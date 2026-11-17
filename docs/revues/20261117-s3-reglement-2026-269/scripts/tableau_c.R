###############################################################################
# Tableau avant / apres du commit (c) de S3 (issue #504, ADR 0019, point 3).
# Avant : appel a DATE_REFERENCE_TESTS (texte "2019/981") ; apres : le meme
# appel a "2027-01-30" (texte "2026/269"). Meme moteur (arbre de travail),
# B = 999 et graine par defaut (ceux des references).
# Comparateur : aplatir() et ecart_feuille() de tests/outils_tests.R.
# Controle d'anteriorite : l'appel "avant" est compare a l'outil d'avant S3
# (R/engine.R de main, avant de83b19, md5 a73c2f20...) et a la tete
# b7f40a7, charges dans des environnements separes (charger_moteur(dans =
# NULL)).
# Usage (racine du depot) :
#   LC_ALL=C.UTF-8 Rscript <ce script> <sortie.md> <engine_avant_s3.R> <engine_b7f40a7.R>
# Moteurs de comparaison : git show edf7ff9:R/engine.R > engine_avant_s3.R ;
#   git show b7f40a7:R/engine.R > engine_b7f40a7.R (md5 cites dans le tableau).
###############################################################################
args <- commandArgs(TRUE)
sortie <- args[1]; f_avant_s3 <- args[2]; f_b7 <- args[3]
t_debut <- Sys.time()
RACINE <- "."
outils <- new.env(parent = globalenv())
sys.source("tests/outils_tests.R", envir = outils)   # charge aussi le moteur courant
source("R/charger_moteur.R")
moteur <- charger_moteur("R/engine.R", dans = NULL)
m_s3 <- charger_moteur(f_avant_s3, dans = NULL)
m_b7 <- charger_moteur(f_b7, dans = NULL)
aplatir <- outils$aplatir; ecart_feuille <- outils$ecart_feuille
DATE_AVANT <- outils$DATE_REFERENCE_TESTS; DATE_APRES <- "2027-01-30"
stopifnot(identical(DATE_AVANT, "2026-12-31"))

jeux <- list(donnees_ln = read.csv("tests/donnees/donnees_ln.csv"),
             donnees_ln_interieur = read.csv("tests/donnees/donnees_ln_interieur.csv"))
tri <- outils$.tri
nettoyer <- function(r) { r$metadata[c("horodatage", "duree_sec", "version_R")] <- NULL; r }

# Cas : (etiquette, arguments communs, declaration ajoutee aux deux appels)
cas <- list()
for (j in names(jeux)) for (s in c(1, 4, 5)) for (np in c(FALSE, TRUE))
  cas[[length(cas) + 1L]] <- list(
    id = sprintf("%s II-%d nettes, réassurance NP %s", j, s, if (np) "déclarée présente (TRUE)" else "déclarée absente (FALSE)"),
    jeu = j, groupe = if (np) "avec NP" else "sans NP", segment = sprintf("II-%d", s),
    args = list(xt = jeux[[j]]$xt, yt = jeux[[j]]$yt, methode = "premium", segment = s,
                annexe = "II", nature_donnees = "nettes", reassurance_np = np))
# Temoins attendus sans ecart.
for (j in names(jeux))
  cas[[length(cas) + 1L]] <- list(id = sprintf("%s II-1 brutes, sans déclaration (témoin)", j), jeu = j,
    groupe = "temoin", segment = "II-1",
    args = list(xt = jeux[[j]]$xt, yt = jeux[[j]]$yt, methode = "premium", segment = 1,
                annexe = "II", nature_donnees = "brutes"))
cas[[length(cas) + 1L]] <- list(id = "donnees_ln II-6 nettes, réassurance NP déclarée absente (FALSE) (témoin)",
  jeu = "donnees_ln", groupe = "temoin", segment = "II-6",
  args = list(xt = jeux$donnees_ln$xt, yt = jeux$donnees_ln$yt, methode = "premium", segment = 6,
              annexe = "II", nature_donnees = "nettes", reassurance_np = FALSE))
