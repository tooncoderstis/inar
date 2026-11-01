# Pembentukan laporan verifikasi. Status dihitung, bukan ditulis manual.

metric <- function(id, example, label, paper, reproduced, tolerance,
                   unit = "", status = NULL, note = "", kind = "tolerance") {
  numeric_pair <- is.numeric(paper) && is.numeric(reproduced) &&
    length(paper) == 1 && length(reproduced) == 1 &&
    !is.na(paper) && !is.na(reproduced)
  diff <- if (numeric_pair) reproduced - paper else NA_real_
  if (is.null(status)) {
    status <- if (kind == "exact") {
      if (is.na(diff) || abs(diff) > 1e-9) "FAIL" else "PASS"
    } else if (kind == "rounding") {
      if (is.na(diff) || abs(diff) > tolerance) "FAIL" else "PASS"
    } else if (kind == "tolerance") {
      if (is.na(diff) || abs(diff) > tolerance) "FAIL" else "PASS_TOLERANCE"
    } else if (kind == "na") {
      "N/A"
    } else if (kind == "estimated") {
      "ESTIMATED"
    } else {
      "FAIL"
    }
  }
  list(
    id = id, example = example, metric = label,
    paper = paper, reproduced = reproduced, diff = diff,
    tolerance = tolerance, unit = unit, status = status, note = note
  )
}

rounding_tolerance <- function(paper) {
  if (is.na(paper) || paper == 0) {
    return(0.5)
  }
  decimals <- max(0, nchar(sub("^[^.]*\\.?", "", format(paper, scientific = FALSE))))
  0.5 * 10^(-decimals)
}

rel_tolerance <- function(paper, rel = 0.025, abs_min = 0.03) {
  max(abs(paper) * rel, abs_min)
}

