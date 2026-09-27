###############################################################################
#  tests/taux_franchissement_reperes.R  --  TAUX DE FRANCHISSEMENT DES REPERES
#  DES DIAGNOSTICS SOUS LE MODELE AJUSTE (issue #72)
#
#  OUTIL DE MESURE HORS CI : ce script n'est ni une batterie de tests ni un
#  generateur de references. Il n'est lance ni par la CI, ni par
#  test_unitaires.R (nom sans prefixe test_), ni par test_reproductibilite.R.
#  Il n'ecrit aucun fichier : sortie en markdown sur la console (UTF-8).
#  R base + stats.
#
#  Objet : la decision M7 (#24) s'appuyait sur 60 replications (+/- 6 points)
#  pour dire que quatre reperes des diagnostics (Cook 4/T, IC 50 %, jackknife
#  10 %, R2 0,5) sont franchis par le modele vrai dans 50 a 80 % des cas a
#  T = 8. Ce script mesure, sur R replications (defaut 2 000) simulees sous le
#  modele AJUSTE au jeu (usp_simuler(), le generateur du bootstrap
#  parametrique), la frequence de franchissement de chaque repere, avec son
#  intervalle de Clopper-Pearson a 95 % (incertitude Monte-Carlo sur le taux,
#  fonction de R ; elle ne dit rien de l'erreur d'approximation en T).
#
#  Chaque replication est traitee comme run_engine() traite un jeu observe
#  (methode prime, segment 1 de l'annexe II, donnees brutes, alpha = 0,10) :
#    usp_ajuster() (54 demarrages), usp_parametre(), usp_jackknife() et
#    l'ecart relatif max sur sigma_USP, l'IC bootstrap 90 % de sigma_USP et
#    sa largeur relative, puis usp_tests() avec robustesse : les reperes sont
#    lus sur les lignes de la table produite par le moteur ACTUEL (lignes
#    Cook, leviers, R2, jackknife, IC ; pente et Fisher restitues en
#    diagnostic quand la pente n'est pas identifiable, regle R4 de #44 ;
#    lignes non applicables, #59 ; tests inoperants restitues INFO, regle R1
#    de #44).
#  Deux ecarts a run_engine(), controles sur le jeu observe (controle
#  d'integrite ci-dessous) :
#    - l'IC bootstrap de chaque replication est reconstruit par la boucle de
#      usp_bootstrap() reduite a ce dont l'IC depend (usp_simuler() et
#      usp_ajuster_rapide() sous engine_sous_graine(), sans les statistiques
#      du catalogue, ~30 fois plus couteuses) : sigma_boot n'en differe que
#      si les statistiques d'une replication interne echouent alors que le
#      reajustement aboutit ;
#    - usp_tests() recoit les statistiques observees du catalogue et des
#      p-values Monte-Carlo fictives (0,5) : type, estimation, statistique
#      et inoperance (p_min, lois discretes) n'en dependent pas ; les
#      verdicts des lignes "test" en dependent et ne sont pas exploites.
#
#  Alea : tout tirage passe par engine_sous_graine() avec une graine
#  explicite. Les R jeux simules sont tires d'un seul flux (graine --graine),
#  avant tout calcul ; l'IC de la replication b utilise la graine
#  --graine-ic + b (graines distinctes : pas de bruit Monte-Carlo commun aux
#  replications). Le resultat ne depend donc pas du decoupage en tranches.
#
#  Usage (depuis la racine du depot) :
#      Rscript tests/taux_franchissement_reperes.R [--R 2000]
#          [--graine 20260927] [--graine-ic 20260831] [--B-ic 999]
#          [--jeu J1|J2] [--tranche i/K]
#      Rscript tests/taux_franchissement_reperes.R --combiner f1 f2 ...
#  --tranche i/K : ne traite que la i-eme de K tranches de replications
#  consecutives et imprime, en plus des tableaux partiels, ses comptes bruts
#  (lignes "COMPTE") ; rediriger la sortie de chaque tranche vers un fichier
#  HORS du depot, puis --combiner additionne les comptes des K fichiers (memes
#  parametres, tranches disjointes couvrant 1..R, sinon erreur) et imprime
#  les tableaux complets, identiques a ceux d'une execution d'un seul tenant.
#  Duree mesuree (poste du mainteneur, R 4.3.1, 27/09/2026) : 0,6 a 0,7 s par
#  replication a --B-ic 999 ; 2 000 replications en 8 tranches : 1 312 s.
#  Code de sortie : 0 si les controles d'integrite tiennent, 1 sinon.
#  La lecture des taux (rubrique 6 des fiches, statut de constat de
#  simulation) revient a actuary et a docwriter.
###############################################################################

