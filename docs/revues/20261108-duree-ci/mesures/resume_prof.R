f <- commandArgs(TRUE)[1]
s <- summaryRprof(f)
bt <- s$by.total; rownames(bt) <- gsub("\"", "", rownames(bt))
garde <- c("system2","run_engine","usp_bootstrap","mw_bootstrap","usp_lr_delta","usp_tests","mw_tests","sw_loi_nulle",
  "usp_permutation_pente","engine_plots_data","mw_plots_data","usp_ajuster","usp_jackknife","usp_profil","executer_cas",
  "charger_moteur","usp_ajuster_rapide","stats::lm","lm","dw_p_exacte","mk_p_exacte","engine_rang_simultane_dh",
  "usp_puissance_enveloppe_h2","dw_puissance_ar1","engine_enveloppe_qq","usp_controles_numeriques","usp_hessienne","engine_p_famille",
  "mw_msep","mw_ajuster","engine_surface_objectif","cmpfun","parse","readLines","engine_sous_graine",".mc_evaluer","usp_simuler","mw_simuler_triangle",
  "optim","stats::optim","verifier","withCallingHandlers")
cat("echantillons :", s$sampling.time, "s\n")
print(bt[intersect(garde, rownames(bt)), 1:2])
print(head(s$by.self[, 1:2], 12))
