// Paleta y primitivas compartidas. Todo lo que dos archivos de plantilla
// necesiten ver vive acá, para que no haya un color escrito dos veces.

#let ambar = rgb("#c8791f")
#let tinta = rgb("#211f25")
#let gris = rgb("#6f6a75")
#let regla = rgb("#d9d4dd")
#let fondo-codigo = rgb("#f6f4f7")
#let noche = rgb("#131115")
#let perforacion = rgb("#302b36")

#let pagina-alto = 297mm
#let margen-superior = 24mm
#let margen-inferior = 22mm

#let titular = "IBM Plex Sans"
#let cuerpo = "IBM Plex Serif"
#let mono = "IBM Plex Mono"

// Ancho fijo de tres dígitos
#let folio(n) = {
  let s = str(n)
  while s.len() < 3 { s = "0" + s }
  s
}

#let fondo(opacidad: 75%) = {
  place(top + left, image("../figuras/fondo_portada.png", width: 100%, height: 100%, fit: "cover"))
  place(top + left, rect(width: 100%, height: 100%, fill: black.transparentize(opacidad)))
}

