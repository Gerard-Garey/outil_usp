###############################################################################
#  tests/unitaires/test_application_partie_2.R  --  APPLICATION SHINY,
#  seconde partie (processus Shiny)
#
#  Seconde moitie de la partie Shiny de test_application.R (voir son en-tete
#  pour les proprietes verifiees), coupee en deux fichiers (issue #561, etape 4
#  de S8) pour raccourcir le chemin critique d'un lot de la CI : ce fichier
#  lance un second processus R, qui rejoue quatorze des vingt blocs testServer
#  (#155, #212, #199, #240, #498, #236, #412, #483, #499, #497, #518, #556,
#  #569, #567) ; les six autres (#212 garde, #236 base, #226, #380, #488, #504)
#  et les assertions hors processus sont dans test_application.R. Chaque bloc
#  garde son texte et son ordre relatif ; les aides communes de la grille
#  (fichier, grille, apercu, garde, base) et l'en-tete du processus sont
#  recopiees de test_application.R, a tenir identiques. Les definitions de
#  l'issue #155 (grille_html, a_id, a_val, fichier_tri, tri10, meme_tri), de
#  #199 (saisie199), de #483 (depot, xlsx_dispo) et de #497 (tri_champs) ne
#  servent qu'aux blocs de ce fichier : elles y restent ensemble. Sans shiny, le
#  fichier n'exerce rien (note en fin de fichier).
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_application_partie_2.R")

.racine <- if (exists("RACINE", inherits = TRUE)) RACINE else
           if (file.exists("R/engine.R")) "." else if (file.exists("../R/engine.R")) ".." else "../.."

## --- Grille des series et journal (issues #134, #136) -------------------------
if (requireNamespace("shiny", quietly = TRUE)) {
  # Scenarios de l'issue #155 (dimension du triangle, reinitialisation),
  # ajoutes au script du processus fils ; chaine brute, sans echappement.
  .bloc_155 <- r"---(
## Dimension du triangle et reinitialisation (issue #155, Q-R7-2 (A))
grille_html <- function(output) as.character(output$grille_donnees$html)
a_id <- function(h, id) grepl(sprintf('id="%s"', id), h, fixed = TRUE)
a_val <- function(h, id, v) grepl(sprintf('id="%s" type="number" class="shiny-input-number form-control" value="%s"',
                                         id, v), h, fixed = TRUE)
# Fichier de triangle n x n au format de l'import (colonnes i, j0, j1...).
fichier_tri <- function(tri) {
  f <- tempfile(fileext = ".csv"); n <- nrow(tri)
  utils::write.csv(data.frame(i = seq_len(n) - 1L,
                              setNames(as.data.frame(tri), paste0("j", seq_len(n) - 1L))),
                   f, row.names = FALSE, na = "")
  data.frame(name = basename(f), size = file.size(f), type = "text/csv", datapath = f,
             stringsAsFactors = FALSE)
}
tri10 <- round(ea$triangle_defaut(10) * 1.1, 2)
meme_tri <- function(x, y) identical(dim(x), dim(y)) && isTRUE(all.equal(x, y, tolerance = 0))
testServer(app, {
  do.call(session$setInputs, c(base, list(reinit = 1)))
  g1 <- grille_html(output)
  session$setInputs(x_1 = 999)
  session$setInputs(reinit = 2)
  g2 <- grille_html(output)
  a("series deja par defaut, seconde reinitialisation : grille redessinee, valeur par defaut (#155 c)",
    identical(donnees(), ea$DONNEES_DEFAUT) && identical(version_grille(), 2L) &&
      !identical(g1, g2) && grepl('data-version="2"', g2, fixed = TRUE) && a_val(g2, "x_1", "104.2"))
  t0 <- triangle()
  session$setInputs(fichier_import = fichier(6)); session$setInputs(profondeur = 6)
  a("import d'une serie de 6 annees, puis T = 6 : triangle 8 x 8 garde (#155 a)",
    nrow(donnees()) == 6L && nrow(t0) == 8L && identical(triangle(), t0))
  g3 <- grille_html(output)
  session$setInputs(fichier_import = fichier(6))
  a("second import du meme fichier de series : grille redessinee (#155 c)",
    !identical(g3, grille_html(output)))
  session$setInputs(methode = "reserve2")
  a("passage en reserve no 2 apres l'import : triangle 8 x 8 garde (#155 a)",
    identical(triangle(), t0) && a_id(grille_html(output), "c_7_0") &&
      !a_id(grille_html(output), "c_8_0"))
  session$setInputs(profondeur = 5)
  a("reserve no 2, T = 5 : triangle 8 x 8 inchange, aucune troncature (#155 b)",
    identical(triangle(), t0))
  session$setInputs(profondeur = 12)
  a("reserve no 2, T = 12 : triangle 8 x 8 inchange, aucun prolongement (#155 b)",
    identical(triangle(), t0))
  session$setInputs(reinit = 3)
  a("Reinitialiser avec T = 12 : triangle par defaut 12 x 12, seul changement de dimension (#155)",
    identical(triangle(), ea$triangle_defaut(12)) && a_id(grille_html(output), "c_11_0"))
  g4 <- grille_html(output)
  session$setInputs(c_0_0 = 1)
  session$setInputs(reinit = 4)
  a("triangle deja par defaut, seconde reinitialisation : grille redessinee, valeur par defaut (#155 c)",
    identical(triangle(), ea$triangle_defaut(12)) && !identical(g4, grille_html(output)) &&
      a_val(grille_html(output), "c_0_0", "300"))
  session$setInputs(fichier_import = fichier_tri(tri10))
  a("import d'un triangle 10 x 10 avec T = 12 : dimension 10 gardee (#155)",
    meme_tri(triangle(), tri10) && a_id(grille_html(output), "c_9_0") &&
      !a_id(grille_html(output), "c_10_0"))
  session$setInputs(profondeur = 8)
  a("triangle importe 10 x 10, puis T = 8 : dimension gardee (#155 b)", meme_tri(triangle(), tri10))
})
# Demarrage sur un fichier de triangle 10 x 10, sans fichier de series
# (T_INIT = 8, jeu par defaut) : app.R est relu dans un dossier temporaire
# qui porte usp_donnees_MW.csv ; le depot n'est pas touche.
tmp <- tempfile("app155_"); dir.create(file.path(tmp, "R"), recursive = TRUE)
invisible(file.copy(c("app.R", "DESCRIPTION"), tmp))
invisible(file.copy(file.path("R", c("engine.R", "charger_moteur.R", "display_helpers.R")), file.path(tmp, "R")))
invisible(file.copy(fichier_tri(tri10)$datapath, file.path(tmp, "usp_donnees_MW.csv")))
ici <- setwd(tmp); eb <- new.env(); app_b <- source("app.R", local = eb)$value; setwd(ici)
testServer(app_b, {
  do.call(session$setInputs, modifyList(base, list(methode = "reserve2", profondeur = eb$T_INIT)))
  a("demarrage : triangle 10 x 10 lu, T = 8 (series par defaut) : dimension gardee (#155 a)",
    identical(eb$T_INIT, 8L) && isTRUE(eb$CHARGE_MW$statut$ok) && meme_tri(triangle(), tri10) &&
      a_id(grille_html(output), "c_9_0"))
})
)---"
  # Portee de PROFONDEUR_MAX (issue #212, regle "T = donnees chargees" du
  # mainteneur du 14/10/2026). updateNumericInput() et showNotification()
  # sont remplaces, dans l'environnement d'app.R, par un releve : la session
  # simulee de shiny ne renvoie pas au serveur la valeur poussee dans le
  # champ T. Mesure avant correction (14/10/2026, testServer) : triangle
  # 41 x 41 importe en 1,65 s, 100 x 100 en 12,0 s (rendu de la grille,
  # HTML de 1,86 Mo) ; series reinitialisees avec T saisi = 12 ou 40 : champ
  # T inchange, avec T = 200 : champ T a 40, pour 8 annees chargees.
  .bloc_212 <- r"---(
## Portee de PROFONDEUR_MAX : regle "T = donnees chargees" (issue #212)
maj212 <- list(); notifs212 <- character(0)
assign("updateNumericInput", function(session, inputId, value = NULL, ...) {
  maj212[[length(maj212) + 1L]] <<- list(id = inputId, value = value); invisible(NULL)
}, envir = ea)
assign("showNotification", function(ui, ...) {
  notifs212 <<- c(notifs212, paste(as.character(ui), collapse = "")); invisible("id")
}, envir = ea)
champ_T <- function() vapply(Filter(function(m) identical(m$id, "profondeur"), maj212),
                             function(m) as.numeric(m$value), numeric(1))
