S <- Sys.getenv("S")
cas <- c("premium","premium_ii6","premium_interieur","premium_net","reserve1","reserve2")
pats <- c(ind="loi classique INDICATIVE", comb="loi combinatoire EXACTE de R", combz="^loi combinatoire EXACTE de R$", combr="pi_t constant : r_t i.i.d.", combvar="loi combinatoire de R, exacte a pi_t constant seulement")
for (n in cas) { r <- readRDS(file.path(S, paste0("dump_", n, ".rds")))
  cat("==", n, " lignes 'non applicable' (inoperant n'est pas le type; on compte detail 'test non applicable'):", sum(grepl("test non applicable", r$detail)), "\n")
  for (p in names(pats)) { k <- which(grepl(pats[p], r$loi)); cat("  ", p, length(k), ": ", paste0(k, "=", r$test[k], collapse=" ; "), "\n") } }
