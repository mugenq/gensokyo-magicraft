#requires -Version 5.1
# Keep this script ASCII-only (UTF-8 without BOM is safe for ASCII).
# Non-ASCII speaker names belong in config/voices.json, read explicitly as UTF-8.
# Check local Windows settings for Gensokyo Magicraft.
# From the repo root: .\scripts\check_windows_environment.ps1
# To launch VOICEVOX if it is not running: .\scripts\check_windows_environment.ps1 -LaunchVoicevox
[CmdletBinding()]
param([switch]$LaunchVoicevox)

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$configPath = Join-Path $repoRoot 'config\windows.json'
$config = Get-Content -LiteralPath $configPath -Raw -Encoding UTF8 | ConvertFrom-Json
$voicesPath = Join-Path $repoRoot 'config\voices.json'
$voices = Get-Content -LiteralPath $voicesPath -Raw -Encoding UTF8 | ConvertFrom-Json
$requiredSpeakerNames = @($voices.energetic.voice_name, $voices.reserved.voice_name)

Write-Host "Repository: $repoRoot"
Write-Host "Configured workspace: $($config.workspace_root)"
if (-not (Test-Path -LiteralPath $config.workspace_root -PathType Container)) {
    Write-Warning "Workspace path does not exist yet: $($config.workspace_root)"
} elseif ([System.IO.Path]::GetFullPath($repoRoot).TrimEnd('\') -ine [System.IO.Path]::GetFullPath($config.workspace_root).TrimEnd('\')) {
    Write-Warning "This checkout is not located at the configured workspace. Use the local repository at $($config.workspace_root) for asset production."
} else {
    Write-Host "Workspace path matches this checkout."
}

foreach ($entry in $config.directories.PSObject.Properties) {
    if (Test-Path -LiteralPath $entry.Value -PathType Container) {
        Write-Host "Existing $($entry.Name): $($entry.Value)"
    } else {
        Write-Host "Not created yet ($($entry.Name)): $($entry.Value)"
    }
}

$exe = [string]$config.voicevox_executable
if (Test-Path -LiteralPath $exe -PathType Leaf) {
    Write-Host "VOICEVOX executable found: $exe"
} else {
    Write-Warning "VOICEVOX executable NOT found: $exe"
}

if ($LaunchVoicevox) {
    if (-not (Test-Path -LiteralPath $exe -PathType Leaf)) {
        throw "Cannot launch VOICEVOX: executable missing at configured path"
    }
    if (-not (Get-Process -Name 'VOICEVOX' -ErrorAction SilentlyContinue)) {
        Start-Process -FilePath $exe
        Write-Host "Started VOICEVOX."
    } else {
        Write-Host "VOICEVOX appears to be running."
    }
}

$api = [string]$config.voicevox_api_base
$attempts = if ($LaunchVoicevox) { 8 } else { 1 }
$connected = $false
for ($i=0; $i -lt $attempts; $i++) {
    try {
        $version = Invoke-RestMethod -Uri "$api/version" -TimeoutSec 3
        Write-Host "VOICEVOX API available at $api (version $version)"
        # The engine returns UTF-8 JSON without a charset. PowerShell 5.1 can
        # decode it as ANSI, so decode the response bytes explicitly instead.
        $speakerResponse = Invoke-WebRequest -Uri "$api/speakers" -UseBasicParsing -TimeoutSec 5
        $speakers = [System.Text.Encoding]::UTF8.GetString($speakerResponse.RawContentStream.ToArray()) | ConvertFrom-Json
        $names = @($speakers | ForEach-Object { $_.name })
        foreach ($requiredName in $requiredSpeakerNames) {
            if ($names -contains $requiredName) { Write-Host "Speaker found: $requiredName" }
            else { Write-Warning "Speaker not found: $requiredName" }
        }
        $connected = $true
        break
    } catch {
        if ($i -lt $attempts - 1) { Start-Sleep -Seconds 2 }
    }
}
if (-not $connected) {
    Write-Warning "VOICEVOX API unavailable at $api. Launch the desktop app, then retry. The executable and engine must be verified locally."
}
