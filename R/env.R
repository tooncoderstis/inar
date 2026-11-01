# Memuat .env untuk pengembangan lokal. Di produksi, env disuntikkan oleh platform.

load_dotenv <- function(path = ".env") {
  if (!file.exists(path)) return(invisible(FALSE))
  lines <- readLines(path, warn = FALSE, encoding = "UTF-8")
  for (line in lines) {
    line <- trimws(line)
    if (line == "" || startsWith(line, "#")) next
    pos <- regexpr("=", line, fixed = TRUE)
    if (pos < 1) next
    key <- trimws(substr(line, 1, pos - 1))
    value <- trimws(substr(line, pos + 1, nchar(line)))
    if (grepl("^['\"].*['\"]$", value)) value <- substr(value, 2, nchar(value) - 1)
    if (key != "" && Sys.getenv(key, unset = "") == "") {
      do.call(Sys.setenv, stats::setNames(list(value), key))
    }
  }
  invisible(TRUE)
}
