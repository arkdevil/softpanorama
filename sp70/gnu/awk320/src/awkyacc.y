%{
/*
 * Awk syntactical analyser and pseudo code generator
 *
 * Copyright (C) 1988, 1989, 1990, 1991 by Rob Duff
 * All rights reserved
 */
#include <stddef.h>
#include <alloc.h>
#include <mem.h>

#include "awk.h"
#include "awklex.h"
%}
%union
{
    int     ival;
    double  dval;
    char   *sptr;
    FUNC   *uptr;
    void   *vptr;
}

%token T_EOF
%token T_EOL
%token T_BEGIN
%token T_END
%token T_IF
%token T_ELSE
%token T_FOR
%token T_DO
%token T_DONE
%token T_WHILE
%token T_BREAK
%token T_CONTINUE
%token T_FUNCTION
%token T_RETURN
%token T_NEXT
%token T_EXIT

%token T_PRINT
%token T_PRINTF

%token T_INDEX
%token T_SRAND
%token T_CLOSE
%token T_SPLIT
%token T_MATCH
%token T_DELETE
%token T_SUBSTR
%token T_SPRINTF

%token T_GETLINE

%token <ival> T_SUB
%token <vptr> T_USER
%token <vptr> T_NAME
%token <sptr> T_SCON
%token <dval> T_DCON
%token <ival> T_FUNC0
%token <ival> T_FUNC1
%token <ival> T_FUNC2

%right T_CREATE T_APPEND
%right <ival> T_STORE
%left '?' ':'
%nonassoc T_LIOR
%nonassoc T_LAND
%nonassoc T_IN
%nonassoc '~' T_NOMATCH
%nonassoc <ival> T_RELOP '<' '>'
%left T_CONCAT
%left '+' '-'
%left '*' '/'
%right T_SIGN
%right '!'
%right '^'
%left <ival> T_INCOP
%right '$'
%nonassoc T_GROUP

%type <ival> pattern_expression pattern_disjunction pattern_conjunction
%type <ival> expression print_expression conditional print_conditional 
%type <ival> print_disjunction disjunction conjunction print_conjunction 
%type <ival> membership print_membership match print_match
%type <ival> match_relation relation match_concatenation
%type <ival> concatenation arithmetic term unary exponential factor
%type <ival> optional_argument_list optional_expression
%type <ival> optional_print_list expression_list print_expression_list
%type <ival> field_zero_match regular_expression
%type <uptr> declaration
%type <vptr> body action pattern pattern_predicate
%type <vptr> optional_parameter_list parameter_list
%%
pattern_action_list:
    pattern_action_list eos pattern_action
|   pattern_action
;
pattern_action:
    T_FUNCTION declaration body {
        yydisplay = NULL;
        $2->pcode = $3;
    }
|    T_BEGIN action {
        if (beginend == NULL)
            beginact = beginend = genact($2);
        else
            beginend = beginend->cnext = genact($2);
    }
|   T_END action {
        if (endend == NULL)
            endact = endend = genact($2);
        else
            endend = endend->cnext = genact($2);
    }
|   pattern action {
        enroll($1, $2);
    }
|   pattern {
        genfield(0);
        lastop(C_PLUCK);
        genfcon(0);
        gencall(P_PRINT, 2);
        genbyte(C_END);
        enroll($1, gencode());
    }
|   action {
        enroll(genrule(NULL, NULL), $1);
    }
|
;
declaration:
    T_USER '(' optional_parameter_list ')' {
        yydisplay = $3;
        $$ = ((IDENT*)($1))->vfunc = newfunction();
    }
;
optional_parameter_list:
    parameter_list {
        $$ = $1;
    }
|   {
        $$ = 0;
    }
;
parameter_list:
    parameter_list comma T_NAME {
        $$ = newelement($1, $3);
    }
|   T_NAME {
        $$ = newelement(NULL, $1);
    }
