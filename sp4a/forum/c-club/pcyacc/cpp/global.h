
/*================== PCYACC ==========================================

            ABRAXAS SOFTWARE (R) PCYACC
      (C)COPYRIGHT PCYACC 1986-88, ABRAXAS SOFTWARE, INC.
               ALL RIGHTS RESERVED

======================================================================*/


/*
 * type declarations
 */

typedef struct const_s konst;
typedef struct const_expr_s const_expr;
typedef struct abstract_decl_s abstract_decl;
typedef struct type_name_s type_name;
typedef int op;
typedef struct id_s id;
typedef struct prim_expr_s prim_expr;
typedef struct term_s term;
typedef struct expr_s expr;
typedef struct stmt_s stmt;
typedef struct stmt_list_s stmt_list;
typedef struct comp_stmt_s comp_stmt;
typedef struct arg_decl_s arg_decl;
typedef struct args_s args;
typedef struct arg_decl_list_s arg_decl_list;
typedef struct operfunc_name_s operfunc_name;
typedef struct simp_dname_s simp_dname;
typedef struct dname_s dname;
typedef struct decl_s decl;
typedef struct init_list_s init_list;
typedef struct init_s init;
typedef struct init_decl_s init_decl;
typedef struct decl_list_s decl_list;
typedef struct ft_spec_s ft_spec;
typedef struct sc_spec_s sc_spec;
typedef struct class_head_s class_head;
typedef struct clas_spec_s clas_spec;
typedef struct unio_spec_s unio_spec;
typedef struct enumerator_s enumerator;
typedef struct enum_list_s enum_list;
typedef struct enum_spec_s enum_spec;
typedef struct simp_tname_s simp_tname;
typedef struct tp_spec_s tp_spec;
typedef struct data_decl_s data_decl;
typedef struct mem_init_s mem_init;
typedef struct mem_init_list_s mem_init_list;
typedef struct func_body_s func_body;
typedef struct func_head_s func_head;
typedef struct type_decl_s type_decl;
typedef struct func_decl_s func_decl;
typedef struct func_def_s func_def;
typedef struct def_s def;
typedef struct defs_s defs;

typedef union {
  defs          *pdfs;
  def           *pdef;
  func_def      *pfdf;
  type_decl     *ptdc;
  func_decl     *pfdc;
  func_head     *pfhd;
  func_body     *pfbd;
  mem_init_list *pmil;
  mem_init      *pmin;
  data_decl     *pddc;
  tp_spec       *ptsp;
  simp_tname    *pstn;
  enum_spec     *pesp;
  enum_list     *pels;
  enumerator    *penm;
  unio_spec     *pusp;
  clas_spec     *pcsp;
  class_head    *pchd;
  sc_spec       *pssp;
  ft_spec       *pfsp;
  decl_list     *pdls;
  init_decl     *pidc;
  init          *pini;
  init_list     *pils;
  decl          *pdcl;
  dname         *pdnm;
  simp_dname    *psdn;
  operfunc_name *pofn;
  arg_decl_list *padl;
  args          *parg;
  arg_decl      *padc;
  comp_stmt     *pcst;
  stmt_list     *psls;
  stmt          *pstm;
  expr          *pexp;
  term          *ptrm;
  prim_expr     *ppex;
  id            *pid;
  op             pop;
  type_name     *ptnm;
  abstract_decl *pabs;
  const_expr    *pcex;
  konst         *pcon;
  char          *pchr;
} YYSTYPE;

/*
 * symbolic node types
 */

#define DEFS           0
#define DEF            1
#define FUNC_DEF       2
#define TYPE_DECL      3
#define FUNC_DECL      4
#define FUNC_HEAD      5
#define FUNC_BODY      6
#define MEM_INIT_LIST  7
#define MEM_INIT       8
#define DATA_DECL      9
#define TP_SPEC       10
#define SIMP_TNAME    11
#define ENUM_SPEC     12
#define ENUM_LIST     13
#define ENUMERATOR    14
#define UNIO_SPEC     15
#define CLAS_SPEC     16
#define CLASS_HEAD    17
#define SC_SPEC       18
#define FT_SPEC       19
#define DECL_LIST     20
#define INIT_DECL     21
#define INIT          22
#define INIT_LIST     23
#define DECL          24
#define DNAME         25
#define SIMP_DNAME    26
#define OPERFUNC_NAME 27
#define ARG_DECL_LIST 28
#define ARGS          29
#define ARG_DECL      30
#define COMP_STMT     31
#define STMT_LIST     32
#define STMT          33
#define EXPR          34
#define TERM          35
#define PRIM_EXPR     36
#define ID            37
#define OP            38
#define TYPE_NAME     39
#define ABSTRACT_DECL 40
#define CONST_EXPR    41
#define KONST         42

