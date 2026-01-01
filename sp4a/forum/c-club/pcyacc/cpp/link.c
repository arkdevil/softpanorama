
/*================== PCYACC ==========================================

            ABRAXAS SOFTWARE (R) PCYACC
      (C)COPYRIGHT PCYACC 1986-88, ABRAXAS SOFTWARE, INC.
               ALL RIGHTS RESERVED

======================================================================*/


#include <stdio.h>
#include "const.h"
#include "global.h"
#include "cppcmain.h"

/*
 * global variable declaratoins
 */

konst         *a_const = NULL;
const_expr    *a_const_expr = NULL;
abstract_decl *a_abstract_decl = NULL;
type_name     *a_type_name = NULL;
op            a_op = EMPTY;
id            *a_id = NULL;
prim_expr     *a_prim_expr = NULL;
term          *a_term = NULL;
expr          *a_expr = NULL;
stmt          *a_stmt = NULL;
stmt_list     *a_stmt_list = NULL;
comp_stmt     *a_comp_stmt = NULL;
arg_decl      *a_arg_decl = NULL;
args          *a_args = NULL;
arg_decl_list *a_arg_decl_list = NULL;
operfunc_name *a_opoerfunc_name = NULL;
simp_dname    *a_simp_dname = NULL;
dname         *a_dname = NULL;
decl          *a_decl = NULL;
init_list     *a_init_list = NULL;
init          *a_init = NULL;
init_decl     *a_init_decl = NULL;
decl_list     *a_decl_list = NULL;
ft_spec       *a_ft_spec = NULL;
sc_spec       *a_sc_spec = NULL;
class_head    *a_class_head = NULL;
clas_spec     *a_clas_spec = NULL;
unio_spec     *a_unio_spec = NULL;
enumerator    *a_enumerator = NULL;
enum_list     *a_enum_list = NULL;
enum_spec     *a_enum_spec = NULL;
simp_tname    *a_simp_tname = NULL;
tp_spec       *a_tp_spec = NULL;
data_decl     *a_data_decl = NULL;
mem_init      *a_mem_init = NULL;
mem_init_list *a_mem_init_list = NULL;
func_body     *a_func_body = NULL;
func_head     *a_func_head = NULL;
type_decl     *a_type_decl = NULL;
func_decl     *a_func_decl = NULL;
func_def      *a_func_def = NULL;
def           *a_def = NULL;
defs          *a_defs = NULL,
              *a_prog = NULL;

/*
 * this set of routines adds backward links to the syntax tree
 */

void blink_konst();
void blink_const_expr();
void blink_abstract_decl();
void blink_type_name();
void blink_id();
void blink_prim_expr();
void blink_term();
void blink_expr();
void blink_stmt();
void blink_stmt_list();
void blink_comp_stmt();
void blink_arg_decl();
void blink_args();
void blink_arg_decl_list();
void blink_operfunc_name();
void blink_simp_dname();
void blink_dname();
void blink_decl();
void blink_init_list();
void blink_init();
void blink_init_decl();
void blink_decl_list();
void blink_ft_spec();
void blink_sc_spec();
void blink_class_head();
void blink_clas_spec();
void blink_unio_spec();
void blink_enumerator();
void blink_enum_list();
void blink_enum_spec();
void blink_simp_tname();
void blink_tp_spec();
void blink_data_decl();
void blink_mem_init();
void blink_mem_init_list();
void blink_func_body();
void blink_func_head();
void blink_type_decl();
void blink_func_decl();
void blink_func_def();
void blink_def();
void blink_defs();

void
blink_konst(p, pt, pp)
konst *p;
int pt;
const_expr *pp;
{

  if (p!=NULL) {
    if (debug) fprintf(tracefp, "const: %d, %s\n", p->constype, p->aconst);
    p->pnodetype = pt;
    if (pt == CONST_EXPR) p->parent.pcex = (const_expr *) pp;
    else if (pt == PRIM_EXPR) p->parent.ppex = (prim_expr *) pp;
  }
}

