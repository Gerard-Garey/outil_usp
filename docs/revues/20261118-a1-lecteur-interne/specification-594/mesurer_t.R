source("R/charger_moteur.R"); m <- charger_moteur(dans = NULL)
avant <- m$.xlsx_controler_structure
txt <- deparse(avant, width.cutoff = 500L); k <- grep("t_is <- nm == \"t\"", txt, fixed = TRUE)
txt[k] <- "    t_is <- nm == \"t\" & pn == \"is\" & ifelse(g == \"o\", !tk %in% c(\"<t>\", \"<t xml:space=\\\"preserve\\\">\"), !grepl(\"^<t[ \\t\\r\\n]*/>$\", tk, useBytes = TRUE) & tk != \"<t xml:space=\\\"preserve\\\"/>\")"
apres <- eval(parse(text = txt)); environment(apres) <- environment(avant)
assign(".xlsx_controler_structure", apres, envir = m)
ref <- read.csv("tests/donnees/donnees_ln.csv"); ref[] <- lapply(ref, as.numeric)
c594 <- commandArgs(TRUE)[1]
fs <- c("blancs/classeurs_sans_lxml/note_bordee_blancs.xlsx", "blancs/classeurs/ligne_finale_note_blanche.xlsx", "blancs/classeurs/note_tab.xlsx",
        "blancs/classeurs/note_trois_blancs.xlsx", "blancs/classeurs/note_un_blanc.xlsx", "classeurs/openpyxl_blancs.xlsx", "classeurs/pandas_blancs.xlsx",
        "classeurs/xlsxwriter_constant_memory_blancs.xlsx", "entete/openpyxl_entete_lu_blanc.xlsx", "poste-windows/classeurs/openpyxl_series_blancs.xlsx",
        "poste-windows/classeurs/pandas-openpyxl_series_blancs.xlsx", "poste-windows/classeurs/xlsxwriter-constant_memory_series_blancs.xlsx")
for (f in fs) {
  d <- m$engine_lire_xlsx(file.path(c594, f)); a <- m$engine_lire_donnees_csv(d)
  tt <- m$.en_numerique(d$t)[seq_len(8)]
  cat(sprintf("%-68s nrow=%d t[1:8]=CSV:%s xt=CSV:%s yt=CSV:%s avert=%d note=%s\n", f, nrow(d), identical(tt, ref$t), identical(a$xt, ref$xt), identical(a$yt, ref$yt),
              length(a$avertissements_lecture), paste(encodeString(d[[ncol(d)]], quote = "\""), collapse = " ")))
}
