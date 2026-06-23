#import "/template.typ": frame, setup
#show: setup

= 数理解析第二回

== Section2 級数

=== テイラーの定理

#v(0.6em)

$f(x)$が$[a,b]$上で$n$回微分可能

$
  f(b) = sum_(k=0)^(n-1) (f^((k))(a)) / k! (b - a)^k
  + (f^((n))(c)) / n! (b - a)^n
  quad (exists c in (a,b))
$

== マクローリンの定理

$f(x)$が$0$を含む区間$I$上で$n$回微分可能

$=>$ $x in I$に対して

$
  f(x) = sum_(k=0)^(n-1) (f^((k))(0)) / k! x^k
  + (f^((n))(c)) / n! x^n
  quad (c " は " 0 " と " x " の間")
$


$f(x)$が無限回微分可能ならマクローリン展開は形式的には無限に続く

ただし剰余項が$n -> infinity$で$0$に収束するときに限る

マクローリン級数と呼ぶ

$f(x)$が$infinity$回微分可能でも剰余項が$0$に収束するとは限らない

ex)
$
  f(x) = cases(
    e^(-1 / x) quad (x > 0),
    0 quad (x <= 0),
  )
$

この関数は$x = 0$で何回でも微分可能で、すべての$k >= 0$について$f^((k))(0) = 0$となる。

まず$x > 0$で
$
  f'(x) = 1 / x^2 e^(-1 / x)
$
であり、さらに微分を繰り返すと
$
  f^((k))(x) = P_k(1 / x) e^(-1 / x) quad (x > 0)
$
と書ける。ただし$P_k$は多項式である。例えば$e^(-1 / x)$を微分するたびに$1 / x^2$が出てくるので、
$1 / x$の多項式と$e^(-1 / x)$の積の形が保たれる。

ここで$y = 1 / x$とおくと、$x -> 0 +$は$y -> infinity$に対応する。
任意の自然数$m$について
$
  y^m e^(-y) -> 0 quad (y -> infinity)
$
だから、多項式$P_k(y)$を掛けても$P_k(y) e^(-y) -> 0$である。したがって
$
  lim_(x -> 0 +) f^((k))(x) = 0
$
となる。一方$x <= 0$では$f(x) = 0$なので左側ではすべての導関数が$0$である。
よって帰納法により$f^((k))(0) = 0$がすべての$k$で成り立つ。

したがって$f$のマクローリン級数は
$
  sum_(k=0)^infinity (f^((k))(0)) / k! x^k = 0
$
であり、恒等的に$0$である。
しかし$x > 0$では$f(x) = e^(-1 / x) > 0$なので、このマクローリン級数は$f$を表していない。

マクローリン展開できる例

$e^x = 1 + x + 1/2 x^2 + dots$

$sin x = x - 1/3! x^3 + 1/5! x^5 - 1/7! x^7 + dots$

$cos x = 1 - 1/2 x^2 + 1/4! x^4 - 1/6! x^6 + dots$

#frame(title: [オイラーの公式])[

  $x$に$i x$を代入する

  $
    e^(i x) & = 1 + i x - 1/2 x^2 - i / 3! x^3 + 1/4! x^4 + i / 5! x^5 - dots \
            & = cos x + i sin x
  $
]



数列${a_n}$に対して$S_n = sum_(k=1)^n a_k$を部分和という
${S_n}_(n=1)^infinity$を考える

(${S_n}$が収束する$<=>sum_(n=1)^infinity a_n$ が収束する)

#frame(title: [定理2.1])[
  $a_1 > 0, a_2 < 0, a_3 > 0, a_4 < 0 dots$と符号が交互に変わるとき
  $sum_(n=1)^infinity a_n$を交代級数という。ただし$S_n = sum_(k=1)^n a_k$とする。

  このとき${|a_n|}$が単調減少で$lim_(n-> infinity) a_n = 0$なら、級数$sum_(n=1)^infinity a_n$は収束する。

  実際、偶数番目の部分和は
  $
    S_2 <= S_4 <= S_6 <= dots
  $
  と単調増加し、奇数番目の部分和は
  $
    S_1 >= S_3 >= S_5 >= dots
  $
  と単調減少する。また任意の$n$について$S_(2n) <= S_(2n+1)$である。

  よって
  $
    [S_2, S_1] supset [S_4, S_3] supset [S_6, S_5] supset dots
  $
  となる。さらに各区間の幅は
  $
    S_(2n-1) - S_(2n) = -a_(2n)
  $
  であり、$lim_(n-> infinity) a_n = 0$より$0$に収束する。

  区間縮小法により、すべての区間に含まれる定数$alpha$がただ一つ存在する。
  したがって
  $
    lim_(n-> infinity) S_(2n) = lim_(n-> infinity) S_(2n-1) = alpha
  $
  となるので、$lim_(n-> infinity) S_n = alpha$である。
]