t_debut <- Sys.time()

# --- Options ------------------------------------------------------------------
ARGS <- commandArgs(trailingOnly = TRUE)
lire_option <- function(nom, defaut) {
  i <- match(nom, ARGS)
  if (is.na(i)) return(defaut)
  if (i == length(ARGS)) stop("option ", nom, " sans valeur")
  ARGS[i + 1L]
}
OPT_R         <- as.integer(lire_option("--R", "2000"))
OPT_GRAINE    <- as.numeric(lire_option("--graine", "20260927"))
OPT_GRAINE_IC <- as.numeric(lire_option("--graine-ic", "20260831"))
OPT_B_IC      <- as.integer(lire_option("--B-ic", "999"))
OPT_JEU       <- lire_option("--jeu", "J1")
OPT_TRANCHE   <- lire_option("--tranche", NA_character_)
i_comb <- match("--combiner", ARGS)
FICHIERS_COMB <- if (is.na(i_comb)) character(0) else ARGS[-seq_len(i_comb)]
if (!is.na(i_comb) && !length(FICHIERS_COMB)) stop("--combiner : aucun fichier")
if (!OPT_JEU %in% c("J1", "J2")) stop("--jeu : J1 ou J2")
if (!is.finite(OPT_R) || OPT_R < 1L) stop("--R : entier >= 1")
if (!is.finite(OPT_B_IC) || OPT_B_IC < 21L) stop("--B-ic : entier >= 21 (IC calcule si plus de 20 replications)")

# Configuration de run_engine() reproduite (cas de reference "premium").
METHODE <- "premium"; SEGMENT <- 1; ANNEXE <- "II"; NATURE <- "brutes"
ALPHA <- 0.10; THETA_EQUIV <- 0.10

# --- Chargement du moteur et des outils --------------------------------------
DOSSIER_SCRIPT <- local({
  f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  if (length(f) == 1L) dirname(f) else if (file.exists("tests/outils_tests.R")) "tests" else "."
})
source(file.path(DOSSIER_SCRIPT, "outils_tests.R"))

# Console en UTF-8 quelle que soit la locale (meme definition que
# tests/comparer_ajusteurs_bootstrap.R).
ecrire_console <- function(x) writeLines(enc2utf8(x), useBytes = TRUE)

# --- Mise en forme -------------------------------------------------------------
ligne_md <- function(...) paste0("| ", paste(..., sep = " | "), " |")
entete_md <- function(cols) c(ligne_md(paste(cols, collapse = " | ")),
                              ligne_md(paste(rep("---", length(cols)), collapse = " | ")))
pct <- function(k, n) if (n > 0) sprintf("%.1f %%", 100 * k / n) else "NA"
ic_cp <- function(k, n) if (n > 0) {
  ci <- stats::binom.test(k, n)$conf.int
  sprintf("[%.1f %% ; %.1f %%]", 100 * ci[1], 100 * ci[2])
} else "NA"

