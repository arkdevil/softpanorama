/*
 * Written by Douglas Thomson (1989/1990)
 *
 * This source code is released into the public domain.
 */

/*
 * Name:    dte - Doug's Text Editor program - find/replace module
 * Purpose: This file contains the functions relating to finding text
 *           and replacing text.
 *          It also contains the code for moving the cursor to various
 *           other positions in the file.
 * File:    findrep.c
 * Author:  Douglas Thomson
 * System:  this file is intended to be system-independent
 * Date:    October 1, 1989
 */

#ifdef HPXL
#include "commonh"
#include "findreph"
#include "utilsh"
#else
#include "common.h"
#include "findrep.h"
#include "utils.h"
#endif

/*
 * prototypes for all functions in this file
 */
int set_flags ARGS((char *flag_str, int *flags, int *count));
int get_flags ARGS((int lines));
int mystrcmp ARGS((char *s1, char *s2));
int mystrcmpi ARGS((char *s1, char *s2));
void on_screen ARGS((windows *window, text_ptr cursor, int last));
void do_replace ARGS((windows *window, text_ptr start));
void do_last ARGS((windows *window));
void find_string ARGS((windows *window));
void replace_string ARGS((windows *window));
void goto_prep ARGS((windows *window));
void goto_complete ARGS((windows *window, text_ptr cursor));
void goto_marker ARGS((windows *window, int n));
void goto_top_file ARGS((windows *window));
void goto_end_file ARGS((windows *window));
text_ptr scan_forward ARGS((text_ptr start, char *opp, char *target));
text_ptr scan_backward ARGS((text_ptr start, char *opp, char *target));
void match_pair ARGS((windows *window, int forward));
void goto_line ARGS((windows *window));

/*
 * find and replace flags
 */
#define F_BACKWARD 0x01 /* search backwards through file */
#define F_GLOBAL   0x02 /* search entire file */
#define F_LOCAL    0x04 /* search only marked block */
#define F_AUTO     0x08 /* behave as if user always answered yes */
#define F_IGNORE   0x10 /* ignore case differences */
#define F_WORD     0x20 /* match whole words only */
#define F_MATCH    0x40 /* match the case of the text being replaced */

/*
 * Name:    set_flags
 * Purpose: To set up find and replace flags.
 * Date:    October 1, 1989
 * Passed:  flag_str:   the flags chosen by the user
 * Returns: flags:      the equivalent binary flags
 *          count:      the repeat count embedded in the flags
 *          TRUE if flags were OK, FALSE otherwise
 */
int set_flags(flag_str, flags, count)
char *flag_str;
int *flags;
int *count;
{
    char *p;    /* used to scan through flag_str for flags */

    /*
     * start with no flags set, then add those chosen
     */
    *flags = 0;

    /*
     * assume just a single find / replace required
     */
    *count = 1;

    /*
     * scan flag_str to work out which flags were chosen
     */
    for (p=flag_str; *p; ++p) {
        if (isdigit(*p)) {
            /*
             * extract an embedded repeat count
             */
            *count = atoi(p);
            while (isdigit(*++p)) {
                ;
            }
            --p;
            if (*count <= 0) {
                error(WARNING, "bad repeat count: %d", *count);
                *count = 1;
                return FALSE;
            }
        }
        else if ((*p = toupper(*p)) == 'B') {
            *flags |= F_BACKWARD;
        }
        else if (*p == 'G') {
            *flags |= F_GLOBAL;
            *count = GLOB_COUNT;
        }
        else if (*p == 'L') {
            *flags |= F_LOCAL;
            *count = GLOB_COUNT;
        }
        else if (*p == 'N') {
            *flags |= F_AUTO;
        }
        else if (*p == 'U') {
            *flags |= F_IGNORE;
        }
        else if (*p == 'W') {
            *flags |= F_WORD;
        }
        else if (*p == 'M') {
            *flags |= F_MATCH;
        }
        else {
            error(WARNING, "unknown flag: %c", *p);
            return FALSE;
        }
    }
    return TRUE;
}