;
body:
    '{' {
        pushstack(L_MARK);
    } statement_list '}' {
        popstack(L_MARK);
        if (stacktop != stackbot + MAXSTACK)
            yyerror("body jump stack");
        if (lastcode() != C_RETURN) {
            genaddr(lookfor(nul));
            genbyte(C_LOAD);
            genbyte(C_RETURN);
        }
        genbyte(C_END);
        $$ = gencode();
    }
;
pattern:
    pattern_predicate comma pattern_predicate {
        $$ = genrule($1, $3);
    }
|   pattern_predicate {
        $$ = genrule($1, NULL);
    }
;
pattern_predicate:
    pattern_disjunction {
        genbyte(C_END);
        $$ = gencode();
    }
;
pattern_disjunction:
    pattern_conjunction
|   pattern_disjunction T_LIOR eol {
        yyl1 = getlabel();
        pushlabel(L_NORMAL, yyl1);
        genjump(C_OJMP, yyl1);
    } pattern_conjunction {
        yyl1 = poplabel();
        genlabel(yyl1);
        putlabel(yyl1);
        $$ = S_LONG;
    }
;
pattern_conjunction:
    pattern_expression
|   pattern_conjunction T_LAND eol {
        yyl1 = getlabel();
        pushlabel(L_NORMAL, yyl1);
        genjump(C_AJMP, yyl1);
    } pattern_expression {
        yyl1 = poplabel();
        genlabel(yyl1);
        putlabel(yyl1);
        $$ = S_LONG;
    }
;
pattern_expression:
    field_zero_match
|   '!' field_zero_match {
        genbyte(C_NOT);
        $$ = S_SHORT;
    }
|   '(' pattern_disjunction ')' {
        $$ = $2;
    }
|   '!' '(' pattern_disjunction ')' {
        genbyte(C_NOT);
        $$ = S_SHORT;
    }
|   membership
;
field_zero_match:
    regular_expression {
        genfield(0);
        lastop(C_PLUCK);
        genbyte(C_SWAP);
        genbyte(C_MAT);
        $$ = S_SHORT;
    }
;
action:
    '{' {
        pushstack(L_MARK);
    } statement_list '}' {
        popstack(L_MARK);
        if (stacktop != stackbot + MAXSTACK)
            yyerror("action jump stack");
        genbyte(C_END);
        $$ = gencode();
    }
;
statement_list:
    statement_list eos else_part
|   statement
;
else_part:
    T_ELSE eol {
        yyl1 = toploop(L_ELSE);
        if (yyl1 < 0)
            yyerror("syntax error");
        yyl1 = getloop(L_ELSE);
        pushlabel(L_ELSE, yyl1);
        yyl2 = getlabel();
        genjump(C_JUMP, yyl2);
        genlabel(yyl1);
        uselabel(yyl1, yyl2);
        putlabel(yyl2);
    } statement
|   {
        while (stackptr->sclass >= L_FOR)
            popstack(stackptr->sclass);
    } statement
;
statement:
    expression {
        gendrop();
    }
|   '{' {
        pushstack(L_MARK);
    } statement_list {
        popstack(L_MARK);
    } '}'
|   T_IF '(' expression ')' eol {
        yyl1 = getlabel();
        pushlabel(L_ELSE, yyl1);
        genjump(C_FJMP, yyl1);
    } statement
|   T_WHILE {
        yyl1 = getlabel();
        yyl2 = getlabel();
        pushlabel(L_BREAK, yyl1);
        pushlabel(L_CONTINUE, yyl2);
        pushstack(L_WHILE);
        genlabel(yyl2);
    } '(' expression ')' eol {
        yyl1 = toploop(L_BREAK);
        genjump(C_FJMP, yyl1);
    } statement
|   T_DO eol {
        yyl1 = getlabel();
        yyl2 = getlabel();
        yyl3 = getlabel();
        pushlabel(L_NORMAL, yyl1);
        pushlabel(L_BREAK, yyl2);
        pushlabel(L_CONTINUE, yyl3);
        pushstack(L_DONE);
        genlabel(yyl1);
        yydone = 1;
    } statement
