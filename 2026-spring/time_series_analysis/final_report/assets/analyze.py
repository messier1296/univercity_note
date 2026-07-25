# /// script
# requires-python = ">=3.12"
# dependencies = [
#   "matplotlib>=3.10",
#   "numpy>=2.2",
#   "pandas>=2.2",
#   "statsmodels>=0.14.6",
# ]
# ///

from __future__ import annotations

import warnings
from pathlib import Path

import matplotlib.dates as mdates
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import statsmodels.api as sm
from statsmodels.stats.diagnostic import (
    acorr_ljungbox,
    breaks_cusumolsresid,
)
from statsmodels.stats.stattools import jarque_bera
from statsmodels.tools.sm_exceptions import ConvergenceWarning
from statsmodels.tsa.arima.model import ARIMA
from statsmodels.tsa.stattools import acf, adfuller, coint, pacf

REPORT_DIR = Path(__file__).resolve().parents[1]
DATA_DIR = REPORT_DIR / "data"
RAW_PATH = DATA_DIR / "raw" / "boj_effective_exchange_rates.csv"
OUT_DIR = REPORT_DIR / "assets"
NOMINAL_CODE = "FX180110001"
REAL_CODE = "FX180110002"
EVALUATION_START = pd.Timestamp("2016-01-01")
TRAIN_END = pd.Timestamp("2015-12-01")

BLUE = "#1f77b4"
ORANGE = "#d95f02"
GREEN = "#2b8a3e"
RED = "#c43c39"
GRAY = "#526173"
GRID = "#d8dee8"

plt.rcParams.update(
    {
        "font.family": "Noto Sans CJK JP",
        "font.size": 10,
        "axes.edgecolor": GRAY,
        "axes.grid": True,
        "axes.unicode_minus": False,
        "grid.color": GRID,
        "grid.linewidth": 0.7,
        "legend.frameon": False,
        "svg.fonttype": "none",
    }
)


def load_data() -> tuple[pd.DataFrame, str]:
    lines = RAW_PATH.read_text(encoding="utf-8").splitlines()
    if not lines or lines[0] != "STATUS,200":
        raise ValueError("The BOJ API response did not return status 200.")
    header_row = next(
        i for i, line in enumerate(lines) if line.startswith("SERIES_CODE,")
    )
    raw = pd.read_csv(RAW_PATH, skiprows=header_row)
    required = {"SERIES_CODE", "SURVEY_DATES", "VALUES", "LAST_UPDATE"}
    if not required <= set(raw.columns):
        raise ValueError("Required columns are missing from the BOJ data.")

    raw["date"] = pd.to_datetime(
        raw["SURVEY_DATES"].astype(str), format="%Y%m", errors="raise"
    )
    raw["VALUES"] = pd.to_numeric(raw["VALUES"], errors="raise")
    levels = (
        raw.pivot(index="date", columns="SERIES_CODE", values="VALUES")
        .rename(columns={NOMINAL_CODE: "nominal", REAL_CODE: "real"})
        .sort_index()
        .asfreq("MS")
    )
    if list(levels.columns) != ["nominal", "real"]:
        levels = levels[["nominal", "real"]]
    if levels.isna().any().any() or len(levels) != 677:
        raise ValueError(
            "The expected 677 complete monthly observations were not found."
        )
    if not np.allclose(levels.loc["2020"].mean().to_numpy(), 100, atol=0.01):
        raise ValueError("The 2020=100 normalization could not be verified.")

    update = str(int(raw["LAST_UPDATE"].iloc[0]))
    update_label = f"{update[:4]}年{int(update[4:6])}月{int(update[6:])}日"
    return levels, update_label


def adf_summary(series: pd.Series) -> dict[str, float | int]:
    result = adfuller(series.dropna(), maxlag=12, regression="c", autolag="AIC")
    return {"stat": float(result[0]), "p": float(result[1]), "lag": int(result[2])}


def jp_month(date: pd.Timestamp) -> str:
    return f"{date.year}年{date.month}月"


def p_text(value: float) -> str:
    return "0.001未満" if value < 0.001 else f"{value:.3f}"


def save_figure(fig: plt.Figure, name: str) -> None:
    fig.tight_layout()
    fig.savefig(OUT_DIR / name, format="svg", bbox_inches="tight")
    plt.close(fig)


