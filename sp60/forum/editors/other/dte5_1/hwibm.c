/*
 * Written by Douglas Thomson (1989/1990)
 *
 * This source code is released into the public domain.
 */

/*
 * Name:    dte - Doug's Text Editor program - hardware dependent module
 * Purpose: This file contains all the code that needs to be different on
 *           different hardware.
 * File:    hwibm.c
 * Author:  Douglas Thomson
 * System:  This particular version is for the IBM PC and close compatibles.
 *           It write directly to video RAM, so it is faster than other
 *           techniques, but will cause "snow" on most CGA cards. See the
 *           file "hwibmcga.c" for a version that avoids snow.
 *          The compiler is Turbo C 2.0, using one of the large data memory
 *           models.
 * Date:    October 10, 1989
 * Notes:   This module has been kept as small as possible, to facilitate
 *           porting between different systems.
 */
#include "common.h"     /* dte types */
#include "hwdep.h"      /* prototypes for functions here */
#include "utils.h"      /* for displaying messages etc */
#include "version.h"    /* current version number */
#include <stdarg.h>     /* for passing variable numbers of arguments */
#include <conio.h>      /* for using putch to output a character */
#include <dos.h>        /* for renaming files */
#include <dir.h>        /* for searching the current path */
#include <bios.h>       /* for direct BIOS keyboard input */
#include <alloc.h>      /* for memory allocation */
#include <io.h>         /* for file attribute code */
#include <fcntl.h>      /* open flags */
#include <process.h>    /* spawn etc */
#include <sys/stat.h>   /* S_IWRITE etc */

/*
 * prototypes for all functions in this file
 */
void error ARGS((int kind, ...));
void main ARGS((int argc, char *argv[]));
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
static int write_file ARGS((char *name, char *mode, text_ptr start,
        text_ptr end));
int hw_save ARGS((char *name, text_ptr start, text_ptr end));
int hw_append ARGS((char *name, text_ptr start, text_ptr end));
int hw_print ARGS((text_ptr start, text_ptr end));
int hw_load ARGS((char *name, text_ptr start, text_ptr limit, text_ptr *end));
void hw_copy_path ARGS((char *old, char *name, char *new));
int hw_os_shell ARGS((void));

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
void error(kind, format)
int kind;
char *format;
{
    va_list argptr;         /* used to access various arguments */
    char buff[MAX_COLS];    /* somewhere to store error before printing */
    int c;                  /* character entered by user to continue */

    /*
     * prepare to process variable arguments
     */
    va_start(argptr, format);

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
 * Name:    harmless
 * Purpose: To process control-break by ignoring it, so that the editor is
 *           not aborted!
 * Date:    February 5, 1990
 */
static int harmless(void)
{
    return 1;   /* ignore */
}


/*
 * original control-break checking flag
 */
static int s_cbrk;

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
    char drive[MAXDRIVE];  /* drive which dte.exe came from */
    char dir[MAXDIR];      /* directory for dte.exe */

    /*
     * trap control-break to make it harmless, and turn checking off
     */
    s_cbrk = getcbrk();
    ctrlbrk(harmless);
    setcbrk(0);

    /*
     * set up help file name. This is a file called dte.hlp, and it should
     *  be in the same directory as the dte.exe program.
     * This information is only available in DOS 3 and later, so we need
     *  to check to see whether argv[0] was OK.
     */
    if (fnsplit(argv[0], drive, dir, NULL, NULL) & DIRECTORY) {
#ifdef GRIB
        fnmerge(g_status.help_file, drive, dir, "dtegrib", ".hlp");
#else
        fnmerge(g_status.help_file, drive, dir, "dte", ".hlp");
#endif
    }
    editor(argc, argv);
}

/*
 * The following defines specify which video attributes give desired
 *  effects on different display devices.
 * REVERSE is supposed to be reverse video - a different background color,
 *  so that even a blank space can be identified.
 * HIGH is supposed to quickly draw the user's eye to the relevant part of
 *  the screen, either for a message or for matched text in find/replace.
 * NORMAL is supposed to be something pleasant to look at for the main
 *  body of the text.
 * These defines may not be optimal for all types of display. Eventually
 *  the user should be allowed to select which attribute is used where.
 */
