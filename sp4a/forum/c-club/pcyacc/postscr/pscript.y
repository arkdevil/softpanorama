
/*
==========================================================================

  pscript.y: PCYACC grammar description for POSTSCRIPT

  (c) COPYRIGHT, PCYACC ABRAXAS SOFTWARE, INC.
  version 1.0
  by Xing Liu

  Reference: PostScript Language Reference Manual
             Adobe Systems Incorporated
             Addison-Wesley, 1985

===========================================================================
*/

%union {
  int   i;
  float r;
  char *s;
}

/* PostScript is a postfix expression language, with a general */
/* syntax of O1 O2 ... On operator                             */

%token COMMENT INTEGER FLOAT STRING IDENTIFIER OPERATOR
%start pscripts

%%

pscripts
  : pexpr
  | pscripts pexpr
  ;

pexpr
  : items OPERATOR
  | items IDENTIFIER
  ;

items
  :
  | items item
  ;

item
  : COMMENT
  | INTEGER
  | FLOAT
  | STRING
  | '/' OPERATOR
  | '/' IDENTIFIER
  | '[' elems ']'
  | '{' pscripts '}'
  ;

elems
  : elem
  | elems elem
  ;

elem
  : item
  | OPERATOR
  | IDENTIFIER
  ;


