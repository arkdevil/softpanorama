
/*================== PCYACC ==========================================

            ABRAXAS SOFTWARE (R) PCYACC
      (C)COPYRIGHT PCYACC 1986-88, ABRAXAS SOFTWARE, INC.
               ALL RIGHTS RESERVED

======================================================================*/


#include <stdlib.h>
#include <stdio.h>
#include <malloc.h>
#include <string.h>

#include "const.h"
#include "global.h"

char *make_aname();
defs *tlift_new_defs();

/*
 * this set of routines walking through the syntax tree:
 *   lift deep aggregate {class, struct, union, enum} definitions
 *   appearing as type specifications for data or functions.
 *   for each such definition, a new type definition structure is
 *   created at the global level, if the original is given a name
 *   <name>, this <name> will replace the entire definition in the
 *   original position, while the new top level definition will be
 *   named as <name>_<name>, if the original is nameless, a system
 *   created name will be used as replacement.
 */

void tlift_konst();
void tlift_const_expr();
void tlift_abstract_decl();
void tlift_type_name();
void tlift_id();
void tlift_prim_expr();
void tlift_term();
void tlift_expr();
void tlift_stmt();
void tlift_stmt_list();
void tlift_comp_stmt();
void tlift_arg_decl();
void tlift_args();
void tlift_arg_decl_list();
void tlift_operfunc_name();
void tlift_simp_dname();
void tlift_dname();
void tlift_decl();
void tlift_init_list();
void tlift_init();
void tlift_init_decl();
void tlift_decl_list();
void tlift_ft_spec();
void tlift_sc_spec();
void tlift_class_head();
void tlift_clas_spec();
void tlift_unio_spec();
void tlift_enumerator();
void tlift_enum_list();
void tlift_enum_spec();
void tlift_simp_tname();
void tlift_tp_spec();
void tlift_data_decl();
void tlift_mem_init();
void tlift_mem_init_list();
void tlift_func_body();
void tlift_func_head();
void tlift_type_decl();
void tlift_func_decl();
void tlift_func_def();
void tlift_def();
void tlift_defs();

void
tlift_konst(p)
konst *p;
{

  if (p!=NULL) {
  }
}

void
tlift_const_expr(p)
const_expr *p;
{
  if (p!=NULL) {
    tlift_konst(p->aconst);
  }
}

void
tlift_abstract_decl(p)
abstract_decl *p;
{
  if (p!=NULL) {
    tlift_arg_decl_list(p->aargdecllist);
    tlift_expr(p->aexpr);
    tlift_abstract_decl(p->aabstractdecl);
  }
}

void
tlift_type_name(p)
type_name *p;
{
  if (p!=NULL) {
    tlift_tp_spec(p->atpspec);
    tlift_abstract_decl(p->aabstractdecl);
  }
}						

void
tlift_id(p)
id *p;
{
  if (p!=NULL) {
    tlift_operfunc_name(p->aoperfuncname);
  }
}

void
tlift_prim_expr(p)
prim_expr *p;
{
  if (p!=NULL) {
    tlift_id(p->aid);
    tlift_konst(p->aconst);
    tlift_expr(p->aexpr);
    tlift_prim_expr(p->aprimexpr);
  }
}

void
tlift_term(p)
term *p;
{
  if (p!=NULL) {
    tlift_prim_expr(p->aprimexpr);
    tlift_term(p->aterm);
    tlift_expr(p->aexpr);
    tlift_type_name(p->atypename);
    tlift_simp_tname(p->asimptname);
  }
}

void
tlift_expr(p)
expr *p;
{
  if (p!=NULL) {
    tlift_term(p->aterm);
    tlift_expr(p->aexpr);
    tlift_expr(p->aexpr2);
    tlift_expr(p->aexpr3);
  }
}

void
tlift_stmt(p)
stmt *p;
{
  if (p!=NULL) {
    tlift_expr(p->aexpr);
    tlift_expr(p->aexpr2);
    tlift_stmt(p->astmt);
    tlift_stmt(p->astmt2);
    tlift_data_decl(p->adatadecl);
    tlift_comp_stmt(p->acompstmt);
    tlift_const_expr(p->aconstexpr);
  }
}

void
tlift_stmt_list(p)
stmt_list *p;
{
  if (p!=NULL) {
    tlift_stmt(p->astmt);
    tlift_stmt_list(p->next);
  }
}

void
tlift_comp_stmt(p)
comp_stmt *p;
{
  if (p!=NULL) {
    tlift_stmt_list(p->astmtlist);
  }
}

void
tlift_arg_decl(p)
arg_decl *p;
{
  if (p!=NULL) {
    tlift_tp_spec(p->atpspec);
    tlift_decl(p->adecl);
    tlift_expr(p->aexpr);
    tlift_type_name(p->atypename);
  }
}

void
tlift_args(p)
args *p;
{
  if (p!=NULL) {
    tlift_arg_decl(p->aargdecl);
    tlift_args(p->next);
  }
}

void
tlift_arg_decl_list(p)
arg_decl_list *p;
{
  if (p!=NULL) {
    tlift_args(p->aargs);
  }
}

