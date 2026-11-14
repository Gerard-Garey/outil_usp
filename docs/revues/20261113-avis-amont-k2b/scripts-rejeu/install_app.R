sp <- "<scratchpad>/k2b-rejeu"
lib <- file.path(sp, "lib_app")
.libPaths(c(lib, .libPaths()))
options(repos = c(CRAN = "https://cloud.r-project.org"), Ncpus = 2L)
Sys.setenv(MAKEFLAGS = "-j2")
install.packages("shiny", lib = lib)
cat("SHINY:", requireNamespace("shiny", quietly = TRUE), "\n")
install.packages("plotly", lib = lib)
cat("PLOTLY:", requireNamespace("plotly", quietly = TRUE), "\n")
