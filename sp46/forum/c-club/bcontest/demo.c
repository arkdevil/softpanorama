/*******************************************************************\
 *			DEMO.C					   *
 * 	Графическая библиотека для языка Си GRAPH		   *
 *		Демонстрационная программа			   *
 *	Гайфуллин Б.Н., 142432, Черноголовка ИПТМ АН СССР	   *
 *	       Научно-технический центр "Интерфейс"		   *
 *			 1990					   *
\*******************************************************************/

#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#define	PI	3.141529

int	i1,j1,i2,j2;	/* глобальные переменные для границ экрана */

main(argc,argv)
int	argc;
char	*argv[];
{
  int i,j,mode;
  /* проверим нет ли аргументов в командной строке, показывающих CGA */
  if(argc>1 && argv[1][0]=='/' && argv[1][1]=='c') mode=4;	/* CGA */
  else mode=16;	/* EGA */
  InitGraphic(mode);		/* инициация цветной графики */
  /* определим значения границ (размеры) экрана, которые будем затем использовать*/
  i1=getx1(); i2=getx2(); j1=gety1(); j2=gety2();
  loadfont("88.fon");	/* загружаем тектовые фонты */
  points(6000);		/* вывод 6000 псевдо-случайных точек */
  setforeground(15);	/* установка цвета графического вывода */
  windowborder();	/* выводим границы экрана */
  lines(400);		/* вывод 400 псевдо-случайных отрезка линий */
  copyscreen();		/* копируем изображение в буферный экран */
  defwindow(1,i1,j2/2,i2/2,j2);	/* описание окна с номером 1 */
  selectwindow(1);	/* включение окна с номером 1 */
  clrwindow();          /* очистка окна */
  setforeground(15);
  windowborder();	/* рисуем границы окна */
  boxes(100);		/* вывод 100 псевдослучайных прямоугольников */
  defwindow(2,i2/2,j2/2,i2,j2);	/* определяем второе окно */
  selectwindow(2);	/* включаем его */
  clrwindow();		/* очищаем окно */
  setforeground(15); windowborder();	/* рисуем границы окна */
  funny();		/* выводим в окне картинку из отрезков */
  defwindow(3,i2/2,j1,i2,j2/2);	/* описываем 3 окно */
  selectwindow(3);	/* включаем его */
  setforeground(15);	/* задаем цвет */
  clrwindow();		/* чистим */
  windowborder();	/* рисуем границы */
  styles();		/* выводим в этом окне различные стили линий */
  colors();		/* меняем в цикле фоновые цвета */
  swapping();		/* обмен экранами */
  clean(1);		/* "очищаем" картинку с восстановлением фона */
  hatches();		/* движущиеся окна с различными видами штриховки */
  copyscreen();		/* запоминаем изображение в дополнительном экране */
  clean(0);		/* чистим экран без восстановления фона */
  ribbon();		/* движение резиновых прямоугольника, линии, крестика */
  ClrScreen();		/* чистим экран */
  SelectWindow(0);	/* включаем нулевое окно, по умолчанию - это весь экран */
  markers(500);		/* выводим маркеры и графические примитивы */
  SelectScreen(2);	/* включаем второй экран */
  sleep(1);
  CopyScreen();		/* копируем его содержимое на первый экран */
  sleep(1);
  CloseGraphic();	/* закрываем работу с графикой */

  /* заново откроем графический режим для двухмерной графики */
  if(mode>6) InitGraphic(16); else initgraphic(6);
  polygons();	 	/* "двумерная" графика */
  draw1();		/* вывод графиков */
  draw2();		/* вывод графиков другого вида */

  /* для спрайтов откроем заново графику */
  InitGraphic(mode);
  sprites();		/* демонстрация работы со спрайтами */
  letters(600);		/* выведем образцы буковок и рекламу */
  CloseGraphic();	/* окончание работы с графикой */
  setmode(2);
}        /* main() */


time(n)			/* временная задержка */
int	n;
{
  delay(n*300);
}

typedef double (*PlotArray)[2];	/* описание типа для многоугольников в
					двумерной графике */
	static PlotArray pa;
	static int	np;

