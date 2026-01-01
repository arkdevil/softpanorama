/*
 * Written by Douglas Thomson (1989/1990)
 *
 * This source code is released into the public domain.
 */

/*
 * Name:    dte - Doug's Text Editor program - miscellaneous utilities
 * Purpose: This file contains miscellaneous functions that were required
 *           in more than one of the other files, or were thought to be
 *           likely to be used elsewhere in the future.
 * File:    utils.c
 * Author:  Douglas Thomson
 * System:  this file is intended to be system-independent
 * Date:    October 1, 1989
 */

#ifdef HPXL
#include "commonh"
#include "utilsh"
#else
#include "common.h"
#include "utils.h"
#endif
#include <time.h>
#ifdef __TURBOC__
#include <dir.h>        /* for making temporary file names etc */
#endif

/*
 * prototypes for all functions in this file
 */
int myisalnum ARGS((char c));
int linelen ARGS((text_ptr s));
int prelinelen ARGS((text_ptr s));
text_ptr find_next ARGS((text_ptr s));
text_ptr find_prev ARGS((text_ptr current));
void copy_line ARGS((windows *window));
void un_copy_line ARGS((windows *window));
int expand ARGS((text_ptr dest, text_ptr end));
int load_file ARGS((char *name, int fixup));
void set_prompt ARGS((char *prompt, int lines));
int get_name ARGS((char *prompt, int lines, char *name));
void fix_marks ARGS((windows *window, text_ptr pos, long len));
int get_ynaq ARGS((windows *window));
int get_yn ARGS((windows *window));
int get_oa ARGS((windows *window));
char get_attr ARGS((windows *window, text_ptr text));
int update_line ARGS((windows *window, text_ptr orig, int line,
        text_ptr cursor));
int display_window ARGS((windows *window, int last, text_ptr cursor, int wn));
int display ARGS((do_func doit, int reserved));
void setup_window ARGS((windows *window));
int first_non_blank ARGS((char *s));
void page_up ARGS((windows *window));
void page_down ARGS((windows *window));
void scroll_down ARGS((windows *window));
void scroll_up ARGS((windows *window));
void save_file ARGS((windows *window, int kind));
void save_as_file ARGS((windows *window));

/*
 * Name:    myisalnum
 * Purpose: To determine whether or not a character is part of a "word",
 *           which in languages like Pascal means a letter, digit or
 *           underscore.
 * Date:    October 1, 1989
 * Passed:  c: the character to be tested
 * Returns: TRUE if c is an alphanumeric or '_' character, FALSE otherwise
 */
int myisalnum(c)
char c;
{
    if ((c >= 'A' && c <= 'Z') ||
            (c >= 'a' && c <= 'z') ||
            (c >= '0' && c <= '9') ||
            (c == '_')) {
        return TRUE;
    }
    return FALSE;
}

/*
 * Name:    linelen
 * Purpose: To determine the length of a line, up to either a \n or a
 *           \0, whichever comes first.
 * Date:    October 1, 1989
 * Passed:  s: the line to be measured
 * Returns: the length of the line
 */
int linelen(s)
text_ptr s;
{
    int len = 0;

    while (*s && *s != '\n') {
        ++len;
        ++s;
    }
    return len;
}

/*
 * Name:    prelinelen
 * Purpose: To determine the length of a line, from the current position
 *           backwards to either a \n or a \0, whichever comes first.
 * Date:    October 1, 1989
 * Passed:  s: the line to be measured
 * Returns: the length of the line up to the current position
 * Notes:   It is assumed there will be a "terminating" \0 before the
 *           start of the first line. This is the case with the main
 *           text buffer, but elsewhere beware.
 */
int prelinelen(s)
text_ptr s;
{
    int len = 0;

    while (*--s && *s != '\n') {
        ++len;
    }
    return len;
}

/*
 * Name:    find_next
 * Purpose: To find the first character in the next line after the starting
 *           point.
 * Date:    October 1, 1989
 * Passed:  s: the starting point
 * Returns: the first character in the next line
 */
text_ptr find_next(s)
text_ptr s;
{
    while (*s && *s != '\n') {
        ++s;
    }
    if (*s) {
        return ++s;
    }
    return NULL;
}

/*
 * Name:    find_prev
 * Purpose: To find the start of the line before the current line.
 * Date:    October 1, 1989
 * Passed:  current: the current line
 * Returns: the start if the previous line
 * Notes:   current must be at the start of the current line to begin with.
 *          There must be a \0 preceding the first line.
 */
text_ptr find_prev(current)
text_ptr current;
{
    if (*--current == '\0') {
        return NULL;
    }
    for (;;) {
        if (*--current == '\n' || *current == '\0') {
            return ++current;
        }
    }
}

/*
 * Name:    copy_line
 * Purpose: To copy the cursor line, if necessary, into the current line
 *           buffer, so that changes can be made efficiently.
 * Date:    October 1, 1989
 * Passed:  window: access to the current line
 * Notes:   As the cursor line is being copied, any markers that are set
 *           within the line are also copied.
 *          Trailing spaces left on the line (presumably from earlier
 *           editing) are removed during the copy.
 *          See un_copy_line, the reverse operation.
 */
