
// category_theory_intro_slides.typ
// Compile: typst compile category_theory_intro_slides.typ category_theory_intro_slides.pdf
// A self-contained 16:9 slide deck introducing category theory in Japanese.

#set page(width: 16cm, height: 9cm, margin: 0cm)
#set text(font: ("Noto Sans CJK JP", "Noto Sans JP", "Hiragino Sans", "Yu Gothic", "Arial"), lang: "ja", size: 17pt)
#set par(justify: false, leading: 0.72em)

#let bg = rgb("#f7f3e8")
#let paper = rgb("#fffdf7")
#let ink = rgb("#1f2933")
#let muted = rgb("#5b6472")
#let accent = rgb("#4f46e5")
#let accent2 = rgb("#0f766e")
#let warm = rgb("#f59e0b")
#let linec = rgb("#ded8c8")

#let footer-text = "圏論入門"

#let pill(t, fill: rgb("#ede9fe"), fg: accent) = rect(
  fill: fill,
  stroke: none,
  radius: 99pt,
  inset: (x: 10pt, y: 4pt),
)[#text(size: 11pt, weight: "bold", fill: fg)[#t]]

#let card(title, body, fill: paper) = rect(
  width: 100%,
  fill: fill,
  stroke: 0.8pt + linec,
  radius: 14pt,
  inset: 14pt,
)[
  #text(size: 15pt, weight: "bold", fill: accent)[#title]
  #v(5pt)
  #text(size: 13.5pt, fill: ink)[#body]
]

#let small-card(title, body) = rect(
  width: 100%,
  fill: paper,
  stroke: 0.7pt + linec,
  radius: 12pt,
  inset: 10pt,
)[
  #text(size: 12pt, weight: "bold", fill: accent2)[#title]
  #v(3pt)
  #text(size: 11.5pt, fill: ink)[#body]
]

#let slide(title: none, kicker: none, body) = {
  rect(width: 100%, height: 100%, fill: bg, stroke: none, inset: 0pt)[
    #pad(left: 0.8cm, right: 0.8cm, top: 0.55cm, bottom: 0.42cm)[
      #if kicker != none { pill(kicker) }
      #if title != none [
        #if kicker != none { v(0.16cm) }
        #text(size: 26pt, weight: "bold", fill: ink)[#title]
        #v(0.18cm)
        #line(length: 100%, stroke: 1pt + linec)
        #v(0.25cm)
      ]
      #body
      #place(bottom + right, dx: 0pt, dy: 0pt)[#text(size: 8pt, fill: muted)[#footer-text]]
    ]
  ]
  pagebreak()
}

#let big-equation(t) = align(center)[
  #rect(fill: paper, stroke: 1pt + linec, radius: 16pt, inset: 18pt)[
    #text(size: 24pt, weight: "bold", fill: accent)[#t]
  ]
]

#slide(kicker: "Category Theory", [
  #align(center + horizon)[
    #text(size: 40pt, weight: "bold", fill: ink)[圏論]
    #v(0.15cm)
    #text(size: 20pt, fill: muted)[構造と変換を同じ言葉で見る]
    #v(0.6cm)
    #grid(
      columns: (1fr, 1fr, 1fr),
      gutter: 0.35cm,
      small-card("対象", [もの]), small-card("射", [ものの間の関係・変換]), small-card("合成", [変換をつなぐルール]),
    )
    #v(0.5cm)
    #text(size: 12pt, fill: muted)[集合、順序、空間、プログラムを「同じ形」で比較するための道具]
  ]
])

#slide(title: "圏論の一言要約", kicker: "Big picture", [
  #grid(
    columns: (1.05fr, 0.95fr),
    gutter: 0.6cm,
    [
      #text(size: 19pt, weight: "bold", fill: accent)[「もの」よりも「ものの間の矢印」に注目する]
      #v(0.35cm)
      - 対象そのものの中身を細かく見る前に、対象同士がどうつながるかを見る。
      - 変換を合成できるなら、多くの数学的構造を同じ語彙で扱える。
      - 重要なのは、個別の中身ではなく、保たれる関係と構造。
    ],
    [
      #card("見方の切り替え", [
        通常: $A$ の中身を調べる

        圏論: $A → B$ という変換を調べる

        さらに: 変換の変換も調べる
      ])
    ],
  )
])

