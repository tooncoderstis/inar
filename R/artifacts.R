# Penulisan artefak JSON/CSV untuk aplikasi.

write_json <- function(x, path) {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  jsonlite::write_json(x, path, auto_unbox = TRUE, pretty = TRUE, digits = NA,
                       na = "null")
}

acf_pacf <- function(x, lag.max = 40) {
  x <- stats::na.omit(as.numeric(x))
  a <- stats::acf(x, plot = FALSE, lag.max = lag.max)
  p <- stats::pacf(x, plot = FALSE, lag.max = lag.max)
  list(
    lag = as.integer(a$lag[, 1, 1]),
    acf = as.numeric(a$acf[, 1, 1]),
    pacf = c(NA, as.numeric(p$acf[, 1, 1])),
    band = 2 / sqrt(a$n.used),
    n_used = a$n.used
  )
}

series_frame <- function(years, observed, hidden, extra = list()) {
  out <- data.frame(year = years, observed = observed, hidden = hidden)
  for (nm in names(extra)) out[[nm]] <- extra[[nm]]
  out
}

hpv_payload <- function(y, years, weeks, stats, fit, naive, mixture, poisson,
                        hidden, acfp, resid) {
  list(
    id = "hpv",
    title = list(
      id = "HPV di Girona (2010-2014)",
      en = "HPV in Girona (2010-2014)"
    ),
    subtitle = list(
      id = "260 observasi mingguan; 0-6 kasus per minggu",
      en = "260 weekly observations; 0-6 cases per week"
    ),
    stats = stats,
    fit = fit,
    naive = naive,
    mixture = mixture,
    poisson = poisson,
    series = series_frame(years, y, hidden, list(week = weeks)),
    acf = acfp,
    residuals = list(
      values = resid$mid,
      u_minus = resid$u_minus,
      u_plus = resid$u_plus,
      mean = mean(resid$mid, na.rm = TRUE),
      sd = stats::sd(resid$mid, na.rm = TRUE),
      max_abs_acf = max(abs(acfp$residual$acf[-1]), na.rm = TRUE)
    ),
    zeros = list(
      n = sum(y == 0),
      hidden_mean = mean(hidden[y == 0]),
      hidden_min = min(hidden[y == 0]),
      hidden_max = max(hidden[y == 0])
    ),
    meta = list(
      source = "Generalitat de Catalunya, weekly HPV cases (Girona)",
      raw = "data/raw/hpv_catalonia_weekly.csv",
      processed = "data/processed/hpv_girona.csv",
      note = "Minggu 53 dibuang; tahun 2010-2014."
    )
  )
}

bot_payload <- function(d, stats, fit, hidden, acfp, resid) {
  list(
    id = "botulism",
    title = list(
      id = "Botulism di Kanada (1970-2013)",
      en = "Botulism in Canada (1970-2013)"
    ),
    subtitle = list(
      id = "44 observasi tahunan; counts diturunkan dari rate x populasi",
      en = "44 annual observations; counts derived from rate x population"
    ),
    stats = stats,
    fit = fit,
    series = series_frame(
      d$year, d$cases, hidden,
      list(population = d$population, rate_per_100k = d$rate_per_100k)
    ),
    acf = acfp,
    residuals = list(
      values = resid$mid,
      u_minus = resid$u_minus,
      u_plus = resid$u_plus,
      mean = mean(resid$mid, na.rm = TRUE),
      sd = stats::sd(resid$mid, na.rm = TRUE),
      max_abs_acf = max(abs(acfp$residual$acf[-1]), na.rm = TRUE)
    ),
    meta = list(
      source = "Public Health Agency of Canada (CNDSS), rate per 100,000",
      raw = "data/raw/botulisme.xlsx",
      processed = "data/processed/botulism_canada.csv",
      note = "Counts = round(rate * population / 100000); 2010 dikoreksi menjadi 2 mengikuti skrip paper."
    )
  )
}

meso_payload <- function(d, stats) {
  list(
    id = "mesothelioma",
    title = list(
      id = "Mesothelioma di Britania Raya (1968-2013)",
      en = "Mesothelioma in Great Britain (1968-2013)"
    ),
    subtitle = list(
      id = "Ekstensi data HSE - bukan reproduksi seri ONS paper",
      en = "HSE data extension - not a reproduction of the paper's ONS series"
    ),
    stats = stats,
    series = data.frame(
      year = d$year,
      observed = d$deaths,
      population = d$population,
      rate_per_100k = round(d$rate_per_100k, 4)
    ),
    meta = list(
      source = "UK Health and Safety Executive, MESO01 (published 2026-07-01)",
      raw = "data/raw/meso01.xlsx",
      processed = "data/processed/mesothelioma_gb.csv",
      note = "Seri paper (mean 14, var 34, rentang 3-30) tidak sama dengan seri HSE ini. Tidak ada angka Table II yang diklaim."
    )
  )
}

