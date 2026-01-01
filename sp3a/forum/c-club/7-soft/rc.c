#include "keys.h"
#include <ctype.h>
#define maxlength 254
#define xx 9
#define yy 1

char RCalcTitle[]="RC - Resident calculator Version 1.10 (c) 1991 7-Soft";

typedef unsigned char byte;

extern int	_psp;
extern int	page;
extern unsigned scanlines;
extern unsigned _heaplen=1;
extern unsigned _stklen=0x80;
extern unsigned	size;
extern unsigned width;
extern byte _seg *displayptr;

char S_EMPTY[]="",F_S[]="%-60s",F_Full[]="%-80s";
char op_mu[]="*/&|><^";
char op_ad[]="+-";
char far *Ptr;
char *pos;
char *EDIT_S;
unsigned screenlength;

void interrupt (*getvect(int interrupno))();
void setvect(int interruptno,void interrupt(*isr)());
int  sprintf(char *s,const char* Format, ...);
void __emit__();

#define __cli__()	__emit__(0xFA)
#define __int__(c)	__emit__(0xCD,(c))
#define FP_OFF(p)	((unsigned)(p))
#define FP_SEG(p)	((unsigned)(byte _seg *)(byte far *)(p))
#define MK_FP(seg,ofs)	((byte _seg *)(seg)+(byte near *)(ofs))
#define NULL 0L

byte	Release;
char	s[maxlength+1]="";

void	 movmem (byte *src,byte *dest,unsigned length);
char	*strchr (char *s,char c);
unsigned strlen (char *s);
char	*strcpy (char *dest,char *src);

long	 ad();
long	 mu();
long	 evaluate();
long	 getnum();
int	 ch2num();

void	interrupt (*Old09)(void);
void	interrupt (*Old16)(void);
#define legal	S_EMPTY
#define GetText() movmem(Ptr,(Ptr=displayptr+page*size)+size,80*10*2)
#define PutText() movmem(Ptr+size,(Ptr=displayptr+page*size),80*10*2)
#define IsAlpha(c) (isalpha((c))|isxdigit((c))|((c)>='А'&&(c)<='я'))
long error(int no)
{
 static char *err[]=	{ "Ok",
			  "Bad expression",
			  "Bad digit",
			  "Division by zero"
			};
 writef(9,7,0x07,F_S,err[no]);
 return 0;
} /* error */

long ad()
{
  /* Evaluates add operands */
  #pragma warn -pia
  long r=mu(),n,x;
  while((n=(long)strchr(op_mu,*pos))&&*pos)
  {
    n-=(long)op_mu;
    pos++;
    x=mu();
    switch((char)n)
    {
      case 0:r*=x;break;
      case 1:r/=(x==0)?1+error(3):x;break;
      case 2:r&=x;break;
      case 3:r|=x;break;
      case 4:r>>=x;break;
      case 5:r<<=x;break;
      case 6:r^=x;
    } /*switch*/
  } /*while*/
  return r;
} /*ad*/

long mu()
{
  /* Evaluates multiply operands */
  long r;
  if(*pos=='(')
  {
    pos++;
    r=evaluate();
    pos++;
  } /*if*/
  else r=getnum();
  return r;
} /*mu*/

long getnum()
{
  /* Evaluates numbers */
  long r,rr;
  int i,k,l,base;
  if(*pos=='\''&&*(pos+2)=='\'')
  {
    /* Character operand */
    pos+=3;
    return *(pos-2);
  } /* if */
  if(*pos=='?'&&*(pos+1)=='(')
  {
    /* Peek operation */
    pos+=2;
    r=evaluate();
    pos++;
    rr=evaluate();
    pos++;
    return *(unsigned *)MK_FP(r,rr);
  } /* if */
  if(isdigit(*pos))
  {
    for(i=0;isdigit(pos[i])||isalpha(pos[i]);i++);
    base=10;l=i-1;
    switch(tolower(pos[l]))
    {
      case 'b':base=2;
	       break;
      case 'o':base=8;
	       break;
      case 'd':break;
      case 'h':base=16;
	       break;
      default :l++;
    } /*switch*/
    r=0;
    for(k=0;k<l;k++)
      r=r*base+ch2num(pos[k],base);
    pos+=i;
  } /*if*/
  else error(1); /* Bad Expression */
  return r;
} /*getnum*/

