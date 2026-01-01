/*
 * Written by Douglas Thomson (1989/1990)
 *
 * This source code is released into the public domain.
 */

/*
 * Name:    dte - Doug's Text Editor program - hardware dependent module
 * Purpose: This file contains all the code that needs to be different on
 *           different hardware.
 * File:    hwhpxl.c (actually HWHPXLC due to naming restrictions)
 * Author:  Douglas Thomson
 * System:  This particular version is for the HP3000 running MPE/XL.
 * Date:    October 10, 1989
 * Notes:   This module has been kept as small as possible, to facilitate
 *           porting between different systems.
 *          This is a preliminary version, which does not support any
 *           way to find out whether a character has been typed without
 *           waiting for it. There seems to be no simple way to do this.
 *           I tried using NOWAIT I/O on $STDIN, but it seems that a
 *           pending read (even a NOWAIT read) prevents any further output
 *           to the terminal!!!
 *          Because of this, it is very important to use what HP call a
 *           type ahead engine. This is supplied in a file called:
 *              TYPE.DTS0000.TELESUP
 *           and the required command is:
 *              TYPE.DTS0000.TELESUP ON
 *           which enables type ahead for all subsequent programs. HP
 *           have some justification for not making this the default,
 *           but I confess I could not follow their logic.
 *          Without type ahead, "dte" loses keystrokes all over the place!
 */
#include "commonh"     /* dte types */
#include "hwdeph"      /* prototypes for functions here */
#include "utilsh"      /* for displaying messages etc */
#include "versionh"    /* current version number */
#include <mpe.h>       /* access to MPE intrinsics */
#include <varargs.h>   /* for passing variable numbers of parameters */
#include <fcntl.h>     /* for open flags */

/*
 * prototypes for all functions in this file
 */
static void myputchar ARGS((char c));
static void myputs ARGS((char *s));
void error ARGS((int kind, ...));
static void termset ARGS((char *name));
void main ARGS((int argc, char *argv[]));
static void hw_attr ARGS((char attr));
static void att_stuff ARGS((void));
void att_check ARGS((void));
void hw_xygoto ARGS((void));
int hw_clreol ARGS((void));
int hw_linedel ARGS((int line));
int hw_scroll_up ARGS((int top, int bottom));
int hw_lineins ARGS((int line));
int hw_scroll_down ARGS((int top, int bottom));
int hw_c_avail ARGS((void));
int hw_c_input ARGS((void));
void hw_c_output ARGS((int c));
void hw_terminate ARGS((void));
void hw_initialize ARGS((void));
void hw_move ARGS((text_ptr dest, text_ptr source, long number));
int hw_backspace ARGS((void));
int hw_c_insert ARGS((void));
int hw_c_delete ARGS((void));
int hw_rename ARGS((char *old, char *new));
int hw_fattrib ARGS((char *name));
int hw_set_fattrib ARGS((char *name, int attrib));
int hw_unlink ARGS((char *name));
int hw_printable ARGS((int c));
int hw_load ARGS((char *name, text_ptr start, text_ptr limit, text_ptr *end));
static int write_file ARGS((char *name, char *mode, text_ptr start,
        text_ptr end));
int hw_save ARGS((char *name, text_ptr start, text_ptr end));
int hw_append ARGS((char *name, text_ptr start, text_ptr end));
int hw_print ARGS((text_ptr start, text_ptr end));
void hw_copy_path ARGS((char *old, char *name, char *new));

/*
 * These pragmas provide access to system intrinsics necessary mainly
 *  for direct keyboard input.
 */
#pragma intrinsic COMMAND MPE_COMMAND
#pragma intrinsic FFILEINFO MPE_FFILEINFO
#pragma intrinsic FCONTROL MPE_FCONTROL
#pragma intrinsic FDEVICECONTROL MPE_FDEVICECONTROL
#pragma intrinsic FREAD MPE_FREAD
#pragma intrinsic FWRITE MPE_FWRITE
#pragma intrinsic FRENAME MPE_FRENAME
#pragma intrinsic HPCIPUTVAR MPE_PUTVAR

#define REVERSE 1       /* reverse video (or standout) attribute */
#define HIGH 2          /* high intensity (or underline) attribute */
#define NORMAL 3        /* normal video attribute */

/*
 * The following variables store the appropriate escape sequences for
 *  the current terminal type. This is not very elegant coding, although
 *  the problem with global variables is at least restricted to just this
 *  one source file.
 * Eventually it would be nice to implement some equivalent to a UNIX
 *  termcap file...
 */
static char *t_flash1;  /* start flash attribute */
static char *t_flash0;  /* end flash attribute */
static char *t_block1;  /* start block attribute */
static char *t_block0;  /* end block attribute */
static char *t_eol;     /* erase to end of line */
static char *t_insline; /* insert line */
static char *t_delline; /* delete line */
static char *t_inschar; /* insert character */
static char *t_delchar; /* delete character */
static char *t_defwind; /* define scrollable window */
static char *t_scrup;   /* scroll window up */
static char *t_scrdown; /* scroll window down */
static char *t_cp;      /* cursor positioning */
static int   t_cpoff;   /* cursor positioning offset */
static int   t_hptinit; /* set up HP (700/41) terminal function keys? */

/*
 * Under MPE/XL, text files can either have variable length lines or fixed
 *  length lines. For most purposes (such as program source files) using
 *  variable length lines saves wasting space. However, MPE/XL insists that
 *  job files have fixed length lines. Therefore, the editor must be able to
 *  create either kind of file.
 * This is achieved by checking the name of the executing program: DTE implies
 *  variable length lines, DTEJ implies fixed length lines.
 * The "g_job_file" variable is set TRUE if we are working with job files.
 */
int g_job_file;

/*
 * the following variable determines the size of the memory buffer used. It
 *  is set to something reasonable in main.
 */
