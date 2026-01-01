/* параметры для функции
   toggle_intensity_blinking() */
#define BLINKING 1
#define INTENSITY 0

#define ESCAPE 27     /* коды клавиш, */
#define CTRL_O 15     /* возвращаемые функцией */
#define BACKSPACE 8   /* getkey() */
#define ENTER 13
#define TAB 9
#define HOMEKEY 327
#define ENDKEY 335
#define UPKEY 328
#define DOWNKEY 336
#define PGUPKEY 329
#define PGDNKEY 337
#define LEFTKEY 331
#define RIGHTKEY 333
#define DELKEY 339
#define StrConst "*.*"
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
void restore_text(int left,int top,int right,
               int bottom,char far *sourcetext);
char *edit_string(int row,int startcol,int endcol,
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

int edit_fname(char *fname);
void toggle_switch(int *sw);
# if defined(MAIN)
/* значение старого вектора прерывания 0x1B
   (Ctrl-Break) */
unsigned long OldBreakVector;

int VideoMode;   /* текущий видеорежим */
/* форма курсора: начальная скан-линия в старшем
   байте, конечная - в младшем */
int CursorShape;

# endif