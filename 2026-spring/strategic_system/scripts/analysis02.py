from pathlib import Path

import pandas as pd
from scipy import stats

BASE_DIR = Path(__file__).resolve().parents[1]
CSV_PATH = BASE_DIR / "data" / "FEH_00450091_260414110315.csv"
ENCODING = "shift_jis"

df = pd.read_csv(CSV_PATH, encoding=ENCODING)

university = pd.to_numeric(
    df["大学 所定内給与額【千円】"].iloc[1:48], errors="coerce"
).dropna()
graduated = pd.to_numeric(
    df["大学院 所定内給与額【千円】"].iloc[1:48], errors="coerce"
).dropna()

print(university)

print("大卒の平均年収:", university.mean())
print("院卒の平均年収:", graduated.mean())
print("平均の差:", graduated.mean() - university.mean())
print("t値:", stats.ttest_ind(university, graduated, equal_var=True))
