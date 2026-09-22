#!/usr/bin/env bash
###############################################################################
#  .claude/hooks/commun.sh  --  fonctions partagees par les hooks de preparation
#  (preparer_r.sh, preparer_latex.sh). A charger par `source`.
###############################################################################

# Ajoute un dossier au PATH de la session. $CLAUDE_ENV_FILE est fourni par
# Claude Code aux hooks SessionStart : les lignes qui y sont ecrites
# s'appliquent aux commandes Bash de la session.
ajouter_au_path() {
  export PATH="$1:$PATH"
  if [ -n "$CLAUDE_ENV_FILE" ]; then
    printf 'export PATH="%s:$PATH"\n' "$1" >> "$CLAUDE_ENV_FILE"
  fi
}

# installer_apt <commande attendue> <paquet>... : installe par apt (session
# cloud Linux) et reussit si la commande est ensuite disponible. La sortie
# d'apt va dans un journal, dont la fin est affichee en cas d'echec.
installer_apt() {
  commande=$1; shift
  command -v apt-get >/dev/null 2>&1 || return 1
  SUDO=""
  if [ "$(id -u)" != "0" ] && command -v sudo >/dev/null 2>&1; then SUDO="sudo -n"; fi
  journal="${TMPDIR:-/tmp}/apt_$commande.log"
  apt="$SUDO env DEBIAN_FRONTEND=noninteractive apt-get"
  if $apt update -qq >"$journal" 2>&1 &&
     $apt install -y -qq --no-install-recommends "$@" >>"$journal" 2>&1 &&
     command -v "$commande" >/dev/null 2>&1; then
    return 0
  fi
  tail -n 5 "$journal" >&2
  return 1
}
