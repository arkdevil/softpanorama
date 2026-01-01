
/*================== PCYACC ==========================================

            ABRAXAS SOFTWARE (R) PCYACC
      (C)COPYRIGHT PCYACC 1986-88, ABRAXAS SOFTWARE, INC.
               ALL RIGHTS RESERVED

======================================================================*/


%{

#include <stdio.h>
#include "const.h"
#include "global.h"
#include "yylex.h"
#include "cppcmain.h"

%}

/*
 * syntax convention:
 * nonterminals are represented using all-lowercase symbols
 * terminals for value types are represented using all-uppercase symbols
 * terminals for combined symbols are represented using all-uppercase symbols
 * terminals for key-words are represented  using capitalized symbols
 * terminals for reserved-words are represented using capitalized symbols
 * terminals for single characters are represented by themselves
 */

/* tokens denoting value types */

%token <pchr> C_CONSTANT                /* a char constant */
%token <pchr> F_CONSTANT                /* a float constant */
%token <pchr> I_CONSTANT                /* an integer constant */
%token <pchr> STRING                    /* a string constant */

%token <pchr> IDENTIFIER                /* an identifier */
%token <pchr> TAG
%token <pchr> TYP
%token <pchr> VAR

/* tokens denoting combined symbols */

%token AND_EQUAL                 /* &= */
%token DIVIDE_EQUAL              /* /= */
%token DOUBLE_AMPERSAND          /* && */
%token DOUBLE_COLON              /* :: */
%token DOUBLE_EQUAL              /* == */
%token DOUBLE_LEFT_ANGLE         /* << */
%token DOUBLE_MINUS              /* -- */
%token DOUBLE_PLUS               /* ++ */
%token DOUBLE_RIGHT_ANGLE        /* >> */
%token DOUBLE_VERTICAL_BAR       /* || */
%token EXOR_EQUAL                /* ^= */
%token GREATER_EQUAL             /* >= */
%token LEFT_SHIFT_EQUAL          /* <<= */
%token LESS_EQUAL                /* <= */
%token MINUS_EQUAL               /* -= */
%token MOD_EQUAL                 /* %= */
%token NOT_EQUAL                 /* != */
%token OR_EQUAL                  /* |= */
%token PLUS_EQUAL                /* += */
%token POINTER                   /* -> */
%token RIGHT_SHIFT_EQUAL         /* >>= */
%token TIMES_EQUAL               /* *= */
%token TRIPLE_DOT                /* ... */

/* tokens denoting key-words */

%token Asm
%token Auto
%token Break
%token Case
%token Class
%token Const
%token Continue
%token Default
%token Do
%token Else
%token Enum
%token Extern
%token For
%token Friend
%token Goto
%token If
%token Inline
%token Operator
%token Overload
%token Public
%token Register
%token Return
%token Static
%token Struct
%token Switch
%token This
%token Typedef
%token Union
%token Unsigned
%token Virtual
%token While

/* tokens denoting reserved-words */

%token Char
%token Delete
%token Double
%token Float
%token Int
%token Long
%token New
%token Short
%token Sizeof
%token Void

%left        ','

%right       '='
             TIMES_EQUAL
             DIVIDE_EQUAL
             MOD_EQUAL
             PLUS_EQUAL
             MINUS_EQUAL
             RIGHT_SHIFT_EQUAL
             LEFT_SHIFT_EQUAL
             AND_EQUAL
             OR_EQUAL
             EXOR_EQUAL

%right       '?'
             ':'

%left        DOUBLE_VERTICAL_BAR
%left        DOUBLE_AMPERSAND
%left        '|'
%left        '^'
%left        '&'

%left        DOUBLE_EQUAL
             NOT_EQUAL

%left        '<'
             '>'
             GREATER_EQUAL
             LESS_EQUAL

%left        DOUBLE_LEFT_ANGLE
             DOUBLE_RIGHT_ANGLE

%left        '+'
             '-'

%left        '*'
             '/'
             '%'

%right       Sizeof SIZEOBJ SIZETYPE

%right       DOUBLE_PLUS  PREINC POSTINC
             DOUBLE_MINUS PREDEC POSTDEC
             '~'
             '!'
             UMINUS
             UPLUS
             ADDROF
             DEREF
             New
             Delete VECDEL

%left        '('
             '['
             '.'
             POINTER

%type <pdfs> prog defs
%type <pdef> def
%type <pfdf> func_def
%type <ptdc> type_decl
%type <pfdc> func_decl
%type <pfhd> func_head
%type <pfbd> func_body
%type <pmil> mem_init_list
%type <pmin> mem_init
%type <pddc> data_decl
%type <ptsp> tp_spec
%type <pstn> simp_tname
%type <pesp> enum_spec
%type <pels> enum_list
%type <penm> enumerator
%type <pusp> unio_spec
%type <pcsp> clas_spec
%type <pchd> class_head
%type <pssp> sc_spec
%type <pfsp> ft_spec
%type <pdls> decl_list
%type <pidc> init_decl
%type <pini> init
%type <pils> init_list
%type <pdcl> decl
%type <pdnm> dname
%type <psdn> simp_dname
%type <pofn> operfunc_name
%type <padl> arg_decl_list
%type <parg> args
%type <padc> arg_decl
%type <pcst> comp_stmt
%type <psls> stmt_list
%type <pstm> stmt
%type <pexp> expr
%type <ptrm> term
%type <ppex> prim_expr
%type <pid>  id
%type <pop>  op
%type <ptnm> type_name
%type <pabs> abstract_decl
%type <pcex> const_expr
%type <pcon> konst

