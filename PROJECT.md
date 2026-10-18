# Gensokyo Magicraft | Project brief

## Mission
Build a Touhou-inspired Japanese-first edutainment channel, combining rigorous mathematics, physics, logic, computational experiments, canon-aware theorycrafting, and imaginative crossover thought experiments. Make compelling investigations, not mass-produced fanfiction.

## Decisions from the ChatGPT planning conversation
- Format: programmable video with reusable, properly licensed sprites, graphics, backgrounds, diagrams, narration, and audio. Prefer deterministic renders over generating whole clips with video AI.
- Voices: tentative VOICEVOX pair 春日部つむぎ (energetic host) and 小夜/SAYO (gentle/quiet skeptical host). Confirm voice-bank and artwork licensing before commercial release; credit appropriately.
- Script source of truth: Japanese dialogue. Translate directly from the FINAL Japanese lines to idiomatic English with matching line IDs. Export Japanese and English SRT assets separately; do not permanently burn in English by default.
- Research: one distinct, carefully researched script package each day, stored in a dated episode folder. Do NOT automatically publish daily videos.
- Quality: include sources, uncertainties, mathematical assumptions, runnable experiment plans, and original dialogue. Reviewer/owner approval is required before producing or publishing.
- Pilot: 4–6 minutes, e.g. "Can Reimu Dodge One Million Bullets?", addressing hitboxes, projectile density, path geometry, movement limits, and reproducible simulations.
- Editorial: energetic host introduces problems; quiet host asks intelligent objections. Clearly separate established canon, reasonable interpretation, scientific modeling, and fictional conjecture.
- Content pillars: Touhou × mathematics/physics; Touhou × logical what-ifs; occasional Naruto/Re:Zero crossovers; and technology/VTuber/Hololive experiments subject to IP reviews.
- Publication: one human-reviewed polished video per week is an initial aspiration, not an automated commitment.
- Monetization: no promises; distinguish copyright permissions for Touhou, other IP, voices, music, artwork, fonts, and platform rules.

## Architecture
ChatGPT Project = decisions and collaborative planning.
This GitHub repository = durable approved agent instructions, scripts, provenance, and production code.
A daily job (NOT active yet) = one bounded research run, saving reviewable artifacts.
A separate local rendering job (NOT implemented yet) = synthesis with VOICEVOX and rendering with Python/Manim/Remotion/FFmpeg for approved scripts.

ChatGPT Project conversations do not automatically sync to this repository. Update these files explicitly when decisions become final.

## Safety and cost
Never commit secrets or paid/restricted media. Use GitHub Actions secrets for credentials. Minimize repeated context, reuse reviewed assets and research, cap retries and spend, and never publish or render unapproved scripts.
