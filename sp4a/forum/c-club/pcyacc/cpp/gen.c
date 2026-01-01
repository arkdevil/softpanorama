
/*================== PCYACC ==========================================

            ABRAXAS SOFTWARE (R) PCYACC
      (C)COPYRIGHT PCYACC 1986-88, ABRAXAS SOFTWARE, INC.
               ALL RIGHTS RESERVED

======================================================================*/


#include <stdio.h>
#include <string.h>
#include "const.h"
#include "global.h"

extern FILE *tempfp;
char *current_classname;

/*
 * c code generation routines
 */

void gcode_konst();
void gcode_const_expr();
void gcode_abstract_decl();
void gcode_type_name();
void gcode_id();
void gcode_prim_expr();
void gcode_term();
void gcode_expr();
void gcode_stmt();
void gcode_stmt_list();
void gcode_comp_stmt();
void gcode_arg_decl();
void gcode_args();
void gcode_arg_decl_list();
void gcode_operfunc_name();
void gcode_simp_dname();
void gcode_dname();
void gcode_decl();
void gcode_init_list();
void gcode_init();
void gcode_init_decl();
void gcode_decl_list();
void gcode_ft_spec();
void gcode_sc_spec();
void gcode_class_head();
void gcode_clas_spec();
void gcode_unio_spec();
void gcode_enumerator();
void gcode_enum_list();
void gcode_enum_spec();
void gcode_simp_tname();
void gcode_tp_spec();
void gcode_data_decl();
void gcode_mem_init();
void gcode_mem_init_list();
void gcode_func_body();
void gcode_func_head();
void gcode_type_decl();
void gcode_func_decl();
void gcode_func_def();
void gcode_def();
void gcode_defs();

void
gcode_konst(p)
konst *p;
{

  if (p!=NULL) {
    fprintf(tempfp, "%s", p->aconst);
  }
}

void
gcode_const_expr(p)
const_expr *p;
{
  if (p!=NULL) {
    gcode_konst(p->aconst);
  }
}

void
gcode_abstract_decl(p)
abstract_decl *p;
{
  if (p!=NULL) {
    switch (p->absttype) {
      case AST: {
        fprintf(tempfp, "*");
        break;
      }
      case PAR: {
        fprintf(tempfp, "()");
        break;
      }
      case ARG: {
        fprintf(tempfp, "(");
        gcode_arg_decl_list(p->aargdecllist);
        fprintf(tempfp, ")");
        break;
      }
      case CON: {
        fprintf(tempfp, "[");
        gcode_expr(p->aexpr);
        fprintf(tempfp, "]");
        break;
      }
      case VEC: {
        fprintf(tempfp, "[]");
        break;
      }
      case ASA: {
        fprintf(tempfp, "*");
        gcode_abstract_decl(p->aabstractdecl);
        break;
      }
      case APA: {
        gcode_abstract_decl(p->aabstractdecl);
        fprintf(tempfp, "()");
        break;
      }
      case AAR: {
        gcode_abstract_decl(p->aabstractdecl);
        fprintf(tempfp, "(");
        gcode_arg_decl_list(p->aargdecllist);
        fprintf(tempfp, ")");
        break;
      }
      case ACO: {
        gcode_abstract_decl(p->aabstractdecl);
        fprintf(tempfp, "[");
        gcode_expr(p->aexpr);
        fprintf(tempfp, "]");
        break;
      }
      case AVE: {
        gcode_abstract_decl(p->aabstractdecl);
        fprintf(tempfp, "[]");
        break;
      }
      default: {
        break;
      }
    }
  }
}

void
gcode_type_name(p)
type_name *p;
{
  if (p!=NULL) {
    gcode_tp_spec(p->atpspec);
    gcode_abstract_decl(p->aabstractdecl);
  }
}						

void
gcode_id(p)
id *p;
{
  if (p!=NULL) {
    if (p->atyp != NULL) {
      fprintf(tempfp, "%s_", p->atyp);
    }
    gcode_operfunc_name(p->aoperfuncname);
    if (p->avar != NULL) {
      fprintf(tempfp, "%s", p->avar);
    }
  }
}

