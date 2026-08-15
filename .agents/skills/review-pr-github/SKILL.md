---
name: review-pr-github
description: Inspecte, repond et gere les threads de review d'une PR GitHub depuis le terminal. Pour l'acces structure aux commentaires et les thread replies; ne remplace pas gatekeeper-pr-github pour la merge gate stricte.
---

# review-pr-github

Accede aux threads de review et aux commentaires inline d'une PR GitHub avec sortie structuree pour les agents.

## Shared GitHub preflight

Before using `gh pr-review ...` or any `gh pr ...` command, run the shared helper [github_context.sh](/home/naarc/harnais_projets/.agents/skills/workflow-github/scripts/github_context.sh):

```sh
source .agents/skills/workflow-github/scripts/github_context.sh
github_preflight GITHUB_TOKEN_PR_REVIEW
```

This authenticates `gh` and resolves the target repository into `$GITHUB_REPO`.

- Do not require a separate manual login step outside the skill flow.
- If the repository cannot be inferred, ask only for `GITHUB_REPO=owner/repo`.

## Scope

Use this skill when you need to:

- inspect review threads and inline comments,
- reply to comments programmatically,
- resolve or unresolve threads,
- create or submit a review from the terminal,
- retrieve structured PR review context for another agent.

This skill is not the strict merge gate. If the goal is to approve or block a PR with mandatory evidence checks and a machine-readable verdict, use `gatekeeper-pr-github`.

## Installation

Ensure the extension is installed:

```sh
gh extension install agynio/gh-pr-review
```

## Core commands

### 1. View all reviews and threads

```sh
gh pr-review review view -R "$GITHUB_REPO" --pr <number>
```

Useful filters:

- `--unresolved`
- `--reviewer <login>`
- `--states <APPROVED|CHANGES_REQUESTED|COMMENTED|DISMISSED>`
- `--tail <n>`
- `--not_outdated`

### 2. Reply to a review thread

```sh
gh pr-review comments reply <pr-number> -R "$GITHUB_REPO" \
  --thread-id <PRRT_...> \
  --body "Your reply message"
```

### 3. List review threads

```sh
gh pr-review threads list -R "$GITHUB_REPO" <pr-number> --unresolved --mine
```

### 4. Resolve or unresolve threads

```sh
gh pr-review threads resolve -R "$GITHUB_REPO" <pr-number> --thread-id <PRRT_...>
```

### 5. Start and submit a review

```sh
gh pr-review review --start -R "$GITHUB_REPO" <pr-number>
```

```sh
gh pr-review review --add-comment \
  --review-id <PRR_...> \
  --path <file-path> \
  --line <line-number> \
  --body "Your comment" \
  -R "$GITHUB_REPO" <pr-number>
```

```sh
gh pr-review review --submit \
  --review-id <PRR_...> \
  --event <APPROVE|REQUEST_CHANGES|COMMENT> \
  --body "Overall review summary" \
  -R "$GITHUB_REPO" <pr-number>
```

## Output expectations

Commands should return structured data with stable field names that another agent can reuse without manual scraping.
