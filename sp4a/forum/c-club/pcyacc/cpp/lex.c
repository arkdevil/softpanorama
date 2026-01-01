
/*================== PCYACC ==========================================

            ABRAXAS SOFTWARE (R) PCYACC
      (C)COPYRIGHT PCYACC 1986-88, ABRAXAS SOFTWARE, INC.
               ALL RIGHTS RESERVED

======================================================================*/


#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <malloc.h>

#include "const.h"
#include "global.h"
#include "yytab.h"
#include "yyerr.h"
#include "cppcmain.h"

extern YYSTYPE yylval;

int c;
int lineno;
int charno;
int scan_started;

typedef struct {
    char name[NMSZ];
    int  kw_token;
} kw_table;

kw_table keyword_table[KWSZ] = {
    {"asm",		Asm},
    {"auto",		Auto},
    {"break",		Break},
    {"case",		Case},
    {"char",		Char},
    {"class",		Class},
    {"const",		Const},
    {"continue", 	Continue},
    {"default",	Default},
    {"delete",		Delete},
    {"do",		Do},
    {"double",		Double},
    {"else",		Else},
    {"enum",		Enum},
    {"extern",		Extern},
    {"float",		Float},
    {"for",		For},
    {"friend",		Friend},
    {"goto",		Goto},
    {"if",		If},
    {"inline",		Inline},
    {"int",		Int},
    {"long",		Long},
    {"new",		New},
    {"operator", 	Operator},
    {"overload", 	Overload},
    {"public",		Public},
    {"register", 	Register},
    {"return",		Return},
    {"short",		Short},
    {"sizeof",		Sizeof},
    {"static",		Static},
    {"struct",		Struct},
    {"switch",		Switch},
    {"this",		This},
    {"typedef",	Typedef},
    {"union",		Union},
    {"unsigned",	Unsigned},
    {"virtual",	Virtual},
    {"void",		Void},
    {"while",		While},
};

/*
 * beginning of the lexical analyzer module
 */

int
nextchar(so, li)

/*
 * called to get the next character from the input stream, and the
 * gotten character is immediately appended to the listing file.
 */

FILE *so, *li;
{
    int c;

    c = getc(so);
    putc(c, li);
    charno ++;

    return(c);
}

void
nlproc(li)

/*
 * called each time a line feed is seen. it print an error message beneath
 * the previous line if appropriate, advances the input line counter "lineno"
 * and prepares for the listing of the next input line.
 */

FILE *li;
{ int i;

    if (errflag) {
	errflag = FALSE;
	fprintf(li, "ERROR:");
        for (i=0;i<errpos;i++) {
          fprintf(li, " ");
	}
        fprintf(li, "^ %d\n", errtoken);
    }
    lineno++;
    charno = 0;
    fprintf(li,"%4d  ", lineno);
}

/*
 * a general binary search routine to find a name in a word table.
 * it returns the table index to the table entry where the name is
 * found, otherwise, it returns a -1. in order to use this routine,
 * the word table entry must be so structured that it contains a
 * field called name with the type char[].
 */
 
int
bsearch(word, word_table, tbsize)
char word[];
kw_table word_table[];
int tbsize;
{ int low, high, middle;
  int i;

    low = 0;
    high = tbsize - 1;

    while (low <= high) {
	middle = (low + high) / 2;
	i = strcmp(word, word_table[middle].name);
	if (i < 0) {
	    high = middle - 1;
	} else if (i > 0) {
	    low = middle + 1;
	} else {
	    return (middle);
	}
    }
    return (-1);
}

int
nexttok(val)

/*
 * main routine of the module
 *   LOCAL VARS: c1   -- a lookahead character
 *        tokenvalue  -- a char string for the current token value
 *        tokentype   -- an int for the current token type
 *        tokenend    -- a flag used during scanning strings and comments
 */

char *val;

