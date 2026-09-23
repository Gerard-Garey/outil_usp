#!/usr/bin/env bash
###############################################################################
#  .claude/hooks/preparer_latex.sh  --  HOOK SessionStart DE CLAUDE CODE
#
#  Rend pdflatex disponible pour compiler docs/latex/doc_tests_usp.tex :
#    - pdflatex deja dans le PATH : rien a faire ;
#    - poste Windows : MiKTeX installe mais absent du PATH -> ajout au PATH ;
#    - Linux sans LaTeX (session cloud) : installation TeX Live par apt,
#      seulement avec l'argument --installer (plusieurs minutes), que passe la
#      skill compiler-doc au moment de compiler ; au demarrage de session, le
#      hook se contente de signaler l'absence.
#  Le hook n'echoue jamais au demarrage.
###############################################################################

. "$(dirname "$0")/commun.sh"

rapport() {
  echo "LaTeX pour cette session : $(pdflatex --version 2>&1 | head -n 1) ($1)."
}

if command -v pdflatex >/dev/null 2>&1; then
  rapport "deja dans le PATH"
  exit 0
fi

# --- Poste Windows (Git Bash) : MiKTeX installe hors du PATH -----------------
lad=$(cygpath -u "$LOCALAPPDATA" 2>/dev/null || echo "$LOCALAPPDATA")
for bin in "$lad/Programs/MiKTeX/miktex/bin/x64" "/c/Program Files/MiKTeX/miktex/bin/x64"; do
  if [ -x "$bin/pdflatex.exe" ]; then
    ajouter_au_path "$bin"
    rapport "ajoute au PATH depuis $bin"
    exit 0
  fi
done

# --- Linux (session cloud) : installation par apt, a la demande --------------
if [ "$1" != "--installer" ]; then
  echo "LaTeX absent ; la skill compiler-doc l'installera au besoin (bash .claude/hooks/preparer_latex.sh --installer)."
  exit 0
fi
echo "Installation de TeX Live par apt, plusieurs minutes..." >&2
# Paquets exiges par le preambule du .tex (newtx et dsfont : fonts-extra ;
# binhex.tex, charge par les polices : plain-generic) ; pdfinfo pour la
# verification du PDF par la skill compiler-doc (poppler-utils).
if installer_apt pdflatex texlive-latex-extra texlive-fonts-recommended \
     texlive-fonts-extra texlive-lang-french texlive-pictures \
     texlive-plain-generic poppler-utils; then
  rapport "installe par apt"
  exit 0
fi
echo "ATTENTION : pdflatex est introuvable et n'a pas pu etre installe ; le PDF ne peut pas etre compile dans cette session."
exit 1
