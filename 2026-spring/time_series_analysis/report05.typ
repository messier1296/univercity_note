#import "/template.typ": setup
#show: setup

#import "report05_assets/summary.typ": *

#align(center)[
  #text(size: 15pt, weight: "bold")[計量時系列分析 第5回課題]

  #v(4mm)
  202410178 今村隼人
]

= AR(1)過程のシミュレーション

AR(1)過程
$
  y_t = c + phi y_(t-1) + u_t, quad u_t ~ "WN"(sigma^2)
$
を考える。課題で与えられた4つの組
$
  (c, phi, sigma)
  = (2, 0.3, 2), (-2, -0.8, 1), (2, 1, 1), (2, 1.1, 1)
$
について、$T=100$ の系列をPythonで発生させた。

#figure(
  image("report05_assets/ar1_series.svg", width: 100%),
  caption: [AR(1)過程(a)--(d)のシミュレーション系列],
)

標本平均、標本分散、1次の標本自己相関は表1の通りである。

#table(
  columns: (1.2fr, 1fr, 1fr, 1fr),
  inset: 5pt,
  align: center + horizon,
  [設定], [標本平均], [標本分散], [1次自己相関],
  [(a)], [#ar1_a_mean], [#ar1_a_var], [#ar1_a_acf1],
  [(b)], [#ar1_b_mean], [#ar1_b_var], [#ar1_b_acf1],
  [(c)], [#ar1_c_mean], [#ar1_c_var], [#ar1_c_acf1],
  [(d)], [#ar1_d_mean], [#ar1_d_var], [#ar1_d_acf1],
)

AR(1)過程は $abs(phi) < 1$ のとき弱定常である。このとき平均は
$
  E(y_t) = c / (1 - phi)
$
であり、自己相関は
$
  rho(k) = phi^k
$
となる。したがって、(a)は正の自己相関を持ち、系列は平均 $2 / (1 - 0.3) = 2.857$ の周りで比較的ゆっくり動く。(b)は $phi=-0.8$ なので、隣り合う時点で符号が反転しやすく、1次自己相関は負になる。

一方、(c)は $phi=1$ の単位根過程であり、平均へ戻る力を持たない。(d)は $phi=1.1$ であり、絶対値が1を超えるため発散的である。どちらも弱定常ではない。

#figure(
  image("report05_assets/ar1_acf.svg", width: 100%),
  caption: [AR(1)過程(a)--(d)の10次までのコレログラム],
)

= AR(2)過程の定常条件

AR(2)過程
$
  y_t = c + phi_1 y_(t-1) + phi_2 y_(t-2) + u_t,
  quad u_t ~ "WN"(sigma^2)
$
を考える。平均が存在するならば、$E(y_t)=mu$ とおけるので、
$
  mu = c + phi_1 mu + phi_2 mu
$
である。したがって
$
  mu = c / (1 - phi_1 - phi_2)
$
となる。

AR特性方程式は
$
  1 - phi_1 z - phi_2 z^2 = 0
$
である。AR(2)過程が弱定常であるためには、この方程式の根がすべて単位円の外側にあること、すなわち根の絶対値が1より大きいことが必要である。係数で書けば
$
  phi_1 + phi_2 < 1, quad
  phi_2 - phi_1 < 1, quad
  -1 < phi_2 < 1
$
が定常条件である。

自己共分散はYule-Walker方程式を満たす。$k >= 1$ について
$
  gamma(k) = phi_1 gamma(k-1) + phi_2 gamma(k-2)
$
であり、自己相関についても
$
  rho(k) = phi_1 rho(k-1) + phi_2 rho(k-2)
$
が成り立つ。特に
$
  rho(1) = frac(phi_1, 1 - phi_2)
$
である。

= AR(1)過程のMA(∞)表現

平均を0としたAR(1)過程
$
  y_t = phi y_(t-1) + u_t
$
を考える。

== 定常条件

AR特性方程式は
$
  1 - phi z = 0
$
であり、その根は $z = 1 / phi$ である。定常であるためには根の絶対値が1より大きい必要があるので、
$
  abs(1 / phi) > 1
$
すなわち
$
  abs(phi) < 1
$
が定常条件である。

== 繰り返し代入

1期前の式 $y_(t-1) = phi y_(t-2) + u_(t-1)$ を代入すると、
$
  y_t = u_t + phi u_(t-1) + phi^2 y_(t-2)
$
である。さらに繰り返すと、任意の $m$ について
$
  y_t
  = u_t + phi u_(t-1) + phi^2 u_(t-2) + dots
    + phi^m u_(t-m) + phi^(m+1) y_(t-m-1)
$
となる。

== MA(∞)表現

$abs(phi)<1$ ならば、$m -> infinity$ のとき $phi^(m+1) y_(t-m-1) -> 0$ と考えられる。したがって
$
  y_t = sum_(j=0)^infinity phi^j u_(t-j)
$
と表せる。これはAR(1)過程のMA(∞)表現である。係数 $phi^j$ は幾何級数的に減衰するので、現在のショックは将来へ残るが、その影響は $abs(phi)<1$ のもとで次第に小さくなる。

= AR(2)過程の分析

例として、次のAR(2)過程を考える。
$
  y_t = 1 + 0.5 y_(t-1) + 0.2 y_(t-2) + u_t,
  quad u_t ~ "WN"(1)
$

== 理論値

この過程では $phi_1=0.5$、$phi_2=0.2$ である。定常条件を確認すると、
$
  phi_1 + phi_2 = 0.7 < 1,
  quad phi_2 - phi_1 = -0.3 < 1,
  quad -1 < phi_2 = 0.2 < 1
$
であり、弱定常である。

平均は
$
  mu = 1 / (1 - 0.5 - 0.2) = 3.333
$
である。1次自己相関は
$
  rho(1) = 0.5 / (1 - 0.2) = 0.625
$
であり、2次自己相関は
$
  rho(2) = 0.5 rho(1) + 0.2 = 0.5125
$
である。AR(2)ではこの後の自己相関も
$
  rho(k) = 0.5 rho(k-1) + 0.2 rho(k-2)
$
によって決まる。

== シミュレーション

$T=100$ の系列を発生させたところ、標本平均は #ar2_mean、標本分散は #ar2_var であった。また、標本自己相関は1次が #ar2_acf1、2次が #ar2_acf2 であった。標本数が100なので完全には理論値と一致しないが、正の自己相関がゆっくり減衰するというAR(2)過程の特徴は確認できる。

#figure(
  image("report05_assets/ar2_series_acf.svg", width: 95%),
  caption: [AR(2)過程のシミュレーション系列と10次までのコレログラム],
)
