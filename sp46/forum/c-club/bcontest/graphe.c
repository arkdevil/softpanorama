/*
 * Gaifullin B.N. C Graphics Toolbox ( CGA&EGA )
 * 142432 USSR, Chernogolovka
 * last changes: JAN-91
 */

#include <stdarg.h>
#include <stdio.h>
#include <dos.h>
#include <conio.h>
#include <math.h>

#define XORMODE	0x18
#define ORMODE	0x10
#define ANDMODE	0x08

#define	NSPRITE	20		/* max number of sprites */
#define EGABASE 0xa0000000L

#define TRUE 0xFF
#define ENABLE 0x0F
#define INDEXREG 0x3CE
#define VALREG 0x3CF
#define OUI(index,val)	{outp(INDEXREG,index); outp(VALREG,val);}
#define DIS {OUI(0,0);OUI(1,0);OUI(3,0);OUI(8,TRUE);}
#define ENA {OUI(0,ColorGlb);OUI(1,ENABLE);OUI(3,XORModeGlb);}
#define COPENA	{ OUI(1,ENABLE);OUI(3,0);OUI(5,1);}
#define COPDIS	{ OUI(0,0);OUI(1,0);OUI(3,0);OUI(8,0xff);OUI(5,0);}
#define EGACOPBYTE(from,to) { e_c=*((unsigned char far *)(from));	\
	OUI(8,0x80); *((unsigned char far *)(to))=TRUE; }


int	XMaxGlb	= 79;	/*  Number of BYTES -1 in one screen line */
int	XScreenMaxGlb=639; /*  Number of PIXELS -1 in one screen line */
int	YMaxGlb =349;	/*  Number of lines -1 on the screen */
int	ScreenSizeGlb=16383; /* Total size in integers of the screen */
                         /* 16383 for EGA, 8191 for CGA */
int	ColorGlb;
int	MaxClr,ClrWid,Shifter;
int	XORModeGlb=0;
int	TextModeGlb=0;
int	PaletteGlb,BackGroundGlb;
int	LineStyleGlb=0;
int	CntGlb=7;
unsigned char	LnStyleArray[8];
unsigned char	DisplayMem;
int	ClippingGlb=0;
int	HatchGlb=0;
int	GrafModeGlb=0;
int 	EGAColor;
int	XTextGlb,YTextGlb;
double	AspectFactor=0.86;
double	AspectGlb=0.86;
int	NScreenGlb;
int	WorldsMaxGlb=10;
int	WindowsMaxGlb=16;
int	WorldMaxGlb=0,WindowMaxGlb=0;
double	X1WldGlb,Y1WldGlb,X2WldGlb,Y2WldGlb;
int	WindowNdxGlb;
int	X1RefGlb,Y1RefGlb,Y2RefGlb,X2RefGlb;
int	Ega;
double	BxGlb,ByGlb,AxGlb,AyGlb;

unsigned YAddr[350],XAddr[640];
unsigned char	Shift[640],Point[640];

unsigned char far *ScreenGlb = (unsigned char far *)0xA0000000;
int far *	RAMScreenGlb=NULL;
int far *	HardwareGraf=(int far *)0xA0000000;

unsigned char	HatchArray[8][8];
extern int	HatchGlb;
unsigned char	CharSet[256][8];
int	CharHGlb,CharWGlb,CharSHGlb,CharSWGlb;
int	CharScaleGlb;
int	e_c;
unsigned char exist_color;

struct world{
	double	x1,y1,x2,y2;
       } World[10];
struct window{
	int	ix1,iy1,ix2,iy2;
       } Window[16];

int GetMode()
{
  union REGS reg;
  reg.h.ah=0x0F;
  reg.h.al=0;
  int86(0x10,&reg,&reg);
  return(reg.h.al);
}	/* GetMode() */

SetMode(Mode)
int	Mode;
{
  int	indx=0, indx2=0;
  unsigned	mask;
  union REGS	reg;
  if(Mode>16){
    puts("Invalid video mode\n"); exit(0);
  }
  switch(Mode){
    case 4:
    case 5:	XScreenMaxGlb=319;
		YMaxGlb=199; Shifter=4; MaxClr=3; ClrWid=2;
		Ega=0; break;
    case 6:	XScreenMaxGlb=639;
		YMaxGlb=199; Shifter=8; MaxClr=1; ClrWid=1;
		Ega=0; break;
    case 13: case 14: case 15:
    case 16:	XScreenMaxGlb=639;
		YMaxGlb=349; Shifter=8; MaxClr=15; ClrWid=1;
		reg.h.ah=0x12; reg.x.bx=0xFF10;
		int86(0x10,&reg,&reg);
		if(reg.h.bh==0xFF){ puts("EGA not installed "); return; }
		if(reg.h.cl!=9){
		  puts("EGA not present with color display ");return;
		}
		DisplayMem=reg.h.bl;
		Ega=1; break;
  }
  if(Mode>3){
    GrafModeGlb=Mode;
    if(Mode<=6){
      ScreenSizeGlb=8191;
      while(indx<=YMaxGlb){
	YAddr[indx++]=80*indx2;
	YAddr[indx++]=80*(indx2++) + 0x2000;
      }
    }else{	/* EGA */
      for(indx=0;indx<=YMaxGlb;++indx) YAddr[indx]=80*indx;
    }
    for(indx=0;indx<=XScreenMaxGlb;++indx){
       mask=0x80>>(ClrWid*(indx%Shifter));
       if(Mode<6){
         mask|=(mask>>1);
         Shift[indx]=6-(ClrWid*(indx%Shifter));
       }else if(Mode==6){
         Shift[indx]=7-(indx%Shifter);
       }else{
	 Shift[indx]=7-(ClrWid*(indx%Shifter));
       }
       if(Ega) Point[indx]=mask; else Point[indx]=~mask;
       XAddr[indx]=indx/Shifter;
    }
  }else GrafModeGlb=0;
  if(GrafModeGlb<=6) HardwareGraf=(int far *)0xB8000000;
  else HardwareGraf=(int far *)0xA0000000;
  ScreenGlb=(unsigned char *)HardwareGraf;
  reg.h.ah=0;
  reg.h.al=Mode;
  int86(0x10,&reg,&reg);
}	/* SetMode() */

static int	SaveStat;

void InitGraphic(n)
int	n;
{
  int	i,j,mn;
  SaveStat=GetMode(); mn=n; n=abs(n);
  SetMode(n);
/*  if(n<6){
    SetPalette(0);
    SetBackGround(0);
    GotoXY(0,0);
  }*/
  SetForeGround(MaxClr);
  ClrScreen();
  for(i=0;i<WorldsMaxGlb;++i)
     DefWorld(i,0.,0.,(double)XScreenMaxGlb,(double)YMaxGlb);
  for(i=0;i<WindowsMaxGlb;++i)
     DefWindow(i,0,0,XScreenMaxGlb,YMaxGlb);
  WorldMaxGlb=WindowMaxGlb=WindowNdxGlb=0;
  SelectWorld(0); SelectWindow(0); SetClipping(0);
  SetHatchStyle(0); SetLineStyle(0); SetXORMode(0);
  SetAspect(1.);
  if(mn>0){
    AllocRAMScreen();
    SelectScreen(2);ClrScreen();
  }
  SelectScreen(1);
}	/* InitGraphic() */

void CloseGraphic()
{
  SelectScreen(1);
  ClrScreen();
  SetMode(SaveStat);
}	/* CloseGraphic() */

SetPalette(P)
int 	P;
{	union  REGS inregs,outregs;
	inregs.h.ah=0x0b;	/* call   BIOS to set palette */
	inregs.h.bh=1;
	inregs.h.bl=P&0x01;
	int86(0x10,&inregs,&outregs);
	PaletteGlb=P&1;
}	/* SetPalette() */

SetEGAPalette(P,Color)
int	P,Color;
{  union REGS reg;
  reg.x.ax=0x1000; reg.h.bh=Color; reg.h.bl=P;
  int86(0x10,&reg,&reg);
}	/* SetEGAPalette() */

SetBackGround(Color)
int  Color;
{ union REGS inregs, outregs;
  BackGroundGlb=Color&0x0F;
  if(Ega){ SetEGAPalette(0,Color); return; }
  inregs.h.ah=0x0b;
  inregs.h.bh=0;
  inregs.h.bl=Color&0x0f;
  int86(0x10,&inregs,&outregs);
}	/* SetBackGround() */

SetForeGround(Color)
int	Color;
{
  ColorGlb=Color&MaxClr;
}	/* SetForeGround() */

int GetPalette()
{
  return(PaletteGlb);
}	/* GetPalette() */

int GetMaxColor()
{
  return(MaxClr);
}	/* GetMaxColor() */

int GetBackGround()
{
  return(BackGroundGlb);
}	/* GetBackGround() */

int GetForeGround()
{
  return(ColorGlb);
}	/* GetForeGround() */

SetXORMode(Mode)
int Mode;
{
  if(Ega) XORModeGlb=Mode;
  else XORModeGlb=Mode&1;
}	/* SetXORMode() */

int GetXORMode()
{
  return(XORModeGlb);
}	/* GetXORMode() */

SetAspect(a)
double	a;
{
  if(fabs(a))AspectGlb=a*AspectFactor;
}	/* SetAspect() */

double GetAspect()
{
  return(AspectGlb/AspectFactor);
}	/* GetAspect() */

