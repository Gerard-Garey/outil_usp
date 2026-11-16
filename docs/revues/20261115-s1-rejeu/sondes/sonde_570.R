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
  "temoin sans colonne de plus (t, xt, yt)" = list(c("t", "xt", "yt"), c("t", "xt", "yt")))
remplacer <- list(B = NB, B2 = NB2, U8 = U8, L1 = L1, L1n = L1n, BOMB = BOMB, ASC = ASC)
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
