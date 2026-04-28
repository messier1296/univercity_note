// Common settings and helpers for math analysis lecture notes.
//
// Usage from each lecture file:
//
// #import "template.typ": setup, frame
// #show: setup
//
// = 数理解析第○回
//
// #frame(title: [定理 X.X])[
//   本文
// ]

#let setup(body) = {
  import "@preview/codly:1.3.0": *
  import "@preview/codly-languages:0.1.8": *

  set page(
    paper: "a4",
    margin: (x: 16mm, y: 18mm),
    numbering: "1",
    number-align: bottom + right,
  )
  set math.equation(numbering: "(1)")
  show: codly-init.with()

  show math.equation: it => {
    let num = it.at("numbering", default: none)

    if it.block and not it.has("label") and num != none {
      counter(math.equation).update(n => calc.max(n - 1, 0))
      math.equation(
        it.body,
        block: true,
        numbering: none,
      )
    } else {
      it
    }
  }
  set math.equation(numbering: "(1)")
  show ref: it => {
    if (
      it.element != none and it.element.func() == math.equation and it.element.numbering != none
    ) {
      // Override equation references.
      link(it.element.location(), numbering(
        it.element.numbering,
        ..counter(math.equation).at(it.element.location()),
      ))
    } else {
      // Other references as usual.
      it
    }
  }

  set text(
    font: ("Noto Serif CJK JP", "New Computer Modern Math"),
    size: 10.5pt,
    fill: rgb("#1d2433"),
  )

  show math.equation: set text(font: ("New Computer Modern Math", "Noto Serif CJK JP"))
  set par(justify: true, leading: 0.72em)
  set heading(numbering: "1.")

  body
}

#let frame(title: none, body, color: rgb("#239dad")) = block(
  fill: color.lighten(95%), // 背景は指定色の95%明度上げ（かなり薄く）
  stroke: (left: 2.5pt + color), // 左線は指定色
  inset: (x: 1.2em, y: 1em),
  width: 100%,
  radius: (right: 4pt),
  below: 1.5em,
  breakable: true,
  [
    // タイトルがある場合、アクセントカラーで表示
    #if title != none [
      #text(fill: color, weight: "bold")[#title]
      #v(0.5em)
    ]
    #body
  ],
)
