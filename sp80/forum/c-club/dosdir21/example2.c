/*
 *  EXAMPLE2.C - Example program uses dosdir directory functions
 *
 *  Modification history:
 *   V1.0  9-Jun-94, J Mathews  Original version.
 */

#include "dosdir.h"

void main( int argc, char** argv)
{
  dd_ffblk fb;
  char *mask = (argc == 1) ? ALL_FILES_MASK : argv[1];
  printf("Directory of %s\n", mask);
  if (!dd_findfirst( mask, &fb, DD_DIREC ))
  {
    do {
         printf("%s\n", fb.dd_name);
    } while (!dd_findnext(&fb));
  }
}
