#import "../plantilla/bloques.typ": pendiente, nota, tabla, disposicion, diagrama, caja, encierro, flecha

= Firmware

== Desglose del sistema

La consigna del subsistema de transporte es mover película con motores paso a
paso. Enunciada así es difícil implementarlo: no dice quién decide el
movimiento, quién lo ejecuta, ni dónde está la frontera entre ambos. Por lo tanto, el problema
se parte en tres tareas.

La primera es recibir órdenes desde la PC. La segunda es gobernar los drivers.  Ninguna de
las dos tiene nada de este proyecto: mandar comandos a un TMC2209 es un problema
cerrado, con una respuesta que vale para cualquiera que use ese driver, y llamar
procedimientos de forma remota sobre un enlace serie es un problema aún más
viejo. Ninguna de las dos necesita saber de transporte fílmico.
#nota[También cabe preguntarse qué componentes se usan y por qué: el
microcontrolador es un ESP32 y el driver es un TMC2209, pero ambas elecciones se
resolvieron en el capítulo 6, y el protocolo del driver se detalla en el anexo A.]

La tercera es coordinarlas y configurarlas, y es la única tarea propia del proyecto: cuándo
mover, cuánto, a dónde, y qué hacer cuando algo no responde.

De ahí salen tres piezas, las tres escritas en C. Una librería que gobierna el driver,
una librería que resuelve el enlace, y un programa que las compone y decide.

#figure(
  diagrama(
    encierro(((1, 0), (1, 1), (1, 2))),
    caja((0, 1), [PC]),
    caja((1, 0), raw("rpc"), acento: true),
    caja((1, 1), [Orquestador]),
    caja((1, 2), raw("tmc2209"), acento: true),
    caja((2, 1), [Driver y motor]),
    flecha((0, 1), (1, 1), etiqueta: [USB], doble: true),
    flecha((1, 1), (1, 0)),
    flecha((1, 1), (1, 2)),
    flecha((1, 1), (2, 1), etiqueta: align(center)[UART \ y líneas digitales], doble: true),
  ),
  caption: [Composición del firmware. El recuadro punteado es el
  microcontrolador. Las dos piezas en ámbar no saben nada del proyecto; la del
  medio es lo único que sí.],
) <fig-firmware-bloques>

Que las dos librerías sean independientes no es una prolijidad: es la forma
concreta que toma el requerimiento de modularidad (R06) dentro del
microcontrolador. #nota[Cada una compila, se prueba y se documenta de forma independiente, y declara lo que necesita del periférico como contratos
de puntero a función. De ahí
que se puedan sustituir de a una, que es lo que pide R07. De ahí también que cada librería sea publicable por
separado y sirva en cualquier proyecto, propio o ajeno.] Las tres secciones que siguen recorren esas piezas
en ese orden: primero el driver, después el enlace, y al final lo que las vuelve
un sistema.

== Gobierno del driver

Al driver se le habla por dos vías. Una es un bus UART de un hilo, por el que
viajan datagramas que leen y escriben sus registros. La otra son cuatro líneas
lógicas, que se manejan como valores lógicos.

#figure(
  tabla(
    columnas: (auto, 1fr, auto),
    cabecera: ("Vía", "Qué resuelve", "Sentido"),
    [UART], [Configuración y lectura de estado, por registros.], [Bidireccional],
    [ENN], [Habilita la etapa de potencia. Activo bajo.], [Escritura],
    [DIR], [Orden de fases del motor.], [Escritura],
    [STEP], [Un micropaso por flanco.], [Escritura],
    [DIAG], [Falla del driver o StallGuard, según configuración.], [Lectura],
  ),
  kind: table,
  caption: [Vías de comunicación que expone el driver.],
) <tbl-tmc2209-vias>

La tabla es engañosa en una fila. STEP figura como una línea más, pero un tren de
pulsos no es un nivel: no se puede escribir como si fuese una salida de propósito general. Escribir ese pin desde el
procesador, además, es lo que hace que la cadencia dependa de qué más esté
haciendo el sistema. Esa observación es la que parte el problema en tres partes y
no en dos, y ordena el resto de la sección.

=== Lo que la librería declara y no implementa

Las tres vías terminan en periféricos del sistema que hospeda a la librería. Si
la librería los tocara directo quedaría atada a un microcontrolador y a un
cableado: no compilaría en otro, no se probaría sin el driver enchufado, y una
decisión de conexionado obligaría a editarla.

#nota[Sobre el ESP32, las implementaciones se apoyan en el controlador
de UART para el bus y en el de GPIO para las líneas.
#pendiente[Nombrar el periférico que emite los pulsos cuando esté escrito el
backend de STEP. Pero mover nota a la sección de ESP32]]

