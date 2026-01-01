/******************************************************************** ITEMS.H
 *									    *
 *		       Display Item Class Definition			    *
 *									    *
 ****************************************************************************/

#ifndef ITEMS_H
#define ITEMS_H

class Item
{
  private:
    USHORT Id ; 		 // Item ID.
    BOOL   Flag ;		 // Flag: Show this item at this time?
    BYTE   Name [80] ;		 // Text for items profile name.
    BYTE   Label [80] ; 	 // Text to display on left part of line.
    BYTE   MenuOption [80] ;	 // Text to display in system menu.

  protected:
    ULONG  Value ;		 // Current value.

  public:
    Item ( USHORT id, PSZ pName, PSZ pLabel, PSZ pMenuOption )
    {
      Id = id ;
      Flag = TRUE ;
      strcpy ( PCHAR(Name), PCHAR(pName) ) ;
      strcpy ( PCHAR(Label), PCHAR(pLabel) ) ;
      strcpy ( PCHAR(MenuOption), PCHAR(pMenuOption) ) ;
      Value = 0 ;
    }

    USHORT QueryId     ( void ) { return ( Id	) ; }
    BOOL   QueryFlag   ( void ) { return ( Flag ) ; }
    PBYTE  QueryName   ( void ) { return ( Name ) ; }
    PBYTE  QueryLabel  ( void ) { return ( Label ) ; }
    PBYTE  QueryOption ( void ) { return ( MenuOption ) ; }
    ULONG  QueryValue  ( void ) { return ( Value ) ; }

    VOID SetFlag   ( void ) { Flag = TRUE ; }
    VOID ResetFlag ( void ) { Flag = FALSE ; }

    VOID Paint
    (
      HPS hPS,
      RECTL &Rectangle,
      COLOR TextColor,
      COLOR BackColor,
      PSZ Text,
      ULONG NewValue
    ) ;

    virtual ULONG NewValue ( void )
    {
      return ( 0 ) ;
    }

    virtual VOID Repaint
    (
      HPS hPS,
      RECTL &Rectangle,
      COLOR TextColor,
      COLOR BackColor,
      BOOL Mandatory
    )
    {
      return ;
    }
} ;

class Clock : public Item
{
  private:
    COUNTRYINFO CountryInfo ;
    ResourceString *DaysOfWeek ;

  public:
    Clock ( USHORT id, PSZ pName, PSZ pLabel, PSZ pMenuOption, COUNTRYINFO &countryinfo, class ResourceString *daysofweek )
      : Item ( id, pName, pLabel, pMenuOption )
    {
      CountryInfo = countryinfo ;
      DaysOfWeek = daysofweek ;
    }

    ULONG NewValue ( void ) ;

    VOID Repaint
    (
      HPS hPS,
      RECTL &Rectangle,
      COLOR TextColor,
      COLOR BackColor,
      BOOL Mandatory
    ) ;
} ;

class ElapsedTime : public Item
{
  private:
    COUNTRYINFO CountryInfo ;
    ResourceString *Day ;
    ResourceString *Days ;

  public:
    ElapsedTime ( USHORT id, PSZ pName, PSZ pLabel, PSZ pMenuOption, COUNTRYINFO &countryinfo, class ResourceString *day, class ResourceString *days )
      : Item ( id, pName, pLabel, pMenuOption )
    {
      CountryInfo = countryinfo ;
      Day = day ;
      Days = days ;
    }

    ULONG NewValue ( void ) ;

    VOID Repaint
    (
      HPS hPS,
      RECTL &Rectangle,
      COLOR TextColor,
      COLOR BackColor,
      BOOL Mandatory
    ) ;
} ;

class MemoryFree : public Item
{
  private:
    COUNTRYINFO CountryInfo ;
    class SwapFree *SwapFree ;

  public:
    MemoryFree ( USHORT id, PSZ pName, PSZ pLabel, PSZ pMenuOption, COUNTRYINFO &countryinfo, class SwapFree *swapfree )
      : Item ( id, pName, pLabel, pMenuOption )
    {
      CountryInfo = countryinfo ;
      SwapFree = swapfree ;
    }

    ULONG NewValue ( void ) ;

    VOID Repaint
    (
      HPS hPS,
      RECTL &Rectangle,
      COLOR TextColor,
      COLOR BackColor,
      BOOL Mandatory
    ) ;
} ;

class SwapSize : public Item
{
  private:
    COUNTRYINFO CountryInfo ;
    PSZ SwapPath ;

  public:
    SwapSize ( USHORT id, PSZ pName, PSZ pLabel, PSZ pMenuOption, COUNTRYINFO countryinfo, PSZ swappath )
      : Item ( id, pName, pLabel, pMenuOption )
    {
      CountryInfo = countryinfo ;
      SwapPath = new BYTE [ strlen(PCHAR(swappath)) + 1 ] ;
      strcpy ( PCHAR(SwapPath), PCHAR(swappath) ) ;
    }

    ~SwapSize ( void )
    {
      delete [] SwapPath ;
    }

