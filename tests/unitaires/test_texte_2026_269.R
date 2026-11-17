###############################################################################
#  tests/unitaires/test_texte_2026_269.R  --  TEXTE "2026/269" (>= 30.1.2027)
#
#  Issue #504, ADR 0019, point 3, commit (c) de la fiche S3 de
#  docs/feuille-de-route.md (le commit qui change un resultat) : a une date
#  de reference posterieure ou egale au 30.1.2027, le moteur applique les
#  art. 117 et 148 dans leur version modifiee par le reglement delegue (UE)
#  2026/269 (art. 1er, points 29) et 39), p. 25-26 et 29-30 du PDF verse a la
#  racine du depot), regle portee par engine_valider_declarations() seule :
#    - methode du risque de primes, donnees nettes, segment a facteur NP
#      standard different de 100 % (II-1, II-4, II-5) : reassurance_np
#      exigee, sigma standard saisi ou non ; TRUE : NP standard x sigma brut ;
#      FALSE : sigma brut (100 %) ; ailleurs (donnees brutes, autre segment,
#      annexe XIV, aucun segment) : declaration consignee sans effet ;
#    - methodes de reserve : cdd_qualifiante exigee, sigma standard saisi ou
#      non (D-S3-7) ; TRUE : refus, hors du domaine (R-3 ouverte, D-S3-4) ;
#      FALSE : sigma(res,s) de l'annexe.
#  Criteres de la ligne (c) du plan de forme : objets identical() aux donnees
#  brutes (sans reassurance NP) et a l'appel a DATE_REFERENCE_TESTS (avec),
#  hors champs de metadata designes ; sigma_USP de II-1 et des methodes de
#  reserve egaux a ceux des references a TOLERANCE (comparateur unique,
#  ecart_feuille() de tests/outils_tests.R) ; conformite d'un sigma saisi
#  jugee selon le texte applicable.
#  B = 99 (minimum d'usage) pour les identites entre executions ; B = 999
#  (defaut, celui des references) pour les comparaisons aux references.
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_texte_2026_269.R")

.racine269 <- if (exists("RACINE", inherits = TRUE)) RACINE else "."
# Comparateur unique aux references (ADR 0006, second amendement).
outils269 <- new.env(parent = globalenv())
sys.source(file.path(.racine269, "tests", "outils_tests.R"), envir = outils269)
.jeux269 <- list(
  donnees_ln = utils::read.csv(file.path(.racine269, "tests", "donnees", "donnees_ln.csv")),
  donnees_ln_interieur = utils::read.csv(file.path(.racine269, "tests", "donnees",
                                                   "donnees_ln_interieur.csv")))
.tri269 <- local({
  df <- utils::read.csv(file.path(.racine269, "tests", "donnees", "triangle_mw.csv"))
  m <- as.matrix(df[, setdiff(names(df), "i")]); storage.mode(m) <- "double"; unname(m)
})
B269 <- 99
DATE269 <- "2027-01-30"
# Appel de la methode du risque de primes sur un jeu, arguments
# supplementaires passes tels quels.
prime269 <- function(jeu, segment, ..., B = B269) {
  d <- .jeux269[[jeu]]
  run_engine(xt = d$xt, yt = d$yt, methode = "premium", segment = segment, annexe = "II",
             B = B, ...)
}
reserve269 <- function(methode, ..., B = B269) {
  d <- .jeux269$donnees_ln
  if (methode == "reserve2")
    run_engine(methode = "reserve2", triangle = .tri269, segment = 1, annexe = "II", B = B, ...)
  else run_engine(xt = d$xt, yt = d$yt, methode = "reserve1", segment = 1, annexe = "II", B = B, ...)
}
# Resultat sans les champs d'execution, et sans les champs designes de metadata.
sans269 <- function(r, champs = character(0)) {
  r$metadata[c("horodatage", "duree_sec", "version_R", champs)] <- NULL
  r
}
essai269 <- function(expr) tryCatch(expr, error = function(e) e)
sigma_ref269 <- function(cas) readRDS(outils269$chemin_reference(cas))$parametre_final$sigma_usp
conforme269 <- function(ref, val) isTRUE(outils269$ecart_feuille(ref, val)$conforme)

