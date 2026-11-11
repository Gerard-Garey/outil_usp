suppressMessages({source("R/charger_moteur.R"); m <- charger_moteur()})
r <- m$run_engine(xt = rep(100, 5), yt = c(60, 80, 80, 80, 110), methode = "reserve1", segment = 1, annexe = "II", B = 99)
for (l in r$tests) if (identical(l$type, "non applicable")) cat(sprintf("[%s]\n  loi=%s\n  detail=%s\n", l$test, l$loi, substr(l$detail,1,160)))
