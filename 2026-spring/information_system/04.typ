#import "../../template.typ": frame, setup
#show: (setup)

= 情報システム第4回

== ファイナンスの確率過程と価格決定アルゴリズム

=== 確立過程

確率:ある時点での不確実性を扱う

確立過程:時間発展を含む不確実性を扱う

*株価時系列は予測不可能*ということは一番最初に習う

しかし注文なら予測可能である

==== なぜ注文は予測できて株価は予測できないか?

一度買い注文が観測されるとしばらく買いが観測される.これを*注文流は長期記憶性を持つ*という

長期的な需給の不均衡は用意に予測可能

*注文分割行動*と*価格インパクト*

- 注文分割行動 大量の注文を執行するときに行われる実務行動
- 価格インパクト: 注文分割による価格変動

==== 注文分割

自社で抱える顧客の「大量の注文」の購入時

株式を安く買うために複数回の注文に分割して購入する.

一度に大量に購入すると株価が一気に上昇してしまい損になる

ex) 5分ごとに買い注文を出すと自明に自己相関が発生する

LMFモデルで予測可能

==== 注文分割者の価格インパクト

予測では注文量$Q$に比例して価格が変動する実務では$sqrt(Q)$に比例することがわかった

===== べき指数0.5は普遍指数なのか?

- 賛成派のモデル:latent order book model
- 反対派のモデル: FGLWモデル,GGPSモデル


=== single queue model

各時刻に注文がランダムに
- 増えるイベント: $lambda$
- 減るイベント: $k$
という確率で訪れるとする

あるQueueのｚ幼体を$V_t$とする

Queueの時間発展方程式は

$
  V_(t+1) = cases(V_(t + 1)("probably" lambda), V_(t - 1)(k), V_t (1-lambda-k))
$

$
  V_(t+1) - V_(t) = cases(+1(lambda), -1(k), 0(1-lambda,k))
$

$f_t (V) = V_t$として記述する

$
  f_(t+1) (V) - f_t (V) = cases(f_t (V+1) - f(V) (lambda), f_t(V-1) - f(V) (k), f(V)-f(V) = 0(1-lambda-k))
$

両辺の期待値を取る

$
  sum_V P_t (V)[f_(t+1) (V)-f_t (V)] = sum_V P_t (V) [lambda(f_t (V+1) -f_t (V)) + k (f_t (V-1) - f_t (V))]
$

部分積分する

ここで使っている部分積分は,離散和で添字をずらす操作である.
例えば境界項が無視できるとして,

$
  sum_V P_t (V) f_t (V+1)
  = sum_U P_t (U-1) f_t (U)
  = sum_V f_t (V) P_t (V-1)
$

となる.同様に,

$
  sum_V P_t (V) f_t (V-1)
  = sum_U P_t (U+1) f_t (U)
  = sum_V f_t (V) P_t (V+1)
$

である.したがって,$f_t (V+1)$や$f_t (V-1)$にかかっていた差分を,
$P_t (V)$側の差分として書き直せる.

$
  sum_V f_t (V) Delta P_t (V) = sum_V f_t (V)[lambda[P_t (V-1) - P_t (V)] + k(P_t (V+1) - P_t (V))]
$

$
  Delta P_t (V) = lambda P_t (V-1) + k P_t (V+1) - (lambda + k) P_t (V)
$

$Delta P_t (V) -> sum e^(-g) Delta P_t (V) = s P_s (V)$とすると

$
  s P_s(V) = lambda P_s (V-1) + k P_s (V-1) - (lambda+k) P_s (V)
$

$
  sum f_t (V) Delta_t P(V) = sum_V f_t(V) [lambda(P_t (V-1) - P_t (V)) + k(P_t (V-1) - P_t (V))] + sum_V sum_L rho(L) delta(V-1) (f(L) - f(1))P_t (V)\
  Delta_t P(hat(V)) = lambda P_t (hat(V) - 1) + k P_t (hat(V) + 1) - P_t (hat(V)) (lambda + k)\
  sum_V sum_L rho (L) delta(V-1) delta(hat(V) - L) P_t (V)\
  = sum_V rho(hat(V)) delta(V-1) P_t (V)\
  = rho(hat(V)) P_t (1)\
$

$
  V_(t + dif t) - V_t = cases(+1 lambda dif t, -1 k dif t, -1 V_t eta dif t)\
  f_(t+ dif t) -f_t (V) = cases(f_t (V+1) - f_t (V) lambda dif t, f_t(V-1) - f_t (V) k dif t, f_t (V-1) - f_t (V) V_t eta dif t)\
  sum [f_(t+dif t) - f_t ] P_t (V) = sum P_t (V) [lambda dif t [f_t (V+1) - f_t (V)] + k dif t[f_t (V-1) - f_t (V)] + V_t eta dif t [f_t(V-1 - f_t(V))]]\
  partial / partial t P_t (V) = lambda P_t(V-1) + k P_t (V+1) + eta (V_t + 1) P_t (V+1) - (lambda + k - eta V_t) P_k (V)\
$
