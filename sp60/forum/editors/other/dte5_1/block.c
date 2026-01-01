/*
 * Written by Douglas Thomson (1989/1990)
 *
 * This source code is released into the public domain.
 */

/*
 * Name:    dte - Doug's Text Editor program - block commands module
 * Purpose: This file contains all the commands than manipulate blocks.
 * File:    block.c
 * Author:  Douglas Thomson
 * System:  this file is intended to be system-independent
 * Date:    October 1, 1989
 */

#ifdef HPXL
#include "commonh"
#include "utilsh"
#include "blockh"
#else
#include "common.h"
#include "utils.h"
#include "block.h"
#endif

/*
 * prototypes for all functions in this file
 */
void set_marker ARGS((windows *window, int n));
void mark_start ARGS((windows *window));
void mark_end ARGS((windows *window));
void prepare_block ARGS((windows *window));
void block_move ARGS((windows *window));
void block_copy ARGS((windows *window));
void block_read ARGS((windows *window, int fixup));
int check_block ARGS((windows *window));
void block_delete ARGS((windows *window));
void block_indent ARGS((windows *window));
void block_unindent ARGS((windows *window));
void block_write ARGS((windows *window));
void block_print ARGS((windows *window));

/*
 * Name:    set_marker
 * Purpose: To record the position of a marker in the file.
 * Date:    October 1, 1989
 * Passed:  window: information required to access current window
 *          n:      the number of the marker to set
 * Notes:   n must be in the range 0..9
 */
void set_marker(window, n)
windows *window;
int n;
{
    int col;    /* cursor column, or end of line, whichever is less */
    int len;    /* length of current line */

    if (g_status.copied) {
        /*
         * current line buffer is active, so set the buffer marker
         */
        if ((col = window->ccol) > (len = linelen(g_status.line_buff))) {
            /*
             * markers can only be placed where there is actually some
             *  text. If the cursor is beyond the end of the line, then
             *  the marker must be set at the end of the line
             */
            col = len;
        }
        g_status.buff_marker[n] = g_status.line_buff + col;
    }
    else {
        /*
         * work directly with main text
         */
        if ((col = window->ccol) > (len = linelen(window->cursor))) {
            col = len;
        }
        window->file_info->marker[n] = window->cursor + col;
    }
}

/*
 * Name:    mark_start
 * Purpose: To record the position of the start of the block in the file.
 * Date:    October 1, 1989
 * Passed:  window: information required to access current window
 * Notes:   This differs slightly from the setting of a normal mark,
 *           in that if we are using the current line buffer, the main
 *           text start marker must be modified also. (This may not
 *           still be necessary?)
 */
void mark_start(window)
windows *window;
{
    int col;    /* cursor column, or end of line, whichever is less */
    int len;    /* length of current line */

    /*
     * if the end of the block has already been marked, then the block
     *  must now become visible
     */
    if (window->file_info->marker[END_BLOCK]) {
        window->file_info->visible = TRUE;
    }

    if (g_status.copied) {
        if ((col = window->ccol) > (len = linelen(g_status.line_buff))) {
            col = len;
        }
        window->file_info->marker[START_BLOCK] = window->cursor;
        g_status.buff_marker[START_BLOCK] = g_status.line_buff + col;
    }
    else {
        if ((col = window->ccol) > (len = linelen(window->cursor))) {
            col = len;
        }
        window->file_info->marker[START_BLOCK] = window->cursor + col;
    }
}

/*
 * Name:    mark_end
 * Purpose: To record the position of the end of the block in the file.
 * Date:    October 1, 1989
 * Passed:  window: information required to access current window
 * Notes:   This differs slightly from the setting of a normal mark,
 *           in that if we are using the current line buffer, the main
 *           text end marker must be modified also.
 */
void mark_end(window)
windows *window;
{
    int col;    /* cursor column, or end of line, whichever is less */
    int len;    /* length of current line */

    if (window->file_info->marker[START_BLOCK]) {
        window->file_info->visible = TRUE;
    }
    if (g_status.copied) {
        if ((col = window->ccol) > (len = linelen(g_status.line_buff))) {
            col = len;
        }
        window->file_info->marker[END_BLOCK] = window->cursor;
        g_status.buff_marker[END_BLOCK] = g_status.line_buff + col;
    }
    else {
        if ((col = window->ccol) > (len = linelen(window->cursor))) {
            col = len;
        }
        window->file_info->marker[END_BLOCK] = window->cursor + col;
    }
}

