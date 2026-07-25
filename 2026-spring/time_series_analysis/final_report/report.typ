#import "/template.typ": setup
#show: setup

#import "assets/summary.typ": *

#align(center)[
  #text(size: 15pt, weight: "bold")[計量時系列分析 最終レポート]

  #v(2mm)
  #text(size: 12pt, weight: "bold")[名目・実質実効為替レートの短期連動と長期乖離]

  #v(4mm)
  202410178 今村隼人
]

= 分析目的

円相場を見るとき、円ドルレートのような二通貨間の為替レートだけでは、円が貿易相手国の通貨全体に対してどのように変化したかは分からない。名目実効為替レートは複数の二国間レートを貿易上の重要度で集計した指数であり、実質実効為替レートはさらに内外の物価変動を調整した指数である。両者は同じ名目為替変動を含むため短期的には連動すると考えられるが、相対物価の変化が累積すれば長期的な関係は変わりうる。

本稿では、日本銀行が公表する月次の名目・実質実効為替レートを用い、次の3点を検証する。

+ 両系列は単位根を持つか。また、長期的な共和分関係を持つか。
+ 月次変化はどの程度連動し、長期的な乖離とどのように両立しているか。
+ 実質実効為替レートの短期予測で、単純なARIMAモデルはランダムウォークを上回るか。

= データと分析方法

== データ

日本銀行時系列統計データ検索サイトから、名目実効為替レート `FX180110001` と実質実効為替レート `FX180110002` をAPIで取得した。対象は #sample-start から #sample-end までの月次 #sample-n 観測で、欠測はない。単位はいずれも2020年平均を100とする指数であり、データの最終更新日は #data-last-update、取得日は2026年7月13日である。

指数の上昇は円の実効的な増価、低下は減価を表す。ただし、100は基準年に合わせた正規化にすぎず、100未満であること自体は円の「過小評価」を意味しない。現行値はBISのBroad系列に基づくが、Broad系列が存在しない1993年以前はNarrow系列の前月比で遡及推計されている。また、貿易ウェイトの更新時には過去値も改訂されるため、本稿の結果は上記取得時点のデータに対するものである。

== 変数と検定

名目指数を $N_t$、実質指数を $R_t$ とし、
$
  n_t = log N_t, quad r_t = log R_t, quad g_t = r_t - n_t
$
とおく。$Delta n_t$ と $Delta r_t$ はそれぞれの月次変化率の近似であり、$g_t$ は実質と名目の対数乖離である。加工値、推定値および図表はPythonで計算した。

定常性は、定数項を含むADF回帰
$
  Delta x_t = alpha + gamma x_(t-1)
    + sum_(i=1)^p beta_i Delta x_(t-i) + u_t
$
により検定した。最大ラグは月次データを考慮して12とし、AICで $p$ を選んだ。帰無仮説は $gamma=0$、すなわち単位根が存在することである。長期関係は
$
  r_t = alpha + beta n_t + epsilon_t
$
を推定し、残差の単位根を調べるEngle--Granger検定で確認した。

短期関係では、$100 Delta r_t$ を $100 Delta n_t$ に回帰した。標準誤差は残差の系列相関と不均一分散を考慮し、最大12ラグのHAC標準誤差とした。傾きが1であるという仮説はWald検定、係数の安定性はOLS残差のCUSUM検定で調べた。この回帰は定義上関連する2指数の記述であり、因果効果の推定ではない。

予測では、#sample-start から2015年12月までを初期推定期間とした。$p,q=0,dots,3$ のARIMA$(p,1,q)$について、ドリフトの有無も含めてAICを比較した。その後、2016年1月から #sample-end まで毎月推定期間を1観測ずつ延長し、1か月先予測を #evaluation-n 回行った。比較対象は、翌月も当月値と同じとするドリフトなしランダムウォークである。両モデルの対数二乗誤差の差は、最大12ラグのHAC標準誤差を用いた平均値の検定でも比較した。

= 系列の長期的推移

#figure(
  image("assets/effective_exchange_rates.svg", width: 100%),
  caption: [日本の名目・実質実効為替レート],
)

