###############################################################################
#  tests/unitaires/test_b_effectif_mw.R  --  B EFFECTIF < B SUR LES LIGNES
#                                            MONTE-CARLO DE MERZ-WUTHRICH
#                                            (ISSUE #204)
#
#  Specification commune d'E2b (docs/specifications/e2b-doctrine-p-monte-carlo.md,
#  section 6, tests T1 a T5 re-specifies, approuves en D1-6 ; decision du
#  mainteneur du 12/10/2026, commentaire 6120564480 de #204 ; ADR 0003 annote
#  le 12/10/2026, point 4) :
#    - cas A (p_mc finie, B_effectif < B) : phrase "B effectif = %d sur B = %d
#      (%d replication(s) ecartee(s), statistique non finie) : p-value
#      Monte-Carlo conditionnelle a la definition de la statistique, ..." ;
#    - cas B (motif MOTIF_MC_REPLIC_INSUFFISANTES) : "B effectif = %d sur B = %d." ;
#    - exception a la regle #76 bornee a ces deux phrases, posees par
#      mw_tests() seul via .mw_phrase_b_effectif() ; add() n'est pas touchee ;
#    - MOTIF_MC_AUCUNE_REPLIC, motifs degeneres, lignes lognormales : aucune
#      phrase ;
#    - refus explicite (jamais devine) si boot$B ou boot$B_effectif[[mc_nom]]
#      manque (reprise de #204, Q3 d'actuary).
#  Les six references identiques (T3 pour reserve2) sont portees par
#  tests/test_reproductibilite.R.
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_b_effectif_mw.R")

.racine204 <- if (exists("RACINE", inherits = TRUE)) RACINE else
              if (file.exists("R/engine.R")) "." else if (file.exists("../R/engine.R")) ".." else "../.."

phrase_a <- function(be, B)
  sprintf(paste("B effectif = %d sur B = %d (%d replication(s) ecartee(s), statistique",
                "non finie) : p-value Monte-Carlo conditionnelle a la definition de la",
                "statistique, comptee sur les seules replications ou elle est finie ;",
                "l'absence de biais de cette selection n'est pas demontree."),
          be, B, B - be)
phrase_b <- function(be, B) sprintf("B effectif = %d sur B = %d.", be, B)
a_beff <- function(l) grepl("B effectif =", l$detail, fixed = TRUE)
# detail sans la phrase de #244, posee en dernier par add() (elle suit donc
# la phrase de #204 quand les deux sont presentes).
sans_244 <- function(d) sub(paste0(" ", PHRASE_VERDICT_SENSIBLE_MC), "", d, fixed = TRUE)

## --- Triangle ta_pert(9e-13) (Taylor & Ashe, colonne 6 presque degeneree) ------
# Meme triangle que U181-7 (test_sans_repli_p_non_simulee.R) et ta_pert() de
# test_merz_wuthrich.R : B_eff = 67 sur 99 et 42 sur 60 pour Origine, HomogF,
# Courbure ; B_eff = B sur les dix autres statistiques Monte-Carlo.
ta204 <- matrix(c(357848, 352118, 290507, 310608, 443160, 396132, 440832, 359480, 376686, 344014,
  1124788, 1236139, 1292306, 1418858, 1136350, 1333217, 1288463, 1421128, 1363294, NA,
  1735330, 2170033, 2218525, 2195047, 2128333, 2180715, 2419861, 2864498, NA, NA,
  2218270, 3353322, 3235179, 3757447, 2897821, 2985752, 3483130, NA, NA, NA,
  2745596, 3799067, 3985995, 4029929, 3402672, 3691712, NA, NA, NA, NA,
  3319994, 4120063, 4132918, 4381982, 3873311, NA, NA, NA, NA, NA,
  3466336, 4647867, 4628910, 4588268, NA, NA, NA, NA, NA, NA,
  3606286, 4914039, 4909315, NA, NA, NA, NA, NA, NA, NA,
  3833515, 5339085, NA, NA, NA, NA, NA, NA, NA, NA,
  3901463, NA, NA, NA, NA, NA, NA, NA, NA, NA), 10, 10)
ta204[1:5, 6] <- 1.05 * ta204[1:5, 5]
ta204[1:5, 6] <- ta204[1:5, 6] * (1 + c(1, -1, 1, -1, 1) * 9e-13)
aj204 <- mw_ajuster(ta204)
noms3 <- c(Origine = "Nullite de l'ordonnee a l'origine, colonne par colonne",
           HomogF = "Homogeneite de f_j entre annees de survenance",
           Courbure = "Absence de courbure de la regression")
ligne <- function(tm, n) Filter(function(l) identical(l$test, n), tm)[[1]]

## --- T1 (cas A) : B = 99 ---------------------------------------------------------
bt99 <- mw_bootstrap(aj204, B = 99); tm99 <- mw_tests(aj204, bt99)
verifier("T1 ta_pert(9e-13), B = 99 : B_eff = 67 sur Origine, HomogF, Courbure, 99 ailleurs",
         identical(unname(bt99$B_effectif[names(noms3)]), c(67, 67, 67)) &&
           all(bt99$B_effectif[setdiff(names(bt99$B_effectif), names(noms3))] == 99) &&
           all(is.finite(bt99$p_mc)))
