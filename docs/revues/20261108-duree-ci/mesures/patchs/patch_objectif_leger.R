# Essai (c2) : objectif sans construire la liste complete de usp_noyau().
# Memes operations flottantes, dans le meme ordre, que usp_noyau()$obj.
usp_objectif <- function(par, x, y, xbar) {
  d <- par[1]; g <- par[2]
  if (!is.finite(d) || !is.finite(g) || d < 0 || d > 1) return(1e12)
  T <- length(x)
  p <- usp_pi(d, g, x, xbar)
  r <- log(y / x)
  ln_beta <- (T / 2 + sum(p * r)) / sum(p)
  v <- r + 1 / (2 * p) - ln_beta
  o <- sum(p * v^2) - sum(log(p))
  if (!is.finite(o)) 1e12 else o
}
