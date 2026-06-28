#set page(
  paper: "a4",
  margin: (x: 3.5mm, y: 3.5mm),
  numbering: "1 / 2",
  number-align: bottom + right,
)
#set text(
  font: ("Noto Serif CJK JP", "New Computer Modern Math"),
  size: 10.5pt,
  fill: rgb("#111827"),
)
#show math.equation: set text(font: ("New Computer Modern Math", "Noto Serif CJK JP"))
#set par(justify: true, leading: 0.52em, spacing: 0.25em)
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
      text(size: 7.5pt, fill: gray)[#side｜第6〜8回],
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
    )[#text(fill: white, weight: "bold", size: 10.4pt)[#name]]
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

#title([計量時系列分析 チートシート], [表面：推定・予測])

#columns(2, gutter: 1mm)[
  #sec([6｜AR(1)の条件付き最尤法])[
    *モデル・定常条件*
    #eq[$y_t=c+phi y_(t-1)+u_t,quad u_t ~ "iid" N(0,sigma^2),quad |phi|<1$]
    平均 $mu=c/(1-phi)$、無条件分散 $V(y_t)=sigma^2/(1-phi^2)$。$y_0$ を所与とする条件付き密度：
    #eq[$f(y_t|y_(t-1);Theta)=frac(1,sqrt(2pi sigma^2)) exp(-frac((y_t-c-phi y_(t-1))^2,2sigma^2))$]
    $Theta=(c,phi,sigma^2)$、条件付き尤度は
    #eq[$L(Theta)=product_(t=1)^T f(y_t|y_(t-1);Theta)$]
    対数尤度：
    #eq[$ell=-frac(T,2)log(2pi)-frac(T,2)log sigma^2-frac(1,2sigma^2) sum_(t=1)^T (y_t-c-phi y_(t-1))^2$]
    $c,phi$ に関係するのは残差平方和だけ。したがって正規性の下で *条件付きMLEの $hat(c),hat(phi)$ はOLSと一致*。
  ]

  #sec([6｜正規方程式と推定量])[
    #eq[$sum y_t=T c+phi sum y_(t-1)$]
    #eq[$sum y_(t-1)y_t=c sum y_(t-1)+phi sum y_(t-1)^2$]
    $overline(y)_0=T^(-1)sum y_(t-1)$、$overline(y)_1=T^(-1)sum y_t$ とおけば
    #eq[$hat(phi)=frac(sum (y_(t-1)-overline(y)_0)(y_t-overline(y)_1),sum (y_(t-1)-overline(y)_0)^2)$]
    #eq[$hat(c)=overline(y)_1-hat(phi)overline(y)_0$]
    分散について $partial ell/partial sigma^2=0$ より
    #eq[$hat(sigma)^2=frac(1,T)sum_(t=1)^T (y_t-hat(c)-hat(phi)y_(t-1))^2$]
    #key[*注意*：MLEの分母は $T$。不偏分散推定量の $T-2$ ではない。]
  ]

  #sec([6｜条件付き尤度 vs 正確尤度], color: green)[
    *条件付き*：初期値 $y_0$ を固定値として扱い、$t=1,dots,T$ の条件付き密度だけを使う。

    *正確尤度*：定常分布
    #eq[$y_0 ~ N(mu, sigma^2/(1-phi^2))$]
    の密度も尤度に含める。したがって有限標本では推定値が少し異なる。$T -> infinity$ では初期値1個の影響が相対的に小さくなる。

    報告例（真値 $c=.4,phi=.8,mu=2,sigma^2=1$）：
    #table(
      columns: (1.2fr, 0.8fr, 0.8fr, 0.8fr, 0.8fr),
      align: center + horizon,
      [方法], [$c$], [$phi$], [$mu$], [$sigma^2$],
      [条件付], [.414], [.703], [1.392], [.936],
      [正確], [.388], [.704], [1.311], [.937],
    )
  ]

  #sec([6｜推定量の有限標本性質], color: green)[
    1000回反復の要点：$T$ が増えるほど $hat(phi)$ の標準偏差が縮小し、平均は真値へ接近（一致性）。$phi$ が1に近いと有限標本で下方バイアスが目立つ。
    #table(
      columns: (0.7fr, 0.7fr, 1fr, 1fr),
      align: center + horizon,
      [$phi$], [$T$], [平均], [SD],
      [.3], [50], [.261], [.139],
      [.3], [100], [.277], [.100],
      [.3], [400], [.296], [.047],
      [.8], [50], [.730], [.106],
      [.8], [100], [.769], [.067],
      [.8], [400], [.790], [.032],
      [-.5], [50], [-.494], [.125],
      [-.5], [400], [-.500], [.043],
    )
    #key[持続性が高い（$phi approx 1$）ほど、小標本の推定・推論に注意。]
  ]

  #sec([7｜最適予測＝条件付き期待値])[
    時点 $t$ の情報集合に関する期待値を $E_t$ とし、$mu_(t+h|t)=E_t(y_(t+h))$。任意の予測 $tilde(y)$ に対し
    #eq[$E_t(y-tilde(y))^2=E_t(y-mu)^2+E_t(mu-tilde(y))^2$]
    が成立。交差項は
    #eq[$2(mu-tilde(y))E_t(y-mu)=0$]
    で、第2項は非負。よって二乗誤差を最小にする予測は
    #key[$hat(y)_(t+h|t)=E_t(y_(t+h))$]
    *証明の型*：誤差を「予測不能部分 $y-mu$」＋「予測のずれ $mu-tilde(y)$」に分解する。
  ]

  #colbreak()

  #sec([7｜AR(1)の $h$ 期先予測])[
    逐次代入：
    #eq[$y_(t+h)=c sum_(j=0)^(h-1)phi^j+phi^h y_t+sum_(j=0)^(h-1)phi^j u_(t+h-j)$]
    将来ショックの条件付き期待値は0なので
    #eq[$hat(y)_(t+h|t)=frac(c(1-phi^h),1-phi)+phi^h y_t$]
    $mu=c/(1-phi)$ を使えば、覚えやすい形は
    #key[$hat(y)_(t+h|t)=mu+phi^h(y_t-mu)$]
    予測誤差：
    #eq[$e_(t+h|t)=sum_(j=0)^(h-1)phi^j u_(t+h-j)$]
    よって
    #eq[$"MSE"_h=sigma^2 sum_(j=0)^(h-1)phi^(2j)=frac(1-phi^(2h),1-phi^2)sigma^2$]
  ]

  #sec([7｜予測ホライズンと極限], color: green)[
    $|phi|<1$ なら $phi^h -> 0$：
    #eq[$hat(y)_(t+h|t) -> mu$]
    長期予測は現在値の影響を失い、無条件平均へ平均回帰する。
    #eq[$"MSE"_(h+1)-"MSE"_h=sigma^2 phi^(2h)>=0$]
    MSEは単調増加し、
    #eq[$lim_(h -> infinity)"MSE"_h=frac(sigma^2,1-phi^2)=V(y_t)$]
    #key[定常AR：長期点予測 $->$ 平均、長期MSE $->$ 無条件分散。]
  ]

  #sec([7｜区間予測の基本], color: green)[
    正規性の下で $h$ 期先95%区間は
    #eq[$hat(y)_(t+h|t) plus.minus 1.96 sqrt("MSE"_h)$]
    1期先なら $"MSE"_1=sigma^2$。$h$ が増えるとMSEは増えるが、定常ARでは有限値へ収束する。
  ]

  #sec([7｜AR(2)の平均と予測])[
    一般のAR(2)：
    #eq[$y_t=c+phi_1 y_(t-1)+phi_2 y_(t-2)+u_t$]
    定常なら平均は
    #eq[$mu=frac(c,1-phi_1-phi_2)$]
    逐次予測は「未来の $u$ を0、未観測の $y$ を直前の予測値で置換」。

    課題例：$c=1.1,phi_1=.3,phi_2=-.4,sigma^2=9$。
    #eq[$mu=frac(1.1,1-.3-(-.4))=1$]
    末尾 $y_49=-4.657,y_50=.186$ のとき
    #eq[$hat(y)_(51|50)=1.1+.3y_50-.4y_49=3.019$]
    #eq[$hat(y)_(52|50)=1.1+.3hat(y)_(51|50)-.4y_50=1.931$]
  ]

  #sec([7｜AR(2)の予測区間])[
    1期先誤差はそのまま $u_51$：
    #eq[$"MSE"_1=9,quad "SE"_1=3$]
    #eq[$95%: 3.019 plus.minus 1.96 times 3=[-2.861,8.899]$]
    2期先では $u_51$ が $phi_1$ 倍で次期へ伝播し、新しい $u_52$ も加わる：
    #eq[$e_(52|50)=u_52+phi_1u_51$]
    #eq[$"MSE"_2=sigma^2(1+phi_1^2)$]
    一般のAR($p$)でも、再帰的点予測＋インパルス応答係数による誤差分散で考える。
  ]

  #sec([7｜ACF・PACFの読み方], color: green)[
    *ACF*：$k$ 期離れた系列の相関。*PACF*：途中のラグ $1,dots,k-1$ の影響を除いたラグ $k$ の相関。

    代表的識別：
    #table(
      columns: (0.7fr, 1fr, 1fr),
      align: center + horizon,
      [過程], [ACF], [PACF],
      [AR($p$)], [徐々に減衰], [$p$ 次で打切り],
      [MA($q$)], [$q$ 次で打切り], [徐々に減衰],
      [ARMA], [徐々に減衰], [徐々に減衰],
    )
    目安の95%帯は $plus.minus 1.96/sqrt(T)$。課題の標本では ACF$(1)=.251,$ ACF$(2)=-.043$、PACF$(1)=.251,$ PACF$(2)=-.113$。
  ]

  #sec([6–7｜試験用チェックリスト], color: red)[
    ① 定常条件と平均を先に確認。② 尤度は「密度の積→対数→SSR最小化」。③ MLE分散の分母は $T$。④ 最適予測は条件付き期待値。⑤ 未知の将来値は予測値、将来ショックは0。⑥ 区間は点予測 $plus.minus$ 臨界値 $times sqrt("MSE")$。⑦ 長期極限で平均回帰とMSE収束を確認。
  ]
]

