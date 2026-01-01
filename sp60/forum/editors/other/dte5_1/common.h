/*
 * Written by Douglas Thomson (1989/1990)
 *
 * This source code is released into the public domain.
 */

/*
 * This file contains all the includes, defines, types and function
 *  prototypes that are common to all the editor modules.
 */

#include <stdio.h>
#include <string.h>
#include <ctype.h>
#ifdef __TURBOC__
#include <stdlib.h>
#endif

/*
 * The following defines allow the same source code to be compiled under
 *  both K&R C and more modern C compilers that support prototypes.
 */
#ifdef PROTO
#define ARGS(a) a
#else
#define ARGS(a) ()
#endif

#define RECOVERY "DTESAVE"      /* recovery file name */
#define HELPFILE "/usr/local/lib/dte.hlp"   /* help file name */

#define MAX_COLS 80             /* widest screen ever used */
#define MAX_LINES 25            /* highest screen ever used */
#define BUFF_SIZE 256           /* longest line permitted in file */

#define CONTROL(c) ((c) & 0x1F) /* for ASCII control characters */
#ifndef ERROR
#define ERROR (-1)              /* abnormal termination */
#endif
#ifndef OK
#define OK 0                    /* normal termination */
#endif
#ifndef TRUE
#define TRUE 1                  /* logical true */
#endif
#ifndef FALSE
#define FALSE 0                 /* logical false */
#endif

/*
 * The following defines are used by the "error" function, to indicate
 *  how serious the error is.
 */
#define WARNING 1               /* user must acknowledge, editor continues */
#define FATAL 2                 /* editor aborts - very rare! */
#define DIAG 3                  /* error but no pause and editor continues */
#define TEMP 4                  /* not an error, just tell the use what is
                                    going on at the moment */

/*
 * The following defines are used to identify certain position markers in
 *  addition to the usual 0 to 9.
 */
#define START_BLOCK 10          /* marker used for start of blocks */
#define END_BLOCK 11            /* marker used for end of blocks */
#define PREVIOUS 12             /* previous position in text */
#define NO_MARKS 13             /* no. of position markers */

#define GLOB_COUNT 0x7FFF       /* no. of matches for global search */

#define SAVE_NORMAL 0           /* save normal editor file */
#define SAVE_RECOVERY 1         /* save recovery backup file */

/*
 * each screen location needs both a character and an attribute. Here
 *  I have used the IBM PC system, which allows a more efficient
 *  implementation on the PC.
 * Note that this creates all sorts of problems for terminals that
 *  record attribute start and end locations instead of associating
 *  attributes with individual characters.
 */
typedef struct {
    char c;
    char attr;
} screen_chars;

/*
 * each line on the screen is an array of character/attribute pairs
 */
typedef screen_chars screen_lines[MAX_COLS];

/*
 * Some systems (like the PC) require a special kind of pointer for
 *  arrays larger than (say) 64K. Such pointers are always defined
 *  as 'text_ptr's. (Note: only Turbo C's large data memory models
 *  will compile correctly with this code.)
 */
#ifdef __TURBOC__
typedef char huge *text_ptr;
#else
typedef char *text_ptr;
#endif

/*
 * "displays" contain all the status information about what attributes are
 *  used for what purposes, which attribute is currently set, and so on.
 * The editor only knows about one physical screen.
 */
typedef struct {
    int line;                   /* actual line cursor currently on */
    int col;                    /* actual column cursor currently in */
    int nlines;                 /* lines on display device */
    int ncols;                  /* columns on display device */
    int ca_len;                 /* length of cursor addressing string */
    char attr;                  /* current actual attribute */
    char normal;                /* attribute for normal text */
    char flash;                 /* attribute for highlighted text - in fact
                                   flashing would probably not be a good
                                   choice! */
    char block;                 /* attribute for blocked text */
} displays;

/*
 * Since there is only one display, and almost all the functions either
 *  refer to it or need to pass it to lower level functions, it is a
 *  global variable.
 * However, by making it a structure rather than leaving all the fields
 *  as separate global variables, it is much less likely that there will
 *  be any confusion.
 */
extern displays g_display;

/*
 * On some systems, the screen memory can be accessed directly, so
 *  the actual screen is made a pointer.
 * On most systems, the hw_initialize routine will simply allocate
 *  the required about of space.
 */
extern screen_lines *g_screen;

/*
 * "status_infos" contain all the editor status information that is
 *  global to the entire editor (i.e. not dependent on the file or
 *  window)
 */
