/*
 * Written by Douglas Thomson (1989/1990)
 *
 * This source code is released into the public domain.
 */

/*
 * Name:    dte - Doug's Text Editor program - main editor module
 * Purpose: This file contains the main editor module, and a number of the
 *           smaller miscellaneous editing commands.
 *          It also contains the code for dispatching commands.
 * File:    ed.c
 * Author:  Douglas Thomson
 * System:  this file is intended to be system-independent
 * Date:    October 1, 1989
 * I/O:     file being edited
 *          files read or written
 *          user commands and prompts
 * Notes:   see the file "dte.doc" for general program documentation
 */

#ifdef HPXL
#include "commonh"      /* common types for all dte modules */
#include "globalh"      /* global variables */
#include "findreph"     /* find and replace command prototypes */
#include "blockh"       /* block marking, moving etc prototypes */
#include "windowh"      /* opening and sizing windows, help */
#include "utilsh"       /* miscellaneous commonly used routines */
#else
#include "common.h"     /* common types for all dte modules */
#include "global.h"     /* global variables */
#include "findrep.h"    /* find and replace command prototypes */
#include "block.h"      /* block marking, moving etc prototypes */
#include "window.h"     /* opening and sizing windows, help */
#include "utils.h"      /* miscellaneous commonly used routines */
#endif
#include <time.h>       /* for auto-saving */

/*
 * prototypes for all functions in this file
 */
void quit ARGS((windows *window));
void tab_key ARGS((windows *window));
void insert ARGS((windows *window, int c, int new_line));
void move_up ARGS((windows *window));
void move_down ARGS((windows *window));
void move_left ARGS((windows *window));
void move_right ARGS((windows *window));
void word_left ARGS((windows *window));
void word_right ARGS((windows *window));
void word_delete ARGS((windows *window));
void char_del_left ARGS((windows *window));
void line_kill ARGS((windows *window));
void char_del_under ARGS((windows *window));
void eol_kill ARGS((windows *window));
void reminder ARGS((char *mess));
void goto_left ARGS((windows *window));
void goto_right ARGS((windows *window));
void goto_top ARGS((windows *window));
void goto_bottom ARGS((windows *window));
void set_tabstop ARGS((void));
int command ARGS((windows *window));
void editor ARGS((int argc, char *argv[]));

/*
 * Name:    quit
 * Purpose: To close the current window without saving the current file.
 * Date:    October 1, 1989
 * Passed:  window: information allowing access to the current window
 * Notes:   If the file has been modified but not saved, then the user is
 *           given a second chance before the changes are discarded.
 *          Note that this is only necessary if this is the last window
 *           that refers to the file. If another window still refers to
 *           the file, then the check can be left until later.
 */
void quit(window)
windows *window;
{
    if (window->file_info->modified && window->file_info->ref_count == 1) {
        set_prompt("Abandon changes? (y/n): ", 1);
        if (display(get_yn, 1) != A_YES) {
            return;
        }
    }

    /*
     * If the user decided to abandon changes, then the recovery file (if
     *  one exists) is now obsolete.
     */
    if (g_status.recovery[0]) {
        hw_unlink(g_status.recovery);
        g_status.recovery[0] = '\0';
    }

    /*
     * remove window, allocate screen lines to other windows etc
     */
    finish(window);
}

/*
 * Name:    tab_key
 * Purpose: To make the necessary changes after the user types the tab key.
 * Date:    October 1, 1989
 * Passed:  window: information allowing access to the current window
 * Notes:   If in insert mode, then this function simply puts the required
 *           number of spaces back into the input stream, so as far as the
 *           editor is concerned the tab is ignored, and the user then typed
 *           the spaces instead.
 *          If not in insert mode, then tab simply moves the cursor right
 *           the required distance.
 */
void tab_key(window)
windows *window;
{
    int spaces;  /* the spaces to move to the next tab stop */

    /*
     * work out the number of spaces to the next tab stop
     */
    spaces = g_status.tab_size - (window->ccol % g_status.tab_size);

    if (g_status.insert) {
        /*
         * pretend the user actually typed the spaces. All the work will
         *  be done by the insert function.
         */
        while (spaces--) {
            c_uninput(' ');
        }
    }
    else {
        /*
         * advance the cursor without changing the text underneath
         */
        window->ccol += spaces;

        /*
         * make sure the cursor stays on the screen
         */
        if (window->ccol >= g_display.ncols) {
            window->ccol = g_display.ncols-1;
        }
    }
}

/*
 * Name:    insert
 * Purpose: To make the necessary changes after the user has typed a normal
 *           printable character (or a carriage return)
 * Date:    October 1, 1989
 * Passed:  window:   information allowing access to the current window
 *          c:        the character just typed
 *          new_line: TRUE if carriage return, FALSE if insert line
 */
