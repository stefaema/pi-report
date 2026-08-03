#import "../plantilla/bloques.typ": pendiente, nota, tabla

= Metodología

La metodología de este proyecto es el conjunto de procedimientos que responden a los requerimientos de modularidad (R06), documentación (R07) y capacidad de mantenimiento (R09).

Lo que sigue declara cómo se organiza el trabajo, cómo se verifica, y qué se hace cuando algo falla.

== Ciclo de vida en desarrollo

El desarrollo adopta un ciclo de vida iterativo e incremental. Cada iteración toma un subsistema, lo lleva de una prueba de concepto a una versión integrable, y lo deja verificado antes de sumarle el siguiente. Las tres pruebas de concepto del capítulo 3 son la primera iteración de ese ciclo, y su función fue reducir el riesgo de comprometer requerimientos sin saber si eran alcanzables.

== Control de versiones

El sistema tiene distintas partes. Ninguna sirve por separado, porque el digitalizador es sinergia. Esta sección responde tres preguntas que de otro modo quedan implícitas: dónde vive el código, dónde se hace el trabajo a medio terminar, y qué significa exactamente "la versión del sistema".

=== Organización del repositorio

Todo el proyecto vive en un único repositorio, con una carpeta por módulo, de tres clases distintas:

#nota[Se entiende por módulo lo que se construye y se verifica por separado.]

- *Subsistemas*, que son las partes del equipo: firmware, detección, captura, aplicación central, interfaz gráfica, placas y carcaza.

- *Librerías*, creadas como utilidades fundamentales para el sistema: el protocolo de comunicación y el driver del motor.

- *Compartidos*, que contienen aquello que varios módulos tienen en común dentro del código fuente.

Un solo repositorio y no uno por módulo, porque la sinergia vive en las interfaces. El protocolo entre la PC y el microcontrolador se declara en un único archivo compartido que las dos puntas compilan: un cambio ahí las toca a las dos en el mismo commit, una sola corrida de verificación lo comprueba, y una única versión describe al sistema entero.

Las librerías quedan al mismo nivel y no dentro del subsistema que las usa, porque desde afuera no tienen cómo nombrarlo. La independencia queda forzada y no confiada a la disciplina de quien las edita.

=== Ramas y flujo de trabajo

El ciclo de vida de la sección anterior pide que cada iteración quede verificada y aislada antes de sumarle la siguiente. Esa es la función de las ramas, que acá son de tres clases.

Cada iteración se desarrolla en una *rama de subsistema*, nombrada por el que toca. Al terminarla se incorpora a la *rama de integración*, que exige que las pruebas unitarias pasen. La *línea principal* recibe a la rama de integración solo cuando además pasan las pruebas que cruzan subsistemas, y es sobre ella que se etiquetan las versiones.

Esa escala intermedia existe porque mientras un subsistema está a medio construir, las pruebas que lo cruzan con otro no pueden pasar porque el otro extremo todavía no existe.

Cada incorporación se registra con un commit de unión, que marca el cierre de la iteración.

Los mensajes de commit siguen una convención que exige declarar el módulo afectado y un asunto breve. Ante una regresión una historia con mensajes uniformes se puede filtrar para responderla mientras que una historia con mensajes libres no.

=== Esquema de versionado

Decir "la versión del sistema" puede ser ambiguo si no se aclara primero que dimensión se está atacando.

La *versión del sistema* es una etiqueta sobre la línea principal, con el esquema mayor, menor y corrección. Es lo que cobra el argumento del monorepo: un único número que designa un firmware, un software, unas placas y unas piezas mecánicas que se probaron juntos.

La *versión de la interfaz* entre la PC y el microcontrolador es un número propio, transportado por el protocolo mismo. Hace falta porque el firmware no corre desde el repositorio sino desde la memoria del microcontrolador, y ahí puede estar atrasado. Por eso informa qué versión habla, y la aplicación central se niega a operar si no coincide con la suya. Ese número solo se incrementa al llegar a la rama principal.

La *versión del entorno* es el archivo de fijación de dependencias descrito en la sección siguiente. No se elige ni se incrementa a mano: se actualiza cuando se decide mover la cadena de herramientas, y queda registrada en el repositorio como un cambio más.

== Reproducibilidad del entorno

Las dependencias de compilación no se documentan como instrucciones a seguir, se declaran de forma ejecutable y con las versiones fijadas. Así la cadena de herramientas que compila el proyecto se obtiene en un paso, y es la misma en cualquier máquina y en cualquier momento.

