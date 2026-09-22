###############################################################################
#  R/engine.R  --  MOTEUR DE CALCUL QUANTITATIF
#
#  Paramètres propres à l'entreprise (USP) - Solvabilité II
#  Règlement délégué (UE) 2015/35, articles 218-220 et annexe XVII
#  Méthodes "risque de prime" (section B) et "risque de réserve 1" (section C).
#
#  ARCHITECTURE
#  Ce fichier contient l'INTEGRALITE de la logique quantitative du projet :
#  preparation des donnees, controles de validite, estimation, statistiques de
#  test, p-values (exactes, asymptotiques, Monte-Carlo), bootstrap, jackknife,
#  profils de vraisemblance, calibration, parametre final, et les quantites
#  numeriques necessaires aux graphiques.
#
#  Il est utilisable SANS Shiny :
#      source("R/engine.R")
#      res <- run_engine(xt = ..., yt = ..., methode = "premium", segment = 1)
#  Aucune dependance a input$/output$/reactive()/render*() n'y figure.
#  Dependances : R base + stats uniquement.
#
#  La couche Shiny ne doit contenir aucun calcul statistique ou actuariel.
#
#  NOTE SUR LA TAILLE D'ECHANTILLON
#  La profondeur d'interet du projet est T = 8. A cette taille, les lois
#  asymptotiques sont peu fiables. Le moteur calcule donc, pour chaque test et
#  lorsque c'est possible :
#    - une p-value EXACTE (loi combinatoire ou de permutation),
#    - une p-value ASYMPTOTIQUE (loi limite classique),
#    - une p-value MONTE-CARLO par bootstrap parametrique sous le modele ajuste.
#  Le champ `nature_p` de chaque test indique laquelle est retenue.
###############################################################################


## =============================================================================
## 0. PARAMÈTRES STANDARD ET FACTEURS DE CRÉDIBILITÉ
## =============================================================================

# Écarts-types standard de l'annexe II (non-vie), règlement délégué (UE)
# 2015/35, JOUE L 12 du 17.1.2015, p. 230-231. Valeurs vérifiées ligne à ligne
# contre le texte publié.
ANNEXE_II <- data.frame(
  segment = 1:12,
  libelle = c(
    "RC automobile et reass. proportionnelle",
    "Autres assurances automobiles et reass. proportionnelle",
    "Maritime, aerien et transport et reass. proportionnelle",
    "Incendie et autres dommages aux biens et reass. proportionnelle",
    "RC generale et reass. proportionnelle",
    "Credit et cautionnement et reass. proportionnelle",
    "Protection juridique et reass. proportionnelle",
    "Assistance et reass. proportionnelle",
    "Pertes pecuniaires diverses et reass. proportionnelle",
    "Reass. non proportionnelle - accidents",
    "Reass. non proportionnelle - maritime, aerien, transport",
    "Reass. non proportionnelle - dommages aux biens"
  ),
  sigma_prime_brut = c(.10, .08, .15, .08, .14, .12, .07, .09, .13, .17, .17, .17),
  sigma_reserve    = c(.09, .08, .11, .10, .11, .19, .12, .20, .20, .20, .20, .20),
  stringsAsFactors = FALSE
)

# Écarts-types standard de l'annexe XIV (santé non-SLT), règlement délégué
# (UE) 2015/35, JOUE L 12 du 17.1.2015, p. 269. Valeurs vérifiées ligne à ligne
# contre le texte publié. La colonne `lob` rappelle les lignes d'activité de
# l'annexe I dont se compose chaque segment.
ANNEXE_XIV <- data.frame(
  segment = 1:4,
  libelle = c(
    "Frais medicaux et reass. proportionnelle",
    "Protection du revenu et reass. proportionnelle",
    "Indemnisation des travailleurs et reass. proportionnelle",
    "Reassurance sante non proportionnelle"
  ),
  lob = c("1 et 13", "2 et 14", "3 et 15", "25"),
  sigma_prime_brut = c(.050, .085, .080, .17),
  sigma_reserve    = c(.050, .140, .110, .20),
  stringsAsFactors = FALSE
)

# Catalogue unifié des segments, utilisé par l'interface et par
# usp_segment_infos(). L'annexe d'appartenance fait partie de la clé : les
# numéros de segment se recoupent entre les deux annexes.
SEGMENTS <- rbind(
  data.frame(annexe = "II", ANNEXE_II[, c("segment", "libelle")],
             sigma_prime_brut = ANNEXE_II$sigma_prime_brut,
             sigma_reserve = ANNEXE_II$sigma_reserve, stringsAsFactors = FALSE),
  data.frame(annexe = "XIV", ANNEXE_XIV[, c("segment", "libelle")],
             sigma_prime_brut = ANNEXE_XIV$sigma_prime_brut,
             sigma_reserve = ANNEXE_XIV$sigma_reserve, stringsAsFactors = FALSE)
)
SEGMENTS$cle <- paste0(SEGMENTS$annexe, "-", SEGMENTS$segment)

# Annexe XVII, section G - facteurs de crédibilité.
# Barème "long" : segments 1, 5 et 6 de l'annexe II.
CRED_LONG  <- c(`5` = .34, `6` = .43, `7` = .51, `8` = .59, `9` = .67,
                `10` = .74, `11` = .81, `12` = .87, `13` = .92, `14` = .96,
                `15` = 1.00)
# Barème "court" : autres segments de l'annexe II, segments de l'annexe XIV,
# et méthode risque de révision.
CRED_COURT <- c(`5` = .34, `6` = .51, `7` = .67, `8` = .81, `9` = .92,
                `10` = 1.00)

usp_credibilite <- function(T, bareme = c("court", "long")) {
  bareme <- match.arg(bareme)
  tab <- if (bareme == "long") CRED_LONG else CRED_COURT
  if (T < 5) stop("Annexe XVII : au moins 5 annees consecutives sont exigees (T = ", T, ").")
  Tc <- min(T, max(as.integer(names(tab))))
  unname(tab[as.character(Tc)])
}

# Annexe XVII, section G :
#   (1) bareme "long"  : segments 1, 5 et 6 de l'annexe II uniquement ;
#   (2) bareme "court" : segments 2 a 4 et 7 a 12 de l'annexe II, TOUS les
#       segments de l'annexe XIV (sante non-SLT), et la methode du risque de
#       revision.
# L'annexe d'appartenance est donc necessaire : le segment 1 de l'annexe XIV
# (frais medicaux) releve du bareme court, contrairement au segment 1 de
# l'annexe II (RC automobile).
usp_bareme_segment <- function(segment, annexe = "II") {
  if (is.null(segment) || is.na(segment)) return("court")
  if (identical(annexe, "XIV")) return("court")
  if (segment %in% c(1, 5, 6)) "long" else "court"
}

# Renvoie les caracteristiques reglementaires d'un segment : libelle, ecarts
# types standard et bareme de credibilite applicable.
usp_segment_infos <- function(segment, annexe = "II") {
  tab <- if (identical(annexe, "XIV")) ANNEXE_XIV else ANNEXE_II
  i <- match(segment, tab$segment)
  if (is.na(i)) stop(sprintf("Segment %s inconnu dans l'annexe %s.", segment, annexe))
  list(annexe = annexe, segment = segment, libelle = tab$libelle[i],
       sigma_prime_brut = tab$sigma_prime_brut[i],
       sigma_reserve = tab$sigma_reserve[i],
       bareme = usp_bareme_segment(segment, annexe))
}


## =============================================================================
## 1. LECTURE ET CONTRÔLES DE QUALITÉ DES DONNÉES (art. 19 et 219)
## =============================================================================

usp_lire_vecteur <- function(chemin, sep = ",", dec = ".") {
  if (!file.exists(chemin)) stop("Fichier introuvable : ", chemin)
  brut <- utils::read.csv(chemin, header = FALSE, sep = sep, dec = dec,
                          stringsAsFactors = FALSE)
  # Un CSV "vecteur" peut être en ligne ou en colonne, avec ou sans en-tête.
  v <- suppressWarnings(as.numeric(unlist(brut, use.names = FALSE)))
  if (all(is.na(v))) {                       # en-tête probable : on relit
    brut <- utils::read.csv(chemin, header = TRUE, sep = sep, dec = dec,
                            stringsAsFactors = FALSE)
    v <- suppressWarnings(as.numeric(unlist(brut, use.names = FALSE)))
  }
  v <- v[!is.na(v)]
  if (!length(v)) stop("Aucune valeur numerique exploitable dans ", chemin)
  v
}

usp_charger <- function(fichier_x, fichier_y, T = NULL, plus_recent_en_dernier = TRUE,
                        sep = ",", dec = ".") {
  x <- usp_lire_vecteur(fichier_x, sep, dec)
  y <- usp_lire_vecteur(fichier_y, sep, dec)
  if (length(x) != length(y))
    stop("x (", length(x), ") et y (", length(y), ") n'ont pas la meme longueur.")
  if (!plus_recent_en_dernier) { x <- rev(x); y <- rev(y) }
  n <- length(x)
  if (!is.null(T)) {
    if (T > n) stop("T = ", T, " > profondeur disponible (", n, ").")
    idx <- (n - T + 1):n                     # on garde les T annees les plus recentes
    x <- x[idx]; y <- y[idx]
  }
  list(x = x, y = y, T = length(x))
}

usp_controle_donnees <- function(x, y, alpha = 0.10) {
  T <- length(x)
  res <- list()
  add <- function(nom, ok, detail) res[[length(res) + 1]] <<-
    list(famille = "A. Qualite des donnees", test = nom,
         stat = NA_real_, p = NA_real_, verdict = if (ok) "OK" else "ECHEC",
         detail = detail)

  add("Profondeur minimale (annexe XVII, B/C(2)(b))", T >= 5,
      sprintf("T = %d annee(s) consecutive(s) ; minimum reglementaire = 5", T))
  add("Absence de valeurs manquantes", !any(is.na(c(x, y))),
      sprintf("%d NA detecte(s)", sum(is.na(c(x, y)))))
  add("Strict positivite de x_t", all(x > 0),
      sprintf("min(x) = %.6g", min(x)))
  add("Strict positivite de y_t (requise par la lognormale)", all(y > 0),
      sprintf("min(y) = %.6g", min(y)))
  add("Absence de doublons parfaits", !any(duplicated(data.frame(x, y))),
      sprintf("%d couple(s) (x,y) duplique(s)", sum(duplicated(data.frame(x, y)))))
  ratio <- y / x
  add("Plausibilite du ratio y/x", all(ratio > 0 & ratio < 5),
      sprintf("min = %.3f ; median = %.3f ; max = %.3f",
              min(ratio), stats::median(ratio), max(ratio)))
  amp <- max(x) / min(x)
  add("Amplitude du volume (stabilite du perimetre)", amp < 10,
      sprintf("max(x)/min(x) = %.2f ; une amplitude elevee signale une rupture de perimetre", amp))
  add("Credibilite pleine atteinte", T >= 10,
      sprintf("T = %d ; c = %.0f%% (bareme court) / %.0f%% (bareme long)",
              T, 100 * usp_credibilite(T, "court"), 100 * usp_credibilite(T, "long")))
  res
}


## =============================================================================
## 2. NOYAU DE CALCUL (annexe XVII, sections B et C, paragraphes 3 à 6)
## =============================================================================

# pi_t(delta, gamma) = 1 / ln( 1 + e^{2 gamma} * ( delta + (1-delta) * xbar / x_t ) )
usp_pi <- function(delta, gamma, x, xbar = mean(x)) {
  1 / log1p(exp(2 * gamma) * (delta + (1 - delta) * xbar / x))
}

# Toutes les quantités du modèle pour un couple (delta, gamma) donné.
usp_noyau <- function(delta, gamma, x, y, xbar = mean(x)) {
  T <- length(x)
  p <- usp_pi(delta, gamma, x, xbar)
  r <- log(y / x)
  # ln(beta) : annexe XVII, sect. B/C par. 4-5 (estimateur MV du niveau)
  ln_beta <- (T / 2 + sum(p * r)) / sum(p)
  v <- r + 1 / (2 * p) - ln_beta            # residus bruts (loi normale, var = 1/pi_t)
  list(
    pi      = p,
    ln_beta = ln_beta,
    beta    = exp(ln_beta),                 # ratio S/P moyen implicite
    v       = v,
    z       = v * sqrt(p),                  # residus standardises ~ N(0,1)
    sigma   = exp(gamma + ln_beta),         # fonction d'ecart-type sigma(delta, gamma)
    obj     = sum(p * v^2) - sum(log(p))    # -2 log-vraisemblance (a une constante pres)
  )
}

usp_objectif <- function(par, x, y, xbar) {
  d <- par[1]; g <- par[2]
  if (!is.finite(d) || !is.finite(g) || d < 0 || d > 1) return(1e12)
  o <- usp_noyau(d, g, x, y, xbar)$obj
  if (!is.finite(o)) 1e12 else o
}

# Minimisation sous contrainte 0 <= delta <= 1 (annexe XVII, par. 6),
# avec démarrages multiples pour éviter les optima locaux.
usp_ajuster <- function(x, y, n_starts_delta = 9, verbose = FALSE) {
  xbar <- mean(x)
  grille_d <- seq(0, 1, length.out = n_starts_delta)
  grille_g <- log(c(0.01, 0.03, 0.06, 0.10, 0.20, 0.40))
  starts <- expand.grid(delta = grille_d, gamma = grille_g)
  best <- NULL
  vals <- rep(NA_real_, nrow(starts))
  for (i in seq_len(nrow(starts))) {
    fit <- try(stats::optim(
      par = c(starts$delta[i], starts$gamma[i]),
      fn = usp_objectif, x = x, y = y, xbar = xbar,
      method = "L-BFGS-B",
      lower = c(0, -12), upper = c(1, 3),
      control = list(factr = 1e5, maxit = 500)), silent = TRUE)
    if (inherits(fit, "try-error")) next
    vals[i] <- fit$value
    if (is.null(best) || fit$value < best$value - 1e-10) best <- fit
  }
  if (is.null(best)) stop("Echec de l'optimisation (annexe XVII, par. 6).")

  # Contrôle de convergence : proportion de démarrages atteignant l'optimum
  # global, mesuree sur la meme grille (aucune reoptimisation redondante).
  part_convergents <- mean(abs(vals - best$value) < 1e-6, na.rm = TRUE)

  d <- best$par[1]; g <- best$par[2]
  k <- usp_noyau(d, g, x, y, xbar)
  # Condition du premier ordre du maximum de vraisemblance : sum(pi_t * v_t) = 0.
  # C'est CETTE somme ponderee qui est contrainte a zero, et non la moyenne
  # simple des residus standardises (elles ne coincident que si pi_t est
  # constant, c'est-a-dire delta = 1 ou volumes x_t constants).
  foc <- abs(sum(k$pi * k$v)) / sum(k$pi)
  c(k, list(delta = d, gamma = g, T = length(x), x = x, y = y, xbar = xbar,
            foc = foc,
            obj_min = best$value, convergence = best$convergence,
            part_starts_convergents = part_convergents,
            delta_au_bord = (d < 1e-6 || d > 1 - 1e-6)))
}

# Paramètre propre final :
# sigma_USP = c * sigma(delta, gamma) * sqrt((T+1)/(T-1)) + (1 - c) * sigma_standard
usp_parametre <- function(fit, sigma_standard, bareme = "court") {
  T <- fit$T
  cred <- usp_credibilite(T, bareme)
  corr <- sqrt((T + 1) / (T - 1))
  sigma_ech <- fit$sigma * corr
  list(
    sigma_estime_brut   = fit$sigma,
    correction_taille   = corr,
    sigma_estime        = sigma_ech,
    credibilite         = cred,
    sigma_standard      = sigma_standard,
    sigma_usp           = cred * sigma_ech + (1 - cred) * sigma_standard,
    variation_relative  = (cred * sigma_ech + (1 - cred) * sigma_standard) / sigma_standard - 1
  )
}


## =============================================================================
## 3. STATISTIQUES DE TEST (implémentations base R, références citées)
## =============================================================================

.p_borne <- function(p) if (!is.finite(p)) NA_real_ else max(min(p, 1), 0)

# shapiro.test() leve une erreur si toutes les valeurs sont identiques ;
# encapsulation indispensable car cette fonction est appelee dans la boucle
# de bootstrap, ou une replication degeneree interromprait tout le calcul.
.shapiro_sur <- function(z) {
  r <- try(stats::shapiro.test(z), silent = TRUE)
  if (inherits(r, "try-error"))
    list(stat = NA_real_, p = NA_real_)
  else list(stat = unname(r$statistic), p = r$p.value)
}

# --- Normalité ---------------------------------------------------------------

# Anderson & Darling (1954), "A test of goodness of fit", JASA 49, 765-769.
stat_ad <- function(z) {
  z <- sort(z); n <- length(z)
  p <- stats::pnorm(z)
  p <- pmin(pmax(p, 1e-12), 1 - 1e-12)
  -n - mean((2 * seq_len(n) - 1) * (log(p) + log(1 - rev(p))))
}

# Cramér (1928) / von Mises (1931) ; forme de Stephens (1974), JASA 69, 730-737.
stat_cvm <- function(z) {
  z <- sort(z); n <- length(z)
  p <- stats::pnorm(z)
  1 / (12 * n) + sum((p - (2 * seq_len(n) - 1) / (2 * n))^2)
}

# p-value analytique d'Anderson-Darling, cas 3 (moyenne et variance estimees),
# approximations par morceaux de D'Agostino & Stephens (1986),
# Goodness-of-Fit Techniques, Marcel Dekker, tableau 4.9.
# Ce sont des ajustements empiriques, non un resultat exact : la p-value est
# fournie a titre de p-value NON simulee, la p-value de Monte-Carlo restant
# calculee en parallele.
ad_p_stephens <- function(A2, n) {
  if (!is.finite(A2) || n < 5) return(NA_real_)
  a <- A2 * (1 + 0.75 / n + 2.25 / n^2)
  p <- if (a < 0.200)      1 - exp(-13.436 + 101.14 * a - 223.73 * a^2)
       else if (a < 0.340) 1 - exp(-8.318 + 42.796 * a - 59.938 * a^2)
       else if (a < 0.600) exp(0.9177 - 4.279 * a - 1.38 * a^2)
       else if (a < 13)    exp(1.2937 - 5.709 * a + 0.0186 * a^2)
       else                0
  .p_borne(p)
}

# p-value analytique de Cramer-von Mises, cas 3, memes sources.
cvm_p_stephens <- function(W2, n) {
  if (!is.finite(W2) || n < 5) return(NA_real_)
  w <- W2 * (1 + 0.5 / n)
  p <- if (w < 0.0275)      1 - exp(-13.953 + 775.5 * w - 12542.61 * w^2)
       else if (w < 0.051)  1 - exp(-5.903 + 179.546 * w - 1515.29 * w^2)
       else if (w < 0.092)  exp(0.886 - 31.62 * w + 10.897 * w^2)
       else if (w < 1.1)    exp(1.111 - 34.242 * w + 12.832 * w^2)
       else                 7.37e-10
  .p_borne(p)
}

# --- Test de Lilliefors (1967) ----------------------------------------------
# Distinct du Kolmogorov-Smirnov contre N(0,1) deja present : ici la moyenne et
# l'ecart-type sont ESTIMES sur l'echantillon, ce qui est la situation reelle.
# La loi de reference n'est plus celle de Kolmogorov mais celle de Lilliefors,
# stochastiquement plus concentree.
stat_lilliefors <- function(z) {
  n <- length(z); m <- mean(z); s <- stats::sd(z)
  if (!is.finite(s) || s == 0) return(NA_real_)
  p <- stats::pnorm(sort((z - m) / s))
  max(pmax((1:n) / n - p, p - (0:(n - 1)) / n))
}

# p-value de Lilliefors : approximation de Dallal & Wilkinson (1986),
# The American Statistician 40(4), 294-296, prolongee au-dela de 0,10 par les
# polynomes de Stephens (1974). Meme implementation que nortest::lillie.test.
lillie_p <- function(D, n) {
  if (!is.finite(D) || n < 5) return(NA_real_)
  if (n <= 100) { Kd <- D; nd <- n } else { Kd <- D * (n / 100)^0.49; nd <- 100 }
  p <- exp(-7.01256 * Kd^2 * (nd + 2.78019) +
             2.99587 * Kd * sqrt(nd + 2.78019) - 0.122119 +
             0.974598 / sqrt(nd) + 1.67997 / nd)
  if (p > 0.1) {
    KK <- (sqrt(n) - 0.01 + 0.85 / sqrt(n)) * D
    p <- if (KK <= 0.302) 1
         else if (KK <= 0.5)  2.76773 - 19.828315 * KK + 80.709644 * KK^2 -
                              138.55152 * KK^3 + 81.218052 * KK^4
         else if (KK <= 0.9)  -4.901232 + 40.662806 * KK - 97.490286 * KK^2 +
                              94.029866 * KK^3 - 32.355711 * KK^4
         else if (KK <= 1.31) 6.198765 - 19.558097 * KK + 23.186922 * KK^2 -
                              12.234627 * KK^3 + 2.423045 * KK^4
         else 0
  }
  .p_borne(p)
}

# --- Shapiro-Wilk SANS la normalisation de Royston --------------------------
# shapiro.test() calcule W puis en tire une p-value par la transformation
# normalisante de Royston (1992), qui est un ajustement empirique. On propose
# ici une p-value obtenue par simulation directe de la LOI NULLE de W pour des
# echantillons normaux de meme taille. Cette loi ne depend d'aucun parametre
# (W est invariant par translation et par changement d'echelle), donc la
# simulation est independante du modele USP ajuste : ce n'est PAS un bootstrap
# parametrique, mais une evaluation numerique de la loi exacte de W sous H0.
# Le resultat est exact a l'erreur de Monte-Carlo pres, en 1/sqrt(B_null).
.cache_sw <- new.env(parent = emptyenv())
sw_loi_nulle <- function(n, B_null = 20000, seed = 20260901) {
  cle <- paste0("n", n, "_B", B_null, "_s", seed)
  if (!is.null(.cache_sw[[cle]])) return(.cache_sw[[cle]])
  old <- if (exists(".Random.seed", .GlobalEnv)) get(".Random.seed", .GlobalEnv) else NULL
  set.seed(seed)
  w <- replicate(B_null, {
    r <- try(stats::shapiro.test(stats::rnorm(n))$statistic, silent = TRUE)
    if (inherits(r, "try-error")) NA_real_ else unname(r)
  })
  if (!is.null(old)) assign(".Random.seed", old, envir = .GlobalEnv)
  w <- sort(w[is.finite(w)])
  .cache_sw[[cle]] <- w
  w
}
sw_p_loi_nulle <- function(W, n, B_null = 20000) {
  if (!is.finite(W) || n < 3) return(NA_real_)
  w <- sw_loi_nulle(n, B_null)
  if (!length(w)) return(NA_real_)
  .p_borne((1 + sum(w <= W)) / (length(w) + 1))   # rejet en queue basse
}

# Kolmogorov (1933) - Smirnov (1948), version Lilliefors (1967) JASA 62, 399-402.
stat_ks <- function(z) {
  z <- sort(z); n <- length(z)
  p <- stats::pnorm(z)
  max(pmax(seq_len(n) / n - p, p - (seq_len(n) - 1) / n))
}

