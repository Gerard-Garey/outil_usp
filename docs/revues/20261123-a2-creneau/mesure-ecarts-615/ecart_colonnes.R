source("R/charger_moteur.R"); charger_moteur()
e <- environment(run_engine)
tri_ref <- local({ d <- utils::read.csv("tests/donnees/triangle_mw.csv"); m <- as.matrix(d[, setdiff(names(d), "i")]); storage.mode(m) <- "double"; unname(m)})
tri615 <- function(rho, jstar = 5L, t = tri_ref) {
  I <- nrow(t) - 1L; J <- ncol(t) - 1L
  f <- e$mw_ajuster(t)$f[jstar + 1L]
  F0 <- t[, -1L, drop = FALSE] / t[, -ncol(t), drop = FALSE]
  n <- I - jstar; u <- seq(-1, 1, length.out = n)
  nt <- t
  nt[seq_len(n), jstar + 2L] <- nt[seq_len(n), jstar + 1L] * f * (1 + rho * u)
  nt
}
for (js in c(2L,5L)) for (rho in c(5e-13, 1e-12, 1e-11)) {
  t <- tri615(rho, js); n <- nrow(t)-1L-js
  C0 <- t[1:n, js+1]; C1 <- t[1:n, js+2]
  ec <- e$.mw_ecart_facteur_stable(C0, C1)
  cat(js, rho, n, paste(sprintf("%a", C0), collapse=","), paste(sprintf("%a", C1), collapse=","), paste(sprintf("%a", ec), collapse=","), "\n", sep="|")
}