static int g_space = 0;

/*
 * Name:    myfflush
 * Purpose: To flush any pending characters in the output buffer.
 * Date:    September 3, 1990
 */
static void myfflush()
{
    fflush(stdout);
}

/*
 * Name:    myputchar
 * Purpose: To output a single character to the display device.
 * Date:    September 3, 1990
 * Passed:  c:  the character to be output
 */
static void myputchar(c)
char c;
{
    putc(c, stdout);
}

/*
 * Name:    myputs
 * Purpose: To output a character string to the display device.
 * Date:    November 6, 1989
 * Passed:  s:  the character string to be output
 */
static void myputs(s)
char *s;
{
    while (*s) {
        myputchar(*s++);
    }
}

/*
 * Name:    error
 * Purpose: To report an error, and usually make the user type <ESC> before
 *           continuing.
 * Date:    October 10, 1989
 * Passed:  kind:   an indication of how serious the error was:
 *                      TEMP:    merely a message, do not wait for <ESC>
 *                      DIAG:    merely a message, but make sure user sees it
 *                      WARNING: error, but editor can continue after <ESC>
 *                      FATAL:   abort the editor!
 *          format: printf format string for any arguments that follow
 *          ...:    arguments to be printed
 * Notes:   This function should be system independent; that is the whole
 *           point of the "stdarg" philosophy. However, two of the systems
 *           I have used implemented "stdarg" incompatibly, and some older
 *           systems may not support the "stdarg" macros at all...
 */
void error(kind, va_alist)
int kind;
va_dcl
{
    char *format;           /* printf format string for error message */
    va_list argptr;         /* used to access various arguments */
    char buff[MAX_COLS];    /* somewhere to store error before printing */
    int c;                  /* character entered by user to continue */

    /*
     * obtain the first two arguments
     */
    va_start(argptr);
    format = va_arg(argptr, char *);

    /*
     * tell the user what kind of an error it is
     */
    switch (kind) {
    case FATAL:
        strcpy(buff, "Fatal error: ");
        break;
    case WARNING:
        strcpy(buff, "Warning: ");
        break;
    case DIAG:
    case TEMP:
        strcpy(buff, "");
        break;
    }

    /*
     * prepare the error message itself
     */
    vsprintf(buff + strlen(buff), format, argptr);
    va_end(argptr);

    /*
     * tell the user how to continue editing if necessary
     */
    if (kind == WARNING || kind == DIAG) {
        strcat(buff, ": type <ESC>");
    }

    /*
     * output the error message
     */
    set_prompt(buff, 1);

    if (kind == FATAL) {
        /*
         * no point in making the user type <ESC>, since the program is
         *  about to abort anyway...
         */
        terminate();
        exit(1);
    }
    else if (kind != TEMP) {
        /*
         * If necessary, force the user to acknowledge the error by
         *  typing <ESC> (or ^U).
         * This prevents any extra commands the user has entered from
         *  causing problems after an error may have made them inappropriate.
         */
        while ((c=c_input()) != 27 && c != CONTROL('U')) {
            set_prompt(buff, 1);
        }
    }
}

/*
 * Name:    termset
 * Purpose: To set an MPE variable to record the terminal type for future
 *           invocations of the editor.
 * Passed:  name:  the name of the terminal (termcap style!)
 * Date:    November 10, 1989
 */
static void termset(name)
char *name;
{
    int length;   /* length of terminal name */
    int status;   /* status of MPE variable setting command */

    length = strlen(name);
    MPE_PUTVAR("DTETERM", &status, 2, name, 11, &length);
}

/*
 * Name:    main
 * Purpose: To do any system dependent command line argument processing,
 *           and then call the main editor function.
 * Date:    November 10, 1989
 * Passed:  argc:   number of command line arguments
 *          argv:   text of command line arguments
 * Notes:   The MPE/XL version needs to determine the type of terminal
 *           currently in use.
 */