# --- Reperes ---------------------------------------------------------------------
# cle : identifiant des comptes ; ligne : nom exact de la ligne de usp_tests()
# lue ; seuil et source : affiches. Les seuils 4/T et 2k/T (k = 1) sont ceux
# que usp_tests() imprime ; 10 % est REPERE_INFLUENCE_SIGMA du moteur ; 20 %,
# 50 % et 80 % sont les reperes conventionnels des fiches (commentaire de
# usp_tests(), famille G) ; 1/2 est SEUIL_PUISSANCE_PENTE (regle R4, #44).
LIGNE_COOK  <- "Points influents (distance de Cook)"
LIGNE_LEV   <- "Leviers (hat values)"
LIGNE_R2    <- "Coefficient de determination R2"
LIGNE_PENTE <- "Test de Student sur la pente (lm(y~x))"
LIGNE_FISH  <- "Test de Fisher (significativite globale)"
LIGNE_JACK  <- "Sensibilite au retrait d'une annee (jackknife)"
LIGNE_IC    <- "Largeur relative de l'IC bootstrap 90%"
REPERES <- list(
  list(cle = "cook", libelle = "Distance de Cook : au moins une observation au-dessus",
       seuil = "4/T", source = "usp_tests() (d\u00e9tail de la ligne)"),
  list(cle = "leviers", libelle = "Leviers : au moins une observation au-dessus",
       seuil = "2k/T, k = 1", source = "usp_tests() (d\u00e9tail de la ligne)"),
  list(cle = "r2", libelle = "R\u00b2 de lm(y ~ x) en dessous", seuil = "0,5",
       source = "usp_tests() (d\u00e9tail de la ligne)"),
  list(cle = "pente", libelle = "Pente non identifiable : Student pente et Fisher restitu\u00e9s en diagnostic",
       seuil = "puissance approch\u00e9e < 1/2", source = "SEUIL_PUISSANCE_PENTE (r\u00e8gle R4, #44)"),
  list(cle = "jack10", libelle = "Jackknife : \u00e9cart relatif max sur \u03c3_USP au-dessus", seuil = "10 %",
       source = "REPERE_INFLUENCE_SIGMA ; fiche du jackknife"),
  list(cle = "jack20", libelle = "Jackknife : \u00e9cart relatif max sur \u03c3_USP au-dessus", seuil = "20 %",
       source = "fiche du jackknife"),
  list(cle = "ic50", libelle = "IC bootstrap 90 % : largeur relative au-dessus", seuil = "50 %",
       source = "fiche de l'IC bootstrap"),
  list(cle = "ic80", libelle = "IC bootstrap 90 % : largeur relative au-dessus", seuil = "80 %",
       source = "fiche de l'IC bootstrap"),
  list(cle = "bord", libelle = "Position de \u03b4\u0302 : solution au bord (0 ou 1)",
       seuil = "TOL_DELTA_BORD", source = "usp_regime()"),
  list(cle = "bord1", libelle = "dont \u03b4\u0302 au bord 1 (\u03c0\u0302 constant)",
       seuil = "\u03b4\u0302 \u2265 1 \u2212 TOL_DELTA_BORD", source = "usp_regime()")
)

# --- Mode --combiner ---------------------------------------------------------------
lire_comptes <- function(f) {
  l <- readLines(f, warn = FALSE, encoding = "UTF-8")
  par <- sub("^PARAMETRES\t", "", grep("^PARAMETRES\t", l, value = TRUE))
  tr <- strsplit(sub("^TRANCHE\t", "", grep("^TRANCHE\t", l, value = TRUE)), "\t")
  cp <- strsplit(sub("^COMPTE\t", "", grep("^COMPTE\t", l, value = TRUE)), "\t")
  if (length(par) != 1L || length(tr) != 1L || !length(cp))
    stop("--combiner : ", f, " n'est pas une sortie de tranche complete (PARAMETRES, TRANCHE, COMPTE)")
  list(parametres = par, debut = as.integer(tr[[1]][1]), fin = as.integer(tr[[1]][2]),
       comptes = stats::setNames(as.numeric(vapply(cp, `[`, "", 2L)), vapply(cp, `[`, "", 1L)))
}