/*
 * Name:    prepare_block
 * Purpose: To prepare a window/file for a block read, move or copy.
 * Date:    October 10, 1989
 * Passed:  window: information required to access current window
 * Notes:   The main complication is that the cursor may be beyond the end
 *           of the current line, in which case extra padding spaces have
 *           to be added before the block operation can take place.
 */
void prepare_block(window)
windows *window;
{
    text_ptr source;        /* source for block moves */
    text_ptr dest;          /* destination for block moves */
    int pad;                /* amount of padding to be added */
    int len;                /* length (usually of current line) */
    int cr;                 /* does current line end with \n? */
    long number;            /* number of characters for block moves */

    /*
     * if cursor was beyond the end of the actual line, then add
     *  padding first.
     *
     * work on the current line buffer until padding is sorted out.
     */
    copy_line(window);
    if (window->ccol > (len = linelen(g_status.line_buff))) {
        /*
         * work out how much padding is required to extend the current
         *  line to the cursor position
         */
        if (g_status.line_buff[len] == '\n') {
            cr = 1;
        }
        else {
            cr = 0;
        }
        pad = window->ccol - len;

        /*
         * check that there is room in the current line - should never
         *  give any problems...
         */
        if (len + pad + cr >= BUFF_SIZE) {
            error(WARNING, "too far right");
            return;
        }

        /*
         * make room for the padding spaces, and fix the markers
         */
        source = g_status.line_buff + window->ccol - pad;
        dest = source + pad;
        number = len + pad - window->ccol + 1 + cr;
        hw_move(dest, source, number);
        fix_marks(window, source, (long) pad);

        /*
         * insert the padding spaces
         */
        while (pad--) {
            *source++ = ' ';
        }
    }
    un_copy_line(window);

    /*
     * The cursor is now somewhere in the main text block, so there
     *  are no major complications.
     */
}

/*
 * Name:    move_block
 * Purpose: To move the marked block from its current position to the
 *           cursor position.
 * Date:    October 1, 1989
 * Passed:  window: information required to access current window
 */
