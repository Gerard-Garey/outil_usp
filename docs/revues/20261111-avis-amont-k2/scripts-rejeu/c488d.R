source("/tmp/claude-0/-home-user-outil-usp/9cb815f0-8197-554a-a7db-4a6f9f874cc0/scratchpad/k2-etape1/outils.R")
.ln <- utils::read.csv("tests/donnees/donnees_ln.csv")
xt <- .ln$xt * (1 + 1/3e3); yt <- .ln$yt * (1 + 1/7e3)   # 17 chiffres significatifs
df <- data.frame(t = seq_along(xt), xt = xt, yt = yt)
lire_csv_app <- function(chemin) utils::read.csv(chemin, colClasses = "character", blank.lines.skip = FALSE, check.names = FALSE, na.strings = character(0), row.names = NULL)
calc <- function(x, y) run_engine(xt = x, yt = y, methode = "premium", segment = 1, annexe = "II", nature_donnees = "brutes", B = 99)
r0 <- calc(xt, yt); e0 <- engine_empreinte(r0)
cat(sprintf("%-34s %-22s %-34s %s\n", "export", "sigma_usp", "empreinte donnees", "= origine ?"))
cat(sprintf("%-34s %-22s %-34s\n", "origine (donnees en memoire)", format(r0$parametre$sigma_usp, digits = 17), e0$donnees))
essai <- function(nom, d) { r <- engine_lire_donnees_csv(d); rr <- calc(r$xt, r$yt); e <- engine_empreinte(rr)
  cat(sprintf("%-34s %-22s %-34s %s ; ecart rel sigma = %.2e\n", nom, format(rr$parametre$sigma_usp, digits = 17), e$donnees, identical(e$donnees, e0$donnees),
              abs(rr$parametre$sigma_usp - r0$parametre$sigma_usp) / r0$parametre$sigma_usp)) }
fo <- tempfile(fileext = ".xlsx"); engine_ecrire_xlsx(df, fo); essai("xlsx par openxlsx, relu openxlsx", engine_lire_xlsx(fo)); essai("xlsx par openxlsx, relu interne", sans_ox(engine_lire_xlsx(fo)))
fi <- tempfile(fileext = ".xlsx"); sans_ox(engine_ecrire_xlsx(df, fi)); essai("xlsx par interne, relu openxlsx", engine_lire_xlsx(fi)); essai("xlsx par interne, relu interne", sans_ox(engine_lire_xlsx(fi)))
fc <- tempfile(fileext = ".csv"); utils::write.csv(df, fc, row.names = FALSE, na = ""); essai("csv write.csv (app.R)", lire_csv_app(fc))
