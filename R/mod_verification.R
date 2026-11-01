# Modul halaman verifikasi.

verification_ui <- function(id, lang, data) {
  ns <- shiny::NS(id)
  vs <- data$verification$summary
  bslib::nav_panel(
    title = tr(lang, "Verifikasi", "Verification"),
    value = "verification",
    div(
      class = "page-wrap",
      section_heading(
        tr(lang, "Verifikasi angka paper", "Verification of paper numbers"),
        tr(
          lang,
          "Setiap angka dibandingkan dengan hasil rekonstruksi. Status dihitung otomatis oleh pipeline R.",
          "Each number is compared with the reconstruction. Status is computed automatically by the R pipeline."
        )
      ),
      div(
        class = "kpi-grid",
        kpi_card(vs$PASS, "PASS", tr(lang, "sama persis", "exact"), "accent"),
        kpi_card(vs$PASS_TOLERANCE, "PASS_TOLERANCE", tr(lang, "dalam toleransi", "within tolerance")),
        kpi_card(vs$ESTIMATED, "ESTIMATED", tr(lang, "data asli tidak tersedia", "original data unavailable")),
        kpi_card(vs$`N/A`, "N/A", tr(lang, "ekstensi", "extension")),
        kpi_card(vs$FAIL, "FAIL", tr(lang, "harus nol", "must be zero"), "danger")
      ),
      bslib::card(
        bslib::card_header(tr(lang, "Tabel verifikasi", "Verification table")),
        bslib::card_body(DT::DTOutput(ns("table")))
      ),
      bslib::layout_columns(
        col_widths = c(7, 5),
        bslib::card(
          bslib::card_header(tr(lang, "Arti status", "Status meanings")),
          bslib::card_body(
            tags$ul(
              class = "status-legend",
              tags$li(status_badge("PASS"), tr(lang, "angka sama persis.", "the number matches exactly.")),
              tags$li(status_badge("PASS_TOLERANCE"), tr(lang, "selisih berada dalam toleransi yang disepakati.", "the difference is within the agreed tolerance.")),
              tags$li(status_badge("ESTIMATED"), tr(lang, "angka paper tidak dapat direproduksi karena data asli tidak tersedia.", "the paper number cannot be reproduced because the original data are unavailable.")),
              tags$li(status_badge("N/A"), tr(lang, "bukan bagian reproduksi (ekstensi).", "not part of the reproduction (extension).")),
              tags$li(status_badge("FAIL"), tr(lang, "di luar toleransi; CI gagal.", "outside tolerance; CI fails."))
            )
          )
        ),
        bslib::card(
          bslib::card_header(tr(lang, "Catatan optimizer", "Optimizer note")),
          bslib::card_body(
            p(tr(
              lang,
              paste0(
                "MLE HPV direkonstruksi dengan nlm dan fungsi likelihood yang sama seperti kode suplemen. ",
                "Dengan orientasi matriks transisi yang benar (kolom = state berikutnya), nlm mencapai ",
                "titik optimum yang sama dengan paper pada 3 desimal untuk alpha, lambda, omega, q, dan SE."
              ),
              paste0(
                "HPV MLE is reconstructed with nlm and the same likelihood as the supplementary code. ",
                "With the corrected transition-matrix orientation (columns = next state), nlm reaches ",
                "the same optimum as the paper at three decimals for alpha, lambda, omega, q, and SE."
              )
            )),
            div(
              class = "download-row",
              shiny::downloadButton(ns("download_json"), tr(lang, "Unduh JSON", "Download JSON"),
                class = "btn-outline"
              ),
              shiny::downloadButton(ns("download_csv"), tr(lang, "Unduh CSV", "Download CSV"),
                class = "btn-outline"
              )
            )
          )
        )
      )
    )
  )
}