void main(argc, argv)
int argc;
char *argv[];
{
    char termc;                     /* terminal identifier */
    char *term;                     /* terminal name */
    static char std_buff[4096];     /* output buffer */

    /*
     * allocate a large output buffer
     */
    setvbuf(stdout, std_buff, _IOFBF, 4096);

    /*
     * work out whether we are working with job files or normal files.
     */
    if (mystrcmpi("DTEJ", argv[0]) == 0) {
        g_job_file = TRUE;
    }
    else {
        g_job_file = FALSE;
    }

    /*
     * see if user specified buffer size
     */
    if (argc > 1 && mystrcmpi("-s", argv[1]) == 0) {
        g_space = atoi(argv[1]+2);
        ++argv;
        --argc;
    }

    /*
     * ensure space is reasonable
     */
    if (g_space < 1000) {
        g_space = 100000;   /* enough for program source code files */
    }

    /*
     * set path for the help file
     */
    hw_copy_path(argv[0], "DTEHELP", g_status.help_file);

    /*
     * Check DTETERM system variable to see if a terminal kind has already
     *  been set.
     */
    termc = '?';
    if ((term = getenv("DTETERM")) != NULL) {
        if (strcmp(term, "vt100") == 0) {
            termc = 'v';
        }
        else if (strcmp(term, "vt220") == 0) {
            termc = '2';
        }
        else if (strcmp(term, "tvi920") == 0) {
            termc = 't';
        }
        else if (strcmp(term, "tvi925") == 0) {
            termc = 'h';
        }
        else if (strcmp(term, "hp2392a") == 0) {
            termc = '9';
        }
        else if (strcmp(term, "dmp") == 0) {
            termc = 'd';
        }
    }

    /*
     * If no system variable, then ask the user to choose from a menu
     *  of supported terminals.
     */
    if (termc == '?') {
        for (;;) {
            myputs("Terminals Available:\n\n");
            myputs("    v) VT100 (VISUAL 300)\n");
            myputs("    2) VT220\n");
            myputs("    h) Televideo 925 (HP700/41)\n");
            myputs("    9) HP 2392A\n");
            myputs("    t) Televideo 920 (PROCOMM)\n");
            myputs("    d) DMP\n\n");

            myputs("Selection: ");
            myfflush();
            switch (getchar()) {
                case 'v':
                case 'V':
                    termc = 'v';
                    termset("vt100");
                    break;
                case '2':
                    termc = '2';
                    termset("vt220");
                    break;
                case 'h':
                case 'H':
                    termc = 'h';
                    termset("tvi925");
                    break;
                case 't':
                case 'T':
                    termc = 't';
                    termset("tvi920");
                    break;
                case '9':
                    termc = '9';
                    termset("hp2392a");
                    break;
                case 'd':
                    termc = 'd';
                    termset("dmp");
                    break;
                default:
                    fflush(stdin);
                    continue;
            }
            break;
        }
    }

    /*
     * now terminal type is known, set the appropriate escape sequences
     */
    switch (termc) {
    case 'v':
        t_flash1 = "\033[1m";       /* start flash attribute */
        t_flash0 = "\033[m";        /* end flash attribute */
        t_block1 = "\033[7m";       /* start block attribute */
        t_block0 = "\033[m";        /* end block attribute */
        t_eol = "\033[K";           /* erase to end of line */
        t_insline = NULL;           /* insert line */
        t_delline = NULL;           /* delete line */
        t_inschar = NULL;           /* insert character */
        t_delchar = NULL;           /* delete character */
        t_defwind = "\033[%d;%dr";  /* define scrollable window */
        t_scrup = "\033M";          /* scroll window up */
        t_scrdown = "\n";           /* scroll window down */
        t_cp = "\033[%d;%dH";       /* cursor positioning */
        t_cpoff = 1;                /* cursor positioning offset */
        break;
    case '2':
        t_flash1 = "\033[1m";       /* start flash attribute */
        t_flash0 = "\033[m";        /* end flash attribute */
        t_block1 = "\033[7m";       /* start block attribute */
        t_block0 = "\033[m";        /* end block attribute */
        t_eol = "\033[K";           /* erase to end of line */
        t_insline = "\033[L";       /* insert line */
        t_delline = "\033[M";       /* delete line */
        t_inschar = NULL;           /* insert character */
        t_delchar = "\033[P";       /* delete character */
        t_defwind = "\033[%d;%dr";  /* define scrollable window */
        t_scrup = "\033M";          /* scroll window up */
        t_scrdown = "\033D";        /* scroll window down */
        t_cp = "\033[%d;%dH";       /* cursor positioning */
        t_cpoff = 1;                /* cursor positioning offset */
        break;
    case 'h':
        t_flash1 = NULL;            /* start flash attribute */
        t_flash0 = NULL;            /* end flash attribute */
        t_block1 = NULL;            /* start block attribute */
        t_block0 = NULL;            /* end block attribute */
        t_eol = "\033T";            /* erase to end of line */
        t_insline = "\033E";        /* insert line */
        t_delline = "\033R";        /* delete line */
        t_inschar = "\033Q";        /* insert character */
        t_delchar = "\033W";        /* delete character */
        t_defwind = NULL;           /* define scrollable window */
        t_scrup = NULL;             /* scroll window up */
        t_scrdown = NULL;           /* scroll window down */
        t_cp = "\033=%c%c";         /* cursor positioning */
        t_cpoff = 32;               /* cursor positioning offset */
        t_hptinit = TRUE;           /* initialize terminal keys */
        break;
    case 't':
        t_flash1 = "\033l";         /* start flash attribute */
        t_flash0 = "\033m";         /* end flash attribute */
        t_block1 = "\033j";         /* start block attribute */
        t_block0 = "\033k";         /* end block attribute */
        t_eol = "\033T";            /* erase to end of line */
        t_insline = "\033E";        /* insert line */
        t_delline = "\033R";        /* delete line */
        t_inschar = "\033Q";        /* insert character */
        t_delchar = "\033W";        /* delete character */
        t_defwind = NULL;           /* define scrollable window */
        t_scrup = NULL;             /* scroll window up */
        t_scrdown = NULL;           /* scroll window down */
        t_cp = "\033=%c%c";         /* cursor positioning */
        t_cpoff = 32;               /* cursor positioning offset */
        break;
    case '9':
        t_flash1 = NULL;            /* start flash attribute */
        t_flash0 = NULL;            /* end flash attribute */
        t_block1 = NULL;            /* start block attribute */
        t_block0 = NULL;            /* end block attribute */
        t_eol = "\033K";            /* erase to end of line */
        t_insline = "\033L";        /* insert line */
        t_delline = "\033M";        /* delete line */
        t_inschar = NULL;           /* insert character */
        t_delchar = "\033P";        /* delete character */
        t_defwind = NULL;           /* define scrollable window */
        t_scrup = NULL;             /* scroll window up */
        t_scrdown = NULL;           /* scroll window down */
        t_cp = "\033&a%dy%dC";      /* cursor positioning */
        t_cpoff = 0;                /* cursor positioning offset */
        break;
    case 'd':
        t_flash1 = "\020";          /* start flash attribute */
        t_flash0 = "\016";          /* end flash attribute */
        t_block1 = "\022";          /* start block attribute */
        t_block0 = "\016";          /* end block attribute */
        t_eol = "\027";             /* erase to end of line */
        t_insline = "\030";         /* insert line */
        t_delline = "\031";         /* delete line */
        t_inschar = "\025";         /* insert character */
        t_delchar = "\026";         /* delete character */
        t_defwind = "\013%c%c";     /* define scrollable window */
        t_scrup = "\005";           /* scroll window up */
        t_scrdown = "\006";         /* scroll window down */
        t_cp = "\002%c%c";          /* cursor positioning */
        t_cpoff = 32;               /* cursor positioning offset */
        break;
    }

    /*
     * now start up the main editor
     */
    editor(argc, argv);
}

