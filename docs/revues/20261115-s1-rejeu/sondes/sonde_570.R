# Usage : Rscript sonde_570.R <depot> <fichier_moteur>
# #570, S1 etape 6 (decision D-S1-4 du mainteneur, option a) : en-tete de
# colonne d'encodage "bytes" en appel direct d'engine_lire_donnees_csv().
# fichier_moteur : R/engine.R apres le correctif ; avant, la version extraite
# de cc6c9a9 (git show cc6c9a9:R/engine.R > fichier).
# Serie de reference : tests/donnees/donnees_ln.csv, lue comme par
# l'application (cellules en texte, en-tetes tels quels) ; une colonne de plus
# (valeur 0) porte le nom du cas. Nom "bytes" : octets 61 ff 62 ("a\xffb")
# declares "bytes". sigma_USP rendu par run_engine(premium, segment 1,
# annexe II, brutes) si engine_lire_donnees_csv() reussit. Chaque cas est
# protege par tryCatch() : une erreur R est relevee avec sa classe.
# Complement D-S1-19 (option 2) : cas "colonne 1 a prefixe de BOM" (X...,
# octets EF 2E 2E, X.U.FEFF. suivis de 61 ff 62 declares "bytes"), temoins
# (BOM brut + t, X... + 61 ff 62 non declare, prefixes + t declares "bytes")
# et bloc engine_lire_triangle() en fin de sortie ; avant = ba43923
# (git show ba43923:R/engine.R > fichier), sorties 570-bom-{avant,apres}.txt.
# Complement D-S1-26 : bloc triangle etendu (nom "bytes" en colonne > 1,
# plusieurs colonnes, matrice a noms de colonne "bytes", temoins ASCII,
# UTF-8, Latin-1 declare ou non, BOM + i ; noms de ligne "bytes", non lus).
# Les sorties 570-avant.txt et 570-apres.txt ont ete produites avant cet ajout.
a <- commandArgs(TRUE); depot <- normalizePath(a[1]); moteur <- normalizePath(a[2])
setwd(depot); source("R/charger_moteur.R"); e <- charger_moteur(moteur, dans = NULL)
cat(sprintf("moteur = %s ; R %s ; locale LC_CTYPE = %s\n", basename(moteur),
            paste(R.version$major, R.version$minor, sep = "."), Sys.getlocale("LC_CTYPE")))
LN <- utils::read.csv("tests/donnees/donnees_ln.csv", colClasses = "character", check.names = FALSE,
                      na.strings = character(0))
