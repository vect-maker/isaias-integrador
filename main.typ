#import "metadata.typ": (
  title,
  title-short,
  authors,
  educators,
  date,
  location,
  institutional-motto,
  university,
  campus,
  area,
  department,
  career,
  academic-year,
  course,
)

#set document(
  title: title,
  author: authors.map(a => a.formal-name),
  date: date,
)

#set page(
  paper: "us-letter",
  margin: (top: 2.54cm, bottom: 2.54cm, left: 2.54cm, right: 2.54cm),
  footer: context {
    let i = counter(page).get().first()
    if i > 1 {
      align(right, text(size: 11pt)[#(i - 1)])
    }
  }
)

#set text(
  font: "Liberation Serif",
  size: 12pt,
  lang: "es"
)

#show link: it => text(fill: rgb("1b58a6"), underline(it))

#set par(
  justify: true,
  leading: 0.65em,
  spacing: 1.05em
)

#set figure(gap: 0.8em)
#set figure.caption(separator: [. ])

#set list(spacing: 0.75em)
#set enum(spacing: 0.75em)

#show heading.where(level: 1): it => block(
  width: 100%,
  above: 1.6em,
  below: 1.0em,
  align(center, text(weight: "bold", size: 16pt)[#it.body])
)

#show heading.where(level: 2): it => block(
  above: 1.3em,
  below: 0.7em,
  text(weight: "bold", size: 13pt)[#it.body]
)

#show heading.where(level: 3): it => block(
  above: 1.1em,
  below: 0.5em,
  text(weight: "bold", size: 12pt)[#it.body]
)

#show heading.where(level: 4): it => block(
  above: 0.9em,
  below: 0.4em,
  text(weight: "bold", size: 11.5pt)[#it.body]
)

// ==========================================
// PORTADA / COVER PAGE
// ==========================================
#align(center)[
  #text(size: 11pt, style: "italic")[
    #institutional-motto
  ]

  #v(0.4cm)
  #image("images/image1.png", width: 4.6cm)

  #v(0.3cm)
  #text(weight: "bold", size: 12pt)[
    #university \
    #campus \
    #area \
    #department \
    #career \
    #academic-year \
  ]

  #v(0.4cm)
  #rect(
    stroke: 0.5pt + luma(120),
    radius: 3pt,
    fill: rgb("f7f9fa"),
    inset: 10pt,
    width: 95%,
    [
      #text(weight: "bold", size: 12.5pt)[
        #title
      ]
    ]
  )

  #v(0.3cm)
  #text(weight: "bold", size: 12pt)[
    #course
  ]

  #v(0.5cm)
  #grid(
    columns: (1fr, 1fr),
    gutter: 1.5cm,
    align: (left, left),
    [
      #text(weight: "bold", size: 11pt)[Educadores:] \
      #v(0.15cm)
      #for edu in educators [
        #edu \
      ]
    ],
    [
      #text(weight: "bold", size: 11pt)[Estudiantes:] \
      #v(0.15cm)
      #for auth in authors [
        #auth.formal-name \
      ]
    ]
  )

  #v(0.8cm)
  #text(size: 11pt)[
    #location
  ]
]

#pagebreak()

// ==========================================
// ÍNDICE GENERAL
// ==========================================
#{
  show outline.entry: it => {
    set text(size: 10pt)
    it
  }
  set par(leading: 0.5em)
  outline(
    title: [Índice General],
    depth: 3,
    indent: 1.2em,
  )
}

#pagebreak()

// ==========================================
// CONTENIDO MODULAR
// ==========================================

#include "content/01_introduccion.typ"

#pagebreak()

#include "content/02_metodologia.typ"

#pagebreak()

#include "content/03_resultados.typ"

#pagebreak()

#include "content/04_conclusiones.typ"

#pagebreak()

#include "content/referencias.typ"
