/*
 *  yyerror.c -- stdio print error
 *
 * Copyright (C) 1988, 1989, 1990, 1991 by Rob Duff
 * All rights reserved
 */

#include <stdio.h>

yyerror(fmt, arg)
char *fmt, *arg;
{
    fprintf(stderr, fmt, arg);
    fputc('\n', stderr);
}

