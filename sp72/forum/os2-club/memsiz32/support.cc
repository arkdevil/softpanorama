/***************************************************************** SUPPORT.CC
 *                                                                          *
 *                Presentation Manager Support Functions                    *
 *                                                                          *
 ****************************************************************************/

#define INCL_BASE
#define INCL_PM
#include <os2.h>

#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "support.h"
#include "debug.h"


/****************************************************************************
 *									    *
 *	Definitions & Declarations					    *
 *									    *
 ****************************************************************************/

  // Local Function Prototypes

static USHORT BuildExtendedAttributeItem ( PFEA pFEA, PEADATA Item ) ;


/****************************************************************************
 *                                                                          *
 *                        Message Dispatcher                                *
 *                                                                          *
 ****************************************************************************/

extern MRESULT DispatchMessage
(
  HWND    hwnd,
  USHORT  msg,
  MPARAM  mp1,
  MPARAM  mp2,
  PMETHOD MethodTable,
  USHORT  MethodCount,
  PFNWP   DefaultProcessor
)
{
 /***************************************************************************
  * Local Declarations                                                      *
  ***************************************************************************/

  USHORT cNumberLeft ;
  MRESULT mr ;
  PMETHOD pMethod ;

 /***************************************************************************
  * Process messages according to object's class method table.              *
  ***************************************************************************/

  pMethod = MethodTable ;
  cNumberLeft = MethodCount ;

  while ( ( cNumberLeft ) AND ( pMethod->Action != msg ) )
  {
    pMethod ++ ;
    cNumberLeft -- ;
  }

  if ( cNumberLeft )
  {
    mr = pMethod->pFunction ( hwnd, msg, mp1, mp2 ) ;
  }
  else
  {
    if ( DefaultProcessor )
      mr = DefaultProcessor ( hwnd, msg, mp1, mp2 ) ;
    else
      mr = 0 ;
  }

 /***************************************************************************
  * Return result from message processor.                                   *
  ***************************************************************************/

  return ( mr ) ;
}

/****************************************************************************
 *                                                                          *
 *                         Add Item to System Menu                          *
 *                                                                          *
 ****************************************************************************/

extern VOID AddSysMenuItem ( HWND hwndFrame, MENUITEM *Item, PSZ Text )
{
 /***************************************************************************
  * Local Declarations                                                      *
  ***************************************************************************/

  HWND hwndSysMenu ;
  HWND hwndSysSubMenu ;
  USHORT idSysMenu ;
  MENUITEM miSysMenu ;

 /***************************************************************************
  * Obtain the system menu window handle.                                   *
  ***************************************************************************/

  hwndSysMenu = WinWindowFromID ( hwndFrame, FID_SYSMENU ) ;

 /***************************************************************************
  * Get the system menu's base item and its window handle.                  *
  ***************************************************************************/

  idSysMenu = SHORT1FROMMR ( WinSendMsg ( hwndSysMenu, MM_ITEMIDFROMPOSITION, NULL, NULL ) ) ;

  WinSendMsg ( hwndSysMenu, MM_QUERYITEM,
    MPFROM2SHORT(idSysMenu,FALSE), MPFROMP(&miSysMenu) ) ;

  hwndSysSubMenu = miSysMenu.hwndSubMenu ;

 /***************************************************************************
  * Add the new item to the system menu's submenu, which is what we see.    *
  ***************************************************************************/

  WinSendMsg ( hwndSysSubMenu, MM_INSERTITEM, MPFROMP(Item), MPFROMP(Text) ) ;
}

/****************************************************************************
 *                                                                          *
 *                   Add Item to Submenu on System Menu                     *
 *                                                                          *
 ****************************************************************************/

