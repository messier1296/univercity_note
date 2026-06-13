#import "/template.typ": setup, frame
#show: setup

#let my-title = "M/M/1待ち行列のシミュレーション"
#let my-author = "今村隼人"
#let my-date = datetime(year: 2026, month: 6, day: 8)

#set document(
  title: my-title,
  author: my-author,
  date: my-date,
)

#align(center)[
  #text(size: 20pt, weight: "bold")[#my-title]
  #v(0.6em)
  #my-author
  #v(0.3em)
  #my-date.display("[year]-[month]-[day]")
]

= 目的

M/M/1待ち行列について，発生イベント数と初期に無視するイベント数を変えながらシミュレーションし，平均系内客数を理論値と比較する。サービス率は $mu = 5$ に固定し，到着率は $lambda = 3, 4, 4.5, 4.9, 4.95, 5.1$ とした。

= モデルと理論値

M/M/1モデルでは，到着間隔がパラメータ $lambda$ の指数分布，サービス時間がパラメータ $mu$ の指数分布に従う。時刻 $t$ の系内客数を $N(t)$ とすると，$lambda < mu$ のとき定常分布は

$
  P(N = n) = (1 - rho) rho^n, quad rho = lambda / mu
$

である。したがって平均系内客数の理論値は

$
  E[N] = rho / (1 - rho) = lambda / (mu - lambda)
$

となる。$lambda >= mu$ では安定条件を満たさないため，定常分布は存在せず，平均系内客数は長時間では発散すると考えられる。

= シミュレーション方法

第8回ノートブックのイベント駆動型シミュレーションを使い，系内客数が0のときは次の到着だけを発生させ，系内客数が1以上のときは到着またはサービス完了の早い方を次イベントとして発生させた。平均系内客数は，初期イベントを無視したあと，各状態で過ごした時間を重みとして

$
  overline(N) = (sum_i N_i Delta t_i) / (sum_i Delta t_i)
$

により計算した。乱数seedを固定して，再実行しても同じ結果になるようにした。

実験設定は次の6通りである。

#table(
  columns: (1fr, 1fr),
  inset: 5pt,
  stroke: 0.5pt,
  table.header([発生イベント数], [無視した最初のイベント数]),
  [110], [10],
  [1100], [100],
  [11000], [1000],
  [110000], [10000],
  [1100000], [100000],
  [11000000], [1000000],
)

= 平均系内客数

#text(size: 7.6pt)[
  #include "result_table.typ"
]

イベント数が少ない場合は，初期状態や偶然の偏りの影響が大きく，理論値から離れることがある。一方，イベント数を増やすと，安定条件を満たす $lambda < mu$ の範囲ではおおむね理論値へ近づいた。

= サンプルパス

以下は，各 $lambda$ について，最大イベント数 $11000000$，無視イベント数 $1000000$ の条件で，初期イベントを除いたあとの一部時間区間を描いたサンプルパスである。

#grid(
  columns: (1fr, 1fr),
  gutter: 10pt,
  figure(image("figures/sample_path_lambda_3p0.png", width: 100%), caption: [$lambda=3$]),
  figure(image("figures/sample_path_lambda_4p0.png", width: 100%), caption: [$lambda=4$]),
  figure(image("figures/sample_path_lambda_4p5.png", width: 100%), caption: [$lambda=4.5$]),
  figure(image("figures/sample_path_lambda_4p9.png", width: 100%), caption: [$lambda=4.9$]),
  figure(image("figures/sample_path_lambda_4p95.png", width: 100%), caption: [$lambda=4.95$]),
  figure(image("figures/sample_path_lambda_5p1.png", width: 100%), caption: [$lambda=5.1$]),
)

$lambda$ が大きくなるほど，サンプルパスの中心が上に移動し，大きな混雑状態が長く続きやすくなった。特に $lambda = 4.95$ は $mu=5$ に非常に近いため，安定条件は満たしているが，混雑が解消するまでの時間が長い。$lambda = 5.1$ は $lambda > mu$ であり，サンプルパスでも系内客数が減らずに増え続ける傾向が見える。

= 系内客数の分布

以下は，最大イベント数の条件で得た時間重み付きの系内客数分布である。$lambda < mu$ の場合は幾何分布の理論値も重ねて示した。

#grid(
  columns: (1fr, 1fr),
  gutter: 10pt,
  figure(image("figures/distribution_lambda_3p0.png", width: 100%), caption: [$lambda=3$]),
  figure(image("figures/distribution_lambda_4p0.png", width: 100%), caption: [$lambda=4$]),
  figure(image("figures/distribution_lambda_4p5.png", width: 100%), caption: [$lambda=4.5$]),
  figure(image("figures/distribution_lambda_4p9.png", width: 100%), caption: [$lambda=4.9$]),
  figure(image("figures/distribution_lambda_4p95.png", width: 100%), caption: [$lambda=4.95$]),
  figure(image("figures/distribution_lambda_5p1.png", width: 100%), caption: [$lambda=5.1$]),
)

$lambda=3$ や $lambda=4$ では，分布が比較的低い系内客数に集中しており，シミュレーション分布も理論分布に近い。$lambda=4.9$ や $lambda=4.95$ では分布の裾が長くなり，高い系内客数も無視できなくなる。このため，短いシミュレーションでは大きな混雑を十分に観測できず，平均値が理論値から外れやすい。

= 考察

平均系内客数の結果を見ると，安定条件を満たす $lambda < 5$ では，イベント数を増やすほどシミュレーション値が理論値に近づいた。例えば $lambda=3$ では最大設定で1.5019となり，理論値1.5とほぼ一致した。$lambda=4.5$ でも最大設定では8.9934であり，理論値9.0に近い。

一方，$lambda$ が $mu$ に近づくと収束は遅くなる。$lambda=4.9$ の理論値は49，$lambda=4.95$ の理論値は99であり，平均系内客数そのものが大きい。サンプルパスでも長い混雑期間と短い空き期間が交互に現れ，限られたイベント数では観測された混雑の長さに平均値が強く左右された。$lambda=4.95$ では11000000イベントでも105.5056となり，理論値に近いがまだ数単位の差が残った。

$lambda=5.1$ は $lambda > mu$ なので，平均到着率が平均サービス率を上回る。この場合，定常状態は存在しないため理論値は有限にならない。実際，イベント数を増やすと平均系内客数は2.0531から56658.0836まで増加し，システムが不安定であることが確認できた。

= 社会での応用例と感想

M/M/1モデルは，1台のATM，1人の窓口担当者，1つの受付カウンター，1本の通信回線など，単一のサーバにランダムに仕事や客が到着する場面の近似に使える。例えば，大学の窓口で証明書発行を受け付ける場合，到着率がサービス率に近づくと待ち人数が急増する。このモデルを使えば，担当者を増やすべき時間帯や，予約制により到着率を平準化する効果を考えられる。

今回の演習では，$lambda$ が $mu$ に近づくだけで平均系内客数が急激に増えることを，理論式だけでなくサンプルパスでも確認できた。短いシミュレーションでは理論値とかなりずれる場合があり，特に混雑しやすい条件ほど長い観測が必要になることも分かった。待ち行列は単純なモデルでも，現実の混雑対策を考えるうえでかなり直感的な道具になると感じた。

#pagebreak()

= ソースコード

以下のPythonコードで表と図を生成した。

#text(size: 6.8pt)[
  #raw(read("mm1_simulation.py"), lang: "python", block: true)
]
