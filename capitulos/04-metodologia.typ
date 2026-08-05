#import "../plantilla/bloques.typ": pendiente, nota, tabla

= Metodología

La metodología de este proyecto es el conjunto de procedimientos que responden a los requerimientos de modularidad (R06), documentación (R07) y capacidad de mantenimiento (R09).

Lo que sigue declara qué se le exige al proceso de trabajo: cómo se organiza, cómo se verifica y qué se hace cuando algo falla. Las herramientas concretas que satisfacen cada una de esas exigencias se tratan en la parte II, junto con el resto de las decisiones de implementación. La separación es deliberada: una exigencia metodológica sobrevive al cambio de la herramienta que hoy la cumple, y mezclarlas haría que reemplazar una herramienta pareciera un cambio de método.

== Ciclo de vida en desarrollo

El desarrollo adopta un ciclo de vida iterativo e incremental. Cada iteración toma un subsistema, lo lleva de una prueba de concepto a una versión integrable, y lo deja verificado antes de sumarle el siguiente. Las tres pruebas de concepto del capítulo 3 son la primera iteración de ese ciclo, y su función fue reducir el riesgo de comprometer requerimientos sin saber si eran alcanzables.

== Control de versiones

El sistema tiene distintas partes. Ninguna sirve por separado, porque el digitalizador es sinergia. Esta sección responde tres preguntas que de otro modo quedan implícitas: dónde vive el código, dónde se hace el trabajo a medio terminar, y qué significa exactamente "la versión del sistema".

=== Organización del repositorio

Todo el proyecto vive en un único repositorio, con una carpeta por módulo, de tres clases distintas:

#nota[Se entiende por módulo lo que se construye y se verifica por separado.]

- *Subsistemas*, que son las partes del equipo: firmware, transporte, detección, captura, aplicación central, interfaz gráfica, ccapi, placas y carcaza.

- *Librerías*, creadas como utilidades fundamentales para el sistema: el protocolo de comunicación y el driver del motor.

- *Compartidos*, que contienen aquello que varios módulos tienen en común dentro del código fuente.

Un solo repositorio y no uno por módulo, porque la sinergia vive en las interfaces. El protocolo entre la PC y el microcontrolador se declara en un único archivo compartido que las dos puntas compilan: un cambio ahí las toca a las dos en el mismo commit, una sola corrida de verificación lo comprueba, y una única versión describe al sistema entero.

Las librerías quedan al mismo nivel y no dentro del subsistema que las usa, porque desde afuera no tienen cómo nombrarlo. La independencia queda forzada y no confiada a la disciplina de quien las edita.

=== Aislamiento del trabajo en curso

El ciclo de vida pide que cada iteración quede verificada y aislada antes de sumarle la siguiente, y eso exige tres grados de madurez distintos y no dos.
#nota[En la parte de desarrollo esta sección se traducirá en el sistema de ramas de Git utilizado.]

Hace falta un espacio donde un subsistema pueda estar a medio construir sin romper nada, otro donde los subsistemas terminados convivan aunque el sistema completo todavía no cierre, y un tercero que solo reciba lo que pasó todas las comprobaciones y sobre el que se etiquetan las versiones. 

=== Esquema de versionado

Decir "la versión del sistema" puede ser ambiguo si no se aclara primero qué dimensión se está atacando. Son tres, y cada una responde a una pregunta distinta.

La *versión del sistema* designa un conjunto de firmware, software, placas y piezas mecánicas que se probaron juntos. Es lo que cobra el argumento del repositorio único: un solo número describe un equipo completo y verificado.


La *versión del entorno* identifica la cadena de herramientas con la que el proyecto se construye. No se elige ni se incrementa a mano: cambia cuando se decide mover esa cadena, y queda registrada en el repositorio como un cambio más.

#pendiente[ver lo de version de interfaces cuando ya esté andando todo]
== Reproducibilidad del entorno

Las dependencias de compilación no se documentan como instrucciones a seguir, se declaran de forma ejecutable y con las versiones fijadas. Así la cadena de herramientas que compila el proyecto se obtiene en un paso, y es la misma en cualquier máquina y en cualquier momento.

De esa exigencia se desprenden tres condiciones. Cada módulo tiene que declarar qué necesita para compilarse, hasta la versión del compilador, de modo que una dependencia no declarada haga fallar la construcción en lugar de tomarse en silencio de la máquina de quien compila. Las declaraciones de todos los módulos tienen que apuntar a una fijación única, para que una sola revisión describa la cadena de herramientas del proyecto entero. Y el entorno de un módulo no puede instalarse en el sistema anfitrión, porque módulos distintos necesitan versiones que de otro modo se pisarían.

La declaración, eso sí, está limitada aguas arriba: dice cómo reconstruir el entorno a partir de fuentes que se descargan, y la reconstrucción es exacta mientras esas fuentes sigan disponibles. Por eso la reproducibilidad declarativa no alcanza por sí sola, y el proyecto tiene que producir además artefactos archivables por cada versión etiquetada. Son dos resguardos con propósitos distintos: uno de desarrollo, que debe permitir recompilar y modificar el sistema sin depender de que las fuentes externas sigan en línea, y uno de producción, que debe permitir volver a poner el equipo en operación sin compilar nada.

