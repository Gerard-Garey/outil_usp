###############################################################################
#  tests/unitaires/test_rapport_html.R  --  RAPPORT FIGE (issue #53)
#
#  rapport_html(), encoder_base64(), texte_formule() (R/display_helpers.R) et
#  engine_empreinte() (R/engine.R).
#  Proprietes verifiees : document HTML autonome (DOCTYPE, UTF-8, aucune
#  ressource externe), tests retenus dans la section principale et tests
#  exclus en annexe avec leur verdict, empreintes presentes, stables et
#  sensibles aux donnees, formule propre a chaque methode, etat global
#  (.Random.seed, options) inchange ; graphiques d'influence et note sans
#  erreur ni "NA" quand les distances de Cook sont non finies (issue #153) ;
#  profil et reperes du LR sur delta a NA restitues sans erreur (issue #161) ;
#  niveau des bandes du QQ-plot lu dans plots_data$qq_enveloppe, repere
#  asymptotique du profil de delta hors de la legende et dans le cadre,
#  legende et libelle du repere hors de la ligne en delta estime, libelle
#  contraste (issue #162) ; vue Detail : commentaire du moteur long replie
#  sans texte retire, colonne Fonction (champ fonction, #111), commentaire du
#  moteur dans l'annexe des tests exclus, texte entier dans le rapport fige
#  (issue #178) ; ligne "P-values Monte-Carlo" de l'en-tete
#  (texte_p_mc_regime(), issue #240, Q-A4-12 (B)) : V3b arret a la cible et a
#  B_max, V1 au bord et a volumes constants, objet sans p_mc_regime, reserve2 ;
#  graine du flux (metadata$seed_flux_regime) dans valeurs_generateur() et
#  l'en-tete, absente en reserve2 ; rapport sur les six references nettoyees
#  (sans horodatage, duree_sec ni version_R), tiret dans ces lignes (#263) ;
#  mention de la granularite effective en V3b arrete a B_max seulement
#  (#254), qui renvoie a la colonne "granularite MC" du detail des tests ;
#  colonne "granularite MC" lue dans bootstrap$granularite_stat, comparee a
#  la statistique Monte-Carlo de chaque ligne relevee dans add() (#285) ;
#  p-values sous 1e-4 en trois chiffres significatifs, jamais "0,0000"
#  pour une p-value non nulle, p = 0 rendu "0,0000", frontiere de 1e-4 sans
#  saut (fmt_p(), #323) ; tiret pour une marge theta_equiv ou delta_equiv absente ;
#  virgule decimale des nombres affiches (.num_fr(), fmt_*(), notes, rapport
#  fige ; issue #236).
#  References : RFC 4648, section 10 (vecteurs de test base64) ; regle de
#  selection de l'onglet Tests (filtrer_selection).
#  La branche PNG est exercee partout ou capabilities("png") est vrai ; la
#  branche plotly seulement si le paquet est installe (pas en CI, decision du
#  mainteneur, issue #53).
###############################################################################

if (!exists("verifier", mode = "function")) {
  .f <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  source(file.path(if (length(.f)) dirname(.f) else "tests/unitaires", "outils_unitaires.R"))
}
debut_fichier("test_rapport_html.R")

.racine <- if (exists("RACINE", inherits = TRUE)) RACINE else
           if (file.exists("R/engine.R")) "." else if (file.exists("../R/engine.R")) ".." else "../.."
source(file.path(.racine, "R", "display_helpers.R"), local = TRUE)

lire <- function(f) { t <- rawToChar(readBin(f, "raw", file.info(f)$size)); Encoding(t) <- "UTF-8"; t }
# Les motifs non ASCII sont ecrits en echappements \uXXXX (chaines marquees
# UTF-8), comme les libelles de display_helpers.R : un litteral accentue est
# lu dans l'encodage natif et, sous LC_CTYPE=POSIX, grepl() echoue
# ("regular expression is invalid UTF-8").
compte <- function(txt, motif) lengths(regmatches(txt, gregexpr(motif, txt, fixed = TRUE)))
# Extrait de txt, de la premiere occurrence de debut a la premiere occurrence
# de fin qui la suit.
entre <- function(txt, debut, fin) {
  i <- regexpr(debut, txt, fixed = TRUE)
  if (i < 0) return("")
  reste <- substr(txt, i, nchar(txt))
  j <- regexpr(fin, reste, fixed = TRUE)
  if (j < 0) return("")
  substr(reste, 1, j + nchar(fin) - 1)
}
# Ligne <tr> de la table qui porte le test `nom` (repere par son balisage).
ligne_de <- function(section, nom) {
  lignes <- regmatches(section, gregexpr("<tr>.*?</tr>", section, perl = TRUE))[[1]]
  lignes[grepl(paste0(">", .echap_html(nom), "</span>"), lignes, fixed = TRUE)]
}

xt <- c(104.20, 102.25, 109.34, 114.64, 118.41, 121.28, 132.40, 131.22)
yt <- c(68.97, 76.76, 83.49, 95.38, 88.96, 70.22, 78.89, 117.37)
tri <- unname(as.matrix(utils::read.csv(file.path(.racine, "tests", "donnees",
                                                  "triangle_mw.csv"))[, -1]))
res_ln <- run_engine(xt = xt, yt = yt, methode = "premium", segment = 1, B = 99,
                     nature_donnees = "brutes")
res_mw <- run_engine(methode = "reserve2", triangle = tri, segment = 1, B = 99)
idt <- identite_code(.racine)
png_ok <- isTRUE(capabilities("png"))
if (!png_ok) cat("  note : capabilities(\"png\") vaut FALSE ; la branche sans graphique est exercee a la place des PNG.\n")

## --- Encodage base64 (RFC 4648, section 10) -----------------------------------
verifier("base64 : 'Man' -> 'TWFu' (exemple canonique)",
         identical(encoder_base64(charToRaw("Man")), "TWFu"))
verifier("base64 : vecteurs de la RFC 4648 (f, fo, foo, foob, fooba, foobar, vide)",
         identical(vapply(c("f", "fo", "foo", "foob", "fooba", "foobar"),
                          function(s) encoder_base64(charToRaw(s)), character(1), USE.NAMES = FALSE),
                   c("Zg==", "Zm8=", "Zm9v", "Zm9vYg==", "Zm9vYmE=", "Zm9vYmFy")) &&
         identical(encoder_base64(raw(0)), ""))
verifier("base64 : octets extremes 00 et FF",
         identical(encoder_base64(as.raw(c(0, 0, 0))), "AAAA") &&
         identical(encoder_base64(as.raw(c(255, 255, 255))), "////"))

## --- Empreintes (engine_empreinte) --------------------------------------------
e1 <- engine_empreinte(res_ln); e2 <- engine_empreinte(res_ln)
verifier("Empreintes : md5 de 32 caracteres hexadecimaux, donnees et resultat",
         all(grepl("^[0-9a-f]{32}$", c(e1$donnees, e1$resultat))))
verifier("Empreintes : stables pour un meme res", identical(e1, e2))
x2 <- xt; x2[1] <- 104.21
e3 <- engine_empreinte(run_engine(xt = x2, yt = yt, methode = "premium", segment = 1, B = 99,
                                  nature_donnees = "brutes"))
verifier("Empreintes : changent si xt[1] change (donnees et resultat)",
         e3$donnees != e1$donnees && e3$resultat != e1$resultat)
verifier("Empreintes : stables entre deux run_engine() a graine egale (hors horodatage)",
         identical(engine_empreinte(run_engine(xt = xt, yt = yt, methode = "premium",
                                               segment = 1, B = 99,
                                               nature_donnees = "brutes"))[c("donnees", "resultat")],
                   e1[c("donnees", "resultat")]))
verifier("Empreintes : texte canonique en %.17g, recalculable",
         grepl("1;104.2;68.969999999999999", e1$texte_donnees, fixed = TRUE) && {
           f <- tempfile(); writeBin(charToRaw(e1$texte_donnees), f)
           identical(unname(as.character(tools::md5sum(f))), e1$donnees) })
verifier("Empreintes : triangle Merz-Wuthrich, cellules non observees ecrites NA",
         grepl("^triangle;8;8\n", engine_empreinte(res_mw)$texte_donnees) &&
         grepl(";NA\n", engine_empreinte(res_mw)$texte_donnees, fixed = TRUE))

res_refus <- run_engine(xt = c(1, NA, 3, 4), yt = c(1, 2, 3, 4), methode = "premium",
                        segment = 1, B = 99, nature_donnees = "brutes")
e_refus <- engine_empreinte(res_refus)
verifier("Empreintes : resultat refuse (ok = FALSE), donnees NA, empreinte md5 de l'objet refuse, stable",
         !isTRUE(res_refus$ok) && is.na(e_refus$donnees) && is.na(e_refus$texte_donnees) &&
         grepl("^[0-9a-f]{32}$", e_refus$resultat) &&
         identical(engine_empreinte(run_engine(xt = c(1, NA, 3, 4), yt = c(1, 2, 3, 4),
                                               methode = "premium", segment = 1, B = 99,
                                               nature_donnees = "brutes")),
                   e_refus))

## --- Rapport fige, branche PNG, methode lognormale ----------------------------
tb <- engine_table_tests(res_ln)
s <- selection_defaut(tb)
# Selection personnalisee, comme dans l'onglet Personnalisation : un test
# principal retire ; pour un test decline en deux bases, la ligne z_t passe
# sur la base "r" (elle est donc exclue) et la ligne "ratios bruts" est
# cochee avec la base "r" (elle est donc retenue).
i_retire <- which(tb$variante == "principale" & tb$base == "commun")[1]
s$garde[i_retire] <- FALSE
i_z <- which(tb$base == "z" & tb$variante == "principale")[1]
nom_r <- tb$test[tb$base == "r" & startsWith(tb$test, tb$test[i_z])][1]
i_r <- match(nom_r, tb$test)
s$base[c(i_z, i_r)] <- "r"
s$garde[i_r] <- TRUE
retenu <- filtrer_selection(tb, s)

f_png <- tempfile(fileext = ".html")
set.seed(11); graine0 <- .Random.seed; option0 <- getOption("usp.graphiques_base")
r_png <- rapport_html(res_ln, s, f_png, interactif = FALSE, identite = idt)
verifier("Rapport : etat global inchange (.Random.seed, option usp.graphiques_base)",
         identical(graine0, .Random.seed) && identical(option0, getOption("usp.graphiques_base")))
h <- lire(f_png)
verifier("Rapport : fichier cree, commence par <!DOCTYPE html>",
         file.exists(f_png) && identical(substr(h, 1, 15), "<!DOCTYPE html>"))
verifier("Rapport : UTF-8 declare et octets UTF-8 valides",
         grepl("<meta charset=\"utf-8\">", h, fixed = TRUE) && validUTF8(h))
verifier("Rapport PNG : aucune reference externe (src=\"http, href=\"http)",
         compte(h, "src=\"http") == 0 && compte(h, "href=\"http") == 0)
n_graphes <- sum(vapply(.graphiques_rapport(res_ln), function(o) length(o$g), integer(1))) + 1L
if (png_ok) {
  verifier("Rapport PNG : mode png, une image base64 par graphique (calibration comprise)",
           r_png$mode == "png" && compte(h, "src='data:image/png;base64,") == n_graphes)
  verifier("Rapport PNG : chaque image est un PNG (signature iVBORw0KGgo en base64)",
           compte(h, "src='data:image/png;base64,iVBORw0KGgo") == n_graphes &&
           compte(h, "Graphique indisponible") == 0)
} else {
  verifier("Rapport sans peripherique PNG : bandeau explicite, aucune image",
           r_png$mode == "aucun" && grepl("Graphiques non produits", h, fixed = TRUE) &&
           compte(h, "<img") == 0)
}
verifier("Rapport : aucun script dans la branche PNG", compte(h, "<script") == 0)

principal <- entre(h, "<section id='section-tests-retenus'>", "</section>")
annexe <- entre(h, "<section id='section-annexe-exclus'>", "</section>")
verifier("Rapport : encadre de personnalisation avec le nombre de lignes du moteur",
         grepl(sprintf("Le moteur a calcul\u00e9 %d lignes", nrow(tb)), principal, fixed = TRUE) &&
         grepl("sans effet sur le calcul", principal, fixed = TRUE))
# Legende des natures du rapport fige (#120) : la nature "approx. n fini"
# (NATURE_APPROX_N_FINI) y est nommee, dans la couleur de son badge.
verifier("Rapport : legende des natures, nature 'approx. n fini' nommee dans la couleur du badge (#120)",
         grepl("<b style='color:#6E2C00'>approx. n fini</b> (Anscombe-Glynn, T &gt;= 20)",
               principal, fixed = TRUE) &&
         grepl("color:#6E2C00", badge_nature(NATURE_APPROX_N_FINI), fixed = TRUE))
# Legende de la hierarchie (#181) : rang de la p non simulee et absence de
# repli quand la p Monte-Carlo manque.
verifier("Rapport : legende 'exacte > Monte-Carlo > p non simulee', aucun repli sur la p non simulee (#181)",
         grepl(paste("&gt; p non simul\u00e9e (<b style='color:#B9770E'>asymptotique</b> ou",
                     "<b style='color:#6E2C00'>approx. n fini</b>)."), principal, fixed = TRUE) &&
         grepl(paste("Quand la p Monte-Carlo manque, la p non simul\u00e9e n'est jamais retenue",
                     "\u00e0 sa place (ADR 0001) : sauf p exacte, la ligne ne porte aucune",
                     "p-value retenue."), principal, fixed = TRUE))
verifier("Rapport : chaque test retenu est dans la section principale, pas en annexe",
         all(vapply(tb$test[retenu], function(n) length(ligne_de(principal, n)) >= 1 &&
                      !length(ligne_de(annexe, n)), logical(1))))
verifier("Rapport : chaque test exclu est en annexe, pas dans la section principale",
         all(vapply(tb$test[!retenu], function(n) length(ligne_de(annexe, n)) == 1 &&
                      !length(ligne_de(principal, n)), logical(1))))
verifier("Rapport : annexe = une ligne par test exclu, avec son verdict et sa p retenue",
         compte(annexe, "<tr><td>") == sum(!retenu) &&
         all(vapply(which(!retenu), function(k) {
           l <- ligne_de(annexe, tb$test[k])
           grepl(badge_verdict(tb$verdict[k]), l, fixed = TRUE) &&
             grepl(paste0("<td>", fmt_p(tb$p_retenue[k]), "</td>"), l, fixed = TRUE)
         }, logical(1))))
verifier("Rapport : motifs d'exclusion (test retire ; autre base retenue)",
         grepl("test non conserv\u00e9", ligne_de(annexe, tb$test[i_retire]), fixed = TRUE) &&
         grepl("base retenue pour ce test : ratios bruts", ligne_de(annexe, tb$test[i_z]),
               fixed = TRUE) &&
         length(ligne_de(principal, nom_r)) == 2)   # synthese et detail
verifier("Rapport : empreintes des donnees, du resultat et du code presentes",
         all(vapply(c(e1$donnees, e1$resultat, idt$md5_engine),
                    function(x) grepl(x, h, fixed = TRUE), logical(1))) &&
         identical(r_png$empreintes, e1[c("donnees", "resultat")]))
verifier("Rapport : horodatage du calcul et version DESCRIPTION restitues",
         grepl(format(res_ln$metadata$horodatage, "%Y-%m-%d %H:%M:%S"), h, fixed = TRUE) &&
         grepl(paste0("<td>", idt$version, "</td>"), h, fixed = TRUE))
verifier("Rapport : donnees lues dans res (x_t et y_t du calcul), virgule decimale (#236)",
         grepl("<td>1</td><td>104,2</td><td>68,97</td>", h, fixed = TRUE) &&
         grepl("<td>7</td><td>132,4</td><td>78,89</td>", h, fixed = TRUE))
verifier("Rapport lognormal : formule avec le facteur sqrt((T+1)/(T-1))",
         grepl("sqrt((T+1)/(T-1))", texte_formule(res_ln), fixed = TRUE) &&
         grepl(.echap_html(texte_formule(res_ln)), h, fixed = TRUE))
verifier("Rapport : avertissement T = 8 en fin de document",
         grepl(avertissement_T(8), h, fixed = TRUE))
# Echappement HTML des colonnes textuelles du moteur : fait une seule fois,
# dans table_detail_groupe() / table_synthese_groupe(), source commune de
# l'onglet Tests et du rapport (H1 du TOST = "|a| < Delta ...").
i_tost <- which(grepl("^\\|a\\| < Delta", tb$H1))[1]
det_tost <- table_detail_groupe(tb[i_tost, , drop = FALSE])
verifier("table_detail_groupe() : H0 et H1 echappes (|a| &lt; Delta, |a| &gt;= Delta), balise du test conservee",
         !is.na(i_tost) && startsWith(det_tost$H1, "|a| &lt; Delta") &&
         startsWith(det_tost$H0, "|a| &gt;= Delta") &&
         startsWith(det_tost$Test, "<span style=") &&
         grepl("|a| &lt; Delta", html_table(det_tost), fixed = TRUE))
verifier("table_synthese_groupe() : badges non echappes, texte echappe",
         {
           sy <- table_synthese_groupe(tb)
           all(startsWith(sy$Verdict, "<span style=")) && !any(grepl("&lt;span", unlist(sy), fixed = TRUE))
         })
verifier("Rapport : pas de double echappement (&amp;lt; / &amp;gt; absents), H1 du TOST echappe une fois",
         compte(h, "&amp;lt;") == 0 && compte(h, "&amp;gt;") == 0 &&
         grepl("|a| &lt; Delta", h, fixed = TRUE))
# Type et motif d'une ligne (#124) : lus dans tb$type, tb$inoperant (#129,
# point 3) et tb$commentaire (engine_table_tests()), restitues par table_detail_groupe() (colonnes Type
# et "Motif / commentaire") et, pour les lignes autres que "test", sous le
# badge de table_synthese_groupe() ; memes fonctions dans le rapport fige.
det_all <- table_detail_groupe(tb); sy_all <- table_synthese_groupe(tb)
i_fis <- grep("^Test de Fisher", tb$test)[1]
i_inop <- which(tb$inoperant)[1]
verifier("table_detail_groupe() : colonnes Type et Motif / commentaire, motif echappe (Fisher diagnostic, J1, #169)",
         all(c("Type", "Motif / commentaire") %in% names(det_all)) &&
         !is.na(i_fis) && identical(tb$type[i_fis], "diagnostic") &&
         identical(det_all$Type[i_fis], "diagnostic") &&
         grepl("redondante avec le test de Pitman (F = t^2)", det_all[["Motif / commentaire"]][i_fis], fixed = TRUE))
verifier("table_detail_groupe() : toute ligne INFO a un motif (aucun tiret)",
         all(det_all[["Motif / commentaire"]][tb$verdict == "INFO"] != "\u2013"))
verifier("Type : test inoperant (R1) distingue du diagnostic, en detail et sous le badge de synthese",
         !is.na(i_inop) && identical(type_ligne(tb)[i_inop], "test inop\u00e9rant") &&
         identical(det_all$Type[i_inop], "test inop\u00e9rant") &&
         grepl("test inop\u00e9rant</span>", sy_all$Verdict[i_inop], fixed = TRUE) &&
         all(!grepl("<br>", sy_all$Verdict[tb$type == "test"], fixed = TRUE)))
# Source du type "test inoperant" (#129, point 3, constat 1 de l'audit) : le
# champ inoperant, non le prefixe du commentaire. Table alteree pour separer
# les deux lectures, qui coincident sur des donnees reelles.
verifier("Type : test inoperant lu dans tb$inoperant, non dans le prefixe TEST INOPERANT",
         {
           tb1 <- tb; tb1$commentaire[i_inop] <- "sans prefixe"
           tb2 <- tb; tb2$inoperant[i_inop] <- FALSE
           identical(type_ligne(tb1)[i_inop], "test inopérant") &&
             identical(type_ligne(tb2)[i_inop], "diagnostic")
         })