Entonces no los toca. Declara lo que necesita como tres estructuras de punteros a
función, y quien la usa provee las implementaciones. Un canal de bytes para el
UART, una lectura y una escritura de nivel para las líneas, y una fuente de
pulsos con rampas y cuenta para STEP. Ninguna de las tres nombra al dispositivo
ni a las otras dos, que es lo que permite escribir una sin abrir el resto de la
librería.

#figure(
  diagrama(
    caja((1, 0), [Dispositivo]),
    caja((0, 1), raw("uart"), acento: true),
    caja((1, 1), raw("lines"), acento: true),
    caja((2, 1), raw("stepgen"), acento: true),
    caja((0, 2), [Enlace serie]),
    caja((1, 2), [Pines]),
    caja((2, 2), [Temporizador]),
    flecha((1, 0), (0, 1)),
    flecha((1, 0), (1, 1)),
    flecha((1, 0), (2, 1)),
    flecha((0, 2), (0, 1)),
    flecha((1, 2), (1, 1)),
    flecha((2, 2), (2, 1)),
  ),
  caption: [Los tres contratos y quién los llena. La fila de abajo la provee
  quien usa la librería; la de arriba es todo lo que la librería conoce.],
) <fig-tmc2209-backends>

Que sean tres y no dos es la consecuencia de la sección anterior. UART y líneas se
separan porque son canales distintos del integrado. La fuente de pulsos se separa
de las líneas aunque compartan el mismo pin, porque una cadencia con rampas y
cuenta exacta la emite un periférico de temporización y no una escritura de
nivel. Como quedan dos candidatos a manejar el mismo pin, la librería obliga a
elegir uno: cuando hay una fuente de pulsos, escribir STEP como nivel se rechaza.

Dos detalles del mismo orden. Las líneas se declaran con una máscara de cuáles
están efectivamente conectadas, de modo que una llamada que nombre una línea
ausente se rechaza. Y dentro del contrato del UART
conviven dos tipos de políticas distintas:
#nota[- La política backend vive en el contrato del bus y no en cada dispositivo porque describe al cable, no al driver: cuatro drivers pueden compartir el bus ya que tienen direccionamiento de dos bits.

- El eco que se menciona se debe a que el TMC2209 admite una comunicación half-duplex de un solo hilo por lo que el microcontrolador termina escuchando lo que envía.]

- Los punteros a funciones y el hecho de que el bus y el eco son propiedad de quien lo implementa, el backend.
- El tiempo de espera y los reintentos son criterio de la librería.

=== La pieza que cruza los tres canales

Los contratos por separado no alcanzan, porque hay operaciones que necesitan más
de un canal para completarse. Iniciar un movimiento es el caso: hay que fijar el
sentido en una línea, verificar algunos registros por UART, y recién entonces arrancar el tren de pulsos, en ese orden y nunca
en otro. Ningún contrato puede hacerlo, porque ninguno conoce a los otros dos.

Esa es la razón de ser del dispositivo. Reúne los tres contratos, la dirección
del driver en el bus, la copia de lo último que se sabe de cada registro junto
con su bitmap de validez, y lo poco que hace falta recordar entre llamadas: el
contador de escrituras aceptadas y los dos bits con los que arrancó el
movimiento en curso.

```c
typedef struct {
    const tmc2209_uart_t    *uart;
    const tmc2209_lines_t   *lines;
    const tmc2209_stepgen_t *stepgen;
    uint8_t  addr;
    uint8_t  ifcnt;
    uint32_t cache[TMC2209_REG_COUNT];
    uint32_t valid;
    bool     run_dir;
    bool     run_shaft;
} tmc2209_t;
```

Toda la librería se llama sobre un dispositivo, así que nadie arma una operación
juntando tres partes. La dirección es lo que además permite que varios drivers
compartan un mismo bus, configurado en el mundo físico mediante dos straps conectados al TMC2209 conocidos como MS1 y MS2.

El ciclo de vida sigue de eso. Primero se construye el dispositivo, después se le
vincula cada contrato que exista, y recién al final se reclama el driver y se le
escribe una configuración conocida.

=== Registros y caché

Todo lo que el driver es capaz de hacer se configura escribiendo registros, y lo
natural sería preguntarle su contenido cada vez que hace falta. No es conveniente, por
dos razones distintas:
- Ocho de sus registros son de solo escritura del lado del driver, así que la lectura es directamente imposible.
- Cada lectura cuesta una transacción, sobre un bus que además comparten hasta cuatro drivers.