cas[[length(cas) + 1L]] <- list(id = "donnees_ln XIV-1 nettes, réassurance NP déclarée absente (FALSE) (témoin)",
  jeu = "donnees_ln", groupe = "temoin", segment = "XIV-1",
  args = list(xt = jeux$donnees_ln$xt, yt = jeux$donnees_ln$yt, methode = "premium", segment = 1,
              annexe = "XIV", nature_donnees = "nettes", reassurance_np = FALSE))
cas[[length(cas) + 1L]] <- list(id = "reserve1 (donnees_ln, II-1), CDD qualifiante déclarée absente (FALSE) (témoin)",
  jeu = "donnees_ln", groupe = "temoin", segment = "II-1",
  args = list(xt = jeux$donnees_ln$xt, yt = jeux$donnees_ln$yt, methode = "reserve1", segment = 1,
              annexe = "II", cdd_qualifiante = FALSE))
cas[[length(cas) + 1L]] <- list(id = "reserve2 (triangle_mw, II-1), CDD qualifiante déclarée absente (FALSE) (témoin)",
  jeu = "triangle_mw", groupe = "temoin", segment = "II-1",
  args = list(methode = "reserve2", triangle = tri, segment = 1, annexe = "II",
              cdd_qualifiante = FALSE))

executer <- function(k) {
  a <- cas[[k]]$args
  av <- nettoyer(do.call(moteur$run_engine, c(a, list(date_reference = DATE_AVANT))))
  ap <- nettoyer(do.call(moteur$run_engine, c(a, list(date_reference = DATE_APRES))))
  # Anteriorite : outil d'avant S3 (sans date ni declaration) et tete b7f40a7.
  a_s3 <- a[setdiff(names(a), c("reassurance_np", "cdd_qualifiante"))]
  s3 <- nettoyer(do.call(m_s3$run_engine, a_s3))
  b7 <- nettoyer(do.call(m_b7$run_engine, c(a, list(date_reference = DATE_AVANT))))
  list(avant = av, apres = ap, s3 = s3, b7 = b7)
}
R <- parallel::mclapply(seq_along(cas), executer, mc.cores = 3L)
stopifnot(all(vapply(R, function(x) isTRUE(x$avant$ok) && isTRUE(x$apres$ok) &&
                       isTRUE(x$s3$ok) && isTRUE(x$b7$ok), logical(1))))

# Feuilles non identiques entre deux sous-objets (aplatir + ecart_feuille).
diff_feuilles <- function(a, b) {
  fa <- aplatir(a); fb <- aplatir(b)
  stopifnot(identical(names(fa), names(fb)))
  l <- lapply(seq_along(fa), function(i) {
    j <- ecart_feuille(fa[[i]], fb[[i]], tol = 0)
    if (identical(j$mesure, "identique")) NULL else
      data.frame(chemin = names(fa)[i], avant = I(list(fa[[i]])), apres = I(list(fb[[i]])),
                 ecart = j$ecart, mesure = j$mesure, stringsAsFactors = FALSE)
  })
  l <- Filter(Negate(is.null), l)
  if (length(l)) do.call(rbind, l) else
    data.frame(chemin = character(0), avant = I(list()), apres = I(list()), ecart = numeric(0),
               mesure = character(0))
}
num <- function(x, d = 10) if (is.numeric(x) && length(x) == 1L && !is.na(x))
  trimws(formatC(x, digits = d, format = "g")) else if (length(x) == 1L && is.na(x)) "NA" else
  gsub("\\|", "\\\\|", paste(as.character(x), collapse = " "))
fr <- function(s) gsub(".", ",", s, fixed = TRUE)

CHAMPS_CHANGENT <- c("parametre_final", "candidats", "calibration", "ic_bootstrap",
                     "ic_bootstrap_restreint", "ic_bootstrap_basic_log", "jackknife",
                     "ajustement", "plots_data", "metadata", "tests")
CHAMPS_FIXES <- c("bootstrap", "profil", "lr_delta", "controles")
CHAMPS_P <- c("p_exacte", "p_asymptotique", "p_mc", "err_mc", "p_retenue", "p_min", "p_min_mc",
              "nature_p", "verdict", "inoperant")

