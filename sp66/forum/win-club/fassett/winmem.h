//---------------------------------------------------------------------------
// WinMem.h
//---------------------------------------------------------------------------
// Function prototypes for WinMem.asm
//---------------------------------------------------------------------------
// Public domain
// Written by Michael Geary
//---------------------------------------------------------------------------

#include <windows.h>

//---------------------------------------------------------------------------

short     PASCAL lmemcmp( LPVOID lpOne, LPVOID lpTwo, WORD cbMem );
LPVOID    PASCAL lmemcpy( LPVOID lpDest, LPVOID lpSrc, WORD cbMem );
LPVOID    PASCAL lmemset( LPVOID lpMem, short chr, WORD cbMem );

#define  lmemeq( lpA, lpB, cbMem )  ( lmemcmp( (lpA), (lpB), (cbMem) ) == 0 )

#define  lmemzero( lpMem )          lmemset( (lpMem), 0, sizeof(*(lpMem)) )

//---------------------------------------------------------------------------

