// enumfont.c
//***************************************************************
//*                                                             *
//*                DLL to allow VB to use EnumFonts             *
//*                                                             *
//*  Copyright (C) Telelink Systems 1991 All Rights Reserved    *
//*  Phone:  (916) 332-2671                   Fax:  332-2529    *
//***************************************************************
//
// Compilation instructions:
//    Turbo C++
//    Small model
//    SS=!DS

#include <windows.h>
#include <drivinit.h>

HANDLE hCallerInstance;

// Globals
int nFontIndex;                       // Running font number
int nUserArraySize;                   // Size of the array provided by user
LPLOGFONT  lpUserLogFontArray;        // User's logical font array or NULL
LPTEXTMETRIC lpUserTextMetricArray;   // User's text metric array or NULL
LPINT lpnUserFontTypeArray;           // User's font type array or NULL

// Call back routine
int FAR PASCAL  EnumFontsCallBack(
		   LPLOGFONT lpLogFont,
		   LPTEXTMETRIC lpTextMetric,
		   short nFontType,
		   LPSTR lpData)
{
   // If user allocated space, move the data
   if (nFontIndex<=nUserArraySize-1){
       if (lpUserLogFontArray) *(lpUserLogFontArray+nFontIndex)=*lpLogFont;
       if (lpUserTextMetricArray) *(lpUserTextMetricArray+nFontIndex)=*lpTextMetric;
       if (lpnUserFontTypeArray) *(lpnUserFontTypeArray+nFontIndex)=nFontType;
   }
   // Increment number of fonts and return the number
   return(++nFontIndex);
}

// DLL Entry from Visual Basic
int FAR PASCAL _export VBEnumFonts(
	      HDC hDC,                       // Device Context handle
	      LPSTR lpFaceName,              // typeface or null if all
	      LPLOGFONT lpLogFontArray,        // Array of LOGFONT elements or null
	      LPTEXTMETRIC lpTextMetricArray,// Array of TEXTMETRIC elements or null
	      LPINT nFontTypeArray,          // Array of integers or null
	      int nArraySize                 // Size of the arrays or 0
	      )                              // Returns number of fonts available
{
    static FARPROC lpfnEnumFontCallBack;

    // Register the call-back routine
    if (!lpfnEnumFontCallBack) lpfnEnumFontCallBack=MakeProcInstance(EnumFontsCallBack,hCallerInstance);

    // Initialize global structure
    nFontIndex=0;
    nUserArraySize=nArraySize;
    lpUserLogFontArray=lpLogFontArray;
    lpUserTextMetricArray=lpTextMetricArray;
    lpnUserFontTypeArray=nFontTypeArray;

    return(EnumFonts(hDC,lpFaceName,lpfnEnumFontCallBack,NULL));
}


int FAR PASCAL LibMain(HANDLE hInstance,WORD wDataSet, WORD cbHeapSize, LPSTR lpszCmdLine)
{
    hCallerInstance=hInstance;
    return (1);
}