## --- engine_valider_declarations() : regle du texte "2026/269" -------------
verifier("#504 (c) engine_valider_declarations() a 2027-01-30 : texte \"2026/269\" ; primes nettes II-1, II-4, II-5 : np_requise, facteur NP standard si TRUE, 1 si FALSE, refus si absente (facteur NA) ; reserve : cdd_requise, refus si absente ou TRUE",
         {
           v <- function(...) engine_valider_declarations(..., date_reference = DATE269)
           ok <- TRUE
           for (s in c(1, 4, 5)) {
             a <- v("premium", s, "II", "nettes")
             t <- v("premium", s, "II", "nettes", reassurance_np = TRUE)
             f <- v("premium", s, "II", "nettes", reassurance_np = FALSE)
             ok <- ok && identical(a$ok, FALSE) && identical(a$texte_applicable, "2026/269") &&
               identical(a$np_requise, TRUE) && identical(a$facteur_np, NA_real_) &&
               length(a$erreurs) == 1L &&
               grepl("^Declaration de reassurance non proportionnelle exigee \\(reassurance_np absente\\)",
                     a$erreurs) &&
               isTRUE(t$ok) && identical(t$facteur_np, ANNEXE_II$np_standard[s]) &&
               isTRUE(f$ok) && identical(f$facteur_np, 1) && identical(f$np_requise, TRUE) &&
               identical(f$cdd_requise, FALSE)
           }
           for (m in c("reserve1", "reserve2")) {
             a <- v(m, 1, "II", NULL); t <- v(m, 1, "II", NULL, cdd_qualifiante = TRUE)
             f <- v(m, 1, "II", NULL, cdd_qualifiante = FALSE)
             ok <- ok && identical(a$ok, FALSE) && identical(a$cdd_requise, TRUE) &&
               grepl("^Declaration de couverture pour developpements defavorables exigee \\(cdd_qualifiante absente\\)",
                     a$erreurs) &&
               identical(t$ok, FALSE) && length(t$erreurs) == 1L &&
               grepl("^Couverture pour developpements defavorables qualifiante declaree \\(cdd_qualifiante = TRUE\\) : calcul hors du domaine",
                     t$erreurs) &&
               isTRUE(f$ok) && identical(f$np_requise, FALSE) && identical(f$facteur_np, NA_real_)
           }
           ok
         })
verifier("#504 (c) engine_valider_declarations() a 2027-01-30 : aucune declaration exigee pour les donnees brutes, les autres segments de l'annexe II, l'annexe XIV et sans segment (primes) ; reassurance_np consignee sans effet en reserve, cdd_qualifiante en primes",
         {
           v <- function(...) engine_valider_declarations(..., date_reference = DATE269)
           ok <- TRUE
           for (a in c("II", "XIV")) for (s in seq_len(if (a == "II") 12L else 4L)) {
             b <- v("premium", s, a, "brutes")
             n <- v("premium", s, a, "nettes")
             agit <- a == "II" && s %in% c(1, 4, 5)
             ok <- ok && isTRUE(b$ok) && identical(b$np_requise, FALSE) &&
               identical(b$facteur_np, NA_real_) &&
               (agit || (isTRUE(n$ok) && identical(n$np_requise, FALSE) && identical(n$facteur_np, 1)))
           }
           x <- v("premium", NULL, "II", "nettes")
           r <- v("reserve1", 1, "II", NULL, reassurance_np = TRUE, cdd_qualifiante = FALSE)
           p <- v("premium", 1, "II", "brutes", cdd_qualifiante = TRUE)
           ok && isTRUE(x$ok) && identical(x$np_requise, FALSE) && identical(x$facteur_np, NA_real_) &&
             isTRUE(r$ok) && identical(r$reassurance_np, TRUE) &&
             isTRUE(p$ok) && identical(p$cdd_qualifiante, TRUE) && identical(p$cdd_requise, FALSE)
         })

