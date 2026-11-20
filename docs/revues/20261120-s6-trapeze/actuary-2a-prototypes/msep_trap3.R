# Prototype hors depot : MSEP du trapeze (convention B) vs CL_MSEPs (ChainLadder 0.2.21, M. Wuthrich)
setwd("/home/user/outil_usp")
source("R/charger_moteur.R"); charger_moteur()
cl_env <- new.env()
src <- readLines("/tmp/claude-0/-home-user-outil-usp/8f991392-3bf5-5fd0-a4b8-27e588ed5637/scratchpad/cl/src/ChainLadder/R/MWChainLadder.R")
debut <- grep("^CL_MSEPs <- function", src); fin <- grep("^CDR.MackChainLadder", src) - 1
eval(parse(text = src[debut:fin]), envir = cl_env)
df <- utils::read.csv("tests/donnees/triangle_mw.csv")
tri8 <- as.matrix(df[, -1]); dimnames(tri8) <- NULL
# Ajustement independant, transcription directe de D(4)(c), D(5)(b)-(d), convention (B)
ajuste_B <- function(tri) {
  I <- nrow(tri) - 1; J <- ncol(tri) - 1
  f <- s2 <- numeric(J); s2d <- NA
  for (j in 0:(J-1)) { r <- 0:(I-j-1); f[j+1] <- sum(tri[r+1, j+2]) / sum(tri[r+1, j+1]) }
  for (j in 0:(J-2)) { r <- 0:(I-j-1)
    s2[j+1] <- sum(tri[r+1,j+1] * (tri[r+1,j+2]/tri[r+1,j+1] - f[j+1])^2) / (I-j-1) }
  s2[J] <- min(s2[J-1], s2[J-2], s2[J-1]^2 / s2[J-2])
  if (I - J >= 1) { r <- 0:(I-J); s2d <- sum(tri[r+1,J] * (tri[r+1,J+1]/tri[r+1,J] - f[J])^2) / (I-J) }
  list(I = I, J = J, f = f, s2 = s2, s2_direct = s2d)
}
msep_B <- function(tri, a) {
  I <- a$I; J <- a$J; f <- a$f; Q <- a$s2 / f^2
  S <- sapply(0:(J-1), function(j) sum(tri[(0:(I-j-1))+1, j+1]))
  Sp <- sapply(0:(J-1), function(j) sum(tri[(0:(I-j))+1, j+1]))
  lat <- sapply(0:I, function(i) tri[i+1, min(I-i, J)+1])
  Cu <- sapply(0:I, function(i) { d <- min(I-i, J); v <- lat[i+1]; if (d < J) for (j in d:(J-1)) v <- v * f[j+1]; v })
  ii <- (I-J+1):I
  D <- sapply(ii, function(i) { k <- I-i; v <- Q[k+1]/S[k+1]
    if (k+1 <= J-1) for (j in (k+1):(J-1)) v <- v + tri[I-j+1, j+1]/Sp[j+1] * Q[j+1]/S[j+1]; v })
  names(D) <- ii
  t1 <- sum(sapply(ii, function(i) Cu[i+1]^2 * Q[I-i+1] / lat[i+1]))
  t2 <- 0
  for (i in ii) for (k in ii) t2 <- t2 + Cu[i+1]*Cu[k+1]*D[as.character(min(i,k))]
  list(msep = t1 + t2, reserve = sum(Cu - lat), Cu = Cu, lat = lat)
}
cl_msep <- function(tri, a) {
  I0 <- nrow(tri); J0 <- ncol(tri); I <- I0-1; J <- J0-1
  full <- tri
  for (i in 0:I) { d <- I - i; if (d < J) for (j in (d+1):J) full[i+1, j+1] <- full[i+1, j] * a$f[j] }
  Sp <- sapply(0:(J-1), function(j) sum(tri[(0:(I-j))+1, j+1]))
  alpha <- sapply(0:(J-1), function(j) tri[I-j+1, j+1]) / Sp
  param <- data.frame(f = a$f, sigma2 = a$s2, ratio = a$s2 / a$f^2, alpha = alpha)
  r <- cl_env$CL_MSEPs(full, I0, J0, param)
  list(msep = r[I0+1, 2], reserve = r[I0+1, 1])
}
ta <- matrix(c(357848, 352118, 290507, 310608, 443160, 396132, 440832, 359480, 376686, 344014,
  1124788, 1236139, 1292306, 1418858, 1136350, 1333217, 1288463, 1421128, 1363294, NA,
  1735330, 2170033, 2218525, 2195047, 2128333, 2180715, 2419861, 2864498, NA, NA,
  2218270, 3353322, 3235179, 3757447, 2897821, 2985752, 3483130, NA, NA, NA,
  2745596, 3799067, 3985995, 4029929, 3402672, 3691712, NA, NA, NA, NA,
  3319994, 4120063, 4132918, 4381982, 3873311, NA, NA, NA, NA, NA,
  3466336, 4647867, 4628910, 4588268, NA, NA, NA, NA, NA, NA,
  3606286, 4914039, 4909315, NA, NA, NA, NA, NA, NA, NA,
  3833515, 5339085, NA, NA, NA, NA, NA, NA, NA, NA,
  3901463, NA, NA, NA, NA, NA, NA, NA, NA, NA), 10, 10)
out <- NULL
for (J1 in c(10, 9, 7, 5)) {
  tri <- ta[, 1:J1]; a <- ajuste_B(tri); m <- msep_B(tri, a); c <- cl_msep(tri, a)
  out <- rbind(out, data.frame(geom = sprintf("10x%d", J1), msep_B = m$msep, msep_CL = c$msep,
    ecart_rel = abs(m$msep - c$msep)/c$msep, R = m$reserve, s2_regle = a$s2[a$J], s2_direct = a$s2_direct))
}
print(out, digits = 15)
aj <- mw_ajuster(ta); cat(sprintf("moteur 10x10 : %.10f ; racine %.6f\n", mw_msep(aj)$msep, sqrt(mw_msep(aj)$msep)))
