/***********************************************************************
	   Тест - перемножение матриц.   А.П.+ П.А. Северовы, 1989.
***********************************************************************/

#include <dos.h>
#include <math.h>
#include <stdio.h>
#include <float.h>


float Time()
{
struct time s;float t;
  gettime(&s);
  /*printf(" %i.%i.%i.%i\n",s.ti_hour,s.ti_min,s.ti_sec,s.ti_hund);*/
  t=(((((s.ti_hour*60.0)+s.ti_min)*60.0)+s.ti_sec)*100.0+s.ti_hund)/100.0;
  return(t);
}

main()
{
double A[41][41],B[41][41],C[41][41],S;
float StartTime,FinishTime;
int i,j,k,n;



  n=41;

  for (i=1; i<n; i++)   { for (j=1; j<n; j++)  A[i][j]=2.0/(i*j); }
  for (i=1; i<n; i++)   { for (j=1; j<n; j++)  B[i][j]=2.0*i*j; }

  StartTime=Time();

  for (k=1; k<n; k++)   { for (j=1; j<n; j++)
			 { S=0; for (i=1; i<n; i++)
			 { S=S+A[k][i]*B[i][j]; C[k][j]=S; }}}

  FinishTime=Time();

  for (j=1; j<5; j++)    { for (k=1; k<3; k++)  printf(" %f\n",C[k][j]); }

  printf("Время=%f ceк.\n",FinishTime-StartTime);
  scanf("Нажми клавишу + Enter ");

  }


