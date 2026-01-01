/* Файл MAKEPRT.H */
/* Автор А.Синев, Copyright (C) 1990,1991 */
/* Turbo C 2.0, Turbo C++ 1.0 */

/* маска для выделения кода специальной клавиши,
   возвращаемого функцией get_choice() */
#define SpecialKeyMask 0x01FF

/* значение, возвращаемое функцией
   break_control(), при преждевременном выходе
   из программы */
#define ABORT 0
/* параметры для функции
   toggle_intensity_blinking() */
#define BLINKING 1
#define INTENSITY 0

#define ESCAPE 27     /* коды клавиш, */
#define CTRL_O 15     /* возвращаемые функцией */
#define BACKSPACE 8   /* getkey() */
#define ENTER 13
#define HOMEKEY 327
#define ENDKEY 335
#define UPKEY 328
#define DOWNKEY 336
#define PGUPKEY 329
#define PGDNKEY 337
#define LEFTKEY 331
#define RIGHTKEY 333
#define DELKEY 339

#define NoCursor 0x2000    /* отмена курсора */


int get_video_mode(void);
int get_cursor_size(void);
void set_cursor_size(int cursorshape);
void set_cursor_position(int column, int row);
unsigned long get_cursor_position_size(void);
void set_cursor_position_size(unsigned long);
void toggle_intensity_blinking(int sw);
int getkey(void);
int string_copy(char far *deststring,
    char far *sourcestring);
void make_hbar(int row,int startcol,int width,
     unsigned char far *sourcestring,
     unsigned char far *deststring);
void clear_nchars(int row,int startcol,
     int nn_chars);
void put_string(int row, int startcol,
     char far *sourcestring);
void update_right(int row,int startcol,
     int endcol,int begstatus,int endstatus,
     int cursorpos_w,char far *cursorpos_s);
void update_left(int row,int startcol,int endcol,
     int begstatus,int endstatus,int cursorpos_w,
     char far *cursorpos_s);
void insert_char(char far *sourcestring,
     int stringlength, int ch);
void delete_char(char far *sourcestring,
     int stringlength);
void make_window(int left,int top,int right,
     int bottom,char far *sourcetext,
     char far *buffer,int windowattr,
     int shadowbackgroundattr,int nn_hotkeys,
     int far *hotkeys, int hotkeyattr);
void get_window_text(int left,int top,int right,
     int bottom,char far *deststring);
void restore_text(int left,int top,int right,
               int bottom,char far *sourcetext);
int get_choice(int firstrow,int lastrow,
    int startcol,int barwidth,int currchoice,
    unsigned char *sourceattr,
    unsigned char *destattr,int nn_altkeys,
    int *altkeys,int bar_status);
int edit_string(int row,int startcol,int endcol,
    int cursorshape,int buffersize,
    char *originalstring,
    unsigned char *sourceattr,
    unsigned char *destattr);

int fexists_mes(int start_row,char *pathname);
void wildcard_mes(int start_row);

unsigned long break_off(void);
void break_on(unsigned long oldbreakvector);
int break_control(void);

void get_pathname(char *pattern,char *ff_name,
     char *pathname);
void shrink_fname(char *shrunkname,char *pathname,
     const char *default_extension);

void menu_on(void);
void menu_off(void);
void dialbox_on(void);
void dialbox_off(void);
int edit_fname(char *fname);
void edit_number(int *number);
void toggle_switch(int *sw);
void process(void);


#if defined(MAIN)

/* строка заголовка страницы */
#define HeadString "File: %-45s Page %d of %d\n"

#define NN_LinesStr "\
\nThe file %s consists of %u lines."
#define NN_PagesStr "\
\nThat will be %d pages of %d lines each."

/* основание системы счисления */
#define Radix 10
/* атрибуты файла для поиска */
#define FF_Attrib (FA_ARCH | FA_RDONLY)

/* строка текста окна меню (45x10) */
#define MenuText "\
┌─────────────────── MENU ──────────────────┐\
│ Read from file                            │\
│ Write to file                             │\
│ Lines per page        60                  │\
│ Odd left margins      10                  │\
│ Even left margins     4                   │\
│ Write page Numbers    On                  │\
│ Screen output         On                  │\
│ Start Processing                          │\
└───────────────────────────────────────────┘"

/* строка текста диалогового окна (43x3) */
#define DialBoxText "\
┌─────────────── File Name ───────────────┐\
│                                         │\
└─────────────────────────────────────────┘"

