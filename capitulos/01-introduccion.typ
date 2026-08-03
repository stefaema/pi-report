#import "../plantilla/bloques.typ": pendiente, nota, tabla

= Introducción

== Situación

El Centro de Conservación y Documentación Audiovisual (CDA), dependiente de la Facultad de Filosofía y Humanidades y de la Facultad de Artes de la Universidad Nacional de Córdoba (UNC), tiene como misión la recuperación, preservación, investigación y puesta en valor del patrimonio audiovisual de la región. #nota[El CDA se conformó en 1994 a partir de un convenio con los Servicios de Radio y Televisión de la UNC, y fue institucionalizado como dependencia por Ordenanza 02/02 del HCD de la Facultad de Filosofía y Humanidades. Desde 2011 la dependencia es compartida con la Facultad de Artes @cda-sitio @cda-artes.] Su acervo custodia colecciones fotográficas e históricas de acceso público: más de 8.000 negativos de vidrio de la colección periodística Antonio Novello (1920-1955), digitalizados con escáneres planos de alta resolución, y un volumen que la propia institución estima en *75.000 rollos de película cinematográfica* @cda-sitio. Ese fondo fílmico abarca el archivo del Noticiero Canal 10 (1962-1980), el del Noticiero Canal 12 (1996-2001), el primer noticiero cinematográfico producido en Córdoba, la filmografía completa del director Alfredo Mathé y las colecciones de la Cinemateca de la Escuela de Artes (1964-1974).

#figure(
  image("../figuras/boveda-cda.jpg", width: 100%),
  caption: [Bóveda de almacenamiento del acervo fílmico del CDA.],
) <fig-boveda>

Dentro del abanico de actividades de la institución, este proyecto se enfoca de manera específica en la *conservación del material audiovisual en los calibres de 16 mm y 35 mm*, que es la tarea operativa más crítica del centro. Contar con una copia digital en alta resolución facilita el acceso a los documentos y evita la manipulación del original analógico para tareas de reproducción.

La conservación de este patrimonio suele plantearse por varias vías, pero en la práctica el abanico de opciones reales es muy acotado:

- *Almacenamiento controlado.* Mantener los filmes en bóvedas con temperatura y humedad reguladas no resuelve el problema, solo retrasa un deterioro que es químicamente inevitable. En el acetato de celulosa, que es el material de base de la mayor parte del acervo, ese deterioro se conoce como síndrome del vinagre, y una vez iniciado no se revierte. La sección 2.1 desarrolla el mecanismo.

- *Hallazgos físicos.* Buscar copias nuevas depende de la suerte de encontrar piezas en mejor estado que las archivadas, algo cada vez menos frecuente.

- *Restauración fotoquímica.* Intervenir físicamente el filme tiene límites técnicos claros, costos prohibitivos, y depende de una infraestructura industrial que prácticamente desapareció de la región.

- *Digitalización.* Es la única vía que cambia el medio de almacenamiento y, con eso, la única que desacopla la información de un material de base que se degrada.

El problema se agrava en el plano geográfico e institucional. En Córdoba no existen actualmente equipos capaces de digitalizar 16 mm o 35 mm a nivel profesional, y en el ámbito privado las pocas empresas idóneas operan en Buenos Aires a costos prohibitivos para un presupuesto universitario. Por eso la digitalización de esos dos calibres es el foco central de este proyecto y el cuello de botella operativo más relevante de la institución.

=== Del telecine al prototipo manual

A mediados de 2009, mediante un subsidio de la Secretaría de Ciencia y Tecnología de la UNC, el CDA adquirió un telecine comercial MWA FlashTransfer de origen alemán. #nota[Con ese equipo se volcaron más de 400 horas de material a soporte digital antes de que quedara fuera de servicio.] El equipo transfería filmes de 16 mm a resolución estándar DV-PAL y años más tarde recibió intervenciones sobre la óptica y la captura para intentar llevarlo a ultra alta definición. La obsolescencia acumulada, el desgaste mecánico y la imposibilidad de importar repuestos o contratar servicio técnico especializado terminaron por dejarlo definitivamente fuera de servicio.

