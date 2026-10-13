###############################################################################
#  tests/enumeration_spearman_ex_aequo.R  --  P-VALUE BILATERALE DE SPEARMAN
#  AVEC EX AEQUO : DOUBLEMENT DE LA PLUS PETITE QUEUE (REGLE DU MOTEUR)
#  CONTRE REGLE BILATERALE DE cor.test(), n = 4 A 7 (issue #259)
#
#  OUTIL DE MESURE HORS CI : ce script n'est ni une batterie de tests ni un
#  generateur de references. Il n'est lance ni par la CI, ni par
#  test_unitaires.R (nom sans prefixe test_), ni par test_reproductibilite.R
#  (decision Q-E2d-7 du mainteneur : test unitaire si sa duree en CI reste
#  sous 10 s, script hors CI sinon ; execution complete mesuree de 20 a
#  40 s selon la machine et la charge, R 4.3.3 sous Linux). R base + stats (utils et tools, livres avec R), sans
#  alea. Il ne modifie ni R/engine.R ni tests/reference/. Sortie en markdown
#  sur la console ; fichier ecrit SEULEMENT avec --ecrire. Libelles non ASCII
#  en echappements \u (fichier source ASCII).
#
#  Usage :
#      Rscript tests/enumeration_spearman_ex_aequo.R [--ecrire [--remplacer]]
#  --remplacer sans --ecrire : refus d'usage (code 1), avant tout autre
#    controle.
#  --ecrire : ecrit dans docs/tableaux/ (date du jour)
#    <AAAAMMJJ>-issue259-spearman-ex-aequo.md. --ecrire REFUSE (code 1, rien
#    d'ecrit), des l'analyse des options, avant l'enumeration, puis de
#    nouveau avant d'ecrire (#205, #173, comme
#    tests/mesure_precision_residus_mw.R) : dossier docs/tableaux absent ;
#    commit non propre ou script non suivi
#    (motifs_non_versionnable(commit_depot())) ; code hors du depot ; garde
#    d'ecrasement garde_ecrasement() sans --remplacer. Avec --remplacer,
#    l'en-tete cite le fichier remplace et son md5 d'avant
#    (ligne_remplacement()). Le commit cite en tete est donc un SHA nu.
#
#  Objet : la p-value bilaterale de Spearman des colonnes de HomogF et
#  d'ExpVar (.mw_spearman(), n <= 9 avec ex aequo, #207, decision Q-E2c-4)
#  est lue sur la loi de permutation de S = somme A_i B_pi(i) conditionnelle
#  aux rangs moyens observes (A, B : doubles des rangs moyens, entiers),
#  comptee par .mw_spearman_comptes() ; regle du moteur
#  (.mw_spearman_loi_rangs()) : p = min(1, 2 min(P(S <= s0), P(S >= s0))).
#  Regle bilaterale de stats::cor.test(method = "spearman") (lue dans
#  stats:::cor.test.default de R 4.3.3) : q = (n^3 - n)(1 - r)/6 ; si
#  q > (n^3 - n)/6 (r < 0), queue superieure de q, sinon queue inferieure,
#  p = min(2 p, 1) ; q decroit avec r, et r croit strictement avec S : la
#  regle double donc P(S <= s0) si r < 0, P(S >= s0) si r >= 0, soit
#  n s0 < somme A somme B (comparaison en entiers, exacte) ou non. Les deux
#  regles sont appliquees ici a la MEME loi conditionnelle, enumeree par le
#  moteur ; cor.test() n'est pas appelee (avec ex aequo, elle n'enumere pas
#  cette loi).
#
#  Grille : n = 4 a 7 (tailles des colonnes de HomogF et d'ExpVar a T = 8) ;
#  structure d'ex aequo = composition de n (tailles des groupes d'ex aequo
#  dans l'ordre des valeurs), une variable de valeurs rep(1:k, tailles) ;
#  structures constantes (un seul groupe) exclues (correlation de rang non
#  definie, p NA dans .mw_spearman()) ; tous les couples ORDONNES (a, b) de
#  structures dont l'une au moins a un ex aequo (une taille > 1) ; pour
#  chaque couple, toutes les valeurs s du support de S.
#  Grandeurs, par n : couples, valeurs du support, ecarts (p du moteur
#  differente de p de la regle de cor.test(), comparaison de comptes entiers
#  divises par n!), ecarts au centre (n s = somme A somme B, r = 0) et hors
#  du centre, plus grand |r_s| sur les ecarts, plus petite p du moteur et de
#  la regle de cor.test() sur les ecarts, et nombre d'ecarts ou la p du
#  moteur est la plus petite ; puis la liste des ecarts. r_s, coefficient de
#  Spearman (cor(rank(a), rank(b)), comme .mw_spearman()) a la valeur s :
#  (n s - somme A somme B) / sqrt((n somme A^2 - (somme A)^2)
#  (n somme B^2 - (somme B)^2)), coefficient de Pearson des rangs moyens
#  doubles, affine en s.
#  Controles internes (arret, code 1, rien d'ecrit, en cas d'echec) : sur
#  chaque couple, pour trois configurations fixes et deterministes de b, la
#  p du moteur au s0 = somme A_i B_perm(i) de la configuration est identique
#  a .mw_spearman_loi_rangs(a, b[perm])$p : perm identite (a et b tries :
#  s0 = maximum du support, inegalite de rearrangement), perm = n:1 (rev(b),
#  minimum du support) et perm = pairs puis impairs (c(seq(2, n, 2),
#  seq(1, n, 2)), configuration interieure dans 4 714 couples sur 5 200, extremite sinon) ; somme des comptes egale a n!
#  (verifiee par .mw_spearman_comptes()).
#  Decomptes cites par docs/latex/doc_tests_usp.tex (227 191 valeurs,
#  378 ecarts, p >= 5/6, moteur toujours plus petit) : compares en T0 ;
#  un ecart est signale et rend le code de sortie 1 (apres ecriture avec
#  --ecrire : le tableau est un constat).
#  Statut des valeurs : ENUMERATION EXACTE (comptes entiers), sans alea ni
#  approximation ; n = 8 et 9 non couverts.
#  Code de sortie : 0 si les controles tiennent et les decomptes concordent,
#  1 sinon.
###############################################################################

