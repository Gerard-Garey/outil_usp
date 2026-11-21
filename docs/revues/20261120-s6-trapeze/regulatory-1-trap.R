setwd("/home/user/outil_usp")
source("R/charger_moteur.R"); m <- charger_moteur()
d <- read.csv("tests/donnees/triangle_mw.csv"); full <- as.matrix(d[, -1]); dimnames(full) <- NULL
calc <- function(tri) {
  I <- nrow(tri) - 1; J <- ncol(tri) - 1
  f <- sapply(0:(J-1), function(j) { idx <- 0:(I-j-1); sum(tri[idx+1, j+2]) / sum(tri[idx+1, j+1]) })
  s2 <- rep(NA, J)
  for (j in 0:(J-2)) { idx <- 0:(I-j-1); s2[j+1] <- sum(tri[idx+1,j+1]*(tri[idx+1,j+2]/tri[idx+1,j+1]-f[j+1])^2)/(I-j-1) }
  direct <- if (I - J >= 1) { j <- J-1; idx <- 0:(I-j-1); sum(tri[idx+1,j+1]*(tri[idx+1,j+2]/tri[idx+1,j+1]-f[j+1])^2)/(I-j-1) } else NA
  s2[J] <- min(s2[J-1], s2[J-2], s2[J-1]^2/s2[J-2])
  Q <- s2 / f^2                      # Q[j+1] = Q_j, j = 0..J-1
  Qx <- function(j) if (j <= J-1) Q[j+1] else 0   # convention B : Q_j := 0, j >= J
  S  <- function(j) sum(tri[(0:(I-j-1))+1, j+1])
  Sp <- function(j) sum(tri[(0:(I-j))+1, j+1])
  last <- function(i) tri[i+1, min(I-i, J)+1]          # C(i, I-i), borne a J (convention B)
  Ch <- sapply(0:I, function(i) { d <- I - i; v <- last(i); if (d < J) for (j in d:(J-1)) v <- v * f[j+1]; v })
  Delta <- function(i) { d <- I - i; if (d >= J) return(0); v <- Qx(d)/S(d)
    if (d+1 <= J-1) for (j in (d+1):(J-1)) v <- v + tri[I-j+1, j+1]/Sp(j) * Q[j+1]/S(j); v }
  proc <- function(i) { d <- I - i; if (d >= J) 0 else Ch[i+1]^2 * Qx(d)/last(i) }
  ii <- 1:I
  cons <- sum(sapply(ii, function(i) proc(i) + Ch[i+1]^2*Delta(i))) +
          2*sum(sapply(ii, function(i) sum(Ch[i+1]*Ch[ii[ii > i]+1]*Delta(i))))
  v2015 <- sum(sapply(ii, proc)) + sum(sapply(ii, function(i) sum(sapply(ii, function(k) Ch[i+1]*Ch[k+1]*Delta(i)))))
  ir <- ii[ii >= I-J+1]
  v2015r <- sum(sapply(ir, proc)) + sum(sapply(ir, function(i) sum(sapply(ir, function(k) Ch[i+1]*Ch[k+1]*Delta(i)))))
  R <- sum(Ch - sapply(0:I, last))
  list(I=I, J=J, R=R, msep_cons=cons, msep_2015=v2015, msep_2015_restreinte=v2015r,
       sig_cons=sqrt(cons)/R, sig_2015=sqrt(v2015)/R, sig_2015r=sqrt(v2015r)/R,
       s2_regle=s2[J], s2_direct=direct, s2=s2)
}
# controle : carre 8x8 contre le moteur
aj <- m$mw_ajuster(full); ms <- m$mw_msep(aj)$msep
r8 <- calc(full); cat(sprintf("8x8 : moteur %.10f, script %.10f, ecart rel %.2e\n", ms, r8$msep_cons, r8$msep_cons/ms-1))
cat(sprintf("8x8 forme 2015 : sigma_est %.6f (cons %.6f)\n", r8$sig_2015, r8$sig_cons))
for (Jc in c(5,6,7)) {
  tri <- full[, 1:Jc]; for (i in 0:7) for (j in 0:(Jc-1)) if (i + j > 7) tri[i+1, j+1] <- NA
  v <- m$mw_valider_triangle(tri); r <- calc(tri)
  cat(sprintf("\n8x%d (I=%d, J=%d) : ok=%s ; motifs: %s\n", Jc, r$I, r$J, v$ok, paste(substr(v$erreurs,1,40), collapse=" | ")))
  cat(sprintf("  R=%.4f  MSEP cons(B)=%.4f sigma=%.6f | 2015(B, k=1..I)=%.4f sigma=%.6f (%+.2f%%) | 2015 restreinte=%.4f sigma=%.6f\n",
      r$R, r$msep_cons, r$sig_cons, r$msep_2015, r$sig_2015, 100*(r$sig_2015/r$sig_cons-1), r$msep_2015_restreinte, r$sig_2015r))
  cat(sprintf("  sigma2_{J-1} regle=%.6g  direct (pour information)=%.6g\n", r$s2_regle, r$s2_direct))
  cat(sprintf("  c(I+1=%d) court=%.2f long=%.2f ; c(J+1=%d) court=%.2f long=%.2f ; c(I=%d) court=%.2f\n",
      r$I+1, m$usp_credibilite(r$I+1,"court"), m$usp_credibilite(r$I+1,"long"), r$J+1,
      m$usp_credibilite(r$J+1,"court"), m$usp_credibilite(r$J+1,"long"), r$I, m$usp_credibilite(r$I,"court")))
}
