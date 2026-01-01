
/*
 * Dbase IV command syntax
 * Reference: dBase IV Essentials
 *            by Jack Hursch and Carolyn Hursch, Windcrest, 1988
 *
 * Copyright(c) ABRAXAS SOFTWARE INC., 1988, all rights reserved
 *
 */

%{

#include <stdio.h>
#include "const.h"

%}

%union {
  char	cv;
  int   iv;
  float fv;
  char  nv[NMSZ];
  char *sv;
}

%token	ACCEPT
%token	ADDITIVE
%token	ALIAS
%token	ALL
%token	ALTERNATE
%token	AMERICAN
%token	ANSI
%token	APPLICATION
%token	APPEND
%token	ARRAY
%token	ASCENDING
%token	ASSIST
%token	AVERAGE
%token	AVG
%token	AUTOSAVE
%token	BACKGROUND
%token	BEFORE	  
%token	BELL
%token	BLANK
%token	BORDER	  
%token	BOTTOM
%token	BOX
%token	BRITISH	  
%token	BROWSE
%token	CALCULATE
%token	CANCEL
%token	CARRY
%token	CASE
%token	CATALOG
%token	CENTURY
%token	CHANGE
%token	CLEAR
%token	CLOCK
%token	CLOSE
%token	CNT
%token	COLOR
%token	COM1	  
%token	COM2	  
%token	COMMAND
%token	COMPRESS
%token	CONFIRM
%token	CONSOLE
%token	CONTINUE
%token	CONVERT
%token	COPY
%token	COUNT
%token	CREATE
%token	CURRENCY
%token	DATABASES 
%token	DATE
%token	dBASEII
%token	DEBUG
%token	DESCENDING
%token	DECIMALS
%token	DEFAULT
%token	DELETE
%token	DELETED
%token	DELIMITED
%token	DELIMITER
%token	DESIGN
%token	DEVELOPMENT
%token	DEVICE
%token	DIF
%token	DIR
%token	DISPLAY
%token	DISTINCT
%token	DO
%token	DOHISTORY
%token	DOUBLE
%token	ECHO
%token	EDIT
%token	EGA25
%token	EGA43
%token	EJECT	  
%token	ELSE
%token	ENDCASE
%token	ENDDO
%token	ENDIF
%token	ENDLOOP
%token	ENDSCAN
%token	ENDTEXT
%token	ENHANCED  
%token	ENVIRONMENT
%token	ERASE
%token	ERROR
%token	ESCAPE
%token	EXACT
%token	EXCEPT
%token	EXCLUSIVE
%token	EXIT
%token	EXPORT
%token	EXTENDED
%token	FIELD
%token	FIELDS
%token	_FILE
%token	FILES
%token	FILLER	   
%token	FILTER
%token	FIND
%token	FIXED
%token	FOR
%token	FORM
%token	FORMAT
%token	FREEZE
%token	FRENCH	   
%token	FROM
%token	FUNCTION
%token	FW2
%token	GERMAN	   
%token	GETS
%token	GO
%token	GOTO
%token	HEADING
%token	HELP
%token	HISTORY
%token	IF
%token	IMPORT
%token	IN
%token	INDEX
%token	INDEXES
%token	INPUT
%token	INSERT
%token	INSTRUCT
%token	INTENSITY
%token	INTO	   
%token	ITALIAN	
%token	JAPAN   
%token	JOIN
%token	KEY
%token	LABEL
%token	LAST
%token	LIKE
%token	LIST
%token	LOCATE
%token	LOCK
%token	LOOP
%token	LPT1	   
%token	LPT2
%token	MACRO	   
%token	MARGIN
%token	MASTER
%token	MEMO
%token	MEMORY
%token	MEMOWIDTH
%token	MENUS
%token	MESSAGE
%token	MAX
%token	MIN
%token	MODIFY
%token	MODULE
%token	MONO
%token	MONO43
%token	NEAR
%token	NEXT
%token	NOAPPEND
%token	NOCLEAR
%token	NODELETE
%token	NOEDIT
%token	NOEJECT
%token	NOFOLLOW	
%token	NOINIT
%token	NOMENU
%token	NONE
%token	NPV
%token	OF
%token	OFF
%token	ON
%token	ORDER
%token	OTHERWISE
%token	OVERWRITE
%token	PACK
%token	PANEL
%token	PARAMETERS
%token	PATH
%token	PFS
%token	PLAIN
%token	PLAY
%token	POINT
%token	PRECISION
%token	PRINT
%token	PRINTER
%token	PROCEDURE
%token	PUBLIC
%token	QUERY
%token	QUIT
%token	RANDOM
%token	READ
%token	READERROR
%token	RECALL
%token	RECORD
%token	REFRESH
%token	REINDEX
%token	RELATION
%token	RELEASE
%token	RENAME
%token	REPLACE
%token	REPORT
%token	REST
%token	RESTORE
%token	RESUME
%token	RETRY
%token	RETURN
%token	RPD
%token	RUN
%token	SAMPLE
%token	SAFETY
%token	SAVE
%token	SCAN
%token	SCREEN
%token	SDF
%token	SEEK
%token	SELECT
%token	SEPARATOR
%token	SET
%token	SINGLE
%token	SKIP
%token	SORT
%token	SPACE
%token	SQL
%token	STANDARD   
%token	STATUS
%token	STD
%token	STEP
%token	STORE
%token	STRUCTURE
%token	SUM
%token	SUMMARY
%token	SUSPEND
%token	SYLK
%token	TAG
%token	TALK
%token	TEXT
%token	TITLE
%token	TO
%token	TOP
%token	TOTAL
%token	TYPE
%token	TYPEAHEAD
%token	UNIQUE
%token	UPDATE
%token	USA
%token	USE
%token	VAR
%token	VIEW
%token	WAIT
%token	WHILE
%token	WIDTH
%token	WINDOW
%token	WITH
%token	WKS
%token	ZAP