#figure(
  image("../figuras/digitalizador-roto.jpg", height: 190mm),
  caption: [Telecine MWA FlashTransfer de 16 mm, fuera de servicio.],
) <fig-telecine>

Para no paralizar el rescate del archivo, el CDA diseñó un prototipo de escáner económico adaptando una antigua mesa bobinadora horizontal plana de 35 mm. El equipo integró una ventanilla de presión reciclada para mantener el filme plano, una fuente de luz LED con difusor esmerilado opaco, y una cámara Canon EOS R50 con anillos de extensión para capturar en UHD (3840 × 2160) la imagen, las perforaciones y la banda de sonido óptico, esta última procesada con el software libre AEO-Light @aeo-light.

#figure(
  image("../figuras/digitalizador-manual.jpg", width: 100%),
  caption: [Sistema de captura manual adaptado sobre la mesa de montaje.],
) <fig-manual>

Esa mesa demostró que se pueden obtener imágenes de alta calidad, pero mantuvo el proceso atado a una operación estrictamente artesanal:

1. *Tracción manual.* El operador hace avanzar el filme accionando de forma individual la palanca original de la mesa bobinadora.

2. *Centrado visual no determinista.* El encuadre de cada fotograma depende de la destreza del operador, que alinea la imagen a ojo en un monitor contra una guía física pegada sobre la pantalla.

3. *Disparo unitario.* Con el fotograma posicionado, el operador acciona manualmente el obturador de la cámara.

El método alcanza una cadencia promedio de 2 segundos por fotograma. #nota[La cadencia es el tiempo que consume el ciclo completo de un fotograma, esto es avanzar el filme, centrarlo y disparar, y es la magnitud que este proyecto se propone cambiar.]
Contra la escala del acervo, ese número es un problema central:

#figure(
  tabla(
    columnas: (1fr, auto, 38mm),
    cabecera: ("Magnitud", "Valor", "Origen"),
    [Rollos custodiados], [75.000], [estimación del CDA],
    [Duración media por rollo], [10 min], [estimación conservadora],
    [Fotogramas por rollo], [14.400], [10 min × 60 s × 24 fps],
    [Fotogramas en el acervo], [1.080 millones], [75.000 × 14.400],
    [Cadencia manual medida], [2 s por fotograma], [medición en el laboratorio],
    [Horas hombre], [600.000 h], [1.080 millones × 2 s],
    [Jornada laboral considerada], [2.000 h por año], [8 h × 250 días],
    [Años de una persona], [más de 300], [600.000 ÷ 2.000],
  ),
  kind: table,
  caption: [Escala del acervo fílmico del CDA contra la cadencia del método manual.],
) <tbl-escala>

A esta cadencia, el acervo se descomponerá antes de ser digitalizado, por lo que la decisión que el laboratorio necesita tomar no es qué material rescatar primero, sino cómo cambiar la cadencia.

Frente a esa inviabilidad operativa, y ante la imposibilidad económica de adquirir un escáner industrial cerrado, el punto de partida de este proyecto es la base física de la mesa bobinadora adaptada.

== Objetivos y motivaciones

Esta sección enuncia las metas fundamentales del proyecto y justifica su desarrollo en el ámbito universitario frente a la alternativa de adquirir un producto comercial nuevamente. Asimismo, para garantizar que estos objetivos sean verificables e identificables dentro de la implementación, el Capítulo 3 abordará en detalle la ingeniería de requerimientos y el proceso de elicitación de necesidades.

=== Objetivo general

Diseñar, construir e implementar un sistema mecatrónico modular y de código abierto para el transporte, la detección y la captura automatizados de material fílmico en 16 mm y 35 mm, que reemplace la tracción y el centrado manuales del laboratorio del CDA por control de motores y visión por computadora, integrando como medio de captura las cámaras fotográficas Canon de las que el laboratorio ya dispone.

=== Objetivos específicos

1. *Desarrollar un subsistema de transporte de bajo impacto.* Diseñar el hardware y el firmware de control, sobre drivers de motor paso a paso configurables por puerto serie, que garanticen un avance preciso del filme y protejan el material con perforaciones dañadas o base debilitada.

