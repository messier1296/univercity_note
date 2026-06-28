import fs from "node:fs/promises";
import { Presentation, PresentationFile } from "@oai/artifact-tool";

const FINAL_PPTX = process.argv[2];
const QA_DIR = process.argv[3];

if (!FINAL_PPTX || !QA_DIR) {
  console.error("Usage: node build_final_presentation.mjs <final.pptx> <qa-dir>");
  process.exit(1);
}

const W = 1280;
const H = 720;
const C = {
  ink: "#111827",
  muted: "#4B5563",
  quiet: "#8A94A6",
  panel: "#EEF0F2",
  panel2: "#F7F8FA",
  rule: "#C8CDD5",
  blue: "#276FBF",
  orange: "#D9472B",
  green: "#2F8F6F",
};

const industries = [
  { name: "建設業", rd: 5.28349, pat: 3.59273 },
  { name: "食品製造業", rd: 5.34553, pat: 3.28870 },
  { name: "繊維・パルプ・紙", rd: 4.85424, pat: 3.39637 },
  { name: "医薬品製造業", rd: 6.07685, pat: 2.84323 },
  { name: "化学工業", rd: 6.04947, pat: 4.22523 },
  { name: "石油石炭・プラ等", rd: 5.48179, pat: 3.89020 },
  { name: "鉄鋼・非鉄金属", rd: 5.63411, pat: 3.78930 },
  { name: "金属製品製造業", rd: 5.11289, pat: 3.39322 },
  { name: "機械製造業", rd: 6.00477, pat: 3.95342 },
  { name: "電気機械製造業", rd: 6.30659, pat: 4.61867 },
  { name: "輸送機械製造業", rd: 6.52826, pat: 4.30468 },
  { name: "業務用機械器具", rd: 5.72976, pat: 4.08368 },
  { name: "その他の製造業", rd: 5.42509, pat: 4.16435 },
  { name: "情報通信業", rd: 5.54949, pat: 3.48073 },
  { name: "卸売・小売等", rd: 4.32465, pat: 2.79029 },
  { name: "その他の非製造業", rd: 5.13774, pat: 4.37796 },
  { name: "教育・TLO・公的研究機関", rd: 6.53062, pat: 3.92947 },
];

const regressionX = [4.32, 6.54];
const regressionY = regressionX.map((x) => 1.1425771947026173 + 0.46865802509811727 * x);

function textBox(slide, text, x, y, w, h, style = {}) {
  const shape = slide.shapes.add({
    geometry: "textbox",
    position: { left: x, top: y, width: w, height: h },
    fill: "none",
    line: { style: "solid", fill: "none", width: 0 },
  });
  shape.text = text;
  shape.text.style = {
    fontSize: style.fontSize ?? 20,
    bold: style.bold ?? false,
    color: style.color ?? C.ink,
    alignment: style.alignment ?? "left",
  };
  return shape;
}

function panel(slide, x, y, w, h, fill = C.panel, lineFill = "none") {
  return slide.shapes.add({
    geometry: "rect",
    position: { left: x, top: y, width: w, height: h },
    fill,
    line: { style: "solid", fill: lineFill, width: lineFill === "none" ? 0 : 1.2 },
  });
}

function footer(slide, n) {
  textBox(slide, "戦略行動システム演習 最終レポート", 42, 660, 430, 28, {
    fontSize: 15,
    color: C.quiet,
  });
  textBox(slide, String(n), 1176, 660, 62, 28, {
    fontSize: 15,
    color: C.quiet,
    alignment: "right",
  });
}

function setNotes(slide, notes) {
  slide.speakerNotes.textFrame.setText(notes);
  slide.speakerNotes.setVisible(true);
}

function addTitle(slide, title, subtitle, n) {
  textBox(slide, title, 42, 38, 860, 56, { fontSize: 40, bold: true });
  if (subtitle) {
    textBox(slide, subtitle, 42, 104, 940, 42, { fontSize: 20, color: C.muted });
  }
  footer(slide, n);
}

function addBullet(slide, text, x, y, w, h, accent = C.ink) {
  panel(slide, x, y + 8, 9, 9, accent, accent);
  textBox(slide, text, x + 24, y, w - 24, h, { fontSize: 22, color: C.ink });
}

function metricCard(slide, x, y, w, h, label, value, note, color = C.panel) {
  panel(slide, x, y, w, h, color, C.rule);
  const compact = h < 220;
  textBox(slide, label, x + 26, y + (compact ? 22 : 28), w - 52, compact ? 34 : 48, {
    fontSize: compact ? 23 : 24,
    bold: true,
  });
  textBox(slide, value, x + 26, y + (compact ? 68 : 120), w - 52, compact ? 56 : 94, {
    fontSize: compact ? 42 : 60,
    bold: true,
  });
  textBox(slide, note, x + 26, y + (compact ? 126 : 244), w - 52, compact ? h - 134 : 86, {
    fontSize: compact ? 17 : 19,
    color: C.muted,
  });
}

