# Persiapan data: hanya membaca data/raw dan menulis data/processed.
# Semua transformasi didokumentasikan di data/processed/PROVENANCE.md.

read_hpv <- function(root = ".") {
  path <- file.path(root, "data", "raw", "hpv_catalonia_weekly.csv")
  d <- utils::read.csv(path, header = TRUE, sep = ";", check.names = FALSE,
                       stringsAsFactors = FALSE)
  d <- d[!is.na(d$Any) & !is.na(d$Setmana) & !is.na(d$Girona), ]
  d <- d[d$Any >= 2010 & d$Any <= 2014 & d$Setmana != 53, ]
  out <- data.frame(
    year = as.integer(d$Any),
    week = as.integer(d$Setmana),
    cases = as.integer(d$Girona)
  )
  out <- out[order(out$year, out$week), ]
  rownames(out) <- NULL
  out
}

read_population <- function(root = ".", country = c("canada", "uk")) {
  country <- match.arg(country)
  path <- file.path(root, "data", "reference", paste0("population_", country, ".csv"))
  d <- utils::read.csv(path, stringsAsFactors = FALSE)
  d[order(d$year), c("year", "population", "iso3", "source", "url", "retrieved_at")]
}

read_botulism <- function(root = ".") {
  path <- file.path(root, "data", "raw", "botulisme.xlsx")
  raw <- suppressMessages(readxl::read_excel(path, sheet = "Data", col_names = FALSE))
  raw <- as.data.frame(raw)
  year <- suppressWarnings(as.integer(raw[[2]]))
  rate <- suppressWarnings(as.numeric(raw[[3]]))
  d <- data.frame(year = year, rate_per_100k = rate)
  d <- d[!is.na(d$year) & d$year >= 1970 & d$year <= 2013, ]
  pop <- read_population(root, "canada")
  d <- merge(d, pop[, c("year", "population")], by = "year", all.x = TRUE)
  d <- d[order(d$year), ]
  d$derived_count <- round(d$rate_per_100k * d$population / 1e5)
  d$cases <- as.integer(d$derived_count)
  # Koreksi penulis paper: serie[41] = 2 (tahun 2010).
  d$cases[d$year == 2010] <- 2L
  d$note <- ifelse(d$year == 2010, "corrected to 2 following the paper's script", "derived: rate x population")
  rownames(d) <- NULL
  d
}

read_mesothelioma <- function(root = ".") {
  path <- file.path(root, "data", "raw", "meso01.xlsx")
  raw <- as.data.frame(suppressMessages(
    readxl::read_excel(path, sheet = "MESO01", col_names = FALSE)
  ))
  years <- suppressWarnings(as.integer(unlist(raw[6, 3:ncol(raw)])))
  gb <- which(apply(raw, 1, function(r) any(r == "Great Britain", na.rm = TRUE)))
  if (length(gb) == 0) stop("Baris Great Britain tidak ditemukan")
  total_row <- NA_integer_
  for (i in (gb + 1):(gb + 5)) {
    if (!is.na(raw[i, 2]) && raw[i, 2] == "Total") {
      total_row <- i
      break
    }
  }
  if (is.na(total_row)) stop("Baris Total Great Britain tidak ditemukan")
  deaths <- suppressWarnings(as.numeric(unlist(raw[total_row, 3:ncol(raw)])))
  d <- data.frame(year = years, deaths = deaths)
  d <- d[!is.na(d$year) & d$year >= 1968 & d$year <= 2013, ]
  pop <- read_population(root, "uk")
  d <- merge(d, pop[, c("year", "population")], by = "year", all.x = TRUE)
  d <- d[order(d$year), ]
  d$rate_per_100k <- d$deaths / d$population * 1e5
  rownames(d) <- NULL
  d
}

prepare_data <- function(root = ".") {
  dir.create(file.path(root, "data", "processed"), recursive = TRUE, showWarnings = FALSE)
  hpv <- read_hpv(root)
  bot <- read_botulism(root)
  meso <- read_mesothelioma(root)
  utils::write.csv(hpv, file.path(root, "data", "processed", "hpv_girona.csv"), row.names = FALSE)
  utils::write.csv(bot, file.path(root, "data", "processed", "botulism_canada.csv"), row.names = FALSE)
  utils::write.csv(meso, file.path(root, "data", "processed", "mesothelioma_gb.csv"), row.names = FALSE)
  write_provenance(root)
  list(hpv = hpv, botulism = bot, mesothelioma = meso)
}

write_provenance <- function(root = ".") {
  txt <- c(
    "# Provenance data",
    "",
    paste0("Digenerate: ", Sys.Date(), " oleh `scripts/run_analysis.R`."),
    "",
    "## HPV Girona",
    "- Sumber mentah: `data/raw/hpv_catalonia_weekly.csv` (Generalitat de Catalunya; kolom `Girona`).",
    "- Filter: tahun 2010-2014, minggu 53 dibuang, nilai kosong dibuang.",
    "- Hasil: 260 observasi mingguan; nilai 0-6.",
    "",
    "## Botulism Kanada",
    "- Sumber mentah: `data/raw/botulisme.xlsx`, sheet `Data` (rate per 100.000, PHAC/CNDSS).",
    "- Populasi: `data/reference/population_canada.csv` (World Bank SP.POP.TOTL).",
    "- Counts diturunkan: `round(rate * population / 100000)`.",
    "- Koreksi mengikuti skrip penulis: tahun 2010 di-set 2.",
    "- Status: **derived** — bukan file `bot.csv` asli; MLE diberi status ESTIMATED.",
    "",
    "## Mesothelioma",
    "- Sumber mentah: `data/raw/meso01.xlsx`, sheet `MESO01`, baris `Great Britain / Total`.",
    "- Populasi: `data/reference/population_uk.csv` (World Bank SP.POP.TOTL).",
    "- Status: **ekstensi** (seri HSE 1968-2013). Bukan seri ONS yang dipakai paper.",
    "",
    "## Populasi",
    "- World Bank API `SP.POP.TOTL`, diakses 2026-11-01; URL tersimpan di CSV referensi."
  )
  writeLines(txt, file.path(root, "data", "processed", "PROVENANCE.md"), useBytes = TRUE)
}