extern VOID AddSysSubMenuItem
(
  HWND hwndFrame,
  USHORT SubMenuID,
  MENUITEM *Item,
  PSZ Text
)
{
 /***************************************************************************
  * Local Declarations                                                      *
  ***************************************************************************/

  HWND hwndSubMenu ;
  HWND hwndSysMenu ;
  HWND hwndSysSubMenu ;
  USHORT idSysMenu ;
  MENUITEM MenuItem ;

 /***************************************************************************
  * Obtain the system menu window handle.                                   *
  ***************************************************************************/

  hwndSysMenu = WinWindowFromID ( hwndFrame, FID_SYSMENU ) ;

 /***************************************************************************
  * Get the system menu's base item and its window handle.                  *
  ***************************************************************************/

  idSysMenu = SHORT1FROMMR ( WinSendMsg ( hwndSysMenu, MM_ITEMIDFROMPOSITION, NULL, NULL ) ) ;

  WinSendMsg ( hwndSysMenu, MM_QUERYITEM,
    MPFROM2SHORT(idSysMenu,FALSE), MPFROMP(&MenuItem) ) ;

  hwndSysSubMenu = MenuItem.hwndSubMenu ;

 /***************************************************************************
  * Get the submenu's base item and its window handle.                      *
  ***************************************************************************/

  WinSendMsg ( hwndSysSubMenu, MM_QUERYITEM,
    MPFROM2SHORT ( SubMenuID, TRUE ),
    (MPARAM) &MenuItem ) ;

  hwndSubMenu = MenuItem.hwndSubMenu ;

 /***************************************************************************
  * Add the new item to the system menu's submenu, which is what we see.    *
  ***************************************************************************/

  WinSendMsg ( hwndSubMenu, MM_INSERTITEM, MPFROMP(Item), MPFROMP(Text) ) ;
}

/****************************************************************************
 *                                                                          *
 *                           Add Item to Menu                               *
 *                                                                          *
 ****************************************************************************/

extern VOID AddMenuItem
(
  HWND hwndFrame,
  USHORT MenuID,
  MENUITEM *Item,
  PSZ Text
)
{
 /***************************************************************************
  * Local Declarations                                                      *
  ***************************************************************************/

  HWND hwndMenu ;

 /***************************************************************************
  * Obtain the menu window handle.                                          *
  ***************************************************************************/

  hwndMenu = WinWindowFromID ( hwndFrame, MenuID ) ;

 /***************************************************************************
  * Add the new item to the menu.                                           *
  ***************************************************************************/

  WinSendMsg ( hwndMenu, MM_INSERTITEM, MPFROMP(Item), MPFROMP(Text) ) ;
}

/****************************************************************************
 *                                                                          *
 *                        Add Item to SubMenu                               *
 *                                                                          *
 ****************************************************************************/

extern VOID AddSubMenuItem
(
  HWND hwndFrame,
  USHORT MenuID,
  USHORT SubMenuID,
  MENUITEM *Item,
  PSZ Text
)
{
 /***************************************************************************
  * Local Declarations                                                      *
  ***************************************************************************/

  HWND hwndMenu ;
  HWND hwndSubMenu ;
  MENUITEM MenuItem ;

 /***************************************************************************
  * Obtain the menu window handle.                                          *
  ***************************************************************************/

  hwndMenu = WinWindowFromID ( hwndFrame, MenuID ) ;

 /***************************************************************************
  * Obtain the submenu window handle.                                       *
  ***************************************************************************/

  WinSendMsg ( hwndMenu, MM_QUERYITEM,
    MPFROM2SHORT ( SubMenuID, TRUE ),
    (MPARAM) &MenuItem ) ;

  hwndSubMenu = MenuItem.hwndSubMenu ;

 /***************************************************************************
  * Add the new item to the menu.                                           *
  ***************************************************************************/

  WinSendMsg ( hwndSubMenu, MM_INSERTITEM, MPFROMP(Item), MPFROMP(Text) ) ;
}

/****************************************************************************
 *									    *
 *			 Remove Item from SubMenu			    *
 *									    *
 ****************************************************************************/

