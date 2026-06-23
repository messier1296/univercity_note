#import "/template.typ": frame, setup
#show: setup

= 数理解析第二回

== 前回の課題

(1) 二項分布$B(n,p): P_k = binom(n, k) p^k (1-p)^(n-k)$
の確率母関数を考える

$
  P_(B_(m,k)) & = sum_(k=0)^infinity binom(n, k) p^k (1-p)^(n-k) x^k \
              & = sum_(k=0)^n binom(n, k) (p x)^k (1-p)^(n-k) \
              & = (p x + (1-p))^n (because"二項定理")
$

(2)
ポアソン分布 $P(lambda)$

$P_k = e^(-lambda) lambda^k / k!$

$
  P_(P_(0,lambda)) (x) & = sum_(k=0)^infinity e^(-lambda) lambda^k / k! x^k \
                       & = sum_(k=0)^infinity e^(-lambda) (lambda x )^k / k! \
                       & = e^(-lambda) times e^(lambda x) (because e^x = sum_(k=0)^infinity 1/k! x^k) \
                       & = e^(lambda(x-1))
$

== 冪級数 $sum_(n=0)^infinity a_n x^n$ の微分

$k$回微分: $f(x)^((k)) = sum_(n=k)^infinity n(n-1) dots (n-k+1) a_n x^(n-k)$

$f(x) = a_0 + a_1 x + a_2 x^2 dots$

$f'(x) = a_1 + 2 a_2 x + 3a_3 x^2 dots$

$f$と$f'$は同じ収束半径
$because 1/r_0 = lim_(n-> infinity) root(n, |a_n|)$

$f'$の係数は$(n+1) a_(n+1)$なので

$
  1/r_1 & = lim_(n-> infinity) root(n, |(n+1) a_(n+1)|) \
        & = lim_(n-> infinity) root(n, n+1) root(n, |a_(n+1)|) \
        & = 1 times 1/r_0
$

$therefore r_1 = r_0$

$root(n, n+1) -> 1$なので、$n$をかけても収束半径は変わらない

項別に微分は無限和に対してやっていいのか?

$->$収束半径内ではやっていい(証明は難しいので省略)

確率母関数$P_X(x) = p_0 + p_1 x + p_2 x^2 dots$

$P'_X(x) = p_1 + 2p_2 x + 3 p_3 x^2 + dots$

$P'_X(1) = p_1 + 2p_2 + 3p_3 + dots = E[X]$

$P''_X (x) = 2p_2 + 6p_3 x + 12 p_4 x^2 dots$

$P''_X (1) = 2 p_2 + 6p_3 + 12 p_4 dots = E[X(X-1)]$

$
  V[X] & = E[X^2] - (E[X])^2 \
       & = P ''_X(1) + P'_X(1) - P'_X(1)^2
$



二項分布 $P_(B_(n,k)) (x) = ((1-p) + p x)^n$

$P'_(B_(n,k)) (x) = n((1-p) + p x)^(n-1) p$

$P'_(B_(n,k)) (1)= n((1-p) + p)^(n-1) p = n p = E[B_(n,k)]$

$P ''_(B_(n,k))(x) = n(n-1) ((1-p) + p x)^(n-2) p^2$

$P ''_(B_(n,k)) (1) = n(n-1) ((1-p) + p)^(n-2) p^2$

#pagebreak()

$
  V[B_(n,k)] & = P ''(1) + P'(1) - (P'(1))^2 \
             & = n(n-1) p^2 + n p -(n p)^2 \
             & = - n p^2 + n p \
             & = n p (1-p)
$

$x=1$が収束半径に入っていることが仮定されている


ポアソン分布 $P_(0, lambda)$ の場合

$P_X(x) = e^(lambda(x-1))$

$P'_X(x) = lambda e^(lambda(x-1))$

$P'_X(1) = lambda = E[X]$

$P''_X(x) = lambda^2 e^(lambda(x-1))$

$P''_X(1) = lambda^2$

$
  V[X] & = P''_X(1) + P'_X(1) - P'_X(1)^2 \
       & = lambda^2 + lambda - lambda^2 \
       & = lambda
$

確率母関数の収束半径は$1$以上

$because |x| <= 1$として$sum_(n=0)^infinity |P_(n) x^n| = sum_(n=0) P_n |x|^n <= sum_(n=0)^infinity P_n = 1$

最後は確率分布だから$1$に収束

収束半径が$1$のときはアーベルの定理から大丈夫

アーベルの定理:

$sum_(n=0)^infinity a_n$が収束して、その和を$s$とする。

$f(x) = sum_(n=0)^infinity a_n x^n$とおくと、

$
  lim_(x -> 1-0) f(x) = s
