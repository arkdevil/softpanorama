
/*
==========================================================================
  c.y: PCYACC grammar description for C programming language
  Copyright(c) Abraxas Software Inc. (R), 1988, All rights reserved
  version 1.0
  by Xing Liu

  Reference: The C Programming Language (Reference Manual)
             By B.W. Kernighan and D.M. Retchie

  As of July 19, there are 4 shift/reduce conflicts in this grammar
===========================================================================
*/

/*--------------------------- constants ---------------------------------*/

%token	C_CONST	F_CONST	I_CONST	S_CONST

/*--------------------------- identifiers -------------------------------*/

%token	IDENTIFIER	TYPEDEF_NAME

/*--------------------------- key words ---------------------------------*/

%token	Auto		Break		Case		Char	Continue
%token	Default		Do		Double		Else	Enum
%token	Extern		Float		For		Goto	If
%token	Int		Long		Register	Return	Short
%token	Sizeof		Static		Struct		Switch	Typedef
%token	Void		Union		Unsigned	While

/*--------------------------- combined operators ------------------------*/

/* binary logicals and comparators */

%token	OROR	ANDAND	EQU	NEQ	LEQ	GEQ

/* shift operators */

%token	SHL	SHR

/* unary increments */

%token	ADDADD	SUBSUB

/* pointer */

%token	PTR

/* assignments */

%token	EQ	ADDEQ	SUBEQU	MULEQ	DIVEQ	MODEQ
%token	SHLEQ	SHREQ	BANDEQ	BXOREQ	BOREQ

/*--------------------------- operator precedence -----------------------*/

/* comma operator */

%left	','

/* assignment operators */

%right	EQ	ADDEQ	SUBEQ	MULEQ	DIVEQ	MODEQ
	SHLEQ	SHREQ	BANDEQ	BXOREQ	BOREQ

/* binary operators */

%right	'?'	':'
%left	OROR
%left	ANDAND
%left	BOR
%left	BXOR
%left	BAND
%left	EQU
%left	NEQ
%left	LT	GT	LEQ	GEQ
%left	SHL	SHR
%left	ADD	SUB
%left	MUL	DIV	MOD

/* type coersion */

%left	CAST	PRIMARY

/* unary operators */

%right	ADDADD	SUBSUB	'~'	'!'
	UNIADD	UNISUB	UNIMUL	UNIBAND
	Sizeof	'*'

/* special operators */

%left	'('	'['	'.'	PTR

/*--------------------------- start symbol ------------------------------*/

%start defs

%%

/*--------------------------- external definitions ----------------------*/

defs
  :
  | defs def
  ;

def
  : fun_def
  | dat_def
  ;

fun_def
  : type_spec fun_dctor fun_body
  |           fun_dctor fun_body
  ;

fun_dctor
  : dctor '(' par_list ')'
  | dctor '('          ')'
  ;

par_list
  : IDENTIFIER
  | IDENTIFIER ',' par_list
  ;

fun_body
  : opt_dcl_list comp_stmt
  ;

dat_def
  : extern_or_static type_spec opt_init_dctor_list ';'
  | extern_or_static           opt_init_dctor_list ';'
  |                  type_spec opt_init_dctor_list ';'
  |                            opt_init_dctor_list ';'
  ;

extern_or_static
  : Extern
  | Static
  ;

opt_init_dctor_list
  :
  | init_dctor_list
  ;

/*--------------------------- declarations ------------------------------*/

dcl
  : dcl_specs opt_init_dctor_list ';'
  ;

dcl_specs
  : type_or_sc_spec
  | type_or_sc_spec dcl_specs
  ;

type_or_sc_spec
  : type_spec
  | sc_spec
  ;

sc_spec
  : Auto
  | Extern
  | Register
  | Static
  | Typedef
  ;

type_spec
  : Char
  | Short
  | Int
  | Long
  | Unsigned
  | Float
  | Double
  | Void
  | typedef_name
  | enum_spec
  | struct_spec
  | union_spec
  ;

enum_spec
  : Enum IDENTIFIER '{' enum_list '}'
  | Enum            '{' enum_list '}'
  | Enum IDENTIFIER
  ;

enum_list
  : enum
  | enum_list ',' enum
  ;

enum
  : IDENTIFIER
  | IDENTIFIER '=' const_expr
  ;

struct_spec
  : Struct IDENTIFIER '{' mem_dcl_list '}'
  | Struct            '{' mem_dcl_list '}'
  | Struct IDENTIFIER
  ;

