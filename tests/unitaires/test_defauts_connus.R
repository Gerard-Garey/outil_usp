###############################################################################
#  tests/unitaires/test_defauts_connus.R  --  DEFAUTS OUVERTS (ISSUES #3, #4)
#
#  Chaque defaut connu est documente par un test "echec attendu" : le test
#  decrit le comportement CORRECT et echoue tant que le defaut subsiste. Quand
#  une issue est resolue, le test passe, est signale "succes inattendu" et fait
#  echouer la batterie : il faut alors le transformer en test ordinaire.
#  Les tests ordinaires de ce fichier verifient la coherence actuelle des noms
#  Monte-Carlo, dont depend l'absence d'erreur silencieuse.
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_defauts_connus.R")

x <- c(104.20, 102.25, 109.34, 114.64, 118.41, 121.28, 132.40, 131.22)
y <- c(68.97, 76.76, 83.49, 95.38, 88.96, 70.22, 78.89, 117.37)
fit <- usp_ajuster(x, y)                       # delta = 1 (au bord)
s_obs <- .stats_bootstrapables(fit$x, fit$y, fit$z)
# Objet bootstrap fictif (aucune simulation) : toutes les p Monte-Carlo a 0,5.
boot_fictif <- function(sans = character(0)) {
  p <- stats::setNames(rep(0.5, length(s_obs)), names(s_obs))
  p <- p[setdiff(names(p), sans)]
  list(stats_obs = as.list(s_obs), p_mc = p, err_mc = p * 0 + 0.01)
}
mc_noms <- function(f) {
  txt <- paste(deparse(f), collapse = " ")
  unique(gsub("mc_nom = |\"", "", regmatches(txt, gregexpr("mc_nom = \"[^\"]+\"", txt))[[1]]))
}
noms_ln <- mc_noms(usp_tests); noms_mw <- mc_noms(mw_tests)
tri_mw <- local({
  d <- utils::read.csv(file.path(RACINE, "tests", "donnees", "triangle_mw.csv"))
  m <- as.matrix(d[, setdiff(names(d), "i")]); storage.mode(m) <- "double"; unname(m)
})
s_mw <- .mw_stats(mw_ajuster(tri_mw))

## --- Issue #4, piste 1 : noms Monte-Carlo -------------------------------------
verifier("Lognormal : chaque mc_nom de usp_tests() est une statistique simulee",
         if (all(noms_ln %in% names(s_obs))) TRUE
         else paste("inconnus :", paste(setdiff(noms_ln, names(s_obs)), collapse = ", ")))
verifier("Merz-Wuthrich : chaque mc_nom de mw_tests() est une statistique simulee",
         if (all(noms_mw %in% names(s_mw))) TRUE
         else paste("inconnus :", paste(setdiff(noms_mw, names(s_mw)), collapse = ", ")))
verifier("usp_tests() sur un bootstrap complet : hierarchie exacte > Monte-Carlo > asymptotique",
         {
           tt <- usp_tests(fit, boot_fictif())
           ok <- TRUE
           for (l in tt) {
             attendu <- if (is.finite(l$p_exacte)) l$p_exacte
                        else if (is.finite(l$p_mc)) l$p_mc else l$p_asymptotique
             ok <- ok && (identical(is.na(attendu), is.na(l$p_retenue)) &&
                          (is.na(attendu) || attendu == l$p_retenue)) &&
                   (is.na(l$p_retenue) || (l$p_retenue >= 0 && l$p_retenue <= 1))
           }
           ok
         })
echec_attendu("add() refuse un mc_nom absent du bootstrap (erreur explicite)",
              "issue #4 : gp() renvoie NA, repli silencieux sur la p asymptotique",
              leve_erreur(usp_tests(fit, boot_fictif(sans = "RESET"))))
echec_attendu("Toute statistique simulee est exploitee par un test (pas d'orpheline)",
              "issue #4 : LB2r et BP2r simulees mais jamais affichees",
              {
                orph <- setdiff(names(s_obs), noms_ln)
                if (length(orph)) paste("orphelines :", paste(orph, collapse = ", ")) else TRUE
              })
echec_attendu("Centrage des residus : statistique affichee = statistique simulee",
              "issue #4 : t de Student affiche, p Monte-Carlo calculee sur MeanZ = mean(z)",
              {
                l <- Filter(function(l) l$test == "Centrage des residus standardises",
                            usp_tests(fit, boot_fictif()))[[1]]
                isTRUE(proche(l$stat, s_obs[["MeanZ"]], rel = 1e-12))
              })

## --- Issue #3 : test de centrage degenere quand delta est au bord -------------
verifier("Issue #3 (constat) : delta au bord et moyenne des z nulle par construction",
         isTRUE(fit$delta_au_bord) && abs(s_obs[["MeanZ"]]) < 1e-12)
echec_attendu("Centrage des residus : non applicable (verdict INFO) quand delta est au bord",
              "issue #3 : test presente comme un vrai test, p Monte-Carlo sur du bruit d'arrondi",
              {
                l <- Filter(function(l) l$test == "Centrage des residus standardises",
                            usp_tests(fit, boot_fictif()))[[1]]
                l$type != "test" || identical(l$verdict, "INFO")
              })

## --- Issue #4, piste 2 : etat du generateur aleatoire -------------------------
echec_attendu("sw_loi_nulle() ne cree pas de .Random.seed s'il n'en existait pas",
              "issue #4 : l'etat n'est restaure que s'il existait",
              {
                if (exists(".Random.seed", envir = globalenv()))
                  rm(".Random.seed", envir = globalenv())
                sw_loi_nulle(10, B_null = 200, seed = 11)
                r <- !exists(".Random.seed", envir = globalenv())
                set.seed(401)
                r
              })
echec_attendu("usp_bootstrap() restaure l'etat du generateur de l'appelant",
              "issue #4 : set.seed(seed) sans restauration",
              {
                set.seed(402); avant <- .Random.seed
                usp_bootstrap(fit, B = 3, seed = 1)
                identical(avant, .Random.seed)
              })

fin_fichier()
