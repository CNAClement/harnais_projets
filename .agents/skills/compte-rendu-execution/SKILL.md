---
name: compte-rendu-execution
description: Génère un compte rendu horodaté des étapes effectuées par l'agent suite à un prompt : liste des actions, modèles utilisés, et tokens consommés. Utilise ce skill systématiquement à la fin de chaque session de travail agent, ou dès que l'utilisateur demande un résumé d'exécution, un bilan de session, un compte rendu, ou veut savoir ce que l'agent a fait et combien ça a coûté en tokens.
---

# Compte Rendu d'Exécution Agent

Ce skill produit un fichier de trace horodaté résumant ce que l'agent a accompli, quels modèles ont été sollicités, et combien de tokens ont été consommés au cours de la session.

## Quand l'invoquer

- À la fin de chaque session de travail significative (fix, refactor, création de feature, etc.)
- Quand l'utilisateur demande un "compte rendu", "résumé d'exécution", "bilan de session", ou "ce que tu as fait"
- Quand les instructions du dépôt l'exigent (voir `.github/copilot-instructions.md`)

## Répertoire cible

Les comptes rendus sont écrits dans :

```
compte_rendu_executions_agents/
```

Ce répertoire est à la racine du dépôt. Il contient un `.keep` mais son contenu n'est pas commité (`.gitignore`).

## Format du nom de fichier

```
cr_<YYYYMMDD>_<HHMMSS>_<slug-du-prompt>.md
```

Exemple : `cr_20260815_143022_fix-issue-42-auth.md`

Le slug est dérivé des 4-5 premiers mots significatifs du prompt initial, en minuscules, séparés par des tirets.

## Structure du fichier de compte rendu

Utilise exactement ce template :

```markdown
# Compte Rendu d'Exécution Agent

**Date** : <YYYY-MM-DD HH:MM:SS>
**Prompt initial** : <prompt complet ou résumé fidèle si très long>

---

## Étapes effectuées

1. **<Titre court de l'étape>**
   - Action : <ce qui a été fait>
   - Outils utilisés : <liste des outils/commandes>
   - Résultat : <succès / échec / output clé>

2. **<Titre court de l'étape>**
   - ...

_(Répéter pour chaque étape significative)_

---

## Modèles utilisés

| Modèle | Rôle / Contexte |
|--------|-----------------|
| <nom-modèle> | <ex: agent principal, sous-agent grader, etc.> |

---

## Consommation de tokens

| Modèle | Tokens entrée | Tokens sortie | Total |
|--------|--------------|---------------|-------|
| <nom> | <N> | <N> | <N> |
| **Total** | | | **<N>** |

> Si les données de tokens ne sont pas disponibles directement, indiquer "non disponible" et expliquer brièvement pourquoi (ex: session CLI sans accès aux métriques).

---

## Résultat global

**Statut** : ✅ Succès / ⚠️ Partiel / ❌ Échec

**Résumé** : <2-3 phrases décrivant ce qui a été accompli et l'état final>

**Artefacts produits** :
- <fichier ou ressource créée/modifiée, avec chemin>

---

_Généré automatiquement par le skill `compte-rendu-execution`_
```

## Comment récupérer les informations

### Étapes
Reconstitue les étapes à partir de la conversation en cours : chaque appel d'outil, commande bash, lecture de fichier, ou décision structurante est une étape candidate. Regroupe les micro-actions en étapes logiques (ex: "Lecture du contexte", "Implémentation du fix", "Validation", "Commit et PR").

### Modèles
- Note le modèle de la session principale (disponible dans le contexte système).
- Si des sous-agents ont été lancés (via `task`), indique leur rôle et modèle si précisé.

### Tokens
- Si l'environnement expose les métriques de tokens (notifications de tâches, métadonnées de session), utilise ces valeurs.
- Sinon, indique "non disponible" — ne pas inventer de chiffres.

## Écriture du fichier

```bash
# Construire le nom de fichier
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
SLUG="<slug-derive-du-prompt>"
FILEPATH="compte_rendu_executions_agents/cr_${TIMESTAMP}_${SLUG}.md"

# Écrire le contenu
cat > "$FILEPATH" << 'EOF'
<contenu du compte rendu>
EOF

echo "Compte rendu écrit : $FILEPATH"
```

Confirme à l'utilisateur le chemin du fichier créé.
