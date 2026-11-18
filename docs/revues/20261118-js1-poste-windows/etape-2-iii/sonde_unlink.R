# Etape 2 (iii) de JS1 : localisation du fichier ecrit par
# engine_ecrire_xlsx(df, "C:f.xlsx") sous Windows. trace() sur base::unlink
# releve, au moment ou le dossier temporaire d de l'appel est supprime, si
# f.xlsx s'y trouve. Usage : Rscript sonde_unlink.R <racine du depot>.
depot <- normalizePath(commandArgs(TRUE)[1], winslash = "/")  # racine du depot
source(file.path(depot, "R/charger_moteur.R")); charger_moteur(file.path(depot, "R/engine.R"))
e <- environment(run_engine)
cat("HEAD :", system2("git", c("-C", depot, "rev-parse", "HEAD"), stdout = TRUE), "\n")
cat("tempdir() :", tempdir(), "; getwd() :", getwd(), "\n")
cat("dirname:", dirname("C:f.xlsx"), "\n")
cat("cible:", e$.xlsx_chemin_sortie("C:f.xlsx", getwd()), "\n")
trace(unlink, quote(if (any(grepl("xlsx_", x))) cat("unlink", x, "; f.xlsx present dans d :", file.exists(file.path(x, "f.xlsx")), "\n")),
      print = FALSE, where = baseenv())
r <- engine_ecrire_xlsx(read.csv(file.path(depot, "tests/donnees/donnees_ln.csv")), "C:f.xlsx")
untrace(unlink, where = baseenv())
cat("rendu:", r, "\n")
cat("f.xlsx dans getwd() apres :", file.exists(file.path(getwd(), "f.xlsx")), "\n")
