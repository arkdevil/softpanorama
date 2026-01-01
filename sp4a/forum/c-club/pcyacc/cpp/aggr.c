
/*================== PCYACC ==========================================

            ABRAXAS SOFTWARE (R) PCYACC
      (C)COPYRIGHT PCYACC 1986-88, ABRAXAS SOFTWARE, INC.
               ALL RIGHTS RESERVED

======================================================================*/


#include <stdio.h>
#include "const.h"
#include "global.h"

/*
 * the first pass going through the syntax tree:
 *   lift nested aggregate {class, struct, union, enum} type definitions.
 *   each such definition is simply moved to the front of the top
 *   level linked list
 */

void alift_konst();
void alift_const_expr();
void alift_abstract_decl();
void alift_type_name();
void alift_id();
void alift_prim_expr();
void alift_term();
void alift_expr();
void alift_stmt();
void alift_stmt_list();
void alift_comp_stmt();
void alift_arg_decl();
void alift_args();
void alift_arg_decl_list();
void alift_operfunc_name();
void alift_simp_dname();
void alift_dname();
void alift_decl();
void alift_init_list();
void alift_init();
void alift_init_decl();
void alift_decl_list();
void alift_ft_spec();
void alift_sc_spec();
void alift_class_head();
void alift_clas_spec();
void alift_unio_spec();
void alift_enumerator();
void alift_enum_list();
void alift_enum_spec();
void alift_simp_tname();
void alift_tp_spec();
void alift_data_decl();
void alift_mem_init();
void alift_mem_init_list();
void alift_func_body();
void alift_func_head();
void alift_type_decl();
void alift_func_decl();
void alift_func_def();
void alift_def();
void alift_defs();

void
alift_konst(p, nested)
konst *p;
int nested;
{

  if (p!=NULL) {
  }
}

void
alift_const_expr(p, nested)
const_expr *p;
int nested;
{
  if (p!=NULL) {
    alift_konst(p->aconst, nested);
  }
}

void
alift_abstract_decl(p, nested)
abstract_decl *p;
int nested;
{
  if (p!=NULL) {
    alift_arg_decl_list(p->aargdecllist, nested);
    alift_expr(p->aexpr, nested);
    alift_abstract_decl(p->aabstractdecl, nested);
  }
}

void
alift_type_name(p, nested)
type_name *p;
int nested;
{
  if (p!=NULL) {
    alift_tp_spec(p->atpspec, nested);
    alift_abstract_decl(p->aabstractdecl, nested);
  }
}						

void
alift_id(p, nested)
id *p;
int nested;
{
  if (p!=NULL) {
    alift_operfunc_name(p->aoperfuncname, nested);
  }
}

void
alift_prim_expr(p, nested)
prim_expr *p;
int nested;
{
  if (p!=NULL) {
    alift_id(p->aid, nested);
    alift_konst(p->aconst, nested);
    alift_expr(p->aexpr, nested);
    alift_prim_expr(p->aprimexpr, nested);
  }
}

void
alift_term(p, nested)
term *p;
int nested;
{
  if (p!=NULL) {
    alift_prim_expr(p->aprimexpr, nested);
    alift_term(p->aterm, nested);
    alift_expr(p->aexpr, nested);
    alift_type_name(p->atypename, nested);
    alift_simp_tname(p->asimptname, nested);
  }
}

void
alift_expr(p, nested)
expr *p;
int nested;
{
  if (p!=NULL) {
    alift_term(p->aterm, nested);
    alift_expr(p->aexpr, nested);
    alift_expr(p->aexpr2, nested);
    alift_expr(p->aexpr3, nested);
  }
}

void
alift_stmt(p, nested)
stmt *p;
int nested;
{
  if (p!=NULL) {
    alift_expr(p->aexpr, nested);
    alift_expr(p->aexpr2, nested);
    alift_stmt(p->astmt, nested);
    alift_stmt(p->astmt2, nested);
    alift_data_decl(p->adatadecl, nested);
    alift_comp_stmt(p->acompstmt, nested);
    alift_const_expr(p->aconstexpr, nested);
  }
}

void
alift_stmt_list(p, nested)
stmt_list *p;
int nested;
{
  if (p!=NULL) {
    alift_stmt(p->astmt, nested);
    alift_stmt_list(p->next, nested);
  }
}

void
alift_comp_stmt(p, nested)
comp_stmt *p;
int nested;
{
  if (p!=NULL) {
    alift_stmt_list(p->astmtlist, nested);
  }
}

