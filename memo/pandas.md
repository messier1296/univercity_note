# pandasのメモ

DataFrameのindexとID列は別物
条件抽出は .loc
最適化に渡す前に list / dict に変換する
制約式の中でDataFrameを直接触らない


下のコードの解説を書く
```python
df = pd.read_csv("data/students.csv")

df.head()
df.info()
df.describe()

df["列名"]
df[["列名1", "列名2"]]

df.loc[条件, "列名"]
df.loc[条件, ["列名1", "列名2"]]

df["列名"].tolist()
df["列名"].mean()
df["列名"].value_counts()

df.set_index("id列")["値列"].to_dict()
```