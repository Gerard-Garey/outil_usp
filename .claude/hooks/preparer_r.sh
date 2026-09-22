#!/usr/bin/env bash
###############################################################################
#  .claude/hooks/preparer_r.sh  --  HOOK SessionStart DE CLAUDE CODE
#
#  Rend Rscript disponible pour la session, en local comme dans le cloud :
#    - Rscript deja dans le PATH : rien a faire ;
#    - poste Windows : R installe mais absent du PATH -> ajout au PATH de la
#      session via $CLAUDE_ENV_FILE ;
#    - Linux sans R (session cloud) : installation de r-base-core par apt.
#  Le message affiche sur la sortie standard est ajoute au contexte de la
#  session. Le hook n'echoue jamais : au pire, il signale que R manque.
###############################################################################

. "$(dirname "$0")/commun.sh"

rapport() {
  echo "R pour cette session : $(Rscript --version 2>&1 | head -n 1) ($1)."
}

if command -v Rscript >/dev/null 2>&1; then
  rapport "deja dans le PATH"
  exit 0
fi

# --- Poste Windows (Git Bash) : R installe hors du PATH ---------------------
for base in "/c/Program Files/R" "$LOCALAPPDATA/Programs/R"; do
  [ -d "$base" ] || continue
  bin=$(ls -d "$base"/R-*/bin 2>/dev/null | sort -V | tail -n 1)
  if [ -n "$bin" ] && [ -x "$bin/Rscript.exe" ]; then
    ajouter_au_path "$bin"
    rapport "ajoute au PATH depuis $bin"
    exit 0
  fi
done

# --- Linux (session cloud) : installation par apt ---------------------------
if command -v apt-get >/dev/null 2>&1; then
  echo "Installation de R (r-base-core), 1 a 2 minutes..." >&2
  if installer_apt Rscript r-base-core; then
    rapport "installe par apt ; la CI reste la reference pour R 4.3.1"
    exit 0
  fi
fi

echo "ATTENTION : R est introuvable et n'a pas pu etre installe. Les tests (tests/test_reproductibilite.R) et le moteur ne peuvent pas etre executes dans cette session."
exit 0
