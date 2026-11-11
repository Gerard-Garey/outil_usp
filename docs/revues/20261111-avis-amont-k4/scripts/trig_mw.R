source(file.path(Sys.getenv("S"), "pre.R"))
tri <- .tri
show <- function(id, v) { cat(sprintf("--- %s | ok=%s\n", id, v$ok)); for (e in v$erreurs) cat("  ERR:", e, "\n"); for (e in v$avertissements) cat("  AVT:", e, "\n") }
dim(tri) |> print()
show("M0 valide", mw_valider_triangle(tri, segment=1L, annexe="II"))
T4 <- matrix(NA_real_, 4, 4); for (i in 0:3) for (j in 0:3) if (i+j<=3) T4[i+1,j+1] <- 100*(j+1)
show("M2/M3 grille 4x4 (T<5)", mw_valider_triangle(T4, segment=1L, annexe="II"))
t1 <- tri; t1[1,3] <- NA; show("M6 cellule manquante", mw_valider_triangle(t1, segment=1L, annexe="II"))
t2 <- tri; t2[1,3] <- -5; show("M8 cumul <=0", mw_valider_triangle(t2, segment=1L, annexe="II"))
t3 <- tri; t3[1,3] <- 1e120; show("M9 domaine", mw_valider_triangle(t3, segment=1L, annexe="II"))
t3b <- tri; t3b[1,3] <- Inf; show("M7 Inf (direct)", mw_valider_triangle(t3b, segment=1L, annexe="II"))
t3c <- tri; t3c[1,3] <- NaN; show("M7b NaN (direct)", mw_valider_triangle(t3c))
show("M1 non matrice (direct)", mw_valider_triangle(as.data.frame(tri)))
nc <- tri[, 1:6]; show("M5 non carre 8x6 (import)", mw_valider_triangle(nc))
nr <- tri[1:6, ]; show("M4/M5 non carre 6x8 (import)", mw_valider_triangle(nr))
t5 <- tri; rownames(t5) <- c("a","a",3:8); show("M10 noms doublon (direct)", mw_valider_triangle(t5))
t6 <- tri; rownames(t6) <- c("", "b", 3:8); show("M10b nom vide (direct)", mw_valider_triangle(t6))
show("M11 bareme (direct)", mw_valider_triangle(tri, bareme="moyen"))
# avertissements
t7 <- tri; t7[8,8] <- 5; show("MA1 sous diagonale", mw_valider_triangle(t7, segment=1L, annexe="II"))
t8 <- tri; t8[1,5] <- t8[1,4]*0.9; show("MA2 decroissant", mw_valider_triangle(t8, segment=1L, annexe="II"))
# post-ajustement refus
tr <- tri; tr[] <- NA_real_
R0 <- matrix(NA_real_, 8, 8); for (i in 0:7) for (j in 0:7) if (i+j<=7) R0[i+1,j+1] <- 1000 + i  # f_j = 1 -> reserve nulle
r <- run_engine(methode="reserve2", triangle=R0, segment=1L, annexe="II", B=99)
cat("--- MP1 reserve nulle (f_j=1) ok=", r$ok, "\n"); for (e in r$validation$erreurs) cat("  ERR:", e, "\n")
D0 <- matrix(NA_real_, 8, 8); for (i in 0:7) for (j in 0:7) if (i+j<=7) D0[i+1,j+1] <- 1000*1.5^j
r <- run_engine(methode="reserve2", triangle=D0, segment=1L, annexe="II", B=99)
cat("--- MP2 degenere ok=", r$ok, "\n"); for (e in r$validation$erreurs) cat("  ERR:", e, "\n")
# nature MW (direct)
r <- run_engine(methode="reserve2", triangle=tri, segment=1L, annexe="II", B=99, nature_donnees="brutes")
cat("--- MN reserve2 + brutes (direct, app passe NULL) ok=", r$ok, "\n"); for (e in r$validation$erreurs) cat("  ERR:", e, "\n")