La librería entonces recuerda lo último que le consta de cada registro, que casi
siempre es lo que escribió y, para unos pocos, lo que leyó una sola vez al
reclamar el driver. Pero un valor recordado es
una afirmación sobre el presente, y solo es cierta para algunos registros. De ahí
que la tabla de registros conteste dos preguntas independientes que conviene no
mezclar. Una es el acceso, que es lo que el driver permite: si se puede leer, si
se puede escribir. La otra es la clase, que es quién puede cambiar el valor, y es
la que decide si recordarlo es legítimo.

#figure(
  tabla(
    columnas: (auto, auto, 1fr),
    cabecera: ("Clase", "Quién lo escribe", "Qué implica"),
    [Volátil],
    [El driver],
    [Se consulta cada vez ya que sus valores son avisos del driver para la entidad que usa de él. Una copia describiría un momento que ya pasó.],

    [Propio],
    [Solo la librería],
    [Se recuerda mientras la ranura siga siendo válida.],

    [Constante],
    [Nadie, en este diseño],
    [Se lee una vez al reclamar el driver y se recuerda desde entonces.],
  ),
  kind: table,
  caption: [Clasificación de los registros según quién cambia su valor.],
) <tbl-tmc2209-clases>
#nota[Se le llama reclamar el driver cuando una estructura de dispositivo logra comunicarse con el integrado y sincronizar su copia de registros. La librería no puede producir movimiento hasta que eso suceda. Queda claro que un driver solo puede tener un controlador, y que un controlador puede gobernar varios drivers.]
La copia es un arreglo con una ranura por registro y un bit de validez por
ranura. Ese bit es el que hace honesta a la estructura: no dice que el valor sea
viejo, dice que no es fiable. Pedir un registro cuya ranura es
inválida se rechaza, y para los ocho
registros de solo escritura esa copia inválida es la única fuente que existe.

Escribir tiene su propio problema. El driver no contesta las escrituras, así que
por sí sola una escritura no se distingue de un datagrama que se perdió. La
confirmación se construye una capa más arriba, leyendo un contador que el driver
incrementa cada vez que acepta una. #nota[Se lee ese contador antes y después, y
lo que se verifica es un rango y no una igualdad: tiene que haber avanzado al
menos una vez por registro escrito, y a lo sumo una vez por datagrama enviado. La
diferencia entre esas dos cotas son los reintentos, que el driver contó cada vez
que llegaron. Es lo único que el integrado ofrece para saberlo.] Por eso la
unidad de trabajo no es un registro sino un lote: diez registros cuestan once
transacciones y no veinte.

Ese lote tiene tres conductas que conviene conocer antes de usarlo. Se aplica en
orden, y un registro nombrado dos veces se transmite una sola vez, con el último
valor. Se descarta lo que ya coincide con una ranura válida, de modo que un lote
puede terminar sin poner un solo byte en el bus. Y ante una falla, se
invalidan todas las ranuras del lote, incluidas las de los datagramas que
alcanzaron a salir: nada queda confirmado hasta el conteo final, así que dar por
buenas las escrituras previas sería creer en algo que nunca se verificó. La
recuperación es reenviar el lote entero.

La misma regla gobierna el caso extremo. Si el driver informa que se reinició, la
librería invalida todas las ranuras propias de una vez, porque el reinicio
significa exactamente que el caché dejó de describir al integrado.

=== Movimiento

Un motor paso a paso al que se le exige más aceleración de la que puede dar no se
queja: se atrasa, pierde el sincronismo y avanza una distancia que nadie sabe
cuál fue. Por eso un movimiento no se pide con una cadencia sino con tres, y las
tres describen al mecanismo antes que a la intención de quien lo ordena.

#figure(
  tabla(
    columnas: (auto, 1fr),
    cabecera: ("Cadencia", "Qué describe"),
    [Arranque],
    [La velocidad del primer y del último pulso: lo más rápido que este motor con
    esta carga puede partir del reposo, y frenar en seco, sin perder el paso.],

    [Crucero],
    [La velocidad que se sostiene entre las dos rampas.],

    [Aceleración],
    [La pendiente de ambas rampas. Un movimiento demasiado corto y/o poco
    acelerado nunca llega al crucero, y el perfil se vuelve un triángulo.],
  ),
  kind: table,
  caption: [Las tres cadencias que definen un movimiento.],
) <tbl-tmc2209-cadencias>

Esas tres cadencias, más cuántos pulsos emitir, son todo lo que se le pide al backend de generación de pulsos. Es su plan de corrida.

```c
typedef struct {
    uint32_t pulses;
    uint32_t pullin_pps;
    uint32_t cruise_pps;
    uint32_t accel_pps_s;
} tmc2209_run_plan_t;
```