/*
 * data structure declarations for building parse trees
 */

/* for constype */
#define ICO 0 
#define CCO 1
#define FCO 2

struct const_s {
    int constype;
    char *aconst;
    int nodetype;
    int pnodetype;
    YYSTYPE parent;
};

struct const_expr_s {
    konst *aconst;
    int nodetype;
    int pnodetype;
    YYSTYPE parent;
};

/* for absttype */
#define AST 0
#define PAR 1
#define ARG 2
#define CON 3
#define VEC 5
#define ASA 6
#define APA 7
#define AAR 8
#define ACO 9
#define AVE 10

struct abstract_decl_s {
    int absttype;
    arg_decl_list *aargdecllist;
    expr *aexpr;
    abstract_decl *aabstractdecl;
    int nodetype;
    int pnodetype;
    YYSTYPE parent;
};

struct type_name_s {
    tp_spec *atpspec;
    abstract_decl *aabstractdecl;
    int nodetype;
    int pnodetype;
    YYSTYPE parent;
};

struct id_s {
    char *atyp;
    char *avar;
    operfunc_name *aoperfuncname;
    int nodetype;
    int pnodetype;
    YYSTYPE parent;
};

/* for primtype */
#define IDP 0
#define VAP 1
#define COP 2
#define STP 3
#define THP 4
#define EXP 5
#define VCP 6
#define FCP 7
#define MEP 8
#define PTP 9

struct prim_expr_s {
    int primtype;
    id *aid;
    char *avar;
    konst *aconst;
    char *astring;
    expr *aexpr;
    prim_expr *aprimexpr;
    int nodetype;
    int pnodetype;
    YYSTYPE parent;
};
    
/* for termtype */
#define PRM 0
#define DRT 1
#define RFT 2
#define POT 3
#define NET 4
#define BNT 5
#define NOT 6
#define BIT 19
#define BDT 7
#define AIT 8
#define ADT 9
#define SZE 10
#define SZN 11
#define NTP 12
#define NEX 13
#define CS1 15
#define CS2 16
#define DLE 17
#define DLV 18

struct term_s {
    int termtype;
    prim_expr *aprimexpr;
    term *aterm;
    expr *aexpr;
    type_name *atypename;
    simp_tname *asimptname;
    int nodetype;
    int pnodetype;
    YYSTYPE parent;
};

/* for exprtype */
#define TRM 0
#define MUL 1
#define DIV 2
#define MOD 3
#define ADD 4
#define SUB 5
#define SHL 6
#define SHR 7
#define LES 8
#define GRT 9
#define GTE 10
#define LSE 11
#define EQU 12
#define NEQ 13
#define BAN 14
#define BEX 15
#define BOR 16
#define LAN 17
#define LOR 18
#define ASS 19
#define ADA 20
#define SBA 21
#define MUA 22
#define DVA 23
#define MDA 24
#define EXA 25
#define ANA 26
#define ORA 27
#define LSA 28
#define RSA 29
#define CNE 30
#define COM 31

struct expr_s {
    int exprtype;
    term *aterm;
    expr *aexpr;
    expr *aexpr2;
    expr *aexpr3;
    int nodetype;
    int pnodetype;
    YYSTYPE parent;
};

/* for stmttype */
#define NUST 0
#define IFST 1
#define IEST 2
#define WHST 3
#define DOST 4
#define F1ST 5
#define F2ST 6
#define F3ST 7
#define F4ST 8
#define SWST 9
#define CAST 10
#define DEST 11
#define BRST 12
#define COST 13
#define REST 14
#define GOST 15
#define LAST 16
#define EXST 17
#define CMST 18
#define DAST 19

struct stmt_s {
    int stmttype;
    expr *aexpr;
    expr *aexpr2;
    stmt *astmt;
    stmt *astmt2;
    data_decl *adatadecl;
    comp_stmt *acompstmt;
    const_expr *aconstexpr;
    char *aidentifier;
    int nodetype;
    int pnodetype;
    YYSTYPE parent;
};
    
struct stmt_list_s {
    stmt *astmt;
    stmt_list *next;
    stmt_list *prev;
    int nodetype;
    int pnodetype;
    YYSTYPE parent;
};

