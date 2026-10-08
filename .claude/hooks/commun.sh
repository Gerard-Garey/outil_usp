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

# Session cloud derriere le proxy sortant ($HTTPS_PROXY) : apt n'y passe pas
# en HTTP simple (depots Ubuntu declares en http://, nom non resolu). On bascule
# les depots Ubuntu en https:// et on declare le proxy a apt, sans CaInfo :
# apt telecharge sous l'utilisateur _apt, qui ne lit pas le certificat du proxy
# dans /root ; les certificats systeme suffisent. Idempotent. Couvre aussi
# les miroirs regionaux (xx[.yy].archive.ubuntu.com) et ports.ubuntu.com. Sans
# proxy, retire le fichier d'une session precedente. Les domaines Ubuntu
# utilises doivent etre autorises par la politique reseau de l'environnement
# (constat et decision du 08/10/2026 ; revue finale d'E1g).
preparer_apt_proxy() {
  conf=/etc/apt/apt.conf.d/99proxy-session
  if [ -z "${HTTPS_PROXY:-}" ]; then
    [ -f "$conf" ] && ${SUDO:-} rm -f "$conf" 2>/dev/null
    return 0
  fi
  motif='http://(([a-z0-9-]+\.)*archive|security|ports)\.ubuntu\.com'
  for f in /etc/apt/sources.list /etc/apt/sources.list.d/*.list /etc/apt/sources.list.d/*.sources; do
    [ -f "$f" ] && grep -Eq "$motif" "$f" &&
      ${SUDO:-} sed -i -E "s#$motif#https://\1.ubuntu.com#g" "$f" 2>/dev/null
  done
  printf 'Acquire::https::Proxy "%s";\n' "$HTTPS_PROXY" |
    ${SUDO:-} tee "$conf" >/dev/null 2>&1
  return 0
}

# installer_apt <commande attendue> <paquet>... : installe par apt (session
# cloud Linux) et reussit si la commande est ensuite disponible. La sortie
# d'apt va dans un journal, dont la fin est affichee en cas d'echec.
installer_apt() {
  commande=$1; shift
  command -v apt-get >/dev/null 2>&1 || return 1
  SUDO=""
  if [ "$(id -u)" != "0" ] && command -v sudo >/dev/null 2>&1; then SUDO="sudo -n"; fi
  preparer_apt_proxy
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
