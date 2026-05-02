import csv
import html
import math
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
CSV_PATH = ROOT / "gaku-jk2542.csv"
OUT_DIR = ROOT / "report03_assets"


def parse_float(value):
    return float(value.replace(",", "").strip())


def load_gdp():
    rows = []
    current_year = None
    with CSV_PATH.open(encoding="cp932", newline="") as f:
        for i, row in enumerate(csv.reader(f)):
            if i < 7 or not row or not row[0].strip():
                continue
            label = row[0].strip()
            if "/" in label:
                year_text, q_text = label.split("/", 1)
                current_year = int(year_text.strip())
            else:
                q_text = label
            q_text = q_text.replace(".", "").strip()
            if q_text.startswith("1-"):
                q = 1
            elif q_text.startswith("4-"):
                q = 2
            elif q_text.startswith("7-"):
                q = 3
            elif q_text.startswith("10-"):
                q = 4
            else:
                continue
            rows.append((current_year, q, f"{current_year}Q{q}", parse_float(row[1])))
    return rows


def mean(xs):
    return sum(xs) / len(xs)


def variance_pop(xs):
    m = mean(xs)
    return sum((x - m) ** 2 for x in xs) / len(xs)


def acf_values(xs, max_lag=10):
    n = len(xs)
    m = mean(xs)
    gamma = []
    for lag in range(max_lag + 1):
        gamma.append(sum((xs[t] - m) * (xs[t - lag] - m) for t in range(lag, n)) / n)
    return gamma, [g / gamma[0] for g in gamma]


def nice_ticks(ymin, ymax, count=5):
    if ymin == ymax:
        return [ymin]
    step = (ymax - ymin) / (count - 1)
    return [ymin + step * i for i in range(count)]


def polyline(points):
    return " ".join(f"{x:.2f},{y:.2f}" for x, y in points)


