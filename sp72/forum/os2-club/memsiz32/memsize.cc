/***************************************************************** MEMSIZE.CC
 *									    *
 * System Resources Monitor						    *
 *									    *
 * (C) Copyright 1991-1993 by Richard W. Papo.				    *
 *									    *
 * This is 'FreeWare'.	As such, it may be copied and distributed	    *
 * freely.  If you want to use part of it in your own program, please	    *
 * give credit where credit is due.  If you want to change the		    *
 * program, please refer the change request to me or send me the	    *
 * modified source code.  I can be reached at CompuServe 72607,3111.	    *
 *									    *
 ****************************************************************************/

//
// Things to do:
//
//   (1) Validate memory statistics against OS20MEMU.
//
//   (2) Provide an item to serve as a button to cause a secondary
//	 drive status window to be displayed.
//
//   (3) Make file system name display optional.
//
//   (4) Make drive percentage utilization available as an option.
//

#define INCL_BASE
#define INCL_PM
#include <os2.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "debug.h"
#include "support.h"

#include "about.h"
#include "config.h"
#include "process.h"
#include "profile.h"
#include "restring.h"

#include "items.h"

#include "memsize.h"

#define STATIC static


/****************************************************************************
 *									    *
 *			 Definitions & Declarations			    *
 *									    *
 ****************************************************************************/

  // Constants

#define PROGRAM_NAME	   "MEMSIZE"
#define CLASS_NAME	    PROGRAM_NAME

#define WM_REFRESH        (WM_USER)

#define MAX_DRIVES	  (26)
#define DRIVE_ERROR	  (0xFFFFFFFFL)

enum
{
  ITEM_CLOCK,
  ITEM_ELAPSEDTIME,
  ITEM_MEMORYFREE,
  ITEM_SWAPFILESIZE,
  ITEM_SWAPDISKFREE,
  ITEM_SPOOLFILESIZE,
  ITEM_CPULOAD,
  ITEM_TASKCOUNT,
  ITEM_TOTALFREE,
  ITEM_BASE_COUNT
} ;


  // Data Types

typedef struct	      // Parameters saved to system.
{
  // The Display Item List - - -
  Item		 *Items [ ITEM_BASE_COUNT + MAX_DRIVES ] ;
  int		  ItemCount ;

  // Data required for the display item objects to function.
  ULONG 	  IdleCount ;
  ULONG 	  MaxCount ;
  BYTE		  SwapPath [_MAX_PATH] ;
  ULONG 	  MinFree ;
  PBYTE 	  SpoolPath ;
  COUNTRYINFO	  CountryInfo ;
  ResourceString *Day ;
  ResourceString *Days ;
  ResourceString *DaysOfWeek ;
  ResourceString *DriveError ;

  // Window size and location
  SWP	 Position ;
  BOOL	 fPosition ;

  // User Options
  BOOL	 HideControls ;
  BOOL	 fHideControls ;

  BOOL	 Float ;
  BOOL	 fFloat ;

  USHORT TimerInterval ;
  BOOL	 fTimerInterval ;

  // Presentation Parameters
  BYTE	 FontNameSize [80] ;
  BOOL	 fFontNameSize ;

  COLOR  BackColor ;
  BOOL	 fBackColor ;

  COLOR  TextColor ;
  BOOL	 fTextColor ;
}
PROFILE, *PPROFILE ;

typedef struct        // Data structure for window.
{
  HAB		 Anchor ;
  HMODULE	 Library ;
  HINI           ProfileHandle ;

  ULONG 	 IdleCounter ;
  TID		 IdleLoopTID ;
  TID		 MonitorLoopTID ;

  PROFILE	 Profile ;

  HWND           hwndTitleBar ;
  HWND           hwndSysMenu ;
  HWND		 hwndMinMax ;

  ULONG 	 Drives ;

  long		 Width ;
  long		 Height ;

}
DATA, *PDATA ;

typedef struct
{
  HAB Anchor ;
  HMODULE Library ;
  HINI ProfileHandle ;
}
PARMS, *PPARMS ;

typedef struct
{
  volatile PULONG Counter ;
  PUSHORT Interval ;
  HWND Owner ;
}
MONITOR_PARMS, *PMONITOR_PARMS ;


  // Function Prototypes

extern INT main ( INT argc, PCHAR argv[] ) ;

STATIC MRESULT EXPENTRY MessageProcessor
(
  HWND hwnd,
  USHORT msg,
  MPARAM mp1,
  MPARAM mp2
) ;

STATIC METHODFUNCTION Create ;
STATIC METHODFUNCTION Destroy ;
STATIC METHODFUNCTION Size ;
STATIC METHODFUNCTION SaveApplication ;
STATIC METHODFUNCTION Paint ;
STATIC METHODFUNCTION Command ;
STATIC METHODFUNCTION ResetDefaults ;
STATIC METHODFUNCTION HideControlsCmd ;
STATIC METHODFUNCTION Configure ;
STATIC METHODFUNCTION About ;
STATIC METHODFUNCTION ButtonDown ;
STATIC METHODFUNCTION ButtonDblClick ;
STATIC METHODFUNCTION PresParamChanged ;
STATIC METHODFUNCTION SysColorChange ;
STATIC METHODFUNCTION QueryKeysHelp ;
STATIC METHODFUNCTION HelpError ;
STATIC METHODFUNCTION ExtHelpUndefined ;
STATIC METHODFUNCTION HelpSubitemNotFound ;
STATIC METHODFUNCTION Refresh ;

STATIC int GetProfile ( HAB Anchor, HMODULE Library, HINI ProfileHandle, PPROFILE Profile ) ;
STATIC VOID PutProfile ( HINI ProfileHandle, PPROFILE Profile ) ;

STATIC PSZ ScanSystemConfig ( HAB Anchor, PSZ Keyword ) ;

STATIC void ResizeWindow ( HWND hwnd, PPROFILE Profile ) ;

STATIC void HideControls
(
  BOOL fHide,
  HWND hwndFrame,
  HWND hwndSysMenu,
  HWND hwndTitleBar,
  HWND hwndMinMax
) ;

STATIC void UpdateWindow ( HWND hwnd, PDATA Data, BOOL All ) ;

STATIC VOID MonitorLoopThread ( PMONITOR_PARMS Parms ) ;

STATIC VOID UpdateDriveList
(
  HAB Anchor,
  HMODULE Library,
  HINI ProfileHandle,
  PPROFILE Profile,
  ULONG OldDrives,
  ULONG NewDrives
) ;

STATIC BOOL CheckDrive ( USHORT Drive, PBYTE FileSystem ) ;

STATIC ULONG CalibrateLoadMeter ( VOID ) ;

STATIC VOID CounterThread ( PULONG Counter ) ;

STATIC HINI OpenProfile ( PSZ Name, HAB Anchor, HMODULE Library, HWND HelpInstance ) ;


/****************************************************************************
 *									    *
 *	Program Mainline						    *
 *									    *
 ****************************************************************************/

extern INT main ( INT argc, PCHAR argv[] )
{
 /***************************************************************************
  * Initialize the process.						    *
  ***************************************************************************/

  Process Proc ;

 /***************************************************************************
  * Now WIN and GPI calls will work.  Open the language DLL.		    *
  ***************************************************************************/

  HMODULE Library ;
  if ( DosLoadModule ( NULL, 0, (PSZ)PROGRAM_NAME, &Library ) )
  {
    Debug ( HWND_DESKTOP, "ERROR: Unable to load " PROGRAM_NAME ".DLL." ) ;
    DosExit ( EXIT_PROCESS, 1 ) ;
  }

 /***************************************************************************
  * Get the program title.                        			    *
  ***************************************************************************/

  ResourceString Title ( Library, IDS_TITLE ) ;

 /***************************************************************************
  * Decipher command-line parameters.					    *
  ***************************************************************************/

  BOOL Reset = FALSE ;

  ResourceString ResetCommand ( Library, IDS_PARMS_RESET ) ;

  while ( --argc )
  {
    argv ++ ;

    WinUpper ( Proc.QueryAnchor(), NULL, NULL, (PSZ)*argv ) ;

    if ( *argv[0] == '?' )
    {
      ResourceString Message ( Library, IDS_PARAMETERLIST ) ;

      WinMessageBox ( HWND_DESKTOP, HWND_DESKTOP, Message.Ptr(),
	Title.Ptr(), 0, MB_ENTER | MB_NOICON ) ;

      DosExit ( EXIT_PROCESS, 1 ) ;
    }

    if ( !strcmp ( *argv, (PCHAR)ResetCommand.Ptr() ) )
    {
      Reset = TRUE ;
      continue ;
    }

    {
      ResourceString Format ( Library, IDS_ERROR_INVALIDPARM ) ;

      BYTE Message [200] ;
      sprintf ( (PCHAR)Message, (PCHAR)Format.Ptr(), *argv ) ;

      WinMessageBox ( HWND_DESKTOP, HWND_DESKTOP, Message,
	Title.Ptr(), 0, MB_ENTER | MB_ICONEXCLAMATION ) ;

      DosExit ( EXIT_PROCESS, 1 ) ;
    }
  }

 /***************************************************************************
  * Create the help instance.						    *
  ***************************************************************************/

  HELPINIT HelpInit =
  {
    sizeof ( HELPINIT ),
    0L,
    NULL,
    MAKEP ( 0xFFFF, ID_MAIN ),
    0,
    0,
    0,
    0,
    NULL,
    CMIC_HIDE_PANEL_ID,
    (PSZ) ( PROGRAM_NAME ".HLP" )
  } ;

  ResourceString HelpTitle ( Library, IDS_HELPTITLE ) ;

  HelpInit.pszHelpWindowTitle = HelpTitle.Ptr() ;

  HWND hwndHelp = WinCreateHelpInstance ( Proc.QueryAnchor(), &HelpInit ) ;

  if ( hwndHelp == NULL )
  {
    ResourceString Message ( Library, IDS_ERROR_WINCREATEHELPINSTANCE ) ;

    WinMessageBox ( HWND_DESKTOP, HWND_DESKTOP, Message.Ptr(),
      Title.Ptr(), 0, MB_ENTER | MB_ICONEXCLAMATION ) ;
  }

 /***************************************************************************
  * Open/create the profile file.                           		    *
  ***************************************************************************/

  HINI ProfileHandle = OpenProfile ( PSZ(PROGRAM_NAME),
    Proc.QueryAnchor(), Library, hwndHelp ) ;

  if ( ProfileHandle == NULL )
  {
    ResourceString Message ( Library, IDS_ERROR_PRFOPENPROFILE ) ;

//  Log ( "%s\r\n", Message.Ptr() ) ;

    WinMessageBox ( HWND_DESKTOP, HWND_DESKTOP, Message.Ptr(),
      Title.Ptr(), 0, MB_ENTER | MB_ICONEXCLAMATION ) ;

    DosFreeModule ( Library ) ;
    DosExit ( EXIT_PROCESS, 1 ) ;
  }

 /***************************************************************************
  * If we're going to reset the program's profile, do it now.               *
  ***************************************************************************/

  if ( Reset )
  {
    PrfWriteProfileData ( ProfileHandle, (PSZ)PROGRAM_NAME, NULL, NULL, 0 ) ;
  }

 /***************************************************************************
  * Create the frame window.						    *
  ***************************************************************************/

  #pragma pack(2)
  struct
  {
    USHORT Filler ;
    USHORT cb ;
    ULONG  flCreateFlags ;
    USHORT hmodResources ;
    USHORT idResources ;
  }
  fcdata ;
  #pragma pack()

  fcdata.cb = sizeof(fcdata) - sizeof(fcdata.Filler) ;
  fcdata.flCreateFlags =
    FCF_TITLEBAR | FCF_SYSMENU | FCF_BORDER |
    FCF_ICON | FCF_MINBUTTON | FCF_NOBYTEALIGN | FCF_ACCELTABLE ;
  fcdata.hmodResources = 0 ;
  fcdata.idResources = ID_MAIN ;

  HWND hwndFrame = WinCreateWindow
  (
    HWND_DESKTOP,
    WC_FRAME,
    Title.Ptr(),
    0,
    0, 0, 0, 0,
    HWND_DESKTOP,
    HWND_TOP,
    ID_MAIN,
    &fcdata.cb,
    NULL
  ) ;

  if ( hwndFrame == NULL )
  {
    ResourceString Message ( Library, IDS_ERROR_WINCREATEFRAME ) ;

    WinMessageBox ( HWND_DESKTOP, HWND_DESKTOP, Message.Ptr(),
      Title.Ptr(), 0, MB_ENTER | MB_ICONEXCLAMATION ) ;

    PrfCloseProfile ( ProfileHandle ) ;
    DosFreeModule ( Library ) ;
    DosExit ( EXIT_PROCESS, 1 ) ;
  }

 /***************************************************************************
  * Associate the help instance with the frame window.			    *
  ***************************************************************************/

  if ( hwndHelp )
  {
    WinAssociateHelpInstance ( hwndHelp, hwndFrame ) ;
  }

 /***************************************************************************
  * Register the window class.						    *
  ***************************************************************************/

  if ( NOT WinRegisterClass ( Proc.QueryAnchor(), (PSZ)CLASS_NAME,
    MessageProcessor, CS_MOVENOTIFY, sizeof(PVOID) ) )
  {
    ResourceString Format ( Library, IDS_ERROR_WINREGISTERCLASS ) ;

    BYTE Message [200] ;
    sprintf ( PCHAR(Message), PCHAR(Format.Ptr()), CLASS_NAME ) ;

    WinMessageBox ( HWND_DESKTOP, HWND_DESKTOP, Message,
      Title.Ptr(), 0, MB_ENTER | MB_ICONEXCLAMATION ) ;

    PrfCloseProfile ( ProfileHandle ) ;
    DosFreeModule ( Library ) ;
    DosExit ( EXIT_PROCESS, 1 ) ;
  }

 /***************************************************************************
  * Create client window.  If this fails, destroy frame and return.	    *
  ***************************************************************************/

  PARMS Parms ;
  Parms.Anchor = Proc.QueryAnchor() ;
  Parms.Library = Library ;
  Parms.ProfileHandle = ProfileHandle ;

  HWND hwndClient = WinCreateWindow
  (
    hwndFrame,
    (PSZ)CLASS_NAME,
    (PSZ)"",
    0,
    0, 0, 0, 0,
    hwndFrame,
    HWND_BOTTOM,
    FID_CLIENT,
    &Parms,
    NULL
  ) ;

  if ( hwndClient == NULL )
  {
    ResourceString Message ( Library, IDS_ERROR_WINCREATEWINDOW ) ;

    WinMessageBox ( HWND_DESKTOP, HWND_DESKTOP, Message.Ptr(),
      Title.Ptr(), 0, MB_ENTER | MB_ICONEXCLAMATION ) ;

    WinDestroyWindow ( hwndFrame ) ;
    if ( hwndHelp )
    {
      WinDestroyHelpInstance ( hwndHelp ) ;
    }
    PrfCloseProfile ( ProfileHandle ) ;
    DosFreeModule ( Library ) ;
    DosExit ( EXIT_PROCESS, 1 ) ;
  }

 /***************************************************************************
  * Wait for and process messages to the window's queue.  Terminate         *
  *   when the WM_QUIT message is received.				    *
  ***************************************************************************/

  QMSG QueueMessage ;
  while ( WinGetMsg ( Proc.QueryAnchor(), &QueueMessage, NULL, 0, 0 ) )
  {
    WinDispatchMsg ( Proc.QueryAnchor(), &QueueMessage ) ;
  }

 /***************************************************************************
  * Discard all that was requested of the system and terminate. 	    *
  ***************************************************************************/

  WinDestroyWindow ( hwndFrame ) ;

  if ( hwndHelp )
  {
    WinDestroyHelpInstance ( hwndHelp ) ;
  }

  PrfCloseProfile ( ProfileHandle ) ;

  DosFreeModule ( Library ) ;

  DosExit ( EXIT_PROCESS, 0 ) ;
}

