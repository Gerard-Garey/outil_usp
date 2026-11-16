# Usage : Rscript sonde_574_lot_d.R <depot> <dossier_sondes> <fichier_moteur> [<cas>]
# #574, S1 etape 5, lot D : regle R9 (structure de la table des chaines
# partagees) du contrat ferme du lecteur de classeur, decompte des chaines
# repris par R10, et positions de R10 limitees aux cinq premieres ; cas q1 a
# q3 de l'avis d'actuary sur le lot D, <phoneticPr></phoneticPr> (reserve b),
# cout des retraits de blocs de X1 (guillemet non ferme).
# Sans <cas> : chaque cas est rejoue dans son propre sous-processus Rscript
# (un arret n'interrompt pas la sonde), code de sortie releve.
# Chemin : openxlsx s'il est dans .libPaths() (R_LIBS), lecteur interne sinon.
# fichier_moteur : R/engine.R apres le correctif ; avant, la version extraite
# de 1c206a7 (git show 1c206a7:R/engine.R > fichier).
# Chaque cas forge la serie de reference (tests/donnees/donnees_ln.csv) dont
# la cellule B2 (xt de la premiere annee, 104.2) est une cellule t="s" qui
# renvoie a la table du cas ; sigma_USP rendu par run_engine(premium,
# segment 1, annexe II, brutes) si la lecture et engine_lire_donnees_csv()
# reussissent. Valeur juste de B2 : celle que donne la table lue selon le
# format (une chaine par <si>, texte des <t> hors phonetique) ; elle est
# ecrite apres "attendu" pour chaque cas.
a <- commandArgs(TRUE); depot <- normalizePath(a[1]); sd <- normalizePath(a[2]); moteur <- normalizePath(a[3])
RPR <- "<si><r><rPr><b/></rPr><t>a</t></r></si>"
# cas = list(table, indice de B2, valeur attendue)
T9 <- list(
  # formes de #574 et du par. 8 de l'avis amont
  "574-1-xsi-mele" = list('<x:si><x:t>9</x:t></x:si><si><t>11.5</t></si>', 0, "9"),
  "574-2-r-puis-xrph" = list('<si><r><rPr><b/></rPr><t>1</t></r><r><t>1.5</t></r><x:rPh sb="0" eb="1"><t>7</t></x:rPh></si>', 0, "11.5"),
  "xsi-seul" = list('<x:si><x:t>11.5</x:t></x:si>', 0, "11.5"),
  "xrph-auto" = list('<si><t>11.5</t><x:rPh sb="0" eb="1"/></si>', 0, "11.5"),
  "xrph-apres-t" = list('<si><t>11.5</t><x:rPh sb="0" eb="1"><t>7</t></x:rPh></si>', 0, "11.5"),
  "si-auto-indice-0" = list('<si/><si><t>9</t></si>', 0, "(chaine vide)"),
  "si-auto-indice-1" = list('<si/><si><t>9</t></si>', 1, "9"),
  # formes du schema lues autrement par openxlsx (mesure)
  "rph-second-table-rpr" = list(paste0('<si><t>11</t><rPh sb="0" eb="1"><t>a</t></rPh><rPh sb="1" eb="2"><t>7</t></rPh></si>', RPR), 0, "11"),
  "rph-sans-t" = list('<si><rPh sb="0" eb="1"><t>1</t></rPh><rPh sb="1" eb="2"><t>7</t></rPh></si>', 0, "(chaine vide)"),
  "t-vide-dans-r" = list('<si><r><rPr><b/></rPr><t>1</t></r><r><t/></r><r><t>5</t></r></si>', 0, "15"),
  "rpr-element-tz" = list('<si><r><rPr><b/><tz val="1">9</tz></rPr><t>1</t></r></si>', 0, "1"),
  # autres formes hors du contrat
  "rphx" = list('<si><t>11.5</t><rPhX sb="0"/><phoneticPr fontId="1" type="noConversion"/></si>', 0, "11.5"),
  "tab" = list('<si><t>11.5</t><tab/><tabx a="1"/></si>', 0, "11.5"),
  "x-r-t" = list('<si><x:r><x:rPr><x:b/></x:rPr><t>1</t></x:r><x:r><t>1.5</t></x:r></si><si><r><rPr><b/></rPr><t>a</t></r></si>', 0, "11.5"),
  "x-r-x-t" = list('<si><x:r><x:rPr><x:b/></x:rPr><x:t>1</x:t></x:r><x:r><x:t>1.5</x:t></x:r></si><si><r><rPr><b/></rPr><t>a</t></r></si>', 0, "11.5"),
  "x-tab" = list('<si><t>11.5</t><x:tab/></si>', 0, "11.5"),
  "si-blanc" = list('<si ><t>11.5</t></si><si><t>9</t></si>', 0, "11.5"),
  "si-fermante-blanc" = list('<si><t>11.5</t></si ><si><t>9</t></si>', 0, "11.5"),
  "texte-hors-t" = list('<si><t>11.5</t>9</si>', 0, "11.5"),
  "si-dans-extlst" = list('<si><t>9</t></si><extLst><ext uri="u"><si><t>7</t></si></ext></extLst><si><t>11.5</t></si>', 1, "11.5"),
  "prefixe-dans-extlst" = list('<si><t>11.5</t></si><extLst><ext uri="u"><x:a/></ext></extLst>', 0, "11.5"),
  "SI-majuscules" = list('<SI><t>9</t></SI><si><t>11.5</t></si>', 0, "11.5"),
  "t-apres-rph" = list('<si><rPh sb="0" eb="1"><t>Z</t></rPh><t>11.5</t></si>', 0, "11.5"),
  # temoins (forme du contrat)
  "ok-simple" = list('<si><t>11.5</t></si>', 0, "11.5"),
  "ok-riche-excel" = list('<si><r><rPr><b/><sz val="11"/><color rgb="FFFF0000"/><rFont val="Calibri"/><family val="2"/><scheme val="minor"/></rPr><t>1</t></r><r><rPr><sz val="11"/></rPr><t xml:space="preserve">1.5</t></r></si>', 0, "11.5"),
  "ok-phonetique" = list('<si><t>11.5</t><rPh sb="0" eb="1"><t>ZZ</t></rPh><phoneticPr fontId="1" type="noConversion"/></si>', 0, "11.5"),
  "ok-rph-second-sans-rpr" = list('<si><t>11.5</t><rPh sb="0" eb="1"><t>a</t></rPh><rPh sb="1" eb="2"><t>7</t></rPh></si>', 0, "11.5"),
  "ok-preserve" = list('<si><t xml:space="preserve">11.5</t></si>', 0, "11.5"),
  "ok-vides-indices" = list('<si></si><si><t/></si><si>\n <t>11.5</t>\n</si>', 2, "11.5"),
  "ok-extlst" = list('<si><t>11.5</t></si><extLst><ext uri="u"><a b="1">z</a></ext></extLst>', 0, "11.5"),
  "ok-phoneticpr-ouvert-ferme" = list('<si><t>11.5</t><rPh sb="0" eb="1"><t>a</t></rPh><phoneticPr fontId="1" type="noConversion"></phoneticPr></si>', 0, "11.5"),
  # cas de l'avis d'actuary sur le lot D (Q1 a Q3)
  "q1-texte-dans-b" = list('<si><r><rPr><b>9</b></rPr><t>1</t></r></si>', 0, "1"),
  "q2-japonais-rpr" = list('<si><r><rPr><b/></rPr><t>1</t></r><r><t>1.5</t></r><rPh sb="0" eb="1"><t>a</t></rPh><rPh sb="1" eb="2"><t>7</t></rPh><phoneticPr fontId="1"/></si>', 0, "11.5"),
  "q2-rpr-dans-extlst" = list('<si><t>11</t><rPh sb="0" eb="1"><t>a</t></rPh><rPh sb="1" eb="2"><t>7</t></rPh></si><extLst><ext uri="u"><rPr></rPr></ext></extLst>', 0, "11"),
  "q3-ext-x14" = list('<si><t>11.5</t></si><extLst><ext uri="u" xmlns:x14="urn:x14"><x14:a/></ext></extLst>', 0, "11.5"))
