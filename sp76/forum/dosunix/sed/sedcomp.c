/*
 * sedcomp.c -- stream editor main and compilation phase
 *
 * The stream editor compiles its command input  (from files or -e options) into
 * an internal form using compile() then executes the compiled form using
 * execute(). Main() just initializes data structures, interprets command
 * line options, and calls compile() and execute() in appropriate sequence.
 * The data structure produced by compile() is an array of compiled-command
 * structures (type sedcmd).  These contain several pointers into pool[], the
 * regular-expression and text-data pool, plus a command code and g & p
 * flags. In the special case that the command is a label the struct  will
 * hold a ptr into the labels array labels[] during most of the compile,
 * until resolve() resolves references at the end. The operation of execute()
 * is described in its source module.
 *
 * ==== Written for the GNU operating system by Eric S. Raymond ====
 * v1.1, 19 Jun 91
 * Toad Hall Tweak
 * - Mostly minor tweaks to make it compile with Borland's TC v2.0.
 * - No more feelthy debug.
 * - We're prototyping now.
 * See VERSION.NOT for details.
 *
 * modified Sep 91 by Howard Helman (h**2) for BC++ and Sun4 plus fixes:
 *   (those marked **** were critical)
 * 	1. l command cleanup (indexing and quoting)
 * 	2. first line problem (should have been delete FALSE) ****
 *	3. y command compile funny BC++ problem with chars and ints
 *	4. fixed `\' escapes in patterns
 *	5. fixed `\' escapes in rhs
 *      6. fixed `\' escapes in y strings 
 *      7. fixed `\' escapes in inserted text
 *      8. fixed `\' in sets  (all fixed by fixquote routine)
 *      9. RE bad looping on error message   *****
 *     10. reworked entire selected routine
 *     11. spaces after -e -f and nothing after -g -n
 *     12. errors to stderr and general error message fixups
 *     13. usage message when no args
 *     14. Make it compile under Sun Unix with minimum lint complaints
 *     15. Make it compile under BC++ 2.0   *****
 *     16. Fix recognition of last line to edit
 *     17. ; # and initial space clean ups
 *     18. No `\` escapes in file names or labels
 *     19. Last line may not have \n in commands
 *     20. 256 bit characters in all contexts
 *     21. Add + option to second address
 *     22. allow \{m,n\} RE's including after \1 as for *; + now \{1,\}
 *     23. allow \<  and \> RE's
 *     24. Genbuf now extremly long to hold everything(was 71!!) *****
 *     25. Misc cleanups for n, N, & D commands range checks cleaned up.
 *     26. Reset inrange flag on exit from {} nesting
 *     27. Blanks after : (actually all of label processing fixed up
 *     28. - in character character sets now works for ranges
 *     29. g flag in s command cleanup used ++ instead of = 1
 *     30. made separate -e and -f input routines and fixed up gettext
 *     31. RELIMIT replaced by poolend  allows REs to be of any size
 *     32. \0 character is now an error in an RE body
 *     33. address of 000 now illegal
 *     34. trailing arguments of s command handled properly
 *     35. & substitutions fixed(previously could not escape)
 *     36. handling of lastre
 *     37. % as repeat last rhs added
 *     38. nth substitution only added to s command
 *     39. \?RE? in addresses added
 *     40. No range on { command
	v1.4, Toad Hall, 20 Sep 91
 */
#ifdef OTHER 
#include "compiler.h"
#include "debug.h"
#endif
#ifdef LATTICE
#define void int
#endif

#include <stdio.h>		/* uses getc, fprintf, fopen, fclose */
#include "sed.h"		/* command type struct and name defines */

/***** public stuff ******/
#define MAXCMDS		200	/* maximum number of compiled commands */
#define MAXLINES	256	/* max # numeric addresses to compile */

/* main data areas */
char	linebuf[MAXBUF + 1];	/* current-line buffer */
sedcmd	cmds[MAXCMDS + 1];	/* hold compiled commands */
long	linenum[MAXLINES];	/* numeric-addresses table */

/* miscellaneous shared variables */
int         nflag;	 /* -n option flag */
static int  gflag;	/* -g option flag */
int         eargc;	 /* scratch copy of argument count */
sedcmd	*pending = NULL;	/* next command to be executed */
char	bits[] = {1, 2, 4, 8, 16, 32, 64, 128};

