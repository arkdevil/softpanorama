#include "DBG85C.H"
#include <stdio.h>
#include <conio.h>

byte daylight;

void pane(byte s,byte x, byte y)  /* вывод символа в заданной позиции */
{
  gotoxy(x,y);
  if (s) putchar('▒');
    else putchar(' ');
}

void pascal far IN_model(byte n)
{
n++;
retdbg(daylight);			/* возврат значения освещенности */
}

void pascal far OUT_model(byte n,byte d)
{
  switch (n)				/* для каждого порта вывод символа */
  {					/* в своем месте		   */
   case 1: pane(d,32,10); break;
   case 2: pane(d,35,10); break;
   case 3: pane(d,32,12); break;
   case 4: pane(d,35,12);
  }
retdbg(0);
}

void pascal far CLK_model(void)
{
  set85interrupt(0,8);			/* прерывание номер 0, вектор -8 */
  setnextcall(get85time()+10000);	/* следующий вызов через 0.1 сек */
  retdbg(0);
}

void pascal far DAT_model(void)
{
  daylight=!daylight;			/* инверсия значения освещенности */
  gotoxy(1,1);
  if (daylight) printf("день");		/* вывод текущего состояния */
	   else printf("ночь");
  retdbg(0);
}

void main()
{
  adjustmodel( OUT_model, IN_model, DAT_model, CLK_model );
  daylight=0; clrscr(); gotoxy(1,1); printf("ночь");
  gotoxy(30,5);  printf("   /\\ ");
  gotoxy(30,6);  printf("  /  \\ ");
  gotoxy(30,7);  printf(" /    \\ ");
  gotoxy(30,8);  printf("/      \\");
  gotoxy(30,9);  printf("╔══════╗");
  gotoxy(30,10); printf("║      ║");
  gotoxy(30,11); printf("║      ║");
  gotoxy(30,12); printf("║      ║");
  gotoxy(30,13); printf("╚══════╝");
  linkwithdbg();
}
