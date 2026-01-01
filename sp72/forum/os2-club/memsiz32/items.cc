/******************************************************************* ITEMS.CC
 *									    *
 *		       Display Item Class Functions			    *
 *									    *
 ****************************************************************************/

#define INCL_BASE
#define INCL_PM
#include <os2.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "debug.h"
#include "support.h"
#include "restring.h"

#include "items.h"


VOID Item::Paint
(
  HPS hPS,
  RECTL &Rectangle,
  COLOR TextColor,
  COLOR BackColor,
  PSZ Text,
  ULONG NewValue
)
{
  WinDrawText ( hPS, strlen(PCHAR(Text)), Text, &Rectangle,
    TextColor, BackColor, DT_RIGHT | DT_BOTTOM | DT_ERASERECT ) ;

  WinDrawText ( hPS, strlen(PCHAR(Label)), Label, &Rectangle,
    TextColor, BackColor, DT_LEFT | DT_BOTTOM ) ;

  Value = NewValue ;
}


ULONG Clock::NewValue ( void )
{
  DATETIME DateTime ;
  DosGetDateTime ( &DateTime ) ;

  ULONG Time ;
  Time	= DateTime.weekday ;
  Time *= 100 ;
  Time += DateTime.month ;
  Time *= 100 ;
  Time += DateTime.day ;
  Time *= 100 ;
  Time += DateTime.hours ;
  Time *= 100 ;
  Time += DateTime.minutes ;

  return ( Time ) ;
}


VOID Clock::Repaint
(
  HPS hPS,
  RECTL &Rectangle,
  COLOR TextColor,
  COLOR BackColor,
  BOOL Mandatory
)
{
  ULONG Time = NewValue ( ) ;

  if ( Mandatory || ( Time != Value ) )
  {
    BYTE Text [100] ;
    ULONG Dow	 = ( Time % 1000000000L ) / 100000000L ;
    ULONG Month  = ( Time % 100000000L )  / 1000000L ;
    ULONG Day	 = ( Time % 1000000L )	  / 10000L ;
    ULONG Hour	 = ( Time % 10000L )	  / 100L ;
    ULONG Minute = ( Time % 100L ) ;

    sprintf ( PCHAR(Text), "%0.3s, ", DaysOfWeek->Ptr() + Dow*3 ) ;

    switch ( CountryInfo.fsDateFmt )
    {
      case DATEFMT_DD_MM_YY:
	sprintf ( PCHAR(Text)+strlen(PCHAR(Text)), "%02lu%s%02lu ",
	  Day, CountryInfo.szDateSeparator, Month ) ;
	break ;

      case DATEFMT_YY_MM_DD:
      case DATEFMT_MM_DD_YY:
      default:
	sprintf ( PCHAR(Text)+strlen(PCHAR(Text)), "%02lu%s%02lu ",
	  Month, CountryInfo.szDateSeparator, Day ) ;
	break ;
    }

    if ( CountryInfo.fsTimeFmt )
    {
      sprintf ( PCHAR(Text)+strlen(PCHAR(Text)), "%02lu%s%02lu",
	Hour,
	CountryInfo.szTimeSeparator,
	Minute ) ;
    }
    else
    {
      PCHAR AmPm ;

      if ( Hour )
      {
	if ( Hour < 12 )
	{
	  AmPm = "a" ;
	}
	else if ( Hour == 12 )
	{
	  if ( Minute )
	    AmPm = "p" ;
	  else
	    AmPm = "a" ;
	}
	else if ( Hour > 12 )
	{
	  Hour -= 12 ;
	  AmPm = "p" ;
	}
      }
      else
      {
	Hour = 12 ;
	if ( Minute )
	  AmPm = "a" ;
	else
	  AmPm = "p" ;
      }
      sprintf ( PCHAR(Text)+strlen(PCHAR(Text)), "%02lu%s%02lu%s",
	Hour, CountryInfo.szTimeSeparator, Minute, AmPm ) ;
    }

    Paint ( hPS, Rectangle, TextColor, BackColor, Text, Time ) ;
  }
}


ULONG ElapsedTime::NewValue ( void )
{
  ULONG Milliseconds ;
  DosQuerySysInfo ( QSV_MS_COUNT, QSV_MS_COUNT, &Milliseconds, sizeof(Milliseconds) ) ;
  return ( Milliseconds / 60000L ) ;
}