extern VOID RemoveSubMenuItem
(
  HWND hwndFrame,
  USHORT MenuID,
  USHORT SubMenuID,
  USHORT ItemID
)
{
 /***************************************************************************
  * Local Declarations							    *
  ***************************************************************************/

  HWND hwndMenu ;
  HWND hwndSubMenu ;
  MENUITEM MenuItem ;

 /***************************************************************************
  * Obtain the menu window handle.					    *
  ***************************************************************************/

  hwndMenu = WinWindowFromID ( hwndFrame, MenuID ) ;

 /***************************************************************************
  * Obtain the submenu window handle.					    *
  ***************************************************************************/

  WinSendMsg ( hwndMenu, MM_QUERYITEM,
    MPFROM2SHORT ( SubMenuID, TRUE ),
    (MPARAM) &MenuItem ) ;

  hwndSubMenu = MenuItem.hwndSubMenu ;

 /***************************************************************************
  * Remove the item from the menu.					    *
  ***************************************************************************/

  WinSendMsg ( hwndSubMenu, MM_REMOVEITEM, MPFROM2SHORT(ItemID,TRUE), 0 ) ;
}

/****************************************************************************
 *                                                                          *
 *      Enable/Disable menu item.                                           *
 *                                                                          *
 ****************************************************************************/

extern VOID EnableMenuItem ( HWND hwndFrame, USHORT MenuID, USHORT ItemID, BOOL Enable )
{
 /***************************************************************************
  * Local Declarations                                                      *
  ***************************************************************************/

  HWND hwndMenu ;

 /***************************************************************************
  * Get the menu's window handle.                                           *
  ***************************************************************************/

  hwndMenu = WinWindowFromID ( hwndFrame, MenuID ) ;

 /***************************************************************************
  * Set the menu item's enable/disable status.                              *
  ***************************************************************************/

  WinSendMsg ( hwndMenu, MM_SETITEMATTR, MPFROM2SHORT ( ItemID, TRUE ),
    MPFROM2SHORT ( MIA_DISABLED, Enable ? 0 : MIA_DISABLED ) ) ;
}

/****************************************************************************
 *                                                                          *
 *      Check/Uncheck menu item.                                            *
 *                                                                          *
 ****************************************************************************/

extern VOID CheckMenuItem ( HWND hwndFrame, USHORT MenuID, USHORT ItemID, BOOL Enable )
{
 /***************************************************************************
  * Local Declarations                                                      *
  ***************************************************************************/

  HWND hwndMenu ;

 /***************************************************************************
  * Get the menu's window handle.                                           *
  ***************************************************************************/

  hwndMenu = WinWindowFromID ( hwndFrame, MenuID ) ;

 /***************************************************************************
  * Set the menu item's enable/disable status.                              *
  ***************************************************************************/

  WinSendMsg ( hwndMenu, MM_SETITEMATTR, MPFROM2SHORT ( ItemID, TRUE ),
    MPFROM2SHORT ( MIA_CHECKED, Enable ? MIA_CHECKED : 0 ) ) ;
}

/****************************************************************************
 *                                                                          *
 *                        Add Program to Task List                          *
 *                                                                          *
 ****************************************************************************/

extern VOID Add2TaskList ( HWND hwnd, PSZ Name )
{
 /***************************************************************************
  * Local Declarations                                                      *
  ***************************************************************************/

  PID pid ;
  SWCNTRL swctl ;

 /***************************************************************************
  * Get the window's process ID.                                            *
  ***************************************************************************/

  WinQueryWindowProcess ( hwnd, &pid, NULL ) ;

 /***************************************************************************
  * Add an entry to the system task list.                                   *
  ***************************************************************************/

  swctl.hwnd = hwnd ;
  swctl.hwndIcon = NULL ;
  swctl.hprog = NULL ;
  swctl.idProcess = pid ;
  swctl.idSession = 0 ;
  swctl.uchVisibility = SWL_VISIBLE ;
  swctl.fbJump = SWL_JUMPABLE ;
  strcpy ( swctl.szSwtitle, (PCHAR)Name ) ;

  WinAddSwitchEntry ( &swctl ) ;
}

/****************************************************************************
 *									    *
 *  Build Presentation Parameters					    *
 *									    *
 ****************************************************************************/