void
gcode_prim_expr(p)
prim_expr *p;
{
  if (p!=NULL) {
    switch (p->primtype) {
      case IDP: {
        gcode_id(p->aid);
        break;
      }
      case VAP: {
        fprintf(tempfp, "%s ", p->avar);
        break;
      }
      case COP: {
        gcode_konst(p->aconst);
        break;
      }
      case STP: {
        fprintf(tempfp, "%s ", p->astring);
        break;
      }
      case THP: {
        fprintf(tempfp, "this");
        break;
      }
      case EXP: {
        fprintf(tempfp, "(");
        gcode_expr(p->aexpr);
        fprintf(tempfp, ")");
        break;
      }
      case VCP: {
        gcode_prim_expr(p->aprimexpr);
        fprintf(tempfp, "[");
        gcode_expr(p->aexpr);
        fprintf(tempfp, "]");
        break;
      }
      case FCP: {
        gcode_prim_expr(p->aprimexpr);
        fprintf(tempfp, "(");
        gcode_expr(p->aexpr);
        fprintf(tempfp, ")");
        break;
      }
      case MEP: {
        gcode_prim_expr(p->aprimexpr);
        fprintf(tempfp, ".");
        gcode_id(p->aid);
        break;
      }
      case PTP: {
        gcode_prim_expr(p->aprimexpr);
        fprintf(tempfp, "->");
        gcode_id(p->aid);
        break;
      }
      default: {
        break;
      }
    }
  }
}

void
gcode_term(p)
term *p;
{
  if (p!=NULL) {
    switch (p->termtype) {
      case PRM: {
        gcode_prim_expr(p->aprimexpr);
        break;
      }
      case DRT: {
        fprintf(tempfp, "*");
        gcode_term(p->aterm);
        break;
      }
      case RFT: {
        fprintf(tempfp, "*");
        gcode_term(p->aterm);
        break;
      }
      case POT: {
        fprintf(tempfp, "+");
        gcode_term(p->aterm);
        break;
      }
      case NET: {
        fprintf(tempfp, "-");
        gcode_term(p->aterm);
        break;
      }
      case BNT: {
        fprintf(tempfp, "~");
        gcode_term(p->aterm);
        break;
      }
      case NOT: {
        fprintf(tempfp, "!");
        gcode_term(p->aterm);
        break;
      }
      case BIT: {
        fprintf(tempfp, "++");
        gcode_term(p->aterm);
        break;
      }
      case BDT: {
        fprintf(tempfp, "--");
        gcode_term(p->aterm);
        break;
      }
      case AIT: {
        gcode_term(p->aterm);
        fprintf(tempfp, "++");
        break;
      }
      case ADT: {
        gcode_term(p->aterm);
        fprintf(tempfp, "--");
        break;
      }
      case SZE: {
        fprintf(tempfp, "sizeof(");
        gcode_expr(p->aexpr);
        fprintf(tempfp, ")");
        break;
      }
      case SZN: {
        fprintf(tempfp, "sizeof(");
        gcode_type_name(p->atypename);
        fprintf(tempfp, ")");
        break;
      }
      case CS1: {
        fprintf(tempfp, "(");
        gcode_type_name(p->atypename);
        fprintf(tempfp, ") ");
        gcode_prim_expr(p->aprimexpr);
        break;
      }
      case CS2: {
        gcode_simp_tname(p->asimptname);
        fprintf(tempfp, "(");
        gcode_expr(p->aexpr);
        fprintf(tempfp, ") ");
        break;
      }
      case NEX: {
        fprintf(tempfp, "( ");
        a_type_name = p->atypename;
        a_tp_spec = a_type_name->atpspec;
        a_abstract_decl = a_type_name->aabstractdecl;
        if (a_abstract_decl != NULL) {
          a_expr = a_abstract_decl->aexpr;
        } else {
          a_expr = NULL;
        }
        gcode_tp_spec(a_tp_spec);
        fprintf(tempfp, "*) malloc(sizeof(");
        gcode_tp_spec(a_tp_spec);
        fprintf(tempfp, ")");
        if (a_expr != NULL) fprintf(tempfp, " * ");
        gcode_expr(a_expr);
        fprintf(tempfp, ")");
        break;
      }
      case NTP: {
        fprintf(tempfp, "( ");
        a_type_name = p->atypename;
        a_tp_spec = a_type_name->atpspec;
        a_abstract_decl = a_type_name->aabstractdecl;
        if (a_abstract_decl != NULL) {
          a_expr = a_abstract_decl->aexpr;
        } else {
          a_expr = NULL;
        }
        gcode_tp_spec(a_tp_spec);
        fprintf(tempfp, "*) malloc(sizeof(");
        gcode_tp_spec(a_tp_spec);
        fprintf(tempfp, ")");
        if (a_expr != NULL) fprintf(tempfp, " * ");
        gcode_expr(a_expr);
        fprintf(tempfp, ")");
        break;
      }
      case DLE: {
        fprintf(tempfp, "free(");
        gcode_expr(p->aexpr);
        fprintf(tempfp, ")");
        break;
      }
      case DLV: {
        break;
      }
      default: {
        break;
      }
    }
  }
}

