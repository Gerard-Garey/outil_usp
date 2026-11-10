###############################################################################
#  tests/unitaires/test_registre_add.R  --  CONTROLES D'ENTREE D'ADD()
#                                           (ISSUE #484)
#
#  Regles de l'avis amont d'actuary (docs/revues/20261110-avis-amont-k3/
#  actuary-avis-amont.md, section 1) :
#    - sens valide a l'entree ("rejeter" / "ne pas rejeter"), scenario C1 ;
#    - p-values finies hors de [0, 1] refusees (p_ex, p_as, p_mc_ext, p_min,
#      p_mc et p_min_mc lues par mc_nom) ; non finie admise comme absente ;
#      0 et 1 admis ; err_mc_ext non controlee ; scenario C2 ;
#    - argument verdict retire, scenario C3 ;
#    - nature_forcee : forme controlee a l'entree ; rang controle sur une
#      ligne qui porte un verdict et dont la p retenue est finie (remarque R1).
#  Les deux appels reels de nature_forcee (TOST, Pitman) passent : par appel
#  direct reproduisant leurs arguments, et par run_engine().
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_registre_add.R")

# Registre fictif (aucune simulation) : une statistique Monte-Carlo "A".
reg484 <- function(p_mc = 0.5, p_min_mc = NULL) {
  boot <- list(p_mc = c(A = p_mc), err_mc = c(A = 0.01))
  if (!is.null(p_min_mc)) boot$p_min_mc <- c(A = p_min_mc)
  engine_registre_tests(boot, list(A = .mc_entree(function(e) 1, "haut")), 0.10, "Monte-Carlo")
}
ligne484 <- function(..., p_mc = 0.5, p_min_mc = NULL) {
  r <- reg484(p_mc, p_min_mc); r$add("F", "t", "ref", fonction = "usp_tests", ...)
  r$lignes()[[1]]
}
msg484 <- function(expr) tryCatch({ expr; "" }, error = function(e) conditionMessage(e))

## --- C1 : sens ------------------------------------------------------------------
verifier("C1 add() : sens = 'rejecter' -> erreur 'sens inconnu' (plus de regle 'ne pas rejeter' en silence)",
         identical(msg484(ligne484(mc_nom = "A", p_mc = 0.03, sens = "rejecter")),
                   "add() : sens inconnu : rejecter (t)"))
verifier("C1 add() : sens NA, vide, de longueur 2 ou non chaine -> erreur 'sens inconnu'",
         all(grepl("^add\\(\\) : sens inconnu : ",
                   c(msg484(ligne484(p_as = 0.3, sens = NA_character_)),
                     msg484(ligne484(p_as = 0.3, sens = NA)),
                     msg484(ligne484(p_as = 0.3, sens = "")),
                     msg484(ligne484(p_as = 0.3, sens = c("rejeter", "ne pas rejeter"))),
                     msg484(ligne484(p_as = 0.3, sens = 1))))))
verifier("C1 add() : sens 'rejeter' et 'ne pas rejeter' admis (p_mc = 0,03 : OK puis ECHEC)",
         identical(ligne484(mc_nom = "A", p_mc = 0.03, sens = "rejeter")$verdict, "OK") &&
           identical(ligne484(mc_nom = "A", p_mc = 0.03)$verdict, "ECHEC"))

## --- C2 : p-values hors de [0, 1] -------------------------------------------------
verifier("C2 add() : p_ex = 1,7 et p_ex = -0,2 -> erreur 'p-value hors de [0, 1]'",
         identical(msg484(ligne484(p_ex = 1.7)), "add() : p-value hors de [0, 1] : p_ex = 1.7 (t)") &&
           identical(msg484(ligne484(p_ex = -0.2)), "add() : p-value hors de [0, 1] : p_ex = -0.2 (t)"))
verifier("C2 add() : p_as, p_mc_ext, p_min finies hors de [0, 1] -> erreur nommant l'argument",
         grepl("p-value hors de [0, 1] : p_as = 1.2 (t)", msg484(ligne484(p_as = 1.2)), fixed = TRUE) &&
           grepl("p-value hors de [0, 1] : p_mc_ext = -0.01 (t)",
                 msg484(ligne484(p_mc_ext = -0.01, err_mc_ext = 0.01)), fixed = TRUE) &&
           grepl("p-value hors de [0, 1] : p_min = 2 (t)",
                 msg484(ligne484(p_ex = 0.5, p_min = 2)), fixed = TRUE))
