#include <dos.h>
void GetMyTime(int *sec,int *min,int *hor){
union REGS regs;
regs.h.ah = 02;
int86(0x1a, &regs, &regs);
*sec = regs.h.dh & 0x000f;
*sec += ((regs.h.dh & 0x00f0) >> 4)*10;
*min = regs.h.cl & 0x000f;
*min += ((regs.h.cl & 0x00f0) >> 4)*10;
*hor = regs.h.ch & 0x000f;
*hor += ((regs.h.ch & 0x00f0) >> 4)*10;
}