# Shapiro & Francia (1972), JASA 67, 215-216 ; p-value Royston (1993) Appl. Stat.
test_shapiro_francia <- function(z) {
  n <- length(z)
  if (n < 5 || n > 5000) return(list(stat = NA_real_, p = NA_real_))
  m <- stats::qnorm(stats::ppoints(n, a = 3/8))
  W <- stats::cor(sort(z), m)^2
  u <- log(n); v <- log(u)
  mu <- -1.2725 + 1.0521 * (v - u)
  sg <- 1.0308 - 0.26758 * (v + 2 / u)
  p <- 1 - stats::pnorm((log(1 - W) - mu) / sg)
  list(stat = W, p = .p_borne(p))
}

# Jarque & Bera (1980), Economics Letters 6, 255-259.
test_jarque_bera <- function(z) {
  n <- length(z); m <- mean(z)
  s <- mean((z - m)^3) / mean((z - m)^2)^1.5
  k <- mean((z - m)^4) / mean((z - m)^2)^2
  JB <- n / 6 * (s^2 + (k - 3)^2 / 4)
  list(stat = JB, p = .p_borne(1 - stats::pchisq(JB, 2)), skew = s, kurt = k)
}

# D'Agostino (1970), Biometrika 57, 679-681 (asymetrie).
test_dagostino_skew <- function(z) {
  n <- length(z)
  if (n < 8) return(list(stat = NA_real_, p = NA_real_))
  m <- mean(z); b1 <- mean((z - m)^3) / mean((z - m)^2)^1.5
  Y <- b1 * sqrt((n + 1) * (n + 3) / (6 * (n - 2)))
  b2 <- 3 * (n^2 + 27 * n - 70) * (n + 1) * (n + 3) /
        ((n - 2) * (n + 5) * (n + 7) * (n + 9))
  W2 <- -1 + sqrt(2 * (b2 - 1)); W <- sqrt(W2)
  del <- 1 / sqrt(log(W)); alp <- sqrt(2 / (W2 - 1))
  Z <- del * log(Y / alp + sqrt((Y / alp)^2 + 1))
  list(stat = Z, p = .p_borne(2 * (1 - stats::pnorm(abs(Z)))))
}

# Anscombe & Glynn (1983), Biometrika 70, 227-234 (aplatissement).
test_anscombe_kurt <- function(z) {
  n <- length(z)
  if (n < 20) return(list(stat = NA_real_, p = NA_real_))
  m <- mean(z); b2 <- mean((z - m)^4) / mean((z - m)^2)^2
  Eb2 <- 3 * (n - 1) / (n + 1)
  vb2 <- 24 * n * (n - 2) * (n - 3) / ((n + 1)^2 * (n + 3) * (n + 5))
  xx <- (b2 - Eb2) / sqrt(vb2)
  sb1 <- 6 * (n^2 - 5 * n + 2) / ((n + 7) * (n + 9)) *
         sqrt(6 * (n + 3) * (n + 5) / (n * (n - 2) * (n - 3)))
  A <- 6 + 8 / sb1 * (2 / sb1 + sqrt(1 + 4 / sb1^2))
  Z <- ((1 - 2 / (9 * A)) -
        ((1 - 2 / A) / (1 + xx * sqrt(2 / (A - 4))))^(1/3)) / sqrt(2 / (9 * A))
  list(stat = Z, p = .p_borne(2 * (1 - stats::pnorm(abs(Z)))))
}

# --- Indépendance / structure temporelle -------------------------------------

# Durbin & Watson (1950, 1951), Biometrika 37 et 38.
# CORRECTION : la statistique est definie sur des residus de MOYENNE NULLE (les
# residus MCO le sont par construction). Nos z_t sont contraints par
# sum(sqrt(pi_t) z_t) = 0 mais pas par sum(z_t) = 0 : sans centrage, le
# denominateur est gonfle de T*mean(z)^2 et DW est biaisee vers le bas. On
# centre donc explicitement, ce qui rend aussi la statistique coherente avec
# l'autocorrelation utilisee par Box.test().
stat_dw <- function(z) {
  zc <- z - mean(z)
  sum(diff(zc)^2) / sum(zc^2)
}

# Loi EXACTE de DW sous H0 : z ~ N(0, sigma^2 I).
# DW = z'Az / z'z avec A la matrice des differences secondes, dont les valeurs
# propres sont connues analytiquement : lambda_j = 2(1 - cos(pi j / n)),
# j = 0, ..., n-1 (verification numerique faite). On a donc
#     P(DW <= c) = P( z'(A - cI)z <= 0 )
# soit la queue d'une forme quadratique en variables normales, calculable
# exactement par la methode d'Imhof (1961), Biometrika 48, 419-426 :
#     P(Q > 0) = 1/2 - (1/pi) * integrale_0^inf sin(theta(u)) / (u rho(u)) du
# Aucune approximation asymptotique n'intervient ; les bornes d_L/d_U de
# Durbin-Watson, etablies pour des residus MCO, ne sont pas utilisees.
.imhof_p_sup0 <- function(h) {
  integrand <- function(u) {
    theta <- 0.5 * colSums(atan(outer(h, u)))
    rho   <- exp(0.25 * colSums(log1p(outer(h^2, u^2))))
    sin(theta) / (u * rho)
  }
  v <- try(stats::integrate(integrand, 0, Inf, subdivisions = 2000L,
                            rel.tol = 1e-10)$value, silent = TRUE)
  if (inherits(v, "try-error")) return(NA_real_)
  min(max(0.5 - v / pi, 0), 1)
}

# p-value bilaterale exacte de Durbin-Watson (centrage compris : le centrage
# retire une dimension, on travaille sur les n-1 valeurs propres non nulles de
# A restreintes au sous-espace orthogonal au vecteur constant).
dw_p_exacte <- function(z) {
  n <- length(z)
  if (n < 4) return(NA_real_)
  d <- stat_dw(z)
  # matrice des differences secondes projetee sur le complement du vecteur 1
  A <- diag(c(1, rep(2, n - 2), 1))
  for (i in 1:(n - 1)) { A[i, i + 1] <- -1; A[i + 1, i] <- -1 }
  M <- diag(n) - matrix(1 / n, n, n)          # projecteur de centrage
  lam <- eigen(M %*% A %*% M, symmetric = TRUE, only.values = TRUE)$values
  lam <- sort(lam, decreasing = TRUE)[1:(n - 1)]   # on ecarte la valeur nulle
  p_inf <- .imhof_p_sup0(lam - d)             # P(DW > d)
  if (!is.finite(p_inf)) return(NA_real_)
  .p_borne(2 * min(p_inf, 1 - p_inf))
}

# Wald & Wolfowitz (1940), Ann. Math. Statist. 11, 147-162 (test des suites).
test_runs <- function(z) {
  s <- sign(z - stats::median(z)); s <- s[s != 0]
  n <- length(s); n1 <- sum(s > 0); n2 <- sum(s < 0)
  if (n1 == 0 || n2 == 0) return(list(stat = NA_real_, p = NA_real_, runs = NA))
  R <- 1 + sum(diff(s) != 0)
  E <- 2 * n1 * n2 / n + 1
  V <- 2 * n1 * n2 * (2 * n1 * n2 - n) / (n^2 * (n - 1))
  Z <- (R - E) / sqrt(V)
  list(stat = Z, p = .p_borne(2 * (1 - stats::pnorm(abs(Z)))), runs = R)
}

# Cox & Stuart (1955), JRSS B 17, 1-26 (test de tendance par signes).
test_cox_stuart <- function(v) {
  n <- length(v); c0 <- ceiling(n / 2)
  d <- v[(c0 + 1):n] - v[1:(n - c0)]
  d <- d[d != 0]
  if (!length(d)) return(list(stat = NA_real_, p = NA_real_))
  k <- sum(d > 0); m <- length(d)
  list(stat = k, p = .p_borne(stats::binom.test(k, m, 0.5)$p.value))
}

# --- Lois EXACTES sous H0 (disponibles aux petites tailles, donc a T = 8) ----

# Distribution exacte du S de Kendall par la distribution mahonienne du nombre
# d'inversions : la fonction generatrice du nombre d'inversions d'une
# permutation de n elements est prod_{k=1}^{n} (1 + q + ... + q^{k-1})
# (Kendall & Gibbons, 1990, Rank Correlation Methods, 5e ed., ch. 4-5).
# Avec S = n(n-1)/2 - 2*inv, on en deduit la loi exacte de S sous H0.
.mk_loi_exacte <- function(n) {
  if (n < 2 || n > 12) return(NULL)          # au-dela : cout combinatoire inutile
  poly <- 1
  for (k in 2:n) poly <- .poly_mult(poly, rep(1, k))
  inv <- 0:(length(poly) - 1)
  list(S = n * (n - 1) / 2 - 2 * inv, prob = poly / sum(poly))
}
.poly_mult <- function(a, b) {
  r <- numeric(length(a) + length(b) - 1)
  for (i in seq_along(a)) r[i:(i + length(b) - 1)] <- r[i:(i + length(b) - 1)] + a[i] * b
  r
}

# p-value bilaterale exacte du test de Mann-Kendall (sans ex aequo).
mk_p_exacte <- function(v) {
  n <- length(v)
  if (anyDuplicated(v) > 0) return(NA_real_)   # loi exacte invalide avec ex aequo
  d <- .mk_loi_exacte(n)
  if (is.null(d)) return(NA_real_)
  Sobs <- sum(vapply(1:(n - 1), function(i) sum(sign(v[(i + 1):n] - v[i])), numeric(1)))
  .p_borne(sum(d$prob[abs(d$S) >= abs(Sobs) - 1e-9]))
}

# Loi exacte du nombre de suites R (Wald-Wolfowitz), tabulee par
# Swed & Eisenhart (1943), Ann. Math. Statist. 14, 66-87.
#   P(R = 2k)   = 2 C(n1-1, k-1) C(n2-1, k-1) / C(n, n1)
#   P(R = 2k+1) = [C(n1-1,k) C(n2-1,k-1) + C(n1-1,k-1) C(n2-1,k)] / C(n, n1)
.runs_dens <- function(n1, n2) {
  n <- n1 + n2; rr <- 2:n; pr <- numeric(length(rr))
  for (idx in seq_along(rr)) {
    R <- rr[idx]
    if (R %% 2 == 0) {
      k <- R / 2
      pr[idx] <- 2 * choose(n1 - 1, k - 1) * choose(n2 - 1, k - 1)
    } else {
      k <- (R - 1) / 2
      pr[idx] <- choose(n1 - 1, k) * choose(n2 - 1, k - 1) +
                 choose(n1 - 1, k - 1) * choose(n2 - 1, k)
    }
  }
  list(R = rr, prob = pr / choose(n, n1))
}

# p-value bilaterale exacte du test des suites (methode de la densite : on
# somme les probabilites des issues au plus aussi probables que l'observee).
runs_p_exacte <- function(z) {
  sg <- sign(z - stats::median(z)); sg <- sg[sg != 0]
  n1 <- sum(sg > 0); n2 <- sum(sg < 0)
  if (n1 < 1 || n2 < 1) return(NA_real_)
  Robs <- 1 + sum(diff(sg) != 0)
  d <- .runs_dens(n1, n2)
  pobs <- d$prob[d$R == Robs]
  if (!length(pobs)) return(NA_real_)
  .p_borne(sum(d$prob[d$prob <= pobs + 1e-12]))
}

# Mann (1945) / Kendall (1975) - test de tendance monotone.
test_mann_kendall <- function(v) {
  n <- length(v)
  S <- sum(vapply(1:(n - 1), function(i) sum(sign(v[(i + 1):n] - v[i])), numeric(1)))
  ties <- table(v); tt <- sum(ties * (ties - 1) * (2 * ties + 5))
  V <- (n * (n - 1) * (2 * n + 5) - tt) / 18
  Z <- if (S > 0) (S - 1) / sqrt(V) else if (S < 0) (S + 1) / sqrt(V) else 0
  list(stat = Z, p = .p_borne(2 * (1 - stats::pnorm(abs(Z)))), S = S)
}

# --- Hétéroscédasticité / structure de variance ------------------------------

# --- Breusch-Pagan, VERSION ORIGINALE de 1979 (non robuste) ------------------
# Breusch & Pagan (1979), Econometrica 47, 1287-1294, statistique du
# multiplicateur de Lagrange telle que publiee :
#     g_t = u_t^2 / sigma^2_chapeau   avec sigma^2_chapeau = moyenne(u_t^2)
#     LM  = (1/2) * somme des carres EXPLIQUES de la regression de g sur Z
# Sous H0 ET NORMALITE des erreurs, LM converge en loi vers chi2(q).
#
# ATTENTION : le facteur 1/2 et la loi chi2 reposent explicitement sur
# Var(u^2) = 2 sigma^4, propriete de la loi normale. Le test est donc
# NON ROBUSTE : sur des erreurs a queues lourdes, Var(u^2) > 2 sigma^4 et la
# statistique est gonflee, ce qui provoque un sur-rejet. C'est precisement ce
# defaut que la version studentisee de Koenker (1981) corrige, en remplacant le
# facteur 1/2 par une estimation empirique de la variance de u^2, ce qui conduit
# a LM = T R^2 (fonction test_breusch_pagan ci-dessous).
#
# Les deux versions sont conservees : l'originale parce qu'elle est celle qui
# est citee dans la litterature et attendue dans un dossier, la robuste parce
# qu'elle est la seule defendable si la normalite n'est pas acquise -- ce qui
# est justement l'objet de l'hypothese H3, testee separement.
test_breusch_pagan_original <- function(u2, reg) {
  n <- length(u2)
  if (stats::sd(reg) == 0 || mean(u2) <= 0)
    return(list(stat = NA_real_, p = NA_real_, ddl = NA_integer_))
  g <- u2 / mean(u2)
  aux <- stats::lm(g ~ reg)
  sce <- sum((stats::fitted(aux) - mean(g))^2)   # somme des carres expliques
  LM <- 0.5 * sce
  q <- 1
  list(stat = LM, p = .p_borne(1 - stats::pchisq(LM, q)), ddl = q)
}

# Breusch & Pagan (1979), Econometrica 47, 1287-1294 ; version studentisee
# (robuste a la non-normalite) de Koenker (1981) : LM = n R^2.
test_breusch_pagan <- function(u2, reg) {
  d <- data.frame(u2 = u2, reg = reg)
  m <- stats::lm(u2 ~ reg, data = d)
  R2 <- summary(m)$r.squared
  LM <- length(u2) * R2
  list(stat = LM, p = .p_borne(1 - stats::pchisq(LM, 1)))
}

# White (1980), Econometrica 48, 817-838 (forme auxiliaire quadratique).
test_white <- function(u2, reg) {
  d <- data.frame(u2 = u2, reg = reg, reg2 = reg^2)
  m <- stats::lm(u2 ~ reg + reg2, data = d)
  R2 <- summary(m)$r.squared
  LM <- length(u2) * R2
  list(stat = LM, p = .p_borne(1 - stats::pchisq(LM, 2)))
}

# Goldfeld & Quandt (1965), JASA 60, 539-547.
test_goldfeld_quandt <- function(u, reg) {
  o <- order(reg); u <- u[o]; n <- length(u)
  h <- floor(n / 2)
  s1 <- sum(u[1:h]^2) / h
  s2 <- sum(u[(n - h + 1):n]^2) / h
  F <- s2 / s1
  list(stat = F, p = .p_borne(2 * min(stats::pf(F, h, h), 1 - stats::pf(F, h, h))))
}

# Brown & Forsythe (1974), JASA 69, 364-367 (variante robuste de Levene).
test_brown_forsythe <- function(u, reg) {
  g <- factor(reg > stats::median(reg))
  if (nlevels(g) < 2) return(list(stat = NA_real_, p = NA_real_))
  dev <- unlist(tapply(u, g, function(v) abs(v - stats::median(v))))
  gg <- rep(levels(g), tapply(u, g, length))
  a <- stats::anova(stats::lm(dev ~ gg))
  list(stat = a[["F value"]][1], p = .p_borne(a[["Pr(>F)"]][1]))
}

# Regression simple non contrainte y = a + b*x + e (Student & Fisher, 1908/1922/1925)
# utilisee uniquement comme diagnostic exploratoire de H1 - le modele
# reglementaire lui-meme est y = beta*x + e, sans constante (cf. test_intercept).
test_lm_complet <- function(x, y) {
  # x constant => colonne singuliere : la pente n'est pas identifiee et la
  # ligne "x" est absente de la matrice des coefficients. On renvoie des NA
  # plutot que de laisser une erreur d'indexation remonter.
  if (stats::sd(x) == 0 || length(unique(x)) < 2) {
    return(list(pente = NA_real_, t_pente = NA_real_, p_pente = NA_real_,
                F = NA_real_, ddl1 = NA_integer_, ddl2 = NA_integer_,
                p_F = NA_real_, R2 = NA_real_, R2_ajuste = NA_real_,
                modele = stats::lm(y ~ 1)))
  }
  m <- stats::lm(y ~ x)
  s <- summary(m)
  list(
    pente        = s$coefficients["x", "Estimate"],
    t_pente      = s$coefficients["x", "t value"],
    p_pente      = s$coefficients["x", "Pr(>|t|)"],
    F            = unname(s$fstatistic[1]),
    ddl1         = unname(s$fstatistic[2]),
    ddl2         = unname(s$fstatistic[3]),
    p_F          = stats::pf(s$fstatistic[1], s$fstatistic[2], s$fstatistic[3],
                             lower.tail = FALSE),
    R2           = s$r.squared,
    R2_ajuste    = s$adj.r.squared,
    modele       = m
  )
}

test_reset <- function(x, y) {
  if (stats::sd(x) == 0 || length(unique(x)) < 2)
    return(list(stat = NA_real_, p = NA_real_))
  m0 <- stats::lm(y ~ x - 1)                 # E[Y] = beta * X, sans constante
  f <- stats::fitted(m0)
  m1 <- stats::lm(y ~ x + I(f^2) + I(f^3) - 1)
  a <- stats::anova(m0, m1)
  list(stat = a[["F"]][2], p = .p_borne(a[["Pr(>F)"]][2]))
}

# --- Test d'equivalence sur la constante (TOST) ------------------------------
# Le test de Student usuel sur la constante a pour hypothese nulle a = 0 : son
# NON-rejet ne prouve rien (absence de preuve n'est pas preuve d'absence), ce
# qui est genant puisque c'est precisement la proportionnalite que le reglement
# exige d'etablir. Le test d'equivalence inverse la charge de la preuve :
#
#     H0 : |a| >= Delta      (la constante n'est PAS negligeable)
#     H1 : |a| <  Delta      (la constante est negligeable)
#
# Rejeter H0 fournit une preuve POSITIVE de proportionnalite pratique.
# Mise en oeuvre par deux tests unilateraux (Schuirmann, 1987) :
#     H0_bas : a <= -Delta   et   H0_haut : a >= +Delta
# la p-value du test d'equivalence etant le MAXIMUM des deux p-values
# unilaterales. Sous normalite des erreurs, chacune est EXACTE (loi de Student
# a T-2 degres de liberte) : aucune approximation asymptotique n'intervient.
#
# La marge Delta n'est pas statistique mais economique : elle doit etre fixee
# a priori. On la parametre en proportion theta de la perte annuelle moyenne,
# Delta = theta * mean(y), afin qu'elle soit invariante a l'unite monetaire.
# theta = 0.10 signifie : "une composante fixe inferieure a 10 % de la
# sinistralite annuelle moyenne est jugee negligeable".
# ATTENTION a l'exactitude : le test n'est EXACT (loi de Student) que si Delta
# est fixe A PRIORI, independamment des donnees. La marge par defaut
# Delta = theta*mean(y) est commode et invariante d'echelle, mais elle est
# aleatoire : l'exactitude devient alors approchee (la simulation montre que le
# niveau reste tenu, mais ce n'est plus un resultat exact). Pour un dossier
# ACPR, fixer `delta_abs` a une valeur arretee a priori et documentee.
test_tost_intercept <- function(x, y, theta = 0.10, delta_abs = NULL) {
  if (stats::sd(x) == 0 || length(unique(x)) < 2 ||
      (is.null(delta_abs) && theta <= 0) ||
      (!is.null(delta_abs) && (!is.finite(delta_abs) || delta_abs <= 0)))
    return(list(stat = NA_real_, p = NA_real_, delta = NA_real_,
                a = NA_real_, se = NA_real_, t_bas = NA_real_, t_haut = NA_real_,
                marge_a_priori = FALSE))
  m <- summary(stats::lm(y ~ x))
  a  <- m$coefficients[1, 1]; se <- m$coefficients[1, 2]
  ddl <- length(x) - 2
  marge_a_priori <- !is.null(delta_abs)
  Delta <- if (marge_a_priori) delta_abs else theta * mean(y)
  t_bas  <- (a + Delta) / se        # H0_bas  : a <= -Delta, rejet si t_bas grand
  t_haut <- (a - Delta) / se        # H0_haut : a >= +Delta, rejet si t_haut petit
  p_bas  <- stats::pt(t_bas,  ddl, lower.tail = FALSE)
  p_haut <- stats::pt(t_haut, ddl, lower.tail = TRUE)
  p <- max(p_bas, p_haut)           # regle du maximum (intersection-union)
  list(stat = if (p_bas >= p_haut) t_bas else t_haut,
       p = .p_borne(p), delta = Delta, a = a, se = se,
       t_bas = t_bas, t_haut = t_haut, p_bas = p_bas, p_haut = p_haut,
       ddl = ddl, marge_a_priori = marge_a_priori)
}

# Significativité de la constante : rejette la proportionnalité stricte.
test_intercept <- function(x, y) {
  if (stats::sd(x) == 0 || length(unique(x)) < 2)
    return(list(stat = NA_real_, p = NA_real_))
  m <- summary(stats::lm(y ~ x))
  list(stat = m$coefficients[1, 3], p = .p_borne(m$coefficients[1, 4]))
}

# --- Ruptures et points influents --------------------------------------------

# Quandt (1960) / Chow (1960) : statistique sup-F de rupture de moyenne.
stat_supF <- function(v, trim = 0.15) {
  n <- length(v)
  b <- max(2, floor(trim * n)):min(n - 2, n - floor(trim * n))
  if (!length(b) || b[1] >= b[length(b)]) return(NA_real_)
  sst <- sum((v - mean(v))^2)
  if (!is.finite(sst) || sst <= 0) return(NA_real_)
  Fs <- vapply(b, function(k) {
    ssr <- sum((v[1:k] - mean(v[1:k]))^2) + sum((v[(k+1):n] - mean(v[(k+1):n]))^2)
    ((sst - ssr) / 1) / (ssr / (n - 2))
  }, numeric(1))
  max(Fs)
}

# Brown, Durbin & Evans (1975), JRSS B 37, 149-192 : OLS-CUSUM.
stat_cusum <- function(z) {
  n <- length(z); s <- stats::sd(z)
  if (!is.finite(s) || s == 0) return(NA_real_)
  max(abs(cumsum(z - mean(z))) / (s * sqrt(n)))
}

