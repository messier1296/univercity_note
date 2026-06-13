import csv
import math
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np

MU = 5.0
LAMBDAS = [3.0, 4.0, 4.5, 4.9, 4.95, 5.1]
SETTINGS = [
    (110, 10),
    (1100, 100),
    (11000, 1000),
    (110000, 10000),
    (1100000, 100000),
    (11000000, 1000000),
]
BASE_SEED = 20260608
OUT_DIR = Path(__file__).resolve().parent
FIG_DIR = OUT_DIR / "figures"


def theoretical_mean(lam: float, mu: float) -> float:
    if lam >= mu:
        return math.inf
    return lam / (mu - lam)


def simulate_one_lambda(
    lam: float,
    mu: float,
    settings: list[tuple[int, int]],
    seed: int,
    path_time_limit: float = 120.0,
) -> tuple[
    list[dict[str, float | int | str]],
    list[tuple[float, int]],
    dict[int, float],
]:
    """Run one M/M/1 sample path and collect all event-count settings.

    This is the same event-driven idea as the lecture notebook:
    while the system has customers, the next event is the earlier of an
    arrival clock and a service-completion clock.  Equivalently, the next
    interval has rate lambda + mu and is an arrival with probability
    lambda / (lambda + mu).  At state 0, only arrivals can happen.
    """

    rng = np.random.default_rng(seed)
    max_events = max(total for total, _ in settings)
    max_setting_total, max_setting_ignore = settings[-1]

    numerators = [0.0 for _ in settings]
    included_times = [0.0 for _ in settings]
    path_points: list[tuple[float, int]] = [(0.0, 0)]
    state_durations: dict[int, float] = {}

    n_in_system = 0
    valid_time_for_path = 0.0

    for event in range(1, max_events + 1):
        before = n_in_system

        if before == 0:
            interval = float(rng.exponential(1.0 / lam))
            n_in_system = 1
        else:
            interval = float(rng.exponential(1.0 / (lam + mu)))
            if rng.random() < lam / (lam + mu):
                n_in_system += 1
            else:
                n_in_system -= 1

        for idx, (total_events, ignored_events) in enumerate(settings):
            if ignored_events < event <= total_events:
                numerators[idx] += interval * before
                included_times[idx] += interval

        if max_setting_ignore < event <= max_setting_total:
            state_durations[before] = state_durations.get(before, 0.0) + interval
            if valid_time_for_path <= path_time_limit:
                path_points.append((valid_time_for_path, before))
                valid_time_for_path += interval
                path_points.append((valid_time_for_path, before))

    rows: list[dict[str, float | int | str]] = []
    theory = theoretical_mean(lam, mu)
    for idx, (total_events, ignored_events) in enumerate(settings):
        sim_mean = numerators[idx] / included_times[idx]
        absolute_error = abs(sim_mean - theory) if math.isfinite(theory) else math.nan
        rows.append(
            {
                "lambda": lam,
                "mu": mu,
                "total_events": total_events,
                "ignored_events": ignored_events,
                "simulated_mean": sim_mean,
                "theoretical_mean": theory,
                "absolute_error": absolute_error,
            }
        )

    return rows, path_points, state_durations


def format_lambda(lam: float) -> str:
    return str(lam).replace(".", "p")


def plot_sample_path(lam: float, points: list[tuple[float, int]]) -> None:
    xs = [x for x, _ in points]
    ys = [y for _, y in points]
    plt.figure(figsize=(8.0, 3.4))
    plt.plot(xs, ys, linewidth=1.0)
    plt.xlabel("time after warm-up")
    plt.ylabel("N(t)")
    plt.title(f"Sample path of M/M/1 queue (lambda={lam:g}, mu={MU:g})")
    plt.xlim(0, min(120, max(xs) if xs else 120))
    plt.grid(alpha=0.25)
    plt.tight_layout()
    plt.savefig(FIG_DIR / f"sample_path_lambda_{format_lambda(lam)}.png", dpi=180)
    plt.close()


def plot_distribution(lam: float, durations: dict[int, float]) -> None:
    total_time = sum(durations.values())
    max_state = max(durations)
    states = np.arange(max_state + 1)
    probs = np.array([durations.get(int(state), 0.0) / total_time for state in states])

    plt.figure(figsize=(8.0, 3.4))
    if lam < MU:
        plt.bar(states, probs, width=0.8, alpha=0.65, label="simulation")
        rho = lam / MU
        theory = (1.0 - rho) * (rho**states)
        plt.plot(
            states,
            theory,
            marker="o",
            markersize=3,
            linewidth=1.2,
            label="theoretical",
        )
        plt.xlim(-0.5, min(max_state + 0.5, 140))
    else:
        observed_states = np.array(sorted(durations))
        observed_weights = np.array(
            [durations[int(state)] / total_time for state in observed_states]
        )
        bins = np.linspace(observed_states.min(), observed_states.max(), 70)
        plt.hist(
            observed_states,
            bins=bins,
            weights=observed_weights,
            alpha=0.70,
            label="simulation",
        )
    plt.xlabel("number of customers in system")
    plt.ylabel("probability")
    plt.title(f"Distribution of N in M/M/1 queue (lambda={lam:g}, mu={MU:g})")
    plt.grid(axis="y", alpha=0.25)
    plt.legend()
    plt.tight_layout()
    plt.savefig(FIG_DIR / f"distribution_lambda_{format_lambda(lam)}.png", dpi=180)
    plt.close()


def write_results(rows: list[dict[str, float | int | str]]) -> None:
    with (OUT_DIR / "mm1_results.csv").open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=list(rows[0].keys()))
        writer.writeheader()
        writer.writerows(rows)


def write_typst_table(rows: list[dict[str, float | int | str]]) -> None:
    lines = [
        "#table(",
        "  columns: (0.7fr, 1fr, 1fr, 1.2fr, 1.2fr, 1.1fr),",
        "  inset: 4pt,",
        "  stroke: 0.45pt,",
        "  table.header("
        "[$lambda$], [発生イベント数], [無視イベント数], "
        "[シミュレーション], [理論値], [差]),",
    ]
    for row in rows:
        theory = row["theoretical_mean"]
        theory_text = (
            "$infinity$" if math.isinf(float(theory)) else f"{float(theory):.4f}"
        )
        err = row["absolute_error"]
        err_text = "-" if math.isnan(float(err)) else f"{float(err):.4f}"
        lines.append(
            f"  [{float(row['lambda']):g}],"
            f" [{int(row['total_events'])}],"
            f" [{int(row['ignored_events'])}],"
            f" [{float(row['simulated_mean']):.4f}],"
            f" [{theory_text}],"
            f" [{err_text}],"
        )
    lines.append(")")
    (OUT_DIR / "result_table.typ").write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> None:
    FIG_DIR.mkdir(parents=True, exist_ok=True)
    all_rows: list[dict[str, float | int | str]] = []

    for index, lam in enumerate(LAMBDAS):
        rows, path_points, durations = simulate_one_lambda(
            lam=lam,
            mu=MU,
            settings=SETTINGS,
            seed=BASE_SEED + index,
        )
        all_rows.extend(rows)
        plot_sample_path(lam, path_points)
        plot_distribution(lam, durations)

    write_results(all_rows)
    write_typst_table(all_rows)


if __name__ == "__main__":
    main()