void
gcode_expr(p)
expr *p;
{
  if (p!=NULL) {
    if (p->exprtype == TRM) {
      gcode_term(p->aterm);
    } else {
      gcode_expr(p->aexpr);
      switch (p->exprtype) {
        case MUL: {
          fprintf(tempfp, " * ");
          break;
        }
        case DIV: {
          fprintf(tempfp, " / ");
        break;
        }
        case MOD: {
          fprintf(tempfp, " % ");
        break;
        }
        case ADD: {
          fprintf(tempfp, " + ");
        break;
        }
        case SUB: {
          fprintf(tempfp, " - ");
        break;
        }
        case SHL: {
          fprintf(tempfp, " << ");
        break;
        }
        case SHR: {
          fprintf(tempfp, " >> ");
        break;
        }
        case LES: {
          fprintf(tempfp, " < ");
        break;
        }
        case GRT: {
          fprintf(tempfp, " > ");
        break;
        }
        case LSE: {
          fprintf(tempfp, " <= ");
        break;
        }
        case EQU: {
          fprintf(tempfp, " == ");
        break;
        }
        case NEQ: {
          fprintf(tempfp, " != ");
        break;
        }
        case BAN: {
          fprintf(tempfp, " & ");
        break;
        }
        case BEX: {
          fprintf(tempfp, " ^ ");
        break;
        }
        case BOR: {
          fprintf(tempfp, " | ");
        break;
        }
        case LAN: {
          fprintf(tempfp, " && ");
        break;
        }
        case LOR: {
          fprintf(tempfp, " || ");
        break;
        }
        case ASS: {
          fprintf(tempfp, " = ");
        break;
        }
        case ADA: {
          fprintf(tempfp, " += ");
        break;
        }
        case SBA: {
          fprintf(tempfp, " -= ");
        break;
        }
        case MUA: {
          fprintf(tempfp, " *= ");
        break;
        }
        case DVA: {
          fprintf(tempfp, " /= ");
        break;
        }
        case MDA: {
          fprintf(tempfp, " %= ");
        break;
        }
        case ANA: {
          fprintf(tempfp, " &= ");
        break;
        }
        case ORA: {
          fprintf(tempfp, " |= ");
        break;
        }
        case LSA: {
          fprintf(tempfp, " <<= ");
        break;
        }
        case RSA: {
          fprintf(tempfp, " >>= ");
        break;
        }
        case COM: {
          fprintf(tempfp, " , ");
        break;
        }
        default: {
          break;
        }
      }
      gcode_expr(p->aexpr2);
    }
    if (p->exprtype == CNE) {
      gcode_expr(p->aexpr);
      fprintf(tempfp, " ? ");
      gcode_expr(p->aexpr2);
      fprintf(tempfp, " : ");
      gcode_expr(p->aexpr3);
    }
  }
}

