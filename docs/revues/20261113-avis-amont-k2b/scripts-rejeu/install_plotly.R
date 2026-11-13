sp <- "<scratchpad>/k2b-rejeu"
lib <- file.path(sp, "lib_shiny")
.libPaths(c(lib, file.path(sp, "lib_app"), .libPaths()))
Sys.setenv(USE_BUNDLED_LIBUV = "1", MAKEFLAGS = "-j2",
           INCLUDE_DIR = file.path(sp, "debs/dev/inc"), LIB_DIR = file.path(sp, "debs/dev/lib"),
           PKG_CONFIG_PATH = "", LD_LIBRARY_PATH = "")
options(repos = c(CRAN = "https://cloud.r-project.org"), Ncpus = 2L)
install.packages("plotly", lib = lib)
cat("PLOTLY:", requireNamespace("plotly", quietly = TRUE), "\n")
