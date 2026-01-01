*--------------------------------------------------------------------------
*                         CA-CLIPPER 5.xx VERSION
*--------------------------------------------------------------------------
* RBckDemo.PRG - Program to demonstrate the use of the functions
*                in the CA-Clipper Library, RBckLib v1.0d
*
* Used functions :
*
*       R_BackUp ()   - Make a backup to floppy disk
*       R_Restore ()  - Restores a backup from floppy disk
*	R_BckList ()  - Gathers information from a backup-set
*
* Compile    :  CLIPPER RBCKDEMO /N
*
* Link       :  RTLINK   file RBCKDEMO lib RBck_C50    - or -
*               BLINKER  file RBCKDEMO lib RBck_C50    - or -
*               EXOSPACE file RBCKDEMO lib RBck_C50 EXO PACK INT10
*		(For Clipper 5.2x replace RBck_C50 with RBck_C52)
*
* Syntax     :  RBCKDEMO
*--------------------------------------------------------------------------
* Date       :  18/01/95
*--------------------------------------------------------------------------
* Author     :  Rolf van Gelder
*               Binnenwiertzstraat 27
*               5615 HG  EINDHOVEN
*               THE NETHERLANDS
*
* E-Mail     :  Internet   : RCROLF@urc.tue.nl
*               BitNet     : RCROLF@heitue5
*               CompuServe : >INTERNET:rcrolf@urc.tue.nl
*--------------------------------------------------------------------------
* (c) 1993-95  Rolf van Gelder, All rights reserved
*--------------------------------------------------------------------------

*--------------------------------------------------------------------------
* Standard Clipper HEADER files
*--------------------------------------------------------------------------
#include "Set.CH"
#include "SetCurs.CH"

*--------------------------------------------------------------------------
* RBCKLIB header file
*--------------------------------------------------------------------------
#include "RBCKLib.CH"

*--------------------------------------------------------------------------
* Static variables
*--------------------------------------------------------------------------
*-- Initialize the array with error messages (from RBckLib.CH)
STATIC  aErrTxt := BU_ERRMSG

*-- Overwrite confirmation flag
STATIC	lConfirm

*-- Column to display the [ok] message
STATIC	nLastCol

*--------------------------------------------------------------------------
* STATIC CODEBLOCKS
*--------------------------------------------------------------------------
*-- Display headerline (with clear screen)
STATIC  bHeader := { || Scroll (), DevPos ( 0, 0 ), ;
   DevOut ('RBckDemo: Demo program for RBckLib v1.0d - '+;
   '18/01/95 (c) 1993-95  Rolf van Gelder' ), ;
   DevPos ( 1, 0 ), ;
   DevOut ( Replicate ( '─', 80 ) ) }


*!*****************************************************************************
*!
*!       Function: RBCKDEMO()
*!
*!*****************************************************************************
FUNCTION RBckDemo

*-- Main menu
LOCAL   aMainMenu := { ;
   'Backup files from current directory to drive A: - R_BackUp()', ;
   'Restore files from drive A: to C:\RBCKTEST      - R_Restore()', ;
   'Get the contents of a backup-set                - R_BckList()', ;
   'End of Demo' }

LOCAL   nChoice := 1                    && Menu choice
LOCAL   nRetCode                        && Return code
LOCAL   nFiles                          && Counter
LOCAL   nHandle                         && File handle
LOCAL	nBarLen				&& Length of the progress bar
LOCAL	nBarRow				&& Row for progress bar
LOCAL	nBarCol				&& Column for progress bar
LOCAL	cOldCol				&& Old color
LOCAL	anBckList			&& Array with backup contents
LOCAL	lEscape := .T.			&& Backup/Restore interruptable
LOCAL	lSilent := .F.			&& Use the beeper ...

*-- Enable blinking colors
SetBlink ( .T. )

*-- Set color to BRIGHT WHITE on BLUE
SetColor ( 'W+/B' )

*-- Disable scoreboard
Set ( _SET_SCOREBOARD, .f. )

*-- Set cursor OFF
SetCursor ( SC_NONE )

