for (n in c("premium","premium_ii6","premium_interieur","premium_net","reserve1","reserve2")) { x <- readRDS(file.path("tests/reference", paste0(n, ".rds")))
  ty <- vapply(x$tests, function(t) t$type, ""); cat(n, "types non applicable:", sum(ty == "non applicable"), "\n") }
