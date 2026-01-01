
/*================== PCYACC ==========================================

            ABRAXAS SOFTWARE (R) PCYACC
      (C)COPYRIGHT PCYACC 1986-88, ABRAXAS SOFTWARE, INC.
               ALL RIGHTS RESERVED

======================================================================*/


#include <stdio.h>
#include "const.h"
#include "global.h"

/*
 * this set of routines lifts function definitions and function declarations
 * nested inside a class definition
 */

void flift_konst();
void flift_const_expr();
void flift_abstract_decl();
void flift_type_name();
void flift_id();
void flift_prim_expr();
void flift_term();
void flift_expr();
void flift_stmt();
void flift_stmt_list();
void flift_comp_stmt();
void flift_arg_decl();
void flift_args();
void flift_arg_decl_list();
void flift_operfunc_name();
void flift_simp_dname();
void flift_dname();
void flift_decl();
void flift_init_list();
void flift_init();
void flift_init_decl();
void flift_decl_list();
void flift_ft_spec();
void flift_sc_spec();
void flift_class_head();
void flift_clas_spec();
void flift_unio_spec();
void flift_enumerator();
void flift_enum_list();
void flift_enum_spec();
void flift_simp_tname();
void flift_tp_spec();
void flift_data_decl();
void flift_mem_init();
void flift_mem_init_list();
void flift_func_body();
void flift_func_head();
void flift_type_decl();
void flift_func_decl();
void flift_func_def();
void flift_def();
void flift_defs();

#define INCLASS 1
#define INUNION 2

void
flift_konst(p, context)
konst *p;
int context;
{

  if (p!=NULL) {
/*
    if (pt == CONST_EXPR) p->parent.pcex = (const_expr *) pp;
    else if (pt == PRIM_EXPR) p->parent.ppex = (prim_expr *) pp;
*/
  }
}

void
flift_const_expr(p, context)
const_expr *p;
int context;
{
  if (p!=NULL) {
    flift_konst(p->aconst, context);
/*
    if (pt == ABSTRACT_DECL) p->parent.pabs = (abstract_decl *) pp;
    else if (pt == STMT) p->parent.pstm = (stmt *) pp;
    else if (pt == DECL) p->parent.pdcl = (decl *) pp;
    else if (pt == ENUMERATOR) p->parent.penm = (enumerator *) pp;
*/
  }
}

void
flift_abstract_decl(p, context)
abstract_decl *p;
int context;
{
  if (p!=NULL) {
    flift_arg_decl_list(p->aargdecllist, context);
    flift_expr(p->aexpr, context);
    flift_abstract_decl(p->aabstractdecl, context);
/*
    if (pt == ABSTRACT_DECL) p->parent.pabs = (abstract_decl *) pp;
    else if (pt == TYPE_NAME) p->parent.ptnm = (type_name *) pp;
*/
  }
}

void
flift_type_name(p, context)
type_name *p;
int context;
{
  if (p!=NULL) {
    flift_tp_spec(p->atpspec, context);
    flift_abstract_decl(p->aabstractdecl, context);
/*
    if (pt == TERM) p->parent.ptrm = (term *) pp;
    else if (pt == ARG_DECL) p->parent.padc = (arg_decl *) pp;
*/
  }
}						

void
flift_id(p, context)
id *p;
int context;
{
  if (p!=NULL) {
    flift_operfunc_name(p->aoperfuncname, context);
/*
    if (pt == PRIM_EXPR) p->parent.ppex = (prim_expr *) pp;
*/
  }
}

void
flift_prim_expr(p, context)
prim_expr *p;
int context;
{
  if (p!=NULL) {
    flift_id(p->aid, context);
    flift_konst(p->aconst, context);
    flift_expr(p->aexpr, context);
    flift_prim_expr(p->aprimexpr, context);
/*
    if (pt == PRIM_EXPR) p->parent.ppex = (prim_expr *) pp;
    else if (pt == TERM) p->parent.ptrm = (term *) pp;
*/
  }
}

