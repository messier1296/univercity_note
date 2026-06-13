import html
import math
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "report05_assets"


def mean(xs):
    return float(sum(xs) / len(xs))


def variance(xs):
    m = mean(xs)
    return float(sum((x - m) ** 2 for x in xs) / len(xs))


def acf_values(xs, max_lag=10):
    n = len(xs)
    m = mean(xs)
    gamma = [
        sum((xs[t] - m) * (xs[t - lag] - m) for t in range(lag, n)) / n
        for lag in range(max_lag + 1)
    ]
    return gamma, [g / gamma[0] for g in gamma]


def simulate_ar1(c, phi, sigma, n, rng):
    burn = 300 if abs(phi) < 1 else 0
    u = rng.normal(0, sigma, n + burn)
    y = np.zeros(n + burn)
    if abs(phi) < 1:
        y[0] = c / (1 - phi)
    else:
        y[0] = 0
    for t in range(1, n + burn):
        y[t] = c + phi * y[t - 1] + u[t]
    return y[burn:]


def simulate_ar2(c, phi1, phi2, sigma, n, rng):
    burn = 300
    u = rng.normal(0, sigma, n + burn)
    y = np.zeros(n + burn)
    if 1 - phi1 - phi2 != 0:
        y[:2] = c / (1 - phi1 - phi2)
    for t in range(2, n + burn):
        y[t] = c + phi1 * y[t - 1] + phi2 * y[t - 2] + u[t]
    return y[burn:]


def points_attr(points):
    return " ".join(f"{x:.2f},{y:.2f}" for x, y in points)


def nice_ticks(ymin, ymax, count=5):
    step = (ymax - ymin) / (count - 1)
    return [ymin + i * step for i in range(count)]


def line_panel(parts, series, x0, y0, width, height, title, ymin, ymax, color):
    left, right, top, bottom = 48, 15, 27, 30
    plot_w = width - left - right
    plot_h = height - top - bottom

    def sx(i):
        return x0 + left + plot_w * i / (len(series) - 1)

    def sy(v):
        return y0 + top + plot_h * (ymax - v) / (ymax - ymin)

    parts.append(
        f'<text class="subtitle" x="{x0 + width / 2}" y="{y0 + 17}" text-anchor="middle">{html.escape(title)}</text>'
    )
    for tick in nice_ticks(ymin, ymax):
        y = sy(tick)
        parts.append(
            f'<line class="grid" x1="{x0 + left}" y1="{y:.2f}" x2="{x0 + width - right}" y2="{y:.2f}"/>'
        )
        parts.append(
            f'<text x="{x0 + left - 7}" y="{y + 4:.2f}" text-anchor="end">{tick:.1f}</text>'
        )
    parts.append(
        f'<line class="axis" x1="{x0 + left}" y1="{y0 + top + plot_h}" x2="{x0 + width - right}" y2="{y0 + top + plot_h}"/>'
    )
    parts.append(
        f'<line class="axis" x1="{x0 + left}" y1="{y0 + top}" x2="{x0 + left}" y2="{y0 + top + plot_h}"/>'
    )
    for tick in [1, 25, 50, 75, 100]:
        x = sx(tick - 1)
        parts.append(f'<text x="{x:.2f}" y="{y0 + height - 8}" text-anchor="middle">{tick}</text>')
    pts = [(sx(i), sy(v)) for i, v in enumerate(series)]
    parts.append(f'<polyline class="line" style="stroke:{color}" points="{points_attr(pts)}"/>')


def acf_panel(parts, rho, n, x0, y0, width, height, title, ymin=-0.6, ymax=1.0):
    left, right, top, bottom = 48, 15, 27, 30
    plot_w = width - left - right
    plot_h = height - top - bottom
    bound = 1.96 / math.sqrt(n)

    def sx(k):
        return x0 + left + plot_w * (k - 1) / 9

    def sy(v):
        return y0 + top + plot_h * (ymax - v) / (ymax - ymin)

    parts.append(
        f'<text class="subtitle" x="{x0 + width / 2}" y="{y0 + 17}" text-anchor="middle">{html.escape(title)}</text>'
    )
    for tick in nice_ticks(ymin, ymax):
        y = sy(tick)
        parts.append(
            f'<line class="grid" x1="{x0 + left}" y1="{y:.2f}" x2="{x0 + width - right}" y2="{y:.2f}"/>'
        )
        parts.append(
            f'<text x="{x0 + left - 7}" y="{y + 4:.2f}" text-anchor="end">{tick:.2f}</text>'
        )
    zero = sy(0)
    parts.append(f'<line class="axis" x1="{x0 + left}" y1="{zero:.2f}" x2="{x0 + width - right}" y2="{zero:.2f}"/>')
    parts.append(
        f'<line class="axis" x1="{x0 + left}" y1="{y0 + top}" x2="{x0 + left}" y2="{y0 + top + plot_h}"/>'
    )
    for b in (bound, -bound):
        y = sy(b)
        parts.append(f'<line class="bound" x1="{x0 + left}" y1="{y:.2f}" x2="{x0 + width - right}" y2="{y:.2f}"/>')
    for lag in range(1, 11):
        x = sx(lag)
        y = sy(rho[lag])
        parts.append(f'<line class="bar" x1="{x:.2f}" y1="{zero:.2f}" x2="{x:.2f}" y2="{y:.2f}"/>')
        parts.append(f'<text x="{x:.2f}" y="{y0 + height - 8}" text-anchor="middle">{lag}</text>')