%start prog

%%

prog
  : defs
    {
      a_prog = $1;
    }
  ;

defs
  : def
    {
      $$ = new_defs($1, NULL);
    }
  | defs def
    {
      $$ = new_defs($2, $1);
    }
  ;

def
  : func_def
    {
      $$ = new_def($1, NULL, NULL, NULL);
      scan_started = FALSE;
    }
  | data_decl
    {
      $$ = new_def(NULL, $1, NULL, NULL);
      scan_started = FALSE;
    }
  | type_decl
    {
      $$ = new_def(NULL, NULL, $1, NULL);
      scan_started = FALSE;
    }
  | func_decl
    {
      $$ = new_def(NULL, NULL, NULL, $1);
      scan_started = FALSE;
    }
  ;


type_decl
  : enum_spec ';'
    {
      $$ = new_type_decl($1, NULL, NULL);
    }
  | unio_spec ';'
    {
      $$ = new_type_decl(NULL, $1, NULL);
    }
  | clas_spec ';'
    {
      $$ = new_type_decl(NULL, NULL, $1);
    }
  ;

func_def
  : func_head func_body
    {
      $$ = new_func_def($1, $2);
    }
  ;

func_decl
  : func_head ';'
    {
      $$ = new_func_decl($1);
    }
  ;

func_body
  :               comp_stmt
    {
      $$ = new_func_body(NULL, $1);
    }
  | mem_init_list comp_stmt
    {
      $$ = new_func_body($1, $2);
    }
  ;

func_head
  : sc_spec ft_spec tp_spec decl '(' arg_decl_list ')'
    {
      $$ = new_func_head($1, $2, $3, $4, $6);
    }
  | sc_spec ft_spec         decl '(' arg_decl_list ')'
    {
      $$ = new_func_head($1, $2, NULL, $3, $5);
    }
  | sc_spec         tp_spec decl '(' arg_decl_list ')'
    {
      $$ = new_func_head($1, NULL, $2, $3, $5);
    }
  | sc_spec                 decl '(' arg_decl_list ')'
    {
      $$ = new_func_head($1, NULL, NULL, $2, $4);
    }
  |         ft_spec tp_spec decl '(' arg_decl_list ')'
    {
      $$ = new_func_head(NULL, $1, $2, $3, $5);
    }
  |         ft_spec         decl '(' arg_decl_list ')'
    {
      $$ = new_func_head(NULL, $1, NULL, $2, $4);
    }
  |                 tp_spec decl '(' arg_decl_list ')'
    {
      $$ = new_func_head(NULL, NULL, $1, $2, $4);
    }
  |                         decl '(' arg_decl_list ')'
    {
      $$ = new_func_head(NULL, NULL, NULL, $1, $3);
    }
  | sc_spec ft_spec tp_spec decl '('               ')'
    {
      $$ = new_func_head($1, $2, $3, $4, NULL);
    }
  | sc_spec ft_spec         decl '('               ')'
    {
      $$ = new_func_head($1, $2, NULL, $3, NULL);
    }
  | sc_spec         tp_spec decl '('               ')'
    {
      $$ = new_func_head($1, NULL, $2, $3, NULL);
    }
  | sc_spec                 decl '('               ')'
    {
      $$ = new_func_head($1, NULL, NULL, $2, NULL);
    }
  |         ft_spec tp_spec decl '('               ')'
    {
      $$ = new_func_head(NULL, $1, $2, $3, NULL);
    }
  |         ft_spec         decl '('               ')'
    {
      $$ = new_func_head(NULL, $1, NULL, $2, NULL);
    }
  |                 tp_spec decl '('               ')'
    {
      $$ = new_func_head(NULL, NULL, $1, $2, NULL);
    }
  |                         decl '('               ')'
    {
      $$ = new_func_head(NULL, NULL, NULL, $1, NULL);
    }
  ;

