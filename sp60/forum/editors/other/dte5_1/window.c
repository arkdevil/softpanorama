/*
 * Written by Douglas Thomson (1989/1990)
 *
 * This source code is released into the public domain.
 */

/*
 * Name:    dte - Doug's Text Editor program - window module
 * Purpose: This file contains the code associated with opening and sizing
 *           windows, and also displaying the help window.
 * File:    window.c
 * Author:  Douglas Thomson
 * System:  this file is intended to be system-independent
 * Date:    October 12, 1989
 */

#ifdef HPXL
#include "commonh"
#include "utilsh"
#include "windowh"
#else
#include "common.h"
#include "utils.h"
#include "window.h"
#endif

/*
 * prototypes for all functions in this file
 */
int open_window ARGS((windows *window, char *name));
void new_window ARGS((char *auto_name, windows *window));
void choose_window ARGS((char *name, windows *window));
void size_window ARGS((windows *window));
void get_help ARGS((windows *window));
void finish ARGS((windows *window));
int create_window ARGS((windows *prev, int top, int bottom, text_ptr cursor,
        file_infos *file));
int create_file ARGS((file_infos *prev));

/*
 * Name:    open_window
 * Purpose: To open a new window, and load a file into it.
 * Date:    October 10, 1989
 * Passed:  window:   information allowing access to the current window
 *          name:     name of file to read
 * Returns: OK if window opened successfully
 *          ERROR if anything went wrong
 * Notes:   If window is NULL, then this is the first window, and should
 *           take up the entire screen.
 *          If window is not NULL, then the new window should start on the
 *           line below the cursor line of the current window, and continue
 *           down to what used to be the bottom of the current window. If
 *           this does not make enough room for the new window, then an
 *           error is reported, and no new window is created.
 */
