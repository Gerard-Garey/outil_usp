###############################################################################
#  tests/unitaires/test_textes_inconditionnels.R  --  TEXTES INCONDITIONNELS
#                                                     (ISSUE #182)
#
#  Specification commune d'E2b (docs/specifications/e2b-doctrine-p-monte-carlo.md,
#  section 4, tests U182-1 a U182-7 ; decision D1-4) : un texte ne nomme une p
#  que si elle existe, et ne qualifie une loi d'exacte que dans le regime ou
#  elle l'est (#128, point c). Deux branches par texte :
#    1. detail de Shapiro-Wilk a loi nulle simulee a pi_t variable ;
#    2. detail des deux lignes du rapport de vraisemblance sur delta ;
#    3. loi de Cox-Stuart (quatre regimes : pi_t constant ou variable, avec ou
#       sans ex aequo) ;
#    4. loi d'Anderson-Darling et de Cramer-von Mises (T < 8, p_mc absente) ;
#    5. loi des six autres lignes de la regle R7 (DW, suites sur z, MK,
#       Smirnov, SpearVol, SpearTps) ;
#    6. detail de Smirnov a pi_t variable.
#  U182-6 (premium_interieur patche sur les seuls champs listes, cinq autres
#  cas identiques) et U182-7 (aucune p ni aucun verdict modifie) sont portes
#  par tests/test_reproductibilite.R (references comparees par
#  comparer_objets()).
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_textes_inconditionnels.R")

# J1 : delta estime = 1 (pi_t constant) ; J2 : delta estime = 0,664 (pi_t
# variable) ; J2e : J2 avec r_6 = r_2 (difference nulle dans la deuxieme
# paire de Cox-Stuart), delta estime = 0,666 (pi_t variable) ; J1e : J1 avec
# r_5 = r_1, delta estime = 1.
x182 <- c(104.20, 102.25, 109.34, 114.64, 118.41, 121.28, 132.40, 131.22)
y182 <- c(68.97, 76.76, 83.49, 95.38, 88.96, 70.22, 78.89, 117.37)
xi182 <- c(50, 80, 120, 200, 300, 150, 90, 60)
yi182 <- c(29.92, 56.9, 101.25, 123.06, 207.23, 105.91, 68.59, 40.05)
y1e <- y182; y1e[5] <- y182[1] * x182[5] / x182[1]
y2e <- yi182; y2e[6] <- yi182[2] * xi182[6] / xi182[2]
B182 <- 199L
lig182 <- function(tt, n) Filter(function(l) identical(l$test, n), tt)[[1]]
jeu182 <- function(x, y, B = B182, lr = NULL) {
  f <- usp_ajuster(x, y); b <- usp_bootstrap(f, B = B)
  list(f = f, b = b, t = usp_tests(f, b, methode = "premium", lr_delta = lr))
}
J1 <- jeu182(x182, y182); J2 <- jeu182(xi182, yi182)
R7 <- " exacte a pi_t constant seulement (regle R7)"

verifier("U182 jeux : delta J1 = 1, J1e = 1 ; J2 et J2e interieurs",
         J1$f$delta == 1 && usp_ajuster(x182, y1e)$delta == 1 &&
           J2$f$delta < 1 - TOL_DELTA_BORD && usp_ajuster(xi182, y2e)$delta < 1 - TOL_DELTA_BORD)

## --- U182-1 : Shapiro-Wilk a loi nulle simulee ---------------------------------
N_SWN <- "Shapiro-Wilk (loi nulle simulee, sans normalisation de Royston)"
DEB_SWN <- paste("loi nulle i.i.d. sans objet a pi_t variable (W(P epsilon) n'a pas la loi",
                 "de W sous i.i.d. normal) ; voir la ligne Shapiro-Wilk sur residus standardises")
verifier("U182-1 J2, p_mc de SW presente : detail inchange (p Monte-Carlo)",
         is.finite(J2$b$p_mc[["SW"]]) &&
           identical(lig182(J2$t, N_SWN)$detail, paste(DEB_SWN, "(p Monte-Carlo)")))
verifier("U182-1 J2, p_mc de SW absente (motif pose) : renvoi sans p Monte-Carlo",
         {
           b <- J2$b; b$p_mc["SW"] <- NA_real_; b$err_mc["SW"] <- NA_real_
           b$motif_mc["SW"] <- MOTIF_MC_REPLIC_INSUFFISANTES
           t <- usp_tests(J2$f, b, methode = "premium")
           identical(lig182(t, N_SWN)$detail,
                     paste(DEB_SWN, "(p Monte-Carlo indisponible sur ces donnees)")) &&
             identical(lig182(t, "Shapiro-Wilk sur residus standardises")$type, "diagnostic")
         })

