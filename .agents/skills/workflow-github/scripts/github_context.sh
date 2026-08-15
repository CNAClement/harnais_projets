#!/usr/bin/env bash

github_project_root() {
  git rev-parse --show-toplevel 2>/dev/null || pwd
}

github_load_env_file() {
  if [[ -n "${GITHUB_SKILL_ENV_LOADED:-}" ]]; then
    return 0
  fi

  local root env_file
  root=$(github_project_root)
  env_file="$root/env_perso.env"

  if [[ -f "$env_file" ]]; then
    set -a
    # shellcheck disable=SC1090
    . "$env_file"
    set +a
  fi

  GITHUB_SKILL_ENV_LOADED=1
}

github_auth() {
  local token_var token
  token_var=${1:-}
  [[ -n "$token_var" ]] || { echo "Usage: github_auth <token-var>" >&2; return 1; }

  github_load_env_file
  token=${!token_var:-${GITHUB_TOKEN:-}}
  [[ -n "$token" ]] || {
    echo "GitHub token missing: define $token_var in env_perso.env or export GITHUB_TOKEN." >&2
    return 1
  }

  export GITHUB_TOKEN="$token"
  gh auth status >/dev/null 2>&1 || printf '%s' "$GITHUB_TOKEN" | gh auth login --with-token
  gh auth status >/dev/null
}

github_resolve_repo() {
  local remote repo

  github_load_env_file

  if [[ -n "${GITHUB_REPO:-}" ]]; then
    printf '%s\n' "$GITHUB_REPO"
    return 0
  fi

  if [[ -n "${GH_REPO:-}" ]]; then
    printf '%s\n' "$GH_REPO"
    return 0
  fi

  remote=$(git config --get remote.origin.url 2>/dev/null || true)
  if [[ -n "$remote" ]]; then
    case "$remote" in
      git@*:* )
        repo=${remote#*:}
        ;;
      ssh://git@*/* )
        repo=${remote#ssh://git@}
        repo=${repo#*/}
        ;;
      https://*/* | http://*/* )
        repo=${remote#*://}
        repo=${repo#*/}
        ;;
      * )
        repo=
        ;;
    esac

    repo=${repo%.git}
    if [[ -n "$repo" && "$repo" == */* ]]; then
      printf '%s\n' "$repo"
      return 0
    fi
  fi

  repo=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || true)
  [[ -n "$repo" ]] || {
    echo "GitHub repo unresolved: export GITHUB_REPO=owner/repo or configure remote.origin.url." >&2
    return 1
  }

  printf '%s\n' "$repo"
}

github_preflight() {
  local token_var
  token_var=${1:-}
  github_auth "$token_var" || return 1
  export GITHUB_REPO
  GITHUB_REPO=$(github_resolve_repo) || return 1
}
