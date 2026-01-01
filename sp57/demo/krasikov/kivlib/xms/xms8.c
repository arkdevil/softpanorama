#include <xms.h>
#include <dos.h>


int xms2mem(unsigned int handle, unsigned long offset,
	    void far * Buf, unsigned int Count)
{
  EMMSTRUCT E;
  unsigned int w;
  int ww;
  ww=(E.size=Count)%2;
  if (ww) E.size--;
  E.soh=handle;
  E.soo=offset;
  E.dsh=0;
  E.dso=(unsigned long)(MK_FP(FP_SEG(Buf),FP_OFF(Buf)));
  if (moveXMS(&E)==0) return 0;
  if (ww) {
      E.size=2;
      E.soh=handle;
      E.soo=offset+Count-1;
      E.dsh=0;
      E.dso=(unsigned long)(MK_FP(FP_SEG(&w),FP_OFF(&w)));
      if (moveXMS(&E)==0) return 0;
      pokeb(FP_SEG(Buf),FP_OFF(Buf)+Count-1,(unsigned char)w);
  }
  return 1;
}
