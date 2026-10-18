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
