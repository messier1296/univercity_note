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

= 数理解析レポート第七回

202410178
今村隼人

== [演習]

改良オイラー法は実は2次のルンゲ・クッタ法になっている.
すなわち
$
  n = 2,
  quad
  b_1 = 0,
  quad
  b_2 = 1,
  quad
  alpha_1 = 1 / 2,
  quad
  beta_(1,1) = 1 / 2
$
とした場合である.

二次のルンゲ・クッタ法はパラメータを
$
  b_1 + b_2 = 1,
  quad
  alpha_1 b_2 = 1 / 2,
  quad
  beta_(1,1) b_2 = 1 / 2
$
とすれば二次項まで一致することを確認しなさい.

#v(0.5cm)

== [解答]

常微分方程式
$
  y' = f(x, y)
$
を考える.
$x_i$における近似値を$Y_i$とし,刻み幅を$h$とする.
2段のルンゲ・クッタ法は
$
  k_1 & = h f(x_i, Y_i), \
  k_2 & = h f(x_i + alpha_1 h, Y_i + beta_(1,1) k_1), \
  Y_(i+1) & = Y_i + b_1 k_1 + b_2 k_2
$
で与えられる.

ここで$Y_i = y(x_i)$であるとして,1ステップ後の値をテイラー展開する.
まず
$
  k_1 = h f(x_i, y_i)
$
である.また,$f$を$(x_i, y_i)$のまわりで展開すると,
$
  f(x_i + alpha_1 h, y_i + beta_(1,1) k_1)
  & = f(x_i, y_i)
      + alpha_1 h f_x(x_i, y_i)
      + beta_(1,1) k_1 f_y(x_i, y_i)
      + O(h^2) \
  & = f(x_i, y_i)
      + alpha_1 h f_x(x_i, y_i)
      + beta_(1,1) h f(x_i, y_i) f_y(x_i, y_i)
      + O(h^2)
$
である.したがって
$
  k_2
  = h f(x_i, y_i)
    + alpha_1 h^2 f_x(x_i, y_i)
    + beta_(1,1) h^2 f(x_i, y_i) f_y(x_i, y_i)
    + O(h^3)
$
となる.

これを更新式に代入すると,
$
  Y_(i+1)
  & = y_i + b_1 h f(x_i, y_i) \
  & quad + b_2 (h f(x_i, y_i)
    + alpha_1 h^2 f_x(x_i, y_i)
    + beta_(1,1) h^2 f(x_i, y_i) f_y(x_i, y_i)
    + O(h^3)) \
  & = y_i
      + h (b_1 + b_2) f(x_i, y_i) \
  & quad + h^2 alpha_1 b_2 f_x(x_i, y_i)
      + h^2 beta_(1,1) b_2 f(x_i, y_i) f_y(x_i, y_i)
      + O(h^3).
$

一方で,厳密解のテイラー展開は
$
  y(x_i + h)
  = y_i + h y'(x_i) + h^2 / 2 y''(x_i) + O(h^3)
$
である.
$y' = f(x, y)$より,
$
  y'' = dif / (dif x) f(x, y)
      = f_x(x, y) + f_y(x, y) y'
      = f_x(x, y) + f_y(x, y) f(x, y)
$
であるから,
$
  y(x_i + h)
  = y_i
    + h f(x_i, y_i)
    + h^2 / 2 (f_x(x_i, y_i) + f_y(x_i, y_i) f(x_i, y_i))
    + O(h^3)
$
となる.

したがって,2段ルンゲ・クッタ法の展開が厳密解の展開と二次項まで一致するためには,
$
  b_1 + b_2 = 1,
  quad
  alpha_1 b_2 = 1 / 2,
  quad
  beta_(1,1) b_2 = 1 / 2
$
が成り立てばよい.
この条件のもとで
$
  Y_(i+1)
  = y_i
    + h f(x_i, y_i)
    + h^2 / 2 (f_x(x_i, y_i) + f_y(x_i, y_i) f(x_i, y_i))
    + O(h^3)
$
となり,厳密解のテイラー展開と二次項まで一致する.

特に改良オイラー法では
$
  b_1 = 0,
  quad
  b_2 = 1,
  quad
  alpha_1 = 1 / 2,
  quad
  beta_(1,1) = 1 / 2
$
であるから,
$
  b_1 + b_2 = 1,
  quad
  alpha_1 b_2 = 1 / 2,
  quad
  beta_(1,1) b_2 = 1 / 2
$
を満たす.
よって改良オイラー法は2次のルンゲ・クッタ法の一つであり,局所誤差は$O(h^3)$である.