## --- usp_parametre_standard() : seize segments, independance ---------------
verifier("#504 (c) usp_parametre_standard() a 2027-01-30, seize segments : donnees brutes et segments a facteur NP de 100 % (annexe XIV comprise) : sigma standard identical quelle que soit la declaration (NULL, TRUE, FALSE) ; II-1, II-4, II-5 nettes : NULL erreur, TRUE NP x sigma brut, FALSE sigma brut",
         {
           ok <- TRUE
           p <- function(s, a, n, np) usp_parametre_standard("premium", s, a, n, date_reference = DATE269,
                                                             reassurance_np = np)$sigma_standard
           for (a in c("II", "XIV")) for (s in seq_len(if (a == "II") 12L else 4L)) {
             inf <- usp_segment_infos(s, a)
             for (n in c("brutes", "nettes")) {
               agit <- n == "nettes" && inf$np_standard != 1
               if (!agit) {
                 ok <- ok && identical(p(s, a, n, NULL), inf$sigma_prime_brut) &&
                   identical(p(s, a, n, TRUE), inf$sigma_prime_brut) &&
                   identical(p(s, a, n, FALSE), inf$sigma_prime_brut)
               } else {
                 ok <- ok && leve_erreur(p(s, a, n, NULL)) &&
                   identical(p(s, a, n, TRUE), inf$np_standard * inf$sigma_prime_brut) &&
                   identical(p(s, a, n, FALSE), inf$sigma_prime_brut)
               }
             }
           }
           ok && identical(sort(SEGMENTS$cle[SEGMENTS$np_standard != 1]), c("II-1", "II-4", "II-5"))
         })
verifier("#504 (c) usp_parametre_standard() : a 2027-01-29 (texte \"2019/981\"), reassurance_np = FALSE reste sans effet (sigma standard 0,08 sur II-1 nettes) ; a 2027-01-30, 0,10",
         {
           a <- usp_parametre_standard("premium", 1, "II", "nettes", date_reference = "2027-01-29",
                                       reassurance_np = FALSE)
           b <- usp_parametre_standard("premium", 1, "II", "nettes", date_reference = DATE269,
                                       reassurance_np = FALSE)
           identical(a$texte_applicable, "2019/981") && identical(a$sigma_standard, 0.8 * 0.10) &&
             identical(b$texte_applicable, "2026/269") && identical(b$sigma_standard, 0.10) &&
             identical(b$facteur_np, 1) && identical(b$np_standard, 0.8)
         })
verifier("#504 (c) usp_parametre_standard() appelee directement : declaration exigee absente -> erreur (II-1 nettes, sigma saisi avec segment compris ; reserve no 1 et no 2, sigma saisi compris) ; cdd_qualifiante = TRUE -> erreur ; sigma saisi sans segment (primes) accepte",
         leve_erreur(usp_parametre_standard("premium", 1, "II", "nettes", date_reference = DATE269)) &&
           leve_erreur(usp_parametre_standard("premium", 1, "II", "nettes", sigma_standard = 0.1,
                                              date_reference = DATE269)) &&
           leve_erreur(usp_parametre_standard("reserve1", 1, "II", date_reference = DATE269)) &&
           leve_erreur(usp_parametre_standard("reserve2", NULL, "II", sigma_standard = 0.1,
                                              date_reference = DATE269)) &&
           leve_erreur(usp_parametre_standard("reserve2", 1, "II", date_reference = DATE269,
                                              cdd_qualifiante = TRUE)) &&
           leve_erreur(usp_parametre_standard("reserve1", NULL, "II", sigma_standard = 0.1,
                                              date_reference = DATE269, cdd_qualifiante = TRUE)) &&
           !leve_erreur(usp_parametre_standard("premium", NULL, "II", "nettes", sigma_standard = 0.1,
                                               date_reference = DATE269)))

