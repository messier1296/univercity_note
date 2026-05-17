from pathlib import Path

import matplotlib.pyplot as plt
import pandas as pd
from scipy import stats

BASE_DIR = Path(__file__).resolve().parents[1]
CSV_PATH = BASE_DIR / "data" / "FEH_00450091_260414110315.csv"
OUTPUT_PATH = BASE_DIR / "assets" / "two_way_anova_gender_education.png"
ENCODING = "shift_jis"

SEX_COLUMN = "性別_基本"
REGION_COLUMN = "地域"
TARGET_COLUMNS = {
    "大卒": "大学 所定内給与額【千円】",
    "大学院卒": "大学院 所定内給与額【千円】",
}
SEXES = ["男", "女"]


def load_long_data() -> pd.DataFrame:
    df = pd.read_csv(CSV_PATH, encoding=ENCODING)

    target_df = df.loc[
        df[SEX_COLUMN].isin(SEXES) & (df[REGION_COLUMN] != "全国"),
        [SEX_COLUMN, REGION_COLUMN, *TARGET_COLUMNS.values()],
    ].copy()

    for column in TARGET_COLUMNS.values():
        target_df[column] = pd.to_numeric(target_df[column], errors="coerce")

    long_df = target_df.melt(
        id_vars=[SEX_COLUMN, REGION_COLUMN],
        value_vars=list(TARGET_COLUMNS.values()),
        var_name="学歴",
        value_name="所定内給与額",
    )
    long_df["学歴"] = long_df["学歴"].map(
        {column: label for label, column in TARGET_COLUMNS.items()}
    )

    complete_regions = (
        long_df.dropna(subset=["所定内給与額"])
        .groupby(REGION_COLUMN)
        .filter(lambda x: len(x) == len(SEXES) * len(TARGET_COLUMNS))[REGION_COLUMN]
        .unique()
    )

    return long_df.loc[long_df[REGION_COLUMN].isin(complete_regions)].rename(
        columns={SEX_COLUMN: "性別", REGION_COLUMN: "地域"}
    )


def two_way_anova(df: pd.DataFrame) -> pd.DataFrame:
    grand_mean = df["所定内給与額"].mean()
    sexes = list(df["性別"].drop_duplicates())
    educations = list(df["学歴"].drop_duplicates())

    sex_means = df.groupby("性別")["所定内給与額"].mean()
    education_means = df.groupby("学歴")["所定内給与額"].mean()
    cell_stats = df.groupby(["性別", "学歴"])["所定内給与額"].agg(["mean", "count"])

    ss_sex = sum(
        len(df.loc[df["性別"] == sex]) * (sex_means[sex] - grand_mean) ** 2
        for sex in sexes
    )
    ss_education = sum(
        len(df.loc[df["学歴"] == education])
        * (education_means[education] - grand_mean) ** 2
        for education in educations
    )
    ss_interaction = sum(
        cell_stats.loc[(sex, education), "count"]
        * (
            cell_stats.loc[(sex, education), "mean"]
            - sex_means[sex]
            - education_means[education]
            + grand_mean
        )
        ** 2
        for sex in sexes
        for education in educations
    )
    ss_total = ((df["所定内給与額"] - grand_mean) ** 2).sum()
    ss_error = ss_total - ss_sex - ss_education - ss_interaction

    df_sex = len(sexes) - 1
    df_education = len(educations) - 1
    df_interaction = df_sex * df_education
    df_error = len(df) - len(sexes) * len(educations)

    ms_error = ss_error / df_error
    rows = [
        ("性別", ss_sex, df_sex),
        ("学歴", ss_education, df_education),
        ("性別×学歴", ss_interaction, df_interaction),
        ("誤差", ss_error, df_error),
        ("全体", ss_total, len(df) - 1),
    ]

    result_df = pd.DataFrame(rows, columns=["要因", "平方和", "自由度"])
    result_df["平均平方"] = result_df["平方和"] / result_df["自由度"]
    result_df.loc[result_df["要因"].isin(["誤差", "全体"]), "平均平方"] = pd.NA

    for index, row in result_df.iterrows():
        if row["要因"] in ["誤差", "全体"]:
            result_df.loc[index, "F値"] = pd.NA
            result_df.loc[index, "p値"] = pd.NA
            continue

        f_value = row["平均平方"] / ms_error
        result_df.loc[index, "F値"] = f_value
        result_df.loc[index, "p値"] = stats.f.sf(f_value, row["自由度"], df_error)

    return result_df


def save_interaction_plot(summary_df: pd.DataFrame) -> None:
    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)

    plot_df = summary_df.pivot(index="学歴", columns="性別", values="平均")
    plot_df = plot_df.loc[["大卒", "大学院卒"], SEXES]
    plot_df = plot_df.rename(index={"大卒": "University", "大学院卒": "Graduate"})
    label_map = {"男": "Male", "女": "Female"}

    plt.figure(figsize=(7, 4.8))
    for sex in SEXES:
        plt.plot(
            plot_df.index,
            plot_df[sex],
            marker="o",
            linewidth=2,
            markersize=7,
            label=label_map[sex],
        )

    plt.title("Monthly Scheduled Earnings by Gender and Education")
    plt.xlabel("Education")
    plt.ylabel("Earnings [thousand yen]")
    plt.grid(axis="y", alpha=0.3)
    plt.legend(title="Gender")
    plt.tight_layout()
    plt.savefig(OUTPUT_PATH, dpi=150)
    plt.close()


def main() -> None:
    long_df = load_long_data()
    summary_df = (
        long_df.groupby(["性別", "学歴"])["所定内給与額"]
        .agg(件数="count", 平均="mean", 標準偏差="std")
        .reset_index()
    )
    anova_df = two_way_anova(long_df)
    save_interaction_plot(summary_df)

    print("対象: 男・女、全国を除く都道府県のうち4条件がそろう44都道府県")
    print("単位: 所定内給与額（千円）")
    print()
    print("性別・学歴別の記述統計")
    print(summary_df.to_string(index=False, float_format=lambda x: f"{x:.2f}"))
    print()
    print("二元配置分散分析")
    print(anova_df.to_string(index=False, float_format=lambda x: f"{x:.6f}"))
    print()
    print(f"図の出力先: {OUTPUT_PATH}")


if __name__ == "__main__":
    main()
