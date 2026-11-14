source("R/charger_moteur.R"); charger_moteur()
tri <- function(I, J, f = 1.3, base = 100) {   # I+1 annees d'accident, J+1 colonnes
  m <- matrix(NA_real_, I + 1, J + 1)
  for (i in 0:I) for (j in 0:J) if (i + j <= I) m[i + 1, j + 1] <- (base + 10 * (i+1) + j+1) * f^j
  m
}
cat("== carre 8x8\n"); r <- mw_valider_triangle(tri(7,7)); str(r[c("ok","erreurs","I","J")])
cat("== triangle 6 x 8 (I<J: 6 lignes, 8 colonnes)\n")
m <- matrix(NA_real_, 6, 8); for (i in 0:5) for (j in 0:7) if (i+j<=5) m[i+1,j+1] <- (100+i+j)*1.3^j
r <- mw_valider_triangle(m); print(r$erreurs); cat("I,J:", r$I, r$J, "\n")
cat("== trapeze 8 x 6 (I>J)\n")
m <- matrix(NA_real_, 8, 6); for (i in 0:7) for (j in 0:5) if (i+j<=7) m[i+1,j+1] <- (100+i+j)*1.3^j
r <- mw_valider_triangle(m); print(r$erreurs); cat("I,J:", r$I, r$J, "\n")
cat("== trapeze 6x5\n")
m <- matrix(NA_real_, 6, 5); for (i in 0:5) for (j in 0:4) if (i+j<=5) m[i+1,j+1] <- (100+i+j)*1.3^j
print(mw_valider_triangle(m)$erreurs)
cat("== run_engine reserve2 8x6 et 6x8\n")
m86 <- matrix(NA_real_, 8, 6); for (i in 0:7) for (j in 0:5) if (i+j<=7) m86[i+1,j+1] <- (100+i+j)*1.3^j
m68 <- matrix(NA_real_, 6, 8); for (i in 0:5) for (j in 0:7) if (i+j<=5) m68[i+1,j+1] <- (100+i+j)*1.3^j
for (nm in c("m86","m68")) {
  r <- run_engine(methode="reserve2", triangle=get(nm), segment=1, annexe="II", B=99)
  cat(nm, ": ok =", r$ok, "\n"); print(r$validation$erreurs)
}
cat("== 5x6 (cbind(triangle5, NA))  : 5 lignes 6 colonnes\n")
m <- matrix(NA_real_, 5, 6); for (i in 0:4) for (j in 0:4) if (i+j<=4) m[i+1,j+1] <- (100+i+j)*1.3^j
print(mw_valider_triangle(m)$erreurs)
cat("== 8x8 carre via run_engine : ok\n")
r <- run_engine(methode="reserve2", triangle=tri(7,7), segment=1, annexe="II", B=99); cat(r$ok, "\n")
