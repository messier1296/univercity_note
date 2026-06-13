#import "/template.typ": frame, setup
#show: setup

= 数理解析第六回

数列${a_n}$が劣加法的 (subadditive)

$<=> a_(n+m) <= a_n + a_m forall n,m$

定理 (subadditivity lemma)
$a_n >= 0$で ${a_n}$が劣加法的
$=> lim_(n -> infinity) a_n / n$が必ず有限値として存在する

(proof)

$n$を固定して,$m >n$とする
$
  m = q n + r(0 <= r < n)
$
と書ける

ここで
$
  a_m / m = (a_(q n + r)) /(q n + r) & <= (q a_n + a_r) / (q n + r) \
                                     & <= (q a_n + a_r) / q n \
                                     & = a_n / n + a_r / q n ("右は" m-> infinity"で0に収束") \
$
よって
$lim_(m -> infinity) <= a_n / n$ (limは上極限)


$lim_(m -> infinity) <= lim_(n -> infinity) a_n / n$ (左のlimは上極限右は下極限)
一般に上極限>= 下極限なので

$a_n/n$は収束する

グラフ理論の応用

グラフの彩色:各頂点に色を塗る 隣接する頂点は異なる色

グラフ$G$の彩色数$chi(G)$ グラフ$G$の彩色に必要な最小の色する

七重彩色:各頂点に七色ずつ 与える隣接する二頂点で重複する色を持たない

必要な最小数を$chi_t(G)$: 七重彩色数

二重彩色するとき一重彩色を2つ重ねるとかならず$2 times chi(G)$色でできる

より一般的に$S$重と$t$重から$s + t$重が作れる

ただしもっと少ない色でできる可能性がある

$chi_(s+t) (G) <= chi_s(G) + chi_t(G)$

となる

$chi_n(G) / n$の$n ->$での極限は?

== section6 乱数を使った数値計算

モンテカルロ法がうまく行くpoint

パラメータの空間から欲しい分布にサンプリングが簡単にできる

事象の判定が簡単にできると良い

-> nを大きくしたい

モンテカルロ法の精度

確率空間$X$から$x$をサンプリングする
$i$回目の試行を$X_i$として
$
  X_i = cases(1 "if" x in S, 0 "if" x not in S)
$
そして$(X_1 + dots X_n) / N$ の分布を見る

$X_1 + dots X_N$は二項分布 -> 平均$N P$ 分散$N P (1 - P)$  (p = P[X_i = 1])

$N -> "large"$ で二項分布は正規分布に近づく
$ -> $ 95%信頼区間は1.96 $sigma_N$

標準偏差 $sigma_N = sqrt((N P(1-P))/ N^2) = sqrt((P(1-P)) / N)$

推定値$bar(x)$において$bar(x) plus.minus 1.96 sqrt((P(1-P)) / N)$が95%信頼区間

$sqrt(N)$ぐらいのスピードで収束する

モンテカルロ積分

四分円の例は$f:[0,1] times [0,1] -> R$

$
  f(x) = cases(1 x in S, 0 x in not S)
$
に対して
$integral integral f(x) dif x$
を求めたと言える

一般化すると

領域$D$上の関数 $f(x)$に対して$x in D$を一様ランダムにサンプリング

$f(x)$の平均値を求める

-> $bar(f)$とする

$bar(f) eq.down (integral integral_D f(x) dif x) / |D| -> integral integral_D f(x) dif x eq.down bar(f) |D|$

で求められる

同様の考察で精度は$sqrt(N)$

*演習問題*
確率変数 $X in D$
として$sum f(X) / N$の分数と標準偏差を計算する

またはモンテカルロ法を実行してグラフで精度の変化を見積もる

数値積分はリーマン和をベースに計算する方法が種々ある

低次元ではリーマン和の方が速い
高次元ではリーマン和が遅くなる次元数$h$に対して$O(h^n)$かかる

モンテカルロ法は常に$O(sqrt(n))$の速さで収束するから高次元だと優秀

== section7 常微分方程式

例) 運動方程式

$F = m a = m times d^2/ d t^2 P$

微分を含んだ方程式である

重さ$m$を吊り下げているバネが$x$伸びているばね定数は$k$

$m g - k x = m dif x^2/dif t^2$

ばねの挙動を表す常微分方程式

普通の微分を使った方程式 = 常微分方程式

偏微分を使った方程式 = 偏微分方程式

人口変動の方程式

人口 を$x(t)$,出生率$k$

$-> dif x /dif t = k x$

$x = C e^(k t)$

上界のつく人口変動モデル $r:$自然増加率 $K:$環境収容量

$dif x /dif t = r (K- x)/ k x$

販売数のモデル

$M$ 販売量
$F(t)$ 販売数
$p$ 広告などの増加
$q$ 口コミの効果
$dif F / dif t = (M- F(t)) (p + q F(t) / M)$