struct comp_stmt_s {
    stmt_list *astmtlist;
    int nodetype;
    int pnodetype;
    YYSTYPE parent;
};

struct arg_decl_s {
    tp_spec *atpspec;
    decl *adecl;
    expr *aexpr;
    type_name *atypename;
    int nodetype;
    int pnodetype;
    YYSTYPE parent;
};

struct args_s {
    arg_decl *aargdecl;
    args *next;
    int nodetype;
    int pnodetype;
    YYSTYPE parent;
};

struct arg_decl_list_s {
    int hastridots;
    args *aargs;
    int nodetype;
    int pnodetype;
    YYSTYPE parent;
};

struct operfunc_name_s {
    op aop;
    int nodetype;
    int pnodetype;
    YYSTYPE parent;
};

struct simp_dname_s {
    int hasdes;
    int iscons;
    char *aidentifier;
    operfunc_name *aoperfuncname;
    int nodetype;
    int pnodetype;
    YYSTYPE parent;
};
    
struct dname_s {
    char *atyp;
    simp_dname *asimpdname;
    int nodetype;
    int pnodetype;
    YYSTYPE parent;
};

struct decl_s {
    dname *adname;
    int hasast;
    int hasamp;
    int hasround;
    int hassquare;
    int isenclosed;
    decl *adecl;
    arg_decl_list *aargdecllist;
    const_expr *aconstexpr;
    int nodetype;
    int pnodetype;
    YYSTYPE parent;
};

struct init_list_s {
    expr *aexpr;
    init_list *ainitlist;
    init_list *ainitlist2;
    int nodetype;
    int pnodetype;
    YYSTYPE parent;
};

struct init_s {
    expr *aexpr;
    init_list *ainitlist;
    int nodetype;
    int pnodetype;
    YYSTYPE parent;
};

struct init_decl_s {
    decl *adecl;
    init *ainit;
    int nodetype;
    int pnodetype;
    YYSTYPE parent;
};

struct decl_list_s {
    init_decl *ainitdecl;
    decl *adecl;
    expr *aexpr;
    decl_list *next;
    int nodetype;
    int pnodetype;
    YYSTYPE parent;
};

struct ft_spec_s {
    char *aftconst;
    int nodetype;
    int pnodetype;
    YYSTYPE parent;
};

struct sc_spec_s {
    char *ascconst;
    int nodetype;
    int pnodetype;
    YYSTYPE parent;
};

/* for headtype */
#define CLA 0
#define STR 1

struct class_head_s {
    int headtype;
    char *atag;
    int ispub;
    char *atyp;
    int nodetype;
    int pnodetype;
    YYSTYPE parent;
};

struct clas_spec_s {
    class_head *aclasshead;
    defs *prdefs;
    defs *pudefs;
    int nodetype;
    int pnodetype;
    YYSTYPE parent;
};

struct unio_spec_s {
    char *atag;
    defs *adefs;
    int nodetype;
    int pnodetype;
    YYSTYPE parent;
};

struct enumerator_s {
    char *aidentifier;
    const_expr *aconstexpr;
    int nodetype;
    int pnodetype;
    YYSTYPE parent;
};

struct enum_list_s {
    enumerator *aenumerator;
    enum_list *next;
    int nodetype;
    int pnodetype;
    YYSTYPE parent;
};

struct enum_spec_s {
    char *atag;
    enum_list *aenumlist;
    int nodetype;
    int pnodetype;
    YYSTYPE parent;
};

struct simp_tname_s {
    int hasunsigned;
    char *asimptname;
    int nodetype;
    int pnodetype;
    YYSTYPE parent;
};

struct tp_spec_s {
    int hasconst;
    simp_tname *asimptname;
    clas_spec  *aclasspec;
    unio_spec  *auniospec;
    enum_spec  *aenumspec;
    int nodetype;
    int pnodetype;
    YYSTYPE parent;
};

struct data_decl_s {
    int hastypedef;
    sc_spec *ascspec;
    tp_spec *atpspec;
    decl_list *adecllist;
    int nodetype;
    int pnodetype;
    YYSTYPE parent;
};

struct mem_init_s {
    char *aidentifier;
    expr *aexpr;
    int nodetype;
    int pnodetype;
    YYSTYPE parent;
};

struct mem_init_list_s {
    mem_init *ameminit;
    mem_init_list *next;
    int nodetype;
    int pnodetype;
    YYSTYPE parent;
};

struct func_body_s {
    mem_init_list *ameminitlist;
    comp_stmt     *acompstmt;
    int nodetype;
    int pnodetype;
    YYSTYPE parent;
};

