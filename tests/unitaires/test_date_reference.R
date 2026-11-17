###############################################################################
#  tests/unitaires/test_date_reference.R  --  DATE DE REFERENCE DU CALCUL
#
#  Issue #504, ADR 0019 (accepte le 17/11/2026), commits (b1), (b3) et (c)
#  de la fiche S3 de docs/feuille-de-route.md : entrees date_reference,
#  reassurance_np et cdd_qualifiante de run_engine(), accueillies, controlees
#  et consignees dans res$metadata. Teste ici :
#    - une date de reference anterieure au 1.1.2020 (borne M6, #19) est
#      refusee comme hors du domaine (ok = FALSE, sans erreur R) ; une date
#      posterieure ou egale au 30.1.2027 (reglement delegue (UE) 2026/269,
#      article 2) fixe le texte "2026/269", dont la regle est testee dans
#      tests/unitaires/test_texte_2026_269.R (commit (c)) ;
#    - la date est obligatoire (commit (b3)) : son absence est un refus
#      motive (ok = FALSE, motif nommant date_reference, sans erreur R) ;
#      appel direct d'usp_parametre_standard() sans date : erreur ; objet a
#      date NA refuse par les fonctions de trace ;
#    - une date ou une declaration mal formee est refusee sans conversion ;
#    - sous "2019/981", les declarations sont consignees sans effet (Q-S3-4)
#      et aucun resultat ne change (meme double pour le sigma standard).
#  Sources des dates : TEXTES_APPLICABLES (R/engine.R, en tete) ; reglement
#  delegue (UE) 2026/269, article 2, PDF verse a la racine du depot, p. 94 :
#  "Il est applicable a partir du 30 janvier 2027".
#  B = 99 (minimum d'usage) pour les executions completes : aucune valeur
#  de reference n'est lue ici, seules des identites entre executions.
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_date_reference.R")

.racine504 <- if (exists("RACINE", inherits = TRUE)) RACINE else "."
.ln504 <- utils::read.csv(file.path(.racine504, "tests", "donnees", "donnees_ln.csv"))
.tri504 <- local({
  df <- utils::read.csv(file.path(.racine504, "tests", "donnees", "triangle_mw.csv"))
  m <- as.matrix(df[, setdiff(names(df), "i")]); storage.mode(m) <- "double"; unname(m)
})
B504 <- 99
# Appel complet d'une methode, arguments supplementaires passes tels quels.
appel504 <- function(methode, ...) {
  base <- switch(methode,
    premium  = list(xt = .ln504$xt, yt = .ln504$yt, methode = "premium", segment = 1,
                    annexe = "II", nature_donnees = "nettes", B = B504),
    reserve1 = list(xt = .ln504$xt, yt = .ln504$yt, methode = "reserve1", segment = 1,
                    annexe = "II", B = B504),
    reserve2 = list(methode = "reserve2", triangle = .tri504, segment = 1, annexe = "II",
                    B = B504))
  do.call(run_engine, c(base, list(...)))
}
# Resultat sans les champs d'execution, et sans les champs designes de metadata.
sans504 <- function(r, champs = character(0)) {
  r$metadata[c("horodatage", "duree_sec", "version_R", champs)] <- NULL
  r
}
# Execution qui rend l'erreur R au lieu de la lever.
essai504 <- function(expr) tryCatch(expr, error = function(e) e)
methodes504 <- c("premium", "reserve1", "reserve2")

## --- Convention des tests et donnees reglementaires ------------------------
verifier("#504 : DATE_REFERENCE_TESTS, lue dans tests/outils_tests.R, vaut \"2026-12-31\" (Q-S3-7)",
         identical(DATE_REFERENCE_TESTS, "2026-12-31"))
verifier("#504 : TEXTES_APPLICABLES, deux lignes, \"2019/981\" du 2020-01-01 et \"2026/269\" du 2027-01-30, chaines sans facteur",
         is.data.frame(TEXTES_APPLICABLES) &&
           identical(TEXTES_APPLICABLES$texte, c("2019/981", "2026/269")) &&
           identical(TEXTES_APPLICABLES$applicable_du, c("2020-01-01", "2027-01-30")))

## --- Refus de la date : ok = FALSE, sans erreur R, pour les trois methodes --
dates_refusees <- list("30/01/2027", "2027-1-30", "2027-02-30", " 2026-12-31", 20261231,
                       as.Date("2026-12-31"), NA, "", c("2026-12-31", "2026-12-31"),
                       NA_character_, "2026-12-31 ", "2026-12-31T00:00:00",
                       "2019-12-31", "0999-12-31")
