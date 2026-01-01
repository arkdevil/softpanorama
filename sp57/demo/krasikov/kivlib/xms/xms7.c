#include <xms.h>
#include <dos.h>


int mem2xms(void far * Buf, unsigned int Count, unsigned int handle,
	    unsigned long offset)
{
  EMMSTRUCT E;
  unsigned int w;
  int ww;
  #pragma warn -pia
  if (ww=Count %2) {
  #pragma warn +pia
      E.size=2;
      E.soh=handle;
      E.soo=offset+Count;
      E.dsh=0;
      E.dso=(unsigned long)(MK_FP(FP_SEG(&w),FP_OFF(&w)));
      if (moveXMS(&E)==0) return 0;
  }
  E.size=(ww) ? Count+1 : Count;
  E.soh=0;
  E.soo=(unsigned long)(MK_FP(FP_SEG(Buf),FP_OFF(Buf)));
  E.dsh=handle;
  E.dso=offset;
  if (moveXMS(&E)==0) return(0);
  if (ww) {
      E.size=2;
      E.soh=0;
      E.soo=(unsigned long)(MK_FP(FP_SEG(&w),FP_OFF(&w)));
      E.dsh=handle;
      E.dso=offset+Count;
      if(moveXMS(&E)==0) return(0);
  }
  return(1);
}

