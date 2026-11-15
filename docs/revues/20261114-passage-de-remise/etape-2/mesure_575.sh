#!/bin/bash
# usage : mesure.sh <bibliotheque> <depot>
# forge.xlsx (non verse) : classeur d'une feuille dont une cellule t="s" porte
# l'indice 5 alors que la table des chaines partagees n'en a qu'une (#575).
B=$1; D=$2; F=$(dirname $0)/forge.xlsx
echo "== openxlsx::read.xlsx direct"
R_LIBS=$B LC_ALL=C.UTF-8 Rscript -e 'cat("openxlsx", as.character(packageVersion("openxlsx")), "\n"); x <- openxlsx::read.xlsx(commandArgs(TRUE)[1], colNames = FALSE); print(x)' $F; echo "code de sortie : $?"
echo "== engine_lire_xlsx (openxlsx present)"
cd $D && R_LIBS=$B LC_ALL=C.UTF-8 Rscript -e 'source("R/charger_moteur.R"); e <- charger_moteur(); f <- get("engine_lire_xlsx", envir = environment(e$run_engine)); r <- tryCatch(f(commandArgs(TRUE)[1]), error = function(err) paste("ERREUR :", conditionMessage(err))); str(r)' $F; echo "code de sortie : $?"
