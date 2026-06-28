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

= 数理解析レポート第九回

202410178
今村隼人

== [演習]

距離空間$(X,d_X),(Y,d_Y)$と写像$f:X -> Y$を考える.
距離空間における連続性,開球,開集合を定義し,次の同値関係を証明せよ.

$
  f "が連続"
  <=>
  Y "の任意の開集合" U "に対して" f^(-1)(U) "が" X "の開集合"
$

#v(0.5cm)

== [解答]

=== 定義

$(X,d_X)$を距離空間とする.$x_0 in X$と$r>0$に対して,

$
  B_X(x_0,r) = {x in X | d_X(x,x_0) < r}
$

を中心$x_0$,半径$r$の開球という.

部分集合$A subset.eq X$が開集合であるとは,

$
  forall x in A, exists r > 0,
  B_X(x,r) subset.eq A
$

が成り立つことである.

写像$f:(X,d_X) -> (Y,d_Y)$が$x_0 in X$で連続であるとは,

$
  forall epsilon > 0, exists delta > 0,
  d_X(x,x_0) < delta
  => d_Y(f(x),f(x_0)) < epsilon
$

が成り立つことである.$f$がすべての$x_0 in X$で連続であるとき,$f$を連続写像という.開球を用いれば,この条件は

$
  forall epsilon > 0, exists delta > 0,
  f(B_X(x_0,delta)) subset.eq B_Y(f(x_0),epsilon)
$

と書ける.

ここで,距離空間の開球は開集合であることを確認する.$y in B_X(x_0,r)$とし,

$
  eta = r - d_X(x_0,y) > 0
$

とおく.$z in B_X(y,eta)$ならば,三角不等式より

$
  d_X(x_0,z)
  <= d_X(x_0,y) + d_X(y,z)
  < d_X(x_0,y) + eta
  = r
$

である.したがって$B_X(y,eta) subset.eq B_X(x_0,r)$となるので,$B_X(x_0,r)$は開集合である.

#pagebreak()

=== 証明

まず$f$が連続であると仮定する.$U subset.eq Y$を任意の開集合とする.$f^(-1)(U)=nothing$ならばこれは開集合であるから,$f^(-1)(U) != nothing$の場合を考える.

$x_0 in f^(-1)(U)$を任意に取る.このとき$f(x_0) in U$であり,$U$は開集合なので,ある$epsilon>0$が存在して

$
  B_Y(f(x_0),epsilon) subset.eq U
$

となる.$f$は$x_0$で連続であるから,ある$delta>0$が存在して

$
  d_X(x,x_0) < delta
  => d_Y(f(x),f(x_0)) < epsilon
$

となる.よって$x in B_X(x_0,delta)$ならば$f(x) in U$,すなわち$x in f^(-1)(U)$である.したがって

$
  B_X(x_0,delta) subset.eq f^(-1)(U)
$

を得る.$x_0$は任意であったから,$f^(-1)(U)$は$X$の開集合である.

逆に,$Y$の任意の開集合$U$に対して$f^(-1)(U)$が$X$の開集合であると仮定する.$x_0 in X$と$epsilon>0$を任意に取る.開球

$
  U = B_Y(f(x_0),epsilon)
$

は$Y$の開集合であるから,仮定より$f^(-1)(U)$は$X$の開集合である.また$f(x_0) in U$なので,$x_0 in f^(-1)(U)$である.したがって,ある$delta>0$が存在して

$
  B_X(x_0,delta) subset.eq f^(-1)(U)
$

となる.よって$d_X(x,x_0)<delta$ならば$f(x) in U$であり,

$
  d_Y(f(x),f(x_0)) < epsilon
$

が成り立つ.これは$f$が$x_0$で連続であることを意味する.$x_0$は任意であったから,$f$は$X$上で連続である.

以上より,

$
  f "が連続"
  <=>
  forall U subset.eq Y,
  U "が開集合" => f^(-1)(U) "が開集合"
$

が示された.
