# Fabrique un classeur minimal a partir du XML de la feuille (et d'une table de chaines partagees facultative).
fab <- function(chemin, rows_xml, shared = NULL) {
  d <- tempfile("fab_"); dir.create(d)
  dir.create(file.path(d, "_rels")); dir.create(file.path(d, "xl", "_rels"), recursive = TRUE); dir.create(file.path(d, "xl", "worksheets"))
  w <- function(txt, ...) writeLines(txt, file.path(d, ...), useBytes = TRUE)
  ct <- paste0('<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/><Default Extension="xml" ContentType="application/xml"/><Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/><Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>',
    if (!is.null(shared)) '<Override PartName="/xl/sharedStrings.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sharedStrings+xml"/>', '</Types>')
  w(ct, "[Content_Types].xml")
  w('<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/></Relationships>', "_rels", ".rels")
  w('<?xml version="1.0" encoding="UTF-8" standalone="yes"?><workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><sheets><sheet name="S" sheetId="1" r:id="rId1"/></sheets></workbook>', "xl", "workbook.xml")
  w(paste0('<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/>',
    if (!is.null(shared)) '<Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/sharedStrings" Target="sharedStrings.xml"/>', '</Relationships>'), "xl", "_rels", "workbook.xml.rels")
  if (!is.null(shared)) w(paste0('<?xml version="1.0" encoding="UTF-8" standalone="yes"?><sst xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" count="', length(shared), '" uniqueCount="', length(shared), '">', paste0("<si>", shared, "</si>", collapse = ""), '</sst>'), "xl", "sharedStrings.xml")
  w(paste0('<?xml version="1.0" encoding="UTF-8" standalone="yes"?><worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><sheetData>', rows_xml, '</sheetData></worksheet>'), "xl", "worksheets", "sheet1.xml")
  wd <- setwd(d); on.exit(setwd(wd))
  if (file.exists(chemin)) unlink(chemin)
  st <- system2("zip", c("-r9Xq", shQuote(chemin), "'[Content_Types].xml'", "_rels", "xl"))
  stopifnot(st == 0)
  invisible(chemin)
}
# Lecture par les deux chemins : renvoie liste(interne =, openxlsx =), chacune data.frame ou "ERREUR: msg" / "REFUS(classe): msg"
lire2 <- function(chemin, moteur_env) {
  une <- function(masque) {
    f <- function() { av <- character(0)
      r <- withCallingHandlers(tryCatch(engine_lire_xlsx(chemin), error = function(e)
        structure(paste0(if (inherits(e, "usp_refus_lecture")) "REFUS: " else "ERREUR: ", conditionMessage(e)), class = "echec")),
        warning = function(w) { av <<- c(av, conditionMessage(w)); invokeRestart("muffleWarning") })
      if (length(av)) attr(r, "avertissements") <- av
      r }
    if (!masque) return(f())
    env <- environment(engine_lire_xlsx)
    ancien <- if (exists("requireNamespace", envir = env, inherits = FALSE)) get("requireNamespace", envir = env) else NULL
    assign("requireNamespace", function(package, ..., quietly = FALSE)
      if (identical(package, "openxlsx")) FALSE else base::requireNamespace(package, ..., quietly = quietly), envir = env)
    on.exit(if (is.null(ancien)) rm("requireNamespace", envir = env) else assign("requireNamespace", ancien, envir = env))
    f()
  }
  list(interne = une(TRUE), openxlsx = if (requireNamespace("openxlsx", quietly = TRUE)) une(FALSE) else "openxlsx absent")
}
montrer <- function(nom, r) {
  cat("\n### ", nom, "\n", sep = "")
  for (k in names(r)) {
    cat("-- ", k, ":\n", sep = "")
    x <- r[[k]]
    if (inherits(x, "echec") || is.character(x) && length(x) == 1L && is.null(dim(x))) cat("   ", unclass(x), "\n")
    else { print(x); if (!is.null(attr(x, "avertissements"))) cat("   AVERTISSEMENTS:", attr(x, "avertissements"), "\n"); cat("   classes:", paste(vapply(x, function(c) class(c)[1], ""), collapse = ","), "\n"); cat("   names (dput):", deparse(names(x)), "\n") }
  }
}
