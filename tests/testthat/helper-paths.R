project_root <- normalizePath(
  file.path(testthat::test_path(), "..", ".."),
  winslash = "/", mustWork = FALSE
)

project_file <- function(...) file.path(project_root, ...)
