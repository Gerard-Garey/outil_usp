sp <- "<scratchpad>/k2b-rejeu"
.libPaths(c(file.path(sp, "lib_shiny"), file.path(sp, "lib_app"), file.path(sp, "lib"), .libPaths()))
setwd("/home/user/outil_usp")
shiny::runApp("app.R", port = as.integer(Sys.getenv("PORT_APP", "4321")), host = "127.0.0.1", launch.browser = FALSE)
