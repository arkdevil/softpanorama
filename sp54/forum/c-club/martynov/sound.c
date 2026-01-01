#define FP_SEG(fp) (*((unsigned *)&(fp) + 1))
#define FP_OFF(fp) (*((unsigned *)&(fp)))
void fortran sound(long *freq,long *duration)
{ long far *clock;
  long cpd;
  unsigned fc;
  FP_SEG(clock)=0x40;
  FP_OFF(clock)=0x6C;
  cpd=*clock+*duration;
  if(*freq)
    { fc=1190000L/(*freq);
      _asm
	{ in al,61h
	  or al,3h
	  out 61h,al
	  mov al,0B6h
	  out 43h,al
	  mov ax,fc
	  out 42h,al
	  xchg ah,al
	  out 42h,al
	}
    }
  while(*clock<cpd);
  _asm
    { in al,61h
      and al,0FCh
      out 61h,al
    }
}
void fortran beep()
{ long f,d;
  f=1000;
  d=8;
  sound(&f,&d);
}
