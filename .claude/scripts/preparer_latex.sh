#!/usr/bin/env bash
###############################################################################
#  .claude/scripts/preparer_latex.sh
#
#  Rend pdflatex disponible pour compiler docs/latex/doc_tests_usp.tex, en
#  local comme dans le cloud (skill compiler-doc, etape 0) :
#    - pdflatex deja dans le PATH : rien a faire ;
#    - poste Windows : MiKTeX installe mais absent du PATH -> ajout au PATH ;
#    - Linux sans LaTeX (session cloud) : installation TeX Live par apt.
#  A lancer par `source` pour que l'ajout au PATH vaille dans le shell courant ;
#  en session cloud, `bash` suffit (apt installe dans /usr/bin).
#  Paquets apt : ceux qu'exige le preambule du .tex (newtxtext et dsfont sont
#  dans texlive-fonts-extra, babel-french dans texlive-lang-french, tikz dans
#  texlive-pictures, mdframed/titlesec/tocloft dans texlive-latex-extra).
###############################################################################

rapport() {
  echo "LaTeX pour cette session : $(pdflatex --version 2>&1 | head -n 1) ($1)."
}

if command -v pdflatex >/dev/null 2>&1; then
  rapport "deja dans le PATH"
  return 0 2>/dev/null || exit 0
fi

# --- Poste Windows (Git Bash) : MiKTeX installe hors du PATH -----------------
for bin in "$LOCALAPPDATA/Programs/MiKTeX/miktex/bin/x64" "/c/Program Files/MiKTeX/miktex/bin/x64"; do
  if [ -x "$bin/pdflatex.exe" ]; then
    export PATH="$bin:$PATH"
    rapport "ajoute au PATH depuis $bin"
    return 0 2>/dev/null || exit 0
  fi
done

# --- Linux (session cloud) : installation par apt ----------------------------
if command -v apt-get >/dev/null 2>&1; then
  if [ "$(id -u)" = "0" ]; then SUDO=""
  elif command -v sudo >/dev/null 2>&1; then SUDO="sudo -n"
  else SUDO=""; fi
  echo "Installation de TeX Live par apt, plusieurs minutes (texlive-fonts-extra est volumineux)..." >&2
  if $SUDO env DEBIAN_FRONTEND=noninteractive apt-get update -qq >/dev/null 2>&1 &&
     $SUDO env DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --no-install-recommends \
       texlive-latex-base texlive-latex-recommended texlive-latex-extra \
       texlive-fonts-recommended texlive-fonts-extra texlive-lang-french \
       texlive-pictures >/dev/null 2>&1 &&
     command -v pdflatex >/dev/null 2>&1; then
    rapport "installe par apt"
    return 0 2>/dev/null || exit 0
  fi
fi

echo "ATTENTION : pdflatex est introuvable et n'a pas pu etre installe ; le PDF ne peut pas etre compile dans cette session."
return 1 2>/dev/null || exit 1