|   T_DONE {
        popstack(L_DONE);
        yyl1 = toploop(L_CONTINUE);
        genlabel(yyl1);
        yydone = 0;
    } '(' expression ')' {
        yyl1 = poplabel();
        yyl2 = poplabel();
        yyl3 = poplabel();
        genjump(C_TJMP, yyl3);
        genlabel(yyl2);
        putlabel(yyl1);
        putlabel(yyl2);
        putlabel(yyl3);
    }
|   T_FOR '(' variable T_IN variable_name ')' eol {
        yyl1 = getlabel();
        yyl2 = getlabel();
        pushlabel(L_BREAK, yyl1);
        pushlabel(L_CONTINUE, yyl2);
        pushstack(L_FOR);
        genbyte(C_LOAD);
        genlabel(yyl2);
        genjump(C_IJMP, yyl1);
    } statement
|   T_FOR '(' optional_statement ';' {
        yyl1 = getlabel();
        yyl2 = getlabel();
        pushlabel(L_BREAK, yyl1);
        pushlabel(L_CONTINUE, yyl2);
        pushstack(L_FOR);
        yyl1 = getlabel();
        yyl2 = getlabel();
        pushlabel(L_NORMAL, yyl1);
        pushlabel(L_NORMAL, yyl2);
        genlabel(yyl1);
    } for_test
|   T_BREAK {
        yyl1 = toploop(L_BREAK);
        if (yyl1 < 0) {
            yyerror("invalid break");
            YYERROR;
        }
        genjump(C_JUMP, yyl1);
    }
|   T_CONTINUE {
        yyl1 = toploop(L_CONTINUE);
        if (yyl1 < 0) {
            yyerror("invalid continue");
            YYERROR;
        }
        genjump(C_JUMP, yyl1);
    }
|   T_RETURN return_expression {
        genbyte(C_RETURN);
    }
|   T_SRAND '(' optional_expression ')' {
        gencall(P_SRAND, $3);
    }
|   T_PRINT '(' expression_list ')' output_file {
        gencall(P_PRINT, $3+1);
    }
|   T_PRINT optional_print_list output_file {
        gencall(P_PRINT, $2+1);
    }
|   T_PRINTF '(' expression_list ')' output_file {
        gencall(P_PRINTF, $3+1);
    }
|   T_PRINTF print_expression_list output_file {
        gencall(P_PRINTF, $2+1);
    }
|   T_CLOSE '('  expression ')' {
        gencall(P_CLOSE, 1);
    }
|   T_DELETE variable_name '[' expression_list ']' {
        if ($4 > 1)
            gencall(P_JOIN, $4);
        gencall(P_DELETE, 2);
    }
|   T_NEXT {
        gencall(P_NEXT, 0);
    }
|   T_EXIT optional_expression {
        gencall(P_EXIT, $2);
    }
|
;
optional_expression:
    expression {
        $$ = 1;
    }
|   {
        $$ = 0;
    }
;
for_test:
    ';' {
        yyl1 = toploop(L_NORMAL);
        yyl2 = toploop(L_CONTINUE);
        genjump(C_JUMP, yyl1);
        genlabel(yyl2);
    } optional_statement ')' eol {
        yyl1 = poplabel();
        yyl2 = poplabel();
        genlabel(yyl1);
        putlabel(yyl1);
        putlabel(yyl2);
    } statement
|   expression ';' {
        yyl1 = toploop(L_BREAK);
        genjump(C_FJMP, yyl1);
    } for_next
;
for_next:
    ')' eol {
        yyl1 = poplabel();
        yyl2 = poplabel();
        yyl3 = toploop(L_CONTINUE);
        uselabel(yyl3, yyl2);
        putlabel(yyl1);
        putlabel(yyl2);
    } statement
