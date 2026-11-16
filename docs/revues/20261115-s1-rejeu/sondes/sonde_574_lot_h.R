# Usage : Rscript sonde_574_lot_h.R <depot> <dossier_sondes> <fichier_moteur> [<cas>]
# #574, S1, lot H : decision D-S1-37 du mainteneur (H1 de l'audit leger du
# lot G) et mineurs m1, m2 de cet audit.
#  - D-S1-37 : relations forgees qui font lire a openxlsx une autre feuille
#    que la voie de repli : Id="rId1" dans la valeur d'un autre attribut
#    d'une relation (a), r:id="rId2" dans un nom de feuille (b), attribut Id
#    repete (c) ou prefixe (d), deux relations de meme Id (e) ; variantes
#    mesurees par le correctif (r:id entre apostrophes, a blancs autour de =,
#    precede d'une tabulation, vide, non alphanumerique ; id sans prefixe,
#    x:id, r:id repete ; nom de feuille portant ">" ; RelId="rId1").
#  - m1 : </sheetData> puis <sheetData> (permutees) : l'ouvrante non fermee
#    est citee avec la fermante en surnombre.
#  - M1 de l'audit leger du lot H : openxlsx colle les lignes de
#    xl/workbook.xml et des relations (readLines() puis paste(collapse =
#    "")) : r:id<LF>=" ou r:id<CR>=" dans un nom de feuille, Id<LF>=" dans
#    la valeur d'un autre attribut d'une relation, <LF> seul devant r:id
#    (refus) ; espace puis <LF> devant r:id, Id<LF>="rId1" de la relation
#    retenue, workbook.xml et relations en fins de ligne CRLF (temoins).
#  - limite connue (D-S1-38, cible Target hors du controle) :
#    Target='...sheet1.xml' x:Target="...sheet2.xml" et
#    Target='...sheet1.xml' Foo='Target="...sheet2.xml"'.
#  - temoins : classeur forge ordinaire, deux feuilles ordinaires, attributs
#    entre apostrophes et a blancs (une feuille, #487), r:id dans une autre
#    balise que <sheet> (externalReference), r:id='rId2' dans un nom,
#    classeur de l'ecrivain interne, classeur d'openxlsx::write.xlsx() a deux
#    feuilles (ecrit par un sous-processus si openxlsx n'est pas dans
#    .libPaths() : bibliotheque donnee par la variable OPENXLSX_LIB).
# Sans <cas> : chaque cas est rejoue dans son propre sous-processus Rscript
# (un arret n'interrompt pas la sonde), code de sortie releve.
# Chemin : openxlsx s'il est dans .libPaths() (R_LIBS), lecteur interne sinon.
# fichier_moteur : R/engine.R apres le correctif ; avant, la version extraite
# de la tete (git show 5950e03:R/engine.R > fichier).
# Serie de reference (tests/donnees/donnees_ln.csv) ; sigma_USP rendu par
# run_engine(premium, segment 1, annexe II, brutes) si la lecture et
# engine_lire_donnees_csv() reussissent. La feuille 2 (et 3) porte 999 en B2 :
# B2 lu 999 signale une autre feuille lue. Lecture attendue ecrite apres
# "attendu" pour chaque cas.
a <- commandArgs(TRUE); depot <- normalizePath(a[1]); sd <- normalizePath(a[2]); moteur <- normalizePath(a[3])
CAS <- c(# D-S1-37, formes de l'audit
         "a-rels-id-dans-valeur", "b-workbook-rid-dans-nom", "c-rels-id-repete", "d-rels-id-prefixe",
         "e-rels-id-en-double",
         # variantes mesurees par le correctif
         "rels-relid", "workbook-rid-apostrophes-2-feuilles", "workbook-rid-blancs-2-feuilles",
         "workbook-rid-tabulation-2-feuilles", "workbook-rid-vide-3-feuilles", "workbook-rid-non-alphanumerique",
         "workbook-id-sans-prefixe", "workbook-x-id", "workbook-rid-repete", "workbook-nom-chevron",
         # m1
         "m1-sheetdata-permutees",
         # M1 de l'audit leger du lot H (texte colle par openxlsx)
         "m1h-workbook-rid-lf-dans-nom", "m1h-workbook-rid-cr-dans-nom", "m1h-rels-id-lf-dans-valeur",
         "m1h-workbook-lf-seul-avant-rid",
         "temoin-m1h-espace-lf-avant-rid", "temoin-m1h-rels-id-lf-retenu", "temoin-m1h-crlf",
         # limite connue (D-S1-38)
         "limite-target-x-target", "limite-target-dans-valeur",
         # temoins
         "temoin-forge", "temoin-deux-feuilles", "temoin-apostrophes-une-feuille", "temoin-blancs-une-feuille",
         "temoin-rels-id-apostrophes", "temoin-externalreference", "temoin-rid-apostrophes-dans-nom",
         "temoin-ecrivain-interne", "temoin-openxlsx-deux-feuilles")
