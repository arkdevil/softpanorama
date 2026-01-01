/*
 * sedexec.c -- execute compiled form of stream editor commands
 *
 * The single entry point of this module is the function execute(). It may take
 * a string argument (the name of a file to be used as text)  or the argument
 * NULL which tells it to filter standard input. It executes the compiled
 * commands in cmds[] on each line in turn. The function command() does most
 * of the work. Match() and advance() are used for matching text against
 * precompiled regular expressions and dosub() does right-hand-side
 * substitution.  Getline() does text input; readout() and smemcmp() are
 * output and string-comparison utilities.
 *
 * ==== Written for the GNU operating system by Eric S. Raymond ====
 * v1.2, 14 Jul 91
 * From: mdlawler@bsu-cs.bsu.edu (Michael D. Lawler)
 * Change the line in sedexec.c from
 *    static int delete;
 * to
 *   static int delete = TRUE;
 * and let me know if it still compiles ok under TurboC 2.0.
 * I made this change which was suggested by Mark Adler
 * and it made sed work fine under BC++ 2.0.
 *
 * Toad Hall:  Compiles just fine in TC 2.0.
 *
 * v1.1, 19 Jun 91
 * Toad Hall Tweak for TC v2.0
 * See VERSION.NOT for details
 * modified September 91 by hh see notes in sedcomp.c
 */

#ifdef OTHER /*hh 14*/
#include "compiler.h"
#include "debug.h"
#endif
#ifdef LATTICE
#define void int
#endif

#include <stdio.h>	/* {f}puts, {f}printf, getc/putc, f{re}open, fclose */
#include <ctype.h>	/* for isprint(), isdigit(), toascii() macros */
#include "sed.h"	/* command type structures & miscellaneous* constants */

#ifdef __TURBOC__		/* v1.1 */
#include <string.h>
#include <stdlib.h>		/* exit() */
static char    *getline(register char *buf);
static int	selected(sedcmd *ipc);
static void	command(sedcmd *ipc);
static void     readout(void);
static int	match(char *expbuf, int gf);
static int	advance(register char *lp, register char *ep);
static void	dosub(char *rhsbuf);
static char    *place(char *asp,char *al1,char *al2);
static void	listto(register char *p1, FILE *fp);
static int	substitute(sedcmd *ipc);
/* v1.1 renamed this so it wouldn't conflict with TC's memcmp() */
static int	smemcmp(register char *a, register char *b, int count);
#else	/* !PROTO */
extern char	*strcpy();	/* used in dosub */
	char	*getline();	/* input-getting functions */
	void	command(), readout();
	void	dosub();	/* for if we find a match */
	char			*place();
#endif	/* ?PROTO */

/***** shared variables imported from the main ******/

/* main data areas */
extern char	linebuf[];	/* current-line buffer */
extern sedcmd	cmds[];		/* hold compiled commands */
extern long	linenum[];	/* numeric-addresses table */

/* miscellaneous shared variables */
extern int	nflag;		/* -n option flag */
extern int	eargc;		/* scratch copy of argument count */
extern sedcmd	*pending;	/* ptr to command waiting to be executed */
extern char	bits[];		/* the bits table */

#define MAXHOLD		MAXBUF	/* size of the hold space */
#define GENSIZ		MAXBUF	/* maximum genbuf size */
#define TRUE			1
#define FALSE			0
#define JUMPLIMIT  50  /*max branches before inf loop*/
#define ABORT2(msg,arg) (fprintf(stderr,msg,arg),exit(2))
#define ISWCHAR(c) (isalnum(c)||c=='_')
#define Copy(to,from,ep) {char *it=to,*ix=from;while(*it++=*ix++);ep=it-1;}
static char     INFLOOP[]= "sed: infinite branch loop at line %ld\n";
static char	LTLMSG[] = "sed: line too long at line %ld\n";
static char     FILEBAD[]= "sed: cannot open %s\n";
static char     REBAD[]=   "sed: RE bad code %x\n";
static char     APPERR[]=  "sed: too many appends after line %ld\n";
static char     APPLNG[]=  "sed: append too long after line %ld\n";
static char     READERR[]= "sed: too many reads after line %ld\n";
static char	*spend;		/* current end-of-line-buffer pointer */
static long	lnum = 0L;	/* current source line number */