/****************************************************************************
 *									    *
 *	Window Message Processor					    *
 *									    *
 ****************************************************************************/

STATIC MRESULT EXPENTRY MessageProcessor
(
  HWND hwnd,
  USHORT msg,
  MPARAM mp1,
  MPARAM mp2
)
{
 /***************************************************************************
  * Dispatch the message according to the method table and return the	    *
  *   result.  Any messages not defined above get handled by the system     *
  *   default window processor. 					    *
  ***************************************************************************/

  static METHOD Methods [] =
  {
    { WM_CREATE,		Create		    },
    { WM_DESTROY,		Destroy 	    },
    { WM_SIZE,			Size		    },
    { WM_MOVE,			Size		    },
    { WM_SAVEAPPLICATION,	SaveApplication     },
    { WM_PAINT, 		Paint		    },
    { WM_BUTTON1DOWN,		ButtonDown	    },
    { WM_BUTTON2DOWN,		ButtonDown	    },
    { WM_BUTTON1DBLCLK, 	ButtonDblClick	    },
    { WM_BUTTON2DBLCLK, 	ButtonDblClick	    },
    { WM_PRESPARAMCHANGED,	PresParamChanged    },
    { WM_SYSCOLORCHANGE,	SysColorChange	    },
    { WM_COMMAND,		Command 	    },
    { HM_QUERY_KEYS_HELP,	QueryKeysHelp	    },
    { HM_ERROR, 		HelpError	    },
    { HM_EXT_HELP_UNDEFINED,	ExtHelpUndefined    },
    { HM_HELPSUBITEM_NOT_FOUND, HelpSubitemNotFound },
    { WM_REFRESH,		Refresh 	    }
  } ;

  return ( DispatchMessage ( hwnd, msg, mp1, mp2, Methods, sizeof(Methods)/sizeof(Methods[0]), WinDefWindowProc ) ) ;
}

/****************************************************************************
 *									    *
 *	Create the main window. 					    *
 *									    *
 ****************************************************************************/

STATIC MRESULT APIENTRY Create
(
  HWND hwnd,
  USHORT msg,
  MPARAM mp1,
  MPARAM mp2
)
{
 /***************************************************************************
  * Allocate instance data.						    *
  ***************************************************************************/

  PDATA Data = malloc ( sizeof(DATA) ) ;

  memset ( Data, 0, sizeof(DATA) ) ;

  WinSetWindowPtr ( hwnd, QWL_USER, Data ) ;

 /***************************************************************************
  * Grab any parameters from the WM_CREATE message.			    *
  ***************************************************************************/

  PPARMS Parms = (PPARMS) PVOIDFROMMP ( mp1 ) ;

  Data->Anchor = Parms->Anchor ;
  Data->Library = Parms->Library ;
  Data->ProfileHandle = Parms->ProfileHandle ;

 /***************************************************************************
  * Get the current drive mask. 					    *
  ***************************************************************************/

  ULONG Drive ;
  DosQueryCurrentDisk ( &Drive, &Data->Drives ) ;

 /***************************************************************************
  * Initialize the global resource strings.				    *
  ***************************************************************************/

  Data->Profile.Day	   = new ResourceString ( Data->Library, IDS_DAY ) ;
  Data->Profile.Days	   = new ResourceString ( Data->Library, IDS_DAYS ) ;
  Data->Profile.DaysOfWeek = new ResourceString ( Data->Library, IDS_DAYSOFWEEK ) ;
  Data->Profile.DriveError = new ResourceString ( Data->Library, IDS_DRIVEERROR ) ;

 /***************************************************************************
  * Get country information.						    *
  ***************************************************************************/

  COUNTRYCODE CountryCode ;
  ULONG Count ;
  ULONG Status ;

  CountryCode.country = 0 ;
  CountryCode.codepage = 0 ;

  Status = DosGetCtryInfo ( sizeof(Data->Profile.CountryInfo), &CountryCode,
    &Data->Profile.CountryInfo, &Count ) ;
  if ( Status )
  {
    BYTE Message [80] ;
    WinLoadMessage ( Data->Anchor, Data->Library, IDS_ERROR_DOSGETCTRYINFO,
      sizeof(Message), Message ) ;
    Debug ( hwnd, (PCHAR)Message, Status ) ;
    Data->Profile.CountryInfo.fsDateFmt = DATEFMT_MM_DD_YY ;
    Data->Profile.CountryInfo.fsTimeFmt = 0 ;
    Data->Profile.CountryInfo.szDateSeparator[0] = '/' ;
    Data->Profile.CountryInfo.szDateSeparator[1] = 0 ;
    Data->Profile.CountryInfo.szTimeSeparator[0] = ':' ;
    Data->Profile.CountryInfo.szTimeSeparator[1] = 0 ;
    Data->Profile.CountryInfo.szThousandsSeparator[0] = ',' ;
    Data->Profile.CountryInfo.szThousandsSeparator[1] = 0 ;
  }

 /***************************************************************************
  * Get the SWAPPATH statement from CONFIG.SYS. 			    *
  ***************************************************************************/

  PSZ Swappath = ScanSystemConfig ( Data->Anchor, (PSZ)"SWAPPATH" ) ;

  if ( Swappath == NULL )
  {
    Swappath = (PSZ) "C:\\OS2\\SYSTEM 0" ;
  }

  sscanf ( (PCHAR)Swappath, "%s %li",
    Data->Profile.SwapPath, &Data->Profile.MinFree ) ;

 /***************************************************************************
  * Find out where the spool work directory is. 			    *
  ***************************************************************************/

  Data->Profile.SpoolPath = NULL ;

  ULONG Size ;
  if ( PrfQueryProfileSize ( HINI_PROFILE, (PSZ)"PM_SPOOLER", (PSZ)"DIR", &Size ) )
  {
    Data->Profile.SpoolPath = malloc ( (int)Size ) ;

    if ( Data->Profile.SpoolPath )
    {
      if ( PrfQueryProfileData ( HINI_PROFILE, (PSZ)"PM_SPOOLER", (PSZ)"DIR", Data->Profile.SpoolPath, &Size ) )
      {
	PBYTE p = (PBYTE) strchr ( (PCHAR)Data->Profile.SpoolPath, ';' ) ;
	if ( p )
	{
	  *p = 0 ;
	}
      }
      else
      {
	free ( Data->Profile.SpoolPath ) ;
	Data->Profile.SpoolPath = NULL ;
      }
    }
  }

 /***************************************************************************
  * Calibrate the old-style load meter, if the high resolution timer's      *
  *   available.							    *
  ***************************************************************************/

  Data->Profile.MaxCount = CalibrateLoadMeter ( ) ;
  Data->Profile.MaxCount = (ULONG) max ( 1L, Data->Profile.MaxCount ) ;

 /***************************************************************************
  * Get profile data. Try the OS2.INI first, then try for private INI.      *
  *   If obtained from OS2.INI, erase it afterwards.                        *
  ***************************************************************************/

  if ( GetProfile ( Data->Anchor, Data->Library, HINI_USERPROFILE, &Data->Profile ) )
  {
    GetProfile ( Data->Anchor, Data->Library, Data->ProfileHandle, &Data->Profile ) ;
  }
  else
  {
    PrfWriteProfileData ( HINI_USERPROFILE, (PSZ)PROGRAM_NAME, NULL, NULL, 0 ) ;
  }

 /***************************************************************************
  * Get the frame handle.						    *
  ***************************************************************************/

  HWND hwndFrame = WinQueryWindow ( hwnd, QW_PARENT ) ;

 /***************************************************************************
  * Get the control window handles.					    *
  ***************************************************************************/

  Data->hwndSysMenu  = WinWindowFromID ( hwndFrame, FID_SYSMENU  ) ;
  Data->hwndTitleBar = WinWindowFromID ( hwndFrame, FID_TITLEBAR ) ;
  Data->hwndMinMax   = WinWindowFromID ( hwndFrame, FID_MINMAX   ) ;

 /***************************************************************************
  * Add basic extensions to the system menu.				    *
  ***************************************************************************/

  static MENUITEM MenuSeparator =
    { MIT_END, MIS_SEPARATOR, 0, 0, NULL, 0 } ;

  AddSysMenuItem ( hwndFrame, &MenuSeparator, NULL ) ;

  static MENUITEM MenuItems [] =
  {
    { MIT_END, MIS_TEXT,      0, IDM_SAVE_APPLICATION, NULL, 0 },
    { MIT_END, MIS_TEXT,      0, IDM_RESET_DEFAULTS,   NULL, 0 },
    { MIT_END, MIS_TEXT,      0, IDM_HIDE_CONTROLS,    NULL, 0 },
    { MIT_END, MIS_TEXT,      0, IDM_CONFIGURE,        NULL, 0 },
  } ;

  for ( int i=0; i<sizeof(MenuItems)/sizeof(MenuItems[0]); i++ )
  {
    ResourceString MenuText ( Data->Library, i+IDS_SAVE_APPLICATION ) ;
    AddSysMenuItem ( hwndFrame, MenuItems+i, MenuText.Ptr() ) ;
  }

  AddSysMenuItem ( hwndFrame, &MenuSeparator, NULL ) ;

 /***************************************************************************
  * Add 'About' to the system menu.					    *
  ***************************************************************************/

  static MENUITEM MenuAbout =
    { MIT_END, MIS_TEXT, 0, IDM_ABOUT, NULL, 0 } ;

  ResourceString AboutText ( Data->Library, IDS_ABOUT ) ;

  AddSysMenuItem ( hwndFrame, &MenuAbout, AboutText.Ptr() ) ;

 /***************************************************************************
  * Add 'Help' to the system menu.					    *
  ***************************************************************************/

  static MENUITEM MenuHelp =
    { MIT_END, MIS_HELP, 0, 0, NULL, 0 } ;

  ResourceString HelpText ( Data->Library, IDS_HELP ) ;

  AddSysMenuItem ( hwndFrame, &MenuHelp, HelpText.Ptr() ) ;

 /***************************************************************************
  * Start the new load meter.						    *
  ***************************************************************************/

  DosCreateThread ( &Data->IdleLoopTID, CounterThread, (ULONG)&Data->IdleCounter, 0, 4096 ) ;
  DosSetPrty ( PRTYS_THREAD, PRTYC_IDLETIME, PRTYD_MINIMUM, Data->IdleLoopTID ) ;
  DosSuspendThread ( Data->IdleLoopTID ) ;

  Data->Profile.IdleCount = 0 ;
  Data->IdleCounter = 0 ;

  if ( Data->Profile.Items[ITEM_CPULOAD]->QueryFlag() )
  {
    DosResumeThread ( Data->IdleLoopTID ) ;
  }

  PMONITOR_PARMS MonitorParms = PMONITOR_PARMS ( malloc ( sizeof(*MonitorParms) ) ) ;
  MonitorParms->Counter = & Data->IdleCounter ;
  MonitorParms->Interval = & Data->Profile.TimerInterval ;
  MonitorParms->Owner = hwnd ;
  DosCreateThread ( &Data->MonitorLoopTID, MonitorLoopThread, (ULONG)MonitorParms, 2, 8192 ) ;

 /***************************************************************************
  * Add the program to the system task list.				    *
  ***************************************************************************/

  ResourceString Title ( Data->Library, IDS_TITLE ) ;
  Add2TaskList ( hwndFrame, Title.Ptr() ) ;

 /***************************************************************************
  * Position & size the window.  For some reason, we must move and size     *
  *   the window to the saved position before applying the resizing	    *
  *   function as fine-tuning.	Maybe the positioning request fails if	    *
  *   the window has no size?						    *
  ***************************************************************************/

  WinSetWindowPos ( hwndFrame, HWND_BOTTOM,
    Data->Profile.Position.x, Data->Profile.Position.y,
    Data->Profile.Position.cx, Data->Profile.Position.cy,
    SWP_SIZE | SWP_MOVE | SWP_ZORDER |
    ( Data->Profile.Position.fl & SWP_MINIMIZE ) |
    ( Data->Profile.Position.fl & SWP_RESTORE ) ) ;

  ResizeWindow ( hwnd, &Data->Profile ) ;

 /***************************************************************************
  * Hide the controls if so configured. 				    *
  ***************************************************************************/

  if ( Data->Profile.HideControls
    AND NOT ( Data->Profile.Position.fl & SWP_MINIMIZE ) )
  {
    CheckMenuItem ( hwndFrame, FID_SYSMENU, IDM_HIDE_CONTROLS, Data->Profile.HideControls ) ;

    HideControls
    (
      TRUE,
      hwndFrame,
      Data->hwndSysMenu,
      Data->hwndTitleBar,
      Data->hwndMinMax
    ) ;
  }

 /***************************************************************************
  * Get the saved presentation parameters and reinstate them.		    *
  ***************************************************************************/

  if ( Data->Profile.fFontNameSize )
  {
    WinSetPresParam ( hwnd, PP_FONTNAMESIZE,
      strlen((PCHAR)Data->Profile.FontNameSize)+1, Data->Profile.FontNameSize ) ;
  }

  if ( Data->Profile.fBackColor )
  {
    WinSetPresParam ( hwnd, PP_BACKGROUNDCOLOR,
      sizeof(Data->Profile.BackColor), &Data->Profile.BackColor ) ;
  }

  if ( Data->Profile.fTextColor )
  {
    WinSetPresParam ( hwnd, PP_FOREGROUNDCOLOR,
      sizeof(Data->Profile.TextColor), &Data->Profile.TextColor ) ;
  }

 /***************************************************************************
  * Determine our font size.						    *
  ***************************************************************************/

  HPS hPS = WinGetPS ( hwnd ) ;
  RECTL Rectangle ;
  WinQueryWindowRect ( HWND_DESKTOP, &Rectangle ) ;
  WinDrawText ( hPS, 1, (PSZ)" ", &Rectangle, 0L, 0L, DT_LEFT | DT_BOTTOM | DT_QUERYEXTENT ) ;
  Data->Width  = Rectangle.xRight - Rectangle.xLeft ;
  Data->Height = Rectangle.yTop - Rectangle.yBottom ;
  WinReleasePS ( hPS ) ;

 /***************************************************************************
  * Now that the window's in order, make it visible.                        *
  ***************************************************************************/

  WinShowWindow ( hwndFrame, TRUE ) ;

 /***************************************************************************
  * Success?  Return no error.						    *
  ***************************************************************************/

  return ( 0 ) ;
}

