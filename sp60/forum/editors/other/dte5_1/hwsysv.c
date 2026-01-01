/*
 * Written by Douglas Thomson (1989/1990)
 * Modified for pure System V release 2 by Jay Maynard (1990)
 *
 * This source code is released into the public domain.
 */

/*
 * Name:    dte - Doug's Text Editor program - hardware dependent module
 * Purpose: This file contains all the code that needs to be different on
 *           different hardware.
 * File:    hwsysv.c
 * Authors: Douglas Thomson and Jay Maynard
 * System:  This particular version is for generic System V release 2,
 *           although it should suit most versions of UNIX system V.
 * Date:    28 November 1990
 * Notes:   This module has been kept as small as possible, to facilitate
 *           porting between different systems.
 */
#include <curses.h>     /* used to access terminfo database */
#include <term.h>       /* used to set terminal modes */
#include <fcntl.h>      /* used to set up stdin with no delay reads */
#include <signal.h>     /* used to trap various signals (future?) */
#include <varargs.h>    /* used to pass a variable no. of arguments */
#include "common.h"     /* dte types */
#include "hwdep.h"      /* prototypes for functions here */
#include "utils.h"      /* prototypes for display/input etc */
#include "version.h"    /* current version number */

/*
 * A bug in some versions of elm causes editing sessions not to be killed
 *  when elm is killed (for example when a modem user unplugs the 'phone
 *  while editing mail!).
 * The editor process is inherited by the init process, so all I do here
 *  is have the editor commit suicide if it detects that its parent has
 *  died.
 */
#define ELM_BUG

/*
 * prototypes for all functions in this file
 */
void error ARGS((int kind, ...));
static void myputchar ARGS((char c));
static void hw_attr ARGS((char attr));
static void att_check ARGS((void));
void att_stuff ARGS((void));
void hw_xygoto ARGS((void));
int hw_clreol ARGS((void));
int hw_linedel ARGS((int line));
int hw_lineins ARGS((int line));
int hw_backspace ARGS((void));
int hw_c_insert ARGS((void));
int hw_c_delete ARGS((void));
void hw_c_output ARGS((int c));
void hw_terminate ARGS((void));
static void process_input ARGS((void));
void hw_initialize ARGS((void));
int hw_c_avail ARGS((void));
int hw_c_input ARGS((void));
void main ARGS((int argc, char *argv[]));
void hw_move ARGS((text_ptr dest, text_ptr source, long number));
int hw_rename ARGS((char *old, char *new));
int hw_scroll_up ARGS((int top, int bottom));
int hw_scroll_down ARGS((int top, int bottom));
int min ARGS((int a, int b));
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

#define REVERSE 1       /* reverse video (or standout) attribute */
#define HIGH 2          /* high intensity (or underline) attribute */
#define NORMAL 3        /* normal video attribute */

#define UNKNOWN 7       /* flag not yet set to TRUE or FALSE */

char *malloc(/*!void*/);     /* memory allocator - this keeps lint happy */

/*
 * the following variable determines the size of the memory buffer used. It
 *  is set to something reasonable in main.
 */
static int g_space = 0;

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
 *           point of the "varargs" philosophy. However, two of the systems
 *           I have used implemented "varargs" incompatibly, and some older
 *           systems may not support the "varargs" macros at all...
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
 * Name:    myputchar
 * Purpose: To output one character to the display terminal.
 * Date:    October 10, 1989
 * Passed:  c: character to be displayed
 * Notes:   This function makes the write system call directly, to try to
 *           minimize the amount of buffering that takes place. (Since this
 *           editor tries to respond quickly to new commands, we do not
 *           want a whole screenful of output stored in a buffer waiting
 *           to be sent to the terminal!)
 *          For very high speed terminals, it may be more appropriate to
 *           encourage buffering... writing just one character has the
 *           disadvantage that under heavy load screen update sometimes
 *           "freezes" temporarily while other processes run!
 */
