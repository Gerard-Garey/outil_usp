###############################################################################
#  tests/unitaires/test_non_applicable.R  --  UNE LIGNE NON APPLICABLE NE
#                                              RESTITUE AUCUNE P-VALUE (#427)
#
#  Regle (avis 0b (ii) d'actuary-approfondi, decision Q-47-7 (a) du
#  04/11/2026) : une ligne d'usp_tests() de type "non applicable" a p_exacte,
#  p_asymptotique, p_mc et p_retenue a NA ; la statistique peut rester dans
#  `stat`. Les lignes de famille d'engine_p_famille() sont hors de la regle.
#  La regle n'est pas posee dans add() : chaque ligne porte son predicat.
#  Cas fautif d'origine : la ligne Fisher a F non fini (ajustement exact du
#  modele auxiliaire MCO) restituait p_asymptotique = lmc$p_F = 0.
#  Jeux : volumes constants, pertes constantes, R12 (T = 200, reg ecarte par
#  lm()), ajustement exact (x = 1:8, y = 2x), et le jeu J1 (non degenere,
#  non-regression).
#  #533 (decisions Q-A, Q-A2, Q-C du 11/11/2026) : une ligne non applicable a
#  aussi loi = NA_character_ (usp_tests() ligne par ligne, add() pour R3).
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_non_applicable.R")

NOM_FISHER  <- "Test de Fisher (significativite globale)"
NOM_STUDENT <- "Test de Student sur la pente (modele auxiliaire MCO)"

# Objet bootstrap fictif (aucune simulation) : p Monte-Carlo a 0,5 sur les
# statistiques finies, motif d'observee non finie sur les autres (comme le
# garde-fou R12 de test_volumes_constants.R).
boot_fictif <- function(f) {
  s <- .stats_bootstrapables(f$x, f$y, f$z, f$pi)
  pm <- stats::setNames(rep(0.5, length(s)), names(s))
  pm[is.na(s)] <- NA_real_
  mm <- stats::setNames(rep(NA_character_, length(s)), names(s))
  mm[is.na(s)] <- MOTIF_MC_OBS_NON_FINIE
  list(stats_obs = as.list(s), p_mc = pm, err_mc = pm * 0 + 0.01, motif_mc = mm)
}
tests_du_jeu <- function(x, y) {
  f <- suppressWarnings(usp_ajuster(x, y))
  suppressWarnings(usp_tests(f, boot_fictif(f), methode = "premium"))
}
hors_famille <- function(tt) Filter(function(l) !identical(l$fonction, "engine_p_famille"), tt)
ligne <- function(tt, nom) Filter(function(l) identical(l$test, nom), tt)[[1]]

# Lignes non applicables qui restituent une p-value, avec le champ en cause.
fautives <- function(tt) {
  out <- character(0)
  for (l in hors_famille(tt)) if (identical(l$type, "non applicable")) {
    for (ch in c("p_exacte", "p_asymptotique", "p_mc", "p_retenue"))
      if (!is.na(l[[ch]])) out <- c(out, sprintf("%s : %s = %s", l$test, ch, format(l[[ch]])))
  }
  out
}

x1 <- c(104.20, 102.25, 109.34, 114.64, 118.41, 121.28, 132.40, 131.22)
y1 <- c(68.97, 76.76, 83.49, 95.38, 88.96, 70.22, 78.89, 117.37)

# Scenario R12 de test_volumes_constants.R (graine 59, sans toucher a l'alea global).
xa <- rep(110, 200); xa[2] <- 110 * (1 + 1.1e-6)
ya <- engine_sous_graine(59, xa * 0.8 * exp(stats::rnorm(200, 0, 0.1)))

jeux <- list(
  "volumes constants"                = list(x = rep(110, 8), y = y1),
  "pertes constantes"                = list(x = x1, y = rep(70, 8)),
  "R12 (T = 200, reg ecarte)"        = list(x = xa, y = ya),
  "ajustement exact (x = 1:8, y = 2x)" = list(x = as.numeric(1:8), y = 2 * as.numeric(1:8)),
  "J1 (non degenere)"                = list(x = x1, y = y1))
res <- lapply(jeux, function(j) tests_du_jeu(j$x, j$y))

for (nm in names(jeux)) local({
  nom <- nm; tt <- res[[nom]]
  verifier(sprintf("%s : aucune ligne non applicable (hors engine_p_famille) ne restitue de p-value", nom),
           {
             pb <- fautives(tt)
             if (length(pb)) paste(pb, collapse = " ; ") else TRUE
           })
  verifier(sprintf("%s : Fisher non applicable <=> Student non applicable", nom),
           identical(ligne(tt, NOM_FISHER)$type == "non applicable",
                     ligne(tt, NOM_STUDENT)$type == "non applicable"))
})

## Les jeux degeneres exercent bien la regle (garde contre un test vide).
for (nm in setdiff(names(jeux), "J1 (non degenere)")) local({
  nom <- nm; tt <- res[[nom]]
  verifier(sprintf("%s : Fisher et Student sont non applicables (le test exerce la regle)", nom),
           ligne(tt, NOM_FISHER)$type == "non applicable" &&
             ligne(tt, NOM_STUDENT)$type == "non applicable")
})

