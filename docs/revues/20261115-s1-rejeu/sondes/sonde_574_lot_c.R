# Usage : Rscript sonde_574_lot_c.R <depot> <dossier_sondes> <fichier_moteur> [<cas>]
# #574, S1 etape 5, lot C : regles R7 (type de cellule admis) et R8
# (contenu conforme au type) du contrat ferme du lecteur de classeur, avec
# l'amendement de R8 (avis d'actuary sur le lot B, Q5 : t="s" et t="b" sans
# <v> refuses), <v></v> et <v/> ; position "cellule sans reference" du refus
# du segment (mineur de l'audit du lot B).
# Sans <cas> : chaque cas est rejoue dans son propre sous-processus Rscript
# (un arret n'interrompt pas la sonde), code de sortie releve.
# Chemin : openxlsx s'il est dans .libPaths() (R_LIBS), lecteur interne sinon.
# fichier_moteur : R/engine.R apres le correctif ; avant, la version extraite
# de 185a3e7 (git show 185a3e7:R/engine.R > fichier).
# Chaque cas forge la serie de reference (tests/donnees/donnees_ln.csv) dont
# la cellule B2 (xt de la premiere annee, 104.2) est remplacee ; sigma_USP
# rendu par run_engine(premium, segment 1, annexe II, brutes) si la lecture
# et engine_lire_donnees_csv() reussissent.
a <- commandArgs(TRUE); depot <- normalizePath(a[1]); sd <- normalizePath(a[2]); moteur <- normalizePath(a[3])
PARTAGEES <- "<si><t>11.5</t></si><si><t>104.2</t></si>"
B2 <- list(
  # R7, type admis
  "r7-t-d" = '<c r="B2" t="d"><v>2020-01-01T00:00:00</v></c>',
  "r7-t-e-corps" = '<c r="B2" t="e"><v>#N/A</v></c>',
  "r7-t-e-vm" = '<c r="B2" t="e" vm="1"><v>#VALUE!</v></c>',
  "r7-t-e-sans-v" = '<c r="B2" t="e"/>',
  "r7-t-x" = '<c r="B2" t="x"><v>5</v></c>',
  "r7-t-S" = '<c r="B2" t="S"><v>1</v></c>',
  "r7-t-N" = '<c r="B2" t="N"><v>104.2</v></c>',
  "r7-t-Str" = '<c r="B2" t="Str"><v>104.2</v></c>',
  # R8, cellule nombre (t absent ou n)
  "r8-n-hex" = '<c r="B2"><v>0x10</v></c>',
  "r8-n-entite-15" = '<c r="B2"><v>&#49;5</v></c>',
  "r8-n-entite-104" = '<c r="B2"><v>1&#48;4.2</v></c>',
  "r8-n-lt" = '<c r="B2"><v>1&lt;2</v></c>',
  "r8-n-gt" = '<c r="B2"><v>1>2</v></c>',
  "r8-n-INF" = '<c r="B2"><v>INF</v></c>',
  "r8-n-NaN" = '<c r="B2"><v>NaN</v></c>',
  "r8-n-vide" = '<c r="B2"><v></v></c>',
  "r8-n-auto" = '<c r="B2"><v/></c>',
  "r8-tn-vide" = '<c r="B2" t="n"><v></v></c>',
  "r8-n-point" = '<c r="B2"><v>.</v></c>',
  "r8-n-1e" = '<c r="B2"><v>1e</v></c>',
  "r8-n-1e400" = '<c r="B2"><v>1e400</v></c>',
  "r8-n-pleine-chasse" = '<c r="B2"><v>１０４.2</v></c>',
  "r8-n-virgule" = '<c r="B2"><v>104,2</v></c>',
  "r8-n-blanc-interieur" = '<c r="B2"><v>104 .2</v></c>',
  "r8-n-is" = '<c r="B2"><is><t>104.2</t></is></c>',
  "r8-tn-is" = '<c r="B2" t="n"><is><t>104.2</t></is></c>',
  # cellules nombre admises (temoins)
  "ok-n-blancs" = '<c r="B2"><v> \t104.2\n</v></c>',
  "ok-n-cr" = '<c r="B2"><v>104.2\r</v></c>',
  "ok-n-plus-exposant" = '<c r="B2"><v>+1.042E+2</v></c>',
  "ok-n-point-final" = '<c r="B2"><v>104.</v></c>',
  "ok-n-point-initial" = '<c r="B2"><v>+.5e-3</v></c>',
  "ok-n-moins-zero" = '<c r="B2"><v>-0</v></c>',
  "ok-tn" = '<c r="B2" t="n"><v>104.2</v></c>',
  "ok-f-sans-v" = '<c r="B2"><f>1+1</f></c>',
  "ok-f-avec-v" = '<c r="B2"><f>1+1</f><v>104.2</v></c>',
  # R8, booleen
  "r8-b-2" = '<c r="B2" t="b"><v>2</v></c>',
  "r8-b-true" = '<c r="B2" t="b"><v>true</v></c>',
  "r8-b-blanc" = '<c r="B2" t="b"><v> 1</v></c>',
  "r8-b-vide" = '<c r="B2" t="b"><v></v></c>',
  "r8-b-sans-v" = '<c r="B2" t="b"/>',
  "r8-b-auto" = '<c r="B2" t="b"><v/></c>',
  "r8-b-f-sans-v" = '<c r="B2" t="b"><f>TRUE()</f></c>',
  "ok-b-1" = '<c r="B2" t="b"><v>1</v></c>',
  # R8, chaine partagee (table : 11.5, 104.2)
  "r8-s-is" = '<c r="B2" t="s"><is><t>11</t></is></c>',
  "r8-s-v-is" = '<c r="B2" t="s"><v>1</v><is><t>11</t></is></c>',
  "r8-s-sans-v" = '<c r="B2" t="s"/>',
  "r8-s-f-sans-v" = '<c r="B2" t="s"><f>A1</f></c>',
  "r8-s-vide" = '<c r="B2" t="s"><v></v></c>',
  "r8-s-auto" = '<c r="B2" t="s"><v/></c>',
  "r8-s-blanc" = '<c r="B2" t="s"><v> 1</v></c>',
  "r8-s-1.0" = '<c r="B2" t="s"><v>1.0</v></c>',
  "r8-s-moins1" = '<c r="B2" t="s"><v>-1</v></c>',
  "r8-s-plus1" = '<c r="B2" t="s"><v>+1</v></c>',
  "r8-s-1e0" = '<c r="B2" t="s"><v>1e0</v></c>',
  "ok-s-01" = '<c r="B2" t="s"><v>01</v></c>',
  # R8, chaine de formule
  "r8-str-is" = '<c r="B2" t="str"><is><t>104.2</t></is></c>',
  "r8-str-vide" = '<c r="B2" t="str"><f>""</f><v></v></c>',
  "r8-str-auto" = '<c r="B2" t="str"><f>""</f><v/></c>',
  "ok-str" = '<c r="B2" t="str"><f>A1</f><v>104.2</v></c>',
  "ok-str-sans-v" = '<c r="B2" t="str"><f>A1</f></c>',
  "ok-str-entite" = '<c r="B2" t="str"><v>104&#46;2</v></c>',
  # R8, chaine en ligne
  "r8-is-v" = '<c r="B2" t="inlineStr"><v>104.2</v><is><t>104.2</t></is></c>',
  "r8-is-v-seul" = '<c r="B2" t="inlineStr"><v>104.2</v></c>',
  "r8-is-auto" = '<c r="B2" t="inlineStr"><v/><is><t>104.2</t></is></c>',
  "ok-is-sans" = '<c r="B2" t="inlineStr"/>',
  "ok-is-auto-seul" = '<c r="B2" t="inlineStr"><v/></c>',
  "ok-str-auto-seul" = '<c r="B2" t="str"><v/></c>',
  "ok-is" = '<c r="B2" t="inlineStr"><is><t>104.2</t></is></c>')