void insert(window, c, new_line)
windows *window;
int c;
int new_line;
{
    text_ptr source;    /* source for block move to make room for c */
    text_ptr dest;      /* destination for block move */
    long number;        /* number of characters to be moved */
    int len;            /* length of current line */
    int pad;            /* padding to add if cursor beyond end of line */
    int add;            /* characters to be added (usually 1 in insert mode) */
    int cr;             /* does current line end in \n? */
    int i;              /* counter for adding autoindenting */
    text_ptr prev;      /* previous lines scanned for autoindent */

    /*
     * first check we have room on the screen - although the editor can
     *  cope with lines wider than the screen, we do not want to
     *  encourage them!
     */
    if (window->ccol >= g_display.ncols-1 && c != '\n') {
        error(WARNING, "cannot insert more characters");
        return;
    }

    /*
     * if necessary, copy the current line into the line buffer. Making
     *  small changes to the entire file is too slow, so only the current
     *  line is affected until the cursor moves to another line.
     */
    copy_line(window);

    /*
     * work out how many characters need to be inserted
     */
    len = linelen(g_status.line_buff);
    if (g_status.line_buff[len] == '\n') {
        cr = 1;
    }
    else {
        cr = 0;
    }
    if (window->ccol > len) {  /* padding required */
        pad = window->ccol - len;
    }
    else {
        pad = 0;
    }
    if (c == '\n') {
        add = 0;
        /*
         * indentation is only required if we are in the right mode,
         *  the user typed <CR>, and if there is not space followed
         *  by something after the cursor.
         */
        if (g_status.indent && new_line && (window->ccol >= len ||
                g_status.line_buff[window->ccol] != ' ')) {
            /*
             * autoindentation is required. Match the indentation of
             *  the first line above that is not blank.
             */
            add = first_non_blank(g_status.line_buff);
            if (g_status.line_buff[add] == '\n' ||
                    g_status.line_buff[add] == '\0') {
                prev = window->cursor;
                while ((prev = find_prev(prev)) != NULL) {
                    add = first_non_blank((char *)prev);
                    if (prev[add] != '\n') {
                        break;
                    }
                }
            }
        }
        ++add; /* carriage return is always inserted, even in overwrite */
    }
    else if (g_status.insert || window->ccol >= len) {
        /*
         * inserted characters, or overwritten characters at the end of
         *  the line, are inserted.
         */
        add = 1;
    }
    else {
        /*
         * If the character is not a carriage return, and the cursor is
         *  in the middle of the line, and we are not in insert mode,
         *  then the current character is overwritten by the new one,
         *  and no extra space is required.
         */
        add = 0;
    }

    /*
     * check that current line would not get too long. Note that there must
     *  be space for both the old line and any indentation, so the maximum
     *  allowed line length (BUFF_SIZE) should be at least twice the
     *  actual screen line length.
     */
    if (len + pad + add + cr >= BUFF_SIZE) {
        error(WARNING, "no more room to add");
        return;
    }

    /*
     * all clear to add new character!
     */

    /*
     * move character to make room for whatever needs to be inserted
     */
    source = g_status.line_buff + window->ccol - pad;
    dest = source + pad + add;
    number = len + pad - window->ccol + 1 + cr;
    hw_move(dest, source, number);

    /*
     * fix marks (such as block begin/end) so that they remain in the
     *  correct place after the move
     */
    fix_marks(window, source, (long) (pad + add));

    /*
     * if padding was required, then put in the required spaces
     */
    while (pad--) {
        *source++ = ' ';
    }

    /*
     * now place the new character (which was included in the "add" count)
     */
    *source++ = c;
    --add;

    /*
     * now put in the autoindent characters
     */
    for (i=0; i < add; i++) {
        *source++ = ' ';
    }

    if (c == '\n') {
        /*
         * the line has been split. This is a special case, since the
         *  current line now has (or may have) a carriage return in the
         *  middle of it, which is not normally allowed. Hence we must
         *  restore the situation to a safe state.
         */
        un_copy_line(window);

        /*
         * make sure the line below the cursor is visible
         */
        if (window->cline == window->bottom_line) {
            if (window->cline > window->top_line) {
                scroll_down(window);
            }
        }

        /*
         * give the display routine a hint about a way of updating the
         *  screen that is likely to be efficient.
         */
        if (window->cline < window->bottom_line) {
            window_scroll_down(window->cline+1, window->bottom_line);
        }

        /*
         * If the cursor is to move down to the next line, then update
         *  the line and column appropriately.
         */
        if (new_line) {
            window->ccol = add;
            window->cursor = find_next(window->cursor);
            if (window->cline < window->bottom_line) {
                window->cline++;
            }
        }
    }
    else {
        /*
         * This is a normal character in a normal part of the screen.
         *  Simply advance the cursor and output the character.
         */
        xygoto(window->ccol, window->cline);
        if (g_status.insert && window->ccol < len) {
            c_insert();
        }
        c_output(c);
        window->ccol++;
    }

    /*
     * record that file has been modified (this is only necessary here
     *  if in overwrite mode [where pad and add can both be 0])
     */
    window->file_info->modified = TRUE;
    if (!g_status.unsaved) {
        g_status.save_time = time(NULL);
        g_status.unsaved = TRUE;
    }
}

