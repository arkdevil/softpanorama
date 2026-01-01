/* bigram -- list bigrams for fast-find

   Usage: bigram < text > bigrams
   
   Use 'code' to encode a file using this output.

   Author: James A. Woods (jaw@riacs.edu)
   Modified by David MacKenzie (djm@ai.mit.edu)
   MS-DOS mods: Thorsten Ohl (ohl@gnu.ai.mit.edu)
   Public domain. */

#include <stdio.h>
#include <sys/types.h>

#ifdef MSDOS
#include <stdlib.h>
#include <string.h>
int prefix_length (char *s1, char *s2);
void main (void);
#else /* not MSDOS */
#include <sys/param.h>
#endif /* not MSDOS */

#ifndef MAXPATHLEN
#define MAXPATHLEN 1024
#endif

char path[MAXPATHLEN];

char oldpath[MAXPATHLEN] = " ";

void
main ()
{
  register int count, j;

  while (fgets (path, sizeof path, stdin) != NULL)
    {
      path[strlen (path) - 1] = '\0'; /* Remove newline. */

      count = prefix_length (oldpath, path);
      /* Output post-residue bigrams only. */
      for (j = count; path[j] != '\0'; j += 2)
	{
	  if (path[j + 1] == '\0')
	    break;
	  putchar (path[j]);
	  putchar (path[j + 1]);
	  putchar ('\n');
	}
      strcpy (oldpath, path);
    }
  exit (0);
}

/* Return length of longest common prefix of strings S1 and S2. */

int
prefix_length (s1, s2)
     char *s1, *s2;
{
  register char *start;

  for (start = s1; *s1 == *s2; s1++, s2++)
    if (*s1 == '\0')
      break;
  return s1 - start;
}
