S <- Sys.getenv("S")
cas <- c("premium","premium_ii6","premium_interieur","premium_net","reserve1","reserve2")
d <- lapply(cas, function(n) readRDS(file.path(S, paste0("dump_", n, ".rds")))); names(d) <- cas
cat("--- #528 : H0 == 'les residus standardises suivent une loi normale'\n")
for (n in cas) { r <- d[[n]]; k <- which(r$H0 %in% "les residus standardises suivent une loi normale"); cat(n, length(k), "lignes:", paste(k, collapse=","), "\n") }
cat("--- autres H0 contenant 'normal' (hors H0n), par cas\n")
for (n in cas) { r <- d[[n]]; k <- which(grepl("normal", r$H0) & !(r$H0 %in% "les residus standardises suivent une loi normale")); for (i in k) cat(n, i, "|", r$test[i], "| H0:", r$H0[i], "\n") }