## --- run_engine() : identites, II-1, II-4, II-5, deux jeux -----------------
# Sans reassurance NP : objet identical() a celui des donnees brutes a la
# meme date, hors metadata$nature_donnees et metadata$reassurance_np. Avec :
# identical() a celui de DATE_REFERENCE_TESTS (texte "2019/981", declaration
# non fournie), hors metadata$date_reference, texte_applicable et
# reassurance_np.
for (jeu in names(.jeux269)) for (s in c(1, 4, 5)) {
  sans_np <- prime269(jeu, s, nature_donnees = "nettes", date_reference = DATE269,
                      reassurance_np = FALSE)
  brutes <- prime269(jeu, s, nature_donnees = "brutes", date_reference = DATE269)
  avec_np <- prime269(jeu, s, nature_donnees = "nettes", date_reference = DATE269,
                      reassurance_np = TRUE)
  avant <- prime269(jeu, s, nature_donnees = "nettes", date_reference = DATE_REFERENCE_TESTS)
  verifier(sprintf("#504 (c) %s II-%d nettes a 2027-01-30 : sans reassurance NP, identical() aux donnees brutes hors nature_donnees et reassurance_np ; avec, identical() a DATE_REFERENCE_TESTS hors date_reference, texte_applicable et reassurance_np",
                   jeu, s),
           isTRUE(sans_np$ok) && isTRUE(avec_np$ok) &&
             identical(sans_np$metadata$texte_applicable, "2026/269") &&
             identical(sans_np$metadata$reassurance_np, FALSE) &&
             identical(avec_np$metadata$reassurance_np, TRUE) &&
             identical(sans269(sans_np, c("nature_donnees", "reassurance_np")),
                       sans269(brutes, c("nature_donnees", "reassurance_np"))) &&
             identical(sans269(avec_np, c("date_reference", "texte_applicable", "reassurance_np")),
                       sans269(avant, c("date_reference", "texte_applicable", "reassurance_np"))) &&
             identical(sans_np$parametre_final$sigma_standard, ANNEXE_II$sigma_prime_brut[s]))
}
verifier("#504 (c) run_engine() a 2027-01-30, II-1 nettes sans reassurance_np : ok = FALSE, sans erreur R, motif nommant reassurance_np en tete, metadata reduite ; sigma standard saisi avec segment designe : refus aussi (Q-S3-3 (ii)) ; donnees brutes, II-2 nettes, annexe XIV nettes : acceptes sans declaration",
         {
           a <- essai269(prime269("donnees_ln", 1, nature_donnees = "nettes", date_reference = DATE269))
           b <- essai269(prime269("donnees_ln", 1, nature_donnees = "nettes", date_reference = DATE269,
                                  sigma_standard = 0.1))
           ok_sans <- function(r) isTRUE(r$ok) && identical(r$metadata$reassurance_np, NA)
           d <- .jeux269$donnees_ln
           !inherits(a, "error") && identical(a$ok, FALSE) &&
             grepl("(reassurance_np absente)", a$validation$erreurs[1], fixed = TRUE) &&
             identical(names(a$metadata), c("horodatage", "methode")) &&
             !inherits(b, "error") && identical(b$ok, FALSE) &&
             grepl("(reassurance_np absente)", b$validation$erreurs[1], fixed = TRUE) &&
             ok_sans(prime269("donnees_ln", 1, nature_donnees = "brutes", date_reference = DATE269)) &&
             ok_sans(prime269("donnees_ln", 2, nature_donnees = "nettes", date_reference = DATE269)) &&
             ok_sans(run_engine(xt = d$xt, yt = d$yt, methode = "premium", segment = 1, annexe = "XIV",
                                nature_donnees = "nettes", date_reference = DATE269, B = B269))
         })

## --- Methodes de reserve ---------------------------------------------------
verifier("#504 (c) reserve no 1 et no 2 a 2027-01-30 : cdd_qualifiante absente -> refus, TRUE -> refus (sigma standard saisi compris, D-S3-7), sans erreur R, motif en tete ; TRUE a 2027-01-29 : accepte, sans effet",
         all(vapply(c("reserve1", "reserve2"), function(m) {
           r <- list(essai269(reserve269(m, date_reference = DATE269)),
                     essai269(reserve269(m, date_reference = DATE269, cdd_qualifiante = TRUE)),
                     essai269(reserve269(m, date_reference = DATE269, cdd_qualifiante = TRUE,
                                         sigma_standard = 0.1)),
                     essai269(reserve269(m, date_reference = DATE269, sigma_standard = 0.1)))
           motifs <- c("(cdd_qualifiante absente)", "(cdd_qualifiante = TRUE)",
                       "(cdd_qualifiante = TRUE)", "(cdd_qualifiante absente)")
           avant_t <- reserve269(m, date_reference = "2027-01-29", cdd_qualifiante = TRUE)
           avant <- reserve269(m, date_reference = "2027-01-29")
           all(vapply(seq_along(r), function(i) !inherits(r[[i]], "error") &&
                        identical(r[[i]]$ok, FALSE) &&
                        grepl(motifs[i], r[[i]]$validation$erreurs[1], fixed = TRUE) &&
                        identical(names(r[[i]]$metadata), c("horodatage", "methode")), logical(1))) &&
             isTRUE(avant_t$ok) && identical(avant_t$metadata$cdd_qualifiante, TRUE) &&
             identical(sans269(avant_t, "cdd_qualifiante"), sans269(avant, "cdd_qualifiante"))
         }, logical(1))))

