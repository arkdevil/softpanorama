:userdoc.
:title.'Ajuda de Recursos del Sistema OS/2'
:body.

:h1 res=1.Introducció
:i1.Introducció
:artwork name='memsize.bmp' align=center.
:p.
Aquest programa mostra per pantalla diferents informacions sobre
els recursos del sistema, i les actualiza una vegada per segon,
si es que el processador té temps per a fer-ho. Les informacions
mostrades són:
:p.
:hp2.Data/Hora:ehp2. - La data i hora actual, en el format normal
de cada país, depenent de com estigui configurada la línia COUNTRY=
al fitxer CONFIG.SYS
:p.
:hp2.Temps transcorregut:ehp2. - El temps que ha passat des de la darrera
ocasió en que s'ha arrencat l'ordinador.
:p.
:hp2.Memòria lliure:ehp2. - El total de memòria virtual lliure, d'acord
amb la funció :hp1.DosQuerySysInfo:ehp1.,
menys l'espai de disc disponible per al
fitxer d'intercanvi. Aquesta és la suma de memòria lliure i de
l'espai lliure a l'interior del fitxer d'intercanvi, doncs encara
no he sigut capaç de poder separar aquests dos valors.
:p.
:hp2.Tamany del fitxer d'intercanvi:ehp2. - El tamany que ocupa al disc el
fitxer de memòria virtual d'intercanvi (swap), SWAPPER.DAT. Per
localitzar aquest fitxer, busqueu al fitxer CONFIG.SYS la línia que
comença amb SWAPPATH, on trobareu indicat el nom complet (inclòs el
directori) del fitxer d'intercanvi, així com l'espai que cal reservar a
la unitat on es troba situat aquest fitxer.
:p.
:hp2.Espai disponible pel fitxer d'intercanvi:ehp2. - La quantitat total
d'espai a la unitat de disc on es troba el fitxer d'intercanvi, menys la
quantitat d'espai que cal reservar. Aquest valor és el tamany màxim que
pot utilitzar el fitxer d'intercanvi.
:p.
:hp2.Tamany del fitxer d'spool:ehp2. - La quantitat total de disc consumida
pels fitxers enviats a l'spooler d'impressora.
:p.
:hp2.Percentatge d'ús de la CPU:ehp2. - El percentatge aproximat d'ús
del processador. El valor que es mostra és el percentatge corresponent
al promig d'utilització del darrer segon.
:note.Aquesta funció i el PULSE que s'inclou amb l'OS/2 2.0, no són gaire compatibles.
:p.
:hp2.Número de tasques actives:ehp2. -
El número d'entrades a lliista de finestres, que és la llista de veieu quan
premeu CTRL-ESC.
:note.No totes les tasques del sistema són mostrades a la Llista de
Finteses, donat que algunes tasques no són visibles.
:p.
:hp2.Espai lliure total:ehp2. - La suma de l'espai lliure a totes les
unitats de disc no removibles.
:p.
:hp2.Espai lliure a la unitat X:ehp2. - La quanitat total d'espai lliure a
la unitat de disc X.
:p.
Aquesta ajuda és sensible al contexte, com ja se n'haureu adonat.
L'accés a les següents funcions es fa a través del menú de sistema de
la finestra:
:sl compact.
:li.:hpt.Guardar configuració:ehpt.:hdref res=11.
:li.:hpt.Restaurar els valors per defecte:ehpt.:hdref res=12.
:li.:hpt.Amagar els controls:ehpt.:hdref res=13.
:li.:hpt.Configuració...:ehpt.:hdref res=14.
:li.:hpt.Informació del programa:ehpt.:hdref res=15.
:esl.:p.
A més d'aquestes funcions descrites, el programa accepta ordres dels
controladors de fonts i de la paleta de colors de l'OS/2 2.0