draw1()
{
  int	i,j,k,mode;
  int	i1,j1,i2,j2;
  PlotArray	t4;
  static double aa[65][2];
  i1=getx1(); i2=getx2(); j1=gety1(); j2=gety2();
  mode=getmode();
  t4=aa;
	ClrScreen(); SetForeGround(13);
	for(i=1;i<=32;++i){	/* формируем массив значений синусов */
	   t4[i][0]= -PI+(i-1)*PI/15;
	   t4[i][1]=sin(t4[i][0]);
	}
	DefWorld(2,-PI*1.3,1.5,PI*1.3,-1.5);
	SelectWorld(2);SelectWindow(0);
	DefWindow(1,i1,j1,i2/3-10,j2/2-j2/20);
	DefWindow(2,i2/3,j1,(2*i2)/3-10,j2/2-j2/20);
	DefWindow(3,(2*i2)/3,j1,i2,j2/2-j2/20);
	DefWindow(4,i1,j2/2+j2/20,i2/3-10,j2);
	DefWindow(5,i2/3,j2/2+j2/20,(2*i2)/3-10,j2);
	DefWindow(6,(2*i2)/3,j2/2+j2/20,i2,j2);
	for(i=1;i<=6;++i){
	SelectWindow(i);
	  setforeground(13); WindowBorder();
	  if(i>3) setforeground(11);
	  DrawPolygon(t4,1,32,i,2,0);
	}
	if(mode<=6){
	  delay(200);InvertScreen();delay(300);
	}else{
	  delay(500);
	}
	setforeground(9);
	for(i=1;i<=6;++i){
	  if(i>3) setforeground(7);
	  SelectWindow(i);ClrWindow();WindowBorder();
	  DrawPolygon(t4,1,32,-i-2,2,0);
	}
	if(mode<16){
	  delay(200);InvertScreen();delay(200);
	  SetForeGround(1);
	}else{
	  delay(700); setforeground(12);
	}
	k=2;
	for(i=1;i<=3;++i){
	SelectWindow(i);
	ClrWindow(i);WindowBorder();
	DrawPolygon(t4,1,32,0,0,1);
	for(j=2;j<=32;++j){
	   if(k==1+i)k=2+i;else k=1+i;
	   SetHatchStyle(k);
	   if(j&1)Fill(WindowX(t4[j][0])-2,gety2()-2);
	}
	}
	delay(300);
	if(mode>6) setforeground(4); else setforeground(1);
	SelectWindow(4);InvertWindow();
	Axis0(5,5,-1,-1,1);time(2);InvertWindow();
	time(2);
	SelectWindow(5);InvertWindow();
	Axis0(5,5,2,2,1);time(2);InvertWindow();
	time(2);
	SelectWindow(6);InvertWindow();
	Axis0(5,5,1,3,0);time(2);InvertWindow();
	delay(1000);
}	/* draw1() */

polygons()
{
  int	i,c,k;
  char	*p;
  /* координаты многоугольника для двумерной графики */
  double static tt1[5][2]={{0,0},{0,-5},{-4,4},{4,4},{0,-5}};
  DefWorld(1,-15.,-10.,15.,10.);	/* описываем мир */
  SelectWorld(1);			/* включаем его */
  SelectWindow(0);			/* включаем окно-экран */
  clrwindow(); windowborder();		/* чистим и рисуем границы */
  /* выводим подзаголовочек */
  p="2-Dimensional Graphics  "; k=strlen(p)+1;
  drawtext((i1+i2-k*8)/2,j2-12,p);
  if(getmode()>6) c=14; else c=1;	/* определяем цвет */
  pa=tt1; np=4;
  drp(c);	/* выводим многоугольник (в нашем случае замкнутый) */
  for(i=0;i<=7;++i){
     drp(0);	/* стираем */
     RotatePAbout(pa,np,5.,-2.,-2.); /* поворот вокруг точки */
     drp(c);	/* выводим */
  }
  for(i=0;i<=6;++i){
     drp(0);
     RotatePolygon(pa,np,5.);		/* поворот многоугольника */
     drp(c);
  }
  for(i=0;i<=7;++i){
     drp(0);
     MovePolygon(pa,np,-1.,-1.);	/* сдвиг многоугольника */
     drp(c);
  }
  for(i=0;i<=7;++i){
     drp(0);
     ScalePolygon(pa,np,0.4,0.4);     /* масштабирование */
     drp(c);
  }
  for(i=0;i<=10;++i){
     ScaleCPolygon(pa,np,2.,2.);/*масштабирование многоугольника*/
     drp(c);
  }
  delay(500);		/* задержка */
}	/* polygons() */