L <- character(0); ecr <- function(...) L <<- c(L, paste0(...))
md5 <- function(f) unname(tools::md5sum(f))
ecr("# Tableau avant / après — facteur NP conditionnel de l'art. 117, paragraphe 3, à partir du 30.1.2027 (issue #504, commit (c) de S3, ADR 0019, point 3)")
ecr("")
ecr("| Grandeur | Valeur |")
ecr("|---|---|")
ecr("| Date | ", format(Sys.Date(), "%Y-%m-%d"), " |")
ecr("| Commande | `LC_ALL=C.UTF-8 Rscript docs/revues/20261117-s3-reglement-2026-269/scripts/tableau_c.R docs/tableaux/20261117-issue504-facteur-np-conditionnel.md engine_avant_s3.R engine_b7f40a7.R` (racine du dépôt ; moteurs de comparaison tirés par `git show edf7ff9:R/engine.R` et `git show b7f40a7:R/engine.R`) |")
ecr("| Script | `tableau_c.R`, md5 `", md5(sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))), "` |")
ecr("| Moteur (après (c)) | `R/engine.R` de l'arbre de travail, md5 `", md5("R/engine.R"), "` |")
ecr("| Outil d'avant S3 | `R/engine.R` de `de83b19^` (`main` avant S3), md5 `", md5(f_avant_s3), "` |")
ecr("| Tête de la branche avant (c) | `R/engine.R` de `b7f40a7`, md5 `", md5(f_b7), "` |")
ecr("| Commit de base | `", system("git rev-parse HEAD", intern = TRUE), "` (arbre de travail modifié : moteur identifié par son md5) |")
ecr("| R, plateforme | ", R.version.string, " ; ", utils::sessionInfo()$running, " ; BLAS : ", basename(extSoftVersion()[["BLAS"]]), " |")
ecr("| Appels | `run_engine()` complet, B = 999, graine 20260831, alpha = 0,10 (défauts, ceux des références) ; **avant** : `date_reference = DATE_REFERENCE_TESTS` (\"2026-12-31\", texte `\"2019/981\"`) ; **après** : `date_reference = \"2027-01-30\"` (texte `\"2026/269\"`), mêmes autres arguments, déclaration comprise |")
ecr("| Comparateur | `aplatir()` et `ecart_feuille()` de `tests/outils_tests.R` (tol = 0 : toute feuille non `identical()` est listée ; écart relatif si \\|avant\\| > 1e-6, absolu sinon) |")
ecr("")
ecr("Lecture : « sans NP » = réassurance non proportionnelle déclarée absente (`reassurance_np = FALSE`) ; « avec NP » = déclarée présente (`TRUE`). ",
    "Sous le texte `\"2019/981\"` la déclaration est sans effet (facteur NP standard sans condition) : l'appel « avant » est donc le résultat de l'outil d'avant S3 (contrôle d'antériorité, § 5). ",
    "II-4 et II-5 sont illustratifs : mêmes données réaffectées à un autre segment (seuls le σ standard et le barème changent ; avis d'`actuary`, § 3.2).")
ecr("")

