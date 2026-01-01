#define INCL_DOSMVDM
#define INCL_BASE
#define INCL_DOSPROCESS
#define MAX_ERRORS 10

#include <os2.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

unsigned int DosApi_Send(PVOID, SHORT, SHORT);

unsigned int DosApi_Recv(PVOID, SHORT, SHORT);

unsigned int DosApi_Update(PVOID, SHORT, SHORT);

unsigned int DosApi_Read(PVOID, SHORT, SHORT);

unsigned int DosApi_Reset();