mem_dcl_list
  : mem_dcl
  | mem_dcl_list mem_dcl
  ;

mem_dcl
  : type_spec mem_dctor_list ';'
  ;

mem_dctor_list
  : mem_dctor
  | mem_dctor ',' mem_dctor_list
  ;

mem_dctor
  : dctor
  | dctor ':' const_expr
  |       ':' const_expr
  ;

union_spec
  : Union IDENTIFIER '{' mem_dcl_list '}'
  | Union            '{' mem_dcl_list '}'
  | Union IDENTIFIER
  ;

init_dctor_list
  : init_dctor
  | init_dctor ',' init_dctor_list
  ;

init_dctor
  : dctor opt_init
  ;

opt_init
  :
  | init
  ;

dctor
  : IDENTIFIER
  | dctor '['            ']'
  | dctor '[' const_expr ']'
  | '*' dctor
  | '(' dctor ')'
  | dctor '(' ')'
  ;

init
  : '=' expr
  | '=' '{' init_list '}'
  | '=' '{' init_list ',' '}'
  ;

init_list
  : expr
  | init_list ',' init_list
  | '{' init_list '}'
  ;

type_name
  : type_spec abs_dctor
  ;

abs_dctor
  :
  | '(' abs_dctor ')'
  | '*' abs_dctor
  | abs_dctor '(' ')'
  | abs_dctor '[' ']'
  | abs_dctor '[' const_expr ']'
  ;

typedef_name
  : TYPEDEF_NAME
  ;

/*--------------------------- statements ------------------------------- */

comp_stmt
  : '{' opt_dcl_list opt_stmt_list '}'
  ;

opt_dcl_list
  :
  | opt_dcl_list dcl
  ;

/*
dcl_list
  : dcl
  | dcl dcl_list
  ;
*/

opt_stmt_list
  :
  | stmt_list
  ;

stmt_list
  : stmt
  | stmt stmt_list
  ;

stmt
  : comp_stmt
  | expr ';'
  | If '(' expr ')' stmt
  | If '(' expr ')' stmt Else stmt
  | While '(' expr ')' stmt
  | Do stmt While '(' expr ')' ';'
  | For '(' opt_expr ';' opt_expr ';' opt_expr ')' stmt
  | Switch '(' expr ')' stmt
  | Case const_expr ':' stmt
  | Default ':' stmt
  | Break ';'
  | Continue ';'
  | Return opt_expr ';'
  | Goto IDENTIFIER ';'
  | IDENTIFIER ':' stmt
  | ';'
  ;

/*--------------------------- expressions -------------------------------*/

opt_expr_list
  :
  | expr_list
  ;

expr_list
  : expr
  | expr ',' expr_list
  ;

opt_expr
  :
  | expr
  ;

expr
  : primary			%prec PRIMARY
  | expr OROR expr
  | expr ANDAND expr
  | expr BOR expr
  | expr BXOR expr
  | expr BAND expr
  | expr EQU expr
  | expr NEQ expr
  | expr LT expr
  | expr GT expr
  | expr LEQ expr
  | expr GEQ expr
  | expr SHL expr
  | expr SHR expr
  | expr ADD expr
  | expr SUB expr
  | expr MUL expr
  | expr DIV expr
  | expr MOD expr
  | expr '?' expr ':' expr
  | expr EQ expr
  | expr ADDEQ expr
  | expr SUBEQ expr
  | expr MULEQ expr
  | expr DIVEQ expr
  | expr MODEQ expr
  | expr SHLEQ expr
  | expr SHREQ expr
  | expr BANDEQ expr
  | expr BXOREQ expr
  | expr BOREQ expr
/*  | expr ',' expr */
  ;

primary
  : IDENTIFIER
  | constant
  | MUL  primary		%prec UNIMUL
  | BAND primary		%prec UNIBAND
  | ADD  primary		%prec UNIADD
  | SUB  primary		%prec UNISUB
  | '!' primary
  | '~' primary
  | ADDADD primary
  | SUBSUB primary
  | primary ADDADD
  | primary SUBSUB
  | Sizeof expr
  | '(' type_name ')' expr	%prec CAST
  | '(' expr ')'
  | primary '(' opt_expr_list ')'
  | primary '[' expr ']'
  | primary '.' IDENTIFIER
  | primary PTR IDENTIFIER
  ;

/*--------------------------- constant expressions ----------------------*/

const_expr
  : constant
  ;

constant
  : C_CONST
  | F_CONST
  | I_CONST
  | S_CONST
  ;