VOID ElapsedTime::Repaint
(
  HPS hPS,
  RECTL &Rectangle,
  COLOR TextColor,
  COLOR BackColor,
  BOOL Mandatory
)
{
  ULONG Time = NewValue ( ) ;

  if ( Mandatory || ( Time != Value ) )
  {
    BYTE Text [100] ;

    memset ( Text, 0, sizeof(Text) ) ;

    ULONG NumberOfDays = Time / ( 60L * 24L ) ;

    if ( NumberOfDays )
    {
      sprintf ( PCHAR(Text), "%lu %s, ",
	NumberOfDays, NumberOfDays > 1 ? Days->Ptr() : Day->Ptr() ) ;
    }

    ULONG Minutes = Time % ( 60L * 24L ) ;

    sprintf ( PCHAR(Text+strlen(PCHAR(Text))), "%lu%s%02lu",
      Minutes/60, CountryInfo.szTimeSeparator, Minutes%60 ) ;

    Paint ( hPS, Rectangle, TextColor, BackColor, Text, Time ) ;
  }
}


ULONG MemoryFree::NewValue ( void )
{
  ULONG VirtualMemory ;
  DosQuerySysInfo ( QSV_TOTAVAILMEM, QSV_TOTAVAILMEM, &VirtualMemory, sizeof(VirtualMemory) ) ;

  ULONG SwapDiskFree = SwapFree->NewValue ( ) ;

  LONG Space = LONG(VirtualMemory) - LONG(SwapDiskFree) ;

  while ( Space < 0 )
  {
    Space += 0x100000 ;
  }

  return ( ULONG(Space) ) ;
}


VOID MemoryFree::Repaint
(
  HPS hPS,
  RECTL &Rectangle,
  COLOR TextColor,
  COLOR BackColor,
  BOOL Mandatory
)
{
  ULONG Size = NewValue ( ) ;

  if ( Mandatory || ( Size != Value ) )
  {
    BYTE Text [100] ;

    if ( Size < 0x80000 )
      sprintf ( (PCHAR)Text, "%lu", Size ) ;
    else
      sprintf ( (PCHAR)Text, "%lu", (Size+512)/1024 ) ;

    {
      PBYTE p1, p2 ;
      BYTE Work[100] ;

      p1 = Text ;
      p2 = Work ;
      while ( *p1 )
      {
	*p2 = *p1 ;
	p1 ++ ;
	p2 ++ ;
	if ( *p1 )
	{
	  if ( strlen((PCHAR)p1) % 3 == 0 )
	  {
	    *p2 = CountryInfo.szThousandsSeparator [0] ;
	    p2 ++ ;
	  }
	}
      }
      *p2 = 0 ;
      strcpy ( (PCHAR)Text, (PCHAR)Work ) ;
    }

    Text[strlen(PCHAR(Text))+1] = 0 ;
    if ( Size < 0x80000 )
      Text[strlen((PCHAR)Text)] = ' ' ;
    else
      Text[strlen((PCHAR)Text)] = 'K' ;

    Paint ( hPS, Rectangle, TextColor, BackColor, Text, Size ) ;
  }
}


ULONG SwapSize::NewValue ( void )
{
  char Path [_MAX_PATH+1] ;

  strcpy ( Path, (PCHAR)SwapPath ) ;

  if ( Path[strlen(Path)-1] != '\\' )
  {
    strcat ( Path, "\\" ) ;
  }

  strcat ( Path, "SWAPPER.DAT" ) ;

  ULONG SwapSize = 0 ;
  FILESTATUS3 Status ;
  if ( DosQueryPathInfo ( (PSZ)Path, FIL_STANDARD, &Status, sizeof(Status) ) == 0 )
  {
    SwapSize = Status.cbFileAlloc ;
  }

  return ( SwapSize ) ;
}


VOID SwapSize::Repaint
(
  HPS hPS,
  RECTL &Rectangle,
  COLOR TextColor,
  COLOR BackColor,
  BOOL Mandatory
)
{
  ULONG Size = NewValue ( ) ;

  if ( Mandatory || ( Size != Value ) )
  {
    BYTE Text [100] ;

    if ( Size < 0x80000 )
      sprintf ( (PCHAR)Text, "%lu", Size ) ;
    else
      sprintf ( (PCHAR)Text, "%lu", (Size+512)/1024 ) ;

    {
      PBYTE p1, p2 ;
      BYTE Work[100] ;

      p1 = Text ;
      p2 = Work ;
      while ( *p1 )
      {
	*p2 = *p1 ;
	p1 ++ ;
	p2 ++ ;
	if ( *p1 )
	{
	  if ( strlen((PCHAR)p1) % 3 == 0 )
	  {
	    *p2 = CountryInfo.szThousandsSeparator [0] ;
	    p2 ++ ;
	  }
	}
      }
      *p2 = 0 ;
      strcpy ( (PCHAR)Text, (PCHAR)Work ) ;
    }

    Text[strlen(PCHAR(Text))+1] = 0 ;
    if ( Size < 0x80000 )
      Text[strlen((PCHAR)Text)] = ' ' ;
    else
      Text[strlen((PCHAR)Text)] = 'K' ;

    Paint ( hPS, Rectangle, TextColor, BackColor, Text, Size ) ;
  }
}


