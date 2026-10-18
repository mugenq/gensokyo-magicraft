# Project setup and operation

ChatGPT planning has moved into a Project. The permanent project source of truth for agents is this GitHub repository.

## Current state
- Project charter and agent instructions: this setup PR.
- Voice settings are provisional, not a tested renderer.
- Scheduled daily runner: NOT IMPLEMENTED or enabled yet.
- Voice synthesis, video rendering, automatic public upload: NOT IMPLEMENTED.
- There is no automatic live sync of ChatGPT messages into this repository.

## Next implementation milestones
1. Confirm and merge the project-memory PR when accurate.
2. Build a tiny research-runner CLI that reads `AGENTS.md`, `PROJECT.md` and `prompts/daily_research.md`, selects exactly one topic, and outputs the required validated episode files.
3. Run the CLI manually using a tiny spending cap. Check quality, source URLs, output JSON schema, exact line IDs, cost data, and duplicate detection.
4. Only after that, add a scheduled GitHub Actions run with daily concurrency=1, max attempts, timeout, and explicit token/cost budget. Store API credentials in Actions Secrets, never in repo files. Open a draft PR for each episode; NEVER auto-merge or publish.
5. Separately implement a local renderer: VOICEVOX /speakers ID discovery → /audio_query & /synthesis WAV → audio timing → aligned JA/EN SRT → Remotion scenes/MP4. Render only approved scripts.

## Efficiency principles
Use one orchestrator with staged tasks, not many agents repeating the same research. Small model for cheap metadata and translation passes, stronger model for hard math or evidence conflicts. Track tokens and costs; cache approved assets/sources. Do not assume prompt caches persist across runs a day apart.

## Security and rights
This repository is PUBLIC as initially created. Do not store API keys, private personal information, unreleased paid assets, or images/music without sharing rights. VOICEVOX audio permissions, voice-specific terms, character illustration licensing, Touhou fan guidelines, and other IP licenses require separate review.


## Windows local environment (PowerShell)

The local repository workspace is `D:\gensokyo-magicraft`.
- Assets: `D:\gensokyo-magicraft\assets`
- Episode library: `D:\gensokyo-magicraft\episodes`
- Render outputs: `D:\gensokyo-magicraft\renders`
- Temporary cache: `D:\gensokyo-magicraft\.cache`
- VOICEVOX editor executable: `D:\twitch\voicevox-0.25.2-x64.nsis\VOICEVOX.exe`
- Engine endpoint when running: `http://127.0.0.1:50021`

Check the environment from a **local PowerShell session**:

```powershell
Set-Location 'D:\gensokyo-magicraft'
.\scripts\check_windows_environment.ps1
# Explicitly launch VOICEVOX if needed:
.\scripts\check_windows_environment.ps1 -LaunchVoicevox
```

The check script does not create missing folders; it only reports whether the paths and engine are reachable. A cloud agent cannot access the local drive or local VOICEVOX server. All renderer code should read `config/windows.json`, not duplicate paths in source.

### PowerShell compatibility and encoding

`scripts/check_windows_environment.ps1` supports Windows PowerShell 5.1 and PowerShell 7. Keep its source ASCII-only, saved as UTF-8 without BOM (ASCII has identical bytes in both encodings). Speaker names come from `config/voices.json`, which must be saved as UTF-8; the script reads JSON with explicit `-Encoding UTF8`, so that file does not require a BOM.

The VOICEVOX `/speakers` response is also decoded explicitly from UTF-8 bytes. This avoids Windows PowerShell 5.1's incorrect decoding of Japanese JSON when the server does not specify a charset.

Windows PowerShell 5.1 otherwise reads BOM-less script files using the system ANSI code page. If non-ASCII text is ever added to a `.ps1` file, save that file as **UTF-8 with BOM** for Windows PowerShell 5.1. For these environment-check scripts, prefer keeping the source ASCII-only and Unicode data in explicitly decoded JSON instead; the regression check enforces this convention.

Run the regression check under each installed shell from the repository root:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\test_check_windows_environment.ps1
pwsh.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\test_check_windows_environment.ps1
```

`-ExecutionPolicy Bypass` applies only to the test process; it does not change the machine's execution policy. Omit it if your policy already permits local scripts.

The check uses the running shell's parser and mocked VOICEVOX responses to verify Japanese speaker matching (including incorrectly decoded response text), missing-speaker warnings, and the unavailable-engine warning. It makes no network requests, launches no applications, and requires no paid APIs.
