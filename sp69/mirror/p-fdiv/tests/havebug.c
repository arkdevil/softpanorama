/* This program just does some divisions that are known to set
   off the Pentium fdiv bug.  More then one case is used to
   make sure the compiler doesn't optimize away the division. 

   Written by Bill Broadley 
   havebug.c Version 1.0
   Broadley@math.ucdavis.edu

   Please email if this DOESN'T find a bug on your pentium.
 */

#define C 824633702449.0

double
test (double x)
{
  return ((1.0 / x) * x);
}

main ()
{
  double delta = 1e-15;
  volatile double in1, in2, in3, out1, out2, out3;
  in1 = C - 1;
  out1 = test (in1);
  in2 = C;
  out2 = test (in2);
  in3 = C + 1;
  out3 = test (in3);
  printf ("This program checks for an error > %e when using fdiv\n", delta);
  printf ("When detected it warns you that you probably have the \n");
  printf ("pentium fdiv bug.\n\n");
  if (fabs (out1 - 1.0) > delta)
    printf ("You have the pentium bug\n");
  printf ("%lf produced an error of %e\n\n", in1, fabs (out1 - 1.0));

  if (fabs (out2 - 1.0) > delta)
    printf ("You have the pentium bug\n");
  printf ("%lf produced an error of %e\n\n", in2, fabs (out2 - 1.0));

  if (fabs (out3 - 1.0) > delta)
    printf ("You have the pentium bug\n");
  printf ("%lf produced an error of %e\n", in3, fabs (out3 - 1.0));
}