def plot_levels(levels: pd.DataFrame) -> None:
    fig, ax = plt.subplots(figsize=(10.2, 4.8))
    ax.plot(levels.index, levels["nominal"], color=BLUE, lw=1.7, label="名目")
    ax.plot(levels.index, levels["real"], color=ORANGE, lw=1.7, label="実質")
    ax.axhline(100, color=GRAY, lw=1, ls="--", label="2020年平均=100")
    ax.axvline(pd.Timestamp("1994-01-01"), color=GRAY, lw=1, ls=":")
    ax.text(
        pd.Timestamp("1994-08-01"),
        ax.get_ylim()[1] * 0.96,
        "1993年以前はNarrow系列で遡及",
        color=GRAY,
        va="top",
        fontsize=9,
    )
    ax.set_title("日本の名目・実質実効為替レート")
    ax.set_ylabel("指数（2020年平均=100）")
    ax.set_xlabel("")
    ax.xaxis.set_major_locator(mdates.YearLocator(10))
    ax.xaxis.set_major_formatter(mdates.DateFormatter("%Y"))
    ax.legend(ncol=3, loc="upper left")
    save_figure(fig, "effective_exchange_rates.svg")


def plot_gap_and_correlation(
    levels: pd.DataFrame, log_levels: pd.DataFrame, differences: pd.DataFrame
) -> pd.Series:
    gap = 100 * (log_levels["real"] - log_levels["nominal"])
    rolling_corr = differences["nominal"].rolling(120).corr(differences["real"])

    fig, axes = plt.subplots(2, 1, figsize=(10.2, 6.4), sharex=True)
    axes[0].plot(gap.index, gap, color=GREEN, lw=1.7)
    axes[0].axhline(0, color=GRAY, lw=1, ls="--")
    axes[0].set_title("名目と実質の長期乖離")
    axes[0].set_ylabel("100 × [log(実質) − log(名目)]")
    axes[0].axvline(pd.Timestamp("1994-01-01"), color=GRAY, lw=1, ls=":")

    axes[1].plot(rolling_corr.index, rolling_corr, color=BLUE, lw=1.7)
    axes[1].axhline(1, color=GRAY, lw=1, ls="--")
    axes[1].set_ylim(0.8, 1.01)
    axes[1].set_title("月次対数差分の120か月ローリング相関")
    axes[1].set_ylabel("相関係数")
    axes[1].xaxis.set_major_locator(mdates.YearLocator(10))
    axes[1].xaxis.set_major_formatter(mdates.DateFormatter("%Y"))
    save_figure(fig, "gap_and_rolling_correlation.svg")
    return rolling_corr


def plot_change_scatter(
    differences: pd.DataFrame, intercept: float, slope: float, corr: float, r2: float
) -> None:
    x = 100 * differences["nominal"]
    y = 100 * differences["real"]
    line_x = np.linspace(float(x.min()), float(x.max()), 200)
    line_y = 100 * intercept + slope * line_x

    fig, ax = plt.subplots(figsize=(6.8, 5.6))
    ax.scatter(x, y, s=15, color=BLUE, alpha=0.45, edgecolors="none")
    ax.plot(line_x, line_y, color=RED, lw=2, label="OLS回帰線")
    ax.axline((0, 0), slope=1, color=GRAY, lw=1, ls="--", label="45度線")
    ax.set_title("名目・実質実効為替レートの月次変化")
    ax.set_xlabel("名目の月次対数変化（%）")
    ax.set_ylabel("実質の月次対数変化（%）")
    ax.text(
        0.03,
        0.96,
        f"相関係数 = {corr:.3f}\n$R^2$ = {r2:.3f}",
        transform=ax.transAxes,
        va="top",
        bbox={"facecolor": "white", "edgecolor": GRID, "alpha": 0.9},
    )
    ax.legend(loc="lower right")
    save_figure(fig, "monthly_changes_scatter.svg")


