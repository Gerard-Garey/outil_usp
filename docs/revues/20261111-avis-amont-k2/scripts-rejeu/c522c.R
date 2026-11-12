source("/tmp/claude-0/-home-user-outil-usp/9cb815f0-8197-554a-a7db-4a6f9f874cc0/scratchpad/k2-etape1/outils.R")
d <- data.frame(a = 1:8, b = 1:8, c = 1:8); names(d) <- c("a\001b", "x\tt\n", "y\033[31mt")
r <- engine_lire_donnees_csv(d)
b <- charToRaw(r$erreurs); cat("octets de controle dans le message :", paste(sprintf("%02X", as.integer(b[b < 0x20])), collapse = " "), "\n")
# Convention I, J d'un triangle 8x8 sans decalage
M <- matrix(NA_real_, 8, 8); for (k in 1:8) for (j in 1:(8-k+1)) M[k,j] <- 100*k + 10*j + j^2
t0 <- engine_lire_triangle(as.data.frame(M)); cat("triangle 8x8 direct : ok =", t0$ok, " I =", t0$I, " J =", t0$J, " dim =", dim(t0$triangle), "\n")