#define DPQ(x,y)                                                    \
{ /* quick point drawing */                                         \
  unsigned	total;  int		b;                          \
  unsigned char	far	*base;      				    \
  if(Ega){                                                          \
    base=(unsigned char far *)((long)ScreenGlb+(YAddr[y]+XAddr[x]));         \
    OUI(8,Point[x]);exist_color=*base; *base&=TRUE;                 \
  }else{                                                            \
    total=XAddr[x]+YAddr[y];  b=ScreenGlb[total];                   \
    if(!XORModeGlb) b&=Point[x];                                    \
    ScreenGlb[total]= (ColorGlb<<Shift[x])^b;                       \
  }                                                                 \
}	/* DPQ() */

DP(x,y)
int	x,y;
{
  unsigned char	far	*base;
  if(ClippingGlb){
    if(x<X1RefGlb || x>X2RefGlb || y<Y1RefGlb || y>Y2RefGlb) return;
  }
  if(Ega) ENA; DPQ(x,y); if(Ega) DIS;
} /* DP() */

DPC(x,y,Color)
int	x,y,Color;
{
  int	c=ColorGlb; ColorGlb=Color&MaxClr;
  if(Ega) ENA; DPQ(x,y); if(Ega) DIS;
  ColorGlb=c;
}	/* DPC() */

void IP(x,y)
int	x,y;
{
  unsigned	total;
  int		b,a;
  if(!Ega){
    total=XAddr[x]+YAddr[y];
    a=ScreenGlb[total]; b=a&Point[x];
    a=(~((a&(~Point[x])) >> Shift[x]))&MaxClr;
    ScreenGlb[total]= (a<<Shift[x])|b;
  }else{
    a=XORModeGlb; XORModeGlb=0x18;
    DPC(x,y,15);
    XORModeGlb=a;
/*    DPC(x,y,~PD(x,y));*/
  }
}	/* IP() */

int PD(x,y)
int	x,y;
{
  union REGS regs;
  if(Ega){
    regs.h.bh=0; regs.h.ah=13;regs.x.dx=y; regs.x.cx=x;
    int86(0x10,&regs,&regs);
    return(regs.h.al);
  }else{
    return((ScreenGlb[XAddr[x]+YAddr[y]]&(~Point[x]))>>Shift[x]);
  }
}	/* PD() */

int GetKey(void)	/*  uses the BIOS to read the next keyboard char */
{	int key,lo,hi;
	key=bioskey(0);
	lo=key&0x00FF;
	hi=(key&0xFF00)>>8;
	return((lo==0)?hi+256:lo);
}	/* GetKey() */

GotoXY(col,row)
int col,row; 	/* moves the cursor to a specific column and row */
{	union REGS reg;
	if(!GrafModeGlb || !TextModeGlb){
 	reg.h.ah=2;
	reg.h.bh=0;
	reg.x.dx=(row<<8)+col;
	int86(0x10,&reg,&reg);
        }
        XTextGlb=col; YTextGlb=row;
}	/* GotoXY() */

GetXY(pcol,prow)
int *pcol,*prow;
{	union REGS reg;
 	reg.h.ah=3;
	reg.h.bh=0;
	int86(0x10,&reg,&reg);
        *prow=reg.h.dh; *pcol=reg.h.dl;
}

Sound(Freq,Time)
int	Freq,Time;
{
#define TIMESCALE	1230L		/* for XT */
  int	hibyt,lobyt,port;
  long	i,count,divisor;
  divisor=1331000L/Freq; lobyt=divisor%256; hibyt=divisor/256;
  count=TIMESCALE*Time;
  outportb(67,182); outportb(66,lobyt); outportb(66,hibyt);
  port=inportb(97);outportb(97,port|3);
  for(i=1;i<=count;++i) ;
  outportb(97,port);
}	/* Sound() */

Mouse(code,pbuttons,px,py)
int	code;
int	*pbuttons,*px,*py;
{
  union REGS reg;
  reg.x.ax=code; reg.x.bx=*pbuttons;
  reg.x.cx=*px;  reg.x.dx=*py;
  int86(51,&reg,&reg);
  *pbuttons=reg.x.bx; *px=reg.x.cx; *py=reg.x.dx;
}	/* Mouse() */

int EditString(s,legal,maxlength)
unsigned char	s[],legal[];
int	maxlength;
{
#define	HOMEKEY		327
#define	ENDKEY		335
#define INSKEY		338
#define LEFTKEY		331
#define RIGHTKEY	333
#define DELKEY		339
#define CR		13
#define BS		8
#define ESC		27

  int	c,len=strlen(s),pos=len,insert=0;
  int	x,y,i;
  GetXY(&x,&y);
  do{ GotoXY(x,y);
    for(i=0;i<maxlength;++i) if(i<len)putchar(s[i]);else putchar(' ');
    GotoXY(x+pos,y);
    switch(c=GetKey()){
      case HOMEKEY: pos=0; break;
      case ENDKEY:  pos=len;break;
      case INSKEY:  insert= !insert;break;
      case LEFTKEY: if(pos>0) pos--;break;
      case RIGHTKEY:if(pos<len)pos++;break;
      case DELKEY:  if(pos<len){
                      movmem(&s[pos+1],&s[pos],len-pos); len--;
                    } break;
      case BS: if(pos>0){
                 movmem(&s[pos],&s[pos-1],len-pos+1); pos--; len--;
               } break;
      case CR: break;
      case ESC:len=0;break;
      default:
        if(((legal[0]=='\0')||(strchr(legal,c)!=NULL))&&
          ((c>=' ')&&(len<maxlength))){
          if(insert){
            memmove(&s[pos+1],&s[pos],len-pos+1); len++;
          }else if(pos>=len) len++;
          s[pos++]=c;
        }
        break;
    } /* switch */
    s[len]='\0';
  }while((c!=CR)&&(c!=ESC));
  return((c!=ESC)?1:-1);
}	/* EditString() */

SetCursor(startline,endline)
int	startline,endline;
{
  union REGS reg;
  reg.h.ah=1;
  reg.x.cx=(startline<<8)+endline;
  int86(0x10,&reg,&reg);
}	/* SetCursor() */

int	EGAInstalled()
{
  union	REGS reg;
  reg.x.ax=0x1200;
  reg.x.bx=0x0010;
  reg.x.cx=0xFFFF;
  int86(0x10,&reg,&reg);
  return((reg.x.cx==0xFFFF)?0:1);
}	/* EGAInstalled */

void Scroll(direction,lines,x1,y1,x2,y2,attrib)
int direction,lines,
    x1,y1,x2,y2,
    attrib;
{
  union REGS reg;
  reg.x.ax=((direction+4)<<8)+lines;
  reg.h.bl=attrib;
  reg.x.cx=(y1<<8)+x1;
  reg.x.dx=(y2<<8)+x2;
  int86(0x10,&reg,&reg);
}	/* Scroll() */

ClrScreen()
{
  int	i;
  if(ScreenGlb==NULL) return;
  for(i=0;i<=ScreenSizeGlb;++i){
     ((int far *)ScreenGlb)[i]=0;
  }
}	/* ClrScreen() */

void Line(x1,y1,x2,y2)
int	x1,y1,x2,y2;
{
  int	x,y,deltax,deltay,xstep,ystep;
  int	s,i;
  if(Ega) ENA;
  x=x1; y=y1;
  xstep=((x1<=x2)? 1 : -1);
  ystep=((y1<=y2)? 1 : -1);
  deltax=abs(x2-x1); deltay=abs(y2-y1);
  if(deltax>deltay){
    s=deltax>>1;
    for(i=0;i<=deltax;i++){
       if(!LineStyleGlb){
         if(x>=X1RefGlb&&x<=X2RefGlb&&y>=Y1RefGlb&&y<=Y2RefGlb||!ClippingGlb)
		   DPQ(x,y);
       }else{
         CntGlb=(CntGlb+1)&7;
         if(LnStyleArray[CntGlb])
		   if(x>=X1RefGlb&&x<=X2RefGlb&&y>=Y1RefGlb&&y<=Y2RefGlb||!ClippingGlb)
			 DPQ(x,y);
       }
       x+=xstep; s+=deltay;
       if(s>=deltax){
         y+=ystep; s-=deltax;
       }
    }
  }else{
    s=deltay>>1;
    for(i=0;i<=deltay;++i){
       if(!LineStyleGlb){
         if(x>=X1RefGlb&&x<=X2RefGlb&&y>=Y1RefGlb&&y<=Y2RefGlb||!ClippingGlb)
		   DPQ(x,y);
       }else{
         CntGlb=(CntGlb+1)&7;
         if(LnStyleArray[CntGlb])
		   if(x>=X1RefGlb&&x<=X2RefGlb&&y>=Y1RefGlb&&y<=Y2RefGlb||!ClippingGlb)
			 DPQ(x,y);
       }
       y+=ystep; s+=deltax;
       if(s>=deltay){
         x+=xstep; s-=deltay;
       }
    }
  }
  if(Ega) DIS;
}	/* Line() */

SetLineStyle(ls)
int	ls;
{int	i;
  static int lsa[5]={0xFF,0x88,0xF8,0xE4,0xEE};
  if(ls<0 ||ls>4) ls=(ls&0xFF)+0x100;
  LineStyleGlb=ls;
  if(ls<5) ls=lsa[ls];
  for(i=0;i<=7;++i)LnStyleArray[7-i]=(ls>>i)&1;
  CntGlb=7;
}	/* SetLineStyle() */

int GetLineStyle()
{
  return(LineStyleGlb);
}	/* GetLineStyle() */