drp(i)			/* вывод многоугольника заданным цветом */
int	i;
{
  SetForeGround(i);
  DrawPolygon(pa,1,np,0,0,0);
  if(i) delay(70);
}	/* drp() */


points(n)	/* вывод псевдо-случайных точек в активном окне */
int	n;	/* количество выводимых точек */
{
  int i1,i2,j1,j2,i,j,k,c,o;
  i1=getx1(); i2=getx2(); j1=gety1(); j2=gety2();
  o=getmaxcolor();
  for(k=0;k<n;++k){
     i=i1+random(i2-i1+1); j=j1+random(j2-j1+1);
     c=random(o+1);
     dpc(i,j,c);
  }
}	/* points() */

boxes(n)	/* вывод псевдо-случайных прямоугольников в активном окне */
int	n;	/* количество выводимых прямоугольников */
{
  int i1,i2,j1,j2,i,j,k,c,o;
  int x1,y1,x2,y2;
  i1=getx1(); i2=getx2(); j1=gety1(); j2=gety2();
  o=getmaxcolor();
  for(k=0;k<n;++k){
     x1=i1+random(i2-i1+1); y1=j1+random(j2-j1+1);
     x2=x1-(x1-(i1+random(i2-i1+1)))/2;
     y2=y1-(y1-(j1+random(j2-j1+1)))/2;
     c=random(o+1);
     setforeground(c);
     bar(x1,y1,x2,y2);
  }
}	/* boxes() */

lines(n)	/* вывод псевдо-случайных линий в активном окне */
int	n;	/* количество выводимых линий */
{
  int i1,i2,j1,j2,i,j,k,c,o;
  int x1,y1,x2,y2;
  i1=getx1(); i2=getx2(); j1=gety1(); j2=gety2();
  o=getmaxcolor();
  for(k=0;k<n;++k){
     x1=i1+random(i2-i1+1); y1=j1+random(j2-j1+1);
     x2=x1-(x1-(i1+random(i2-i1+1)))/2;
     y2=y1-(y1-(j1+random(j2-j1+1)))/2;
     c=random(o+1);
     setforeground(c);
     line(x1,y1,x2,y2);
  }
}	/* lines() */

funny()		/* вывод  линий в активном окне */
{
  int i1,i2,j1,j2,i,j,k,c,o;
  int x1,y1,x2,y2;
  i1=getx1(); i2=getx2(); j1=gety1(); j2=gety2();
  o=getmaxcolor();
  setforeground(o-2);
  y1=j1+4; y2=j2-4;
  for(k=0;k<(i2-i1)/4;++k){
     x1=/*i1+6+k*2;*/i1+(i2-i1)/3;
     x2=i2-6-k*4;
     line(x1,y1,x2,y2);
  }
}	/* funny() */

styles()		/* вывод стилей линий в активном окне */
{
  int i1,i2,j1,j2,i,j,k,c,o,s;
  int x1,y1,x2,y2;
  i1=getx1(); i2=getx2(); j1=gety1(); j2=gety2();
  o=getmaxcolor(); c=1; s=0;
  y1=j1+4; y2=j2-4; x1=i1+6;
  for(k=0;k<(i2-i1)/10;++k){
     x2=i2-6-k*9; y2=(j1+j2)/3+k*2+k*k/10;
     if(c>o) c=1; setforeground(c++);
     if(s>4) s=0; setlinestyle(s++);
     line(x1,y1,x2,y2);
  }
}	/* styles() */

