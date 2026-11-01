#!/usr/bin/env Rscript
port <- as.integer(Sys.getenv("PORT", "3838"))
shiny::runApp(".", host = "0.0.0.0", port = port, launch.browser = FALSE)