verification_server <- function(id, data, lang) {
  shiny::moduleServer(id, function(input, output, session) {
    output$table <- DT::renderDT({
      e <- data$verification$entries
      fmt_cell <- function(x) {
        if (is.list(x)) x <- x[[1]]
        if (is.character(x) && grepl("^-?[0-9.]+([eE][-+]?[0-9]+)?$", x)) {
          x <- suppressWarnings(as.numeric(x))
        }
        if (is.numeric(x)) {
          return(formatC(x, digits = 5, format = "fg"))
        }
        as.character(x)
      }
      labels_en <- c(
        "hpv.n" = "Observations", "hpv.mean" = "Mean", "hpv.var" = "Variance",
        "hpv.dispersion" = "Dispersion index", "hpv.acf1" = "Observed ACF(1)",
        "hpv.mix.lambda" = "Mixture: lambda1/(1-alpha)",
        "hpv.mix.qlambda" = "Mixture: q*lambda1/(1-alpha)",
        "hpv.mix.omega" = "Mixture: omega", "hpv.mix.q" = "Mixture: q",
        "hpv.naive.alpha1" = "Naive: alpha1", "hpv.naive.lambda1" = "Naive: lambda1",
        "hpv.naive.alpha2" = "Naive: alpha2", "hpv.naive.lambda2" = "Naive: lambda2",
        "hpv.aic.poisson" = "Poisson AIC", "hpv.aic.mixture" = "Two-Poisson mixture AIC",
        "hpv.mle.alpha" = "MLE alpha", "hpv.mle.lambda" = "MLE lambda",
        "hpv.mle.omega" = "MLE omega", "hpv.mle.q" = "MLE q",
        "hpv.mle.se_alpha" = "SE alpha", "hpv.mle.se_lambda" = "SE lambda",
        "hpv.mle.se_omega" = "SE omega", "hpv.mle.se_q" = "SE q",
        "hpv.coverage" = "Reporting coverage (%)",
        "bot.n" = "Observations", "bot.mean" = "Mean", "bot.var" = "Variance",
        "bot.median" = "Median", "bot.min" = "Minimum", "bot.max" = "Maximum",
        "bot.mle.alpha" = "MLE alpha", "bot.mle.a" = "MLE a",
        "bot.mle.omega" = "MLE omega", "bot.mle.q" = "MLE q", "bot.aic" = "AIC",
        "meso.n" = "Observations", "meso.mean" = "Mean (paper)",
        "meso.var" = "Variance (paper)", "meso.range" = "Range (paper)"
      )
      notes_en <- c(
        "hpv.mean" = "The paper rounds to 2 decimals.",
        "hpv.mix.lambda" = "Two-Poisson EM (equivalent to poisregmixEM), larger component.",
        "hpv.mle.alpha" = "nlm reproduces the paper value at 3 decimals.",
        "bot.mean" = "Counts derived from rate x population.",
        "bot.mle.alpha" = "The original count file (bot.csv) is unavailable; shown as an estimate.",
        "meso.n" = "Extension using the HSE series; not the paper ONS series.",
        "meso.mean" = "The available HSE series differs from the paper series."
      )
      metric_label <- e$metric
      note_text <- e$note
      if (identical(lang(), "en")) {
        hit <- labels_en[e$id]
        metric_label <- ifelse(is.na(hit), e$metric, unname(hit))
        hitn <- notes_en[e$id]
        note_text <- ifelse(is.na(hitn), e$note, unname(hitn))
      }
      tab <- data.frame(
        Example = e$example,
        Metric = metric_label,
        Paper = vapply(seq_len(nrow(e)), function(i) fmt_cell(e$paper[[i]]), ""),
        Reproduced = vapply(seq_len(nrow(e)), function(i) fmt_cell(e$reproduced[[i]]), ""),
        Status = e$status,
        Note = note_text,
        check.names = FALSE,
        stringsAsFactors = FALSE
      )
      DT::datatable(
        tab,
        rownames = FALSE, escape = FALSE,
        options = list(pageLength = 15, dom = "tp", order = list(list(0, "asc")))
      ) |>
        DT::formatStyle(
          "Status",
          color = DT::styleEqual(
            c("PASS", "PASS_TOLERANCE", "ESTIMATED", "N/A", "FAIL"),
            c("#0f766e", "#0369a1", "#b45309", "#64748b", "#b91c1c")
          ),
          fontWeight = "bold"
        )
    })
    output$download_json <- shiny::downloadHandler(
      filename = function() "inar-verification.json",
      content = function(file) {
        file.copy(file.path("verification", "report.json"), file)
      }
    )
    output$download_csv <- shiny::downloadHandler(
      filename = function() "inar-verification.csv",
      content = function(file) {
        e <- data$verification$entries
        utils::write.csv(e, file, row.names = FALSE)
      }
    )
  })
}
