###############################################################################
#  tests/tableau_levee_mw04.R  --  TABLEAU AVANT / APRES DE LA LEVEE DU
#  MOTIF MW-04 ("Triangle non carre") SUR LES TRAPEZES I > J
#  (issue #567, branche S6, etape 6, commit moteur: C3)
#
#  OUTIL HORS CI : ce script n'est ni une batterie de tests ni un generateur
#  de references. Il n'est lance ni par la CI, ni par test_unitaires.R (nom
#  sans prefixe test_), ni par test_reproductibilite.R. R base + stats ;
#  tools::md5sum() pour les empreintes. Il ne modifie ni R/, ni app.R, ni
#  tests/reference/. Fichier source ASCII : les libelles non ASCII sont
#  ecrits en echappements \u ; sortie en UTF-8, y compris sous LC_ALL=C.
#
#  Objet (consigne d'architect, docs/revues/20261120-s6-trapeze/
#  architect-6-forme-etape6-fable.md, par. 1.5) : resultat de run_engine()
#  avant et apres la levee de MW-04 (decision D2 (a') du mainteneur, ADR
#  0005 annote le 21/11/2026), sur les trapezes 8 x 5, 8 x 6 et 8 x 7 formes
#  des colonnes 0..J de tests/donnees/triangle_mw.csv (cas reserve2), plus le
#  cas reserve2 lui-meme (carre 8 x 8), dont l'objet doit etre identical()
#  avant et apres. Le 8 x 6 est le cas reserve2_trapeze de
#  tests/outils_tests.R (decision Q-F1 (a)) : la valeur de sa reference,
#  produite par la CI (mode creation), fait foi pour ce triangle.
#
#  Moteurs : "avant" = R/engine.R du commit --avant (par defaut ac363b1,
#  tete de la branche S6 avant C3), extrait par "git show" vers un fichier
#  temporaire ; "apres" = R/engine.R de l'arbre de travail. Chacun est charge
#  par charger_moteur(fichier, dans) (ADR 0016) dans un environnement propre ;
#  aucun n'atteint l'environnement global.
#
#  Appels : run_engine(methode = "reserve2", triangle, segment = 1,
#  annexe = "II", date_reference = DATE_REFERENCE_TESTS), autres arguments
#  par defaut (B = 999, graine 20260831, alpha = 0,10), ceux du cas reserve2
#  de tests/outils_tests.R. Objets compares apres nettoyer() (horodatage,
#  duree_sec, version_R retires), comme par test_reproductibilite.R.
#
#  Contenu : avant, ok et motifs (MW-04 seul attendu) ; apres, sigma_USP,
#  sigma estime, R, racine(MSEP), c, T, sigma2_(J-1) de la regle de minimum et
#  estimateur direct (I - J degres de liberte), intervalle bootstrap de
#  sigma, verdict et p-value retenue des lignes de engine_table_tests() (et,
#  pour lecture, celles du carre reserve2), avertissements de la validation.
#
#  Usage (racine du depot, LC_ALL=C.UTF-8 sous Linux) :
#      Rscript tests/tableau_levee_mw04.R [--avant SHA] [--sortie CHEMIN [--remplacer]]
#  Sortie markdown sur la console ; --sortie l'ecrit aussi dans CHEMIN, apres
#  garde_ecrasement() de tests/outils_tests.R (un fichier suivi par git est
#  refuse sans --remplacer).
#  Derniere ligne : CONTROLES OK ou CONTROLES ECHEC (avant : ok = FALSE et un
#  seul motif, prefixe "Triangle non carre (", sur chaque trapeze ; apres :
#  ok = TRUE et avertissement de geometrie present une fois sur chaque
#  trapeze ; reserve2 identical() avant / apres). Code de sortie 0 si
#  CONTROLES OK, 1 sinon.
###############################################################################

t_debut <- Sys.time()

# --- Locale : sortie UTF-8 sous LC_ALL=C (#113) -------------------------------
if (!isTRUE(l10n_info()[["UTF-8"]]))
  for (loc in c("C.UTF-8", "en_US.UTF-8", "fr_FR.UTF-8"))
    if (nzchar(suppressWarnings(Sys.setlocale("LC_CTYPE", loc)))) break