/****************************************************************************
 *									    *
 *	Destroy main window.						    *
 *									    *
 ****************************************************************************/

STATIC MRESULT APIENTRY Destroy
(
  HWND hwnd,
  USHORT msg,
  MPARAM mp1,
  MPARAM mp2
)
{
 /***************************************************************************
  * Find the instance data.						    *
  ***************************************************************************/

  PDATA Data = (PDATA) WinQueryWindowPtr ( hwnd, QWL_USER ) ;

 /***************************************************************************
  * Release the instance memory.					    *
  ***************************************************************************/

  free ( Data ) ;

 /***************************************************************************
  * We're done.                                                             *
  ***************************************************************************/

  return ( MRFROMSHORT ( 0 ) ) ;
}

/****************************************************************************
 *									    *
 *	Process window resize message.					    *
 *									    *
 ****************************************************************************/

STATIC MRESULT APIENTRY Size
(
  HWND hwnd,
  USHORT msg,
  MPARAM mp1,
  MPARAM mp2
)
{
 /***************************************************************************
  * Find the instance data.						    *
  ***************************************************************************/

  PDATA Data = (PDATA) WinQueryWindowPtr ( hwnd, QWL_USER ) ;

 /***************************************************************************
  * Find out the window's new position and size.                            *
  ***************************************************************************/

  HWND hwndFrame = WinQueryWindow ( hwnd, QW_PARENT ) ;

  SWP Position ;
  WinQueryWindowPos ( hwndFrame, &Position ) ;

  if ( NOT ( Position.fl & SWP_MINIMIZE )
    AND NOT ( Position.fl & SWP_MAXIMIZE ) )
  {
    Data->Profile.Position.x = Position.x ;
    Data->Profile.Position.y = Position.y ;

    Data->Profile.Position.cx = Position.cx ;
    Data->Profile.Position.cy = Position.cy ;
  }

 /***************************************************************************
  * If hiding the controls . . .					    *
  ***************************************************************************/

  if ( Data->Profile.HideControls )
  {

   /*************************************************************************
    * If changing to or from minimized state . . .			    *
    *************************************************************************/

    if ( ( Position.fl & SWP_MINIMIZE ) != ( Data->Profile.Position.fl & SWP_MINIMIZE ) )
    {

     /***********************************************************************
      * Hide the controls if no longer minimized.			    *
      ***********************************************************************/

      HideControls
      (
	NOT ( Position.fl & SWP_MINIMIZE ),
	hwndFrame,
	Data->hwndSysMenu,
	Data->hwndTitleBar,
	Data->hwndMinMax
      ) ;
    }
  }

  Data->Profile.Position.fl = Position.fl ;

 /***************************************************************************
  * We're done.                                                             *
  ***************************************************************************/

  return ( 0 ) ;
}

/****************************************************************************
 *									    *
 *	Process SAVE APPLICATION message.				    *
 *									    *
 ****************************************************************************/

STATIC MRESULT APIENTRY SaveApplication
(
  HWND hwnd,
  USHORT msg,
  MPARAM mp1,
  MPARAM mp2
)
{
 /***************************************************************************
  * Find the instance data.						    *
  ***************************************************************************/

  PDATA Data = (PDATA) WinQueryWindowPtr ( hwnd, QWL_USER ) ;

 /***************************************************************************
  * Call function to put all profile data out to the system.		    *
  ***************************************************************************/

  PutProfile ( Data->ProfileHandle, &Data->Profile ) ;

 /***************************************************************************
  * We're done.  Let the system complete default processing.                *
  ***************************************************************************/

  return ( WinDefWindowProc ( hwnd, WM_SAVEAPPLICATION, 0, 0 ) ) ;
}

/****************************************************************************
 *									    *
 *	Repaint entire window.						    *
 *									    *
 ****************************************************************************/

STATIC MRESULT APIENTRY Paint
(
  HWND hwnd,
  USHORT msg,
  MPARAM mp1,
  MPARAM mp2
)
{
 /***************************************************************************
  * Find the instance data.						    *
  ***************************************************************************/

  PDATA Data = (PDATA) WinQueryWindowPtr ( hwnd, QWL_USER ) ;

 /***************************************************************************
  * Get presentation space and make it use RGB colors.			    *
  ***************************************************************************/

  HPS hPS = WinBeginPaint ( hwnd, NULL, NULL ) ;
  GpiCreateLogColorTable ( hPS, LCOL_RESET, LCOLF_RGB, 0L, 0L, NULL ) ;

 /***************************************************************************
  * Clear the window.							    *
  ***************************************************************************/

  RECTL Rectangle ;
  WinQueryWindowRect ( hwnd, &Rectangle ) ;

  GpiMove ( hPS, (PPOINTL) &Rectangle.xLeft ) ;
  GpiSetColor ( hPS, Data->Profile.BackColor ) ;
  GpiBox ( hPS, DRO_FILL, (PPOINTL) &Rectangle.xRight, 0L, 0L ) ;

 /***************************************************************************
  * Release presentation space. 					    *
  ***************************************************************************/

  WinEndPaint ( hPS ) ;

 /***************************************************************************
  * Update the window and return.					    *
  ***************************************************************************/

  UpdateWindow ( hwnd, Data, TRUE ) ;

  return ( 0 ) ;
}

/****************************************************************************
 *									    *
 *	Process commands received by Main Window			    *
 *									    *
 ****************************************************************************/

STATIC MRESULT APIENTRY Command
(
  HWND hwnd,
  USHORT msg,
  MPARAM mp1,
  MPARAM mp2
)
{
 /***************************************************************************
  * Dispatch all other commands through the method table.		    *
  ***************************************************************************/

  static METHOD Methods [] =
  {
    { IDM_SAVE_APPLICATION, SaveApplication },
    { IDM_RESET_DEFAULTS,   ResetDefaults   },
    { IDM_HIDE_CONTROLS,    HideControlsCmd },
    { IDM_CONFIGURE,	    Configure	    },
    { IDM_EXIT, 	    Exit	    },
    { IDM_ABOUT,	    About	    },
  } ;

  return ( DispatchMessage ( hwnd, SHORT1FROMMP(mp1), mp1, mp2, Methods, sizeof(Methods)/sizeof(Methods[0]), NULL ) ) ;
}

/****************************************************************************
 *									    *
 *	Process Reset Defaults menu command.				    *
 *									    *
 ****************************************************************************/

STATIC MRESULT APIENTRY ResetDefaults
( 
  HWND hwnd, 
  USHORT msg, 
  MPARAM mp1, 
  MPARAM mp2
)
{
 /***************************************************************************
  * Find the instance data.						    *
  ***************************************************************************/

  PDATA Data = (PDATA) WinQueryWindowPtr ( hwnd, QWL_USER ) ;

 /***************************************************************************
  * Reset all profile data for this program.				    *
  ***************************************************************************/

  PrfWriteProfileData ( Data->ProfileHandle, (PSZ)PROGRAM_NAME, NULL, NULL, 0 ) ;

 /***************************************************************************
  * Reset the program's presentation parameters.                            *
  ***************************************************************************/

  WinRemovePresParam ( hwnd, PP_FONTNAMESIZE ) ;
  WinRemovePresParam ( hwnd, PP_FOREGROUNDCOLOR ) ;
  WinRemovePresParam ( hwnd, PP_BACKGROUNDCOLOR ) ;

 /***************************************************************************
  * Done.								    *
  ***************************************************************************/

  return ( MRFROMSHORT ( 0 ) ) ;
}

/****************************************************************************
 *									    *
 *	Process Hide Controls menu command.				    *
 *									    *
 ****************************************************************************/

STATIC MRESULT APIENTRY HideControlsCmd
( 
  HWND hwnd, 
  USHORT msg, 
  MPARAM mp1, 
  MPARAM mp2
)
{
 /***************************************************************************
  * Find the instance data.						    *
  ***************************************************************************/

  PDATA Data = (PDATA) WinQueryWindowPtr ( hwnd, QWL_USER ) ;

 /***************************************************************************
  * Toggle the Hide Controls setting.					    *
  ***************************************************************************/

  Data->Profile.HideControls = Data->Profile.HideControls ? FALSE : TRUE ;
  Data->Profile.fHideControls = TRUE ;

 /***************************************************************************
  * Get the frame handle.        					    *
  ***************************************************************************/

  HWND hwndFrame = WinQueryWindow ( hwnd, QW_PARENT ) ;

 /***************************************************************************
  * If controls aren't hidden yet, update the menu check-mark.              *
  ***************************************************************************/

  if ( Data->Profile.HideControls )
    CheckMenuItem ( hwndFrame, FID_SYSMENU, IDM_HIDE_CONTROLS, Data->Profile.HideControls ) ;

 /***************************************************************************
  * If not minimized right now, hide or reveal the controls.		    *
  ***************************************************************************/

  if ( NOT ( Data->Profile.Position.fl & SWP_MINIMIZE ) )
  {
    HideControls
    (
      Data->Profile.HideControls,
      hwndFrame,
      Data->hwndSysMenu,
      Data->hwndTitleBar,
      Data->hwndMinMax
    ) ;
  }

 /***************************************************************************
  * If controls are no longer hidden, update the menu check-mark.	    *
  ***************************************************************************/

  if ( NOT Data->Profile.HideControls )
    CheckMenuItem ( hwndFrame, FID_SYSMENU, IDM_HIDE_CONTROLS, Data->Profile.HideControls ) ;

 /***************************************************************************
  * Done.								    *
  ***************************************************************************/

  return ( MRFROMSHORT ( 0 ) ) ;
}

/****************************************************************************
 *									    *
 *	Process Configure command.					    *
 *									    *
 ****************************************************************************/