/*
 * Name:    hw_attr
 * Purpose: To select a new attribute on the terminal.
 * Date:    October 10, 1989
 * Passed:  attr: the desired attribute
 */
static void hw_attr(attr)
char attr;
{
    static int old_att = -1;         /* existing attribute */

    /*
     * If there has been no change, then ignore the call (actually this
     *  should never happen, since hw_attr is only called when the
     *  attribute HAS changed...
     */
    if (old_att == attr) {
        return;
    }

    /*
     * end the current attribute
     */
    if (old_att != g_display.normal) {
        if (old_att == g_display.flash) {
            if (t_flash0) {
                myputs(t_flash0);
            }
        }
        else if (old_att == g_display.block) {
            if (t_block0) {
                myputs(t_block0);
            }
        }
    }

    /*
     * set the new attribute
     */
    if (attr == g_display.flash) {
        if (t_flash1) {
            myputs(t_flash1);
        }
    }
    else if (attr == g_display.block) {
        if (t_block1) {
            myputs(t_block1);
        }
    }

    /*
     * record new attribute for next time
     */
    old_att = attr;
}

/*
 * Name:    att_stuff
 * Purpose: To make sure that the attribute is set to normal before commands
 *           such as clear to end of line are executed.
 * Date:    October 10, 1989
 * Passed:  [g_display.attr]:   the current attribute
 *          [g_display.normal]: the normal attribute
 * Returns: [g_display.attr]:   set to normal
 * Notes:   This function is necessary because some terminals clear to
 *           spaces using the current attribute, while others clear to
 *           normal spaces. Unfortunately terminfo does not seem to record
 *           this distinction.
 */
static void att_stuff()
{
    if (g_display.attr != g_display.normal) {
        hw_attr(g_display.normal);
        g_display.attr = g_display.normal;
    }
}

/*
 * Name:    att_check
 * Purpose: To check that the attribute required for the next character is
 *           the one currently in effect, and set it if different.
 * Date:    October 10, 1989
 * Passed:  [g_display.attr]:  the current attribute
 *          [g_status.wanted]: the required attribute
 * Returns: [g_display.attr]:  the newly set attribute
 */
void att_check()
{
    if (g_display.attr != g_status.wanted) {
        hw_attr(g_status.wanted);
        g_display.attr = g_status.wanted;
    }
}

/*
 * Name:    hw_xygoto
 * Purpose: To move the cursor to a new position on the screen.
 * Date:    October 10, 1989
 * Passed:  [g_display.line]: the required line
 *          [g_display.col]:  the required column
 */
void hw_xygoto()
{
    char buff[20];  /* for cursor positioning command */

    sprintf(buff, t_cp, g_display.line+t_cpoff, g_display.col+t_cpoff);
    myputs(buff);
}

/*
 * The following locally global variables are used to keep track of the
 *  character in the bottom right corner of the screen.
 * It is not safe to write this character, since most terminals will
 *  scroll the whole screen up a line after writing it.
 * However, if the screen is subsequently scrolled up for any reason, then
 *  this character must appear on the second bottom line!
 * This causes numerous complications in the code which follows...
 */
static char g_mem_c = 0;   /* character supposed to be at bottom right */
static char g_mem_attr;    /* attribute for g_mem_c */

/*
 * Name:    hw_clreol
 * Purpose: To clear from the cursor to the end of the cursor line.
 * Date:    October 10, 1989
 * Returns: TRUE if the hardware could clear to end of line, FALSE otherwise
 */
int hw_clreol()
{
    /*
     * find out if function is available, and give up if not
     */
    if (t_eol == NULL) {
        return FALSE;
    }

    /*
     * clear to end of line, using normal attribute
     */
    att_stuff();
    myputs(t_eol);

    /*
     * If we just cleared the bottom line, then the bottom right character
     *  was cleared too.
     */
    if (g_display.line == g_display.nlines-1) {
        g_mem_c = 0;
    }

    return TRUE;
}

/*
 * Name:    hw_linedel
 * Purpose: To delete the cursor line, scrolling lines below up.
 * Date:    October 10, 1989
 * Passed:  line:  line on screen to be deleted
 * Returns: TRUE if the hardware could delete the line, FALSE otherwise
 */
int hw_linedel(line)
int line;
{
    /*
     * check availability of function
     */
    if (t_delline == NULL) {
        return FALSE;
    }

    /*
     * delete the line
     */
    att_stuff();
    xygoto(0, line);
    myputs(t_delline);

    /*
     * If this caused the bottom line to move up (which will usually be
     *  the case), then add the bottom right character (if any) onto the
     *  second bottom line.
     */
    if (g_mem_c) {
        if (line < g_display.nlines-1) {
            xygoto(g_display.ncols-1, g_display.nlines-2);
            set_attr(g_mem_attr);
            c_output(g_mem_c);
            g_display.col = g_display.line = -1;
        }
        g_mem_c = 0;
    }
    return TRUE;
}

/*
 * Name:    hw_scroll_up
 * Purpose: To scroll the lines in a given region up one line.
 * Date:    October 10, 1989
 * Passed:  top:    the top line in the window
 *          bottom: the bottom line in the window
 * Returns: TRUE if terminal could scroll, FALSE otherwise
 * Notes:   If this function does not exist, then insert and delete line
 *           can achieve the same effect. However, insert and delete line
 *           make lower windows jump, so using terminal scrolling is
 *           preferable.
 */