/* append buffer maintenance */
static sedcmd  *appends[MAXAPPENDS];	/* array of ptrs to a,i,c commands */
static sedcmd **aptr = appends;			/* ptr to current append */

/* genbuf and its pointers and misc pointers*/
static char	genbuf[GENSIZ];
static long     pcnt[MAXPLUS]; /*holder for count downs*/

/* command-logic flags */
static int	lastline;	/* do-line flag */
static int	jump, jumpcnt;	/* jump set and loop counter */
static int	delete = FALSE;	/* delete command flag *//*hh 2*/
static int      cdswitch=FALSE; /*in midst of D command*/

/* tagged-pattern tracking */
static char	*bracend[MAXTAGS+1];	/* tagged pattern start pointers */
static char	*brastart[MAXTAGS+1];	/* tagged pattern end pointers */

/* execute the compiled commands in cmds[] on a file */
void execute(file) char	*file;{	/* name of text source file to be edited */
	register sedcmd *ipc;	/* ptr to current command */
	if (file&&!freopen(file, "rt", stdin)) ABORT2(FILEBAD,file);
	/* here's the main command-execution loop */
        while(pending||cdswitch||(spend=getline(linebuf))){  /* v1.5*/
		ipc =pending? pending:cmds;
		delete=jumpcnt=0;cdswitch=FALSE;
		while(!delete&&ipc->command){
		   if(pending||selected(ipc))command(ipc);
		   if(jump){
			jump=FALSE;
			if(++jumpcnt>=JUMPLIMIT)ABORT2(INFLOOP,lnum);
			ipc=ipc->u.link;}
		   else ipc++;}
		if(pending)break;
		/* we've now done all modification commands on the line */
		PASS("execute(): output");
		if (!nflag && !delete)  puts(linebuf);
		/* if we've been set up for append, emit the text from it */
		if (aptr > appends)readout();
		PASS("execute(): end main loop");}
	PASS("execute(): end execute");}

static int selected(ipc)
sedcmd *ipc;
/* is current command selected */
{/*hh 10*/
   char  *p1=ipc->addr1;
   char  *p2=ipc->addr2;
   int ans,first=FALSE;

   if(!p1)return !ipc->flags.allbut;
   if( (ans=ipc->flags.inrange) != 0) ;	/* v1.4 */
   else if (*p1 == CEND) ans=lastline;
   else if (*p1==CLNUM)
	    first=ipc->flags.inrange=ans=lnum==linenum[*(unsigned char*)(p1+1)];
   else first=ipc->flags.inrange=ans=match(p1, 0);
   if ( ((ipc->flags.inrange&=(p2!=0)) != 0)
		&& (*p2!=CEND)
	  ) {
      if(*p2==CLNUM)ipc->flags.inrange=(lnum<linenum[*(unsigned char*)(p2+1)]);
      else if(*p2==CPLUS){
	  if(first) pcnt[p2[2]]=linenum[*(unsigned char*)(p2+1)];
	  ipc->flags.inrange=((--pcnt[p2[2]])>=0);}
      else ipc->flags.inrange=!match(p2, 0);}
   return ans^ipc->flags.allbut;}

/* match RE at expbuf against linebuf; if gf set, copy linebuf from genbuf */
static int match(expbuf, gf)  char *expbuf;int gf;{/* gf set on recall */
	char  c,  *p1=gf?bracend[0]:linebuf; int i;
        for (i=1;i<MAXTAGS+1;i++)brastart[i]=bracend[i]=linebuf;
	if(gf&&*expbuf) return FALSE; /*no repeats on anchored match*/
	if (*expbuf++) {
		brastart[0]= p1;
		if (*expbuf==CCHR &&expbuf[1] != *p1) /* 1st char is wrong */
			return (FALSE);		/* so fail */
		return (advance(p1, expbuf));}	/* else try to match rest */
	/* quick check for 1st character if it's literal */
	if (*expbuf==CCHR) {c = expbuf[1];  /* get search character */
		do { if (*p1 != c)continue;	/* scan the source string */
		     if (advance(brastart[0]=p1,expbuf)) /* match the rest */
			return  1;
		    } while (*p1++);
		return (FALSE);}	/* didn't find that first char */
	/* else try for unanchored match of the pattern */
	do {if (advance(brastart[0]=p1,expbuf))return  1;
	    } while (*p1++);
	/* if got here, didn't match either way */
	return (FALSE);}

