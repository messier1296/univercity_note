#set page(numbering: "-1-")
#set text(font: "Noto Serif CJK JP")
#show math.equation: set text(font: ("New Computer Modern Math", "Noto Serif CJK JP"))

#let my-title = "サンプル課題"
#let my-author = "今村隼人"
#let my-date = datetime(year: 2026, month: 4, day: 14)

#set document(
  title: my-title,
  author: my-author,
  date: my-date,
)

#v(2cm)
#align(center)[
  #text(size: 24pt, weight: "bold")[#my-title]
  #v(0.8em)
  #my-author
  #v(0.4em)
  #my-date.display("[year]-[month]-[day]")
]
#v(2cm)
/*
= section1

== section2

=== section3

- これは箇条書き
- 二個目

+ 箇条書きの番号付き
+ 二個目

#set text(font: "Noto Mono")

フォントの変更

#set text(size: 20pt)

フォントサイズの変更

#set text(size: 12pt, font: "Noto Serif CJK JP")

表の書き方

#table(
  columns: 2,
  [false],[true],[0],[1]
)

インライン数式$sin^2 theta + cos ^2 theta = 1$

ディスプレイ数式
$
integral ^ infinity _(-infinity) 1/ (sqrt(2) pi sigma ) exp(- (x-mu)^2/(2 sigma^2))
$
*/

= 班員の紹介
#v(2cm)
#table(
  columns: 5,
  [名前], [学年], [出身], [気になっていること], [つくば市のおすすめスポット],
  [小倉], [3], [神奈川県], [パズル], [筑波山],
  [櫻井], [3], [茨城県], [ポーカー], [えびすや],
  [村田], [3], [埼玉県], [ロードバイク], [りんりんロード],
)

#v(2cm)
= 階層分析

階層分析法（AHP）は、複数の基準をもつ意思決定問題を
*階層構造*・*一対比較*・*総合評価* によって整理する手法である。

== 基本の流れ

- 目的を定める
- 評価基準を設定する
- 代替案を比較する
- 重みを求めて総合評価する

== 階層構造の例

#align(center)[
  $
    "目的" -> "評価基準" -> "代替案"
  $
]

- 第1階層：目的
- 第2階層：評価基準
- 第3階層：代替案

== 一対比較

比較行列を $A = (a_(i j))$ とすると、各成分は対象 $i$ の対象 $j$ に対する重要度を表す。

#align(center)[
  $
  A = mat(
    1, a_(12), dots, a_(1n);
    1 / a_(12), 1, dots, a_(2n);
    dots.v, dots.v, dots.down, dots.v;
    1 / a_(1n), 1 / a_(2n), dots, 1
  )
  $
]

性質は次の通りである。

- $a_(i i) = 1$
- $a_(j i) = 1 / a_(i j)$
- 比較尺度には $1, 3, 5, 7, 9$ とその逆数を用いる

== 重みの計算

=== 固有値法

最大固有値に対応する固有ベクトルを用いて重みを求める。

#align(center)[
  $
  A w = lambda_"max" w
  $
]

#align(center)[
  $
  sum_(i=1)^n w_i = 1
  $
]

=== 幾何平均法

各行の幾何平均を使って重みを求める。

#align(center)[
  $
  g_i = root(n, product_(j=1)^n a_(i j))
  $
]

#align(center)[
  $
  w_i = g_i / sum_(j=1)^n g_j
  $
]

== 整合性指標

比較の一貫性は CI によって確認する。

#align(center)[
  $
  C I = (lambda_"max" - n) / (n - 1)
  $
]

- $C I = 0$ に近いほど整合性が高い
- 大きい場合は再評価が必要になる

== 例：今日の献立

評価基準と代替案を次のようにする。

#table(
  columns: (1.6fr, 1.2fr, 1.2fr),
  inset: 6pt,
  stroke: 0.5pt,
  table.header(
    [項目], [内容], [例]
  ),
  [目的], [献立を選ぶ], [今日の献立],
  [基準], [値段・満足感・季節感], [3基準],
  [代替案], [候補メニュー], [カレー / カツ丼 / ハンバーグ],
)

基準の重みを次のようにする。

#table(
  columns: 4,
  inset: 6pt,
  stroke: 0.5pt,
  table.header(
    [値段], [ガッツリ感], [季節感], [合計]
  ),
  [$0.19$], [$0.08$], [$0.73$], [$1.00$],
)

各代替案の総合評価を $W_t$ とすると、重み付き和で表せる。

#align(center)[
  $
  W_t = W_p w_t^p + W_q w_t^q + W_r w_t^r
  $
]

評価例を表にすると次のようになる。

#table(
  columns: 5,
  inset: 6pt,
  stroke: 0.5pt,
  table.header(
    [代替案], [値段], [ガッツリ感], [季節感], [総合評価]
  ),
  [カレーライス], [$0.73$], [$0.26$], [$0.66$], [$0.64$],
  [カツ丼], [$0.19$], [$0.64$], [$0.16$], [$0.20$],
  [ハンバーグ], [$0.08$], [$0.10$], [$0.18$], [$0.16$],
)

== まとめ

AHP では、次のような流れで意思決定を整理できる。

1. 階層を作る
2. 一対比較を行う
3. 重みを求める
4. 総合評価で順位を決める
#set text(font: "Noto Mono")

フォントの変更

#set text(size: 20pt)

フォントサイズの変更

#set text(size: 12pt, font: "Noto Serif CJK JP")