# --- Options ------------------------------------------------------------------
ARGS <- commandArgs(trailingOnly = TRUE)
lv_refuser <- function(...) { message("REFUS : ", ...); quit(status = 1L) }
local({
  i <- 1L
  while (i <= length(ARGS)) {
    a <- ARGS[i]
    if (a %in% c("--avant", "--sortie")) {
      if (sum(ARGS == a) > 1L) lv_refuser("option ", a, " donnee plusieurs fois")
      if (i == length(ARGS)) lv_refuser("option ", a, " sans valeur")
      i <- i + 2L
    } else if (a == "--remplacer") i <- i + 1L
    else lv_refuser("option inconnue : ", a)
  }
})
OPT_AVANT  <- if ("--avant" %in% ARGS) ARGS[match("--avant", ARGS) + 1L] else "ac363b1"
OPT_SORTIE <- if ("--sortie" %in% ARGS) ARGS[match("--sortie", ARGS) + 1L] else NA_character_
OPT_REMPL  <- "--remplacer" %in% ARGS
if (OPT_REMPL && is.na(OPT_SORTIE)) lv_refuser("--remplacer : reserve a --sortie")
if (!grepl("^[0-9a-f]{7,40}$", OPT_AVANT)) lv_refuser("--avant : SHA hexadecimal attendu")

# --- Outils communs et moteur apres --------------------------------------------
# outils_tests.R charge R/engine.R de l'arbre de travail (charger_moteur())
# et fournit DATE_REFERENCE_TESTS, nettoyer(), garde_ecrasement(),
# commit_depot() et RACINE.
OT <- new.env(parent = globalenv())
sys.source(if (file.exists("tests/outils_tests.R")) "tests/outils_tests.R" else "outils_tests.R",
           envir = OT)
RACINE <- OT$RACINE
if (!is.na(OPT_SORTIE)) {
  dir_s <- dirname(OPT_SORTIE)
  if (!dir.exists(dir_s)) lv_refuser("dossier de --sortie introuvable : ", dir_s)
  REMPLACES <- OT$garde_ecrasement(OPT_SORTIE, OPT_REMPL, RACINE)
}
source(file.path(RACINE, "R", "charger_moteur.R"), local = TRUE)
FICHIER_APRES <- file.path(RACINE, "R", "engine.R")
APRES <- new.env(parent = globalenv()); charger_moteur(FICHIER_APRES, dans = APRES)

# --- Moteur avant : git show <SHA>:R/engine.R ------------------------------------
FICHIER_AVANT <- tempfile("engine_avant_", fileext = ".R")
code_avant <- tryCatch(suppressWarnings(system2("git", c("-C", shQuote(RACINE), "show",
                                                         paste0(OPT_AVANT, ":R/engine.R")),
                                                stdout = TRUE, stderr = FALSE)),
                       error = function(e) character(0))
if (!length(code_avant) || !is.null(attr(code_avant, "status")))
  lv_refuser("git show ", OPT_AVANT, ":R/engine.R a echoue")
writeLines(code_avant, FICHIER_AVANT, useBytes = TRUE)
SHA_AVANT <- tryCatch(system2("git", c("-C", shQuote(RACINE), "rev-parse", OPT_AVANT), stdout = TRUE,
                              stderr = FALSE), error = function(e) OPT_AVANT)
AVANT <- new.env(parent = globalenv()); charger_moteur(FICHIER_AVANT, dans = AVANT)

# --- Donnees et appels -----------------------------------------------------------
TRI <- OT$.tri
JEUX <- list("8 x 5" = TRI[, 1:5], "8 x 6" = TRI[, 1:6], "8 x 7" = TRI[, 1:7])
lv_appel <- function(moteur, tri)
  OT$nettoyer(moteur$run_engine(methode = "reserve2", triangle = tri, segment = 1, annexe = "II",
                                date_reference = OT$DATE_REFERENCE_TESTS))
RES_AVANT <- lapply(JEUX, function(t) lv_appel(AVANT, t))
RES_APRES <- lapply(JEUX, function(t) lv_appel(APRES, t))
CARRE_AVANT <- lv_appel(AVANT, TRI)
CARRE_APRES <- lv_appel(APRES, TRI)

# --- Mise en forme ---------------------------------------------------------------
lv_num <- function(x, d = 10) if (is.null(x) || !length(x) || is.na(x)) "NA" else
  trimws(formatC(x, digits = d, format = "g", decimal.mark = ","))
