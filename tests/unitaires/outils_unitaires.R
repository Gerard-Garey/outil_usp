###############################################################################
#  tests/unitaires/outils_unitaires.R  --  MINI-CADRE DE TESTS UNITAIRES
#
#  R base uniquement (le moteur et la CI n'ont aucune dependance). Fournit :
#    verifier(nom, expr)                  : assertion ; expr doit valoir TRUE
#    echec_attendu(nom, constat, expr)    : defaut CONNU du moteur. expr decrit
#                                           le comportement CORRECT ; elle doit
#                                           echouer tant que le defaut existe.
#                                           Si elle passe, le test est compte en
#                                           echec ("succes inattendu") afin que
#                                           le test soit revu avec la correction.
#    proche(a, b, rel, abs)               : egalite numerique a tolerance pres
#    leve_erreur(expr)                    : TRUE si expr leve une erreur
#    debut_fichier(nom) / bilan_fichier() : regroupement et decompte par fichier
#
#  Charge aussi le moteur R/engine.R par charger_moteur() (R/charger_moteur.R,
#  ADR 0016), par chemin relatif a la racine du depot (les scripts se lancent
#  depuis la racine ou depuis tests/).
###############################################################################

if (!exists("ENGINE_CHARGE", inherits = TRUE)) {
  RACINE <- if (file.exists("R/engine.R")) "." else if (file.exists("../R/engine.R")) ".." else
            if (file.exists("../../R/engine.R")) "../.." else
            stop("R/engine.R introuvable : lancer depuis la racine du depot.")
  # Chargement dedie (ADR 0016, #200) : liaisons du moteur copiees dans
  # l'environnement global ; une substitution de test se pose dans
  # environment(run_engine), jamais dans l'environnement global.
  source(file.path(RACINE, "R", "charger_moteur.R"))
  charger_moteur(file.path(RACINE, "R", "engine.R"), dans = globalenv())
  ENGINE_CHARGE <- TRUE
}

.tu <- new.env(parent = emptyenv())
.tu$lignes <- data.frame(fichier = character(0), nom = character(0),
                         statut = character(0), message = character(0),
                         stringsAsFactors = FALSE)
.tu$fichier <- "?"

debut_fichier <- function(nom) {
  .tu$fichier <- nom
  .tu$t0 <- Sys.time()
  cat(sprintf("\n== %s\n", nom))
}

.enregistrer <- function(nom, statut, message = "") {
  .tu$lignes[nrow(.tu$lignes) + 1, ] <- list(.tu$fichier, nom, statut, message)
  marque <- switch(statut, OK = "ok  ", ECHEC = "ECHEC", ATTENDU = "xfail",
                   INATTENDU = "XPASS")
  if (statut != "OK" || isTRUE(getOption("tu.verbeux")))
    cat(sprintf("  [%s] %s%s\n", marque, nom,
                if (nzchar(message)) paste0("\n          -> ", message) else ""))
}

# Evalue expr dans l'environnement appelant ; renvoie list(ok, message).
# Les avertissements sont neutralises sans reevaluation : seuls comptent la
# valeur renvoyee et les erreurs.
.evaluer <- function(expr_sub, env) {
  r <- tryCatch(withCallingHandlers(eval(expr_sub, env),
                                    warning = function(w) invokeRestart("muffleWarning")),
                error = function(e) e)
  if (inherits(r, "error")) return(list(ok = FALSE, message = paste("erreur :", conditionMessage(r))))
  if (isTRUE(r)) return(list(ok = TRUE, message = ""))
  list(ok = FALSE, message = if (is.character(r)) paste(r, collapse = " ; ")
                             else paste("valeur obtenue :", paste(format(r), collapse = " ")))
}

verifier <- function(nom, expr) {
  r <- .evaluer(substitute(expr), parent.frame())
  .enregistrer(nom, if (r$ok) "OK" else "ECHEC", r$message)
  invisible(r$ok)
}

