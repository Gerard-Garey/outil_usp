###############################################################################
#  tests/unitaires/test_regressions_qr.R  --  SIX REGRESSIONS AUXILIAIRES PAR
#                         QR CONTRE LEUR CALCUL PAR lm() / anova() (#237)
#
#  Depuis #237, test_breusch_pagan_original(), test_breusch_pagan(),
#  test_white(), test_brown_forsythe(), test_reset() et .usp_lm_pondere()
#  (constante et TOST) calculent leurs regressions par .usp_mco_qr() (QR
#  LINPACK de lm.fit(), formes fermees de summary.lm() et anova()). Chacune
#  est confrontee a la contre-implementation par lm() / anova() de
#  tests/outils_tests.R (contre_bp79() ... contre_lm_pondere(), corps d'avant
#  #237), sur :
#    - les jeux des cas de reference (J1, donnees_ln.csv) et J2 ;
#    - 1 000 jeux tires sous graine (volumes continus, ex aequo, k = 3) ;
#    - des echelles extremes (x, y, u x 1e-160 et 1e160) ;
#    - des etendues relatives de 8,6e-4, 2,9e-3 et 2,9e-6 ;
#    - k = 2, k = 3, volumes constants, pertes constantes, poids invalides,
#      regresseur ecarte par le pivotage, entrees sous-normales.
#  Critere (#237) : tolerance relative 1e-12 sur stat (et sur p, et sur les
#  quatre colonnes des coefficients ponderes), identite des NA / NaN, des
#  motifs non_applicable et des noms de champs ; une erreur de l'une des deux
#  implementations doit etre une erreur de l'autre.
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_regressions_qr.R")

# Contre-implementation : outils_tests.R dans un environnement dedie (comme
# test_comparateur.R) ; ses fonctions contre_*() y voient le moteur qu'il
# charge, le meme R/engine.R que celui de la batterie.
.dossier <- if (exists("DOSSIER_UNITAIRES", inherits = TRUE)) DOSSIER_UNITAIRES else {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  if (length(.f)) dirname(.f) else "tests/unitaires"
}
outils_env <- new.env(parent = globalenv())
sys.source(file.path(.dossier, "..", "outils_tests.R"), envir = outils_env)

REL_QR <- 1e-12
# Paires (moteur, contre-implementation), avec la forme des arguments.
PAIRES <- list(
  BP79   = list(f = test_breusch_pagan_original, g = outils_env$contre_bp79),
  BP     = list(f = test_breusch_pagan,          g = outils_env$contre_bp),
  White  = list(f = test_white,                  g = outils_env$contre_white),
  BF     = list(f = test_brown_forsythe,         g = outils_env$contre_bf),
  RESET  = list(f = test_reset,                  g = outils_env$contre_reset),
  Pond   = list(f = .usp_lm_pondere,             g = outils_env$contre_lm_pondere))

# Evaluation sans avertissement (summary.lm() et anova.lm() en emettent sur
# un ajustement quasi parfait) ; une erreur est rendue comme objet.
evaluer <- function(f, args) tryCatch(suppressWarnings(do.call(f, args)), error = function(e) e)

