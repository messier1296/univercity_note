#set page(
  paper: "a4",
  margin: (x: 3.5mm, y: 3.5mm),
  numbering: "1 / 2",
  number-align: bottom + right,
)
#set text(
  font: ("Noto Serif CJK JP", "New Computer Modern Math"),
  size: 11.2pt,
  fill: rgb("#111827"),
)
#show math.equation: set text(font: ("New Computer Modern Math", "Noto Serif CJK JP"))
#set par(justify: true, leading: 0.55em, spacing: 0.26em)
#set math.equation(block: false)
#set table(stroke: 0.35pt + rgb("#667085"), inset: 1.1pt)

#let blue = rgb("#174f78")
#let green = rgb("#28643d")
#let red = rgb("#8a2f2b")
#let gray = rgb("#475467")

#let title(label, side) = block(width: 100%, below: 1.3mm)[
  #grid(
    columns: (1fr, auto),
    align: (left + horizon, right + horizon),
    text(size: 10.5pt, weight: "bold", fill: blue)[#label],
    text(size: 7.5pt, fill: gray)[#side｜第2〜5回],
  )
  #line(length: 100%, stroke: 0.8pt + blue)
]

#let sec(name, body, color: blue) = block(
  width: 100%,
  breakable: false,
  below: 1.05mm,
  stroke: 0.4pt + color,
  inset: (x: 1.6mm, y: 1.1mm),
  radius: 1.2pt,
  [
    #block(
      width: 100%,
      fill: color,
      inset: (x: 1.1mm, y: 0.45mm),
      outset: (x: 1.1mm, top: 0.65mm),
    )[#text(fill: white, weight: "bold", size: 11.1pt)[#name]]
    #v(0.55mm)
    #body
  ],
)

#let key(body) = block(
  width: 100%,
  fill: rgb("#fff4cc"),
  stroke: 0.35pt + rgb("#b58105"),
  inset: 1.1mm,
  below: 0.6mm,
  [#body],
)

#let eq(body) = block(
  width: 100%,
  inset: (x: 0.6mm, y: 0.45mm),
  above: 0.25mm,
  below: 0.25mm,
  fill: rgb("#f2f4f7"),
  align(center)[#body],
)

#title([計量時系列分析 チートシート], [表面：基礎・定常性])

