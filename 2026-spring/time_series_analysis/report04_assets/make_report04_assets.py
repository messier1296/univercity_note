import html
import math
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "report04_assets"


def mean(xs):
    return float(sum(xs) / len(xs))


def variance(xs):
    m = mean(xs)
    return float(sum((x - m) ** 2 for x in xs) / len(xs))


def sample_std(xs):
    m = mean(xs)
    return math.sqrt(sum((x - m) ** 2 for x in xs) / (len(xs) - 1))


def acf_values(xs, max_lag=10):
    n = len(xs)
    m = mean(xs)
    gamma = [
        sum((xs[t] - m) * (xs[t - lag] - m) for t in range(lag, n)) / n
        for lag in range(max_lag + 1)
    ]
    return gamma, [g / gamma[0] for g in gamma]


def simulate_ma1(mu, theta, sigma, n, rng):
    u = rng.normal(0, sigma, n + 1)
    return np.array([mu + u[t + 1] + theta * u[t] for t in range(n)])


def simulate_ma2(mu, theta1, theta2, sigma, n, rng):
    u = rng.normal(0, sigma, n + 2)
    return np.array(
        [mu + u[t + 2] + theta1 * u[t + 1] + theta2 * u[t] for t in range(n)]
    )


def points_attr(points):
    return " ".join(f"{x:.2f},{y:.2f}" for x, y in points)


def nice_ticks(ymin, ymax, count=5):
    step = (ymax - ymin) / (count - 1)
    return [ymin + i * step for i in range(count)]


def line_panel(parts, series, x0, y0, width, height, title, ymin, ymax, color):
    left, right, top, bottom = 50, 15, 28, 32
    plot_w = width - left - right
    plot_h = height - top - bottom

    def sx(i):
        return x0 + left + plot_w * i / (len(series) - 1)

    def sy(v):
        return y0 + top + plot_h * (ymax - v) / (ymax - ymin)

    parts.append(f'<text class="subtitle" x="{x0 + width / 2}" y="{y0 + 17}" text-anchor="middle">{html.escape(title)}</text>')
    for tick in nice_ticks(ymin, ymax, 5):
        y = sy(tick)
        parts.append(f'<line class="grid" x1="{x0 + left}" y1="{y:.2f}" x2="{x0 + width - right}" y2="{y:.2f}"/>')
        parts.append(f'<text x="{x0 + left - 7}" y="{y + 4:.2f}" text-anchor="end">{tick:.1f}</text>')
    parts.append(f'<line class="axis" x1="{x0 + left}" y1="{y0 + top + plot_h}" x2="{x0 + width - right}" y2="{y0 + top + plot_h}"/>')
    parts.append(f'<line class="axis" x1="{x0 + left}" y1="{y0 + top}" x2="{x0 + left}" y2="{y0 + top + plot_h}"/>')
    for tick in [1, 25, 50, 75, 100]:
        x = sx(tick - 1)
        parts.append(f'<text x="{x:.2f}" y="{y0 + height - 8}" text-anchor="middle">{tick}</text>')
    pts = [(sx(i), sy(v)) for i, v in enumerate(series)]
    parts.append(f'<polyline class="line" style="stroke:{color}" points="{points_attr(pts)}"/>')


def acf_panel(parts, rho, n, x0, y0, width, height, title, ymin=-0.45, ymax=0.95):
    left, right, top, bottom = 50, 15, 28, 32
    plot_w = width - left - right
    plot_h = height - top - bottom
    bound = 1.96 / math.sqrt(n)

    def sx(k):
        return x0 + left + plot_w * (k - 1) / 9

    def sy(v):
        return y0 + top + plot_h * (ymax - v) / (ymax - ymin)

    parts.append(f'<text class="subtitle" x="{x0 + width / 2}" y="{y0 + 17}" text-anchor="middle">{html.escape(title)}</text>')
    for tick in nice_ticks(ymin, ymax, 5):
        y = sy(tick)
        parts.append(f'<line class="grid" x1="{x0 + left}" y1="{y:.2f}" x2="{x0 + width - right}" y2="{y:.2f}"/>')
        parts.append(f'<text x="{x0 + left - 7}" y="{y + 4:.2f}" text-anchor="end">{tick:.2f}</text>')
    zero = sy(0)
    parts.append(f'<line class="axis" x1="{x0 + left}" y1="{zero:.2f}" x2="{x0 + width - right}" y2="{zero:.2f}"/>')
    parts.append(f'<line class="axis" x1="{x0 + left}" y1="{y0 + top}" x2="{x0 + left}" y2="{y0 + top + plot_h}"/>')
    for b in (bound, -bound):
        y = sy(b)
        parts.append(f'<line class="bound" x1="{x0 + left}" y1="{y:.2f}" x2="{x0 + width - right}" y2="{y:.2f}"/>')
    for lag in range(1, 11):
        x = sx(lag)
        y = sy(rho[lag])
        parts.append(f'<line class="bar" x1="{x:.2f}" y1="{zero:.2f}" x2="{x:.2f}" y2="{y:.2f}"/>')
        parts.append(f'<text x="{x:.2f}" y="{y0 + height - 8}" text-anchor="middle">{lag}</text>')


