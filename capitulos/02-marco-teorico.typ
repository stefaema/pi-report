#import "../plantilla/bloques.typ": pendiente, nota, tabla, figura-pendiente

= Marco teórico

== Digitalización y conservación de filmes

El filme cinematográfico es una tira flexible formada por un material de base plástico y transparente, y una emulsión fotosensible de gelatina adherida a él. La imagen y el sonido óptico viven en la emulsión, mientras que la base sostiene esa información y es lo que un sistema de transporte efectivamente manipula. Los calibres que le interesan a este proyecto, 16 mm y 35 mm, quedan definidos por el ancho de la tira y por las dimensiones y el paso de sus perforaciones.

A lo largo del siglo se usaron tres materiales de base, y la diferencia entre ellos determina en qué estado llega hoy el material al laboratorio. El *nitrato de celulosa*, empleado hasta comienzos de la década de 1950, es químicamente inestable y altamente inflamable. Los *acetatos de celulosa*, primero diacetato y luego triacetato, se comercializaron como "safety film" por su menor riesgo de combustión, que es una propiedad distinta de la estabilidad química: bajo condiciones de guarda corrientes, un triacetato considerado material de archivo puede iniciar su degradación en pocas décadas @nfpf-guide. El *poliéster*, introducido comercialmente hacia mediados de la década de 1950, es el primero que resulta estable en lo químico y en lo dimensional a largo plazo. El acervo del CDA es mayoritariamente acetato, que es la familia intermedia.

La forma característica en que se degrada el acetato es el *síndrome del vinagre*. La base de acetato se hidroliza, libera ácido acético, y es el olor de ese ácido lo que da nombre al fenómeno. #nota[Lo que vuelve grave al síndrome del vinagre es que la reacción es autocatalítica: el ácido liberado acelera la hidrólisis que lo produce. Una vez iniciada, la degradación no se detiene ni se revierte, solo se ralentiza bajando la temperatura y la humedad de guarda @nfpf-guide.] El Image Permanence Institute desarrolló para detectarlo las A-D Strips, tiras indicadoras de acidez que se guardan junto al filme y cambian de color sobre una escala de 0 a 3, donde cualquier lectura por encima de 0 ya indica degradación en curso @ipi-adstrips @nfpf-guide. Eso le permite a un archivo priorizar qué rollos digitalizar primero. Más allá del olor, los síntomas observables son el encogimiento de la base, la pérdida de flexibilidad y el enrulado, la emulsión cuarteada y un polvo blanco sobre los bordes @nfpf-guide. El primero es el que gobierna todo lo que sigue: el filme no llega al sistema con las dimensiones con las que fue fabricado.

#figura-pendiente(
  [Fotografía de material del propio acervo en distintos estados de conservación, sobre mesa de luz y con una escala en el encuadre. Debería mostrar, en lo posible en una sola toma comparativa: un rollo en buen estado, uno con encogimiento y deformación ondulada visibles, y una tira con perforaciones rasgadas o faltantes. Si el CDA usa A-D Strips, incluir una junto al rollo con su lectura visible.],
  caption: [Estados de conservación del acetato en el acervo del CDA.],
) <fig-deterioro>

=== Perforaciones y paso

Las perforaciones cumplen dos funciones a la vez: son el apoyo mecánico del transporte, sea por rueda dentada, garra o capstan, y son la referencia geométrica que permitía registrar cada fotograma en su posición. Su paso, la distancia entre dos perforaciones consecutivas, está normalizado por la Society of Motion Picture and Television Engineers (SMPTE) en dos variantes por calibre, y la razón de que sean dos ya es una consecuencia del encogimiento: el positivo se perfora con un paso 0,2 % más largo que el negativo del que se lo copia, para compensar lo que ese negativo se contrae durante el revelado y el almacenamiento previos @smpte-st102. Antes de cualquier deterioro, la geometría nominal del filme está calculada alrededor de una contracción esperada.

