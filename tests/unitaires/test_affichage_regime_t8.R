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
#  #274 (revue finale de Ff) : NOTE_C5 relue (lue par conditions_regime()
#  et tableau_l15()) ; classes fermees de (t2) (classe_t2(), t2_classer())
#  et critere ECHEC (indic_echec(), transitions_echec()) sur des lignes et
#  des replications synthetiques.
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
               "CLASSES", "ETAT", "PRED_C5", "PRED_C5_TXT", "NOTE_C5", "LIGNES_HORS_ECHEC", "MARQUEUR_R14",
               "CLASSES_T2", "LIGNE_PITMAN", "PREFIXE_MC_INDISPO")
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
verifier("D-a masquer_chemins() (revue) : toutes les occurrences masquees, chemins avec espace compris",
         identical(E$masquer_chemins("/c d/e.md (md5 2) ; /f/g.md (md5 3)"), sprintf("e.md%s (md5 2) ; g.md%s (md5 3)", HD, HD)))
verifier("D-a masquer_chemins() (revue) : le chemin de tete s'arrete au separateur ; (aucun bloc avale)",
         identical(E$masquer_chemins("/usr/lib/x.so ; autre /tmp/y (md5 abc)"), sprintf("/usr/lib/x.so ; autre y%s (md5 abc)", HD)))
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
verifier("D-c LIGNE_TOST nommee dans le texte de T2 si elle est parmi les lignes exclues, pas sinon (revue)",
         any(grepl(sprintf("dont la ligne \u00ab %s \u00bb qui sature J1", E$LIGNE_TOST), T2, fixed = TRUE)) &&
           { LT2b <- c(E$STAT_LIGNE[["AD"]], "Autre ligne", E$STAT_LIGNE[["BP"]])
             !any(grepl("sature J1", E$tableau_t2(list(J1 = E$matrices(D1)), LT2b), fixed = TRUE)) })
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
verifier("m1 txt_n() : seuil lu dans N_EVALUABLE (revue), et non ecrit en dur",
         { e2 <- new.env(parent = E); e2$N_EVALUABLE <- 50L; f <- E$txt_n; environment(f) <- e2
           identical(f("J2", 40L), "J2 40 (n < 50)") && identical(f("J2", 60L), "J2 60") && identical(E$txt_n("J2", 99L), "J2 99 (n < 100)") })
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

## --- #274 : classes fermees de (t2), classe_t2() -----------------------------
# Ligne de usp_tests() synthetique : test ordinaire a p Monte-Carlo, champs
# remplaces par ceux de `...`.
ligne_t <- function(...) {
  d <- list(test = "Ligne X", type = "test", verdict = "OK", p_retenue = 0.3, p_exacte = NA_real_, p_min = NA_real_,
            p_min_mc = NA_real_, inoperant = FALSE, detail = "")
  m <- list(...); d[names(m)] <- m; d
}
A <- E$ALPHA
diag_na <- function(...) ligne_t(type = "diagnostic", verdict = "INFO", p_retenue = NA_real_, ...)
verifier("#274 classe_t2() T : ligne TOST en diagnostic INFO, p NA, detail portant MARQUEUR_R14 ; sans le marqueur, '-'",
         identical(E$classe_t2(diag_na(test = E$LIGNE_TOST, detail = paste("x", E$MARQUEUR_R14))), "T") &&
           identical(E$classe_t2(diag_na(test = E$LIGNE_TOST, detail = "autre motif")), "-") &&
           identical(E$classe_t2(diag_na(test = "Ligne X", detail = E$MARQUEUR_R14)), "-"))
verifier("#274 classe_t2() M : verdict INFO, p NA, detail prefixe 'Monte-Carlo indisponible : ' ; verdict OK ou p finie ou prefixe ailleurs, '-'",
         identical(E$classe_t2(diag_na(detail = paste0(E$PREFIXE_MC_INDISPO, "motif"))), "M") &&
           identical(E$classe_t2(diag_na(verdict = "OK", detail = paste0(E$PREFIXE_MC_INDISPO, "motif"))), "-") &&
           identical(E$classe_t2(ligne_t(verdict = "INFO", detail = paste0(E$PREFIXE_MC_INDISPO, "motif"))), "-") &&
           identical(E$classe_t2(diag_na(detail = paste0("x ", E$PREFIXE_MC_INDISPO))), "-"))