# --- T1 : sigma_USP ---
ecr("## 1. σ_USP et σ standard (visa du mainteneur)")
ecr("")
ecr("| Cas | Groupe | σ standard avant | σ standard après | σ_USP avant | σ_USP après | Δσ_USP | Δ relatif | variation_relative avant | variation_relative après |")
ecr("|---|---|---|---|---|---|---|---|---|---|")
for (k in seq_along(cas)) {
  pa <- R[[k]]$avant$parametre_final; pb <- R[[k]]$apres$parametre_final
  d <- pb$sigma_usp - pa$sigma_usp
  ecr("| ", cas[[k]]$id, " | ", cas[[k]]$groupe, " | ", fr(num(pa$sigma_standard)), " | ", fr(num(pb$sigma_standard)),
      " | ", fr(num(pa$sigma_usp)), " | ", fr(num(pb$sigma_usp)), " | ",
      if (identical(pa$sigma_usp, pb$sigma_usp)) "0 (identical)" else fr(sprintf("%+.10g", d)), " | ",
      if (identical(pa$sigma_usp, pb$sigma_usp)) "0" else fr(sprintf("%+.2f %%", 100 * d / pa$sigma_usp)), " | ",
      fr(num(pa$variation_relative)), " | ", fr(num(pb$variation_relative)), " |")
}
ecr("")
# Delta theorique (1 - c) x 0,2 x sigma brut, c lu sur parametre_final.
ecr("Contrôle : pour chaque cas « sans NP », Δσ_USP comparé à (1 − c) × (σ brut − NP × σ brut) = (1 − c) × 0,2 × σ brut, c lu dans `parametre_final$credibilite` :")
ecr("")
ecr("| Cas | c | σ brut | (1 − c) × 0,2 × σ brut | Δσ_USP mesuré | \\|écart\\| |")
ecr("|---|---|---|---|---|---|")
for (k in which(vapply(cas, `[[`, "", "groupe") == "sans NP")) {
  pa <- R[[k]]$avant$parametre_final; pb <- R[[k]]$apres$parametre_final
  th <- (1 - pa$credibilite) * (pb$sigma_standard - pa$sigma_standard)
  ecr("| ", cas[[k]]$id, " | ", fr(num(pa$credibilite)), " | ", fr(num(pb$sigma_standard)), " | ",
      fr(num((1 - pa$credibilite) * 0.2 * pb$sigma_standard)), " | ", fr(num(pb$sigma_usp - pa$sigma_usp)),
      " | ", fr(trimws(formatC(abs(pb$sigma_usp - pa$sigma_usp - th), digits = 3, format = "g"))), " |")
}
ecr("")


# --- T1b : champs de metadata ---
ecr("## 1 bis. `metadata` : σ standard et les quatre champs nouveaux (avant → après)")
ecr("")
ecr("| Cas | `sigma_standard` | `date_reference` | `texte_applicable` | `reassurance_np` | `cdd_qualifiante` |")
ecr("|---|---|---|---|---|---|")
fl <- function(a, b) { fa <- num(a); fb <- num(b); if (identical(a, b)) fr(fa) else paste0(fr(fa), " → ", fr(fb)) }
for (k in seq_along(cas)) {
  ma <- R[[k]]$avant$metadata; mb <- R[[k]]$apres$metadata
  ecr("| ", cas[[k]]$id, " | ", fl(ma$sigma_standard, mb$sigma_standard), " | ",
      fl(ma$date_reference, mb$date_reference), " | ", fl(ma$texte_applicable, mb$texte_applicable), " | ",
      fl(ma$reassurance_np, mb$reassurance_np), " | ", fl(ma$cdd_qualifiante, mb$cdd_qualifiante), " |")
}
ecr("")
ecr("`NA` : déclaration non fournie (« non déclarée »). La déclaration est la même dans les deux appels : seuls la date, le texte et, sans NP, le σ standard changent.")
ecr("")
# Identite de la ligne (c) : II-1 sans NP apres = donnees brutes apres, hors
# nature_donnees et reassurance_np.
ecr("Identité de la ligne (c) du plan, sur les deux jeux : à 2027-01-30, II-1 nettes sans NP `identical()` à II-1 brutes (témoin), hors `metadata$nature_donnees` et `metadata$reassurance_np` :")
ecr("")
ids <- vapply(cas, `[[`, "", "id")
for (j in names(jeux)) {
  a <- R[[which(ids == sprintf("%s II-1 nettes, réassurance NP déclarée absente (FALSE)", j))]]$apres
  b <- R[[which(ids == sprintf("%s II-1 brutes, sans déclaration (témoin)", j))]]$apres
  a$metadata[c("nature_donnees", "reassurance_np")] <- NULL; b$metadata[c("nature_donnees", "reassurance_np")] <- NULL
  ecr("- ", j, " : **", if (identical(a, b)) "identical" else "DIFFERENT", "**")
}
ecr("")
# --- T2 : synthese par champ ---
ecr("## 2. Synthèse par champ (feuilles non `identical()` entre avant et après)")
ecr("")
ecr("Champs du § 3.1 de l'avis d'`actuary` ; « autres » = tous les autres champs de l'objet. Écart max : relatif (\\|avant\\| > 1e-6) ou absolu.")
ecr("")
ecr("| Cas | Champ | Feuilles | Changées | Écart max | Feuille de l'écart max |")
ecr("|---|---|---|---|---|---|")
tous_champs <- names(R[[1]]$avant)
synth <- list()
for (k in seq_along(cas)) {
  av <- R[[k]]$avant; ap <- R[[k]]$apres
  stopifnot(identical(names(av), names(ap)))
  for (ch in c(CHAMPS_CHANGENT, "autres")) {
    sa <- if (ch == "autres") av[setdiff(names(av), CHAMPS_CHANGENT)] else av[[ch]]
    sb <- if (ch == "autres") ap[setdiff(names(ap), CHAMPS_CHANGENT)] else ap[[ch]]
    if (is.null(sa) && is.null(sb)) next
    df <- diff_feuilles(sa, sb)
    n <- length(aplatir(sa))
    e <- suppressWarnings(max(df$ecart, na.rm = TRUE))
    i <- if (nrow(df) && any(!is.na(df$ecart))) which.max(df$ecart) else NA
    synth[[length(synth) + 1L]] <- data.frame(k = k, champ = ch, n = n, changees = nrow(df))
    if (cas[[k]]$groupe != "sans NP" && !nrow(df) && ch != "metadata") next
    ecr("| ", cas[[k]]$id, " | `", ch, "` | ", n, " | ", nrow(df), " | ",
        if (is.na(i)) (if (nrow(df)) "non numérique" else "—") else fr(trimws(formatC(e, digits = 4, format = "g"))),
        " | ", if (is.na(i)) (if (nrow(df)) paste0("`", paste(df$chemin, collapse = "`, `"), "`") else "—")
        else paste0("`", df$chemin[i], "`"), " |")
  }
}
synth <- do.call(rbind, synth)
ecr("")
ecr("Cas « avec NP » et témoins : seules les lignes non vides sont listées, plus `metadata` ; tout autre champ a 0 feuille changée (contrôle : ",
    sum(synth$changees[!(vapply(cas, `[[`, "", "groupe")[synth$k] == "sans NP") & synth$champ != "metadata"]),
    " feuille changée hors `metadata` sur ces ", sum(vapply(cas, `[[`, "", "groupe") != "sans NP"), " cas).")
