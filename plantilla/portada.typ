#import "estilos.typ": *

// Tiñe la inicial de cada palabra que aporta una letra a la sigla, en orden.

#let resaltar-iniciales(titulo, sigla) = {
  let restante = upper(sigla).clusters()
  let salida = ()
  for palabra in titulo.split(" ") {
    if restante.len() > 0 and palabra.len() > 0 and upper(palabra.first()) == restante.first() {
      salida.push(text(fill: ambar)[#palabra.first()] + [#palabra.slice(1)])
      restante = restante.slice(1)
    } else {
      salida.push([#palabra])
    }
  }
  salida.join([ ])
}

#let portada(
  sigla: none,
  titulo: none,
  subtitulo: none,
  autor: none,
  carrera: none,
  universidad: none,
  facultad:none,
  director: none,
  codirector: none,
  fecha: none,
) = {
  set page(fill: noche, margin: 0pt, header: none, footer: none)
  set text(fill: white, font: titular, hyphenate: false)
  set par(justify: false)

  fondo()

  place(
    top + left,
    dx: 24mm,
    dy: 42mm,
    block(width: 118mm)[
      #text(size: 9.5pt, tracking: 3.4pt, fill: ambar)[#upper(universidad)]
      #v(2mm)
      #text(size: 9.5pt, tracking: 1.2pt, fill: gris)[#facultad]
      #v(2mm)
      #text(size: 9.5pt, tracking: 1.2pt, fill: gris)[#carrera]
    ],
  )

  place(
    left + horizon,
    dx: 24mm,
    block(width: 138mm)[
      // Espaciado por bloque en vez de `v()`.
      #block(above: 0pt, below: 8mm, line(length: 26mm, stroke: 1.4pt + ambar))

      #if sigla != none {
        block(
          above: 0pt,
          below: 13mm,
          text(size: 82pt, weight: 600, tracking: 10pt, fill: ambar)[#upper(sigla)],
        )
      }

      #block(
        above: 0pt,
        below: 8mm,
        width: 100mm,
        text(size: 23pt, weight: 400, fill: white)[#titulo],
      )
      #block(above: 0pt, below: 0pt, width: 100mm, text(size: 12pt, weight: 300, fill: gris)[#subtitulo])
    ],
  )

  place(
    bottom + left,
    dx: 24mm,
    dy: -40mm,
    block(width: 132mm)[
      #set text(size: 10pt, fill: gris)
      #grid(
        columns: (auto, 1fr),
        column-gutter: 8mm,
        row-gutter: 2.4mm,
        text(fill: ambar, size: 8pt, tracking: 1pt)[AUTOR], text(fill: white)[#autor],
        text(fill: ambar, size: 8pt, tracking: 1pt)[DIRECCIÓN], text(fill: white)[#director],
        text(fill: ambar, size: 8pt, tracking: 1pt)[CODIRECCIÓN], text(fill: white)[#codirector],
        text(fill: ambar, size: 8pt, tracking: 1pt)[FECHA], text(fill: white)[#fecha],
      )
    ],
  )

  pagebreak()
}