void block_move(window)
windows *window;
{
    text_ptr source;        /* source for block moves */
    text_ptr dest;          /* destination for block moves */
    long number;            /* number of characters for block moves */
    int len;                /* length (usually of current line) */
    int add;                /* characters being added from another line */
    long block_len;         /* length of the block */
    text_ptr orig;          /* cursor location in text */
    text_ptr block_text;    /* place block is temporarily moved to */
    text_ptr block_dest;    /* place block must finish up in */
    text_ptr fix_pos;       /* origin for marker fixup */

    if (!window->file_info->visible) {
        error(WARNING, "no visible block");
        return;
    }

    /*
     * if cursor was beyond the end of the actual line, then add
     *  padding first
     */
    prepare_block(window);

    /*
     * make sure block is legitimate
     */
    if (window->file_info->marker[END_BLOCK] <=
            window->file_info->marker[START_BLOCK]) {
        error(WARNING, "end before start");
        return;
    }

    /*
     * work out how much has to be moved
     */
    block_len = window->file_info->marker[END_BLOCK] -
            window->file_info->marker[START_BLOCK];

    /*
     * now check that no lines will become too long as a result of
     *  the block move
     *
     * first check that the text on the cursor line up to the cursor, plus
     *  the text on the line the block starts on from the start of the
     *  block to the end of the line, will all fit on one line
     */
    len = linelen(window->cursor);
    add = linelen(window->file_info->marker[START_BLOCK]);
    if (window->file_info->marker[START_BLOCK] + add >
            window->file_info->marker[END_BLOCK]) {
        add = (int) (window->file_info->marker[END_BLOCK] -
                window->file_info->marker[START_BLOCK]);
    }
    if (window->file_info->marker[START_BLOCK][add] == '\n') {
        ++add;
    }
    if (window->ccol + add >= BUFF_SIZE) {
        error(WARNING, "line would be too long");
        return;
    }

    /*
     * next check that the text on the cursor line from the cursor to the
     *  end of the line, plus the text on the line the block ends on from the
     *  start of the line to the end of the block, will all fit on one line
     */
    add = prelinelen(window->file_info->marker[END_BLOCK]);
    if (window->file_info->marker[START_BLOCK] + add >
            window->file_info->marker[END_BLOCK]) {
        /*
         * if the block is smaller than one line, then we only need to worry
         *  about the text actually in the block
         */
        add = (int) (window->file_info->marker[END_BLOCK] -
                window->file_info->marker[START_BLOCK]);
    }
    if (len - window->ccol + add >= BUFF_SIZE) {
        error(WARNING, "line would be too long");
        return;
    }

    /*
     * finally check that the text on the line the block starts on from the
     *  start of the line to the start of the block, plus the text on the line
     *  the block ends on from the end of the block to the end of the line,
     *  will all fit on one line
     */
    add = linelen(window->file_info->marker[END_BLOCK]);
    if (window->file_info->marker[END_BLOCK][add] == '\n') {
        ++add;
    }
    if (prelinelen(window->file_info->marker[START_BLOCK]) + add >=
            BUFF_SIZE) {
        error(WARNING, "line would be too long");
        return;
    }

    /*
     * check that the move is going to have some effect
     */
    orig = window->cursor + window->ccol;
    if (orig >= window->file_info->marker[START_BLOCK] &&
            orig <= window->file_info->marker[END_BLOCK]) {
        /*
         * a block moved to within the block itself has no effect
         */
        return;
    }

    /*
     * check that there is room to copy the block to the end of the
     *  text buffer
     */
    if (g_status.end_mem + block_len >= g_status.max_mem) {
        error(WARNING, "not enough memory for move");
        return;
    }

    /*
     * make copy of block after the end of the main text
     */
    source = window->file_info->marker[START_BLOCK];
    block_text = g_status.end_mem + 1;
    hw_move(block_text, source, block_len);

    /*
     * shift the text between the cursor and the block to make room
     */
    if (orig < window->file_info->marker[START_BLOCK]) {
        source = orig;
        fix_pos = window->file_info->marker[START_BLOCK] + block_len;
        dest = source + block_len;
        block_dest = source;
        number = window->file_info->marker[START_BLOCK] - source;
    }
    else {
        source = window->file_info->marker[END_BLOCK];
        dest = window->file_info->marker[START_BLOCK];
        fix_pos = window->file_info->marker[START_BLOCK];
        block_dest = orig - block_len;
        number = orig - source;
    }
    hw_move(dest, source, number);

    /*
     * if the cursor used to be after the block, it is now before it
     */
    if (window->cursor > window->file_info->marker[END_BLOCK]) {
        window->cursor -= block_len;
    }

    /*
     * move the block back into the gap where it belongs
     */
    hw_move(block_dest, block_text, block_len);

    /*
     * fix up all the affected markers. Note that markers within the
     *  block are not moved with the block, but instead all converge
     *  at where the block used to start. Here is the place to fix this
     *  if it is ever a problem.
     */
    fix_marks(window, orig, block_len);
    fix_marks(window, fix_pos, -block_len);

    /*
     * the marked block is now in a new place
     */
    window->file_info->marker[START_BLOCK] = block_dest;
    window->file_info->marker[END_BLOCK] = block_dest + block_len;
}

/*
 * Name:    copy_block
 * Purpose: To copy the marked block from its current position to the
 *           cursor position.
 * Date:    October 1, 1989
 * Passed:  window: information required to access current window
 * Notes:   This operation is complicated by the fact that the block
 *           may be copied to within itself. An extra copy of the block
 *           is therefore made, just to make life easier for the
 *           programmer!
 */