    ULONG NewValue ( void ) ;

    VOID Repaint
    (
      HPS hPS,
      RECTL &Rectangle,
      COLOR TextColor,
      COLOR BackColor,
      BOOL Mandatory
    ) ;
} ;

class SwapFree : public Item
{
  private:
    COUNTRYINFO CountryInfo ;
    PSZ SwapPath ;
    ULONG MinFree ;

  public:
    SwapFree ( USHORT id, PSZ pName, PSZ pLabel, PSZ pMenuOption, COUNTRYINFO &countryinfo, PSZ swappath, ULONG minfree )
      : Item ( id, pName, pLabel, pMenuOption )
    {
      CountryInfo = countryinfo ;
      SwapPath = new BYTE [ strlen(PCHAR(swappath)) + 1 ] ;
      strcpy ( PCHAR(SwapPath), PCHAR(swappath) ) ;
      MinFree = minfree ;
    }

    ~SwapFree ( void )
    {
      delete [] SwapPath ;
    }

    ULONG NewValue ( void ) ;

    VOID Repaint
    (
      HPS hPS,
      RECTL &Rectangle,
      COLOR TextColor,
      COLOR BackColor,
      BOOL Mandatory
    ) ;
} ;

class SpoolSize : public Item
{
  private:
    COUNTRYINFO CountryInfo ;
    PSZ SpoolPath ;

  public:
    SpoolSize ( USHORT id, PSZ pName, PSZ pLabel, PSZ pMenuOption, COUNTRYINFO &countryinfo, PSZ spoolpath )
      : Item ( id, pName, pLabel, pMenuOption )
    {
      CountryInfo = countryinfo ;
      SpoolPath = new BYTE [ strlen(PCHAR(spoolpath)) + 1 ] ;
      strcpy ( PCHAR(SpoolPath), PCHAR(spoolpath) ) ;
    }

    ~SpoolSize ( void )
    {
      delete [] SpoolPath ;
    }

    ULONG NewValue ( void ) ;

    VOID Repaint
    (
      HPS hPS,
      RECTL &Rectangle,
      COLOR TextColor,
      COLOR BackColor,
      BOOL Mandatory
    ) ;
} ;

class CpuLoad : public Item
{
  private:
    PULONG IdleCount ;
    ULONG MaxCount ;

  public:
    CpuLoad ( USHORT id, PSZ pName, PSZ pLabel, PSZ pMenuOption, ULONG maxcount, PULONG idlecount )
      : Item ( id, pName, pLabel, pMenuOption )
    {
      MaxCount = maxcount ;
      IdleCount = idlecount ;
    }

    ULONG NewValue ( void ) ;

    VOID Repaint
    (
      HPS hPS,
      RECTL &Rectangle,
      COLOR TextColor,
      COLOR BackColor,
      BOOL Mandatory
    ) ;
} ;

class TaskCount : public Item
{
  private:
    HAB Anchor ;

  public:
    TaskCount ( USHORT id, PSZ pName, PSZ pLabel, PSZ pMenuOption, HAB anchor )
      : Item ( id, pName, pLabel, pMenuOption )
    {
      Anchor = anchor ;
    }

    ULONG NewValue ( void ) ;

    VOID Repaint
    (
      HPS hPS,
      RECTL &Rectangle,
      COLOR TextColor,
      COLOR BackColor,
      BOOL Mandatory
    ) ;
} ;

class DriveFree : public Item
{
  private:
    COUNTRYINFO CountryInfo ;
    class ResourceString *DriveError ;
    USHORT DriveNumber ;
    BOOL Error ;

  public:
    DriveFree ( USHORT id, PSZ pName, PSZ pLabel, PSZ pMenuOption, COUNTRYINFO &countryinfo, USHORT drivenumber, class ResourceString *driveerror )
      : Item ( id, pName, pLabel, pMenuOption )
    {
      CountryInfo = countryinfo ;
      DriveError = driveerror ;
      DriveNumber = drivenumber ;
      Error = FALSE ;
    }

    ULONG NewValue ( void ) ;

    VOID Repaint
    (
      HPS hPS,
      RECTL &Rectangle,
      COLOR TextColor,
      COLOR BackColor,
      BOOL Mandatory
    ) ;
} ;

class TotalFree : public Item
{
  private:
    COUNTRYINFO CountryInfo ;
    ULONG Drives ;

  public:
    TotalFree ( USHORT id, PSZ pName, PSZ pLabel, PSZ pMenuOption, COUNTRYINFO &countryinfo, ULONG drives )
      : Item ( id, pName, pLabel, pMenuOption )
    {
      CountryInfo = countryinfo ;
      Drives = drives ;
    }

    VOID ResetMask ( ULONG drives ) { Drives = drives ; }

    ULONG NewValue ( void ) ;

    VOID Repaint
    (
      HPS hPS,
      RECTL &Rectangle,
      COLOR TextColor,
      COLOR BackColor,
      BOOL Mandatory
    ) ;
} ;

#endif
