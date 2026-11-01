# Modul ekstensi mesothelioma.

meso_ui <- function(id, lang, d) {
  ns <- shiny::NS(id)
  st <- d$stats
  latest <- d$series[nrow(d$series), ]
  bslib::nav_panel(
    title = "Mesothelioma",
    value = "meso",
    div(
      class = "page-wrap",
      section_heading(
        tr(
          lang, "Mesothelioma di Britania Raya, 1968-2013",
          "Mesothelioma in Great Britain, 1968-2013"
        ),
        tr(
          lang, "Ekstensi data HSE - bukan reproduksi seri paper",
          "HSE data extension - not a reproduction of the paper's series"
        )
      ),
      note_box(
        tr(
          lang,
          paste0(
            "<strong>Mengapa N/A?</strong> Paper memakai seri ONS dengan rata-rata 14, varians 34, dan rentang 3-30. ",
            "File HSE yang tersedia berisi jumlah kematian total (rata-rata sekitar 1.133, rentang 153-2.560). ",
            "Keduanya bukan seri yang sama, sehingga angka Table II paper tidak diklaim sebagai hasil."
          ),
          paste0(
            "<strong>Why N/A?</strong> The paper uses an ONS series with mean 14, variance 34, and range 3-30. ",
            "The available HSE file contains total deaths (mean about 1,133, range 153-2,560). ",
            "They are not the same series, so the paper's Table II numbers are not claimed as results."
          )
        ),
        "warn"
      ),
      div(
        class = "kpi-grid",
        kpi_card(st$n, tr(lang, "Tahun", "Years"), "1968-2013"),
        kpi_card(fmt_num(st$mean, 0), tr(lang, "Rata-rata kematian", "Mean deaths")),
        kpi_card(format(latest$observed, big.mark = ","), tr(lang, "Kematian 2013", "Deaths in 2013")),
        kpi_card(fmt_num(latest$rate_per_100k, 2), tr(lang, "Rate per 100.000 (2013)", "Rate per 100,000 (2013)"))
      ),
      plot_card(
        tr(lang, "Kematian dan rate per 100.000", "Deaths and rate per 100,000"),
        ns("series"),
        tr(
          lang, "Data HSE MESO01; populasi dari World Bank.",
          "HSE MESO01 data; population from the World Bank."
        )
      ),
      bslib::card(
        bslib::card_header(tr(lang, "Apa yang bisa dipelajari", "What can be learned")),
        bslib::card_body(
          p(tr(
            lang,
            paste0(
              "Ekstensi ini menunjukkan pola kohort dan puncak kematian mesothelioma, ",
              "serta pentingnya kovariat populasi ketika memodelkan tren jangka panjang. ",
              "Model INAR-HMM tidak dipaksakan pada seri ini karena state space akan sangat besar ",
              "dan seri asli paper tidak tersedia."
            ),
            paste0(
              "This extension shows the cohort pattern and peak in mesothelioma deaths, ",
              "and why a population covariate matters when modelling long-term trends. ",
              "The INAR-HMM is not forced onto this series because the state space would be very large ",
              "and the paper's original series is unavailable."
            )
          ))
        )
      )
    )
  )
}

meso_server <- function(id, d, lang) {
  shiny::moduleServer(id, function(input, output, session) {
    output$series <- plotly::renderPlotly(plot_meso_series(d, lang()))
  })
}
