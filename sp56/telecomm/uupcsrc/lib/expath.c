/*--------------------------------------------------------------------*/
/*    e x p a t h . c                                                 */
/*                                                                    */
/*    Path expansion functions for UUPC/extended                      */
/*--------------------------------------------------------------------*/

/*--------------------------------------------------------------------*/
/*                    MS-DOS and OS/2 header files                    */
/*--------------------------------------------------------------------*/

#include <ctype.h>
#include <stdio.h>
#include <direct.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>

/*--------------------------------------------------------------------*/
/*                     UUPC/extended header files                     */
/*--------------------------------------------------------------------*/

#include "lib.h"
#include "expath.h"
#include "hlib.h"
#include "hostable.h"
#include "usertabl.h"

/*--------------------------------------------------------------------*/
/*   e x p a n d _ p a t  h                                           */
/*                                                                    */
/*   Expands ~, ~/ and relative paths                                 */
/*--------------------------------------------------------------------*/

char *expand_path(char *path,          /* Input/output path name     */
				  const char *cur_dir, /* Default directory path     */
                  const char *home,    /* Default home directory     */
                  const char *ftype )  /* Default extension          */
{
   char        *p, *fname;
   char        save[FILENAME_MAX];
   struct UserTable *userp;

/*--------------------------------------------------------------------*/
/*                   Convert backslashes to slashes                   */
/*--------------------------------------------------------------------*/

   p  = path;
   while ((p = strchr(p,'\\')) != NULL)
      *p++ = '/';

/*--------------------------------------------------------------------*/
/*                 Add optional extension, if needed                  */
/*--------------------------------------------------------------------*/

   if ( ftype != NULL )
   {
      p = strrchr(path,'/');  /* Get the last slash in name          */

      if ( p == NULL )        /* No slash?                           */
         p = path;            /* Okay, look at entire name           */

      if ( strchr( p , '.') == NULL )  /* Does name have a period?   */
         strcat( strcat(p, ".") ,ftype );
                              /* No --> Add extension                */
   } /* if ( ftype != NULL ) */

/*--------------------------------------------------------------------*/
/*               If a fully qualified path name, return               */
/*--------------------------------------------------------------------*/

   if (*path == '/')
      return path;            /* nothing to do */

/*--------------------------------------------------------------------*/
/*      If non-default drive and not full path, reject the path       */
/*--------------------------------------------------------------------*/

   if (isalpha( *path ) && (path[1] == ':'))
   {
      if (path[2] == '/')     /* Absolute path on drive?             */
		 return path;         /* Yes --> Leave it alone              */

      printmsg(0, "expand_path: Invalid path \"%s\"; \
relative path on non-default drive.  (Use full path for file.)",path);
      return NULL;          /* nothing to do  */
   } /* if */
   else
      p = path;               /* Copy entire path                    */

/*--------------------------------------------------------------------*/
/*            Try to translate the file as a home directory path      */
/*--------------------------------------------------------------------*/

   strcpy(save, p);
   if (save[0] == '~')  {
	  if (save[1] == '/')  {
		 strcpy(path, home);  /* Use home dir for this user          */
		 fname = save + 2;    /* Step past directory for simple name */
	  }
	  else  {
		 if (!save[1] || (fname = strchr(save + 1, '/')) == NULL)
			fname = "";
		 else
			*fname++ = '\0';           /* End string, step past it */
		 if (!save[1])
			 strcpy(path, home);  /* Use home dir for this user          */
		 else if (   strcmp(save + 1, "uucp") == 0
				  || stricmp(save + 1, "uupc") == 0
				 )
			strcpy(path, pubdir);	/* UUPC home dir */
		 else {

/*--------------------------------------------------------------------*/
/*                Look in /etc/passwd for the user id                 */
/*--------------------------------------------------------------------*/

			 userp = checkuser(save + 1);  /* Locate user id in table  */
			 if ( userp == BADUSER )    /* Invalid user id?         */
			 {                          /* Yes --> Dump in trash    */
				printmsg(0,"expand_path: User \"%s\" is invalid", save + 1);
				return NULL;
			 } /* if */
			 strcpy(path, userp->homedir);
		 }
	  } /* else */
   } /* if (save[0] == '~')  */

/*--------------------------------------------------------------------*/
/*    No user id appears in the path; just append the input data      */
/*    to the current directory to convert the relative path to an     */
/*    absolute path                                                   */
/*--------------------------------------------------------------------*/

   else {
		 fname = save;              /* Give it the file name - 6/23/91  */
		 if ( cur_dir == NULL )
			getcwd( path, FILENAME_MAX);
		 else if ( equal(cur_dir,"."))
         {
			strcpy( path, save );
            return path;
         }
         else
            strcpy( path, cur_dir );
   } /* else */

/*--------------------------------------------------------------------*/
/*             Normalize the path, and then add the name              */
/*--------------------------------------------------------------------*/

   while (*p && (p = strchr(p,'\\')) != NULL)
	  *p++ = '/';
   if ( path[ strlen( path ) - 1 ] != '/' )
	  strcat( path, "/");
   strcat( path, fname );
   strlwr(path);

/*--------------------------------------------------------------------*/
/*                       Return data to caller                        */
/*--------------------------------------------------------------------*/

   return path;
} /* expand_path */
