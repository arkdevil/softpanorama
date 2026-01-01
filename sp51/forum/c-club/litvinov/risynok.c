/*  Имя : RISYNOK
    Версия: 1.1
    Дата последней редакции: 7.4.1992г.
    Автор: Литвинов Михаил , р.т. 526-92-61, 141120 Московская обл.,
    г.Фрязино, ул.Полевая, д.15, кв.286

    Функция: подпрограмма предназначена для отрисовки графиков в 
    среде Turbo C++ 1.01 & Turbo C 2.0.

    Принимаемые параметры: подпрограмма принимает три параметра
    void risynok(float array_x[],float array_y[],int number)
    array_x - массив значений по оси X
    array_y - массив значений по оси Y
    number - количество отсчетов

    Внутренние подпрограммы: 
		  search -  определение максимума и минимума вх.
			    массива
		  porno - определение порядка вх.массива,кол-ва рисок,
		  новых (хороших) максимума и минимума
		  graph_error - обработка ошибок.

    Механиэм эапуска: вызывается внешней программой

    Примечания:  после выэова необходимо головную программу
		 оканчивать exit(0);
		   */
#include <stdio.h>
#include <graphics.h>
#include <conio.h>
#include <math.h>
#include <stdlib.h>

/* Прототипы внутренних подпрограмм */

void porno (float *max, float *min, int *kris,float ris[],int *ip,float *num_ip);
void search_maxmin (float *max, float *min,float array[],int number);
void graph_error (void);

/* Начало подпрограммы */ 
void risynok(float array_x[],float array_y[],int number)

{
	int g_driver,g_mode;
	int maxx,maxy;
	int left,top,right,bottom;
	int number_x,number_y;
	int pixel_x,pixel_y,i;
	int maxcolor;
	int color_strip=1;
	float max_array,min_array,dx,dy,dob_x,dob_y;
	int kris,ip;
	static float ris[10];
	float num_ip;
	int ik,strih;
	char bufer[8];
	char text[]=" Copyright 1992. Litvinov M.A.";

/* Опpеделение типа адаптеpа */
	detectgraph (&g_driver,&g_mode);

/* Инициализация графической системы */
	initgraph (&g_driver,&g_mode,"");

/*  Проверка ошибок инициализации */
	graph_error();
/* Определение максимального количества цветов */
	maxcolor=getmaxcolor()+1;
/* Задание фона и активного цвета графика */
	if( maxcolor > 2 )
	{
	  setbkcolor(BLUE);
	  setcolor(YELLOW);
	  color_strip=14;
	  }
	graph_error(); //проверка ошибок установки цвета

/* Определение максимальной разрешающей способности экрана  */
	maxx=getmaxx (); /* по оси x */
	maxy=getmaxy (); /* по оси y */

/* Определение  границ для построения внутренней рамки */
	left= maxx * 0.08; /* левая граница */
	top= maxy * 0.05; /* верхняя граница */
	right= maxx - maxx * 0.02; /* правая граница */
	bottom= maxy - maxy * 0.15; /* нижняя граница */


/* Определение новой разрешающей способности экрана */
	number_x= right - left; /* по оси x */
	number_y= bottom - top; /* по оси y */

/* Построение внешней рамки */
	lineto (maxx,0);
	lineto (maxx,maxy);
	lineto (0,maxy);
	lineto (0,0);

/* Построение внутренней координатной рамки */
	moveto (left,top);
	lineto (right,top);
	lineto (right,bottom);
	lineto (left,bottom);
	lineto (left,top);

/* Вывод автоpского соглашения*/
	outtextxy (8,maxy-8,text);

/* Определение масштабных козффициентов для оси X */
	search_maxmin (&max_array,&min_array,array_x,number);
	porno (&max_array,&min_array,&kris,ris,&ip,&num_ip);

	dx= number_x / (max_array - min_array); /* козф. по оси x */
	dob_x= min_array * dx; /* добавочный козф. */

/* Разметка оси X */

	for (ik=0;ik<=kris;ik++)     /* расстановка штрипков */
	{
	 pixel_x=left+ris[ik] * dx - dob_x;
	 strih=0;
	 while(strih < 8)
	   {
	     putpixel(pixel_x,bottom-strih,color_strip);
	     strih++;
	    }

/* Преобразование массива эначений в символьное представление */
	 gcvt (ris[ik],8,bufer);

/* Подпись эначений под штрипками */
	 outtextxy (pixel_x,bottom+8,bufer);
	  }

/*  Определение масштабных коэффициентов для оси  Y */
	search_maxmin (&max_array,&min_array,array_y,number);
	porno (&max_array,&min_array,&kris,ris,&ip,&num_ip);

	dy= number_y / ( max_array - min_array ); /* козф. по оси y */
	dob_y= min_array * dy; /* добавочный козф. */

/* Разметка оси Y */
	for (ik=0;ik<=kris;ik++)    /* расстановка штрипков */
	{
	  pixel_y=bottom-(ris[ik] * dy - dob_y);
	  strih=0;
	  while(strih <10)
	  {
	   putpixel(left+strih,pixel_y,color_strip);
	   strih++;
	   }

/* Преобразование массива эначений в символьное представление */
	 gcvt (ris[ik],4,bufer);

/* Подпись эначений под штрипками */
	 outtextxy (left-37,pixel_y,bufer);

	 }

/* Построение графика */
	pixel_x= left + array_x[0] * dx - dob_x;
	pixel_y= bottom - (array_y[0] * dy - dob_y);
	moveto (pixel_x,pixel_y);

	for ( i=0; i < number; i++ )
	{
	  pixel_x= left + array_x[i] * dx - dob_x;
	  pixel_y= bottom - (array_y[i] * dy - dob_y);
	  lineto (pixel_x,pixel_y);
	  }


/* конец */
	getch();
	cleardevice();
	closegraph();
 }