int ch2num(char ch,int base)
{
  /* Converts charecter to number */
  int r=0;
  if(isxdigit(ch))
  {
    if(isdigit(ch))
      r=(int)(ch-'0');
    else
      r=(int)(tolower(ch)-'a'+10);
    if(r>=base)
      r=error(2);/* BAD DIGIT */
  } /*if*/
  else error(1);/* BAD EXPRESSION */
  return r;
} /* ch2num */

long evaluate()
{
  /* Evaluates expression */
  #pragma warn -pia
  long r=ad(),f,x;
  while((f=(long)strchr(op_ad,*pos))&&*pos)
  {
    f-=(long)op_ad;
    pos++;
    x=ad();
    switch((char)f)
    {
      case 0:r+=x;break;
      case 1:r-=x;
    } /*switch*/
  } /*while*/
  return r;
} /*getd16*/

void GoToXY(int col, int row) 
{
  _BH = page;
  _DH = row;
  _DL = col;
  _AH = 2;
  __int__(0x10);
} /* GoToXY */

void setcursor(int startline, int endline) 
{
  _CH = startline;
  _CL = endline;
  _AH = 1;
  __int__(0x10);
} /* setcursor */

void changecursor(insmode)
{
  if (insmode)
    setcursor(scanlines-3,scanlines-2);
  else
    setcursor(1,scanlines-2);
} /* changecursor */

int editstring()
{
  int beg=1,c,len=strlen(EDIT_S),pos=len-(len==maxlength),insert=1/* TRUE */,shift=0;char count,is=(len>screenlength);
  changecursor(insert);
  do
  {
    c=screenlength-is-(shift!=0);
    if(pos>=c+shift)
    {
      shift=pos-c+1;
      if(shift==1) shift++;
    } /* if */
    if(pos<=shift)
    {
      shift=pos;
      if(shift==1) shift--;
    } /* if */
    is=(len>c+shift);
    c=screenlength-is-(shift!=0);
    writef(xx,yy,(beg)?0x0F:0x07,"%s%-*.*s%s",shift?"":S_EMPTY,c,c,EDIT_S+shift,is?"":S_EMPTY);
    GoToXY(pos+xx-shift+(shift!=0),yy);
    switch(c=getkey())
    {
      case keyHome     :pos=0;
			break;
      case keyEnd      :pos=len-(len==maxlength);
			break;
      case keyIns      :changecursor(insert=!insert);
			break;
      case keyLeft     :if(pos>0) pos--;
			break;
      case keyRight    :if(pos+(len==maxlength)<len) pos++;
			break;
      case keyBS       :if(pos>0)
			{
			  movmem(&EDIT_S[pos],&EDIT_S[pos-1],len-pos+1);
			  pos--;
			  len--;
			} /* if */
			break;
      case keyDel      :if(pos<len)
			{
			  movmem(&EDIT_S[pos+1],&EDIT_S[pos],len-pos+1);
			  len--;
			} /* if */
			break;
      case keyCtrlRight:for(pos+=(pos<len);IsAlpha(EDIT_S[pos])&&pos<=len;pos++);
			for(;!(IsAlpha(EDIT_S[pos]))&&pos<=len;pos++);
			goto Chpos;
      case keyCtrlLeft: for(pos-=(pos!=0);!(IsAlpha(EDIT_S[pos]))&&pos>=0;pos--);
			for(;IsAlpha(EDIT_S[pos])&&pos>=0;pos--);
			pos++;
Chpos:			if(pos>=len) pos=len-(len!=0);
			break;
      case keyCtrlBS   :for(;IsAlpha(EDIT_S[pos])&&pos>=0;pos--);
			for(c=pos+1;IsAlpha(EDIT_S[c])&&c<=len;c++);
			movmem(&EDIT_S[c],&EDIT_S[pos+1],len-c+1);
			len-=c-pos-1;
			break;
      case keyCtrlHome :pos=0;
			for(c=0;c<len;EDIT_S[c++]=' ');
			len=0;
			break;
      case keyCtrlEnd:if(pos<len) for(c=pos;c<len;EDIT_S[c++]=' ');
			len=pos;
      case keyCR       :break;
      case keyEsc      :len=0;
			break;
      default	       :if(c>=0x100)
			break;
			if(beg) *EDIT_S=len=pos=0;
			if((legal[0]==0||strchr(legal,c)!=0)&&len<=maxlength)
			{
			  if(insert)
			  {
			    memmove(&EDIT_S[pos+1],&EDIT_S[pos],len++-pos+1);
			    if(len>maxlength) EDIT_S[--len]=0;
			  } /* if(insert) */
			  else
			    if(pos>=len)
			    {
			      if(len>=maxlength) break;
			      len++;
			      EDIT_S[pos+1]='\0';
			    } /* if(pos... */
			  EDIT_S[pos++]=c;
			  if(pos>=maxlength) pos--;
			} /* if((legal[0]==... */
    } /* switch */
    beg=0;
  } /*do-while*/
  while((c!=keyCR)&&(c!=keyEsc));
  setcursor(0x20,0);
  return (c!=keyEsc);
} /* editstring */

