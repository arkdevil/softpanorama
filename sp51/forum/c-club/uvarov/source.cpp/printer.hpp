/*--------------------------------------------------*
* Файл PRINTER.HPP                                  *
* автор : Ушаров В.В.                               *
* Дата  :    09.1992                                *
* Организация работы с принтером типа ЕPSON         *
----------------------------------------------------*/
#ifndef __PRINTER_HPP
#define __PRINTER_HPP

//for check prn
const int PRN_TIME_OUT     = 0x02;
const int PRN_IO_ERROR     = 0x04;
const int PRN_ON_LINE      = 0x08;
const int PRN_OFF_LINE     = 0x10;
const int PRN_OUT_OF_PAPER = 0x20;
const int PRN_BUSY         = 0x40;
const int PRN_NOT_BUSY     = 0x80;
const int PRN_NOT_ATTACHED = 0x200;
const int PRN_ATTACHED     = 0x120;
const int PRN_NOISE     = 0x300;
const int PRN_TERMINATED     = 0x400;

//for recomendations
const int PRN_CANCEAL   = 0x2;
const int PRN_ABORT     = 0x4;
const int PRN_CONTINUE  = 0x8;
const int PRN_WAIT      = 0x16;

//for object prn
const int PRN_STRING  = 0x20;
const int PRN_CHAR  = 0x2;
const int PRN_UCHAR = 0x4;
const int PRN_INT   = 0x8;
const int PRN_LONG  = 0x16;
const int PRN_ULONG = 0x32;
const int PRN_UINT  = 0x64;

const int TURN_ON      = 0x680;
const int SWITCH_ON    = 0x740;
const int INSERT_PAPER = 0x840;

class PRINTER {
	int status;
	int portnum; //0 -LPT1 1 - LPT2 etc;
	int tick; int mask;
public:
        int before,after;             //switches for work with PRN
	PRINTER(int _mask = 0 , int _portnum=0);
	int GetStatus(void) {return status;}
	int CheckPrinter(int cmd=2,int _abyte=0);       //check printer
        int GetRecomendation(void);   //recomendation for work with thim
        int DesireAction(void);       //desire action 
	virtual void Show(char *str); //show response
        int Put(void *data , int name=PRN_STRING);
};
#endif
