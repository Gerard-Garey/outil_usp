#!/bin/bash
# usage : rejouer.sh <depot> <bibliotheque_openxlsx> <cas...>
# Chaque cas dans un sous-processus Rscript, sans puis avec openxlsx ; code de sortie releve.
D=$1; B=$2; shift 2; SD=$(dirname "$(readlink -f "$0")")
for c in "$@"; do
  for chemin in interne openxlsx; do
    if [ $chemin = openxlsx ]; then L=$B; else L=; fi
    R_LIBS=$L LC_ALL=C.UTF-8 Rscript "$SD/sonde.R" "$D" "$SD" "$c" 2>&1
    echo "  [code de sortie : $?]"; echo
  done
done