/***** module common stuff *****/
#define POOLSIZE	10000	/* size of string-pool space */
#define WFILES		10	/* max # w output files that can be compiled */
#define MAXDEPTH	20	/* maximum {}-nesting level */
#define MAXLABS		50	/* max # of labels that can be handled */

#define SKIPWS(pc) while((*pc==' ')||(*pc=='\t')||*pc=='\f'||*pc=='\v')pc++
#define ABORT(msg)	(fprintf(stderr, msg, linebuf), exit(2))
#define IFEQ(x, v)	if (*x == v) x++ ,	/* do expression */

/* error messages */
static char     BADGCNT[]="sed: bad value for match count on s command %s\n";
static char	AGMSG[] = "sed: garbled address %s\n";
static char	CGMSG[] = "sed: garbled command %s\n";
static char	TMTXT[] = "sed: too much text: %s\n";
static char	AD1NG[] = "sed: no addresses allowed for %s\n";
static char	AD2NG[] = "sed: only one address allowed for %s\n";
static char	TMCDS[] = "sed: too many commands, last was %s\n";
static char	COCFI[] = "sed: cannot open command-file %s\n";
static char	UFLAG[] = "sed: unknown flag %c\n";
static char	CCOFI[] = "sed: cannot create %s\n";
static char	ULABL[] = "sed: undefined label %s\n";
static char	TMLBR[] = "sed: too many {'s %s\n";
static char	NSCAX[] = "sed: no such command as %s\n";
static char	TMRBR[] = "sed: too many }'s %s\n";
static char	DLABL[] = "sed: duplicate label %s\n";
static char	TMLAB[] = "sed: too many labels: %s\n";
static char	TMWFI[] = "sed: too many w files %s \n";
static char	REITL[] = "sed: RE too long: %s\n";
static char	TMLNR[] = "sed: too many line numbers %s\n";
static char	TRAIL[] = "sed: command \"%s\" has trailing garbage\n";
static char  USAGE[] = "usage: sed [-n] [-g] [-e cmds] [-f cmdfile] files\n";
static char	NEEDB[] = "sed: error proccessing: %s\n"; /*hh 12*/
static char     NOARG[] = "sed: no argument for -e\n";    /*hh 12*/
static char     ILFQT[] = "sed: bad expression %4.4s\n";  /*hh 12*/
static char     BADRANGE[]= "sed: range error in set %s\n";

typedef struct {		/* represent a command label */
	char	*name;		/* the label name */
	sedcmd	*list;		/* it's on the label search list */
	sedcmd	*address;	/* pointer to the cmd it labels */
  }  label;

/* label handling */
static label	labels[MAXLABS];	/* here's the label table */
static label   *curlab = labels + 1;	/* pointer to current label */

/* string pool for regular expressions, append text, etc. etc. */
static char	pool[POOLSIZE];		/* the pool */
static char    *fp = pool;			/* current pool pointer */
static char    *poolend = pool + POOLSIZE;	/* pointer past pool end */

/* compilation state */
static FILE    *cmdf = NULL;	/* current command source */
static char    *cp = linebuf;	/* compile pointer */
static sedcmd  *cmdp = cmds;	/* current compiled-cmd ptr */
static char    *lastre = NULL;	/* old RE pointer */
static char    *lastrhs= NULL;  /* old RHS pointer*/
static int	bdepth = 0;	/* current {}-nesting level */
static int	bcount = 0;	/* # tagged patterns in current RE */
static char   **eargv;		/* scratch copy of argument list */

