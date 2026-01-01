/****************************************************************** PROFILE.H
 *									    *
 *			Profile Dialog definitions			    *
 *									    *
 ****************************************************************************/

#ifndef PROFILE_H
#define PROFILE_H

typedef struct
{
  SHORT   id ;
  HWND	  hwndHelp ;
  PBYTE   Path ;
  int	  PathSize ;
}
PROFILE_PARMS, *PPROFILE_PARMS ;

extern "C" 
{
  extern MRESULT EXPENTRY ProfileProcessor
  (
    HWND hwnd,
    USHORT msg,
    MPARAM mp1,
    MPARAM mp2
  ) ;
}
#endif