# Comparaison d'une valeur numerique : memes NA / NaN, memes types, ecart
# relatif <= REL_QR ailleurs (absolu si la reference est nulle).
meme_num <- function(a, b) {
  if (!identical(typeof(a), typeof(b)) || length(a) != length(b)) return(FALSE)
  if (!identical(is.na(a), is.na(b)) || !identical(is.nan(a), is.nan(b))) return(FALSE)
  k <- !is.na(b)
  all(a[k] == b[k] | abs(a[k] - b[k]) <= REL_QR * abs(b[k]))
}
# Ecart relatif maximal (hors NA et zeros de reference), pour le compte rendu.
ecart_rel <- function(a, b) {
  a <- as.numeric(a); b <- as.numeric(b); k <- !is.na(a) & !is.na(b) & b != 0
  if (!any(k)) 0 else max(abs(a[k] - b[k]) / abs(b[k]))
}
# Concordance d'un resultat du moteur (a) et de la contre-implementation (b).
concorde <- function(nom, a, b) {
  if (inherits(a, "error") || inherits(b, "error"))
    return(inherits(a, "error") && inherits(b, "error"))
  if (nom == "Pond") {
    if (is.null(a) || is.null(b)) return(is.null(a) && is.null(b))
    ca <- a$coefficients; cb <- b$coefficients
    return(identical(dimnames(ca), dimnames(cb)) && meme_num(as.vector(ca), as.vector(cb)))
  }
  if (!identical(names(a), names(b))) return(FALSE)
  all(vapply(names(b), function(ch) {
    if (is.character(b[[ch]]) || is.character(a[[ch]])) identical(a[[ch]], b[[ch]])
    else meme_num(a[[ch]], b[[ch]])
  }, logical(1)))
}
# Arguments des six fonctions sur un jeu (x, y, z, pi).
arguments <- function(x, y, z, pi)
  list(BP79 = list(z^2, x), BP = list(z^2, x), White = list(z^2, x), BF = list(z, x),
       RESET = list(x, y), Pond = list(x, y, pi))
# Confronte les six fonctions sur un jeu ; rend les noms des desaccords.
confronter <- function(args, quelles = names(PAIRES)) {
  ko <- character(0)
  for (nm in quelles) {
    a <- evaluer(PAIRES[[nm]]$f, args[[nm]]); b <- evaluer(PAIRES[[nm]]$g, args[[nm]])
    if (!isTRUE(concorde(nm, a, b))) ko <- c(ko, nm)
  }
  ko
}
rapporter <- function(ko) if (length(ko)) paste("desaccord :", paste(unique(ko), collapse = ", ")) else TRUE

# Jeux nommes : J1 (cas de reference), J2 (delta interieur).
ln <- utils::read.csv(file.path(RACINE, "tests", "donnees", "donnees_ln.csv"))
x1 <- ln$xt; y1 <- ln$yt; f1 <- usp_ajuster(x1, y1)
x2 <- c(50, 80, 120, 200, 300, 150, 90, 60)
y2 <- c(29.92, 56.9, 101.25, 123.06, 207.23, 105.91, 68.59, 40.05)
f2 <- usp_ajuster(x2, y2)
alt <- rep(c(1, -1), 4)

## --- 1. Jeux des cas de reference -------------------------------------------
verifier("Cas de reference (J1, donnees_ln.csv) et J2 : six regressions = lm() / anova() (rel 1e-12, NA, motifs, noms)",
         rapporter(c(confronter(arguments(x1, y1, f1$z, f1$pi)),
                     confronter(arguments(x2, y2, f2$z, f2$pi)))))
verifier("Cas de reference : constante et TOST alimentes par .usp_lm_pondere() = lignes de summary(lm(y ~ x, weights = w)) (rel 1e-12)",
         all(vapply(list(f1, f2), function(f) {
           m <- outils_env$contre_lm_pondere(f$x, f$y, f$pi)$coefficients
           ti <- test_intercept(f$x, f$y, f$pi); to <- test_tost_intercept(f$x, f$y, f$pi)
           isTRUE(proche(ti$stat, m[1, 3], rel = REL_QR)) && isTRUE(proche(ti$p, m[1, 4], rel = REL_QR)) &&
             isTRUE(proche(ti$a, m[1, 1], rel = REL_QR)) && isTRUE(proche(to$se, m[1, 2], rel = REL_QR)) &&
             identical(to$a, ti$a)
         }, logical(1))))
verifier("Statistiques Monte-Carlo du catalogue (RESET, BP, BP79, White, BF, Intercept) sur J1 et J2 = contre-implementation (rel 1e-12)",
         all(vapply(list(f1, f2), function(f) {
           s <- .stats_bootstrapables(f$x, f$y, f$z, f$pi)
           ref <- c(RESET = outils_env$contre_reset(f$x, f$y)$stat,
                    BP = outils_env$contre_bp(f$z^2, f$x)$stat,
                    BP79 = outils_env$contre_bp79(f$z^2, f$x)$stat,
                    White = outils_env$contre_white(f$z^2, f$x)$stat,
                    BF = outils_env$contre_bf(f$z, f$x)$stat,
                    Intercept = outils_env$contre_lm_pondere(f$x, f$y, f$pi)$coefficients[1, 3])
           isTRUE(proche(s[names(ref)], ref, rel = REL_QR))
         }, logical(1))))