#slide(title: "圏の定義", kicker: "Definition", [
  #grid(
    columns: (1fr, 1fr),
    gutter: 0.45cm,
    card("1. 対象", [
      集合、位相空間、型、命題など。

      記号では $A, B, C$ と書く。
    ]),
    card("2. 射", [
      対象から対象への矢印。

      $f: A → B$ は「$A$ から $B$ への変換」。
    ]),

    card("3. 合成", [
      $f: A → B$ と $g: B → C$ から
      $g ∘ f: A → C$ を作る。
    ]),
    card("4. 恒等射", [
      各対象 $A$ には $id_A: A → A$ がある。

      何もしない変換。
    ]),
  )
])

#slide(title: "圏の公理は2つだけ", kicker: "Laws", [
  #big-equation([$h ∘ (g ∘ f) = (h ∘ g) ∘ f$])
  #v(0.35cm)
  #grid(
    columns: (1fr, 1fr),
    gutter: 0.55cm,
    card("結合律", [
      矢印をどの順番で括って合成しても同じ。

      つまり「つなぎ方」が安定している。
    ]),
    card("単位律", [
      $id_B ∘ f = f$、$f ∘ id_A = f$。

      何もしない矢印は合成を変えない。
    ]),
  )
  #v(0.35cm)
  #align(center)[#text(size: 14pt, fill: muted)[圏論は、複雑な構造を「合成できる矢印の体系」として抽象化する。]]
])

#slide(title: "代表的な例", kicker: "Examples", [
  #grid(
    columns: (1fr, 1fr, 1fr),
    gutter: 0.35cm,
    small-card("Set", [対象: 集合\
      射: 関数\
      合成: 関数合成]),
    small-card("Poset", [対象: 要素\
      射: $a ≤ b$ の証拠\
      合成: 推移律]),
    small-card("Top", [対象: 位相空間\
      射: 連続写像\
      合成: 連続写像の合成]),

    small-card("Vect", [対象: ベクトル空間\
      射: 線形写像\
      合成: 線形写像の合成]),
    small-card("Type", [対象: 型\
      射: 関数\
      合成: プログラムの接続]),
    small-card("Graph", [対象: ノード集合など\
      射: 構造を保つ写像\
      合成: 写像の合成]),
  )
  #v(0.35cm)
  #align(center)[#text(size: 13pt, fill: muted)[違う分野に見えても、「対象・射・合成」が揃うと同じ言語で話せる。]]
])

#slide(title: "関手: 圏から圏への写像", kicker: "Functor", [
  #grid(
    columns: (0.92fr, 1.08fr),
    gutter: 0.55cm,
    [
      #card("関手 F", [
        圏 $C$ の対象と射を、圏 $D$ の対象と射へ移す。

        ただし、構造を壊してはいけない。
      ])
      #v(0.25cm)
      #card("保存するもの", [
        $F(id_A) = id_{F(A)}$

        $F(g ∘ f) = F(g) ∘ F(f)$
      ])
    ],
    [
      #rect(fill: paper, stroke: 1pt + linec, radius: 16pt, inset: 16pt)[
        #text(size: 14pt, weight: "bold", fill: accent)[イメージ]
        #v(0.15cm)
        ```text
        C                         D
        A ──f──▶ B          F(A) ──F(f)──▶ F(B)
        │        │     F      │             │
        g        h    ───▶    F(g)          F(h)
        ▼        ▼            ▼             ▼
        C ──k──▶ E          F(C) ──F(k)──▶ F(E)
        ```
      ]
    ],
  )
])

