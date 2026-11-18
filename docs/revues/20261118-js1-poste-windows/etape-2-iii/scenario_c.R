# Etape 2 (iii) de JS1 : engine_ecrire_xlsx(df, "C:f.xlsx") sous Windows.
# Usage : Rscript scenario_c.R <racine du depot>, depuis un dossier de travail
# quelconque du lecteur C:. Les avertissements sont releves sans interrompre
# l'appel (withCallingHandlers) ; une erreur est relevee comme refus.
depot <- normalizePath(commandArgs(TRUE)[1], winslash = "/")  # racine du depot
source(file.path(depot, "R/charger_moteur.R"))
charger_moteur(file.path(depot, "R/engine.R"))
cat("HEAD :", system2("git", c("-C", depot, "rev-parse", "HEAD"), stdout = TRUE), "\n")
cat("md5 R/engine.R :", unname(tools::md5sum(file.path(depot, "R/engine.R"))), "\n")
cat("R :", R.version.string, "; openxlsx :", if (requireNamespace("openxlsx", quietly = TRUE)) as.character(packageVersion("openxlsx")) else "absent",
    "; zip :", if (requireNamespace("zip", quietly = TRUE)) as.character(packageVersion("zip")) else "absent", "\n")
cat("tempdir() :", tempdir(), "(lecteur", substr(tempdir(), 1, 2), ")\n")
cat("getwd() avant :", getwd(), "\n")
cat("normalizePath(\"C:\") avant :", normalizePath("C:", mustWork = FALSE), "\n")
cat("normalizePath(\"C:f.xlsx\") avant :", normalizePath("C:f.xlsx", mustWork = FALSE), "\n")
cat("file.exists(\"C:f.xlsx\") avant :", file.exists("C:f.xlsx"), "\n")
df <- read.csv(file.path(depot, "tests/donnees/donnees_ln.csv"))
avert <- character(0)
res <- tryCatch(withCallingHandlers(list(valeur = engine_ecrire_xlsx(df, "C:f.xlsx")),
                                    warning = function(w) { avert <<- c(avert, conditionMessage(w)); invokeRestart("muffleWarning") }),
                error = function(e) list(erreur = e))
cat("Avertissements :", if (length(avert)) paste(avert, collapse = " | ") else "aucun", "\n")
if (!is.null(res$erreur)) {
  cat("Refus : classe", paste(class(res$erreur), collapse = ", "), "\n  message :", conditionMessage(res$erreur), "\n")
} else {
  cat("Valeur rendue :\n"); str(res$valeur)
}
cat("getwd() apres :", getwd(), "\n")
cands <- unique(c(file.path(getwd(), "f.xlsx"), file.path(normalizePath("C:", mustWork = FALSE), "f.xlsx"),
                  "C:/f.xlsx", file.path(depot, "f.xlsx")))
for (f in cands) cat("existe", f, ":", file.exists(f), if (file.exists(f)) paste("(", file.size(f), "octets, md5", tools::md5sum(f), ")"), "\n")
