#!/usr/bin/env bash
# Controle des mots-cles de fermeture d'issue (issue #407, decision Q-45-12,
# CLAUDE.md « Git et GitHub »).
#
# Regle : aucun mot-cle de fermeture (close, closes, closed, fix, fixes,
# fixed, resolve, resolves, resolved, insensible a la casse) suivi d'une
# reference d'issue ne figure dans un message de commit ni dans la prose du
# corps d'une PR, meme entre guillemets. Seules sont admises, dans le corps
# de la PR, les lignes qui ne contiennent que « Closes #N ».
#
# Formes de reference lues : #N, owner/repo#N, URL d'issue ou de pull
# (formes de fermeture de GitHub), et GH-N (ajoutee par prudence). Un
# deux-points apres le mot-cle est admis par GitHub et traite de meme. Le
# controle est volontairement plus large que la lecture de GitHub (mieux
# vaut un faux positif acquittable qu'une issue fermee a tort) : il n'a pas
# ete confronte a toutes les variantes que GitHub lit.
# Limite connue : le controle est ligne a ligne ; un mot-cle en fin de ligne
# et un numero en debut de ligne suivante ne sont pas rapproches.
#
# Un commit fautif deja publie ne se reecrit pas (Q-43-13) : il est acquitte
# par la liste versionnee .github/shas_admis_fermeture.txt (un SHA complet de
# 40 caracteres par ligne, suivi en commentaire du renvoi a l'issue rouverte
# apres la fusion). Le corps de PR, lui, se corrige dans l'interface.
#
# Usage (le workflow mots-cles-fermeture.yml l'appelle sans argument), par
# variables d'environnement : BASE_REF (branche de base de la PR), HEAD_SHA
# (tete de la PR), PR_BODY (corps), PR_TITLE (titre, facultatif), LISTE_ADMIS
# (facultatif, defaut .github/shas_admis_fermeture.txt). Le corps arrive par
# variable d'environnement, jamais par interpolation dans le script : aucune
# injection de shell par le texte de la PR.
# Codes de sortie : 0 aucun mot-cle ; 1 mot-cle trouve ; 2 controle impossible
# (base ou tete introuvable, erreur de lecture) : jamais un succes silencieux.
# Le fichier se source aussi (tests) : les fonctions sont alors disponibles
# sans execution du controle.

MOTIF_FERMETURE='(^|[^[:alnum:]_])(close[sd]?|fix(e[sd])?|resolve[sd]?)[`*_]*[[:space:]]*:?[[:space:]]*[`*_[]*(#[0-9]+|GH-[0-9]+|[[:alnum:]_.-]+/[[:alnum:]_.-]+#[0-9]+|https?://github\.com/[^[:space:]]+/(issues|pull)/[0-9]+)'
# Ligne dediee admise dans le corps d'une PR (apres numerotation par grep -n).
LIGNE_DEDIEE='^[0-9]+:Closes #[0-9]+[[:space:]]*$'

# Lignes d'un texte (stdin) qui portent un mot-cle, au format « n:ligne ».
# Les fins de ligne CRLF des corps de PR sont retirees. Code 0 (avec ou sans
# ligne) ; autre code seulement si grep echoue (code 2 : erreur, jamais masque).
fermeture_lignes_motif() {
  tr -d '\r' | grep -n -i -E -- "$MOTIF_FERMETURE" || [ $? -eq 1 ]
}

# Corps de PR (stdin) : lignes fautives, lignes dediees « Closes #N » exclues.
fermeture_lignes_fautives_corps() {
  local lignes
  # Deux temps (pas de tube) : le code d'erreur de la premiere etape n'est
  # pas masque par le code 1 de grep -v quand rien ne reste.
  lignes=$(fermeture_lignes_motif) || return 2
  printf '%s\n' "$lignes" | grep -v -E -- "$LIGNE_DEDIEE" || [ $? -eq 1 ]
}

# Le SHA complet $1 figure-t-il dans la liste d'acquittement $2 ?
# Seul le premier mot de chaque ligne compte : une ligne commentee (#) ou un
# SHA tronque ne correspond a aucun SHA complet. Fins de ligne CRLF admises.
fermeture_sha_admis() {
  local sha="$1" liste="$2"
  [ -f "$liste" ] || return 1
  awk -v s="$sha" '{ sub(/\r$/, "") } $1 == s { trouve = 1 } END { exit !trouve }' "$liste"
}

