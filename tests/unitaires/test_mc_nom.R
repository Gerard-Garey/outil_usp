###############################################################################
#  tests/unitaires/test_mc_nom.R  --  CHAMP DE LIGNE mc_nom (#330)
#
#  add() d'engine_registre_tests() pose sur chaque ligne le nom de sa
#  statistique Monte-Carlo dans le catalogue de la methode (USP_CATALOGUE_MC,
#  MW_CATALOGUE_MC), en cinquieme champ de fin de ligne, apres p_min_mc :
#  l'argument mc_nom tel quel, NA_character_ pour une p Monte-Carlo externe
#  (p_mc_ext : usp_lr_delta(), usp_permutation_pente()) ou une ligne sans p
#  Monte-Carlo du bootstrap. engine_table_tests() l'expose en colonne mc_nom,
#  apres p_min_mc. Forme decidee par le mainteneur (Q-41-3, 24/10/2026).
#  La lecture par granularite_lignes() (R/display_helpers.R) est testee dans
#  test_rapport_html.R (#285).
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_mc_nom.R")

FIN330 <- c("p_min", "fonction", "inoperant", "p_min_mc", "mc_nom")
EXTERNES330 <- c("usp_lr_delta", "usp_permutation_pente")

# Invariants du champ sur une liste de lignes de res$tests, catalogue et
# objet bootstrap de la methode. Rend TRUE ou un message.
inv330 <- function(tt, catalogue, boot) {
  ordre <- vapply(tt, function(l) identical(utils::tail(names(l), 5L), FIN330), NA)
  if (!all(ordre)) return(paste("ordre des champs de fin de ligne faux :", sum(!ordre), "ligne(s)"))
  type <- vapply(tt, function(l) is.character(l$mc_nom) && length(l$mc_nom) == 1L &&
                   is.null(names(l$mc_nom)) && (is.na(l$mc_nom) || nzchar(l$mc_nom)), NA)
  if (!all(type)) return(paste("mc_nom non chaine scalaire sans nom :", sum(!type), "ligne(s)"))
  m <- vapply(tt, function(l) l$mc_nom, "")
  k <- !is.na(m)
  if (!any(k)) return("aucune ligne a mc_nom renseigne")
  if (!all(m[k] %in% names(catalogue))) return(paste("mc_nom hors catalogue :",
                                                  paste(setdiff(m[k], names(catalogue)), collapse = ", ")))
  # p et erreur Monte-Carlo de la ligne : celles du bootstrap pour sa statistique.
  lu <- vapply(which(k), function(i) identical(tt[[i]]$p_mc, unname(boot$p_mc[[m[i]]])) &&
                 identical(tt[[i]]$err_mc, unname(boot$err_mc[[m[i]]])), NA)
  if (!all(lu)) return(paste("p_mc ou err_mc differente de celle du bootstrap :", sum(!lu), "ligne(s)"))
  # Sans mc_nom : aucune p Monte-Carlo, ou p Monte-Carlo externe.
  f <- vapply(tt, function(l) l$fonction, "")
  pm <- vapply(tt, function(l) l$p_mc, numeric(1))
  sans <- !k & is.finite(pm) & !f %in% EXTERNES330
  if (any(sans)) return(paste("p Monte-Carlo finie sans mc_nom hors p externe :", sum(sans), "ligne(s)"))
  if (any(k & f %in% EXTERNES330)) return("ligne a p externe avec mc_nom")
  TRUE
}

## --- Six cas de reference versionnes -----------------------------------------
verifier("#330 references : mc_nom cinquieme champ de fin de ligne, chaine du catalogue ou NA, p et erreur MC lues au bootstrap pour sa statistique",
         {
           cas <- c("premium", "reserve1", "reserve2", "premium_ii6", "premium_net", "premium_interieur")
           v <- lapply(cas, function(k) {
             f <- file.path(RACINE, "tests", "reference", paste0(k, ".rds"))
             if (!file.exists(f)) return("reference absente")
             r <- readRDS(f)
             inv330(r$tests, if (identical(k, "reserve2")) MW_CATALOGUE_MC else USP_CATALOGUE_MC, r$bootstrap)
           })
           ok <- vapply(v, isTRUE, logical(1))
           if (all(ok)) TRUE else paste(cas[!ok], unlist(v[!ok]), collapse = " ; ")
         })

