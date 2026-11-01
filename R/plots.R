# Grafik plotly.

plotly_base <- function(p, lang) {
  p |>
    plotly::layout(
      font = list(family = "Inter, system-ui, sans-serif", size = 12),
      paper_bgcolor = "rgba(0,0,0,0)",
      plot_bgcolor = "rgba(0,0,0,0)",
      hovermode = "x unified",
      margin = list(l = 50, r = 20, t = 10, b = 50),
      legend = list(orientation = "h", y = -0.2)
    ) |>
    plotly::config(displayModeBar = FALSE, responsive = TRUE)
}

plot_hpv_series <- function(d, lang) {
  s <- d$series
  x <- s$year + (s$week - 1) / 52
  lab <- paste0(s$year, " W", s$week)
  plotly::plot_ly() |>
    plotly::add_trace(
      x = x, y = s$observed, type = "scatter", mode = "lines",
      name = tr(lang, "Tercatat", "Observed"),
      line = list(color = "#94a3b8", width = 1.2),
      hovertemplate = paste0("%{text}<br>", tr(lang, "Tercatat", "Observed"), ": %{y}<extra></extra>"),
      text = lab
    ) |>
    plotly::add_trace(
      x = x, y = s$hidden, type = "scatter", mode = "lines",
      name = tr(lang, "Tersembunyi (Viterbi)", "Hidden (Viterbi)"),
      line = list(color = "#0f766e", width = 1.6),
      hovertemplate = paste0("%{text}<br>", tr(lang, "Tersembunyi", "Hidden"), ": %{y}<extra></extra>"),
      text = lab
    ) |>
    plotly::layout(
      xaxis = list(title = tr(lang, "Tahun", "Year"), tickformat = "d"),
      yaxis = list(title = tr(lang, "Kasus per minggu", "Cases per week"))
    ) |>
    plotly_base(lang)
}

plot_bot_series <- function(d, lang) {
  s <- d$series
  plotly::plot_ly() |>
    plotly::add_trace(
      x = s$year, y = s$observed, type = "scatter", mode = "lines+markers",
      name = tr(lang, "Tercatat", "Observed"),
      line = list(color = "#94a3b8", width = 1.2),
      marker = list(size = 4),
      hovertemplate = paste0("%{x}<br>", tr(lang, "Tercatat", "Observed"), ": %{y}<extra></extra>")
    ) |>
    plotly::add_trace(
      x = s$year, y = s$hidden, type = "scatter", mode = "lines",
      name = tr(lang, "Tersembunyi (Viterbi)", "Hidden (Viterbi)"),
      line = list(color = "#0f766e", width = 2),
      hovertemplate = paste0("%{x}<br>", tr(lang, "Tersembunyi", "Hidden"), ": %{y}<extra></extra>")
    ) |>
    plotly::add_trace(
      x = s$year, y = s$population / 1e6, type = "scatter", mode = "lines",
      name = tr(lang, "Populasi (juta)", "Population (millions)"),
      yaxis = "y2",
      line = list(color = "#f59e0b", width = 1, dash = "dot"),
      hovertemplate = paste0("%{x}<br>", tr(lang, "Populasi", "Population"), ": %{y:.1f} ", tr(lang, "juta", "M"), "<extra></extra>")
    ) |>
    plotly::layout(
      xaxis = list(title = tr(lang, "Tahun", "Year")),
      yaxis = list(title = tr(lang, "Kasus per tahun", "Cases per year")),
      yaxis2 = list(
        overlaying = "y", side = "right", showgrid = FALSE,
        title = tr(lang, "Populasi (juta)", "Population (millions)")
      )
    ) |>
    plotly_base(lang)
}

plot_meso_series <- function(d, lang) {
  s <- d$series
  plotly::plot_ly() |>
    plotly::add_trace(
      x = s$year, y = s$observed, type = "bar",
      name = tr(lang, "Kematian", "Deaths"),
      marker = list(color = "#0f766e"),
      hovertemplate = paste0("%{x}<br>", tr(lang, "Kematian", "Deaths"), ": %{y}<extra></extra>")
    ) |>
    plotly::add_trace(
      x = s$year, y = s$rate_per_100k, type = "scatter", mode = "lines",
      name = tr(lang, "Rate per 100.000", "Rate per 100,000"),
      yaxis = "y2",
      line = list(color = "#f59e0b", width = 2),
      hovertemplate = paste0("%{x}<br>Rate: %{y:.2f}<extra></extra>")
    ) |>
    plotly::layout(
      xaxis = list(title = tr(lang, "Tahun", "Year")),
      yaxis = list(title = tr(lang, "Kematian", "Deaths")),
      yaxis2 = list(
        overlaying = "y", side = "right", showgrid = FALSE,
        title = "Rate / 100.000"
      ),
      bargap = 0.2
    ) |>
    plotly_base(lang)
}