void
flift_term(p, context)
term *p;
int context;
{
  if (p!=NULL) {
    flift_prim_expr(p->aprimexpr, context);
    flift_term(p->aterm, context);
    flift_expr(p->aexpr, context);
    flift_type_name(p->atypename, context);
    flift_simp_tname(p->asimptname, context);
/*
    if (pt == TERM) p->parent.ptrm = (term *) pp;
    else if (pt == EXPR) p->parent.pexp = (expr *) pp;
*/
  }
}

void
flift_expr(p, context)
expr *p;
int context;
{
  if (p!=NULL) {
    flift_term(p->aterm, context);
    flift_expr(p->aexpr, context);
    flift_expr(p->aexpr2, context);
    flift_expr(p->aexpr3, context);
/*
    if (pt == PRIM_EXPR) p->parent.ppex = (prim_expr *) pp;
    else if (pt == TERM) p->parent.ptrm = (term *) pp;
    else if (pt == EXPR) p->parent.pexp = (expr *) pp;
    else if (pt == STMT) p->parent.pstm = (stmt *) pp;
    else if (pt == ARG_DECL) p->parent.padc = (arg_decl *) pp;
    else if (pt == INIT_LIST) p->parent.pils = (init_list *) pp;
    else if (pt == INIT) p->parent.pini = (init *) pp;
    else if (pt == DECL_LIST) p->parent.pdls = (decl_list *) pp;
    else if (pt == MEM_INIT) p->parent.pmin = (mem_init *) pp;
*/
  }
}

void
flift_stmt(p, context)
stmt *p;
int context;
{
  if (p!=NULL) {
    flift_expr(p->aexpr, context);
    flift_expr(p->aexpr2, context);
    flift_stmt(p->astmt, context);
    flift_stmt(p->astmt2, context);
    flift_data_decl(p->adatadecl, context);
    flift_comp_stmt(p->acompstmt, context);
    flift_const_expr(p->aconstexpr, context);
/*
    if (pt == STMT) p->parent.pstm = (stmt *) pp;
    else if (pt == STMT_LIST) p->parent.psls = (stmt_list *) pp;
*/
  }
}

void
flift_stmt_list(p, context)
stmt_list *p;
int context;
{
  if (p!=NULL) {
    flift_stmt(p->astmt, context);
    flift_stmt_list(p->next, context);
/*
    if (pt == STMT_LIST) p->parent.psls = (stmt_list *) pp;
    else if (pt == COMP_STMT) p->parent.pcst = (comp_stmt *) pp;
*/
  }
}

void
flift_comp_stmt(p, context)
comp_stmt *p;
int context;
{
  if (p!=NULL) {
    flift_stmt_list(p->astmtlist, context);
/*
    if (pt == STMT) p->parent.pstm = (stmt *) pp;
    else if (pt == FUNC_BODY) p->parent.pfbd = (func_body *) pp;
*/
  }
}

void
flift_arg_decl(p, context)
arg_decl *p;
int context;
{
  if (p!=NULL) {
    flift_tp_spec(p->atpspec, context);
    flift_decl(p->adecl, context);
    flift_expr(p->aexpr, context);
    flift_type_name(p->atypename, context);
/*
    if (pt == ARGS) p->parent.parg = (args *) pp;
*/
  }
}

void
flift_args(p, context)
args *p;
int context;
{
  if (p!=NULL) {
    flift_arg_decl(p->aargdecl, context);
    flift_args(p->next, context);
/*
    if (pt == ARGS) p->parent.parg = (args *) pp;
    else if (pt == ARG_DECL_LIST) p->parent.padl = (arg_decl_list *) pp;
*/
  }
}

void
flift_arg_decl_list(p, context)
arg_decl_list *p;
int context;
{
  if (p!=NULL) {
    flift_args(p->aargs, context);
/*
    if (pt == ABSTRACT_DECL) p->parent.pabs = (abstract_decl *) pp;
    else if (pt == DECL) p->parent.pdcl = (decl *) pp;
    else if (pt == FUNC_HEAD) p->parent.pfhd = (func_head *) pp;
*/
  }
}

void
flift_operfunc_name(p, context)
operfunc_name *p;
int context;
{
  if (p!=NULL) {
/*
    if (pt == ID) p->parent.pid = (id *) pp;
    else if (pt == SIMP_DNAME) p->parent.psdn = (simp_dname *) pp;
*/
  }
}