void
blink_const_expr(p, pt, pp)
const_expr *p;
int pt;
decl *pp;
{
  if (p!=NULL) {
    if (debug) fprintf(tracefp, "const_expr: \n");
    blink_konst(p->aconst, p->nodetype, p);
    p->pnodetype = pt;
    if (pt == ABSTRACT_DECL) p->parent.pabs = (abstract_decl *) pp;
    else if (pt == STMT) p->parent.pstm = (stmt *) pp;
    else if (pt == DECL) p->parent.pdcl = (decl *) pp;
    else if (pt == ENUMERATOR) p->parent.penm = (enumerator *) pp;
  }
}

void
blink_abstract_decl(p, pt, pp)
abstract_decl *p;
int pt;
type_name *pp;
{
  if (p!=NULL) {
    if (debug) fprintf(tracefp, "abstract_decl: %d\n", p->absttype);
    blink_arg_decl_list(p->aargdecllist, p->nodetype, p);
    blink_expr(p->aexpr, p->nodetype, p);
    blink_abstract_decl(p->aabstractdecl, p->nodetype, p);
    p->pnodetype = pt;
    if (pt == ABSTRACT_DECL) p->parent.pabs = (abstract_decl *) pp;
    else if (pt == TYPE_NAME) p->parent.ptnm = (type_name *) pp;
  }
}

void
blink_type_name(p, pt, pp)
type_name *p;
int pt;
arg_decl *pp;
{
  if (p!=NULL) {
    if (debug) fprintf(tracefp, "type_name\n");
    blink_tp_spec(p->atpspec, p->nodetype, p);
    blink_abstract_decl(p->aabstractdecl, p->nodetype, p);
    p->pnodetype = pt;
    if (pt == TERM) p->parent.ptrm = (term *) pp;
    else if (pt == ARG_DECL) p->parent.padc = (arg_decl *) pp;
  }
}						

void
blink_id(p, pt, pp)
id *p;
int pt;
prim_expr *pp;
{
  if (p!=NULL) {
    if (debug) fprintf(tracefp, "id: %s, %s\n", p->atyp, p->avar);
    blink_operfunc_name(p->aoperfuncname, p->nodetype, p);
    p->pnodetype = pt;
    if (pt == PRIM_EXPR) p->parent.ppex = (prim_expr *) pp;
  }
}

void
blink_prim_expr(p, pt, pp)
prim_expr *p;
int pt;
term *pp;
{
  if (p!=NULL) {
    if (debug) fprintf(tracefp, "prim_expr: %d, %s, %s\n", p->primtype, p->avar, p->astring);
    blink_id(p->aid, p->nodetype, p);
    blink_konst(p->aconst, p->nodetype, p);
    blink_expr(p->aexpr, p->nodetype, p);
    blink_prim_expr(p->aprimexpr, p->nodetype, p);
    p->pnodetype = pt;
    if (pt == PRIM_EXPR) p->parent.ppex = (prim_expr *) pp;
    else if (pt == TERM) p->parent.ptrm = (term *) pp;
  }
}

void
blink_term(p, pt, pp)
term *p;
int pt;
expr *pp;
{
  if (p!=NULL) {
    if (debug) fprintf(tracefp, "term: %d\n", p->termtype);
    blink_prim_expr(p->aprimexpr, p->nodetype, p);
    blink_term(p->aterm, p->nodetype, p);
    blink_expr(p->aexpr, p->nodetype, p);
    blink_type_name(p->atypename, p->nodetype, p);
    blink_simp_tname(p->asimptname, p->nodetype, p);
    p->pnodetype = pt;
    if (pt == TERM) p->parent.ptrm = (term *) pp;
    else if (pt == EXPR) p->parent.pexp = (expr *) pp;
  }
}