testServer(app, {
  do.call(session$setInputs, modifyList(base, list(methode = "reserve2", reinit = 1)))
  t0 <- triangle(); v0 <- version_grille()
  f41 <- fichier_tri(ea$triangle_defaut(41))
  maj212 <<- list(); notifs212 <<- character(0)
  duree <- system.time(session$setInputs(fichier_import = f41))[["elapsed"]]
  a("import d'un triangle 41 x 41 : refuse, triangle courant 8 x 8 et grille gardes (#212)",
    identical(triangle(), t0) && identical(version_grille(), v0) &&
      a_id(grille_html(output), "c_7_0") && !a_id(grille_html(output), "c_8_0"))
  a("import d'un triangle 41 x 41 : statut d'import au texte unique (fichier, donnees courantes conservees, motif), notification unique, champ T non touche (#212, #556)",
    identical(statut_import()$ok, FALSE) &&
      identical(statut_import()$msg,
                sprintf("Import du fichier %s (CSV) refuse ; donnees courantes conservees. Motif : %s",
                        f41$name, ea$refus_dimension_triangle(41L))) &&
      identical(notifs212, "Import refuse ; donnees courantes conservees : voir le statut d'import.") &&
      !length(champ_T()))
  a("import d'un triangle 41 x 41 : refus en moins de 1 s (1,65 s avant #212)", duree < 1)
  session$setInputs(fichier_import = fichier_tri(ea$triangle_defaut(40)))
  a("import d'un triangle 40 x 40 : accepte, dimension gardee (#212)",
    identical(dim(triangle()), c(40L, 40L)) &&
      isTRUE(all.equal(triangle(), ea$triangle_defaut(40))) && isTRUE(statut_import()$ok) &&
      a_id(grille_html(output), "c_39_0"))
  maj212 <<- list(); notifs212 <<- character(0)
  session$setInputs(profondeur = 200, reinit = 2)
  a("saisie T = 200, reserve no 2 : triangle par defaut 40 x 40, champ T a 40, message de plafonnement (#194)",
    identical(triangle(), ea$triangle_defaut(40)) && identical(champ_T(), 40) &&
      identical(notifs212, c("Profondeur T = 200 au-dela du maximum de 40 : T = 40 retenu.",
                             "Donnees reinitialisees : triangle par defaut 40 x 40.")))
})
for (T212 in c(12, 200)) testServer(app, {
  do.call(session$setInputs, modifyList(base, list(profondeur = T212)))
  maj212 <<- list(); notifs212 <<- character(0)
  session$setInputs(reinit = 1)
  a(sprintf("series, T saisi = %d : reinitialisation, 8 annees chargees, champ T ramene a 8 (#212)", T212),
    identical(donnees(), ea$DONNEES_DEFAUT) && identical(champ_T(), 8) &&
      identical(notifs212, "Donnees reinitialisees : series par defaut de 8 annees, T = 8."))
})
testServer(app, {
  do.call(session$setInputs, base)
  maj212 <<- list(); notifs212 <<- character(0)
  session$setInputs(reinit = 1)
  a("series, T saisi = 8 : reinitialisation sans mise a jour du champ T (#212)",
    identical(donnees(), ea$DONNEES_DEFAUT) && !length(champ_T()) &&
      identical(notifs212, "Donnees reinitialisees : series par defaut de 8 annees, T = 8."))
})
# Series de plus de 40 annees (issue #286, option (a)) : meme refus motive que
# le triangle. Mesure avant correction (issue #286, testServer) : 60 annees
# importees, champ T pousse a 60 au-dela de sa borne PROFONDEUR_MAX.
testServer(app, {
  do.call(session$setInputs, base)
  d0 <- donnees(); v0 <- version_grille()
  maj212 <<- list(); notifs212 <<- character(0)
  f60 <- fichier(60)
  session$setInputs(fichier_import = f60)
  a("import de series de 60 annees : refuse, series courantes et grille gardees, champ T non touche (#286)",
    identical(donnees(), d0) && identical(version_grille(), v0) &&
      identical(statut_import()$ok, FALSE) &&
      identical(statut_import()$msg,
                sprintf("Import du fichier %s (CSV) refuse ; donnees courantes conservees. Motif : %s",
                        f60$name, ea$refus_dimension_series(60L))) &&
      identical(notifs212, "Import refuse ; donnees courantes conservees : voir le statut d'import.") &&
      !length(champ_T()))
  maj212 <<- list()
  session$setInputs(fichier_import = fichier(40))
  a("import de series de 40 annees : accepte, champ T pousse a 40 (#286)",
    nrow(donnees()) == 40L && identical(champ_T(), 40))
  # Refus motive du lecteur xlsx (#522) : classeur dont la ligne 1 est vide
  # (lignes descendues d'une ligne dans le XML ; paquet zip ou commande zip
  # requis). Sans l'un ni l'autre : assertion sautee, signalee dans le
  # libelle (meme nombre d'assertions, comme le bloc de #488).
  nom522 <- "import d'un classeur a ligne 1 vide : statut \"Import du fichier ligne1.xlsx (XLSX) refuse ; donnees courantes conservees. Motif : <texte du moteur>\", notification unique, series gardees (#522, #556)"
  zip522 <- requireNamespace("zip", quietly = TRUE)
  if (zip522 || nzchar(Sys.which("zip"))) {
    f522 <- tempfile(fileext = ".xlsx")
    get("engine_ecrire_xlsx", envir = ea)(data.frame(xt = 100:107, yt = 60:67), f522)
    x522 <- tempfile("x522_"); utils::unzip(f522, exdir = x522)
    fs <- file.path(x522, "xl", "worksheets", "sheet1.xml")
    s <- paste(readLines(fs, warn = FALSE), collapse = "")
    m <- gregexpr('<(row|c) r="[A-Z]*[0-9]+"', s)
    regmatches(s, m) <- lapply(regmatches(s, m), function(tk) vapply(tk, function(t)
      sub('[0-9]+"$', paste0(as.integer(sub('.*[^0-9]([0-9]+)"$', "\\1", t)) + 1L, '"'), t), "", USE.NAMES = FALSE))
    writeLines(s, fs, useBytes = TRUE)
    unlink(f522); od <- setwd(x522)
    if (zip522) zip::zipr(f522, list.files(".", all.files = TRUE, no.. = TRUE), include_directories = FALSE)
    else utils::zip(f522, list.files(".", all.files = TRUE, no.. = TRUE), flags = "-r9Xq")
    setwd(od)
    d40 <- donnees(); notifs212 <<- character(0)
    suppressMessages(session$setInputs(fichier_import = list(name = "ligne1.xlsx", datapath = f522)))
    a(nom522,
      identical(statut_import()$ok, FALSE) && identical(donnees(), d40) &&
        identical(statut_import()$msg, paste("Import du fichier ligne1.xlsx (XLSX) refuse ; donnees courantes conservees. Motif :",
          "Ligne 1 du fichier sans aucune valeur : l'en-tete du tableau doit etre en ligne 1, sans ligne au-dessus ; supprimer la ou les lignes vides au-dessus de l'en-tete.")) &&
        identical(notifs212, "Import refuse ; donnees courantes conservees : voir le statut d'import."))
    unlink(c(f522, x522), recursive = TRUE)
  } else a(paste0(nom522, " ; saute (ni paquet ni commande zip)"), TRUE)
})
rm("updateNumericInput", "showNotification", envir = ea)
)---"
  # Objet rbind non fonction de l'environnement global (issue #199) : la
  # table des controles (output$tab_controles) est rendue dans deux sessions,
  # sans puis avec rbind <- 5 pose avant le calcul, sur la grille du jeu par
  # defaut renseignee (sans elle, R() reste vide et la table n'est pas rendue).
  # Mordant : avec do.call(rbind, ...), la seconde session leve "'what' must
  # be a function or character string" (mesure du 06/10/2026, shiny 1.8.0).
  .bloc_199 <- r"---(
## Objet rbind de l'environnement global (issue #199)
r199 <- new.env()
d199 <- ea$DONNEES_DEFAUT
saisie199 <- c(setNames(as.list(d199$xt), paste0("x_", seq_len(nrow(d199)))),
               setNames(as.list(d199$yt), paste0("y_", seq_len(nrow(d199)))))
testServer(app, {
  do.call(session$setInputs, c(base, list(reinit = 1)))
  do.call(session$setInputs, saisie199)
  session$setInputs(go = 1)
  r199$sans <- tryCatch(output$tab_controles, error = function(e) e)
})
assign("rbind", 5, envir = globalenv())
testServer(app, {
  do.call(session$setInputs, c(base, list(reinit = 1)))
  do.call(session$setInputs, saisie199)
  session$setInputs(go = 1)
  r199$avec <- tryCatch(output$tab_controles, error = function(e) e)
})
rm(list = "rbind", envir = globalenv())
a("objet non fonction rbind global : table des controles identical a celle rendue sans lui (#199)",
  is.character(r199$sans) && grepl("<table", r199$sans, fixed = TRUE) &&
    identical(r199$avec, r199$sans))
)---"
  # Ligne "P-values Monte-Carlo" du bloc Etat et du journal, graine du flux
  # dans le journal (issue #240, Q-A4-12 (B)) : textes de texte_p_mc_regime()
  # et de valeurs_generateur(), lus dans le resultat, presents en primes (jeu
  # par defaut) et absents en reserve no 2 (triangle par defaut) ; graine de
  # la loi nulle SW : l'inverse (reserve no 2 seulement, #351).
  .bloc_240 <- r"---(
## Ligne "P-values Monte-Carlo" du bloc Etat (issue #240)
testServer(app, {
  do.call(session$setInputs, c(base, list(reinit = 1)))
  do.call(session$setInputs, saisie199)
  session$setInputs(go = 1)
  et <- as.character(output$etat$html)
  lig <- texte_p_mc_regime(resultat())
  a("bloc Etat (primes) : ligne P-values Monte-Carlo, texte de texte_p_mc_regime() (#240)",
    is.character(lig) && grepl("<b>P-values Monte-Carlo</b>", et, fixed = TRUE) &&
      grepl(htmltools::htmlEscape(lig), et, fixed = TRUE))
  jo <- output$tab_meta
  a("journal (primes) : ligne P-values Monte-Carlo entre la granularite et alpha, graine du flux 20800000 (#240)",
    grepl(paste0("P-values Monte-Carlo : ", lig, " \n"), jo, fixed = TRUE) &&
      regexpr("Granularite p_mc", jo, fixed = TRUE) < regexpr("P-values Monte-Carlo", jo, fixed = TRUE) &&
      regexpr("P-values Monte-Carlo", jo, fixed = TRUE) < regexpr("Seuil alpha", jo, fixed = TRUE) &&
      grepl("Graine flux regime   : 20800000 ", jo, fixed = TRUE))
  a("journal (primes) : pas de ligne 'Graine loi nulle SW' (consignee en reserve no 2 seulement, #351)",
    !grepl("Graine loi nulle SW", jo, fixed = TRUE) &&
      is.null(resultat()$metadata$seed_loi_nulle_sw))
  session$setInputs(methode = "reserve2", reinit = 2)
  # Le navigateur rend la grille du triangle : ses cellules observees c_i_j
  # sont relues, sans quoi le moteur refuse un triangle vide.
  tr <- triangle(); k <- which(!is.na(tr), arr.ind = TRUE)
  do.call(session$setInputs, setNames(as.list(tr[k]), sprintf("c_%d_%d", k[, 1] - 1L, k[, 2] - 1L)))
  session$setInputs(go = 2)
  et <- as.character(output$etat$html)
  a("bloc Etat (reserve no 2) : aucune ligne P-values Monte-Carlo (#240)",
    isTRUE(resultat()$ok) && identical(resultat()$metadata$methode, "reserve2") &&
      grepl("sigma_USP", et, fixed = TRUE) && !grepl("P-values Monte-Carlo", et, fixed = TRUE))
  jo <- output$tab_meta
  a("journal (reserve no 2) : ni ligne P-values Monte-Carlo ni graine du flux (#240)",
    grepl("Seuil alpha", jo, fixed = TRUE) && !grepl("P-values Monte-Carlo", jo, fixed = TRUE) &&
      !grepl("Graine flux regime", jo, fixed = TRUE))
  a("journal (reserve no 2) : ligne 'Graine loi nulle SW' presente, graine du moteur (#351)",
    grepl(paste0("Graine loi nulle SW  : ",
                 format(resultat()$metadata$seed_loi_nulle_sw, scientific = FALSE), " "),
          jo, fixed = TRUE) && identical(resultat()$metadata$seed_loi_nulle_sw, 20260901))
})
)---"
  # Regle des verdicts, alpha du resultat et du panneau (issue #498) : la regle
  # (quatre phrases d'engine_regle_verdicts(), alpha du RESULTAT) ouvre le
  # tableau des tests, jamais celui des controles ; la colonne Sens figure en
  # Synthese et en Detail ; le bloc Etat donne l'alpha du resultat et signale,
  # sans recalcul, un alpha du panneau different (texte_alpha_divergent()).
  .bloc_498 <- r"---(