# --- Tableaux a partir des comptes -------------------------------------------------
# cpt : vecteur nomme de comptes ("k|cle", "n|cle", "type|ligne|type",
# "inop|ligne", "nl|ligne").
tableaux <- function(cpt, R) {
  g <- function(n) if (n %in% names(cpt)) cpt[[n]] else 0
  L <- c("### T1 -- taux de franchissement des rep\u00e8res (constat de simulation sous le mod\u00e8le ajust\u00e9)", "",
         entete_md(c("Rep\u00e8re", "Seuil", "Source du seuil", "Franchi", "n", "Taux", "IC 95 % (Clopper-Pearson)")))
  for (r in REPERES) {
    k <- g(paste0("k|", r$cle)); n <- g(paste0("n|", r$cle))
    L <- c(L, ligne_md(r$libelle, r$seuil, r$source, k, n, pct(k, n), ic_cp(k, n)))
  }
  L <- c(L, "", sprintf(paste("n : r\u00e9plications o\u00f9 la ligne du rep\u00e8re existe et porte une valeur finie",
                              "(sur %d). IC : incertitude Monte-Carlo sur le taux (fonction de R), pas",
                              "l'erreur d'approximation en T."), R), "")
  lignes <- unique(sub("^nl\\|", "", grep("^nl\\|", names(cpt), value = TRUE)))
  types <- c("test", "diagnostic", "non applicable", "procedure de decision")
  L <- c(L, "### T2 -- classement des lignes de usp_tests() sur les r\u00e9plications (lignes non restitu\u00e9es \"test\" au moins une fois)", "",
         entete_md(c("Ligne", "n", "test", "diagnostic", "dont inop\u00e9rant (INFO)", "non applicable",
                     "proc\u00e9dure de d\u00e9cision")))
  for (li in lignes) {
    n <- g(paste0("nl|", li)); kt <- vapply(types, function(ty) g(paste0("type|", li, "|", ty)), numeric(1))
    ki <- g(paste0("inop|", li))
    if (kt[["test"]] == n && ki == 0) next
    L <- c(L, ligne_md(li, n, pct(kt[["test"]], n), pct(kt[["diagnostic"]], n), pct(ki, n),
                       pct(kt[["non applicable"]], n), pct(kt[["procedure de decision"]], n)))
  }
  c(L, "", "Inop\u00e9rant : ligne de type test dont p_min \u2265 \u03b1, restitu\u00e9e diagnostic INFO (r\u00e8gle R1, #44) ; compt\u00e9e aussi dans la colonne diagnostic.", "")
}

if (length(FICHIERS_COMB)) {
  parts <- lapply(FICHIERS_COMB, lire_comptes)
  par <- unique(vapply(parts, `[[`, "", "parametres"))
  if (length(par) != 1L) stop("--combiner : parametres differents entre les fichiers")
  R_tot <- as.integer(sub("^.*;R=([0-9]+);.*$", "\\1", par))
  idx <- unlist(lapply(parts, function(p) seq.int(p$debut, p$fin)))
  if (anyDuplicated(idx) || !setequal(idx, seq_len(R_tot)))
    stop("--combiner : les tranches ne couvrent pas 1..", R_tot, " exactement une fois")
  cles <- unique(unlist(lapply(parts, function(p) names(p$comptes))))
  cpt <- stats::setNames(vapply(cles, function(k) sum(vapply(parts, function(p)
    if (k %in% names(p$comptes)) p$comptes[[k]] else 0, numeric(1))), numeric(1)), cles)
  ecrire_console(c(sprintf("## Taux de franchissement des rep\u00e8res -- combinaison de %d tranche(s)", length(parts)), "",
                   sprintf("Param\u00e8tres : %s", par), ""))
  ecrire_console(tableaux(cpt, R_tot))
  quit(status = 0L)
}

# --- Jeu et modele ajuste ----------------------------------------------------------
lire_j2 <- function() {
  f <- file.path(RACINE, "tests", "unitaires", "test_controles_numeriques.R")
  l <- readLines(f)
  env <- new.env()
  for (v in c("xi", "yi")) {
    li <- grep(sprintf("^%s <- c\\(", v), l, value = TRUE)
    if (length(li) != 1L) stop("J2 : ligne '", v, " <- c(' introuvable ou multiple dans ", f)
    eval(parse(text = li), envir = env)
  }
  list(x = env$xi, y = env$yi)
}
JEU <- if (OPT_JEU == "J1")
  list(x = .ln$xt, y = .ln$yt, libelle = "J1 : tests/donnees/donnees_ln.csv (jeu des cas de r\u00e9f\u00e9rence)") else
  c(lire_j2(), libelle = "J2 : xi, yi de tests/unitaires/test_controles_numeriques.R (\u03b4 estim\u00e9 int\u00e9rieur)")
