S <- Sys.getenv("S")
cas <- c("premium","premium_ii6","premium_interieur","premium_net","reserve1","reserve2")
for (n in cas) { r <- readRDS(file.path(S, paste0("dump_", n, ".rds")))
  cat("=====", n, "\n")
  k <- which(grepl("ESD|Rosner|Grubbs", r$test))
  for (i in k) cat(i, "|", r$test[i], "|\n  loi:", r$loi[i], "\n  detail:", r$detail[i], "\n  nchar detail:", nchar(r$detail[i]), "\n")
  cat("occ 'sous i.i.d. normal' dans loi:", sum(grepl("exacte sous i.i.d. normal", r$loi)), " dans detail:", sum(grepl("exacte sous i.i.d. normal", r$detail)), "\n")
  cat("occ '(n >= 25)' detail:", sum(grepl("(n >= 25)", r$detail, fixed=TRUE)), " 'n = 25' detail:", sum(grepl("n = 25", r$detail, fixed=TRUE)), "\n")
}