void
tlift_operfunc_name(p)
operfunc_name *p;
{
  if (p!=NULL) {
  }
}

void
tlift_simp_dname(p)
simp_dname *p;
{
  if (p!=NULL) {
    tlift_operfunc_name(p->aoperfuncname);
  }
}

void
tlift_dname(p)
dname *p;
{
  if (p!=NULL) {
    tlift_simp_dname(p->asimpdname);
  }
}

void
tlift_decl(p)
decl *p;
{
  if (p!=NULL) {
    tlift_dname(p->adname);
    tlift_decl(p->adecl);
    tlift_arg_decl_list(p->aargdecllist);
    tlift_const_expr(p->aconstexpr);
  }
}

void
tlift_init_list(p)
init_list *p;
{
  if (p!=NULL) {
    tlift_expr(p->aexpr);
    tlift_init_list(p->ainitlist);
    tlift_init_list(p->ainitlist2);
  }
}

void
tlift_init(p)
init *p;
{
  if (p!=NULL) {
    tlift_expr(p->aexpr);
    tlift_init_list(p->ainitlist);
  }
}

void
tlift_init_decl(p)
init_decl *p;
{
  if (p!=NULL) {
    tlift_decl(p->adecl);
    tlift_init(p->ainit);
  }
}

void
tlift_decl_list(p)
decl_list *p;
{
  if (p!=NULL) {
    tlift_init_decl(p->ainitdecl);
    tlift_decl(p->adecl);
    tlift_expr(p->aexpr);
    tlift_decl_list(p->next);
  }
}

void
tlift_ft_spec(p)
ft_spec *p;
{
  if (p!=NULL) {
  }
}

void
tlift_sc_spec(p)
sc_spec *p;
{ int sc;

  if (p!=NULL) {
  }
}

void
tlift_class_head(p)
class_head *p;
{
  if (p!=NULL) {
  }
}

void
tlift_clas_spec(p)
clas_spec *p;
{ char *q;

  if (p!=NULL) {
    tlift_class_head(p->aclasshead);
    tlift_defs(p->prdefs);
    tlift_defs(p->pudefs);
    if (p->pnodetype == TP_SPEC) {
      p->pnodetype = TYPE_DECL;
      q = make_aname(&(p->aclasshead->atag));

      /* replace this clas_spec with a simp_tname */
      a_simp_tname = new_simp_tname(FALSE, q);
      a_simp_tname->pnodetype = TP_SPEC;
      a_tp_spec = p->parent.ptsp;
      a_simp_tname->parent.ptsp = a_tp_spec;
      a_tp_spec->aenumspec = NULL;
      a_tp_spec->asimptname = a_simp_tname;

      /* now create appropriate structures for a top level type definition */
      a_type_decl = new_type_decl(NULL, NULL, p);
      a_type_decl->pnodetype = DEF;
      p->parent.ptdc = a_type_decl;
      a_def = new_def(NULL, NULL, a_type_decl, NULL);
      a_def->pnodetype = DEFS;
      a_type_decl->parent.pdef = a_def;
      a_defs = tlift_new_defs(a_def);
      a_defs->pnodetype = DEFS;
      a_defs->parent.pdfs = NULL;
      a_defs->next = a_prog;
      a_prog->parent.pdfs = a_defs;
      a_prog = a_defs;
    } /* p->pnodetype ==  TP_SPEC */
  }
}

void
tlift_unio_spec(p)
unio_spec *p;
{ char *q;

  if (p!=NULL) {
    tlift_defs(p->adefs);
    if (p->pnodetype == TP_SPEC) {
      p->pnodetype = TYPE_DECL;
      q = make_aname(&(p->atag));

      /* replace this unio_spec with a simp_tname */
      a_simp_tname = new_simp_tname(FALSE, q);
      a_simp_tname->pnodetype = TP_SPEC;
      a_tp_spec = p->parent.ptsp;
      a_simp_tname->parent.ptsp = a_tp_spec;
      a_tp_spec->auniospec = NULL;
      a_tp_spec->asimptname = a_simp_tname;

      /* now create appropriate structures for a top level type definition */
      a_type_decl = new_type_decl(NULL, p, NULL);
      a_type_decl->pnodetype = DEF;
      p->parent.ptdc = a_type_decl;
      a_def = new_def(NULL, NULL, a_type_decl, NULL);
      a_def->pnodetype = DEFS;
      a_type_decl->parent.pdef = a_def;
      a_defs = tlift_new_defs(a_def);
      a_defs->pnodetype = DEFS;
      a_defs->parent.pdfs = NULL;
      a_defs->next = a_prog;
      a_prog->parent.pdfs = a_defs;
      a_prog = a_defs;
    } /* p->pnodetype ==  TP_SPEC */
  }
}

void
tlift_enumerator(p)
enumerator *p;
{
  if (p!=NULL) {
    tlift_const_expr(p->aconstexpr) ;
  }
}

void
tlift_enum_list(p)
enum_list *p;
{
  if (p!=NULL) {
    tlift_enumerator(p->aenumerator);
    tlift_enum_list(p->next);
  }
}

