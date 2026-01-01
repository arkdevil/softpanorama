
/*====================================================================

  PCYACC grammar description file for HYPERTALK
  Copyright(c) Abraxas Software Inc. (R), 1988, All rights reserved
  Version 1.0,
  By Xing Liu, Sept 1988

  Reference: Hypertalk Programming, by Dan Shafer, Hayden Books, 1988

====================================================================*/

%union {
  int   i;
  float r;
  char  *s;
}

/*--------------------------------------------------------------------
  tokens
--------------------------------------------------------------------*/

%token ADD
%token AFTER
%token ALL
%token ANSWER
%token ASCENDING
%token ASK
%token AT
%token BARN
%token BEEP
%token BEFORE
%token BLACK
%token BLINDS
%token BUTTON
%token BY
%token CARD
%token CARDS
%token CHAR
%token CHARACTERS
%token CHARS
%token CHECKERBOARD
%token CHOOSE
%token CHUNK
%token CLICK
%token CLOSE
%token CONVERT
%token DATEITEMS
%token DATETIME
%token DELETE
%token DESCENDING
%token DIAL
%token DISSOLVE
%token DIVIDE
%token DO
%token DOMENU
%token DOOR
%token DOWNTO
%token DRAG
%token EDIT
%token EFFECT
%token ELSE
%token END
%token EXIT
%token FAST
%token FIELD
%token _FILE
%token FIND
%token FOR
%token FROM
%token FUNCTION
%token GET
%token GLOBAL
%token GO
%token GRAY
%token HELP
%token HIDE
%token HYPERCARD
%token IF
%token IN
%token INTERNATIONAL
%token INTO
%token INVERSE
%token IRIS
%token LINE
%token MODEM
%token MULTIPLY
%token NEXT
%token NUMERIC
%token OF
%token ON
%token OPEN
%token OR
%token PAINT
%token PASS
%token PASSWORD
%token PLAIN
%token PLAY
%token POINT
%token POP
%token PRINT
%token PRINTING
%token PUSH
%token PUT
%token READ
%token REPEAT
%token RESET
%token RETURN
%token SCRIPT
%token SCROLL
%token SECONDS
%token SEND
%token SET
%token SHOW
%token SLOW
%token SLOWLY
%token SORT
%token STACK
%token STOP
%token SUBTRACT
%token TEXT
%token THEN
%token TIMES
%token TO    
%token TOOL
%token TYPE
%token UNTIL
%token VENETIAN
%token VERY
%token VISUAL
%token WAIT
%token WHILE
%token WHITE
%token WIPE
%token WITH
%token WORD
%token WRITE
%token ZOOM

%token IDENTIFIER
%token NUMBER
%token STRING

%token COMMANDKEY
%token OPTIONKEY
%token SHIFTKEY

%token AND
%token CONTAINS
%token DIV
%token IS	
%token ISNOTIN
%token NOT
%token OR
%token MOD

%left OR
%left AND
%left NOT

%nonassoc '<' '>' '=' LE GE NE IS ISNOT CONTAINS ISNOTIN

%left '+' '-' '&' AND2
%left '*' '/' DIV MOD

%right '^'

%nonassoc POS NEG

%start script

%%

script
  :
  | script handler
  ;

handler
  : event_handler
  | function_handler
  ;

event_handler
  : ON IDENTIFIER commands END IDENTIFIER
  ;

function_handler
  : FUNCTION IDENTIFIER commands END IDENTIFIER
  ;

commands
  : command
  | commands command
  ;

command
  : add
  | answer
  | ask
  | beep
  | choose
  | click
  | close
  | convert
  | delete
  | dial
  | divide
  | do
  | domenu
  | drag
  | editscript
  | exitrepeat
  | exittohypercard
  | find
  | get
  | global
  | go
  | help
  | hide
  | if
  | multiply
  | nextrepeat
  | open
  | pass
  | play
  | pop
  | print
  | push
  | put
  | read
  | repeat
  | reset
  | return
  | send
  | set
  | show
  | sort
  | subtract
  | type
  | visual
  | wait
  | write
  ;

add
  : ADD NUMBER TO IDENTIFIER
  ;

answer		
  : ANSWER STRING
  | ANSWER STRING WITH STRING
  | ANSWER STRING WITH STRING OR STRING
  | ANSWER STRING WITH STRING OR STRING OR STRING
  ;

ask
  : ASK          STRING
  | ASK          STRING WITH STRING
  | ASK PASSWORD STRING
  | ASK PASSWORD STRING WITH STRING
  ;

beep
  : BEEP NUMBER
  ;

choose
  : CHOOSE IDENTIFIER TOOL
  ;

click
  : CLICK AT expression
  | CLICK AT expression WITH key
  | CLICK AT expression BUTTON STRING
  ;

key
  : OPTIONKEY
  | SHIFTKEY
  | COMMANDKEY
  ;

close
  : CLOSE PRINTING
  ;

convert
  : CONVERT IDENTIFIER TO DATEITEMS
  ;

delete
  : DELETE expression
  | DELETE expression OF CARD
  ;

dial
  : DIAL NUMBER
  | DIAL NUMBER WITH MODEM STRING
  | DIAL NUMBER WITH MODEM
  | DIAL NUMBER WITH       STRING
  ;

divide
  : DIVIDE IDENTIFIER BY NUMBER
  ;

do
  : DO STRING
  ;

domenu
  : DOMENU STRING
  ;

drag
  : DRAG FROM expression TO expression
  | DRAG FROM expression TO expression WITH key
  ;

editscript
  : EDIT SCRIPT OF expression
  ;

exitrepeat
  : EXIT REPEAT
  ;

exittohypercard
  : EXIT TO HYPERCARD
  ;

