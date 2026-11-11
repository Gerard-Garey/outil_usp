source("/tmp/claude-0/-home-user-outil-usp/9cb815f0-8197-554a-a7db-4a6f9f874cc0/scratchpad/k2-etape1/outils.R")
sous_od <- function(od, expr) { a <- options(OutDec = od); on.exit(options(a)); force(expr) }
ser <- data.frame(t = 1:3, xt = c(0.1, 1/3, 2001), yt = c(1e-300, 2.5, 1e5))
xml_xlsx <- function(f) { d <- tempfile(); utils::unzip(f, exdir = d); fs <- list.files(d, recursive = TRUE, full.names = TRUE); setNames(sapply(sort(fs), function(p) paste(readLines(p, warn = FALSE), collapse = "")), sub(".*/(xl|docProps|_rels)", "\\1", sort(fs))) }
for (qui in c("openxlsx", "interne")) {
  w <- function(od) sous_od(od, { f <- tempfile(fileext = ".xlsx"); if (qui == "interne") sans_ox(engine_ecrire_xlsx(ser, f)) else engine_ecrire_xlsx(ser, f); xml_xlsx(f) })
  a <- w("."); b <- w(","); Sys.sleep(1.1); a2 <- w(".")
  diffs <- names(a)[!mapply(identical, a, b)]
  cat(sprintf("%s : parties differentes pt/vg : %s ; entre deux appels sous '.' (1 s d'ecart) : %s\n", qui, paste(diffs, collapse = ","), paste(names(a)[!mapply(identical, a, a2)], collapse = ",")))
  cat("  tout identique pt/vg :", identical(a, b), "\n")
}
# Textes avec virgule : engine_regle_verdicts, un extrait
cat(substr(sous_od(",", engine_regle_verdicts(0.037))[1], 1, 200), "\n")