/* Подпрограмма поиска максимального и минимального чисел */
/*  во входном массиве */
	void search_maxmin (float *max,float *min,float array[],int number)

	{
	  int i;

	 *max=array[0];
	 *min=array[0];
/* поиск максимума и минимума */
	  for ( i=0; i < number; i++ )
	  {
	    if ( array[i] >= *max )  *max=array[i];
	    if ( array[i] <= *min )  *min=array[i];
	    }
	  }

/* Подпрограмма определения порядка массива, кол-ва рисок на оси */
/* maссива значений , соответствующих рискам и хороших значений */
/* максимума и минимума */

	void porno (float *max,float *min,int *kris,float ris[],int *ip,float *num_ip)
	{
	  float max_real,max_mas,min_mas;
	  float dobavka,abs_max,abs_min,epsilon;
	  int ipok;
	  float kris_min,kris_max,kris_dob;
	  int ik;

/*  Увеличиваем диапаэон эначений массива на 10% */

	  dobavka=0.1 * (*max - *min);
	  if ( *max > 0.0 ) max_mas= *max + dobavka;
	     else max_mas= *max;
	  if ( *min < 0.0 ) min_mas= *min - dobavka;
	     else min_mas= *min;

/* Находим абсолютный максимум массива */
	  abs_max=abs (max_mas);
	  abs_min=abs (min_mas);
	  if ( abs_max >= abs_min ) max_real=abs_max;
	     else max_real=abs_min;

/* определение порядка */
	  for ( ipok=10 ; ipok >=- 10   ; ipok--)
	  {
	    if ( max_real > pow10(ipok) ) goto goal;
	    }
 goal:      /* порядок найден */

/*  дискрет значений для рисок */
	  *ip=ipok;
	  *num_ip=pow10(*ip);

/*  Найдем кол-во рисок от мин. и от макс. */
	  kris_min= min_mas/ (*num_ip);
	  kris_max= max_mas/ (*num_ip);

/* Определяем новый хороший максимум */
	  if (*max < 0.0 ) epsilon= *max + dobavka - kris_max* (*num_ip);
	    else epsilon=kris_max* (*num_ip) - (*max);
	  kris_dob=epsilon/(*num_ip);

	  if (kris_dob >=2) kris_max=kris_max-kris_dob/2;
	  *max= kris_max* (*num_ip);

/*  Определяем новый хороший минимум */
	  if (*min > 0.0) epsilon=kris_min* (*num_ip) -(*min) +dobavka;
	    else epsilon=*min - kris_min* (*num_ip);
	  kris_dob=epsilon/(*num_ip);
	  if (kris_dob >=2) kris_min=kris_min - kris_dob/2;
	  *min= kris_min* (*num_ip);

/*  определяем кол-во рисок исходя иэ диапаэона эначений массива */
	  *kris=1 + (*max - *min)/ *num_ip;

/* уточним кол-во рисок */
	  while ( *kris > 10 )  /* если рисок много */
	  {
	    *num_ip=(*num_ip)*2;
	    *kris= (*max - *min)/ *num_ip;
	    }

	  while ( *kris <= 2 ) /*  если рисок мало */
	  {
	    *num_ip= *num_ip/2;
	    *kris= (*max - *min)/ *num_ip;
	    }
/*  Найдем эначения соответствующие рискам */
	  ris[0]= *min;
	  for ( ik=1; ik <= *kris; ik++)
	    {
	     ris[ik]=ris[0] + (ik-1) * (*num_ip);
	     }

	  }
/*  Подпрограмма обработки ошибок */
	void graph_error(void)
	{
	int g_error;

	g_error=graphresult ();
	if (g_error < 0 )
	{
	  printf("Initgraph error %s \n",grapherrormsg(g_error) );
	  exit(1);
	  }

	 }