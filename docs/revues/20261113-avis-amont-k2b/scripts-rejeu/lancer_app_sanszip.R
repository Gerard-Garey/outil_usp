sp <- "<scratchpad>/k2b-rejeu"
.libPaths(c(file.path(sp, "lib_shiny"), file.path(sp, "lib_app"), .libPaths()))   # sans le paquet zip ni openxlsx
setwd("/home/user/outil_usp")
cat("zip paquet:", requireNamespace("zip", quietly = TRUE), " R_ZIPCMD:", Sys.getenv("R_ZIPCMD"), " Sys.which:", unname(Sys.which(Sys.getenv("R_ZIPCMD", "zip"))), "\n")
shiny::runApp("app.R", port = as.integer(Sys.getenv("PORT_APP", "4322")), host = "127.0.0.1", launch.browser = FALSE)
