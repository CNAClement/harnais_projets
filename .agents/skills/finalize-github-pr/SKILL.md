---
name: finalize-github-pr
description: Merge une PR GitHub approuvee par le gatekeeper, puis nettoie le depot local et distant. Utilise ce skill seulement apres un verdict GATEKEEPER_STATUS APPROVED confirme.
---

# finalize-github-pr

Termine le workflow apres validation gatekeeper : merger la PR, resynchroniser main, nettoyer les branches, verifier que l'issue est fermee.

## Preflight GitHub commun

```sh
source .agents/skills/workflow-github/scripts/github_context.sh
github_preflight GITHUB_TOKEN_FIX_ISSUE
```

Le depot cible est disponible dans `$GITHUB_REPO`.

## Etapes

### 1. Verifier l'approbation

```sh
gh pr view <PR_NUMBER> --repo "$GITHUB_REPO" --json labels,state
```

Confirmer :

- `state = OPEN`,
- label `gatekeeper:approved` present,
- label `gatekeeper:blocked` absent.

### 2. Merger la PR

```sh
gh pr merge <PR_NUMBER> --repo "$GITHUB_REPO" --squash --delete-branch
```

### 3. Resynchroniser le local

```sh
git checkout main
git pull --ff-only origin main
git branch --show-current
```

### 4. Supprimer la branche locale

```sh
BRANCH=<nom_branche>
git branch -d "$BRANCH" 2>/dev/null || git branch -D "$BRANCH"
```

### 5. Verifier l'etat final

```sh
git branch -vv
git log --oneline -3
gh issue view <ISSUE_NUMBER> --repo "$GITHUB_REPO" --json state
```

L'issue doit etre fermee automatiquement via `Fixes #<issue>`.

## Sortie attendue

- PR mergee et branche distante supprimee,
- `main` local a jour,
- branche locale supprimee,
- issue fermee.
