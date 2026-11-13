sp <- "<scratchpad>/k2b-rejeu"
.libPaths(c(file.path(sp, "lib"), .libPaths()))
source("R/charger_moteur.R"); charger_moteur()
source(file.path(sp, "fab.R"))
cat("LC_CTYPE =", Sys.getlocale("LC_CTYPE"), " l10n_info UTF-8:", l10n_info()$`UTF-8`, "\n")
cas <- c(NBSP = " ", EMSP_2003 = " ", NEL_0085 = "\u0085", IDEO_3000 = "　", FIG_2007 = " ", TAB = "\t", LF = "\n")
for (k in names(cas)) {
  nm <- c("t", paste0(" ", "x", cas[[k]], cas[[k]], "t "), "yt")
  df <- setNames(data.frame(1:2, c(1.5, 3), c(2.5, 4)), nm)
  f <- file.path(sp, "classeurs", "blancs.xlsx"); engine_ecrire_xlsx(df, f)
  r <- lire2(f)
  na <- vapply(r, function(x) if (inherits(x, "echec")) unclass(x) else paste(deparse(names(x)), collapse = ""), "")
  cat(sprintf("%-10s interne: %-28s openxlsx: %-28s  %s\n", k, na[["interne"]], na[["openxlsx"]], if (identical(na[["interne"]], na[["openxlsx"]])) "PARITE" else "ECART"))
}
