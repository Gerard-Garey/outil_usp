# Prototype (hors depot) : lanceur parallele par fork d'un processus ou le moteur est
# deja charge (et optionnellement precompile), au lieu d'un Rscript neuf par fichier.
# Usage : Rscript lanceur_fork.R <n> <precompiler: 0|1> <sortie.tsv>
a <- commandArgs(TRUE); n <- as.integer(a[1]); precomp <- a[2] == "1"; sortie <- a[3]
setwd("/home/user/outil_usp")
LANCEUR_UNITAIRES <- TRUE
source("tests/unitaires/outils_unitaires.R")
t0 <- Sys.time()
if (precomp) {
  env <- environment(run_engine)
  for (nm in ls(env, all.names = TRUE)) {
    f <- get(nm, env)
    if (is.function(f) && !is.primitive(f)) assign(nm, compiler::cmpfun(f), envir = env)
  }
  # copies globales (charger_moteur expose une copie) : les repointer
  for (nm in ls(env, all.names = TRUE)) if (exists(nm, envir = globalenv(), inherits = FALSE) && is.function(get(nm, env)))
    assign(nm, get(nm, env), envir = globalenv())
  invisible(sw_loi_nulle(8))
}
cat("preparation :", round(as.numeric(difftime(Sys.time(), t0, units = "secs")), 1), "s\n")
ci <- read.delim("/tmp/duree-ci/durees_ci_1152.tsv", header = FALSE, col.names = c("f","n","d"))
fich <- sort(list.files("tests/unitaires", pattern = "^test_.*[.]R$", full.names = TRUE))
d <- setNames(ci$d, ci$f)[sub("[.]R$", "", basename(fich))]
attente <- fich[order(-d)]
executer <- function(f) {
  t1 <- Sys.time()
  log <- file.path(tempdir(), paste0(basename(f), ".log"))
  zz <- file(log, open = "wt"); sink(zz); sink(zz, type = "message")
  .tu$lignes <- .tu$lignes[0, ]
  r <- tryCatch({ sys.source(f, envir = new.env(parent = globalenv())); NULL }, error = function(e) e)
  if (inherits(r, "error")) { .tu$fichier <- basename(f); .enregistrer("chargement du fichier", "ECHEC", conditionMessage(r)) }
  sink(type = "message"); sink(); close(zz)
  s <- table(factor(.tu$lignes$statut, levels = c("OK","ECHEC","ATTENDU","INATTENDU")))
  c(as.list(s), duree = as.numeric(difftime(Sys.time(), t1, units = "secs")))
}
en_cours <- list(); res <- list()
t0 <- Sys.time()
while (length(attente) || length(en_cours)) {
  while (length(attente) && length(en_cours) < n) {
    f <- attente[[1]]; attente <- attente[-1]
    en_cours[[basename(f)]] <- parallel::mcparallel(executer(f), name = basename(f))
  }
  fini <- parallel::mccollect(en_cours, wait = FALSE, timeout = 1)
  for (nm in names(fini)) { en_cours[[nm]] <- NULL; res[[nm]] <- fini[[nm]] }
}
tot <- as.numeric(difftime(Sys.time(), t0, units = "secs"))
df <- do.call(rbind, lapply(names(res), function(nm) data.frame(fichier = nm, ok = res[[nm]]$OK, echec = res[[nm]]$ECHEC,
   attendu = res[[nm]]$ATTENDU, inattendu = res[[nm]]$INATTENDU, duree = round(res[[nm]]$duree, 1))))
write.table(df, sortie, sep = "\t", row.names = FALSE, quote = FALSE)
cat(sprintf("mural %.1f s ; somme %.1f s ; assertions %d ; echecs %d ; attendus %d ; inattendus %d\n",
            tot, sum(df$duree), sum(df$ok + df$echec + df$attendu + df$inattendu), sum(df$echec), sum(df$attendu), sum(df$inattendu)))