%token	FALSE
%token	TRUE

%token	IDENTIFIER
%token	FUNCALL

%token	CHARACTER
%token	NUMBER
%token	STRING

%token	NE	/* <> */
%token	LE	/* <= */
%token	GE	/* >= */

%nonassoc	ACCEPT
		APPEND
		ASSIST
		AVERAGE
		BROWSE
		CALCULATE
		CANCEL
		CHANGE
		CLEAR
		CLOSE
		CONTINUE
		CONVERT
		COPY
		COUNT
		CREATE
		DELETE
		DIR
		DISPLAY
		DO
		EDIT
		EJECT
		ERASE
		EXIT
		EXPORT
		FIND
		GO
		GOTO
		HELP
		IF
		IMPORT
		INDEX
		INPUT
		INSERT
		JOIN
		LABEL
		LIST
		LOCATE
		LOOP
		MODIFY
		ON
		PACK
		PLAY
		PUBLIC
		QUIT
		READ
		RECALL
		REINDEX
		RELEASE
		RENAME
		REPLACE
		REPORT
		RESTORE
		RESUME
		RETRY
		RUN
		SAVE
		SCAN
		SEEK
		SELECT
		SET
		SKIP
		SORT
		STORE
		SUM
		SUSPEND
		TEXT
		TOTAL
		TYPE
		UPDATE
		USE
		WAIT
		ZAP

%nonassoc DOREDUCE

%nonassoc	'='	'<'	'>'	NE	LE	GE

%left	'+'	'-'
%left	'*'	'/'
%right	UNARYMINUS


%type <cv>	CHARACTER
%type <sv>	STRING
%type <nv>	IDENTIFIER
%type <iv>	NUMBER

%start	prog

%%

prog
  : PROCEDURE IDENTIFIER	/* procedure file (.prg), with params */
    PARAMETERS identifier_list	/* parameter list */
    stmts			/* other statements */
    return_st			/* return statement */
  | PROCEDURE IDENTIFIER	/* procedure file, without params */
    stmts
    return_st
  | PARAMETERS identifier_list	/* program file (.prg), with params */
    stmts
    return_st
  | stmts			/* program file (.prg), without params */
    return_st
  | stmts			/* a bunch of statements */
  ;

