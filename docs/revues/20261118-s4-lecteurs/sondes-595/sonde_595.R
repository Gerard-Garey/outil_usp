# Usage : Rscript sonde_595.R <depot> <fichier_moteur> [<cas> <chemin>]
# #595 (S4, etape 3) : parties lues par openxlsx hors de la feuille.
# Sans <cas> : chaque cas est rejoue sur les deux chemins, chacun dans son
# propre sous-processus Rscript borne par timeout 20 s (code 124 : blocage).
# Chemin openxlsx : R_LIBS doit donner openxlsx 4.2.5.2 (variable OPENXLSX_LIB
# transmise au sous-processus). Chemin interne : requireNamespace("openxlsx")
# substitue par FALSE dans environment(run_engine) (modele des tests de
# parite, fils575).
# Classeur : serie de reference (tests/donnees/donnees_ln.csv, forge.R du
# rejeu S1) ; la feuille 2 (sheet2.xml) porte 999 en B2 : B2 lu 999 signale
# une autre feuille lue. sigma_USP : run_engine(premium, segment 1, annexe II,
# brutes) si la lecture reussit.
a <- commandArgs(TRUE); depot <- normalizePath(a[1]); moteur <- normalizePath(a[2])
CAS <- c(
  # tableau de l'issue (cible Target)
  "t1-xtarget-dq-puis-target-apos", "t2-xtarget-dq-puis-target-dq", "t3-target-apos-puis-xtarget-dq",
  "t4-foo-target-puis-target-apos", "t5-target-apos-puis-foo-target",
  # variantes
  "t6-target-dq-puis-foo-target", "t7-target-repete-dq", "t8-foo-target-lf-puis-target-apos",
  "t9-xtarget-nom-puis-target-apos", "t10-target-dans-sa-valeur",
  # formes ajoutees par actuary (Target unique)
  "t14-guillemet-entree", "t15-entite-entree", "t11-target-apos-seul-2f", "t12-target-blancs-seul-2f", "t13-target-apos-seul-1f",
  # balise <Relationship
  "b1-tab-premiere", "b2-lf-premiere", "b3-cr-premiere", "b4-tab-seconde", "b5-relation-lf-ship-tab",
  "b6-relationshipx", "b7-crlf-espace", "b8-x-prefixe-tab", "b9-racine-tab", "b10-racine-lf",
  "b11-tab-derniere-2f", "b12-attribut-par-ligne-lf-2f", "b13-attribut-par-ligne-crlf-2f",
  # Type
  "y1-xtype-chart-puis-type-ws", "y2-type-chart-puis-xtype-ws", "y3-type-repete",
  # entrees homonymes
  "h1-autre-workbook", "h2-autre-workbook-rels", "h3-copie-feuille-autre-dossier", "h4-copie-feuille-xworksheets",
  # temoins
  "w1-forge", "w2-deux-feuilles", "w3-ecrivain-interne", "w4-openxlsx-deux-feuilles", "w5-crlf")
if (length(a) < 4) {
  self <- normalizePath(sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE)))
  lib <- Sys.getenv("OPENXLSX_LIB")
  cas_sel <- if (length(a) == 3) strsplit(a[3], ",")[[1]] else CAS
  for (c in cas_sel) for (ch in c("interne", "openxlsx")) {
    env <- c("LC_ALL=C.UTF-8", if (ch == "openxlsx") paste0("R_LIBS=", lib) else "R_LIBS=")
    out <- suppressWarnings(system2("timeout", c("20", file.path(R.home("bin"), "Rscript"), shQuote(c(self, depot, moteur, c, ch))),
                                    stdout = TRUE, stderr = TRUE, env = env))
    st <- attr(out, "status"); if (is.null(st)) st <- 0L
    cat(out, sep = "\n"); cat(sprintf("  [code de sortie : %d%s]\n\n", st, if (st == 124) " = BLOCAGE (timeout 20 s)" else ""))
  }
  quit(save = "no")
}
cas <- a[3]; chemin <- a[4]
setwd(depot); source("R/charger_moteur.R"); e <- charger_moteur(moteur, dans = NULL)
env <- environment(e$run_engine)
if (chemin == "interne")
  assign("requireNamespace", function(package, ...)
    if (package %in% "openxlsx") FALSE else base::requireNamespace(package, ...), envir = env)
