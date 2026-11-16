# Usage : Rscript sonde_574_lot_g.R <depot> <dossier_sondes> <fichier_moteur> [<cas>]
# #574, S1, lot G : decisions D-S1-35 et D-S1-36 du mainteneur (revue finale
# de S1, 16/11/2026).
#  - D-S1-35 (M1 d'audit) : balises <sheetData> toutes fermantes ou en
#    surnombre ; la position du refus cite la fermante en surnombre.
#  - D-S1-36 (/code-review) : commentaire, section CDATA, instruction de
#    traitement ou declaration de type de document dans xl/workbook.xml ou
#    xl/_rels/workbook.xml.rels (une <Relationship> commentee avant la vraie
#    faisait lire une autre feuille) ; temoin : _rels/.rels, non lue.
# Sans <cas> : chaque cas est rejoue dans son propre sous-processus Rscript
# (un arret n'interrompt pas la sonde), code de sortie releve.
# Chemin : openxlsx s'il est dans .libPaths() (R_LIBS), lecteur interne sinon.
# fichier_moteur : R/engine.R apres le correctif ; avant, la version extraite
# de la tete (git show 261c45e:R/engine.R > fichier).
# Serie de reference (tests/donnees/donnees_ln.csv) ; sigma_USP rendu par
# run_engine(premium, segment 1, annexe II, brutes) si la lecture et
# engine_lire_donnees_csv() reussissent. Lecture attendue ecrite apres
# "attendu" pour chaque cas.
a <- commandArgs(TRUE); depot <- normalizePath(a[1]); sd <- normalizePath(a[2]); moteur <- normalizePath(a[3])
CAS <- c(# D-S1-35
         "sheetdata-deux-fermantes", "sheetdata-une-fermante-seule", "sheetdata-fermante-en-surnombre",
         "sheetdata-vide-puis-fermante", "sheetdata-temoin",
         # D-S1-36
         "workbook-commentaire", "workbook-cdata", "workbook-pi", "workbook-doctype",
         "rels-commentaire-sheet2", "rels-cdata", "rels-pi", "rels-doctype",
         "temoin-dot-rels-commentaire", "temoin-workbook-declaration")
if (length(a) < 4) {
  self <- normalizePath(sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE)))
  for (c in CAS) {
    out <- suppressWarnings(system2(file.path(R.home("bin"), "Rscript"), shQuote(c(self, depot, sd, moteur, c)),
                                    stdout = TRUE, stderr = TRUE, timeout = 300))
    st <- attr(out, "status"); if (is.null(st)) st <- 0L
    cat(out, sep = "\n"); cat(sprintf("  [code de sortie : %d]\n\n", st))
  }
  quit(save = "no")
}
cas <- a[4]
setwd(depot); source("R/charger_moteur.R"); e <- charger_moteur(moteur, dans = NULL)
source(file.path(sd, "forge.R"))
chemin <- if (requireNamespace("openxlsx", quietly = TRUE))
  paste("openxlsx", as.character(packageVersion("openxlsx"))) else "interne"
