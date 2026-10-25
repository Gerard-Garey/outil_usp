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
#    - cas A au plafond du retirage de #257 (boot$plafond_cumuls TRUE) :
#      phrase "B effectif = %d sur B = %d (%d replication(s) manquante(s) :
#      plafond de tirages atteint et, le cas echeant, statistique non
#      finie) : ..." (#279, texte approuve par le mainteneur le 14/10/2026) ;
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
# Cas A au plafond du retirage de #257 (#279 ; texte approuve par le
# mainteneur le 14/10/2026).
phrase_a_plafond <- function(be, B)
  sprintf(paste("B effectif = %d sur B = %d (%d replication(s) manquante(s) : plafond de",
                "tirages atteint et, le cas echeant, statistique non finie) : p-value",
                "Monte-Carlo comptee sur les seules replications ou la statistique est finie ;",
                "les replications perdues au plafond le sont independamment de la valeur de",
                "la statistique, l'absence de biais de la selection par statistique non finie",
                "n'est pas demontree."),
          be, B, B - be)
a_beff <- function(l) grepl("B effectif =", l$detail, fixed = TRUE)
# detail sans la phrase de #244, posee en dernier par add() (elle suit donc
# la phrase de #204 quand les deux sont presentes).
sans_244 <- function(d) sub(paste0(" ", PHRASE_VERDICT_SENSIBLE_MC), "", d, fixed = TRUE)

## --- Triangle ta_pert(9e-13) (Taylor & Ashe, colonne 6 presque degeneree) ------
# Meme triangle que U181-7 (test_sans_repli_p_non_simulee.R) et ta_pert() de
# test_merz_wuthrich.R : B_eff < B pour Origine, HomogF, Courbure et, depuis
# #300, MinP4 (colonne retenue devenue degeneree dans la replication : t NA,
# statistique NA, volet 2 de #56 ; 67 sur 99 et 42 sur 60 mesures, comme les
# trois autres) ; B_eff = B sur les neuf autres statistiques Monte-Carlo. Valeurs mesurees (R 4.3.x,
# Linux) : 67 sur 99 et 42 sur 60. La perturbation est placee a la
# tolerance : ces comptes peuvent varier entre plateformes ; les assertions
# portent sur des relations (B_eff < B, B_eff >= B_MIN_DEGENERESCENCE pour le
# cas A, < B_MIN_DEGENERESCENCE pour le cas B, nombres de la phrase egaux a
# boot$B_effectif, boot$B et leur difference), pas sur ces comptes (constat
# C3 d'audit, revue finale d'E2b).
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
# Ligne de cellule aberrante (#300, cle MinP4) : B_eff < B sur ce triangle,
# assertions propres (libelle de sa p non simulee : borne de Bonferroni).
NOM_MINP4 <- "Cellule aberrante du triangle (residus studentises externes)"
noms4 <- c(names(noms3), "MinP4")

## --- T1 (cas A) : B = 99 ---------------------------------------------------------
bt99 <- mw_bootstrap(aj204, B = 99); tm99 <- mw_tests(aj204, bt99)
# B effectif de chaque statistique des trois lignes (67 mesure).
be99 <- as.integer(bt99$B_effectif[names(noms3)]); names(be99) <- names(noms3)
pa99 <- function(nm) phrase_a(be99[[nm]], as.integer(bt99$B))
verifier("T1 ta_pert(9e-13), B = 99 : B_MIN_DEGENERESCENCE <= B_eff < B sur Origine, HomogF, Courbure et MinP4 (#300), B ailleurs",
         identical(as.integer(bt99$B), 99L) &&
           all(bt99$B_effectif[noms4] < bt99$B) && all(bt99$B_effectif[noms4] >= B_MIN_DEGENERESCENCE) &&
           all(bt99$B_effectif[setdiff(names(bt99$B_effectif), noms4)] == bt99$B) &&
           all(is.finite(bt99$p_mc)))