void copy_line(window)
windows *window;
{
    text_ptr p, q;     /* destination and source of copy */
    int count;         /* number of characters copied */
    int i;             /* for updating markers */
    text_ptr end_line; /* end of line after removing trailing spaces */

    /*
     * If the line has already been copied, then do not copy it again
     */
    if (g_status.copied) {
        return;
    }

    /*
     * record that the current line buffer is active
     */
    g_status.copied = TRUE;

    /*
     * clear any old buffer markers left from last time
     */
    for (i=0; i < NO_MARKS; i++) {
        g_status.buff_marker[i] = NULL;
    }

    /*
     * find out where the line should end after removing trailing
     *  spaces.
     */
    end_line = q = window->cursor;
    while (*q && *q != '\n') {
        if (*q++ != ' ') {
            end_line = q;
        }
    }

    /*
     * copy the cursor line to the line buffer, noting any markers
     *  passed along the way
     */
    p = g_status.line_buff;
    q = window->cursor;
    for (count=0; ; ) {
        for (i=0; i < NO_MARKS; i++) {
            if (q == window->file_info->marker[i]) {
                g_status.buff_marker[i] = p;
            }
        }
        if (*q == '\n') {
            *p++ = *q++;
            break;
        }
        if (*q == '\0') {
            break;
        }

        /*
         * avoid copying trailing spaces
         */
        if (q < end_line) {
            if (++count >= BUFF_SIZE) {
                error(WARNING, "line buffer overflow - line truncated!");
                break;
            }
            *p++ = *q;
        }
        ++q;
    }
    *p = '\0';
}

/*
 * Name:    un_copy_line
 * Purpose: To copy the cursor line, if necessary, from the current line
 *           buffer, shifting the main text to make the right amount of
 *           room.
 * Date:    October 1, 1989
 * Passed:  window: access to the current line
 * Notes:   As the cursor line is being copied, any markers that are set
 *           within the line buffer are also copied.
 *          For various reasons, trailing spaces are NOT removed when
 *           returning the line buffer to the main text. Typically,
 *           padding is added at the end of a line by deliberately
 *           adding trailing spaces, and then uncopying the line.
 *          See copy_line, the reverse operation.
 */
void un_copy_line(window)
windows *window;
{
    text_ptr source; /* source for block move and for copying buffer line */
    text_ptr dest;   /* destination for block move and copy */
    long number;     /* length of block move */
    int len;         /* length of current line buffer text */
    int curs_len;    /* length of cursor line */
    int i;           /* used for checking markers */

    /*
     * do not uncopy unless the line buffer is active
     */
    if (!g_status.copied) {
        return;
    }

    /*
     * record that the line buffer is not active
     */
    g_status.copied = FALSE;

    /*
     * work out the lengths of the old cursor line (including the \n if any)
     *  and the new current line buffer text.
     */
    curs_len = linelen(window->cursor);
    if (window->cursor[curs_len] == '\n') {
        ++curs_len;
    }
    len = strlen(g_status.line_buff);

    /*
     * if the main text buffer has run out of space, then only part of the
     *  current line can be moved back into the main buffer. Warn the user
     *  that some of the current line has been lost
     */
    if (g_status.end_mem + len - curs_len >= g_status.max_mem) {
        error(WARNING, "buffer full, part line truncated");
        len = curs_len + (int) (g_status.max_mem - g_status.end_mem);
        g_status.line_buff[len] = '\0';
    }

    /*
     * move text to either make room for the extra characters in the new
     *  line, or else close up the gap.
     */
    source = window->cursor + curs_len;
    dest = source + len - curs_len;
    number = g_status.end_mem - source;
    hw_move(dest, source, number);

    /*
     * adjust any markers that were set after the original cursor line
     */
    fix_marks(window, window->cursor, (long) (len - curs_len));

    /*
     * now copy the line buffer into the space just created, updating any
     *  markers found in the line buffer
     */
    source = g_status.line_buff;
    dest = window->cursor;
    for (;;) {
        for (i=0; i < NO_MARKS; i++) {
            if (g_status.buff_marker[i] == source) {
                window->file_info->marker[i] = dest;
            }
        }
        if (*source == '\0') {
            break;
        }
        *dest++ = *source++;
    }
}

/*
 * Name:    expand
 * Purpose: To expand tabs in text from an input file.
 * Date:    October 1, 1989
 * Passed:  dest:   start of text to expand
 *          end:    end of text to expand
 * Returns: OK if text fitted in buffer and was reasonable text
 *          ERROR if any problem
 * Notes:   Tabs are expanded using the current tab interval.
 *          Lines are checked to make sure they are not too long.
 *          Characters are checked to ensure a NULL character does not
 *           get into the buffer.
 *          Originally, this function was called for all file reads.
 *           However, it proved rather slow, and unnecessary for most
 *           files. The only real danger is a NULL character, which the
 *           editor will treat as the end of the buffer.
 */
int expand(dest, end)
text_ptr dest;
text_ptr end;
{
    int spaces = 0;  /* spaces still to be inserted to make tab */
    int count = 0;   /* characters on the current line */
    long number;     /* bytes in original text */
    text_ptr source; /* current position in copied original text */
    char c;          /* current character from source */
    char lastc = 0;  /* character before c */
    int noinc;       /* do not increment source? */

    /*
     * first copy entire text to the very end of the buffer, so
     *  that it can be copied back to the start while expanding tabs
     */
    number = end - dest;
    source = dest + (g_status.max_mem - end);
    hw_move(source, dest, number); /* note source and dest reversed here */
    end = g_status.max_mem;

    /*
     * keep on processing until end of text or some kind of error
     */
    while (source < end) {
        c = *source;

        /*
         * check main text buffer still has room
         */
        if (dest >= end) {
            error(WARNING, "buffer full");
            return ERROR;
        }

        /*
         * if the last character was a tab, then pretend the right number
         *  of spaces occurred in the file
         */
        if ((noinc = spaces) != 0) {
            --spaces;
            c = ' ';
        }

        /*
         * process next character
         */
        if (++count >= BUFF_SIZE) {
            /*
             * current line too long to handle
             */
            error(WARNING, "line too long");
            return ERROR;
        }
        else if (c == '\n') {
            /*
             * end of line - now remove trailing spaces
             */
            if (lastc == ' ') {
                while (*--dest == ' ') {
                    ;
                }
                ++dest;
            }
            count = 0;
        }
        else if (c == '\t') {
            /*
             * work out how many spaces are required to expand the tab
             */
            spaces = g_status.tab_size - ((count-1) % g_status.tab_size) - 1;
            c = ' ';
        }
        else if (c == 0) {
            /*
             * this would confuse things rather...
             */
            error(WARNING, "cannot handle NULL characters");
            return ERROR;
        }
        if (!noinc) {
            source++;
        }
        *dest++ = c;
        lastc = c;
    }

    /*
     * record the end of the text just read
     */
    g_status.temp_end = dest;
    return OK;
}