/*
func_def
  : sc_spec ft_spec tp_spec decl '(' arg_decl_list ')' mem_init_list comp_stmt
    {
      $$ = new_func_def($1, $2, $3,
                                $4, $6, $8, $9);
    }
  | sc_spec ft_spec tp_spec decl '(' arg_decl_list ')'               comp_stmt
    {
      $$ = new_func_def($1, $2, $3,
                                $4, $6, NULL, $8);
    }
  | sc_spec ft_spec         decl '(' arg_decl_list ')' mem_init_list comp_stmt
    {
      $$ = new_func_def($1, $2, NULL,
                                $3, $5, $7, $8);
    }
  | sc_spec ft_spec         decl '(' arg_decl_list ')'               comp_stmt
    {
      $$ = new_func_def($1, $2, NULL,
                                $3, $5, NULL, $7);
    }
  | sc_spec         tp_spec decl '(' arg_decl_list ')' mem_init_list comp_stmt
    {
      $$ = new_func_def($1, NULL, $2,
                                $3, $5, $7, $8);
    }
  | sc_spec         tp_spec decl '(' arg_decl_list ')'               comp_stmt
    {
      $$ = new_func_def($1, NULL, $2,
                                $3, $5, NULL, $7);
    }
  | sc_spec                 decl '(' arg_decl_list ')' mem_init_list comp_stmt
    {
      $$ = new_func_def($1, NULL, NULL,
                                $2, $4, $6, $7);
    }
  | sc_spec                 decl '(' arg_decl_list ')'               comp_stmt
    {
      $$ = new_func_def($1, NULL, NULL,
                                $2, $4, NULL, $6);
    }
  |         ft_spec tp_spec decl '(' arg_decl_list ')' mem_init_list comp_stmt
    {
      $$ = new_func_def(NULL, $1, $2,
                                $3, $5, $7, $8);
    }
  |         ft_spec tp_spec decl '(' arg_decl_list ')'               comp_stmt
    {
      $$ = new_func_def(NULL, $1, $2,
                                $3, $5, NULL, $7);
    }
  |         ft_spec         decl '(' arg_decl_list ')' mem_init_list comp_stmt
    {
      $$ = new_func_def(NULL, $1, NULL,
                                $2, $4, $6, $7);
    }
  |         ft_spec         decl '(' arg_decl_list ')'               comp_stmt
    {
      $$ = new_func_def(NULL, $1, NULL,
                                $2, $4, NULL, $6);
    }
  |                 tp_spec decl '(' arg_decl_list ')' mem_init_list comp_stmt
    {
      $$ = new_func_def(NULL, NULL, $1,
                                $2, $4, $6, $7);
    }
  |                 tp_spec decl '(' arg_decl_list ')'               comp_stmt
    {
      $$ = new_func_def(NULL, NULL, $1,
                                $2, $4, NULL, $6);
    }
  |                         decl '(' arg_decl_list ')' mem_init_list comp_stmt
    {
      $$ = new_func_def(NULL, NULL, NULL,
                                $1, $3, $5, $6);
    }
  |                         decl '(' arg_decl_list ')'               comp_stmt
    {
      $$ = new_func_def(NULL, NULL, NULL,
                                $1, $3, NULL, $5);
    }
  | sc_spec ft_spec tp_spec decl '('               ')' mem_init_list comp_stmt
    {
      $$ = new_func_def($1, $2, $3,
                                $4, NULL, $7, $8);
    }
  | sc_spec ft_spec tp_spec decl '('               ')'               comp_stmt
    {
      $$ = new_func_def($1, $2, $3,
                                $4, NULL, NULL, $7);
    }
  | sc_spec ft_spec         decl '('               ')' mem_init_list comp_stmt
    {
      $$ = new_func_def($1, $2, NULL,
                                $3, NULL, $6, $7);
    }
  | sc_spec ft_spec         decl '('               ')'               comp_stmt
    {
      $$ = new_func_def($1, $2, NULL,
                                $3, NULL, NULL, $6);
    }
  | sc_spec         tp_spec decl '('               ')' mem_init_list comp_stmt
    {
      $$ = new_func_def($1, NULL, $2,
                                $3, NULL, $6, $7);
    }
  | sc_spec         tp_spec decl '('               ')'               comp_stmt
    {
      $$ = new_func_def($1, NULL, $2,
                                $3, NULL, NULL, $6);
    }
  | sc_spec                 decl '('               ')' mem_init_list comp_stmt
    {
      $$ = new_func_def($1, NULL, NULL,
                                $2, NULL, $5, $6);
    }
  | sc_spec                 decl '('               ')'               comp_stmt
    {
      $$ = new_func_def($1, NULL, NULL,
                                $2, NULL, NULL, $5);
    }
  |         ft_spec tp_spec decl '('               ')' mem_init_list comp_stmt
    {
      $$ = new_func_def(NULL, $1, $2,
                                $3, NULL, $6, $7);
    }
  |         ft_spec tp_spec decl '('               ')'               comp_stmt
    {
      $$ = new_func_def(NULL, $1, $2,
                                $3, NULL, NULL, $6);
    }
  |         ft_spec         decl '('               ')' mem_init_list comp_stmt
    {
      $$ = new_func_def(NULL, $1, NULL,
                                $2, NULL, $5, $6);
    }
  |         ft_spec         decl '('               ')'               comp_stmt
    {
      $$ = new_func_def(NULL, $1, NULL,
                                $2, NULL, NULL, $5);
    }
  |                 tp_spec decl '('               ')' mem_init_list comp_stmt
    {
      $$ = new_func_def(NULL, NULL, $1,
                                $2, NULL, $5, $6);
    }
  |                 tp_spec decl '('               ')'               comp_stmt
    {
      $$ = new_func_def(NULL, NULL, $1,
                                $2, NULL, NULL, $5);
    }
  |                         decl '('               ')' mem_init_list comp_stmt
    {
      $$ = new_func_def(NULL, NULL, NULL,
                                $1, NULL, $4, $5);
    }
  |                         decl '('               ')'               comp_stmt
    {
      $$ = new_func_def(NULL, NULL, NULL,
                                $1, NULL, NULL, $4);
    }
  ;
*/

mem_init_list
  : mem_init
    {
      $$ = new_mem_init_list($1, NULL);
    }
  | mem_init_list ',' mem_init
    {
      $$ = new_mem_init_list($3, $1);
    }
  ;

mem_init
  : IDENTIFIER '(' expr ')'
    {
      $$ = new_mem_init($1, $3);
    }
  | IDENTIFIER '(' ')'
    {
      $$ = new_mem_init($1, NULL);
    }
  ;

data_decl
  : sc_spec tp_spec decl_list ';'
    {
      $$ = new_data_decl(FALSE, $1, $2, $3);
    }
  |         tp_spec decl_list ';'
    {
      $$ = new_data_decl(FALSE, NULL, $1, $2);
    }
  | sc_spec         decl_list ';'
    {
      $$ = new_data_decl(FALSE, $1, NULL, $2);
    }
  | Typedef tp_spec decl_list ';'
    {
      $$ = new_data_decl(TRUE, NULL, $2, $3);
    }
  ;

