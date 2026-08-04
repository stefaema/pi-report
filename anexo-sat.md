# Anexo

## Contexto y motivación

El Centro de Conservación y Documentación Audiovisual (CDA) de la UNC resguarda material fílmico en los calibres de 16 mm y 35 mm desde la década de 1940. Ese patrimonio enfrenta una degradación química continua e irreversible, y la única vía que garantiza su permanencia es la digitalización.

El flujo de trabajo actual es estrictamente manual y muy poco ergonómico, con una cadencia de 2 segundos por fotograma que hace inviable procesar el acervo a un ritmo sostenible. El telecine original de 16 mm está fuera de servicio por obsolescencia, roturas y falta de repuestos, lo que dejó paralizada la digitalización de ese segmento del acervo. Su reemplazo directo es indeseable, porque depende de tecnología propietaria extranjera de alto costo sobre la cual la institución no tiene control alguno.

## Objetivo

Diseñar, construir e implementar un sistema mecatrónico modular y de código abierto para el transporte, la detección y la captura automatizados de material fílmico en 16 mm y 35 mm, que reemplace la tracción y el centrado manuales por control de motores y visión por computadora, integrando como medio de captura las cámaras Canon de las que el laboratorio ya dispone.

## Requerimientos

| ID | Requerimiento |
| --- | --- |
| **R01** | El sistema debe disparar automáticamente el obturador de la cámara cuando un fotograma se encuentre centrado. |
| **R02** | El sistema debe monitorear la temperatura que informa la cámara y suspender la captura cuando supere un umbral configurable, para no reducir su vida útil. |
| **R03** | El sistema debe centrar un fotograma mediante un mecanismo de detección y un mecanismo de transporte del material fílmico. |
| **R04** | El sistema debe implementar el mecanismo de detección de modo que se adapte al estado típico de los filmes, bajo diversas condiciones de deterioro físico y dimensional. |
| **R05** | El sistema debe implementar el mecanismo de transporte de modo que afecte lo menos posible la integridad del material fílmico. |
| **R06** | El sistema debe ser modular. |
| **R07** | El sistema debe ser fácil de mantener y utilizar componentes fácilmente reemplazables. |
| **R08** | El sistema debe proveer una interfaz gráfica que permita al operador configurar, iniciar, detener y monitorear la digitalización. |
| **R09** | El sistema debe estar documentado de forma que garantice la longevidad del proyecto a largo plazo. |
| **R10** | El sistema debe utilizar herramientas propias o de origen abierto siempre que sea posible. |
| **R11** | El sistema debe superar la capacidad del proceso manual, optimizando la cadencia de procesamiento, reduciendo la fatiga operativa y extendiendo los intervalos de autonomía del equipo. |
| **R12** | El sistema debe entregar capturas que incluyan el área marginal del filme, con las perforaciones y la pista de sonido óptico dentro del encuadre. |
| **R13** | El sistema debe registrar, por fotograma, el resultado del centrado y la cuenta de avance del transporte. |

Cada requerimiento declara en el informe su origen, su tipo y el medio con el que se lo dará por cumplido, de modo que la validación final del capítulo de resultados se hace contra esa misma tabla y no contra criterios definidos a posteriori.

## Arquitectura del sistema propuesto

La solución es un sistema mecatrónico bajo una arquitectura de software modular, con desacoplamiento entre el control de hardware y la lógica de aplicación. Se organiza sobre tres funciones, que son las que estructuran tanto el desarrollo como el informe: **transporte**, **detección** y **captura**.

Se compone de cinco módulos:

