sp <- "<scratchpad>/k2b-rejeu"
lib <- file.path(sp, "lib_shiny")
.libPaths(c(lib, file.path(sp, "lib_app"), .libPaths()))
Sys.setenv(USE_BUNDLED_LIBUV = "1", MAKEFLAGS = "-j2")
options(repos = c(CRAN = "https://cloud.r-project.org"), Ncpus = 1L)
install.packages("shiny", lib = lib)
cat("SHINY:", requireNamespace("shiny", quietly = TRUE), "\n")