lv_p <- function(x) if (is.na(x)) "—" else trimws(formatC(x, digits = 4, format = "g", decimal.mark = ","))
# Ligne de tableau markdown : arguments mis bout a bout (vecteurs compris).
ligne_md <- function(...) paste0("| ", paste(c(...), collapse = " | "), " |")
lv_court <- function(s, n = 90) if (nchar(s) > n) paste0(substr(s, 1, n), "…") else s
PREFIXE_MW04 <- "Triangle non carre ("
DEBUT_T1 <- "Triangle a "

# --- Controles ----------------------------------------------------------------
ctl <- list()
ctl$avant <- vapply(RES_AVANT, function(r) identical(r$ok, FALSE) && length(r$validation$erreurs) == 1L &&
                      startsWith(r$validation$erreurs, PREFIXE_MW04), logical(1))
ctl$apres <- vapply(RES_APRES, function(r) identical(r$ok, TRUE) &&
                      sum(startsWith(r$validation$avertissements, DEBUT_T1)) == 1L, logical(1))
ctl$carre <- identical(CARRE_AVANT, CARRE_APRES)
OK <- all(ctl$avant) && all(ctl$apres) && isTRUE(ctl$carre)

# --- Tableau ------------------------------------------------------------------
md5 <- function(f) unname(tools::md5sum(f))
blas <- tryCatch(extSoftVersion()[["BLAS"]], error = function(e) NA_character_)
out <- c(
  "# Tableau avant / après — levée du motif MW-04 sur les trapèzes I > J (issue #567, étape 6 de S6, commit `moteur:` C3)",
  "",
  ligne_md("Grandeur", "Valeur"), ligne_md("---", "---"),
  ligne_md("Date", format(Sys.time(), "%Y-%m-%d", tz = "UTC")),
  ligne_md("Commande", sprintf("`LC_ALL=C.UTF-8 Rscript tests/tableau_levee_mw04.R%s%s` (racine du dépôt)",
                               if ("--avant" %in% ARGS) paste0(" --avant ", OPT_AVANT) else "",
                               if (!is.na(OPT_SORTIE)) paste0(" --sortie ", OPT_SORTIE,
                                                              if (OPT_REMPL) " --remplacer" else "") else "")),
  ligne_md("Script", sprintf("`tests/tableau_levee_mw04.R`, md5 `%s`",
                             md5(file.path(RACINE, "tests", "tableau_levee_mw04.R")))),
  ligne_md("Moteur avant", sprintf("`R/engine.R` de `%s` (`git show`), md5 `%s`", SHA_AVANT, md5(FICHIER_AVANT))),
  ligne_md("Moteur après", sprintf("`R/engine.R` de l'arbre de travail, md5 `%s`", md5(FICHIER_APRES))),
  ligne_md("Commit de l'arbre", sprintf("`%s`", OT$commit_depot())),
  ligne_md("R, plateforme", sprintf("%s ; %s ; BLAS : %s", R.version.string, utils::sessionInfo()$running,
                                    if (is.na(blas) || !nzchar(blas)) "non déterminé" else blas)),
  ligne_md("Appels", sprintf(paste("`run_engine(methode = \"reserve2\", triangle, segment = 1, annexe = \"II\",",
                                   "date_reference = \"%s\")`, B = 999, graine 20260831, alpha = 0,10 (défauts,",
                                   "ceux du cas `reserve2`) ; triangles : colonnes 0..J de",
                                   "`tests/donnees/triangle_mw.csv` (8 x 6 = cas `reserve2_trapeze`)"),
                             OT$DATE_REFERENCE_TESTS)),
  "",
  "## 1. Avant la levée : refus",
  "",
  ligne_md("Trapèze", "ok", "Motifs", "Motif"), ligne_md("---", "---", "---", "---"))
for (g in names(JEUX)) {
  r <- RES_AVANT[[g]]
  out <- c(out, ligne_md(g, r$ok, length(r$validation$erreurs),
                         paste(vapply(r$validation$erreurs, lv_court, ""), collapse = " / ")))
}
out <- c(out, "",
  "## 2. Après la levée : paramètre (visa du mainteneur)", "",
  ligne_md("Grandeur", names(JEUX)), ligne_md("---", rep("---", length(JEUX))))