t_debut <- Sys.time()
SCRIPT <- "tests/enumeration_spearman_ex_aequo.R"

# --- Locale : sortie UTF-8 sous LC_ALL=C (#113) --------------------------------
if (!isTRUE(l10n_info()[["UTF-8"]]))
  for (loc in c("C.UTF-8", "en_US.UTF-8", "fr_FR.UTF-8"))
    if (nzchar(suppressWarnings(Sys.setlocale("LC_CTYPE", loc)))) break

# --- Options -----------------------------------------------------------------
ARGS <- commandArgs(trailingOnly = TRUE)
OPTIONS_DRAPEAU <- c("--ecrire", "--remplacer")
for (a in ARGS) if (!a %in% OPTIONS_DRAPEAU) stop("option inconnue : ", a)
ECRIRE    <- "--ecrire" %in% ARGS
REMPLACER <- "--remplacer" %in% ARGS
# Refus d'usage avant tout autre controle et tout chargement (#173).
if (REMPLACER && !ECRIRE) {
  message("--remplacer : reserve a --ecrire")
  quit(status = 1L)
}

# --- Outils partages et moteur -------------------------------------------------
# tests/outils_tests.R dans un environnement dedie : RACINE, commit_depot(),
# garde_ecrasement(), empreinte_sans_commentaires(), et le moteur qu'il
# charge (.mw_spearman_comptes(), .mw_spearman_loi_rangs()).
OT <- new.env()
sys.source(file.path(if (file.exists("tests/outils_tests.R")) "tests" else
                     if (file.exists("outils_tests.R")) "." else
                     stop("lancer depuis la racine du depot"), "outils_tests.R"), envir = OT)
RACINE <- OT$RACINE
FICHIER_MOTEUR <- file.path(RACINE, "R", "engine.R")