void block_copy(window)
windows *window;
{
    text_ptr source;        /* source for block moves */
    text_ptr dest;          /* destination for block moves */
    long number;            /* number of characters for block moves */
    int len;                /* length (usually of current line) */
    int add;                /* characters being added from another line */
    long block_len;         /* length of the block */
    text_ptr orig;          /* cursor location in text */
    text_ptr block_text;    /* place block is temporarily moved to */
    text_ptr block_dest;    /* place block must finish up in */

    if (!window->file_info->visible) {
        error(WARNING, "no visible block");
        return;
    }

    /*
     * if cursor was beyond the end of the actual line, then add
     *  padding first
     */
    prepare_block(window);

    if (window->file_info->marker[END_BLOCK] <=
            window->file_info->marker[START_BLOCK]) {
        error(WARNING, "end before start");
        return;
    }

    block_len = window->file_info->marker[END_BLOCK] -
            window->file_info->marker[START_BLOCK];

    /*
     * now check that no lines will become too long as a result of
     *  the block move
     */
    len = linelen(window->cursor);
    add = linelen(window->file_info->marker[START_BLOCK]);
    if (window->file_info->marker[START_BLOCK] + add >
            window->file_info->marker[END_BLOCK]) {
        add = (int) (window->file_info->marker[END_BLOCK] -
                window->file_info->marker[START_BLOCK]);
    }
    if (window->file_info->marker[START_BLOCK][add] == '\n') {
        ++add;
    }
    if (window->ccol + add >= BUFF_SIZE) {
        error(WARNING, "line would be too long");
        return;
    }
    add = prelinelen(window->file_info->marker[END_BLOCK]);
    if (window->file_info->marker[START_BLOCK] + add >
            window->file_info->marker[END_BLOCK]) {
        add = (int) (window->file_info->marker[END_BLOCK] -
                window->file_info->marker[START_BLOCK]);
    }
    if (len - window->ccol + add >= BUFF_SIZE) {
        error(WARNING, "line would be too long");
        return;
    }

    orig = window->cursor + window->ccol;

    /*
     * the block is copied to the end of the file, then all the
     *  text is shifted to make room for the copy of the block,
     *  then the block is moved to its new position. This means we
     *  need room for 2 extra copies of the block in memory.
     */
    if (g_status.end_mem + 2*block_len >= g_status.max_mem) {
        error(WARNING, "not enough memory for copy");
        return;
    }

    /*
     * make copy of block after where text will finally end
     */
    source = window->file_info->marker[START_BLOCK];
    block_text = g_status.end_mem + block_len;
    hw_move(block_text, source, block_len);

    /*
     * move text to make room for block
     */
    source = orig;
    dest = source + block_len;
    block_dest = source;
    number = g_status.end_mem - source;
    hw_move(dest, source, number);

    /*
     * put block in the hole
     */
    hw_move(block_dest, block_text, block_len);

    /*
     * adjust all the marks
     */
    fix_marks(window, orig, block_len);

    /*
     * the block is now somewhere new
     */
    window->file_info->marker[START_BLOCK] = block_dest;
    window->file_info->marker[END_BLOCK] = block_dest + block_len;
}

/*
 * Name:    block_read
 * Purpose: To read a file into the text at the cursor position, marking
 *           this text as the current block. Optionally, tabs may be
 *           expanded and the file checked for printable ASCII characters
 *           only.
 * Date:    October 1, 1989
 * Passed:  window: information required to access current window
 *          fixup:  should we expand tabs etc?
 * Notes:   To make life easier for the programmer, the block is first
 *           read to the end of the text buffer, then moved by its size
 *           so that it will not be overwritten when the main text is
 *           shifted to make room for the block.
 */
