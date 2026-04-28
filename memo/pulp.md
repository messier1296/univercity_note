# pulpのメモ

下の使い方を明記する

OK: 変数 + 変数
OK: 定数 * 変数
OK: 線形式 <= 定数
OK: 線形式 <= 線形式

NG: 変数 * 変数
NG: 変数 / 変数
NG: 変数 ** 2
NG: if 変数:
NG: max(変数, 変数)
NG: abs(変数)

データはpandasを使うならrangeじゃなくてlistの要素を舐めるfor文を使う


下の使い方を明記する
```python
# i は必ず1つの j に割り当てる
for i in I:
    prob += lpSum(x[i][j] for j in J) == 1

# j に割り当てられる i は L 人以上 U 人以下
for j in J:
    prob += lpSum(x[i][j] for i in I) >= L
    prob += lpSum(x[i][j] for i in I) <= U

# グループ G の人数を j ごとに制限する
for j in J:
    prob += lpSum(x[i][j] for i in G) <= U

# グループ G の人数を j ごとに最低人数以上にする
for j in J:
    prob += lpSum(x[i][j] for i in G) >= L

# i1 と i2 を同じ j にしない
for j in J:
    prob += x[i1][j] + x[i2][j] <= 1

# 解の値を見る
pulp.value(x[i][j])
```