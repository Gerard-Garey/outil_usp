###############################################################################
#  tests/unitaires/test_affichage_regime_t8.R  --  AFFICHAGE DU SCRIPT DE
#  MESURE DE #229 (tests/p_conditionnelle_regime_t8.R ; issue #242)
#
#  Le script de mesure execute son calcul au chargement : il n'est pas
#  source. Ses definitions sont relues par parse() (keep.source = FALSE) :
#  toutes les fonctions definies au niveau superieur, et les seules
#  constantes de la liste CONST_229 (aucune lecture de donnees, aucun
#  calcul, aucun appel au moteur), evaluees dans un environnement dedie.
#  Les tableaux sont alors produits sur des replications synthetiques
#  (lignes REP fabriquees, lues par en_table() et matrices() comme par
#  --combiner), sans bootstrap. Constats de #242 :
#    D-a  chemins hors du depot cites par leur seul nom en T0 ;
#    D-b  agregats de T2 sur la population du critere (J1 : bords) ;
#    D-c  agregats de T2 aussi sur les seules lignes Monte-Carlo, et
#         controle descriptif des lignes exclues ;
#    m1   n affiche pour C1b, C3, C4a, C4b (etat inchange) ;
#    audit A1, A2, A3 : grille de --combiner, chemins avec espaces, fichier
#         absent du depot ;
#    D-d  C1c contre la reference de la cellule (lissee, loi discrete) ;
#    D-e  decimales des IC suffisantes devant les seuils de lecture ;
#    D-f  libelle du scenario H0 (alternative, non l'hypothese nulle) ;
#    D-i  aide a la lecture propre a la partie P ;
#    revue : libelles en sequences \u (aucun octet non ASCII) ; nombre de
#    p absentes affiche a cote du taux ; libelle de J1 en T3.
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_affichage_regime_t8.R")

.dossier <- if (exists("DOSSIER_UNITAIRES", inherits = TRUE)) DOSSIER_UNITAIRES else {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  if (length(.f)) dirname(.f) else "tests/unitaires"
}
SCRIPT_229 <- file.path(.dossier, "..", "p_conditionnelle_regime_t8.R")
RACINE_229 <- normalizePath(file.path(.dossier, "..", ".."), winslash = "/")

# Constantes relues (valeurs fixes de la specification et libelles) ; les
# fonctions sont toutes relues.
CONST_229 <- c("SCRIPT", "R_SPEC", "RP_SPEC", "CODES_SCEN", "METHODE", "ALPHA", "THETA_EQUIV", "SEUILS", "IA",
               "B_BOOT", "B_CIBLE", "B_MAX", "GRAINE_BOOT", "GRAINE_V3B", "T_", "F_T", "F_8", "INTENSITES",
               "SCENARIOS", "LIB_SCEN", "NOTE_SCEN", "CIBLES", "STATS_P2", "TOL_H2", "REL_QR", "NIVEAU_HOLM",
               "N_EVALUABLE", "SEUIL_C3", "REG", "LIB_REG", "VARIANTES", "VARIANTES_CRIT", "JEUX", "LOI_STAT",
               "LIB_LOI", "DISCRETES", "STAT_LIGNE", "LIGNE_TOST", "STATS", "NS", "F_R", "QUEUE", "CODES_MOTIF",
               "LIB_MOTIF", "TEXTE_CRITERE_229", "PROFILS_D", "COLS_FIXES", "CHAMPS_STAT", "REPCOLS", "COLS_NUM",
               "CLASSES", "ETAT", "PRED_C5", "PRED_C5_TXT")
