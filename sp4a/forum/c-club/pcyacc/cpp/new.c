
/*================== PCYACC ==========================================

            ABRAXAS SOFTWARE (R) PCYACC
      (C)COPYRIGHT PCYACC 1986-88, ABRAXAS SOFTWARE, INC.
               ALL RIGHTS RESERVED

======================================================================*/


/*
 * routines for allocating syntax tree nodes
 */

#include <stdio.h>
#include <malloc.h>
#include "const.h"
#include "global.h"

extern long dymesize;

konst *
new_konst(cs)
char *cs;
{ konst *p;

  dymesize += sizeof(konst);
  p = (konst *) malloc(sizeof(konst));
  if (p==NULL) {
      error(FATAL, "heap overflow");
  } else {
      p->nodetype = KONST;
      p->constype = EMPTY;
      p->aconst = cs;
      return (p);
  }
}

const_expr *
new_const_expr(cs)
konst *cs;
{ const_expr *p;

  dymesize += sizeof(const_expr);
  p = (const_expr *) malloc(sizeof(const_expr));
  if (p==NULL) {
      error(FATAL, "heap overflow");
  } else {
      p->nodetype = CONST_EXPR;
      p->aconst = cs;
      return (p);
  }
}

abstract_decl *
new_abstract_decl(at, al, ex, ad)
int at;
arg_decl_list *al;
expr *ex;
abstract_decl *ad;
{ abstract_decl *p;

  dymesize += sizeof(abstract_decl);
  p = (abstract_decl *) malloc(sizeof(abstract_decl));
  if (p==NULL) {
      error(FATAL, "heap overflow");
  } else {
      p->nodetype = ABSTRACT_DECL;
      p->absttype = at;
      p->aargdecllist = al;
      p->aexpr = ex;
      p->aabstractdecl = ad;
      return (p);
  }
}

type_name *
new_type_name(ts, ad)
tp_spec *ts;
abstract_decl *ad;
{ type_name *p;

  dymesize += sizeof(type_name);
  p = (type_name *) malloc(sizeof(type_name));
  if (p==NULL) {
      error(FATAL, "heap overflow");
  } else {
      p->nodetype = TYPE_NAME;
      p->atpspec = ts;
      p->aabstractdecl = ad;
      return (p);
  }
}

id *
new_id(tp, va, of)
char *tp;
char *va;
operfunc_name *of;
{ id *p;

  dymesize += sizeof(id);
  p = (id *) malloc(sizeof(id));
  if (p==NULL) {
      error(FATAL, "heap overflow");
  } else {
      p->nodetype = ID;
      p->atyp = tp;
      p->avar = va;
      p->aoperfuncname = of;
      return (p);
  }
}

prim_expr *
new_prim_expr(pt, ai, va, cs, st, ex, pe)
int pt;
id *ai;
char *va;
konst *cs;
char *st;
expr *ex;
prim_expr *pe;
{ prim_expr *p;

  dymesize += sizeof(prim_expr);
  p = (prim_expr *) malloc(sizeof(prim_expr));
  if (p==NULL) {
      error(FATAL, "heap overflow");
  } else {
      p->nodetype = PRIM_EXPR;
      p->primtype = pt;
      p->aid = ai;
      p->avar = va;
      p->aconst = cs;
      p->astring = st;
      p->aexpr = ex;
      p->aprimexpr = pe;
      return (p);
  }
}

term *
new_term(tt, pe, tm, ex, tn, st)
int tt;
prim_expr *pe;
term *tm;
expr *ex;
type_name *tn;
simp_tname *st;
{ term *p;

  dymesize += sizeof(term);
  p = (term *) malloc(sizeof(term));
  if (p==NULL) {
      error(FATAL, "heap overflow");
  } else {
      p->nodetype = TERM;
      p->termtype = tt;
      p->aprimexpr = pe;
      p->aterm = tm;
      p->aexpr = ex;
      p->atypename = tn;
      p->asimptname = st;
      return (p);
  }
}

expr *
new_expr(et, tm, e1, e2, e3)
int et;
term *tm;
expr *e1, *e2, *e3;
{ expr *p;

  dymesize += sizeof(expr);
  p = (expr *) malloc(sizeof(expr));
  if (p==NULL) {
      error(FATAL, "heap overflow");
  } else {
      p->nodetype = EXPR;
      p->exprtype = et;
      p->aterm = tm;
      p->aexpr = e1;
      p->aexpr2 = e2;
      p->aexpr3 = e3;
      return (p);
  }
}