/*
 * Name:    get_flags
 * Purpose: To input find and replace flags.
 * Date:    October 1, 1989
 * Passed:  lines:  no. of lines up from bottom of screen
 * Returns: [g_status.flags]:        binary flags set
 *          [g_status.flag_str]:     flags as character string
 *          [g_status.search_count]: repeat find count
 *          OK if flags were entered, ERROR if user wanted to abort
 */
int get_flags(lines)
int lines;
{
    char flag_str[MAX_COLS]; /* temporary copy of g_status.flag_str */
    int flags;               /* temporary copy of g_status.flags */
    int count;               /* temporary copy of g_status.count */

    /*
     * use the previous flags as the default
     */
    strcpy(flag_str, g_status.flag_str);

    /*
     * keep on asking for flags until something acceptable is entered
     */
    for (;;) {
        if (get_name("Options (B,G,L,M,N,n,U,W): ", lines, flag_str) !=
                OK) {
            return ERROR;
        }
        if (set_flags(flag_str, &flags, &count)) {
            break;
        }
    }

    g_status.flags = flags;
    g_status.search_count = count;
    strcpy(g_status.flag_str, flag_str);
    return OK;
}

/*
 * Name:    mystrcmp
 * Purpose: To compare two strings up to the length of the first.
 * Date:    October 1, 1989
 * Passed:  s1: first string to compare
 *          s2: second string to compare
 * Returns: 0 if strings match
 *          <0 if s1 < s2
 *          >0 if s1 > s2
 */
int mystrcmp(s1, s2)
char *s1;
char *s2;
{
    for(;;) {
        if (*s1 == '\0') {
            return 0;
        }
        if (*s1 != *s2) {
            return *s1 - *s2;
        }
        ++s1;
        ++s2;
    }
}

/*
 * Name:    mystrcmpi
 * Purpose: To compare two strings up to the length of the first, ignoring
 *           case.
 * Date:    October 1, 1989
 * Passed:  s1: first string to compare
 *          s2: second string to compare
 * Returns: 0 if strings match
 *          <0 if s1 < s2
 *          >0 if s1 > s2
 */
int mystrcmpi(s1, s2)
char *s1;
char *s2;
{
    for(;;) {
        if (*s1 == '\0') {
            return 0;
        }
        if (tolower(*s1) != tolower(*s2)) {
            return tolower(*s1) - tolower(*s2);
        }
        ++s1;
        ++s2;
    }
}

/*
 * Name:    on_screen
 * Purpose: To move the cursor to a new position, without redrawing the
 *           window unless the new position is off the window.
 * Date:    October 1, 1989
 * Passed:  window: information allowing access to current window etc
 *          cursor: the new target position in the text
 *          last:   the last line considered to be on the screen (this
 *                   only affects the bottom window)
 */
void on_screen(window, cursor, last)
windows *window;
text_ptr cursor;
int last;
{
    text_ptr p;  /* used to scan from current cursor towards new one */
    int line;    /* used to count screen line */

    /*
     * if this is the bottom window displayed, then some lines at the
     *  bottom may need to be reserved for messages.
     * Otherwise, the last line available is simply the bottom line used
     *  for the window.
     */
    last = min(g_display.nlines-last-1, window->bottom_line);

    line = window->cline;
    if (window->cursor >= cursor) {
        /*
         * new cursor position is above old one
         */
        for (p=window->cursor; ; p--) {
            if (*p == '\n') {
                --line;
            }
            if (line < window->top_line) {
                /*
                 * off top of screen, so place in middle of display
                 */
                window->cline = window->place_line;

                /*
                 * now check that we are not wasting the top part of the
                 *  screen
                 */
                line = window->cline;
                for (p=cursor; ; p--) {
                    if (*p == '\n') {
                        --line;
                    }
                    if (*p == '\0') {
                        window->cline -= line - window->top_line;
                        break;
                    }
                    if (line < window->top_line) {
                        break;
                    }
                }
                break;
            }
            if (p <= cursor) {
                /*
                 * position found on screen
                 */
                window->cline = line;
                break;
            }
        }
    }
    else {
        /*
         * new cursor position is below current one
         */
        for (p=window->cursor; ; p++) {
            if (*p == '\n') {
                ++line;
            }
            if (line > last) {
                /*
                 * off bottom of screen or window
                 */
                window->cline = window->place_line;

                /*
                 * now check that we are not wasting the bottom part of the
                 *  screen
                 */
                line = window->cline;
                for (p=cursor; ; p++) {
                    if (*p == '\n') {
                        ++line;
                    }
                    if (*p == '\0') {
                        window->cline += last - line;
                        break;
                    }
                    if (line > last) {
                        break;
                    }
                }
                break;
            }
            if (p >= cursor) {
                window->cline = line;
                break;
            }
        }
    }
    window->cursor = cursor;
}