extern PPRESPARAMS BuildPresParams
(
  USHORT ParmCount,
  PULONG Ids,
  PULONG ByteCounts,
  PBYTE *Parms
)
{
 /***************************************************************************
  * Local Declarations							    *
  ***************************************************************************/

  USHORT i ;
  PPARAM Param ;
  PPRESPARAMS PresParams ;
  ULONG Size ;

 /***************************************************************************
  * Determine final size of presentation parameter block.		    *
  ***************************************************************************/

  Size = sizeof(ULONG) ;

  for ( i=0; i<ParmCount; i++ )
  {
    Size += sizeof(ULONG) ;
    Size += sizeof(ULONG) ;
    Size += ByteCounts[i] ;
  }

 /***************************************************************************
  * Allocate memory for block.	Return if unable to do so.		    *
  ***************************************************************************/

  PresParams = (PPRESPARAMS) AllocateMemory ( (USHORT) Size ) ;

  if ( PresParams == NULL )
    return ( NULL ) ;

 /***************************************************************************
  * Initialize the block header.					    *
  ***************************************************************************/

  PresParams->cb = Size - sizeof(PresParams->cb) ;

 /***************************************************************************
  * Load the presentation parameters into the block.			    *
  ***************************************************************************/

  Param = PresParams->aparam ;

  for ( i=0; i<ParmCount; i++ )
  {
    Param->id = Ids[i] ;
    Param->cb = ByteCounts[i] ;
    memcpy ( Param->ab, Parms[i], (USHORT)ByteCounts[i] ) ;
    ((PBYTE)Param) += sizeof(LONG) ;
    ((PBYTE)Param) += sizeof(LONG) ;
    ((PBYTE)Param) += ByteCounts[i] ;
  }

 /***************************************************************************
  * Return the pointer to the block.  It will need freeing by the caller.   *
  ***************************************************************************/

  return ( PresParams ) ;
}

/****************************************************************************
 *									    *
 *	Build Extended Attributes					    *
 *									    *
 ****************************************************************************/

extern PEAOP BuildExtendedAttributes ( USHORT Count, EADATA Table[] )
{
 /***************************************************************************
  * Local Declarations							    *
  ***************************************************************************/

  USHORT   cbEA ;
  USHORT   i ;
  PEAOP    pExtendedAttributes ;
  PFEA	   pFEA ;
  PFEALIST pFEAList ;

 /***************************************************************************
  * Find out how much memory will be needed for the block.		    *
  ***************************************************************************/

  cbEA = sizeof(FEALIST) - sizeof(FEA) ;

  for ( i=0; i<Count; i++ )
  {
    cbEA += BuildExtendedAttributeItem ( NULL, &Table[i] ) ;
  }

 /***************************************************************************
  * Allocate memory for the FEA list.					    *
  ***************************************************************************/

  pFEAList = (PFEALIST) AllocateMemory ( cbEA ) ;

  if ( pFEAList == NULL )
  {
    return ( NULL ) ;
  }

 /***************************************************************************
  * Construct the extended attributes.					    *
  ***************************************************************************/

  pFEA = pFEAList->list ;

  for ( i=0; i<Count; i++ )
  {
    (PBYTE) pFEA += BuildExtendedAttributeItem ( pFEA, &Table[i] ) ;
  }

  pFEAList->cbList = (PBYTE) pFEA - (PBYTE) pFEAList ;

 /***************************************************************************
  * Allocate memory for the EA header block.				    *
  ***************************************************************************/

  pExtendedAttributes = (PEAOP) AllocateMemory ( sizeof(EAOP) ) ;

  if ( pExtendedAttributes == NULL )
  {
    FreeMemory ( pFEAList ) ;
    return ( NULL ) ;
  }

 /***************************************************************************
  * Fill in the extended attribute header block and return its address.     *
  ***************************************************************************/

  pExtendedAttributes->fpGEAList = NULL ;
  pExtendedAttributes->fpFEAList = pFEAList ;
  pExtendedAttributes->oError = 0 ;

  return ( pExtendedAttributes ) ;
}

/****************************************************************************
 *									    *
 *	Build Extended Attribute Item					    *
 *									    *
 ****************************************************************************/