AUTRES <- c("574-4-n1000", "574-4-n2000", "574-4-n4000", "574-4-n16000", "x1-rph-guillemet-n16000",
            "x1-r-guillemet-n16000", "x-sst-racine", "temoin-ecrit-par-moteur",
            "temoin-openxlsx-write", "r10-cinq-positions")
CAS <- c(names(T9), AUTRES)
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
  t0 <- proc.time()[["elapsed"]]
  df <- tryCatch(withCallingHandlers(e$engine_lire_xlsx(f),
                   warning = function(x) { w <<- c(w, conditionMessage(x)); invokeRestart("muffleWarning") }),
                 error = function(err) err)
  cat(sprintf("  duree de lecture : %.2f s\n", proc.time()[["elapsed"]] - t0))
  if (length(w)) cat(sprintf("  avertissements R : %d (premier : %s)\n", length(w), substr(w[1], 1, 60)))
  if (inherits(df, "error")) {
    cat(sprintf("  ERREUR classe = %s\n  message = %s\n\n", class(df)[1], conditionMessage(df))); return(invisible(NULL))
  }
  cat(sprintf("  lu : %d x %d ; noms = %s ; B2 lu = %s (classe de xt : %s)\n", nrow(df), ncol(df),
              paste(names(df), collapse = ","), encodeString(format(df[[2]][1], digits = 15), quote = '"'), class(df[[2]])[1]))
  r <- e$engine_lire_donnees_csv(df)
  cat(sprintf("  engine_lire_donnees_csv : ok = %s\n", r$ok))
  if (r$ok) {
    res <- tryCatch(e$run_engine(xt = r$xt, yt = r$yt, methode = "premium", segment = 1, annexe = "II", nature_donnees = "brutes"),
                    error = function(err) err)
    if (inherits(res, "error")) cat("  run_engine : ERREUR", conditionMessage(res), "\n")
    else if (isTRUE(res$ok)) cat(sprintf("  run_engine : ok = TRUE, sigma_USP = %.10f\n", res$parametre$sigma_usp))
    else cat("  run_engine : ok = FALSE ;", head(res$validation$erreurs, 2), sep = "\n    ")
  } else cat("  erreurs :", r$erreurs, sep = "\n    ")
  cat("\n")
}
b2s <- function(k) sprintf('<c r="B2" t="s"><v>%d</v></c>', as.integer(k))
if (cas %in% names(T9)) {
  x <- T9[[cas]]
  cat(sprintf("  table : %s\n  B2 : indice %d ; attendu : %s\n", encodeString(x[[1]]), as.integer(x[[2]]), x[[3]]))
  lire_serie(forger(serie(list("1" = b2s(x[[2]]))), partagees = x[[1]]))
} else switch(cas,
  # #574 (4) : n balises <x:rPh> non fermees dans la table
  "574-4-n1000" = , "574-4-n2000" = , "574-4-n4000" = , "574-4-n16000" = {
    n <- as.integer(sub("^.*-n", "", cas))
    cat(sprintf("  table : <si><t>11</t> suivi de %d <x:rPh sb=\"0\" eb=\"1\"> non fermes ; attendu : refus\n", n))
    lire_serie(forger(serie(list("1" = b2s(0))), partagees = paste0("<si><t>11</t>", strrep('<x:rPh sb="0" eb="1">', n), "</si>")))
  },
  # retraits de blocs de X1 (avant R9) : 16 000 <rPh a=" ou <r a=" (guillemet
  # non ferme) ; seconde chaine a <rPr> (sinon refus Q-F pour <r a=")
  "x1-rph-guillemet-n16000" = , "x1-r-guillemet-n16000" = {
    forme <- if (startsWith(cas, "x1-rph")) '<rPh a="' else '<r a="'
    cat(sprintf("  table : <si><t>11</t> suivi de 16000 %s, puis <si> a <rPr> ; attendu : refus\n", forme))
    lire_serie(forger(serie(list("1" = b2s(0))), partagees = paste0("<si><t>11</t>", strrep(forme, 16000), "</si>", RPR)))
  },
  # racine prefixee : partie ecrite a la main (forge.R ecrit <sst>)
  "x-sst-racine" = {
    f <- forger(serie(list("1" = b2s(0))), partagees = "<si><t>11.5</t></si>")
    d <- tempfile("xsst_"); utils::unzip(f, exdir = d)
    writeLines('<?xml version="1.0" encoding="UTF-8"?><x:sst xmlns:x="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><x:si><x:t>11.5</x:t></x:si></x:sst>',
               file.path(d, "xl", "sharedStrings.xml"), useBytes = TRUE)
    od <- setwd(d); unlink(f); system2("zip", c("-r9Xq", shQuote(f), "[Content_Types].xml", "_rels", "xl")); setwd(od)
    cat("  table : <x:sst><x:si><x:t>11.5</x:t></x:si></x:sst> ; attendu : 11.5\n")
    lire_serie(f) },
  "temoin-ecrit-par-moteur" = { f <- tempfile(fileext = ".xlsx")
    env <- environment(e$run_engine); assign("requireNamespace", function(package, ...) FALSE, envir = env)
    e$engine_ecrire_xlsx(LN, f); rm("requireNamespace", envir = env); lire_serie(f) },
  # classeur ecrit par openxlsx::write.xlsx() dans un sous-processus
  # (bibliotheque SONDE_LIB_OPENXLSX), colonne texte annexe
  "temoin-openxlsx-write" = {
    lib <- Sys.getenv("SONDE_LIB_OPENXLSX"); f <- tempfile(fileext = ".xlsx")
    st <- if (nzchar(lib)) system2(file.path(R.home("bin"), "Rscript"), c("-e", shQuote(sprintf(
      "library(openxlsx, lib.loc = '%s'); d <- data.frame(t = 1:8, xt = c(%s), yt = c(%s), note = c('a b', 'x&y', rep('n', 6))); write.xlsx(d, '%s')",
      lib, paste(LN$xt, collapse = ","), paste(LN$yt, collapse = ","), f)))) else 1L
    if (!identical(as.integer(st), 0L) || !file.exists(f)) cat("  [saute] SONDE_LIB_OPENXLSX absent\n\n") else lire_serie(f) },
  # R10 : 100 000 cellules hors de la table, controle seul (cellules lues
  # avant la mesure du temps)
  "r10-cinq-positions" = {
    x10 <- paste0("<worksheet><sheetData><row r=\"1\">", paste(sprintf('<c r="A%d" t="s"><v>%d</v></c>', 1:100000, 1:100000), collapse = ""),
                  "</row></sheetData></worksheet>")
    cc <- e$.xlsx_cellules(x10)
    t0 <- proc.time()[["elapsed"]]
    m <- tryCatch(e$.xlsx_controler_indices_partages(x10, 1, cc), error = function(x) conditionMessage(x))
    cat(sprintf("  R10, 100 000 cellules hors de la table : %.2f s ; positions : %s\n\n", proc.time()[["elapsed"]] - t0,
                regmatches(m, regexpr("\\([^;]*", m)))) })
