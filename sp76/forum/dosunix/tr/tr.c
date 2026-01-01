/* TR.C  - Translate Characters 
 *
 * Copyright 1985:  Ian Ashdown
 *                  byHeart Software
 *                  1089 West 21st Street
 *                  North Vancouver, B.C. V7P 2C2
 *                  Canada
 *
 * Updates by:      Tom Harris
 *                  932 NW 16th St.
 *                  Oklahoma City, OK 73106
 *                  CIS: 72126,3374
 *
 * Version  1.00    May 5th, 1985
 *          1.01    Feb 16th, 1990  TH
 *          1.10    Feb 10th, 1991  TH
 *          1.11    Oct 12th, 1992  TH
 *          1.12    Nov 13th, 1992  TH
 *
 * This program may be copied for personal, non-commercial use only,
 * provided that the above copyright notice is included in all
 * copies of the source code. Copying for any other use without
 * previously obtaining the written permission of the author is
 * prohibited.
 *
 * USAGE: tr [-cdns] [string_1 [string_2] ]
 */
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <io.h>
#include <stdarg.h>
#include <string.h>

typedef int BOOL;       /* Boolean flag */

#define TRUE    1
#define FALSE   0
#define EOS     '\0'
#define NUL     '\0'

#define BUFFER_SIZE 30720

typedef unsigned char UChr;

/* Error message codes
 */
char *ErrMsg[] = {
#define OPT_USE 0
    "\nUsage: Tr [-cdns] [string_1 [string_2]]\n",
#define OPT_ERR 1
    "option.",
#define CMD_ERR 2
    "command line.",
#define BSL_ERR 3
    "use of '\\' operator.",
#define DSH_ERR 4
    "use of '-' operator."
};

UChr translate[256];            /* Character translation array */

static UChr exp_str(UChr **, UChr *, UChr *, int *);
static UChr literal_sw(UChr **);
static void error(int);
static void cdecl fprnts(FILE *, ...);

/* Main Body Of Program
 */
