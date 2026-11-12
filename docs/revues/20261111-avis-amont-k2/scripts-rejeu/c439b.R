source("/tmp/claude-0/-home-user-outil-usp/9cb815f0-8197-554a-a7db-4a6f9f874cc0/scratchpad/k2-etape1/outils.R")
sous_od <- function(od, expr) { a <- options(OutDec = od); on.exit(options(a)); force(expr) }
x <- c(104.20, 102.25, 109.34, 114.64, 118.41, 121.28, 132.40, 131.22); y <- c(68.97, 76.76, 83.49, 95.38, 88.96, 70.22, 78.89, 117.37)
tri <- utils::read.csv("tests/donnees/triangle_mw.csv"); trim <- unname(as.matrix(tri[, -1])); storage.mode(trim) <- "double"
res <- sans <- NULL
ln <- run_engine(xt = x, yt = y, methode = "premium", segment = 1, annexe = "II", nature_donnees = "brutes", B = 99, sigma_standard = 0.1234567)
rm2 <- run_engine(methode = "reserve2", triangle = trim, segment = 1, annexe = "II", B = 99)
horloge <- function(r) { r$metadata[c("horodatage","duree_sec","version_R")] <- NULL; r }
ser <- data.frame(t = 1:8, xt = x, yt = y); ser_c <- ser; ser_c$xt[3] <- NA; ser_dup <- ser; ser_dup$t[2] <- 1.5
fx <- tempfile(fileext = ".xlsx"); engine_ecrire_xlsx(ser, fx)
fx_t <- tempfile(fileext = ".xlsx"); engine_ecrire_xlsx(data.frame(i = 0:7, setNames(as.data.frame(trim), paste0("j", 0:7))), fx_t)
tri_df <- tri
xml_xlsx <- function(f) { d <- tempfile(); utils::unzip(f, exdir = d); fs <- list.files(d, recursive = TRUE, full.names = TRUE); sapply(sort(fs), function(p) paste(readLines(p, warn = FALSE), collapse = "")) }
casos <- list(
  engine_lire_donnees_csv = list(ent = function() engine_lire_donnees_csv(ser_dup), nb = TRUE),
  engine_lire_donnees_csv_valeur = list(ent = function() engine_lire_donnees_csv(ser), nb = FALSE),
  engine_lire_triangle = list(ent = function() engine_lire_triangle(tri_df), nb = FALSE),
  engine_lire_triangle_refus_chiffre = list(ent = function() { t2 <- tri_df; t2[2, 3] <- 0.5 * t2[2, 2]; engine_lire_triangle(t2) }, nb = TRUE),
  `engine_lire_xlsx (openxlsx)` = list(ent = function() engine_lire_xlsx(fx)),
  `engine_lire_xlsx (interne)` = list(ent = function() sans_ox(engine_lire_xlsx(fx))),
  `engine_lire_xlsx triangle (openxlsx)` = list(ent = function() engine_lire_xlsx(fx_t)),
  `engine_ecrire_xlsx (openxlsx) : XML` = list(ent = function() { f <- tempfile(fileext = ".xlsx"); engine_ecrire_xlsx(ser, f); xml_xlsx(f) }),
  `engine_ecrire_xlsx (interne) : XML` = list(ent = function() { f <- tempfile(fileext = ".xlsx"); sans_ox(engine_ecrire_xlsx(ser, f)); xml_xlsx(f) }),
  engine_empreinte_ln = list(ent = function() engine_empreinte(horloge(ln))),
  engine_empreinte_mw = list(ent = function() engine_empreinte(horloge(rm2))),
  engine_regle_verdicts = list(ent = function() engine_regle_verdicts(0.037)),
  engine_parametre_standard = list(ent = function() engine_parametre_standard(ln)),
  engine_derogations = list(ent = function() engine_derogations(ln)),
  engine_table_tests = list(ent = function() engine_table_tests(ln)),
  engine_valider_donnees = list(ent = function() engine_valider_donnees(replace(x, 8, 1e-9), y, theta_equiv = 0.37, delta_equiv = 1e9)),
  engine_valider_serie_retenue = list(ent = function() engine_valider_serie_retenue(x, y, T = 5.5)),
  engine_valider_profondeur = list(ent = function() engine_valider_profondeur(5.5, 8)),
  mw_valider_triangle = list(ent = function() { t2 <- trim; t2[2, 2] <- 0.5 * t2[2, 1]; mw_valider_triangle(t2) }),
  engine_motif_b_alpha = list(ent = function() engine_motif_b_alpha(99, 0.037))
)
sortie <- data.frame()
for (n in names(casos)) {
  a <- sous_od(".", casos[[n]]$ent()); b <- sous_od(",", casos[[n]]$ent())
  txt <- function(o) if (is.character(o)) o else if (is.list(o) || is.data.frame(o)) unlist(lapply(o, txt), use.names = FALSE) else character(0)
  sortie <- rbind(sortie, data.frame(entree = n, identical_pt_vg = identical(a, b), chaines = length(txt(a)),
                                     virgule_decimale_sous_vg = any(grepl("[0-9],[0-9]", txt(b)) & !grepl("[0-9],[0-9]+,", txt(b)))))
}
options(width = 160); print(sortie, row.names = FALSE)