vu <- eval(quote(requireNamespace("openxlsx", quietly = TRUE)), env)
source(file.path(depot, "docs/revues/20261115-s1-rejeu/sondes/forge.R"))
cat(sprintf("[%s] chemin = %s (openxlsx vu par le moteur : %s%s) ; moteur = %s\n", cas, chemin, vu,
            if (vu) paste0(", ", packageVersion("openxlsx")) else "", basename(moteur)))
lire_serie <- function(f) {
  df <- tryCatch(e$engine_lire_xlsx(f), error = function(err) err)
  if (inherits(df, "error")) {
    cat(sprintf("  ERREUR classe = %s\n  message = %s\n", class(df)[1], conditionMessage(df))); return(invisible(NULL))
  }
  if (is.null(df)) { cat("  lu : NULL\n"); return(invisible(NULL)) }
  cat(sprintf("  lu : %d x %d ; B2 lu = %s\n", nrow(df), ncol(df), format(df[[2]][1], digits = 15)))
  r <- e$engine_lire_donnees_csv(df)
  if (isTRUE(r$ok)) {
    res <- tryCatch(e$run_engine(xt = r$xt, yt = r$yt, methode = "premium", segment = 1, annexe = "II", nature_donnees = "brutes", date_reference = "2026-12-31"),
                    error = function(err) err)
    if (inherits(res, "error")) cat("  run_engine : ERREUR", conditionMessage(res), "\n")
    else cat(sprintf("  run_engine : ok = %s, sigma_USP = %.10f\n", res$ok, if (isTRUE(res$ok)) res$parametre$sigma_usp else NA))
  } else cat("  engine_lire_donnees_csv : ok = FALSE ;", head(r$erreurs, 1), "\n")
}
# Retouches : liste de c(partie, de, vers) (sub fixe) ; feuilles : nombre de
# copies de sheet1.xml (999 en B2) ; extra : liste c(entree, partie_source,
# remplacer_999) d'entrees ajoutees a l'archive, placees avant xl.
retoucher <- function(f, modifs, feuilles = 0L, extra = list()) {
  d <- tempfile("s595_"); dir.create(d); utils::unzip(f, exdir = d)
  lire_p <- function(p) rawToChar(readBin(file.path(d, p), "raw", file.info(file.path(d, p))$size))
  ecr_p <- function(p, x) { dir.create(dirname(file.path(d, p)), recursive = TRUE, showWarnings = FALSE); writeBin(charToRaw(x), file.path(d, p)) }
  for (k in seq_len(feuilles))
    ecr_p(sprintf("xl/worksheets/sheet%d.xml", k + 1L), sub("<v>104.2</v>", "<v>999</v>", lire_p("xl/worksheets/sheet1.xml"), fixed = TRUE))
  for (m in modifs) { x <- lire_p(m[1]); stopifnot(grepl(m[2], x, fixed = TRUE)); ecr_p(m[1], sub(m[2], m[3], x, fixed = TRUE)) }
  for (x in extra) ecr_p(x[1], if (identical(x[3], "999")) sub("<v>104.2</v>", "<v>999</v>", lire_p(x[2]), fixed = TRUE) else lire_p(x[2]))
  od <- setwd(d); on.exit(setwd(od)); unlink(f)
  tops <- list.files(".", all.files = TRUE, no.. = TRUE)
  std <- c("[Content_Types].xml", "_rels", "xl")
  stopifnot(system2("zip", c("-r9Xq", shQuote(f), shQuote(c(setdiff(tops, std), std)))) == 0); f
}
WB <- "xl/workbook.xml"; RL <- "xl/_rels/workbook.xml.rels"; FS <- "xl/worksheets/sheet1.xml"
RT <- "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
TW <- sprintf('Type="%s/worksheet"', RT)
T1 <- 'Target="worksheets/sheet1.xml"'
REL1 <- '<Relationship Id="rId1"'
rel <- function(id, k) sprintf('<Relationship Id="%s" %s Target="worksheets/sheet%d.xml"/>', id, TW, k)
fin_rels <- function(...) c(RL, "</Relationships>", paste0(..., "</Relationships>"))
fin_sheets <- function(...) c(WB, "</sheets>", paste0(..., "</sheets>"))
sh <- function(nom, k, att) sprintf('<sheet name="%s" sheetId="%d" %s/>', nom, k, att)
deux <- function() list(fin_rels(rel("rId2", 2L)), fin_sheets(sh("Autre", 2L, 'r:id="rId2"')))
f0 <- function() forger(serie())
S1 <- "worksheets/sheet1.xml"; S2 <- "worksheets/sheet2.xml"
cible <- function(par) lire_serie(retoucher(f0(), list(c(RL, T1, par)), 1L))
switch(cas,
  "t1-xtarget-dq-puis-target-apos" = { cat("  relation de la feuille lue : x:Target=\"...sheet2.xml\" Target='...sheet1.xml'\n")
    cible(sprintf("x:Target=\"%s\" Target='%s'", S2, S1)) },
  "t2-xtarget-dq-puis-target-dq" = { cat("  x:Target=\"...sheet2.xml\" Target=\"...sheet1.xml\"\n")
    cible(sprintf("x:Target=\"%s\" Target=\"%s\"", S2, S1)) },
  "t3-target-apos-puis-xtarget-dq" = { cat("  Target='...sheet1.xml' x:Target=\"...sheet2.xml\"\n")
    cible(sprintf("Target='%s' x:Target=\"%s\"", S1, S2)) },
  "t4-foo-target-puis-target-apos" = { cat("  Foo='Target=\"...sheet2.xml\"' Target='...sheet1.xml'\n")
    cible(sprintf("Foo='Target=\"%s\"' Target='%s'", S2, S1)) },
  "t5-target-apos-puis-foo-target" = { cat("  Target='...sheet1.xml' Foo='Target=\"...sheet2.xml\"'\n")
    cible(sprintf("Target='%s' Foo='Target=\"%s\"'", S1, S2)) },
  "t6-target-dq-puis-foo-target" = { cat("  Target=\"...sheet1.xml\" Foo='Target=\"...sheet2.xml\"'\n")
    cible(sprintf("Target=\"%s\" Foo='Target=\"%s\"'", S1, S2)) },
  "t7-target-repete-dq" = { cat("  Target=\"...sheet2.xml\" Target=\"...sheet1.xml\" (Target repete, sans prefixe)\n")
    cible(sprintf("Target=\"%s\" Target=\"%s\"", S2, S1)) },
  "t8-foo-target-lf-puis-target-apos" = { cat("  Foo='Target<LF>=\"...sheet2.xml\"' Target='...sheet1.xml' (texte colle)\n")
    cible(sprintf("Foo='Target\n=\"%s\"' Target='%s'", S2, S1)) },
  "t9-xtarget-nom-puis-target-apos" = { cat("  xTarget=\"...sheet2.xml\" Target='...sheet1.xml' (nom d'attribut qui finit par Target)\n")
    cible(sprintf("xTarget=\"%s\" Target='%s'", S2, S1)) },
  "t10-target-dans-sa-valeur" = { cat("  Target='...sheet1.xml Target=\"...sheet2.xml\"' (texte dans la valeur de Target)\n")
    cible(sprintf("Target='%s Target=\"%s\"'", S1, S2)) },
  "t14-guillemet-entree" = { cat("  Target=\"...sheet1.xml\" Foo=\"z.xml\" et entree xl/worksheets/sheet1.xml\" Foo=\"z.xml (999) dans l'archive\n")
    lire_serie(retoucher(f0(), list(c(RL, T1, paste0(T1, ' Foo="z.xml"'))), 0L, list(c('xl/worksheets/sheet1.xml" Foo="z.xml', FS, "999")))) },
  "t15-entite-entree" = { cat("  Target=\"worksheets/sheet&#49;.xml\" et entree xl/worksheets/sheet&#49;.xml (999) dans l'archive\n")
    lire_serie(retoucher(f0(), list(c(RL, T1, 'Target="worksheets/sheet&#49;.xml"')), 0L, list(c("xl/worksheets/sheet&#49;.xml", FS, "999")))) },
  "t11-target-apos-seul-2f" = { cat("  deux feuilles ; relation de la feuille lue Target='...sheet1.xml'\n")
    lire_serie(retoucher(f0(), c(deux(), list(c(RL, T1, sprintf("Target='%s'", S1)))), 1L)) },
  "t12-target-blancs-seul-2f" = { cat("  deux feuilles ; relation de la feuille lue Target = \"...sheet1.xml\"\n")
    lire_serie(retoucher(f0(), c(deux(), list(c(RL, T1, sprintf("Target = \"%s\"", S1)))), 1L)) },
  "t13-target-apos-seul-1f" = { cat("  une feuille ; Target='...sheet1.xml'\n")
    lire_serie(retoucher(f0(), list(c(RL, T1, sprintf("Target='%s'", S1))))) },
  "b1-tab-premiere" = { cat("  <Relationship<TAB>Id=\"rId1\" (premiere relation)\n")
    lire_serie(retoucher(f0(), list(c(RL, REL1, '<Relationship\tId="rId1"')))) },
  "b2-lf-premiere" = { cat("  <Relationship<LF>Id=\"rId1\" (premiere relation)\n")
    lire_serie(retoucher(f0(), list(c(RL, REL1, '<Relationship\nId="rId1"')))) },
  "b3-cr-premiere" = { cat("  <Relationship<CR>Id=\"rId1\" (premiere relation)\n")
    lire_serie(retoucher(f0(), list(c(RL, REL1, '<Relationship\rId="rId1"')))) },
  "b4-tab-seconde" = { cat("  deux feuilles, seconde relation (feuille 2) <Relationship<TAB>Id=\"rId2\"\n")
    lire_serie(retoucher(f0(), c(deux(), list(c(RL, '<Relationship Id="rId2"', '<Relationship\tId="rId2"'))), 1L)) },
  "b5-relation-lf-ship-tab" = { cat("  <Relation<LF>ship<TAB>Id=\"rId1\" (colle : <Relationship<TAB>)\n")
    lire_serie(retoucher(f0(), list(c(RL, REL1, '<Relation\nship\tId="rId1"')))) },
  "b6-relationshipx" = { cat("  <RelationshipX Id=\"rId9\" .../> placee avant la vraie\n")
    lire_serie(retoucher(f0(), list(c(RL, REL1, paste0('<RelationshipX Id="rId9" ', TW, ' Target="worksheets/sheet1.xml"/>', REL1))))) },
  "b7-crlf-espace" = { cat("  <Relationship<CR><LF> Id=\"rId1\" (colle : <Relationship Id)\n")
    lire_serie(retoucher(f0(), list(c(RL, REL1, '<Relationship\r\n Id="rId1"')))) },
  "b8-x-prefixe-tab" = { cat("  <x:Relationship<TAB>Id=\"rId1\" (prefixe declare sur la racine)\n")
    lire_serie(retoucher(f0(), list(c(RL, "<Relationships xmlns=", '<Relationships xmlns:x="http://schemas.openxmlformats.org/package/2006/relationships" xmlns='),
                                    c(RL, REL1, '<x:Relationship\tId="rId1"')))) },
  "b9-racine-tab" = { cat("  racine <Relationships<TAB>xmlns=...\n")
    lire_serie(retoucher(f0(), list(c(RL, "<Relationships xmlns=", "<Relationships\txmlns=")))) },
  "b10-racine-lf" = { cat("  racine <Relationships<LF>xmlns=... (colle : <Relationshipsxmlns)\n")
    lire_serie(retoucher(f0(), list(c(RL, "<Relationships xmlns=", "<Relationships\nxmlns=")))) },
  "b11-tab-derniere-2f" = { cat("  deux feuilles, relation 2 en derniere position <Relationship<TAB>Id=\"rId2\" (idem b4, controle)\n")
    lire_serie(retoucher(f0(), c(deux(), list(c(RL, '<Relationship Id="rId2"', '<Relationship\tId="rId2"'))), 1L)) },
  "b12-attribut-par-ligne-lf-2f" = { cat("  deux feuilles, relations ecrites un attribut par ligne (<LF><espace> avant chaque attribut)\n")
    lire_serie(retoucher(f0(), c(deux(), list(c(RL, rel("rId1", 1L), gsub(" ", "\n ", rel("rId1", 1L), fixed = TRUE)),
                                             c(RL, rel("rId2", 2L), gsub(" ", "\n ", rel("rId2", 2L), fixed = TRUE)))), 1L)) },
  "b13-attribut-par-ligne-crlf-2f" = { cat("  deux feuilles, relations ecrites un attribut par ligne (<CR><LF><espace> avant chaque attribut)\n")
    lire_serie(retoucher(f0(), c(deux(), list(c(RL, rel("rId1", 1L), gsub(" ", "\r\n ", rel("rId1", 1L), fixed = TRUE)),
                                             c(RL, rel("rId2", 2L), gsub(" ", "\r\n ", rel("rId2", 2L), fixed = TRUE)))), 1L)) },
  "y1-xtype-chart-puis-type-ws" = { cat("  deux feuilles ; relation 1 : x:Type=\".../chartsheet\" Type=\".../worksheet\"\n")
    lire_serie(retoucher(f0(), c(deux(), list(c(RL, paste0(REL1, " ", TW), sprintf('%s x:Type="%s/chartsheet" %s', REL1, RT, TW)))), 1L)) },
  "y2-type-chart-puis-xtype-ws" = { cat("  deux feuilles ; relation 1 : Type=\".../chartsheet\" x:Type=\".../worksheet\"\n")
    lire_serie(retoucher(f0(), c(deux(), list(c(RL, paste0(REL1, " ", TW), sprintf('%s Type="%s/chartsheet" x:%s', REL1, RT, TW)))), 1L)) },
  "y3-type-repete" = { cat("  deux feuilles ; relation 1 : Type=\".../chartsheet\" Type=\".../worksheet\"\n")
    lire_serie(retoucher(f0(), c(deux(), list(c(RL, paste0(REL1, " ", TW), sprintf('%s Type="%s/chartsheet" %s', REL1, RT, TW)))), 1L)) },
  "h1-autre-workbook" = { cat("  entree a/workbook.xml (copie de xl/workbook.xml) placee avant xl/ dans l'archive\n")
    lire_serie(retoucher(f0(), list(), 1L, list(c("a/workbook.xml", WB)))) },
  "h2-autre-workbook-rels" = { cat("  entree a/_rels/workbook.xml.rels (relation rId1 -> sheet2.xml) placee avant xl/\n")
    d0 <- retoucher(f0(), list(c(RL, S1, S2)), 1L, list(c("a/_rels/workbook.xml.rels", RL)))
    lire_serie(retoucher(d0, list(c(RL, S2, S1)))) },
  "h3-copie-feuille-autre-dossier" = { cat("  entree a/worksheets/sheet1.xml (999 en B2) placee avant xl/\n")
    lire_serie(retoucher(f0(), list(), 0L, list(c("a/worksheets/sheet1.xml", FS, "999")))) },
  "h4-copie-feuille-xworksheets" = { cat("  entree xl/xworksheets/sheet1.xml (999 en B2)\n")
    lire_serie(retoucher(f0(), list(), 0L, list(c("xl/xworksheets/sheet1.xml", FS, "999")))) },
  "w1-forge" = { cat("  classeur forge ordinaire\n"); lire_serie(f0()) },
  "w2-deux-feuilles" = { cat("  deux feuilles ordinaires\n"); lire_serie(retoucher(f0(), deux(), 1L)) },
  "w3-ecrivain-interne" = { cat("  classeur de engine_ecrire_xlsx()\n")
    f <- tempfile(fileext = ".xlsx"); e$engine_ecrire_xlsx(data.frame(t = LN$t, xt = LN$xt, yt = LN$yt), f); lire_serie(f) },
  "w4-openxlsx-deux-feuilles" = { cat("  classeur d'openxlsx::write.xlsx() a deux feuilles\n")
    f <- tempfile(fileext = ".xlsx")
    ecr <- sprintf('d <- data.frame(t = 1:8, xt = c(%s), yt = c(%s)); d2 <- d; d2$xt[1] <- 999; openxlsx::write.xlsx(list(Donnees = d, Autre = d2), "%s")',
                   paste(LN$xt, collapse = ", "), paste(LN$yt, collapse = ", "), f)
    system2(file.path(R.home("bin"), "Rscript"), c("-e", shQuote(ecr)), env = paste0("R_LIBS=", Sys.getenv("OPENXLSX_LIB")))
    lire_serie(f) },
  "w5-crlf" = { cat("  deux feuilles, workbook.xml et relations en CRLF\n")
    lire_serie(retoucher(f0(), c(deux(), list(c(WB, "?><workbook", "?>\r\n<workbook"), c(WB, '"/><sheet ', '"/>\r\n<sheet '),
                                              c(RL, "?><Relationships", "?>\r\n<Relationships"), c(RL, '"/><Relationship ', '"/>\r\n<Relationship '))), 1L)) })