void
gcode_stmt(p)
stmt *p;
{
  if (p!=NULL) {
    if (p->stmttype == DAST) {
      gcode_data_decl(p->adatadecl);
    } else if (p->stmttype == CMST) {
      gcode_comp_stmt(p->acompstmt);
    } else if (p->stmttype == EXST) {
      gcode_expr(p->aexpr);
      fprintf(tempfp, ";\n");
    } else if (p->stmttype == NUST) {
      fprintf(tempfp, ";\n");
    } else if (p->stmttype == IFST) {
      fprintf(tempfp, "if (");
      gcode_expr(p->aexpr);
      fprintf(tempfp, ") ");
      gcode_stmt(p->astmt);
    } else if (p->stmttype == IEST) {
      fprintf(tempfp, "if (");
      gcode_expr(p->aexpr);
      fprintf(tempfp, ") ");
      gcode_stmt(p->astmt);
      fprintf(tempfp, "\nelse ");
      gcode_stmt(p->astmt2);
    } else if (p->stmttype == WHST) {
      fprintf(tempfp, "while (");
      gcode_expr(p->aexpr);
      fprintf(tempfp, ") ");
      gcode_stmt(p->astmt);
    } else if (p->stmttype == DOST) {
      fprintf(tempfp, "do ");
      gcode_stmt(p->astmt);
      fprintf(tempfp, "while (");
      gcode_expr(p->aexpr);
      fprintf(tempfp, ");\n");
    } else if (p->stmttype == F1ST) {
      fprintf(tempfp, "for (");
      gcode_stmt(p->astmt);
      gcode_expr(p->aexpr);
      fprintf(tempfp, ";");
      gcode_expr(p->aexpr2);
      fprintf(tempfp, ")");
      gcode_stmt(p->astmt2);
    } else if (p->stmttype == F2ST) {
      fprintf(tempfp, "for (");
      gcode_stmt(p->astmt);
      fprintf(tempfp, ";");
      gcode_expr(p->aexpr2);
      fprintf(tempfp, ")");
      gcode_stmt(p->astmt2);
    } else if (p->stmttype == F3ST) {
      fprintf(tempfp, "for (");
      gcode_stmt(p->astmt);
      gcode_expr(p->aexpr);
      fprintf(tempfp, ";");
      fprintf(tempfp, ")");
      gcode_stmt(p->astmt2);
    } else if (p->stmttype == F4ST) {
      fprintf(tempfp, "for (");
      gcode_stmt(p->astmt);
      fprintf(tempfp, ";");
      fprintf(tempfp, ")");
      gcode_stmt(p->astmt2);
    } else if (p->stmttype == SWST) {
      fprintf(tempfp, "switch (");
      gcode_expr(p->aexpr);
      fprintf(tempfp, ")");
      gcode_stmt(p->astmt);
    } else if (p->stmttype == CAST) {
      fprintf(tempfp, "case ");
      gcode_const_expr(p->aconstexpr);
      fprintf(tempfp, ": ");
      gcode_stmt(p->astmt);
    } else if (p->stmttype == DEST) {
      fprintf(tempfp, "default: ");
      gcode_stmt(p->astmt);
    } else if (p->stmttype == BRST) {
      fprintf(tempfp, "break;\n");
    } else if (p->stmttype == COST) {
      fprintf(tempfp, "continue;\n");
    } else if (p->stmttype == REST) {
      fprintf(tempfp, "return ");
      gcode_expr(p->aexpr);
      fprintf(tempfp, ";\n");
    } else if (p->stmttype == GOST) {
      fprintf(tempfp, "goto %s;\n", p->aidentifier);
    } else if (p->stmttype == LAST) {
      fprintf(tempfp, "%s: ", p->aidentifier);
      gcode_stmt(p->astmt);
    }
  }
}

void
gcode_stmt_list(p)
stmt_list *p;
{
  if (p!=NULL) {
    gcode_stmt(p->astmt);
    gcode_stmt_list(p->next);
  }
}

void
gcode_comp_stmt(p)
comp_stmt *p;
{
  if (p!=NULL) {
    fprintf(tempfp, "{\n");
    gcode_stmt_list(p->astmtlist);
    fprintf(tempfp, "}\n");
  }
}

void
gcode_arg_decl(p)
arg_decl *p;
{
  if (p!=NULL) {
    gcode_tp_spec(p->atpspec);
    gcode_decl(p->adecl);
/*    gcode_expr(p->aexpr); */
    gcode_type_name(p->atypename);
  }
}

void
gcode_args(p)
args *p;
{
  if (p!=NULL) {
    gcode_arg_decl(p->aargdecl);
    if (p->next != NULL) {
      fprintf(tempfp, ", ");
    }
    gcode_args(p->next);
  }
}

