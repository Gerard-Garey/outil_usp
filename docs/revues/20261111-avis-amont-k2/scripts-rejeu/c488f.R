tf <- tempfile(); utils::write.csv(data.frame(g = c(1/3, 1.7976931348623157e308, 0.1)), tf, row.names = FALSE); cat(readLines(tf), sep = "\n")
cat("lu :", format(utils::read.csv(tf)$g, digits = 17), "\n")
