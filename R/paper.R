# Konfigurasi dan verifikasi password PDF.

paper_file <- function(root = ".") {
  from_env <- Sys.getenv("PDF_PATH", unset = "")
  if (nzchar(from_env) && file.exists(from_env)) {
    return(from_env)
  }
  file.path(root, "private", "paper", "under-reported-data-inar-hmc.pdf")
}

paper_config <- function() {
  salt <- Sys.getenv("PDF_PASSWORD_SALT", unset = "")
  hash <- Sys.getenv("PDF_PASSWORD_HASH", unset = "")
  list(salt = salt, hash = tolower(hash), configured = nzchar(salt) && nzchar(hash))
}

check_paper_password <- function(password) {
  cfg <- paper_config()
  if (!cfg$configured) {
    return(FALSE)
  }
  candidate <- digest::hmac(key = cfg$salt, object = password, algo = "sha256")
  identical(tolower(candidate), cfg$hash)
}

paper_available <- function(root = ".") {
  file.exists(paper_file(root))
}