tp_spec
  : simp_tname
    {
      $$ = new_tp_spec(FALSE, $1, NULL, NULL, NULL);
    }
  | clas_spec
    {
      $$ = new_tp_spec(FALSE, NULL, $1, NULL, NULL);
    }
  | unio_spec
    {
      $$ = new_tp_spec(FALSE, NULL, NULL, $1, NULL);
    }
  | enum_spec
    {
      $$ = new_tp_spec(FALSE, NULL, NULL, NULL, $1);
    }
  | Const simp_tname
    {
      $$ = new_tp_spec(TRUE, $2, NULL, NULL, NULL);
    }
  | Const clas_spec
    {
      $$ = new_tp_spec(TRUE, NULL, $2, NULL, NULL);
    }
  | Const unio_spec
    {
      $$ = new_tp_spec(TRUE, NULL, NULL, $2, NULL);
    }
  | Const enum_spec
    {
      $$ = new_tp_spec(TRUE, NULL, NULL, NULL, $2);
    }
  ;

simp_tname
  : TYP /* TYP */
    {
      $$ = new_simp_tname(FALSE, $1);
    }
  | Char
    {
      $$ = new_simp_tname(FALSE, "char");
    }
  | Unsigned Char  
    {
      $$ = new_simp_tname(TRUE, "char");
    }
  | Short
    {
      $$ = new_simp_tname(FALSE, "short");
    }
  | Unsigned Short
    {
      $$ = new_simp_tname(TRUE, "short");
    }
  | Int
    {
      $$ = new_simp_tname(FALSE, "int");
    }
  | Unsigned Int
    {
      $$ = new_simp_tname(TRUE, "int");
    }
  | Long
    {
      $$ = new_simp_tname(FALSE, "long");
    }
  | Unsigned Long
    {
      $$ = new_simp_tname(TRUE, "long");
    }
  | Unsigned
    {
      $$ = new_simp_tname(TRUE, "int");
    }
  | Float
    {
      $$ = new_simp_tname(FALSE, "float");
    }
  | Double
    {
      $$ = new_simp_tname(FALSE, "double");
    }
  | Void
    {
      $$ = new_simp_tname(FALSE, "void");
    }
  ;

enum_spec
  : Enum IDENTIFIER '{' enum_list '}' /* TAG */
    {
      $$ = new_enum_spec($2, $4);
    }
  | Enum     '{' enum_list '}'
    {
      $$ = new_enum_spec(NULL, $3);
    }
  | Enum IDENTIFIER /* TAG */
    {
      $$ = new_enum_spec($2, NULL);
    }
  ;

enum_list
  : enumerator
    {
      $$ = new_enum_list($1, NULL);
    }
  | enum_list ',' enumerator
    {
      $$ = new_enum_list($3, $1);
    }
  ;

enumerator
  : IDENTIFIER
    {
      $$ = new_enumerator($1, NULL);
    }
  | IDENTIFIER '=' const_expr
    {
      $$ = new_enumerator($1, $3);
    }
  ;

unio_spec
  : Union IDENTIFIER '{' defs '}' /* TAG */
    {
      $$ = new_unio_spec($2, $4);
    }
  | Union     '{' defs '}'
    {
      $$ = new_unio_spec(NULL, $3);
    }
  | Union IDENTIFIER /* TAG */
    {
      $$ = new_unio_spec($2, NULL);
    }
  ;

clas_spec
  : class_head '{' defs '}'
    {
      $$ = new_clas_spec($1, $3, NULL);
    }
  | class_head '{' '}'
    {
      $$ = new_clas_spec($1, NULL, NULL);
    }
  | class_head
    {
      $$ = new_clas_spec($1, NULL, NULL);
    }
  | class_head '{' Public ':' '}'
    {
      $$ = new_clas_spec($1, NULL, NULL);
    }
  | class_head '{' defs Public ':' defs '}'
    {
      $$ = new_clas_spec($1, $3, $6);
    }
  | class_head '{' Public ':' defs '}'
    {
      $$ = new_clas_spec($1, NULL, $5);
    }
  | class_head '{' defs Public ':' '}'
    {
      $$ = new_clas_spec($1, $3, NULL);
    }
  ;

class_head
  : Struct IDENTIFIER /* TAG */
    {
      $$ = new_class_head(STR, $2, FALSE, NULL);
    }
  | Class  IDENTIFIER /* TAG */
    {
      $$ = new_class_head(CLA, $2, FALSE, NULL);
    }
  | Struct
    {
      $$ = new_class_head(STR, NULL, FALSE, NULL);
    }
  | Class
    {
      $$ = new_class_head(CLA, NULL, FALSE, NULL);
    }
  | Struct IDENTIFIER ':' Public IDENTIFIER /* TAG TYP */
    {
      $$ = new_class_head(STR, $2, TRUE, $5);
    }
  | Struct     ':' Public IDENTIFIER /* TYP */
    {
      $$ = new_class_head(STR, NULL, TRUE, $4);
    }
  | Struct     ':'        IDENTIFIER /* TYP */
    {
      $$ = new_class_head(STR, NULL, FALSE, $3);
    }
  | Class  IDENTIFIER ':' Public IDENTIFIER /* TAG TYP */
    {
      $$ = new_class_head(CLA, $2, TRUE, $5);
    }
  | Class      ':' Public IDENTIFIER /* TYP */
    {
      $$ = new_class_head(CLA, NULL, TRUE, $4);
    }
  | Class      ';'        IDENTIFIER /* TYP */
    {
      $$ = new_class_head(STR, NULL, FALSE, $3);
    }
  ;

