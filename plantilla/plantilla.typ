#import "estilos.typ": *
#import "portada.typ": portada

#let modo-anexo = state("modo-anexo", false)

// Dos dígitos para los capítulos, por la misma razón que tres para el folio:
#let dos(n) = {
  let s = str(n)
  if s.len() < 2 { "0" + s } else { s }
}

// Etiqueta del capítulo en curso, tal como aparece en el encabezado.
#let etiqueta-capitulo(h) = context {
  let cuerpo = text(font: titular, size: 7.5pt, fill: gris, tracking: 0.6pt)[#upper(h.body)]
  if h.numbering == none {
    cuerpo
  } else {
    let n = counter(heading).at(h.location()).first()
    let anexo = modo-anexo.at(h.location())
    let marca = if anexo { numbering("A", n) } else { dos(n) }
    text(font: titular, size: 7.5pt, fill: gris, tracking: 0.6pt)[#marca · #cuerpo]
  }
}

#let informe(
  sigla: none,
  titulo: none,
  subtitulo: none,
  titulo-corto: none,
  autor: none,
  carrera: none,
  universidad: none,
  facultad: none,
  director: none,
  codirector: none,
  fecha: none,
  contenido,
) = {
  set document(title: titulo, author: if autor == none { () } else { (autor,) })

  set text(font: cuerpo, size: 10.2pt, lang: "es", fill: tinta)
  set par(justify: true, leading: 0.72em, spacing: 1.1em, first-line-indent: 0pt)
  set heading(numbering: "1.1.")
  set table(stroke: none)

  show link: it => text(fill: ambar, it)
  show emph: it => text(style: "italic", it)

  show raw.where(block: true): it => block(
    width: 100%,
    fill: fondo-codigo,
    inset: (x: 5mm, y: 4mm),
    radius: 1.5mm,
    text(font: mono, size: 8.6pt, it),
  )
  show raw.where(block: false): it => box(
    fill: fondo-codigo,
    inset: (x: 1.6pt),
    outset: (y: 3pt),
    radius: 1pt,
    text(font: mono, size: 0.92em, it),
  )

  show figure: set block(above: 6mm, below: 7mm)
  show figure.caption: it => {
    set text(font: titular, size: 8.2pt, fill: gris)
    set par(justify: false)
    [#text(weight: 600, fill: tinta)[#it.supplement #context it.counter.display(it.numbering).] #it.body]
  }

  // Capítulo: numeral grande en ámbar, filete, título. Siempre abre página.
  show heading.where(level: 1): it => context {
    pagebreak(weak: true)
    v(14mm)

    if it.numbering != none {
      let n = counter(heading).at(it.location()).first()
      let anexo = modo-anexo.at(it.location())
      let marca = if anexo { numbering("A", n) } else { dos(n) }

      block(above: 0pt, below: 4mm, text(font: titular, size: 64pt, weight: 600, fill: ambar)[#marca])
    }
    block(above: 0pt, below: 3.5mm, line(length: 100%, stroke: 1.6pt + tinta))
    block(above: 0pt, below: 9mm, text(font: titular, size: 26pt, weight: 500)[#it.body])
  }

  show heading.where(level: 2): it => {
    v(3mm)
    text(font: titular, size: 13pt, weight: 600)[#counter(heading).display() #it.body]
    v(0.5mm)
  }

  show heading.where(level: 3): it => {
    v(2mm)
    text(font: titular, size: 10.8pt, weight: 600, fill: gris.darken(30%))[#counter(heading).display() #it.body]
    v(0.5mm)
  }

  set page(
    paper: "a4",

    margin: (left: 24mm, right: 62mm, top: margen-superior, bottom: margen-inferior),
    header: context {
      let pag = here().page()
      let caps = query(heading.where(level: 1))
      let abre-aca = caps.any(h => h.location().page() == pag)
      if not abre-aca {
        let previos = caps.filter(h => h.location().page() <= pag)
        let actual = if previos.len() > 0 { previos.last() } else { none }
        grid(
          columns: (1fr, auto),
          align: (left, right),
          text(font: titular, size: 7.5pt, fill: gris, tracking: 0.6pt)[
            #upper(if titulo-corto == none { "" } else { titulo-corto })
          ],
          if actual == none { [] } else { etiqueta-capitulo(actual) },
        )
        v(2.2mm)
        line(length: 100%, stroke: 0.5pt + regla)
      }
    },
    footer: context {
      let pag = here().page()
      let caps = query(heading.where(level: 1)).filter(h => h.location().page() <= pag)
      let h = if caps.len() == 0 { none } else { caps.last() }
      let marca = if h == none or h.numbering == none {
        none
      } else {
        let n = counter(heading).at(h.location()).first()
        if modo-anexo.at(h.location()) { numbering("A", n) } else { dos(n) }
      }
      set text(font: titular, size: 8pt, fill: gris)
      align(right)[
        #if marca == none [#folio(pag)] else [#marca · #folio(pag)]
      ]
    },
  )

  portada(
    sigla: sigla,
    titulo: titulo,
    subtitulo: subtitulo,
    autor: autor,
    carrera: carrera,
    universidad: universidad,
    facultad: facultad,
    director: director,
    codirector: codirector,
    fecha: fecha,
  )

  contenido
}

// Los anexos siguen numerando capítulos, pero con letra.
#let anexos(contenido) = {
  modo-anexo.update(true)
  counter(heading).update(0)
  set heading(numbering: "A.1.")
  contenido
}

// Título de sección sin numerar, para el frente y el cierre del documento.
#let titulo-suelto(texto) = {
  pagebreak(weak: true)
  v(10mm)
  block(above: 0pt, below: 9mm, text(font: titular, size: 26pt, weight: 500)[#texto])
}

#let indice-general() = {
  titulo-suelto("Índice")
  show outline.entry.where(level: 1): it => {
    v(4mm, weak: true)
    text(font: titular, weight: 600, size: 10.5pt, it)
  }
  outline(title: none, depth: 2, indent: 6mm)
}

#let indice-figuras() = {
  titulo-suelto("Índice de figuras")
  outline(title: none, target: figure.where(kind: image))
}