# Grubbs (1969), Technometrics 11, 1-21.
test_grubbs <- function(v) {
  n <- length(v); s <- stats::sd(v)
  if (!is.finite(s) || s == 0 || n < 3)
    return(list(stat = NA_real_, p = NA_real_, idx = NA))
  G <- max(abs(v - mean(v))) / s
  # G est borne par (n-1)/sqrt(n) ; a cette borne le denominateur s'annule
  # (0/0 numerique). On borne alors la p-value a sa valeur limite 0.
  den <- (n - 1)^2 - n * G^2
  if (den <= .Machine$double.eps * (n - 1)^2) {
    p <- 0
  } else {
    tt <- sqrt(n * (n - 2) * G^2 / den)
    p <- n * 2 * (1 - stats::pt(tt, n - 2))
  }
  list(stat = G, p = .p_borne(p), idx = which.max(abs(v - mean(v))))
}

# Rosner (1983), Technometrics 25, 165-172 : generalized ESD.
test_rosner <- function(v, k = NULL, alpha = 0.05) {
  # alpha est le niveau de la procedure de decision (il n'y a pas de p-value).
  n <- length(v); if (is.null(k)) k <- max(1, floor(n / 4))
  w <- v; idx <- seq_along(v); det <- integer(0)
  R <- numeric(k); lam <- numeric(k)
  for (i in 1:k) {
    if (length(w) < 3) { R[i] <- NA; lam[i] <- NA; next }
    m <- mean(w); s <- stats::sd(w)
    j <- which.max(abs(w - m))
    R[i] <- abs(w[j] - m) / s
    nn <- n - i + 1
    pp <- 1 - alpha / (2 * nn)
    tcrit <- stats::qt(pp, nn - 2)
    lam[i] <- (nn - 1) * tcrit / sqrt((nn - 2 + tcrit^2) * nn)
    det <- c(det, idx[j]); w <- w[-j]; idx <- idx[-j]
  }
  n_out <- suppressWarnings(max(c(0, which(R > lam)), na.rm = TRUE))
  list(nb_outliers = n_out,
       positions = if (n_out > 0) det[seq_len(n_out)] else integer(0),
       R = R, lambda = lam)
}


## =============================================================================
## 4. P-VALUES PAR BOOTSTRAP PARAMÉTRIQUE SOUS LE MODÈLE AJUSTÉ
##    (seules p-values réellement calibrées pour T de l'ordre de 5 à 15)
## =============================================================================

usp_simuler <- function(fit) {
  # Y_t | X_t ~ LogNormale(mu_t, 1/pi_t) avec mu_t = ln(beta x_t) - 1/(2 pi_t)
  mu <- log(fit$beta * fit$x) - 1 / (2 * fit$pi)
  exp(stats::rnorm(fit$T, mu, sqrt(1 / fit$pi)))
}

# Toutes les statistiques dont la loi sous H0 "le modele de l'annexe XVII est
# correct" peut etre simulee. IMPORTANT : le bootstrap parametrique simule sous
# le MODELE AJUSTE. Sont donc exclues les statistiques dont l'hypothese nulle
# n'est pas "le modele est correct" mais "beta = 0" (Student sur la pente,
# Fisher global) : pour celles-la, le modele ajuste appartient a H1 et une
# p-value de Monte-Carlo n'aurait aucun sens.
.stats_bootstrapables <- function(x, y, z) {
  r <- y / x
  lbp <- test_breusch_pagan(z^2, x); lwh <- test_white(z^2, x)
  lbp79 <- test_breusch_pagan_original(z^2, x)
  gq <- test_goldfeld_quandt(z, x);  bf <- test_brown_forsythe(z, x)
  rs <- test_reset(x, y);            ti <- test_intercept(x, y)
  mk <- test_mann_kendall(r);        ru <- test_runs(z)
  ds <- test_dagostino_skew(z)
  sv <- if (stats::sd(x) > 0)
    suppressWarnings(unname(stats::cor.test(r, x, method = "spearman",
                                            exact = FALSE)$estimate)) else NA_real_
  st <- suppressWarnings(unname(stats::cor.test(r, seq_along(r),
                                                method = "spearman", exact = FALSE)$estimate))
  T <- length(x)
  lb2 <- if (T >= 8) unname(stats::Box.test(z, lag = 2, type = "Ljung-Box")$statistic) else NA_real_
  bp2 <- if (T >= 8) unname(stats::Box.test(z, lag = 2, type = "Box-Pierce")$statistic) else NA_real_
  sm <- NA_real_
  if (T >= 8 && stats::sd(x) > 0) {
    g <- x > stats::median(x)
    if (sum(g) >= 3 && sum(!g) >= 3)
      sm <- unname(suppressWarnings(stats::ks.test(z[g], z[!g])$statistic))
  }
  cx <- test_cox_stuart(r)
  m <- ceiling(T / 2)
  # Serie des ratios bruts centres : base alternative pour les tests
  # d'independance et de stabilite (voir usp_tests, argument base_residus).
  # Ces ratios sont heteroscedastiques par construction, donc leurs p-values
  # classiques ne sont qu'indicatives ; seule la p-value de Monte-Carlo est
  # valide, le bootstrap simulant sous le modele ajuste.
  u <- r - mean(r)
  lb1u <- unname(stats::Box.test(u, lag = 1, type = "Ljung-Box")$statistic)
  lb2u <- if (T >= 8) unname(stats::Box.test(u, lag = 2, type = "Ljung-Box")$statistic) else NA_real_
  bp2u <- if (T >= 8) unname(stats::Box.test(u, lag = 2, type = "Box-Pierce")$statistic) else NA_real_
  c(AD = stat_ad(z), CvM = stat_cvm(z), KS = stat_ks(z),
    SW = .shapiro_sur(z)$stat, SF = test_shapiro_francia(z)$stat,
    JB = test_jarque_bera(z)$stat, DW = stat_dw(z),
    LB1 = unname(stats::Box.test(z, lag = 1, type = "Ljung-Box")$statistic),
    supF = stat_supF(z), CUSUM = stat_cusum(z), Grubbs = test_grubbs(z)$stat,
    MeanZ = mean(z), VarZ = stats::var(z), Lillie = stat_lilliefors(z),
    # statistiques ajoutees : loi de reference seulement asymptotique
    Intercept = ti$stat, RESET = rs$stat, BP = lbp$stat, BP79 = lbp79$stat,
    White = lwh$stat,
    GQ = gq$stat, BF = bf$stat, Smirnov = sm, LB2 = lb2, BP2 = bp2,
    Runs = ru$stat, MK = mk$stat, SpearVol = sv, SpearTps = st,
    DAgo = ds$stat,
    CoxStuart = if (is.finite(cx$stat)) abs(cx$stat - (T - m) / 2) else NA_real_,
    # --- memes statistiques sur les ratios bruts centres (base "r") ---------
    DWr = stat_dw(u), LB1r = lb1u, LB2r = lb2u, BP2r = bp2u,
    Runsr = test_runs(u)$stat, supFr = stat_supF(u), CUSUMr = stat_cusum(u),
    Grubbsr = test_grubbs(u)$stat)
}

usp_bootstrap <- function(fit, B = 999, seed = 20260831, refit = TRUE,
                          progres = FALSE) {
  set.seed(seed)
  stats_obs <- .stats_bootstrapables(fit$x, fit$y, fit$z)
  noms <- names(stats_obs)
  sim <- matrix(NA_real_, B, length(noms), dimnames = list(NULL, noms))
  sig <- del <- gam <- rep(NA_real_, B)
  for (b in seq_len(B)) {
    yb <- usp_simuler(fit)
    fb <- if (refit) {
      f <- try(usp_ajuster_rapide(fit$x, yb, fit$delta, fit$gamma), silent = TRUE)
      if (inherits(f, "try-error")) next else f
    } else usp_noyau(fit$delta, fit$gamma, fit$x, yb, fit$xbar)
    sb <- try(.stats_bootstrapables(fit$x, yb, fb$z), silent = TRUE)
    if (inherits(sb, "try-error")) next
    sim[b, ] <- sb[noms]
    sig[b] <- fb$sigma
    if (!is.null(fb$delta)) { del[b] <- fb$delta; gam[b] <- fb$gamma }
    if (progres && b %% 100 == 0) cat(".")
  }
  if (progres) cat("\n")

  # Sens du rejet, statistique par statistique.
  queue <- c(AD = "haut", CvM = "haut", KS = "haut", SW = "bas", SF = "bas",
             JB = "haut", DW = "deux", LB1 = "haut", supF = "haut",
             CUSUM = "haut", Grubbs = "haut", MeanZ = "deux", VarZ = "deux",
             Lillie = "haut",
             Intercept = "deux", RESET = "haut", BP = "haut", BP79 = "haut",
             White = "haut",
             GQ = "deux", BF = "haut", Smirnov = "haut", LB2 = "haut",
             BP2 = "haut", Runs = "deux", MK = "deux", SpearVol = "deux",
             SpearTps = "deux", DAgo = "deux", CoxStuart = "haut",
             DWr = "deux", LB1r = "haut", LB2r = "haut", BP2r = "haut",
             Runsr = "deux", supFr = "haut", CUSUMr = "haut", Grubbsr = "haut")
  pv <- vapply(noms, function(nm) {
    sv <- sim[, nm]; sv <- sv[is.finite(sv)]; o <- stats_obs[[nm]]
    if (!length(sv) || !is.finite(o)) return(NA_real_)
    switch(queue[[nm]],
           haut = (1 + sum(sv >= o)) / (length(sv) + 1),
           bas  = (1 + sum(sv <= o)) / (length(sv) + 1),
           deux = 2 * min((1 + sum(sv >= o)) / (length(sv) + 1),
                          (1 + sum(sv <= o)) / (length(sv) + 1)))
  }, numeric(1))
  pv <- pmin(pv, 1)

  # Erreur de Monte-Carlo sur chaque p-value : ecart-type binomial en 1/sqrt(B),
  # a distinguer strictement de l'erreur d'approximation liee a T.
  B_eff <- colSums(is.finite(sim))
  err_mc <- sqrt(pv * (1 - pv) / pmax(B_eff, 1))

  list(stats_obs = as.list(stats_obs), p_mc = pv, err_mc = err_mc,
       B_effectif = B_eff, granularite = 1 / (B + 1),
       sigma_boot = sig[is.finite(sig)],
       delta_boot = del[is.finite(del)], gamma_boot = gam[is.finite(gam)], B = B)
}

# Réajustement rapide (un seul démarrage, à partir de l'optimum observé).
usp_ajuster_rapide <- function(x, y, d0, g0) {
  xbar <- mean(x)
  f <- stats::optim(c(d0, g0), usp_objectif, x = x, y = y, xbar = xbar,
                    method = "L-BFGS-B", lower = c(0, -12), upper = c(1, 3),
                    control = list(factr = 1e7, maxit = 200))
  k <- usp_noyau(f$par[1], f$par[2], x, y, xbar)
  c(k, list(delta = f$par[1], gamma = f$par[2], T = length(x),
            x = x, y = y, xbar = xbar))
}


## =============================================================================
## 5. ROBUSTESSE : JACKKNIFE, PROFIL DE VRAISEMBLANCE, TESTS DE RAPPORT
## =============================================================================

# Sensibilité au retrait d'une année. La crédibilité et la correction de taille
# sont maintenues à celles de l'échantillon complet : l'objectif est d'isoler
# l'effet de l'observation retirée sur l'estimation, non de rejouer les règles
# de l'annexe XVII sur un échantillon de T-1 années (qui pourrait passer sous
# le minimum de 5 années).
usp_jackknife <- function(fit, sigma_standard, bareme) {
  T <- fit$T
  cred <- usp_credibilite(T, bareme)
  corr <- sqrt((T + 1) / (T - 1))
  out <- data.frame(annee_retiree = 1:T, sigma = NA_real_, sigma_usp = NA_real_,
                    delta = NA_real_, gamma = NA_real_)
  for (i in 1:T) {
    xi <- fit$x[-i]; yi <- fit$y[-i]
    f <- try(usp_ajuster(xi, yi, n_starts_delta = 5), silent = TRUE)
    if (inherits(f, "try-error")) next
    out$sigma[i] <- f$sigma
    out$sigma_usp[i] <- cred * f$sigma * corr + (1 - cred) * sigma_standard
    out$delta[i] <- f$delta; out$gamma[i] <- f$gamma
  }
  out
}

usp_profil <- function(fit, n = 41) {
  gd <- seq(0, 1, length.out = n)
  pd <- vapply(gd, function(d) {
    o <- stats::optimize(function(g) usp_objectif(c(d, g), fit$x, fit$y, fit$xbar),
                         interval = c(-12, 3))
    o$objective
  }, numeric(1))
  gg <- seq(fit$gamma - 1.5, fit$gamma + 1.5, length.out = n)
  pg <- vapply(gg, function(g) {
    o <- stats::optimize(function(d) usp_objectif(c(d, g), fit$x, fit$y, fit$xbar),
                         interval = c(0, 1))
    o$objective
  }, numeric(1))
  # Tests du rapport de vraisemblance sur les cas limites de delta.
  lr <- function(d) {
    o <- stats::optimize(function(g) usp_objectif(c(d, g), fit$x, fit$y, fit$xbar),
                         interval = c(-12, 3))$objective
    st <- o - fit$obj_min
    list(stat = st, p = .p_borne(1 - stats::pchisq(st, 1)))
  }
  list(delta_grid = gd, delta_obj = pd, gamma_grid = gg, gamma_obj = pg,
       lr_delta0 = lr(0), lr_delta1 = lr(1))
}


## =============================================================================
## 6. BATTERIE DE TESTS COMPLÈTE
## =============================================================================

