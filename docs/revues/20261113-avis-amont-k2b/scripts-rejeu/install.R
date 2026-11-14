lib <- "<scratchpad>/k2b-rejeu/lib"
.libPaths(c(lib, .libPaths()))
options(repos = c(CRAN = "https://cloud.r-project.org"), Ncpus = 4L)
install.packages(c("openxlsx","zip"), lib = lib)
print(requireNamespace("openxlsx", quietly = TRUE))
