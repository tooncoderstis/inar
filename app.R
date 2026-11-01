library(shiny)

# INAR Under-reporting Lab — aplikasi Shiny.
# Angka berasal dari scripts/run_analysis.R; UI tidak menghitung ulang kecuali di tab Lab.

source("R/env.R")
load_dotenv()
source("R/load_data.R")
source("R/ui_helpers.R")
source("R/plots.R")
source("R/mod_home.R")
source("R/mod_example.R")
source("R/mod_meso.R")
source("R/mod_methodology.R")
source("R/mod_lab.R")
source("R/mod_verification.R")
source("R/mod_data.R")
source("R/paper.R")
source("R/mod_paper.R")
source("R/engine.R")

app_data <- load_app_data(".")

build_page <- function(lang, data) {
  links <- div(
    class = "lang-switch",
    tags$a(href = "?lang=id", class = if (lang == "id") "active" else "", "ID"),
    tags$span("/"),
    tags$a(href = "?lang=en", class = if (lang == "en") "active" else "", "EN")
  )
  tagList(
    bslib::page_navbar(
      title = tags$span(class = "brand", "INAR", tags$span(class = "brand-sub", "Lab")),
      id = "nav",
      window_title = "INAR Under-reporting Lab",
      fillable = FALSE,
      home_ui(lang, data),
      example_ui("hpv", lang, data$hpv, "hpv"),
      example_ui("bot", lang, data$botulism, "bot"),
      meso_ui("meso", lang, data$mesothelioma),
      methodology_ui(lang),
      lab_ui("lab", lang),
      verification_ui("verification", lang, data),
      data_ui("data", lang),
      paper_ui("paper", lang),
      about_ui(lang, data),
      bslib::nav_spacer(),
      bslib::nav_item(links)
    ),
    tags$footer(
      class = "app-footer",
      div(
        class = "footer-inner",
        span("INAR Under-reporting Lab"),
        span(class = "dot", "·"),
        span(tr(lang, "Rekonstruksi Fernandez-Fontelo dkk. (2016)", "Reconstruction of Fernandez-Fontelo et al. (2016)")),
        span(class = "dot", "·"),
        tags$a(href = "https://doi.org/10.1002/sim.7026", "doi:10.1002/sim.7026")
      )
    )
  )
}

ui <- bslib::page_fluid(
  theme = bslib::bs_theme(
    version = 5,
    bootswatch = "flatly",
    primary = "#0f766e",
    secondary = "#334155",
    success = "#0f766e",
    info = "#0e7490",
    warning = "#b45309",
    danger = "#b91c1c",
    base_font = bslib::font_google("Inter", local = FALSE),
    heading_font = bslib::font_google("Inter", local = FALSE)
  ),
  tags$head(
    tags$meta(charset = "utf-8"),
    tags$meta(name = "viewport", content = "width=device-width, initial-scale=1"),
    tags$meta(name = "description",
              content = "Laboratorium under-reporting dengan model INAR(1)-hidden Markov chain."),
    tags$link(rel = "stylesheet", href = "styles.css"),
    tags$link(rel = "icon", type = "image/svg+xml", href = "favicon.svg"),
    tags$script(HTML(
      "window.MathJax = {tex: {inlineMath: [['$','$'], ['\\\\(','\\\\)']], displayMath: [['$$','$$'], ['\\\\[','\\\\]']]}, svg: {fontCache: 'global'}};"
    )),
    tags$script(src = "https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js", defer = ""),
    tags$script(src = "vendor/pdfjs/pdf.min.js"),
    tags$script(src = "app.js"),
    tags$script(src = "pdfjs-viewer.js")
  ),
  shiny::uiOutput("page")
)

server <- function(input, output, session) {
  lang <- shiny::reactive({
    q <- shiny::parseQueryString(session$clientData$url_search)
    if (identical(q$lang, "en")) "en" else "id"
  })

  output$page <- shiny::renderUI({
    build_page(lang(), app_data)
  })

  example_server("hpv", app_data$hpv, "hpv", lang, app_data$verification)
  example_server("bot", app_data$botulism, "bot", lang, app_data$verification)
  meso_server("meso", app_data$mesothelioma, lang)
  verification_server("verification", app_data, lang)
  lab_server("lab", app_data, lang)
  data_server("data", lang)
  paper_server("paper", lang, root = ".")
}

shiny::shinyApp(ui, server)