EXPRS_229 <- parse(SCRIPT_229, keep.source = FALSE, encoding = "UTF-8")
E <- new.env(parent = globalenv())
assign("RACINE", RACINE_229, envir = E)
for (.e in EXPRS_229) {
  if (!is.call(.e) || !identical(.e[[1]], as.name("<-")) || !is.name(.e[[2]])) next
  .rhs <- .e[[3]]
  if (as.character(.e[[2]]) %in% CONST_229 || (is.call(.rhs) && identical(.rhs[[1]], as.name("function")))) eval(.e, E)
}
# Premier argument (deparse) de chaque appel a `fun` dans le script, lu sur
# l'arbre syntaxique (et non sur un texte deparse) : assertions statiques.
args_appels <- function(fun) {
  out <- character(0)
  marche <- function(e) {
    if (is.call(e) && identical(e[[1]], as.name(fun)) && length(e) >= 2L)
      out <<- c(out, paste(deparse(e[[2]], width.cutoff = 500L), collapse = " "))
    if (is.call(e) || is.expression(e))
      for (i in seq_along(e)) if (!identical(e[[i]], quote(expr = ))) marche(e[[i]])
  }
  marche(EXPRS_229)
  out
}

## --- Lignes REP synthetiques -------------------------------------------------
# Ligne REP (champs de REPCOLS) d'une replication traitee : p de toutes les
# statistiques a 0,5 sauf `p` (liste nommee "p_V1:BP" = valeur), verdicts et
# natures de T2 (`verd` : une chaine, commune aux variantes, ou trois,
# nommees V1, V3a, V3b).
rep_ligne <- function(b, regime, verd = "", p = list(), statut = "traitee") {
  ch <- stats::setNames(rep("0", length(E$REPCOLS)), E$REPCOLS)
  ch[startsWith(E$REPCOLS, "p_")] <- "0.5"
  ch[startsWith(E$REPCOLS, "B_")] <- "999"
  ch[startsWith(E$REPCOLS, "m_")] <- "-"
  ch[c("b", "statut", "regime", "arret", "i1", "t2", "v3a", "discordances")] <-
    c(as.character(b), statut, regime, "cible", "-", "-", "-", "-")
  ch[c("a_v1", "ret_v3b", "tir_v3b", "duree")] <- c("999", "999", "999", "1")
  for (v in c("V1", "V3a", "V3b")) {
    vv <- if (length(verd) > 1L) verd[[v]] else verd
    ch[[paste0("verd_", v)]] <- if (nzchar(vv)) vv else "-"
    ch[[paste0("nat_", v)]] <- if (nzchar(vv)) strrep("m", nchar(vv)) else "-"
  }
  for (k in names(p)) ch[[k]] <- format(p[[k]], digits = 17)
  unname(ch)
}
REF0 <- matrix(rep(E$SEUILS, each = E$NS), E$NS, 2L, dimnames = list(E$STATS, E$IA))

## --- Revue finale de #229 : libelles en sequences \u --------------------------
verifier("p_conditionnelle_regime_t8.R : aucun octet non ASCII (libelles accentues en sequences \\u, #113)",
         { o <- readBin(SCRIPT_229, "raw", file.size(SCRIPT_229)); !any(as.integer(o) > 127L) })
verifier("libelles du pre-vol et des diagnostics (i1), (h1) : chaines marquees UTF-8",
         { feuilles <- function(e) if (is.character(e)) e else if (is.call(e) || is.expression(e)) unlist(lapply(as.list(e), feuilles)) else character(0)
           s <- feuilles(EXPRS_229)
           s <- s[grepl("^(## Pr|r.plication %d : %d contexte|\\(i1\\) %s : p de #221|\\(1\\) quasi)", s)]
           length(s) == 4L && all(Encoding(s) == "UTF-8") })

## --- D-a : chemins hors du depot ----------------------------------------------
HD <- " (hors du d\u00e9p\u00f4t)"
MD5A <- strrep("a", 32)
.tmp <- tempfile("journal_", fileext = ".md"); writeLines("x", .tmp)
verifier("D-a chemin_affiche() : fichier hors du depot cite par son seul nom, sans le dossier temporaire",
         { a <- E$chemin_affiche(.tmp)
           identical(a, paste0(basename(.tmp), HD)) && !grepl(dirname(.tmp), a, fixed = TRUE) })