int getkey(void)
{
  int key , lo, hi;
  _AX=0;
  __int__(0x16);
  key=_AX;
  lo = key & 0X00FF;
  hi = key >> 8;
  return((lo == 0) ? hi + 0x100 : lo);
} /* getkey */

char *num2bin(unsigned long value)
{
  /* Converts number to binary string */
  static char str[33];
  register signed char i=31;
  do
  {
    str[i--]=(value&1)+'0';
    value>>=1;
  } /* do */
  while(value>0); /* do-while */
  str[32]=0;
  return &str[i+1];
} /* num2bin */

void calc()
{
  /* Main calculator procedure */
  char t[10];
  long n;
  Old09();
  initdisplay();
  screenlength=width-16;
  GetText();
  border(0,0,width-8,7,0x07,0x07);
  writef(1,1,0x07,"Command:");
  writef(1,2,0x07,"Decimal:");
  writef(1,3,0x07,"Hexadec:");
  writef(1,4,0x07,"Binary :");
  writef(1,5,0x07,"Octal  :");
  writef(1,6,0x07,"Charact:");
  writef(1,7,0x07,"Message: %s",RCalcTitle);
  EDIT_S=s;
  while(editstring())
  {
    error(0); /* clear message line */
    if(*s==0)
      *(unsigned*)s='0';
    pos=s;
    n=evaluate();
    writef(9,2,0x07,"%ld(%lu)%20s",n,n,S_EMPTY);
    sprintf(t,"0%lX",n);
    writef(9,3,0x07,"%sh%10s",isdigit(t[1])?t+1:t,S_EMPTY);
    writef(9,4,0x07,"%sb%31s",num2bin(n),S_EMPTY);
    writef(9,5,0x07,"%loo%10s",n,S_EMPTY);
    pr( 9,6,0x07, (unsigned long)n>>24);
    pr(10,6,0x07,((unsigned long)n>>16)&0xFF);
    pr(11,6,0x07,((unsigned long)n>> 8)&0xFF);
    pr(12,6,0x07, (unsigned long)n     &0xFF);
    for(n=0;n<maxlength&&s[n]!=' ';n++);
    if(n<maxlength) s[n+1]=0;
  } /* while */
  changecursor(1);
  PutText();
} /* calc */

void interrupt New09()
{
  register char c;
  __emit__(0xE4,0x60); /* in	al,60h */
  c=_AL; 
  if(c==0x9D||(Release==3&&c==0x1D)) 
    Release++; 
  if((c&0x7F)!=0x1D)
    Release=0;
  if(Release==3)
  {
    calc();
    Release=0;
  } /* if */
  else
    Old09();
} /* New09 */

void interrupt New16(Bp,Di,Si,Ds,Es,Dx,Cx,Bx,Ax,Ip,Cs,Flags)
  unsigned Bp,Di,Si,Ds,Es,Dx,Cx,Bx,Ax,Ip,Cs,Flags;
{
  #pragma argsused
  if(_AX=='??') Ax='77';
  else 
  {
    Old16();
    Ax=_AX;
    Flags=_FLAGS;
  } /* else */
} /* New16 */

void main(void)
{
  initdisplay();
  writef(0,1,0x07,F_Full,RCalcTitle);
  writef(0,2,0x07,F_Full,"Press Ctrl-Ctrl-Ctrl to activate...");
  _AX='??';	/* Check installation */
  __int__(0x16);
  if(_AX=='77')	/* Installed */
  {
    writef(0,3,0x07,F_Full,"RC already installed.");
    _AX=0x4C01;
    __int__(0x21);
  } /* if */
  Old09=getvect(0x09);
  Old16=getvect(0x16);
  __cli__();
  setvect(0x09,New09);
  setvect(0x16,New16);
  _DX=_SS+_SP/16-0x80/16-_psp;
  _AX=0x3100;
  __int__(0x21);
} /* main */