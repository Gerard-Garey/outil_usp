source("/tmp/claude-0/-home-user-outil-usp/9cb815f0-8197-554a-a7db-4a6f9f874cc0/scratchpad/k2-etape1/outils.R")
RACINE <- getwd()
.ln  <- utils::read.csv(file.path(RACINE, "tests", "donnees", "donnees_ln.csv"))
.ln_int <- utils::read.csv(file.path(RACINE, "tests", "donnees", "donnees_ln_interieur.csv"))
tri_df <- utils::read.csv(file.path(RACINE, "tests", "donnees", "triangle_mw.csv"))
.tri <- local({ m <- as.matrix(tri_df[, setdiff(names(tri_df), "i")]); storage.mode(m) <- "double"; unname(m) })
cat("colonnes de .ln :", names(.ln), " n =", nrow(.ln), "\n")
# lire_tableau CSV, copie du code d'app.R (l. 230-250) sans journalisation
lire_csv_app <- function(chemin) {
  nc <- utils::count.fields(chemin, sep = ",", quote = "\"", comment.char = "", blank.lines.skip = FALSE)
  utils::read.csv(chemin, colClasses = "character", blank.lines.skip = FALSE, check.names = FALSE,
                  na.strings = character(0), row.names = NULL)
}
exp_series <- function(xt, yt) data.frame(t = seq_along(xt), xt = xt, yt = yt)
exp_tri <- function(m) { df <- data.frame(i = 0:(nrow(m) - 1), m); names(df) <- c("i", paste0("j", 0:(ncol(m) - 1))); df }  # tableau_export()
grille <- c(0.1, 1/3, 2001, 1e-300, 1.7976931348623157e308)
set.seed(1); alea <- runif(8) * 1000
jeux <- list(
  `six cas : .ln (premium, reserve1, ii6, net)` = list(type = "ser", xt = .ln$xt, yt = .ln$yt),
  `six cas : .ln_int (premium_interieur)`      = list(type = "ser", xt = .ln_int$xt, yt = .ln_int$yt),
  `six cas : .tri (reserve2)`                  = list(type = "tri", m = .tri),
  `grille 0.1,1/3,2001,1e-300,1.797e308`       = list(type = "ser", xt = grille, yt = rev(grille)),
  `8 reels aleatoires (17 chiffres)`           = list(type = "ser", xt = alea, yt = alea / 7),
  `triangle .tri * pi/3 (17 chiffres)`         = list(type = "tri", m = .tri * pi / 3)
)
relire <- function(jeu, df) { # df : data.frame lu (comme l'app) -> xt,yt ou triangle
  if (jeu$type == "ser") { r <- engine_lire_donnees_csv(df); list(ok = r$ok, v = cbind(r$xt, r$yt), ref = cbind(jeu$xt, jeu$yt)) }
  else { r <- engine_lire_triangle(df); list(ok = r$ok, v = r$triangle, ref = jeu$m) }
}
nom_filtre <- function(a, b) if (is.null(a) || length(a) != length(b)) NA else all(a == b)
sortie <- data.frame()
ligne <- function(jeu_nom, export, lecteur, res, ref) {
  v <- res$v; ok_id <- !is.null(v) && length(v) == length(ref) && identical(unname(v), unname(ref))
  ecart <- if (!is.null(v) && length(v) == length(ref) && all(is.finite(v))) max(abs(v - ref) / pmax(abs(ref), .Machine$double.xmin)) else NA
  sortie <<- rbind(sortie, data.frame(jeu = jeu_nom, export = export, lecteur = lecteur, ok = isTRUE(res$ok), identical = ok_id, ecart_rel_max = signif(ecart, 3)))
}
for (nm in names(jeux)) {
  jeu <- jeux[[nm]]
  df <- if (jeu$type == "ser") exp_series(jeu$xt, jeu$yt) else exp_tri(jeu$m)
  ref <- if (jeu$type == "ser") cbind(jeu$xt, jeu$yt) else jeu$m
  # xlsx
  fo <- tempfile(fileext = ".xlsx"); engine_ecrire_xlsx(df, fo)                       # openxlsx present
  fi <- tempfile(fileext = ".xlsx"); sans_ox(engine_ecrire_xlsx(df, fi))              # ecrivain interne
  for (w in c("openxlsx", "interne")) for (lec in c("openxlsx", "interne")) {
    f <- if (w == "openxlsx") fo else fi
    d <- if (lec == "interne") sans_ox(engine_lire_xlsx(f)) else engine_lire_xlsx(f)
    ligne(nm, paste0("xlsx ecrit par ", w), paste0("lu par ", lec), relire(jeu, d), ref)
  }
  # CSV (write.csv exact comme app.R)
  fc <- tempfile(fileext = ".csv"); utils::write.csv(df, fc, row.names = FALSE, na = "")
  ligne(nm, "csv write.csv (app.R)", "lecture app (read.csv)", relire(jeu, lire_csv_app(fc)), ref)
  # CSV avec sprintf %.17g a titre de controle
  fc2 <- tempfile(fileext = ".csv")
  d17 <- df; for (j in seq_along(d17)) if (is.numeric(d17[[j]])) d17[[j]] <- vapply(d17[[j]], function(v) if (is.na(v)) "" else { s <- sprintf("%.15g", v); if (as.double(s) != v) sprintf("%.17g", v) else s }, "")
  utils::write.csv(d17, fc2, row.names = FALSE, na = "", quote = FALSE)
  ligne(nm, "csv regle .xlsx_nombre (temoin)", "lecture app (read.csv)", relire(jeu, lire_csv_app(fc2)), ref)
}
options(width = 200); print(sortie, row.names = FALSE)
