source("/tmp/claude-0/-home-user-outil-usp/9cb815f0-8197-554a-a7db-4a6f9f874cc0/scratchpad/k2-etape1/outils.R")
tri_csv <- utils::read.csv("tests/donnees/triangle_mw.csv", colClasses = "character", check.names = FALSE, na.strings = character(0), blank.lines.skip = FALSE)
cat("lu :", dim(tri_csv), " noms:", names(tri_csv), "\n")
mod <- function(df, noms, avec_i = TRUE, vider0 = TRUE) { # df: i,j0..j7
  if (vider0) df[[2]] <- ""
  names(df) <- noms
  if (!avec_i) df <- df[, -1, drop = FALSE]
  df
}
cas <- list(
  A_avec_i_ent0_vide   = mod(tri_csv, c("i", "", paste0("j", 1:7)), TRUE),
  B_sans_i_ent0_vide   = mod(tri_csv, c("i", "", paste0("j", 1:7)), FALSE),
  A2_avec_i_tous_ent_vides = mod(tri_csv, c("i", rep("", 8)), TRUE),
  B2_sans_i_tous_ent_vides = mod(tri_csv, c("i", rep("", 8)), FALSE),
  A3_avec_i_ent0_present = mod(tri_csv, c("i", "j0", paste0("j", 1:7)), TRUE),
  B3_sans_i_ent0_present = mod(tri_csv, c("i", "j0", paste0("j", 1:7)), FALSE),
  A4_avec_i_entetes_numeriques = mod(tri_csv, c("i", "0", as.character(1:7)), TRUE),
  B4_sans_i_entetes_numeriques = mod(tri_csv, c("i", "0", as.character(1:7)), FALSE)
)
res_str <- function(r) sprintf("ok=%s dim=%s | %s", r$ok, if (is.null(r$triangle)) "-" else paste(dim(r$triangle), collapse = "x"), paste(r$erreurs, collapse = " // "))
for (n in names(cas)) { r <- engine_lire_triangle(cas[[n]]); cat(sprintf("%-30s %s\n", n, substr(res_str(r), 1, 330))) }

cat("\n== run_engine() sur le triangle lu (B = 199, graine par defaut) : cas B (sans i, col 0 vide sans en-tete)\n")
ref <- engine_lire_triangle(tri_csv)
cat("reference (col 0 pleine) dim:", dim(ref$triangle), "\n")
rB <- engine_lire_triangle(cas$B_sans_i_ent0_vide)
rA <- engine_lire_triangle(cas$A_avec_i_ent0_vide)
for (nm in c("A", "B")) {
  r <- get(paste0("r", nm))
  if (isTRUE(r$ok)) {
    e <- run_engine(methode = "reserve2", triangle = r$triangle, segment = 1, annexe = "II", B = 199)
    cat(nm, ": engine ok =", e$ok, " sigma_usp =", format(e$parametre$sigma_usp, digits = 10), " tri dim:", dim(e$triangle), "\n")
  } else cat(nm, ": lecture refusee\n")
}
e0 <- run_engine(methode = "reserve2", triangle = ref$triangle, segment = 1, annexe = "II", B = 199)
cat("reference col 0 pleine : sigma_usp =", format(e0$parametre$sigma_usp, digits = 10), "\n")
cat("noms de e0$parametre :", names(e0$parametre), "\n")