/* attempt to advance match pointer by one pattern element */
static int advance(lp, ep)  char *lp, *ep; {/* source, RE*/
	char  *curlp;	/* save ptr for closures */
	char   c;	/* scratch character holder */
	char  *bbeg,*tep;
	int    ct,i1,i2;	/* scratch integer holders */
	while((c=*ep++)!=CEOF) switch(c){
	  case CCHR:			/* literal character */
		if (*ep++ == *lp++) break;	/* if chars are equal */
		return (FALSE);			/* else return false */
	  case CBOW:                    /*at the begining of a word*/
	       if(ISWCHAR(*lp)&&!ISWCHAR(lp[-1]))break; /*at word start*/
	       return (FALSE);
	  case CEOW:                    /*at the end of a word*/
	       if(!ISWCHAR(*lp)&&ISWCHAR(lp[-1])) break;
	       return (FALSE);
	  case CDOT:			/* anything but eol */
		if (*lp++)  break;	/* not first NUL is at EOL */
		return (FALSE);		/* else return false */
	  case CDOL:			/* end-of-line */
		if (*lp == 0)  break;	/* found that  NUL? */
		return (FALSE);		/* else return false */
	  case CCL:				/* a set */
		ct = *lp++ &0xff;
		if (ep[ct>>3] & bits[ct & 07]) {/* is char in set? */
			ep += 32;		/* then skip rest of bitmask */
			break;}			/* and keep going */
		return (FALSE);			/* else return false */
	  case CBRA:				/* start of tagged pattern */
		brastart[*ep++] = lp;	/* mark it */
		break;				/* and go */
	  case CKET:				/* end of tagged pattern */
		bracend[*ep++] = lp;	/* mark it */
		break;			/* and go */
	  case CBACK:
		bbeg = brastart[*ep];
		ct = bracend[*ep++] - bbeg;
		if (smemcmp(bbeg, lp, ct)) {lp += ct;break;}
		return (FALSE);
	  case CBACK | STAR:
		bbeg = brastart[*ep];
		ct = bracend[*ep++] - bbeg;
		curlp = lp;
		while (smemcmp(bbeg, lp, ct)) lp += ct;
		while (lp >= curlp) {
			if (advance(lp, ep))return (TRUE);
			lp -= ct;}
		return (FALSE);
	case CBACK|MTYPE:
		bbeg = brastart[*ep];
		ct = bracend[*ep++] - bbeg;
		i1=*ep++&0xFF,i2=*ep++&0xFF;
		while(smemcmp(bbeg,lp,ct)&&i1)lp+=ct,i1--;
		if(i1)return FALSE;
		if(!i2||!lp[-1]) break;
		if(i2==0xFF)i2=MAXBUF;
		curlp=lp;
		while(smemcmp(bbeg,lp,ct)&&i2)lp+=ct,i2--;
		while (lp >= curlp) {
			if (advance(lp, ep))return (TRUE);
			lp -= ct;}
		return (FALSE);
	case CCHR|MTYPE:
		c=*ep++;i1=*ep++&0xFF,i2=*ep++&0xFF;
		while(*lp==c&&i1)lp++,i1--;
		if(i1)return FALSE;
		if(!i2||!lp[-1]) break;
		if(i2==0xFF)i2=MAXBUF;
		curlp=lp;
		while(*lp++==c&&i2)i2--;
		goto star;
	case CCL|MTYPE:
		tep=ep;ep+=32;
		i1=*ep++&0xFF,i2=*ep++&0xFF;
		do{ct=*lp++&0xff;
		   if(!(tep[ct>>3]&bits[ct&07]))break;
		   }while(--i1);
		if(i1)return FALSE;
		if(!i2||!lp[-1]) break;
		if(i2==0xFF)i2=MAXBUF;
		curlp=lp;
		do{ct=*lp++&0xff;
		   if(!(tep[ct>>3]&bits[ct&07]))break;
		   }while(--i2);
		goto star;
	case CDOT|MTYPE:
		i1=*ep++&0xFF,i2=*ep++&0xFF;
		while(*lp&&i1)lp++,i1--;
		if(i1)return FALSE;
		if(!i2||!lp[-1]) break;
		if(i2==0xFF)i2=MAXBUF;
		curlp=lp;
		while(*lp++&&i2)i2--;
		goto star;
	  case CDOT | STAR:			/* match .* */
		curlp = lp;			/* save closure start loc */
		while (*lp++) ;			/* match anything */
		goto star;			/* now look for followers */
	  case CCHR | STAR:			/* match <literal char>* */
		curlp = lp;			/* save closure start loc */
		while (*lp++ == *ep) ;		/* match many of that char */
		ep++;				/* to start of next element */
		goto star;			/* match it and followers */
	  case CCL | STAR:			/* match [...]* */
		curlp = lp;			/* save closure set start loc */
		do {ct = *lp++ & 0xFF;	/* match any in set */
		} while (ep[ct>>3] & bits[ct & 07]);
		ep += 32;			/* skip past the set */
		goto star;			/* match followers */
	  star:		/* the recursion part of a * or + match */
		if (--lp == curlp)break;	/* 0 matches */
		if (*ep == CCHR) {c = ep[1];
			do {if (*lp != c) continue;
			    if (advance(lp, ep))return (TRUE);
			    } while (lp-- > curlp);
			return (FALSE);}
		if (*ep == CBACK) {c = *(brastart[ep[1]]);
			do {if (*lp != c)continue;
			    if (advance(lp, ep))return (TRUE);
			    } while (lp-- > curlp);
			return (FALSE);}
		do {
		    if (advance(lp, ep)) return (TRUE);
		    } while (lp-- > curlp);
		return (FALSE);
	  default:ABORT2(REBAD,*--ep);}
	bracend[0] = lp;		/* set second loc */
	return (TRUE); }	/* wow we matched it */