/*
 * Name:    move_up
 * Purpose: To move the cursor one line up the screen.
 * Date:    October 1, 1989
 * Passed:  window:   information allowing access to the current window
 * Notes:   If the cursor is at the top of the window, then the file must
 *           be scrolled down.
 *          If the cursor is already on the first line of the file, then
 *           this command can be ignored.
 */
void move_up(window)
windows *window;
{
    text_ptr p;   /* the previous line on the screen */

    un_copy_line(window);

    /*
     * if no previous line, give up
     */
    if ((p = find_prev(window->cursor)) == NULL) {
        return;
    }

    if (window->cline == window->top_line) {
        window_scroll_down(window->top_line, window->bottom_line);
    }
    else {
        --window->cline;        /* simply move cursor */
    }

    window->cursor = p;
}

/*
 * Name:    move_down
 * Purpose: To move the cursor one line down the screen.
 * Date:    October 1, 1989
 * Passed:  window:   information allowing access to the current window
 * Notes:   If the cursor is at the bottom of the window, then the file must
 *           be scrolled up.
 *          If the cursor is already on the last line of the file, then
 *           this command can be ignored.
 */
void move_down(window)
windows *window;
{
    text_ptr p;

    un_copy_line(window);
    if ((p = find_next(window->cursor)) == NULL) {
        return;
    }
    if (window->cline == window->bottom_line) {
        window_scroll_up(window->top_line, window->bottom_line);
    }
    else {
        ++window->cline;
    }
    window->cursor = p;
}

/*
 * Name:    move_left
 * Purpose: To move the cursor one character to the left
 * Date:    October 1, 1989
 * Passed:  window:   information allowing access to the current window
 * Notes:   If the cursor is already at the left of the screen, then
 *           this command is ignored.
 */
void move_left(window)
windows *window;
{
    if (window->ccol > 0) {
        --window->ccol;
    }
}

/*
 * Name:    move_right
 * Purpose: To move the cursor one character to the right
 * Date:    October 1, 1989
 * Passed:  window:   information allowing access to the current window
 * Notes:   If the cursor is already at the right of the screen, then
 *           this command is ignored.
 *          It is quite OK to move the cursor beyond the rightmost
 *           character in the line itself.
 */
void move_right(window)
windows *window;
{
    if (window->ccol < g_display.ncols-1) {
        ++window->ccol;
    }
}

/*
 * Name:    word_left
 * Purpose: To move the cursor one word to the left.
 * Date:    October 1, 1989
 * Passed:  window:   information allowing access to the current window
 * Notes:   If the cursor is at the left of the line, then move the
 *           end of the previous line.
 *          If the cursor is beyond the end of the line, then move back
 *           to the end of the line.
 *          Words are considered strings of letters, numbers and underscores,
 *           which must be separated by other characters.
 */
void word_left(window)
windows *window;
{
    text_ptr p;   /* previous line in file */
    int len;      /* length of current line */

    /*
     * get current line in buffer so we can play with it
     */
    copy_line(window);

    if (window->ccol > (len = linelen(g_status.line_buff))) {
        /*
         * cursor beyond end of line
         */
        window->ccol = len;
    }
    else if (window->ccol == 0) {
        /*
         * cursor at start of line
         */
        un_copy_line(window);
        if ((p = find_prev(window->cursor)) != NULL) {
            if (window->cline == window->top_line) {
                scroll_up(window);
            }
            window->cursor = p;
            --window->cline;
            window->ccol = linelen(window->cursor);
        }
    }
    else {
        /*
         * normal search for word. Do not consider character under
         *  cursor, so that two word left commands in a row will keep
         *  moving the cursor.
         */
        --window->ccol;

        /*
         * scan for something that IS part of a word
         */
        for (;;) {
            if (myisalnum(g_status.line_buff[window->ccol])) {
                break;
            }
            if (window->ccol == 0) {
                break;
            }
            --window->ccol;
        }

        /*
         * now scan for something that is NOT part of a word
         */
        if (window->ccol > 0) {
            for (;;) {
                if (!myisalnum(g_status.line_buff[window->ccol])) {
                    /*
                     * we have found something that is NOT part of a word,
                     *  so the thing after it must be the start of a word.
                     */
                    ++window->ccol;
                    break;
                }
                if (window->ccol == 0) {
                    break;
                }
                --window->ccol;
            }
        }
    }
}