void
alift_arg_decl(p, nested)
arg_decl *p;
int nested;
{
  if (p!=NULL) {
    alift_tp_spec(p->atpspec, nested);
    alift_decl(p->adecl, nested);
    alift_expr(p->aexpr, nested);
    alift_type_name(p->atypename, nested);
  }
}

void
alift_args(p, nested)
args *p;
int nested;
{
  if (p!=NULL) {
    alift_arg_decl(p->aargdecl, nested);
    alift_args(p->next, nested);
  }
}

void
alift_arg_decl_list(p, nested)
arg_decl_list *p;
int nested;
{
  if (p!=NULL) {
    alift_args(p->aargs, nested);
  }
}

void
alift_operfunc_name(p, nested)
operfunc_name *p;
int nested;
{
  if (p!=NULL) {
  }
}

void
alift_simp_dname(p, nested)
simp_dname *p;
int nested;
{
  if (p!=NULL) {
    alift_operfunc_name(p->aoperfuncname, nested);
  }
}

void
alift_dname(p, nested)
dname *p;
int nested;
{
  if (p!=NULL) {
    alift_simp_dname(p->asimpdname, nested);
  }
}

void
alift_decl(p, nested)
decl *p;
int nested;
{
  if (p!=NULL) {
    alift_dname(p->adname, nested);
    alift_decl(p->adecl, nested);
    alift_arg_decl_list(p->aargdecllist, nested);
    alift_const_expr(p->aconstexpr, nested);
  }
}

void
alift_init_list(p, nested)
init_list *p;
int nested;
{
  if (p!=NULL) {
    alift_expr(p->aexpr, nested);
    alift_init_list(p->ainitlist, nested);
    alift_init_list(p->ainitlist2, nested);
  }
}

void
alift_init(p, nested)
init *p;
int nested;
{
  if (p!=NULL) {
    alift_expr(p->aexpr, nested);
    alift_init_list(p->ainitlist, nested);
  }
}

void
alift_init_decl(p, nested)
init_decl *p;
int nested;
{
  if (p!=NULL) {
    alift_decl(p->adecl, nested);
    alift_init(p->ainit, nested);
  }
}

void
alift_decl_list(p, nested)
decl_list *p;
int nested;
{
  if (p!=NULL) {
    alift_init_decl(p->ainitdecl, nested);
    alift_decl(p->adecl, nested);
    alift_expr(p->aexpr, nested);
    alift_decl_list(p->next, nested);
  }
}

void
alift_ft_spec(p, nested)
ft_spec *p;
int nested;
{
  if (p!=NULL) {
  }
}

void
alift_sc_spec(p, nested)
sc_spec *p;
int nested;
{ int sc;

  if (p!=NULL) {
  }
}

void
alift_class_head(p, nested)
class_head *p;
int nested;
{
  if (p!=NULL) {
  }
}

void
alift_clas_spec(p, nested)
clas_spec *p;
int nested;
{

  if (p!=NULL) {
    alift_class_head(p->aclasshead, nested);
    alift_defs(p->prdefs, TRUE);
    alift_defs(p->pudefs, TRUE);
  }
}

void
alift_unio_spec(p, nested)
unio_spec *p;
int nested;
{

  if (p!=NULL) {
    alift_defs(p->adefs, TRUE);
  }
}

void
alift_enumerator(p, nested)
enumerator *p;
int nested;
{
  if (p!=NULL) {
    alift_const_expr(p->aconstexpr) ;
  }
}

void
alift_enum_list(p, nested)
enum_list *p;
int nested;
{
  if (p!=NULL) {
    alift_enumerator(p->aenumerator, nested);
    alift_enum_list(p->next, nested);
  }
}

void
alift_enum_spec(p, nested)
enum_spec *p;
int nested;
{
  if (p!=NULL) {
    alift_enum_list(p->aenumlist, nested);
  }
}

void
alift_simp_tname(p, nested)
simp_tname *p;
int nested;
{
  if (p!=NULL) {
  }
}

void
alift_tp_spec(p, nested)
tp_spec *p;
int nested;
{
  if (p!=NULL) {
    alift_simp_tname(p->asimptname, nested);
    alift_clas_spec(p->aclasspec, nested);
    alift_unio_spec(p->auniospec, nested);
    alift_enum_spec(p->aenumspec, nested);
  }
}