verifier("T1 Origine, HomogF, Courbure : phrase A (67, 99, 32) en fin du detail (avant la phrase de #244)",
         all(vapply(noms3, function(n) {
           l <- ligne(tm99, n); d <- sans_244(l$detail)
           endsWith(d, phrase_a(67L, 99L)) &&
             lengths(regmatches(l$detail, gregexpr("B effectif =", l$detail, fixed = TRUE))) == 1L &&
             identical(l$type, "test") && identical(l$p_retenue, l$p_mc)
         }, logical(1))))
verifier("T1 HomogF et Courbure finissent par la phrase A ; Origine par la phrase A puis celle de #244",
         endsWith(ligne(tm99, noms3[["HomogF"]])$detail, phrase_a(67L, 99L)) &&
           endsWith(ligne(tm99, noms3[["Courbure"]])$detail, phrase_a(67L, 99L)) &&
           endsWith(ligne(tm99, noms3[["Origine"]])$detail,
                    paste(phrase_a(67L, 99L), PHRASE_VERDICT_SENSIBLE_MC)))
verifier("T1 jonction exacte (regle de jonction d'add()) : ' ' apres un point (Origine), ' ; ' sinon (HomogF, Courbure)",
         endsWith(sans_244(ligne(tm99, noms3[["Origine"]])$detail),
                  paste0("colonne par colonne. ", phrase_a(67L, 99L))) &&
           grepl(paste0("Fisher ; ", phrase_a(67L, 99L)), ligne(tm99, noms3[["HomogF"]])$detail,
                 fixed = TRUE) &&
           grepl(paste0("est nulle ; ", phrase_a(67L, 99L)), ligne(tm99, noms3[["Courbure"]])$detail,
                 fixed = TRUE))
verifier("T1 les autres lignes (dix lignes Monte-Carlo comprises) ne contiennent pas 'B effectif ='",
         {
           autres <- Filter(function(l) !l$test %in% noms3, tm99)
           !any(vapply(autres, a_beff, logical(1))) &&
             sum(vapply(tm99, function(l) is.finite(l$p_mc), logical(1))) == 13L
         })

## --- T2 (cas B) : B = 60 ---------------------------------------------------------
bt60 <- mw_bootstrap(aj204, B = 60); tm60 <- mw_tests(aj204, bt60)
verifier("T2 ta_pert(9e-13), B = 60 : B_eff = 42, motif replications insuffisantes",
         identical(unname(bt60$B_effectif[names(noms3)]), c(42, 42, 42)) &&
           all(bt60$motif_mc[names(noms3)] == MOTIF_MC_REPLIC_INSUFFISANTES))
verifier("T2 Origine, HomogF, Courbure : diagnostic de #181, detail fini par 'B effectif = 42 sur B = 60.'",
         all(vapply(noms3, function(n) {
           l <- ligne(tm60, n)
           endsWith(l$detail, phrase_b(42L, 60L)) &&
             !grepl("conditionnelle a la definition", l$detail, fixed = TRUE) &&
             lengths(regmatches(l$detail, gregexpr("B effectif =", l$detail, fixed = TRUE))) == 1L &&
             identical(l$type, "diagnostic") && identical(l$verdict, "INFO") && is.na(l$p_retenue) &&
             startsWith(l$detail, paste0("Monte-Carlo indisponible : ", MOTIF_MC_REPLIC_INSUFFISANTES,
                                         " ; p non simulee (loi du champ loi) non retenue (ADR 0001)."))
         }, logical(1))))
verifier("T2 les autres lignes ne contiennent pas 'B effectif ='",
         !any(vapply(Filter(function(l) !l$test %in% noms3, tm60), a_beff, logical(1))))

## --- T3 : reserve2 (reference versionnee) ---------------------------------------
# Lecture de tests/reference/reserve2.rds au lieu d'un run_engine() a B = 999
# (environ 27 s) : l'egalite du moteur a cette reference, detail compris, est
# portee par tests/test_reproductibilite.R.
r2 <- readRDS(file.path(.racine204, "tests", "reference", "reserve2.rds"))
verifier("T3 reserve2 (reference) : B_eff = B sur les 13 statistiques, aucune ligne ne contient 'B effectif ='",
         isTRUE(r2$ok) && length(r2$bootstrap$B_effectif) == 13L &&
           all(r2$bootstrap$B_effectif == r2$bootstrap$B) &&
           !any(vapply(r2$tests, a_beff, logical(1))))