octets <- function(s) { x <- rawToChar(as.raw(s)); Encoding(x) <- "bytes"; x }
NB <- octets(c(0x61, 0xff, 0x62))
NB2 <- octets(c(0xe9, 0x74, 0xe9))
U8 <- "année"                                        # UTF-8 declare
L1 <- rawToChar(as.raw(c(0x61, 0x6e, 0x6e, 0xe9, 0x65))); Encoding(L1) <- "latin1"
L1n <- rawToChar(as.raw(c(0x61, 0x6e, 0x6e, 0xe9, 0x65)))  # Latin-1 non declare ("unknown")
BOMB <- octets(c(0xef, 0xbb, 0xbf, 0x61, 0xff, 0x62))      # BOM UTF-8 + octets, declare "bytes"
ASC <- "abc"; Encoding(ASC) <- "bytes"                     # R garde "unknown" sur une chaine ASCII
PREF <- list(X3 = c(0x58, 0x2e, 0x2e, 0x2e), EF = c(0xef, 0x2e, 0x2e), XU = as.integer(charToRaw("X.U.FEFF.")))
octets_nd <- function(s) rawToChar(as.raw(s))              # non declare ("unknown")
BX3 <- octets(c(PREF$X3, 0x61, 0xff, 0x62)); BEF <- octets(c(PREF$EF, 0x61, 0xff, 0x62))
BXU <- octets(c(PREF$XU, 0x61, 0xff, 0x62))
X3n <- octets_nd(c(PREF$X3, 0x61, 0xff, 0x62))             # X... + octets non declares
BOMt <- octets_nd(c(0xef, 0xbb, 0xbf, 0x74))               # BOM brut + t, non declare
EFt <- octets(c(PREF$EF, 0x74))                            # EF 2E 2E + t declare bytes (reste ASCII)
cat("Encoding(\"abc\" declare bytes) =", Encoding(ASC), "\n\n")
cas <- list(
  "bytes apres yt (t, xt, yt, B)"         = list(c("t", "xt", "yt", "B"), c("t", "xt", "yt", "0")),
  "bytes en tete (B, xt, yt)"             = list(c("B", "xt", "yt"), c("0", "xt", "yt")),
  "bytes avant xt (t, B, xt, yt)"         = list(c("t", "B", "xt", "yt"), c("t", "0", "xt", "yt")),
  "bytes entre xt et yt (t, xt, B, yt)"   = list(c("t", "xt", "B", "yt"), c("t", "xt", "0", "yt")),
  "bytes a la place de yt (t, xt, B)"     = list(c("t", "xt", "B"), c("t", "xt", "yt")),
  "deux bytes (B, t, xt, yt, B2)"         = list(c("B", "t", "xt", "yt", "B2"), c("0", "t", "xt", "yt", "0")),
  "bytes precede d'un BOM, colonne 1"     = list(c("BOMB", "t", "xt", "yt"), c("0", "t", "xt", "yt")),
  "bytes et t en double (t, xt, yt, t, B)" = list(c("t", "xt", "yt", "t", "B"), c("t", "xt", "yt", "t", "0")),
  "temoin ASCII (t, xt, yt, abc)"         = list(c("t", "xt", "yt", "abc"), c("t", "xt", "yt", "0")),
  "temoin ASCII declare bytes (t, xt, yt, ASC)" = list(c("t", "xt", "yt", "ASC"), c("t", "xt", "yt", "0")),
  "temoin UTF-8 (t, xt, yt, annee UTF-8)" = list(c("t", "xt", "yt", "U8"), c("t", "xt", "yt", "0")),
  "temoin Latin-1 declare (t, xt, yt, L1)" = list(c("t", "xt", "yt", "L1"), c("t", "xt", "yt", "0")),
  "temoin Latin-1 non declare (t, xt, yt, L1n)" = list(c("t", "xt", "yt", "L1n"), c("t", "xt", "yt", "0")),
  "temoin UTF-8 seul manquant (t, xt, U8)" = list(c("t", "xt", "U8"), c("t", "xt", "yt")),
  "temoin sans colonne de plus (t, xt, yt)" = list(c("t", "xt", "yt"), c("t", "xt", "yt")),
  "D-S1-19 : X... + bytes, colonne 1"      = list(c("BX3", "xt", "yt"), c("0", "xt", "yt")),
  "D-S1-19 : EF 2E 2E + bytes, colonne 1"  = list(c("BEF", "xt", "yt"), c("0", "xt", "yt")),
  "D-S1-19 : X.U.FEFF. + bytes, colonne 1" = list(c("BXU", "xt", "yt"), c("0", "xt", "yt")),
  "D-S1-19 temoin : BOM brut + t non declare" = list(c("BOMt", "xt", "yt"), c("t", "xt", "yt")),
  "D-S1-19 temoin : EF 2E 2E + t declare bytes" = list(c("EFt", "xt", "yt"), c("t", "xt", "yt")),
  "D-S1-19 temoin : X... + octets non declare" = list(c("X3n", "xt", "yt"), c("0", "xt", "yt")),
  "D-S1-19 temoin : ASCII t en colonne 1"  = list(c("t", "xt", "yt"), c("t", "xt", "yt")))
remplacer <- list(B = NB, B2 = NB2, U8 = U8, L1 = L1, L1n = L1n, BOMB = BOMB, ASC = ASC,
                  BX3 = BX3, BEF = BEF, BXU = BXU, X3n = X3n, BOMt = BOMt, EFt = EFt)
for (nm in names(cas)) {
  v <- cas[[nm]][[1]]; src <- cas[[nm]][[2]]
  d <- as.data.frame(lapply(src, function(s) if (s == "0") rep("0", nrow(LN)) else LN[[s]]),
                     stringsAsFactors = FALSE)
  noms <- vapply(v, function(s) if (s %in% names(remplacer)) remplacer[[s]] else s, "", USE.NAMES = FALSE)
  names(d) <- noms
  cat(sprintf("[%s]\n  Encoding(noms) = %s\n", nm, paste(Encoding(names(d)), collapse = ", ")))
  r <- tryCatch(e$engine_lire_donnees_csv(d), error = function(err) err)
  if (inherits(r, "error")) {
    cat(sprintf("  ERREUR R : classe = %s\n  message = %s\n\n", paste(class(r), collapse = "/"), conditionMessage(r)))
    next
  }
  cat("  engine_lire_donnees_csv : ok =", r$ok, "\n")
  if (!isTRUE(r$ok)) { cat("  erreurs :", r$erreurs, sep = "\n    "); cat("\n\n"); next }
  res <- e$run_engine(xt = r$xt, yt = r$yt, methode = "premium", segment = 1, annexe = "II", nature_donnees = "brutes")
  cat(sprintf("  run_engine : ok = %s, sigma_USP = %.10f\n\n", res$ok, res$parametre$sigma_usp))
}
# Bloc triangle (D-S1-19) : engine_lire_triangle() sur tests/donnees/triangle_mw.csv
# (cellules en texte), premier nom remplace ; "autres vides" : tous les autres
# noms "" (chemin de .ligne1_sans_valeur()). Reste 61 ff 62 (non UTF-8), c3 a9
# (e accentue UTF-8), e3 80 80 (U+3000, blanc), i + e3 80 80 ; prefixes X...,
# EF 2E 2E, X.U.FEFF. et BOM brut, declares "bytes".
cat("== engine_lire_triangle, premier nom ==\n")
TR <- utils::read.csv("tests/donnees/triangle_mw.csv", colClasses = "character", check.names = FALSE,
                      na.strings = character(0))