/*
 * Name:    do_replace
 * Purpose: To replace text once match has been found.
 * Date:    October 1, 1989
 * Passed:  window: information allowing access to current window etc
 *          start:  location of start of matched text
 */
void do_replace(window, start)
windows *window;
text_ptr start;
{
    int old_len;             /* length of original text */
    int new_len;             /* length of replacement text */
    text_ptr source;         /* source of block move */
    text_ptr dest;           /* destination of block move */
    long number;             /* number of characters moved */
    char new_text[MAX_COLS]; /* replacement text (case matched) */

    old_len = strlen(g_status.pattern);
    new_len = strlen(g_status.subst);

    /*
     * unless case is to be matched, the replacement text is exactly
     *  what the user entered
     */
    strcpy(new_text, g_status.subst);

    if (g_status.flags & F_MATCH) {
        /*
         * change case of new text to match old
         */
        for (dest=new_text, source=start; *dest; ++dest) {
            if (isupper(*source)) {
                *dest = toupper(*dest);
            }
            else if (islower(*source)) {
                *dest = tolower(*dest);
            }

            /*
             * if the replacement is longer than the original text, then
             *  keep on matching the case of the last character of the
             *  original text
             */
            if (++source >= start + old_len) {
                --source;
            }
        }
    }

    /*
     * move the text to either make room for the extra replacement text
     *  or to close up the gap left
     */
    source = start + old_len;
    dest = start + new_len;
    number = g_status.end_mem - source;
    hw_move(dest, source, number);

    /*
     * insert the replacement text
     */
    for (dest=start, source=new_text; *source; ) {
        *dest++ = *source++;
    }

    /*
     * fix up any affected marks
     */
    fix_marks(window, start, -(long)old_len);
    fix_marks(window, start, (long) new_len);
}

/*
 * Name:    do_last
 * Purpose: To repeat the previous find or replace operation.
 * Date:    October 1, 1989
 * Passed:  window: information allowing access to current window etc
 * Notes:   This function performs a very simple-minded and inefficient
 *           text matching algorithm. When I have more time, I might try
 *           replacing this with something like the Boyer-Moore string
 *           pattern matching algorithm...
 */