verifier("#274 classe_t2() b : inoperant, p NA, p_min_mc >= alpha, seulement si p_min < alpha (ou non finie)",
         identical(E$classe_t2(diag_na(inoperant = TRUE, p_min = A / 2, p_min_mc = A + 0.02)), "b") &&
           identical(E$classe_t2(diag_na(inoperant = TRUE, p_min = NA_real_, p_min_mc = A + 0.02)), "b") &&
           identical(E$classe_t2(diag_na(inoperant = TRUE, p_min = A + 0.1, p_min_mc = A + 0.02)), "-") &&
           identical(E$classe_t2(diag_na(inoperant = TRUE, p_min = A / 2, p_min_mc = A / 2)), "-"))
verifier("#274 classe_t2() h : test, p finie, p_min >= alpha > p_min_mc, seulement sans p exacte finie",
         identical(E$classe_t2(ligne_t(p_min = A + 0.02, p_min_mc = A / 2)), "h") &&
           identical(E$classe_t2(ligne_t(p_min = A + 0.02, p_min_mc = A / 2, p_exacte = 0.3)), "-") &&
           identical(E$classe_t2(ligne_t(p_min = A / 2, p_min_mc = A / 2)), "-") &&
           identical(E$classe_t2(ligne_t(p_min = A + 0.02, p_min_mc = A / 2, inoperant = NA)), "-"))
verifier("#274 classe_t2() P : ligne de Pitman de type test, seulement si la p retenue est identique a la p exacte",
         identical(E$classe_t2(ligne_t(test = E$LIGNE_PITMAN, p_retenue = 0.2, p_exacte = 0.2)), "P") &&
           identical(E$classe_t2(ligne_t(test = E$LIGNE_PITMAN, p_retenue = 0.2, p_exacte = NA_real_)), "-") &&
           identical(E$classe_t2(ligne_t(test = E$LIGNE_PITMAN, p_retenue = 0.2, p_exacte = 0.2 + 1e-12)), "-") &&
           identical(E$classe_t2(ligne_t(test = "Ligne X", p_retenue = 0.2, p_exacte = 0.2)), "-"))

## --- #274 : t2_classer() -------------------------------------------------------
# LIGNES_T2 (calculee par le script a partir de run_engine()) posee ici :
# pente de Pitman, ligne de BP, autre ligne.
assign("LIGNES_T2", c(E$LIGNE_PITMAN, E$STAT_LIGNE[["BP"]], "Autre ligne"), envir = E)
t2c <- function(pr, p, cl, r4 = FALSE, expl = character(0)) E$t2_classer(pr, list(p = p, cl = cl), expl, r4)
verifier("#274 t2_classer() P : nouvelle p finie de la pente (ancienne NA) admise seulement si R4 recalculee est vraie",
         { a <- t2c(c(NA, 0.2, 0.3), c(0.04, 0.2, 0.3), c("P", "-", "-"), r4 = TRUE)
           b <- t2c(c(NA, 0.2, 0.3), c(0.04, 0.2, 0.3), c("P", "-", "-"), r4 = FALSE)
           identical(a$dl, 1L) && identical(a$cause, "P") && isTRUE(a$complet_p) &&
             identical(b$dl, 1L) && identical(b$cause, NA_character_) && isTRUE(b$complet_p) })
verifier("#274 t2_classer() completude de P : R4 vraie sans discordance de classe P sur la pente -> complet_p FALSE",
         { a <- t2c(c(NA, 0.2, 0.3), c(NA, 0.2, 0.3), c("-", "-", "-"), r4 = TRUE)
           b <- t2c(c(0.1, 0.2, 0.3), c(0.1, NA, 0.3), c("-", "M", "-"), r4 = TRUE)
           !length(a$dl) && identical(a$complet_p, FALSE) && identical(b$cause, "M") && identical(b$complet_p, FALSE) })
verifier("#274 t2_classer() M et T : admises seulement de l'ancienne p finie a la nouvelle NA",
         identical(t2c(c(0.1, 0.2, 0.3), c(0.1, NA, 0.3), c("-", "M", "-"))$cause, "M") &&
           identical(t2c(c(0.1, NA, 0.3), c(0.1, 0.25, 0.3), c("-", "M", "-"))$cause, NA_character_) &&
           identical(t2c(c(0.1, 0.2, 0.3), c(0.1, 0.25, 0.3), c("-", "M", "-"))$cause, NA_character_) &&
           identical(t2c(c(0.1, 0.2, 0.3), c(0.1, 0.2, NA), c("-", "-", "T"))$cause, "T") &&
           identical(t2c(c(0.1, 0.2, NA), c(0.1, 0.2, 0.3), c("-", "-", "T"))$cause, NA_character_))