plot_acf <- function(a, lang, title = "ACF") {
  keep <- a$lag > 0
  plotly::plot_ly(
    x = a$lag[keep], y = a$acf[keep], type = "bar",
    marker = list(color = "#0f766e"),
    hovertemplate = "Lag %{x}<br>ACF %{y:.3f}<extra></extra>"
  ) |>
    plotly::add_segments(
      x = 0, xend = max(a$lag), y = a$band, yend = a$band,
      line = list(color = "#f59e0b", dash = "dot", width = 1),
      inherit = FALSE, showlegend = FALSE, hoverinfo = "none"
    ) |>
    plotly::add_segments(
      x = 0, xend = max(a$lag), y = -a$band, yend = -a$band,
      line = list(color = "#f59e0b", dash = "dot", width = 1),
      inherit = FALSE, showlegend = FALSE, hoverinfo = "none"
    ) |>
    plotly::layout(
      xaxis = list(title = "Lag"),
      yaxis = list(title = title, range = c(-0.3, 0.3)),
      showlegend = FALSE,
      margin = list(l = 50, r = 10, t = 10, b = 40)
    ) |>
    plotly_base(lang) |>
    plotly::layout(showlegend = FALSE, hovermode = "closest")
}

plot_pacf <- function(a, lang) {
  keep <- a$lag > 0 & !is.na(a$pacf)
  plotly::plot_ly(
    x = a$lag[keep], y = a$pacf[keep], type = "bar",
    marker = list(color = "#334155"),
    hovertemplate = "Lag %{x}<br>PACF %{y:.3f}<extra></extra>"
  ) |>
    plotly::add_segments(
      x = 0, xend = max(a$lag), y = a$band, yend = a$band,
      line = list(color = "#f59e0b", dash = "dot", width = 1),
      inherit = FALSE, showlegend = FALSE, hoverinfo = "none"
    ) |>
    plotly::add_segments(
      x = 0, xend = max(a$lag), y = -a$band, yend = -a$band,
      line = list(color = "#f59e0b", dash = "dot", width = 1),
      inherit = FALSE, showlegend = FALSE, hoverinfo = "none"
    ) |>
    plotly::layout(
      xaxis = list(title = "Lag"),
      yaxis = list(title = "PACF", range = c(-0.3, 0.3)),
      showlegend = FALSE,
      margin = list(l = 50, r = 10, t = 10, b = 40)
    ) |>
    plotly_base(lang) |>
    plotly::layout(showlegend = FALSE, hovermode = "closest")
}

plot_residual_hist <- function(values, lang) {
  plotly::plot_ly(
    x = values, type = "histogram", nbinsx = 20,
    marker = list(color = "#0f766e", line = list(color = "#ffffff", width = 1)),
    hovertemplate = "%{x}<br>n=%{y}<extra></extra>"
  ) |>
    plotly::layout(
      xaxis = list(title = tr(lang, "Mid-pseudo-residual", "Mid-pseudo-residual")),
      yaxis = list(title = tr(lang, "Frekuensi", "Frequency")),
      bargap = 0.05
    ) |>
    plotly_base(lang) |>
    plotly::layout(showlegend = FALSE)
}

plot_residual_line <- function(values, years, lang) {
  n <- length(values)
  x <- if (!is.null(years) && length(years) == n) years else seq_len(n)
  plotly::plot_ly(
    x = x, y = values, type = "scatter", mode = "markers+lines",
    marker = list(color = "#0f766e", size = 5),
    line = list(color = "#0f766e", width = 1),
    hovertemplate = "%{x}<br>z = %{y:.2f}<extra></extra>"
  ) |>
    plotly::add_segments(
      x = min(x), xend = max(x), y = 0, yend = 0,
      line = list(color = "#94a3b8", width = 1), inherit = FALSE,
      showlegend = FALSE, hoverinfo = "none"
    ) |>
    plotly::layout(
      xaxis = list(title = tr(lang, "Tahun", "Year")),
      yaxis = list(title = "Mid-pseudo-residual"),
      showlegend = FALSE
    ) |>
    plotly_base(lang) |>
    plotly::layout(showlegend = FALSE)
}

plot_lab <- function(y, hidden, x, lang, ylab) {
  plotly::plot_ly() |>
    plotly::add_trace(
      x = x, y = y, type = "scatter", mode = "lines",
      name = tr(lang, "Tercatat", "Observed"),
      line = list(color = "#94a3b8", width = 1.2)
    ) |>
    plotly::add_trace(
      x = x, y = hidden, type = "scatter", mode = "lines",
      name = tr(lang, "Rekonstruksi", "Reconstruction"),
      line = list(color = "#b45309", width = 1.8)
    ) |>
    plotly::layout(
      xaxis = list(title = tr(lang, "Indeks waktu", "Time index")),
      yaxis = list(title = ylab)
    ) |>
    plotly_base(lang)
}
