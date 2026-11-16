# Usage : Rscript sonde_574_lot_f.R <depot> <dossier_sondes> <fichier_moteur> [<cas>]
# #574, S1, lot F : balise <t> portant un attribut ou un blanc dans une
# chaine en ligne (<is>), decision D-S1-31 du mainteneur sur le constat H1
# de la validation du .tex par actuary (16/11/2026). openxlsx 4.2.5.2 garde
# l'attribut dans le texte lu, le lecteur interne le retire.
# Sans <cas> : chaque cas est rejoue dans son propre sous-processus Rscript
# (un arret n'interrompt pas la sonde), code de sortie releve.
# Chemin : openxlsx s'il est dans .libPaths() (R_LIBS), lecteur interne sinon.
# fichier_moteur : R/engine.R apres le correctif ; avant, la version extraite
# de la tete (git show 3f4720e:R/engine.R > fichier).
# Serie de reference (tests/donnees/donnees_ln.csv), en-tete en chaines en
# ligne ; sigma_USP rendu par run_engine(premium, segment 1, annexe II,
# brutes) si la lecture et engine_lire_donnees_csv() reussissent. Lecture
# attendue ecrite apres "attendu" pour chaque cas.
a <- commandArgs(TRUE); depot <- normalizePath(a[1]); sd <- normalizePath(a[2]); moteur <- normalizePath(a[3])
# balises <t> visees, valeur B2 (104.2) et en-tete B1 (xt)
T_VISES <- c("preserve" = '<t xml:space="preserve">', "sans-prefixe" = '<t space="preserve">',
             "prefixe-x" = '<t x:space="preserve">', "apostrophes" = "<t xml:space='preserve'>",
             "autre-attribut" = '<t foo="1">', "blanc" = "<t >", "tabulation" = "<t\t>", "saut-de-ligne" = "<t\n>")
CAS <- c(paste0("valeur-", names(T_VISES)), paste0("entete-", names(T_VISES)),
         # vide a attribut (refuse, lettre de D-S1-31) ; vides sans attribut (admis)
         "vide-preserve-note", "vide-note", "vide-blanc-note",
         # temoins admis : <is><t>, table partagee <si><t xml:space="preserve">
         "temoin-is-t-valeur", "temoin-is-t-entete", "temoin-si-preserve-valeur", "temoin-si-preserve-entete",
         "temoin-si-blanc-valeur",
         # cout : 100 000 chaines en ligne <t> en colonne E, la derniere a attribut ou non
         "cout-1e5-admise", "cout-1e5-refus")
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
b2_ligne <- function(t) sprintf('<c r="B2" t="inlineStr"><is>%s104.2</t></is></c>', t)
entete <- function(b1) { l <- serie(); l[1] <- ligne(1, ci("A1", "t"), b1, ci("C1", "yt")); l }
# colonne note D : D1 "note", D2 la chaine en ligne <is>x</is>, D3 "z"
avec_note <- function(d2) {
  l <- serie(); l[1] <- sub("</row>", paste0(ci("D1", "note"), "</row>"), l[1], fixed = TRUE)
  l[2] <- sub("</row>", sprintf('<c r="D2" t="inlineStr"><is>%s</is></c></row>', d2), l[2], fixed = TRUE)
  l[3] <- sub("</row>", paste0(ci("D3", "z"), "</row>"), l[3], fixed = TRUE)
  l
}
k <- sub("^(valeur|entete)-", "", cas)
if (startsWith(cas, "valeur-")) {
  cat(sprintf("  B2 : <is>%s104.2</t></is> ; attendu : refus R3 (balise <t>, B2) apres ; avant : 104.2 en interne\n", encodeString(T_VISES[[k]])))
  lire_serie(forger(serie(list("1" = b2_ligne(T_VISES[[k]])))))
} else if (startsWith(cas, "entete-")) {
  cat(sprintf("  B1 : <is>%sxt</t></is> ; attendu : refus R3 (balise <t>, B1) apres ; avant : en-tete xt en interne\n", encodeString(T_VISES[[k]])))
  lire_serie(forger(entete(sprintf('<c r="B1" t="inlineStr"><is>%sxt</t></is></c>', T_VISES[[k]]))))
} else switch(cas,
  "vide-preserve-note" = {
    cat("  D2 : <is><t xml:space=\"preserve\"/></is> ; attendu : refus R3 (balise <t>, D2) apres (lettre de D-S1-31)\n")
    lire_serie(forger(avec_note('<t xml:space="preserve"/>')), note = TRUE) },
  "vide-note" = , "vide-blanc-note" = {
    t <- if (cas == "vide-note") "<t/>" else "<t />"
    cat(sprintf("  D2 : <is>%s</is> ; attendu : admis, D2 vide (chaine vide ou NA), sigma_USP de la serie\n", t))
    lire_serie(forger(avec_note(t)), note = TRUE) },
  "temoin-is-t-valeur" = {
    cat("  B2 : <is><t>104.2</t></is> ; attendu : 104.2, sigma_USP de la serie\n")
    lire_serie(forger(serie(list("1" = b2_ligne("<t>"))))) },
  "temoin-is-t-entete" = {
    cat("  B1 : <is><t>xt</t></is> ; attendu : en-tete xt, sigma_USP de la serie\n")
    lire_serie(forger(entete(ci("B1", "xt")))) },
  "temoin-si-preserve-valeur" = , "temoin-si-blanc-valeur" = {
    t <- if (cas == "temoin-si-preserve-valeur") '<t xml:space="preserve">' else "<t >"
    cat(sprintf("  table : <si>%s104.2</t></si> ; B2 : indice 0 ; attendu : 104.2 (forme hors du bloc des donnees)\n", t))
    lire_serie(forger(serie(list("1" = '<c r="B2" t="s"><v>0</v></c>')), partagees = sprintf("<si>%s104.2</t></si>", t))) },
  "temoin-si-preserve-entete" = {
    cat("  table : <si><t xml:space=\"preserve\">xt</t></si> ; B1 : indice 0 ; attendu : en-tete xt\n")
    lire_serie(forger(entete('<c r="B1" t="s"><v>0</v></c>'), partagees = '<si><t xml:space="preserve">xt</t></si>')) },
  "cout-1e5-admise" = , "cout-1e5-refus" = {
    der <- if (endsWith(cas, "admise")) "<t>" else '<t xml:space="preserve">'
    cat(sprintf("  colonne E, lignes 10 a 100009 : 100 000 cellules <is><t>k</t></is>, la derniere ecrite %s (cout de lecture ; verdict aval quelconque)\n", der))
    i <- 10:100009
    tt <- c(rep("<t>", 99999), der)
    lire_serie(forger(c(serie(), sprintf('<row r="%d"><c r="E%d" t="inlineStr"><is>%sk%d</t></is></c></row>', i, i, tt, i))))
  })
