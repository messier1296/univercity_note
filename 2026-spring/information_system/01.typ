#set page(
  paper: "a4",
  margin: (x: 16mm, y: 18mm),
  numbering: "1",
  number-align: bottom + right,
  columns: 2,
)

#set text(
  font: "Noto Serif CJK JP",
  size: 10.5pt,
  fill: rgb("#1d2433"),
)

#show math.equation: set text(font: ("New Computer Modern Math", "Noto Serif CJK JP"))
#set par(justify: true, leading: 0.72em)
#set heading(numbering: "1.")

= 情報システム第一回

== 指数分布

待ち行列モデルの到着間隔は指数分布に従う.

$
  P(X<=x) = 1 - e^(-lambda x)\
  f(x) = lambda e^(-lambda x)
$

$E[x]$を計算しよう

$
  E[X] & = integral^infinity_(0) x f(x) dif x \
       & = integral^infinity_(0) x lambda e^(-lambda x) dif x \
       & = [-x e^(-lambda x)]^infinity_0 + integral^infinity_0 e^(-lambda x) dif x \
       & = - [( e^(-lambda x))/lambda]^infinity_0 \
       & = 1/lambda
$

== ポアソン分布

待ち行列モデルの平均到着人数はポアソン過程になる.

なぜか?

ある一日に訪れる可能性のある人が訪れる確率を$p$,訪れる可能性のある人の人数を$n$とする.

$p$が極めて小さく,$n$が極めて大きいときを考える.

一日に訪れる人数を確率変数とすると$(n,p)$の二項分布になる.

$lambda = n p, n -> infinity, p -> 0$
のときポアソン分布に収束する.

(proof)

$
  P(X = K) & = p^k (1-p)^(n-k) n! / (k! (n-k)!) \
           & = lambda^k / k! (n (n-1) dots (n-k-1)) / n^k (1- lambda/n)^n (1-lambda/n)^k \
           & = (e^(-lambda) lambda^k) / k!
$

== 単一サーバーモデル

系内客数を$N$とすると平均系内客数$E[N]$は
$
  E[N] & = sum^infinity_(n=0) P(N=n) n \
       & = sum^infinity_(n=0) (1- rho) rho^n n \
       & = (1-rho) sum^infinity_(n=0) rho^n n \
       & = rho/(1-rho)
$
//最後の行では無限級数の部分にrhoを掛けて引くと無限等比級数になるのを利用する


