:userdoc.
:title.'Ayuda de Recursos del Sistema OS/2'
:body.

:h1 res=1.Introducción
:i1.Introducción
:artwork name='memsize.bmp' align=center.
:p.
Este programa muestra por pantalla diferentes informaciones sobre los
recursos del sistema, y los actualiza una vez por segundo, si es que el
procesador tiene tiempo para hacerlo. Las informaciones que se muestran
son:
:p.
:hp2.Fecha/Hora:ehp2. - La fecha y hora actual, en el formado normal
de cada país, dependiendo de como esté configurada la línia COUNTRY=
del fichero CONFIG.SYS
:p.
:hp2.Tiempo transcurrido:ehp2. - El tiempo que ha pasado desde la última
vez que se arrancó el ordenador.
:p.
:hp2.Memoria libre:ehp2. - El total de memoria virtual libre, según el valor
devuelto por la función :hp1.DosQuerySysInfo:ehp1.,
menos el espacio de disco
disponible para el fichero de intercambio. Esta es la suma de la
memoria libre y del espacio libre en el interior del fichero de
intercambio, ya que no he sido capaz, aun, de poder separar estos
dos valores.
:p.
:hp2.Tamaño del fichero de intercambio:ehp2. - El tamaño que ocupa en el
disco el fichero de memoria virtual de intercambio (swap), SWAPPER.DAT.
Para localizar este fichero, busque en el fichero CONFIG.SYS la línea
que empieza con SWAPPATH, dónde está indicado el nombre completo
(incluido el directorio) del fichero de intercambio, así como el espacio
que se debe reservar en la unidad dónde se encuentra este fichero.
:p.
:hp2.Espacio disponible para el fichero de intercambio:ehp2. - La
cantidad total de espacio en la unidad de disco dónde se encuentra el
fichero de intercambio, menos la cantidad de espacio que debe
reservarse. Este valor es el tamaño máximo que puede utilizar el fichero
de intercambio.
:p.
:hp2.Tamaño del fichero del spooler:ehp2. - La cantidad total de disco
consumida por los ficheros enviados al spooler de la impresora.
:p.
:hp2.Porcentaje de utilización de la CPU:ehp2. - El porcentaje
aproximado de utilización de la CPU. El valor que se muestra es el
porcentaje correspondiente al promedio de utilización del último
segundo.
:Note.Esta función y el PULSE que se incluye con el OS/2 2.0, no son muy
compatibles.
:p.
:hp2.Número de tareas activas:ehp2. -
El número de elementos en la lista de ventanas, que es la lista que se
visualiza cuando pulsamos CTRL-ESC.
:note.No todas las tareas del sistema se muestran en la Lista de
Ventanas, ya que algunas de estas tareas no son visibles.
:p.
:hp2.Espacio libre total:ehp2. - La suma del espacio libre en todas las
unidades de disco (no removibles).
:p.
:hp2.Espacio libre en la unidad X:ehp2. - La cantidad de espacio libre
en el disco X.
:p.
Esta ayuda es sensible al contexto, como ya se habrá dado cuenta. El
acceso a las siguientes funciones se realiza a través del menú de
sistema de la ventana:
:sl compact.
:li.:hpt.Grabar configuración:ehpt.:hdref res=11.
:li.:hpt.Restaurar los valores por defecto:ehpt.:hdref res=12.
:li.:hpt.Esconder los controles:ehpt.:hdref res=13.
:li.:hpt.Configuración...:ehpt.:hdref res=14.
:li.:hpt.Información del producto:ehpt.:hdref res=15.
:esl.:p.
Aparte de estas funciones, el programa accepta ordenes de los
controladores de fuentes y de la paleta de colores del OS/2 2.0

:h1 res=11.Grabar la configuración (Opción del menú)
:i1.Grabar la configuración (Opción del menú)
Cuando se selecciona esta opción del menú, el programa guarda la posición
actual en la pantalla así como el estado de los controles. La próxima
vez que se ejecute el programa, lo hará en la misma posición y con los
controles ocultos (o visibles), de acuerdo con la información grabada.
:p.
La tecla aceleradora asignada a esta función es F2.

:h1 res=12.Restaurar los valores por defecto (Opción del menú)
:i1.Restaurar los valores por defecto (Opción del menú)
Seleccionado esta opción del menú, se restaura el tipo de letra y los
atributos de color a sus valores por defecto.

:h1 res=13.Esconder los controles (Opción del menú)
:i1.Esconder los controles (Opción del menú)
Cuando esta opción del menú está seleccionada, obliga a los controles de
la ventana del programa (el menú de sistema, la barra con el título y el
botón de minimización) esten ocultos. Es posible variar el valor de esta
función pulsando dos veces el botón del mouse dentro de la ventana.
.br
La tecla aceleradora asignada a esta función es ALT+H.

:h1 res=14.Configuración... (Opción del menú)
:i1.Configuración... (Opción del menú)
Cuando se selecciona esta opción del menú, se muestra la caja de
diálogo de configuración del programa.
:p.
La combinación de teclas ALT+C realiza la misma acción.

:h1 res=140.Configuración... (Caja de diálogo)
:i1.Configuración... (Caja de diálogo)
Esta caja de diálogo muestra la lista de las opociones disponibles y
os permite seleccionar aquellas que desea incluir en la ventana del
programa.
Así mismo, las opciones de ocultar los controlos y de quedar
siempre en primer plano pueden activarse o desactivarse aquí.
También es posible modificar el intervalo de actualización de la
ventana del programa.
:p.
Realizar los cambios que se deseen y pulse la tecla ENTER, o bien
haga un click en el botón "OK", para grabar las modificaciones.
:p.
Para salir sin grabar los cambios realizados, pulsar la tecla ESC o
bien haga un click en el botón "Anular".

:h1 res=15.Información del producto (Opción del menú)
:i1.Información del producto (Opción del menú)
Esta opción muestra, cuando se selecciona, información sobre el
programa.

:h1 res=150.Información del producto (Caja de diálogo)
:i1.Información del producto (Cajaa de diálogo)
Esta caja de diálogo muestra el nombre del programa, el icono y
información sobre los derechos de copia y el autor.

Para salir de esta caja de diálogo, se puede pulsar cualquiera de estas
teclas: ENTER, la barra de espacios o bien ESCAPE. También se puede
salir seleccionando el botón OK con el mouse.

:h1 res=99.Ayuda de las teclas
:i1.Ayuda de las teclas
Las siguientes teclas de función se han definido para el uso de este
programa:
:sl compact.
:li.F1 - Ayuda
:li.F2 - Grabar la configuración
:li.F3 - Salir
:li.Alt+H - Esconder los controles
:esl.:p.

:h1 res=9900.Indicar el directorio del fichero .INI. (Caja de diálogo)
:i1.Indicar el directorio del fichero .INI. (Caja de diálogo)
Esta caja de diálogo se muestra cuando el programa no puede
encontrar su fichero .INI y pregunta cual es el nombre de este
fichero y en qué directorio se encuentra.
:p.
Sólo se acceptan nombres
válidos de directorios ya existentes. Una vez que se haya escrito
el nombre, pulsando INTRO (RETURN) o bien haciendo un click en el
botón "OK" permite al programa continuar su secuencia de
inicialización.
:p.
Si, por contra, se desea cortar la inicialización
del programa, se debe pulsar la tecla ESC o bien hacer un click en
el botón de anulación.

:euserdoc.