Nótese lo que no está. No hay sentido de giro, no hay unidades de paso, no hay
posición. La fuente de pulsos cuenta pulsos y nada más, y nunca oyó hablar de en
cuántos micropasos está dividido un paso. #nota[La distinción no es pedantería:
un paso completo puede contener hasta 256 micropasos, así que llamar pasos a los
pulsos es errar la cuenta por dos órdenes de magnitud. La conversión ocurre una
capa más arriba, donde la resolución sí se conoce.] Esa ignorancia es lo que la
vuelve implementable por cualquiera.

A cambio se le exigen cuatro garantías. Que una corrida acotada emita esa
cantidad de pulsos y ni uno más. Que si se la detiene antes, informe cuántos
alcanzó a emitir. Que una corrida demasiado corta para completar las rampas
priorice la cantidad de pulsos sobre la cadencia, y salga como triángulo. Y que
todo pulso tenga el ancho mínimo que el driver es capaz de registrar, a cualquier
cadencia.

El estado que el backend debe ofrecer para seguir la corrida es simétrico al plan
que la pidió: cuántos pulsos lleva emitidos, a qué cadencia va, y si sigue
corriendo. Se puede pedir mientras corre, porque la llamada que la inició no
bloquea ni avisa cuando termina.

Un movimiento real necesita dos bits más que la fuente de pulsos no
puede conocer, porque no viven en su canal: el sentido, que es una línea, y el
registro que lo invierte. Los dos tienen que estar de acuerdo antes del primer
flanco. #nota[Hacia dónde gira el eje es un XOR de tres términos: la
línea, el registro, y cómo estén ordenadas las fases del motor en el cableado. La
librería controla los dos primeros y no puede conocer el tercero.] De ahí que el
dispositivo declare su propio plan, que es el de la corrida con esos dos
adelante.

```c
typedef struct {
    bool     dir;
    bool     shaft;
    uint32_t pulses;
    /* ... las tres cadencias ... */
} tmc2209_movement_plan_t;
```

El estado crece por el mismo lado que el plan. A los tres campos que ofrece el
backend se les suman los dos bits con los que arrancó el movimiento, que no son
necesariamente los que haya ahora: nada impide cambiarlos en pleno movimiento, y
el motor responde en el acto. La cuenta, en cambio, no tiene signo y solo sube,
porque quien la lleva no sabe qué es una dirección.

#nota[Como resultado, se considera a modo de recomendación que el operador de la librería no cambie de sentido mientras el motor está en movimiento.]
Lo que no aparece por ningún lado es una posición. La librería cuenta un
movimiento por vez y nunca los acumula, porque sumarlos es decidir qué
significaron esos pulsos, y esa decisión pertenece a quien la usa.

=== Fallas

Lo que el driver puede informar está repartido en dos registros, y quien pregunta
si está sano no debería tener que aprenderse en cuál vive cada cosa. La librería
los lee juntos y devuelve un único conjunto de condiciones.

La distinción que sí importa es temporal. Algunas banderas tienen memoria:
avisan que algo pasó y siguen avisándolo hasta que alguien las limpie. Otras
son vivas: describen lo que es cierto ahora y se apagan solas cuando la situación
cambia.

Del lado de la librería, en cambio, hay un solo vocabulario de error, plano y
compartido por todas las capas. #nota[Que sea plano es deliberado: una falla de
la vía, un CRC mal, una línea sin conectar y un movimiento en curso que
impide la llamada se informan con el mismo tipo. Quien la usa decide qué hacer
con cada caso sin tener que traducir entre capas.]

== Enlace con la PC

Que la PC llame a un procedimiento que corre en el microcontrolador suena a una
sola cosa y son cuatro, apiladas. Hay que saber dónde termina un mensaje, saber
si llegó intacto, saber qué parte de él es qué, y saber a qué función
corresponde. Cada una supone resuelta la anterior, así que la sección las recorre
de abajo hacia arriba.

=== Dónde empieza y dónde termina un mensaje

Un cable entrega bytes, no mensajes. El receptor ve un flujo continuo y nada le
indica dónde corta uno y empieza el siguiente. Lo primero que se le ocurre a
cualquiera es reservar un byte que signifique "acá termina", y ahí aparece el
problema: ese byte también puede aparecer dentro de los datos, y entonces hay que
escaparlo, y hay que escapar el carácter de escape.

