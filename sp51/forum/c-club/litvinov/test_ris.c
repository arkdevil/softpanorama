/* Пример использования подпрограммы risynok.c */

#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include "risynok.h"
void main(void)
{
	static float mas_x[100],mas_y[100];
	int number=100;
	int i;

	for  ( i=0; i < number; i++ )
	{
	  mas_x[i]=i;
	  mas_y[i]=pow(4.5,exp(i*0.01))*sin(3.1415*(20*i)/180);
	  }
	risynok (mas_x,mas_y,number);
	printf("  Конец программы вывода графика\n ");
 }

