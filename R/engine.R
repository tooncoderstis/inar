# Mesin statistik INAR(1)-hidden Markov chain.
# Referensi: Fernandez-Fontelo et al. (2016), Statistics in Medicine 35:4875-4890.
# Implementasi mengikuti kode suplemen penulis (analysis/original/).

log_sum_exp <- function(x) {
  m <- max(x)
  if (!is.finite(m)) {
    return(-Inf)
  }
  m + log(sum(exp(x - m)))
}

log_sum_exp_rows <- function(m) {
  apply(m, 2, log_sum_exp)
}

#' Matriks emisi P(Y = j | X = k), baris k = 0..th, kolom j = 0..j_max.
emission_matrix <- function(th, omega, q, j_max) {
  k <- 0:th
  E <- matrix(0, nrow = th + 1, ncol = j_max + 1)
  for (j in 0:j_max) {
    E[, j + 1] <- ifelse(
      k < j, 0,
      ifelse(k == j, (1 - omega) + omega * q^j, omega * stats::dbinom(j, k, q))
    )
  }
  E
}

#' Matriks transisi P(X_n = next | X_{n-1} = prev) untuk INAR(1):
#' next = Binomial(prev, alpha) + Poisson(lambda).
transition_matrix <- function(th, alpha, lambda) {
  T <- matrix(0, nrow = th + 1, ncol = th + 1)
  for (prev in 0:th) {
    k <- 0:prev
    pk <- stats::dbinom(k, prev, alpha)
    for (i in seq_along(k)) {
      nxt <- k[i] + 0:(th - k[i])
      T[prev + 1, nxt + 1] <- T[prev + 1, nxt + 1] +
        pk[i] * stats::dpois(0:(th - k[i]), lambda)
    }
  }
  T
}

transition_list <- function(lambda_vec, th, alpha) {
  lapply(lambda_vec, function(l) transition_matrix(th, alpha, l))
}

#' Forward algorithm dengan penskalaan. Mengembalikan loglik dan alpha ternormalisasi.
forward_core <- function(y, E, T_list, lambda0) {
  n <- length(y)
  th <- nrow(E) - 1
  states <- 0:th
  prior <- stats::dpois(states, lambda0)
  p <- prior * E[, y[1] + 1]
  cc <- sum(p)
  if (!is.finite(cc) || cc <= 0) {
    return(list(loglik = -Inf, alpha = matrix(NA_real_, th + 1, n)))
  }
  alpha <- matrix(0, nrow = th + 1, ncol = n)
  alpha[, 1] <- p / cc
  ll <- log(cc)
  if (n >= 2) {
    for (j in 2:n) {
      w <- as.vector(t(T_list[[j]]) %*% alpha[, j - 1])
      p <- w * E[, y[j] + 1]
      cc <- sum(p)
      if (!is.finite(cc) || cc <= 0) {
        return(list(loglik = -Inf, alpha = alpha))
      }
      alpha[, j] <- p / cc
      ll <- ll + log(cc)
    }
  }
  list(loglik = ll, alpha = alpha)
}

#' Log-likelihood untuk parameter (alpha, lambda, omega, q).
#' Bila `exposure` diberikan, lambda_vec = par[2] * exposure (model dengan kovariat).
inar_loglik <- function(par, y, th, lambda_vec = NULL, E = NULL, exposure = NULL) {
  alpha <- par[1]
  lambda <- par[2]
  omega <- par[3]
  q <- par[4]
  if (any(!is.finite(par)) || alpha <= 0 || alpha >= 1 || lambda <= 0 ||
      omega <= 0 || omega >= 1 || q <= 0 || q >= 1) {
    return(-Inf)
  }
  if (!is.null(exposure)) lambda_vec <- lambda * exposure
  if (is.null(lambda_vec)) lambda_vec <- rep(lambda, length(y))
  if (max(y) > th) return(-Inf)
  if (is.null(E)) E <- emission_matrix(th, omega, q, max(y))
  T_list <- transition_list(lambda_vec, th, alpha)
  forward_core(y, E, T_list, lambda_vec[1] / (1 - alpha))$loglik
}