/* imported functions */
#ifdef __TURBOC__			/* v1.1 */
#include <string.h>
#include <stdlib.h>			/* exit() */
#include <ctype.h>
#define Void void        /*K&R and Std C compatibility*/
static void   compile(int eflag),einit(void);
static void   resolve(void);
extern void   execute(char *file);/* execute compiled command  (in SEDEXEC.C) */
static char   fixquote(char**);
static int    ecmdline(void), fcmdline(void);
static int    address(char **expbuf,int pass);
static int    cmdcomp(register char cchar);
static char  *gettext(register char *txp,int doq);
static label *search(void);
static int    recomp(char **expbuf, char redelim);
static int    rhscomp(char **rhsp, char delim);
static int    ycomp(void);
static char   tox(char);
static int    processm(void);
#else	/* !__TURBOC__*/
#define Void
extern int    strcmp();
static int    recomp(), address(), rhscomp(),ycomp(),processm();
extern void   execute();	/* execute compiled command */
static char  *gettext();
static label *search();
static char   fixquote();
static void   compile(), resolve(), einit();
#endif	/* ?__TURBOC__ */

#ifdef HHDEB
void mybcheck(Void){char *p; for(p=pool;p<fp;p++)
   if((*p&0xff)<' ')printf("%2i,",*p&0xff);
   else printf("%c,",*p&0xff);
 getchar();}
#else
void mybcheck(Void){}
#endif

int main(argc,argv) int argc; char *argv[];{ /*hh 15*/
	eargc = argc;		/* set local copy of argument count */
	eargv = argv;		/* set local copy of argument list */
	if (eargc <= 1){fprintf(stderr,USAGE);exit(1);} /*hh 13*/
	PASS("main(): setup"); /*scan through the arguments,interpreting each*/
	while ((--eargc > 0) && (**++eargv == '-'))
		switch (eargv[0][1]) {
		 case 'e':
			if(eargv[0][2]){eargc++;*eargv+=2;eargv--;}/*hh 11*/
			einit();compile(1);	/* compile with e flag on */
			break;		/* get another argument */
		 case 'f':
			if(eargv[0][2]){ /*hh 11*/
			  if((cmdf=fopen(*eargv+2,"rt"))==NULL){ /*hh 12*/
				 fprintf(stderr,COCFI,*eargv+2);exit(2);}}
			else if (eargc-- <= 0){	/*hh 12*/
			  fprintf(stderr,NEEDB,eargv[0]);exit(2);}
			else if ((cmdf = fopen(*++eargv, "rt")) == NULL) {
			  fprintf(stderr, COCFI, *eargv);exit(2);}
			compile(0);		/* file is O.K., compile it */
			fclose(cmdf);
			break;	/* go back for another argument */
		  case 'g':  gflag++;	/* set global flag on all s cmds */
			if(eargv[0][2])
			  {fprintf(stderr,NEEDB,eargv[0]);exit(2);}/*hh 11*/
			break;
		  case 'n':  nflag++;	/* no print except on p flag or w */
			if(eargv[0][2])
			  {fprintf(stderr,NEEDB,eargv[0]);exit(2);}/*hh 11*/
			break;
		  default:
			fprintf(stderr, UFLAG, eargv[0][1]);exit(1);/*hh 11*/}
	PASS("main(): argscan");
	if (cmdp == cmds) {		/* no commands have been compiled */
		eargv--; eargc++; einit(); compile(1); eargv++; eargc--;}
	if (bdepth) ABORT(TMLBR);	/* we have unbalanced squigglies */
	resolve(); mybcheck();      /* resolve label table indirections */
	if (eargc <= 0)	execute((char*)NULL);/*execute on file from stdin only*/
	else  while (--eargc >= 0)	/* else execute only listed files */
		      execute(*eargv++);
	PASS("main(): end & exit OK");
	return (0);  }		/* everything was O.K. if we got here */

#define H	0x80	/* 128 bit, on if there's really code for  command */
#define LOWCMD  56	/* = '8', lowest char indexed in cmdmask */
/* indirect through this to get command internal code, if it exists */
static char		cmdmask[] =
{0,        0,     H,      0,      0,H+EQCMD,    0,      0, /* 89:;<=>? */
 0,        0,     0,      0,  CDCMD,      0,    0,  CGCMD, /* @ABCDEFG */
 CHCMD,    0,     0,      0,      0,      0,CNCMD,      0, /* HIJKLMNO */
 CPCMD,    0,     0,      0,H+CTCMD,      0,    0,H+CWCMD, /* PQRSTUVW */
 0,        0,     0,      0,      0,      0,    0,      0, /* XYZ[\]^_ */
 0,   H+ACMD,H+BCMD, H+CCMD,   DCMD,      0,    0,   GCMD, /* `abcdefg */
 HCMD,H+ICMD,     0,     0,  H+LCMD,      0, NCMD,      0, /* hijklmno */
 PCMD,H+QCMD,H+RCMD, H+SCMD, H+TCMD,      0,    0, H+WCMD, /* pqrstuvw */
 XCMD,H+YCMD,     0,H+BRCMD,     0,       H,    0,      0,};/*xyz{|}~  */