opt_identifier_list
  :
  | identifier_list
  ;

identifier_list
  : IDENTIFIER
  | identifier_list ',' IDENTIFIER
  ;

return_st
  : RETURN
  | RETURN TO MASTER
  ;

stmts
  : stmt
  | stmts stmt
  ;

stmt
  : simple_stmt
  | complex_stmt
  | advanced_stmt
  | db4mod_stmt
  | db4new_stmt
  ;

/* statements in alphabetical order:
----------
   accept_st 
   append_st 
   assist_st 
   average_st 
   browse_st 
   cancel_st 
   change_st 
   clear_st 
   close_st 
   continue_st 
   copy_st 
   count_st 
   create_st 
   delete_st 
   dir_st 
   display_st 
   do_st 
   edit_st 
   eject_st 
   erase_st 
   exit_st 
   export_st 
   find_st 
   go_st 
   help_st 
   if_st 
   import_st 
   index_st 
   input_st 
   insert_st
   join_st
   label_st
   list_st
   locate_st
   loop_st
   modify_st
   on_st
   pack_st
   parameter_st
   proc_st
   pub_st
   quit_st
   read_st
   recall_st
   reind_st
   release_st
   rename_st
   replace_st
   report_st
   restore_st
   resume_st
   retry_st
   return_st
   run_st
   save_st
   select_st
   set_st
   skip_st
   sort_st
   store_st
   sum_st
   suspend_st
   text_st
   total_st
   type_st
   use_st
   wait_st
   zap_st
----------*/

simple_stmt
  : accept_st
  | assist_st
  | cancel_st
  | clear_st
  | continue_st
  | create_st
  | do_st
  | eject_st
  | erase_st
  | exit_st
  | export_st
  | find_st
  | import_st
  | input_st
  | insert_st
  | loop_st
  | modify_st
  | pack_st
  | public_st
  | quit_st
  | read_st
  | reindex_st
  | rename_st
  | restore_st
  | resume_st
  | retry_st
  | set_st
  | suspend_st
  | type_st
  | zap_st
  ;

advanced_stmt
  : docase_st
  | dowhile_st
  | if_st
  | join_st
  | select_st
  | sort_st
  ;

complex_stmt
  : append_st 
  | average_st 
  | browse_st 
  | change_st 
  | close_st 
  | copy_st
  | count_st 
  | delete_st 
  | dir_st 
  | display_st 
  | edit_st 
  | go_st 
  | help_st 
  | index_st 
  | label_st
  | list_st
  | locate_st
  | on_st
  | recall_st
  | release_st
  | replace_st
  | report_st
  | run_st
  | save_st
  | seek_st
  | skip_st
  | store_st
  | sum_st
  | text_st
  | total_st
  | update_st
  | use_st
  | wait_st
  ;

/* simple statements */

accept_st
  : ACCEPT STRING TO IDENTIFIER
  | ACCEPT        TO IDENTIFIER
  ;

assist_st
  : ASSIST
  ;

cancel_st
  : CANCEL
  ;

clear_st
  : CLEAR
  | CLEAR ALL
  | CLEAR FIELDS
  | CLEAR GETS
  | CLEAR MEMORY
  | CLEAR TYPEAHEAD
  ;

continue_st
  : CONTINUE
  ;

create_st
  : CREATE IDENTIFIER
  | CREATE LABEL IDENTIFIER
  | CREATE QUERY IDENTIFIER
  | CREATE REPORT IDENTIFIER
  | CREATE SCREEN IDENTIFIER
  | CREATE VIEW IDENTIFIER
  | CREATE VIEW IDENTIFIER FROM ENVIRONMENT
  ;

do_st
  : DO IDENTIFIER
  | DO IDENTIFIER WITH expr_list
  ;

eject_st
  : EJECT
  ;

erase_st
  : ERASE IDENTIFIER
  ;

exit_st
  : EXIT		%prec DOREDUCE
  ;

export_st
  : EXPORT TO IDENTIFIER TYPE PFS
  ;