# --- Gardes de --ecrire (#205, #173) -------------------------------------------
# Cible fixee par la date du jour. Gardes ANTICIPEES des l'analyse des
# options, avant l'enumeration : dossier docs/tableaux, commit propre et
# script suivi (motifs_non_versionnable()), garde d'ecrasement ; puis gardes
# FINALES avant d'ecrire (l'etat du depot peut changer pendant le calcul).
# Fonctions et ordre de tests/mesure_precision_residus_mw.R.
DATE <- format(Sys.Date(), "%Y%m%d")
CIBLE_MD <- file.path(RACINE, "docs", "tableaux", paste0(DATE, "-issue259-spearman-ex-aequo.md"))
# Empreintes du code execute : md5 de ce script et de tests/outils_tests.R ;
# "hors depot" si le script execute n'est pas celui du depot.
empreintes_code <- function() {
  f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  md5 <- function(x) if (!length(x) || !file.exists(x)) "absent" else unname(tools::md5sum(x))
  dans <- length(f) == 1L && identical(normalizePath(f, winslash = "/", mustWork = FALSE),
                                       normalizePath(file.path(RACINE, SCRIPT), winslash = "/", mustWork = FALSE))
  sprintf("%s %s%s ; tests/outils_tests.R %s", SCRIPT, md5(f), if (dans) "" else " (hors d\u00e9p\u00f4t)",
          md5(file.path(RACINE, "tests", "outils_tests.R")))
}
gardes_ecrire <- function(quand) {
  if (!dir.exists(file.path(RACINE, "docs", "tableaux"))) stop("dossier de sortie introuvable : docs/tableaux")
  nv <- OT$motifs_non_versionnable(OT$commit_depot(SCRIPT), empreintes_code(), quand)
  if (length(nv)) {
    message("--ecrire refuse (tableau versionne dans docs/tableaux/) : ", paste(nv, collapse = " ; "),
            " -- aucun fichier ecrit")
    quit(status = 1L)
  }
  OT$garde_ecrasement(CIBLE_MD, remplacer = REMPLACER, racine = RACINE)
}
REMPLACES <- NULL
if (ECRIRE) REMPLACES <- gardes_ecrire("de l'ex\u00e9cution")
COMMIT <- OT$commit_depot(SCRIPT)
MD5_MOTEUR <- unname(tools::md5sum(FICHIER_MOTEUR))

# --- Enumeration ---------------------------------------------------------------
# Compositions de n (tailles des groupes dans l'ordre des valeurs).
compositions <- function(n) {
  if (n == 0L) return(list(integer(0)))
  unlist(lapply(seq_len(n), function(k) lapply(compositions(n - k), function(r) c(k, r))),
         recursive = FALSE)
}
# Un n : tous les couples ordonnes de structures non constantes dont l'une
# au moins a un ex aequo. Renvoie les decomptes et les ecarts.
enumerer_taille <- function(n) {
  cs <- Filter(function(x) length(x) > 1L, compositions(n))
  ex <- vapply(cs, function(x) any(x > 1L), TRUE)
  lib <- vapply(cs, function(x) paste0("(", paste(x, collapse = ","), ")"), "")
  n_couples <- 0L; n_valeurs <- 0; ctrl_ko <- character(0); ecarts <- list()
  for (i in seq_along(cs)) for (j in seq_along(cs)) {
    if (!ex[i] && !ex[j]) next
    a <- rep(seq_along(cs[[i]]), cs[[i]]); b <- rep(seq_along(cs[[j]]), cs[[j]])
    A <- as.integer(round(2 * rank(a))); B <- as.integer(round(2 * rank(b)))
    lc <- OT$.mw_spearman_comptes(sort(A), sort(B))
    bas <- cumsum(lc$n); haut <- rev(cumsum(rev(lc$n)))      # comptes de S <= s, S >= s
    q_moteur <- pmin(lc$total, 2 * pmin(bas, haut))
    positif <- n * lc$s >= sum(A) * sum(B)                    # r >= 0
    q_ct <- pmin(lc$total, 2 * ifelse(positif, haut, bas))
    # controle : regle du moteur au s0 de trois configurations de b
    # (maximum, minimum, et en general interieure du support) = .mw_spearman_loi_rangs()
    for (perm in list(seq_len(n), n:1, c(seq(2L, n, 2L), seq(1L, n, 2L)))) {
      k0 <- match(sum(A * B[perm]), lc$s)
      if (is.na(k0) || !identical(q_moteur[k0] / lc$total, OT$.mw_spearman_loi_rangs(a, b[perm])$p))
        ctrl_ko <- c(ctrl_ko, sprintf("n = %d, %s x %s, perm %s", n, lib[i], lib[j], paste(perm, collapse = "")))
    }
    n_couples <- n_couples + 1L
    n_valeurs <- n_valeurs + length(lc$s)
    d <- which(q_moteur != q_ct)
    if (length(d))
      ecarts[[length(ecarts) + 1L]] <- data.frame(n = n, a = lib[i], b = lib[j], s = lc$s[d],
                                                  centre = sum(A) * sum(B) / n,
                                                  au_centre = n * lc$s[d] == sum(A) * sum(B),
                                                  r_s = (n * lc$s[d] - sum(A) * sum(B)) /
                                                    sqrt((n * sum(A^2) - sum(A)^2) * (n * sum(B^2) - sum(B)^2)),
                                                  p_moteur = q_moteur[d] / lc$total, p_cortest = q_ct[d] / lc$total,
                                                  stringsAsFactors = FALSE)
  }
  ecarts <- if (length(ecarts)) do.call(rbind, ecarts) else
    data.frame(n = integer(0), a = character(0), b = character(0), s = numeric(0), centre = numeric(0),
               au_centre = logical(0), r_s = numeric(0), p_moteur = numeric(0), p_cortest = numeric(0), stringsAsFactors = FALSE)
  list(n = n, structures = length(cs), couples = n_couples, valeurs = n_valeurs, ecarts = ecarts,
       ctrl_ko = ctrl_ko)
}
TAILLES <- 4:7
RES <- lapply(TAILLES, enumerer_taille)
CTRL_KO <- unlist(lapply(RES, `[[`, "ctrl_ko"))
if (length(CTRL_KO)) {
  message("controle interne en echec (regle du moteur differente de .mw_spearman_loi_rangs()) : ",
          paste(utils::head(CTRL_KO, 10L), collapse = " ; "), " -- aucun fichier ecrit")
  quit(status = 1L)
}
ECARTS <- do.call(rbind, lapply(RES, `[[`, "ecarts"))

