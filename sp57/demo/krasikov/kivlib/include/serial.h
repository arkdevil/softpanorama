/***************************************************************/
/*                                                             */
/*              KIVLIB include file  SERIAL.H                  */
/*                                                             */
/*                                                             */
/*        Copyright (c)  1993   by  KIV without Co             */
/***************************************************************/
#ifndef  ___SERIAL_H___
#define  ___SERIAL_H___


#ifdef __cplusplus

extern "C" {

#endif

unsigned int far cdecl GetSerialPort(int Num);

unsigned char far cdecl InitSerial(unsigned int Port, long speed, unsigned char flags);

unsigned char far cdecl StatusSerial(unsigned int Port);

int far cdecl OKtoSendSerial(unsigned int Port);

void far cdecl SendSerial(unsigned int Port, unsigned char A);

int far cdecl OKtoReceiveSerial(unsigned int Port);

unsigned char far cdecl ReceiveSerial(unsigned int Port);

int far cdecl ConnectSerial(unsigned int Port, int Kbd, int del);
//return 0 - OK
//       1 - KBD interrupt
//       2 - 1 min interrupt

int far cdecl MainSerial(unsigned int S);
// after Connect - immediately!

void far cdecl SendBuffer(unsigned int Port, void far * buf, unsigned int count);

void far cdecl ReceiveBuffer(unsigned int Port, void far * buf, unsigned int count);


#ifdef __cplusplus
}
#endif

#endif