int GetClipping()
{
  return(ClippingGlb);
}	/* GetClippingGlb() */

SetClipping(i)
int	i;
{
  ClippingGlb=i;
}	/* SetClipping() */

AllocRAMScreen()
{
  void	*calloc();
  if(!Ega){
    RAMScreenGlb=(int *)calloc(ScreenSizeGlb,sizeof(int));
    if(RAMScreenGlb==NULL){
      puts("can not allocate RAM Screen ");GetKey();
    }
  }else{	/* for EGA */
    RAMScreenGlb=(int *)((long)HardwareGraf+440*80L);
  }
}	/* AllocRAMScreen() */

void CopyScreen()
{
  int far * p;
  int	i,o;
  long	ii,jj,ij,ij0=80L*350L;
  if(RAMScreenGlb!=NULL){
    if(ScreenGlb==(unsigned char far *)HardwareGraf){
      p=RAMScreenGlb; o=0;
    }else{
      p=HardwareGraf; o=1;
    }
    if(!Ega){	/* CGA */
      for(i=0;i<=ScreenSizeGlb;++i){
	 p[i]=((int far *)ScreenGlb)[i];
      }
    }else{	/* EGA */
     COPENA;
     if(!o){
       ii=(long)HardwareGraf; jj=(long)RAMScreenGlb;
     }else{
       jj=(long)HardwareGraf; ii=(long)RAMScreenGlb;
     }
     for(ij=0;ij<ij0;++ii,++jj,++ij){
	EGACOPBYTE(ii,jj);

     }
     COPDIS;OUI(0,0);
     OUI(1,0);OUI(3,0);
     OUI(8,0xff);OUI(5,0);
    }
  }
}	/* CopyScreen() */

void InvertScreen()
{
  int i,j;
  if(ScreenGlb==NULL) return;
  if(!Ega)
    for(i=0;i<=ScreenSizeGlb;++i){
       ((int far *)ScreenGlb)[i]=~((int far *)ScreenGlb)[i];
    }
  else{
    int a,c;
    a=XORModeGlb; XORModeGlb=0x18;
    c=ColorGlb; ColorGlb=255&MaxClr;
    for(i=0;i<=XScreenMaxGlb;++i)
       for(j=0;j<=YMaxGlb;++j){
	  /*IP(i,j);*/
	  if(Ega) ENA; DPQ(i,j); if(Ega) DIS;
       }
    ColorGlb=c;
    XORModeGlb=a;
  }
}	/* InvertScreen() */

void SwapScreen()
{
  int	g,i,j,is;
  long	ii,ij0;
  unsigned char	b[8];
  unsigned char  far *s0,*s1,*s2;
  if(RAMScreenGlb!=NULL){
    if(Ega){
      COPENA; ij0=350L*80L;
      s0=(unsigned char far *)RAMScreenGlb;
      is=GetScreen(); SelectScreen(1);
      for(i=0;i<8;++i) b[i]=PD(i,0);
      s1=(unsigned char far *)HardwareGraf; EGACOPBYTE(s0,s1);
      for(ii=1;ii<ij0;++ii){
	    s2=(unsigned char far *)RAMScreenGlb+ii;
	    s1=(unsigned char far *)HardwareGraf+ii;
	    EGACOPBYTE(s2,s0); EGACOPBYTE(s1,s2); EGACOPBYTE(s0,s1);
      }
      SelectScreen(2); for(i=0;i<8;++i) DPC(i,0,b[i]);
      SelectScreen(is);
      COPDIS;
    }else{
      for(i=0;i<=ScreenSizeGlb;++i){
	 g=HardwareGraf[i];
	 HardwareGraf[i]=RAMScreenGlb[i];
	 RAMScreenGlb[i]=g;
      }
    }
  }
}	/* SwapScreen() */

void SaveScreen(FileName)
unsigned char	FileName[];
{
  FILE	*pf;
  int	i,j,k;
  if((pf=fopen(FileName,"wb"))!=NULL){
    if(Ega){
      for(j=0;j<YMaxGlb;++j){
	 for(i=0;i<XScreenMaxGlb;i+=2){
	    k=(PD(i,j)<<4)|PD(i+1,j); putc(k,pf);
	 }
      }
    }else{
      for(i=0;i<=ScreenSizeGlb;++i){
	 putw(((int far *)ScreenGlb)[i],pf);
      }
    }
    fclose(pf);
  }else{
    puts("Can't open save file");
  }
}	/* SaveScreen() */

void LoadScreen(FileName)
unsigned char	FileName[];
{
  FILE	*pf;
  int	i,j,k;
  if((pf=fopen(FileName,"rb"))!=NULL){
    if(Ega){
      for(j=0;j<YMaxGlb;++j){
	 for(i=0;i<XScreenMaxGlb;i+=2){
	    k=getc(pf); DPC(i,j,k>>4); DPC(i+1,j,k&0xf);
	 }
      }
    }else{
      for(i=0;i<=ScreenSizeGlb;++i){
	 ((int far *)ScreenGlb)[i]=getw(pf);
      }
    }
    fclose(pf);
  }
}	/* LoadScreen() */

SelectScreen(i)
int 	i;
{
  if(i==1){
    ScreenGlb=(unsigned char far *)HardwareGraf; NScreenGlb=1;
  }else{
	ScreenGlb=(unsigned char far *)RAMScreenGlb; NScreenGlb=2;
  }
}	/* SelectScreen() */

int GetScreen()
{
  return(NScreenGlb);
}	/* GetScreen() */

void Box(x1,y1,x2,y2)
int	x1,y1,x2,y2;
{
  int	i;
  if(x1>x2){ i=x1; x1=x2; x2=i; }
  if(y1>y2){ i=y1; y1=y2; y2=i; }
  Line(x1+1,y1,x2,y1);
  Line(x2,y1+1,x2,y2);
  Line(x1,y2,x2-1,y2);
  Line(x1,y2-1,x1,y1);
}	/* Box() */

void Bar(x1,y1,x2,y2)
int	x1,y1,x2,y2;
{
  int	i,j,jj;
  unsigned	total;  int		b;
  unsigned char	far	*base;
  if(Ega) ENA;
  if(x1>x2){ i=x1; x1=x2; x2=i; }
  if(y1>y2){ i=y1; y1=y2; y2=i; }
  if(ClippingGlb){
	if(x1<X1RefGlb) x1=X1RefGlb;
	if(x2>X2RefGlb) x2=X2RefGlb;
	if(y1<Y1RefGlb) y1=Y1RefGlb;
	if(y2>Y2RefGlb) y2=Y2RefGlb;
  }
  for(j=y1;j<=y2;++j){
     long b;
     b=((long)ScreenGlb+YAddr[j]);
     if(Ega){
       for(i=x1;i<=x2;++i){
	  /*DPQ(i,j);*/
	  base=(unsigned char far *)(b+XAddr[i]);
	  OUI(8,Point[i]);exist_color=*base; *base&=TRUE;
       }
     }else{
       for(i=x1;i<=x2;++i){
	  DPQ(i,j);
       }
     }
  }
  if(Ega) DIS;
}	/* Bar() */

void Cross(x,y,scale)
int	x,y,scale;
{
  Line(x-scale,y,x+scale,y);
  Line(x,y-scale,x,y+scale);
}	/* Cross() */

void Star(x,y,scale)
int	x,y,scale;
{
  Cross(x,y,scale);
  scale*=0.7; scale+=0.5;
  Line(x-scale,y-scale,x+scale,y+scale);
  Line(x-scale,y+scale,x+scale,y-scale);
}	/* Star() */

void CrossDiag(x,y,scale)
int	x,y,scale;
{
  Line(x-scale,y+scale,x+scale,y-scale);
  Line(x-scale,y-scale,x+scale,y+scale);
}	/* CrossDiag() */

void Wye(x,y,scale)
int x,y,scale;
{
  Line(x-scale,y-scale,x,y);
  Line(x+scale,y-scale,x,y);
  Line(x,y,x,y+scale);
}	/* Wye() */

void Diamond(x,y,scale)
int x,y,scale;
{
  Line(x-scale,y,x,y-scale);
  Line(x,y-scale,x+scale,y);
  Line(x+scale,y,x,y+scale);
  Line(x,y+scale,x-scale,y);
}	/* Diamond() */

void Circle(xr,yr,r)
int	xr,yr,r;
{
 static int x[15]={0,0,121,239,355,465,568,663,749,823,885,935,971,993,1000};
 int	xk1,yk1,xk2,yk2,xp1,yp1,xp2,yp2;
 double	xfact,yfact;
 double	GetAspect();
 int	i;
 xfact=fabs(r*0.001);
 yfact=xfact*GetAspect();
 if(xfact>0){
   xk1=x[1]*xfact+0.5;
   yk1=x[14]*yfact+0.5;
   for(i=2;i<=14;++i){
      xk2=x[i]*xfact+0.5;
      yk2=x[15-i]*yfact+0.5;
      xp1=xr-xk1; yp1=yr+yk1;
      xp2=xr-xk2; yp2=yr+yk2;
      Line(xp1,yp1,xp2,yp2);
      xp1=xr+xk1; xp2=xr+xk2;
      Line(xp1,yp1,xp2,yp2);
      yp1=yr-yk1; yp2=yr-yk2;
      Line(xp1,yp1+1,xp2,yp2+1);
      xp1=xr-xk1; xp2=xr-xk2;
      Line(xp1,yp1+1,xp2,yp2+1);
      xk1=xk2; yk1=yk2;
   }
 }else{
   DP(xr,yr);
 }
}	/* Circle() */

