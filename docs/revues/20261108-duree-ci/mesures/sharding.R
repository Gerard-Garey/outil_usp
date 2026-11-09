ci <- read.delim("/tmp/duree-ci/durees_ci_1152.tsv", header = FALSE, col.names = c("f","n","d"))
d <- setNames(ci$d, ci$f)
lpt <- function(d, m) { fin <- rep(0, m); aff <- integer(length(d)); o <- order(-d); for (i in o) { k <- which.min(fin); fin[k] <- fin[k] + d[i]; aff[i] <- k }; list(fin = fin, aff = aff) }
mural_shards <- function(d, s, p = 4) {
  # repartition LPT entre shards (sur la somme), puis LPT a p processus dans chaque shard
  r <- lpt(d, s); sapply(1:s, function(k) max(lpt(d[r$aff == k], p)$fin))
}
d2 <- d; d2 <- c(d2[names(d2) != "test_merz_wuthrich"], test_merz_a = d[["test_merz_wuthrich"]]/2, test_merz_b = d[["test_merz_wuthrich"]]/2)
for (s in 1:3) cat(sprintf("%d shard(s) : mural par shard = %s s ; avec test_merz_wuthrich coupe en deux : %s s\n", s,
  paste(round(mural_shards(d, s)), collapse = "/"), paste(round(mural_shards(d2, s)), collapse = "/")))
