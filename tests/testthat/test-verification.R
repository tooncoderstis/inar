test_that("laporan verifikasi tidak memiliki FAIL", {
  skip_if_not(file.exists(project_file("verification", "report.json")), "jalankan run_analysis.R dulu")
  report <- jsonlite::read_json(project_file("verification", "report.json"), simplifyVector = TRUE)
  expect_equal(report$summary$FAIL, 0)
  expect_true(nrow(report$entries) >= 30)
  expect_true(all(c("metric", "paper", "reproduced", "diff", "tolerance", "status") %in%
                    names(report$entries)))
})

test_that("angka kunci HPV berada dalam toleransi", {
  skip_if_not(file.exists(project_file("verification", "report.json")), "jalankan run_analysis.R dulu")
  report <- jsonlite::read_json(project_file("verification", "report.json"), simplifyVector = TRUE)
  e <- report$entries
  row <- e[e$id == "hpv.mle.lambda", ]
  expect_equal(row$status, "PASS_TOLERANCE")
  expect_lte(abs(row$diff), row$tolerance)
  expect_equal(e$status[e$id == "hpv.n"], "PASS")
})

test_that("artefak HPV konsisten dengan data mentah", {
  skip_if_not(file.exists(project_file("public", "data", "hpv.json")), "jalankan run_analysis.R dulu")
  d <- jsonlite::read_json(project_file("public", "data", "hpv.json"), simplifyVector = TRUE)
  expect_equal(nrow(d$series), 260)
  expect_equal(mean(d$series$observed), 1.269230769, tolerance = 1e-6)
  expect_true(all(d$series$hidden[d$series$observed == 0] >= 1))
})

test_that("status mesothelioma adalah N/A, bukan klaim reproduksi", {
  skip_if_not(file.exists(project_file("verification", "report.json")), "jalankan run_analysis.R dulu")
  report <- jsonlite::read_json(project_file("verification", "report.json"), simplifyVector = TRUE)
  e <- report$entries
  expect_true(all(e$status[e$example == "Mesothelioma"] == "N/A"))
})