echec_attendu <- function(nom, constat, expr) {
  r <- .evaluer(substitute(expr), parent.frame())
  if (r$ok) .enregistrer(nom, "INATTENDU",
                         paste("le defaut semble corrige (", constat,
                               ") : transformer ce test en test ordinaire"))
  else .enregistrer(paste0(nom, "  {", constat, "}"), "ATTENDU", "")
  invisible(!r$ok)
}

# Egalite numerique elementwise : |a - b| <= abs + rel * |b|. Renvoie TRUE ou
# un message decrivant le plus grand ecart (affiche en cas d'echec).
proche <- function(a, b, rel = 1e-10, abs = 0) {
  a <- unname(as.numeric(a)); b <- unname(as.numeric(b))
  if (length(a) != length(b)) return(sprintf("longueurs %d et %d", length(a), length(b)))
  if (any(is.na(a) != is.na(b))) return("NA a des positions differentes")
  k <- !is.na(a)
  e <- abs(a[k] - b[k]); lim <- abs + rel * abs(b[k])
  if (all(e <= lim)) return(TRUE)
  i <- which.max(e - lim)
  sprintf("ecart max %.3g (obtenu %.12g, attendu %.12g, tolerance %.3g)",
          e[i], a[k][i], b[k][i], lim[i])
}

leve_erreur <- function(expr) inherits(tryCatch(expr, error = function(e) e), "error")

bilan_fichier <- function() {
  d <- .tu$lignes[.tu$lignes$fichier == .tu$fichier, ]
  cat(sprintf("   %d assertions : %d ok, %d echec(s), %d echec(s) attendu(s), %d succes inattendu(s)  (%.1f s)\n",
              nrow(d), sum(d$statut == "OK"), sum(d$statut == "ECHEC"),
              sum(d$statut == "ATTENDU"), sum(d$statut == "INATTENDU"),
              as.numeric(difftime(Sys.time(), .tu$t0, units = "secs"))))
}

# Code de sortie : 1 si au moins un echec ou un succes inattendu.
terminer <- function() {
  d <- .tu$lignes
  n_ko <- sum(d$statut %in% c("ECHEC", "INATTENDU"))
  cat(sprintf("\nTOTAL : %d assertions, %d ok, %d echec(s), %d echec(s) attendu(s) (defauts connus), %d succes inattendu(s)\n",
              nrow(d), sum(d$statut == "OK"), sum(d$statut == "ECHEC"),
              sum(d$statut == "ATTENDU"), sum(d$statut == "INATTENDU")))
  if (n_ko) {
    cat("\nECHEC\n")
    quit(status = 1)
  }
  cat("OK\n")
  invisible(TRUE)
}

# Lancement autonome d'un fichier de test : Rscript tests/unitaires/test_x.R
# (le lanceur tests/test_unitaires.R definit LANCEUR_UNITAIRES et appelle
# terminer() lui-meme).
fin_fichier <- function() {
  bilan_fichier()
  if (!exists("LANCEUR_UNITAIRES", inherits = TRUE)) terminer()
}

# --- Detail des lignes de test : deux phrases et 400 caracteres (#514) --------
# Specification d'actuary (docs/revues/20261109-detail-deux-phrases/), regles
# (P), (L1) et (L2) ; decisions Q-1 a Q-5 du mainteneur du 09/11/2026. Outils
# partages par tests/unitaires/test_detail_deux_phrases.R (A0 a A4) et par les
# fichiers qui appellent verifier_detail() sur les objets qu'ils construisent
# (A3, branches rares).
PLAFOND_TEXTE_PROPRE <- 400L
PHRASES_MAX <- 2L
# Copie de .ABREV_FIN_PHRASE (R/display_helpers.R), recopiee ici pour que le
# controle ne depende pas de l'affichage.
ABREV_FIN_PHRASE_514 <- c("al", "cf", "p", "pp", "vol", "no", "ed", "eds", "ch",
                          "sect", "fig", "eq", "approx", "resp")