def line_chart_svg(series, path, title, ylabel, width=980, height=430):
    margin = dict(left=75, right=25, top=50, bottom=55)
    plot_w = width - margin["left"] - margin["right"]
    plot_h = height - margin["top"] - margin["bottom"]
    all_y = [v for _, v in series]
    ymin, ymax = min(all_y), max(all_y)
    pad = (ymax - ymin) * 0.08 if ymax > ymin else 1
    ymin -= pad
    ymax += pad

    def sx(i):
        return margin["left"] + plot_w * i / (len(series) - 1)

    def sy(v):
        return margin["top"] + plot_h * (ymax - v) / (ymax - ymin)

    ticks = nice_ticks(ymin, ymax)
    labels = [series[i][0] for i in range(0, len(series), max(1, len(series) // 8))]
    label_indices = [next(i for i, row in enumerate(series) if row[0] == lab) for lab in labels]
    pts = [(sx(i), sy(v)) for i, (_, v) in enumerate(series)]

    parts = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}">',
        '<style>text{font-family:"Noto Sans CJK JP","Noto Sans",sans-serif;fill:#263142;font-size:13px}.title{font-size:20px;font-weight:700}.axis{stroke:#526173;stroke-width:1}.grid{stroke:#d8dee8;stroke-width:1}.line{fill:none;stroke:#1f77b4;stroke-width:2.2}</style>',
        f'<text class="title" x="{width/2}" y="28" text-anchor="middle">{html.escape(title)}</text>',
        f'<text x="18" y="{height/2}" transform="rotate(-90 18 {height/2})" text-anchor="middle">{html.escape(ylabel)}</text>',
    ]
    for tick in ticks:
        y = sy(tick)
        parts.append(f'<line class="grid" x1="{margin["left"]}" y1="{y:.2f}" x2="{width-margin["right"]}" y2="{y:.2f}"/>')
        parts.append(f'<text x="{margin["left"]-8}" y="{y+4:.2f}" text-anchor="end">{tick:.3f}</text>')
    parts.append(f'<line class="axis" x1="{margin["left"]}" y1="{height-margin["bottom"]}" x2="{width-margin["right"]}" y2="{height-margin["bottom"]}"/>')
    parts.append(f'<line class="axis" x1="{margin["left"]}" y1="{margin["top"]}" x2="{margin["left"]}" y2="{height-margin["bottom"]}"/>')
    for i in label_indices:
        x = sx(i)
        parts.append(f'<text x="{x:.2f}" y="{height-margin["bottom"]+24}" text-anchor="middle">{html.escape(series[i][0])}</text>')
    parts.append(f'<polyline class="line" points="{polyline(pts)}"/>')
    parts.append("</svg>")
    path.write_text("\n".join(parts), encoding="utf-8")


def combined_svg(labels, values, path):
    colors = ["#1f77b4", "#d95f02", "#2b8a3e"]
    width, height = 980, 760
    panel_h = 230
    parts = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}">',
        '<style>text{font-family:"Noto Sans CJK JP","Noto Sans",sans-serif;fill:#263142;font-size:13px}.title{font-size:20px;font-weight:700}.subtitle{font-size:16px;font-weight:700}.axis{stroke:#526173;stroke-width:1}.grid{stroke:#d8dee8;stroke-width:1}.line{fill:none;stroke-width:2}</style>',
        f'<text class="title" x="{width/2}" y="28" text-anchor="middle">実質季節調整GDPの変換系列</text>',
    ]
    panels = [
        ("原系列", values["level"], "10億円"),
        ("対数系列", values["log"], "log"),
        ("対数差分系列", values["dlog"], "前期差"),
    ]
    for p, (name, ys, unit) in enumerate(panels):
        top = 55 + p * panel_h
        left, right, bottom = 75, 25, 38
        plot_w, plot_h = width - left - right, panel_h - bottom - 25
        ymin, ymax = min(ys), max(ys)
        pad = (ymax - ymin) * 0.08 if ymax > ymin else 1
        ymin -= pad
        ymax += pad

        def sx(i):
            return left + plot_w * i / (len(ys) - 1)

        def sy(v):
            return top + 25 + plot_h * (ymax - v) / (ymax - ymin)

        parts.append(f'<text class="subtitle" x="{left}" y="{top+3}">{html.escape(name)} ({html.escape(unit)})</text>')
        for tick in nice_ticks(ymin, ymax, 4):
            y = sy(tick)
            parts.append(f'<line class="grid" x1="{left}" y1="{y:.2f}" x2="{width-right}" y2="{y:.2f}"/>')
            parts.append(f'<text x="{left-8}" y="{y+4:.2f}" text-anchor="end">{tick:.3f}</text>')
        parts.append(f'<line class="axis" x1="{left}" y1="{top+25+plot_h}" x2="{width-right}" y2="{top+25+plot_h}"/>')
        parts.append(f'<line class="axis" x1="{left}" y1="{top+25}" x2="{left}" y2="{top+25+plot_h}"/>')
        pts = [(sx(i), sy(v)) for i, v in enumerate(ys)]
        parts.append(f'<polyline class="line" style="stroke:{colors[p]}" points="{polyline(pts)}"/>')
        if p == 2:
            step = max(1, len(labels) // 8)
            for i in range(0, len(labels), step):
                parts.append(f'<text x="{sx(i):.2f}" y="{top+25+plot_h+24}" text-anchor="middle">{html.escape(labels[i])}</text>')
    parts.append("</svg>")
    path.write_text("\n".join(parts), encoding="utf-8")


def acf_svg(rho, n, path):
    width, height = 760, 430
    left, right, top, bottom = 70, 30, 45, 55
    plot_w, plot_h = width - left - right, height - top - bottom
    bound = 1.96 / math.sqrt(n)
    ymin = min(-0.35, min(rho[1:]) - 0.05, -bound - 0.05)
    ymax = max(0.35, max(rho[1:]) + 0.05, bound + 0.05)

    def sx(k):
        return left + plot_w * (k - 1) / 9

    def sy(v):
        return top + plot_h * (ymax - v) / (ymax - ymin)

    parts = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}">',
        '<style>text{font-family:"Noto Sans CJK JP","Noto Sans",sans-serif;fill:#263142;font-size:13px}.title{font-size:20px;font-weight:700}.axis{stroke:#526173;stroke-width:1}.grid{stroke:#d8dee8;stroke-width:1}.bar{stroke:#1f77b4;stroke-width:7}.bound{stroke:#d95f02;stroke-width:1.6;stroke-dasharray:7 5}</style>',
        f'<text class="title" x="{width/2}" y="28" text-anchor="middle">対数差分系列のコレログラム</text>',
    ]
    for tick in nice_ticks(ymin, ymax, 6):
        y = sy(tick)
        parts.append(f'<line class="grid" x1="{left}" y1="{y:.2f}" x2="{width-right}" y2="{y:.2f}"/>')
        parts.append(f'<text x="{left-8}" y="{y+4:.2f}" text-anchor="end">{tick:.3f}</text>')
    zero = sy(0)
    parts.append(f'<line class="axis" x1="{left}" y1="{zero:.2f}" x2="{width-right}" y2="{zero:.2f}"/>')
    parts.append(f'<line class="axis" x1="{left}" y1="{top}" x2="{left}" y2="{height-bottom}"/>')
    for b in (bound, -bound):
        y = sy(b)
        parts.append(f'<line class="bound" x1="{left}" y1="{y:.2f}" x2="{width-right}" y2="{y:.2f}"/>')
    for k in range(1, 11):
        x = sx(k)
        y = sy(rho[k])
        parts.append(f'<line class="bar" x1="{x:.2f}" y1="{zero:.2f}" x2="{x:.2f}" y2="{y:.2f}"/>')
        parts.append(f'<text x="{x:.2f}" y="{height-bottom+24}" text-anchor="middle">{k}</text>')
    parts.append(f'<text x="{width/2}" y="{height-8}" text-anchor="middle">lag</text>')
    parts.append("</svg>")
    path.write_text("\n".join(parts), encoding="utf-8")


