#include <stdio.h>
#include <string.h>

/* Copyright (C) 1989 Brian B. McGuinness
                      15 Kevin Road
                      Scotch Plains, NJ 07076

This function is free software; you can redistribute it and/or modify it under 
the terms of the GNU General Public License as published by the Free Software 
Foundation; either version 1, or (at your option) any later version.

This function is distributed in the hope that it will be useful, but WITHOUT 
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more 
details.

You should have received a copy of the GNU General Public License along with 
this function; if not, write to the Free Software Foundation, Inc., 675 Mass 
Ave, Cambridge, MA 02139, USA. */

/*----------------------------------------------------------------------------*/
/* nexttok() - Return a pointer to the next cmd line token to be processed    */
/*                                                                            */
/* argc    = pointer to command line argument count                           */
/* argv    = pointer to command line argument array                           */
/* inpflag = pointer to current input status flag:                            */
/*             zero if we're returning tokens from the command line,          */
/*             nonzero if we're reading tokens from standard input            */
/*             This value should be preserved between calls to this routine.  */
/*                                                                            */
/* Normally, inpflag is zero the first time this routine is called, so we     */
/* begin by returning tokens from the command line.  When the token "@" is    */
/* found on the command line, we start reading tokens from standard input.    */
/* This continues until we encounter EOF, at which time we resume taking      */
/* tokens from the command line.  Occurrances of the "@" token in the         */
/* standard input stream are ignored.                                         */
/*                                                                            */
/* When we reach the end of the command line, we return NULL.                 */
/*----------------------------------------------------------------------------*/

char *nexttok (int *argc, char ***argv, int *inpflag) {

#define BUFLEN 128
static char buffer[BUFLEN]="";
static char *cp=buffer;

while (1) {     /* Keep trying until we find a token or finish the cmd line */

  /* IF WE'RE HANDLING '@' THEN TRY TO GET NEXT TOKEN FROM STANDARD INPUT */
  if (*inpflag) {
    if (cp == NULL || !*cp) {   /* Need to read new line of input */
      if (NULL == fgets (buffer, BUFLEN, stdin)) {
        *inpflag = 0;           /* EOF: resume scanning command line */
        continue;
      }
      cp=strtok (buffer, " ,;\t\n\r");
    }
    else cp=strtok (NULL, " ,;\t\n\r");
    if (cp == NULL) continue;           /* No tokens left on this input line */
    if (!strcmp (cp, "@")) continue;    /* Ignore '@' flag in input */
    return cp;                          /* Found a token!  Return it */
  }

  /* OTHERWISE, GET NEXT TOKEN FROM THE COMMAND LINE */
  else {
    if (!--*argc) return (char *) NULL; /* No more tokens to process */
    if (!strcmp (*(++*argv),"@")) {     /* Check for '@' std input flag */
      *inpflag = 1;
      continue;
    }
    return **argv;                      /* Return next cmd line token */
  }
}
} /* end nexttok() */