void
blink_expr(p, pt, pp)
expr *p;
int pt;
stmt *pp;
{
  if (p!=NULL) {
    if (debug) fprintf(tracefp, "expr: %d\n", p->exprtype);
    blink_term(p->aterm, p->nodetype, p);
    blink_expr(p->aexpr, p->nodetype, p);
    blink_expr(p->aexpr2, p->nodetype, p);
    blink_expr(p->aexpr3, p->nodetype, p);
    p->pnodetype = pt;
    if (pt == PRIM_EXPR) p->parent.ppex = (prim_expr *) pp;
    else if (pt == TERM) p->parent.ptrm = (term *) pp;
    else if (pt == EXPR) p->parent.pexp = (expr *) pp;
    else if (pt == STMT) p->parent.pstm = (stmt *) pp;
    else if (pt == ARG_DECL) p->parent.padc = (arg_decl *) pp;
    else if (pt == INIT_LIST) p->parent.pils = (init_list *) pp;
    else if (pt == INIT) p->parent.pini = (init *) pp;
    else if (pt == DECL_LIST) p->parent.pdls = (decl_list *) pp;
    else if (pt == MEM_INIT) p->parent.pmin = (mem_init *) pp;
  }
}

void
blink_stmt(p, pt, pp)
stmt *p;
int pt;
stmt_list *pp;
{
  if (p!=NULL) {
    if (debug) fprintf(tracefp, "stmt: %d, %s\n", p->stmttype, p->aidentifier);
    blink_expr(p->aexpr, p->nodetype, p);
    blink_expr(p->aexpr2, p->nodetype, p);
    blink_stmt(p->astmt, p->nodetype, p);
    blink_stmt(p->astmt2, p->nodetype, p);
    blink_data_decl(p->adatadecl, p->nodetype, p);
    blink_comp_stmt(p->acompstmt, p->nodetype, p);
    blink_const_expr(p->aconstexpr, p->nodetype, p);
    p->pnodetype = pt;
    if (pt == STMT) p->parent.pstm = (stmt *) pp;
    else if (pt == STMT_LIST) p->parent.psls = (stmt_list *) pp;
  }
}

void
blink_stmt_list(p, pt, pp)
stmt_list *p;
int pt;
comp_stmt *pp;
{
  if (p!=NULL) {
    if (debug) fprintf(tracefp, "stmt_list\n");
    blink_stmt(p->astmt, p->nodetype, p);
    blink_stmt_list(p->next, p->nodetype, p);
    p->pnodetype = pt;
    if (pt == STMT_LIST) p->parent.psls = (stmt_list *) pp;
    else if (pt == COMP_STMT) p->parent.pcst = (comp_stmt *) pp;
  }
}

void
blink_comp_stmt(p, pt, pp)
comp_stmt *p;
int pt;
func_body *pp;
{
  if (p!=NULL) {
    if (debug) fprintf(tracefp, "comp_stmt\n");
    blink_stmt_list(p->astmtlist, p->nodetype, p);
    p->pnodetype = pt;
    if (pt == STMT) p->parent.pstm = (stmt *) pp;
    else if (pt == FUNC_BODY) p->parent.pfbd = (func_body *) pp;
  }
}

void
blink_arg_decl(p, pt, pp)
arg_decl *p;
int pt;
args *pp;
{
  if (p!=NULL) {
    if (debug) fprintf(tracefp, "arg_decl\n");
    blink_tp_spec(p->atpspec, p->nodetype, p);
    blink_decl(p->adecl, p->nodetype, p);
    blink_expr(p->aexpr, p->nodetype, p);
    blink_type_name(p->atypename, p->nodetype, p);
    p->pnodetype = pt;
    if (pt == ARGS) p->parent.parg = (args *) pp;
  }
}

void
blink_args(p, pt, pp)
args *p;
int pt;
arg_decl_list *pp;
{
  if (p!=NULL) {
    if (debug) fprintf(tracefp, "args\n");
    blink_arg_decl(p->aargdecl, p->nodetype, p);
    blink_args(p->next, p->nodetype, p);
    p->pnodetype = pt;
    if (pt == ARGS) p->parent.parg = (args *) pp;
    else if (pt == ARG_DECL_LIST) p->parent.padl = (arg_decl_list *) pp;
  }
}