STATIC MRESULT APIENTRY Configure
( 
  HWND hwnd, 
  USHORT msg, 
  MPARAM mp1, 
  MPARAM mp2
)
{
 /***************************************************************************
  * Find the instance data.						    *
  ***************************************************************************/

  PDATA Data = (PDATA) WinQueryWindowPtr ( hwnd, QWL_USER ) ;

 /***************************************************************************
  * Invoke the Configure dialog.  If cancelled, just return.		    *
  ***************************************************************************/

  CONFIG_PARMS Parms ;
  Parms.id	      = IDD_CONFIGURE ;
  Parms.hwndHelp      = WinQueryHelpInstance ( hwnd ) ;
  Parms.HideControls  = Data->Profile.HideControls ;
  Parms.Float	      = Data->Profile.Float ;
  Parms.TimerInterval = Data->Profile.TimerInterval ;

  Parms.ItemCount     = Data->Profile.ItemCount ;

  PSZ  ItemNames [ ITEM_BASE_COUNT + MAX_DRIVES ] ;
  BOOL ItemFlags [ ITEM_BASE_COUNT + MAX_DRIVES ] ;
  for ( int i=0; i<Data->Profile.ItemCount; i++ )
  {
    ItemNames[i] = Data->Profile.Items[i]->QueryOption () ;
    ItemFlags[i] = Data->Profile.Items[i]->QueryFlag () ;
  }
  Parms.ItemNames = ItemNames ;
  Parms.ItemFlags = ItemFlags ;

  if ( WinDlgBox ( HWND_DESKTOP, hwnd, ConfigureProcessor,
    Data->Library, IDD_CONFIGURE, &Parms ) == FALSE )
  {
    return ( MRFROMSHORT ( 0 ) ) ;
  }

 /***************************************************************************
  * Save the new timer interval.					    *
  ***************************************************************************/

  Data->Profile.fTimerInterval = TRUE ;
  Data->Profile.TimerInterval = Parms.TimerInterval ;

 /***************************************************************************
  * Save the float-to-top flag. 					    *
  ***************************************************************************/

  Data->Profile.fFloat = TRUE ;
  Data->Profile.Float = Parms.Float ;

 /***************************************************************************
  * Save the hide controls flag, and adjust the window if it changed.	    *
  ***************************************************************************/

  Data->Profile.fHideControls = TRUE ;
  if ( Data->Profile.HideControls != Parms.HideControls )
  {
    HWND FrameWindow = WinQueryWindow ( hwnd, QW_PARENT ) ;
    Data->Profile.HideControls = Parms.HideControls ;
    if ( Data->Profile.HideControls )
      CheckMenuItem ( FrameWindow, FID_SYSMENU, IDM_HIDE_CONTROLS, Data->Profile.HideControls ) ;
    if ( NOT ( Data->Profile.Position.fl & SWP_MINIMIZE ) )
    {
      HideControls
      (
	Data->Profile.HideControls,
	FrameWindow,
	Data->hwndSysMenu,
	Data->hwndTitleBar,
	Data->hwndMinMax
      ) ;
    }
    if ( NOT Data->Profile.HideControls )
      CheckMenuItem ( FrameWindow, FID_SYSMENU, IDM_HIDE_CONTROLS, Data->Profile.HideControls ) ;
  }

 /***************************************************************************
  * Determine if the display item list has changed.  If not, return.	    *
  ***************************************************************************/

  BOOL ItemsChanged = FALSE ;
  for ( i=0; i<Data->Profile.ItemCount; i++ )
  {
    if ( ItemFlags[i] != Data->Profile.Items[i]->QueryFlag() )
    {
      ItemsChanged = TRUE ;
      break ;
    }
  }

  if ( NOT ItemsChanged )
  {
    return ( MRFROMSHORT ( 0 ) ) ;
  }

 /***************************************************************************
  * If CPU load monitoring has changed, start/stop the monitoring thread.   *
  ***************************************************************************/

  if ( ItemFlags[ITEM_CPULOAD] != Data->Profile.Items[ITEM_CPULOAD]->QueryFlag() )
  {
    if ( ItemFlags[ITEM_CPULOAD] )
      DosResumeThread ( Data->IdleLoopTID ) ;
    else
      DosSuspendThread ( Data->IdleLoopTID ) ;
  }

 /***************************************************************************
  * Save the new item flags.						    *
  ***************************************************************************/

  for ( i=0; i<Data->Profile.ItemCount; i++ )
  {
    if ( ItemFlags[i] )
      Data->Profile.Items[i]->SetFlag ( ) ;
    else
      Data->Profile.Items[i]->ResetFlag ( ) ;
  }

 /***************************************************************************
  * Resize the display window.						    *
  ***************************************************************************/

  ResizeWindow ( hwnd, &Data->Profile ) ;

 /***************************************************************************
  * Done.								    *
  ***************************************************************************/

  return ( MRFROMSHORT ( 0 ) ) ;
}

/****************************************************************************
 *									    *
 *	Process About menu command.					    *
 *									    *
 ****************************************************************************/

STATIC MRESULT APIENTRY About
( 
  HWND hwnd, 
  USHORT msg, 
  MPARAM mp1, 
  MPARAM mp2
)
{
 /***************************************************************************
  * Find the instance data.						    *
  ***************************************************************************/

  PDATA Data = (PDATA) WinQueryWindowPtr ( hwnd, QWL_USER ) ;

 /***************************************************************************
  * Invoke the About dialog.						    *
  ***************************************************************************/

  ABOUT_PARMS Parms ;
  Parms.id = IDD_ABOUT ;
  Parms.hwndHelp = WinQueryHelpInstance ( hwnd ) ;

  WinDlgBox ( HWND_DESKTOP, hwnd, AboutProcessor,
    Data->Library, IDD_ABOUT, &Parms ) ;

 /***************************************************************************
  * Done.								    *
  ***************************************************************************/

  return ( MRFROMSHORT ( 0 ) ) ;
}

/****************************************************************************
 *									    *
 *	Process Mouse Button being pressed.				    *
 *									    *
 ****************************************************************************/

STATIC MRESULT APIENTRY ButtonDown
(
  HWND hwnd,
  USHORT msg,
  MPARAM mp1,
  MPARAM mp2
)
{
 /***************************************************************************
  * Find the instance data.						    *
  ***************************************************************************/

  PDATA Data = (PDATA) WinQueryWindowPtr ( hwnd, QWL_USER ) ;

 /***************************************************************************
  * Determine the new window position.					    *
  ***************************************************************************/

  TRACKINFO TrackInfo ;
  memset ( &TrackInfo, 0, sizeof(TrackInfo) ) ;

  TrackInfo.cxBorder = 1 ;
  TrackInfo.cyBorder = 1 ;
  TrackInfo.cxGrid = 1 ;
  TrackInfo.cyGrid = 1 ;
  TrackInfo.cxKeyboard = 8 ;
  TrackInfo.cyKeyboard = 8 ;

  HWND hwndFrame = WinQueryWindow ( hwnd, QW_PARENT ) ;

  SWP Position ;
  WinQueryWindowPos ( hwndFrame, &Position ) ;
  TrackInfo.rclTrack.xLeft   = Position.x ;
  TrackInfo.rclTrack.xRight  = Position.x + Position.cx ;
  TrackInfo.rclTrack.yBottom = Position.y ;
  TrackInfo.rclTrack.yTop    = Position.y + Position.cy ;

  WinQueryWindowPos ( HWND_DESKTOP, &Position ) ;
  TrackInfo.rclBoundary.xLeft   = Position.x ;
  TrackInfo.rclBoundary.xRight  = Position.x + Position.cx ;
  TrackInfo.rclBoundary.yBottom = Position.y ;
  TrackInfo.rclBoundary.yTop    = Position.y + Position.cy ;

  TrackInfo.ptlMinTrackSize.x = 0 ;
  TrackInfo.ptlMinTrackSize.y = 0 ;
  TrackInfo.ptlMaxTrackSize.x = Position.cx ;
  TrackInfo.ptlMaxTrackSize.y = Position.cy ;

  TrackInfo.fs = TF_MOVE | TF_STANDARD | TF_ALLINBOUNDARY ;

  if ( WinTrackRect ( HWND_DESKTOP, NULL, &TrackInfo ) )
  {
    WinSetWindowPos ( hwndFrame, NULL,
      (SHORT) TrackInfo.rclTrack.xLeft,
      (SHORT) TrackInfo.rclTrack.yBottom,
      0, 0, SWP_MOVE ) ;
  }

 /***************************************************************************
  * Return through the default processor, letting window activation	    *
  *   and other system functions occur. 				    *
  ***************************************************************************/

  return ( WinDefWindowProc ( hwnd, msg, mp1, mp2 ) ) ;
}

/****************************************************************************
 *									    *
 *	Process Mouse Button having been double-clicked.		    *
 *									    *
 ****************************************************************************/

STATIC MRESULT APIENTRY ButtonDblClick
(
  HWND hwnd,
  USHORT msg,
  MPARAM mp1,
  MPARAM mp2
)
{
 /***************************************************************************
  * Send message to self to stop hiding the controls.			    *
  ***************************************************************************/

  WinPostMsg ( hwnd, WM_COMMAND,
    MPFROM2SHORT ( IDM_HIDE_CONTROLS, 0 ),
    MPFROM2SHORT ( CMDSRC_OTHER, TRUE ) ) ;

 /***************************************************************************
  * Return through the default processor, letting window activation	    *
  *   and other system functions occur. 				    *
  ***************************************************************************/

  return ( WinDefWindowProc ( hwnd, msg, mp1, mp2 ) ) ;
}

/****************************************************************************
 *									    *
 *	Process Presentation Parameter Changed notification.		    *
 *									    *
 ****************************************************************************/

STATIC MRESULT APIENTRY PresParamChanged
(
  HWND hwnd,
  USHORT msg,
  MPARAM mp1,
  MPARAM mp2
)
{
 /***************************************************************************
  * Find the instance data.						    *
  ***************************************************************************/

  PDATA Data = (PDATA) WinQueryWindowPtr ( hwnd, QWL_USER ) ;

 /***************************************************************************
  * Get the presentation parameter that changed.			    *
  ***************************************************************************/

  switch ( LONGFROMMP(mp1) )
  {

   /*************************************************************************
    * If font, note the fact that we now have a font to be saved as	    *
    *	part of the configuration.  Get the font metrics and resize	    *
    *	the window appropriately.					    *
    *************************************************************************/

    case PP_FONTNAMESIZE:
    {
      ULONG ppid ;
      if ( WinQueryPresParam ( hwnd, PP_FONTNAMESIZE, 0, &ppid,
	sizeof(Data->Profile.FontNameSize), &Data->Profile.FontNameSize,
	0 ) )
      {
	Data->Profile.fFontNameSize = TRUE ;
      }
      else
      {
	strcpy ( (PCHAR)Data->Profile.FontNameSize, "" ) ;
	Data->Profile.fFontNameSize = FALSE ;
	PrfWriteProfileData ( Data->ProfileHandle, (PSZ)PROGRAM_NAME, (PSZ)"FontNameSize", NULL, 0 ) ;
      }

      HPS hPS = WinGetPS ( hwnd ) ;
      RECTL Rectangle ;
      WinQueryWindowRect ( HWND_DESKTOP, &Rectangle ) ;
      WinDrawText ( hPS, 1, (PSZ)" ", &Rectangle, 0L, 0L, DT_LEFT | DT_BOTTOM | DT_QUERYEXTENT ) ;
      Data->Width  = Rectangle.xRight - Rectangle.xLeft ;
      Data->Height = Rectangle.yTop - Rectangle.yBottom ;
      WinReleasePS ( hPS ) ;
      ResizeWindow ( hwnd, &Data->Profile ) ;
      break ;
    }

   /*************************************************************************
    * If background color, note the fact and repaint the window.	    *
    *************************************************************************/

    case PP_BACKGROUNDCOLOR:
    {
      ULONG ppid ;
      if ( WinQueryPresParam ( hwnd, PP_BACKGROUNDCOLOR, 0, &ppid,
	sizeof(Data->Profile.BackColor), &Data->Profile.BackColor, 0 ) )
      {
	Data->Profile.fBackColor = TRUE ;
      }
      else
      {
	Data->Profile.BackColor = WinQuerySysColor ( HWND_DESKTOP, SYSCLR_WINDOW, 0L ) ;
	Data->Profile.fBackColor = FALSE ;
	PrfWriteProfileData ( Data->ProfileHandle, (PSZ)PROGRAM_NAME, (PSZ)"BackgroundColor", NULL, 0 ) ;
      }
      WinInvalidateRect ( hwnd, NULL, TRUE ) ;
      break ;
    }

   /*************************************************************************
    * If foreground color, note the fact and repaint the window.	    *
    *************************************************************************/

    case PP_FOREGROUNDCOLOR:
    {
      ULONG ppid ;
      if ( WinQueryPresParam ( hwnd, PP_FOREGROUNDCOLOR, 0, &ppid,
	sizeof(Data->Profile.TextColor), &Data->Profile.TextColor, 0 ) )
      {
	Data->Profile.fTextColor = TRUE ;
      }
      else
      {
	Data->Profile.TextColor = WinQuerySysColor ( HWND_DESKTOP, SYSCLR_OUTPUTTEXT, 0L ) ;
	Data->Profile.fTextColor = FALSE ;
	PrfWriteProfileData ( Data->ProfileHandle, (PSZ)PROGRAM_NAME, (PSZ)"ForegroundColor", NULL, 0 ) ;
      }
      WinInvalidateRect ( hwnd, NULL, TRUE ) ;
      break ;
    }
  }

 /***************************************************************************
  * Return through the default processor, letting window activation	    *
  *   and other system functions occur. 				    *
  ***************************************************************************/

  return ( WinDefWindowProc ( hwnd, msg, mp1, mp2 ) ) ;
}

/****************************************************************************
 *									    *
 *	Process System Color Change notification.			    *
 *									    *
 ****************************************************************************/

STATIC MRESULT APIENTRY SysColorChange
(
  HWND hwnd,
  USHORT msg,
  MPARAM mp1,
  MPARAM mp2
)
{
 /***************************************************************************
  * Find the instance data.						    *
  ***************************************************************************/

  PDATA Data = (PDATA) WinQueryWindowPtr ( hwnd, QWL_USER ) ;

 /***************************************************************************
  * If we aren't using custom colors, then query for the new defaults.      *
  ***************************************************************************/

  if ( NOT Data->Profile.fBackColor )
  {
    Data->Profile.BackColor = WinQuerySysColor ( HWND_DESKTOP, SYSCLR_WINDOW, 0L ) ;
  }

  if ( NOT Data->Profile.fTextColor )
  {
    Data->Profile.TextColor = WinQuerySysColor ( HWND_DESKTOP, SYSCLR_OUTPUTTEXT, 0L ) ;
  }

 /***************************************************************************
  * Return value must be NULL, according to the documentation.		    *
  ***************************************************************************/

  return ( MRFROMP ( NULL ) ) ;
}

/****************************************************************************
 *									    *
 *	Process Query for Keys Help resource id.			    *
 *									    *
 ****************************************************************************/

STATIC MRESULT APIENTRY QueryKeysHelp
(
  HWND hwnd,
  USHORT msg,
  MPARAM mp1,
  MPARAM mp2
)
{
 /***************************************************************************
  * Simply return the ID of the Keys Help panel.			    *
  ***************************************************************************/

  return ( (MRESULT) IDM_KEYS_HELP ) ;
}