/*
 * Name:    load_file
 * Purpose: To read in a given file to the end of the main text buffer.
 * Date:    October 1, 1989
 * Passed:  name:   path name of file to be read
 *          fixup:  should tabs be expanded after reading?
 * Returns: OK if file read successfully
 *          ERROR if any problem (such as out of buffer space)
 * Notes:   If the file does not exist, the user is informed of an error,
 *           so check first if it is OK for the file to be new.
 */
int load_file(name, fixup)
char *name;
int fixup;
{
    /*
     * make sure this gets set properly even if there is no file!
     */
    g_status.temp_end = g_status.end_mem;

    if (hw_load(name, g_status.end_mem, g_status.max_mem,
            &g_status.temp_end) == ERROR) {
        return ERROR;
    }

    if (fixup) {
        /*
         * expand tabs and check for printable characters only
         */
        error(TEMP, "expanding tabs...");
        return expand(g_status.end_mem, g_status.temp_end);
    }
    else {
        return OK;
    }
}

/*
 * Name:    set_prompt
 * Purpose: To display a prompt, highlighted, at the bottom of the screen.
 * Date:    October 1, 1989
 * Passed:  prompt: prompt to be displayed
 *          lines:  how many lines up from the bottom (usually just 1)
 * Notes:   We use update_line to display the prompt, since it can deal
 *           with clearing to end of line even on terminals without such
 *           a command.
 */
void set_prompt(prompt, lines)
char *prompt;
int lines;
{
    text_ptr old_start;    /* for saving match location */
    text_ptr old_end;      /*  "  */
    windows empty_window;  /* window with no marked text */
    file_infos empty_file; /* file with no marked text */

    /*
     * save current matched text
     */
    old_start = g_status.match_start;
    old_end = g_status.match_end;

    /*
     * work out where the answer should go
     */
    g_status.prompt_col = strlen(prompt);
    g_status.prompt_line = g_display.nlines - lines;

    /*
     * cause the prompt to be highlighted
     */
    g_status.match_start = prompt;
    g_status.match_end = prompt + g_status.prompt_col;

    /*
     * set up a window which will not have anything except normal
     *  attributes
     */
    empty_window.file_info = &empty_file;
    empty_file.visible = FALSE;

    /*
     * output the prompt
     */
    update_line(&empty_window, prompt, g_display.nlines-lines,
            NULL);

    /*
     * restore the old matched text
     */
    g_status.match_start = old_start;
    g_status.match_end = old_end;

    /*
     * ensure the cursor is in the right place
     */
    xygoto(g_status.prompt_col, g_status.prompt_line);
}

/*
 * Name:    get_name
 * Purpose: To prompt the user, and read the string the user enters in
 *           response.
 * Date:    October 1, 1989
 * Passed:  prompt: prompt to offer the user
 *          lines:  no. of lines up from the bottom of the screen
 *          name:   default answer
 * Returns: name:   user's answer
 *          OK if user entered something
 *          ERROR if user aborted the command
 * Notes:   Editing of the line is supported.
 */
int get_name(prompt, lines, name)
char *prompt;
int lines;
char *name;
{
    int col;                /* cursor column for answer */
    int line;               /* cursor line for answer */
    int c;                  /* character user just typed */
    char *cp;               /* cursor position in answer */
    char *answer;           /* user's answer */
    int first = TRUE;       /* first character typed */
    int len;                /* length of answer */
    int plen;               /* length of prompt */
    char *p;                /* for copying text in answer */
    char buffer[MAX_COLS+1];/* line on which name is being entered */
    windows empty_window;  /* window with no marked text */
    file_infos empty_file; /* file with no marked text */

    /*
     * set up prompt and default
     */
    strcpy(buffer, prompt);
    plen = strlen(prompt);
    answer = buffer + plen;
    strcpy(answer, name);

    /*
     * set up a window which will not have anything except normal
     *  attributes
     */
    empty_window.file_info = &empty_file;
    empty_file.visible = FALSE;

    /*
     * let user edit default into desired string
     */
    len = strlen(answer);
    col = strlen(buffer);
    line = g_display.nlines - lines;
    cp = answer + len;
    for (;;) {
        /*
         * cause the prompt to be highlighted
         */
        g_status.match_start = buffer;
        g_status.match_end = buffer + len + plen;

        /*
         * output the line
         */
        update_line(&empty_window, buffer, line, NULL);

        /*
         * remove highlighting
         */
        g_status.match_start = g_status.match_end = NULL;

        /*
         * place cursor in correct position
         */
        xygoto(col, line);

        /*
         * process next keystroke
         */
        if ((c = c_input()) == '\r') {
            /*
             * finished
             */
            break;
        }
        if (c == '\b') {
            /*
             * delete to left of cursor
             */
            if (cp > answer) {
                for (p=cp-1; p < answer+len; p++) {
                    *p = *(p+1);
                }
                --len;
                --col;
                --cp;
                xygoto(col, line);
                c_delete();
            }
        }
        else if (c == CONTROL('G') || c == 127) {
            /*
             * delete char under cursor
             */
            if (*cp) {
                for (p=cp; p < answer+len; p++) {
                    *p = *(p+1);
                }
                --len;
                c_delete();
            }
        }
        else if (c == CONTROL('Y')) {
            /*
             * delete current line
             */
            col = plen;
            cp = answer;
            *cp = '\0';
            len = 0;
        }
        else if (c == CONTROL('R')) {
            /*
             * restore original line
             */
            strcpy(answer, name);
            len = strlen(answer);
            col = plen + len;
            cp = answer + len;
        }
        else if (c == CONTROL('S')) {
            /*
             * move cursor left
             */
            if (cp > answer) {
                col--;
                cp--;
            }
        }
        else if (c == CONTROL('D')) {
            /*
             * move cursor right
             */
            if (*cp) {
                col++;
                cp++;
            }
        }
        else if (c == CONTROL('E')) {
            /*
             * move cursor to start of line
             */
            col = plen;
            cp = answer;
        }
        else if (c == CONTROL('X')) {
            /*
             * move cursor to end of line
             */
            col = plen + len;
            cp = answer + len;
        }
        else if (hw_printable(c)) {
            /*
             * insert character at cursor
             */
            if (first) {
                /*
                 * delete previous answer
                 */
                col = plen;
                cp = answer;
                *cp = '\0';
                len = 0;
            }

            /*
             * insert new character
             */
            if (col < g_display.ncols-1) {
                for (p=answer+len; p >= cp; p--) {
                    *(p+1) = *p;
                }
                *cp = c;
                c_insert();
                c_output(c);
                ++cp;
                ++len;
                ++col;
            }
        }
        else if (c == 27 || c == CONTROL('U')) {
            /*
             * abort operation
             */
            return ERROR;
        }
        first = FALSE;
    }

    /*
     * finally, replace the default
     */
    strcpy(name, answer);
    return OK;
}