void
gcode_arg_decl_list(p)
arg_decl_list *p;
{
  if (p!=NULL) {
    gcode_args(p->aargs);
    if (p->aargs != NULL && p->hastridots) {
      fprintf(tempfp, ", ... ");
    }
  }
}

void
gcode_operfunc_name(p)
operfunc_name *p;
{
  if (p!=NULL) {
/*
    if (pt == ID) p->parent.pid = (id *) pp;
    else if (pt == SIMP_DNAME) p->parent.psdn = (simp_dname *) pp;
*/
  }
}

void
gcode_simp_dname(p)
simp_dname *p;
{
  if (p!=NULL) {
    gcode_operfunc_name(p->aoperfuncname);
    if (p->aidentifier != NULL) {
      if (p->hasdes) {
        fprintf(tempfp, "_%s", p->aidentifier);
      } else {
        fprintf(tempfp, "%s ", p->aidentifier);
      }
    }
  }
}

void
gcode_dname(p)
dname *p;
{
  if (p!=NULL) {
    if (p->atyp != NULL) {
      fprintf(tempfp, "%s_", p->atyp);
    }
    gcode_simp_dname(p->asimpdname);
  }
}

void
gcode_decl(p)
decl *p;
{
  if (p!=NULL) {
    gcode_dname(p->adname);
    if (p->hasast || p->hasamp) {
      fprintf(tempfp, "*");
    } else if (p->isenclosed) {
      fprintf(tempfp, "(");
    }
    gcode_decl(p->adecl);
    if (p->isenclosed) {
      fprintf(tempfp, ")");
    } else if (p->hassquare) {
      fprintf(tempfp, "[");
    }
    gcode_arg_decl_list(p->aargdecllist);
    gcode_const_expr(p->aconstexpr);
    if (p->hassquare) {
      fprintf(tempfp, "]");
    }
  }
}

void
gcode_init_list(p)
init_list *p;
{
  if (p!=NULL) {
    fprintf(tempfp, "{");
    gcode_expr(p->aexpr);
    gcode_init_list(p->ainitlist);
    if (p->ainitlist != NULL) {
      fprintf(tempfp, ",\n");
    }
    gcode_init_list(p->ainitlist2);
    fprintf(tempfp, "}");
  }
}

void
gcode_init(p)
init *p;
{
  if (p!=NULL) {
    fprintf(tempfp, "= ");
    gcode_expr(p->aexpr);
    gcode_init_list(p->ainitlist);
  }
}

void
gcode_init_decl(p)
init_decl *p;
{
  if (p!=NULL) {
    gcode_decl(p->adecl);
    gcode_init(p->ainit);
  }
}

void
gcode_decl_list(p)
decl_list *p;
{
  if (p!=NULL) {
    gcode_init_decl(p->ainitdecl);
    gcode_decl(p->adecl);
    if (p->aexpr != NULL) {
      fprintf(tempfp, "(");
    }
    gcode_expr(p->aexpr);
    if (p->aexpr != NULL) {
      fprintf(tempfp, ") ");
    } else if (p->next != NULL) {
      fprintf(tempfp, ", ");
    }
    gcode_decl_list(p->next);
  }
}

void
gcode_ft_spec(p)
ft_spec *p;
{
  if (p!=NULL) {
    fprintf(tempfp, "%s ", p->aftconst);
  }
}

void
gcode_sc_spec(p)
sc_spec *p;
{ int sc;

  if (p!=NULL) {
    fprintf(tempfp, "%s ", p->ascconst);
  }
}

void
gcode_class_head(p)
class_head *p;
{
  if (p!=NULL) {
    fprintf(tempfp, "struct %s {\n", p->atag);
  }
}

void
gcode_clas_spec(p)
clas_spec *p;
{

  if (p!=NULL) {
    gcode_class_head(p->aclasshead);
    gcode_defs(p->prdefs);
    gcode_defs(p->pudefs);
    fprintf(tempfp, "}");
  }
}

void
gcode_unio_spec(p)
unio_spec *p;
{

  if (p!=NULL) {
    fprintf(tempfp, "union %s {\n", p->atag);
    gcode_defs(p->adefs);
    fprintf(tempfp, "}");
  }
}