# Regle (P) : nombre de phrases de x (chaine de longueur 1). Fin de phrase :
# "." suivi d'une espace puis d'un caractere non blanc (toute casse), ou ";"
# suivi d'une espace, a profondeur nulle de parentheses et de crochets
# (profondeur comptee depuis le debut du texte, sans descendre sous 0). Un "."
# ne compte pas s'il suit un mot de ABREV_FIN_PHRASE_514 ou une lettre isolee
# precedee d'un "." ("i.i.d."). "!" et "?" ne comptent pas. Nombre de fins + 1 ;
# texte vide ou NA : 0.
compter_phrases <- function(x) {
  if (length(x) != 1L || is.na(x) || !nzchar(x)) return(0L)
  car <- strsplit(x, "", fixed = TRUE)[[1]]
  n <- length(car)
  delta <- (car %in% c("(", "[")) - (car %in% c(")", "]"))
  prof <- integer(n); p <- 0L
  for (i in seq_len(n)) { prof[i] <- p; p <- max(0L, p + delta[i]) }
  fins <- 0L
  for (i in seq_len(n - 1L)) {
    if (prof[i] != 0L) next
    if (car[i] == ";" && car[i + 1L] == " ") { fins <- fins + 1L; next }
    if (car[i] == "." && car[i + 1L] == " " && i + 2L <= n && !grepl("\\s", car[i + 2L])) {
      avant <- substr(x, 1L, i - 1L)
      mot <- regmatches(avant, regexpr("[\\p{L}\\p{N}_]+$", avant, perl = TRUE))
      if (length(mot)) {
        if (tolower(mot) %in% ABREV_FIN_PHRASE_514) next
        if (grepl("^\\p{L}$", mot, perl = TRUE) && i >= 3L && car[i - 2L] == ".") next
      }
      fins <- fins + 1L
    }
  }
  fins + 1L
}