ULONG SwapFree::NewValue ( void )
{
  char Path [_MAX_PATH+1] ;

  strcpy ( Path, (PCHAR)SwapPath ) ;
  strcat ( Path, "\\SWAPPER.DAT" ) ;

  ULONG SwapFree = 0 ;
  if ( Path[0] )
  {
    DosError ( FERR_DISABLEHARDERR ) ;
    FSALLOCATE Allocation ;
    DosQueryFSInfo ( Path[0]-'A'+1, FSIL_ALLOC,
      (PBYTE)&Allocation, sizeof(Allocation) ) ;
    DosError ( FERR_ENABLEHARDERR ) ;

    SwapFree = Allocation.cUnitAvail*Allocation.cSectorUnit*Allocation.cbSector ;
  }

  if ( SwapFree < ULONG(MinFree*1024L) )
    return ( 0L ) ;
  else
    return ( SwapFree - ULONG(MinFree*1024L) ) ;
}


VOID SwapFree::Repaint
(
  HPS hPS,
  RECTL &Rectangle,
  COLOR TextColor,
  COLOR BackColor,
  BOOL Mandatory
)
{
  ULONG Size = NewValue ( ) ;

  if ( Mandatory || ( Size != Value ) )
  {
    BYTE Text [100] ;

    if ( Size < 0x80000 )
      sprintf ( (PCHAR)Text, "%lu", Size ) ;
    else
      sprintf ( (PCHAR)Text, "%lu", (Size+512)/1024 ) ;

    {
      PBYTE p1, p2 ;
      BYTE Work[100] ;

      p1 = Text ;
      p2 = Work ;
      while ( *p1 )
      {
	*p2 = *p1 ;
	p1 ++ ;
	p2 ++ ;
	if ( *p1 )
	{
	  if ( strlen((PCHAR)p1) % 3 == 0 )
	  {
	    *p2 = CountryInfo.szThousandsSeparator [0] ;
	    p2 ++ ;
	  }
	}
      }
      *p2 = 0 ;
      strcpy ( (PCHAR)Text, (PCHAR)Work ) ;
    }

    Text[strlen(PCHAR(Text))+1] = 0 ;
    if ( Size < 0x80000 )
      Text[strlen((PCHAR)Text)] = ' ' ;
    else
      Text[strlen((PCHAR)Text)] = 'K' ;

    Paint ( hPS, Rectangle, TextColor, BackColor, Text, Size ) ;
  }
}


ULONG SpoolSize::NewValue ( void )
{
  ULONG PathSize ;
  DosQuerySysInfo ( QSV_MAX_PATH_LENGTH, QSV_MAX_PATH_LENGTH, &PathSize, sizeof(PathSize) ) ;

  PBYTE Path = malloc ( PathSize ) ;
  if ( Path == NULL )
  {
//  Log ( "ERROR: Unable to allocate memory for spool-file search path.\r\n" ) ;
    return ( 0 ) ;
  }

  PFILEFINDBUF3 Found = malloc ( PathSize + sizeof(FILEFINDBUF3) ) ;
  if ( Found == NULL )
  {
//  Log ( "ERROR: Unable to allocate memory for spool-file search result structure.\r\n" ) ;
    free ( Path ) ;
    return ( 0 ) ;
  }

  strcpy ( (PCHAR)Path, (PCHAR)SpoolPath ) ;
  strcat ( (PCHAR)Path, "\\*.*" ) ;

  HDIR hDir = (HDIR) HDIR_CREATE ;
  ULONG Count = 1 ;
  ULONG TotalSize = 0 ;

  if ( !DosFindFirst2 ( Path, &hDir,
    FILE_NORMAL | FILE_READONLY | FILE_DIRECTORY | FILE_ARCHIVED,
    Found, PathSize+sizeof(FILEFINDBUF3), &Count, FIL_STANDARD ) )
  {

    do
    {

      if ( !strcmp ( (PCHAR)Found->achName, "." )
	OR !strcmp ( (PCHAR)Found->achName, ".." ) )
      {
	continue ;
      }

      if ( Found->attrFile & FILE_DIRECTORY )
      {
	HDIR hDir = (HDIR) HDIR_CREATE ;

	strcpy ( (PCHAR)Path, (PCHAR)SpoolPath ) ;
	strcat ( (PCHAR)Path, "\\" ) ;
	strcat ( (PCHAR)Path, (PCHAR)Found->achName ) ;
	strcat ( (PCHAR)Path, "\\*.*" ) ;

	Count = 1 ;
	if ( !DosFindFirst2 ( Path, &hDir,
	  FILE_NORMAL | FILE_READONLY | FILE_ARCHIVED,
	  Found, PathSize+sizeof(FILEFINDBUF3), &Count, FIL_STANDARD ) )
	{
	  do
	  {
	    TotalSize += Found->cbFileAlloc ;
	  }
	  while ( !DosFindNext ( hDir, Found, PathSize+sizeof(FILEFINDBUF3), &Count ) ) ;
	  DosFindClose ( hDir ) ;
	}

	Count = 1 ;
      }

      else
      {
	TotalSize += Found->cbFileAlloc ;
      }
    }
    while ( !DosFindNext ( hDir, Found, PathSize+sizeof(FILEFINDBUF3), &Count ) ) ;

    DosFindClose ( hDir ) ;
  }

  free ( Path ) ;
  free ( Found ) ;

  return ( TotalSize ) ;
}


