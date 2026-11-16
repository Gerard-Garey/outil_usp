# Usage : LC_ALL=<locale> Rscript sonde_588.R <depot> <fichier_moteur>
# #588, S1 etape 7 (decisions D-S1-7 et D-S1-8 du mainteneur) : texte cite
# par .echapper_texte() pour un nom declare Latin-1, et faux doublon
# Latin-1 / ASCII de mw_valider_triangle() (constat hors perimetre n. 1 de
# l'avis amont d'actuary).
# fichier_moteur : R/engine.R apres le correctif ; avant, la version extraite
# de 7351725 (git show 7351725:R/engine.R > fichier).
# Sorties 588-avant.txt et 588-apres.txt : la sonde lancee sous LC_ALL=C.UTF-8
# puis sous LC_ALL=C, sorties concatenees.
# Blocs :
#  1. les 128 octets 0x80-0xFF, chacun dans "a<octet>b" declare Latin-1 :
#     texte rendu par .echapper_texte() (sans guillemets) ;
#  2. attendu de l'assertion #522 (cols522 de test_controles_entree.R) ;
#  3. mw_valider_triangle() sur un triangle 5 x 5 dont les noms de ligne
#     portent "a\x81b" declare Latin-1 et "a<81>b" ASCII, puis les memes avec
#     0x8D, 0x8F, 0x90, 0x9D ; temoin : vrai doublon Latin-1 "\xe9t\xe9" et
#     UTF-8 "ete" accentue ;
#  4. motifs des autres appelants pour un en-tete Latin-1 a octet 0x81
#     (colonnes presentes apres un t en double, colonne vide a en-tete du
#     triangle).
a <- commandArgs(TRUE); depot <- normalizePath(a[1]); moteur <- normalizePath(a[2])
setwd(depot); source("R/charger_moteur.R"); e <- charger_moteur(moteur, dans = NULL)
cat(sprintf("moteur = %s ; R %s ; locale LC_CTYPE = %s ; UTF-8 = %s\n", basename(moteur),
            paste(R.version$major, R.version$minor, sep = "."), Sys.getlocale("LC_CTYPE"),
            isTRUE(l10n_info()[["UTF-8"]])))
l1 <- function(b) { x <- rawToChar(as.raw(c(0x61, b, 0x62))); Encoding(x) <- "latin1"; x }
# Sortie ASCII seule (les deux locales l'ecrivent de la meme facon) : chaque
# caractere non ASCII du texte rendu est montre U+XXXX entre crochets.
montrer <- function(s) {
  if (is.na(s)) return("NA")
  cp <- utf8ToInt(enc2utf8(s))
  if (anyNA(cp)) return(paste0("<non UTF-8 : ", paste(charToRaw(s), collapse = " "), ">"))
  paste(vapply(cp, function(c) if (c < 128L) intToUtf8(c) else sprintf("[U+%04X]", c), ""), collapse = "")
}
cat("\n== 1. .echapper_texte(\"a<octet>b\" declare Latin-1)\n")
for (b in 0x80:0xFF)
  cat(sprintf("%02X  %s\n", b, montrer(e$.echapper_texte(l1(b)))))

cat("\n== 2. Assertion #522 : Colonnes presentes pour 0xA0, 0x81, 0xE9 declares Latin-1\n")
cols <- function(noms) {
  d <- as.data.frame(matrix("1", 1L, length(noms)), stringsAsFactors = FALSE)
  names(d) <- noms
  r <- e$engine_lire_donnees_csv(d)
  sub("^.*Colonnes presentes : (.*)\\.$", "\\1", r$erreurs)
}
cat(montrer(cols(c(l1(0xa0), l1(0x81), l1(0xe9)))), "\n")

cat("\n== 3. mw_valider_triangle() : nom Latin-1 a octet C1 non defini et nom ASCII \"a<xx>b\"\n")
tri <- function(n) {
  m <- matrix(NA_real_, n, n)
  for (i in 1:n) for (j in 1:(n - i + 1)) m[i, j] <- (100 + 10 * i + j) * 1.3^(j - 1)
  m
}
for (b in c(0x81, 0x8D, 0x8F, 0x90, 0x9D)) {
  m <- tri(5); rownames(m) <- c(l1(b), sprintf("a<%02x>b", b), "2", "3", "4")
  r <- e$mw_valider_triangle(m)
  cat(sprintf("%02X  ok = %s ; erreurs = %s\n", b, r$ok,
              if (length(r$erreurs)) paste(vapply(r$erreurs, montrer, ""), collapse = " | ") else "(aucune)"))
}
m <- tri(5); ete <- rawToChar(as.raw(c(0xe9, 0x74, 0xe9))); Encoding(ete) <- "latin1"
rownames(m) <- c(ete, "été", "2", "3", "4")
r <- e$mw_valider_triangle(m)
cat(sprintf("temoin ete Latin-1 / UTF-8  ok = %s ; erreurs = %s\n", r$ok,
            paste(vapply(r$erreurs, montrer, ""), collapse = " | ")))

cat("\n== 4. Autres motifs citant un en-tete Latin-1 a octet 0x81\n")
n81 <- l1(0x81)
# colonne t en double ("t" et "T") et yt manquant : les deux motifs, le
# second cite le nom 0x81 parmi les colonnes presentes
d2 <- data.frame(a = "1", b = "2", c = "3", d = "4", stringsAsFactors = FALSE)
names(d2) <- c("t", "T", "xt", n81)
cat("t en double + yt manquant : ", montrer(paste(e$engine_lire_donnees_csv(d2)$erreurs, collapse = " | ")), "\n")
tc <- as.data.frame(matrix(c("100", "110", "120", "130", "140",
                             "130", "140", "150", "160", "",
                             "170", "180", "190", "", "",
                             "200", "210", "", "", "",
                             "250", "", "", "", ""), 5, 5), stringsAsFactors = FALSE)
tc[["vide"]] <- ""
names(tc) <- c("0", "1", "2", "3", "4", n81)
cat("triangle, colonne vide a en-tete 0x81 : ", montrer(paste(e$engine_lire_triangle(tc)$erreurs, collapse = " | ")), "\n")
