#import "/template.typ": setup
#show: setup

#import "report04_assets/summary.typ": *

#align(center)[
  #text(size: 15pt, weight: "bold")[計量時系列分析 第4回課題]

  #v(4mm)
  202410178 今村隼人
]

= ホワイトノイズの性質

ホワイトノイズ ${u_t}$ は、平均0、分散 $sigma^2$、異なる時点間で無相関な確率過程である。
したがって、$t != s$ のとき
$
  "Cov"(u_t, u_s) = 0
$
である。共分散の定義より、
$
  "Cov"(u_t, u_s)
  = E(u_t u_s) - E(u_t) E(u_s)
$
であり、ホワイトノイズでは $E(u_t)=E(u_s)=0$ なので、
$
  E(u_t u_s) = 0
$
となる。

また、分散の定義より
$
  "Var"(u_t) = E(u_t^2) - {E(u_t)}^2
$
である。$E(u_t)=0$、$"Var"(u_t)=sigma^2$ であるから、
$
  E(u_t^2) = sigma^2
$
である。同様に $u_s$ についても
$
  E(u_s^2) = sigma^2
$
が成り立つ。よって、$E(u_t^2)=E(u_s^2)=sigma^2$ である。

= MA(1) 過程のシミュレーション

第4回資料 p.9 の(a)と(f)に対応するMA(1)過程を考える。
MA(1)過程は
$
  y_t = mu + u_t + theta_1 u_(t-1), quad u_t ~ "WN"(sigma^2)
$
である。ここでは(a)を $mu=0, theta_1=0.8, sigma=1$、
(f)を $mu=-2, theta_1=-0.8, sigma=2$ とした。
乱数の発生にはPythonを用い、$T=100$ の系列を作成した。
縦軸の範囲は2つの図でそろえた。

#figure(
  image("report04_assets/ma1_af_series.svg", width: 100%),
  caption: [MA(1)過程(a)と(f)のシミュレーション系列],
)

標本平均、標本分散、1次の標本自己相関は表1の通りである。

#table(
  columns: (1.5fr, 1fr, 1fr, 1fr),
  inset: 5pt,
  align: center + horizon,
  [設定], [標本平均], [標本分散], [1次自己相関],
  [(a)], [#ma1_a_mean], [#ma1_a_var], [#ma1_a_acf1],
  [(f)], [#ma1_f_mean], [#ma1_f_var], [#ma1_f_acf1],
)

(a)は $theta_1=0.8$ であるため、隣り合う時点の値が同じ方向に動きやすい。
一方、(f)は $theta_1=-0.8$ であるため、1期前の撹乱項の影響が逆方向に出やすく、
1次自己相関は負になっている。
コレログラムでもこの違いが確認できる。

#figure(
  image("report04_assets/ma1_af_acf.svg", width: 100%),
  caption: [MA(1)過程(a)と(f)の10次までのコレログラム],
)

= MA(2) 過程の平均・分散・自己共分散・自己相関

一般のMA(2)過程
$
  y_t = mu + u_t + theta_1 u_(t-1) + theta_2 u_(t-2),
  quad u_t ~ "WN"(sigma^2)
$
を考える。まず平均は
$
  E(y_t)
  = mu + E(u_t) + theta_1 E(u_(t-1)) + theta_2 E(u_(t-2))
  = mu
$
である。

分散は、ホワイトノイズが異なる時点で無相関であることから、
$
  gamma(0)
  = "Var"(y_t)
  = (1 + theta_1^2 + theta_2^2) sigma^2
$
となる。

1次自己共分散は
$
  gamma(1)
  = "Cov"(y_t, y_(t-1))
  = (theta_1 + theta_1 theta_2) sigma^2
  = theta_1 (1 + theta_2) sigma^2
$
である。2次自己共分散は
$
  gamma(2)
  = "Cov"(y_t, y_(t-2))
  = theta_2 sigma^2
$
である。3次以上では共通する撹乱項がないため、
$
  gamma(k) = 0 quad (k >= 3)
$
となる。

したがって、自己相関は
$
  rho(1) = frac(theta_1 (1 + theta_2), 1 + theta_1^2 + theta_2^2),
  quad
  rho(2) = frac(theta_2, 1 + theta_1^2 + theta_2^2),
  quad
  rho(k) = 0 quad (k >= 3)