static rbx1=0,rby1=0,rbx2=0,rby2=0,
       rlx1=0,rly1=0,rlx2=0,rly2=0,
       rcx1=0,rcy1=0,rcs=0;

void RBox(x1,y1,x2,y2)
int	x1,y1,x2,y2;
{
  int	XORLoc=GetXORMode();
  if(Ega) SetXORMode(XORMODE);
  else SetXORMode(1);
  if(rbx1|rby1|rbx2|rby2) Box(rbx1,rby1,rbx2,rby2);
  Box(x1,y1,x2,y2);
  rbx1=x1; rbx2=x2; rby1=y1; rby2=y2;
  SetXORMode(XORLoc);
}	/* RBox() */

void DelBox()
{
  int	XORLoc=GetXORMode();
  if(Ega) SetXORMode(XORMODE);
  else SetXORMode(1);
  if(rbx1|rby1|rbx2|rby2) Box(rbx1,rby1,rbx2,rby2);
  SetXORMode(XORLoc);
  rbx1=rby1=rbx2=rby2=0;
}	/* DelBox() */

void RLine(x1,y1,x2,y2)
int	x1,y1,x2,y2;
{
  int	XORLoc=GetXORMode();
  if(Ega) SetXORMode(XORMODE);
  else SetXORMode(1);
  if(rlx1|rly1|rlx2|rly2) Line(rlx1,rly1,rlx2,rly2);
  Line(x1,y1,x2,y2);
  SetXORMode(XORLoc);
  rlx1=x1; rly1=y1; rlx2=x2; rly2=y2;
}	/* Rline() */

void DelLine()
{
  int	XORLoc=GetXORMode();
  if(Ega) SetXORMode(XORMODE);
  else SetXORMode(1);
  if(rlx1|rly1|rlx2|rly2) Line(rlx1,rly1,rlx2,rly2);
  SetXORMode(XORLoc);
  rlx1=rly1=rlx2=rly2=0;
}	/* DelLine() */

void RCross(x1,y1,s)
int x1,y1,s;
{
  int	XORLoc=GetXORMode();
  if(Ega) SetXORMode(XORMODE);
  else SetXORMode(1);
  if(rcx1|rcy1) Cross(rcx1,rcy1,rcs);
  Cross(x1,y1,s);
  rcx1=x1; rcy1=y1; rcs=s;
  SetXORMode(XORLoc);
}	/* RCross() */

void DelCross()
{
  int	XORLoc=GetXORMode();
  if(Ega) SetXORMode(XORMODE);
  else SetXORMode(1);
  if(rcx1|rcy1) Cross(rcx1,rcy1,rcs);
  rcx1=rcy1=rcs=0;
  SetXORMode(XORLoc);
}	/* DelCross() */

DefWorld(i,x1,y1,x2,y2)
int	i;
double	x1,y1,x2,y2;
{
  if(x1!=x2 && y1!=y2 && i>=0 && i<WorldsMaxGlb){
    World[i].x1=x1; World[i].y1=y2;
    World[i].x2=x2; World[i].y2=y1;
    if(i>WorldMaxGlb) WorldMaxGlb=i;
  }else{
    puts("Illegal World definition\n");
  }
}	/* DefWorld() */

SelectWorld(i)
int	i;
{
  if(i>=0 && i<=WorldMaxGlb){
    X1WldGlb=World[i].x1; Y1WldGlb=World[i].y1;
    X2WldGlb=World[i].x2; Y2WldGlb=World[i].y2;
    SelectWindow(WindowNdxGlb);
  }else{
    puts("Illegal world number\n");
  }
}	/* SelectWorld() */

double GetWX1()
{ return(X1WldGlb); }

double GetWX2()
{ return(X2WldGlb); }

double GetWY1()
{ return(Y1WldGlb); }

double GetWY2()
{ return(Y2WldGlb); }

void RedefWindow(i,x1,y1,x2,y2)
int	i,x1,y1,x2,y2;
{
  int	l;
  if(i>=0 && i<WindowsMaxGlb && x1<=x2 && y1<=y2 &&
    x1>=0 && x2<=XScreenMaxGlb && y1>=0 && y2<=YMaxGlb){
    if(XScreenMaxGlb==639) l=3; else l=2;
    x1=XAddr[x1]<<l; x2=((XAddr[x2]+1)<<l)-1;
    Window[i].ix1=x1; Window[i].iy1=y1;
    Window[i].ix2=x2; Window[i].iy2=y2;
    if(i>WindowMaxGlb)WindowMaxGlb=i;
  }else{
    puts("Illegal window definition\n");
  }
}	/* RedefWindow() */

DefWindow(i,x1,y1,x2,y2)
int	i,x1,y1,x2,y2;
{
  RedefWindow(i,x1,y1,x2,y2);
}	/* DefWindow() */

SelectWindow(i)
int	i;
{
  if(i>=0 && i<=WindowMaxGlb){
    WindowNdxGlb=i;
    X1RefGlb=Window[i].ix1; Y1RefGlb=Window[i].iy1;
    X2RefGlb=Window[i].ix2; Y2RefGlb=Window[i].iy2;
    BxGlb=(X2RefGlb-X1RefGlb)/(X2WldGlb-X1WldGlb);
    ByGlb=(Y2RefGlb-Y1RefGlb)/(Y2WldGlb-Y1WldGlb);
    AxGlb=X1RefGlb-X1WldGlb*BxGlb;
    AyGlb=Y1RefGlb-Y1WldGlb*ByGlb;
    SetClipping(1);
  }else{
    puts("Illegal window number\n");
  }
}	/* SelectWindow() */

int GetX1()
{ return(X1RefGlb); }

int GetX2()
{ return(X2RefGlb); }

int GetY1()
{ return(Y1RefGlb); }

int GetY2()
{ return(Y2RefGlb); }

int GetWindow()
{
  return(WindowNdxGlb);
}	/* GetWindow() */

int WindowX(x)
double	x;
{
  return(AxGlb+BxGlb*x);
}	/* WindowX() */

int WindowY(y)
double	y;
{
  return(AyGlb+ByGlb*y);
}	/* WindowY() */

double WorldX(x)
int	x;
{
  return((x-AxGlb)/BxGlb);
}	/* WorldX() */

double WorldY(y)
int	y;
{
  return((y-AyGlb)/ByGlb);
}	/* WorldY() */

void ResetWindows()
{
  int	i;
  for(i=0;i<WindowMaxGlb;++i){
     DefWindow(i,0,0,XScreenMaxGlb,YMaxGlb);
  }
  SelectWindow(0);
}	/* ResetWindows() */

void ResetWorlds()
{
  int	i;
  for(i=0;i<WorldMaxGlb;++i){
     DefWorld(i,0.,0.,(double)XScreenMaxGlb,(double)YMaxGlb);
  }
  SelectWorld(0);
  SelectWindow(GetWindow());
}	/* ResetWorlds() */

void DrawPoint(x,y)
double	x,y;
{
  DP(WindowX(x),WindowY(y));
}	/* DrawPoint() */

void DrawLine(x1,y1,x2,y2)
double	x1,y1,x2,y2;
{
  Line(WindowX(x1),WindowY(y1),WindowX(x2),WindowY(y2));
}	/* DrawLine() */

void DrawCircle(x,y,r)
double	x,y,r;
{
  Circle(WindowX(x),WindowY(y),abs(WindowY(r)-WindowY(0.)));
}	/* DrawCircle() */

void DrawCross(x,y,scale)
double	x,y;
int	scale;
{
  Cross(WindowX(x),WindowY(y),scale);
}	/* DrawCross() */

void DrawStar(x,y,scale)
double	x,y;
int	scale;
{
  Star(WindowX(x),WindowY(y),scale);
}	/* DrawStar() */

void DrawWye(x,y,scale)
double	x,y;
int	scale;
{
  Wye(WindowX(x),WindowY(y),scale);
}	/* DrawWye() */

void DrawDiamond(x,y,scale)
double	x,y;
int	scale;
{
  Diamond(WindowX(x),WindowY(y),scale);
}	/* DrawDiamond() */

void DrawBox(x1,y1,x2,y2)
double	x1,y1,x2,y2;
{
  Box(WindowX(x1),WindowY(y1),WindowX(x2),WindowY(y2));
}	/* DrawBox() */

void DrawBar(x1,y1,x2,y2)
double	x1,y1,x2,y2;
{
  Bar(WindowX(x1),WindowY(y1),WindowX(x2),WindowY(y2));
}	/* DrawBar() */

void InvertWindow()
{
  int	i,j,iy,i1,in;
  if(!Ega){
    i1=XAddr[X1RefGlb];in=XAddr[X2RefGlb];
    for(j=Y1RefGlb;j<=Y2RefGlb;++j){
       iy=YAddr[j];
       for(i=i1;i<=in;++i){
          ScreenGlb[i+iy]=~ScreenGlb[i+iy];
       }
    }
  }else{
    int a,c;
    a=XORModeGlb; XORModeGlb=0x18;
    c=ColorGlb; ColorGlb=255&MaxClr;
    for(i=X1RefGlb;i<=X2RefGlb;++i)
    for(j=Y1RefGlb;j<=Y2RefGlb;++j){
       /*IP(i,j);*/
	  if(Ega) ENA; DPQ(i,j); if(Ega) DIS;
    }
    ColorGlb=c; XORModeGlb=a;
  }
}	/* InvertWindow() */