## --- 2. 1 000 jeux tires sous graine ----------------------------------------
# Quatre familles de volumes (continus sur deux decades, ex aequo par paires,
# trois valeurs, etendue relative de 1 %), pertes y = x exp(N(0, 0,3)),
# residus z ~ N(0, 1), pi dans [2 ; 50]. Graine locale (engine_sous_graine()) :
# l'etat aleatoire de la batterie est restaure.
JEUX <- engine_sous_graine(23700237, lapply(seq_len(1000), function(i) {
  x <- switch(i %% 4 + 1,
              exp(stats::runif(8, log(10), log(1000))),
              rep(exp(stats::runif(4, log(10), log(1000))), 2),
              sample(c(100, 150, 230), 8, replace = TRUE),
              100 * (1 + 0.01 * stats::rnorm(8)))
  list(x = x, y = x * exp(stats::rnorm(8, 0, 0.3)), z = stats::rnorm(8), pi = stats::runif(8, 2, 50))
}))
ECARTS <- stats::setNames(numeric(length(PAIRES)), names(PAIRES))
NB_IDENT <- stats::setNames(integer(length(PAIRES)), names(PAIRES))
verifier("1 000 jeux sous graine (T = 8) : six regressions = lm() / anova() (rel 1e-12, NA, motifs, noms)",
         {
           ko <- character(0)
           for (j in JEUX) {
             args <- arguments(j$x, j$y, j$z, j$pi)
             for (nm in names(PAIRES)) {
               a <- evaluer(PAIRES[[nm]]$f, args[[nm]]); b <- evaluer(PAIRES[[nm]]$g, args[[nm]])
               if (!isTRUE(concorde(nm, a, b))) ko <- c(ko, nm)
               if (identical(a, b) || (nm == "Pond" && identical(a$coefficients, b$coefficients)))
                 NB_IDENT[nm] <- NB_IDENT[nm] + 1L
               va <- if (nm == "Pond") a$coefficients else a$stat
               vb <- if (nm == "Pond") b$coefficients else b$stat
               if (!inherits(a, "error") && !inherits(b, "error") && length(va) == length(vb))
                 ECARTS[nm] <- max(ECARTS[nm], ecart_rel(va, vb))
             }
           }
           rapporter(ko)
         })
cat(sprintf("  note : 1 000 jeux, resultats identiques au bit pres : %s ; ecart relatif maximal : %s (#237).\n",
            paste(sprintf("%s %d", names(NB_IDENT), NB_IDENT), collapse = ", "),
            paste(sprintf("%s %.2g", names(ECARTS), ECARTS), collapse = ", ")))
verifier("1 000 jeux : les familles de volumes couvrent k = 3, k = 4 et k = 8 volumes distincts",
         {
           k <- vapply(JEUX, function(j) .usp_nb_volumes_distincts(j$x), integer(1))
           any(k == 3L) && any(k == 4L) && any(k == 8L)
         })

## --- 3. Echelles extremes (mesures de #110) ----------------------------------
verifier("Echelles extremes : x, y, u x 1e-160 et 1e160 (J1 et J2), six regressions = lm() / anova() (memes NA, NaN, motifs)",
         {
           ko <- character(0)
           for (f in list(f1, f2)) for (cc in c(1e-160, 1e160)) {
             ko <- c(ko, confronter(arguments(cc * f$x, cc * f$y, f$z, f$pi)),
                     confronter(arguments(f$x, f$y, cc * f$z, f$pi), c("BP79", "BP", "White", "BF")),
                     confronter(arguments(cc * f$x, f$y, cc * f$z, f$pi)))
           }
           rapporter(ko)
         })