hatches()
{
  int	k,i,j;
  if(getmode()!=16){InvertScreen();time(2);InvertScreen();	/*инвертирование экрана*/}
	if(getmode()>6) setforeground(12); else setforeground(1);
	i=(i2-i1)/40; j=(j2-j1)/10;
	DefWindow(1,7*i,0,12*i,3*j);
	SelectWindow(1);
	SetHatchStyle(7);SelectScreen(2);FillWindow();WindowBorder();
	SelectScreen(1);SetHatchStyle(6);FillWindow();WindowBorder();
	for(k=0;k<7*i/8;++k) MoveHor(-8,1);	/* двигаем окно горизонтально */
	RedefWindow(1,7*i,0,12*i,3*j);SelectWindow(1);
	SelectScreen(2);SetHatchStyle(5);FillWindow();WindowBorder();
	SelectScreen(1);
	for(k=0;k<7*i/8;++k) MoveHor(8,1);
	RedefWindow(1,7*i,0,12*i,3*j);SelectWindow(1);CopyScreen();
	SelectScreen(2);SetHatchStyle(4);FillWindow();WindowBorder();
	SelectScreen(1);
	for(k=0;k<14*i/8;++k) MoveHor(8,1);
	RedefWindow(1,7*i,0,12*i,3*j);SelectWindow(1);
	SelectScreen(2);SetHatchStyle(3);FillWindow();WindowBorder();
	SelectScreen(1);
	for(k=0;k<4*j/2;++k) MoveVer(-2,1);	/* двигаем окно вертикально */
	for(k=0;k<7*i/8;++k) MoveHor(-8,1);
	RedefWindow(1,7*i,0,12*i,3*j);SelectWindow(1);
	SelectScreen(2);SetHatchStyle(2);FillWindow();WindowBorder();
	SelectScreen(1);
	for(k=0;k<4*j/2;++k) MoveVer(-2,1);
	for(k=0;k<7*i/8;++k) MoveHor(8,1);
	RedefWindow(1,7*i,0,12*i,3*j);SelectWindow(1);CopyScreen();
	SelectScreen(2);SetHatchStyle(1);FillWindow();WindowBorder();
	SelectScreen(1);
	for(k=0;k<4*j/2;++k) MoveVer(-2,1);
	for(k=0;k<14*i/8;++k) MoveHor(8,1);
	RedefWindow(1,7*i,0,12*i,3*j);SelectWindow(1);
	SelectScreen(2);SetHatchStyle(0);FillWindow();WindowBorder();
	SelectScreen(1);
	for(k=0;k<4*j/2;++k) MoveVer(-2,1);
}	/* hatches() */

colors()	/* меняем фоновые цвета */
{
  int	i,j;
  for(i=0;i<=1;++i){
     SetPalette(i);		/* смена палитры */
     for(j=0;j<=15;++j){
	SetBackGround(j);	/* установка фона */
	delay(150);
     }
  }
  SetPalette(0); SetBackGround(0);
}	/* colors() */

clean(o)	/* очистка экрана */
int	o;	/* параметр, указывающий следует ли восстанавливать запомненный фон */
{
  int	i,j,k;
  char	*p;
  /* определяем окно для рисования */
  i=3*((i2-i1)/8); j=3*((j2-j1)/8)-1;
  defwindow(1,i1+i,j1+j,i2-i,j2-j);
  selectwindow(1);	/* включаем его */
  if(getmode()==16) setforeground(7);	/* устанавливаем цвет для EGA */
  else setforeground(1);
  sethatchstyle(1);	/* определяем стиль раскрашивания */
  fillwindow();		/* раскрашиваем (заполняем) окно */
  setforeground(15);	/* задаем цвет */
  windowborder();	/* рисуем границу окна */
  /* выводим текст, который располагаем по центру окна */
  p="C"; k=strlen(p)+1;
  drawtext((i1+i2-k*8)/2,j1+j+12,p);
  p="Graphics"; k=strlen(p)+1;
  drawtext((i1+i2-k*8)/2,j1+j+24,p);
  p="Library"; k=strlen(p)+1;
  drawtext((i1+i2-k*8)/2,j1+j+32,p);
  if(getmode()>6){	/* для EGA выводим информации побольше */
    setforeground(10);
    p="Gaifullin B."; k=strlen(p)+1;
    drawtext((i1+i2-k*8)/2,j1+j+45,p);
    p="142432 USSR "; k=strlen(p)+1;
    drawtext((i1+i2-k*8)/2,j1+j+53,p);
    p="Chernogolovka"; k=strlen(p)+1;
    drawtext((i1+i2-k*8)/2,j1+j+70,p);
    setforeground(12);
    p=" \3 \3 \3"; k=strlen(p)+1;
    drawtext((i1+i2-k*8)/2,j1+j+80,p);
  }
  sleep(2);	/* на разглядывание даем 2 секунды */
  for(k=0;k<=j2/4/2;++k) movever(2,o);	/* сдвигаем окно по вертикали, вверх */
  for(k=0;k<=i2/4/8;++k) movehor(-8,o);	/* влево */
  for(k=0;k<=j2/2/2;++k) movever(-2,o);	/* вниз */
  for(k=0;k<=i2/2/8;++k) movehor(8,o);	/* вправо */
  while(gety1()>=j1+2) movever(2,o);	/* вверх до упора */
  while(getx1()>=i1+8) movehor(-8,o);	/* влево до упора */
  while(gety2()<=j2-2) movever(-2,o);	/* и так далее ... */
  while(getx2()<=i2-8) movehor(8,o);
  while(gety1()>=j1+2) movever(2,o);
  if(o) while(getx1()>=i1+8) movehor(-8,o);
}	/* clean() */