# Mentions conditionnelles M1 a M16 (specification, par. 2), hors compte :
# expressions regulieres (perl) construites a partir des constantes et des
# gabarits du moteur. rx_fixe() echappe un texte fixe.
rx_fixe <- function(s) gsub("([][{}()+*^$|\\\\.?])", "\\\\\\1", s)
.rx_motif <- "(?:[^.]|\\.(?! ))+?"                      # texte sans ". "
.rx_par <- "\\((?:[^()]|\\([^()]*\\))*\\)"              # parenthese, un niveau imbrique
.rx_num <- "-?[0-9][0-9.e+-]*"
# Gabarit de .mw_phrase_b_effectif() rendu en expression : nombres 900, 999
# et 99 remplaces par \d+ (texte fixe du moteur, aucun nombre recopie).
.rx_b_effectif <- function(plafond, motif = NA_character_, p = 0.5) {
  boot <- list(B = 999, B_effectif = c(S = if (is.na(p)) 30 else 900), p_mc = c(S = p),
               plafond_cumuls = plafond, motif_mc = c(S = motif))
  s <- rx_fixe(.mw_phrase_b_effectif(boot, "S"))
  gsub("\\b(900|999|99|30)\\b", "\\\\d+", s)
}
MENTIONS <- local({
  deg <- paste(rx_fixe(MOTIFS_MC_DEGENERES), collapse = "|")
  compl <- paste0("(?: ", rx_fixe(DETAIL_MC_ATOME_HORS_OBS), ")?")
  eff_mw <- paste0("(?:(?:colonnes n_j|diagonales n_k|residus par annee de survenance|",
                   "paires de colonnes n_k) = [0-9, ]+|n1 = \\d+, n2 = \\d+)")
  list(
    M1_degenere = paste0("^(?:", deg, ") : aucune p-value retenue\\.", compl),
    M3 = paste0("^Monte-Carlo indisponible : ", .rx_motif, ", .+? non retenue\\.(?= |$)"),
    M1_indisponible = paste0("^Monte-Carlo indisponible : ", .rx_motif, "\\.(?= |$)"),
    M2 = paste0("^", rx_fixe(MOTIF_MC_OBS_NON_FINIE), " : test non applicable\\."),
    M4 = paste0("TEST INOPERANT au seuil alpha = \\S+ : p-value minimale atteignable",
                "(?: sous la loi de reference echangeable)? = ", .rx_num,
                "(?: ", .rx_par, ")?, aucun verdict\\."),
    M5 = paste0("TEST INOPERANT au seuil alpha = \\S+ : plus petite p-value Monte-Carlo ",
                "atteignable sur ces replications >= alpha(?: ", .rx_par, ")?, aucun verdict\\."),
    M6_exacte = paste0("ECHEC inatteignable : p_min = ", .rx_num, " >= alpha/2 = ", .rx_num,
                       "(?: ", .rx_par, ")?"),
    M6_mc = paste0("ECHEC inatteignable : plus petite p-value Monte-Carlo atteignable sur ces ",
                   "replications >= alpha/2 = ", .rx_num, "(?: ", .rx_par, ")?"),
    M7 = paste0("p_min de la loi de reference echangeable = ", .rx_num, " >= alpha/2 = ",
                .rx_num, "(?: ", .rx_par, ")?",
                "(?:, mais la p-value Monte-Carlo retenue, simulee sous le modele ajuste, ",
                "peut lui etre inferieure \\(erreur Monte-Carlo, non-echangeabilite\\) : ",
                "ECHEC possible)?"),
    M8_rangs = paste0("T = \\d+, ex aequo dans (?:r et x|r|x) : loi conditionnelle non ",
                      "tabulee, p_min et p exacte non attribuees\\.?$"),
    M8_smirnov = "n1 = \\d+, n2 = \\d+, ex aequo dans z : p_min et p exacte non attribuees\\.?$",
    M8_mw = paste0(eff_mw, ", (?:ex aequo : loi de permutation conditionnelle non tabulee, ",
                   "p_min non attribuee|colonne de plus de \\d+ facteurs : p_j de Spearman ",
                   "par approximation de Student relevee au plancher 2/n!, loi de reference ",
                   "non tabulee, p_min non attribuee|p_min = k! prod n_i! / N! hors de la ",
                   "precision de la machine \\(N = \\d+\\) : p_min non calculable|p_min non ",
                   "calculable sur ces effectifs, p_min non attribuee)\\.?$"),
    M9 = paste0("^(?:Monte-Carlo indisponible : ", .rx_motif, ", )?aucune p-value ",
                "disponible sur ces donnees : aucun verdict\\."),
    M10 = paste0("plancher Monte-Carlo >= alpha(?:/2)? = \\S+ : ",
                 "(?:OK inatteignable|seul OK atteignable|ECHEC inatteignable)"),
    M11 = rx_fixe(PHRASE_VERDICT_SENSIBLE_MC),
    M12_retires = rx_fixe(PHRASE_MW_CUMULS_RETIRES),
    M12_plafond = rx_fixe(PHRASE_MW_PLAFOND_CUMULS),
    M13_a = .rx_b_effectif(FALSE),
    M13_a_plafond = .rx_b_effectif(TRUE),
    M13_b = .rx_b_effectif(FALSE, MOTIF_MC_REPLIC_INSUFFISANTES, NA_real_),
    M14 = paste0("Colonnes? (?:degenerees? \\(.*?\\)|a moins de (?:deux|trois) valeurs ",
                 "distinctes de C\\(i,j\\)) : j = .+?, exclusion qui ne vaut pas preuve ",
                 "[^.]+\\."),
    M15_a = rx_fixe(PHRASE_FAMILLE_B_EFF_REDUIT),
    M15_b = paste0("^", rx_fixe(PHRASE_FAMILLE_B_EFF_INSUFFISANT)),
    M16 = paste0("^", .rx_motif, " : aucune p-value Monte-Carlo\\.", compl),
    # Mentions de regime (#514, decision Q-6 ; specification finale, par. 2) :
    # constantes du moteur reconnues litteralement, M18 par son gabarit.
    M17a = rx_fixe(MENTION_PI_VARIABLE_TEST),
    M17a_sans_mc = rx_fixe(MENTION_PI_VARIABLE_TEST_SANS_MC),
    M17b = rx_fixe(MENTION_PI_VARIABLE_DIAG),
    M18 = paste0("pi_t n'est constant qu'a la tolerance TOL_DELTA_BORD = [0-9.eE+-]+ pres ",
                 "\\([^()]+\\) : la loi exacte, etablie pour pi_t exactement constant, ne ",
                 "vaut ici qu'a un ecart de cet ordre pres\\."),
    M19 = rx_fixe(MENTION_H3_PI_VARIABLE),
    M20a = rx_fixe(MENTION_DELTA_BORNE_1),
    M20b = rx_fixe(MENTION_VOLUMES_CONSTANTS),
    M21 = rx_fixe(MENTION_EDGEWORTH),
    M22 = rx_fixe(MENTION_PERMUTATIONS_ALEATOIRES))
})
# Mentions conditionnelles presentes dans un detail (noms de MENTIONS).
mentions_presentes <- function(x) {
  if (length(x) != 1L || is.na(x)) return(character(0))
  names(MENTIONS)[vapply(MENTIONS, function(rx) grepl(rx, x, perl = TRUE), logical(1))]
}

