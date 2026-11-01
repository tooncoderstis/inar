# Helper UI dan terjemahan ringan (ID/EN).

tr <- function(lang, id, en) {
  if (identical(lang, "en")) en else id
}

kpi_card <- function(value, label, sub = NULL, tone = "primary") {
  bslib::card(
    class = paste0("kpi kpi-", tone),
    bslib::card_body(
      div(class = "kpi-value", value),
      div(class = "kpi-label", label),
      if (!is.null(sub)) div(class = "kpi-sub", sub)
    )
  )
}

status_badge <- function(status) {
  cls <- switch(status,
    PASS = "badge-pass",
    PASS_TOLERANCE = "badge-tolerance",
    ESTIMATED = "badge-estimated",
    `N/A` = "badge-na",
    FAIL = "badge-fail",
    "badge-na"
  )
  htmltools::tags$span(class = paste("status-badge", cls), status)
}

note_box <- function(text, type = "info") {
  div(class = paste0("note-box note-", type), HTML(text))
}

section_heading <- function(title, sub = NULL) {
  div(
    class = "section-heading",
    h2(title),
    if (!is.null(sub)) p(sub)
  )
}

plot_card <- function(title, plot, sub = NULL, height = "420px") {
  bslib::card(
    bslib::card_header(
      div(class = "card-title", title),
      if (!is.null(sub)) div(class = "card-sub", sub)
    ),
    bslib::card_body(plotly::plotlyOutput(plot, height = height))
  )
}

fmt_num <- function(x, digits = 3) {
  if (is.null(x) || length(x) == 0 || is.na(x)) return("-")
  formatC(as.numeric(x), digits = digits, format = "f")
}

fmt_pct <- function(x, digits = 1) {
  paste0(formatC(as.numeric(x), digits = digits, format = "f"), "%")
}

paper_value <- function(id, data) {
  e <- data$verification$entries
  row <- e[e$id == id, , drop = FALSE]
  if (nrow(row) == 0) return(NA)
  row$paper[1]
}

verification_status <- function(id, data) {
  e <- data$verification$entries
  row <- e[e$id == id, , drop = FALSE]
  if (nrow(row) == 0) return(NA_character_)
  row$status[1]
}