/*
 * Name:    fix_marks
 * Purpose: To make the necessary adjustments to the appropriate markers
 *           after characters have been inserted or deleted.
 * Date:    October 1, 1989
 * Passed:  window: access to the current window, buffers and markers
 *          pos:    position of insertion or deletion
 *          len:    length of insertion or (if negative) deletion
 */
void fix_marks(window, pos, len)
windows *window;
text_ptr pos;
long len;
{
    int i;              /* used to can through markers */
    text_ptr other;     /* end of deleted area */
    file_infos *file;   /* for scanning markers in other files */
    windows *wp;        /* for checking cursor lines */

    /*
     * If the cursor line was copied into the line buffer (perhaps
     *  for moving the cursor by a word) and then copied back with
     *  no change, then there is nothing to do here.
     */
    if (len == 0) {
        return;
    }

    if (pos >= g_status.start_mem && pos < g_status.end_mem) {
        /*
         * the insert/delete affected the total text
         */
        if (len >= 0) {
            /*
             * adjust file position markers of all files
             */
            for (file=g_status.file_list; file; file = file->next) {
                for (i=0; i < NO_MARKS; i++) {
                    if (file->marker[i] > pos) {
                        file->marker[i] += len;
                    }
                }
            }

            /*
             * adjust cursor lines of other windows
             */
            for (wp=g_status.window_list; wp; wp = wp->next) {
                if (wp != window) {
                    if (wp->cursor > pos) {
                        wp->cursor += len;
                    }
                }
            }
        }
        else {
            other = pos - len;
            /*
             * adjust file position markers of all files
             */
            for (file=g_status.file_list; file; file = file->next) {
                for (i=0; i < NO_MARKS; i++) {
                    if (file->marker[i] >= other) {
                        file->marker[i] += len;
                    }
                    else if (file->marker[i] > pos) {
                        file->marker[i] = pos;
                    }
                }
            }

            /*
             * adjust cursor lines of other windows
             */
            for (wp=g_status.window_list; wp; wp = wp->next) {
                if (wp != window) {
                    if (wp->cursor >= other) {
                        wp->cursor += len;
                    }
                    else if (wp->cursor > pos) {
                        wp->cursor = pos;
                    }
                }
            }
        }

        /*
         * adjust file buffer beginning and ending positions for
         *  all files
         */
        for (file=g_status.file_list; file; file = file->next) {
            if (file->start_text > pos) {
                file->start_text += len;
            }
            if (file->end_text > pos) {
                file->end_text += len;
            }
        }

        /*
         * adjust total memory buffer size
         */
        g_status.end_mem += len;
    }
    else {
        /*
         * the insert/delete only affected the current line
         */
        if (len >= 0) {
            for (i=0; i < NO_MARKS; i++) {
                if (g_status.buff_marker[i] > pos) {
                    g_status.buff_marker[i] += len;
                }
            }
        }
        else {
            other = pos - len;
            for (i=0; i < NO_MARKS; i++) {
                if (g_status.buff_marker[i] >= other) {
                    g_status.buff_marker[i] += len;
                }
                else if (g_status.buff_marker[i] > pos) {
                    g_status.buff_marker[i] = pos;
                }
            }
        }
    }

    /*
     * If the window changed size, then it must have been edited in
     *  some way.
     */
    window->file_info->modified = TRUE;
    if (!g_status.unsaved) {
        g_status.save_time = time(NULL);
        g_status.unsaved = TRUE;
    }
}

/*
 * Name:    get_ynaq
 * Purpose: To input a response of yes, no, always or quit.
 * Date:    October 1, 1989
 * Passed:  window: access to the current window
 * Returns: the user's answer (A_??? - see common.h)
 */
int get_ynaq(window)
windows *window;
{
    char c;   /* user's response */

    /*
     * leave the cursor marking the find / replace text
     */
    xygoto(window->ccol, window->cline);

    /*
     * keep trying until the user enters something acceptable
     */
    for (;;) {
        c = c_input();
        if (hw_printable(c)) {
            xygoto(g_status.prompt_col, g_status.prompt_line);
            set_attr(g_display.flash);
            c_output(c);
        }
        switch (toupper(c)) {
        case 'Y':
            return A_YES;
        case 'N':
            return A_NO;
        case 'A':
            return A_ALWAYS;
        case 'Q':
            return A_QUIT;
        case 27:
        case CONTROL('U'):
            return A_ABORT;
        default:
            xygoto(window->ccol, window->cline);
            break;
        }
    }
}

/*
 * Name:    get_yn
 * Purpose: To input a response of yes or no.
 * Date:    October 1, 1989
 * Passed:  window: access to the current window (not used, but
 *                   required to match other functions of type do_func)
 * Returns: the user's answer (A_??? - see common.h)
 */