verifier("D-a chemin_affiche() : fichier du depot cite relativement a la racine",
         identical(E$chemin_affiche(file.path(RACINE_229, "tests", "p_conditionnelle_regime_t8.R")),
                   "tests/p_conditionnelle_regime_t8.R"))
verifier("D-a chemin_affiche() (audit A3) : fichier absent du depot, chemin absolu ou relatif, cite relativement (et non hors du depot)",
         identical(E$chemin_affiche(file.path(RACINE_229, "docs", "tableaux", "inexistant.tsv")), "docs/tableaux/inexistant.tsv") &&
           identical(E$chemin_affiche(file.path(RACINE_229, "dossier_absent", "x.tsv")), "dossier_absent/x.tsv"))
verifier("D-a chemin_affiche() : NA rendu tel quel ; chemin Windows avec espace hors du depot cite par son nom",
         identical(E$chemin_affiche(NA_character_), NA_character_) &&
           identical(E$chemin_affiche("C:/Users/John Doe/OneDrive/g.md"), paste0("g.md", HD)))
verifier("D-a masquer_chemins() : grille en tete de valeur, chemin avec espaces (audit A2)",
         identical(E$masquer_chemins(sprintf("C:/Users/John Doe/OneDrive/grille.md (md5 %s, suivi par git : non)", MD5A)),
                   sprintf("grille.md%s (md5 %s, suivi par git : non)", HD, MD5A)) &&
           identical(E$masquer_chemins(sprintf("/tmp/a b/grille.md (md5 %s)", MD5A)), sprintf("grille.md%s (md5 %s)", HD, MD5A)))
verifier("D-a masquer_chemins() : valeurs brutes de la grille dans les sources (tranches deja ecrites), espaces compris",
         { v <- sprintf("docs/tableaux/x.md (md5 %s, suivi par git : oui) ; valeurs brutes de la grille /tmp/s v/g-brut.tsv (md5 %s)", MD5A, MD5A)
           identical(E$masquer_chemins(v),
                     sprintf("docs/tableaux/x.md (md5 %s, suivi par git : oui) ; valeurs brutes de la grille g-brut.tsv%s (md5 %s)", MD5A, HD, MD5A)) })
verifier("D-a masquer_chemins() : grille du depot en chemin absolu citee relativement",
         identical(E$masquer_chemins(sprintf("%s/docs/tableaux/g.md (md5 %s)", RACINE_229, MD5A)), sprintf("docs/tableaux/g.md (md5 %s)", MD5A)))
verifier("D-a masquer_chemins() : autres chemins absolus (LAPACK de la plateforme) et barres de fraction inchanges",
         { v <- "BLAS : /usr/lib/libblas.so.3 ; LAPACK : /usr/lib/liblapack.so.3 (version 3.12.0) ; n01 / n10 ; [r\u00e9f/2 ; 3 r\u00e9f/2]"
           identical(E$masquer_chemins(v), v) })
verifier("D-a grille_combinaison() (audit A1) : grille hors du depot, chemin absolu garde, motif cite par son seul nom",
         { g <- E$grille_combinaison(sprintf("%s (md5 %s, suivi par git : non)", .tmp, MD5A))
           identical(g$chemin, .tmp) && identical(g$nv, sprintf("tableau de la grille %s%s non suivi par git", basename(.tmp), HD)) })