#columns(2, gutter: 1mm)[
  #sec([2｜データの種類])[
    #table(
      columns: (0.9fr, 2.2fr),
      align: left + horizon,
      [種類], [識別ポイント・例],
      [時系列], [同一対象を時点順に観測。月次売上、日次株価。順序に意味。],
      [横断面], [同一時点で複数対象。ある年の大学別学生数。],
      [パネル], [同じ複数対象を反復観測。店舗 $i times$ 月 $t$。個体差＋時間変化。],
      [コーホート], [共通属性の集団を追跡。入学年度別の平均取得単位。],
    )
    時系列では自己相関、トレンド、季節性により観測が独立でない点が重要。
  ]

  #sec([2｜時系列の成分と変換], color: green)[
    典型的分解：トレンド $T_t$、季節 $S_t$、循環 $C_t$、不規則 $I_t$。
    #eq[$y_t=T_t+S_t+C_t+I_t quad "(加法)"$]
    #eq[$y_t=T_t times S_t times C_t times I_t quad "(乗法)"$]
    差分は水準トレンドを除く：$Delta y_t=y_t-y_(t-1)$。季節差分（周期 $s$）：$Delta_s y_t=y_t-y_(t-s)$。対数は成長率・分散安定化に有用（$y_t>0$）。
  ]

  #sec([2｜対数差分と変化率])[
    通常の変化率 $g_t=(y_t-y_(t-1))/y_(t-1)$ なら $y_t=y_(t-1)(1+g_t)$：
    #eq[$Delta log y_t=log(y_t/y_(t-1))=log(1+g_t)$]
    テイラー展開：
    #eq[$log(1+g)=g-frac(g^2,2)+frac(g^3,3)-frac(g^4,4)+dots$]
    よって $|g_t|$ が小さければ
    #key[$Delta log y_t approx g_t$]
    例：$g=.02$ の2次項は $.0002$。$g=.5$ では $.125$ で無視不可。厳密な百分率は $100(e^(Delta log y_t)-1)%$。
  ]

  #sec([2｜動学方程式と繰返し代入])[
    #eq[$y_t=phi y_(t-1)+w_t$]
    $h$ 期先まで代入すると
    #eq[$y_(t+h)=phi^h y_t+sum_(j=1)^h phi^(h-j)w_(t+j)$]
    時点 $t$ の1単位ショックが $j$ 期後へ及ぼす*動学乗数*：
    #eq[$frac(partial y_(t+j),partial w_t)=phi^j$]
    一時的ショックの $j$ 期までの累積効果：
    #eq[$sum_(i=0)^j phi^i=frac(1-phi^(j+1),1-phi)$]
    $|phi|<1$ なら長期累積効果 $1/(1-phi)$。$phi<0$ は符号を交互に変えて減衰、$|phi|>1$ は発散、$phi=1$ は影響が永久に残る。
  ]

  #sec([3｜弱定常性（共分散定常性）], color: red)[
    2次モーメントが有限な過程 ${X_t}$ が弱定常であるとは、すべての $t,h$ について
    #eq[$E(X_t)=mu quad "(時点によらず一定)"$]
    #eq[$"Cov"(X_t,X_(t-h))=gamma(h) quad "(時点でなくラグの関数)"$]
    が成立すること。したがって $"Var"(X_t)=gamma(0)$ は一定。自己相関：
    #eq[$rho(h)=frac(gamma(h),gamma(0)),quad rho(0)=1,quad rho(-h)=rho(h)$]
    #key[弱定常は分布全体ではなく、平均・分散・自己共分散だけの条件。]
  ]

  #sec([3｜強定常性（厳密定常性）], color: red)[
    任意の $n$、任意の時点 $t_1,dots,t_n$、任意のシフト $k$ に対して
    #eq[$(X_(t_1),dots,X_(t_n)) quad "と" quad (X_(t_1+k),dots,X_(t_n+k)) quad "は同分布"$]
    となること。すべての有限次元結合分布が時間移動で不変。

    *関係*：強定常＋有限な2次モーメント $=>$ 弱定常。一般に弱定常から強定常は導けない。ただし*ガウス過程*では平均・共分散が結合分布を決めるため、弱定常 $=>$ 強定常。

    *反例*：奇数時点は $N(0,1)$、偶数時点は $P(X=plus.minus 1)=1/2$、各時点独立。平均0・分散1・非ゼロラグ共分散0なので弱定常だが、周辺分布が時点で変わるため強定常でない。
  ]

  #colbreak()

  #sec([3｜エルゴード性], color: red)[
    定常過程がエルゴード的とは、*1本の十分長い標本経路の時間平均で母集団（アンサンブル）の性質を推定できる*こと。平均エルゴード性：
    #eq[$overline(X)_T=frac(1,T)sum_(t=1)^T X_t -> E(X_t)=mu quad "(確率収束等)"$]
    弱定常過程では
    #eq[$"Var"(overline(X)_T)=frac(1,T^2)sum_(t=1)^T sum_(s=1)^T gamma(t-s)$]
    が0へ収束すれば平均エルゴード的。十分条件の一つは $sum_(h=-infinity)^infinity |gamma(h)|<infinity$。

    *定常性との違い*：定常＝分布が時間で変わらない。エルゴード＝時間平均が期待値へ収束。定常でも非エルゴードの場合がある。

    *反例*：$X_t=Z$（全時点で同じ確率変数）。強定常だが $overline(X)_T=Z$ のままで一般に $E(Z)$ へ収束しない。
    #key[実データは通常1本の系列のみ。時間平均で理論モーメントを推定する根拠がエルゴード性。]
  ]

  #sec([3｜ホワイトノイズ])[
    $u_t ~ "WN"(sigma^2)$ の定義：
    #eq[$E(u_t)=0,quad "Var"(u_t)=sigma^2,quad "Cov"(u_t,u_s)=0 (t!=s)$]
    よって $E(u_t u_s)=0 (t!=s)$、$E(u_t^2)=sigma^2$。ACFは $rho(0)=1$、$rho(h)=0 (h!=0)$。

    *注意*：無相関は独立より弱い。iid $(0,sigma^2)$ ならWNだが、WNだけでは独立・正規性を仮定しない。$y_t=mu+u_t$ は平均 $mu$、分散 $sigma^2$ の弱定常過程。
  ]

  #sec([3｜標本自己共分散・自己相関], color: green)[
    観測 $x_1,dots,x_T$、標本平均 $overline(x)$：
    #eq[$hat(gamma)(k)=frac(1,T)sum_(t=k+1)^T(x_t-overline(x))(x_(t-k)-overline(x))$]
    #eq[$hat(rho)(k)=frac(hat(gamma)(k),hat(gamma)(0))$]
    WNの帰無仮説の下で個々の標本ACFの概算95%帯：
    #eq[$plus.minus frac(1.96,sqrt(T))$]
    帯外のラグは系列相関の候補。ただし多数ラグを同時に見るときはLjung–Box等も検討。
  ]

  #sec([3｜GDP例：変換の読み方])[
    原系列：長期上昇＋景気ショックで非定常に見える。対数：水準が大きい時期の変動幅を相対化。対数差分：おおむね四半期成長率で、平均周りに変動。

    レポートのGDP対数差分では $hat(rho)(1)=-.089$、$hat(rho)(2)=.159$、$hat(rho)(3)=-.161$。10次まで概算95%帯内で、強い自己相関は確認されなかった。
  ]

  #sec([2–3｜見分け方の要点], color: gray)[
    ①図でトレンド・季節・分散変化を確認。②正値なら対数、トレンドなら差分、季節なら季節差分。③定常性は「平均一定・共分散はラグのみ」。④強定常は結合分布全体。⑤1本の経路から平均等を推定するにはエルゴード性。⑥標本ACFは理論ACFの推定値であり有限標本誤差を持つ。
  ]
]

