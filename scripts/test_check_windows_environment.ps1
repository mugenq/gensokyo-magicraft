#requires -Version 5.1
# Keep this regression check ASCII-only; run it in both powershell.exe and pwsh.exe.
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$checkPath = Join-Path $PSScriptRoot 'check_windows_environment.ps1'

# ParseFile uses this host's normal file decoding, just like invoking a .ps1 file.
# ASCII-only source prevents dependence on the machine's ANSI code page in 5.1.
foreach ($path in @($checkPath, $PSCommandPath)) {
    $bytes = [System.IO.File]::ReadAllBytes($path)
    if (@($bytes | Where-Object { $_ -gt 127 }).Count -ne 0) {
        throw "Keep environment-check scripts ASCII-only: $path"
    }
    $tokens = $null
    $parseErrors = $null
    $null = [System.Management.Automation.Language.Parser]::ParseFile(
        $path, [ref]$tokens, [ref]$parseErrors
    )
    if ($parseErrors.Count -ne 0) {
        throw "Syntax errors in ${path}: $($parseErrors -join '; ')"
    }
}

# Independent Unicode expectations, without non-ASCII source or API calls.
$expectedNames = @(
    (-join [char[]]@(0x6625, 0x65E5, 0x90E8, 0x3064, 0x3080, 0x304E)),
    ((-join [char[]]@(0x5C0F, 0x591C)) + '/SAYO')
)
$configPath = Join-Path $repoRoot 'config\windows.json'
$config = Get-Content -LiteralPath $configPath -Raw -Encoding UTF8 | ConvertFrom-Json
$api = [string]$config.voicevox_api_base
$environmentCheckTestState = @{
    Api = $api
    ExpectedNames = $expectedNames
    Scenario = ''
    Requests = (New-Object 'System.Collections.Generic.List[string]')
}

# Functions in the caller's scope shadow the web cmdlets in the check script.
# Unexpected endpoints fail the test; no HTTP request can leave these mocks.
function Invoke-RestMethod {
    param([string]$Uri, [int]$TimeoutSec)

    $environmentCheckTestState.Requests.Add($Uri)
    if ($environmentCheckTestState.Scenario -eq 'offline') {
        throw 'Mock engine unavailable'
    }
    if ($Uri -eq "$($environmentCheckTestState.Api)/version") {
        return 'mock-version'
    }
    throw "Unexpected REST endpoint: $Uri"
}

function Invoke-WebRequest {
    param([string]$Uri, [int]$TimeoutSec, [switch]$UseBasicParsing)

    $environmentCheckTestState.Requests.Add($Uri)
    if ($Uri -eq "$($environmentCheckTestState.Api)/speakers") {
        $names = $environmentCheckTestState.ExpectedNames
        if ($environmentCheckTestState.Scenario -eq 'missing-speaker') {
            $names = @($environmentCheckTestState.ExpectedNames[0])
        }
        $json = ConvertTo-Json -InputObject @($names | ForEach-Object { [pscustomobject]@{ name = $_ } })
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($json)
        # Simulate 5.1 decoding charset-less UTF-8 as Latin-1. Only the raw
        # response bytes should be used to match Japanese speaker names.
        return [pscustomobject]@{
            Content = [System.Text.Encoding]::GetEncoding(28591).GetString($bytes)
            RawContentStream = (New-Object System.IO.MemoryStream(, $bytes))
        }
    }
    throw "Unexpected endpoint: $Uri"
}

function Assert-Message {
    param([string[]]$Messages, [string]$Expected)
    if ($Messages -notcontains $Expected) {
        throw "Missing expected message: $Expected`n$($Messages -join [Environment]::NewLine)"
    }
}

foreach ($scenario in @('available', 'missing-speaker', 'offline')) {
    $environmentCheckTestState.Scenario = $scenario
    $environmentCheckTestState.Requests.Clear()
    # Do not pass -LaunchVoicevox. Capture host output and warnings in both hosts.
    $messages = @(& $checkPath 3>&1 6>&1 | ForEach-Object { [string]$_ })

    if ($scenario -eq 'offline') {
        Assert-Message $messages "VOICEVOX API unavailable at $api. Launch the desktop app, then retry. The executable and engine must be verified locally."
        $expectedRequests = @("$api/version")
    } else {
        Assert-Message $messages "VOICEVOX API available at $api (version mock-version)"
        Assert-Message $messages "Speaker found: $($expectedNames[0])"
        if ($scenario -eq 'available') {
            Assert-Message $messages "Speaker found: $($expectedNames[1])"
        } else {
            Assert-Message $messages "Speaker not found: $($expectedNames[1])"
        }
        $expectedRequests = @("$api/version", "$api/speakers")
    }
    if (($environmentCheckTestState.Requests -join '|') -cne ($expectedRequests -join '|')) {
        throw "Unexpected requests in ${scenario}: $($environmentCheckTestState.Requests -join ', ')"
    }
}

Write-Host "PASS: ASCII source, syntax parsing, and mocked environment checks (PowerShell $($PSVersionTable.PSVersion))."