cat(sprintf("[%s] chemin = %s ; moteur = %s\n", cas, chemin, basename(moteur)))
lire_serie <- function(f) {
  w <- character(0)
  df <- tryCatch(withCallingHandlers(e$engine_lire_xlsx(f),
                   warning = function(x) { w <<- c(w, conditionMessage(x)); invokeRestart("muffleWarning") }),
                 error = function(err) err)
  if (length(w)) cat(sprintf("  avertissements R : %d (premier : %s)\n", length(w), substr(w[1], 1, 60)))
  if (inherits(df, "error")) {
    cat(sprintf("  ERREUR classe = %s\n  message = %s\n\n", class(df)[1], conditionMessage(df))); return(invisible(NULL))
  }
  cat(sprintf("  lu : %d x %d ; noms = %s ; B2 lu = %s\n", nrow(df), ncol(df),
              encodeString(paste(names(df), collapse = ",")), encodeString(format(df[[2]][1], digits = 15), quote = '"')))
  r <- e$engine_lire_donnees_csv(df)
  cat(sprintf("  engine_lire_donnees_csv : ok = %s\n", r$ok))
  if (r$ok) {
    cat(sprintf("  xt retenu : %s\n", paste(format(r$xt, digits = 15), collapse = " ")))
    res <- tryCatch(e$run_engine(xt = r$xt, yt = r$yt, methode = "premium", segment = 1, annexe = "II", nature_donnees = "brutes"),
                    error = function(err) err)
    if (inherits(res, "error")) cat("  run_engine : ERREUR", conditionMessage(res), "\n")
    else if (isTRUE(res$ok)) cat(sprintf("  run_engine : ok = TRUE, sigma_USP = %.10f\n", res$parametre$sigma_usp))
    else cat("  run_engine : ok = FALSE ;", head(res$validation$erreurs, 2), sep = "\n    ")
  } else cat("  erreurs :", r$erreurs, sep = "\n    ")
  cat("\n")
}
# Retouche d'une partie d'un classeur forge (sub fixe sur son texte) ; sheet2 :
# ajoute xl/worksheets/sheet2.xml, copie de sheet1.xml ou B2 vaut 999.
retoucher <- function(f, partie, de, vers, sheet2 = FALSE) {
  d <- tempfile("lotg_"); dir.create(d); utils::unzip(f, exdir = d)
  lire_p <- function(p) rawToChar(readBin(file.path(d, p), "raw", file.info(file.path(d, p))$size))
  ecr_p <- function(p, x) writeBin(charToRaw(x), file.path(d, p))
  x <- lire_p(partie); stopifnot(grepl(de, x, fixed = TRUE)); ecr_p(partie, sub(de, vers, x, fixed = TRUE))
  if (sheet2) {
    ecr_p("xl/worksheets/sheet2.xml", sub("<v>104.2</v>", "<v>999</v>", lire_p("xl/worksheets/sheet1.xml"), fixed = TRUE))
    ecr_p("[Content_Types].xml", sub("</Types>", '<Override PartName="/xl/worksheets/sheet2.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/></Types>',
                                     lire_p("[Content_Types].xml"), fixed = TRUE))
  }
  od <- setwd(d); on.exit(setwd(od)); unlink(f)
  stopifnot(system2("zip", c("-r9Xq", shQuote(f), "[Content_Types].xml", "_rels", "xl")) == 0); f
}
WB <- "xl/workbook.xml"; RL <- "xl/_rels/workbook.xml.rels"
DECL <- '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
REL1 <- '<Relationship Id="rId1"'
switch(cas,
  "sheetdata-deux-fermantes" = {
    cat("  feuille : </sheetData>...</sheetData> (aucune ouvrante) ; attendu apres : refus R3 citant les deux </sheetData> ; avant : lu en interne, \"Fichier vide\" par openxlsx\n")
    lire_serie(retoucher(forger(serie()), "xl/worksheets/sheet1.xml", "<sheetData>", "</sheetData>")) },
  "sheetdata-une-fermante-seule" = {
    cat("  feuille : </sheetData>... (fermante seule en tete, aucune a la fin) ; attendu apres : refus R3 citant </sheetData>\n")
    f <- retoucher(forger(serie()), "xl/worksheets/sheet1.xml", "<sheetData>", "</sheetData>")
    lire_serie(retoucher(f, "xl/worksheets/sheet1.xml", "</sheetData></worksheet>", "</worksheet>")) },
  "sheetdata-fermante-en-surnombre" = {
    cat("  feuille : <sheetData>...</sheetData></sheetData> ; attendu apres : refus R3 citant la seconde </sheetData> (avant : refus citant l'ouvrante)\n")
    lire_serie(retoucher(forger(serie()), "xl/worksheets/sheet1.xml", "</sheetData>", "</sheetData></sheetData>")) },
  "sheetdata-vide-puis-fermante" = {
    cat("  feuille : <sheetData/>...</sheetData> ; attendu apres : refus R3 citant <sheetData/> et </sheetData>\n")
    lire_serie(retoucher(forger(serie()), "xl/worksheets/sheet1.xml", "<sheetData>", "<sheetData/>")) },
  "sheetdata-temoin" = {
    cat("  feuille : <sheetData>...</sheetData> ; attendu : 104.2, sigma_USP de la serie\n")
    lire_serie(forger(serie())) },
  "workbook-commentaire" = {
    cat("  xl/workbook.xml : <sheets><!-- x --><sheet .../> ; attendu apres : refus R2 nommant xl/workbook.xml\n")
    lire_serie(retoucher(forger(serie()), WB, "<sheets>", "<sheets><!-- x -->")) },
  "workbook-cdata" = {
    cat("  xl/workbook.xml : <![CDATA[x]]> apres </sheets> ; attendu apres : refus R2 nommant xl/workbook.xml\n")
    lire_serie(retoucher(forger(serie()), WB, "</sheets>", "</sheets><![CDATA[x]]>")) },
  "workbook-pi" = {
    cat("  xl/workbook.xml : <?foo bar?> apres la declaration ; attendu apres : refus R2 nommant xl/workbook.xml\n")
    lire_serie(retoucher(forger(serie()), WB, DECL, paste0(DECL, "<?foo bar?>"))) },
  "workbook-doctype" = {
    cat("  xl/workbook.xml : <!DOCTYPE workbook> apres la declaration ; attendu apres : refus R2 nommant xl/workbook.xml\n")
    lire_serie(retoucher(forger(serie()), WB, DECL, paste0(DECL, "<!DOCTYPE workbook>"))) },
  "rels-commentaire-sheet2" = {
    cat("  xl/_rels/workbook.xml.rels : <!-- <Relationship Id=\"rId1\" ... Target=\"worksheets/sheet2.xml\"/> --> avant la vraie ; sheet2.xml : B2 = 999 ; attendu apres : refus R2 nommant xl/_rels/workbook.xml.rels ; avant : sheet2 lue (999)\n")
    lire_serie(retoucher(forger(serie()), RL, REL1,
                         paste0('<!-- <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet2.xml"/> -->', REL1),
                         sheet2 = TRUE)) },
  "rels-cdata" = {
    cat("  xl/_rels/workbook.xml.rels : <![CDATA[x]]> avant la relation ; attendu apres : refus R2 nommant xl/_rels/workbook.xml.rels\n")
    lire_serie(retoucher(forger(serie()), RL, REL1, paste0("<![CDATA[x]]>", REL1))) },
  "rels-pi" = {
    cat("  xl/_rels/workbook.xml.rels : <?foo bar?> apres la declaration ; attendu apres : refus R2 nommant xl/_rels/workbook.xml.rels\n")
    lire_serie(retoucher(forger(serie()), RL, DECL, paste0(DECL, "<?foo bar?>"))) },
  "rels-doctype" = {
    cat("  xl/_rels/workbook.xml.rels : <!DOCTYPE Relationships> apres la declaration ; attendu apres : refus R2 nommant xl/_rels/workbook.xml.rels\n")
    lire_serie(retoucher(forger(serie()), RL, DECL, paste0(DECL, "<!DOCTYPE Relationships>"))) },
  "temoin-dot-rels-commentaire" = {
    cat("  _rels/.rels : <!-- x --> avant la relation (partie non lue par le lecteur) ; attendu : admis, 104.2\n")
    lire_serie(retoucher(forger(serie()), "_rels/.rels", REL1, paste0("<!-- x -->", REL1))) },
  "temoin-workbook-declaration" = {
    cat("  xl/workbook.xml et ses relations : declaration XML initiale seule ; attendu : admis, 104.2\n")
    lire_serie(forger(serie())) })
