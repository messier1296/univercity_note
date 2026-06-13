#import "/template.typ": setup
#show: setup

#import "report06_assets/summary.typ": *

#align(center)[
  #text(size: 15pt, weight: "bold")[計量時系列分析 第6回課題]

  #v(4mm)
  202410178 今村隼人
]

= AR(1) モデルの最尤推定量

AR(1) モデル
$
  y_t = c + phi y_(t-1) + u_t, quad u_t ~ "iid" N(0, sigma^2)
$
を考える。推定したいパラメータを
$
  Theta = (c, phi, sigma^2)
$
とする。初期値 $y_0$ を所与として条件付き尤度を考えると、結合密度は条件付き密度の積に分解できる。
$
  f(y_1, dots, y_T | y_0; Theta)
  = product_(t=1)^T f(y_t | y_(t-1); Theta)
$
である。

$u_t$ が正規分布に従うので、条件付き分布は
$
  y_t | y_(t-1) ~ N(c + phi y_(t-1), sigma^2)
$
である。したがって
$
  f(y_t | y_(t-1); Theta)
  = frac(1, sqrt(2 pi sigma^2))
    exp(
      - frac((y_t - c - phi y_(t-1))^2, 2 sigma^2)
    )
$
となる。これを積に代入して対数を取ると、条件付き対数尤度は
$
  L(Theta)
  = - frac(T, 2) log(2 pi)
    - frac(T, 2) log(sigma^2)
    - frac(1, 2 sigma^2)
      sum_(t=1)^T (y_t - c - phi y_(t-1))^2
$
である。

$c$ と $phi$ については、対数尤度の第3項に含まれる残差平方和
$
  "SSR"(c, phi)
  = sum_(t=1)^T (y_t - c - phi y_(t-1))^2
$
を最小化すればよい。1階条件は
$
  frac(partial "SSR", partial c)
  = -2 sum_(t=1)^T (y_t - c - phi y_(t-1)) = 0
$
および
$
  frac(partial "SSR", partial phi)
  = -2 sum_(t=1)^T y_(t-1) (y_t - c - phi y_(t-1)) = 0
$
である。これを整理すると正規方程式
$
  sum_(t=1)^T y_t = T c + phi sum_(t=1)^T y_(t-1)
$
$
  sum_(t=1)^T y_(t-1) y_t
  = c sum_(t=1)^T y_(t-1)
    + phi sum_(t=1)^T y_(t-1)^2
$
を得る。

$overline(y)_0 = T^(-1) sum_(t=1)^T y_(t-1)$、$overline(y)_1 = T^(-1) sum_(t=1)^T y_t$ とおくと、第1式から
$
  hat(c) = overline(y)_1 - hat(phi) overline(y)_0
$
である。これを第2式に代入すると
$
  hat(phi)
  =
  frac(
    sum_(t=1)^T (y_(t-1) - overline(y)_0) (y_t - overline(y)_1),
    sum_(t=1)^T (y_(t-1) - overline(y)_0)^2
  )
$
となる。よって、条件付き最尤推定量の $hat(c)$ と $hat(phi)$ は、$y_t$ を定数項と $y_(t-1)$ に回帰したOLS推定量と一致する。

最後に $sigma^2$ について微分する。対数尤度を $sigma^2$ で微分して0とおくと、
$
  - frac(T, 2 sigma^2)
  + frac(1, 2 (sigma^2)^2)
    sum_(t=1)^T (y_t - hat(c) - hat(phi) y_(t-1))^2 = 0
$
である。したがって、撹乱項分散の条件付き最尤推定量は
$
  hat(sigma)^2
  = frac(1, T)
    sum_(t=1)^T (y_t - hat(c) - hat(phi) y_(t-1))^2
$
である。分母は $T-2$ ではなく $T$ になる。

= シミュレーションによる推定

定常なAR(1)過程として
$
  y_t = 2 + 0.8 (y_(t-1) - 2) + u_t,
  quad u_t ~ N(0, 1)
$
を用いた。これは $y_t = c + phi y_(t-1) + u_t$ と書くと、真の値は
$
  c = #true-c, quad phi = #true-phi, quad mu = #true-mu, quad sigma^2 = #true-sigma2