void ClrWindow()
{
  int	i,j,iy,i1,in;
  i1=XAddr[X1RefGlb];in=XAddr[X2RefGlb];
  for(j=Y1RefGlb;j<=Y2RefGlb;++j){
     iy=YAddr[j];
     for(i=i1;i<=in;++i){
          ScreenGlb[i+iy]=0;
     }
  }
}	/* ClrWindow() */

void CopyWindow(from,to,x,y)
int	from,to;
int	x,y;
{
  int	i,j,jt,jf,xlen,ylen;
  unsigned char far	*fromscreen,*f;
  unsigned char far	*toscreen,*t;
  xlen=X2RefGlb-X1RefGlb; ylen=Y2RefGlb-Y1RefGlb;
  if(x<0 || y<0 | x+xlen>XScreenMaxGlb || y+ylen>YMaxGlb){
    puts("Ambiguous copy parameter\n"); return;
  }
  if(from==2) fromscreen=(unsigned char far *)RAMScreenGlb;
  else	fromscreen=(unsigned char far *)HardwareGraf;
  if(to  ==2) toscreen=(unsigned char far *)RAMScreenGlb;
  else	toscreen=(unsigned char far *)HardwareGraf;
  xlen=XAddr[X2RefGlb]-XAddr[X1RefGlb];
  if(!Ega){
    for(j=0;j<=ylen;++j){
       jt=YAddr[y+j]; jf=YAddr[Y1RefGlb+j];
       t=toscreen+jt+XAddr[x]; f=fromscreen+jf+XAddr[X1RefGlb];
       for(i=0;i<=xlen;++i) t[i]=f[i];
    }
  }else{
    COPENA;
    for(j=0;j<=ylen;++j){
       jt=YAddr[y+j]; jf=YAddr[Y1RefGlb+j];
       t=toscreen+jt+XAddr[x]; f=fromscreen+jf+XAddr[X1RefGlb];
       for(i=0;i<=xlen;++i)  EGACOPBYTE((f+i),(t+i));
    }
    COPDIS;
  }
}	/* CopyWindow() */

static DPD(x,y,clr)
int	x,y,clr;
{
  unsigned	total; int	b;
  total=XAddr[x]+YAddr[y];
  b=((unsigned char far *)HardwareGraf)[total]&Point[x];
  ((unsigned char far *)HardwareGraf)[total]= (b|(clr<<Shift[x]));
}	/* DPD() */

WindowCopy(Mode)	int	Mode;
{ int	ix,iy,i,x1,x2,xlen,jt,is,y2;
  double	l;
  unsigned	rand();
  unsigned char far	*fromscreen;
  unsigned char far	*toscreen;
  if(Ega) return;
  fromscreen=(unsigned char far *)RAMScreenGlb;
  toscreen=(unsigned char far *)HardwareGraf;
  if(Mode==1){
  xlen=XAddr[X2RefGlb]-XAddr[X1RefGlb];
  x1=XAddr[X1RefGlb];x2=XAddr[X2RefGlb];
  for(ix=0;ix<=xlen;++ix){
  for(iy=Y1RefGlb;iy<=Y2RefGlb;++iy){
     jt=YAddr[iy];
	 if(iy&4){
       for(i=0;i<=ix;++i) toscreen[x2-ix+i+jt]=fromscreen[x1+i+jt];
	 }else{
       for(i=0;i<=ix;++i) toscreen[x1+ix-i+jt]=fromscreen[x2-i+jt];
	 }
  }
  }
  }else if(Mode==2){
	is=GetScreen();SelectScreen(2);
	xlen=X2RefGlb-X1RefGlb+1; jt=Y2RefGlb-Y1RefGlb+1;
    for(i=0;i<xlen*jt*1.5;++i){
	   l=rand()/32767.;ix=l*xlen+X1RefGlb;
	   l=rand()/32767.;iy=l*jt+Y1RefGlb;
	   x1=PD(ix,iy); DPD(ix,iy,x1);
	}
	CopyWindow(2,1,X1RefGlb,Y1RefGlb);
	SelectScreen(is);
  }else{
	xlen=XAddr[X2RefGlb]-XAddr[X1RefGlb];
    x1=XAddr[X1RefGlb];x2=XAddr[X2RefGlb];
    for(iy=Y1RefGlb;iy<=Y2RefGlb;++iy){
	for(is=0;is<=iy-Y1RefGlb;++is){
       jt=YAddr[Y1RefGlb+is]; y2=YAddr[Y2RefGlb+Y1RefGlb-iy+is];
       for(i=0;i<=xlen;++i) toscreen[x1+i+y2]=fromscreen[x1+i+jt];
    }
    }
  }
}	/* WindowCopy() */

void MoveHor(delta,fill)
int	delta;		/* delta<0 - left */
int	fill;
{
  int	i,i1,in,ih,j,y,xd=abs(delta),ij;
  unsigned char far *	fromscreen;
  if(XScreenMaxGlb==639) xd&=~7; else xd&=~3;
  if(delta<0) delta= -xd; else delta=xd;
  if(!delta) return;
  xd=XAddr[abs(delta)]; if(delta<0) xd= -xd;
  if(X1RefGlb+delta<0 || X2RefGlb+delta>XScreenMaxGlb){
    puts("Illegal horizontal step\n"); return;
  }
  if(RAMScreenGlb==NULL) fill=0;
  if(delta<0){	/* left */
    i1=XAddr[X1RefGlb]; in=XAddr[X2RefGlb]+1; ih=1;
  }else{	/* rigth */
    i1=XAddr[X2RefGlb]; in=XAddr[X1RefGlb]-1; ih=-1;
  }
  if(Ega){
    COPENA;
    for(i=i1;i!=in;i+=ih){
       for(j=Y1RefGlb;j<=Y2RefGlb;++j){
	  y=YAddr[j]+i;
	  EGACOPBYTE((ScreenGlb+y),(ScreenGlb+y+xd));
       }
    }
    COPDIS;
  }else{
    for(i=i1;i!=in;i+=ih){
       for(j=Y1RefGlb;j<=Y2RefGlb;++j){
	  y=YAddr[j];
	  ScreenGlb[i+y+xd]=ScreenGlb[i+y];
       }
    }
  }
  if(fill){
    if(ScreenGlb==(unsigned char far *)HardwareGraf) fromscreen=
                                            (unsigned char far *)RAMScreenGlb;
    else fromscreen=(unsigned char far *)HardwareGraf;
  }
  in-=ih;
  for(i=in;i!=in+xd;i-=ih){
     if(fill){
       if(Ega){ COPENA;
	 for(j=Y1RefGlb;j<=Y2RefGlb;++j){
	    ij=i+YAddr[j];EGACOPBYTE((fromscreen+ij),(ScreenGlb+ij));
	 }      COPDIS;
       }else{
         for(j=Y1RefGlb;j<=Y2RefGlb;++j){
	    ij=i+YAddr[j];ScreenGlb[ij]=fromscreen[ij];
	 }
       }
     }else{
       if(Ega){
	 for(j=0;j<8;++j) DPC(in*8+j,Y1RefGlb,0);
	 COPENA;
	 for(j=Y1RefGlb+1;j<=Y2RefGlb;++j)
	    EGACOPBYTE((ScreenGlb+i+YAddr[Y1RefGlb]),(ScreenGlb+i+YAddr[j]));
	 COPDIS;
       }else{
	 for(j=Y1RefGlb;j<=Y2RefGlb;++j) ScreenGlb[i+YAddr[j]]=0;
       }
     }
  }
  RedefWindow(WindowNdxGlb,X1RefGlb+delta,Y1RefGlb,
                           X2RefGlb+delta,Y2RefGlb);
  SelectWindow(WindowNdxGlb);
}	/* MoveHor() */

void MoveVer(delta,fill)
int	delta;		/* delta>0 - up */
int	fill;
{
  int	j,j1,jn,jh,i,i1,in,a,from,to;
  unsigned char far *	fromscreen;
  if(!delta)return;
  if(RAMScreenGlb==NULL) fill=0;
  if(Y2RefGlb-delta>YMaxGlb || Y1RefGlb-delta<0){
    puts("Illegal vertical step\n"); return;
  }
  if(delta<0){	/* down */
    j1=Y2RefGlb; jn=Y1RefGlb-1; jh= -1;
  }else{	/* up */
    j1=Y1RefGlb; jn=Y2RefGlb+1; jh=1;
  }
  i1=XAddr[X1RefGlb]; in=XAddr[X2RefGlb];
  if(Ega){
    COPENA;
    for(j=j1;j!=jn;j+=jh){
       from=YAddr[j]; to=YAddr[j-delta];
       for(i=i1;i<=in;++i)EGACOPBYTE((ScreenGlb+from+i),(ScreenGlb+to+i));
    } COPDIS;
  }else{
    for(j=j1;j!=jn;j+=jh){
       from=YAddr[j]; to=YAddr[j-delta];
       for(i=i1;i<=in;++i)ScreenGlb[to+i]=ScreenGlb[from+i];
    }
  }
  jn-=jh;
  if(fill){
    if(ScreenGlb==(unsigned char far *)HardwareGraf)
      fromscreen=(unsigned char far *)RAMScreenGlb;
    else fromscreen=(unsigned char far *)HardwareGraf;
  }
  for(j=jn;j!=jn-delta;j-=jh){
     a=YAddr[j];
     if(fill){
       if(Ega){
	 COPENA;
	 for(i=i1;i<=in;++i)EGACOPBYTE((fromscreen+a+i),(ScreenGlb+a+i));
	 COPDIS;
       }else{
	 for(i=i1;i<=in;++i)ScreenGlb[a+i]=fromscreen[a+i];
       }
     }else{
       if(Ega){
	 for(i=0;i<8;++i) DPC(i1*8+i,j,0);
	 COPENA;
	 for(i=i1+1;i<=in;++i)EGACOPBYTE((ScreenGlb+a+i1),(ScreenGlb+a+i));
	 COPDIS;
       }else{
	 for(i=i1;i<=in;++i)ScreenGlb[a+i]=0;
       }
     }
  }
  RedefWindow(WindowNdxGlb,X1RefGlb,Y1RefGlb-delta,X2RefGlb,Y2RefGlb-delta);
  SelectWindow(WindowNdxGlb);
}	/* MoveVer() */

