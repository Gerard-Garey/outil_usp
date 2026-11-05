###############################################################################
#  tests/unitaires/test_outdec.R  --  TEXTES ET EXPORT XLSX DE REPLI
#                                     INDEPENDANTS DE getOption("OutDec")
#                                     (ISSUE #428, suite de #413)
#
#  format(), paste() et sprintf("%s") d'un double suivent l'option de session
#  OutDec ; sprintf("%f"/"%g") ne la suit pas. Deux garanties :
#    1. a donnees, parametres et graine identiques, run_engine() rend un objet
#       identical() sous options(OutDec = ",") et sous ".", donc des detail,
#       avertissements et refus en point decimal (partie I du .tex, graphie
#       des textes produits par le moteur ; ADR 0006) ;
#    2. l'ecrivain xlsx de repli d'engine_ecrire_xlsx() ecrit les nombres en
#       point decimal et pleine precision (15 chiffres quand ils suffisent,
#       sinon 17) : aller-retour sans perte par le lecteur interne, sous les
#       deux options. L'absence d'openxlsx est simulee en posant
#       requireNamespace() dans environment(run_engine), jamais dans
#       l'environnement global (ADR 0016).
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_outdec.R")

# Execute expr sous OutDec = od et restaure l'option en sortie, erreur comprise.
sous_outdec <- function(od, expr) {
  avant <- options(OutDec = od)
  on.exit(options(avant), add = TRUE)
  force(expr)
}
sans_horloge <- function(res) {
  res$metadata[c("horodatage", "duree_sec", "version_R")] <- NULL
  res
}
# Toutes les chaines d'un objet, a plat (detail, erreurs, avertissements...)
chaines <- function(o) {
  if (is.character(o)) o
  else if (is.list(o)) unlist(lapply(o, chaines), use.names = FALSE)
  else character(0)
}

x428 <- c(104.20, 102.25, 109.34, 114.64, 118.41, 121.28, 132.40, 131.22)
y428 <- c(68.97, 76.76, 83.49, 95.38, 88.96, 70.22, 78.89, 117.37)
tri428 <- as.matrix(utils::read.csv(file.path(RACINE, "tests", "donnees", "triangle_mw.csv"))[, -1])
tri428 <- unname(tri428); storage.mode(tri428) <- "double"

## --- 1. run_engine() sous OutDec = "," ----------------------------------------
verifier("OutDec : l'option est restituee par sous_outdec(), erreur comprise",
         {
           options(OutDec = ".")
           try(sous_outdec(",", stop("x")), silent = TRUE)
           identical(getOption("OutDec"), ".")
         })

# reserve2 : triangle du depot (colonnes degenerees non concernees) ; B reduit,
# la comparaison porte sur deux appels de meme graine.
r2_pt <- sous_outdec(".", sans_horloge(run_engine(methode = "reserve2", triangle = tri428,
                                                  segment = 1, annexe = "II", B = 99)))
r2_vg <- sous_outdec(",", sans_horloge(run_engine(methode = "reserve2", triangle = tri428,
                                                  segment = 1, annexe = "II", B = 99)))
verifier("OutDec : run_engine(reserve2) sous \",\" identique a celui sous \".\"",
         isTRUE(r2_pt$ok) && identical(r2_pt, r2_vg))
verifier("OutDec : reserve2, des detail portent un nombre decimal en point, aucun en virgule",
         any(grepl("[0-9]\\.[0-9]", chaines(r2_vg$tests))) &&
           !any(grepl("[0-9],[0-9]{3,}", chaines(r2_vg$tests))))

ln_pt <- sous_outdec(".", sans_horloge(run_engine(xt = x428, yt = y428, methode = "premium",
                                                  segment = 1, annexe = "II",
                                                  nature_donnees = "brutes", B = 99)))
ln_vg <- sous_outdec(",", sans_horloge(run_engine(xt = x428, yt = y428, methode = "premium",
                                                  segment = 1, annexe = "II",
                                                  nature_donnees = "brutes", B = 99)))
verifier("OutDec : run_engine(premium) sous \",\" identique a celui sous \".\"",
         isTRUE(ln_pt$ok) && identical(ln_pt, ln_vg))

# Refus et avertissements : textes de mw_valider_ajustement() et de la saisie
tri_neg <- tri428; tri_neg[1, 2] <- 0.5 * tri_neg[1, 1]
rf_pt <- sous_outdec(".", sans_horloge(run_engine(methode = "reserve2", triangle = tri_neg,
                                                  segment = 1, annexe = "II", B = 99)))
rf_vg <- sous_outdec(",", sans_horloge(run_engine(methode = "reserve2", triangle = tri_neg,
                                                  segment = 1, annexe = "II", B = 99)))