## Non-regression : sur J1, Fisher reste applicable et sa p asymptotique finie.
verifier("J1 : Fisher et Student diagnostics, p_asymptotique finie et egale entre les deux lignes",
         {
           lf <- ligne(res[["J1 (non degenere)"]], NOM_FISHER)
           ls <- ligne(res[["J1 (non degenere)"]], NOM_STUDENT)
           lf$type == "diagnostic" && ls$type == "diagnostic" &&
             is.finite(lf$p_asymptotique) && is.finite(ls$p_asymptotique) &&
             abs(lf$p_asymptotique - ls$p_asymptotique) < 1e-12
         })

## --- #533 (decisions Q-A, Q-A2, Q-C du 11/11/2026) : loi NA ------------------
# Une ligne non applicable n'a aucune p-value, donc aucune loi de reference :
# loi = NA_character_, posee ligne par ligne dans usp_tests() et, pour la
# regle R3, dans add().
lois_non_na <- function(tt) {
  out <- character(0)
  for (l in hors_famille(tt)) if (identical(l$type, "non applicable") &&
                                  !identical(l$loi, NA_character_))
    out <- c(out, sprintf("%s : loi = %s", l$test, format(l$loi)))
  out
}
for (nm in names(jeux)) local({
  nom <- nm; tt <- res[[nom]]
  verifier(sprintf("#533 %s : toute ligne non applicable a loi NA", nom),
           { pb <- lois_non_na(tt); if (length(pb)) paste(pb, collapse = " ; ") else TRUE })
})

# Entree minimale de #533 : T = 5, volumes constants, pi_t constant,
# n1 = n2 = 1 sur z et sur u (17 lignes non applicables, mesure du 11/11/2026).
res533 <- suppressWarnings(run_engine(xt = rep(100, 5), yt = c(60, 80, 80, 80, 110),
                                      methode = "reserve1", segment = 1, annexe = "II", B = 99))
verifier("#533 entree minimale : 17 lignes non applicables, toutes a loi NA",
         {
           na533 <- Filter(function(l) identical(l$type, "non applicable"), hors_famille(res533$tests))
           pb <- lois_non_na(res533$tests)
           if (length(pb)) paste(pb, collapse = " ; ") else length(na533) == 17L
         })
# Lignes de suites (Q-C) : loi NA ; detail inchange par #533 (texte releve
# avant la modification, moteur de 49f4600).
DETAIL_SUITES_533 <- paste("une seule valeur de chaque cote de la mediane (n1 = n2 = 1) : R = 2",
                           "pour tout arrangement, loi de R degeneree (variance nulle), test non",
                           "applicable")
for (nm in c("Test des suites (aleatoire des signes)", "Test des suites sur ratios bruts")) local({
  nom <- nm
  verifier(sprintf("#533 entree minimale, %s : non applicable, loi NA, detail inchange", nom),
           {
             l <- ligne(res533$tests, nom)
             identical(l$type, "non applicable") && identical(l$loi, NA_character_) &&
               identical(l$detail, DETAIL_SUITES_533)
           })
})

# Six references versionnees (une ligne non applicable par cas lognormal,
# aucune en reserve2 ; leur egalite au moteur courant est controlee par
# tests/test_reproductibilite.R).
verifier("#533 references versionnees (6 cas) : toute ligne non applicable a loi NA",
         {
           cas <- c("premium", "reserve1", "reserve2", "premium_ii6", "premium_net", "premium_interieur")
           v <- vapply(cas, function(k) {
             f <- file.path(RACINE, "tests", "reference", paste0(k, ".rds"))
             if (!file.exists(f)) return("reference absente")
             pb <- lois_non_na(readRDS(f)$tests)
             if (length(pb)) paste(pb, collapse = " ; ") else ""
           }, character(1))
           if (all(v == "")) TRUE else paste(cas[v != ""], v[v != ""], collapse = " ; ")
         })

# Regle R3 d'add() (registre fictif, comme test_inoperance.R) : statistique
# observee non finie, sans p exacte -> non applicable ; le loi recu de
# l'appelant est remplace par NA (#533, Q-A2).
verifier("#533 add(), regle R3 : ligne rendue non applicable a loi NA malgre un loi fourni",
         {
           r <- engine_registre_tests(
             list(p_mc = c(S = NA_real_), err_mc = c(S = NA_real_),
                  motif_mc = c(S = MOTIF_MC_OBS_NON_FINIE)),
             list(S = .mc_entree(function(e) 1, "haut")), 0.10, "Monte-Carlo")
           r$add("F", "t", "ref", fonction = "usp_tests", loi = "chi2(1) asymptotique",
                 p_as = 0.3, mc_nom = "S", detail = "d.")
           l <- r$lignes()[[1]]
           identical(l$type, "non applicable") && identical(l$loi, NA_character_)
         })

fin_fichier()