- **Transporte y capa de abstracción de hardware.** Firmware sobre un sistema operativo de tiempo real que gobierna los motores paso a paso del capstan y de los platos alimentador y receptor. La PC envía órdenes de alto nivel al microcontrolador mediante llamadas a procedimientos remotos, y el microcontrolador las traduce en datagramas serie hacia los drivers y en señales de temporización.
- **Módulo de visión artificial.** Detección y centrado de fotogramas mediante un algoritmo propio de correlación cruzada sobre regiones de interés, con algoritmos de apoyo y heurísticas de votación cuyo método óptimo se determina por análisis y evaluación comparativa sobre datasets de referencia.
- **Cliente de la API REST de la cámara.** Control inalámbrico de la captura sobre la Canon Camera Control API: configuración, disparo, estado y descarga.
- **Aplicación central.** Orquesta transporte, detección y captura, y produce el registro por fotograma que exige R13.
- **Hardware a medida.** Placas de driver, placa concentradora (carrier board), gabinetes y piezas mecánicas impresas en 3D, definidas de forma paramétrica.

## Metodología de desarrollo y validación

El proyecto adopta un enfoque de ingeniería de software mediante un ciclo de vida iterativo e incremental, con las siguientes prácticas:

- **Gestión de configuración.** Repositorio distribuido y pipelines de integración continua que garantizan compilaciones reproducibles, análisis estático de código y ejecución de pruebas de regresión.
- **Estrategia de testing.** Pruebas unitarias sobre los algoritmos de visión con datasets de referencia, pruebas unitarias sobre las bibliotecas de control, y pruebas de integración para la comunicación entre módulos.
- **Validación hardware-in-the-loop.** Simulación de variables de entorno para verificar sincronización temporal, latencias y tolerancia a fallos mecánicos entre el software y la electrónica.
- **Métricas de calidad.** Evaluación sobre material real según tolerancia máxima de error de centrado, cadencia de captura, tasa de éxito y manejo de excepciones sobre filme dañado.
- **Gestión de riesgos.** Identificación y mitigación de variables críticas como la latencia de red en la comunicación con la cámara, las vibraciones mecánicas y el desgaste de la tracción.
- **Filosofía abierta.** El proyecto es enteramente de código y hardware abiertos, y está documentado de forma extensiva para asegurar su reproducibilidad y su mejora.

## Estructuración de la documentación técnica

La estructura documental se define desde el inicio del proyecto y se completa a medida que avanzan las etapas: el índice completo existe, con cada sección creada y con su alcance declarado, de manera que el estado de avance es verificable en cualquier momento sin depender de un informe de situación.

### Estructura del informe

