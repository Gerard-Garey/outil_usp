source(file.path(Sys.getenv("S"), "pre.R"))
r <- run_engine(xt = rep(100, 5), yt = c(60, 80, 80, 80, 110), methode = "reserve1", segment = 1, annexe = "II", B = 99)
for (t in r$tests) if (identical(t$type, "non applicable")) cat(sprintf("%-65s | loi: %s\n", t$test, paste(t$loi, collapse="/")))