verifier("#274 t2_classer() R : b de finie a NA, h de NA a finie, jamais l'inverse",
         identical(t2c(c(0.1, 0.2, 0.3), c(0.1, NA, 0.3), c("-", "b", "-"))$cause, "R") &&
           identical(t2c(c(0.1, NA, 0.3), c(0.1, 0.25, 0.3), c("-", "h", "-"))$cause, "R") &&
           identical(t2c(c(0.1, NA, 0.3), c(0.1, 0.25, 0.3), c("-", "b", "-"))$cause, NA_character_) &&
           identical(t2c(c(0.1, 0.2, 0.3), c(0.1, NA, 0.3), c("-", "h", "-"))$cause, NA_character_))
verifier("#274 t2_classer() i1 : discordance de la ligne d'une statistique expliquee par (i1), prioritaire ; egalite au bit pres",
         identical(t2c(c(0.1, 0.2, 0.3), c(0.1, 0.25, 0.3), c("-", "-", "-"), expl = "BP")$cause, "i1") &&
           identical(t2c(c(0.1, 0.2, 0.3), c(0.1, 0.25, 0.3), c("-", "-", "-"), expl = "AD")$cause, NA_character_) &&
           identical(t2c(c(0.1, 0.2, 0.3), c(0.1, 0.2 + 1e-15, 0.3), c("-", "-", "-"))$dl, 2L))

## --- #274 : indic_echec() et transitions_echec() --------------------------------
# Lignes de T2 : les quatre lignes hors du critere ECHEC (TOST, Pitman,
# Fisher, ESD), la ligne de BP (p_V1:BP, p_V3b:BP), une ligne sans
# statistique du catalogue. Comparaison (REF) -> presente mesure (DN), J2 :
#   b = 1 (bord1) : ligne 6 E -> I, diag M sous V1 et V3b -> admis (V1, V3h) ;
#   b = 2 (interieur) : ligne 6 E -> I sous V3b seule, diag R -> defaut (V3h) ;
#   b = 3 (bord1) : BP E -> O, diag "." -> non explique (V1, V3h ; p 0,03 -> 0,2) ;
#   b = 4 (bord0) : BP O -> E (hausse, descriptive) ; TOST E -> O (hors critere) ;
#   b = 5 : ecartee (hors population) dans REF.
LE <- c(E$LIGNES_HORS_ECHEC, E$STAT_LIGNE[["BP"]], "Autre ligne")
dfe <- function(b, statut, regime, v1, v3b, d1 = NULL, d3b = NULL, p1 = NULL, p3b = NULL) {
  d <- data.frame(b = b, statut = statut, regime = regime, verd_V1 = v1, verd_V3b = v3b, stringsAsFactors = FALSE)
  if (!is.null(d1)) { d$diag_V1 <- d1; d$diag_V3b <- d3b }
  if (!is.null(p1)) { d[["p_V1:BP"]] <- p1; d[["p_V3b:BP"]] <- p3b }
  d
}
DR <- dfe(1:5, c(rep("traitee", 4), "ecartee"), c("bord1", "interieur", "bord1", "bord0", "-"),
          c("OOOOOE", "OOOOOO", "OOOOEO", "EOOOOO", "OOOOEE"), c("OOOOOE", "OOOOOE", "OOOOEO", "EOOOOO", "OOOOEE"),
          p1 = c(0.5, 0.5, 0.03, 0.5, 0.5), p3b = c(0.5, 0.5, 0.03, 0.5, 0.5))
DNE <- dfe(1:4, "traitee", c("bord1", "interieur", "bord1", "bord0"),
           c("OOOOOI", "OOOOOO", "OOOOOO", "OOOOEO"), c("OOOOOI", "OOOOOI", "OOOOOO", "OOOOEO"),
           d1 = c(".....M", "......", "......", "......"), d3b = c(".....M", ".....R", "......", "......"),
           p1 = c(0.5, 0.5, 0.2, 0.04), p3b = c(0.5, 0.5, 0.2, 0.04))