struct func_head_s {
    sc_spec *ascspec;
    ft_spec *aftspec;
    tp_spec *atpspec;
    decl    *adecl;
    arg_decl_list *aargdecllist;
    int nodetype;
    int pnodetype;
    YYSTYPE parent;
};

struct type_decl_s {
    enum_spec *aenumspec;
    unio_spec *auniospec;
    clas_spec *aclasspec;
    int nodetype;
    int pnodetype;
    YYSTYPE parent;
}; 

struct func_decl_s {
    func_head *afunchead;
    char *classname;
    int nodetype;
    int pnodetype;
    YYSTYPE parent;
};

struct func_def_s {
    func_head *afunchead;
    func_body *afuncbody;
    char *classname;
    int nodetype;
    int pnodetype;
    YYSTYPE parent;
};

struct def_s {
    func_def *afuncdef;
    data_decl *adatadecl;
    type_decl *atypedecl;
    func_decl *afuncdecl;
    int nodetype;
    int pnodetype;
    YYSTYPE parent;
};

struct defs_s {
    def *adef;
    defs *next;
    int nodetype;
    int pnodetype;
    YYSTYPE parent;
};

/*  tree node allocation routines   */

extern konst         *new_konst();
extern const_expr    *new_const_expr();
extern abstract_decl *new_abstract_decl();
extern type_name     *new_type_name();
extern id            *new_id();
extern prim_expr     *new_prim_expr();
extern term          *new_term();
extern expr          *new_expr();
extern stmt          *new_stmt();
extern stmt_list     *new_stmt_list();
extern comp_stmt     *new_comp_stmt();
extern arg_decl      *new_arg_decl();
extern args          *new_args();
extern arg_decl_list *new_arg_decl_list();
extern operfunc_name *new_operfunc_name();
extern simp_dname    *new_simp_dname();
extern dname         *new_dname();
extern decl          *new_decl();
extern init_list     *new_init_list();
extern init          *new_init();
extern init_decl     *new_init_decl();
extern decl_list     *new_decl_list();
extern ft_spec       *new_ft_spec();
extern sc_spec       *new_sc_spec();
extern class_head    *new_class_head();
extern clas_spec     *new_clas_spec();
extern unio_spec     *new_unio_spec();
extern enumerator    *new_enumerator();
extern enum_list     *new_enum_list();
extern enum_spec     *new_enum_spec();
extern simp_tname    *new_simp_tname();
extern tp_spec       *new_tp_spec();
extern data_decl     *new_data_decl();
extern mem_init      *new_mem_init();
extern mem_init_list *new_mem_init_list();
extern func_body     *new_func_body();
extern func_head     *new_func_head();
extern type_decl     *new_type_decl();
extern func_decl     *new_func_decl();
extern func_def      *new_func_def();
extern def           *new_def();
extern defs          *new_defs();

extern konst         *a_const;
extern const_expr    *a_const_expr;
extern abstract_decl *a_abstract_decl;
extern type_name     *a_type_name;
extern op             a_op;
extern id            *a_id;
extern prim_expr     *a_prim_expr;
extern term          *a_term;
extern expr          *a_expr;
extern stmt          *a_stmt;
extern stmt_list     *a_stmt_list;
extern comp_stmt     *a_comp_stmt;
extern arg_decl      *a_arg_decl;
extern args          *a_args;
extern arg_decl_list *a_arg_decl_list;
extern operfunc_name *a_operfunc_name;
extern simp_dname    *a_simp_dname;
extern dname         *a_dname;
extern decl          *a_decl;
extern init_list     *a_init_list;
extern init          *a_init;
extern init_decl     *a_init_decl;
extern decl_list     *a_decl_list;
extern ft_spec       *a_ft_spec;
extern sc_spec       *a_sc_spec;
extern class_head    *a_class_head;
extern clas_spec     *a_clas_spec;
extern unio_spec     *a_unio_spec;
extern enumerator    *a_enumerator;
extern enum_list     *a_enum_list;
extern enum_spec     *a_enum_spec;
extern simp_tname    *a_simp_tname;
extern tp_spec       *a_tp_spec;
extern data_decl     *a_data_decl;
extern mem_init      *a_mem_init;
extern mem_init_list *a_mem_init_list;
extern func_body     *a_func_body;
extern func_head     *a_func_head;
extern type_decl     *a_type_decl;
extern func_decl     *a_func_decl;
extern func_def      *a_func_def;
extern def           *a_def;
extern defs          *a_defs, *a_prog;

