/*--------------------------------------------------------------------*/
/*    r e a d d i r . c                                               */
/*                                                                    */
/*    Reads a spooling directory with optional pattern matching       */
/*                                                                    */
/*    Copyright 1991 (C), Andrew H. Derbyshire                        */
/*--------------------------------------------------------------------*/

/*--------------------------------------------------------------------*/
/*                        System include files                        */
/*--------------------------------------------------------------------*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

/*--------------------------------------------------------------------*/
/*                    UUPC/extended include files                     */
/*--------------------------------------------------------------------*/

#include "lib.h"
#include "readdir.h"
#include "ndir.h"
#include "hlib.h"

currentfile();

/*--------------------------------------------------------------------*/
/*    x r e a d d i r                                                 */
/*                                                                    */
/*    Read a directory into a linked list                             */
/*--------------------------------------------------------------------*/

char       *xreaddir(char *xname,
          const char *remote,
          const char *subdir,
           char *pattern )
{
   static char *saveremote  = "";
   static char remotedir[FILENAME_MAX];
   static struct file_queue *first_link = NULL;
   struct file_queue *save_link;

   if ((remote == NULL) || !equal( remote, saveremote ))
   {
      DIR *dirp;
      struct direct *dp;

      saveremote = "";

      while ( first_link != NULL )  /* Any files queued up?          */
      {
         save_link = first_link;
         free(first_link);         /* Yes --> Drop it gracefully     */
         first_link = save_link;
      }

	  if ( remote == NULL )      /* Clean up only, no new search? */
         return NULL;            /* Yes --> Return to caller      */

/*--------------------------------------------------------------------*/
/*           We're all clean; now examine the new directory           */
/*--------------------------------------------------------------------*/

	  mkfilename(remotedir, remote, subdir);

	  if (pattern == NULL )
		 pattern = "*.*";

	  if ((dirp = opendirx(remotedir,pattern)) == nil(DIR))
	  {
		 printmsg(2, "xreaddir: couldn't opendir() %s", remotedir);
		 return nil(char);
	  }

	  saveremote = (char *) remote;
							  /* Flag we have an active search going */
	  printmsg(5, "xreaddir: \"%s\"", remotedir);

/*--------------------------------------------------------------------*/
/*      We have files in the directory; load up the linked list       */
/*--------------------------------------------------------------------*/

	  while ((dp = readdir(dirp)) != nil(struct direct))
	  {
		 struct file_queue *current_link = malloc( sizeof( *current_link ));

		 checkref( current_link );
		 current_link->next_link = NULL;
		 sprintf(current_link->name, "%.8s\\%s\\%s",
			remote, subdir, dp->d_name);
		 printmsg(6, "xreaddir: queuing \"%s\"", current_link->name );
         if ( first_link == NULL )
            first_link = current_link;
         else
            save_link->next_link = current_link;
         save_link = current_link;
      } /* while */

      closedir(dirp);
   } /* if */
   else
	  printmsg(5, "xreaddir: next file in \"%s\"", remotedir);

/*--------------------------------------------------------------------*/
/*         Now return a file (or the full list) to the caller         */
/*--------------------------------------------------------------------*/

   if ( first_link == NULL )
   {
	  saveremote = "";
	  printmsg(5, "xreaddir: not matched");
	  return nil(char);
   }
   else if (xname == NULL)    /* Do they want the full list?         */
   {                          /* Yes --> Return it                   */
      save_link = first_link;
      first_link = NULL;      /* We will not free the list           */
      saveremote = "";
	  printmsg(5, "xreaddir: returning entire list");
	  return (char *) save_link;
   }
   else {
	  save_link = first_link->next_link;
	  strcpy( xname , first_link->name );
	  free( first_link );
	  first_link = save_link;
	  printmsg(5, "xreaddir: matched %s",xname );
	  return xname;
   } /* else */

} /*readdir*/
