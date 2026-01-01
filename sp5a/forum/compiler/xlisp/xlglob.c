/* xlglobals - xlisp global variables */

#include "xlisp.h"

/* symbols */
NODE *true = NULL;
NODE *s_quote = NULL, *s_function = NULL;
NODE *s_bquote = NULL, *s_comma = NULL, *s_comat = NULL;
NODE *s_evalhook = NULL, *s_applyhook = NULL;
NODE *s_lambda = NULL, *s_macro = NULL;
NODE *s_stdin = NULL, *s_stdout = NULL;
NODE *s_tracenable = NULL, *s_tracelimit = NULL, *s_breakenable = NULL;
NODE *s_continue = NULL, *s_quit = NULL;
NODE *s_car = NULL, *s_cdr = NULL;
NODE *s_get = NULL, *s_svalue = NULL, *s_splist = NULL;
NODE *s_eql = NULL, *k_test = NULL, *k_tnot = NULL;
NODE *k_optional = NULL, *k_rest = NULL, *k_aux = NULL;
NODE *a_subr = NULL, *a_fsubr = NULL;
NODE *a_list = NULL, *a_sym = NULL, *a_int = NULL;
NODE *a_str = NULL, *a_obj = NULL, *a_fptr = NULL;
NODE *oblist = NULL, *s_unbound = NULL;

/* evaluation variables */
NODE *xlstack = NULL;
NODE *xlenv = NULL;
NODE *xlnewenv = NULL;

/* exception handling variables */
CONTEXT *xlcontext = NULL;	/* current exception handler */
NODE *xlvalue = NULL;		/* exception value */

/* debugging variables */
int xldebug = 0;		/* debug level */
int xltrace = -1;		/* trace stack pointer */
NODE **trace_stack = NULL;	/* trace stack */

/* gensym variables */
char gsprefix[STRMAX+1] = { 'G',0 };	/* gensym prefix string */
int gsnumber = 1;		/* gensym number */

/* i/o variables */
int xlplevel = 0;		/* prompt nesting level */
int xlfsize = 0;		/* flat size of current print call */
int prompt = TRUE;		/* input prompt flag */

/* dynamic memory variables */
long total = 0L;		/* total memory in use */
int anodes = 0;			/* number of nodes to allocate */
int nnodes = 0;			/* number of nodes allocated */
int nsegs = 0;			/* number of segments allocated */
int nfree = 0;			/* number of nodes free */
int gccalls = 0;		/* number of gc calls */
struct segment *segs = NULL;	/* list of allocated segments */
NODE *fnodes = NULL;		/* list of free nodes */

/* object programming variables */
NODE *self = NULL, *class = NULL, *object = NULL;
NODE *new = NULL, *isnew = NULL, *msgcls = NULL, *msgclass = NULL;
int varcnt = 0;

/* general purpose string buffer */
char buf[STRMAX+1] = 0;
