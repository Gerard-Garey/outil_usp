###############################################################################
#  tests/unitaires/test_rapport_html.R  --  RAPPORT FIGE (issue #53)
#
#  rapport_html(), encoder_base64(), texte_formule() (R/display_helpers.R) et
#  engine_empreinte() (R/engine.R).
#  Proprietes verifiees : document HTML autonome (DOCTYPE, UTF-8, aucune
#  ressource externe), tests retenus dans la section principale et tests
#  exclus en annexe avec leur verdict, empreintes presentes, stables et
#  sensibles aux donnees, formule propre a chaque methode, etat global
#  (.Random.seed, options) inchange.
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
# Type et motif d'une ligne (#124) : lus dans tb$type et tb$commentaire
# (engine_table_tests()), restitues par table_detail_groupe() (colonnes Type
# et "Motif / commentaire") et, pour les lignes autres que "test", sous le
# badge de table_synthese_groupe() ; memes fonctions dans le rapport fige.
det_all <- table_detail_groupe(tb); sy_all <- table_synthese_groupe(tb)
i_fis <- grep("^Test de Fisher", tb$test)[1]
i_inop <- grep("^TEST INOPERANT", tb$commentaire)[1]
verifier("table_detail_groupe() : colonnes Type et Motif / commentaire, motif echappe (Fisher R4, J1)",
         all(c("Type", "Motif / commentaire") %in% names(det_all)) &&
         !is.na(i_fis) && identical(tb$type[i_fis], "diagnostic") &&
         identical(det_all$Type[i_fis], "diagnostic") &&
         grepl("PENTE NON IDENTIFIABLE", det_all[["Motif / commentaire"]][i_fis], fixed = TRUE) &&
         grepl("0.47 &lt; 0.5", det_all[["Motif / commentaire"]][i_fis], fixed = TRUE))
verifier("table_detail_groupe() : toute ligne INFO a un motif (aucun tiret)",
         all(det_all[["Motif / commentaire"]][tb$verdict == "INFO"] != "\u2013"))
verifier("Type : test inoperant (R1) distingue du diagnostic, en detail et sous le badge de synthese",
         !is.na(i_inop) && identical(type_ligne(tb)[i_inop], "test inop\u00e9rant") &&
         identical(det_all$Type[i_inop], "test inop\u00e9rant") &&
         grepl("test inop\u00e9rant</span>", sy_all$Verdict[i_inop], fixed = TRUE) &&
         all(!grepl("<br>", sy_all$Verdict[tb$type == "test"], fixed = TRUE)))
verifier("Rapport : motif de la ligne Fisher restitue dans la section des tests retenus",
         retenu[i_fis] &&
         grepl("PENTE NON IDENTIFIABLE", paste(ligne_de(principal, tb$test[i_fis]), collapse = ""),
               fixed = TRUE))
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

fin_fichier()
