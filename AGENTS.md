# Gensokyo Magicraft | Agent instructions

Read `PROJECT.md` before working. Follow the relevant `prompts/` file for your assigned task. Keep context small: do not reread the entire conversation history or every episode.

## One daily research task
1. Check the existing episode index and previous projects for duplicates.
2. Select ONE Touhou-centered question with an interesting analytical or testable angle.
3. Gather verifiable primary sources for canon and reliable references for scientific or contemporary claims. Store exact URLs, dates, and uncertainties.
4. Distinguish canon, interpretation, hypotheses, and crossover rules. Build a sound argument or reproducible simulation plan. Do not invent numerical results.
5. Write Japanese dialogue for two hosts: energetic 春日部つむぎ, reserved 小夜/SAYO. The reserved host must be thoughtful, not a strawman.
6. Translate each FINAL Japanese line directly into natural English, keeping stable aligned line IDs.
7. Create a storyboard and asset requirements for programmable video. Prefer approved reused assets over new ones.
8. Run brief factual, copyright, originality, cost, and language QA. Output a ready-for-review package, not a claim of publication readiness.

## Required files per episode
Create `episodes/YYYY-MM-DD_slug/`:
- `research.md` — question, claim/evidence table, sources, assumptions, analysis, limitations.
- `script_ja.json` — structured Japanese dialogue, stable IDs, voice keys, emotions, scene hints.
- `translation_en.json` — matching IDs and direct JA→EN subtitle text.
- `storyboard.json` — sequence of scenes, reusable graphics and animation requirements.
- `assets.json` — needed assets, provenance, license status, reviewer flags.
- `review.md` — quality checks, unresolved issues, human-approval recommendation.
- `metadata.json` — unique topic key, lifecycle status, relevant model usage/cost.

## Operational rules
- Prefer a single staged research workflow. Use separate specialist agents only when justified.
- Reuse previously reviewed evidence where relevant; refresh time-sensitive claims.
- No unbounded retries or self-improvement loops. Log token usage, model, tool time, approximate API spend, and failures where possible.
- No TTS, image generation, final rendering, public upload, or monetization actions during daily research.
- Never commit API keys, private user data, restricted assets, or other secrets.
- If reliable evidence is unavailable, preserve the incomplete draft with an explicit warning.
- Prefer branch + draft pull request for changes; do not merge or publish without the user's review.
- Treat outside-IP crossovers as copyright-sensitive; fan content guidelines from one franchise do not clear another franchise.
- Follow each voice library's terms and attribution rules. VOICEVOX voice use does not license Touhou or other character art.


## Local Windows workstation and PowerShell
- The user's local workspace is `D:\gensokyo-magicraft`. The working tree, assets, episode packages, and local render outputs belong under that root.
- VOICEVOX executable: `D:\twitch\voicevox-0.25.2-x64.nsis\VOICEVOX.exe`. It is the desktop editor; verify its local synthesis API at `http://127.0.0.1:50021` instead of assuming it is ready.
- For local shell commands use PowerShell. Read runtime paths from `config/windows.json` and use `scripts/check_windows_environment.ps1` to test them.
- Cloud Codex cannot access the local `D:` drive; it must use mocks and must never claim local VOICEVOX or disk verification succeeded.
- The repository is public. Do not commit restricted assets, generated audio/video, personal information, or secrets.
