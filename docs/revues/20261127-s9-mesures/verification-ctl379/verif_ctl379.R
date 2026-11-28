# Verification ciblee hors depot (#379) : controle_chaine() corrige de
# tests/puissance_t8.R rejoue sur les 240 replications controlees de la
# campagne versee (b multiple de 10, J1 et J2, points N, A+0.5, T2, R4_2 ;
# B = 999, graines par defaut). Definitions et constantes du script
# evaluees par parse() jusqu'au bloc du mode --familles (exclu), sous
# commandArgs() substitue ("--familles", options par defaut).
# Usage (cwd = depot) : Rscript verif_ctl379.R [coeurs]
COEURS <- { a <- commandArgs(TRUE); if (length(a)) as.integer(a[1]) else 4L }
SP <- "/tmp/claude-0/-home-user-outil-usp/3407551e-539e-4dba-954f-822f43f11bd0/scratchpad"
SCRIPT <- normalizePath("tests/puissance_t8.R")
BRUT <- "docs/tableaux/20261127-issue379-familles-ln-brut.tsv"
commandArgs <- function(trailingOnly = FALSE)
  if (trailingOnly) "--familles" else c("R", paste0("--file=", SCRIPT), "--args", "--familles")
ex <- parse(SCRIPT, keep.source = FALSE, encoding = "UTF-8")
i_fam <- which(vapply(ex, function(e) identical(deparse(e)[1], "if (OPT_FAMILLES) {"), logical(1)))
stopifnot(length(i_fam) == 1L)
for (e in ex[seq_len(i_fam - 1L)]) eval(e, globalenv())
rm(commandArgs)
stopifnot(OPT_B == 999L, !OPT_ESSAI, identical(JEUX_B, c("J1", "J2")))
POINTS_FAM <- strsplit(OPT_POINTS, ",", fixed = TRUE)[[1]]
stopifnot(identical(POINTS_FAM, c("N", "A+0.5", "T2", "R4_2")))
cat("EMPREINTES :", EMPREINTES, "\n")
cat("plateforme :", plateforme_calcul(), "\n")
cat("md5 du script corrige :", unname(tools::md5sum(SCRIPT)), "\n")
R_RUN <- 300L
PLAN <- list()
for (jn in JEUX_B) {
  J <- charger_jeu(jn); fit <- usp_ajuster(J$x, J$y)
  PLAN[[jn]] <- list(nom = jn, x = J$x, fit = fit, E = tirer_e(OPT_GRAINE + 1, R_RUN), libelle = J$libelle)
}
taches <- expand.grid(b = seq(CTL_CHAINE_PERIODE, R_RUN, by = CTL_CHAINE_PERIODE), pt = POINTS_FAM, jeu = JEUX_B,
                      stringsAsFactors = FALSE)
cat("replications controlees :", nrow(taches), "\n")
t0 <- Sys.time()
res <- parallel::mclapply(seq_len(nrow(taches)), function(i)
  tryCatch(unite_familles_ln(PLAN[[taches$jeu[i]]], taches$pt[i], taches$b[i], TRUE),
           error = function(e) paste("erreur :", conditionMessage(e))),
  mc.cores = COEURS, mc.preschedule = FALSE)
duree <- as.numeric(difftime(Sys.time(), t0, units = "secs"))
saveRDS(list(taches = taches, res = res), file.path(SP, "verif_ctl379.rds"))
ok <- vapply(res, function(v) is.character(v) && length(v) == length(COLS_FAM), logical(1))
cat("unites en erreur :", sum(!ok), "\n")
V <- as.data.frame(do.call(rbind, res[ok]), stringsAsFactors = FALSE)
classe <- ifelse(V$ctl == "identique", "identique", ifelse(V$ctl == "exclusion (boucle)", "exclusion (boucle)",
                 ifelse(V$ctl == "exclusion (flux V3b)", "exclusion (flux V3b)", ifelse(startsWith(V$ctl, "ECHEC"), "ECHEC", V$ctl))))
print(table(paste(V$jeu, V$point), factor(classe, c("identique", "exclusion (boucle)", "exclusion (flux V3b)", "ECHEC"))))
if (any(classe == "ECHEC")) print(unique(V$ctl[classe == "ECHEC"]))
# Memes replications que la campagne : champs du brut verse (hors ctl,
# texte du controle) identiques a ceux recalcules.
B0 <- utils::read.delim(BRUT, colClasses = "character", check.names = FALSE, quote = "", comment.char = "")
B0 <- B0[as.integer(B0$b) %% CTL_CHAINE_PERIODE == 0L, , drop = FALSE]
cols <- setdiff(intersect(names(B0), names(V)), "ctl")
k0 <- paste(B0$jeu, B0$point, B0$b); kv <- paste(V$jeu, V$point, V$b)
m <- match(kv, k0)
cat("lignes du brut retrouvees :", sum(!is.na(m)), "/", nrow(V), " ; colonnes comparees :", length(cols), "\n")
cat("lignes identiques au brut (", length(cols), "colonnes ) :",
    sum(vapply(seq_len(nrow(V)), function(i) !is.na(m[i]) && identical(unname(unlist(V[i, cols])), unname(unlist(B0[m[i], cols]))), logical(1))), "\n")
cat("ctl du brut verse sur ces lignes :", paste(names(table(B0$ctl[m])), table(B0$ctl[m]), collapse = " ; "), "\n")
# p_mc des douze lignes de LIG_B effectivement comparees : nombre de finies.
nf <- vapply(seq_len(nrow(V)), function(i) sum(is.finite(num_tsv(unlist(V[i, paste0("pmc:", LIG_B)])))), 1)
cat("p_mc finies de LIG_B par replication : min", min(nf), "max", max(nf), "total", sum(nf), "sur", 12 * nrow(V), "\n")
cat(sprintf("duree : %.0f s d'horloge, %d processus ; somme des durees run_engine %.0f s, controles %.0f s\n", duree, COEURS,
            sum(as.numeric(V$duree)), sum(as.numeric(V$duree_ctl))))