| Parte | Capítulo | Estado y alcance |
| --- | --- | --- |
| I. Planteo | 1. Introducción | Redactado. Situación del acervo y del laboratorio, cese del telecine comercial y reemplazo manual subóptimo, objetivos, y frontera del proyecto: qué queda adentro del PI, qué del lado del CDA y bajo qué condiciones se evalúa. |
| | 2. Marco teórico | Parcial. Conservación y geometría del filme, transporte, detección, captura y estado del arte. Fija en un solo lugar la transferencia de dominio del mundo archivista al de ingeniería, y termina en piezas genéricas a diseñar: los diseños e implementación se desarrollan después. |
| | 3. Elicitación | Redactado. Problemáticas relevadas en el laboratorio, restricciones que impone el equipamiento existente, y los trece requerimientos con su tipo, su origen y su medio de verificación. |
| | 4. Metodología | Estructura definida. Ciclo de vida, gestión de configuración, estrategia de testing, métricas de calidad, gestión de riesgos y filosofía abierta, con el detalle de cómo se verifica cada una. Todo a nivel diseño. |
| II. Desarrollo | 5. Arquitectura general | Estructura definida. Mapa de los capítulos 6 a 12: qué subsistema resuelve qué, con qué tecnología y con qué interfaz habla con los demás. Habla también de decisiones concretas de cómo se implementó el capítulo 4. |
| | 6. Hardware y placas | Estructura definida. Elección del driver frente a alternativas, placas de driver, placa concentradora, bus compartido y distribución de alimentación. |
| | 7. Armazón, modelos 3D y planos | Estructura definida. Rodillos capstan y de tensión, disposición óptica y mecánica del dispositivo, y gabinetes de sus módulos. Todo definido de forma paramétrica en código. |
| | 8. Firmware | Redactado. Firmware del microcontrolador: capa de abstracción sobre el driver, generación de temporización, control de líneas y atención del enlace de procedimientos remotos con la PC. |
| | 9. Detección | Estructura definida. Algoritmo de centrado por correlación cruzada, dataset de referencia, algoritmos de apoyo y comparativa entre ellos sobre material del acervo. |
| | 10. Captura | Estructura definida. Cliente propio sobre la interfaz de la cámara: arquitectura en capas, control de disparo, configuración y monitoreo de estado. |
| | 11. Interfaz de operación | Estructura definida. Interfaz gráfica con la que el operador configura, inicia, detiene y monitorea la digitalización, y su validación de experiencia de uso. |
| | 12. Aplicación central | Estructura definida. El orquestador que coordina transporte, detección y captura, decide el disparo y produce el registro por fotograma, dándole acceso de seguimiento a la interfaz gráfica. Cierra el desarrollo. |
| III. Cierre | 13. Resultados | Estructura definida. Validación de integración sobre material real, situación final del dispositivo y las métricas declaradas en el capítulo 3: error de centrado, cadencia contra la línea de base manual, tasa de éxito y manejo de excepciones. |
| | 14. Conclusiones | Estructura definida. Cierre contra los objetivos del capítulo 1, uno por uno, y trabajo futuro. |
| Anexos | A. Manual de Operación del Digitalizador | Pendiente. Consiste en un manual para que un operario pueda entender como operar el dispositivo, con troubleshooting básico y mantenimiento/reparación. |
| | B. CCAPI | Pendiente, contenido preliminar existente por las PPS. Consiste en un manual de como funciona Canon Camera Control API en general y en particular, para poder justificar la existencia y el diseño del cliente y poder ofrecerle a un equipo de desarrollo futuro herramientas para mejorar el cliente sin tener que solicitarle nuevamente el acceso al equipo de desarrollo de Canon. |
| | C. Documentación derivada del código y artefactos de fabricación | Estructura definida, será generado automáticamente por CI/CD. |

### Mecanismos de trazabilidad

Tres mecanismos sostienen que lo anterior sea auditable y no declarativo:

1. **Repositorio distribuido con integración continua.** Cada cambio queda registrado con su autoría y su motivo. El pipeline ejecuta compilación reproducible, análisis estático y pruebas de regresión, y los ganchos de repositorio impiden incorporar cambios que no pasen esas verificaciones.
2. **Documentación derivada del código.** La referencia de API se genera desde el propio código, lo que evita que la documentación y la implementación se separen con el tiempo.
3. **Trazabilidad de requerimientos.** Cada requerimiento declara la problemática que lo origina y el medio con que se verifica su cumplimiento, y el capítulo de resultados reporta contra esa misma tabla.

## Estado actual del proyecto

Dado que la integridad del material se degrada de forma continua e irreversible, se avanzó con el desarrollo antes de la aprobación formal del tema. A la fecha existe:

- La documentación de la CCAPI, redactada a modo preliminar durante la práctica profesional supervisada. Requiere refactorización.
- Las bibliotecas de control del driver y del enlace de comunicación RPC, implementadas, con pruebas unitarias y verificación automática en integración continua y pruebas en Hardware.
- El firmware del microcontrolador con la capa de abstracción sobre el driver y el enlace de procedimientos remotos hacia la PC, a nivel preliminar. Falta especificar los procedimientos de alto nivel, que a su vez requieren que el resto de subsistemas esté funcional.
- Un cliente de la CCAPI funcional como prueba de concepto, con control remoto del disparo verificado sobre la cámara del laboratorio. Requiere refinación de API.
- Un prototipo de detección por correlación cruzada, evaluado sobre material deteriorado real, que devuelve desplazamiento y confianza. Falta el sistema de votación y un mejor dataset.
- Prototipos mecánicos iniciales modelados en 3D: gabinete de una fuente conmutada y rodillo capstan. Ambos modelos son prototipos que requieren cambios.
- El informe con su estructura completa definida, sus tres primeros capítulos redactados.
