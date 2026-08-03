#import "estilos.typ": *

// Las Partes agrupan y no numeran: no son un nivel de encabezado, así que no
// gastan jerarquía ni entran en la numeración de capítulos. Por eso son una
// función y no un `= Título`.
#let parte(numero, titulo) = {
  pagebreak(weak: true)
  set page(fill: noche, margin: 0pt, header: none, footer: none)
  fondo()
  place(
    bottom + left,
    dx: 24mm,
    dy: -46mm,
    block[
      #line(length: 26mm, stroke: 1.4pt + ambar)
      #v(4mm)
      #text(font: titular, size: 10pt, tracking: 3.4pt, fill: ambar)[PARTE #numero]
      #v(1mm)
      #text(font: titular, size: 44pt, weight: 500, fill: white)[#titulo]
    ],
  )
  pagebreak(weak: true)
}