verifier("C2 add() : p_mc et p_min_mc lues par mc_nom hors de [0, 1] -> erreur",
         grepl("p-value hors de [0, 1] : p_mc = 1.5 (t)",
               msg484(ligne484(mc_nom = "A", p_mc = 1.5)), fixed = TRUE) &&
           grepl("p-value hors de [0, 1] : p_min_mc = -0.5 (t)",
                 msg484(ligne484(mc_nom = "A", p_mc = 0.5, p_min_mc = -0.5)), fixed = TRUE))
verifier("C2 add() : p_min_mc hors de [0, 1] refusee meme hors de la branche Monte-Carlo de R1 (p exacte retenue)",
         leve_erreur(ligne484(mc_nom = "A", p_ex = 0.4, p_mc = 0.5, p_min_mc = 3)))
verifier("C2 add() : 0 et 1 admis pour chaque argument",
         {
           l0 <- ligne484(p_ex = 0); l1 <- ligne484(p_ex = 1)
           identical(l0$p_retenue, 0) && identical(l0$verdict, "ECHEC") &&
             identical(l1$p_retenue, 1) && identical(l1$verdict, "OK") &&
             identical(ligne484(p_as = 0)$p_retenue, 0) && identical(ligne484(p_as = 1)$p_retenue, 1) &&
             identical(ligne484(p_mc_ext = 0, err_mc_ext = 0)$p_retenue, 0) &&
             identical(ligne484(p_mc_ext = 1, err_mc_ext = 0)$p_retenue, 1) &&
             identical(ligne484(mc_nom = "A", p_mc = 0)$p_retenue, 0) &&
             identical(ligne484(mc_nom = "A", p_mc = 1)$p_retenue, 1) &&
             !leve_erreur(ligne484(p_ex = 0.5, p_min = 0)) && !leve_erreur(ligne484(p_ex = 0.5, p_min = 1)) &&
             !leve_erreur(ligne484(mc_nom = "A", p_mc = 0.5, p_min_mc = 0)) &&
             !leve_erreur(ligne484(mc_nom = "A", p_mc = 0.5, p_min_mc = 1))
         })
verifier("C2 add() : p non finies (NA, NaN, Inf, -Inf) lues comme absentes, sans erreur",
         {
           l <- ligne484(p_ex = NaN, p_as = Inf, p_min = -Inf)
           l2 <- ligne484(p_ex = NA_real_, p_as = 0.3)
           identical(l$verdict, "INFO") && identical(l$p_retenue, NA_real_) &&
             identical(l2$p_retenue, 0.3) &&
             !leve_erreur(ligne484(mc_nom = "A", p_mc = 0.5, p_min_mc = Inf))
         })
verifier("m1 add() : p-value de forme invalide (chaine, TRUE, longueur 2 ou 0, NULL, liste) -> erreur nommant l'argument",
         {
           m <- c(msg484(ligne484(p_ex = "0.01")), msg484(ligne484(p_ex = TRUE)),
                  msg484(ligne484(p_as = c(0.1, 0.2))), msg484(ligne484(p_min = numeric(0))),
                  msg484(ligne484(p_mc_ext = NULL)), msg484(ligne484(p_ex = list(0.1))))
           arg <- c("p_ex", "p_ex", "p_as", "p_min", "p_mc_ext", "p_ex")
           all(startsWith(m, paste0("add() : p-value de forme invalide : ", arg, " (classe "))) &&
             identical(m[1], "add() : p-value de forme invalide : p_ex (classe character, longueur 1) (t)")
         })
verifier("m1 add() : p_mc lue par mc_nom de forme invalide (chaine dans boot$p_mc) -> erreur",
         {
           r <- engine_registre_tests(list(p_mc = list(A = "0.5"), err_mc = c(A = 0.01)),
                                      list(A = .mc_entree(function(e) 1, "haut")), 0.10, "Monte-Carlo")
           grepl("p-value de forme invalide : p_mc", msg484(r$add("F", "t", "ref", fonction = "usp_tests",
                                                                  mc_nom = "A")), fixed = TRUE)
         })
