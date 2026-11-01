# Modul dashboard contoh (HPV dan Botulism).

example_ui <- function(id, lang, d, kind) {
  ns <- shiny::NS(id)
  is_hpv <- kind == "hpv"
  f <- d$fit
  st <- d$stats
  title <- if (is_hpv) {
    tr(lang, "HPV di Girona, 2010-2014", "HPV in Girona, 2010-2014")
  } else {
    tr(lang, "Botulism di Kanada, 1970-2013", "Botulism in Canada, 1970-2013")
  }
  sub <- if (is_hpv) {
    tr(lang, "Deret mingguan yang stasioner: contoh paling sederhana dari metode INAR-HMM.",
       "A stationary weekly series: the simplest illustration of the INAR-HMM method.")
  } else {
    tr(lang, "Deret tahunan dengan kovariat populasi; counts diturunkan dari rate publik.",
       "An annual series with a population covariate; counts derived from public rates.")
  }

  bslib::nav_panel(
    title = if (is_hpv) "HPV" else "Botulism",
    value = kind,
    div(
      class = "page-wrap",
      section_heading(title, sub),
      if (!is_hpv) {
        note_box(
          tr(lang,
             paste0("<strong>Status: perkiraan.</strong> File counts asli (bot.csv/popC.csv) tidak tersedia. ",
                    "Counts di sini diturunkan dari rate per 100.000 dikali populasi, lalu 2010 dikoreksi menjadi 2 ",
                    "mengikuti skrip paper. Estimasi MLE karenanya berstatus <em>ESTIMATED</em>, bukan PASS."),
             paste0("<strong>Status: estimated.</strong> The original count files (bot.csv/popC.csv) are unavailable. ",
                    "Counts are derived from rates per 100,000 times population, with 2010 corrected to 2 following ",
                    "the paper's script. The MLE is therefore <em>ESTIMATED</em>, not PASS.")),
          "warn"
        )
      },
      div(
        class = "kpi-grid",
        kpi_card(st$n, tr(lang, "Observasi", "Observations"),
                 if (is_hpv) tr(lang, "minggu", "weeks") else tr(lang, "tahun", "years")),
        kpi_card(fmt_num(st$mean, 2), tr(lang, "Rata-rata tercatat", "Observed mean")),
        kpi_card(fmt_num(f$mean_hidden, 2), tr(lang, "Rata-rata tersembunyi", "Hidden mean"),
                 tr(lang, "estimasi model", "model estimate")),
        kpi_card(fmt_pct(f$coverage_pct, 1), tr(lang, "Cakupan tercatat", "Reporting coverage"),
                 tr(lang, "tercatat / tersembunyi", "observed / hidden"), "accent"),
        kpi_card(fmt_num(f$omega, 3), tr(lang, "Frekuensi under-reporting", "Under-reporting frequency"),
                 "omega"),
        kpi_card(fmt_num(f$q, 3), tr(lang, "Intensitas under-reporting", "Under-reporting intensity"),
                 "q")
      ),
      plot_card(
        tr(lang, "Proses tercatat vs tersembunyi", "Observed vs hidden process"),
        ns("series"),
        tr(lang, "Garis gelap adalah rekonstruksi Viterbi dari deret tersembunyi.",
           "The dark line is the Viterbi reconstruction of the hidden series.")
      ),
      bslib::layout_columns(
        col_widths = c(7, 5),
        bslib::card(
          bslib::card_header(tr(lang, "Parameter model", "Model parameters")),
          bslib::card_body(DT::DTOutput(ns("params")))
        ),
        bslib::card(
          bslib::card_header(tr(lang, "Cara membaca", "How to read")),
          bslib::card_body(
            if (is_hpv) {
              tagList(
                p(HTML(tr(
                  lang,
                  paste0("Model INAR(1) untuk proses tersembunyi adalah ",
                         "<em>X<sub>n</sub> = ", fmt_num(f$alpha, 3), " o X<sub>n-1</sub> + W<sub>n</sub>(",
                         fmt_num(f$lambda, 3), ")</em>. ",
                         "Dengan probabilitas ", fmt_num(f$omega, 3), ", nilai yang tercatat adalah ",
                         "hasil thinning dengan peluang ", fmt_num(f$q, 3), "; sisanya tercatat utuh."),
                  paste0("The hidden INAR(1) process is <em>X<sub>n</sub> = ", fmt_num(f$alpha, 3),
                         " o X<sub>n-1</sub> + W<sub>n</sub>(", fmt_num(f$lambda, 3), ")</em>. ",
                         "With probability ", fmt_num(f$omega, 3), ", the recorded value is thinned with ",
                         "probability ", fmt_num(f$q, 3), "; otherwise it is recorded exactly.")
                ))),
                p(HTML(tr(
                  lang,
                  paste0("Rata-rata tersembunyi yang diestimasi adalah <strong>",
                         fmt_num(f$mean_hidden, 2), " kasus/minggu</strong>, sedangkan rata-rata tercatat hanya ",
                         fmt_num(st$mean, 2), ". Artinya registry menangkap sekitar <strong>",
                         fmt_pct(f$coverage_pct, 1), "</strong> dari total kasus yang diestimasi."),
                  paste0("The estimated hidden mean is <strong>", fmt_num(f$mean_hidden, 2),
                         " cases/week</strong>, while the recorded mean is only ", fmt_num(st$mean, 2),
                         ". The registry therefore captures about <strong>", fmt_pct(f$coverage_pct, 1),
                         "</strong> of the estimated total.")
                ))),
                p(class = "muted", tr(
                  lang,
                  "Perhatikan: semua nilai nol yang tercatat direkonstruksi sebagai kasus yang tidak terlaporkan.",
                  "Note: every recorded zero is reconstructed as an unreported case."
                ))
              )
            } else {
              tagList(
                p(HTML(tr(
                  lang,
                  paste0("Model memakai kovariat populasi: lambda<sub>n</sub> = a x N<sub>n</sub> / 10<sup>7</sup>, ",
                         "dengan a = ", fmt_num(f$a, 3), ". Frekuensi under-reporting omega = ",
                         fmt_num(f$omega, 3), " dan intensitas q = ", fmt_num(f$q, 3), "."),
                  paste0("The model uses a population covariate: lambda<sub>n</sub> = a x N<sub>n</sub> / 10<sup>7</sup>, ",
                         "with a = ", fmt_num(f$a, 3), ". Under-reporting frequency omega = ",
                         fmt_num(f$omega, 3), " and intensity q = ", fmt_num(f$q, 3), ".")
                ))),
                p(HTML(tr(
                  lang,
                  paste0("Rata-rata tersembunyi sekitar <strong>", fmt_num(f$mean_hidden, 2),
                         " kasus/tahun</strong>; registry menangkap sekitar <strong>",
                         fmt_pct(f$coverage_pct, 1), "</strong>."),
                  paste0("The hidden mean is about <strong>", fmt_num(f$mean_hidden, 2),
                         " cases/year</strong>; the registry captures about <strong>",
                         fmt_pct(f$coverage_pct, 1), "</strong>.")
                ))),
                p(class = "muted", tr(
                  lang,
                  "Karena counts adalah turunan, angka ini adalah ilustrasi metodologi, bukan estimasi final untuk Kanada.",
                  "Because counts are derived, these numbers illustrate the methodology rather than provide a final Canadian estimate."
                ))
              )
            }
          )
        )
      ),
      bslib::layout_columns(
        col_widths = c(6, 6),
        plot_card(tr(lang, "ACF observasi", "Observed ACF"), ns("acf_obs"), height = "300px"),
        plot_card(tr(lang, "PACF observasi", "Observed PACF"), ns("pacf_obs"), height = "300px")
      ),
      bslib::layout_columns(
        col_widths = c(6, 6),
        plot_card(tr(lang, "ACF mid-pseudo-residual", "ACF of mid-pseudo-residuals"),
                  ns("acf_res"), height = "300px"),
        plot_card(tr(lang, "Distribusi residual", "Residual distribution"),
                  ns("hist_res"), height = "300px")
      ),
      plot_card(
        tr(lang, "Residual terhadap waktu", "Residuals over time"),
        ns("line_res"),
        tr(lang, "Jika model memadai, residual menyerupai white noise dan berada di dalam pita.",
           "If the model fits, residuals resemble white noise and stay within the band."),
        height = "300px"
      )
    )
  )
}

