---
name: implement-issue-github
description: Implemente une issue GitHub de bout en bout -- analyse, branche, code, validations, preuves et ouverture de PR. Skill procedural a utiliser depuis l'agent github-developer ou en secours direct.
---

# Implement GitHub Issue

Execute le workflow complet de developpeur : analyser l'issue, implementer, valider, et ouvrir une PR avec evidence complete.

## Shared GitHub preflight

Use the shared helper [github_context.sh](/home/naarc/harnais_projets/.agents/skills/workflow-github/scripts/github_context.sh) before any `gh` command:

```sh
source .agents/skills/workflow-github/scripts/github_context.sh
github_preflight GITHUB_TOKEN_FIX_ISSUE
```

This resolves the target repository in the following order:

1. `GITHUB_REPO=owner/repo`
2. `GH_REPO`
3. the Git remote `origin`
4. the active `gh` context

If none of these works, ask the user only for the missing `owner/repo` value.

## Position in the workflow

- This is the procedural skill used by the `github-developer` agent.
- When `workflow-github` is the entry point, prefer launching that agent instead of having the general agent inline the whole implementation flow.

## Operating rules

- Do not ask the user to authenticate `gh` manually.
- Check the current branch before changing code.
- Create or recreate the work branch from `origin/main`.
- Prefer the smallest targeted validation that covers the change; expand only if the evidence is still weak.
- Do not consider the task complete while mandatory PR evidence is missing.

## Handshake with `gatekeeper-pr-github`

When this skill is part of the GitHub workflow, it must cooperate with the gatekeeper reviewer.

PR labels used as state:

- `gatekeeper:blocked`
- `gatekeeper:ready-for-recheck`
- `gatekeeper:approved`

The gatekeeper emits a machine-readable block:

```text
GATEKEEPER_STATUS: BLOCKED|APPROVED
GATEKEEPER_MISSING: changelog,tests,runtime,docs,gitflow
GATEKEEPER_ACTION: developer-fix|none
```

If status is `BLOCKED`, resume immediately:

1. read the latest review or comment,
2. parse `GATEKEEPER_MISSING`,
3. change only what is missing,
4. update the PR evidence,
5. comment `DEVELOPER_READY_FOR_RECHECK`,
6. remove `gatekeeper:blocked` and add `gatekeeper:ready-for-recheck`.

If `gitflow` is missing, rebuild the branch from `origin/main` first.

## Workflow

### 1. Read context before touching code

Read the project-level instructions first:

1. `README.md`
2. `.github/copilot-instructions.md`
3. relevant files in `.github/instructions/`

Why: on a fresh repository, these files define the local rules better than guesswork does.

Then inspect the issue in full:

```sh
gh issue view <issue-number> --repo "$GITHUB_REPO" --comments
```

If useful, post a short diagnosis comment before implementation:

```sh
cat > /tmp/issue-diagnosis.md <<'BODY'
[COMMENTAIRE AUTOMATIQUE AGENT] DIAGNOSTIC INITIAL.

<root cause or current understanding>
BODY

gh issue comment <issue-number> --repo "$GITHUB_REPO" --body-file /tmp/issue-diagnosis.md
```

### 2. Investigate and plan

- Search the codebase for the affected files, commands, and symbols.
- Read the issue history and related PRs if they exist.
- Write a short scratch plan only if it helps coordinate a non-trivial fix.

### 3. Create a clean issue branch

Required sequence:

```sh
git fetch origin
git checkout -B <issue-branch> origin/main
git branch --show-current
```

Branch example: `fix/issue-123-short-slug`

### 4. Implement the change

- Make the smallest coherent change that solves the root cause.
- Reuse existing helpers before adding new ones.
- Update docs or comments when the behavior or workflow changes.
- Keep commits readable and scoped.

### 5. Validate

Validation is mandatory and must reflect the real impact of the change.

Required checks:

1. run the most targeted automated tests already present in the repository,
2. run any relevant lint/type/build step only if the touched area depends on it,
3. exercise the real runtime path affected by the issue when feasible (CLI, service, script, UI flow, job runner, etc.).

Capture evidence you will reuse in the PR:

- exact commands,
- pass/fail summaries,
- relevant logs or screenshots,
- what you observed in the runtime check.

### 6. Prepare labels

Issue and PR should both have labels.

Type labels:

- `bug`
- `enhancement`
- `refactor`
- `tech-debt`

Optional execution labels:

- `needs-tests`
- `needs-runtime-validation`
- `needs-docs`

If a required label is missing, create it before applying it.

### 7. Open the PR

Push the branch and create a PR that closes the issue:

- include `Fixes #<issue-number>`,
- include a concise change summary,
- include the evidence section below,
- request review.

Use this evidence block in the PR body:

```md
## Evidence
- Changelog/docs: <files changed and why>
- Tests: <commands and outcome>
- Runtime validation: <real path exercised and result>
- Artifacts: <logs, screenshots, reports, paths>

## Evidence Status
EVIDENCE_CHANGELOG: OK|MISSING
EVIDENCE_TESTS: OK|MISSING
EVIDENCE_RUNTIME: OK|MISSING
EVIDENCE_DOCS: OK|MISSING
```

Mandatory completion checks:

- changelog or equivalent project history update when the repo expects one,
- documentation updated where relevant,
- automated validations passed,
- runtime validation performed when the issue changes executable behavior,
- `Fixes #<issue-number>` present,
- labels applied on issue and PR.

## Command reference

```sh
# Shared preflight
source .agents/skills/workflow-github/scripts/github_context.sh
github_preflight GITHUB_TOKEN_FIX_ISSUE

# Inspect the issue
gh issue view 123 --repo "$GITHUB_REPO" --comments

# Comment on the issue
cat > /tmp/comment.md <<'BODY'
[COMMENTAIRE AUTOMATIQUE AGENT] MISE A JOUR DEVELOPPEMENT.

<contenu>
BODY
gh issue comment 123 --repo "$GITHUB_REPO" --body-file /tmp/comment.md

# Create labels if missing
gh label create bug --color d73a4a --description "Something is broken" --repo "$GITHUB_REPO" || true
gh label create enhancement --color a2eeef --description "New feature or request" --repo "$GITHUB_REPO" || true
gh label create refactor --color cfd3d7 --description "Code change without functional change" --repo "$GITHUB_REPO" || true
gh label create tech-debt --color f9d0c4 --description "Maintainability or cleanup work" --repo "$GITHUB_REPO" || true

# Apply labels
gh issue edit 123 --repo "$GITHUB_REPO" --add-label bug
gh pr edit 456 --repo "$GITHUB_REPO" --add-label bug

# Open a PR that closes the issue
gh pr create --repo "$GITHUB_REPO" --title "Implement: short summary" --body-file /tmp/pr_body.md
```
