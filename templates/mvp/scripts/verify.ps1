$ErrorActionPreference = "Stop"

function Invoke-IfExists {
    param([Parameter(Mandatory = $true)][string]$Path)

    if (Test-Path -LiteralPath $Path -PathType Leaf) {
        Write-Host "Running $Path..."
        & $Path
    }
    else {
        Write-Host "Skipping $Path because it does not exist."
    }
}

function Test-NpmScript {
    param([Parameter(Mandatory = $true)][string]$ScriptName)

    if (-not (Test-Path -LiteralPath "package.json" -PathType Leaf)) {
        return $false
    }

    if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
        return $false
    }

    $json = Get-Content -LiteralPath "package.json" -Raw | ConvertFrom-Json
    if (-not $json.scripts) {
        return $false
    }

    return [bool]($json.scripts.PSObject.Properties.Name -contains $ScriptName)
}

function Invoke-NpmScriptIfExists {
    param([Parameter(Mandatory = $true)][string]$ScriptName)

    if (Test-NpmScript -ScriptName $ScriptName) {
        Write-Host "Running npm run $ScriptName..."
        npm run $ScriptName
    }
    else {
        Write-Host "Skipping npm run $ScriptName because it is not available."
    }
}

Invoke-IfExists ".\scripts\lint.ps1"
Invoke-IfExists ".\scripts\typecheck.ps1"
Invoke-IfExists ".\scripts\test.ps1"
Invoke-IfExists ".\scripts\build.ps1"

Invoke-NpmScriptIfExists "lint"
Invoke-NpmScriptIfExists "typecheck"
Invoke-NpmScriptIfExists "test"
Invoke-NpmScriptIfExists "build"

Write-Host "Verification completed."

