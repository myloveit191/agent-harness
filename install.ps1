[CmdletBinding()]
param(
    [ValidateSet("mvp", "full")]
    [string]$Profile = "mvp",

    [string[]]$Pack = @(),

    [string]$Target = (Get-Location).Path,

    [switch]$Force,

    [switch]$Yes
)

$ErrorActionPreference = "Stop"
$InteractiveMode = $PSBoundParameters.Count -eq 0

$RepoUrl = if ($env:AGENT_HARNESS_REPO) { $env:AGENT_HARNESS_REPO } else { "https://github.com/myloveit191/agent-harness" }
$Ref = if ($env:AGENT_HARNESS_REF) { $env:AGENT_HARNESS_REF } else { "main" }
$Version = "0.2.0"
$script:TempDownloadDirectory = $null

function Get-NormalizedPacks {
    param([string[]]$InputPacks)

    $result = New-Object System.Collections.Generic.List[string]

    foreach ($entry in $InputPacks) {
        if (-not $entry) {
            continue
        }

        foreach ($name in ($entry -split ",")) {
            $trimmed = $name.Trim()
            if ($trimmed) {
                $result.Add($trimmed)
            }
        }
    }

    return $result.ToArray()
}

function Get-AvailablePacks {
    param([Parameter(Mandatory = $true)][string]$TemplatesDirectory)

    $packsDirectory = Join-Path $TemplatesDirectory "packs"
    if (-not (Test-Path -LiteralPath $packsDirectory -PathType Container)) {
        return @()
    }

    return @(Get-ChildItem -LiteralPath $packsDirectory -Directory | Sort-Object Name | ForEach-Object { $_.Name })
}

function Get-TemplatesDirectory {
    $scriptPath = $PSCommandPath
    if ($scriptPath) {
        $scriptDir = Split-Path -Parent $scriptPath
        $localTemplates = Join-Path $scriptDir "templates"
        if (Test-Path -LiteralPath $localTemplates -PathType Container) {
            return $localTemplates
        }
    }

    $script:TempDownloadDirectory = Join-Path ([System.IO.Path]::GetTempPath()) ("agent-harness-" + [System.Guid]::NewGuid().ToString("N"))
    New-Item -ItemType Directory -Path $script:TempDownloadDirectory | Out-Null
    $archivePath = Join-Path $script:TempDownloadDirectory "agent-harness.zip"

    Write-Host "Downloading templates from $RepoUrl ($Ref)..."
    Invoke-WebRequest -Uri "$RepoUrl/archive/refs/heads/$Ref.zip" -OutFile $archivePath
    Expand-Archive -LiteralPath $archivePath -DestinationPath $script:TempDownloadDirectory

    $templates = Get-ChildItem -LiteralPath $script:TempDownloadDirectory -Directory -Recurse |
        Where-Object { $_.Name -eq "templates" } |
        Select-Object -First 1

    if (-not $templates) {
        throw "Could not find templates directory in downloaded archive."
    }

    return $templates.FullName
}