find_st
  : FIND STRING
  ;

import_st
  : IMPORT FROM IDENTIFIER TYPE PFS
  ;

input_st
  : INPUT TO IDENTIFIER
  | INPUT STRING TO IDENTIFIER
  ;

insert_st
  : INSERT
  | INSERT BLANK
  | INSERT       BEFORE
  | INSERT BLANK BEFORE
  ;

loop_st
  : LOOP stmts ENDLOOP
  ;

modify_st
  : MODIFY COMMAND IDENTIFIER
  | MODIFY LABEL IDENTIFIER
  | MODIFY QUERY IDENTIFIER
  | MODIFY REPORT IDENTIFIER
  | MODIFY SCREEN IDENTIFIER
  | MODIFY STRUCTURE
  | MODIFY STRUCTURE IDENTIFIER
  | MODIFY VIEW IDENTIFIER
  ;

pack_st
  : PACK
  ;

public_st
  : PUBLIC identifier_list
  ;

quit_st
  : QUIT
  ;

read_st
  : READ
  | READ SAVE
  ;

reindex_st
  : REINDEX
  ;

rename_st
  : RENAME IDENTIFIER IDENTIFIER
  ;

restore_st
  : RESTORE FROM IDENTIFIER
  | RESTORE FROM IDENTIFIER ADDITIVE
  ;

resume_st
  : RESUME
  ;

retry_st
  : RETRY
  ;

set_st
  : SET
  | SET ALTERNATE on_off
  | SET ALTERNATE TO IDENTIFIER
  | SET BELL on_off
  | SET CARRY on_off
  | SET CATALOG on_off
  | SET CATALOG TO IDENTIFIER
  | SET COLOR TO color_codes
  | SET CONFIRM on_off
  | SET CONSOLE on_off
  | SET DATE date_type
  | SET DEBUG on_off
  | SET DECIMALS TO NUMBER
  | SET DEFAULT TO IDENTIFIER ':'
  | SET DELETED on_off
  | SET DELIMITER on_off
  | SET DELIMITER TO STRING
  | SET DELIMITER TO DEFAULT
  | SET DEVICE TO PRINTER
  | SET DEVICE TO SCREEN
  | SET DOHISTORY on_off
  | SET ECHO on_off
  | SET ESCAPE on_off
  | SET EXACT on_off
  | SET FIELDS on_off
  | SET FIELDS TO field_list
  | SET FIELDS TO ALL
  | SET FILLER TO condition
  | SET FILLER TO _FILE IDENTIFIER
  | SET FIXED on_off
  | SET FORMAT TO IDENTIFIER
  | SET FUNCTION NUMBER TO STRING
  | SET HEADING on_off
  | SET HISTORY TO expr
  | SET INDEX TO field_list
  | SET INTENSITY on_off
  | SET MARGIN TO expr
  | SET MEMOWIDTH TO expr
  | SET MENUS on_off
  | SET MESSAGE TO expr
  | SET PATH TO path
  | SET PRINT on_off
  | SET PRINTER TO devs
  | SET PROCEDURE TO IDENTIFIER
  | SET RELATION TO IDENTIFIER INTO IDENTIFIER
  | SET SAFETY on_off
  | SET STEP on_off
  | SET TALK on_off
  | SET TITLE on_off
  | SET TYPEAHEAD TO expr
  | SET UNIQUE on_off
  | SET VIEW TO IDENTIFIER
  ;

suspend_st
  : SUSPEND
  ;

type_st
  : TYPE IDENTIFIER
  | TYPE IDENTIFIER TO PRINT
  ;

zap_st
  : ZAP
  ;

/* advance statements */

docase_st
  : DO CASE cases ENDCASE
  | DO CASE cases OTHERWISE stmts ENDCASE
  ;

dowhile_st
  : DO WHILE condition stmts ENDDO
  ;

if_st
  : IF condition stmts ENDIF
  | IF condition stmts ELSE stmts ENDIF
  ;

join_st
  : JOIN WITH IDENTIFIER TO IDENTIFIER FOR condition
  | JOIN WITH IDENTIFIER TO IDENTIFIER FOR condition field_list
  ;