def main():
    rows = load_gdp()
    labels = [r[2] for r in rows]
    y = [r[3] for r in rows]
    log_y = [math.log(v) for v in y]
    dlog = [log_y[i] - log_y[i - 1] for i in range(1, len(log_y))]
    growth = [(y[i] - y[i - 1]) / y[i - 1] for i in range(1, len(y))]
    dlabels = labels[1:]

    gamma, rho = acf_values(dlog, 10)
    OUT_DIR.mkdir(exist_ok=True)
    combined_svg(dlabels, {"level": y[1:], "log": log_y[1:], "dlog": dlog}, OUT_DIR / "gdp_transformations.svg")
    line_chart_svg(list(zip(dlabels, growth)), OUT_DIR / "gdp_growth.svg", "実質季節調整GDPの変化率", "前期比")
    acf_svg(rho, len(dlog), OUT_DIR / "gdp_acf.svg")

    summary_path = OUT_DIR / "gdp_summary.typ"
    lines = [
        f"#let gdp_start = [{labels[0]}]",
        f"#let gdp_end = [{labels[-1]}]",
        f"#let gdp_n = [{len(y)}]",
        f"#let dlog_n = [{len(dlog)}]",
        f"#let dlog_mean = [{mean(dlog):.8f}]",
        f"#let dlog_var = [{variance_pop(dlog):.8f}]",
        f"#let acf_bound = [{1.96 / math.sqrt(len(dlog)):.4f}]",
        "#let acf_table = (",
    ]
    for k in range(11):
        lines.append(f"  ({k}, {gamma[k]:.8f}, {rho[k]:.8f}),")
    lines.append(")")
    summary_path.write_text("\n".join(lines) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