## --- Conformite d'un sigma standard saisi selon le texte applicable --------
verifier("#504 (c) sigma standard saisi a 0,10 sur II-1 nettes, reassurance_np = FALSE : engine_derogations() conforme TRUE a 2027-01-30 (valeur reglementaire 0,1), FALSE a 2026-12-31 (0,08)",
         {
           a <- prime269("donnees_ln", 1, nature_donnees = "nettes", sigma_standard = 0.10,
                         date_reference = DATE269, reassurance_np = FALSE)
           b <- prime269("donnees_ln", 1, nature_donnees = "nettes", sigma_standard = 0.10,
                         date_reference = DATE_REFERENCE_TESTS, reassurance_np = FALSE)
           da <- engine_derogations(a); db <- engine_derogations(b)
           ia <- which(da$parametre == "sigma_standard"); ib <- which(db$parametre == "sigma_standard")
           length(ia) == 1L && length(ib) == 1L &&
             identical(da$conforme[ia], TRUE) && identical(da$valeur_reglementaire[ia], "0.1") &&
             identical(db$conforme[ib], FALSE) && identical(db$valeur_reglementaire[ib], "0.08")
         })

## --- Trace : engine_parametre_standard() sous le texte "2026/269" ----------
verifier("#504 (c) engine_parametre_standard() a 2027-01-30 : texte \"2026/269\", declaration exigee et son effet, facteur NP applique 1 (FALSE) ou 0,8 (TRUE), trois dernieres lignes inchangees ; reserve : CDD exigee, facteur 100 %",
         {
           f <- prime269("donnees_ln", 1, nature_donnees = "nettes", date_reference = DATE269,
                         reassurance_np = FALSE)
           t <- prime269("donnees_ln", 1, nature_donnees = "nettes", date_reference = DATE269,
                         reassurance_np = TRUE)
           r <- reserve269("reserve1", date_reference = DATE269, cdd_qualifiante = FALSE)
           lire <- function(x) { d <- engine_parametre_standard(x)
             list(t = stats::setNames(d$texte, d$grandeur), v = stats::setNames(d$valeur, d$grandeur),
                  g = d$grandeur) }
           F <- lire(f); Tt <- lire(t); R <- lire(r)
           grepl("^2026/269 : ", F$t[["Texte applicable au parametre standard"]]) &&
             identical(F$t[["Reassurance non proportionnelle en place (declaration)"]],
                       "declaree absente ; exigee sous ce texte : facteur de 100 % applique") &&
             identical(Tt$t[["Reassurance non proportionnelle en place (declaration)"]],
                       "declaree presente ; exigee sous ce texte : facteur NP standard applique") &&
             identical(F$v[["Facteur NP applique a sigma brut"]], 1) &&
             identical(Tt$v[["Facteur NP applique a sigma brut"]], 0.8) &&
             identical(F$v[["sigma standard reglementaire"]], 0.10) &&
             identical(F$t[["sigma standard reglementaire"]], "facteur NP applique x sigma brut") &&
             grepl("modifie par le reglement delegue (UE) 2026/269", F$t[["Parametre standard remplace"]],
                   fixed = TRUE) &&
             identical(tail(F$g, 3), c("Bareme et facteur c applicables (annexe XVII, section G)",
                                       "Bareme et facteur c retenus", "Origine du bareme retenu")) &&
             grepl("^declaree absente ; exigee sous ce texte : facteur de 100 %",
                   R$t[["Couverture pour developpements defavorables qualifiante (declaration)"]]) &&
             identical(R$v[["sigma standard reglementaire"]], ANNEXE_II$sigma_reserve[1]) &&
             grepl("paragraphe 4, ajoute par le reglement delegue (UE) 2026/269",
                   R$t[["Parametre standard remplace"]], fixed = TRUE)
         })