static int substitute(ipc) sedcmd  *ipc;{ /* ptr to s command struct to do */
        int repcnt=1, fcnt=ipc->flags.nthone;
	if (match(ipc->u.lhs, 0))	/* if no match */
		{if(fcnt<=1) dosub(ipc->rhs);}	/* perform it once */
	else   return (FALSE);	/* command fails */
	if (fcnt>1||ipc->flags.global)		/* if global flag enabled */
		while (*bracend[0])		/* cycle through possibles */
			if (match(ipc->u.lhs, 1))	/* found another */
			   {if(!fcnt||++repcnt==fcnt)dosub(ipc->rhs);
                            if(fcnt==repcnt)
					if(!ipc->flags.global)break;
					else fcnt=0;}
			else	break;			/* otherwise,done */
	return !fcnt||fcnt==repcnt;}	/* we succeeded */

/* generate substituted right-hand side (of s command) */
static void dosub(rhsbuf) char *rhsbuf;{/* uses linebuf, genbuf, spend */
	register char  *lp, *sp, *rp;
	int c,room=linebuf+MAXBUF-spend+bracend[0]-brastart[0];
	/* copy linebuf to genbuf up to location  1 */
	lp = linebuf;sp = genbuf;
	while (lp < brastart[0])*sp++ = *lp++;
	for (rp = rhsbuf;
		( --room>0) && ((c = *rp++) != 0)	/* v1.4 expanded */
		 ;)
	    if (c==ARGMARK && *rp>= '0' && *rp<MAXTAGS + '1'){c=*rp++ - '0';
	       if((room-=bracend[c]-brastart[c])<=0)break;
	       else   sp=place(sp,brastart[c], bracend[c]);}
	    else *sp++ = c;
        if(room<=0)ABORT2(LTLMSG,lnum);
	lp = bracend[0]; bracend[0]= linebuf+(sp-genbuf);
	while ( (*sp++ = *lp++) != 0)  ;  /*copy rest of text*//* v1.1 */
	lp = linebuf;	sp = genbuf;
	while ( (*lp++ = *sp++) != 0) ;	 /*copy the line back*//* v1.1 */
	spend = lp - 1;}

