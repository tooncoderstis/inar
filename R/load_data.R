# Memuat artefak hasil pipeline sekali saat aplikasi start.

load_artifact <- function(root, name) {
  path <- file.path(root, "public", "data", paste0(name, ".json"))
  if (!file.exists(path)) {
    stop("Artefak tidak ditemukan: ", path, ". Jalankan Rscript scripts/run_analysis.R")
  }
  jsonlite::read_json(path, simplifyVector = TRUE)
}

load_app_data <- function(root = ".") {
  list(
    hpv = load_artifact(root, "hpv"),
    botulism = load_artifact(root, "botulism"),
    mesothelioma = load_artifact(root, "mesothelioma"),
    verification = load_artifact(root, "verification"),
    summary = load_artifact(root, "summary")
  )
}