#pagebreak()

#title([計量時系列分析 チートシート], [裏面：単位根・共和分])

#columns(2, gutter: 1mm)[
  #sec([8｜単位根・和分次数])[
    ランダムウォーク（ドリフト付き）：
    #eq[$y_t=delta+y_(t-1)+u_t,quad u_t ~ "iid" (0,sigma^2)$]
    #eq[$Delta y_t=delta+u_t ~ I(0) => y_t ~ I(1)$]
    $d$ 回差分して初めて定常なら $I(d)$。ARIMA$(p,d,q)$ は $d$ 回差分後が定常・反転可能なARMA$(p,q)$。

    $y_t=delta t+v_t$ と書けば確率的トレンド $v_t=sum_(s=1)^t u_s$ を持つ。ショックは永久に残り、平均回帰しない。
    #eq[$E(y_t-delta t)^2=V(v_t)=t sigma^2$]
    対してトレンド定常 $y_t=delta t+x_t, x_t ~ I(0)$ ではトレンドからの分散は一定。
  ]

  #sec([8｜ランダムウォークの予測])[
    #eq[$y_(t+h)=y_t+h delta+sum_(j=1)^h u_(t+j)$]
    #eq[$hat(y)_(t+h|t)=y_t+h delta$]
    #eq[$"MSE"_h=h sigma^2$]
    #key[定常ARと違い、予測は平均へ戻らず、MSEは $h$ とともに発散。]
    単位根検定：DF、ADF、PP。ADFの基本形は
    #eq[$Delta y_t=alpha+gamma y_(t-1)+sum_(i=1)^p psi_i Delta y_(t-i)+e_t$]
    $H_0:gamma=0$（単位根）対 $H_1:gamma<0$（定常）。通常の $t$ 分布ではなくDF臨界値を使う。定数・トレンド項の有無をデータ生成過程に合わせる。
  ]

  #sec([8｜株価と効率的市場仮説], color: green)[
    *適する面*：公開情報が即座に価格へ反映され、新情報 $u_t$ が予測不能なら価格変化も予測不能。現在価格が将来価格の基準予測となり、ショックの持続性も表せる。

    *限界*：効率的市場仮説が要求するのは「利用可能情報からリスク調整後超過収益を継続的に得られない」ことであり、価格水準の厳密なランダムウォークではない。期待収益、時変ボラティリティ、ジャンプ等を単純なiid撹乱だけでは表せない。

    #key[結論：予測困難性の基準モデルとして有用。ただし収益率分布・リスクの完全なモデルではない。]
  ]

  #sec([8｜和分過程の線形和], color: green)[
    #table(
      columns: (1fr, 1fr),
      align: center + horizon,
      [線形和], [結果],
      [$I(0)+I(0)$], [$I(0)$],
      [$I(1)+I(0)$], [$I(1)$],
      [$I(1)+I(1)$], [$I(0)$ または $I(1)$],
    )
    最後のケースで確率的トレンドが相殺されれば共和分。
  ]

  #sec([8｜見せかけの回帰])[
    独立な2系列
    #eq[$x_t=x_(t-1)+v_t,quad y_t=y_(t-1)+w_t$]
    をレベルで
    #eq[$y_t=alpha+beta x_t+epsilon_t$]
    とOLS回帰すると、無関係でも $t$ 値が大きく、高い $R^2$ が出る。残差が非定常・系列相関を持ち、通常の標準誤差と $t,F$ 分布の前提が崩れるため。

    *症状*：係数が有意／$R^2$ が高い／Durbin--Watsonが低いことがあっても因果・関係の証拠ではない。

    *解決*：共和分なし→差分回帰
    #eq[$Delta y_t=alpha+beta Delta x_t+e_t$]
    必要なら差分のラグを追加。共和分あり→レベルの長期関係を捨てずECMを使う。
  ]

  #sec([8｜シミュレーション結果], color: red)[
    $T=100$、独立なRW、5000回。通常の5% $t$ 検定は本来無関係なのに大幅に過剰棄却。
    #table(
      columns: (0.55fr, 1fr, 1fr, 1fr, 1fr),
      align: center + horizon,
      [$delta$], [$alpha$ 棄却], [$beta$ 棄却], [$R^2$ 中央], [$R^2$ 90%],
      [0], [83.4%], [76.4%], [.170], [.606],
      [.2], [80.1%], [94.8%], [.653], [.881],
    )
    ドリフトありでは共通の決定論的増加傾向も回帰関係と誤認し、傾きの有意性と $R^2$ が特に高くなる。
    #key[「有意＋高 $R^2$」でも、まず単位根・残差定常性を確認。]
  ]

  #colbreak()

  #sec([8｜共和分の定義])[
    $x_t,y_t ~ I(1)$ とする。非零ベクトル $(a,b)'$ が存在して
    #eq[$a x_t+b y_t ~ I(0)$]
    なら共和分。$(a,b)'$ は共和分ベクトル。定数倍も同じ関係なので $a=1$ 等に基準化する。

    経済的意味：各系列は平均回帰しなくても、乖離
    #eq[$z_t=y_t-beta x_t ~ I(0)$]
    は平均回帰する。長期均衡 $y_t approx alpha+beta x_t$ からのずれが一時的。
  ]

  #sec([8｜共和分の例／反例], color: green)[
    $z_t,w_t$：独立RW、$u_t,v_t$：定常。

    *あり*：$x_t=z_t+u_t, y_t=2z_t+v_t$
    #eq[$y_t-2x_t=v_t-2u_t ~ I(0)$]
    共有する確率的トレンド $z_t$ が消える。ベクトル $(-2,1)'$。

    *なし*：$x_t=z_t+u_t, y_t=w_t+v_t$
    #eq[$a x_t+b y_t=a z_t+b w_t+a u_t+b v_t$]
    独立トレンド $z_t,w_t$ を同時に消すには $a=b=0$ しかなく、非零の共和分ベクトルなし。
  ]

  #sec([8｜Engle–Granger 2段階検定])[
    前提：各系列が $I(1)$ であることをADF等で確認。

    *Step 1* レベル回帰：
    #eq[$x_t=alpha+beta y_t+epsilon_t$]
    OLS残差
    #eq[$hat(epsilon)_t=x_t-hat(alpha)-hat(beta)y_t$]
    を保存。

    *Step 2* 残差の単位根検定：
    #eq[$Delta hat(epsilon)_t=rho hat(epsilon)_(t-1)+sum psi_i Delta hat(epsilon)_(t-i)+e_t$]
    $H_0$：残差に単位根（共和分なし）。棄却して $hat(epsilon)_t ~ I(0)$ なら共和分あり。

    #key[推定残差を使うため、通常ADFではなくEngle–Granger専用臨界値。]
  ]

  #sec([8｜共和分あり：ECM])[
    共和分関係 $y_t-alpha-beta x_t$ が定常なら、短期変化と長期均衡への復帰を同時に表す：
    #eq[$Delta y_t=lambda(y_(t-1)-alpha-beta x_(t-1))+gamma Delta x_t+e_t$]
    $lambda$ は調整速度。均衡より $y$ が高いとき次期に下がって戻るには通常 $lambda<0$。

    *短期効果*：$gamma$。*長期関係*：$y=alpha+beta x$。共和分がないのに誤差修正項を入れる根拠はない。
  ]

  #sec([8｜解析の判断フロー], color: red)[
    *1* 原系列を図示し、定数・トレンドを検討。

    *2* 各系列にADF/PP：$I(0)$ か $I(1)$ か確認。

    *3* 両方 $I(1)$ でレベル関係を考えるならEngle–Granger。

    *4A* 残差 $I(0)$ → 共和分あり → ECM（長期＋短期）。

    *4B* 残差 $I(1)$ → 共和分なし → 差分系列で解析。

    *禁止*：単位根系列のレベル回帰の通常 $t$ 値・$R^2$ をそのまま解釈。
  ]

  #sec([6–8｜比較で覚える], color: blue)[
    #table(
      columns: (1fr, 1fr, 1fr),
      align: center + horizon,
      [性質], [定常AR], [単位根],
      [ショック], [減衰], [永久],
      [長期予測], [平均へ], [現在値＋ドリフト],
      [長期MSE], [分散へ収束], [発散],
      [回帰], [通常推論可], [見せかけ注意],
    )
  ]

  #sec([直前確認｜記号と落とし穴], color: gray)[
    $Delta y_t=y_t-y_(t-1)$。$I(0)$＝定常、$I(1)$＝1階差分で定常。MLEの $hat(sigma)^2$ 分母は $T$。予測区間はMSEの平方根を使う。単位根検定の帰無仮説は「単位根あり」。共和分検定は「残差の単位根」を調べる。相関・有意性・高 $R^2$ だけで長期関係と判断しない。
  ]
]