/****************************************************************************
 *									    *
 *	Process Help Manager Error					    *
 *									    *
 ****************************************************************************/

STATIC MRESULT APIENTRY HelpError
( 
  HWND hwnd, 
  USHORT msg, 
  MPARAM mp1, 
  MPARAM mp2
)
{
 /***************************************************************************
  * Local Declarations							    *
  ***************************************************************************/

  static struct
  {
    ULONG Error ;
    USHORT StringId ;
  }
  HelpErrors [] =
  {
    { HMERR_NO_FRAME_WND_IN_CHAIN,     IDS_HMERR_NO_FRAME_WND_IN_CHAIN },
    { HMERR_INVALID_ASSOC_APP_WND,     IDS_HMERR_INVALID_ASSOC_APP_WND },
    { HMERR_INVALID_ASSOC_HELP_INST,   IDS_HMERR_INVALID_ASSOC_HELP_IN },
    { HMERR_INVALID_DESTROY_HELP_INST, IDS_HMERR_INVALID_DESTROY_HELP_ },
    { HMERR_NO_HELP_INST_IN_CHAIN,     IDS_HMERR_NO_HELP_INST_IN_CHAIN },
    { HMERR_INVALID_HELP_INSTANCE_HDL, IDS_HMERR_INVALID_HELP_INSTANCE },
    { HMERR_INVALID_QUERY_APP_WND,     IDS_HMERR_INVALID_QUERY_APP_WND },
    { HMERR_HELP_INST_CALLED_INVALID,  IDS_HMERR_HELP_INST_CALLED_INVA },
    { HMERR_HELPTABLE_UNDEFINE,        IDS_HMERR_HELPTABLE_UNDEFINE    },
    { HMERR_HELP_INSTANCE_UNDEFINE,    IDS_HMERR_HELP_INSTANCE_UNDEFIN },
    { HMERR_HELPITEM_NOT_FOUND,        IDS_HMERR_HELPITEM_NOT_FOUND    },
    { HMERR_INVALID_HELPSUBITEM_SIZE,  IDS_HMERR_INVALID_HELPSUBITEM_S },
    { HMERR_HELPSUBITEM_NOT_FOUND,     IDS_HMERR_HELPSUBITEM_NOT_FOUND },
    { HMERR_INDEX_NOT_FOUND,	       IDS_HMERR_INDEX_NOT_FOUND       },
    { HMERR_CONTENT_NOT_FOUND,	       IDS_HMERR_CONTENT_NOT_FOUND     },
    { HMERR_OPEN_LIB_FILE,	       IDS_HMERR_OPEN_LIB_FILE	       },
    { HMERR_READ_LIB_FILE,	       IDS_HMERR_READ_LIB_FILE	       },
    { HMERR_CLOSE_LIB_FILE,	       IDS_HMERR_CLOSE_LIB_FILE        },
    { HMERR_INVALID_LIB_FILE,	       IDS_HMERR_INVALID_LIB_FILE      },
    { HMERR_NO_MEMORY,		       IDS_HMERR_NO_MEMORY	       },
    { HMERR_ALLOCATE_SEGMENT,	       IDS_HMERR_ALLOCATE_SEGMENT      },
    { HMERR_FREE_MEMORY,	       IDS_HMERR_FREE_MEMORY	       },
    { HMERR_PANEL_NOT_FOUND,	       IDS_HMERR_PANEL_NOT_FOUND       },
    { HMERR_DATABASE_NOT_OPEN,	       IDS_HMERR_DATABASE_NOT_OPEN     },
    { 0,			       IDS_HMERR_UNKNOWN	       }
  } ;

  ULONG ErrorCode = (ULONG) LONGFROMMP ( mp1 ) ;

 /***************************************************************************
  * Find the instance data.						    *
  ***************************************************************************/

  PDATA Data = (PDATA) WinQueryWindowPtr ( hwnd, QWL_USER ) ;

 /***************************************************************************
  * Find the error code in the message table.				    *
  ***************************************************************************/

  int Index = 0 ;
  while ( HelpErrors[Index].Error
    AND ( HelpErrors[Index].Error != ErrorCode ) )
  {
    Index ++ ;
  }

 /***************************************************************************
  * Get the message texts.						    *
  ***************************************************************************/

  ResourceString Title ( Data->Library, IDS_HMERR ) ;

  ResourceString Message ( Data->Library, HelpErrors[Index].StringId ) ;

 /***************************************************************************
  * Display the error message.						    *
  ***************************************************************************/

  WinMessageBox
  (
    HWND_DESKTOP,
    hwnd,
    Message.Ptr(),
    Title.Ptr(),
    0,
    MB_OK | MB_WARNING
  ) ;

 /***************************************************************************
  * Return zero, indicating that the message was processed.		    *
  ***************************************************************************/

  return ( MRFROMSHORT ( 0 ) ) ;
}

/****************************************************************************
 *									    *
 *	Process "Extended Help Undefined" notification			    *
 *									    *
 ****************************************************************************/

STATIC MRESULT APIENTRY ExtHelpUndefined
( 
  HWND hwnd, 
  USHORT msg, 
  MPARAM mp1, 
  MPARAM mp2
)
{
 /***************************************************************************
  * Find the instance data.						    *
  ***************************************************************************/

  PDATA Data = (PDATA) WinQueryWindowPtr ( hwnd, QWL_USER ) ;

 /***************************************************************************
  * Get the message texts.						    *
  ***************************************************************************/

  ResourceString Title ( Data->Library, IDS_HMERR ) ;

  ResourceString Message ( Data->Library, IDS_HMERR_EXTHELPUNDEFINED ) ;

 /***************************************************************************
  * Display the error message.						    *
  ***************************************************************************/

  WinMessageBox
  (
    HWND_DESKTOP,
    hwnd,
    Message.Ptr(),
    Title.Ptr(),
    0,
    MB_OK | MB_WARNING
  ) ;

 /***************************************************************************
  * Return zero, indicating that the message was processed.		    *
  ***************************************************************************/

  return ( MRFROMSHORT ( 0 ) ) ;
}

/****************************************************************************
 *									    *
 *	Process "Help Subitem Not Found" notification			    *
 *									    *
 ****************************************************************************/

STATIC MRESULT APIENTRY HelpSubitemNotFound
( 
  HWND hwnd, 
  USHORT msg, 
  MPARAM mp1, 
  MPARAM mp2
)
{
 /***************************************************************************
  * Find the instance data.						    *
  ***************************************************************************/

  PDATA Data = (PDATA) WinQueryWindowPtr ( hwnd, QWL_USER ) ;

 /***************************************************************************
  * Get the title text. 						    *
  ***************************************************************************/

  ResourceString Title ( Data->Library, IDS_HMERR ) ;

 /***************************************************************************
  * Format the error message.						    *
  ***************************************************************************/

  USHORT Topic = (USHORT) SHORT1FROMMP ( mp2 ) ;
  USHORT Subtopic = (USHORT) SHORT2FROMMP ( mp2 ) ;

  ResourceString Frame	 ( Data->Library, IDS_HELPMODE_FRAME ) ;
  ResourceString Menu	 ( Data->Library, IDS_HELPMODE_MENU ) ;
  ResourceString Window  ( Data->Library, IDS_HELPMODE_WINDOW ) ;
  ResourceString Unknown ( Data->Library, IDS_HELPMODE_UNKNOWN ) ;

  PBYTE Mode ;
  switch ( SHORT1FROMMP ( mp1 ) )
  {
    case HLPM_FRAME:
      Mode = Frame.Ptr() ;
      break ;

    case HLPM_MENU:
      Mode = Menu.Ptr() ;
      break ;

    case HLPM_WINDOW:
      Mode = Window.Ptr() ;
      break ;

    default:
      Mode = Unknown.Ptr() ;
  }

  ResourceString Format ( Data->Library, IDS_HELPSUBITEMNOTFOUND ) ;

  BYTE Message [200] ;
  sprintf ( (PCHAR)Message, PCHAR(Format.Ptr()), Mode, Topic, Subtopic ) ;

 /***************************************************************************
  * Display the error message.						    *
  ***************************************************************************/

  WinMessageBox
  (
    HWND_DESKTOP,
    hwnd,
    Message,
    Title.Ptr(),
    0,
    MB_OK | MB_WARNING
  ) ;

 /***************************************************************************
  * Return zero, indicating that the message was processed.		    *
  ***************************************************************************/

  return ( MRFROMSHORT ( 0 ) ) ;
}

/****************************************************************************
 *									    *
 *	Process Refresh message.					    *
 *									    *
 ****************************************************************************/

STATIC MRESULT APIENTRY Refresh
( 
  HWND hwnd, 
  USHORT msg, 
  MPARAM mp1, 
  MPARAM mp2
)
{
 /***************************************************************************
  * Find the instance data.						    *
  ***************************************************************************/

  PDATA Data = (PDATA) WinQueryWindowPtr ( hwnd, QWL_USER ) ;

 /***************************************************************************
  * If we're supposed to float the window, do so here.                      *
  ***************************************************************************/

  if ( Data->Profile.Float )
    WinSetWindowPos ( WinQueryWindow(hwnd,QW_PARENT), HWND_TOP, 0, 0, 0, 0, SWP_ZORDER ) ;

 /***************************************************************************
  * Save the idle counter.						    *
  ***************************************************************************/

  Data->Profile.IdleCount = LONGFROMMP ( mp1 ) ;

 /***************************************************************************
  * Determine if drive mask has changed.				    *
  ***************************************************************************/

  ULONG Drive ;
  ULONG Drives ;
  DosQueryCurrentDisk ( &Drive, &Drives ) ;

  if ( Drives != Data->Drives )
  {
   /*************************************************************************
    * It has.  First save the display options.				    *
    *************************************************************************/

    SaveApplication ( hwnd, WM_SAVEAPPLICATION, 0, 0 ) ;

   /*************************************************************************
    * Next, update the drive item list. 				    *
    *************************************************************************/

    UpdateDriveList ( Data->Anchor, Data->Library, Data->ProfileHandle, 
      &Data->Profile, Data->Drives, Drives ) ;

   /*************************************************************************
    * If the controls are hidden, hide the whole window and reveal the	    *
    *	controls.  Otherwise the menu wouldn't get updated correctly.       *
    *************************************************************************/

    if ( Data->Profile.HideControls )
    {
      WinShowWindow ( WinQueryWindow(hwnd,QW_PARENT), FALSE ) ;
      HideControls
      (
	FALSE,
	WinQueryWindow ( hwnd, QW_PARENT ),
	Data->hwndSysMenu,
	Data->hwndTitleBar,
	Data->hwndMinMax
      ) ;
    }

   /*************************************************************************
    * If the controls were supposed to be hidden, hide them once more and   *
    *	show the window to the world again.				    *
    *************************************************************************/

    if ( Data->Profile.HideControls )
    {
      HideControls
      (
	TRUE,
	WinQueryWindow ( hwnd, QW_PARENT ),
	Data->hwndSysMenu,
	Data->hwndTitleBar,
	Data->hwndMinMax
      ) ;
      WinShowWindow ( WinQueryWindow(hwnd,QW_PARENT), TRUE ) ;
    }

   /*************************************************************************
    * Save the updated drive mask.					    *
    *************************************************************************/

    Data->Drives = Drives ;

   /*************************************************************************
    * Resize the window to accommodate the new option list.		    *
    *************************************************************************/

    ResizeWindow ( hwnd, &Data->Profile ) ;
  }

 /***************************************************************************
  * Update the statistics.						    *
  ***************************************************************************/

  UpdateWindow ( hwnd, Data, FALSE ) ;

 /***************************************************************************
  * Return zero, indicating that the message was processed.		    *
  ***************************************************************************/

  return ( MRFROMSHORT ( 0 ) ) ;
}


/****************************************************************************
 *									    *
 *			     Get Profile Data				    *
 *									    *
 ****************************************************************************/

