source(file.path(Sys.getenv("S"), "pre.R"))
r <- run_engine(xt = rep(100, 5), yt = c(60, 80, 80, 80, 110), methode = "reserve1", segment = 1, annexe = "II", B = 99)
for (t in r$tests) if (grepl("suites", t$test)) cat(paste0("[", t$test, "] type=", t$type, "\n   loi=", paste(t$loi, collapse="/"), "\n   effectifs=", paste(t$effectifs, collapse="/"), "\n   detail=", t$detail, "\n   p_retenue=", t$p_retenue, " p_exacte=", t$p_exacte, " p_mc=", t$p_mc, "\n"))