usp_tests <- function(fit, boot, alpha = 0.10,
                      theta_equiv = 0.10, delta_equiv = NULL) {
  z <- fit$z; x <- fit$x; y <- fit$y; T <- fit$T
  r <- y / x
  # Base alternative : ratios bruts centres. Voir la sous-section
  # "Choix de la base de residus" de la documentation.
  u <- r - mean(r)
  pmc <- boot$p_mc; emc <- boot$err_mc
  gp  <- function(nm) if (nm %in% names(pmc)) unname(pmc[[nm]]) else NA_real_
  ge  <- function(nm) if (nm %in% names(emc)) unname(emc[[nm]]) else NA_real_
  L <- list()

  # -- Enregistrement d'une ligne de resultat ---------------------------------
  # Grandeurs strictement separees :
  #   stat        : STATISTIQUE DE TEST (loi de reference connue ou simulee)
  #   estim       : ESTIMATION / grandeur descriptive (aucune loi de reference)
  #   p_exacte / p_asymptotique / p_mc : les trois p-values possibles
  #   p_retenue + nature_p : celle effectivement utilisee pour le verdict
  #   err_mc      : erreur de Monte-Carlo (liee a B), a ne PAS confondre avec
  #                 l'erreur d'approximation statistique (liee a T)
  add <- function(fam, nom, ref, type = "test",
                  H0 = NA_character_, H1 = NA_character_,
                  stat_nom = NA_character_, stat = NA_real_,
                  loi = NA_character_,
                  estim_nom = NA_character_, estim = NA_real_,
                  p_ex = NA_real_, p_as = NA_real_, mc_nom = NA_character_,
                  detail = "", verdict = NULL, sens = "ne pas rejeter",
                  motif_non_mc = NA_character_, nature_forcee = NA_character_,
                  base = "commun", variante = "principale") {
    p_mc <- if (!is.na(mc_nom)) gp(mc_nom) else NA_real_
    e_mc <- if (!is.na(mc_nom)) ge(mc_nom) else NA_real_
    # Hierarchie adaptee a T faible : exacte > Monte-Carlo > asymptotique.
    if (is.finite(p_ex)) {
      p_ret <- p_ex; nature <- "exacte"
    } else if (is.finite(p_mc)) {
      p_ret <- p_mc; nature <- "Monte-Carlo (bootstrap parametrique)"
    } else if (is.finite(p_as)) {
      p_ret <- p_as
      nature <- if (!is.na(motif_non_mc))
        paste0("asymptotique (", motif_non_mc, ")") else "asymptotique"
    } else {
      p_ret <- NA_real_; nature <- NA_character_
    }
    if (!is.na(nature_forcee) && is.finite(p_ret)) nature <- nature_forcee
    v <- if (!is.null(verdict)) verdict
    else if (type != "test" || !is.finite(p_ret)) "INFO"
    else if (sens == "rejeter") {
      if (p_ret < alpha) "OK" else if (p_ret < 0.30) "ALERTE" else "ECHEC"
    } else {
      if (p_ret < alpha / 2) "ECHEC" else if (p_ret < alpha) "ALERTE" else "OK"
    }
    L[[length(L) + 1]] <<- list(
      famille = fam, test = nom, reference = ref, type = type,
      base = base, variante = variante,
      H0 = H0, H1 = H1,
      stat_nom = stat_nom, stat = stat, loi = loi,
      estim_nom = estim_nom, estim = estim,
      p_exacte = p_ex, p_asymptotique = p_as, p_mc = p_mc, err_mc = e_mc,
      p_retenue = p_ret, nature_p = nature,
      verdict = v, detail = detail, sens = sens)
  }

  ## --- B. H1 : E[Y_t] lineaire proportionnelle en X_t ------------------------
  fam <- "B. H1 - linearite / proportionnalite (annexe XVII B(2)(f)(i))"
  ti <- test_intercept(x, y); lmc <- test_lm_complet(x, y)
  # p-value EXACTE prioritaire : sous normalite des erreurs, t_a suit
  # exactement une loi de Student a T-2 ddl. La p-value de Monte-Carlo reste
  # calculee et affichee, mais a titre de complement seulement.
  add(fam, "Nullite de la constante (proportionnalite stricte)",
      "Student (1908), Biometrika 6",
      type = if (is.finite(ti$stat)) "test" else "non applicable",
      H0 = "a = 0 (proportionnalite stricte)", H1 = "a != 0",
      stat_nom = "t", stat = ti$stat,
      loi = sprintf("t(%d) EXACTE sous normalite des erreurs", T - 2),
      estim_nom = "constante a",
      estim = if (is.finite(ti$stat)) unname(stats::coef(lmc$modele)[1]) else NA_real_,
      p_ex = ti$p, mc_nom = "Intercept",
      detail = paste("Le NON-rejet ne prouve pas la proportionnalite :",
                     "voir le test d'equivalence ci-dessous."))
  tost <- test_tost_intercept(x, y, theta = theta_equiv, delta_abs = delta_equiv)
  add(fam, "Equivalence de la constante a zero (TOST)",
      "Schuirmann (1987), J. Pharmacokinet. Biopharm. 15",
      type = if (is.finite(tost$p)) "test" else "non applicable",
      H0 = "|a| >= Delta (la constante n'est PAS negligeable)",
      H1 = "|a| < Delta (constante negligeable : proportionnalite pratique)",
      stat_nom = "t (max des 2 unilateraux)", stat = tost$stat,
      loi = if (isTRUE(tost$marge_a_priori))
        sprintf("t(%d) EXACTE (marge fixee a priori)", T - 2)
      else sprintf("t(%d) ; marge estimee sur les donnees -> exactitude approchee", T - 2),
      estim_nom = "marge Delta", estim = tost$delta,
      p_ex = if (isTRUE(tost$marge_a_priori)) tost$p else NA_real_,
      p_as = if (isTRUE(tost$marge_a_priori)) NA_real_ else tost$p,
      nature_forcee = if (isTRUE(tost$marge_a_priori)) NA_character_
                      else "quasi-exacte (loi de Student ; marge estimee sur les donnees)",
      sens = "rejeter",
      detail = sprintf(paste("Rejeter H0 fournit une preuve POSITIVE de proportionnalite.",
                             "Delta = %.4g (%s) ; p_bas = %.4f, p_haut = %.4f."),
                       tost$delta,
                       if (isTRUE(tost$marge_a_priori)) "fixee a priori"
                       else sprintf("%.0f %% de la moyenne de y", 100 * theta_equiv),
                       tost$p_bas, tost$p_haut))
  add(fam, "Test de Student sur la pente (lm(y~x))",
      "Student (1908), Biometrika 6",
      type = if (is.finite(lmc$t_pente)) "test" else "non applicable",
      H0 = "b = 0 (aucun lien volume / pertes)", H1 = "b != 0",
      stat_nom = "t", stat = lmc$t_pente, loi = sprintf("t(%d)", T - 2),
      estim_nom = "pente b", estim = lmc$pente,
      p_as = lmc$p_pente, sens = "rejeter",
      motif_non_mc = "H0 non simulable : le modele ajuste appartient a H1",
      detail = "Loi EXACTE sous normalite des erreurs. Ici on souhaite REJETER H0")
  add(fam, "Test de Fisher (significativite globale)", "Fisher (1922, 1925)",
      type = if (is.finite(lmc$F)) "test" else "non applicable",
      H0 = "b = 0", H1 = "b != 0",
      stat_nom = "F", stat = lmc$F,
      loi = if (is.finite(lmc$F)) sprintf("F(%d,%d)", lmc$ddl1, lmc$ddl2) else NA_character_,
      p_as = lmc$p_F, sens = "rejeter",
      motif_non_mc = "H0 non simulable : le modele ajuste appartient a H1",
      detail = "Loi EXACTE sous normalite. Equivaut a t^2 en regression simple")
  add(fam, "Coefficient de determination R2", "lm(y ~ x)",
      type = if (is.finite(lmc$R2)) "indicateur" else "non applicable",
      estim_nom = "R2", estim = lmc$R2,
      detail = if (is.finite(lmc$R2))
        sprintf("R2 ajuste = %.4f ; sous H0 (b=0) E[R2] = 1/(T-1) = %.3f. Indicateur, pas un test",
                lmc$R2_ajuste, 1 / (T - 1)) else "x_t constant : R2 non defini",
      verdict = if (!is.finite(lmc$R2)) "INFO" else if (lmc$R2 < 0.5) "ALERTE" else "OK")
  tr <- test_reset(x, y)
  add(fam, "RESET (forme fonctionnelle)", "Ramsey (1969), JRSS B 31",
      H0 = "gamma2 = gamma3 = 0 (forme lineaire correcte)",
      H1 = "forme fonctionnelle mal specifiee",
      stat_nom = "F", stat = tr$stat, loi = sprintf("F(2,%d) approx.", T - 3),
      p_as = tr$p, mc_nom = "RESET",
      detail = "La loi F n'est PAS exacte : les regresseurs auxiliaires y^2, y^3 dependent de y")
  if (stats::sd(x) > 0) {
    cs_ex <- suppressWarnings(try(stats::cor.test(r, x, method = "spearman", exact = TRUE),
                                  silent = TRUE))
    cs <- suppressWarnings(stats::cor.test(r, x, method = "spearman", exact = FALSE))
    add(fam, "Independance ratio S/P vs volume", "Spearman (1904) ; exact : Best & Roberts (1975), AS 89",
        H0 = "independance (aucune association monotone)", H1 = "association monotone",
        stat_nom = "S", stat = unname(cs$statistic),
        loi = "permutation exacte (T <= 9, sans ex aequo)",
        estim_nom = "rho_s", estim = unname(cs$estimate),
        p_ex = if (!inherits(cs_ex, "try-error")) cs_ex$p.value else NA_real_,
        p_as = cs$p.value, mc_nom = "SpearVol",
        detail = "Une correlation signale un effet d'echelle non modelise")
  } else {
    add(fam, "Independance ratio S/P vs volume", "Spearman (1904)",
        type = "non applicable", detail = "x_t constant : test non applicable")
  }
  ct_ex <- suppressWarnings(try(stats::cor.test(r, seq_along(r), method = "spearman",
                                                exact = TRUE), silent = TRUE))
  ct <- suppressWarnings(stats::cor.test(r, seq_along(r), method = "spearman", exact = FALSE))
  add(fam, "Correlation ratio S/P vs temps", "Spearman (1904) ; exact : Best & Roberts (1975)",
      H0 = "independance entre le ratio et le rang chronologique",
      H1 = "association monotone avec le temps",
      stat_nom = "S", stat = unname(ct$statistic),
      loi = "permutation exacte (T <= 9, sans ex aequo)",
      estim_nom = "rho_s", estim = unname(ct$estimate),
      p_ex = if (!inherits(ct_ex, "try-error")) ct_ex$p.value else NA_real_,
      p_as = ct$p.value, mc_nom = "SpearTps")
  mk <- test_mann_kendall(r)
  add(fam, "Tendance monotone du ratio S/P",
      "Mann (1945) ; loi exacte : Kendall & Gibbons (1990), ch. 4-5",
      H0 = "absence de tendance monotone (r_t i.i.d.)", H1 = "tendance monotone",
      stat_nom = "Z", stat = mk$stat,
      loi = "loi exacte de S (distribution mahonienne)",
      estim_nom = "S de Kendall", estim = mk$S,
      p_ex = mk_p_exacte(r), p_as = mk$p, mc_nom = "MK",
      detail = "Une derive du S/P contredit la constance de beta")
  cx <- test_cox_stuart(r); m_paires <- T - ceiling(T / 2)
  add(fam, "Tendance par signes du ratio S/P", "Cox & Stuart (1955), Biometrika 42",
      H0 = "P(D_t > 0) = 1/2 (absence de tendance)", H1 = "P(D_t > 0) != 1/2",
      stat_nom = "K", stat = cx$stat, loi = "Binomiale(m, 1/2) EXACTE",
      p_ex = cx$p, mc_nom = "CoxStuart",
      detail = sprintf("m = %d paires ; p bilaterale minimale atteignable = %.4f",
                       m_paires, 2 * 0.5^m_paires))

  ## --- C. H2 : variance quadratique en X_t -----------------------------------
  fam <- "C. H2 - structure de variance (annexe XVII B(2)(f)(ii))"
  bp <- test_breusch_pagan(z^2, x)
  add(fam, "Heteroscedasticite vs volume - Breusch-Pagan studentise (Koenker)",
      "Breusch & Pagan (1979) ; studentisation de Koenker (1981)",
      H0 = "c1 = 0 : la variance des residus normalises ne depend pas du volume",
      H1 = "variance residuelle dependante du volume",
      stat_nom = "LM", stat = bp$stat, loi = "chi2(1) asymptotique",
      p_as = bp$p, mc_nom = "BP",
      detail = "Doit etre non significatif si la ponderation pi_t est correcte")
  bp79 <- test_breusch_pagan_original(z^2, x)
  add(fam, "Heteroscedasticite vs volume - Breusch-Pagan original (non robuste)",
      "Breusch & Pagan (1979), Econometrica 47",
      variante = "secondaire",
      H0 = "c1 = 0 ET erreurs normales : variance residuelle independante du volume",
      H1 = "variance residuelle dependante du volume",
      stat_nom = "LM", stat = bp79$stat, loi = "chi2(1) asymptotique, SOUS NORMALITE",
      p_as = bp79$p, mc_nom = "BP79",
      detail = paste("Version publiee, avec le facteur 1/2 issu de Var(u^2) = 2 sigma^4.",
                     "NON ROBUSTE : sur-rejette si les erreurs ne sont pas normales.",
                     "A confronter systematiquement a la version de Koenker ci-dessus."))
  wh <- test_white(z^2, x)
  add(fam, "Heteroscedasticite (forme quadratique)", "White (1980), Econometrica 48",
      H0 = "c1 = c2 = 0", H1 = "heteroscedasticite residuelle de forme quadratique",
      stat_nom = "LM", stat = wh$stat, loi = "chi2(2) asymptotique",
      p_as = wh$p, mc_nom = "White")
  gq <- test_goldfeld_quandt(z, x)
  add(fam, "Egalite des variances petits vs gros volumes",
      "Goldfeld & Quandt (1965), JASA 60",
      H0 = "sigma1^2 = sigma2^2", H1 = "variances inegales entre les deux blocs",
      stat_nom = "F", stat = gq$stat,
      loi = sprintf("F(%d,%d) approx. (residus issus d'un ajustement global)",
                    floor(T / 2), floor(T / 2)),
      p_as = gq$p, mc_nom = "GQ")
  bf <- test_brown_forsythe(z, x)
  add(fam, "Homogeneite des dispersions (mediane)",
      "Brown & Forsythe (1974), JASA 69",
      H0 = "egalite des dispersions entre les deux groupes",
      H1 = "dispersions inegales",
      stat_nom = "W", stat = bf$stat, loi = sprintf("F(1,%d) approx.", T - 2),
      p_as = bf$p, mc_nom = "BF")
  if (T >= 8 && stats::sd(x) > 0) {
    grp <- x > stats::median(x)
    if (sum(grp) >= 3 && sum(!grp) >= 3) {
      ks2 <- suppressWarnings(stats::ks.test(z[grp], z[!grp]))
      add(fam, "Egalite des lois petits vs gros volumes (2 ech.)", "Smirnov (1939)",
          H0 = "F1 = F2 (memes lois)", H1 = "lois differentes",
          stat_nom = "D", stat = unname(ks2$statistic),
          loi = "exacte combinatoire (ks.test, sans ex aequo)",
          p_ex = ks2$p.value, mc_nom = "Smirnov",
          detail = "Voir aussi le QQ-plot a deux echantillons")
    }
  }
  add(fam, "Position de delta dans [0,1]", "Annexe XVII, section B/C par. 6",
      type = "diagnostic", estim_nom = "delta", estim = fit$delta,
      detail = if (isTRUE(fit$delta_au_bord))
        "SOLUTION AU BORD : structure de variance non identifiee par les donnees"
      else "interieur du domaine : melange des deux composantes identifie",
      verdict = if (isTRUE(fit$delta_au_bord)) "ALERTE" else "OK")

  ## --- D. H3 : lognormalite --------------------------------------------------
  fam <- "D. H3 - lognormalite (annexe XVII B(2)(f)(iii))"
  H0n <- "les residus normalises suivent une loi normale"
  H1n <- "loi non normale"
  sw <- .shapiro_sur(z)
  add(fam, "Shapiro-Wilk sur residus standardises", "Shapiro & Wilk (1965), Biometrika 52",
      H0 = H0n, H1 = H1n, stat_nom = "W", stat = sw$stat,
      loi = "aucune forme fermee ; normalisation de Royston (1992)",
      p_as = sw$p, mc_nom = "SW")
  add(fam, "Shapiro-Wilk (loi nulle simulee, sans normalisation de Royston)",
      "Shapiro & Wilk (1965) ; loi nulle evaluee par simulation directe",
      variante = "secondaire",
      H0 = H0n, H1 = H1n, stat_nom = "W", stat = sw$stat,
      loi = "loi exacte de W sous normalite, evaluee numeriquement (20 000 tirages)",
      p_ex = sw_p_loi_nulle(sw$stat, T),
      detail = paste("W etant invariant par translation et changement d'echelle,",
                     "sa loi nulle ne depend d'aucun parametre : la simulation est",
                     "independante du modele USP ajuste (ce n'est pas un bootstrap)."))
  sf <- test_shapiro_francia(z)
  add(fam, "Shapiro-Francia", "Shapiro & Francia (1972), JASA 67 ; Royston (1993)",
      H0 = H0n, H1 = H1n, stat_nom = "W'", stat = sf$stat,
      loi = "aucune forme fermee ; normalisation de Royston (1993)",
      p_as = sf$p, mc_nom = "SF")
  add(fam, "Anderson-Darling", "Anderson & Darling (1954), JASA 49",
      H0 = H0n, H1 = H1n, stat_nom = "A2", stat = boot$stats_obs$AD,
      loi = "loi AD, cas parametres estimes ; approximation de Stephens",
      p_as = ad_p_stephens(boot$stats_obs$AD, T), mc_nom = "AD",
      detail = paste("Sensible aux queues. p non simulee disponible :",
                     "ajustement empirique de D'Agostino & Stephens (1986)."))
  add(fam, "Cramer-von Mises", "Cramer (1928) / von Mises (1928) ; Stephens (1974)",
      H0 = H0n, H1 = H1n, stat_nom = "W2", stat = boot$stats_obs$CvM,
      loi = "loi CvM, cas parametres estimes ; approximation de Stephens",
      p_as = cvm_p_stephens(boot$stats_obs$CvM, T), mc_nom = "CvM")
  add(fam, "Kolmogorov-Smirnov contre N(0,1)", "Kolmogorov (1933) ; Smirnov (1948)",
      H0 = H0n, H1 = H1n, stat_nom = "D", stat = boot$stats_obs$KS,
      variante = "secondaire",
      loi = "loi de Kolmogorov (valable a parametres CONNUS)",
      p_as = { dd <- boot$stats_obs$KS
               if (is.finite(dd)) .p_borne(2 * sum((-1)^(0:99) *
                 exp(-2 * (1:100)^2 * T * dd^2))) else NA_real_ },
      mc_nom = "KS",
      detail = paste("Les residus sont standardises par le MODELE, non par la moyenne",
                     "et l'ecart-type empiriques : la loi de Kolmogorov reste tres",
                     "conservatrice (simulation : 0 rejet sur 3 000 a 5 %).",
                     "Voir le test de Lilliefors ci-dessus."))
  Dl <- stat_lilliefors(z)
  add(fam, "Lilliefors (KS a parametres estimes)",
      "Lilliefors (1967), JASA 62 ; p-value : Dallal & Wilkinson (1986)",
      H0 = H0n, H1 = H1n, stat_nom = "D", stat = Dl,
      loi = "loi de Lilliefors (moyenne et ecart-type estimes)",
      p_as = lillie_p(Dl, T), mc_nom = "Lillie",
      detail = paste("Distinct du KS contre N(0,1) : la loi de reference tient compte",
                     "de l'estimation des parametres. Appliquer la loi de Kolmogorov",
                     "dans ce cas rend le test extremement conservateur."))
  jb <- test_jarque_bera(z)
  add(fam, "Jarque-Bera", "Jarque & Bera (1980, 1987)",
      H0 = "asymetrie nulle ET aplatissement egal a 3",
      H1 = "asymetrie ou aplatissement non normaux",
      stat_nom = "JB", stat = jb$stat, loi = "chi2(2) asymptotique",
      p_as = jb$p, mc_nom = "JB",
      detail = sprintf("asymetrie = %+.3f ; aplatissement = %.3f (borne mecaniquement par ~T = %d)",
                       jb$skew, jb$kurt, T))
  ds <- test_dagostino_skew(z)
  if (is.finite(ds$stat))
    add(fam, "Asymetrie (D'Agostino, T >= 8)", "D'Agostino (1970), Biometrika 57",
        H0 = "coefficient d'asymetrie de la population nul", H1 = "asymetrie non nulle",
        stat_nom = "Z", stat = ds$stat, loi = "N(0,1) approx. (transformation de Johnson SU)",
        estim_nom = "asymetrie", estim = jb$skew, p_as = ds$p, mc_nom = "DAgo")
  else
    add(fam, "Asymetrie (D'Agostino, T >= 8)", "D'Agostino (1970), Biometrika 57",
        type = "non applicable", estim_nom = "asymetrie", estim = jb$skew,
        detail = sprintf("T = %d < 8 : transformation normalisante non definie", T))
  ak <- test_anscombe_kurt(z)
  if (is.finite(ak$stat))
    add(fam, "Aplatissement (Anscombe-Glynn, T >= 20)", "Anscombe & Glynn (1983), Biometrika 70",
        H0 = "aplatissement de la population egal a 3", H1 = "aplatissement different de 3",
        stat_nom = "Z", stat = ak$stat, loi = "N(0,1) approx. (Wilson-Hilferty)",
        estim_nom = "aplatissement", estim = jb$kurt, p_as = ak$p)
  else
    add(fam, "Aplatissement (Anscombe-Glynn, T >= 20)", "Anscombe & Glynn (1983), Biometrika 70",
        type = "non applicable", estim_nom = "aplatissement", estim = jb$kurt,
        detail = sprintf("T = %d < 20 : test non defini", T))

  ## --- E. H4 : independance / validite du MV ---------------------------------
  fam <- "E. H4 - independance et validite du MV (annexe XVII B(2)(f)(iv))"
  add(fam, "Autocorrelation d'ordre 1 (Durbin-Watson)", "Durbin & Watson (1950, 1951)",
      base = "z",
      H0 = "rho = 0 (absence d'autocorrelation d'ordre 1)", H1 = "rho != 0",
      stat_nom = "DW", stat = boot$stats_obs$DW,
      loi = "forme quadratique en normales ; loi EXACTE par la methode d'Imhof (1961)",
      p_ex = dw_p_exacte(z), mc_nom = "DW",
      detail = paste("Statistique calculee sur residus CENTRES. Les bornes d_L/d_U,",
                     "etablies pour des residus MCO, ne sont pas utilisees : la loi",
                     "exacte est obtenue par integration numerique d'Imhof."))
  lb1 <- stats::Box.test(z, lag = 1, type = "Ljung-Box")
  add(fam, "Ljung-Box (retard 1)", "Ljung & Box (1978), Biometrika 65",
      base = "z",
      H0 = "rho_1 = 0", H1 = "autocorrelation au retard 1",
      stat_nom = "Q", stat = unname(lb1$statistic), loi = "chi2(1) asymptotique",
      p_as = lb1$p.value, mc_nom = "LB1")
  if (T >= 8) {
    lb2 <- stats::Box.test(z, lag = 2, type = "Ljung-Box")
    add(fam, "Ljung-Box (retard 2)", "Ljung & Box (1978), Biometrika 65",
        H0 = "rho_1 = rho_2 = 0", H1 = "autocorrelation jusqu'au retard 2",
        stat_nom = "Q", stat = unname(lb2$statistic), loi = "chi2(2) asymptotique",
        p_as = lb2$p.value, mc_nom = "LB2")
    bp2 <- stats::Box.test(z, lag = 2, type = "Box-Pierce")
    add(fam, "Box-Pierce (retard 2)", "Box & Pierce (1970), JASA 65",
        H0 = "rho_1 = rho_2 = 0", H1 = "autocorrelation jusqu'au retard 2",
        variante = "secondaire",
        stat_nom = "Q", stat = unname(bp2$statistic), loi = "chi2(2) asymptotique",
        p_as = bp2$p.value, mc_nom = "BP2")
  }
  ru <- test_runs(z)
  add(fam, "Test des suites (aleatoire des signes)",
      base = "z",
      "Wald & Wolfowitz (1940) ; loi exacte : Swed & Eisenhart (1943)",
      H0 = "la suite des signes est un arrangement aleatoire",
      H1 = "arrangement non aleatoire (regroupement ou alternance)",
      stat_nom = "Z", stat = ru$stat, loi = "loi combinatoire EXACTE de R",
      estim_nom = "nb de suites R", estim = ru$runs,
      p_ex = runs_p_exacte(z), p_as = ru$p, mc_nom = "Runs")
  tt <- stats::t.test(z)
  add(fam, "Centrage des residus standardises", "Student (1908) ; loi par Monte-Carlo",
      H0 = "E[z_t] = 0", H1 = "E[z_t] != 0",
      stat_nom = "t", stat = unname(tt$statistic),
      loi = "t(T-1) nominal ; parametres estimes -> Monte-Carlo",
      estim_nom = "moyenne(z)", estim = mean(z),
      p_as = tt$p.value, mc_nom = "MeanZ",
      detail = "VRAI test : la moyenne simple de z n'est pas contrainte par l'estimation")
  vc <- (T - 1) * stats::var(z)
  add(fam, "Variance unitaire des residus standardises", "Pearson (1900) ; loi par Monte-Carlo",
      H0 = "Var(z_t) = 1", H1 = "Var(z_t) != 1",
      stat_nom = "C", stat = vc,
      loi = "chi2(T-1) nominal ; parametres estimes -> Monte-Carlo",
      estim_nom = "var(z)", estim = stats::var(z),
      p_as = 2 * min(stats::pchisq(vc, T - 1), 1 - stats::pchisq(vc, T - 1)),
      mc_nom = "VarZ", detail = "VRAI test de l'echelle de la ponderation pi_t")

  ## --- F. Stabilite, ruptures et points aberrants ----------------------------
  fam <- "F. Stabilite, ruptures et points aberrants"
  add(fam, "Rupture de niveau (sup-F)", "Quandt (1960) / Chow (1960) ; Andrews (1993)",
      base = "z",
      H0 = "E[z_t] constant (absence de rupture)", H1 = "rupture de niveau a une date inconnue",
      stat_nom = "supF", stat = boot$stats_obs$supF,
      loi = "supremum de processus (Andrews) -> Monte-Carlo", mc_nom = "supF",
      detail = "La loi de Fisher est inapplicable : le point de rupture est estime")
  add(fam, "Stabilite cumulee (OLS-CUSUM)", "Brown, Durbin & Evans (1975), JRSS B 37",
      base = "z",
      H0 = "constance des parametres sur la periode", H1 = "derive graduelle",
      stat_nom = "CUSUM", stat = boot$stats_obs$CUSUM,
      loi = "sup |pont brownien| ; formule de Kolmogorov asymptotique",
      p_as = { cc <- boot$stats_obs$CUSUM
               if (is.finite(cc)) .p_borne(2 * sum((-1)^(0:99) *
                 exp(-2 * (1:100)^2 * cc^2))) else NA_real_ },
      mc_nom = "CUSUM",
      detail = "La formule asymptotique n'a aucune validite a T = 8 : p_mc retenue")
  gr <- test_grubbs(z)
  add(fam, "Valeur aberrante isolee (Grubbs)", "Grubbs (1950, 1969), Technometrics 11",
      base = "z",
      H0 = "aucune valeur aberrante (echantillon normal homogene)",
      H1 = "exactement une valeur aberrante",
      stat_nom = "G", stat = gr$stat,
      loi = "Student + borne de Bonferroni (conservatrice)",
      p_as = gr$p, mc_nom = "Grubbs",
      estim_nom = "rang de l'obs. extreme", estim = gr$idx,
      detail = sprintf("G est borne par (T-1)/sqrt(T) = %.3f", (T - 1) / sqrt(T)))
  ro <- test_rosner(z, alpha = alpha)
  add(fam, "Valeurs aberrantes multiples (ESD generalise)", "Rosner (1983), Technometrics 25",
      type = "procedure de decision",
      H0 = "aucune valeur aberrante", H1 = "il existe i <= k valeurs aberrantes",
      estim_nom = "nb de valeurs aberrantes", estim = ro$nb_outliers,
      detail = sprintf("procedure a niveau alpha = %.2f (aucune p-value)%s", alpha,
                       if (ro$nb_outliers > 0)
                         paste0(" ; rangs ", paste(ro$positions, collapse = ", ")) else ""),
      verdict = if (ro$nb_outliers >= 2) "ECHEC"
                else if (ro$nb_outliers == 1) "ALERTE" else "OK")
  mlm <- stats::lm(y ~ x - 1); ck <- stats::cooks.distance(mlm); hv <- stats::hatvalues(mlm)
  add(fam, "Points influents (distance de Cook)", "Cook (1977), Technometrics 19",
      type = "diagnostic", estim_nom = "max D_t", estim = max(ck),
      detail = sprintf("seuil conventionnel 4/T = %.3f ; %d observation(s) au-dessus%s",
                       4 / T, sum(ck > 4 / T),
                       if (any(ck > 4 / T))
                         paste0(" (rangs ", paste(which(ck > 4 / T), collapse = ", "), ")") else ""),
      verdict = if (sum(ck > 4 / T) >= 2) "ECHEC"
                else if (sum(ck > 4 / T) == 1) "ALERTE" else "OK")
  ## --- Variante "ratios bruts" des tests d'independance et de stabilite -----
  # Memes statistiques appliquees aux ratios centres u_t = r_t - moyenne(r).
  # Interet : ces tests ne dependent d'aucun ajustement, ce qui les rend
  # interpretables economiquement (une valeur aberrante de u_t est un
  # boni/mali exceptionnel) et insensibles a une mauvaise specification du
  # modele. Limite : les u_t sont heteroscedastiques par construction
  # (Var(r_t) depend de x_t), donc les p-values classiques ne sont
  # qu'INDICATIVES ; seule la p-value de Monte-Carlo est valide, le bootstrap
  # simulant sous le modele ajuste. Verification par simulation a T = 8 :
  # niveau tenu a 10,7 % et 5,0 % pour des seuils de 10 % et 5 %.
  loi_ind <- "loi classique INDICATIVE (ratios heteroscedastiques) -> Monte-Carlo"
  add("E. H4 - independance et validite du MV (annexe XVII B(2)(f)(iv))",
      "Autocorrelation d'ordre 1 (Durbin-Watson) sur ratios bruts",
      "Durbin & Watson (1950, 1951)", base = "r",
      H0 = "absence d'autocorrelation d'ordre 1 du ratio S/P",
      H1 = "autocorrelation du ratio S/P",
      stat_nom = "DW", stat = boot$stats_obs$DWr, loi = loi_ind, mc_nom = "DWr")
  add("E. H4 - independance et validite du MV (annexe XVII B(2)(f)(iv))",
      "Ljung-Box (retard 1) sur ratios bruts", "Ljung & Box (1978), Biometrika 65",
      base = "r", H0 = "rho_1 = 0 pour le ratio S/P", H1 = "autocorrelation au retard 1",
      stat_nom = "Q", stat = boot$stats_obs$LB1r, loi = loi_ind, mc_nom = "LB1r")
  add("E. H4 - independance et validite du MV (annexe XVII B(2)(f)(iv))",
      "Test des suites sur ratios bruts", "Wald & Wolfowitz (1940)",
      base = "r", H0 = "arrangement aleatoire des signes du ratio centre",
      H1 = "arrangement non aleatoire",
      stat_nom = "Z", stat = boot$stats_obs$Runsr, loi = loi_ind, mc_nom = "Runsr")
  add(fam, "Rupture de niveau (sup-F) sur ratios bruts",
      "Quandt (1960) / Chow (1960) ; Andrews (1993)", base = "r",
      H0 = "niveau du ratio S/P constant", H1 = "rupture de niveau du ratio S/P",
      stat_nom = "supF", stat = boot$stats_obs$supFr,
      loi = "supremum de processus -> Monte-Carlo", mc_nom = "supFr",
      detail = "Detecte un changement de regime du ratio, independamment du modele")
  add(fam, "Stabilite cumulee (OLS-CUSUM) sur ratios bruts",
      "Brown, Durbin & Evans (1975), JRSS B 37", base = "r",
      H0 = "constance du niveau du ratio S/P", H1 = "derive graduelle",
      stat_nom = "CUSUM", stat = boot$stats_obs$CUSUMr,
      loi = "sup |pont brownien| -> Monte-Carlo", mc_nom = "CUSUMr")
  add(fam, "Valeur aberrante isolee (Grubbs) sur ratios bruts",
      "Grubbs (1950, 1969), Technometrics 11", base = "r",
      H0 = "aucun ratio S/P aberrant", H1 = "exactement un ratio aberrant",
      stat_nom = "G", stat = boot$stats_obs$Grubbsr, loi = loi_ind,
      estim_nom = "rang du ratio extreme",
      estim = { g <- test_grubbs(u); if (is.finite(g$stat)) g$idx else NA_real_ },
      mc_nom = "Grubbsr",
      detail = "Identifie l'annee au boni/mali le plus atypique, sans passer par le modele")

  add(fam, "Leviers (hat values)", "Hoaglin & Welsch (1978), Amer. Statist. 32",
      type = "diagnostic", estim_nom = "max h_t", estim = max(hv),
      detail = sprintf("seuil conventionnel 2k/T = %.3f ; %d observation(s) au-dessus",
                       2 / T, sum(hv > 2 / T)),
      verdict = if (any(hv > 2 / T)) "ALERTE" else "OK")

  ## --- G. Robustesse de l'estimation -----------------------------------------
  fam <- "G. Robustesse de l'estimation"
  add(fam, "Condition du premier ordre |sum(pi_t*v_t)|/sum(pi_t)",
      "Diagnostic numerique (annexe XVII, par. 4-6)", type = "diagnostic",
      estim_nom = "FOC relative", estim = fit$foc,
      detail = "Doit etre nulle a la precision machine si l'optimisation a converge",
      verdict = if (!is.finite(fit$foc) || fit$foc > 1e-6) "ECHEC" else "OK")
  add(fam, "Convergence multi-demarrages", "Diagnostic numerique (L-BFGS-B)",
      type = "diagnostic",
      estim_nom = "part des demarrages a l'optimum", estim = fit$part_starts_convergents,
      detail = sprintf("code de retour optim = %d", fit$convergence),
      verdict = if (fit$part_starts_convergents < 0.5 || fit$convergence != 0) "ALERTE" else "OK")
  if (!is.null(fit$ecart_jackknife))
    add(fam, "Sensibilite au retrait d'une annee (jackknife)",
        "Quenouille (1949) / Tukey (1958)", type = "diagnostic",
        estim_nom = "ecart relatif max", estim = fit$ecart_jackknife,
        detail = sprintf("ecart maximal sur sigma_USP = %+.1f%%", 100 * fit$ecart_jackknife),
        verdict = if (fit$ecart_jackknife > 0.20) "ECHEC"
                  else if (fit$ecart_jackknife > 0.10) "ALERTE" else "OK")
  if (!is.null(fit$largeur_ic))
    add(fam, "Largeur relative de l'IC bootstrap 90%", "Efron (1979), Ann. Statist. 7",
        type = "diagnostic",
        estim_nom = "largeur / sigma_USP", estim = fit$largeur_ic,
        detail = sprintf("(q95 - q05) / sigma_USP = %.1f%%", 100 * fit$largeur_ic),
        verdict = if (fit$largeur_ic > 0.80) "ECHEC"
                  else if (fit$largeur_ic > 0.50) "ALERTE" else "OK")
  L
}


