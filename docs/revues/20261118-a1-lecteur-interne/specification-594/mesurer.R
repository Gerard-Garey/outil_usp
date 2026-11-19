# Mesure, lecture seule : lecteur interne actuel (avant) et prototype en
# memoire de la regle amendee de #594 (apres). Aucun fichier du depot ecrit.
args <- commandArgs(TRUE); cl <- args[1]; corpus <- args[2]
source("R/charger_moteur.R")
m <- charger_moteur(dans = NULL)
stopifnot(!requireNamespace("openxlsx", quietly = TRUE))
avant <- m$.xlsx_controler_structure
txt <- deparse(avant, width.cutoff = 500L)
k <- grep("t_is <- nm == \"t\"", txt, fixed = TRUE)
stopifnot(length(k) == 1L)
cat("ligne t_is actuelle :", trimws(txt[k]), "\n")
txt[k] <- "    t_is <- nm == \"t\" & pn == \"is\" & ifelse(g == \"o\", !tk %in% c(\"<t>\", \"<t xml:space=\\\"preserve\\\">\"), !grepl(\"^<t[ \\t\\r\\n]*/>$\", tk, useBytes = TRUE) & tk != \"<t xml:space=\\\"preserve\\\"/>\")"
cat("ligne t_is prototype :", trimws(txt[k]), "\n")
apres <- eval(parse(text = txt)); environment(apres) <- environment(avant)
lire <- function(f, proto, entete = TRUE) {
  assign(".xlsx_controler_structure", if (proto) apres else avant, envir = m)
  on.exit(assign(".xlsx_controler_structure", avant, envir = m))
  tryCatch(m$engine_lire_xlsx(f, entete), error = function(e) e)
}
etat <- function(r) if (inherits(r, "condition")) paste0("REFUS [", class(r)[1], "] ", substr(conditionMessage(r), 1, 150)) else sprintf("lu %dx%d ; noms = %s", nrow(r), ncol(r), paste(sprintf("[%s]", names(r)), collapse = " "))
ref <- read.csv("tests/donnees/donnees_ln.csv"); ref[] <- lapply(ref, as.numeric)
aval <- function(r) if (inherits(r, "condition")) NULL else m$engine_lire_donnees_csv(r)
dit_aval <- function(a) if (is.null(a)) "-" else sprintf("ok=%s n=%d xt=CSV:%s yt=CSV:%s erreurs=%s", a$ok, a$n,
  isTRUE(identical(a$xt, ref$xt)), isTRUE(identical(a$yt, ref$yt)), if (length(a$erreurs)) substr(paste(a$erreurs, collapse = " | "), 1, 160) else "aucune")
cat("\n=== 1. Scenarios par ecrivain (avant = moteur actuel ; apres = prototype)\n")
fs <- sort(list.files(cl, "^S.*xlsx$", full.names = TRUE))
for (f in fs) {
  a <- lire(f, FALSE); p <- lire(f, TRUE)
  cat(sprintf("%-50s avant : %s\n%-50s apres : %s\n%-50s aval apres : %s\n", basename(f), etat(a), "", etat(p), "", dit_aval(aval(p))))
}
cat("\n=== 2. Critere : chaine en ligne (apres) == chaine partagee (avant), data.frame et engine_lire_donnees_csv() par identical()\n")
scen <- unique(sub("__.*$", "", basename(fs)))
for (s in scen) {
  ref_p <- lire(file.path(cl, paste0(s, "__xlsxwriter_defaut.xlsx")), FALSE)
  for (w in c("openpyxl", "xlsxwriter_cm")) {
    p <- lire(file.path(cl, paste0(s, "__", w, ".xlsx")), TRUE)
    same_df <- if (inherits(ref_p, "condition") || inherits(p, "condition")) identical(class(ref_p), class(p)) && identical(conditionMessage(ref_p), conditionMessage(p)) else identical(p, ref_p)
    same_av <- identical(aval(p), aval(ref_p))
    cat(sprintf("%-38s %-14s df identique : %-5s aval identique : %-5s\n", s, w, same_df, same_av))
  }
}
cat("\n=== 3. Formes forgees (sur S1 openpyxl, note D5)\n")
for (f in sort(list.files(cl, "^F_.*xlsx$", full.names = TRUE))) {
  a <- lire(f, FALSE); p <- lire(f, TRUE)
  note <- if (!inherits(p, "condition")) paste0(" ; D5 note = ", encodeString(p$note[4], quote = "\"")) else ""
  cat(sprintf("%-28s avant : %s\n%-28s apres : %s%s\n", basename(f), substr(etat(a), 1, 170), "", substr(etat(p), 1, 170), note))
}
cat("\n=== 3b. Lecture apres vs lecture avant de la forme sans attribut (identical)\n")
sa <- lire(file.path(cl, "F_sans_attribut.xlsx"), FALSE); pa <- lire(file.path(cl, "S1_note_bordee__openpyxl.xlsx"), TRUE)
cat("S1 openpyxl apres == F_sans_attribut avant :", identical(sa, pa), "\n")
vp <- lire(file.path(cl, "F_vide_paire.xlsx"), TRUE); va <- lire(file.path(cl, "F_vide_auto.xlsx"), TRUE); vt <- lire(file.path(cl, "F_vide_t.xlsx"), FALSE)
cat("vide_auto apres == vide_paire apres :", identical(va, vp), " ; == <t/> avant :", identical(va, vt), "\n")
cat("\n=== 4. Corpus du temoin (38 classeurs)\n")
tri <- read.csv("tests/donnees/triangle_mw.csv")
for (f in sort(list.files(corpus, "\\.xlsx$", recursive = TRUE, full.names = TRUE))) {
  a <- lire(f, FALSE); p <- lire(f, TRUE)
  est_tri <- grepl("triangle", f)
  ea <- if (inherits(a, "condition")) "refus" else "lu"; ep <- if (inherits(p, "condition")) "refus" else "lu"
  av <- if (ep == "lu") { if (est_tri) { r <- m$engine_lire_triangle(p); sprintf("triangle ok=%s %s", r$ok, if (length(r$erreurs)) substr(r$erreurs[1], 1, 70) else "") } else dit_aval(aval(p)) } else substr(conditionMessage(p), 1, 90)
  chg <- if (ea != ep) "CHANGE" else if (ea == "lu" && !identical(a, p)) "DF CHANGE" else "="
  cat(sprintf("%-80s %-5s -> %-5s %-9s %s\n", sub(".*mesure-594/", "", f), ea, ep, chg, av))
}
