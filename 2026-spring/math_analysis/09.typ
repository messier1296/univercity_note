#import "/template.typ": frame, setup
#show: setup

= 数理解析第九回

== 関数の連続性

Def　$f:RR -> RR$が$x = x_0$で連続 <=> $lim_(x-> x_0) f(x) = f(x_0)$
$forall x$で連続なとき%$f(x)$は連続関数

$
  lim_(x -> x_0) f(x) = f(x_0)\ <=> forall epsilon > 0, exists delta > 0, |x - x_0| < delta => |f(x) - f(x_0)| < epsilon
$

$f(x)$が連続 <=> $forall x_0 in RR,forall epsilon > 0,exists delta > 0, |x - x_0| < delta => |f(x) - f(x_0) < delta$

類似する定義で次のようなものがある

上の定義は$delta$は$x_0$に依存して決めていい,下はどの$x_0$に対しても共通に決める


$forall epsilon > 0,exists delta > 0 , forall x_0 in RR, |x-x_0| < delta => |f(x) = f(x)| <epsilon$

$<=>$ $f(x)$は一様連続

$f(x) = x^2$は一様連続ではない

連続関数については以下が知られている

有界閉集合上の連続関数は一様連続

有界閉集合上の連続関数は最大値最小値を持つ

$f:RR^m -> RR$の連続性も$f:RR-> RR$のときと同じ

$x = x_0$で連続 $<=>$ $forall epsilon > 0 , exists delta > 0, |x - x_0| <delta => |f(x) - f(x_0) | epsilon$

$f$が連続 $<=>$ $forall x_0 in RR^n, forall epsilon > 0,exists delta > 0 |x - x_0 | < delta => |f(x) - f(x_0) < epsilon$

関数の列$f_1(x),f_2(x),dots,f_n(x) dots$において各$x$において$lim_(n ->infinity) f_n(x) = f(x)$となるとき関数列${f_n(x)}$は$f(x)$に収束するという

極限:$forall epsilon > 0 ,exists N, forall n >= N ,|f_n(x) - f(x)| < epsilon$

ここで収束性を示す$N$が$x$によらずに取れるとき「一様に収束する」という

各$f_n(x)$が連続で$f_n -> f$が一様収束なら$f(x)$は連続関数

ここまでの$f(x)$の連続性の話は$RR^n$上の距離関数によって定まっていた

距離の定められた空間 $=$距離空間 (X,d_x)
$X:$集合,$d_x:$距離関数

(i) $forall x,y in X$で$d_x(x,y) > 0$で$d_X(x,y) = 0 <=> x= y$
(ii) $forall x,y in X, d_X(x,y) = d_X(y,x)$
(iii) $forall x,y,z in X d_x(x,y) + d_X(y,z) >= d_X(x,z)$


---
演習

多変数関数の連続:$forall x in RR forall epsilon >0, exists delta >0, |x-x_0|< delta => |f(x) - f(x_0)| < epsilon$

この定理を距離空間での設定で書き直す
- 各定義を距離空間でのもので書く
- 証明を書く

---

距離空間での写像$f:X -> Y$の連続性
$f:(X,d_X) -> (Y,d_Y)$

$forall x_0 in X, forall epsilon >0, exists delta >0 d_X(x,x_0) <delta => d_Y(f(x) - f(x_0)) < epsilon$

$B_X(x_0 delta) = {x in X| d_X(x_0,x) < delta}$
開球

関連して開集合,閉集合の定義を見る

$A subset.eq X$が開集合 $<=>$ $forall x in A, exists epsilon ,B_X(x,epsilon) subset.eq A$

$B subset.eq X$が閉集合 <=> $X-B$が開集合

---
定理

(X,d_X) (Y,d_Y) が距離空間として$f:X ->Y$が連続

$<=> (Y,d_y)$ の任意の開集合$u$に対してその逆像$f^(-1) (u)$ が$(X,d_X)$の開集合となる
---

実は$f$の連続性は距離関数を使わなくても開集合の情報があれば定義できる

-> 位相空間$(X,O)$

$O$は開集合すべて$O subset.eq 2^X$

(i) $nothing , X in O$
(ii) $u_1, dots,u_k in O => u_1 inter dots ,u_k in O$
(iii) $u_i in O$ for $forall i in Lambda => union_(i in Lambda) u_i = O$ ($Lambda$は無限集合でもよい)

定理9.2より$f:X->Y$が全単射で$f$と$f^(-1)$が両方連続なら$(X,O_X),(Y,O_Y)$の開集合は同じ構造をもつことになる
//なぜ連続である必要がある?
このような$f$を同相写像,$X$と$Y$は同相という

コンパクト性

位相空間$(X,O_X)$において集合$A subset.eq X$がコンパクト
$<=>A$の任意の無限開被覆が有限個からなら部分被覆を持つ

$X$自身がコンパクトなときコンパクト空間と言う

定理9.3

$RR^n$におけるユークリッド距離$d$による距離位相のもとでは$A$がコンパクト$<=>$有界閉集合

定理 9.4

位相空間$(X,O_X)$においてコンパクトな集合上の連続関数は最大値,最小値を持つ

(proof)

$f$が連続だと$A$がコンパクト => $f(A)$もコンパクト
$f(A) subset.eq RR$は有界閉集合 => 最大最小が存在

定理9.5

距離空間$(X,d)$の距離位相において$f: X -> Y$が連続$X$がコンパクト => $f$は一様連続
