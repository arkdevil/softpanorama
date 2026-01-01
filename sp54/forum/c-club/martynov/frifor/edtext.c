#define FP_SEG(fp) (*((unsigned *)&(fp) + 1))
#define FP_OFF(fp) (*((unsigned *)&(fp)))
void fortran getkey();
void fortran movcur();
void fortran getcur();
void fortran edtext(char *str,int *count,int *x,int *y,int *dx,char *sa)
{ unsigned char far *video;
  unsigned char symb,tail,scan,asc;
  int i,i0,j;
  long ix,ix0,iy0;
  FP_SEG(video)=0xB800;
  FP_OFF(video)=(*y*80+(*x))<<1;
  for(i=j=tail=i0=0;i<*dx;i++)
    { symb=str[i];
      if(symb==0 || i>=*count) tail=1;
      if(tail) symb=0x20;
      if(symb>0x20) i0=i+1;
      video[j++]=symb;
      if(*sa>=0) video[j]=*sa;
      j++;
    }
  getcur(&ix0,&iy0);
  i=i0;
  ix=*x+i;
  movcur(&ix,y);
  do
    { getkey(&scan,&asc);
      if(asc>=0x20)
	{ for(j=*dx-1;j>i;j--)
	    video[j<<1]=video[(j-1)<<1];
	  video[j<<1]=asc;
	  scan=77;
	}
      if(asc==0x08 && i>0)
	{ scan=0x53;
	  ix--; i--;
	  movcur(&ix,y);
	}
      if(asc==0x1B)
	{ i=0; ix=*x;
	  movcur(&ix,y);
	  for(j=0;j<*dx;j++)
	    video[j<<1]=0x20;
	}
      if(scan==83) /*Del*/
	{ for(j=i+1;j<*dx;j++)
	    video[(j-1)<<1]=video[j<<1];
	  video[(j-1)<<1]=0x20;
	}
      if(scan==75 && i>0) /*Left*/
	{ ix--; i--;
	  movcur(&ix,y);
	}
      if(scan==77 && i<*dx-1) /*Right*/
	{ ix++; i++;
	  movcur(&ix,y);
	}
    }
  while(asc != 0x0D && asc != 0x0A);
  movcur(&ix0,&iy0);
  for(j=0;j<*count;j++)
    str[j]=video[j<<1];
}