function Copy-Profile {
    param(
        [Parameter(Mandatory = $true)][string]$Source,
        [Parameter(Mandatory = $true)][string]$Destination,
        [Parameter(Mandatory = $true)][string]$Timestamp
    )

    if (-not (Test-Path -LiteralPath $Source -PathType Container)) {
        throw "Template profile does not exist: $Source"
    }

    $sourceRoot = (Resolve-Path -LiteralPath $Source).Path.TrimEnd('\', '/')

    Get-ChildItem -LiteralPath $Source -Directory -Recurse | ForEach-Object {
        $relative = $_.FullName.Substring($sourceRoot.Length).TrimStart('\', '/')
        $targetDirectory = Join-Path $Destination $relative
        New-Item -ItemType Directory -Path $targetDirectory -Force | Out-Null
    }

    Get-ChildItem -LiteralPath $Source -File -Recurse | ForEach-Object {
        $relative = $_.FullName.Substring($sourceRoot.Length).TrimStart('\', '/')
        $targetFile = Join-Path $Destination $relative
        $targetDirectory = Split-Path -Parent $targetFile
        New-Item -ItemType Directory -Path $targetDirectory -Force | Out-Null

        if (Test-Path -LiteralPath $targetFile) {
            if (-not $Force) {
                throw "Refusing to overwrite existing file: $targetFile. Re-run with -Force to back it up and replace it."
            }

            $backup = "$targetFile.backup.$Timestamp"
            Copy-Item -LiteralPath $targetFile -Destination $backup
            Write-Host "Backed up $targetFile -> $backup"
        }

        Copy-Item -LiteralPath $_.FullName -Destination $targetFile -Force
    }
}

function Copy-Pack {
    param(
        [Parameter(Mandatory = $true)][string]$TemplatesDirectory,
        [Parameter(Mandatory = $true)][string]$PackName,
        [Parameter(Mandatory = $true)][string]$Destination,
        [Parameter(Mandatory = $true)][string]$Timestamp
    )

    $source = Join-Path (Join-Path $TemplatesDirectory "packs") $PackName
    if (-not (Test-Path -LiteralPath $source -PathType Container)) {
        throw "Pack does not exist: $PackName"
    }

    $packDestination = Join-Path (Join-Path $Destination ".agent-harness\packs") $PackName
    Copy-Profile -Source $source -Destination $packDestination -Timestamp $Timestamp
}

function Write-GeneratedFile {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Content,
        [Parameter(Mandatory = $true)][string]$Timestamp
    )

    $directory = Split-Path -Parent $Path
    New-Item -ItemType Directory -Path $directory -Force | Out-Null

    if (Test-Path -LiteralPath $Path) {
        if (-not $Force) {
            throw "Refusing to overwrite existing file: $Path. Re-run with -Force to back it up and replace it."
        }

        $backup = "$Path.backup.$Timestamp"
        Copy-Item -LiteralPath $Path -Destination $backup
        Write-Host "Backed up $Path -> $backup"
    }

    Set-Content -LiteralPath $Path -Value $Content -Encoding UTF8
}

function Write-Metadata {
    param(
        [Parameter(Mandatory = $true)][string]$Destination,
        [Parameter(Mandatory = $true)][string]$Timestamp,
        [string[]]$Packs = @()
    )

    $metadata = [ordered]@{
        version = $Version
        profile = $Profile
        layout = "nested"
        packs = $Packs
        installedAt = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    }

    $json = $metadata | ConvertTo-Json -Depth 4 -Compress
    $metadataPath = Join-Path $Destination ".agent-harness\agent-harness.json"
    Write-GeneratedFile -Path $metadataPath -Content $json -Timestamp $Timestamp
}

function Invoke-InteractiveConfig {
    param([Parameter(Mandatory = $true)][string]$TemplatesDirectory)

    if (-not $InteractiveMode) {
        return
    }

    Write-Host ""
    Write-Host "Agent Harness Installer $Version"
    Write-Host ""
    Write-Host "Choose profile:"
    Write-Host "  1) mvp  (recommended)"
    Write-Host "  2) full"
    $profileAnswer = Read-Host "Profile [1]"
    switch ($profileAnswer) {
        "2" { $script:Profile = "full" }
        "full" { $script:Profile = "full" }
        "Full" { $script:Profile = "full" }
        default { $script:Profile = "mvp" }
    }

    $availablePacks = @(Get-AvailablePacks -TemplatesDirectory $TemplatesDirectory)
    $script:Pack = @()
    if ($availablePacks.Count -gt 0) {
        Write-Host ""
        Write-Host "Choose packs. Enter numbers or names separated by commas, or leave empty for none:"
        for ($index = 0; $index -lt $availablePacks.Count; $index++) {
            Write-Host ("  {0}) {1}" -f ($index + 1), $availablePacks[$index])
        }

        $packsAnswer = Read-Host "Packs [none]"
        if ($packsAnswer) {
            $selected = New-Object System.Collections.Generic.List[string]
            foreach ($entry in ($packsAnswer -split ",")) {
                $trimmed = $entry.Trim()
                if (-not $trimmed) {
                    continue
                }

                $number = 0
                if ([int]::TryParse($trimmed, [ref]$number) -and $number -ge 1 -and $number -le $availablePacks.Count) {
                    $selected.Add($availablePacks[$number - 1])
                }
                else {
                    $selected.Add($trimmed)
                }
            }
            $script:Pack = $selected.ToArray()
        }
    }

    Write-Host ""
    $targetAnswer = Read-Host "Target directory [$Target]"
    if ($targetAnswer) {
        $script:Target = $targetAnswer
    }

    $rootAgents = Join-Path $script:Target "AGENTS.md"
    $harnessDirectory = Join-Path $script:Target ".agent-harness"
    if ((Test-Path -LiteralPath $rootAgents) -or (Test-Path -LiteralPath $harnessDirectory)) {
        Write-Host ""
        Write-Host "Existing agent-harness files were found in the target."
        $overwriteAnswer = Read-Host "Back up and overwrite existing files? [y/N]"
        if ($overwriteAnswer -match "^(y|yes)$") {
            $script:Force = $true
        }
        else {
            $script:Force = $false
        }
    }

    [string[]]$summaryPacks = @(Get-NormalizedPacks -InputPacks $script:Pack)
    Write-Host ""
    Write-Host "Install summary:"
    Write-Host "  Profile: $script:Profile"
    if ($summaryPacks.Count -eq 0) {
        Write-Host "  Packs:   none"
    }
    else {
        Write-Host "  Packs:   $($summaryPacks -join ', ')"
    }
    Write-Host "  Target:  $script:Target"
    if ($script:Force) {
        Write-Host "  Force:   backup and overwrite"
    }
    else {
        Write-Host "  Force:   no"
    }

    if (-not $script:Yes) {
        $confirmAnswer = Read-Host "Continue? [Y/n]"
        if ($confirmAnswer -match "^(n|no)$") {
            Write-Host "Install cancelled."
            exit 0
        }
    }
}

try {
    $templatesDirectory = Get-TemplatesDirectory
    Invoke-InteractiveConfig -TemplatesDirectory $templatesDirectory

    New-Item -ItemType Directory -Path $Target -Force | Out-Null
    $Target = (Resolve-Path -LiteralPath $Target).Path
    $timestamp = Get-Date -Format "yyyyMMddHHmmss"
    [string[]]$normalizedPacks = @(Get-NormalizedPacks -InputPacks $Pack)

    foreach ($packName in $normalizedPacks) {
        if ($packName -notmatch "^[a-z0-9][a-z0-9-]*$") {
            throw "Invalid pack name: $packName. Use lowercase letters, numbers, and hyphens."
        }

        $packPath = Join-Path (Join-Path $templatesDirectory "packs") $packName
        if (-not (Test-Path -LiteralPath $packPath -PathType Container)) {
            throw "Pack does not exist: $packName"
        }
    }

    Copy-Profile -Source (Join-Path $templatesDirectory "core\mvp") -Destination $Target -Timestamp $timestamp
    if ($Profile -eq "full") {
        Copy-Profile -Source (Join-Path $templatesDirectory "core\full") -Destination $Target -Timestamp $timestamp
    }

    foreach ($packName in $normalizedPacks) {
        Copy-Pack -TemplatesDirectory $templatesDirectory -PackName $packName -Destination $Target -Timestamp $timestamp
    }

    Write-Metadata -Destination $Target -Timestamp $timestamp -Packs $normalizedPacks

    Write-Host ""
    Write-Host "agent-harness installed."
    Write-Host ""
    Write-Host "Profile: $Profile"
    if ($normalizedPacks.Count -eq 0) {
        Write-Host "Packs:   none"
    }
    else {
        Write-Host "Packs:   $($normalizedPacks -join ', ')"
    }
    Write-Host "Target:  $Target"
    Write-Host ""
    Write-Host "Next steps:"
    Write-Host "  1. Review AGENTS.md."
    Write-Host "  2. Customize .agent-harness/harness/instructions/context-map.md."
    Write-Host "  3. Run verification:"
    Write-Host "     .\.agent-harness\scripts\verify.ps1"
    Write-Host ""
}
finally {
    if ($script:TempDownloadDirectory -and (Test-Path -LiteralPath $script:TempDownloadDirectory)) {
        Remove-Item -LiteralPath $script:TempDownloadDirectory -Recurse -Force
    }
}