ribbon()	/* вывод резиновых фигур */
{
  int	k,l,i;
  char	*p;
  selectwindow(0);	/* выбираем окно */
  setlinestyle(0);	/* стиль линии - сплошная */
  clrscreen(); 		/* чистим экран */
  setforeground(15);
  windowborder();	/* рисуем границы */
  p="Ribbon Figures  "; k=strlen(p)+1;
  drawtext((i1+i2-k*8)/2,j2-12,p);
  for(i=1;i<=i1+(i2-i1)/6;i+=2)
     RBox(i*2,(j1+j2)/2-i,i*4,(j1+j2)/2+i); /* резиновый box */
  delay(500);		/* задержка */
  DelBox();		/* удаляем с экрана остаток */
  SetForeGround(11);	/* новый цвет */
  for(i=i1;i<=(i1+i2)/4;++i)	/* резиновая линия */
     RLine(i1+(i2-i1)/10,j2-(j2-j1)/8,i1+(i2-i1)/2+2*i,30+i);
  delay(300);
  DelLine();		/* удаляем линию с экрана */
  if(getmode()>6) SetForeGround(12); else setforeground(2);
  for(i=i2/10;i<=i2-(i2-i1)/3;++i)
     RCross(i,50,20);	/* резиновое перекрестье */
  for(i=i2-(i2-i1)/3;i>=i1+(i2-i1)/3;--i)
     RCross(i,(k=50+(i2-(i2-i1)/3-i)/2),20);
  for(l=0,i=i1+(i2-i1)/3;i<=i2-(i2-i1)/3;++i,++l)
     RCross(i,k,20+l/2);
  delay(500);
  DelCross();		/* удаляем крестик с экрана */
}	/* ribbon() */

markers(n)	/* вывод маркеров */
int	n;	/* количество выводимых маркеров */
{
  int i1,i2,j1,j2,i,j,k,c,o,m,s;
  char	*p;
  setforeground(15);
  windowborder();	/* рисуем границы */
  i1=getx1(); i2=getx2(); j1=gety1(); j2=gety2();
  p="Markers  "; k=strlen(p)+1;
  drawtext((i1+i2-k*8)/2,j2-12,p);
  o=getmaxcolor();	/* максимально допустимый номер цвета */
  for(k=0;k<n;++k){
     i=i1+random(i2-i1+1); j=j1+random(j2-j1+1);
     c=random(o+1); setforeground(c);
     m=random(7); s=1+random(15);
     switch(m){	/* выбираем какой маркер рисовать */
       case 0: Star(i,j,s); break;
       case 1: Diamond(i,j,s); break;
       case 2: Wye(i,j,s); break;
       case 3: CrossDiag(i,j,s); break;
       case 4: Box(i-s/2,j-s/2,i+s/2,j+s/2); break;
       case 5: Bar(i-s/2,j-s/2,i+s/2,j+s/2); break;
       case 6: Circle(i,j,s+3); break;
     }
  }
}	/* markers() */

