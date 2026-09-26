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
# Issue #33 (defaut releve par audit, repris de l'issue #7), corrige : Inf
# passait les controles (anyNA(Inf) est FALSE, Inf > 0) et run_engine()
# s'arretait sur une erreur R au lieu de renvoyer ok = FALSE.
verifier("Validation : valeur infinie dans y ou x refusee (#33)",
         !engine_valider_donnees(x, replace(y, 3, Inf))$ok &&
         !engine_valider_donnees(replace(x, 2, Inf), y)$ok &&
         !engine_valider_donnees(x, replace(y, 3, -Inf))$ok &&
         contient(engine_valider_donnees(x, replace(y, 3, Inf))$erreurs, "infinies"))
verifier("run_engine : valeur infinie -> ok = FALSE avec motif, sans erreur R (#33)",
         {
           r <- run_engine(xt = x, yt = replace(y, 3, Inf), methode = "premium",
                           segment = 1, annexe = "II", B = 19, nature_donnees = "brutes")
           identical(r$ok, FALSE) && contient(r$validation$erreurs, "infinies")
         })
## --- Marge du test d'equivalence (#33, complement d'audit de #58) ------------
# Avis d'actuary du 24/09/2026 : theta reel fini, 0 < theta < 1 ; delta_equiv
# (s'il est fourni) reel fini, 0 < Delta < moyenne(yt), theta alors ignore.
# Hors domaine : ok = FALSE avec un motif nommant le parametre.
marge_refusee <- function(th = 0.10, de = NULL, motif) {
  v <- engine_valider_donnees(x, y, theta_equiv = th, delta_equiv = de)
  !v$ok && contient(v$erreurs, motif)
}
verifier("Marge theta : NA, vide, multiple, texte, Inf, 0, negative, 1 et plus refuses",
         all(vapply(list(NA, NA_real_, numeric(0), NULL, c(0.1, 0.2), "0.1", Inf, -Inf, 0, -0.1, 1, 1.5),
                    function(th) marge_refusee(th = th, motif = "theta_equiv"), logical(1))))
verifier("Marge theta : 0 < theta < 1 accepte (0,10 ; 0,999 ; 1e-6), jeu valide inchange",
         all(vapply(c(0.10, 0.999, 1e-6), function(th)
           isTRUE(engine_valider_donnees(x, y, theta_equiv = th)$ok), logical(1))) &&
         identical(engine_valider_donnees(x, y), engine_valider_donnees(x, y, theta_equiv = 0.10)))
# Audit de #33 (C2) : la valeur refusee est restituee telle qu'elle a ete
# fournie (deparse), guillemets d'un texte compris.
verifier("Marge : valeur refusee restituee par deparse() (texte entre guillemets, vecteur en c(...)) (#33)",
         {
           e1 <- engine_valider_donnees(x, y, theta_equiv = "0.1")$erreurs
           e2 <- engine_valider_donnees(x, y, theta_equiv = c(0.1, 0.2))$erreurs
           e3 <- engine_valider_donnees(x, y, delta_equiv = "8")$erreurs
           e4 <- engine_valider_donnees(x, y, theta_equiv = NULL)$erreurs
           contient(e1, "theta_equiv = \"0.1\"") && contient(e2, "theta_equiv = c(0.1, 0.2)") &&
             contient(e3, "delta_equiv = \"8\"") && contient(e4, "theta_equiv = vide")
         })
verifier("Marge Delta : NA, vide, multiple, Inf, 0, negative, >= moyenne(y) refuses",
         all(vapply(list(NA, numeric(0), c(1, 2), Inf, 0, -1, mean(y), 2 * mean(y)),
                    function(de) marge_refusee(de = de, motif = "delta_equiv"), logical(1))))
verifier("Marge Delta fournie : theta ignore (theta = 5 ou NA accepte avec Delta = 8)",
         isTRUE(engine_valider_donnees(x, y, theta_equiv = 5, delta_equiv = 8)$ok) &&
         isTRUE(engine_valider_donnees(x, y, theta_equiv = NA, delta_equiv = 8)$ok))