.git_ok <- nzchar(Sys.which("git")) && dir.exists(file.path(RACINE_229, ".git"))
if (.git_ok) {
  verifier("D-a grille_combinaison() : grille suivie du depot, chemin relatif rapporte a la racine, aucun motif",
           { g <- E$grille_combinaison(sprintf("docs/tableaux/20261010-issue229-grille.md (md5 %s)", MD5A))
             identical(g$chemin, file.path(RACINE_229, "docs/tableaux/20261010-issue229-grille.md")) && !length(g$nv) })
} else cat("  (git absent : test de grille_combinaison() sur un fichier suivi saute)\n")
verifier("D-a script : JOURNAL, valeurs brutes de #221, de la partie regime et de la grille cites par chemin_affiche(), jamais chemin_cite()",
         { cc <- args_appels("chemin_cite"); ca <- args_appels("chemin_affiche")
           !any(c("OPT_JOURNAL", "frb", "OPT_GRILLE_BRUT", "fb") %in% cc) && all(c("OPT_JOURNAL", "frb", "OPT_GRILLE_BRUT", "fb") %in% ca) })
verifier("D-a script : T0 (tranche, --combiner communes et par groupe) et controle (i3) passent par masquer_chemins() ; grille par grille_combinaison()",
         all(c("ctx1[[k]]", "CTX[[g]][[k]]", "nettoyer_champ(CTX[[k]])", "TXT_GRILLE") %in% args_appels("masquer_chemins")) &&
           "ctx1[[\"grille\"]]" %in% args_appels("grille_combinaison"))

## --- D-b, D-c : agregats de T2 -------------------------------------------------
# Trois lignes de T2 : AD et BP (lignes Monte-Carlo, STAT_LIGNE) et la ligne
# TOST, toujours en ECHEC ; J1 : deux replications au bord, une interieure
# (hors population du critere).
LT2 <- c(E$STAT_LIGNE[["AD"]], E$LIGNE_TOST, E$STAT_LIGNE[["BP"]])
D1 <- E$en_table(list(rep_ligne(1, "bord0", "OEO"), rep_ligne(2, "bord1", "AEO"), rep_ligne(3, "interieur", "OEA")))
T2 <- E$tableau_t2(list(J1 = E$matrices(D1)), LT2)
lig_crit <- grep("^\\| J1 \\| population du crit", T2, value = TRUE)
verifier("D-c STAT_LIGNE : une ligne distincte par statistique du catalogue (34)",
         setequal(names(E$STAT_LIGNE), E$STATS) && !anyDuplicated(E$STAT_LIGNE) && length(E$STAT_LIGNE) == 34L)
verifier("D-b agregat de T2 de J1 sur la population du critere (bords) : n = 2, et non 3",
         length(lig_crit) == 1L && grepl("\\| 2 \\|", lig_crit) && !any(grepl("^\\| J1 \\| tous \\|", T2)))
verifier("D-c agregat sur les lignes Monte-Carlo : 1/2 replication avec >= 1 A ou E, aucune en E (sature a 1 avec TOST)",
         { ch <- strsplit(sub(" \\|$", "", sub("^\\| ", "", lig_crit)), " | ", fixed = TRUE)[[1]]
           identical(ch[4:7], rep("1,0000 / 1,0000", 4)) && identical(ch[8:11], rep("0,5000 / 0,0000", 4)) })
verifier("D-c en-tete : colonnes des lignes Monte-Carlo annoncees (2 lignes, 1 exclue)",
         any(grepl("lignes Monte-Carlo :", T2, fixed = TRUE)) && any(grepl("les 2 lignes Monte-Carlo seules", T2, fixed = TRUE)))
verifier("D-c controle descriptif : lignes exclues de meme verdict sous les quatre variantes, aucune exception",
         any(grepl("^Contr\u00f4le descriptif : sur 3 r\u00e9plication\\(s\\) trait\u00e9e\\(s\\), les 1 lignes hors Monte-Carlo .* exceptions : aucune\\.$", T2)))