void
gcode_enumerator(p)
enumerator *p;
{
  if (p!=NULL) {
    fprintf(tempfp, "%s ", p->aidentifier);
    gcode_const_expr(p->aconstexpr) ;
  }
}

void
gcode_enum_list(p)
enum_list *p;
{
  if (p!=NULL) {
    gcode_enumerator(p->aenumerator);
    fprintf(tempfp, ",\n");
    gcode_enum_list(p->next);
  }
}

void
gcode_enum_spec(p)
enum_spec *p;
{
  if (p!=NULL) {
    fprintf(tempfp, "enum %s {\n", p->atag);
    gcode_enum_list(p->aenumlist);
    fprintf(tempfp, "}");
  }
}

void
gcode_simp_tname(p)
simp_tname *p;
{
  if (p!=NULL) {
    if (p->hasunsigned) {
      fprintf(tempfp, "unsigned %s ", p->asimptname);
    } else {
      fprintf(tempfp, "%s ", p->asimptname);
    }
  }
}

void
gcode_tp_spec(p)
tp_spec *p;
{
  if (p!=NULL) {
    gcode_simp_tname(p->asimptname);
    gcode_clas_spec(p->aclasspec);
    gcode_unio_spec(p->auniospec);
    gcode_enum_spec(p->aenumspec);
  }
}

void
gcode_data_decl(p)
data_decl *p;
{
  if (p!=NULL) {
    if (p->hastypedef) {
      fprintf(tempfp, "typedef ");
    }
    gcode_sc_spec(p->ascspec);
    gcode_tp_spec(p->atpspec);
    gcode_decl_list(p->adecllist);
    fprintf(tempfp, ";\n");
  }
}

void
gcode_mem_init(p)
mem_init *p;
{
  if (p!=NULL) {
    gcode_expr(p->aexpr);
  }
}

void
gcode_mem_init_list(p)
mem_init_list *p;
{
  if (p!=NULL) {
    gcode_mem_init(p->ameminit);
    gcode_mem_init_list(p->next);
  }
}

void
gcode_func_body(p)
func_body *p;
{

  if (p!=NULL) {
    gcode_mem_init_list(p->ameminitlist);
    gcode_comp_stmt(p->acompstmt);
  }
}

void
gcode_func_head(p)
func_head *p;
{
  if (p!=NULL) {
    gcode_sc_spec(p->ascspec);
    gcode_ft_spec(p->aftspec);
    gcode_tp_spec(p->atpspec);
    if (a_func_def != NULL && a_func_def->classname != NULL) {
      fprintf(tempfp, "%s_", a_func_def->classname);
    } else if (a_func_decl != NULL && a_func_decl->classname != NULL) {
      fprintf(tempfp, "%s_", a_func_decl->classname);
    }
    gcode_decl(p->adecl);
    fprintf(tempfp, "(");
    gcode_arg_decl_list(p->aargdecllist);
    fprintf(tempfp, ")");
  }
}

void
gcode_type_decl(p)
type_decl *p;
{
  if (p!=NULL) {
    gcode_enum_spec(p->aenumspec);
    gcode_unio_spec(p->auniospec);
    gcode_clas_spec(p->aclasspec);
    fprintf(tempfp, ";\n");
  }
}

void
gcode_func_decl(p)
func_decl *p;
{
  if (p!=NULL) {
    a_func_decl = p;
    gcode_func_head(p->afunchead);
    fprintf(tempfp, ";\n");
    a_func_decl = NULL;
  }
}

void
gcode_func_def(p)
func_def *p;
{
  if (p!=NULL) {
    a_func_def = p;
    gcode_func_head(p->afunchead);
    gcode_func_body(p->afuncbody);
    a_func_def = NULL;
  }
}

void
gcode_def(p)
def *p;
{
  if (p!=NULL) {
    gcode_func_def(p->afuncdef);
    gcode_data_decl(p->adatadecl);
    gcode_type_decl(p->atypedecl);
    gcode_func_decl(p->afuncdecl);
  }
}

void
gcode_defs(p)
defs *p;
{
  if (p!=NULL) {
    gcode_def(p->adef);
    gcode_defs(p->next);
  }
}