void do_last(window)
windows *window;
{
    int len;                /* length of current line */
    int count;              /* number of matches still to be made */
    text_ptr start;         /* start of area to be searched */
    text_ptr end;           /* end of area to be searched */
    text_ptr orig;          /* original cursor location in text */
    text_ptr cursor;        /* where cursor line would be if stopped now */
    text_ptr final_cursor;  /* where cursor should be placed at end */
    char *pattern;          /* pattern to be searched for */
    int pat_len;            /* length of pattern */
    int rep_len;            /* length of replacement text */
    int result;             /* find/replace this one? */
    int backwards;          /* searching backwards? */
    cmp_func cmp;           /* string comparison function in use */

    un_copy_line(window);

    if (strlen(g_status.pattern) == 0) {
        error(WARNING, "nothing to search for");
        return;
    }

    /*
     * save current cursor position as previous
     */
    len = linelen(window->cursor) - 1;
    if (window->ccol < len) {
        len = window->ccol;
    }
    orig = window->cursor + len;
    window->file_info->marker[PREVIOUS] = orig;

    /*
     * work out where to start and end searching
     */
    backwards = g_status.flags & F_BACKWARD;
    pattern = g_status.pattern;
    pat_len = strlen(pattern);
    rep_len = strlen(g_status.subst);
    if (g_status.flags & F_GLOBAL) {
        if (backwards) {
            end = window->file_info->start_text;
            start = window->file_info->end_text-1 - pat_len;
            cursor = start - prelinelen(start);
        }
        else {
            cursor = start = window->file_info->start_text;
            end = window->file_info->end_text-1 - pat_len;
        }
    }
    else if (g_status.flags & F_LOCAL) {
        if (!window->file_info->visible ||
                window->file_info->marker[START_BLOCK] >=
                window->file_info->marker[END_BLOCK]) {
            error(WARNING, "no block to search");
            return;
        }
        if (backwards) {
            end = window->file_info->marker[START_BLOCK];
            start = window->file_info->marker[END_BLOCK] - pat_len;
            cursor = window->file_info->marker[END_BLOCK] -
                    prelinelen(window->file_info->marker[END_BLOCK]);
        }
        else {
            start = window->file_info->marker[START_BLOCK];
            end = window->file_info->marker[END_BLOCK] - pat_len;
            cursor = window->file_info->marker[START_BLOCK] -
                    prelinelen(window->file_info->marker[START_BLOCK]);
        }
    }
    else {
        if (backwards) {
            end = window->file_info->start_text;
            start = orig - pat_len;
        }
        else {
            start = orig + 1;
            end = window->file_info->end_text-1 - pat_len;
        }
        cursor = window->cursor;
    }

    /*
     * work out how to compare
     */
    if (g_status.flags & (F_IGNORE | F_MATCH)) {
        cmp = mystrcmpi;
    }
    else {
        cmp = mystrcmp;
    }

    /*
     * find the required number of matches
     */
    count = g_status.search_count;
    while (count > 0) {
        /*
         * check if finished searching
         */
        if (backwards) {
            if (start < end) {
                break;
            }
        }
        else {
            if (start > end) {
                break;
            }
        }

        /*
         * keep track of where cursor line may start
         */
        if (*start == '\n') {
            cursor = start+1;
        }

        /*
         * try for match
         */
        if ((*cmp)(pattern, (char *)start) == 0) {
            if (!(g_status.flags & F_WORD) ||
                    !(myisalnum(*(start-1)) || myisalnum(*(start+pat_len)))
                    ) {
                /*
                 * we have a valid match
                 */
                --count;

                /*
                 * position the cursor to show the user
                 */
                if (backwards) {
                    /*
                     * since we have not got to the \n yet, we must
                     *  scan backwards until we find it, so that we
                     *  can display the screen properly.
                     */
                    cursor = start - prelinelen(start);
                }
                window->ccol = (int) (start - cursor);
                if (window->ccol >= g_display.ncols) {
                    window->ccol = g_display.ncols-1;
                }

                /*
                 * since this might be the last match, remember the
                 *  spot so that the cursor can be left there at the
                 *  end
                 */
                final_cursor = cursor;

                if (g_status.flags & F_AUTO) {
                    if (g_status.replace) {
                        /*
                         * replace the string
                         */
                        do_replace(window, start);
                        if (!backwards) {
                            /*
                             * replace may have changed the position of the
                             *  end of the search
                             */
                            end += rep_len - pat_len;

                            /*
                             * don't risk recursive replace!
                             */
                            start += rep_len - 1;
                            /*
                             * this fixes a problem with a replacement
                             *  containing the pattern combined with
                             *  multiple ^L replaces...
                             */
                            window->ccol = (int) (start - cursor);
                            if (window->ccol >= g_display.ncols) {
                                window->ccol = g_display.ncols-1;
                            }
                        }
                    }
                }
                else {
                    /*
                     * see if it is on the current screen, and if so
                     *  adjust cursor line accordingly; otherwise
                     *  place in center of screen
                     */
                    on_screen(window, cursor, 1);

                    /*
                     * if necessary, ask the user if this replacement
                     *  should be made, or if this is the desired
                     *  occurrence for find
                     */
                    if (g_status.replace || count > 0) {
                        /*
                         * arrange for matched text to be highlighted
                         */
                        g_status.match_start = start;
                        g_status.match_end = start + pat_len;

                        /*
                         * find out what to do
                         */
                        set_prompt("this one? (y/n/a/q): ", 1);
                        result = display(get_ynaq, 1);

                        /*
                         * remove highlighting
                         */
                        g_status.match_start = g_status.match_end;

                        /*
                         * do whatever is required
                         */
                        switch (result) {
                        case A_ABORT:
                        case A_QUIT:
                            return;
                        case A_ALWAYS:
                            /*
                             * switch to automatic mode
                             */
                            g_status.flags |= F_AUTO;
                            if (!g_status.replace) {
                                break;
                            }

                            /*
                             * if replacing, then fall through to
                             *  replace this one before moving on to
                             *  the rest of them
                             */
                        case A_YES:
                            if (g_status.replace) {
                                /*
                                 * replace the string
                                 */
                                do_replace(window, start);
                                if (!backwards) {
                                    /*
                                     * see comments above
                                     */
                                    end += rep_len - pat_len;
                                    start += rep_len - 1;
                                    window->ccol = (int) (start - cursor);
                                    if (window->ccol >= g_display.ncols) {
                                        window->ccol = g_display.ncols-1;
                                    }
                                }
                            }
                            else {
                                /*
                                 * found desired occurrence
                                 */
                                return;
                            }
                            break;
                        case A_NO:
                            /*
                             * keep looking
                             */
                            break;
                        }
                    }
                }
            }
        }
        /*
         * try again starting one character nearer the end
         */
        if (backwards) {
            --start;
        }
        else {
            ++start;
        }
    }

    /*
     * report no matches if necessary
     */
    if (count == g_status.search_count) {
        error(WARNING, "no match");
    }
    else {
        /*
         * leave the cursor on the final match
         */
        on_screen(window, final_cursor, 1);
    }
}