def plot_correlogram(difference: pd.Series) -> tuple[np.ndarray, np.ndarray, float]:
    max_lag = 24
    acf_values = acf(difference, nlags=max_lag, fft=False)
    pacf_values = pacf(difference, nlags=max_lag, method="ywm")
    bound = 1.96 / np.sqrt(len(difference))
    lags = np.arange(1, max_lag + 1)

    fig, axes = plt.subplots(2, 1, figsize=(9.2, 6.0), sharex=True)
    for ax, values, title in (
        (axes[0], acf_values, "自己相関（ACF）"),
        (axes[1], pacf_values, "偏自己相関（PACF）"),
    ):
        ax.axhline(0, color=GRAY, lw=0.9)
        ax.axhline(bound, color=ORANGE, lw=1, ls="--")
        ax.axhline(-bound, color=ORANGE, lw=1, ls="--")
        ax.vlines(lags, 0, values[1:], color=BLUE, lw=2)
        ax.scatter(lags, values[1:], color=BLUE, s=13, zorder=3)
        ax.set_ylabel(title)
        ax.set_ylim(-0.22, 0.38)
    axes[0].set_title("実質実効為替レートの月次対数差分")
    axes[1].set_xlabel("ラグ（月）")
    axes[1].set_xticks(np.arange(1, max_lag + 1))
    save_figure(fig, "real_change_correlogram.svg")
    return acf_values, pacf_values, bound


def select_model(train: pd.Series) -> tuple[pd.DataFrame, tuple[int, int, int], str]:
    rows: list[dict[str, float | int | str | bool]] = []
    with warnings.catch_warnings():
        warnings.simplefilter("ignore", category=ConvergenceWarning)
        warnings.simplefilter("ignore", category=UserWarning)
        for trend in ("n", "t"):
            for p in range(4):
                for q in range(4):
                    try:
                        fit = ARIMA(train, order=(p, 1, q), trend=trend).fit()
                    except (ValueError, np.linalg.LinAlgError):
                        continue
                    converged = bool(fit.mle_retvals.get("converged", True))
                    rows.append(
                        {
                            "p": p,
                            "d": 1,
                            "q": q,
                            "trend": trend,
                            "aic": float(fit.aic),
                            "bic": float(fit.bic),
                            "converged": converged,
                        }
                    )
    table = pd.DataFrame(rows)
    valid = table.loc[table["converged"]].sort_values("aic")
    best = valid.iloc[0]
    order = (int(best["p"]), 1, int(best["q"]))
    trend = str(best["trend"])
    if order != (1, 1, 0) or trend != "n":
        raise ValueError(f"Unexpected selected model: {order}, trend={trend}")
    return table, order, trend


def rolling_forecast(
    log_real: pd.Series, order: tuple[int, int, int], trend: str
) -> pd.DataFrame:
    start = log_real.index.get_loc(EVALUATION_START)
    records: list[dict[str, float | pd.Timestamp]] = []
    with warnings.catch_warnings():
        warnings.simplefilter("ignore", category=ConvergenceWarning)
        for i in range(start, len(log_real)):
            train = log_real.iloc[:i]
            actual_log = float(log_real.iloc[i])
            random_walk_log = float(train.iloc[-1])
            fit = ARIMA(train, order=order, trend=trend).fit()
            result = fit.get_forecast(steps=1)
            predicted_log = float(result.predicted_mean.iloc[0])
            interval = result.conf_int(alpha=0.05).iloc[0]
            records.append(
                {
                    "date": log_real.index[i],
                    "actual_log": actual_log,
                    "random_walk_log": random_walk_log,
                    "arima_log": predicted_log,
                    "lower_log": float(interval.iloc[0]),
                    "upper_log": float(interval.iloc[1]),
                }
            )
    result = pd.DataFrame(records).set_index("date")
    for name in ("actual", "random_walk", "arima", "lower", "upper"):
        result[name] = np.exp(result[f"{name}_log"])
    return result


def forecast_metrics(forecasts: pd.DataFrame) -> dict[str, float]:
    metrics: dict[str, float] = {}
    for model in ("random_walk", "arima"):
        log_error = forecasts["actual_log"] - forecasts[f"{model}_log"]
        level_error = forecasts["actual"] - forecasts[model]
        metrics[f"{model}_log_rmse"] = float(np.sqrt(np.mean(log_error**2)))
        metrics[f"{model}_log_mae"] = float(np.mean(np.abs(log_error)))
        metrics[f"{model}_rmse"] = float(np.sqrt(np.mean(level_error**2)))
        metrics[f"{model}_mae"] = float(np.mean(np.abs(level_error)))
    metrics["rmse_improvement"] = 1 - (
        metrics["arima_rmse"] / metrics["random_walk_rmse"]
    )
    metrics["mae_improvement"] = 1 - (metrics["arima_mae"] / metrics["random_walk_mae"])
    metrics["coverage"] = float(
        np.mean(
            (forecasts["actual_log"] >= forecasts["lower_log"])
            & (forecasts["actual_log"] <= forecasts["upper_log"])
        )
    )
    previous = forecasts["random_walk_log"]
    metrics["direction_accuracy"] = float(
        np.mean(
            np.sign(forecasts["actual_log"] - previous)
            == np.sign(forecasts["arima_log"] - previous)
        )
    )
    loss_difference = (forecasts["actual_log"] - forecasts["random_walk_log"]) ** 2 - (
        forecasts["actual_log"] - forecasts["arima_log"]
    ) ** 2
    loss_test = sm.OLS(
        loss_difference.to_numpy(), np.ones((len(loss_difference), 1))
    ).fit(cov_type="HAC", cov_kwds={"maxlags": 12})
    metrics["loss_difference"] = float(loss_difference.mean())
    metrics["loss_test_stat"] = float(loss_test.tvalues[0])
    metrics["loss_test_p"] = float(loss_test.pvalues[0])
    return metrics