REFE <- list(lignes = LE, D = list(J2 = DR))
verifier("#274 indic_echec() : deux populations de lignes (hors TOST/Pitman/Fisher/ESD : 2 ; toutes : 6), V3h = V3b a l'interieur",
         { ie <- E$indic_echec(DR, LE)
           identical(ie$hors$b, 1:4) && identical(ie$hors$n_lignes, 2L) && identical(ie$toutes$n_lignes, 6L) &&
             identical(ie$hors$V1, c(TRUE, FALSE, TRUE, FALSE)) && identical(ie$hors$V3h, c(TRUE, TRUE, TRUE, FALSE)) &&
             identical(ie$toutes$V1, c(TRUE, FALSE, TRUE, TRUE)) && identical(ie$toutes$V3h, c(TRUE, TRUE, TRUE, TRUE)) })
verifier("#274 indic_echec() : refus si une ligne exclue manque, si un libelle est duplique ou si la longueur des verdicts differe",
         inherits(tryCatch(E$indic_echec(DR, LE[-1]), error = identity), "error") &&
           grepl("dupliques", conditionMessage(tryCatch(E$indic_echec(DR, c(LE[-6], LE[5])), error = identity)), fixed = TRUE) &&
           inherits(tryCatch(E$indic_echec(DR, c(LE, "Ligne 7")), error = identity), "error"))
TRE <- E$transitions_echec(list(J2 = DNE), LE, REFE)
cpt_tr <- function(v) unlist(TRE$tab[TRE$tab$variante == v, c("n", "baisse", "admis", "defaut", "autre", "hausse")])
verifier("#274 transitions_echec() : comptes V1 (n 4 ; ECHEC -> non-ECHEC 2 ; admis 1 ; defaut 0 ; non explique 1 ; hausse 1)",
         identical(unname(cpt_tr("V1")), c(4L, 2L, 1L, 0L, 1L, 1L)))
verifier("#274 transitions_echec() : comptes V3h, V3b au regime interieur (ECHEC -> non-ECHEC 3 ; admis 1 ; defaut R 1 ; non explique 1 ; hausse 1)",
         identical(unname(cpt_tr("V3h")), c(4L, 3L, 1L, 1L, 1L, 1L)))
verifier("#274 transitions_echec() : passages non admis listes (p de la statistique lue, DEFAUT pour le code R), bilan bloquant",
         length(TRE$lst) == 3L && TRE$n_lignes == 2L && isTRUE(TRE$bloquant) &&
           any(grepl("J2 b = 3, V1, .* : p ancienne 0.03, nouvelle 0.2, nouveau verdict O, code \\.$", TRE$lst)) &&
           any(grepl("J2 b = 2, V3h, Autre ligne : p ancienne -, nouvelle -, nouveau verdict I, code R (DEFAUT", TRE$lst, fixed = TRUE)) &&
           startsWith(TRE$bilan, "TRANSITIONS NON EXPLIQUEES (3 passage(s) non admis ; 0 ligne(s)"))
verifier("#274 transitions_echec() : tout passage admis (diagnostic Monte-Carlo indisponible) -> bilan OK, non bloquant",
         { t <- E$transitions_echec(list(J2 = DNE[1, ]), LE, list(lignes = LE, D = list(J2 = DR[1, ])))
           identical(t$bloquant, FALSE) && startsWith(t$bilan, "OK (") && !length(t$lst) &&
             identical(t$tab$variante, c("V1", "V3h")) && all(t$tab$baisse == 1L & t$tab$admis == 1L) })
verifier("#274 transitions_echec() : colonnes diag absentes -> NON EVALUABLE, bloquant ; ligne absente de la comparaison -> bloquant",
         { t1 <- E$transitions_echec(list(J2 = DNE[, setdiff(names(DNE), c("diag_V1", "diag_V3b"))]), LE, REFE)
           # jeu ou tout passage evalue est admis (n_ko = 0) : seul manq rend le bilan bloquant
           t2 <- E$transitions_echec(list(J2 = DNE[1, ]), LE, list(lignes = LE[-6], D = list(J2 = DR[1, ])))
           isTRUE(t1$bloquant) && startsWith(t1$bilan, "NON EVALUABLE (colonnes diag absentes : J2)") &&
             isTRUE(t2$bloquant) && identical(t2$manq, "Autre ligne") &&
             grepl("1 ligne(s) absente(s) de la comparaison", t2$bilan, fixed = TRUE) })

unlink(.tmp)
fin_fichier()
