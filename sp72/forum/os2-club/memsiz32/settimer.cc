/**************************************************************** SETTIMER.CC
 *									    *
 *			Dialog: Set Timer Interval			    *
 *									    *
 ****************************************************************************/

#define INCL_BASE
#define INCL_PM
#define INCL_WINSTDSPIN
#include <os2.h>

#include "support.h"
#include "settimer.h"


/****************************************************************************
 *									    *
 *		       Definitions & Declarations			    *
 *									    *
 ****************************************************************************/

  // Function Prototypes

static METHODFUNCTION InitDlg ;
static METHODFUNCTION Command ;
static METHODFUNCTION OK ;
static METHODFUNCTION Cancel ;


  // Global Data

static SHORT id ;
static PUSHORT TimerInterval ;


/****************************************************************************
 *									    *
 *	"SetTimer" Dialog Processor					    *
 *									    *
 ****************************************************************************/

extern MRESULT EXPENTRY SetTimerProcessor
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
  * Local Declarations							    *
  ***************************************************************************/

  SETTIMER_PARMS *Parms = (SETTIMER_PARMS*) ( PVOIDFROMMP ( mp2 ) ) ;

 /***************************************************************************
  * Save parameter data.						    *
  ***************************************************************************/

  id = Parms->id ;
  TimerInterval = Parms->TimerInterval ;

 /***************************************************************************
  * Set the dialog help instance.					    *
  ***************************************************************************/

  WinSetWindowUShort ( hwnd, QWS_ID, id ) ;

  if ( Parms->hwndHelp )
  {
    WinAssociateHelpInstance ( Parms->hwndHelp, hwnd ) ;
  }

 /***************************************************************************
  * Set the limits and initial value of the spin-button control.	    *
  ***************************************************************************/

  WinSendDlgItemMsg ( hwnd, id,
    SPBM_SETLIMITS, (MPARAM)300L, (MPARAM)10L ) ;

  WinSendDlgItemMsg ( hwnd, id,
    SPBM_SETCURRENTVALUE, (MPARAM)(*TimerInterval/100), NULL ) ;

 /***************************************************************************
  * Return OK.								    *
  ***************************************************************************/

  return ( MRFROMSHORT ( FALSE ) ) ;

  hwnd = hwnd ;  msg = msg ;  mp1 = mp1 ;  mp2 = mp2 ;
}

/****************************************************************************
 *									    *
 *	Process command messages.					    *
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
 *	Process acceptance of new timer value.				    *
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
  * Save the results.							    *
  ***************************************************************************/

  WinSendDlgItemMsg ( hwnd, id, SPBM_QUERYVALUE, TimerInterval, MPFROM2SHORT(NULL,SPBQ_UPDATEIFVALID) ) ;
  *TimerInterval *= 100 ;

 /***************************************************************************
  * Dismiss the dialog with a TRUE status.				    *
  ***************************************************************************/

  WinDismissDlg ( hwnd, TRUE ) ;

  return ( 0 ) ;

  hwnd = hwnd ;  msg = msg ;  mp1 = mp1 ;  mp2 = mp2 ;
}

/****************************************************************************
 *									    *
 *	Process cancellation.						    *
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