/* This program randomly searchs for numbers when inverted don't
   equal themselved with the expected accuracty. This sets off FDIV bug
   about once an hour on a p-90.  Most time is spent in drand48 though.

   Written by Bill Broadley 
   rndsearchbug.c Version 1.0
   Broadley@math.ucdavis.edu

   Please email if this DOESN'T find a bug on your pentium.
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
/* linux include 
   #include <sys/timex.h> */
/* solaris include */
#include <sys/time.h>

/* Make sure everythings working so trigger the fdiv error the first time
   on a pentium */
#define errornum 824633702449.0

main ()
{
  double x, y;
  double c1 = 1.0;
  double delta = 1e-15;
  int total = 0;
  int error = 0;
  struct timeval tv;
  long i;
  setvbuf (stdout, NULL, _IOLBF, 80);

  gettimeofday (&tv, 0);
  srand48 ((tv.tv_usec / 1000) + (tv.tv_sec * 1000));

  x = errornum;
  for (;;)
    {
      for (i = 0; i < 8388608; i++)
	{
	  y = (c1 / x) * x;
	  if (fabs (y - c1) > delta)
	    {
	      ++error;
	      printf ("#%4d %18.16e: ", error, x);
	      printf ("Error=%10.8e\n", fabs (y - c1));
	    }
	  x = drand48 ();
	}
      total++;
      printf ("tried=%4d * 2^23", total);
      printf (" errors=%3d", error);
      printf (" last try=%18.16e \n", x);
    }
}
