#import "../plantilla/bloques.typ": pendiente, nota, tabla

= Elicitación

El capítulo 1 estableció que el flujo manual del laboratorio no escala. Este capítulo convierte esa constatación en especificaciones: qué problemas concretos se relevaron, qué restricciones impone el equipamiento existente, y qué debe hacer el sistema como consecuencia de ambas cosas.

== Identificación de problemáticas

El relevamiento se realizó sobre el propio laboratorio del CDA, en conversaciones sucesivas con su personal de dirección y del departamento de digitalización, y mediante trabajo directo en el puesto durante la Práctica Profesional Supervisada (PPS). Esa permanencia en el laboratorio es lo que permitió observar el flujo completo en operación real.

La PPS se aprovechó además para verificar que las soluciones candidatas fueran alcanzables antes de comprometerlas como requerimientos. Se construyó una prueba de concepto por subsistema:

#figure(
  tabla(
    columnas: (auto, 1fr, 1fr),
    cabecera: ("Subsistema", "Prueba realizada", "Qué quedó verificado"),
    [Transporte],
    [Comunicación entre la PC y un driver TMC2209 por puerto serie, con lectura y escritura de sus registros.],
    [El driver es gobernable por software desde una computadora, y su protocolo serie es implementable.],

    [Detección],
    [Una grabación del Live View de la cámara usada como material de entrada para una versión prototípica del algoritmo de centrado.],
    [El fotograma es identificable sobre imagen real del propio flujo, sin instrumentación adicional, y el resultado es una magnitud: un desplazamiento en píxeles acompañado de una confianza, y no un juicio visual.],

    [Captura],
    [Disparo del obturador de la Canon desde un script en Python, por red.],
    [La cámara acepta órdenes de captura remotas, de modo que el disparo puede automatizarse.],
  ),
  kind: table,
  caption: [Pruebas de concepto construidas durante la etapa de relevamiento.],
) <tbl-pruebas-concepto>

Dos de esas pruebas quedaron registradas y se muestran en la @fig-pruebas-concepto. La primera es la placa de pruebas que sirvió para gobernar el driver: un módulo TMC2209 sobre placa perforada, con sus borneras de motor y de alimentación y un conector RJ45 que lleva el bus serie y las líneas de control hacia el controlador. Ese conector no es un detalle de armado sino el germen de la separación entre placa de driver y placa concentradora que se justifica en el capítulo 6.

La segunda es la salida del prototipo de detección corriendo sobre material grabado del laboratorio. #nota[La prueba de concepto resolvía el problema por correlación cruzada. Se quedaba con el canal azul, donde el contraste entre la perforación y la base del filme es mayor, y sumaba horizontalmente los píxeles de las columnas donde las perforaciones aparecen de forma estable, con lo que reducía el fotograma a un perfil de una sola dimensión. Correlacionar ese perfil contra el de referencia da el desplazamiento en píxeles, y la nitidez del pico, la confianza. El algoritmo que llega al sistema final se trata en el capítulo 9.] Sobre la imagen quedan marcadas las perforaciones halladas y el borde del fotograma, y el algoritmo devuelve un desplazamiento respecto del centro, medido en píxeles, junto con una confianza. Que devuelva cifras es la diferencia concreta contra el método manual descrito, donde el centrado se decide a ojo y no deja ningún valor que se pueda registrar, comparar entre corridas ni usar para corregir el transporte. El filme de la captura, además, está visiblemente deteriorado, lo que muestra que el problema de detección se planteó desde el principio sobre material real y no sobre una copia en buen estado.

#figure(
  grid(
    columns: (1fr, 1fr),
    column-gutter: 5mm,
    row-gutter: 2mm,
    align: bottom,
    image("../figuras/driver-testingboard.jpg", width: 100%),
    image("../figuras/detection-assertion.png", width: 100%),
    align(center)[(a)],
    align(center)[(b)],
  ),
  kind: image,
  caption: [Registro de dos de las pruebas de concepto. (a) Placa de banco con el módulo TMC2209, sus borneras y el conector RJ45 que transporta el bus serie y las líneas de control. (b) Prototipo de detección sobre material del acervo, con las perforaciones y el borde del fotograma marcados, y el desplazamiento y la confianza que devuelve el algoritmo.],
) <fig-pruebas-concepto>

Del relevamiento surgieron cinco problemáticas. Se numeran porque cada requerimiento de la sección 3.3 declara de cuál proviene.