find
  : FIND            expression
  | FIND            expression IN FIELD IDENTIFIER
  | FIND CHARS      expression
  | FIND CHARS      expression IN FIELD IDENTIFIER
  | FIND CHARACTERS expression
  | FIND CHARACTERS expression IN FIELD IDENTIFIER
  | FIND WORD       expression
  | FIND WORD       expression IN FIELD IDENTIFIER
  ;

get
  : GET expression
  ;

global
  : GLOBAL name_list
  ;

name_list
  : IDENTIFIER
  | name_list ',' IDENTIFIER
  ;

go
  : goto IDENTIFIER
  | goto STACK IDENTIFIER
  | goto IDENTIFIER OF IDENTIFIER
  | goto IDENTIFIER OF IDENTIFIER OF IDENTIFIER
  ;

goto
  : GO
  | GO TO
  ;

help
  : HELP
  ;

hide
  : HIDE expression
  ;

if
  : IF expression THEN commands END IF
  | IF expression THEN commands ELSE commands END IF
  ;

multiply
  : MULTIPLY IDENTIFIER BY NUMBER
  ;

nextrepeat
  : NEXT REPEAT
  ;

open
  : OPEN _FILE IDENTIFIER
  | OPEN PRINTING
  | OPEN PRINTING WITH STRING
  ;

pass
  : PASS IDENTIFIER
  ;

play
  : PLAY STRING expression NUMBER PLAY STOP
  | PLAY STRING expression        PLAY STOP
  | PLAY STRING            NUMBER PLAY STOP
  | PLAY STRING                   PLAY STOP
  ;

pop
  : POP CARD 
  | POP CARD preposition IDENTIFIER
  ;

preposition
  : INTO
  | BEFORE
  | AFTER
  ;

print
  : PRINT CARD
  ;

push
  : PUSH CARD
  ;

put
  : PUT expression preposition IDENTIFIER
  | PUT expression
  | PUT            preposition IDENTIFIER
  | PUT
  ;

read
  : READ FROM IDENTIFIER
  | READ FROM IDENTIFIER read_control
  ;

read_control
  : UNTIL STRING
  | FOR NUMBER
  ;

repeat
  : REPEAT FOR NUMBER TIMES commands END REPEAT
  | REPEAT     NUMBER TIMES commands END REPEAT
  | REPEAT     NUMBER       commands END REPEAT
  | REPEAT WITH IDENTIFIER '=' NUMBER TO     NUMBER commands END REPEAT
  | REPEAT WITH IDENTIFIER '=' NUMBER DOWNTO NUMBER commands END REPEAT
  | REPEAT WHILE expression                         commands END REPEAT
  | REPEAT UNTIL expression                         commands END REPEAT
  | REPEAT
  ;

reset
  : RESET PAINT
  ;

return
  : RETURN expression
  ;

send
  : SEND IDENTIFIER expression_list TO expression
  | SEND IDENTIFIER                 TO expression
  ;

set
  : SET IDENTIFIER OF expression TO expression
  ;

show
  : SHOW expression
  | SHOW expression AT expression
  | SHOW NUMBER CARDS
  | SHOW ALL    CARDS
  ;

sort
  : SORT sortorder sorttype BY expression
  | SORT           sorttype BY expression
  | SORT sortorder          BY expression
  | SORT                    BY expression
  ;

sortorder
  : ASCENDING
  | DESCENDING
  ;

sorttype
  : TEXT
  | NUMERIC
  | DATETIME
  | INTERNATIONAL
  ;

subtract
  : SUBTRACT NUMBER FROM IDENTIFIER
  ;

type
  : TYPE STRING
  | TYPE STRING WITH key
  ;

visual
  : visualeffect effect_name speed TO image
  | visualeffect effect_name speed
  | visualeffect effect_name       TO image
  | visualeffect effect_name
  ;

effect_name
  : WIPE
  | SCROLL
  | ZOOM
  | IRIS
  | BARN DOOR
  | DISSOLVE
  | CHECKERBOARD
  | VENETIAN BLINDS
  | PLAIN
  ;

speed
  : VERY slow
  | slow
  | FAST
  | VERY FAST
  ;

image
  : BLACK
  | WHITE
  | GRAY
  | INVERSE
  | CARD
  ;

slow
  : SLOW
  | SLOWLY
  ;
  
visualeffect
  : VISUAL
  | VISUAL EFFECT
  ;

wait
  : WAIT FOR NUMBER SECONDS
  | WAIT     NUMBER SECONDS
  | WAIT FOR NUMBER
  | WAIT     NUMBER
  | WAIT UNTIL expression
  | WAIT WHILE expression
  ;

write
  : WRITE STRING TO _FILE IDENTIFIER
  ;

expression_list
  : expression
  | expression_list ',' expression
  ;

expression
  : primary
  | expression '+'      expression
  | expression '-'      expression
  | expression '*'      expression
  | expression '/'      expression
  | expression '^'      expression
  | expression '&'      expression
  | expression AND2     expression
  | expression '='      expression
  | expression NE       expression
  | expression '<'      expression
  | expression '>'      expression
  | expression LE       expression
  | expression GE       expression
  | expression DIV      expression
  | expression MOD      expression
  | expression AND      expression
  | expression OR       expression
  | expression CONTAINS expression
  | expression ISNOTIN  expression
  | expression IS       expression
  | expression ISNOT    expression
  ;

primary
  : IDENTIFIER
  | constant
  | '-' primary %prec NEG
  | '+' primary
  | NOT primary
  | IDENTIFIER '('                 ')'
  | IDENTIFIER '(' expression_list ')'
  | '(' expression ')'
  ;

constant
  : NUMBER
  | STRING
  ;

/*--------------------------------------------------------------------
  end of grammar section
--------------------------------------------------------------------*/