/*
 * Name:    find_string
 * Purpose: To set up and perform a find operation.
 * Date:    October 1, 1989
 * Passed:  window: information allowing access to current window etc
 */
void find_string(window)
windows *window;
{
    char pattern[MAX_COLS];  /* text to be found */

    /*
     * get replacement text, using previous as default
     */
    strcpy(pattern, g_status.pattern);
    if (get_name("String to find: ", 1, pattern) != OK) {
        return;
    }
    strcpy(g_status.pattern, pattern);

    /*
     * get find options to use
     */
    if (get_flags(2) != OK) {
        return;
    }

    /*
     * record that this is a find operation
     */
    g_status.replace = FALSE;

    /*
     * pretend we are repeating the previous find
     */
    do_last(window);
}

/*
 * Name:    replace_string
 * Purpose: To set up and perform a replace operation.
 * Date:    October 1, 1989
 * Passed:  window: information allowing access to current window etc
 */
void replace_string(window)
windows *window;
{
    char pattern[MAX_COLS];  /* the old and replacement text */

    /*
     * get the old text, using the previous as the default
     */
    strcpy(pattern, g_status.pattern);
    if (get_name("String to find: ", 1, pattern) != OK) {
        return;
    }
    strcpy(g_status.pattern, pattern);

    /*
     * get the replacement text, using the previous as the default
     */
    strcpy(pattern, g_status.subst);
    if (get_name("Replacement:    ", 2, pattern) != OK) {
        return;
    }
    strcpy(g_status.subst, pattern);

    /*
     * get the replace flags
     */
    if (get_flags(3) != OK) {
        return;
    }

    /*
     * record that this is a replace operation
     */
    g_status.replace = TRUE;

    /*
     * go away and do the replace
     */
    do_last(window);
}

/*
 * Name:    goto_prep
 * Purpose: To get ready to perform a goto operation, mainly by recording
 *           the current position as previous.
 * Date:    October 1, 1989
 * Passed:  window: information allowing access to current window etc
 */