- *P01. La cadencia depende de la resistencia física del operador.* El avance del filme se consigue accionando la palanca de la mesa bobinadora, una vez por fotograma. Es una tarea repetitiva y sostenida por lo que la cadencia efectiva cae a lo largo de la jornada y por lo tanto resulta en una actividad sumamente *inergonómica*.

- *P02. El centrado no es determinista y, sobre todo, no es medible.* El encuadre de cada fotograma se logra haciendo coincidir a ojo la imagen del monitor con una referencia física pegada sobre la pantalla. Esto produce resultados desparejos entre fotogramas consecutivos, que después obligan a reencuadrar el área útil de imagen. Lo más limitante es que el proceso no arroja ninguna medición: nadie sabe cuánto se desvió cada fotograma, así que el laboratorio no tiene una línea de base de error de centrado contra la cual comparar una mejora.

- *P03. El disparo es unitario.* Cada captura exige que el operador accione el obturador después de alinear el fotograma. Ese acoplamiento entre la decisión visual y la acción manual es lo que fija la cadencia en el orden de los 2 segundos por fotograma establecido en el capítulo 1.

- *P04. El material degradado impone un riesgo que el avance manual no controla.* Los filmes de base de acetato presentan síndrome del vinagre, encogimiento heterogéneo, fragilidad estructural y perforaciones rasgadas o faltantes. El avance por tensión desigual (causado por la ventanilla de presión reciclada) aumenta la probabilidad de atascos y roturas, poniendo en riesgo la integridad material de piezas audiovisuales irremplazables.

- *P05. La dependencia tecnológica ya se cobró un equipo.* La parálisis del telecine MWA por falta de repuestos y de servicio técnico es la evidencia local de que un sistema cerrado y poco modular transfiere al proveedor la vida útil del equipo. Cualquier reemplazo que repita ese esquema hereda el mismo destino.

== Materiales disponibles del laboratorio

El equipamiento que el CDA ya posee fija restricciones que explican decisiones de arquitectura que, sin este contexto, parecerían arbitrarias.

- *Cámara Canon EOS R50.* Una cámara sin espejo de sensor APS-C y lente intercambiable, con anillos de extensión para trabajar a la distancia de un fotograma @uncinnova-cda. Lo relevante para el proyecto no es su gama sino dos hechos: el laboratorio ya la tiene, y admite control remoto a través de la Canon Camera Control API. De ahí se sigue que el subsistema de captura se construya sobre esa interfaz y opere por red, y que queden descartadas las cámaras industriales con interfaz USB3 o GigE, cuyo costo contradice la premisa del proyecto.

- *Mesa bobinadora horizontal plana de 35 mm.* Adaptada, con platos de suministro y rebobinado, ventanilla de presión reciclada para mantener el filme plano y retroiluminación LED con difusor esmerilado @uncinnova-cda. El sistema se integra sobre ese chasis y automatiza su tracción, en lugar de fabricar una estructura desde cero.

- *AEO-Light.* El CDA ya utiliza este software libre para extraer la banda de sonido óptico a partir de la imagen del filme. #nota[AEO-Light fue desarrollado en la University of South Carolina, en las Moving Image Research Collections y con financiamiento del National Endowment for the Humanities, para extraer la banda de sonido óptico a partir de escaneos de filme ya existentes, sin requerir una segunda pasada por un equipo dedicado al sonido @aeo-light @uncinnova-cda.] La consecuencia es directa y se convierte en requerimiento: el encuadre que entregue el sistema no puede recortar el área marginal del filme, porque ahí viven las perforaciones y la pista de sonido que ese flujo posterior necesita. La práctica archivística respalda esa exigencia por la vía del costo: cuando el escáner no captura la banda sonora junto con la imagen, el sonido pasa a depender de un flujo paralelo de sincronización, con su propia preparación y verificación @fiaf-workflow.

- *Red del laboratorio.* Como el control de la cámara ocurre sobre red, la infraestructura existente determina las condiciones de latencia en las que el sistema tiene que operar. Es un dato del entorno y no una decisión de diseño, y es el origen de uno de los riesgos que se gestionan en el capítulo 4.

- *Entorno informático.* El sistema central debe correr sobre los equipos de cómputo estándar del laboratorio y apoyarse en herramientas de código abierto, tanto para no depender de licencias comerciales como para que las compilaciones del proyecto sean reproducibles.

== Requerimientos

De las problemáticas y de las restricciones anteriores se elicitaron trece requerimientos. Los once primeros provienen del relevamiento inicial del proyecto; R12 surgió de la restricción que impone el flujo de extracción de sonido ya vigente en el laboratorio, y R13 de la falta de medición que señala P02.

