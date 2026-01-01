/*--------------------------------------------------*
* Файл TASK_3.CPP                                   *
* автор : Ушаров В.В.                               *
* Программа для теста по введенному тексту          *
* Дата  :    09.1992                                *
----------------------------------------------------*/
#include <ui_win.hpp>
#include "matr.hpp"
#include <string.h>

TASK3::TASK3
(char *_input[],int _MaxInput,
			char *_output[],int _MaxOutput,
					char *_filename,char *_header)  :
	TEST(_input,_MaxInput,
			_output,_MaxOutput,
					_filename,_header)
{
//initialization of answer matrix in CLASS
for (int i=0; i < 12;i++)
answer[i]=HAVE_NOT;
}
//----------------------<<<<<<<<<<<<<<<>>>>>>>>>>>>>>---------------\\
void TASK3::Work(int res)
{
if (current >= 0)       answer[current]=res;
if (res == HAVE_IT )    numer++;
	if (current < 10) {
		current++;
		text->DataSet(input[current],2000);
		  }
else   //exceed
	{
	char GetOut[2000];
	GetOut[0]='\0';
	strcpy(GetOut,"Может это Вас заинтересует ; \n");
//initialization of printer & asciifile classes
	flag = TO_PRN;
	if (
		(answer[0] == HAVE_IT)      &&  (answer[1] == HAVE_IT)
		&&   (answer[2] == HAVE_IT) &&  (answer[3] == HAVE_IT)
		&&   (answer[4] == HAVE_IT) &&  (answer[5] == HAVE_IT)
		&&   (answer[6] == HAVE_IT) &&  (answer[7] == HAVE_IT)
		&&   (answer[8] == HAVE_IT) &&  (answer[9] == HAVE_IT)
	)
		{
			strcat(GetOut,output[0]);
		}
	if
		(answer[1] == HAVE_IT)
		{
			strcat(GetOut,output[1]);
		}
	if (
		(answer[3] == HAVE_IT)      &&  (answer[7] == HAVE_IT)
			&&   (answer[8 ] == HAVE_IT)
	)
                {
			strcat(GetOut,output[2]);
		}
	if (
		(answer[2] == HAVE_IT)      &&  (answer[4] == HAVE_IT)
		&&   (answer[5] == HAVE_IT) &&  (answer[9] == HAVE_IT)
	)
                {
			strcat(GetOut,output[3]);
		}
	if
		(answer[10] == HAVE_NOT)
		{
		strcat(GetOut,output[4]);
		}

      strcat(GetOut,output[5]);
			text->DataSet(GetOut,2000);//current=0;
	}
return;
}
//----------------------<<<<<<<<<<<<<<<>>>>>>>>>>>>>>---------------\\