verifier("run_engine : theta_equiv NA ou 1, delta_equiv vide -> ok = FALSE, sans erreur R",
         {
           r1 <- run_engine(xt = x, yt = y, methode = "premium", segment = 1, B = 19,
                            theta_equiv = NA, nature_donnees = "brutes")
           r2 <- run_engine(xt = x, yt = y, methode = "reserve1", segment = 1, B = 19,
                            theta_equiv = 1)
           r3 <- run_engine(xt = x, yt = y, methode = "premium", segment = 1, B = 19,
                            delta_equiv = numeric(0), nature_donnees = "brutes")
           identical(r1$ok, FALSE) && identical(r2$ok, FALSE) && identical(r3$ok, FALSE) &&
             contient(r1$validation$erreurs, "theta_equiv") &&
             contient(r3$validation$erreurs, "delta_equiv")
         })

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
# Audit de #33 (C3) : une valeur non finie n'est pas une cellule manquante ;
# motif distinct, avec la position et la valeur.
verifier("Triangle : Inf, -Inf, NaN signales 'valeur non finie' (pas 'manquante'), NA reste 'manquante' (#33)",
         {
           m <- t5; m[1, 2] <- Inf; m[2, 1] <- -Inf; m[3, 2] <- NaN; m[1, 4] <- NA
           e <- mw_valider_triangle(m)$erreurs
           contient(e, "Valeur non finie en (i=0, j=1) : Inf") &&
             contient(e, "Valeur non finie en (i=1, j=0) : -Inf") &&
             contient(e, "Valeur non finie en (i=2, j=1) : NaN") &&
             contient(e, "Cellule observee manquante en (i=0, j=3)") &&
             !contient(e, "manquante en (i=0, j=1)") && length(e) == 4L
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
# Issue #33 (defaut releve par audit, repris de l'issue #7), corrige :
# lecture d'un fichier d'echange.
verifier("Lecture : colonne facteur convertie par ses valeurs, non par ses codes (#33)",
         {
           f <- factor(c("104.2", "102.25", "109.34", "114.64", "118.41"))
           r <- engine_lire_donnees_csv(data.frame(t = factor(2001:2005), xt = f,
                                                   yt = factor(c("70", "80", "85", "90", "99"))))
           isTRUE(r$ok) && identical(r$xt, c(104.2, 102.25, 109.34, 114.64, 118.41)) &&
             identical(r$yt, c(70, 80, 85, 90, 99))
         })
# Avis d'actuary du 24/09/2026 : annexe XVII, B(2)(b) et C(2)(b), annees
# consecutives ; doublon, trou, annee non entiere ou manquante : refus.
verifier("Lecture : annees t dupliquees ou non consecutives refusees (#33)",
         {
           a <- engine_lire_donnees_csv(data.frame(t = c(2001, 2001, 2002, 2003, 2004), xt = 1:5, yt = 1:5))
           b <- engine_lire_donnees_csv(data.frame(t = c(2001, 2003, 2005, 2007, 2009), xt = 1:5, yt = 1:5))
           c <- engine_lire_donnees_csv(data.frame(t = c(2001.5, 2002.5, 2003.5, 2004.5, 2005.5),
                                                   xt = 1:5, yt = 1:5))
           !a$ok && contient(a$erreurs, "dupliquee") && !b$ok &&
             contient(b$erreurs, "non consecutives") && !c$ok && contient(c$erreurs, "entiers")
         })
verifier("Lecture : colonne t incomplete ou non numerique refusee (tri non effectue en silence) (#33)",
         {
           a <- engine_lire_donnees_csv(data.frame(t = c(3, 1, NA, 2, 5), xt = 1:5, yt = 1:5))
           b <- engine_lire_donnees_csv(data.frame(t = c("2001", "2002", "x", "2004", "2005"),
                                                   xt = 1:5, yt = 1:5, stringsAsFactors = FALSE))
           !a$ok && contient(a$erreurs, "ligne(s) 3") && !b$ok
         })
verifier("Lecture : t consecutive dans le desordre -> triee en croissant",
         {
           r <- engine_lire_donnees_csv(data.frame(t = c(2005, 2003, 2004, 2001, 2002),
                                                   xt = c(5, 3, 4, 1, 2), yt = c(50, 30, 40, 10, 20)))
           isTRUE(r$ok) && identical(r$xt, c(1, 2, 3, 4, 5)) && identical(r$yt, c(10, 20, 30, 40, 50))
         })

## --- engine_lire_triangle (#33, #4 piste 3) -----------------------------------
# Conversion fichier -> triangle en une fonction du moteur, puis
# mw_valider_triangle().
fichier_tri <- function(m) {
  d <- as.data.frame(m); names(d) <- paste0("j", seq_len(ncol(m)) - 1L)
  cbind(i = seq_len(nrow(m)), d)
}
verifier("engine_lire_triangle : colonne i ignoree, triangle 5 x 5 rendu tel quel",
         {
           r <- engine_lire_triangle(fichier_tri(t5))
           isTRUE(r$ok) && identical(r$triangle, t5) && r$I == 4 && r$J == 4
         })
verifier("engine_lire_triangle : colonnes facteur ou texte converties par leurs valeurs",
         {
           d <- fichier_tri(t5)
           d[] <- lapply(d, function(v) factor(ifelse(is.na(v), "", format(v, digits = 17))))
           r <- engine_lire_triangle(d)
           isTRUE(r$ok) && isTRUE(all.equal(r$triangle, t5, tolerance = 1e-15))
         })
verifier("engine_lire_triangle : cellule non numerique refusee (pas lue comme NA), avec sa position",
         {
           d <- fichier_tri(t5); d$j1 <- as.character(d$j1); d$j1[3] <- "abc"
           r <- engine_lire_triangle(d)
           !r$ok && contient(r$erreurs, "(i=2, j=1)") && is.null(r$triangle)
         })
verifier("engine_lire_triangle : cellule texte \"Inf\" signalee 'valeur non finie', non 'manquante' (#33)",
         {
           d <- fichier_tri(t5); d$j1 <- as.character(d$j1); d$j1[1] <- "Inf"
           r <- engine_lire_triangle(d)
           !r$ok && contient(r$erreurs, "Valeur non finie en (i=0, j=1)") &&
             !contient(r$erreurs, "manquante") && is.null(r$triangle)
         })
verifier("engine_lire_triangle : erreurs de recevabilite de mw_valider_triangle() restituees",
         {
           d <- fichier_tri(t5); d$j2[2] <- NA
           r1 <- engine_lire_triangle(d)
           r2 <- engine_lire_triangle(fichier_tri(triangle(4)))
           !r1$ok && contient(r1$erreurs, "(i=1, j=2)") && !r2$ok && contient(r2$erreurs, "D(2)(b)") &&
             !engine_lire_triangle(data.frame())$ok && !engine_lire_triangle(list(a = 1))$ok
         })

## --- usp_controle_donnees ----------------------------------------------------
verifier("Controles qualite : 8 lignes ; jeu de test OK sauf credibilite pleine (T < 10)",
         {
           r <- usp_controle_donnees(x, y)
           verd <- vapply(r, function(l) l$verdict, "")
           length(r) == 8 && all(verd %in% c("OK", "ECHEC")) &&
             identical(unname(verd[8]), "ECHEC") && all(verd[1:7] == "OK")
         })
# Issue #33 (defaut releve par audit, repris de l'issue #7), corrige. Avis
# d'actuary du 24/09/2026 : un controle non etabli vaut ECHEC et le dit ;
# sous T = 5, la ligne de credibilite sort ECHEC, bareme non defini.
verifier("Controles qualite : T = 4 donne une ligne ECHEC (et non une erreur R) (#33)",
         {
           r <- usp_controle_donnees(x[1:4], y[1:4])
           l <- r[[8]]
           length(r) == 8 && identical(l$verdict, "ECHEC") &&
             grepl("bareme non defini sous T = 5", l$detail, fixed = TRUE) &&
             identical(r[[1]]$verdict, "ECHEC")
         })
verifier("Controles qualite : un NA donne une ligne ECHEC (et non une erreur R) (#33)",
         {
           r <- usp_controle_donnees(replace(x, 2, NA), y)
           verd <- vapply(r, function(l) l$verdict, "")
           det <- vapply(r, function(l) l$detail, "")
           nx <- c("Strict positivite de x_t", "Absence de doublons parfaits",
                   "Plausibilite du ratio y/x", "Amplitude du volume (stabilite du perimetre)")
           tests <- vapply(r, function(l) l$test, "")
           length(r) == 8 && all(verd[tests %in% nx] == "ECHEC") &&
             all(grepl("controle non etabli : valeur(s) manquante(s)", det[tests %in% nx], fixed = TRUE)) &&
             identical(unname(verd[tests == "Absence de valeurs manquantes"]), "ECHEC") &&
             identical(unname(verd[tests == "Strict positivite de y_t (requise par la lognormale)"]), "OK") &&
             !any(grepl("NA", det[tests %in% nx], fixed = TRUE))
         })
verifier("Controles qualite : jeu de test inchange (details identiques, sans mention 'non etabli')",
         !any(grepl("non etabli", vapply(usp_controle_donnees(x, y), function(l) l$detail, ""),
                    fixed = TRUE)))

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
# Issue #33 (defaut releve par audit, repris de l'issue #7), corrige : une
# cellule vide etait retiree en silence ; deux vides a des annees differentes
# donnaient deux series de meme longueur mais DECALEES.
verifier("Lecture vecteur : cellule vide refusee (pas de decalage silencieux des annees) (#33)",
         {
           fx2 <- tempfile(fileext = ".csv"); fy2 <- tempfile(fileext = ".csv")
           writeLines(c("x", "100", "", "120", "130", "140", "150"), fx2)
           writeLines(c("y", "70", "80", "", "90", "95", "99"), fy2)
           e <- tryCatch(usp_charger(fx2, fy2), error = function(e) conditionMessage(e))
           is.character(e) && grepl("Cellule(s) vide(s) en position 2", e, fixed = TRUE)
         })
verifier("Lecture vecteur : valeur non numerique au milieu refusee ; separateur final et lignes vides finales toleres",
         {
           f1 <- tempfile(); writeLines(c("100", "110", "abc", "130"), f1)
           f2 <- tempfile(); writeLines(c("100,110,120,130,140,", "", ""), f2)
           f3 <- tempfile(); writeLines(c("x,100,110,,130,140"), f3)
           leve_erreur(usp_lire_vecteur(f1)) && leve_erreur(usp_lire_vecteur(f3)) &&
             identical(usp_lire_vecteur(f2), c(100, 110, 120, 130, 140))
         })
# Audit de #33 (C1) : l'ancien lecteur sautait les lignes vides ; celles de
# tete (avant l'en-tete ou entre l'en-tete et la premiere valeur) restent
# sans effet. Seule une cellule vide au milieu de la serie est refusee.
verifier("Lecture vecteur : lignes vides de tete ou apres l'en-tete ignorees, vide au milieu refuse avec sa position (#33)",
         {
           lit <- function(l) { f <- tempfile(); writeLines(l, f); usp_lire_vecteur(f) }
           msg <- function(l) tryCatch(lit(l), error = function(e) conditionMessage(e))
           identical(lit(c("", "100", "110")), c(100, 110)) &&
             identical(lit(c("x", "", "100", "110")), c(100, 110)) &&
             identical(lit(c("", "", "x", "", "100", "110", "")), c(100, 110)) &&
             identical(lit(c("", "100,110,120")), c(100, 110, 120)) &&
             identical(lit(c(",100,110")), c(100, 110)) &&
             grepl("Cellule(s) vide(s) en position 2", msg(c("", "x", "100", "", "110")), fixed = TRUE)
         })
verifier("Lecture vecteur : tableau a plusieurs lignes et colonnes refuse (format non reconnu)",
         {
           f <- tempfile(); writeLines(c("a,b", "1,2", "3,4"), f)
           leve_erreur(usp_lire_vecteur(f))
         })
# Revue finale de la branche (#33) : le format en ligne avec en-tete (ligne 1
# = en-tetes non numeriques, ligne 2 = la serie), lu par l'ancien lecteur,
# etait refuse comme tableau. Retabli par decision du mainteneur du
# 25/09/2026 ; tout autre tableau reste refuse, sans aplatissement.
verifier("Lecture vecteur : serie en ligne avec ligne d'en-tetes acceptee (sep ',' et ';', dec ',') (#33)",
         {
           lit <- function(l, sep = ",", dec = ".") {
             f <- tempfile(); writeLines(l, f); usp_lire_vecteur(f, sep, dec)
           }
           identical(lit(c("a2017,a2018,a2019,a2020", "104.2,102.25,109.34,114.64")),
                     c(104.2, 102.25, 109.34, 114.64)) &&
             identical(lit(c("a2017;a2018;a2019;a2020", "104,2;102,25;109,34;114,64"), ";", ","),
                       c(104.2, 102.25, 109.34, 114.64)) &&
             identical(lit("104.2,102.25,109.34,114.64"), c(104.2, 102.25, 109.34, 114.64))
         })
verifier("Lecture vecteur : 2 lignes numeriques ou 3 lignes x n refusees (tableau, pas d'aplatissement) (#33)",
         {
           msg <- function(l) {
             f <- tempfile(); writeLines(l, f)
             tryCatch(usp_lire_vecteur(f), error = function(e) conditionMessage(e))
           }
           grepl("Format non reconnu", msg(c("1,2,3", "4,5,6")), fixed = TRUE) &&
             grepl("Format non reconnu", msg(c("a,b,c", "1,2,3", "4,5,6")), fixed = TRUE) &&
             grepl("Format non reconnu", msg(c("a,2018,c", "1,2,3")), fixed = TRUE)
         })
verifier("Lecture vecteur : cellule vide au milieu d'une serie en ligne avec en-tetes refusee avec sa position (#33)",
         {
           f <- tempfile(); writeLines(c("a2017;a2018;a2019;a2020", "104,2;;109,34;114,64"), f)
           e <- tryCatch(usp_lire_vecteur(f, ";", ","), error = function(e) conditionMessage(e))
           is.character(e) && grepl("Cellule(s) vide(s) en position 2", e, fixed = TRUE)
         })
# Issue #95 : serie en ligne avec ligne d'en-tetes ; une valeur manquante de
# bord (cellule vide ecartee) ou en surnombre passait sans message. Decision
# du mainteneur : alignement colonne par colonne (en-tete non vide et valeur,
# ou rien) ; etiquette de ligne admise, sauf "NA", "-" ou nombre ecrit avec
# l'autre separateur decimal.
msg_ligne <- function(l, sep = ",", dec = ".") {
  f <- tempfile(); writeLines(l, f)
  tryCatch(usp_lire_vecteur(f, sep, dec), error = function(e) conditionMessage(e))
}
a_motif <- function(txt, ...) all(vapply(c(...), function(p) grepl(p, txt, fixed = TRUE), TRUE))
verifier("Lecture vecteur : serie en ligne, valeur manquante de bord ou en surnombre refusee, colonnes fautives et decomptes donnes (#95)",
         a_motif(msg_ligne(c("a,b,c,d", "1,2,3,")),
                 "colonne 4 : en-tete \"d\" sans valeur", "3 valeur(s) pour 4 en-tete(s) non vide(s)") &&
           a_motif(msg_ligne(c("a,b,c,d", ",2,3,4")),
                   "colonne 1 : en-tete \"a\" sans valeur", "3 valeur(s) pour 4 en-tete(s) non vide(s)") &&
           a_motif(msg_ligne(c("a,b", "1,2,3")),
                   "colonne 3 : valeur \"3\" sans en-tete", "3 valeur(s) pour 2 en-tete(s) non vide(s)"))
verifier("Lecture vecteur : serie en ligne, en-tetes et valeurs decales ou en-tete vide intercale refuses colonne par colonne (#95)",
         a_motif(msg_ligne(c("a,b,c,", ",2,3,4")),
                 "colonne 1 : en-tete \"a\" sans valeur ; colonne 4 : valeur \"4\" sans en-tete") &&
           a_motif(msg_ligne(c("a,b,,d", "1,2,3,4")), "colonne 3 : valeur \"3\" sans en-tete") &&
           a_motif(msg_ligne(c("a,,c", "1,2,3")), "colonne 2 : valeur \"2\" sans en-tete") &&
           a_motif(msg_ligne(c("serie,a2017,a2018", ",1,2")),
                   "colonne 1 : en-tete \"serie\" sans valeur", "retirer son en-tete"))
verifier("Lecture vecteur : serie en ligne, etiquette \"NA\", \"-\" ou nombre a l'autre separateur decimal refusee (#95)",
         a_motif(msg_ligne(c("a,b,c", "NA,2,3")), "cellule \"NA\" (colonne 1)", "etiquette") &&
           a_motif(msg_ligne(c("a,b,c", "-,2,3")), "cellule \"-\" (colonne 1)", "etiquette") &&
           a_motif(msg_ligne(c("a2017;a2018;a2019", "1,5;2;3"), ";", "."),
                   "cellule \"1,5\" (colonne 1)", "separateur decimal"))
# Avis d'actuary : predicat unique .allure_manquante_ou_nombre(), applique a
# l'etiquette du format avec en-tetes et a l'en-tete des autres formats.
verifier("Lecture vecteur : etiquette NaN, #N/A, N/A, n.d., 1 234, 1.234,5 (dec ',') ou 1,234.5 (dec '.') refusee (#95)",
         a_motif(msg_ligne(c("a,b,c", "NaN,2,3")), "cellule \"NaN\" (colonne 1), en position d'etiquette") &&
           a_motif(msg_ligne(c("a,b,c", "#N/A,2,3")), "cellule \"#N/A\"", "valeur manquante") &&
           a_motif(msg_ligne(c("a,b,c", "N/A,2,3")), "cellule \"N/A\"", "etiquette") &&
           a_motif(msg_ligne(c("a,b,c", "n.d.,2,3")), "cellule \"n.d.\"", "etiquette") &&
           a_motif(msg_ligne(c("a,b,c", "1 234,2,3")), "cellule \"1 234\"", "etiquette") &&
           a_motif(msg_ligne(c("a;b;c", "1.234,5;2;3"), ";", ","), "cellule \"1.234,5\"", "etiquette") &&
           a_motif(msg_ligne(c("a;b;c", "1,234.5;2;3"), ";", "."), "cellule \"1,234.5\"", "etiquette"))
verifier("Lecture vecteur : en-tete NA, - ou NaN refuse en format ligne sans en-tetes et en format colonne (#95)",
         {
           en_tete <- "en position d'en-tete (premiere cellule non vide)"
           all(vapply(c("NA", "-", "NaN"), function(z)
             a_motif(msg_ligne(paste0(z, ",2,3")), paste0("cellule \"", z, "\" ", en_tete)) &&
               a_motif(msg_ligne(c(z, "2", "3")), paste0("cellule \"", z, "\" ", en_tete)), TRUE))
         })
verifier("Predicat .allure_manquante_ou_nombre() : manquants et nombres refuses, 12a, TRUE et en-tetes ordinaires admis (#95)",
         {
           # Espace insecable en UTF-8 (C2 A0) et en Windows-1252 (A0) ; deux
           # appels successifs (un litteral dans gsub() donnait un resultat
           # instable sous une locale Windows-1252).
           nbsp <- paste0("1", intToUtf8(160), "234")
           nbsp1252 <- rawToChar(as.raw(c(0x31, 0xa0, 0x32, 0x33, 0x34)))
           oui <- c("NA", "nan", "N/A", "#n/a", "N.D.", "-", "1,5", "1 234", nbsp, nbsp1252,
                    "1.234,5", "1,234.5", "'1'234", "+3")
           identical(.allure_manquante_ou_nombre(oui), rep(TRUE, 14)) &&
             identical(.allure_manquante_ou_nombre(oui), rep(TRUE, 14)) &&
             identical(.allure_manquante_ou_nombre(
               c("12a", "TRUE", "x", "a2017", "serie", "annee", "--", "", ".", "NA2", NA)), rep(FALSE, 11))
         })
verifier("Lecture vecteur : cellule d'espaces sous un en-tete refusee a l'alignement (colonne 1 : en-tete \"a\" sans valeur) (#95)",
         a_motif(msg_ligne(c("a,b,c", "\"   \",2,3")), "colonne 1 : en-tete \"a\" sans valeur"))
verifier("Lecture vecteur : formats sains inchanges (en-tete x en colonne, etiquette x, en-tetes a2017...) (#95)",
         {
           lit <- function(l, sep = ",", dec = ".") { f <- tempfile(); writeLines(l, f); usp_lire_vecteur(f, sep, dec) }
           identical(lit(c("x", "1", "2", "3")), c(1, 2, 3)) &&
             identical(lit("x,1,2,3"), c(1, 2, 3)) &&
             identical(lit(c("serie,a2017,a2018", "x,1,2")), c(1, 2)) &&
             identical(lit(c("12a", "1", "2")), c(1, 2)) &&
             identical(lit(c("a2017;a2018;a2019", "1,5;2;3"), ";", ","), c(1.5, 2, 3))
         })
verifier("Lecture vecteur : serie en ligne, vide au milieu de la ligne de valeurs : message #33 inchange (#95)",
         a_motif(msg_ligne(c("a,b,c", "1,,3")), "Cellule(s) vide(s) en position 2"))
verifier("Lecture vecteur : serie en ligne, colonnes alignees acceptees (colonne vide de bord, etiquette de ligne) (#95)",
         {
           lit <- function(l) { f <- tempfile(); writeLines(l, f); usp_lire_vecteur(f) }
           identical(lit(c(",b,c,d", ",2,3,4")), c(2, 3, 4)) &&
             identical(lit(c("a,b,c,d,", "1,2,3,4,")), c(1, 2, 3, 4)) &&
             identical(lit(c("serie,a2017,a2018", "x,1,2")), c(1, 2)) &&
             identical(lit(c(",a2017,a2018", "x,1,2")), c(1, 2)) &&
             identical(lit(c("a,b,c", "1,2,3", "")), c(1, 2, 3))
         })
# Issue #96 : BOM UTF-8 (EF BB BF) en tete du fichier. Fichiers ecrits en
# binaire ; lecture dans la locale courante, puis, si le systeme l'accepte,
# sous LC_CTYPE = "C" (non UTF-8, ou le defaut se manifestait), la locale
# de l'appelant etant restauree en sortie.
bom_csv <- function(txt) {
  f <- tempfile(fileext = ".csv")
  writeBin(c(as.raw(c(0xef, 0xbb, 0xbf)), charToRaw(txt)), f)
  f
}
lit_bom <- function() list(
  usp_lire_vecteur(bom_csv("1,2,3\n")),
  usp_lire_vecteur(bom_csv("1\n2\n3\n")),
  usp_lire_vecteur(bom_csv("x\n1\n2\n3\n")),
  usp_lire_vecteur(bom_csv("a2017;a2018;a2019\n1,5;2;3\n"), ";", ","))
attendu_bom <- list(c(1, 2, 3), c(1, 2, 3), c(1, 2, 3), c(1.5, 2, 3))
verifier("Lecture vecteur : CSV avec BOM ecrit en binaire lu sans perte dans la locale courante (#96)",
         identical(lit_bom(), attendu_bom))
# Evalue f() sous LC_CTYPE = "C" et restaure la locale de l'appelant ; rend
# "locale C indisponible" (avec un message visible) si le systeme refuse la
# locale ou si elle reste UTF-8, l'assertion etant alors neutre.
sous_locale_c <- function(f) {
  avant <- Sys.getlocale("LC_CTYPE")
  r <- tryCatch({
    pose <- suppressWarnings(Sys.setlocale("LC_CTYPE", "C"))
    if (!nzchar(pose) || isTRUE(l10n_info()[["UTF-8"]])) "locale C indisponible" else f()
  }, finally = suppressWarnings(Sys.setlocale("LC_CTYPE", avant)))
  if (!identical(Sys.getlocale("LC_CTYPE"), avant)) stop("locale LC_CTYPE non restauree")
  if (identical(r, "locale C indisponible"))
    message("  (information) LC_CTYPE = C indisponible ou UTF-8 : assertion BOM non exercee")
  r
}
verifier("Lecture vecteur : CSV avec BOM lu sans perte sous LC_CTYPE = C (non UTF-8), locale restauree (#96)",
         {
           r <- sous_locale_c(lit_bom)
           identical(r, "locale C indisponible") || identical(r, attendu_bom)
         })
# Lecteurs de l'application (read.csv avec en-tete, puis engine_lire_*) : hors
# locale UTF-8, le BOM altere le premier nom de colonne ("X...t" sous C).
verifier("Lecture t, xt, yt : CSV avec BOM lu par read.csv sous LC_CTYPE = C, colonne t reconnue et controlee (#96)",
         {
           r <- sous_locale_c(function() {
             ok <- engine_lire_donnees_csv(utils::read.csv(
               bom_csv("t,xt,yt\n2,11,21\n1,10,20\n3,12,22\n"), stringsAsFactors = FALSE))
             trou <- engine_lire_donnees_csv(utils::read.csv(
               bom_csv("t,xt,yt\n1,10,20\n3,12,22\n"), stringsAsFactors = FALSE))
             list(isTRUE(ok$ok) && identical(ok$xt, c(10, 11, 12)) && identical(ok$yt, c(20, 21, 22)),
                  !trou$ok && contient(trou$erreurs, "non consecutives"))
           })
           identical(r, "locale C indisponible") || identical(r, list(TRUE, TRUE))
         })
verifier("Lecture triangle : CSV 5 x 5 avec colonne i et BOM lu par read.csv sous LC_CTYPE = C, ok = TRUE (#96)",
         {
           tri <- paste0("i,d1,d2,d3,d4,d5\n1,100,150,170,180,185\n2,110,160,180,190,\n",
                         "3,120,175,195,,\n4,130,185,,,\n5,140,,,,\n")
           r <- sous_locale_c(function() {
             v <- engine_lire_triangle(utils::read.csv(bom_csv(tri), stringsAsFactors = FALSE,
                                                       row.names = NULL))
             isTRUE(v$ok) && identical(dim(v$triangle), c(5L, 5L)) && identical(v$triangle[1, 1], 100)
           })
           identical(r, "locale C indisponible") || isTRUE(r)
         })
verifier("Retrait du BOM d'un nom de colonne : formes brute, \"X...\", \"X.U.FEFF.\" et EF 2E 2E ; autres noms intacts (#96)",
         {
           b <- function(...) rawToChar(as.raw(c(...)))
           identical(.nom_sans_bom(b(0xef, 0xbb, 0xbf, 0x74)), "t") &&
             identical(.nom_sans_bom("X...t"), "t") && identical(.nom_sans_bom("X.U.FEFF.i"), "i") &&
             identical(.nom_sans_bom(b(0xef, 0x2e, 0x2e, 0x78, 0x74)), "xt") &&
             identical(.nom_sans_bom("t"), "t") && identical(.nom_sans_bom("X..."), "X...") &&
             identical(.nom_sans_bom("X.1"), "X.1") && identical(.nom_sans_bom(NA_character_), NA_character_)
         })
verifier("Retrait du BOM : .sans_bom() retire EF BB BF de tete seulement, laisse le reste intact (#96)",
         {
           s <- rawToChar(as.raw(c(0xef, 0xbb, 0xbf, 0x31, 0x32)))
           identical(.sans_bom(s), "12") && identical(.sans_bom("12"), "12") &&
             identical(.sans_bom(""), "") && identical(.sans_bom(NA_character_), NA_character_) &&
             identical(.sans_bom(rawToChar(as.raw(c(0x31, 0xef, 0xbb, 0xbf)))),
                       rawToChar(as.raw(c(0x31, 0xef, 0xbb, 0xbf))))
         })

fin_fichier()
