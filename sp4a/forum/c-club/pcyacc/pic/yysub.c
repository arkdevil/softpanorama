
#include <stdio.h>
#include "defs.h"
#include "pic.h"

Object *objlst[LISTSZ], anObject;
Symbol *symlst[LISTSZ];
int     ocount=0;

Object *
new_object(o)
Object *o;
{ Object *p;

  p = (Object *) malloc(sizeof(Object));
  if (p==NULL) exception(FATAL, "out of heap space");
  cpy_object(p, o);
  clr_object(o);
  return(p);
}

cpy_object(t, f)
Object *t, *f;
{ register int i;

  t->shape = f->shape;
  t->color = f->color;
  t->style = f->style;
  t->fill  = f->fill;
  t->npoints = f->npoints;
  for (i=0; i<f->npoints; i++) {
    t->x_coord[i] = f->x_coord[i];
    t->y_coord[i] = f->y_coord[i];
  }
}

clr_object(o)
Object *o;
{ register int i;

  o->shape = LINE;
  o->color = WHITE;
  o->style = SOLID;
  o->fill  = BLACK;
  o->npoints = 0;
}

hash(s)
char *s;
{ int hashval;

  for (hashval=0; *s != '\0';) hashval += *s++;
  return(hashval % LISTSZ);
}

Object *
lookup(s)
char *s;
{ Symbol *sp;

  for (sp=symlst[hash(s)]; sp!=NULL; sp=sp->next) {
    if ( !strcmp(s, sp->namep) ) {
      return(sp->value);
    }
  }
  return(NULL);
}

install(s, o)
char *s;
Object *o;
{ Symbol *sp;
  Object *op;
  int hashval;

  if ((op=lookup(s)) == NULL) { /* a new symbol definition */
    if ((sp=(Symbol *) malloc(sizeof(Symbol))) == NULL)
      exception(FATAL, "out of heap space");
    hashval = hash(s);
    sp->next = symlst[hashval];
    symlst[hashval] = sp;
  } else { /* symbol exists, override old definition */
    free(op);
  }
  sp->namep = s;
  sp->value = o;
}

exception(f, m)
int f;
char *m;
{

  fprintf(stderr, "Exception: %s\n", m);
  if (f==FATAL) exit(1);
}

append_objlst(o)
Object *o;
{
  objlst[ocount++] = o;
}