verifier("D-c controle descriptif : exception listee (verdict TOST different sous V3b)",
         { D1x <- E$en_table(list(rep_ligne(1, "bord0", c(V1 = "OEO", V3a = "OEO", V3b = "OAO"))))
           t2x <- E$tableau_t2(list(J1 = E$matrices(D1x)), LT2)
           any(grepl(sprintf("exceptions : J1 r\u00e9plication 1, %s (V1 E, V3a E, V3b A, V3h E).", E$LIGNE_TOST), t2x, fixed = TRUE)) })
verifier("D-b regime interieur de J1 rapporte a part (descriptif)",
         any(grepl("^\\| J1 \\| \u03b4\u0302\\* int\u00e9rieur \\| 1 \\|", T2)))

## --- D-d : C1c contre la reference de la cellule ; m1 : n affiche ---------------
# J2, 200 replications interieures : V1 rejette a 0,10 (p = 0,07, pas a
# 0,05) sur les 30 premieres pour SpearTps (loi discrete, reference lissee
# posee a 0,01), MK (loi discrete, reference laissee a 0,10) et BP
# (continue, reference alpha) ; V3a et V3b ne rejettent jamais. Borne haute
# de l'IC des variantes : 0,0183 (0 sur 200), inferieure a 0,10,
# superieure a 0,01.
p30 <- function(s) { x <- list(0.07); names(x) <- paste0("p_V1:", s); x }
D2 <- E$en_table(lapply(1:200, function(b) rep_ligne(b, "interieur", p = if (b <= 30) c(p30("SpearTps"), p30("MK"), p30("BP")) else list())))
REF_D <- REF0; REF_D["SpearTps", "a10"] <- 0.01
COND <- E$conditions_regime(list(J2 = E$matrices(D2)), REF_D)
c1c <- function(v) COND$detail[COND$cond == "C1c (descriptif)" & COND$variante == v]
verifier("D-d C1c : BP et MK signales, SpearTps (borne haute 0,018 > reference lissee 0,01) non signale",
         grepl("J2 BP 0,10 (0/30)", c1c("V3b"), fixed = TRUE) && grepl("J2 MK 0,10 (0/30)", c1c("V3b"), fixed = TRUE) &&
           !grepl("SpearTps", c1c("V3b"), fixed = TRUE) && !grepl("0,05 (", c1c("V3b"), fixed = TRUE))
verifier("D-d C1c : detail qui dit s'ecarter du par. 2.2 (reference de la cellule, et non alpha ; C1b a alpha, L9)",
         grepl("r\u00e9f. de la cellule, liss\u00e9e de #166 pour une loi discr\u00e8te \u2020, et non \u03b1 du par. 2.2 : #242 D-d ; C1b \u00e0 \u03b1, L9",
               c1c("V3b"), fixed = TRUE))
verifier("D-d C1c : cellule discrete de V3a marquee descriptive (L13), pas celle de V3b ni la cellule continue",
         grepl("J2 MK 0,10 (0/30) [descriptive, L13]", c1c("V3a"), fixed = TRUE) && !grepl("BP 0,10 (0/30) [descriptive", c1c("V3a"), fixed = TRUE) &&
           !grepl("descriptive, L13", c1c("V3b"), fixed = TRUE))
verifier("D-d C1b inchangee : toujours au seuil alpha (L9), aucune aggravation liberale ici",
         identical(COND$etat[COND$cond == "C1b" & COND$variante == "V3b"], E$ETAT[["ok"]]))
verifier("m1 C1b : n de la population affiche, sans mention n < 100 a n = 200",
         grepl("; n : J2 200", COND$detail[COND$cond == "C1b" & COND$variante == "V3b"], fixed = TRUE) &&
           !grepl("n < 100", COND$detail[COND$cond == "C1b" & COND$variante == "V3b"], fixed = TRUE))