if (length(a) < 4) {
  self <- normalizePath(sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE)))
  for (c in CAS) {
    out <- suppressWarnings(system2(file.path(R.home("bin"), "Rscript"), shQuote(c(self, depot, sd, moteur, c)),
                                    stdout = TRUE, stderr = TRUE, timeout = 300))
    st <- attr(out, "status"); if (is.null(st)) st <- 0L
    cat(out, sep = "\n"); cat(sprintf("  [code de sortie : %d]\n\n", st))
  }
  quit(save = "no")
}
cas <- a[4]
setwd(depot); source("R/charger_moteur.R"); e <- charger_moteur(moteur, dans = NULL)
source(file.path(sd, "forge.R"))
avec_ox <- requireNamespace("openxlsx", quietly = TRUE)
chemin <- if (avec_ox) paste("openxlsx", as.character(packageVersion("openxlsx"))) else "interne"
cat(sprintf("[%s] chemin = %s ; moteur = %s\n", cas, chemin, basename(moteur)))
lire_serie <- function(f) {
  w <- character(0)
  df <- tryCatch(withCallingHandlers(e$engine_lire_xlsx(f),
                   warning = function(x) { w <<- c(w, conditionMessage(x)); invokeRestart("muffleWarning") }),
                 error = function(err) err)
  if (length(w)) cat(sprintf("  avertissements R : %d (premier : %s)\n", length(w), substr(w[1], 1, 60)))
  if (inherits(df, "error")) {
    cat(sprintf("  ERREUR classe = %s\n  message = %s\n\n", class(df)[1], conditionMessage(df))); return(invisible(NULL))
  }
  cat(sprintf("  lu : %d x %d ; noms = %s ; B2 lu = %s\n", nrow(df), ncol(df),
              encodeString(paste(names(df), collapse = ",")), encodeString(format(df[[2]][1], digits = 15), quote = '"')))
  r <- e$engine_lire_donnees_csv(df)
  cat(sprintf("  engine_lire_donnees_csv : ok = %s\n", r$ok))
  if (r$ok) {
    cat(sprintf("  xt retenu : %s\n", paste(format(r$xt, digits = 15), collapse = " ")))
    res <- tryCatch(e$run_engine(xt = r$xt, yt = r$yt, methode = "premium", segment = 1, annexe = "II", nature_donnees = "brutes"),
                    error = function(err) err)
    if (inherits(res, "error")) cat("  run_engine : ERREUR", conditionMessage(res), "\n")
    else if (isTRUE(res$ok)) cat(sprintf("  run_engine : ok = TRUE, sigma_USP = %.10f\n", res$parametre$sigma_usp))
    else cat("  run_engine : ok = FALSE ;", head(res$validation$erreurs, 2), sep = "\n    ")
  } else cat("  erreurs :", r$erreurs, sep = "\n    ")
  cat("\n")
}
# Retouches d'un classeur forge : liste de c(partie, de, vers) (sub fixe sur
# le texte de la partie) ; feuilles : nombre de feuilles copiees de sheet1.xml
# (sheet2.xml, sheet3.xml...) ou B2 vaut 999.
retoucher <- function(f, modifs, feuilles = 0L) {
  d <- tempfile("loth_"); dir.create(d); utils::unzip(f, exdir = d)
  lire_p <- function(p) rawToChar(readBin(file.path(d, p), "raw", file.info(file.path(d, p))$size))
  ecr_p <- function(p, x) writeBin(charToRaw(x), file.path(d, p))
  for (k in seq_len(feuilles)) {
    ecr_p(sprintf("xl/worksheets/sheet%d.xml", k + 1L), sub("<v>104.2</v>", "<v>999</v>", lire_p("xl/worksheets/sheet1.xml"), fixed = TRUE))
    ecr_p("[Content_Types].xml", sub("</Types>", sprintf('<Override PartName="/xl/worksheets/sheet%d.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/></Types>', k + 1L),
                                     lire_p("[Content_Types].xml"), fixed = TRUE))
  }
  for (m in modifs) { x <- lire_p(m[1]); stopifnot(grepl(m[2], x, fixed = TRUE)); ecr_p(m[1], sub(m[2], m[3], x, fixed = TRUE)) }
  od <- setwd(d); on.exit(setwd(od)); unlink(f)
  stopifnot(system2("zip", c("-r9Xq", shQuote(f), "[Content_Types].xml", "_rels", "xl")) == 0); f
}
WB <- "xl/workbook.xml"; RL <- "xl/_rels/workbook.xml.rels"; FS <- "xl/worksheets/sheet1.xml"
TW <- 'Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet"'
REL1 <- '<Relationship Id="rId1"'; SH1 <- '<sheet name="Donnees" sheetId="1" r:id="rId1"/>'
rel <- function(id, k, att = paste0('Id="', id, '"')) sprintf('<Relationship %s %s Target="worksheets/sheet%d.xml"/>', att, TW, k)
fin_rels <- function(...) c(RL, "</Relationships>", paste0(..., "</Relationships>"))
fin_sheets <- function(...) c(WB, "</sheets>", paste0(..., "</sheets>"))
sh <- function(nom, k, att) sprintf('<sheet name="%s" sheetId="%d" %s/>', nom, k, att)
f0 <- function() forger(serie())
switch(cas,
  "a-rels-id-dans-valeur" = {
    cat("  relations : <Relationship Id=\"rIdQ\" ... Foo='Id=\"rId1\"' Target=\"worksheets/sheet2.xml\"/> avant la vraie ; attendu apres : refus nommant xl/_rels/workbook.xml.rels ; avant : 104.2 interne, 999 openxlsx\n")
    lire_serie(retoucher(f0(), list(c(RL, REL1, paste0(rel("rIdQ", 2L, 'Id="rIdQ" Foo=\'Id="rId1"\''), REL1))), 1L)) },
  "b-workbook-rid-dans-nom" = {
    cat("  classeur : <sheet name='a r:id=\"rId2\"' ... r:id=\"rId1\"/>, rId2 -> sheet2.xml ; attendu apres : refus nommant xl/workbook.xml ; avant : 104.2 interne, 999 openxlsx\n")
    lire_serie(retoucher(f0(), list(fin_rels(rel("rId2", 2L)), c(WB, 'name="Donnees"', "name='a r:id=\"rId2\"'")), 1L)) },
  "c-rels-id-repete" = {
    cat("  relations : <Relationship Id=\"rId9\" Id=\"rId1\" ... sheet2.xml/> avant la vraie ; attendu apres : refus (attribut Id repete) ; avant : 104.2 interne, 999 openxlsx\n")
    lire_serie(retoucher(f0(), list(c(RL, REL1, paste0(rel("rId9", 2L, 'Id="rId9" Id="rId1"'), REL1))), 1L)) },
  "d-rels-id-prefixe" = {
    cat("  relations : <Relationship x:Id=\"rId9\" Id=\"rId1\" ... sheet2.xml/> avant la vraie ; attendu apres : refus (attribut Id prefixe) ; avant : 104.2 interne, 999 openxlsx\n")
    lire_serie(retoucher(f0(), list(c(RL, REL1, paste0(rel("rId9", 2L, 'x:Id="rId9" Id="rId1"'), REL1))), 1L)) },
  "e-rels-id-en-double" = {
    cat("  relations : deux <Relationship Id=\"rId1\">, sheet2.xml d'abord ; attendu apres : refus (Id en double) ; avant : 999 sur les deux chemins\n")
    lire_serie(retoucher(f0(), list(c(RL, REL1, paste0(rel("rId1", 2L), REL1))), 1L)) },
  "rels-relid" = {
    cat("  relations : <Relationship RelId=\"rId1\" Id=\"rIdQ\" ... sheet2.xml/> avant la vraie ; attendu apres : refus (texte Id=\"rId1\" hors de l'attribut) ; avant : 104.2 interne, 999 openxlsx\n")
    lire_serie(retoucher(f0(), list(c(RL, REL1, paste0(rel("rIdQ", 2L, 'RelId="rId1" Id="rIdQ"'), REL1))), 1L)) },
  "workbook-rid-apostrophes-2-feuilles" = {
    cat("  classeur : feuille 1 r:id='rId1', feuille 2 r:id=\"rId2\" (sheet2.xml) ; attendu apres : refus (un autre lecteur designe une autre relation) ; avant : 104.2 interne, 999 openxlsx\n")
    lire_serie(retoucher(f0(), list(fin_rels(rel("rId2", 2L)), fin_sheets(sh("Autre", 2L, 'r:id="rId2"')), c(WB, 'r:id="rId1"', "r:id='rId1'")), 1L)) },
  "workbook-rid-blancs-2-feuilles" = {
    cat("  classeur : feuille 1 r:id = \"rId1\", feuille 2 r:id=\"rId2\" ; attendu apres : refus ; avant : 104.2 interne, 999 openxlsx\n")
    lire_serie(retoucher(f0(), list(fin_rels(rel("rId2", 2L)), fin_sheets(sh("Autre", 2L, 'r:id="rId2"')), c(WB, 'r:id="rId1"', 'r:id = "rId1"')), 1L)) },
  "workbook-rid-tabulation-2-feuilles" = {
    cat("  classeur : feuille 1 <TAB>r:id=\"rId1\", feuille 2 r:id=\"rId2\" ; attendu apres : refus ; avant : 104.2 interne, 999 openxlsx\n")
    lire_serie(retoucher(f0(), list(fin_rels(rel("rId2", 2L)), fin_sheets(sh("Autre", 2L, 'r:id="rId2"')), c(WB, ' r:id="rId1"', '\tr:id="rId1"')), 1L)) },
  "workbook-rid-vide-3-feuilles" = {
    cat("  classeur : feuille 1 r:id=\"\", feuille 2 r:id=\"rId2\" (sheet2.xml, 999), feuille 3 r:id=\"rId3\" (sheet1.xml) ; attendu apres : refus ; avant : 999 interne, 104.2 openxlsx\n")
    lire_serie(retoucher(f0(), list(fin_rels(rel("rId2", 2L), sprintf('<Relationship Id="rId3" %s Target="worksheets/sheet1.xml"/>', TW)),
                                    fin_sheets(sh("Autre", 2L, 'r:id="rId2"'), sh("Trois", 3L, 'r:id="rId3"')),
                                    c(WB, 'sheetId="1" r:id="rId1"', 'sheetId="1" r:id=""')), 1L)) },
  "workbook-rid-non-alphanumerique" = {
    cat("  classeur : r:id=\"rId-1\" (relation rId-1 -> sheet1.xml) et relation rId -> sheet2.xml ; attendu apres : refus ; avant : 104.2 interne, 999 openxlsx\n")
    lire_serie(retoucher(f0(), list(fin_rels(rel("rId", 2L)), c(WB, 'r:id="rId1"', 'r:id="rId-1"'), c(RL, 'Id="rId1"', 'Id="rId-1"')), 1L)) },
  "workbook-id-sans-prefixe" = {
    cat("  classeur : feuille 1 id=\"rId2\" r:id=\"rId1\" (rId2 -> sheet2.xml) ; attendu apres : refus (attribut id sans prefixe) ; avant : 999 interne, 104.2 openxlsx\n")
    lire_serie(retoucher(f0(), list(fin_rels(rel("rId2", 2L)), c(WB, 'r:id="rId1"', 'id="rId2" r:id="rId1"')), 1L)) },
  "workbook-x-id" = {
    cat("  classeur : feuille 1 x:id=\"rId2\" r:id=\"rId1\" (rId2 -> sheet2.xml) ; attendu apres : refus (attribut x:id) ; avant : 999 interne, 104.2 openxlsx\n")
    lire_serie(retoucher(f0(), list(fin_rels(rel("rId2", 2L)), c(WB, 'r:id="rId1"', 'x:id="rId2" r:id="rId1"')), 1L)) },
  "workbook-rid-repete" = {
    cat("  classeur : feuille 1 r:id=\"rId2\" r:id=\"rId1\" (rId2 -> sheet2.xml) ; attendu apres : refus (r:id repete) ; avant : 999 interne, mesure openxlsx\n")
    lire_serie(retoucher(f0(), list(fin_rels(rel("rId2", 2L)), c(WB, 'r:id="rId1"', 'r:id="rId2" r:id="rId1"')), 1L)) },
  "workbook-nom-chevron" = {
    cat("  classeur : feuille 1 name=\"a>b\" (balise coupee au \">\" par les deux lecteurs), feuille 2 r:id=\"rId2\" ; attendu apres : refus (r:id absent de la balise lue) ; avant : 999 interne, erreur openxlsx\n")
    lire_serie(retoucher(f0(), list(fin_rels(rel("rId2", 2L)), fin_sheets(sh("Autre", 2L, 'r:id="rId2"')), c(WB, 'name="Donnees"', 'name="a>b"')), 1L)) },
  "m1-sheetdata-permutees" = {
    cat("  feuille : </sheetData>...<sheetData> (permutees) ; attendu apres : refus R3 citant </sheetData> et <sheetData> ; avant : refus citant </sheetData> seule\n")
    lire_serie(retoucher(f0(), list(c(FS, "<sheetData>", "@@"), c(FS, "</sheetData>", "<sheetData>"), c(FS, "@@", "</sheetData>")))) },
  "m1h-workbook-rid-lf-dans-nom" = {
    cat("  classeur : <sheet name='a r:id<LF>=\"rId2\"' ... r:id=\"rId1\"/>, rId2 -> sheet2.xml ; attendu apres : refus nommant xl/workbook.xml ; avant : 104.2 interne, 999 openxlsx\n")
    lire_serie(retoucher(f0(), list(fin_rels(rel("rId2", 2L)), c(WB, 'name="Donnees"', "name='a r:id\n=\"rId2\"'")), 1L)) },
  "m1h-workbook-rid-cr-dans-nom" = {
    cat("  classeur : <sheet name='a r:id<CR>=\"rId2\"' ... r:id=\"rId1\"/>, rId2 -> sheet2.xml ; attendu apres : refus nommant xl/workbook.xml ; avant : 104.2 interne, 999 openxlsx\n")
    lire_serie(retoucher(f0(), list(fin_rels(rel("rId2", 2L)), c(WB, 'name="Donnees"', "name='a r:id\r=\"rId2\"'")), 1L)) },
  "m1h-rels-id-lf-dans-valeur" = {
    cat("  relations : <Relationship Id=\"rIdQ\" ... Foo='Id<LF>=\"rId1\"' Target=\"worksheets/sheet2.xml\"/> avant la vraie ; attendu apres : refus nommant xl/_rels/workbook.xml.rels ; avant : 104.2 interne, 999 openxlsx\n")
    lire_serie(retoucher(f0(), list(c(RL, REL1, paste0(rel("rIdQ", 2L, "Id=\"rIdQ\" Foo='Id\n=\"rId1\"'"), REL1))), 1L)) },
  "m1h-workbook-lf-seul-avant-rid" = {
    cat("  classeur : feuille 1 sheetId=\"1\"<LF>r:id=\"rId1\" (colle : plus de blanc devant r:id), feuille 2 r:id=\"rId2\" ; attendu apres : refus nommant xl/workbook.xml ; avant (5950e03) : 104.2 interne, 999 openxlsx\n")
    lire_serie(retoucher(f0(), list(fin_rels(rel("rId2", 2L)), fin_sheets(sh("Autre", 2L, 'r:id="rId2"')), c(WB, ' r:id="rId1"', '\nr:id="rId1"')), 1L)) },
  "temoin-m1h-espace-lf-avant-rid" = {
    cat("  classeur : feuille 1 sheetId=\"1\" <LF>r:id=\"rId1\" (espace garde au collage), feuille 2 r:id=\"rId2\" ; attendu : 104.2 (refuse a tort par le lot H avant M1)\n")
    lire_serie(retoucher(f0(), list(fin_rels(rel("rId2", 2L)), fin_sheets(sh("Autre", 2L, 'r:id="rId2"')), c(WB, ' r:id="rId1"', ' \nr:id="rId1"')), 1L)) },
  "temoin-m1h-rels-id-lf-retenu" = {
    cat("  relations : relation retenue Id<LF>=\"rId1\", deux feuilles ; attendu : 104.2\n")
    lire_serie(retoucher(f0(), list(fin_rels(rel("rId2", 2L)), fin_sheets(sh("Autre", 2L, 'r:id="rId2"')), c(RL, 'Id="rId1"', 'Id\n="rId1"')), 1L)) },
  "temoin-m1h-crlf" = {
    cat("  xl/workbook.xml et xl/_rels/workbook.xml.rels ecrits en fins de ligne CRLF, deux feuilles ; attendu : 104.2\n")
    lire_serie(retoucher(f0(), list(fin_rels(rel("rId2", 2L)), fin_sheets(sh("Autre", 2L, 'r:id="rId2"')),
                                    c(WB, "?><workbook", "?>\r\n<workbook"), c(WB, "<sheets>", "\r\n<sheets>\r\n"),
                                    c(WB, '"/><sheet ', '"/>\r\n<sheet '), c(WB, "</sheets>", "\r\n</sheets>\r\n"),
                                    c(RL, "?><Relationships", "?>\r\n<Relationships"), c(RL, '"/><Relationship ', '"/>\r\n<Relationship ')), 1L)) },
  "limite-target-x-target" = {
    cat("  relations : Target='worksheets/sheet1.xml' x:Target=\"worksheets/sheet2.xml\" (relation de la feuille lue) ; limite connue (D-S1-38, hors du controle) : 104.2 interne, 999 openxlsx\n")
    lire_serie(retoucher(f0(), list(c(RL, 'Target="worksheets/sheet1.xml"', "Target='worksheets/sheet1.xml' x:Target=\"worksheets/sheet2.xml\"")), 1L)) },
  "limite-target-dans-valeur" = {
    cat("  relations : Target='worksheets/sheet1.xml' Foo='Target=\"worksheets/sheet2.xml\"' ; limite connue (D-S1-38, hors du controle) : 104.2 interne, 999 openxlsx\n")
    lire_serie(retoucher(f0(), list(c(RL, 'Target="worksheets/sheet1.xml"', "Target='worksheets/sheet1.xml' Foo='Target=\"worksheets/sheet2.xml\"'")), 1L)) },
  "temoin-forge" = {
    cat("  classeur forge ordinaire ; attendu : 104.2, sigma_USP de la serie\n")
    lire_serie(f0()) },
  "temoin-deux-feuilles" = {
    cat("  deux feuilles ordinaires (sheet2.xml : 999) ; attendu : 104.2\n")
    lire_serie(retoucher(f0(), list(fin_rels(rel("rId2", 2L)), fin_sheets(sh("Autre", 2L, 'r:id="rId2"'))), 1L)) },
  "temoin-apostrophes-une-feuille" = {
    cat("  une feuille, r:id='rId1' et Id='rId1' (#487) ; attendu : 104.2 interne, erreur R d'openxlsx (inchange)\n")
    lire_serie(retoucher(f0(), list(c(WB, 'r:id="rId1"', "r:id='rId1'"), c(RL, 'Id="rId1"', "Id='rId1'")))) },
  "temoin-blancs-une-feuille" = {
    cat("  une feuille, r:id = \"rId1\" (#487) ; attendu : 104.2 interne, erreur R d'openxlsx (inchange)\n")
    lire_serie(retoucher(f0(), list(c(WB, 'r:id="rId1"', 'r:id = "rId1"')))) },
  "temoin-rels-id-apostrophes" = {
    cat("  relations : Id='rId1' (une feuille) ; attendu : 104.2 interne, erreur R d'openxlsx (inchange)\n")
    lire_serie(retoucher(f0(), list(c(RL, 'Id="rId1"', "Id='rId1'")))) },
  "temoin-externalreference" = {
    cat("  classeur : <externalReferences><externalReference r:id=\"rId1\"/></externalReferences> apres </sheets> ; attendu : 104.2 (r:id hors des balises <sheet> non vise)\n")
    lire_serie(retoucher(f0(), list(c(WB, "</sheets>", '</sheets><externalReferences><externalReference r:id="rId1"/></externalReferences>')))) },
  "temoin-rid-apostrophes-dans-nom" = {
    cat("  classeur : name=\"a r:id='rId2' b\" (#487 ; forme que openxlsx ne lit pas comme r:id) ; attendu : 104.2\n")
    lire_serie(retoucher(f0(), list(fin_rels(rel("rId2", 2L)), c(WB, 'name="Donnees"', "name=\"a r:id='rId2' b\"")), 1L)) },
  "temoin-ecrivain-interne" = {
    cat("  classeur de engine_ecrire_xlsx() (serie de reference) ; attendu : 104.2\n")
    f <- tempfile(fileext = ".xlsx"); e$engine_ecrire_xlsx(data.frame(t = LN$t, xt = LN$xt, yt = LN$yt), f)
    lire_serie(f) },
  "temoin-openxlsx-deux-feuilles" = {
    cat("  classeur d'openxlsx::write.xlsx(list(Donnees = serie, Autre = serie avec B2 = 999)) ; attendu : 104.2\n")
    f <- tempfile(fileext = ".xlsx")
    ecr <- sprintf('d <- data.frame(t = 1:8, xt = c(%s), yt = c(%s)); d2 <- d; d2$xt[1] <- 999; openxlsx::write.xlsx(list(Donnees = d, Autre = d2), "%s"); cat(as.character(packageVersion("openxlsx")))',
                   paste(LN$xt, collapse = ", "), paste(LN$yt, collapse = ", "), f)
    v <- if (avec_ox) { invisible(capture.output(eval(parse(text = ecr)))); "" } else
      system2(file.path(R.home("bin"), "Rscript"), c("-e", shQuote(ecr)), stdout = TRUE, env = paste0("R_LIBS=", Sys.getenv("OPENXLSX_LIB")))
    if (!file.exists(f)) cat("  classeur non ecrit (openxlsx absent, OPENXLSX_LIB vide)\n\n") else {
      if (!avec_ox) cat(sprintf("  (ecrit par openxlsx %s dans un sous-processus)\n", paste(v, collapse = "")))
      lire_serie(f) } })