2. *Implementar el centrado de fotogramas por visión artificial.* Desarrollar algoritmos de procesamiento de imágenes, basados en correlación cruzada y heurísticas de apoyo, capaces de identificar y centrar fotogramas en tiempo de operación, con tolerancia a las deformaciones y variaciones dimensionales del material degradado.

3. *Automatizar la captura fotográfica por red.* Construir un cliente para la interfaz Canon Camera Control API que gobierne de forma remota la configuración, el disparo y el monitoreo de la cámara, sin intervención manual del operador.

4. *Construir una arquitectura modular y abierta.* Separar el sistema en capas de abstracción, tanto sobre el hardware como sobre el enlace entre la PC y el microcontrolador, de modo que un componente se pueda sustituir o reparar sin reescribir los que lo rodean.

5. *Superar la línea de base manual.* Validar experimentalmente que la cadencia del sistema automatizado supera a los 2 segundos por fotograma de la captura manual, y que el equipo puede operar sin supervisión continua durante intervalos medibles.

6. *Consolidar una documentación reproducible.* Generar un compendio documental estructurado, con el código, los diseños paramétricos 3D y los artefactos de fabricación de las placas, que prevenga la obsolescencia por falta de información y permita que otra persona retome el proyecto.

=== Motivaciones

Tres razones sostienen que este desarrollo sea pertinente y necesario dentro de la universidad, y que justifiquen su continuidad más allá de la tesis de grado:

*Integración disciplinar.* Un proyecto integrador tiene que cruzar áreas afines a la carrera. En particular, el presente trabajo concede los siguientes enfoques:
- *Electrónica:* diseño de placas, buses y gestión de potencia.
- *Sistemas embebidos:* firmware sobre un sistema operativo de tiempo real, generación de señales de temporización y abstracción de enlace mediante llamadas a procedimientos remotos.
- *Software:* procesamiento digital de imágenes, protocolos de red y múltiples interfaces de operación.
- *Ingeniería de requerimientos:* el problema se enuncia en un dominio y se resuelve en otro. Las necesidades llegan en términos de acervo, conservación y deterioro, y salen como tolerancias, protocolos, algoritmos y piezas. Los requerimientos son el mecanismo de traducción entre ambos mundos.

*Patrimonio y acceso.* El acervo del CDA mantiene registros de la vida universitaria, de la política cordobesa de los sesenta y setenta, y la cinematografía local, nacional, regional e internacional del período. La digitalización es lo que convierte ese material en algo consultable para la sociedad, y esa dimensión que se desprende es una de las misiones de la institución: preservar y poner a disposición de la comunidad patrimonio cultural.

*Soberanía técnica.* El telecine MWA quedó fuera de servicio porque no había repuestos ni servicio técnico al alcance. Un equipo cerrado le transfiere al proveedor la decisión de hasta cuándo sigue funcionando, y esa decisión ya se tomó una vez en contra del laboratorio. Un equipo abierto, modular y armado con piezas replicables localmente, con impresión 3D, microcontroladores de línea y drivers de catálogo, devuelve esa decisión a la institución y se considera una respuesta más acorde a la de adquirir un equipo nuevo.

== Alcance y limitaciones

#pendiente[Modificar el contenido de esta subsección a medida que se tenga más claro los límites del proyecto.]


Esta sección fija la frontera del sistema: qué queda del lado del proyecto, qué queda del lado del CDA, y bajo qué condiciones se evalúan los resultados de la parte 3. Varias de las restricciones que siguen no son concesiones sino consecuencias directas de la premisa económica y técnica del proyecto, y se declaran como tales.

=== Alcance del desarrollo

- *Calibres.* El sistema se diseña para 16 mm y 35 mm, y se valida sobre 16 mm, que es el calibre mayoritario del acervo y el que dejó paralizado el cese del telecine. El de 35 mm se aborda como compatibilidad mecánica y óptica del diseño, verificada en ensayos puntuales. Los calibres domésticos (8 mm, Super 8) y los soportes fotográficos quedan explícitamente afuera: no comparten geometría de perforación ni condiciones de tracción.