# Regle (L1) : texte propre d'un detail, prive de ses mentions (dans l'ordre
# de MENTIONS), puis des " ; " et espaces restes en bord. Passes repetees
# jusqu'a stabilite : une mention ancree en fin de texte (M8) n'y est qu'une
# fois retirees celles qui la suivent (M10, M11).
texte_propre <- function(x) {
  if (length(x) != 1L || is.na(x)) return(NA_character_)
  repeat {
    x0 <- x
    for (rx in MENTIONS) x <- gsub(rx, "", x, perl = TRUE)
    x <- gsub("^[ ;]+|[ ;]+$", "", gsub("  +", " ", x))
    if (identical(x, x0)) break
  }
  x
}

# Controle (A4) : chaque ligne de lignes (liste de lignes de res$tests, ou
# objet usp_engine) a un texte propre d'au plus PHRASES_MAX phrases et
# PLAFOND_TEXTE_PROPRE caracteres, non vide hors ligne non applicable (les
# mentions de regime, constantes du moteur, font une phrase : A1). Une assertion par appel ; le message nomme
# les lignes fautives.
verifier_detail <- function(lignes, contexte) {
  if (inherits(lignes, "usp_engine") || (is.list(lignes) && !is.null(lignes$tests)))
    lignes <- lignes$tests
  fautes <- character(0)
  for (l in lignes) {
    tp <- texte_propre(l$detail)
    if (is.na(tp)) next
    np <- compter_phrases(tp); nc <- nchar(tp)
    if (np > PHRASES_MAX || nc > PLAFOND_TEXTE_PROPRE)
      fautes <- c(fautes, sprintf("%s (%d phrases, %d caracteres) : %s", l$test, np, nc, tp))
    # Ligne de type test ou diagnostic : texte propre non vide (#514, A2).
    if (!identical(l$type, "non applicable") && !nzchar(tp))
      fautes <- c(fautes, sprintf("%s : texte propre vide", l$test))
  }
  verifier(sprintf("#514 detail : %s, texte propre <= %d phrases et <= %d caracteres",
                   contexte, PHRASES_MAX, PLAFOND_TEXTE_PROPRE),
           if (!length(fautes)) TRUE else paste(fautes, collapse = " | "))
}
