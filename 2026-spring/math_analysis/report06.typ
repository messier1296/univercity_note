#set page(
  paper: "a4",
  margin: (x: 16mm, y: 18mm),
  numbering: "1",
  number-align: bottom + right,
)

#set text(
  font: "Noto Serif CJK JP",
  size: 10.5pt,
  fill: rgb("#1d2433"),
)

#show math.equation: set text(font: ("New Computer Modern Math", "Noto Serif CJK JP"))
#set par(justify: true, leading: 0.72em)
#set enum(numbering: "(1)")

= 数理解析レポート第六回

202410178
今村隼人

== [演習]

領域$D$上の確率変数$X$を考え,$X_1, X_2, dots, X_N$を互いに独立に同じ分布に従うサンプルとする.
関数$f$に対して,モンテカルロ法による平均値の推定量を
$
  overline(f)_N = 1 / N sum_(i=1)^N f(X_i)
$
とおく.

このとき,$overline(f)_N$の分散と標準偏差を計算し,試行回数$N$に対してどのように変化するかを調べよ.
また,領域$D$上の積分
$
  integral_D f(x) dif x
$
を求めたい場合に,この結果がどのように使えるかを説明せよ.

#v(0.5cm)

== [解答]

$Y_i = f(X_i)$とおく.このとき$X_i$は独立同分布であるから,$Y_i$も独立同分布である.
ここで
$
  mu = E[Y_i] = E[f(X)],
  quad
  sigma^2 = "Var"(Y_i) = "Var"(f(X))
$
とおく.

まず期待値を計算すると,
$
  E[overline(f)_N]
  = E[1 / N sum_(i=1)^N Y_i]
  = 1 / N sum_(i=1)^N E[Y_i]
  = 1 / N dot N mu
  = mu
$
である.したがって$overline(f)_N$は$E[f(X)]$の不偏推定量である.

次に分散を計算する.独立性より$i != j$のとき
$
  "Cov"(Y_i, Y_j) = 0
$
であるから,
$
  "Var"(overline(f)_N)
  & = "Var"(1 / N sum_(i=1)^N Y_i) \
  & = 1 / N^2 "Var"(sum_(i=1)^N Y_i) \
  & = 1 / N^2 sum_(i=1)^N "Var"(Y_i) \
  & = 1 / N^2 dot N sigma^2 \
  & = sigma^2 / N.
$
したがって
$
  "Var"(overline(f)_N) = "Var"(f(X)) / N
$
である.

標準偏差は分散の平方根であるから,
$
  "sd"(overline(f)_N)
  = sqrt("Var"(overline(f)_N))
  = sqrt(sigma^2 / N)
  = sigma / sqrt(N)
$
となる.すなわち,
$
  "sd"(overline(f)_N)
  = sqrt("Var"(f(X))) / sqrt(N)
$
である.

以上より,モンテカルロ法で得られる標本平均の分散は$1/N$に比例して小さくなり,標準偏差は$1 / sqrt(N)$に比例して小さくなる.
したがって誤差を半分にしたい場合には,試行回数をおよそ4倍にする必要がある.

領域$D$から一様にサンプリングしている場合を考える.このとき$X$の密度は$1 / |D|$であるから,
$
  E[f(X)]
  = integral_D f(x) 1 / |D| dif x
  = 1 / |D| integral_D f(x) dif x
$
である.よって求めたい積分は
$
  integral_D f(x) dif x
  = |D| E[f(X)]
$
と書ける.

したがってモンテカルロ積分の推定量は
$
  I_N = |D| overline(f)_N
$
である.この分散は
$
  "Var"(I_N)
  = |D|^2 "Var"(overline(f)_N)
  = |D|^2 sigma^2 / N
$
となり,標準偏差は
$
  "sd"(I_N)
  = |D| sigma / sqrt(N)
$
である.

実際には$sigma^2 = "Var"(f(X))$は未知であることが多いので,サンプルから
$
  s_N^2 = 1 / (N - 1) sum_(i=1)^N (f(X_i) - overline(f)_N)^2
$
を計算し,$sigma^2$の代わりに用いる.このとき積分値の標準誤差は
$
  |D| s_N / sqrt(N)
$
と見積もることができる.

中心極限定理により,$N$が十分大きいとき
$
  overline(f)_N approx N(mu, sigma^2 / N)
$
とみなせる.そのため,平均値$E[f(X)]$については
$
  overline(f)_N plus.minus 1.96 s_N / sqrt(N)
$
が約95%信頼区間となり,積分値$integral_D f(x) dif x$については
$
  |D| overline(f)_N plus.minus 1.96 |D| s_N / sqrt(N)
$
が約95%信頼区間となる.

このように,モンテカルロ法の精度は次元に直接依存するのではなく,主にサンプル数$N$に対して$1 / sqrt(N)$の速さで改善する.そのため,低次元ではリーマン和の方が効率的なこともあるが,高次元の積分ではモンテカルロ法が有効になりやすい.
