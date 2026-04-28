# university

## Linter / Formatter / Type Checker

Python の linter と formatter は `ruff`、型検査は `pyright` を使う。設定は
[`pyproject.toml`](./pyproject.toml) の `[tool.ruff]` と `[tool.pyright]`
以下にまとめている。

### 実行方法

```sh
uv run ruff check .
uv run ruff format .
uv run pyright
```

自動修正できる lint は次で直す。

```sh
uv run ruff check . --fix
```

### 設定内容

- `target-version = "py312"`: Python 3.12 を前提に lint する。
- `line-length = 88`: 1 行の長さは 88 文字を目安にする。
- `select = ["E", "F", "I", "B", "UP"]`: pycodestyle、pyflakes、import
  順序、bugbear、pyupgrade の基本的なルールを見る。
- `ignore = ["T201"]`: 授業用スクリプトでは `print()` を使うため、print
  文の警告は無視する。
- `[tool.ruff.format]`: ダブルクォート、スペースインデント、環境に合わせた改行を使う。

### Pyright

- `pythonVersion = "3.12"`: Python 3.12 を前提に型検査する。
- `typeCheckingMode = "strict"`: Pyright の strict mode を使い、型の不明瞭さを
  できるだけ検出する。
- `include = ["."]`: このリポジトリ全体を型検査の対象にする。
- `exclude`: `.venv`、`__pycache__`、Rust プロジェクトの `chore` は対象外にする。
- `useLibraryCodeForTypes = true`: 型スタブがないライブラリでも、可能な範囲で実装から
  型情報を読む。
- `reportMissingTypeStubs = "warning"`: 外部ライブラリの型スタブ不足は警告にする。
  自分のコードの型エラーは strict mode のまま検出する。

型検査で使う外部ライブラリと型スタブは `dev` dependency に入れている。特に
`pandas-stubs` と `scipy-stubs` は、`pandas` / `scipy` を使うコードの型検査に必要。
