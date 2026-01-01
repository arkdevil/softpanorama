/******************************************************************** ABOUT.H
 *									    *
 *			 About Dialog definitions			    *
 *									    *
 ****************************************************************************/

#ifndef ABOUT_H
#define ABOUT_H

typedef struct
{
  SHORT id ;
  HWND hwndHelp ;
}
ABOUT_PARMS, *PABOUT_PARMS ;

extern "C" 
{
  extern MRESULT EXPENTRY AboutProcessor  
  (
    HWND hwnd,
    USHORT msg,
    MPARAM mp1,
    MPARAM mp2
  ) ;
}
#endif
