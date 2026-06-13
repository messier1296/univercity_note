from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from scipy import stats

BASE_DIR = Path(__file__).resolve().parents[1]
WAGE_CSV_PATH = BASE_DIR / "data" / "FEH_00450091_260414110315.csv"
POPULATION_XLSX_PATH = BASE_DIR / "data" / "population_2023_estat.xlsx"
OUTPUT_PATH = BASE_DIR / "assets" / "multiple_regression_salary_population_education.png"
MERGED_OUTPUT_PATH = BASE_DIR / "data" / "analysis05_salary_population.csv"
ENCODING = "shift_jis"

REGION_COLUMN = "地域"
SEX_COLUMN = "性別_基本"
EDUCATION_COLUMNS = {
    "高卒": "高校 所定内給与額【千円】",
    "大卒": "大学 所定内給与額【千円】",
    "大学院卒": "大学院 所定内給与額【千円】",
}


def load_wage_data() -> pd.DataFrame:
    df = pd.read_csv(WAGE_CSV_PATH, encoding=ENCODING)
    target_df = df.loc[
        (df[SEX_COLUMN] == "男女計") & (df[REGION_COLUMN] != "全国"),
        [REGION_COLUMN, *EDUCATION_COLUMNS.values()],
    ].copy()

    for column in EDUCATION_COLUMNS.values():
        target_df[column] = pd.to_numeric(target_df[column], errors="coerce")

    long_df = target_df.melt(
        id_vars=[REGION_COLUMN],
        value_vars=list(EDUCATION_COLUMNS.values()),
        var_name="学歴",
        value_name="初任給_千円",
    )
    long_df["学歴"] = long_df["学歴"].map(
        {column: label for label, column in EDUCATION_COLUMNS.items()}
    )

    return long_df.rename(columns={REGION_COLUMN: "地域"})


def load_population_data() -> pd.DataFrame:
    df = pd.read_excel(
        POPULATION_XLSX_PATH,
        sheet_name="第５表",
        header=6,
        usecols=[7, 8, 10, 17],
    )
    df = df.rename(
        columns={
            "人口区分": "人口区分",
            "性別": "性別",
            "地域": "地域",
            "2023年": "人口_千人",
        }
    )
    population_df = df.loc[
        (df["人口区分"] == "総人口") & (df["性別"] == "男女計") & (df["地域"] != "全国"),
        ["地域", "人口_千人"],
    ].copy()
    population_df["地域"] = population_df["地域"].str.replace("\u3000", "", regex=False)
    population_df["人口_千人"] = pd.to_numeric(population_df["人口_千人"], errors="coerce")

    return population_df


def prepare_regression_data() -> pd.DataFrame:
    wage_df = load_wage_data()
    population_df = load_population_data()
    df = wage_df.merge(population_df, on="地域", how="inner").dropna()
    df["人口_対数"] = np.log(df["人口_千人"])
    df["大卒ダミー"] = (df["学歴"] == "大卒").astype(int)
    df["大学院卒ダミー"] = (df["学歴"] == "大学院卒").astype(int)
    df.to_csv(MERGED_OUTPUT_PATH, index=False)
    return df


def fit_ols(y: np.ndarray, x_without_const: np.ndarray, names: list[str]) -> dict[str, object]:
    n = len(y)
    x = np.column_stack([np.ones(n), x_without_const])
    p = x.shape[1]

    beta = np.linalg.inv(x.T @ x) @ x.T @ y
    fitted = x @ beta
    residuals = y - fitted

    sse = float(residuals.T @ residuals)
    sst = float(((y - y.mean()) ** 2).sum())
    ssr = sst - sse
    df_model = p - 1
    df_resid = n - p
    mse = sse / df_resid
    cov_beta = mse * np.linalg.inv(x.T @ x)
    se = np.sqrt(np.diag(cov_beta))
    t_values = beta / se
    p_values = 2 * stats.t.sf(np.abs(t_values), df_resid)
    r2 = 1 - sse / sst
    adj_r2 = 1 - (1 - r2) * (n - 1) / df_resid
    f_value = (ssr / df_model) / mse
    f_p_value = stats.f.sf(f_value, df_model, df_resid)

    standardized_x = (x_without_const - x_without_const.mean(axis=0)) / x_without_const.std(
        axis=0, ddof=1
    )
    standardized_y = (y - y.mean()) / y.std(ddof=1)
    standardized_beta = (
        np.linalg.inv(standardized_x.T @ standardized_x)
        @ standardized_x.T
        @ standardized_y
    )

    coef_df = pd.DataFrame(
        {
            "変数": ["定数", *names],
            "B": beta,
            "標準誤差": se,
            "標準偏回帰係数": [np.nan, *standardized_beta],
            "t値": t_values,
            "p値": p_values,
        }
    )

    return {
        "coef": coef_df,
        "n": n,
        "r2": r2,
        "adj_r2": adj_r2,
        "anova": {
            "回帰平方和": ssr,
            "残差平方和": sse,
            "全体平方和": sst,
            "回帰自由度": df_model,
            "残差自由度": df_resid,
            "全体自由度": n - 1,
            "F値": f_value,
            "p値": f_p_value,
        },
        "fitted": fitted,
        "residuals": residuals,
    }


