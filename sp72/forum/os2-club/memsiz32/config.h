/******************************************************************* CONFIG.H
 *									    *
 *		       Configure Dialog definitions			    *
 *									    *
 ****************************************************************************/

#ifndef CONFIG_H
#define CONFIG_H

typedef struct
{
  SHORT  id ;
  HWND	 hwndHelp ;

  BOOL	 HideControls ;
  BOOL	 Float ;
  ULONG  TimerInterval ;

  USHORT ItemCount ;
  PSZ	*ItemNames ;
  PBOOL  ItemFlags ;
}
CONFIG_PARMS, *PCONFIG_PARMS ;

extern MRESULT EXPENTRY ConfigureProcessor
(
  HWND hwnd,
  USHORT msg,
  MPARAM mp1,
  MPARAM mp2
) ;

#endif
