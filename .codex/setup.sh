#!/usr/bin/env bash
###############################################################################
#  .codex/setup.sh  --  SCRIPT DE SETUP DE L'ENVIRONNEMENT CODEX CLOUD
#
#  A declarer une fois par le mainteneur comme « setup script » de
#  l'environnement Codex Cloud du depot (reglages de l'environnement) :
#
#      bash .codex/setup.sh              # R seul (roles coder, audit, app-review)
#      USP_LATEX=1 bash .codex/setup.sh  # R et TeX Live (role docwriter) ;
#                                        # un echec de LaTeX n'est qu'un avertissement
#
#  Le setup s'execute avec acces a Internet, avant la tache ; l'agent, lui,
#  peut ne pas en avoir. Une tache qui ne trouve pas Rscript relance ce
#  script ; s'il echoue, elle s'arrete en le disant (AGENTS.md).
#
#  R : r-base-core par apt (R 4.3.x sous Ubuntu 24.04). La CI (R 4.3.1,
#  ubuntu-22.04, BLAS de reference) reste seule reference des resultats ;
#  les references de tests/reference/ ne se regenerent jamais ici (ADR 0011).
#  Le moteur n'a besoin que de R base + stats ; aucun paquet CRAN n'est
#  installe.
###############################################################################

set -u

SUDO=""
if [ "$(id -u)" != "0" ] && command -v sudo >/dev/null 2>&1; then SUDO="sudo -n"; fi
APT="$SUDO env DEBIAN_FRONTEND=noninteractive apt-get"

installer() {
  # installer <commande attendue> <paquet>...
  # En cas d'echec, affiche la fin du journal d'apt et la cause probable.
  commande=$1; shift
  if command -v "$commande" >/dev/null 2>&1; then
    echo "$commande deja present."
    return 0
  fi
  if ! command -v apt-get >/dev/null 2>&1; then
    echo "apt-get absent : installation de $* impossible." >&2
    return 1
  fi
  journal="${TMPDIR:-/tmp}/setup_$commande.log"
  echo "Installation de $* (journal : $journal) ..."
  if $APT update -qq >"$journal" 2>&1 &&
     $APT install -y -qq --no-install-recommends "$@" >>"$journal" 2>&1 &&
     command -v "$commande" >/dev/null 2>&1; then
    return 0
  fi
  tail -n 15 "$journal" >&2
  if grep -qi "unable to locate package" "$journal"; then
    echo "Cause probable : paquet absent des index apt (depots Ubuntu" \
         "inaccessibles lors de 'apt-get update', ou nom de paquet errone)." >&2
  elif grep -qiE "could not resolve|temporary failure|failed to fetch|network is unreachable|connection (timed out|refused)" "$journal"; then
    echo "Cause probable : pas d'acces a Internet. Declarer ce script comme" \
         "setup script de l'environnement Codex Cloud (phase avec Internet)," \
         "ou autoriser l'acces Internet de l'agent aux depots apt d'Ubuntu." >&2
  elif [ "$(id -u)" != "0" ] && [ -z "$SUDO" ]; then
    echo "Cause probable : ni root ni sudo." >&2
  fi
  return 1
}

statut=0

if installer Rscript r-base-core; then
  echo "R : $(Rscript --version 2>&1 | head -n 1)"
else
  echo "ECHEC : Rscript indisponible ; aucune batterie ne peut tourner." >&2
  statut=1
fi

# Locale des batteries (faux echec de la concordance sous POSIX, #113).
if ! locale -a 2>/dev/null | grep -qi '^c\.utf-\?8$'; then
  echo "ATTENTION : locale C.UTF-8 absente ; lancer les batteries sous une locale UTF-8." >&2
fi

if [ "${USP_LATEX:-0}" = "1" ]; then
  # Paquets exiges par le preambule de docs/latex/doc_tests_usp.tex ;
  # pdfinfo (poppler-utils) pour la verification du PDF.
  # Echec de LaTeX : avertissement seulement, pour ne pas rendre
  # l'environnement inutilisable aux roles qui n'ont besoin que de R.
  # pdflatex et pdfinfo sont testes separement : l'un peut exister sans
  # l'autre.
  if installer pdflatex texlive-latex-extra texlive-fonts-recommended \
       texlive-fonts-extra texlive-lang-french texlive-pictures \
       texlive-plain-generic latexmk &&
     installer pdfinfo poppler-utils; then
    echo "LaTeX : $(pdflatex --version 2>&1 | head -n 1)"
  else
    echo "ATTENTION : pdflatex ou pdfinfo indisponible ; le PDF ne peut pas etre compile ici (voir .codex/procedures/compilation-doc.md)." >&2
  fi
fi

exit $statut