example_server <- function(id, d, kind, lang, verification) {
  shiny::moduleServer(id, function(input, output, session) {
    is_hpv <- kind == "hpv"
    output$series <- plotly::renderPlotly({
      if (is_hpv) plot_hpv_series(d, lang()) else plot_bot_series(d, lang())
    })
    output$acf_obs <- plotly::renderPlotly({
      if (is_hpv) {
        plot_acf(d$acf$observed, lang(), "ACF")
      } else {
        plotly::plotly_empty() |>
          plotly::layout(
            annotations = list(text = tr(lang(), "Tidak tersedia untuk seri non-stasioner",
                                         "Not available for a non-stationary series"),
                               showarrow = FALSE)
          )
      }
    })
    output$pacf_obs <- plotly::renderPlotly({
      if (is_hpv) {
        plot_pacf(d$acf$observed, lang())
      } else {
        plotly::plotly_empty() |>
          plotly::layout(
            annotations = list(text = tr(lang(), "Lihat catatan metodologi",
                                         "See the methodology note"),
                               showarrow = FALSE)
          )
      }
    })
    output$acf_res <- plotly::renderPlotly({
      plot_acf(d$acf$residual, lang(), "ACF")
    })
    output$hist_res <- plotly::renderPlotly({
      plot_residual_hist(d$residuals$values, lang())
    })
    output$line_res <- plotly::renderPlotly({
      yrs <- if (is_hpv) d$series$year + (d$series$week - 1) / 52 else d$series$year
      plot_residual_line(d$residuals$values, yrs, lang())
    })

    output$params <- DT::renderDT({
      f <- d$fit
      if (is_hpv) {
        labels <- c(tr(lang(), "alpha (autoregresi)", "alpha (autoregression)"),
                    tr(lang(), "lambda (inovasi)", "lambda (innovation)"),
                    tr(lang(), "omega (frekuensi)", "omega (frequency)"),
                    tr(lang(), "q (intensitas)", "q (intensity)"))
        ids <- c("hpv.mle.alpha", "hpv.mle.lambda", "hpv.mle.omega", "hpv.mle.q")
        est <- c(f$alpha, f$lambda, f$omega, f$q)
        se <- c(f$se$alpha, f$se$lambda, f$se$omega, f$se$q)
      } else {
        labels <- c(tr(lang(), "alpha (autoregresi)", "alpha (autoregression)"),
                    "a (kovariat populasi)", "a (population covariate)",
                    tr(lang(), "omega (frekuensi)", "omega (frequency)"),
                    tr(lang(), "q (intensitas)", "q (intensity)"))
        if (identical(lang(), "en")) labels <- c("alpha (autoregression)", "a (population covariate)",
                                                  "omega (frequency)", "q (intensity)")
        else labels <- c("alpha (autoregresi)", "a (kovariat populasi)",
                         "omega (frekuensi)", "q (intensitas)")
        ids <- c("bot.mle.alpha", "bot.mle.a", "bot.mle.omega", "bot.mle.q")
        est <- c(f$alpha, f$a, f$omega, f$q)
        se <- c(f$se$alpha, f$se$a, f$se$omega, f$se$q)
      }
      tab <- data.frame(
        Parameter = labels,
        Paper = vapply(ids, function(i) as.numeric(paper_value(i, list(verification = verification))), 0),
        Reconstructed = est,
        SE = se,
        Status = vapply(ids, function(i) verification_status(i, list(verification = verification)), ""),
        check.names = FALSE
      )
      tab$Paper <- round(tab$Paper, 3)
      tab$Reconstructed <- round(tab$Reconstructed, 3)
      tab$SE <- round(tab$SE, 3)
      DT::datatable(
        tab, rownames = FALSE, escape = FALSE,
        options = list(dom = "t", pageLength = 10, ordering = FALSE)
      ) |>
        DT::formatRound(columns = c("Paper", "Reconstructed", "SE"), digits = 3) |>
        DT::formatStyle(
          "Status",
          color = DT::styleEqual(
            c("PASS", "PASS_TOLERANCE", "ESTIMATED", "N/A", "FAIL"),
            c("#0f766e", "#0369a1", "#b45309", "#64748b", "#b91c1c")
          ),
          fontWeight = "bold"
        )
    })
  })
}