static void myputchar(c)
char c;
{
    putc(c, stdout);
/*    write(1, &c, 1); */
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
     * If we want the normal attribute, then there may be an easy way of
     *  getting it without undoing other attributes.
     */
    if (attr == g_display.normal) {
        if (exit_attribute_mode) {
            tputs(exit_attribute_mode, 1, myputchar);
            old_att = attr;
            return;
        }
    }

    /*
     * end the current attribute
     */
    if (old_att != g_display.normal) {
        if (old_att == g_display.flash) {
            tputs(exit_underline_mode, 1, myputchar);
        }
        else if (old_att == g_display.block) {
            tputs(exit_standout_mode, 1, myputchar);
        }
    }

    /*
     * set the new attribute
     */
    if (attr == REVERSE) {
        tputs(enter_standout_mode, 1, myputchar);
    }
    else if (attr == HIGH) {
        tputs(enter_underline_mode, 1, myputchar);
    }

    /*
     * record new attribute for next time
     */
    old_att = attr;
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
static void att_check()
{
    if (g_display.attr != g_status.wanted) {
        hw_attr(g_status.wanted);
        g_display.attr = g_status.wanted;
    }
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
void att_stuff()
{
    if (g_display.attr != g_display.normal) {
        hw_attr(g_display.normal);
        g_display.attr = g_display.normal;
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
    if (!move_standout_mode) {
        /*
         * some terminals can only move the cursor when in normal video
         *  mode
         */
        att_stuff();
    }
    tputs(tparm(cursor_address, g_display.line, g_display.col), 1, myputchar);
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
    static int avail = UNKNOWN;  /* can terminal do it? */

    /*
     * find out if function is available, and give up if not
     */
    if (avail == UNKNOWN) {
        avail = strlen(clr_eol) > 0;
    }
    if (!avail) {
        return FALSE;
    }

    /*
     * clear to end of line, using normal attribute
     */
    att_stuff();
    tputs(clr_eol, 1, myputchar);

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
    static int avail = UNKNOWN; /* can terminal do it? */

    /*
     * check availability of function
     */
    if (avail == UNKNOWN) {
        avail = strlen(delete_line) > 0;
    }
    if (!avail) {
        return FALSE;
    }

    /*
     * delete the line
     */
    att_stuff();
    xygoto(0, line);
    tputs(delete_line, 1, myputchar);

    /*
     * If this caused the bottom line to move up (which will usually be
     *  the case), then add the bottom right character (if any) onto the
     *  second bottom line.
     */
    if (g_mem_c) {
        if (line < g_display.nlines-1) {
            xygoto(g_display.ncols-1, g_display.nlines-2);
            if (g_display.attr != g_mem_attr) {
                hw_attr(g_mem_attr);
                g_display.attr = g_mem_attr;
            }
            myputchar(g_mem_c);

            /*
             * some terminals wrap, some don't. Terminfo contains this
             *  distinction, but it makes almost no difference...
             */
            g_display.col = g_display.line = -1;
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
    static int avail = UNKNOWN;  /* can hardware do it? */

    /*
     * check that function is available
     */
    if (avail == UNKNOWN) {
        avail = strlen(insert_line) > 0;
    }
    if (!avail) {
        return FALSE;
    }

    /*
     * insert the line
     */
    att_stuff();
    xygoto(0, line);
    tputs(insert_line, 1, myputchar);

    /*
     * regardless of where the line was inserted, the bottom line
     *  (including the bottom right character) scrolled off the screen
     */
    g_mem_c = 0;

    return TRUE;
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
    static int avail = UNKNOWN;

    if (avail == UNKNOWN) {
        avail = strlen(cursor_left) > 0;
    }
    if (avail) {
        tputs(cursor_left, 1, myputchar);
    }
    return avail;
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
    static int avail = UNKNOWN;

    if (avail == UNKNOWN) {
        avail = strlen(insert_character) > 0;
    }
    if (avail) {
        tputs(insert_character, 1, myputchar);
    }
    return avail;
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
    static int avail = UNKNOWN;

    if (avail == UNKNOWN) {
        avail = strlen(delete_character) > 0;
    }
    if (avail) {
        att_stuff();
        tputs(delete_character, 1, myputchar);
        /*
         * bottom right corner character could need to be put on the bottom
         *  line, one character in from the right
         */
        if (g_mem_c && g_display.line == g_display.nlines-1) {
            if (g_display.col < g_display.ncols-2) {
                xygoto(g_display.ncols-2, g_display.nlines-1);
                if (g_display.attr != g_mem_attr) {
                    hw_attr(g_mem_attr);
                    g_display.attr = g_mem_attr;
                }
                myputchar(g_mem_c);

                /*
                 * some terminals wrap, some don't. Terminfo contains this
                 *  distinction, but it makes almost no difference...
                 */
                g_display.col = g_display.line = -1;
            }
            g_mem_c = 0;
        }
    }
    return avail;
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
    if (g_display.line == g_display.nlines-1 && g_display.col ==
            g_display.ncols-1) {
        g_mem_c = c;
        g_mem_attr = g_status.wanted;
        return;
    }
    att_check();
    myputchar(c);
}

/*
 * This struct and flag variable save the original terminal modes
 * for restoration on exit.
 */
static struct termio term_orig;
static int kbdflgs;
/*
 * Name:    hw_terminate
 * Purpose: To restore the terminal to a safe state prior to leaving the
 *           editor.
 * Date:    October 10, 1989
 */
void hw_terminate()
{
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
    xygoto(0, g_display.nlines-2);
    att_stuff();
    resetterm();

    /*
     * Reset the terminal mode to what it was on entry
     */
    if (ioctl(0, TCSETA, &term_orig) == -1) {
        error(FATAL, "could not reset termio");
    }
    fcntl(0, F_SETFL, kbdflgs);
    /*
     * leave the editor version number showing, to make it easier to
     *  keep track of which version is being used where.
     * Once "dte" becomes more stable, this may not be useful.
     */
    printf("\ndte version %s for UNIX (System V)\n", VERSION);
}

#ifndef HPUX
/*
 * Buffer declaration for work area for copy function. System V doesn't
 * have memmove, so we'll have to fake it.
 */
static char *g_buffer;
#endif
/*
 * Name:    hw_initialize
 * Purpose: To initialize the display ready for editor use.
 * Date:    October 10, 1989
 * Notes:   Typed characters (including ^S and ^Q and ^\) must all be
 *           returned without echoing!
 */
void hw_initialize()
{
    struct termio term;    /* to avoid ^S ^Q processing */
    int result;            /* result of setting up terminal commands */
    int flags;             /* for setting no delay on read */

    /*
     * allocate space for the screen image
     */
    if ((g_screen = (screen_lines *)malloc(MAX_LINES * sizeof(screen_lines)))
            == NULL) {
        printf("no memory for screen image\n");
        exit(1);
    }

    /*
     * set path for the help file
     */
    strcpy(g_status.help_file, HELPFILE);

    /*
     * locate all the terminfo strings
     */
    setupterm(NULL, 1, &result);
    if (result != 1) {
        error(FATAL, "no TERM set");
    }

    /*
     * check that at least cursor addressing is available
     */
    if (strlen(cursor_address) == 0) {
        error(FATAL, "terminal MUST have cursor addressing");
    }

    /*
     * do not attempt to use attributes on idiotic terminals!!
     */
    if (magic_cookie_glitch > 0 || ceol_standout_glitch) {
        g_display.block = NORMAL;
        g_display.flash = NORMAL;
        g_display.normal = NORMAL;
        g_display.attr = NORMAL;
    }
    else {
        g_display.block = REVERSE;
        g_display.flash = HIGH;
        g_display.normal = NORMAL;
        g_display.attr = NORMAL;
        hw_attr(NORMAL);
    }

    /*
     * work out the actual size of the screen
     */
    if (columns < MAX_COLS) {
        g_display.ncols = columns;
    }
    else {
        g_display.ncols = MAX_COLS;
    }
    if (lines < MAX_LINES) {
        g_display.nlines = lines;
    }
    else {
        g_display.nlines = MAX_LINES;
    }

    /*
     * work out the length of the cursor addressing command, so we can
     *  choose the quickest way of getting anywhere
     */
    g_display.ca_len = strlen(tparm(cursor_address, g_display.nlines,
            g_display.ncols));

    /*
     * get rid of XON/XOFF handling, echo, and other input processing
     */
    if (ioctl(0, TCGETA, &term) == -1) {
        error(FATAL, "could not get termio");
    }
    (void)ioctl(0, TCGETA, &term_orig);
    term.c_iflag = 0;
    term.c_oflag = 0;
    term.c_lflag = 0;
    term.c_cc[VMIN] = 1;
    term.c_cc[VTIME] = 0;
    if (ioctl(0, TCSETA, &term) == -1) {
        error(FATAL, "could not set termio");
    }
    kbdflgs = fcntl( 0, F_GETFL, 0 );

    /*
     * set up no delay when checking if anything is in the buffer
     */
    flags = fcntl(0, F_GETFL);
    flags |= O_NDELAY;
    fcntl(0, F_SETFL, flags);

    /*
     * allocate space for the main text buffer and the copying buffer
     */
    if ((g_status.start_mem = (char *)malloc(g_space)) == NULL) {
        error(FATAL, "out of memory for text");
    }
    g_status.max_mem = g_status.start_mem + g_space;
#ifndef HPUX
    if ((g_buffer = (char *)malloc(g_space)) == NULL) {
        error(FATAL, "out of memory for buffer");
    }
#endif
}

/*
 * if we succeeded in reading a character from the buffer, then we need
 *  to store it somewhere until it is needed.
 */
static int avail_ch = 0;

/*
 * Name:    hw_c_avail
 * Purpose: To test whether or not a character has been typed by the user.
 * Date:    October 10, 1989
 * Returns: TRUE if user typed something, FALSE otherwise
 */
int hw_c_avail()
{
    char c;     /* character read from buffer */
    int result; /* was there a character in the buffer */

    /*
     * something already there, so no need to check buffer
     */
    if (avail_ch) {
        return TRUE;
    }

    fflush(stdout);

    /*
     * try reading from the buffer
     */
    result = read(0, &c, 1);

    if (result == 1) {
        /*
         * got something!
         */
        avail_ch = c;
        return TRUE;
    }
    return FALSE;
}

/*
 * Name:    hw_c_input
 * Purpose: To input a character from the user (indirectly).
 * Date:    October 10, 1989
 * Returns: the character the user typed
 */
int hw_c_input()
{
    char c;     /* character typed */
    int flags;  /* for setting delay mode */

#ifdef ELM_BUG
    if (getppid() == 1) {
        terminate();
        exit(1);
    }
#endif
    if (hw_c_avail()) {
        /*
         * There was a character already there, so return it and record
         *  that it has been used.
         */
        c = avail_ch;
        avail_ch = 0;
        return c;
    }

    /*
     * this time, we want to wait until the user types something, not
     *  keep going immediately
     */
    flags = fcntl(0, F_GETFL);
    flags &= ~O_NDELAY;
    fcntl(0, F_SETFL, flags);

    /*
     * wait for something to be there
     */
    read(0, &c, 1);

    /*
     * set stdin back to no delay, ready for hw_c_avail.
     */
    flags = fcntl(0, F_GETFL);
    flags |= O_NDELAY;
    fcntl(0, F_SETFL, flags);

    return c;
}

/*
 * Name:    main
 * Purpose: To do any system dependent command line argument processing,
 *           and then call the main editor function.
 * Date:    October 10, 1989
 * Passed:  argc:   number of command line arguments
 *          argv:   text of command line arguments
 */
void main(argc, argv)
int argc;
char *argv[];
{
    /*
     * see if user specified buffer size
     */
    if (argc > 1 && mystrcmp("-s", argv[1]) == 0) {
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

    editor(argc, argv);
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
#ifdef HPUX
        /*
         * overlapping move available, so take advantage of it
         */
        memmove(dest, source, number);
#else
        /*
         * no overlapping move available, so copy to buffer and back
         */
        memcpy(g_buffer, source, number);
        memcpy(dest, g_buffer, number);
#endif
    }
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
    if (link(old, new) == 0) {
        if (unlink(old) == 0) {
            return OK;
        }
    }
    return ERROR;
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
    static int avail = UNKNOWN;  /* can terminal do it? */

    /*
     * check if function is available
     */
    if (avail == UNKNOWN) {
        avail = strlen(change_scroll_region) > 0 &&
                      strlen(scroll_forward) > 0;
    }
    if (!avail) {
        return FALSE;
    }

    /*
     * select window to be affected
     */
    att_stuff();
    tputs(tparm(change_scroll_region, top, bottom), 1, myputchar);
    g_display.col = -1;
    g_display.line = -1;

    /*
     * scroll the window up
     */
    xygoto(0, bottom);
    tputs(scroll_forward, 1, myputchar);

    /*
     * don't leave a peculiar region scrolling - it confuses all sorts of
     *  things!
     */
    tputs(tparm(change_scroll_region, 0, g_display.nlines-1), 1, myputchar);
    g_display.col = -1;
    g_display.line = -1;

    /*
     * if the bottom line was scrolled up, then restore the old bottom
     *  right character to the second bottom line
     */
    if (g_mem_c) {
        if (bottom == g_display.nlines-1) {
            xygoto(g_display.ncols-1, g_display.nlines-2);
            hw_attr(g_mem_attr);
            g_display.attr = g_mem_attr;
            myputchar(g_mem_c);
            g_display.col = -1;
            g_display.line = -1;
        }
        g_mem_c = 0;
    }

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
    static int avail = UNKNOWN;  /* can terminal do it? */

    /*
     * check if function is available
     */
    if (avail == UNKNOWN) {
        avail = strlen(change_scroll_region) > 0 &&
                      strlen(scroll_reverse) > 0;
    }
    if (!avail) {
        return FALSE;
    }

    /*
     * select region to be affected
     */
    att_stuff();
    tputs(tparm(change_scroll_region, top, bottom), 1, myputchar);
    g_display.col = -1;
    g_display.line = -1;

    /*
     * scroll down
     */
    xygoto(0, top);
    tputs(scroll_reverse, 1, myputchar);

    /*
     * don't leave a peculiar region scrolling - it confuses all sorts of
     *  things!
     */
    tputs(tparm(change_scroll_region, 0, g_display.nlines-1), 1, myputchar);
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
 * Name:    min
 * Purpose: To return the smaller of two integers.
 * Date:    October 10, 1989
 * Passed:  a, b: integers to compare
 * Returns: a or b, whichever is smaller
 * Notes:   This function is here because some (most?) C compilers either
 *           define a macro or have this as a library function.
 */
int min(a, b)
int a;
int b;
{
    return a < b ? a : b;
}

#include <sys/types.h>
#include <sys/stat.h>
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
    struct stat info;  /* i-node info, including access mode bits */

    if (stat(name, &info) != 0) {
        return ERROR;
    }
    return info.st_mode;
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
    return chmod(name, attrib);
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
    if ((hw_fattrib(name) & 0200) == 0) { /* file cannot be written */
        set_prompt("File is write protected! Overwrite anyway? (y/n): ", 1);
        if (display(get_yn, 1) != A_YES) {
            return ERROR;
        }
        if (chmod(name, 0600) == ERROR) {
            return ERROR;
        }
    }
    return unlink(name);
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
 *          The file is read in 1K chunks. It might be more efficient
 *           to read the entire file with a single system call, provided
 *           there is no limit on the number of bytes that can be read
 *           in a single call.
 *          This function is in the hardware dependent module because
 *           some computers require non-standard open parameters...
 */
int hw_load(name, start, limit, end)
char *name;
text_ptr start;
text_ptr limit;
text_ptr *end;
{
    int fd;         /* file being read */
    int length;     /* number of bytes actually read */

    /*
     * try reading the file
     */
    if ((fd = open(name, O_RDONLY)) == ERROR) {
        error(WARNING, "File '%s' not found", name);
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
 *          mode:  fopen flags to be used when opening file
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
    return write_file(name, "w", start, end);
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
    return write_file(name, "a", start, end);
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
 *          The system "lp" command is used to get banners etc.
 */
int hw_print(start, end)
text_ptr start;
text_ptr end;
{
    char command[80];       /* printer selection */
    char temp[40];          /* temporary file name */

    /*
     * make temporary file name
     */
    strcpy(temp, "/tmp/dteXXXXXX");
    mktemp(temp);

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
            sprintf(command, "lp -dlp208 -c -s -t%s %s",
                    g_status.current_window->file_info->file_name, temp);
            break;
        case 2:
            sprintf(command, "lp -dlp125 -c -s -t%s %s",
                    g_status.current_window->file_info->file_name, temp);
            break;
        case 3:
            sprintf(command, "lp -dlpc -c -s -t%s %s",
                    g_status.current_window->file_info->file_name, temp);
            break;
        default:
            continue;
        }
        break;
    }

    /*
     * print file
     */
    write_file(temp, "w", start, end);
    system(command);
    unlink(temp);
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
    char *id;           /* current user id */

    strcpy(new, old);
    if ((cp = strrchr(new, '/')) != NULL) {
        ++cp;
    }
    else {
        cp = new;
    }

    /*
     * On UNIX systems it is common for multiple users to access the same
     *  directory (for example /tmp). It is therefore desirable to make
     *  the save file name unique for each user...
     */
    if (strcmp(name, RECOVERY) == 0) {
        strcpy(cp, (id = cuserid(NULL)) ? id : "");
        cp += strlen(cp);
    }

    strcpy(cp, name);
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
    struct termio term;    /* to avoid ^S ^Q processing */
    int flags;             /* for setting no delay on read */
    static char ci[100] = "/bin/csh";
    char *getenv();
    if (*getenv("SHELL")) {
        strcpy(ci, getenv("SHELL"));
    }
    hw_terminate();
    if (fork() == 0) {
        execl(ci, ci, NULL);
    }
    else {
        wait(NULL);     /* wait for child to finish */
    }
    /*
     * get rid of XON/XOFF handling, echo, and other input processing
     */
    if (ioctl(0, TCGETA, &term) == -1) {
        error(FATAL, "could not get termio");
    }
    (void)ioctl(0, TCGETA, &term_orig);
    term.c_iflag = 0;
    term.c_oflag = 0;
    term.c_lflag = 0;
    term.c_cc[VMIN] = 1;
    term.c_cc[VTIME] = 0;
    if (ioctl(0, TCSETA, &term) == -1) {
        error(FATAL, "could not set termio");
    }
    kbdflgs = fcntl( 0, F_GETFL, 0 );
    /*
     * set up no delay when checking if anything is in the buffer
     */
    flags = fcntl(0, F_GETFL);
    flags |= O_NDELAY;
    fcntl(0, F_SETFL, flags);
    return TRUE;
}