$

つまり、境界$x=1$で級数が収束していれば、内側から$x -> 1$としても同じ値に近づく。

確率母関数では$sum_(n=0)^infinity p_n = 1$なので、

$
  lim_(x -> 1-0) P_X(x) = 1
$

== section3 線形代数
// 線形空間などを俯瞰してみる
// 自分が知ってる分野でどのように使うか調べる

=== 基底

線形代数 = 線形空間(ベクトル空間)の理論 ベクトルや行列はそれを表現するもの

線形空間: 線形性を持つ空間

線形性: $a in V => k a in V$  $a,b in V => a + b in V$という性質をもつ($k$は実数 ほかはベクトル)

ベクトル空間は$cases("定数倍", "和")$が定義できる

ベクトル空間の公理

$(x + y) + z = x + (y + z)$

$x + y = y + x$

$exists o s,t, forall x in V x + o = x$

$forall x in V, exists -x in V s,t, x + (-x) = o$

$1 x = x$

$a (b x) = (a b) x$

$(a + b) x = a x + b x$

$a (x + y) = a x + a y$

$(0 in K) x = o$

$a o = o$

ベクトル空間の公理は和と積が自然に満たす計算ができるだけ

線形性があることによって$bold(a)$があれば$k bold(a)$の形のベクトルはすべて生成できる

$bold(a)$と$bold(b)$があれば$bold(a) + bold(b)$の形が作れる

また$k bold(a) + l bold(b)$という形がすべて生成できる

$->$ $V$全体を生成するためにはいくつかの代表的なベクトルで十分

$->$ $V$全体を生成できる必要最小限のベクトル集合が欲しい

$->$ *基底*

必要最小限のベクトル集合
$<=>$
このベクトル集合のどの一つが書けても足りなくなる

$<=>$
この集合のどの一つのベクトルも他のベクトルたちで書くことができない

$<=>$
*一次独立*である

#frame(title: [定理3.1])[
  ${bold(a)_1 dots bold(a)_n}$が一次独立
  $<=>$
  $
    k_1 bold(a)_1 + k_2 bold(a_2) dots + k_n bold(a)_n = 0
  $<one>
  を満たすのは

  $(k_1 dots k_n) = (0, dots, 0)$ のみ

  もしある$k_i$が0でない形で@one が成り立つとすると
  $
    a_i = 1/(k_i) (-k_1 a_1 dots -k_(i-1) a_(i-1) -k_(i+1) a_(i+1) dots)
  $
  と書けてしまう一次独立の定義に反している
]
${bold(a)_1 dots bold(a)_n}$が$V$の基底

$<=>$
${bold(a_1) dots bold(a_n)}$が一次独立でかつ$V = {k_1 bold(a)_1 + dots + k_n bold(a)_n}$となる

一次独立なセットでできるだけ多くのベクトルを含んでいれば良い?

#frame(title: [定理3.2])[
  ベクトル空間$V$において${bold(a)_1 dots bold(a)_k}$と${bold(b)_1 dots bold(b)_l}$がそれぞれ基底ならば$k = l$

  (proof)

  $k < l$とする

  ${bold(a)_1 dots bold(a)_k}$は$V$の基底なので$bold(b)_i = C_(i,1) bold(a)_1 + dots + C_(i,k) bold(a)_k$とかける

  すると

  $
    lambda_1 bold(b)_1 + dots + lambda_l bold(b)_l \
                                                 & = lambda_1(C_11 bold(a)_1 + dots + C_(1k) bold(a)_k) \
                                                 & + lambda_2(C_21 bold(a)_1 + dots + C_(2k) bold(a)_k) \
                                                 & + dots \
                                                 & + lambda_l (C_(l,1) bold(a)_1 + dots C_(l k) bold(a)_k)
  $<sum>
  としたとき
  ${bold(b)_1 dots bold(b)_l}$は基底なので一次独立だから
  $(lambda_1 ,dots lambda_l) = (0,dots,0)$のはず

  一方@sum の部分は

  $
    (lambda_1 C_11 + lambda_2 C_21 + dots + lambda_l C_(l 1)) bold(a)_1\
    &+
    (lambda_1 C_12 + lambda_2 C_22 + dots + lambda_l C_(l 2)) bold(a)_2\
    &+ dots \
    &+
    (lambda_1 C_1k + dots + lambda_l C_(l k)) bold(a)_k\
  $
  となっている
  ここで${bold(a)_1 dots bold(a)_k}$は基底なので一次独立だから
  $
    lambda_1 C_11 + dots + lambda_l C_(l,1) = 0\
    dots.v\
    lambda_1 C_1k + dots + lambda_l C_(l,k) =0
  $
  変数$l$個の$k$個の線形連立方程式のはず

  今$k < l$としているので,未知数の方が方程式より多い.
  よって同次連立方程式には$(lambda_1 dots lambda_l) = (0,dots,0)$以外の解がある.

  その非自明解を使うと
  $
    lambda_1 bold(b)_1 + dots + lambda_l bold(b)_l = 0
  $
  となるので,${bold(b)_1 dots bold(b)_l}$の一次独立性に矛盾する.

  $k<l$と仮定すると矛盾したので$k >= l$である.

  $a$と$b$を入れ替えれば$l >= k$も成り立つので$k = l$
]