#figure(
  tabla(
    columnas: (auto, auto, auto, auto),
    cabecera: ("Calibre", "Perforación y uso", "Paso", "Norma"),
    [35 mm], [CS-1870, copias], [0,1870 ± 0,0004 in (4,750 ± 0,010 mm)], [SMPTE 102 @smpte-st102],
    [35 mm], [BH y KS, negativos e intermedios], [0,1866 in (4,740 mm)], [SMPTE 93 @smpte-93, SMPTE 139 @smpte-139],
    [16 mm], [1R-3000 y 2R-3000, copias], [0,3000 in (7,620 mm)], [SMPTE 109 @smpte-109],
    [16 mm], [1R-2994 y 2R-2994, negativos], [0,2994 in (7,605 mm)], [SMPTE 109 @smpte-109],
  ),
  kind: table,
  caption: [Pasos de perforación normalizados por calibre y variante. En ambos calibres la diferencia entre las dos variantes es de alrededor del 0,2 %, que es la contracción que la norma prevé para el negativo. El paso largo de 16 mm queda además corroborado por @smpte-rp74, que lo declara como el paso del filme sin encogimiento sobre el que calcula la geometría del diente.],
) <tbl-pasos>

#nota[Los códigos siguen el sistema de nomenclatura que SMPTE aplica a todas sus normas de dimensiones de filme: el título indica el ancho, luego un código de forma de perforación (BH, KS, DH o CS) o bien la cantidad de hileras (1R, 2R), según cuál sea el factor significativo en ese calibre, y por último el paso escrito sin la coma decimal @smpte-st102. Por eso el 35 mm se identifica por forma y el 16 mm por hileras.]

El 16 mm admite dos configuraciones de perforado, ambas en esa misma norma @smpte-109: en 2R hay una hilera a cada lado de la tira, y en 1R queda una sola, porque el borde liberado es donde corre la pista de sonido óptico. De ahí sale R12, que obliga a capturar ambos bordes para que el flujo de extracción de sonido del CDA siga teniendo con qué trabajar. Y de ahí sale una restricción más fina para el capítulo 9: un algoritmo que ubique el fotograma por las columnas donde aparecen las perforaciones no puede asumir cuántas hileras va a encontrar.

#figura-pendiente(
  [Fotografía a contraluz de tiras del acervo apoyadas sobre la misma mesa de luz y a la misma escala, con una regla en el encuadre: una de 35 mm y una de 16 mm, y dentro del 16 mm una tira de doble perforación junto a una de perforación simple. Tiene que dejarse ver el borde liberado de la tira 1R, que es donde corre la pista de sonido óptico.],
  caption: [Geometría comparada de 16 mm y 35 mm sobre material del acervo. El área marginal que se ve a los costados del fotograma es la que el requerimiento R12 obliga a mantener dentro del encuadre.],
) <fig-geometria>

Todas esas cifras describen filme nuevo, y las normas lo dicen explícitamente: rigen en el momento del corte y perforado, sobre filme acondicionado a 23 °C y 50 % de humedad relativa @smpte-st102. En un rollo que pasó décadas en un depósito el paso deja de ser constante y de ser conocido. Y lo que gobierna la estabilidad de la imagen no es la uniformidad entre un rollo y otro, sino la variación de una perforación a la siguiente dentro de un grupo pequeño de perforaciones consecutivas @smpte-st102: el error es local, no se cancela promediando ni se corrige con una constante por rollo, y de ahí que la Federal Agencies Digitization Guidelines Initiative (FADGI) exija medirlo sobre cada rollo en vez de deducirlo de la especificación nominal @fadgi-2016.

Cuánto margen admite el mecanismo tradicional está escrito en su propia norma de diseño. La práctica recomendada de SMPTE para ruedas dentadas de 16 mm calcula la geometría del diente sobre un paso nominal de 7,620 mm y le reserva a cada diente una holgura de deslizamiento que absorbe alrededor de 0,6 % de encogimiento, con 0,8 % como techo del rango: es el valor con el que se dimensiona la rueda de retención dentada y el que acota el arco de engrane admisible @smpte-rp74. #nota[RP 74 y SMPTE 242 están clasificadas por SMPTE como documentos Stable, es decir vigentes pero no representativos de la tecnología actual. Se las cita justamente por eso: el material tampoco es actual.]

La práctica archivística llega al mismo número por el otro camino. La guía de preservación de la National Film Preservation Foundation establece que una película de 16 mm encogida más de 0,8 % puede dañarse al proyectarse, que en 35 mm ese límite es 1 %, y que por encima de 2 % hasta un laboratorio especializado tiene dificultades para copiarla @nfpf-guide. La guía agrega que el encogimiento castiga más a los calibres chicos, por el fotograma más pequeño y la mayor precisión que le exigen al equipo, y el acervo del CDA es mayoritariamente 16 mm. #nota[No todo encogimiento viene de la degradación química: una guarda demasiado seca, con humedad relativa por debajo del 15 % de forma sostenida, también hace que el filme pierda agua, se contraiga y se vuelva quebradizo @nfpf-guide.]