stmt *
new_stmt(st, e1, e2, s1, s2, dd, cs, ce, ai)
int st;
expr *e1, *e2;
stmt *s1, *s2;
data_decl *dd;
comp_stmt *cs;
const_expr *ce;
char *ai;
{ stmt *p;

  dymesize += sizeof(stmt);
  p = (stmt *) malloc(sizeof(stmt));
  if (p==NULL) {
      error(FATAL, "heap overflow");
  } else {
      p->nodetype = STMT;
      p->stmttype = st;
      p->aexpr = e1;
      p->aexpr2 = e2;
      p->astmt = s1;
      p->astmt2 = s2;
      p->adatadecl = dd;
      p->acompstmt = cs;
      p->aconstexpr = ce;
      p->aidentifier = ai;
      return (p);
  }
}

stmt_list *
new_stmt_list(st, nx)
stmt *st;
stmt_list *nx;
{ stmt_list *p;
  stmt_list *q;

  dymesize += sizeof(stmt_list);
  p = (stmt_list *) malloc(sizeof(stmt_list));
  if (p==NULL) {
      error(FATAL, "heap overflow");
  } else {
      p->nodetype = STMT_LIST;
      p->astmt = st;
      p->next = NULL;
      p->prev = NULL;
      if (nx == NULL) {
        return (p);
      } else {
        q = nx;
        while (q->next != NULL) q = q->next;
        q->next = p;
        return (nx);
      }
  }
}

comp_stmt *
new_comp_stmt(sl)
stmt_list *sl;
{ comp_stmt *p;

  dymesize += sizeof(comp_stmt);
  p = (comp_stmt *) malloc(sizeof(comp_stmt));
  if (p==NULL) {
      error(FATAL, "heap overflow");
  } else {
      p->nodetype = COMP_STMT;
      p->astmtlist = sl;
      return (p);
  }
}

arg_decl *
new_arg_decl(ts, dc, ex, tn)
tp_spec *ts;
decl *dc;
expr *ex;
type_name *tn;
{ arg_decl *p;

  dymesize += sizeof(arg_decl);
  p = (arg_decl *) malloc(sizeof(arg_decl));
  if (p==NULL) {
      error(FATAL, "heap overflow");
  } else {
      p->nodetype = ARG_DECL;
      p->atpspec = ts;
      p->adecl = dc;
      p->aexpr = ex;
      p->atypename = tn;
      return (p);
  }
}

args *
new_args(ad, nx)
arg_decl *ad;
args *nx;
{ args *p;
  args *q;

  dymesize += sizeof(args);
  p = (args *) malloc(sizeof(args));
  if (p==NULL) {
      error(FATAL, "heap overflow");
  } else {
      p->nodetype = ARGS;
      p->aargdecl = ad;
      p->next = NULL;
      if (nx == NULL) {
        return (p);
      } else {
        q = nx;
        while (q->next != NULL) q = q->next;
        q->next = p;
        return (nx);
      }
  }
}

arg_decl_list *
new_arg_decl_list(hd, ar)
int hd;
args *ar;
{ arg_decl_list *p;

  dymesize += sizeof(arg_decl_list);
  p = (arg_decl_list *) malloc(sizeof(arg_decl_list));
  if (p==NULL) {
      error(FATAL, "heap overflow");
  } else {
      p->nodetype = ARG_DECL_LIST;
      p->hastridots = hd;
      p->aargs = ar;
      return (p);
  }
}

operfunc_name *
new_operfunc_name(ao)
op ao;
{ operfunc_name *p;

  dymesize += sizeof(operfunc_name);
  p = (operfunc_name *) malloc(sizeof(operfunc_name));
  if (p==NULL) {
      error(FATAL, "heap overflow");
  } else {
      p->nodetype = OPERFUNC_NAME;
      p->aop = ao;
      return (p);
  }
}

simp_dname *
new_simp_dname(hd, ic, ai, of)
int hd;
int ic;
char *ai;
operfunc_name *of;
{ simp_dname *p;

  dymesize += sizeof(simp_dname);
  p = (simp_dname *) malloc(sizeof(simp_dname));
  if (p==NULL) {
      error(FATAL, "heap overflow");
  } else {
      p->nodetype = SIMP_DNAME;
      p->hasdes = hd;
      p->iscons = ic;
      p->aidentifier = ai;
      p->aoperfuncname = of;
      return (p);
  }
}

