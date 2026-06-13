from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from scipy import stats
from scipy.cluster.hierarchy import dendrogram, fcluster, linkage

BASE_DIR = Path(__file__).resolve().parents[1]
CSV_PATH = BASE_DIR / "data" / "FEH_00450091_260414110315.csv"
SUMMARY_OUTPUT_PATH = BASE_DIR / "data" / "analysis07_cluster_summary.csv"
MEMBERS_OUTPUT_PATH = BASE_DIR / "data" / "analysis07_cluster_members.csv"
DENDROGRAM_OUTPUT_PATH = BASE_DIR / "assets" / "cluster_analysis_dendrogram.png"
SCATTER_OUTPUT_PATH = BASE_DIR / "assets" / "cluster_analysis_salary_scatter.png"

ENCODING = "shift_jis"
SEX_COLUMN = "性別_基本"
REGION_COLUMN = "地域"
VALUE_COLUMN = "大学 所定内給与額【千円】"
CLUSTER_COUNT = 3

CLUSTER_LABELS = {
    1: "高年収群",
    2: "中年収群",
    3: "低年収群",
}
CLUSTER_COLORS = {
    "高年収群": "#b45f4d",
    "中年収群": "#4c78a8",
    "低年収群": "#51946b",
}


def load_salary_data() -> pd.DataFrame:
    df = pd.read_csv(CSV_PATH, encoding=ENCODING)
    df[VALUE_COLUMN] = pd.to_numeric(df[VALUE_COLUMN], errors="coerce")

    salary_df = df.loc[
        (df[SEX_COLUMN] == "男女計")
        & (df[REGION_COLUMN] != "全国")
        & df[VALUE_COLUMN].notna(),
        [REGION_COLUMN, VALUE_COLUMN],
    ].copy()
    salary_df = salary_df.rename(
        columns={REGION_COLUMN: "都道府県", VALUE_COLUMN: "月額給与_千円"}
    )
    salary_df["年収_千円"] = salary_df["月額給与_千円"] * 12
    return salary_df.reset_index(drop=True)


def assign_clusters(df: pd.DataFrame) -> tuple[pd.DataFrame, np.ndarray]:
    standardized = (
        (df[["年収_千円"]] - df[["年収_千円"]].mean())
        / df[["年収_千円"]].std(ddof=0)
    )
    linkage_matrix = linkage(standardized.to_numpy(), method="ward")
    raw_clusters = fcluster(linkage_matrix, CLUSTER_COUNT, criterion="maxclust")

    result_df = df.copy()
    result_df["raw_cluster"] = raw_clusters

    means = (
        result_df.groupby("raw_cluster")["年収_千円"]
        .mean()
        .sort_values(ascending=False)
    )
    label_map = {
        raw_cluster: CLUSTER_LABELS[index + 1]
        for index, raw_cluster in enumerate(means.index)
    }
    result_df["クラスター"] = result_df["raw_cluster"].map(label_map)
    result_df = result_df.drop(columns=["raw_cluster"])
    return result_df, linkage_matrix


def summarize_clusters(df: pd.DataFrame) -> pd.DataFrame:
    summary = (
        df.groupby("クラスター")["年収_千円"]
        .agg(都道府県数="count", 平均="mean", 分散="var", 最小値="min", 最大値="max")
        .reindex(["高年収群", "中年収群", "低年収群"])
        .round(2)
    )
    summary["所属都道府県"] = (
        df.sort_values("年収_千円", ascending=False)
        .groupby("クラスター")["都道府県"]
        .apply("、".join)
        .reindex(summary.index)
    )
    return summary.reset_index()


def run_anova(df: pd.DataFrame) -> tuple[float, float]:
    groups = [
        group["年収_千円"].to_numpy(dtype=float)
        for _, group in df.groupby("クラスター", sort=False)
    ]
    f_value, p_value = stats.f_oneway(*groups)
    return float(f_value), float(p_value)


def save_dendrogram(df: pd.DataFrame, linkage_matrix: np.ndarray) -> None:
    DENDROGRAM_OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    plt.rcParams["font.family"] = ["Noto Sans CJK JP", "Noto Serif CJK JP", "sans-serif"]

    fig, ax = plt.subplots(figsize=(11, 6.2))
    dendrogram(
        linkage_matrix,
        labels=df["都道府県"].tolist(),
        leaf_rotation=90,
        leaf_font_size=8,
        color_threshold=4.6,
        ax=ax,
    )
    ax.set_title("Dendrogram of Prefectures by University Graduate Annual Salary")
    ax.set_xlabel("Prefecture")
    ax.set_ylabel("Ward distance")
    ax.grid(axis="y", alpha=0.25)
    fig.tight_layout()
    fig.savefig(DENDROGRAM_OUTPUT_PATH, dpi=180)
    plt.close(fig)


def save_scatter(df: pd.DataFrame) -> None:
    SCATTER_OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    plt.rcParams["font.family"] = ["Noto Sans CJK JP", "Noto Serif CJK JP", "sans-serif"]

    plot_df = df.sort_values("年収_千円").reset_index(drop=True)
    colors = plot_df["クラスター"].map(CLUSTER_COLORS)

    fig, ax = plt.subplots(figsize=(11, 5.8))
    ax.scatter(plot_df.index + 1, plot_df["年収_千円"], c=colors, s=56, alpha=0.88)
    for index, row in plot_df.iterrows():
        ax.text(
            index + 1,
            row["年収_千円"] + 10,
            row["都道府県"],
            rotation=90,
            ha="center",
            va="bottom",
            fontsize=7.5,
        )

    for label, color in CLUSTER_COLORS.items():
        ax.scatter([], [], color=color, label=label, s=56)
    ax.set_title("University Graduate Annual Salary by Cluster")
    ax.set_xlabel("Prefectures ordered by annual salary")
    ax.set_ylabel("Annual salary [thousand yen]")
    ax.set_xticks([])
    ax.set_ylim(plot_df["年収_千円"].min() - 40, plot_df["年収_千円"].max() + 170)
    ax.grid(axis="y", alpha=0.25)
    ax.legend(title="Cluster", loc="upper left")
    fig.tight_layout()
    fig.savefig(SCATTER_OUTPUT_PATH, dpi=180)
    plt.close(fig)


def main() -> None:
    salary_df = load_salary_data()
    clustered_df, linkage_matrix = assign_clusters(salary_df)
    summary_df = summarize_clusters(clustered_df)
    f_value, p_value = run_anova(clustered_df)

    clustered_df.sort_values(["クラスター", "年収_千円"], ascending=[True, False]).to_csv(
        MEMBERS_OUTPUT_PATH, index=False
    )
    summary_df.to_csv(SUMMARY_OUTPUT_PATH, index=False)
    save_dendrogram(salary_df, linkage_matrix)
    save_scatter(clustered_df)

    print("対象: 2023年・男女計・大学卒・全国除外の47都道府県")
    print("年収: 大学 所定内給与額【千円】 × 12")
    print("分析: 年収を標準化し、Ward法で階層的クラスター分析")
    print(f"クラスター数: {CLUSTER_COUNT}")
    print()
    print(summary_df.to_string(index=False))
    print()
    print(f"一元配置分散分析: F(2, 44) = {f_value:.2f}, p = {p_value:.6g}")
    print(f"集計表: {SUMMARY_OUTPUT_PATH}")
    print(f"所属表: {MEMBERS_OUTPUT_PATH}")
    print(f"デンドログラム: {DENDROGRAM_OUTPUT_PATH}")
    print(f"散布図: {SCATTER_OUTPUT_PATH}")


if __name__ == "__main__":
    main()
