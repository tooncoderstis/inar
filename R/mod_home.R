# Halaman ringkasan.

home_ui <- function(lang, data) {
  key <- data$summary$key
  vs <- data$verification$summary
  bslib::nav_panel(
    title = tr(lang, "Ringkasan", "Overview"),
    value = "home",
    div(
      class = "page-wrap",
      div(
        class = "hero",
        div(
          class = "hero-kicker",
          tr(lang, "LABORATORIUM STATISTIK", "STATISTICS LAB")
        ),
        h1(tr(
          lang, "Berapa banyak kasus yang tidak tercatat?",
          "How many cases go unrecorded?"
        )),
        p(tr(
          lang,
          paste0(
            "Rekonstruksi dan penjelasan model INAR(1)-hidden Markov chain untuk data under-reported, ",
            "berdasarkan Fernandez-Fontelo, Cabana, Puig & Morina (2016)."
          ),
          paste0(
            "A reconstruction and explainer of the INAR(1)-hidden Markov chain model for under-reported data, ",
            "based on Fernandez-Fontelo, Cabana, Puig & Morina (2016)."
          )
        )),
        div(
          class = "hero-actions",
          tags$a(
            class = "btn btn-primary", href = "?tab=lab",
            tr(lang, "Coba lab parameter", "Try the parameter lab")
          ),
          tags$a(
            class = "btn btn-outline", href = "?tab=verification",
            tr(lang, "Lihat verifikasi", "See verification")
          )
        )
      ),
      div(
        class = "kpi-grid",
        kpi_card(
          fmt_pct(key$hpv_coverage_pct, 1),
          tr(lang, "Cakupan HPV di Girona", "HPV reporting coverage in Girona"),
          tr(lang, "estimasi model", "model estimate"), "accent"
        ),
        kpi_card(
          fmt_pct(key$bot_coverage_pct, 1),
          tr(lang, "Cakupan Botulism Kanada", "Botulism reporting coverage in Canada"),
          tr(lang, "status perkiraan", "estimated"), "accent"
        ),
        kpi_card(
          paste0(vs$PASS + vs$PASS_TOLERANCE), tr(lang, "Metrik terverifikasi", "Verified metrics"),
          tr(lang, "PASS + PASS_TOLERANCE", "PASS + PASS_TOLERANCE")
        ),
        kpi_card(
          vs$ESTIMATED, tr(lang, "Metrik perkiraan", "Estimated metrics"),
          tr(lang, "menunggu data asli", "awaiting original data")
        )
      ),
      bslib::layout_columns(
        col_widths = c(4, 4, 4),
        bslib::card(
          bslib::card_header(tr(lang, "Masalah", "The problem")),
          bslib::card_body(
            p(tr(
              lang,
              paste0(
                "Data kesehatan masyarakat sering mencatat lebih sedikit kasus daripada yang sebenarnya. ",
                "Jika under-reporting diabaikan, model standar memberi kesimpulan yang bias."
              ),
              paste0(
                "Public health data often record fewer cases than actually occur. ",
                "Ignoring under-reporting biases standard models and conclusions."
              )
            ))
          )
        ),
        bslib::card(
          bslib::card_header(tr(lang, "Model", "The model")),
          bslib::card_body(
            p(tr(
              lang,
              paste0(
                "Proses tersembunyi X mengikuti INAR(1); yang kita lihat adalah Y, hasil thinning binomial ",
                "dengan peluang q dan frekuensi omega. Likelihood dihitung dengan forward algorithm; ",
                "deret tersembunyi direkonstruksi dengan Viterbi."
              ),
              paste0(
                "The hidden process X follows INAR(1); we observe Y, a binomial-thinned version with ",
                "probability q and frequency omega. The likelihood uses a forward algorithm; ",
                "the hidden series is reconstructed with Viterbi."
              )
            ))
          )
        ),
        bslib::card(
          bslib::card_header(tr(lang, "Bukti", "The evidence")),
          bslib::card_body(
            p(tr(
              lang,
              paste0(
                "Setiap angka paper ditampilkan berdampingan dengan hasil rekonstruksi, selisih, dan status. ",
                "Perbedaan optimizer dan keterbatasan data tidak disembunyikan."
              ),
              paste0(
                "Every paper number is shown next to its reconstruction, difference, and status. ",
                "Optimizer differences and data limitations are not hidden."
              )
            )),
            div(
              class = "badge-row",
              status_badge("PASS"), status_badge("PASS_TOLERANCE"),
              status_badge("ESTIMATED"), status_badge("N/A")
            )
          )
        )
      ),
      bslib::card(
        bslib::card_header(tr(lang, "Temuan utama", "Key findings")),
        bslib::card_body(
          tags$ul(
            class = "finding-list",
            tags$li(HTML(tr(
              lang,
              paste0(
                "<strong>HPV:</strong> rata-rata tercatat ", fmt_num(key$hpv_mean_observed, 2),
                " kasus/minggu, estimasi tersembunyi ", fmt_num(key$hpv_mean_hidden, 2),
                " (cakupan ", fmt_pct(key$hpv_coverage_pct, 1), "). Semua nol tercatat direkonstruksi sebagai kasus tak terlaporkan."
              ),
              paste0(
                "<strong>HPV:</strong> observed mean ", fmt_num(key$hpv_mean_observed, 2),
                " cases/week, hidden estimate ", fmt_num(key$hpv_mean_hidden, 2),
                " (coverage ", fmt_pct(key$hpv_coverage_pct, 1), "). Every recorded zero is reconstructed as an unreported case."
              )
            ))),
            tags$li(HTML(tr(
              lang,
              paste0(
                "<strong>Botulism:</strong> cakupan sekitar ", fmt_pct(key$bot_coverage_pct, 1),
                "; status MLE <em>ESTIMATED</em> karena counts diturunkan dari rate."
              ),
              paste0(
                "<strong>Botulism:</strong> coverage about ", fmt_pct(key$bot_coverage_pct, 1),
                "; MLE is <em>ESTIMATED</em> because counts are derived from rates."
              )
            ))),
            tags$li(HTML(tr(
              lang,
              "<strong>Mesothelioma:</strong> data HSE yang tersedia berbeda dari seri paper, jadi ditampilkan sebagai ekstensi, bukan reproduksi.",
              "<strong>Mesothelioma:</strong> the available HSE data differ from the paper's series, so it is shown as an extension, not a reproduction."
            )))
          )
        )
      )
    )
  )
}
