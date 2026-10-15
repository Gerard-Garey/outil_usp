suppressMessages(source("R/engine.R"))
for (cas in c("premium","premium_interieur","reserve2")) {
  res <- readRDS(file.path("tests/reference", paste0(cas, ".rds")))
  tt <- engine_table_tests(res)
  cat("\n=====", cas, " nrow =", nrow(tt), " delta =", if (!is.null(res$fit$delta)) res$fit$delta else NA, "\n")
  cat("colonnes:", paste(names(tt), collapse=", "), "\n")
  cat("-- type:\n"); print(table(tt$type, useNA="ifany"))
  cat("-- verdict:\n"); print(table(tt$verdict, useNA="ifany"))
  cat("-- nature_p:\n"); print(table(tt$nature_p, useNA="ifany"))
  cat("-- inoperant:\n"); print(table(tt$inoperant, useNA="ifany"))
  cat("-- lignes (test, famille, type, verdict, p_ex, p_as, p_mc, p_ret, nature, p_min, p_min_mc):\n")
  pc <- intersect(c("test","famille","type","verdict","p_exacte","p_asymptotique","p_monte_carlo","p_retenue","nature_p","p_min","p_min_mc","sens_du_test"), names(tt))
  d <- tt[, pc]
  for (k in c("p_exacte","p_asymptotique","p_monte_carlo","p_retenue","p_min","p_min_mc")) if (k %in% names(d)) d[[k]] <- signif(d[[k]], 3)
  d$nature_p <- substr(d$nature_p, 1, 38); d$test <- substr(d$test, 1, 52)
  print(d, row.names = FALSE, right = FALSE)
}