# Libelle de l'effet de la declaration NP (revue finale de S3, critere E5),
# accorde a la ligne du facteur NP applique : II-1, donnees brutes, "sans
# effet : donnees brutes" sous les deux textes ("sans objet : donnees
# brutes") ; donnees nettes, "sans condition" sous "2019/981", exigee sous
# "2026/269" ; sans segment, brutes ou nettes : "aucun segment designe" ;
# II-2 nettes sous "2026/269" : "de 100 % pour ce segment".
verifier("#504 engine_parametre_standard(), reassurance_np = TRUE : effet de la declaration NP, II-1 donnees brutes / nettes x textes \"2019/981\" / \"2026/269\" ; sans segment (brutes sous \"2026/269\", nettes sous \"2019/981\") : aucun segment designe ; II-2 nettes sous \"2026/269\" : facteur de 100 % du segment ; accorde a la ligne du facteur NP applique",
         {
           np <- "Reassurance non proportionnelle en place (declaration)"
           fa <- "Facteur NP applique a sigma brut"
           lire <- function(nat, date, segment = 1, ...) {
             d <- engine_parametre_standard(prime269("donnees_ln", segment, nature_donnees = nat,
                                                     date_reference = date,
                                                     reassurance_np = TRUE, ...))
             stats::setNames(d$texte, d$grandeur)
           }
           b19 <- lire("brutes", "2027-01-29"); b26 <- lire("brutes", DATE269)
           n19 <- lire("nettes", "2027-01-29"); n26 <- lire("nettes", DATE269)
           s0 <- lire("nettes", "2027-01-29", NULL, sigma_standard = 0.1)
           sb <- lire("brutes", DATE269, NULL, sigma_standard = 0.1)
           n26_2 <- lire("nettes", DATE269, 2)
           identical(b19[[np]], "declaree presente ; sans effet : donnees brutes") &&
             identical(b26[[np]], "declaree presente ; sans effet : donnees brutes") &&
             identical(b19[[fa]], "sans objet : donnees brutes") &&
             identical(b26[[fa]], "sans objet : donnees brutes") &&
             identical(n19[[np]],
                       "declaree presente ; sans effet sous ce texte : facteur NP standard sans condition") &&
             identical(n19[[fa]], "NP standard, sans condition") &&
             identical(n26[[np]], "declaree presente ; exigee sous ce texte : facteur NP standard applique") &&
             identical(s0[[np]], "declaree presente ; sans effet : aucun segment designe") &&
             identical(s0[[fa]], "aucun segment designe") &&
             identical(sb[[np]], "declaree presente ; sans effet : aucun segment designe") &&
             identical(sb[[fa]], "aucun segment designe") &&
             identical(n26_2[[np]],
                       "declaree presente ; sans effet : facteur NP standard de 100 % pour ce segment") &&
             identical(n26_2[[fa]], "100 % : facteur NP standard du segment")
         })

## --- sigma_USP egaux a ceux des references (B = 999, defaut) ---------------
# II-1, donnees_ln, nettes a 2027-01-30 : sans reassurance NP, sigma_USP de
# la reference premium (donnees brutes) ; avec, de premium_net. Reserve no 1
# et no 2, cdd_qualifiante = FALSE : sigma_USP de reserve1 et reserve2.
s_sans <- prime269("donnees_ln", 1, nature_donnees = "nettes", date_reference = DATE269,
                   reassurance_np = FALSE, B = 999)$parametre_final$sigma_usp
s_avec <- prime269("donnees_ln", 1, nature_donnees = "nettes", date_reference = DATE269,
                   reassurance_np = TRUE, B = 999)$parametre_final$sigma_usp
s_r1 <- reserve269("reserve1", date_reference = DATE269, cdd_qualifiante = FALSE,
                   B = 999)$parametre_final$sigma_usp
s_r2 <- reserve269("reserve2", date_reference = DATE269, cdd_qualifiante = FALSE,
                   B = 999)$parametre_final$sigma_usp
verifier("#504 (c) a 2027-01-30, B = 999 : sigma_USP de II-1 nettes sans reassurance NP = reference premium, avec = reference premium_net ; reserve no 1 et no 2 sans CDD qualifiante = references reserve1 et reserve2 (ecart_feuille(), TOLERANCE)",
         conforme269(sigma_ref269("premium"), s_sans) &&
           conforme269(sigma_ref269("premium_net"), s_avec) &&
           conforme269(sigma_ref269("reserve1"), s_r1) &&
           conforme269(sigma_ref269("reserve2"), s_r2) &&
           !conforme269(sigma_ref269("premium_net"), s_sans))

fin_fichier()