STATIC int GetProfile ( HAB Anchor, HMODULE Library, HINI ProfileHandle, PPROFILE Profile )
{
 /***************************************************************************
  * Get the window's current size and position.                             *
  ***************************************************************************/

  #pragma pack(2)
  typedef struct {
    USHORT Filler ;
    USHORT fs ;
    USHORT cy, cx, y, x ;
    HWND hwndInsertBehind ;
    HWND hwnd ;
  } OLDSWP ;
  #pragma pack()

  ULONG Size ;
  memset ( &Profile->Position, 0, sizeof(Profile->Position) ) ;
  Profile->fPosition = FALSE ;
  if ( PrfQueryProfileSize ( ProfileHandle, (PSZ)PROGRAM_NAME, (PSZ)"Position", &Size ) )
  {
    if ( Size == sizeof(OLDSWP)-sizeof(USHORT) )
    {
      OLDSWP OldPosition ;
      if ( PrfQueryProfileData ( ProfileHandle, (PSZ)PROGRAM_NAME, (PSZ)"Position", &OldPosition.fs, &Size ) )
      {
        Profile->Position.fl = OldPosition.fs ;
        Profile->Position.cy = OldPosition.cy ;
        Profile->Position.cx = OldPosition.cx ;
        Profile->Position.y = OldPosition.y ;
        Profile->Position.x = OldPosition.x ;
        Profile->Position.hwndInsertBehind = OldPosition.hwndInsertBehind ;
        Profile->Position.hwnd = OldPosition.hwnd ;
        Profile->fPosition = TRUE ;
      }
    }
    else if ( Size == sizeof(Profile->Position) )
    {
      if ( PrfQueryProfileData ( ProfileHandle, (PSZ)PROGRAM_NAME, (PSZ)"Position", &Profile->Position, &Size ) )
      {
        Profile->fPosition = TRUE ;
      }
    }
  }

  if ( NOT Profile->fPosition )
  {
    if ( ProfileHandle == HINI_USERPROFILE )
    {
      return ( 1 ) ;
    }
  }

 /***************************************************************************
  * Get the program options.						    *
  ***************************************************************************/

  Profile->HideControls = FALSE ;
  Profile->fHideControls = FALSE ;
  if 
  ( 
    PrfQueryProfileSize ( ProfileHandle, (PSZ)PROGRAM_NAME, (PSZ)"HideControls", &Size )
    AND
    ( ( Size == sizeof(Profile->HideControls) ) OR ( Size == sizeof(short) ) )
    AND
    PrfQueryProfileData ( ProfileHandle, (PSZ)PROGRAM_NAME, (PSZ)"HideControls", &Profile->HideControls, &Size )
  )
  {
    Profile->fHideControls = TRUE ;
  }

  Profile->Float = FALSE ;
  Profile->fFloat = FALSE ;
  if 
  ( 
    PrfQueryProfileSize ( ProfileHandle, (PSZ)PROGRAM_NAME, (PSZ)"Float", &Size )
    AND
    ( ( Size == sizeof(Profile->Float) ) OR ( Size == sizeof(short) ) )
    AND
    PrfQueryProfileData ( ProfileHandle, (PSZ)PROGRAM_NAME, (PSZ)"Float", &Profile->Float, &Size )
  )
  {
    Profile->fFloat = TRUE ;
  }

  Profile->TimerInterval = 1000 ;
  Profile->fTimerInterval = FALSE ;
  if 
  ( 
    PrfQueryProfileSize ( ProfileHandle, (PSZ)PROGRAM_NAME, (PSZ)"TimerInterval", &Size )
    AND
    ( ( Size == sizeof(Profile->TimerInterval) ) OR ( Size == sizeof(short) ) )
    AND
    PrfQueryProfileData ( ProfileHandle, (PSZ)PROGRAM_NAME, (PSZ)"TimerInterval", &Profile->TimerInterval, &Size ) 
  )
  {
    Profile->fTimerInterval = TRUE ;
  }

 /***************************************************************************
  * Get the presentation parameters.					    *
  ***************************************************************************/

  strcpy ( (PCHAR)Profile->FontNameSize, "" ) ;
  Profile->fFontNameSize = FALSE ;
  if
  (
    PrfQueryProfileSize ( ProfileHandle, (PSZ)PROGRAM_NAME, (PSZ)"FontNameSize", &Size )
    AND
    ( Size == sizeof(Profile->FontNameSize) )
    AND
    PrfQueryProfileData ( ProfileHandle, (PSZ)PROGRAM_NAME, (PSZ)"FontNameSize", &Profile->FontNameSize, &Size )
  )
  {
    Profile->fFontNameSize = TRUE ;
  }

  Profile->BackColor = WinQuerySysColor ( HWND_DESKTOP, SYSCLR_WINDOW, 0L ) ;
  Profile->fBackColor = FALSE ;
  if
  (
    PrfQueryProfileSize ( ProfileHandle, (PSZ)PROGRAM_NAME, (PSZ)"BackgroundColor", &Size )
    AND
    ( Size == sizeof(Profile->BackColor) )
    AND
    PrfQueryProfileData ( ProfileHandle, (PSZ)PROGRAM_NAME, (PSZ)"BackgroundColor", &Profile->BackColor, &Size )
  )
  {
    Profile->fBackColor = TRUE ;
  }

  Profile->TextColor = WinQuerySysColor ( HWND_DESKTOP, SYSCLR_OUTPUTTEXT, 0L ) ;
  Profile->fTextColor = FALSE ;
  if
  (
    PrfQueryProfileSize ( ProfileHandle, (PSZ)PROGRAM_NAME, (PSZ)"ForegroundColor", &Size )
    AND
    ( Size == sizeof(Profile->TextColor) )
    AND
    PrfQueryProfileData ( ProfileHandle, (PSZ)PROGRAM_NAME, (PSZ)"ForegroundColor", &Profile->TextColor, &Size )
  )
  {
    Profile->fTextColor = TRUE ;
  }

 /***************************************************************************
  * Build the fixed portion of the item list.				    *
  ***************************************************************************/

  ResourceString ClockLabel ( Library, IDS_SHOW_CLOCK_LABEL ) ;
  ResourceString ClockOption ( Library, IDS_SHOW_CLOCK_OPTION ) ;
  Profile->Items[ITEM_CLOCK] = new Clock ( ITEM_CLOCK,
    PSZ("ShowClock"), ClockLabel.Ptr(), ClockOption.Ptr(),
    Profile->CountryInfo, Profile->DaysOfWeek ) ;

  ResourceString ElapsedLabel ( Library, IDS_SHOW_ELAPSED_LABEL ) ;
  ResourceString ElapsedOption ( Library, IDS_SHOW_ELAPSED_OPTION ) ;
  Profile->Items[ITEM_ELAPSEDTIME] = new ElapsedTime ( ITEM_ELAPSEDTIME,
    PSZ("ShowElapsed"), ElapsedLabel.Ptr(), ElapsedOption.Ptr(),
    Profile->CountryInfo,
    Profile->Day,
    Profile->Days ) ;

  ResourceString SwapSizeLabel ( Library, IDS_SHOW_SWAPSIZE_LABEL ) ;
  ResourceString SwapSizeOption ( Library, IDS_SHOW_SWAPSIZE_OPTION ) ;
  Profile->Items[ITEM_SWAPFILESIZE] = new SwapSize ( ITEM_SWAPFILESIZE,
    PSZ("ShowSwapsize"), SwapSizeLabel.Ptr(), SwapSizeOption.Ptr(),
    Profile->CountryInfo,
    Profile->SwapPath ) ;

  ResourceString SwapFreeLabel ( Library, IDS_SHOW_SWAPFREE_LABEL ) ;
  ResourceString SwapFreeOption ( Library, IDS_SHOW_SWAPFREE_OPTION ) ;
  Profile->Items[ITEM_SWAPDISKFREE] = new SwapFree ( ITEM_SWAPDISKFREE,
    PSZ("ShowSwapfree"), SwapFreeLabel.Ptr(), SwapFreeOption.Ptr(),
    Profile->CountryInfo,
    Profile->SwapPath,
    Profile->MinFree ) ;

  ResourceString MemoryLabel ( Library, IDS_SHOW_MEMORY_LABEL ) ;
  ResourceString MemoryOption ( Library, IDS_SHOW_MEMORY_OPTION ) ;
  Profile->Items[ITEM_MEMORYFREE] = new MemoryFree ( ITEM_MEMORYFREE,
    PSZ("ShowMemory"), MemoryLabel.Ptr(), MemoryOption.Ptr(),
    Profile->CountryInfo,
    (SwapFree*)Profile->Items[ITEM_SWAPDISKFREE] ) ;

  ResourceString SpoolSizeLabel ( Library, IDS_SHOW_SPOOLSIZE_LABEL ) ;
  ResourceString SpoolSizeOption ( Library, IDS_SHOW_SPOOLSIZE_OPTION ) ;
  Profile->Items[ITEM_SPOOLFILESIZE] = new SpoolSize ( ITEM_SPOOLFILESIZE,
    PSZ("ShowSpoolSize"), SpoolSizeLabel.Ptr(), SpoolSizeOption.Ptr(),
    Profile->CountryInfo,
    Profile->SpoolPath ) ;

  ResourceString CpuLoadLabel ( Library, IDS_SHOW_CPULOAD_LABEL ) ;
  ResourceString CpuLoadOption ( Library, IDS_SHOW_CPULOAD_OPTION ) ;
  Profile->Items[ITEM_CPULOAD] = new CpuLoad ( ITEM_CPULOAD,
    PSZ("ShowCpuLoad"), CpuLoadLabel.Ptr(), CpuLoadOption.Ptr(),
    Profile->MaxCount,
    &Profile->IdleCount ) ;

  ResourceString TaskCountLabel ( Library, IDS_SHOW_TASKCOUNT_LABEL ) ;
  ResourceString TaskCountOption ( Library, IDS_SHOW_TASKCOUNT_OPTION ) ;
  Profile->Items[ITEM_TASKCOUNT] = new TaskCount ( ITEM_TASKCOUNT,
    PSZ("ShowTaskCount"), TaskCountLabel.Ptr(), TaskCountOption.Ptr(),
    Anchor ) ;

  ResourceString TotalFreeLabel ( Library, IDS_SHOW_TOTALFREE_LABEL ) ;
  ResourceString TotalFreeOption ( Library, IDS_SHOW_TOTALFREE_OPTION ) ;
  Profile->Items[ITEM_TOTALFREE] = new TotalFree ( ITEM_TOTALFREE,
    PSZ("ShowTotalFree"), TotalFreeLabel.Ptr(), TotalFreeOption.Ptr(),
    Profile->CountryInfo, 0 ) ;

  for ( int i=0; i<ITEM_BASE_COUNT; i++ )
  {
    BOOL Flag = TRUE ;
    if 
    ( 
      PrfQueryProfileSize ( ProfileHandle, (PSZ)PROGRAM_NAME, Profile->Items[i]->QueryName(), &Size )
      AND
      ( ( Size == sizeof(Flag) ) OR ( Size == sizeof(short) ) )
      AND 
      PrfQueryProfileData ( ProfileHandle, (PSZ)PROGRAM_NAME, Profile->Items[i]->QueryName(), &Flag, &Size )
    )
    {
      ;
    }

    if ( Flag )
      Profile->Items[i]->SetFlag() ;
    else
      Profile->Items[i]->ResetFlag() ;
  }

 /***************************************************************************
  * Add items for each drive on the system.				    *
  ***************************************************************************/

  ULONG Drive, Drives ;
  DosQueryCurrentDisk ( &Drive, &Drives ) ;
  UpdateDriveList ( Anchor, Library, ProfileHandle, Profile, 0, Drives ) ;

  return ( 0 ) ;
}

/****************************************************************************
 *									    *
 *			     Put Profile Data				    *
 *									    *
 ****************************************************************************/

STATIC void PutProfile ( HINI ProfileHandle, PPROFILE Profile )
{
 /***************************************************************************
  * Save the window's current size and position.                            *
  ***************************************************************************/

  PrfWriteProfileData
  (
    ProfileHandle,
    (PSZ)PROGRAM_NAME,
    (PSZ)"Position",
    &Profile->Position,
    sizeof(Profile->Position)
  ) ;

 /***************************************************************************
  * Save the program options.						    *
  ***************************************************************************/

  if ( Profile->fHideControls )
  {
    PrfWriteProfileData
    (
      ProfileHandle,
      (PSZ)PROGRAM_NAME,
      (PSZ)"HideControls",
      &Profile->HideControls,
      sizeof(Profile->HideControls)
    ) ;
  }

  if ( Profile->fFloat )
  {
    PrfWriteProfileData
    (
      ProfileHandle,
      (PSZ)PROGRAM_NAME,
      (PSZ)"Float",
      &Profile->Float,
      sizeof(Profile->Float)
    ) ;
  }

  if ( Profile->fTimerInterval )
  {
    PrfWriteProfileData
    (
      ProfileHandle,
      (PSZ)PROGRAM_NAME,
      (PSZ)"TimerInterval",
      &Profile->TimerInterval,
      sizeof(Profile->TimerInterval)
    ) ;
  }

 /***************************************************************************
  * Save the item options.						    *
  ***************************************************************************/

  for ( int i=0; i<Profile->ItemCount; i++ )
  {
    Item *pItem = Profile->Items [i] ;
    BOOL Flag = pItem->QueryFlag() ;

    PrfWriteProfileData
    (
      ProfileHandle,
      PSZ(PROGRAM_NAME),
      pItem->QueryName(),
      &Flag,
      sizeof(Flag)
    ) ;
  }

 /***************************************************************************
  * Save the presentation parameters.					    *
  ***************************************************************************/

  if ( Profile->fFontNameSize )
  {
    PrfWriteProfileData
    (
      ProfileHandle,
      (PSZ)PROGRAM_NAME,
      (PSZ)"FontNameSize",
      Profile->FontNameSize,
      sizeof(Profile->FontNameSize)
    ) ;
  }

  if ( Profile->fBackColor )
  {
    PrfWriteProfileData
    (
      ProfileHandle,
      (PSZ)PROGRAM_NAME,
      (PSZ)"BackgroundColor",
      &Profile->BackColor,
      sizeof(Profile->BackColor)
    ) ;
  }

  if ( Profile->fTextColor )
  {
    PrfWriteProfileData
    (
      ProfileHandle,
      (PSZ)PROGRAM_NAME,
      (PSZ)"ForegroundColor",
      &Profile->TextColor,
      sizeof(Profile->TextColor)
    ) ;
  }
}

/****************************************************************************
 *									    *
 *	Scan CONFIG.SYS for a keyword.	Return the value.		    *
 *									    *
 ****************************************************************************/

STATIC PSZ ScanSystemConfig ( HAB Anchor, PSZ Keyword )
{
 /***************************************************************************
  * Get the boot drive number from the global information segment.	    *
  ***************************************************************************/

  ULONG BootDrive ;
  DosQuerySysInfo ( QSV_BOOT_DRIVE, QSV_BOOT_DRIVE, &BootDrive, sizeof(BootDrive) ) ;

 /***************************************************************************
  * Convert the keyword to upper case.                                      *
  ***************************************************************************/

  WinUpper ( Anchor, NULL, NULL, Keyword ) ;

 /***************************************************************************
  * Build the CONFIG.SYS path.						    *
  ***************************************************************************/

  char Path [_MAX_PATH] ;
  Path[0] = (char) ( BootDrive + 'A' - 1 ) ;
  Path[1] = 0 ;
  strcat ( Path, ":\\CONFIG.SYS" ) ;

 /***************************************************************************
  * Open CONFIG.SYS for reading.					    *
  ***************************************************************************/

  FILE *File = fopen ( Path, "rt" ) ;
  if ( NOT File )
  {
    return ( NULL ) ;
  }

 /***************************************************************************
  * While there're more lines in CONFIG.SYS, read a line and check it.      *
  ***************************************************************************/

  static char Buffer [500] ;
  while ( fgets ( Buffer, sizeof(Buffer), File ) )
  {

   /*************************************************************************
    * Clean any trailing newline character from the input string.	    *
    *************************************************************************/

    if ( Buffer[strlen(Buffer)-1] == '\n' )
    {
      Buffer[strlen(Buffer)-1] = 0 ;
    }

   /*************************************************************************
    * If keyword starts the line, we've found the line we want.  Close      *
    *	the file and return a pointer to the parameter text.		    *
    *************************************************************************/

    WinUpper ( Anchor, NULL, NULL, (PSZ)Buffer ) ;

    if ( NOT strncmp ( Buffer, (PCHAR)Keyword, strlen((PCHAR)Keyword) )
      AND ( Buffer[strlen((PCHAR)Keyword)] == '=' ) )
    {
      fclose ( File ) ;
      return ( (PSZ) ( Buffer + strlen((PCHAR)Keyword) + 1 ) ) ;
    }
  }

 /***************************************************************************
  * Close the file.  We haven't found the line we wanted.                   *
  ***************************************************************************/

  fclose ( File ) ;

  return ( NULL ) ;
}

