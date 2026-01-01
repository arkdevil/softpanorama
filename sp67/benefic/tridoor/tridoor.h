/*
	tridoor.h - TriDoor header file
	Copyright (c) 1992 By Mark Goodwin
*/
#ifndef __TRIDOORH__
#define __TRIDOORH__

#define BLACK 0
#define BLUE 1
#define GREEN 2
#define CYAN 3
#define RED 4
#define MAGENTA 5
#define BROWN 6
#define LIGHTGRAY 7
#define DARKGRAY 8
#define LIGHTBLUE 9
#define LIGHTGREEN 10
#define LIGHTCYAN 11
#define LIGHTRED 12
#define LIGHTMAGENTA 13
#define YELLOW 14
#define WHITE 15

extern char TDUserName[81], TDUserFirstName[81], TDDoorName[81];
extern char TDCityState[81], TDPhoneNumber[81], TDBBSName[81];
extern char TDSysopName[81], TDAlias[81];
extern int TDAnsiColor, TDSecurityLevel, TDMinutesLeft;
extern int TDSerialPort, TDNode, TDErrorCorrecting;
extern long TDBaudRate, TDLockedBaudRate;
extern void (*TDDropToDOS)(void);
extern int TDNonStandardIRQ;

#ifdef __cplusplus
extern "C" {
#endif
void TDClrScr(void);
void TDDisplayFile(char *);
void TDDisplayBreakableFile(char *);
int TDGetBackground(void);
int TDGetForeground(void);
int TDGetch(void);
char *TDGets(char *);
void TDGotoXY(int, int);
void TDInitialize(void);
int TDKeyPressed(void);
void TDHangUp(void);
int TDPrintf(char *, ...);
void TDPutch(int);
void TDPuts(char *);
void TDSetColor(int, int);
int TDTimeLeft(void);
int TDTimeOn(void);
#ifdef __cplusplus
}
#endif

#endif
