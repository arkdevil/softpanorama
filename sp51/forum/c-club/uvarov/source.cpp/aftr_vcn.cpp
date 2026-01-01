/*--------------------------------------------------*
* Файл AFTR_VCN.CPP                                 *
* автор : Ушаров В.В.                               *
* Программа для теста по введенному тексту          *
* Дата  :    09.1992                                *
----------------------------------------------------*/
#include <ui_win.hpp>
#include "sens.hpp"
#include "global.hpp"
#include <math.h>


AFTER_VOCANCY::AFTER_VOCANCY(char *_input[],int _MaxInput,
			     char *_output[],int _MaxOutput,
				 char *_header ,
			     char *prompt1, char *prompt2,char *prompt3 ,
			     char *_filename)  :
SENS(_input,_MaxInput,
	_output,_MaxOutput,
		_header ,
	prompt1,prompt2,prompt3 ,
	_filename)
{
//initialization of answer matrix in CLASS
	for (int j=0; j<3;j++)
	rezult[j]=0;

}
void AFTER_VOCANCY::Work(int res)
{
if (current == -1)
	for (int j=0; j<3;j++)
		rezult[j]=0;
switch(res) {
	case A_BUTTON:
		switch(current) {
			case 0: rezult[WHITE_CIRCLE] += 10; break; //1
			case 1: rezult[WHITE_CIRCLE] +=10; break; //2:
			case 2: rezult[WHITE_CIRCLE] +=10; break; //3:
			case 3: rezult[POINT_CIRCLE] +=10; break; //4:
			case 4: rezult[POINT_CIRCLE] +=10; break; //5:
			case 5: rezult[WHITE_CIRCLE] +=10; break; //6:
			case 6: rezult[POINT_CIRCLE] +=10; break; //7:
			case 7: rezult[WHITE_CIRCLE] +=10; break; //8:
			case 8: rezult[POINT_CIRCLE] +=10; break; //9:
			case 9: rezult[WHITE_CIRCLE] +=10; break; //10
			case 10:rezult[WHITE_CIRCLE] +=10; break; //11
			case 11:rezult[POINT_CIRCLE] +=10; break; //12
			case 12:rezult[WHITE_CIRCLE] +=10; break; //13
			case 13:rezult[WHITE_CIRCLE] +=10; break; //14
			}
	break;
	case B_BUTTON:
		switch(current) {
			case 0: rezult[POINT_CIRCLE] +=10; break; //1
			case 1: rezult[POINT_CIRCLE] +=10; break; //2:
			case 2: rezult[POINT_CIRCLE] +=10; break; //3:
			case 3: rezult[WHITE_CIRCLE] +=10; break; //4:
			case 4: rezult[WHITE_CIRCLE] +=10; break; //5:
			case 5: rezult[POINT_CIRCLE] +=10; break; //6:
			case 6: rezult[WHITE_CIRCLE] +=10; break; //7:
			case 7: rezult[POINT_CIRCLE] +=10; break; //8:
			case 8: rezult[WHITE_CIRCLE] +=10; break; //9:
			case 9: rezult[POINT_CIRCLE] +=10; break; //10
			case 10:rezult[POINT_CIRCLE] +=10; break; //11
			case 11:rezult[WHITE_CIRCLE] +=10; break; //12
			case 12:rezult[POINT_CIRCLE] +=10; break; //13
			case 13:rezult[POINT_CIRCLE] +=10; break; //14
			 }
	break;
	case C_BUTTON:
		rezult[FULL_CIRCLE] += 10;  //from 0 to 14
	break;
       }

if (current < (MaxInput-1)) {
	current++;
	text->DataSet(input[current],2000);
		  }
else   //exceed
	{
	flag = TO_PRN;


int first,second,third;
first=0;
second=0;
third=0;
// A == B < C
		if (
(rezult[WHITE_CIRCLE] == rezult[POINT_CIRCLE])
&& (rezult[FULL_CIRCLE] > rezult[POINT_CIRCLE])
			)
			{
				first  = FULL_CIRCLE;
				second = WHITE_CIRCLE;
				third  = POINT_CIRCLE;
			}
// A == B == C
		if (
(rezult[WHITE_CIRCLE] == rezult[POINT_CIRCLE])
&& (rezult[FULL_CIRCLE] == rezult[POINT_CIRCLE])
			)
			{
				first  = WHITE_CIRCLE;
				second = POINT_CIRCLE;
				third  = FULL_CIRCLE;
			}
// A == B > C
else if (
(rezult[WHITE_CIRCLE] == rezult[POINT_CIRCLE])
&& (rezult[FULL_CIRCLE] < rezult[POINT_CIRCLE])
			)
			{
				first  = WHITE_CIRCLE;
				second = POINT_CIRCLE;
				third  = FULL_CIRCLE;
			}
// A < B == C
else if (
(rezult[POINT_CIRCLE] == rezult[FULL_CIRCLE ]) &&
(rezult[WHITE_CIRCLE] < rezult[POINT_CIRCLE])
			)
			{
				first  = POINT_CIRCLE;
				second = FULL_CIRCLE;
				third  = WHITE_CIRCLE;
			}
// A > B == C
else if (
(rezult[POINT_CIRCLE] == rezult[FULL_CIRCLE ]) &&
(rezult[WHITE_CIRCLE] > rezult[POINT_CIRCLE])
			)
			{
				first  = WHITE_CIRCLE;
				second = POINT_CIRCLE;
				third  = FULL_CIRCLE;
			}
// A > B > C
else if (
(rezult[WHITE_CIRCLE] > rezult[POINT_CIRCLE ])  &&
(rezult[POINT_CIRCLE] > rezult[FULL_CIRCLE])
			)
			{
				first  = WHITE_CIRCLE;
				second = POINT_CIRCLE;
				third  = FULL_CIRCLE;
			}
// A < B < C
else if (
(rezult[WHITE_CIRCLE] < rezult[POINT_CIRCLE ])  &&
(rezult[POINT_CIRCLE] < rezult[FULL_CIRCLE])
			)
			{
				first  = FULL_CIRCLE;
				second = POINT_CIRCLE;
				third  = WHITE_CIRCLE;
			}
// A < B > C
else if (
(rezult[WHITE_CIRCLE] < rezult[POINT_CIRCLE ])  &&
(rezult[POINT_CIRCLE] > rezult[FULL_CIRCLE])
			)
			{
// A < C

	if (
		(rezult[WHITE_CIRCLE] < rezult[FULL_CIRCLE ])
			)      {
				first  = POINT_CIRCLE;
				second = FULL_CIRCLE;
				third  = WHITE_CIRCLE; }
// A > C
	if (
		(rezult[WHITE_CIRCLE] > rezult[FULL_CIRCLE ])
			)      {
				first  = POINT_CIRCLE;
				second = WHITE_CIRCLE;
				third  = FULL_CIRCLE;  }
			}
// A > B < C
else if (
(rezult[WHITE_CIRCLE] > rezult[POINT_CIRCLE ])  &&
(rezult[POINT_CIRCLE] < rezult[FULL_CIRCLE])
			)
			{
// A < C
	if (
		(rezult[WHITE_CIRCLE] < rezult[FULL_CIRCLE ])
			)      {
				first  = FULL_CIRCLE;
				second = WHITE_CIRCLE;
				third  = POINT_CIRCLE;  }
// A > C
	if (
		(rezult[WHITE_CIRCLE] > rezult[FULL_CIRCLE ])
			)      {
				first  = WHITE_CIRCLE;
				second = FULL_CIRCLE;
				third  = POINT_CIRCLE; }
			}

/////////////////////////////////
// A B C
		if(
			(first==WHITE_CIRCLE)  &&
			(second == POINT_CIRCLE) &&
			(third == FULL_CIRCLE)
		)
			text->DataSet(output[1],2000);//current=2;
// B C A
		else if (
			(first  == POINT_CIRCLE )  &&
			(second == FULL_CIRCLE  ) &&
			(third  == WHITE_CIRCLE )
		)
			text->DataSet(output[5],2000);//current=1;
// B A C
		else if (
			(first  == POINT_CIRCLE )  &&
			(second == WHITE_CIRCLE ) &&
			(third  == FULL_CIRCLE  )
		)
			text->DataSet(output[4],2000);//current=1;
// C B A
		else if (
			(first  == FULL_CIRCLE )  &&
			(second == POINT_CIRCLE ) &&
			(third  == WHITE_CIRCLE  )
		)
			text->DataSet(output[3],2000);//current=1;
// C A B
		else if (
			(first  == FULL_CIRCLE )  &&
			(second == WHITE_CIRCLE ) &&
			(third  == POINT_CIRCLE  )
		)
			text->DataSet(output[2],2000);//current=1;
// A C B
		else if (
			(first  == WHITE_CIRCLE )  &&
			(second == FULL_CIRCLE ) &&
			(third  == POINT_CIRCLE  )
		)
			text->DataSet(output[0],2000);//current=1;

	}
}