void
alift_data_decl(p, nested)
data_decl *p;
int nested;
{
  if (p!=NULL) {
    alift_sc_spec(p->ascspec, nested);
    alift_tp_spec(p->atpspec, nested);
    alift_decl_list(p->adecllist, nested);
  }
}

void
alift_mem_init(p, nested)
mem_init *p;
int nested;
{
  if (p!=NULL) {
    alift_expr(p->aexpr, nested);
  }
}

void
alift_mem_init_list(p, nested)
mem_init_list *p;
int nested;
{
  if (p!=NULL) {
    alift_mem_init(p->ameminit, nested);
    alift_mem_init_list(p->next, nested);
  }
}

void
alift_func_body(p, nested)
func_body *p;
int nested;
{

  if (p!=NULL) {
    alift_mem_init_list(p->ameminitlist, nested);
    alift_comp_stmt(p->acompstmt, nested);
  }
}

void
alift_func_head(p, nested)
func_head *p;
int nested;
{
  if (p!=NULL) {
    alift_sc_spec(p->ascspec, nested);
    alift_ft_spec(p->aftspec, nested);
    alift_tp_spec(p->atpspec, nested);
    alift_decl(p->adecl, nested);
    alift_arg_decl_list(p->aargdecllist, nested);
  }
}

void
alift_type_decl(p, nested)
type_decl *p;
int nested;
{
  if (p!=NULL) {
    alift_enum_spec(p->aenumspec, nested);
    alift_unio_spec(p->auniospec, nested);
    alift_clas_spec(p->aclasspec, nested);
    if (nested) { /* linkage rerouting */
      a_def = p->parent.pdef;
      a_defs = a_def->parent.pdfs;
      if (a_defs->next != NULL) {
        if (a_defs->pnodetype == DEFS) {
          a_defs->parent.pdfs->next = a_defs->next;
          a_defs->next->parent.pdfs = a_defs->parent.pdfs;
        } else if (a_defs->pnodetype == CLAS_SPEC) {
          if (a_defs == a_defs->parent.pcsp->prdefs) {
            a_defs->parent.pcsp->prdefs = a_defs->next;
          } else {
            a_defs->parent.pcsp->pudefs = a_defs->next;
          }
          a_defs->next->pnodetype = CLAS_SPEC;
          a_defs->next->parent.pcsp = a_defs->parent.pcsp;
        } else /* UNIO_SPEC */ {
          a_defs->parent.pusp->adefs = a_defs->next;
          a_defs->next->pnodetype = UNIO_SPEC;
          a_defs->next->parent.pusp = a_defs->parent.pusp;
        }
      } else /* a_defs->next == NULL */ {
        if (a_defs->pnodetype == DEFS) {
          a_defs->parent.pdfs->next = NULL;
        } else if (a_defs->pnodetype == CLAS_SPEC) {
          if (a_defs == a_defs->parent.pcsp->prdefs) {
            a_defs->parent.pcsp->prdefs = NULL;
          } else {
            a_defs->parent.pcsp->pudefs = NULL;
          }
        } else {
          a_defs->parent.pusp->adefs = NULL;
        }
      } /* a_defs->next != NULL */
      /* now lift the defs to the front of the top level */
      a_defs->pnodetype = DEFS;
      a_defs->parent.pdfs = NULL;
      a_defs->next = a_prog;
      a_prog->pnodetype = DEFS;
      a_prog->parent.pdfs = a_defs;
      a_prog = a_defs;
    } /* nested */
  }
}

void
alift_func_decl(p, nested)
func_decl *p;
int nested;
{
  if (p!=NULL) {
    alift_func_head(p->afunchead, nested);
  }
}

void
alift_func_def(p, nested)
func_def *p;
int nested;
{
  if (p!=NULL) {
    alift_func_head(p->afunchead, nested);
    alift_func_body(p->afuncbody, nested);
  }
}

void
alift_def(p, nested)
def *p;
int nested;
{
  if (p!=NULL) {
    alift_func_def(p->afuncdef, TRUE);
    alift_data_decl(p->adatadecl, TRUE);
    alift_type_decl(p->atypedecl, nested);
    alift_func_decl(p->afuncdecl, TRUE);
  }
}

void
alift_defs(p, nested)
defs *p;
int nested;
{
  if (p!=NULL) {
    alift_def(p->adef, nested);
    alift_defs(p->next, nested);
  }
}

