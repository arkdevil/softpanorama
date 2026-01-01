/* Example.C */
/* Copyright (c) 1992 by Serge N. Varjukha */
#include <stdio.h>
#include <conio.h>
#include "mice.h"

#include "exclaim.c"

main()
{
  if (!mouseinstalled()) exit(1);
  setgraphmode();
  printf("Press any key to Exit.");
  setmouseshape(&exclaimmouse);
  showmouse();
  getch();
  hidemouse();
  settextmode();
  return(0);
}
