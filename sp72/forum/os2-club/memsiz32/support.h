/****************************************************************** SUPPORT.H
 *                                                                          *
 *                Presentation Manager Support Functions                    *
 *                                                                          *
 ****************************************************************************/

#ifndef SUPPORT_H
#define SUPPORT_H

#define TRUE  1
#define FALSE 0

#define NOT !
#define OR  ||
#define AND &&

#define _MAX_PATH  260
#define _MAX_DRIVE 3
#define _MAX_DIR   256
#define _MAX_FNAME 256
#define _MAX_EXT   256

#define DATEFMT_MM_DD_YY    (0x0000)
#define DATEFMT_DD_MM_YY    (0x0001)
#define DATEFMT_YY_MM_DD    (0x0002)

#define max(a,b)	(((a) > (b)) ? (a) : (b))
#define min(a,b)	(((a) < (b)) ? (a) : (b))

typedef MRESULT (APIENTRY METHODFUNCTION) ( HWND, USHORT, MPARAM, MPARAM ) ;
typedef METHODFUNCTION *PMETHODFUNCTION ;

typedef struct Method
{
  USHORT Action ;
  PMETHODFUNCTION pFunction ;
}
METHOD, *PMETHOD ;

extern MRESULT DispatchMessage
(
  HWND    hwnd,
  USHORT  msg,
  MPARAM  mp1,
  MPARAM  mp2,
  PMETHOD MethodTable,
  USHORT  MethodCount,
  PFNWP   DefaultProcessor
) ;

extern VOID AddSysMenuItem ( HWND hwndFrame, MENUITEM *Item, PSZ Text ) ;

extern VOID AddSysSubMenuItem
(
  HWND hwndFrame,
  USHORT SubMenuID,
  MENUITEM *Item,
  PSZ Text
) ;

extern VOID AddMenuItem
(
  HWND hwndFrame,
  USHORT MenuID,
  MENUITEM *Item,
  PSZ Text
) ;

extern VOID AddSubMenuItem
(
  HWND hwndFrame,
  USHORT MenuID,
  USHORT SubMenuID,
  MENUITEM *Item,
  PSZ Text
) ;

extern VOID RemoveSubMenuItem
(
  HWND hwndFrame,
  USHORT MenuID,
  USHORT SubMenuID,
  USHORT ItemID
) ;

extern VOID EnableMenuItem
(
  HWND hwndFrame,
  USHORT MenuID,
  USHORT Item,
  BOOL Enable
) ;

extern VOID CheckMenuItem
(
  HWND hwndFrame,
  USHORT MenuID,
  USHORT Item,
  BOOL Check
) ;

extern VOID Add2TaskList ( HWND hwnd, PSZ Name ) ;

extern PPRESPARAMS BuildPresParams
(
  USHORT ParmCount,
  PULONG Ids,
  PULONG ByteCounts,
  PBYTE *Parms
) ;

typedef struct
{
  PSZ	 Name ;
  USHORT Type ;
  USHORT Length ;
  PVOID  Value ;
}
EADATA, *PEADATA ;

extern PEAOP BuildExtendedAttributes ( USHORT Count, EADATA Table[] ) ;

typedef struct
{
  USHORT Type ;
  USHORT Length ;
  PVOID  Value ;
}
MVMT_VALUE, *PMVMT_VALUE ;

extern USHORT BuildMVMTValue ( PVOID Value, USHORT Count, MVMT_VALUE Table[] ) ;

extern METHODFUNCTION Exit ;
extern METHODFUNCTION HelpForHelp ;
extern METHODFUNCTION ExtendedHelp ;
extern METHODFUNCTION KeysHelp ;
extern METHODFUNCTION HelpIndex ;

#endif



