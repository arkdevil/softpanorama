/*
 * Mail -- a mail program
 *
 * Auxiliary functions.
 *
 * $Log:	version.c,v $
 * Revision 1.2  93/01/04  02:24:44  ache
 * I decide to put all changes into RCS now
 * 
 * Revision 1.1  92/08/24  02:23:36  ache
 * Initial revision
 * 
 */
/*NOXSTR*/
static char rcsid[] = "$Header: version.c,v 1.2 93/01/04 02:24:44 ache Exp $";
/*YESXSTR*/
int revision = 1, subrevision = 8;

char *os =
#ifdef  M_XENIX
# ifdef  M_I386
	"XENIX/386"
# else
	"XENIX/286"
# endif
#else
# ifdef  ultrix
	"Ultrix"
# else
#  if defined(vax) || defined(pdp11)
	"BSD"
#  else
#   ifdef sun
	"SunOS"
#   else
#    ifdef MSDOS
	"MSDOS"
#    else
#     ifdef ISC
	"INTERACTIVE UNIX"
#     else
#      ifdef SVR4
#       ifdef i386
	"System V R4 (i386)"
#       else
	"System V R4"
#       endif
#      else
#	ifdef __386BSD__
	"386BSD"
#	else     
	"Unix"
#	endif
#      endif
#     endif
#    endif
#   endif
#  endif
# endif
#endif
	;

version()
{
	printf("Mail v%d.%d released for %s 08/22/92 by <ache@astral.msk.su>\n",
		revision, subrevision, os);
	printf("Changes Copyright (C) 1992 Andrew A. Chernov, Moscow\n");
	return 0;
}