D4 <- E$en_table(lapply(1:4, function(b) rep_ligne(b, "bord0")))
COND4 <- E$conditions_regime(list(J2 = E$matrices(D4)), REF0)
C44 <- E$conditions_c4(list(H0 = E$matrices(D4)))
verifier("m1 C1b et C3 : mention n < 100 a n = 4, etat inchange (remplie, pas non evaluable)",
         grepl("n : J2 4 (n < 100)", COND4$detail[COND4$cond == "C1b" & COND4$variante == "V3b"], fixed = TRUE) &&
           grepl("sur n = 4 (n < 100)", COND4$detail[COND4$cond == "C3" & COND4$variante == "V3b"], fixed = TRUE) &&
           identical(COND4$etat[COND4$cond %in% c("C1b", "C3") & COND4$variante == "V3b"], rep(E$ETAT[["ok"]], 2)))
verifier("m1 C4a et C4b : n affiche avec la mention n < 100 (C4b : replications a delta* interieur)",
         grepl("n : H0 4 (n < 100)", C44$detail[C44$cond == "C4a" & C44$variante == "V3b"], fixed = TRUE) &&
           grepl("int\u00e9rieur : H0 0 (n < 100)", C44$detail[C44$cond == "C4b" & C44$variante == "V3b"], fixed = TRUE) &&
           identical(C44$etat[C44$cond == "C4a" & C44$variante == "V3b"], E$ETAT[["ok"]]))

## --- D-e : decimales des IC ----------------------------------------------------
# J3, BP a 0,05 sous V3h : 120 rejets sur 2 000, borne basse 0,049993 < 0,05
# (constat d'actuary au point d'arret A3) ; a 4 decimales, [0,0500 ; ...].
lec <- E$lecture(120, 2000, 0.05)
verifier("D-e IC de 120/2000 contre 0,05 : borne basse affichee 0,04999 (et non 0,0500), taux au meme nombre de decimales",
         lec$d == 5L && identical(E$txt_lec(lec), "0,06000 [0,04999 ; 0,07132]"))
verifier("D-e IC sans ambiguite : 4 decimales",
         { l2 <- E$lecture(225, 2000, 0.10); l2$d == 4L && identical(E$txt_lec(l2), "0,1125 [0,0990 ; 0,1272]") })
verifier("D-e taux compris dans le choix des decimales : 75/3001 = 0,024992 affiche 0,02499 (et non 0,0250) face a ref/2 = 0,025",
         { l3 <- E$lecture(75, 3001, 0.05); l3$d == 5L && startsWith(E$txt_lec(l3), "0,02499 [") })
verifier("D-e decimales_ic() : bornes de la bande de Bradley prises en compte, plafond de 10",
         E$decimales_ic(c(0.0749996, 0.2), c(0.05, 0.025, 0.075)) == 7L && E$decimales_ic(c(0.05, 0.1), 0.05) == 4L &&
           E$decimales_ic(c(NA, 0.1), 0.05) == 4L)

## --- Revue : p absentes ----------------------------------------------------------
D3 <- E$en_table(lapply(1:4, function(b) rep_ligne(b, "bord0", p = if (b <= 2) list("p_V3a:AD" = NA_real_) else list("p_V3a:AD" = 0.01))))
MX3 <- E$matrices(D3)
c3 <- E$cellule(MX3, rep(TRUE, 4), "AD", "V3a", "a10", REF0)
verifier("revue cellule() : p absentes comptees a part (2 sur 4), toujours non-rejets (k = 2)",
         c3$na == 2L && c3$k == 2L && c3$n == 4L)
verifier("revue txt_lec() : nombre de p absentes affiche a cote du taux, rien s'il est nul",
         grepl("; 2 p absentes (non-rejet)", E$txt_lec(c3), fixed = TRUE) &&
           !grepl("absente", E$txt_lec(E$cellule(MX3, rep(TRUE, 4), "AD", "V1", "a10", REF0)), fixed = TRUE))
verifier("revue tableau_t1() : p absentes de V3a affichees dans la ligne de AD",
         { t1 <- E$tableau_t1(list(J2 = MX3), REF0)
           any(grepl("^\\| J2 \\| AD \\(haut\\) \\|.*\\| V3a \\|.*2 p absentes", t1)) })