def write_ar1_svgs(series_map, rho_map):
    colors = ["#1f77b4", "#d95f02", "#2ca02c", "#756bb1"]
    width, height = 980, 760
    parts = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}">',
        '<style>text{font-family:"Noto Sans",sans-serif;fill:#263142;font-size:13px}.title{font-size:20px;font-weight:700}.subtitle{font-size:15px;font-weight:700}.axis{stroke:#526173;stroke-width:1}.grid{stroke:#d8dee8;stroke-width:1}.line{fill:none;stroke-width:2}</style>',
        f'<text class="title" x="{width / 2}" y="28" text-anchor="middle">AR(1) simulated series, T=100</text>',
    ]
    positions = [(15, 55), (500, 55), (15, 405), (500, 405)]
    for i, (label, ys) in enumerate(series_map.items()):
        ymin, ymax = float(ys.min() - 0.6), float(ys.max() + 0.6)
        line_panel(parts, ys, *positions[i], 465, 300, label, ymin, ymax, colors[i])
    parts.append("</svg>")
    (OUT_DIR / "ar1_series.svg").write_text("\n".join(parts), encoding="utf-8")

    parts = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}">',
        '<style>text{font-family:"Noto Sans",sans-serif;fill:#263142;font-size:13px}.title{font-size:20px;font-weight:700}.subtitle{font-size:15px;font-weight:700}.axis{stroke:#526173;stroke-width:1}.grid{stroke:#d8dee8;stroke-width:1}.bar{stroke:#1f77b4;stroke-width:7}.bound{stroke:#d95f02;stroke-width:1.5;stroke-dasharray:7 5}</style>',
        f'<text class="title" x="{width / 2}" y="28" text-anchor="middle">Correlograms of AR(1) series</text>',
    ]
    for i, (label, rho) in enumerate(rho_map.items()):
        acf_panel(parts, rho, 100, *positions[i], 465, 300, label)
    parts.append("</svg>")
    (OUT_DIR / "ar1_acf.svg").write_text("\n".join(parts), encoding="utf-8")


def write_ar2_svg(y, rho):
    width, height = 980, 760
    ymin, ymax = float(y.min() - 0.5), float(y.max() + 0.5)
    parts = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}">',
        '<style>text{font-family:"Noto Sans",sans-serif;fill:#263142;font-size:13px}.title{font-size:20px;font-weight:700}.subtitle{font-size:15px;font-weight:700}.axis{stroke:#526173;stroke-width:1}.grid{stroke:#d8dee8;stroke-width:1}.line{fill:none;stroke:#1f77b4;stroke-width:2}.bar{stroke:#1f77b4;stroke-width:7}.bound{stroke:#d95f02;stroke-width:1.5;stroke-dasharray:7 5}</style>',
        f'<text class="title" x="{width / 2}" y="28" text-anchor="middle">AR(2): y_t = 1 + 0.5y_(t-1) + 0.2y_(t-2) + u_t</text>',
    ]
    line_panel(parts, y, 90, 55, 800, 300, "Simulated series (T=100)", ymin, ymax, "#1f77b4")
    acf_panel(parts, rho, 100, 90, 405, 800, 300, "Correlogram up to lag 10", ymin=-0.35, ymax=1.0)
    parts.append("</svg>")
    (OUT_DIR / "ar2_series_acf.svg").write_text("\n".join(parts), encoding="utf-8")


def main():
    OUT_DIR.mkdir(exist_ok=True)
    rng = np.random.default_rng(20260531)
    settings = {
        "(a) c=2, phi=0.3, sigma=2": (2, 0.3, 2),
        "(b) c=-2, phi=-0.8, sigma=1": (-2, -0.8, 1),
        "(c) c=2, phi=1.0, sigma=1": (2, 1.0, 1),
        "(d) c=2, phi=1.1, sigma=1": (2, 1.1, 1),
    }
    series_map = {label: simulate_ar1(*params, 100, rng) for label, params in settings.items()}
    rho_map = {label: acf_values(ys, 10)[1] for label, ys in series_map.items()}
    write_ar1_svgs(series_map, rho_map)

    ar2 = simulate_ar2(1, 0.5, 0.2, 1, 100, rng)
    _, ar2_rho = acf_values(ar2, 10)
    write_ar2_svg(ar2, ar2_rho)

    lines = []
    for key, label in zip(["a", "b", "c", "d"], settings):
        ys = series_map[label]
        rho = rho_map[label]
        lines.extend(
            [
                f"#let ar1_{key}_mean = [{mean(ys):.3g}]",
                f"#let ar1_{key}_var = [{variance(ys):.3g}]",
                f"#let ar1_{key}_acf1 = [{rho[1]:.3f}]",
            ]
        )
    lines.extend(
        [
            f"#let ar2_mean = [{mean(ar2):.3f}]",
            f"#let ar2_var = [{variance(ar2):.3f}]",
            f"#let ar2_acf1 = [{ar2_rho[1]:.3f}]",
            f"#let ar2_acf2 = [{ar2_rho[2]:.3f}]",
            f"#let acf_bound = [{1.96 / math.sqrt(100):.3f}]",
        ]
    )
    (OUT_DIR / "summary.typ").write_text("\n".join(lines) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