verifier("OutDec : triangle a cumuls decroissants (refus ou avertissements), identique sous \",\" et \".\"",
         identical(rf_pt, rf_vg))
msg_seg <- function(od) sous_outdec(od, tryCatch(
  run_engine(xt = x428, yt = y428, methode = "premium", segment = 1.5, annexe = "II",
             nature_donnees = "brutes", B = 99),
  error = function(e) conditionMessage(e)))
verifier("OutDec : segment non entier, le refus d'usage cite 1.5 en point, sous \",\" comme sous \".\"",
         is.character(msg_seg(".")) && grepl("1.5", msg_seg(","), fixed = TRUE) &&
           identical(msg_seg(","), msg_seg(".")))

# Triangle degenere a facteurs individuels non entiers (colonne J-1 = 1.0457 x
# colonne J-2, colonne J = 1.0123 x colonne J-1) : exerce les textes chiffres de
# mw_valider_ajustement() (facteurs f_j, variances, repere de l'extrapolation).
tri_deg <- tri428; J428 <- ncol(tri_deg)
for (i in seq_len(nrow(tri_deg))) {
  if (!is.na(tri_deg[i, J428 - 1]) && !is.na(tri_deg[i, J428 - 2]))
    tri_deg[i, J428 - 1] <- 1.0457 * tri_deg[i, J428 - 2]
  if (!is.na(tri_deg[i, J428])) tri_deg[i, J428] <- 1.0123 * tri_deg[i, J428 - 1]
}
dg_pt <- sous_outdec(".", sans_horloge(run_engine(methode = "reserve2", triangle = tri_deg,
                                                  segment = 1, annexe = "II", B = 99)))
dg_vg <- sous_outdec(",", sans_horloge(run_engine(methode = "reserve2", triangle = tri_deg,
                                                  segment = 1, annexe = "II", B = 99)))
verifier("OutDec : triangle degenere a facteurs 1.0457 et 1.0123, identique sous \",\" et \".\"",
         isTRUE(dg_pt$ok) && identical(dg_pt, dg_vg) &&
           any(grepl("facteurs individuels", chaines(dg_pt), fixed = TRUE) &
                 grepl("1.0457", chaines(dg_pt), fixed = TRUE)))

# Points d'entree appeles directement par l'application : meme resultat sous
# les deux options, sur des entrees qui produisent des messages chiffres non
# entiers. `chiffre` : le resultat contient bien un nombre en point decimal.
x_bas <- x428; x_bas[8] <- 1e-9
# Resultat avec sigma standard saisi : engine_derogations() n'a de ligne que
# pour une derogation (valeur retenue 0.1234567 contre 0.1 reglementaire).
ln_sg <- sans_horloge(run_engine(xt = x428, yt = y428, methode = "premium", segment = 1,
                                 annexe = "II", nature_donnees = "brutes", B = 99,
                                 sigma_standard = 0.1234567))
tri_bas <- tri428; tri_bas[2, 2] <- 0.5 * tri_bas[2, 1]
entrees <- list(
  engine_valider_donnees = function() engine_valider_donnees(
    x_bas, y428, theta_equiv = 0.37, delta_equiv = 1e9),
  engine_valider_serie_retenue = function() engine_valider_serie_retenue(
    x428, y428, T = 5.5),
  engine_valider_profondeur = function() engine_valider_profondeur(5.5, 8),
  mw_valider_triangle = function() mw_valider_triangle(tri_bas),
  engine_motif_b_alpha = function() engine_motif_b_alpha(99, 0.037),
  engine_table_tests = function() engine_table_tests(ln_pt),
  engine_derogations = function() engine_derogations(ln_sg))
for (nm in names(entrees)) {
  f <- entrees[[nm]]
  a <- sous_outdec(".", f()); b <- sous_outdec(",", f())
  verifier(sprintf("OutDec : %s() identique sous \",\" et \".\"", nm),
           identical(a, b) && length(chaines(a)) > 0L)
}
verifier("OutDec : engine_valider_profondeur(5.5, 8) cite 5.5 en point sous \",\"",
         any(grepl("5.5", sous_outdec(",", engine_valider_profondeur(5.5, 8)), fixed = TRUE)))

