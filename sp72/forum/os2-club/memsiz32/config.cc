/****************************************************************** CONFIG.CC
 *									    *
 *			  Clock Configuration Dialog			    *
 *									    *
 ****************************************************************************/

#define INCL_PM
#define INCL_WINSTDSPIN
#include <os2.h>

#include <stdlib.h>
#include <string.h>

#include "debug.h"
#include "support.h"

#include "memsize.h"
#include "config.h"


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


/****************************************************************************
 *									    *
 *	"Configure" Dialog Processor						*
 *									    *
 ****************************************************************************/

extern MRESULT EXPENTRY ConfigureProcessor
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
  * Get initial parameters.						    *
  ***************************************************************************/

  PCONFIG_PARMS Parms = (PCONFIG_PARMS) ( PVOIDFROMMP ( mp2 ) ) ;

  WinSetWindowPtr ( hwnd, QWL_USER, Parms ) ;

 /***************************************************************************
  * Associate the help instance.					    *
  ***************************************************************************/

  WinSetWindowUShort ( hwnd, QWS_ID, Parms->id ) ;

  if ( Parms->hwndHelp )
  {
    WinAssociateHelpInstance ( Parms->hwndHelp, hwnd ) ;
  }

 /***************************************************************************
  * Load the list box.							    *
  ***************************************************************************/

  for ( int i=0; i<Parms->ItemCount; i++ )
  {
    WinSendDlgItemMsg ( hwnd, IDD_CONFIG_ITEMS, LM_INSERTITEM,
      MPFROMSHORT(LIT_END), MPFROMP(Parms->ItemNames[i]) ) ;

    if ( Parms->ItemFlags[i] )
    {
      WinSendDlgItemMsg ( hwnd, IDD_CONFIG_ITEMS, LM_SELECTITEM,
	MPFROMSHORT(SHORT(i)), MPFROMSHORT(TRUE) ) ;
    }
  }

 /***************************************************************************
  * Set the radio button and checkbox values.				    *
  ***************************************************************************/

  WinSendDlgItemMsg ( hwnd, IDD_CONFIG_HIDECONTROLS,
    BM_SETCHECK, MPFROMSHORT(Parms->HideControls), 0 ) ;

  WinSendDlgItemMsg ( hwnd, IDD_CONFIG_FLOAT,
    BM_SETCHECK, MPFROMSHORT(Parms->Float), 0 ) ;

 /***************************************************************************
  * Set the limits and initial value of the spin-button control.	    *
  ***************************************************************************/

  WinSendDlgItemMsg ( hwnd, IDD_CONFIG_TIMER,
    SPBM_SETLIMITS, (MPARAM)300L, (MPARAM)10L ) ;

  WinSendDlgItemMsg ( hwnd, IDD_CONFIG_TIMER,
    SPBM_SETCURRENTVALUE, (MPARAM)(Parms->TimerInterval/100), NULL ) ;

 /***************************************************************************
  * Return without error.						    *
  ***************************************************************************/

  return ( MRFROMSHORT ( FALSE ) ) ;
}

/****************************************************************************
 *									    *
 *	Process commands received by the Configure Dialog			*
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
 *	Process the Configure Dialog's OK button being pressed.             *
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
  * Find the instance data.						    *
  ***************************************************************************/

  PCONFIG_PARMS Parms = PCONFIG_PARMS ( WinQueryWindowPtr ( hwnd, QWL_USER ) ) ;

 /***************************************************************************
  * Query the list box items for their selection.			    *
  ***************************************************************************/

  for ( int i=0; i<Parms->ItemCount; i++ )
  {
    Parms->ItemFlags[i] = FALSE ;
  }

  SHORT Selection = LIT_FIRST ;
  do
  {
    Selection = BOOL ( SHORT1FROMMR ( WinSendDlgItemMsg ( hwnd,
      IDD_CONFIG_ITEMS, LM_QUERYSELECTION,
      MPFROMSHORT(SHORT(Selection)), 0 ) ) ) ;

    if ( Selection != LIT_NONE )
    {
      Parms->ItemFlags[Selection] = TRUE ;
    }
  }
  while ( Selection != LIT_NONE ) ;

 /***************************************************************************
  * Query the buttons for their new settings.				    *
  ***************************************************************************/

  Parms->HideControls = (BOOL) SHORT1FROMMR ( WinSendDlgItemMsg ( hwnd,
    IDD_CONFIG_HIDECONTROLS, BM_QUERYCHECK, 0L, 0L ) ) ;

  Parms->Float = (BOOL) SHORT1FROMMR ( WinSendDlgItemMsg ( hwnd,
    IDD_CONFIG_FLOAT, BM_QUERYCHECK, 0L, 0L ) ) ;

 /***************************************************************************
  * Query the spinbuttons for their new settings.			    *
  ***************************************************************************/

  WinSendDlgItemMsg ( hwnd, IDD_CONFIG_TIMER, SPBM_QUERYVALUE,
    &Parms->TimerInterval, MPFROM2SHORT(NULL,SPBQ_UPDATEIFVALID) ) ;

  Parms->TimerInterval *= 100 ;

 /***************************************************************************
  * Dismiss the dialog with a TRUE status.				    *
  ***************************************************************************/

  WinDismissDlg ( hwnd, TRUE ) ;

  return ( 0 ) ;
}

/****************************************************************************
 *									    *
 *	Process the Configure Dialog's being cancelled.                     *
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