例) $ sum_(n=1)^infinity a_n & = 1- 1/2 + 1/3 - 1/4 \
                       & = sum_(n=1)^infinity (-1)^(n-1) 1/n $

$sum_(n=1)^infinity 1/n$は収束しない

$lim a_n = 0$ だけでは級数の収束を保証しない

$
  because sum_(k=1)^n 1/ k >= integral_1^(n+1 ) 1/x dif x = [log x]^(n+1)_1
$
なので$n->infinity$のとき右辺は$infinity$に発散

$a_n= (-1)^(n-1) 1/n$は

$sum_(n=1)^infinity |a_n|$は発散するが、
$sum_(n=1)^infinity a_n$は収束するので条件収束である。

$sum_(n=1)^infinity |a_n|$が収束するとき$sum_(n=1)^infinity a_n$は絶対収束するという

#frame(title: [定理2.2])[
  絶対収束する級数は収束する

  (proof)

  $m > n$として部分和$S_n = sum_(k=1)^n a_k$を考えると
  $
    |S_m - S_n| & = |a_(n+1) + dots + a_m| \
                & <= |a_(n+1)| + dots + |a_m|
  $

  $sum_(n=1)^infinity |a_n|$が収束すると仮定すると

  $forall epsilon > 0 exists N, forall m > n >= N, |a_(n+1)| + dots + |a_m| < epsilon$となる (コーシーの条件)

  $forall epsilon > 0 exists N, forall m > n >= N, |S_m - S_n| < epsilon$が言える。
  よって$sum_(n=1)^infinity a_n$は収束する
]

条件収束のときは$sum_(n=1)^infinity a_n$ は項の順序を変えると収束先が変わる (任意の値に収束させられる)

例) $beta$に収束させたい
$=>$ $beta$を超えたら負項を$beta$を下回るまで足す$beta$を下回ったら正の項を足す

これを無限回繰り返す

一方次が成り立つ

#frame(title: [定理2.3])[
  絶対収束ならば収束先は項の順序に依らない
]
(proofの概略)

$a_n >= 0$の時を考える

$sum_(n=1)^infinity a_n = alpha <=> sum_(n in T) a_n$ の上限が$alpha$ ($T$は${1,dots}$の有限部分集合)

${a_n}$を並び替えたものを${b_n}$とする

各$n$に対して

$ sum_(k=1)^n b_k <= sum_(k=1)^(N_n) a_k $
となる$N_n$が見つかる (${b_1,dots,b_n}$に現れる項がすべて${a_1,dots,a_(N_n)}$に含まれるように$N_n$を選べば良い)

$n -> infinity$として$sum_(k=1)^n b_k <= alpha$となる。
特に$sum^infinity b_n$は上に有界なので収束する

${b_n}$と${a_n}$を入れ替えて同様の議論をすると

$ sum^infinity a_n <= sum^infinity b_n $となり収束先は一致する

一般の場合${a_n}$の非負項を${p_n}$負項を${q_n}$とする

$sum^infinity p_n = A, sum^infinity q_n = B$とする。ただし$q_n$は負項の絶対値とする。

このとき$A,B$がともに有限値に収束する$<=> sum a_n$が絶対収束となっている

${a_n}$の有限部分和$sum_T a_n$を取る

対応する$p_n$の部分和を$A_T$、$q_n$の部分和を$B_T$とすると

$sum_T a_n = A_T - B_T$

極限をとると $sum^infinity a_n = sum^infinity p_n - sum^infinity q_n$となる

ここで右辺は共に並び替えてもよいので左辺も並び替えてよい


#linebreak()

絶対収束する級数同士は以下のように和と積を扱える

$
  (a_0 + a_1 + a_2 + dots + a_n + dots) + (b_0 + b_1 + b_2 + dots + b_n + dots) \
  = (a_0 + b_0) + (a_1 + b_1) + (a_2 + b_2) + dots
$

