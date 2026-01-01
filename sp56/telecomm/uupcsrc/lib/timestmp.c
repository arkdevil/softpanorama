/*
   timestmp.c

   Compiler timestamps for display at program start-up

   History:

      12/13/89 Add Copyright statements - ahd
 */

#include <dos.h>
#include <io.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#ifdef __TURBOC__
#include <dir.h>
#else
#include <direct.h>
#endif

#include "lib.h"
#include "screen.h"

#define UUPCV   "v5.09gamma Changes Copyright (C) 1992 Andrew A. Chernov"

#ifndef UUPCV
#define UUPCV "1.08(experimental)"
#endif

char compiled[] = { __DATE__ } ;
char compilet[] = { __TIME__ } ;
char compilev[] = { UUPCV } ;

char compilep[] = { "UUPC/@" } ;

char program[MAXFILE];
char *calldir;
static char	drv[MAXDRIVE];
static char	dir[MAXDIR];
static char	ext[MAXEXT];

extern int screen;
void banner (char **argv)
{
	  char *cp, dummy[128];

#ifdef __TURBOC__
	  if (  fnsplit(argv[0], drv, dir, program, ext) & FILENAME )
	  {
#else
	  if (!equal(argv[0],"C"))    /* Microsoft C for no prog name? */
	  {
		 _splitpath( argv[0], drv, dir, program, ext );
#endif /* __TURBOC__ */
		 calldir = malloc(strlen(drv) + strlen(dir) + 1);
		 strcpy(calldir, drv);
		 strcat(calldir, dir);
		 sprintf(dummy, "%s: ", program);
		 cp = dummy+strlen(dummy)-1;
	  } /* if */
	  else {
		cp = dummy;
		strcpy(program, "UUNONE");
		calldir = ".";
	  }

	  if (!isatty(fileno(stdin))) /* Is the console I/O redirected?  */
		 return;                 /* Yes --> Run quietly              */


	  sprintf(cp, "%s %s (%2.2s%3.3s%2.2s)",
				  compilep,
				  compilev,
				  &compiled[4],
				  &compiled[0],
				  &compiled[9]);
	 if (screen)
		 Sheader(dummy);
	 else
		 puts(cp);
} /* banner */