## Regle des verdicts, alpha du resultat et du panneau (issue #498)
testServer(app, {
  do.call(session$setInputs, c(base, list(reinit = 1)))
  do.call(session$setInputs, saisie199)
  avant <- tryCatch(as.character(output$tests_par_hypothese$html), error = function(e) e)
  a("avant tout calcul : onglet Tests sans regle, ni erreur autre que l'annulation du rendu (#498)",
    inherits(avant, "shiny.silent.error"))
  session$setInputs(go = 1)
  ph <- engine_regle_verdicts(resultat()$metadata$alpha)
  h <- as.character(output$tests_par_hypothese$html)
  et <- as.character(output$etat$html)
  a("calcul abouti au jeu par defaut, alpha 0,1 du resultat (#498)",
    isTRUE(resultat()$ok) && identical(resultat()$metadata$alpha, 0.1))
  pos <- vapply(ph, function(x) regexpr(.echap_html(x), h, fixed = TRUE)[1], numeric(1))
  a("onglet Tests : les quatre phrases d'engine_regle_verdicts(alpha du resultat), dans l'ordre, avant le premier groupe (#498)",
    all(pos > 0) && all(diff(pos) > 0) && pos[1] < regexpr("<h4", h, fixed = TRUE)[1])
  a("onglet Tests : la regle ouvre le tableau, aucun autre element avant elle (#498)",
    startsWith(h, "<div class='bloc regle-verdicts'>"))
  # Repere de profondeur (#499) : champ du moteur, non replie, sous la regle.
  rp499 <- resultat()$validation$repere_profondeur
  bloc499 <- paste0("<div class='avert repere-profondeur'>", .echap_html(rp499), "</div>")
  a("onglet Tests : repere de profondeur du moteur (T = 8) non replie, juste sous la regle, avant le premier groupe (#499)",
    length(rp499) == 1L && startsWith(rp499, "T = 8 :") &&
      lengths(regmatches(h, gregexpr(bloc499, h, fixed = TRUE))) == 1L &&
      regexpr(paste0("</ul></div>\n", bloc499), h, fixed = TRUE)[1] == regexpr("</ul></div>", h, fixed = TRUE)[1] &&
      regexpr(bloc499, h, fixed = TRUE)[1] < regexpr("<h4", h, fixed = TRUE)[1])
  ctr <- as.character(output$tab_controles)
  a("tableau des controles : aucune phrase de la regle (#498)",
    is.character(ctr) && grepl("<table", ctr, fixed = TRUE) && !grepl("regle-verdicts", ctr, fixed = TRUE) &&
      !any(vapply(ph, function(x) grepl(.echap_html(x), ctr, fixed = TRUE), logical(1))))
  lig_pit <- grep("Test de Pitman", regmatches(h, gregexpr("<tr>.*?</tr>", h, perl = TRUE))[[1]],
                  fixed = TRUE, value = TRUE)
  a("vue Synthese : colonne Sens, ligne Pitman en ALERTE (p = 0,1107) avec le sens rejeter (#498)",
    grepl("<th>Sens</th>", h, fixed = TRUE) && length(lig_pit) == 1L &&
      grepl("ALERTE", lig_pit, fixed = TRUE) && grepl("<td>0,1107</td>", lig_pit, fixed = TRUE) &&
      endsWith(lig_pit, "<td><span style='white-space:nowrap'>rejeter</span></td></tr>"))
  session$setInputs(vue_tests = "detail")
  hd <- as.character(output$tests_par_hypothese$html)
  a("vue Detail : la regle en tete et la colonne Sens (#498)",
    startsWith(hd, "<div class='bloc regle-verdicts'>") && grepl("<th>Sens</th>", hd, fixed = TRUE) &&
      all(vapply(ph, function(x) grepl(.echap_html(x), hd, fixed = TRUE), logical(1))))
  a("bloc Etat : alpha du resultat (0,1), aucun signal tant que le panneau est a 0,1 (#498)",
    grepl("<b>&alpha;</b> = 0,1</div>", et, fixed = TRUE) && !grepl("du panneau", et, fixed = TRUE))
  session$setInputs(alpha = 0.2)
  et2 <- as.character(output$etat$html)
  h2 <- as.character(output$tests_par_hypothese$html)
  a("alpha du panneau a 0,2 : signal dans l'Etat, alpha du resultat toujours 0,1, aucun recalcul (#498)",
    grepl("α du panneau différent de celui du dernier calcul : relancer les calculs", et2, fixed = TRUE) &&
      grepl("<b>&alpha;</b> = 0,1</div>", et2, fixed = TRUE) && !grepl("<b>&alpha;</b> = 0,2", et2, fixed = TRUE) &&
      identical(resultat()$metadata$alpha, 0.1))
  a("alpha du panneau a 0,2 : la regle de l'onglet Tests reste celle du resultat (alpha 0,1), inchangee (#498)",
    identical(h2, hd) && grepl(.echap_html(ph[1]), h2, fixed = TRUE) && !grepl("α = 0,2", h2, fixed = TRUE))
  session$setInputs(alpha = NA_real_)
  et3 <- as.character(output$etat$html)
  a("champ alpha vide (NA) : ni signal ni erreur, alpha du resultat affiche (#498)",
    grepl("<b>&alpha;</b> = 0,1</div>", et3, fixed = TRUE) && !grepl("du panneau", et3, fixed = TRUE))
  session$setInputs(alpha = 0.10)
  a("alpha du panneau revenu a 0,1 : le signal disparait (#498)",
    !grepl("du panneau", as.character(output$etat$html), fixed = TRUE))
})
)---"
  # Virgule decimale des nombres affiches (issue #236) : bloc Etat, bloc du
  # parametre retenu (intervalle bootstrap "[a ; b]"), journal, table de
  # calibration, note d'influence et notification du retrait d'une ligne
  # (valeurs separees par " ; "), sur le jeu par defaut (B = 99, alpha = 0,10).
  .bloc_236 <- r"---(
## Virgule decimale des nombres affiches (issue #236)
notifs236 <- character(0)
assign("showNotification", function(ui, ...) {
  notifs236 <<- c(notifs236, paste(as.character(ui), collapse = "")); invisible("id")
}, envir = ea)
testServer(app, {
  do.call(session$setInputs, c(base, list(reinit = 1)))
  do.call(session$setInputs, saisie199)
  session$setInputs(go = 1)
  r <- resultat(); p <- r$parametre_final; ic <- r$ic_bootstrap
  sig <- sub(".", ",", sprintf("%.4f", p$sigma_usp), fixed = TRUE)
  et <- as.character(output$etat$html)
  a("bloc Etat : sigma_USP en virgule decimale, 4 decimales (#236)",
    isTRUE(r$ok) && grepl("^0,[0-9]{4}$", sig) &&
      grepl(paste0("font-size:18px'>", sig, "</span>"), et, fixed = TRUE))
  # Point decimal recherche hors des attributs style (font-size:12.5px).
  bf <- as.character(output$bloc_final$html)
  a("bloc du parametre : sigma_USP, variation et intervalle bootstrap \"[a ; b]\" en virgule decimale, aucun point decimal hors style (#236)",
    grepl(paste0("sigma_USP = ", sig, "</span>"), bf, fixed = TRUE) &&
      grepl("par rapport au parametre standard de 0,1000", bf, fixed = TRUE) &&
      grepl("90 % : \\[[0-9]+,[0-9]{4} ; [0-9]+,[0-9]{4}\\]", bf) &&
      grepl(gsub("(\\d)\\.(\\d)", "\\1,\\2", sprintf("95 %% : [%.4f ; %.4f]", ic[1], ic[5])), bf, fixed = TRUE) &&
      !grepl("[0-9]\\.[0-9]", gsub("style=\"[^\"]*\"", "", bf)))
  # Libelles des intervalles bootstrap (issue #305, Q-D2-Fn-3 (A)) : ligne
  # de percentile "niveau nominal", ligne "basic" sur l'echelle
  # logarithmique dessous, note grise ; ancien libelle absent.
  i_pc <- regexpr("Intervalle bootstrap de percentile, niveau nominal 90 % : [", bf, fixed = TRUE)
  i_bl <- regexpr("Intervalle bootstrap « basic » sur l'échelle logarithmique, niveau nominal 90 % : [",
                  bf, fixed = TRUE)
  a("bloc du parametre : intervalle de percentile 'niveau nominal', intervalle basic sur l'echelle logarithmique dessous, note grise des niveaux nominaux (#305)",
    i_pc > 0 && i_bl > i_pc && grepl("Niveaux nominaux. À T = 8, sous les modèles", bf, fixed = TRUE) &&
      !grepl("Intervalle bootstrap 90 %", bf, fixed = TRUE))
  jo <- output$tab_meta
  a("journal : sigma standard, granularite et alpha en virgule decimale (#236)",
    grepl("sigma standard       : 0,1 ", jo, fixed = TRUE) &&
      grepl("Granularite p_mc     : 0,01 ", jo, fixed = TRUE) &&
      grepl("Seuil alpha          : 0,1 \n", jo, fixed = TRUE))
  tc <- output$tab_calibration
  a("table de calibration : valeurs a 5 decimales en virgule decimale (#236)",
    grepl("<td> [0-9]+,[0-9]{5} </td>", tc) && !grepl("[0-9]\\.[0-9]", tc))
  ni <- as.character(output$note_influence$html)
  a("note d'influence (application) : reperes et ecart en virgule decimale, aucun point decimal (#236)",
    grepl("(4/T = 0,500)", ni, fixed = TRUE) && grepl("<b>[+-][0-9]+,[0-9] %</b>", ni) &&
      !grepl("[0-9]\\.[0-9]", ni))
  notifs236 <<- character(0)
  session$setInputs(retirer_annee = 1)
  a("retrait d'une ligne renseignee : valeurs en virgule decimale, separees par \" ; \" (#236)",
    identical(notifs236, "Ligne t = 8 retiree (x_t = 131,22 ; y_t = 117,37)."))
})
rm("showNotification", envir = ea)
)---"
  # Bandeau des avertissements de validation d'apres calcul, entierement replie
  # (issue #412, decision Q-46-4 (a) ; test reporte de R30, Q-45-4) : triangle
  # tri_deg (test_merz_wuthrich.R) importe puis cellules c_i_j relues, comme le
  # navigateur ; reserve no 2, segment II-1, B = 99. Un cas a un seul
  # avertissement (primes, 12 annees, segment II-1, mesure du 03/11/2026) pour
  # le singulier du resume.
  .bloc_412 <- r"---(
