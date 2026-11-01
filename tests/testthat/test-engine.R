source(project_file("R", "engine.R"))

test_that("transition matrix adalah distribusi peluang", {
  T <- transition_matrix(40, 0.4, 1.2)
  expect_equal(dim(T), c(41, 41))
  expect_true(all(T >= 0))
  expect_equal(sum(T[3, ]), 1, tolerance = 1e-4)
})

test_that("emission matrix adalah distribusi peluang", {
  E <- emission_matrix(6, 0.7, 0.3, 6)
  expect_equal(dim(E), c(7, 7))
  expect_true(all(E >= 0))
  expect_equal(sum(E[5, ]), 1, tolerance = 1e-8)
})

test_that("forward loglik sama dengan enumerasi state", {
  y <- c(0L, 1L, 0L)
  th <- 3
  par <- c(0.5, 1.1, 0.6, 0.4)
  E <- emission_matrix(th, par[3], par[4], max(y))
  T <- transition_list(rep(par[2], length(y)), th, par[1])
  ll <- forward_core(y, E, T, par[2] / (1 - par[1]))$loglik

  states <- 0:th
  total <- 0
  for (x1 in states) {
    p1 <- dpois(x1, par[2] / (1 - par[1])) * E[x1 + 1, y[1] + 1]
    if (p1 == 0) next
    for (x2 in states) {
      p2 <- p1 * T[[2]][x1 + 1, x2 + 1] * E[x2 + 1, y[2] + 1]
      if (p2 == 0) next
      for (x3 in states) {
        p3 <- p2 * T[[3]][x2 + 1, x3 + 1] * E[x3 + 1, y[3] + 1]
        total <- total + p3
      }
    }
  }
  expect_equal(ll, log(total), tolerance = 1e-8)
})

test_that("EM campuran dua Poisson memulihkan parameter sintetis", {
  set.seed(42)
  y <- c(rpois(400, 1), rpois(600, 4))
  fit <- fit_mixture2(y)
  expect_equal(sort(c(fit$lambda1, fit$lambda2)), c(1, 4), tolerance = 0.25)
  expect_true(fit$weight1 > 0.3 && fit$weight1 < 0.7)
})

test_that("viterbi menghasilkan panjang yang sama dan nilai valid", {
  y <- c(0L, 2L, 1L, 0L, 3L)
  par <- c(0.5, 1.2, 0.8, 0.4)
  path <- viterbi_paper(y, par, th = 10)
  expect_length(path, length(y))
  expect_true(all(path >= 0))
  expect_true(all(path <= 10))
})