verifier("Rapport : motif de la ligne Fisher restitue dans la section des tests retenus",
         retenu[i_fis] &&
         grepl("redondante avec le test de Pitman (F = t^2)",
               paste(ligne_de(principal, tb$test[i_fis]), collapse = ""), fixed = TRUE))
verifier("Garde : table sans colonnes type ni commentaire -> tirets, aucun libelle sous le badge",
         {
           tb0 <- tb; tb0$type <- NULL; tb0$commentaire <- NULL
           d0 <- table_detail_groupe(tb0); s0 <- table_synthese_groupe(tb0)
           all(d0$Type == "\u2013") && all(d0[["Motif / commentaire"]] == "\u2013") &&
             !any(grepl("<br>", s0$Verdict, fixed = TRUE))
         })
tb_vc <- engine_table_tests(run_engine(xt = rep(100, 8), yt = yt, methode = "premium",
                                       segment = 1, B = 99, nature_donnees = "brutes"))
i_r13 <- which(tb_vc$type == "non applicable" & startsWith(tb_vc$commentaire, "volumes x_t constants"))
verifier("Volumes constants (R13) : 13 lignes non applicables, type et motif restitues",
         length(i_r13) == 13 &&
         all(table_detail_groupe(tb_vc)$Type[i_r13] == "non applicable") &&
         all(startsWith(table_detail_groupe(tb_vc)[["Motif / commentaire"]][i_r13], "volumes x_t constants")) &&
         all(grepl("non applicable</span>", table_synthese_groupe(tb_vc)$Verdict[i_r13], fixed = TRUE)))
# Tableau "Robustesse du calibrage" : non filtre, comme l'onglet Calibration.
cle_ln <- vapply(tb$famille, function(f) groupe_de(f)$cle, character(1))
s_rob <- selection_defaut(tb); s_rob$garde[cle_ln == "ROB"] <- FALSE
f_rob <- tempfile(fileext = ".html")
rapport_html(res_ln, s_rob, f_rob, interactif = FALSE, identite = idt)
h_rob <- lire(f_rob)
sec_rob <- entre(h_rob, "<section id='section-robustesse'>", "</section>")
verifier("Rapport : tableau Robustesse du calibrage = table_robustesse(), meme si les diagnostics ROB sont deselectionnes",
         any(cle_ln == "ROB") &&
         identical(sec_rob, entre(h, "<section id='section-robustesse'>", "</section>")) &&
         compte(sec_rob, "<tr><td>") == sum(cle_ln == "ROB") &&
         all(vapply(tb$test[cle_ln == "ROB"], function(n)
           grepl(paste0("<td>", .echap_html(n), "</td>"), sec_rob, fixed = TRUE) &&
             length(ligne_de(entre(h_rob, "<section id='section-annexe-exclus'>", "</section>"), n)) == 1,
           logical(1))))
verifier("Rapport : selection NULL = selection par defaut",
         {
           f <- tempfile(fileext = ".html")
           r <- rapport_html(res_ln, NULL, f, interactif = FALSE, identite = idt)
           r$n_retenus == sum(filtrer_selection(tb, selection_defaut(tb)))
         })
verifier("Rapport : refus explicite sur un resultat refuse ou une selection d'un autre resultat",
         leve_erreur(rapport_html(run_engine(xt = xt[1:4], yt = yt[1:4], methode = "premium",
                                             segment = 1, B = 99, nature_donnees = "brutes"),
                                  NULL, tempfile())) &&
         leve_erreur(rapport_html(res_ln, selection_defaut(engine_table_tests(res_mw)), tempfile())))

## --- Rapport fige, Merz-Wuthrich ----------------------------------------------
f_mw <- tempfile(fileext = ".html")
r_mw <- rapport_html(res_mw, NULL, f_mw, interactif = FALSE, identite = idt)
hm <- lire(f_mw)
tbm <- engine_table_tests(res_mw); rm <- filtrer_selection(tbm, selection_defaut(tbm))
verifier("Rapport MW : triangle du calcul restitue (virgule decimale, #236), cellules non observees en tiret",
         grepl("<td>2766,61</td>", hm, fixed = TRUE) && grepl("<td>\u2013</td>", hm, fixed = TRUE))
verifier("Rapport MW : exclus par defaut en annexe avec leur verdict",
         any(!rm) && all(vapply(which(!rm), function(k)
           grepl(badge_verdict(tbm$verdict[k]),
                 ligne_de(entre(hm, "<section id='section-annexe-exclus'>", "</section>"), tbm$test[k]),
                 fixed = TRUE), logical(1))))
# Depuis #245, la ligne M5 Lilliefors est un diagnostic : ni nature_p ni
# verdict de test ; elle n'a plus le badge 'approx. n fini' (#120).
verifier("Rapport MW : M5 Lilliefors (variante secondaire, en annexe), diagnostic INFO sans badge 'approx. n fini' (#245)",
         {
           lg <- ligne_de(entre(hm, "<section id='section-annexe-exclus'>", "</section>"),
                          "Lilliefors sur les residus de Mack")
           length(lg) == 1L && nzchar(lg) && grepl(badge_verdict("INFO"), lg, fixed = TRUE) &&
             !grepl(badge_nature(NATURE_APPROX_N_FINI), lg, fixed = TRUE)
         })
verifier("Rapport MW : formule racine(MSEP) / R, sans facteur de taille finie",
         grepl("racine(MSEP) / R", texte_formule(res_mw), fixed = TRUE) &&
         !grepl("(T+1)/(T-1)", texte_formule(res_mw), fixed = TRUE) &&
         grepl(.echap_html(texte_formule(res_mw)), hm, fixed = TRUE))
verifier("Rapport MW : tableau Robustesse du calibrage avec tous les diagnostics M6",
         {
           cle_mw <- vapply(tbm$famille, function(f) groupe_de(f)$cle, character(1))
           sec <- entre(hm, "<section id='section-robustesse'>", "</section>")
           any(cle_mw == "M6") && compte(sec, "<tr><td>") == sum(cle_mw == "M6") &&
             all(vapply(tbm$test[cle_mw == "M6"], function(n)
               grepl(paste0("<td>", .echap_html(n), "</td>"), sec, fixed = TRUE), logical(1)))
         })
verifier("Rapport MW : aucune reference externe, empreintes presentes",
         compte(hm, "src=\"http") == 0 && compte(hm, "href=\"http") == 0 &&
         grepl(engine_empreinte(res_mw)$donnees, hm, fixed = TRUE))
if (png_ok)
  verifier("Rapport MW PNG : une image par graphique",
           compte(hm, "src='data:image/png;base64,iVBORw0KGgo") ==
             sum(vapply(.graphiques_rapport(res_mw), function(o) length(o$g), integer(1))) + 1L)

## --- Citation reglementaire sous chaque groupe (issue #92) --------------------
# Source : annexe XVII, point B(2)(g) i. a iv. (methode du risque de primes) et
# point C(2)(e) i. a iv. (methode du risque de reserve no 1) ; D(2)(h) pour
# Merz-Wuthrich. L'application (onglet Tests) et le rapport fige citent le
# seul point de la methode appliquee, lu dans le champ famille du moteur par
# groupe_de() ; repli sur GROUPES$ref pour les groupes sans citation (F., G.,
# M4 a M6). Valeurs attendues ressaisies ici (double saisie).
res_r1 <- run_engine(xt = xt, yt = yt, methode = "reserve1", segment = 1, annexe = "II",
                     B = 99)
diag_c <- "diagnostics compl\u00e9mentaires"
ref_attendue <- function(pt) c(
  H1 = paste0("annexe XVII, ", pt, "(i)"),   H2 = paste0("annexe XVII, ", pt, "(ii)"),
  H3 = paste0("annexe XVII, ", pt, "(iii)"), H4 = paste0("annexe XVII, ", pt, "(iv)"),
  STAB = diag_c, ROB = diag_c)
ref_mw <- c(M1 = "annexe XVII, D(2)(h)(iii)", M2 = "annexe XVII, D(2)(h)(iv)",
            M3 = "annexe XVII, D(2)(h)(i) et (ii)", M4 = diag_c,
            M5 = "hors annexe XVII, D(2)(h)", M6 = diag_c)
# Reference affichee par groupe, dans l'ordre de cles_groupes() (premiere
# famille du groupe, comme app.R et rapport_html()).
refs_groupes <- function(res) {
  f <- engine_table_tests(res)$famille
  cle <- vapply(f, function(x) groupe_de(x)$cle, character(1))
  k <- intersect(cles_groupes(), cle)
  setNames(vapply(k, function(x) groupe_de(f[match(x, cle)])$ref, character(1)), k)
}
# Citations en italique de la section 5 du rapport fige.
refs_rapport <- function(res) {
  f <- tempfile(fileext = ".html")
  rapport_html(res, NULL, f, interactif = FALSE, identite = idt)
  sec <- entre(lire(f), "<section id='section-tests-retenus'>", "</section>")
  sub("^<div class='gris'><i>(.*)</i></div>$", "\\1",
      regmatches(sec, gregexpr("<div class='gris'><i>.*?</i></div>", sec, perl = TRUE))[[1]])
}
verifier("Citation affichee, premium : B(2)(g)(i) a (iv), une par groupe H1-H4 (issue #92)",
         identical(refs_groupes(res_ln), ref_attendue("B(2)(g)")))
verifier("Citation affichee, reserve1 : C(2)(e)(i) a (iv), une par groupe H1-H4 (issue #92)",
         identical(refs_groupes(res_r1), ref_attendue("C(2)(e)")))
verifier("Citation affichee : repli sur GROUPES$ref pour F. et G. (aucune citation dans la famille)",
         {
           f <- unique(engine_table_tests(res_ln)$famille)
           fg <- f[substr(f, 1, 2) %in% c("F.", "G.")]
           length(fg) == 2L && all(is.na(vapply(fg, citation_de, character(1)))) &&
             identical(unname(vapply(fg, function(x) groupe_de(x)$ref, character(1))),
                       c(GROUPES[["F."]]$ref, GROUPES[["G."]]$ref))
         })
verifier("Citation affichee, Merz-Wuthrich : M1 a M6 inchanges (egaux a GROUPES$ref)",
         identical(refs_groupes(res_mw), ref_mw) &&
           identical(unname(ref_mw), unname(vapply(GROUPES[paste0("M", 1:6)],
                                                   function(g) g$ref, character(1)))))
verifier("Rapport fige : citations de la methode appliquee seulement (premium B(2)(g), reserve1 C(2)(e))",
         {
           rp <- refs_rapport(res_ln); rr <- refs_rapport(res_r1)
           identical(rp, unname(ref_attendue("B(2)(g)")[names(refs_groupes(res_ln))])) &&
             identical(rr, unname(ref_attendue("C(2)(e)")[names(refs_groupes(res_r1))])) &&
             !any(grepl("C(2)(e)", rp, fixed = TRUE)) && !any(grepl("B(2)(g)", rr, fixed = TRUE)) &&
             !any(grepl(" ; ", c(rp, rr), fixed = TRUE))
         })
verifier("citation_de() : parentheses imbriquees et forme \"et (ii)\" ; NA sans citation",
         identical(citation_de("M3. independance (annexe XVII D(2)(h)(i) et (ii))"),
                   "annexe XVII, D(2)(h)(i) et (ii)") &&
           identical(citation_de("M5. normalite des residus (diagnostic, NON exige par le modele)"),
                     NA_character_) &&
           identical(groupe_de("Z. inconnue")$ref, ""))
rm(res_r1)

## --- Branche interactive (plotly), si le paquet est installe -----------------
if (requireNamespace("plotly", quietly = TRUE) && requireNamespace("htmltools", quietly = TRUE)) {
  f_int <- tempfile(fileext = ".html")
  r_int <- rapport_html(res_ln, s, f_int, interactif = TRUE, identite = idt)
  hi <- lire(f_int)
  # Les bibliotheques integrees sont reperees par leur balise ; le reste du
  # document ne doit contenir aucune URL de ressource.
  # (?s) : le point doit traverser les sauts de ligne des bibliotheques.
  hors_biblio <- gsub("(?s)<script data-dependance=[^>]*>.*?</script>", "", hi, perl = TRUE)
  verifier("Rapport interactif : mode plotly, un widget par graphique",
           r_int$mode == "plotly" && compte(hi, "class=\"plotly html-widget") == n_graphes)
  verifier("Rapport interactif : aucune ressource externe (src=\"http nulle part ; href=\"http hors bibliotheques integrees nul)",
           compte(hi, "src=\"http") == 0 && compte(hors_biblio, "href=\"http") == 0 &&
           compte(hors_biblio, "src=\"http") == 0 && !grepl("<script src=", hi, fixed = TRUE) &&
           !grepl("<link ", hi, fixed = TRUE))
  verifier("Rapport interactif : bibliotheques integrees (htmlwidgets, plotly)",
           grepl("<script data-dependance=\"htmlwidgets ", hi, fixed = TRUE) &&
           grepl("<script data-dependance=\"plotly-main ", hi, fixed = TRUE))
  verifier("Rapport interactif : memes sections et memes exclus qu'en PNG",
           identical(entre(hi, "<section id='section-annexe-exclus'>", "</section>"), annexe))
} else {
  cat("  note : plotly absent ; branche interactive non exercee (attendu en CI, issue #53).\n")
}

## --- Troncature des annees fournies (issue #104) ------------------------------
# n = 12 annees (4 annees synthetiques, sans source, devant les 8 du jeu
# ci-dessus), T = 8 : la ligne "profondeur" de engine_derogations() est
# reprise dans le rapport fige (en-tete et bandeau de la calibration) ;
# absente quand n = T (res_ln).
res_12 <- run_engine(xt = c(95.10, 97.80, 99.40, 101.05, xt),
                     yt = c(71.30, 64.20, 80.15, 69.90, yt), methode = "premium",
                     segment = 1, B = 99, nature_donnees = "brutes", T = 8)
f_12 <- tempfile(fileext = ".html")
rapport_html(res_12, selection_defaut(engine_table_tests(res_12)), f_12,
             interactif = FALSE, identite = idt)
h12 <- lire(f_12)
lib12 <- .echap_html(engine_derogations(res_12)$libelle)
verifier("Rapport fige, n = 12, T = 8 : libelle \"profondeur\" du moteur repris deux fois (en-tete, bandeau) ; absent pour n = T (#104)",
         length(lib12) == 1L && compte(h12, lib12) == 2L &&
           !grepl("annees fournies", h, fixed = TRUE))

## --- Graphiques d'influence a distances de Cook non finies (issue #153) -------
# Residus de y = beta x tous nuls : residu_std et D_t = NaN sur les 8
# annees. Avant #153, plot_influence_levier() et plot_influence_cook()
# levaient en base R l'erreur "need finite 'ylim' values", affichee par
# app.R a la place des graphiques ; ils rendent desormais .vide() avec le
# motif plots_data$influence_motif pose par le moteur. Le cas de l'issue,
# y exactement proportionnel a x (x = 2^(0:7), y = x / 2), n'atteint pas
# la garde sur toute plateforme : selon le BLAS, ses routines et la version
# de R, lm() y rend des residus exactement nuls ou un bruit d'arrondi
# (mesure, R 4.3.3 et OpenBLAS 0.3.20 de la CI : max D_t NaN avec les
# routines Zen, Haswell et le BLAS de reference, 0,0029 avec SkylakeX ;
# voir test_controles_entree.R). La garde est donc atteinte a coup sur par
# injection dans l'environnement du moteur : .usp_echelle_exacte() rend
# y = 0 pour les donnees de test (residus exactement nuls sous tout BLAS),
# et engine_plots_data() pose le motif ; le cas de l'issue est garde pour
# l'absence d'erreur R et la coherence de son issue. Branche base R sur un
# peripherique pdf(NULL) ; branche plotly seulement si le paquet est
# installe (pas en CI, issue #53).
echelle_orig153 <- .usp_echelle_exacte
avec_y_nul153 <- function(expr) {
  e <- environment(run_engine)
  assign(".usp_echelle_exacte",
         function(v) if (isTRUE(all.equal(v, yt))) 0 * v else echelle_orig153(v), envir = e)
  on.exit(assign(".usp_echelle_exacte", echelle_orig153, envir = e))
  expr
}
res_g153 <- suppressWarnings(avec_y_nul153(
  run_engine(xt = xt, yt = yt, methode = "premium", segment = 1, B = 99, nature_donnees = "brutes")))
pd153 <- res_g153$plots_data
# Decision du mainteneur du 08/10/2026, #188 : run_engine() refuse
# desormais la serie exactement proportionnelle (maximum de vraisemblance
# non atteint, gamma sur la borne basse de BORNES_GAMMA). Les graphiques
# d'influence de ce cas sont construits sans run_engine(), par
# engine_plots_data() sur l'ajustement, le bootstrap, le profil, le
# jackknife et sigma_USP directs, avec les arguments dont depend la table
# d'influence (segment II-1, donnees brutes ; sans lr_delta, sans objet
# pour l'influence) : sans jackknife ni sigma_USP, la table d'influence
# n'a pas ecart_sigma et note_influence() rend NULL. Ce cas n'est plus
# produit par run_engine() : le test garde la robustesse de la fonction
# publique engine_plots_data() et de note_influence() en appel direct, seule
# couverture sans injection de residus exactement nuls (avis d'actuary du
# 08/10/2026).
xp153 <- 2^(0:7)
res_p153 <- suppressWarnings(run_engine(xt = xp153, yt = xp153 / 2, methode = "premium",
                                        segment = 1, B = 99, nature_donnees = "brutes"))
pdp153 <- suppressWarnings(local({
  f <- usp_ajuster(xp153, xp153 / 2)
  b <- usp_bootstrap(f, B = B_MIN_USAGE)
  s0 <- usp_parametre_standard("premium", 1, "II", "brutes")$sigma_standard
  bar <- usp_bareme_segment(1, "II")
  engine_plots_data(f, b, usp_profil(f), usp_jackknife(f, s0, bar),
                    usp_parametre(f, s0, bar)$sigma_usp)
}))
traces153 <- c("plot_influence_levier", "plot_influence_cook", "plot_influence_sigma")
sans_erreur153 <- function(pd) vapply(traces153, function(f)
  !inherits(tryCatch(get(f)(pd), error = function(e) e), "error"), logical(1))
option153 <- options(usp.graphiques_base = TRUE); grDevices::pdf(NULL)
base153 <- sans_erreur153(pd153)
basep153 <- sans_erreur153(pdp153)
pd153_sans_motif <- pd153; pd153_sans_motif$influence_motif <- NULL
temoin153 <- suppressWarnings(sans_erreur153(pd153_sans_motif))
grDevices::dev.off(); options(option153)
# Repere de levier : les leviers ne dependent que de x (inchanges par
# l'injection) ; decompte attendu lu dans plots_data.
lev153 <- sprintf("<b>%d</b> au-del&agrave; du rep&egrave;re de levier", sum(pd153$influence$fort_levier))
verifier("Graphiques d'influence, residus de y = beta x nuls (injection) : motif pose par le moteur (residu_std et cook non finis), absent sur les donnees ordinaires (#153)",
         isTRUE(res_g153$ok) && is.character(pd153$influence_motif) &&
           length(pd153$influence_motif) == 1L &&
           !any(is.finite(pd153$influence$cook)) && !any(is.finite(pd153$influence$residu_std)) &&
           is.null(res_ln$plots_data$influence_motif) &&
           identical(get(".usp_echelle_exacte", envir = environment(run_engine)), echelle_orig153))
