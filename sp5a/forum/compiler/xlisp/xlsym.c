/* xlsym - symbol handling routines */

#include "xlisp.h"

/* external variables */
extern NODE *oblist;
extern NODE *s_unbound;
extern NODE *xlstack;

/* forward declarations */
FORWARD NODE *xlmakesym();
FORWARD NODE *findprop();

/* xlenter - enter a symbol into the oblist */
NODE *xlenter(name,type)
  char *name;
{
    NODE *oldstk,*lsym,*nsym,newsym;
    int cmp;

    /* check for nil */
    if (strcmp(name,"nil") == 0)
	return (NULL);

    /* check for symbol already in table */
    lsym = NULL;
    nsym = oblist->n_symvalue;
    while (nsym) {
	if ((cmp = strcmp(name,xlsymname(car(nsym)))) <= 0)
	    break;
	lsym = nsym;
	nsym = cdr(nsym);
    }

    /* check to see if we found it */
    if (nsym && cmp == 0)
	return (car(nsym));

    /* make a new symbol node and link it into the oblist */
    oldstk = xlsave(&newsym,NULL);
    newsym.n_ptr = newnode(LIST);
    rplaca(newsym.n_ptr,xlmakesym(name,type));
    rplacd(newsym.n_ptr,nsym);
    if (lsym)
	rplacd(lsym,newsym.n_ptr);
    else
	oblist->n_symvalue = newsym.n_ptr;
    xlstack = oldstk;

    /* return the new symbol */
    return (car(newsym.n_ptr));
}

/* xlsenter - enter a symbol with a static print name */
NODE *xlsenter(name)
  char *name;
{
    return (xlenter(name,STATIC));
}

/* xlintern - intern a symbol onto the oblist */
NODE *xlintern(sym)
  NODE *sym;
{
    NODE *oldstk,*lsym,*nsym,newsym;
    char *name;
    int cmp;

    /* get the symbol's print name */
    name = xlsymname(sym);

    /* check for nil */
    if (strcmp(name,"nil") == 0)
	return (NULL);

    /* check for symbol already in table */
    lsym = NULL;
    nsym = oblist->n_symvalue;
    while (nsym) {
	if ((cmp = strcmp(name,xlsymname(car(nsym)))) <= 0)
	    break;
	lsym = nsym;
	nsym = cdr(nsym);
    }

    /* check to see if we found it */
    if (nsym && cmp == 0)
	return (car(nsym));

    /* link the symbol into the oblist */
    oldstk = xlsave(&newsym,NULL);
    newsym.n_ptr = newnode(LIST);
    rplaca(newsym.n_ptr,sym);
    rplacd(newsym.n_ptr,nsym);
    if (lsym)
	rplacd(lsym,newsym.n_ptr);
    else
	oblist->n_symvalue = newsym.n_ptr;
    xlstack = oldstk;

    /* return the symbol */
    return (sym);
}

/* xlmakesym - make a new symbol node */
NODE *xlmakesym(name,type)
  char *name;
{
    NODE *oldstk,sym,*str;

    /* create a new stack frame */
    oldstk = xlsave(&sym,NULL);

    /* make a new symbol node */
    sym.n_ptr = newnode(SYM);
    sym.n_ptr->n_symvalue = (*name == ':' ? sym.n_ptr : s_unbound);
    sym.n_ptr->n_symplist = newnode(LIST);
    rplaca(sym.n_ptr->n_symplist,str = newnode(STR));
    str->n_str = (type == DYNAMIC ? strsave(name) : name);
    str->n_strtype = type;

    /* restore the previous stack frame */
    xlstack = oldstk;

    /* return the new symbol node */
    return (sym.n_ptr);
}

/* xlsymname - return the print name of a symbol */
char *xlsymname(sym)
  NODE *sym;
{
    return (car(sym->n_symplist)->n_str);
}

/* xlgetprop - get the value of a property */
NODE *xlgetprop(sym,prp)
  NODE *sym,*prp;
{
    NODE *p;

    return ((p = findprop(sym,prp)) ? car(p) : NULL);
}

/* xlputprop - put a property value onto the property list */
xlputprop(sym,val,prp)
  NODE *sym,*val,*prp;
{
    NODE *oldstk,p,*pair;

    if ((pair = findprop(sym,prp)) == NULL) {
	oldstk = xlsave(&p,NULL);
	p.n_ptr = newnode(LIST);
	rplaca(p.n_ptr,prp);
	rplacd(p.n_ptr,pair = newnode(LIST));
	rplaca(pair,val);
	rplacd(pair,cdr(sym->n_symplist));
	rplacd(sym->n_symplist,p.n_ptr);
	xlstack = oldstk;
    }
    rplaca(pair,val);
}

/* xlremprop - remove a property from a property list */
xlremprop(sym,prp)
  NODE *sym,*prp;
{
    NODE *last,*p;

    last = NULL;
    for (p = cdr(sym->n_symplist); consp(p) && consp(cdr(p)); p = cdr(last)) {
	if (car(p) == prp)
	    if (last)
		rplacd(last,cdr(cdr(p)));
	    else
		rplacd(sym->n_symplist,cdr(cdr(p)));
	last = cdr(p);
    }
}

/* findprop - find a property pair */
LOCAL NODE *findprop(sym,prp)
  NODE *sym,*prp;
{
    NODE *p;

    for (p = cdr(sym->n_symplist); consp(p) && consp(cdr(p)); p = cdr(cdr(p)))
	if (car(p) == prp)
	    return (cdr(p));
    return (NULL);
}

/* xlsinit - symbol initialization routine */
xlsinit()
{
    /* initialize the oblist */
    oblist = xlmakesym("*oblist*",STATIC);
    oblist->n_symvalue = newnode(LIST);
    rplaca(oblist->n_symvalue,oblist);

    /* enter the unbound symbol indicator */
    s_unbound = xlsenter("*unbound*");
    s_unbound->n_symvalue = s_unbound;
}
