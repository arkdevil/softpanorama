/*         ------------------------ DMENU.H -----------------------           

┌────────────────────────────────────────────┐
│  ╔═════╗ ╔╦─╗ ╔╦═╗ ╔╦═╗ ╔╦═╗ ╔╗ ╔╗ ╔═╦╦═╗  │
│  ║╔═══╗║ ║║   ║║   ╚╩╦╗ ║║   ║║ ║║   ║║    │
│  ║╠═══╝║ ║║   ║║═    ║║ ║║═  ║║\║║   ║║    │
│  ║╠════╝ ╚╝   ╚╩═╝ ╚═╩╝ ╚╩═╝ ╚╝ ╚╝   ╚╝    │
│  ║║ ╔═ (C)opyright ═════════════════════╗  │
│  ║║ ║  ──────────  O  L  V ───────────  ║  │
│  ╚╝ ╚══════════════════════════ 1991 г.═╝  │
└────────────────────────────────────────────┘          07.11.1991

*/

/* назначение  аттрибутов цветов:                                             */
#define on +16*
/* определить задание координат всего экрана                                  */
#define ALLSCREEN   1,1,80,25

/* центровка вывода строк : наименования фрейма меню, help, и т.д.            */
#define CENTRLEFT            81     /* центровка : к началу                   */
#define CENTRCENTR           82     /* центровка : в центр                    */
#define CENTRRIGHT           83     /* центровка : к концу                    */
#define CENTRTOP             26     /* центровка : в верх                     */
#define CENTRBOTTOM          28     /* центровка : в низ                      */

/*  расшифровка битов flag в структуре MENU :                                 */
#define      SHADOW 00000001     /* выводить тень нормального размера         */
#define SMALLSHADOW 00000002     /* выводить тень  маленького размера         */

#define WINDOW      00000010     /* залить окно установленными символами      */
#define BORDURE     00000020     /* вывести псевдографический бордюр          */
#define AREASAVE    00000200     /* область экрана под меню сохранить в памяти*/

#define BARMENU     00001000     /* баровое        меню                       */
#define RECOME      00010000     /* разрешает переход в соседнюю опцию меню   */

#define  BORD   0              /* атрибуты (цвет/фон) фрейма рамки           */
#define  WIND   1              /* атрибуты (цвет/фон) окна рамки             */
#define  SHAD   2              /* атрибуты (цвет/фон) теней рамки            */
#define  NORM   3              /* атрибуты (цвет/фон) невыбранной опции меню */
#define  ACTIV  4              /* атрибуты (цвет/фон) выбранной опции меню   */
#define  NOACT  5              /* атрибуты (цвет/фон) неактивной опции меню  */
#define  HIKEY  6              /* атрибуты (цвет/фон) горячей клавиши меню   */
#define  NAME   7              /* атрибуты (цвет/фон) имени фрейма меню      */
#define  HELP   8              /* атрибуты (цвет/фон) HELP-строки            */

#define AREA void
#define MENU void

void   addmenu(MENU * menu);
int    choicemenu(MENU * menu);
MENU * freadmenu (char * filename);
int    fwritemenu(char * filename, MENU * menu);
void   freemenu(MENU * menu);
void   freereadmenu(MENU * menu);
void   helpxy(int xhelp, int yhelp);
void   lenmenu(int len_x, int len_y);
int    menuitem(char * name, int start_x, int start_y, int hikey, int key, char * help);
void   menuxy(int start_x, int start_y);
int    stackmenu(void);
void   namexy(int start_x, int start_y);
void   popsubmenu(void);
int    paint(int start_x, int start_y, int len_x, int len_y, char * string, int attrib);
void   resetmenu(MENU * menu);
MENU * submenu(char * name, char * bord, char * wind, int * attr, int help_y, int flags);