*--------------------------------------------------------------------------
*                   M A I N   P R O G R A M   L O O P
*--------------------------------------------------------------------------
DO WHILE .t.
   
   *-- Display header lines
   Eval ( bHeader )
   
   *-- Do some advertisement ...
   DevPos ( 2,15 )
   DevOut ( 'THE COMPRESSED BACKUP LIBRARY FOR CA-CLIPPER' )
   DevPos ( 4, 11 )
   DevOut ( ' ▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄           ▄     ▄  ▄        ▄▄  ▄      ' )
   DevPos ( 5, 11 )
   DevOut ( '▒▒▒▒▒▒▒█ ▒▒▒▒▒▒▒█          ▒█    ▒▀ ▒█       ▒▒▀ ▒█      ' )
   DevPos ( 6, 11 )
   DevOut ( '▒█▄▄▄▄▒█ ▒█▄▄▄▄▒▀  ▄▄▄▄▄▄▄ ▒█▄▄▄▒▀  ▒█        ▄▄ ▒█▄▄▄▄▄▄' )
   DevPos ( 7, 11 )
   DevOut ( '▒▒▒▒▒▒▒▀ ▒▒▒▒▒▒▀▄ ▒▒▒▒▒▒▒▀ ▒▒▒▒▒▀▄  ▒█       ▒▒█ ▒▒▒▒▒▒▒█' )
   DevPos ( 8, 11 )
   DevOut ( '▒█   ▒▀▄ ▒█▄▄▄▄▒█ ▒█▄▄▄▄▄▄ ▒█   ▒▀▄ ▒█▄▄▄▄▄▄ ▒▒█ ▒█▄▄▄▄▒█' )
   DevPos ( 9, 11 )
   DevOut ( '▒▀    ▒▀ ▒▒▒▒▒▒▒▀ ▒▒▒▒▒▒▒▀ ▒▀    ▒▀ ▒▒▒▒▒▒▒▀ ▒▒▀ ▒▒▒▒▒▒▒▀' )
   DevPos ( 10, 11 )
   DevOut ( '                                                         ' )
   DevPos ( 11, 9 )
   DevOut ( '(c) 1993-95  Rolf v Gelder -+- Eindhoven -+- The Netherlands ' )
   
   *-- Draw double box for main menu
   DispBox ( 14, 7, 19, 72, 2 )
   
   *-- Display main menu
   nChoice := AChoice ( 15, 9, 18, 70, aMainMenu, nil, nil, nChoice )
   
   IF LastKey () = 27 .or. nChoice = Len ( aMainMenu )
      *-- <Esc> or 'End of Demo'
      EXIT
   ENDIF
   
   *-- Display header lines
   Eval ( bHeader )
   
   DO CASE
   CASE nChoice = 1
      *--------------------------------------------------------------------
      * MAKE A BACKUP TO DRIVE A:
      *--------------------------------------------------------------------

      *-- Display a warning
      Alert ( '!!! CAUTION !!!;;' + ;
         'ALL FILES in the ROOT directory of;' + ;
         'the BACKUP DISKETTE(S) will be automatically DELETED !' )

      *-- Initialize progress bar variables
      nBarLen := 50
      nBarRow := 7
      nBarCol := 15
      
      *-- Draw a fancy box around the progress bar ...
      DrawBar ( nBarRow, nBarCol, 'Creating a backup on drive A:', lEscape )

      *-- Draw a box for displaying file names
      cOldCol := SetColor ( 'W+/RB' )
      Scroll   ( nBarRow+6, nBarCol-2, nBarRow+13, nBarCol+nBarLen+1 )
      DispBox  ( nBarRow+6, nBarCol-2, nBarRow+13, nBarCol+nBarLen+1 )
      DevPos   ( nBarRow+6, nBarCol+(nBarLen-10)/2 )
      DevOut   ( ' Adding : ' )
      SetColor ( cOldCol )
      nLastCol := NIL
      
      *--------------------------------------------------------------------
      * Syntax :
      * FUNCTION R_Backup ( aSkeleton, aExclude, cDestDrv, cFileName,
      *    aBar, lEscape, lSilent, bRBckBlk, aMsg )
      *--------------------------------------------------------------------
      nRetCode := R_BackUp ( ;
         { '*.TXT', nil, '*.NG', '*.PRG', '*.DOC', '*.REG' }, ;
         { 'DUTCH.REG' }, ;
         'A:', nil, ;
         { nBarLen, nBarRow, nBarCol, Chr (177), 'GR+/R' }, ;
         lEscape, lSilent, ;
         { |fname| ShowName ( fname, nBarRow+4, nBarCol, nBarLen ) }, ;
         { MaxRow () - 1, nil, nil, 'W+*/B' } )

      *--------------------------------------------------------------------
      * You may also use the (more readable) COMMAND FORM syntax
      * (as included in RBckLib.Ch) :
      *
      * RBACKUP FILES { '*.TXT', '*.NG', '*.PRG', '*.DOC', '*.REG' } ;
      *        EXCLUDE { 'DUTCH.REG' } ;
      *        TO A: ;
      *        BAR { nBarLen, nBarRow, nBarCol, Chr(177), 'GR+/R' } ;
      *        ESCAPE ;
      *        BLOCK { |fname| ShowName ( fname, nBarRow+4, nBarCol, nBarLen ) } ;
      *        MESSAGE { MaxRow () - 1, nil, nil, 'W+*/B' } ;
      *        RETCODE nRetCode
      *--------------------------------------------------------------------

      *-- Clear screen
      Scroll ( 2, 0 )
      
      IF nRetCode != BU_OKAY
         *-- Oops, error detected : display error message !

         Alert ( 'BackUp error : ' + aErrTxt [ nRetCode ] )
         
      ELSE
         *-- No errors detected !

         Alert ( 'Backup made !' )
         
      ENDIF


   CASE nChoice = 2
      *--------------------------------------------------------------------
      * RESTORE FROM DRIVE A:
      *--------------------------------------------------------------------
      
      *-- Overwrite confirmation initial to TRUE
      M->lConfirm := .T.
      
      *-- Initialize the progress bar variables
      nBarLen     := 50
      nBarRow     := 7
      nBarCol     := 15
      
      *-- Draw a fancy box around the progress bar ...
      DrawBar ( nBarRow, nBarCol, 'Restoring files from drive A:', lEscape )

      *-- Draw a box for displaying file names
      cOldCol := SetColor ( 'W+/RB' )
      Scroll   ( nBarRow+6, nBarCol-2, nBarRow+13, nBarCol+nBarLen+1 )
      DispBox  ( nBarRow+6, nBarCol-2, nBarRow+13, nBarCol+nBarLen+1 )
      DevPos   ( nBarRow+6, nBarCol+(nBarLen-14)/2 )
      DevOut   ( ' Extracting : ' )
      SetColor ( cOldCol )
      nLastCol := NIL
      
      *---------------------------------------------------------------------
      * Syntax :
      * FUNCTION R_Restore ( cSrcDrv, aMask, cDestSpec, cFileName,
      *    aBar, lEscape, lSilent, bRBckBlk, aMsg, bConfirm )
      *---------------------------------------------------------------------
      nRetCode := R_Restore ( 'A:', { '*.*' }, 'C:\RBCKTEST', nil, ;
         { nBarLen, nBarRow, nBarCol, Chr (177), 'GR+/R' }, ;
         lEscape, lSilent, ;
         { |fname| ShowName ( fname, nBarRow+4, nBarCol, nBarLen ) }, ;
         { MaxRow () - 1 }, ;
         { |fname| Confirm ( fname ) } )

      *--------------------------------------------------------------------
      * You may also use the (more readable) COMMAND FORM syntax
      * (as included in RBckLib.Ch) :
      *
      * RRESTORE FROM A: TO C:\RBCKTEST ;
      *    BAR { nBarLen, nBarRow, nBarCol, Chr(177), 'GR+/R' } ;
      *    ESCAPE ;
      *    BLOCK { |fname| ShowName ( fname, nBarRow+4, nBarCol, nBarLen ) } ;
      *    MESSAGE { MaxRow () - 1, nil, nil, nil } ;
      *    CONFIRM { |fname| Confirm ( fname ) } ;
      *    RETCODE nRetCode
      *--------------------------------------------------------------------

      *-- Clear screen
      Scroll ( 2, 0 )
      
      IF nRetCode != BU_OKAY
         *-- Oops, error detected : display error message !

         Alert ( 'Restore error : ' + aErrTxt [ nRetCode ] )
         
      ELSE
         *-- No errors detected !

         Alert ( 'File(s) restored !' )
         
      ENDIF


   CASE nChoice = 3
      *--------------------------------------------------------------------
      * CONTENTS OF A BACKUP-SET
      *--------------------------------------------------------------------

      DevPos ( MaxRow () - 1, ( MaxCol () - 40 ) / 2 )
      DevOut ( 'Just a moment, examining backup-set ....' )

      *---------------------------------------------------------------------
      * Syntax :
      * FUNCTION R_BckList ( cSrcDrv, cFileName, lEscape, lSilent, aMsg )
      *---------------------------------------------------------------------
      * anBckList := R_BckList ( 'A:', nil, lEscape, lSilent, ;
      *   { MaxRow () - 1 } )

      *--------------------------------------------------------------------
      * You may also use the (more readable) COMMAND FORM syntax
      * (as included in RBckLib.Ch) :
      *
       RBCKLIST FROM A: ;
          MESSAGE { MaxRow () - 1 } ;
          ESCAPE ;
          RETCODE anBckList
      *--------------------------------------------------------------------

      *-- Clear the 'Just a moment' message
      Scroll ( MaxRow () - 1, 0, MaxRow () - 1, MaxCol () )

      IF ValType ( anBckList ) = 'N'
         *-- Error detected : display error message

         Alert ( 'R_BckList error : ' + aErrTxt [ anBckList ] )

      ELSE
         *-- No errors detected : show the results

         cOldCol := SetColor ( 'W+/RB' )
         DevPos ( 3, 5 )
         DevOut ( '    Filespec                       Size ' + ;
            'Date       Time  BackUp-file  ' )

         *-- Set color to BRIGHT WHITE on CYAN
         SetColor ( 'W+/BG' )

         nFiles := 0

         *-- Display contents of the file-info array
         AEval ( anBckList, ;
         { |x| DevPos ( Row()+1, 5 ), ;
               DevOut ( ;
               Str ( ++nFiles, 3 ) + ' ' + ;
               PadR ( x [BU_FNAME], 26) + ' ' + ;
               Str ( x [BU_FSIZE], 8 ) + ' ' + ;
               PadR ( x [BU_FDATE], 10 ) + ' ' + ;
               x [BU_FTIME] + ' ' + ;
               PadR ( x [BU_ANAME], 12 ) + ' ' ) } )

          *-- Wait for a key to be pressed
          SetColor ( cOldCol )
          DevPos   ( MaxRow(), 32 )
          DevOut   ( 'Hit any key ....' )
          InKey    ( 0 )

      ENDIF

   ENDCASE
   