void block_read(window, fixup)
windows *window;
int fixup;
{
    text_ptr source;        /* source for block moves */
    text_ptr dest;          /* destination for block moves */
    long number;            /* number of characters for block moves */
    int len;                /* length (usually of current line) */
    int add;                /* characters being added from another line */
    long block_len;         /* length of the block */
    text_ptr orig;          /* cursor location in text */
    text_ptr block_text;    /* place block is temporarily moved to */
    text_ptr block_dest;    /* place block must finish up in */
    char num_str[MAX_COLS]; /* tab interval as a character string */
    int old_tab;            /* previous tab interval */

    /*
     * if cursor was beyond the end of the actual line, then add
     *  padding first
     */
    prepare_block(window);

    /*
     * find out which file to read
     */
    if (get_name("File to read: ", 1, g_status.rw_name) != OK) {
        return;
    }

    /*
     * set up tab interval to use for read
     */
    old_tab = g_status.tab_size;
    if (fixup) {
        for (;;) {
            strcpy(num_str, "8");
            if (get_name("Tab interval: ", 1, num_str) != OK) {
                return;
            }
            g_status.tab_size = atoi(num_str);
            if (g_status.tab_size < MAX_COLS/2) {
                break;
            }
        }
    }

    /*
     * read in the file at the end of the current main text
     */
    block_text = g_status.end_mem;
    if (load_file(g_status.rw_name, fixup) != OK) {
        /*
         * make sure tab interval is restored before aborting
         */
        g_status.tab_size = old_tab;
        return;
    }

    /*
     * now OK to restore original tab interval.
     */
    g_status.tab_size = old_tab;

    /*
     * work out how long the block is
     */
    block_len = g_status.temp_end - block_text;

    /*
     * now check that no lines will become too long as a result of
     *  the block move
     */
    add = linelen(block_text);
    if (block_text[add] == '\n') {
        ++add;
    }
    if (window->ccol + add >= BUFF_SIZE) {
        error(WARNING, "line would be too long");
        return;
    }
    len = linelen(window->cursor);
    add = prelinelen(block_text + block_len);
    if (len - window->ccol + add >= BUFF_SIZE) {
        error(WARNING, "line would be too long");
        return;
    }

    orig = window->cursor + window->ccol;

    /*
     * check there is enough memory for the extra copy of
     *  the block
     */
    if (g_status.end_mem + 2*block_len >= g_status.max_mem) {
        error(WARNING, "not enough memory for read");
        return;
    }

    /*
     * make copy of block after where text will finally end
     */
    source = block_text;
    block_text += block_len;
    hw_move(block_text, source, block_len);

    /*
     * move text to make room for block
     */
    source = orig;
    dest = source + block_len;
    block_dest = source;
    number = g_status.end_mem - source;
    hw_move(dest, source, number);

    /*
     * put block in the hole
     */
    hw_move(block_dest, block_text, block_len);

    /*
     * fix up affected markers
     */
    fix_marks(window, orig, block_len);

    /*
     * the block just read becomes the current block, and is visible
     */
    window->file_info->marker[START_BLOCK] = block_dest;
    window->file_info->marker[END_BLOCK] = block_dest + block_len;
    window->file_info->visible = TRUE;
}

/*
 * Name:    check_block
 * Purpose: To check that the block is visible.
 * Date:    October 1, 1989
 * Passed:  window: information required to access current window
 * Returns: OK if block is visible, ERROR otherwise
 * Notes:   This module reports the error to the user, so there is no
 *           need to do this after an error is returned.
 */
int check_block(window)
windows *window;
{
    if (!window->file_info->visible) {
        error(WARNING, "no visible block");
        return ERROR;
    }

    un_copy_line(window);

    if (window->file_info->marker[END_BLOCK] <
            window->file_info->marker[START_BLOCK]) {
        error(WARNING, "block end before start");
        return ERROR;
    }

    return OK;
}

/*
 * Name:    block_delete
 * Purpose: To delete the currently marked block.
 * Date:    October 1, 1989
 * Passed:  window: information required to access current window
 */