static void compile(eflag)int eflag; /*hh 14*//* precompile sed commands*/
       {char ccode; static int comment1=0;
	PASS("compile(): entry");
	while(*cp=='#'||*cp++==';'||(eflag?ecmdline():fcmdline())){
	    SKIPWS(cp);
            if (*cp == '#'){*cp=0;if(!comment1++&&cp[1]=='n')nflag++;}
	    if (*cp == '\0' || *cp==';') continue;
	    /* compile first address */
	    if (fp > poolend) ABORT(TMTXT);
	    if (address(&cmdp->addr1,1)){  SKIPWS(cp);
	       if (*cp == ',' || *cp == ';') {	/* there's 2nd addr */
		   cp++; if (fp > poolend) ABORT(TMTXT);
		   if(!address(&cmdp->addr2,2))	ABORT(AGMSG);}}
	    if (fp > poolend)  ABORT(TMTXT);
	    SKIPWS(cp);		/* discard whitespace after address */
	    IFEQ(cp, '!') cmdp->flags.allbut = 1;
	    SKIPWS(cp);		/* get cmd char, range-check it */
	    if ((*cp < LOWCMD) || (*cp > '~')
		  || ((ccode = cmdmask[*cp - LOWCMD]) == 0))ABORT(NSCAX);
	    cmdp->command = ccode & ~H;	/* fill in command value */
	    if ((ccode & H) == 0)		/* if no compile-time code */
			cmdp++,cp++;		/* end cmd &discard char */
	    else cmdp+=cmdcomp(*cp++);/*execute stuff and bump if gotone*/
	    if (cmdp >= cmds + MAXCMDS)  ABORT(TMCDS);
	    SKIPWS(cp);			/* look for trailing stuff */
	    if (*cp != '\0'&&*cp!=';'&&*cp!='#') ABORT(TRAIL); /*hh 17*/}}