select_st
  : SELECT NUMBER
  | SELECT IDENTIFIER
  ;

sort_st
  : SORT ON IDENTIFIER sort_specs TO IDENTIFIER opt_scope opt_range_control
  ;

/* complex statements */

append_st
  : APPEND
  | APPEND BLANK
  | APPEND FROM IDENTIFIER opt_range_control opt_record_type
  ;

average_st
  : AVERAGE identifier_list opt_scope opt_range_control opt_identifier_list
  ;

browse_st
  : BROWSE opt_browse_control
  ;

change_st
  : CHANGE opt_scope opt_field_list opt_range_control opt_misc_controls
  ;

 
close_st
  : CLOSE file_type
  | CLOSE file_type ALL
  ;

copy_st
  : COPY _FILE IDENTIFIER TO IDENTIFIER
  | COPY STRUCTURE TO IDENTIFIER EXTENDED
  | COPY STRUCTURE TO IDENTIFIER opt_field_list
  | COPY TO IDENTIFIER opt_scope opt_field_list opt_range_control opt_record_type
  ;

count_st
  : COUNT opt_scope opt_range_control opt_identifier_list
  ;

delete_st
  : DELETE opt_scope opt_range_control
  ;

dir_st
  : DIR dir_spec
  ;

display_st
  : DISPLAY opt_scope opt_field_list opt_range_control opt_expr_list
  | DISPLAY HISTORY 
  | DISPLAY HISTORY LAST NUMBER
  | DISPLAY HISTORY             TO PRINT
  | DISPLAY HISTORY LAST NUMBER TO PRINT
  | DISPLAY MEMORY
  | DISPLAY MEMORY TO PRINT
  | DISPLAY STATUS
  | DISPLAY STATUS TO PRINT
  | DISPLAY STRUCTURE
  | DISPLAY STRUCTURE TO PRINT
  ;

edit_st
  : EDIT opt_scope opt_field_list opt_range_control opt_misc_controls
  ;

go_st
  : GO TOP
  | GO BOTTOM
  | GO expr
  | GOTO expr
  ;

/* ????? */

help_st
  : HELP
/*   | HELP <keyword> */
  ;

index_st
  : INDEX ON expr TO IDENTIFIER opt_index_controls
  | INDEX TAG IDENTIFIER OF IDENTIFIER opt_index_controls
  ;

label_st
  : LABEL FORM IDENTIFIER opt_label_control
  ;

list_st
  : LIST opt_scope opt_range_control opt_field_list
  | LIST opt_scope opt_range_control opt_field_list OFF
  | LIST opt_scope opt_range_control opt_field_list     TO PRINT
  | LIST opt_scope opt_range_control opt_field_list OFF TO PRINT
  | LIST MEMORY
  | LIST MEMORY TO PRINT
  | LIST STATUS
  | LIST STATUS TO PRINT
  | LIST STRUCTURE
  | LIST STRUCTURE TO PRINT
  ;

locate_st
  : LOCATE opt_scope opt_range_control
  ;

on_st
  : ON on_act
  ;

recall_st
  : RECALL opt_scope opt_range_control
  ;

release_st
  : RELEASE opt_release_control
  ;

replace_st
  : REPLACE opt_scope replacements opt_range_control
  ;

report_st
  : REPORT FORM IDENTIFIER opt_report_control
  ;

/* ????? dos_command */

run_st
  : RUN IDENTIFIER
  ;

save_st
  : SAVE TO IDENTIFIER
  | SAVE TO IDENTIFIER all_phrase
  ;


seek_st
  : SEEK expr
  ;

skip_st
  : SKIP expr
  ;

store_st
  : STORE expr TO identifier_list
  ;

sum_st
  : SUM opt_scope opt_expr_list TO identifier_list opt_range_control
  ;

text_st
  : TEXT string_list ENDTEXT
  ;

total_st
  : TOTAL TO IDENTIFIER ON IDENTIFIER opt_scope opt_field_list opt_range_control
  ;