void
blink_arg_decl_list(p, pt, pp)
arg_decl_list *p;
int pt;
func_head *pp;
{
  if (p!=NULL) {
    if (debug) fprintf(tracefp, "arg_decl_list: %d\n", p->hastridots);
    blink_args(p->aargs, p->nodetype, p);
    p->pnodetype = pt;
    if (pt == ABSTRACT_DECL) p->parent.pabs = (abstract_decl *) pp;
    else if (pt == DECL) p->parent.pdcl = (decl *) pp;
    else if (pt == FUNC_HEAD) p->parent.pfhd = (func_head *) pp;
  }
}

void
blink_operfunc_name(p, pt, pp)
operfunc_name *p;
int pt;
dname *pp;
{
  if (p!=NULL) {
    if (debug) fprintf(tracefp, "operfunc_name: %d\n", p->aop);
    p->pnodetype = pt;
    if (pt == ID) p->parent.pid = (id *) pp;
    else if (pt == SIMP_DNAME) p->parent.psdn = (simp_dname *) pp;
  }
}

void
blink_simp_dname(p, pt, pp)
simp_dname *p;
int pt;
dname *pp;
{
  if (p!=NULL) {
    if (debug) fprintf(tracefp, "simp_dname: %d, %d, %s\n", p->hasdes, p->iscons, p->aidentifier);
    blink_operfunc_name(p->aoperfuncname, p->nodetype, p);
    p->pnodetype = pt;
    if (pt == DNAME) p->parent.pdnm = (dname *) pp;
  }
}

void
blink_dname(p, pt, pp)
dname *p;
int pt;
decl *pp;
{
  if (p!=NULL) {
    if (debug) fprintf(tracefp, "dname: %s\n", p->atyp);
    blink_simp_dname(p->asimpdname, p->nodetype, p);
    p->pnodetype = pt;
    if (pt == DECL) p->parent.pdcl = (decl *) pp;
  }
}

void
blink_decl(p, pt, pp)
decl *p;
int pt;
decl_list *pp;
{
  if (p!=NULL) {
    if (debug) fprintf(tracefp, "decl: %d, %d, %d, %d, %d\n", p->hasast,
                 p->hasamp, p->hasround, p->hassquare, p->isenclosed);
    blink_dname(p->adname, p->nodetype, p);
    blink_decl(p->adecl, p->nodetype, p);
    blink_arg_decl_list(p->aargdecllist, p->nodetype, p);
    blink_const_expr(p->aconstexpr, p->nodetype, p);
    p->pnodetype = pt;
    if (pt == ARG_DECL) p->parent.padc = (arg_decl *) pp;
    else if (pt == DECL) p->parent.pdcl = (decl *) pp;
    else if (pt == INIT_DECL) p->parent.pidc = (init_decl *) pp;
    else if (pt == DECL_LIST) p->parent.pdls = (decl_list *) pp;
    else if (pt == FUNC_HEAD) p->parent.pfhd = (func_head *) pp;
  }
}

void
blink_init_list(p, pt, pp)
init_list *p;
int pt;
init *pp;
{
  if (p!=NULL) {
    if (debug) fprintf(tracefp, "init_list\n");
    blink_expr(p->aexpr, p->nodetype, p);
    blink_init_list(p->ainitlist, p->nodetype, p);
    blink_init_list(p->ainitlist2, p->nodetype, p);
    p->pnodetype = pt;
    if (pt == INIT_LIST) p->parent.pils = (init_list *) pp;
    else if (pt == INIT) p->parent.pini = (init *) pp;
  }
}

void
blink_init(p, pt, pp)
init *p;
int pt;
init_decl *pp;
{
  if (p!=NULL) {
    if (debug) fprintf(tracefp, "init\n");
    blink_expr(p->aexpr, p->nodetype, p);
    blink_init_list(p->ainitlist, p->nodetype, p);
    p->pnodetype = pt;
    if (pt == INIT_DECL) p->parent.pidc = (init_decl *) pp;
  }
}