## --- U182-2 : rapport de vraisemblance sur delta ------------------------------
N_LR <- c("Rapport de vraisemblance : delta = 0 (variance lineaire en volume)",
          "Rapport de vraisemblance : delta = 1 (variance quadratique en volume)")
TXT_LR_DEBUT <- paste("Aucun verdict (ADR 0001) : le LR mesure si les donnees distinguent cette",
                      "borne de l'optimum, non l'adequation du modele. Lecture : LR = 0, borne",
                      "atteinte par l'estimation")
TXT_LR_FIN <- paste("La p asymptotique (melange de Chernoff) est rapportee pour memoire et non",
                    "retenue : ecart a la loi simulee mesure a T = 8 (fiche du .tex).")
TXT_LR_MC <- paste("; p_mc elevee, borne aussi defendable que delta estime ; p_mc faible,",
                   "borne moins compatible avec les donnees.")
verifier("U182-2 LR a p_mc finie (B = 199) : lecture de p_mc conservee",
         {
           lr <- usp_lr_delta(J1$f, B = B182)
           t <- usp_tests(J1$f, J1$b, methode = "premium", lr_delta = lr)
           all(c(is.finite(lr$borne0$p_mc), is.finite(lr$borne1$p_mc))) &&
             all(vapply(N_LR, function(n) endsWith(lig182(t, n)$detail,
                                                   paste(TXT_LR_DEBUT, TXT_LR_MC, TXT_LR_FIN)),
                        logical(1)))
         })
verifier("U182-2 LR a p_mc absente (B = 40, replications insuffisantes) : aucune lecture de p_mc",
         {
           lr <- usp_lr_delta(J1$f, B = 40)
           t <- usp_tests(J1$f, J1$b, methode = "premium", lr_delta = lr)
           all(c(is.na(lr$borne0$p_mc), is.na(lr$borne1$p_mc))) &&
             all(vapply(N_LR, function(n) {
               d <- lig182(t, n)$detail
               endsWith(d, paste0(TXT_LR_DEBUT, ". ", TXT_LR_FIN)) && !grepl("p_mc", d, fixed = TRUE)
             }, logical(1)))
         })

## --- U182-3 : loi de Cox-Stuart, quatre regimes ---------------------------------
N_CS <- "Tendance par signes du ratio S/P"
CS_MC <- "p_mc par |K - n_p/2|, n_p paires, queue haute"
CS_EA <- "p_mc non calculee (ex aequo)"
CS_CST <- "Binomiale(m, 1/2) EXACTE, m differences non nulles ;"
CS_VAR <- paste0("Binomiale(m, 1/2), m differences non nulles,", R7, " ;")
verifier("U182-3 pi_t constant sans ex aequo (J1) : loi inchangee, p exacte attribuee",
         {
           l <- lig182(J1$t, N_CS)
           identical(l$loi, paste(CS_CST, CS_MC)) && is.finite(l$p_exacte)
         })
verifier("U182-3 pi_t constant avec ex aequo (J1e) : EXACTE, p_mc non calculee",
         {
           l <- lig182(jeu182(x182, y1e)$t, N_CS)
           identical(l$loi, paste(CS_CST, CS_EA)) && is.finite(l$p_exacte) && is.na(l$p_mc)
         })
verifier("U182-3 pi_t variable sans ex aequo (J2) : exacte a pi_t constant seulement, p exacte NA",
         {
           l <- lig182(J2$t, N_CS)
           identical(l$loi, paste(CS_VAR, CS_MC)) && is.na(l$p_exacte) && !grepl("EXACTE", l$loi)
         })
verifier("U182-3 pi_t variable avec ex aequo (J2e) : exacte a pi_t constant seulement, p_mc non calculee",
         {
           l <- lig182(jeu182(xi182, y2e)$t, N_CS)
           identical(l$loi, paste(CS_VAR, CS_EA)) && is.na(l$p_exacte) && is.na(l$p_mc)
         })

## --- U182-4 : loi d'Anderson-Darling et de Cramer-von Mises ----------------------
ST_PL <- paste("p non simulee : ajustement de Stephens (cas 3) sur estim (statistique",
               "re-standardisee), non sur stat")