gr <- function(lib, f) ligne_md(lib, vapply(RES_APRES, f, ""))
aj <- function(r) r$ajustement
out <- c(out,
  gr("ok", function(r) as.character(r$ok)),
  gr("σ_USP", function(r) lv_num(r$parametre_final$sigma_usp)),
  gr("σ estimé (√MSEP / R)", function(r) lv_num(r$parametre_final$sigma_estime)),
  gr("R (réserve chain-ladder)", function(r) lv_num(aj(r)$reserve)),
  gr("√MSEP", function(r) lv_num(sqrt(r$msep$msep))),
  gr("c (crédibilité)", function(r) lv_num(r$parametre_final$credibilite)),
  gr("T = I + 1 (durée, G(3)(c))", function(r) as.character(r$metadata$T)),
  gr("I, J", function(r) sprintf("%d, %d", r$metadata$I, r$metadata$J)),
  gr("σ²_{J−1} de la règle de minimum (MSEP, simulation)",
     function(r) lv_num(aj(r)$sigma2[aj(r)$J])),
  gr("σ²_{J−1} estimateur direct (résidus) ; degrés de liberté",
     function(r) sprintf("%s ; %d", lv_num(aj(r)[["sigma2_Jm1_direct"]]), aj(r)$I - aj(r)$J)),
  gr("Intervalle bootstrap de σ (2,5 % ; 97,5 %)",
     function(r) sprintf("%s ; %s", lv_num(r$ic_bootstrap[["2.5%"]], 6), lv_num(r$ic_bootstrap[["97.5%"]], 6))),
  gr("Verdicts", function(r) {
    v <- table(factor(OT$engine_table_tests(r)$verdict, levels = c("ALERTE", "ECHEC", "INFO", "OK")))
    paste(sprintf("%d %s", as.integer(v), names(v)), collapse = ", ")
  }))
# Lignes de tests : verdict (p retenue), trapezes puis carre reserve2 (inchange)
tb <- lapply(RES_APRES, OT$engine_table_tests)
tbc <- OT$engine_table_tests(CARRE_APRES)
ident <- function(t) paste(substr(t$famille, 1, 2), t$test)
memes <- all(vapply(tb, function(t) identical(ident(t), ident(tbc)), logical(1)))
out <- c(out, "",
  "## 3. Lignes de tests après la levée : verdict (p-value retenue)", "",
  sprintf("Mêmes lignes, dans le même ordre, pour les trois trapèzes et le carré `reserve2` : %s.",
          if (memes) "oui" else "NON"), "",
  ligne_md("#", "Famille", "Test", names(JEUX), "reserve2 8 x 8 (inchangé, pour lecture)"),
  ligne_md("---", "---", "---", rep("---", length(JEUX)), "---"))
cel <- function(t, k) sprintf("%s (%s)", t$verdict[k], lv_p(t$p_retenue[k]))
for (k in seq_len(nrow(tbc)))
  out <- c(out, ligne_md(k, substr(tbc$famille[k], 1, 2), tbc$test[k],
                         vapply(tb, function(t) if (k <= nrow(t)) cel(t, k) else "—", ""), cel(tbc, k)))
out <- c(out, "", "## 4. Avertissements de la validation après la levée", "")
for (g in names(JEUX)) {
  out <- c(out, sprintf("**%s** :", g), "")
  out <- c(out, paste0("- ", RES_APRES[[g]]$validation$avertissements), "")
}
out <- c(out, "## 5. Carré `reserve2` (8 x 8)", "",
  sprintf("Objet de `run_engine()` avant / après : %s ; σ_USP = %s.",
          if (isTRUE(ctl$carre)) "`identical()`, identique au bit" else "DIFFÉRENT",
          lv_num(CARRE_APRES$parametre_final$sigma_usp)), "",
  "## Contrôles", "",
  sprintf("- avant : ok = FALSE et MW-04 seul : %s", paste(sprintf("%s %s", names(JEUX), ctl$avant), collapse = ", ")),
  sprintf("- après : ok = TRUE et avertissement de géométrie une fois : %s",
          paste(sprintf("%s %s", names(JEUX), ctl$apres), collapse = ", ")),
  sprintf("- reserve2 identical() avant / après : %s", ctl$carre),
  sprintf("- durée : %.0f s", as.numeric(difftime(Sys.time(), t_debut, units = "secs"))))
fin <- if (OK) "CONTROLES OK" else "CONTROLES ECHEC"
con_out <- stdout()
writeLines(enc2utf8(c(out, "", fin)), con_out, useBytes = TRUE)
if (!is.na(OPT_SORTIE)) {
  con <- file(OPT_SORTIE, open = "wb")
  writeLines(enc2utf8(out), con, useBytes = TRUE, sep = "\n")
  close(con)
}
unlink(FICHIER_AVANT)
quit(status = if (OK) 0L else 1L)