X <- JEU$x; T_ <- length(X)
FIT0 <- usp_ajuster(X, JEU$y)
SIGMA_STD <- usp_parametre_standard(METHODE, SEGMENT, ANNEXE, NATURE, NULL)$sigma_standard
BAREME <- usp_bareme_segment(SEGMENT, ANNEXE)

# Tranche
if (is.na(OPT_TRANCHE)) { DEBUT <- 1L; FIN <- OPT_R } else {
  m <- regmatches(OPT_TRANCHE, regexec("^([0-9]+)/([0-9]+)$", OPT_TRANCHE))[[1]]
  if (length(m) != 3L) stop("--tranche : forme i/K attendue")
  i <- as.integer(m[2]); K <- as.integer(m[3])
  if (K < 1L || i < 1L || i > K || K > OPT_R) stop("--tranche : 1 <= i <= K <= R")
  DEBUT <- as.integer(floor((i - 1) * OPT_R / K)) + 1L; FIN <- as.integer(floor(i * OPT_R / K))
}

# Les R jeux simules, d'un seul flux, avant tout calcul (independants du
# decoupage en tranches).
YSIM <- engine_sous_graine(OPT_GRAINE, t(vapply(seq_len(OPT_R), function(b) usp_simuler(FIT0), numeric(T_))))

# --- Traitement d'une replication ------------------------------------------------------
# Largeur relative de l'IC bootstrap 90 % de sigma_USP : boucle de
# usp_bootstrap() (usp_simuler() puis usp_ajuster_rapide() depuis l'optimum,
# replication ecartee si le reajustement echoue), sans les statistiques du
# catalogue ; IC et largeur comme run_engine(). Rend aussi sigma_boot (controle
# d'integrite).
ic_bootstrap <- function(fit, param, graine, B) {
  sig <- engine_sous_graine(graine, {
    s <- rep(NA_real_, B)
    for (k in seq_len(B)) {
      yk <- usp_simuler(fit)
      f <- try(usp_ajuster_rapide(fit$x, yk, fit$delta, fit$gamma), silent = TRUE)
      if (inherits(f, "try-error")) next
      s[k] <- f$sigma
    }
    s
  })
  sig <- sig[is.finite(sig)]
  usp_b <- param$credibilite * sig * param$correction_taille + (1 - param$credibilite) * param$sigma_standard
  ic <- if (length(usp_b) > 20) stats::quantile(usp_b, c(.025, .05, .5, .95, .975)) else NULL
  list(sigma_boot = sig, largeur = if (!is.null(ic)) unname((ic[4] - ic[2]) / param$sigma_usp) else NULL)
}

# Table des tests d'un jeu (x, y) traitee comme par run_engine().
traiter <- function(x, y, graine_ic) {
  fb <- usp_ajuster(x, y)
  param <- usp_parametre(fb, SIGMA_STD, BAREME)
  jack <- usp_jackknife(fb, SIGMA_STD, BAREME)
  d_jack <- jack$sigma_usp - param$sigma_usp
  jack_calcule <- any(is.finite(d_jack))
  fb$ecart_jackknife <- if (jack_calcule) max(abs(d_jack), na.rm = TRUE) / param$sigma_usp else NULL
  icb <- ic_bootstrap(fb, param, graine_ic, OPT_B_IC)
  fb$largeur_ic <- icb$largeur
  i_jack <- if (jack_calcule) which.max(abs(d_jack)) else NULL
  rob <- list(jack_annee = i_jack, jack_usp = if (jack_calcule) d_jack[i_jack] / param$sigma_usp else NULL)
  so <- .mc_evaluer(USP_CATALOGUE_MC, .usp_contexte_mc(fb$x, fb$y, fb$z))
  boot <- list(stats_obs = as.list(so), p_mc = so * 0 + 0.5, err_mc = so * 0 + 0.01,
               motif_mc = stats::setNames(rep(NA_character_, length(so)), names(so)))
  tt <- usp_tests(fb, boot, ALPHA, theta_equiv = THETA_EQUIV, delta_equiv = NULL,
                  robustesse = rob, methode = METHODE)
  list(fit = fb, tests = tt, sigma_boot = icb$sigma_boot, regime = usp_regime(fb$delta, fb$x))
}