## --- Calcul a B = 99 -------------------------------------------------------------
.ln330 <- utils::read.csv(file.path(RACINE, "tests", "donnees", "donnees_ln.csv"))
.tri330 <- local({
  d <- utils::read.csv(file.path(RACINE, "tests", "donnees", "triangle_mw.csv"))
  m <- as.matrix(d[, setdiff(names(d), "i")]); storage.mode(m) <- "double"; unname(m)
})
res330_p <- run_engine(xt = .ln330$xt, yt = .ln330$yt, methode = "premium", segment = 1, annexe = "II",
                       nature_donnees = "brutes", B = 99)
res330_r2 <- run_engine(methode = "reserve2", triangle = .tri330, segment = 1, annexe = "II", B = 99)
verifier("#330 run_engine() B = 99 (premium, reserve2) : memes invariants",
         isTRUE(res330_p$ok) && isTRUE(res330_r2$ok) &&
           isTRUE(inv330(res330_p$tests, USP_CATALOGUE_MC, res330_p$bootstrap)) &&
           isTRUE(inv330(res330_r2$tests, MW_CATALOGUE_MC, res330_r2$bootstrap)))
verifier("#330 premium : lignes du rapport de vraisemblance sur delta (usp_lr_delta), p Monte-Carlo externe finie, mc_nom NA",
         {
           lr <- Filter(function(l) identical(l$fonction, "usp_lr_delta"), res330_p$tests)
           length(lr) > 0L && any(vapply(lr, function(l) is.finite(l$p_mc), NA)) &&
             all(vapply(lr, function(l) identical(l$mc_nom, NA_character_), NA))
         })

## --- engine_table_tests() -----------------------------------------------------
verifier("#330 engine_table_tests() : colonne mc_nom juste apres p_min_mc, alignee sur le champ ; NA pour un objet anterieur au champ ; fin de table inchangee",
         {
           tb <- engine_table_tests(res330_r2); n <- names(tb)
           anc <- res330_r2; anc$tests <- lapply(anc$tests, function(l) { l$mc_nom <- NULL; l })
           ta <- engine_table_tests(anc)
           match("mc_nom", n) == match("p_min_mc", n) + 1L &&
             identical(utils::tail(n, 2L), c("fonction", "inoperant")) &&
             identical(tb$mc_nom, vapply(res330_r2$tests, function(l) l$mc_nom, "")) &&
             is.character(ta$mc_nom) && all(is.na(ta$mc_nom)) &&
             identical(ta[names(ta) != "mc_nom"], tb[names(tb) != "mc_nom"])
         })

## --- add() en appel direct ---------------------------------------------------------
# Bootstrap du cas premium a B = 99 ; DW du catalogue lognormal. Ligne a
# motif Monte-Carlo (p_mc de DW retiree, motif non degenere) : mc_nom garde
# l'argument recu.
verifier("#330 add() direct : mc_nom recu ; NA sans mc_nom, avec p_mc_ext, et conserve sous motif Monte-Carlo",
         {
           b <- res330_p$bootstrap
           reg <- engine_registre_tests(b, USP_CATALOGUE_MC, 0.10, nature_mc = "Monte-Carlo")
           reg$add("F.", "avec", "r", stat = 1, mc_nom = "DW", fonction = "stat_dw")
           reg$add("F.", "sans", "r", type = "diagnostic", fonction = "usp_tests")
           reg$add("F.", "externe", "r", type = "diagnostic", p_mc_ext = 0.5, err_mc_ext = 0.05,
                   fonction = "usp_lr_delta")
           b2 <- b; b2$p_mc[["DW"]] <- NA_real_; b2$err_mc[["DW"]] <- NA_real_
           b2$motif_mc[["DW"]] <- MOTIF_MC_AUCUNE_REPLIC
           reg2 <- engine_registre_tests(b2, USP_CATALOGUE_MC, 0.10, nature_mc = "Monte-Carlo")
           reg2$add("F.", "motif", "r", stat = 1, mc_nom = "DW", fonction = "stat_dw")
           l <- reg$lignes(); l2 <- reg2$lignes()
           identical(vapply(l, function(x) x$mc_nom, ""), c("DW", NA_character_, NA_character_)) &&
             identical(l[[3]]$p_mc, 0.5) &&
             identical(l2[[1]]$mc_nom, "DW") && !is.finite(l2[[1]]$p_mc) &&
             all(vapply(c(l, l2), function(x) identical(utils::tail(names(x), 5L), FIN330), NA)) &&
             leve_erreur(reg$add("F.", "deux", "r", mc_nom = "DW", p_mc_ext = 0.5, fonction = "stat_dw"))
         })

fin_fichier()