for (m in methodes504) {
  r <- lapply(dates_refusees, function(x) essai504(appel504(m, date_reference = x)))
  verifier(sprintf("#504 %s : date refusee (mal formee ou < 2020-01-01) -> ok = FALSE, motif en tete nommant date_reference, sans erreur R (%d cas)",
                   m, length(dates_refusees)),
           {
             ko <- !vapply(r, function(x) !inherits(x, "error") && identical(x$ok, FALSE) &&
                             grepl("Date de reference du calcul", x$validation$erreurs[1], fixed = TRUE) &&
                             identical(names(x$metadata), c("horodatage", "methode")), logical(1))
             if (!any(ko)) TRUE else
               paste("cas en defaut :", paste(vapply(dates_refusees[ko], function(x)
                 paste(deparse(x), collapse = " "), character(1)), collapse = " | "))
           })
}
verifier("#504 : motifs distincts : forme (\"date_reference = \"), borne M6 (2020-01-01), absence (\"date_reference absente\") ; 2027-01-30 acceptee (texte \"2026/269\", commit (c)) sur donnees brutes, sans declaration",
         {
           e <- function(x) engine_valider_declarations("premium", 1, "II", "brutes", x)$erreurs
           grepl("non recevable (date_reference = \"2027-1-30\")", e("2027-1-30"), fixed = TRUE) &&
             grepl("anterieure au 2020-01-01", e("2019-12-31"), fixed = TRUE) &&
             grepl("non declaree (date_reference absente)", e(NULL), fixed = TRUE) &&
             identical(e("2027-01-30"), character(0)) &&
             identical(engine_valider_declarations("premium", 1, "II", "brutes",
                                                   "2027-01-30")$texte_applicable, "2026/269") &&
             grepl("format(d, \"%Y-%m-%d\"), ici \"2026-12-31\"", e(as.Date("2026-12-31")),
                   fixed = TRUE)
         })

## --- Dates acceptees : 2020-01-01 et 2027-01-29, sans effet sur le calcul --
r_ref <- appel504("premium", date_reference = DATE_REFERENCE_TESTS)
r_2020 <- appel504("premium", date_reference = "2020-01-01")
r_2027 <- appel504("premium", date_reference = "2027-01-29")
verifier("#504 premium nettes II-1 : \"2020-01-01\" et \"2027-01-29\" acceptees, texte \"2019/981\", resultat identical a celui de DATE_REFERENCE_TESTS hors metadata$date_reference",
         isTRUE(r_ref$ok) && isTRUE(r_2020$ok) && isTRUE(r_2027$ok) &&
           identical(r_2020$metadata$date_reference, "2020-01-01") &&
           identical(r_2027$metadata$date_reference, "2027-01-29") &&
           identical(r_2027$metadata$texte_applicable, "2019/981") &&
           identical(sans504(r_2020, "date_reference"), sans504(r_ref, "date_reference")) &&
           identical(sans504(r_2027, "date_reference"), sans504(r_ref, "date_reference")) &&
           identical(r_ref$parametre_final$sigma_standard, 0.8 * 0.10))

## --- Date absente : refus motive (date obligatoire, commit (b3)) ----------
# Argument omis, et NULL explicite : meme refus.
r_sans <- lapply(methodes504, function(m) essai504(appel504(m)))
r_null <- lapply(methodes504, function(m) essai504(appel504(m, date_reference = NULL)))
r_avec <- lapply(methodes504, function(m) appel504(m, date_reference = DATE_REFERENCE_TESTS))
verifier("#504 : date absente refusee (trois methodes, argument omis ou NULL) : ok = FALSE, sans erreur R, motif en tete nommant date_reference, seul motif, metadata reduite a horodatage et methode",
         all(vapply(c(r_sans, r_null), function(a)
           !inherits(a, "error") && identical(a$ok, FALSE) &&
             length(a$validation$erreurs) == 1L &&
             grepl("^Date de reference du calcul non declaree \\(date_reference absente\\)",
                   a$validation$erreurs[1]) &&
             identical(names(a$metadata), c("horodatage", "methode")), logical(1))) &&
           identical(vapply(r_sans, function(a) a$metadata$methode, character(1)), methodes504) &&
           all(vapply(r_avec, function(b) isTRUE(b$ok) &&
                        identical(b$metadata$date_reference, DATE_REFERENCE_TESTS), logical(1))))