#define LCD_REVERSE 0x70
#define LCD_NORMAL  0x07
#define LCD_HIGH    0x17

#define HERC_REVERSE 0x70
#define HERC_UNDER   0x01
#define HERC_NORMAL  0x07
#define HERC_HIGH    0x0F

#define COLOR_NORMAL 0x07
#define COLOR_REVERSE 0x17
#define COLOR_HIGH 0x1F

/*
 * Name:    hw_xygoto
 * Purpose: To move the cursor to a new position on the screen.
 * Date:    October 10, 1989
 * Passed:  [g_display.line]: the required line
 *          [g_display.col]:  the required column
 */
void hw_xygoto()
{
    gotoxy(g_display.col+1, g_display.line+1);
}

/*
 * Name:    hw_clreol
 * Purpose: To clear from the cursor to the end of the cursor line.
 * Date:    October 10, 1989
 * Returns: TRUE if the hardware could clear to end of line, FALSE otherwise
 */
int hw_clreol()
{
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
    return TRUE;
}

/*
 * Name:    hw_c_avail
 * Purpose: To test whether or not a character has been typed by the user.
 * Date:    October 10, 1989
 * Returns: TRUE if user typed something, FALSE otherwise
 */
int hw_c_avail()
{
    return bioskey(1);
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
    int key;

    g_screen[0][MAX_COLS-2].c = ((g_display.col+1) / 10) + '0';
    g_screen[0][MAX_COLS-1].c = ((g_display.col+1) % 10) + '0';

    key = bioskey(0);
    if ((key & 0xFF) == 0) {
        /*
         * The user entered a function key. Translate it into the
         *  appropriate command, or ignore.
         */
        if (key == 0x4700) { /* home */
            c_uninput(CONTROL('S'));
            return CONTROL('Q');
        }
        if (key == 0x4800) { /* up arrow */
            return CONTROL('E');
        }
        if (key == 0x4900) { /* page up */
            return CONTROL('R');
        }
        if (key == 0x4b00) { /* left arrow */
            return CONTROL('S');
        }
        if (key == 0x4d00) { /* right arrow */
            return CONTROL('D');
        }
        if (key == 0x4f00) { /* end */
            c_uninput(CONTROL('D'));
            return CONTROL('Q');
        }
        if (key == 0x5000) { /* down arrow */
            return CONTROL('X');
        }
        if (key == 0x5100) { /* page down */
            return CONTROL('C');
        }
        if (key == 0x5200) { /* insert */
            return CONTROL('V');
        }
        if (key == 0x5300) { /* del */
            return CONTROL('G');
        }
        if (key == 0x2d00) { /* AltX */
            c_uninput(CONTROL('X'));
            return CONTROL('K');
        }
        return 0;
    }
    else {
        return key & 0xFF;
    }
}

/*
 * Name:    hw_c_output
 * Purpose: To output a character, using the current attribute, at the
 *           current screen position.
 * Date:    October 10, 1989
 * Notes:   Although we do not need to actually output the character here,
 *           we do need to advance the cursor for the user to see.
 */
void hw_c_output(c)
int c;
{
    gotoxy(g_display.col+2, g_display.line+1);
    return;
}

/*
 * Name:    hw_terminate
 * Purpose: To restore the terminal to a safe state prior to leaving the
 *           editor.
 * Date:    October 10, 1989
 */
void hw_terminate()
{
    gotoxy(g_display.ncols, g_display.nlines);
    textattr(g_display.normal);
    putch(' ');
    printf("dte version %s for IBM PC", VERSION);

    /*
     * restore control-break checking
     */
    setcbrk(s_cbrk);
}

/*
 * Name:    hw_initialize
 * Purpose: To initialize the display ready for editor use.
 * Date:    October 10, 1989
 */