verifier("Graphiques d'influence, residus de y = beta x nuls (injection), base R : aucun trace en erreur ; sans le motif, residus vs levier et Cook par annee en erreur (temoin de la garde, #153)",
         all(base153) && identical(unname(temoin153), c(FALSE, FALSE, TRUE)))
verifier("note_influence(), residus de y = beta x nuls (injection) : decompte de Cook remplace (aucun 'NA'), repere de levier conserve (#153)",
         {
           n153 <- note_influence(pd153)
           is.character(n153) && !grepl("NA", n153, fixed = TRUE) &&
             grepl("sans objet", n153, fixed = TRUE) && grepl(lev153, n153, fixed = TRUE)
         })
verifier("run_engine, y proportionnel a x (x = 2^(0:7), y = x / 2) : ok = FALSE, refus 'maximum de vraisemblance non atteint', sans plots_data (decision du mainteneur du 08/10/2026, #188)",
         identical(res_p153$ok, FALSE) && identical(names(res_p153), c("ok", "validation", "metadata")) &&
           is.null(res_p153$validation$erreur_r) &&
           any(startsWith(res_p153$validation$erreurs, "Maximum de vraisemblance non atteint")))
# Depuis #224, les huit reajustements du jackknife de ce jeu sont refuses par
# usp_valider_ajustement() et laisses a NA : ecart_sigma est entierement NA.
# Corrige par #328 : plot_influence_sigma() rend .vide() avec un message fixe
# et note_influence() une phrase fixe, sans 'NA' (avant : erreur « need finite
# 'ylim' values » et character(0)).
verifier("Graphiques d'influence, y proportionnel a x (x = 2^(0:7), y = x / 2), ajustement refuse par run_engine() (#188), robustesse de engine_plots_data() / note_influence() en appel direct : motif pose (residu_std et cook non finis) ou absent (tout fini) selon la plateforme ; aucun trace en base R ni note_influence() en erreur, aucun 'NA' dans la note (#153 ; #188 ; #328)",
         {
           inf <- pdp153$influence
           np153 <- tryCatch(note_influence(pdp153), error = function(e) e)
           garde <- !any(is.finite(inf$cook)) && !any(is.finite(inf$residu_std)) &&
             is.character(pdp153$influence_motif) && length(pdp153$influence_motif) == 1L
           calcule <- all(is.finite(inf$cook)) && all(is.finite(inf$residu_std)) &&
             is.null(pdp153$influence_motif)
           (garde || calcule) && all(basep153) &&
             is.character(np153) && length(np153) == 1L && !grepl("NA", np153, fixed = TRUE)
         })

## --- Jackknife non evaluable : graphique et note d'influence (issue #328) -----
# Cas entierement NA : ecart_sigma non fini sur les huit annees (jeu de #188
# ci-dessus). Message fixe du graphique, phrase fixe de la note, en
# coherence avec le detail de la ligne jackknife (#329) ; le rapport fige,
# qui passe par les memes fonctions, est produit sans erreur (resultat ok de
# J1 dont plots_data$influence est injecte a NA, run_engine() n'atteignant
# pas ce cas sur un jeu accepte).
MSG_328 <- "Aucune annee evaluable : influence sur sigma_USP non mesuree"
# .vide() est enveloppe dans l'environnement de plot_influence_sigma() pour
# relever son message (meme procede que releve_vide161, #161).
env328 <- environment(plot_influence_sigma); vide328 <- get(".vide", envir = env328)
vide_328 <- function(pd) {
  msg <- NULL
  assign(".vide", function(message = formals(vide328)$message) { msg <<- message; vide328(message) },
         envir = env328)
  on.exit(assign(".vide", vide328, envir = env328))
  r <- tryCatch({ plot_influence_sigma(pd); TRUE }, error = function(e) FALSE)
  list(ok = r, msg = msg)
}
option328 <- options(usp.graphiques_base = TRUE); grDevices::pdf(NULL)
na328 <- vide_328(pdp153)
nn328 <- tryCatch(note_influence(pdp153), error = function(e) e)
grDevices::dev.off(); options(option328)
verifier("plot_influence_sigma(), jackknife entierement NA (base R) : aucune erreur, graphique vide avec le message fixe (#328)",
         all(is.na(pdp153$influence$ecart_sigma)) && na328$ok && identical(na328$msg, MSG_328))
verifier("note_influence(), jackknife entierement NA : phrase fixe 'Aucune annee evaluable', plus de phrase sur l'annee la plus influente, aucun 'NA', une chaine (#328)",
         is.character(nn328) && length(nn328) == 1L && !grepl("NA", nn328, fixed = TRUE) &&
           grepl("Aucune ann&eacute;e &eacute;valuable", nn328, fixed = TRUE) &&
           !grepl("la plus influente", nn328, fixed = TRUE) &&
           grepl("n'est pas mesur&eacute;e", nn328, fixed = TRUE))
verifier("Rapport fige, jackknife entierement NA (plots_data injecte) : produit sans erreur, note d'influence a phrase fixe (#328)",
         {
           r328 <- res_ln
           r328$plots_data$influence$sigma_usp_sans_t <- rep(NA_real_, length(xt))
           r328$plots_data$influence$ecart_sigma <- rep(NA_real_, length(xt))
           r328$plots_data$influence$fort_ecart_sigma <- rep(NA, length(xt))
           f328 <- tempfile(fileext = ".html")
           ok328 <- tryCatch({
             rapport_html(r328, NULL, f328, interactif = FALSE, identite = idt); TRUE
           }, error = function(e) FALSE)
           h328 <- if (ok328) lire(f328) else ""; unlink(f328)
           ok328 && grepl("Aucune ann&eacute;e &eacute;valuable", h328, fixed = TRUE) &&
             !grepl("d&eacute;place sigma_USP de", h328, fixed = TRUE) &&
             !grepl("Graphique indisponible", h328, fixed = TRUE)
         })

# Cas partiellement NA : jeu de #224 (x de J1, y = 0,7 x, y_5 = 0,8 x_5), annee
# 5 non evaluable. La barre de l'annee 5 reste absente, sans erreur ; la note
# cite l'annee 5 (ensemble des annees dont ecart_sigma n'est pas fini).
y328 <- 0.7 * xt; y328[5] <- 0.8 * xt[5]
res328 <- tryCatch(run_engine(xt = xt, yt = y328, methode = "premium", segment = 1, B = 99,
                               nature_donnees = "brutes"), error = function(e) e)
pd328 <- res328$plots_data
option328 <- options(usp.graphiques_base = TRUE); grDevices::pdf(NULL)
base328 <- !inherits(tryCatch(plot_influence_sigma(pd328), error = function(e) e), "error")
grDevices::dev.off(); options(option328)
nt328 <- tryCatch(note_influence(pd328), error = function(e) e)
verifier("Jeu de #224 (annee 5 non evaluable) : barre de l'annee 5 absente, graphique base R sans erreur ; note qui cite l'annee 5, conserve la phrase de l'annee la plus influente, aucun 'NA' (#328)",
         !inherits(res328, "error") && isTRUE(res328$ok) &&
           identical(which(is.na(pd328$influence$ecart_sigma)), 5L) &&
           base328 && is.character(nt328) && length(nt328) == 1L &&
           grepl("Ann&eacute;e 5 non &eacute;valuable", nt328, fixed = TRUE) &&
           grepl("d&eacute;place sigma_USP de", nt328, fixed = TRUE) &&
           !grepl("NA", nt328, fixed = TRUE))
verifier("note_influence(), annees non evaluables 2 et 5 (injection) : 'Annees 2 et 5 non evaluables' ; jeu sans annee non evaluable : aucune phrase (#328)",
         {
           pd2 <- pd328; pd2$influence$sigma_usp_sans_t[2] <- NA; pd2$influence$ecart_sigma[2] <- NA
           n2 <- note_influence(pd2)
           n0 <- note_influence(res_ln$plots_data)
           grepl("Ann&eacute;es 2 et 5 non &eacute;valuables", n2, fixed = TRUE) &&
             !grepl("valuable", n0, fixed = TRUE) && !grepl("NA", n0, fixed = TRUE)
         })
verifier("note_influence(), annees non evaluables 2, 5 et 7 (injection) : 'Annees 2, 5 et 7 non evaluables' (#328)",
         {
           pd3 <- pd328
           pd3$influence$sigma_usp_sans_t[c(2, 7)] <- NA; pd3$influence$ecart_sigma[c(2, 7)] <- NA
           grepl("Ann&eacute;es 2, 5 et 7 non &eacute;valuables", note_influence(pd3), fixed = TRUE)
         })
# ecart_sigma entierement non fini alors que sigma_usp_sans_t est fini (sigma_USP
# nul, par exemple) : le graphique est vide (jamais « need finite ylim ») et la
# note rend la phrase fixe, une chaine.
verifier("ecart_sigma tout NA avec sigma_usp_sans_t fini : graphique vide au message fixe, note a phrase fixe en une chaine (#328)",
         {
           pdn <- pd328; pdn$influence$ecart_sigma[] <- NA_real_; pdn$influence$fort_ecart_sigma[] <- NA
           op <- options(usp.graphiques_base = TRUE); grDevices::pdf(NULL)
           vn <- vide_328(pdn); grDevices::dev.off(); options(op)
           nn <- tryCatch(note_influence(pdn), error = function(e) e)
           all(is.finite(pdn$influence$sigma_usp_sans_t[-5])) && vn$ok && identical(vn$msg, MSG_328) &&
             is.character(nn) && length(nn) == 1L && !grepl("NA", nn, fixed = TRUE) &&
             grepl("Aucune ann&eacute;e &eacute;valuable", nn, fixed = TRUE)
         })
# Le maximum ne cite jamais une annee ecartee : meme avec un ecart enorme a
# l'annee non evaluable (injection), la note donne le maximum des autres annees.
verifier("note_influence() : maximum calcule hors des annees non evaluables (ecart injecte a l'annee 5 ignore) (#328)",
         {
           pdm <- pd328; pdm$influence$ecart_sigma[5] <- 9
           grepl("sigma_USP de <b>+2,1 %</b>", note_influence(pdm), fixed = TRUE)
         })
# Reperage par sigma_usp_sans_t (critere de jack_non_evaluables du moteur) et
# non par ecart_sigma : annee non evaluable reperee meme si ecart_sigma y est
# fini (injection), repli sur ecart_sigma sans sigma_usp_sans_t.
verifier("note_influence(), repere par sigma_usp_sans_t non fini (ecart_sigma fini) ; repli sur ecart_sigma sans sigma_usp_sans_t (#328)",
         {
           pdr <- pd328; pdr$influence$sigma_usp_sans_t[3] <- NA
           pdq <- pd328; pdq$influence$sigma_usp_sans_t <- NULL
           grepl("Ann&eacute;es 3 et 5 non &eacute;valuables", note_influence(pdr), fixed = TRUE) &&
             grepl("Ann&eacute;e 5 non &eacute;valuable", note_influence(pdq), fixed = TRUE) &&
             !grepl("Ann&eacute;es", note_influence(pdq), fixed = TRUE)
         })
if (requireNamespace("plotly", quietly = TRUE)) {
  verifier("Graphiques d'influence, residus nuls (injection) et y proportionnel a x, plotly : aucun trace en erreur (#153)",
           all(sans_erreur153(pd153)) && all(sans_erreur153(pdp153)))
  # Jackknife non evaluable (#328), branche plotly : graphique vide (entierement
  # NA) et barre absente (partiellement NA), sans erreur.
  verifier("plot_influence_sigma(), jackknife entierement puis partiellement NA, plotly : aucun trace en erreur (#328)",
           !inherits(tryCatch(plotly::plotly_build(plot_influence_sigma(pdp153)), error = function(e) e), "error") &&
             !inherits(tryCatch(plotly::plotly_build(plot_influence_sigma(pd328)), error = function(e) e), "error"))
} else {
  cat("  note : plotly absent ; branche plotly des graphiques d'influence non exercee (attendu en CI, issue #53).\n")
}

## --- Rapport de vraisemblance sur delta et profil en echec (issue #161) --------
# Erreur injectee dans l'environnement du moteur : usp_ajuster_contraint() en
# echec sur les donnees observees aux deux bornes (jeu a delta interieur) et
# usp_objectif() en echec sous usp_profil(). Le moteur rend ok = TRUE avec
# plots_data$lr_delta$lr, q90_bootstrap et les objectifs du profil a NA, de
# meme forme ; l'affichage doit les restituer sans erreur R (trace du profil
# en base R sur pdf(NULL), tableaux de l'onglet Tests, rapport fige).
avec_injection161 <- function(nom, f, expr) {
  e <- environment(run_engine)
  orig <- get(nom, envir = e)
  assign(nom, f, envir = e)
  on.exit(assign(nom, orig, envir = e))
  expr
}
xi161 <- c(50, 80, 120, 200, 300, 150, 90, 60)
yi161 <- c(29.92, 56.9, 101.25, 123.06, 207.23, 105.91, 68.59, 40.05)
contraint161 <- usp_ajuster_contraint; objectif161 <- usp_objectif
res161 <- avec_injection161("usp_ajuster_contraint",
  function(x, y, delta0, gamma_depart) {
    if (identical(y, yi161)) stop("panne simulee")
    contraint161(x, y, delta0, gamma_depart)
  },
  avec_injection161("usp_objectif", function(par, ...) {
    if (any(vapply(sys.calls(), function(cl) identical(cl[[1]], as.name("usp_profil")), logical(1))))
      stop("panne simulee")
    objectif161(par, ...)
  }, run_engine(xt = xi161, yt = yi161, methode = "premium", segment = 1, B = 99,
                nature_donnees = "brutes")))
tb161 <- engine_table_tests(res161)
verifier("LR sur delta et profil en echec : ok = TRUE, lr, q90 et objectifs du profil a NA dans plots_data (#161)",
         isTRUE(res161$ok) && all(is.na(res161$plots_data$lr_delta$lr)) &&
           all(is.na(res161$plots_data$lr_delta$q90_bootstrap)) &&
           all(is.na(res161$plots_data$profil_delta$objectif)) &&
           sum(tb161$commentaire == MOTIF_LR_DELTA_ECHEC) == 2L)
option161 <- options(usp.graphiques_base = TRUE); grDevices::pdf(NULL)
trace161 <- suppressWarnings(tryCatch({ plot_profil_delta(res161$plots_data); TRUE },
                                      error = function(e) FALSE))
grDevices::dev.off(); options(option161)
verifier("LR sur delta et profil en echec, base R : plot_profil_delta() sans erreur (#161)", trace161)
# Garde d'affichage (app-review, #161) : profil entierement NA -> .vide() avec
# le message renvoyant aux lignes G, avant la bifurcation base R / plotly ;
# profil ordinaire -> aucun appel a .vide(). .vide() est enveloppe dans
# l'environnement de plot_profil_delta() pour relever son message.
env161 <- environment(plot_profil_delta); vide161 <- get(".vide", envir = env161)
msg161 <- new.env()
releve_vide161 <- function(pdx, base = TRUE) {
  msg161$m <- NULL
  assign(".vide", function(message = "Graphique non disponible pour cette methode") {
    msg161$m <- message; vide161(message)
  }, envir = env161)
  on.exit(assign(".vide", vide161, envir = env161))
  option <- options(usp.graphiques_base = base); grDevices::pdf(NULL)
  on.exit({ grDevices::dev.off(); options(option) }, add = TRUE)
  plot_profil_delta(pdx)
  msg161$m
}
MSG_PROFIL_NA <- "Profil non calculable pour ces donnees (voir le motif des lignes G dans l'onglet Tests)"
res161_ord <- run_engine(xt = xi161, yt = yi161, methode = "premium", segment = 1, B = 99,
                         nature_donnees = "brutes")
verifier("Profil entierement NA : plot_profil_delta() aiguille vers .vide() avec le message renvoyant aux lignes G ; profil ordinaire trace sans .vide() (#161)",
         identical(releve_vide161(res161$plots_data), MSG_PROFIL_NA) &&
           is.null(releve_vide161(res161_ord$plots_data)))
verifier("LR sur delta et profil en echec : tableaux de synthese et de detail sans erreur, lignes LR non applicables avec leur motif (#161)",
         {
           g <- tb161[tb161$commentaire %in% MOTIF_LR_DELTA_ECHEC, ]
           s <- tryCatch(table_synthese_groupe(tb161), error = function(e) NULL)
           d <- tryCatch(table_detail_groupe(g), error = function(e) NULL)
           !is.null(s) && !is.null(d) && nrow(d) == 2L &&
             all(d$Type == "non applicable") &&
             all(grepl("non calculable sur les donnees observees", d$`Motif / commentaire`, fixed = TRUE))
         })
f161 <- tempfile(fileext = ".html")
r161 <- tryCatch(suppressWarnings(rapport_html(res161, selection_defaut(tb161), f161,
                                               interactif = FALSE, identite = idt)),
                 error = function(e) e)
verifier("LR sur delta et profil en echec : rapport fige produit sans erreur, motif restitue (#161)",
         !inherits(r161, "error") && file.exists(f161) &&
           grepl("non calculable sur les donnees observees",
                 paste(readLines(f161, warn = FALSE), collapse = "\n"), fixed = TRUE))
if (requireNamespace("plotly", quietly = TRUE)) {
  verifier("LR sur delta et profil en echec, plotly : plot_profil_delta() sans erreur, message du profil non calculable en annotation (#161)",
           {
             p <- tryCatch(plot_profil_delta(res161$plots_data), error = function(e) e)
             !inherits(p, "error") &&
               identical(releve_vide161(res161$plots_data, base = FALSE), MSG_PROFIL_NA)
           })
} else {
  cat("  note : plotly absent ; branche plotly du profil en echec non exercee (attendu en CI, issue #53).\n")
}

# --- Issue #162 : niveau des bandes du QQ-plot lu dans le moteur ; repere
# asymptotique du profil de delta hors de la legende (base R) et dans le
# cadre (plotly) ---------------------------------------------------------------
pd162 <- res_ln$plots_data
e162 <- pd162$qq_enveloppe
# Au niveau du moteur (0,90), chaines identiques a celles que cite la
# documentation (doc_tests_usp.tex, « enveloppe de simulation 90 % »).
verifier("QQ-plot au niveau du moteur (0,90) : titre, libelles des bandes simultanee et ponctuelle inchanges (#162)",
         identical(e162$niveau_ponctuel, 0.90) && identical(e162$niveau_simultane, 0.90) &&
           identical(.qq_titre(pd162), "QQ-plot normal (H3) — enveloppe de simulation 90 %") &&
           identical(.qq_lib_sim(e162), "bande simultanée 90 % (tous les points à la fois)") &&
           identical(.qq_lib_ponct(e162), "bande ponctuelle 90 % (point par point)"))
# Niveau reecrit dans un qq_enveloppe forge : l'affichage le suit, aucun
# « 90 % » ne subsiste.
forge162 <- function(np, ns) {
  p <- pd162; p$qq_enveloppe$niveau_ponctuel <- np; p$qq_enveloppe$niveau_simultane <- ns; p
}
p80 <- forge162(0.80, 0.80)
verifier("QQ-plot, qq_enveloppe forge a 0,80 : titre et libelles rendent 80 %, aucun 90 % (#162)",
         identical(.qq_titre(p80), "QQ-plot normal (H3) — enveloppe de simulation 80 %") &&
           identical(.qq_lib_sim(p80$qq_enveloppe), "bande simultanée 80 % (tous les points à la fois)") &&
           identical(.qq_lib_ponct(p80$qq_enveloppe), "bande ponctuelle 80 % (point par point)"))