int get_yn(window)
windows *window;
{
    char c;   /* the user's response */

    for (;;) {
        xygoto(g_status.prompt_col, g_status.prompt_line);
        c = c_input();
        if (hw_printable(c)) {
            set_attr(g_display.flash);
            c_output(c);
        }
        switch (toupper(c)) {
        case 'Y':
            return A_YES;
        case 'N':
            return A_NO;
        case 27:
        case CONTROL('U'):
            return A_ABORT;
        default:
            break;
        }
    }
}

/*
 * Name:    get_oa
 * Purpose: To input a response of overwrite or append.
 * Date:    October 1, 1989
 * Passed:  window: access to the current window (not used, but
 *                   required to match other functions of type do_func)
 * Returns: the user's answer (A_??? - see common.h)
 */
int get_oa(window)
windows *window;
{
    char c;   /* the user's response */

    for (;;) {
        xygoto(g_status.prompt_col, g_status.prompt_line);
        c = c_input();
        if (hw_printable(c)) {
            set_attr(g_display.flash);
            c_output(c);
        }
        switch (toupper(c)) {
        case 'O':
            return A_OVERWRITE;
        case 'A':
            return A_APPEND;
        case 27:
        case CONTROL('U'):
            return A_ABORT;
        default:
            break;
        }
    }
}

/*
 * Name:    get_attr
 * Purpose: To find what attribute should be displayed at the current
 *           location.
 * Date:    October 1, 1989
 * Passed:  window:   information allowing access to the current window
 *          text:     location to be considered
 * Returns: the attribute required
 */
char get_attr(window, text)
windows *window;
text_ptr text;
{
    char wanted;    /* wanted attribute */
    int marked;     /* was text possibly marked? */

    if (window == NULL) {
        /*
         * This is a status line
         */
        wanted = g_display.block;
    }
    else if (*text < 32 && *text != '\n' && *text != '\0') {
        /*
         * this is a control character, always "flashing"
         */
        wanted = g_display.flash;
    }
    else if (text >= g_status.match_start && text < g_status.match_end) {
        /*
         * this is used for marking matched text in find/replace
         */
        wanted = g_display.flash;
    }
    else if (!window->file_info->visible) {
        /*
         * no visible block, so return quickly
         */
        wanted = g_display.normal;
    }
    else if (text >= window->file_info->start_text &&
            text < window->file_info->end_text) {
        /*
         * the current location is in the main text
         */
        if (text >= window->file_info->marker[START_BLOCK] &&
                text < window->file_info->marker[END_BLOCK]) {
            wanted = g_display.block;
        }
        else {
            wanted = g_display.normal;
        }
    }
    else {
        /*
         * the current location is in the current line buffer. Here,
         *  the text is marked if it is between the start and end
         *  markers within the current line, but it may also be marked
         *  if a block started before the current line, or ended
         *  after the current line.
         */
        if (g_status.buff_marker[START_BLOCK] == NULL) {
            marked = window->cursor > window->file_info->marker[START_BLOCK];
        }
        else {
            marked = text >= g_status.buff_marker[START_BLOCK];
        }

        if (marked) {
            if (g_status.buff_marker[END_BLOCK] == NULL) {
                marked = window->cursor <
                        window->file_info->marker[END_BLOCK];
            }
            else {
                marked = text < g_status.buff_marker[END_BLOCK];
            }
        }

        if (marked) {
            wanted = g_display.block;
        }
        else {
            wanted = g_display.normal;
        }
    }
    return wanted;
}

/*
 * this define is needed so we can display control characters
 *  sensibly
 */
#define fixup(c) ((c) < 32 ? (c)+'A'-1 : (c))

/*
 * Name:    update_line
 * Purpose: To make as few changes as possible to cause the current line
 *           to be what it should be.
 * Date:    October 1, 1989
 * Passed:  window:   information allowing access to the current window
 *          orig:     how the line SHOULD be
 *          line:     line number to be compared
 *          cursor:   the main text cursor location if line buffer is active
 * Returns: OK if line updated completely
 *          ERROR if update aborted by user typing a key
 * Notes:   This function checks both the text and the attributes, including
 *           the blank space beyond the right end of lines.
 *          The update is aborted if the user has typed a character.
 */
