# Lab parameter: rekonstruksi ulang dengan parameter pilihan pengguna.

lab_defaults <- list(
  hpv = list(alpha = 0.5204, lambda = 1.6475, omega = 0.9263, q = 0.3197),
  bot = list(alpha = 0.5538, lambda = 2.7266, omega = 0.7207, q = 0.3338)
)

lab_ui <- function(id, lang) {
  ns <- shiny::NS(id)
  bslib::nav_panel(
    title = tr(lang, "Lab", "Lab"),
    value = "lab",
    div(
      class = "page-wrap",
      section_heading(
        tr(lang, "Lab parameter", "Parameter lab"),
        tr(lang,
           "Ubah parameter dan lihat bagaimana rekonstruksi deret tersembunyi berubah. Model tidak diestimasi ulang; hanya likelihood dan Viterbi yang dihitung.",
           "Change parameters and see how the hidden-series reconstruction changes. The model is not re-estimated; only the likelihood and Viterbi path are computed.")
      ),
      bslib::layout_columns(
        col_widths = c(4, 8),
        bslib::card(
          bslib::card_header(tr(lang, "Kontrol", "Controls")),
          bslib::card_body(
            shiny::selectInput(
              ns("dataset"), tr(lang, "Dataset", "Dataset"),
              choices = c("HPV (Girona)" = "hpv", "Botulism (Kanada)" = "bot")
            ),
            shiny::sliderInput(ns("alpha"), "alpha", min = 0.01, max = 0.99,
                               value = lab_defaults$hpv$alpha, step = 0.001),
            shiny::sliderInput(ns("lambda_a"), "lambda", min = 0.1, max = 4,
                               value = lab_defaults$hpv$lambda, step = 0.001),
            shiny::sliderInput(ns("omega"), "omega", min = 0.01, max = 0.99,
                               value = lab_defaults$hpv$omega, step = 0.001),
            shiny::sliderInput(ns("q"), "q", min = 0.01, max = 0.99,
                               value = lab_defaults$hpv$q, step = 0.001),
            shiny::actionButton(ns("reset"), tr(lang, "Kembalikan ke MLE", "Reset to MLE"),
                                class = "btn-outline"),
            p(class = "muted small",
              tr(lang,
                 "Parameter MLE adalah hasil pipeline; slider memungkinkan eksplorasi what-if.",
                 "MLE parameters come from the pipeline; sliders allow what-if exploration."))
          )
        ),
        div(
          shiny::uiOutput(ns("kpis")),
          shiny::uiOutput(ns("warning")),
          bslib::card(
            bslib::card_header(tr(lang, "Rekonstruksi", "Reconstruction")),
            bslib::card_body(plotly::plotlyOutput(ns("plot"), height = "440px"))
          )
        )
      )
    )
  )
}

lab_server <- function(id, data, lang) {
  shiny::moduleServer(id, function(input, output, session) {
    apply_defaults <- function(ds, session) {
      d <- lab_defaults[[ds]]
      if (ds == "hpv") {
        shiny::updateSliderInput(session, "lambda_a", label = "lambda",
                                 min = 0.1, max = 4, value = d$lambda, step = 0.001)
      } else {
        shiny::updateSliderInput(session, "lambda_a", label = "a (kovariat populasi)",
                                 min = 0.5, max = 6, value = d$lambda, step = 0.01)
      }
      shiny::updateSliderInput(session, "alpha", value = d$alpha)
      shiny::updateSliderInput(session, "omega", value = d$omega)
      shiny::updateSliderInput(session, "q", value = d$q)
    }

    shiny::observeEvent(input$dataset, {
      apply_defaults(input$dataset, session)
    }, ignoreInit = TRUE)

    shiny::observeEvent(input$reset, {
      apply_defaults(input$dataset, session)
    })

    result <- shiny::reactive({
      ds <- input$dataset
      if (ds == "hpv") {
        y <- as.integer(data$hpv$series$observed)
        th <- 16
        lam <- rep(input$lambda_a, length(y))
        x <- data$hpv$series$year + (data$hpv$series$week - 1) / 52
        ylab <- tr(lang(), "Kasus per minggu", "Cases per week")
      } else {
        y <- as.integer(data$botulism$series$observed)
        exposure <- data$botulism$series$population / 1e7
        lam <- input$lambda_a * exposure
        th <- 20 + max(y)
        x <- data$botulism$series$year
        ylab <- tr(lang(), "Kasus per tahun", "Cases per year")
      }
      par <- c(input$alpha, input$lambda_a, input$omega, input$q)
      E <- emission_matrix(th, input$omega, input$q, max(y))
      T <- transition_list(lam, th, input$alpha)
      fwd <- forward_core(y, E, T, lam[1] / (1 - input$alpha))
      hidden <- viterbi_paper(y, par, th, lam)
      mean_hidden <- mean(lam) / (1 - input$alpha)
      list(
        y = y, hidden = hidden, x = x, ylab = ylab, th = th,
        loglik = fwd$loglik, mean_hidden = mean_hidden,
        coverage = 100 * mean(y) / mean_hidden,
        max_hidden = max(hidden),
        zeros = sum(y == 0), zeros_hidden = mean(hidden[y == 0])
      )
    }) |> shiny::debounce(250)

    output$plot <- plotly::renderPlotly({
      r <- result()
      plot_lab(r$y, r$hidden, r$x, lang(), r$ylab)
    })
    output$kpis <- shiny::renderUI({
      r <- result()
      div(
        class = "kpi-grid kpi-grid-3",
        kpi_card(fmt_num(r$mean_hidden, 2), tr(lang(), "Rata-rata tersembunyi", "Hidden mean")),
        kpi_card(fmt_pct(r$coverage, 1), tr(lang(), "Cakupan", "Coverage"), NULL, "accent"),
        kpi_card(r$max_hidden, tr(lang(), "Puncak tersembunyi", "Hidden peak"))
      )
    })
    output$warning <- shiny::renderUI({
      r <- result()
      if (!is.finite(r$loglik)) {
        note_box(tr(lang(),
                    "Likelihood nol pada parameter ini. Coba nilai yang lebih dekat ke MLE.",
                    "The likelihood is zero at these parameters. Try values closer to the MLE."),
                 "warn")
      } else {
        note_box(tr(
          lang(),
          paste0("Log-likelihood = ", fmt_num(r$loglik, 2),
                 ". Ada ", r$zeros, " observasi nol; rata-rata rekonstruksinya ",
                 fmt_num(r$zeros_hidden, 2), " kasus."),
          paste0("Log-likelihood = ", fmt_num(r$loglik, 2),
                 ". There are ", r$zeros, " zero observations; their mean reconstruction is ",
                 fmt_num(r$zeros_hidden, 2), " cases.")
        ), "info")
      }
    })
  })
}
