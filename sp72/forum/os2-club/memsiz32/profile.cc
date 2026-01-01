/***************************************************************** PROFILE.CC
 *									    *
 *			   "Profile Path" Dialog			    *
 *									    *
 ****************************************************************************/

#define INCL_BASE
#define INCL_PM
#include <os2.h>

#include <string.h>

#include "support.h"
#include "profile.h"


/****************************************************************************
 *									    *
 *		       Definitions & Declarations			    *
 *									    *
 ****************************************************************************/

enum { ENTRY, ERR } ;

static METHODFUNCTION InitDlg ;
static METHODFUNCTION Command ;
static METHODFUNCTION OK ;
static METHODFUNCTION Cancel ;

  // Global Data

static SHORT id ;
static PBYTE Path ;
static int   PathSize ;


/****************************************************************************
 *									    *
 *	Dialog Message Processor					    *
 *									    *
 ****************************************************************************/

extern MRESULT EXPENTRY ProfileProcessor
(
  HWND hwnd,
  USHORT msg,
  MPARAM mp1,
  MPARAM mp2
)
{
 /***************************************************************************
  *				Declarations				    *
  ***************************************************************************/

  static METHOD Methods [] =
  {
    { WM_INITDLG, InitDlg },
    { WM_COMMAND, Command }
  } ;

 /***************************************************************************
  * Dispatch the message according to the method table and return the	    *
  *   result.  Any messages not defined above get handled by the system     *
  *   default dialog processor. 					    *
  ***************************************************************************/

  return ( DispatchMessage ( hwnd, msg, mp1, mp2, Methods, sizeof(Methods)/sizeof(Methods[0]), WinDefDlgProc ) ) ;
}

/****************************************************************************
 *									    *
 *	Initialize Dialog						    *
 *									    *
 ****************************************************************************/

static MRESULT APIENTRY InitDlg
( 
  HWND hwnd, 
  USHORT msg,
  MPARAM mp1, 
  MPARAM mp2
)
{
 /***************************************************************************
  * Get parameters from initialization message. 			    *
  ***************************************************************************/

  PPROFILE_PARMS Parms = (PPROFILE_PARMS) ( PVOIDFROMMP ( mp2 ) ) ;

 /***************************************************************************
  * Save parameter data.						    *
  ***************************************************************************/

  id = Parms->id ;
  Path = Parms->Path ;
  PathSize = Parms->PathSize ;

 /***************************************************************************
  * Set the dialog help instance.					    *
  ***************************************************************************/

  WinSetWindowUShort ( hwnd, QWS_ID, Parms->id ) ;
  if ( Parms->hwndHelp )
  {
    WinAssociateHelpInstance ( Parms->hwndHelp, hwnd ) ;
  }

 /***************************************************************************
  * Set the entry field contents.					    *
  ***************************************************************************/

  WinSetDlgItemText ( hwnd, id+ENTRY, Path ) ;

 /***************************************************************************
  * Return no error.							    *
  ***************************************************************************/

  return ( MRFROMSHORT ( FALSE ) ) ;
}

/****************************************************************************
 *									    *
 *	Process commands received by the dialog.			    *
 *									    *
 ****************************************************************************/

static MRESULT APIENTRY Command
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

  static METHOD Methods [] =
  {
    { DID_OK,	  OK	 },
    { DID_CANCEL, Cancel },
  } ;

 /***************************************************************************
  * Dispatch the message without a default message processor.		    *
  ***************************************************************************/

  return ( DispatchMessage ( hwnd, SHORT1FROMMP(mp1), mp1, mp2, Methods, sizeof(Methods)/sizeof(Methods[0]), NULL ) ) ;
}

/****************************************************************************
 *									    *
 *	Process the dialog's OK button being pressed.                       *
 *									    *
 ****************************************************************************/

static MRESULT APIENTRY OK
( 
  HWND hwnd, 
  USHORT msg, 
  MPARAM mp1, 
  MPARAM mp2
)
{
 /***************************************************************************
  * Verify the entered path.						    *
  ***************************************************************************/

  BYTE Name [256] ;
  WinQueryDlgItemText ( hwnd, id+ENTRY, sizeof(Name), Name ) ;

  BYTE FullPath [256] ;
  if ( DosQueryPathInfo ( Name, FIL_QUERYFULLNAME, FullPath, sizeof(FullPath) ) )
  {
    PSZ Message = PSZ ( "ERROR: Not a valid path." ) ;
    WinSetDlgItemText ( hwnd, id+ERR, Message ) ;
    WinAlarm ( HWND_DESKTOP, WA_ERROR ) ;
    WinSetFocus ( HWND_DESKTOP, WinWindowFromID ( hwnd, id+ENTRY ) ) ;
    return ( 0 ) ;
  }

  FILESTATUS3 Status ;
  if ( DosQueryPathInfo ( FullPath, FIL_STANDARD, &Status, sizeof(Status) ) )
  {
    PSZ Message = PSZ ( "ERROR: Path does not exist." ) ;
    WinSetDlgItemText ( hwnd, id+ERR, Message ) ;
    WinAlarm ( HWND_DESKTOP, WA_ERROR ) ;
    WinSetFocus ( HWND_DESKTOP, WinWindowFromID ( hwnd, id+ENTRY ) ) ;
    return ( 0 ) ;
  }

  if ( ! ( Status.attrFile & FILE_DIRECTORY ) )
  {
    PSZ Message = PSZ ( "ERROR: Specified path is not a directory." ) ;
    WinSetDlgItemText ( hwnd, id+ERR, Message ) ;
    WinAlarm ( HWND_DESKTOP, WA_ERROR ) ;
    WinSetFocus ( HWND_DESKTOP, WinWindowFromID ( hwnd, id+ENTRY ) ) ;
    return ( 0 ) ;
  }

 /***************************************************************************
  * Return the full path to the caller. 				    *
  ***************************************************************************/

  strncpy ( PCHAR(Path), PCHAR(FullPath), PathSize ) ;

 /***************************************************************************
  * Dismiss the dialog with a TRUE status.				    *
  ***************************************************************************/

  WinDismissDlg ( hwnd, TRUE ) ;

  return ( 0 ) ;
}

/****************************************************************************
 *									    *
 *	Process the dialog's being cancelled.                               *
 *									    *
 ****************************************************************************/

static MRESULT APIENTRY Cancel
( 
  HWND hwnd, 
  USHORT msg, 
  MPARAM mp1, 
  MPARAM mp2
)
{
 /***************************************************************************
  * Dismiss the dialog with a TRUE status.				    *
  ***************************************************************************/

  WinDismissDlg ( hwnd, FALSE ) ;

  return ( 0 ) ;
}
