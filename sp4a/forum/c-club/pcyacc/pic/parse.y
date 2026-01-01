
%{
#include <stdio.h>
#include "defs.h"
extern Object *new_object();
%}

%union {
  int   in;
  char *ch;
}

%token DRAW DEFINE                          /* verbs */
%token LINE BOX POLYGON CIRCLE ELLIPSE      /* shapes */
%token BLACK WHITE SOLID DOTTED FILL        /* attributes */
%token <ch> IDENTIFIER
%token <in> INTEGER

%start stats

%%

stats
  :
  | stats stat
  ;

stat
  : draw_stat ';'
  | define_stat ';'
  ;

draw_stat
  : DRAW IDENTIFIER
    { append_objlst(lookup($2)); }
  | DRAW object
    { append_objlst(new_object(&anObject)); }
  ;

define_stat
  : DEFINE IDENTIFIER '=' object
    { install($2, new_object(&anObject)); }
  ;

object
  : shape attrs '(' params ')'
  ;

shape
  : LINE    { anObject.shape = LINE; }
  | BOX     { anObject.shape = BOX;  }
  | POLYGON { anObject.shape = POLYGON; }
  | CIRCLE  { anObject.shape = CIRCLE; }
  | ELLIPSE { anObject.shape = ELLIPSE; }
  ;

attrs
  : 
  | attrs attr
  ;

attr
  : style
  | color
  | filling
  ;

style
  : SOLID  { anObject.style = SOLID; }
  | DOTTED { anObject.style = DOTTED; }
  ;

color
  : BLACK { anObject.color = BLACK; }
  | WHITE { anObject.color = WHITE; }
  ;

filling
  : FILL BLACK { anObject.fill = BLACK; }
  | FILL WHITE { anObject.fill = WHITE; }
  ;

params
  : point
  | params ',' point
  ;

point
  : INTEGER INTEGER
    { anObject.x_coord[anObject.npoints] = $1;
      anObject.y_coord[anObject.npoints++] = $2;
    }
  ;