## --- T4 : MOTIF_MC_AUCUNE_REPLIC, motifs degeneres, observee non finie -------------
# Objet bootstrap de B = 99, la statistique Origine forcee a chaque motif
# (p_mc et err_mc NA), B_effectif 0 pour MOTIF_MC_AUCUNE_REPLIC, 67 sinon.
boot_motif <- function(motif, be) {
  b <- bt99
  b$p_mc[["Origine"]] <- NA_real_; b$err_mc[["Origine"]] <- NA_real_
  b$motif_mc[["Origine"]] <- motif; b$B_effectif[["Origine"]] <- be
  b
}
motifs_t4 <- list(c(MOTIF_MC_AUCUNE_REPLIC, 0), c(MOTIF_MC_DISPERSION_NULLE, 67),
                  c(MOTIF_MC_ATOME_HORS_OBS, 67), c(MOTIF_MC_CONDITION, 67),
                  c(MOTIF_MC_OBS_NON_FINIE, 67))
for (m in motifs_t4) local({
  b <- boot_motif(m[[1]], as.numeric(m[[2]]))
  l <- ligne(mw_tests(aj204, b), noms3[["Origine"]])
  verifier(sprintf("T4 motif '%s' (B_eff = %s) : aucune phrase de #204", m[[1]], m[[2]]),
           identical(.mw_phrase_b_effectif(b, "Origine"), "") && !a_beff(l) &&
             grepl(m[[1]], l$detail, fixed = TRUE))
})
verifier("T4 .mw_phrase_b_effectif() : cas A, cas B et B_eff = B (lecture de boot$B_effectif et boot$B)",
         identical(.mw_phrase_b_effectif(bt99, "Origine"), phrase_a(67L, 99L)) &&
           identical(.mw_phrase_b_effectif(bt60, "HomogF"), phrase_b(42L, 60L)) &&
           identical(.mw_phrase_b_effectif(bt99, "Alpha"), "") &&
           identical(.mw_phrase_b_effectif(bt60, "Alpha"), ""))
verifier("T4 refus explicite (jamais devine) : B absent ou non fini, mc_nom absent de B_effectif",
         {
           msg <- function(b) tryCatch({ .mw_phrase_b_effectif(b, "Origine"); NA_character_ },
                                       error = function(e) conditionMessage(e))
           sans_b <- bt99; sans_b$B <- NULL
           b_na <- bt99; b_na$B <- NA_real_
           sans_be <- bt99; sans_be$B_effectif <- NULL
           be_partiel <- bt99; be_partiel$B_effectif <- bt99$B_effectif[names(bt99$B_effectif) != "Origine"]
           m <- vapply(list(sans_b, b_na, sans_be, be_partiel,
                            list(p_mc = c(Origine = 0.5))), msg, character(1))
           all(!is.na(m)) && all(grepl("B absent ou non fini", m[1:2], fixed = TRUE)) &&
             all(grepl("B effectif absent ou non fini dans le bootstrap : Origine", m[3:4], fixed = TRUE)) &&
             leve_erreur(mw_tests(aj204, sans_b))
         })

## --- T5 : lignes lognormales ---------------------------------------------------------
# J1 : donnees_ln.csv (delta estime = 1) ; J2 : jeu a delta estime interieur
# (V3b) ; usp_bootstrap(B = 40) : B_eff < B_MIN_DEGENERESCENCE partout.
d204 <- utils::read.csv(file.path(.racine204, "tests", "donnees", "donnees_ln.csv"))
xi204 <- c(50, 80, 120, 200, 300, 150, 90, 60)
yi204 <- c(29.92, 56.9, 101.25, 123.06, 207.23, 105.91, 68.59, 40.05)
lignes_usp <- function(x, y, B) {
  f <- usp_ajuster(x, y); usp_tests(f, usp_bootstrap(f, B = B), methode = "premium")
}
for (j in list(list("J1", d204$xt, d204$yt, 40), list("J2 (V3b)", xi204, yi204, 40),
               list("J2 (V3b)", xi204, yi204, 199))) local({
  tt <- lignes_usp(j[[2]], j[[3]], j[[4]])
  verifier(sprintf("T5 %s, B = %d : aucune ligne d'usp_tests() ne contient 'B effectif ='", j[[1]], j[[4]]),
           length(tt) > 0L && !any(vapply(tt, a_beff, logical(1))))
})
verifier("T5 premium_interieur (reference versionnee) : aucune ligne ne contient 'B effectif ='",
         {
           ref <- readRDS(file.path(.racine204, "tests", "reference", "premium_interieur.rds"))
           length(ref$tests) > 0L && !any(vapply(ref$tests, a_beff, logical(1)))
         })

## --- Exception a la regle #76 bornee a mw_tests() ------------------------------------
verifier("add() (engine_registre_tests) ne pose aucune phrase 'B effectif' ; seul .mw_phrase_b_effectif() l'ecrit",
         {
           src <- readLines(file.path(.racine204, "R", "engine.R"), warn = FALSE)
           code <- sub("#.*$", "", src)
           ici <- grep("B effectif = %d", code, fixed = TRUE)
           deb <- grep("^\\.mw_phrase_b_effectif <- function", src)
           fin <- deb + which(src[(deb + 1):length(src)] == "}")[1]
           !any(grepl("B effectif", deparse(engine_registre_tests), fixed = TRUE)) &&
             length(ici) == 2L && all(ici > deb & ici < fin)
         })

bilan_fichier()