dname *
new_dname(tp, sd)
char *tp;
simp_dname *sd;
{ dname *p;

  dymesize += sizeof(dname);
  p = (dname *) malloc(sizeof(dname));
  if (p==NULL) {
      error(FATAL, "heap overflow");
  } else {
      p->nodetype = DNAME;
      p->atyp = tp;
      p->asimpdname = sd;
      return (p);
  }
}

decl *
new_decl(dn, ht, hp, hd, he, ie, dc, al, ce)
dname *dn;
int ht, hp, hd, he, ie;
decl *dc;
arg_decl_list *al;
const_expr *ce;
{ decl *p;

  dymesize += sizeof(decl);
  p = (decl *) malloc(sizeof(decl));
  if (p==NULL) {
      error(FATAL, "heap overflow");
  } else {
      p->nodetype = DECL;
      p->adname = dn;
      p->hasast = ht;
      p->hasamp = hp;
      p->hasround = hd;
      p->hassquare = he;
      p->isenclosed = ie;
      p->adecl = dc;
      p->aargdecllist = al;
      p->aconstexpr = ce;
      return (p);
  }
}

init_list *
new_init_list(ex, i1, i2)
expr *ex;
init_list *i1, *i2;
{ init_list *p;

  dymesize += sizeof(init_list);
  p = (init_list *) malloc(sizeof(init_list));
  if (p==NULL) {
      error(FATAL, "heap overflow");
  } else {
      p->nodetype = INIT_LIST;
      p->aexpr = ex;
      p->ainitlist = i1;
      p->ainitlist2 = i2;
      return (p);
  }
}

init *
new_init(ex, il)
expr *ex;
init_list *il;
{ init *p;

  dymesize += sizeof(init);
  p = (init *) malloc(sizeof(init));
  if (p==NULL) {
      error(FATAL, "heap overflow");
  } else {
      p->nodetype = INIT;
      p->aexpr = ex;
      p->ainitlist = il;
      return (p);
  }
}

init_decl *
new_init_decl(dc, in)
decl *dc;
init *in;
{ init_decl *p;

  dymesize += sizeof(init_decl);
  p = (init_decl *) malloc(sizeof(init_decl));
  if (p==NULL) {
      error(FATAL, "heap overflow");
  } else {
      p->nodetype = INIT_DECL;
      p->adecl = dc;
      p->ainit = in;
      return (p);
  }
}

decl_list *
new_decl_list(in, dc, ex, nx)
init_decl *in;
decl *dc;
expr *ex;
decl_list *nx;
{ decl_list *p;
  decl_list *q;

  dymesize += sizeof(decl_list);
  p = (decl_list *) malloc(sizeof(decl_list));
  if (p==NULL) {
      error(FATAL, "heap overflow");
  } else {
      p->nodetype = DECL_LIST;
      p->ainitdecl = in;
      p->adecl = dc;
      p->aexpr = ex;
      p->next = NULL;
      if (nx == NULL) {
        return (p);
      } else {
        q = nx;
        while (q->next != NULL) q = q->next;
        q->next = p;
        return (nx);
      }
  }
}

ft_spec *
new_ft_spec(fc)
char *fc;
{ ft_spec *p;

  dymesize += sizeof(ft_spec);
  p = (ft_spec *) malloc(sizeof(ft_spec));
  if (p==NULL) {
      error(FATAL, "heap overflow");
  } else {
      p->nodetype = FT_SPEC;
      p->aftconst = fc;
      return (p);
  }
}

sc_spec *
new_sc_spec(sc)
char *sc;
{ sc_spec *p;

  dymesize += sizeof(sc_spec);
  p = (sc_spec *) malloc(sizeof(sc_spec));
  if (p==NULL) {
      error(FATAL, "heap overflow");
  } else {
      p->nodetype = SC_SPEC;
      p->ascconst = sc;
      return (p);
  }
}

class_head *
new_class_head(ht, tg, pu, tp)
int ht;
char *tg;
int pu;
char *tp;
{ class_head *p;

  dymesize += sizeof(class_head);
  p = (class_head *) malloc(sizeof(class_head));
  if (p==NULL) {
      error(FATAL, "heap overflow");
  } else {
      p->nodetype = CLASS_HEAD;
      p->headtype = ht;
      p->atag = tg;
      p->ispub = pu;
      p->atyp = tp;
      return (p);
  }
}