static int cmdcomp(cchar) /* compile a single command */
	register char   cchar;	/* character name of command */
{   
	static sedcmd **cmpstk[MAXDEPTH];	/* current cmd stack for {} */
	static char    *fname[WFILES];		/* w file name pointers */
	static FILE    *fout[WFILES] ;          /* w file file ptrs */
	static int	nwfiles = 0;	         /* count of open w files */
	int	        i;			/* indexing dummy used in w */
	label	       *lpt;
	char		redelim;		/* current RE delimiter */

	switch (cchar) {
	  case '{':			/* start command group */
		cmdp->flags.allbut = !cmdp->flags.allbut;
		cmpstk[bdepth++] = &(cmdp->u.link);
		if (++cmdp >= cmds + MAXCMDS) ABORT(TMCDS);
		if (*cp != '\0')
			*--cp = ';'; /* get next cmd w/o lineread *//*hh 17*/
		return (0);
	  case '}':			       /* end command group */
		if (cmdp->addr1||cmdp->flags.allbut)  
                         ABORT(AD1NG);/* no addresses allowed */
		if (--bdepth < 0) ABORT(TMRBR);/* too many right braces */
		*cmpstk[bdepth] = cmdp;		/* set the jump address */
		return (0);
	  case '=':			/* print current source line number */
	  case 'q':			/* exit the stream editor */
		if (cmdp->addr2) ABORT(AD2NG);
		break;
	  case ':':			/* label declaration */
                if(cmdp->addr1) ABORT(AD1NG);
                if((lpt=search())->address) ABORT(DLABL);
                lpt->address=cmdp;   /*mark it here*/
		return (0);
	  case 'b':			/* branch command */
	  case 't':			/* branch-on-succeed command */
	  case 'T':			/* branch-on-fail command */
		cmdp->u.link=(lpt=search())->list;
                lpt->list=cmdp;
                break;
	  case 'a':			/* append text */
	  case 'i':			/* insert text */
	  case 'r':			/* read file into stream */
		if (cmdp->addr2) ABORT(AD2NG);
	  case 'c':			/* change text */
		if ((*cp == '\\') && (cp[1] == '\n')) cp+=2;
		fp = gettext(cmdp->u.lhs = fp,cchar!='r'); /*hh 7*/
		break;
	  case 's':		/* substitute regular expression */
		redelim = *cp++;	/* get delimiter from 1st ch */
		if(!recomp(&cmdp->u.lhs,redelim))ABORT(CGMSG);
		if ((cmdp->rhs = fp) > poolend)	ABORT(TMTXT);
		if (!rhscomp(&cmdp->rhs, redelim)) ABORT(CGMSG);
		if (gflag) cmdp->flags.global = 1;
                while(*cp){
                    SKIPWS(cp);
		    if(isdigit(*cp)){
                      i=0;while(isdigit(*cp)) i=i*10+*cp++-'0';
                      if (!i||i>512)ABORT(BADGCNT);
                      cmdp->flags.nthone=i;}
                     else if(*cp=='g') cmdp->flags.global =1;
		     else if(*cp=='p') cmdp->flags.print = 1;
		     else if(*cp== 'P') cmdp->flags.print = 2;
                     else break;
                     cp++;}
 	  case 'l':			/* list pattern space */
		if (*cp == 'w') cp++;/* and execute a w command! */
		else	break;		/* s or l is done */
	  case 'w':			/* write-pattern-space command */
	  case 'W':			/* write-first-line command */
		if (nwfiles >= WFILES)	ABORT(TMWFI);
		fp = gettext(fname[nwfiles] = fp,0);/*get filename */ /*hh 18*/
                if(!*fname[nwfiles]){cmdp->fout=stdout;return 0;}/*dft stdout*/
		for (i = nwfiles - 1; i >= 0; i--)	/* match it in table */
		     if (strcmp(fname[nwfiles],fname[i])==0) {/*could opt fp*/
				cmdp->fout = fout[i]; return (1);}
		  /* if didn't find one, open new out file */
		if((cmdp->fout=fopen(fname[nwfiles],"wt"))==NULL){ /*hh 15*/
			fprintf(stderr, CCOFI, fname[nwfiles]);	exit(2);}
		fout[nwfiles++] = cmdp->fout;
		break;
 	  case 'y':			/* transliterate text */
                cmdp->u.lhs=fp;
                if(!ycomp()) ABORT(CGMSG);
		if (fp > poolend)ABORT(TMTXT);	/* fail on overflow */
		break;}	/* switch */
	return 1;}		/* succeeded in interpreting one command */

static char tox(c) char c;{ /*hh 4-8*/
  if(isdigit(c))return c&017;
  else return (c&07)+9;}

static char fixquote(p)
char **p;
/*function added by h**2*/
{
	char c = *(*p-1);
	char	x1,x2;

  if(c=='a')c='\a';  /* for all quoted replacements*/
     else if(c=='b')c='\b';
     else if(c=='e')c= 27;
     else if(c=='f')c='\f';
     else if(c=='n')c='\n';
     else if(c=='r')c='\r';
     else if(c=='t')c='\t';
     else if(c=='v')c='\v';
     else if(c=='x'){
		   if(!(x1= *(*p))||!(x2=*(*p+1))
		      ||!isxdigit(x1)||!isxdigit(x2))
                          {fprintf(stderr,ILFQT,(*p)-2);exit(2);}
                   c=(tox(x1)<<4)|tox(x2);(*p)+=2;}
  return c;}  /*hh 4-8*/

