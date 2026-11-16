# Usage : Rscript sonde_574_lot_e.R <depot> <dossier_sondes> <fichier_moteur> [<cas>]
# #574, S1 etape 5, lot E : references numeriques de caracteres ordinaires
# (&#NNN; ou &#xHH; designant un caractere ASCII imprimable autre que
# " & ' < >) dans le texte d'une chaine partagee ou d'une chaine en ligne,
# decision D-S1-18 du mainteneur sur la Q7 de l'avis d'actuary sur le lot D ;
# extension aux references a un blanc que retire la mise en forme des
# en-tetes (decision D-S1-23, constat de l'audit du lot E) et temoins des
# caracteres de controle restant admis (decision D-S1-22).
# Sans <cas> : chaque cas est rejoue dans son propre sous-processus Rscript
# (un arret n'interrompt pas la sonde), code de sortie releve.
# Chemin : openxlsx s'il est dans .libPaths() (R_LIBS), lecteur interne sinon.
# fichier_moteur : R/engine.R apres le correctif ; avant, la version extraite
# de 5a28380 (git show 5a28380:R/engine.R > fichier).
# Serie de reference (tests/donnees/donnees_ln.csv), en-tete en chaines en
# ligne ; sigma_USP rendu par run_engine(premium, segment 1, annexe II,
# brutes) si la lecture et engine_lire_donnees_csv() reussissent. Lecture
# juste attendue ecrite apres "attendu" pour chaque cas.
a <- commandArgs(TRUE); depot <- normalizePath(a[1]); sd <- normalizePath(a[2]); moteur <- normalizePath(a[3])
CAS <- c(
  # valeur B2 (xt de la premiere annee, 104.2) en chaine partagee d'indice 0
  "valeur-partagee-dec", "valeur-partagee-hex", "valeur-partagee-point", "valeur-partagee-zeros-dec",
  "valeur-partagee-zeros-hex", "valeur-partagee-X-majuscule",
  # valeur B2 en chaine en ligne
  "valeur-ligne-dec",
  # en-tete B1 x&#116; (xt)
  "entete-partagee", "entete-ligne",
  # en-tete B1 x&#116; et en-tete D1 xt (colonne D = 2 xt)
  "doublon-partagee", "doublon-ligne", "doublon-str",
  # formes non visees : <v> d'une cellule nombre (R8), <f>
  "valeur-nombre-v", "formule-f-nombre", "formule-f-str",
  # D-S1-23 : blancs retires par la mise en forme des en-tetes ; B1 + D1 xt
  "doublon-tab-partagee", "doublon-tab-ligne", "doublon-cr-debut-partagee", "doublon-ideo-ligne",
  "valeur-partagee-tab", "t-bom-annees-decroissantes", "t-tab-annees-decroissantes",
  # D-S1-22 : temoins restant admis, B1 + D1 xt
  "doublon-controle-1-partagee", "doublon-nbsp-partagee", "doublon-eacute-ligne",
  # temoins admis (colonne note annexe)
  "temoins-admis",
  # cout : table de 10^5 chaines, lecture complete
  "cout-table-1e5-admise", "cout-table-1e5-refus")
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
lire_serie <- function(f, note = FALSE) {
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
  cat(sprintf("  lu : %d x %d ; noms = %s ; B2 lu = %s (classe de la colonne 2 : %s)\n", nrow(df), ncol(df),
              encodeString(paste(names(df), collapse = ",")), encodeString(format(df[[2]][1], digits = 15), quote = '"'), class(df[[2]])[1]))
  if (note) cat(sprintf("  colonne note : %s\n", paste(encodeString(df$note, quote = '"'), collapse = " ; ")))
  r <- e$engine_lire_donnees_csv(df)
  cat(sprintf("  engine_lire_donnees_csv : ok = %s\n", r$ok))
  # serie retenue, dans l'ordre retenu (colonne t lue : lignes triees par annee)
  if (r$ok) cat(sprintf("  xt retenu : %s\n", paste(format(r$xt, digits = 15), collapse = " ")))
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
cs <- function(ref, k) sprintf('<c r="%s" t="s"><v>%d</v></c>', ref, as.integer(k))
# serie dont l'en-tete B1 est entete_b1, avec une colonne D (en-tete D1 xt,
# valeurs 2 xt) si doublon
serie_entete <- function(entete_b1, doublon = FALSE) {
  l <- ligne(1, ci("A1", "t"), entete_b1, ci("C1", "yt"), if (doublon) ci("D1", "xt"))
  for (k in 1:8) l <- c(l, ligne(k + 1, cn(paste0("A", k + 1), k), cn(paste0("B", k + 1), LN$xt[k]), cn(paste0("C", k + 1), LN$yt[k]),
                                 if (doublon) cn(paste0("D", k + 1), LN$xt[k] * 2)))
  l
}
VAL <- c("valeur-partagee-dec" = "1&#48;4.2", "valeur-partagee-hex" = "1&#x30;4.2", "valeur-partagee-point" = "104&#46;2",
         "valeur-partagee-zeros-dec" = "1&#00048;4.2", "valeur-partagee-zeros-hex" = "1&#x0030;4.2",
         "valeur-partagee-X-majuscule" = "1&#X30;4.2")
if (cas %in% names(VAL)) {
  cat(sprintf("  table : <si><t>%s</t></si> ; B2 : indice 0 ; attendu : 104.2 (X majuscule : hors grammaire XML)\n", VAL[[cas]]))
  lire_serie(forger(serie(list("1" = b2s(0))), partagees = sprintf("<si><t>%s</t></si>", VAL[[cas]])))
} else switch(cas,
  "valeur-ligne-dec" = {
    cat("  B2 : <is><t>1&#48;4.2</t></is> ; attendu : 104.2\n")
    lire_serie(forger(serie(list("1" = '<c r="B2" t="inlineStr"><is><t>1&#48;4.2</t></is></c>')))) },
  "entete-partagee" = {
    cat("  B1 : chaine partagee <t>x&#116;</t> ; attendu : en-tete xt, sigma_USP de la serie\n")
    lire_serie(forger(serie_entete(cs("B1", 0)), partagees = "<si><t>x&#116;</t></si>")) },
  "entete-ligne" = {
    cat("  B1 : chaine en ligne <t>x&#116;</t> ; attendu : en-tete xt, sigma_USP de la serie\n")
    lire_serie(forger(serie_entete(ci("B1", "x&#116;")))) },
  "doublon-partagee" = {
    cat("  B1 : chaine partagee <t>x&#116;</t>, D1 : xt (colonne D = 2 xt) ; attendu : refus du doublon xt\n")
    lire_serie(forger(serie_entete(cs("B1", 0), TRUE), partagees = "<si><t>x&#116;</t></si>")) },
  "doublon-ligne" = {
    cat("  B1 : chaine en ligne <t>x&#116;</t>, D1 : xt (colonne D = 2 xt) ; attendu : refus du doublon xt\n")
    lire_serie(forger(serie_entete(ci("B1", "x&#116;"), TRUE))) },
  "doublon-tab-partagee" = {
    cat("  B1 : chaine partagee <t>xt&#9;</t>, D1 : xt (colonne D = 2 xt) ; attendu : refus (doublon xt)\n")
    lire_serie(forger(serie_entete(cs("B1", 0), TRUE), partagees = "<si><t>xt&#9;</t></si>")) },
  "doublon-tab-ligne" = {
    cat("  B1 : chaine en ligne <t>xt&#9;</t>, D1 : xt (colonne D = 2 xt) ; attendu : refus (doublon xt)\n")
    lire_serie(forger(serie_entete(ci("B1", "xt&#9;"), TRUE))) },
  "doublon-cr-debut-partagee" = {
    cat("  B1 : chaine partagee <t>&#xD;xt</t>, D1 : xt (colonne D = 2 xt) ; attendu : refus (doublon xt)\n")
    lire_serie(forger(serie_entete(cs("B1", 0), TRUE), partagees = "<si><t>&#xD;xt</t></si>")) },
  "doublon-ideo-ligne" = {
    cat("  B1 : chaine en ligne <t>xt&#12288;</t> (U+3000), D1 : xt (colonne D = 2 xt) ; attendu : refus (doublon xt)\n")
    lire_serie(forger(serie_entete(ci("B1", "xt&#12288;"), TRUE))) },
  "valeur-partagee-tab" = {
    cat("  table : <si><t>104.2&#9;</t></si> ; B2 : indice 0 ; attendu : 104.2\n")
    lire_serie(forger(serie(list("1" = b2s(0))), partagees = "<si><t>104.2&#9;</t></si>")) },
  "t-bom-annees-decroissantes" = , "t-tab-annees-decroissantes" = {
    h <- if (startsWith(cas, "t-bom")) "&#65279;t" else "t&#9;"
    cat(sprintf("  A1 : chaine partagee <t>%s</t> ; annees 8 a 1 en A2 a A9 (ordre du fichier inverse) ; attendu : colonne t, serie remise dans l'ordre des annees\n", h))
    l <- serie()
    l[1] <- sub(ci("A1", "t"), cs("A1", 0), l[1], fixed = TRUE)
    for (k in 1:8) l[k + 1] <- sub(sprintf('<c r="A%d"><v>%d</v></c>', k + 1, k), sprintf('<c r="A%d"><v>%d</v></c>', k + 1, 9 - k), l[k + 1], fixed = TRUE)
    lire_serie(forger(l, partagees = sprintf("<si><t>%s</t></si>", h))) },
  "doublon-controle-1-partagee" = , "doublon-nbsp-partagee" = {
    h <- if (grepl("controle", cas)) "xt&#1;" else "xt&#160;"
    cat(sprintf("  B1 : chaine partagee <t>%s</t>, D1 : xt (colonne D = 2 xt) ; en-tete distinct de xt sur les deux chemins : colonne D\n", h))
    lire_serie(forger(serie_entete(cs("B1", 0), TRUE), partagees = sprintf("<si><t>%s</t></si>", h))) },
  "doublon-eacute-ligne" = {
    cat("  B1 : chaine en ligne <t>xt&#233;</t>, D1 : xt (colonne D = 2 xt) ; en-tete distinct de xt sur les deux chemins : colonne D\n")
    lire_serie(forger(serie_entete(ci("B1", "xt&#233;"), TRUE))) },
  "doublon-str" = {
    cat("  B1 : t=\"str\" <v>x&#116;</v>, D1 : xt (colonne D = 2 xt) ; texte t=\"str\" non decode par les deux chemins\n")
    lire_serie(forger(serie_entete('<c r="B1" t="str"><v>x&#116;</v></c>', TRUE))) },
  "valeur-nombre-v" = {
    cat("  B2 : cellule nombre <v>1&#48;4.2</v> ; attendu : refus R8\n")
    lire_serie(forger(serie(list("1" = '<c r="B2"><v>1&#48;4.2</v></c>')))) },
  "formule-f-nombre" = {
    cat("  B2 : cellule nombre <f>1&#48;4.2</f><v>104.2</v> ; attendu : 104.2 (formule non lue)\n")
    lire_serie(forger(serie(list("1" = '<c r="B2"><f>1&#48;4.2</f><v>104.2</v></c>')))) },
  "formule-f-str" = {
    cat("  D1 : t=\"str\" <f>&quot;n&#111;te&quot;</f><v>note</v> ; attendu : en-tete note (formule non lue)\n")
    l <- serie(); l[1] <- sub("</row>", '<c r="D1" t="str"><f>&quot;n&#111;te&quot;</f><v>note</v></c></row>', l[1], fixed = TRUE)
    lire_serie(forger(l)) },
  "temoins-admis" = {
    tem <- c("&#233;t&#xE9;", "a&#160;b&#x202F;c&#8203;d&#x85;e", "&#38;&#39;&#x27;&#34;&#60;&#62;",
             "&amp;&lt;&gt;&quot;&apos;", "&#0;&#127;&#31;&#x110000;")
    cat("  colonne note : D2 a D6 en chaines partagees, D7 a D9 en chaines en ligne :", paste(tem, collapse = " | "), "\n")
    l <- serie(); l[1] <- sub("</row>", paste0(ci("D1", "note"), "</row>"), l[1], fixed = TRUE)
    for (k in 1:8) {
      d <- if (k <= 5) cs(paste0("D", k + 1), k - 1) else ci(paste0("D", k + 1), tem[k - 5])
      l[k + 1] <- sub("</row>", paste0(d, "</row>"), l[k + 1], fixed = TRUE)
    }
    lire_serie(forger(l, partagees = paste0("<si><t>", tem, "</t></si>", collapse = "")), note = TRUE) },
  "cout-table-1e5-admise" = , "cout-table-1e5-refus" = {
    corps <- if (endsWith(cas, "admise")) "x&#233;&#160;&#38;" else "1&#48;"
    cat(sprintf("  table : 100 000 chaines <si><t>%s k</t></si>, puis 104.2 a l'indice 100000 ; B2 : indice 100000\n", corps))
    sh <- paste0(paste0("<si><t>", corps, " ", seq_len(100000), "</t></si>", collapse = ""), "<si><t>104.2</t></si>")
    lire_serie(forger(serie(list("1" = b2s(100000))), partagees = sh)) })
