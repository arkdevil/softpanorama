/*
 *  yymapc -- handle escapes within strings
 *
 * Copyright (C) 1988, 1989, 1990, 1991 by Rob Duff
 * All rights reserved
 */

#include <stdio.h>

extern int yynext(void);
extern void yyback(char);
extern void yyerror(char*);

yymapc(delim, esc)
{
    register c, octv, n;

mapch:
    if (delim != EOF) {
        c = yynext();
        if (c == EOF) {
            yyerror("Unterminated string");
            return(EOF);
        }
        if (c == delim)
            return(EOF);
        if (c == '\n')
            yyerror("Newline in string");
        if (c != esc)
            return(c);
    }
    c = yynext();
    switch (c) {
    case '\n':
        if (delim == EOF)
            return(EOF);
        goto mapch;
    case 'e':
        return('\e');
    case 'f':
        return('\f');
    case 'n':
        return('\n');
    case 'p':
        return(033);
    case 'r':
        return('\r');
    case 't':
        return('\t');
    case '0':
    case '1':
    case '2':
    case '3':
    case '4':
    case '5':
    case '6':
    case '7':
        octv = c - '0';
        for (n = 1; (c = yynext()) >= '0' && c<='7' && n <= 3; n++)
            octv = octv * 010 + c - '0';
        yyback(c);
        return(octv);
    case '\"':
    case '\'':
    default:
        return(c);
    }
}