verifier("#504 engine_valider_declarations() sans date : ok = FALSE, un motif, sans erreur R ; date_reference, texte_applicable et facteur_np NA (trois methodes)",
         all(vapply(methodes504, function(m) {
           x <- essai504(engine_valider_declarations(m, 1, "II", if (m == "premium") "nettes" else NULL))
           !inherits(x, "error") && identical(x$ok, FALSE) && length(x$erreurs) == 1L &&
             grepl("date_reference", x$erreurs, fixed = TRUE) &&
             identical(x$date_reference, NA_character_) &&
             identical(x$texte_applicable, NA_character_) && identical(x$facteur_np, NA_real_)
         }, logical(1))))
verifier("#504 : date absente et donnees refusees ensemble : motif de date en tete, motif des donnees garde (premium sans nature)",
         {
           p <- run_engine(xt = .ln504$xt, yt = .ln504$yt, methode = "premium", segment = 1,
                           B = B504)
           identical(p$ok, FALSE) &&
             grepl("^Date de reference du calcul non declaree", p$validation$erreurs[1]) &&
             any(grepl("Nature des donnees non declaree", p$validation$erreurs, fixed = TRUE))
         })
verifier("#504 : annee < 1000 de forme valide (\"0999-12-31\", \"0000-01-01\") : motif hors du domaine (borne M6), non motif de forme ; date inexistante de petite annee (\"0999-02-29\") ou seculaire non bissextile (\"1900-02-29\") : motif de forme",
         {
           e <- function(x) engine_valider_declarations("premium", 1, "II", "brutes", x)
           a <- e("0999-12-31"); z <- e("0000-01-01")
           f <- e("0999-02-29"); g <- e("1900-02-29")
           identical(a$ok, FALSE) && length(a$erreurs) == 1L &&
             grepl("Date de reference du calcul 0999-12-31 hors du domaine de l'outil : anterieure au 2020-01-01",
                   a$erreurs, fixed = TRUE) &&
             identical(a$date_reference, "0999-12-31") &&
             identical(z$ok, FALSE) && grepl("0000-01-01 hors du domaine", z$erreurs, fixed = TRUE) &&
             identical(f$ok, FALSE) &&
             grepl("non recevable (date_reference = \"0999-02-29\")", f$erreurs, fixed = TRUE) &&
             identical(g$ok, FALSE) &&
             grepl("non recevable (date_reference = \"1900-02-29\")", g$erreurs, fixed = TRUE) &&
             isTRUE(e("2024-02-29")$ok)
         })
verifier("#504 : metadata porte date_reference, texte_applicable (caractere), reassurance_np et cdd_qualifiante (logiques NA si non declarees), aucun nombre",
         all(vapply(r_avec, function(r) {
           m <- r$metadata
           identical(m$texte_applicable, "2019/981") && identical(m$reassurance_np, NA) &&
             identical(m$cdd_qualifiante, NA) && is.character(m$date_reference)
         }, logical(1))))

## --- Declarations : forme, refus et consignation sans effet ----------------
decl_refusees <- list("oui", 1, NA, c(TRUE, FALSE), 1L, "TRUE")
for (nom in c("reassurance_np", "cdd_qualifiante")) for (m in methodes504) {
  r <- lapply(decl_refusees, function(v) {
    a <- list(date_reference = DATE_REFERENCE_TESTS); a[[nom]] <- v
    essai504(do.call(appel504, c(list(m), a)))
  })
  verifier(sprintf("#504 %s : %s a \"oui\", 1, NA, c(TRUE, FALSE), 1L ou \"TRUE\" -> ok = FALSE, motif nommant l'argument, sans erreur R",
                   m, nom),
           all(vapply(r, function(x) !inherits(x, "error") && identical(x$ok, FALSE) &&
                        any(grepl(sprintf("Declaration non recevable (%s = ", nom),
                                  x$validation$erreurs, fixed = TRUE)), logical(1))))
}
r_decl <- lapply(methodes504, function(m)
  appel504(m, date_reference = DATE_REFERENCE_TESTS, reassurance_np = TRUE, cdd_qualifiante = FALSE))
r_decl2 <- lapply(methodes504, function(m)
  appel504(m, date_reference = DATE_REFERENCE_TESTS, reassurance_np = FALSE, cdd_qualifiante = TRUE))
