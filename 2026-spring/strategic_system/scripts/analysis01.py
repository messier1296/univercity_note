from pathlib import Path

import matplotlib.pyplot as plt
import pandas as pd

BASE_DIR = Path(__file__).resolve().parents[1]
CSV_PATH = BASE_DIR / "data" / "FEH_00450091_260414110315.csv"
OUTPUT_PATH = (
    BASE_DIR / "assets" / "histogram_all_industry_all_education_prefectures.png"
)
ENCODING = "shift_jis"
SEX_COLUMN = "性別_基本"
REGION_COLUMN = "地域"
VALUE_COLUMN = "大学 所定内給与額【千円】"


def load_prefecture_values() -> pd.DataFrame:
    df = pd.read_csv(CSV_PATH, encoding=ENCODING)
    df[VALUE_COLUMN] = pd.to_numeric(df[VALUE_COLUMN], errors="coerce")

    prefecture_df = df.loc[
        (df[SEX_COLUMN] == "男女計")
        & (df[REGION_COLUMN] != "全国")
        & df[VALUE_COLUMN].notna(),
        [REGION_COLUMN, VALUE_COLUMN],
    ].copy()

    return prefecture_df


def save_histogram(prefecture_df: pd.DataFrame) -> None:
    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)

    plt.figure(figsize=(10, 6))
    plt.hist(
        prefecture_df[VALUE_COLUMN],
        bins=10,
        color="#4C78A8",
        edgecolor="black",
        alpha=0.85,
    )
    plt.title("Histogram of Earnings\n(All Industries / All Education / Prefectures)")
    plt.xlabel("Earnings [thousand yen]")
    plt.ylabel("Number of prefectures")
    plt.grid(axis="y", alpha=0.3)
    plt.tight_layout()
    plt.savefig(OUTPUT_PATH, dpi=150)
    plt.close()


def main() -> None:
    prefecture_df = load_prefecture_values()

    mean_value = prefecture_df[VALUE_COLUMN].mean()
    std_value = prefecture_df[VALUE_COLUMN].std()

    save_histogram(prefecture_df)

    print(f"対象件数: {len(prefecture_df)}")
    print("対象: 全産業・全学歴・各都道府県（男女計）")
    print(f"平均: {mean_value:.2f}")
    print(f"標準偏差: {std_value:.2f}")
    print(f"ヒストグラム出力先: {OUTPUT_PATH}")


if __name__ == "__main__":
    main()
