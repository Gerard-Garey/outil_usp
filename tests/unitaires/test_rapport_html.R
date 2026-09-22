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
res_ln <- run_engine(xt = xt, yt = yt, methode = "premium", segment = 1, B = 99)
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
e3 <- engine_empreinte(run_engine(xt = x2, yt = yt, methode = "premium", segment = 1, B = 99))
verifier("Empreintes : changent si xt[1] change (donnees et resultat)",
         e3$donnees != e1$donnees && e3$resultat != e1$resultat)
verifier("Empreintes : stables entre deux run_engine() a graine egale (hors horodatage)",
         identical(engine_empreinte(run_engine(xt = xt, yt = yt, methode = "premium",
                                               segment = 1, B = 99))[c("donnees", "resultat")],
                   e1[c("donnees", "resultat")]))
verifier("Empreintes : texte canonique en %.17g, recalculable",
         grepl("1;104.2;68.969999999999999", e1$texte_donnees, fixed = TRUE) && {
           f <- tempfile(); writeBin(charToRaw(e1$texte_donnees), f)
           identical(unname(as.character(tools::md5sum(f))), e1$donnees) })
verifier("Empreintes : triangle Merz-Wuthrich, cellules non observees ecrites NA",
         grepl("^triangle;8;8\n", engine_empreinte(res_mw)$texte_donnees) &&
         grepl(";NA\n", engine_empreinte(res_mw)$texte_donnees, fixed = TRUE))

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
         grepl(sprintf("Le moteur a calculé %d lignes", nrow(tb)), principal, fixed = TRUE) &&
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
         grepl("test non conservé", ligne_de(annexe, tb$test[i_retire]), fixed = TRUE) &&
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
verifier("Rapport : selection NULL = selection par defaut",
         {
           f <- tempfile(fileext = ".html")
           r <- rapport_html(res_ln, NULL, f, interactif = FALSE, identite = idt)
           r$n_retenus == sum(filtrer_selection(tb, selection_defaut(tb)))
         })
verifier("Rapport : refus explicite sur un resultat refuse ou une selection d'un autre resultat",
         leve_erreur(rapport_html(run_engine(xt = xt[1:4], yt = yt[1:4], methode = "premium",
                                             segment = 1, B = 99), NULL, tempfile())) &&
         leve_erreur(rapport_html(res_ln, selection_defaut(engine_table_tests(res_mw)), tempfile())))

## --- Rapport fige, Merz-Wuthrich ----------------------------------------------
f_mw <- tempfile(fileext = ".html")
r_mw <- rapport_html(res_mw, NULL, f_mw, interactif = FALSE, identite = idt)
hm <- lire(f_mw)
tbm <- engine_table_tests(res_mw); rm <- filtrer_selection(tbm, selection_defaut(tbm))
verifier("Rapport MW : triangle du calcul restitue, cellules non observees en tiret",
         grepl("<td>2766.61</td>", hm, fixed = TRUE) && grepl("<td>–</td>", hm, fixed = TRUE))
verifier("Rapport MW : exclus par defaut en annexe avec leur verdict",
         any(!rm) && all(vapply(which(!rm), function(k)
           grepl(badge_verdict(tbm$verdict[k]),
                 ligne_de(entre(hm, "<section id='section-annexe-exclus'>", "</section>"), tbm$test[k]),
                 fixed = TRUE), logical(1))))
verifier("Rapport MW : formule racine(MSEP) / R, sans facteur de taille finie",
         grepl("racine(MSEP) / R", texte_formule(res_mw), fixed = TRUE) &&
         !grepl("(T+1)/(T-1)", texte_formule(res_mw), fixed = TRUE) &&
         grepl(.echap_html(texte_formule(res_mw)), hm, fixed = TRUE))
verifier("Rapport MW : aucune reference externe, empreintes presentes",
         compte(hm, "src=\"http") == 0 && compte(hm, "href=\"http") == 0 &&
         grepl(engine_empreinte(res_mw)$donnees, hm, fixed = TRUE))
if (png_ok)
  verifier("Rapport MW PNG : une image par graphique",
           compte(hm, "src='data:image/png;base64,iVBORw0KGgo") ==
             sum(vapply(.graphiques_rapport(res_mw), function(o) length(o$g), integer(1))) + 1L)

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
