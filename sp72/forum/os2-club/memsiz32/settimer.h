/***************************************************************** SETTIMER.H
 *									    *
 *			Set Timer Dialog definitions			    *
 *									    *
 ****************************************************************************/

#ifndef SETTIMER_H
#define SETTIMER_H

typedef struct
{
  SHORT   id ;
  HWND	  hwndHelp ;
  PUSHORT TimerInterval ;
}
SETTIMER_PARMS ;

extern MRESULT EXPENTRY SetTimerProcessor
(
  HWND hwnd,
  USHORT msg,
  MPARAM mp1,
  MPARAM mp2
) ;

#endif