ecr("")

# --- T3 : detail feuille a feuille, cas sans NP, hors plots_data ---
ecr("## 3. Détail feuille par feuille, cas « sans NP » (hors `plots_data`, résumé au § 2 et ci-dessous)")
ecr("")
for (k in which(vapply(cas, `[[`, "", "groupe") == "sans NP")) {
  av <- R[[k]]$avant; ap <- R[[k]]$apres
  ecr("### ", cas[[k]]$id)
  ecr("")
  ecr("| Feuille | Avant | Après | Écart | Mesure |")
  ecr("|---|---|---|---|---|")
  for (ch in setdiff(CHAMPS_CHANGENT, "plots_data")) {
    df <- diff_feuilles(av[[ch]], ap[[ch]])
    for (i in seq_len(nrow(df)))
      ecr("| `", ch, if (startsWith(df$chemin[i], "[")) "" else "$", df$chemin[i], "` | ",
          fr(num(df$avant[[i]])), " | ", fr(num(df$apres[[i]])), " | ",
          if (is.na(df$ecart[i])) "" else fr(trimws(formatC(df$ecart[i], digits = 4, format = "g"))), " | ",
          df$mesure[i], " |")
  }
  pd <- diff_feuilles(av$plots_data, ap$plots_data)
  sous <- sub("^([^$\\[]+).*$", "\\1", pd$chemin)
  ecr("")
  ecr("`plots_data` : ", nrow(pd), " feuille(s) changée(s) sur ", length(aplatir(av$plots_data)),
      ", écart max ", fr(trimws(formatC(max(pd$ecart, na.rm = TRUE), digits = 4, format = "g"))), " (",
      pd$mesure[which.max(pd$ecart)], ", `plots_data$", pd$chemin[which.max(pd$ecart)], "`) ; par élément : ",
      paste(sprintf("`%s` %d", names(table(sous)), as.integer(table(sous))), collapse = ", "), ".")
  ecr("")
}

