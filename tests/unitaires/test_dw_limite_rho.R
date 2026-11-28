###############################################################################
#  tests/unitaires/test_dw_limite_rho.R  --  LIMITE DE LA PUISSANCE DU TEST DE
#                                            DURBIN-WATSON QUAND rho -> -1,
#                                            T = 4, 5 ET 8 (ISSUE #421)
#
#  Resultat exact (demonstration de l'avis d'actuary de l'etape 1 de S9,
#  docs/revues/20261127-s9-mesures/actuary-protocoles-etape-1.md, par. 1.2) :
#  sous l'AR(1) stationnaire de dw_puissance_ar1(), quand rho -> -1, la serie
#  centree tend, a un facteur aleatoire non nul pres, vers le vecteur alterne
#  centre ; DW, invariante d'echelle, tend presque surement vers
#  d* = DW(v_T), v_T = ((-1)^t), t = 1..T :
#    d* = 4 (T - 1) / T (T pair), 4 T / (T + 1) (T impair),
#  soit 3, 10/3 et 7/2 a T = 4, 5 et 8. Si dw_p_exacte(v_T) != alpha, la
#  puissance tend donc vers L- = 1{dw_p_exacte(v_T) < alpha} (convergence
#  dominee ; p < alpha si et seulement si d est hors de [d_bas, d_haut]).
#  La valeur de L- pour un T donne depend du signe de la marge
#  m = dw_p_exacte(v_T) - alpha, evaluee par quadrature (Imhof) : approximation
#  numerique d'une quantite exacte ; l'assertion |m| > 1e-4 garde ce test
#  d'un cas limite ou cette quadrature deciderait seule du signe.
#
#  Assertions (avis, par. 1.4, point 4), sans tirage :
#    - DW(v_T) egale a sa valeur rationnelle a 1e-12 (stat_dw()) ;
#    - dw_p_exacte(v_T) egale a 0,2200433, 0,0506042 et 0,0056935 a 1e-6 pres
#      (valeurs de l'avis, par. 1.2, arrondies a 7 decimales) ;
#    - les six limites L- (T = 4, 5, 8 ; alpha = 0,10 et 0,05) : 0, 0 ; 1, 0 ;
#      1, 1 ;
#    - |m| > 1e-4 dans les six cas (plus petite marge : T = 5, alpha = 0,05,
#      6,04e-4) ;
#    - en complement, a la garde rho = -1 + 1e-6 : dw_puissance_ar1(4, rho,
#      0,10) < 0,01 et dw_puissance_ar1(8, rho, 0,10) > 0,99. T = 5, alpha =
#      0,05 n'y figure pas : la marge y est faible et la puissance a la garde
#      reste loin de sa limite 0 (avis, par. 1.5, K421-3).
#  Mesure des T de l'index jusqu'a la garde, limites et recoupement :
#  tests/mesure_dw_rho_negatif_t8.R (hors CI).
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_dw_limite_rho.R")

.v_alt <- function(n) (-1)^seq_len(n)
.dw_rationnel <- c("4" = 12 / 4, "5" = 20 / 6, "8" = 28 / 8)
.p_attendue <- c("4" = 0.2200433, "5" = 0.0506042, "8" = 0.0056935)
.L_attendue <- list("4" = c("0.1" = 0, "0.05" = 0), "5" = c("0.1" = 1, "0.05" = 0), "8" = c("0.1" = 1, "0.05" = 1))

for (n in c(4L, 5L, 8L)) {
  k <- format(n)
  v <- .v_alt(n)
  verifier(sprintf("T = %d : DW(v_T) egale a sa valeur rationnelle (%s) a 1e-12", n,
                   if (n %% 2L == 0L) "4(T - 1)/T" else "4T/(T + 1)"),
           proche(stat_dw(v), .dw_rationnel[[k]], rel = 0, abs = 1e-12))
  p_v <- dw_p_exacte(v)
  verifier(sprintf("T = %d : dw_p_exacte(v_T) = %s a 1e-6", n, format(.p_attendue[[k]])),
           proche(p_v, .p_attendue[[k]], rel = 0, abs = 1e-6))
  for (a in c(0.10, 0.05)) {
    verifier(sprintf("T = %d, alpha = %s : limite L- = 1{dw_p_exacte(v_T) < alpha} = %d", n, format(a),
                     as.integer(.L_attendue[[k]][[format(a)]])),
             identical(as.numeric(p_v < a), .L_attendue[[k]][[format(a)]]))
    verifier(sprintf("T = %d, alpha = %s : marge |dw_p_exacte(v_T) - alpha| > 1e-4 (pas de cas limite)", n, format(a)),
             is.finite(p_v) && abs(p_v - a) > 1e-4)
  }
}

# Complement a la garde rho = -1 + 1e-6 (domaine de dw_puissance_ar1()).
verifier("dw_puissance_ar1(4, -1 + 1e-6, 0,10) < 0,01 (limite L- = 0)",
         dw_puissance_ar1(4L, -1 + 1e-6, 0.10) < 0.01)
verifier("dw_puissance_ar1(8, -1 + 1e-6, 0,10) > 0,99 (limite L- = 1)",
         dw_puissance_ar1(8L, -1 + 1e-6, 0.10) > 0.99)

fin_fichier()