#figure(
  tabla(
    columnas: (auto, 1fr),
    cabecera: ("ID", "Requerimiento"),
    [R01], [El sistema debe disparar automáticamente el obturador de la cámara cuando un fotograma se encuentre centrado.],
    [R02], [El sistema debe monitorear la temperatura que informa la cámara y suspender la captura cuando supere un umbral configurable, para no reducir su vida útil.],
    [R03], [El sistema debe centrar un fotograma mediante un mecanismo de detección y un mecanismo de transporte del material fílmico.],
    [R04], [El sistema debe implementar el mecanismo de detección de modo que se adapte al estado típico de los filmes, bajo diversas condiciones de deterioro físico y dimensional.],
    [R05], [El sistema debe implementar el mecanismo de transporte de modo que afecte lo menos posible la integridad del material fílmico.],
    [R06], [El sistema debe ser modular.],
    [R07], [El sistema debe ser fácil de mantener y utilizar componentes fácilmente reemplazables.],
    [R08], [El sistema debe proveer una interfaz gráfica que permita al operador configurar, iniciar, detener y monitorear la digitalización.],
    [R09], [El sistema debe estar documentado de forma que garantice la longevidad del proyecto a largo plazo.],
    [R10], [El sistema debe utilizar herramientas propias o de origen abierto siempre que sea posible.],
    [R11], [El sistema debe superar la capacidad del proceso manual, optimizando la cadencia de procesamiento, reduciendo la fatiga operativa y extendiendo los intervalos de autonomía del equipo.],
    [R12], [El sistema debe entregar capturas que incluyan el área marginal del filme, con las perforaciones y la pista de sonido óptico dentro del encuadre.],
    [R13], [El sistema debe registrar, por fotograma, el resultado del centrado y la cuenta de avance del transporte.],
  ),
  kind: table,
  caption: [Requerimientos elicitados para el sistema.],
) <tbl-requerimientos>

Un requerimiento que no declara cómo se comprueba no se puede concluir. Por ello, la siguiente tabla los clasifica, los ata a la problemática o restricción que lo originó, y fija con qué evidencia se lo va a dar por cumplido en el capítulo 13.

#figure(
  tabla(
    columnas: (auto, auto, auto, 1fr),
    cabecera: ("ID", "Tipo", "Origen", "Medio de verificación"),
    [R01], [Funcional], [P03], [Ensayo funcional sobre material real, con medición de la proporción de disparos correctos.],
    [R02], [Funcional], [3.2], [Ensayo de cadencia sostenida: se registra la temperatura que informa la cámara y se verifica la suspensión al alcanzar el umbral.],
    [R03], [Funcional], [P02], [Ensayo funcional: proporción de fotogramas centrados dentro de la tolerancia declarada.],
    [R04], [No Funcional], [P02, P04], [Ensayo sobre el corpus de validación, que incluye material con deterioro representativo.],
    [R05], [No Funcional], [P04], [Inspección del material antes y después del procesamiento, buscando daño atribuible al transporte.],
    [R06], [No Funcional], [P05], [Inspección de la arquitectura: sustituir un componente sin modificar los que lo rodean.],
    [R07], [No Funcional], [P05], [Inspección de la lista de materiales: disponibilidad y reemplazabilidad de cada pieza.],
    [R08], [Funcional], [P01], [Demostración de la interfaz sobre el flujo completo, con las cuatro operaciones ejercidas.],
    [R09], [No Funcional], [P05], [Inspección documental: este informe, la documentación derivada del código y el anexo C.],
    [R10], [No Funcional], [P05], [Inspección de licencias y dependencias del proyecto.],
    [R11], [No Funcional], [P01, P03], [Medición de cadencia y throughput contra la línea de base de 2 s por fotograma.],
    [R12], [Funcional], [3.2], [Inspección de las capturas entregadas: presencia de perforaciones y pista de sonido en el encuadre.],
    [R13], [Funcional], [P02], [Inspección del registro contra una secuencia de longitud conocida.],
  ),
  kind: table,
  caption: [Clasificación, trazabilidad y verificación de los requerimientos.],
) <tbl-trazabilidad>

#pendiente[Tres cosas de este capítulo se cierran contra el capítulo 13 y hoy no tienen número: la tolerancia de error de centrado que menciona R03, la cadencia sostenida que R02 declara verificable, y la cota de mejora de R11. Los tres medios de verificación de la matriz tienen que coincidir con lo que 13.2 efectivamente reporte. Es decir, cuando estes mas avanzado, charlá con los supervisores y fijá esos números, para que la trazabilidad sea completa.]