draw2(){
  double x[128],y[128],z[128];
  int	i,m,s,n,mode;
  char	c[20];
  mode=getmode();	/* используемый графический режим */
  n=32;			/* количество точек */
  s=2;			/* размер маркеров */
  for(i=0;i<n;++i){	/* инициируем значения массивов x и y для графиков */
     x[i]=2*PI/(n-1)*i;
     y[i]=sin(x[i]);	/* y(x) и z(x) - две различные функции */
     z[i]=0.5*cos(x[i]);
  }
  DefWorld(1,-2.,-1.5,8.,1.5); SelectWorld(1);	/* определяем "мир" */
  ClrScreen();
  if(mode==16){		/* определяем окна в зависимости от видеорежима */
    DefWindow(1,0,14,639,174);
    DefWindow(2,0,14,319,174); DefWindow(3,320,14,639,174);
    DefWindow(4,0,175,639,349);
    DefWindow(5,0,175,319,349);DefWindow(6,320,175,639,349);
  }else{
    DefWindow(1,0,8,639,96);
    DefWindow(2,0,8,319,96); DefWindow(3,320,8,639,96);
    DefWindow(4,0,97,639,199);
    DefWindow(5,0,97,319,199);DefWindow(6,320,97,639,199);
  }
  SelectWindow(1); ClrWindow();
  if(mode==16) SetForeground(9); Axis(0.,-1.,6.2831,1.,2);
  if(mode==16) SetForeground(10); Draw(x,y,n,2,s); sleep(1);
  SelectWindow(2); ClrWindow(); WindowBorder();
  if(mode==16)SetForeground(5); Axis(0.,-1.,6.2831,1.,2);
  if(mode==16)SetForeground(6); Draw(x,z,n,3,s);
  if(mode==16)SetForeGround(7); Draw(x,y,n,-2,s);
  sleep(1);
  SelectWindow(4); ClrWindow();
  if(mode==16)SetForeground(1); Axis(0.,-1.,6.2831,1.,0);
  if(mode==16)SetForeground(3); Draw(x,z,n,4,s);sleep(1);
  SelectWindow(6); ClrWindow(); WindowBorder();
  if(mode==16)SetForeground(4); Axis(0.,-1.,6.2831,1.,1);
  if(mode==16)SetForeground(5); Draw(x,z,n,-4,s); Draw(x,y,n,5,s); sleep(1);
  SelectWindow(3); ClrWindow(); WindowBorder();
  if(mode==16)SetForeground(7); Axis(0.,-1.,6.2831,1.,1);
  if(mode==16)SetForeground(8); Draw(x,z,n,-6,s);
  if(mode==16)SetForeGround(9); Draw(x,y,n,-5,s); sleep(1);
  SelectWindow(5); ClrWindow(); WindowBorder();
  if(mode==16)SetForeground(10); Axis(0.,-1.,6.2831,1.,2);
  if(mode==16)SetForeground(11); Draw(x,z,n,7,s);
  if(mode==16)SetForeGround(12); Draw(x,y,n,-8,s); sleep(1);
  SelectWindow(6); ClrWindow();
  if(mode==16)SetForeground(12); Axis(0.,-1.,6.2831,1.,2);
  if(mode==16)SetForeGround(13); Draw(x,y,n,9,s); sleep(2);
  SelectWindow(3); ClrWindow();
  if(mode==16)SetForeground(13); Axis(0.,-1.,6.2831,1.,1);
  if(mode==16)SetForeGround(10); Draw(x,z,n,-9,s);
  if(mode==16)SetForeGround(13); Draw(x,z,n,9,s);
  sleep(1);
}	/* draw2() */

