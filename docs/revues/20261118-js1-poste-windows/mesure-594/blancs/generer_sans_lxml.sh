#!/bin/sh
# Classeurs de classeurs_sans_lxml/ : openpyxl 3.1.5 sans lxml.
# Usage, depuis la racine du depot : sh <ce fichier> <dossier de sortie>
# (openpyxl et pandas importables par python3).
set -e
M=docs/revues/20261118-js1-poste-windows/mesure-594
OUT=$1; T=$(mktemp -d)
export OPENPYXL_LXML=False
python3 $M/blancs/generer_blancs.py tests/donnees/donnees_ln.csv "$OUT"
python3 $M/generer.py tests/donnees/donnees_ln.csv "$T"
cp "$T/openpyxl_blancs.xlsx" "$OUT/note_bordee_blancs.xlsx"
cp "$T/openpyxl_temoin.xlsx" "$OUT/note_temoin.xlsx"
rm -r "$T"