void goto_prep(window)
windows *window;
{
    int len;  /* length of cursor line */

    /*
     * make sure there is no confusion with the line buffer
     */
    un_copy_line(window);

    /*
     * set the previous marker to the cursor position
     */
    len = linelen(window->cursor);
    if (window->ccol < len) {
        len = window->ccol;
    }
    window->file_info->marker[PREVIOUS] = window->cursor + len;
}

/*
 * Name:    goto_complete
 * Purpose: To clean up after a goto operation, mainly by making sure the
 *           cursor is nicely positioned on the screen.
 * Date:    October 1, 1989
 * Passed:  window: information allowing access to current window etc
 *          cursor: final destination in file buffer
 */
void goto_complete(window, cursor)
windows *window;
text_ptr cursor;
{
    on_screen(window, cursor - prelinelen(cursor), 0);
    window->ccol = prelinelen(cursor);
    if (window->ccol >= g_display.ncols) {
        window->ccol = g_display.ncols-1;
    }
}

/*
 * Name:    goto_marker
 * Purpose: To move the cursor to a particular position marker.
 * Date:    October 1, 1989
 * Passed:  window: information allowing access to current window etc
 *          n:      the position marker to be used
 * Notes:   n must be in the range 0 .. 9
 */
void goto_marker(window, n)
windows *window;
int n;
{
    text_ptr cursor;  /* desired cursor position */

    un_copy_line(window);
    cursor = window->file_info->marker[n];
    if (cursor) {
        goto_prep(window);
        goto_complete(window, cursor);
    }
    else {
        error(WARNING, "no marker set");
    }
}

/*
 * Name:    goto_top_file
 * Purpose: To move the cursor to the top of the file.
 * Date:    October 1, 1989
 * Passed:  window: information allowing access to current window etc
 */
void goto_top_file(window)
windows *window;
{
    goto_prep(window);
    goto_complete(window, window->file_info->start_text);
}

/*
 * Name:    goto_end_file
 * Purpose: To move the cursor to the end of the file.
 * Date:    October 1, 1989
 * Passed:  window: information allowing access to current window etc
 */
void goto_end_file(window)
windows *window;
{
    if (window->file_info->end_text > window->file_info->start_text) {
        goto_prep(window);
        goto_complete(window, window->file_info->end_text-1); /* -1 for \0
                                                            at end of text */
    }
}

/*
 * Name:    scan_forward
 * Purpose: To find the corresponding occurrence of target, ignoring
 *           embedded pairs of opp and target, searching forwards.
 * Date:    October 1, 1989
 * Passed:  start:  position of character to be paired
 *          opp:    the opposite to target, if any
 *          target: the string to be found
 * Returns: the location of the corresponding target in the text buffer
 */
text_ptr scan_forward(start, opp, target)
text_ptr start;
char *opp;
char *target;
{
    int count = 0;  /* number of unmatched opposites found */

    while (*++start) {
        if (opp && mystrcmpi(opp, (char *) start) == 0) {
            count++;
        }
        else if (mystrcmpi(target, (char *) start) == 0) {
            if (count == 0) {
                break;
            }
            --count;
        }
    }
    return start;
}

/*
 * Name:    scan_backward
 * Purpose: To find the corresponding occurrence of target, ignoring
 *           embedded pairs of opp and target, searching backwards.
 * Date:    October 1, 1989
 * Passed:  start:  position of character to be paired
 *          opp:    the opposite to target, if any
 *          target: the string to be found
 * Returns: the location of the corresponding target in the text buffer
 */
text_ptr scan_backward(start, opp, target)
text_ptr start;
char *opp;
char *target;
{
    int count = 0;  /* number of unmatched opposites found */

    while (*--start) {
        if (opp && mystrcmpi(opp, (char *) start) == 0) {
            count++;
        }
        else if (mystrcmpi(target, (char *) start) == 0) {
            if (count == 0) {
                break;
            }
            --count;
        }
    }
    return start;
}

