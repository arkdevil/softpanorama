#define FP_SEG(fp) (*((unsigned *)&(fp) + 1))
#define FP_OFF(fp) (*((unsigned *)&(fp)))
static unsigned char com24old=0x00;
void fortran disa24()
{ char far *com24;
  int far *lowaddr;
  if(com24old==0x00)
    { lowaddr=0;
      FP_OFF(com24)=lowaddr[0x48];
      FP_SEG(com24)=lowaddr[0x49];
      com24old=*com24;
      *com24=0xCF;
    }
}
void fortran enab24()
{ char far *com24;
  int far *lowaddr;
  if(com24old)
    { lowaddr=0;
      FP_OFF(com24)=lowaddr[0x48];
      FP_SEG(com24)=lowaddr[0x49];
      if(*com24==0xCF) *com24=com24old;
      com24old=0;
    }
}
