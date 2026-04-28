import csv

import pandas as pd

path = "/home/hayato/university/2026-spring/data/FEH_00450091_260414110315.csv"

rows: list[list[str]] = []
with open(path, encoding="shift_JIS", newline="") as f:
    reader = csv.reader(f)
    for row in reader:
        rows.append(row)

max_len = max(len(row) for row in rows)
rows = [row + [""] * (max_len - len(row)) for row in rows]
df_raw = pd.DataFrame(rows)

# 目視で確認して行番号を調整
row_edu = 13  # /学歴_基本８区分（2020年～）
row_last = 16  # 時間軸（2020～2023） コード ...
row_data = 17  # 最初のデータ行

edu = df_raw.iloc[row_edu].fillna("")
last = df_raw.iloc[row_last].fillna("")

new_cols: list[str] = []
for i in range(df_raw.shape[1]):
    base = str(last[i]).strip()
    sub = str(edu[i]).strip()

    if i <= 9:
        # 前半の識別列
        new_cols.append(base if base else f"col_{i}")
    else:
        # 後半の給与列
        sub = sub.replace("高専・短大", "高専短大")
        if sub:
            new_cols.append(f"所定内給与額_{sub}")
        else:
            new_cols.append(f"col_{i}")

data = df_raw.iloc[row_data:].reset_index(drop=True)
data.columns = new_cols

# 欲しい列だけ残す例
keep_cols = [
    "時間軸（2020～2023）",
    "性別_基本",
    "地域",
    "所定内給与額_学歴計",
    "所定内給与額_中学",
    "所定内給与額_高校",
    "所定内給与額_専門学校",
    "所定内給与額_高専短大",
    "所定内給与額_大学",
    "所定内給与額_大学院",
]

# 存在するものだけ残す
keep_cols = [c for c in keep_cols if c in data.columns]
data = data[keep_cols]

print(data.head())
data.to_csv("clean_output.csv", index=False, encoding="utf-8-sig")
