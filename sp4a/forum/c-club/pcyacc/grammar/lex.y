
/*-------------------------------------------------------------------*
 * PCLEX ----- Input Language Definition [grm.y]
 * Copyright(c) ABRAXAS SOFTWARE INC., 1989, all rights reserved
 *
 *   Typical Input Format:
 *     %{
 *     <include>
 *     %}
 *     <name> = "string"
 *     <name> = "string"
 *     %%
 *     <regular-expression> { <action> }
 *     <regular-expression> { <action> }
 *     %%
 *     <code>
 *-------------------------------------------------------------------*/

%{

#include	<stdio.h>
#include	<string.h>
#include	"global.h"
#include	"extern.h"

%}
   
%union {
  int   i;
  char *s;
  fa   *m;
}

/* Tokens */
%token BOL
%token CHARACTER
%token DEFVALUE
%token DELIMITER
%token EOL
%token IDENTIFIER
%token ITERATOR
%token LACT
%token LCURL
%token NEGCCL
%token POSCCL
%token SDEFINE
%token STRING
%token SUSE

/* Special symbols */
%token CHOICE
%token DOT
%token EQSIGN
%token LPAREN
%token ONEUP
%token OPTION
%token RCONTEXT
%token RPAREN
%token ZEROUP

/* For precedence */
%token CONCAT
%token RULE

/* Associativity */
%left RULE
%left SUSE RCONTEXT
%left CHOICE
%left EOL BOL
%left CHARACTER POSCCL NEGCCL STRING NULLS IDENTIFIER LPAREN DOT
%left ITERATOR
%left CONCAT
%left ZEROUP ONEUP OPTION

/* Data types of grammar symbols */
%type <s> IDENTIFIER DEFVALUE STRING POSCCL NEGCCL lact LACT
%type <i> CHARACTER
%type <m> rexpr rule

%start lexprog

%%

lexprog
  : defsec delim rulesec delim
  | defsec delim rulesec
  ;

defsec
  :
  | auxdefs
  ;

auxdefs
  : auxdef
  | auxdefs auxdef
  ;

rulesec
  : lact rules
  ;

lcurl
  : LCURL
  ;

delim
  : DELIMITER
  ;

auxdef
  : lcurl
  | SDEFINE IDENTIFIER
    {
    }
  | IDENTIFIER DEFVALUE
    {
    }
  | IDENTIFIER EQSIGN DEFVALUE
    {
    }
  ;

rules
  : ruleact
  | rules ruleact
  ;

ruleact  
  : rule lact
    {
    }
  ;

lact
  :
    {
    }
  | lact LACT
    {
    }
  ;

rule
  : rexpr		%prec RULE
    {
    }
  ;

rexpr
  : CHARACTER
    {
    }
  | STRING
    {
    }
  | POSCCL
    {
    }
  | NEGCCL
    {
    }
  | DOT
    {
    }
  | rexpr ITERATOR
    {
    }
  | rexpr ZEROUP
    {
    }
  | rexpr ONEUP
    {
    }
  | rexpr OPTION
    {
    }
  | SUSE rexpr
    {
    }
  | BOL rexpr
    {
    }
  | rexpr EOL
    {
    }
  | rexpr CHOICE rexpr
    {
    }
  | rexpr rexpr			%prec CONCAT
    {
    }
  | rexpr RCONTEXT rexpr
    {
    }
  | LPAREN rexpr RPAREN
    {
    }
  ;

%%