static int 	rhscomp(rhsp, delim)	/* uses bcount *//*hh 5*/
/* generate replacement string for substitute command right hand side */
	char  **rhsp;	/* place to compile expression to */
	char   delim;	/* regular-expression end-mark to look for */
     { if(lastrhs&&*cp=='%'&&cp[1]==delim){
          *rhsp=lastrhs;cp+=2;return 1;}/* repeat last substitution*/ 
       lastrhs=*rhsp=fp;
       while((*fp=*cp++)!=delim)
	if (*fp  == '\\') {	/* copy; if it's a \, */
		*fp = *cp++;  /* copy escaped char */
		/* check validity of pattern tag */
		if(*fp>'0'&&*fp<='9'){/*hh 5*/
		       if(*fp>bcount+'0')return 0;
		       else *fp++=ARGMARK,*fp++=cp[-1];}
		else if(!*fp)	return 0;
		else *fp++=fixquote(&cp);
		continue;}
	else if(*fp =='&') *fp++=ARGMARK,*fp++='0'; /*note replacement*/
	else if (*fp++ == '\0')	/* last ch not RE end, help! */
		return 0;
     *fp++ = '\0';		    /* cap the expression string */
     return 1;}

static int     recomp(expbuf, redelim)		/* uses cp, bcount */
/* compile a regular expression to internal form */
	char	**expbuf;		/* place to compile it to */
	char	redelim;		/* RE end-marker to look for */
{
	char  *lastep= 0; /* for repeat handling */ /*hh 4*/
	register int	c;	/* current-character pointer */
	char	negclass;	/* all-but flag */
	char	brnest[MAXTAGS];	/* bracket-nesting array */
	char   *brnestp;	/* ptr to current bracket-nest */
	int	classct;	/* class element count */
	int	tags;		/* # of closed tags */
	int lastc,nextc;        /*temps for ranges*/
	if (*cp == redelim){	/* if first char is RE endmarker */
		cp++;if(!lastre) return 0;
		*expbuf=lastre; return 1;}
	*expbuf=lastre =fp; /*if this is good its the last one we found*/
	brnestp = brnest;		/* initialize ptr to brnest array */
	tags = bcount = 0;		/* initialize counters */
	if ( (*fp++ = (*cp == '^')) != 0)cp++; /* check for start-of-line  */
	while(fp<poolend&&(c=*cp++)!=redelim  ){
	  switch (c) {
	       case '\\':
		if ((c = *cp++) == '(') {	/* start tagged section */
		  if (bcount >= MAXTAGS) return 0;
                  lastep=0;
		  *brnestp++ = bcount;		/* update tag stack */
		  *fp++ = CBRA;			/* enter tag-start */
		  *fp++ = bcount++ + 1;		/* bump tag count */
		  break;}
		else if (c == ')') {		/* end tagged section */
		  if (brnestp <= brnest) return 0;/* extra \) */
                  lastep=0;
		  *fp++ = CKET;			/* enter end-of-tag */
		  *fp++ = *--brnestp + 1;	/* pop tag stack */
		  tags++;			/* count closed tags */
		  break;}
	        else if(c=='{'){if(!lastep) return 0; /* rep error*/
		  *lastep|=MTYPE; lastep=0;
		  if(!processm())return 0;
		  break;}
		else if(c=='<'){   /*begining of word test*/
		  lastep=0; *fp++=CBOW;
		  break;}
		else if(c=='>'){/*end of word test*/
		  lastep=0; *fp++=CEOW;
		  break;}
		else if (c >= '1' && c <= '9') {	/* tag use */
		  if ((c -= '1') >= tags) return 0 ;	/* too few */
		  lastep=fp; *fp++ = CBACK;		/* enter tag mark */
		  *fp++ = c+1; 		/* and the number */
		  break;}
		else if (c == '\n')return 0;	/* escaped newline bad*/
		else { c=fixquote(&cp);
		       goto defchar;} /*hh 4*/
	       case '\0':		/* do not allow */
	       case '\n': return 0;    /* no trailing pattern delimiter */
	       case '.':	   /* match any char except newline */
		lastep=fp; *fp++ = CDOT;
		break;
	       case '+':	/* 1 to n repeats of previous pattern */
		if(!lastep)   goto defchar;
		*lastep|=MTYPE; lastep=0; *fp++=1;*fp++=0xFF;
		break;
	       case '*':	/* 0..n repeats of previous pattern */
		if(!lastep) goto defchar;
		*lastep|=STAR; lastep=0;
		break;
	       case '$':	/* match only end-of-line */
		if (*cp != redelim)		/* if we're not at end of RE */
			goto defchar;		/* match a literal $ */
		*fp++ = CDOL;			/* insert end-symbol mark */
		break;
	       case '[':	/* begin character set pattern */
		lastep=fp;
		if (fp + 33 >= poolend) ABORT(REITL);
		*fp++ = CCL; 	/* insert class mark */
		if ( (negclass = ((c = *cp++) == '^')) != 0)     /* v1.1 */
			c = *cp++;
		lastc=0;
		do {if (c == '\0') ABORT(CGMSG);
		   /* handle character ranges */
		    if (c == '-' && lastc && *cp != ']'){
		      nextc=*cp++&0xff;
		      if(nextc=='\\')cp++,nextc=fixquote(&cp)&0xff;
		      if(lastc>nextc)ABORT(BADRANGE);
		      for(;lastc<=nextc;lastc++)fp[lastc>>3]|=bits[lastc&7];
		      lastc=0;continue;}
		    if (c == '\\')cp++,c=fixquote(&cp); /*hh 8*/
		    fp[(c>>3)&0x1F] |= bits[c & 7];lastc=c&0xff;
		    } while((c = *cp++) != ']');
		/* invert the bitmask if all-but was specified */
		if (negclass)
		   for (classct = 0; classct<32;classct++)fp[classct] ^= 0xFF;
		fp[0] &= 0xFE;		/* never match ASCII 0 */
		fp += 32;		/* advance ep past set mask */
		break;
	     defchar:			/* match literal character */
	       default:			/* which is what we'd do by default */
		lastep=fp;
		*fp++ = CCHR;		/* insert character mark */
		*fp++ = c;
		break;}}
	*fp++=CEOF;return fp<poolend&& brnestp==brnest;}