/*
 * Name:    word_right
 * Purpose: To move the cursor one word to the right.
 * Date:    October 1, 1989
 * Passed:  window:   information allowing access to the current window
 * Notes:   If the cursor is at the right of the line, then move the
 *           start of the next line.
 *          Words are considered strings of letters, numbers and underscores,
 *           which must be separated by other characters.
 */
void word_right(window)
windows *window;
{
    int len;     /* length of this line */
    text_ptr p;  /* next line */

    copy_line(window);

    if (window->ccol >= (len = linelen(g_status.line_buff))) {
        /*
         * at or beyond end of line, so move to start of next line
         */
        un_copy_line(window);
        if ((p = find_next(window->cursor)) != NULL) {
            if (window->cline == window->bottom_line) {
                scroll_down(window);
            }
            window->cursor = p;
            ++window->cline;
            window->ccol = 0;
        }
    }
    else {
        /*
         * normal word right - see comments in word_left
         */
        for (;;) {
            if (!myisalnum(g_status.line_buff[window->ccol])) {
                break;
            }
            if (window->ccol == len) {
                break;
            }
            ++window->ccol;
        }
        if (window->ccol < len) {
            for (;;) {
                if (myisalnum(g_status.line_buff[window->ccol])) {
                    break;
                }
                if (window->ccol == len) {
                    break;
                }
                ++window->ccol;
            }
        }
    }
}

/*
 * Name:    word_delete
 * Purpose: To delete from the cursor to the start of the next word.
 * Date:    October 1, 1989
 * Passed:  window:   information allowing access to the current window
 * Notes:   If the cursor is at the right of the line, then combine the
 *           current line with the next one, leaving the cursor where it
 *           is.
 *          If the cursor is on an alphanumeric character, then all
 *           subsequent alphanumeric characters are deleted.
 *          If the cursor is on a space, then all subsequent spaces
 *           are deleted.
 *          If the cursor is on a punctuation character, then all
 *           subsequent punctuation characters are deleted.
 */
void word_delete(window)
windows *window;
{
    int len;            /* length of current line */
    int start;          /* column that next word starts in */
    text_ptr source;    /* source for block move to delete word */
    text_ptr dest;      /* destination for block move */
    long number;        /* number of characters to move */
    int del_len;        /* number of characters to delete */
    text_ptr p;         /* next line in file */
    int pad;            /* padding spaces required */
    int cr;             /* does current line end with carriage return? */
    int alpha;          /* is the cursor char alphanumeric? */

    copy_line(window);
    if (window->ccol >= (len = linelen(g_status.line_buff))) {
        /*
         * we need to combine with the next line, if any
         */
        if ((p = find_next(window->cursor)) != NULL) {
            /*
             * add padding if required
             */
            if (g_status.line_buff[len] == '\n') {
                cr = 1;
            }
            else {
                cr = 0;
            }
            if (window->ccol > len) {
                pad = window->ccol - len;
            }
            else {
                pad = 0;
            }

            /*
             * check room to combine lines
             */
            if (len + pad + cr + linelen(p) >= BUFF_SIZE) {
                error(WARNING, "cannot combine lines");
                return;
            }

            /*
             * do the move, fixing any marks
             */
            source = g_status.line_buff + window->ccol - pad;
            dest = source + pad;
            number = len + pad - window->ccol + 1 + cr;
            hw_move(dest, source, number);
            fix_marks(window, source, (long) pad);

            /*
             * insert the padding
             */
            while (pad--) {
                *source++ = ' ';
            }

            /*
             * remove the \n separating the two lines
             */
            if (*source == '\n') {
                *source = '\0';
            }

            /*
             * let un_copy_line finish off the merge and adjust
             *  marks etc.
             */
            un_copy_line(window);

            /*
             * give display a hint about how to update the screen
             */
            if (window->cline < window->bottom_line) {
                window_scroll_up(window->cline+1, window->bottom_line);
            }
        }
    }
    else {
        /*
         * normal word delete
         *
         * find the start of the next word
         */
        start = window->ccol;
        if (g_status.line_buff[start] == ' ') {
            /*
             * the cursor was on a space, so eat all consecutive spaces
             *  from the cursor onwards.
             */
            for (;;) {
                if (g_status.line_buff[start] != ' ') {
                    break;
                }
                ++start;
            }
        }
        else {
            /*
             * eat all consecutive characters in the same class (spaces
             *  are considered to be in the same class as the cursor
             *  character)
             */
            alpha = myisalnum(g_status.line_buff[start++]);
            for (;;) {
                if (start == len) {
                    break;
                }
                if (g_status.line_buff[start] == ' ') {
                    /*
                     * the next character that is not a space will
                     *  end the delete
                     */
                    alpha = -1;
                }
                else if (alpha != myisalnum(g_status.line_buff[start])) {
                    if (g_status.line_buff[start] != ' ') {
                        break;
                    }
                }
                ++start;
            }
        }

        /*
         * move text to delete word, and fix marks
         */
        source = g_status.line_buff + start;
        dest = g_status.line_buff + window->ccol;
        number = strlen(g_status.line_buff) - start + 1;
        hw_move(dest, source, number);
        del_len = start - window->ccol;
        fix_marks(window, dest, -(long)del_len);
    }
}