void block_delete(window)
windows *window;
{
    text_ptr source;        /* source for block moves */
    text_ptr dest;          /* destination for block moves */
    long number;            /* number of characters for block moves */
    int len;                /* length (usually of current line) */
    int add;                /* characters being added from another line */
    long block_len;         /* length of the block */
    text_ptr orig;          /* cursor location in text */
    text_ptr next;          /* next line after end of block */

    /*
     * check something there to delete
     */
    if (check_block(window) != OK) {
        return;
    }

    /*
     * work out how much to delete
     */
    block_len = window->file_info->marker[END_BLOCK] -
            window->file_info->marker[START_BLOCK];

    /*
     * work out cursor position in actual text
     */
    if ((len = linelen(window->cursor)) > window->ccol) {
        len = window->ccol;
    }
    orig = window->cursor + len;

    /*
     * now check that no lines will become too long as a result of
     *  the block move
     */
    add = linelen(window->file_info->marker[END_BLOCK]);
    if (window->file_info->marker[END_BLOCK][add] == '\n') {
        ++add;
    }
    if (prelinelen(window->file_info->marker[START_BLOCK]) + add >=
            BUFF_SIZE) {
        error(WARNING, "line would be too long");
        return;
    }

    /*
     * adjust the cursor line
     */
    if (orig <= window->file_info->marker[START_BLOCK]) {
        /*
         * cursor was before the block, so no problems
         */
        ;
    }
    else if ((next = find_next(window->file_info->marker[END_BLOCK])) &&
            orig >= next) {
        /*
         * cursor was after the last line of the block, so merely
         *  adjust by the number of characters deleted
         */
        window->cursor -= block_len;
    }
    else {
        /*
         * complications! The location of the cursor has been
         *  affected by the delete. The cursor line will become
         *  the line the block started on.
         */
        source = window->file_info->marker[START_BLOCK];
        source -= prelinelen(source);
        window->cursor = source;
        if (orig >= window->file_info->marker[END_BLOCK]) {
            /*
             * cursor was on the last line of the block, after the
             *  end of the block. Leave cursor on the same character.
             */
            window->ccol +=
                    prelinelen(window->file_info->marker[START_BLOCK]) -
                    prelinelen(window->file_info->marker[END_BLOCK]);
        }
        else {
            /*
             * the cursor was inside the block. Leave cursor on what
             *  used to be the first character of the block
             */
            window->ccol =
                    prelinelen(window->file_info->marker[START_BLOCK]);
        }
    }

    /*
     * move the text to delete the block
     */
    source = window->file_info->marker[END_BLOCK];
    dest = window->file_info->marker[START_BLOCK];
    number = g_status.end_mem - source;
    hw_move(dest, source, number);

    /*
     * fix affected markers and adjust the total text size
     */
    fix_marks(window, window->file_info->marker[START_BLOCK], -block_len);
}

/*
 * Name:    block_indent
 * Purpose: To indent every line in the current block by the current tab
 *           size.
 * Date:    October 1, 1989
 * Passed:  window: information required to access current window
 */
void block_indent(window)
windows *window;
{
    text_ptr source;        /* source for block moves */
    text_ptr dest;          /* destination for block moves */
    long number;            /* number of characters to be moved */
    text_ptr p;             /* current position within block */
    text_ptr last_p;        /* end of moved block */
    int i;                  /* counter for inserting indent space */
    int increase;           /* total increase for indenting all lines */
    int count;              /* number of chars in current line */
    text_ptr new_cursor;    /* where the cursor line might finish */

    /*
     * check block is OK
     */
    if (check_block(window) != OK) {
        return;
    }

    /*
     * work out how much extra space we need - one indent at
     *  the start of the block, then another after every \n,
     *  except that if the last \n is the last character in
     *  the block, we won't indent the next line.
     */
    increase = g_status.tab_size;
    count = prelinelen(window->file_info->marker[START_BLOCK]);
    for (p=window->file_info->marker[START_BLOCK];
            p < window->file_info->marker[END_BLOCK]; ) {
        if (*p++ == '\n') {
            count = 0;
            if (p < window->file_info->marker[END_BLOCK]) {
                increase += g_status.tab_size;
            }
        }
        if (++count >= BUFF_SIZE - g_status.tab_size) {
            error(WARNING, "line too long");
            return;
        }
    }

    /*
     * move everything from the start of the block down to make
     *  room for inserted characters
     */
    source = window->file_info->marker[START_BLOCK];
    dest = source + increase;
    number = g_status.end_mem - source;
    if (g_status.end_mem + increase >= g_status.max_mem) {
        error(WARNING, "buffer full");
        return;
    }
    hw_move(dest, source, number);

    /*
     * start from the copy of the block, moving text into position, and
     *  keeping track of where the cursor will finish
     *
     * the start of the block is handled as a special case, since it
     *  will not necessarily be the start of a line
     */
    new_cursor = window->cursor + increase;
    if (window->file_info->marker[START_BLOCK] -
            prelinelen(window->file_info->marker[START_BLOCK]) ==
            window->cursor) {
        /*
         * the cursor was on the first line of the block
         */
        new_cursor = source;
        if (window->cursor + window->ccol >=
                window->file_info->marker[START_BLOCK]) {
            window->ccol += g_status.tab_size;
            if (window->ccol >= g_display.ncols) {
                window->ccol = g_display.ncols-1;
            }
        }
    }

    /*
     * note where the block now finishes
     */
    last_p = window->file_info->marker[END_BLOCK] + increase;

    /*
     * markers must be adjusted separately for each line, so that
     *  any markers within the block stay in their correct places
     */
    fix_marks(window, source, (long) g_status.tab_size);

    /*
     * put in the first indent
     */
    for (i=0; i < g_status.tab_size; i++) {
        *source++ = ' ';
    }

    /*
     * now process the rest of the block
     *
     * Note the text is being copied from dest to source! This is rather
     *  confusing, a consequence of the direction of the previous
     *  block move. I should probably have used different variable
     *  names...
     */
    for (;;) {
        if (source >= dest) { /* finished */
            break;
        }
        if (*dest == '\n') {
            /*
             * copy the character itself
             */
            *source++ = *dest++;

            /*
             * keep track of the cursor position if it was inside
             *  the block
             */
            if (dest == new_cursor) {
                new_cursor = source;
                window->ccol += g_status.tab_size;
                if (window->ccol >= g_display.ncols) {
                    window->ccol = g_display.ncols-1;
                }
            }

            /*
             * avoid indenting the line following the end of the
             *  block
             */
            if (dest >= last_p) {
                break;
            }

            /*
             * fix the affected marks and add the indentation
             */
            fix_marks(window, source, (long) g_status.tab_size);
            for (i=0; i < g_status.tab_size; i++) {
                *source++ = ' ';
            }
        }
        else {
            *source++ = *dest++;
        }
    }

    /*
     * update the cursor line if necessary
     */
    if (window->cursor > window->file_info->marker[START_BLOCK]) {
        window->cursor = new_cursor;
    }
}

