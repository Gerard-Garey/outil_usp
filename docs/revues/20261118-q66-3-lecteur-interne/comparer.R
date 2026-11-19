# Compare, classeur par classeur, les retours des deux chemins (lire_corpus.R).
a <- readRDS(commandArgs(TRUE)[1]); b <- readRDS(commandArgs(TRUE)[2])
cat("A :", a$chemin, " B :", b$chemin, "\n")
etat <- function(x) if (inherits(x, "refus")) paste0("refus ", x$classe[1]) else sprintf("lu %dx%d", nrow(x), ncol(x))
for (f in names(a$res)) {
  ra <- a$res[[f]]; rb <- b$res[[f]]
  lu_id <- identical(ra$lu, rb$lu); aval_id <- identical(ra$aval, rb$aval)
  diff <- ""
  if (!lu_id && is.data.frame(ra$lu) && is.data.frame(rb$lu)) {
    d <- character(0)
    if (!identical(names(ra$lu), names(rb$lu))) d <- c(d, "noms")
    for (k in intersect(names(ra$lu), names(rb$lu)))
      if (!identical(ra$lu[[k]], rb$lu[[k]])) d <- c(d, sprintf("%s(%s/%s)", k, class(ra$lu[[k]])[1], class(rb$lu[[k]])[1]))
    diff <- paste(d, collapse = ",")
  }
  if (!lu_id && inherits(ra$lu, "refus") && inherits(rb$lu, "refus"))
    diff <- if (identical(ra$lu$message, rb$lu$message)) "meme message" else "messages differents"
  cat(sprintf("%-70s %-14s lu_ident=%-5s aval_ident=%-5s %s | t_A=%.3fs t_B=%.3fs\n",
      sub(".*/(mesure-594|q663)/", "", f), etat(ra$lu), lu_id, aval_id, diff, ra$duree, rb$duree))
}
