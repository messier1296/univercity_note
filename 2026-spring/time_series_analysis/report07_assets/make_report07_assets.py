from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np

ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "report07_assets"


def fmt(x, digits=3):
    return f"{x:.{digits}f}"


def simulate_ar2(c, phi1, phi2, sigma, n, rng):
    mu = c / (1 - phi1 - phi2)
    y = np.empty(n + 2)
    y[0] = mu
    y[1] = mu
    shocks = rng.normal(0, sigma, n)
    for i in range(n):
        y[i + 2] = c + phi1 * y[i + 1] + phi2 * y[i] + shocks[i]
    return y, shocks


def sample_acf(y, max_lag):
    centered = y - y.mean()
    denom = float(np.sum(centered**2))
    return np.array(
        [np.sum(centered[k:] * centered[:-k]) / denom for k in range(1, max_lag + 1)]
    )


def pacf_yule_walker(y, max_lag):
    centered = y - y.mean()
    denom = float(np.sum(centered**2))
    rho = [1.0]
    rho.extend(
        float(np.sum(centered[k:] * centered[:-k]) / denom)
        for k in range(1, max_lag + 1)
    )

    pacf = []
    for k in range(1, max_lag + 1):
        r_mat = np.fromfunction(
            lambda i, j: np.array([rho[abs(int(a - b))] for a, b in zip(i.flat, j.flat)])
            .reshape(i.shape),
            (k, k),
            dtype=int,
        )
        r_vec = np.array(rho[1 : k + 1])
        pacf.append(float(np.linalg.solve(r_mat, r_vec)[-1]))
    return np.array(pacf)


def write_correlogram(acf, pacf, n):
    lags = np.arange(1, len(acf) + 1)
    band = 1.96 / np.sqrt(n)
    fig, axes = plt.subplots(2, 1, figsize=(8.2, 5.8), sharex=True)
    for ax, values, title in (
        (axes[0], acf, "Sample ACF"),
        (axes[1], pacf, "Sample PACF"),
    ):
        ax.axhline(0, color="#263142", linewidth=0.9)
        ax.axhline(band, color="#d95f02", linestyle="--", linewidth=1.0)
        ax.axhline(-band, color="#d95f02", linestyle="--", linewidth=1.0)
        ax.vlines(lags, 0, values, color="#1f77b4", linewidth=2.0)
        ax.scatter(lags, values, color="#1f77b4", s=18)
        ax.set_title(title)
        ax.set_ylabel("correlation")
        ax.set_ylim(-1, 1)
        ax.grid(True, axis="y", color="#d8dee8", linewidth=0.8)
    axes[1].set_xlabel("lag")
    axes[1].set_xticks(lags)
    fig.tight_layout()
    fig.savefig(OUT_DIR / "ar2_correlogram.svg")
    plt.close(fig)


def write_series(y):
    t = np.arange(-1, 51)
    fig, ax = plt.subplots(figsize=(8.2, 3.4))
    ax.plot(t, y, color="#1f77b4", linewidth=1.7)
    ax.axhline(1.0, color="#d95f02", linestyle="--", linewidth=1.1)
    ax.set_title("Simulated AR(2) series")
    ax.set_xlabel("t")
    ax.set_ylabel("y")
    ax.grid(True, color="#d8dee8", linewidth=0.8)
    fig.tight_layout()
    fig.savefig(OUT_DIR / "ar2_series.svg")
    plt.close(fig)


def main():
    OUT_DIR.mkdir(exist_ok=True)
    rng = np.random.default_rng(20260615)

    c = 1.1
    phi1 = 0.3
    phi2 = -0.4
    sigma = 3.0
    y_all, shocks = simulate_ar2(c, phi1, phi2, sigma, 50, rng)
    y = y_all[2:]

    acf = sample_acf(y, 20)
    pacf = pacf_yule_walker(y, 20)
    write_series(y_all)
    write_correlogram(acf, pacf, len(y))

    y49 = float(y[-2])
    y50 = float(y[-1])
    yhat51 = c + phi1 * y50 + phi2 * y49
    lower51 = yhat51 - 1.96 * sigma
    upper51 = yhat51 + 1.96 * sigma
    yhat52 = c + phi1 * yhat51 + phi2 * y50

    summary = [
        "#let seed = [20260615]",
        "#let mean = [1.000]",
        f"#let y49 = [{fmt(y49)}]",
        f"#let y50 = [{fmt(y50)}]",
        f"#let forecast-51 = [{fmt(yhat51)}]",
        f"#let interval-51-lower = [{fmt(lower51)}]",
        f"#let interval-51-upper = [{fmt(upper51)}]",
        f"#let forecast-52 = [{fmt(yhat52)}]",
        f"#let acf1 = [{fmt(acf[0])}]",
        f"#let acf2 = [{fmt(acf[1])}]",
        f"#let pacf1 = [{fmt(pacf[0])}]",
        f"#let pacf2 = [{fmt(pacf[1])}]",
    ]
    (OUT_DIR / "summary.typ").write_text("\n".join(summary) + "\n", encoding="utf-8")

    csv_lines = ["t,y"]
    csv_lines.extend(f"{t},{value:.10f}" for t, value in zip(range(1, 51), y, strict=True))
    (OUT_DIR / "HW7.csv").write_text("\n".join(csv_lines) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