int hw_scroll_up(top, bottom)
int top;
int bottom;
{
    char buff[20];   /* for window definition command */

    /*
     * check if function is available
     */
    if (t_defwind == NULL || t_scrdown == NULL) {
        return FALSE;
    }

    /*
     * select window to be affected
     */
    att_stuff();
    sprintf(buff, t_defwind, top+t_cpoff, bottom+t_cpoff);
    myputs(buff);
    g_display.col = -1;
    g_display.line = -1;

    /*
     * scroll the window up
     */
    xygoto(0, bottom);
    myputs(t_scrdown);

    /*
     * don't leave a peculiar region scrolling - it confuses all sorts of
     *  things!
     */
    sprintf(buff, t_defwind, 0+t_cpoff, g_display.nlines-1+t_cpoff);
    myputs(buff);
    g_display.col = -1;
    g_display.line = -1;

    /*
     * if the bottom line was scrolled up, then restore the old bottom
     *  right character to the second bottom line
     */
    if (g_mem_c) {
        if (bottom == g_display.nlines-1) {
            xygoto(g_display.ncols-1, g_display.nlines-2);
            set_attr(g_mem_attr);
            c_output(g_mem_c);
            g_display.col = -1;
            g_display.line = -1;
        }
        g_mem_c = 0;
    }

    return TRUE;
}

/*
 * Name:    hw_lineins
 * Purpose: To insert a blank line above the cursor line, scrolling the
 *           cursor line and lines below down.
 * Date:    October 10, 1989
 * Passed:  line:  line on screen to be inserted
 * Returns: TRUE if the hardware could insert the line, FALSE otherwise
 */
int hw_lineins(line)
int line;
{
    /*
     * give up if not available
     */
    if (t_insline == NULL) {
        return FALSE;
    }

    /*
     * insert the line
     */
    att_stuff();
    xygoto(0, line);
    myputs(t_insline);

    /*
     * regardless of where the line was inserted, the bottom line
     *  (including the bottom right character) scrolled off the screen
     */
    g_mem_c = 0;

    return TRUE;
}

/*
 * Name:    hw_scroll_down
 * Purpose: To scroll the lines in a given region down one line.
 * Date:    October 10, 1989
 * Passed:  top:    the top line in the window
 *          bottom: the bottom line in the window
 * Returns: TRUE if terminal could scroll, FALSE otherwise
 * Notes:   If this function does not exist, then insert and delete line
 *           can achieve the same effect. However, insert and delete line
 *           make lower windows jump, so using terminal scrolling is
 *           preferable.
 */
int hw_scroll_down(top, bottom)
int top;
int bottom;
{
    char buff[20];  /* for define window command */

    /*
     * check if function is available
     */
    if (t_defwind == NULL || t_scrup == NULL) {
        return FALSE;
    }

    /*
     * select window to be affected
     */
    att_stuff();
    sprintf(buff, t_defwind, top+t_cpoff, bottom+t_cpoff);
    myputs(buff);
    g_display.col = -1;
    g_display.line = -1;

    /*
     * scroll the window up
     */
    xygoto(0, top);
    myputs(t_scrup);

    /*
     * don't leave a peculiar region scrolling - it confuses all sorts of
     *  things!
     */
    sprintf(buff, t_defwind, 0+t_cpoff, g_display.nlines-1+t_cpoff);
    myputs(buff);
    g_display.col = -1;
    g_display.line = -1;

    /*
     * if the region included the bottom line, then the bottom right
     *  character moved off the screen altogether
     */
    if (bottom == g_display.nlines-1) {
        g_mem_c = 0;
    }

    return TRUE;
}

/*
 * Name:    hw_c_avail
 * Purpose: To test whether or not a character has been typed by the user.
 * Date:    October 10, 1989
 * Returns: TRUE if user typed something, FALSE otherwise
 * Notes:   No simple way to check under MPE/XL, so just pretend the
 *           user waited until the screen was fully updated.
 */
int hw_c_avail()
{
    return FALSE;
}

/*
 * Name:    hw_c_input
 * Purpose: To input a character from the user, without echo, waiting if
 *           nothing has been typed yet.
 * Date:    October 10, 1989
 * Returns: the character the user typed
 * Notes:   A return value of 0 means that what the user typed should be
 *           ignored.
 */
int hw_c_input()
{
    char key;  /* the key the user typed */

    myfflush();  /* first display everything that is pending */

    MPE_FREAD(_mpe_fileno(0), &key, -1);
    return key;
}

/*
 * Name:    hw_c_output
 * Purpose: To output a character, using the current attribute, at the
 *           current screen position.
 * Date:    October 10, 1989
 * Notes:   If the current screen position is the bottom right corner, then
 *           we do not write the character, but merely store it away for
 *           later. (See explanation above.)
 */
void hw_c_output(c)
int c;
{
    if (g_display.line == g_display.nlines-1 &&
            g_display.col == g_display.ncols-1) {
        g_mem_c = c;
        g_mem_attr = g_status.wanted;
        return;
    }
    att_check();
    myputchar(c);
}

/*
 * Name:    hw_terminate
 * Purpose: To restore the terminal to a safe state prior to leaving the
 *           editor.
 * Date:    October 10, 1989
 */
void hw_terminate()
{
    unsigned short status;  /* error status of MPE intrinsic */
    unsigned short command; /* device control command number */

    /*
     * ensure no windows are left (it is annoying to exit the editor and
     *  then find that only the bottom 4 lines of the screen can be used
     *  for other purposes!
     */
    window_scroll_up(0, g_display.nlines-1);

    /*
     * leave the editor text on the screen, but move the cursor to the
     *  bottom line.
     */
    xygoto(0, g_display.nlines-1);
    att_stuff();

    /*
     * restore text mode with echo
     */
    command = 1;
    MPE_FDEVICECONTROL(_mpe_fileno(0), &command, 1, 192, 26, 2, &status);
    command = 0;
    MPE_FDEVICECONTROL(_mpe_fileno(0), &command, 1, 192, 32, 2, &status);
    MPE_FCONTROL(_mpe_fileno(0), 12, &status);
    MPE_FCONTROL(_mpe_fileno(0), 26, &status);
    MPE_FCONTROL(_mpe_fileno(0), 15, &status);

    printf("dte version %sC for MPE/XL %s files\n", VERSION,
            g_job_file ? "job" : "program");
}