/* place chars at *al1...*(al1 - 1) at asp... in genbuf[] */
static char	*place(asp, al1, al2)  char *asp, *al1,*al2;{
  while (al1 < al2) { *asp++ = *al1++;
	 if (asp >= genbuf + MAXBUF) ABORT2(LTLMSG,lnum);}
  return (asp);}

/* write a hex dump expansion of *p1... to fp */
static void listto(p1, fp) char *p1; FILE *fp; {char c;
	while ( (c=*p1++) != 0)		/* v1.4 */
		if (isprint(c)&&c!='\\')
			putc(c, fp);	/* pass it through */
		else {
			putc('\\', fp);	/* emit a backslash */
			switch (c) {
			  case '\\': putc('\\', fp); break;
			  case '\a': putc('a', fp); break;
			  case '\b': putc('b', fp); break;
			  case  27 : putc('e', fp); break; /*ESC*/
			  case '\f': putc('f', fp); break;
			  case '\n': putc('n', fp); break;
			  case '\r': putc('r', fp); break;
			  case '\t': putc('t', fp); break;
			  case '\v': putc('v', fp); break;
			    default: fprintf(fp, "x%02x", c & 0xFF);}}
	putc('\n', fp);}

/* execute compiled command pointed at by ipc */
static void	command(ipc) sedcmd *ipc;{
	static int	 didsub;		/* true if last s succeeded */
	static char	 holdsp[MAXHOLD]; /* the hold space */
	static char	*hspend = holdsp;/* hold space end pointer */
	register char	*p1, *p2;	 /* temp pointers*/
	char	        *execp;
	switch (ipc->command) {
	       case ACMD:			/* append */
			*aptr++ = ipc;
			if (aptr >= appends + MAXAPPENDS) ABORT2(APPERR,lnum);
			*aptr = 0;
			break;
	       case CCMD:			/* change pattern space */
			delete = TRUE;
			if (!ipc->flags.inrange || lastline)
				printf("%s\n", ipc->u.lhs);
			break;
	       case DCMD:			/* delete pattern space */
			delete++;
			break;
	       case CDCMD:		/* delete a line in hold space */
			p1 = linebuf;delete++;
			while (*p1&&*p1 != '\n') p1++;
                        if(!*p1++) return;
			Copy(linebuf,p1,spend);
			cdswitch=TRUE;
			break;
	       case EQCMD:			/* show current line number */
			fprintf(stdout, "%ld\n", lnum);
			break;
	       case GCMD:		/* copy hold space to pattern space */
			Copy(linebuf,holdsp,spend);
			break;
	       case CGCMD:	/* append hold space to pattern space */
			if(spend!=linebuf) *spend++ = '\n';
			if(spend+(hspend-holdsp)>linebuf+MAXBUF)
			      ABORT2(APPLNG,lnum);
			Copy(spend,holdsp,spend);
			break;
	       case HCMD:		/* copy pattern space to hold space */
			Copy(holdsp,linebuf,hspend);
			break;
	       case CHCMD:	/* append pattern space to hold space */
			if(hspend!=holdsp) *hspend++='\n';
			if(hspend+(spend-linebuf)>holdsp+MAXBUF)
			      ABORT2(APPLNG,lnum);
			Copy(hspend,linebuf,hspend);
			break;
	       case ICMD:			/* insert text */
			printf("%s\n", ipc->u.lhs);
			break;
	       case BRCMD:			/* grouping cammand */
		    {sedcmd *a=ipc; while(++a<ipc->u.link)a->flags.inrange=0;}
	       case BCMD:     /*branch to label command*/
                        jump = TRUE;
			break;
	       case LCMD:			/* list text */
			listto(linebuf,(ipc->fout != NULL)?ipc->fout : stdout);
			break;
	       case NCMD: /*read next line into pattern space*/
	       case CNCMD: /*append next line to pattern space*/
			if(!pending){
			    if(ipc->command==NCMD){
			       if(!nflag)puts(linebuf);
			       spend=linebuf;}
			    else  *spend++='\n';
			    if(aptr>appends) readout();}/*do any pending a,r*/
			*spend=0;
			if(!(execp=getline(spend)))
				pending=lastline?NULL:ipc,delete=TRUE;
			else pending=NULL,spend=execp;
			if(spend>linebuf+MAXBUF)ABORT2(APPLNG,lnum);
			break;
	       case PCMD:		/* print pattern space */
			puts(linebuf);
			break;
	       case CPCMD:	/* print one line from pattern space */
	  cpcom:		/* so s command can jump here */
			for (p1 = linebuf; *p1 != '\n' && *p1 != '\0';)
			      putc(*p1++, stdout);
			putc('\n', stdout);
			break;
	       case QCMD:	/* quit the stream editor */
		    if (!nflag)
			puts(linebuf);	/* flush out the current line */
		    if (aptr > appends)
			readout();	/* do any pending a and r commands */
		    exit(0);
	       case RCMD:		/* read a file into the stream */
		    *aptr++ = ipc;
		    if (aptr >= appends + MAXAPPENDS)ABORT2(READERR,lnum);
		    *aptr = 0;
		    break;
	       case SCMD:		/* substitute RE */
			if(didsub=substitute(ipc)){
			if(ipc->fout) fprintf(ipc->fout,"%s\n",linebuf);
			if(ipc->flags.print==1) puts(linebuf);
			else if(ipc->flags.print) goto cpcom;}
		    break;
	       case TCMD:  /* branch on last s successful */
	       case CTCMD: /* branch on last s failed */
		    jump =(didsub==(ipc->command==TCMD));
		    didsub = FALSE;/*reset after test*/
		    break;
	       case CWCMD:	/* write one line from pattern space */
		    for (p1 = linebuf; *p1 != '\n' && *p1 != '\0';)
			putc(*p1++, ipc->fout);
		    putc('\n', ipc->fout);
		    break;
	       case WCMD:	/* write pattern space to file */
		    fprintf(ipc->fout, "%s\n", linebuf);
		    break;
	       case XCMD:	/* exchange pattern and hold spaces */
		    Copy(genbuf,linebuf,spend);
		    Copy(linebuf,holdsp,spend);
		    Copy(holdsp,genbuf,hspend);
		    break;
	       case YCMD:
		    p1 = linebuf;p2 = ipc->u.lhs;
		    while(*p1){*p1=p2[(*p1)&0xFF]; p1++;}
		    break;}}