# --- Decomptes et comparaison au .tex -------------------------------------------
TOTAL_VALEURS <- sum(vapply(RES, `[[`, 0, "valeurs"))
TOTAL_ECARTS <- nrow(ECARTS)
P_MIN_ECART <- if (TOTAL_ECARTS) min(ECARTS$p_moteur, ECARTS$p_cortest) else NA_real_
MOTEUR_PLUS_PETIT <- sum(ECARTS$p_moteur < ECARTS$p_cortest)
TEX <- list(valeurs = 227191, ecarts = 378L, p_min = 5 / 6)
CONCORDE <- TOTAL_VALEURS == TEX$valeurs && TOTAL_ECARTS == TEX$ecarts &&
  (!TOTAL_ECARTS || P_MIN_ECART >= TEX$p_min) && MOTEUR_PLUS_PETIT == TOTAL_ECARTS

# --- Sorties --------------------------------------------------------------------
# Gardes finales, avant de composer l'en-tete (fichier remplace cite).
if (ECRIRE) REMPLACES <- gardes_ecrire("de l'ex\u00e9cution")
duree <- as.numeric(difftime(Sys.time(), t_debut, units = "secs"))
fr <- function(x) formatC(x, format = "d", big.mark = "\u00a0")
pf <- function(x) ifelse(is.na(x), "\u2014", formatC(x, format = "f", digits = 6))

