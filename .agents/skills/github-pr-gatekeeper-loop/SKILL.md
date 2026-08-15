---
name: github-pr-gatekeeper-loop
description: Lance la boucle automatique developpeur <-> gatekeeper sur une issue ou une PR GitHub jusqu'a verdict final. Utilise les agents specialises github-developer et github-gatekeeper pour eviter qu'un agent generaliste bascule entre les deux roles.
---

# GitHub PR Gatekeeper Loop

Coordonne deux roles specialises sur la meme issue/PR jusqu'a ce que le gatekeeper rend son verdict final APPROVED ou identifie un blocker reel.

## Use this skill when

- the user explicitly wants an automated developer/gatekeeper loop,
- the workflow must continue without human mediation between review rounds,
- the target outcome is "run until merged" or "loop until approved".

## Roles

- `github-developer`: implements the change and refreshes PR evidence via `implement-issue-github`.
- `github-gatekeeper`: reviews the PR as a strict merge gate via `gatekeeper-pr-github`.

Do not collapse these two roles back into a single general-purpose pass when the specialised agents are available.

## Loop logic

1. Launch `github-developer` on the target issue or blocked PR.
2. Once a PR exists or has been refreshed, launch `github-gatekeeper` on that PR.
3. If the verdict is `BLOCKED`, resume the same `github-developer` context with `GATEKEEPER_MISSING`.
4. Repeat until the verdict is `APPROVED` or a non-fixable blocker is explicit.
5. When the verdict is `APPROVED`, run `finalize-github-pr`.

No human validation step is required between gatekeeper feedback and developer resumption unless the blocker requires a user decision.

## Canonical verdict block

Every gatekeeper verdict must include:

```text
GATEKEEPER_STATUS: BLOCKED|APPROVED
GATEKEEPER_MISSING: changelog,tests,runtime,docs,gitflow
GATEKEEPER_ACTION: developer-fix|none
```

## Shared PR state labels

- `gatekeeper:blocked`
- `gatekeeper:ready-for-recheck`
- `gatekeeper:approved`

## Merge readiness

The PR is merge-ready only when:

1. `GATEKEEPER_STATUS: APPROVED`,
2. label `gatekeeper:approved` is present,
3. label `gatekeeper:blocked` is absent,
4. the PR body still contains the full evidence section.