↑線形代数の抽象論の証明では線形方程式の理論が密接にリンクしている事がわかる

この性質によりベクトル空間の次元が定まる

$V$の次元 = 基底の要素数
(有限次元として)

$V$の基底はgreedyに見つけることができる

${bold(a)_1 dots bold(a)_k}$が一次独立として基底でない

$<=>$ $k<d$で$bold(a)_1$から$bold(a)_k$までの線形結合で書けない$bold(a)_(k+1) in V$がある

すると${a_1 dots a_k} union {a_(k+1)}$で一次独立なものを作れる

$d$本揃うまで続けて基底を得られる

=== 線形写像

線形性を保った写像のこと

$
  cases(f(k bold(a)) = k f(bold(a)), f(bold(a) + bold(b) ) = f(bold(a)) + f(bold(b)))
$
を満たしている写像

$V$での演算の構造と$f(V)$での演算の構造が同じ形になっている

有限次元ベクトル空間$V,W$が同じ体上で定義されているとき,

$dim V = dim W$
$<=>$ $V$と$W$の間に線形な全単射が存在する

つまり有限次元ベクトル空間は,体を固定すれば次元のみで分類できる.

ただし,任意の線形写像$f:V -> W$が$dim V = dim W$だけで全単射になるわけではない.
例えば零写像は次元が同じでも全単射ではない.

与えられた線形写像$f$が全単射

$<=>$ $V$の基底${bold(e)_1 dots bold(e)_n}$に対して${f(bold(e)_1) dots f(bold(e)_n)}$が$W$の基底になる

特に$dim V = dim W = n$のときは,$f$が全単射であることと$"rank"(f) = n$であることは同値である.

=== 行列,数ベクトルとベクトル空間

$V$の基底${bold(e)_1 dots bold(e)_n}$を一つ固定すると

$
  bold(a) in V & <=> bold(a) = a_1 bold(e)_1 + dots * a_n bold(e)_n "と一意に表せる" \
               & <=> bold(a) : binom(a_1, dots.v, a_n) "と対応できる"
$

線形写像$f$もこの表現の中で表せる

$->$ 表現行列 $f(bold(a))$を$A(a_1 dots a_n)$と対応できる

線形写像は行列で表現できるのが便利

=== ランク

ベクトルの集合${bold(a)_1,dots,bold(a)_k}$の中の一次独立なものの最大数

$=$ $A= (bold(a)_1 dots bold(a)_k)$のランク

$=$ $A$の行基本変形でにしたときの段数

$=$ $A$の行,列変形で 1が斜めに続いている部分の段数


演習

$
  vec(1, 0, 0, 1) vec(0, 1, 0, 1) vec(1, 1, 0, 2) vec(2, 0, 0, 2) vec(2, 1, 0, 3) vec(0, 1, 1, 2) vec(1, 1, 1, 3)
$

この中からできるだけ多い本数からなる一次独立なベクトル集合を一つ見つけ

(1) 一次独立であることを示す

(2) その本数が最大であることを示す

(解答)

以下の3本を取る.
$
  v_1 = vec(1, 0, 0, 1),
  quad
  v_2 = vec(0, 1, 0, 1),
  quad
  v_6 = vec(0, 1, 1, 2)
$

まず一次独立性を示す.
$
  alpha v_1 + beta v_2 + gamma v_6 = 0
$
とすると,成分ごとに
$
  vec(alpha, beta + gamma, gamma, alpha + beta + 2 gamma) = vec(0,0,0,0)
$
である.
第1成分から$alpha = 0$,第3成分から$gamma = 0$,第2成分から$beta = 0$となる.
よってこの3本は一次独立である.

次に最大性を示す.
与えられたすべてのベクトルは
$
  x_4 = x_1 + x_2 + x_3
$
を満たしている.
したがってこれらは$RR^4$の中の3次元部分空間
$
  {vec(x_1,x_2,x_3,x_4) | x_4 = x_1 + x_2 + x_3}
$
に含まれる.
よって4本以上の一次独立な集合は取れない.
3本の一次独立な集合が見つかったので,最大本数は3本である.