int WindowSize(i)
int	i;
{
  return((Window[i].iy2-Window[i].iy1+1)*
  (XAddr[Window[i].ix2]-XAddr[Window[i].ix1]+1));
}	/* WindowSize() */

void SaveWindow(n,FileName)
int	n;
unsigned char	FileName[];
{
  FILE	*pf;
  int	j,i,y,x1,x2,y1,y2,k;
  if((pf=fopen(FileName,"wb"))!=NULL){
    x1=Window[n].ix1; x2=Window[n].ix2;
    y1=Window[n].iy1; y2=Window[n].iy2;
    putw(x1,pf);putw(x2,pf);putw(y1,pf);putw(y2,pf);
    for(j=y1;j<=y2;++j){
       if(Ega){
	 for(i=x1;i<x2;i+=2){
	    k=(PD(i,j)<<4)|PD(i+1,j); putc(k,pf);
	 }
       }else{
	 y=YAddr[j];
	 for(i=XAddr[x1];i<=XAddr[x2];++i) putc(ScreenGlb[i+y],pf);
       }
    }
    fclose(pf);
  }else{
    puts("Can't open save file\n");
  }
}	/* SaveWindow() */

void LoadWindow(n,FileName)
int	n;
unsigned char	FileName[];
{
  FILE	*pf;
  int	j,i,y,x1,x2,y1,y2,iloc=GetWindow(),k;
  if((pf=fopen(FileName,"rb"))!=NULL){
    x1=getw(pf);x2=getw(pf);y1=getw(pf);y2=getw(pf);
    RedefWindow(n,x1,y1,x2,y2);
    SelectWindow(n);
    for(j=y1;j<=y2;++j){
       if(Ega){
	 for(i=X1RefGlb;i<X2RefGlb;i+=2){
	  k=getc(pf); DPC(i,j,k>>4); DPC(i+1,j,k&0xf);
	 }
       }else{
	 y=YAddr[j];
	 for(i=XAddr[X1RefGlb];i<=XAddr[X2RefGlb];++i) ScreenGlb[i+y]=getc(pf);
       }
    }
    fclose(pf);
  }else{
    puts("Can't open load file\n");
  }
  SelectWindow(iloc);
}	/* LoadWindow() */

void WindowBorder()
{
  Box(X1RefGlb,Y1RefGlb,X2RefGlb,Y2RefGlb);
}	/* WindowBorder() */

void FillWindow()
{
  int	i,j;
  if(GetHatchStyle()<0){
    for(i=X1RefGlb;i<=X2RefGlb;++i)
    for(j=Y1RefGlb;j<=Y2RefGlb;++j) DPC(i,j,HatchArray[i&7][j&7]);
  }else{
    for(i=X1RefGlb;i<=X2RefGlb;++i)
    for(j=Y1RefGlb;j<=Y2RefGlb;++j)
       if(HatchArray[i&7][j&7]) DP(i,j); else DPC(i,j,0);
  }
}	/* FillWindow() */

void DefHatchStyle(b)
unsigned char	b[8][8];
{
  int	i,j;
  for(i=0;i<=7;++i){
  for(j=0;j<=7;++j)
     HatchArray[i][j]=b[i][j];
  }
  HatchGlb=-1;
}	/* DefHatchStyle() */

SetHatchStyle(style)
int	style;
{
  int	i,j;
  static unsigned char	h[8][4]={
         {0x00,0x00,0x00,0x00},{0xFF,0xFF,0xFF,0xFF},
         {0x11,0x22,0x44,0x88},{0x88,0x44,0x22,0x11},
         {0x99,0x33,0x66,0xCC},{0x99,0xCC,0x66,0x33},
         {0x55,0x22,0x55,0x88},{0x55,0xAA,0x55,0xAA}};
  if(style<0 ||style>7){
    puts("Ambiguous hatch style");
    style=0;
  }
  HatchGlb=style;
  for(i=0;i<=7;++i){
  for(j=0;j<=7;++j)
     if((h[style][j&3]>>(7-i))&1) HatchArray[i][j]=255;
     else HatchArray[i][j]=0;
  }
}	/* SetHatchStyle() */

int GetHatchStyle()
{
  return(HatchGlb);
}	/* GetHatchStyle() */

void Fill(x0,y0)
int	x0,y0;
{
  int	h,x,y,x1,x2,i,g;
  g=GetHatchStyle();
  h=1; x=x0; y=y0;
l:x1=x2=x;
  while(!PD(x1-1,y))--x1;
  while(!PD(x2+1,y))++x2;
  for(i=x1;i<=x2;++i){
     if(g<0) DPC(i,y,HatchArray[i&7][y&7]);
     else if(HatchArray[i&7][y&7]) DP(i,y); else DPC(i,y,0);
  }
  for(i=x1;i<=x2;++i){
     if(!PD(i,y+h)){
       x=i; y+=h; goto l;
     }
  }
  if(h>0){
    h=-1; x=x0; y=y0; goto l;
  }
}	/* Fill() */

void FillBox(x1,y1,x2,y2)
{
  int	i,j;
  if(x1>x2){ i=x1; x1=x2; x2=i; }
  if(y1>y2){ i=y1; y1=y2; y2=i; }
  if(x1<X1RefGlb) x1=X1RefGlb;
  if(x2>X2RefGlb) x2=X2RefGlb;
  if(y1<Y1RefGlb) y1=Y1RefGlb;
  if(y2>Y2RefGlb) y2=Y2RefGlb;
  if(GetHatchStyle<0){
    for(i=x1;i<=x2;++i)
    for(j=y1;j<=y2;++j) DPC(i,j,HatchArray[i&7][j&7]);
  }else{
    for(i=x1;i<=x2;++i)
    for(j=y1;j<=y2;++j)
       if(HatchArray[i&7][j&7]) DP(i,j); else DPC(i,j,0);
  }
}	/* FillBox() */

void SetText(H,W,scale)
int	H,W,scale;
{
  CharSHGlb=H; CharSWGlb=W; CharScaleGlb=scale;
}	/* SetText() */

void LoadFont(FileName)
unsigned char	FileName[];
{
  FILE	*pf;
  unsigned char	a[11];
  int	charbyte,ch,x,y;

  for(x=0;x<=255;++x)
  for(y=0;y<=7;++y) CharSet[x][y]=0;
  if((pf=fopen(FileName,"r"))==NULL){
    puts("Can't open font file");
    return;
  }
  fscanf(pf,"%d %d\n",&CharWGlb,&CharHGlb);
  if(CharWGlb<=0||CharWGlb>8||CharHGlb<=0||CharHGlb>8){
    puts("Ambiguous font parameter");
    return;
  }
  while(!feof(pf)){
    fgets(a,10,pf);
    if(a[0]=='\\') ch=atoi(a+1);
    else ch=a[0];
/*    fscanf(pf,"%c\n",&ch); ch&=0xFF;*/
    for(y=0;y<CharHGlb;++y){
       charbyte=0;
       fgets(a,10,pf);a[9]='\0';
       for(x=0;x<CharWGlb;++x)
          charbyte|=(((a[x]=='*')?1:0)<<(7-x));
       CharSet[ch][y+8-CharHGlb]=charbyte;
    }
  }
  fclose(pf);
  SetText(CharHGlb+2,CharWGlb+2,1);
}	/* LoadFont() */

void DrawAscii(x,y,size,ch)
int	x,y,size,ch;
{
  int	xpos,ypos,xx,yy,x1,x2,y1,y2,charbyte;
  for(ypos=0;ypos<CharHGlb;++ypos){
     charbyte=CharSet[ch][7-ypos]&0xFF;
     for(xpos=0;xpos<CharWGlb;++xpos){
        if((charbyte>>(7-xpos))&1){
          x1=x+xpos*size;
          x2=x1+size-1;
          y1=y-ypos*size;
          y2=y1-size+1;
          for(yy=y1;yy>=y2;--yy)
          for(xx=x1;xx<=x2;++xx)DP(xx,yy);
        }
     }
  }
}	/* DrawAscii() */


void DrawText(x,y,txt)
int	x,y;
unsigned char	txt[];
{
  int	i,ch;
  for(i=0;i<strlen(txt);++i){
     ch=txt[i]&0xFF;
     DrawAscii(x,y,CharScaleGlb,ch);
     x+=CharSWGlb;
     if(x+CharWGlb>XScreenMaxGlb){
       x=0;
       y+=CharSHGlb;if(y>YMaxGlb)y=CharSHGlb;
     }
  }
}	/* DrawText() */

#define	PI	3.141529

typedef double	(*PlotArray)[2];

