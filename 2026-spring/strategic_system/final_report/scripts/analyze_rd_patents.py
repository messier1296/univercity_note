from __future__ import annotations

from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from scipy import stats


ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "data" / "jpo_ip_activity_2025_industry_rd_patents_2024_analysis_ready.csv"
ASSETS = ROOT / "assets"
RESULTS = ROOT / "data" / "jpo_ip_activity_2025_industry_rd_patents_analysis_results.csv"


def setup_plot() -> None:
    plt.rcParams["font.family"] = "Noto Sans CJK JP"
    plt.rcParams["axes.unicode_minus"] = False
    plt.rcParams["figure.dpi"] = 120
    plt.rcParams["savefig.dpi"] = 220


def regression_summary(x: np.ndarray, y: np.ndarray) -> dict[str, float]:
    reg = stats.linregress(x, y)
    return {
        "slope": float(reg.slope),
        "intercept": float(reg.intercept),
        "r": float(reg.rvalue),
        "r2": float(reg.rvalue**2),
        "p": float(reg.pvalue),
        "stderr": float(reg.stderr),
        "intercept_stderr": float(reg.intercept_stderr),
    }


def add_regression_line(ax: plt.Axes, x: np.ndarray, summary: dict[str, float]) -> None:
    xs = np.linspace(x.min(), x.max(), 200)
    ys = summary["intercept"] + summary["slope"] * xs
    ax.plot(xs, ys, color="#c43c39", linewidth=2.2, label="回帰直線")


def plot_raw(df: pd.DataFrame, summary: dict[str, float]) -> None:
    fig, ax = plt.subplots(figsize=(7.4, 5.0))
    x = df["rd_100m_yen"].to_numpy()
    y = df["domestic_patent_applications_2024"].to_numpy()
    ax.scatter(x, y, s=46, color="#276fbf", alpha=0.86)

    xs = np.linspace(x.min(), x.max(), 200)
    ys = summary["intercept"] + summary["slope"] * (xs * 100)
    ax.plot(xs, ys, color="#c43c39", linewidth=2.0)

    for _, row in df.iterrows():
        if row["industry"] in {"電気機械製造業", "輸送機械製造業", "その他の非製造業", "教育・TLO・公的研究機関・公務"}:
            ax.annotate(
                row["industry"],
                (row["rd_100m_yen"], row["domestic_patent_applications_2024"]),
                xytext=(5, 5),
                textcoords="offset points",
                fontsize=8,
            )

    ax.set_xlabel("研究費（億円）")
    ax.set_ylabel("国内特許出願件数（2024年実績）")
    ax.set_title("産業別の研究費と国内特許出願件数")
    ax.grid(True, color="#d8dee8", linewidth=0.8, alpha=0.8)
    ax.text(
        0.02,
        0.96,
        f"$R^2$ = {summary['r2']:.3f}, p = {summary['p']:.3f}",
        transform=ax.transAxes,
        ha="left",
        va="top",
        fontsize=10,
        bbox={"facecolor": "white", "edgecolor": "#cfd6e3", "boxstyle": "round,pad=0.25"},
    )
    fig.tight_layout()
    fig.savefig(ASSETS / "rd_patents_raw_scatter.png")
    plt.close(fig)


def plot_log(df: pd.DataFrame, summary: dict[str, float]) -> None:
    fig, ax = plt.subplots(figsize=(7.4, 5.0))
    x = df["log_rd"].to_numpy()
    y = df["log_patents"].to_numpy()
    ax.scatter(x, y, s=46, color="#276fbf", alpha=0.86)
    add_regression_line(ax, x, summary)

    labeled = {
        "電気機械製造業",
        "輸送機械製造業",
        "教育・TLO・公的研究機関・公務",
        "その他の非製造業",
        "その他の製造業",
        "医薬品製造業",
        "卸売・小売等",
    }
    for _, row in df[df["industry"].isin(labeled)].iterrows():
        ax.annotate(
            row["industry"],
            (row["log_rd"], row["log_patents"]),
            xytext=(5, 4),
            textcoords="offset points",
            fontsize=8,
        )

    ax.set_xlabel("log10(研究費)")
    ax.set_ylabel("log10(国内特許出願件数)")
    ax.set_title("対数変換後の研究費と国内特許出願件数")
    ax.set_xlim(x.min() - 0.08, x.max() + 0.38)
    ax.set_ylim(y.min() - 0.08, y.max() + 0.10)
    ax.grid(True, color="#d8dee8", linewidth=0.8, alpha=0.8)
    ax.text(
        0.02,
        0.96,
        f"$R^2$ = {summary['r2']:.3f}, p = {summary['p']:.3f}",
        transform=ax.transAxes,
        ha="left",
        va="top",
        fontsize=10,
        bbox={"facecolor": "white", "edgecolor": "#cfd6e3", "boxstyle": "round,pad=0.25"},
    )
    fig.tight_layout()
    fig.savefig(ASSETS / "rd_patents_log_regression.png")
    plt.close(fig)


def plot_efficiency(df: pd.DataFrame) -> None:
    sorted_df = df.sort_values("patent_applications_per_100m_yen_rd", ascending=True)
    colors = np.where(sorted_df["patent_applications_per_100m_yen_rd"] >= sorted_df["patent_applications_per_100m_yen_rd"].median(), "#2f8f6f", "#8a96a8")

    fig, ax = plt.subplots(figsize=(7.4, 6.2))
    ax.barh(sorted_df["industry"], sorted_df["patent_applications_per_100m_yen_rd"], color=colors)
    ax.set_xlabel("研究費1億円あたりの国内特許出願件数")
    ax.set_title("研究費あたりの国内特許出願件数")
    ax.grid(True, axis="x", color="#d8dee8", linewidth=0.8, alpha=0.8)
    fig.tight_layout()
    fig.savefig(ASSETS / "rd_patents_efficiency_bar.png")
    plt.close(fig)


def main() -> None:
    setup_plot()
    ASSETS.mkdir(exist_ok=True)

    df = pd.read_csv(DATA)
    df["rd_100m_yen"] = df["rd_expenditure_million_yen"] / 100
    df["log_rd"] = np.log10(df["rd_expenditure_million_yen"])
    df["log_patents"] = np.log10(df["domestic_patent_applications_2024"])

    raw_summary = regression_summary(
        df["rd_expenditure_million_yen"].to_numpy(),
        df["domestic_patent_applications_2024"].to_numpy(),
    )
    log_summary = regression_summary(df["log_rd"].to_numpy(), df["log_patents"].to_numpy())

    df["log_predicted_patents"] = log_summary["intercept"] + log_summary["slope"] * df["log_rd"]
    df["predicted_patents_log_model"] = 10 ** df["log_predicted_patents"]
    df["residual_log_model"] = df["log_patents"] - df["log_predicted_patents"]
    df.to_csv(RESULTS, index=False, encoding="utf-8-sig")

    plot_raw(df, raw_summary)
    plot_log(df, log_summary)
    plot_efficiency(df)

    print("raw model")
    print(raw_summary)
    print("log-log model")
    print(log_summary)
    print("top efficiency")
    print(
        df.sort_values("patent_applications_per_100m_yen_rd", ascending=False)[
            ["industry", "patent_applications_per_100m_yen_rd"]
        ]
        .head(5)
        .to_string(index=False)
    )


if __name__ == "__main__":
    main()