== Todo lo que define al sistema es código

Todo lo que define al sistema se escribe en un lenguaje y se versiona, incluso aquello que no suele pensarse como programa. La regla separa dos clases de artefacto.

Están los que describen *lo que el sistema hace*, y ahí la elección de lenguaje responde a lo que cada lado exige: determinismo temporal, rendimiento y tamaño del binario del lado del microcontrolador; versatilidad del ecosistema y rapidez de desarrollo del lado de la PC.

Y están los que describen *cómo se construye el sistema*. Que la cadena de herramientas se declare en un lenguaje, y no en un instructivo, es lo que la convierte en un archivo fuente del proyecto, sujeto a las mismas revisiones y al mismo historial que el resto.

La regla se extiende a los artefactos que tradicionalmente quedan fuera del control de versiones. Los modelos mecánicos y los planos se definen por código, de modo que una pieza es un programa que se ejecuta y produce su geometría, y una cota se cambia editando un parámetro y regenerando el resultado.

Las placas son el caso donde la regla no se sostiene del todo, y conviene declararlo en lugar de disimularlo. Su diseño se edita con una herramienta gráfica, aunque los archivos resultantes sean texto y se versionen bien.

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

El conjunto de comprobaciones se declara como una salida más del entorno reproducible. De ahí que verificar el proyecto sea una sola orden, con sus herramientas fijadas, que produce el mismo resultado en cualquier máquina.

Esa orden se engancha en los tres grados de madurez de 4.2.2, y cada uno exige lo que a esa altura tiene sentido exigir.

+ *Al registrar un cambio* corre lo barato, ya que los commits son frecuentes: formato y análisis estático sobre los archivos modificados, y validación del mensaje del commit contra la convención.
+ *Al integrar un subsistema terminado* se compila y se ejecutan las pruebas unitarias. Es todo lo que se le puede pedir a un subsistema sin depender de que los demás estén listos.
+ *Al promover el sistema completo* se suman las pruebas que cruzan subsistemas y la regeneración de la documentación derivada del código. Si algo falla, la versión no avanza.

La regresión es el objetivo de fondo. En un sistema donde el transporte, la detección y la captura se coordinan, un ajuste en cualquiera de los tres puede degradar a otro, y una batería de pruebas automática es lo que lo advierte a tiempo.

Este capítulo declara qué se verifica y cuándo. Con qué herramientas, y cómo se engancha cada comprobación al control de versiones, se trata en el capítulo 5.

== Seguridad de operación y detección de fallas

El material es único y el sistema lo transporta mecánicamente, así que la detección de fallas no es una característica agregada al final: es una condición de diseño desde el principio. Se adoptan cuatro mecanismos.

- *Corte de la etapa de potencia.* La parada urgente consiste en quitarle la habilitación al driver.

- *Enlace supervisado por temporizador.* Un movimiento iniciado desde la PC sobrevive a la llamada que lo inició, así que el equipo tiene que poder distinguir entre un orquestador que sigue vivo y uno que se cayó. La ausencia de señal durante un movimiento en curso debe detener el avance, y la supervisión solo puede estar activa mientras haya movimiento, de modo que un equipo quieto pueda quedar horas sin recibir órdenes.

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

#pendiente[*Deuda hacia la parte II.* Este capítulo quedó como planteo puro: declara qué se le exige al proceso y no con qué se cumple. Todo lo concreto que se sacó tiene que aparecer en la parte II, en "Arquitectura de desarrollo" (5.2) o en un capítulo propio si crece demasiado. La lista de lo que hay que ubicar allá:

- *Reproducibilidad (4.3).* Nix como lenguaje y gestor que ejecuta la declaración, los flakes y sus salidas con nombre, el archivo de bloqueo, el almacén aparte y la fijación única en la raíz. Y los artefactos archivables por versión: exportación de la clausura del entorno, binario del firmware, archivos de fabricación de las placas, mallas de las piezas, PDF de la documentación, e imágenes de máquina virtual o de contenedor para el resguardo de desarrollo y el de producción.
- *Lenguajes (4.4).* C para el firmware y Python para la PC, con su justificación; Nix como lenguaje de construcción; `build123d` para los modelos mecánicos; KiCad para las placas, con la distinción entre el diseño como fuente y los Gerber y taladrado como derivados.
- *Documentación (4.9).* La herramienta que genera la documentación derivada del código, que hoy el capítulo menciona sin nombrar.
- *Aislamiento del trabajo (4.2.2).* Los nombres concretos de las tres ramas, el flujo de incorporación y la convención de mensajes de commit.
- *Versionado (4.2.3).* El esquema mayor, menor y corrección, y el mecanismo por el que la versión de interfaz se incrementa al llegar a la rama principal.
- *Verificación (4.6).* El corredor único de comprobaciones, cómo descubre los módulos, qué herramienta corre cada nivel de prueba, y los enganches al control de versiones con su instalación al activar el entorno.]
