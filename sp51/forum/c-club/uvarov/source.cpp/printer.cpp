/*--------------------------------------------------*
* Файл PRINTER.CPP                                  *
* автор : Ушаров В.В.                               *
* Дата  :    09.1992                                *
* Организация работы с принтером типа ЕPSON         *
----------------------------------------------------*/
#if !defined( __BIOS_H )
#include <bios.h>
#endif

#ifndef __STDIO_H
#include <stdio.h>
#endif

#ifndef __STRING_H
#include <string.h>
#endif

#ifndef __DOS_H
#include <dos.h>
#endif

#ifndef __IO_H
#include <io.h>
#endif

#ifndef __STAT_H
#include <sys\stat.h>
#endif


#if !defined( __FCNTL_H )
#include <fcntl.h>
#endif

#ifndef __PRINTER_HPP
#include "printer.hpp"
#endif

#ifndef PRN_LPT1
#define PRN_LPT1 0
#endif
//----------------------------------------------------//
PRINTER::PRINTER(int _mask , int _portnum )
{
	portnum=_portnum;
	status=CheckPrinter();
	tick = 0;
	mask = _mask;
}
//----------------------------------------------------//
void PRINTER::Show(char *str) //show response
{
	printf("%s",str);
}

//----------------------------------------------------//
int     PRINTER::CheckPrinter(int cmd,int _abyte)
{
//work throw the BIOS interrupt N17

int abyte = _abyte;

	//check for present printer before
	status=peek(0x0040,0x0010);
	if ( (status & 0xc000) == 0)
			{
                        Show("\n\n\n\t У вас нет принтера в Вашей \n \
                                копнфигурации  ");
			return PRN_NOT_ATTACHED;
			 }
	//Get status printer
status = 0; //init zero for next check !
   status = biosprint(cmd, abyte, portnum);

   if (status & 0x01)       {
//	Show("/Device time out.");
	status |= PRN_TIME_OUT;
}
   if (status & 0x08) {
//	Show("\nI/O error.\n");
	status |= PRN_IO_ERROR;
}
   if (status & 0x10)
{
//	Show("\nOn line.\n");
	status |= PRN_ON_LINE;
	}
	else
{
//	Show("Off line\n");
	status |= PRN_OFF_LINE;
	}


   if (status & 0x20)
{
//	Show("Out of paper.\n");
	status |= PRN_OUT_OF_PAPER;
				  }

   if (status & 0x40)
{
//	Show("Acknowledge.\n");
	status |= PRN_ATTACHED;
	}


   if (status & 0x80)
{
//	Show("Not busy.\n");
	status |= PRN_NOT_BUSY;
	}
	else
{
//	Show("Busy\n");
	status |= PRN_BUSY;
	}
return status;
}
//----------------------------------------------------//
int PRINTER::GetRecomendation(void)
{
CheckPrinter();//GetStatus();

	if (
      (status & PRN_NOT_ATTACHED)
	   )
	{
       if (!mask)
                        Show("\n\n\n\t У вас нет принтера в Вашей \n \
                                копнфигурации  ");
	return PRN_CANCEAL;
	}

       if (
      (status & PRN_IO_ERROR) &&
      (status & PRN_ATTACHED) &&
      (status & PRN_OFF_LINE) &&
      (status & PRN_NOT_BUSY)
	 )
	{
	if (before != TURN_ON) {
	before =TURN_ON;
        Show("\rВключите Ваш принтер пожайлуста");
	}
	return PRN_WAIT;
	}

       if (
      (status & PRN_BUSY) &&
      (status & PRN_IO_ERROR) &&
      (status & PRN_ON_LINE)  &&
      !(status & PRN_OUT_OF_PAPER)
	 )
	{
	if (before != SWITCH_ON) {
	before =SWITCH_ON;
        Show("\rНажмите кнопку ON LINE на Вашем принтере. \
                Побыстрее ");
	}
	return PRN_WAIT;
	}

	if (
	(status & PRN_ON_LINE)  &&
	(status & PRN_NOT_BUSY)
	   )
	   {
         Show("\rПечать ...");
	   return PRN_CONTINUE;
	}
	if  (
	(status & PRN_BUSY)   &&
	(status & PRN_ON_LINE)  &&
	(status & PRN_OUT_OF_PAPER)
	    )
	{
	if (before != INSERT_PAPER) {
	before =INSERT_PAPER;
        Show("\rВставте бумагу между управляющими \n \
                кромками в щель принтера");
	}
	return PRN_WAIT;
	}
return status;
}
//----------------------------------------------------//
int PRINTER::DesireAction(void )       //desire action of programm
{
int sts=GetRecomendation();  // Small information
//tick = 0;
switch (sts) {
	case PRN_WAIT:

		if (tick > 25000 ) {
			for (int i=200;i <350; i+=50) {
				sound(i); delay(i);nosound();
//				sound(500); delay(100);nosound();
			}
//			Show("\nprinter a very busy \n");
			tick=0;
			}
		tick++;
	return PRN_WAIT;
	break;
	case PRN_CANCEAL:
	case PRN_CONTINUE:
	return sts;
	break;
}
return 0;
}

//----------------------------------------------------//
int PRINTER::Put(void *data , int name)
{
/*
const int PRN_INT   = 0x8;
const int PRN_LONG  = 0x16;
const int PRN_ULONG = 0x32;
const int PRN_UINT  = 0x64;
*/
char str[8];
str[0]='\0';
//int sts=DesireAction();  // Small information
switch(DesireAction()) {
	case PRN_CANCEAL:case PRN_WAIT:
		return 0; break;
	case PRN_CONTINUE:
		break;
}

	switch(name) {
		case PRN_CHAR:
			char a=(char )data;
			return CheckPrinter(0,a);
		break;
		case PRN_UCHAR:
			unsigned char b=(unsigned char )data;
			return CheckPrinter(0,b);
		break;
		case PRN_STRING:
			char *str1=(char *)data;
				if (portnum != PRN_LPT1)
					for (int i=0;
						i<strlen(str1);
							i++)
						CheckPrinter(0,str1[i]);
				else if ( fprintf(stdprn,str1)  == EOF )
					{
					Show("\nСожалею , но из-за ошибки в аппаратуре  \
						дальнейшая распечатка невозможна  ");
					status |= PRN_TERMINATED;
					return PRN_CANCEAL;
					}
		break;
		case PRN_INT:
				sprintf(str,"%d",(int )data);
				Put(str,PRN_STRING);
		break;
		case PRN_UINT:
				sprintf(str,"%u",(unsigned int )data);
				Put(str,PRN_STRING);
		break;
		case PRN_LONG:
				sprintf(str,"%ld",(long )data);
				Put(str,PRN_STRING);
		break;
		case PRN_ULONG:
				sprintf(str,"%ld",(unsigned long )data);
				Put(str,PRN_STRING);
		break;
	}
return 0;
}
//----------------------------------------------------//
