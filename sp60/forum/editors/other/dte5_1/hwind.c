/*
 * Written by Douglas Thomson (1989/1990)
 *
 * This source code is released into the public domain.
 */

/*
 * Name:    hardware independent screen IO module
 * Purpose: This file contains the code to interface the rest of the
 *           editor to the display and input hardware.
 * File:    hwind.c
 * Author:  Douglas Thomson
 * System:  this file is intended to be system-independent
 * Date:    October 2, 1989
 * Notes:   This is the only module that is allowed to call the hardware
 *           dependent display IO library.
 *          Typically, functions here check whether any action is
 *           necessary (for example, the cursor may already happen to be
 *           in the required position), call hardware dependent functions
 *           to achieve the required effect, and finally update status
 *           information about the current state of the terminal display.
 *          The idea behind this approach is to keep the hardware
 *           dependent code as small and simple as possible, thus making
 *           porting the code easier.
 */

#ifdef HPXL
#include "commonh"
#include "hwdeph"
#else
#include "common.h"
#include "hwdep.h"
#endif
#include <string.h>

/*
 * prototypes for all functions in this file
 */
void xygoto ARGS((int col, int line));
void set_attr ARGS((char attr));
int c_insert ARGS((void));
int c_delete ARGS((void));
int eol_clear ARGS((void));
int c_avail ARGS((void));
int c_input ARGS((void));
void c_uninput ARGS((char c));
void c_output ARGS((int c));
void s_output ARGS((char *s));
void force_blank ARGS((void));
void initialize ARGS((void));
void terminate ARGS((void));
void line_del ARGS((int line));
void line_ins ARGS((int ins_line));
void window_scroll_up ARGS((int top, int bottom));
void window_scroll_down ARGS((int top, int bottom));

/*
 * Name:    xygoto
 * Purpose: To move the cursor to the required column and line.
 * Date:    October 2, 1989
 * Passed:  col:    desired column (0 up to max)
 *          line:   desired line (0 up to max)
 * Notes:   This function makes some attempt to use shorter movement
 *           commands for simple movements (initially, only backspace
 *           to move left one space).
 */
void xygoto(col, line)
int col;
int line;
{
    int diff;  /* how far backwards the cursor must be moved */

    /*
     * If the cursor is on the right line, then a simpler movement
     *  may be possible.
     */
    if (g_display.line == line) {
        if ((diff = g_display.col - col) == 0) {
            /*
             * the cursor was in exactly the right spot, so no
             *  action required.
             */
            return;
        }
        else if (diff == 1) {
            /*
             * the cursor only needs to move one space left, so try
             *  simply backspacing (if the hardware supports it)
             */
            if (hw_backspace()) {
                g_display.col = col;
                return;
            }
        }
    }

    /*
     * use a full cursor addressing command. The hardware is required
     *  to provide such a command, so there is no need to check.
     */
    g_display.col = col;
    g_display.line = line;
    hw_xygoto();
}

/*
 * Name:    set_attr
 * Purpose: To record the attribute to be used for the next character
 *           output.
 * Date:    October 2, 1989
 * Passed:  attr:              desired new attribute
 * Returns: [g_status.wanted]: attribute to use next
 * Notes:   Since other hardware commands can need to fiddle with the
 *           attribute, it is better not to bother actually outputting
 *           the hardware attribute command. This is done immediately
 *           prior to sending the actual character.
 */
void set_attr(attr)
char attr;
{
    g_status.wanted = attr;
}

/*
 * Name:    c_insert
 * Purpose: To insert space for one character at the cursor position.
 * Date:    October 2, 1989
 * Notes:   If this function is available in the hardware, then it must
 *           leave the cursor in its original position (or else
 *           explicitly undefined [line = col = -1]) and insert one
 *           character in front of the character that used to be under
 *           the cursor.
 *          No assumption is made about what the attribute of the inserted
 *           character will be!
 */
int c_insert()
{
    int col;        /* used to copy characters along */
    int old_col;    /* to remember current column */
    int old_line;   /* to remember current line */

    /*
     * It is permissible for hardware functions to leave the current
     *  cursor position undefined (-1, -1). Hence we need to store the
     *  current location for use later.
     */
    old_col = g_display.col;
    old_line = g_display.line;

    if (hw_c_insert()) {
        /*
         * update memory version of screen
         */
        for (col=g_display.ncols-1; col > old_col; col--) {
            g_screen[old_line][col] =
                    g_screen[old_line][col-1];
        }
        g_screen[old_line][old_col].c = ' ';
        g_screen[old_line][old_col].attr = 0xFF;
        return TRUE;
    }
    return FALSE;
}