AUTRES <- c("r7-t-e-hors-tableau", "r8-s-xfd-sans-v", "r8-b-xfd-sans-v", "r8-n-xfd-vide",
            "seg-sans-r", "temoin-reference", "temoin-ecrit-par-moteur", "temoin-openxlsx-write",
            "openxlsx-write-keepna", "openxlsx-write-inf")
CAS <- c(names(B2), AUTRES)
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
  cat(sprintf("  lu : %d x %d ; noms = %s ; B2 lu = %s (classe de xt : %s)\n", nrow(df), ncol(df),
              paste(names(df), collapse = ","), encodeString(format(df[[2]][1], digits = 15), quote = '"'), class(df[[2]])[1]))
  r <- e$engine_lire_donnees_csv(df)
  cat(sprintf("  engine_lire_donnees_csv : ok = %s\n", r$ok))
  if (r$ok) {
    cat("  xt =", format(r$xt, digits = 10), "\n")
    res <- tryCatch(e$run_engine(xt = r$xt, yt = r$yt, methode = "premium", segment = 1, annexe = "II", nature_donnees = "brutes"),
                    error = function(err) err)
    if (inherits(res, "error")) cat("  run_engine : ERREUR", conditionMessage(res), "\n")
    else if (isTRUE(res$ok)) cat(sprintf("  run_engine : ok = TRUE, sigma_USP = %.10f\n", res$parametre$sigma_usp))
    else cat("  run_engine : ok = FALSE ;", head(res$validation$erreurs, 2), sep = "\n    ")
  } else cat("  erreurs :", r$erreurs, sep = "\n    ")
  cat("\n")
}
# Classeur ecrit par openxlsx::write.xlsx() dans un sous-processus Rscript
# (bibliotheque SONDE_LIB_OPENXLSX) : colonnes t, xt, yt, puis colonnes
# supplementaires (texte R), arguments supplementaires de write.xlsx().
ecrire_openxlsx <- function(colonnes, args) {
  lib <- Sys.getenv("SONDE_LIB_OPENXLSX"); f <- tempfile(fileext = ".xlsx")
  st <- if (nzchar(lib)) system2(file.path(R.home("bin"), "Rscript"), c("-e", shQuote(sprintf(
    "library(openxlsx, lib.loc = '%s'); d <- data.frame(t = 1:8, xt = c(%s), yt = c(%s)%s); write.xlsx(d, '%s'%s)",
    lib, paste(LN$xt, collapse = ","), paste(LN$yt, collapse = ","), colonnes, f, args)))) else 1L
  if (!identical(as.integer(st), 0L) || !file.exists(f)) cat("  [saute] SONDE_LIB_OPENXLSX absent\n\n") else {
    x <- utils::unzip(f, "xl/worksheets/sheet1.xml", exdir = tempfile())
    tt <- regmatches(readLines(x, warn = FALSE), gregexpr('<c r="D[0-9]+"[^>]*t="e"[^>]*>.*?</c>', readLines(x, warn = FALSE), perl = TRUE))
    cat("  cellules t=\"e\" ecrites par openxlsx :", if (length(unlist(tt))) unlist(tt) else "aucune", "\n")
    lire_serie(f) }
}
avec_table <- function(x) grepl('t="s"', x, fixed = TRUE)
if (cas %in% names(B2)) {
  x <- B2[[cas]]
  lire_serie(forger(serie(list("1" = x)), partagees = if (avec_table(x)) PARTAGEES))
} else switch(cas,
  # cellule en erreur de calcul hors des colonnes t, xt, yt (colonne "note")
  "r7-t-e-hors-tableau" = { l <- serie(); l[1] <- sub("</row>", paste0(ci("D1", "note"), "</row>"), l[1], fixed = TRUE)
                            l[2] <- sub("</row>", '<c r="D2" t="e"><v>#DIV/0!</v></c></row>', l[2], fixed = TRUE)
                            lire_serie(forger(l)) },
  # cellules sans <v> en XFD1048576 (avis d'actuary sur le lot B, Q5)
  "r8-s-xfd-sans-v" = lire_serie(forger(c(serie(), '<row r="1048576"><c r="XFD1048576" t="s"/></row>'), partagees = PARTAGEES)),
  "r8-b-xfd-sans-v" = lire_serie(forger(c(serie(), '<row r="1048576"><c r="XFD1048576" t="b"/></row>'))),
  "r8-n-xfd-vide" = lire_serie(forger(c(serie(), '<row r="1048576"><c r="XFD1048576"><v></v></c></row>'))),
  # refus du segment sur une cellule sans attribut r (mineur de l'audit du
  # lot B) : ligne 2 <c s="1"/> sans r, ligne 3 <row r="3" t="s">
  "seg-sans-r" = { l <- serie(); l[2] <- sub("</row>", '<c s="1"/></row>', l[2], fixed = TRUE)
                   l[3] <- sub('<row r="3">', '<row r="3" t="s">', l[3], fixed = TRUE)
                   lire_serie(forger(l, partagees = PARTAGEES)) },
  "temoin-reference" = lire_serie(forger(serie())),
  "temoin-ecrit-par-moteur" = { f <- tempfile(fileext = ".xlsx")
    env <- environment(e$run_engine); assign("requireNamespace", function(package, ...) FALSE, envir = env)
    e$engine_ecrire_xlsx(LN, f); rm("requireNamespace", envir = env); lire_serie(f) },
  # classeurs ecrits par openxlsx::write.xlsx(), dans un sous-processus (le
  # chargement d'openxlsx ici ferait suivre le chemin openxlsx au moteur)
  "temoin-openxlsx-write" = ecrire_openxlsx("", ""),
  # colonne annexe "note" : NA ecrit avec keepNA = TRUE, puis Inf, -Inf, NaN
  # ecrits par defaut (cellules t="e", decision D-S1-13)
  "openxlsx-write-keepna" = ecrire_openxlsx(", note = c(NA, rep(1, 7))", ", keepNA = TRUE"),
  "openxlsx-write-inf" = ecrire_openxlsx(", note = c(Inf, -Inf, NaN, rep(1, 5))", ""))