md <- c(
  "# P-value bilat\u00e9rale de Spearman avec ex \u00e6quo : doublement de la plus petite queue contre r\u00e8gle de `cor.test()` (issue #259)",
  "",
  "### T0 \u2014 Ex\u00e9cution",
  "",
  "| Grandeur | Valeur |", "|---|---|",
  sprintf("| Date | %s |", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")),
  sprintf("| Script | `%s` |", SCRIPT),
  sprintf("| Commit | `%s` |", COMMIT),
  sprintf("| Empreintes du code | %s |", empreintes_code()),
  sprintf("| Moteur | `R/engine.R`, md5 `%s`, empreinte sans commentaires `%s` |", MD5_MOTEUR,
          OT$empreinte_sans_commentaires(FICHIER_MOTEUR)),
  sprintf("| R | %s, %s |", R.version.string, Sys.info()[["sysname"]]),
  OT$ligne_remplacement(REMPLACES, CIBLE_MD),
  sprintf("| Dur\u00e9e | %.1f s |", duree),
  sprintf("| D\u00e9comptes du `.tex` (227 191 valeurs, 378 \u00e9carts, p \u2265 5/6, moteur toujours plus petit) | %s |",
          if (CONCORDE) "reproduits" else "NON reproduits"),
  "| Structures d'ex \u00e6quo | non constantes : une structure \u00e0 un seul groupe est exclue (`.mw_spearman()` y rend p = NA) |",
  "",
  "Statut : \u00e9num\u00e9ration exacte (comptes entiers de `.mw_spearman_comptes()`), sans al\u00e9a ni approximation.",
  "Structure d'ex \u00e6quo : tailles des groupes dans l'ordre des valeurs (composition de n), structures non constantes seulement ;",
  "couples ordonn\u00e9s (a, b) dont l'une au moins a un ex \u00e6quo ; toutes les valeurs s du support de S = \u2211 A_i B_\u03c0(i),",
  "loi conditionnelle aux rangs moyens. R\u00e8gle du moteur : p = min(1, 2 min(P(S \u2264 s), P(S \u2265 s))).",
  "R\u00e8gle de `cor.test()` : p = min(1, 2 P(S \u2264 s)) si r < 0, min(1, 2 P(S \u2265 s)) sinon (r \u2265 0), sur la m\u00eame loi.",
  "Centre : n s = \u2211 A \u2211 B (r_s = 0). r_s : coefficient de Spearman \u00e0 la valeur s.",
  "",
  "### T1 \u2014 D\u00e9comptes par taille",
  "",
  "| n | Structures non constantes | Couples ordonn\u00e9s | Valeurs du support | \u00c9carts | \u00c9carts au centre | \u00c9carts hors du centre | Plus grand \\|r_s\\| sur les \u00e9carts | Plus petite p sur les \u00e9carts (moteur) | Plus petite p sur les \u00e9carts (`cor.test()`) | \u00c9carts o\u00f9 la p du moteur est la plus petite |",
  "|---|---|---|---|---|---|---|---|---|---|---|")
ligne_t1 <- function(etiquette, structures, couples, valeurs, e)
  sprintf("| %s | %d | %s | %s | %d | %d | %d | %s | %s | %s | %d |", etiquette, structures, fr(couples), fr(valeurs),
          nrow(e), sum(e$au_centre), sum(!e$au_centre), pf(if (nrow(e)) max(abs(e$r_s)) else NA),
          pf(if (nrow(e)) min(e$p_moteur) else NA), pf(if (nrow(e)) min(e$p_cortest) else NA),
          sum(e$p_moteur < e$p_cortest))
for (r in RES) md <- c(md, ligne_t1(as.character(r$n), r$structures, r$couples, r$valeurs, r$ecarts))
md <- c(md, ligne_t1("Total", sum(vapply(RES, `[[`, 0L, "structures")), sum(vapply(RES, `[[`, 0L, "couples")),
                     TOTAL_VALEURS, ECARTS),
        "", "### T2 \u2014 \u00c9carts", "",
        "| n | Structure a | Structure b | s | Centre | r_s | p moteur | p `cor.test()` |", "|---|---|---|---|---|---|---|---|")
if (TOTAL_ECARTS)
  md <- c(md, sprintf("| %d | %s | %s | %d | %s | %s | %s | %s |", ECARTS$n, ECARTS$a, ECARTS$b, as.integer(ECARTS$s),
                      formatC(ECARTS$centre, format = "f", digits = 3), pf(ECARTS$r_s), pf(ECARTS$p_moteur),
                      pf(ECARTS$p_cortest)))

ecrire_console <- function(x) writeLines(enc2utf8(x), con = stdout(), useBytes = TRUE)
ecrire_console(md)

if (ECRIRE) {
  con <- file(CIBLE_MD, open = "wb"); writeLines(enc2utf8(md), con, useBytes = TRUE); close(con)
  cat(sprintf("\nEcrit : %s\n", CIBLE_MD), file = stderr())
}
if (!CONCORDE) {
  message("decomptes differents de ceux du .tex (227 191 valeurs, 378 ecarts, p >= 5/6, moteur toujours plus petit)")
  quit(status = 1L)
}
quit(status = 0L)