verifier("T1 MinP4 (#300) : phrase A en fin du detail (avant la phrase de #244), jointe par ' ' apres le point final, p Monte-Carlo retenue",
         {
           l <- ligne(tm99, NOM_MINP4); d <- sans_244(l$detail)
           pa <- phrase_a(as.integer(bt99$B_effectif[["MinP4"]]), as.integer(bt99$B))
           endsWith(d, paste0(". ", pa)) &&
             lengths(regmatches(l$detail, gregexpr("B effectif =", l$detail, fixed = TRUE))) == 1L &&
             identical(l$type, "test") && identical(l$p_retenue, l$p_mc)
         })
verifier("T1 Origine, HomogF, Courbure : phrase A (B_eff, B, B - B_eff ; 67, 99, 32 mesures) en fin du detail (avant la phrase de #244)",
         all(vapply(names(noms3), function(nm) {
           l <- ligne(tm99, noms3[[nm]]); d <- sans_244(l$detail)
           endsWith(d, pa99(nm)) &&
             grepl(sprintf("B effectif = %d sur B = %d (%d replication(s)", be99[[nm]],
                           as.integer(bt99$B), as.integer(bt99$B) - be99[[nm]]), d, fixed = TRUE) &&
             lengths(regmatches(l$detail, gregexpr("B effectif =", l$detail, fixed = TRUE))) == 1L &&
             identical(l$type, "test") && identical(l$p_retenue, l$p_mc)
         }, logical(1))))
verifier("T1 HomogF et Courbure finissent par la phrase A ; Origine par la phrase A puis celle de #244",
         endsWith(ligne(tm99, noms3[["HomogF"]])$detail, pa99("HomogF")) &&
           endsWith(ligne(tm99, noms3[["Courbure"]])$detail, pa99("Courbure")) &&
           endsWith(ligne(tm99, noms3[["Origine"]])$detail,
                    paste(pa99("Origine"), PHRASE_VERDICT_SENSIBLE_MC)))
verifier("T1 jonction exacte (regle de jonction d'add()) : ' ' apres un point (Origine), ' ; ' sinon (HomogF, Courbure)",
         endsWith(sans_244(ligne(tm99, noms3[["Origine"]])$detail),
                  paste0("colonne par colonne. ", pa99("Origine"))) &&
           grepl(paste0("Fisher ; ", pa99("HomogF")), ligne(tm99, noms3[["HomogF"]])$detail,
                 fixed = TRUE) &&
           grepl(paste0("est nulle ; ", pa99("Courbure")), ligne(tm99, noms3[["Courbure"]])$detail,
                 fixed = TRUE))
verifier("T1 les autres lignes (dix lignes Monte-Carlo comprises) ne contiennent pas 'B effectif ='",
         {
           autres <- Filter(function(l) !l$test %in% c(noms3, NOM_MINP4), tm99)
           !any(vapply(autres, a_beff, logical(1))) &&
             # Lignes de famille et ligne globale (#297) : p Monte-Carlo
             # externe (p_mc_ext), hors du compte des 13 statistiques.
             sum(vapply(tm99, function(l) is.finite(l$p_mc) &&
                          !identical(l$fonction, "engine_p_famille"), logical(1))) == 13L
         })

## --- T2 (cas B) : B = 60 ---------------------------------------------------------
bt60 <- mw_bootstrap(aj204, B = 60); tm60 <- mw_tests(aj204, bt60)
# B effectif de chaque statistique des trois lignes (42 mesure).
be60 <- as.integer(bt60$B_effectif[names(noms3)]); names(be60) <- names(noms3)
verifier("T2 ta_pert(9e-13), B = 60 : 0 < B_eff < B_MIN_DEGENERESCENCE (< B), motif replications insuffisantes",
         identical(as.integer(bt60$B), 60L) &&
           all(be60 > 0L) && all(be60 < B_MIN_DEGENERESCENCE) && all(be60 < bt60$B) &&
           all(bt60$motif_mc[names(noms3)] == MOTIF_MC_REPLIC_INSUFFISANTES))