static USHORT BuildExtendedAttributeItem ( PFEA pFEA, PEADATA Item )
{
 /***************************************************************************
  *			     Declarations				    *
  ***************************************************************************/

  PBYTE p ;
  PSHORT ps ;

 /***************************************************************************
  * Store header.							    *
  ***************************************************************************/

  p = (PBYTE) pFEA ;

  if ( pFEA )
  {
    pFEA->fEA = 0 ;
    pFEA->cbName = (BYTE) strlen ( (PCHAR)Item->Name ) ;
    pFEA->cbValue = Item->Length + 2 * sizeof(USHORT) ;
  }

  p += sizeof(FEA) ;

 /***************************************************************************
  * Store name. 							    *
  ***************************************************************************/

  if ( pFEA )
  {
    strcpy ( (PCHAR)p, (PCHAR)Item->Name ) ;
  }

  p += strlen ( (PCHAR)Item->Name ) + 1 ;

 /***************************************************************************
  * Store value's type.                                                     *
  ***************************************************************************/

  ps = (PSHORT) p ;

  if ( pFEA )
  {
    *ps = Item->Type ;
  }

  ps ++ ;

 /***************************************************************************
  * Store value's length.                                                   *
  ***************************************************************************/

  if ( pFEA )
  {
    *ps = Item->Length ;
  }

  ps ++ ;

 /***************************************************************************
  * Store value.							    *
  ***************************************************************************/

  p = (PBYTE) ps ;

  if ( pFEA )
  {
    memcpy ( p, Item->Value, Item->Length ) ;
  }

  p += Item->Length ;

 /***************************************************************************
  * Return count of bytes needed for item.				    *
  ***************************************************************************/

  return ( p - (PBYTE)pFEA ) ;
}

/****************************************************************************
 *									    *
 *	Build Multi-Value Multi-Type EA Item's Value                        *
 *									    *
 ****************************************************************************/

extern USHORT BuildMVMTValue ( PVOID Value, USHORT Count, MVMT_VALUE Table[] )
{
 /***************************************************************************
  *			     Declarations				    *
  ***************************************************************************/

  PBYTE p = (PBYTE) Value ;
  USHORT i ;

 /***************************************************************************
  * Store the number of values. 					    *
  ***************************************************************************/

  if ( Value )
    *((PUSHORT)p) = Count ;
  ((PUSHORT)p) ++ ;

 /***************************************************************************
  * Store the multiple values.						    *
  ***************************************************************************/

  for ( i=0; i<Count; i++ )
  {
    if ( Value )
      *((PUSHORT)p) = Table[i].Type ;

    ((PUSHORT)p) ++ ;

    if ( Value )
      *((PUSHORT)p) = Table[i].Length ;

    ((PUSHORT)p) ++ ;

    if ( Value )
      memcpy ( p, Table[i].Value, Table[i].Length ) ;

    p += Table[i].Length ;
  }

 /***************************************************************************
  * Return the total byte count.					    *
  ***************************************************************************/

  return ( p - (PBYTE)Value ) ;
}

/****************************************************************************
 *                                                                          *
 *      Process Exit menu command.                                          *
 *                                                                          *
 ****************************************************************************/

extern MRESULT APIENTRY Exit
(
  HWND hwnd,
  USHORT msg,
  MPARAM mp1,
  MPARAM mp2
)
{
 /***************************************************************************
  * Send a WM_CLOSE message to the window.                                  *
  ***************************************************************************/

  WinSendMsg ( hwnd, WM_CLOSE, 0L, 0L ) ;

 /***************************************************************************
  * Done.                                                                   *
  ***************************************************************************/

  return ( MRFROMSHORT ( 0 ) ) ;

  hwnd = hwnd ;  msg = msg ;  mp1 = mp1 ;  mp2 = mp2 ;
}

/****************************************************************************
 *                                                                          *
 *      Process Help For Help menu command.                                 *
 *                                                                          *
 ****************************************************************************/

