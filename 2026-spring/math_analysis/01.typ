#set page(
  paper: "a4",
  margin: (x: 16mm, y: 18mm),
  numbering: "1",
  number-align: bottom + right,
  columns: 2
)

#set text(
  font: "Noto Serif CJK JP",
  size: 10.5pt,
  fill: rgb("#1d2433"),
)

#show math.equation: set text(font: ("New Computer Modern Math", "Noto Serif CJK JP"))
#set par(justify: true, leading: 0.72em)
#set heading(numbering: "1.")

= 数理解析第一回

#v(1cm)

確認テスト 80% 6/26(金)

レポート 20% 翌週火曜日まで

シラバスとは内容が変わっている.
前半5週 一年の微積線形の続き

教科書:『解析概論』高木貞治

== Section 1 数列の極限

=== 実数とは?

直線上の各点に対応している.
{整数}$in${有理数}$in${実数}

実数の性質
+ 全順序が定められている(大小が評価できる) //{Ord,PartialEq} Traitをもつ?
+ 連続性を持つ集合

=== 実数の連続性


定理(1.1) デデキントの定理
実数の集合を$A,B$ 2つに分け,$a in A,b in B$なら$a <b$となっているとする.

するとある一つの実数$s$が存在して
- $s in A$ $s$は$A$の最大数
- $s in B$ $s$は$B$の最小数
のどちらかである- (1)

*デデキントの切断*という

(1) $A$と$B$の境界はどちらかが開区間,
もう一方は閉区間になる.
$A$と$B$に隙間が発生することはない.

note:有理数の集合では(1)が成り立たない,つまり連続ではない
任意の無理数を$s$に設定することでわかる.

//デデキントの切断により実数が定義されるらしい?

=== 実数の集合の有界性

実数の集合$A$が上に有界 $<=>$ある$M$に対して$forall a in A, a <= M$

note:MはAに入っていてもいなくてもよい

このとき,このような$M$を$A$の上界という.

同様に実数の集合$A$が下に有界 $<=>$ ある$M$に対して$forall a in A, M <= a$

$M$を$A$の下界という.

定理 1.2 ワイヤシュトラスの定理

集合Aが上に有界であるときその上界の集合は最小元を持つ

(Proof)

$x$を集合$A$の上界とすると,$x <= y$なる任意の$y$は$A$の上界となる.

したがって$A$の上界すべての集合を$Y$としてそれ以外を$X$とすると,$(X,Y)$は切断となり,その境に実数$s$が定まる.この$s$は$X$には属さない.

背理法
$because$ $s$が$X$に属すると仮定する.

$<=>$ $s$は$Y$に属さない $<=>$ $s$は$A$の上界ではない.
$<=>$ $(forall a in A, a<= s)$
$<=>$ $exists a in A,not(a <= s)$

$s$と$a$の間に$s prime$が存在する.この$s prime$は
$s < s prime < a$となっているので $s prime$は$A$の上界ではない.
$s prime$は$s$より大きい$X$の要素なので切断$(X,Y)$の切断点ではないので矛盾する.
よって$s$は$X$に属さない. $=>$ $s$は$Y$に属して$Y$の最小元.

上界の最小限がある $=>$ 上限
下界の最小限がある $=>$ 下限

定理1.3

単調増加する数列(単調非減少) ${a_n}$が上に有界ならば収束する.


(Proof) $A = {a_n}_(n=1)^infinity$とする
$A$は上に有界.
ワイヤシュトラスの定理により$A$の上限$alpha$が存在する ($A$の上界の集合の最小元)

この$alpha$が$lim_(n->infinity) a_n = alpha$となることを示す.

$<=>forall epsilon > 0, exists N, forall n >= N, |a_n - alpha| < epsilon$を示す

// なぜこれを示すとalphaに収束したことになるのか?


$epsilon > 0$を任意に一つとる.

$alpha prime = alpha - epsilon$とする.

$alpha$は$A$の上限($A$の上界の最小元)なので,$alpha prime$は($alpha prime < alpha$なので)$A$の上界ではない.

$=> exists a_i in A, alpha prime < a_i$だから上限じゃない.