void
flift_simp_dname(p, context)
simp_dname *p;
int context;
{
  if (p!=NULL) {
    flift_operfunc_name(p->aoperfuncname, context);
/*
    if (pt == DNAME) p->parent.pdnm = (dname *) pp;
*/
  }
}

void
flift_dname(p, context)
dname *p;
int context;
{
  if (p!=NULL) {
    flift_simp_dname(p->asimpdname, context);
/*
    if (pt == DECL) p->parent.pdcl = (decl *) pp;
*/
  }
}

void
flift_decl(p, context)
decl *p;
int context;
{
  if (p!=NULL) {
    flift_dname(p->adname, context);
    flift_decl(p->adecl, context);
    flift_arg_decl_list(p->aargdecllist, context);
    flift_const_expr(p->aconstexpr, context);
/*
    if (pt == ARG_DECL) p->parent.padc = (arg_decl *) pp;
    else if (pt == DECL) p->parent.pdcl = (decl *) pp;
    else if (pt == INIT_DECL) p->parent.pidc = (init_decl *) pp;
    else if (pt == DECL_LIST) p->parent.pdls = (decl_list *) pp;
    else if (pt == FUNC_HEAD) p->parent.pfhd = (func_head *) pp;
*/
  }
}

void
flift_init_list(p, context)
init_list *p;
int context;
{
  if (p!=NULL) {
    flift_expr(p->aexpr, context);
    flift_init_list(p->ainitlist, context);
    flift_init_list(p->ainitlist2, context);
/*
    if (pt == INIT_LIST) p->parent.pils = (init_list *) pp;
    else if (pt == INIT) p->parent.pini = (init *) pp;
*/
  }
}

void
flift_init(p, context)
init *p;
int context;
{
  if (p!=NULL) {
    flift_expr(p->aexpr, context);
    flift_init_list(p->ainitlist, context);
/*
    if (pt == INIT_DECL) p->parent.pidc = (init_decl *) pp;
*/
  }
}

void
flift_init_decl(p, context)
init_decl *p;
int context;
{
  if (p!=NULL) {
    flift_decl(p->adecl, context);
    flift_init(p->ainit, context);
/*
    if (pt == DECL_LIST) p->parent.pdls = (decl_list *) pp;
*/
  }
}

void
flift_decl_list(p, context)
decl_list *p;
int context;
{
  if (p!=NULL) {
    flift_init_decl(p->ainitdecl, context);
    flift_decl(p->adecl, context);
    flift_expr(p->aexpr, context);
    flift_decl_list(p->next, context);
/*
    if (pt == DECL_LIST) p->parent.pdls = (decl_list *) pp;
    else if (pt == DATA_DECL) p->parent.pddc = (data_decl *) pp;
*/
  }
}

void
flift_ft_spec(p, context)
ft_spec *p;
int context;
{
  if (p!=NULL) {
/*
    if (pt == FUNC_HEAD) p->parent.pfhd = (func_head *) pp;
*/
  }
}

void
flift_sc_spec(p, context)
sc_spec *p;
int context;
{ int sc;

  if (p!=NULL) {
/*
    if (pt == DATA_DECL) p->parent.pddc = (data_decl *) pp;
    else if (pt == FUNC_HEAD) p->parent.pfhd = (func_head *) pp;
*/
  }
}

char *current_classname;
extern char *make_aname();

void
flift_class_head(p, context)
class_head *p;
int context;
{
  if (p!=NULL) {
    current_classname = p->atag;
/*
    if (pt == CLAS_SPEC) p->parent.pcsp = (clas_spec *) pp;
*/
  }
}

void
flift_clas_spec(p, context)
clas_spec *p;
int context;
{

  if (p!=NULL) {
    flift_class_head(p->aclasshead, context);
    flift_defs(p->prdefs, context);
    flift_defs(p->pudefs, context);
/*
    if (pt == TP_SPEC) p->parent.ptsp = (tp_spec *) pp;
    else if (pt == TYPE_DECL) p->parent.ptdc = (type_decl *) pp;
*/
  }
}

