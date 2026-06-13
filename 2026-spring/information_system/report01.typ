#import "../../template.typ": frame, setup
#show: (setup)

= 情報システムレポート

202410178 今村隼人

== 第一問

確率変数$X$が二項分布に従う場合$X$の母関数,期待値,分散を求めよ

=== 母関数

$
  G(s) = E[s^x] & = sum_(k=0)^(k=n) s^x binom(n, k) p^x (1-p)^x \
                & = sum_(k=0)^(k=n) binom(n, k) (p s)^x (1-p)^x \
                & = (p s + 1 - p)^n (because "二項定理")
$

=== 期待値
$
  G'(s) = n p(p s + 1 - p)^(n-1)\
  E[X] = G'(1) = n p
$

=== 分散

$
  G''(s) & = n (n-1) p^2(p s + 1 -p)^(n-1) \
    V[X] & = G''(1) + G'(1) - G'(1)^2 \
         & = n(n-1)p^2 + n p - (n p)^2 \
         & = n p(1 - p)
$

== 第二問

確率変数$X$がパラメータ$lambda$の ポアソン分布に従う場合$X$の母関数,期待値,分散を求めよ

=== モーメント母関数

$
  G(s) = E[s^X] & = sum_(k=0)^(k=n) s^k (e^(-lambda) lambda^k) / k! \
                & = sum_(k=0)^(k=n) (s^k ( lambda^k)) / k! e^(-lambda) \
                & = e^(lambda s) e^(-lambda) (because e^x = x^k/k!) \
                & = e^(lambda(s-1))
$

=== 期待値

$
  G'(s) = lambda e^(lambda(s-1))\
  E[X] = G'(1) = lambda
$

=== 分散

$
  G''(s) & = lambda^2 e^(lambda(s-1)) \
    V[X] & = G''(1) + G'(s) - G'(s)^2 \
         & = lambda^2 + lambda - lambda^2 \
         & = lambda
$

