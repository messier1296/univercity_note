#import "/template.typ": frame, setup
#show: setup

= 数理解析第八回

== 常微分方程式

=== 常微分方程式の解の存在条件
ローレンツアトラクター

簡単な常微分方程式でも振る舞いが非常に複雑になる

$
  cases((dif x_1) /dif t) = sigma (x_2 -x_1) ,(dif x_2)/(dif t) = -x_1 x_3 + r x_1 - x_2,(dif x_2)/(dif t) = x_1 x_2 - b x_3)
$

定理7.1

$
  cases((dif x) / (dif t) = f(t,x), x(t_0) = t_0)
$
$Omega = [a,b] times [c,d]$ 上で$f$は連続

$f(t,x)$は$t$ について一様に$x$に関してリプシッツ連続なら$Omega$中の任意の内点$(t_0,x_0)$に対して$exists delta > 0 ,[t_0 - delta,t_0 + delta] -> t$で を満たす関数$x = x(t)$が存在する

リプシッツ連続

$exists k > 0, |f(t,x_1) - f(t,x_2)| <= k|x_1 - x_2| ,forall x_1,x_2 in [c,d]$

連立方程式についても同様の議論で解の存在を示せる

(proof)

解を以下のように構成する
$
  x_0(t) = x_0 ("定数関数")\
  x_n(t) = x_0 + integral_(t_0)^t f(t,x_(n-1) (t)) dif t \
  lim_(n->infinity) x_n(t) = x(t)
$

$x_n(t) = x_0 + integral_(t_0)^t f(t,x_(n-1) (t)) dif t$を
微分して $dif / (dif t) x(t) = f(t,x(t))$となることを目指す

この収束性を確認する

=== $(t,x_n(t)) in Omega$となるように$t$の範囲を定める


$Omega$上で$f(t,x)$は連続なので最大値,最小値を持つ

特に$exists M >0$で$|f(t,x)| <= M " "((t,x) < Omega)$となる

ここで$(t_0,x_0)$を通る傾き$M,-M$の直線で定まる領域$A$が$Omega$に入る$delta$を定める.また$delta <= 1/(2k)$となるようにしておく

このようにすると実際に$(t,x_n(t)) in Omega$ となる

$n = 0$のときはOK

$n-1$のときにOKとすると

$x_n(t) = x_0 + integral_(t_0)^t f(t,x_n-1 (t)) dif t$より$|x_n(t) - x_0| = |integral_(t_0)^t f(t,x_(n-1)(t)) dif t| <= M |t- t_0|$

よって$(t,x_n(t))$は$A$中に含まれる

=== $lim_(n-> infinity) x_n(t)$は収束する

$x_n (t) = x_0 (t) + (x_1 (t) - x_0(t)) + dots (x_n(t) - x_0(t))$

$ lim_(n->infinity) =x_n(t) = x_0(t) + sum_(n_1)^infinity (x_n(t) - x_(n-1) (t)) $


連立線形の方程式

$
  (dif x_1) / (dif t) = a_(1,1) (t) x_1 + dots a_(1 n) x_n + f_1(t)\
  dots.v\
  (dif x_n) / (dif t) = a_(n,1) (t) x_1 + dots a_(n n) x_n + f_n(t)\
$

$<=> (dif bold(x_1)) / (dif t) + bold(A)(t) x + bold(f) (t)$ と書ける

右辺の$bold(f)(t)$ がある -> 非斉次方程式

ない -> 斉次方程式


斉次方程式の場合

$ (dif bold(x))/ (dif t) = A(t) bold(x) $
$ "初期値" bold(x) (s) = bold(x) $

線形なのでリプシッツ連続
よって解が一意に存在する

この解を$bold(x) (t,s,bold(x_0))$とする

ここで$ (dif) /(dif t) (dif bold(x) (t,s,bold(x_0)) + beta bold(x) (t,s,y_0)) &= alpha dif/(dif t) bold(x) (t,s,bold(x_0)) + beta dif / (dif t) bold(x) (t,s,y_0)\
&= alpha A(t) bold(x) (t,s,bold(x_0)) + beta A(t) bold(x) (t,s,y_0)\
&= A(t) (alpha bold(x) (t,s,bold(x)) + beta bold(x) (t,s,y_0)) $

よって$alpha bold(x) (t,s,bold(x_0)) + beta bold(x) (t,s,y_0)$

は
$ (dif bold(x))/ (dif t) = A(t) bold(x) $
の解
またその初期値は$t = s$ で$alpha bold(x_0) + beta bold(y_0)$となる

つまり$t = s$における初期値$bold(x)$ に対して対応する解$bold(x) (t,s,bold(x_0))$ を割り当てる写像は線形写像になっている

先程の解は$bold(x) (t,s,bold(x_0)) = R(t,s)bold(x_0)$

この$R(t,s)$を解核行列という

先程の解全体は$n$次元線形空間になる

特に$A(t) = A$のとき

このとき$R(t,s) = e^(A(t-s))$ となる

$
  e^A & = I + A + 1/2 A^2 + 1/3! A^3 + dots \
      & = sum_(k=0)^infinity 1/ k! A^k
$

$e^(A t)$ の各要素は収束半径$infinity$になり絶対収束する

$
  dif / (dif t) e^(A t) & = dif / (dif t) (I + t A + t^2/2 A^2 + dots ) \
                        & "項別に微分" \
                        & = 0 + A + t A^2 + t^2/2 A^3 dots \
                        & = A(I + t A + t^2 / 2 A^2 + dots ) \
                        & = A e^(A t)
$

となるので

$
  bold(x) = e^(A(t-s)) bold(x_0) = e^(A t) e^(-A s) bold(x_0)
$
が解とわかる

$e^(t A)$の計算

$A$が対角化可能となら

$A^k = dots$ 省略

$dif /(dif t) bold(x) = A bold(x)$の解は

$
  bold(x) & = e^(A t) bold(x_0) \
          & = T mat(e^(lambda_1 T), , 0; , dots.down, ; 0, , e^(lambda_n t)) T^(-1) bold(x_0) \
          & = c_1 e^(lambda_1 t) bold(P_1) + dots + c_n e^(lambda_n t) bold(P_n)
$

となる

$e^(lambda_i t)$ は

$lambda_i > 0$ のとき$t -> infinity$で$-> infinity$


$lambda_i < 0$ のときは$t-> infinity$で $-> 0$

つまり解の大域挙動は$A$の初期値によって決まる

$n = 2$ のとき$A$を実行列として

$lambda_1,lambda_2$が複素数のとき

$lambda_1 = a + b_i$

$lambda_1 = a - b_i$
とする

---

演習

$y ''' - 2 y'' - y ' + 2y = 0$の解の挙動を考える

(1) 一階連立にする

(2) 係数行列の固有値を求める

(3) 解の挙動がどうなるか調べる

---