#pagebreak()

#title([計量時系列分析 チートシート], [裏面：MA・AR])

#columns(2, gutter: 1mm)[
  #sec([4｜ラグ演算子と多項式])[
    ラグ演算子 $L y_t=y_(t-1)$。ARMA$(p,q)$：
    #eq[$phi(L)(y_t-mu)=theta(L)u_t$]
    #eq[$phi(z)=1-phi_1 z-dots-phi_p z^p$]
    #eq[$theta(z)=1+theta_1 z+dots+theta_q z^q$]
    AR多項式は定常性・因果性、MA多項式は反転可能性を判定する。
  ]

  #sec([4–5｜特性方程式【必須】], color: red)[
    *AR特性方程式*：
    #eq[$phi(z)=1-phi_1 z-dots-phi_p z^p=0$]
    全根が単位円の外側（$|z_i|>1$）なら因果的な弱定常解を持つ。

    *MA特性方程式*：
    #eq[$theta(z)=1+theta_1 z+dots+theta_q z^q=0$]
    全根が単位円の外側なら反転可能（$u_t$ を現在・過去の $y$ で一意に復元）。

    #key[規約注意：$r^p-phi_1r^(p-1)-dots-phi_p=0$ と書く場合、根は上の $z$ の逆数なので定常条件は $|r|<1$。]
  ]

  #sec([4｜MA($q$)の一般モーメント])[
    #eq[$y_t=mu+sum_(j=0)^q theta_j u_(t-j),quad theta_0=1,quad u_t~"WN"(sigma^2)$]
    #eq[$E(y_t)=mu,quad gamma(0)=sigma^2 sum_(j=0)^q theta_j^2$]
    #eq[$gamma(k)=sigma^2 sum_(j=0)^(q-k) theta_j theta_(j+k) quad (1<=k<=q)$]
    #eq[$gamma(k)=0 quad (k>q),quad rho(k)=gamma(k)/gamma(0)$]
    有限次数MAは常に弱定常。ACFは $q$ 次で理論上打ち切られる。
  ]

  #sec([4｜MA(1)・MA(2)])[
    MA(1)：$y_t=mu+u_t+theta u_(t-1)$
    #eq[$gamma(0)=(1+theta^2)sigma^2,quad gamma(1)=theta sigma^2$]
    #eq[$rho(1)=frac(theta,1+theta^2),quad rho(k)=0 (k>=2)$]
    $theta>0$ なら隣接値は同方向、$theta<0$ なら逆方向へ動きやすい。

    MA(2)：$y_t=mu+u_t+theta_1 u_(t-1)+theta_2 u_(t-2)$
    #eq[$gamma(0)=(1+theta_1^2+theta_2^2)sigma^2$]
    #eq[$gamma(1)=theta_1(1+theta_2)sigma^2,quad gamma(2)=theta_2sigma^2$]
    3次以上は0。例 $(theta_1,theta_2)=(.3,-.1)$：$rho(1)=.245,rho(2)=-.091$。
  ]

  #sec([4｜MAの反転可能性])[
    MA(1) $y_t=u_t+theta u_(t-1)$：特性方程式 $1+theta z=0$ の根 $z=-1/theta$。よって
    #key[$|z|>1 <=> |theta|<1$]
    繰返し代入：
    #eq[$u_t=y_t-theta y_(t-1)+theta^2 y_(t-2)-dots=sum_(j=0)^infinity(-theta)^j y_(t-j)$]
    したがってAR($infinity$)表現：
    #eq[$y_t=theta y_(t-1)-theta^2y_(t-2)+theta^3y_(t-3)-dots+u_t$]
    反転可能性により異なるMA係数による同一ACF表現を排除し、撹乱項を観測系列から復元できる。
  ]

  #sec([4｜MA(2)反転可能性の例], color: green)[
    $y_t=2+u_t+.3u_(t-1)-.1u_(t-2)$：
    #eq[$1+.3z-.1z^2=0 => z=5,-2$]
    両根とも絶対値 $>1$ なので反転可能。理論平均2、分散 $1.10sigma^2$、ACFは2次で打切り。
  ]

  #colbreak()

  #sec([5｜AR($p$)の定義と平均])[
    #eq[$y_t=c+sum_(j=1)^p phi_j y_(t-j)+u_t,quad u_t~"WN"(sigma^2)$]
    定常平均が存在すれば
    #eq[$mu=frac(c,1-sum_(j=1)^p phi_j)$]
    平均偏差 $x_t=y_t-mu$ とすれば $x_t=sum phi_j x_(t-j)+u_t$。ARはACFが一般に幾何的または減衰振動し、PACFが $p$ 次で打ち切られる。
  ]

  #sec([5｜ユールウォーカー方程式【必須】], color: red)[
    定常AR($p$)を $y_t-mu=sum_(j=1)^p phi_j(y_(t-j)-mu)+u_t$ とする。両辺に $y_(t-k)-mu$ を掛け期待値を取る：
    #eq[$gamma(k)=sum_(j=1)^p phi_j gamma(k-j)quad(k>=1)$]
    $k=0$ では撹乱項分散が加わる：
    #eq[$gamma(0)=sum_(j=1)^p phi_j gamma(j)+sigma^2$]
    自己相関形：
    #eq[$rho(k)=sum_(j=1)^p phi_j rho(k-j),quad rho(-k)=rho(k)$]
    行列形（$r=(rho(1),dots,rho(p))'$）：
    #eq[$mat(1,rho(1),dots,rho(p-1);rho(1),1,dots,rho(p-2);dots,dots,dots,dots;rho(p-1),rho(p-2),dots,1) mat(phi_1;phi_2;dots;phi_p)=mat(rho(1);rho(2);dots;rho(p))$]
    標本自己相関を代入してAR係数を推定するのがYule–Walker推定。
  ]

  #sec([5｜AR(1)の性質])[
    #eq[$y_t=c+phi y_(t-1)+u_t$]
    特性根 $z=1/phi$ より定常条件 $|phi|<1$。
    #eq[$mu=frac(c,1-phi),quad gamma(0)=frac(sigma^2,1-phi^2)$]
    Yule–Walkerより
    #eq[$gamma(k)=phi gamma(k-1),quad rho(k)=phi^k$]
    $phi>0$：単調減衰、$phi<0$：符号を交互に変えて減衰。$phi=1$：単位根、$|phi|>1$：発散的で非定常。

    MA($infinity$)表現：
    #eq[$y_t-mu=sum_(j=0)^infinity phi^j u_(t-j)$]
    ショックの影響は $phi^j$。定常性は過去ショック係数の絶対可和・二乗可和を保証する。
  ]

  #sec([5｜AR(2)の定常性])[
    #eq[$y_t=c+phi_1 y_(t-1)+phi_2 y_(t-2)+u_t$]
    特性方程式 $1-phi_1 z-phi_2 z^2=0$ の全根が $|z|>1$。係数条件：
    #eq[$phi_1+phi_2<1,quad phi_2-phi_1<1,quad -1<phi_2<1$]
    #eq[$mu=frac(c,1-phi_1-phi_2)$]
    Yule–Walker：
    #eq[$rho(1)=frac(phi_1,1-phi_2),quad rho(k)=phi_1 rho(k-1)+phi_2 rho(k-2)$]
    実根なら指数減衰の和、複素根なら減衰振動。
  ]

  #sec([5｜AR(2)例])[
    $y_t=1+.5y_(t-1)+.2y_(t-2)+u_t$：
    #eq[$phi_1+phi_2=.7<1,quad phi_2-phi_1=-.3<1,quad |phi_2|<1$]
    よって定常。
    #eq[$mu=frac(1,1-.5-.2)=3.333$]
    #eq[$rho(1)=frac(.5,1-.2)=.625,quad rho(2)=.5(.625)+.2=.5125$]
    以後 $rho(k)=.5rho(k-1)+.2rho(k-2)$。
  ]

  #sec([4–5｜ACF・PACFと識別], color: green)[
    #table(
      columns: (0.8fr, 1.4fr, 1.4fr),
      align: center + horizon,
      [過程], [ACF], [PACF],
      [AR($p$)], [徐々に減衰], [$p$ 次で打切り],
      [MA($q$)], [$q$ 次で打切り], [徐々に減衰],
      [ARMA], [徐々に減衰], [徐々に減衰],
    )
    「打切り」は理論値。標本ACF/PACFは有限標本誤差で0付近に散らばる。
  ]

  #sec([2–5｜直前確認], color: gray)[
    *定常性*：AR特性根は単位円外。*反転可能性*：MA特性根は単位円外。*MA*：有限次数なら常に定常、ACF打切り。*AR*：条件付きで定常、PACF打切り。*Yule–Walker*：AR係数と自己共分散の再帰関係、$k=0$ のみ $sigma^2$ を加える。*弱 vs 強*：2次モーメント vs 結合分布全体。*エルゴード*：時間平均 $->$ 期待値。
  ]
]