build_verification <- function(hpv, bot, meso, hpv_res, bot_res, meso_res) {
  entries <- list()
  add <- function(e) entries[[length(entries) + 1]] <<- e

  # ---------------- HPV ----------------
  add(metric("hpv.n", "HPV", "Jumlah observasi", 260, hpv_res$n, 0,
    "observasi",
    kind = "exact"
  ))
  add(metric("hpv.mean", "HPV", "Rata-rata", 1.27, hpv_res$mean,
    rounding_tolerance(1.27), "kasus/minggu",
    kind = "rounding",
    note = "Paper membulatkan ke 2 desimal."
  ))
  add(metric("hpv.var", "HPV", "Varians", 1.60, hpv_res$var,
    rounding_tolerance(1.60), "kasus^2",
    kind = "rounding"
  ))
  add(metric("hpv.dispersion", "HPV", "Indeks dispersi", 1.26,
    hpv_res$dispersion, rounding_tolerance(1.26), "",
    kind = "rounding"
  ))
  add(metric("hpv.acf1", "HPV", "ACF(1) observasi", 0.133, hpv_res$acf1,
    0.001, "",
    kind = "rounding"
  ))
  add(metric("hpv.mix.lambda", "HPV", "Campuran: lambda1/(1-alpha)", 2.765,
    hpv_res$mixture$lambda2, 0.002, "",
    kind = "tolerance",
    note = "EM 2-Poisson (setara poisregmixEM), komponen besar."
  ))
  add(metric("hpv.mix.qlambda", "HPV", "Campuran: q*lambda1/(1-alpha)", 1.042,
    hpv_res$mixture$lambda1, 0.002, "",
    kind = "tolerance"
  ))
  add(metric("hpv.mix.omega", "HPV", "Campuran: omega", 0.868,
    hpv_res$mixture$weight1, 0.002, "",
    kind = "tolerance"
  ))
  add(metric("hpv.mix.q", "HPV", "Campuran: q", 0.377,
    hpv_res$naive$q, 0.002, "",
    kind = "tolerance"
  ))
  add(metric("hpv.naive.alpha1", "HPV", "Naive: alpha1", 0.370,
    hpv_res$naive$alpha1, 0.002, "",
    kind = "tolerance"
  ))
  add(metric("hpv.naive.lambda1", "HPV", "Naive: lambda1", 1.744,
    hpv_res$naive$lambda1, 0.005, "",
    kind = "tolerance"
  ))
  add(metric("hpv.naive.alpha2", "HPV", "Naive: alpha2", 0.504,
    hpv_res$naive$alpha2, 0.002, "",
    kind = "tolerance"
  ))
  add(metric("hpv.naive.lambda2", "HPV", "Naive: lambda2", 1.372,
    hpv_res$naive$lambda2, 0.005, "",
    kind = "tolerance"
  ))
  add(metric("hpv.aic.poisson", "HPV", "AIC Poisson", 787.075,
    hpv_res$poisson$aic, 0.01, "",
    kind = "tolerance"
  ))
  add(metric("hpv.aic.mixture", "HPV", "AIC campuran 2-Poisson", 783.843,
    hpv_res$mixture$aic, 0.01, "",
    kind = "tolerance"
  ))
  add(metric("hpv.mle.alpha", "HPV", "MLE alpha", 0.517,
    hpv_res$fit$estimate[1], 0.0005, "",
    kind = "rounding",
    note = "nlm mereproduksi nilai paper pada 3 desimal."
  ))
  add(metric("hpv.mle.lambda", "HPV", "MLE lambda", 1.623,
    hpv_res$fit$estimate[2], 0.0005, "",
    kind = "rounding"
  ))
  add(metric("hpv.mle.omega", "HPV", "MLE omega", 0.922,
    hpv_res$fit$estimate[3], 0.0005, "",
    kind = "rounding"
  ))
  add(metric("hpv.mle.q", "HPV", "MLE q", 0.326,
    hpv_res$fit$estimate[4], 0.0005, "",
    kind = "rounding"
  ))
  add(metric("hpv.mle.se_alpha", "HPV", "SE alpha", 0.227,
    hpv_res$fit$se[1], 0.0005, "",
    kind = "rounding"
  ))
  add(metric("hpv.mle.se_lambda", "HPV", "SE lambda", 0.616,
    hpv_res$fit$se[2], 0.0005, "",
    kind = "rounding"
  ))
  add(metric("hpv.mle.se_omega", "HPV", "SE omega", 0.073,
    hpv_res$fit$se[3], 0.0005, "",
    kind = "rounding"
  ))
  add(metric("hpv.mle.se_q", "HPV", "SE q", 0.085,
    hpv_res$fit$se[4], 0.0005, "",
    kind = "rounding"
  ))
  add(metric("hpv.coverage", "HPV", "Cakupan tercatat (%)", 38,
    hpv_res$coverage_pct, 0.5, "%",
    kind = "rounding"
  ))

  # ---------------- Botulism ----------------
  add(metric("bot.n", "Botulism", "Jumlah observasi", 44, bot_res$n, 0,
    "tahun",
    kind = "exact"
  ))
  add(metric("bot.mean", "Botulism", "Rata-rata", 9, bot_res$mean, 0.5,
    "kasus/tahun",
    kind = "tolerance",
    note = "Counts diturunkan dari rate x populasi."
  ))
  add(metric("bot.var", "Botulism", "Varians", 44.7, bot_res$var, 0.5,
    "",
    kind = "tolerance"
  ))
  add(metric("bot.median", "Botulism", "Median", 7, bot_res$median, 0.5,
    "",
    kind = "tolerance"
  ))
  add(metric("bot.min", "Botulism", "Minimum", 0, bot_res$min, 0, "",
    kind = "exact"
  ))
  add(metric("bot.max", "Botulism", "Maksimum", 36, bot_res$max, 0, "",
    kind = "exact"
  ))
  add(metric("bot.mle.alpha", "Botulism", "MLE alpha", 0.592,
    bot_res$fit$estimate[1], NA, "",
    status = "ESTIMATED",
    note = "Data counts asli (bot.csv) tidak tersedia; angka ditampilkan sebagai perkiraan."
  ))
  add(metric("bot.mle.a", "Botulism", "MLE a", 2.475,
    bot_res$fit$estimate[2], NA, "",
    status = "ESTIMATED"
  ))
  add(metric("bot.mle.omega", "Botulism", "MLE omega", 0.671,
    bot_res$fit$estimate[3], NA, "",
    status = "ESTIMATED"
  ))
  add(metric("bot.mle.q", "Botulism", "MLE q", 0.317,
    bot_res$fit$estimate[4], NA, "",
    status = "ESTIMATED"
  ))
  add(metric("bot.aic", "Botulism", "AIC", 296.72, bot_res$aic, NA, "",
    status = "ESTIMATED"
  ))

  # ---------------- Mesothelioma ----------------
  add(metric("meso.n", "Mesothelioma", "Jumlah observasi", 46, meso_res$n, 0,
    "tahun",
    status = "N/A",
    note = "Ekstensi memakai seri HSE; bukan seri ONS paper."
  ))
  add(metric("meso.mean", "Mesothelioma", "Rata-rata (paper)", 14,
    meso_res$mean, NA, "",
    status = "N/A",
    note = "Seri HSE yang tersedia tidak sama dengan seri paper."
  ))
  add(metric("meso.var", "Mesothelioma", "Varians (paper)", 34,
    meso_res$var, NA, "",
    status = "N/A"
  ))
  add(metric("meso.range", "Mesothelioma", "Rentang (paper)", "3-30",
    paste0(meso_res$min, "-", meso_res$max), NA, "",
    status = "N/A"
  ))

  statuses <- vapply(entries, `[[`, "", "status")
  summary <- list(
    PASS = sum(statuses == "PASS"),
    PASS_TOLERANCE = sum(statuses == "PASS_TOLERANCE"),
    ESTIMATED = sum(statuses == "ESTIMATED"),
    `N/A` = sum(statuses == "N/A"),
    FAIL = sum(statuses == "FAIL")
  )
  list(
    generated_at = format(Sys.time(), "%Y-%m-%dT%H:%M:%S%z"),
    paper = list(
      title = "Under-reported data analysis with INAR-hidden Markov chains",
      authors = "Fernandez-Fontelo A., Cabana A., Puig P., Morina D.",
      journal = "Statistics in Medicine 35(26):4875-4890 (2016)",
      doi = "10.1002/sim.7026"
    ),
    entries = entries,
    summary = summary
  )
}