void
blink_init_decl(p, pt, pp)
init_decl *p;
int pt;
decl_list *pp;
{
  if (p!=NULL) {
    if (debug) fprintf(tracefp, "init_decl\n");
    blink_decl(p->adecl, p->nodetype, p);
    blink_init(p->ainit, p->nodetype, p);
    p->pnodetype = pt;
    if (pt == DECL_LIST) p->parent.pdls = (decl_list *) pp;
  }
}

void
blink_decl_list(p, pt, pp)
decl_list *p;
int pt;
data_decl *pp;
{
  if (p!=NULL) {
    if (debug) fprintf(tracefp, "decl_list\n");
    blink_init_decl(p->ainitdecl, p->nodetype, p);
    blink_decl(p->adecl, p->nodetype, p);
    blink_expr(p->aexpr, p->nodetype, p);
    blink_decl_list(p->next, p->nodetype, p);
    p->pnodetype = pt;
    if (pt == DECL_LIST) p->parent.pdls = (decl_list *) pp;
    else if (pt == DATA_DECL) p->parent.pddc = (data_decl *) pp;
  }
}

void
blink_ft_spec(p, pt, pp)
ft_spec *p;
int pt;
func_head *pp;
{
  if (p!=NULL) {
    if (debug) fprintf(tracefp, "ft_spec: %s\n", p->aftconst);
    p->pnodetype = pt;
    if (pt == FUNC_HEAD) p->parent.pfhd = (func_head *) pp;
  }
}

void
blink_sc_spec(p, pt, pp)
sc_spec *p;
int pt;
data_decl *pp;
{ int sc;

  if (p!=NULL) {
    if (debug) fprintf(tracefp, "sc_spec: %s\n", p->ascconst);
    p->pnodetype = pt;
    if (pt == DATA_DECL) p->parent.pddc = (data_decl *) pp;
    else if (pt == FUNC_HEAD) p->parent.pfhd = (func_head *) pp;
  }
}

void
blink_class_head(p, pt, pp)
class_head *p;
int pt;
clas_spec *pp;
{
  if (p!=NULL) {
    if (debug) fprintf(tracefp, "class_head: %d, %s, %d, %s\n", p->headtype,
                 p->atag, p->ispub, p->atyp);
    p->pnodetype = pt;
    if (pt == CLAS_SPEC) p->parent.pcsp = (clas_spec *) pp;
  }
}

void
blink_clas_spec(p, pt, pp)
clas_spec *p;
int pt;
type_decl *pp;
{

  if (p!=NULL) {
    if (debug) fprintf(tracefp, "clas_spec\n");
    blink_class_head(p->aclasshead, p->nodetype, p);
    blink_defs(p->prdefs, p->nodetype, p);
    blink_defs(p->pudefs, p->nodetype, p);
    p->pnodetype = pt;
    if (pt == TP_SPEC) p->parent.ptsp = (tp_spec *) pp;
    else if (pt == TYPE_DECL) p->parent.ptdc = (type_decl *) pp;
  }
}

void
blink_unio_spec(p, pt, pp)
unio_spec *p;
int pt;
type_decl *pp;
{

  if (p!=NULL) {
    if (debug) fprintf(tracefp, "unio_spec: %s\n", p->atag);
    blink_defs(p->adefs, p->nodetype, p);
    p->pnodetype = pt;
    if (pt == TP_SPEC) p->parent.ptsp = (tp_spec *) pp;
    else if (pt == TYPE_DECL) p->parent.ptdc = (type_decl *) pp;
  }
}

void
blink_enumerator(p, pt, pp)
enumerator *p;
int pt;
enum_list *pp;
{
  if (p!=NULL) {
    if (debug) fprintf(tracefp, "enumerator: %s\n", p->aidentifier);
    blink_const_expr(p->aconstexpr) ;
    p->pnodetype = pt;
    if (pt == ENUM_LIST) p->parent.pels = (enum_list *) pp;
  }
}