p_mix <- forge162(0.80, 0.95); p_mix$qqnorm$env_sim_bas <- p_mix$qqnorm$env_bas
p_mix$qqnorm$env_sim_haut <- p_mix$qqnorm$env_haut
verifier("QQ-plot, niveaux distincts (0,80 ponctuel, 0,95 simultane) : chaque libelle porte le sien, titre sans niveau ; niveau NA omis (#162)",
         identical(.qq_titre(p_mix), "QQ-plot normal (H3) — enveloppe de simulation") &&
           identical(.qq_lib_sim(p_mix$qq_enveloppe), "bande simultanée 95 % (tous les points à la fois)") &&
           identical(.qq_lib_ponct(p_mix$qq_enveloppe), "bande ponctuelle 80 % (point par point)") &&
           identical(.qq_lib_ponct(list(niveau_ponctuel = NA_real_)), "bande ponctuelle (point par point)") &&
           identical(.qq_lib_sim(list(niveau_simultane = 0.975)),
                     "bande simultanée 97,5 % (tous les points à la fois)"))

# Releve des appels a graphics::legend() et graphics::text() d'un trace base
# R (trace() pose puis retire dans l'environnement de graphics).
releve_base162 <- function(f, largeur = 560 / 72, hauteur = 250 / 72) {
  r <- new.env(); r$leg <- list(); r$txt <- list()
  ns <- asNamespace("graphics")
  suppressMessages({
    # legend(plot = FALSE), appele pour mesurer, n'est pas releve.
    trace("legend", exit = bquote(if (isTRUE(plot)) assign("leg", c(get("leg", envir = .(r)),
            list(list(texte = legend, rect = returnValue()$rect))), envir = .(r))),
          where = ns, print = FALSE)
    # largeur : strwidth() d'un texte sur plusieurs lignes rend celle de la
    # plus longue.
    trace("text.default", exit = bquote(assign("txt", c(get("txt", envir = .(r)),
            list(list(labels = labels, x = if (is.list(x)) x$x else x, col = col,
                      largeur = graphics::strwidth(labels, cex = cex)))), envir = .(r))),
          where = ns, print = FALSE)
  })
  on.exit(suppressMessages({ untrace("legend", where = ns); untrace("text.default", where = ns) }))
  option <- options(usp.graphiques_base = TRUE)
  grDevices::pdf(NULL, width = largeur, height = hauteur)
  on.exit({ grDevices::dev.off(); options(option) }, add = TRUE)
  # pdf(NULL) convertit mal le tiret cadratin des titres : avertissements
  # sans objet ici.
  suppressWarnings(f())
  r$usr <- graphics::par("usr")
  as.list(r)
}
rb162 <- releve_base162(function() plot_profil_delta(pd162))
seuil162 <- pd162$lr_delta$seuil_asymptotique
leg162 <- rb162$leg[[length(rb162$leg)]]
# Libelle du repere asymptotique, sur une ou deux lignes.
filtre_lib162 <- function(txt)
  Filter(function(t) identical(gsub("\n", " ", t$labels, fixed = TRUE), LIB_LR_ASYMPT_COURT), txt)
lib162 <- filtre_lib162(rb162$txt)
verifier("Profil de delta, base R (560 x 250 px, rapport fige) : repere asymptotique absent de la legende, libelle dans le cadre, ligne hors de la legende (#162)",
         length(rb162$leg) == 1L &&
           !any(grepl("repère asymptotique", unlist(lapply(rb162$leg, `[[`, "texte")), fixed = TRUE)) &&
           length(lib162) == 1L &&
           lib162[[1]]$x - lib162[[1]]$largeur / 2 >= rb162$usr[1] &&
           lib162[[1]]$x + lib162[[1]]$largeur / 2 <= rb162$usr[2] &&
           seuil162 < leg162$rect$top - leg162$rect$h)
# Ligne verticale en delta estime hors de la legende et du libelle du repere
# asymptotique, delta estime a l'interieur de [0 ; 1] : J2 (delta estime
# 0,594) et J3 (0,522), donnees arrondies a 0,01, au format du rapport fige
# (560 x 250 px) et a 550 x 330 et 700 x 450 px (#162).
x_int162 <- c(100, 150, 80, 300, 120, 60, 250, 90)
pd_j2 <- run_engine(xt = x_int162, yt = c(58.82, 90.47, 46.68, 187.03, 72.72, 34.95, 151.85, 55.31),
                    methode = "premium", segment = 1, B = 99, nature_donnees = "brutes")$plots_data
pd_j3 <- run_engine(xt = x_int162, yt = c(58.1, 89.8, 47.63, 176.5, 73.7, 35.79, 153.72, 57.09),
                    methode = "premium", segment = 1, B = 99, nature_donnees = "brutes")$plots_data
delta_hors_cadres162 <- function(pd, l, h) {
  r <- releve_base162(function() plot_profil_delta(pd), l / 72, h / 72)
  leg <- r$leg[[length(r$leg)]]$rect
  lib <- filtre_lib162(r$txt)
  d0 <- pd$delta_estime
  length(r$leg) == 1L && length(lib) == 1L &&
    (d0 < leg$left || d0 > leg$left + leg$w) &&
    (d0 < lib[[1]]$x - lib[[1]]$largeur / 2 || d0 > lib[[1]]$x + lib[[1]]$largeur / 2) &&
    lib[[1]]$x - lib[[1]]$largeur / 2 >= r$usr[1] && lib[[1]]$x + lib[[1]]$largeur / 2 <= r$usr[2]
}
tailles162 <- list(c(560, 250), c(550, 330), c(700, 450))
verifier(sprintf("Profil de delta, base R, delta estime interieur (J2 %s, J3 %s) : ligne en delta estime hors de la legende et du libelle, libelle dans le cadre, a 560 x 250, 550 x 330 et 700 x 450 px (#162)",
                 format(round(pd_j2$delta_estime, 3), decimal.mark = ","),
                 format(round(pd_j3$delta_estime, 3), decimal.mark = ",")),
         pd_j2$delta_estime > 0.5 && pd_j2$delta_estime < 0.65 &&
           pd_j3$delta_estime > 0.45 && pd_j3$delta_estime < 0.55 &&
           all(vapply(tailles162, function(d) delta_hors_cadres162(pd_j2, d[1], d[2]), TRUE)) &&
           all(vapply(tailles162, function(d) delta_hors_cadres162(pd_j3, d[1], d[2]), TRUE)))
# Meme controle de part et d'autre de 0,5 : delta estime force dans
# plots_data (le placement ne lit que delta_estime) ; a 0,45 legende et
# libelle passent a droite.
pd_j3f <- function(d0) { p <- pd_j3; p$delta_estime <- d0; p }
verifier("Profil de delta, base R, delta estime force a 0,45 / 0,50 / 0,55 : ligne hors de la legende et du libelle, aux trois tailles (#162)",
         all(vapply(c(0.45, 0.50, 0.55), function(d0)
           all(vapply(tailles162, function(d) delta_hors_cadres162(pd_j3f(d0), d[1], d[2]), TRUE)), TRUE)))
# C3 : libelle du repere en gris fonce, contraste d'au moins 4,5:1 sur le
# fond (WCAG 2.1, critere 1.4.3) ; la ligne garde le gris de reference.
contraste162 <- function(a, b) {
  lum <- function(h) {
    v <- grDevices::col2rgb(h)[, 1] / 255
    v <- ifelse(v <= 0.03928, v / 12.92, ((v + 0.055) / 1.055)^2.4)
    sum(c(0.2126, 0.7152, 0.0722) * v)
  }
  l <- sort(c(lum(a), lum(b)), decreasing = TRUE)
  (l[1] + 0.05) / (l[2] + 0.05)
}
verifier(sprintf("Libelle du repere asymptotique (base R) en COUL$ref_texte, contraste %s:1 sur le fond >= 4,5:1 (gris de reference %s:1) (#162)",
                 format(round(contraste162(COUL$ref_texte, COUL$fond), 2), decimal.mark = ","),
                 format(round(contraste162(COUL$ref, COUL$fond), 2), decimal.mark = ",")),
         identical(lib162[[1]]$col, COUL$ref_texte) &&
           contraste162(COUL$ref_texte, COUL$fond) >= 4.5)
verifier("Libelle court du repere asymptotique : debut et fin cites par la documentation, libelle long au survol (#162)",
         startsWith(LIB_LR_ASYMPT_COURT, "repère asymptotique") &&
           endsWith(LIB_LR_ASYMPT_COURT, "aide de lecture") &&
           startsWith(LIB_LR_ASYMPT, "repère asymptotique") &&
           endsWith(LIB_LR_ASYMPT, "aide de lecture"))
rq162 <- releve_base162(function() plot_qqnorm(p80), largeur = 1000 / 72, hauteur = 420 / 72)
verifier("QQ-plot base R, qq_enveloppe forge a 0,80 : legende des bandes a 80 % (#162)",
         length(rq162$leg) == 1L &&
           identical(rq162$leg[[1]]$texte, "bande ponctuelle 80 % (point par point)"))
if (requireNamespace("plotly", quietly = TRUE)) {
  # Libelle du repere : cale sur le bord du cote libre, s'etendant vers
  # l'interieur (xanchor du cote du bord), fond opaque, dernier des
  # annotations ; annotation q90 du meme cote de l'autre cote de la ligne.
  plotly_lib162 <- function(pd) {
    b <- plotly::plotly_build(plot_profil_delta(pd))
    an <- b$x$layout$annotations
    est_lib <- vapply(an, function(a) identical(gsub("<br>", " ", a$text, fixed = TRUE),
                                                LIB_LR_ASYMPT_COURT), TRUE)
    survol <- unlist(lapply(b$x$data, function(t) t$text))
    if (sum(est_lib) != 1L || !est_lib[length(an)] || !(LIB_LR_ASYMPT %in% survol)) return(NA_character_)
    a <- an[[length(an)]]
    cote <- if (identical(a$x, 0) && identical(a$xanchor, "left") && a$xshift > 0) "gauche"
            else if (identical(a$x, 1) && identical(a$xanchor, "right") && a$xshift < 0) "droite"
            else "?"
    q <- Filter(function(x) identical(x$text, LIB_LR_Q90_COURT[if (cote == "droite") 2 else 1]), an)
    ok <- identical(a$xref, "x") && identical(a$bgcolor, COUL$fond) &&
      identical(a$font$color, COUL$ref_texte) && length(q) == 1L &&
      !identical(q[[1]]$yanchor, a$yanchor)
    if (ok) cote else NA_character_
  }
  verifier("Profil de delta, plotly : libelle du repere du cote libre (J1 au bord et J2 : gauche ; delta estime 0,45 : droite), fond opaque, annotation q90 du meme cote de l'autre cote de la ligne, libelle long au survol (#162)",
           identical(plotly_lib162(pd162), "gauche") && identical(plotly_lib162(pd_j2), "gauche") &&
             identical(plotly_lib162(pd_j3f(0.45)), "droite"))
  verifier("QQ-plot plotly, qq_enveloppe forge a 0,80 : annotation et titre a 80 % (#162)",
           {
             b <- plotly::plotly_build(plot_qqnorm(p80))
             txt <- vapply(b$x$layout$annotations, `[[`, "", "text")
             ti <- b$x$layout$title; ti <- if (is.list(ti)) ti$text else ti
             identical(txt, "bande ponctuelle 80 % (point par point)") &&
               startsWith(ti, "QQ-plot normal (H3) — enveloppe de simulation 80 %<br>")
           })
} else {
  cat("  note : plotly absent ; annotations plotly du profil de delta et du QQ-plot non exercees (#162).\n")
}

## --- Issue #195 : annotation q90 du bord oppose au cote libre (plotly) -------
# Logique de placement lue sur .lr_annotations_q90(), qui construit les
# annotations q90 sans plotly : elle tourne donc sans plotly. Bord oppose =
# l'autre que .lr_cote_libre(), du cote de delta estime. Pas traversee par le
# repere asymptotique : la bande verticale du texte (yanchor, yshift) est du
# cote de la marque oppose a la ligne. Pas traversee par la ligne en delta
# estime : fond opaque (le texte la masque). Cas de l'issue : J2 (delta estime
# 0,594, annotation de delta = 1) et J3 force a 0,45 (annotation de delta = 0).
ann195 <- function(pd) {
  libre <- if (.lr_cote_libre(pd) == "gauche") 1L else 2L
  list(libre = libre, s = pd$lr_delta$seuil_asymptotique, q = unname(pd$lr_delta$q90_bootstrap),
       ann = .lr_annotations_q90(unname(pd$lr_delta$q90_bootstrap), pd$lr_delta$seuil_asymptotique, libre))
}
# Annotation de l'indice k (1 : delta = 0, 2 : delta = 1), NULL si absente.
ann_k195 <- function(a, k) {
  r <- Filter(function(x) identical(x$text, LIB_LR_Q90_COURT[k]), a$ann)
  if (length(r) == 1L) r[[1]] else NULL
}
# Bande verticale hors du repere : au-dessus (bottom, decalage > 0) si la
# marque est sur la ligne ou au-dessus, au-dessous (top, decalage < 0) sinon.
hors_repere195 <- function(x, q, s)
  if (q >= s) identical(x$yanchor, "bottom") && x$yshift > 0 else identical(x$yanchor, "top") && x$yshift < 0
oppose_ok195 <- function(pd) {
  a <- ann195(pd); k <- 3L - a$libre; x <- ann_k195(a, k)
  !is.null(x) && identical(x$x, c(0, 1)[k]) && identical(x$y, a$q[k]) &&
    identical(x$xanchor, c("left", "right")[k]) && identical(x$bgcolor, COUL$fond) &&
    hors_repere195(x, a$q[k], a$s)
}
a_j2 <- ann195(pd_j2); a_j3 <- ann195(pd_j3f(0.45))
verifier(sprintf("Profil de delta, plotly : annotation q90 du bord oppose, cas de l'issue (J2 delta estime %s, annotation de delta = 1 au-dessus de sa marque, sur le repere ; J3 force a 0,45, annotation de delta = 0 sous sa marque, sous le repere) : hors du repere asymptotique, fond opaque (#195)",
                 format(round(pd_j2$delta_estime, 3), decimal.mark = ",")),
         a_j2$libre == 1L && a_j2$q[2] >= a_j2$s && oppose_ok195(pd_j2) &&
           identical(ann_k195(a_j2, 2)$yanchor, "bottom") &&
           a_j3$libre == 2L && a_j3$q[1] < a_j3$s && oppose_ok195(pd_j3f(0.45)) &&
           identical(ann_k195(a_j3, 1)$yanchor, "top"))
verifier("Profil de delta, plotly : annotation q90 du bord oppose hors du repere et a fond opaque, delta estime proche de chaque bord et autour de 0,5 (0 ; 0,02 ; 0,45 ; 0,50 ; 0,55 ; 0,98 ; 1 ; NA) (#195)",
         all(vapply(c(0, 0.02, 0.45, 0.50, 0.55, 0.98, 1, NA), function(d0) oppose_ok195(pd_j3f(d0)), TRUE)))
# Toutes les positions de marque par rapport au repere, de chaque cote libre :
# les deux annotations sont hors du repere ; seule celle du bord oppose a un
# fond (celle du cote libre garde son rendu de #162) ; seuil non fini : les
# deux au-dessus de leur marque, comme avant ; quantile non fini : pas
# d'annotation ; textes inchanges.
verifier("Placement des annotations q90 (.lr_annotations_q90()) : hors du repere asymptotique pour toute position des marques, fond opaque au seul bord oppose, seuil non fini ou quantile NA traites, textes LIB_LR_Q90_COURT inchanges (#195)",
         all(vapply(list(c(1, 3), c(3, 1), c(1, 1), c(3, 3), c(2, 2)), function(q)
           all(vapply(1:2, function(libre) {
             an <- .lr_annotations_q90(q, 2, libre)
             length(an) == 2L &&
               all(vapply(1:2, function(k) hors_repere195(an[[k]], q[k], 2) &&
                            identical(an[[k]]$text, LIB_LR_Q90_COURT[k]) &&
                            identical(an[[k]]$bgcolor, if (k == libre) NULL else COUL$fond), TRUE))
           }, TRUE)), TRUE)) &&
           all(vapply(.lr_annotations_q90(c(1, 3), NA_real_, 1L), function(x) identical(x$yanchor, "bottom"), TRUE)) &&
           length(.lr_annotations_q90(c(NA, 3), 2, 1L)) == 1L &&
           identical(.lr_annotations_q90(c(NA, 3), 2, 1L)[[1]]$text, LIB_LR_Q90_COURT[2]) &&
           identical(LIB_LR_Q90_COURT, c("q90 % du LR simulé sous δ = 0", "q90 % du LR simulé sous δ = 1")))
if (requireNamespace("plotly", quietly = TRUE)) {
  # Objet plotly_build() : les annotations q90 sont celles de
  # .lr_annotations_q90(), le libelle du repere en dernier.
  verifier("Profil de delta, plotly_build() : annotations q90 = .lr_annotations_q90() (J2, J3 force a 0,45 et 0,98), libelle du repere en dernier (#195)",
           all(vapply(list(pd_j2, pd_j3f(0.45), pd_j3f(0.98)), function(pd) {
             an <- plotly::plotly_build(plot_profil_delta(pd))$x$layout$annotations
             attendu <- ann195(pd)$ann
             n <- length(attendu)
             length(an) == n + 1L &&
               all(vapply(seq_len(n), function(i) all(vapply(names(attendu[[i]]), function(nm)
                 isTRUE(all.equal(an[[i]][[nm]], attendu[[i]][[nm]])), TRUE)), TRUE)) &&
               identical(gsub("<br>", " ", an[[n + 1L]]$text, fixed = TRUE), LIB_LR_ASYMPT_COURT)
           }, TRUE)))
} else {
  cat("  note : plotly absent ; annotations q90 de l'objet plotly_build() non exercees (#195).\n")
}

## --- Vue Detail et annexe des tests exclus (issue #178) -----------------------
# Inverse de .echap_html() (trois entites), pour relire le texte d'une cellule.
desechap <- function(x) gsub("&amp;", "&", gsub("&gt;", ">", gsub("&lt;", "<", x, fixed = TRUE),
                                                   fixed = TRUE), fixed = TRUE)
# Texte rendu par une cellule de .commentaire_replie() : debut (summary) et
# suite (corps du details), rejoints par l'espace de coupure ; tiret : NA.
# Phrase de #244 sortie du repli (pied) : retiree, puis rejointe au texte
# relu selon la regle de jonction d'add() (" " apres un point final, " ; "
# sinon). Phrase seule dans la cellule : SPAN244 sans <br> (remarque
# d'app-review sur #244).
SPAN244 <- paste0("<span style='color:#B9770E;font-weight:600;font-size:11px'>",
                  .echap_html(PHRASE_VERDICT_SENSIBLE_MC), "</span>")
PIED244 <- paste0("<br>", SPAN244)
relire_com <- function(cel) vapply(cel, function(x) {
  if (identical(x, "–")) return(NA_character_)
  if (identical(x, SPAN244)) return(PHRASE_VERDICT_SENSIBLE_MC)
  if (endsWith(x, PIED244)) {
    b <- relire_com(substr(x, 1L, nchar(x) - nchar(PIED244)))
    return(paste0(b, if (grepl("\\.$", b)) " " else " ; ", PHRASE_VERDICT_SENSIBLE_MC))
  }
  if (!nzchar(x)) return("")
  m <- regmatches(x, regexec("^<details class='com'><summary>(.*)</summary>(.*)</details>$", x))[[1]]
  if (!length(m)) return(desechap(x))
  d <- desechap(m[2]); r <- desechap(m[3])
  # Coupure au seuil sans espace : rien entre les deux parties.
  if (nchar(d) == 200L) paste0(d, r) else paste(d, r)
}, character(1), USE.NAMES = FALSE)

