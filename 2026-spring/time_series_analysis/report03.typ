#import "/template.typ": setup
#show: setup

#import "report03_assets/gdp_summary.typ": *
#import "report03_assets/white_noise_summary.typ": *

#align(center)[
  #text(size: 15pt, weight: "bold")[計量時系列分析 第3回課題]

  #v(4mm)
  202410178 今村隼人
]

= 弱定常であるが強定常ではない過程

確率過程 ${x_t}$ を、各時点で独立であり、奇数時点では
$
  x_t ~ N(0, 1)
$
偶数時点では
$
  P(x_t = 1) = P(x_t = -1) = 1/2
$
に従うものとして定義する。すなわち、奇数時点と偶数時点で周辺分布は異なるが、各時点の変数は互いに独立である。

各時点で
$
  E(x_t) = 0, quad "Var"(x_t) = 1
$
であり、異なる時点の変数は独立なので、$h != 0$ について
$
  gamma(h) = "Cov"(x_t, x_(t-h)) = 0
$
である。したがって、平均は時点に依存せず、自己共分散もラグ $h$ のみに依存するため、この過程は弱定常である。

一方で、1次元の分布は時点によって異なる。たとえば奇数時点では連続分布 $N(0,1)$ であるのに対し、偶数時点では $-1$ と $1$ のみを取る離散分布である。時点を1期ずらすだけで周辺分布が変わるため、任意の時点シフトに対して結合分布が不変であるとはいえない。したがって、この過程は強定常ではない。

= ホワイトノイズを用いた基礎的な定常過程

課題のモデル
$
  y_t = mu + w_t, quad w_t ~ "WN"(sigma^2)
$
を考える。ホワイトノイズの定義より
$
  E(w_t) = 0, quad "Var"(w_t) = sigma^2, quad "Cov"(w_t, w_(t-h)) = 0 space (h != 0)
$
である。したがって
$
  E(y_t) = E(mu + w_t) = mu
$
であり、平均は時点 $t$ に依存しない。また、
$
  "Var"(y_t) = "Var"(mu + w_t) = "Var"(w_t) = sigma^2
$
である。自己共分散は
$
  gamma(h)
  = "Cov"(y_t, y_(t-h))
  = "Cov"(mu + w_t, mu + w_(t-h))
  = "Cov"(w_t, w_(t-h))
$
なので、
$
  gamma(0) = sigma^2, quad gamma(h) = 0 space (h != 0)
$
となる。これはラグ $h$ のみに依存し、時点 $t$ には依存しない。よって、このモデルは弱定常過程である。


Excelでは、A列に $t=1,2,dots,100$ を入力し、標準正規乱数を
`=NORM.S.INV(RAND())`
で発生させた。さらに、(a) については
`=1+B2`、(b) については
`=2+2*B2`
として、同じ標準正規乱数から
$
  y_t = mu + sigma z_t, quad z_t ~ N(0, 1)
$
を作成した。なお、Excelの `RAND()` は再計算のたびに値が変わるため、図示した後に値を貼り付けて固定した。

#figure(
  image("report03_assets/white_noise_excel.svg", width: 95%),
  caption: [Excelで発生させた正規ホワイトノイズから作成した $y_t$ の標本系列（$T=100$）],
)

得られた標本平均と標本分散は次の通りである。

