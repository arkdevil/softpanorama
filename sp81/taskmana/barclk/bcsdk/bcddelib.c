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

#include "bcddelib.h"
#include <ddeml.h>

//Stolen from Windows 3.1 DDK WINNET.H
WORD FAR PASCAL WNetGetCaps(WORD);
typedef BOOL (FAR PASCAL *LPFNWINNETBROWSE)(HWND, LPSTR, LPSTR, UINT, DWORD);

// Global data
DWORD idInst = 0;

// Local data
static char host[64] = "";
char cmdBuf[512];

// Local functions
static short ddeStdExecute(short id, char FAR *pName);
static short ddeInfoExecute(short id, char FAR *pName, char FAR *pMsg, char FAR *pWave, char FAR *pApp);


// ******************
//
//   INIT FUNCTIONS
//
// ******************

short BCDdeLibInit(FARPROC lpfnCallback, DWORD afCmd)
{
	// Already inited?
	if (idInst)
		return BCDDE_MULTIPLEINIT;

	// Use default filters?
	if (lpfnCallback == NULL)
		afCmd = APPCMD_CLIENTONLY | CBF_FAIL_ALLSVRXACTIONS | CBF_SKIP_ALLNOTIFICATIONS;

	// Start conversation
	if (DdeInitialize(&idInst, (PFNCALLBACK) lpfnCallback, afCmd, 0l) != DMLERR_NO_ERROR) {

		idInst = 0;
	}

	// Set return inst

	return ((idInst)? BCDDE_NOERROR:BCDDE_INITFAIL);
}

void BCDdeLibFree(void)
{
	// Disconnect
	if (idInst) DdeUninitialize(idInst);
	idInst = 0;
}


// *************
//
//   MAIN EXEC
//
// *************

short BCDdeExecute(char FAR *pCommand)
{
	char serviceBuf[256];
	LPSTR pService = "BarClock";
	HCONV hConv;
	HSZ hszTopic = (HSZ) 0;
	HSZ hszService;
	short err = BCDDE_EXECFAIL;

	if (idInst == 0) return BCDDE_NOINIT;

	// If a host is specified, build
	// include host name in service
	if (host[0]) {

		// Set service name
		wsprintf(serviceBuf, "%s\\NDDE$", (LPSTR) host);
		pService = serviceBuf;
	}

	// Create service string
	hszService = DdeCreateStringHandle(idInst, pService, CP_WINANSI);

	// Allocate topic
	hszTopic = (host[0])? DdeCreateStringHandle(idInst, "BARCLK$", CP_WINANSI):hszService;

	// Start conversation
	if (hszService && ((hConv = DdeConnect(idInst, hszService, hszTopic, NULL)) != (HCONV) 0)) {

		// Execute command
		if (DdeClientTransaction((void FAR *) pCommand,
							lstrlen(pCommand) + 1,
							hConv, (HSZ) 0,
							CF_TEXT, XTYP_EXECUTE,
							4000L, NULL) != FALSE) {
			err = BCDDE_NOERROR;
		}

		// converastion is done
		DdeDisconnect(hConv);
	}

	if (hszService) DdeFreeStringHandle(idInst, hszService);
	if (host[0] && hszTopic) DdeFreeStringHandle(idInst, hszTopic);

	return err;
}



// ******************
//
//   UTIL FUNCTIONS
//
// ******************

#undef DDECommand
#define DDECommand(a)	#a,

static LPSTR cmdTable[] = {

	#include "bcddestr.h"
	NULL
};

char FAR *BCDdeString(short id)
{
	return ((id < eCmdLast)? cmdTable[id]:NULL);
}



// *****************
//
//   NET FUNCTIONS
//
// *****************

short BCDdeQueryHost(HWND hwnd, char FAR *pHost, short bufLen)
{
	LPFNWINNETBROWSE pfnBrowse;
	HINSTANCE hModNet;

	// Get net DLL
	if ((hModNet = (HINSTANCE)WNetGetCaps(0xFFFF)) != (HINSTANCE) 0) {

		// Load proc address
		pfnBrowse=(LPFNWINNETBROWSE)GetProcAddress(hModNet, (LPSTR)(LONG)146);

		if (NULL != pfnBrowse) {

			if ((*pfnBrowse)(hwnd, "MRU_BarClock", pHost, bufLen, 0L) == WN_SUCCESS)
				return BCDDE_NOERROR;
		}
	}

	return BCDDE_HOSTFAIL;
}