## =============================================================================
## 7. ORCHESTRATEUR


## =============================================================================
## 8. RESTITUTION
## =============================================================================


usp_exporter <- function(res, prefixe = "usp") {
  tt <- do.call(rbind, lapply(res$tests, function(t)
    data.frame(famille = t$famille, test = t$test, type = t$type,
               reference = t$reference,
               nom_statistique = t$stat_nom, statistique = t$stat,
               loi_sous_H0 = t$loi,
               nom_estimation = t$estim_nom, estimation = t$estim,
               p_value = t$p, p_bootstrap = t$p_mc,
               sens_du_test = t$sens,
               verdict = t$verdict, commentaire = t$detail,
               stringsAsFactors = FALSE)))
  cc <- do.call(rbind, lapply(res$controles, function(t)
    data.frame(test = t$test, verdict = t$verdict, detail = t$detail,
               stringsAsFactors = FALSE)))
  pp <- data.frame(res$parametre)
  utils::write.csv(tt, paste0(prefixe, "_tests.csv"), row.names = FALSE)
  utils::write.csv(cc, paste0(prefixe, "_controles_donnees.csv"), row.names = FALSE)
  utils::write.csv(pp, paste0(prefixe, "_parametre.csv"), row.names = FALSE)
  utils::write.csv(res$jackknife, paste0(prefixe, "_jackknife.csv"), row.names = FALSE)
  invisible(list(tests = tt, controles = cc, parametre = pp))
}



## =============================================================================
## 7bis. LECTURE D'UN JEU DE DONNEES AU FORMAT D'EXPORT (t, xt, yt)
## =============================================================================

# Interprete un data.frame deja charge (colonnes attendues : t, xt, yt -- le
# format exact ecrit par le bouton d'export de l'application) et en extrait les
# vecteurs xt, yt, tries selon t si cette colonne est presente et exploitable.
# La LECTURE du fichier (acces disque) reste du ressort de la couche Shiny ;
# cette fonction ne fait que l'interpretation structurelle du tableau une fois
# charge, ce qui la rend testable independamment de toute interface :
#     df  <- utils::read.csv("usp_donnees.csv")
#     res <- engine_lire_donnees_csv(df)
engine_lire_donnees_csv <- function(df) {
  err <- character(0)
  if (!is.data.frame(df) || !nrow(df))
    return(list(ok = FALSE, erreurs = "Fichier vide ou illisible comme tableau.",
                xt = NULL, yt = NULL, n = 0L))
  noms <- names(df)
  manquantes <- setdiff(c("xt", "yt"), noms)
  if (length(manquantes)) {
    return(list(ok = FALSE,
                erreurs = sprintf(
                  "Colonne(s) manquante(s) : %s. Colonnes attendues : t, xt, yt (format d'export de l'application). Colonnes presentes : %s.",
                  paste(manquantes, collapse = ", "), paste(noms, collapse = ", ")),
                xt = NULL, yt = NULL, n = 0L))
  }
  xt <- suppressWarnings(as.numeric(df$xt))
  yt <- suppressWarnings(as.numeric(df$yt))
  if (anyNA(xt) || anyNA(yt))
    err <- c(err, "Certaines valeurs de xt ou yt ne sont pas numeriques.")
  if ("t" %in% noms) {
    to <- suppressWarnings(as.numeric(df$t))
    if (!anyNA(to)) { o <- order(to); xt <- xt[o]; yt <- yt[o] }
  }
  list(ok = length(err) == 0, erreurs = err, xt = xt, yt = yt, n = length(xt))
}



## =============================================================================
## 7ter. ECHANGE AU FORMAT EXCEL (.xlsx)
##
## Un fichier .xlsx est une archive ZIP contenant du XML (norme ECMA-376,
## OOXML). Aucun paquet R specialise n'etant suppose disponible, le moteur
## embarque un lecteur et un ecrivain minimaux, suffisants pour des feuilles
## rectangulaires de nombres et de chaines, qui est exactement le besoin ici
## (series x_t / y_t, ou triangle de cumules).
##
## Si le paquet openxlsx est installe, il est utilise en priorite : son
## implementation est plus complete et mieux eprouvee. Les fonctions ci-dessous
## constituent un repli, non un remplacement.
## =============================================================================

.col_lettre <- function(i) {                       # 1 -> "A", 27 -> "AA"
  out <- character(0)
  while (i > 0) { r <- (i - 1) %% 26; out <- c(LETTERS[r + 1], out); i <- (i - 1) %/% 26 }
  paste(out, collapse = "")
}
.lettre_col <- function(s) {                       # "AA" -> 27
  ch <- utf8ToInt(toupper(s)) - 64L
  sum(ch * 26^rev(seq_along(ch) - 1))
}
.xml_echap <- function(x) {
  x <- gsub("&", "&amp;", x, fixed = TRUE)
  x <- gsub("<", "&lt;", x, fixed = TRUE)
  gsub(">", "&gt;", x, fixed = TRUE)
}

# Ecrit un data.frame dans un classeur .xlsx a une feuille. Les colonnes
# numeriques sont ecrites comme nombres, les autres comme chaines en ligne
# (inlineStr), ce qui evite d'avoir a gerer une table de chaines partagees.
engine_ecrire_xlsx <- function(df, chemin, feuille = "Donnees") {
  if (requireNamespace("openxlsx", quietly = TRUE)) {
    openxlsx::write.xlsx(df, chemin, sheetName = feuille)
    return(invisible(chemin))
  }
  df <- as.data.frame(df, stringsAsFactors = FALSE)
  nc <- ncol(df); nr <- nrow(df)
  cellule <- function(ligne, col, valeur) {
    ref <- paste0(.col_lettre(col), ligne)
    if (is.na(valeur)) return("")
    if (is.numeric(valeur))
      sprintf('<c r="%s"><v>%s</v></c>', ref, format(valeur, scientific = FALSE, trim = TRUE))
    else
      sprintf('<c r="%s" t="inlineStr"><is><t>%s</t></is></c>', ref, .xml_echap(as.character(valeur)))
  }
  lignes <- character(nr + 1)
  lignes[1] <- paste0('<row r="1">',
    paste(vapply(seq_len(nc), function(j) cellule(1, j, names(df)[j]), character(1)),
          collapse = ""), '</row>')
  for (i in seq_len(nr)) {
    cs <- vapply(seq_len(nc), function(j) {
      v <- df[[j]][i]
      cellule(i + 1, j, if (is.factor(v)) as.character(v) else v)
    }, character(1))
    lignes[i + 1] <- paste0('<row r="', i + 1, '">', paste(cs, collapse = ""), '</row>')
  }
  sheet <- paste0('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>',
    '<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">',
    '<sheetData>', paste(lignes, collapse = ""), '</sheetData></worksheet>')

  d <- file.path(tempdir(), paste0("xlsx_", as.integer(runif(1, 1, 1e9))))
  dir.create(file.path(d, "_rels"), recursive = TRUE, showWarnings = FALSE)
  dir.create(file.path(d, "xl", "_rels"), recursive = TRUE, showWarnings = FALSE)
  dir.create(file.path(d, "xl", "worksheets"), recursive = TRUE, showWarnings = FALSE)
  writeLines(paste0('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>',
    '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">',
    '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>',
    '<Default Extension="xml" ContentType="application/xml"/>',
    '<Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>',
    '<Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>',
    '</Types>'), file.path(d, "[Content_Types].xml"), useBytes = TRUE)
  writeLines(paste0('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>',
    '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">',
    '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>',
    '</Relationships>'), file.path(d, "_rels", ".rels"), useBytes = TRUE)
  writeLines(paste0('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>',
    '<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"',
    ' xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">',
    '<sheets><sheet name="', .xml_echap(feuille), '" sheetId="1" r:id="rId1"/></sheets></workbook>'),
    file.path(d, "xl", "workbook.xml"), useBytes = TRUE)
  writeLines(paste0('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>',
    '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">',
    '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/>',
    '</Relationships>'), file.path(d, "xl", "_rels", "workbook.xml.rels"), useBytes = TRUE)
  writeLines(sheet, file.path(d, "xl", "worksheets", "sheet1.xml"), useBytes = TRUE)

  wd <- setwd(d); on.exit(setwd(wd), add = TRUE)
  cible <- if (grepl("^(/|[A-Za-z]:)", chemin)) chemin else file.path(wd, chemin)
  if (file.exists(cible)) unlink(cible)
  st <- utils::zip(cible, c("[Content_Types].xml", "_rels", "xl"), flags = "-r9Xq")
  if (!identical(st, 0L)) stop("Echec de la creation du fichier .xlsx (commande zip indisponible ?).")
  invisible(cible)
}

# Lit la premiere feuille d'un classeur .xlsx et renvoie un data.frame, la
# premiere ligne etant traitee comme l'en-tete. Les colonnes entierement
# numeriques sont converties en numerique.
engine_lire_xlsx <- function(chemin, entete = TRUE) {
  if (requireNamespace("openxlsx", quietly = TRUE))
    return(openxlsx::read.xlsx(chemin, sheet = 1, colNames = entete))
  d <- file.path(tempdir(), paste0("unx_", as.integer(runif(1, 1, 1e9))))
  dir.create(d, recursive = TRUE, showWarnings = FALSE)
  utils::unzip(chemin, exdir = d)
  f <- list.files(file.path(d, "xl", "worksheets"), pattern = "\\.xml$", full.names = TRUE)
  if (!length(f)) stop("Classeur illisible : aucune feuille trouvee.")
  xml <- paste(readLines(f[1], warn = FALSE, encoding = "UTF-8"), collapse = "")
  # table des chaines partagees, si presente
  fs <- file.path(d, "xl", "sharedStrings.xml")
  partagees <- character(0)
  if (file.exists(fs)) {
    sx <- paste(readLines(fs, warn = FALSE, encoding = "UTF-8"), collapse = "")
    si <- regmatches(sx, gregexpr("<si>.*?</si>", sx))[[1]]
    partagees <- vapply(si, function(x) {
      t <- regmatches(x, gregexpr("<t[^>]*>.*?</t>", x))[[1]]
      paste(gsub("<[^>]*>", "", t), collapse = "")
    }, character(1))
  }
  cells <- regmatches(xml, gregexpr('<c [^>]*?/>|<c [^>]*?>.*?</c>', xml))[[1]]
  if (!length(cells)) return(data.frame())
  ref <- sub('.*r="([A-Z]+)([0-9]+)".*', "\\1|\\2", cells)
  col <- vapply(sub("\\|.*", "", ref), .lettre_col, numeric(1))
  lig <- as.integer(sub(".*\\|", "", ref))
  typ <- ifelse(grepl('t="[^"]*"', cells), sub('.*t="([^"]*)".*', "\\1", cells), "n")
  val <- rep(NA_character_, length(cells))
  vv <- regmatches(cells, regexpr("<v>.*?</v>", cells))
  ok <- grepl("<v>", cells)
  val[ok] <- gsub("<[^>]*>", "", vv)
  isx <- grepl("<is>", cells)
  if (any(isx)) val[isx] <- gsub("<[^>]*>", "",
    regmatches(cells[isx], regexpr("<t[^>]*>.*?</t>", cells[isx])))
  s <- typ == "s" & !is.na(val)
  if (any(s)) val[s] <- partagees[as.integer(val[s]) + 1L]
  m <- matrix(NA_character_, max(lig), max(col))
  m[cbind(lig, col)] <- val
  if (entete) {
    nm <- m[1, ]; corps <- m[-1, , drop = FALSE]
    nm[is.na(nm) | nm == ""] <- paste0("V", which(is.na(nm) | nm == ""))
  } else { nm <- paste0("V", seq_len(ncol(m))); corps <- m }
  df <- as.data.frame(corps, stringsAsFactors = FALSE)
  names(df) <- make.unique(nm)
  for (j in seq_along(df)) {
    num <- suppressWarnings(as.numeric(df[[j]]))
    if (all(is.na(num) == is.na(df[[j]]))) df[[j]] <- num
  }
  df
}

## =============================================================================
## 8. CONTROLES DE VALIDITE (cote MOTEUR, independants de toute interface)
## =============================================================================

# Verifie que le couple (xt, yt) est exploitable par les methodes de l'annexe
# XVII. Ce controle a une signification statistique et actuarielle : il est donc
# implemente ICI, afin que le moteur reste sur meme appele hors de Shiny.
# Retourne une liste : $ok (logique), $erreurs (bloquantes), $avertissements.
engine_valider_donnees <- function(xt, yt, T_min = 5) {
  err <- character(0); avt <- character(0)
  if (!is.numeric(xt) || !is.numeric(yt))
    err <- c(err, "xt et yt doivent etre numeriques.")
  if (length(xt) != length(yt))
    err <- c(err, sprintf("xt (%d valeurs) et yt (%d valeurs) doivent avoir la meme longueur.",
                          length(xt), length(yt)))
  if (anyNA(xt) || anyNA(yt))
    err <- c(err, "Valeurs manquantes : le calibrage exige des series completes (art. 19).")
  if (length(xt) && any(xt <= 0, na.rm = TRUE))
    err <- c(err, "Toutes les valeurs de xt doivent etre strictement positives.")
  if (length(yt) && any(yt <= 0, na.rm = TRUE))
    err <- c(err, "Toutes les valeurs de yt doivent etre strictement positives (loi lognormale).")
  if (length(xt) < T_min)
    err <- c(err, sprintf("Annexe XVII, B/C(2)(b) : au moins %d annees consecutives (T = %d).",
                          T_min, length(xt)))
  if (!length(err)) {
    r <- yt / xt
    if (any(r <= 0 | r >= 5))
      avt <- c(avt, "Ratio y/x hors de la plage plausible ]0 ; 5[ : verifier les unites.")
    if (max(xt) / min(xt) >= 10)
      avt <- c(avt, "Amplitude des volumes >= 10 : rupture de perimetre possible.")
    if (anyDuplicated(data.frame(xt, yt)) > 0)
      avt <- c(avt, "Couples (xt, yt) dupliques detectes.")
    if (length(xt) < 10)
      avt <- c(avt, sprintf(paste("T = %d : credibilite partielle et lois asymptotiques peu",
                                  "fiables. Privilegier les p-values exactes ou Monte-Carlo."),
                            length(xt)))
  }
  list(ok = length(err) == 0, erreurs = err, avertissements = avt, T = length(xt))
}


## =============================================================================
## 9. QUANTITES NUMERIQUES DES GRAPHIQUES
## =============================================================================

# Toutes les quantites tracees sont calculees ICI. La couche d'affichage ne fait
# que les representer (choix des couleurs, titres, axes).
# Surface de la fonction objectif sur une grille (delta, gamma). Elle sert a
# visualiser la geometrie de l'optimisation, notamment lorsque delta est au
# bord : un plateau plat en delta signifie que la structure de variance n'est
# pas identifiee par les donnees, ce que le seul profil ne montre pas toujours.
engine_surface_objectif <- function(fit, n_delta = 45, n_gamma = 45,
                                    marge_gamma = 1.6) {
  gd <- seq(0, 1, length.out = n_delta)
  gg <- seq(fit$gamma - marge_gamma, fit$gamma + marge_gamma, length.out = n_gamma)
  M <- outer(gd, gg, Vectorize(function(d, g)
    usp_objectif(c(d, g), fit$x, fit$y, fit$xbar)))
  list(delta = gd, gamma = gg, objectif = M,
       delta_opt = fit$delta, gamma_opt = fit$gamma, objectif_opt = fit$obj_min,
       au_bord = isTRUE(fit$delta_au_bord),
       # Amplitude relative de l'objectif le long de delta, a gamma optimal :
       # mesure quantitative de la platitude (identifiabilite de delta).
       amplitude_delta = {
         v <- vapply(gd, function(d) usp_objectif(c(d, fit$gamma), fit$x, fit$y,
                                                  fit$xbar), numeric(1))
         diff(range(v))
       })
}

# --- Diagnostics d'influence de la regression (methode lognormale) -----------
# La regression de reference est le modele reglementaire contraint
# y_t = beta x_t (sans constante), a k = 1 parametre. Pour ce modele :
#   levier      h_t = x_t^2 / somme(x_i^2)        (somme des h_t = k = 1)
#   residu standardise  e_t / (s sqrt(1 - h_t))
#   distance de Cook    D_t = r_t^2 * h_t / (k (1 - h_t))
# On y ajoute la mesure d'influence la plus parlante pour le dossier :
# l'effet du retrait de chaque annee sur le parametre final sigma_USP, deja
# calcule par le jackknife.
engine_influence <- function(fit, jackknife = NULL, sigma_usp = NULL) {
  x <- fit$x; y <- fit$y; T <- fit$T
  m <- stats::lm(y ~ x - 1)
  k <- 1L
  h <- stats::hatvalues(m)
  e <- stats::residuals(m)
  s <- sqrt(sum(e^2) / (T - k))
  r_std <- e / (s * sqrt(pmax(1 - h, .Machine$double.eps)))
  cook <- stats::cooks.distance(m)
  d <- data.frame(
    t = seq_len(T), x = x, y = y,
    levier = unname(h), residu_std = unname(r_std), cook = unname(cook),
    z = fit$z,
    seuil_levier = 2 * k / T, seuil_cook = 4 / T,
    stringsAsFactors = FALSE)
  d$influent <- d$cook > d$seuil_cook
  d$fort_levier <- d$levier > d$seuil_levier
  if (!is.null(jackknife) && !is.null(sigma_usp)) {
    d$sigma_usp_sans_t <- jackknife$sigma_usp
    d$ecart_sigma <- (jackknife$sigma_usp - sigma_usp) / sigma_usp
  }
  d
}

# Courbes d'iso-distance de Cook, tracees dans le plan (levier, residu
# standardise). Pour un niveau D fixe : r = +/- sqrt(D k (1 - h) / h).
engine_contours_cook <- function(T, k = 1L, niveaux = c(0.5, 1), n = 200) {
  hmax <- 0.99
  h <- seq(0.005, hmax, length.out = n)
  do.call(rbind, lapply(niveaux, function(D) {
    r <- sqrt(D * k * (1 - h) / h)
    rbind(data.frame(niveau = D, signe = "+", levier = h, residu = r),
          data.frame(niveau = D, signe = "-", levier = h, residu = -r))
  }))
}

engine_plots_data <- function(fit, boot, profil, jackknife = NULL,
                              sigma_usp = NULL) {
  T <- fit$T; x <- fit$x; z <- fit$z
  qq <- stats::qqnorm(z, plot.it = FALSE)
  # Droite de reference du QQ-plot (quartiles), comme stats::qqline
  qy <- stats::quantile(z, c(0.25, 0.75)); qx <- stats::qnorm(c(0.25, 0.75))
  pente_qq <- diff(qy) / diff(qx); ord_qq <- qy[1] - pente_qq * qx[1]

  # Enveloppe de simulation du QQ-plot : quantiles des statistiques d'ordre
  # simulees sous le modele ajuste (calibre la lecture visuelle a T faible).
  set.seed(20260831)
  ordres <- replicate(499, sort(stats::rnorm(T)))
  env <- t(apply(ordres, 1, stats::quantile, probs = c(0.05, 0.95)))

  # QQ-plot a deux echantillons (faible vs fort volume)
  qq2 <- NULL
  if (stats::sd(x) > 0) {
    g <- x > stats::median(x)
    if (sum(g) >= 3 && sum(!g) >= 3) {
      nn <- min(sum(g), sum(!g)); pr <- stats::ppoints(nn)
      qq2 <- data.frame(faible = stats::quantile(sort(z[!g]), pr, type = 7),
                        fort   = stats::quantile(sort(z[g]),  pr, type = 7))
    }
  }
  lo <- stats::lowess(x, sqrt(abs(z)))
  list(
    ajustement = data.frame(x = x, y = fit$y, ajuste = fit$beta * x),
    beta = fit$beta,
    ratio = data.frame(t = seq_len(T), ratio = fit$y / x, niveau = fit$beta),
    qqnorm = data.frame(theorique = qq$x, empirique = qq$y,
                        env_bas = env[order(order(qq$x)), 1],
                        env_haut = env[order(order(qq$x)), 2]),
    qqline = c(ordonnee = unname(ord_qq), pente = unname(pente_qq)),
    qq2ech = qq2,
    spread = data.frame(x = x, racine_abs_z = sqrt(abs(z))),
    spread_lisse = data.frame(x = lo$x, y = lo$y),
    residus = data.frame(x = x, z = z, t = seq_len(T)),
    profil_delta = data.frame(delta = profil$delta_grid, objectif = profil$delta_obj),
    profil_gamma = data.frame(gamma = profil$gamma_grid, objectif = profil$gamma_obj),
    surface = engine_surface_objectif(fit),
    influence = engine_influence(fit, jackknife, sigma_usp),
    contours_cook = engine_contours_cook(T),
    delta_estime = fit$delta, gamma_estime = fit$gamma,
    sigma_boot = boot$sigma_boot, delta_boot = boot$delta_boot
  )
}


