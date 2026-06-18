[CmdletBinding()]
param(
    [ValidateSet("mvp", "full")]
    [string]$Profile = "mvp",

    [string]$Target = (Get-Location).Path,

    [switch]$Force
)

$ErrorActionPreference = "Stop"

$RepoUrl = if ($env:AGENT_HARNESS_REPO) { $env:AGENT_HARNESS_REPO } else { "https://github.com/myloveit191/agent-harness" }
$Ref = if ($env:AGENT_HARNESS_REF) { $env:AGENT_HARNESS_REF } else { "main" }
$script:TempDownloadDirectory = $null

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

try {
    New-Item -ItemType Directory -Path $Target -Force | Out-Null
    $Target = (Resolve-Path -LiteralPath $Target).Path
    $templatesDirectory = Get-TemplatesDirectory
    $timestamp = Get-Date -Format "yyyyMMddHHmmss"

    Copy-Profile -Source (Join-Path $templatesDirectory "mvp") -Destination $Target -Timestamp $timestamp
    if ($Profile -eq "full") {
        Copy-Profile -Source (Join-Path $templatesDirectory "full") -Destination $Target -Timestamp $timestamp
    }

    Write-Host ""
    Write-Host "agent-harness installed."
    Write-Host ""
    Write-Host "Profile: $Profile"
    Write-Host "Target:  $Target"
    Write-Host ""
    Write-Host "Next steps:"
    Write-Host "  1. Review AGENTS.md."
    Write-Host "  2. Customize .harness/instructions/context-map.md."
    Write-Host "  3. Run verification:"
    Write-Host "     .\scripts\verify.ps1"
    Write-Host ""
}
finally {
    if ($script:TempDownloadDirectory -and (Test-Path -LiteralPath $script:TempDownloadDirectory)) {
        Remove-Item -LiteralPath $script:TempDownloadDirectory -Recurse -Force
    }
}