ENDDO

DevPos ( MaxRow () - 1, 0 )

*-- Set cursor to normal
SetCursor ( SC_NORMAL )

RETURN nil


*!*****************************************************************************
*!
*!       Function: DRAWBAR()
*!
*!*****************************************************************************
STATIC FUNCTION DrawBar ( nRow, nCol, cHeader, lEscape )
*==========================================================================
* FUNCTION TO DRAW A FANCY BOX AROUND THE PROGRESS BAR
*==========================================================================

LOCAL	cOldCol := SetColor ( 'W+/BG' )	&& Save & set screen color
LOCAL	i				&& Counter

*-- Decrease row/column
nRow -= 2
nCol -= 2

*-- Clear box area
Scroll  ( nRow, nCol, nRow+4, nCol+53 )

*-- Draw box
DispBox ( nRow, nCol, nRow+4, nCol+53 )

*-- Draw header (centered)
DevPos ( nRow, ( MaxCol() + 1 - Len ( cHeader ) ) / 2 )
DevOut ( ' ' + cHeader + ' ' )

*-- Draw footer
IF lEscape
   DevPos ( nRow+4, 31 )
   DevOut ( ' Hit ESC to abort ' )
ENDIF

*-- Draw ruler lines
DevPos ( nRow+1, nCol+2 )
*-- Draw percentages
DevOut ( '0  10   20   30   40   50   60   70   80   90  100' )
DevPos ( nRow+3, nCol+2 )
*-- Draw marks
DevOut ( Chr ( 16 ) )
FOR i := 1 TO 9
   DevPos ( nRow+3, nCol+1+5*i )
   DevOut ( Chr ( 30 ) )