def calculate_vif(df: pd.DataFrame, names: list[str]) -> pd.DataFrame:
    rows = []
    for name in names:
        other_names = [other for other in names if other != name]
        y = df[name].to_numpy(dtype=float)
        x = df[other_names].to_numpy(dtype=float)
        result = fit_ols(y, x, other_names)
        r2 = float(result["r2"])
        rows.append({"変数": name, "VIF": 1 / (1 - r2), "許容度": 1 - r2})
    return pd.DataFrame(rows)


def save_plot(df: pd.DataFrame, fitted: np.ndarray) -> None:
    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    plot_df = df.copy()
    plot_df["予測値"] = fitted

    colors = {"高卒": "#2f6f9f", "大卒": "#51946b", "大学院卒": "#b45f4d"}
    labels = {"高卒": "High school", "大卒": "University", "大学院卒": "Graduate"}

    fig, axes = plt.subplots(1, 2, figsize=(10, 4.2))
    for education, group in plot_df.groupby("学歴"):
        axes[0].scatter(
            group["人口_千人"],
            group["初任給_千円"],
            label=labels[education],
            color=colors[education],
            alpha=0.82,
        )
    axes[0].set_xscale("log")
    axes[0].set_xlabel("Population [thousand persons, log scale]")
    axes[0].set_ylabel("Monthly salary [thousand yen]")
    axes[0].set_title("Salary by Population and Education")
    axes[0].grid(alpha=0.25)
    axes[0].legend(title="Education")

    axes[1].scatter(plot_df["予測値"], plot_df["初任給_千円"], color="#3f4d63", alpha=0.78)
    lower = min(plot_df["予測値"].min(), plot_df["初任給_千円"].min())
    upper = max(plot_df["予測値"].max(), plot_df["初任給_千円"].max())
    axes[1].plot([lower, upper], [lower, upper], color="#b45f4d", linewidth=1.6)
    axes[1].set_xlabel("Predicted salary [thousand yen]")
    axes[1].set_ylabel("Observed salary [thousand yen]")
    axes[1].set_title("Observed vs. Predicted")
    axes[1].grid(alpha=0.25)

    fig.tight_layout()
    fig.savefig(OUTPUT_PATH, dpi=160)
    plt.close(fig)


def format_p(value: float) -> str:
    if value < 0.001:
        return "< .001"
    return f"{value:.3f}".lstrip("0")


def main() -> None:
    df = prepare_regression_data()
    predictor_names = ["人口_対数", "大卒ダミー", "大学院卒ダミー"]
    y = df["初任給_千円"].to_numpy(dtype=float)
    x = df[predictor_names].to_numpy(dtype=float)
    result = fit_ols(y, x, predictor_names)
    vif_df = calculate_vif(df, predictor_names)
    save_plot(df, result["fitted"])

    print("対象: 男女計、全国を除く47都道府県、学歴は高卒・大卒・大学院卒")
    print("従属変数: 初任給（所定内給与額、千円）")
    print("説明変数: 人口の自然対数、学歴ダミー（基準: 高卒）")
    print(f"件数: {result['n']}")
    print()
    print("学歴別の記述統計")
    summary = (
        df.groupby("学歴")["初任給_千円"]
        .agg(件数="count", 平均="mean", 標準偏差="std")
        .reindex(["高卒", "大卒", "大学院卒"])
    )
    print(summary.to_string(float_format=lambda value: f"{value:.2f}"))
    print()
    print("モデルの要約")
    print(f"R2 = {result['r2']:.6f}")
    print(f"調整済みR2 = {result['adj_r2']:.6f}")
    anova = result["anova"]
    print(
        f"F({anova['回帰自由度']}, {anova['残差自由度']}) = "
        f"{anova['F値']:.6f}, p = {format_p(anova['p値'])}"
    )
    print()
    print("係数")
    print(result["coef"].to_string(index=False, float_format=lambda value: f"{value:.6f}"))
    print()
    print("VIF")
    print(vif_df.to_string(index=False, float_format=lambda value: f"{value:.3f}"))
    print()
    print(f"結合データの出力先: {MERGED_OUTPUT_PATH}")
    print(f"図の出力先: {OUTPUT_PATH}")


if __name__ == "__main__":
    main()
