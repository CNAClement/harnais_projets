---
name: gatekeeper-pr-github
description: Rendre un verdict gatekeeper strict sur une PR GitHub avant merge. Verifie les preuves, le gitflow et publie un bloc machine-readable GATEKEEPER_*. Skill procedural a utiliser depuis l'agent github-gatekeeper ou en secours direct.
---

# gatekeeper-pr-github

Agis comme la merge gate stricte pour une PR GitHub avec verification d'evidence et verdict machine-readable.

## Shared GitHub preflight

Before using `gh pr-review ...` or any `gh pr ...` command, run the shared helper [github_context.sh](/home/naarc/harnais_projets/.agents/skills/workflow-github/scripts/github_context.sh):

```sh
source .agents/skills/workflow-github/scripts/github_context.sh
github_preflight GITHUB_TOKEN_PR_REVIEW
```

This authenticates `gh` and resolves the target repository into `$GITHUB_REPO`.

## Position in the workflow

- This is the procedural skill used by the `github-gatekeeper` agent.
- Use `review-pr-github` when you only need structured review-thread access.
- Do not edit code from this skill. Gatekeeper judges the PR state and evidence only.

## Canonical verdict

Every final gatekeeper review body must include:

```text
GATEKEEPER_STATUS: BLOCKED|APPROVED
GATEKEEPER_MISSING: changelog,tests,runtime,docs,gitflow
GATEKEEPER_ACTION: developer-fix|none
```

PR labels used as state:

- `gatekeeper:blocked`
- `gatekeeper:ready-for-recheck`
- `gatekeeper:approved`

If labels are missing, create them before use.

## Mandatory verification points

Gatekeeper must block the PR when any required proof is missing or weak:

1. changelog or equivalent project history update when expected,
2. tests evidence for changed behavior,
3. production-like runtime validation evidence for the real affected execution path,
4. documentation evidence when relevant,
5. gitflow evidence: a dedicated branch based on `origin/main`.

## Gitflow base branch verification

Mandatory checks before final verdict:

1. PR base branch is `main`,
2. PR head branch is not `main`,
3. git ancestry confirms a strict `origin/main` base policy.

Suggested commands:

```sh
PR=<pr-number>
BASE_REF=$(gh pr view "$PR" --repo "$GITHUB_REPO" --json baseRefName -q .baseRefName)
HEAD_REF=$(gh pr view "$PR" --repo "$GITHUB_REPO" --json headRefName -q .headRefName)

git fetch origin
git fetch origin "$HEAD_REF"
STRICT_BASE_OK=0
if [[ "$BASE_REF" == "main" && "$HEAD_REF" != "main" ]]; then
  BASE_SHA=$(git rev-parse origin/main)
  HEAD_SHA=$(git rev-parse "origin/$HEAD_REF")
  MERGE_BASE=$(git merge-base "$BASE_SHA" "$HEAD_SHA")
  [[ "$MERGE_BASE" == "$BASE_SHA" ]] && STRICT_BASE_OK=1
fi
```

If `STRICT_BASE_OK` is `0`, gatekeeper must block the PR and include `gitflow` in `GATEKEEPER_MISSING`.

## Verdict actions

If status is `BLOCKED`:

1. submit `REQUEST_CHANGES` when technically possible,
2. if GitHub disallows `REQUEST_CHANGES`, submit `COMMENT` with explicit blocker wording and the machine-readable block,
3. add `gatekeeper:blocked`, remove `gatekeeper:ready-for-recheck` and `gatekeeper:approved`.

If status is `APPROVED`:

1. submit `APPROVE`,
2. add `gatekeeper:approved`, remove `gatekeeper:blocked` and `gatekeeper:ready-for-recheck`.

## Suggested review commands

```sh
gh pr-review review view -R "$GITHUB_REPO" --pr <number>
```

```sh
gh pr-review review --submit \
  --review-id <PRR_...> \
  --event <APPROVE|REQUEST_CHANGES|COMMENT> \
  --body "Overall review summary" \
  -R "$GITHUB_REPO" <pr-number>
```