# Commits de $1..$2 fautifs et non acquittes (liste $3) : une ligne de rapport
# par ligne fautive, « commit abc1234 « sujet » : ligne n:texte ».
# Code 2 si la plage ne peut pas etre lue (base ou tete inconnue) : jamais un
# succes silencieux.
fermeture_rapport_commits() {
  local base="$1" tete="$2" liste="$3" shas sha court sujet message lignes l
  shas=$(git rev-list "$base..$tete") || return 2
  while IFS= read -r sha; do
    [ -n "$sha" ] || continue
    if fermeture_sha_admis "$sha" "$liste"; then continue; fi
    court=$(git rev-parse --short "$sha") || return 2
    sujet=$(git log -1 --format=%s "$sha") || return 2
    message=$(git log -1 --format=%B "$sha") || return 2
    lignes=$(printf '%s\n' "$message" | fermeture_lignes_motif) || return 2
    [ -n "$lignes" ] || continue
    while IFS= read -r l; do
      printf 'commit %s « %s » : ligne %s\n' "$court" "$sujet" "$l"
    done <<< "$lignes"
  done <<< "$shas"
}

# Corps de PR (stdin) : une ligne de rapport par ligne fautive.
fermeture_rapport_corps() {
  local lignes
  lignes=$(fermeture_lignes_fautives_corps) || return 2
  [ -z "$lignes" ] || printf '%s\n' "$lignes" | sed 's/^/corps de la PR : ligne /'
}

# Titre de PR (stdin) : aucune ligne dediee admise, toute occurrence est fautive.
fermeture_rapport_titre() {
  local lignes
  lignes=$(fermeture_lignes_motif) || return 2
  [ -z "$lignes" ] || printf '%s\n' "$lignes" | sed 's/^/titre de la PR : ligne /'
}

# Controle complet. Code 1 et rapport nommant le commit ou la ligne fautive ;
# code 2 si le controle ne peut pas s'executer (base ou tete introuvable,
# erreur de lecture) : l'impossibilite de controler n'est jamais un succes.
fermeture_controle() {
  local base="origin/${BASE_REF:?BASE_REF manquant}" tete="${HEAD_SHA:?HEAD_SHA manquant}"
  local liste="${LISTE_ADMIS:-.github/shas_admis_fermeture.txt}" rapport r nb
  local ref
  for ref in "$base" "$tete"; do
    if ! git rev-parse -q --verify "$ref^{commit}" > /dev/null; then
      echo "::error title=Contrôle impossible::Commit ou référence introuvable : ${ref}. Le contrôle ne peut pas être exécuté."
      return 2
    fi
  done
  rapport=$(fermeture_rapport_commits "$base" "$tete" "$liste") || {
    echo "::error title=Contrôle impossible::Lecture des commits de ${base}..${tete} en échec."
    return 2
  }
  r=$(printf '%s\n' "${PR_BODY-}" | fermeture_rapport_corps) || {
    echo "::error title=Contrôle impossible::Lecture du corps de la PR en échec."
    return 2
  }
  rapport+="${r:+$'\n'$r}"
  r=$(printf '%s\n' "${PR_TITLE-}" | fermeture_rapport_titre) || {
    echo "::error title=Contrôle impossible::Lecture du titre de la PR en échec."
    return 2
  }
  rapport+="${r:+$'\n'$r}"
  rapport="${rapport#$'\n'}"
  if [ -n "$rapport" ]; then
    echo "::error title=Mot-clé de fermeture interdit::Détail dans le journal du job (commit, corps ou titre de la PR)."
    echo "Mots-clés de fermeture trouvés hors des lignes « Closes #N » du corps de la PR :"
    printf '%s\n' "$rapport"
    echo
    echo "Règle (CLAUDE.md, « Git et GitHub » ; Q-45-12) : écrire « Refs #N » ou « fermeture de #N » ailleurs que sur ces lignes dédiées."
    echo "Corps ou titre de PR : corriger dans l'interface (le contrôle repart seul). Commit déjà fait : il ne se réécrit pas ; ajouter son SHA complet à ${liste} avec le renvoi à l'issue rouverte après la fusion."
    return 1
  fi
  nb=$(git rev-list --count "$base..$tete") || return 2
  echo "Aucun mot-clé de fermeture hors des lignes « Closes #N » du corps de la PR (${nb} commit(s) examiné(s))."
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  set -uo pipefail
  fermeture_controle
fi
