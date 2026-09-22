###############################################################################
#  tests/unitaires/test_controles_entree.R  --  CONTROLES D'ENTREE
#
#  engine_valider_donnees(), mw_valider_triangle(), engine_lire_donnees_csv(),
#  usp_controle_donnees(), usp_lire_vecteur() / usp_charger().
#  Cas valides, valeurs negatives ou nulles, NA, valeurs infinies, longueurs
#  differentes, T < 5, triangle non carre.
#  Reference : exigences de l'annexe XVII (B(2)(b) et D(2)(b), (c), (e) :
#  au moins 5 annees ; strict positivite requise par la loi lognormale et par
#  les rapports C(i,j+1)/C(i,j)) et article 19 (donnees completes).
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_controles_entree.R")

x <- c(104.20, 102.25, 109.34, 114.64, 118.41, 121.28, 132.40, 131.22)
y <- c(68.97, 76.76, 83.49, 95.38, 88.96, 70.22, 78.89, 117.37)
contient <- function(txt, motif) any(grepl(motif, txt, fixed = TRUE))

## --- engine_valider_donnees ---------------------------------------------------
v <- engine_valider_donnees(x, y)
verifier("Validation : jeu de test valide (ok, aucune erreur, T = 8)",
         isTRUE(v$ok) && !length(v$erreurs) && v$T == 8)
verifier("Validation : T = 8 < 10 -> avertissement de credibilite partielle",
         contient(v$avertissements, "credibilite partielle"))
verifier("Validation : T = 5 accepte, T = 4 refuse (annexe XVII, B/C(2)(b))",
         isTRUE(engine_valider_donnees(x[1:5], y[1:5])$ok) &&
         !engine_valider_donnees(x[1:4], y[1:4])$ok &&
         contient(engine_valider_donnees(x[1:4], y[1:4])$erreurs, "au moins 5"))
verifier("Validation : x negatif ou nul refuse",
         !engine_valider_donnees(replace(x, 3, -1), y)$ok &&
         !engine_valider_donnees(replace(x, 3, 0), y)$ok)
verifier("Validation : y nul ou negatif refuse (lognormale)",
         !engine_valider_donnees(x, replace(y, 2, 0))$ok &&
         !engine_valider_donnees(x, replace(y, 2, -5))$ok)
verifier("Validation : NA dans x ou y refuse (art. 19), sans erreur R",
         {
           a <- engine_valider_donnees(replace(x, 1, NA), y)
           b <- engine_valider_donnees(x, replace(y, 8, NaN))
           !a$ok && !b$ok && contient(a$erreurs, "manquantes")
         })
verifier("Validation : longueurs differentes refusees",
         {
           a <- engine_valider_donnees(x, y[-1])
           !a$ok && contient(a$erreurs, "meme longueur")
         })
verifier("Validation : vecteurs non numeriques refuses",
         !engine_valider_donnees(as.character(x), y)$ok &&
         !engine_valider_donnees(x > 110, y)$ok)
verifier("Validation : vecteurs vides refuses", !engine_valider_donnees(numeric(0), numeric(0))$ok)
verifier("Validation : avertissements ratio >= 5, amplitude >= 10, doublons",
         contient(engine_valider_donnees(x, replace(y, 1, 600))$avertissements, "Ratio") &&
         contient(engine_valider_donnees(replace(x, 1, 10), y)$avertissements, "Amplitude") &&
         contient(engine_valider_donnees(c(x, x[1]), c(y, y[1]))$avertissements, "dupliques"))
verifier("Validation : T_min parametrable",
         !engine_valider_donnees(x, y, T_min = 9)$ok &&
         isTRUE(engine_valider_donnees(x[1:3], y[1:3], T_min = 3)$ok))
# Constat d'audit : Inf passe les controles (anyNA(Inf) est FALSE, Inf > 0) ;
# run_engine() s'arrete ensuite sur une erreur de lm.fit au lieu de renvoyer
# ok = FALSE, et usp_ajuster() renvoie sigma = Inf avec l'objectif de penalite
# 1e12 comme optimum.
# Issue #33 (defaut releve par audit, repris de l'issue #7)
echec_attendu("Validation : valeur infinie dans y ou x refusee",
              "constat audit : ok = TRUE pour yt[3] = Inf ou xt[2] = Inf",
              !engine_valider_donnees(x, replace(y, 3, Inf))$ok &&
              !engine_valider_donnees(replace(x, 2, Inf), y)$ok)