for (cas in list(list(nom = "lognormale", tb = tb), list(nom = "MW", tb = tbm))) {
  t1 <- cas$tb
  com1 <- t1$commentaire; com1[!is.na(com1) & !nzchar(trimws(com1))] <- NA_character_
  dr <- table_detail_groupe(t1, replier = TRUE); dp <- table_detail_groupe(t1)
  cel <- dr[["Motif / commentaire"]]
  # Longueur comptee sans la phrase de #244 ni sa jonction, sortie du repli.
  sans244 <- ifelse(!is.na(com1) & endsWith(com1, PHRASE_VERDICT_SENSIBLE_MC),
                    sub("[ ;]+$", "", substr(com1, 1L, nchar(com1) - nchar(PHRASE_VERDICT_SENSIBLE_MC))),
                    com1)
  long <- !is.na(com1) & nchar(sans244) > 200L
  verifier(sprintf("Vue Detail (%s) : commentaire long replie (<details>), court en clair, aucun texte retire (#178)", cas$nom),
           any(long) && all(startsWith(cel[long], "<details class='com'><summary>")) &&
           !any(grepl("<details", cel[!long], fixed = TRUE)) &&
           identical(relire_com(cel), unname(com1)) &&
           all(nchar(vapply(regmatches(cel[long], regexec("<summary>(.*)</summary>", cel[long])),
                            function(m) desechap(m[2]), "")) <= 200L))
  verifier(sprintf("Vue Detail (%s) : replier = FALSE (rapport fige) rend le texte entier, sans <details> (#178)", cas$nom),
           identical(dp[["Motif / commentaire"]], unname(.txt(com1))) &&
           identical(dp[names(dp) != "Motif / commentaire"], dr[names(dr) != "Motif / commentaire"]))
  verifier(sprintf("Vue Detail (%s) : colonne Fonction = champ fonction de chaque ligne, en <code> (#178, #111)", cas$nom),
           identical(names(dr)[ncol(dr)], "Fonction") && !anyNA(t1$fonction) &&
           identical(dr$Fonction, paste0("<code>", t1$fonction, "</code>")))
}
verifier(".commentaire_replie() : coupure au dernier espace avant le seuil, au seuil sans espace, echappement par partie (#178)",
         {
           x1 <- paste(c(rep("mot", 60), "a < b"), collapse = " ")   # 245 caracteres
           x2 <- strrep("x", 450)
           x3 <- strrep("y", 200)
           cr <- .commentaire_replie(c(x1, x2, x3, NA))
           identical(relire_com(cr[1:3]), c(x1, x2, x3)) && identical(cr[3], x3) &&
             identical(cr[4], "–") && grepl("a &lt; b</details>$", cr[1]) &&
             identical(cr[2], paste0("<details class='com'><summary>", strrep("x", 200),
                                     "</summary>", strrep("x", 250), "</details>"))
         })
# Phrase de #244 (decision du mainteneur : sortie du repli) : cas long, Origine
# de reserve2 (314 caracteres, phrase au-dela du seuil de 200) ; cas court,
# Grubbs de premium_interieur (128 caracteres) ; phrase seule : detail
# synthetique egal a PHRASE_VERDICT_SENSIBLE_MC (depuis #299, homogeneite des
# dispersions de premium, source de ce cas, est un diagnostic par decision
# sans la phrase de #244, et aucune ligne des references n'a plus un detail
# reduit a la seule phrase ; cas d'add() a detail vide, U244-8 de
# test_verdict_sensible_mc.R). Ligne designee par son nom de test (#302 : un
# retrait de lignes decale les indices), une et une seule par reference
# (erreur sinon).
ref244 <- function(cas, nom) {
  l <- Filter(function(l) identical(l$test, nom),
              readRDS(file.path(.racine, "tests", "reference", paste0(cas, ".rds")))$tests)
  if (length(l) != 1L) stop("ref244 : ", length(l), " ligne(s) '", nom, "' dans ", cas)
  l[[1]]$detail
}
verifier(".commentaire_replie() : phrase de #244 hors du <details>, en pied, texte relu entier (#244, #178)",
         {
           x_long <- ref244("reserve2", "Nullite de l'ordonnee a l'origine, colonne par colonne")
           x_court <- ref244("premium_interieur", "Valeur aberrante isolee (Grubbs)")
           x_seul <- PHRASE_VERDICT_SENSIBLE_MC
           cr <- .commentaire_replie(c(x_long, x_court, x_seul))
           nchar(x_long) > 200L && endsWith(x_long, PHRASE_VERDICT_SENSIBLE_MC) &&
             startsWith(cr[1], "<details class='com'><summary>") &&
             endsWith(cr[1], paste0("</details>", PIED244)) &&
             !grepl("alea de simulation", sub(PIED244, "", cr[1], fixed = TRUE), fixed = TRUE) &&
             identical(cr[2], paste0(.echap_html(sub(paste0(" ; ", PHRASE_VERDICT_SENSIBLE_MC), "",
                                                     x_court, fixed = TRUE)), PIED244)) &&
             !grepl("<details", cr[2], fixed = TRUE) &&
             identical(cr[3], SPAN244) && !grepl("<br>", cr[3], fixed = TRUE) &&
             identical(relire_com(cr), c(x_long, x_court, x_seul))
         })
verifier("Garde : table sans colonne fonction -> tiret dans la colonne Fonction (#178)",
         { tbf <- tb; tbf$fonction <- NULL; all(table_detail_groupe(tbf)$Fonction == "–") })
# Colonne "p min MC" de la vue Detail (plancher Monte-Carlo p_min_mc, #125,
# constat C1 d'app-review sur E2b) : sur premium_interieur, la ligne
# "Tendance par signes du ratio S/P" est un test inoperant dont la bascule R1
# lit p_min_mc = 0,149 (test_plancher_mc.R, U125-6), alors que la p minimale
# de la loi discrete vaut 0,125. Meme fonction dans l'application (vue
# Detail, replier = TRUE) et dans le rapport fige (section 5).
res_pi <- readRDS(file.path(.racine, "tests", "reference", "premium_interieur.rds"))
tb_pi <- engine_table_tests(res_pi)
nom_signes <- "Tendance par signes du ratio S/P"
i_signes <- match(nom_signes, tb_pi$test)
verifier("Vue Detail : colonnes \"p min (loi discr\u00e8te)\" puis \"p min MC\", 0,125 et 0,149 sur la ligne inoperante des signes (premium_interieur, #125)",
         {
           dd <- table_detail_groupe(tb_pi, replier = TRUE)
           j <- match("p min (loi discr\u00e8te)", names(dd))
           !is.na(i_signes) && isTRUE(tb_pi$inoperant[i_signes]) && !is.na(j) &&
             identical(names(dd)[j + 1L], "p min MC") &&
             identical(dd[i_signes, j], "0,125") && identical(dd[["p min MC"]][i_signes], "0,149") &&
             identical(dd[["p min MC"]] == "\u2013", !is.finite(tb_pi$p_min_mc)) &&
             identical(dd[names(dd) != "Motif / commentaire"],
                       table_detail_groupe(tb_pi)[names(dd) != "Motif / commentaire"])
         })
verifier("Garde : table sans colonne p_min_mc -> tiret dans la colonne p min MC (#125)",
         { tbf <- tb_pi; tbf$p_min_mc <- NULL; all(table_detail_groupe(tbf)[["p min MC"]] == "\u2013") })
# Le rapport fige est produit sur la reference versionnee, lue sans recalcul :
# les champs de metadata qu'en retire nettoyer() (horodatage, duree, version
# de R) s'affichent en tiret depuis #263.
verifier("Rapport fige (reference premium_interieur) : en-tetes p min et p min MC, 0,125 et 0,149 sur la ligne des signes (#125)",
         {
           f_pi <- tempfile(fileext = ".html")
           rapport_html(res_pi, selection_defaut(tb_pi), f_pi, interactif = FALSE, identite = idt)
           h_pi <- lire(f_pi); unlink(f_pi)
           pr_pi <- entre(h_pi, "<section id='section-tests-retenus'>", "</section>")
           l_pi <- ligne_de(pr_pi, nom_signes)
           grepl("<th>p min (loi discr\u00e8te)</th><th>p min MC</th>", pr_pi, fixed = TRUE) &&
             # Deux lignes portent le test : Synthese puis Detail ; seule la
             # seconde a les colonnes p min.
             length(l_pi) == 2L && grepl("<td>0,125</td><td>0,149</td>", l_pi[2], fixed = TRUE)
         })
verifier("Rapport : colonne Fonction dans le detail des tests retenus, commentaire en entier, aucun <details> (#178)",
         all(vapply(which(retenu), function(k)
           any(grepl(paste0("<td><code>", tb$fonction[k], "</code></td></tr>"),
                     ligne_de(principal, tb$test[k]), fixed = TRUE)), logical(1))) &&
         compte(h, "<details") == 0)
# Annexe des tests exclus : commentaire du moteur, comme dans l'onglet Tests.
com_attendu <- function(t1, k) {
  x <- t1$commentaire[k]; if (is.na(x) || !nzchar(trimws(x))) "–" else .echap_html(x)
}
verifier("Rapport : annexe des tests exclus avec la colonne Commentaire du moteur, texte entier echappe (#178)",
         grepl("<th>Motif</th><th>Commentaire du moteur</th></tr>", annexe, fixed = TRUE) &&
         all(vapply(which(!retenu), function(k)
           endsWith(ligne_de(annexe, tb$test[k]),
                    paste0("<td>", com_attendu(tb, k), "</td></tr>")), logical(1))) &&
         any(nchar(tb$commentaire[!retenu]) > 200L, na.rm = TRUE))
verifier("Rapport MW : annexe des tests exclus avec le commentaire du moteur (#178)",
         {
           ax <- entre(hm, "<section id='section-annexe-exclus'>", "</section>")
           all(vapply(which(!rm), function(k)
             endsWith(ligne_de(ax, tbm$test[k]),
                      paste0("<td>", com_attendu(tbm, k), "</td></tr>")), logical(1)))
         })
verifier("Rapport : encadre de personnalisation annonce le commentaire du moteur en annexe (#178)",
         grepl("verdict, le commentaire du moteur et le motif de leur exclusion", principal, fixed = TRUE))

## --- Objet rbind de l'environnement global (issue #199) ---------------------
# do.call() evalue son premier argument comme une valeur : un objet non
# fonction rbind de l'environnement global (ou display_helpers.R est source)
# masquait base::rbind dans la table des controles de rapport_html(), alors
# qu'un appel rbind(...) ordinaire l'ignore (meme defaut que #179 dans le
# moteur). Mordant : avant le passage en base::rbind, rapport_html() echoue
# ("'what' must be a function or character string"). La section 3 est
# comparee seule, l'horodatage du rapport changeant d'un appel a l'autre.
verifier("Objet non fonction rbind dans l'environnement global : section Controles du rapport identical a celle calculee sans lui (#199)",
         {
           genv <- globalenv()
           stopifnot(!exists("rbind", envir = genv, inherits = FALSE))
           sect <- function(f) entre(lire(f), "<h2 id='controles'>", "</table>")
           f0 <- tempfile(fileext = ".html"); f5 <- tempfile(fileext = ".html")
           rapport_html(res_ln, NULL, f0, interactif = FALSE, identite = idt)
           assign("rbind", 5, envir = genv)
           r5 <- tryCatch(rapport_html(res_ln, NULL, f5, interactif = FALSE, identite = idt),
                          error = function(e) e,
                          finally = rm(list = "rbind", envir = genv))
           !inherits(r5, "error") && grepl("<table", sect(f0), fixed = TRUE) &&
             identical(sect(f5), sect(f0))
         })

## --- Ligne "P-values Monte-Carlo" (issue #240, Q-A4-12 (B)) ------------------
# texte_p_mc_regime() lit res$bootstrap$p_mc_regime sans calcul ; la ligne
# est ecrite dans la section 1 du rapport fige, apres la granularite et avant
# le seuil alpha, et absente pour reserve2 et pour un objet sans p_mc_regime.
# Jeux : res_ln (delta estime au bord 1, V1) ; donnees_ln_interieur.csv (J2,
# interieur, V3b, arret a la cible : 510 tirages, mesure du 11/10/2026) ;
# replication b = 1455 de #229 sur les volumes de donnees_ln.csv (interieur,
# regime interieur rare : arret a B_max = 2500 tirages, 97 retenus) ; volumes
# constants rep(110, 8) (delta estime au bord 0, motif volumes constants
# prioritaire sur le bord, decision du 11/10/2026) ; p_mc_regime au motif
# "volumes constants" pose a la main (delta estime interieur a volumes
# constants non atteint par usp_ajuster(), qui n'y libere jamais delta) ;
# res_mw (reserve2).
.lancer_ln <- function(x, y) run_engine(xt = x, yt = y, methode = "premium", segment = 1,
                                        B = 99, nature_donnees = "brutes")
.ln_int <- utils::read.csv(file.path(.racine, "tests", "donnees", "donnees_ln_interieur.csv"))
.ln_j1 <- utils::read.csv(file.path(.racine, "tests", "donnees", "donnees_ln.csv"))
res_cible <- .lancer_ln(.ln_int$xt, .ln_int$yt)
res_bmax <- .lancer_ln(.ln_j1$xt, c(80.061271676886193, 62.506419725192131, 75.947508440386684,
  73.078214305038301, 81.70127631154007, 88.287475207907406, 89.71478845147162, 107.19756511252216))
res_vc <- .lancer_ln(rep(110, 8), yt)
res_vc_motif <- res_cible
res_vc_motif$bootstrap$p_mc_regime <- modifyList(res_cible$bootstrap$p_mc_regime, list(
  regime_obs = "interieur", variante = "V1",
  motif_v1 = "volumes constants : regime de delta non identifie",
  B_cible = NA_real_, B_max = NA_real_, tirages = 99, retenus_v1 = NA_real_, retenus = NA_real_,
  rejets_flux = c(reajustement = NA_real_, hors_regime = NA_real_, statistiques = NA_real_),
  arret = NA_character_))
res_sans <- res_cible
res_sans$bootstrap$p_mc_regime <- NULL
TXT_CIBLE <- paste("conditionnelles au r\u00e9gime int\u00e9rieur de delta estim\u00e9 \u2014",
                   "510 tirages, 99 retenus, arr\u00eat \u00e0 la cible (B = 99 retenus)")
TXT_BMAX <- paste("conditionnelles au r\u00e9gime int\u00e9rieur de delta estim\u00e9 \u2014",
                  "2500 tirages, 97 retenus, arr\u00eat \u00e0 B_max (2500 tirages),",
                  "cible B = 99 non atteinte ; granularit\u00e9 effective par statistique :",
                  "colonne \u00ab granularit\u00e9 MC \u00bb du d\u00e9tail des tests,",
                  "plus grossi\u00e8re que la granularit\u00e9 nominale")
# Mention de la granularite effective (#254) : en V3b arrete a B_max seulement.
MENTION_254 <- "granularit\u00e9 effective par statistique"
verifier("p_mc_regime : jeux au contrat attendu (V3b cible, V3b B_max, V1 bord 1, V1 bord 0, reserve2 sans champ)",
         identical(res_cible$bootstrap$p_mc_regime[c("variante", "tirages", "retenus", "arret")],
                   list(variante = "V3b", tirages = 510, retenus = 99, arret = "cible")) &&
           identical(res_bmax$bootstrap$p_mc_regime[c("variante", "tirages", "retenus", "arret")],
                     list(variante = "V3b", tirages = 2500, retenus = 97, arret = "B_max")) &&
           identical(res_ln$bootstrap$p_mc_regime[c("regime_obs", "variante")],
                     list(regime_obs = "bord1", variante = "V1")) &&
           identical(res_vc$bootstrap$p_mc_regime[c("regime_obs", "variante", "motif_v1")],
                     list(regime_obs = "bord0", variante = "V1",
                          motif_v1 = "volumes constants : regime de delta non identifie")) &&
           is.null(res_mw$bootstrap$p_mc_regime))
verifier("texte_p_mc_regime() : V3b, arret a la cible (tirages, retenus, B)",
         identical(texte_p_mc_regime(res_cible), TXT_CIBLE))
verifier("texte_p_mc_regime() : V3b, arret a B_max (tirages, retenus, B_max, cible non atteinte)",
         identical(texte_p_mc_regime(res_bmax), TXT_BMAX))
verifier("texte_p_mc_regime() : V1, delta estime au bord 1",
         identical(texte_p_mc_regime(res_ln),
                   "marginales, sur les 99 tirages (delta estim\u00e9 au bord 1)"))
verifier("texte_p_mc_regime() : V1, volumes constants (delta estime au bord 0, motif volumes constants prioritaire)",
         identical(texte_p_mc_regime(res_vc), paste(
           "marginales, sur les 99 tirages (volumes constants : r\u00e9gime de delta non",
           "identifi\u00e9)")))
verifier("texte_p_mc_regime() : V1, motif volumes constants (p_mc_regime pose a la main)",
         identical(texte_p_mc_regime(res_vc_motif), paste(
           "marginales, sur les 99 tirages (volumes constants : r\u00e9gime de delta non",
           "identifi\u00e9)")))
verifier("texte_p_mc_regime() : objet sans p_mc_regime -> NULL, sans erreur",
         is.null(texte_p_mc_regime(res_sans)))
verifier("texte_p_mc_regime() : reserve2 -> NULL, sans erreur",
         is.null(texte_p_mc_regime(res_mw)))
# #254 : mention de la granularite effective en V3b arrete a B_max seulement.
# Le jeu res_bmax arrete a B_max (97 retenus) a toutes ses granularite_stat
# au-dessus de la granularite nominale 1/(B+1) (contrat de la mention) ; un
# arret "B_max" pose a la main sous V1 (champ arret ignore hors V3b) ne la
# produit pas.
res_v1_bmax <- res_ln
res_v1_bmax$bootstrap$p_mc_regime$arret <- "B_max"
verifier("#254 : granularite_stat > granularite nominale sur le jeu arrete a B_max",
         { g <- res_bmax$bootstrap$granularite_stat
           all(is.finite(g)) && all(g > res_bmax$bootstrap$granularite) })
verifier("#254 : mention de la granularite effective en V3b, arret a B_max",
         compte(texte_p_mc_regime(res_bmax), MENTION_254) == 1L)
verifier("#254 : mention absente en V3b arret a la cible, en V1 (bord 1, volumes constants, arret B_max pose a la main), reserve2 et sans p_mc_regime",
         !grepl(MENTION_254, texte_p_mc_regime(res_cible), fixed = TRUE) &&
           !grepl(MENTION_254, texte_p_mc_regime(res_ln), fixed = TRUE) &&
           !grepl(MENTION_254, texte_p_mc_regime(res_vc), fixed = TRUE) &&
           !grepl(MENTION_254, texte_p_mc_regime(res_vc_motif), fixed = TRUE) &&
           !grepl(MENTION_254, texte_p_mc_regime(res_v1_bmax), fixed = TRUE) &&
           is.null(texte_p_mc_regime(res_mw)) && is.null(texte_p_mc_regime(res_sans)))
# Section 1 du rapport fige (en-tete de gel).
.sect_gel <- function(res) {
  f <- tempfile(fileext = ".html")
  rapport_html(res, NULL, f, interactif = FALSE, identite = idt)
  entre(lire(f), "<h2 id='gel'>", "<h3>Empreintes</h3>")
}
.ligne_mc <- function(sect, texte) {
  i_gran <- regexpr("granularit\u00e9 MC \u00bb du d\u00e9tail des tests)", sect, fixed = TRUE)
  i_mc <- regexpr(paste0("<td>P-values Monte-Carlo</td><td>", .echap_html(texte), "</td>"),
                  sect, fixed = TRUE)
  i_alpha <- regexpr("Seuil alpha des verdicts", sect, fixed = TRUE)
  i_gran > 0 && i_mc > i_gran && i_alpha > i_mc && compte(sect, "P-values Monte-Carlo") == 1L
}
verifier("rapport fige : ligne P-values Monte-Carlo (V3b, cible) entre la granularite et le seuil alpha",
         .ligne_mc(.sect_gel(res_cible), TXT_CIBLE))
