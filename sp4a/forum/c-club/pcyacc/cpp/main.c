
/*================== PCYACC ==========================================

            ABRAXAS SOFTWARE (R) PCYACC
      (C)COPYRIGHT PCYACC 1986-88, ABRAXAS SOFTWARE, INC.
               ALL RIGHTS RESERVED

======================================================================*/

 
#include <stdio.h>
#include <string.h>

#include "const.h"
#include "global.h"
#include "yylex.h"
#include "yyerr.h"

extern void blink_defs();
extern void alift_defs();
extern void tlift_defs();
extern void flift_defs();
extern void gcode_defs();

extern int yyparse();

void split();

int debug;
long dymesize = 0;

char infn[NMSZ];
char infn_root[NMSZ];
char infn_ext[NMSZ];
char lifn[NMSZ];
char tmfn[NMSZ];
char trfn[NMSZ];
char oufn[NMSZ];

FILE *fopen(),
     *infp,
     *listfp,
     *tempfp,
     *tracefp,
     *outfp;

main(argc, argv)
int  argc;
char *argv[];
{ int i;
  int onechar;

    infn[0] = '\0';
    lifn[0] = '\0';
    oufn[0] = '\0';
    debug = FALSE;

    while (argc > 1) {
      argv++;
      if ((*argv)[0] == '-') {
        switch ((*argv)[1]) {
          case 'd': {
            debug = TRUE;
            break;
	  }
          default: {
            fprintf(stderr, "ERROR: unknown option \"%c\"\n", (*argv)[1]);
            exit(1);
	  }
	}
      } else {
        strcpy(infn, *argv);
        split(infn, infn_root, infn_ext);
        if (strcmp(infn_ext, "cpp")) {
          fprintf(stderr, "ERROR: unknown file extention \"%s\"\n", infn_ext);
          exit(1);
	}
        strcpy(lifn, infn_root);
        strcat(lifn, ".lis");
        strcpy(tmfn, infn_root);
        strcat(tmfn, ".tmp");
        strcpy(trfn, infn_root);
        strcat(trfn, ".trc");
        strcpy(oufn, infn_root);
        strcat(oufn, ".c");
      }
      argc--;
    }
    if (infn_root[0] == '\0') {
      strcpy(infn, "source.cpp");
      strcpy(lifn, "source.lis");
      strcpy(tmfn, "source.tmp");
      strcpy(trfn, "source.trc");
      strcpy(oufn, "source.c");
    }

    if ((infp = fopen(infn, "r")) == NULL) {
      fprintf(stderr, "ERROR: can't open \"%s\"\n", infn);
      exit(1);
    }
    if ((listfp = fopen(lifn, "w")) == NULL) {
      fprintf(stderr, "ERROR: can't create \"%s\"\n", lifn);
      exit(1);
    }
    if ((tempfp = fopen(tmfn, "w")) == NULL) {
      fprintf(stderr, "ERROR: can't create \"%s\"\n", tmfn);
      exit(1);
    }
    if (debug) {
      if ((tracefp = fopen(trfn, "w")) == NULL) {
        fprintf(stderr, "ERROR: can't create \"%s\"\n", trfn);
        exit(1);
      }
    }

    lexinit();
    yyparse();

    blink_defs(a_prog, DEFS, NULL);

    alift_defs(a_prog, FALSE);
    tlift_defs(a_prog);

    flift_defs(a_prog, FALSE);
    gcode_defs(a_prog);

    fclose(tempfp);
    if ((tempfp = fopen(tmfn, "r")) == NULL) {
      fprintf(stderr, "ERROR: can't create \"%s\"\n", tmfn);
      exit(1);
    }
    if ((outfp = fopen(oufn, "w")) == NULL) {
      fprintf(stderr, "ERROR: can't create \"%s\"\n", oufn);
      exit(1);
    }
    format(tempfp, outfp);

    if (debug) printf("total dynamic memory used: %ld\n", dymesize); 
/*
    gen_defs(a_prog);

    fprintf(listfp, "\n\n***** ");    fprintf(stdout, "\n\n***** ");
    if (errcount > 0) {
      fprintf(listfp, "error(s) detected in translation");
      fprintf(stdout, "error(s) detected in translation");
    } else {
      fprintf(listfp, "translation successful");
      fprintf(stdout, "translation successful");
    }
    fprintf(listfp, " *****\n\n"); fprintf(stdout, " *****\n\n");
*/
    fclose(infp);
    fclose(listfp);
    fclose(tempfp);
    if (debug) fclose(tracefp);
    fclose(outfp);
}

void
split(s1, s11, s12)
char s1[], s11[], s12[];
{ register int i, j;

  i = 0;
  while ((s1[i] != '\0') && (s1[i] != '.')) {
    s11[i] = s1[i];
    i ++;
  }
  s11[i] = '\0';
  j = i + 1;
  if (s1[i] != '\0') {
    i = i + 1;
    while (s1[i] != '\0') {
      s12[i-j] = s1[i];
      i ++;
    }
  }
  s12[i-j] = '\0';
}