VOID SpoolSize::Repaint
(
  HPS hPS,
  RECTL &Rectangle,
  COLOR TextColor,
  COLOR BackColor,
  BOOL Mandatory
)
{
  ULONG Size = NewValue ( ) ;

  if ( Mandatory || ( Size != Value ) )
  {
    BYTE Text [100] ;

    if ( Size < 0x80000 )
      sprintf ( (PCHAR)Text, "%lu", Size ) ;
    else
      sprintf ( (PCHAR)Text, "%lu", (Size+512)/1024 ) ;

    {
      PBYTE p1, p2 ;
      BYTE Work[100] ;

      p1 = Text ;
      p2 = Work ;
      while ( *p1 )
      {
	*p2 = *p1 ;
	p1 ++ ;
	p2 ++ ;
	if ( *p1 )
	{
	  if ( strlen((PCHAR)p1) % 3 == 0 )
	  {
	    *p2 = CountryInfo.szThousandsSeparator [0] ;
	    p2 ++ ;
	  }
	}
      }
      *p2 = 0 ;
      strcpy ( (PCHAR)Text, (PCHAR)Work ) ;
    }

    Text[strlen(PCHAR(Text))+1] = 0 ;
    if ( Size < 0x80000 )
      Text[strlen((PCHAR)Text)] = ' ' ;
    else
      Text[strlen((PCHAR)Text)] = 'K' ;

    Paint ( hPS, Rectangle, TextColor, BackColor, Text, Size ) ;
  }
}


ULONG CpuLoad::NewValue ( void )
{
  MaxCount = (ULONG) max ( MaxCount, *IdleCount ) ;

  ULONG Load = ( ( MaxCount - *IdleCount ) * 100 ) / MaxCount ;

  return ( Load ) ;
}


VOID CpuLoad::Repaint
(
  HPS hPS,
  RECTL &Rectangle,
  COLOR TextColor,
  COLOR BackColor,
  BOOL Mandatory
)
{
  ULONG Load = NewValue ( ) ;

  if ( Mandatory || ( Load != Value ) )
  {
    BYTE Text [100] ;
    sprintf ( (PCHAR)Text, "%lu%%", Load ) ;
    Paint ( hPS, Rectangle, TextColor, BackColor, Text, Load ) ;
  }
}


ULONG TaskCount::NewValue ( void )
{
  return ( WinQuerySwitchList ( Anchor, NULL, 0 ) ) ;
}


VOID TaskCount::Repaint
(
  HPS hPS,
  RECTL &Rectangle,
  COLOR TextColor,
  COLOR BackColor,
  BOOL Mandatory
)
{
  ULONG Count = NewValue ( ) ;

  if ( Mandatory || ( Count != Value ) )
  {
    BYTE Text [100] ;
    sprintf ( (PCHAR)Text, "%lu ", Count ) ;
    Paint ( hPS, Rectangle, TextColor, BackColor, Text, Count ) ;
  }
}


