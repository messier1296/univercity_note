# 日本銀行「実効為替レート」

日本銀行時系列統計データ検索サイトのAPIから、2026年7月13日に取得した。

## 収録系列

- `FX180110001`: 名目実効為替レート（月次、2020年平均=100）
- `FX180110002`: 実質実効為替レート（月次、2020年平均=100）
- 期間: 1970年1月から2026年5月
- 各系列677観測、欠測なし

原データは `raw/boj_effective_exchange_rates.csv` に未加工で保存している。分析コードが生成する `boj_effective_exchange_rates.csv` は、2系列を日付ごとに横持ちへ変換した加工データである。

## 出典

- データ表: https://www.stat-search.boj.or.jp/ssi/mtshtml/fm09_m_1.html
- 統計の解説: https://www.boj.or.jp/statistics/outline/exp/exrate02.htm
- API: https://www.stat-search.boj.or.jp/api/v1/getDataCode?format=csv&lang=en&db=FM09&code=FX180110001,FX180110002&startDate=197001&endDate=202605
- 利用上の注意: https://www.stat-search.boj.or.jp/info/notice.html

出所: 日本銀行「実効為替レート」および日本銀行時系列統計データ検索サイト。対数変換、差分、推定および図表作成は筆者による。

## 利用上の注意

現行値はBISのBroad系列に基づくが、1993年以前はNarrow系列の前月比で遡及推計されている。また、貿易ウェイトの更新などにより過去値が改訂される場合がある。そのため、分析では系列コードと取得日を固定している。
