#import "/template.typ": frame, setup
#show: setup

= 数理解析第7回

== 常微分方程式

高階方程式

-> 一階連立式にできる

$
  (dif^n x) / (dif t^n) = f(t,x,(dif x) / (dif t) ,(dif^2 x)/(dif t^2), dots (dif^(n-1) x) /(dif t^(n-1)))
$
$x = x_1 , (dif x) / (dif t) = x_2 , dots (dif^(n-1)x) / (dif t^(n-1)) = x_n$
と置くと
$(dif x_1) / (dif t) = x_2 , (dif x_2) / (dif t) = x_3 dots (dif x_(n-1)) / (dif t) = x_n,(dif x_n) / (dif t) = f(t,x_1,x_2 dots x_n)$
と一階連立の常微分方程式になる

微分方程式

- 初期値問題 ex) 座標と速度からその後の運動を予測する
- 境界値問題 ex) ある地点とある地点の情報がわかっていてその間の動きを予測する

簡単のために一変数一階で考える (n変数の一階連立に適用できる)

オイラー法で数値的に解ける

$x$を$h$刻みで進めながら$y$の変化を見る
$y$の動きを線分で近似できる
傾き $= (dif y) / (dif x) (x = x_0) = f(x_0,y_0)$になる

すると$y(x_0 + h) approx y(x_0) + h f(x_0, y_0)$

$y(x_0 + h) = Y_1,Y_0 = y_0$

$i$番目の近似解$(x_i,Y_i)$として

$Y_(i+1) = Y_i + h f(x_i, Y_i)$
とする これがオイラー法

オイラー法は誤差が大きいので実用的ではない

改良オイラー法を使う

$x_i$のときの傾きの代わりに$x_i + h/2$の傾きを使う
$x_i + h/2$の高さはオイラー法で求める

改良オイラー法:$Y_(i+1) = Y_i + h f(x_i + h/2,Y_i + 1/2 h f(x_i,Y_i))$

オイラー法:$Y_(i+1) = Y_i + h f(x_i,Y_i)$は

$y(x_(i+1)) = y(x_i) + y'(x_i) h + 1/2 y''(x_i) h^2 + dots$
のテイラー展開を一次で打ち切っている
$O(h^2)$の誤差が発生している

改良オイラー法は$h^2$まで見ている
誤差は$O(h^3)$になる

テイラー展開を見る

$
  y(x_i + h) & = y(x_i) + h (dif y) / (dif x) + h^2 /2 (dif^2 y)/ (dif x^2) + O(h^3) \
    & = y(x_i) + h f(x_i,y_i) + h^2/2 dif/(dif x) f(x_i,y_i) + O(h^3) \
    & = y(x_i) + h f(x_i,y_i) + h^2/2 ((partial f) / (partial x) + (partial f)/(partial y) (dif y) / (dif x)) + O(h^3) \
    & = y(x_i) + h f(x_i,y_i) + h^2/2 ((partial f) / (partial x) + (partial f)/(partial y) f(x_i,y_i)) + O(h^3) \
$

改良オイラー法の式の$f(...)$の部分をテイラー展開すると

$
  Y_(i+1) & = Y_i + h f(x_i + h/2,Y_i + 1/2 h f(x_i,Y_i)) \
          & = y(x_i) + h[f(x_i,y_i) + h/2 (partial f)/(partial x) + h/2 f(x_i,y_i) (partial f)/(partial y) + O(h^2)] \
          & = y(x_i) + h f(x_i,y_i) + h^2 / 2 ((partial f)/(partial x) + (partial f)/(partial y) f(x_i,y_i)) + O(h^3)
$

となりテイラー展開の二次項まで一致する
誤差は$O(h^3)$

更に頑張る
ルンゲクッタ法

$
  k_1 & = h f(x_i, Y_i) \
  k_2 & = h f(x_i + alpha_1 h,Y_i+beta_(1,1) k_1) \
  k_3 & = h f(x_i + alpha_2 h, Y_i + beta_(2,1) k_1 + beta_(2,2) k_2) \
  k_4 & = h f(x_i + alpha_3 h, Y_i + beta_(3,1) k_1 + beta_(3,2) k_2 + beta_(3,3) k_3) \