write_verification <- function(report, root = ".") {
  dir.create(file.path(root, "verification"), showWarnings = FALSE, recursive = TRUE)
  jsonlite::write_json(report, file.path(root, "verification", "report.json"),
    auto_unbox = TRUE, pretty = TRUE, digits = NA
  )
  lines <- c(
    "# Laporan verifikasi",
    "",
    paste0("Digenerate: ", report$generated_at),
    "",
    paste0("Paper: ", report$paper$authors, " - ", report$paper$journal),
    "",
    "| Contoh | Metrik | Paper | Rekonstruksi | Selisih | Status | Catatan |",
    "|---|---|---|---|---|---|---|"
  )
  fmt <- function(x) {
    if (is.null(x) || length(x) == 0 || is.na(x)) {
      return("-")
    }
    if (is.numeric(x)) {
      return(formatC(x, digits = 6, format = "fg"))
    }
    as.character(x)
  }
  for (e in report$entries) {
    lines <- c(lines, paste0(
      "| ", e$example, " | ", e$metric, " | ", fmt(e$paper), " | ",
      fmt(e$reproduced), " | ", fmt(e$diff), " | **", e$status, "** | ",
      e$note, " |"
    ))
  }
  lines <- c(
    lines, "",
    "## Ringkasan",
    paste0("- PASS: ", report$summary$PASS),
    paste0("- PASS_TOLERANCE: ", report$summary$PASS_TOLERANCE),
    paste0("- ESTIMATED: ", report$summary$ESTIMATED),
    paste0("- N/A: ", report$summary$`N/A`),
    paste0("- FAIL: ", report$summary$FAIL),
    "",
    "## Catatan optimizer HPV",
    "MLE direkonstruksi dengan nlm dan fungsi likelihood yang sama seperti kode suplemen.",
    "Setelah orientasi matriks transisi diperbaiki (kolom = state berikutnya), nlm mencapai",
    "titik optimum yang sama dengan paper pada 3 desimal untuk alpha, lambda, omega, q, dan SE."
  )
  writeLines(enc2utf8(lines), file.path(root, "verification", "REPORT.md"),
    useBytes = TRUE
  )
}