:h1 res=11.Guardar configuració (Opció del menú)
:i1.Guardar configuració (Opció del menú)
Quan seleccioneu aquesta opció del menú, el programa guarda la possició
actual a la pantalla així com l'estat dels controls. La propera vegada
que s'executi el programa, ho farà a la mateixa possició i amb els
controls amagats (o visibles), d'acord amb la informació gravada.
:p.
La tecla acceleradora assignada a aquesta funció és F2.

:h1 res=12.Restaurar els valors per defecte (Opció del menú)
:i1.Restaurar els valors per defecte (Opció del menú)
Seleccionant aquesta opció del menú, es restaura el tipus de lletra i
els atributs de color als seus valors per defecte.

:h1 res=13.Amagar els controls (Opció del menú)
:i1.Amagar els controls (Opció del menú)
Aquesta opció del menú, quan està seleccionada, fa que els controls de
la finestra del programa (el menú de sistema, la barra del títol i el botó
de minimització) s'amagin. És possible variar el valor d'aquesta funció
si premeu dues vegades el botó del mouse dintre de la finestra.
:p.
La tecla acceleradora assignada a aquesta funció és ALT+H.

:h1 res=14.Configuració... (Opció del menú)
:i1.Configuració... (Opció del menú)
Quan seleccioneu aquesta opció del menú es mostrarà la capsa de
diàleg de configuració del programa.
:p.
La combinació de tecles ALT+C realitza la mateixa acció.

:h1 res=140.Configuració... (Capsa de diàleg)
:i1.Configuració... (Capsa de diàleg)
Aquesta capsa de diàleg mostra la llista d'opcions disponibles i us
permet de seleccionar aquelles que voleu incloure a la finestra del
programa.
Així mateix, les opcions d'amagar els control i de restar sempre en
primer pla poden activar-se o desactivar-se aquí. També podeu
modificar l'interval d'actualització de la finestra del programa.
:p.
Realitzar els canvis que desitgeu i premeu la tecla ENTER o bé feu
un click al botó "OK" per grabar aquest canvis i que tinguin
efecte.
:p.
Per avortar sense grabar qualsevol canvi que hagiu fet, premeu la
tecla ESC o bé feu un click al botó "Anulzlar"

:h1 res=15.Informació del programa (Opció del menú)
:i1.Informació del programa (Opció del menú)
Aquesta opció ofereix, quan es selecciona, informació sobre el programa.

:h1 res=150.Informació del programa (Capsa de diàleg)
:i1.Informació del programa (Capsa de diàleg)
Aquesta capsa de diàleg mostra el nom del programa, la icona i
informació sobre els drets de còpia i l'autor.

Per sortir d'aquesta capsa de diàleg, podeu prémer qualsevol d'aquestes
tecles: ENTER, la barra d'espais o bé ESCAPE. També es possible sortir
seleccionat el butó OK del mouse.

:h1 res=99.Ajuda de les tecles
:i1.Ajuda de les tecles
Les següents tecles de funció s'han definit per aquest programa:
:sl compact.
:li.F1 - Ajuda
:li.F2 - Guardar configuració
:li.F3 - Finalitzar
:li.Alt+H - Amagar els controls
:esl.:p.

:h1 res=9900.Indicar el directori del fitxer .INI (Capsa de diàleg)
:i1.Indicar el directori del fitxer .INI (Capsa de diàleg)
Aquesta capsa de diàleg es mostra quan el programa no pot trobar el
seu fitxer .INI, i pregunta quin és el nom d'aquest fitxer i a quin
directori es troba.
:p.
Només s'accepten noms vàlids de directoris ja
existents. Una vegada que hagiu escrit el nom, prement la tecla
INTRO (RETURN) o bé fent un click al botó "OK" fa que el programa
continuï la seva seqüència d'inicialització.
:p.
Si, per contra, voleu tallar la inicialització del programa, premeu
la tecla ESC o bé feu un click al botó d'anulzlació.

:euserdoc.