int open_window(window, name)
windows *window;
char *name;
{
    int existing;       /* did the file already exist? */
    file_infos *file;   /* file structure for file belonging to new window */
    int ccol;           /* cursor column in new window */
    text_ptr cursor;    /* start of cursor line in new window */
    windows *wp;        /* used for scanning windows for same file name */
    int file_attrib;    /* rwx bits for new file */

    if (window) {
        /*
         * check that there is room for the window (no need if this is the
         *  first window)
         */
        if (window->bottom_line - window->cline < 2 ||
                g_display.nlines-3 - window->cline < 2) {
            error(WARNING, "move cursor up first");
            return ERROR;
        }
    }

    /*
     * look for a window whose file has the same name. Check the
     *  current window (if any) first.
     * If there is already a window open on the same file, then the
     *  new window can share the existing file structure, and the new
     *  window's cursor should be placed in the same spot in the file.
     */
    if (window && strcmp(name, window->file_info->file_name) == 0) {
        file = window->file_info;
        existing = TRUE;
        cursor = window->cursor;
        ccol = window->ccol;

        /*
         * One line is taken by the status line, and the cursor line
         *  is duplicated. All the other lines can be kept.
         */
        window_scroll_down(window->cline+1, window->bottom_line);
        window_scroll_down(window->cline+2, window->bottom_line);
    }
    else {
        /*
         * Not same file as current window, so try other windows
         */
        file = NULL;
        for (wp=g_status.window_list; wp; wp = wp->next) {
            if (strcmp(name, wp->file_info->file_name) == 0) {
                file = wp->file_info;
                break;
            }
        }
        if (file) {
            /*
             * file was already open somewhere
             */
            existing = TRUE;
            cursor = wp->cursor;
            ccol = wp->ccol;
        }
        else {
            /*
             * file was not open, so see if it exists on disk
             */
            file_attrib = hw_fattrib(name);
            existing = file_attrib != ERROR;
            if (existing) {
                if (load_file(name, FALSE) != OK) {
                    /*
                     * The file existed, but was not a plain text file
                     *  or we ran out of memory. In any case, give up
                     *  on the new window.
                     */
                    return ERROR;
                }
            }
            else {
                /*
                 * make sure this gets set properly even if there is no file!
                 */
                g_status.temp_end = g_status.end_mem;
            }

            /*
             * allocate a file structure for the new file
             */
            if (create_file(window ? window->file_info : NULL) == ERROR) {
                error(WARNING, "out of memory");
                return ERROR;
            }
            file = window ? window->file_info->next : g_status.file_list;

            /*
             * set up all the info we need to know about a file, and
             *  record that we have used some more memory.
             */
            strcpy(file->file_name, name);
            file->file_attrib = file_attrib;
            cursor = g_status.end_mem;
            ccol = 0;
            file->start_text = g_status.end_mem;
            *g_status.temp_end = '\0';
            g_status.end_mem = g_status.temp_end + 1;
            file->end_text = g_status.end_mem;

            /*
             * file has not been modified yet
             */
            g_status.unsaved = FALSE;
        }
    }

    /*
     * Now that we have the file, allocate a window to view the file
     */
    if (create_window(window, window ? window->cline+1 : 0,
            window ? window->bottom_line : g_display.nlines-1, cursor,
            file) == ERROR) {
        error(WARNING, "out of memory");

        /*
         * This is a real nuisance. We had room for the file and the
         *  file structure, but not enough for the window as well.
         * Now we must free all the memory that has already been
         *  allocated.
         */
        if (file->ref_count == 0) {
            if (file->prev) {
                file->prev->next = file->next;
            }
            else {
                g_status.file_list = file->next;
            }
            if (file->next) {
                file->next->prev = file->prev;
            }
            g_status.end_mem = file->start_text;
            free(file);
        }
        return ERROR;
    }

    if (window) {
        /*
         * record that the current window has lost some lines from
         *  the bottom for the new window, and adjust its page size
         *  etc accordingly.
         */
        window->bottom_line = window->cline;
        setup_window(window);

        /*
         * we have now finished with the old window, and can concentrate
         *  on the new one.
         */
        window = window->next;
    }
    else {
        window = g_status.window_list;
    }

    /*
     * tell the user if a new file has been created, in case this was not
     *  intentional.
     * Eventually, the user should be given a chance to change the name
     *  of the file and try again.
     */
    if (!existing) {
        error(DIAG, "'%s' is a new file", name);
        file->new_file = TRUE;
    }

    /*
     * set up the new cursor position as appropriate
     */
    window->cursor = cursor;
    window->ccol = ccol;

    /*
     * the new window becomes the current window.
     */
    g_status.current_window = window;
    return OK;
}

/*
 * Name:    new_window
 * Purpose: To open a new window, and ask the user which file to load into it.
 * Date:    October 10, 1989
 * Passed:  auto_name: name of file (NULL if we should prompt the user)
 *          window:    information allowing access to the current window
 */
void new_window(auto_name, window)
char *auto_name;
windows *window;
{
    char name[MAX_COLS];

    /*
     * check that there is room for the window
     */
    if (window->bottom_line - window->cline < 2 ||
            g_display.nlines-3 - window->cline < 2) {
        error(WARNING, "move cursor up first");
        return;
    }

    /*
     * get the name of the file
     */
    if (auto_name) {
        strcpy(name, auto_name);
    }
    else {
        strcpy(name, window->file_info->file_name);
        if (get_name("File to edit: ", 1, name) == ERROR) {
            return;
        }
    }

    open_window(window, name);
}

/*
 * Name:    choose_window
 * Purpose: To select either an existing window or a new one.
 * Date:    October 10, 1989
 * Passed:  name:     name of file (NULL normally)
 *          window:   information allowing access to the current window
 * Notes:   If "name" is not NULL, then the named file will be opened
 *           in a new window.
 *          If the user enters the word "new" (the default), then a new
 *           window will be created.
 *          If the user enters a number, then the relevant window will
 *           become the new current window.
 *          Windows are numbered starting with the current window as 0.
 *           Windows above have negative numbers, and windows below have
 *           positive numbers.
 */
