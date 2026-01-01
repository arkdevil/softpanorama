
/*
=====================================================================
  SQL.Y: PCYACC grammar specification of SQL
  Verion 1.0
  By Xing Liu
  Copyright(c) Abraxas Software Inc. (R), 1988, All rights reserved

  Reference: "A Guide To the SQL Standard", by C.J. Data
=====================================================================
*/

%union {
  int   i;
  float r;
  char *s;
}

/*
  token declarations
*/

%token ALL
%token ANY
%token AS
%token ASC
%token AUTHORIZATION
%token BETWEEN
%token BY
%token CHAR
%token CHECK
%token CLOSE
%token COMMIT
%token COBOL
%token CREATE
%token CURRENT
%token CURSOR
%token DECIMAL
%token DECLARE
%token DELETE
%token DESC
%token DISTINCT
%token ESCAPE
%token EXISTS
%token FETCH
%token FOR
%token FORTRAN
%token FROM
%token GRANT
%token GROUP
%token HAVING
%token IN
%token INDICATOR
%token INSERT
%token INTO
%token IS
%token LANGUAGE
%token LIKE
%token MODULE
%token _NULL
%token OF
%token ON
%token OPEN 
%token OPTION 
%token ORDER 
%token PASCAL
%token PL1
%token PRIVILEGES
%token PROCEDURE
%token PUBLIC
%token ROLLBACK 
%token SCHEMA
%token SELECT
%token SET
%token SOME
%token SQLCODE
%token TABLE
%token TO
%token VALUES
%token VIEW
%token UNION
%token UNIQUE
%token UPDATE
%token USER
%token WHERE
%token WITH
%token WORK

%token AND
%token OR
%token NOT

%token ADD
%token SUB
%token MUL
%token DIV

%token NEG
%token POS

%token EQ
%token NE
%token GT
%token LT
%token GE
%token LE

%token AVG
%token MAX
%token MIN
%token SUM
%token COUNT

%token IDENTIFIER
%token INTEGER_CONST
%token REAL_CONST
%token STRING_CONST

%token INTEGER
%token REAL
%token STRING

%token PRIM

%left PRIM

%left ALL
%left UNION

%left OR
%left AND

%left ADD SUB
%left MUL DIV

%left NEG POS NOT

%left '.'

%start sql_prog

%%

sql_prog
  : schema
  | module
  ;

/*
  schema definition
*/

schema
  : CREATE SCHEMA AUTHORIZATION IDENTIFIER                /* user - IDENTIFIER */
  | CREATE SCHEMA AUTHORIZATION IDENTIFIER schemaelements /* user - IDENTIFIER */
  ;

schemaelements
  : schemaelement
  | schemaelements schemaelement
  ;

schemaelement
  : basetable
  | view
  | privilege
  ;

basetable
  : CREATE TABLE IDENTIFIER '(' basetableelement_list ')'
  | CREATE TABLE IDENTIFIER '.' IDENTIFIER '(' basetableelement_list ')'
  ;

basetableelement_list
  : basetableelement
  | basetableelement_list ',' basetableelement
  ;

basetableelement
  : column
  | unique
  ;

column
  : IDENTIFIER type           /* column - IDENTIFIER */
  | IDENTIFIER type NOT _NULL /* column - IDENTIFIER */
  | IDENTIFIER type NOT _NULL UNIQUE
  ;

unique
  : UNIQUE '(' identifier_list ')' /* column_list - identifier_list */
  ;

view
  : CREATE VIEW IDENTIFIER '(' identifier_list ')' AS queryspec WITH CHECK OPTION /* column_list */
  | CREATE VIEW IDENTIFIER '(' identifier_list ')' AS queryspec                   /* column_list */
  | CREATE VIEW IDENTIFIER                         AS queryspec WITH CHECK OPTION
  | CREATE VIEW IDENTIFIER                         AS queryspec              
  | CREATE VIEW IDENTIFIER '.' IDENTIFIER '(' identifier_list ')' AS queryspec WITH CHECK OPTION /* column_list */
  | CREATE VIEW IDENTIFIER '.' IDENTIFIER '(' identifier_list ')' AS queryspec                   /* column_list */
  | CREATE VIEW IDENTIFIER '.' IDENTIFIER                         AS queryspec WITH CHECK OPTION
  | CREATE VIEW IDENTIFIER '.' IDENTIFIER                         AS queryspec              
  ;
  
