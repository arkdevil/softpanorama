/*--------------------------------------------------*
* Файл TASK_1.CPP                                   *
* автор : Ушаров В.В.                               *
* Программа для теста по введенному тексту          *
* Дата  :    09.1992                                *
----------------------------------------------------*/
#include <ui_win.hpp>
#include "matr.hpp"

//----------------------<<<<<<<<<<<<<<<>>>>>>>>>>>>>>---------------\\
TASK1::TASK1
(char *_input[],int _MaxInput,
			char *_output[],int _MaxOutput,
					char *_filename,char *_header)  :
	TEST(_input,_MaxInput,
                        _output,_MaxOutput,
                                        _filename,_header)
{
}
//----------------------<<<<<<<<<<<<<<<>>>>>>>>>>>>>>---------------\\
void TASK1::Work(int res)
{
if (res == HAVE_IT ) numer++;
        if (current < 12) {
                current++;
		text->DataSet(input[current],2000);
		  }
else   //exceed
	{
	flag = TO_PRN;
		if (numer >= 7 )
                        text->DataSet(output[2],2000);//current=2;
		else if (numer > 1)
                        text->DataSet(output[1],2000);//current=1;
		else if (numer <= 1 )
                        text->DataSet(output[0],2000);//current=0;

	}
}
//----------------------<<<<<<<<<<<<<<<>>>>>>>>>>>>>>---------------\\