## Bandeau d'apres calcul replie (issue #412)
tri_deg <- matrix(NA_real_, 6, 6)
tri_deg[1, ] <- c(1000, 1600, 1800, 1800, 1830, 1835)
tri_deg[2, 1:5] <- c(1100, 1815, 2000, 2000, 2050)
tri_deg[3, 1:4] <- c(900, 1395, 1580, 1580)
tri_deg[4, 1:3] <- c(1200, 1980, 2210)
tri_deg[5, 1:2] <- c(1050, 1638)
tri_deg[6, 1]   <- 980
testServer(app, {
  do.call(session$setInputs, c(base, list(reinit = 1)))
  session$setInputs(methode = "reserve2", reinit = 2)
  a("bandeau d'avertissements : vide avant tout calcul (#412)",
    is.null(output$bandeau_avertissements))
  session$setInputs(fichier_import = fichier_tri(tri_deg))
  tr <- triangle(); k <- which(!is.na(tr), arr.ind = TRUE)
  do.call(session$setInputs, setNames(as.list(tr[k]), sprintf("c_%d_%d", k[, 1] - 1L, k[, 2] - 1L)))
  session$setInputs(go = 1)
  av <- resultat()$validation$avertissements
  h <- as.character(output$bandeau_avertissements$html)
  balises <- regmatches(h, gregexpr("<details[^>]*>", h))[[1]]
  a("tri_deg : calcul abouti, quatre avertissements du moteur (#412)",
    isTRUE(resultat()$ok) && length(av) == 4L)
  a("tri_deg : bandeau replie, une seule balise <details> sans attribut open, classe com (#412)",
    length(balises) == 1L && !grepl("open", balises, fixed = TRUE) &&
      identical(balises, "<details class=\"com\">") && grepl("<summary>", h, fixed = TRUE))
  a("tri_deg : resume '4 avertissements de validation du calcul' (#412)",
    grepl("<summary>4 avertissements de validation du calcul</summary>", h, fixed = TRUE))
  a("tri_deg : les quatre textes du moteur, tels quels et dans l'ordre, dans le corps replie (#412)",
    all(vapply(av, function(x) grepl(paste0("<li>", htmltools::htmlEscape(x), "</li>"), h, fixed = TRUE),
               logical(1))) &&
      all(diff(vapply(av, function(x) regexpr(htmltools::htmlEscape(x), h, fixed = TRUE)[1], numeric(1))) > 0) &&
      regexpr("</summary>", h, fixed = TRUE) < regexpr(htmltools::htmlEscape(av[1]), h, fixed = TRUE))
})
testServer(app, {
  do.call(session$setInputs, c(base, list(reinit = 1)))
  session$setInputs(fichier_import = fichier(12)); grille(session, 12)
  session$setInputs(profondeur = 12, go = 1)
  av <- resultat()$validation$avertissements
  h <- as.character(output$bandeau_avertissements$html)
  a("primes, 12 annees : un seul avertissement, resume au singulier, replie (#412)",
    isTRUE(resultat()$ok) && length(av) == 1L &&
      grepl("<summary>1 avertissement de validation du calcul</summary>", h, fixed = TRUE) &&
      !grepl("avertissements de validation", h, fixed = TRUE) &&
      !grepl("<details[^>]* open", h) &&
      grepl(paste0("<li>", htmltools::htmlEscape(av), "</li>"), h, fixed = TRUE))
})
# Rendu tagList de output$note_surface (#405) : la note de la surface puis, dans
# un bloc distinct de style neutre, l'aide du profil en delta (champ aide de
# note_surface()) quand le profil est trace ; texte lu dans note_surface()
# (R/display_helpers.R), aucune regle ici.
testServer(app, {
  do.call(session$setInputs, c(base, list(reinit = 1)))
  session$setInputs(fichier_import = fichier(12)); grille(session, 12)
  session$setInputs(profondeur = 12, go = 1)
  pd <- resultat()$plots_data
  ns <- note_surface(pd)
  h <- as.character(output$note_surface$html)
  a("note_surface : profil trace, champ aide non vide (#405)",
    isTRUE(resultat()$ok) && !is.null(pd$profil_delta) && !all(is.na(pd$profil_delta$objectif)) &&
      !is.null(ns$aide) && nzchar(ns$aide))
  a("output$note_surface : contient la note de la surface puis l'aide du profil en delta, bloc neutre (#405)",
    grepl(ns$html, h, fixed = TRUE) && grepl(ns$aide, h, fixed = TRUE) &&
      grepl("Profil de vraisemblance en delta : la ligne pointill[^ ]* horizontale \\(rep", h) &&
      grepl("<div style=\"margin-top:6px;color:#7F8C8D;font-size:12.5px\">", h, fixed = TRUE) &&
      regexpr(ns$html, h, fixed = TRUE) < regexpr(ns$aide, h, fixed = TRUE))
})
)---"
  # Import d'un CSV lu en texte (issue #483, #490) : meme motif dans
  # l'application pour le CSV et le xlsx ; donnees courantes gardees.
  .bloc_483 <- r"---(
## Import CSV lu en texte, interpretation par le moteur (issue #483, #490)
depot <- function(lignes = NULL, d = NULL) {
  f <- tempfile(fileext = if (is.null(d)) ".csv" else ".xlsx")
  if (is.null(d)) writeLines(lignes, f) else engine_ecrire_xlsx(d, f)
  data.frame(name = basename(f), size = file.size(f), type = "", datapath = f,
             stringsAsFactors = FALSE)
}
xlsx_dispo <- requireNamespace("zip", quietly = TRUE) || nzchar(Sys.which("zip"))
ser_vide <- c("xt,yt", paste(100:102, 60:62, sep = ","), "", paste(103:107, 63:67, sep = ","))
testServer(app, {
  do.call(session$setInputs, c(base, list(reinit = 1)))
  d0 <- donnees()
  session$setInputs(fichier_import = depot(ser_vide))
  m_csv <- statut_import()
  a("import CSV de series a ligne vide intercalee : refuse, motif du moteur, series courantes gardees (#483)",
    identical(m_csv$ok, FALSE) && identical(donnees(), d0) &&
      grepl("Ligne(s) vide(s) intercalee(s) (ligne(s) de donnees 4)", m_csv$msg, fixed = TRUE))
  if (xlsx_dispo) {
    session$setInputs(fichier_import = depot(d = data.frame(xt = c(100:102, NA, 103:107),
                                                            yt = c(60:62, NA, 63:67))))
    # Le statut porte le nom du fichier (#556) : meme motif, nom et extension propres.
    motif483 <- function(st) sub("^.* Motif : ", "", st$msg)
    a("import xlsx du meme tableau : meme motif que le CSV (#483, #556)",
      identical(statut_import()$ok, m_csv$ok) && nzchar(motif483(m_csv)) &&
        identical(motif483(statut_import()), motif483(m_csv)) && identical(donnees(), d0))
  } else a("import xlsx du meme tableau : saute (aucun ecrivain xlsx)", TRUE)
  session$setInputs(fichier_import = depot(c("xt,yt", "100,60", "0x10,61", paste(102:104, 62:64, sep = ","))))
  a("import CSV avec \"0x10\" : refuse comme valeur non numerique (xt : ligne de donnees 2), series courantes gardees (#490)",
    identical(statut_import()$ok, FALSE) && identical(donnees(), d0) &&
      grepl("Certaines valeurs des colonnes xt ou yt ne sont pas numeriques (colonne xt : ligne(s) de donnees 2).", statut_import()$msg,
            fixed = TRUE))
  session$setInputs(fichier_import = depot(c("t,xt,yt,", paste0(1:6, ",", 100:105, ",", 60:65, ","))))
  a("import CSV de series valide (colonne de fin sans en-tete) : 6 annees importees, valeurs lues par le moteur (#483)",
    isTRUE(statut_import()$ok) && identical(donnees(), data.frame(t = 1:6, xt = as.numeric(100:105),
                                                                  yt = as.numeric(60:65))))
})
)---"
  # Avertissements de lecture du moteur restitues a l'import d'un triangle
  # (issue #518, R1 d'app-review) : cellules renseignees sous la diagonale
  # (#491), que la grille (i + j <= I) ne montre pas ; CSV dont une ligne
  # compte plus de champs que l'en-tete refuse (C4).
  .bloc_518 <- r"---(