verifier("T2 Origine, HomogF, Courbure : diagnostic de #181, detail fini par 'B effectif = <B_eff> sur B = <B>.' (42 et 60 mesures)",
         all(vapply(names(noms3), function(nm) {
           l <- ligne(tm60, noms3[[nm]])
           endsWith(l$detail, phrase_b(be60[[nm]], as.integer(bt60$B))) &&
             !grepl("conditionnelle a la definition", l$detail, fixed = TRUE) &&
             lengths(regmatches(l$detail, gregexpr("B effectif =", l$detail, fixed = TRUE))) == 1L &&
             identical(l$type, "diagnostic") && identical(l$verdict, "INFO") && is.na(l$p_retenue) &&
             startsWith(l$detail, paste0("Monte-Carlo indisponible : ", MOTIF_MC_REPLIC_INSUFFISANTES,
                                         " ; p non simulee (loi du champ loi) non retenue (ADR 0001)."))
         }, logical(1))))
verifier("T2 MinP4 (#300) : 0 < B_eff < B_MIN_DEGENERESCENCE, diagnostic de #181 (borne de Bonferroni non retenue), detail fini par 'B effectif = <B_eff> sur B = <B>.'",
         {
           be <- as.integer(bt60$B_effectif[["MinP4"]]); l <- ligne(tm60, NOM_MINP4)
           be > 0L && be < B_MIN_DEGENERESCENCE &&
             identical(unname(bt60$motif_mc[["MinP4"]]), MOTIF_MC_REPLIC_INSUFFISANTES) &&
             endsWith(l$detail, phrase_b(be, as.integer(bt60$B))) &&
             identical(l$type, "diagnostic") && identical(l$verdict, "INFO") && is.na(l$p_retenue) &&
             startsWith(l$detail, paste0("Monte-Carlo indisponible : ", MOTIF_MC_REPLIC_INSUFFISANTES,
                                         " ; borne de Bonferroni min(1, N_t M) non retenue (ADR 0001)."))
         })
verifier("T2 les autres lignes ne contiennent pas 'B effectif ='",
         !any(vapply(Filter(function(l) !l$test %in% c(noms3, NOM_MINP4), tm60), a_beff, logical(1))))

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
# Objets synthetiques a B effectif distinct des comptes mesures (67, 42) :
# une phrase dont les nombres seraient codes en dur ne passe pas (reprise du
# constat d'audit, revue finale d'E2b).
verifier("T4 .mw_phrase_b_effectif() synthetique : cas A (B_eff = 80, p_mc finie) et cas B (B_eff = 30, motif replications insuffisantes)",
         {
           b_a <- bt99; b_a$B_effectif[["Origine"]] <- 80
           b_b <- boot_motif(MOTIF_MC_REPLIC_INSUFFISANTES, 30)
           is.finite(b_a$p_mc[["Origine"]]) &&
             identical(.mw_phrase_b_effectif(b_a, "Origine"), phrase_a(80L, 99L)) &&
             identical(.mw_phrase_b_effectif(b_b, "Origine"), phrase_b(30L, as.integer(bt99$B)))
         })