void choose_window(name, window)
char *name;
windows *window;
{
    char number[MAX_COLS];  /* window selected by user */
    int count;              /* existing window number */

    un_copy_line(window);

    /*
     * if the file in this window has been modified, then ask the user
     *  if it should be saved. This may be important, since the recovery
     *  file will contain the file for the new window, meaning that there
     *  would be no way to recover changes made in the old window.
     */
    if (window->file_info->modified) {
        sprintf(number, "Save '%s' first? (y/n): ",
                window->file_info->file_name);
        set_prompt(number, 1);
        switch (display(get_yn, 1)) {
        case A_YES:
            save_file(window, SAVE_NORMAL);
            break;
        case A_NO:
            g_status.unsaved = FALSE;
            if (g_status.recovery[0]) {
                hw_unlink(g_status.recovery);
                g_status.recovery[0] = '\0';
            }
            break;
        default:
            return;
        }
    }

    /*
     * If the name was already specified, then go ahead and open it. This
     *  is used for help windows.
     */
    if (name) {
        new_window(name, window);
        return;
    }

    /*
     * get the desired destination. The default is to create a new
     *  window
     */
    strcpy(number, "new");
    if (get_name("Window number or new: ", 1, number) == ERROR) {
        return;
    }

    if (strcmp(number, "new") == 0) {
        /*
         * user wanted to create a new window
         */
        new_window(NULL, window);
    }
    else {
        /*
         * user wanted to switch to an existing window
         */
        if (strcmp(number, "+") == 0) {
            count = 1;
        }
        else if (strcmp(number, "-") == 0) {
            count = -1;
        }
        else {
            count = atoi(number);
        }

        /*
         * follow pointers until required window is located (or we run
         *  out of windows)
         */
        if (count < 0) {
            while (count++ < 0 && window) {
                window = window->prev;
            }
        }
        else {
            while (count-- > 0 && window) {
                window = window->next;
            }
        }

        /*
         * record a new current window, or report an error if the window
         *  did not exist
         */
        if (window) {
            g_status.current_window = window;
        }
        else {
            error(WARNING, "no such window");
        }
    }
}

/*
 * Name:    size_window
 * Purpose: To change the size of the current and one other window.
 * Date:    October 10, 1989
 * Passed:  window:   information allowing access to the current window
 * Notes:   The cursor line will become the bottom line of the window,
 *           and the window below will grow. (If the current window is
 *           the bottom window, the cursor line will become the top line,
 *           and the window above will grow.)
 */
void size_window(window)
windows *window;
{
    /*
     * try to give more lines to the window below
     */
    if (window->next) {
        window->next->top_line = window->cline+2;
        window->bottom_line = window->cline;
        setup_window(window->next);
    }
    else {
        /*
         * This is the bottom window, so cursor line becomes the new
         *  top of the window
         */
        if (window->prev) {
            window->prev->bottom_line = window->cline-2;
            window->top_line = window->cline;
            setup_window(window->prev);
        }
    }
    setup_window(window);
}

/*
 * Name:    get_help
 * Purpose: To read in the help file, and display it for the user to read
 *           and scroll through.
 * Date:    October 1, 1989
 * Passed:  window: information allowing access to the current window
 * Notes:   The help file is read into a normal window (it can even be
 *           edited, although most users will not be able to save the
 *           edited version!)
 */
void get_help(window)
windows *window;
{
    /*
     * don't risk destroying current line
     */
    un_copy_line(window);

    /*
     * If file exists, then load it
     */
    if (hw_fattrib(g_status.help_file) == ERROR) {
        error(DIAG, "sorry, no help file available");
        return;
    }

    /*
     * open new window for help
     */
    choose_window(g_status.help_file, window);
}

/*
 * Name:    finish
 * Purpose: To remove the current window, and terminate the program if no
 *           more windows are left.
 * Date:    October 1, 1989
 * Passed:  window: information allowing access to the current window
 * Notes:   If more windows are left, then the lines from this window
 *           are inherited by the window above (if any, otherwise the
 *           window below).
 *          If no other window referred to the same file, then the space
 *           taken by the file must be freed.
 */