verifier("rapport fige : ligne P-values Monte-Carlo (V3b, B_max)",
         .ligne_mc(.sect_gel(res_bmax), TXT_BMAX))
verifier("rapport fige : mention de la granularite effective (#254) en V3b arrete a B_max seulement",
         compte(.sect_gel(res_bmax), MENTION_254) == 1L &&
           all(vapply(list(res_cible, res_ln, res_vc, res_v1_bmax, res_sans, res_mw),
                      function(r) !grepl(MENTION_254, .sect_gel(r), fixed = TRUE), TRUE)))
verifier("rapport fige : ligne P-values Monte-Carlo (V1, bord 1)",
         .ligne_mc(.sect_gel(res_ln), texte_p_mc_regime(res_ln)))
verifier("rapport fige : ligne P-values Monte-Carlo (V1, volumes constants)",
         .ligne_mc(.sect_gel(res_vc), texte_p_mc_regime(res_vc)))
verifier("rapport fige : objet sans p_mc_regime, rapport ecrit sans la ligne",
         { s0 <- .sect_gel(res_sans)
           nzchar(s0) && grepl("Seuil alpha des verdicts", s0, fixed = TRUE) &&
             !grepl("P-values Monte-Carlo", s0, fixed = TRUE) })
verifier("rapport fige : reserve2, rapport ecrit sans la ligne",
         { s0 <- .sect_gel(res_mw)
           nzchar(s0) && grepl("Seuil alpha des verdicts", s0, fixed = TRUE) &&
             !grepl("P-values Monte-Carlo", s0, fixed = TRUE) })
# Graine du flux (metadata$seed_flux_regime, #240) : valeurs_generateur() et
# ligne de l'en-tete, libelle de lib_gen (un libelle manquant s'ecrirait NA).
LIB_FLUX <- paste("Graine du flux compl\u00e9mentaire des p-values Monte-Carlo",
                  "(r\u00e9gime int\u00e9rieur de delta estim\u00e9)")
verifier("valeurs_generateur() : seed_flux_regime = \"20800000\" en primes (V1 et V3b), absent en reserve2",
         identical(valeurs_generateur(res_ln$metadata)[["seed_flux_regime"]], "20800000") &&
           identical(valeurs_generateur(res_cible$metadata)[["seed_flux_regime"]], "20800000") &&
           identical(names(valeurs_generateur(res_ln$metadata)),
                     c("generateur", "seed_loi_nulle_sw", "seed_flux_regime")) &&
           !("seed_flux_regime" %in% names(valeurs_generateur(res_mw$metadata))))
verifier("valeurs_generateur() : seed_flux_regime ecrit sans notation scientifique (-2146944479)",
         identical(valeurs_generateur(list(seed_flux_regime = -2146944479))[["seed_flux_regime"]],
                   "-2146944479"))
verifier("rapport fige : ligne de la graine du flux (libelle et valeur), aucune cle NA",
         { s0 <- .sect_gel(res_cible)
           grepl(paste0("<td>", .echap_html(LIB_FLUX), "</td><td>20800000</td>"), s0, fixed = TRUE) &&
             !grepl("<td>NA</td>", s0, fixed = TRUE) })
verifier("rapport fige : reserve2, pas de ligne de la graine du flux",
         !grepl("Graine du flux", .sect_gel(res_mw), fixed = TRUE))

# Objet relu et nettoye (#263) : les six references de tests/reference/, sans
# horodatage, duree_sec ni version_R dans metadata, donnent un rapport sans
# erreur, avec un tiret dans les lignes de ces champs ; titre sans "NULL".
# Valeur de la ligne `cle` de la table cle-valeur de l'en-tete (motif fixe).
cle_val <- function(s, cle) {
  debut <- paste0("<td>", .echap_html(cle), "</td><td>")
  i <- regexpr(debut, s, fixed = TRUE)
  if (i < 0) return(NA_character_)
  reste <- substr(s, i + nchar(debut), nchar(s))
  substr(reste, 1, regexpr("</td>", reste, fixed = TRUE) - 1L)
}
CLES_263 <- c("Horodatage du calcul (run_engine)", "Dur\u00e9e du calcul", "Version de R")
REFS_263 <- sort(list.files(file.path(.racine, "tests", "reference"), "[.]rds$", full.names = TRUE))
verifier("Six references dans tests/reference/ pour le rapport fige (#263)", length(REFS_263) == 6L)
for (f_ref in REFS_263) {
  verifier(sprintf("Rapport fige sur la reference %s : sans erreur, tiret pour horodatage, duree et version de R (#263)",
                   basename(f_ref)),
           {
             r0 <- readRDS(f_ref)
             f0 <- tempfile(fileext = ".html")
             ok0 <- tryCatch({
               rapport_html(r0, NULL, f0, interactif = FALSE, identite = idt); TRUE
             }, error = function(e) FALSE)
             h0 <- if (ok0) lire(f0) else ""; unlink(f0)
             g0 <- entre(h0, "<h2 id='gel'>", "</table>")
             ok0 && all(!c("horodatage", "duree_sec", "version_R") %in% names(r0$metadata)) &&
               identical(unname(vapply(CLES_263, cle_val, "", s = g0)), rep("\u2013", 3L)) &&
               grepl("calcul du \u2013</title>", h0, fixed = TRUE) &&
               !grepl(">NULL<", h0, fixed = TRUE)
           })
}

# Marges du test d'equivalence de la constante (revue de #263) : un objet
# lognormal sans theta_equiv (ou avec un delta_equiv vide) donne un rapport
# sans erreur et un tiret a la place de la marge, comme les autres champs de
# metadata absents.
CLE_EQUIV <- "Test d'\u00e9quivalence de la constante"
verifier("Rapport fige : marge theta_equiv absente -> tiret, sans erreur (revue de #263)",
         {
           r0 <- readRDS(file.path(.racine, "tests", "reference", "premium.rds"))
           r0$metadata$theta_equiv <- NULL
           f0 <- tempfile(fileext = ".html")
           ok0 <- tryCatch({
             rapport_html(r0, NULL, f0, interactif = FALSE, identite = idt); TRUE
           }, error = function(e) FALSE)
           h0 <- if (ok0) lire(f0) else ""; unlink(f0)
           ok0 && identical(cle_val(entre(h0, "<h2 id='gel'>", "</table>"), CLE_EQUIV),
                            .echap_html("marge = \u2013 de la perte moyenne (theta_equiv)"))
         })
verifier("Rapport fige : marge theta_equiv presente -> valeur inchangee (0,1, virgule decimale #236)",
         {
           f0 <- tempfile(fileext = ".html")
           rapport_html(res_ln, NULL, f0, interactif = FALSE, identite = idt)
           h0 <- lire(f0); unlink(f0)
           identical(cle_val(entre(h0, "<h2 id='gel'>", "</table>"), CLE_EQUIV),
                     "marge = 0,1 de la perte moyenne (theta_equiv)")
         })
verifier("Rapport fige : marge delta_equiv de longueur nulle -> tiret, sans erreur",
         {
           r0 <- readRDS(file.path(.racine, "tests", "reference", "premium.rds"))
           r0$metadata$delta_equiv <- numeric(0)
           f0 <- tempfile(fileext = ".html")
           ok0 <- tryCatch({
             rapport_html(r0, NULL, f0, interactif = FALSE, identite = idt); TRUE
           }, error = function(e) FALSE)
           h0 <- if (ok0) lire(f0) else ""; unlink(f0)
           ok0 && identical(cle_val(entre(h0, "<h2 id='gel'>", "</table>"), CLE_EQUIV),
                            .echap_html("marge Delta fix\u00e9e a priori = \u2013"))
         })

# Champ present mais NA (revue finale de #263) : tiret, et non "NA" ou
# "NA s". Mesure avant correction (14/10/2026) : reference premium avec
# duree_sec, alpha et bootstrap$granularite a NA -> "NA s", "NA", "NA".
CLE_GRAN <- paste("Granularit\u00e9 nominale d'une p-value Monte-Carlo unilat\u00e9rale,",
                  "1/(B+1) sur B nominal (bilat\u00e9rale : 2/(B_eff+1), par statistique,",
                  "colonne \u00ab granularit\u00e9 MC \u00bb du d\u00e9tail des tests)")
verifier("Rapport fige : duree_sec, alpha et granularite a NA -> tiret, ni \"NA\" ni \"NA s\" (revue de #263)",
         {
           r0 <- readRDS(file.path(.racine, "tests", "reference", "premium.rds"))
           r0$metadata$duree_sec <- NA_real_; r0$metadata$alpha <- NA_real_
           r0$bootstrap$granularite <- NA_real_
           f0 <- tempfile(fileext = ".html")
           ok0 <- tryCatch({
             rapport_html(r0, NULL, f0, interactif = FALSE, identite = idt); TRUE
           }, error = function(e) FALSE)
           h0 <- if (ok0) lire(f0) else ""; unlink(f0)
           g0 <- entre(h0, "<h2 id='gel'>", "</table>")
           ok0 && identical(unname(vapply(c("Dur\u00e9e du calcul", "Seuil alpha des verdicts", CLE_GRAN),
                                          cle_val, "", s = g0)), rep("\u2013", 3L))
         })
verifier(".ou_tiret() : NA scalaire -> tiret avant f(), valeur finie -> f(x), vecteur garde la regle de longueur (revue de #263)",
         identical(.ou_tiret(NA_real_, function(x) paste(.num_fr(x, "%.2f"), "s")), "\u2013") &&
           identical(.ou_tiret(NA, function(x) .num_fr(x, digits = 7)), "\u2013") &&
           identical(.ou_tiret(as.POSIXct(NA)), "\u2013") &&
           identical(.ou_tiret(6.137, function(x) paste(.num_fr(x, "%.2f"), "s")), "6,14 s") &&
           identical(.ou_tiret(c(1, NA), function(x) "deux"), "deux") &&
           identical(.ou_tiret(c(1, 2), function(x) c("a", "b")), "\u2013"))

## --- Granularite effective par ligne (#285, option (i)) ----------------------
# La colonne "granularite MC" du detail des tests est lue dans
# bootstrap$granularite_stat par granularite_lignes(), qui lit la statistique
# de la ligne dans la colonne mc_nom d'engine_table_tests() (#330, posee par
# add()). Verite independante : le mc_nom passe a add() pour chaque ligne,
# releve en enveloppant add() le temps d'un calcul (engine_registre_tests()
# de l'environnement global, restauree en sortie) sur le jeu de res_bmax
# (V3b arrete a B_max, granularites 1/98 et 2/98). L'enveloppe a pour
# environnement celui du moteur : add() y verifie son argument fonction
# (exists(..., environment(engine_registre_tests), inherits = FALSE)) ; son
# etat (.etat285) est donc pose dans cet environnement le temps du calcul,
# puis retire avec la restauration (la batterie source chaque fichier dans
# un environnement enfant, invisible depuis celui du moteur).
.mc_nom_lignes <- function(expr) {
  env <- environment(engine_registre_tests)
  etat <- new.env(); etat$orig <- engine_registre_tests; etat$vus <- list()
  enveloppe <- function(...) {
    r <- .etat285$orig(...); a <- r$add; e <- .etat285
    k <- length(e$vus) + 1L; e$vus[[k]] <- character(0)
    r$add <- function(...) {
      m <- list(...)$mc_nom
      e$vus[[k]] <- c(e$vus[[k]], if (is.null(m)) NA_character_ else m)
      a(...)
    }
    r
  }
  environment(enveloppe) <- env
  assign(".etat285", etat, envir = env)
  assign("engine_registre_tests", enveloppe, envir = env)
  on.exit({ assign("engine_registre_tests", etat$orig, envir = env)
            rm(".etat285", envir = env) }, add = TRUE)
  res <- expr
  list(res = res, mc_nom = etat$vus)
}
.erg285 <- engine_registre_tests
.m285 <- .mc_nom_lignes(.lancer_ln(.ln_j1$xt, res_bmax$donnees$yt))
.r285 <- .m285$res; .mc285 <- .m285$mc_nom[[length(.m285$mc_nom)]]
.tb285 <- engine_table_tests(.r285)
.g285 <- granularite_lignes(.tb285, .r285$bootstrap)
.vrai285 <- vapply(.mc285, function(m) if (is.na(m)) NA_real_
                   else unname(.r285$bootstrap$granularite_stat[[m]]), numeric(1), USE.NAMES = FALSE)
verifier("#285 : jeu de res_bmax rejoue a l'identique, un mc_nom releve par ligne",
         identical(.r285$bootstrap$granularite_stat, res_bmax$bootstrap$granularite_stat) &&
           length(.m285$mc_nom) == 1L && length(.mc285) == nrow(.tb285) &&
           identical(get("engine_registre_tests", envir = environment(.erg285)), .erg285) &&
           !exists(".etat285", envir = environment(.erg285), inherits = FALSE))
verifier("#285 : granularite_lignes() = granularite_stat de la statistique de chaque ligne (31 lignes depuis les retraits de LB1r, #303, et de LB1 et BP2, #302), tiret sans statistique du bootstrap (16 depuis le retrait de Shapiro-Wilk a loi nulle simulee, #302)",
         identical(is.finite(.g285), is.finite(.vrai285)) &&
           identical(.g285[is.finite(.g285)], .vrai285[is.finite(.vrai285)]) &&
           sum(is.finite(.g285)) == 31L && sum(!is.finite(.g285)) == 16L &&
           setequal(round(.g285[is.finite(.g285)] * 98), c(1, 2)))
verifier("#330 : colonne mc_nom d'engine_table_tests() = mc_nom passe a add() pour chaque ligne",
         identical(.tb285$mc_nom, unname(.mc285)))
verifier("#285, #330 : lignes a p Monte-Carlo externe (usp_lr_delta) en tiret, mc_nom NA",
         { k <- .tb285$fonction %in% c("usp_lr_delta", "usp_permutation_pente")
           any(k) && any(is.finite(.tb285$p_monte_carlo[k])) && all(is.na(.tb285$mc_nom[k])) &&
             all(is.na(.g285[k])) })
verifier("#285 : colonne granularite MC du detail apres p min MC, valeurs lues en %.3g, tiret sans boot",
         { d <- table_detail_groupe(.tb285, boot = .r285$bootstrap)
           d0 <- table_detail_groupe(.tb285)
           j <- match("p min MC", names(d))
           identical(names(d)[j + 1L], "granularité MC") &&
             identical(d[["granularité MC"]],
                       ifelse(is.finite(.g285), .num_fr(.g285, "%.3g"), "–")) &&
             all(c("0,0102", "0,0204") %in% d[["granularité MC"]]) &&
             all(d0[["granularité MC"]] == "–") &&
             identical(d[names(d) != "granularité MC"], d0[names(d0) != "granularité MC"]) })
# Avant #330, deux statistiques de meme p et de meme erreur Monte-Carlo
# rendaient l'appariement ambigu (tiret) : la lecture par mc_nom n'en depend
# plus ; seule la granularite de la statistique de la ligne compte.
verifier("#330 : granularite lue par mc_nom, independante des autres statistiques de meme p et de meme erreur",
         { b <- .r285$bootstrap; i <- which(is.finite(.g285))[1]; m <- .mc285[i]
           autre <- setdiff(names(b$p_mc), m)[1]
           b$p_mc[[autre]] <- b$p_mc[[m]]; b$err_mc[[autre]] <- b$err_mc[[m]]
           b$granularite_stat[[autre]] <- b$granularite_stat[[m]] + 0.5
           identical(granularite_lignes(.tb285, b)[i], .g285[i]) &&
             { b$granularite_stat[[m]] <- 0.25
               identical(granularite_lignes(.tb285, b)[i], 0.25) } })
verifier("#285, #330 : objet sans granularite_stat ou table sans colonne mc_nom -> tiret partout, sans erreur",
         { b <- .r285$bootstrap; b$granularite_stat <- NULL
           tbf <- .tb285; tbf$mc_nom <- NULL
           all(is.na(granularite_lignes(.tb285, b))) && all(is.na(granularite_lignes(tbf, .r285$bootstrap))) })
verifier("#330 : appariement retire, FONCTIONS_P_MC_EXTERNE absente de R/display_helpers.R ; granularite non finie -> tiret",
         { src <- readLines(file.path(.racine, "R", "display_helpers.R"), encoding = "UTF-8")
           b <- .r285$bootstrap; i <- which(is.finite(.g285))[1]
           b$granularite_stat[[.mc285[i]]] <- NA_real_
           !any(grepl("FONCTIONS_P_MC_EXTERNE", src, fixed = TRUE)) &&
             !exists("FONCTIONS_P_MC_EXTERNE") && is.na(granularite_lignes(.tb285, b)[i]) })
verifier("#330 : ligne a mc_nom renseigne mais p Monte-Carlo non finie -> tiret",
         { i <- which(is.finite(.g285))[1]; tbn <- .tb285; tbn$p_monte_carlo[i] <- NA_real_
           is.na(granularite_lignes(tbn, .r285$bootstrap)[i]) &&
             identical(granularite_lignes(tbn, .r285$bootstrap)[-i], .g285[-i]) })
verifier("#285 : rapport fige, colonne granularite MC dans le detail des tests retenus (section 5)",
         { f <- tempfile(fileext = ".html")
           rapport_html(res_bmax, NULL, f, interactif = FALSE, identite = idt)
           s5 <- entre(lire(f), "<h2 id='tests-retenus'>", "</section>")
           grepl("<th>granularité MC</th>", s5, fixed = TRUE) &&
             grepl("<td>0,0204</td>", s5, fixed = TRUE) })

## --- Tres petites p-values (#323) ----------------------------------------------
# fmt_p() : "%.4f" a partir de 1e-4, "%.3g" en deca ; meme formateur pour
# l'onglet Tests et le rapport fige. Valeurs de l'issue : p exacte de Pitman
# 1/40320 = 2,48e-05 et p asymptotique 2,95e-06 sur premium_interieur.
verifier("#323 : fmt_p(), %.4f a partir de 1e-4, %.3g en deca, tiret pour NA et Inf",
         identical(fmt_p(c(0.5, 1e-4, 9.99e-5, 1 / 40320, 2.95e-6, NA, Inf, 1)),
                   c("0,5000", "0,0001", "9,99e-05", "2,48e-05", "2,95e-06", "–", "–", "1,0000")))
# Revue finale de R16 : frontiere de 1e-4 sans saut ("%.3g" ecrit "0,0001"
# sur [9,995e-5 ; 1e-4), comme "%.4f" a 1e-4) et p = 0 exactement au format
# de la colonne, "0,0000" (et non "0").
verifier("#323 : fmt_p(), frontiere de 1e-4 sans saut et p = 0 rendu 0,0000 (revue finale de R16)",
         identical(fmt_p(c(0, 9.9949e-5, 9.995e-5, 9.9995e-5, 1e-4, 1.00049e-4)),
                   c("0,0000", "9,99e-05", "0,0001", "0,0001", "0,0001", "0,0001")))
# p-value M1 de la note du graphique de l'ordonnee a l'origine (note_m1()) :
# meme formateur que l'onglet Tests (revue finale de R16) ; le survol plotly
# de plot_mw_origine() passe aussi par fmt_p() (non exerce sans plotly).
verifier("#323 : note_m1(), p-value M1 par fmt_p(), sans 0,0000 (revue finale de R16)",
         { nm <- note_m1(list(origine = data.frame(j = 1:3, p = c(0.3, 2.48e-5, 0.02))), 0.05)
           grepl("<b>j = 2</b> (p = 2,48e-05)", nm, fixed = TRUE) && !grepl("0,0000", nm, fixed = TRUE) })
