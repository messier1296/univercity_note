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

= 数理解析レポート第二回

202410178
今村隼人

== [演習]

(1) 二項分布 $B(n,p)$ に従う確率変数$X$について,
$
  P(X = k) = binom(n, k) p^k (1-p)^(n-k) quad (k = 0,1,dots,n)
$
であるとき,確率母関数を求めよ.

(2) ポアソン分布に従う確率変数$X$について,
$
  P(X = k) = e^(-lambda) lambda^k / k! quad (k = 0,1,2,dots)
$
であるとき,確率母関数を求めよ.

#v(0.5cm)

== [解答]

確率変数$X$が非負整数値を取るとき,その確率母関数は
$
  P_X(x) = sum_(k=0)^infinity P(X = k) x^k
$
で定義される.

=== (1)

$X$が二項分布$B(n,p)$に従うとする.このとき$X$は$0$から$n$までの値を取るので,
$
  P_X(x) & = sum_(k=0)^n P(X = k) x^k \
         & = sum_(k=0)^n binom(n, k) p^k (1-p)^(n-k) x^k \
         & = sum_(k=0)^n binom(n, k) (p x)^k (1-p)^(n-k)
$
となる.

ここで二項定理
$
  sum_(k=0)^n binom(n, k) a^k b^(n-k) = (a+b)^n
$
を用いると,$a = p x, b = 1-p$として
$
  P_X(x) = ((1-p) + p x)^n
$
を得る.

よって二項分布$B(n,p)$の確率母関数は
$
  P_X(x) = ((1-p) + p x)^n
$
である.

=== (2)

$X$がパラメータ$lambda$のポアソン分布に従うとする.このとき
$
  P_X(x) & = sum_(k=0)^infinity P(X = k) x^k \
         & = sum_(k=0)^infinity e^(-lambda) lambda^k / k! x^k \
         & = e^(-lambda) sum_(k=0)^infinity (lambda x)^k / k!
$
である.

指数関数の級数展開
$
  e^t = sum_(k=0)^infinity t^k / k!
$
を用いると,
$
  sum_(k=0)^infinity (lambda x)^k / k! = e^(lambda x)
$
であるから,
$
  P_X(x) = e^(-lambda) e^(lambda x)
  = e^(lambda (x - 1))
$
となる.

よってポアソン分布の確率母関数は
$
  P_X(x) = e^(lambda (x - 1))
$
である.
