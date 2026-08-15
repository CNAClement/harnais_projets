---
name: create-github-token
description: Cree ou regenere un token GitHub (PAT fine-grained ou classic) pour un repo cible avec les droits minimaux attendus, puis met a jour env_perso.env pour les autres agents. Utilise ce skill des qu'un utilisateur demande "cree un PAT/token pour tel repo", "prepare les droits GitHub pour issue/dev/validation", ou veut automatiser au maximum la creation de tokens avec seulement une confirmation de sa part.
---

# Create GitHub Token

Automatise la creation de tokens GitHub au maximum, avec une seule intervention utilisateur attendue: connexion/2FA et copie finale de la valeur du token.

## Intentions couvertes

- Creer un PAT fine-grained limite a un repo.
- Creer un token classic quand une topologie "agentique" ou un outillage legacy le demande.
- Standardiser les noms et stocker les secrets dans `env_perso.env` pour reutilisation par les autres agents.

## Regles importantes

1. `gh` ne permet pas de creer un PAT utilisateur fine-grained de bout en bout. Utiliser le navigateur GitHub pour la creation.
2. Ne jamais afficher ni journaliser la valeur complete d'un token.
3. Toujours limiter l'acces au repo cible sauf demande explicite contraire.
4. Si un token existe deja avec le meme role, preferer regeneration ou remplacement propre plutot que multiplication de variantes.
5. Le chat peut masquer automatiquement les secrets envoyes par l'utilisateur. Ne pas compter sur un simple copier/coller dans la conversation pour recuperer un token.
6. Les outils navigateur peuvent voir qu'un token existe, mais GitHub masque souvent sa valeur reelle (`******`) aux automatismes. Prevoir un circuit local de transit.

## Entree attendue

- `owner/repo` cible (ex: `CNAClement/harnais_projets`)
- typologie demandee (`issue-create`, `fix-issue`, `agentic-bh`)
- duree d'expiration (par defaut `90` jours)

Si un de ces points manque, demander uniquement la precision bloquante.

Avant de creer le token `fix-issue`, inspecter le repo cible:

- si le repo contient des fichiers sous `.github/workflows/` qui devront etre pousses avec ce token, basculer immediatement sur la variante `fix-issue + workflows`.
- ne pas decouvrir ce besoin plus tard apres un push rate si le depot local est deja disponible pour inspection.

## Nommage standardise

Deriver `REPO_KEY` en majuscules avec underscores a partir du repo (`harnais_projets` -> `HARNAIS_PROJETS`).

Variables d'environnement standard:

- `${REPO_KEY}_GITHUB_ISSUE_CREATE`
- `${REPO_KEY}_GITHUB_FIX_ISSUE`
- `${REPO_KEY}_GITHUB_PR_REVIEW`

Alias legacy encore acceptes pour la review:

- `${REPO_KEY}_GITHUB_AGENTIC_BH`

Exemple:

- `HARNAIS_PROJETS_GITHUB_FIX_ISSUE`

Nom lisible du token GitHub (UI):

- `<repo>-issue-create`
- `<repo>-fix-issue`
- `<repo>-agentic-bh`

## Topologies officielles (a garder coherentes)

### 1) PAT fine-grained `issue-create`

But: creation d'issues uniquement.

Permissions repo:

- `Issues: Read and write`
- `Metadata: Read-only` (impose par GitHub)

Acces repository:

- `Only select repositories` + repo cible

Compatibilite historique attendue:

- equivalent a `GITHUB_TOKEN_ISSUE_CREATE`
- vue GitHub: "Read and Write access to issues"

### 2) PAT fine-grained `fix-issue`

But: implementer un fix, pousser du code, ouvrir/mettre a jour une PR.

Permissions repo:

- `Contents (code): Read and write`
- `Pull requests: Read and write`
- `Issues: Read and write`
- `Metadata: Read-only` (impose)

Acces repository:

- `Only select repositories` + repo cible

Compatibilite historique attendue:

- equivalent a `GITHUB_TOKEN_FIX_ISSUE`
- vue GitHub: "Read and Write access to code, issues, and pull requests"

Extension conditionnelle:

- si le repo contient deja des fichiers sous `.github/workflows/` et que le token doit pousser ces fichiers (cas typique: premier push d'initialisation vers un repo distant vide), ajouter aussi:
  - `Workflows: Read and write`

Pourquoi:

- GitHub refuse la creation ou mise a jour de fichiers workflow par git avec un PAT qui n'a pas `workflows:write`, meme si `contents:write` est deja present.
- cette extension n'est pas necessaire pour tous les repos; n'ajouter `workflows:write` que quand le flux reel en a besoin.
- pour `harnais_projets`, cette extension est necessaire des le premier push car le repo versionne deja `.github/workflows/gatekeeper-evidence.yml`.

### 3) Token classic `agentic-bh`

But: execution agentique sur compte dedie de validation/separation des responsabilites.

Scope classique:

- `repo` (ce scope inclut les sous-scopes prives utiles)

Pourquoi un classic ici:

- un PAT (fine-grained) reste attache a l'identite du compte emetteur et a un set de permissions plus segmente.
- certaines chaines d'outils/API "agentiques" restent plus robustes avec `repo` classique.
- pour une vraie separation des responsabilites, la validation doit idealement venir d'un autre compte GitHub (machine user/bot), avec son propre token.

## Procedure operationnelle

### A. Preparer l'URL de creation

PAT fine-grained (`issue-create`):

`https://github.com/settings/personal-access-tokens/new?name=<repo>-issue-create&description=Token%20fine-grained%20pour%20creer%20des%20issues%20sur%20<owner>%2F<repo>&target_name=<owner>&expires_in=<days>&issues=write`

PAT fine-grained (`fix-issue`):

`https://github.com/settings/personal-access-tokens/new?name=<repo>-fix-issue&description=Token%20fine-grained%20pour%20developper%20et%20ouvrir%20des%20PR%20sur%20<owner>%2F<repo>&target_name=<owner>&expires_in=<days>&contents=write&pull_requests=write&issues=write`

PAT fine-grained (`fix-issue` + workflows):

`https://github.com/settings/personal-access-tokens/new?name=<repo>-fix-issue&description=Token%20fine-grained%20pour%20developper%20et%20ouvrir%20des%20PR%20sur%20<owner>%2F<repo>&target_name=<owner>&expires_in=<days>&contents=write&pull_requests=write&issues=write&workflows=write`

Token classic (`agentic-bh`):

`https://github.com/settings/tokens/new?description=<repo>-agentic-bh&expires_in=<days>&scopes=repo`

### A bis. Contraintes reelles rencontrees

En pratique:

- GitHub affiche la valeur du token une seule fois.
- Le composant GitHub `clipboard-copy` permet souvent de copier le token dans le presse-papiers du navigateur, mais la lecture automatisee retourne parfois `******`.
- Le chat masque les secrets colles par l'utilisateur avant qu'ils n'arrivent au modele.
- Une page GitHub ne peut pas poster librement vers `localhost` a cause de la CSP GitHub.
- Le clic automatise sur `Generate token` peut etre instable selon l'etat du navigateur integre: parfois il passe, parfois non.

Conclusion:

- il faut minimiser l'intervention utilisateur,
- mais il faut accepter un petit pont local explicite pour faire sortir le token du navigateur vers l'environnement de travail.
- et prevoir un fallback ou l'utilisateur ne fait qu'un clic `Generate token` puis `Copy token` quand GitHub bloque ce dernier clic automatise.
- il ne faut jamais promettre un `Generate token` 100% autonome tant que le navigateur integre reste instable sur ce bouton.

### B. Automatiser dans le navigateur

1. Ouvrir l'URL.
2. Laisser l'utilisateur faire connexion/2FA si necessaire.
3. Verifier les champs pre-remplis.
4. Pour PAT fine-grained:
   - basculer sur `Only select repositories`,
   - selectionner uniquement le repo cible,
   - verifier les permissions attendues.
5. Generer le token.
6. Si GitHub affiche un ecran de confirmation supplementaire, confirmer une seconde fois `Generate token`.
7. Si le clic automatise sur `Generate token` echoue apres plusieurs tentatives raisonnables, demander a l'utilisateur de faire uniquement:
   - `Generate token`
   - `Copy token`
   puis reprendre automatiquement la suite via le pont local.

Important:

- le fallback humain attendu doit rester minimal et explicite.
- pour un token donne, ne demander ni navigation complexe, ni edition manuelle de fichier, ni copier/coller du secret dans le chat.

### C. Recuperer la valeur du token avec intervention minimale

Essayer dans cet ordre:

1. **Recuperation directe automatisable**
   - cliquer sur `Copy token`,
   - tester si la valeur reelle est accessible sans masquage.

2. **Pont local via page de transit** si la valeur reste masquee
   - ouvrir une page locale simple avec une zone de texte,
   - demander a l'utilisateur d'y coller le token,
   - lire cette valeur depuis la page locale,
   - l'envoyer vers un serveur local `python3` avec CORS actif,
   - mettre ensuite `env_perso.env` a jour depuis le fichier local recu.

Exemple de serveur local:

```sh
python3 - <<'PY'
from http.server import BaseHTTPRequestHandler, HTTPServer
from pathlib import Path

OUT = Path('/tmp/github_token_capture.txt')

class Handler(BaseHTTPRequestHandler):
    def _headers(self, code=200):
        self.send_response(code)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', '*')
        self.end_headers()
    def do_OPTIONS(self):
        self._headers(204)
    def do_POST(self):
        length = int(self.headers.get('Content-Length', '0'))
        OUT.write_bytes(self.rfile.read(length))
        self._headers(200)
        self.wfile.write(b'ok')
    def do_GET(self):
        self._headers(200)
        self.wfile.write(b'ready')
    def log_message(self, format, *args):
        return

HTTPServer(('127.0.0.1', 8766), Handler).serve_forever()
PY
```

Puis:

- faire coller le token par l'utilisateur dans la page locale,
- lire la valeur dans cette page,
- poster vers `http://127.0.0.1:8766`,
- relire `/tmp/github_token_capture.txt` sans jamais re-afficher sa valeur.

### D. Mise a jour de `env_perso.env` par l'agent

L'utilisateur ne doit pas modifier `env_perso.env` lui-meme si cela peut etre evite.

Des que la valeur est disponible dans un canal local exploitable, l'agent doit ecrire lui-meme le fichier.

Le helper GitHub du depot sait maintenant reutiliser:

- les noms generiques historiques,
- ou les variables repo-scoped derivees automatiquement du repo courant.

Donc remplir a la fois:

- les variables repo-scoped preferees,
- l'alias legacy repo-scoped de review pour compatibilite,
- les alias generiques encore attendus par certains skills.

## Mise a jour de `env_perso.env`

Ajouter/mettre a jour les valeurs standardisees dans `env_perso.env` a la racine du projet.

Exemple pour `harnais_projets`:

```dotenv
HARNAIS_PROJETS_GITHUB_ISSUE_CREATE=<token_pat_issue_create>
HARNAIS_PROJETS_GITHUB_FIX_ISSUE=<token_pat_fix_issue>
HARNAIS_PROJETS_GITHUB_PR_REVIEW=<token_classic_agentic_bh>
HARNAIS_PROJETS_GITHUB_AGENTIC_BH=<token_classic_agentic_bh>
```

Ajouter aussi des alias de compatibilite pour les skills existants:

```dotenv
GITHUB_TOKEN_ISSUE_CREATE=<token_pat_issue_create>
GITHUB_TOKEN_FIX_ISSUE=<token_pat_fix_issue>
GITHUB_TOKEN_PR_REVIEW=<token_classic_agentic_bh>
```

Si l'utilisateur veut un seul token par defaut pour des commandes generiques `gh`:

```dotenv
GITHUB_TOKEN=<token_pat_fix_issue>
```

Si possible, remplir aussi les variables repo-scoped suivantes:

```dotenv
HARNAIS_PROJETS_GITHUB_ISSUE_CREATE=<token_pat_issue_create>
HARNAIS_PROJETS_GITHUB_FIX_ISSUE=<token_pat_fix_issue>
HARNAIS_PROJETS_GITHUB_PR_REVIEW=<token_classic_agentic_bh>
HARNAIS_PROJETS_GITHUB_AGENTIC_BH=<token_classic_agentic_bh>
```

## Commandes utiles pour ecrire `env_perso.env` sans afficher le secret

Exemple:

```sh
export TOKEN=$(tr -d '\r\n' < /tmp/github_token_capture.txt)
python3 - <<'PY'
from pathlib import Path
import os

env_path = Path('env_perso.env')
token = os.environ['TOKEN']
replacements = {
    'HARNAIS_PROJETS_GITHUB_ISSUE_CREATE': token,
    'GITHUB_TOKEN_ISSUE_CREATE': token,
}

lines = env_path.read_text().splitlines()
out = []
seen = set()

for line in lines:
    if '=' in line:
        key, _ = line.split('=', 1)
        if key in replacements:
            out.append(f'{key}={replacements[key]}')
            seen.add(key)
            continue
    out.append(line)

for key, value in replacements.items():
    if key not in seen:
        out.append(f'{key}={value}')

env_path.write_text('\n'.join(out) + '\n')
PY
```

Pour verifier ensuite sans imprimer le secret:

```sh
python3 - <<'PY'
from pathlib import Path
for line in Path('env_perso.env').read_text().splitlines():
    if '=' in line:
        key, value = line.split('=', 1)
        if key.startswith('HARNAIS_PROJETS_GITHUB_') or key.startswith('GITHUB_TOKEN_'):
            print(key, len(value))
PY
```

## Verification finale a produire

Toujours confirmer en sortie:

1. URL du token cree (page settings GitHub),
2. repo effectivement selectionne,
3. permissions observees,
4. variable `env_perso.env` cible a renseigner,
5. rappel que la valeur n'est plus recuperable apres fermeture sans regeneration.
6. si un pont local a ete necessaire, expliquer brievement pourquoi (masquage GitHub/chat/CSP) pour pouvoir reproduire la manoeuvre la prochaine fois.

## Format de reponse final

- **Statut**: cree / regenere / en attente de confirmation utilisateur
- **Typologie**: `issue-create` | `fix-issue` | `agentic-bh`
- **Repo**: `owner/repo`
- **Permissions**: liste courte
- **Variables a renseigner**: liste exacte des cles `env_perso.env`
