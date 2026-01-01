
/*
=====================================================================
  ST.Y: PCYACC grammar description file for SMALLTALK method parser
  Verion 1.0
  By Xing Liu
  Copyright(c) Abraxas Software Inc. (R), 1988, All rights reserved

=====================================================================
*/

%union {
  float n;
  char  c;
  char *s;
}

%token CHARACTER
%token IDENTIFIER
%token LEFTARROW
%token NUMBER
%token STRING
%token UPARROW

/*
  special characters that can be used as binary message selectors
*/

%token ADD		/* + */
%token SLSH		/* / */
%token BSLSH		/* \ */
%token MUL		/* * */
%token TLD		/* ~ */
%token LT		/* < */
%token GT		/* > */
%token EQ		/* = */
%token AT		/* @ */
%token MOD		/* % */
%token OR		/* | */
%token AND		/* & */
%token QMK		/* ? */
%token NOT		/* ! */

%left  KWMSG
%left  ADD		/* + */
       SLSH		/* / */
       BSLSH		/* \ */
       MUL		/* * */
       TLD		/* ~ */
       LT		/* < */
       GT		/* > */
       EQ		/* = */
       AT		/* @ */
       MOD		/* % */
       OR		/* | */
       AND		/* & */
       QMK		/* ? */
       NOT		/* ! */

       BIMSG

%left  UNMSG
%left  ONESP
%left  TWOSP

%start method

%%

method
  : msgpatterns opt_temporaries opt_statements
  ;

opt_temporaries
  :
  | temporaries
  ;

opt_statements
  :
  | statements
  ;

msgpatterns
  : msgpattern
  | msgpatterns msgpattern
  ;

msgpattern
  : IDENTIFIER
  | bsel IDENTIFIER
  | keyword IDENTIFIER
  ;

statements
  : stat
  | statements '.' stat
  ;

stat
  : UPARROW expr
  |         expr
  ;

expr
  : IDENTIFIER LEFTARROW expr0
  |                      expr0
  ;

expr0
  : msgexpr
  | casexpr
  ;

primary
  : IDENTIFIER
  | literal
  | block
  | '(' expr ')'
  ;

msgexpr
  : primsgexpr
  | msgexpr IDENTIFIER			%prec UNMSG
  | msgexpr bsel msgexpr		%prec BIMSG
  | msgexpr keyword msgexpr		%prec KWMSG
  ;

primsgexpr
  : primary
  | primary IDENTIFIER
  | primary bsel primary
  | primary keyword primary
  ;

/*
msgexpr
  : uexpr
  | bexpr
  | kexpr
  ;

uexpr
  : uobj usel
  ;

bexpr
  : bobj bsel uobj
  ;

kexpr
  : bobj kexpr0
  ;

kexpr0
  : keyword bobj
  | kexpr0 keyword bobj
  ;

uobj
  : primary
  | bexpr
  ;

bobj
  : uobj
  | bexpr
  ;
*/

casexpr
  : msgexpr ';' msgpatterns
  ;

/*
casexpr0
  : usel
  | bsel uobj
  | keyword bobj
  | casexpr0 usel
  | casexpr0 bsel uobj
  | casexpr0 keyword bobj
  ;
*/

temporaries
  : OR identifier_list OR
  ;

block
  : '[' opt_blkvars statements ']'
  ;

opt_blkvars
  :
  | blkvars '|'
  ;

blkvars
  : ':' IDENTIFIER
  | blkvars ':' IDENTIFIER
  ;

/*
usel
  : IDENTIFIER
  ;
*/

bsel
  : '-'
  | spechar			%prec ONESP
  | spechar spechar		%prec TWOSP
  ;

spechar
  : ADD		/* + */
  | SLSH	/* / */
  | BSLSH	/* \ */
  | MUL	 	/* * */
  | TLD		/* ~ */
  | LT		/* < */
  | GT		/* > */
  | EQ		/* = */
  | AT		/* @ */
  | MOD		/* % */
  | OR		/* | */
  | AND		/* & */
  | QMK		/* ? */
  | NOT		/* ! */
  ;

keyword
  : IDENTIFIER ':'
  ;

literal
  : NUMBER
  | STRING
  | CHARACTER
  | symbol_const
  | array_const
  ;

symbol_const
  : '#' symbol
  ;

symbol
  : IDENTIFIER
  | bsel
  | keyword
  ;

array_const
  : '#' array
  ;

array
  : '(' components ')'
  ;

components
  : component
  | components component
  ;

component
  : NUMBER
  | STRING
  | CHARACTER
  | array
  | symbol
  ;

identifier_list
  : IDENTIFIER
  | identifier_list ',' IDENTIFIER
  ;

