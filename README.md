# Informe

Fuente del informe del Proyecto Integrador, en Typst.

Todo lo que vive en este repositorio está en castellano: prosa, nombres de
archivo, nombres de sección y etiquetas de referencia cruzada. La documentación
del resto del proyecto está en inglés.

## Cómo se compila

El editor alcanza: la extensión Tinymist trae su propio compilador y exporta el
PDF al guardar. No hace falta instalar Typst en el sistema ni entrar a ningún
devshell.

Desde la línea de comandos, parado en la raíz del repositorio:

```
typst compile --font-path plantilla/fuentes --ignore-system-fonts main.typ build/informe.pdf
```

`--ignore-system-fonts` no es opcional: obliga a usar las fuentes versionadas en
`plantilla/fuentes/` y no las que tenga instalada la máquina, que es lo que hace
que el PDF salga igual en cualquier clon.

Versión de Typst con la que se compila: **0.15.1**.

## Estructura

| Ruta | Qué contiene |
| --- | --- |
| `main.typ` | La estructura del informe. El orden de los `include` es el orden del documento. |
| `plantilla/` | Diseño: geometría, tipografía, color, portada, divisores de parte y bloques. |
| `plantilla/fuentes/` | IBM Plex Sans, Serif y Mono, con sus licencias OFL. |
| `capitulos/` | Un archivo por capítulo. |
| `anexos/` | Un archivo por anexo. |
| `figuras/` | Imágenes y fuentes de diagramas. |
| `referencias/` | Bibliografía en BibTeX. |
| `build/` | Salida. Ignorado por git. |

<!--
Pendiente de escribir en este archivo:

- Mapa de capítulos: qué número corresponde a qué archivo y qué entra en cada
  uno. La fuente por ahora es meta/report_structure.md.
- Convenciones de escritura: cómo se nombran las etiquetas de referencia
  cruzada, cuándo va una nota al margen y cuándo va al cuerpo.
- Cómo se agregan figuras: formato, dónde viven, cómo se regeneran los
  diagramas.
- Qué se saca del documento antes de entregarlo (la sección "Pendientes").
- El tag del repositorio que corresponde a la versión defendida.
-->
