#define FP_SEG(fp) (*((unsigned *)&(fp) + 1))
#define FP_OFF(fp) (*((unsigned *)&(fp)))
void fortran wrtext(char *str,int *count,int *x,int *y,int *dx,char *sa)
{ char far *video;
  unsigned char symb,i,j,tail;
  FP_SEG(video)=0xB800;
  FP_OFF(video)=(*y*80+(*x))<<1;
  for(i=j=tail=0;i<*dx;i++)
    { symb=str[i];
      if(symb==0 || i>=*count)
	tail=1;
      if(tail)
	symb=' ';
      video[j++]=symb;
      if(*sa) video[j]=*sa;
      j++;
    }
}
void fortran rdtext(char *str,int *count,int *x,int *y)
{ char far *video;
  unsigned char i;
  FP_SEG(video)=0xB800;
  FP_OFF(video)=(*y*80+(*x))<<1;
  for(i=0;i<*count;i++)
    str[i]=video[i<<1];
}
void fortran chattr(int *count,int *x,int *y,char *sa)
{ char far *video;
  unsigned char i,j;
  FP_SEG(video)=0xB800;
  FP_OFF(video)=(*y*80+(*x))<<1;
  for(i=0,j=1;i<*count;i++,j+=2)
    video[j]=*sa;
}
