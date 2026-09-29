#!/usr/bin/env bash
###############################################################################
#  .codex/setup.sh  --  SCRIPT DE SETUP DE L'ENVIRONNEMENT CODEX CLOUD
#
#  A declarer une fois par le mainteneur comme « setup script » de
#  l'environnement Codex Cloud du depot (reglages de l'environnement) :
#
#      bash .codex/setup.sh              # R seul (roles coder, audit, app-review)
#      USP_LATEX=1 bash .codex/setup.sh  # R et TeX Live (role docwriter)
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
  commande=$1; shift
  if command -v "$commande" >/dev/null 2>&1; then
    echo "$commande deja present."
    return 0
  fi
  echo "Installation de $* ..."
  $APT update -qq && $APT install -y -qq --no-install-recommends "$@" &&
    command -v "$commande" >/dev/null 2>&1
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
  if installer pdflatex texlive-latex-extra texlive-fonts-recommended \
       texlive-fonts-extra texlive-lang-french texlive-pictures \
       texlive-plain-generic poppler-utils latexmk; then
    echo "LaTeX : $(pdflatex --version 2>&1 | head -n 1)"
  else
    echo "ECHEC : pdflatex indisponible ; le PDF ne peut pas etre compile." >&2
    statut=1
  fi
fi

exit $statut