/*
 * If the MPE/XL C library contained a function to do overlapping moves
 *  correctly, then only one text buffer would be required. However,
 *  copying individual bytes was too slow, and it was much faster to
 *  copy everything to an extra buffer, and then back to the destination!
 */
static char *g_buffer;

/*
 * Name:    hw_initialize
 * Purpose: To initialize the display ready for editor use.
 * Date:    October 10, 1989
 * Notes:   Typed characters (including ^S and ^Q and ^\) must all be
 *           returned without echoing!
 */
void hw_initialize()
{
    unsigned short result;   /* result of setting up terminal commands */
    unsigned short command;  /* MPE device control command number */
    char buff[20];           /* for cursor positioning command */

    /*
     * allocate space for the screen image
     */
    if ((g_screen = (screen_lines *)malloc(MAX_LINES * sizeof(screen_lines)))
            == NULL) {
        printf("no memory for screen image\n");
        exit(1);
    }

    /*
     * set up terminal screen size
     */
    g_display.ncols = 80;
    g_display.nlines = 24;

    /*
     * work out the length of the cursor addressing command, so we can
     *  choose the quickest way of getting anywhere
     */
    sprintf(buff, t_cp, 24+t_cpoff, 80+t_cpoff);
    g_display.ca_len = strlen(buff);

    /*
     * set up raw input with no echo etc
     */
    MPE_FCONTROL(_mpe_fileno(0), 13, &result);
    MPE_FCONTROL(_mpe_fileno(0), 14, &result);
    command = 0;
    MPE_FDEVICECONTROL(_mpe_fileno(0), &command, 1, 192, 26, 2, &result);
    command = 0;
    MPE_FDEVICECONTROL(_mpe_fileno(0), &command, 1, 192, 32, 2, &result);
    MPE_FCONTROL(_mpe_fileno(0), 27, &result);

    /*
     * set up video attributes
     */
    g_display.block = REVERSE;
    g_display.flash = HIGH;
    g_display.normal = NORMAL;
    g_display.attr = NORMAL;
    hw_attr(NORMAL);

    if (t_hptinit) {
        /*
         * initialize function keys, select terminal emulation
         */
        printf("\033~\"\033~ ");
        printf("\033z#%c\177", CONTROL('G'));
        printf("\033z&%c\177", CONTROL('I'));
        printf("\033z+%c\177", CONTROL('E'));
        printf("\033z,%c\177", CONTROL('X'));
        printf("\033z-%c\177", CONTROL('S'));
        printf("\033z.%c\177", CONTROL('D'));
        printf("\033z/%c%c\177", CONTROL('Q'), CONTROL('E'));
        printf("\033~$\033\"\033'");
        fflush(stdout);
    }

    /*
     * allocate space for the main text buffer and the copying buffer
     */
    if ((g_status.start_mem = (char *)malloc(g_space)) == NULL) {
        error(FATAL, "out of memory for text");
    }
    g_status.max_mem = g_status.start_mem + g_space;
    if ((g_buffer = (char *)malloc(g_space)) == NULL) {
        error(FATAL, "out of memory for buffer");
    }
}

/*
 * Name:    hw_move
 * Purpose: To move data from one place to another as efficiently as
 *           possible.
 * Date:    October 10, 1989
 * Passed:  dest:   where to copy to
 *          source: where to copy from
 *          number: number of bytes to copy
 * Notes:   moves may be (usually will be) overlapped
 */
void hw_move(dest, source, number)
text_ptr dest;
text_ptr source;
long number;
{
    if (number < 0) {
        /*
         * this should never happen...
         */
        error(WARNING, "negative move - contact Douglas Thomson!");
    }
    else if (source == dest) {
        /*
         * nothing to be done
         */
        ;
    }
    else {
        /*
         * no overlapping move available, so copy to buffer and back
         */
        memcpy(g_buffer, source, number);
        memcpy(dest, g_buffer, number);
    }
}

/*
 * Name:    hw_backspace
 * Purpose: To move the cursor left one position.
 * Date:    October 10, 1989
 * Returns: TRUE if the hardware could backspace, FALSE otherwise
 * Notes:   This function is used where deletion requires a backspace,
 *           space, backspace. If the terminal can backspace, this may
 *           be much faster than using cursor addressing.
 */
int hw_backspace()
{
    myputchar('\b');
    return TRUE;
}

/*
 * Name:    hw_c_insert
 * Purpose: To insert a blank character under the cursor.
 * Date:    October 10, 1989
 * Returns: TRUE if the hardware could insert the space, FALSE otherwise
 * Notes:   This function is used where the user has just typed a character
 *           in the middle of a line in insert mode. If it is available, it
 *           saves having to redraw the entire remainder of the line.
 *          No assumptions are made about the contents or attribute of the
 *           inserted character.
 */
int hw_c_insert()
{
    if (t_inschar == NULL) {
        return FALSE;
    }

    myputs(t_inschar);

    if (g_mem_c && g_display.line == g_display.nlines-1) {
        g_mem_c = 0;
    }

    return TRUE;
}

/*
 * Name:    hw_c_delete
 * Purpose: To delete the character under the cursor.
 * Date:    October 10, 1989
 * Returns: TRUE if the hardware could delete the character, FALSE otherwise
 * Notes:   This function is used where the user has deleted a character
 *           in the middle of a line. If it is available, it saves having to
 *           redraw the entire remainder of the line.
 *          The rightmost character on the line after the delete is assumed
 *           to be a space character with normal attribute.
 */