- *Cadena cubierta.* El desarrollo abarca el transporte motorizado del filme, el centrado automático del fotograma por visión artificial, el disparo remoto de la cámara y el registro de lo ocurrido en cada fotograma. Empieza cuando el rollo ya está montado y termina cuando la imagen fue capturada.

- *Tareas que se sustituyen.* El sistema reemplaza al operador en las tres tareas repetitivas del ciclo: hacer avanzar el filme, centrar el fotograma y accionar el obturador. Siguen siendo del operador el montaje y desmontaje del rollo, la inspección y limpieza previa, el empalme, y la decisión de qué material se digitaliza y en qué orden. Esa última no es una limitación técnica ya que es una decisión del CDA y no le corresponde al sistema.

- *Entregable.* La salida del sistema es una secuencia ordenada de capturas más un registro de captura que asienta, por fotograma, el resultado del centrado y la cuenta de avance del transporte. Ese registro es lo que permite verificar a posteriori que la secuencia está completa, sin depender de contar archivos a mano. La transferencia masiva de las imágenes se hace por los medios que la propia cámara ya provee, porque no es donde está el aporte del proyecto.

=== Limitaciones y restricciones de diseño

- *Digitaliza, no restaura.* El sistema no realiza restauración digital ni física. La corrección de color, la remoción de rayas, la reconstrucción de fotogramas dañados y la extracción del sonido óptico pertenecen a una etapa posterior, con herramientas y criterios que son del CDA. La banda de sonido se captura como imagen y queda disponible para ese flujo, pero su procesamiento no es parte de este desarrollo.

- *La calidad de imagen es heredada, no optimizada.* La resolución efectiva, la profundidad de color y el rendimiento óptico quedan acotados por la cámara y el objetivo que el laboratorio ya posee. Es una consecuencia inmediata de reutilizar el equipamiento existente, que es a su vez lo que hace viable el costo. Por lo mismo, toda comparación de rendimiento en el capítulo 13 se hace a óptica y cámara constantes.

- *Operación asistida.* El sistema elimina la intervención fotograma por fotograma, pero se especifica para operar con el operador presente. La operación autónoma prolongada sin supervisión queda fuera de alcance, y no por una limitación de implementación: el material es irremplazable y una falla mecánica no advertida puede destruir en segundos lo que no tiene copia.

- *Ante una anomalía, el sistema se detiene y reporta.* No intenta recuperarse por su cuenta. Frente a una pérdida de sincronismo, un centrado que no converge o una condición de falla del driver, la conducta especificada es interrumpir el avance y dejar registro del punto exacto en que ocurrió. Sobre material único, una detención cuesta minutos de operador y un reintento automático mal juzgado puede costar el rollo.

- *Integridad física previa del material.* El sistema tolera y compensa el daño típico del filme, como el jitter, el encogimiento de la base y las perforaciones deterioradas, pero no acondiciona ni repara. El material con faltantes estructurales, empalmes rotos o cristalización avanzada debe ser acondicionado antes por el equipo de archivistas.

- *Reutilización del equipamiento existente.* El diseño mecánico, óptico y de comunicaciones se adapta de forma obligatoria a lo que ya hay en el laboratorio: la mesa bobinadora horizontal adaptada y el ecosistema de cámaras Canon, en particular la EOS R50. No se contempla adquirir cámaras industriales ni construir estructuras a medida desde cero.

- *Sin equiparación con el estado del arte industrial.* El proyecto no busca igualar las especificaciones de los escáneres comerciales de alta gama. Adoptar sus arquitecturas llevaría el costo a un orden que anula la premisa de factibilidad, y el objetivo de diseño es precisión suficiente para el caso de uso con componentes accesibles. La comparación detallada contra esos equipos, y el argumento de por qué ninguno resuelve este caso, se desarrollan en el estado del arte.

- *Corpus de validación acotado.* La validación se realiza sobre un conjunto acotado y documentado de material del propio acervo, elegido para cubrir tanto filme en buen estado como filme con deterioro representativo. Las conclusiones se limitan a ese corpus y a las condiciones en que fue procesado.