## Avertissements de lecture restitues a l'import, lecture sans nom de ligne (issue #518)
notifs518 <- list()
assign("showNotification", function(ui, ..., type = "default") {
  notifs518[[length(notifs518) + 1L]] <<- list(texte = paste(as.character(ui), collapse = ""), type = type)
  invisible("id")
}, envir = ea)
types518 <- function() vapply(notifs518, `[[`, "", "type")
tri_sous <- ea$triangle_defaut(8); tri_sous[row(tri_sous) + col(tri_sous) - 2L > 7L] <- 1000
testServer(app, {
  do.call(session$setInputs, c(base, list(reinit = 1)))
  session$setInputs(methode = "reserve2", reinit = 2)
  notifs518 <<- list()
  session$setInputs(fichier_import = fichier_tri(tri_sous))
  lu <- engine_lire_triangle(tri_sous)
  h <- as.character(output$import_statut$html)
  a("import d'un triangle 8 x 8 a cellules sous la diagonale : importe, statut au seul avertissement de #491 (avertissements_lecture du moteur), tel quel (#518)",
    isTRUE(statut_import()$ok) && length(statut_import()$avertissements) == 1L &&
      identical(statut_import()$avertissements, lu$avertissements_lecture) &&
      grepl("sous la diagonale", statut_import()$avertissements, fixed = TRUE) &&
      length(lu$avertissements) > 1L && identical(dim(triangle()), c(8L, 8L)))
  a("import du triangle sous la diagonale : avertissement visible a l'ecran sous le titre Avertissements, sans le vert du succes, sans credibilite ni pourcentage ; notification warning unique (#518)",
    grepl("Avertissements :", h, fixed = TRUE) &&
      grepl(paste0("<li>", htmltools::htmlEscape(lu$avertissements_lecture), "</li>"), h, fixed = TRUE) &&
      !grepl("1E8449", h, fixed = TRUE) && !grepl("%|credibilite|bruites", h) &&
      identical(types518(), "warning") &&
      identical(notifs518[[1]]$texte, "Triangle importe, avec des avertissements : voir le statut d'import."))
  notifs518 <<- list()
  session$setInputs(fichier_import = fichier_tri(ea$triangle_defaut(8)))
  h2 <- as.character(output$import_statut$html)
  a("import d'un triangle 8 x 8 sans cellule sous la diagonale : statut sans avertissement, en vert, sans pourcentage de credibilite, aucune notification warning (N2) (#518)",
    isTRUE(statut_import()$ok) && identical(statut_import()$avertissements, character(0)) &&
      length(engine_lire_triangle(ea$triangle_defaut(8))$avertissements) == 2L &&
      !grepl("Avertissements", h2, fixed = TRUE) && grepl("1E8449", h2, fixed = TRUE) &&
      !grepl("%|credibilite", h2) && !("warning" %in% types518()))
  a("statut_ui() : succes sans avertissement en vert, sans titre Avertissements ; avec avertissement, titre et liste, sans vert (#518)",
    {
      v0 <- as.character(ea$statut_ui(list(ok = TRUE, msg = "ok")))
      v1 <- as.character(ea$statut_ui(list(ok = TRUE, msg = "ok", avertissements = "a < b")))
      grepl("1E8449", v0, fixed = TRUE) && !grepl("Avertissements", v0, fixed = TRUE) &&
        !grepl("1E8449", v1, fixed = TRUE) && grepl("<li>a &lt; b</li>", v1, fixed = TRUE)
    })
  t1 <- triangle()
  session$setInputs(fichier_import = depot(c("j0,j1,j2", "1,300,960,1560", "1,310,980,", "1,320,,")))
  a("import d'un triangle dont les lignes ont plus de champs que l'en-tete : refuse, message fixe du CSV (plus de 'duplicate row.names'), triangle courant garde (#518)",
    identical(statut_import()$ok, FALSE) && identical(triangle(), t1) &&
      grepl(ea$MESSAGE_ILLISIBLE[["csv"]], statut_import()$msg, fixed = TRUE) &&
      !grepl("duplicate", statut_import()$msg, fixed = TRUE))
})
testServer(app, {
  do.call(session$setInputs, c(base, list(reinit = 1)))
  d0 <- donnees()
  session$setInputs(fichier_import = depot(c("xt,yt", paste(2015:2022, 100:107, 60:67, sep = ","))))
  a("import de series 'xt,yt' dont les lignes portent une colonne d'annees de plus : refuse, message fixe du CSV, series courantes gardees, aucune colonne ignoree en silence (#518)",
    identical(statut_import()$ok, FALSE) && identical(donnees(), d0) &&
      grepl(ea$MESSAGE_ILLISIBLE[["csv"]], statut_import()$msg, fixed = TRUE))
  session$setInputs(fichier_import = depot(c("xt,yt,annee", paste(100:107, 60:67, 2015:2022, sep = ","))))
  a("import de series avec une colonne en surnombre NOMMEE : importee, colonne ignoree par nom (convention du moteur), 8 annees (#518)",
    isTRUE(statut_import()$ok) && identical(donnees(), data.frame(t = 1:8, xt = as.numeric(100:107),
                                                                  yt = as.numeric(60:67))))
})
rm("showNotification", envir = ea)
)---"
  # Information de lecture des series restituee a l'import (issue #569,
  # decision Q-66-6 (a)) : engine_lire_donnees_csv()$avertissements_lecture
  # sous le statut d'import, tel quel, en CSV comme en classeur, que les
  # donnees chargees passent ou non les controles de validite ; aucun pour
  # un fichier range ni pour un refus. depot() : bloc de #483.
  .bloc_569 <- r"---(
## Information de lecture des series restituee a l'import (issue #569)
x569 <- round(100 * 1.03^(1:8), 2); y569 <- round(70 * 1.03^(1:8) + 5 * (-1)^(1:8), 2)
lig569 <- function(p, x = x569, y = y569) c("t,xt,yt", paste(p, x[p], y[p], sep = ","))
lu569 <- function(dp) engine_lire_donnees_csv(ea$lire_tableau(dp$datapath, grepl("xlsx$", dp$datapath))$df)
testServer(app, {
  do.call(session$setInputs, c(base, list(reinit = 1)))
  dp <- depot(lig569(c(2, 1, 3:8))); session$setInputs(fichier_import = dp)
  lu <- lu569(dp); h <- as.character(output$import_statut$html)
  a("import CSV de series aux lignes 1 et 2 permutees : importe, rangees par t, statut au seul motif d'avertissements_lecture du moteur, tel quel (#569)",
    isTRUE(statut_import()$ok) && length(statut_import()$avertissements) == 1L &&
      identical(statut_import()$avertissements, lu$avertissements_lecture) &&
      grepl("(ligne(s) de donnees 1, 2 deplacee(s))", statut_import()$avertissements, fixed = TRUE) &&
      identical(donnees(), data.frame(t = 1:8, xt = lu$xt, yt = lu$yt)) && identical(lu$xt, x569))
  a("import CSV permute : motif visible a l'ecran sous le titre Avertissements, sans le vert du succes (#569)",
    grepl("Avertissements :", h, fixed = TRUE) &&
      grepl(paste0("<li>", htmltools::htmlEscape(lu$avertissements_lecture), "</li>"), h, fixed = TRUE) &&
      !grepl("1E8449", h, fixed = TRUE))
  session$setInputs(fichier_import = depot(lig569(1:8)))
  h0 <- as.character(output$import_statut$html)
  a("import CSV de series deja rangees : statut sans avertissement (character(0)), en vert (#569)",
    isTRUE(statut_import()$ok) && identical(statut_import()$avertissements, character(0)) &&
      !grepl("Avertissements", h0, fixed = TRUE) && grepl("1E8449", h0, fixed = TRUE))
  if (xlsx_dispo) {
    dx <- depot(d = data.frame(t = c(2, 1, 3:8), xt = x569[c(2, 1, 3:8)], yt = y569[c(2, 1, 3:8)]))
    session$setInputs(fichier_import = dx)
    a("import xlsx de series aux lignes 1 et 2 permutees : meme motif qu'en CSV, tel quel, series rangees (#569)",
      isTRUE(statut_import()$ok) && identical(statut_import()$avertissements, lu$avertissements_lecture) &&
        identical(statut_import()$avertissements, lu569(dx)$avertissements_lecture) &&
        identical(donnees(), data.frame(t = 1:8, xt = lu$xt, yt = lu$yt)))
  } else a("import xlsx de series permutees : saute (aucun ecrivain xlsx)", TRUE)
  yneg <- y569; yneg[3] <- -5
  dn <- depot(lig569(c(2, 1, 3:8), y = yneg)); session$setInputs(fichier_import = dn)
  a("import CSV permute hors des controles de validite (yt negatif) : charge, statut en erreur avec le motif de lecture du moteur, tel quel (#569)",
    identical(statut_import()$ok, FALSE) &&
      grepl("ne passent pas les controles de validite du moteur", statut_import()$msg, fixed = TRUE) &&
      length(statut_import()$avertissements) == 1L &&
      identical(statut_import()$avertissements, lu569(dn)$avertissements_lecture))
  session$setInputs(fichier_import = depot(lig569(1:8))); d0 <- donnees()
  l <- lig569(c(2, 1, 3:8)); l[4] <- sub("^([^,]*),[^,]*", "\\1,abc", l[4])
  session$setInputs(fichier_import = depot(l))
  a("import CSV permute refuse (xt non numerique) : statut de refus sans avertissement, series courantes gardees (#569)",
    identical(statut_import()$ok, FALSE) && !length(statut_import()$avertissements) &&
      grepl("ne sont pas numeriques", statut_import()$msg, fixed = TRUE) && identical(donnees(), d0))
})
)---"
  # Restitution unique des refus d'import et echec d'export (issue #556) :
  # showNotification() est remplace, dans l'environnement d'app.R, par un
  # releve (texte, type, duree) ; engine_ecrire_xlsx() et engine_ecrire_csv()
  # sont remplaces par une erreur, retiree en sortie. Refus de dimension et du
  # lecteur : voir les blocs de #212 et #522.
  .bloc_556 <- r"---(
## Restitution unique des refus d'import ; echec d'un export (issue #556)
notifs556 <- list()
assign("showNotification", function(ui, ..., type = "default", duration = 5) {
  notifs556[[length(notifs556) + 1L]] <<- list(texte = paste(as.character(ui), collapse = ""),
                                               type = type, duration = duration)
  invisible("id")
}, envir = ea)
dep556 <- function(lignes, ext = ".csv") {
  f <- tempfile(fileext = ext); writeLines(lignes, f)
  data.frame(name = basename(f), size = file.size(f), type = "", datapath = f, stringsAsFactors = FALSE)
}
NOTIF556 <- "Import refuse ; donnees courantes conservees : voir le statut d'import."
ent556 <- function(d, ext) sprintf("Import du fichier %s (%s) refuse ; donnees courantes conservees. Motif : ", d$name, ext)
une_notif556 <- function() length(notifs556) == 1L && identical(notifs556[[1]]$texte, NOTIF556) &&
  identical(notifs556[[1]]$type, "error") && identical(notifs556[[1]]$duration, 8)