static int processm(Void) {int i1=0,i2=0;
  while(isdigit(*cp))i1=i1*10+*cp++-'0';
  if(!i1||i1>255)return 0;
  *fp++ = (char)i1;
  if(*cp=='\\'&&cp[1]=='}')cp+=2,*fp++=0;
  else if(*cp==','&&cp[1]=='\\'&&cp[2]=='}')cp+=3,*fp++ = 0xFF;
  else if(*cp++==','){
	while (isdigit(*cp))i2=i2*10+*cp++-'0';
	if(*cp!='\\'||cp[1]!='}'||i2<i1||i2-i1>254)return 0;
	cp+=2;*fp++=(char)(i2-i1);}
  else return 0;
  return 1;}

static char *p=NULL;

static void einit(Void){
	if (eargc-- <= 0){fprintf(stderr,NOARG);exit(2);} /*hh 12*/
	p = *++eargv;}

static int ecmdline(Void)
{
	char *cbuf=linebuf-1;

	cp=linebuf;
   if(p==NULL)return 0;
   while ( (*++cbuf = *p++) != 0)	/* v1.4 */
	if (*cbuf == '\\') {
		if ((*++cbuf=*p++) == '\0'){*++cbuf=0;p=NULL;return 1;}
		else  continue;}
	else if (*cbuf == '\n') {/*end of cmd line*/
		*cbuf = '\0';
		return ( 1);}
   p=NULL;
   return 1;}

static int fcmdline(Void){ /*uses cmdf; read next command from file */
	int inc, any=0; /*hh 19*/
	char *cbuf=linebuf-1;		/* so pre-increment points us at cbuf */
	cp=linebuf;
	while ((inc = getc(cmdf)) != EOF)	/* get next char */
	  if (++any&&((*++cbuf = inc) == '\\'))	/* if it's escape *//*hh 19*/
			*++cbuf = inc = getc(cmdf);	/* get next char */
		else if (*cbuf == '\n')		/* end on newline */
			return (*cbuf = '\0', 1);	/* cap the string */
	  return (*++cbuf = '\0', any); /*real end-of-file?*//*hh 19*/}