$
  (a_0 + a_1 + a_2 + dots) (b_0 + b_1 + b_2 + dots)
  = sum_(n=0)^infinity c_n, quad c_n = sum_(k=0)^n a_k b_(n-k)
$

=== 冪級数

$a_0 + a_1 x + a_2 x^2 + dots = sum_(n=0)^infinity a_n x^n$

#frame(title: [定理2.4])[
  冪級数が$x= x_0 != 0$で収束するなら
  + $|x| < |x_0|$ なるすべての$x$で絶対収束する
  + $|x| < |x_0|$ 中の任意の閉区間上で一律に収束する
]

(proof)

$sum_(n=0)^infinity a_n x_0^n$が収束するので,その一般項$a_n x_0^n$は$0$に収束する.
特に有界であり,ある$M > 0$が存在して
$
  |a_n x_0^n| <= M
$
となる.

$|x| < |x_0|$とすると
$
  |a_n x^n|
  = |a_n x_0^n| (|x| / |x_0|)^n
  <= M (|x| / |x_0|)^n
$
である.
$|x| / |x_0| < 1$なので右辺は等比級数として収束する.
比較判定法より$sum a_n x^n$は絶対収束する.

また$|x| <= r < |x_0|$を満たす閉区間上では
$
  |a_n x^n| <= M (r / |x_0|)^n
$
がすべての$x$について成り立つ.
右辺の級数は収束するので,ワイエルシュトラスの判定法により一律収束する.

この定理より,冪級数には中心$0$からある距離までは収束し,それより外では発散するという境目がある.
この境目を収束半径という.



#frame(title: [コーシーアダマールの定理])[

  冪級数の収束半径$r_0$について
  $1 / r_0 = limsup_(n-> infinity) root(n, |a_n|)$
  が成り立つ
]

ここで$limsup$は上極限である.
通常の極限$lim root(n, |a_n|)$が存在するなら,それと$limsup root(n, |a_n|)$は一致する.
したがって係数$a_n$の大きくなり方が速いほど収束半径は小さくなる.

#frame(title: [ダランベールの定理])[
  冪級数の収束半径$r_0$について
  $lim_(n-> infinity) (|a_(n+1)|) / (|a_n|)$が存在すれば
  $
    1/ r_0 = lim_(n-> infinity) (|a_(n+1)|) / (|a_n|)
  $
  が成り立つ
]

これは比の形で収束半径を求める方法である.
例えば$a_n = 1 / n!$なら
$
  |a_(n+1)| / |a_n| = 1 / (n+1) -> 0
$
なので$1 / r_0 = 0$,すなわち$r_0 = infinity$となる.
したがって$e^x = sum_(n=0)^infinity x^n/n!$はすべての$x$で収束する.

冪級数は収束半径内で和と積を定められる

$
  (sum_(n=0)^infinity a_n x^n) + (sum_(n=0)^infinity b_n x^n)
  = sum_(n=0)^infinity (a_n + b_n) x^n
$

$
  (sum_(n=0)^infinity a_n x^n) (sum_(n=0)^infinity b_n x^n)
  = sum_(n=0)^infinity (sum_(k=0)^n a_k b_(n-k)) x^n
$


$sum^infinity a_n x^n$は収束半径内で$x$の連続関数で$infinity$回微分可能

$f^((k)) (x) = sum_(n=k)^infinity n(n-1) dots (n-k+1) a_n x^(n-k)$
となる


確率変数$X$が非負整数値を取るとき

$P(X = k) = p_k$のとき $P_X(x) = sum_(k=0)^infinity p_k x^k$
を$X$の確率母関数という

#frame(title: [演習])[
  (1) 二項分布 $B(n,p)$ $p(k) = binom(n, k) p^k (1-p)^(n-k)$

  (2) ポアソン分布$p(k) = e^(-lambda) (lambda^k) / k!$
  それぞれの確率母関数を求める

  (1)
  $
    P_X(x)
    = sum_(k=0)^n binom(n,k) p^k (1-p)^(n-k) x^k
    = sum_(k=0)^n binom(n,k) (p x)^k (1-p)^(n-k)
    = ((1-p) + p x)^n
  $

  (2)
  $
    P_X(x)
    = sum_(k=0)^infinity e^(-lambda) lambda^k / k! x^k
    = e^(-lambda) sum_(k=0)^infinity (lambda x)^k / k!
    = e^(-lambda) e^(lambda x)
    = e^(lambda (x-1))
  $
]
