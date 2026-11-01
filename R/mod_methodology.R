# Halaman metodologi (markdown bilingual).

methodology_ui <- function(lang) {
  path <- file.path("content", lang, "methodology.md")
  body <- if (file.exists(path)) {
    HTML(shiny::markdown(paste(readLines(path, warn = FALSE, encoding = "UTF-8"),
      collapse = "\n"
    )))
  } else {
    p("Konten metodologi belum tersedia.")
  }
  bslib::nav_panel(
    title = tr(lang, "Metodologi", "Methodology"),
    value = "methodology",
    div(class = "page-wrap prose methodology", body)
  )
}

about_ui <- function(lang, data) {
  bslib::nav_panel(
    title = tr(lang, "Tentang", "About"),
    value = "about",
    div(
      class = "page-wrap prose",
      h1(tr(lang, "Tentang proyek", "About the project")),
      p(tr(
        lang,
        paste0(
          "INAR Under-reporting Lab merekonstruksi dan menjelaskan metode INAR(1)-hidden Markov chain ",
          "untuk data hitungan yang under-reported. Aplikasi ini dibuat untuk pengguna data, stakeholder, ",
          "dan pembelajar."
        ),
        paste0(
          "INAR Under-reporting Lab reconstructs and explains the INAR(1)-hidden Markov chain method ",
          "for under-reported count data. It is built for data users, stakeholders, and learners."
        )
      )),
      h2(tr(lang, "Sitasi", "Citation")),
      tags$blockquote(
        "Fernandez-Fontelo, A., Cabana, A., Puig, P., & Morina, D. (2016). ",
        "Under-reported data analysis with INAR-hidden Markov chains. ",
        tags$em("Statistics in Medicine"), " 35(26), 4875-4890. ",
        tags$a(href = "https://doi.org/10.1002/sim.7026", "doi:10.1002/sim.7026")
      ),
      h2(tr(lang, "Sumber data", "Data sources")),
      tags$ul(
        tags$li("HPV: Generalitat de Catalunya (weekly cases, Girona)."),
        tags$li("Botulism: Public Health Agency of Canada, CNDSS notifiable disease charts."),
        tags$li("Mesothelioma: UK Health and Safety Executive, MESO01-MESO03."),
        tags$li("Population: World Bank SP.POP.TOTL.")
      ),
      h2(tr(lang, "Keterbatasan", "Limitations")),
      tags$ul(
        tags$li(tr(
          lang,
          "MLE HPV berbeda <= 2,5% dari paper karena toleransi optimizer; likelihood hasil rekonstruksi lebih tinggi.",
          "The HPV MLE differs by <= 2.5% from the paper because of optimizer tolerance; the reconstructed likelihood is higher."
        )),
        tags$li(tr(
          lang,
          "Botulism memakai counts turunan; MLE berstatus ESTIMATED.",
          "Botulism uses derived counts; the MLE is ESTIMATED."
        )),
        tags$li(tr(
          lang,
          "Mesothelioma adalah ekstensi, bukan reproduksi seri ONS paper.",
          "Mesothelioma is an extension, not a reproduction of the paper's ONS series."
        )),
        tags$li(tr(
          lang,
          "Model mengasumsikan under-reporting permanen dan stasioneritas (kecuali kovariat).",
          "The model assumes permanent under-reporting and stationarity (except for covariates)."
        ))
      ),
      h2(tr(lang, "Lisensi", "License")),
      p(tr(
        lang,
        "Kode proyek: MIT. Paper dan PDF tetap milik Wiley; disajikan untuk penggunaan terbatas.",
        "Project code: MIT. The paper and PDF remain Wiley's property; provided for limited use."
      ))
    )
  )
}