void hw_initialize()
{
    struct text_info buff; /* for discovering display type */
    long space;            /* amount of memory to use */

    /*
     * set up path name for help file
     */
    if (*g_status.help_file == '\0') {
        strcpy(g_status.help_file, searchpath("dte.hlp"));
    }

    /*
     * set up screen size
     */
    g_display.ncols = MAX_COLS;
    g_display.nlines = MAX_LINES;

    /*
     * cursor addressing is very cheap with a memory mapped display!
     */
    g_display.ca_len = 0;

    /*
     * use almost all the available memory for the text buffer, but
     *  reserve some for opening files and windows and shelling to
     *  DOS.
     * If there is plenty of memory available, then try to preserve
     *  command.com as well.
     */
    space = farcoreleft() - 50000L;
    if (space < 100000L) {
        space += 40000L;
    }
    if ((g_status.start_mem = farmalloc(space)) == NULL) {
        error(FATAL, "out of memory???");
    }
    g_status.max_mem = g_status.start_mem + space;

    /*
     * work out what kind of display is in use, and set attributes and
     *  display address accordingly. Note that this will only work with
     *  close IBM compatibles.
     */
    gettextinfo(&buff);
    if (buff.currmode == MONO) {
        g_screen = (screen_lines *) 0xB0000000L;
        g_display.block = HERC_REVERSE;
        g_display.normal = HERC_NORMAL;
        g_display.flash = HERC_HIGH;
        g_display.attr = HERC_NORMAL;
    }
    else {
        g_screen = (screen_lines *) 0xB8000000L;
        if (buff.currmode == BW80) {
            /*
             * There are probably some machines apart from ones with liquid
             *  crystal displays which use BW80 mode, in which case these
             *  attributes may not be appropriate.
             */
            g_display.block = LCD_REVERSE;
            g_display.normal = LCD_NORMAL;
            g_display.flash = LCD_HIGH;
            g_display.attr = LCD_NORMAL;
        }
        else {
            g_display.block = COLOR_REVERSE;
            g_display.normal = COLOR_NORMAL;
            g_display.flash = COLOR_HIGH;
            g_display.attr = COLOR_NORMAL;
        }
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
        error(WARNING, "negative move - contact Douglas Thomson");
    }
    else if (source == dest) {
        /*
         * nothing to be done
         */
        ;
    }
    else if (source > dest) {
        /*
         * Turbo C provides a move that can handle overlapping moves,
         *  but unfortunately it can only move up to 64K-1 bytes.
         * Since I could not move 64K, I have only tried to move 32K.
         */
        while (number > 0x8000L) {
            memmove((char *)dest, (char *)source, 0x8000);
            number -= 0x8000L;
            dest += 0x8000L;
            source += 0x8000L;
        }
        /*
         * now less than 32K is left, so finish off the move
         */
        memmove((char *)dest, (char *)source, (unsigned)number);
    }
    else {
        source += number;
        dest += number;
        while (number > 0x8000L) {
            source -= 0x8000L;
            dest -= 0x8000L;
            number -= 0x8000L;
            memmove((char *)dest, (char *)source, 0x8000);
        }
        source -= number;
        dest -= number;
        memmove((char *)dest, (char *)source, (unsigned)number);
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
    gotoxy(g_display.col, g_display.line+1);
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
    return _chmod(name, 0);
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
    return _chmod(name, 1, attrib);
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
    int result;

    if ((result = _chmod(name, 0)) != -1 && (result & FA_RDONLY) != 0) {
        /*
         * file cannot be written
         */
        set_prompt("File is write protected! Overwrite anyway? (y/n): ", 1);
        if (display(get_yn, 1) != A_YES) {
            return ERROR;
        }
        if (_chmod(name, 1, 0) == ERROR) {
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
   return (c >= 32);
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
 */
int hw_print(start, end)
text_ptr start;
text_ptr end;
{
    return write_file("PRN", "a", start, end);
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

    strcpy(new, old);
    if ((cp = strrchr(new, '/')) != NULL ||
            (cp = strrchr(new, '\\')) != NULL ||
            (cp = strrchr(new, ':')) != NULL) {
        ++cp;
    }
    else {
        cp = new;
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
    static unsigned char ci[MAXPATH];
    static unsigned char dos_prompt[80];
    if (ci[0] == '\0') {
        strcpy(ci, getenv("COMSPEC"));
    }
    if (dos_prompt[0] == '\0') {
        sprintf(dos_prompt, "PROMPT=[DTE] %s", getenv("PROMPT"));
    }
    putenv(dos_prompt);
    spawnl(P_WAIT, ci, ci, 0);
    return TRUE;
}