/*
 * Name:    char_del_left
 * Purpose: To delete the character to the left of the cursor.
 * Date:    October 1, 1989
 * Passed:  window:   information allowing access to the current window
 * Notes:   If the cursor is at the left of the line, then combine the
 *           current line with the previous one.
 *          If in unindent mode, and the cursor is on the first non-blank
 *           character of the line, then match the indentation of an
 *           earlier line.
 */
void char_del_left(window)
windows *window;
{
    int len;            /* length of the current line */
    text_ptr source;    /* source of block move to delete character */
    text_ptr dest;      /* destination of block move */
    long number;        /* number of characters to move */
    text_ptr p;         /* previous line in file */
    int cr;             /* did line end with carriage return? */
    int plen;           /* length of previous line */
    int del_count;      /* number of characters to delete */
    int pos;            /* the position of the first non-blank char */

    copy_line(window);
    len = linelen(g_status.line_buff);
    if (window->ccol == 0) {
        /*
         * combine this line with the previous, if any
         */
        if ((p = find_prev(window->cursor)) != NULL) {
            if (g_status.line_buff[len] == '\n') {
                cr = 1;
            }
            else {
                cr = 0;
            }
            if (len + cr + (plen = linelen(p)) >= BUFF_SIZE) {
                error(WARNING, "cannot combine lines");
                return;
            }
            un_copy_line(window);

            /*
             * do the move and fix marks
             */
            source = window->cursor;
            dest = source-1;
            number = g_status.end_mem - source;
            hw_move(dest, source, number);
            fix_marks(window, dest, -1L);

            /*
             * adjust the cursor line, since it is now in the middle of a
             *  newly formed line
             */
            window->cursor = dest - prelinelen(dest);

            /*
             * make sure cursor stays on the screen, at the end of the
             *  previous line
             */
            if (window->cline == window->top_line) {
                scroll_up(window);
            }
            window_scroll_up(window->cline, window->bottom_line);
            --window->cline;
            if ((window->ccol = plen) >= g_display.ncols) {
                window->ccol = g_display.ncols-1;
            }
        }
    }
    else {
        /*
         * normal delete
         *
         * find out how much to delete (depends on unindent mode)
         */
        del_count = 1;   /* the default */
        if (g_status.unindent) {
            /*
             * Unindent only happens if the cursor is on the first
             *  non-blank character of the line, or if the cursor is
             *  beyond the end of the line.
             */
            if ((pos = first_non_blank(g_status.line_buff)) == window->ccol
                    || g_status.line_buff[pos] == '\n'
                    || g_status.line_buff[pos] == '\0') {
                /*
                 * now work out how much to unindent
                 */
                p = window->cursor;
                for (;;) {
                    if ((p = find_prev(p)) == NULL) {
                        /*
                         * no more lines to try, so give up and just
                         *  delete one character
                         */
                        break;
                    }
                    if ((plen = first_non_blank((char *)p)) < window->ccol &&
                            *(p+plen) != '\n') {
                        /*
                         * found the line to match
                         */
                        del_count = window->ccol - plen;
                        break;
                    }
                }
            }
        }

        /*
         * move text to delete char(s), unless no chars actually there
         */
        if (window->ccol - del_count < len) {
            /*
             * note that this may move characters beyond the end of the
             *  line in the line buffer, but this does not matter.
             */
            source = g_status.line_buff + window->ccol;
            dest = source - del_count;
            number = strlen(g_status.line_buff) - window->ccol + 1;
            hw_move(dest, source, number);
            fix_marks(window, dest, -(long)del_count);
        }
        window->ccol -= del_count;

        /*
         * give update algorithm a hint
         */
        if (del_count == 1) {
            xygoto(window->ccol, window->cline);
            c_delete();
        }
    }
}

/*
 * Name:    line_kill
 * Purpose: To delete the line the cursor is on.
 * Date:    October 1, 1989
 * Passed:  window:   information allowing access to the current window
 */
void line_kill(window)
windows *window;
{
    /*
     * let copy and un_copy do most of the work. Simply record that the
     *  current line has no characters in it!
     */
    copy_line(window);
    window_scroll_up(window->cline, window->bottom_line);
    fix_marks(window, g_status.line_buff, -(long)strlen(g_status.line_buff));
    *g_status.line_buff = '\0';
    un_copy_line(window);
    window->ccol = 0;
}