ST_HP <- "p non simulee non calculee (T < 8, hors de la plage de l'implementation de reference)"
ST_MC <- " ; p_mc sur stat (statistique du catalogue)"
loi_st <- function(st, corps, mc) paste0("loi ", st, ", cas parametres estimes ; ", corps, mc)
verifier("U182-4 T = 8 avec p_mc : chaine identique a celle d'avant #182",
         {
           # Chaine d'avant #182, ecrite en dur.
           avant <- function(st) sprintf(paste(
             "loi %s, cas parametres estimes ; p non simulee : ajustement de Stephens (cas 3)",
             "sur estim (statistique re-standardisee), non sur stat ; p_mc sur stat",
             "(statistique du catalogue)"), st)
           identical(lig182(J2$t, "Anderson-Darling")$loi, avant("AD")) &&
             identical(lig182(J2$t, "Cramer-von Mises")$loi, avant("CvM"))
         })
verifier("U182-4 T = 7 avec p_mc : p non simulee non calculee, p_mc decrite",
         {
           j <- jeu182(xi182[1:7], yi182[1:7])
           l <- lig182(j$t, "Anderson-Darling"); m <- lig182(j$t, "Cramer-von Mises")
           is.finite(l$p_mc) && is.na(l$p_asymptotique) && identical(l$loi, loi_st("AD", ST_HP, ST_MC)) &&
             is.finite(m$p_mc) && identical(m$loi, loi_st("CvM", ST_HP, ST_MC))
         })
verifier("U182-4 T = 8, p_mc absente (B = 40) : p_mc non decrite",
         {
           j <- jeu182(xi182, yi182, B = 40)
           l <- lig182(j$t, "Anderson-Darling"); m <- lig182(j$t, "Cramer-von Mises")
           is.na(l$p_mc) && identical(l$loi, loi_st("AD", ST_PL, "")) &&
             is.na(m$p_mc) && identical(m$loi, loi_st("CvM", ST_PL, ""))
         })
verifier("U182-4 T = 7, p_mc absente (B = 40) : ni p non simulee ni p_mc decrites",
         {
           j <- jeu182(xi182[1:7], yi182[1:7], B = 40)
           identical(lig182(j$t, "Anderson-Darling")$loi, loi_st("AD", ST_HP, "")) &&
             identical(lig182(j$t, "Cramer-von Mises")$loi, loi_st("CvM", ST_HP, ""))
         })

## --- U182-5 / U182-6 (textes 5 et 6) : six autres lignes de la regle R7 ----------
R7_LOI <- list(
  "Autocorrelation d'ordre 1 (Durbin-Watson)" =
    c("forme quadratique en normales ; loi EXACTE par la methode d'Imhof (1961)",
      "forme quadratique en normales ; loi par la methode d'Imhof (1961)"),
  "Test des suites (aleatoire des signes)" =
    c("loi combinatoire EXACTE de R", "loi combinatoire de R"),
  "Tendance monotone du ratio S/P" =
    c("loi exacte de S (distribution mahonienne)", "loi de S (distribution mahonienne)"),
  "Egalite des lois petits vs gros volumes (2 ech.)" =
    c("exacte combinatoire (ks.test, sans ex aequo)", "loi combinatoire (ks.test, sans ex aequo)"),
  "Independance ratio S/P vs volume" =
    c("permutation exacte (T <= 9, sans ex aequo)", "loi de permutation (T <= 9, sans ex aequo)"),
  "Correlation ratio S/P vs temps" =
    c("permutation exacte (T <= 9, sans ex aequo)", "loi de permutation (T <= 9, sans ex aequo)"))
verifier("U182-5 pi_t constant (J1) : loi des six lignes inchangee",
         all(vapply(names(R7_LOI), function(n) identical(lig182(J1$t, n)$loi, R7_LOI[[n]][1]),
                    logical(1))))
verifier("U182-5 pi_t variable (J2) : loi des six lignes 'exacte a pi_t constant seulement', p exacte NA",
         all(vapply(names(R7_LOI), function(n) {
           l <- lig182(J2$t, n)
           identical(l$loi, paste0(R7_LOI[[n]][2], ",", R7)) && is.na(l$p_exacte) &&
             !grepl("EXACTE", l$loi, fixed = TRUE)
         }, logical(1))))
N_SM <- "Egalite des lois petits vs gros volumes (2 ech.)"
verifier("U182-5 Smirnov, detail : inchange a pi_t constant, loi echangeable nommee a pi_t variable",
         {
           d1 <- lig182(J1$t, N_SM)$detail; d2 <- lig182(J2$t, N_SM)$detail
           grepl("p-value minimale atteignable = 0.0286, atteinte seulement pour D = 1", d1, fixed = TRUE) &&
             !grepl("echangeable", d1, fixed = TRUE) &&
             grepl(paste("p-value minimale atteignable sous la loi de reference echangeable = 0.0286,",
                         "atteinte seulement pour D = 1 (deux groupes totalement separes)"),
                   d2, fixed = TRUE)
         })

fin_fichier()