extern int cdecl main(int argc, char *argv[]) {

    int
        i,                      /* Temporary variable */
        trans,                  /* Translation character */
        curr,                   /* Current input character */
        prev = NUL;             /* Previous input character */

    BOOL
        r_1 = FALSE,            /* String_1 range flag */
        r_2 = FALSE;            /* String_2 range flag */

    UChr
        *str_1,                 /* String_1 pointer */
        *str_2,                 /* String_2 pointer */
        dflt_str = EOS,         /* point here if no string_(1 | 2) arg */

        ch_1,                   /* String_1 character */
        ch_2 = NUL,             /* String_2 character */
        low_1 = NUL,            /* String_1 low range character */
        high_1,                 /* String_1 high range character */
        low_2 = NUL,            /* String_2 low range character */
        high_2,                 /* String_2 low range character */

        Upsi  = '\x00';         /* Option bits */
#define OFLAG   '\x40'          /* Option present */
#define CFLAG   '\x01'          /* Complement option flag */
#define DFLAG   '\x02'          /* Delete option flag */
#define NFLAG   '\x04'          /* NUL translation flag v1.12 */
#define SFLAG   '\x08'          /* Squeeze option flag */

    /* Parse the command line for user-selected options
     */
    while (*(*++argv) == '/' || (**argv == '-')) {  /* v1.01 */
        argc--;
        Upsi |= OFLAG;          /* fix v1.10 */
        while (*++(*argv) != EOS) {
            switch (**argv) {
            case 'C':       /* Complement flag */
            case 'c':
                Upsi &= (OFLAG | NFLAG | SFLAG);
                Upsi |= CFLAG;
                break;
            case 'D':       /* Delete flag */
            case 'd':
                Upsi &= OFLAG;
                Upsi |= DFLAG;
                break;
            case 'N':       /* Allow translation of NUL */
            case 'n':
                Upsi &= (OFLAG | CFLAG | SFLAG);
                Upsi |= NFLAG;
                break;
            case 'S':       /* Squeeze flag */
            case 's':
                Upsi &= (OFLAG | CFLAG | NFLAG);
                Upsi |= SFLAG;
                break;
            case '?':
                error(OPT_USE);
            default:        /* Illegal command line option */
                error(OPT_ERR);
            }
        }
    }
    if (!(!Upsi || (Upsi & DFLAG && argc) || (argc == 3))) {
        error(CMD_ERR);
    }
    if (Upsi & NFLAG)
        if (!(Upsi & CFLAG))
            error(CMD_ERR);

    /* Gather pointers to string_1 and string_2
     * Supply a null string by default - override with
     * address of string from the command line if present
     */
    str_1 = *argv != NULL ? (UChr *)*argv : &dflt_str;  /* v1.01 */
    argv++;
    str_2 = *argv != NULL ? (UChr *)*argv : &dflt_str;  /* v1.01 */

    for (i = 0; i < 256; i++)
            translate[i] = NUL;

    /* Expand the source and translation strings
     */
    if (Upsi & DFLAG) {             /* Delete option selected v1.10 */
         while ((ch_1 = exp_str(&str_1, &low_1, &high_1, &r_1)) != EOS)
            translate[ch_1] = ch_1;
    }       
    else if (!(Upsi & CFLAG)) {     /* Complement option not selected */
        while ((ch_1 = exp_str(&str_1, &low_1, &high_1, &r_1)) != EOS) {
            if ((curr = exp_str(&str_2, &low_2, &high_2, &r_2)) != EOS)
                ch_2 = (UChr) curr;
            translate[ch_1] = ch_2;
        }
        for (i = 1; i < 256; i++)
            if (translate[i] == NUL)
                translate[i] = (UChr) i;
    }
    else {                          /* Complement option selected */
        while ((ch_1 = exp_str(&str_1, &low_1, &high_1, &r_1)) != EOS)
            translate[ch_1] = ch_1;
        ch_2 = exp_str(&str_2, &low_2, &high_2, &r_2);
        for (i = 1; i < 256; i++)
            if (translate[i] == NUL)
                translate[i] = ch_2;
        translate[0] = (UChr)((Upsi & NFLAG) ? ch_2 : NUL);
    }
    setmode(fileno(stdin), O_BINARY);
    setmode(fileno(stdout), O_BINARY);
    setvbuf(stdin, NULL, _IOFBF, BUFFER_SIZE);  /* Big buffers, but */
    setvbuf(stdout, NULL, _IOFBF, BUFFER_SIZE); /* stay in the small model */

    while ((curr = fgetc(stdin)) != EOF) {  /* Process the input */
        trans = translate[curr];
        if (!(Upsi & DFLAG)) {      /* Delete option not selected */
            if (!(Upsi & SFLAG))        /* Squeeze option not selected */
                putc(trans, stdout);
            else {                      /* Squeeze option selected */
                if (curr == trans)
                    putc(trans, stdout);
                else
                    if (trans != prev)
                        putc(trans, stdout);
                prev = trans;
            }
        }
        else {                      /* Delete option selected */
            if (curr != trans)          /* v1.10 */
                putc(curr, stdout);     /* v1/10 */
        }
    }
    return 0;
}

/* EXP_STR
 * Expand a character string. The arguments passed are a pointer to
 * a pointer to a character string ("str"), a pointer to the low
 * value of a character range ("low"), a pointer to the high value
 * of the same range ("high"), and a pointer to a boolean flag
 * ("range") that indicated whether or not the range is currently
 * being expanded. The current character of "str" or of a range
 * implicit in "str" currently being expanded is returned. "exp_str"
 * uses pointer to variables external to the function rather than
 * internal static variables so that the calling function can use
 * more than one set of variables at a time.
 */