## --- mw_valider_triangle -----------------------------------------------------
triangle <- function(n, f = 1.3, base = 100) {
  m <- matrix(NA_real_, n, n)
  for (i in 1:n) for (j in 1:(n - i + 1)) m[i, j] <- (base + 10 * i + j) * f^(j - 1)
  m
}
t5 <- triangle(5)
verifier("Triangle 5 x 5 valide : ok, I = J = 4",
         {
           r <- mw_valider_triangle(t5)
           isTRUE(r$ok) && r$I == 4 && r$J == 4 && !length(r$erreurs)
         })
verifier("Triangle : moins de 10 annees -> avertissement",
         contient(mw_valider_triangle(t5)$avertissements, "credibilite partielle"))
verifier("Triangle 4 x 4 refuse (D(2)(b) et (c))",
         {
           r <- mw_valider_triangle(triangle(4))
           !r$ok && contient(r$erreurs, "D(2)(b)") && contient(r$erreurs, "D(2)(c)")
         })
verifier("Triangle 6 x 5 (I > J) refuse : non carre",
         {
           r <- mw_valider_triangle(triangle(6)[, 1:5])
           !r$ok && contient(r$erreurs, "non carre")
         })
verifier("Triangle 5 x 6 (moins d'annees d'accident que de developpement) refuse (D(2)(e))",
         {
           r <- mw_valider_triangle(cbind(triangle(5), NA))
           !r$ok && contient(r$erreurs, "D(2)(e)")
         })
verifier("Triangle : cellule observee manquante refusee",
         {
           m <- t5; m[2, 3] <- NA
           r <- mw_valider_triangle(m)
           !r$ok && contient(r$erreurs, "(i=1, j=2)")
         })
verifier("Triangle : cumul nul ou negatif refuse",
         {
           m0 <- t5; m0[3, 1] <- 0; mn <- t5; mn[1, 5] <- -4
           !mw_valider_triangle(m0)$ok && !mw_valider_triangle(mn)$ok
         })
verifier("Triangle : cellule observee infinie refusee",
         {
           m <- t5; m[1, 2] <- Inf
           !mw_valider_triangle(m)$ok
         })
verifier("Triangle : data.frame ou matrice de caracteres refuses",
         !mw_valider_triangle(as.data.frame(t5))$ok &&
         !mw_valider_triangle(matrix(as.character(t5), 5))$ok)
verifier("Triangle : cumul decroissant accepte avec avertissement",
         {
           m <- t5; m[1, 3] <- m[1, 2] - 1
           r <- mw_valider_triangle(m)
           isTRUE(r$ok) && contient(r$avertissements, "cumul decroissant")
         })

## --- engine_lire_donnees_csv --------------------------------------------------
df <- data.frame(t = c(2003, 2001, 2002, 2004, 2005), xt = c(3, 1, 2, 4, 5) * 100,
                 yt = c(3, 1, 2, 4, 5) * 70)
verifier("Lecture : colonnes t, xt, yt ; tri par t",
         {
           r <- engine_lire_donnees_csv(df)
           isTRUE(r$ok) && identical(r$xt, c(1, 2, 3, 4, 5) * 100) &&
             identical(r$yt, c(1, 2, 3, 4, 5) * 70) && r$n == 5
         })
verifier("Lecture : sans colonne t, ordre du fichier conserve",
         identical(engine_lire_donnees_csv(df[, c("xt", "yt")])$xt, df$xt))
verifier("Lecture : colonne manquante refusee avec message explicite",
         {
           r <- engine_lire_donnees_csv(df[, c("t", "xt")])
           !r$ok && contient(r$erreurs, "yt")
         })
verifier("Lecture : valeur non numerique refusee",
         !engine_lire_donnees_csv(data.frame(t = 1:5, xt = c("1", "2", "a", "4", "5"),
                                             yt = 1:5, stringsAsFactors = FALSE))$ok)
verifier("Lecture : tableau vide ou objet non tabulaire refuse",
         !engine_lire_donnees_csv(df[0, ])$ok && !engine_lire_donnees_csv(list(xt = 1))$ok)