sc_spec
  : Auto
    {
      $$ = new_sc_spec("auto");
    }
  | Extern
    {
      $$ = new_sc_spec("extern");
    }
  | Register
    {
      $$ = new_sc_spec("register");
    }
  | Static
    {
      $$ = new_sc_spec("static");
    }
  ;

ft_spec
  : Inline
    {
      $$ = new_ft_spec("inline");
    }
  | Overload
    {
      $$ = new_ft_spec("overload");
    }
  | Virtual
    {
      $$ = new_ft_spec("virtual");
    }
  | Friend
    {
      $$ = new_ft_spec("friend");
    }
  ;

decl_list
  : init_decl
    {
      $$ = new_decl_list($1, NULL, NULL, NULL);
    }
  | decl '(' expr ')'
    {
      $$ = new_decl_list(NULL, $1, $3, NULL);
    }
  | decl_list ',' init_decl
    {
      $$ = new_decl_list($3, NULL, NULL, $1);
    }
  | decl_list ',' decl '(' expr ')'
    {
      $$ = new_decl_list(NULL, $3, $5, $1);
    }
  ;

init_decl
  : decl
    {
      $$ = new_init_decl($1, NULL);
    }
  | decl init
    {
      $$ = new_init_decl($1, $2);
    }
  ;

init
  : '=' expr
    {
      $$ = new_init($2, NULL);
    }
  | '=' init_list
    {
      $$ = new_init(NULL, $2);
    }
  ;

init_list
  : '{' expr '}'
    {
      $$ = new_init_list($2, NULL, NULL);
    }
  | '{' expr ',' '}'
    {
      $$ = new_init_list($2, NULL, NULL);
    }
  | '{' init_list ',' init_list '}'
    {
      $$ = new_init_list(NULL, $2, $4);
    }
  ;

decl
  : dname
    {
      $$ = new_decl($1, FALSE, FALSE, FALSE, FALSE, FALSE, NULL, NULL, NULL);
    }
  | '(' decl ')'
    {
      $$ = new_decl(NULL, FALSE, FALSE, FALSE, FALSE, TRUE, $2, NULL, NULL);
    }
  | '*' decl
    {
      $$ = new_decl(NULL, TRUE, FALSE, FALSE, FALSE, FALSE, $2, NULL, NULL);
    }
  | '&' decl
    {
      $$ = new_decl(NULL, FALSE, TRUE, FALSE, FALSE, FALSE, $2, NULL, NULL);
    }
/*  | decl '(' ')'
    {
      $$ = new_decl(NULL, FALSE, FALSE, TRUE, FALSE, FALSE, $1, NULL, NULL);
    }
  | decl '(' arg_decl_list ')'
    {
      $$ = new_decl(NULL, FALSE, FALSE, FALSE, FALSE, FALSE, $1, $3, NULL);
    } */
  | decl '[' ']'
    {
      $$ = new_decl(NULL, FALSE, FALSE, FALSE, TRUE, FALSE, $1, NULL, NULL);
    }
  | decl '[' const_expr ']'
    {
      $$ = new_decl(NULL, FALSE, FALSE, FALSE, FALSE, FALSE, $1, NULL, $3);
    }
  ;

dname
  : simp_dname
    {
      $$ = new_dname(NULL, $1);
    }
  | IDENTIFIER DOUBLE_COLON simp_dname /* TYP */
    {
      $$ = new_dname($1, $3);
    }
  ;

simp_dname
  : IDENTIFIER       /* if an id found in type table, look at the next */
    {
      $$ = new_simp_dname(FALSE, FALSE, $1, NULL);
    }
  | '~' IDENTIFIER   /* token see if it is a con/destructor */
    {
      $$ = new_simp_dname(TRUE, FALSE, $2, NULL);
    }
  | operfunc_name
    {
      $$ = new_simp_dname(FALSE, FALSE, NULL, $1);
    }
  ;

operfunc_name
  : Operator op
    {
      $$ = new_operfunc_name($2);
    }
  ;

arg_decl_list
  : TRIPLE_DOT
    {
      $$ = new_arg_decl_list(TRUE, NULL);
    }
  | args
    {
      $$ = new_arg_decl_list(FALSE, $1);
    }
  | args TRIPLE_DOT
    {
      $$ = new_arg_decl_list(TRUE, $1);
    }
  ;

args
  : arg_decl
    {
      $$ = new_args($1, NULL);
    }
  | args ',' arg_decl
    {
      $$ = new_args($3, $1);
    }
  ;

arg_decl
  : tp_spec decl
    {
      $$ = new_arg_decl($1, $2, NULL, NULL);
    }
  | tp_spec decl '=' expr
    {
      $$ = new_arg_decl($1, $2, $4, NULL);
    }
  | type_name
    {
      $$ = new_arg_decl(NULL, NULL, NULL, $1);
    }
  ;

comp_stmt
  : '{' stmt_list '}'
    {
      $$ = new_comp_stmt($2);
    }
  | '{'           '}'
    {
      $$ = new_comp_stmt(NULL);
    }
  ;

stmt_list
  : stmt
    {
      $$ = new_stmt_list($1, NULL);
    }
  | stmt_list stmt
    {
      $$ = new_stmt_list($2, $1);
    }
  ;