void
blink_enum_list(p, pt, pp)
enum_list *p;
int pt;
enum_spec *pp;
{
  if (p!=NULL) {
    if (debug) fprintf(tracefp, "enum_list\n");
    blink_enumerator(p->aenumerator, p->nodetype, p);
    blink_enum_list(p->next, p->nodetype, p);
    p->pnodetype = pt;
    if (pt == ENUM_LIST) p->parent.pels = (enum_list *) pp;
    else if (pt == ENUM_SPEC) p->parent.pesp = (enum_spec *) pp;
  }
}

void
blink_enum_spec(p, pt, pp)
enum_spec *p;
int pt;
type_decl *pp;
{
  if (p!=NULL) {
    if (debug) fprintf(tracefp, "enum_spec: %s\n", p->atag);
    blink_enum_list(p->aenumlist, p->nodetype, p);
    p->pnodetype = pt;
    if (pt == TP_SPEC) p->parent.ptsp = (tp_spec *) pp;
    else if (pt == TYPE_DECL) p->parent.ptdc = (type_decl *) pp;
  }
}

void
blink_simp_tname(p, pt, pp)
simp_tname *p;
int pt;
tp_spec *pp;
{
  if (p!=NULL) {
    if (debug) fprintf(tracefp, "simp_tname: %d, %s\n", p->hasunsigned, p->asimptname);
    p->pnodetype = pt;
    if (pt == TERM) p->parent.ptrm = (term *) pp;
    else if (pt == TP_SPEC) p->parent.ptsp = (tp_spec *) pp;
  }
}

void
blink_tp_spec(p, pt, pp)
tp_spec *p;
int pt;
data_decl *pp;
{
  if (p!=NULL) {
    if (debug) fprintf(tracefp, "tp_spec: %d\n", p->hasconst);
    blink_simp_tname(p->asimptname, p->nodetype, p);
    blink_clas_spec(p->aclasspec, p->nodetype, p);
    blink_unio_spec(p->auniospec, p->nodetype, p);
    blink_enum_spec(p->aenumspec, p->nodetype, p);
    p->pnodetype = pt;
    if (pt == TYPE_NAME) p->parent.ptnm = (type_name *) pp;
    else if (pt == ARG_DECL) p->parent.padc = (arg_decl *) pp;
    else if (pt == DATA_DECL) p->parent.pddc = (data_decl *) pp;
    else if (pt == FUNC_HEAD) p->parent.pfhd = (func_head *) pp;
  }
}

void
blink_data_decl(p, pt, pp)
data_decl *p;
int pt;
def *pp;
{
  if (p!=NULL) {
    if (debug) fprintf(tracefp, "data_decl: %d\n", p->hastypedef);
    blink_sc_spec(p->ascspec, p->nodetype, p);
    blink_tp_spec(p->atpspec, p->nodetype, p);
    blink_decl_list(p->adecllist, p->nodetype, p);
    p->pnodetype = pt;
    if (pt == STMT) p->parent.pstm = (stmt *) pp;
    else if (pt == DEF) p->parent.pdef = (def *) pp;
  }
}

void
blink_mem_init(p, pt, pp)
mem_init *p;
int pt;
mem_init_list *pp;
{
  if (p!=NULL) {
    if (debug) fprintf(tracefp, "mem_init: %s\n", p->aidentifier);
    blink_expr(p->aexpr, p->nodetype, p);
    p->pnodetype = pt;
    if (pt == MEM_INIT_LIST) p->parent.pmil = (mem_init_list *) pp;
  }
}

void
blink_mem_init_list(p, pt, pp)
mem_init_list *p;
int pt;
func_body *pp;
{
  if (p!=NULL) {
    if (debug) fprintf(tracefp, "mem_init_list\n");
    blink_mem_init(p->ameminit, p->nodetype, p);
    blink_mem_init_list(p->next, p->nodetype, p);
    p->pnodetype = pt;
    if (pt == MEM_INIT_LIST) p->parent.pmil = (mem_init_list *) pp;
    else if (pt == FUNC_BODY) p->parent.pfbd = (func_body *) pp;
  }
}

