# Essai (c1) : memoisation du dernier usp_noyau() dans usp_ajuster_rapide().
# optim(L-BFGS-B) appelle fn puis gr au meme point : le noyau etait calcule deux fois.
# Les fonctions appelees et l'ordre des operations flottantes sont inchanges.
usp_ajuster_rapide <- function(x, y, d0, g0) {
  xbar <- mean(x)
  dern_par <- NULL; dern_k <- NULL
  noyau <- function(par) {
    if (!identical(par, dern_par)) {
      dern_k <<- usp_noyau(par[1], par[2], x, y, xbar); dern_par <<- par
    }
    dern_k
  }
  fn <- function(par, x, y, xbar) {
    d <- par[1]; g <- par[2]
    if (!is.finite(d) || !is.finite(g) || d < 0 || d > 1) return(1e12)
    o <- noyau(par)$obj
    if (!is.finite(o)) 1e12 else o
  }
  gr <- function(par, x, y, xbar) {
    k <- noyau(par); delta <- par[1]; gamma <- par[2]
    e <- exp(2 * gamma)
    a <- delta + (1 - delta) * xbar / x
    s <- k$z^2 - 1 - k$z / sqrt(k$pi)
    g <- c(delta = sum(-k$pi * e * (1 - xbar / x) / (1 + e * a) * s),
           gamma = sum(-k$pi * 2 * e * a / (1 + e * a) * s))
    if (all(is.finite(g)) || !identical(fn(par, x, y, xbar), 1e12)) g
    else c(delta = 0, gamma = 0)
  }
  best <- NULL
  for (d_dep in c(d0, 0, 1)) {
    f <- try(stats::optim(c(d_dep, g0), fn, gr = gr,
                          x = x, y = y, xbar = xbar,
                          method = "L-BFGS-B",
                          lower = c(0, BORNES_GAMMA[1]), upper = c(1, BORNES_GAMMA[2]),
                          control = list(factr = 1e4, maxit = 200)), silent = TRUE)
    if (inherits(f, "try-error") || !is.finite(f$value)) next
    if (is.null(best) || f$value < best$value - 1e-10) best <- f
  }
  if (is.null(best)) stop("Reajustement rapide : aucun demarrage abouti.")
  k <- usp_noyau(best$par[1], best$par[2], x, y, xbar)
  c(k, list(delta = best$par[1], gamma = best$par[2], T = length(x),
            x = x, y = y, xbar = xbar))
}
