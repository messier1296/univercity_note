#import "/template.typ": setup
#show: setup

#import "report07_assets/summary.typ": *

#align(center)[
  #text(size: 15pt, weight: "bold")[計量時系列分析 第7回課題]

  #v(4mm)
  202410178 今村隼人
]

= 最適予測

時刻 $t$ で利用可能な情報に関する条件付期待値を $E_t$ と書き、
$
  mu_(t+h|t) = E_t(y_(t+h))
$
とおく。任意の予測 $tilde(y)_(t+h|t)$ について、
$
  E_t (y_(t+h) - tilde(y)_(t+h|t))^2
  = E_t ((y_(t+h) - mu_(t+h|t)) + (mu_(t+h|t) - tilde(y)_(t+h|t)))^2
$
である。右辺を展開すると、
$
  E_t (y_(t+h) - mu_(t+h|t))^2
  + 2 E_t ((y_(t+h) - mu_(t+h|t))
      (mu_(t+h|t) - tilde(y)_(t+h|t)))
  + E_t (mu_(t+h|t) - tilde(y)_(t+h|t))^2
$
となる。

$mu_(t+h|t)$ と $tilde(y)_(t+h|t)$ は時刻 $t$ の情報で決まるので、中央の交差項は
$
  2 (mu_(t+h|t) - tilde(y)_(t+h|t))
    E_t (y_(t+h) - mu_(t+h|t)) = 0
$
である。したがって、
$
  E_t (y_(t+h) - tilde(y)_(t+h|t))^2
  = E_t (y_(t+h) - mu_(t+h|t))^2
    + E_t (mu_(t+h|t) - tilde(y)_(t+h|t))^2
$
を得る。右辺第2項は非負なので、
$
  tilde(y)_(t+h|t) = mu_(t+h|t)
$
のときMSEは最小になる。よって最適予測は条件付期待値で与えられる。

= AR(1)の予測

AR(1)過程
$
  y_t = c + phi y_(t-1) + u_t,
  quad u_t ~ "WN"(sigma^2), quad abs(phi) < 1
$
を考える。逐次代入により、
$
  y_(t+h)
  = c sum_(j=0)^(h-1) phi^j
    + phi^h y_t
    + sum_(j=0)^(h-1) phi^j u_(t+h-j)
$
である。時刻 $t$ では将来の $u$ の条件付期待値は0なので、
$
  hat(y)_(t+h|t)
  = c sum_(j=0)^(h-1) phi^j + phi^h y_t
  = frac(c (1 - phi^h), 1 - phi) + phi^h y_t
$
となる。予測誤差は
$
  y_(t+h) - hat(y)_(t+h|t)
  = sum_(j=0)^(h-1) phi^j u_(t+h-j)
$
であり、ホワイトノイズは互いに無相関だから、
$
  "MSE"(hat(y)_(t+h|t))
  = sigma^2 sum_(j=0)^(h-1) phi^(2j)
  = frac(1 - phi^(2h), 1 - phi^2) sigma^2
$
である。

過程の期待値を
$
  mu = frac(c, 1 - phi)
$
とおくと、
$
  hat(y)_(t+h|t) = mu + phi^h (y_t - mu)
$
と書ける。$abs(phi)<1$ より $h -> infinity$ で $phi^h -> 0$ だから、
$
  hat(y)_(t+h|t) -> mu
$
である。すなわち、長期予測は過程の期待値へ収束する。

また、MSEについては
$
  "MSE"_(h+1) - "MSE"_h
  = sigma^2 phi^(2h) >= 0
$
であるから単調に増加する。さらに、
$
  lim_(h -> infinity) "MSE"_h
  = frac(sigma^2, 1 - phi^2)
$
である。定常AR(1)の無条件分散も
$
  V(y_t) = frac(sigma^2, 1 - phi^2)
$
なので、MSEは過程の分散に収束する。

= AR(2)過程のシミュレーションと予測

課題のAR(2)過程
$
  y_t = 1.1 + 0.3 y_(t-1) - 0.4 y_(t-2) + u_t,
  quad u_t ~ "iid" N(0, 9)
$
を考える。この過程の期待値は
$
  mu = frac(1.1, 1 - 0.3 - (-0.4)) = 1
$
である。したがって、初期値は $y_(-1) = y_0 = 1$ とした。乱数シードは #seed とし、$y_1, dots, y_50$ を発生させた。

#figure(
  image("report07_assets/ar2_series.svg", width: 82%),
  caption: [シミュレーションで得たAR(2)系列],
)

20次までの標本自己相関と標本偏自己相関は次の通りである。1次と2次の値は、それぞれ標本自己相関が #acf1、#acf2、標本偏自己相関が #pacf1、#pacf2 であった。

#figure(
  image("report07_assets/ar2_correlogram.svg", width: 82%),
  caption: [20次までの標本自己相関と標本偏自己相関],
)

最後の2点は
$
  y_49 = #y49, quad y_50 = #y50
$
であった。1期先点予測は講義のAR(p)の逐次予測式から
$
  hat(y)_(51|50)
  = 1.1 + 0.3 y_50 - 0.4 y_49
  = #forecast-51
$
である。1期先の予測誤差は $u_51$ なのでMSEは $9$、標準偏差は $3$ である。したがって95%区間予測は
$
  hat(y)_(51|50) plus.minus 1.96 times 3
  = [#interval-51-lower, #interval-51-upper]
$
である。

2期先点予測では、未知の $y_51$ を1期先点予測で置き換えるので、
$
  hat(y)_(52|50)
  = 1.1 + 0.3 hat(y)_(51|50) - 0.4 y_50
  = #forecast-52
$
となる。