stmt
  : data_decl
    {
      $$ = new_stmt(DAST, NULL, NULL, NULL, NULL, $1, NULL, NULL, NULL);
    }
  | comp_stmt
    {
      $$ = new_stmt(CMST, NULL, NULL, NULL, NULL, NULL, $1, NULL, NULL);
    }
  | expr ';'
    {
      $$ = new_stmt(EXST, $1, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
    }
  | ';'
    {
      $$ = new_stmt(NUST, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
    }
  | If '(' expr ')' stmt
    {
      $$ = new_stmt(IFST, $3, NULL, $5, NULL, NULL, NULL, NULL, NULL);
    }
  | If '(' expr ')' stmt Else stmt
    {
      $$ = new_stmt(IEST, $3, NULL, $5, $7, NULL, NULL, NULL, NULL);
    }
  | While '(' expr ')' stmt
    {
      $$ = new_stmt(WHST, $3, NULL, $5, NULL, NULL, NULL, NULL, NULL);
    }
  | Do stmt While '(' expr ')' ';'
    {
      $$ = new_stmt(DOST, $5, NULL, $2, NULL, NULL, NULL, NULL, NULL);
    }
  | For '(' stmt expr ';' expr ')' stmt
    {
      $$ = new_stmt(F1ST, $4, $6, $3, $8, NULL, NULL, NULL, NULL);
    }
  | For '(' stmt      ';' expr ')' stmt
    {
      $$ = new_stmt(F2ST, NULL, $5, $3, $7, NULL, NULL, NULL, NULL);
    }
  | For '(' stmt expr ';'      ')' stmt
    {
      $$ = new_stmt(F3ST, $4, NULL, $3, $7, NULL, NULL, NULL, NULL);
    }
  | For '(' stmt      ';'      ')' stmt
    {
      $$ = new_stmt(F4ST, NULL, NULL, $3, $6, NULL, NULL, NULL, NULL);
    }
  | Switch '(' expr ')' stmt
    {
      $$ = new_stmt(SWST, $3, NULL, $5, NULL, NULL, NULL, NULL, NULL);
    }
  | Case const_expr ':' stmt
    {
      $$ = new_stmt(CAST, NULL, NULL, $4, NULL, NULL, NULL, $2, NULL);
    }
  | Default ':' stmt
    {
      $$ = new_stmt(DEST, NULL, NULL, $3, NULL, NULL, NULL, NULL, NULL);
    }
  | Break ';'
    {
      $$ = new_stmt(BRST, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
    }
  | Continue ';'
    {
      $$ = new_stmt(COST, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
    }
  | Return expr ';'
    {
      $$ = new_stmt(REST, $2, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
    }
  | Return      ';'
    {
      $$ = new_stmt(REST, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
    }
  | Goto IDENTIFIER ';'
    {
      $$ = new_stmt(GOST, NULL, NULL, NULL, NULL, NULL, NULL, NULL, $2);
    }
  | IDENTIFIER ':' stmt
    {
      $$ = new_stmt(LAST, NULL, NULL, $3, NULL, NULL, NULL, NULL, $1);
    }
  ;

expr
  : term
    {
      $$ = new_expr(TRM, $1, NULL, NULL, NULL);
    }
  | expr '*' expr
    {
      $$ = new_expr(MUL, NULL, $1, $3, NULL);
    }
  | expr '/' expr
    {
      $$ = new_expr(DIV, NULL, $1, $3, NULL);
    }
  | expr '%' expr
    {
      $$ = new_expr(MOD, NULL, $1, $3, NULL);
    }
  | expr '+' expr
    {
      $$ = new_expr(ADD, NULL, $1, $3, NULL);
    }
  | expr '-' expr
    {
      $$ = new_expr(SUB, NULL, $1, $3, NULL);
    }
  | expr DOUBLE_LEFT_ANGLE expr
    {
      $$ = new_expr(SHL, NULL, $1, $3, NULL);
    }
  | expr DOUBLE_RIGHT_ANGLE expr
    {
      $$ = new_expr(SHR, NULL, $1, $3, NULL);
    }
  | expr '<' expr
    {
      $$ = new_expr(LES, NULL, $1, $3, NULL);
    }
  | expr '>' expr
    {
      $$ = new_expr(GRT, NULL, $1, $3, NULL);
    }
  | expr GREATER_EQUAL expr
    {
      $$ = new_expr(GTE, NULL, $1, $3, NULL);
    }
  | expr LESS_EQUAL expr
    {
      $$ = new_expr(LSE, NULL, $1, $3, NULL);
    }
  | expr DOUBLE_EQUAL expr
    {
      $$ = new_expr(EQU, NULL, $1, $3, NULL);
    }
  | expr NOT_EQUAL expr
    {
      $$ = new_expr(NEQ, NULL, $1, $3, NULL);
    }
  | expr '&' expr
    {
      $$ = new_expr(BAN, NULL, $1, $3, NULL);
    }
  | expr '^' expr
    {
      $$ = new_expr(BEX, NULL, $1, $3, NULL);
    }
  | expr '|' expr
    {
      $$ = new_expr(BOR, NULL, $1, $3, NULL);
    }
  | expr DOUBLE_AMPERSAND expr
    {
      $$ = new_expr(LAN, NULL, $1, $3, NULL);
    }
  | expr DOUBLE_VERTICAL_BAR expr
    {
      $$ = new_expr(LOR, NULL, $1, $3, NULL);
    }
  | expr '=' expr
    {
      $$ = new_expr(ASS, NULL, $1, $3, NULL);
    }
  | expr PLUS_EQUAL expr
    {
      $$ = new_expr(ADA, NULL, $1, $3, NULL);
    }
  | expr MINUS_EQUAL expr
    {
      $$ = new_expr(SBA, NULL, $1, $3, NULL);
    }
  | expr TIMES_EQUAL expr
    {
      $$ = new_expr(MUA, NULL, $1, $3, NULL);
    }
  | expr DIVIDE_EQUAL expr
    {
      $$ = new_expr(DVA, NULL, $1, $3, NULL);
    }
  | expr MOD_EQUAL expr
    {
      $$ = new_expr(MDA, NULL, $1, $3, NULL);
    }
  | expr EXOR_EQUAL expr
    {
      $$ = new_expr(EXA, NULL, $1, $3, NULL);
    }
  | expr AND_EQUAL expr
    {
      $$ = new_expr(ANA, NULL, $1, $3, NULL);
    }
  | expr OR_EQUAL expr
    {
      $$ = new_expr(ORA, NULL, $1, $3, NULL);
    }
  | expr LEFT_SHIFT_EQUAL expr
    {
      $$ = new_expr(LSA, NULL, $1, $3, NULL);
    }
  | expr RIGHT_SHIFT_EQUAL expr
    {
      $$ = new_expr(RSA, NULL, $1, $3, NULL);
    }
  | expr '?' expr ':' expr
    {
      $$ = new_expr(CNE, NULL, $1, $3, $5);
    }
  | expr ',' expr
    {
      $$ = new_expr(COM, NULL, $1, $3, NULL);
    }
  ;

term
  : prim_expr
    {
      $$ = new_term(PRM, $1, NULL, NULL, NULL, NULL);
    }
  | '*' term
    {
      $$ = new_term(DRT, NULL, $2, NULL, NULL, NULL);
    }
  | '&' term
    {
      $$ = new_term(RFT, NULL, $2, NULL, NULL, NULL);
    }
  | '+' term
    {
      $$ = new_term(POT, NULL, $2, NULL, NULL, NULL);
    }
  | '-' term
    {
      $$ = new_term(NET, NULL, $2, NULL, NULL, NULL);
    }
  | '~' term
    {
      $$ = new_term(BNT, NULL, $2, NULL, NULL, NULL);
    }
  | '!' term
    {
      $$ = new_term(NOT, NULL, $2, NULL, NULL, NULL);
    }
  | DOUBLE_PLUS term
    {
      $$ = new_term(BIT, NULL, $2, NULL, NULL, NULL);
    }
  | DOUBLE_MINUS term
    {
      $$ = new_term(BDT, NULL, $2, NULL, NULL, NULL);
    }
  | term DOUBLE_PLUS
    {
      $$ = new_term(AIT, NULL, $1, NULL, NULL, NULL);
    }
  | term DOUBLE_MINUS
    {
      $$ = new_term(ADT, NULL, $1, NULL, NULL, NULL);
    }
  | Sizeof expr
    {
      $$ = new_term(SZE, NULL, NULL, $2, NULL, NULL);
    }
  | Sizeof '(' type_name ')'
    {
      $$ = new_term(SZN, NULL, NULL, NULL, $3, NULL);
    }
  | '(' type_name ')' prim_expr /* reduced from expr */
    {
      $$ = new_term(CS1, $4, NULL, NULL, $2, NULL);
    }
  | simp_tname '(' expr ')'
    {
      $$ = new_term(CS2, NULL, NULL, $3, NULL, $1);
    }
  | New type_name '(' expr ')'
    {
      $$ = new_term(NEX, NULL, NULL, $4, $2, NULL);
    }
  | New type_name
    {
      $$ = new_term(NTP, NULL, NULL, NULL, $2, NULL);
    }
  | New '(' type_name ')'
    {
      $$ = new_term(NTP, NULL, NULL, NULL, $3, NULL);
    }
  | Delete expr
    {
      $$ = new_term(DLE, NULL, NULL, $2, NULL, NULL);
    }
  | Delete '[' expr ']' prim_expr /* reduced from expr */
    {
      $$ = new_term(DLV, NULL, NULL, $3, NULL, NULL);
    }
  ;

prim_expr
  : id
    {
      $$ = new_prim_expr(IDP, $1, NULL, NULL, NULL, NULL, NULL);
    }
  | DOUBLE_COLON IDENTIFIER /* VAR */
    {
      $$ = new_prim_expr(VAP, NULL, $2, NULL, NULL, NULL, NULL);
    }
  | konst
    {
      $$ = new_prim_expr(COP, NULL, NULL, $1, NULL, NULL, NULL);
    }
  | STRING
    {
      $$ = new_prim_expr(STP, NULL, NULL, NULL, $1, NULL, NULL);
    }
  | This
    {
      $$ = new_prim_expr(THP, NULL, NULL, NULL, NULL, NULL, NULL);
    }
  | '(' expr ')'
    {
      $$ = new_prim_expr(EXP, NULL, NULL, NULL, NULL, $2, NULL);
    }
  | prim_expr '[' expr ']'
    {
      $$ = new_prim_expr(VCP, NULL, NULL, NULL, NULL, $3, $1);
    }
  | prim_expr '(' expr ')'
    {
      $$ = new_prim_expr(FCP, NULL, NULL, NULL, NULL, $3, $1);
    }
  | prim_expr '(' ')'
    {
      $$ = new_prim_expr(FCP, NULL, NULL, NULL, NULL, NULL, $1);
    }
  | prim_expr '.' id
    {
      $$ = new_prim_expr(MEP, $3, NULL, NULL, NULL, NULL, $1);
    }
  | prim_expr POINTER id
    {
      $$ = new_prim_expr(PTP, $3, NULL, NULL, NULL, NULL, $1);
    }
  ;

id
  : IDENTIFIER /* VAR */
    {
      $$ = new_id(NULL, $1, NULL);
    }
  | operfunc_name
    {
      $$ = new_id(NULL, NULL, $1);
    }
  | IDENTIFIER DOUBLE_COLON IDENTIFIER /* TYP VAR */
    {
      $$ = new_id($1, $3, NULL);
    }
  | IDENTIFIER DOUBLE_COLON operfunc_name /* TYP */
    {
      $$ = new_id($1, NULL, $3);
    }
  ;

op
  : '*'
    {
      $$ = '*';
    }
  | '&'
    {
      $$ = '&';
    }
  | '+'
    {
      $$ = '+';
    }
  | '-'
    {
      $$ = '-';
    }
  | '~'
    {
      $$ = '~';
    }
  | '!'
    {
      $$ = '!';
    }
  | DOUBLE_PLUS
    {
      $$ = DOUBLE_PLUS;
    }
  | DOUBLE_MINUS
    {
      $$ = DOUBLE_MINUS;
    }
  | '/'
    {
      $$ = '/';
    }
  | '%'
    {
      $$ = '%';
    }
  | DOUBLE_LEFT_ANGLE
    {
      $$ = DOUBLE_LEFT_ANGLE;
    }
  | DOUBLE_RIGHT_ANGLE
    {
      $$ = DOUBLE_RIGHT_ANGLE;
    }
  | '<'
    {
      $$ = '<';
    }
  | '>'
    {
      $$ = '>';
   }
  | GREATER_EQUAL
    {
      $$ = GREATER_EQUAL;
    }
  | LESS_EQUAL
    {
      $$ = LESS_EQUAL;
    }
  | DOUBLE_EQUAL
    {
      $$ = DOUBLE_EQUAL;
    }
  | NOT_EQUAL
    {
      $$ = NOT_EQUAL;
    }
  | '^'
    {
      $$ = '^';
    }
  | '|'
    {
      $$ = '|';
    }
  | DOUBLE_AMPERSAND
    {
      $$ = DOUBLE_AMPERSAND;
    }
  | DOUBLE_VERTICAL_BAR
    {
      $$ = DOUBLE_VERTICAL_BAR;
    }
  | '='
    {
      $$ = '=';
    }
  | PLUS_EQUAL
    {
      $$ = PLUS_EQUAL;
    }
  | MINUS_EQUAL
    {
      $$ = MINUS_EQUAL;
    }
  | TIMES_EQUAL
    {
      $$ = TIMES_EQUAL;
    }
  | DIVIDE_EQUAL
    {
      $$ = DIVIDE_EQUAL;
    }
  | MOD_EQUAL
    {
      $$ = MOD_EQUAL;
    }
  | EXOR_EQUAL
    {
      $$ = EXOR_EQUAL;
    }
  | AND_EQUAL
    {
      $$ = AND_EQUAL;
    }
  | OR_EQUAL
    {
      $$ = OR_EQUAL;
    }
  | LEFT_SHIFT_EQUAL
    {
      $$ = LEFT_SHIFT_EQUAL;
    }
  | RIGHT_SHIFT_EQUAL
    {
      $$ = RIGHT_SHIFT_EQUAL;
    }
  | '(' ')'
    {
      $$ = '(';
    }
  | '[' ']'
    {
      $$ = ']';
    }
  | New
    {
      $$ = New;
    }
  | Delete
    {
      $$ = Delete;
    }
  ;

type_name
  : tp_spec
    {
      $$ = new_type_name($1, NULL);
    }
  | tp_spec abstract_decl
    {
      $$ = new_type_name($1, $2);
    }
  ;

/*
abstract_decl
  :
  | '*' abstract_decl
  | abstract_decl '(' ')'
  | abstract_decl '(' arg_decl_list ')'
  | abstract_decl '[' const_expr ']'
  | abstract_decl '[' ']'
  ;
*/

abstract_decl
  : '*'
    {
      $$ = new_abstract_decl(AST, NULL, NULL, NULL);
    }
  | '(' ')'
    {
      $$ = new_abstract_decl(PAR, NULL, NULL, NULL);
    }
  | '(' arg_decl_list ')'
    {
      $$ = new_abstract_decl(ARG, $2, NULL, NULL);
    }
  | '[' expr ']'
    {
      $$ = new_abstract_decl(CON, NULL, $2, NULL);
    }
  | '[' ']'
    {
      $$ = new_abstract_decl(VEC, NULL, NULL, NULL);
    }
  | '*' abstract_decl
    {
      $$ = new_abstract_decl(ASA, NULL, NULL, $2);
    }
  | abstract_decl '(' ')'
    {
      $$ = new_abstract_decl(APA, NULL, NULL, $1);
    }
  | abstract_decl '(' arg_decl_list ')'
    {
      $$ = new_abstract_decl(AAR, $3, NULL, $1);
    }
  | abstract_decl '[' expr ']'
    {
      $$ = new_abstract_decl(ACO, NULL, $3, $1);
    }
  | abstract_decl '[' ']'
    {
      $$ = new_abstract_decl(AVE, NULL, NULL, $1);
    }
  ;

const_expr /* constant for now, to be generalized */
  : konst
    {
      $$ = new_const_expr($1);
    }
  ;

konst
  : I_CONSTANT
    {
      $$ = new_konst($1);
    }
  | C_CONSTANT
    {
      $$ = new_konst($1);
    }
  | F_CONSTANT
    {
      $$ = new_konst($1);
    }
  ;

%%


