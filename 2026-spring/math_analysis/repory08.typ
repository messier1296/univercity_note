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

= 数理解析レポート第八回

202410178
今村隼人

== [演習]

$
  y''' - 2 y'' - y' + 2y = 0
$
の解の挙動を考える.

#enum[
  一階連立にする.
][
  係数行列の固有値を求める.
][
  解の挙動がどうなるか調べる.
]

#v(0.5cm)

== [解答]

#enum[
  $
    x_1 = y,
    quad
    x_2 = y',
    quad
    x_3 = y''
  $
  とおく.このとき
  $
    x_1' = x_2,
    quad
    x_2' = x_3
  $
  である.また,もとの方程式より
  $
    y''' = 2 y'' + y' - 2y
  $
  であるから,
  $
    x_3' = -2 x_1 + x_2 + 2 x_3
  $
  となる.したがって一階連立の形では
  $
    dif / (dif t) mat(x_1; x_2; x_3)
    =
    mat(
      0, 1, 0;
      0, 0, 1;
      -2, 1, 2
    )
    mat(x_1; x_2; x_3)
  $
  である.
][
  係数行列を
  $
    A =
    mat(
      0, 1, 0;
      0, 0, 1;
      -2, 1, 2
    )
  $
  とする.固有値は
  $
    det(lambda I - A)
    =
    det mat(
      lambda, -1, 0;
      0, lambda, -1;
      2, -1, lambda - 2
    )
  $
  から求める.これを計算すると
  $
    det(lambda I - A)
    = lambda^3 - 2 lambda^2 - lambda + 2
    = (lambda - 2)(lambda - 1)(lambda + 1)
  $
  である.よって固有値は
  $
    lambda = 2, 1, -1
  $
  である.
][
  特性方程式の解が$2,1,-1$であるから,一般解は
  $
    y(t) = C_1 e^(2t) + C_2 e^t + C_3 e^(-t)
  $
  と書ける.

  したがって$t -> infinity$では,一般には$e^(2t)$の項が最も速く増大する.
  ただし$C_1 = 0$の場合は$e^t$の項が支配的になり,$C_1 = C_2 = 0$の場合だけ$y(t) -> 0$となる.

  一方で$t -> -infinity$では,$e^(-t)$の項が増大する.
  ただし$C_3 = 0$の場合は$e^(2t), e^t$はいずれも$0$に近づく.

  よって,正の固有値$1,2$に対応する成分を持つ解は$t -> infinity$で発散し,負の固有値$-1$に対応する成分だけからなる解は$t -> infinity$で$0$に収束する.
]