int hw_c_delete()
{
    if (t_delchar == NULL) {
        return FALSE;
    }

    myputs(t_delchar);

    /*
     * bottom right corner character could need to reappear one
     *  character in from the right
     */
    if (g_mem_c && g_display.line == g_display.nlines-1) {
        if (g_display.col < g_display.ncols-2) {
            xygoto(g_display.ncols-2, g_display.nlines-1);
            set_attr(g_mem_attr);
            c_output(g_mem_c);
            g_display.col = g_display.line = -1;
        }
        g_mem_c = 0;
    }

    return TRUE;
}

/*
 * Name:    hw_rename
 * Purpose: To rename a disk file to a new name.
 * Date:    October 10, 1989
 * Passed:  old: current file name
 *          new: new desired file name
 * Returns: OK if rename succeeded, ERROR if any problem
 */
int hw_rename(old, new)
char *old;
char *new;
{
    return rename(old, new);
}

/*
 * Name:    hw_fattrib
 * Purpose: To determine the current file attributes.
 * Date:    October 17, 1989
 * Passed:  name: name of file to be checked
 * Returns: current read/write/execute etc attributes of the file, or
 *          ERROR if file did not exist etc.
 */
int hw_fattrib(name)
char *name;
{
    FILE *fp;

    /*
     * The MPE/XL implementation is very simple-minded.
     */
    if ((fp = fopen(name, "r")) == NULL) {
        return ERROR;
    }
    fclose(fp);
    return OK;
}

/*
 * Name:    hw_set_fattrib
 * Purpose: To set the current file attributes.
 * Date:    October 17, 1989
 * Passed:  name:   name of file to be changed
 *          attrib: the required attributes
 * Returns: new read/write/execute etc attributes of the file, or
 *          ERROR if file did not exist etc.
 * Notes:   If "attrib" is ERROR, then do not change attributes.
 */
int hw_set_fattrib(name, attrib)
char *name;
int attrib;
{
    if (attrib == ERROR) {
        return ERROR;
    }
    return OK;
}

/*
 * Name:    hw_unlink
 * Purpose: To delete a file, regardless of access modes.
 * Date:    October 17, 1989
 * Passed:  name:   name of file to be removed
 * Returns: OK if file could be removed
 *          ERROR otherwise
 */
int hw_unlink(name)
char *name;
{
    FILE *fp;

    /*
     * Open file in such a way that it will be removed when closed -
     *  seems an odd way to do things, but the MPE/XL library
     *  has no unlink().
     */
    if ((fp = fopen(name, "r Df4")) == NULL) {
        return ERROR;
    }
    return fclose(fp);
}

/*
 * Name:    hw_printable
 * Purpose: To determine whether or not a character is printable on the
 *           current hardware.
 * Date:    October 18, 1989
 * Passed:  c: the character to be tested
 * Returns: TRUE if c is a visible character, FALSE otherwise
 * Notes:   This is hardware dependent so that machines like the IBM PC can
 *           edit files containing graphics characters.
 */
int hw_printable(c)
int c;
{
   return (c >= 32 && c < 127);
}

/*
 * Name:    hw_load
 * Purpose: To load a file into the text buffer.
 * Date:    November 11, 1989
 * Passed:  name:  name of disk file
 *          start: first character in text buffer
 *          limit: last available character in text buffer
 *          end:   last character (+1) from the file
 * Returns: OK, or ERROR if anything went wrong
 * Notes:   All error messages are displayed here, so the caller should
 *           neither tell the user what is happening, nor print an error
 *           message if anything goes wrong.
 *          This function is in the hardware dependent module because
 *           some computers require non-standard open parameters...
 */
int hw_load(name, start, limit, end)
char *name;
text_ptr start;
text_ptr limit;
text_ptr *end;
{
    int fd;             /* file being read */
    int length;         /* number of bytes actually read */
    short code;         /* file type code */
    foptions foption;   /* for determining if file is ASCII */

    /*
     * try reading the file, trimming trailing space and editor line
     *  numbers.
     */
    if ((fd = open(name, O_RDONLY|O_MPEOPTS, 0, "Tm")) == ERROR) {
        error(WARNING, "File '%s' not found", name);
        return ERROR;
    }

    /*
     * check file is ASCII text file
     */
    code = -1;
    MPE_FFILEINFO(_mpe_fileno(fd), 8, &code);
    if (code != 0) {
        close(fd);
        error(WARNING, "cannot edit this file type (%d)", code);
        return ERROR;
    }
    foption.fs.ascii = 0;
    MPE_FFILEINFO(_mpe_fileno(fd), 2, &foption.fv);
    if (foption.fs.ascii != 1) {
        close(fd);
        error(WARNING, "only ASCII text files can be edited");
        return ERROR;
    }

    /*
     * tell the user what is happening
     */
    error(TEMP, "Reading file '%s'...", name);

    /*
     * read the entire file, without going past end of buffer.
     * Note that this means a file that is within 1K of the limit
     *  will not be accepted.
     */
    limit -= 1024;
    for (;;) {
        if (start >= limit) {
            error(WARNING, "file '%s' too big", name);
            close(fd);
            return ERROR;
        }
        if ((length = read(fd, (char *)start, 1024)) == ERROR) {
            error(WARNING, "could not read file '%s'", name);
            close(fd);
            return ERROR;
        }
        start += length;
        if (length == 0) {
            /*
             * we reached the end of file
             */
            break;
        }
    }

    /*
     * close the file and report the final character in the buffer
     */
    close(fd);
    *end = start;

    return OK;
}

