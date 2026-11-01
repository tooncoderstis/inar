source(project_file("R", "paper.R"))

test_that("password PDF diverifikasi lewat hash dan salt", {
  old_salt <- Sys.getenv("PDF_PASSWORD_SALT", unset = NA)
  old_hash <- Sys.getenv("PDF_PASSWORD_HASH", unset = NA)
  on.exit(
    {
      if (is.na(old_salt)) Sys.unsetenv("PDF_PASSWORD_SALT") else Sys.setenv(PDF_PASSWORD_SALT = old_salt)
      if (is.na(old_hash)) Sys.unsetenv("PDF_PASSWORD_HASH") else Sys.setenv(PDF_PASSWORD_HASH = old_hash)
    },
    add = TRUE
  )

  salt <- "test-salt"
  hash <- digest::hmac(key = salt, object = "rahasia", algo = "sha256")
  Sys.setenv(PDF_PASSWORD_SALT = salt, PDF_PASSWORD_HASH = hash)

  expect_true(paper_config()$configured)
  expect_true(check_paper_password("rahasia"))
  expect_false(check_paper_password("salah"))
  expect_false(check_paper_password(""))
})

test_that("konfigurasi kosong tidak meloloskan password", {
  old_salt <- Sys.getenv("PDF_PASSWORD_SALT", unset = NA)
  old_hash <- Sys.getenv("PDF_PASSWORD_HASH", unset = NA)
  on.exit(
    {
      if (is.na(old_salt)) Sys.unsetenv("PDF_PASSWORD_SALT") else Sys.setenv(PDF_PASSWORD_SALT = old_salt)
      if (is.na(old_hash)) Sys.unsetenv("PDF_PASSWORD_HASH") else Sys.setenv(PDF_PASSWORD_HASH = old_hash)
    },
    add = TRUE
  )

  Sys.unsetenv("PDF_PASSWORD_SALT")
  Sys.unsetenv("PDF_PASSWORD_HASH")
  expect_false(paper_config()$configured)
  expect_false(check_paper_password("apa saja"))
})