int update_line(window, orig, line, cursor)
windows *window;
text_ptr orig;
int line;
text_ptr cursor;
{
    int done = FALSE;   /* has line been completely compared? */
    text_ptr text;      /* current character of orig begin considered */
    int col;            /* update is current up to col */
    int new_col;        /* match is good up to new_col */
    int diff;           /* attribute was different */
    char wanted;        /* attribute wanted for current character */
    int check;          /* check for user input? */

    /*
     * return immediately if the user has typed a command.
     */
    if (c_avail()) {
        return ERROR;
    }

    /*
     * If this is the cursor line and it has been copied, then use the
     *  line buffer instead.
     */
    if (cursor == orig) {
        orig = g_status.line_buff;
        check = TRUE;
    }
    else {
        check = FALSE;
    }

    if (orig == NULL) {
        /*
         * we just want a blank line
         */
        new_col = 0;
        wanted = g_display.normal;
    }
    else {
        /*
         * Keep on patching differences until we reach the end of the
         *  text line
         */
        col = 0;
        for (;;) {
            diff = FALSE;
            text = orig + col;
            /*
             * see how far the lines match
             */
            for (new_col=col; ; new_col++, text++) {
                if (*text == '\n') {
                    done = TRUE;
                    break;
                }
                if (*text == '\0') {
                    done = TRUE;
                    break;
                }
                if (new_col == g_display.ncols) {
                    done = TRUE;
                    break;
                }
                wanted = get_attr(window, text);
                if (g_screen[line][new_col].attr != wanted) {
                    diff = TRUE;
                    break;
                }
                if (g_screen[line][new_col].c != fixup(*text)) {
                    break;
                }
            }
            if (done) {
                /*
                 * complete match up to end of text line
                 */
                break;
            }

            /*
             * check for anything else to be before updating screen (but
             *  only if this is the cursor line)
             */
            if (check && c_avail()) {
                return ERROR;
            }

            /*
             * use cursor addressing only if this means sending fewer
             *  characters to the terminal.
             * Often, the xygoto will be a no-op, since the cursor
             *  will already be in position.
             */
            if (new_col - col > g_display.ca_len || diff) {
                col = new_col;
            }
            xygoto(col, line);

            /*
             * output the required character
             */
            text = orig + col++;
            wanted = get_attr(window, text);
            set_attr(wanted);
            c_output(fixup(*text));
        }
        /*
         * lines now match up to the end of the text line
         *
         * work out what attribute to use for the rest of the line
         */
        text = orig + new_col;
        wanted = get_attr(window, text);
    }

    /*
     * now make the rest of the line spaces with the right attribute
     */
    col = new_col;
    done = FALSE;
    for (;;) {
        diff = FALSE;
        for (new_col=col; ; new_col++) {
            if (new_col == g_display.ncols) {
                done = TRUE;
                break;
            }
            if (g_screen[line][new_col].attr != wanted) {
                diff = TRUE;
                break;
            }
            if (g_screen[line][new_col].c != ' ') {
                break;
            }
        }
        if (done) {
            break;
        }
        if (check && c_avail()) {
            return ERROR;
        }
        if (new_col - col > g_display.ca_len || diff) {
            col = new_col;
        }
        xygoto(col, line);

        /*
         * the clear to end of line function is a quick way to get the
         *  normal attribute for the rest of the line. Unfortunately,
         *  it cannot be relied upon to set any other attribute!
         */
        if (wanted == g_display.normal) {
            if (eol_clear()) {
                break;
            }
        }
        set_attr(wanted);
        c_output(' ');
        col++;
    }
    return OK;
}

/*
 * Name:    display_window
 * Purpose: To update one window to look the way it should, making as few
 *           changes as possible.
 * Date:    October 1, 1989
 * Passed:  window:   information allowing access to the current window
 *          last:     number of lines to update (so we can reserve lines
 *                     for things like answering prompts)
 *          cursor:   cursor line if line buffer active
 *          wn:       window number
 * Returns: OK if window updated completely
 *          ERROR if update aborted by user typing a key
 * Notes:   First the cursor line is updated, and then lines above and
 *           below the cursor are updated alternately.
 */
int display_window(window, last, cursor, wn)
windows *window;
int last;
text_ptr cursor;
int wn;
{
    text_ptr prev;      /* successive lines above the cursor */
    text_ptr next;      /* successive lines below the cursor */
    int line_above;     /* line number of lines above cursor */
    int line_below;     /* line number of lines below cursor */
    int count;          /* number of lines updated so far */
    int turn = FALSE;   /* turn to do above or below line? */
    int number;         /* number of lines visible in window */
    char status_line[MAX_COLS+1]; /* status line at top of window */
    char *p;            /* for setting up status line */
    char check;         /* used to check character before start of line */
    int len;            /* characters by which cursor should be adjusted */

    /*
     * work out bottom line (+1) to be displayed
     */
    if (window->bottom_line+last >= g_display.nlines) {
        last = g_display.nlines - last;
    }
    else {
        last = window->bottom_line + 1;
    }

    /*
     * work out how many lines need to be displayed
     */
    number = last - window->top_line;

    /*
     * display the required number of lines, starting from the
     *  cursor line
     */
    for (count=0; count < number; turn = !turn) {
        if (count == 0) {
            /*
             * as a result of editing in other windows into the same
             *  file, it is possible that the cursor position may be
             *  in the middle of a line.
             * If this is the case, then the cursor position must be
             *  adjusted so that the line can be displayed properly.
             */
            check = *(window->cursor-1);
            if (check != '\n' && check != '\0') {
                len = prelinelen(window->cursor);
                window->cursor -= len;
                window->ccol += len;
                if (window->ccol >= g_display.ncols) {
                    window->ccol = g_display.ncols - 1;
                }
            }

            /*
             * if line is to be displayed, then update it
             */
            if (window->cline < last) {
                if (update_line(window, window->cursor, window->cline,
                        cursor)) {
                    return ERROR;
                }
            }

            /*
             * set up next and previous lines
             */
            next = find_next(window->cursor);
            prev = find_prev(window->cursor);
            line_above = window->cline - 1;
            line_below = window->cline + 1;

            /*
             * one more line has been displayed
             */
            ++count;

            if (wn == 0) {
                /*
                 * move the cursor to its correct position, since often
                 *  other lines will not be affected.
                 */
                xygoto(window->ccol, window->cline);
            }
        }
        else if (turn && line_below < last) {
            if (update_line(window, next, line_below, cursor)) {
                return ERROR;
            }
            if (next) {
                next = find_next(next);
            }
            ++count;
            ++line_below;
        }
        else if (!turn && line_above >= window->top_line) {
            if (update_line(window, prev, line_above, cursor)) {
                return ERROR;
            }
            if (prev) {
                prev = find_prev(prev);
            }
            ++count;
            --line_above;
        }
    }

    /*
     * display status line
     */
    sprintf(status_line, "== %s [%2d] ==", window->file_info->file_name, wn);
    count = strlen(status_line);
    p = status_line + count;
    while (count++ < g_display.ncols) {
        *p++ = '=';
    }
    *p = '\0';

    if (update_line(NULL, status_line, window->top_line-1, NULL)) {
        return ERROR;
    }
    return OK;
}

/*
 * Name:    display
 * Purpose: To update the display to look the way it should, making as few
 *           changes as possible.
 * Date:    October 1, 1989
 * Passed:  doit:     function to be called if a key is typed
 *          reserved: number of lines reserved for things like answering
 *                     prompts
 * Returns: the result returned by the function doit
 * Notes:   First the current window is updated, and then windows above and
 *           below the cursor are updated alternately.
 */