|   {
        yyl1 = toploop(L_NORMAL);
        yyl2 = toploop(L_CONTINUE);
        genjump(C_JUMP, yyl1);
        genlabel(yyl2);
    } expression ')' eol {
        yyl1 = poplabel();
        yyl2 = poplabel();
        gendrop();
        genjump(C_JUMP, yyl2);
        genlabel(yyl1);
        putlabel(yyl1);
        putlabel(yyl2);
    } statement
;
optional_statement:
    expression {
        gendrop();
    }
|
;
optional_print_list:
    print_expression_list {
        $$ = $1;
    }
|   {
        genfield(0);
        lastop(C_PLUCK);
        $$ = 1;
    }
;
return_expression:
    expression
|   {
        genaddr(lookfor(nul));
        genbyte(C_LOAD);
    }
;
output_file:
    '>' factor {
        gencall(P_CREATE, 1);
    }
|   T_APPEND factor {
        gencall(P_APPEND, 1);
    }
|   {
        genfcon(0);
    }
;
input_file:
    '<' factor {
        gencall(P_OPEN, 1);
    }
|   {
        genfcon(1);
    }
;
regular_expression:
    '/' {
        genrcon(regexp(1));
        $$ = S_REGEXP;
    }
;
print_expression:
    variable T_STORE print_expression {
        genstore($2);
        $$ = $3;
    }
|   print_conditional
;
print_conditional:
    print_disjunction {
        if ($1 == S_LONG)
            genbyte(C_IS);
        $$ = S_SHORT;
    }
|   print_disjunction '?' {
        yyl1 = getlabel();
        yyl2 = getlabel();
        pushlabel(L_NORMAL, yyl1);
        pushlabel(L_NORMAL, yyl2);
        genjump(C_FJMP, yyl2);
    } print_expression ':' {
        yyl1 = poplabel();
        yyl2 = toploop(L_NORMAL);
        genjump(C_JUMP, yyl2);
        genlabel(yyl1);
        putlabel(yyl1);
    } print_expression {
        yyl1 = poplabel();
        genlabel(yyl1);
        putlabel(yyl1);
        $$ = S_NUMBER;
    }
;
print_disjunction:
    print_conjunction
|   print_disjunction T_LIOR eol {
        yyl1 = getlabel();
        pushlabel(L_NORMAL, yyl1);
        genjump(C_OJMP, yyl1);
    } print_conjunction {
        yyl1 = poplabel();
        genlabel(yyl1);
        putlabel(yyl1);
        $$ = S_LONG;
    }
;
print_conjunction:
    print_membership
|   print_conjunction T_LAND eol {
        yyl1 = getlabel();
        pushlabel(L_NORMAL, yyl1);
        genjump(C_AJMP, yyl1);
    } print_membership {
        yyl1 = poplabel();
        genlabel(yyl1);
        putlabel(yyl1);
        $$ = S_LONG;
    }
;
print_membership:
   '(' expression_list ')' T_IN {
        if ($2 > 1)
            gencall(P_JOIN, $2);
    } variable_name {
        genbyte(C_IN);
        $$ = S_SHORT;
    }
|   print_match T_IN variable_name {
        genbyte(C_IN);
        $$ = S_SHORT;
    }
|   print_match
;
print_match:
    concatenation
|   concatenation '~' match_concatenation {
        genbyte(C_MAT);
        $$ = S_SHORT;
    }
|   concatenation T_NOMATCH match_concatenation {
        genbyte(C_MAT);
        genbyte(C_NOT);
        $$ = S_SHORT;
    }
;
match_concatenation:
    regular_expression
|   concatenation
;
print_expression_list:
    print_expression_list comma print_expression {
        $$ = $1 + 1;
    }
|   print_expression {
        $$ = 1;
    }
;
expression:
    variable T_STORE expression {
        genstore($2);
        $$ = $3;
    }