/****************************************************************************
 *									    *
 *			 Resize Client Window				    *
 *									    *
 ****************************************************************************/

STATIC void ResizeWindow ( HWND hwnd, PPROFILE Profile )
{
 /***************************************************************************
  * If the window is visible and minimized, restore it invisibly.	    *
  ***************************************************************************/

  HWND hwndFrame = WinQueryWindow ( hwnd, QW_PARENT ) ;

  SHORT fHadToHide = FALSE ;
  SHORT fHadToRestore = FALSE ;
  if ( Profile->Position.fl & SWP_MINIMIZE )
  {
    if ( WinIsWindowVisible ( hwndFrame ) )
    {
      WinShowWindow ( hwndFrame, FALSE ) ;
      fHadToHide = TRUE ;
    }
    WinSetWindowPos ( hwndFrame, NULL, 0, 0, 0, 0, SWP_RESTORE ) ;
    fHadToRestore = TRUE ;
  }

 /***************************************************************************
  * Determine how many items are to be displayed.			    *
  ***************************************************************************/

  HPS hPS = WinGetPS ( hwnd ) ;

  int Count = 0 ;
  LONG Widest = 0 ;
  LONG Height = 0 ;

  for ( int i=0; i<Profile->ItemCount; i++ )
  {
    Item *pItem = Profile->Items [i] ;

    if ( pItem->QueryFlag() )
    {
      Count ++ ;

      BYTE Text [100] ;
      sprintf ( (PCHAR)Text, "%s 1,234,567K", pItem->QueryLabel() ) ;

      RECTL Rectangle ;
      WinQueryWindowRect ( HWND_DESKTOP, &Rectangle ) ;

      WinDrawText ( hPS, strlen((PCHAR)Text), Text,
	&Rectangle, 0L, 0L, DT_LEFT | DT_BOTTOM | DT_QUERYEXTENT ) ;

      Widest = max ( Widest, (Rectangle.xRight-Rectangle.xLeft+1) ) ;

      Height += Rectangle.yTop - Rectangle.yBottom ;
    }
  }

  WinReleasePS ( hPS ) ;

 /***************************************************************************
  * Get the window's current size & position.                               *
  ***************************************************************************/

  RECTL Rectangle ;
  WinQueryWindowRect ( hwndFrame, &Rectangle ) ;

  WinCalcFrameRect ( hwndFrame, &Rectangle, TRUE ) ;

 /***************************************************************************
  * Adjust the window's width & height.                                     *
  ***************************************************************************/

  Rectangle.xRight  = Rectangle.xLeft + Widest ;

  Rectangle.yTop    = Rectangle.yBottom + Height ;

 /***************************************************************************
  * Compute new frame size and apply it.				    *
  ***************************************************************************/

  WinCalcFrameRect ( hwndFrame, &Rectangle, FALSE ) ;

  WinSetWindowPos ( hwndFrame, NULL, 0, 0,
    (SHORT) (Rectangle.xRight-Rectangle.xLeft),
    (SHORT) (Rectangle.yTop-Rectangle.yBottom),
    SWP_SIZE ) ;

 /***************************************************************************
  * Return the window to its original state.				    *
  ***************************************************************************/

  if ( fHadToRestore )
  {
    WinSetWindowPos ( hwndFrame, NULL,
      Profile->Position.x, Profile->Position.y,
      Profile->Position.cx, Profile->Position.cy,
      SWP_MOVE | SWP_SIZE | SWP_MINIMIZE ) ;
  }

  if ( fHadToHide )
  {
    WinShowWindow ( hwndFrame, TRUE ) ;
  }

 /***************************************************************************
  * Invalidate the window so that it gets repainted.			    *
  ***************************************************************************/

  WinInvalidateRect ( hwnd, NULL, TRUE ) ;
}

/****************************************************************************
 *									    *
 *			Hide Window Controls				    *
 *									    *
 ****************************************************************************/

STATIC void HideControls
(
  BOOL fHide,
  HWND hwndFrame,
  HWND hwndSysMenu,
  HWND hwndTitleBar,
  HWND hwndMinMax
)
{
 /***************************************************************************
  * Get original window position and state.				    *
  ***************************************************************************/

  SWP OldPosition ;
  WinQueryWindowPos ( hwndFrame, &OldPosition ) ;

  BOOL WasVisible = WinIsWindowVisible ( hwndFrame ) ;

 /***************************************************************************
  * Restore and hide the window.					    *
  ***************************************************************************/

  WinSetWindowPos ( hwndFrame, NULL, 0, 0, 0, 0, SWP_RESTORE | SWP_HIDE ) ;

 /***************************************************************************
  * Determine client window and location.				    *
  ***************************************************************************/

  SWP Position ;
  WinQueryWindowPos ( hwndFrame, &Position ) ;

  RECTL Rectangle ;
  Rectangle.xLeft   = Position.x ;
  Rectangle.xRight  = Position.x + Position.cx ;
  Rectangle.yBottom = Position.y ;
  Rectangle.yTop    = Position.y + Position.cy ;

  WinCalcFrameRect ( hwndFrame, &Rectangle, TRUE ) ;

 /***************************************************************************
  * Hide or reveal the controls windows by changing their parentage.	    *
  ***************************************************************************/

  if ( fHide )
  {
    WinSetParent ( hwndSysMenu,  HWND_OBJECT, FALSE ) ;
    WinSetParent ( hwndTitleBar, HWND_OBJECT, FALSE ) ;
    WinSetParent ( hwndMinMax,	 HWND_OBJECT, FALSE ) ;
  }
  else
  {
    WinSetParent ( hwndSysMenu,  hwndFrame, TRUE ) ;
    WinSetParent ( hwndTitleBar, hwndFrame, TRUE ) ;
    WinSetParent ( hwndMinMax,	 hwndFrame, TRUE ) ;
  }

 /***************************************************************************
  * Tell the frame that things have changed.  Let it update the window.     *
  ***************************************************************************/

  WinSendMsg ( hwndFrame, WM_UPDATEFRAME,
    MPFROMSHORT ( FCF_TITLEBAR | FCF_SYSMENU | FCF_MINBUTTON ), 0L ) ;

 /***************************************************************************
  * Reposition the frame around the client window, which is left be.	    *
  ***************************************************************************/

  WinCalcFrameRect ( hwndFrame, &Rectangle, FALSE ) ;

  WinSetWindowPos ( hwndFrame, NULL,
    (SHORT) Rectangle.xLeft,  (SHORT) Rectangle.yBottom,
    (SHORT) (Rectangle.xRight-Rectangle.xLeft),
    (SHORT) (Rectangle.yTop-Rectangle.yBottom),
    SWP_SIZE | SWP_MOVE ) ;

 /***************************************************************************
  * If window was maximized, put it back that way.			    *
  ***************************************************************************/

  if ( OldPosition.fl & SWP_MAXIMIZE )
  {
    WinSetWindowPos ( hwndFrame, NULL,
      (SHORT) Rectangle.xLeft,	(SHORT) Rectangle.yBottom,
      (SHORT) (Rectangle.xRight-Rectangle.xLeft),
      (SHORT) (Rectangle.yTop-Rectangle.yBottom),
      SWP_SIZE | SWP_MOVE |
      ( OldPosition.fl & SWP_MAXIMIZE ) ) ;
  }

 /***************************************************************************
  * If the window was visible in the first place, show it.		    *
  ***************************************************************************/

  if ( WasVisible )
  {
    WinShowWindow ( hwndFrame, TRUE ) ;
  }
}

/****************************************************************************
 *									    *
 *    Update Window							    *
 *									    *
 ****************************************************************************/

STATIC void UpdateWindow ( HWND hwnd, PDATA Data, BOOL All )
{
 /***************************************************************************
  * Determine how many items are to be displayed.			    *
  ***************************************************************************/

  int Count = 0 ;
  for ( int i=0; i<Data->Profile.ItemCount; i++ )
  {
    if ( Data->Profile.Items[i]->QueryFlag() )
    {
      Count ++ ;
    }
  }

 /***************************************************************************
  * Get presentation space and make it use RGB colors.			    *
  ***************************************************************************/

  HPS hPS = WinGetPS ( hwnd ) ;
  GpiCreateLogColorTable ( hPS, LCOL_RESET, LCOLF_RGB, 0L, 0L, NULL ) ;

 /***************************************************************************
  * Get the window's size and determine the initial position.               *
  ***************************************************************************/

  RECTL Rectangle ;
  WinQueryWindowRect ( hwnd, &Rectangle ) ;

  Rectangle.xLeft += Data->Width / 2 ;
  Rectangle.xRight -= Data->Width / 2 ;

  Rectangle.yBottom = Data->Height * ( Count - 1 ) ;
  Rectangle.yTop = Rectangle.yBottom + Data->Height ;

 /***************************************************************************
  * Review all items.  Display those changed, or all.			    *
  ***************************************************************************/

  for ( i=0; i<Data->Profile.ItemCount; i++ )
  {
    ULONG NewValue ;

    Item *pItem = Data->Profile.Items [i] ;

    if ( pItem->QueryFlag() )
    {
      pItem->Repaint ( hPS, Rectangle,
	Data->Profile.TextColor, Data->Profile.BackColor, All ) ;

      Rectangle.yBottom -= Data->Height ;
      Rectangle.yTop	-= Data->Height ;
    }
  }

 /***************************************************************************
  * Release the presentation space and return.				    *
  ***************************************************************************/

  WinReleasePS ( hPS ) ;
}


/****************************************************************************
 *									    *
 *    Monitor Loop Thread						    *
 *									    *
 ****************************************************************************/

STATIC VOID MonitorLoopThread ( PMONITOR_PARMS Parms )
{
 /***************************************************************************
  * Set this thread's priority as high as it can go.                        *
  ***************************************************************************/

  DosSetPrty ( PRTYS_THREAD, PRTYC_TIMECRITICAL, PRTYD_MAXIMUM, 0 ) ;

 /***************************************************************************
  * Start up the high resolution timer, if it is available.		    *
  ***************************************************************************/

  BOOL HiResTimer = OpenTimer ( ) ;

 /***************************************************************************
  * Loop forever . . .							    *
  ***************************************************************************/

  while ( 1 )
  {

   /*************************************************************************
    * Reset the last time and count seen.				    *
    *************************************************************************/

    ULONG LastMilliseconds ;
    TIMESTAMP Time [2] ;

    if ( HiResTimer )
      GetTime ( &Time[0] ) ;
    else
      DosQuerySysInfo ( QSV_MS_COUNT, QSV_MS_COUNT, &LastMilliseconds, sizeof(LastMilliseconds) ) ;

    ULONG LastCounter = *Parms->Counter ;

   /*************************************************************************
    * Sleep for a bit.							    *
    *************************************************************************/

    DosSleep ( *Parms->Interval ) ;

   /*************************************************************************
    * Find out how much time and counts went by.			    *
    *************************************************************************/

    ULONG CurrentCounter = *Parms->Counter ;

    ULONG DeltaMilliseconds ;

    if ( HiResTimer )
    {
      GetTime ( &Time[1] ) ;

      ULONG Nanoseconds ;
      DeltaMilliseconds = ElapsedTime ( &Time[0], &Time[1], &Nanoseconds ) ;

      if ( Nanoseconds >= 500000L )
	DeltaMilliseconds ++ ;
    }
    else
    {
      ULONG Milliseconds ;
      DosQuerySysInfo ( QSV_MS_COUNT, QSV_MS_COUNT, &Milliseconds, sizeof(Milliseconds) ) ;
      DeltaMilliseconds = Milliseconds - LastMilliseconds ;
    }

   /*************************************************************************
    * Find out how much idle time was counted.	Adjust it to persecond.     *
    *************************************************************************/

    ULONG Counter = (ULONG) ( ( (double)(CurrentCounter-LastCounter) * 1000L ) / (double)DeltaMilliseconds ) ;

   /*************************************************************************
    * Tell the owner window to refresh its statistics.			    *
    *************************************************************************/

    WinPostMsg ( Parms->Owner, WM_REFRESH, MPFROMLONG(Counter), 0L ) ;
  }
}

/****************************************************************************
 *									    *
 *	Update the Item List to reflect changes in the available drives.    *
 *									    *
 ****************************************************************************/

