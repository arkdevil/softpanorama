/* xlprint - xlisp print routine */

#include "xlisp.h"

/* external variables */
extern NODE *xlstack;
extern char buf[];

/* xlprint - print an xlisp value */
xlprint(fptr,vptr,flag)
  NODE *fptr,*vptr; int flag;
{
    NODE *nptr,*next;

    /* print null as the empty list */
    if (vptr == NULL) {
	putstr(fptr,"nil");
	return;
    }

    /* check value type */
    switch (ntype(vptr)) {
    case SUBR:
	    putatm(fptr,"Subr",(int) vptr);
	    break;
    case FSUBR:
	    putatm(fptr,"FSubr",(int) vptr);
	    break;
    case LIST:
	    xlputc(fptr,'(');
	    for (nptr = vptr; nptr != NULL; nptr = next) {
	        xlprint(fptr,car(nptr),flag);
		if ((next = cdr(nptr)) != NULL)
		    if (consp(next))
			xlputc(fptr,' ');
		    else {
			putstr(fptr," . ");
			xlprint(fptr,next,flag);
			break;
		    }
	    }
	    xlputc(fptr,')');
	    break;
    case SYM:
	    putstr(fptr,xlsymname(vptr));
	    break;
    case INT:
	    putdec(fptr,vptr->n_int);
	    break;
    case STR:
	    if (flag)
		putstring(fptr,vptr->n_str);
	    else
		putstr(fptr,vptr->n_str);
	    break;
    case FPTR:
	    putatm(fptr,"File",(int) vptr);
	    break;
    case OBJ:
	    putatm(fptr,"Object",(int) vptr);
	    break;
    case FREE:
	    putatm(fptr,"Free",(int) vptr);
	    break;
    default:
	    putatm(fptr,"Foo",(int) vptr);
	    break;
    }
}

/* xlterpri - terminate the current print line */
xlterpri(fptr)
  NODE *fptr;
{
    xlputc(fptr,'\n');
}

/* putstring - output a string */
LOCAL putstring(fptr,str)
  NODE *fptr; char *str;
{
    int ch;

    /* output the initial quote */
    xlputc(fptr,'"');

    /* output each character in the string */
    while (ch = *str++)

	/* check for a control character */
	if (ch < 040 || ch == '\\') {
	    xlputc(fptr,'\\');
	    switch (ch) {
	    case '\033':
		    xlputc(fptr,'e');
		    break;
	    case '\n':
		    xlputc(fptr,'n');
		    break;
	    case '\r':
		    xlputc(fptr,'r');
		    break;
	    case '\t':
		    xlputc(fptr,'t');
		    break;
	    case '\\':
		    xlputc(fptr,'\\');
		    break;
	    default:
		    putoct(fptr,ch);
		    break;
	    }
	}

	/* output a normal character */
	else
	    xlputc(fptr,ch);

    /* output the terminating quote */
    xlputc(fptr,'"');
}

/* putatm - output an atom */
LOCAL putatm(fptr,tag,val)
  NODE *fptr; char *tag; int val;
{
    sprintf(buf,"#<%s: #%x>",tag,val);
    putstr(fptr,buf);
}

/* putdec - output a decimal number */
LOCAL putdec(fptr,n)
  NODE *fptr; int n;
{
    sprintf(buf,"%d",n);
    putstr(fptr,buf);
}

/* putoct - output an octal byte value */
LOCAL putoct(fptr,n)
  NODE *fptr; int n;
{
    sprintf(buf,"%03o",n);
    putstr(fptr,buf);
}

/* putstr - output a string */
LOCAL putstr(fptr,str)
  NODE *fptr; char *str;
{
    while (*str)
	xlputc(fptr,*str++);
}
