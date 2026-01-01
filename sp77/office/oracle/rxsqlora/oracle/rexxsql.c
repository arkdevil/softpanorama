/***********************************************************************/
/* rexxsql.c - REXX/SQL for Oracle                                     */
/***********************************************************************/
/*
 * REXX/SQL. A REXX interface to SQL databases.
 * Copyright Impact Systems Pty Ltd, 1994, 1995.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to:
 *
 *    The Free Software Foundation, Inc.
 *    675 Mass Ave,
 *    Cambridge, MA 02139 USA.
 *
 *
 * If you make modifications to this software that you feel increases
 * it usefulness for the rest of the community, please email the
 * changes, enhancements, bug fixes as well as any and all ideas to 
 * address below.
 * This software is going to be maintained and enhanced as deemed
 * necessary by the community.
 *
 * Mark Hessling                     email: M.Hessling@qut.edu.au
 * 36 David Road                     Phone: +61 7 849 7731
 * Holland Park                      
 * QLD 4121
 * Australia
 *
 * Author:	Chris O'Sullivan  Ph (Australia) 015 123414
 *
 *    Purpose:	This module fires up the REXX/SQL version of the REXX
 *		interpreter. All real work is done elsewhere!
 *
 */

#define INCL_RXSHV	/* Shared variable support */
#define INCL_RXFUNC	/* External functions support */

#include "rexxsaa.h"
#include "rexxsql.h"


/* Debugging flags */
extern int run_flags;


/* Program name...passed as arg[0] to main. */
static char *Program=NULL;


/* These are required by the getopt() function */
extern char *optarg;
extern int  optind;



/*-----------------------------------------------------------------------------
 * Returns a pointer to the basename of a file (i.e. to the 1st character past
 * the directory part.
 *----------------------------------------------------------------------------*/
static char *my_basename

#ifdef __STDC__
	(char *filename)
#else
	(filename)
	char  *filename;
#endif
{
    int   len = strlen(filename);
    char  *p=NULL;

    for (p = filename + len - 1; len && !(DIRSEP(*p)); p--, len--)
        ;
    return ++p;
}



#if !defined(DYNAMIC_LIBRARY)

/*-----------------------------------------------------------------------------
 * Print a usage message.
 *----------------------------------------------------------------------------*/
static void usage

#ifdef __STDC__
    (void)
#else
    ()
#endif

{
    (void)fprintf(stderr,
                  "\n\nUsage: %s [-h]\n       %s [-dv] REXX-script-name\n\n",
                  Program, Program);
    exit(BAD_ARGS);
}

/*-----------------------------------------------------------------------------
 * Processing starts here for stand-alone rexxsql executable...
 *----------------------------------------------------------------------------*/
int main

#if __STDC__
    (int argc, char *argv[])
#else
    (argc, argv)
    int   argc;
    char  *argv[];
#endif

{
    int      c=0;
    char     *ScriptName=NULL;
    long     i=0, ArgCount=0;
#if defined(OS2)
    int      rc=0;
#else
    long     rc=0;
#endif
    RXSTRING retstr;
    CHAR retbuf[250];
    RXSTRING *Arg=NULL, *ArgList = (RXSTRING*)NULL;

    /* Get the name of this executable. */
    Program = my_basename(argv[0]);

    /* Get any program options. */
    while ((c = getopt(argc, argv, "dvh?")) != EOF) {
        switch (c) {
            case 'v': run_flags |= MODE_VERBOSE; break;
            case 'd': run_flags |= MODE_DEBUG; break;
            case 'h':
            default : usage();
        }
    }

    /* Ensure that a script has been specified! */
    if (optind >= argc) usage();

    /* Next argument is the name of the REXX script */
    ScriptName = argv[optind++];

    /* Get number of arguments to the REXX script */
    ArgCount = argc - optind;

    /* Build an array of arguments if any. */
    if (ArgCount) {
        if ((ArgList = (RXSTRING*)calloc((size_t)ArgCount, sizeof(RXSTRING)))
                          == (RXSTRING*)NULL) {
            (void)fprintf(stderr, "%s: out of memory\n", Program);
            exit(REXX_FAIL);
        }
        for (Arg = ArgList, i = 0; i < ArgCount; Arg++, i++) {
            Arg->strptr = argv[optind++];
            Arg->strlength = strlen(Arg->strptr);
        }
    }

    /* Initialise the REXX/SQL interface. */
    InitRexxSQL(Program);

    MAKERXSTRING(retstr,retbuf,sizeof(retbuf));
    /*
     * Execute the REXX script. Use RXSUBROUTINE mode so that an array
     * of arguments can be passed to the REXX script. This allows passing
     * strings containing spaces and is much more useful than RXCOMMAND
     * mode which passes a command as a single string!
     */
    RexxStart(ArgCount, ArgList, ScriptName, NULL, DLLNAME, RXSUBROUTINE,
              NULL,
#if defined(OS2)
              (PSHORT)&rc,
#else
              &rc, 
#endif
              (PRXSTRING)&retstr);

    /* Terminate the REXX/SQL interface. */
    (void)TerminateRexxSQL(Program);

    if (ArgList)
       free(ArgList);
    /*
     * Return the exit value from the script. This is useful for UNIX/DOS etc.
     * if the value is kept to 0-success, small positive numbers (say < 100)
     * to indicate errors!
     */


    return (int)rc;
}
#endif