# Comptes d'une replication, ajoutes a cpt.
compter <- function(cpt, r) {
  ajoute <- function(cle, v) { cpt[cle] <<- (if (cle %in% names(cpt)) cpt[[cle]] else 0) + v }
  noms <- vapply(r$tests, `[[`, "", "test")
  ligne <- function(nm) { i <- match(nm, noms); if (is.na(i)) NULL else r$tests[[i]] }
  lu <- function(nm) { l <- ligne(nm); if (is.null(l) || !is.finite(l$estim)) NA_real_ else l$estim }
  repere <- function(cle, franchi) if (!is.na(franchi)) { ajoute(paste0("n|", cle), 1); ajoute(paste0("k|", cle), franchi) }
  for (nm in c(LIGNE_COOK, LIGNE_LEV, LIGNE_R2, LIGNE_PENTE, LIGNE_FISH))
    if (is.null(ligne(nm))) stop("ligne \"", nm, "\" absente de usp_tests() : script a mettre a jour")
  repere("cook", lu(LIGNE_COOK) > 4 / T_)
  repere("leviers", lu(LIGNE_LEV) > 2 / T_)
  r2 <- ligne(LIGNE_R2)
  repere("r2", if (identical(r2$type, "diagnostic") && is.finite(r2$estim)) r2$estim < 0.5 else NA)
  tp <- ligne(LIGNE_PENTE)$type
  repere("pente", if (tp %in% c("test", "diagnostic")) tp == "diagnostic" else NA)
  j <- lu(LIGNE_JACK); repere("jack10", j > REPERE_INFLUENCE_SIGMA); repere("jack20", j > 0.20)
  w <- lu(LIGNE_IC); repere("ic50", w > 0.50); repere("ic80", w > 0.80)
  repere("bord", r$regime$delta_au_bord)
  repere("bord1", r$fit$delta >= 1 - TOL_DELTA_BORD)
  for (l in r$tests) {
    ajoute(paste0("nl|", l$test), 1)
    ajoute(paste0("type|", l$test, "|", l$type), 1)
    if (!is.null(l$detail) && startsWith(l$detail, "TEST INOPERANT")) ajoute(paste0("inop|", l$test), 1)
  }
  cpt
}

# --- Controle d'integrite sur le jeu observe -------------------------------------------
# run_engine() a B = --B-ic, graine --graine-ic, et traiter() a la meme graine
# doivent donner : le meme sigma_boot (identical) ; les memes lignes, types,
# statistiques et estimations (identical).
integrite <- character(0)
t0 <- Sys.time()
res <- run_engine(xt = X, yt = JEU$y, methode = METHODE, segment = SEGMENT, annexe = ANNEXE,
                  nature_donnees = NATURE, B = OPT_B_IC, alpha = ALPHA, theta_equiv = THETA_EQUIV,
                  seed = OPT_GRAINE_IC)
obs <- traiter(X, JEU$y, OPT_GRAINE_IC)
if (!isTRUE(res$ok)) integrite <- c(integrite, "run_engine() sur le jeu observe : ok = FALSE")
if (!identical(obs$sigma_boot, res$bootstrap$sigma_boot))
  integrite <- c(integrite, "sigma_boot reconstruit different de res$bootstrap$sigma_boot")
champs <- c("test", "type", "stat", "estim")
if (length(obs$tests) != length(res$tests) ||
    !identical(lapply(obs$tests, `[`, champs), lapply(res$tests, `[`, champs)))
  integrite <- c(integrite, "usp_tests() reconstruit : lignes, types, statistiques ou estimations differents de res$tests")
