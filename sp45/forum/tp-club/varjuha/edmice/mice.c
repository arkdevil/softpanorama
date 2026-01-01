#include <dos.h>
#include "mice.h"

void setmouseshape(MouseShapePtr m)
{
  struct REGPACK reg;

  reg.r_ax = 9;
  reg.r_dx = FP_OFF(m->andmask);
  reg.r_es = FP_SEG(m->andmask);
  reg.r_bx = m->hotspotx;
  reg.r_cx = m->hotspoty;
  intr(0x33, &reg);
}

void showmouse(void)
{
  struct REGPACK reg;

  reg.r_ax = 1;
  intr(0x33, &reg);
}

void hidemouse(void)
{
  struct REGPACK reg;

  reg.r_ax = 2;
  intr(0x33, &reg);
}

void settextmode(void)
{
  struct REGPACK reg;

  reg.r_ax = 3;
  intr(0x10, &reg);
}

void setgraphmode(void)
{
  struct REGPACK reg;

  reg.r_ax = 0x13;
  intr(0x10, &reg);
}

int mouseinstalled(void)
{
  struct REGPACK reg;
  void interrupt (*i)(); 
  int res;

  res = 0;
  i = getvect(0x33);
  if (!i) return res;
  reg.r_ax = 0;
  intr(0x33, &reg);
  if (reg.r_ax == 0xffff) res++;
  return res;
}
