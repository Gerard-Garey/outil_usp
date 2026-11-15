# Usage : Rscript sonde_574_lot_b.R <depot> <dossier_sondes> <fichier_moteur> [<cas>]
# #574, S1 etape 5, lot B : regles R3 (structure du bloc <sheetData>), R4
# (attributs de <c>), R5 (limites d'une feuille), R6 (reference unique),
# R11 (etendue des cellules a valeur) du contrat ferme du lecteur de
# classeur, et dimensionnement du lecteur interne sur les seules cellules a
# valeur ; reprise apres l'audit leger et l'avis d'actuary sur le lot B :
# texte du segment de cellule (Q1), references en minuscules refusees
# (D-S1-9), regle R6b de l'ordre de lecture (D-S1-11), feuille sans balise.
# Sans <cas> : chaque cas est rejoue dans son propre sous-processus Rscript
# (un arret n'interrompt pas la sonde), code de sortie releve.
# Chemin : openxlsx s'il est dans .libPaths() (R_LIBS), lecteur interne sinon.
# fichier_moteur : R/engine.R apres le correctif ; avant, la version extraite
# de 1818b4d (git show 1818b4d:R/engine.R > fichier).
a <- commandArgs(TRUE); depot <- normalizePath(a[1]); sd <- normalizePath(a[2]); moteur <- normalizePath(a[3])
CAS <- c("574-3a-xfd-valeur", "574-3b-a99999999999", "574-m1-doublon", "r6-doublon-casse", "r4-xr-z9",
         "r3-hors-bloc", "r3-deux-blocs", "574-4-en-ligne", "r3-is-r", "r3-is-rph", "r3-x-c",
         "r3-ligne-t-s", "r3-ligne-t-s-hors-table", "r3-apres-bloc-v", "r3-extlst-v", "r3-is-blanc", "r3-fin-v-blanc",
         "r3-sheetdata-blanc", "r4-s-r", "r5-xfe", "r11-1e6", "r11-1e6-plus", "r11-1e7",
         "entete-t", "entete-t-s", "indente-is", "ordre-l1", "ordre-row1-fin", "ordre-rows", "minuscule", "v-space",
         "feuille-vide", "feuille-sans-balise",
         "temoin-vide-xfd", "temoin-v-blanc", "temoin-forme-legale", "temoin-ecrit-par-moteur", "temoin-reference")
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
cat(sprintf("[%s] chemin = %s ; moteur = %s\n", cas, chemin, basename(dirname(moteur))))
# Retouche texte de la feuille : premiere occurrence de motif remplacee par
# par ; motif NULL : la feuille entiere est remplacee par par.
retoucher <- function(f, motif, par) {
  d <- tempfile("ret_"); utils::unzip(f, exdir = d)
  p <- file.path(d, "xl/worksheets/sheet1.xml"); s <- readChar(p, file.info(p)$size, useBytes = TRUE)
  if (is.null(motif)) { unlink(p); writeBin(charToRaw(par), p) } else {
    stopifnot(grepl(motif, s, fixed = TRUE))
    writeChar(sub(motif, par, s, fixed = TRUE), p, eos = NULL, useBytes = TRUE) }
  od <- setwd(d); on.exit(setwd(od)); unlink(f)
  stopifnot(system2("zip", c("-r9Xq", shQuote(f), "[Content_Types].xml", "_rels", "xl")) == 0)
  f
}
lire_serie <- function(f, montrer = TRUE) {
  w <- character(0)
  t0 <- proc.time()[["elapsed"]]
  df <- tryCatch(withCallingHandlers(e$engine_lire_xlsx(f),
                   warning = function(x) { w <<- c(w, conditionMessage(x)); invokeRestart("muffleWarning") }),
                 error = function(err) err)
  duree <- proc.time()[["elapsed"]] - t0
  if (length(w)) cat(sprintf("  avertissements R : %d (premier : %s)\n", length(w), substr(w[1], 1, 60)))
  if (inherits(df, "error")) {
    cat(sprintf("  ERREUR classe = %s (%.2f s)\n  message = %s\n", class(df)[1], duree, conditionMessage(df))); return(invisible(NULL))
  }
  if (!montrer) { cat(sprintf("  lu : %d x %d (%.2f s)\n", nrow(df), ncol(df), duree)); return(invisible(df)) }
  r <- e$engine_lire_donnees_csv(df)
  cat(sprintf("  lu : %d x %d (%.2f s) ; engine_lire_donnees_csv : ok = %s\n", nrow(df), ncol(df), duree, r$ok))
  if (r$ok) cat("  xt =", format(r$xt, digits = 10), "\n  yt =", format(r$yt, digits = 10), "\n")
  else cat("  erreurs :", r$erreurs, sep = "\n    ")
  cat("\n")
}
L <- serie()
b2 <- function(x) { l <- L; l[2] <- ligne(2, cn("A2", 1), x, cn("C2", 68.97)); l }
ext <- function(...) c(L, ...)
switch(cas,
  "574-3a-xfd-valeur" = lire_serie(forger(ext('<row r="1048576"><c r="XFD1048576"><v>1</v></c></row>'))),
  "574-3b-a99999999999" = lire_serie(forger(ext('<row r="99999999999"><c r="A99999999999"><v>1</v></c></row>'))),
  "574-m1-doublon" = lire_serie(forger(b2('<c r="B2"><v>104.2</v></c><c r="B2"><v>999</v></c>'))),
  "r6-doublon-casse" = lire_serie(forger(b2('<c r="B2"><v>104.2</v></c><c r="b2"><v>999</v></c>'))),
  "r4-xr-z9" = lire_serie(forger(b2('<c x:r="Z9" r="B2"><v>104.2</v></c>'))),
  "r3-hors-bloc" = lire_serie(retoucher(forger(L), "</sheetData>", '</sheetData><c r="D2"><v>7</v></c>')),
  "r3-deux-blocs" = lire_serie(retoucher(forger(L), "</sheetData>", '</sheetData><sheetData><row r="2"><c r="D2"><v>7</v></c></row></sheetData>')),
  "574-4-en-ligne" = for (n in c(1000, 2000, 4000, 16000)) {
    blocs <- paste(rep('<x:rPh sb="0" eb="1">', n), collapse = "")
    f <- forger(b2(paste0('<c r="B2" t="inlineStr"><is><t>11</t>', blocs, '</is></c>')))
    t0 <- proc.time()[["elapsed"]]
    df <- tryCatch(e$engine_lire_xlsx(f), error = function(err) err)
    cat(sprintf("  n = %5d : %.2f s ; %s\n", n, proc.time()[["elapsed"]] - t0,
                if (inherits(df, "error")) paste("ERREUR", class(df)[1], substr(conditionMessage(df), 1, 200))
                else paste("B2 lu =", encodeString(as.character(df$xt[1])))))
  },
  "r3-is-r" = lire_serie(forger(b2('<c r="B2" t="inlineStr"><is><r><t>11</t></r><r><t>.5</t></r></is></c>'))),
  "r3-is-rph" = lire_serie(forger(b2('<c r="B2" t="inlineStr"><is><t>11.5</t><rPh sb="0" eb="1"><t>7</t></rPh></is></c>'))),
  "r3-x-c" = lire_serie(forger(b2('<x:c r="B2" xmlns:x="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><x:v>11.5</x:v></x:c>'))),
  # attribut t de la ligne suivante, lu par openxlsx comme le type de la
  # derniere cellule de la ligne precedente (C2, sans t)
  "r3-ligne-t-s" = { l <- L; l[2] <- ligne(2, cn("A2", 1), cn("B2", 104.2), cn("C2", 0)); l[3] <- sub('<row r="3">', '<row r="3" t="s">', l[3])
                     lire_serie(forger(l, partagees = "<si><t>11.5</t></si>")) },
  "r3-ligne-t-s-hors-table" = { l <- L; l[2] <- ligne(2, cn("A2", 1), cn("B2", 104.2), cn("C2", 5)); l[3] <- sub('<row r="3">', '<row r="3" t="s">', l[3])
                                lire_serie(forger(l, partagees = "<si><t>11.5</t></si>")) },
  # derniere cellule sans valeur ; <v> dans une balise placee apres le bloc
  "r3-apres-bloc-v" = lire_serie(retoucher(forger(ext('<row r="12"><c r="B12" s="1"/></row>')), "</sheetData>",
                                           '</sheetData><foo xmlns="urn:x"><v>9</v></foo>')),
  "r3-extlst-v" = lire_serie(forger(b2('<c r="B2"><extLst><ext uri="u"><v>9</v></ext></extLst><v>104.2</v></c>'))),
  "r3-is-blanc" = lire_serie(forger(b2('<c r="B2" t="inlineStr"><is> <t>104.2</t></is></c>'))),
  "r3-fin-v-blanc" = lire_serie(forger(b2('<c r="B2"><v>104.2</v ></c>'))),
  "r3-sheetdata-blanc" = lire_serie(retoucher(forger(L), "<sheetData>", "<sheetData >")),
  "r4-s-r" = lire_serie(forger(b2('<c s="xr=_D2" r="B2"><v>104.2</v></c>'))),
  "r5-xfe" = lire_serie(forger(ext('<row r="10"><c r="XFE10" s="1"/></row>'))),
  # R11 : derniere ligne x derniere colonne des cellules a valeur ; J = 10
  "r11-1e6" = lire_serie(forger(ext('<row r="100000"><c r="J100000"><v>1</v></c></row>')), montrer = FALSE),
  "r11-1e6-plus" = lire_serie(forger(ext('<row r="100000"><c r="K100000"><v>1</v></c></row>')), montrer = FALSE),
  "r11-1e7" = lire_serie(forger(ext('<row r="100000"><c r="CV100000"><v>1</v></c></row>')), montrer = FALSE),
  # Texte portant " t=" apres la derniere cellule (C9, nombre sans t) : pied
  # ou en-tete de page (avis d'actuary sur le lot B, Q1 ; decision D-S1-10, a)
  "entete-t" = lire_serie(retoucher(forger(L), "</sheetData>", '</sheetData><headerFooter><oddHeader>&amp;CMontant t=1</oddHeader></headerFooter>')),
  "entete-t-s" = lire_serie(retoucher(forger(L), "</sheetData>", '</sheetData><headerFooter><oddHeader>&amp;C t="s"</oddHeader></headerFooter>')),
  # Chaine en ligne indentee (decision D-S1-10, b)
  "indente-is" = lire_serie(forger(b2('<c r="B2" t="inlineStr">\n  <is>\n    <t>104.2</t>\n  </is>\n</c>'))),
  # Ordre de lecture (regle R6b, decision D-S1-11)
  "ordre-l1" = { l <- L; l[1] <- ligne(1, ci("A1", "t"), ci("C1", "yt"), ci("B1", "xt")); lire_serie(forger(l)) },
  "ordre-row1-fin" = lire_serie(forger(c(L[-1], L[1]))),
  "ordre-rows" = lire_serie(forger(L[c(1, 3, 2, 4:9)])),
  # Reference en minuscules (decision D-S1-9)
  "minuscule" = lire_serie(forger(b2('<c r="b2"><v>104.2</v></c>'))),
  # <v xml:space="preserve"> : forme XML legale (decision D-S1-10, d)
  "v-space" = lire_serie(forger(b2('<c r="B2"><v xml:space="preserve">104.2</v></c>'))),
  # Feuille vide (partie de 0 octet) ou sans aucune balise (audit leger)
  "feuille-vide" = lire_serie(retoucher(forger(L), NULL, "")),
  "feuille-sans-balise" = lire_serie(retoucher(forger(L), NULL, "abc")),
  "temoin-vide-xfd" = lire_serie(forger(ext('<row r="1048576"><c r="XFD1048576" s="1"/></row>'))),
  "temoin-v-blanc" = lire_serie(forger(b2('<c r="B2"><v >104.2</v></c>'))),
  # Forme XML legale : attributs de ligne, s, cm, vm, ph, formule partagee,
  # <v xml:space>, <extLst> de ligne au contenu prefixe, cellules mises en
  # forme sans valeur, contenu apres le bloc
  "temoin-forme-legale" = { l <- L
    l[1] <- sub('<row r="1">', '<row r="1" spans="1:3" s="2" customFormat="1" x14ac:dyDescent="0.25">', l[1])
    l[2] <- ligne(2, '<c r="A2" s="1" t="n" cm="1"><v>1</v></c>', '<c r="B2" vm="1" ph="1"><f t="shared" ref="B2:B3" si="0">1+1</f><v xml:space="preserve">104.2</v></c>',
                  cn("C2", 68.97), '<c r="D2" s="3"/>')
    l[3] <- sub("</row>", '<extLst><ext uri="{x}" xmlns:x14="urn:x14"><x14:foo a="1"><x14:v>9</x14:v></x14:foo></ext></extLst></row>', l[3])
    lire_serie(retoucher(forger(l), "</sheetData>", '</sheetData><mergeCells count="1"><mergeCell ref="E1:F1"/></mergeCells><conditionalFormatting sqref="B2"><cfRule type="expression" priority="1"><formula>B2&gt;0</formula></cfRule></conditionalFormatting><pageMargins left="0.7" right="0.7" top="0.75" bottom="0.75" header="0.3" footer="0.3"/>')) },
  "temoin-ecrit-par-moteur" = { f <- tempfile(fileext = ".xlsx")
    sans <- function(expr) { env <- environment(e$run_engine); assign("requireNamespace", function(package, ...) FALSE, envir = env)
                             on.exit(rm("requireNamespace", envir = env)); force(expr) }
    sans(e$engine_ecrire_xlsx(LN, f)); lire_serie(f) },
  "temoin-reference" = lire_serie(forger(L)))