void
flift_unio_spec(p, context)
unio_spec *p;
int context;
{

  if (p!=NULL) {
/*
    flift_defs(p->adefs, context);
    if (pt == TP_SPEC) p->parent.ptsp = (tp_spec *) pp;
    else if (pt == TYPE_DECL) p->parent.ptdc = (type_decl *) pp;
*/
  }
}

void
flift_enumerator(p, context)
enumerator *p;
int context;
{
  if (p!=NULL) {
    flift_const_expr(p->aconstexpr) ;
/*
    if (pt == ENUM_LIST) p->parent.pels = (enum_list *) pp;
*/
  }
}

void
flift_enum_list(p, context)
enum_list *p;
int context;
{
  if (p!=NULL) {
/*
    flift_enumerator(p->aenumerator, context);
    flift_enum_list(p->next, context);
    if (pt == ENUM_LIST) p->parent.pels = (enum_list *) pp;
    else if (pt == ENUM_SPEC) p->parent.pesp = (enum_spec *) pp;
*/
  }
}

void
flift_enum_spec(p, context)
enum_spec *p;
int context;
{
  if (p!=NULL) {
    flift_enum_list(p->aenumlist, context);
/*
    if (pt == TP_SPEC) p->parent.ptsp = (tp_spec *) pp;
    else if (pt == TYPE_DECL) p->parent.ptdc = (type_decl *) pp;
*/
  }
}

void
flift_simp_tname(p, context)
simp_tname *p;
int context;
{
  if (p!=NULL) {
/*
    if (pt == TERM) p->parent.ptrm = (term *) pp;
    else if (pt == TP_SPEC) p->parent.ptsp = (tp_spec *) pp;
*/
  }
}

void
flift_tp_spec(p, context)
tp_spec *p;
int context;
{
  if (p!=NULL) {
    flift_simp_tname(p->asimptname, context);
    flift_clas_spec(p->aclasspec, context);
    flift_unio_spec(p->auniospec, context);
    flift_enum_spec(p->aenumspec, context);
/*
    if (pt == TYPE_NAME) p->parent.ptnm = (type_name *) pp;
    else if (pt == ARG_DECL) p->parent.padc = (arg_decl *) pp;
    else if (pt == DATA_DECL) p->parent.pddc = (data_decl *) pp;
    else if (pt == FUNC_HEAD) p->parent.pfhd = (func_head *) pp;
*/
  }
}

void
flift_data_decl(p, context)
data_decl *p;
int context;
{
  if (p!=NULL) {
/*
    flift_sc_spec(p->ascspec, context);
    flift_tp_spec(p->atpspec, context);
    flift_decl_list(p->adecllist, context);
    if (pt == STMT) p->parent.pstm = (stmt *) pp;
    else if (pt == DEF) p->parent.pdef = (def *) pp;
*/
  }
}

void
flift_mem_init(p, context)
mem_init *p;
int context;
{
  if (p!=NULL) {
    flift_expr(p->aexpr, context);
/*
    if (pt == MEM_INIT_LIST) p->parent.pmil = (mem_init_list *) pp;
*/
  }
}

void
flift_mem_init_list(p, context)
mem_init_list *p;
int context;
{
  if (p!=NULL) {
    flift_mem_init(p->ameminit, context);
    flift_mem_init_list(p->next, context);
/*
    if (pt == MEM_INIT_LIST) p->parent.pmil = (mem_init_list *) pp;
    else if (pt == FUNC_BODY) p->parent.pfbd = (func_body *) pp;
*/
  }
}

void
flift_func_body(p, context)
func_body *p;
int context;
{

  if (p!=NULL) {
    flift_mem_init_list(p->ameminitlist, context);
    flift_comp_stmt(p->acompstmt, context);
/*
    if (pt == FUNC_DEF) p->parent.pfdf = (func_def *) pp;
*/
  }
}

void
flift_func_head(p, context)
func_head *p;
int context;
{
  if (p!=NULL) {
/*
    flift_sc_spec(p->ascspec, context);
    flift_ft_spec(p->aftspec, context);
    flift_tp_spec(p->atpspec, context);
    flift_decl(p->adecl, context);
    flift_arg_decl_list(p->aargdecllist, context);
    if (pt == FUNC_DEF) p->parent.pfdf = (func_def *) pp;
    else if (pt == FUNC_DECL) p->parent.pfdc = (func_decl *) pp;
*/
  }
}