verifier("#504 : declarations TRUE / FALSE acceptees pour les trois methodes (Q-S3-4), consignees, sans effet sous \"2019/981\" (resultat identical hors les deux champs)",
         all(vapply(seq_along(methodes504), function(i) {
           a <- r_decl[[i]]; b <- r_decl2[[i]]; o <- r_avec[[i]]
           champs <- c("reassurance_np", "cdd_qualifiante")
           isTRUE(a$ok) && isTRUE(b$ok) &&
             identical(a$metadata$reassurance_np, TRUE) && identical(a$metadata$cdd_qualifiante, FALSE) &&
             identical(b$metadata$reassurance_np, FALSE) && identical(b$metadata$cdd_qualifiante, TRUE) &&
             identical(sans504(a, champs), sans504(o, champs)) &&
             identical(sans504(b, champs), sans504(o, champs))
         }, logical(1))))

## --- Motifs en tete de validation$erreurs, avec ceux des donnees -----------
verifier("#504 : date et donnees refusees ensemble : motif de date en tete, motif des donnees garde (premium sans nature ; reserve2 \"brutes\")",
         {
           p <- run_engine(xt = .ln504$xt, yt = .ln504$yt, methode = "premium", segment = 1,
                           B = B504, date_reference = "2019-12-31")
           q <- run_engine(methode = "reserve2", triangle = .tri504, segment = 1, B = B504,
                           nature_donnees = "brutes", date_reference = "2019-12-31",
                           reassurance_np = "oui")
           identical(p$ok, FALSE) && grepl("^Date de reference du calcul", p$validation$erreurs[1]) &&
             any(grepl("Nature des donnees non declaree", p$validation$erreurs, fixed = TRUE)) &&
             identical(q$ok, FALSE) && grepl("^Date de reference du calcul", q$validation$erreurs[1]) &&
             grepl("^Declaration non recevable \\(reassurance_np", q$validation$erreurs[2]) &&
             any(grepl("section D, paragraphe 2, point f)", q$validation$erreurs, fixed = TRUE))
         })

## --- engine_valider_declarations() : forme de la valeur, facteur NP --------
verifier("#504 engine_valider_declarations() : liste des neuf champs de l'ADR 0019, point 3",
         identical(names(engine_valider_declarations("premium", 1, "II", "nettes", DATE_REFERENCE_TESTS)),
                   c("ok", "erreurs", "date_reference", "texte_applicable", "reassurance_np",
                     "cdd_qualifiante", "np_requise", "cdd_requise", "facteur_np")))
verifier("#504 engine_valider_declarations() : facteur_np = np_standard de la table (nettes, segment designe), NA sinon ; aucune declaration exigee sous \"2019/981\"",
         {
           v <- function(...) engine_valider_declarations(..., date_reference = DATE_REFERENCE_TESTS)
           identical(v("premium", 1, "II", "nettes")$facteur_np, ANNEXE_II$np_standard[1]) &&
             identical(v("premium", 2, "II", "nettes")$facteur_np, 1) &&
             identical(v("premium", 1, "XIV", "nettes")$facteur_np, 1) &&
             identical(v("premium", 1, "II", "brutes")$facteur_np, NA_real_) &&
             identical(v("premium", NULL, "II", "nettes")$facteur_np, NA_real_) &&
             identical(v("reserve1", 1, "II", NULL)$facteur_np, NA_real_) &&
             identical(v("reserve2", 1, "II", "nettes")$facteur_np, NA_real_) &&
             all(vapply(methodes504, function(m) {
               x <- v(m, 1, "II", if (m == "premium") "nettes" else NULL)
               isTRUE(x$ok) && identical(x$np_requise, FALSE) && identical(x$cdd_requise, FALSE)
             }, logical(1)))
         })
verifier("#504 engine_valider_declarations() : aucune erreur R pour une declaration refusee ; ok, erreurs et champs NA",
         {
           x <- essai504(engine_valider_declarations("premium", 1, "II", "nettes", "2027-02-30",
                                                     reassurance_np = NA, cdd_qualifiante = "oui"))
           !inherits(x, "error") && identical(x$ok, FALSE) && length(x$erreurs) == 3L &&
             identical(x$date_reference, NA_character_) && identical(x$texte_applicable, NA_character_) &&
             identical(x$reassurance_np, NA) && identical(x$cdd_qualifiante, NA)
         })

