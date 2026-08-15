# harnais_projets

Socle de fichiers de personnalisation pour travailler plus efficacement avec GitHub Copilot et des agents, puis recopier la meme base d'un projet a l'autre.

## Structure recommandee

```text
.github/
  copilot-instructions.md
  instructions/
    documentation.instructions.md
    python-refactor.instructions.md
  agents/
    refactor-simplification.agent.md
    github-developer.agent.md
    github-gatekeeper.agent.md
    github-workflow-orchestrator.agent.md

.agents/
  skills/
    workflow-github/
      SKILL.md
      references/
      scripts/
    gatekeeper-pr-github/
      SKILL.md
    github-pr-gatekeeper-loop/
      SKILL.md
    implement-issue-github/
      SKILL.md
    finalize-github-pr/
      SKILL.md
    <skill-name>/
      SKILL.md
```

## Role de chaque emplacement

### `.github/copilot-instructions.md`

Socle global du depot.
Ce fichier contient les regles toujours vraies pour le projet: contexte technique, contraintes de reproductibilite, principes KISS, verification minimale, et attentes de documentation.

### `.github/instructions/*.instructions.md`

Instructions ciblees, appliquees par type de fichier ou par zone de travail.

Dans ce depot:
- [documentation.instructions.md](/home/naarc/harnais_projets/.github/instructions/documentation.instructions.md) cadre la mise a jour de la documentation Markdown.
- [python-refactor.instructions.md](/home/naarc/harnais_projets/.github/instructions/python-refactor.instructions.md) ajoute des garde-fous pour les refactors Python.

### `.github/agents/*.agent.md`

Profils d'agents personnalises.

Dans ce depot:
- [refactor-simplification.agent.md](/home/naarc/harnais_projets/.github/agents/refactor-simplification.agent.md) sert de persona de refactorisation globale.
- [github-developer.agent.md](/home/naarc/harnais_projets/.github/agents/github-developer.agent.md) porte le role developpeur pour les issues et PR bloquees.
- [github-gatekeeper.agent.md](/home/naarc/harnais_projets/.github/agents/github-gatekeeper.agent.md) porte la review gatekeeper stricte avant merge.
- [github-workflow-orchestrator.agent.md](/home/naarc/harnais_projets/.github/agents/github-workflow-orchestrator.agent.md) pilote les workflows GitHub de bout en bout et les boucles "run until merged".

### `.agents/skills/*/SKILL.md`

Skills portables et reutilisables d'un projet a l'autre.

Le depot choisit volontairement [`.agents/skills/`](/home/naarc/harnais_projets/.agents/skills) comme emplacement canonique pour les skills du projet afin de garder une convention unique, portable, et compatible avec VS Code/Copilot.

Les skills peuvent embarquer des ressources dediees quand cela evite de dupliquer les memes instructions partout. Par exemple, [workflow-github](/home/naarc/harnais_projets/.agents/skills/workflow-github) sert maintenant de meta-skill de routage pour les demandes GitHub multi-etapes et porte aussi le helper partage d'authentification et de resolution du depot cible, reutilise par les autres skills GitHub.

## Architecture GitHub retenue

Le depot separe maintenant clairement :

- les **skills proceduraux** de [`.agents/skills/`](/home/naarc/harnais_projets/.agents/skills), qui decrivent comment faire une etape precise ;
- les **agents de role** de [`.github/agents/`](/home/naarc/harnais_projets/.github/agents), qui incarnent qui fait le travail ;
- et le meta-skill [workflow-github](/home/naarc/harnais_projets/.agents/skills/workflow-github/SKILL.md), qui route les demandes multi-etapes vers ces roles au lieu de laisser un agent generaliste alterner entre developpement et gatekeeping.

Pour le workflow GitHub :

- [create-issue-github](/home/naarc/harnais_projets/.agents/skills/create-issue-github/SKILL.md) cree une issue actionnable.
- [implement-issue-github](/home/naarc/harnais_projets/.agents/skills/implement-issue-github/SKILL.md) est la procedure de developpement utilisee par [github-developer.agent.md](/home/naarc/harnais_projets/.github/agents/github-developer.agent.md).
- [review-pr-github](/home/naarc/harnais_projets/.agents/skills/review-pr-github/SKILL.md) reste la boite a outils de review PR generique et de gestion des threads.
- [gatekeeper-pr-github](/home/naarc/harnais_projets/.agents/skills/gatekeeper-pr-github/SKILL.md) porte la merge gate stricte et le verdict `GATEKEEPER_*`.
- [github-pr-gatekeeper-loop](/home/naarc/harnais_projets/.agents/skills/github-pr-gatekeeper-loop/SKILL.md) automatise la boucle developpeur <-> gatekeeper.
- [finalize-github-pr](/home/naarc/harnais_projets/.agents/skills/finalize-github-pr/SKILL.md) merge puis nettoie une PR approuvee.

