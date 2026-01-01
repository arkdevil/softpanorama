
/* PCYACC grammar specification for PASCAL based on ISO standard */

%union {
  int   i;
  float r;
  char *s;
}

%token _AND       _ARRAY   _BEGIN  _CASE   _CONST   _DIV      _DO   _DOWNTO
%token _ELSE      _END     _FILE   _FOR    _FORWARD _FUNCTION _GOTO _IF
%token _IN        _LABEL   _MOD    _NIL    _NOT     _OF       _OR   _PACKED
%token _PROCEDURE _PROGRAM _RECORD _REPEAT _SET     _THEN     _TO   _TYPE
%token _UNTIL     _VAR     _WHILE  _WITH

%token _IDENT     _INT     _REAL   _STRING

%token _ASSIGN /* := */
%token _NE     /* <> */
%token _GE     /* >= */
%token _LE     /* <= */
%token _DOTDOT /* .. */

%left  '=' '<' '>' _NE  _LE  _GE _IN
%left  '+' '-'     _OR
%left  '*' '/'     _DIV _AND _MOD
%right _NOT
%left  '.'
%right _UNARY

%start program

%%

program
  : _PROGRAM _IDENT '(' opt_identifier_list ')' ';' block '.'
  ;

opt_identifier_list
  : identifier_list
  |
  ;

identifier_list
  : _IDENT
  | _IDENT ',' identifier_list
  ;

block
  : opt_labels opt_constants opt_types opt_variables
    opt_procedure_or_function_heading_dcls _BEGIN statements _END
  ;

opt_labels
  : _LABEL integer_list ';'
  |
  ;

integer_list
  : _INT
  | _INT ',' integer_list
  ;

opt_constants
  : _CONST constant_dcls
  |
  ;

opt_types
  : _TYPE type_dcls
  |
  ;

opt_variables
  : _VAR variable_dcls
  |
  ;

opt_procedure_or_function_heading_dcls
  : opt_procedure_or_function_heading_dcls procedure_or_function_heading ';'
    block_directive ';'
  |
  ;

block_directive
  : block
  | directive
  ;

directive
  : _FORWARD
  ;

statements
  : statement
  | statements ';' statement
  ;

constant_dcls
  : _IDENT '=' constant ';'
  | constant_dcls _IDENT '=' constant ';'
  ;

variable_dcls
  : identifier_list ':' type ';'
  | variable_dcls identifier_list ':' type ';'
  ;

statement
  : opt_label unlabeled_statement
  ;

opt_label
  : _INT ':'
  |
  ;

unlabeled_statement
  : variable _ASSIGN expression
  | _IDENT opt_proc_parameter_list
  | _BEGIN statements _END
  | _IF expression _THEN statement
  | _IF expression _THEN statement _ELSE statement
  | _WHILE expression _DO statement
  | _CASE expression _OF case_body _END
  | _REPEAT statements _UNTIL expression
  | _FOR _IDENT _ASSIGN expression direction expression _DO statement
  | _WITH variable_list _DO statement
  | _GOTO _INT
  |
  ;

variable_list
  : variable
  | variable_list ',' variable
  ;

constant_list
  : constant
  | constant_list ',' constant
  ;

case_body
  : constant_list ':' statement case_trailer
  ;

case_trailer
  : ';'
  | ';' case_body
  |
  ;

direction
  : _DOWNTO
  | _TO
  ;

opt_proc_parameter_list
  : '(' expression_opt_formats_list ')'
  |
  ;

expression_opt_formats_list
  : expression_opt_formats
  | expression_opt_formats_list ',' expression_opt_formats
  ;

expression_opt_formats
  : expression opt_formats
  ;

opt_formats
  : ':' expression
  | ':' expression ':'expression
  |
  ;

expression_list
  : expression
  | expression_list ',' expression
  ;

expression
  : expression '+' expression
  | expression '-' expression
  | expression '*' expression
  | expression _DIV expression
  | expression _MOD expression
  | expression _AND expression
  | expression _OR expression
  | expression '<' expression
  | expression '>' expression
  | expression '=' expression
  | expression _NE expression
  | expression _GE expression
  | expression _LE expression
  | expression '.' expression
  | expression _IN expression
  | expression '/' expression
  | '-' expression %prec _UNARY
  | '+' expression %prec _UNARY
  | _NOT expression
  | primary
  ;

primary
  : _IDENT variable_trailer_func_parm_list
  | '(' expression ')'
  | unsigned_literal
  | '[' opt_elipsis_list ']'
  ;

variable_trailer_func_parm_list
  : variable_trailers
  | '(' expression_list ')'
  ;

opt_elipsis_list
  : elipsis_list
  |
  ;

elipsis_list
  : elipsis
  | elipsis_list ',' elipsis
  ;

elipsis
  : expression
  | expression _DOTDOT expression
  ;

/*
binop
  : '+'
  | '-'
  | '*'
  | _DIV
  | _MOD
  | _AND
  | _OR
  | '>'
  | '<'
  | '='
  | _NE
  | _GE
  | _LE
  | '.'
  | _IN
  | '/'
  ;
*/

variable
  : _IDENT variable_trailers
  ;

variable_trailers
  : '[' expression_list ']' variable_trailers
  | '.' _IDENT variable_trailers
  | '^' variable_trailers
  |
  ;

constant
  : '+' unsigned_constant %prec _UNARY
  | '-' unsigned_constant %prec _UNARY
  | unsigned_constant
  ;

unsigned_literal
  : _REAL
  | _INT
  | _STRING
  | _NIL
  ;

unsigned_constant
  : _IDENT
  | unsigned_literal
  ;

type
  : '^' _IDENT
  | ordinal_type
  | opt_packed packable_type
  ;

packable_type
  : _ARRAY '[' ordinal_type_list ']' _OF type
  | _RECORD field_list _END
  | _FILE _OF type
  | _SET _OF ordinal_type
  ;

ordinal_type_list
  : ordinal_type
  | ordinal_type_list ',' ordinal_type
  ;

ordinal_type
  : _IDENT
  | '(' identifier_list ')'
  | constant _DOTDOT constant
  ;

field_list
  : identifier_list ':' type
  | identifier_list ':' type ';' field_list
  | _CASE tag _OF cases
  |
  ;

tag
  : _IDENT
  | _IDENT ':' type
  ;

cases
  : constant_list ':' '(' field_list ')' cases_trailer
  ;

cases_trailer
  : ';' cases
  | ';'
  |
  ;

procedure_or_function_heading
  : _PROCEDURE _IDENT opt_formal_parm_list
  | _FUNCTION _IDENT opt_formal_parm_list opt_return
  ;

opt_formal_parm_list
  : '(' formal_parms ')'
  |
  ;

formal_parms
  : opt_var identifier_list ':' formal_parm_trailer
  | procedure_or_function_heading proc_parm_trailer
  ;

opt_var
  : _VAR
  |
  ;

formal_parm_trailer
  : _IDENT proc_parm_trailer
  | conformant_array_schema proc_parm_trailer
  ;

proc_parm_trailer
  : ';' formal_parms
  |
  ;

conformant_array_schema
  : opt_packed '[' index_type_spec_list ']' _OF _IDENT
  | opt_packed '[' index_type_spec_list ']' _OF _IDENT conformant_array_schema
  ;

opt_packed
  : _PACKED
  |
  ;

index_type_spec_list
  : _IDENT _DOTDOT _IDENT ':' _IDENT
  ;

opt_return
  : ':' _IDENT
  |
  ;

type_dcls
  : _IDENT '=' type ';'
  | type_dcls _IDENT '=' type ';'
  ;

  



