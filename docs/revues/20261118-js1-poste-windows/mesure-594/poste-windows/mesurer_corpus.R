# Mesure du corpus d'acceptation de JS1, etape 2 (ii), poste Windows.
# Usage, depuis la racine du depot :
#   Rscript docs/revues/20261118-js1-poste-windows/mesure-594/poste-windows/mesurer_corpus.R <dossier des classeurs> ; openxlsx present (chemin openxlsx) ou masque par R_LIBS_USER vide
# (chemin de repli). Moteur charge par charger_moteur() (ADR 0016).
dossier <- commandArgs(TRUE)[1]
source("R/charger_moteur.R"); charger_moteur()
cat("HEAD :", system2("git", c("rev-parse", "HEAD"), stdout = TRUE), "\n")
avec <- requireNamespace("openxlsx", quietly = TRUE)
cat("chemin :", if (avec) paste("openxlsx", packageVersion("openxlsx")) else "repli (openxlsx absent)", "\n")
ref <- read.csv("tests/donnees/donnees_ln.csv"); ref[] <- lapply(ref, as.numeric)
tri_ref <- read.csv("tests/donnees/triangle_mw.csv")
tri_attendu <- engine_lire_triangle(tri_ref)
num3 <- function(d) unname(lapply(d[c("t", "xt", "yt")], as.numeric))
notes_b <- c(" debut blanc", "fin blanche ", " deux ", "sans", NA, "x ", " y", "z")
# Structure XML de la feuille : chaines partagees ou en ligne, xml:space
sonde <- function(f) {
  d <- tempfile(); on.exit(unlink(d, recursive = TRUE))
  utils::unzip(f, exdir = d)
  s <- paste(readLines(file.path(d, "xl/worksheets/sheet1.xml"), warn = FALSE, encoding = "UTF-8"), collapse = "")
  ss <- file.path(d, "xl/sharedStrings.xml")
  sst <- if (file.exists(ss)) paste(readLines(ss, warn = FALSE, encoding = "UTF-8"), collapse = "") else ""
  sprintf("t=\"s\" : %d ; inlineStr : %d ; t=\"str\" : %d ; xml:space (feuille / sst) : %d / %d",
          lengths(regmatches(s, gregexpr('t="s"', s))), lengths(regmatches(s, gregexpr('t="inlineStr"', s))),
          lengths(regmatches(s, gregexpr('t="str"', s))),
          lengths(regmatches(s, gregexpr("xml:space", s))), lengths(regmatches(sst, gregexpr("xml:space", sst))))
}
for (f in sort(list.files(dossier, pattern = "\\.xlsx$", full.names = TRUE))) {
  nom <- basename(f)
  cat(sprintf("\n%s\n  md5 %s ; %s\n", nom, unname(tools::md5sum(f)), sonde(f)))
  # Lecture directe par openxlsx (series), y compris des classeurs que le
  # moteur refuse : c'est elle qui montre la colonne note faussee (#594)
  if (avec && !grepl("triangle", nom)) {
    o <- openxlsx::read.xlsx(f, sheet = 1)
    nb <- if (grepl("_blancs", nom)) notes_b else trimws(notes_b)
    cat("  openxlsx::read.xlsx direct : t/xt/yt identiques =", identical(num3(o), unname(as.list(ref))),
        "; note =", paste(sprintf("[%s]", o$note), collapse = " "), "; note juste =", identical(o$note, nb), "\n")
  }
  r <- tryCatch(engine_lire_xlsx(f), error = function(e) e)
  if (inherits(r, "condition")) {
    cat("  moteur : refus [", paste(class(r), collapse = ", "), "] ", conditionMessage(r), "\n", sep = "")
    next
  }
  if (grepl("triangle", nom)) {
    lt <- engine_lire_triangle(r)
    cat("  moteur : lu ; engine_lire_triangle ok =", lt$ok, "; triangle identique a celui du CSV (identical) =",
        identical(lt$triangle, tri_attendu$triangle), "\n")
    if (!lt$ok) cat("  erreurs :", paste(lt$erreurs, collapse = " | "), "\n")
  } else {
    ld <- engine_lire_donnees_csv(r)
    cat("  moteur : lu ; t/xt/yt identiques au CSV (identical) =", identical(num3(r), unname(as.list(ref))),
        "; engine_lire_donnees_csv ok =", ld$ok, ", n =", ld$n,
        "; avertissements :", if (length(ld$avertissements_lecture)) paste(ld$avertissements_lecture, collapse = " | ") else "aucun", "\n")
  }
}