int display(doit, reserved)
do_func doit;
int reserved;
{
    windows *window;            /* current active window */
    int above_count;            /* window number above current */
    int below_count;            /* window number below current */
    windows *above;             /* window above current */
    windows *below;             /* window below current */
    text_ptr cursor;            /* cursor line in current window */

    /*
     * since some commands change the current window, display must check
     *  rather than relying on a passed parameter.
     */
    window = g_status.current_window;

    /*
     * If the line buffer is active, then other routines need to know
     *  which line should be taken from the line buffer instead.
     * This approach allows multiple windows into the same file to
     *  display the cursor line correctly.
     */
    if (g_status.copied) {
        cursor = window->cursor;
    }
    else {
        cursor = (text_ptr) -1; /* no line should start here! */
    }

    /*
     * display the current window
     */
    if (display_window(window, reserved, cursor, 0)) {
        return (*doit)(window);
    }

    /*
     * move the cursor to its correct position, since usually other
     *  windows will not be affected.
     */
    xygoto(window->ccol, window->cline);

    /*
     * now update all the other windows
     */
    above = below = window;
    above_count = below_count = 0;
    while (above->prev || below->next) {
        if (above->prev) {
            above = above->prev;
            --above_count;
            if (display_window(above, reserved, cursor, above_count)) {
                return (*doit)(window);
            }
        }
        if (below->next) {
            below = below->next;
            ++below_count;
            if (display_window(below, reserved, cursor, below_count)) {
                return (*doit)(window);
            }
        }
    }

    /*
     * all done, so position the cursor and wait for the user to enter
     *  something
     */
    xygoto(window->ccol, window->cline);
    return (*doit)(window);
}

/*
 * Name:    setup_window
 * Purpose: To set the page length and the center line of a window, based
 *           on the top and bottom lines.
 * Date:    October 10, 1989
 * Passed:  window: window to be set up
 */
void setup_window(window)
windows *window;
{
    window->place_line = (window->bottom_line + window->top_line) / 2;
    window->page = window->bottom_line - window->top_line -
            g_status.overlap + 1;
    if (window->page < 1) {
        window->page = 1;
    }
}

/*
 * Name:    first_non_blank
 * Purpose: To find the column in which the first non-blank character in
 *           the string occurs.
 * Date:    October 1, 1989
 * Passed:  s:  the string to search
 * Returns: the first non-blank column
 */
int first_non_blank(s)
char *s;
{
    int count = 0;

    while (*s && *s++ == ' ') {
        ++count;
    }
    return count;
}

/*
 * Name:    page_up
 * Purpose: To move the cursor one page up the window (probably more
 *           intuitive to think of the text being moved down)
 * Date:    October 1, 1989
 * Passed:  window:   information allowing access to the current window
 * Notes:   The cursor line is moved back the required number of lines
 *           towards the start of the file.
 *          If the start of the file is reached, then the movement stops.
 *           In this case, the cursor is placed at the top of the window.
 */
void page_up(window)
windows *window;
{
    int i;        /* count of lines scanned */
    text_ptr p;   /* previous lines */

    un_copy_line(window);
    for (i=0; i < window->page; i++) {
        if ((p = find_prev(window->cursor)) != NULL) {
            window->cursor = p;
        }
        else {
            window->cline = window->top_line;
            break;
        }
    }
}

/*
 * Name:    page_down
 * Purpose: To move the cursor one page down the window (probably more
 *           intuitive to think of the text being moved up)
 * Date:    October 1, 1989
 * Passed:  window:   information allowing access to the current window
 * Notes:   The cursor line is moved forwards the required number of lines
 *           towards the end of the file.
 *          If the end of the file is reached, then the movement stops.
 *           In this case, the cursor is placed at the bottom of the window.
 */
void page_down(window)
windows *window;
{
    int i;          /* count of lines scanned so far */
    text_ptr p;     /* lines below cursor */

    un_copy_line(window);
    for (i=0; i < window->page; i++) {
        if ((p = find_next(window->cursor)) != NULL) {
            window->cursor = p;
        }
        else {
            window->cline = window->bottom_line;
            break;
        }
    }
}

/*
 * Name:    scroll_down
 * Purpose: To make the necessary changes after the user has given the
 *           command to scroll down the screen.
 * Date:    October 1, 1989
 * Passed:  window: information allowing access to the current window
 * Notes:   Normally, we can just delete the top line on the window, and
 *           then move the cursor up one line (so the cursor remains at
 *           the same position in the file).
 *          However, if the cursor was already on the top line of the
 *           window, then the cursor must be moved down a line first.
 */
void scroll_down(window)
windows *window;
{
    text_ptr next;

    if (window->cline == window->top_line) {
        /*
         * Since the cursor must be moved, it is necessary to flush the
         *  current line buffer back into the main text.
         * If the line was not already copied, then this function will
         *  have no effect.
         */
        un_copy_line(window);

        if ((next = find_next(window->cursor)) != NULL) {
            window->cursor = next;
        }
        else {
            return;
        }
        ++window->cline;
    }

    /*
     * Note that in order to scroll the window down the file, we must
     *  scroll the text UP the screen!
     */
    window_scroll_up(window->top_line, window->bottom_line);
    --window->cline;
}

/*
 * Name:    scroll_up
 * Purpose: To make the necessary changes after the user has given the
 *           command to scroll up the screen.
 * Date:    October 1, 1989
 * Passed:  window: information allowing access to the current window
 * Notes:   Normally, we can just insert one line at the top of the window,
 *           and then move the cursor down one line (so the cursor remains at
 *           the same position in the file).
 *          However, if the cursor was already on the bottom line of the
 *           window, then the cursor must be moved up a line first.
 */
