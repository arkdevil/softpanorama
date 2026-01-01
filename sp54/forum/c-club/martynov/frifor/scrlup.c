#define FP_SEG(fp) (*((unsigned *)&(fp) + 1))
#define FP_OFF(fp) (*((unsigned *)&(fp)))

void fortran scrlup(char *str,int *count,int *x,int *y,int *dx,int *dy)
{ char far *video;
  unsigned char symb,i,j,tail;
  FP_SEG(video)=0xB800;
  FP_OFF(video)=(*y*80+(*x))<<1;
  for(i=1;i<*dy;i++)
    { for(j=0;j<*dx;j++)
	video[j<<1]=video[(j<<1)+160];
      video+=160;
    }
  for(i=tail=0;i<*dx;i++)
    { symb=str[i];
      if(symb==0 || i>=*count)
	tail=1;
      if(tail)
	symb=' ';
      video[i<<1]=symb;
    }
}
void fortran scrldn(char *str,int *count,int *x,int *y,int *dx,int *dy)
{ char far *video;
  char symb,i,j,tail;
  FP_SEG(video)=0xB800;
  FP_OFF(video)=((*y+*dy-1)*80+(*x))<<1;
  for(i=1;i<*dy;i++)
    { for(j=0;j<*dx;j++)
	video[j<<1]=video[(j<<1)-160];
      video-=160;
    }
  for(i=tail=0;i<*dx;i++)
    { symb=str[i];
      if(symb==0 || i>=*count)
	tail=1;
      if(tail)
	symb=' ';
      video[i<<1]=symb;
    }
}

void fortran scrllf(int *x,int *y,int *dx,int *dy,int *count)
{ char far *video;
  int i,j;
  FP_SEG(video)=0xB800;
  FP_OFF(video)=(*y*80+(*x))<<1;
  for(j=0;j<*dy;j++)
    { for(i=0;i<(*dx-*count);i++)
	{ video[i<<1]=video[(i+*count)<<1];
	  video[(i+*count)<<1]=' ';
	}
      video+=160;
    }
}
void fortran scrlrg(int *x,int *y,int *dx,int *dy,int *count)
{ char far *video;
  int i,j;
  FP_SEG(video)=0xB800;
  FP_OFF(video)=(*y*80+(*x))<<1;
  for(j=0;j<*dy;j++)
    { for(i=*dx-1;i>=*count;i--)
	{ video[i<<1]=video[(i-*count)<<1];
	  video[(i-*count)<<1]=' ';
	}
      video+=160;
    }
}