void RotatePAbout(a,NPoints,Theta,x0,y0)
PlotArray	a;
int	NPoints;
double	Theta,x0,y0;
{
  int	i;
  double	c,s,x,ph;
  if(NPoints>=2){
    ph=PI/180.*Theta;
    c=cos(ph); s=sin(ph);
    for(i=1;i<=NPoints;++i){
    	x=x0+c*(a[i][0]-x0)-s*(a[i][1]-y0);
        a[i][1]=y0+s*(a[i][0]-x0)+c*(a[i][1]-y0);
        a[i][0]=x;
    }
  }else{
    puts("Ambiguous points number");
  }
}	/* RotatePAbout() */

void RotatePolygon(a,NPoints,Theta)
PlotArray	a;
int	NPoints;
double	Theta;
{
  double	x=0.,y=0.;
  int	i;
  for(i=1;i<NPoints;++i){
     x+=a[i][0]; y+=a[i][1];
  }
  RotatePAbout(a,NPoints,Theta,x/NPoints,y/NPoints);
}	/* RotatePolygon() */

void MovePolygon(a,N,DeltaX,DeltaY)
PlotArray	a;
int	N;
double	DeltaX,DeltaY;
{
  int	i;
  if(N>=2){
    for(i=1;i<=N;++i){
       a[i][0]+=DeltaX; a[i][1]+=DeltaY;
    }
  }else{
    puts("Ambiguous points number");
  }
}	/* MovePolygon() */

void ScalePolygon(a,N,ScaleX,ScaleY)
PlotArray	a;
int	N;
double	ScaleX,ScaleY;
{
  int	i;
  for(i=1;i<=N;++i){
     a[i][0]*=ScaleX; a[i][1]*=ScaleY;
  }
}	/* ScalePolygon() */

void ScaleCPolygon(a,N,ScaleX,ScaleY)
PlotArray	a;
int	N;
double	ScaleX,ScaleY;
{
  int	i;
  double	x,y;
  x=y=0.;
  for(i=1;i<=N;++i){
     x+=a[i][0]; y+=a[i][1];
  }
  x/=N; y/=N;
  for(i=1;i<=N;++i){
     a[i][0]=(a[i][0]-x)*ScaleX+x;
     a[i][1]=(a[i][1]-y)*ScaleY+y;
  }
}	/* ScaleCPolygon() */

void DrawItem(x,y,item,scale)
int	x,y,item,scale;
{
  int	lineloc=GetLineStyle();
  SetLineStyle(0);
  switch(item){
    case 2: CrossDiag(x,y,scale);break;
    case 3: Bar(x-scale,y-scale,x+scale,y+scale);break;
    case 4: Box(x-scale,y-scale,x+scale,y+scale);break;
    case 5: Diamond(x,y,scale);break;
    case 6: Wye(x,y,scale);break;
    case 7: Star(x,y,scale);break;
    case 8: Circle(x,y,scale);break;
    case 0: DP(x,y); break;
  }
  SetLineStyle(lineloc);
}	/* DrawItem() */

void DrawPolygon(a,I0,NPoints,Lin,Scale,Lines)
PlotArray	a;
int	I0,NPoints;
int	Lin,Scale,Lines;
{
  int	x1,y1,x2,y2,i,PlotLine;
  int	cliploc=GetClipping();
  SetClipping((NPoints>0)?1:0);
  NPoints=abs(NPoints);
  PlotLine=((Lin>=0)?1:0);
  Lin=abs(Lin); if(Lin==9)PlotLine=0;
  Scale=abs(Scale);
  x1=WindowX(a[I0][0]);
  y1=WindowY(a[I0][1]);
  DrawItem(x1,y1,Lin,Scale);
  if(Lines) Line(x1,Y2RefGlb,x1,y1);
  for(i=I0+1;i<=NPoints;++i){
     x2=WindowX(a[i][0]);
     y2=WindowY(a[i][1]);
     DrawItem(x2,y2,Lin,Scale);
     if(Lines) Line(x2,Y2RefGlb,x2,y2);
     if(PlotLine) Line(x1,y1,x2,y2);
     x1=x2; y1=y2;
  }
  SetClipping(cliploc);
}	/* DrawPolygon() */

void FindWorld(i,a,N,ScaleX,ScaleY)
int	i;
PlotArray	a;
int	N;
double	ScaleX,ScaleY;
{
  double	xmax,xmin,ymax,ymin,x,y;
  int	j;
  N=abs(N); ScaleX=fabs(ScaleX); ScaleY=fabs(ScaleY);
  xmax=xmin=a[1][0]; ymax=ymin=a[1][1];
  for(j=2;j<=N;++j){
    if(a[j][0]>xmax) xmax=a[j][0];
    else if(a[j][0]<xmin) xmin=a[j][0];
    if(a[j][1]>ymax) ymax=a[j][1];
    else if(a[j][1]<ymin) ymin=a[j][1];
  }
  x=(xmax+xmin)/2; y=(ymax+ymin)/2;
  xmax=x+(xmax-x)*ScaleX; xmin=x-(x-xmin)*ScaleX;
  ymax=y+(ymax-y)*ScaleY; ymin=y-(y-ymin)*ScaleY;
  DefWorld(i,xmin,ymin,xmax,ymax);
  SelectWorld(i);
}	/* FindWorld() */

void Axis0(XDense,YDense,XAxis,YAxis,Arrows)
{
  int	xk0,yk0,xk1,yk1,xk2,yk2;
  int	cliploc=GetClipping(),lineloc=GetLineStyle();
  SetClipping(0); SetLineStyle(0);
  xk0=X1RefGlb+32; yk0=Y2RefGlb-14;
  xk1=xk0; yk1=Y1RefGlb+6;
  xk2=X2RefGlb-8; yk2=yk0;
  if(XAxis>=0){
    SetLineStyle(XAxis);
    DrawLine(X1WldGlb,0.,X2WldGlb,0.);
    SetLineStyle(0);
  }
  if(YAxis>=0){
    SetLineStyle(YAxis);
    DrawLine(0.,Y1WldGlb,0.,Y2WldGlb);
    SetLineStyle(0);
  }
  SetClipping(cliploc);
  if(YDense>=2){
    Line(xk0,yk0,xk1,yk1);
    if(Arrows){
      Line(xk1,yk1,xk1+4,yk1+4);
      Line(xk1,yk1,xk1-4,yk1+4);
      DP(xk1,yk1-1);
    }
  }
  if(XDense>=2){
    Line(xk0,yk0,xk2+1,yk2);
    if(Arrows){
      Line(xk2,yk2,xk2-4,yk2-4);
      Line(xk2,yk2,xk2-4,yk2+4);
    }
  }
  SetLineStyle(lineloc);
}	/* Axis0() */

static yymin;

Axis(minx,miny,maxx,maxy,mode)
double	minx,miny,maxx,maxy;
{ int	i,j,ix,iy,ix1,ix2,ix3,iy1,iy2,iy3,n,i1,is;
  double	h,d;
  GetXY(&ix,&iy);
  DrawLine(minx,miny,maxx,miny); DrawLine(minx,miny,minx,maxy);
  if(mode==1||mode==2){
	DrawLine(maxx,miny,maxx,maxy); DrawLine(minx,maxy,maxx,maxy);
  }
  i=WindowX(minx);j=WindowY(maxy);Line(i,j,i-4,j);
  ix1=GetCol(i)-1; iy1=GetRow(j); h=(maxy-miny)/3;
  PutF(ix1,iy1,-1,maxy);
  j=WindowY(miny+h); iy1=GetRow(j);Line(i,j,i-4,j); PutF(ix1,iy1,-1,miny+h);
  j=WindowY(maxy-h); iy1=GetRow(j);Line(i,j,i-4,j); PutF(ix1,iy1,-1,maxy-h);
  if(mode==2){
	is=GetLineStyle(); SetLineStyle(1);
	d=miny+h; DrawLine(minx,d,maxx,d);
	d+=h;     DrawLine(minx,d,maxx,d);
	h=(maxx-minx)/4;
	d=minx+h; DrawLine(d,miny,d,maxy);
	d+=h;     DrawLine(d,miny,d,maxy);
	d+=h;     DrawLine(d,miny,d,maxy);
	SetLineStyle(is);
  }
  ix2=ix1+1;
  yymin=j=WindowY(miny);Line(i,j,i-4,j);Line(i,j,i,j+2);
  iy2=GetRow(j); iy3=iy2+1;
  PutF(ix1,iy2,-1,miny);
  i=WindowX(maxx);Line(i,j,i,j+2);ix3=GetCol(i);
  PutF(ix2,iy3,0,minx);
  PutF(ix3+1,iy3,-1,maxx);
  h=(maxx-minx)/4; d=minx+h;
  n=WindowX(d); Line(n,j,n,j+3); n=WindowX((d+=h)); Line(n,j,n,j+3);
  n=WindowX(d+h); Line(n,j,n,j+3);
  GotoXY(ix,iy);
}	/* Axis() */

static PutF(x,y,k,f)	double	f;
{ unsigned char ac[30],*c; int	l,m;  c=ac;
/* 0 - по центру , <0 - слева, прижимаем к правому краю */
  if((X2RefGlb-X1RefGlb>=320)&&(GrafModeGlb==6||GrafModeGlb==16))
	   sprintf(c,"%-8.4g",f);
  else sprintf(c,"%-4.2g",f);
  while(*c==' ')++c;for(l=strlen(c)-1;c[l]==' '&&l>0;--l)c[l]='\0';
  m=l=strlen(c); if(l==1) l=2;
  if(!k) l/= -2; else if(k>0) l= -l;
  x-=l; if(x<0) x=0; else if(x+m>80) x=80-m;
  GotoXY(x,y); printf(c);
}