## --- usp_parametre_standard() : delegation, refus, meme double -------------
verifier("#504 usp_parametre_standard() : seize segments, trois methodes, brutes et nettes : sans date, erreur ; avec DATE_REFERENCE_TESTS, sigma standard identical a la valeur de la table (NP standard x sigma brut sur donnees nettes) ; champs de la regle rendus",
         {
           ok <- TRUE
           for (a in c("II", "XIV")) for (s in seq_len(if (a == "II") 12L else 4L))
             for (m in methodes504) for (n in if (m == "premium") c("brutes", "nettes") else list(NULL)) {
               inf <- usp_segment_infos(s, a)
               attendu <- if (m != "premium") inf$sigma_reserve else
                 if (identical(n, "nettes")) inf$np_standard * inf$sigma_prime_brut else
                   inf$sigma_prime_brut
               p1 <- usp_parametre_standard(m, s, a, n, date_reference = DATE_REFERENCE_TESTS)
               ok <- ok && leve_erreur(usp_parametre_standard(m, s, a, n)) &&
                 identical(p1$sigma_standard, attendu) &&
                 identical(p1$sigma_reglementaire, attendu) &&
                 identical(p1$texte_applicable, "2019/981") &&
                 identical(p1$date_reference, DATE_REFERENCE_TESTS)
             }
           ok
         })
verifier("#504 usp_parametre_standard() appelee directement sans date : erreur nommant date_reference, sigma standard saisi compris (trois methodes)",
         all(vapply(methodes504, function(m) {
           n <- if (m == "premium") "brutes" else NULL
           e1 <- essai504(usp_parametre_standard(m, 1, "II", n))
           e2 <- essai504(usp_parametre_standard(m, NULL, "II", n, sigma_standard = 0.1))
           inherits(e1, "error") && grepl("date_reference absente", conditionMessage(e1), fixed = TRUE) &&
             inherits(e2, "error") && grepl("date_reference absente", conditionMessage(e2), fixed = TRUE)
         }, logical(1))))
verifier("#504 usp_parametre_standard() appelee directement : date ou declaration refusee -> erreur (stop), comme la nature des donnees",
         leve_erreur(usp_parametre_standard("premium", 1, "II", "brutes", date_reference = "2027-1-30")) &&
           leve_erreur(usp_parametre_standard("premium", 1, "II", "brutes", date_reference = "2019-12-31")) &&
           leve_erreur(usp_parametre_standard("reserve1", 1, "II", date_reference = as.Date("2026-12-31"))) &&
           leve_erreur(usp_parametre_standard("reserve2", 1, "II", date_reference = DATE_REFERENCE_TESTS,
                                              reassurance_np = "oui")) &&
           !leve_erreur(usp_parametre_standard("reserve2", 1, "II", date_reference = "2027-01-29",
                                               cdd_qualifiante = TRUE)))

## --- Independance de la locale et de l'horloge -----------------------------
# Locale francaise essayee si elle existe sur la machine (absente du conteneur
# de developpement : seul le cas C y est alors execute).
verifier("#504 : meme resultat d'engine_valider_declarations() (toutes les dates essayees) et de run_engine() sous LC_ALL = C et sous une locale francaise si elle existe",
         {
           tous <- c(dates_refusees, list("2020-01-01", "2027-01-29", DATE_REFERENCE_TESTS, NULL))
           lire <- function() list(
             lapply(tous, function(x) engine_valider_declarations("premium", 1, "II", "nettes", x)),
             sans504(appel504("reserve1", date_reference = "2027-01-29")))
           # Restauration categorie par categorie : la chaine composite de
           # Sys.getlocale("LC_ALL") n'est pas toujours acceptee en retour
           # (mesure sous C.UTF-8 : "cannot be honored").
           cats <- c("LC_COLLATE", "LC_CTYPE", "LC_MONETARY", "LC_TIME")
           avant <- vapply(cats, Sys.getlocale, character(1))
           restaurer <- function() for (k in cats) invisible(Sys.setlocale(k, avant[[k]]))
           ref <- lire()
           ok <- TRUE
           for (loc in c("C", "fr_FR.UTF-8", "fr_FR.utf8", "French_France.utf8")) {
             if (!nzchar(suppressWarnings(Sys.setlocale("LC_ALL", loc)))) { restaurer(); next }
             ok <- ok && tryCatch(identical(lire(), ref), finally = restaurer())
           }
           ok && identical(vapply(cats, Sys.getlocale, character(1)), avant)
         })
verifier("#504 : ni Sys.Date ni Sys.time dans all.names() d'engine_valider_declarations() et d'usp_parametre_standard() (D-S3-5)",
         !any(c("Sys.Date", "Sys.time") %in%
                c(all.names(body(engine_valider_declarations)), all.names(body(usp_parametre_standard)))))