/*
 * Name:    write_file
 * Purpose: To write text to a file, eliminating trailing space on the
 *           way.
 * Date:    November 11, 1989
 * Passed:  name:  name of disk file or device
 *          mode:  fopen flags to be used in open
 *          start: first character in text buffer
 *          end:   last character (+1) in text buffer
 * Returns: OK, or ERROR if anything went wrong
 * Notes:   Trailing space at the very end of the text is NOT removed,
 *           so that a block write of a block of spaces will work.
 *          No error messages are displayed here, so the caller must
 *           both tell the user what is happening, and print an error
 *           message if anything goes wrong.
 *          This function is in the hardware dependent module because
 *           some computers require non-standard open parameters...
 */
static int write_file(name, mode, start, end)
char *name;
char *mode;
text_ptr start;
text_ptr end;
{
    FILE *fp;       /* file to be written */
    int spaces;     /* no. of space characters pending */
    char c;         /* current character in file */

    /*
     * create a new file, or truncate an old one
     */
    if ((fp = fopen(name, mode)) == NULL) {
        return ERROR;
    }

    /*
     * save the file, eliminating trailing space
     */
    spaces = 0;
    for (;;) {
        if (start == end) {
            break;
        }
        if ((c = *start++) == ' ') {
            spaces++;   /* count them, maybe output later */
            continue;
        }

        if (c == '\n') {
            spaces = 0; /* eliminate the trailing space */
        }
        else if (spaces) {
            /*
             * the spaces were NOT trailing, so output them now
             */
            do {
                if (putc(' ', fp) == ERROR) {
                    fclose(fp);
                    return ERROR;
                }
            } while (--spaces);
        }

        if (putc(c, fp) == ERROR) {
            fclose(fp);
            return ERROR;
        }
    }

    /*
     * output any trailing space at end of file - this may be important
     *  for block writes.
     */
    if (spaces) {
        do {
            if (putc(' ', fp) == ERROR) {
                fclose(fp);
                return ERROR;
            }
        } while (--spaces);
    }

    return fclose(fp);
}

/*
 * Name:    hw_save
 * Purpose: To save text to a file, eliminating trailing space on the
 *           way.
 * Date:    November 11, 1989
 * Passed:  name:  name of disk file
 *          start: first character in text buffer
 *          end:   last character (+1) in text buffer
 * Returns: OK, or ERROR if anything went wrong
 * Notes:   Trailing space at the very end of the file is NOT removed,
 *           so that a block write of a block of spaces will work.
 *          No error messages are displayed here, so the caller must
 *           both tell the user what is happening, and print an error
 *           message if anything goes wrong.
 *          This function is in the hardware dependent module because
 *           some computers require non-standard open parameters...
 */
int hw_save(name, start, end)
char *name;
text_ptr start;
text_ptr end;
{
    return write_file(name, g_job_file ? "w Ds1 R80" : "w Ds1 V", start, end);
}

/*
 * Name:    hw_append
 * Purpose: To append text to a file.
 * Date:    November 11, 1989
 * Passed:  name:  name of disk file
 *          start: first character in text buffer
 *          end:   last character (+1) in text buffer
 * Returns: OK, or ERROR if anything went wrong
 * Notes:   No error messages are displayed here, so the caller must
 *           both tell the user what is happening, and print an error
 *           message if anything goes wrong.
 *          This function is in the hardware dependent module because
 *           some computers require non-standard open parameters...
 */
int hw_append(name, start, end)
char *name;
text_ptr start;
text_ptr end;
{
    return write_file(name, "a Ds1", start, end);
}

/*
 * Name:    hw_print
 * Purpose: To print text to a printer.
 * Date:    November 11, 1989
 * Passed:  start: first character in text buffer
 *          end:   last character (+1) in text buffer
 * Returns: OK, or ERROR if anything went wrong
 * Notes:   This function is in the hardware dependent module because
 *           some computers require non-standard open parameters...
 */
int hw_print(start, end)
text_ptr start;
text_ptr end;
{
    char command[300];      /* printer device command */
    char *device;           /* printer device name */
    unsigned short status;  /* printer file equation status */
    unsigned short param;   /* more info about any error */

    /*
     * work out where to print
     */
    for (;;) {
        strcpy(command, "2");
        if (get_name("Printer 1N208 (1), 2S125 (2), Computer Center (3): ",
                1, command) != OK) {
            return ERROR;
        }
        switch (atoi(command)) {
        case 1:
            device = "300";
            break;
        case 2:
            device = "309";
            break;
        case 3:
            device = "6";
            break;
        default:
            continue;
        }
        break;
    }
    sprintf(command, "FILE LP;DEV=%s\r", device);
    MPE_COMMAND(command, &status, &param);
    if (status) {
        error(WARNING, "File equation error %d/%d", status, param);
        return ERROR;
    }

    /*
     * print file
     */
    return write_file("LP", "a Ds1", start, end);
}

/*
 * Name:    hw_copy_path
 * Purpose: To create a new file path using most of an old path but
 *           changing just the file name.
 * Date:    November 8, 1989
 * Passed:  old:   the file path to extract path info from
 *          name:  the file name to add to the extracted path info
 * Returns: new:   the new path
 * Notes:   The file is located in the same place as the original, so
 *           that related editor files stay in the same directory.
 *          This function is hardware dependent because different characters
 *           delimit directories on different systems.
 */
void hw_copy_path(old, name, new)
char *old;
char *name;
char *new;
{
    char *cp;           /* cutoff point in old path */

    strcpy(new, name);
    if ((cp = strchr(old, '.')) != NULL) {
        strcat(new, cp);
    }
}

/*
 * Name:    hw_os_shell
 * Purpose: To shell out of the editor into the operating system, in such a
 *           way that editing may be resumed later.
 * Date:    November 28, 1990
 * Returns: TRUE if screen may have been clobbered, FALSE if screen OK.
 */
int hw_os_shell()
{
    return FALSE;   /* not implemented - possible for unpriviledged users? */
}
