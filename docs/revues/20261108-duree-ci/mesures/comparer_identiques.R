a <- commandArgs(TRUE)
for (nom in c("premium","reserve1","reserve2","premium_ii6","premium_net","premium_interieur")) {
  f1 <- sprintf("/tmp/duree-ci/res_%s_%s.rds", a[1], nom); f2 <- sprintf("/tmp/duree-ci/res_%s_%s.rds", a[2], nom)
  if (file.exists(f1) && file.exists(f2)) cat(sprintf("%-18s identical = %s\n", nom, identical(readRDS(f1), readRDS(f2))))
}