/*
 * Name:    block_unindent
 * Purpose: To unindent every line in the current block by the current tab
 *           size.
 * Date:    October 1, 1989
 * Passed:  window: information required to access current window
 * Notes:   Each line is first checked to see that it has the required
 *           number of leading blank spaces.
 */
void block_unindent(window)
windows *window;
{
    text_ptr source;        /* source for block moves */
    text_ptr dest;          /* destination for block moves */
    long number;            /* number of characters to be moved */
    text_ptr p;             /* current position within block */
    int i;                  /* counter for removing indent space */
    int decrease;           /* total decrease for unindenting all lines */
    text_ptr new_cursor;    /* where the cursor line might finish */
    text_ptr orig_end_mem;  /* old end of main text (for fixups) */
    text_ptr orig_end_block;/* old end of marked block (for fixups */
    int len;                /* length of current line or tab interval */

    /*
     * check block OK
     */
    if (check_block(window) != OK) {
        return;
    }

    /*
     * save info for fixups later
     */
    orig_end_mem = g_status.end_mem;
    orig_end_block = window->file_info->marker[END_BLOCK];

    /*
     * work out how much space we need to remove - one indent at
     *  the start of the block, then another after every \n,
     *  except that if the last \n is the last character in
     *  the block, we won't unindent that line.
     */
    decrease = 0;
    for (p=window->file_info->marker[START_BLOCK];
            p < window->file_info->marker[END_BLOCK]; ) {
        if (p == window->file_info->marker[START_BLOCK] || *p++ == '\n') {
            if (p < window->file_info->marker[END_BLOCK]) {
                /*
                 * check that the required blank space is available
                 */
                for (i=0; i < g_status.tab_size; i++) {
                    if (p[i] != ' ') {
                        if (p[i] != '\n') {
                            error(WARNING,
                                    "line with too few leading spaces");
                            return;
                        }
                        else {
                            /*
                             * blank lines can be safely unindented
                             */
                            break;
                        }
                    }
                    else {
                        decrease++;
                    }
                }
            }
            if (p == window->file_info->marker[START_BLOCK]) {
                ++p;
            }
        }
    }

    /*
     * fix cursor position if on first line of block
     */
    new_cursor = window->cursor;
    if (window->file_info->marker[START_BLOCK] -
            prelinelen(window->file_info->marker[START_BLOCK]) ==
            window->cursor) {
        if (window->cursor + window->ccol >=
                window->file_info->marker[START_BLOCK]) {
            window->ccol -= g_status.tab_size;
            if (window->ccol <= 0) {
                window->ccol = 0;
            }
        }
    }

    /*
     * move text into new position
     *
     * first line is a special case, since the block will not necessarily
     *  start at the start of a line
     */
    source = dest = window->file_info->marker[START_BLOCK];
    if ((len=linelen(source)) > g_status.tab_size) {
        len = g_status.tab_size;
    }
    fix_marks(window, dest, -(long)len);
    source += len; /* simply ignore spaces */

    /*
     * now process the rest of the lines
     */
    for (;;) {
        if (source >= orig_end_block) {
            break;
        }
        if (*source == '\n') {
            *dest++ = *source++;
            if (source == new_cursor) {
                new_cursor = dest;
                window->ccol -= g_status.tab_size;
                if (window->ccol <= 0) {
                    window->ccol = 0;
                }
            }
            if (source >= orig_end_block) {
                break;
            }
            if ((len=linelen(source)) > g_status.tab_size) {
                len = g_status.tab_size;
            }
            fix_marks(window, dest, -(long)len);
            source += len; /* simply ignore it */
        }
        else {
            *dest++ = *source++;
        }
    }

    /*
     * move everything from the end of the unindented block up to
     *  close the gap
     */
    number = orig_end_mem - source;
    hw_move(dest, source, number);

    /*
     * adjust the cursor position if necessary
     */
    if (window->cursor > window->file_info->marker[START_BLOCK]) {
        if (window->cursor > orig_end_block) {
            window->cursor -= decrease;
        }
        else {
            window->cursor = new_cursor;
        }
    }
}

