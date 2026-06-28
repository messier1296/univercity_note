from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
from scipy import stats

ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "report08_assets"
T = 100
REPLICATIONS = 5000
SEED = 20260623


def ols(y: np.ndarray, x: np.ndarray) -> tuple[np.ndarray, np.ndarray, float]:
    design = np.column_stack((np.ones(len(x)), x))
    beta = np.linalg.solve(design.T @ design, design.T @ y)
    residual = y - design @ beta
    sigma2 = float(residual @ residual) / (len(x) - 2)
    covariance = sigma2 * np.linalg.inv(design.T @ design)
    standard_error = np.sqrt(np.diag(covariance))
    r2 = 1 - float(residual @ residual) / float((y - y.mean()) @ (y - y.mean()))
    return beta, beta / standard_error, r2


def random_walk(rng: np.random.Generator, delta: float) -> np.ndarray:
    return np.cumsum(delta + rng.normal(size=T))


def simulate_case(
    rng: np.random.Generator, delta: float
) -> tuple[np.ndarray, np.ndarray, np.ndarray, np.ndarray]:
    x = random_walk(rng, delta)
    y = random_walk(rng, delta)
    beta, t_value, r2 = ols(y, x)
    return x, y, beta, np.array([t_value[0], t_value[1], r2])


def monte_carlo(delta: float) -> tuple[float, float, float, float]:
    rng = np.random.default_rng(SEED + round(delta * 1000))
    alpha_rejections = 0
    beta_rejections = 0
    r2_values = np.empty(REPLICATIONS)
    critical = stats.t.ppf(0.975, T - 2)
    for i in range(REPLICATIONS):
        x = random_walk(rng, delta)
        y = random_walk(rng, delta)
        _, t_value, r2 = ols(y, x)
        alpha_rejections += abs(t_value[0]) > critical
        beta_rejections += abs(t_value[1]) > critical
        r2_values[i] = r2
    return (
        alpha_rejections / REPLICATIONS,
        beta_rejections / REPLICATIONS,
        float(np.median(r2_values)),
        float(np.quantile(r2_values, 0.9)),
    )


def fmt(value: float, digits: int = 3) -> str:
    return f"{value:.{digits}f}"


def main() -> None:
    OUT_DIR.mkdir(exist_ok=True)
    rng = np.random.default_rng(SEED)
    cases = []
    for delta in (0.0, 0.2):
        cases.append((delta, *simulate_case(rng, delta)))

    fig, axes = plt.subplots(2, 2, figsize=(8.2, 5.8))
    time = np.arange(1, T + 1)
    for row, (delta, x, y, beta, result) in enumerate(cases):
        axes[row, 0].plot(time, x, label="x", linewidth=1.4)
        axes[row, 0].plot(time, y, label="y", linewidth=1.4)
        axes[row, 0].set_title(f"Random walks (delta={delta:.1f})")
        axes[row, 0].set_xlabel("t")
        axes[row, 0].set_ylabel("level")
        axes[row, 0].grid(True, color="#d8dee8", linewidth=0.8)
        axes[row, 0].legend()

        axes[row, 1].scatter(x, y, s=15, alpha=0.75)
        grid = np.linspace(x.min(), x.max(), 100)
        axes[row, 1].plot(grid, beta[0] + beta[1] * grid, color="#d95f02")
        axes[row, 1].set_title(f"OLS fit (R-squared={result[2]:.3f})")
        axes[row, 1].set_xlabel("x")
        axes[row, 1].set_ylabel("y")
        axes[row, 1].grid(True, color="#d8dee8", linewidth=0.8)
    fig.tight_layout()
    fig.savefig(OUT_DIR / "spurious_regression.svg")
    plt.close(fig)

    mc_zero = monte_carlo(0.0)
    mc_drift = monte_carlo(0.2)
    lines = [f"#let seed = [{SEED}]", f"#let replications = [{REPLICATIONS}]"]
    for label, case in zip(("zero", "drift"), cases, strict=True):
        _, _, _, beta, result = case
        lines.extend(
            [
                f"#let {label}-alpha = [{fmt(beta[0])}]",
                f"#let {label}-beta = [{fmt(beta[1])}]",
                f"#let {label}-t-alpha = [{fmt(result[0])}]",
                f"#let {label}-t-beta = [{fmt(result[1])}]",
                f"#let {label}-r2 = [{fmt(result[2])}]",
            ]
        )
    for label, result in (("zero", mc_zero), ("drift", mc_drift)):
        lines.extend(
            [
                f"#let {label}-alpha-reject = [{fmt(100 * result[0], 1)}%]",
                f"#let {label}-beta-reject = [{fmt(100 * result[1], 1)}%]",
                f"#let {label}-median-r2 = [{fmt(result[2])}]",
                f"#let {label}-q90-r2 = [{fmt(result[3])}]",
            ]
        )
    (OUT_DIR / "summary.typ").write_text("\n".join(lines) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