$

として$Y_(i+1) = Y_i + b_1 k_1 + b_2 k_2 + dots b_n k_n$とする

テイラー展開の$n$次項まで一致するようにパラメータを定める

よく使われるのが4次のルンゲ・クッタ法



演習

改良オイラー法は実は2次のルンゲ・クッタ法になっている
$(n=2,b_1 = 0,b_2 = 1,alpha_1 = 1/2,beta_(1, 1) = 1/2)$

二次のルンゲ・クッタ法はパラメータを
$b_1 + b_2 = 1, alpha_1 b_2 = 1/2 beta_(1,1) b_2 = 1/2$
とすれば二次項まで一致することを確認しなさい

(解答)

2段のルンゲ・クッタ法を
$
  k_1 = h f(x_i,Y_i),\
  k_2 = h f(x_i + alpha_1 h, Y_i + beta_(1,1) k_1),\
  Y_(i+1) = Y_i + b_1 k_1 + b_2 k_2
$
とする.
$k_2$の$f$を一次までテイラー展開すると
$
  k_2
  = h f(x_i,Y_i)
    + h^2 alpha_1 (partial f)/(partial x)
    + h^2 beta_(1,1) f(x_i,Y_i) (partial f)/(partial y)
    + O(h^3)
$
である.
したがって
$
  Y_(i+1)
  = Y_i + h(b_1+b_2) f
    + h^2 b_2 alpha_1 (partial f)/(partial x)
    + h^2 b_2 beta_(1,1) f (partial f)/(partial y)
    + O(h^3)
$
となる.
真の解のテイラー展開の二次項と比較すると
$
  b_1 + b_2 = 1,
  quad
  alpha_1 b_2 = 1/2,
  quad
  beta_(1,1) b_2 = 1/2
$
が必要十分である.




== 常微分方程式の解の存在性

定理7.1

$
  cases((dif x) / (dif t) = f(t,x), x(t_0) = x_0)
$
$Omega = [a,b] times [c,d]$ 上でfは連続

$f(t,x)$は$t$ について一様に$x$に関してリプシッツ連続

なら$Omega$中の任意の内点$(t_0,x_0)$に対して$exists delta > 0$が存在し,
$[t_0 - delta,t_0 + delta]$上で初期値問題を満たす関数$x = x(t)$が存在する

リプシッツ連続

$exists k > 0, |f(t,x_1) - f(t,x_2)| <= k|x_1 - x_2| ,forall x_1,x_2 in [c,d]$

定理7.2

7.1と同条件で存在する解は一致

定理7.2の証明

解が2つあるとする $phi(t)$ と$psi(t)$とする

$ dif / (dif t) phi(t) = f(t,phi(t)) $

$ dif / (dif t) psi(t) = f(t,psi(t)) $

を満たす

これらを積分すると

$phi(t) = x_0 + integral^t_t_0 f(tau,phi(tau)) d tau$

$psi(t) = x_0 + integral^t_t_0 f(tau,psi(tau)) d tau$


$|phi(t) - psi(t)| = | integral_t_0^t (f(tau,phi(tau)) - f(tau,psi(tau))) dif tau | <= integral_t_0^t K|phi(tau) - psi(tau)| dif tau <= K sup_(tau in I) | phi(tau) - psi(tau) | |t-t_0|$

ここで$I$を十分小さく取って$K |t-t_0| <= 1/2$となるようにする.
両辺の$sup$をとると

$
  sup_(t in I) | phi(t) - psi(t)|
  <= 1/2 sup_(t in I) | phi(t) - psi(t)|
$
となる.
したがって$sup_(t in I) | phi(t) - psi(t)| = 0$である.

よって$I$上で一致する

-> $t_0$を少しずつ$I$上で動かして積分すると$I$上で一致する