/*
 * Name:    c_delete
 * Purpose: To delete the character under the cursor.
 * Date:    October 10, 1989
 * Notes:   If this function is available in the hardware, then it must
 *           leave the cursor in its original position (or else
 *           explicitly undefined [line = col = -1]) and delete the
 *           character under the cursor.
 *          The character which appears at the end of the line after the
 *           delete is assumed to be a space with the normal attribute.
 */
int c_delete()
{
    int col;        /* used to copy characters along */
    int old_col;    /* to remember current column */
    int old_line;   /* to remember current line */

    /*
     * It is permissible for hardware functions to leave the current
     *  cursor position undefined (-1, -1). Hence we need to store the
     *  current location for use later.
     */
    old_col = g_display.col;
    old_line = g_display.line;

    if (hw_c_delete()) {
        /*
         * update memory version of screen
         */
        for (col=old_col; col < g_display.ncols-1; col++) {
            g_screen[old_line][col] =
                    g_screen[old_line][col+1];
        }
        g_screen[old_line][g_display.ncols-1].c = ' ';
        g_screen[old_line][g_display.ncols-1].attr = g_display.normal;
        return TRUE;
    }
    return FALSE;
}

/*
 * Name:    eol_clear
 * Purpose: To clear the current line from the cursor to the end of the
 *           line to normal spaces.
 * Date:    October 2, 1989
 * Notes:   If this function is available in the hardware, then it must
 *           clear all the rest of the line to spaces, all with the normal
 *           attribute, and leave the cursor exactly where it was (or else
 *           explicitly undefined [line = col = -1]).
 */
int eol_clear()
{
    int col;
    int old_col;    /* to remember current column */
    int old_line;   /* to remember current line */

    old_col = g_display.col;
    old_line = g_display.line;

    if (!hw_clreol()) {
        return FALSE;
    }
    for (col=old_col; col < g_display.ncols; col++) {
        g_screen[old_line][col].c = ' ';
        g_screen[old_line][col].attr = g_display.normal;
    }
    return TRUE;
}

/*
 * Name:    c_avail
 * Purpose: To test whether or not there is a character available to be
 *           read from the user.
 * Date:    October 2, 1989
 * Notes:   Under some circumstances it is convenient to be able to push
 *           a few characters back into the input stream, making it appear
 *           to the rest of the editor that the user typed something
 *           different (for example, the tab key might be turning into
 *           the required number of spaces).
 */
int c_avail()
{
    if (g_status.ungotcount) {
        return TRUE;
    }
    return hw_c_avail();
}

/*
 * Name:    c_input
 * Purpose: To input the next character typed by the user.
 * Date:    October 2, 1989
 * Notes:   Under some circumstances it is convenient to be able to push
 *           a few characters back into the input stream, making it appear
 *           to the rest of the editor that the user typed something
 *           different (for example, the tab key might be turning into
 *           the required number of spaces).
 */
int c_input()
{
    if (g_status.ungotcount) {
        return g_status.ungotbuff[--g_status.ungotcount];
    }
    return hw_c_input();
}

/*
 * Name:    c_uninput
 * Purpose: To push a character back into the input stream, so that it
 *           will be inputted next time c_input is called.
 * Date:    October 2, 1989
 * Notes:   No check is made to see if the buffer has overflowed, so
 *           beware when using this one!
 */
void c_uninput(c)
char c;
{
    g_status.ungotbuff[g_status.ungotcount++] = c;
}

/*
 * Name:    c_output
 * Purpose: To output a single character at the cursor position, and then
 *           advance the cursor.
 * Date:    October 2, 1989
 * Passed:  c: character to be output
 * Notes:   The character is only outputted if it would be on the screen.
 *          The cursor position should not be relied upon after writing
 *           the rightmost column.
 *          It is left up to the hardware to deal with the bottom right
 *           corner of the screen! This is against the philosophy of
 *           keeping the hardware dependent part simple, but we want to
 *           be able to take advantage of any hardware that can do a
 *           decent job of this character.
 */
