
/*  K**2 subroutine library.    */

/*  Functions included:
abbrev      Test for a valid abbreviation.
initv       Initialize an integer vector.
procarg     Process an argument from command line.
showsynt    Display the correct syntax for a command.
*/

#include <stdio.h>
#include <ctype.h>
#include "cmdutil.h"

/*  ABBREV - Test for a valid abbreviation */

abbrev (text, pattern)
    char * text;        /* Text to test */
    char * pattern;     /* Pattern to match it against; lowercase
                    letters are optional */
    {
    while (*pattern != '\0') {
        if (islower (*pattern)) {   /* Optional character */
            if (tolower (*text) == *pattern++
             && abbrev (text + 1, pattern))
                return (TRUE);
            }
        else {              /* Required character */
            if (toupper (*text++) != *pattern++)
                return (FALSE);
            }
        }
    return (*text == '\0');
    }

/*  Process an argument from command line   */

int procarg (argc, argv, optable, info) 
    int * argc;         /* Argument count */
    char * * * argv;        /* Argument vector */
    struct option * optable;    /* Option list */
    char * * * info;        /* Returned information */
    {
    int optno;      /* Option number */
        char * argtext;     /* Argument text */
    int parmno;     /* Parameter counter for multi-value
                   options. */
    
    argtext = *(*argv)++;       /* Pick up an argument */
    --*argc;

    if (!_isopt (argtext)) {
        *info = argtext;    /* String, not an option */
        return (-1);
        }

    for (optno = 0; optable -> opt_text != EOF; ++optno, ++optable)
        if (abbrev (argtext + 1, optable -> opt_text)) break;
                /* Search for optable entry */

    if (optable -> opt_text == EOF) {
        fprintf (stderr, "\n-%s: unknown option.", argtext);
        *info = argtext;
        return (-2);        /* Unrecognized option */
        }

    switch (optable -> opt_type) {
        case NAKED_KWD:
        *info = 0;
        return (optno);
        case NVAL_KWD:
        case SVAL_KWD:
        case MNVL_KWD:
        case MSVL_KWD:
        if (*argc == 0 || _isopt (**argv)) {
            fprintf (stderr, "\n-%s option requires a value.", 
                optable -> opt_text);
            *info = argtext;
            return (-2);
            }
        break;
        default:
        fprintf (stderr, "\nBug: optable badly constructed.");
        exit ();
        }

    switch (optable -> opt_type) {
        case SVAL_KWD:
        *info = *(*argv)++; /* Pick up next arg string */
        --*argc;
            return (optno);
        case NVAL_KWD:
        *info = atoi (*(*argv)++);
        --*argc;
        return (optno);
        default:
        *info = sbrk (*argc + *argc + 2);
        break;
        }

    for (parmno = 0; 
        *argc && !_isopt (argtext = **argv);
        --*argc, ++*argv, ++parmno) {

        if (optable -> opt_type == MSVL_KWD) {
            (*info) [parmno + 1] = argtext;
            }
        else {
            (*info) [parmno + 1] = atoi (argtext);
            }
        }
    (*info) [0] = parmno;
    return (optno);
    }

/* Test if a string is a command option */

int _isopt (s)
    char * s;
    {
    return (*s++ == '-' && isalpha (*s));
    }

/* Display command syntax */

showsyntax (command, optable)
    char * command;
    struct option * optable;
    {
    static char * opstr [6] = {
        "", "<s>", "<n>", "<s> <s>...", "<n> <n>...", EOF };

    fprintf (stderr, "\nSyntax: %s", command);

    if (optable -> opt_text == EOF) return;

    fprintf (stderr, " <options>\nOptions:");

    while (optable -> opt_text != EOF) {

        fprintf (stderr, "\n\t-%s %s", optable -> opt_text,
            opstr [optable -> opt_type]);
        ++optable;

        }
    }