t_controle <- as.numeric(difftime(Sys.time(), t0, units = "secs"))

# --- Replications ----------------------------------------------------------------------
t0 <- Sys.time()
cpt <- numeric(0)
for (b in seq.int(DEBUT, FIN))
  cpt <- compter(cpt, traiter(X, YSIM[b, ], OPT_GRAINE_IC + b))
t_rep <- as.numeric(difftime(Sys.time(), t0, units = "secs"))

# --- Sortie ------------------------------------------------------------------------------
PAR <- sprintf("jeu=%s;R=%d;graine=%.0f;graine_ic=%.0f;B_ic=%d;methode=%s;segment=%d;annexe=%s;nature=%s;alpha=%g",
               OPT_JEU, OPT_R, OPT_GRAINE, OPT_GRAINE_IC, OPT_B_IC, METHODE, SEGMENT, ANNEXE, NATURE, ALPHA)
L0 <- c("## Taux de franchissement des rep\u00e8res des diagnostics sous le mod\u00e8le ajust\u00e9 (issue #72)", "",
        "### T0 -- contexte", "",
        entete_md(c("Grandeur", "Valeur")),
        ligne_md("Jeu", JEU$libelle),
        ligne_md("Mod\u00e8le ajust\u00e9 (usp_ajuster())",
                 sprintf("\u03b4\u0302 = %.6g ; \u03b3\u0302 = %.6g ; \u03b2\u0302 = %.6g ; \u03c3\u0302 = %.6g ; \u03c0\u0302 constant : %s",
                         FIT0$delta, FIT0$gamma, FIT0$beta, FIT0$sigma, usp_regime(FIT0$delta, X)$pi_constant)),
        ligne_md("Configuration", sprintf("m\u00e9thode %s, segment %d de l'annexe %s, donn\u00e9es %s, \u03b1 = %g, \u03c3 standard = %g, bar\u00e8me %s",
                                          METHODE, SEGMENT, ANNEXE, NATURE, ALPHA, SIGMA_STD, BAREME)),
        ligne_md("\u03c3_USP observ\u00e9 (run_engine())", sprintf("%.6g", res$parametre_final$sigma_usp)),
        ligne_md("R\u00e9plications", sprintf("%d (trait\u00e9es : %d \u00e0 %d)", OPT_R, DEBUT, FIN)),
        ligne_md("Graines", sprintf("jeux simul\u00e9s %.0f ; IC de la r\u00e9plication b : %.0f + b", OPT_GRAINE, OPT_GRAINE_IC)),
        ligne_md("B de l'IC bootstrap", OPT_B_IC),
        ligne_md("G\u00e9n\u00e9rateur", paste(ENGINE_RNG_KIND, collapse = ", ")),
        ligne_md("Dur\u00e9e (s)", sprintf("contr\u00f4le %.1f ; r\u00e9plications %.1f ; total %.1f", t_controle, t_rep,
                                          as.numeric(difftime(Sys.time(), t_debut, units = "secs")))),
        ligne_md("Contr\u00f4le d'int\u00e9grit\u00e9", if (length(integrite)) "\u00c9CHEC" else "OK"), "")
ecrire_console(L0)
if (!is.na(OPT_TRANCHE))
  ecrire_console(c("Tableaux PARTIELS (une tranche) : combiner les sorties des K tranches par --combiner.", ""))
ecrire_console(tableaux(cpt, FIN - DEBUT + 1L))
if (length(integrite)) ecrire_console(c("Contr\u00f4le d'int\u00e9grit\u00e9 : \u00c9CHEC", paste("-", integrite), ""))
if (!is.na(OPT_TRANCHE))
  ecrire_console(c(paste0("PARAMETRES\t", PAR), sprintf("TRANCHE\t%d\t%d", DEBUT, FIN),
                   sprintf("COMPTE\t%s\t%.0f", names(cpt), cpt)))
quit(status = if (length(integrite)) 1L else 0L)