この$i$を$N$と置くと$alpha prime < a_N <= alpha$となっている.

また{$a_n$}は単調増加で,$alpha$が$A$の上限なので.$a_N <= a_(N+1) <= a_(N+2) dots <= a_n <= dots alpha$
となっている.

したがって$|a_n -alpha| < epsilon$ となる.

よって$lim_(n-> infinity) a_n = alpha$となることがわかる.

#v(1cm)
例) $a_n = (1 + 1/n)^n$とするとき,${a_n}$は収束する.

$because$ ${a_n}$は単調増加
$because a_n = (1 + 1/n)^n = ((n+1)/n)^n = ((n^2 - 1)/n^2)^n (n/(n-1))^n = (1-1/n^2)^n (n/(n-1))^n >= (n-1)/n (n/(n-1))^n = (n/(n-1))^(n-1) = (1 + 1/(n-1))^(n-1) = a_(n-1)$
//帰納法で示せる

${a_n}$は上に有界

$because$
$
  a_n & = (1 + 1/n)^n \
      & <= (1+ 1/n)^(n+1) \
      & = ((n+1)/n)((n+1)/n)^n \
      & <= (n^2/(n^2 - 1))n ((n+1)/n)^n \
      & = (n/(n-1))^n \
      & = (1 + 1/(n-1))^n <= (1+ 1/(2-1))^2 = 4
$

よって${a_n}$は単調増加で上に有界なので{$a_n$}は収束する.


[演習]

${a_n}$を$a_1 = 1,a_n = 1/2 (a_(n-1) + 2)$
とするときこの数列が収束することを示せ.

//単調で有界なことを示す-> 定理1.3で収束を証明

定理 1.4 区間縮小法

閉区間$I_n = [a_n,b_n]$が$I_1 >= I_2 >= dots >= I_n >= dots$となっていて,かつ$I_n$の範囲$(b_n - a_n)$が$n->infinity$で$0$に収束するとき各区間に共通なただ一つの点が存在する.

(proof)

条件より$a_1 <= a_2 <= dots <= b_2 <= b_1$となっているので
- ${a_n}$は上に有界
- ${b_n}$は下に有界
で${a_n}$は単調費減少,${b_n}$は単調非増加

よって$lim_(n-> infinity)a_n = alpha$と$lim_(n -> infinity) b_n = beta$が存在する.

$a_n < b_n$より$alpha <= beta$のはず.
さらに$a_n <= alpha <= beta <= b_n$のはず

ここで$I_n$の範囲が$n-> infinity$で$b_n - a_n -> 0$なので$forall epsilon > 0$に対して $exists N, forall n>= N b_n - a_n < epsilon$

このとき$beta - alpha < epsilon$ となる

もし$beta eq.not alpha$(つまり$alpha < beta$)とすると$beta-alpha = delta$として$delta > epsilon > 0$を選ぶと$beta- alpha$に矛盾する.

よって$alpha = beta$である

$therefore$ $alpha = beta$がすべての区間に含まれる唯一の点とわかる.

定理 1.5 (コーシーの収束条件) //これじゃないものを指すこともある

数列${a_n}$が収束する.

$<=>$ $forall epsilon > 0$に対してある$N$を定めて$forall n,m >= N,|a_n - a_m| < epsilon$が成り立つ

$forall n,m >= N,|a_n - a_m| < epsilon$コーシー列という

(proof)
$=>$は自明

$arrow.l.double$: $forall epsilon > 0$に対して,ある$n$番目以降の$a_k$は上下に有界よって${a_k|k >= n}$は下限$l_n$は下限$l_n$と上限$u_n$をもつ
$n<= n prime$なら$[l_n,u_n] >= [l_n prime ,u_n prime]$

また,$u_n - l_n < 2 epsilon$となって $epsilon > 0$は任意なので$("範囲") -> 0 (n-> infinity)$ -> 区間微小法で$alpha$二収束する


[演習2]

$sum_(n=1)^(infinity) 1/2^n$は収束することを示す
//コーシー列を使って

[演習3]

ワイヤシュトラスの定理の上下逆版の証明を書く


