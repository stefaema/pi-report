#import "estilos.typ": *
#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

// Nota al margen. Vive en la columna ancha de la derecha, alineada con el
// punto del cuerpo donde se la invoca.
#let nota(contenido) = {
  let cuerpo = box(width: 38mm)[
    #set text(size: 7.6pt, fill: gris)
    #set par(justify: false, leading: 0.55em)
    #line(length: 12mm, stroke: 0.8pt + ambar)
    #v(1.5mm)
    #contenido
  ]

  context {
    let ancla = here().position().y
    let baja = (0.6em).to-absolute()
    let alto = measure(cuerpo).height

    let excedente = ancla + baja + alto - (pagina-alto - margen-inferior)
    if excedente > 0pt {
      baja = calc.max(baja - excedente, margen-superior - ancla)
    }

    place(dx: 100% + 8mm, dy: baja, cuerpo)
  }
}

// Marca de pendiente. Se registra para que `indice-pendientes()` pueda mantener un recuento.

#let pendiente(contenido) = {
  [#metadata((clase: "nota", texto: contenido))<pendiente>]
  box(
    inset: (x: 2mm, y: 0.9mm),
    outset: (y: 0.9mm),
    radius: 1mm,
    fill: ambar.lighten(84%),
    text(size: 8.6pt, fill: ambar.darken(18%), font: titular)[PENDIENTE: #contenido],
  )
}

// Figura que todavía no existe. Ocupa lugar, toma número de figura y entra en
// el índice, así que reemplazarla después no mueve nada a su alrededor.
#let figura-pendiente(descripcion, caption: none) = figure(
  block(
    width: 100%,
    inset: (x: 6mm, y: 7mm),
    radius: 1.5mm,
    stroke: (paint: ambar, thickness: 0.8pt, dash: "dashed"),
    {
      set par(justify: false)
      set align(left)
      [#metadata((clase: "figura", texto: descripcion))<pendiente>]
      text(font: titular, size: 7.5pt, weight: 600, fill: ambar, tracking: 1pt)[FIGURA PENDIENTE]
      v(1.5mm)
      set text(size: 9pt, fill: gris)
      descripcion
    },
  ),
  caption: caption,
  kind: image,
  supplement: [Figura],
)

// Índice de todo lo que falta, con su página. Va al final del documento
#let indice-pendientes() = context {
  let marcas = query(<pendiente>)
  if marcas.len() == 0 {
    text(fill: gris)[No queda nada pendiente.]
  } else {
    set text(size: 9pt)
    for m in marcas {
      let p = m.location().page()
      grid(
        columns: (10mm, 18mm, 1fr),
        align: (left, left, left),
        inset: (y: 2.2pt),
        text(font: mono, fill: ambar)[#folio(p)],
        text(font: titular, size: 7.5pt, fill: gris)[#upper(m.value.clase)],
        m.value.texto,
      )
    }
  }
}

#let caja(pos, contenido, acento: false, ..resto) = node(
  pos,
  text(font: titular, size: 8.5pt, weight: if acento { 600 } else { 400 })[#contenido],
  stroke: 0.8pt + if acento { ambar } else { tinta },
  fill: if acento { ambar.lighten(88%) } else { white },
  inset: 3.5mm,
  corner-radius: 1.5mm,
  ..resto,
)

#let encierro(celdas, ..resto) = node(
  enclose: celdas,
  snap: false,
  stroke: (paint: regla.darken(15%), thickness: 0.7pt, dash: "dashed"),
  fill: none,
  inset: 3.5mm,
  corner-radius: 2mm,
  ..resto,
)

#let flecha(desde, hasta, etiqueta: none, doble: false, ..resto) = edge(
  desde,
  hasta,
  if doble { "<->" } else { "->" },
  stroke: 0.7pt + tinta,
  label: if etiqueta == none {
    none
  } else {
    text(font: titular, size: 7.5pt, fill: gris)[#etiqueta]
  },
  label-sep: 2mm,
  label-side: right,
  ..resto,
)

#let diagrama(..contenido) = align(center, diagram(
  spacing: (16mm, 11mm),
  node-stroke: none,
  edge-stroke: 0.7pt + tinta,
  ..contenido,
))

#let disposicion(
  partes,
  arriba: none,
  abajo: none,
  envuelta: none,
  prefijo: none,
  sufijo: none,
  elastica: none,
) = {
  let n = partes.len()
  let anchos = range(n).map(i => if i == elastica { 1fr } else { auto })
  let etiqueta(t) = table.cell(
    stroke: none,
    align: right + horizon,
    if t == none { [] } else { text(size: 7.5pt, fill: gris)[#t] },
  )
  let hueco = table.cell(stroke: none)[]

  set text(font: titular, size: 8.5pt)
  table(
    columns: (auto, auto, ..anchos, auto),
    stroke: 0.7pt + tinta,
    align: center + horizon,
    inset: (x: 3mm, y: 3mm),
    row-gutter: 2mm,

    etiqueta(arriba), hueco, ..partes, hueco,

    ..if envuelta == none {
      ()
    } else {
      (
        etiqueta(abajo),
        if prefijo == none { hueco } else { prefijo },
        table.cell(colspan: n, envuelta),
        if sufijo == none { hueco } else { sufijo },
      )
    },
  )
}

// Tabla con el trazo del informe:
#let tabla(columnas: auto, cabecera: (), ..filas) = {
  set text(size: 9.2pt)
  table(
    columns: columnas,
    column-gutter: 6mm,
    stroke: none,
    align: left + top,
    inset: (x: 0pt, y: 6pt),
    table.hline(stroke: 1.2pt + tinta),
    table.header(
      ..cabecera.map(c => text(
        font: titular,
        weight: 600,
        size: 8pt,
        tracking: 0.5pt,
      )[#upper(c)]),
    ),
    table.hline(stroke: 0.6pt + tinta),
    ..filas,
    table.hline(stroke: 1.2pt + tinta),
  )
}
