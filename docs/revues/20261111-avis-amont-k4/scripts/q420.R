S <- Sys.getenv("S")
for (n in c("premium","premium_ii6","premium_interieur","premium_net","reserve1","reserve2")) { r <- readRDS(file.path(S, paste0("dump_", n, ".rds")))
  k <- which(grepl("tres correlee", r$detail)); cat(n, ": lignes", paste(k, collapse=","), "\n")
  for (i in k) cat("   [", r$test[i], "] nchar=", nchar(r$detail[i]), "\n   ", r$detail[i], "\n") }
