/*
	BarClock(tm)

	DDE Library v1.0

	Copyright (c) 1995  Patrick Breen
	All rights reserved.

	Requires BarClock/BarClock PLUS v4.0 or later.

	Atomic Dog Software
	PO Box 523
	Medford, MA 02155

	Phone (617) 396-2673
	Fax   (617) 396-5761

	Internet:			pbreen@world.std.com
	CompuServe: 		70312,743
	America Online: 	PBreen

	FTP:	 ftp.std.com	/vendors/AtomicDog
*/
#ifndef _BCDDELIB_H
#define _BCDDELIB_H

#ifndef STRICT
  #define STRICT
#endif

#include <windows.h>

// Include common definitions
#include "bccommon.h"

// Error codes
#define BCDDE_NOERROR		0
#define BCDDE_MULTIPLEINIT	1
#define BCDDE_INITFAIL		2
#define BCDDE_NOINIT		3
#define BCDDE_EXECFAIL		4
#define BCDDE_HOSTFAIL		5

// Declare commands
#undef DDECommand
#define DDECommand(a)	eCmd##a,

enum BCDdeCommand {

	#include "bcddestr.h"
	eCmdLast
};

// Globals
extern DWORD idInst;

// Init
short BCDdeLibInit(FARPROC lpfnCallback, DWORD afCmd);
void BCDdeLibFree(void);

// Utility
char FAR *BCDdeString(short id);
short BCDdeExecute(char FAR *pCommand);

// Network DDE
short BCDdeQueryHost(HWND hWnd, char FAR *pHost, short bufLen);

void BCDdeSetHost(char FAR *pHost);
void BCDdeClearHost(void);

// General
short BCDdeMessage(char FAR *pMessage, short t);
short BCDdeCalendar(short y, short m, short d);
short BCDdeRunApp(char FAR *pCmdLine);
short BCDdePlayWave(char FAR *pFileName);

// Timers
short BCDdeTimerStart(char FAR *pName);
short BCDdeTimerStop(char FAR *pName);
short BCDdeTimerDelete(char FAR *pName);
short BCDdeTimerInfo(char FAR *pName,
				 char FAR *pMsg,
				 char FAR *pWave,
				 char FAR *pApp);
short BCDdeTimerAdd(char FAR *pName,
				short tmrType,
				short dollar,
				short cent,
				short tmrInc,
				DWORD tmrLimit);

// Alarms
short BCDdeAlarmDelete(char FAR *pName);
short BCDdeAlarmInfo(char FAR *pName,
				 char FAR *pMsg,
				 char FAR *pWave,
				 char FAR *pApp);
short BCDdeAlarmAdd(char FAR *pName,
				short year, short month, short day,
				short hour, short min,
				short repeatType);

// Buttons
short BCDdeButtonDelete(unsigned long hookSig, BYTE btnId);
short BCDdeButtonAdd(unsigned long hookSig, BYTE btnId, Position pos);

// Hooks
short BCDdeInstallHook(char FAR *pDllName);

#endif