La herramienta que ejecuta esa declaración es Nix. #nota[Nix es un lenguaje declarativo y el gestor de paquetes que lo evalúa. Cada resultado vive en una ruta derivada del hash de sus entradas, así una dependencia no declarada hace fallar la construcción en vez de tomarse de la máquina. Su interfaz son los *flakes*, que fijan las entradas y exponen salidas con nombre: un paquete, un entorno de trabajo o una batería de comprobaciones @nix-dev.] Cada módulo declara qué necesita para compilarse, y un archivo de bloqueo fija la revisión exacta de cada dependencia, hasta la del compilador. Nada de eso se instala en el sistema: lo construido o descargado queda en un almacén aparte, y entrar al entorno de un módulo solo pone esas rutas al alcance de esa terminal. De esta forma, pueden convivir librerías que de otra manera se pisarían, y un cambio de versión de una dependencia no rompe nada que no lo haya declarado.

Todas las declaraciones apuntan a una fijación única en la raíz del repositorio, de modo que una sola revisión describe la cadena de herramientas del proyecto entero. Eso es la versión del entorno de la sección anterior, y se versiona como cualquier otro archivo.

La declaración, eso sí, está limitada aguas arriba: dice cómo reconstruir el entorno a partir de fuentes que se descargan. La reconstrucción es exacta mientras esas fuentes sigan disponibles.

#pendiente[Definir la entrega de artefactos ejecutables para su archivo, como resguardo ante la eventual indisponibilidad de las fuentes externas. Evaluar, por cada versión etiquetada: exportar la clausura del entorno de compilación a un almacén local, archivar los artefactos derivados (binario del firmware, archivos de fabricación de las placas, mallas de las piezas, PDF de la documentación) y publicar una imagen de máquina virtual con el entorno de desarrollo completo. Conviene distinguir dos resguardos con propósitos distintos: el de desarrollo, que debe permitir recompilar y modificar el sistema, y el de producción, que debe permitir volver a poner el equipo en operación sin compilar nada.]

== Lenguajes y herramientas

Todo lo que define al sistema se escribe en un lenguaje y se versiona, incluso aquello que no suele pensarse como programa. De ahí salen tres lenguajes, y conviene separarlos por lo que definen.

Dos describen lo que el sistema hace. C para el firmware, donde importa el determinismo temporal, el rendimiento y el tamaño del binario; Python para todo lo que corre en la PC, donde importa la versatilidad del ecosistema y la rapidez de desarrollo.

El tercero describe cómo se construye. Nix es el lenguaje en que está escrita la declaración de entorno de la sección anterior, y su presencia acá es clave: la cadena de herramientas dejó de ser un procedimiento que alguien sigue y pasó a ser un archivo fuente del proyecto, sujeto a las mismas revisiones y al mismo historial que el resto.

Los modelos mecánicos y los planos mantienen esa regla, porque se definen por código en Python con `build123d` @build123d, una librería capaz de describir CAD en este lenguaje. Una pieza es un programa que se ejecuta y produce su geometría, así que una cota se cambia editando un parámetro y el resultado se regenera.

Las placas son el caso donde la regla no se mantiene. Se diseñan con KiCad @kicad, cuyos archivos de esquemático y de ruteo son texto y se versionan bien, pero no se escriben sino que se editan con una herramienta gráfica. El diseño de KiCad es la fuente, y los archivos que se le mandan al fabricante
(Gerber de cada capa y taladrado), son su salida: se regeneran desde el diseño y no se editan a mano.

== Estrategia de pruebas

Todo el sistema queda alcanzado por pruebas automatizadas, organizadas en tres niveles según qué necesitan para correr.

