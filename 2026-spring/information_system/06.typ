#import "../../template.typ": frame, setup
#show: (setup)

= 情報システム第六回

== 暗号

=== RSA暗号

Rivest , Shamir, Adleman の頭文字

大きな素数$p,q$
//p,qはどのように作る?

$n = p q$

(平文の集合) = (暗号文の集合) = $Z_n$

$Z_n = { 0,1, dots n-1}$

(鍵の集合) = ${(n,p,q,d,e): d e = 1,(mod(Phi(n))), 1 < d,e < Phi(n)}$

鍵 $K = (n,p,q,d,e)$ に対して

暗号化 $E_k (x) = x^e (mod n)$

複合 $D_k (y) = y^d (mod n)$
//複合は本当に逆関数になってる?

公開鍵: $n,e$

秘密鍵: $p,q,d$


$Phi(n)$:Eulerの$Phi$関数 $1~n$の間で$n$と互いに素の数


ex)

$x = 20,p = 11, q = 13,n = 143$

$=> "暗号と平文の集合" = Z_143$

$Phi(143) = 143 - 13 - 11 - 1 = 11(13 - 1) - (13 - 1) = (11-1) (13-1)$

$d = 7$とする $e = 103$

暗号化 $20^103 (mod 143) = 58$

復号化 $58^7 (mod 143) = 20$

$20^103 (mod 143)= 20^64 times 20^32 times 20^4 times 20^2 times 20 (mod 143)$


$Z_n:$四則演算できる集合にしたい

$+$:$a,b in Z_n => a + n in Z_n$

$-: a,b in Z_n => a - b in Z_n$

$times: a,b in Z_n => a times B in Z_n$

$div: a,b in Z_n => a div b in Z_n$ 本当か怪しい

$n = 2$のとき ok

$n = 3$のとき このように解決できる

$1 div 2 = x, 2 x = 1$

$x = 2 x in Z_3$ ($2 x = 1$でmod を考える)

$n = 4$のとき

$2 x = 1$となる $x$が存在しない

...このように考えると
$=>$ 素数はOK
なぜか?

宿題

スライドを参照
