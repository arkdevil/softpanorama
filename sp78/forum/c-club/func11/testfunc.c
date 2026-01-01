#include <stdio.h>
#include <stdlib.h>
#include "funcion.h"

char function_name[1024];
void *function;
int err=0;

void error(char *s, int cursor)
{
	int i;

	printf("Error:%s\n",s);
	printf("f(x)=%s\n", function_name);
	printf("     ");
	for(i=0;i<cursor;i++) printf(" ");printf("^\n");
	err=1;
}

void main(void)
{
	printf("Introduce f(x): ");
	gets(function_name);
	printf("\n");
	function=function_create(function_name);
	function_syntax_check(function, error);
	if (err) exit(-1);
	printf("f(x)=%s\n",function_name);
	{
		int i;
		double x;

		for (i=0;i<5;i++)
		{
			x=i;
			printf("x=%lf\n",x);
			printf("f(x)=%lf\n",function_calculate(x, function));
		}
	}
	function_destroy(function);
}
