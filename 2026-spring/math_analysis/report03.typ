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

= 数理解析レポート第三回

202410178
今村隼人

== [演習]

次のベクトルの中から,できるだけ多い本数からなる一次独立なベクトル集合を一つ見つけよ.

$
  vec(1, 0, 0, 1), quad
  vec(0, 1, 0, 1), quad
  vec(1, 1, 0, 2), quad
  vec(2, 0, 0, 2), quad
  vec(2, 1, 0, 3), quad
  vec(0, 1, 1, 2), quad
  vec(1, 1, 1, 3)
$

(1) 一次独立であることを示せ.

(2) その本数が最大であることを示せ.

#v(0.5cm)

== [解答]

与えられたベクトルを順に
$
  bold(v)_1 = vec(1, 0, 0, 1), quad
  bold(v)_2 = vec(0, 1, 0, 1), quad
  bold(v)_3 = vec(1, 1, 0, 2), quad
  bold(v)_4 = vec(2, 0, 0, 2),
$
$
  bold(v)_5 = vec(2, 1, 0, 3), quad
  bold(v)_6 = vec(0, 1, 1, 2), quad
  bold(v)_7 = vec(1, 1, 1, 3)
$
とおく.

この中から
$
  {bold(v)_1, bold(v)_2, bold(v)_6}
  =
  {
    vec(1, 0, 0, 1),
    vec(0, 1, 0, 1),
    vec(0, 1, 1, 2)
  }
$
を選ぶ.

=== (1)

$a bold(v)_1 + b bold(v)_2 + c bold(v)_6 = bold(0)$とする.このとき
$
  a vec(1, 0, 0, 1)
  + b vec(0, 1, 0, 1)
  + c vec(0, 1, 1, 2)
  =
  vec(a, b + c, c, a + b + 2c)
$
であるから,
$
  vec(a, b + c, c, a + b + 2c) = vec(0, 0, 0, 0)
$
となる.

よって各成分を比較すると
$
  a = 0, quad b + c = 0, quad c = 0, quad a + b + 2c = 0
$
である.ここから$c = 0$, $b = 0$, $a = 0$を得る.

したがって
$
  a bold(v)_1 + b bold(v)_2 + c bold(v)_6 = bold(0)
$
を満たすのは$a = b = c = 0$の場合のみである.
よって${bold(v)_1, bold(v)_2, bold(v)_6}$は一次独立である.

=== (2)

与えられた7本のベクトルはいずれも,第4成分が第1成分,第2成分,第3成分の和になっている.すなわち
$
  x_4 = x_1 + x_2 + x_3
$
を満たすベクトルである.

したがって,これらのベクトルはすべて
$
  W = {vec(x_1, x_2, x_3, x_4) in RR^4 | x_4 = x_1 + x_2 + x_3}
$
に含まれる.

この空間$W$の任意の元は
$
  vec(x_1, x_2, x_3, x_1 + x_2 + x_3)
  =
  x_1 vec(1, 0, 0, 1)
  + x_2 vec(0, 1, 0, 1)
  + x_3 vec(0, 0, 1, 1)
$
と表せる.よって$W$は高々3次元である.

したがって$W$に含まれるベクトル集合から4本以上の一次独立なベクトルを選ぶことはできない.
一方で(1)より,与えられたベクトルの中から3本の一次独立なベクトル
$
  {bold(v)_1, bold(v)_2, bold(v)_6}
$
を選ぶことができた.

以上より,選べる一次独立なベクトルの本数の最大値は3である.
