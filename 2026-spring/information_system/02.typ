
#import "../../template.typ": frame, setup
#show: (setup)

= 情報システム第二回

== 複数サーバーモデル

$lambda$:単位時間当たりに訪れる人数

$mu$:単位時間あたりにサービスされる人数

$E = lambda/ mu$

== ErlangBモデル

複数サーバーでサービスに入れないとき行列を形成せず諦める場合

客が来たときのサービスに入れない確率を考える

$c$は系内客数

$
  B(E,c) = (E times B(E,c-1)) / (c + E times B(E,c-1))
  , B(E,0) = 1,
  // TODO:漸化式を解く
$

== 確率母関数(Generating function)

確率変数$X$は非負整数値を取るとする

$X$の母関数は

$
  G(z) = E[z^X] = sum_(k=0)^infinity z^k p(k)
$

$|z| <= 1$のときに絶対収束する

$X$の確率変数$p(k)$は確率母関数から一意に定まる

$
  P(X = r) = 1/ r! dif^r/(dif z^r) G_X(z) |_(z=1)
$


$
  G_X(z) & = sum_(k=0)^infinity P(X = K) z^k \
         & = P(X= 0)z^0 + P (X = 1) z^1 + P(X = 2) z^2 + dots \
$

$z=0$を代入すると$G_X(0) = (X=0)$より$r=0$のとき示された

両辺を微分して
$
  (d G_X(z)) / (d z) = 0 + P(X=1) + 2 P (X=2) z + dots
$

$z=0$を代入すると$(d G_X(z))
/ (d z) |_(z=0) = P(X = 1)$

もう一度微分して
$
  (d^2 G_X(z)) / (d z^2) = 2 P(X = 2) + 3! P(X=3) + 3! P(X=3) dots
$
のようになる
// TODO:帰納法に書き換え

== 階乗モーメント

$
  (d^r) / (d z^r) G_X(z) = sum_(k=r)^infinity k (k-1) dots (k-r+1) z^(k - r) p(k)
$

// 階乗モーメントはE[X(X-1)(X-2) dots]