ULONG DriveFree::NewValue ( void )
{
  if ( Error )
  {
    return ( 0 ) ;
  }

  DosError ( FERR_DISABLEHARDERR ) ;

  FSALLOCATE Allocation ;
  USHORT Status = DosQueryFSInfo ( DriveNumber, FSIL_ALLOC, (PBYTE)&Allocation, sizeof(Allocation) ) ;

  DosError ( FERR_ENABLEHARDERR ) ;

  if ( Status )
  {
    Error = TRUE ;
    return ( 0 ) ;
  }

  return ( Allocation.cUnitAvail*Allocation.cSectorUnit*Allocation.cbSector ) ;
}


VOID DriveFree::Repaint
(
  HPS hPS,
  RECTL &Rectangle,
  COLOR TextColor,
  COLOR BackColor,
  BOOL Mandatory
)
{
  ULONG Size = NewValue ( ) ;

  if ( Mandatory || ( Size != Value ) )
  {
    BYTE Text [100] ;

    if ( Error )
    {
      strcpy ( PCHAR(Text), PCHAR(DriveError->Ptr()) ) ;
    }
    else
    {
      if ( Size < 0x80000 )
	sprintf ( (PCHAR)Text, "%lu", Size ) ;
      else
	sprintf ( (PCHAR)Text, "%lu", (Size+512)/1024 ) ;

      {
	PBYTE p1, p2 ;
	BYTE Work[100] ;

	p1 = Text ;
	p2 = Work ;
	while ( *p1 )
	{
	  *p2 = *p1 ;
	  p1 ++ ;
	  p2 ++ ;
	  if ( *p1 )
	  {
	    if ( strlen((PCHAR)p1) % 3 == 0 )
	    {
	      *p2 = CountryInfo.szThousandsSeparator [0] ;
	      p2 ++ ;
	    }
	  }
	}
	*p2 = 0 ;
	strcpy ( (PCHAR)Text, (PCHAR)Work ) ;
      }

      Text[strlen(PCHAR(Text))+1] = 0 ;
      if ( Size < 0x80000 )
	Text[strlen((PCHAR)Text)] = ' ' ;
      else
	Text[strlen((PCHAR)Text)] = 'K' ;
    }

    Paint ( hPS, Rectangle, TextColor, BackColor, Text, Size ) ;
  }
}


ULONG TotalFree::NewValue ( void )
{
  ULONG Free = 0 ;
  ULONG Mask = Drives >> 2 ;

  for ( int Drive=3; Drive<=26; Drive++ )
  {
    if ( Mask & 1 )
    {
      DosError ( FERR_DISABLEHARDERR ) ;

      FSALLOCATE Allocation ;
      USHORT Status = DosQueryFSInfo ( Drive, FSIL_ALLOC, (PBYTE)&Allocation, sizeof(Allocation) ) ;

      DosError ( FERR_ENABLEHARDERR ) ;

      if ( Status )
      {
	Drives &= ~ ( 1 << (Drive-1) ) ;
      }
      else
      {
	Free += Allocation.cUnitAvail*Allocation.cSectorUnit*Allocation.cbSector ;
      }
    }
    Mask >>= 1 ;
  }

  return ( Free ) ;
}


VOID TotalFree::Repaint
(
  HPS hPS,
  RECTL &Rectangle,
  COLOR TextColor,
  COLOR BackColor,
  BOOL Mandatory
)
{
  ULONG Size = NewValue ( ) ;

  if ( Mandatory || ( Size != Value ) )
  {
    BYTE Text [100] ;

    if ( Size < 0x80000 )
      sprintf ( (PCHAR)Text, "%lu", Size ) ;
    else
      sprintf ( (PCHAR)Text, "%lu", (Size+512)/1024 ) ;

    {
      PBYTE p1, p2 ;
      BYTE Work[100] ;

      p1 = Text ;
      p2 = Work ;
      while ( *p1 )
      {
	*p2 = *p1 ;
	p1 ++ ;
	p2 ++ ;
	if ( *p1 )
	{
	  if ( strlen((PCHAR)p1) % 3 == 0 )
	  {
	    *p2 = CountryInfo.szThousandsSeparator [0] ;
	    p2 ++ ;
	  }
	}
      }
      *p2 = 0 ;
      strcpy ( (PCHAR)Text, (PCHAR)Work ) ;
    }

    Text[strlen(PCHAR(Text))+1] = 0 ;
    if ( Size < 0x80000 )
      Text[strlen((PCHAR)Text)] = ' ' ;
    else
      Text[strlen((PCHAR)Text)] = 'K' ;

    Paint ( hPS, Rectangle, TextColor, BackColor, Text, Size ) ;
  }
}