static int address(expbuf,pass)		/* uses cp, linenum */
/* expand an address at *cp... into expbuf, return address ok */
	char **expbuf;int pass;
{ static int numl = 0,numpl=0;/* current inds in addr-number tables */
	int code;
	char  *rcp;		/* temp compile ptr for forwd look */
	long   lno;		/* computed value of numeric address */
	*expbuf=fp;  	/* nominally this is the address start*/
	if (*cp == '$') {		/* end-of-source address */
		*fp++ = CEND;	/* write symbolic end address */
		*fp++ = CEOF;	/* and the end-of-address mark (!) */
		cp++;			/* go to next source character */
		return 1;}		/* we're done */
	if (*cp == '/'||*cp=='\\'){	/* start of regular-expression match */
		if(*cp=='\\')cp++;
		if(!recomp(expbuf, *cp++)) ABORT(AGMSG);/* compile the RE */
		else return 1;}
	code=CLNUM;
	if(pass==2&&*cp=='+'){cp++,code=CPLUS;} /*compile + in 2nd address*/
	rcp = cp;
	lno = 0;			/* now handle a numeric address */
	while (*rcp >= '0' && *rcp <= '9')	/* collect digits */
		lno = lno * 10 + *rcp++ - '0';	/* compute their value */
	if (lno) {				/* if we caught a number... */
		*fp++ = code;	     /* put a numeric-address marker */
		*fp++ = numl;	      /* and the address table index */
		linenum[numl++] = lno;		/* and set the table entry */
		if (numl >= MAXLINES)	/* oh-oh, address table overflow */
			ABORT(TMLNR);		/* abort with error message */
		if(code==CPLUS){
		    *fp++=numpl++;
		    if(numpl>=MAXPLUS)ABORT(TMLNR);}
		*fp++ = CEOF;	/* write the end-of-address marker */
		cp = rcp;		/* point compile past the address */
		return 1;		/* we're done */}
	*expbuf=NULL;
	return 0;}			/* no legal address was found */

static char    *gettext(txp,quoting)	/* uses global cp *//*hh 4-5,12,15*/
/* accept multiline input from *cp..., discarding leading whitespace */
	register char  *txp; int quoting; /* where to put the text */
{       SKIPWS(cp);txp--;
	  while(*++txp=*cp++){
		  if(!quoting&&(*txp=='#'||*txp==';')){*txp=0;break;}
          if(*txp=='\\'&&quoting)cp++,*txp=fixquote(&cp);
          if(*txp=='\n')SKIPWS(cp);}
         return (cp--,++txp);}

static label   *search(Void){label *l; char *lname;	/* uses global curlab */
	SKIPWS(cp);
	fp=gettext(lname=curlab->name=fp,0);
        if(!*lname) return labels;
        for(l=labels+1;strcmp(l->name,lname);l++) ;
	if(l==curlab){if(++curlab>=labels+MAXLABS)ABORT(TMLAB);}
        else fp=lname;
        return l;}

static void resolve(Void)
/*hh 14,15*/
{
	label *l=labels;
	sedcmd *f,*t;

	l->address=cmdp;
	while(l<curlab){
		if(!l->address){fprintf(stderr,ULABL,l->name);exit(2);}
		if(!(f=l->list))
		{
			if(l!=labels)
			    fprintf(stderr,"sed: Label not used %s\n",l->name);
		}
		else  do{
			t=f->u.link;f->u.link=l->address;
		}
		while( (f=t) != NULL);	/* v1.4 */
		l++;
	}
}

static int    ycomp(Void)
/* compile a y (transliterate) command */
{	char   *tp, *sp,delim=*cp++; int c; /*hh 6*/
	/* scan the 'from' section for invalid chars */
	for (sp = tp = cp; *tp != delim; tp++) {
		if (*tp == '\\')  tp++;
		if ((*tp == '\n') || (*tp == '\0'))return 0;}
	tp++;	/* tp now points at first char of 'to' section */
	/* now rescan the 'from' section */
	while ((c = *sp++&0xff) != delim) {
	  if (c == '\\') sp++,c=fixquote(&sp)&0xff;
	  if ((fp[c]=*tp++)=='\\')tp++,fp[c]=fixquote(&tp); /*hh 6*/
	  else if ((fp[c] == delim) || (fp[c] == '\0'))return 0;	}
	if (*tp != delim)	/* 'to', 'from' parts have unequal lengths */
		return 0;
	cp = ++tp;			/* point compile ptr past translit */
	for (c = 0; c < 256; c++)  /* fill in self-map entries in table */
		if (fp[c] == 0) fp[c] = c;
        fp+=0x100;
	return 1;}  

/* sedcomp.c ends here */