図1では、短期的な山と谷は概ね共通しているが、長期的な水準は大きく異なる。主な記述統計は次の通りである。

#table(
  columns: (1.1fr, 1fr, 1.45fr, 1.45fr),
  inset: 5pt,
  align: center + horizon,
  [系列], [最新値], [最小値], [最大値],
  [名目], [#nominal-latest], [#nominal-min（#nominal-min-date）], [#nominal-max（#nominal-max-date）],
  [実質], [#real-latest], [#real-min（#real-min-date）], [#real-max（#real-max-date）],
)

名目指数の最大値は2012年に現れる一方、実質指数の最大値は1995年である。実質指数はその後長期的に低下し、2026年4月に標本期間中の最小値 #real-min を記録した。最新の2026年5月も #real-latest であり、2020年平均を大きく下回る。ただし、この事実だけから均衡水準や過大・過小評価を判断することはできない。

#figure(
  image("assets/gap_and_rolling_correlation.svg", width: 96%),
  caption: [名目・実質指数の対数乖離と月次変化のローリング相関],
)

図2上段の $100g_t$ は長期的に低下している。最新時点では #gap-latest であり、同じ2020年基準で実質指数が名目指数より対数で約4.2ポイント低い。一方、下段の120か月ローリング相関は一貫して高く、最新値も #rolling-correlation-latest である。したがって、「短期変化はほぼ同じ」であることと、「水準の差は長期的に累積する」ことが同時に観察される。

= 単位根と共和分

ADF検定の結果を次表に示す。

