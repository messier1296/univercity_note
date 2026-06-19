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

= 数理解析レポート第一回

202410178
今村隼人

== [演習1]

${a_n}$を$a_1 = 1,a_n = 1/2 (a_(n-1) + 2)$
とするときこの数列が収束することを示せ.

//単調で有界なことを示す-> 定理1.3で収束を証明

#v(0.5cm)
== [解答]

$a_n = 1/2 (a_(n-1) + 2)$の両辺から2を引いて

$
  a_n - 2 & = 1/2 (a_(n-1) - 2) \
          & = 1/4(a_(n-2) - 2) \
          & = 1/8(a_(n-3) - 2) \
   dots.v \
          & = (1/2)^(n-1)(a_1 - 2)
$

これに$a_1 = 1$を代入して$a_n = 2 - (1/2)^(n-1)$となる.
よって$a_n < 2$であり,
+ $a_n$は上に有界である.

#v(0.5cm)

$a_(n-1) = 2a_n - 2$で

$a_n - a_(n-1) = a_n - 2a_n + 2 = 2 - a_n$

である.

$a_n - a_(n-1)$は$a_n < 2$のとき正であり,$a_n < 2$なので$a_n$は単調に増加する.

以上より$a_n$は単調に増加し,上に有界なので定理1.3より収束する.


== [演習2]

$sum_(n=1)^(infinity) 1/2^n - (*)$は収束することを示せ
//コーシー列を使って

#v(0.5cm)

== [解答]

$s_n = sum_(i=1)^(n) (1/2)^i$とし,$s_n$がコーシー列であることを証明する.

$forall epsilon > 0$を取る.
このとき$(1/2)^N < epsilon$となる$N$を取る.
このような$N$は$lim_(N -> infinity)(1/2)^N = 0$より確実に存在する.

$m >= n >= N$とすると
$
  s_m - s_n & = sum_(i=n+1)^(m) (1/2)^i = (1/2)^(n+1) ( 1- (1/2)^(m-n))/2 \
            & = (1/2)^(n) - (1/2)^m
$

$n >= N$より$(1/2)^n < epsilon,s_m-s_n < epsilon$

よって任意の$epsilon>0$に対して$|s_m - s_n|< epsilon$となる$N$が存在することが示され,$s_n$はコーシー列である.

よってコーシーの収束条件により$(*)$は収束する.



