source("R/engine.R")
cas <- c("premium","premium_ii6","premium_interieur","premium_net","reserve1")
for (cc in cas) {
  res <- readRDS(file.path("tests/reference", paste0(cc, ".rds")))
  tt <- engine_table_tests(res)
  sel <- grepl("^(F|G)\\.", tt$famille)
  cat("\n=====", cc, " delta_hat=", res$ajustement$delta, " bord=", res$ajustement$delta_au_bord, " sigma_usp=", res$parametre_final$sigma_usp, "\n")
  cols <- intersect(c("famille","test","stat","estim","p_exacte","p_asymptotique","p_mc","err_mc","p_retenue","nature_p","verdict","inoperant","p_min_mc"), names(tt))
  print(tt[sel, cols], digits = 4, right = FALSE)
}
