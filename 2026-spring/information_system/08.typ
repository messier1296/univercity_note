#import "../../template.typ": frame, setup
#show: (setup)

= 情報システム第七回

== 公開鍵暗号方式

$ ZZ_11 = {0,1,2, dots ,10} ("自然数を11で割った余り") $

$i in ZZ_11$は$i^0$から$i^9$までのループで乱数を表現できる

このとき$ZZ_11 = {0}$以外のすべての要素が出てくると理想的な乱数に近づく

$ZZ_p$の中で${alpha^0,alpha^1,dots, alpha^(p-2)} = ZZ_p - {0}$
となるような要素$alpha$が$ZZ_p$の*原始根*という (primitive element)

離散対数問題

$p$を大きな素数とし$alpha in ZZ_p$を$ZZ_p$の原始根とする
$X in ZZ_p - {0}$が与えられたとき$X = alpha^i (mod p)$
となる$i = log_alpha X$がどのくらい速く計算できるか


$ZZ_11$において$9,7$から秘密鍵を生成する

Step1

原始根:$alpha = 2$

$9 eq.triple 2^6$

$7 eq.triple 2^7$

Step2

$7^6 eq.triple 4$ $2^7^6$

$9^7 eq.triple 4$ $2^6^7$

攻撃者は$ZZ_11$ $alpha = 2$ $9,7$を知っていても Step1の秘密鍵$(6,7)$を計算できない(離散対数問題)

$2^(6+ 7)$は簡単に計算できる

Man in the Middle 攻撃には無力

公開鍵が自分のものであると証明できなければならない

秘密鍵で署名すれば証明できる -> 公開鍵で複合できるか確認することで送受信先を証明できる

(秘密)署名アルゴリズム Sig: 署名者がSigを利用して文書に利用して署名文yを得る

(公開)確認アルゴリズム Ver: (x,y)が与えられたとき確認者がVerを使ってXの署名文であるべきyを確認する

数学的な定義

$p$:文書の集合 $A$:万能な署名の集合 $K$:鍵の集合

$forall k in K , exists S i g_k in S$と対応する確認アルゴリズム$V e r in v$

$S i g_k: p -> A$
$V e r_k:p times A -> {0,1}$

such that

$forall x in p, forall y in A$

$V e r_k(x,y) = cases(1 "if" y = S i g_k (X) 0 "else")$

Hash関数

$h: ZZ_(>0) -> ZZ_n$

任意の非負有限整数から長さ$approx log n$bitの固定された出力値を生成する

+ 出力値の長さ$k <$ 入力値の長さ(圧縮)

+ $X$与えられたとき$y = h(x)$ が高速に計算可能

+ $y = h(x)$から$X$を計算することは難しい 一方向性関数

+ $h(x) = h(x') x != x'$の衝突を探すことは難しい


RSA署名方式

$(p,q)$:大きな素数, $n = p q$

$p$(平文の集合) $= ZZ_(>0)$

$A$(署名bの集合) $= ZZ_n$

$K$(鍵の集合) $= {(n,p,q,d,e)|d e = 1(mod Phi(n))}$

$n,e$は公開,$p,q,d$は秘密

ハッシュ関数$h: ZZ_(>0) -> ZZ_n$公開

$K = (n,p,q,d,e) in K$に対して

$S i g_k(x) = (h(x))^d (mod n)$

$V e r_k(X,y) = 1 <=> (h(X) = y^e (mod n))$

$A:(P_A,S_A) B:(P_B,S_B)$

暗号化の場合:

A -> B  送信内容 $= y = X^(P_B) (mod n) "複合": y^(S_B) (mod n) =X$

署名

A -> B  送信内容 $= (y,x)$ $y = X^(S_A) (mod n) "複合": y^(P_A) (mod n) = h(x)$が正しい確認する

安全性は署名方式のほうが重要

署名と暗号化の結び方

Aが署名付き暗号文書をBに送る