void finish(window)
windows *window;
{
    windows *wp;        /* for scanning other windows */
    file_infos *file;   /* for scanning other files */
    long number;        /* number of bytes removed / copied */

    un_copy_line(window);

    /*
     * remove old window from list
     */
    if (window->prev == NULL) {
        if (window->next == NULL) {
            terminate();
            exit(0);
        }
        g_status.window_list = window->next;
    }
    else {
        window->prev->next = window->next;
    }
    if (window->next) {
        window->next->prev = window->prev;
    }

    /*
     * give lines to adjacent window (preferably above)
     */
    if (window->prev)  {
        wp = window->prev;
        wp->bottom_line = window->bottom_line;
    }
    else {
        wp = window->next;
        wp->top_line = window->top_line;
    }

    /*
     * fix up things like page size and center line
     */
    setup_window(wp);

    /*
     * The window above (or possibly below) becomes the new current
     *  window.
     */
    g_status.current_window = wp;

    /*
     * free unused file memory if necessary
     */
    if (--window->file_info->ref_count == 0) {
        /*
         * no window now refers to this file, so remove file from the list
         */
        file = window->file_info;
        if (file->prev == NULL) {
            g_status.file_list = file->next;
        }
        else {
            file->prev->next = file->next;
        }
        if (file->next) {
            file->next->prev = file->prev;
        }

        /*
         * close up the gap in the memory buffer
         */
        number = g_status.end_mem - file->end_text;
        hw_move(file->start_text, file->end_text, number);
        number = file->end_text - file->start_text;
        fix_marks(window, file->start_text, -number);

        /*
         * free the memory taken by the file structure
         */
        free(window->file_info);
    }

    /*
     * free the memory taken by the window structure
     */
    free(window);
}

/*
 * Name:    create_window
 * Purpose: To allocate space for a new window structure, and set up some
 *           of the relevant fields.
 * Date:    October 10, 1989
 * Passed:  prev:   the previous window (or NULL)
 *          top:    the top line of the new window
 *          bottom: the bottom line of the new window
 *          cursor: the cursor position for the new window
 *          file:   the file structure to be associated with the new window
 * Returns: OK if window could be created
 *          ERROR if out of memory
 */
int create_window(prev, top, bottom, cursor, file)
windows *prev;
int top;
int bottom;
text_ptr cursor;
file_infos *file;
{
    windows *window;  /* the new window structure */

    /*
     * allocate space for new window structure
     */
    if ((window = (windows *)calloc(1, sizeof(windows))) == NULL) {
        error(WARNING, "out of memory for window");
        return ERROR;
    }

    /*
     * set up appropriate fields
     */
    window->file_info = file;
    window->top_line = top+1;
    window->bottom_line = bottom;
    window->cline = top+1;
    setup_window(window);
    window->cursor = cursor;

    /*
     * add window into window list
     */
    window->prev = prev;
    if (prev) {
        if (prev->next) {
            prev->next->prev = window;
        }
        window->next = prev->next;
        prev->next = window;
    }
    else {
        g_status.window_list = window;
    }

    /*
     * record that another window is referencing this file
     */
    ++file->ref_count;
    return OK;
}

/*
 * Name:    create_file
 * Purpose: To allocate space for a new file structure, and set up some
 *           of the relevant fields.
 * Date:    October 10, 1989
 * Passed:  prev:   the previous file (or NULL)
 * Returns: OK if file structure could be created
 *          ERROR if out of memory
 */
int create_file(prev)
file_infos *prev;
{
    file_infos *file;

    if ((file = (file_infos *)calloc(1, sizeof(file_infos))) == NULL) {
        error(WARNING, "out of memory for file info");
        return ERROR;
    }

    /*
     * add file into list
     */
    file->prev = prev;
    if (prev) {
        if (prev->next) {
            prev->next->prev = file;
        }
        file->next = prev->next;
        prev->next = file;
    }
    else {
        g_status.file_list = file;
    }

    return OK;
}

