/* This program linearly searches for numbers that set
	off fdiv bug.  Finds an error about every 21 minutes
	on a p-90.
 
   Written by Bill Broadley
   linsearchbug.c Version 1.0
   Broadley@math.ucdavis.edu
 
   Please email if this DOESN'T find a bug on your pentium.
 */

#include <stdio.h>
#include <math.h>

main ()
{
  double x, y;
  double c1 = 1.0;
  double delta = 1e-15;
  int total = 0;
  int error = 0;
  long i;
  /* don't do buffered I/O */
  setvbuf (stdout, NULL, _IOLBF, 80);


  for (x = 1; x > 0;)
    {
      for (i = 0; i < 16777216; i++)
	{
	  y = (c1 / x) * x;
	  if (fabs (y - c1) > delta)
	    {
	      ++error;
	      printf ("#%4d %20.20e ", error, x);
	      printf ("Error=%20.20e\n", fabs (y - c1));
	    }
	  x++;
	}
      total++;
      printf ("tried=%4d * 2^24", total);
      printf (" errors=%3d", error);
      printf (" last try=%20.20e\n", x);
    }
}
