.args <- "tests/test_unitaires.R"
ex <- parse("tests/test_unitaires.R")
noms <- NULL
noms <- c(".args","FICHIERS_UNITAIRES","DUREE_DEFAUT_S","lire_durees","DUREES_UNITAIRES","duree_estimee","MOTIF_APPLICATION","exige_application","repartir_lots", "DOSSIER_UNITAIRES","FICHIER_DUREES")
for (e in ex) {
  if (is.call(e) && identical(e[[1]], as.name("<-")) && as.character(e[[2]])[1] %in% noms) {
    r <- try(eval(e, globalenv()), silent = TRUE)
    if (inherits(r, "try-error")) cat("ERR", as.character(e[[2]]), conditionMessage(attr(r,"condition")), "\n")
  }
}
DOSSIER_UNITAIRES <- "tests/unitaires"; FICHIERS_UNITAIRES <- sort(list.files(DOSSIER_UNITAIRES, pattern = "^test_.*[.]R$", full.names = TRUE)); DUREES_UNITAIRES <- lire_durees("tests/durees_unitaires.tsv")
rep <- repartir_lots(FICHIERS_UNITAIRES, 3L)
for (f in c("test_application.R","test_controles_entree.R","test_outdec.R","test_defauts_connus.R"))
  cat(f, "-> lot", rep$lot[basename(FICHIERS_UNITAIRES) == f], "\n")