RESTE <- list("61 ff 62" = c(0x61, 0xff, 0x62), "c3 a9" = c(0xc3, 0xa9), "e3 80 80" = c(0xe3, 0x80, 0x80),
              "i e3 80 80" = c(0x69, 0xe3, 0x80, 0x80))
for (p in c(names(PREF), "BOM")) for (q in names(RESTE)) for (vide in c(FALSE, TRUE)) {
  d <- TR; if (vide) names(d) <- rep("", ncol(d))
  names(d)[1] <- octets(c(if (p == "BOM") c(0xef, 0xbb, 0xbf) else PREF[[p]], RESTE[[q]]))
  r <- tryCatch(e$engine_lire_triangle(d), error = function(err) err)
  cat(sprintf("[%s + %s bytes, autres noms %s] ", p, q, if (vide) "vides" else "j0..j7"))
  if (inherits(r, "error")) { cat("ERREUR R :", conditionMessage(r), "\n"); next }
  cat("ok =", r$ok, if (isTRUE(r$ok)) sprintf("I = %d, somme = %.2f", r$I, sum(r$triangle, na.rm = TRUE)) else
    paste(r$erreurs, collapse = " | "), "\n")
}
# Bloc triangle (D-S1-26) : autres places et temoins. "=ref" : liste rendue
# identique a celle du triangle lu sans modification.
cat("\n== engine_lire_triangle, autres places et temoins ==\n")
ref <- e$engine_lire_triangle(TR)
L1 <- rawToChar(as.raw(c(0x61, 0x6e, 0x6e, 0xe9, 0x65))); Encoding(L1) <- "latin1"
ASCb <- "j7"; Encoding(ASCb) <- "bytes"
mod <- function(k, v, base = names(TR)) { n <- base; n[k] <- v; n }
vid <- rep("", ncol(TR))
cas_t <- list(
  "bytes en colonne 4, autres renseignes"      = mod(4, list(NB)),
  "bytes en colonne 4, autres vides"           = mod(4, list(NB), vid),
  "bytes en colonnes 2 et 9"                   = mod(c(2, 9), list(NB, NB2)),
  "bytes en colonnes 1 et 3, autres vides"     = mod(c(1, 3), list(NB2, NB), vid),
  "bytes en colonne 9, colonne 1 nommee j"     = mod(c(1, 9), list("j", NB)),
  "temoin ASCII declare bytes en colonne 9"    = mod(9, list(ASCb)),
  "temoin UTF-8 en colonne 9"                  = mod(9, list(U8)),
  "temoin Latin-1 declare en colonne 9"        = mod(9, list(L1)),
  "temoin Latin-1 non declare en colonne 9"    = mod(9, list(L1n)),
  "temoin BOM brut + i non declare, colonne 1" = mod(1, list(octets_nd(c(0xef, 0xbb, 0xbf, 0x69)))),
  "temoin EF 2E 2E + i declare bytes, colonne 1" = mod(1, list(octets(c(PREF$EF, 0x69)))))
aff <- function(nm, r) {
  cat(sprintf("[%s] ", nm))
  if (inherits(r, "error")) { cat("ERREUR R :", conditionMessage(r), "\n"); return(invisible()) }
  cat("ok =", r$ok, if (identical(r, ref)) "=ref" else "", if (isTRUE(r$ok))
    sprintf("I = %d, somme = %.2f", r$I, sum(r$triangle, na.rm = TRUE)) else paste(r$erreurs, collapse = " | "), "\n")
}
for (nm in names(cas_t)) {
  d <- TR; names(d) <- vapply(cas_t[[nm]], function(z) z, "")
  aff(nm, tryCatch(e$engine_lire_triangle(d), error = function(err) err))
}
m <- as.matrix(TR); colnames(m)[3] <- NB
aff("matrice, nom de colonne 3 bytes", tryCatch(e$engine_lire_triangle(m), error = function(err) err))
d <- TR; rn <- as.character(seq_len(nrow(d))); rn[3] <- NB; rownames(d) <- rn
aff("data.frame, nom de ligne 3 bytes (non lu)", tryCatch(e$engine_lire_triangle(d), error = function(err) err))