#table(
  columns: (1.45fr, 1fr, 0.9fr, 0.8fr),
  inset: 5pt,
  align: center + horizon,
  [系列], [ADF統計量], [$p$ 値], [ラグ],
  [$n_t$], [#adf-log-nominal-stat], [#adf-log-nominal-p], [#adf-log-nominal-lag],
  [$r_t$], [#adf-log-real-stat], [#adf-log-real-p], [#adf-log-real-lag],
  [$Delta n_t$], [#adf-dlog-nominal-stat], [#adf-dlog-nominal-p], [#adf-dlog-nominal-lag],
  [$Delta r_t$], [#adf-dlog-real-stat], [#adf-dlog-real-p], [#adf-dlog-real-lag],
  [$g_t=r_t-n_t$], [#adf-gap-stat], [#adf-gap-p], [#adf-gap-lag],
)

$n_t$ と $r_t$ はともに5%水準で単位根の帰無仮説を棄却できないが、1階差分では強く棄却される。したがって、両系列は $I(1)$ と判断できる。対数乖離 $g_t$ についても単位根を棄却できず、単純な1対1の乖離は平均回帰しない。

Engle--Granger検定では、検定統計量が #coint-stat、$p$ 値が #coint-p であり、共和分なしという帰無仮説を棄却できなかった。名目と実質は共通の為替変動を含むものの、相対物価による調整部分が長期的に累積するため、固定した線形結合が定常になるとは限らない。よって、水準同士の高い見かけ上の関係を通常の回帰として解釈したり、誤差修正モデルを用いたりする根拠は得られない。

= 月次変化の短期関係

#figure(
  image("assets/monthly_changes_scatter.svg", width: 74%),
  caption: [名目・実質実効為替レートの月次対数変化],
)

月次対数差分の相関係数は #change-correlation である。横軸を $x_t=100 Delta n_t$、縦軸を $y_t=100 Delta r_t$ とすると、推定結果は
$
  y_t = #change-alpha + #change-beta x_t + e_t, quad R^2=#change-r2
$
となった。

#table(
  columns: (1.2fr, 1fr, 1fr, 1fr),
  inset: 5pt,
  align: center + horizon,
  [項目], [推定値], [HAC標準誤差], [$p$ 値],
  [定数項（%）], [#change-alpha], [#change-alpha-se], [#change-alpha-p],
  [$x_t$ の係数], [#change-beta], [#change-beta-se], [#change-beta-p],
)

傾きは1に非常に近く、$beta=1$ のWald検定でも棄却されなかった（$p=#change-beta-one-p$）。したがって、名目指数が当月に1%変化すると、実質指数も全期間平均ではほぼ同じ方向・大きさで変化している。一方、定数項は月平均で -0.172%である。この小さな差が長期間累積することが、図2の長期乖離につながっている。

ただし、CUSUM統計量は #change-cusum-stat、$p$ 値は #change-cusum-p であり、係数が全期間で安定しているという帰無仮説は棄却された。よって、1対1という結果は標本全体の平均的な関係であって、各時期に不変の構造パラメータではない。また、実質指数は名目指数を相対物価で調整して作られるため、この高い説明力は機械的な共通成分を反映しており、名目変化が実質変化を「引き起こす」とは解釈しない。

= ARIMAモデルと予測

== 同定と推定

#figure(
  image("assets/real_change_correlogram.svg", width: 88%),
  caption: [実質実効為替レートの月次対数差分のACFとPACF],
)

$Delta r_t$ の1次自己相関は #acf-one であり、無相関のおおよその95%範囲 $plus.minus #acf-bound$ を超えている。正の変化の翌月には同方向の変化が続く傾向がある。初期推定期間における主なモデルのAICは次の通りであった。

#table(
  columns: (1.7fr, 1fr),
  inset: 5pt,
  align: center + horizon,
  [モデル], [AIC],
  [ARIMA$(0,1,0)$], [#aic-rw],
  [ARIMA$(1,1,0)$], [#aic-arima-110],
  [ARIMA$(0,1,1)$], [#aic-arima-011],
  [ARIMA$(0,1,2)$], [#aic-arima-012],
)

AICが最小となったドリフトなしARIMA$(1,1,0)$を採用した。全期間で再推定すると、
$
  Delta r_t = #ar-one Delta r_(t-1) + u_t
$
であり、AR係数の標準誤差は #ar-one-se、$p$ 値は #ar-one-p であった。

ただし、残差診断はモデルの限界を示す。

#table(
  columns: (1.5fr, 1fr, 1fr),
  inset: 5pt,
  align: center + horizon,
  [検定], [統計量], [$p$ 値],
  [Ljung--Box（12次）], [#lb12-stat], [#lb12-p],
  [Ljung--Box（24次）], [#lb24-stat], [#lb24-p],
  [Jarque--Bera], [#jb-stat], [#jb-p],
)

12次、24次のLjung--Box検定はいずれも残差が白色雑音であるという帰無仮説を棄却し、Jarque--Bera検定も正規性を棄却する。ARIMA$(1,1,0)$は主要な1次相関を捉える簡潔なモデルではあるが、すべての動学や急変を説明する完全なモデルではない。

== 擬似予測の比較

#figure(
  image("assets/forecast_evaluation.svg", width: 98%),
  caption: [実質実効為替レートの1か月先擬似予測],
)

#table(
  columns: (1.7fr, 1fr, 1fr),
  inset: 5pt,
  align: center + horizon,
  [モデル], [RMSE], [MAE],
  [ランダムウォーク], [#rw-rmse], [#rw-mae],
  [ARIMA$(1,1,0)$], [#arima-rmse], [#arima-mae],
)

ARIMAのRMSEはランダムウォークより #rmse-improvement、MAEは #mae-improvement 小さかった。変化方向の正答率は #direction-accuracy、95%予測区間の被覆率は #forecast-coverage である。一方、対数二乗誤差の平均差の検定統計量は #loss-test-stat、$p$ 値は #loss-test-p であり、予測誤差が等しいという仮説は5%水準で棄却できなかった。AR(1)の正の持続性を用いることで標本上の予測誤差はわずかに縮小したが、改善は統計的に明確ではない。したがって、実質実効為替レートに短期的な系列相関はあるものの、単変量モデルだけで高い予測可能性が得られたとはいえない。

== 12か月先予測

#figure(
  image("assets/future_forecast.svg", width: 90%),
  caption: [ARIMA$(1,1,0)$による実質実効為替レートの将来予測],
)

#table(
  columns: (1.2fr, 1fr, 1.6fr),
  inset: 5pt,
  align: center + horizon,
  [予測時点], [点予測], [95%予測区間],
  [#forecast-1-date], [#forecast-1-point], [#forecast-1-lower -- #forecast-1-upper],
  [#forecast-3-date], [#forecast-3-point], [#forecast-3-lower -- #forecast-3-upper],
  [#forecast-6-date], [#forecast-6-point], [#forecast-6-lower -- #forecast-6-upper],
  [#forecast-12-date], [#forecast-12-point], [#forecast-12-lower -- #forecast-12-upper],
)

ARIMA$(1,1,0)$はドリフトを持たず、直近の変化の影響も $0.298^h$ で減衰するため、点予測は約66.1へ速やかに収束する。一方、12か月先の95%予測区間は #forecast-12-lower から #forecast-12-upper まで広がる。点予測よりも、この不確実性の大きさを重視すべきである。また、残差診断が不十分であるため、この区間はモデルの仮定の下での目安にとどまる。

= 考察

本稿の中心的な結果は、名目・実質実効為替レートが短期では強く連動する一方、長期では共和分していないことである。月次差分の傾きは全期間平均でほぼ1であるため、短期変動の大部分は共通の名目為替変動で説明できる。しかし、CUSUM検定はこの関係の構造不安定性も示した。さらに、実質化に用いる相対物価の小さな差が長期間累積し、実質指数は1990年代半ば以降低下している。法眼・來住（2024）は、この長期的な実質円安について相対生産性など複数の要因を検討している。本稿の単変量分析はその原因を識別するものではないが、少なくとも名目指数だけでは実質指数の長期水準を代替できないことを示している。

予測面では、差分の正の1次自己相関を利用するARIMAがランダムウォークをわずかに上回った。ただし、改善はRMSEで約2%にすぎず、残差にも系列相関と非正規性が残る。金利差、交易条件、政策変更、リスク回避などの外生情報を含めていないことも限界である。より高度なモデルを使う場合でも、時系列順序を守った外部標本評価によって改善を確認する必要がある。

さらに、1993年以前は異なるカバレッジの系列で遡及され、貿易ウェイト更新時には全期間が改訂される。したがって、1990年代前半の動きを純粋な経済的構造変化と断定できず、将来同じコードを再取得した場合に推定値が変わる可能性もある。再現性のため、本稿では原CSV、取得日、系列コードを保存した。

#pagebreak(weak: true)

= 結論

日本の名目・実質実効為替レートはともに $I(1)$ であり、月次変化は相関 #change-correlation、回帰傾き #change-beta と全期間平均でほぼ1対1に連動した。しかし、CUSUM検定は係数の安定性を棄却し、Engle--Granger検定でも共和分を確認できず、実質と名目の乖離は非定常であった。すなわち、短期的な共通変動が強くても、その関係や相対物価を含む長期関係が固定されているとは限らない。

実質指数のARIMA$(1,1,0)$は1か月先予測でランダムウォークを小幅に上回ったが、残差診断と広い長期予測区間を考えると、予測力は限定的である。現在の低い実質指数は標本内で重要な事実である一方、「2020年=100」という正規化や単純な時系列モデルだけから円の適正価値を結論づけることはできない。


= 参考文献

- 日本銀行「#link("https://www.stat-search.boj.or.jp/ssi/mtshtml/fm09_m_1.html")[実効為替レート（月次）]」日本銀行時系列統計データ検索サイト（2026年7月13日閲覧）。
- 日本銀行調査統計局「#link("https://www.boj.or.jp/statistics/outline/exp/exrate02.htm")[実効為替レート（名目・実質）の解説]」2026年4月。
- 日本銀行「#link("https://www.boj.or.jp/statistics/outline/notice_2026/not260427a.htm")[実効為替レートの遡及改定について]」2026年4月27日。
- Bank for International Settlements, “#link("https://data.bis.org/topics/EER")[Effective exchange rates],” BIS Data Portal（2026年7月13日閲覧）。
- 法眼吉彦・來住直哉「#link("https://www.boj.or.jp/research/wps_rev/wps_2024/wp24j24.htm")[わが国におけるバラッサ・サミュエルソン効果について]」日本銀行ワーキングペーパーシリーズ No.24-J-24、2024年。