def plot_forecast_evaluation(
    forecasts: pd.DataFrame, metrics: dict[str, float]
) -> None:
    fig, axes = plt.subplots(2, 1, figsize=(10.2, 6.4), sharex=True)
    axes[0].plot(
        forecasts.index, forecasts["actual"], color="#1d2433", lw=1.8, label="実績"
    )
    axes[0].plot(forecasts.index, forecasts["arima"], color=BLUE, lw=1.2, label="ARIMA")
    axes[0].plot(
        forecasts.index,
        forecasts["random_walk"],
        color=ORANGE,
        lw=1,
        ls="--",
        label="ランダムウォーク",
    )
    axes[0].set_title("1か月先擬似予測（2016年1月以降）")
    axes[0].set_ylabel("実質実効為替レート")
    axes[0].legend(ncol=3, loc="upper right")

    arima_error = forecasts["actual"] - forecasts["arima"]
    rw_error = forecasts["actual"] - forecasts["random_walk"]
    axes[1].plot(forecasts.index, arima_error, color=BLUE, lw=1.1, label="ARIMA誤差")
    axes[1].plot(
        forecasts.index, rw_error, color=ORANGE, lw=1, alpha=0.75, label="RW誤差"
    )
    axes[1].axhline(0, color=GRAY, lw=0.9)
    axes[1].set_title(
        f"予測誤差（実績－予測）: RMSE改善 {100 * metrics['rmse_improvement']:.1f}%"
    )
    axes[1].set_ylabel("指数ポイント")
    axes[1].legend(ncol=2, loc="upper right")
    axes[1].xaxis.set_major_locator(mdates.YearLocator(2))
    axes[1].xaxis.set_major_formatter(mdates.DateFormatter("%Y"))
    save_figure(fig, "forecast_evaluation.svg")


def plot_future_forecast(
    levels: pd.DataFrame, forecast: pd.DataFrame, last_observed: pd.Timestamp
) -> None:
    recent = levels["real"].loc[last_observed - pd.DateOffset(months=71) :]
    fig, ax = plt.subplots(figsize=(9.4, 4.8))
    ax.plot(recent.index, recent, color="#1d2433", lw=1.8, label="実績")
    ax.plot(forecast.index, forecast["point"], color=BLUE, lw=1.8, label="点予測")
    ax.fill_between(
        forecast.index,
        forecast["lower"],
        forecast["upper"],
        color=BLUE,
        alpha=0.18,
        label="95%予測区間",
    )
    ax.axvline(last_observed, color=GRAY, lw=1, ls="--")
    ax.set_title("実質実効為替レートの12か月先予測")
    ax.set_ylabel("指数（2020年平均=100）")
    ax.xaxis.set_major_locator(mdates.YearLocator(1))
    ax.xaxis.set_major_formatter(mdates.DateFormatter("%Y"))
    ax.legend(ncol=3, loc="upper right")
    save_figure(fig, "future_forecast.svg")