update_st
  : UPDATE        ON IDENTIFIER FROM IDENTIFIER REPLACE replacements
  | UPDATE RANDOM ON IDENTIFIER FROM IDENTIFIER REPLACE replacements
  ;

use_st
  : USE            opt_use_control
  | USE IDENTIFIER opt_use_control
  ;

wait_st
  : WAIT STRING
  | WAIT STRING TO IDENTIFIER
  ;

/* end of statement rules */

/*
 * intermediate constructs for advance statements
 */

/* cases for docase statement */

cases
  : case
  | cases case
  ;

case
  : CASE condition stmts
  ;

/* conditional expressions */

condition
  : logical_constant
  | simple_condition
/*  | compound_condition */
  ;

logical_constant
  : FALSE
  | TRUE
  ;

simple_condition
  : expr '=' expr
  | expr '<' expr
  | expr '>' expr
  | expr NE expr
  | expr LE expr
  | expr GE expr
  ;

/* expressions */

expr
  : primary_expr
  | expr '+' expr
  | expr '-' expr
  | expr '*' expr
  | expr '/' expr
  ;

primary_expr
  : constant
  | IDENTIFIER
  | FUNCALL
  | '(' expr ')' 
  | '-' expr %prec UNARYMINUS
  ;

constant
  : NUMBER
  | STRING
  | CHARACTER
  ;

/* expression list, parameter list */

opt_expr_list
  :
  | expr_list
  ;

expr_list
  : expr
  | expr_list ',' expr
  ;

/* a list of fields */

field_list
  : FIELDS identifier_list
  ;

/* state sorting criteria */

sort_specs
  : sort_spec
  | sort_specs sort_spec
  ;

sort_spec
  : IDENTIFIER sort_order
  ;

sort_order
  : ASCENDING
  | DESCENDING
  ;

/* optional scope */

opt_scope
  :
  | scope
  ;

scope
  : ALL
  | RECORD NUMBER
  | NEXT NUMBER
  ;

/* optional index control */

opt_index_controls
  :
  | opt_index_controls index_control
  ;

index_control
  : UNIQUE
  | DESCENDING
  | DISTINCT
  ;

/* optional misc. control */

opt_misc_controls
  :
  | opt_misc_controls misc_control
  ;

misc_control
  : NOFOLLOW
  | NOINIT
  | NOMENU
  | NOCLEAR
  | NOAPPEND
  | NODELETE
  | NOEDIT
  ;

/* optional range control */

opt_range_control
  :
  | range_control
  ;

range_control
  : for_control
  | while_control
  ;

while_control
  : WHILE condition
  ;

for_control
  : FOR condition
  ;

/* end of constructs used to define advanced statements */

/*
 * constructs for complex statements
 */

/* optional record types */

opt_record_type
  :
  | TYPE record_type
  ;

record_type
  : SDF
  | DELIMITED
  | WKS
  | SYLK
  | DIF
  | dBASEII		/* dBase IV */
  | FW2			/* dBase IV */
  | RPD			/* dBase IV */
  ;

/* optional browse control */

opt_browse_control
  :
  | opt_browse_control browse_control
  ;

browse_control
  : field_list
  | lock_expr
  | freeze_field
  | width_expr
  | WINDOW IDENTIFIER		/* dBase IV */
  | NOINIT
  | NOEDIT
  | NOAPPEND
  | NODELETE
  | NOCLEAR
  | COMPRESS
  | FORMAT
  | NOFOLLOW
  | NOMENU
  ;

lock_expr
  : LOCK expr
  ;

width_expr
  : WIDTH expr
  ;

freeze_field
  : FREEZE IDENTIFIER
  ;

/* optional field list */

opt_field_list
  :
  | field_list
  ;

/* file types for close statement */

file_type
  : ALTERNATE
  | DATABASES
  | FORMAT
  | INDEX
  | PROCEDURE
  ;

/* device : path \ skeleton */

dir_spec
  : opt_device opt_path opt_skeleton
  ;

opt_device
  :
  | IDENTIFIER ':'
  ;

opt_path
  :
  | path
  ;