NEXT
DevPos ( nRow+3, nCol+51 )
DevOut ( Chr ( 17 ) )

*-- Restore old color
SetColor ( cOldCol )

RETURN nil


*!*****************************************************************************
*!
*!       Function: SHOWNAME()
*!
*!*****************************************************************************
STATIC FUNCTION ShowName ( cFName, nRow, nCol, nBarLen )
*==========================================================================
* FUNCTION TO DISPLAY THE CURRENT FILE NAME
*==========================================================================

LOCAL	cOldCol := SetColor ( 'W+/RB' )	&& Save & set screen color

*-- Clear line
IF nLastCol != NIL

   *-- Not the first file
   DevPos ( nRow+8, nLastCol+1 )
   DevOut ( '[ok]' )

ENDIF

nLastCol := nCol + Len ( cFName )

Scroll ( nRow+3, nCol, nRow+8, nCol+nBarLen, 1 )

DevPos ( nRow+8, nCol )
DevOut ( cFName + ' ...' )

SetColor ( cOldCol )

RETURN BU_CONT                          && Continue backup/restore function


*!*****************************************************************************
*!
*!       Function: CONFIRM()
*!
*!*****************************************************************************
STATIC FUNCTION Confirm ( cFileSpec )
*==========================================================================
* CONFIRMATION FOR OVERWRITING AN EXISTING FILE (WHILE RESTORING)
*==========================================================================

LOCAL	nChoice			&& Choice made from ALERT

IF M->lConfirm
   *-- Confirmation is ON
   
   nChoice := Alert ( 'File ' + cFileSpec + ' exists !', ;
      { 'Skip file', 'Replace file', 'Overwrite ALL', 'Abort' } )
   
   DO CASE
   CASE nChoice = 1
      *-- Skip this file
      RETURN BU_SKIPFILE
      
   CASE nChoice = 2
      *-- Replace this file
      RETURN BU_OVERWRITE
      
   CASE nChoice = 3
      *-- Overwrite ALL files that exist : set confirmation OFF !
      M->lConfirm := .F.
      RETURN BU_OVERWRITE
      
   CASE nChoice = 4
      *-- Abort restore
      RETURN BU_ABORT
   ENDCASE
   
ENDIF

RETURN BU_OVERWRITE			&& Confirmation = OFF
*
* EOF RBckDemo.PRG ========================================================
