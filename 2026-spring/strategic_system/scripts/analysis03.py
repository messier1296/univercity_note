from pathlib import Path

import pandas as pd
from scipy import stats

BASE_DIR = Path(__file__).resolve().parents[1]
CSV_PATH = BASE_DIR / "data" / "FEH_00450091_260414110315.csv"
ENCODING = "shift_jis"

SEX_COLUMN = "性別_基本"
REGION_COLUMN = "地域"
TARGET_COLUMNS = {
    "高卒": "高校 所定内給与額【千円】",
    "大卒": "大学 所定内給与額【千円】",
    "大学院卒": "大学院 所定内給与額【千円】",
}


def load_prefecture_data() -> pd.DataFrame:
    df = pd.read_csv(CSV_PATH, encoding=ENCODING)

    prefecture_df = df.loc[
        (df[SEX_COLUMN] == "男女計") & (df[REGION_COLUMN] != "全国"),
        [REGION_COLUMN, *TARGET_COLUMNS.values()],
    ].copy()

    for column in TARGET_COLUMNS.values():
        prefecture_df[column] = pd.to_numeric(prefecture_df[column], errors="coerce")

    return prefecture_df.dropna(subset=TARGET_COLUMNS.values())


def build_annual_income_groups(prefecture_df: pd.DataFrame) -> dict[str, pd.Series]:
    return {
        label: prefecture_df[column] * 12
        for label, column in TARGET_COLUMNS.items()
    }


def main() -> None:
    prefecture_df = load_prefecture_data()
    annual_income_groups = build_annual_income_groups(prefecture_df)

    print("対象: 男女計・全国を除く47都道府県")
    print("単位: 年収（万円）")
    print()
    print("学歴別の平均年収")
    for label, values in annual_income_groups.items():
        mean_man_yen = values.mean() / 10
        std_man_yen = values.std(ddof=1) / 10
        print(f"{label}: 平均 {mean_man_yen:.2f} 万円, 標準偏差 {std_man_yen:.2f} 万円")

    result = stats.f_oneway(*annual_income_groups.values())

    print()
    print("一元配置分散分析")
    print(f"F値: {result.statistic:.4f}")
    print(f"p値: {result.pvalue:.6f}")

    alpha = 0.05
    if result.pvalue < alpha:
        print("結論: 5%水準で学歴間の平均年収に有意な差がある。")
    else:
        print("結論: 5%水準で学歴間の平均年収に有意な差があるとはいえない。")


if __name__ == "__main__":
    main()