path
  : IDENTIFIER '\\'
  | path IDENTIFIER '\\'
  ;

opt_skeleton
  :
  | skeleton
  ;

skeleton
  : '?'
  | '*'
  ;

/* label options */

opt_label_control
  :
  | opt_label_control label_control
  ;

label_control
  : SAMPLE
  | scope
  | range_control
  | TO PRINT
  | TO _FILE IDENTIFIER
  ;

/* trigger for on statements */

on_act
  : ERROR expr
  | ESCAPE expr
  | KEY stmt
  ;

/* release options */

opt_release_control
  :
  | opt_release_control release_control
  ;

release_control
  : ':' identifier_list
  | all_phrase
  | MODULE IDENTIFIER
  ;

all_phrase
  : ALL
  | ALL LIKE skeleton
  | ALL EXCEPT skeleton
  ;

/* replacement specs for replace statement */

replacements
  : IDENTIFIER WITH expr
  | replacements IDENTIFIER WITH expr
  ;

/* options for report statement */

opt_report_control
  :
  | opt_report_control report_control
  ;

report_control
  : scope
  | range_control
  | PLAIN
  | HEADING STRING
  | NOEJECT
  | TO PRINT
  | TO _FILE IDENTIFIER
  | SUMMARY
  ;

/* string list */

string_list
  : STRING
  | string_list ',' STRING
  ;

/* options for use statement */

opt_use_control
  :
  | opt_use_control use_control
  ;

use_control
  : INDEX identifier_list
  | ALIAS IDENTIFIER
  | ALIAS EXCLUSIVE
  | IN NUMBER
  | ORDER IDENTIFIER
  | ORDER IDENTIFIER OF IDENTIFIER
  ;

/* end of constructs for complex statements */

/*
 * some stuff for simple statements
 */

on_off
  : ON
  | OFF
  ;

color_codes
  : color_code
  | color_codes ',' color_code
  ;

color_code
  : STANDARD
  | ENHANCED
  | BORDER
  | BACKGROUND
  ;

date_type
  : AMERICAN
  | ANSI
  | BRITISH
  | ITALIAN
  | JAPAN
  | FRENCH
  | GERMAN
  | USA
  ;

devs
  : LPT1
  | LPT2
  | COM1
  | COM2
  ;

/*********************************/

db4mod_stmt
  : append_mod
  | modify_mod
/*  | browse_mod, browse option controls, changed in place */
/*  | edit_mod, added control options, changed in place */
  | set_mod
/*  | change_mod, add control options */
  | create_mod
  | goto_mod
  | skip_mod
/*  | index_mod, best modified in place */
  | display_mod
  | list_mod
/*  | use_mod, use control options, changes in place */
/*  | replace_mod, no change on syntax */
  | onkey_mod
  ;

append_mod
  : APPEND FROM ARRAY IDENTIFIER
  | APPEND FROM ARRAY IDENTIFIER FOR condition
  | APPEND MEMO IDENTIFIER FROM IDENTIFIER
  | APPEND MEMO IDENTIFIER FROM IDENTIFIER OVERWRITE
  ;

modify_mod
  : MODIFY COMMAND IDENTIFIER WINDOW IDENTIFIER
  | MODIFY QUERY '?'
  | MODIFY VIEW  '?'
  | MODIFY APPLICATION IDENTIFIER
  | MODIFY APPLICATION '?'
  ;

set_mod
  : SET CARRY TO opt_field_list
  | SET CARRY TO opt_field_list ADDITIVE
  | SET FORMAT TO '?'
  | SET ALTERNATE TO IDENTIFIER ADDITIVE
  | SET FIELDS TO ALL LIKE skeleton
  | SET FIELDS TO ALL EXCEPT skeleton
  | SET DEVICE TO _FILE IDENTIFIER
  | SET BELL TO expr ',' expr
  | SET BELL TO
  ;

onkey_mod
  : ON KEY NUMBER stmt
/*  | ON KEY NUMBER */
  ;

create_mod
  : CREATE QUERY '?'
  | CREATE VIEW  '?'
  | CREATE APPLICATION IDENTIFIER
  | CREATE APPLICATION '?'
  ;