*COBS*, por _Consistent Overhead Byte Stuffing_ @cobs, elimina el problema: reescribe el mensaje de forma que el resultado no
contenga ningún cero, sacándolos y anotando dónde estaban de forma determinista. El cero queda entonces
libre para significar fin de mensaje y nada más, sin escapes ni casos especiales y la decodificación es posible por el determinismo.
#nota[La propiedad menos evidente y más valiosa aparece cuando algo sale mal: si
un mensaje se corrompe o se pierde, el punto donde el receptor vuelve a
sincronizarse está definido y no se adivina, y está a lo sumo un mensaje de
distancia. Se descarta lo que quedó mal y todo lo que siga hasta el próximo
cero.] Lo que distingue a COBS de otros métodos de relleno es que su costo está
acotado por diseño: agrega a lo sumo un byte cada 254, sin importar qué contenga
el mensaje. La función que codifica, además, no escribe el delimitador: quién y
cuándo agrega el cero es decisión de quien la usa.

Eso resuelve dónde termina el mensaje, pero no si sobrevivió. De eso se ocupa el
*CRC-16*, un código de redundancia cíclica de dieciséis bits que se calcula sobre
el mensaje y viaja al final @crc-peterson. La idea es tratar a los bytes como un
número enorme, dividirlo por una constante acordada de antemano, y mandar el
resto de la operación. El receptor repite la cuenta sobre lo que recibió, y si le da lo mismo los
bytes son, con altísima probabilidad, los que salieron. #nota[La constante es el
polinomio 0x1021, es decir $x^16 + x^12 + x^5 + 1$. La variante implementada es
CRC-16/IBM-3740, con valor inicial 0xFFFF y sin reflejar los bits, comúnmente mal
llamada "CRC-CCITT": no corresponde a la ITU-T V.41 original, que usa valor
inicial 0x0000 y bits reflejados.] Un error de un solo bit se detecta siempre, y
las ráfagas de hasta dieciséis bits también.

=== Un marco que no se serializa

Ya delimitado, un mensaje de esta librería tiene tres partes.

#figure(
  disposicion(
    ([Cabecera \ 8 B], [Payload], [CRC \ 2 B]),
    arriba: [Marco],
    abajo: [En el cable],
    envuelta: [Marco codificado, sin ceros],
    prefijo: [`0x00`],
    sufijo: [`0x00`],
    elastica: 1,
  ),
  kind: image,
  caption: [Las dos capas del mensaje. El marco es lo que las dos puntas
  interpretan; lo de abajo es lo único que existe en el cable.],
) <fig-rpc-marco>

Y hay tres tipos de mensaje, que se distinguen por el primer byte de la cabecera: un
pedido, una respuesta, y una línea de registro (log). Las dos primeras van de a pares.
La tercera no contesta nada y por eso no lleva identificador.

Ni la cabecera ni el payload se codifican campo por campo. El marco vive en un
único búfer y cada parte ocupa un tramo de él: quien emite escribe sus campos
directamente ahí y manda los bytes tal como quedaron; quien recibe hace lo
inverso, interpreta cada tramo como el struct que le corresponde, la cabecera al
principio y el payload a continuación, y lee los campos sin moverlos de lugar.
No hay traducción en ninguna de las dos
direcciones ni copia a un intermedio, porque para la librería la disposición en memoria y la
disposición en el cable son la misma cosa. #nota[Del lado de quien emite hay un
orden obligado, y es la razón del verbo "sellar": el payload se escribe primero y
la cabecera se completa al final, porque uno de sus campos es el largo del
payload y ese número recién se conoce cuando el payload está puesto. Sellar es
completar la cabecera y agregar la suma de verificación, o sea dar el marco por
cerrado.]

Mapear memoria cruda a un struct es normalmente una mala idea: Un procesador lee un entero de treinta y dos bits de una sola vez solo si ese
entero arranca en una posición múltiplo de cuatro.
Para que eso se cumpla, el compilador tiene permiso de dejar huecos entre un
campo y el siguiente (padding), y los deja sin anunciarlo. Cuántos son y
dónde caen depende del compilador.

Ahí está el problema, porque esos huecos también viajan por el cable. Si los dos
extremos no los ponen en el mismo lugar hay desfase. Tres reglas de la librería lo vuelven seguro:

- *Ningún hueco queda librado al compilador.* Los campos se ordenan de modo que el compilador no necesite interferir ninguno, y si el orden no alcanza se agregan campos huecos de relleno, simulando lo que el compilador haría. #nota[Se le puede pedir al compilador que no deje ningún hueco, pero eso
  devuelve campos poco optimizados y difíciles de tratar, que es justamente lo que los huecos
  evitaban. Ordenarlos a mano cuesta unos pocos bytes y conserva las dos
  propiedades a la vez.]