static GetRow(r)
{ if(GrafModeGlb==16) return(r/14); else return(r/8);}
static GetCol(c)
{ return(c/8);}

Draw(px,py,NPoints,mode,scale)
double	*px,*py;
int	NPoints;
int	mode;
{
  int	x1,y1,x2,y2,i,PlotLine;
  PlotLine=((mode>0)?1:0);
  mode=abs(mode); if(mode>9)PlotLine=0;
  x1=WindowX(px[0]);
  y1=WindowY(py[0]);
  if(mode==9) goto hist;
  DrawItem(x1,y1,mode,scale);
  for(i=1;i<NPoints;++i){
     x2=WindowX(px[i]);
     y2=WindowY(py[i]);
     DrawItem(x2,y2,mode,scale);
     if(PlotLine) Line(x1,y1,x2,y2);
     x1=x2; y1=y2;
  }
  return;
hist:for(i=1;i<NPoints;++i){
        x2=WindowX((px[i]+px[i-1])/2);
        if(PlotLine) Box(x1,y1,x2,yymin);
        else         Bar(x1,y1,x2,yymin);
	  x1=x2; y1=WindowY(py[i]);
     }
     x2=WindowX(px[NPoints-1]);
     if(PlotLine) Box(x1,y1,x2,yymin);
     else         Bar(x1,y1,x2,yymin);
}	/* Draw() */

PrEGAScr0()
{
  int X,Y,SizeX=640,i,Data;
  for(Y=0;Y<349;Y+=8){
	 for(i=0;i<15;++i) Prt(' ');
	 Prt(27);Prt(76);Prt(SizeX%256);Prt(SizeX/256);
	 for(X=0;X<SizeX;X++){
		Data=0;
		if(PD(X,Y)) Data=0x80; if(PD(X,Y+1)) Data|=0x40;
		if(PD(X,Y+2)) Data|=0x20; if(PD(X,Y+3)) Data|=0x10;
		if(PD(X,Y+4)) Data|=0x8; if(PD(X,Y+5)) Data|=0x4;
		if(Y<346){
		  if(PD(X,Y+6)) Data|=0x2; if(PD(X,Y+7)) Data|=0x1;
		}
		Prt(Data);
	 }
	 Prt(27);Prt(51);Prt(22);	/* n/216 inches */
	 Prt('\n');
	 if(kbhit()){ GetKey(); Prt('\n'); Prt('\r'); return; }
  }
  Prt('\n'); Prt('\r');
}	/* PrEGAScr0() */

PrEGAScr1()
{
  int X,Y,SizeX=640,i,SizeY=350,j;
  int	num=350*4;
  int	c[8],j1,k;
  unsigned char buf[350*4];
  for(X=SizeX-1;X>=0;X-=8){
	 for(Y=0;Y<SizeY;Y++){
		for(j=0;j<8;++j) c[j]=PD(X-j,Y);
		for(j=0;j<4;++j){
		   i=3-j;k=0;
		   for(j1=0;j1<8;++j1) k|=(((c[j1]>>i)&1)<<(7-j1));
		   buf[Y*4+j]=k;
		}
	 }
	 for(i=0;i<10;++i) Prt(' ');
	 Prt(27);Prt(90);Prt(num%256);Prt(num/256);	/* 4 скорость */
	 for(j=0;j<num;j+=2){ Prt(buf[j]); Prt(0); }
	 Prt(13);
	 for(i=0;i<10;++i) Prt(' ');
	 Prt(27);Prt(90);Prt(num%256);Prt(num/256);	/* 4 скорость */
	 for(j=0;j<num;j+=2){ Prt(0); Prt(buf[j+1]); }
	 Prt(27);Prt(51);Prt(23);	/* n/216 inches */
	 Prt('\n');
	 if(kbhit()){ GetKey(); Prt('\n'); Prt('\r'); return; }
  }
  Prt('\n'); Prt('\r');
}	/* PrEGAScr1() */

static int status()
{ union REGS regs;
  regs.h.ah = 2; regs.x.dx = 0;
  int86(0x17,&regs,&regs);
}	/* status() */

static int Prt(character)
unsigned char	character;
{ union REGS regs;
  while(!status());
  regs.h.ah = 0; regs.h.al = character;
  regs.x.dx = 0;
  int86(0x17,&regs,&regs);
  return(regs.h.ah);
}	/* put_out() */

static int	SpriteNx[NSPRITE],SpriteNy[NSPRITE];
static unsigned char far *PSprite[NSPRITE];
static unsigned char far *PBuffer[NSPRITE];
static int	SpriteX[NSPRITE],SpriteY[NSPRITE];
static int	SpriteN=-1,SpriteB=0;

ClearSprite()
{ int	i;
  for(i=0;i<SpriteN;++i){
     SpriteX[i]=SpriteY[i]=-1;
     SpriteNx[i]=SpriteNy[i]=0;
     PSprite[i]=PBuffer[i]=NULL;
  }
  SpriteN=-1; SpriteB=0;
}	/* ClearSprite() */

DefSprite(Num,Sprite,Nx,Ny)
int	Num,Nx,Ny;
unsigned char	*Sprite;
{ int	i,j,k,k1,k2;
  extern int far *RAMScreenGlb;	/* for sprite's buffer */
  unsigned char far *p;
  if(Num>=NSPRITE||Num<SpriteN){
    puts("Illegal number of sprite");return;
  }
  SpriteN=Num+1;
  SpriteNx[Num]=Nx; SpriteNy[Num]=Ny;
  PSprite[Num]=Sprite;
  PBuffer[Num]=(unsigned char far *)((long)RAMScreenGlb+SpriteB);
  if(Ega){ PBuffer[Num]+=80; k1=3; k2=80*300;}
  else{ k1=2; k2=40*200; }
  SpriteB+=((Nx>>k1)+2)*Ny;
  if(SpriteB>=k2){
    puts("too large sprite -- memory overflow");return;
  }
  SpriteX[Num]=-1; SpriteY[Num]=-1;
}	/* DefSprite() */

PutSprite(Num,X,Y)
int	Num,X,Y;
{ int	i,j,k,n;
  long	yy1;
  unsigned char far *p,*base;
  if(Num<0||Num>=SpriteN){
    puts("Illegal sprite number"); return;
  }
  if(SpriteX[Num]>=0||SpriteY[Num]>=0) DelSprite(Num);
  SpriteX[Num]=X; SpriteY[Num]=Y;
  p=PBuffer[Num];
  if(Ega){
    n=(SpriteNx[Num]+X)>>3; OUI(1,ENABLE); OUI(3,0); OUI(5,1);
    for(j=Y,k=0;j<SpriteNy[Num]+Y;++j){
       yy1=EGABASE+(long)j*80L;
       for(i=X>>3;i<=n;i++,k++){
	  e_c=*((unsigned char far *)(yy1+i));
	  OUI(8,0x80); p[k]=0xFF;
       }
    }
    OUI(0,0); OUI(1,0); OUI(3,0); OUI(8,0xff); OUI(5,0);
  }else{	/* not EGA */
    n=XAddr[(SpriteNx[Num]+X)];
    for(j=Y,k=0;j<SpriteNy[Num]+Y;++j){
       yy1=(long)HardwareGraf+YAddr[j];
       for(i=XAddr[X];i<=n;i++,k++){/*  p[k]=*((unsigned char far *)(yy1+i));*/
	base=(unsigned char far *)(yy1+i);
	p[k]=*base;
       }
    }
  }
  for(j=0,k=0,p=PSprite[Num];j<SpriteNy[Num];++j){
     for(i=0;i<SpriteNx[Num];++i,++k){
	if((e_c=p[k])!=0xff) DPC(X+i,Y+j,e_c);
     }
  }
}	/* PutSprite() */

DelSprite(Num)
int	Num;
{ int	i,j,k,x,y,n;
  long	yy1;
  unsigned char far *p,*base;
  if(Num<0||Num>=SpriteN){
    puts("Illegal sprite number"); return;
  }
  if(SpriteX[Num]<0&&SpriteY[Num]<0) return;
  x=SpriteX[Num]; y=SpriteY[Num];
  SpriteX[Num]=-1; SpriteY[Num]=-1;   p=PBuffer[Num];
  if(Ega){
  n=(SpriteNx[Num]+x)>>3;
  OUI(1,ENABLE); OUI(3,0); OUI(5,1);
  for(j=y,k=0;j<SpriteNy[Num]+y;++j){
     yy1=EGABASE+(long)j*80L;
     for(i=x>>3;i<=n;i++,k++){
	base=(unsigned char far *)(yy1+i);
	e_c=p[k];
	OUI(8,0x80);
	*base=0xFF;
     }
  }
  OUI(0,0); OUI(1,0); OUI(3,0); OUI(8,0xff); OUI(5,0);
  }else{	/* not EGA */
  n=XAddr[(SpriteNx[Num]+x)];
  for(j=y,k=0;j<SpriteNy[Num]+y;++j){
     yy1=(long)HardwareGraf+YAddr[j];
     for(i=XAddr[x];i<=n;i++,k++){
	base=(unsigned char far *)(yy1+i);
	*base=p[k];
     }
  }
  }
}	/* DelSprite() */