void
tlift_enum_spec(p)
enum_spec *p;
{ char *q;

  if (p!=NULL) {
    tlift_enum_list(p->aenumlist);
    if (p->pnodetype == TP_SPEC) {
      p->pnodetype = TYPE_DECL;
      q = make_aname(&(p->atag));

      /* replace this enum_spec with a simp_tname */
      a_simp_tname = new_simp_tname(FALSE, q);
      a_simp_tname->pnodetype = TP_SPEC;
      a_tp_spec = p->parent.ptsp;
      a_simp_tname->parent.ptsp = a_tp_spec;
      a_tp_spec->aenumspec = NULL;
      a_tp_spec->asimptname = a_simp_tname;

      /* now create appropriate structures for a top level type definition */
      a_type_decl = new_type_decl(p, NULL, NULL);
      a_type_decl->pnodetype = DEF;
      p->parent.ptdc = a_type_decl;
      a_def = new_def(NULL, NULL, a_type_decl, NULL);
      a_def->pnodetype = DEFS;
      a_type_decl->parent.pdef = a_def;
      a_defs = tlift_new_defs(a_def);
      a_defs->pnodetype = DEFS;
      a_defs->parent.pdfs = NULL;
      a_defs->next = a_prog;
      a_prog->parent.pdfs = a_defs;
      a_prog = a_defs;
    } /* p->pnodetype ==  TP_SPEC */
  }
}

void
tlift_simp_tname(p)
simp_tname *p;
{
  if (p!=NULL) {
  }
}

void
tlift_tp_spec(p)
tp_spec *p;
{
  if (p!=NULL) {
    tlift_simp_tname(p->asimptname);
    tlift_clas_spec(p->aclasspec);
    tlift_unio_spec(p->auniospec);
    tlift_enum_spec(p->aenumspec);
  }
}

void
tlift_data_decl(p)
data_decl *p;
{
  if (p!=NULL) {
    tlift_sc_spec(p->ascspec);
    tlift_tp_spec(p->atpspec);
    tlift_decl_list(p->adecllist);
  }
}

void
tlift_mem_init(p)
mem_init *p;
{
  if (p!=NULL) {
    tlift_expr(p->aexpr);
  }
}

void
tlift_mem_init_list(p)
mem_init_list *p;
{
  if (p!=NULL) {
    tlift_mem_init(p->ameminit);
    tlift_mem_init_list(p->next);
  }
}

void
tlift_func_body(p)
func_body *p;
{

  if (p!=NULL) {
    tlift_mem_init_list(p->ameminitlist);
    tlift_comp_stmt(p->acompstmt);
  }
}

void
tlift_func_head(p)
func_head *p;
{
  if (p!=NULL) {
    tlift_sc_spec(p->ascspec);
    tlift_ft_spec(p->aftspec);
    tlift_tp_spec(p->atpspec);
    tlift_decl(p->adecl);
    tlift_arg_decl_list(p->aargdecllist);
  }
}

void
tlift_type_decl(p)
type_decl *p;
{
  if (p!=NULL) {
    tlift_enum_spec(p->aenumspec);
    tlift_unio_spec(p->auniospec);
    tlift_clas_spec(p->aclasspec);
  }
}

void
tlift_func_decl(p)
func_decl *p;
{
  if (p!=NULL) {
    tlift_func_head(p->afunchead);
  }
}

void
tlift_func_def(p)
func_def *p;
{
  if (p!=NULL) {
    tlift_func_head(p->afunchead);
    tlift_func_body(p->afuncbody);
  }
}

void
tlift_def(p)
def *p;
{
  if (p!=NULL) {
    tlift_func_def(p->afuncdef);
    tlift_data_decl(p->adatadecl);
    tlift_type_decl(p->atypedecl);
    tlift_func_decl(p->afuncdecl);
  }
}

void
tlift_defs(p)
defs *p;
{
  if (p!=NULL) {
    tlift_def(p->adef);
    tlift_defs(p->next);
  }
}

extern long dymesize;

char *
make_aname(p)
char **p;
{ char *q;
  char n[NMSZ];
  char n2[NMSZ];
  static int count = 1;

  if (*p == NULL) {
    q = itoa(count, n, 10);
    count ++;
    strcpy(n2, "aggr");
    strcat(n2, n);
  } else {
    strcpy(n2, *p);
    free(*p);
  }
  strcpy(n, n2);
  strcpy(n, "-");
  strcpy(n, n2);

  q = (char *) malloc(1 + strlen(n));
  strcpy(q, n);
  *p = q;

  q = (char *) malloc(1 + strlen(n2));
  strcpy(q, n2);
  return(q);
}

defs *
tlift_new_defs(df)
def *df;
{ defs *p;

  dymesize += sizeof(defs);
  p = (defs *) malloc(sizeof(defs));
  if (p==NULL) {
    error(FATAL, "heap overflow");
  } else {
    p->nodetype = DEFS;
    p->adef = df;
    p->next = NULL;
  }
  return (p);
}


