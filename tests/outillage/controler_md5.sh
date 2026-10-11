#!/usr/bin/env bash
###############################################################################
#  tests/outillage/controler_md5.sh  --  CONTROLE DES md5 DES SORTIES D'UNE
#  MESURE CONTRE SON JOURNAL (issue #206, Q-206-5, lecon L-229-5)
#
#  Outillage d'execution, SANS LOGIQUE DE MESURE. Meme regle que
#  --combiner --journal du script de mesure : chaque sortie terminee doit
#  figurer au JOURNAL sur une ligne qui porte son nom et son md5.
#
#  Usage :
#      bash tests/outillage/controler_md5.sh -d DOSSIER [-j JOURNAL]
#    DOSSIER : dossier des sorties (ou sa copie sur la branche de sauvegarde) ;
#    JOURNAL : defaut DOSSIER/JOURNAL.md.
#  Controles :
#    - chaque sortie terminee (*.txt, derniere ligne non vide "FIN<TAB>...")
#      a une ligne et une seule "- Sortie <nom> : md5 <md5>" au JOURNAL, en
#      debut de ligne, de md5 egal a celui du fichier (#248 : une ligne en
#      double, meme de md5 egal, est un ecart, comme pour --combiner
#      --journal) ;
#    - chaque sortie citee au JOURNAL existe dans DOSSIER et a ce md5 ;
#    - les sorties partielles (sans FIN) sont listees, sans erreur.
#  Code de sortie : 0 si tout concorde, 1 sinon.
###############################################################################
set -u

DOSSIER=""; JOURNAL=""
while [ $# -gt 0 ]; do
  case "$1" in
    -d) DOSSIER="$2"; shift 2 ;;
    -j) JOURNAL="$2"; shift 2 ;;
    *) echo "option inconnue : $1" >&2; exit 2 ;;
  esac
done
[ -d "$DOSSIER" ] || { echo "dossier introuvable (-d)" >&2; exit 2; }
[ -n "$JOURNAL" ] || JOURNAL="$DOSSIER/JOURNAL.md"
[ -f "$JOURNAL" ] || { echo "JOURNAL introuvable : $JOURNAL" >&2; exit 2; }

md5() { if command -v md5sum >/dev/null 2>&1; then md5sum "$1" | cut -d' ' -f1; else command md5 -q "$1"; fi; }
terminee() { [ -f "$1" ] && [ "$(grep -v '^[[:space:]]*$' "$1" | tail -n 1 | cut -f1)" = "FIN" ]; }

ko=0; n_ok=0
for f in "$DOSSIER"/*.txt; do
  [ -e "$f" ] || continue
  nom=$(basename "$f")
  if ! terminee "$f"; then echo "PARTIELLE $nom (sans FIN)"; continue; fi
  j=$(awk -v n="$nom" 'index($0, "- Sortie " n " : md5 ") == 1 { r = substr($0, length("- Sortie " n " : md5 ") + 1); m = substr(r, 1, 32); c = substr(r, 33, 1); if (length(m) == 32 && m !~ /[^0-9a-f]/ && (c == "" || c == "," || c == " " || c == "\t" || c == "\r")) print m }' "$JOURNAL")
  m=$(md5 "$f")
  if [ -z "$j" ]; then echo "ABSENTE DU JOURNAL $nom ($m)"; ko=1
  elif [ "$(printf '%s\n' "$j" | wc -l)" -ne 1 ]; then echo "LIGNES MULTIPLES $nom : $(printf '%s\n' "$j" | wc -l | tr -d ' ') lignes au JOURNAL (une attendue), md5 $(echo $j)"; ko=1
  elif [ "$j" != "$m" ]; then echo "DIFFERENTE $nom : fichier $m, JOURNAL $j"; ko=1
  else n_ok=$((n_ok + 1)); fi
done
while read -r nom m; do
  [ -n "$nom" ] || continue
  if [ ! -f "$DOSSIER/$nom" ]; then echo "CITEE AU JOURNAL, ABSENTE $nom"; ko=1
  elif [ "$(md5 "$DOSSIER/$nom")" != "$m" ]; then echo "CITEE AU JOURNAL, md5 DIFFERENT $nom"; ko=1; fi
done < <(awk 'index($0, "- Sortie ") == 1 { r = substr($0, 10); k = index(r, " : md5 "); if (k < 2) next; n = substr(r, 1, k - 1); if (n ~ /[ \t]/) next; r = substr(r, k + 7); m = substr(r, 1, 32); c = substr(r, 33, 1); if (length(m) == 32 && m !~ /[^0-9a-f]/ && (c == "" || c == "," || c == " " || c == "\t" || c == "\r")) print n, m }' "$JOURNAL")
echo "BILAN : $n_ok sortie(s) terminee(s) conforme(s) au JOURNAL ; $( [ "$ko" -eq 0 ] && echo 'aucun ecart' || echo 'ECARTS ci-dessus')"
exit "$ko"
