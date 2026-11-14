sp <- "<scratchpad>/k2b-rejeu"
lib <- file.path(sp, "lib_old")
.libPaths(c(lib, file.path(sp, "lib"), .libPaths()))
options(repos = c(CRAN = "https://cloud.r-project.org"))
install.packages("https://cran.r-project.org/src/contrib/Archive/zip/zip_2.3.1.tar.gz", repos = NULL, type = "source", lib = lib)
install.packages("https://cran.r-project.org/src/contrib/Archive/openxlsx/openxlsx_4.2.5.2.tar.gz", repos = NULL, type = "source", lib = lib)
cat("VERSIONS:", as.character(packageVersion("openxlsx", lib.loc = lib)), as.character(packageVersion("zip", lib.loc = lib)), "\n")