/*
 * Name:    char_del_under
 * Purpose: To delete the character under the cursor.
 * Date:    October 1, 1989
 * Passed:  window:   information allowing access to the current window
 * Notes:   If the cursor is beyond the end of the line, then this
 *           command is ignored.
 */
void char_del_under(window)
windows *window;
{
    text_ptr source;    /* source of block move to delete character */
    text_ptr dest;      /* destination of block move */
    long number;        /* number of characters to move */

    copy_line(window);
    if (window->ccol >= linelen(g_status.line_buff)) {
        return;
    }
    else {
        /*
         * move text to delete char, then fix marks
         */
        source = g_status.line_buff + window->ccol + 1;
        dest = source - 1;
        number = strlen(g_status.line_buff) - window->ccol;
        hw_move(dest, source, number);
        fix_marks(window, dest, -1L);

        /*
         * give update algorithm a hint
         */
        xygoto(window->ccol, window->cline);
        c_delete();
    }
}

/*
 * Name:    eol_kill
 * Purpose: To delete everything from the cursor to the end of the line.
 * Date:    October 1, 1989
 * Passed:  window:   information allowing access to the current window
 * Notes:   If the cursor is beyond the end of the line, then this
 *           command is ignored.
 */
void eol_kill(window)
windows *window;
{
    char *dest;  /* the start of the delete area */
    int len;     /* the length of the current line */

    copy_line(window);
    if (window->ccol >= (len = linelen(g_status.line_buff))) {
        return;
    }
    else {
        /*
         * truncate to delete rest of line
         */
        dest = g_status.line_buff + window->ccol;

        /*
         * the \n at the end of the line must NOT be deleted!
         */
        if (g_status.line_buff[len] == '\n') {
            *dest++ = '\n';
        }

        len = strlen(dest);
        fix_marks(window, dest, (long) (-len));
        *dest = '\0';
    }
}

/*
 * Name:    reminder
 * Purpose: To remind the user that we are half-way through a two-character
 *           command.
 * Date:    October 1, 1989
 * Passed:  mess:     the text to be displayed
 * Notes:   "mess" is displayed, highlighted, in the top left corner
 */
void reminder(mess)
char *mess;
{
    char old_wanted;  /* previous attribute */

    /*
     * only display message if user has not already typed the command!
     */
    if (!c_avail()) {
        xygoto(0, 0);
        old_wanted = g_status.wanted;
        set_attr(g_display.flash);
        s_output(mess);
        set_attr(old_wanted);
    }
}

/*
 * Name:    goto_left
 * Purpose: To move the cursor to the left of the current line.
 * Date:    October 1, 1989
 * Passed:  window:   information allowing access to the current window
 */
void goto_left(window)
windows *window;
{
    window->ccol = 0;
}

/*
 * Name:    goto_right
 * Purpose: To move the cursor to the right of the current line.
 * Date:    October 1, 1989
 * Passed:  window:   information allowing access to the current window
 */
void goto_right(window)
windows *window;
{
    if (g_status.copied) {
        window->ccol = linelen(g_status.line_buff);
    }
    else {
        window->ccol = linelen(window->cursor);
    }

    /*
     * keep cursor on screen
     */
    if (window->ccol >= g_display.ncols) {
        window->ccol = g_display.ncols-1;
    }
}

/*
 * Name:    goto_top
 * Purpose: To move the cursor to the top of the current window.
 * Date:    October 1, 1989
 * Passed:  window:   information allowing access to the current window
 * Notes:   If the start of the file occurs before the top of the window,
 *           then the start of the file is moved to the top of the window.
 */
void goto_top(window)
windows *window;
{
    text_ptr cursor;  /* anticipated cursor line */

    un_copy_line(window);
    for (; window->cline > window->top_line; window->cline--) {
        if ((cursor = find_prev(window->cursor)) == NULL) {
            window->cline = window->top_line;
            break;
        }
        window->cursor = cursor;
    }
}

/*
 * Name:    goto_bottom
 * Purpose: To move the cursor to the bottom of the current window.
 * Date:    October 1, 1989
 * Passed:  window:   information allowing access to the current window
 * Notes:   If the end of the file occurs before the bottom of the window,
 *           then the end of the file is moved to the bottom of the window.
 */
void goto_bottom(window)
windows *window;
{
    text_ptr cursor;

    un_copy_line(window);
    for (; window->cline < window->bottom_line; window->cline++) {
        if ((cursor = find_next(window->cursor)) == NULL) {
            window->cline = window->bottom_line;
            break;
        }
        window->cursor = cursor;
    }
}

