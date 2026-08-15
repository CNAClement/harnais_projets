---
name: create-issue-github
description: Cree une issue GitHub actionnable a partir d'un prompt naturel. Transforme une demande, un bug report, ou une idee en ticket structuré exploitable par un agent, avec titre clair et body Markdown coherent.
---

# Create Issue on GitHub

Transforme une demande utilisateur en issue GitHub exploitable et actionnable.

## Périmètre

- Créer l'issue uniquement.
- Ne pas implémenter le correctif.
- Ne pas lancer de tests.
- Ne pas clôturer l'issue.

## Préflight GitHub commun

Utiliser le helper partagé [github_context.sh](/home/naarc/harnais_projets/.agents/skills/workflow-github/scripts/github_context.sh) pour l'authentification et la résolution du dépôt cible.

```sh
source .agents/skills/workflow-github/scripts/github_context.sh
github_preflight GITHUB_TOKEN_ISSUE_CREATE
```

Le dépôt est résolu dans cet ordre :

1. `GITHUB_REPO=owner/repo`
2. `GH_REPO`
3. le remote Git `origin`
4. le contexte `gh`

Si aucun dépôt ne peut être inféré, demander une seule précision bloquante à l'utilisateur : la valeur `owner/repo`.

## Entrée attendue

Le prompt utilisateur peut être bref. Infère raisonnablement tant que l'issue reste actionnable.

Ne pose une question que si une ambiguïté empêche :

- d'identifier le problème ou l'objectif,
- de formuler des critères d'acceptation,
- ou de choisir le bon type d'issue.

## Titre de l'issue

Créer un titre court, concret et orienté action.

Formats recommandés :

- `[Bug] ...`
- `[Feature] ...`
- `[Refactor] ...`
- `[Task] ...`

## Body Markdown attendu

Utiliser ce gabarit par défaut :

```markdown
# Contexte

<besoin, symptôme ou problème observé>

# Objectif

<résultat attendu>

# Critères d'acceptation

- [ ] critère 1
- [ ] critère 2

# Contraintes techniques

<fichiers, limites, risques, dépendances>

# Tests attendus

<vérifications minimales attendues>
```

Tu peux alléger une section si elle n'apporte rien, mais garde une structure Markdown nette et facilement réutilisable.

## Création de l'issue

```sh
source .agents/skills/workflow-github/scripts/github_context.sh
github_preflight GITHUB_TOKEN_ISSUE_CREATE

cat > /tmp/gh_issue_body.md <<'BODY'
<body markdown structuré>
BODY

gh issue create \
  --repo "$GITHUB_REPO" \
  --title "<titre>" \
  --body-file /tmp/gh_issue_body.md
```

Si un label utile existe déjà, tu peux l'ajouter. Ne crée pas de taxonomie complexe pour cette seule étape.

## Sortie attendue

Retourner :

- l'URL de l'issue,
- son numéro,
- et le titre retenu.
