# Outillage commun de l'etape 1 de K2 (aucun fichier du depot modifie)
setwd("/home/user/outil_usp")
source("R/charger_moteur.R"); charger_moteur()
env_m <- environment(run_engine)
avec_ox <- requireNamespace("openxlsx", quietly = TRUE)
sans_ox <- function(expr) {
  assign("requireNamespace", function(package, ...) FALSE, envir = env_m)
  on.exit(rm("requireNamespace", envir = env_m), add = TRUE)
  force(expr)
}
# Les deux chemins : evalue lire(f) avec chaque adaptateur
chemins <- function(f, lire = identity) {
  out <- list()
  out$interne <- tryCatch(lire(sans_ox(engine_lire_xlsx(f))), error = function(e) paste("ERREUR:", conditionMessage(e)))
  if (avec_ox) out$openxlsx <- tryCatch(lire(engine_lire_xlsx(f)), error = function(e) paste("ERREUR:", conditionMessage(e)))
  out
}
# Construit un xlsx a partir de fichiers XML bruts : liste nommee chemin -> contenu
mk_xlsx <- function(parts, f = tempfile(fileext = ".xlsx")) {
  d <- tempfile("mk_"); dir.create(d)
  for (nm in names(parts)) {
    p <- file.path(d, nm); dir.create(dirname(p), recursive = TRUE, showWarnings = FALSE)
    writeLines(parts[[nm]], p, useBytes = TRUE)
  }
  od <- setwd(d); on.exit({setwd(od); unlink(d, recursive = TRUE)})
  if (file.exists(f)) unlink(f)
  st <- utils::zip(f, c("[Content_Types].xml", "_rels", "xl"), flags = "-r9Xq")
  stopifnot(identical(st, 0L))
  f
}
H <- '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
NS <- 'xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"'
RNS <- 'xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"'
RT <- 'http://schemas.openxmlformats.org/officeDocument/2006/relationships'
# Classeur a n feuilles : feuilles = liste de (nom, fichier, xml de feuille) dans l'ordre du workbook
mk_classeur <- function(feuilles, shared = NULL, f = tempfile(fileext = ".xlsx")) {
  ct <- paste0(H, '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">',
    '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>',
    '<Default Extension="xml" ContentType="application/xml"/>',
    '<Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>',
    paste(sprintf('<Override PartName="/xl/worksheets/%s" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>',
                  vapply(feuilles, `[[`, "", "fichier")), collapse = ""),
    if (!is.null(shared)) '<Override PartName="/xl/sharedStrings.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sharedStrings+xml"/>',
    '</Types>')
  rels0 <- paste0(H, '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">',
    '<Relationship Id="rId1" Type="', RT, '/officeDocument" Target="xl/workbook.xml"/></Relationships>')
  wb <- paste0(H, '<workbook ', NS, ' ', RNS, '><sheets>',
    paste(sprintf('<sheet name="%s" sheetId="%d" r:id="rId%d"/>',
                  vapply(feuilles, `[[`, "", "nom"), seq_along(feuilles), seq_along(feuilles) + 10L), collapse = ""),
    '</sheets></workbook>')
  wrel <- paste0(H, '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">',
    paste(sprintf('<Relationship Id="rId%d" Type="%s/worksheet" Target="worksheets/%s"/>',
                  seq_along(feuilles) + 10L, RT, vapply(feuilles, `[[`, "", "fichier")), collapse = ""),
    if (!is.null(shared)) paste0('<Relationship Id="rId99" Type="', RT, '/sharedStrings" Target="sharedStrings.xml"/>'),
    '</Relationships>')
  parts <- list("[Content_Types].xml" = ct, "_rels/.rels" = rels0, "xl/workbook.xml" = wb,
                "xl/_rels/workbook.xml.rels" = wrel)
  for (fe in feuilles) parts[[paste0("xl/worksheets/", fe$fichier)]] <- paste0(H, '<worksheet ', NS, '><sheetData>', fe$xml, '</sheetData></worksheet>')
  if (!is.null(shared)) parts[["xl/sharedStrings.xml"]] <- paste0(H, '<sst ', NS, '>', shared, '</sst>')
  mk_xlsx(parts, f)
}
rowx <- function(i, cells) sprintf('<row r="%d">%s</row>', i, paste(cells, collapse = ""))
cn <- function(ref, v) sprintf('<c r="%s"><v>%s</v></c>', ref, v)
ci <- function(ref, txt) sprintf('<c r="%s" t="inlineStr"><is>%s</is></c>', ref, txt)
