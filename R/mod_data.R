# Modul data: pratinjau dan unduhan.

data_ui <- function(id, lang) {
  ns <- shiny::NS(id)
  bslib::nav_panel(
    title = tr(lang, "Data", "Data"),
    value = "data",
    div(
      class = "page-wrap",
      section_heading(
        tr(lang, "Data dan provenance", "Data and provenance"),
        tr(lang,
           "Data mentah tidak diubah. Semua transformasi tercatat dan dapat diunduh.",
           "Raw data are unchanged. Every transformation is documented and downloadable.")
      ),
      bslib::navset_card_tab(
        bslib::nav_panel(
          "HPV Girona",
          DT::DTOutput(ns("hpv_table")),
          div(class = "download-row",
              shiny::downloadButton(ns("hpv_csv"), "CSV", class = "btn-outline"))
        ),
        bslib::nav_panel(
          "Botulism",
          DT::DTOutput(ns("bot_table")),
          div(class = "download-row",
              shiny::downloadButton(ns("bot_csv"), "CSV", class = "btn-outline"))
        ),
        bslib::nav_panel(
          "Mesothelioma",
          DT::DTOutput(ns("meso_table")),
          div(class = "download-row",
              shiny::downloadButton(ns("meso_csv"), "CSV", class = "btn-outline"))
        ),
        bslib::nav_panel(
          tr(lang, "Provenance", "Provenance"),
          div(class = "prose",
              HTML(shiny::markdown(paste(
                readLines(file.path("data", "processed", "PROVENANCE.md"),
                          warn = FALSE, encoding = "UTF-8"),
                collapse = "\n"
              ))))
        )
      )
    )
  )
}

data_server <- function(id, lang) {
  shiny::moduleServer(id, function(input, output, session) {
    hpv <- utils::read.csv(file.path("data", "processed", "hpv_girona.csv"))
    bot <- utils::read.csv(file.path("data", "processed", "botulism_canada.csv"))
    meso <- utils::read.csv(file.path("data", "processed", "mesothelioma_gb.csv"))

    dt_opts <- list(pageLength = 10, dom = "ftp", scrollX = TRUE)
    output$hpv_table <- DT::renderDT(DT::datatable(hpv, rownames = FALSE, options = dt_opts))
    output$bot_table <- DT::renderDT(DT::datatable(bot, rownames = FALSE, options = dt_opts))
    output$meso_table <- DT::renderDT(DT::datatable(meso, rownames = FALSE, options = dt_opts))

    output$hpv_csv <- shiny::downloadHandler(
      filename = function() "hpv_girona.csv",
      content = function(file) file.copy(file.path("data", "processed", "hpv_girona.csv"), file)
    )
    output$bot_csv <- shiny::downloadHandler(
      filename = function() "botulism_canada.csv",
      content = function(file) file.copy(file.path("data", "processed", "botulism_canada.csv"), file)
    )
    output$meso_csv <- shiny::downloadHandler(
      filename = function() "mesothelioma_gb.csv",
      content = function(file) file.copy(file.path("data", "processed", "mesothelioma_gb.csv"), file)
    )
  })
}