#figure(
  tabla(
    columnas: (auto, 1fr, 26mm),
    cabecera: ("Nivel", "Qué verifica", "Dónde corre"),
    [Unitarias],
    [Cada unidad contra su contrato, en aislamiento. En el firmware esto es posible porque las librerías declaran sus dependencias de periférico como contratos de puntero a función, de modo que se compilan y se ejercitan contra implementaciones falsas.],
    [PC, automática y sin dependencia entre módulos.],

    [Integración],
    [Las interfaces entre módulos. Dos casos concretos: los algoritmos de detección se ejercitan contra un dataset de referencia con desplazamientos conocidos, y la comunicación entre el firmware y el cliente RPC de la PC se verifica por ida y vuelta, comprobando que un mensaje construido por una punta y luego interpretado por la otra devuelve exactamente lo que se le puso.],
    [PC, automática y con dependencia entre módulos.],

    [Banco/HIL],
    [El comportamiento con hardware presente: que los pulsos muevan el motor, que el driver conteste por el bus, que la cámara dispare. No se puede automatizar sin el equipo conectado (Hardware-in-the-loop).],
    [Laboratorio, manual y con dependencia entre módulos y del hardware real.],
  ),
  kind: table,
  caption: [Niveles de prueba y qué requiere cada uno para ejecutarse.],
) <tbl-niveles-prueba>

La distinción entre los dos primeros niveles y el tercero es importante: hay comportamiento que solo se comprueba con el equipo enchufado, y afirmar una cobertura automatizada total sería falso. Lo que sí se logra es que la mayor parte de la lógica sea verificable sin hardware, y eso es lo que permite que cada cambio se pruebe antes de llegar al laboratorio.

El dataset de referencia de detección es en sí mismo un artefacto versionado del proyecto, con el material anotado y su desplazamiento verdadero registrado, porque sin un valor de referencia no hay forma de medir el error de un algoritmo de centrado.

== Automatización de la verificación

El conjunto de comprobaciones se declara como una salida más del entorno reproducible, quedando entonces una sola orden, con sus herramientas fijadas, que produce el mismo resultado en cualquier máquina. #nota[Todo esto corre en la máquina de desarrollo, lo que evita atarse a la disponibilidad y al precio de un servidor. Nix vuelve viable esa elección, porque trae fijadas sus propias herramientas.]

Esa orden se engancha en los tres tipos de rama de 4.2.2, y cada uno exige lo que a esa altura tiene sentido exigir.

+ *Al registrar un cambio* corre lo barato, ya que los commits son frecuentes: formato y análisis estático sobre los archivos modificados, y validación del mensaje del commit contra la convención.
+ *Al incorporar una rama de subsistema a la de integración* se compila el firmware y/o el software y se ejecutan las pruebas unitarias. Es todo lo que se le puede pedir a un subsistema terminado sin depender de que los demás lo estén.
+ *Al incorporar la rama de integración a la principal* se suman las pruebas que cruzan subsistemas y la regeneración de la documentación derivada del código. Si algo falla, la línea principal no avanza.

La regresión es el objetivo de fondo. En un sistema donde el transporte, la detección y la captura se coordinan, un ajuste en cualquiera de los tres puede degradar a otro, por lo que una batería de pruebas automática prevee esto.

Este capítulo declara qué se verifica y cuándo. Cómo está implementado, qué herramienta corre cada comprobación y cómo se engancha al control de versiones, se trata en el capítulo 5.

== Seguridad de operación y detección de fallas

El material es único y el sistema lo transporta mecánicamente, así que la detección de fallas no es una característica agregada al final: es una condición de diseño desde el principio. Se adoptan cuatro mecanismos.

- *Corte de la etapa de potencia.* La parada urgente consiste en quitarle la habilitación al driver.

- *Enlace supervisado por temporizador.* Un movimiento iniciado desde la PC en el equipo de transporte sobrevive a la llamada que lo inició. Si el orquestador se cae o el cable se desconecta, se debe detectar al hombre muerto, exigiendo que se manden pulsaciones, para que un silencio detenga el avance. El temporizador se arma solo cuando hay movimiento, de modo que un equipo quieto puede quedar horas sin recibir órdenes.
#pendiente[Rehacer]

- *Corroboración cruzada entre subsistemas.* Es el mecanismo más valioso. El transporte informa cuántos pulsos emitió, que es una estimación de cuánto avanzó la película, mientras que la detección observa la película y mide dónde está el fotograma. Son dos estimaciones independientes de la misma magnitud física, y su desacuerdo es información: si el transporte dice que se movió y la imagen no cambió, hay pérdida de pasos, un atasco o un patinamiento; si la imagen se corre cuando no se ordenó ningún movimiento, hay arrastre o una orden espuria. El orquestador vigila esa coherencia y detiene el ciclo cuando se rompe. Es también lo que permite cerrar un lazo sobre un motor que por sí solo no mide nada, cuestión que el capítulo 2 plantea como problema abierto.
#pendiente[Ver si es fehacible]