sprites()	/* вывод спрайтов */
{
  /* описание данных для шаблона спрайта - "автомобильчик" */
  static char	s1[20*12]=
  { -1 ,-1 ,-1 ,10 ,10, 10, 10, 10, 10, 10, 10, 10, 10, 10,255,255,255,  3,255,255,
    255,255, 10, 10,10, 10,10 , 10, 10, 10, 10, 10, 10, 10, 10,255,255,  3,255,255,
    255, 10, 10, 10,10,255,255,255, 10,255,255,255,255, 10, 10,255,255,  3,255,255,
    10 , 10, 10, 10,255,255,255,255, 10,255,255,255,255, 10, 10,255,255, 3,255,255,
    10 , 10, 10, 10,255,255,255,255, 10,255,255,255,255, 10, 10,255,255, 3,255,255,
    10 , 10, 10, 10,255,255,255,255, 10,255,255,255,255,255, 10, 10,255, 3,255,255,
    10 , 10, 10, 10,255,255,255,255, 10,255,255,255,255,255, 10, 10, 10, 3,255,255,
    255, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10,10, 10, 10,
    255, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10,10, 10, 10,
    255,255, 13,  0,  0,  0,  0, 13,255,255,255, 13,  0,  0,  0,  0, 13,10,10 , 10,
    255,255,255, 13, 0 ,  0, 13,255,255,255,255,255, 13,  0,  0, 13,255,255,255,255,
    255,255,255,255, 13, 13, 255,255,255,255,255,255,255,13, 13,255,255,255,255,255
  };
  /* массивы для трех других автомобильчиков */
  static char	s2[20*12],s3[20*12],s4[20*12];

  static char p[5*4]={ 13,13,13,13,13,	/* шаблон для бегающего квадратика */
	      13,0 ,0 ,0 ,13,
	      13,0 ,0 ,0 ,13,
	      13,13,13,13,13
  };

  int	i,j,k,l,m,mode;
  int	i1,i2,i3,i4,j1,j2,j3,j4;
  int	x1,y1,x2,y2;
  char	*q;
  mode=getmode();	/* определили в каком видеорежиме работаем */
  /* копируем данные (с изменением окраски) для шаблонов */
  for(i=0;i<20*12;++i){
     k=s1[i]; if(k==10) k=9; s2[i]=k;
  }
  for(i=0;i<20*12;++i){
     k=s1[i]; if(k==10) k=11; s3[i]=k;
  }
  for(i=0;i<20*12;++i){
     k=s1[i]; if(k==10) k=12; s4[i]=k;
  }
  x1=getx1(); x2=getx2(); y2=gety2();
  clrscreen(); selectwindow(0);
  /* выводим подзаголовочек */
  setforeground(15);
  if(mode==16) q="Sprite-Oriented Graphics  ";
  else q="Sprites";
  k=strlen(q)+1;
  drawtext((x1+x2-k*8)/2,y2-12,q);
  setforeground(10);
  defsprite(0,p,5,4);	/* описываем спрайты по их шаблонам */
  defsprite(1,s1,20,12);
  defsprite(2,s2,20,12);
  defsprite(3,s3,20,12);
  defsprite(4,s4,20,12);
  windowborder();	/* выводим границу */
  /* начинаем выводить спрайты */
  for(i=(15*x2)/16;i>25;i-=2) putsprite(0,i,x2/16);	/* квадратик */
  i1=i2=i3=i4=4;
  if(mode==16){	/* определяем размеры прямоугольников-дорожек для автомобилей */
    j1=100; j2=150; j3=200; j4=250; k=200; l=450; m=15;
  }else{
    j1=50; j2=90; j3=130; j4=170; k=50; l=270; m=10;
  }
  /* выводим дорожки */
  sethatchstyle(4);setforeground(5);fillbox(k,j1-m,l,j1+m);
  sethatchstyle(3);setforeground(7);fillbox(k,j2-m,l,j2+m);
  sethatchstyle(6);setforeground(2);fillbox(k,j3-m,l,j3+m);
  sethatchstyle(5);setforeground(1);fillbox(k,j4-m,l,j4+m);
  /* 4 автомобиля на старте */
  putsprite(1,i1,j1);putsprite(2,i2,j2);
  putsprite(3,i3,j3);putsprite(4,i4,j4);
  m=2;	/* размер шага с которым движутся авто на экране */
  sleep(1);	/* задержка */
  if(mode!=16){
    for(i=0;i<165;++i) putsprite(0,25,25+i);
    setforeground(15);line(280,0,280,199);
    k=282;
  }else{
    for(i=0;i<260;++i) putsprite(0,25,40+i);
    setforeground(15);line(500,0,500,349);
    k=500;
  }
  while(i1<k||i2<k||i3<k||i4<k){
    l=rand()&3;
    if(l==0&&i1<k){
      i1+=m;putsprite(1,i1,j1);
    }else if(l==1&&i2<k){
      i2+=m;putsprite(2,i2,j2);
    }else if(l==2&&i3<k){
      i3+=m;putsprite(3,i3,j3);
    }else if(i4<k){
      i4+=m;putsprite(4,i4,j4);
    }
  };
}	/* sprites() */