{
register int i;
char tokenvalue[NMSZ];
int c1, tokentype, tokenend;

    while (isspace(c)) /* c is always one char ahead */ {
	if (c == '\n') {
	    nlproc(listfp);
	}
	c = nextchar(infp, listfp);
    }
    
    if (c == EOF) return(NULL);

    if (isdigit(c)) /* numerical token */ {
	tokentype = I_CONSTANT;
	i = 0;
	while (isdigit(c)) {
	    tokenvalue[i++] = c;
	    c = nextchar(infp, listfp);
	}
	if (c == '\.') {
	    tokentype = F_CONSTANT;
	    tokenvalue[i++] = '\.';
	    c = nextchar(infp, listfp);
	    while (isdigit(c)) {
		tokenvalue[i++] = c;
		c = nextchar(infp, listfp);
	    }
	}
    } else if (isalpha(c) || (c == '\_')) /* symbolic token */ {
	tokentype = IDENTIFIER;
        i = 0;
	while (isalnum(c) || (c == '\_')) {
	    tokenvalue[i++] = c;
	    c = nextchar(infp, listfp);
	}
    } else if (c == '\"') /* string token */ {
	tokentype = STRING;
	tokenend = FALSE;
	i = 0;
	tokenvalue[i++] = c;
	while (! tokenend) {
	    c = nextchar(infp, listfp);
	    tokenvalue[i++] = c;
	    if (c == '\"') {
		if ((c = nextchar(infp, listfp)) == '\"') {
		    tokenvalue[i++] = c;
		} else {
		    tokenend = TRUE;
		}
	    }
	}
    } else if (c == '\'') /* a character constant */ {
       tokentype = C_CONSTANT;
	tokenend = FALSE;
	i = 0;
	while (! tokenend) {
	    tokenvalue[i++] = c;
	    if ((c = nextchar(infp, listfp)) == '\'') {
	        tokenend = TRUE;
	    }
	}
	tokenvalue[i++] = c;
	c = nextchar(infp, listfp);
	if ((i <= 2) || (i > 5) || ((i == 4) && (tokenvalue[1] != '\\'))) {
	    tokentype = NONTK;
	}
    } else if (c == '\/') /* /*, //, /=, or / */  {
	if ((c = nextchar(infp, listfp)) == '\*') {
	    tokenend = FALSE;
	    while (! tokenend) {
		c = nextchar(infp, listfp);
		if (c == '\n') {
		    nlproc(listfp);
		}
		if (c == '\*') {
		    if ((c1 = getc(infp)) == '\/') {
                        putc(c1, listfp);
			tokenend = TRUE;
		    } else {
			ungetc(c1, infp);
		    }
		}
	    }
	    c = nextchar(infp, listfp);
	    return (nexttok(val));
	} else if (c == '\/') { /* a single line comment */
	    tokenend = FALSE;
	    while (! tokenend) {
		c = nextchar(infp, listfp);
		if (c == '\n') {
		    nlproc(listfp);
		    tokenend = TRUE;
		}
	    }
	    c = nextchar(infp, listfp);
	    return (nexttok(val));
	} else if (c == '\=') /* /= */ {
	    i = 0;
	    tokenvalue[i++] = '\/';
	    tokenvalue[i++] = '\=';
	    tokentype = DIVIDE_EQUAL;
	    c = nextchar(infp, listfp);
	} else { /* not a comment nor /=, return the slash token as is */
	    tokentype = '\/';
	    i = 0;
	    tokenvalue[i++] = '\/';
	}
    } else if (c == '\-') /* ->, --, -=, or - */ {
	i = 0;
	tokenvalue[i++] = c;
	if ((c = nextchar(infp, listfp)) == '\>') {
	    tokentype = POINTER;
	    tokenvalue[i++] = c;
	    c = nextchar(infp, listfp);
	} else if (c == '\-') {
	    tokenvalue[i++] = c;
	    c = nextchar(infp, listfp);
	    tokentype = DOUBLE_MINUS;
	} else if (c == '\=') {
	    tokentype = MINUS_EQUAL;
	    tokenvalue[i++] = c;
	    c = nextchar(infp, listfp);
	} else {
	    tokentype = '\-';
	}
    } else if (c == '\>') /* >=, >>, >>= or > */ {
	i = 0;
	tokenvalue[i++] = c;
	if ((c = nextchar(infp, listfp)) == '\=') {
	    tokentype = GREATER_EQUAL;
	    tokenvalue[i++] = c;
	    c = nextchar(infp, listfp);
	} else if (c == '\>') {
	    tokenvalue[i++] = c;
	    if ((c = nextchar(infp, listfp)) == '\=') {
		tokentype = RIGHT_SHIFT_EQUAL;
		tokenvalue[i++] = c;
		c = nextchar(infp, listfp);
	    } else {
	        tokentype = DOUBLE_RIGHT_ANGLE;
	    }
	} else {
	    tokentype = '\>';
	}
    } else if (c == '\<') /* <=, <<, <<= or < */ {
	i = 0;
	tokenvalue[i++] = c;
	if ((c = nextchar(infp, listfp)) == '\=') {
	    tokentype = LESS_EQUAL;
	    tokenvalue[i++] = c;
	    c = nextchar(infp, listfp);
	} else if (c == '\<') {
	    tokenvalue[i++] = c;
	    if ((c = nextchar(infp, listfp)) == '\=') {
		tokentype = LEFT_SHIFT_EQUAL;
		tokenvalue[i++] = c;
		c = nextchar(infp, listfp);
	    } else {
	        tokentype = DOUBLE_LEFT_ANGLE;
	    }
	} else {
	    tokentype = '\<';
	}
    } else if (c == '\&') /* &&, &= or & */ {
	i = 0;
	tokenvalue[i++] = c;
	if ((c = nextchar(infp, listfp)) == '\&') {
	    tokentype = DOUBLE_AMPERSAND;
	    tokenvalue[i++] = c;
	    c = nextchar(infp, listfp);
	} else if (c == '\=') {
	    tokentype = AND_EQUAL;
	    tokenvalue[i++] = c;
	    c = nextchar(infp, listfp);
	} else {
	    tokentype = '\&';
	}
    } else if (c == '\:') /* :: */ {
	i = 0;
	tokenvalue[i++] = c;
	if ((c = nextchar(infp, listfp)) == '\:') {
	    tokentype = DOUBLE_COLON;
	    tokenvalue[i++] = c;
	    c = nextchar(infp, listfp);
	} else {
	    tokentype = '\:';
	}
    } else if (c == '\=') /* == or = */ {
	i = 0;
	tokenvalue[i++] = c;
	if ((c = nextchar(infp, listfp)) == '\=') {
	    tokentype = DOUBLE_EQUAL;
	    tokenvalue[i++] = c;
	    c = nextchar(infp, listfp);
	} else {
	    tokentype = '\=';
	}
    } else if ( c == '\+') /* ++, += or + */ {
	i = 0;
	tokenvalue[i++] = c;
	if ((c = nextchar(infp, listfp)) == '\+') {
	    tokentype = DOUBLE_PLUS;
	    tokenvalue[i++] = c;
	    c = nextchar(infp, listfp);
	} else if (c == '\=') {
	    tokentype = PLUS_EQUAL;
	    tokenvalue[i++] = c;
	    c = nextchar(infp, listfp);
	} else {
	    tokentype = '\+';
	}
    } else if (c == '\|') /* ||, |= or | */ {
	i = 0;
	tokenvalue[i++] = c;
	if ((c = nextchar(infp, listfp)) == '\|') {
	    tokentype = DOUBLE_VERTICAL_BAR;
	    tokenvalue[i++] = c;
	    c = nextchar(infp, listfp);
	} else if (c == '\=') {
	    tokentype = OR_EQUAL;
	    tokenvalue[i++] = c;
	    c = nextchar(infp, listfp);
	} else {
	    tokentype = '\|';
	}
    } else if (c == '\^') /* ^= or ^ */ {
	i = 0;
	tokenvalue[i++] = c;
	if ((c = nextchar(infp, listfp)) == '\=') {
	    tokentype = EXOR_EQUAL;
	    tokenvalue[i++] = c;
	    c = nextchar(infp, listfp);
	} else {
	    tokentype = '\^';
	}
    } else if (c == '\%') /* %= or % */ {
	i = 0;
	tokenvalue[i++] = c;
	if ((c = nextchar(infp, listfp)) == '\=') {
	    tokentype = MOD_EQUAL;
	    tokenvalue[i++] = c;
	    c = nextchar(infp, listfp);
	} else {
	    tokentype = '\%';
	}
    } else if (c == '\!') /* != or ! */ {
	i = 0;
	tokenvalue[i++] = c;
	if ((c = nextchar(infp, listfp)) == '\=') {
	    tokentype = NOT_EQUAL;
	    tokenvalue[i++] = c;
	    c = nextchar(infp, listfp);
	} else {
	    tokentype = '\!';
	}
    } else if (c == '\*') /* *= or * */ {
	i = 0;
	tokenvalue[i++] = c;
	if ((c = nextchar(infp, listfp)) == '\=') {
	    tokentype = TIMES_EQUAL;
	    tokenvalue[i++] = c;
	    c = nextchar(infp, listfp);
	} else {
	    tokentype = '\*';
	}
    } else if (c == '\.') /* ... or . */ {
	i = 0;
	tokenvalue[i++] = c;
	if ((c = nextchar(infp, listfp)) == '\.') {
	    tokenvalue[i++] = c;
	    if ((c = nextchar(infp, listfp)) == '\.') {
		tokentype = TRIPLE_DOT;
		tokenvalue[i++] = c;
		c = nextchar(infp, listfp);
	    } else {
		tokentype = NONTK;
	    }
	} else {
	    tokentype = '\.';
	}
    } else {
	i = 0;
	tokenvalue[i++] = c;
	tokentype = c;
        c = nextchar(infp, listfp);
    }
    tokenvalue[i++] = '\0';
    
    if (tokentype == IDENTIFIER) {
	if ((i = bsearch(tokenvalue, keyword_table, KWSZ)) >= 0) {
	    tokentype = keyword_table[i].kw_token;
	}
    }
    strcpy(val, tokenvalue);
    return(tokentype);
}

int ctktyp, ntktyp;
char ctkval[NMSZ], ntkval[NMSZ];

/*
 * initialization
 */

void
lexinit() {

  lineno = 1;
  charno = 1;
  scan_started = FALSE;

  fprintf(listfp,"%4d  ", lineno);
  c = nextchar(infp, listfp);
  ctktyp = nexttok(ctkval);
  ntktyp = nexttok(ntkval);
}

/*
 * interface with the yyparse()
 */

int
yylex() {
int  tktyp;

  if (ctktyp != IDENTIFIER) {
    tktyp = ctktyp;
  } else {
    if (scan_started) {
      tktyp = ctktyp;
    } else {
      scan_started = TRUE;
      if (ntktyp != IDENTIFIER) {
        tktyp = ctktyp;
      } else {
        tktyp = TYP;
      }
    }
  }
  
  yylval.pchr = (char *) malloc(1 + strlen(ctkval));
  strcpy(yylval.pchr, ctkval);
/*  fprintf(tracefp, "tktype = %d, tkval = %s\n", tktyp, ctkval); */
  ctktyp = ntktyp;
  strcpy(ctkval, ntkval);
  ntktyp = nexttok(ntkval);

  return(tktyp);
}