|   conditional
;
conditional:
    disjunction {
        if ($1 == S_LONG)
            genbyte(C_IS);
        $$ = S_SHORT;
    }
|   disjunction '?' {
        yyl1 = getlabel();
        yyl2 = getlabel();
        pushlabel(L_NORMAL, yyl1);
        pushlabel(L_NORMAL, yyl2);
        genjump(C_FJMP, yyl2);
    } expression ':' {
        yyl1 = poplabel();
        yyl2 = toploop(L_NORMAL);
        genjump(C_JUMP, yyl2);
        genlabel(yyl1);
        putlabel(yyl1);
    } expression {
        yyl1 = poplabel();
        genlabel(yyl1);
        putlabel(yyl1);
        $$ = S_NUMBER;
    }
;
disjunction:
    conjunction
|   disjunction T_LIOR eol {
        yyl1 = getlabel();
        pushlabel(L_NORMAL, yyl1);
        genjump(C_OJMP, yyl1);
    } conjunction {
        yyl1 = poplabel();
        genlabel(yyl1);
        putlabel(yyl1);
        $$ = S_LONG;
    }
;
conjunction:
    membership
|   conjunction T_LAND eol {
        yyl1 = getlabel();
        pushlabel(L_NORMAL, yyl1);
        genjump(C_AJMP, yyl1);
    } membership {
        yyl1 = poplabel();
        genlabel(yyl1);
        putlabel(yyl1);
        $$ = S_LONG;
    }
;
membership:
   '(' expression_list ')' T_IN {
        if ($2 > 1)
            gencall(P_JOIN, $2);
    } variable_name {
        genbyte(C_IN);
        $$ = S_SHORT;
    }
|   match T_IN variable_name {
        genbyte(C_IN);
        $$ = S_SHORT;
    }
|   match
;
match:
    relation
|   relation '~' match_relation {
        genbyte(C_MAT);
        $$ = S_SHORT;
    }
|   relation T_NOMATCH match_relation {
        genbyte(C_MAT);
        genbyte(C_NOT);
        $$ = S_SHORT;
    }
;
relation:
    concatenation
|   concatenation T_RELOP concatenation {
        genbyte($2);
        $$ = S_SHORT;
    }
|   concatenation '<' concatenation {
        genbyte(C_LT);
        $$ = S_SHORT;
    }
|   concatenation '>' concatenation {
        genbyte(C_GT);
        $$ = S_SHORT;
    }
;
concatenation:
    arithmetic
|   concatenation arithmetic {
        genbyte(C_CAT);
        $$ = S_STRING;
    }
;
arithmetic:
    term
|   arithmetic '+' term {
        genbyte(C_ADD);
        $$ = S_DOUBLE;
    }
|   arithmetic '-' term {
        genbyte(C_SUB);
        $$ = S_DOUBLE;
    }
;
term:
    unary
|   term '*' unary {
        genbyte(C_MUL);
        $$ = S_DOUBLE;
    }
|   term '/' unary {
        genbyte(C_DIV);
        $$ = S_DOUBLE;
    }
|   term '%' unary {
        genbyte(C_MOD);
        $$ = S_DOUBLE;
    }
;
unary:
    exponential
|   '!' exponential {
        genbyte(C_NOT);
        $$ = S_DOUBLE;
    }
|   '-' exponential %prec T_SIGN {
        genbyte(C_NEG);
        $$ = S_DOUBLE;
    }
|   '+' exponential %prec T_SIGN {
        genbyte(C_NUM);
        $$ = S_DOUBLE;
    }
;
exponential:
    factor
|   factor '^' exponential {
        genbyte(C_POW);
        $$ = S_DOUBLE;
    }
;
factor:
    T_INCOP variable {
        gentwo(C__PRE, $1);
        $$ = S_DOUBLE;
    }
|   variable T_INCOP {
        gentwo(C__POST, $2);
        $$ = S_DOUBLE;
    }