## --- D-f : scenario H0 ------------------------------------------------------------
verifier("D-f lib_pop(H0) : alternative ou Var(Y) est constante, hors famille reglementaire, pas l'hypothese nulle ; autres libelles inchanges",
         identical(E$lib_pop("H0"), paste("H0 (H, k = 0 : alternative o\u00f9 Var(Y) est constante (k = 0, hors de la famille r\u00e9glementaire",
                                          "k \u2208 [1 ; 2]) ; pas l'hypoth\u00e8se nulle)")) &&
           identical(E$lib_pop(c("H3", "J1", "J2")), c("H3 (H, k = 3)", "J1 (bords)", "J2")))
verifier("D-f code H0 inchange (noms de fichiers, PARAMETRES)", "H0" %in% E$CODES_SCEN)

## --- D-i : aide a la lecture --------------------------------------------------------
ar <- tryCatch(E$aide_lecture("regime"), error = function(e) NULL)
ap <- tryCatch(E$aide_lecture("puissance"), error = function(e) NULL)
verifier("D-i aide_lecture(partie) : une aide par partie",
         is.character(ar) && is.character(ap) && !identical(ar, ap))
verifier("D-i aide de la partie P differente de celle de la partie regime (puissance, pas de C5)",
         is.character(ap) && is.character(ar) && any(grepl("^Puissance : ", ap)) && !any(grepl("C5 se lit", ap, fixed = TRUE)) &&
           any(grepl("C5 se lit", ar, fixed = TRUE)) && !any(grepl("^Puissance : ", ar)))
verifier("D-i aide de la partie P : structure de variance, scenario H0 precise, C4a et C4b decrits, critere reporte",
         is.character(ap) && any(grepl("structure de variance Var(Y)", ap, fixed = TRUE)) &&
           any(grepl("le sc\u00e9nario H0 est", ap, fixed = TRUE)) && any(grepl("C4a : ", ap, fixed = TRUE)) &&
           any(grepl("C4b : ", ap, fixed = TRUE)) && all(paste(">", E$TEXTE_CRITERE_229) %in% ap))
verifier("D-i decimales : phrase propre a chaque partie (P : 4 decimales, 3 en C4c, aucun seuil de lecture)",
         is.character(ap) && is.character(ar) && any(grepl("4 d\u00e9cimales, 3 en C4c ; aucun seuil de lecture", ap, fixed = TRUE)) &&
           !any(grepl("davantage quand l'arrondi", ap, fixed = TRUE)) && any(grepl("davantage quand l'arrondi", ar, fixed = TRUE)))
verifier("D-i --combiner : aide_lecture() appelee avec la partie (OPT_PARTIE)",
         "OPT_PARTIE" %in% args_appels("aide_lecture"))
verifier("D-i C4c : p absentes affichees (forme courte)",
         { D5 <- E$en_table(lapply(1:4, function(b) rep_ligne(b, "bord0", p = if (b <= 2) list("p_V3a:BP" = NA_real_) else list())))
           tp <- E$tableaux_puissance(list(H0 = D5), NULL, REF0)
           i <- grep("^### C4c", tp)
           length(i) == 1L && any(grepl("^\\| H0 .*\\| BP \\|.*\\(2 p abs\\.\\)", tp[i:length(tp)])) })

## --- Revue : libelle de J1 en T3 ---------------------------------------------------
verifier("T3 : ligne du regime interieur de J1 sans la mention (bords)",
         { t3 <- E$tableau_t3(list(J1 = D1), list(J1 = E$matrices(D1)), list())
           any(grepl("^\\| J1 \\| \u03b4\u0302\\* int\u00e9rieur \\|", t3)) && !any(grepl("^\\| J1 \\(bords\\) \\|", t3)) })

unlink(.tmp)
fin_fichier()