# L'issue de lm() sur ces entrees depend de la plateforme (commentaire de
# test_tost_intercept(), #153) : le motif du TOST n'est pas fige ici. Sa
# coherence avec lm() est controlee, independamment de la plateforme, par
# test_controles_entree.R (#153) ; ce test exige l'identite au calcul par
# lm() et l'absence d'erreur R, et note le motif obtenu.
MOTIFS_SN <- character(0)
verifier("Entrees sous-normales (x et y x 1e-320, 5e-324, J2) : .usp_lm_pondere() identique au calcul par lm(), constante et TOST sans erreur R",
         all(vapply(c(1e-320, 5e-324), function(cc) {
           a <- .usp_lm_pondere(cc * x2, cc * y2, f2$pi)
           b <- suppressWarnings(outils_env$contre_lm_pondere(cc * x2, cc * y2, f2$pi))
           tt <- tryCatch(test_tost_intercept(cc * x2, cc * y2, f2$pi), error = function(e) e)
           ti <- tryCatch(test_intercept(cc * x2, cc * y2, f2$pi), error = function(e) e)
           ok_lm <- isTRUE(concorde("Pond", a, b))
           MOTIFS_SN <<- c(MOTIFS_SN, sprintf("%g : %s, ponderee %s lm()", cc,
             if (inherits(tt, "error")) paste("erreur", conditionMessage(tt))
             else if (is.na(tt$non_applicable)) "calculee" else tt$non_applicable,
             if (ok_lm) "=" else "!="))
           ok_lm && !inherits(tt, "error") && !inherits(ti, "error")
         }, logical(1))))
cat(sprintf("  note : plateforme courante, TOST sous-normal %s (#237).\n",
            paste(MOTIFS_SN, collapse = " ; ")))

## --- 4. Etendues relatives (mesures de #110) ---------------------------------
verifier("Etendues relatives 8,6e-4, 2,9e-3 et 2,9e-6 (x = 100 (1 + cv scale(1:8))) : six regressions = lm() / anova()",
         {
           ko <- character(0)
           for (cv in c(3e-4, 1e-3, 1e-6)) {
             xe <- 100 * (1 + cv * as.numeric(scale(1:8)))
             fe <- usp_ajuster(xe, y1)
             ko <- c(ko, confronter(arguments(xe, y1, fe$z, fe$pi)),
                     confronter(arguments(xe, y1, f1$z, f1$pi)))
           }
           er <- vapply(c(3e-4, 1e-3, 1e-6), function(cv) {
             xe <- 100 * (1 + cv * as.numeric(scale(1:8))); diff(range(xe)) / mean(xe)
           }, numeric(1))
           if (!isTRUE(proche(er, c(8.6e-4, 2.9e-3, 2.9e-6), rel = 0.02))) ko <- c(ko, "etendues")
           rapporter(ko)
         })

## --- 5. Cas limites -------------------------------------------------------
x_k2 <- 100 * (1 + alt * 1e-5)
x_k3 <- 100 * (1 + 1e-2 * rep(c(-1, 0, 1), length.out = 8))
x_k3b <- x_k3; x_k3b[x_k3b == max(x_k3b)] <- min(x_k3b) * (1 + 1e-11)
verifier("k = 2, k = 3, k = 3 de rang numerique deficient (1e-11), volumes constants : six regressions = lm() / anova(), motifs identiques",
         {
           ko <- character(0)
           for (xx in list(x_k2, x_k3, x_k3b, rep(110, 8), 300 * (1 + alt * 1e-8)))
             ko <- c(ko, confronter(arguments(xx, y1, f1$z, f1$pi)))
           rapporter(ko)
         })
verifier("Motifs atteints : (a) k = 2 et (b) rang deficient pour White et RESET, volumes constants ; meme texte que la contre-implementation",
         {
           mot <- function(f, ...) f(...)$non_applicable
           identical(mot(test_white, f1$z^2, x_k2), mot(outils_env$contre_white, f1$z^2, x_k2)) &&
             startsWith(mot(test_white, f1$z^2, x_k2), "moins de trois volumes distincts (k = 2)") &&
             startsWith(mot(test_reset, x_k3b, y1), "regression auxiliaire RESET de rang deficient") &&
             identical(mot(test_reset, x_k3b, y1), mot(outils_env$contre_reset, x_k3b, y1)) &&
             startsWith(mot(test_white, f1$z^2, x_k3b), "regression auxiliaire de White de rang deficient") &&
             identical(mot(test_reset, rep(110, 8), y1), "volumes constants")
         })