#define MenuBoxLeft 18    /* координаты окна */
#define MenuBoxTop 7      /* меню на экране */
#define MenuBoxRight 62
#define MenuBoxBottom 16

#define DialBoxLeft 19   /* координаты */
#define DialBoxRight 61  /* диалогового окна */

/* ширина курсора главного меню */
#define MenuBarWidth (MenuBoxRight-MenuBoxLeft-1)

/* размер буфера редактируемой строки */
#define StrBuffSize 65
/* левая координата обновляемой строки в окне
   меню и ее максимальная длина */
#define StrLeftCol 42
#define StrLength 19
/* размер буфера для редактирования чисел */
#define NumbBuffSize 4

/* строки индикации переключателей */
#define OnString "On "
#define OffString "Off"

/* модели имен файлов и их расширения */
#define InFNamePattern "*.TXT"
#define OutFNamePattern "*.PRT"
#define InFExtPattern ".TXT"
#define OutFExtPattern ".PRT"

/* массив кодов альтернативных клавиш */
#define NN_AltKeys 18
int AltKeys[NN_AltKeys] =
    { 'r','R','w','W','l','L','o','O','e','E',
      'n','N','s','S','p','P',ESCAPE,CTRL_O };

/* массив порядковых номеров символов строки
   текста меню (считая от единицы), которые
   в окне будут выделены другим цветом
   (атрибутами "горячих" клавиш) */
#define NN_HotChars 12
int HotCharNumbers[NN_HotChars] =
    {22,23,24,25,48,93,138,183,228,284,318,369};

/* буфер для сохранения участка экрана под
   окном меню (текст с атрибутами) */
char MenuBuffer[2*((MenuBoxRight-MenuBoxLeft+1)+
           2)*((MenuBoxBottom-MenuBoxTop+1)+1)];
/* массив атрибутов курсора главного меню */
unsigned char MenuBar[MenuBarWidth];
/* буфер для сохранения атрибутов экрана
   под курсором */
unsigned char MenuBarBuffer[MenuBarWidth];

/* буфер для сохранения участка экрана под
   диалоговым окном */
char DialBoxBuffer[2*
     ((DialBoxRight-DialBoxLeft+1)+2)*(3+1)];

/* массив атрибутов закрашиваемого бруска в
   диалоговом окне и буфер для старых атрибутов */
unsigned char DialBar[DialBoxRight-DialBoxLeft-2];
unsigned char DialBarBuffer[DialBoxRight-
                            DialBoxLeft-2];

/* массив атрибутов закрашиваемого бруска при
   редактировании чисел */
unsigned char NumbBar[NumbBuffSize-1];
unsigned char NumbBarBuff[NumbBuffSize-1];

/* значения атрибутов для окна главного меню,
   альтернативных (горячих) символов, диалогового
   окна, курсора в главном окне, тени главного
   окна, закрашиваемого бруска при редактировании
   чисел */
int MenuBoxAttr = BLACK + (LIGHTGRAY<<4);
int HotAttr = RED + (LIGHTGRAY<<4);
int DialBoxAttr = WHITE + (CYAN<<4);
int BarAttr = WHITE + (BLACK<<4);
int ShadowAttr = DARKGRAY<<4;
int NumbBarAttr = YELLOW + (MAGENTA<<4);

/* имена входного и выходного файлов */
char InFileName[StrBuffSize+4];
char OutFileName[StrBuffSize+4];

/* режимы открытия файла */
char WriteMode[] = "wt", AppendMode[] = "at";
char *OpenMode;

/* значения по умолчанию: число строк на
   странице, поля для нечетных и четных страниц,
   начальные состояния переключателей */
int LinesPerPage = 60;
int OddMargin = 10;  
int EvenMargin = 4;
int Screen_sw = 1;
int PgNumb_sw = 1;

/* значение старого вектора прерывания 0x1B
   (Ctrl-Break) */
unsigned long OldBreakVector;

/* значение выбора в главном меню */
int Choice;

int VideoMode;   /* текущий видеорежим */
/* форма курсора: начальная скан-линия в старшем
   байте, конечная - в младшем */
int CursorShape;

/* указатель на структуру, используемую для
   сохранения и последующего восстановления
   значений регистров центрального процессора
   функциями setjmp() и longjmp() */
jmp_buf Jumper;

#endif

/* Конец файла MAKEPRT.H */