letters(n)	/* вывод букв и рекламы */
int	n;
{
  int i1,i2,j1,j2,i,j,k,c,o,s,l,mode;
  char	*p;
  mode=getmode();
  i1=getx1(); i2=getx2(); j1=gety1(); j2=gety2();
  if(mode==16) k=340; else k=210;
  defwindow(1,i1,j1,k,(2*j2)/3); selectwindow(1);
  setforeground(15); clrscreen(); windowborder();
  o=getmaxcolor();
  for(k=0;k<n;++k){
     i=i1+random(i2-i1+1); j=j1+random(j2-j1+1);
     c=random(o+1); s=random(256); l=1+random(3);
     setforeground(c); drawascii(i,j,l,s);
  }
  selectwindow(0);
  setforeground(o-1);
  drawtext(i1,(2*j2)/3+20,"GRAPH");
  setforeground(o-2);
  drawtext(i1+6*8,(2*j2)/3+20," - самая мощная графическая");
  drawtext(i1,(2*j2)/3+30,"        библиотека для языка Си ");
  drawtext(i1,(2*j2)/3+40,"        из всех существующих ");
  drawtext(i1,(2*j2)/3+50,"Поставляется в исходных текстах на Си!");
  if(mode==16){
    setforeground(o-4);
    drawtext(i1,(2*j2)/3+65,"Это 120 подпрограмм и более 2000 строк на Си.");
    drawtext(i1,(2*j2)/3+75,"Это подробная документация и демонстрационные примеры.");
    drawtext(i1,(2*j2)/3+85,"Это уникальные графические возможности для профессионалов.");
    drawtext(i1,(2*j2)/3+95,"Это легкость освоения и использования для начинающих.");
    setforeground(o-5);
    drawtext(i1,(2*j2)/3+110,"142432 Черноголовка, ИПТМ АН СССР, Гайфуллин Б.");
    setforeground(7);
    drawtext(i2/2+40,j1+10,"Многооконная графика");
    drawtext(i2/2+40,j1+20,"Математическая система");
    drawtext(i2/2+40,j1+30,"координат");
    drawtext(i2/2+40,j1+40,"Движущиеся окна");
    drawtext(i2/2+40,j1+50,"Поддержка второго экрана");
    drawtext(i2/2+40,j1+60,"Работа с мышью");
    drawtext(i2/2+40,j1+70,"Вывод графиков, гистограмм");
    drawtext(i2/2+40,j1+80,"Вывод осей координат");
    drawtext(i2/2+40,j1+90,"Поддержка спрайтов");
    drawtext(i2/2+40,j1+100,"Работа с клавиатурой");
    drawtext(i2/2+40,j1+110,"Вывод текстовых строк");
    drawtext(i2/2+40,j1+120,"Графические маркеры");
    drawtext(i2/2+40,j1+130,"Движущиеся курсоры");
    drawtext(i2/2+40,j1+140,"Работа со звукогенератором");
    drawtext(i2/2+40,j1+150,"Определение текстовых фонтов");
    drawtext(i2/2+40,j1+160,"Перемещение сегментов");
    drawtext(i2/2+40,j1+170,"изображений");
    drawtext(i2/2+40,j1+180,"Вывод изображений на принтер");
    drawtext(i2/2+40,j1+190,"Двухмерная графика");
    drawtext(i2/2+40,j1+205,"и другие возможности ...");
    for(i=0;i<20;++i){
    setforeground(o-3);
    drawascii(62*8,(2*j2)/3+110,1,'\3'); delay(400);
    setforeground(0);
    drawascii(62*8,(2*j2)/3+110,1,'\3'); delay(100);
    }
  }else  sleep(4);
}	/* letters() */

swapping()	/* обмен экранами */
{
  int	i,j,k;
  char *p;
  i=3*((i2-i1)/8); j=5*((j2-j1)/12)-1;
  defwindow(1,i1+i,j1+j,i2-i,j2-j);
  selectwindow(1);	/* включаем его */
  clrwindow();		/* раскрашиваем (заполняем) окно */
  setforeground(15);	/* задаем цвет */
  windowborder();	/* рисуем границу окна */
  /* выводим текст, который располагаем по центру окна */
  p="Screen 1"; k=strlen(p)+1;
  drawtext((i1+i2-k*8)/2,(j1+j2)/2-6,p);
  if(getmode()==16) p="Screens Swapping ";
  else p="Swapping";
  k=strlen(p)+1;
  drawtext((i1+i2-k*8)/2,(j1+j2)/2+6,p);
  selectscreen(2);	/* переключаем вывод на второй экран */
  clrwindow();		/* раскрашиваем (заполняем) окно */
  setforeground(15);	/* задаем цвет */
  windowborder();	/* рисуем границу окна */
  /* выводим текст, который располагаем по центру окна */
  p="Screen 2"; k=strlen(p)+1;
  drawtext((i1+i2-k*8)/2,(j1+j2)/2+4,p);
  selectscreen(1);	/* восстанавливаем вывод на первый экран */
  sleep(1);		/* задержка на 1 секунду */
  swapscreen();		/* обмениваем изображения на экранах */
  sleep(1);
  swapscreen();
  sleep(1);
  swapscreen();
  sleep(1);
  swapscreen();		/* сделали несколько раз */
  delay(500);
}	/* swapping() */

