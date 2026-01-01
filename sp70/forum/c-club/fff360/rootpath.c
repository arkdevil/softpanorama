/*************************************************************************
 * RootPath -- Convert a pathname  argument  to  root  based  cannonical *
 *             form.                                                     *
 * Author:     Don A. Williams                                           *
 *             CompuServ - 75410,543                                     *
 *             Genie     - DON-WILL                                      *
 *                                                                       *
 * RootPath determines the current directory,  appends the path argument *
 * (which may affect which disk the current directory is  relative  to), *
 * and  qualifies  "."  and  ".." references.  The result is a complete, *
 * simple, path name with drive specifier.                               *
 *                                                                       *
 * If the relative path the user specifies  does  not  include  a  drive *
 * spec., the default drive will be used as the base. (The default drive *
 * will never be changed.)                                               *
 *                                                                       *
 *     entry:  RelativePath -- pointer to the pathname to be expanded.   *
 *             FullPath -- must point to a working buffer, see warning.	 *
 *                                                                       *
 *     exit:   FullPath -- the full path which results.                  *
 *                                                                       *
 *     return: A pointer to FullPath if OK, NULL if an error occurs.     *
 *                                                                       *
 *     calls:  getcurdir getdisk                                         *
 *                                                                       *
 *     warning: FullPath  must point to a working buffer large enough to *
 *              hold the longest possible relative  path  argument  plus *
 *              the longest possible current directory path.             *
 *                                                                       *
 * RootPath  was  modeled after the public domain file "rootpath.c" with *
 * fairly extensive "enhancement".  The major enhancement  is  provision *
 * for  relative  paths  such  as  "..\..\here"  which  MS-DOS  does NOT *
 * support.  I found that such  a  construct  would  be  very  handy  in *
 * several  of  my uses of UFIND so I added it.  Provision has also been *
 * made to handle either of the two element name  separator  characters; *
 * the '\' of MS-DOS or the '/' of Unix.  The MS-DOS facilities actually *
 * recognize  either  separator  at  the programmatic level but too many *
 * MS-DOS programs do NOT.                                               *
 *                                                                       *
 ************************************************************************/

#include <stdio.h>
#include <string.h>
#include <ctype.h>

char *RootPath (char *CurDir, char *RelPath, char *FullPath)
{
   char *p, *p1, *p2;

   if (RelPath[0] == '\0')
   {
      FullPath[0] = '\0';
      return(NULL);
   }
   if ( RelPath[1] == ':')
   {                                   /* Path contains drive  */
      FullPath[0] = RelPath[0]; FullPath[1] = RelPath[1];
      memmove(RelPath, RelPath+2, strlen(RelPath) + 1);
   }
   else
   {
      FullPath[0] = CurDir[0]; FullPath[1] = CurDir[1];
   }
   FullPath[2] = '\0';

   if (strlen(RelPath) == 2 && *(RelPath+1) == ':' ) strcat(RelPath, "\\");
   if ( (p = strchr("\\/", *RelPath)) != NULL) strcpy(FullPath+2, RelPath);
   else
   {
      FullPath[2] = '\\';
      if (FullPath[0] != CurDir[0])
      {
         if (getcurdir( (int) (toupper(*FullPath) - '@') + 1, &FullPath[3]))
	    return(NULL);
      }
      else
      {
         strcpy(FullPath, CurDir);
	 FullPath[strlen(FullPath)-1] = '\0';
      }
      p = RelPath;
      while (1)
      {
         p1 = strchr(p, '\\');
	 if (!strncmp(p, "..", 2))
         {
            if ( (p2 = strrchr(FullPath, '\\')) != NULL) *p2 = '\0';
	    p = p1 + 1;
	 }
	 else if (!strncmp(p, ".", 1))
         {
	    p = p1 + 1;
	    break;
	 };
	 if (p1 == NULL) break;
      }
      if ( (strlen(FullPath) > 3) || (strlen(FullPath) == 2) )
         strcat(FullPath, "\\");
      strcat(FullPath, p);
   }

   while ( (p = strchr(FullPath, '/')) != NULL) *p++ = '\\';

   if ( (strlen(FullPath) == 3) && (FullPath[2] == '\\') )
      FullPath[2] = '\0';
   return(strlwr(FullPath));
}