void c_output(c)
int c;
{
    if (g_display.col < g_display.ncols) {
        g_screen[g_display.line][g_display.col].c = c;
        g_screen[g_display.line][g_display.col].attr =
                g_status.wanted;
        hw_c_output(c);

        /*
         * check that cursor position is still known...
         */
        if (g_display.col != -1) {
            ++g_display.col;
        }
    }
}

/*
 * Name:    s_output
 * Purpose: To output character string at the cursor position, advancing
 *           the cursor by the length of the string.
 * Date:    October 2, 1989
 * Passed:  s: string to output
 * Notes:   At present, this function is rarely used, so the simple
 *           approach of calling the character output routine is quite
 *           acceptable. Maybe someday the entire string could be output
 *           with a single system call?
 */
void s_output(s)
char *s;
{
    while (*s) {
        c_output(*s++);
    }
}

/*
 * Name:    force_blank
 * Purpose: To set the status of the screen so that nothing can appear to
 *           be what it needs to be, so that the entire screen will be
 *           redrawn.
 * Date:    October 2, 1989
 * Notes:   This could be done more efficiently with a clear screen
 *           terminal command in the hardware dependent module, but it
 *           does not seem worthwhile to add the extra function when
 *           this is the only time clear screen would be used.
 */
void force_blank()
{
    int line;
    int col;

    for (line=0; line < g_display.nlines; line++) {
        for (col=0; col < g_display.ncols; col++) {
            g_screen[line][col].c = 0xFF;
            g_screen[line][col].attr = 0x00;
        }
    }
}

/*
 * Name:    initialize
 * Purpose: To initialize all the screen status info that is not hardware
 *           dependent, and call the hardware initialization routine to
 *           pick up the hardware dependent stuff.
 * Date:    October 2, 1989
 * Returns: [g_status and g_display]: all set up ready to go
 * Notes:   It is assumed that g_status and g_display are all \0's to begin
 *           with (the default if they use static storage). If this may
 *           not be the case, then clear them explicitly here.
 */
void initialize()
{
    /*
     * we do not know where the cursor is yet
     */
    g_display.col = -1;
    g_display.line = -1;

    /*
     * do the hardware initialization first, since this allocates the main
     *  text buffer and sets up other info needed here later.
     */
    hw_initialize();

    /*
     * the main text buffer must be preceded by a \0, so that backward
     *  searches can see the start of the string
     */
    *g_status.start_mem++ = '\0';

    /*
     * most of the system's text pointers are safer set to the start
     *  of the text buffer - some of these may not be strictly
     *  necessary.
     */
    g_status.temp_end = g_status.start_mem;
    g_status.end_mem = g_status.start_mem;

    /*
     * set the default modes - may want to read this from a file later
     */
    g_status.insert = TRUE;
    g_status.indent = TRUE;
    g_status.unindent = TRUE;

    /*
     * set default interval between tabs
     */
    g_status.tab_size = 4;

    /*
     * set the number of lines from one page that should still be visible
     *  on the next page after page up or page down.
     */
    g_status.overlap = 1;

    /*
     * set the time in seconds between auto-saves
     */
    g_status.save_interval = 300;

    /*
     * initially, text should use the normal attribute
     */
    g_status.wanted = g_display.normal;

    /*
     * record that we have no idea what is currently on the screen.
     */
    force_blank();
}

/*
 * Name:    terminate
 * Purpose: To do any hardware independent housekeeping, and call the
 *           hardware dependent code to clean up screen modes and leave
 *           the cursor at the bottom of the screen in normal attribute.
 * Date:    October 2, 1989
 * Notes:   At present, there is nothing apart from hardware dependent
 *           code required.
 */
void terminate()
{
    hw_terminate();
}

/*
 * Name:    line_del
 * Purpose: To delete a given line on the screen.
 * Date:    October 2, 1989
 * Passed:  line:   line to be deleted
 * Notes:   If the hardware does not support this one, then the editor
 *           will be rather slow!
 */
void line_del(line)
int line;
{
    screen_chars *p, *q;    /* used to shuffle screen copy */
    int col;                /* counter for chars in each line */
    screen_chars blank;     /* the blank/normal character */

    if (!hw_linedel(line)) {
        return;
    }

    /*
     * copy text to close the gap
     */
    while (line < g_display.nlines-1) {
        p = g_screen[line];
        q = g_screen[line+1];
        for (col=g_display.ncols; col > 0; col--) {
            *p++ = *q++;  /* all C compilers support structure assignments? */
        }
        ++line;
    }

    /*
     * now mark the bottom line as all blank
     */
    blank.c = ' ';
    blank.attr = g_display.normal;
    for (col=g_display.ncols-1; col >= 0; col--) {
        g_screen[g_display.nlines-1][col] = blank;
    }
}