extern MRESULT APIENTRY HelpForHelp
(
  HWND hwnd,
  USHORT msg,
  MPARAM mp1,
  MPARAM mp2
)
{
 /***************************************************************************
  * Local Declarations                                                      *
  ***************************************************************************/

  HWND hwndHelp ;

 /***************************************************************************
  * Get the help instance window handle, if any.                            *
  ***************************************************************************/

  hwndHelp = WinQueryHelpInstance ( hwnd ) ;

 /***************************************************************************
  * If help is available, pass the request on to the help window.           *
  ***************************************************************************/

  if ( hwndHelp )
  {
    WinSendMsg ( hwndHelp, HM_DISPLAY_HELP, 0L, 0L ) ;
  }

 /***************************************************************************
  * Done.                                                                   *
  ***************************************************************************/

  return ( MRFROMSHORT ( 0 ) ) ;

  hwnd = hwnd ;  msg = msg ;  mp1 = mp1 ;  mp2 = mp2 ;
}

/****************************************************************************
 *                                                                          *
 *      Process Extended Help menu command.                                 *
 *                                                                          *
 ****************************************************************************/

extern MRESULT APIENTRY ExtendedHelp
(
  HWND hwnd,
  USHORT msg,
  MPARAM mp1,
  MPARAM mp2
)
{
 /***************************************************************************
  * Local Declarations                                                      *
  ***************************************************************************/

  HWND hwndHelp ;

 /***************************************************************************
  * Get the help instance window handle, if any.                            *
  ***************************************************************************/

  hwndHelp = WinQueryHelpInstance ( hwnd ) ;

 /***************************************************************************
  * If help is available, pass the request on to the help window.           *
  ***************************************************************************/

  if ( hwndHelp )
  {
    WinSendMsg ( hwndHelp, HM_EXT_HELP, 0L, 0L ) ;
  }

 /***************************************************************************
  * Done.                                                                   *
  ***************************************************************************/

  return ( MRFROMSHORT ( 0 ) ) ;

  hwnd = hwnd ;  msg = msg ;  mp1 = mp1 ;  mp2 = mp2 ;
}

/****************************************************************************
 *                                                                          *
 *      Process Keys Help menu command.                                     *
 *                                                                          *
 ****************************************************************************/

extern MRESULT APIENTRY KeysHelp
(
  HWND hwnd,
  USHORT msg,
  MPARAM mp1,
  MPARAM mp2
)
{
 /***************************************************************************
  * Local Declarations                                                      *
  ***************************************************************************/

  HWND hwndHelp ;

 /***************************************************************************
  * Get the help instance window handle, if any.                            *
  ***************************************************************************/

  hwndHelp = WinQueryHelpInstance ( hwnd ) ;

 /***************************************************************************
  * If help is available, pass the request on to the help window.           *
  ***************************************************************************/

  if ( hwndHelp )
  {
    WinSendMsg ( hwndHelp, HM_KEYS_HELP, 0L, 0L ) ;
  }

 /***************************************************************************
  * Done.                                                                   *
  ***************************************************************************/

  return ( MRFROMSHORT ( 0 ) ) ;

  hwnd = hwnd ;  msg = msg ;  mp1 = mp1 ;  mp2 = mp2 ;
}

/****************************************************************************
 *                                                                          *
 *      Process Help Index menu command.                                    *
 *                                                                          *
 ****************************************************************************/

extern MRESULT APIENTRY HelpIndex
(
  HWND hwnd,
  USHORT msg,
  MPARAM mp1,
  MPARAM mp2
)
{
 /***************************************************************************
  * Local Declarations                                                      *
  ***************************************************************************/

  HWND hwndHelp ;

 /***************************************************************************
  * Get the help instance window handle, if any.                            *
  ***************************************************************************/

  hwndHelp = WinQueryHelpInstance ( hwnd ) ;

 /***************************************************************************
  * If help is available, pass the request on to the help window.           *
  ***************************************************************************/

  if ( hwndHelp )
  {
    WinSendMsg ( hwndHelp, HM_HELP_INDEX, 0L, 0L ) ;
  }

 /***************************************************************************
  * Done.                                                                   *
  ***************************************************************************/

  return ( MRFROMSHORT ( 0 ) ) ;

  hwnd = hwnd ;  msg = msg ;  mp1 = mp1 ;  mp2 = mp2 ;
}