- *Toda cabecera mide exactamente ocho bytes*, de modo que el payload siempre
  empieza en un desplazamiento alineado.

- *Cada estructura afirma su tamaño en tiempo de compilación.*

```c
// Estructura de la cabecera de respuesta a una petición de procedimiento.
typedef struct {
    uint8_t  type;
    uint8_t  status;
    uint8_t  _pad[2];
    uint16_t id;
    uint16_t _pad2;
} rpc_rep_hdr_t;
RPC_WIRE_SIZE(rpc_rep_hdr_t, RPC_HDR_LEN); // RPC_HDR_LEN es 8
```

La línea que cierra el bloque es la tercera regla puesta en práctica: una macro
sobre `static_assert` que compara el tamaño real de la estructura contra el que
el protocolo declara. #nota[`static_assert` se evalúa mientras se compila y no
emite código, así que la comprobación no cuesta nada en ejecución y tampoco
depende de que asserts tradicionales estén activados.] Es la que
sostiene a las otras dos, porque las dos primeras son intenciones que el
compilador podría no respetar y esta las convierte en una condición verificada.
Si alguien agrega un campo, cambia un ancho o el compilador acomoda distinto, el
archivo deja de compilar en el extremo que se desvió.

=== Del número al procedimiento

Un procedimiento se nombra con dos números, un espacio de nombres (namespace) y un índice
dentro de él. Convertir ese par en una llamada es todo lo que hace esta capa.

La forma directa sería una selección múltiple sobre el índice, un `switch` con
una rama por procedimiento. Funciona, a costa de asegurarse que el archivo conozca toda función ejecutable, ya que el compilador exige
su declaración.

El resultado es que `rpc`, que solo quería mover bytes, termina
dependiendo del proyecto entero. Y con él, cualquiera que lo use: una prueba que
quiere ejercitar la construcción de un marco tiene que enlazar contra el driver
que no piensa tocar, y una versión reducida del firmware no puede dejar afuera un
procedimiento sin editar ese `switch`.

Por eso los espacios de nombres se registran en lugar de compilarse adentro.
Quien usa la librería instala la tabla de vinculación que sirve; una prueba instala solo lo que
está probando; y `rpc` no nombra un solo tipo ajeno. Cada entrada de esa
tabla lleva, además de la función, cuánto miden sus payloads.  Así la verificación de que el payload recibido mide lo que la función
espera ocurre una sola vez, de la misma forma para todos, antes de que nadie toque
el primer campo. #nota[Para saber cuánto mide un payload hay que aplicarle `sizeof` a su estructura, y
eso es nombrarla. Escribir los largos en la tabla de vinculación resuelve `sizeof` al compilar, así que el despachador compara enteros y nunca nombra una estructura
ajena.]

#nota[Que una estructura pueda terminar en un
arreglo sin dimensión declarada es una posibilidad del lenguaje desde C99.]


Hay una excepción que la tabla no puede resolver sola. Cuando un payload termina
en un arreglo de largo variable, el número que lo determina
viaja adentro del propio payload, y ninguna tabla puede saberlo de antemano.
Esas
entradas declaran un mínimo y un máximo en vez de una medida exacta, y reciben el
largo real para verificarlo ellas mismas.


=== Lo que los dos extremos compilan

Todo lo anterior mueve marcos sin preguntar. Falta la otra mitad: qué
procedimientos existen, qué recibe cada uno y qué devuelve. Eso es el contrato.

Un contrato así se puede fijar de dos maneras. Una es documentarlo, con un texto
que diga que el procedimiento número cuatro recibe dos enteros de treinta y dos
bits y devuelve uno de ocho; cada extremo lo lee y escribe su propia versión, en
su propio lenguaje. La otra es declararlo: un único archivo fuente, con la
numeración y las estructuras adentro, que los dos extremos compilan tal cual.
Se hace lo segundo, y esa decisión es lo que define al contrato de este
protocolo.

La diferencia entre las dos maneras aparece cuando algo cambia. Con un
documento, cada extremo tiene su propia copia de la verdad, lo cual es riesgoso. Con una declaración
compartida el problema no existe, porque no hay dos copias que puedan diferir.
#nota[Es el mismo argumento que sostiene a las estructuras que afirman su propio
tamaño: una sola declaración compilada por los dos lados, en lugar de dos
descripciones que hay que mantener sincronizadas a mano.]

Conviene entonces ver *qué le toca escribir a quien use la librería*, y el ejemplo
más chico que alcanza es una calculadora: un procedimiento que recibe dos enteros
y devuelve la suma.

Lo primero es la declaración compartida, el archivo que los dos extremos
compilan.