def write_ma1_svg(a, f):
    ymin = min(a.min(), f.min()) - 0.4
    ymax = max(a.max(), f.max()) + 0.4
    width, height = 980, 420
    parts = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}">',
        '<style>text{font-family:"Noto Sans",sans-serif;fill:#263142;font-size:13px}.title{font-size:20px;font-weight:700}.subtitle{font-size:15px;font-weight:700}.axis{stroke:#526173;stroke-width:1}.grid{stroke:#d8dee8;stroke-width:1}.line{fill:none;stroke-width:2}</style>',
        f'<text class="title" x="{width / 2}" y="28" text-anchor="middle">MA(1) simulated series with common y-axis</text>',
    ]
    line_panel(parts, a, 15, 50, 465, 340, "(a) mu=0, theta=0.8, sigma=1", ymin, ymax, "#1f77b4")
    line_panel(parts, f, 500, 50, 465, 340, "(f) mu=-2, theta=-0.8, sigma=2", ymin, ymax, "#d95f02")
    parts.append("</svg>")
    (OUT_DIR / "ma1_af_series.svg").write_text("\n".join(parts), encoding="utf-8")


def write_acf_svg(a_rho, f_rho, n):
    width, height = 980, 420
    parts = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}">',
        '<style>text{font-family:"Noto Sans",sans-serif;fill:#263142;font-size:13px}.title{font-size:20px;font-weight:700}.subtitle{font-size:15px;font-weight:700}.axis{stroke:#526173;stroke-width:1}.grid{stroke:#d8dee8;stroke-width:1}.bar{stroke:#1f77b4;stroke-width:7}.bound{stroke:#d95f02;stroke-width:1.5;stroke-dasharray:7 5}</style>',
        f'<text class="title" x="{width / 2}" y="28" text-anchor="middle">Correlograms of MA(1) series</text>',
    ]
    acf_panel(parts, a_rho, n, 15, 50, 465, 340, "(a)")
    acf_panel(parts, f_rho, n, 500, 50, 465, 340, "(f)")
    parts.append("</svg>")
    (OUT_DIR / "ma1_af_acf.svg").write_text("\n".join(parts), encoding="utf-8")


def write_ma2_svg(y, rho, n):
    width, height = 980, 760
    ymin = min(y) - 0.4
    ymax = max(y) + 0.4
    parts = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}">',
        '<style>text{font-family:"Noto Sans",sans-serif;fill:#263142;font-size:13px}.title{font-size:20px;font-weight:700}.subtitle{font-size:15px;font-weight:700}.axis{stroke:#526173;stroke-width:1}.grid{stroke:#d8dee8;stroke-width:1}.line{fill:none;stroke:#1f77b4;stroke-width:2}.bar{stroke:#1f77b4;stroke-width:7}.bound{stroke:#d95f02;stroke-width:1.5;stroke-dasharray:7 5}</style>',
        f'<text class="title" x="{width / 2}" y="28" text-anchor="middle">MA(2): y = 2 + u_t + 0.3u_(t-1) - 0.1u_(t-2)</text>',
    ]
    line_panel(parts, y, 90, 55, 800, 300, "Simulated series (T=100)", ymin, ymax, "#1f77b4")
    acf_panel(parts, rho, n, 90, 405, 800, 300, "Correlogram up to lag 10", ymin=-0.35, ymax=0.45)
    parts.append("</svg>")
    (OUT_DIR / "ma2_series_acf.svg").write_text("\n".join(parts), encoding="utf-8")


def main():
    OUT_DIR.mkdir(exist_ok=True)
    rng = np.random.default_rng(20260517)

    ma1_a = simulate_ma1(0, 0.8, 1, 100, rng)
    ma1_f = simulate_ma1(-2, -0.8, 2, 100, rng)
    _, ma1_a_rho = acf_values(ma1_a, 10)
    _, ma1_f_rho = acf_values(ma1_f, 10)

    ma2 = simulate_ma2(2, 0.3, -0.1, 1, 100, rng)
    _, ma2_rho = acf_values(ma2, 10)

    write_ma1_svg(ma1_a, ma1_f)
    write_acf_svg(ma1_a_rho, ma1_f_rho, 100)
    write_ma2_svg(ma2, ma2_rho, 100)

    summary = [
        f"#let ma1_a_mean = [{mean(ma1_a):.3f}]",
        f"#let ma1_a_var = [{variance(ma1_a):.3f}]",
        f"#let ma1_a_acf1 = [{ma1_a_rho[1]:.3f}]",
        f"#let ma1_f_mean = [{mean(ma1_f):.3f}]",
        f"#let ma1_f_var = [{variance(ma1_f):.3f}]",
        f"#let ma1_f_acf1 = [{ma1_f_rho[1]:.3f}]",
        f"#let ma2_mean = [{mean(ma2):.3f}]",
        f"#let ma2_var = [{variance(ma2):.3f}]",
        f"#let ma2_std = [{sample_std(ma2):.3f}]",
        f"#let ma2_acf1 = [{ma2_rho[1]:.3f}]",
        f"#let ma2_acf2 = [{ma2_rho[2]:.3f}]",
    ]
    (OUT_DIR / "summary.typ").write_text("\n".join(summary) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