## =============================================================================
## 11. METHODE DU RISQUE DE RESERVE No 2 (MERZ-WUTHRICH)
##     Reglement delegue (UE) 2015/35, annexe XVII, section D.
##     Toutes les formules ci-dessous sont la transcription litterale du texte
##     publie au JOUE L 12 du 17.1.2015, p. 276-278.
##
##     NOTATION DU REGLEMENT (section D, paragraphe 3)
##       i = 0, ..., I : annees d'accident (0 = la plus ancienne)
##       j = 0, ..., J : annees de developpement
##       C(i,j)        : sinistres cumules
##     Le triangle est stocke dans une matrice (I+1) x (J+1), les cellules non
##     observees (i + j > I) valant NA.
##
##     RESTRICTION D'IMPLEMENTATION : on impose I = J (triangle carre). Le
##     paragraphe 2(e) autorise I >= J, mais la formule du paragraphe 4 fait
##     intervenir C(i, I-i), qui n'est definie que si I - i <= J. Le cas I > J
##     produirait un trapeze dont le texte ne precise pas le traitement ; il est
##     donc refuse explicitement plutot que traite par convention implicite.
## =============================================================================

# --- Controles de recevabilite : annexe XVII, section D, paragraphe 2 --------
mw_valider_triangle <- function(tri, T_min = 5) {
  err <- character(0); avt <- character(0)
  if (!is.matrix(tri) || !is.numeric(tri))
    return(list(ok = FALSE, erreurs = "Le triangle doit etre une matrice numerique.",
                I = NA, J = NA))
  I <- nrow(tri) - 1L; J <- ncol(tri) - 1L
  if (nrow(tri) < T_min)
    err <- c(err, sprintf("D(2)(b) : au moins %d annees d'accident consecutives (%d fournies).",
                          T_min, nrow(tri)))
  if (ncol(tri) < T_min)
    err <- c(err, sprintf("D(2)(c) : au moins %d annees de developpement pour la premiere annee d'accident (%d fournies).",
                          T_min, ncol(tri)))
  if (nrow(tri) < ncol(tri))
    err <- c(err, "D(2)(e) : le nombre d'annees d'accident ne peut etre inferieur au nombre d'annees de developpement.")
  if (I != J)
    err <- c(err, sprintf("Triangle non carre (I = %d, J = %d) : cas non couvert par la formule du paragraphe 4 (voir la note d'implementation).", I, J))
  if (!length(err)) {
    # Structure attendue : partie superieure gauche observee, reste manquant.
    for (i in 0:I) for (j in 0:J) {
      obs <- (i + j <= I)
      v <- tri[i + 1, j + 1]
      if (obs && (is.na(v) || !is.finite(v)))
        err <- c(err, sprintf("Cellule observee manquante en (i=%d, j=%d).", i, j))
      if (obs && is.finite(v) && v <= 0)
        err <- c(err, sprintf("Cumul non strictement positif en (i=%d, j=%d).", i, j))
    }
  }
  if (!length(err)) {
    # Le paragraphe 2(h)(iii) suppose des cumules croissants ; un recul traduit
    # un boni de liquidation ou un recouvrement, licite mais a signaler.
    for (i in 0:I) {
      d <- I - i
      if (d >= 1) {
        v <- tri[i + 1, 1:(d + 1)]
        if (any(diff(v) < 0))
          avt <- c(avt, sprintf("Annee d'accident %d : cumul decroissant (recouvrement ou boni).", i))
      }
    }
    if (nrow(tri) < 10)
      avt <- c(avt, sprintf("I + 1 = %d annees d'accident : credibilite partielle et estimateurs de variance tres bruites en fin de triangle.",
                            nrow(tri)))
  }
  list(ok = length(err) == 0, erreurs = err, avertissements = avt, I = I, J = J)
}

# --- Facteurs de developpement et variances : paragraphes 4 et 5 -------------
# Renvoie f_chapeau, sigma2_chapeau, Q_chapeau, S, S', les cumules estimes
# C_chapeau et la reserve par annee d'accident.
mw_ajuster <- function(tri) {
  I <- nrow(tri) - 1L; J <- ncol(tri) - 1L

  # f_j = somme_{i=0}^{I-j-1} C(i,j+1) / somme_{i=0}^{I-j-1} C(i,j)   [par. 4(c)]
  f <- rep(NA_real_, J)                       # f[j+1] correspond a f_j
  for (j in 0:(J - 1)) {
    idx <- 0:(I - j - 1)
    f[j + 1] <- sum(tri[idx + 1, j + 2]) / sum(tri[idx + 1, j + 1])
  }

  # sigma2_j, j = 0..J-2  [par. 5(d)(ii), premiere ligne]
  s2 <- rep(NA_real_, J)                      # s2[j+1] correspond a sigma2_j
  if (J >= 2) for (j in 0:(J - 2)) {
    idx <- 0:(I - j - 1)
    if (length(idx) >= 2)
      s2[j + 1] <- sum(tri[idx + 1, j + 1] *
                       (tri[idx + 1, j + 2] / tri[idx + 1, j + 1] - f[j + 1])^2) / (I - j - 1)
  }
  # sigma2_{J-1} = min(sigma2_{J-2}, sigma2_{J-3}, sigma2_{J-2}^2 / sigma2_{J-3})
  # [par. 5(d)(ii), seconde ligne]. Le sigma^4 du texte designe le carre de
  # sigma2_{J-2}, la formule etant l'extrapolation geometrique usuelle.
  if (J >= 3 && is.finite(s2[J - 1]) && is.finite(s2[J - 2]) && s2[J - 2] > 0)
    s2[J] <- min(s2[J - 1], s2[J - 2], s2[J - 1]^2 / s2[J - 2])
  else if (J >= 2 && is.finite(s2[J - 1]))
    s2[J] <- s2[J - 1]

  # C_chapeau(i,j) : observe si j <= I-i, projete au-dela   [par. 4(c)]
  Ch <- tri
  for (i in 0:I) {
    d <- I - i
    if (d < J) for (j in (d + 1):J)
      Ch[i + 1, j + 1] <- Ch[i + 1, j] * f[j]
  }

  # Q_j = sigma2_j / f_j^2   [par. 5(d)]
  Q <- s2 / f^2
  # S_j = somme_{i=0}^{I-j-1} C(i,j) ;  S'_j = somme_{i=0}^{I-j} C(i,j)
  S <- Sp <- rep(NA_real_, J + 1)
  for (j in 0:J) {
    if (I - j - 1 >= 0) S[j + 1]  <- sum(tri[(0:(I - j - 1)) + 1, j + 1])
    Sp[j + 1] <- sum(tri[(0:(I - j)) + 1, j + 1])
  }

  derniers <- vapply(0:I, function(i) tri[i + 1, I - i + 1], numeric(1))
  ultimes  <- Ch[, J + 1]
  list(I = I, J = J, tri = tri, f = f, sigma2 = s2, Q = Q, S = S, Sp = Sp,
       C_chapeau = Ch, dernier_observe = derniers, ultime = ultimes,
       reserve_par_annee = ultimes - derniers,
       reserve = sum(ultimes - derniers))
}

# --- Erreur quadratique moyenne de prediction : paragraphe 5 -----------------
# Formule telle qu'imprimee au paragraphe 5 de la VERSION CONSOLIDEE en
# vigueur. La pagination "JOUE L 12/277" qui circulait ici n'a jamais ete
# verifiee (ADR 0005) : elle est retiree plutot que reprise.
#
# MSEP = somme_{i=1}^{I} C^(i,J)^2
#          * ( Q_{I-i}/C(i,I-i)
#              + Q_{I-i}/S_{I-i} + somme_{j=I-i+1}^{J-1} (C(I-j,j)/S'_j)*(Q_j/S_j) )
#      + 2 * somme_{i=1}^{I} somme_{k=i+1}^{I} C^(i,J) * C^(k,J)
#          * ( Q_{I-i}/S_{I-i} + somme_{j=I-i+1}^{J-1} (C(I-j,j)/S'_j)*(Q_j/S_j) )
#
# Le crochet, note Delta_i ci-dessous, apparait DEUX fois : dans la premiere
# somme, a cote du terme de variance de processus Q_{I-i}/C(i,I-i), et dans la
# double somme, affectee du facteur 2. Les deux transcriptions internes
# anterieures (moteur et documentation) omettaient les termes diagonaux
# C^(i,J)^2 * Delta_i et le facteur 2 : voir l'issue #7, commentaire
# "M1 tranche sur piece", qui etablit la lettre du texte et verifie que la
# formule ci-dessus coincide avec l'erreur a un an de Merz-Wuthrich (2008)
# a 3e-15 pres sur le triangle de Taylor & Ashe (ChainLadder::CDR).
#
# DECOUPAGE RESTITUE (choix de presentation, pas une prescription du texte) :
#   terme_variance    = somme_i C^(i,J)^2 * Q_{I-i}/C(i,I-i)  -- variance de
#                       processus seule, attribuable annee par annee ;
#   terme_covariance  = somme_i C^(i,J)^2 * Delta_i
#                       + 2 * somme_{i<k} C^(i,J) C^(k,J) * Delta_i  -- erreur
#                       d'estimation, y compris ses termes diagonaux.
# La somme des deux est exactement la MSEP du texte. Ce decoupage
# processus / estimation a un sens statistique et laisse a terme_variance le
# sens qu'il avait deja, dont depend mw_contributions() (parts par annee du
# graphique des contributions).
mw_msep <- function(aj) {
  I <- aj$I; J <- aj$J; tri <- aj$tri
  Ch <- aj$C_chapeau; Q <- aj$Q; S <- aj$S; Sp <- aj$Sp
  Cu <- Ch[, J + 1]                                  # C^(i,J)
  Cd <- aj$dernier_observe                           # C(i, I-i)

  # Delta_i : crochet d'erreur d'estimation de l'annee d'accident i.
  # Attention : en R, a:b produit une sequence DESCENDANTE lorsque a > b. La
  # borne superieure de la somme en j doit donc etre testee avant la boucle.
  Delta <- function(i) {
    v <- Q[I - i + 1] / S[I - i + 1]
    if ((I - i + 1) <= (J - 1)) for (j in (I - i + 1):(J - 1))
      v <- v + (tri[I - j + 1, j + 1] / Sp[j + 1]) * (Q[j + 1] / S[j + 1])
    v
  }
  Dl <- vapply(1:I, Delta, numeric(1))               # Dl[i] = Delta_i

  # Variance de processus : somme_i C^(i,J)^2 * Q_{I-i} / C(i,I-i)
  t1 <- 0
  for (i in 1:I) t1 <- t1 + Cu[i + 1]^2 * Q[I - i + 1] / Cd[i + 1]

  # Erreur d'estimation : termes diagonaux C^(i,J)^2 * Delta_i ...
  t2 <- 0
  for (i in 1:I) t2 <- t2 + Cu[i + 1]^2 * Dl[i]
  # ... puis les termes croises, comptes une fois et doubles (meme piege sur
  # (i+1):I lorsque i = I : la borne est testee avant d'entrer dans la boucle).
  for (i in 1:I) if (i < I) for (k in (i + 1):I)
    t2 <- t2 + 2 * Cu[i + 1] * Cu[k + 1] * Dl[i]

  list(msep = t1 + t2, terme_variance = t1, terme_covariance = t2)
}

# --- Parametre propre : paragraphe 4 -----------------------------------------
# sigma(res,s,USP) = c * sqrt(MSEP) / somme_{i=0}^{I}(C^(i,J) - C(i,I-i))
#                    + (1 - c) * sigma(res,s)
mw_parametre <- function(aj, msep, sigma_standard, bareme = "court") {
  T_cred <- aj$I + 1L                       # duree = nombre d'annees d'accident
  cred <- usp_credibilite(T_cred, bareme)   # section G(3)(c)
  reserve <- aj$reserve
  sigma_est <- sqrt(msep) / reserve
  list(reserve = reserve, msep = msep, racine_msep = sqrt(msep),
       sigma_estime = sigma_est, credibilite = cred,
       sigma_standard = sigma_standard,
       sigma_usp = cred * sigma_est + (1 - cred) * sigma_standard,
       variation_relative = (cred * sigma_est + (1 - cred) * sigma_standard) /
                            sigma_standard - 1,
       duree_credibilite = T_cred)
}

# --- Residus standardises de Mack --------------------------------------------
# r(i,j) = sqrt(C(i,j)) * ( C(i,j+1)/C(i,j) - f_j ) / sigma_j
# Sous les hypotheses D(2)(h)(iii) et (iv), ces residus sont centres, de
# variance approximativement unitaire et mutuellement non correles. Ce sont eux
# qui servent de support aux tests des sections H1, H2 et H4 adaptees.
mw_residus <- function(aj) {
  I <- aj$I; J <- aj$J; tri <- aj$tri
  out <- data.frame()
  for (j in 0:(J - 1)) {
    if (!is.finite(aj$sigma2[j + 1]) || aj$sigma2[j + 1] <= 0) next
    idx <- 0:(I - j - 1)
    if (length(idx) < 2) next
    Cij <- tri[idx + 1, j + 1]; Cij1 <- tri[idx + 1, j + 2]
    out <- rbind(out, data.frame(
      i = idx, j = j, calendrier = idx + j,
      C = Cij, F = Cij1 / Cij, f_chapeau = aj$f[j + 1],
      sigma_j = sqrt(aj$sigma2[j + 1]),
      residu = sqrt(Cij) * (Cij1 / Cij - aj$f[j + 1]) / sqrt(aj$sigma2[j + 1]),
      stringsAsFactors = FALSE))
  }
  out
}

# --- Test des effets d'annee calendaire (Mack) --------------------------------
# Mack (1994), "Which stochastic model is underlying the chain ladder method ?",
# Insurance: Mathematics and Economics 15, 133-138 ; repris dans Mack (1993),
# ASTIN Bulletin 23(2), 213-225.
# Principe : dans chaque colonne j, les facteurs observes sont classes en
# "grands" (L) et "petits" (S) par rapport a leur mediane ; sous H0 d'absence
# d'effet calendaire, la repartition des L et des S le long de chaque diagonale
# est purement aleatoire. On note Z_k = min(L_k, S_k) sur la diagonale k.
.mack_moments_Z <- function(n) {
  # Loi exacte de Z = min(L, S) lorsque n etiquettes sont reparties au hasard :
  # L ~ Binomiale(n, 1/2) et Z = min(L, n-L).
  if (n < 2) return(c(E = 0, V = 0))
  m <- floor((n - 1) / 2)
  E <- n / 2 - choose(n - 1, m) * n / 2^n
  V <- n * (n - 1) / 4 - choose(n - 1, m) * n * (n - 1) / 2^n + E - E^2
  c(E = E, V = max(V, 0))
}

mw_test_annees_calendaires <- function(aj) {
  I <- aj$I; J <- aj$J; tri <- aj$tri
  etiq <- data.frame()
  for (j in 0:(J - 1)) {
    idx <- 0:(I - j - 1)
    if (length(idx) < 2) next
    F <- tri[idx + 1, j + 2] / tri[idx + 1, j + 1]
    md <- stats::median(F)
    lab <- ifelse(F > md, "L", ifelse(F < md, "S", "*"))
    etiq <- rbind(etiq, data.frame(i = idx, j = j, diag = idx + j, lab = lab,
                                   stringsAsFactors = FALSE))
  }
  etiq <- etiq[etiq$lab != "*", , drop = FALSE]
  if (!nrow(etiq)) return(list(stat = NA_real_, p = NA_real_, Z = NA_real_))
  agg <- lapply(split(etiq$lab, etiq$diag), function(v) {
    L <- sum(v == "L"); S <- sum(v == "S"); n <- L + S
    m <- .mack_moments_Z(n)
    c(Z = min(L, S), E = unname(m["E"]), V = unname(m["V"]), n = n)
  })
  A <- do.call(rbind, agg)
  A <- A[A[, "n"] >= 2, , drop = FALSE]
  if (!nrow(A)) return(list(stat = NA_real_, p = NA_real_, Z = NA_real_))
  Z <- sum(A[, "Z"]); EZ <- sum(A[, "E"]); VZ <- sum(A[, "V"])
  if (!is.finite(VZ) || VZ <= 0) return(list(stat = NA_real_, p = NA_real_, Z = Z))
  st <- (Z - EZ) / sqrt(VZ)
  list(stat = st, p = .p_borne(2 * (1 - stats::pnorm(abs(st)))),
       Z = Z, E = EZ, V = VZ, detail = A)
}

# --- Test de correlation entre annees de developpement adjacentes (Mack) -----
# Mack (1997) / Mack (1993), ASTIN Bulletin 23(2). L'hypothese D(2)(h)(ii)
# suppose les facteurs de developpement successifs non correles. On mesure la
# correlation de rang de Spearman entre colonnes adjacentes, agregee sur le
# triangle. La loi sous H0 dependant de la geometrie du triangle, la p-value
# est obtenue par permutation (voir mw_bootstrap).
mw_stat_correlation_dev <- function(aj) {
  I <- aj$I; J <- aj$J; tri <- aj$tri
  Ts <- w <- numeric(0)
  for (k in 1:(J - 1)) {
    idx <- 0:(I - k - 1)
    if (length(idx) < 3) next
    Fk  <- tri[idx + 1, k + 1] / tri[idx + 1, k]        # colonne k-1 -> k
    Fk1 <- tri[idx + 1, k + 2] / tri[idx + 1, k + 1]    # colonne k -> k+1
    if (stats::sd(Fk) == 0 || stats::sd(Fk1) == 0) next
    rho <- suppressWarnings(stats::cor(rank(Fk), rank(Fk1)))
    if (!is.finite(rho)) next
    Ts <- c(Ts, rho); w <- c(w, length(idx) - 1)
  }
  if (!length(Ts)) return(list(stat = NA_real_, T = NA_real_))
  list(stat = sum(w * Ts) / sum(w), T = Ts, poids = w)
}


# Pente commune de F(i,j) sur C(i,j) A EFFET DE COLONNE FIXE, ponderee par
# C(i,j) conformement a l'hypothese de variance M2. Renvoie la statistique de
# Student de la pente, ou NA si le modele n'est pas estimable.
.mw_lm_intra <- function(res) {
  if (nrow(res) < 4 || stats::sd(res$C) == 0) return(NULL)
  # Ponderation des MOINDRES CARRES GENERALISES : Var(F(i,j)) = sigma_j^2 /
  # C(i,j), donc le poids exact est C(i,j) / sigma_j^2. Ponderer par C(i,j)
  # seul serait insuffisant : sigma_j^2 varie de plusieurs ordres de grandeur
  # entre la premiere et la derniere colonne, l'echelle residuelle serait
  # dominee par les premieres et le test deviendrait inoperant (verifie par
  # simulation : aucun rejet sous H0).
  if (!("sigma_j" %in% names(res)) || any(!is.finite(res$sigma_j)) ||
      any(res$sigma_j <= 0)) return(NULL)
  res$w <- res$C / res$sigma_j^2
  if (length(unique(res$j)) < 2)
    m <- try(stats::lm(F ~ C, weights = w, data = res), silent = TRUE)
  else
    m <- try(stats::lm(F ~ factor(j) + C, weights = w, data = res), silent = TRUE)
  if (inherits(m, "try-error")) return(NULL)
  co <- summary(m)$coefficients
  if (!("C" %in% rownames(co))) return(NULL)
  co["C", ]
}
.mw_pente_intra <- function(res) {
  co <- .mw_lm_intra(res)
  if (is.null(co)) NA_real_ else unname(co[3])
}

# --- Tests specifiques de l'hypothese (iii) de l'annexe XVII, D(2)(h) --------
# L'enonce reglementaire porte "pour TOUTES les annees d'accident" :
#   E[C(i,j+1) | C(i,j)] = f_j C(i,j)
# Il comporte donc DEUX exigences distinctes, testables separement :
#   (a) une proportionnalite SANS CONSTANTE, colonne par colonne ;
#   (b) un facteur f_j COMMUN a toutes les annees d'accident de la colonne.
# Une regression unique agregee sur l'ensemble du triangle ne teste ni l'une ni
# l'autre : elle melange des colonnes d'echelles tres differentes.
#
# Remarque (Mack, 1993, section 3) : la regression ponderee de C(i,j+1) sur
# C(i,j) SANS constante et de poids 1/C(i,j) a pour estimateur des moindres
# carres exactement le facteur chain-ladder f_j. C'est donc la regression de
# reference, et ajouter une constante fournit le test naturel de (a).

# Combinaison de p-values independantes par la methode de Fisher (1932) :
#   X = -2 * somme(ln p_k) suit une loi du khi-deux a 2K degres de liberte.
# ATTENTION : les colonnes adjacentes partagent la colonne C(., j+1), de sorte
# que l'independance n'est qu'approchee. La p-value combinee est donc rapportee
# comme NON simulee et indicative ; la p-value de reference reste celle du
# bootstrap de residus.
.fisher_combine <- function(p) {
  p <- p[is.finite(p) & p > 0 & p <= 1]
  if (length(p) < 2) return(list(stat = NA_real_, p = NA_real_, K = length(p)))
  X <- -2 * sum(log(p))
  list(stat = X, p = .p_borne(1 - stats::pchisq(X, 2 * length(p))), K = length(p))
}

# (a) Nullite de l'ordonnee a l'origine, colonne par colonne.
# Regression ponderee C(i,j+1) = a_j + b_j C(i,j), poids 1/C(i,j).
mw_test_ordonnee_origine <- function(aj) {
  I <- aj$I; J <- aj$J; tri <- aj$tri
  det <- data.frame()
  for (j in 0:(J - 1)) {
    idx <- 0:(I - j - 1)
    if (length(idx) < 3) next                    # 2 parametres + 1 ddl minimum
    C0 <- tri[idx + 1, j + 1]; C1 <- tri[idx + 1, j + 2]
    m <- try(summary(stats::lm(C1 ~ C0, weights = 1 / C0)), silent = TRUE)
    if (inherits(m, "try-error") || nrow(m$coefficients) < 2) next
    det <- rbind(det, data.frame(
      j = j, n = length(idx),
      a = m$coefficients[1, 1], se_a = m$coefficients[1, 2],
      t = m$coefficients[1, 3], p = m$coefficients[1, 4],
      b = m$coefficients[2, 1], f_cl = aj$f[j + 1], stringsAsFactors = FALSE))
  }
  if (!nrow(det)) return(list(stat = NA_real_, p = NA_real_, detail = det))
  fc <- .fisher_combine(det$p)
  list(stat = fc$stat, p = fc$p, K = fc$K, detail = det,
       t_max = det$t[which.max(abs(det$t))], j_max = det$j[which.max(abs(det$t))])
}