#' Estimasi MLE dengan nlm (sesuai paper), plus standard error dari Hessian.
fit_inar <- function(y, start, th, exposure = NULL, iterlim = 2000) {
  nll <- function(par) {
    ll <- inar_loglik(par, y, th, exposure = exposure)
    if (!is.finite(ll)) {
      return(1e10)
    }
    -ll
  }
  fit <- suppressWarnings(stats::nlm(
    nll, p = start, hessian = TRUE, iterlim = iterlim,
    gradtol = 1e-8, steptol = 1e-8
  ))
  se <- rep(NA_real_, length(fit$estimate))
  h <- tryCatch(solve(fit$hessian), error = function(e) NULL)
  if (!is.null(h)) {
    se <- sqrt(diag(h))
  }
  list(estimate = fit$estimate, se = se, nll = fit$minimum, code = fit$code)
}

#' Rekonstruksi ala kode suplemen: rekursi max (Viterbi) lalu argmax per kolom.
viterbi_paper <- function(y, par, th, lambda_vec = NULL) {
  alpha <- par[1]
  lambda <- par[2]
  omega <- par[3]
  q <- par[4]
  if (is.null(lambda_vec)) lambda_vec <- rep(lambda, length(y))
  if (max(y) > th) stop("th terlalu kecil untuk data")
  E <- emission_matrix(th, omega, q, max(y))
  T_list <- transition_list(lambda_vec, th, alpha)
  states <- 0:th
  delta <- matrix(-Inf, nrow = th + 1, ncol = length(y))
  delta[, 1] <- log(stats::dpois(states, lambda_vec[1] / (1 - alpha)) + 1e-300) +
    log(E[, y[1] + 1] + 1e-300)
  if (length(y) >= 2) {
    for (j in 2:length(y)) {
      logT <- log(T_list[[j]] + 1e-300)
      for (i in 0:th) {
        delta[i + 1, j] <- log(E[i + 1, y[j] + 1] + 1e-300) +
          max(delta[, j - 1] + logT[, i + 1])
      }
    }
  }
  apply(delta, 2, function(col) which.max(col) - 1)
}

#' Viterbi sejati dengan backtracking (opsional, untuk pembanding).
viterbi_true <- function(y, par, th, lambda_vec = NULL) {
  alpha <- par[1]
  lambda <- par[2]
  omega <- par[3]
  q <- par[4]
  if (is.null(lambda_vec)) lambda_vec <- rep(lambda, length(y))
  E <- emission_matrix(th, omega, q, max(y))
  states <- 0:th
  delta <- matrix(-Inf, th + 1, length(y))
  psi <- matrix(0L, th + 1, length(y))
  delta[, 1] <- log(stats::dpois(states, lambda_vec[1] / (1 - alpha)) + 1e-300) +
    log(E[, y[1] + 1] + 1e-300)
  for (j in 2:length(y)) {
    T <- transition_matrix(th, alpha, lambda_vec[j])
    logT <- log(T + 1e-300)
    for (i in 0:th) {
      cand <- delta[, j - 1] + logT[, i + 1]
      k <- which.max(cand)
      psi[i + 1, j] <- k - 1
      delta[i + 1, j] <- log(E[i + 1, y[j] + 1] + 1e-300) + cand[k]
    }
  }
  path <- integer(length(y))
  path[length(y)] <- which.max(delta[, length(y)]) - 1
  for (j in length(y):2) {
    path[j - 1] <- psi[path[j] + 1, j]
  }
  path
}

#' EM untuk campuran dua Poisson (setara poisregmixEM tanpa intercept).
fit_mixture2 <- function(y, maxit = 100000, tol = 1e-10) {
  m <- mean(y)
  l1 <- max(m * 0.5, 1e-6)
  l2 <- max(m * 1.5, 1e-6)
  w <- 0.5
  for (it in seq_len(maxit)) {
    d1 <- w * stats::dpois(y, l1)
    d2 <- (1 - w) * stats::dpois(y, l2)
    s <- d1 + d2
    s[s == 0] <- 1e-300
    g <- d1 / s
    nl1 <- sum(g * y) / sum(g)
    nl2 <- sum((1 - g) * y) / sum(1 - g)
    nw <- mean(g)
    if (max(abs(c(nl1 - l1, nl2 - l2, nw - w))) < tol) {
      l1 <- nl1
      l2 <- nl2
      w <- nw
      break
    }
    l1 <- nl1
    l2 <- nl2
    w <- nw
  }
  ll <- sum(log(w * stats::dpois(y, l1) + (1 - w) * stats::dpois(y, l2)))
  list(lambda1 = l1, lambda2 = l2, weight1 = w, loglik = ll,
       aic = -2 * ll + 2 * 3)
}