# Noms de .engine_quantile() : identiques a stats::quantile() sous ".", quel que
# soit le nombre de probabilites (formatC sous 100, format() a partir de 100),
# et en point decimal sous ",".
z150 <- sin(seq_len(200))
for (pr in list(c(.025, .05, .5, .95, .975), ppoints(8), ppoints(99), ppoints(100), ppoints(150))) {
  ref <- sous_outdec(".", stats::quantile(z150, pr, type = 7))
  verifier(sprintf(".engine_quantile() : %d probabilites, noms et valeurs de stats::quantile() sous \".\"", length(pr)),
           identical(sous_outdec(".", .engine_quantile(z150, pr)), ref))
  verifier(sprintf(".engine_quantile() : %d probabilites, memes noms sous \",\" que sous \".\", sans virgule", length(pr)),
           identical(names(sous_outdec(",", .engine_quantile(z150, pr))), names(ref)) &&
             !any(grepl(",", names(sous_outdec(",", .engine_quantile(z150, pr))), fixed = TRUE)))
}

## --- 2. xlsx de repli : aller-retour a pleine precision ------------------------
if (nzchar(Sys.which("zip"))) {
  env_moteur <- environment(run_engine)
  # Simule l'absence d'openxlsx (ecrivain ET lecteur de repli) ; retire a la sortie
  sans_openxlsx <- function(expr) {
    assign("requireNamespace", function(package, ...) FALSE, envir = env_moteur)
    on.exit(rm("requireNamespace", envir = env_moteur), add = TRUE)
    force(expr)
  }
  df <- data.frame(
    t = 2001:2009,
    v = c(0.123456789012, 0.5, 1/3, 0.1 + 0.2, 1e-300, 1.7976931348623157e308,
          123456789.123456789, -2.5e-8, 1e5),
    n = c(2001, 2, 3, 4, 5, 6, 7, 8, 1e15),
    f = c(Inf, -Inf, 1, 2, 3, 4, 5, 6, 7),
    lib = c("a", "b", "c", "d", "e", "f", "g", "h", "i"),
    stringsAsFactors = FALSE)
  df$v[9] <- NA_real_
  aller_retour <- function(od) {
    f <- tempfile(fileext = ".xlsx"); on.exit(unlink(f), add = TRUE)
    sous_outdec(od, sans_openxlsx({ engine_ecrire_xlsx(df, f); engine_lire_xlsx(f) }))
  }
  lu_pt <- aller_retour("."); lu_vg <- aller_retour(",")
  verifier("xlsx de repli : requireNamespace() simule restitue le moteur intact",
           !exists("requireNamespace", envir = env_moteur, inherits = FALSE))
  verifier("xlsx de repli : aller-retour sans perte (17 chiffres significatifs) sous \".\"",
           identical(as.numeric(lu_pt$v), df$v) && identical(as.numeric(lu_pt$n), df$n) &&
             identical(as.numeric(lu_pt$f), df$f) && identical(as.integer(lu_pt$t), df$t) &&
             identical(as.character(lu_pt$lib), df$lib))
  # +-Inf : chaine en ligne dans le classeur. Le lecteur interne les relit en
  # numerique ; openxlsx, s'il est installe, les relit en chaine.
  verifier("xlsx de repli : +-Inf relus en numerique par le lecteur interne, en chaine par openxlsx",
           {
             f <- tempfile(fileext = ".xlsx"); on.exit(unlink(f), add = TRUE)
             sans_openxlsx(engine_ecrire_xlsx(df, f))
             interne <- is.numeric(lu_pt$f) && identical(lu_pt$f[1:2], c(Inf, -Inf))
             externe <- if (base::requireNamespace("openxlsx", quietly = TRUE))
               identical(as.character(openxlsx::read.xlsx(f)$f[1:2]), c("Inf", "-Inf")) else TRUE
             interne && externe
           })
  verifier("xlsx de repli : aller-retour sans perte sous OutDec = \",\", identique a celui sous \".\"",
           identical(lu_vg, lu_pt))
  verifier("xlsx de repli : le XML ecrit sous OutDec = \",\" n'a ni virgule decimale ni troncature a 7 chiffres",
           {
             f <- tempfile(fileext = ".xlsx"); d <- tempfile("lec_")
             on.exit({ unlink(f); unlink(d, recursive = TRUE) }, add = TRUE)
             sous_outdec(",", sans_openxlsx(engine_ecrire_xlsx(df, f)))
             utils::unzip(f, exdir = d)
             xml <- paste(readLines(file.path(d, "xl", "worksheets", "sheet1.xml"), warn = FALSE),
                          collapse = "")
             v <- gsub("</?v>", "", regmatches(xml, gregexpr("<v>[^<]*</v>", xml))[[1]])
             !any(grepl(",", v)) && all(grepl("^-?[0-9.]+(e[-+][0-9]+)?$", v)) &&
               "0.123456789012" %in% v && "0.5" %in% v && "2001" %in% v
           })
} else cat("  [saute] xlsx de repli : commande zip indisponible\n")

fin_fichier()
