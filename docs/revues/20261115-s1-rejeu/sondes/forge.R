# Forge d'un classeur xlsx minimal (hors depot), pour le rejeu S1.
# lignes : vecteur de chaines "<row ...>...</row>" ; partagees : NULL ou
# contenu brut (raw ou chaine) de l'element <sst> (sans l'en-tete XML).
forger <- function(lignes, partagees = NULL, fichier = tempfile(fileext = ".xlsx")) {
  d <- tempfile("forge_"); dir.create(file.path(d, "_rels"), recursive = TRUE)
  dir.create(file.path(d, "xl", "_rels"), recursive = TRUE)
  dir.create(file.path(d, "xl", "worksheets"), recursive = TRUE)
  ecr <- function(chemin, x) {
    con <- file(file.path(d, chemin), "wb"); on.exit(close(con))
    if (is.raw(x)) writeBin(x, con) else writeBin(charToRaw(enc2utf8(x)), con)
  }
  ent <- '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
  ecr("[Content_Types].xml", paste0(ent, '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/><Default Extension="xml" ContentType="application/xml"/><Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/><Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>',
                                    if (!is.null(partagees)) '<Override PartName="/xl/sharedStrings.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sharedStrings+xml"/>', '</Types>'))
  ecr("_rels/.rels", paste0(ent, '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/></Relationships>'))
  ecr("xl/workbook.xml", paste0(ent, '<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><sheets><sheet name="Donnees" sheetId="1" r:id="rId1"/></sheets></workbook>'))
  ecr("xl/_rels/workbook.xml.rels", paste0(ent, '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/>',
                                           if (!is.null(partagees)) '<Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/sharedStrings" Target="sharedStrings.xml"/>', '</Relationships>'))
  ecr("xl/worksheets/sheet1.xml", paste0(ent, '<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><sheetData>',
                                         paste(lignes, collapse = ""), '</sheetData></worksheet>'))
  if (!is.null(partagees)) {
    tete <- charToRaw(paste0(ent, '<sst xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:x="http://schemas.openxmlformats.org/spreadsheetml/2006/main">'))
    corps <- if (is.raw(partagees)) partagees else charToRaw(enc2utf8(partagees))
    ecr("xl/sharedStrings.xml", c(tete, corps, charToRaw("</sst>")))
  }
  od <- setwd(d); on.exit(setwd(od), add = TRUE)
  unlink(fichier)
  st <- system2("zip", c("-r9Xq", shQuote(fichier), "[Content_Types].xml", "_rels", "xl"))
  stopifnot(st == 0)
  fichier
}
# Cellules usuelles
ci <- function(ref, txt) sprintf('<c r="%s" t="inlineStr"><is><t>%s</t></is></c>', ref, txt)
cn <- function(ref, v) sprintf('<c r="%s"><v>%s</v></c>', ref, v)
ligne <- function(i, ...) sprintf('<row r="%d">%s</row>', i, paste0(...))
# Serie de reference (tests/donnees/donnees_ln.csv) ; remplace[[k]] : XML de la
# cellule xt de la ligne de donnees k (ligne k + 1 du classeur).
LN <- data.frame(t = 1:8, xt = c(104.2, 102.25, 109.34, 114.64, 118.41, 121.28, 132.4, 131.22),
                 yt = c(68.97, 76.76, 83.49, 95.38, 88.96, 70.22, 78.89, 117.37))
serie <- function(cellule_xt = list(), extra = character(0)) {
  l <- ligne(1, ci("A1", "t"), ci("B1", "xt"), ci("C1", "yt"))
  for (k in 1:8) {
    bx <- if (!is.null(cellule_xt[[as.character(k)]])) cellule_xt[[as.character(k)]] else cn(paste0("B", k + 1), LN$xt[k])
    l <- c(l, ligne(k + 1, cn(paste0("A", k + 1), k), bx, cn(paste0("C", k + 1), LN$yt[k]), if (k == 8) extra))
  }
  l
}
