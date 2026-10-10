#!/usr/bin/env bash
###############################################################################
#  tests/outillage/lancer_tranches.sh  --  LANCEUR IDEMPOTENT DES TRANCHES
#  D'UN SCRIPT DE MESURE HORS CI (issue #206, Q-206-5, lecon L-229-1)
#
#  Outillage d'execution, SANS LOGIQUE DE MESURE : il lance le script de
#  mesure sur les lignes d'un plan, saute les sorties terminees et reprend
#  les sorties partielles par --reprendre. Versionne sur la branche de
#  travail (jamais sur une branche de sauvegarde : L-229-1). Sert a la mesure
#  #206 (tests/calibration_mc_mw_t8.R) et a tout script qui suit la meme
#  mecanique (--sortie-tranche, --reprendre, ligne FIN finale).
#
#  Usage (depuis la racine du worktree au commit mesure) :
#      bash tests/outillage/lancer_tranches.sh -p PLAN -d DOSSIER [-j PROCESSUS]
#           [-s SCRIPT] [-- OPTIONS_SUPPLEMENTAIRES]
#    PLAN     : fichier texte, une sortie par ligne "nom<TAB>arguments" (lignes
#               vides et lignes commencant par # ignorees), produit par
#               "Rscript tests/calibration_mc_mw_t8.R --plan Lk" ;
#    DOSSIER  : dossier des sorties, HORS du depot (le script de mesure le
#               refuse sous le depot) ;
#    PROCESSUS: nombre de sorties calculees en parallele (defaut 1) ;
#    SCRIPT   : script de mesure (defaut tests/calibration_mc_mw_t8.R) ;
#    OPTIONS_SUPPLEMENTAIRES : ajoutees a chaque appel (ex. --essai).
#  Pour chaque ligne du plan, dans l'ordre :
#    - DOSSIER/nom existe et sa derniere ligne non vide commence par "FIN<TAB>"
#      : sortie terminee, sautee (son etat INTEGRITE est rapporte) ;
#    - DOSSIER/nom existe sans FIN : sortie partielle, renommee
#      nom.partielN (N libre suivant), puis reprise par
#      "--reprendre DOSSIER/nom.partielN --sortie-tranche DOSSIER/nom" si son
#      en-tete est complet (ligne COLS presente), recalculee sinon ;
#    - sinon : calculee par "--sortie-tranche DOSSIER/nom".
#  Journal d'execution : DOSSIER/lanceur.log, une ligne par sortie
#  (nom, debut et fin UTC, code de sortie, md5 de la sortie, reprise) ;
#  console du script dans DOSSIER/nom.log (ajout). Relancer la meme commande
#  apres un redemarrage du conteneur reprend la ou elle s'etait arretee.
#  Code de sortie : 0 si toutes les sorties du plan sont terminees avec
#  INTEGRITE OK, 1 sinon.
###############################################################################
set -u

PLAN=""; DOSSIER=""; PROCESSUS=1; SCRIPT="tests/calibration_mc_mw_t8.R"
while [ $# -gt 0 ]; do
  case "$1" in
    -p) PLAN="$2"; shift 2 ;;
    -d) DOSSIER="$2"; shift 2 ;;
    -j) PROCESSUS="$2"; shift 2 ;;
    -s) SCRIPT="$2"; shift 2 ;;
    --) shift; break ;;
    *) echo "option inconnue : $1" >&2; exit 2 ;;
  esac
done
SUPPL=("$@")
[ -n "$PLAN" ] && [ -f "$PLAN" ] || { echo "plan introuvable (-p)" >&2; exit 2; }
[ -n "$DOSSIER" ] && [ -d "$DOSSIER" ] || { echo "dossier des sorties introuvable (-d)" >&2; exit 2; }
[ -f "$SCRIPT" ] || { echo "script de mesure introuvable : $SCRIPT (lancer depuis la racine du worktree)" >&2; exit 2; }
case "$PROCESSUS" in ''|*[!0-9]*) echo "-j : entier attendu" >&2; exit 2 ;; esac
[ "$PROCESSUS" -ge 1 ] || { echo "-j : au moins 1" >&2; exit 2; }
command -v Rscript >/dev/null 2>&1 || { echo "Rscript introuvable" >&2; exit 2; }

md5() { if command -v md5sum >/dev/null 2>&1; then md5sum "$1" | cut -d' ' -f1; else md5 -q "$1"; fi; }
utc() { date -u +%Y-%m-%dT%H:%M:%SZ; }
# Sortie terminee : derniere ligne non vide "FIN<TAB>..."
terminee() { [ -f "$1" ] && [ "$(grep -v '^[[:space:]]*$' "$1" | tail -n 1 | cut -f1)" = "FIN" ]; }
integrite() { grep -m1 '^INTEGRITE	' "$1" | cut -f2; }

lancer_une() {
  local nom="$1" args="$2" sortie="$DOSSIER/$1" reprise="-" n=1 t0 code
  if terminee "$sortie"; then
    echo "$nom : terminee (INTEGRITE $(integrite "$sortie")), sautee"
    return 0
  fi
  local opts=()
  if [ -f "$sortie" ]; then
    while [ -e "$sortie.partiel$n" ]; do n=$((n + 1)); done
    mv "$sortie" "$sortie.partiel$n"
    if grep -q '^COLS	' "$sortie.partiel$n"; then
      opts=(--reprendre "$sortie.partiel$n"); reprise="$nom.partiel$n"
    else
      reprise="en-tete incomplet ($nom.partiel$n), recalcul"
    fi
  fi
  t0=$(utc)
  # shellcheck disable=SC2086
  Rscript "$SCRIPT" $args ${opts[@]+"${opts[@]}"} --sortie-tranche "$sortie" ${SUPPL[@]+"${SUPPL[@]}"} >> "$DOSSIER/$nom.log" 2>&1
  code=$?
  printf '%s\tdebut %s\tfin %s\tcode %s\tmd5 %s\treprise %s\n' "$nom" "$t0" "$(utc)" "$code" \
    "$( [ -f "$sortie" ] && md5 "$sortie" || echo absent)" "$reprise" >> "$DOSSIER/lanceur.log"
  echo "$nom : code $code"
}

# File d'attente : PROCESSUS sorties en parallele (bash >= 4.3, wait -n).
actifs=0
while IFS=$'\t' read -r nom args || [ -n "$nom" ]; do
  case "$nom" in ''|'#'*) continue ;; esac
  if [ "$actifs" -ge "$PROCESSUS" ]; then wait -n; actifs=$((actifs - 1)); fi
  lancer_une "$nom" "$args" &
  actifs=$((actifs + 1))
done < "$PLAN"
wait

# Bilan : toutes les sorties du plan terminees, INTEGRITE OK.
ko=0
while IFS=$'\t' read -r nom args || [ -n "$nom" ]; do
  case "$nom" in ''|'#'*) continue ;; esac
  if ! terminee "$DOSSIER/$nom"; then echo "BILAN $nom : non terminee"; ko=1
  elif [ "$(integrite "$DOSSIER/$nom")" != "OK" ]; then echo "BILAN $nom : INTEGRITE $(integrite "$DOSSIER/$nom")"; ko=1; fi
done < "$PLAN"
[ "$ko" -eq 0 ] && echo "BILAN : toutes les sorties du plan sont terminees, INTEGRITE OK"
exit "$ko"