void BCDdeSetHost(char FAR *pHost)
{
	lstrcpyn(host, pHost, sizeof(host));
	host[sizeof(host) - 1] = 0;
}

void BCDdeClearHost(void)
{
	host[0] = 0;
}



// ******************
//
//   EXEC FUNCTIONS
//
// ******************

short BCDdeMessage(char FAR *pMessage,
			    short type)
{
	wsprintf(cmdBuf, "[%s(\"%s\",%d)]", BCDdeString(eCmdMessage), pMessage, type);
	return BCDdeExecute(cmdBuf);
}

short BCDdeCalendar(short y, short m, short d)
{
	wsprintf(cmdBuf, "[%s(%d,%d,%d)]", BCDdeString(eCmdCalendar), y, m, d);
	return BCDdeExecute(cmdBuf);
}

short BCDdePlayWave(char FAR *pName)
{
	return ddeStdExecute(eCmdPlayWave, pName);
}

short BCDdeRunApp(char FAR *pCmdLine)
{
	return ddeStdExecute(eCmdRunApp, pCmdLine);
}

short BCDdeTimerStart(char FAR *pName)
{
	return ddeStdExecute(eCmdTimerStart, pName);
}

short BCDdeTimerStop(char FAR *pName)
{
	return ddeStdExecute(eCmdTimerStop, pName);
}

short BCDdeTimerAdd(char FAR *pName,
				short tmrType,
				short dollar,
				short cent,
				short tmrInc,
				DWORD tmrLimit)
{
	wsprintf(cmdBuf, "[%s(\"%s\",%d,%d,%d,%d,%lu)]", BCDdeString(eCmdTimerAdd), pName, tmrType, dollar, cent, tmrInc, tmrLimit);
	return BCDdeExecute(cmdBuf);
}

short BCDdeTimerInfo(char FAR *pName, char FAR *pMsg, char FAR *pWave, char FAR *pApp)
{
	return ddeInfoExecute(eCmdTimerInfo, pName, pMsg, pWave, pApp);
}

short BCDdeTimerDelete(char FAR *pName)
{
	return ddeStdExecute(eCmdTimerDelete, pName);
}

short BCDdeAlarmAdd(char FAR *pName,
				short year, short month, short day,
				short hour, short min,
				short repeatType)
{
	wsprintf(cmdBuf, "[%s(\"%s\",%d,%d,%d,%d,%d,%d)]",
		    BCDdeString(eCmdAlarmAdd), pName, year, month, day, hour, min, repeatType);
	return BCDdeExecute(cmdBuf);
}

short BCDdeAlarmInfo(char FAR *pName, char FAR *pMsg, char FAR *pWave, char FAR *pApp)
{
	return ddeInfoExecute(eCmdAlarmInfo, pName, pMsg, pWave, pApp);
}

short BCDdeAlarmDelete(char FAR *pName)
{
	return ddeStdExecute(eCmdAlarmDelete, pName);
}

short BCDdeButtonAdd(unsigned long hookSig, BYTE btnId, Position pos)
{
	wsprintf(cmdBuf, "[%s(%lu,%c,%d)]", BCDdeString(eCmdButtonAdd), hookSig, btnId, (short) pos);
	return BCDdeExecute(cmdBuf);
}

short BCDdeButtonDelete(unsigned long hookSig, BYTE btnId)
{
	wsprintf(cmdBuf, "[%s(%lu,%c)]", BCDdeString(eCmdButtonDelete), hookSig, btnId);
	return BCDdeExecute(cmdBuf);
}

short BCDdeInstallHook(char FAR *pLibName)
{
	return ddeStdExecute(eCmdInstallHook, pLibName);
}




// *******************
//
//   LOCAL FUNCTIONS
//
// *******************

static short ddeStdExecute(short id, char FAR *pName)
{
	wsprintf(cmdBuf, "[%s(\"%s\")]", BCDdeString(id), pName);
	return BCDdeExecute(cmdBuf);
}

static short ddeInfoExecute(short id, char FAR *pName, char FAR *pMsg, char FAR *pWave, char FAR *pApp)
{
	// Make sure buffer length is not exceeded!

	wsprintf(cmdBuf, "[%s(\"%s\",\"%s\",\"%s\",\"%s\")]",
				  BCDdeString(id), pName,
				  (pMsg)? pMsg:"",
				  (pWave)? pWave:"",
				  (pApp)? pApp:"");

	return BCDdeExecute(cmdBuf);
}