/* get next line of text to be filtered */
static char *getline(buf) char *buf;/* where to put line*/{
  int temp;
  if (gets(buf) != NULL) {/*hh 20*/
	 lnum++;	/* note that we got another line */
	 while (*buf++) ;		/* find the end of the input */
	 if((temp=getc(stdin))==EOF)/*hh 20*/
		    lastline=(eargc==0);
	 else ungetc(temp,stdin);
	 return (--buf);}	/* return ptr to terminating null */
  else  if (eargc == 0)    lastline = TRUE;  /* if no more args this is it */
  return NULL;}

/* return TRUE if *a... == *b... for count chars, FALSE otherwise */
static int	smemcmp(a, b, count) register char  *a, *b;int count;{
	while (count--)				/* look at count characters */
		if (*a++ != *b++)		/* if any are nonequal   */
			return (FALSE);		/* return FALSE for false */
	return (TRUE);}				/* compare succeeded */

/* write file indicated by r command to output */
static void readout() {
	register int	t;			/* hold input char or EOF */
	FILE	       *fi;		/* ptr to file to be read */
	aptr = appends - 1;	/* arrange for pre-increment to work right */
	while (*++aptr)
		if ((*aptr)->command == ACMD)	/* process "a" cmd */
			printf("%s\n", (*aptr)->u.lhs);
	else {				/* process "r" cmd */
		if((fi=fopen((*aptr)->u.lhs,"rt"))==NULL)
		     ABORT2(FILEBAD,(*aptr)->u.lhs);
		while ((t = getc(fi)) != EOF)
			putc((char) t, stdout);
		fclose(fi);}
	aptr = appends;		/* reset the append ptr */
	*aptr = 0;}

/* sedexec.c ends here */