def write_summary(
    levels: pd.DataFrame,
    update_label: str,
    adf_results: dict[str, dict[str, float | int]],
    coint_result: tuple[float, float, np.ndarray],
    regression: sm.regression.linear_model.RegressionResultsWrapper,
    beta_one_p: float,
    cusum_result: tuple[float, float, list[tuple[int, float]]],
    rolling_corr: pd.Series,
    acf_values: np.ndarray,
    bound: float,
    selection: pd.DataFrame,
    full_fit: object,
    diagnostics: pd.DataFrame,
    jb: tuple[float, float, float, float],
    forecasts: pd.DataFrame,
    metrics: dict[str, float],
    future: pd.DataFrame,
) -> None:
    def aic(p: int, q: int, trend: str = "n") -> float:
        row = selection.loc[
            (selection["p"] == p)
            & (selection["q"] == q)
            & (selection["trend"] == trend)
        ].iloc[0]
        return float(row["aic"])

    nominal = levels["nominal"]
    real = levels["real"]
    differences = np.log(levels).diff().dropna()
    gap_latest = 100 * (np.log(real.iloc[-1]) - np.log(nominal.iloc[-1]))
    lines = [
        f"#let sample-start = [{jp_month(levels.index[0])}]",
        f"#let sample-end = [{jp_month(levels.index[-1])}]",
        f"#let sample-n = [{len(levels)}]",
        f"#let data-last-update = [{update_label}]",
        f"#let nominal-latest = [{nominal.iloc[-1]:.2f}]",
        f"#let real-latest = [{real.iloc[-1]:.2f}]",
        f"#let nominal-min = [{nominal.min():.2f}]",
        f"#let nominal-min-date = [{jp_month(nominal.idxmin())}]",
        f"#let nominal-max = [{nominal.max():.2f}]",
        f"#let nominal-max-date = [{jp_month(nominal.idxmax())}]",
        f"#let real-min = [{real.min():.2f}]",
        f"#let real-min-date = [{jp_month(real.idxmin())}]",
        f"#let real-max = [{real.max():.2f}]",
        f"#let real-max-date = [{jp_month(real.idxmax())}]",
        f"#let gap-latest = [{gap_latest:.2f}]",
        f"#let level-correlation = [{levels.corr().iloc[0, 1]:.3f}]",
        f"#let change-correlation = [{differences.corr().iloc[0, 1]:.3f}]",
        f"#let rolling-correlation-latest = [{rolling_corr.dropna().iloc[-1]:.3f}]",
        f"#let change-alpha = [{100 * regression.params['const']:.3f}]",
        f"#let change-alpha-se = [{100 * regression.bse['const']:.3f}]",
        f"#let change-alpha-p = [{p_text(float(regression.pvalues['const']))}]",
        f"#let change-beta = [{regression.params['nominal']:.3f}]",
        f"#let change-beta-se = [{regression.bse['nominal']:.3f}]",
        f"#let change-beta-p = [{p_text(float(regression.pvalues['nominal']))}]",
        f"#let change-beta-one-p = [{p_text(beta_one_p)}]",
        f"#let change-r2 = [{regression.rsquared:.3f}]",
        f"#let change-cusum-stat = [{cusum_result[0]:.3f}]",
        f"#let change-cusum-p = [{p_text(cusum_result[1])}]",
        f"#let acf-one = [{acf_values[1]:.3f}]",
        f"#let acf-bound = [{bound:.3f}]",
        f"#let coint-stat = [{coint_result[0]:.3f}]",
        f"#let coint-p = [{coint_result[1]:.3f}]",
        f"#let aic-rw = [{aic(0, 0):.2f}]",
        f"#let aic-arima-110 = [{aic(1, 0):.2f}]",
        f"#let aic-arima-011 = [{aic(0, 1):.2f}]",
        f"#let aic-arima-012 = [{aic(0, 2):.2f}]",
        f"#let ar-one = [{float(full_fit.params['ar.L1']):.3f}]",
        f"#let ar-one-se = [{float(full_fit.bse['ar.L1']):.3f}]",
        f"#let ar-one-p = [{p_text(float(full_fit.pvalues['ar.L1']))}]",
        f"#let lb12-stat = [{diagnostics.loc[12, 'lb_stat']:.2f}]",
        f"#let lb12-p = [{diagnostics.loc[12, 'lb_pvalue']:.3f}]",
        f"#let lb24-stat = [{diagnostics.loc[24, 'lb_stat']:.2f}]",
        f"#let lb24-p = [{diagnostics.loc[24, 'lb_pvalue']:.3f}]",
        f"#let jb-stat = [{jb[0]:.2f}]",
        f"#let jb-p = [{p_text(jb[1])}]",
        f"#let evaluation-n = [{len(forecasts)}]",
        f"#let rw-rmse = [{metrics['random_walk_rmse']:.3f}]",
        f"#let rw-mae = [{metrics['random_walk_mae']:.3f}]",
        f"#let arima-rmse = [{metrics['arima_rmse']:.3f}]",
        f"#let arima-mae = [{metrics['arima_mae']:.3f}]",
        f"#let rmse-improvement = [{100 * metrics['rmse_improvement']:.1f}%]",
        f"#let mae-improvement = [{100 * metrics['mae_improvement']:.1f}%]",
        f"#let forecast-coverage = [{100 * metrics['coverage']:.1f}%]",
        f"#let direction-accuracy = [{100 * metrics['direction_accuracy']:.1f}%]",
        f"#let loss-test-stat = [{metrics['loss_test_stat']:.3f}]",
        f"#let loss-test-p = [{p_text(metrics['loss_test_p'])}]",
    ]
    for horizon in (1, 3, 6, 12):
        row = future.iloc[horizon - 1]
        forecast_date = jp_month(future.index[horizon - 1])
        lines.extend(
            [
                f"#let forecast-{horizon}-date = [{forecast_date}]",
                f"#let forecast-{horizon}-point = [{row['point']:.2f}]",
                f"#let forecast-{horizon}-lower = [{row['lower']:.2f}]",
                f"#let forecast-{horizon}-upper = [{row['upper']:.2f}]",
            ]
        )
    for name, key in (
        ("log-nominal", "log_nominal"),
        ("log-real", "log_real"),
        ("dlog-nominal", "dlog_nominal"),
        ("dlog-real", "dlog_real"),
        ("gap", "gap"),
    ):
        result = adf_results[key]
        lines.extend(
            [
                f"#let adf-{name}-stat = [{float(result['stat']):.3f}]",
                f"#let adf-{name}-p = [{p_text(float(result['p']))}]",
                f"#let adf-{name}-lag = [{int(result['lag'])}]",
            ]
        )
    (OUT_DIR / "summary.typ").write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    levels, update_label = load_data()
    levels.rename_axis("date").to_csv(DATA_DIR / "boj_effective_exchange_rates.csv")

    log_levels = np.log(levels)
    differences = log_levels.diff().dropna()
    gap = log_levels["real"] - log_levels["nominal"]
    adf_results = {
        "log_nominal": adf_summary(log_levels["nominal"]),
        "log_real": adf_summary(log_levels["real"]),
        "dlog_nominal": adf_summary(differences["nominal"]),
        "dlog_real": adf_summary(differences["real"]),
        "gap": adf_summary(gap),
    }
    coint_result = coint(
        log_levels["real"],
        log_levels["nominal"],
        trend="c",
        maxlag=12,
        autolag="aic",
    )

    design = sm.add_constant(differences["nominal"])
    regression = sm.OLS(differences["real"], design).fit(
        cov_type="HAC", cov_kwds={"maxlags": 12}
    )
    beta_one_p = float(regression.t_test("nominal = 1").pvalue)
    cusum_result = breaks_cusumolsresid(regression.resid, ddof=2)

    plot_levels(levels)
    rolling_corr = plot_gap_and_correlation(levels, log_levels, differences)
    plot_change_scatter(
        differences,
        float(regression.params["const"]),
        float(regression.params["nominal"]),
        float(differences.corr().iloc[0, 1]),
        float(regression.rsquared),
    )
    acf_values, _, bound = plot_correlogram(differences["real"])

    training = log_levels["real"].loc[:TRAIN_END]
    selection, order, trend = select_model(training)
    full_fit = ARIMA(log_levels["real"], order=order, trend=trend).fit()
    residuals = full_fit.resid.iloc[1:]
    diagnostics = acorr_ljungbox(residuals, lags=[12, 24], model_df=1, return_df=True)
    jb = jarque_bera(residuals)

    forecasts = rolling_forecast(log_levels["real"], order, trend)
    metrics = forecast_metrics(forecasts)
    plot_forecast_evaluation(forecasts, metrics)

    future_result = full_fit.get_forecast(steps=12)
    future_interval = future_result.conf_int(alpha=0.05)
    future = pd.DataFrame(
        {
            "point": np.exp(future_result.predicted_mean),
            "lower": np.exp(future_interval.iloc[:, 0]),
            "upper": np.exp(future_interval.iloc[:, 1]),
        }
    )
    plot_future_forecast(levels, future, levels.index[-1])

    write_summary(
        levels,
        update_label,
        adf_results,
        coint_result,
        regression,
        beta_one_p,
        cusum_result,
        rolling_corr,
        acf_values,
        bound,
        selection,
        full_fit,
        diagnostics,
        jb,
        forecasts,
        metrics,
        future,
    )


if __name__ == "__main__":
    main()