```c
typedef enum {
    RPC_NS_CALC  = 0,
    RPC_NS_COUNT = 1,    //cantidad de namespaces del proyecto
} rpc_ns_t;              //solo un namespace: la calculadora

typedef enum {
    RPC_CALC_ADD   = 0,  //procedimiento de sumar, el único
    RPC_CALC_COUNT = 1,  //cantidad de funciones del ns
} rpc_calc_method_t;

typedef struct { // Para sumar se usan dos enteros de 32bits
    int32_t a;
    int32_t b;
} rpc_calc_add_args;
RPC_WIRE_SIZE(rpc_calc_add_args, 8); // 4 bytes por int

typedef struct { // Se devuelve un entero de 32bits
    int32_t sum;
} rpc_calc_add_ret;
RPC_WIRE_SIZE(rpc_calc_add_ret, 4);
```

Lo segundo es la implementación, que existe de un solo lado, y la tabla que la
registra.

```c
static rpc_status_t calc_add(const void *args, void *ret)
{
    const rpc_calc_add_args *in  = args;
    rpc_calc_add_ret        *out = ret;

    out->sum = in->a + in->b;
    return RPC_OK;
}

const rpc_method_t rpc_calc_methods[RPC_CALC_COUNT] = {
    [RPC_CALC_ADD] = RPC_METHOD(calc_add),
};

//registra el namespace y su tabla de procedimientos
rpc_register(RPC_NS_CALC, rpc_calc_methods, RPC_CALC_COUNT);
```

Eso es todo. La lista que sigue es lo que ese ejemplo obedece, y es lo que
cualquier familia de procedimientos debe cumplir para entrar en este protocolo,
sin importar de qué se ocupe.

- *Sus payloads son estructuras declaradas.* Lo que un procedimiento recibe y lo
  que devuelve se lee de una declaración, no se reconstruye siguiendo el orden de
  las asignaciones dentro de una función. Las dos primeras líneas del cuerpo son
  el mecanismo de la subsección anterior visto desde acá: el despachador entrega
  un puntero al búfer y la función lo interpreta como su estructura. Un cast, no
  una decodificación.

- *Esas estructuras obedecen las tres reglas de disposición* de la subsección
  anterior: relleno declarado a mano, cabecera de ocho bytes, y tamaño afirmado en
  tiempo de compilación. #nota[En el ejemplo no hizo falta declarar relleno
  porque dos enteros de treinta y dos bits ya caen alineados. La tercera regla es
  la que verifica que eso sea cierto y no una suposición.]

- *Su numeración vive en la declaración compartida* y en ningún otro lugar. El
  número del espacio de nombres y el de cada procedimiento los elige quien integra
  la librería a su aplicación; la librería no los conoce, recibe la tabla ya
  armada. Renumerar rompe en silencio a un cliente viejo, que pediría el
  procedimiento cuatro y ejecutaría el que antes era el cuatro, así que uno nuevo
  se agrega al final y nunca se inserta.

- *Sus códigos de estado se mantienen por debajo de 240.* La respuesta lleva un
  solo byte de estado y ahí conviven dos vocabularios. Uno es el de `rpc`,
  que sabe decir que ese procedimiento no existe o que el payload no mide lo que
  debía; tiene tres valores y no va a crecer. El otro es el de quien registra los
  procedimientos, que crece con lo que gobierne: para la calculadora sería una
  división por cero. `rpc` se queda con 240 y para arriba, la aplicación
  con todo lo de abajo, y ninguno de los dos necesita listar al otro. #nota[Conviene
  poner un `static_assert` sobre el último código propio, de modo que pasarse de
  la frontera rompa la compilación en lugar de mandar un estado que el otro
  extremo lee como una falla de `rpc`.]

- *Conviene reservar un procedimiento que conteste la versión del protocolo.* Es
  lo único de la lista que es una recomendación: se puede no
  implementar. Ese número lo incrementa el usuario de la librería ante cualquier
  cambio de una disposición, de una numeración o de un estado, y preguntarlo antes convierte una incompatibilidad en un rechazo limpio.
== Integración y orquestación

El sistema de transporte fílmico requiere ambas librerías. Para su puesta a punto, `tmc2209`
declara tres contratos que la capa superior implementa, y `rpc` sirve espacios de nombres que esa misma capa debe registrar. En los dos casos fue a propósito, y esta sección aborda ambos.

*Integrar* es configurar las librerías, atándolas a los
periféricos del microcontrolador y, en un punto, una librería a la otra.
*Orquestar* es decidir en qué orden ocurre todo y qué pasa cuando algo falla. Lo
primero es casi todo el trabajo.