static UChr exp_str(UChr **str, UChr *low, UChr *high, BOOL *range) {

    UChr curr;

    if (*range == FALSE) {  /* Not expanding character range */
        switch (curr = *(*str)++) {
        case EOS:           /* End of string - back up pointer */
            (*str)--;
            return EOS;
        case '\\':          /* Must be '\x'-style escape sequence */
            curr = literal_sw(str);
            break;
        case '-':           /* Must be character range */
            if (*low == EOS)
                break;
            *high = *(*str)++;
            if (*high == '-' || *high == EOS)
                error(DSH_ERR);
            if (*high == '\\')
                *high = literal_sw(str);
            *range = TRUE;
            break;
        default:
            break;
        }
        if (*range == FALSE) {  /* Not expanding character range */
            *low = curr;
            return curr;
        }
    }
    curr = ++(*low);      /* Expanding character range */
    if (curr == *high)
        *range = FALSE;
    return curr;
}

/* LITERAL_SW
 *  Convert characters following '\' operator to their equivalents.
 *  The following escape sequences are supported:
 *
 *          \a      alarm                   (BEL)           v1.10
 *          \b      backspace               (BS)
 *          \e      escape                  (ESC)           v1.10
 *          \f      form feed               (FF)
 *          \n      newline                 (LF)
 *          \r      carriage return         (CR)
 *          \t      horizontal tab          (HT)
 *          \z      MS-DOS EOF control Z    (SUB)           v1.10
 *          \ddd    string representation of a constant     v1.11
 *                  with decimal, octal or hexidecimal digits
 *                  \ddd  - decimal
 *                  \0ddd - octal
 *                  \0xdd - hexidecimal
 *          \c      c (where 'c' is anything else)
 *
 *  The equivalent character is returned. If a NUL is passed as the
 *  argument, an error message is generated.
 */
static UChr literal_sw(UChr **buff_ptr) {

    UChr c;             /* Current input character */

    c = **buff_ptr;
    if ('0' <= c && c <= '9') {
        c = ((UChr)(strtoul((char *)*buff_ptr, (char **)buff_ptr, 0) & 0xFF));
        if (**buff_ptr == '*') {
            /* v1.11
             * This allows the use of the '*' as a rear marker in the
             * translate strings to stop strtoul() forcibly when the
             * next character would have allowed it to continue.
             * This, of course, means that if the next character to be 
             * translated is a '*', it will have to be preceeded by a '*'.
             * eg:      str_1       str_2
             *          "\32*1"     "\tA"
             * means    translate constant 32 decimal (space) to tab
             * and      translate character 1 to character A
             *
             * while    "\321"      "\tA"
             * means    translate constant 321 decimal to tab
             *          note \321 will fold to \65, 'A'
             * and      ignore A in str_2
             */
            (*buff_ptr)++;
        }
        return (c);
    }
    switch (c = *(*buff_ptr)++) {
    case 'a':           /* Convert to BEL v1.10 */
        return '\a';
    case 'b':           /* Convert to BS */
        return '\b';
    case 'e':           /* Convert to ESC v1.10 */
        return '\x1B';
    case 'f':           /* Convert to FF */
        return '\f';
    case 'n':           /* Convert to LF */
        return '\n';
    case 'r':           /* Convert to CR */
        return '\r';
    case 't':           /* Convert to HT */
        return '\t';
    case 'z':           /* Convert to SUB v1.10 */
        return '\x1A';
    case NUL:
        error(BSL_ERR);
    default:            /* Must be a literal character */
        return c;
    }
}

/* ERROR
 * Error reporting procedure
 */
static void error(int opt) {

    if (opt)
        fprnts(stderr, "\nTr: Illegal ", ErrMsg[opt], NULL);

    fprnts(stderr, ErrMsg[OPT_USE], NULL);
    exit(opt);
}

/* fprnts
 * putc a variable length list of strings
 */
static void cdecl fprnts(FILE *stream, ...) {

    va_list argp;
    char *p;

    va_start(argp, stream);
    while ((p = va_arg(argp, char *)) != NULL) {
        while ((*p) != EOS) {
            (void)putc(*p, stream);
            p++;
        }
    }
    va_end(argp);
}