testServer(app, {
  do.call(session$setInputs, c(base, list(reinit = 1)))
  d0 <- donnees(); t0 <- triangle()
  notifs556 <<- list()
  dr <- dep556(c("xt,yt", "100,60,1", "101,61"))
  suppressMessages(session$setInputs(fichier_import = dr))
  a("import illisible (CSV a ligne plus longue que l'en-tete) : statut \"Import du fichier ... refuse ; donnees courantes conservees. Motif : <MESSAGE_ILLISIBLE>\", notification unique error de 8 s, series gardees (#556)",
    identical(statut_import()$ok, FALSE) &&
      identical(statut_import()$msg, paste0(ent556(dr, "CSV"), ea$MESSAGE_ILLISIBLE[["csv"]])) &&
      une_notif556() && identical(donnees(), d0) && identical(triangle(), t0))
  notifs556 <<- list()
  dx <- dep556("pas un classeur", ".xlsx")
  suppressMessages(session$setInputs(fichier_import = dx))
  a("import illisible (xlsx faux) : meme forme, motif MESSAGE_ILLISIBLE$xlsx, notification unique, series gardees (#556)",
    identical(statut_import()$msg, paste0(ent556(dx, "XLSX"), ea$MESSAGE_ILLISIBLE[["xlsx"]])) &&
      une_notif556() && identical(donnees(), d0) && identical(triangle(), t0))
  notifs556 <<- list()
  dv <- dep556(c("xt,zz", "100,60"))
  session$setInputs(fichier_import = dv)
  a("import refuse par la recevabilite du moteur (colonne yt manquante) : nom du fichier, donnees conservees, motif du moteur apres \"Motif : \", notification unique, series gardees (#556)",
    identical(statut_import()$msg, paste0(ent556(dv, "CSV"), engine_lire_donnees_csv(
      data.frame(xt = "100", zz = "60"))$erreurs)) &&
      grepl("Motif : Colonne(s) manquante(s) : yt.", statut_import()$msg, fixed = TRUE) &&
      une_notif556() && identical(donnees(), d0) && identical(triangle(), t0))
  notifs556 <<- list()
  session$setInputs(methode = "reserve2", reinit = 2)
  t0 <- triangle(); notifs556 <<- list()
  dt <- dep556(c("i,j0,j1,j2", "0,1,2,3", "1,4,5,", "2,6,,", "3,7,,"))
  session$setInputs(fichier_import = dt)
  lu556 <- engine_lire_triangle(utils::read.csv(dt$datapath, colClasses = "character", check.names = FALSE,
                                                na.strings = character(0), row.names = NULL))
  a("import de triangle refuse par la recevabilite du moteur (triangle 4 x 3 : D(2)(b) et D(2)(c) ; aussi MW-04 avant #567) : meme forme, notification unique, triangle gardee (#556)",
    !lu556$ok && identical(statut_import()$msg, paste0(ent556(dt, "CSV"), paste(lu556$erreurs, collapse = " "))) &&
      une_notif556() && identical(triangle(), t0) && identical(donnees(), d0))
})
# Echec d'un export : journal, notification (texte, type, duree), erreur relevee.
journal556 <- character(0)
tente556 <- function(expr) withCallingHandlers(tryCatch(expr, error = function(e) e),
  message = function(m) { journal556 <<- c(journal556, conditionMessage(m)); invokeRestart("muffleMessage") })
testServer(app, {
  do.call(session$setInputs, c(base, list(reinit = 1)))
  notifs556 <<- list(); journal556 <<- character(0)
  assign("engine_ecrire_xlsx", function(...) stop(structure(class = c("usp_refus_ecriture", "error", "condition"),
    list(message = "Ecriture du fichier .xlsx impossible : cause de test.", call = NULL))), envir = ea)
  e <- tente556(output$dl_donnees_xlsx)
  rm("engine_ecrire_xlsx", envir = ea)
  a("export xlsx en echec par usp_refus_ecriture : notification error de 10 s \"Export impossible : <texte du moteur>\", cause au journal, erreur relevee au texte utilisateur (#556)",
    length(notifs556) == 1L &&
      identical(notifs556[[1]]$texte, "Export impossible : Ecriture du fichier .xlsx impossible : cause de test.") &&
      identical(notifs556[[1]]$type, "error") && identical(notifs556[[1]]$duration, 10) &&
      any(grepl("cause de test", journal556, fixed = TRUE)) &&
      inherits(e, "error") && identical(conditionMessage(e), notifs556[[1]]$texte))
  notifs556 <<- list(); journal556 <<- character(0)
  assign("engine_ecrire_csv", function(...) stop("impossible d'ouvrir le fichier 'cause R brute' : Permission denied"), envir = ea)
  e <- tente556(output$dl_donnees)
  rm("engine_ecrire_csv", envir = ea)
  a("export CSV en echec par une erreur R ordinaire : texte fixe sans la cause R, cause au journal, erreur relevee (#556)",
    length(notifs556) == 1L &&
      identical(notifs556[[1]]$texte, "Export impossible : erreur lors de l'ecriture du fichier (detail consigne au journal de l'application).") &&
      identical(notifs556[[1]]$type, "error") && identical(notifs556[[1]]$duration, 10) &&
      !grepl("cause R brute", notifs556[[1]]$texte, fixed = TRUE) &&
      any(grepl("cause R brute", journal556, fixed = TRUE)) &&
      inherits(e, "error"))
  a("export CSV en echec : message de l'erreur relevee = texte destine a l'utilisateur, sans la cause R brute ni le chemin (corps de la page d'erreur HTTP 500 de shiny) (#556)",
    identical(conditionMessage(e), "Export impossible : erreur lors de l'ecriture du fichier (detail consigne au journal de l'application).") &&
      !grepl("cause R brute|Permission", conditionMessage(e)))
  notifs556 <<- list(); journal556 <<- character(0)
  f <- tente556(output$dl_donnees)
  a("export CSV reussi : fichier ecrit, aucune notification, aucune ligne de journal (#556)",
    is.character(f) && file.exists(f) && !length(notifs556) && !length(journal556))
  # Export sans resultat (req(resultat()) : erreur silencieuse de shiny) : pas
  # un echec d'ecriture, aucune notification ; l'erreur reste relevee.
  e <- tente556(output$dl_tests)
  a("export des tests sans resultat : erreur silencieuse de shiny relevee, ni notification ni journal (#556)",
    inherits(e, "shiny.silent.error") && !length(notifs556) && !length(journal556))
})
rm("showNotification", envir = ea)
)---"
  # Repere de profondeur (issue #499) : texte et seuil poses par le moteur
  # seul (T < 10, I + 1 < 10), restitues apres calcul une fois dans la liste
  # repliee de bandeau_avertissements et une fois, non replie, en tete de
  # l'onglet Tests (champ validation$repere_profondeur, decision du
  # mainteneur du 10/11/2026) ; l'ancien bandeau_T (seuil T >= 15 propre a
  # l'affichage, phrase "Profondeur suffisante...") est retire.
  .bloc_499 <- r"---(
## Repere de profondeur du moteur : bandeau replie et onglet Tests (issue #499)
non_rejet <- "Une p-value elevee ne demontre pas la validite de l'hypothese : elle ne permet pas de la rejeter."
repere <- function(av) av[grepl("lois asymptotiques peu fiables|estimateurs de variance tres bruites", av)]
sans_bandeau_T <- function(output) inherits(tryCatch(output$bandeau_T, error = function(e) e), "error")
verif_499 <- function(lib, attendu, output, r) {
  av <- r$validation$avertissements; rp <- repere(av)
  h <- if (length(av)) as.character(output$bandeau_avertissements$html) else ""
  occ <- lengths(regmatches(h, gregexpr("lois asymptotiques peu fiables|estimateurs de variance tres bruites", h)))
  a(sprintf("%s : repere du moteur %s, une seule fois au plus dans le bandeau replie, texte du moteur tel quel, sans bandeau_T (#499)",
            lib, if (attendu) "present (phrase de non-rejet)" else "absent"),
    isTRUE(r$ok) && length(rp) == as.integer(attendu) && occ == as.integer(attendu) &&
      (!attendu || (endsWith(rp, non_rejet) &&
                      grepl(paste0("<li>", htmltools::htmlEscape(rp), "</li>"), h, fixed = TRUE))) &&
      sans_bandeau_T(output) && !grepl("Profondeur suffisante", h, fixed = TRUE))
  # Onglet Tests : le champ du moteur, egal au repere des avertissements,
  # une fois et non replie (aucun <details>), ou rien s'il est vide.
  ht <- as.character(output$tests_par_hypothese$html)
  occ_t <- lengths(regmatches(ht, gregexpr("repere-profondeur", ht, fixed = TRUE)))
  a(sprintf("%s : onglet Tests, champ repere_profondeur %s (#499)",
            lib, if (attendu) "affiche une fois, non replie, egal au repere des avertissements" else "vide, aucun bandeau"),
    identical(r$validation$repere_profondeur, rp) && occ_t == as.integer(attendu) &&
      (!attendu || grepl(paste0("<div class='avert repere-profondeur'>", htmltools::htmlEscape(rp), "</div>"),
                         ht, fixed = TRUE)) &&
      !grepl("<details[^>]*>[^<]*<summary[^>]*>[^<]*</summary>[^<]*<div class='avert repere-profondeur'>", ht))
}
testServer(app, {
  do.call(session$setInputs, c(base, list(reinit = 1)))
  for (n in c(8L, 12L, 15L)) {
    session$setInputs(fichier_import = fichier(n)); grille(session, n)
    session$setInputs(profondeur = n, go = n)
    verif_499(sprintf("primes, T = %d", n), n < 10L, output, resultat())
  }
})
tri6 <- matrix(NA_real_, 6, 6)
tri6[1, ] <- c(1000, 1600, 1800, 1800, 1830, 1835)
tri6[2, 1:5] <- c(1100, 1815, 2000, 2000, 2050)
tri6[3, 1:4] <- c(900, 1395, 1580, 1580)
tri6[4, 1:3] <- c(1200, 1980, 2210)
tri6[5, 1:2] <- c(1050, 1638)
tri6[6, 1]   <- 980
for (cas in list(list(tri = tri6, attendu = TRUE), list(tri = tri10, attendu = FALSE))) {
  testServer(app, {
    do.call(session$setInputs, c(base, list(reinit = 1)))
    session$setInputs(methode = "reserve2", reinit = 2)
    session$setInputs(fichier_import = fichier_tri(cas$tri))
    tr <- triangle(); k <- which(!is.na(tr), arr.ind = TRUE)
    do.call(session$setInputs, setNames(as.list(tr[k]), sprintf("c_%d_%d", k[, 1] - 1L, k[, 2] - 1L)))
    session$setInputs(go = 1)
    verif_499(sprintf("reserve no 2, I + 1 = %d", nrow(cas$tri)), cas$attendu, output, resultat())
  })
}
)---"
  # Conservation de la saisie de la grille au changement de methode (issue
  # #497). Mesure avant correction (testServer, 10/11/2026) : x_1 = 999 puis
  # "reserve2" puis "premium" : x_1 = 104,2 ; c_0_0 = 12345 puis "reserve1"
  # puis "reserve2" : c_0_0 = 300. Le navigateur rend la grille apres un
  # import ou une reinitialisation et renvoie ses champs : grille() et
  # tri_champs() le reproduisent.
  .bloc_497 <- r"---(
