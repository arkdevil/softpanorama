
#include <stdio.h>
#include "defs.h"

FILE *fopen(), *inf;
char *infn;
int  nxtch;

main(argc, argv)
int   argc;
char *argv[];
{ int i;

  fprintf(stdout, "\n*********************************************************\n");
  fprintf(stdout,   "*   PIC: a simple PICture drawing routine               *\n");
  fprintf(stdout,   "*                                                       *\n");
  fprintf(stdout,   "*     Usage: pic <picdescrfile>                         *\n");
  fprintf(stdout,   "*     1) prepare a picture description file             *\n");
  fprintf(stdout,   "*        e.g. egfile                                    *\n");
  fprintf(stdout,   "*       +---------------------------------------+       *\n");
  fprintf(stdout,   "*        draw line white solid (-80 0, 80 0);           *\n");
  fprintf(stdout,   "*        draw line white solid (0 -80, 0 80);           *\n");
  fprintf(stdout,   "*        draw box  white solid (10 10, 70 70);          *\n");
  fprintf(stdout,   "*       +---------------------------------------+       *\n");
  fprintf(stdout,   "*        use semicolon ; to terminate a statement       *\n");
  fprintf(stdout,   "*     2) invoke pic                                     *\n");
  fprintf(stdout,   "*        pic egfile                                     *\n");
  fprintf(stdout,   "*     3) pic displays the result,                       *\n");
  fprintf(stdout,   "*        in this example, two lines and a box,          *\n");
  fprintf(stdout,   "*        on the screen of the monitor                   *\n");
  fprintf(stdout,   "*        assuming CGA capability                        *\n");
  fprintf(stdout,   "*                                                       *\n");
  fprintf(stdout,   "*********************************************************\n\n\n");
  if (argc != 2) {
    fprintf(stderr, "Not enough arguments, abort\n");
    exit(1);
  }
  if ((inf=fopen((infn=argv[1]), "r")) == NULL) {
    fprintf(stderr, "Unable to open \"%s\"\n", infn);
    exit(1);
  }
  for (i=0; i<1000; i++); /* intentionally create some delay */
  for (i=0; i<LISTSZ; symlst[i++]=NULL);
  clr_object(&anObject);
  nxtch = getc(inf);
  if (yyparse()) {
      fprintf(stdout, "\n*********************************************************\n");
      fprintf(stdout,   "*   PIC: a simple PICture drawing routine               *\n");
      fprintf(stdout,   "*                                                       *\n");
      fprintf(stdout,   "*     abnormal termination                              *\n");
      fprintf(stdout,   "*     error in parsing                                  *\n");
      fprintf(stdout,   "*     bye!                                              *\n");
      fprintf(stdout,   "*                                                       *\n");
      fprintf(stdout,   "*********************************************************\n");
      exit(1);
  }
  fclose(inf);
  picdraw();
  fprintf(stdout, "\n*********************************************************\n");
  fprintf(stdout,   "*   PIC: a simple PICture drawing routine               *\n");
  fprintf(stdout,   "*                                                       *\n");
  fprintf(stdout,   "*     normal termination                                *\n");
  fprintf(stdout,   "*     bye!                                              *\n");
  fprintf(stdout,   "*                                                       *\n");
  fprintf(stdout,   "*********************************************************\n");
}

yyerror(s)
char *s;
{
  fprintf(stderr, "%s\n", s);
}