# Constats d'audit (lecture d'un fichier d'echange) :
# Issue #33 (defaut releve par audit, repris de l'issue #7)
echec_attendu("Lecture : colonne facteur convertie par ses valeurs, non par ses codes",
              "constat audit : as.numeric(facteur) renvoie les codes 2 1 3 4 5",
              {
                f <- factor(c("104.2", "102.25", "109.34", "114.64", "118.41"))
                r <- engine_lire_donnees_csv(data.frame(t = 1:5, xt = f, yt = 1:5))
                !r$ok || isTRUE(all.equal(r$xt, c(104.2, 102.25, 109.34, 114.64, 118.41)))
              })
# Issue #33 (defaut releve par audit, repris de l'issue #7)
echec_attendu("Lecture : annees t dupliquees ou non consecutives refusees",
              "constat audit : t = 2001, 2001, 2002... et t = 2001, 2003, 2005... acceptes",
              !engine_lire_donnees_csv(data.frame(t = c(2001, 2001, 2002, 2003, 2004), xt = 1:5, yt = 1:5))$ok &&
              !engine_lire_donnees_csv(data.frame(t = c(2001, 2003, 2005, 2007, 2009), xt = 1:5, yt = 1:5))$ok)
# Issue #33 (defaut releve par audit, repris de l'issue #7)
echec_attendu("Lecture : colonne t incomplete signalee (tri non effectue en silence)",
              "constat audit : t avec un NA -> ok = TRUE, lignes laissees dans l'ordre du fichier",
              !engine_lire_donnees_csv(data.frame(t = c(3, 1, NA, 2, 5), xt = 1:5, yt = 1:5))$ok)

## --- usp_controle_donnees ----------------------------------------------------
verifier("Controles qualite : 8 lignes ; jeu de test OK sauf credibilite pleine (T < 10)",
         {
           r <- usp_controle_donnees(x, y)
           verd <- vapply(r, function(l) l$verdict, "")
           length(r) == 8 && all(verd %in% c("OK", "ECHEC")) &&
             identical(unname(verd[8]), "ECHEC") && all(verd[1:7] == "OK")
         })
# Issue #33 (defaut releve par audit, repris de l'issue #7)
echec_attendu("Controles qualite : T = 4 donne une ligne ECHEC (et non une erreur R)",
              "constat audit : erreur levee par usp_credibilite() dans le libelle de la derniere ligne",
              !leve_erreur(usp_controle_donnees(x[1:4], y[1:4])))
# Issue #33 (defaut releve par audit, repris de l'issue #7)
echec_attendu("Controles qualite : un NA donne une ligne ECHEC (et non une erreur R)",
              "constat audit : if (NA) dans add() -> erreur",
              !leve_erreur(usp_controle_donnees(replace(x, 2, NA), y)))

## --- usp_lire_vecteur / usp_charger ------------------------------------------
fx <- tempfile(fileext = ".csv"); fy <- tempfile(fileext = ".csv")
writeLines(c("x", "100", "110", "120", "130", "140"), fx)
writeLines(c("70", "80", "85", "90", "99"), fy)
verifier("Lecture vecteur : avec ou sans en-tete ; T = n dernieres annees",
         {
           r <- usp_charger(fx, fy)
           r2 <- usp_charger(fx, fy, T = 3)
           identical(r$x, c(100, 110, 120, 130, 140)) && identical(r$y, c(70, 80, 85, 90, 99)) &&
             identical(r2$x, c(120, 130, 140)) && r2$T == 3
         })
verifier("Lecture vecteur : longueurs differentes et T trop grand refuses",
         {
           fz <- tempfile(fileext = ".csv"); writeLines(c("1", "2", "3"), fz)
           leve_erreur(usp_charger(fx, fz)) && leve_erreur(usp_charger(fx, fy, T = 6))
         })
# Constat d'audit : une cellule vide est retiree en silence ; deux vides a des
# annees differentes donnent deux series de meme longueur mais DECALEES.
# Issue #33 (defaut releve par audit, repris de l'issue #7)
echec_attendu("Lecture vecteur : cellule vide refusee (pas de decalage silencieux des annees)",
              "constat audit : x sans annee 2 et y sans annee 3 -> 5 couples desalignes, sans erreur",
              {
                fx2 <- tempfile(fileext = ".csv"); fy2 <- tempfile(fileext = ".csv")
                writeLines(c("x", "100", "", "120", "130", "140", "150"), fx2)
                writeLines(c("y", "70", "80", "", "90", "95", "99"), fy2)
                leve_erreur(usp_charger(fx2, fy2))
              })

fin_fichier()
