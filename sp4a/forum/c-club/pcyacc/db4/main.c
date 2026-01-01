
#include <stdio.h>

FILE *fopen(), *fin;

main(argc, argv)
int   argc;
char *argv[];
{
    if (argc < 2) {
        fprintf(stderr, "Usage: db4 <infile>\n");
        exit(1);
    }
    fin = fopen(argv[1], "r");
    if (fin == NULL) {
        fprintf(stderr, "Can't open file \"%s\"\n", argv[1]);
        exit(1);
    }
    if (yyparse()) {
        fprintf(stderr, "Error(s) in DB-IV program \"%s\"\n", argv[1]);
        exit(1);
    } else {
        fprintf(stdout, "No error found in DB-IV program \"%s\"\n", argv[1]);
    }

    fclose(fin);
}

yyerror(s)
char *s;
{
    fprintf(stderr, "ERROR: %s\n", s);
}


