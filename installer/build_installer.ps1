param(
    [string]$AppName = "Focus Application",
    [string]$Publisher = "Focus Application Team",
    [string]$ExeName = "flutter_application_1.exe"
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$pubspecPath = Join-Path $repoRoot "pubspec.yaml"
$pubspecText = Get-Content $pubspecPath -Raw

$versionMatch = [regex]::Match($pubspecText, '(?m)^version:\s*([^\r\n]+)')
if (-not $versionMatch.Success) {
    throw "Could not find a version in pubspec.yaml"
}

$buildName = ($versionMatch.Groups[1].Value -split '\+')[0].Trim()
$flutter = Get-Command flutter -ErrorAction Stop
$isccPath = Join-Path $env:LOCALAPPDATA "Programs\Inno Setup 6\ISCC.exe"

if (-not (Test-Path $isccPath)) {
    throw "Inno Setup compiler not found at $isccPath"
}

Push-Location $repoRoot
try {
    & $flutter.Source build windows --release
    if ($LASTEXITCODE -ne 0) {
        throw "flutter build windows --release failed with exit code $LASTEXITCODE"
    }

    $isccArgs = @(
        "/DMyAppName=$AppName"
        "/DMyAppVersion=$buildName"
        "/DMyAppPublisher=$Publisher"
        "/DMyAppExeName=$ExeName"
        (Join-Path $PSScriptRoot "focus_application.iss")
    )

    & $isccPath @isccArgs
    if ($LASTEXITCODE -ne 0) {
        throw "ISCC failed with exit code $LASTEXITCODE"
    }
}
finally {
    Pop-Location
}