verifier("T4 .mw_phrase_b_effectif() : cas A, cas B et B_eff = B (lecture de boot$B_effectif et boot$B)",
         identical(.mw_phrase_b_effectif(bt99, "Origine"), pa99("Origine")) &&
           identical(.mw_phrase_b_effectif(bt60, "HomogF"),
                     phrase_b(be60[["HomogF"]], as.integer(bt60$B))) &&
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
# Ordre des refus (constat M1 de l'audit de #204) : une statistique absente de
# tout le bootstrap (ni p_mc ni B_effectif) est refusee par add() ("absente du
# bootstrap"), pas par .mw_phrase_b_effectif(), qui n'est appelee que pour une
# statistique presente dans boot$p_mc.
verifier("T4 statistique absente de p_mc et de B_effectif : refus d'add() 'absente du bootstrap : Calendrier'",
         {
           sans_cal <- bt99
           sans_cal$p_mc <- bt99$p_mc[names(bt99$p_mc) != "Calendrier"]
           sans_cal$B_effectif <- bt99$B_effectif[names(bt99$B_effectif) != "Calendrier"]
           m <- tryCatch({ mw_tests(aj204, sans_cal); NA_character_ },
                         error = function(e) conditionMessage(e))
           !is.na(m) && grepl("add() : statistique Monte-Carlo absente du bootstrap : Calendrier", m,
                              fixed = TRUE) && !grepl(".mw_phrase_b_effectif()", m, fixed = TRUE)
         })

## --- #279 : cas A au plafond du retirage (plafond_cumuls TRUE) -----------------------
# Objets synthetiques tires de bt99 (plafond non atteint, plafond_cumuls FALSE) :
# seul plafond_cumuls est force. B effectif 80, B 99 : les trois nombres de la
# phrase sont lus dans l'objet (une phrase codee en dur ne passe pas).
verifier("#279 cas A au plafond (B_eff = 80, B = 99, plafond_cumuls TRUE) : phrase du plafond, trois nombres seuls (80, 99, 19)",
         {
           b <- bt99; b$B_effectif[["Origine"]] <- 80; b$plafond_cumuls <- TRUE
           ph <- .mw_phrase_b_effectif(b, "Origine")
           identical(bt99$plafond_cumuls, FALSE) && is.finite(b$p_mc[["Origine"]]) &&
             identical(ph, phrase_a_plafond(80L, 99L)) &&
             identical(regmatches(ph, gregexpr("[0-9]+", ph))[[1]], c("80", "99", "19")) &&
             !grepl("ecartee(s), statistique non finie", ph, fixed = TRUE)
         })
verifier("#279 plafond_cumuls FALSE : cas A inchange ; plafond_cumuls TRUE et motif replications insuffisantes : cas B inchange",
         {
           b_f <- bt99; b_f$B_effectif[["Origine"]] <- 80; b_f$plafond_cumuls <- FALSE
           b_b <- boot_motif(MOTIF_MC_REPLIC_INSUFFISANTES, 30); b_b$plafond_cumuls <- TRUE
           identical(.mw_phrase_b_effectif(b_f, "Origine"), phrase_a(80L, 99L)) &&
             identical(.mw_phrase_b_effectif(b_b, "Origine"), phrase_b(30L, 99L))
         })
verifier("#279 plafond_cumuls lu au cas A seulement : absent, NA ou 0 refuse (jamais devine) ; ignore hors cas A",
         {
           msg <- function(b) tryCatch({ .mw_phrase_b_effectif(b, "Origine"); NA_character_ },
                                       error = function(e) conditionMessage(e))
           base <- bt99; base$B_effectif[["Origine"]] <- 80
           sans <- base; sans$plafond_cumuls <- NULL
           b_na <- base; b_na$plafond_cumuls <- NA
           b_0 <- base; b_0$plafond_cumuls <- 0
           m <- vapply(list(sans, b_na, b_0), msg, character(1))
           # hors cas A (B_eff = B ; cas B) : plafond_cumuls absent n'est pas lu
           hors_a <- bt99; hors_a$plafond_cumuls <- NULL
           hors_b <- boot_motif(MOTIF_MC_REPLIC_INSUFFISANTES, 30); hors_b$plafond_cumuls <- NULL
           all(!is.na(m)) &&
             all(grepl("plafond_cumuls absent ou non booleen dans le bootstrap (Origine)", m, fixed = TRUE)) &&
             identical(.mw_phrase_b_effectif(hors_a, "Alpha"), "") &&
             identical(.mw_phrase_b_effectif(hors_b, "Origine"), phrase_b(30L, 99L)) &&
             # par mw_tests(), le refus vient d'abord de .mw_phrases_retirage()
             # (#257), evaluee avant .mw_phrase_b_effectif() : message verifie
             grepl("mw_phrases_retirage",
                   tryCatch({ mw_tests(aj204, sans); "" },
                            error = function(e) conditionMessage(e)), fixed = TRUE)
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
# Trois gabarits "B effectif = %d" : cas A, cas A au plafond (#279), cas B.
verifier("add() (engine_registre_tests) ne pose aucune phrase 'B effectif' ; seul .mw_phrase_b_effectif() l'ecrit",
         {
           src <- readLines(file.path(.racine204, "R", "engine.R"), warn = FALSE)
           code <- sub("#.*$", "", src)
           ici <- grep("B effectif = %d", code, fixed = TRUE)
           deb <- grep("^\\.mw_phrase_b_effectif <- function", src)
           fin <- deb + which(src[(deb + 1):length(src)] == "}")[1]
           !any(grepl("B effectif", deparse(engine_registre_tests), fixed = TRUE)) &&
             length(ici) == 3L && all(ici > deb & ici < fin)
         })

fin_fichier()