#table(
  columns: (1.4fr, 1fr, 1fr),
  inset: 5pt,
  align: center + horizon,
  [設定], [標本平均], [標本分散],
  [$(mu, sigma) = (1, 1)$], [#a_mean], [#a_var],
  [$(mu, sigma) = (2, 2)$], [#b_mean], [#b_var],
)

どちらの系列も平均の周りを不規則に変動しており、明確なトレンドや周期的な動きは見られない。(b) は (a) と同じ乱数を用いているため動きの形は同じであるが、平均が 2 に移り、標準偏差が 2 倍になっている。そのため、標本分散もおよそ 4 倍になっている。

= 実質季節調整GDPの分析

「実質季節調整系列／国内総生産（支出側）」を用いた。対象期間は #gdp_start から #gdp_end までであり、GDP原系列の観測数は #gdp_n、対数差分系列の観測数は #dlog_n である。GDPを $y_t$ とし、対数系列を $log y_t$、対数差分系列を
$
  Delta "log" y_t = "log" y_t - "log" y_(t-1)
$
とした。また、通常の変化率を
$
  g_t = (y_t - y_(t-1)) / y_(t-1)
$
として計算した。

#figure(
  image("report03_assets/gdp_transformations.svg", width: 100%),
  caption: [実質季節調整GDPの原系列、対数系列、対数差分系列],
)

#figure(
  image("report03_assets/gdp_growth.svg", width: 92%),
  caption: [実質季節調整GDPの変化率],
)

原系列は長期的には上昇傾向を持つが、リーマンショック期、2020年前後の新型コロナウイルス感染症の時期には大きく落ち込んでいる。対数系列でも同じ動きが確認できるが、対数を取ることで水準の大きさによる変動幅の差がややならされる。対数差分系列と変化率はほぼ同じ形をしており、通常の四半期成長率が小さい範囲では $Delta "log" y_t approx g_t$ という近似がよく成り立つ。ただし、2020年のように変化が大きい時期には、近似誤差も相対的に大きくなる。

== 対数差分系列の自己共分散と自己相関

対数差分系列 $x_t = Delta "log" y_t$ について、標本平均を $overline(x)$、観測数を $T$ とし、ラグ $k$ の標本自己共分散を
$
  hat(gamma)_k = 1 / T sum_(t=k+1)^T (x_t - overline(x))(x_(t-k) - overline(x))
$
自己相関を
$
  hat(rho)_k = hat(gamma)_k / hat(gamma)_0
$
として計算した。標本平均と分散は
$
  overline(x) = #dlog_mean, quad hat(gamma)_0 = #dlog_var
$
である。

#table(
  columns: (0.7fr, 1.4fr, 1.4fr),
  inset: 5pt,
  align: center + horizon,
  [$k$], [自己共分散 $hat(gamma)_k$], [自己相関 $hat(rho)_k$],
  [0], [0.00015073], [1.00000000],
  [1], [-0.00001335], [-0.08853765],
  [2], [0.00002397], [0.15901064],
  [3], [-0.00002422], [-0.16069703],
  [4], [-0.00001637], [-0.10859351],
  [5], [-0.00000539], [-0.03577215],
  [6], [-0.00000582], [-0.03863114],
  [7], [0.00000703], [0.04660853],
  [8], [-0.00001543], [-0.10238558],
  [9], [0.00000217], [0.01440565],
  [10], [-0.00000913], [-0.06058239],
)

白色雑音を帰無仮説とする自己相関の目安として、棄却点を $plus.minus 1.96 / sqrt(T)$ とすると、今回の値は $plus.minus #acf_bound$ である。10次までの自己相関はいずれもこの範囲内にあり、強い系列相関は見られない。

#figure(
  image("report03_assets/gdp_acf.svg", width: 82%),
  caption: [対数差分系列の10次までのコレログラム],
)

== Rによる確認

Rで同じ計算を確認するため、次のようにCSVを読み込み、GDP列を数値化してから対数差分と自己相関を計算した。

```r
data <- read.csv("gaku-jk2542.csv", header = FALSE, sep = ",",
                 fileEncoding = "CP932", skip = 7)
gdp <- as.numeric(gsub(",", "", trimws(data$V2)))
grate <- diff(log(gdp))

ts.plot(grate)
grate_acf <- acf(grate, lag.max = 10)
grate_acf
```

Rの `acf` は、対数差分系列から平均を引き、ラグごとの自己共分散を0次の自己共分散で割って自己相関を求める。上の表と同じ定義であるため、10次までの自己相関はコレログラムの値と一致する。

