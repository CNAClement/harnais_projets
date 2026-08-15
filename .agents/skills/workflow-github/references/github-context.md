# Shared GitHub context for skills

Use [github_context.sh](/home/naarc/harnais_projets/.agents/skills/workflow-github/scripts/github_context.sh) whenever a skill needs both GitHub authentication and an explicit target repository.

## Supported inputs

Repository resolution order:

1. `GITHUB_REPO=owner/repo`
2. `GH_REPO`
3. the Git remote `origin`
4. the active `gh` context

This keeps the workflow portable across repositories:

- on a cloned repository, the remote is usually enough,
- on a detached workspace or orchestration session, `GITHUB_REPO` is the explicit override.

## Standard usage

```sh
source .agents/skills/workflow-github/scripts/github_context.sh
github_preflight GITHUB_TOKEN_FIX_ISSUE
```

After that:

- `gh` is authenticated,
- `$GITHUB_REPO` contains the resolved `owner/repo`,
- GitHub commands should use `--repo "$GITHUB_REPO"`.

## Token policy

Each skill keeps its dedicated token name:

- `GITHUB_TOKEN_ISSUE_CREATE`
- `GITHUB_TOKEN_FIX_ISSUE`
- `GITHUB_TOKEN_PR_REVIEW`

The helper loads `env_perso.env` from the project root when present.

It first checks the dedicated generic variable, then the repo-scoped variable derived from the current repository name:

- `<REPO_KEY>_GITHUB_ISSUE_CREATE`
- `<REPO_KEY>_GITHUB_FIX_ISSUE`
- `<REPO_KEY>_GITHUB_AGENTIC_BH`

Example on `CNAClement/harnais_projets`:

- `HARNAIS_PROJETS_GITHUB_ISSUE_CREATE`
- `HARNAIS_PROJETS_GITHUB_FIX_ISSUE`
- `HARNAIS_PROJETS_GITHUB_AGENTIC_BH`

If neither is defined but `GITHUB_TOKEN` is already exported, it reuses that value.
