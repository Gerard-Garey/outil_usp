# Profile un fichier de test unitaire lance comme par Rscript (meme repertoire)
f <- commandArgs(TRUE)[1]
setwd("/home/user/outil_usp")
out <- sprintf("/tmp/duree-ci/rprof_fichier_%s.out", sub("[.]R$", "", basename(f)))
Rprof(out, interval = 0.02)
t <- system.time(try(sys.source(f, envir = new.env(parent = globalenv())), silent = TRUE))
Rprof(NULL)
cat("DUREE", basename(f), t[[3]], "\n")
s <- summaryRprof(out)
bt <- s$by.total
garde <- c("system2","run_engine","usp_bootstrap","mw_bootstrap","usp_lr_delta","usp_tests","mw_tests","sw_loi_nulle",
  "usp_permutation_pente","engine_plots_data","mw_plots_data","usp_ajuster","usp_jackknife","usp_profil","verifier","executer_cas",
  "charger_moteur","sys.source","usp_ajuster_rapide","stats::lm","dw_p_exacte","mk_p_exacte","engine_rang_simultane_dh",
  "usp_puissance_enveloppe_h2","dw_puissance_ar1","engine_enveloppe_qq","usp_controles_numeriques","usp_hessienne","engine_p_famille",
  "mw_msep","mw_ajuster","engine_surface_objectif","cmpfun","parse","readLines","grepl","gsub","regmatches")
print(bt[intersect(garde, rownames(bt)), 1:2])
print(head(s$by.self[, 1:2], 12))