privilege
  : GRANT privileges ON IDENTIFIER TO grantee_list
  | GRANT privileges ON IDENTIFIER TO grantee_list WITH GRANT OPTION
  | GRANT privileges ON IDENTIFIER '.' IDENTIFIER TO grantee_list
  | GRANT privileges ON IDENTIFIER '.' IDENTIFIER TO grantee_list WITH GRANT OPTION
  ;

privileges
  : ALL PRIVILEGES
  | ALL
  | operation_list
  ;

grantee_list
  : PUBLIC
  | IDENTIFIER                   /* user */
  | grantee_list ',' PUBLIC
  | grantee_list ',' IDENTIFIER /* user */
  ;

operation_list
  : operation
  | operation_list ',' operation
  ;

operation
  : SELECT
  | INSERT
  | DELETE
  | UPDATE
  | UPDATE '(' identifier_list ')' /* column_list */
  ;

/*
  modules
*/

module
  : MODULE IDENTIFIER LANGUAGE language cursor procedure /* module - IDENTIFIER */
  | MODULE IDENTIFIER LANGUAGE language        procedure /* module - IDENTIFIER */
  | MODULE            LANGUAGE language cursor procedure
  | MODULE            LANGUAGE language        procedure
  ;

language
  : COBOL
  | FORTRAN
  | PASCAL
  | PL1
  ;

cursor
  : DECLARE IDENTIFIER CURSOR FOR queryexpr orderby /* cursor - IDENTIFIER */
  | DECLARE IDENTIFIER CURSOR FOR queryexpr         /* cursor - IDENTIFIER */
  ;

orderby
  : ORDER BY orderspec_list
  ;

orderspec_list
  : orderspec
  | orderspec_list ',' orderspec
  ;

orderspec
  : INTEGER ASC
  | INTEGER DESC
  | pathvar ASC
  | pathvar DESC
  ;		     	

procedure
  : PROCEDURE IDENTIFIER parameter_list ';' statements ';' /* procedure - IDENTIFIER */
  ;

parameter_list
  : parameter
  | parameter_list parameter
  ;

parameter
  : IDENTIFIER type
  | SQLCODE
  ;

/*
  statements
*/

statements
  : statement
  | statements statement
  ;

statement
  : close_stmt
  | commit_stmt
  | delete_stmt
  | fetch_stmt
  | insert_stmt
  | open_stmt
  | roll_stmt
  | select_stmt
  | update_stmt
  ;

close_stmt
  : CLOSE IDENTIFIER /* cursor - IDENTIFIER */
  ;

commit_stmt
  : COMMIT WORK
  ;

delete_stmt
  : DELETE FROM  IDENTIFIER WHERE CURRENT OF IDENTIFIER
  | DELETE FROM  IDENTIFIER where
  | DELETE FROM IDENTIFIER '.' IDENTIFIER WHERE CURRENT OF IDENTIFIER
  | DELETE FROM IDENTIFIER '.' IDENTIFIER where
  ;

fetch_stmt
  : FETCH IDENTIFIER INTO pathvar_list /* cursor */
  ;

insert_stmt
  : INSERT INTO  IDENTIFIER '(' identifier_list ')' VALUES '(' atomnull_list ')' /* column_list */
  | INSERT INTO  IDENTIFIER '(' identifier_list ')' queryspec
  | INSERT INTO  IDENTIFIER                         VALUES '(' atomnull_list ')' /* column_list */
  | INSERT INTO  IDENTIFIER                         queryspec
  | INSERT INTO IDENTIFIER '.' IDENTIFIER '(' identifier_list ')' VALUES '(' atomnull_list ')' /* column_list */
  | INSERT INTO IDENTIFIER '.' IDENTIFIER '(' identifier_list ')' queryspec
  | INSERT INTO IDENTIFIER '.' IDENTIFIER                         VALUES '(' atomnull_list ')' /* column_list */
  | INSERT INTO IDENTIFIER '.' IDENTIFIER                         queryspec
  ;

atomnull_list
  : atomnull
  | atomnull_list ',' atomnull
  ;

atomnull
  : atom
  | _NULL
  ;

open_stmt
  : OPEN IDENTIFIER /* cursor - IDENTIFIER */
  ;

roll_stmt
  : ROLLBACK WORK
  ;

select_stmt
  : SELECT DISTINCT selection INTO pathvar_list tableexpr
  | SELECT ALL      selection INTO pathvar_list tableexpr
  | SELECT          selection INTO pathvar_list tableexpr
  ;