verifier("#323 : premium_interieur, Pitman et Fisher sans 0,0000 (synthese et detail)",
         { tbp <- engine_table_tests(readRDS(file.path(.racine, "tests", "reference", "premium_interieur.rds")))
           i <- grep("^Test de Pitman sur la pente", tbp$test); j <- grep("^Test de Fisher", tbp$test)
           sy <- table_synthese_groupe(tbp); de <- table_detail_groupe(tbp)
           length(i) == 1L && length(j) == 1L &&
             identical(sy[["p retenue"]][i], "2,48e-05") && identical(de[["p exacte"]][i], "2,48e-05") &&
             identical(de[["p asympt."]][i], "2,95e-06") && identical(de[["p asympt."]][j], "5,91e-06") &&
             !any(c(sy[["p retenue"]], de[["p exacte"]], de[["p asympt."]], de[["p Monte-Carlo"]]) == "0,0000") })

## --- Statistique qui est une probabilite : M = min p_ij (#353, Q-D1-Fm-10) ----
# STAT_NOMS_PROBABILITE (affichage) est confrontee au stat_nom du moteur sur
# reserve2 ; une statistique de la liste s'affiche par fmt_p() (5,2e-9 n'est
# plus "0,0000"), toutes les autres par fmt_nb(). M vaut 0,1033 sur reserve2
# (reference) : l'affichage y est inchange.
tb353 <- engine_table_tests(readRDS(file.path(.racine, "tests", "reference", "reserve2.rds")))
i353 <- which(tb353$test == .MW_LIGNE_CELLULE_ABERRANTE)
verifier("#353 : le nom_statistique de la ligne des cellules aberrantes de reserve2 appartient a STAT_NOMS_PROBABILITE",
         length(i353) == 1L && tb353$nom_statistique[i353] %in% STAT_NOMS_PROBABILITE)
verifier("#353 : reserve2, M = min p_ij s'affiche par fmt_p() en synthese, comme avant (valeur >= 1e-4, 4 decimales)",
         { sy <- table_synthese_groupe(tb353)
           m <- tb353$statistique[i353]
           identical(sy$Statistique[i353],
                     paste0("<code>M = min p_ij</code> = ", fmt_p(m))) &&
             identical(sy$Statistique[i353],
                       paste0("<code>M = min p_ij</code> = ", fmt_nb(m))) })
verifier("#353 : ligne fabriquee a M = 5,2e-9 : \"5,2e-09\" en synthese, jamais \"0,0000\" ; une autre statistique reste en fmt_nb()",
         { tbf <- tb353[c(i353, which(tb353$test != .MW_LIGNE_CELLULE_ABERRANTE & is.finite(tb353$statistique) & !is.na(tb353$nom_statistique))[1L]), ]
           tbf$statistique[1L] <- 5.2e-9; tbf$statistique[2L] <- 5.2e-9
           sy <- table_synthese_groupe(tbf)
           identical(sy$Statistique[1L], "<code>M = min p_ij</code> = 5,2e-09") &&
             identical(sy$Statistique[2L],
                       paste0("<code>", tbf$nom_statistique[2L], "</code> = 0,0000")) })

## --- Virgule decimale des nombres affiches (issue #236) ------------------------
# .num_fr() ecrit le nombre comme avant (sprintf(fmt, x), ou format(x, digits)
# valeur par valeur) et ne change que le separateur decimal ; aucun espace des
# milliers. Notes, tables et rapport fige l'emploient ; les exports CSV et
# xlsx, hors champ, ne passent pas par display_helpers.R.
verifier(".num_fr() : signe, arrondi et nombre de chiffres du format d'origine, virgule decimale (#236)",
         identical(.num_fr(c(1.5349, -0.0031, 0, 12.25), "%+.2f"), c("+1,53", "-0,00", "+0,00", "+12,25")) &&
           identical(.num_fr(c(0.0300, 0.13289), "%.4f"), c("0,0300", "0,1329")) &&
           identical(.num_fr(-9.4321, "%+.1f"), "-9,4") && identical(.num_fr(0.5, "%.3f"), "0,500"))
verifier(".num_fr() : NA, NaN, Inf et -Inf ecrits comme par sprintf(), sans virgule (#236)",
         identical(.num_fr(c(NA, NaN, Inf, -Inf), "%.4f"), c("NA", "NaN", "Inf", "-Inf")) &&
           identical(.num_fr(c(NA, NaN, Inf, -Inf), "%+.2f"), c("NA", "NaN", "+Inf", "-Inf")) &&
           identical(.num_fr(NA, "%.4f"), "NA") && identical(.num_fr(numeric(0)), character(0)))
verifier(".num_fr() : grands nombres sans espace des milliers, notation scientifique conservee (#236)",
         identical(.num_fr(1234567.891, "%.2f"), "1234567,89") &&
           identical(.num_fr(123456789012, digits = 15), "123456789012") &&
           identical(.num_fr(c(2.5e-5, 1e-20, 4.96e-5), "%.3g"), c("2,5e-05", "1e-20", "4,96e-05")) &&
           identical(.num_fr(c(1e5, 0.1 + 0.2, 2766.61), digits = 15), c("1e+05", "0,3", "2766,61")))
verifier(".num_fr() : digits = 15 reproduit as.character(), digits = 7 reproduit format() valeur par valeur, entier accepte (#236)",
         {
           v <- c(104.2, 68.97, 1 / 3, 2 / 3 * 1e7, 1e-5, 1234567.891, 100000.5, 0.001, 1 / 1001)
           identical(.num_fr(v, digits = 15), sub(".", ",", as.character(v), fixed = TRUE)) &&
             identical(.num_fr(c(0.001, 1 / 1001), digits = 7), c("0,001", "0,000999001")) &&
             identical(.num_fr(2L, "%.4f"), "2,0000")
         })
# formatC(format = "g") complete a gauche une ecriture courte (" 123", " 0.1",
# "   0") ; .num_fr() ne le fait pas (espaces sans effet dans une cellule HTML).
verifier(".num_fr() : identique a formatC(decimal.mark = \",\") pour des nombres finis, format \"f\", et \"g\" aux espaces de tete pres (#236)",
         {
           v <- c(1.5349, -0.0031, 123.456789, 2.5e-5, 0.125, 0.149, 2 / 40320, 1e6 + 0.3)
           identical(.num_fr(v, "%.4f"), formatC(v, format = "f", digits = 4, decimal.mark = ",")) &&
             identical(.num_fr(v, "%+.2f"), formatC(v, format = "f", digits = 2, flag = "+", decimal.mark = ",")) &&
             identical(.num_fr(v, "%.3g"), trimws(formatC(v, format = "g", digits = 3, decimal.mark = ","))) &&
             identical(formatC(c(123, 0.1), format = "g", digits = 3), c(" 123", " 0.1"))
         })
# Formateur par defaut nomme (revue finale de #236) : meme sortie que
# l'ecriture repetee .num_fr(x, digits = getOption("digits")), qu'il remplace.
verifier(".num_fr_defaut() : identique a .num_fr(x, digits = getOption(\"digits\")), y compris sous digits = 4 (#236)",
         {
           v <- c(0.1, 0.001, 1 / 3, 104.2, 131.22, 1e-20, 1e5, NA, NaN, Inf)
           od <- options(digits = 4)
           d4 <- tryCatch(identical(.num_fr_defaut(v), .num_fr(v, digits = 4)) &&
                            identical(.num_fr_defaut(1 / 3), "0,3333"),
                          finally = options(od))
           d4 && identical(getOption("digits"), od$digits) &&
             identical(.num_fr_defaut(v), .num_fr(v, digits = getOption("digits"))) &&
             identical(.num_fr_defaut(1 / 3), "0,3333333") &&
             identical(.num_fr_defaut(integer(0)), character(0))
         })
verifier("Formateur par defaut : aucune ecriture .num_fr(..., digits = getOption(\"digits\")) hors de .num_fr_defaut() dans app.R et display_helpers.R (#236)",
         {
           n <- vapply(file.path(.racine, c("app.R", file.path("R", "display_helpers.R"))), function(f)
             length(grep("digits = getOption(\"digits\")", readLines(f, encoding = "UTF-8", warn = FALSE),
                         fixed = TRUE)), 0L)
           identical(unname(n), c(0L, 1L))
         })
# Espace insecable des milliers (revue finale de #236) : un nombre n'est pas
# coupe en fin de ligne d'une infobulle ou d'une graduation plotly.
verifier(".SEPARATEURS_PLOTLY : virgule decimale puis espace insecable U+00A0 (#236)",
         identical(utf8ToInt(.SEPARATEURS_PLOTLY), c(44L, 160L)))
verifier("fmt_nb(), fmt_p(), fmt_pc() : virgule decimale, tiret pour une valeur non finie (#236)",
         identical(fmt_p(c(0.05, NA, Inf)), c("0,0500", "\u2013", "\u2013")) &&
           identical(fmt_nb(c(-1.23456, 1e3), 2), c("-1,23", "1000,00")) &&
           identical(fmt_nb(1L), "1,0000") && identical(fmt_pc(0.1234), "12,3 %"))
# Note de l'issue : reference reserve2 (CI), cellule la plus influente
# (i = 1, j = 4), DFBETAS +1,53 et deplacement de f_4 de -0,30 %.
res_mw_ref <- readRDS(file.path(.racine, "tests", "reference", "reserve2.rds"))
res_ln_ref <- readRDS(file.path(.racine, "tests", "reference", "premium.rds"))
verifier("note_influence_mw() (reference reserve2) : \"(DFBETAS = +1,53)\" et \"-0,30 %\" de l'issue, aucun point decimal (#236)",
         {
           n <- note_influence_mw(res_mw_ref$plots_data)
           grepl("<b>(i = 1, j = 4)</b> (DFBETAS = +1,53)", n, fixed = TRUE) &&
             grepl("f_4 de <b>-0,30 %</b>", n, fixed = TRUE) && !grepl("[0-9]\\.[0-9]", n)
         })
verifier("note_m1(), note_surface(), note_influence() (references) : virgule decimale, aucun point decimal (#236)",
         {
           n1 <- note_m1(res_mw_ref$plots_data, 0.10)
           ns <- note_surface(res_ln_ref$plots_data)$html
           ni <- note_influence(res_ln_ref$plots_data)
           grepl("au seuil alpha = 0,1, ", n1, fixed = TRUE) && grepl("(p = 0,0300)", n1, fixed = TRUE) &&
             grepl("<b>au bord</b> (1,0000)", ns, fixed = TRUE) && grepl("(4/T = 0,500)", ni, fixed = TRUE) &&
             !any(grepl("[0-9]\\.[0-9]", c(n1, ns, ni)))
         })
# Rapport fige sur la reference premium, duree forgee (champ retire par
# nettoyer()) : echantillon de lignes de l'en-tete, du bloc du parametre (bornes
# d'intervalle separees par " ; ") et des tables ; OutDec restaure.
verifier("Rapport fige (reference premium) : en-tete, parametre, intervalle \"[a ; b]\" et calibration en virgule decimale, OutDec restaure (#236)",
         {
           r0 <- res_ln_ref; r0$metadata$duree_sec <- 6.137
           od <- getOption("OutDec")
           f0 <- tempfile(fileext = ".html")
           rapport_html(r0, NULL, f0, interactif = FALSE, identite = idt)
           h0 <- lire(f0); unlink(f0)
           gel <- entre(h0, "<h2 id='gel'>", "</table>")
           bloc <- entre(h0, "<div class='bloc'>", "<h3>")
           identical(getOption("OutDec"), od) &&
             identical(cle_val(gel, "Dur\u00e9e du calcul"), "6,14 s") &&
             identical(cle_val(gel, "Seuil alpha des verdicts"), "0,1") &&
             identical(cle_val(gel, "sigma standard"), "0,1") &&
             identical(cle_val(gel, CLE_EQUIV), "marge = 0,1 de la perte moyenne (theta_equiv)") &&
             grepl("<td>0,001</td>", gel, fixed = TRUE) &&
             grepl("sigma_USP = 0,1115</span>", bloc, fixed = TRUE) &&
             grepl("soit +11,5 % par rapport au param\u00e8tre standard de 0,1000", bloc, fixed = TRUE) &&
             grepl("90 % : [0,0752 ; 0,1370] &nbsp;|&nbsp; 95 % : [0,0712 ; 0,1416]", bloc, fixed = TRUE) &&
             !grepl("[0-9]\\.[0-9]", gsub("style='[^']*'", "", bloc)) &&
             grepl("<td>delta (parametre de melange)</td><td>1,00000</td>", h0, fixed = TRUE)
         })


## --- Graphique des facteurs Merz-Wuthrich : sigma_j et point J - 1 (#310) ----
# Panneaux f_j / sigma_j (Q-D1-Fm-9, forme retenue par app-review), point
# j = J - 1 designe par plots_data$facteurs$sigma_regle_minimum et legende T-5
# de la specification Fm a la lettre ; objet anterieur a #310 (sans la
# colonne) : serie "sigma_j", aucun point distingue.
spec310 <- readLines(file.path(.racine, "docs", "specifications", "fm-merz-wuthrich-restitution.md"),
                     encoding = "UTF-8")
t5_310 <- spec310[which(startsWith(spec310, "**T-5 (#310"))[1] + 1L]
t5_310 <- sub("^> `(.*)`$", "\\1", t5_310)
verifier("Graphique des facteurs : .LEGENDE_SIGMA_REGLE = texte T-5 de la specification Fm, a la lettre (#310)",
         identical(.LEGENDE_SIGMA_REGLE, t5_310))
pd310 <- res_mw$plots_data
pd310_ancien <- pd310; pd310_ancien$facteurs$sigma_regle_minimum <- NULL
# par() lu avant et apres le trace, sur le peripherique pdf(NULL) du releve.
leg310 <- function(pd, l = 480) {
  e <- new.env()
  r <- releve_base162(function() {
    e$avant <- graphics::par(c("mfrow", "mar", "oma", "xpd"))
    plot_mw_facteurs(pd)
    e$apres <- graphics::par(c("mfrow", "mar", "oma", "xpd"))
  }, largeur = l / 72, hauteur = 330 / 72)
  list(n = length(r$leg), texte = if (length(r$leg)) r$leg[[1]]$texte, rect = if (length(r$leg)) r$leg[[1]]$rect,
       usr = r$usr, par_restaure = identical(e$avant, e$apres))
}
verifier("Graphique des facteurs, base R (400, 480, 560 x 330 px) : legende sigma_j estime + T-5, sous le panneau du bas, par() restaure (#310)",
         all(vapply(c(400, 480, 560), function(l) {
           r <- leg310(pd310, l)
           r$n == 1L && identical(r$texte, c("sigma_j estime", .LEGENDE_SIGMA_REGLE)) &&
             r$rect$top < r$usr[3] && r$par_restaure
         }, TRUE)))
verifier("Graphique des facteurs, base R, objet sans sigma_regle_minimum : rendu sans erreur, serie legendee \"sigma_j\" seule (#310)",
         {
           r <- leg310(pd310_ancien)
           r$n == 1L && identical(r$texte, "sigma_j")
         })
# Reference f = 1 du panneau du haut (reserve d'app-review sur #310, jointe
# a #311) : ylim inclut 1, la droite h = 1 tombe dans la zone de trace meme
# quand tous les f_j sont au-dessus de 1,04. par("usr") releve a l'appel de
# abline(h = 1).
usr_f1 <- function(pd) {
  e <- new.env(); e$usr <- NULL
  ns <- asNamespace("graphics")
  suppressMessages(trace("abline", exit = bquote(if (identical(h, 1))
    assign("usr", graphics::par("usr"), envir = .(e))), where = ns, print = FALSE))
  on.exit(suppressMessages(untrace("abline", where = ns)))
  releve_base162(function() plot_mw_facteurs(pd), largeur = 480 / 72, hauteur = 330 / 72)
  e$usr
}
verifier("Graphique des facteurs, base R : reference f = 1 dans la zone de trace du panneau du haut, y compris quand tous les f_j > 1,04 (#311)",
         {
           pf <- pd310; pf$facteurs$f <- pf$facteurs$f + 0.3
           u0 <- usr_f1(pd310); u1 <- usr_f1(pf)
           min(pf$facteurs$f) > 1.04 && length(u0) == 4L && length(u1) == 4L &&
             u0[3] <= 1 && 1 <= u0[4] && u1[3] <= 1 && 1 <= u1[4]
         })
# Axe j gradue aux seules annees de developpement (constat C3 d'app-review,
# revue finale) : sur un triangle 5 x 5 (J = 4, j = 0..3), R graduait par
# 0,5. Appels de axis() a graduations explicites (at non NULL) releves
# pendant le trace base R : plot.default() appelle aussi axis(1) sans at,
# y compris sous xaxt = "n" (mesure), appels ecartes.
axes_j311 <- function(pd) {
  e <- new.env(); e$ax <- list()
  ns <- asNamespace("graphics")
  suppressMessages(trace("axis", exit = bquote(if (identical(side, 1) && !is.null(at))
    assign("ax", c(get("ax", envir = .(e)), list(list(at = at, labels = labels))), envir = .(e))),
    where = ns, print = FALSE))
  on.exit(suppressMessages(untrace("axis", where = ns)))
  releve_base162(function() plot_mw_facteurs(pd), largeur = 395 / 72, hauteur = 330 / 72)
  e$ax
}
verifier("Graphique des facteurs, base R : axe j gradue en d$j dans les deux panneaux (libelles en bas seulement), y compris J = 4 (#311)",
         all(vapply(list(pd310, local({ p <- pd310; p$facteurs <- p$facteurs[p$facteurs$j <= 3, ]; p })),
                    function(pd) {
           ax <- axes_j311(pd)
           length(ax) == 2L && identical(as.numeric(ax[[1]]$at), as.numeric(pd$facteurs$j)) &&
             identical(ax[[1]]$labels, FALSE) &&
             identical(as.numeric(ax[[2]]$at), as.numeric(pd$facteurs$j)) && isTRUE(ax[[2]]$labels)
         }, TRUE)))
verifier("Graphique des facteurs : losange J - 1 d'une couleur distincte de la reference f = 1 (COUL$regle != COUL$trait) (#310)",
         is.character(COUL$regle) && !identical(COUL$regle, COUL$trait))
if (requireNamespace("plotly", quietly = TRUE)) {
  b310 <- function(pd) suppressWarnings(plotly::plotly_build(plot_mw_facteurs(pd)))$x
  # Nom de trace plotly de T-5 coupe par <br> apres "regle de minimum"
  # (reserve d'app-review sur #310, jointe a #311) : compare a T-5 une fois
  # <br> remplace par une espace.
  verifier("Graphique des facteurs, plotly : deux sous-graphiques a axe j partage, f_j en haut, sigma_j (axe depuis 0) et T-5 en bas, legende horizontale sous le trace (#310)",
           {
             b <- b310(pd310); L <- b$layout
             nm <- vapply(b$data, function(t) if (is.null(t$name)) "" else t$name, "")
             nm <- gsub("<br>", " ", nm, fixed = TRUE)
             ya <- vapply(b$data, function(t) t$yaxis, "")
             xa <- vapply(b$data, function(t) t$xaxis, "")
             j1 <- b$data[[which(nm == .LEGENDE_SIGMA_REGLE)]]
             length(b$data) == 4L && all(xa == "x") &&
               identical(ya[nm == "f_j"], "y") && identical(ya[nm == "sigma_j estime"], "y2") &&
               identical(ya[nm == .LEGENDE_SIGMA_REGLE], "y2") &&
               identical(as.numeric(j1$x), as.numeric(pd310$facteurs$j[pd310$facteurs$sigma_regle_minimum])) &&
               identical(j1$marker$color, COUL$regle) &&
               min(unlist(L$yaxis$domain)) > max(unlist(L$yaxis2$domain)) &&
               identical(unlist(L$yaxis2$range)[1], 0) &&
               identical(L$legend$orientation, "h") && identical(L$legend$y, -0.30)
           })
  verifier("Graphique des facteurs, plotly : legende T-5 coupee en deux lignes apres 'regle de minimum' (largeur < 395 px, #311)",
           {
             b <- b310(pd310)
             nm <- vapply(b$data, function(t) if (is.null(t$name)) "" else t$name, "")
             k <- grep("<br>", nm, fixed = TRUE)
             length(k) == 1L && grepl("regle de minimum<br>(annexe", nm[k], fixed = TRUE) &&
               identical(gsub("<br>", " ", nm[k], fixed = TRUE), .LEGENDE_SIGMA_REGLE)
           })
  verifier("Graphique des facteurs, plotly, objet sans sigma_regle_minimum : trois traces, serie \"sigma_j\" sur tous les j (#310)",
           {
             b <- b310(pd310_ancien)
             nm <- vapply(b$data, function(t) if (is.null(t$name)) "" else t$name, "")
             nm <- gsub("<br>", " ", nm, fixed = TRUE)
             length(b$data) == 3L && !(.LEGENDE_SIGMA_REGLE %in% nm) &&
               identical(as.numeric(b$data[[which(nm == "sigma_j")]]$x), as.numeric(pd310$facteurs$j))
           })
} else {
  cat("  note : plotly absent ; sous-graphiques plotly du graphique des facteurs non exerces (#310).\n")
}


