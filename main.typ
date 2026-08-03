#import "plantilla/plantilla.typ": informe, anexos, indice-general, indice-figuras, titulo-suelto
#import "plantilla/partes.typ": parte
#import "plantilla/bloques.typ": indice-pendientes

// Este archivo es la estructura del informe. El orden de los `include` es el
// orden del documento, y cada capítulo se descomenta cuando su archivo existe.
//
// Dos reglas que ordenan todo lo demás:
//   1. Las Partes agrupan, los capítulos numeran. Los capítulos de desarrollo
//      son hermanos, no hijos, para no gastar un nivel de jerarquía. El
//      agrupamiento lo da `parte()`, que no numera.
//   2. El desarrollo espeja el orden del marco teórico. Transporte, detección
//      y captura se explican en 2.2, 2.3 y 2.4, y se implementan en ese mismo
//      orden en 8, 9 y 10. El lector no reordena nada en la cabeza.

#show: informe.with(
  sigla: "STEF",
  titulo: "Sistema de Transporte y Escaneo Fílmicos",
  subtitulo: "Digitalización de acervo en 16 mm y 35 mm sobre hardware y software abiertos",
  titulo-corto: "STEF · Transporte y Escaneo Fílmicos",
  autor: "Fernando Stefanovic",
  carrera: "Proyecto Integrador de Ingeniería en Computación",
  universidad: "Universidad Nacional de Córdoba",
  facultad: "Facultad de Ciencias Exactas, Físicas y Naturales",
  director: "Julio Sánchez",
  codirector: "Javier Jorge",
  fecha: "2026",
)

#include "capitulos/00-resumen.typ"

#indice-general()

// ============================================================ Parte I
#parte("I", "Planteo")


#include "capitulos/01-introduccion.typ"

#include "capitulos/02-marco-teorico.typ"

#include "capitulos/03-elicitacion.typ"

#include "capitulos/04-metodologia.typ"

// ============================================================ Parte II
#parte("II", "Desarrollo")

#include "capitulos/05-arquitectura.typ"

#include "capitulos/06-hardware.typ"

#include "capitulos/07-armazon.typ"

#include "capitulos/08-firmware.typ"

#include "capitulos/09-deteccion.typ"

#include "capitulos/10-captura.typ"

#include "capitulos/11-gui.typ"

#include "capitulos/12-aplicacion-central.typ"

// ============================================================ Parte III
#parte("III", "Cierre")

#include "capitulos/13-resultados.typ"

#include "capitulos/14-conclusiones.typ"

#bibliography("referencias/referencias.bib", style: "ieee", title: "Bibliografía")

#titulo-suelto("Pendientes")
#indice-pendientes()

// ============================================================ Anexos
#anexos[
  #include "anexos/a-manual.typ"

  #include "anexos/b-ccapi.typ"

  #include "anexos/c-derivados.typ"
]