verifier("Pertes constantes (y = 70) et pertes nulles : RESET, ponderee = lm() / anova() ; White et BP a u2 nul = lm()",
         rapporter(c(confronter(arguments(x2, rep(70, 8), f2$z, f2$pi), c("RESET", "Pond")),
                     confronter(arguments(x2, rep(0, 8), rep(0, 8), f2$pi), c("BP", "White", "BF", "RESET")))))
verifier("Poids invalides (pi NA, Inf, 0, -1, longueur 7) : .usp_lm_pondere() et contre-implementation rendent NULL",
         all(vapply(list(replace(f2$pi, 1, NA), replace(f2$pi, 1, Inf), replace(f2$pi, 1, 0),
                         replace(f2$pi, 1, -1), f2$pi[-1]), function(p)
           is.null(.usp_lm_pondere(x2, y2, p)) && is.null(outils_env$contre_lm_pondere(x2, y2, p)),
           logical(1))))
verifier("x ecarte par le pivotage : .usp_lm_pondere() sans ligne x comme summary(lm()) (x = 300 (1 +/- 1e-9)) ; BP et BP79 NA (T = 200, x[2] = 110 (1 + 1,1e-6))",
         {
           xq <- 300 * (1 + alt * 1e-9)
           a <- .usp_lm_pondere(xq, y2, f2$pi); b <- outils_env$contre_lm_pondere(xq, y2, f2$pi)
           xa <- rep(110, 200); xa[2] <- 110 * (1 + 1.1e-6)
           u2 <- (sin(seq_len(200)) + 1.5)^2
           identical(rownames(a$coefficients), "(Intercept)") && isTRUE(concorde("Pond", a, b)) &&
             !usp_volumes_constants(xa) &&
             identical(confronter(list(BP79 = list(u2, xa), BP = list(u2, xa), White = list(u2, xa)),
                                  c("BP79", "BP", "White")), character(0)) &&
             is.na(test_breusch_pagan(u2, xa)$stat) && is.na(test_breusch_pagan_original(u2, xa)$stat)
         })
verifier("Valeurs manquantes dans la reponse (u2, u ou y avec un NA) : exclusion de la ligne comme na.omit de lm(), ou erreur des deux cotes",
         {
           zn <- f2$z; zn[3] <- NA; yn <- y2; yn[5] <- NA
           rapporter(c(confronter(arguments(x2, y2, zn, f2$pi), c("BP79", "BP", "White", "BF")),
                       confronter(arguments(x2, yn, f2$z, f2$pi), "RESET")))
         })
verifier("Reponse ou regresseur non fini (Inf) : erreur des deux cotes",
         {
           zi <- f2$z; zi[2] <- Inf; yi <- y2; yi[2] <- Inf
           rapporter(c(confronter(arguments(x2, y2, zi, f2$pi), c("BP", "White", "BF")),
                       confronter(arguments(x2, yi, f2$z, f2$pi), "RESET")))
         })
verifier("Interface : noms et ordre des champs rendus inchanges sur la branche calculee et sur chaque garde",
         {
           noms <- function(f, ...) names(f(...))
           identical(noms(test_breusch_pagan_original, f1$z^2, x1), c("stat", "p", "ddl")) &&
             identical(noms(test_breusch_pagan, f1$z^2, x1), c("stat", "p")) &&
             identical(noms(test_white, f1$z^2, x1), c("stat", "p", "non_applicable")) &&
             identical(noms(test_white, f1$z^2, x_k2), c("stat", "p", "non_applicable")) &&
             identical(noms(test_brown_forsythe, f1$z, x1), c("stat", "p")) &&
             identical(noms(test_reset, x1, y1), c("stat", "p", "non_applicable")) &&
             identical(noms(.usp_lm_pondere, x1, y1, f1$pi), "coefficients") &&
             identical(colnames(.usp_lm_pondere(x1, y1, f1$pi)$coefficients),
                       c("Estimate", "Std. Error", "t value", "Pr(>|t|)"))
         })

fin_fichier()