### Guide de decision : quel point d'entree choisir ?

| Intention utilisateur | Point d'entree | Type | Pourquoi |
|---|---|---|---|
| Creer une issue uniquement | [create-issue-github](/home/naarc/harnais_projets/.agents/skills/create-issue-github/SKILL.md) | Skill | Transformation directe d'une demande en issue structuree |
| Implementer une issue existante | agent [github-developer](/home/naarc/harnais_projets/.github/agents/github-developer.agent.md) | Agent | Specialise dans le developpement avec evidence de validation |
| Corriger une PR bloquee par le gatekeeper | agent [github-developer](/home/naarc/harnais_projets/.github/agents/github-developer.agent.md) | Agent | Reprend le travail depuis les criteres GATEKEEPER_MISSING |
| Lire les commentaires de review d'une PR | [review-pr-github](/home/naarc/harnais_projets/.agents/skills/review-pr-github/SKILL.md) | Skill | Acces structure aux threads sans verdict de merge |
| Faire la merge gate avant de merger | agent [github-gatekeeper](/home/naarc/harnais_projets/.github/agents/github-gatekeeper.agent.md) | Agent | Specialise dans le verdict strict avec bloc machine-readable |
| Workflow complet : cree + implemente + boucle dev/gate jusqu'au merge | agent [github-workflow-orchestrator](/home/naarc/harnais_projets/.github/agents/github-workflow-orchestrator.agent.md) | Agent | Orchestre toutes les etapes jusqu'au "run until merged" |

### Arbre decisionnel rapide

```
Demande utilisateur sur GitHub
│
├─ "Creer une issue" 
│  └─> create-issue-github (skill)
│
├─ "Implementer une issue / corriger une PR bloquee"
│  └─> github-developer (agent)
│      ├─> utilise implement-issue-github (skill)
│      └─> accepte GATEKEEPER_MISSING en resume
│
├─ "Lire les commentaires de review"
│  └─> review-pr-github (skill, pas de verdict)
│
├─ "Faire la gatekeeper review / rendre un verdict"
│  └─> github-gatekeeper (agent)
│      └─> utilise gatekeeper-pr-github (skill)
│          └─> emet GATEKEEPER_STATUS + labels
│
└─ "Run until merged / boucle automatique dev <-> gate"
   └─> github-workflow-orchestrator (agent)
       ├─> cree issue si necessaire (create-issue-github)
       ├─> lance github-developer
       ├─> lance github-gatekeeper
       ├─> boucle tant que verdict != APPROVED
       └─> lance finalize-github-pr
```

## Regles de rangement retenues ici

- Un seul point d'entree global: [`.github/copilot-instructions.md`](/home/naarc/harnais_projets/.github/copilot-instructions.md)
- Les instructions ciblees doivent toujours finir par `.instructions.md`
- Les agents personnalises restent dans [`.github/agents/`](/home/naarc/harnais_projets/.github/agents)
- Les skills du projet vivent dans [`.agents/skills/`](/home/naarc/harnais_projets/.agents/skills), pas dans `.github/skills`

## Pourquoi cette convention

- elle suit les emplacements reconnus par VS Code et GitHub Copilot
- elle limite les doublons entre plusieurs repertoires de skills
- elle rend le depot plus facile a cloner tel quel dans un autre projet
- elle separe clairement:
  - les regles globales
  - les regles ciblees
  - les personas d'agents
  - les skills reutilisables

## Note sur cette premiere restructuration

Cette passe a:
- ajoute [`.github/copilot-instructions.md`](/home/naarc/harnais_projets/.github/copilot-instructions.md)
- remplace les anciens fichiers libres de [`.github/instructions/`](/home/naarc/harnais_projets/.github/instructions) par de vrais `*.instructions.md`
- normalise les skills du projet dans [`.agents/skills/`](/home/naarc/harnais_projets/.agents/skills)