typedef struct {
    struct s_windows *current_window; /* current active window */
    struct s_file_infos *file_list; /* all active files */
    struct s_windows *window_list; /* all active windows */
    text_ptr match_start;       /* start of matched text */
    text_ptr match_end;         /* end of matched text+1 */
    text_ptr start_mem;         /* first char in main text buffer */
    text_ptr end_mem;           /* last char in main text buffer used+1 */
    text_ptr temp_end;          /* temporary end_mem marker */
    text_ptr max_mem;           /* last char available for storage (+1) */
    int prompt_col;             /* column for putting answer to prompt */
    int prompt_line;            /* line for putting answer to prompt */
    int insert;                 /* in insert mode? */
    int indent;                 /* in auto-indent mode? */
    int unindent;               /* in unindent mode? */
    int tab_size;               /* characters between tab stops */
    int unsaved;                /* file has been modified since autosave? */
    long save_time;             /* time file was last saved (seconds) */
    long save_interval;         /* time between saves */
    char rw_name[MAX_COLS];     /* name of last file read or written */
    char help_file[MAX_COLS];   /* name of help file */
    char recovery[MAX_COLS];    /* file name of recovery file (with path) */
    int ungotcount;             /* no. of chars ungot */
    char ungotbuff[MAX_COLS];   /* ungot characters */
    char line_buff[BUFF_SIZE];  /* for currently edited line */
    int copied;                 /* is line_buff active? */
    text_ptr buff_marker[NO_MARKS]; /* pos markers in line_buff */
    int replace;                /* last search was replace mode? */
    char pattern[MAX_COLS];     /* last search pattern */
    char subst[MAX_COLS];       /* last substitute text */
    int flags;                  /* last search flags */
    char flag_str[MAX_COLS];    /* last flags as string */
    int search_count;           /* no. of searches to do */
    int overlap;                /* overlap between pages for page up etc */
    char wanted;                /* attribute to be used for next output */
} status_infos;

/*
 * Again, the fields here are global to the entire program, so a global
 *  variable is used.
 * Note that some of these fields could be statically initialized,
 *  but I have chosen to initialize them dynamically, since that way I
 *  can refer to each field by name. This also lends itself to eventually
 *  using a configuration file.
 */
extern status_infos g_status;

/*
 * "file_infos" contain all the information unique to a given file
 */
typedef struct s_file_infos {
    text_ptr start_text;        /* first char in file */
    text_ptr end_text;          /* last char in file (+1) */
    int modified;               /* file has been modified since save? */
    int new_file;               /* is current file new? */
    char file_name[MAX_COLS];   /* name of current file being edited */
    text_ptr marker[NO_MARKS];  /* pos markers in main text */
    int visible;                /* is block visible? (not hidden) */
    int ref_count;              /* no. of windows referring to file */
    int file_attrib;            /* file attributes (rwx etc) */
    struct s_file_infos *next;  /* next file in doubly linked list */
    struct s_file_infos *prev;  /* previous file in doubly linked list */
} file_infos;

/*
 * "windows" contain all the information that is unique to a given
 *  window.
 */
typedef struct s_windows {
    file_infos *file_info;      /* file in window */
    text_ptr cursor;            /* start of line containing cursor */
    int ccol;                   /* column cursor logically in */
    int cline;                  /* line cursor logically in */
    int top_line;               /* top line in window */
    int place_line;             /* where to place cursor if redisplaying */
    int bottom_line;            /* bottom line in window */
    int page;                   /* no. of lines to scroll for one page */
    struct s_windows *next;     /* next window in doubly linked list */
    struct s_windows *prev;     /* previous window in doubly linked list */
} windows;

/*
 * the display function calls one of these if a key is pressed
 */
typedef int (*do_func)ARGS((windows *window));

/*
 * prototypes for functions common to all modules, mainly from
 *  hwind.c
 */
void xygoto ARGS((int col, int row));
int eol_clear ARGS((void));
int c_avail ARGS((void));
int c_input ARGS((void));
void c_output ARGS((int c));
void initialize ARGS((void));
void s_output ARGS((char *s));
void terminate ARGS((void));
void line_del ARGS((int line));
void line_ins ARGS((int line));
void c_uninput ARGS((char c));
void editor ARGS((int argc, char *argv[]));
void error ARGS((int kind, ...));
void set_attr ARGS((char attr));
void hw_move ARGS((text_ptr dest, text_ptr source, long number));
void force_blank ARGS((void));
int c_insert ARGS((void));
int c_delete ARGS((void));
int hw_rename ARGS((char *old, char *new));
void window_scroll_up ARGS((int top, int bottom));
void window_scroll_down ARGS((int top, int bottom));
void set_prompt ARGS((char *prompt, int lines));
int hw_fattrib ARGS((char *name));
int hw_set_fattrib ARGS((char *name, int attrib));
int hw_unlink ARGS((char *name));
int hw_printable ARGS((int c));
int hw_save ARGS((char *name, text_ptr start, text_ptr end));
int hw_print ARGS((text_ptr start, text_ptr end));
int hw_append ARGS((char *name, text_ptr start, text_ptr end));
int hw_load ARGS((char *name, text_ptr start, text_ptr limit, text_ptr *end));
void hw_copy_path ARGS((char *old, char *name, char *new));
void os_shell ARGS((void));
