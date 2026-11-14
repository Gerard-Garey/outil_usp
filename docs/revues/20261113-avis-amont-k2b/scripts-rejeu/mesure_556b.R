sp <- "<scratchpad>/k2b-rejeu"
.libPaths(c(file.path(sp, "lib_shiny"), file.path(sp, "lib_app"), file.path(sp, "lib"), .libPaths()))
suppressMessages(library(shiny))
setwd("/home/user/outil_usp")
source(file.path(sp, "fab.R"))   # fab() ; lire2() n'est pas utilise ici
ea <- new.env(); app <- source("app.R", local = ea)$value
notifs <- character(0)
assign("showNotification", function(ui, ..., type = "default") { notifs <<- c(notifs, sprintf("[%s] %s", type, paste(as.character(ui), collapse = ""))); invisible("id") }, envir = ea)
assign("updateNumericInput", function(...) invisible(NULL), envir = ea)
base <- list(annexe = "II", segment = "1", sigma_manuel = FALSE, B = 99, alpha = 0.10, seed = 20260831,
             delta_apriori = FALSE, theta_equiv = 0.10, methode = "premium", nature_donnees = "brutes", profondeur = 8)
num <- function(ref, v) sprintf('<c r="%s"><v>%s</v></c>', ref, v)
sst <- function(ref, i) sprintf('<c r="%s" t="s"><v>%d</v></c>', ref, i)
row <- function(r, ...) sprintf('<row r="%d">%s</row>', r, paste0(..., collapse = ""))
ecrire_csv <- function(txt, nom) { f <- file.path(tempdir(), nom); writeLines(txt, f, useBytes = TRUE); f }
fi <- function(chemin, nom = basename(chemin)) data.frame(name = nom, size = file.size(chemin), type = "", datapath = chemin, stringsAsFactors = FALSE)
cas <- list()
# 1 xlsx illisible
f1 <- ecrire_csv("pas un classeur", "faux.xlsx")
# 2 xlsx refus moteur : ligne 1 vide (header en ligne 2)
f2 <- file.path(tempdir(), "ligne1.xlsx")
fab(f2, paste0(row(2, sst("A2",0), sst("B2",1), sst("C2",2)), row(3, num("A3",1), num("B3",100), num("C3",70))), shared = c("<t>t</t>","<t>xt</t>","<t>yt</t>"))
# 3 xlsx refus moteur : cellule sans r
f3 <- file.path(tempdir(), "sans_r.xlsx")
fab(f3, paste0(row(1, sst("A1",0), sst("B1",1), sst("C1",2)), row(2, num("A2",1), '<c><v>100</v></c>', num("C2",70))), shared = c("<t>t</t>","<t>xt</t>","<t>yt</t>"))
# 4 CSV illisible : ligne plus longue que l'en-tete
f4 <- ecrire_csv(c("t,xt,yt", "1,100,70,5", "2,101,71"), "long.csv")
# 5 CSV series : colonne yt absente (erreur du moteur engine_lire_donnees_csv)
f5 <- ecrire_csv(c("t,xt", "1,100", "2,101", "3,102", "4,103", "5,104"), "sans_yt.csv")
# 6 CSV series : valeur non numerique
f6 <- ecrire_csv(c("t,xt,yt", "1,100,70", "2,abc,71", "3,102,72", "4,103,73", "5,104,74"), "texte.csv")
# 7 dimension : 60 annees (> PROFONDEUR_MAX)
f7 <- file.path(tempdir(), "long60.csv"); utils::write.csv(data.frame(t = 1:60, xt = 100 + 1:60, yt = 70 + 1:60), f7, row.names = FALSE)
# 8 triangle : trapeze 8 x 6 (en methode reserve2)
tri86 <- matrix(NA_real_, 8, 6); for (i in 0:7) for (j in 0:5) if (i + j <= 7) tri86[i+1,j+1] <- (100+i+j)*1.3^j
f8 <- file.path(tempdir(), "trapeze.csv"); utils::write.csv(data.frame(i = 0:7, setNames(as.data.frame(tri86), paste0("j", 0:5))), f8, row.names = FALSE, na = "")
# 9 triangle : dimension 41 x 41
tri41 <- ea$triangle_defaut(41)
f9 <- file.path(tempdir(), "tri41.csv"); utils::write.csv(data.frame(i = 0:40, setNames(as.data.frame(tri41), paste0("j", 0:40))), f9, row.names = FALSE, na = "")
# 10 triangle xlsx : refus de moteur (ligne1 vide) en reserve2 (meme chemin que 2)
liste <- list(
  list("1. xlsx illisible (fichier texte .xlsx)", f1, "premium"),
  list("2. xlsx : refus du moteur (ligne 1 vide)", f2, "premium"),
  list("3. xlsx : refus du moteur (cellule sans r)", f3, "premium"),
  list("4. CSV illisible (ligne plus longue que l'en-tete)", f4, "premium"),
  list("5. CSV series : colonne yt absente (erreur de validation du moteur)", f5, "premium"),
  list("6. CSV series : valeur non numerique", f6, "premium"),
  list("7. CSV series 60 annees (> PROFONDEUR_MAX)", f7, "premium"),
  list("8. CSV triangle : trapeze 8 x 6 (reserve 2)", f8, "reserve2"),
  list("9. CSV triangle 41 x 41 (> PROFONDEUR_MAX), reserve 2", f9, "reserve2"))
cat("PROFONDEUR_MAX =", ea$PROFONDEUR_MAX, "\n")
for (cas in liste) {
  notifs <<- character(0)
  testServer(app, {
    do.call(session$setInputs, modifyList(base, list(methode = cas[[3]])))
    d0 <- donnees(); t0 <- triangle()
    suppressMessages(session$setInputs(fichier_import = fi(cas[[2]])))
    cat("\n###", cas[[1]], "\n")
    cat("  statut$ok  :", statut_import()$ok, "\n")
    cat("  statut$msg :", statut_import()$msg, "\n")
    cat("  notification(s) :", paste(notifs, collapse = " | "), "\n")
    cat("  donnees conservees :", identical(donnees(), d0), " triangle conserve :", identical(triangle(), t0), "\n")
    cat("  HTML du statut :", gsub("\\s+", " ", as.character(output$import_statut$html)), "\n")
  })
}