STATIC VOID UpdateDriveList
(
  HAB Anchor,
  HMODULE Library,
  HINI ProfileHandle,
  PPROFILE Profile,
  ULONG OldDrives,
  ULONG NewDrives
)
{
 /***************************************************************************
  * Get format strings. 						    *
  ***************************************************************************/

  ResourceString LabelFormat ( Library, IDS_SHOW_DRIVE_FREE_LABEL ) ;
  ResourceString OptionFormat ( Library, IDS_SHOW_DRIVE_FREE_OPTION ) ;

 /***************************************************************************
  * Save the old item list for comparison.				    *
  ***************************************************************************/

  Item *OldItems [ ITEM_BASE_COUNT + MAX_DRIVES ] ;

  memset ( OldItems, 0, sizeof(OldItems) ) ;

  USHORT OldCount = 0 ;
  if ( OldDrives )
  {
    OldCount = Profile->ItemCount ;
    memcpy ( OldItems, Profile->Items, sizeof(OldItems) ) ;
  }

 /***************************************************************************
  * Add items for each drive on the system.				    *
  ***************************************************************************/

  USHORT Count = ITEM_BASE_COUNT ;
  USHORT OldIndex = ITEM_BASE_COUNT ;

  ULONG Drives = 0 ;
  NewDrives >>= 2 ;
  OldDrives >>= 2 ;

  for ( int Drive=3; Drive<=MAX_DRIVES; Drive++ )
  {
    while ( ( OldIndex < OldCount )
      AND ( (SHORT)OldItems[OldIndex]->QueryId() < ITEM_BASE_COUNT + Drive ) )
    {
      OldIndex ++ ;
    }

    if ( NewDrives & 1 )
    {
      if ( OldDrives & 1 )
      {
	Drives |= ( 1 << (Drive-1) ) ;
	if ( ( OldIndex < OldCount )
	  AND ( (SHORT)OldItems[OldIndex]->QueryId() == ITEM_BASE_COUNT + Drive ) )
	{
	  Profile->Items[Count++] = OldItems[OldIndex++] ;
	}
      }
      else
      {
        BYTE FileSystem [80] ;
	if ( CheckDrive ( Drive, FileSystem ) )
	{
	  Drives |= ( 1 << (Drive-1) ) ;

	  BYTE Name [80] ;
	  sprintf ( PCHAR(Name),   "ShowDrive%c:", Drive+'A'-1 ) ;

	  BYTE Label [80] ;
	  sprintf ( PCHAR(Label),  (PCHAR)LabelFormat.Ptr(),  Drive+'A'-1, FileSystem ) ;

	  BYTE Option [80] ;
	  sprintf ( PCHAR(Option), (PCHAR)OptionFormat.Ptr(), Drive+'A'-1 ) ;

	  Profile->Items[Count++] = new DriveFree ( ITEM_BASE_COUNT+Drive,
	    Name, Label, Option, Profile->CountryInfo,
	    Drive, Profile->DriveError ) ;
	}
      }
    }
    else
    {
      if ( OldDrives & 1 )
      {
	delete OldItems[OldIndex++] ;
      }
      else
      {
	// Do nothing.
      }
    }

    NewDrives >>= 1 ;
    OldDrives >>= 1 ;
  }

 /***************************************************************************
  * Save the new item count.						    *
  ***************************************************************************/

  Profile->ItemCount = Count ;

 /***************************************************************************
  * Fetch the display flags for the drives.				    *
  ***************************************************************************/

  for ( int i=ITEM_BASE_COUNT; i<Profile->ItemCount; i++ )
  {
    BOOL Flag = TRUE ;
    Item *pItem = Profile->Items [i] ;
    ULONG Size ;

    if
    (
      PrfQueryProfileSize ( ProfileHandle, (PSZ)PROGRAM_NAME, pItem->QueryName(), &Size )
      AND
      ( ( Size == sizeof(Flag) ) OR ( Size == sizeof(short) ) )
      AND
      PrfQueryProfileData ( ProfileHandle, (PSZ)PROGRAM_NAME, pItem->QueryName(), &Flag, &Size )
    )
    {
      ;
    }

    if ( Flag )
      pItem->SetFlag () ;
    else
      pItem->ResetFlag () ;
  }

 /***************************************************************************
  * Update the total free space object. 				    *
  ***************************************************************************/

  ( (TotalFree*) Profile->Items [ ITEM_TOTALFREE ] ) -> ResetMask ( Drives ) ;
}

/****************************************************************************
 *									    *
 *	Check to see if drive should be added to display list.		    *
 *									    *
 ****************************************************************************/

STATIC BOOL CheckDrive ( USHORT Drive, PBYTE FileSystem )
{
 /***************************************************************************
  * First, check to see if drive is local or remote.  Remote drives are     *
  *   always monitored. 						    *
  ***************************************************************************/

  BYTE Path [3] ;
  Path[0] = (BYTE) ( Drive + 'A' - 1 ) ;
  Path[1] = ':' ;
  Path[2] = 0 ;

  DosError ( FERR_DISABLEHARDERR ) ;

  BYTE Buffer [1024] ;
  ULONG Size = sizeof(Buffer) ;
  ULONG Status = DosQueryFSAttach ( Path, 0, FSAIL_QUERYNAME, (PFSQBUFFER2)Buffer, &Size ) ;
  DosError ( FERR_ENABLEHARDERR ) ;

  if ( Status )
  {
//  Log ( "ERROR: Unable to query drive %s for file system.  Status %04X.\r\n",
//    Path, Status ) ;
    return ( FALSE ) ;
  }

  USHORT cbName = ((PFSQBUFFER2)Buffer)->cbName ;
  strcpy ( (PCHAR)FileSystem, (PCHAR)((PFSQBUFFER2)(Buffer+cbName))->szFSDName ) ;

  if ( ((PFSQBUFFER2)Buffer)->iType == FSAT_REMOTEDRV )
  {
    return ( TRUE ) ;
  }

 /***************************************************************************
  * Attempt to open the local drive as an entire device.  If unable to do   *
  *   so, we cannot monitor this drive. 				    *
  ***************************************************************************/

  ULONG Action ;
  HFILE Handle ;
  Status = DosOpen ( Path, &Handle, &Action, 0, 0, FILE_OPEN,
    OPEN_ACCESS_READONLY | OPEN_SHARE_DENYNONE |
    OPEN_FLAGS_DASD | OPEN_FLAGS_FAIL_ON_ERROR, 0 ) ;

  if ( Status )
  {
//  Log ( "ERROR: Unable to open local drive %s.  Status %04X.\r\n",
//    Path, Status ) ;
    return ( FALSE ) ;
  }

 /***************************************************************************
  * Check to see if the drive has removable media.  We cannot monitor such. *
  ***************************************************************************/

  BOOL Addit = FALSE ;
  BYTE Command = 0 ;
  BYTE NonRemovable ;

  ULONG LengthIn = sizeof(Command) ;
  ULONG LengthOut = sizeof(NonRemovable);

  if 
  ( 
    NOT DosDevIOCtl 
    ( 
      Handle, 8, 0x20, 
      &Command, sizeof(Command), &LengthIn,
      &NonRemovable, sizeof(NonRemovable), &LengthOut 
    ) 
  )
  {
    Addit = NonRemovable ;
  }

 /***************************************************************************
  * Close the drive.							    *
  ***************************************************************************/

  DosClose ( Handle ) ;

 /***************************************************************************
  * Return the final verdict.						    *
  ***************************************************************************/

  return ( Addit ) ;
}

/****************************************************************************
 *									    *
 *			 Calibrate the Load Meter			    *
 *									    *
 ****************************************************************************/

STATIC ULONG CalibrateLoadMeter ( void )
{
 /***************************************************************************
  * Set result to zero as a default.					    *
  ***************************************************************************/

  double AdjustedMaxLoad = 0.0 ;

 /***************************************************************************
  * If HRTIMER.SYS has been installed . . .				    *
  ***************************************************************************/

  if ( OpenTimer ( ) )
  {
   /*************************************************************************
    * Increase this thread's priority to the maximum.                       *
    *************************************************************************/

    DosSetPrty ( PRTYS_THREAD, PRTYC_TIMECRITICAL, PRTYD_MAXIMUM, 0 ) ;

   /*************************************************************************
    * Create the calibration thread and set its priority next highest.	    *
    *************************************************************************/

    TID tidCalibrate ;
    ULONG MaxLoad ;
    DosCreateThread ( &tidCalibrate, CounterThread, (ULONG)&MaxLoad, 0, 4096 ) ;
    DosSetPrty ( PRTYS_THREAD, PRTYC_TIMECRITICAL, PRTYD_MAXIMUM-1, tidCalibrate ) ;
    DosSuspendThread ( tidCalibrate ) ;

   /*************************************************************************
    * Reset the calibration count, get the time, and let the counter go.    *
    *************************************************************************/

    MaxLoad = 0 ;
    TIMESTAMP Time[2] ;
    GetTime ( &Time[0] ) ;
    DosResumeThread ( tidCalibrate ) ;

   /*************************************************************************
    * Sleep for one second.						    *
    *************************************************************************/

    DosSleep ( 1000 ) ;

   /*************************************************************************
    * Suspend the calibration counter and get the time. 		    *
    *************************************************************************/

    DosSuspendThread ( tidCalibrate ) ;
    GetTime ( &Time[1] ) ;

   /*************************************************************************
    * Return priorities to normal.					    *
    *************************************************************************/

    DosSetPrty ( PRTYS_THREAD, PRTYC_REGULAR, 0, 0 ) ;

   /*************************************************************************
    * Get the elapsed time and adjust the calibration count.		    *
    *************************************************************************/

    ULONG Milliseconds ;
    ULONG Nanoseconds ;
    Milliseconds = ElapsedTime ( &Time[0], &Time[1], &Nanoseconds ) ;

    AdjustedMaxLoad = (double)MaxLoad * 1.0E9 ;
    AdjustedMaxLoad /= (double)Milliseconds*1.0E6L + (double)Nanoseconds ;

   /*************************************************************************
    * Close down the connection to HRTIMER.SYS. 			    *
    *************************************************************************/

    CloseTimer ( ) ;
  }

 /***************************************************************************
  * Return the adjusted calibration count.  If HRTIMER was not there, it    *
  *   will be zero.							    *
  ***************************************************************************/

  return ( (ULONG)AdjustedMaxLoad ) ;
}

/****************************************************************************
 *									    *
 *		      General Purpose Counter Thread			    *
 *									    *
 ****************************************************************************/

STATIC VOID CounterThread ( PULONG Counter )
{
  while ( 1 )
  {
    (*Counter) ++ ;
  }
}

/****************************************************************************
 *									    *
 *	Open the Profile						    *
 *									    *
 ****************************************************************************/

STATIC HINI OpenProfile ( PSZ Name, HAB Anchor, HMODULE Library, HWND HelpInstance )
{
 /***************************************************************************
  * Query the system INI for the profile file's path.                       *
  ***************************************************************************/

  PSZ ProfilePath = NULL ;
  ULONG Size ;

  if ( PrfQueryProfileSize ( HINI_USERPROFILE, PSZ(PROGRAM_NAME), PSZ("INIPATH"), &Size ) )
  {
    // The info exists.  Fetch it.
    ProfilePath = PSZ ( AllocateMemory ( Size ) ) ;
    PrfQueryProfileData ( HINI_USERPROFILE, PSZ(PROGRAM_NAME), PSZ("INIPATH"),
      ProfilePath, &Size ) ;

    // Build the profile file name.
    BYTE FullPath [_MAX_PATH] ;
    strcpy ( PCHAR(FullPath), PCHAR(ProfilePath) ) ;
    strcat ( PCHAR(FullPath), "\\" ) ;
    strcat ( PCHAR(FullPath), PCHAR(Name) ) ;
    strcat ( PCHAR(FullPath), ".INI" ) ;

    // Clean the name up and expand it to a full path.
    BYTE Path [256] ;
    DosQueryPathInfo ( FullPath, FIL_QUERYFULLNAME, Path, sizeof(Path) ) ;

    // Does the file exist?  If not, discard the name.
    FILESTATUS3 Status ;
    if ( DosQueryPathInfo ( Path, FIL_STANDARD, &Status, sizeof(Status) ) )
    {
      FreeMemory ( ProfilePath ) ;
      ProfilePath = NULL ;
    }
  }

 /***************************************************************************
  * If the profile file couldn't be found, ask the user for a path.         *
  ***************************************************************************/

  if ( ProfilePath == NULL )
  {
    // Set the default path.
    BYTE Path [256] ;
    DosQueryPathInfo ( PSZ("."), FIL_QUERYFULLNAME, Path, sizeof(Path) ) ;

    // Call up the entry dialog.
    PROFILE_PARMS Parms ;
    Parms.id = IDD_PROFILE_PATH ;
    Parms.hwndHelp = HelpInstance ;
    Parms.Path = Path ;
    Parms.PathSize = sizeof(Path) ;
    if ( WinDlgBox ( HWND_DESKTOP, HWND_DESKTOP, ProfileProcessor,
      Library, IDD_PROFILE_PATH, &Parms ) )
    {
      // If OK, save the approved path in the system profile.
      ProfilePath = PSZ ( AllocateMemory ( strlen(PCHAR(Path)) + 1 ) ) ;
      strcpy ( PCHAR(ProfilePath), PCHAR(Path) ) ;

      PrfWriteProfileData ( HINI_USERPROFILE, PSZ(PROGRAM_NAME), PSZ("INIPATH"),
	ProfilePath, strlen(PCHAR(ProfilePath))+1 ) ;
    }
    else
    {
      // If not, return an error.
      return ( NULL ) ;
    }
  }

 /***************************************************************************
  * Build the full profile file name.					    *
  ***************************************************************************/

  BYTE ProfileName [_MAX_PATH] ;
  strcpy ( PCHAR(ProfileName), PCHAR(ProfilePath) ) ;
  strcat ( PCHAR(ProfileName), "\\" PROGRAM_NAME ".INI" ) ;

 /***************************************************************************
  * Release the memory previously allocated to store the path.		    *
  ***************************************************************************/

  if ( ProfilePath )
  {
    FreeMemory ( ProfilePath ) ;
  }

 /***************************************************************************
  * Open/Create the profile file and return the resultant handle.	    *
  ***************************************************************************/

  return ( PrfOpenProfile ( Anchor, ProfileName ) ) ;
}