/*
 * Name:    line_ins
 * Purpose: To insert a given line on the screen. The cursor line will
 *           move down, leaving the cursor on a new blank/normal line.
 * Date:    October 2, 1989
 * Passed:  ins_line: line to be inserted
 * Notes:   If the hardware does not support this one, then the editor
 *           will be rather slow!
 */
void line_ins(ins_line)
int ins_line;
{
    int line;              /* line being moved */
    int col;               /* column being moved */
    screen_chars *p, *q;   /* dest and source of move */
    screen_chars blank;    /* blank/normal character */

    if (!hw_lineins(ins_line)) {
        return;
    }

    /*
     * shuffle status screen to make a gap
     */
    for (line=g_display.nlines-1; line > ins_line; line--) {
        p = g_screen[line];
        q = g_screen[line-1];
        for (col=g_display.ncols; col > 0; col--) {
            *p++ = *q++;
        }
    }

    /*
     * set the new inserted line to blank/normal
     */
    blank.c = ' ';
    blank.attr = g_display.normal;
    for (col=g_display.ncols-1; col >= 0; col--) {
        g_screen[ins_line][col] = blank;
    }
}

/*
 * Name:    window_scroll_up
 * Purpose: To scroll all the lines between top and bottom up one line.
 * Date:    October 10, 1989
 * Passed:  top:    top line to be scrolled
 *          bottom: bottom line to be scrolled
 * Notes:   If the hardware supports windows, then this is likely to look
 *           better than inserting and deleting lines.
 */
void window_scroll_up(top, bottom)
int top;
int bottom;
{
    int line;              /* line being moved */
    int col;               /* column being moved */
    screen_chars *p, *q;   /* dest and source of move */
    screen_chars blank;    /* blank/normal character */

    if (hw_scroll_up(top, bottom)) {
        /*
         * copy text to close the gap
         */
        line = top;
        while (line < bottom) {
            p = g_screen[line];
            q = g_screen[line+1];
            for (col=g_display.ncols; col > 0; col--) {
                *p++ = *q++;
            }
            ++line;
        }

        /*
         * now mark the bottom line as all blank
         */
        blank.c = ' ';
        blank.attr = g_display.normal;
        for (col=g_display.ncols-1; col >= 0; col--) {
            g_screen[bottom][col] = blank;
        }
    }
    else {
        /*
         * no hardware windows, so do it with insert and delete line
         */
        line_del(top);
        if (bottom < g_display.nlines-1) {
            line_ins(bottom);
        }
    }
}

/*
 * Name:    window_scroll_down
 * Purpose: To scroll all the lines between top and bottom down one line.
 * Date:    October 10, 1989
 * Passed:  top:    top line to be scrolled
 *          bottom: bottom line to be scrolled
 * Notes:   If the hardware supports windows, then this is likely to look
 *           better than inserting and deleting lines.
 */
void window_scroll_down(top, bottom)
int top;
int bottom;
{
    int line;              /* line being moved */
    int col;               /* column being moved */
    screen_chars *p, *q;   /* dest and source of move */
    screen_chars blank;    /* blank/normal character */

    if (hw_scroll_down(top, bottom)) {
        /*
         * shuffle status screen to make a gap
         */
        for (line=bottom; line > top; line--) {
            p = g_screen[line];
            q = g_screen[line-1];
            for (col=g_display.ncols; col > 0; col--) {
                *p++ = *q++;
            }
        }

        /*
         * set the new inserted line to blank/normal
         */
        blank.c = ' ';
        blank.attr = g_display.normal;
        for (col=g_display.ncols-1; col >= 0; col--) {
            g_screen[top][col] = blank;
        }
    }
    else {
        /*
         * no hardware windows, so do it with insert and delete line
         */
        if (bottom < g_display.nlines-1) {
            line_del(bottom);
        }
        line_ins(top);
    }
}

/*
 * Name:    os_shell
 * Purpose: To shell out of the editor into the operating system, in such a
 *           way that editing may be resumed later.
 * Date:    November 28, 1990
 */
void os_shell()
{
    xygoto(0, g_display.nlines-1);
    if (hw_os_shell()) {
        force_blank();   /* get the screen fixed if necessary */
    }
}