#slide(title: "自然変換: 関手どうしの変換", kicker: "Natural transformation", [
  #grid(
    columns: (1fr, 1fr),
    gutter: 0.55cm,
    [
      #text(size: 16pt, weight: "bold", fill: accent)[関手もまた「対象」のように扱える]
      #v(0.25cm)
      圏 $C$ から圏 $D$ への関手 $F, G$ があるとき、自然変換 $η: F ⇒ G$ は各対象 $A$ に射 $η_A: F(A) → G(A)$ を対応させる。
      #v(0.25cm)
      さらに、$C$ の射 $f: A → B$ と整合的でなければならない。
    ],
    [
      #rect(fill: paper, stroke: 1pt + linec, radius: 16pt, inset: 16pt)[
        #text(size: 14pt, weight: "bold", fill: accent)[可換な四角形]
        #v(0.15cm)
        ```text
        F(A) ──F(f)──▶ F(B)
          │             │
         η_A           η_B
          ▼             ▼
        G(A) ──G(f)──▶ G(B)
        ```
        #v(0.15cm)
        #align(center)[#text(size: 15pt, weight: "bold", fill: accent2)[$G(f) ∘ η_A = η_B ∘ F(f)$]]
      ]
    ],
  )
])

#slide(title: "普遍性: 一番よいものを矢印で特徴づける", kicker: "Universal property", [
  #grid(
    columns: (1fr, 1fr),
    gutter: 0.55cm,
    [
      #card("発想", [
        「最小」「最大」「自由」「積」などを、要素ではなく射の一意性で定義する。

        そのため、異なる分野でも同じ定義が使える。
      ])
      #v(0.25cm)
      #card("例: 積", [
        $A × B$ は、$A$ と $B$ へ射を持つ対象の中で、任意の $X$ から一意に射が入るもの。
      ])
    ],
    [
      #rect(fill: paper, stroke: 1pt + linec, radius: 16pt, inset: 16pt)[
        #text(size: 14pt, weight: "bold", fill: accent)[積の普遍性]
        #v(0.15cm)
        ```text
             X
            / \
          f/   \g
          /     \
         ▼       ▼
         A ◀── A×B ──▶ B
              π1   π2
        ```
        #v(0.15cm)
        #text(size: 12pt, fill: muted)[任意の $f, g$ に対して、$X → A×B$ が一意に存在する。]
      ]
    ],
  )
])

#slide(title: "なぜ役に立つのか", kicker: "Why it matters", [
  #grid(
    columns: (1fr, 1fr),
    gutter: 0.55cm,
    [
      #card("統一", [
        集合、順序、空間、型などを同じ言葉で扱える。
      ])
      #v(0.25cm)
      #card("移植", [
        ある分野で見つけた構造を、別の分野へ関手で運べる。
      ])
      #v(0.25cm)
      #card("抽象化", [
        何が本質で、何が表現依存なのかを切り分けられる。
      ])
    ],
    [
      #card("計算機科学との接点", [
        - 型と関数
        - モナドによる効果の扱い
        - データ変換の合成
        - DSLや意味論
      ])
      #v(0.25cm)
      #card("学び方のコツ", [
        定義を暗記するより、まずは「矢印を合成できる世界」を例で増やす。
      ])
    ],
  )
])

#slide(title: "まとめ", kicker: "Takeaway", [
  #align(center)[
    #text(size: 24pt, weight: "bold", fill: ink)[圏論は、構造を「矢印」と「合成」で語る言語]
  ]
  #v(0.45cm)
  #grid(
    columns: (1fr, 1fr, 1fr),
    gutter: 0.35cm,
    card("圏", [対象・射・合成・恒等射]),
    card("関手", [圏の構造を保つ写像]),
    card("自然変換", [関手どうしの整合的な変換]),
  )
  #v(0.45cm)
  #rect(width: 100%, fill: rgb("#eef2ff"), stroke: 1pt + rgb("#c7d2fe"), radius: 16pt, inset: 16pt)[
    #text(size: 17pt, weight: "bold", fill: accent)[今日のゴール]
    #v(0.1cm)
    #text(
      size: 15pt,
      fill: ink,
    )[個々の中身ではなく「つながり方」を見ると、異なる数学やプログラムの世界が同じ形で見えてくる。]
  ]
])