=== Una pieza de vinculación por librería

A cada librería se le suma una pieza compañera que hace las vinculaciones.


#figure(
  tabla(
    columnas: (auto, 1fr, auto),
    cabecera: ("Pieza", "Qué vincula", "Qué nombra"),
    [`tmc2209_bind`],
    [Los tres contratos con las implementaciones que los llenan, y qué drivers existen en esta placa.],
    [`tmc2209`, ESP-IDF],

    [`rpc_bind`],
    [Las tablas de métodos con llamadas a funciones reales, y por dónde entran y salen físicamente las llamadas a procedimientos.],
    [`rpc`, `tmc2209`, ESP-IDF],
  ),
  kind: table,
  caption: [Las dos piezas de vinculación y su alcance.],
) <tbl-firmware-bind>
#pendiente[`rpc_bind` cambiará cuando agreguemos el espacio de nombres `film`, que no es de la librería del driver sino de la capa superior.]

=== Lo que el driver necesita del sistema

Los tres contratos se llenan contra los periféricos del ESP32. El backend sabe mover bytes por el UART, poner un pin en un nivel y temporizar pulsos; qué
significa ese nivel es de la librería, pero qué pin es corresponde a la tabla de
placa.

Esa tabla de placa es la que dice qué drivers existen, en qué pines y con qué
dirección se comunican. Los números salen de la configuración del proyecto, así que
una placa cableada distinto se resuelve configurando y no parcheando.

#nota[Pasar de la placa de un solo driver a la definitiva de tres es agregar
dos entradas a ese arreglo. Todo lo que está por encima direcciona por nombre,
así que nada más se entera.]

Los dispositivos se construyen todos al arrancar, sin condiciones y de una sola
vez.

=== Lo que el enlace necesita del sistema

Las tablas de métodos están partidas por espacio de nombres y se diferencian sobre qué cubren. Se registran al inicializar, desde un archivo cada
una, y el sistema de transporte fílmico las usa para despachar procedimientos.

#figure(
  tabla(
    columnas: (auto,  auto),
    cabecera: ("Namespace", "Para qué sirve"),

    [`sys`],
    [Ofrecer versión de protocolo, estado, qué dispositivos declara la placa, etc.],

    [`passthrough`],
    [Ofrecer transferencia de bytes en el bus UART sin que el firmware los interprete, relegando el armado y verificación de los datagramas del driver a la PC.],

    [`raw`],
    [Ofrecer un método por cada llamada pública de la librería del driver.],

    [`film`],
    [Ofrecer una interfaz de alto nivel y abstraída de los drivers para modelar el movimiento de la película íntegramente mediante un puñado de llamadas.],
  ),
  kind: table,
  caption: [Los espacios de nombres que sirve el mecanismo RPC del sistema de transporte fílmico.],
) <tbl-rpc-namespaces>

Entre las dos librerías hay además un vocabulario que traducir. La librería del
driver reporta sus errores con su propia enumeración y el protocolo los transmite
como un byte de estado. La correspondencia se escribe una vez en la vinculación, y es una renumeración.

Queda la parte más propia del ESP32. El microcontrolador tiene que intercambiar información de negocio por un cable USB: entonces los mensajes de logging no pueden seguir saliendo por consola de forma cruda para evitar
texto suelto entre marcos. Por ello se soluciona redireccionando el logging a la librería, y desde ese momento una
línea de log es un marco como cualquier otro, que es para lo que existía el
tercer tipo de marco de la sección anterior.

#nota[Del lado del microcontrolador hay dos productores de marcos: respuestas y logs. Por eso todo pasa por una cola y una sola tarea escribe. #pendiente[habrá que sacar esto si hacemos la otra sección de tareas y RTOS.]]

=== Resguardos de seguridad

#pendiente[Es lo del watchdog y lo que se determine puede ayudar a hablar. Falta un refactor para que funcione con algo distinto a lo de ahora, que no me convence.]

=== El programa de orquestación

El programa registra los espacios de nombres, levanta el enlace y
construye los dispositivos, en ese orden.

Y no hay nada que arranque por su cuenta. Toda capacidad de esta imagen se
alcanza desde la PC, así que un arranque que moviera un motor sería riesgo sin
contrapartida.

#pendiente[Esta es la imagen de banco, que existe para ejercitar el enlace, la
librería del driver y el hardware en ese orden. Escribir el programa definitivo,
que es el que decide movimientos por su cuenta, cuando estén cerrados el espacio
`film` y la fuente de pulsos.]

#pendiente[Quizás una seccioncita más hablando de tareas, RTOS, y eso, para justificar la parte de ingeniería.]
