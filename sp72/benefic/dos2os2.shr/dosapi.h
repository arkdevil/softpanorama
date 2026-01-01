#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define MAX_ERRORS 10

const char VDD_NAME[10] = "DOSAPI";
long VDD_API;
int  RETURN_CODE;

typedef struct {
	unsigned int Sess_Struct_Len; /* Must be 0x18,0x1E,0x20,0x32, or 0x3C */
	unsigned int Sess_Relation; /* 00 independent, 01 child */
	unsigned int Sess_Fore_Back; /* 00 foreground, 01 background */
	unsigned int Sess_Trace; /* 00-02, 00 = no trace */
	char far *Sess_Program_Title; /* max 62 chars or 0000:0000 */
	char far *Sess_Program_Name; /* max 128 chars or 0000:0000 */
	char far *Sess_Program_Args; /* max 144 chars or 0000:0000 */
	unsigned long Sess_Term_Queue; /* reserved, must be 00000000 */
	char far *Sess_Environment; /* max 486 bytes or 0000:0000 */
	unsigned int Sess_Inheritance; /* 00 or 01 */
	unsigned int Sess_Type;
			/* 	00 OS/2 session manager determines type (default)
				01 OS/2 full-screen
				02 OS/2 window
				03 PM
				04 VDM full-screen
				07 VDM window
			*/
	char far *Sess_Icon_Filename; /* max 128 chars or 0000:0000 */
	unsigned long Sess_Pgm_Handle; /* reserved, must be 00000000 */
	unsigned int Sess_Pgm_Control;
	unsigned int Sess_Column;
	unsigned int Sess_Row;
	unsigned int Sess_Width;
	unsigned int Sess_Height;
	unsigned int Sess_Reserved; /* 0x00 */
	unsigned long Sess_Object_Buffer; /* reserved, must be 00000000 */
	unsigned long Sess_Object_BufferLen; /* reserved, must be 00000000 */
} Session_Data;

unsigned int Dos32CreatEventSem( char far *, unsigned long far *,
			 unsigned long, unsigned char );

unsigned int Dos32OpenEventSem( char far *, unsigned long far * );

unsigned int Dos32CloseEventSem( unsigned long );

unsigned int Dos32PostEventSem( unsigned long );

unsigned int Dos32ResetEventSem( unsigned long, unsigned int far * );

unsigned int Dos32QueryEventSem(unsigned long, unsigned int far * );

unsigned int Dos32WaitEventSem(unsigned long, unsigned char );

unsigned int DosStartSession(Session_Data far *);

unsigned int DosApi_Send(char far *, short, short);

unsigned int DosApi_Recv(char far *, short, short);

unsigned int DosApi_Update(char far *, short, short);

unsigned int DosApi_Read(char far *, short, short);

unsigned int DosApi_Reset();

unsigned int DosApi_Sleep(short);


