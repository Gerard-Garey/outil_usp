S <- Sys.getenv("S")
ph <- "verdict sensible a l'alea de simulation (p a moins de 2 erreurs de Monte-Carlo du seuil)"
for (n in c("premium","premium_ii6","premium_interieur","premium_net","reserve1","reserve2")) { r <- readRDS(file.path(S, paste0("dump_", n, ".rds")))
  k <- which(grepl(ph, r$detail, fixed=TRUE)); cat(n, length(k), "lignes:", paste(k, collapse=","), "\n")
  for (i in k) cat("   ", i, r$test[i], "| fin:", substring(r$detail[i], nchar(r$detail[i])-120), "\n") }
