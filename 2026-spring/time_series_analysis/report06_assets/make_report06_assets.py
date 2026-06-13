import math
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
from scipy.optimize import minimize

ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "report06_assets"


def simulate_ar1(mu, phi, sigma, n, rng):
    y = np.empty(n + 1)
    y[0] = rng.normal(mu, sigma / math.sqrt(1 - phi**2))
    shocks = rng.normal(0, sigma, n)
    for t in range(1, n + 1):
        y[t] = mu + phi * (y[t - 1] - mu) + shocks[t - 1]
    return y


def conditional_mle(y):
    yt = y[1:]
    x = y[:-1]
    x_mean = float(x.mean())
    y_mean = float(yt.mean())
    phi = float(np.sum((yt - y_mean) * (x - x_mean)) / np.sum((x - x_mean) ** 2))
    c = y_mean - phi * x_mean
    resid = yt - c - phi * x
    sigma2 = float(np.mean(resid**2))
    mu = c / (1 - phi)
    return c, phi, mu, sigma2


def exact_neg_loglik(params, y):
    mu, eta, log_sigma2 = params
    phi = math.tanh(eta)
    sigma2 = math.exp(log_sigma2)
    n = len(y) - 1

    initial = (1 - phi**2) * (y[0] - mu) ** 2
    resid = y[1:] - mu - phi * (y[:-1] - mu)
    ss = initial + float(np.sum(resid**2))
    log_det = n * math.log(sigma2) + math.log(sigma2 / (1 - phi**2))
    return 0.5 * ((n + 1) * math.log(2 * math.pi) + log_det + ss / sigma2)


def exact_mle(y):
    c0, phi0, mu0, sigma20 = conditional_mle(y)
    start = np.array([mu0, np.arctanh(np.clip(phi0, -0.98, 0.98)), math.log(sigma20)])
    res = minimize(exact_neg_loglik, start, args=(y,), method="BFGS")
    mu = float(res.x[0])
    phi = float(math.tanh(res.x[1]))
    sigma2 = float(math.exp(res.x[2]))
    c = (1 - phi) * mu
    return c, phi, mu, sigma2


def fmt(x, digits=3):
    return f"{x:.{digits}f}"


def write_series_svg(y):
    fig, ax = plt.subplots(figsize=(8.5, 3.5))
    ax.plot(range(len(y)), y, color="#1f77b4", linewidth=1.8)
    ax.axhline(2, color="#d95f02", linestyle="--", linewidth=1.2, label="true mean")
    ax.set_title("Simulated stationary AR(1) series")
    ax.set_xlabel("t")
    ax.set_ylabel("y")
    ax.grid(True, color="#d8dee8", linewidth=0.8)
    ax.legend(frameon=False)
    fig.tight_layout()
    fig.savefig(OUT_DIR / "ar1_series.svg")
    plt.close(fig)


def write_distribution_svg(results):
    fig, axes = plt.subplots(1, 2, figsize=(9, 3.6), sharey=True)
    settings = [(0.8, 100), (0.8, 400)]
    for ax, (phi, n) in zip(axes, settings, strict=True):
        vals = results[(phi, n)]
        ax.hist(vals, bins=36, color="#6aaed6", edgecolor="white")
        ax.axvline(phi, color="#d95f02", linewidth=1.8, label="true phi")
        ax.axvline(vals.mean(), color="#263142", linestyle="--", linewidth=1.4, label="mean")
        ax.set_title(f"phi={phi}, T={n}")
        ax.set_xlabel("conditional MLE of phi")
        ax.grid(True, axis="y", color="#d8dee8", linewidth=0.8)
    axes[0].set_ylabel("frequency")
    axes[1].legend(frameon=False)
    fig.tight_layout()
    fig.savefig(OUT_DIR / "phi_distribution.svg")
    plt.close(fig)


def main():
    OUT_DIR.mkdir(exist_ok=True)
    rng = np.random.default_rng(20260608)

    mu_true = 2.0
    phi_true = 0.8
    sigma_true = 1.0
    n = 100
    y = simulate_ar1(mu_true, phi_true, sigma_true, n, rng)
    write_series_svg(y)

    cond = conditional_mle(y)
    exact = exact_mle(y)

    simulations = {}
    rows = []
    for phi in (0.3, 0.8, -0.5):
        for n_rep in (50, 100, 400):
            estimates = []
            for _ in range(1000):
                ys = simulate_ar1(mu_true, phi, sigma_true, n_rep, rng)
                estimates.append(conditional_mle(ys)[1])
            estimates = np.array(estimates)
            simulations[(phi, n_rep)] = estimates
            rows.append(
                (
                    phi,
                    n_rep,
                    float(estimates.mean()),
                    float(estimates.std(ddof=1)),
                    float(np.quantile(estimates, 0.025)),
                    float(np.quantile(estimates, 0.975)),
                )
            )
    write_distribution_svg(simulations)

    true_c = (1 - phi_true) * mu_true
    summary = [
        f"#let true-c = [{fmt(true_c)}]",
        f"#let true-phi = [{fmt(phi_true)}]",
        f"#let true-mu = [{fmt(mu_true)}]",
        f"#let true-sigma2 = [{fmt(sigma_true**2)}]",
        f"#let cond-c = [{fmt(cond[0])}]",
        f"#let cond-phi = [{fmt(cond[1])}]",
        f"#let cond-mu = [{fmt(cond[2])}]",
        f"#let cond-sigma2 = [{fmt(cond[3])}]",
        f"#let exact-c = [{fmt(exact[0])}]",
        f"#let exact-phi = [{fmt(exact[1])}]",
        f"#let exact-mu = [{fmt(exact[2])}]",
        f"#let exact-sigma2 = [{fmt(exact[3])}]",
    ]
    for i, (phi, n_rep, mean, sd, q025, q975) in enumerate(rows, 1):
        summary.extend(
            [
                f"#let dist-{i}-phi = [{fmt(phi, 1)}]",
                f"#let dist-{i}-n = [{n_rep}]",
                f"#let dist-{i}-mean = [{fmt(mean)}]",
                f"#let dist-{i}-sd = [{fmt(sd)}]",
                f"#let dist-{i}-q025 = [{fmt(q025)}]",
                f"#let dist-{i}-q975 = [{fmt(q975)}]",
            ]
        )
    (OUT_DIR / "summary.typ").write_text("\n".join(summary) + "\n", encoding="utf-8")

    csv_lines = ["Y"] + [f"{v:.10f}" for v in y]
    (OUT_DIR / "HW6.csv").write_text("\n".join(csv_lines) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