clas_spec *
new_clas_spec(ch, pr, pu)
class_head *ch;
defs *pr, *pu;
{ clas_spec *p;

  dymesize += sizeof(clas_spec);
  p = (clas_spec *) malloc(sizeof(clas_spec));
  if (p==NULL) {
      error(FATAL, "heap overflow");
  } else {
      p->nodetype = CLAS_SPEC;
      p->aclasshead = ch;
      p->prdefs = pr;
      p->pudefs = pu;
      return (p);
  }
}

unio_spec *
new_unio_spec(tg, df)
char *tg;
defs *df;
{ unio_spec *p;

  dymesize += sizeof(unio_spec);
  p = (unio_spec *) malloc(sizeof(unio_spec));
  if (p==NULL) {
      error(FATAL, "heap overflow");
  } else {
      p->nodetype = UNIO_SPEC;
      p->atag = tg;
      p->adefs = df;
      return (p);
  }
}

enumerator *
new_enumerator(ai, ce)
char *ai;
const_expr *ce;
{ enumerator *p;

  dymesize += sizeof(enumerator);
  p = (enumerator *) malloc(sizeof(enumerator));
  if (p==NULL) {
      error(FATAL, "heap overflow");
  } else {
      p->nodetype = ENUMERATOR;
      p->aidentifier = ai;
      p->aconstexpr = ce;
      return (p);
  }
}

enum_list *
new_enum_list(en, nx)
enumerator *en;
enum_list *nx;
{ enum_list *p;
  enum_list *q;

  dymesize += sizeof(enum_list);
  p = (enum_list *) malloc(sizeof(enum_list));
  if (p==NULL) {
      error(FATAL, "heap overflow");
  } else {
      p->nodetype = ENUM_LIST;
      p->aenumerator = en;
      p->next = NULL;
      if (nx == NULL) {
        return (p);
      } else {
        q = nx;
        while (q->next != NULL) q = q->next;
        q->next = p;
        return (nx);
      }
  }
}

enum_spec *
new_enum_spec(tg, el)
char *tg;
enum_list *el;
{ enum_spec *p;

  dymesize += sizeof(enum_spec);
  p = (enum_spec *) malloc(sizeof(enum_spec));
  if (p==NULL) {
      error(FATAL, "heap overflow");
  } else {
      p->nodetype = ENUM_SPEC;
      p->atag = tg;
      p->aenumlist = el;
      return (p);
  }
}

simp_tname *
new_simp_tname(hd, st)
int hd;
char *st;
{ simp_tname *p;

  dymesize += sizeof(simp_tname);
  p = (simp_tname *) malloc(sizeof(simp_tname));
  if (p==NULL) {
      error(FATAL, "heap overflow");
  } else {
      p->nodetype = SIMP_TNAME;
      p->hasunsigned = hd;
      p->asimptname = st;
      return (p);
  }
}

tp_spec *
new_tp_spec(ht, st, cs, us, es)
int ht;
simp_tname *st;
clas_spec *cs;
unio_spec *us;
enum_spec *es;
{ tp_spec *p;

  dymesize += sizeof(tp_spec);
  p = (tp_spec *) malloc(sizeof(tp_spec));
  if (p==NULL) {
      error(FATAL, "heap overflow");
  } else {
      p->nodetype = TP_SPEC;
      p->hasconst = ht;
      p->asimptname = st;
      p->aclasspec = cs;
      p->auniospec = us;
      p->aenumspec = es;
      return (p);
  }
}

data_decl *
new_data_decl(hf, ss, ts, dl)
int hf;
sc_spec *ss;
tp_spec *ts;
decl_list *dl;
{ data_decl *p;

  dymesize += sizeof(data_decl);
  p = (data_decl *) malloc(sizeof(data_decl));
  if (p==NULL) {
      error(FATAL, "heap overflow");
  } else {
      p->nodetype = DATA_DECL;
      p->hastypedef = hf;
      p->ascspec = ss;
      p->atpspec = ts;
      p->adecllist = dl;
      return (p);
  }
}