# --- T4 : preuve de ce qui ne change pas ---
ecr("## 4. Preuve de ce qui ne change pas (`identical()`)")
ecr("")
ecr("| Cas | bootstrap | profil | lr_delta | controles | p-values et verdicts des ", length(R[[1]]$avant$tests),
    " lignes de `tests` (", paste(CHAMPS_P, collapse = ", "), ") | lignes de `tests` changées | objet entier hors `metadata$date_reference` et `metadata$texte_applicable` |")
ecr("|---|---|---|---|---|---|---|---|")
ok_tout <- TRUE
for (k in seq_along(cas)) {
  av <- R[[k]]$avant; ap <- R[[k]]$apres
  fixes <- vapply(CHAMPS_FIXES, function(ch) identical(av[[ch]], ap[[ch]]), logical(1))
  pv <- identical(lapply(av$tests, `[`, CHAMPS_P), lapply(ap$tests, `[`, CHAMPS_P))
  lch <- which(!vapply(seq_along(av$tests), function(i) identical(av$tests[[i]], ap$tests[[i]]), logical(1)))
  desc <- if (!length(lch)) "aucune" else paste(vapply(lch, function(i)
    sprintf("%d (%s ; %s ; champs : %s)", i, av$tests[[i]]$test, av$tests[[i]]$verdict,
            paste(names(av$tests[[i]])[!mapply(identical, av$tests[[i]], ap$tests[[i]])], collapse = ", ")),
    character(1)), collapse = " ; ")
  sans <- function(r) { r$metadata[c("date_reference", "texte_applicable")] <- NULL; r }
  ent <- identical(sans(av), sans(ap))
  if (cas[[k]]$groupe != "sans NP") ok_tout <- ok_tout && ent
  ok_tout <- ok_tout && all(fixes) && pv
  if (cas[[k]]$groupe == "sans NP")
    ok_tout <- ok_tout && all(vapply(lch, function(i) startsWith(av$tests[[i]]$famille, "G.") &&
                                       identical(av$tests[[i]]$verdict, "INFO"), logical(1)))
  ecr("| ", cas[[k]]$id, " | ", paste(ifelse(fixes, "identical", "**DIFFERENT**"), collapse = " | "), " | ",
      if (pv) "identical" else "**DIFFERENT**", " | ", desc, " | ", if (ent) "identical" else "non (champs du § 2)", " |")
}
ecr("")
ecr("Contrôle global (bootstrap, profil, lr_delta, controles, p-values et verdicts identical() partout ; lignes de `tests` changées toutes de la famille G au verdict INFO ; cas « avec NP » et témoins identical() hors date et texte) : **", if (ok_tout) "OK" else "ÉCHEC", "**.")
ecr("")

# --- T5 : anteriorite ---
ecr("## 5. Contrôle d'antériorité : l'appel « avant » est le résultat de l'outil d'avant S3")
ecr("")
ecr("| Cas | avant (c) = tête `b7f40a7`, même appel (`identical()`, hors champs d'exécution) | avant (c) = outil d'avant S3 sans date ni déclaration (`identical()`, hors les quatre champs nouveaux de `metadata`) |")
ecr("|---|---|---|")
ok_ant <- TRUE
for (k in seq_along(cas)) {
  av <- R[[k]]$avant
  s4 <- function(r) { r$metadata[c("date_reference", "texte_applicable", "reassurance_np", "cdd_qualifiante")] <- NULL; r }
  i1 <- identical(av, R[[k]]$b7); i2 <- identical(s4(av), s4(R[[k]]$s3))
  ok_ant <- ok_ant && i1 && i2
  ecr("| ", cas[[k]]$id, " | ", if (i1) "identical" else "**DIFFERENT**", " | ", if (i2) "identical" else "**DIFFERENT**", " |")
}
ecr("")
ecr("Contrôle d'antériorité : **", if (ok_ant) "OK" else "ÉCHEC", "**. Durée : ",
    round(as.numeric(difftime(Sys.time(), t_debut, units = "secs"))), " s (3 processus).")
writeLines(L, sortie, useBytes = TRUE)
cat(sprintf("ecrit : %s ; controle global %s ; anteriorite %s\n", sortie, ok_tout, ok_ant))
