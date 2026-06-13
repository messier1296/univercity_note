#import "/template.typ": setup
#show: setup

#let title = "数理工学モデル化演習 第9回レポート"
#let author = "今村隼人"
#let date = datetime(year: 2026, month: 6, day: 13)

#set document(title: title, author: author, date: date)

#align(center)[
  #text(size: 18pt, weight: "bold")[#title]
  #v(0.6em)
  #author
  #v(0.3em)
  #date.display("[year]-[month]-[day]")
]

= 設定

課題1と課題2では、ページ24と同じく $mu = 1$, $E = lambda / mu = lambda$, $c = 10$ とした。
課題3では $lambda = 8$, $mu = 1$ とし、$c = 10, 15, 20$ の分布を比較した。

= 結果

#figure(
  image("fig_waiting_probability.png", width: 92%),
  caption: [課題1：$c = 10$ の待つ確率],
)

#figure(
  image("fig_blocking_probability.png", width: 92%),
  caption: [課題2：$c = 10$ のブロッキング確率],
)

#figure(
  image("fig_distribution_comparison.png", width: 100%),
  caption: [課題3：$c$ を大きくしたときの系内客数分布],
)

= 考察

課題1の待つ確率は、$E$ が小さい範囲ではほぼ0だが、$E$ がサーバ数 $c = 10$ に近づくと急に1へ近づいた。
シミュレーション点はErlang Cの理論曲線とほぼ一致し、イベントシミュレーションで待ち確率を再現できている。
課題2のブロッキング確率も $E$ とともに増加するが、同じ $E$ では待つ確率よりかなり小さい。
これはM/M/c/cモデルでは満員時の到着客を棄却するため、待ち行列を作るM/M/cモデルより系内客数が増えにくいからである。
課題3では $c$ を大きくするとM/M/cとM/M/c/cの分布はいずれもPoisson(8)に近づき、十分にサーバ数が多いと容量制限や待ち行列の影響が小さくなることが分かる。

= ソースコード

#raw(read("simulation_09.py"), lang: "python")