## --- Trace : objet sans les champs ou altere refuse ------------------------
verifier("#504 : objet sans l'un des quatre champs, ou a champ de forme invalide, ou a date NA (commit (b3)), ou a texte_applicable altere : erreur d'engine_parametre_standard() et d'engine_derogations()",
         {
           base <- r_avec[[1]]
           alteres <- c(
             lapply(c("date_reference", "texte_applicable", "reassurance_np", "cdd_qualifiante"),
                    function(ch) { r <- base; r$metadata[[ch]] <- NULL; r }),
             list(local({ r <- base; r$metadata$texte_applicable <- "2026/269"; r }),
                  local({ r <- base; r$metadata$texte_applicable <- NA_character_; r }),
                  local({ r <- base; r$metadata$date_reference <- "2027-01-30"; r }),
                  local({ r <- base; r$metadata$date_reference <- NA_character_; r }),
                  local({ r <- base; r$metadata$date_reference <- as.Date("2026-12-31"); r }),
                  local({ r <- base; r$metadata$reassurance_np <- "oui"; r }),
                  local({ r <- base; r$metadata$cdd_qualifiante <- 0; r })))
           !leve_erreur(engine_parametre_standard(base)) && !leve_erreur(engine_derogations(base)) &&
             all(vapply(alteres, function(r) leve_erreur(engine_parametre_standard(r)) &&
                          leve_erreur(engine_derogations(r)), logical(1))) &&
             all(vapply(r_avec[2:3], function(o) {
               r <- o; r$metadata$texte_applicable <- "2026/269"
               leve_erreur(engine_parametre_standard(r)) && leve_erreur(engine_derogations(r))
             }, logical(1)))
         })
verifier("#504 engine_parametre_standard() : lignes de la date, du texte et des declarations apres les trois premieres, trois dernieres inchangees ; facteur NP applique (primes) ; resultat refuse sans date : NULL, objet a date NA : erreur",
         {
           d <- engine_parametre_standard(r_decl[[1]])
           t <- stats::setNames(d$texte, d$grandeur); v <- stats::setNames(d$valeur, d$grandeur)
           d1 <- engine_parametre_standard(r_avec[[2]])
           na_date <- r_avec[[2]]; na_date$metadata$date_reference <- NA_character_
           e_na <- essai504(engine_parametre_standard(na_date))
           identical(d$grandeur[1:3], c("Nature declaree des donnees", "Parametre standard remplace",
                                        "Exigence relative aux donnees")) &&
             identical(d$grandeur[4:7], c("Date de reference du calcul",
                                          "Texte applicable au parametre standard",
                                          "Reassurance non proportionnelle en place (declaration)",
                                          "Couverture pour developpements defavorables qualifiante (declaration)")) &&
             identical(tail(d$grandeur, 3), c("Bareme et facteur c applicables (annexe XVII, section G)",
                                              "Bareme et facteur c retenus", "Origine du bareme retenu")) &&
             identical(t[["Date de reference du calcul"]], DATE_REFERENCE_TESTS) &&
             grepl("^2019/981 : ", t[["Texte applicable au parametre standard"]]) &&
             grepl("^declaree presente ; sans effet", t[["Reassurance non proportionnelle en place (declaration)"]]) &&
             grepl("^declaree absente ; sans effet pour cette methode",
                   t[["Couverture pour developpements defavorables qualifiante (declaration)"]]) &&
             identical(v[["Facteur NP applique a sigma brut"]], 0.8) &&
             identical(d1$texte[d1$grandeur == "Date de reference du calcul"], DATE_REFERENCE_TESTS) &&
             grepl("^2019/981 : ", d1$texte[d1$grandeur == "Texte applicable au parametre standard"]) &&
             !"Facteur NP applique a sigma brut" %in% d1$grandeur &&
             is.null(engine_parametre_standard(r_sans[[2]])) &&
             inherits(e_na, "error") &&
             grepl("metadata$date_reference absent ou invalide", conditionMessage(e_na), fixed = TRUE)
         })

## --- Reproductibilite : deux executions identical() ------------------------
verifier("#504 : deux executions a date de reference identique sont identical() (hors champs d'execution), trois methodes",
         all(vapply(seq_along(methodes504), function(i) {
           r2 <- appel504(methodes504[i], date_reference = DATE_REFERENCE_TESTS)
           identical(sans504(r2), sans504(r_avec[[i]]))
         }, logical(1))))

fin_fichier()