El material que este sistema tiene que digitalizar es, por definición, el que ya está fuera de ese rango: si el archivo pudiera proyectarlo o copiarlo por medios convencionales de tracción en las perforaciones, no haría falta construir un sistema de detección.

=== Las funciones de un digitalizador

Un digitalizador de filme resuelve tres problemas de naturaleza distinta, y por eso el sistema se divide en tres subsistemas antes que en uno solo. El *transporte* mueve el filme sin dañarlo y sin asumir que su paso es fijo, y es un problema mecánico y de potencia. La *detección* establece, fotograma a fotograma, cuánto se desvía el encuadre del centro, y es un problema de medición sobre material cuya geometría no es confiable. La *captura* registra la imagen una vez que la detección la habilita, y es un problema óptico y de control remoto. Las secciones 2.2, 2.3 y 2.4 desarrollan cada una en ese orden, y los capítulos 8, 9 y 10 las implementan en el mismo.

La forma de coordinar las tres admite dos esquemas. En el *continuo*, el filme nunca se detiene y la captura se sincroniza con el movimiento, ya sea mediante un sensor lineal que compone la imagen a medida que la tira pasa, ya sea congelando el fotograma en movimiento con iluminación estroboscópica o con un obturador suficientemente rápido. En el *intermitente*, el transporte avanza, se detiene, la detección confirma el centrado y recién entonces se dispara. El continuo alcanza cadencias mayores y le exige al sistema un sincronismo fino y sostenido entre transporte y obturador. El intermitente tolera que el paso entre fotogramas varíe, porque cada avance se corrige contra lo que la detección midió en ese fotograma y no contra una distancia nominal.

== Transporte

De la sección anterior resultó descartado el arrastre por perforaciones, por lo que la primera pregunta es cómo mover material fílmico al que no se le puede tomar de sus agujeros. La alternativa es el arrastre por fricción: un rodillo capstan contacta con el filme (evitando la zona de emulsión) y lo hace avanzar por adherencia sobre la superficie de la base. El paso deja de importar, porque el mecanismo ya no busca calzar en ninguna geometría, y con él desaparece la carga sobre el borde de la perforación contra la que advierte la propia norma de diseño de ruedas dentadas @smpte-rp74.

El avance como tal es una de las tres funciones que el transporte cumple a la vez, y cada una tiene su elemento. El *capstan* impone el avance real. El *plato alimentador*, o de suministro, entrega filme desde el rollo de origen sin tironear. El *plato receptor* lo recoge en el rollo de destino sin dejarlo flojo. #nota[La literatura del área está casi toda en inglés, donde los tres son *capstan*, *feed reel* y *takeup reel*. Capstan se usa sin traducir.] En los tres casos, el vínculo entre lo que hace el motor y lo que le pasa al filme es un factor de conversión que no es constante. En los platos, la tensión es el par dividido por el radio, y el radio cambia a lo largo de la digitalización: a par constante, el filme se tensa cada vez más a medida que el rollo de origen se achica. En el capstan, cada vuelta entrega una longitud fija de filme, pero la longitud que hace falta para avanzar un fotograma es el paso del material, que encogió, de modo que el giro por fotograma es una propiedad variable en cada rollo. La distinción entre el elemento que hace avanzar el filme contra los elementos de suministro es estándar en la industria @smpte-242, y se traduce en tres puntos de actuación independientes.

Entre un plato y el otro el filme va hilado a lo largo de un camino fijo, apoyado sobre rodillos guía que cumplen tres funciones a la vez: definen la geometría del recorrido, mantienen la tira plana y alineada lateralmente, y desacoplan tramos, de modo que una perturbación de tensión en uno no se propague al siguiente. #nota[Un camino hilado admite además intercalar una etapa de limpieza, que la práctica archivística resuelve con rodillos de transferencia de partículas o con un paño humedecido por el que el filme pasa antes de llegar a la ventanilla. Debido a que ya excede a las limitaciones del proyecto, se menciona solo por topología.] Como el filme se guarda enrollado y viaja apoyado sobre superficies cilíndricas, todo elemento del camino es un cuerpo sujeto a rotación y toda actuación se ejerce como un par sobre un eje: el avance lineal de la tira es el resultado de movimientos rotacionales, y en el transporte no hay ningún actuador que se desplace.

De ahí sale lo que se le pide a cada actuador: un avance discreto y repetible del orden del paso de un fotograma, la capacidad de sostener la posición mientras la cámara expone, y un par de torque acotado, porque sobre una base fragilizada la fuerza disponible es un riesgo antes que una virtud.

