SP <- "/tmp/claude-0/-home-user-outil-usp/3407551e-539e-4dba-954f-822f43f11bd0/scratchpad"
x <- readRDS(file.path(SP, "verif_ctl379.rds"))
V <- as.data.frame(do.call(rbind, x$res), stringsAsFactors = FALSE)
B0 <- utils::read.delim("docs/tableaux/20261127-issue379-familles-ln-brut.tsv", colClasses = "character", check.names = FALSE,
                        quote = "", comment.char = "", na.strings = character(0))
cols <- setdiff(intersect(names(B0), names(V)), "ctl")
m <- match(paste(V$jeu, V$point, V$b), paste(B0$jeu, B0$point, B0$b))
same <- vapply(seq_len(nrow(V)), function(i) identical(unname(unlist(V[i, cols])), unname(unlist(B0[m[i], cols]))), logical(1))
cat("colonnes comparees :", length(cols), " ; lignes identiques au brut :", sum(same), "/", nrow(V), "\n")
cat("colonnes de V absentes du brut :", paste(setdiff(names(V), names(B0)), collapse = ", "), "\n")
