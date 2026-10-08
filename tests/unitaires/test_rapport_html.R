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
#  (issue #178).
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
verifier("Rapport : donnees lues dans res (x_t et y_t du calcul)",
         grepl("<td>1</td><td>104.2</td><td>68.97</td>", h, fixed = TRUE) &&
         grepl("<td>7</td><td>132.4</td><td>78.89</td>", h, fixed = TRUE))
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
verifier("Rapport MW : triangle du calcul restitue, cellules non observees en tiret",
         grepl("<td>2766.61</td>", hm, fixed = TRUE) && grepl("<td>\u2013</td>", hm, fixed = TRUE))
verifier("Rapport MW : exclus par defaut en annexe avec leur verdict",
         any(!rm) && all(vapply(which(!rm), function(k)
           grepl(badge_verdict(tbm$verdict[k]),
                 ligne_de(entre(hm, "<section id='section-annexe-exclus'>", "</section>"), tbm$test[k]),
                 fixed = TRUE), logical(1))))
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
verifier("Graphiques d'influence, y proportionnel a x (x = 2^(0:7), y = x / 2), ajustement refuse par run_engine() (#188), robustesse de engine_plots_data() / note_influence() en appel direct : motif pose (residu_std et cook non finis) ou absent (tout fini) selon la plateforme ; aucun trace en base R ni note_influence() en erreur, aucun 'NA' dans la note (#153 ; #188)",
         {
           inf <- pdp153$influence
           np153 <- tryCatch(note_influence(pdp153), error = function(e) e)
           garde <- !any(is.finite(inf$cook)) && !any(is.finite(inf$residu_std)) &&
             is.character(pdp153$influence_motif) && length(pdp153$influence_motif) == 1L
           calcule <- all(is.finite(inf$cook)) && all(is.finite(inf$residu_std)) &&
             is.null(pdp153$influence_motif)
           (garde || calcule) && all(basep153) &&
             is.character(np153) && !grepl("NA", np153, fixed = TRUE)
         })
if (requireNamespace("plotly", quietly = TRUE)) {
  verifier("Graphiques d'influence, residus nuls (injection) et y proportionnel a x, plotly : aucun trace en erreur (#153)",
           all(sans_erreur153(pd153)) && all(sans_erreur153(pdp153)))
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
relire_com <- function(cel) vapply(cel, function(x) {
  if (identical(x, "–")) return(NA_character_)
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
  long <- !is.na(com1) & nchar(com1) > 200L
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
verifier("Garde : table sans colonne fonction -> tiret dans la colonne Fonction (#178)",
         { tbf <- tb; tbf$fonction <- NULL; all(table_detail_groupe(tbf)$Fonction == "–") })
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

fin_fichier()
