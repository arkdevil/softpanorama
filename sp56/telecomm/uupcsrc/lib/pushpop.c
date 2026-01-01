/*--------------------------------------------------------------------*/
/*    p u s h p o p . c                                               */
/*                                                                    */
/*    Directory functions for UUPC/extended                           */
/*--------------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <direct.h>
#include <sys/types.h>

#include "lib.h"
#include "pushpop.h"

#define MAXDEPTH 10

static char *dirstack[MAXDEPTH];
static depth = 0;

currentfile();

/*--------------------------------------------------------------------*/
/*            Change to a directory and push on our stack             */
/*--------------------------------------------------------------------*/

void PushDir( char *directory )
{
   if ( depth >= MAXDEPTH ) 
	panic();
#ifdef __TURBOC__
   dirstack[depth] = getcwd( NULL , FILENAME_MAX );
#else
   dirstack[depth] = _getdcwd( 0, NULL , FILENAME_MAX );
#endif
   if (dirstack[depth] == NULL ) {
		printerr("PushDir", "getcwd");
		panic();
   }
   if (CHDIR( directory )) {
	printerr("PushDir", directory);
	panic();
   }
   depth++;
   return;
} /* PushDir */

/*--------------------------------------------------------------------*/
/*               Return to a directory saved by PushDir               */
/*--------------------------------------------------------------------*/

void PopDir( void )
{
   if ( depth <= 0 )
	panic();
   if (CHDIR( dirstack[--depth] )) {
	printerr("PopDir", dirstack[depth]);
	panic();
   }
   free( dirstack[depth] );
} /* PopDir */