## Saisie de la grille conservee au changement de methode (issue #497)
d497 <- ea$DONNEES_DEFAUT; t497 <- ea$triangle_defaut(8)
tri_champs <- function(tr) { k <- which(!is.na(tr), arr.ind = TRUE)
  setNames(as.list(tr[k]), sprintf("c_%d_%d", k[, 1] - 1L, k[, 2] - 1L)) }
testServer(app, {
  do.call(session$setInputs, c(base, list(reinit = 1)))
  session$setInputs(x_1 = 999, y_2 = 555)
  session$setInputs(methode = "reserve2")
  session$setInputs(methode = "premium")
  a("series : x_1 = 999 et y_2 = 555 conserves apres premium, reserve2, premium (#497)",
    identical(donnees()$xt[1], 999) && identical(donnees()$yt[2], 555) &&
      identical(donnees()$xt[-1], d497$xt[-1]) && identical(donnees()$yt[-2], d497$yt[-2]) &&
      a_val(grille_html(output), "x_1", "999") && a_val(grille_html(output), "y_2", "555"))
  session$setInputs(methode = "reserve1")
  a("series : x_1 = 999 conserve de premium a reserve1, sans changement de famille (#497)",
    identical(donnees()$xt[1], 999) && a_val(grille_html(output), "x_1", "999"))
})
testServer(app, {
  do.call(session$setInputs, c(base, list(reinit = 1)))
  session$setInputs(methode = "reserve2", reinit = 2)
  do.call(session$setInputs, tri_champs(t497))
  session$setInputs(c_0_0 = 12345)
  session$setInputs(methode = "reserve1")
  session$setInputs(methode = "reserve2")
  tr <- triangle(); att <- t497; att[1, 1] <- 12345
  a("triangle : c_0_0 = 12345 conserve apres reserve2, reserve1, reserve2, autres cellules intactes (#497)",
    identical(tr, att) && a_val(grille_html(output), "c_0_0", "12345"))
})
# Champ non rendu (entree absente) : le triangle, jamais affiche dans cette
# session, n'est pas vide au retour des series.
testServer(app, {
  do.call(session$setInputs, c(base, list(reinit = 1)))
  t0 <- triangle()
  session$setInputs(methode = "reserve2")
  session$setInputs(methode = "premium")
  a("triangle sans champ rendu : valeurs stockees gardees au retour aux series (#497)",
    identical(triangle(), t0) && identical(donnees(), d497))
})
# Import et reinitialisation remplacent toujours la saisie : la recopie ne
# s'execute qu'au changement de methode et relit les champs rendus apres eux.
testServer(app, {
  do.call(session$setInputs, c(base, list(reinit = 1)))
  session$setInputs(x_1 = 999)
  session$setInputs(fichier_import = fichier(6)); grille(session, 6)
  imp <- read.csv(fichier(6)$datapath)
  session$setInputs(methode = "reserve2")
  session$setInputs(methode = "premium")
  a("series : import apres la saisie, la serie importee remplace x_1 = 999 et survit a l'aller-retour (#497)",
    nrow(donnees()) == 6L && identical(donnees()$xt, imp$xt) && identical(donnees()$yt, imp$yt) &&
      !a_val(grille_html(output), "x_1", "999"))
  session$setInputs(x_1 = 888)
  session$setInputs(reinit = 2)
  do.call(session$setInputs, c(setNames(as.list(d497$xt), paste0("x_", 1:8)),
                               setNames(as.list(d497$yt), paste0("y_", 1:8))))
  session$setInputs(methode = "reserve1")
  session$setInputs(methode = "premium")
  a("series : Reinitialiser apres la saisie, le jeu par defaut remplace x_1 = 888 et survit a l'aller-retour (#497)",
    identical(donnees(), d497) && a_val(grille_html(output), "x_1", "104.2"))
})
testServer(app, {
  do.call(session$setInputs, c(base, list(reinit = 1)))
  session$setInputs(methode = "reserve2", reinit = 2)
  do.call(session$setInputs, tri_champs(t497))
  session$setInputs(c_0_0 = 12345)
  session$setInputs(fichier_import = fichier_tri(tri10))
  do.call(session$setInputs, tri_champs(tri10))
  session$setInputs(methode = "premium")
  session$setInputs(methode = "reserve2")
  a("triangle : import apres la saisie, le triangle importe remplace c_0_0 = 12345 et survit a l'aller-retour (#497)",
    meme_tri(triangle(), tri10) && !a_val(grille_html(output), "c_0_0", "12345"))
  session$setInputs(c_0_0 = 777)
  session$setInputs(reinit = 3)   # T saisi = 8 : triangle par defaut 8 x 8
  do.call(session$setInputs, tri_champs(t497))
  session$setInputs(methode = "premium")
  session$setInputs(methode = "reserve2")
  a("triangle : Reinitialiser apres la saisie, le triangle par defaut remplace c_0_0 = 777 et survit a l'aller-retour (#497)",
    meme_tri(triangle(), t497) && a_val(grille_html(output), "c_0_0", "300"))
})
)---"
  # Trapeze I > J dans l'application (issue #567, etape 6 de S6, C4 ;
  # consigne d'architect, par. 1.5) : import du 8 x 6 du cas reserve2_trapeze
  # (tests/donnees/triangle_mw_trapeze.csv) ; grille aux seules cellules
  # observees ; lecture et recopie au changement de methode a la dimension
  # 8 x 6 ; calcul au clic ; refus de dimension d'un 41 x 8 ; place de
  # l'apercu et legende du graphique des facteurs (constats d'app-review sur
  # rendu reel). Le navigateur
  # renvoie les champs de la grille rendue : tri_champs() (bloc de #497) le
  # reproduit. showNotification() est remplace, dans l'environnement d'app.R,
  # par un releve, retire en sortie.
  .bloc_567 <- r"---(
## Trapeze I > J : import, grille, lecture, recopie, calcul, refus 41 x 8 (issue #567)
notifs567 <- character(0)
assign("showNotification", function(ui, ...) {
  notifs567 <<- c(notifs567, paste(as.character(ui), collapse = "")); invisible("id")
}, envir = ea)
depot567 <- function(f, nom = basename(f))
  data.frame(name = nom, size = file.size(f), type = "text/csv", datapath = f, stringsAsFactors = FALSE)
f567 <- local({
  f <- tempfile(fileext = ".csv")
  invisible(file.copy(file.path("tests", "donnees", "triangle_mw_trapeze.csv"), f))
  depot567(f, "triangle_mw_trapeze.csv")
})
# Trapeze 41 x 8 : colonnes 0 a 7 du triangle par defaut 41 x 41 (partie
# observee i + j <= 40), recevable par le moteur, au-dela de la limite de
# 40 annees de l'application.
f41_567 <- local({
  f <- tempfile(fileext = ".csv")
  d <- data.frame(i = 0:40, ea$triangle_defaut(41)[, 1:8]); names(d) <- c("i", paste0("j", 0:7))
  utils::write.csv(d, f, row.names = FALSE, na = "")
  depot567(f)
})
T1_567 <- "Triangle a 8 annees d'accident et 6 annees de developpement : "
# Apercu des controles au-dessus de la grille (#567, constat d'app-review
# sur rendu reel : sous la grille, l'avertissement (t1) etait hors de vue
# apres l'import, en 1280 x 900 comme en 1366 x 768) : ordre des sorties dans
# l'interface, une seule sortie validation_live, hors du bloc "Controles de
# validite" (titre et table des controles apres la grille).
ui567 <- paste(as.character(ea$ui), collapse = "")
pos567 <- function(motif) gregexpr(motif, ui567, fixed = TRUE)[[1]]
a("interface : apercu validation_live unique, sous les statuts de demarrage et d'import et au-dessus de la grille ; titre \"Controles de validite\" et table des controles apres la grille (#567)",
  length(pos567('id="validation_live"')) == 1L &&
    all(vapply(c('id="statut_demarrage"', 'id="import_statut"', 'id="validation_live"',
                 'id="grille_donnees"', "<h4>Controles de validite</h4>", 'id="tab_controles"'),
               function(m) length(pos567(m)) == 1L && pos567(m) > 0L, NA)) &&
    !is.unsorted(vapply(c('id="statut_demarrage"', 'id="import_statut"', 'id="validation_live"',
                          'id="grille_donnees"', "<h4>Controles de validite</h4>",
                          'id="tab_controles"'), pos567, 0L), strictly = TRUE))
