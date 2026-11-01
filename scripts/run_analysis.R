#!/usr/bin/env Rscript
# Pipeline produksi angka: data -> model -> verifikasi -> artefak.
# Jalankan dari root proyek: Rscript scripts/run_analysis.R

options(warn = 1)
root <- if (file.exists("STATUS.md")) "." else stop("Jalankan dari root proyek")
source(file.path(root, "R", "data.R"))
source(file.path(root, "R", "engine.R"))
source(file.path(root, "R", "verification.R"))
source(file.path(root, "R", "artifacts.R"))

t_start <- Sys.time()
message("== 1/4 Menyiapkan data ==")
d <- prepare_data(root)

# ---------------------------------------------------------------------------
message("== 2/4 HPV ==")
y_hpv <- d$hpv$cases
n_hpv <- length(y_hpv)
stats_hpv <- list(
  n = n_hpv,
  mean = mean(y_hpv),
  var = stats::var(y_hpv),
  dispersion = stats::var(y_hpv) / mean(y_hpv),
  acf1 = as.numeric(stats::acf(y_hpv, plot = FALSE)$acf[2]),
  min = min(y_hpv),
  max = max(y_hpv)
)
mix_hpv <- fit_mixture2(y_hpv)
pois_hpv <- poisson_fit(y_hpv)
naive_hpv <- naive_estimates(y_hpv, mix_hpv)
fit_hpv <- fit_inar(y_hpv, c(0.504, 1.372, 0.868, 0.377), th = 16)

th_hpv <- 16
E_hpv <- emission_matrix(th_hpv, fit_hpv$estimate[3], fit_hpv$estimate[4], max(y_hpv))
lam_hpv <- rep(fit_hpv$estimate[2], n_hpv)
T_hpv <- transition_list(lam_hpv, th_hpv, fit_hpv$estimate[1])
fwd_hpv <- forward_core(y_hpv, E_hpv, T_hpv, lam_hpv[1] / (1 - fit_hpv$estimate[1]))
hidden_hpv <- viterbi_paper(y_hpv, fit_hpv$estimate, th_hpv, lam_hpv)
resid_hpv <- mid_pseudo_residuals(y_hpv, fit_hpv$estimate, th_hpv, lam_hpv)
acfp_hpv <- list(
  observed = acf_pacf(y_hpv),
  residual = acf_pacf(resid_hpv$mid)
)
coverage_hpv <- 100 * mean(y_hpv) / (fit_hpv$estimate[2] / (1 - fit_hpv$estimate[1]))

hpv_fit <- list(
  alpha = fit_hpv$estimate[1],
  lambda = fit_hpv$estimate[2],
  omega = fit_hpv$estimate[3],
  q = fit_hpv$estimate[4],
  se = list(
    alpha = fit_hpv$se[1], lambda = fit_hpv$se[2],
    omega = fit_hpv$se[3], q = fit_hpv$se[4]
  ),
  nll = fit_hpv$nll,
  aic = 2 * 4 + 2 * fit_hpv$nll,
  mean_hidden = fit_hpv$estimate[2] / (1 - fit_hpv$estimate[1]),
  coverage_pct = coverage_hpv,
  th = th_hpv
)
hpv_res <- list(
  n = n_hpv, mean = stats_hpv$mean, var = stats_hpv$var,
  dispersion = stats_hpv$dispersion, acf1 = stats_hpv$acf1,
  mixture = mix_hpv, naive = naive_hpv, poisson = pois_hpv,
  fit = fit_hpv, coverage_pct = coverage_hpv
)

# ---------------------------------------------------------------------------
message("== 3/4 Botulism ==")
y_bot <- d$botulism$cases
exposure_bot <- d$botulism$population / 1e7
th_bot <- 20 + max(y_bot)
fit_bot <- fit_inar(
  y_bot, c(0.5920177, 2.4752721, 0.6710520, 0.3170722),
  th = th_bot, exposure = exposure_bot
)
lam_bot <- fit_bot$estimate[2] * exposure_bot
E_bot <- emission_matrix(th_bot, fit_bot$estimate[3], fit_bot$estimate[4], max(y_bot))
T_bot <- transition_list(lam_bot, th_bot, fit_bot$estimate[1])
fwd_bot <- forward_core(y_bot, E_bot, T_bot, lam_bot[1] / (1 - fit_bot$estimate[1]))
hidden_bot <- viterbi_paper(y_bot, fit_bot$estimate, th_bot, lam_bot)
resid_bot <- mid_pseudo_residuals(y_bot, fit_bot$estimate, th_bot, lam_bot)
acfp_bot <- list(residual = acf_pacf(resid_bot$mid))
coverage_bot <- 100 * mean(y_bot) / (mean(lam_bot) / (1 - fit_bot$estimate[1]))

