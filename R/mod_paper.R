# Modul PDF: gerbang password dan viewer inline (PDF.js).

paper_gate_ui <- function(ns, lang) {
  bslib::card(
    class = "paper-gate",
    bslib::card_body(
      div(class = "lock-icon", "\U0001F512"),
      h3(tr(lang, "Dokumen terkunci", "Locked document")),
      p(tr(
        lang,
        "Masukkan password untuk membaca paper. PDF ditampilkan inline dan tidak disediakan sebagai unduhan.",
        "Enter the password to read the paper. The PDF is displayed inline and is not offered as a download."
      )),
      shiny::passwordInput(ns("password"), tr(lang, "Password", "Password"),
        placeholder = tr(lang, "Password akses", "Access password")
      ),
      shiny::actionButton(ns("unlock"), tr(lang, "Buka dokumen", "Unlock document"),
        class = "btn-primary"
      ),
      shiny::uiOutput(ns("message"))
    )
  )
}

paper_reader_ui <- function(lang) {
  bslib::card(
    class = "paper-reader",
    bslib::card_header(
      div(
        class = "pdf-toolbar",
        tags$button(
          type = "button", class = "btn btn-sm btn-outline",
          onclick = "pdfPrev()", "\u2039"
        ),
        tags$span(id = "pdf-page", class = "pdf-page", "- / -"),
        tags$button(
          type = "button", class = "btn btn-sm btn-outline",
          onclick = "pdfNext()", "\u203a"
        ),
        tags$button(
          type = "button", class = "btn btn-sm btn-outline",
          onclick = "pdfZoom(-0.2)", "\u2212"
        ),
        tags$button(
          type = "button", class = "btn btn-sm btn-outline",
          onclick = "pdfZoom(0.2)", "+"
        )
      ),
      div(
        class = "pdf-hint",
        tr(
          lang, "Gunakan tombol untuk berpindah halaman atau memperbesar.",
          "Use the buttons to change pages or zoom."
        )
      )
    ),
    bslib::card_body(
      div(
        class = "pdf-stage",
        tags$canvas(id = "pdf-canvas"),
        div(
          id = "pdf-loading", class = "pdf-loading",
          tr(lang, "Memuat dokumen...", "Loading document...")
        )
      )
    )
  )
}

paper_ui <- function(id, lang) {
  ns <- shiny::NS(id)
  bslib::nav_panel(
    title = tr(lang, "Paper", "Paper"),
    value = "paper",
    div(
      class = "page-wrap",
      section_heading(
        tr(lang, "Paper penelitian", "Research paper"),
        tr(
          lang,
          "Fernandez-Fontelo, Cabana, Puig & Morina (2016), Statistics in Medicine 35:4875-4890.",
          "Fernandez-Fontelo, Cabana, Puig & Morina (2016), Statistics in Medicine 35:4875-4890."
        )
      ),
      shiny::uiOutput(ns("gate")),
      p(
        class = "muted small",
        tr(
          lang,
          "Dokumen berhak cipta; hanya untuk penggunaan terbatas. Browser tetap dapat menyimpan salinan setelah ditampilkan.",
          "Copyrighted document; limited use only. The browser may still save a copy once displayed."
        )
      )
    )
  )
}

paper_server <- function(id, lang, root = ".") {
  shiny::moduleServer(id, function(input, output, session) {
    unlocked <- shiny::reactiveVal(FALSE)
    message_text <- shiny::reactiveVal("")
    attempts <- shiny::reactiveVal(numeric(0))
    state <- new.env(parent = emptyenv())
    state$unlocked <- FALSE
    available <- paper_available(root)

    pdf_url <- NULL
    if (available) {
      pdf_raw <- readBin(paper_file(root), "raw", n = file.info(paper_file(root))$size)
      pdf_url <- session$registerDataObj(
        "paper-pdf", pdf_raw,
        function(data, req) {
          if (!isTRUE(state$unlocked)) {
            return(list(
              status = 403L,
              headers = list("content-type" = "text/plain; charset=utf-8"),
              body = charToRaw("Forbidden")
            ))
          }
          list(
            status = 200L,
            headers = list(
              "content-type" = "application/pdf",
              "content-disposition" = "inline; filename=\"inar-paper.pdf\"",
              "cache-control" = "no-store, no-cache, must-revalidate",
              "pragma" = "no-cache",
              "x-robots-tag" = "noindex, nofollow"
            ),
            body = data
          )
        }
      )
    }

    output$gate <- shiny::renderUI({
      if (!available) {
        return(note_box(
          tr(
            lang(),
            "PDF tidak ditemukan di image ini. Hubungi administrator.",
            "The PDF is not present in this image. Contact the administrator."
          ),
          "warn"
        ))
      }
      if (isTRUE(unlocked())) paper_reader_ui(lang()) else paper_gate_ui(session$ns, lang())
    })

    shiny::observeEvent(input$unlock, {
      cfg <- paper_config()
      if (!cfg$configured) {
        message_text(tr(
          lang(), "Password belum dikonfigurasi di server.",
          "The password is not configured on the server."
        ))
        return()
      }
      now <- Sys.time()
      old <- attempts()
      old <- old[difftime(now, old, units = "secs") < 300]
      if (length(old) >= 5) {
        message_text(tr(
          lang(), "Terlalu banyak percobaan. Coba lagi dalam 5 menit.",
          "Too many attempts. Try again in 5 minutes."
        ))
        attempts(old)
        return()
      }
      pw <- input$password
      if (is.null(pw) || !nzchar(pw)) {
        message_text(tr(lang(), "Masukkan password.", "Enter the password."))
        return()
      }
      if (check_paper_password(pw)) {
        unlocked(TRUE)
        state$unlocked <- TRUE
        message_text("")
        attempts(numeric(0))
        later::later(function() {
          if (!is.null(pdf_url)) {
            session$sendCustomMessage("loadPdf", list(url = pdf_url))
          }
        }, delay = 0.4)
      } else {
        attempts(c(old, now))
        remaining <- max(0, 5 - length(c(old, now)))
        message_text(tr(
          lang(),
          paste0("Password salah. Sisa percobaan: ", remaining, "."),
          paste0("Incorrect password. Attempts remaining: ", remaining, ".")
        ))
      }
    })

    output$message <- shiny::renderUI({
      txt <- message_text()
      if (!nzchar(txt)) {
        return(NULL)
      }
      div(class = "form-error", txt)
    })
  })
}