mem_init *
new_mem_init(ai, ex)
char *ai;
expr *ex;
{ mem_init *p;

  dymesize += sizeof(mem_init);
  p = (mem_init *) malloc(sizeof(mem_init));
  if (p==NULL) {
      error(FATAL, "heap overflow");
  } else {
      p->nodetype = MEM_INIT;
      p->aidentifier = ai;
      p->aexpr = ex;
      return (p);
  }
}

mem_init_list *
new_mem_init_list(mi, nx)
mem_init *mi;
mem_init_list *nx;
{ mem_init_list *p;
  mem_init_list *q;

  dymesize += sizeof(mem_init_list);
  p = (mem_init_list *) malloc(sizeof(mem_init_list));
  if (p==NULL) {
      error(FATAL, "heap overflow");
  } else {
      p->nodetype = MEM_INIT_LIST;
      p->ameminit = mi;
      p->next = NULL;
      if (nx == NULL) {
        return (p);
      } else {
        q = nx;
        while (q->next != NULL) q = q->next;
        q->next = p;
        return (nx);
      }
  }
}

func_body *
new_func_body(il, st)
mem_init_list *il;
comp_stmt     *st;
{ func_body *p;

  dymesize += sizeof(func_body);
  p = (func_body *) malloc(sizeof(func_body));
  if (p==NULL) {
      error(FATAL, "heap overflow");
  } else {
      p->nodetype = FUNC_BODY;
      p->ameminitlist = il;
      p->acompstmt = st;
      return (p);
  }
}

func_head *
new_func_head(ss, fs, ts, dc, al)
sc_spec *ss;
ft_spec *fs;
tp_spec *ts;
decl *dc;
arg_decl_list *al;
{ func_head *p;

  dymesize += sizeof(func_head);
  p = (func_head *) malloc(sizeof(func_head));
  if (p==NULL) {
      error(FATAL, "heap overflow");
  } else {
      p->nodetype = FUNC_HEAD;
      p->ascspec = ss;
      p->aftspec = fs;
      p->atpspec = ts;
      p->adecl = dc;
      p->aargdecllist = al;
      return (p);
  }
}

type_decl *
new_type_decl(es, us, cs)
enum_spec *es;
unio_spec *us;
clas_spec *cs;
{ type_decl *p;

  dymesize += sizeof(type_decl);
  p = (type_decl *) malloc(sizeof(type_decl));
  if (p==NULL) {
      error(FATAL, "heap overflow");
  } else {
      p->nodetype = TYPE_DECL;
      p->aenumspec = es;
      p->auniospec = us;
      p->aclasspec = cs;
      return (p);
  }
}

func_decl *
new_func_decl(fh)
func_head *fh;
{ func_decl *p;

  dymesize += sizeof(func_decl);
  p = (func_decl *) malloc(sizeof(func_decl));
  if (p==NULL) {
      error(FATAL, "heap overflow");
  } else {
      p->classname = NULL;
      p->nodetype = FUNC_DECL;
      p->afunchead = fh;
      return (p);
  }
}

func_def *
new_func_def(fh, fb)
func_head *fh;
func_body *fb;
{ func_def *p;

  dymesize += sizeof(func_def);
  p = (func_def *) malloc(sizeof(func_def));
  if (p==NULL) {
      error(FATAL, "heap overflow");
  } else {
      p->classname = NULL;
      p->nodetype = FUNC_DEF;
      p->afunchead = fh;
      p->afuncbody = fb;
      return (p);
  }
}

def *
new_def(fd, dd, td, fc)
func_def *fd;
data_decl *dd;
type_decl *td;
func_decl *fc;
{ def *p;

  dymesize += sizeof(def);
  p = (def *) malloc(sizeof(def));
  if (p==NULL) {
      error(FATAL, "heap overflow");
  } else {
      p->nodetype = DEF;
      p->afuncdef = fd;
      p->adatadecl = dd;
      p->atypedecl = td;
      p->afuncdecl = fc;
      return (p);
  }
}

defs *
new_defs(df, nx)
def *df;
defs *nx;
{ defs *p;
  defs *q;

  dymesize += sizeof(defs);
  p = (defs *) malloc(sizeof(defs));
  if (p==NULL) {
      error(FATAL, "heap overflow");
  } else {
      p->nodetype = DEFS;
      p->adef = df;
      p->next = NULL;
      if (nx == NULL) {
        return (p);
      } else {
        q = nx;
        while (q->next != NULL) q = q->next;
        q->next = p;
        return (nx);
      }
  }
}

