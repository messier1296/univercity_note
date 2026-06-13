from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from scipy import stats

BASE_DIR = Path(__file__).resolve().parents[1]
CSV_PATH = BASE_DIR / "data" / "FEH_00450091_260414110315.csv"
OUTPUT_PATH = BASE_DIR / "assets" / "discriminant_salary_education.png"
ENCODING = "shift_jis"

SEX_COLUMN = "性別_基本"
REGION_COLUMN = "地域"
TARGET_COLUMNS = {
    "大卒": "大学 所定内給与額【千円】",
    "大学院卒": "大学院 所定内給与額【千円】",
}


def load_salary_data() -> pd.DataFrame:
    df = pd.read_csv(CSV_PATH, encoding=ENCODING)
    target_df = df.loc[
        (df[SEX_COLUMN] == "男女計") & (df[REGION_COLUMN] != "全国"),
        [REGION_COLUMN, *TARGET_COLUMNS.values()],
    ].copy()

    for column in TARGET_COLUMNS.values():
        target_df[column] = pd.to_numeric(target_df[column], errors="coerce")

    long_df = target_df.melt(
        id_vars=[REGION_COLUMN],
        value_vars=list(TARGET_COLUMNS.values()),
        var_name="学歴",
        value_name="所定内給与額",
    ).dropna(subset=["所定内給与額"])
    long_df["学歴"] = long_df["学歴"].map(
        {column: label for label, column in TARGET_COLUMNS.items()}
    )
    return long_df.rename(columns={REGION_COLUMN: "地域"})


def discriminant_analysis(df: pd.DataFrame) -> dict[str, float | pd.DataFrame]:
    groups = ["大卒", "大学院卒"]
    values = {group: df.loc[df["学歴"] == group, "所定内給与額"] for group in groups}
    n_by_group = {group: len(values[group]) for group in groups}
    means = {group: values[group].mean() for group in groups}
    variances = {group: values[group].var(ddof=1) for group in groups}

    n_total = sum(n_by_group.values())
    p = 1
    g = len(groups)
    pooled_variance = sum(
        (n_by_group[group] - 1) * variances[group] for group in groups
    ) / (n_total - g)
    pooled_sd = np.sqrt(pooled_variance)

    coefficient = (means["大学院卒"] - means["大卒"]) / pooled_variance
    constant = -0.5 * coefficient * (means["大学院卒"] + means["大卒"])
    standardized_coefficient = coefficient * pooled_sd

    between_ss = sum(
        n_by_group[group] * (means[group] - df["所定内給与額"].mean()) ** 2
        for group in groups
    )
    eigenvalue = between_ss / ((n_total - g) * pooled_variance)
    canonical_correlation = np.sqrt(eigenvalue / (1 + eigenvalue))
    wilks_lambda = 1 / (1 + eigenvalue)
    chi_square = -(n_total - 1 - (p + g) / 2) * np.log(wilks_lambda)
    p_value = stats.chi2.sf(chi_square, p * (g - 1))

    predicted = np.where(
        coefficient * df["所定内給与額"] + constant >= 0,
        "大学院卒",
        "大卒",
    )
    result_df = df.copy()
    result_df["判別得点"] = coefficient * result_df["所定内給与額"] + constant
    result_df["予測学歴"] = predicted
    result_df["的中"] = result_df["学歴"] == result_df["予測学歴"]
    accuracy = result_df["的中"].mean()
    confusion_df = pd.crosstab(result_df["学歴"], result_df["予測学歴"])

    return {
        "summary": pd.DataFrame(
            [
                {
                    "学歴": group,
                    "件数": n_by_group[group],
                    "平均": means[group],
                    "標準偏差": values[group].std(ddof=1),
                    "重心": coefficient * means[group] + constant,
                }
                for group in groups
            ]
        ),
        "coefficient": coefficient,
        "constant": constant,
        "standardized_coefficient": standardized_coefficient,
        "eigenvalue": eigenvalue,
        "canonical_correlation": canonical_correlation,
        "wilks_lambda": wilks_lambda,
        "chi_square": chi_square,
        "p_value": p_value,
        "accuracy": accuracy,
        "result": result_df,
        "confusion": confusion_df,
    }


def save_plot(result_df: pd.DataFrame) -> None:
    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    plot_df = result_df.sort_values(["学歴", "所定内給与額"]).reset_index(drop=True)
    color_map = {"大卒": "#4C78A8", "大学院卒": "#F58518"}

    plt.figure(figsize=(9, 4.8))
    for group, group_df in plot_df.groupby("学歴"):
        y = np.full(len(group_df), 0 if group == "大卒" else 1)
        label_map = {"大卒": "University", "大学院卒": "Graduate school"}
        plt.scatter(
            group_df["所定内給与額"],
            y,
            s=58,
            alpha=0.82,
            color=color_map[group],
            edgecolor="white",
            linewidth=0.6,
            label=label_map[group],
        )

    threshold = plot_df.loc[plot_df["判別得点"].abs().idxmin(), "所定内給与額"]
    plt.axvline(threshold, color="#333333", linestyle="--", linewidth=1.5)
    plt.yticks([0, 1], ["University", "Graduate school"])
    plt.xlabel("Monthly scheduled earnings [thousand yen]")
    plt.title("Discriminant Analysis of Salary and Education")
    plt.grid(axis="x", alpha=0.25)
    plt.legend(title="Education")
    plt.tight_layout()
    plt.savefig(OUTPUT_PATH, dpi=150)
    plt.close()


def main() -> None:
    salary_df = load_salary_data()
    results = discriminant_analysis(salary_df)
    save_plot(results["result"])

    print("対象: 男女計・全国を除く47都道府県")
    print("単位: 所定内給与額（千円）")
    print()
    print("学歴別の記述統計とグループ重心")
    print(results["summary"].to_string(index=False, float_format=lambda x: f"{x:.3f}"))
    print()
    print("判別分析")
    print(f"固有値: {results['eigenvalue']:.6f}")
    print(f"正準相関係数: {results['canonical_correlation']:.6f}")
    print(f"Wilksのラムダ: {results['wilks_lambda']:.6f}")
    print(f"カイ二乗: {results['chi_square']:.6f}")
    print(f"有意確率: {results['p_value']:.6f}")
    print(f"標準判別係数: {results['standardized_coefficient']:.6f}")
    print(f"非標準化係数: {results['coefficient']:.6f}")
    print(f"定数: {results['constant']:.6f}")
    print(f"判別的中率: {results['accuracy'] * 100:.2f}%")
    print()
    print("分類結果")
    print(results["confusion"].to_string())
    print()
    print(f"図の出力先: {OUTPUT_PATH}")


if __name__ == "__main__":
    main()