#' Estimasi naive berbasis ACF (Section 3.1 paper).
naive_estimates <- function(y, mixture = fit_mixture2(y)) {
  ac <- as.numeric(stats::acf(y, plot = FALSE)$acf)
  p1 <- ac[2]
  p2 <- ac[3]
  l1 <- mixture$lambda1
  l2 <- mixture$lambda2
  w1 <- mixture$weight1
  if (l1 > l2) {
    omega <- 1 - w1
    q <- l2 / l1
    big <- l1
  } else {
    omega <- w1
    q <- l1 / l2
    big <- l2
  }
  a1 <- p1 * ((1 - omega * (1 - q)) + big * omega * (1 - omega) * (1 - q)^2) /
    (1 - omega * (1 - q))^2
  lambda1 <- (1 - a1) * big
  a2 <- p2 / p1
  lambda2 <- (1 - a2) * big
  list(alpha1 = a1, lambda1 = lambda1, alpha2 = a2, lambda2 = lambda2,
       omega = omega, q = q, acf1 = p1, acf2 = p2)
}

#' AIC Poisson tunggal.
poisson_fit <- function(y) {
  lambda <- mean(y)
  ll <- sum(stats::dpois(y, lambda, log = TRUE))
  list(lambda = lambda, loglik = ll, aic = -2 * ll + 2)
}

#' Mid-pseudo-residuals (Section 4). Mengembalikan u-, u+, dan z mid.
mid_pseudo_residuals <- function(y, par, th, lambda_vec = NULL, verbose = FALSE) {
  alpha <- par[1]
  lambda <- par[2]
  omega <- par[3]
  q <- par[4]
  if (is.null(lambda_vec)) lambda_vec <- rep(lambda, length(y))
  if (max(y) > th) stop("th terlalu kecil untuk data")
  E <- emission_matrix(th, omega, q, max(y))
  T_list <- transition_list(lambda_vec, th, alpha)
  n <- length(y)
  u_minus <- numeric(n)
  u_plus <- numeric(n)
  for (m in seq_len(n)) {
    if (verbose && m %% 20 == 0) message("residual ", m, "/", n)
    keep <- setdiff(seq_len(n), m)
    ll_rest <- forward_core(
      y[keep], E, T_list[keep], lambda_vec[keep][1] / (1 - alpha)
    )$loglik
    if (!is.finite(ll_rest)) {
      u_minus[m] <- NA
      u_plus[m] <- NA
      next
    }
    probs <- numeric(y[m] + 1)
    for (r in 0:y[m]) {
      y_tmp <- y
      y_tmp[m] <- r
      probs[r + 1] <- forward_core(
        y_tmp, E, T_list, lambda_vec[1] / (1 - alpha)
      )$loglik
    }
    joint <- exp(probs - ll_rest)
    u_minus[m] <- sum(joint[seq_len(y[m])]) # r = 0..y-1
    u_plus[m] <- sum(joint)
  }
  eps <- 1e-12
  u_minus <- pmin(pmax(u_minus, eps), 1 - eps)
  u_plus <- pmin(pmax(u_plus, eps), 1 - eps)
  list(
    u_minus = u_minus,
    u_plus = u_plus,
    mid = stats::qnorm((u_minus + u_plus) / 2)
  )
}

#' Rasio cakupan: rata-rata observasi / rata-rata tersembunyi.
coverage <- function(alpha, lambda) {
  mu_hidden <- lambda / (1 - alpha)
  list(mean_hidden = mu_hidden)
}
