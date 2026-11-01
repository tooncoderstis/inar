# Methodology guide

This page explains the **INAR(1)-hidden Markov chain** model for under-reported data, step by step. No advanced statistics background is required; formulas come after the intuition.

## 1. Why under-reporting matters

Suppose $X_n$ cases of HPV truly occur each week, but the registry records only $Y_n \le X_n$. If we model $Y_n$ as if it were $X_n$, we will:

- underestimate the mean burden of disease;
- misjudge associations with risk factors;
- plan services for too few cases.

Under-reporting is **permanent** in this model: unrecorded cases do not appear later. This differs from *delayed reporting*, where data become more complete over time.

## 2. Count data and INAR(1)

Our data are counts (0, 1, 2, ...), not continuous values. Ordinary ARMA models do not fit. The **INAR(1)** model (integer autoregressive of order 1) mirrors an AR(1) equation:

$$
X_n = \alpha \circ X_{n-1} + W_n, \qquad W_n \sim \text{Poisson}(\lambda).
$$

The symbol $\circ$ is **thinning**: each unit of $X_{n-1}$ survives independently with probability $\alpha$. Thus $\alpha \circ X_{n-1}$ is the number of successes among $X_{n-1}$ Bernoulli trials. The result is always a non-negative integer.

- High $\alpha$: strong memory (this week's cases relate to last week's).
- $\lambda$ is the mean number of new cases unrelated to the past.

The marginal mean of the hidden process is

$$
\mu_X = \frac{\lambda}{1-\alpha}.
$$

## 3. Modelling under-reporting

At each time, with probability $\omega$ (the under-reporting frequency), the recorded value is thinned again:

$$
Y_n =
\begin{cases}
X_n, & \text{with probability } 1-\omega,\\
q \circ X_n, & \text{with probability } \omega.
\end{cases}
$$

The parameter $q \in (0,1)$ is the **intensity** of under-reporting. If $q$ approaches 1 or $\omega$ approaches 0, $Y_n \approx X_n$ and under-reporting is not an issue.

The emission probabilities (probability of observing $j$ given hidden state $k$) are:

$$
P(Y_n=j \mid X_n=k)=
\begin{cases}
0, & k<j,\\
(1-\omega)+\omega q^k, & k=j,\\
\omega \binom{k}{j} q^j (1-q)^{k-j}, & k>j.
\end{cases}
$$

## 4. Identification through the ACF

The autocorrelation function of the observed process has a simple form:

$$
\rho_Y(k) = c(\alpha,\lambda,\omega,q)\,\alpha^{|k|}.
$$

Therefore $\log \rho_Y(k)$ is linear in $k$ with slope $\log \alpha$. A significant intercept indicates under-reporting. For HPV, this regression gives a significant intercept ($p = 0.002$), consistent with under-reporting.

## 5. Naive estimation

For stationary series, the authors propose a quick approach:

1. Fit a two-Poisson mixture; obtain $\hat\lambda_1, \hat\lambda_2, \hat\omega$.
2. Compute $\hat q = \hat\lambda_{\text{small}}/\hat\lambda_{\text{large}}$.
3. Use ACF(1) and ACF(2) to estimate $\alpha_1, \lambda_1, \alpha_2, \lambda_2$.

HPV results: $\hat\lambda_1/(1-\alpha)=2.765$, $\hat q\hat\lambda_1/(1-\alpha)=1.042$, $\hat\omega=0.868$, $\hat q=0.377$; then $\hat\alpha_1=0.370$, $\hat\lambda_1=1.744$, $\hat\alpha_2=0.504$, $\hat\lambda_2=1.372$.

## 6. Likelihood and the forward algorithm

The hidden series has infinitely many possible paths, so the likelihood is computed with the **forward algorithm**:

$$
\alpha_k(X_k)=P(Y_1,\dots,Y_k,X_k)
= P(Y_k\mid X_k)\sum_{x_{k-1}} P(X_k\mid X_{k-1})\,\alpha_{k-1}(x_{k-1}).
$$

The INAR(1) transition probability is

$$
P(X_n=x_n\mid X_{n-1}=x_{n-1})
= e^{-\lambda}\sum_{j=0}^{\min(x_n,x_{n-1})}
\binom{x_{n-1}}{j}\alpha^j(1-\alpha)^{x_{n-1}-j}
\frac{\lambda^{x_n-j}}{(x_n-j)!}.
$$

States are truncated at $T$ (for example $2\max Y_i$ or a stable value) to make computation feasible. The total likelihood is $\sum_{x_n}\alpha_n(x_n)$, maximised with `nlm`.

## 7. Reconstruction with Viterbi

Once parameters are estimated, we want the most probable hidden series:

$$
X^* = \arg\max_X \hat P(X_{1:n}\mid Y_{1:n}).
$$

The Viterbi algorithm solves this with dynamic programming. The paper's code uses a simpler version: at each time, take the state with the largest $\alpha$. In this app, the "hidden" line follows the paper's approach.

## 8. Model checking: mid-pseudo-residuals

Residuals are defined from the conditional probability of one observation given the rest:

$$
u_n^- = \hat P(Y_n < y_n \mid Y_{-n}), \qquad
u_n^+ = \hat P(Y_n \le y_n \mid Y_{-n}),
$$

then

$$
z_n^{mid} = \Phi^{-1}\!\left(\frac{u_n^-+u_n^+}{2}\right).
$$

If the model is correct, residuals resemble white noise. For HPV, the residual ACF/PACF stay inside the band, supporting the fit.

## 9. Reading the parameters

- $\omega$: how often a case is recorded in thinned form.
- $q$: how much is lost when under-reporting occurs.
- $\alpha$: persistence of the hidden series.
- $\lambda$: innovation intensity; with a covariate, $\lambda_n = aN_n$ (population).
- Coverage $\approx \bar Y / \mu_X$.

For HPV: $\hat\mu_X = 1.623/(1-0.517) \approx 3.36$ cases/week, while the recorded mean is 1.27. Coverage is about 38%.

## 10. R code snippets

Emission function:

```r
emission <- function(yx, omega, q) {
  if (yx[1] < yx[2]) return(0)
  if (yx[1] == yx[2]) return((1 - omega) + omega * q^yx[1])
  omega * dbinom(yx[2], yx[1], q)
}
```

One forward step:

```r
for (j in 2:length(y)) {
  for (i in 0:th) {
    ppa[i + 1, j] <- log(sum(
      exp(log(emit[i + 1, y[j] + 1]) +
          log(trans[, i + 1]) +
          ppa[, j - 1])
    ))
  }
}
```

## 11. Exercises

1. In the Lab tab, raise $\omega$ from 0.5 to 0.95. What happens to coverage and the shape of the hidden series?
2. Lower $q$ to 0.1. Why do hidden peaks grow?
3. Compare the HPV residual ACF with the band. Does any lag fall outside?
4. For Botulism, change $a$. How does the population covariate affect $\lambda_n$?
5. Explain why the model must not be used to claim exact numbers without complete raw data.

## 12. Limits and ethics

This model helps **estimate** the scale of under-reporting, not prove its causes. Estimates should be presented with uncertainty and data caveats. For policy, use them as an indication that registries need improvement, not as a verdict.