/*
 * Name:    set_tabstop
 * Purpose: To set the current interval between tab stops
 * Date:    October 1, 1989
 * Notes:   Tab interval must be reasonable, and this function will
 *           not allow tabs more than MAX_COLS / 2.
 */
void set_tabstop()
{
    char num_str[MAX_COLS];  /* tab interval as a character string */
    int tab;                 /* new tab interval */

    for (;;) {
        sprintf(num_str, "%d", g_status.tab_size);
        if (get_name("Tab interval: ", 1, num_str) != OK) {
            return;
        }
        tab = atoi(num_str);
        if (tab < MAX_COLS/2) {
            break;
        }
    }
    g_status.tab_size = tab;
}

/*
 * Name:    command
 * Purpose: To input and execute a command or printable character.
 * Date:    October 1, 1989
 * Passed:  window:   information allowing access to the current window
 * Returns: nothing really, but needs to be compatible with other functions
 *           of type do_func.
 * Notes:   This enormous string of nested ifs is not a very modular
 *           way of doing things. Eventually, the user should probably
 *           be allowed to change the command keys without needing to
 *           recompile the source code. For the present, at least this
 *           keeps everything in the one place so it is easy to change!
 */
int command(window)
windows *window;
{
    int c;   /* character entered */

    if (hw_printable(c = c_input())) {
        /*
         * if a printable character, simply insert it
         */
        insert(window, c, TRUE);
    }
    else if (c == '\t') {
        tab_key(window);
    }
    else if (c == '\b') {
        char_del_left(window);
    }
    else if (c == CONTROL('G') || c == 127) {
        char_del_under(window);
    }
    else if (c == '\r') {
        insert(window, '\n', TRUE);
    }
    else if (c == CONTROL('N')) {
        insert(window, '\n', FALSE);
    }
    else if (c == CONTROL('L')) {
        do_last(window);
    }
    else if (c == CONTROL('Z')) {
        scroll_down(window);
    }
    else if (c == CONTROL('W')) {
        scroll_up(window);
    }
    else if (c == CONTROL('X')) {
        move_down(window);
    }
    else if (c == CONTROL('E')) {
        move_up(window);
    }
    else if (c == CONTROL('S')) {
        move_left(window);
    }
    else if (c == CONTROL('D')) {
        move_right(window);
    }
    else if (c == CONTROL('C')) {
        page_down(window);
    }
    else if (c == CONTROL('R')) {
        page_up(window);
    }
    else if (c == CONTROL('F')) {
        word_right(window);
    }
    else if (c == CONTROL('A')) {
        word_left(window);
    }
    else if (c == CONTROL('T')) {
        word_delete(window);
    }
    else if (c == CONTROL('Y')) {
        line_kill(window);
    }
    else if (c == CONTROL('V')) {
        g_status.insert = !g_status.insert;
    }
    else if (c == CONTROL('J')) {
        get_help(window);
    }
    else if (c == CONTROL('\\')) {
        force_blank();
    }
    else if (c == CONTROL('K')) {
        reminder("^K");
        if ((c = c_input()) >= '0' && c <= '9') {
            set_marker(window, c - '0');
        }
        else {
            c = CONTROL(c);
            if (c == CONTROL('Q')) {
                quit(window);
            }
            else if (c == CONTROL('S')) {
                save_file(window, SAVE_NORMAL);
            }
            else if (c == CONTROL('T')) {
                save_as_file(window);
            }
            else if (c == CONTROL('X')) {
                if (window->file_info->modified) {
                    save_file(window, SAVE_NORMAL);
                }

                /*
                 * The following check picks up the case where for some
                 *  reason the file could not be written. In such a case,
                 *  the last thing we want to do is quit the editor!
                 */
                if (!window->file_info->modified) {
                    finish(window);
                }
            }
            else if (c == CONTROL('D')) {
                save_file(window, SAVE_NORMAL);
                if (!window->file_info->modified) {
                    finish(window);
                }
            }
            else if (c == CONTROL('B')) {
                mark_start(window);
            }
            else if (c == CONTROL('K')) {
                mark_end(window);
            }
            else if (c == CONTROL('H')) {
                window->file_info->visible = !window->file_info->visible;
            }
            else if (c == CONTROL('V')) {
                block_move(window);
            }
            else if (c == CONTROL('Y')) {
                block_delete(window);
            }
            else if (c == CONTROL('C')) {
                block_copy(window);
            }
            else if (c == CONTROL('I')) {
                block_indent(window);
            }
            else if (c == CONTROL('U')) {
                block_unindent(window);
            }
            else if (c == CONTROL('R')) {
                block_read(window, FALSE);
            }
            else if (c == CONTROL('@')) {
                block_read(window, TRUE);
            }
            else if (c == CONTROL('W')) {
                block_write(window);
            }
            else if (c == CONTROL('P')) {
                block_print(window);
            }
            else if (c == CONTROL('F')) {
                os_shell();
            }
            else {
                error(WARNING, "unknown command: ^K^%c",
                        CONTROL(c)+'A'-1);
            }
        }
    }
    else if (c == CONTROL('Q')) {
        reminder("^Q");
        if ((c = c_input()) >= '0' && c <= '9') {
            goto_marker(window, c - '0');
        }
        else {
            c = CONTROL(c);
            if (c == CONTROL('L')) {
                g_status.copied = FALSE;
            }
            else if (c == CONTROL('Y')) {
                eol_kill(window);
            }
            else if (c == CONTROL('F')) {
                find_string(window);
            }
            else if (c == CONTROL('A')) {
                replace_string(window);
            }
            else if (c == CONTROL('P')) {
                goto_marker(window, PREVIOUS);
            }
            else if (c == CONTROL('B')) {
                goto_marker(window, START_BLOCK);
            }
            else if (c == CONTROL('K')) {
                goto_marker(window, END_BLOCK);
            }
            else if (c == CONTROL('S')) {
                goto_left(window);
            }
            else if (c == CONTROL('D')) {
                goto_right(window);
            }
            else if (c == CONTROL('E')) {
                goto_top(window);
            }
            else if (c == CONTROL('X')) {
                goto_bottom(window);
            }
            else if (c == CONTROL('R')) {
                goto_top_file(window);
            }
            else if (c == CONTROL('C')) {
                goto_end_file(window);
            }
            else if (c == CONTROL('[')) {
                match_pair(window, TRUE);
            }
            else if (c == CONTROL(']')) {
                match_pair(window, FALSE);
            }
            else if (c == CONTROL('I')) {
                goto_line(window);
            }
            else {
                error(WARNING, "unknown command: ^Q^%c",
                        CONTROL(c)+'A'-1);
            }
        }
    }
    else if (c == CONTROL('O')) {
        reminder("^O");
        if ((c = CONTROL(c_input())) == CONTROL('I')) {
            g_status.indent = !g_status.indent;
        }
        else if (c == CONTROL('U')) {
            g_status.unindent = !g_status.unindent;
        }
        else if (c == CONTROL('T')) {
            set_tabstop();
        }
        else if (c == CONTROL('K')) {
            choose_window(NULL, window);
        }
        else if (c == CONTROL('M')) {
            size_window(window);
        }
        else {
            error(WARNING, "unknown command: ^O^%c",
                    CONTROL(c)+'A'-1);
        }
    }
    else if (c == 0) {
        /*
         * ignore
         */
        ;
    }
    else {
        error(WARNING, "illegal (unprintable) key: %d", c);
    }
    xygoto(g_status.current_window->ccol, g_status.current_window->cline);

    /*
     * check for time to auto-save
     */
    if (g_status.unsaved) {
        if (time(NULL) > g_status.save_interval + g_status.save_time) {
            save_file(g_status.current_window, SAVE_RECOVERY);
            g_status.save_time += g_status.save_interval;
        }
    }

    return 0;  /* no meaning here */
}