$
である。

= MA(1) の反転可能条件

簡単のため $mu=0$ としたMA(1)過程
$
  y_t = u_t + theta u_(t-1)
$
を考える。移項すると
$
  u_t = -theta u_(t-1) + y_t
$
である。

== 反転可能条件

MA(1)のMA特性方程式は
$
  1 + theta z = 0
$
である。この根は $z = -1 / theta$ である。
反転可能であるためには、MA特性方程式の根の絶対値が1より大きい必要がある。
したがって、
$
  abs(-1 / theta) > 1
$
より、
$
  abs(theta) < 1
$
が反転可能条件である。

== 繰り返し代入

$
  u_t = y_t - theta u_(t-1)
$
に対して、1期前の式
$
  u_(t-1) = y_(t-1) - theta u_(t-2)
$
を代入すると、
$
  u_t = y_t - theta y_(t-1) + theta^2 u_(t-2)
$
となる。さらに繰り返すと、
$
  u_t
  = y_t - theta y_(t-1) + theta^2 y_(t-2)
    - dots + (-theta)^m y_(t-m) + (-theta)^(m+1) u_(t-m-1)
$
である。

== AR(∞) 表現

反転可能条件 $abs(theta)<1$ が満たされるとき、
$
  (-theta)^(m+1) u_(t-m-1) -> 0 quad (m -> infinity)
$
である。したがって、
$
  u_t = sum_(j=0)^infinity (-theta)^j y_(t-j)
$
と書ける。これを $y_t = u_t + theta u_(t-1)$ の反転表現として整理すると、
$
  y_t
  = theta y_(t-1) - theta^2 y_(t-2) + theta^3 y_(t-3) - dots + u_t
$
である。AR係数は
$
  theta, -theta^2, theta^3, -theta^4, dots
$
となり、$abs(theta)<1$ のもとで指数的に0へ減衰する。

= MA(2) 過程の分析

次のMA(2)過程を考える。
$
  y_t = 2 + u_t + 0.3 u_(t-1) - 0.1 u_(t-2),
  quad u_t ~ "WN"(sigma^2)
$

== 理論値

この過程では $mu=2$、$theta_1=0.3$、$theta_2=-0.1$ である。
したがって平均は
$
  E(y_t) = 2
$
である。分散は
$
  gamma(0)
  = (1 + 0.3^2 + (-0.1)^2) sigma^2
  = 1.10 sigma^2
$
である。

1次自己共分散は
$
  gamma(1)
  = 0.3 (1 - 0.1) sigma^2
  = 0.27 sigma^2
$
であり、2次自己共分散は
$
  gamma(2) = -0.1 sigma^2
$
である。3次以上では
$
  gamma(k)=0 quad (k >= 3)
$
である。

自己相関は
$
  rho(1) = 0.27 / 1.10 = 0.245,
  quad
  rho(2) = -0.1 / 1.10 = -0.091,
  quad
  rho(k)=0 quad (k >= 3)
$
である。

== 定常性と反転可能性

MA過程は次数が有限である限り、弱定常である。
したがって、このMA(2)過程は定常である。

反転可能性はMA特性方程式
$
  1 + 0.3 z - 0.1 z^2 = 0
$
の根で判定する。この方程式は
$
  z = 5, quad z = -2
$
を根に持つ。どちらも絶対値が1より大きいので、
このMA(2)過程は反転可能である。

== シミュレーション

$sigma=1$ として $T=100$ のシミュレーションを行った。
得られた標本平均は #ma2_mean、標本分散は #ma2_var、標本標準偏差は #ma2_std であった。
理論平均は2、理論分散は1.10であり、標本値は概ね理論値と近い。
また、標本自己相関は1次が #ma2_acf1、2次が #ma2_acf2 であった。
理論値はそれぞれ0.245、-0.091であるため、標本自己相関も概ね対応している。

#figure(
  image("report04_assets/ma2_series_acf.svg", width: 95%),
  caption: [MA(2)過程のシミュレーション系列と10次までのコレログラム],
)

3次以上の自己相関は理論上0である。ただし、標本数が100であるため、
シミュレーション結果では3次以上にも小さな標本自己相関が現れる。
これは有限標本による誤差であり、理論的なMA(2)過程の性質とは矛盾しない。