async function writeBlob(path, blob) {
  await fs.writeFile(path, new Uint8Array(await blob.arrayBuffer()));
}

async function main() {
  await fs.mkdir(QA_DIR, { recursive: true });
  await fs.writeFile(
    `${QA_DIR}/source-notes.txt`,
    [
      "Deck based on report.typ and the JPO/e-Stat FY2025 intellectual property activity survey data.",
      "Academic background used: Griliches (1990), Hall et al. (1986), Cohen et al. (2000), Arundel and Kabla (1998).",
      "Charts and tables are rebuilt as editable PowerPoint objects where practical.",
    ].join("\n"),
  );

  const deck = Presentation.create({ slideSize: { width: W, height: H } });

  // Slide 1: cover
  {
    const slide = deck.slides.add();
    slide.background.fill = "#FFFFFF";
    textBox(slide, "Final report", 42, 42, 300, 40, { fontSize: 24, color: C.muted });
    textBox(slide, "202410178　今村隼人", 860, 42, 378, 40, {
      fontSize: 22,
      color: C.muted,
      alignment: "right",
    });
    textBox(slide, "産業別にみた\n研究開発費と\n特許出願数の関係", 42, 205, 900, 250, {
      fontSize: 58,
      bold: true,
    });
    textBox(slide, "研究開発投資は特許出願数をどの程度説明するか", 42, 520, 760, 46, {
      fontSize: 26,
      color: C.muted,
    });
    panel(slide, 990, 222, 154, 154, C.panel, "none");
    textBox(slide, "R&D", 1014, 264, 110, 42, { fontSize: 30, bold: true, alignment: "center" });
    textBox(slide, "→", 1035, 340, 70, 46, { fontSize: 42, color: C.orange, alignment: "center" });
    panel(slide, 990, 412, 154, 154, C.panel, "none");
    textBox(slide, "Patent", 1005, 454, 124, 42, { fontSize: 28, bold: true, alignment: "center" });
    footer(slide, 1);
    setNotes(slide, [
      "これから、産業別にみた研究開発費と特許出願数の関係について発表します。",
      "テーマは、研究開発投資は特許出願数をどの程度説明するか、です。",
      "分析では、特許庁の知的財産活動調査を使い、産業別の研究費と国内特許出願件数を比較しました。",
    ]);
  }

  // Slide 2: research question and prior work
  {
    const slide = deck.slides.add();
    slide.background.fill = "#FFFFFF";
    addTitle(slide, "研究の問い", "研究費が多い産業ほど、特許出願も多いのか", 2);
    metricCard(slide, 42, 210, 366, 310, "先行研究", "正の関係", "研究開発活動と特許には関係があるとされる", C.panel);
    metricCard(slide, 457, 210, 366, 310, "ただし", "産業差", "すべての発明が特許化されるわけではない", C.panel);
    metricCard(slide, 872, 210, 366, 310, "本分析", "説明力", "研究費だけでどこまで説明できるかを確認", C.panel);
    setNotes(slide, [
      "先行研究では、研究開発と特許には正の関係があるとされています。",
      "ただし、特許出願数は研究開発成果を完全に表すものではありません。",
      "産業によって、特許を重視する程度や、成果が特許になるまでの時間差が違います。",
      "そこで本分析では、日本の産業別データを使って、研究費だけで特許出願数をどこまで説明できるかを調べました。",
    ]);
  }

  // Slide 3: data and method
  {
    const slide = deck.slides.add();
    slide.background.fill = "#FFFFFF";
    addTitle(slide, "データと方法", "特許庁の同一調査から、研究費と国内特許出願件数を接続", 3);
    panel(slide, 42, 190, 560, 280, C.panel2, C.rule);
    textBox(slide, "データ", 72, 220, 500, 40, { fontSize: 28, bold: true });
    addBullet(slide, "令和7年度 知的財産活動調査", 72, 288, 480, 42, C.blue);
    addBullet(slide, "研究費：第1-1表「研究費」", 72, 346, 480, 42, C.blue);
    addBullet(slide, "特許：第1-8表「国内出願件数 2024年実績」", 72, 404, 480, 42, C.blue);
    panel(slide, 664, 190, 574, 280, C.panel2, C.rule);
    textBox(slide, "分析", 694, 220, 500, 40, { fontSize: 28, bold: true });
    addBullet(slide, "分析対象：17産業", 694, 288, 490, 42, C.green);
    addBullet(slide, "主要分析：対数変換後の単回帰", 694, 346, 490, 42, C.green);
    addBullet(slide, "目的変数：国内特許出願件数", 694, 404, 490, 42, C.green);
    textBox(slide, "log10(特許出願件数) = β0 + β1 log10(研究費) + ε", 122, 535, 1036, 52, {
      fontSize: 30,
      bold: true,
      alignment: "center",
    });
    setNotes(slide, [
      "データは、特許庁の令和7年度知的財産活動調査です。",
      "研究費と国内特許出願件数を、同じ業種分類で取れる点がこのデータの利点です。",
      "全体と、研究費が欠損していた個人・その他を除き、17産業を分析対象にしました。",
      "産業間では規模差が大きいため、主要分析では研究費と特許出願件数を常用対数に変換して単回帰分析を行いました。",
    ]);
  }

  // Slide 4: main regression result
  {
    const slide = deck.slides.add();
    slide.background.fill = "#FFFFFF";
    addTitle(slide, "研究費は特許出願数を有意に説明した", "ただし、説明できたのは全体の約29%にとどまる", 4);
    slide.charts.add("scatter", {
      position: { left: 56, top: 178, width: 750, height: 405 },
      categories: [],
      series: [
        {
          name: "産業",
          xValues: industries.map((d) => d.rd),
          values: industries.map((d) => d.pat),
          marker: { symbol: "circle", size: 7 },
          line: { style: "solid", fill: "none", width: 0 },
          fill: C.blue,
        },
        {
          name: "回帰直線",
          xValues: regressionX,
          values: regressionY,
          marker: { symbol: "none", size: 0 },
          line: { style: "solid", fill: C.orange, width: 3 },
        },
      ],
      hasLegend: false,
      scatterOptions: { style: "marker" },
      xAxis: {
        title: { text: "log10(研究費)", textStyle: { fontSize: 14, fill: C.muted } },
        min: 4.2,
        max: 6.75,
        majorGridlines: { style: "solid", fill: "#E2E6EC", width: 1 },
        textStyle: { fontSize: 12, fill: C.muted },
      },
      yAxis: {
        title: { text: "log10(国内特許出願件数)", textStyle: { fontSize: 14, fill: C.muted } },
        min: 2.7,
        max: 4.75,
        majorGridlines: { style: "solid", fill: "#E2E6EC", width: 1 },
        textStyle: { fontSize: 12, fill: C.muted },
      },
    });
    slide.shapes.add({
      geometry: "custom",
      position: { left: 148, top: 278, width: 588, height: 178 },
      fill: "none",
      line: { style: "solid", fill: C.orange, width: 3 },
      customPaths: [
        {
          width: 588,
          height: 178,
          commands: [{ moveTo: { x: 0, y: 178 } }, { lineTo: { x: 588, y: 0 } }],
        },
      ],
    });
    metricCard(slide, 860, 178, 178, 150, "決定係数", ".286", "約29%を説明", C.panel);
    metricCard(slide, 1060, 178, 178, 150, "p値", ".027", "5%水準で有意", C.panel);
    metricCard(slide, 860, 360, 378, 160, "解釈", "10倍 → 2.94倍", "研究費が10倍でも、出願件数は比例的には増えない", C.panel2);
    textBox(slide, "出典：特許庁「令和7年度知的財産活動調査」、e-Stat 業種別出願件数階級別集計表", 56, 600, 900, 28, {
      fontSize: 14,
      color: C.quiet,
    });
    setNotes(slide, [
      "結果です。対数変換後の単回帰では、決定係数は .286、p値は .027 でした。",
      "したがって、研究費は国内特許出願件数を有意に説明していました。",
      "ただし、説明できたのは約29%です。残りの約71%は研究費以外の要因によると考えられます。",
      "また、回帰係数から見ると、研究費が10倍の産業でも、特許出願件数は平均して約2.94倍です。つまり比例的に増えるわけではありません。",
    ]);
  }

  // Slide 5: industry differences
  {
    const slide = deck.slides.add();
    slide.background.fill = "#FFFFFF";
    addTitle(slide, "産業差が大きい", "研究費が同じでも、特許出願として表れやすい産業と表れにくい産業がある", 5);
    slide.charts.add("bar", {
      position: { left: 58, top: 188, width: 610, height: 390 },
      categories: [
        "その他の非製造業",
        "その他の製造業",
        "繊維・パルプ・紙",
        "電気機械",
        "化学工業",
        "輸送機械",
        "教育・TLO等",
        "医薬品",
      ],
      series: [
        {
          name: "研究費1億円あたり出願件数",
          values: [17.39, 5.49, 3.48, 2.05, 1.50, 0.60, 0.25, 0.06],
          fill: C.green,
        },
      ],
      barOptions: { direction: "bar", grouping: "clustered", gapWidth: 35 },
      hasLegend: false,
      xAxis: {
        title: { text: "研究費1億円あたりの国内特許出願件数", textStyle: { fontSize: 13, fill: C.muted } },
        majorGridlines: { style: "solid", fill: "#E2E6EC", width: 1 },
        textStyle: { fontSize: 11, fill: C.muted },
      },
      yAxis: { textStyle: { fontSize: 12, fill: C.ink } },
      dataLabels: { showValue: true, position: "outEnd", textStyle: { fontSize: 12, fill: C.ink } },
    });
    panel(slide, 720, 190, 220, 130, C.panel2, C.rule);
    textBox(slide, "予測より多い", 746, 214, 180, 28, { fontSize: 24, bold: true });
    textBox(slide, "その他の非製造業\n電気機械製造業\nその他の製造業", 746, 260, 170, 76, {
      fontSize: 18,
      color: C.muted,
    });
    panel(slide, 982, 190, 220, 130, C.panel2, C.rule);
    textBox(slide, "予測より少ない", 1008, 214, 180, 28, { fontSize: 24, bold: true });
    textBox(slide, "医薬品製造業\n卸売・小売等\n食品製造業", 1008, 260, 170, 76, {
      fontSize: 18,
      color: C.muted,
    });
    addBullet(slide, "医薬品は少数の重要特許や長い開発期間が影響する可能性", 720, 386, 475, 56, C.orange);
    addBullet(slide, "電気機械などは多数の技術要素を継続的に特許化しやすい", 720, 468, 475, 56, C.blue);
    setNotes(slide, [
      "次に産業差です。研究費1億円あたりの出願件数を見ると、その他の非製造業が非常に高く、医薬品や教育・TLO等は低くなりました。",
      "回帰モデルの予測値から見ても、電気機械製造業やその他の製造業は予測より出願件数が多く、医薬品製造業は大幅に少ない結果でした。",
      "これは、産業によって特許出願の戦略や、研究開発成果が特許になるまでの時間が違うためだと考えられます。",
    ]);
  }

  // Slide 6: conclusion
  {
    const slide = deck.slides.add();
    slide.background.fill = "#FFFFFF";
    addTitle(slide, "まとめ", "研究開発費は効く。しかし、それだけでは足りない。", 6);
    metricCard(slide, 42, 214, 375, 340, "結論 1", "有意", "研究開発費は国内特許出願件数を有意に説明した", C.panel);
    metricCard(slide, 452, 214, 375, 340, "結論 2", "29%", "説明力は限定的で、産業差が大きい", C.panel);
    metricCard(slide, 863, 214, 375, 340, "結論 3", "戦略", "特許出願数は産業ごとの知財戦略にも左右される", C.panel);
    textBox(slide, "今後の課題：企業単位・複数年データ、時間差、特許の質を加えた分析", 100, 600, 1080, 42, {
      fontSize: 24,
      color: C.muted,
      alignment: "center",
    });
    setNotes(slide, [
      "まとめです。第一に、研究開発費は国内特許出願件数を有意に説明しました。",
      "第二に、決定係数は約29%であり、研究費だけで十分に説明できるわけではありません。",
      "第三に、特許出願数を理解するには、産業ごとの技術特性や知的財産戦略を合わせて見る必要があります。",
      "今後は、企業単位のデータや複数年データを使い、研究開発から特許出願までの時間差や、特許の質も考慮した分析が必要です。",
    ]);
  }

  for (const [index, slide] of deck.slides.items.entries()) {
    const stem = `slide-${String(index + 1).padStart(2, "0")}`;
    await writeBlob(`${QA_DIR}/${stem}.png`, await deck.export({ slide, format: "png", scale: 1 }));
    await fs.writeFile(`${QA_DIR}/${stem}.layout.json`, await (await slide.export({ format: "layout" })).text());
  }

  await writeBlob(`${QA_DIR}/deck-montage.webp`, await deck.export({ format: "webp", montage: true, scale: 1 }));
  const inspect = await deck.inspect({
    kind: "slide,textbox,shape,chart,table,notes,layout",
    maxChars: 24000,
  });
  await fs.writeFile(`${QA_DIR}/inspect.ndjson`, inspect.ndjson);

  const pptx = await PresentationFile.exportPptx(deck);
  await pptx.save(FINAL_PPTX);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