=== Del actuador al driver

Los actuadores rotativos que pueden resolver eso se distinguen, más que por su construcción, por cuánto saben de la posición real de su propio eje. Un motor de corriente continua gira mientras se lo alimente y no sabe nada, así que posicionar con él exige agregarle un sensor y un lazo de control externos. Un servomotor trae ese lazo de fábrica, ya que integra el motor, un encoder y un controlador que compara la posición pedida con la medida y corrige la diferencia. El motor paso a paso ofrece una tercera vía: su rotor avanza un incremento angular fijo por cada pulso que recibe, de modo que contar pulsos alcanza para saber cuánto se movió, sin medir nada @acarnley.

Esa tercera vía es la habitual para avances discretos y repetitivos como el de un fotograma. La electrónica es más simple y barata que la de un servo, el comportamiento es predecible, y su uso masivo en impresoras 3D, máquinas de control numérico (CNC) y automatización de laboratorio dejó una oferta madura de componentes de bajo costo. 


Entre la lógica y el motor hace falta una etapa intermedia, porque un microcontrolador no puede alimentar las bobinas: la corriente, la tensión y la energía almacenada en la inductancia están fuera de lo que un pin puede manejar. De eso se ocupa el *driver*, un circuito integrado que combina la etapa de potencia con la lógica de secuencia y, en los modelos actuales, con una regulación por conmutación que mantiene en cada bobina la corriente configurada en lugar de la que impondría la tensión de alimentación @acarnley. El controlador le habla por dos vías: líneas discretas de paso, dirección y habilitación, que son el mínimo común de la categoría, y en los modelos configurables un enlace serie que da acceso a sus registros internos. #nota[Como el driver es un integrado de montaje superficial de pines muy finos, se lo monta sobre una placa portadora que expone sus señales en un formato común. Esa convención es la que permite que el capítulo 6 discuta qué driver conviene sin que la decisión arrastre al resto del diseño.]

Casi todos ofrecen además *micropaso*, que subdivide electrónicamente cada paso mecánico en fracciones y suaviza el movimiento. La contrapartida rara vez se enuncia junto con la ventaja: el par que sostiene cada micropaso es una fracción del par de paso completo, así que la resolución que se gana en el papel no equivale a precisión de posicionamiento bajo carga @acarnley.

=== Nadie mide el eje en un motor paso a paso

El driver sabe cuántos pulsos emitió y el firmware sabe cuántos pidió, pero nadie mide el eje: no hay sensor que confirme que el rotor giró lo que se le ordenó. Si el par requerido supera momentáneamente al disponible, por fricción, inercia o un obstáculo, el motor pierde pasos o se detiene, y la cuenta sigue avanzando como si nada hubiera ocurrido @acarnley. Algunos drivers estiman la carga sobre el eje a partir de la respuesta eléctrica del propio motor y pueden avisar que se trabó, pero eso informa un evento y no una posición, y no dice cuántos pasos se perdieron antes de avisar.

El arrastre por fricción aporta la segunda mitad del problema. Al no engranar en ninguna geometría, un capstan puede deslizar sobre el filme, de modo que incluso con el motor girando exactamente lo comandado el avance real de la tira puede diferir del calculado. Lo que se ganó al abandonar la perforación como apoyo mecánico se paga de esta forma.

Entonces, la cuenta de pasos es una estimación del avance y nunca una medición. Además, como se discutió en 2.1, todo material degradado tiene un paso con deriva, por lo que no hay forma de convertir movimiento constante en la posición del fotograma. Por lo tanto, como el mecanismo no puede saber dónde quedó el fotograma, hay que mirarlo.

#pendiente[Los datos bibliográficos de @acarnley están verificados, pero las citas se le atribuyeron por tema y no contra el ejemplar. Cuando lo consigas, confirmá que respalda las tres afirmaciones a las que está enganchado: caída de par con la velocidad, distinción entre velocidad de arranque y velocidad máxima con rampa, y regulación de corriente por conmutación. Si conviene, agregá el capítulo o la página a cada cita.]

== Detección y centrado

#pendiente[Detección óptica, estimación por avance de motor, tracking mecánico y visión artificial. Abre desde el problema que dejó 2.2.]

== Captura

#pendiente[Cámaras y escáneres, para poder clasificar la captura cuando aparezca la Canon EOS R50.]

== Estado del arte

#pendiente[Comerciales con precios y abiertos o de aficionado. Compara repuestos, dependencia del proveedor e imposibilidad de reparar, no solo precio.]