/*
 * Name:    block_write
 * Purpose: To write the currently marked block to a disk file.
 * Date:    October 1, 1989
 * Passed:  window: information required to access current window
 * Notes:   If the file already exists, the user gets to choose whether
 *           to overwrite or append.
 */
void block_write(window)
windows *window;
{
    /*
     * make sure block is marked OK
     */
    if (check_block(window) != OK) {
        return;
    }

    /*
     * find out which file to write to
     */
    if (get_name("Filename: ", 1, g_status.rw_name) != OK) {
        return;
    }

    /*
     * if the file exists, find out whether to overwrite or append
     */
    if (hw_fattrib(g_status.rw_name) != ERROR) {
        set_prompt("File exists. Overwrite or Append? (o/a): ", 1);
        switch (display(get_oa, 1)) {
        case A_OVERWRITE:
            hw_unlink(g_status.rw_name);
            break;
        case A_APPEND:
            error(TEMP, "appending block to '%s'", g_status.rw_name);
            if (hw_append(g_status.rw_name,
                    window->file_info->marker[START_BLOCK],
                    window->file_info->marker[END_BLOCK]) == ERROR) {
                error(WARNING, "could not append block");
            }
            return;
        default:
            return;
        }
    }

    error(TEMP, "writing block to '%s'", g_status.rw_name);
    if (hw_save(g_status.rw_name,
            window->file_info->marker[START_BLOCK],
            window->file_info->marker[END_BLOCK]) == ERROR) {
        error(WARNING, "could not write block");
    }
}

/*
 * Name:    block_print
 * Purpose: To print the currently marked block.
 * Date:    October 1, 1989
 * Passed:  window: information required to access current window
 */
void block_print(window)
windows *window;
{
    char answer[MAX_COLS];  /* entire file or just marked block? */

    /*
     * print entire file (WordStar) or just marked block (Turbo)?
     */
    for (;;) {
        strcpy(answer, "f");
        if (get_name("Print file or block? (f/b): ", 1, answer) != OK) {
            return;
        }
        answer[0] = tolower(answer[0]);
        if (answer[0] == 'f') {
            hw_print(window->file_info->start_text,
                    window->file_info->end_text-1); /* -1 to avoid \0 */
            return;
        }
        else if (answer[0] == 'b') {
            break;
        }
    }

    /*
     * check block is marked OK
     */
    if (check_block(window) != OK) {
        return;
    }

    /*
     * write it to the printer
     */
    error(TEMP, "Printing block...");
    if (hw_print(window->file_info->marker[START_BLOCK],
            window->file_info->marker[END_BLOCK])) {
        error(WARNING, "could not print block");
    }
}