# (b) Homogeneite de f_j entre annees de survenance.
# Si f_j est commun a toutes les annees d'accident, les facteurs individuels
# F(i,j) d'une meme colonne ne doivent presenter aucune tendance en i.
# Correlation de rang de Spearman entre F(i,j) et i, colonne par colonne.
mw_test_homogeneite_f <- function(aj) {
  I <- aj$I; J <- aj$J; tri <- aj$tri
  det <- data.frame()
  for (j in 0:(J - 1)) {
    idx <- 0:(I - j - 1)
    if (length(idx) < 4) next
    F <- tri[idx + 1, j + 2] / tri[idx + 1, j + 1]
    if (stats::sd(F) == 0) next
    ct <- suppressWarnings(stats::cor.test(F, idx, method = "spearman", exact = FALSE))
    det <- rbind(det, data.frame(j = j, n = length(idx),
      rho = unname(ct$estimate), p = ct$p.value, stringsAsFactors = FALSE))
  }
  if (!nrow(det)) return(list(stat = NA_real_, p = NA_real_, detail = det))
  fc <- .fisher_combine(det$p)
  list(stat = fc$stat, p = fc$p, K = fc$K, detail = det)
}

# (c) Absence de courbure : terme quadratique dans la regression ponderee.
# Une courbure significative contredit la LINEARITE, meme si la constante est
# nulle : E[C(i,j+1)|C(i,j)] ne serait alors pas proportionnelle a C(i,j).
mw_test_courbure <- function(aj) {
  I <- aj$I; J <- aj$J; tri <- aj$tri
  det <- data.frame()
  for (j in 0:(J - 1)) {
    idx <- 0:(I - j - 1)
    if (length(idx) < 4) next                    # 3 parametres + 1 ddl
    C0 <- tri[idx + 1, j + 1]; C1 <- tri[idx + 1, j + 2]
    if (stats::sd(C0) == 0) next
    m <- try(summary(stats::lm(C1 ~ C0 + I(C0^2), weights = 1 / C0)), silent = TRUE)
    if (inherits(m, "try-error") || nrow(m$coefficients) < 3) next
    det <- rbind(det, data.frame(j = j, n = length(idx),
      c2 = m$coefficients[3, 1], t = m$coefficients[3, 3],
      p = m$coefficients[3, 4], stringsAsFactors = FALSE))
  }
  if (!nrow(det)) return(list(stat = NA_real_, p = NA_real_, detail = det))
  fc <- .fisher_combine(det$p)
  list(stat = fc$stat, p = fc$p, K = fc$K, detail = det)
}

# (d) Stabilite du facteur selon la ponderation : famille alpha.
#   f_j^(alpha) = somme_i C(i,j)^alpha F(i,j) / somme_i C(i,j)^alpha
#   alpha = 0 : moyenne simple des facteurs individuels
#   alpha = 1 : facteur chain-ladder du reglement
#   alpha = 2 : ponderation par le carre du volume
# Sous l'hypothese (iii), les trois estimateurs visent le MEME f_j : une
# divergence marquee signale que l'esperance n'est pas proportionnelle a
# C(i,j), ou que la ponderation en C(i,j) de l'hypothese (iv) est inadaptee.
# La statistique est l'amplitude relative moyenne, ponderee par les effectifs.
mw_famille_alpha <- function(aj) {
  I <- aj$I; J <- aj$J; tri <- aj$tri
  det <- data.frame()
  for (j in 0:(J - 1)) {
    idx <- 0:(I - j - 1)
    if (length(idx) < 3) next
    C0 <- tri[idx + 1, j + 1]; F <- tri[idx + 1, j + 2] / C0
    f <- vapply(c(0, 1, 2), function(a) sum(C0^a * F) / sum(C0^a), numeric(1))
    det <- rbind(det, data.frame(j = j, n = length(idx),
      f0 = f[1], f1 = f[2], f2 = f[3],
      amplitude = (max(f) - min(f)) / f[2], stringsAsFactors = FALSE))
  }
  if (!nrow(det)) return(list(stat = NA_real_, detail = det))
  list(stat = sum(det$n * det$amplitude) / sum(det$n), detail = det)
}

# (e) Adequation de l'exposant de variance (hypothese (iv), complement de M2).
# Si Var[C(i,j+1)|C(i,j)] = sigma_j^2 C(i,j), alors les residus standardises de
# Mack sont d'echelle constante DANS CHAQUE COLONNE : |r(i,j)| ne doit pas
# dependre de C(i,j). Correlation de rang colonne par colonne, combinee.
mw_test_exposant_variance <- function(aj) {
  res <- mw_residus(aj)
  if (!nrow(res)) return(list(stat = NA_real_, p = NA_real_, detail = data.frame()))
  det <- data.frame()
  for (j in unique(res$j)) {
    d <- res[res$j == j, ]
    if (nrow(d) < 4 || stats::sd(d$C) == 0) next
    ct <- suppressWarnings(stats::cor.test(abs(d$residu), d$C,
                                           method = "spearman", exact = FALSE))
    det <- rbind(det, data.frame(j = j, n = nrow(d),
      rho = unname(ct$estimate), p = ct$p.value, stringsAsFactors = FALSE))
  }
  if (!nrow(det)) return(list(stat = NA_real_, p = NA_real_, detail = det))
  fc <- .fisher_combine(det$p)
  list(stat = fc$stat, p = fc$p, K = fc$K, detail = det)
}

# (f) Homogeneite des residus entre annees de survenance (hypothese (i)).
# Si les annees d'accident sont stochastiquement independantes et suivent le
# meme modele, les residus de Mack ne doivent pas differer systematiquement
# d'une ligne a l'autre. Test de Kruskal-Wallis (1952), non parametrique.
mw_test_homogeneite_accident <- function(aj) {
  res <- mw_residus(aj)
  g <- factor(res$i)
  if (nlevels(g) < 3 || nrow(res) < 6)
    return(list(stat = NA_real_, p = NA_real_, ddl = NA_integer_))
  k <- try(stats::kruskal.test(res$residu, g), silent = TRUE)
  if (inherits(k, "try-error")) return(list(stat = NA_real_, p = NA_real_, ddl = NA_integer_))
  list(stat = unname(k$statistic), p = .p_borne(k$p.value),
       ddl = unname(k$parameter))
}

# --- Bootstrap de Mack par reechantillonnage des residus ---------------------
# England & Verrall (2002), "Stochastic claims reserving in general insurance",
# British Actuarial Journal 8(3), 443-518 ; England (2002).
# Le modele de Mack ne specifie que les deux premiers moments : aucun bootstrap
# PARAMETRIQUE n'est possible, contrairement a la methode lognormale. On
# reechantillonne donc les residus standardises de Mack, ce qui ne suppose que
# leur echangeabilite. La p-value obtenue est donc de nature semi-parametrique.
mw_simuler_triangle <- function(aj, res_pool) {
  I <- aj$I; J <- aj$J
  tri <- matrix(NA_real_, I + 1, J + 1)
  tri[, 1] <- aj$tri[, 1]                       # premiere colonne conservee
  for (j in 0:(J - 1)) {
    idx <- 0:(I - j - 1)
    sg <- sqrt(aj$sigma2[j + 1])
    if (!is.finite(sg)) sg <- 0
    e <- sample(res_pool, length(idx), replace = TRUE)
    Cij <- tri[idx + 1, j + 1]
    tri[idx + 1, j + 2] <- Cij * aj$f[j + 1] + e * sg * sqrt(Cij)
  }
  # Un cumul simule negatif ou decroissant rendrait les facteurs non definis :
  # on borne par une valeur stricitement positive, en le signalant au besoin.
  tri[!is.na(tri) & tri <= 0] <- NA_real_
  tri
}

mw_bootstrap <- function(aj, B = 999, seed = 20260831) {
  set.seed(seed)
  res <- mw_residus(aj)
  pool <- res$residu
  pool <- pool - mean(pool)                     # recentrage usuel
  obs <- .mw_stats(aj)
  noms <- names(obs)
  sim <- matrix(NA_real_, B, length(noms), dimnames = list(NULL, noms))
  sig <- rep(NA_real_, B)
  for (b in seq_len(B)) {
    tb <- mw_simuler_triangle(aj, pool)
    if (anyNA(tb[upper.tri(tb, diag = TRUE)[, rev(seq_len(ncol(tb)))]])) next
    ab <- try(mw_ajuster(tb), silent = TRUE)
    if (inherits(ab, "try-error")) next
    sb <- try(.mw_stats(ab), silent = TRUE)
    if (inherits(sb, "try-error")) next
    sim[b, ] <- sb[noms]
    mb <- try(mw_msep(ab), silent = TRUE)
    if (!inherits(mb, "try-error") && is.finite(mb$msep) && ab$reserve > 0)
      sig[b] <- sqrt(mb$msep) / ab$reserve
  }
  # Les tests de NORMALITE sont volontairement exclus du bootstrap. Le
  # reechantillonnage tire dans la loi empirique des residus OBSERVES : son
  # hypothese nulle est "les residus suivent leur propre loi empirique", et non
  # "les residus sont normaux". Une p-value de Monte-Carlo y serait vide de
  # sens (verification par simulation : frequence de rejet nulle au lieu de
  # 5 %). La normalite n'est d'ailleurs PAS une hypothese du modele de Mack :
  # l'annexe XVII, D(2)(h), ne specifie que les deux premiers moments. Elle est
  # donc traitee comme un diagnostic descriptif, avec sa loi nulle propre.
  queue <- c(Calendrier = "deux", CorrDev = "deux",
             BP = "haut", Grubbs = "haut", DW = "deux", Runs = "deux",
             Intercept = "deux",
             # Les statistiques de Fisher et de Kruskal-Wallis rejettent en
             # queue haute ; l'amplitude de la famille alpha egalement.
             Origine = "haut", HomogF = "haut", Courbure = "haut",
             Alpha = "haut", ExpVar = "haut", KruskalAcc = "haut")
  pv <- vapply(noms, function(nm) {
    s <- sim[, nm]; s <- s[is.finite(s)]; o <- obs[[nm]]
    if (!length(s) || !is.finite(o)) return(NA_real_)
    switch(queue[[nm]],
           haut = (1 + sum(s >= o)) / (length(s) + 1),
           bas  = (1 + sum(s <= o)) / (length(s) + 1),
           deux = 2 * min((1 + sum(s >= o)) / (length(s) + 1),
                          (1 + sum(s <= o)) / (length(s) + 1)))
  }, numeric(1))
  pv <- pmin(pv, 1)
  B_eff <- colSums(is.finite(sim))
  list(stats_obs = as.list(obs), p_mc = pv,
       err_mc = sqrt(pv * (1 - pv) / pmax(B_eff, 1)),
       B_effectif = B_eff, granularite = 1 / (B + 1),
       sigma_boot = sig[is.finite(sig)], B = B)
}

# Statistiques bootstrapables de la methode Merz-Wuthrich.
.mw_stats <- function(aj) {
  res <- mw_residus(aj)
  r <- res$residu
  cal <- mw_test_annees_calendaires(aj)
  cor <- mw_stat_correlation_dev(aj)
  # Regression auxiliaire testant la proportionnalite sur l'ensemble du triangle.
  # L'EFFET DE COLONNE EST INDISPENSABLE : le facteur f_j decroit avec j alors
  # que le cumule C(i,j) croit, de sorte qu'une regression agregee sans terme
  # d'annee de developpement capte cette relation mecanique et rejette H0 de
  # facon quasi systematique (verifie par simulation : 100 % de rejets sous H0).
  # L'ajout de facteur(j) ramene le test a ce qu'il pretend mesurer : une
  # dependance au volume A L'INTERIEUR de chaque colonne.
  ti <- .mw_pente_intra(res)
  # Heteroscedasticite residuelle : les residus de Mack ne doivent plus
  # dependre de C(i,j) si la variance est bien proportionnelle a C(i,j).
  bp <- if (nrow(res) > 3 && stats::sd(res$C) > 0)
    nrow(res) * summary(stats::lm(I(r^2) ~ res$C))$r.squared else NA_real_
  # Tests specifiques de l'hypothese (iii), colonne par colonne
  oo <- mw_test_ordonnee_origine(aj); hf <- mw_test_homogeneite_f(aj)
  cb <- mw_test_courbure(aj);         al <- mw_famille_alpha(aj)
  ev <- mw_test_exposant_variance(aj); ka <- mw_test_homogeneite_accident(aj)
  c(Calendrier = cal$stat, CorrDev = cor$stat,
    BP = bp, Grubbs = test_grubbs(r)$stat,
    DW = stat_dw(r), Runs = test_runs(r)$stat, Intercept = ti,
    Origine = oo$stat, HomogF = hf$stat, Courbure = cb$stat,
    Alpha = al$stat, ExpVar = ev$stat, KruskalAcc = ka$stat)
}

# --- Table des tests de la methode Merz-Wuthrich ------------------------------
# Meme structure de sortie que usp_tests() : chaque ligne porte H0, H1, la
# statistique, les p-values disponibles et la nature de celle qui est retenue.
mw_tests <- function(aj, boot, alpha = 0.10) {
  res <- mw_residus(aj); r <- res$residu; n <- length(r)
  gp <- function(nm) if (nm %in% names(boot$p_mc)) unname(boot$p_mc[[nm]]) else NA_real_
  ge <- function(nm) if (nm %in% names(boot$err_mc)) unname(boot$err_mc[[nm]]) else NA_real_
  L <- list()
  add <- function(fam, nom, ref, type = "test", H0 = NA_character_, H1 = NA_character_,
                  stat_nom = NA_character_, stat = NA_real_, loi = NA_character_,
                  estim_nom = NA_character_, estim = NA_real_,
                  p_ex = NA_real_, p_as = NA_real_, mc_nom = NA_character_,
                  detail = "", verdict = NULL, sens = "ne pas rejeter",
                  base = "commun", variante = "principale",
                  nature_forcee = NA_character_) {
    p_mc <- if (!is.na(mc_nom)) gp(mc_nom) else NA_real_
    e_mc <- if (!is.na(mc_nom)) ge(mc_nom) else NA_real_
    if (is.finite(p_ex))      { p_ret <- p_ex; nature <- "exacte" }
    else if (is.finite(p_mc)) { p_ret <- p_mc; nature <- "Monte-Carlo (bootstrap de residus)" }
    else if (is.finite(p_as)) { p_ret <- p_as; nature <- "asymptotique" }
    else                      { p_ret <- NA_real_; nature <- NA_character_ }
    if (!is.na(nature_forcee) && is.finite(p_ret)) nature <- nature_forcee
    v <- if (!is.null(verdict)) verdict
    else if (type != "test" || !is.finite(p_ret)) "INFO"
    else if (sens == "rejeter") { if (p_ret < alpha) "OK" else if (p_ret < 0.30) "ALERTE" else "ECHEC" }
    else { if (p_ret < alpha / 2) "ECHEC" else if (p_ret < alpha) "ALERTE" else "OK" }
    L[[length(L) + 1]] <<- list(famille = fam, test = nom, reference = ref, type = type,
      base = base, variante = variante, H0 = H0, H1 = H1,
      stat_nom = stat_nom, stat = stat, loi = loi,
      estim_nom = estim_nom, estim = estim,
      p_exacte = p_ex, p_asymptotique = p_as, p_mc = p_mc, err_mc = e_mc,
      p_retenue = p_ret, nature_p = nature, verdict = v, detail = detail, sens = sens)
  }

  ## --- M1 : proportionnalite des cumules (D(2)(h)(iii)) ---------------------
  fam <- "M1. proportionnalite des cumules (annexe XVII D(2)(h)(iii))"
  ti <- .mw_lm_intra(res)
  add(fam, "Absence de tendance des facteurs avec le cumul, a colonne donnee",
      "Mack (1993), ASTIN Bulletin 23(2)",
      H0 = "a annee de developpement donnee, le facteur ne depend pas du niveau de C(i,j)",
      H1 = "les facteurs varient avec le volume a l'interieur d'une colonne",
      stat_nom = "t", stat = if (!is.null(ti)) unname(ti[3]) else NA_real_,
      loi = "t ponderee a effet de colonne fixe ; p de reference par Monte-Carlo",
      p_as = if (!is.null(ti)) unname(ti[4]) else NA_real_, mc_nom = "Intercept",
      detail = paste("Regression ponderee sur tout le triangle AVEC effet fixe d'annee de",
                     "developpement. Sans ce terme, la decroissance de f_j et la croissance",
                     "de C(i,j) creent une relation mecanique qui fait rejeter H0 dans la",
                     "quasi-totalite des cas."))

  # --- Tests colonne par colonne de l'hypothese (iii) ------------------------
  oo <- mw_test_ordonnee_origine(aj)
  add(fam, "Nullite de l'ordonnee a l'origine, colonne par colonne",
      "Mack (1993), ASTIN Bulletin 23(2), section 3",
      H0 = "a_j = 0 pour toute annee de developpement j",
      H1 = "au moins une colonne presente une composante fixe",
      stat_nom = "X de Fisher", stat = oo$stat,
      loi = "chi2(2K) approx. (colonnes non independantes) -> Monte-Carlo",
      estim_nom = "colonnes testees", estim = if (is.null(oo$K)) NA_real_ else oo$K,
      p_as = oo$p, mc_nom = "Origine",
      detail = paste("La regression ponderee SANS constante et de poids 1/C(i,j) a pour",
                     "estimateur exactement f_j (identite de Mack, verifiee a 1e-16).",
                     "Ajouter une constante fournit donc le test naturel de la",
                     "proportionnalite, colonne par colonne."))
  hf <- mw_test_homogeneite_f(aj)
  add(fam, "Homogeneite de f_j entre annees de survenance",
      "Annexe XVII, D(2)(h)(iii) : 'pour toutes les annees d'accident'",
      H0 = "le facteur f_j est commun a toutes les annees de survenance",
      H1 = "les facteurs individuels derivent avec l'annee de survenance",
      stat_nom = "X de Fisher", stat = hf$stat,
      loi = "chi2(2K) approx. -> Monte-Carlo",
      estim_nom = "colonnes testees", estim = if (is.null(hf$K)) NA_real_ else hf$K,
      p_as = hf$p, mc_nom = "HomogF",
      detail = "Correlation de rang entre F(i,j) et i, colonne par colonne, combinee par Fisher")
  cb <- mw_test_courbure(aj)
  add(fam, "Absence de courbure de la regression",
      "Test du terme quadratique, dans l'esprit de Ramsey (1969)",
      H0 = "le terme en C(i,j)^2 est nul dans chaque colonne",
      H1 = "la relation entre cumules successifs n'est pas lineaire",
      stat_nom = "X de Fisher", stat = cb$stat,
      loi = "chi2(2K) approx. -> Monte-Carlo",
      estim_nom = "colonnes testees", estim = if (is.null(cb$K)) NA_real_ else cb$K,
      p_as = cb$p, mc_nom = "Courbure",
      detail = "Une courbure invalide la linearite meme si la constante est nulle")
  al <- mw_famille_alpha(aj)
  add(fam, "Stabilite du facteur selon la ponderation (famille alpha)",
      "Mack (1994), Insurance: Mathematics and Economics 15",
      H0 = "les estimateurs alpha = 0, 1 et 2 visent le meme f_j",
      H1 = "la valeur du facteur depend de la ponderation retenue",
      stat_nom = "amplitude relative", stat = al$stat,
      loi = "aucune loi analytique -> Monte-Carlo", mc_nom = "Alpha",
      detail = paste("alpha = 0 : moyenne simple des facteurs ; alpha = 1 : chain-ladder",
                     "du reglement ; alpha = 2 : ponderation par le carre du volume."))

  ## --- M2 : structure de variance (D(2)(h)(iv)) -----------------------------
  fam <- "M2. variance proportionnelle au cumul (annexe XVII D(2)(h)(iv))"
  bp <- if (n > 3 && stats::sd(res$C) > 0) {
    m <- stats::lm(I(r^2) ~ res$C); list(stat = n * summary(m)$r.squared,
      p = .p_borne(1 - stats::pchisq(n * summary(m)$r.squared, 1))) } else list(stat = NA_real_, p = NA_real_)
  add(fam, "Heteroscedasticite residuelle vs cumul",
      "Breusch & Pagan (1979) / Koenker (1981), applique aux residus de Mack",
      H0 = "les residus de Mack ne dependent plus de C(i,j)",
      H1 = "la ponderation en C(i,j) ne capture pas la variance",
      stat_nom = "LM", stat = bp$stat, loi = "chi2(1) asymptotique",
      p_as = bp$p, mc_nom = "BP",
      detail = "Si Var(C(i,j+1)|C(i,j)) = sigma_j^2 C(i,j), les residus standardises sont d'echelle constante")
  ev <- mw_test_exposant_variance(aj)
  add(fam, "Adequation de l'exposant de variance, colonne par colonne",
      "Annexe XVII, D(2)(h)(iv) ; complement de Breusch-Pagan",
      H0 = "|r(i,j)| ne depend pas de C(i,j) dans chaque colonne",
      H1 = "l'exposant 1 impose par le reglement est inadapte",
      stat_nom = "X de Fisher", stat = ev$stat,
      loi = "chi2(2K) approx. -> Monte-Carlo",
      estim_nom = "colonnes testees", estim = if (is.null(ev$K)) NA_real_ else ev$K,
      p_as = ev$p, mc_nom = "ExpVar",
      detail = paste("Si la variance est bien proportionnelle a C(i,j), les residus",
                     "standardises sont d'echelle constante a l'interieur de chaque colonne."))
  add(fam, "Variance unitaire des residus de Mack", "Diagnostic d'echelle",
      type = "diagnostic", estim_nom = "var(residus)", estim = stats::var(r),
      detail = "Valeur attendue proche de 1 ; un ecart marque signale une mauvaise specification de sigma_j",
      verdict = if (!is.finite(stats::var(r))) "INFO"
                else if (abs(stats::var(r) - 1) > 0.5) "ALERTE" else "OK")

  ## --- M3 : independance des annees d'accident et de developpement ----------
  fam <- "M3. independance (annexe XVII D(2)(h)(i) et (ii))"
  cal <- mw_test_annees_calendaires(aj)
  add(fam, "Effets d'annee calendaire (test de Mack)",
      "Mack (1994), Insurance: Mathematics and Economics 15, 133-138",
      H0 = "absence d'effet d'annee calendaire (diagonales homogenes)",
      H1 = "une ou plusieurs diagonales atypiques (inflation, changement de cadence)",
      stat_nom = "Z centre reduit", stat = cal$stat,
      loi = "N(0,1) approx. ; moments EXACTS de Z = min(L, n-L)",
      estim_nom = "Z observe", estim = cal$Z,
      p_as = cal$p, mc_nom = "Calendrier",
      detail = "Les diagonales representent les exercices comptables : un effet calendaire viole l'independance des annees d'accident")
  ka <- mw_test_homogeneite_accident(aj)
  add(fam, "Homogeneite des residus entre annees de survenance",
      "Kruskal & Wallis (1952), JASA 47, 583-621",
      H0 = "les residus de Mack ont la meme distribution dans toutes les lignes",
      H1 = "au moins une annee de survenance se comporte differemment",
      stat_nom = "H", stat = ka$stat,
      loi = sprintf("chi2(%s) approx. -> Monte-Carlo",
                    ifelse(is.na(ka$ddl), "k-1", as.character(ka$ddl))),
      p_as = ka$p, mc_nom = "KruskalAcc",
      detail = "Traduction testable de l'independance des annees de survenance, D(2)(h)(i)")
  cor <- mw_stat_correlation_dev(aj)
  add(fam, "Correlation entre annees de developpement adjacentes",
      "Mack (1993, 1997), ASTIN Bulletin ; correlation de rang de Spearman",
      H0 = "facteurs de developpement successifs non correles",
      H1 = "correlation entre colonnes adjacentes",
      stat_nom = "rho agrege", stat = cor$stat,
      loi = "depend de la geometrie du triangle -> Monte-Carlo", mc_nom = "CorrDev",
      detail = "Une correlation positive signale une dependance entre cadences successives")
  add(fam, "Autocorrelation des residus (Durbin-Watson)",
      "Durbin & Watson (1950, 1951)",
      H0 = "residus de Mack non autocorreles", H1 = "autocorrelation residuelle",
      stat_nom = "DW", stat = stat_dw(r),
      loi = "residus de triangle -> Monte-Carlo", mc_nom = "DW")
  ru <- test_runs(r)
  add(fam, "Test des suites sur les residus de Mack",
      "Wald & Wolfowitz (1940)",
      H0 = "arrangement aleatoire des signes des residus", H1 = "arrangement non aleatoire",
      stat_nom = "Z", stat = ru$stat, loi = "N(0,1) approx. -> Monte-Carlo",
      estim_nom = "nb de suites", estim = ru$runs,
      p_as = ru$p, mc_nom = "Runs")

  ## --- M4 : points aberrants ------------------------------------------------
  fam <- "M4. points aberrants et stabilite"
  gr <- test_grubbs(r)
  add(fam, "Cellule aberrante du triangle (Grubbs)",
      "Grubbs (1950, 1969), Technometrics 11",
      H0 = "aucun residu de Mack aberrant", H1 = "exactement un residu aberrant",
      stat_nom = "G", stat = gr$stat, loi = "Student + Bonferroni -> Monte-Carlo",
      estim_nom = "rang du residu extreme", estim = gr$idx,
      p_as = gr$p, mc_nom = "Grubbs",
      detail = if (is.finite(gr$idx) && gr$idx <= nrow(res))
        sprintf("residu le plus extreme : annee d'accident %d, developpement %d",
                res$i[gr$idx], res$j[gr$idx]) else "")
  ro <- test_rosner(r, alpha = alpha)
  add(fam, "Cellules aberrantes multiples (ESD generalise)",
      "Rosner (1983), Technometrics 25", type = "procedure de decision",
      H0 = "aucun residu aberrant", H1 = "il existe i <= k residus aberrants",
      estim_nom = "nb de cellules aberrantes", estim = ro$nb_outliers,
      detail = sprintf("procedure a niveau alpha = %.2f (aucune p-value)", alpha),
      verdict = if (ro$nb_outliers >= 2) "ECHEC" else if (ro$nb_outliers == 1) "ALERTE" else "OK")

  ## --- M5 : normalite, DIAGNOSTIC seulement ---------------------------------
  fam <- "M5. normalite des residus (diagnostic, NON exige par le modele)"
  sw <- .shapiro_sur(r)
  add(fam, "Shapiro-Wilk sur les residus de Mack",
      "Shapiro & Wilk (1965) ; loi nulle evaluee par simulation directe",
      H0 = "les residus de Mack sont normaux", H1 = "loi non normale",
      stat_nom = "W", stat = sw$stat,
      loi = "loi exacte de W sous normalite, evaluee numeriquement",
      p_ex = sw_p_loi_nulle(sw$stat, n),
      detail = paste("L'annexe XVII, D(2)(h), ne specifie que les DEUX PREMIERS MOMENTS :",
                     "la normalite n'est pas requise par la methode. Ce test n'est pertinent",
                     "que si l'on souhaite exploiter la MSEP pour un quantile."))
  add(fam, "Lilliefors sur les residus de Mack",
      "Lilliefors (1967) ; p-value : Dallal & Wilkinson (1986)",
      variante = "secondaire",
      H0 = "les residus de Mack sont normaux", H1 = "loi non normale",
      stat_nom = "D", stat = stat_lilliefors(r),
      loi = "loi de Lilliefors (parametres estimes)",
      p_as = lillie_p(stat_lilliefors(r), n))

  ## --- M6 : robustesse de l'estimation --------------------------------------
  fam <- "M6. robustesse de l'estimation"
  add(fam, "Extrapolation de sigma pour la derniere annee de developpement",
      "Annexe XVII, D(5)(d)(ii), seconde ligne", type = "diagnostic",
      estim_nom = "sigma2_(J-1)", estim = aj$sigma2[aj$J],
      detail = "Valeur non estimee mais extrapolee par la regle min(...) du reglement : elle repose sur deux annees seulement",
      verdict = "INFO")
  add(fam, "Part de la reserve portee par la derniere annee d'accident",
      "Diagnostic de concentration", type = "diagnostic",
      estim_nom = "part", estim = aj$reserve_par_annee[aj$I + 1] / aj$reserve,
      detail = "Une part elevee concentre la MSEP sur la ligne la moins developpee du triangle",
      verdict = if (aj$reserve_par_annee[aj$I + 1] / aj$reserve > 0.40) "ALERTE" else "OK")
  L
}