- *Detención y reporte ante anomalía.* Consistente con el alcance declarado en 1.3, frente a una condición anómala el sistema interrumpe el avance y registra el punto exacto en que ocurrió, en lugar de intentar recuperarse por su cuenta. Sobre copias únicas, un reintento automático mal juzgado puede costar el rollo, mientras que una detención cuesta minutos de operador.

A esto se suma que el propio driver reporta sus condiciones de falla, tanto por una línea dedicada como por sus registros de estado, de modo que el firmware puede distinguir una falla eléctrica o térmica de un problema mecánico.

#pendiente[Definir si además de la parada por software hay un corte físico de potencia accesible al operador, independiente del firmware. Si existe, se declara acá y entra en el capítulo 6.]

== Métricas de calidad

El desempeño no se evalúa por impresión sino contra magnitudes declaradas de antemano. Cada una se mide sobre material real y se reporta en el capítulo 13.

#figure(
  tabla(
    columnas: (auto, 1fr),
    cabecera: ("Métrica", "Cómo se obtiene"),
    [Error de centrado], [Desviación del fotograma respecto del encuadre objetivo, contra el valor de referencia del dataset anotado.],
    [Cadencia de captura], [Fotogramas por unidad de tiempo en operación sostenida, comparable de forma directa contra los 2 s por fotograma del proceso manual.],
    [Tasa de éxito], [Proporción de fotogramas capturados correctamente sobre el dataset.],
    [Manejo de excepciones], [Comportamiento observado ante material dañado: cuántas anomalías se detectan, cuántas terminan en detención y cuántas pasan inadvertidas.],
    [Integridad del material], [Estado de la película antes y después del procesamiento, para verificar que el transporte no introduce daño.],
  ),
  kind: table,
  caption: [Métricas de calidad y su forma de obtención.],
) <tbl-metricas>

#pendiente[Evaluar incorporar cobertura de código como métrica de calidad del proceso, medida por la verificación automática sobre los dos primeros niveles de prueba. Si se adopta, hay que fijar el umbral y aclarar que mide el alcance de las pruebas y no la corrección del sistema.]

== Gestión de riesgos

Los riesgos se identifican al inicio y se les asigna una mitigación concreta, de modo que aparezcan en el diseño y no como una sorpresa durante la validación.

#figure(
  tabla(
    columnas: (1fr, 1fr),
    cabecera: ("Riesgo", "Mitigación"),
    [Latencia y variabilidad de la red en el control de la cámara.],
    [Medición temprana de los tiempos de respuesta, y un ciclo que no asuma latencia constante ni respuestas inmediatas.],

    [Vibración mecánica que degrade el encuadre en el momento de la captura.],
    [Perfiles de movimiento con rampas de aceleración y frenado, y verificación de que el disparo ocurra con el mecanismo detenido. Corrección de derivas perpendiculares al movimiento en el algoritmo de centrado.],

    [Desgaste de la tracción y de las superficies en contacto con la película.],
    [Piezas de contacto identificadas como consumibles, en lo posible reimprimibles a partir de su definición paramétrica.],

    [Daño irreversible sobre material único.],
    [Los cuatro mecanismos de la sección anterior, y el acondicionamiento previo del material a cargo del equipo de archivistas.],

    [Pérdida de sincronismo del motor sin aviso, por ser un mecanismo de lazo abierto.],
    [Corroboración cruzada contra la medición de la detección, y monitoreo de las condiciones que informa el driver.],
  ),
  kind: table,
  caption: [Riesgos identificados y mitigaciones adoptadas.],
) <tbl-riesgos>

== Filosofía abierta

El proyecto es de código y hardware abiertos, y la documentación forma parte del entregable en el mismo nivel que el código. Esa decisión es instrumental: un sistema cuyo diseño se puede leer, cuyo entorno de compilación se puede reconstruir y cuyas piezas se pueden volver a fabricar es un sistema que la institución puede mantener sin depender de un proveedor. Es la única propiedad que garantiza que este equipo no termine como el que reemplaza.

#pendiente[Definir la licencia del proyecto según lo que establezca la reglamentación de la facultad sobre propiedad intelectual de los trabajos finales. Conviene decidirlo antes de publicar el repositorio, y tener en cuenta que el software y el hardware suelen requerir licencias distintas, ya que una licencia de software no cubre correctamente esquemáticos ni piezas físicas.]