|   variable {
        if (lastcode() == C_ADDR)
            lastop(C_FETCH);
        else if (lastcode() == C_FIELD)
            lastop(C_PLUCK);
        else
            genbyte(C_LOAD);
        $$ = S_NUMBER;
    }
|   '(' expression ')' %prec T_GROUP {
        $$ = S_NUMBER;
    }
|   T_DCON {
        gendcon($1);
        $$ = S_DOUBLE;
    }
|   T_SCON {
        genscon($1);
        $$ = S_STRING;
    }
|   T_USER '(' optional_argument_list ')' {
        genuser($1, $3);
        $$ = S_NUMBER;
    }
|   T_FUNC0 '(' ')' {
        genbyte($1);
        $$ = S_NUMBER;
    }
|   T_FUNC1 '(' expression ')' {
        genbyte($1);
        $$ = S_NUMBER;
    }
|   T_FUNC2 '(' expression comma expression ')' {
        genbyte($1);
        $$ = S_NUMBER;
    }
|   T_SUB '(' match_expression comma expression ')' {
        genfield(0);
        genfield(0);
        lastop(C_PLUCK);
        gencall($1, 4);
        $$ = S_STRING;
    }
|   T_SUB '(' match_expression comma expression comma variable ')' {
        genbyte(C_DUP);
        genbyte(C_LOAD);
        gencall($1, 4);
        $$ = S_STRING;
    }
|   T_SUB '(' match_expression comma expression comma expression ')' {
        genaddr(lookfor(nul));
        genbyte(C_SWAP);
        gencall($1, 4);
        $$ = S_STRING;
    }
|   T_SPLIT '(' expression comma variable_name ')' {
        genaddr(lookfor(fs));
        genbyte(C_LOAD);
        gencall(P_SPLIT, 3);
        $$ = S_DOUBLE;
    }
|   T_SPLIT '(' expression comma variable_name comma expression ')' {
        gencall(P_SPLIT, 3);
        $$ = S_DOUBLE;
    }
|   T_MATCH '(' expression comma match_expression ')' {
        gencall(P_MATCH, 2);
        $$ = S_SHORT;
    }
|   T_INDEX '(' expression ')' {
        genfield(0);
        lastop(C_PLUCK);
        genbyte(C_SWAP);
        gencall(P_INDEX, 2);
        $$ = S_DOUBLE;
    }
|   T_INDEX '(' expression comma expression ')' {
        gencall(P_INDEX, 2);
        $$ = S_DOUBLE;
    }
|   T_SUBSTR '(' expression comma expression ')' {
        gencall(P_SUBSTR, 2);
        $$ = S_STRING;
    }
|   T_SUBSTR '(' expression comma expression comma expression ')' {
        gencall(P_SUBSTR, 3);
        $$ = S_STRING;
    }
|   T_SPRINTF '(' expression_list ')' {
        gencall(P_SPRINTF, $3);
        $$ = S_DOUBLE;
    }
|   T_GETLINE variable input_file {
        gencall(P_GETLINE, 2);
        $$ = S_DOUBLE;
    }
|   T_GETLINE input_file {
        genfield(0);
        genbyte(C_SWAP);
        gencall(P_GETLINE, 2);
        $$ = S_DOUBLE;
    }
;
match_relation:
    regular_expression
|   relation
;
match_expression:
    regular_expression
|   expression
;
expression_list:
    expression_list comma expression {
        $$ = $1 + 1;
    }
|   expression {
        $$ = 1;
    }
;
optional_argument_list:
    expression_list {
        $$ = $1;
    }
|   {
        $$ = 0;
    }
;
variable:
    '$' factor {
        if (lastcode() == C_DCON)
            genfield(lastdcon());
        else
            genbyte(C_DOLAR);
    }
|   variable_name '[' expression_list ']' {
        if ($3 > 1)
            gencall(P_JOIN, $3);
        genbyte(C_SELECT);
    }