## --- Nuages de residus Merz-Wuthrich : moyennes par groupe (#312) ------------
# Moyennes et effectifs lus dans plots_data$residus_acc_groupes et
# residus_cal_groupes (Q-D1-Fm-2) ; legendes et infobulles : texte T-2 de la
# specification Fm, a la lettre. Objet anterieur a #312 (tables absentes) :
# nuage seul, sans legende.
i_t2 <- which(startsWith(spec310, "**T-2 (#312"))[1]
t2_leg <- regmatches(spec310[i_t2 + 1L], gregexpr("`[^`]*`", spec310[i_t2 + 1L]))[[1]]
t2_leg <- gsub("`", "", t2_leg, fixed = TRUE)
t2_inf <- regmatches(spec310[i_t2 + 2L], gregexpr("`[^`]*`", spec310[i_t2 + 2L]))[[1]]
t2_inf <- gsub("^`\"?|\"?`$", "", t2_inf)
verifier("Nuages de residus : legendes et infobulles des moyennes = texte T-2 de la specification Fm, a la lettre (#312)",
         length(t2_leg) == 2L && length(t2_inf) == 2L &&
           identical(c(.LEGENDE_MOYENNE_ACC, .LEGENDE_MOYENNE_CAL), t2_leg) &&
           identical(.INFOBULLE_MOYENNE_ACC, t2_inf[1]) &&
           identical(t2_inf[2], "i + j = %{x}") &&
           identical(.INFOBULLE_MOYENNE_CAL, sub("i = %{x}", "i + j = %{x}", t2_inf[1], fixed = TRUE)))
pd312 <- res_mw$plots_data
pd312_ancien <- pd312; pd312_ancien$residus_acc_groupes <- NULL; pd312_ancien$residus_cal_groupes <- NULL
# Releve, dans l'ordre d'appel, des points traces (graphics::points.default :
# pch et cex) et des textes de marge (graphics::mtext), en plus des
# legendes. legend() trace aussi son symbole par points() (pch 23, cex 0,75) :
# les losanges des moyennes sont les appels pch 23, cex 1,5 ; les residus,
# les appels pch 19.
rel312 <- function(f, l = 480) {
  e <- new.env(); e$pts <- list(); e$mt <- list()
  ns <- asNamespace("graphics")
  suppressMessages({
    trace("points.default", exit = bquote(assign("pts", c(get("pts", envir = .(e)),
      list(list(x = x, y = y, pch = list(...)$pch, cex = list(...)$cex))), envir = .(e))),
      where = ns, print = FALSE)
    trace("mtext", exit = bquote(assign("mt", c(get("mt", envir = .(e)),
      list(list(text = text, at = at, side = side, cex = cex))), envir = .(e))), where = ns, print = FALSE)
  })
  on.exit(suppressMessages({ untrace("points.default", where = ns); untrace("mtext", where = ns) }))
  r <- releve_base162(f, largeur = l / 72, hauteur = 330 / 72)
  los <- Filter(function(p) identical(p$pch, 23) && identical(p$cex, 1.5), e$pts)
  k_los <- which(vapply(e$pts, function(p) identical(p$pch, 23) && identical(p$cex, 1.5), TRUE))
  k_res <- which(vapply(e$pts, function(p) identical(p$pch, 19), TRUE))
  c(r, list(pts = los, k_los = k_los, k_res = k_res, mt = e$mt))
}
# Effectifs ecrits seuls en marge haute, a l'abscisse de chaque groupe,
# precedes de l'intitule "n :" (reprise de #312, app-review R2).
marge_n312 <- function(r, g, cle) {
  mt <- Filter(function(m) identical(m$side, 3), r$mt)
  length(mt) == 2L && identical(mt[[1]]$text, as.character(g$n)) &&
    identical(as.numeric(mt[[1]]$at), as.numeric(g[[cle]])) && identical(mt[[2]]$text, "n :")
}
verifier("Nuages de residus, base R (395, 480 et 560 x 330 px) : moyennes par groupe tracees aux valeurs de plots_data, AVANT les residus, effectifs en marge haute, legende T-2 sous le trace (#312)",
         all(vapply(c(395, 480, 560), function(l) {
           ra <- rel312(function() plot_mw_residus_acc(pd312), l)
           rc <- rel312(function() plot_mw_residus_cal(pd312), l)
           g_a <- pd312$residus_acc_groupes; g_c <- pd312$residus_cal_groupes
           length(ra$leg) == 1L && identical(ra$leg[[1]]$texte, .LEGENDE_MOYENNE_ACC) &&
             ra$leg[[1]]$rect$top < ra$usr[3] &&
             length(rc$leg) == 1L && identical(rc$leg[[1]]$texte, .LEGENDE_MOYENNE_CAL) &&
             rc$leg[[1]]$rect$top < rc$usr[3] &&
             length(ra$pts) == 1L && identical(as.numeric(ra$pts[[1]]$x), as.numeric(g_a$i)) &&
             identical(ra$pts[[1]]$y, g_a$moyenne) &&
             length(rc$pts) == 1L && identical(as.numeric(rc$pts[[1]]$x), as.numeric(g_c$calendrier)) &&
             identical(rc$pts[[1]]$y, g_c$moyenne) &&
             length(ra$k_res) == 1L && ra$k_los < ra$k_res &&
             length(rc$k_res) == 1L && rc$k_los < rc$k_res &&
             marge_n312(ra, g_a, "i") && marge_n312(rc, g_c, "calendrier")
         }, TRUE)))
verifier("Nuages de residus, base R, objet sans tables de groupes : nuage seul, ni legende, ni moyenne, ni effectif (#312)",
         {
           ra <- rel312(function() plot_mw_residus_acc(pd312_ancien))
           rc <- rel312(function() plot_mw_residus_cal(pd312_ancien))
           length(ra$leg) == 0L && length(ra$pts) == 0L && length(rc$leg) == 0L && length(rc$pts) == 0L &&
             length(ra$mt) == 0L && length(rc$mt) == 0L
         })
# Police des effectifs reduite au-dela de .NB_GROUPES_EFFECTIF_REDUIT
# groupes (reserve M1 de l'audit de #312) : table residus_acc_groupes
# fictive de 15 lignes (I = 15), contre les 7 groupes de reserve2.
verifier("Nuages de residus, base R : effectifs et 'n :' en cex 0,6 au-dela de .NB_GROUPES_EFFECTIF_REDUIT groupes (15 lignes), 0,7 en deca (reserve2, 7 groupes) (#312)",
         {
           pd15 <- pd312
           pd15$residus_acc <- data.frame(i = 0:14, residu = seq(-1, 1, length.out = 15))
           pd15$residus_acc_groupes <- data.frame(i = 0:14, n = rep(1L, 15), moyenne = pd15$residus_acc$residu)
           cex3 <- function(r) vapply(Filter(function(m) identical(m$side, 3), r$mt), function(m) m$cex, 0)
           c15 <- cex3(rel312(function() plot_mw_residus_acc(pd15)))
           c7 <- cex3(rel312(function() plot_mw_residus_acc(pd312)))
           nrow(pd15$residus_acc_groupes) > .NB_GROUPES_EFFECTIF_REDUIT &&
             nrow(pd312$residus_acc_groupes) <= .NB_GROUPES_EFFECTIF_REDUIT &&
             identical(c15, c(0.6, 0.6)) && identical(c7, c(0.7, 0.7))
         })
verifier("Nuages de residus : affichage sans calcul, moyennes lues dans plots_data (aucun mean(), tapply() ni stats:: dans le code des nuages) (#312)",
         {
           corps <- paste(c(deparse(.nuage_moyennes), deparse(.groupes_nuage),
                            deparse(plot_mw_residus_acc), deparse(plot_mw_residus_cal)), collapse = "\n")
           !grepl("mean\\(|tapply\\(|aggregate\\(|stats::", corps)
         })
if (requireNamespace("plotly", quietly = TRUE)) {
  b312 <- function(p) suppressWarnings(plotly::plotly_build(p))$x
  verifier("Nuages de residus, plotly : trace des moyennes (losange, customdata = n, infobulle T-2) avant les residus, legende horizontale sous le trace (#312)",
           {
             ok1 <- function(b, g, cle, leg, inf) {
               nm <- vapply(b$data, function(t) if (is.null(t$name)) "" else t$name, "")
               k <- which(nm == leg)
               length(k) == 1L && {
                 t <- b$data[[k]]
                 identical(as.numeric(t$x), as.numeric(g[[cle]])) && identical(as.numeric(t$y), g$moyenne) &&
                   identical(as.numeric(t$customdata), as.numeric(g$n)) &&
                   identical(t$hovertemplate, paste0(inf, "<extra></extra>")) &&
                   identical(t$marker$symbol, "diamond")
               } && isTRUE(b$layout$showlegend) && identical(b$layout$legend$orientation, "h") &&
                 b$layout$legend$y < 0 &&
                 # Trace des moyennes avant celle des residus (dernier trace) :
                 # residus dessines au-dessus des losanges.
                 k < length(b$data) && identical(b$data[[length(b$data)]]$showlegend, FALSE)
             }
             ok1(b312(plot_mw_residus_acc(pd312)), pd312$residus_acc_groupes, "i",
                 .LEGENDE_MOYENNE_ACC, .INFOBULLE_MOYENNE_ACC) &&
               ok1(b312(plot_mw_residus_cal(pd312)), pd312$residus_cal_groupes, "calendrier",
                   .LEGENDE_MOYENNE_CAL, .INFOBULLE_MOYENNE_CAL)
           })
} else {
  cat("  note : plotly absent ; trace plotly des moyennes par groupe non exerce (#312).\n")
}


## --- QQ-plot Merz-Wuthrich des residus redresses (#311) ---------------------
# Option (c) de Q-D1-Fm-4 et Q-D1-Fm-5 : points lus dans plots_data$qqnorm
# (r / sqrt(1 - h)), droite lue dans plots_data$qqline (y = x, posee par le
# moteur) dans les deux rendus ; titre, axes et note : texte T-3 de la
# specification Fm, a la lettre (la note, coupee en lignes a l'affichage, est
# recomposee par une espace ; le titre, coupe en deux lignes avant
# "(M5, diagnostic)", aussi). Droite pleine, epaisseur 2, COUL$trait, comme
# plot_qqnorm(). Objet sans qqline (version anterieure du moteur) : .vide()
# avec un message fixe.
i_t3 <- which(startsWith(spec310, "**T-3 (#311"))[1]
bq311 <- function(l) gsub("`", "", regmatches(l, gregexpr("`[^`]*`", l))[[1]], fixed = TRUE)
t3_titre <- bq311(spec310[i_t3 + 1L]); t3_axes <- bq311(spec310[i_t3 + 2L])
t3_note <- sub("^ *> `(.*)`$", "\\1", spec310[i_t3 + 4L])
verifier("QQ-plot MW : titre, axes et note = texte T-3 de la specification Fm, a la lettre (#311)",
         length(t3_titre) == 1L && length(t3_axes) == 2L &&
           startsWith(t3_note, "droite y = x : variance unitaire") &&
           identical(.TITRE_MW_QQ, t3_titre) && identical(c(.AXE_X_MW_QQ, .AXE_Y_MW_QQ), t3_axes) &&
           identical(.NOTE_MW_QQ, t3_note))
pd311 <- res_mw$plots_data
pd311_ancien <- pd311; pd311_ancien$qqline <- NULL
# Releve du trace base R : points (plot.xy, appele par plot.default() ; un
# trace de plot.default lui-meme ne releve aucun appel quand ce fichier est
# execute en entier, mesure, cause non etablie), droites (abline), titres et
# intitules des axes
# (title, appele aussi par plot.default()) et textes de marge (mtext).
rel311 <- function(pd, l = 560) {
  e <- new.env(); e$pl <- list(); e$ab <- list(); e$ti <- list(); e$mt <- list()
  ns <- asNamespace("graphics")
  suppressMessages({
    trace("plot.xy", tracer = bquote(assign("pl", c(get("pl", envir = .(e)),
      list(list(x = xy$x, y = xy$y))), envir = .(e))), where = ns, print = FALSE)
    trace("abline", exit = bquote(assign("ab", c(get("ab", envir = .(e)),
      list(list(a = a, b = b, lwd = list(...)$lwd, lty = list(...)$lty, col = list(...)$col))),
      envir = .(e))), where = ns, print = FALSE)
    trace("title", exit = bquote(assign("ti", c(get("ti", envir = .(e)),
      list(list(main = main, xlab = xlab, ylab = ylab))), envir = .(e))), where = ns, print = FALSE)
    trace("mtext", exit = bquote(assign("mt", c(get("mt", envir = .(e)),
      list(list(text = text, side = side))), envir = .(e))), where = ns, print = FALSE)
  })
  on.exit(suppressMessages(for (f in c("plot.xy", "abline", "title", "mtext"))
    untrace(f, where = ns)))
  releve_base162(function() plot_mw_qq(pd), largeur = l / 72, hauteur = 330 / 72)
  as.list(e)
}
verifier("QQ-plot MW, base R (560 x 330 px) : points = plots_data$qqnorm, droite abline(qqline) = (0, 1) pleine lwd 2, titre sur deux lignes, axes et note T-3 (#311)",
         {
           r <- rel311(pd311)
           note <- Filter(function(m) identical(m$side, 3), r$mt)
           # plot.default() appelle title(main = "", xlab, ylab), puis
           # plot_mw_qq() title() pour chacune des deux lignes du titre T-3 :
           # titres vides ecartes.
           tit <- unlist(lapply(r$ti, `[[`, "main"))
           length(r$pl) == 1L && identical(as.numeric(r$pl[[1]]$x), pd311$qqnorm$theorique) &&
             identical(as.numeric(r$pl[[1]]$y), pd311$qqnorm$empirique) &&
             length(r$ti) == 3L && identical(r$ti[[1]]$xlab, t3_axes[1]) &&
             identical(r$ti[[1]]$ylab, t3_axes[2]) &&
             length(r$ab) == 1L && identical(r$ab[[1]]$a, pd311$qqline[["ordonnee"]]) &&
             identical(r$ab[[1]]$b, pd311$qqline[["pente"]]) &&
             identical(pd311$qqline, c(ordonnee = 0, pente = 1)) &&
             identical(r$ab[[1]]$lwd, 2) && is.null(r$ab[[1]]$lty) && identical(r$ab[[1]]$col, COUL$trait) &&
             identical(Filter(nzchar, tit), c("QQ-plot des residus de Mack redresses par le levier",
                                              "(M5, diagnostic)")) &&
             identical(paste(Filter(nzchar, tit), collapse = " "), t3_titre) &&
             length(note) >= 2L &&
             identical(paste(vapply(note, function(m) m$text, ""), collapse = " "), t3_note)
         })
env311 <- environment(plot_mw_qq); vide311 <- get(".vide", envir = env311)
vide_311 <- function(pd) {
  msg <- NULL
  assign(".vide", function(message = formals(vide311)$message) { msg <<- message; vide311(message) },
         envir = env311)
  on.exit(assign(".vide", vide311, envir = env311))
  option <- options(usp.graphiques_base = TRUE); grDevices::pdf(NULL)
  on.exit({ grDevices::dev.off(); options(option) }, add = TRUE)
  r <- tryCatch({ plot_mw_qq(pd); TRUE }, error = function(e) FALSE)
  list(ok = r, msg = msg)
}
verifier("QQ-plot MW, objet sans qqline (version anterieure du moteur) : aucune erreur, .vide() avec le message fixe, sans numero d'issue ; objet courant : aucun appel a .vide() (#311)",
         {
           v0 <- vide_311(pd311_ancien); v1 <- vide_311(pd311)
           # Base R : message sur trois lignes, coupe apres "disponible :" et
           # avant "(relancer" (constat C1 d'app-review, revue finale : deux
           # lignes debordaient encore d'un PNG de 395 px).
           v0$ok && identical(gsub("\n", " ", v0$msg, fixed = TRUE), .VIDE_MW_QQ) &&
             grepl("disponible :\nresultat", v0$msg, fixed = TRUE) &&
             grepl("moteur\n(relancer", v0$msg, fixed = TRUE) &&
             lengths(regmatches(v0$msg, gregexpr("\n", v0$msg, fixed = TRUE))) == 2L &&
             v1$ok && is.null(v1$msg) &&
             identical(.VIDE_MW_QQ, paste("QQ-plot non disponible : resultat produit par une version",
                                          "anterieure du moteur (relancer les calculs)")) &&
             !grepl("#", .VIDE_MW_QQ, fixed = TRUE)
         })
verifier("QQ-plot MW : affichage sans calcul (aucun stats::, qqnorm(), qqline() ni quantile() dans plot_mw_qq()) (#311)",
         {
           corps <- paste(deparse(plot_mw_qq), collapse = "\n")
           !grepl("stats::", corps, fixed = TRUE) && !grepl("qqnorm\\(|qqline\\(|quantile\\(", corps)
         })
if (requireNamespace("plotly", quietly = TRUE)) {
  verifier("QQ-plot MW, plotly : droite (0, 1) lue dans qqline, pleine, epaisseur 2, points = qqnorm, titre (deux lignes) et note T-3, axes T-3 (#311)",
           {
             b <- suppressWarnings(plotly::plotly_build(plot_mw_qq(pd311)))$x
             L <- b$layout; x <- range(pd311$qqnorm$theorique)
             tx <- function(t) if (is.list(t)) t$text else t
             ttl <- gsub("<br>", " ", gsub("</?sup>", "", tx(L$title)), fixed = TRUE)
             length(b$data) == 2L &&
               identical(as.numeric(b$data[[1]]$x), x) && identical(as.numeric(b$data[[1]]$y), 0 + 1 * x) &&
               identical(b$data[[1]]$line$width, 2) && is.null(b$data[[1]]$line$dash) &&
               startsWith(tx(L$title), "QQ-plot des residus de Mack redresses par le levier<br>(M5, diagnostic)<br>") &&
               identical(as.numeric(b$data[[2]]$x), pd311$qqnorm$theorique) &&
               identical(as.numeric(b$data[[2]]$y), pd311$qqnorm$empirique) &&
               identical(ttl, paste(t3_titre, t3_note)) &&
               identical(tx(L$xaxis$title), t3_axes[1]) && identical(tx(L$yaxis$title), t3_axes[2])
           })
} else {
  cat("  note : plotly absent ; rendu plotly du QQ-plot Merz-Wuthrich non exerce (#311).\n")
}

fin_fichier()
