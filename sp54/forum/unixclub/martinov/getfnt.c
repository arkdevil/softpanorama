#include <dos.h>
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>

#define col_per_char 8  /* =bits_per_byte */
int fortran putext(unsigned char *sym,int *count,int *x,int *y,
		    int *color,int *rotate)
/* Only for EGA graphic mode */
{ char far *symtable,**int43ptr,*fname;
  int i,j,k,x1,y1,rot,rows_per_char,far *x0485ptr;
  FILE *ptr1;
  unsigned char row,key,colr,pagenumber,vmode;
  /* _getactivepage & _getvideoconfig */
  _asm
  { mov ah,0Fh
    int 10h
    mov pagenumber,bh
    mov vmode,al
  }
  switch(vmode)
    { case 0x06: fname="new8x8.fnt"; break;
      case 0x10: fname="new8x14.fnt"; break;
      case 0x12: fname="new8x16.fnt"; break;
      default: return(-1);
    }
  FP_OFF(x0485ptr)=0x485;
  FP_SEG(x0485ptr)=0;
  rows_per_char=*x0485ptr; /* usually = 14 or 8 */
  FP_OFF(int43ptr)=0x10C;
  FP_SEG(int43ptr)=0;
  colr=*color;
  rot=*rotate;
  if(sym[0]>=128)
    { symtable=*int43ptr;
      _fmode=O_BINARY;
      ptr1=fopen(fname,"w");
      fwrite(symtable,256*rows_per_char,1,ptr1);
      fclose(ptr1);
    }
  for(k=0;k<*count;k++)
   { symtable=*int43ptr+sym[k]*rows_per_char;
     x1=*x;
     y1=*y;
     for(i=0;i<rows_per_char;i++)
       { row=symtable[i];
	 switch(rot)
	 { case 1:  y1=*y-k*col_per_char; break;
	   case 2:  x1=*x-k*col_per_char; break;
	   case 3:  y1=*y+k*col_per_char; break;
	   default: x1=*x+k*col_per_char;
	 }
	 key=0x80;
	 for(j=0;j<col_per_char;j++)
	   { if((row & key)!=0)
	     /* This assembler block may be replaced with _putpixel.
		Inline assembler used to avoid request for
		C graphic library while linking fortran programs */
	     _asm
	     { mov cx,x1
	       mov dx,y1
	       mov al,colr
	       mov bh,pagenumber
	       mov ah,0Ch
	       int 10h
	     }
	     key=key>>1;
	     switch(rot)
	     { case 1:  y1--; break;
	       case 2:  x1--; break;
	       case 3:  y1++; break;
	       default: x1++;
	     }
	   }
	 switch(rot)
	 { case 1:  x1++; break;
	   case 2:  y1--; break;
	   case 3:  x1--; break;
	   default: y1++;
	 }
       }
  }
  return(0);
}

#include <stdio.h>
#include <graph.h>

main()
{ int i,x,y,color,count,rotate;
  unsigned vmode;
  for(i=0;i<3;i++)
    { switch(i)
	{ case 0: vmode=6; break;
	  case 1: vmode=16; break;
	  default: vmode=18;
	}
      _asm
	{ mov ax,vmode
	  int 10h
	}
      x=162;
      y=129;
      rotate=0;
      color=5;
      count=33;
      if(putext("This font will be saved into file",&count,&x,&y,&color,&rotate))
	break;
      y=150;
      x=170;
      count=31;
      putext("Этот шрифт будет записан в файл",&count,&x,&y,&color,&rotate);
      y=190;
      x=200;
      count=25;
      color=9;
      putext("Press any key to continue",&count,&x,&y,&color,&rotate);
      getch();
    }
  _asm
    { mov ax,3
      int 10h
    }
  return(0);
}
void _nullcheck() {}
void _setargv_() {}
void _setenvp() {}
