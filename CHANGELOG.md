# Changelog

## 2026-08-15

Le helper partage `github_context.sh` accepte maintenant un nom repo-scoped coherent pour le token de review (`<REPO_KEY>_GITHUB_PR_REVIEW`) tout en conservant l'alias legacy `<REPO_KEY>_GITHUB_AGENTIC_BH`. Cette petite refactorisation clarifie `env_perso.env`, garde la compatibilite avec les tokens deja crees, et aligne la documentation du workflow GitHub sur le comportement reel du helper.