testServer(app, {
  do.call(session$setInputs, modifyList(base, list(methode = "reserve2")))
  imp <- engine_lire_triangle(utils::read.csv(f567$datapath, colClasses = "character", check.names = FALSE,
                                              na.strings = character(0), row.names = NULL))$triangle
  notifs567 <<- character(0)
  session$setInputs(fichier_import = f567)
  a("trapeze 8 x 6 importe : triangle() 8 x 6 identical() a la lecture du moteur, statut \"Triangle 8 x 6 importe\" sans avertissement de lecture ((t1) hors avertissements_lecture), notification d'import ordinaire (#567)",
    identical(dim(imp), c(8L, 6L)) && identical(triangle(), imp) && isTRUE(statut_import()$ok) &&
      identical(statut_import()$msg, "Triangle 8 x 6 importe depuis triangle_mw_trapeze.csv (CSV).") &&
      !length(statut_import()$avertissements) && identical(notifs567, "Donnees importees."))
  h <- grille_html(output)
  obs <- outer(0:7, 0:5, "+") <= 7L
  pres <- outer(0:7, 0:5, Vectorize(function(i, j) a_id(h, sprintf("c_%d_%d", i, j))))
  a("trapeze 8 x 6 : identifiants c_i_j de la grille pour les seules cellules observees (i + j <= 7, j <= 5 : 33 champs), ni colonne j = 6 ni ligne i = 8 (#567)",
    identical(pres, obs) && sum(pres) == 33L && identical(pres, unname(mw_cellules_observees(imp))) &&
      !a_id(h, "c_0_6") && !a_id(h, "c_8_0"))
  do.call(session$setInputs, tri_champs(imp))
  a("trapeze 8 x 6 : lire_triangle() identical() au triangle importe (#567)",
    identical(lire_triangle(), imp))
  ap <- apercu(output)
  a("trapeze 8 x 6 : apercu de validation sans refus, avertissement de geometrie (t1) une fois (#567)",
    is.character(ap) && !grepl("class=\"err\"", ap, fixed = TRUE) &&
      lengths(regmatches(ap, gregexpr(T1_567, ap, fixed = TRUE))) == 1L)
  session$setInputs(c_0_0 = 12345, c_2_5 = 54321)
  session$setInputs(methode = "reserve1")
  session$setInputs(methode = "reserve2")
  att <- imp; att[1, 1] <- 12345; att[3, 6] <- 54321
  h <- grille_html(output)
  a("trapeze 8 x 6 : c_0_0 et c_2_5 (colonne J) recopies au changement de methode reserve2 -> reserve1 -> reserve2, triangle 8 x 6 a jour, grille redessinee a la meme dimension (#567, #497)",
    identical(triangle(), att) && a_val(h, "c_0_0", "12345") && a_val(h, "c_2_5", "54321") &&
      a_id(h, "c_7_0") && !a_id(h, "c_7_1") && !a_id(h, "c_0_6"))
  session$setInputs(c_0_0 = imp[1, 1], c_2_5 = imp[3, 6])
  session$setInputs(go = 1)
  r <- resultat()
  a("trapeze 8 x 6 : clic, calcul abouti sur le triangle importe (T = I + 1 = 8, I = 7, J = 5 ; sigma_USP du cas reserve2_trapeze a 1e-12 ; (t1) une fois ; bloc Etat rendu) (#567)",
    isTRUE(r$ok) && identical(r$triangle, imp) && identical(r$metadata$T, 8L) &&
      identical(r$metadata$I, 7L) && identical(r$metadata$J, 5L) &&
      abs(r$parametre$sigma_usp / 0.0475797067089398 - 1) < 1e-12 &&
      sum(startsWith(r$validation$avertissements, T1_567)) == 1L &&
      grepl("sigma_USP", as.character(output$etat$html), fixed = TRUE))
  # Legende plotly du graphique des facteurs (#567, constat d'app-review sur
  # rendu reel : a y = -0,30, la premiere des trois entrees du trapeze
  # recouvrait le titre de l'axe j a 395 px) : y = -0,55 a trois entrees
  # (trapeze calcule ci-dessus), y = -0,30 inchange a deux entrees (carre
  # par defaut 8 x 8, plots_data construit par les fonctions du moteur).
  if (requireNamespace("plotly", quietly = TRUE)) {
    leg567 <- function(pd) {
      b <- suppressWarnings(plotly::plotly_build(plot_mw_facteurs(pd)))$x
      list(y = b$layout$legend$y,
           n = sum(vapply(b$data, function(t) !identical(t$showlegend, FALSE), NA)))
    }
    pd_carre567 <- local({
      aj <- mw_ajuster(ea$triangle_defaut(8))
      mw_plots_data(aj, mw_residus(aj), list(sigma_boot = numeric(0)), mw_msep(aj), alpha = 0.10)
    })
    lt <- leg567(r$plots_data); lc <- leg567(pd_carre567)
    a("graphique des facteurs, plotly : legende a y = -0,55 pour les trois entrees du trapeze calcule, y = -0,30 inchange pour les deux entrees du carre 8 x 8 (#567)",
      identical(lt$n, 3L) && identical(lt$y, -0.55) && identical(lc$n, 2L) && identical(lc$y, -0.30))
  } else a("graphique des facteurs, plotly : legende du trapeze et du carre : saute (plotly absent)", TRUE)
  t_av <- triangle()
  notifs567 <<- character(0)
  session$setInputs(fichier_import = f41_567)
  h <- grille_html(output)
  a("trapeze 41 x 8 importe : refuse par refus_dimension_triangle() (motif \"Triangle 41 x 8\"), statut au texte unique, notification unique, triangle 8 x 6 et grille gardes (#567, #212, #556)",
    identical(statut_import()$ok, FALSE) &&
      identical(statut_import()$msg,
                sprintf("Import du fichier %s (CSV) refuse ; donnees courantes conservees. Motif : %s",
                        f41_567$name, ea$refus_dimension_triangle(41L, 8L))) &&
      startsWith(ea$refus_dimension_triangle(41L, 8L), "Triangle 41 x 8 : ") &&
      identical(notifs567, "Import refuse ; donnees courantes conservees : voir le statut d'import.") &&
      identical(triangle(), t_av) && a_id(h, "c_7_0") && !a_id(h, "c_8_0") && !a_id(h, "c_0_6"))
})
rm("showNotification", envir = ea)
)---"
  .script <- tempfile(fileext = ".R")
  writeLines(c(
    'suppressMessages(library(shiny))',
    sprintf('DATE_REFERENCE_TESTS <- %s', deparse(DATE_REFERENCE_TESTS)),
    'ea <- new.env(); app <- source("app.R", local = ea)$value',
    'a <- function(nom, ok) cat(sprintf("ASSERT\\t%s\\t%s\\n", nom, isTRUE(ok)))',
    'xt <- c(98.10, 101.30, 104.20, 102.25, 109.34, 114.64, 118.41, 121.28, 132.40, 131.22)',
    'yt <- c(71.05,  66.40,  68.97,  76.76,  83.49,  95.38,  88.96,  70.22,  78.89, 117.37)',
    '# Fichier CSV de n annees, au format de l\'import (colonnes t, xt, yt).',
    'fichier <- function(n) {',
    '  f <- tempfile(fileext = ".csv")',
    '  utils::write.csv(data.frame(t = seq_len(n), xt = round(100 * 1.03^seq_len(n), 2),',
    '                              yt = round(70 * 1.03^seq_len(n) + 5 * (-1)^seq_len(n), 2)),',
    '                   f, row.names = FALSE)',
    '  data.frame(name = basename(f), size = file.size(f), type = "text/csv", datapath = f,',
    '             stringsAsFactors = FALSE)',
    '}',
    '# Le navigateur rend la grille de n lignes apres l\'import : ses champs',
    '# x_i, y_i sont relus, sans evenement du champ T.',
    'grille <- function(session, n) { d <- read.csv(fichier(n)$datapath)',
    '  do.call(session$setInputs, c(setNames(as.list(d$xt), paste0("x_", seq_len(n))),',
    '                               setNames(as.list(d$yt), paste0("y_", seq_len(n))))) }',
    '# Rendu de l\'apercu ; condition si le rendu est annule (req(cancelOutput)).',
    'apercu <- function(output) tryCatch(as.character(output$validation_live$html),',
    '                                    error = function(e) e)',
    'garde <- function(avant, apres) inherits(apres, "shiny.output.cancel") || identical(apres, avant)',
    'base <- list(annexe = "II", segment = "1", sigma_manuel = FALSE, B = 99, alpha = 0.10,',
    '             seed = 20260831, delta_apriori = FALSE, theta_equiv = 0.10,',
    '             methode = "premium", nature_donnees = "brutes", profondeur = 8,',
    '             date_reference = DATE_REFERENCE_TESTS)',
    .bloc_155, .bloc_212, .bloc_199, .bloc_240, .bloc_498, .bloc_236, .bloc_412, .bloc_483, .bloc_499, .bloc_497, .bloc_518, .bloc_556, .bloc_569, .bloc_567), .script)
  # Processus fils lance depuis la racine du depot : app.R y source
  # R/engine.R par chemin relatif. --vanilla ignore .Renviron et .Rprofile :
  # les bibliotheques de ce processus (.libPaths()) lui sont transmises par
  # R_LIBS, sans quoi un shiny installe dans une bibliotheque declaree par
  # .Renviron n'y est pas trouve (poste du mainteneur, R 4.3.3, PR #208).
  .ici <- setwd(.racine)
  .r_libs <- Sys.getenv("R_LIBS", unset = NA)
  Sys.setenv(R_LIBS = paste(.libPaths(), collapse = .Platform$path.sep))
  .sortie <- tryCatch(suppressWarnings(system2(file.path(R.home("bin"), "Rscript"),
                                               c("--vanilla", shQuote(.script)),
                                               stdout = TRUE, stderr = TRUE)),
                      finally = {
                        if (is.na(.r_libs)) Sys.unsetenv("R_LIBS") else Sys.setenv(R_LIBS = .r_libs)
                        setwd(.ici)
                      })
  .lignes <- grep("^ASSERT\t", .sortie, value = TRUE)
  verifier("processus Shiny (partie 2 sur 2) : 110 assertions rendues", length(.lignes) == 110L)
  if (length(.lignes) != 110L) cat(utils::tail(.sortie, 10), sep = "\n")
  for (.l in strsplit(.lignes, "\t", fixed = TRUE))
    verifier(paste("Application :", .l[2]), identical(.l[3], "TRUE"))
} else {
  cat("  note : shiny absent ; grille, journal, apercu, vue Detail, dimension du triangle et table des controles (#199) non exerces (attendu en CI, comme plotly, issue #53).\n")
}

fin_fichier()
