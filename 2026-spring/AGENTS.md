# AGENTS.md

## このディレクトリの概要

このディレクトリは `university/2026-spring` で、2026年春学期の授業ノート、課題、配布資料、分析コードを科目別に置いている。基本的に1授業につき1ディレクトリを用意し、作業単位も授業ディレクトリごとに分ける。

 `template.pdf`: 共通テンプレートの出力 PDF。Typst ソースは親ディレクトリの `template.typ` にある。
- `.venv/` や各サブディレクトリの `.venv/`: Python 仮想環境。基本的に編集対象ではない。

## 作業方針

- 科目ごとのファイルは、できるだけ該当科目ディレクトリ内で完結させる。
- 依頼対象の授業が分かる場合は、まず対応する授業ディレクトリ内だけを確認・編集する。共通テンプレートや横断的な設定が必要な場合だけ、親ディレクトリや他ディレクトリを参照する。
- 既存の講義ノートやレポートは、文体・見出し階層・数式表記を周辺ファイルに合わせる。
- PDF、`.aux`、`.log`、`.dvi`、`.fdb_latexmk`、`.fls` などは原則として生成物として扱う。ユーザーから依頼がない限り、内容修正の主対象は `.typ`、`.tex`、`.md`、`.py`、`.ipynb` などのソースファイルにする。
- `:Zone.Identifier` や `__MACOSX` 配下のファイルはダウンロード・展開由来のメタデータとして扱い、通常は参照・編集しない。
- `strategic_system/` はネストした Git リポジトリなので、Git 操作や差分確認は作業対象のリポジトリ境界を確認してから行う。

## Typst

- `typst compile` を実行するときは、`university` ディレクトリを root にする。
- このディレクトリから実行する場合は `typst compile --root .. <input.typ> <output.pdf>` の形にする。
- `math_analysis/02.typ` のように `#import "/template.typ"` を使うファイルは、`--root ..` を付けないとテンプレート解決に失敗する。
- `time_series_analysis/02.typ` のように相対 `#include "../template.typ"` を使うファイルもあるため、テンプレート参照方式はファイルごとの既存記法を尊重する。

## Python

- `strategic_system/` は `uv` 管理の Python プロジェクトで、`pyproject.toml` と `uv.lock` がある。依存関係は主に `pandas` と `scipy`。
- Python を触るときは、原則として `uv` を使う。スクリプト実行は `uv run ...`、依存関係の追加は `uv add ...` を優先する。
- 統計分析コードを実行・修正する場合は、まず `strategic_system/scripts/` と `strategic_system/data/` を確認する。
- 仮想環境ディレクトリ `.venv/` は編集しない。

## LaTeX / Notebook

- `math_engineer/` には LaTeX と Typst の両方がある。LaTeX を扱う場合は `.tex` をソース、`.aux` や `.log` などを生成物として扱う。
- Jupyter Notebook は `math_engineer/` に置かれている。ノートブックを編集するときは、実行結果やメタデータの不要な差分を増やしすぎない。
