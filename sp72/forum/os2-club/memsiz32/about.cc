/******************************************************************* ABOUT.CC
 *									    *
 *			  Generic "About" Dialog			    *
 *									    *
 ****************************************************************************/

#define INCL_BASE
#define INCL_PM
#include <os2.h>

#include "debug.h"
#include "support.h"
#include "about.h"


/****************************************************************************
 *									    *
 *		       Definitions & Declarations			    *
 *									    *
 ****************************************************************************/

static METHODFUNCTION InitDlg ;
static METHODFUNCTION Command ;
static METHODFUNCTION OK ;
static METHODFUNCTION Cancel ;


/****************************************************************************
 *									    *
 *	"About" Dialog Processor					    *
 *									    *
 ****************************************************************************/

extern MRESULT EXPENTRY AboutProcessor
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
  PABOUT_PARMS Parms = (PABOUT_PARMS) ( PVOIDFROMMP ( mp2 ) ) ;

  WinSetWindowUShort ( hwnd, QWS_ID, Parms->id ) ;

  if ( Parms->hwndHelp )
  {
    WinAssociateHelpInstance ( Parms->hwndHelp, hwnd ) ;
  }

  return ( MRFROMSHORT ( FALSE ) ) ;

  hwnd = hwnd ;  msg = msg ;  mp1 = mp1 ;  mp2 = mp2 ;
}

/****************************************************************************
 *									    *
 *	Process commands received by the About Dialog			    *
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

  hwnd = hwnd ;  msg = msg ;  mp1 = mp1 ;  mp2 = mp2 ;
}

/****************************************************************************
 *									    *
 *	Process the About Dialog's OK button being pressed.                 *
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
  * Dismiss the dialog with a TRUE status.				    *
  ***************************************************************************/

  WinDismissDlg ( hwnd, TRUE ) ;

  return ( 0 ) ;

  hwnd = hwnd ;  msg = msg ;  mp1 = mp1 ;  mp2 = mp2 ;
}

/****************************************************************************
 *									    *
 *	Process the About Dialog's being cancelled.                         *
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

  hwnd = hwnd ;  msg = msg ;  mp1 = mp1 ;  mp2 = mp2 ;
}