## =============================================================================
## 10. ORCHESTRATEUR PRINCIPAL
## =============================================================================

# run_engine() : lance toute la chaine de calcul a partir des donnees brutes et
# des parametres utilisateur, et retourne un objet structure contenant
# l'integralite des resultats necessaires a l'application.
#
# Arguments
#   xt, yt         vecteurs numeriques de meme longueur (primes / pertes, ou
#                  provision d'ouverture / montant de liquidation)
#   methode        "premium" ou "reserve1"
#   segment        segment de l'annexe II (1 a 12) ; sert a determiner
#                  sigma_standard et le bareme de credibilite
#   sigma_standard ecart-type standard ; s'il est fourni, il prime sur `segment`
#   T              profondeur retenue (les T dernieres annees) ; NULL = tout
#   B              nombre de replications bootstrap / Monte-Carlo
#   alpha          seuil des verdicts
#   seed           graine des simulations (reproductibilite)
#   bareme         "court" ou "long" ; NULL = deduit du segment
#
# Valeur : liste de classe "usp_engine" (voir la structure en fin de fonction).
# Orchestrateur de la methode du risque de reserve no 2. Retourne un objet de
# meme classe et de meme forme generale que la branche lognormale, afin que la
# couche d'affichage puisse le consommer sans traitement particulier.
.run_engine_mw <- function(triangle, segment, annexe, sigma_standard,
                           B, alpha, seed, bareme, t0) {
  if (is.null(triangle))
    stop("La methode du risque de reserve no 2 exige un triangle de paiements cumules.")
  triangle <- as.matrix(triangle)
  validation <- mw_valider_triangle(triangle)
  if (!validation$ok)
    return(structure(list(ok = FALSE, validation = validation, methode = "reserve2",
                          metadata = list(horodatage = t0, methode = "reserve2")),
                     class = "usp_engine"))

  infos <- if (!is.null(segment)) usp_segment_infos(segment, annexe) else NULL
  if (is.null(sigma_standard)) {
    if (is.null(infos)) stop("Fournir soit sigma_standard, soit segment (avec son annexe).")
    sigma_standard <- infos$sigma_reserve      # methode de reserve : sigma(res,s)
  }
  if (is.null(bareme)) bareme <- usp_bareme_segment(segment, annexe)

  aj   <- mw_ajuster(triangle)
  msep <- mw_msep(aj)
  par  <- mw_parametre(aj, msep$msep, sigma_standard, bareme)
  boot <- mw_bootstrap(aj, B = B, seed = seed)
  tests <- mw_tests(aj, boot, alpha)
  res   <- mw_residus(aj)

  ic <- if (length(boot$sigma_boot) > 20)
    stats::quantile(par$credibilite * boot$sigma_boot +
                    (1 - par$credibilite) * sigma_standard,
                    c(.025, .05, .5, .95, .975)) else NULL

  descriptif <- data.frame(
    grandeur = c("Annees d'accident (I+1)", "Annees de developpement (J+1)",
                 "Cellules observees", "Dernier cumul total", "Ultime total",
                 "Reserve totale", "racine(MSEP) a un an", "CV a un an"),
    valeur = c(aj$I + 1, aj$J + 1, sum(!is.na(triangle)),
               sum(aj$dernier_observe), sum(aj$ultime), aj$reserve,
               par$racine_msep, par$sigma_estime),
    stringsAsFactors = FALSE)

  calibration <- data.frame(
    etape = c("Reserve chain-ladder totale", "MSEP a un an",
              "racine(MSEP)", "sigma estime = racine(MSEP) / reserve",
              "facteur de credibilite c", "sigma standard (formule standard)",
              "sigma_USP = c*sigma_estime + (1-c)*sigma_standard"),
    valeur = c(aj$reserve, msep$msep, par$racine_msep, par$sigma_estime,
               par$credibilite, sigma_standard, par$sigma_usp),
    stringsAsFactors = FALSE)

  candidats <- data.frame(
    variante = c("sigma standard (aucun USP)", "sigma estime seul (credibilite 100%)",
                 "sigma_USP retenu (annexe XVII)"),
    valeur = c(sigma_standard, par$sigma_estime, par$sigma_usp),
    retenu = c(FALSE, FALSE, TRUE), stringsAsFactors = FALSE)

  structure(list(
    ok = TRUE, methode = "reserve2",
    triangle = triangle,
    donnees = data.frame(i = res$i, j = res$j, C = res$C, F = res$F,
                         residu = res$residu),
    validation = validation,
    controles = list(list(test = "Structure du triangle", verdict = "OK",
                          detail = sprintf("I = %d, J = %d, %d cellules observees",
                                           aj$I, aj$J, sum(!is.na(triangle))))),
    statistiques_descriptives = descriptif,
    ajustement = aj, msep = msep, residus = res,
    tests = tests, bootstrap = boot, ic_bootstrap = ic,
    calibration = calibration, candidats = candidats,
    parametre_final = list(sigma_usp = par$sigma_usp,
                           sigma_estime = par$sigma_estime,
                           sigma_estime_brut = par$sigma_estime,
                           correction_taille = 1,
                           credibilite = par$credibilite,
                           sigma_standard = sigma_standard,
                           variation_relative = par$variation_relative),
    plots_data = mw_plots_data(aj, res, boot, msep),
    metadata = list(methode = "reserve2", segment = segment, annexe = annexe,
                    libelle_segment = if (!is.null(infos)) infos$libelle else NA_character_,
                    T = aj$I + 1L, I = aj$I, J = aj$J, B = B, alpha = alpha,
                    seed = seed, bareme = bareme, sigma_standard = sigma_standard,
                    horodatage = t0,
                    duree_sec = as.numeric(difftime(Sys.time(), t0, units = "secs")),
                    version_R = R.version.string)
  ), class = "usp_engine")
}

# --- Diagnostics d'influence du triangle (methode Merz-Wuthrich) -------------
# Le facteur de developpement f_j est une moyenne ponderee des facteurs
# individuels F(i,j) = C(i,j+1)/C(i,j), de poids C(i,j) :
#     f_j = somme_i C(i,j) F(i,j) / somme_i C(i,j)
# Le LEVIER exact de la cellule (i,j) dans l'estimation de f_j est donc
#     h(i,j) = C(i,j) / somme_{i'} C(i',j),   de somme 1 par colonne.
# L'INFLUENCE exacte se mesure par le DFBETA obtenu en retirant la cellule :
#     f_j^(-i) = (somme C(.,j+1) - C(i,j+1)) / (somme C(.,j) - C(i,j))
# Ces deux quantites sont calculees exactement, sans reajustement iteratif.
mw_influence <- function(aj) {
  I <- aj$I; J <- aj$J; tri <- aj$tri
  out <- data.frame()
  for (j in 0:(J - 1)) {
    idx <- 0:(I - j - 1)
    if (length(idx) < 2) next
    Cij <- tri[idx + 1, j + 1]; Cij1 <- tri[idx + 1, j + 2]
    Sj <- sum(Cij); Sj1 <- sum(Cij1)
    h <- Cij / Sj
    f_sans <- (Sj1 - Cij1) / (Sj - Cij)
    resid <- if (is.finite(aj$sigma2[j + 1]) && aj$sigma2[j + 1] > 0)
      sqrt(Cij) * (Cij1 / Cij - aj$f[j + 1]) / sqrt(aj$sigma2[j + 1]) else rep(NA_real_, length(idx))
    out <- rbind(out, data.frame(
      i = idx, j = j, C = Cij, F = Cij1 / Cij,
      levier = h, seuil_levier = 2 / length(idx),
      f_chapeau = aj$f[j + 1], f_sans_cellule = f_sans,
      dfbeta_relatif = (f_sans - aj$f[j + 1]) / aj$f[j + 1],
      residu = resid, stringsAsFactors = FALSE))
  }
  out$fort_levier <- out$levier > out$seuil_levier
  out
}

# Contribution de chaque annee de survenance a la reserve et au terme de
# variance de processus de la MSEP. Il s'agit d'une DECOMPOSITION exacte, non
# d'un leave-one-out : le terme d'erreur d'estimation de la MSEP comporte des
# termes croises, par nature partages entre paires d'annees, et n'est donc pas
# attribuable a une annee isolee. Le denominateur des parts est
# msep$terme_variance, c'est-a-dire la seule variance de processus (voir le
# decoupage documente en tete de mw_msep()), et non la MSEP totale.
mw_contributions <- function(aj, msep) {
  I <- aj$I; J <- aj$J
  Cu <- aj$C_chapeau[, J + 1]; Cd <- aj$dernier_observe
  vterme <- rep(0, I + 1)
  for (i in 1:I) vterme[i + 1] <- Cu[i + 1]^2 * aj$Q[I - i + 1] / Cd[i + 1]
  data.frame(
    i = 0:I,
    reserve = aj$reserve_par_annee,
    part_reserve = aj$reserve_par_annee / aj$reserve,
    terme_variance = vterme,
    part_terme_variance = if (msep$terme_variance > 0)
      vterme / msep$terme_variance else rep(NA_real_, I + 1),
    stringsAsFactors = FALSE)
}

# Quantites numeriques des graphiques de la methode Merz-Wuthrich.
mw_plots_data <- function(aj, res, boot, msep = NULL) {
  qq <- stats::qqnorm(res$residu, plot.it = FALSE)
  list(
    methode = "reserve2",
    facteurs = data.frame(j = 0:(aj$J - 1), f = aj$f,
                          sigma = sqrt(aj$sigma2)),
    reserve_par_annee = data.frame(i = 0:aj$I,
                                   dernier = aj$dernier_observe,
                                   ultime = aj$ultime,
                                   reserve = aj$reserve_par_annee),
    residus = res,
    residus_dev = data.frame(j = res$j, residu = res$residu),
    residus_acc = data.frame(i = res$i, residu = res$residu),
    residus_cal = data.frame(calendrier = res$calendrier, residu = res$residu),
    residus_C = data.frame(C = res$C, residu = res$residu),
    qqnorm = data.frame(theorique = qq$x, empirique = qq$y),
    # Donnees des regressions par annee de developpement : nuages C(i,j+1)
    # contre C(i,j), droite de proportionnalite f_j (sans constante) et droite
    # ajustee avec constante. Toutes les quantites sont calculees ici.
    regressions = local({
      out <- list()
      for (j in 0:(aj$J - 1)) {
        idx <- 0:(aj$I - j - 1)
        if (length(idx) < 2) next
        C0 <- aj$tri[idx + 1, j + 1]; C1 <- aj$tri[idx + 1, j + 2]
        a <- b <- NA_real_
        if (length(idx) >= 3) {
          m <- try(stats::lm(C1 ~ C0, weights = 1 / C0), silent = TRUE)
          if (!inherits(m, "try-error") && length(stats::coef(m)) == 2) {
            a <- unname(stats::coef(m)[1]); b <- unname(stats::coef(m)[2])
          }
        }
        out[[length(out) + 1]] <- list(j = j, i = idx, C0 = C0, C1 = C1,
          f = aj$f[j + 1], a = a, b = b, n = length(idx))
      }
      out
    }),
    alpha = mw_famille_alpha(aj)$detail,
    origine = mw_test_ordonnee_origine(aj)$detail,
    influence = mw_influence(aj),
    contributions = if (!is.null(msep)) mw_contributions(aj, msep) else NULL,
    sigma_boot = boot$sigma_boot
  )
}

run_engine <- function(xt, yt,
                       methode = c("premium", "reserve1", "reserve2"),
                       segment = NULL,
                       annexe = c("II", "XIV"),
                       triangle = NULL,
                       sigma_standard = NULL,
                       T = NULL,
                       B = 999,
                       alpha = 0.10,
                       theta_equiv = 0.10,
                       delta_equiv = NULL,
                       seed = 20260831,
                       bareme = NULL,
                       plus_recent_en_dernier = TRUE) {
  t0 <- Sys.time()
  methode <- match.arg(methode)
  annexe  <- match.arg(annexe)

  # --- Branche Merz-Wuthrich (methode du risque de reserve no 2) ------------
  # Cette methode ne prend pas en entree deux vecteurs mais un TRIANGLE de
  # paiements cumules ; la chaine de calcul est entierement distincte.
  if (methode == "reserve2")
    return(.run_engine_mw(triangle = triangle, segment = segment, annexe = annexe,
                          sigma_standard = sigma_standard, B = B, alpha = alpha,
                          seed = seed, bareme = bareme, t0 = t0))

  # --- 1. Donnees et controles de validite ---------------------------------
  if (!plus_recent_en_dernier) { xt <- rev(xt); yt <- rev(yt) }
  n <- length(xt)
  if (!is.null(T) && is.finite(T)) {
    if (T > n) stop(sprintf("T = %d > profondeur disponible (%d).", T, n))
    idx <- (n - T + 1):n; xt <- xt[idx]; yt <- yt[idx]
  }
  validation <- engine_valider_donnees(xt, yt)
  if (!validation$ok)
    return(structure(list(ok = FALSE, validation = validation,
                          metadata = list(horodatage = t0)), class = "usp_engine"))
  T <- length(xt)

  # --- 2. Parametre standard et bareme de credibilite -----------------------
  infos <- if (!is.null(segment)) usp_segment_infos(segment, annexe) else NULL
  if (is.null(sigma_standard)) {
    if (is.null(infos))
      stop("Fournir soit sigma_standard, soit segment (avec son annexe).")
    sigma_standard <- if (methode == "premium") infos$sigma_prime_brut
                      else infos$sigma_reserve
  }
  # Annexe XVII, section G(2) : les segments de l'annexe XIV relevent tous du
  # bareme court, quel que soit leur numero.
  if (is.null(bareme)) bareme <- usp_bareme_segment(segment, annexe)

  # --- 3. Estimation, bootstrap, robustesse ---------------------------------
  controles <- usp_controle_donnees(xt, yt, alpha)
  fit   <- usp_ajuster(xt, yt)
  boot  <- usp_bootstrap(fit, B = B, seed = seed, progres = FALSE)
  param <- usp_parametre(fit, sigma_standard, bareme)
  jack  <- usp_jackknife(fit, sigma_standard, bareme)
  prof  <- usp_profil(fit)

  cred <- param$credibilite; corr <- param$correction_taille
  usp_b <- cred * boot$sigma_boot * corr + (1 - cred) * sigma_standard
  ic <- if (length(usp_b) > 20)
    stats::quantile(usp_b, c(.025, .05, .5, .95, .975)) else NULL

  fit$ecart_jackknife <- max(abs(jack$sigma_usp - param$sigma_usp), na.rm = TRUE) /
    param$sigma_usp
  fit$largeur_ic <- if (!is.null(ic)) unname((ic[4] - ic[2]) / param$sigma_usp) else NULL

  tests <- usp_tests(fit, boot, alpha, theta_equiv = theta_equiv,
                     delta_equiv = delta_equiv)

  # --- 4. Statistiques descriptives -----------------------------------------
  r <- yt / xt
  descriptif <- data.frame(
    grandeur = c("T", "somme(xt)", "somme(yt)", "moyenne(xt)", "moyenne(yt)",
                 "ratio moyen y/x", "mediane du ratio", "ecart-type du ratio",
                 "coefficient de variation du ratio", "min du ratio", "max du ratio",
                 "amplitude max(x)/min(x)"),
    valeur = c(T, sum(xt), sum(yt), mean(xt), mean(yt), mean(r), stats::median(r),
               stats::sd(r), stats::sd(r) / mean(r), min(r), max(r), max(xt) / min(xt)),
    stringsAsFactors = FALSE)

  # --- 5. Calibration : etapes explicites -----------------------------------
  calibration <- data.frame(
    etape = c("delta (parametre de melange)",
              "gamma (coefficient de variation logarithmique)",
              "beta (ratio moyen implicite)",
              "sigma(delta, gamma) estime",
              "correction de taille finie sqrt((T+1)/(T-1))",
              "sigma estime corrige",
              "facteur de credibilite c",
              "sigma standard (formule standard)",
              "sigma_USP = c*sigma_corrige + (1-c)*sigma_standard"),
    valeur = c(fit$delta, fit$gamma, fit$beta, param$sigma_estime_brut,
               param$correction_taille, param$sigma_estime, param$credibilite,
               param$sigma_standard, param$sigma_usp),
    stringsAsFactors = FALSE)

  candidats <- data.frame(
    variante = c("sigma standard (aucun USP)", "sigma estime seul (credibilite 100%)",
                 "sigma_USP retenu (annexe XVII)"),
    valeur = c(sigma_standard, param$sigma_estime, param$sigma_usp),
    retenu = c(FALSE, FALSE, TRUE), stringsAsFactors = FALSE)

  # --- 6. Objet de sortie ----------------------------------------------------
  structure(list(
    ok = TRUE,
    donnees = data.frame(t = seq_len(T), xt = xt, yt = yt, ratio = r),
    validation = validation,
    controles = controles,
    statistiques_descriptives = descriptif,
    ajustement = fit,
    tests = tests,
    bootstrap = boot,
    ic_bootstrap = ic,
    jackknife = jack,
    profil = prof,
    calibration = calibration,
    candidats = candidats,
    parametre_final = param,
    plots_data = engine_plots_data(fit, boot, prof, jack, param$sigma_usp),
    metadata = list(methode = methode, segment = segment, annexe = annexe,
                    libelle_segment = if (!is.null(infos)) infos$libelle else NA_character_,
                    T = T, B = B,
                    alpha = alpha, seed = seed, bareme = bareme,
                    theta_equiv = theta_equiv, delta_equiv = delta_equiv,
                    sigma_standard = sigma_standard,
                    horodatage = t0,
                    duree_sec = as.numeric(difftime(Sys.time(), t0, units = "secs")),
                    version_R = R.version.string)
  ), class = "usp_engine")
}


# Table des tests sous forme de data.frame auditable (donnees, pas affichage).
engine_table_tests <- function(res) {
  do.call(rbind, lapply(res$tests, function(t) data.frame(
    famille = t$famille, test = t$test, type = t$type,
    base = t$base, variante = t$variante,
    H0 = t$H0, H1 = t$H1,
    nom_statistique = t$stat_nom, statistique = t$stat, loi_sous_H0 = t$loi,
    nom_estimation = t$estim_nom, estimation = t$estim,
    p_exacte = t$p_exacte, p_asymptotique = t$p_asymptotique,
    p_monte_carlo = t$p_mc, erreur_MC = t$err_mc,
    p_retenue = t$p_retenue, nature_p = t$nature_p,
    sens_du_test = t$sens, verdict = t$verdict,
    commentaire = t$detail, reference = t$reference,
    stringsAsFactors = FALSE)))
}