goto_mod
  : GO RECORD expr IN IDENTIFIER
  | GO RECORD expr
  | GO        expr IN IDENTIFIER
  | GOTO TOP
  | GOTO BOTTOM
  | GOTO RECORD expr IN IDENTIFIER
  | GOTO        expr IN IDENTIFIER
  | GOTO RECORD expr
  ;

skip_mod
  : SKIP
  | SKIP expr IN IDENTIFIER
  | SKIP      IN IDENTIFIER
  ;

display_mod
  : DISPLAY STRUCTURE IN IDENTIFIER
  | DISPLAY STRUCTURE IN IDENTIFIER TO PRINT
  | DISPLAY STRUCTURE TO _FILE IDENTIFIER  
  | DISPLAY MEMORY TO _FILE IDENTIFIER
  ;

list_mod
  : LIST STRUCTURE IN IDENTIFIER
  | LIST STRUCTURE IN IDENTIFIER TO PRINT
  | LIST STRUCTURE TO _FILE IDENTIFIER
  | LIST FILES opt_skeleton TO _FILE IDENTIFIER
  | LIST FILES opt_skeleton TO PRINT
  | LIST HISTORY opt_lastexpr TO _FILE IDENTIFIER
  | LIST HISTORY opt_lastexpr TO PRINT
  | LIST MEMORY TO _FILE IDENTIFIER
  | LIST STATUS TO _FILE IDENTIFIER
  ;

opt_lastexpr
  :
  | LAST expr
  ;

db4new_stmt
  : calculate_new
  | scan_new
  | set_new
  | copy_new
  | convert_new
  | on_new
  | play_new
  | save_new
  | restore_new
  ;

calculate_new
  : CALCULATE opt_scope opt_range_control cal_control TO identifier_list
  | CALCULATE opt_scope opt_range_control cal_control TO ARRAY IDENTIFIER
  ;

cal_control
  : NPV expr
  | STD expr
  | VAR expr
  | MIN expr
  | MAX expr
  | AVG expr
  | SUM expr
  | CNT expr
  ;

scan_new
  : SCAN opt_scope opt_range_control stmts LOOP stmts EXIT stmts ENDSCAN
  ;

copy_new
  : COPY INDEXES TO IDENTIFIER
  | COPY TAG tag_list TO IDENTIFIER
  ;
    
tag_list
  : tag
  | tag_list tag
  ;

tag
  : IDENTIFIER
  | IDENTIFIER OF IDENTIFIER
  ;

convert_new
  : CONVERT
  | CONVERT TO expr
  ;

on_new
  : ON READERROR stmt
  ;

play_new
  : PLAY MACRO IDENTIFIER
  ;

save_new
  : SAVE MACRO TO IDENTIFIER
  ;

restore_new
  : RESTORE MACRO FROM IDENTIFIER
  ;

set_new
  : SET SKIP TO identifier_list
  | SET WINDOW OF MEMO TO IDENTIFIER
  | SET AUTOSAVE on_off
  | SET DISPLAY TO display_attr
  | SET COLOR OF display_object TO color_codes
  | SET CLOCK ON
  | SET CLOCK TO NUMBER ',' NUMBER
  | SET INSTRUCT on_off
  | SET SPACE on_off
  | SET BORDER TO border_style
  | SET DESIGN on_off
  | SET DEVELOPMENT on_off
  | SET NEAR on_off
  | SET LOCK on_off
  | SET REFRESH TO expr
  | SET SQL on_off
  | SET PRECISION TO expr
  | SET POINT TO CHARACTER
  | SET SEPARATOR TO CHARACTER
  | SET CURRENCY TO CHARACTER
  ;

border_style
  : SINGLE
  | DOUBLE
  | PANEL
  | NONE
  | CHARACTER
  ;

display_object
  : TEXT
  | HEADING
  | STATUS
  | BOX
  | FIELD
  ;

display_attr
  : MONO43
  | EGA43
  | EGA25
  | MONO
  | COLOR
  ;


%%
    