$
である。初期値 $y_0$ は定常分布 $N(mu, sigma^2 / (1 - phi^2))$ から発生させ、$T=100$ の系列を作った。

#figure(
  image("report06_assets/ar1_series.svg", width: 72%),
  caption: [シミュレーションで得た定常AR(1)系列],
)

この系列に対し、上で導出した条件付き最尤推定量を計算した。また、Rの `arima(Y, order=c(1,0,0))` は初期分布を含めた尤度を用いるため、この環境では同じ考え方に対応する正確尤度をPythonで数値最大化した。比較結果は次の通りである。

#table(
  columns: (1.2fr, 1fr, 1fr, 1fr, 1fr),
  inset: 5pt,
  align: center + horizon,
  [方法], [$c$], [$phi$], [$mu$], [$sigma^2$],
  [真の値], [#true-c], [#true-phi], [#true-mu], [#true-sigma2],
  [条件付きMLE], [#cond-c], [#cond-phi], [#cond-mu], [#cond-sigma2],
  [正確尤度], [#exact-c], [#exact-phi], [#exact-mu], [#exact-sigma2],
)

条件付きMLEと正確尤度の推定値は近いが、完全には一致しない。条件付きMLEは $y_0$ を固定された値として扱う一方、正確尤度は $y_0$ が定常分布から発生したことも尤度に含めるためである。$T=100$ では初期値1個の扱いの差がまだ少し残るが、標本数が大きくなるほどこの差は相対的に小さくなる。

= 推定量の分布

さらに、同じ手順を1000回繰り返して $hat(phi)$ の分布を調べた。$phi$ は $0.3$、$0.8$、$-0.5$、標本サイズは $T=50, 100, 400$ とした。表の平均、標準偏差、2.5%点、97.5%点はいずれも1000回の推定値から計算したものである。

#table(
  columns: (0.8fr, 0.8fr, 1fr, 1fr, 1fr, 1fr),
  inset: 4pt,
  align: center + horizon,
  [$phi$], [$T$], [平均], [標準偏差], [2.5%点], [97.5%点],
  [#dist-1-phi], [#dist-1-n], [#dist-1-mean], [#dist-1-sd], [#dist-1-q025], [#dist-1-q975],
  [#dist-2-phi], [#dist-2-n], [#dist-2-mean], [#dist-2-sd], [#dist-2-q025], [#dist-2-q975],
  [#dist-3-phi], [#dist-3-n], [#dist-3-mean], [#dist-3-sd], [#dist-3-q025], [#dist-3-q975],
  [#dist-4-phi], [#dist-4-n], [#dist-4-mean], [#dist-4-sd], [#dist-4-q025], [#dist-4-q975],
  [#dist-5-phi], [#dist-5-n], [#dist-5-mean], [#dist-5-sd], [#dist-5-q025], [#dist-5-q975],
  [#dist-6-phi], [#dist-6-n], [#dist-6-mean], [#dist-6-sd], [#dist-6-q025], [#dist-6-q975],
  [#dist-7-phi], [#dist-7-n], [#dist-7-mean], [#dist-7-sd], [#dist-7-q025], [#dist-7-q975],
  [#dist-8-phi], [#dist-8-n], [#dist-8-mean], [#dist-8-sd], [#dist-8-q025], [#dist-8-q975],
  [#dist-9-phi], [#dist-9-n], [#dist-9-mean], [#dist-9-sd], [#dist-9-q025], [#dist-9-q975],
)

#figure(
  image("report06_assets/phi_distribution.svg", width: 82%),
  caption: [$phi=0.8$ のときの $hat(phi)$ の分布],
)

表から、$T$ が大きくなるほど $hat(phi)$ の標準偏差は小さくなり、分布は真の値の近くに集中することが分かる。これは最尤推定量の一致性を示すシミュレーション結果である。また、$phi=0.8$ のように1に近い場合には、$T=50$ や $T=100$ で平均が真の値よりやや小さくなりやすい。AR(1) の係数推定量には有限標本で下方バイアスが出やすく、系列の持続性が高いほどその影響が目立つためである。$T=400$ では分布の幅がかなり狭くなり、平均も真の値に近づいている。

