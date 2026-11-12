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
#    2. l'ecrivain xlsx interne d'engine_ecrire_xlsx() (seul depuis #488) ecrit les nombres en
#       point decimal et pleine precision (15 chiffres quand ils suffisent,
#       sinon 17) : aller-retour sans perte par le lecteur interne, sous les
#       deux options. L'absence d'openxlsx est simulee en posant
#       requireNamespace() dans environment(run_engine), jamais dans
#       l'environnement global (ADR 0016).
#    3. garantie a la racine (#439) : chacun des 16 points d'entree que
#       l'application appelle (app.R, R/display_helpers.R) pose
#       options(OutDec = ".") par .engine_point_decimal() et restaure l'option
#       de l'appelant en sortie, normale ou sur erreur (ADR 0004, par analogie).
#       Les decimal.mark appel par appel (#428) restent : les sections 1 et 2
#       les exercent encore, par des fonctions qui ne sont pas des points
#       d'entree (.engine_quantile()).
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
  # Simule l'absence d'openxlsx et de zip (lecteur de repli ; ecrivain interne
  # compresse par utils::zip(), #488) ; retire a la sortie
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
  # +-Inf : chaine en ligne dans le classeur. Le lecteur interne et openxlsx,
  # s'il est installe, les relisent en chaine : la colonne porte une cellule
  # texte et reste en caractere dans le lecteur interne (#490).
  verifier("xlsx de repli : +-Inf relus en chaine par le lecteur interne (colonne en caractere) et par openxlsx",
           {
             f <- tempfile(fileext = ".xlsx"); on.exit(unlink(f), add = TRUE)
             sans_openxlsx(engine_ecrire_xlsx(df, f))
             interne <- is.character(lu_pt$f) && identical(lu_pt$f[1:2], c("Inf", "-Inf"))
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

## --- 3. Point d'entree : OutDec = "." local, option de l'appelant restituee (#439) ---
env_moteur439 <- environment(run_engine)
pe_moteur439 <- get(".engine_point_decimal", envir = env_moteur439)

# Les 16 points d'entree : les fonctions du moteur que app.R et
# R/display_helpers.R appellent directement (inventaire de l'etape 1 de K2,
# 12 + 7 dont 3 communes, plus engine_ecrire_csv(), nee en K2, #488). Les appels
# directs documentes de fonctions qui n'en sont pas (test_mann_kendall(),
# dw_p_exacte()...) ne sont pas enveloppes : les decimal.mark y suffisent.
PE439 <- c("run_engine", "engine_lire_xlsx", "engine_lire_donnees_csv",
           "engine_lire_triangle", "engine_ecrire_xlsx", "engine_ecrire_csv",
           "engine_valider_donnees", "engine_valider_serie_retenue",
           "engine_valider_profondeur", "mw_valider_triangle",
           "engine_motif_b_alpha", "engine_table_tests", "engine_derogations",
           "engine_empreinte", "engine_parametre_standard", "engine_regle_verdicts")

# 3a. Garde structurelle : toute fonction du moteur citee par l'application ou
# par l'affichage est un point d'entree de la liste, et chacun commence par
# .engine_point_decimal(). Une fonction ajoutee plus tard a l'application, sans
# la pose, fait echouer ce test.
fn_moteur439 <- Filter(function(n) is.function(get(n, envir = env_moteur439)),
                       ls(env_moteur439, all.names = TRUE))
citees439 <- intersect(unique(unlist(lapply(
  file.path(RACINE, c("app.R", file.path("R", "display_helpers.R"))),
  function(f) all.names(parse(f, keep.source = FALSE))))), fn_moteur439)
verifier("point d'entree : les fonctions du moteur citees par app.R et display_helpers.R sont les 16 attendues",
         setequal(citees439, PE439))
for (nm in PE439) {
  corps <- body(get(nm, envir = env_moteur439))
  verifier(sprintf("point d'entree : %s() commence par .engine_point_decimal()", nm),
           is.call(corps) && identical(corps[[1]], as.name("{")) &&
             identical(corps[[2]], quote(.engine_point_decimal())))
}

# 3b. La fonction utilitaire : pose ".", restaure l'option de l'appelant (",") a la
# sortie normale et sur erreur, et conserve les on.exit propres de l'appelant
# (registre `reg` passe en argument : la sonde porte l'environnement du moteur).
sonde439 <- function(reg, erreur = FALSE) {
  .engine_point_decimal()
  on.exit(reg$propre <- TRUE, add = TRUE)
  reg$dedans <- getOption("OutDec")
  if (erreur) stop("x")
  invisible(NULL)
}
environment(sonde439) <- env_moteur439
reg_ok <- new.env(); reg_err <- new.env()
options(OutDec = ",")
sonde439(reg_ok); apres_ok <- getOption("OutDec")
try(sonde439(reg_err, erreur = TRUE), silent = TRUE); apres_err <- getOption("OutDec")
options(OutDec = ".")
verifier(".engine_point_decimal() : \".\" pose dans l'appelant, \",\" restituee a la sortie normale et sur erreur",
         identical(reg_ok$dedans, ".") && identical(reg_err$dedans, ".") &&
           identical(apres_ok, ",") && identical(apres_err, ","))
verifier(".engine_point_decimal() : l'on.exit propre de l'appelant est conserve, a la sortie normale et sur erreur",
         isTRUE(reg_ok$propre) && isTRUE(reg_err$propre))
reg_pt <- new.env(); sonde439(reg_pt)
verifier(".engine_point_decimal() : sous \".\", l'option reste \".\" dedans et a la sortie",
         identical(reg_pt$dedans, ".") && identical(getOption("OutDec"), "."))

# 3c. Restauration de l'option de l'appelant par chacun des 16 points d'entree :
# (i) sortie normale, appel valide sous OutDec = "," ; (ii) sortie sur erreur,
# appel sans argument (l'erreur d'argument manquant est levee dans le corps, donc
# apres la pose : .engine_point_decimal() est la premiere instruction, 3a).
d439 <- tempfile("k439_"); dir.create(d439)
ft439 <- file.path(d439, "k439_entree.xlsx")
peut_ecrire439 <- requireNamespace("zip", quietly = TRUE) ||
  nzchar(Sys.which(Sys.getenv("R_ZIPCMD", "zip")))
df_xl439 <- data.frame(t = 2001:2004, v = c(0.5, 1/3, 1e-300, 123456789.123456789),
                       lib = c("a", "b", "c", "d"), stringsAsFactors = FALSE)
if (peut_ecrire439) sous_outdec(".", engine_ecrire_xlsx(df_xl439, ft439))
df_ln439 <- utils::read.csv(file.path(RACINE, "tests", "donnees", "donnees_ln.csv"))
df_tri439 <- utils::read.csv(file.path(RACINE, "tests", "donnees", "triangle_mw.csv"))
valides439 <- list(
  run_engine = function() run_engine(xt = x428, yt = y428, methode = "premium", segment = 1,
                                     annexe = "II", nature_donnees = "brutes", B = 99),
  engine_lire_xlsx = function() if (peut_ecrire439) engine_lire_xlsx(ft439) else NULL,
  engine_lire_donnees_csv = function() engine_lire_donnees_csv(df_ln439),
  engine_lire_triangle = function() engine_lire_triangle(df_tri439),
  engine_ecrire_xlsx = function() if (peut_ecrire439)
    engine_ecrire_xlsx(df_xl439, tempfile(tmpdir = d439, fileext = ".xlsx")) else NULL,
  engine_ecrire_csv = function() engine_ecrire_csv(df_xl439, tempfile(tmpdir = d439, fileext = ".csv")),
  engine_valider_donnees = function() engine_valider_donnees(x_bas, y428, theta_equiv = 0.37),
  engine_valider_serie_retenue = function() engine_valider_serie_retenue(x428, y428, T = 5.5),
  engine_valider_profondeur = function() engine_valider_profondeur(5.5, 8),
  mw_valider_triangle = function() mw_valider_triangle(tri_bas),
  engine_motif_b_alpha = function() engine_motif_b_alpha(99, 0.037),
  engine_table_tests = function() engine_table_tests(ln_pt),
  engine_derogations = function() engine_derogations(ln_sg),
  engine_empreinte = function() engine_empreinte(ln_pt),
  engine_parametre_standard = function() engine_parametre_standard(ln_pt),
  engine_regle_verdicts = function() engine_regle_verdicts(0.037))
verifier("point d'entree : un appel valide prepare pour chacun des 16",
         identical(sort(names(valides439)), sort(PE439)))
# La restitution seule serait vraie d'une fonction qui ne touche pas a l'option :
# .engine_point_decimal() est donc remplace, dans l'environnement du moteur
# (ADR 0016), par une sonde qui l'appelle puis consigne la valeur d'OutDec vue
# par le point d'entree ; restitue en sortie.
pose439 <- function(expr) {
  reg <- new.env(); reg$vu <- character(0)
  vrai <- get(".engine_point_decimal", envir = env_moteur439)
  assign(".engine_point_decimal", function(envir = parent.frame()) {
    vrai(envir); reg$vu <- c(reg$vu, getOption("OutDec")); invisible(NULL)
  }, envir = env_moteur439)
  on.exit(assign(".engine_point_decimal", vrai, envir = env_moteur439), add = TRUE)
  force(expr)
  reg$vu
}
for (nm in PE439) {
  if (!peut_ecrire439 && nm %in% c("engine_lire_xlsx", "engine_ecrire_xlsx")) {
    cat(sprintf("  [saute] %s : ni paquet zip ni commande zip\n", nm)); next
  }
  for (od in c(",", ".")) {
    options(OutDec = od)
    vu_ok <- pose439(suppressWarnings(valides439[[nm]]()))
    apres <- getOption("OutDec")
    erreur <- FALSE
    vu_err <- pose439(erreur <- inherits(try(suppressWarnings(
      do.call(nm, list(), envir = env_moteur439)), silent = TRUE), "try-error"))
    apres_err <- getOption("OutDec")
    options(OutDec = ".")
    verifier(sprintf("point d'entree : %s() voit OutDec = \".\" et restitue \"%s\", sortie normale et sur erreur (%s)",
                     nm, od, if (erreur) "erreur levee" else "AUCUNE ERREUR LEVEE"),
             length(vu_ok) >= 1L && all(vu_ok == ".") && identical(apres, od) &&
               erreur && length(vu_err) >= 1L && all(vu_err == ".") && identical(apres_err, od))
  }
}
options(OutDec = ".")
verifier("point d'entree : .engine_point_decimal() du moteur est restitue apres les sondes",
         identical(get(".engine_point_decimal", envir = env_moteur439), pe_moteur439))

# 3d. Resultats identiques sous "," et sous "." : textes, tableaux, detail. Les
# objets run_engine() (tests, detail, validation, metadata, plots_data) sont
# compares en entier plus haut (section 1) ; ici, les tableaux et les chaines.
verifier("point d'entree : engine_table_tests() de reserve2 identique sous \",\" et \".\" (tableau)",
         identical(sous_outdec(".", engine_table_tests(r2_pt)), sous_outdec(",", engine_table_tests(r2_vg))))
verifier("point d'entree : toutes les chaines (detail, motifs, avertissements) de run_engine() identiques sous \",\" et \".\" (premium et reserve2)",
         identical(chaines(r2_pt), chaines(r2_vg)) && length(chaines(r2_pt)) > 0L &&
           identical(chaines(ln_pt), chaines(ln_vg)) && length(chaines(ln_pt)) > 0L)
verifier("point d'entree : run_engine(reserve1) sous \",\" identique a celui sous \".\"",
         {
           a <- sous_outdec(".", sans_horloge(run_engine(xt = x428, yt = y428, methode = "reserve1",
                                                         segment = 1, annexe = "II",
                                                         nature_donnees = "nettes", B = 99)))
           b <- sous_outdec(",", sans_horloge(run_engine(xt = x428, yt = y428, methode = "reserve1",
                                                         segment = 1, annexe = "II",
                                                         nature_donnees = "nettes", B = 99)))
           isTRUE(a$ok) && identical(a, b)
         })
for (nm in c("engine_empreinte", "engine_parametre_standard", "engine_regle_verdicts",
             "engine_lire_donnees_csv", "engine_lire_triangle", "engine_ecrire_csv")) {
  if (nm == "engine_ecrire_csv") {
    # Octets du fichier ecrit, sous chaque option
    ecrit <- function(od) { f <- tempfile(fileext = ".csv"); on.exit(unlink(f))
      sous_outdec(od, engine_ecrire_csv(df_xl439, f)); readBin(f, "raw", file.info(f)$size) }
    # Relu par read.csv() (separateur virgule) : trois colonnes, nombres au bit
    relu_vg <- { f <- tempfile(fileext = ".csv"); on.exit(unlink(f))
      sous_outdec(",", engine_ecrire_csv(df_xl439, f)); utils::read.csv(f) }
    verifier("point d'entree : engine_ecrire_csv() ecrit les memes octets sous \",\" et \".\" ; relu sous \",\", 3 colonnes et nombres au bit",
             identical(ecrit(","), ecrit(".")) && ncol(relu_vg) == 3L &&
               identical(relu_vg$v, df_xl439$v) && grepl(",0.5,", rawToChar(ecrit(",")), fixed = TRUE))
    next
  }
  a <- sous_outdec(".", valides439[[nm]]()); b <- sous_outdec(",", valides439[[nm]]())
  verifier(sprintf("point d'entree : %s() identique sous \",\" et \".\"", nm),
           identical(a, b) && !is.null(a))
}
verifier("point d'entree : engine_lire_donnees_csv() et engine_lire_triangle() lisent les memes nombres sous \",\"",
         isTRUE(sous_outdec(",", engine_lire_donnees_csv(df_ln439))$ok) &&
           isTRUE(sous_outdec(",", engine_lire_triangle(df_tri439))$ok) &&
           identical(sous_outdec(",", engine_lire_donnees_csv(df_ln439))$xt, x428))
if (peut_ecrire439) {
  # Ecrivain xlsx : XML de la feuille identique sous les deux options ; lecteur :
  # data.frame identique, avec le lecteur de repli et, s'il est installe, openxlsx.
  xml_ecrit <- function(od) {
    f <- tempfile(fileext = ".xlsx"); d <- tempfile("k439_")
    on.exit({ unlink(f); unlink(d, recursive = TRUE) })
    sous_outdec(od, engine_ecrire_xlsx(df_xl439, f)); utils::unzip(f, exdir = d)
    paste(readLines(file.path(d, "xl", "worksheets", "sheet1.xml"), warn = FALSE), collapse = "")
  }
  verifier("point d'entree : engine_ecrire_xlsx() ecrit la meme feuille sous \",\" et \".\"",
           identical(xml_ecrit(","), xml_ecrit(".")) && grepl("<v>0.5</v>", xml_ecrit(","), fixed = TRUE))
  sans_ox439 <- function(expr) {
    assign("requireNamespace", function(package, ...) FALSE, envir = env_moteur439)
    on.exit(rm("requireNamespace", envir = env_moteur439), add = TRUE)
    force(expr)
  }
  lu439 <- function(od, repli) sous_outdec(od, if (repli) sans_ox439(engine_lire_xlsx(ft439)) else
    engine_lire_xlsx(ft439))
  verifier("point d'entree : engine_lire_xlsx() (lecteur de repli) identique sous \",\" et \".\", valeurs relues a l'identique",
           identical(lu439(",", TRUE), lu439(".", TRUE)) &&
             identical(as.numeric(lu439(",", TRUE)$v), df_xl439$v))
  if (base::requireNamespace("openxlsx", quietly = TRUE))
    verifier("point d'entree : engine_lire_xlsx() (openxlsx) identique sous \",\" et \".\"",
             identical(lu439(",", FALSE), lu439(".", FALSE)))
  else cat("  [saute] engine_lire_xlsx() par openxlsx : paquet absent\n")
}
unlink(d439, recursive = TRUE)

fin_fichier()