void scroll_up(window)
windows *window;
{
    text_ptr prev;

    if (window->cline == window->bottom_line) {
        un_copy_line(window);
        if ((prev = find_prev(window->cursor)) != NULL) {
            window->cursor = prev;
        }
        else {
            return;
        }
        --window->cline;
    }
    window_scroll_down(window->top_line, window->bottom_line);
    ++window->cline;
}

/*
 * Name:    save_file
 * Purpose: To save the current file to disk.
 * Date:    October 1, 1989
 * Passed:  window:   information allowing access to the current window
 *          kind:     whether we are saving the recovery file or not
 * Notes:   The file is first written under a temporary name, and only
 *           once this is successful is the original file removed.
 *          File names may not contain "/", "\" or ":" characters, or
 *           the editor will get confused when creating the temporary
 *           name.
 *          If anything goes wrong, then the modified flag is set.
 *          If the file is saved successfully, then modified flag is
 *           cleared.
 */
void save_file(window, kind)
windows *window;
int kind;
{
    char name[MAX_COLS]; /* name of file to be saved */
    char temp[MAX_COLS]; /* temporary file name */
    int *pmodified;      /* modified flag location */
    int new_file;        /* are we saving a new file? */
    int *pnew_file;      /* location of above */

    /*
     * make sure we are writing the latest version of the current line
     */
    un_copy_line(window);

    /*
     * set up file name and location of various flags depending on
     *  whether we are writing a normal file or a recovery file
     */
    if (kind == SAVE_NORMAL) {
        strcpy(name, window->file_info->file_name);
        pmodified = &(window->file_info->modified);
        pnew_file = &(window->file_info->new_file);
    }
    else {
        if (g_status.recovery[0] == '\0') {
            hw_copy_path(window->file_info->file_name, RECOVERY,
                    g_status.recovery);
        }
        strcpy(name, g_status.recovery);
        pmodified = &(g_status.unsaved);
        new_file = hw_fattrib(g_status.recovery) == ERROR;
        pnew_file = &new_file;
    }

    /*
     * see if there was a file name - if not, then make the user
     *  supply one.
     */
    if (strlen(name) == 0) {
        save_as_file(window);
        return;
    }

    /*
     * It is not safe to simply overwrite the old file, since a system
     *  crash could cause both the old and edited versions to be lost!
     * Hence we write to a temporary file first.
     */
    strcpy(temp, name);
    if (!(*pnew_file)) {
        hw_copy_path(name, "DTXXXXXX", temp);
        mktemp(temp);
    }

    /*
     * save the file
     */
    error(TEMP, "Saving '%s'", name);
    if (hw_save(temp, window->file_info->start_text,
            window->file_info->end_text-1) == ERROR) {
        if (kind == SAVE_NORMAL) {
            error(WARNING, "cannot write to '%s'", temp);
        }
        else {
            error(WARNING, "cannot write recovery file");
            /*
             * if we cannot write to the recovery file, then do not
             *  try to write again for at least the normal interval
             */
            g_status.save_time += g_status.save_interval;
        }
        return;
    }
    *pmodified = FALSE;

    /*
     * If everything went OK, then rename files and remove the original
     */
    if (!(*pmodified)) {
        if (*pnew_file) {
            /*
             * if the file was new, then it is no longer new
             */
            *pnew_file = FALSE;

            if (kind == SAVE_NORMAL && g_status.recovery[0]) {
                /*
                 * if the main file has been saved, then the recovery
                 *  file is redundant
                 */
                hw_unlink(g_status.recovery);
                g_status.recovery[0] = '\0';
            }
            g_status.unsaved = FALSE;
            return;
        }

        /*
         * if the file already existed, then now is the time to remove
         *  the original file and rename the temporary one.
         */
        if (hw_unlink(name) == ERROR) {
            error(WARNING, "error deleting '%s'", name);
            *pmodified = TRUE;
        }
        else {
            if (hw_rename(temp, name) == ERROR) {
                error(WARNING, "error renaming '%s' to '%s'",
                        temp, name);
                *pmodified = TRUE;
            }
            else { /* complete success - now change access modes */
                hw_set_fattrib(name, window->file_info->file_attrib);
                if (kind == SAVE_NORMAL && g_status.recovery[0]) {
                    hw_unlink(g_status.recovery);
                    g_status.recovery[0] = '\0';
                }
                g_status.unsaved = FALSE;
            }
        }
    }
}

/*
 * Name:    save_as_file
 * Purpose: To save the current file to disk, but under a new name.
 * Date:    October 1, 1989
 * Passed:  window:   information allowing access to the current window
 */
void save_as_file(window)
windows *window;
{
    char name[MAX_COLS];   /* new name for file */

    /*
     * make sure we are writing the latest version of the current line
     */
    un_copy_line(window);

    /*
     * read in name, no default
     */
    name[0] = '\0';
    if (get_name("New file name: ", 1, name) != OK) {
        return;
    }

    /*
     * make sure it is OK to overwrite any existing file
     */
    if (hw_fattrib(name) != ERROR) { /* file exists */
        set_prompt("Overwrite existing file? (y/n): ", 1);
        if (display(get_yn, 1) != A_YES) {
            return;
        }
        if (hw_unlink(name) == ERROR) {
            return;
        }
    }

    /*
     * record the new file name
     */
    strcpy(window->file_info->file_name, name);

    /*
     * save the file, maintaining attributes
     */
    error(TEMP, "Saving '%s'", name);
    if (hw_save(name, window->file_info->start_text,
            window->file_info->end_text-1) == ERROR) {
        error(WARNING, "cannot write to '%s'", name);
        return;
    }
    hw_set_fattrib(name, window->file_info->file_attrib);

    /*
     * record that file is saved and not yet modified again
     */
    window->file_info->modified = FALSE;
    if (g_status.recovery[0]) {
        hw_unlink(g_status.recovery);
        g_status.recovery[0] = '\0';
    }
    g_status.unsaved = FALSE;
}