/*
 * Name:    match_pair
 * Purpose: To find the corresponding pair to the character under the
 *           cursor.
 * Date:    October 1, 1989
 * Passed:  window:     information allowing access to current window etc
 *          forward:    the user would prefer to move forwards?
 * Notes:   If the cursor character differs from its pair, then the search
 *           direction is chosen automatically, regardless of what the
 *           user requested.
 *          The direction only affects single and double quotes.
 *          Searching is very simple-minded, and does not cope with things
 *           like brackets embedded within quoted strings.
 */
void match_pair(window, forward)
windows *window;
int forward;
{
    text_ptr orig;  /* cursor location in text */

    /*
     * make sure the character under the cursor is one that has a
     *  matched pair
     */
    un_copy_line(window);
    if (window->ccol >= linelen(window->cursor)) {
        return;
    }
    orig = window->cursor + window->ccol;
    if (strchr("[]{}()\"\'/\*bBeE", *orig) == NULL) {
        return;
    }
    if (*orig == '/' && *(orig+1) != '*') {
        return;
    }
    if (*orig == '*' && *(orig+1) != '/') {
        return;
    }
    if (*orig == 'b' || *orig == 'B') {
        if (mystrcmpi("begin", (char *) orig) != 0) {
            return;
        }
    }
    if (*orig == 'e' || *orig == 'E') {
        if (mystrcmpi("end", (char *) orig) != 0) {
            return;
        }
    }

    /*
     * record the cursor position as previous
     */
    goto_prep(window);

    /*
     * find the matching pair
     */
    switch (tolower(*orig)) {
    case '[':
        orig = scan_forward(orig, "[", "]");
        break;
    case '(':
        orig = scan_forward(orig, "(", ")");
        break;
    case '{':
        orig = scan_forward(orig, "{", "}");
        break;
    case 'b':
        orig = scan_forward(orig, "begin", "end");
        break;
    case ']':
        orig = scan_backward(orig, "]", "[");
        break;
    case ')':
        orig = scan_backward(orig, ")", "(");
        break;
    case '}':
        orig = scan_backward(orig, "}", "{");
        break;
    case 'e':
        orig = scan_backward(orig, "end", "begin");
        break;
    case '"':
        if (forward) {
            orig = scan_forward(orig, NULL, "\"");
        }
        else {
            orig = scan_backward(orig, NULL, "\"");
        }
        break;
    case '\'':
        if (forward) {
            orig = scan_forward(orig, NULL, "\'");
        }
        else {
            orig = scan_backward(orig, NULL, "\'");
        }
        break;
    case '/':
        orig = scan_forward(orig, NULL, "*\/");
        break;
    case '*':
        orig = scan_backward(orig, NULL, "/\*");
        break;
    }

    /*
     * searching backward may leave us on the leading \0
     */
    if (orig < window->file_info->start_text) {
        orig = window->file_info->start_text;
    }

    /*
     * now show the user what we have found
     */
    goto_complete(window, orig);
}

/*
 * Name:    goto_line
 * Purpose: To move the cursor to a particular line in the file
 * Date:    October 1, 1989
 * Passed:  window: information allowing access to current window etc
 * Notes:   Counting lines from the start of the file buffer is not
 *           very efficient...
 */
void goto_line(window)
windows *window;
{
    int number;             /* line number selected */
    int i;                  /* lines passed so far */
    char num_str[MAX_COLS]; /* line number as string */
    text_ptr p;             /* used to scan through file counting lines */

    /*
     * find out where we are going
     */
    strcpy(num_str, "");
    if (get_name("Line number: ", 1, num_str) != OK) {
        return;
    }
    number = atoi(num_str);

    /*
     * start from the start of the file, and count lines until we
     *  get there.
     */
    un_copy_line(window);
    p = window->file_info->start_text;
    for (i=1; i < number; i++) {
        p = find_next(p);
        if (p == NULL) {
            error(WARNING, "only %d lines in file", i);
            return;
        }
    }

    /*
     * found the line, now note the previous position and show the user.
     */
    goto_prep(window);
    goto_complete(window, p);
}