stats_bot <- list(
  n = length(y_bot), mean = mean(y_bot), var = stats::var(y_bot),
  median = stats::median(y_bot), min = min(y_bot), max = max(y_bot)
)
bot_fit <- list(
  alpha = fit_bot$estimate[1],
  a = fit_bot$estimate[2],
  omega = fit_bot$estimate[3],
  q = fit_bot$estimate[4],
  se = list(
    alpha = fit_bot$se[1], a = fit_bot$se[2],
    omega = fit_bot$se[3], q = fit_bot$se[4]
  ),
  nll = fit_bot$nll,
  aic = 2 * 4 + 2 * fit_bot$nll,
  mean_hidden = mean(lam_bot) / (1 - fit_bot$estimate[1]),
  coverage_pct = coverage_bot,
  th = th_bot,
  scale = "lambda_n = a * population / 1e7"
)
bot_res <- list(
  n = length(y_bot), mean = stats_bot$mean, var = stats_bot$var,
  median = stats_bot$median, min = stats_bot$min, max = stats_bot$max,
  fit = fit_bot, aic = 2 * 4 + 2 * fit_bot$nll, coverage_pct = coverage_bot
)

# ---------------------------------------------------------------------------
message("== 4/4 Mesothelioma (ekstensi) ==")
stats_meso <- list(
  n = nrow(d$mesothelioma),
  mean = mean(d$mesothelioma$deaths),
  var = stats::var(d$mesothelioma$deaths),
  median = stats::median(d$mesothelioma$deaths),
  min = min(d$mesothelioma$deaths),
  max = max(d$mesothelioma$deaths)
)
meso_res <- list(
  n = stats_meso$n, mean = stats_meso$mean, var = stats_meso$var,
  min = stats_meso$min, max = stats_meso$max
)

# ---------------------------------------------------------------------------
message("== Verifikasi ==")
report <- build_verification(
  d$hpv, d$botulism, d$mesothelioma, hpv_res, bot_res, meso_res
)
dir.create(file.path(root, "verification", "golden"), recursive = TRUE, showWarnings = FALSE)
write_verification(report, root)
write_json(report, file.path(root, "public", "data", "verification.json"))

# ---------------------------------------------------------------------------
message("== Artefak aplikasi ==")
write_json(
  hpv_payload(
    y_hpv, d$hpv$year, d$hpv$week, stats_hpv, hpv_fit,
    naive_hpv, mix_hpv, pois_hpv, hidden_hpv, acfp_hpv, resid_hpv
  ),
  file.path(root, "public", "data", "hpv.json")
)
write_json(
  bot_payload(d$botulism, stats_bot, bot_fit, hidden_bot, acfp_bot, resid_bot),
  file.path(root, "public", "data", "botulism.json")
)
write_json(
  meso_payload(d$mesothelioma, stats_meso),
  file.path(root, "public", "data", "mesothelioma.json")
)
write_json(
  list(
    generated_at = report$generated_at,
    summary = report$summary,
    key = list(
      hpv_coverage_pct = coverage_hpv,
      hpv_mean_observed = stats_hpv$mean,
      hpv_mean_hidden = hpv_fit$mean_hidden,
      bot_coverage_pct = coverage_bot,
      bot_mean_observed = stats_bot$mean,
      bot_mean_hidden = bot_fit$mean_hidden
    )
  ),
  file.path(root, "public", "data", "summary.json")
)
write_json(
  list(stats = stats_hpv, fit = hpv_fit, naive = naive_hpv, mixture = mix_hpv),
  file.path(root, "verification", "golden", "hpv.json")
)
write_json(
  list(stats = stats_bot, fit = bot_fit),
  file.path(root, "verification", "golden", "botulism.json")
)

# ---------------------------------------------------------------------------
message("== Ringkasan ==")
cat("HPV : n=", n_hpv, " mean=", round(stats_hpv$mean, 4),
    " var=", round(stats_hpv$var, 4),
    " ACF1=", round(stats_hpv$acf1, 4), "\n", sep = "")
cat("HPV MLE: ", paste(round(fit_hpv$estimate, 4), collapse = ", "),
    " | coverage ", round(coverage_hpv, 1), "%\n", sep = "")
cat("BOT MLE: ", paste(round(fit_bot$estimate, 4), collapse = ", "),
    " | AIC ", round(bot_fit$aic, 2), "\n", sep = "")
cat("Status: ", paste(names(report$summary), report$summary, sep = "=", collapse = ", "), "\n", sep = "")
cat("Selesai dalam ", round(as.numeric(difftime(Sys.time(), t_start, units = "mins")), 1), " menit\n", sep = "")

if (report$summary$FAIL > 0) {
  stop("Ada metrik berstatus FAIL. Periksa verification/REPORT.md")
}
