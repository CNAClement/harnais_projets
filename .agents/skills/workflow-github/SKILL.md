---
name: workflow-github
description: Routeur pour les demandes GitHub multi-etapes ou "run until merged". Oriente vers les agents specialises et les skills mono-etape selon l'intention utilisateur. Ne bypass pas les agents quand ils existent.
---

# workflow-github

Meta-skill d'orchestration pour le workflow GitHub. Choisit le bon agent specialise ou skill mono-etape selon l'intention utilisateur, sans court-circuiter les roles quand ils existent.

## Quand l'utiliser

Utiliser ce skill quand la demande :

- couvre plusieurs etapes GitHub,
- demande un flux de bout en bout,
- demande explicitement une boucle developpeur/gatekeeper,
- ou reste trop large pour choisir directement entre creation d'issue, implementation, review gatekeeper et finalisation.

Ne pas l'utiliser comme point d'entree par defaut pour une demande mono-etape deja claire.

## Regles de routage

### 1. Creation d'issue uniquement

Utiliser directement `create-issue-github`.

### 2. Implementation d'une issue ou reprise d'une PR bloquee

Lancer l'agent `github-developer`.

Cet agent s'appuie sur `implement-issue-github`.

### 3. Review PR generique

Si la demande porte surtout sur la lecture des threads, les reponses inline, la resolution de commentaires ou un usage terminal de `gh-pr-review`, utiliser directement `review-pr-github`.

### 4. Gatekeeper strict avant merge

Lancer l'agent `github-gatekeeper`.

Cet agent s'appuie sur `gatekeeper-pr-github` et produit toujours un verdict machine-readable.

### 5. Workflow complet ou "run until merged"

Lancer l'agent `github-workflow-orchestrator`.

Cet agent coordonne :

1. `create-issue-github` si une issue doit etre creee,
2. `github-developer` pour l'implementation,
3. `github-gatekeeper` pour la gatekeeper review,
4. `finalize-github-pr` une fois le verdict `APPROVED` obtenu.

## Regles d'orchestration

- Router vers les roles specialises au lieu de refaire soi-meme leurs etapes.
- Ne pas utiliser `review-pr-github` comme merge gate strict.
- Ne jamais merger sans verdict `GATEKEEPER_STATUS: APPROVED`.
- Garder [github-context.md](/home/naarc/harnais_projets/.agents/skills/workflow-github/references/github-context.md) et [github_context.sh](/home/naarc/harnais_projets/.agents/skills/workflow-github/scripts/github_context.sh) comme ressources partagees pour les skills GitHub.

## Resume

| Intention utilisateur | Point d'entree recommande |
|---|---|
| Creer une issue | `create-issue-github` |
| Implementer une issue | agent `github-developer` |
| Lire ou gerer une review PR | `review-pr-github` |
| Rendre un verdict gatekeeper | agent `github-gatekeeper` |
| Boucler jusqu'au merge | agent `github-workflow-orchestrator` |