void
blink_func_body(p, pt, pp)
func_body *p;
int pt;
func_decl *pp;
{

  if (p!=NULL) {
    if (debug) fprintf(tracefp, "func_body\n");
    blink_mem_init_list(p->ameminitlist, p->nodetype, p);
    blink_comp_stmt(p->acompstmt, p->nodetype, p);
    p->pnodetype = pt;
    if (pt == FUNC_DEF) p->parent.pfdf = (func_def *) pp;
  }
}

void
blink_func_head(p, pt, pp)
func_head *p;
int pt;
func_def *pp;
{
  if (p!=NULL) {
    if (debug) fprintf(tracefp, "func_head\n");
    blink_sc_spec(p->ascspec, p->nodetype, p);
    blink_ft_spec(p->aftspec, p->nodetype, p);
    blink_tp_spec(p->atpspec, p->nodetype, p);
    blink_decl(p->adecl, p->nodetype, p);
    blink_arg_decl_list(p->aargdecllist, p->nodetype, p);
    p->pnodetype = pt;
    if (pt == FUNC_DEF) p->parent.pfdf = (func_def *) pp;
    else if (pt == FUNC_DECL) p->parent.pfdc = (func_decl *) pp;
  }
}

void
blink_type_decl(p, pt, pp)
type_decl *p;
int pt;
def *pp;
{
  if (p!=NULL) {
    if (debug) fprintf(tracefp, "type_decl\n");
    blink_enum_spec(p->aenumspec, p->nodetype, p);
    blink_unio_spec(p->auniospec, p->nodetype, p);
    blink_clas_spec(p->aclasspec, p->nodetype, p);
    p->pnodetype = pt;
    if (pt == DEF) p->parent.pdef = (def *) pp;
  }
}

void
blink_func_decl(p, pt, pp)
func_decl *p;
int pt;
def *pp;
{
  if (p!=NULL) {
    if (debug) fprintf(tracefp, "func_decl\n");
    blink_func_head(p->afunchead, p->nodetype, p);
    p->pnodetype = pt;
    if (pt == DEF) p->parent.pdef = (def *) pp;
  }
}

void
blink_func_def(p, pt, pp)
func_def *p;
int pt;
def *pp;
{
  if (p!=NULL) {
    if (debug) fprintf(tracefp, "func_def\n");
    blink_func_head(p->afunchead, p->nodetype, p);
    blink_func_body(p->afuncbody, p->nodetype, p);
    p->pnodetype = pt;
    if (pt == DEF) p->parent.pdef = (def *) pp;
  }
}

void
blink_def(p, pt, pp)
def *p;
int pt;
defs *pp;
{
  if (p!=NULL) {
    if (debug) fprintf(tracefp, "def\n");
    blink_func_def(p->afuncdef, p->nodetype, p);
    blink_data_decl(p->adatadecl, p->nodetype, p);
    blink_type_decl(p->atypedecl, p->nodetype, p);
    blink_func_decl(p->afuncdecl, p->nodetype, p);
    p->pnodetype = pt;
    if (pt == DEFS) p->parent.pdfs = (defs *) pp;
  }
}

void
blink_defs(p, pt, pp)
defs *p;
int pt;
defs *pp;
{
  if (p!=NULL) {
    if (debug) fprintf(tracefp, "defs\n");
    blink_def(p->adef, p->nodetype, p);
    blink_defs(p->next, p->nodetype, p);
    p->pnodetype = pt;
    if (pt == CLAS_SPEC) p->parent.pcsp = (clas_spec *) pp;
    else if (pt == UNIO_SPEC) p->parent.pusp = (unio_spec *) pp;
    else if (pt == DEFS) p->parent.pdfs = (defs *) pp;
  }
}

