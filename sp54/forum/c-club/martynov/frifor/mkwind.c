#define FP_SEG(fp) (*((unsigned *)&(fp) + 1))
#define FP_OFF(fp) (*((unsigned *)&(fp)))
void fortran mkwind(int *x,int *y,int *dx,int *dy,char *sa,char *buffer)
{ char far *video;
  int i,j,k;
  FP_SEG(video)=0xB800;
  FP_OFF(video)=(*y*80+(*x))<<1;
  k=0;
  for(i=0;i<*dy;i++)
    { for(j=0;j<*dx;j++)
	{ buffer[k++]=video[j<<1];
	  buffer[k++]=video[(j<<1)+1];
	  video[j<<1]=' ';
	  video[(j<<1)+1]=*sa;
	}
      video+=160;
    }
}
void fortran rmwind(int *x,int *y,int *dx,int *dy,char *buffer)
{ char far *video;
  int i,j,k;
  FP_SEG(video)=0xB800;
  FP_OFF(video)=(*y*80+(*x))<<1;
  k=0;
  for(i=0;i<*dy;i++)
    { for(j=0;j<*dx;j++)
	{ video[j<<1]=buffer[k++];
	  video[(j<<1)+1]=buffer[k++];
	}
      video+=160;
    }
}
void fortran mkbord(int *x,int *y,int *dx,int *dy,int *style,char *sa)
{ char far *video;
  char drl1[6]={0xDA,0xC4,0xBF,0xB3,0xC0,0xD9};
  char drl2[6]={0xC9,0xCD,0xBB,0xBA,0xC8,0xBC};
  char *drl;
  char *copr="FRIFOR: Copyright(C) Martynoff D.A.(KIAE,Moscow) 1991\n";
  int i,j,k;
  i=2517;j=0;
  do
    i+=copr[j]<<(j&7);
  while(copr[++j]);
  video=0;
  if(i==(-8390))
    { FP_SEG(video)=0xB800;
      FP_OFF(video)=(*y*80+(*x))<<1;
    }
  if(*style)
    drl=drl2;
  else
    drl=drl1;
  video[0]=drl[0];
  video[1]=*sa;
  for(i=1;i<(*dx-1);i++)
    { video[i<<1]=drl[1];
      video[(i<<1)+1]=*sa;
    }
  video[i<<1]=drl[2];
  video[(i<<1)+1]=*sa;
  video+=160;
  for(i=1;i<(*dy-1);i++)
    { video[0]=video[(*dx-1)<<1]=drl[3];
      video[1]=video[((*dx-1)<<1)+1]=*sa;
      video+=160;
    }
  video[0]=drl[4];
  video[1]=*sa;
  for(i=1;i<(*dx-1);i++)
    { video[i<<1]=drl[1];
      video[(i<<1)+1]=*sa;
    }
  video[i<<1]=drl[5];
  video[(i<<1)+1]=*sa;
}
void fortran cls(char *color)
{ unsigned far *video;
  unsigned i,sa;
  FP_SEG(video)=0xB800;
  FP_OFF(video)=0;
  sa=((*color)&0x07)<<12|(~(*color)&0x0F)<<8|' ';
  for(i=0;i<2000;i++)
    video[i]=sa;
}