/*
 * Name:    editor
 * Purpose: To allow the full-screen editing of plain text files, in a way
 *           that is effective over slow serial communication lines.
 * Date:    October 1, 1989
 * Passed:  argc:   number of command line arguments
 *          argv:   text of command line arguments
 * Notes:   This is a separate function, rather than the main program, in
 *           case the hardware dependent implementation needs extra
 *           command line parameters etc.
 */
void editor(argc, argv)
int argc;
char *argv[];
{
    char *name;  /* name of file to start editing */

    /*
     * set up the screen
     */
    initialize();

    /*
     * Check that user specified file to edit, if not offer help
     */
    if (argc != 2) {
        name = g_status.help_file;
    }
    else {
        name = argv[1];
    }

    /*
     * If a recovery file exists from a previous editing session,
     *  then perform recovery automatically.
     */
    hw_copy_path(name, RECOVERY, g_status.recovery);
    if (hw_fattrib(g_status.recovery) != ERROR) { /* file exists */
        error(DIAG, "Recovering previous file");
        if (open_window(NULL, g_status.recovery) == ERROR) {
            terminate();
            exit(1);
        }
        /*
         * record no default file name when saving, and force user to save
         */
        g_status.file_list->file_name[0] = '\0';
        g_status.file_list->modified = TRUE;
    }
    else if (open_window(NULL, name) == ERROR) {
        /*
         * could not open window for normal edit file - out of memory?
         */
        terminate();
        exit(1);
    }

    /*
     * main loop - keep updating the display and processing any commands
     *  forever!
     */
    for (;;) {
        (void) display(command, 0);
    }
}
