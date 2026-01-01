/*══════════════════════════════════════════════*/
/*  Программа комплекса обеспечения работы с    */
/*  MOUSE-driver'ом.                            */
/* Программа обеспечивает возврат признака нажа-*/
/*  тия функциональной клавиши на клавиатуре или*/
/*  движения и нажатия клавиш MOUSE.            */
/*  Формат ображения:                           */
/*  int getchm(void);                           */
/*  Возврашаемое значение - код клавиши.        */
/*       для функциональных клавиш 0 поглащает- */
/*       ся.                                    */
/*──────────────────────────────────────────────*/
/* Автор Зеливянский Е.Б. 12/06/89 12:35pm      */
/*══════════════════════════════════════════════*/
#include <mouse.h>
#define MOUSEPOS if(sx==0)mouspos(600,sy);\
                 if(sx==632)mouspos(10,sy); \
                 if(sy==0)mouspos(sx,180);\
                 if(sy==192)mouspos(sx,10);
int stepx=8,
    stepy=11,
    posx =0,
    posy =0,
    cursor=0,
    rbt  =SPACE,
    lbt  =ENTER,
    mbt  =ESC,
    maxx =640,
    maxy =350,
    sx,
    sy;
getchm()
{
 static int stat=-1;
 int x=0,y=0,p;
 struct PRESS press;
 static int init=0;
 if(init==0)
 {
  init=1;
  stat=getmouse();
  if(stat==0)
  {
   mousset(maxx,maxy);
   mouspos(posx,posy);
   x=posx;
   y=posy;
   sx=x;
   sy=y;
   if(cursor==1)
   setmouse();
  }
 }
 press.l=press.r=press.m=0;
 while((p=kbhit())==0)
 {
  if(stat==0)
  {
  mousmov(&x,&y,&press);
  if((x-sx)>=stepx)
  {
   sx=x;sy=y;
   MOUSEPOS;
   return(RIGHT);
  }
  if((sx-x)>=stepx)
  {
   sx=x;sy=y;
   MOUSEPOS;
   return(LEFT);
  }
  if((y-sy)>=stepy)
  {
   sy=y;sx=x;
   MOUSEPOS;
   return(DOWN);
  }
  if((sy-y)>=stepy)
  {
   sy=y;sx=x;
   MOUSEPOS;
   return(UP);
  }
  if(press.l==-1)return(lbt);
  if(press.m==-1)return(mbt);
  if(press.r==-1)return(rbt);
  }
 }
 p=getch();
 if(p==0)p=getch();
 return(p);
}