update_stmt
  : UPDATE IDENTIFIER SET assignment_list WHERE CURRENT OF IDENTIFIER
  | UPDATE IDENTIFIER SET assignment_list
  | UPDATE IDENTIFIER SET assignment_list where
  | UPDATE IDENTIFIER '.' IDENTIFIER SET assignment_list WHERE CURRENT OF IDENTIFIER
  | UPDATE IDENTIFIER '.' IDENTIFIER SET assignment_list
  | UPDATE IDENTIFIER '.' IDENTIFIER SET assignment_list where
  ;

assignment_list
  : assignment
  | assignment_list ',' assignment
  ;

assignment
  : IDENTIFIER EQ expr /* column - IDENTIFIER */
  | IDENTIFIER EQ _NULL /* column - IDENTIFIER */
  ;

/*
  query expression
*/

queryexpr
  : queryspec
  | queryexpr UNION ALL queryexpr
  | queryexpr UNION     queryexpr
  | '(' queryexpr ')'
  ;

queryspec
  : SELECT DISTINCT selection tableexpr
  | SELECT ALL      selection tableexpr
  | SELECT          selection tableexpr
  ;

selection
  : expr_list
  | '*'
  ;

expr_list
  : expr
  | expr_list ',' expr
  ;

tableexpr
  : from where groupby having
  | from where groupby
  | from where         having
  | from where
  | from       groupby having
  | from       groupby
  | from               having
  | from
  ;

from
  : FROM table_range_list
  ;

table_range_list
  : table_range
  | table_range_list ',' table_range
  ;

table_range
  : IDENTIFIER IDENTIFIER /* range variable - IDENTIFIER */
  | IDENTIFIER
  | IDENTIFIER '.' IDENTIFIER IDENTIFIER /* range variable - IDENTIFIER */
  | IDENTIFIER '.' IDENTIFIER
  ;

where
  : WHERE cond
  ;

groupby
  : GROUP BY pathvar_list
  ;

pathvar_list
  : pathvar
  | pathvar_list ',' pathvar
  ;

having
  : HAVING cond
  ;

/*
  search condition
*/

cond
  : pred
  | NOT cond
  | cond AND cond
  | cond OR  cond
  | '(' cond ')'
  ; 

pred
  : compare
  | between
  | like
  | null
  | in
  | allany
  | existence
  ;

compare
  : expr EQ expr
  | expr NE expr
  | expr LT expr
  | expr GT expr
  | expr LE expr
  | expr GE expr
  | expr EQ subq
  | expr NE subq
  | expr LT subq
  | expr GT subq
  | expr LE subq
  | expr GE subq
  ;

subq
  :        subquery
  | allany subquery
  ;

allany
  : ALL
  | ANY
  | SOME
  ;

between
  : expr NOT BETWEEN expr AND expr
  | expr     BETWEEN expr AND expr
  ;

like
  : pathvar NOT LIKE atom
  | pathvar NOT LIKE atom ESCAPE atom
  | pathvar     LIKE atom
  | pathvar     LIKE atom ESCAPE atom
  ;

null
  : pathvar IS NOT _NULL
  | pathvar IS     _NULL
  ;

in
  : expr NOT IN subquery
  | expr NOT IN atom_list
  | expr     IN subquery
  | expr     IN atom_list
  ;

atom_list
  : atom
  | atom_list ',' atom
  ;

existence
  : EXISTS subquery
  ;

subquery
  : '(' SELECT DISTINCT selection tableexpr ')'
  | '(' SELECT ALL      selection tableexpr ')'
  | '(' SELECT          selection tableexpr ')'
  ;

/*
  expression
*/

expr
  : primexpr
  | expr ADD expr
  | expr SUB expr
  | expr MUL expr
  | expr DIV expr
  ;

primexpr
  : atom
  | funcref 
  | NEG primexpr
  | POS primexpr
  | '(' expr ')'
  ;

atom
  : pathvar
  | constant
  | USER
  ;

funcref
  : fname '(' '*' ')'
  | fname '(' DISTINCT pathvar ')'
  | fname '(' ALL expr ')'
  | fname '('     expr ')'
  ;

fname
  : AVG
  | MAX
  | MIN
  | SUM
  ;

identifier_list
  : IDENTIFIER
  | identifier_list ',' IDENTIFIER
  ;

constant
  : INTEGER_CONST
  | REAL_CONST
  | STRING_CONST
  ;

type
  : INTEGER
  | REAL
  | STRING
  | CHAR '(' INTEGER_CONST ')'
  | DECIMAL '(' INTEGER_CONST ')'
  ;

pathvar
  : IDENTIFIER
  | pathvar '.' IDENTIFIER
  ;

/* end of rules */