void
flift_type_decl(p, context)
type_decl *p;
int context;
{
  if (p!=NULL) {
    flift_enum_spec(p->aenumspec, context);
    flift_unio_spec(p->auniospec, INUNION|context);
    flift_clas_spec(p->aclasspec, INCLASS|context);
/*
    if (pt == DEF) p->parent.pdef = (def *) pp;
*/
  }
}

void
flift_func_decl(p, context)
func_decl *p;
int context;
{ def *p_def;
  defs *p_defs;

  if (p!=NULL) {
    if (context & INCLASS) { /* nonnull classname indicates member function */
      p->classname = make_aname(&current_classname);

      /* backing up to this def entry */
      a_def = p->parent.pdef;
      a_defs = a_def->parent.pdfs;

      /* in place relinking */
      if (a_defs->next != NULL) {
        if (a_defs->pnodetype == DEFS) { /* impossible for this pass */
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
        } else /* UNIO_SPEC, not in this pass */ {
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
      /* first, let't get to the top level class entry */

      p_defs = a_defs;
      while (p_defs != NULL && p_defs->pnodetype != CLAS_SPEC) {
        p_defs = p_defs->parent.pdfs;
      }
      if (p_defs != NULL) {
        a_clas_spec = p_defs->parent.pcsp;
        a_type_decl = a_clas_spec->parent.ptdc;
        p_def = a_type_decl->parent.pdef;
        p_defs = p_def->parent.pdfs;

      /* then do the lifting */
        a_defs->pnodetype   = p_defs->pnodetype;
        a_defs->parent.pdfs = p_defs;
        a_defs->next = p_defs->next;
        p_defs->next = a_defs;
        if (a_defs->next != NULL) {
          a_defs->next->parent.pdfs = a_defs;
        }
      }
    }
/*
    flift_func_head(p->afunchead, context);
    if (pt == DEF) p->parent.pdef = (def *) pp;
*/
  }
}

void
flift_func_def(p, context)
func_def *p;
int context;
{ def *p_def;
  defs *p_defs;

  if (p!=NULL) {
    if (context & INCLASS) { /* nonnull classname indicates member function */
      p->classname = make_aname(&current_classname);

      /* backing up to this def entry */
      a_def = p->parent.pdef;
      a_defs = a_def->parent.pdfs;

      /* in place relinking */
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
        } else /* UNIO_SPEC, not in this pass */ {
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

      /* now lift the defs to the top level following the class entry */
      /* first, let't get to the top level class entry */

      p_defs = a_defs;
      while (p_defs != NULL && p_defs->pnodetype != CLAS_SPEC) {
        p_defs = p_defs->parent.pdfs;
      }
      if (p_defs != NULL) {
        a_clas_spec = p_defs->parent.pcsp;
        a_type_decl = a_clas_spec->parent.ptdc;
        p_def = a_type_decl->parent.pdef;
        p_defs = p_def->parent.pdfs;

      /* then do the lifting */

        a_defs->pnodetype   = p_defs->pnodetype;
        a_defs->parent.pdfs = p_defs;
        a_defs->next = p_defs->next;
        p_defs->next = a_defs;
        if (a_defs->next != NULL) {
          a_defs->next->parent.pdfs = a_defs;
        }
      }
    }
/*
    flift_func_head(p->afunchead, context);
    flift_func_body(p->afuncbody, context);
    if (pt == DEF) p->parent.pdef = (def *) pp;
*/
  }
}

void
flift_def(p, context)
def *p;
int context;
{
  if (p!=NULL) {
    flift_func_def(p->afuncdef, context);
    flift_data_decl(p->adatadecl, context);
    flift_type_decl(p->atypedecl, context);
    flift_func_decl(p->afuncdecl, context);
  }
}

void
flift_defs(p, context)
defs *p;
int context;
{ defs *nextdefs;

  if (p!=NULL) {
    nextdefs = p->next;
    flift_def(p->adef, context);
    flift_defs(nextdefs, context);
  }
}