verifier("m1 add() : NA logique, NA_real_, entier admis ; p_min_mc absente du bootstrap lue NA",
         identical(ligne484(p_ex = NA, p_as = 0.3)$p_retenue, 0.3) &&
           identical(ligne484(p_ex = NA_real_)$verdict, "INFO") &&
           identical(ligne484(p_ex = 1L)$verdict, "OK") &&
           identical(ligne484(mc_nom = "A", p_mc = 0.5)$p_min_mc, NA_real_))
verifier("C2 add() : err_mc_ext non controlee (err_mc_ext = 5 admis)",
         identical(ligne484(p_mc_ext = 0.4, err_mc_ext = 5)$err_mc, 5))

## --- C3 : argument verdict retire --------------------------------------------------
verifier("C3 add() : verdict n'est plus un argument (formals)",
         !"verdict" %in% names(formals(reg484()$add)))
verifier("C3 add() : verdict = 'OK' sans p -> erreur (argument inutilise), plus de OK sans p retenue",
         grepl('verdict = "OK"', msg484(ligne484(verdict = "OK")), fixed = TRUE))
verifier("C3 add() : sans p, verdict INFO ; p_ex = 0,001 en sens 'ne pas rejeter' -> ECHEC",
         identical(ligne484()$verdict, "INFO") && identical(ligne484(p_ex = 0.001)$verdict, "ECHEC"))

## --- R1 : nature_forcee -----------------------------------------------------------
verifier("R1 add() : forme de nature_forcee (vide, longueur 2, non chaine) -> erreur a l'entree, meme sans verdict",
         all(grepl("^add\\(\\) : nature_forcee doit etre NA ou une chaine non vide : ",
                   c(msg484(ligne484(p_ex = 0.3, nature_forcee = "")),
                     msg484(ligne484(p_ex = 0.3, nature_forcee = c("exacte", "exacte b")))  ,
                     msg484(ligne484(p_ex = 0.3, nature_forcee = 1)),
                     msg484(ligne484(type = "diagnostic", nature_forcee = ""))))) &&
           !leve_erreur(ligne484(p_ex = 0.3, nature_forcee = NA)))
verifier("R1 add() : 'Monte-Carlo bidon' sur une p exacte -> erreur (rang exacte)",
         identical(msg484(ligne484(p_ex = 0.3, nature_forcee = "Monte-Carlo bidon")),
                   "add() : nature_forcee incompatible avec le rang de la p retenue (exacte) : Monte-Carlo bidon (t)"))
verifier("R1 add() : 'exacte ...' sur une p Monte-Carlo (mc_nom ou p_mc_ext) -> erreur (rang Monte-Carlo)",
         grepl("(Monte-Carlo) : exacte x (t)", msg484(ligne484(mc_nom = "A", nature_forcee = "exacte x")),
               fixed = TRUE) &&
           grepl("(Monte-Carlo) : exacte x (t)",
                 msg484(ligne484(p_mc_ext = 0.4, err_mc_ext = 0.01, nature_forcee = "exacte x")), fixed = TRUE))
verifier("R1 add() : 'exacte ...' ou 'Monte-Carlo ...' sur une p non simulee -> erreur (rang p non simulee)",
         grepl("(p non simulee) : exacte x (t)", msg484(ligne484(p_as = 0.4, nature_forcee = "exacte x")),
               fixed = TRUE) &&
           grepl("(p non simulee) : Monte-Carlo x (t)",
                 msg484(ligne484(p_as = 0.4, nature_forcee = "Monte-Carlo x")), fixed = TRUE))
verifier("R1 add() : prefixe conforme au rang -> nature_p = nature_forcee",
         identical(ligne484(p_ex = 0.3, nature_forcee = "exacte y")$nature_p, "exacte y") &&
           identical(ligne484(mc_nom = "A", nature_forcee = "Monte-Carlo y")$nature_p, "Monte-Carlo y") &&
           identical(ligne484(p_as = 0.3, nature_forcee = "sous y")$nature_p, "sous y"))
verifier("R1 add() : ligne sans verdict (diagnostic, non applicable, bascule R1) ou sans p -> ni controle ni application",
         {
           ld <- ligne484(type = "diagnostic", p_as = 0.3, nature_forcee = "exacte x")
           ln <- ligne484(type = "non applicable", p_as = 0.3, nature_forcee = "exacte x")
           lr <- ligne484(p_ex = 0.5, p_min = 0.2, nature_forcee = "Monte-Carlo x")
           l0 <- ligne484(nature_forcee = "exacte x")
           identical(ld$nature_p, NA_character_) && identical(ln$nature_p, NA_character_) &&
             identical(lr$type, "diagnostic") && isTRUE(lr$inoperant) &&
             identical(lr$nature_p, NA_character_) &&
             identical(l0$nature_p, NA_character_) && identical(l0$verdict, "INFO")
         })

