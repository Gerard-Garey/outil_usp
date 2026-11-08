local({
  f <- Sys.getenv("PROF_OUT")
  if (nzchar(f)) { utils::Rprof(f, interval = 0.02); Sys.unsetenv(c("PROF_OUT", "R_PROFILE_USER")) }
})
.Last <- function() utils::Rprof(NULL)