|   variable_name
;
variable_name:
    T_NAME {
        genaddr($1);
    }
;
comma:
    ',' eol
;
eos:
    ';'
|   T_EOL
;
eol:
    T_EOL
|
;
%%
int     yydone;
int     yyl1, yyl2, yyl3;
LIST    *yydisplay;

static int toploop(int);
static int getloop(int);
static int poplabel(void);

static void popstack(int);
static void pushstack(int);
static void pushlabel(int, int);

static void enroll(void*, void*);

static void *newfunction(void);
static void *newelement(void*, void*);

IDENT *lookfor(ITEM *sp)
{
    IDENT *vp;

    for (vp = ident; vp != NULL; vp = vp->vnext)
        if (vp->vitem == sp)
            return vp;
    return NULL;
}

static void enroll(rule, action)
void *rule;
void *action;
{
    if (rulep == NULL) {
        rulep = rule;
        rules = rulep;
    }
    else {
        rulep->next = rule;
        rulep = rule;
    }
    rulep->next = NULL;
    rulep->action = action;
}

static void*
newelement(next, item)
void *next;
void *item;
{
    LIST    *lp;

    lp = yyalloc(sizeof(LIST));
    lp->litem = item;
    lp->lnext = next;
    return lp;
}

static void*
newfunction()
{
    int     size;
    FUNC    *fp;
    LIST    *lp;

    size = 0;
    lp = yydisplay;
    while (lp != NULL) {
        size++;
        lp = lp->lnext;
    }
    fp = yyalloc(sizeof(FUNC));
    fp->psize = size;
    fp->plist = yydisplay;
    fp->pcode = NULL;
    return fp;
}

static void
pushstack(kind)
{
    if (stackptr <= stackbot)
        yyerror("Stack overflow");
    stackptr--;
    stackptr->sclass = kind;
    stackptr->svalue.ival = 0;
    if (kind == L_MARK || kind == L_DONE) {
        stackptr->stype = yydone;
        stackptr->svalue.sptr = stacktop;
        stacktop = stackptr;
        yydone = 0;
    }
}

static void popstack(kind)
{
    int     i, j, class;

    while (stackptr < stacktop) {
        class = stackptr->sclass;
        if ( class == L_FOR || class == L_WHILE) {
            stackptr++;
            i = poplabel();
            j = poplabel();
            genjump(C_JUMP, i);
            genlabel(j);
            putlabel(i);
            putlabel(j);
        }
        else if (class == L_ELSE) {
            i = poplabel();
            genlabel(i);
            putlabel(i);
        }
        else
            yyerror("dangling label");
        if (class == kind)
            return;
    }
    if (kind == L_MARK || kind == L_DONE) {
        yydone = stackptr->stype;
        stacktop = stackptr->svalue.sptr;
        stackptr++;
    }
    else
        yyerror("syntax error");
}

static int toploop(int class)
{
    ITEM    *sp;
    int     label;

    sp = stackptr;
    while (sp < stackbot + MAXSTACK)
        if (sp->sclass == class) {
            label = sp->svalue.ival;
#ifdef LDEBUG
    printlabel("top", label);
#endif
            return label;
        }
        else
            sp++;
    return(-1);
}

static int getloop(class)
{
    while (stackptr < stacktop) {
        if (stackptr->sclass == class)
            return poplabel();
        else
            popstack(stackptr->sclass);
    }
    return(-1);
}

static void
pushlabel(class, label)
{
#ifdef LDEBUG
    printlabel("pop", label);
#endif
    if (stackptr <= stackbot)
        yyerror("Stack overflow");
    stackptr--;
    stackptr->sclass = class;
    stackptr->svalue.ival = label;
}

static int
poplabel()
{
    int     label;

    label = stackptr->svalue.ival;
#ifdef LDEBUG
    printlabel("pop", label);
#endif
    stackptr++;
    return label;
}

