suppressMessages(source("R/engine.R"))
cas <- c("premium","premium_ii6","premium_interieur","premium_net","reserve1")
for (cc in cas) {
  res <- readRDS(file.path("tests/reference", paste0(cc, ".rds")))
  tb <- engine_table_tests(res)
  sel <- grepl("^[BC]\\.", tb$famille)
  tb <- tb[sel, ]
  cat("\n=====", cc, " regime:", paste(names(res$ajustement)[1:8], collapse=","), "\n"); cat("delta_hat =", format(res$ajustement$delta), "\n")
  cols <- intersect(c("test","type","stat","p_exacte","p_asymptotique","p_mc","p_retenue","nature_p","verdict","p_min","p_min_mc","inoperant","sens_du_test"), names(tb))
  out <- tb[, cols]
  for (k in c("stat","p_exacte","p_asymptotique","p_mc","p_retenue","p_min","p_min_mc")) if (k %in% names(out)) out[[k]] <- signif(out[[k]], 3)
  out$nature_p <- substr(out$nature_p, 1, 38)
  out$test <- substr(out$test, 1, 48)
  print(out, row.names = FALSE, right = FALSE)
}
cat("\nColonnes disponibles:", paste(names(engine_table_tests(readRDS("tests/reference/premium.rds"))), collapse=", "), "\n")
