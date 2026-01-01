/*
   RCST.C
 Copyright (c) 1991 7-Soft
    Functions for programs decorating

*/

int  vsprintf(char *buffer,const char *format,void *Params);
void __emit__();

typedef unsigned char byte;

#define peek(seg,offs)	*((unsigned*)MK_FP((seg),(offs)))
#define peekb(seg,offs)	*((unsigned char*)MK_FP((seg),(offs)))
#define	__int__(c)	__emit__(0xCD,(c))
#define FP_OFF(p)       ((unsigned)(p))                         
#define FP_SEG(p)       ((unsigned)(byte _seg *)(byte far *)(p))
#define MK_FP(seg,ofs)  ((byte _seg *)(seg)+(byte near *)(ofs)) 

char _seg *displayptr;
unsigned page;
unsigned size;
unsigned lines;
unsigned scanlines;
unsigned mono;
unsigned width;

void pr(int xx,int yy,char color,char pr_val)
{
 /* Put char 'pr_val' to (xx;yy) point with color 'color' */
 *((int far*)(displayptr+(page*size)+yy*160+(xx<<1)))=(int)((color<<8)+pr_val);
}

void initdisplay(void)
{
 register int Al;
 _AH=0x0F;
 __int__(0x10);
 Al=_AL;
 displayptr=(char _seg *)((Al != 7)?0xB800:0xB000);
 mono=(Al!=7)&1;
 lines=peekb(0,0x484)+1;
 if(lines==0) lines=25;
 scanlines=peek(0,0x485);
 if(scanlines==0) scanlines=8;
 size=peek(0,0x44C);
 page=peekb(0,0x462);
 width=peekb(0,0x44A);
}

void border(int xx,int yy,int lx,int ly,char bc,char tc)
/* (XX;YY)-Left upper conner;LX,LY-text field size;
   BC-border color; TC-text color
*/
{
 register int i,j;
 for(i=xx+1;i<=xx+lx;i++)
 {
  pr(i,yy,bc,205);
  pr(i,yy+ly+1,bc,205);
  for(j=yy+1;j<=yy+ly;j++)
   pr(i,j,tc,32);
 }
 for(i=yy+1;i<=yy+ly;i++)
 {
  pr(xx,i,bc,186);
  pr(xx+lx+1,i,bc,186);
 }
 pr(xx,yy,bc,201);
 pr(xx+lx+1,yy,bc,187);
 pr(xx,yy+ly+1,bc,200);
 pr(xx+lx+1,yy+ly+1,bc,188);
 for(i=xx+1;i<=xx+lx+2;i++)
  pr(i,yy+ly+2,112,178);
 for(i=yy+1;i<=yy+ly+2;i++)
  pr(xx+lx+2,i,112,178);
}

void writef(int col, int row, int color, char *Format, ...)
{
 char output[81];
 register int i;
 vsprintf(output, Format, ...);
 for(i=0;output[i];i++)
   pr(col+i,row,color,output[i]);
} /* writef */