## --- Appels reels : TOST et Pitman ------------------------------------------------
NF_TOST <- "sous le modele auxiliaire pondere : loi de Student (poids estimes), marge fixee a priori"
NF_ENUM <- "exacte par permutation (H0 : y independant de x, hors modele reglementaire)"
NF_ALEA <- "Monte-Carlo (permutations aleatoires ; H0 : y independant de x)"
verifier("TOST (arguments de l'appel reel) : test a p non simulee, diagnostic, non applicable -> sans erreur",
         {
           lt <- ligne484(p_as = 0.04, nature_forcee = NF_TOST, sens = "rejeter")
           ld <- ligne484(type = "diagnostic", p_as = 0.5, nature_forcee = NF_TOST, sens = "rejeter")
           ln <- ligne484(type = "non applicable", nature_forcee = NF_TOST, sens = "rejeter")
           identical(lt$nature_p, NF_TOST) && identical(lt$verdict, "OK") &&
             identical(ld$nature_p, NA_character_) && identical(ln$nature_p, NA_character_)
         })
verifier("Pitman (arguments de l'appel reel) : enumeration, permutations aleatoires, non applicable a p de Student finie -> sans erreur",
         {
           le <- ligne484(p_ex = 0.02, p_as = 0.03, p_min = 1 / 40320, nature_forcee = NF_ENUM, sens = "rejeter")
           la <- ligne484(p_mc_ext = 0.02, err_mc_ext = 0.004, p_as = 0.03, p_min = 1 / 40320,
                          nature_forcee = NF_ALEA, sens = "rejeter")
           ln <- ligne484(type = "non applicable", p_as = 0.03, nature_forcee = NF_ENUM, sens = "rejeter")
           identical(le$nature_p, NF_ENUM) && identical(la$nature_p, NF_ALEA) &&
             identical(ln$nature_p, NA_character_) && identical(ln$verdict, "INFO")
         })
x484 <- c(104.20, 102.25, 109.34, 114.64, 118.41, 121.28, 132.40, 131.22)
y484 <- c(68.97, 76.76, 83.49, 95.38, 88.96, 70.22, 78.89, 117.37)
lignes484 <- function(xx, yy) {
  res <- run_engine(xt = xx, yt = yy, methode = "premium", segment = 1, annexe = "II",
                    nature_donnees = "brutes", B = B_MIN_USAGE, seed = 20260831)
  t <- engine_table_tests(res)
  list(tost = t[t$test == "Equivalence de la constante a zero (TOST)", ],
       pitman = t[t$test == "Test de Pitman sur la pente (lien positif pertes / volume)", ])
}
# Trois jeux : tests/donnees/donnees_ln_interieur.csv (TOST test a p non simulee,
# Pitman par enumeration) ; T = 10 (Pitman par permutations aleatoires) ;
# volumes constants (Pitman et TOST non applicables ; test_lm_complet() y rend
# t_pente = NA, donc p de Student NA : le cas d'une p de Student finie sur une
# ligne Pitman non applicable n'est exerce que par l'appel direct ci-dessus).
verifier("run_engine() : TOST test, Pitman enumeration, aleatoire et non applicable -> sans erreur, natures attendues",
         {
           d <- utils::read.csv(file.path(RACINE, "tests", "donnees", "donnees_ln_interieur.csv"))
           a <- lignes484(d$xt, d$yt)
           b <- lignes484(c(x484, 135.10, 140.70), c(y484, 101.30, 96.40))
           k <- lignes484(rep(110, 8), y484)
           identical(a$tost$type, "test") && startsWith(a$tost$nature_p, "sous le modele auxiliaire pondere") &&
             identical(a$pitman$type, "test") && identical(a$pitman$nature_p, NF_ENUM) &&
             identical(b$pitman$type, "test") && identical(b$pitman$nature_p, NF_ALEA) &&
             identical(k$pitman$type, "non applicable") &&
             identical(k$pitman$nature_p, NA_character_) &&
             identical(k$tost$type, "non applicable") && identical(k$tost$nature_p, NA_character_)
         })

fin_fichier()
