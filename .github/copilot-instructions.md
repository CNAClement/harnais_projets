# Harnais Projets - Repository Instructions

## Project scope

- Linux-only project.
- Personal project: optimize for simplicity and maintainability, not multi-user production hardening.

## Engineering rules

- Keep it simple. Prefer small reusable functions and explicit control flow.
- Avoid over-engineering, speculative abstractions, and defensive fallbacks for unrealistic scenarios.
- When replacing an existing behavior, rewrite or remove the old path in the same change when possible.
- Do not modify unrelated branches or unrelated work in progress.

## Reproducibility

- Do not install system or Python dependencies ad hoc in terminal commands. Always use requirements.txt instead.
- Any dependency or setup change must stay reproducible, e.g through a dedicated setup.sh skill . 

## Working method

- Check the current branch before making changes.
- Prefer a dedicated branch per issue, except for very small changes explicitly kept on `main`.
- After each change, run the most relevant impacted script or tests before handing off.
- If a simplification opportunity is discovered while working in the touched area, prefer the simpler design.

## Documentation

- Keep documentation aligned with the code in the same change.
- Update docstrings, comments, README, and changelog when behavior or workflow changes.
- Write changelog entries as short pedagogical explanations, not only as terse bullet points.

## Agent behavior

- Challenge assumptions when needed instead of agreeing by default.
- Double-check conclusions to reduce hallucinations.
- **At the end of every significant agent session, invoke the `compte-rendu-execution` skill** to produce a timestamped execution trace in `compte_rendu_executions_agents/`. This applies to any session involving code changes, fixes, refactors, skill creation, or multi-step workflows. Do not skip this step.
