*--------------------------------------------------------------------------
*                         CLIPPER SUMMER '87 VERSION
*--------------------------------------------------------------------------
* RBckDemS.PRG - Program to demonstrate the use of the functions
*                in the CA-Clipper Library, RBckLib v1.0d
*
* Used functions :
*
*       R_BackUp ()   - Make a backup to floppy disk
*       R_Restore ()  - Restores a backup from floppy disk
*       R_BckList ()  - Gets the contents of a backup-set
*
* Compile    :  CLIPPER RBCKDEMS /N
*
* Link       :  PLINK86  file RBCKDEMS lib RBck_S87   - or -
*		TLINK RBCKDEMS,,NUL,RBck_S87          - or -
*               BLINKER  file RBCKDEMS lib RBck_S87
*
* Syntax     :  RBCKDEMS
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
*
*                          Main function : RBckDemS
*
*--------------------------------------------------------------------------

*-- Error text
PUBLIC	aErrTxt [ 10 ]
aErrTxt [ 1 ] = 'Invalid parameter(s) passed'
aErrTxt [ 2 ] = 'Error OPENING input file'
aErrTxt [ 3 ] = 'Wrong version of RBckLib'
aErrTxt [ 4 ] = 'Error CREATING output file'
aErrTxt [ 5 ] = 'Error READING input file'
aErrTxt [ 6 ] = 'Error WRITING output file'
aErrTxt [ 7 ] = 'No files found to backup'
aErrTxt [ 8 ] = 'Function aborted by user'
aErrTxt [ 9 ] = 'Invalid backup drive/disk'
aErrTxt [10 ] = 'Invalid restore directory'

*-- Main menu
PRIVATE	nChoice				&& Menu choice
PRIVATE	nRetCode			&& Return code
PRIVATE	nFiles				&& Number of files
PRIVATE	nFile				&& Counter
PRIVATE	nHandle				&& File handle
PRIVATE	nBarRow				&& Row for progress bar
PRIVATE	nBarCol				&& Column for progress bar
PRIVATE	nBarLen				&& Length of the progress bar
PRIVATE	cOldCol				&& Color save
PRIVATE	cMode				&& 'B'=BACKUP, 'R'=RESTORE

nChoice = 1

DECLARE	aMenu [ 4 ]			&& Main menu

aMenu [ 1 ] = 'Backup files from current directory to drive A: - R_BackUp()'
aMenu [ 2 ] = 'Restore files from drive A: to C:\RBCKTEST      - R_Restore()'
aMenu [ 3 ] = 'Get the contents of a backup-set                - R_BckList()'
aMenu [ 4 ] = 'End of Demo'

SetColor ( 'W+/B' )

*-- Disable scoreboard
SET SCOREBOARD OFF

SET CURSOR OFF

*--------------------------------------------------------------------------
*                   M A I N   P R O G R A M   L O O P
*--------------------------------------------------------------------------
DO WHILE .T.
   
   *-- Display header lines
   Header ()
   
   *-- Do some advertisement ...
   @ 2,21 SAY 'THE BACKUP LIBRARY FOR CA-CLIPPER'
   @ 4,11 SAY ' ▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄           ▄     ▄  ▄        ▄▄  ▄      '
   @ 5,11 SAY '▒▒▒▒▒▒▒█ ▒▒▒▒▒▒▒█          ▒█    ▒▀ ▒█       ▒▒▀ ▒█      '
   @ 6,11 SAY '▒█▄▄▄▄▒█ ▒█▄▄▄▄▒▀  ▄▄▄▄▄▄▄ ▒█▄▄▄▒▀  ▒█        ▄▄ ▒█▄▄▄▄▄▄'
   @ 7,11 SAY '▒▒▒▒▒▒▒▀ ▒▒▒▒▒▒▀▄ ▒▒▒▒▒▒▒▀ ▒▒▒▒▒▀▄  ▒█       ▒▒█ ▒▒▒▒▒▒▒█'
   @ 8,11 SAY '▒█   ▒▀▄ ▒█▄▄▄▄▒█ ▒█▄▄▄▄▄▄ ▒█   ▒▀▄ ▒█▄▄▄▄▄▄ ▒▒█ ▒█▄▄▄▄▒█'
   @ 9,11 SAY '▒▀    ▒▀ ▒▒▒▒▒▒▒▀ ▒▒▒▒▒▒▒▀ ▒▀    ▒▀ ▒▒▒▒▒▒▒▀ ▒▒▀ ▒▒▒▒▒▒▒▀'
   @10,11 SAY '                                                         '
   @11, 9 SAY '(c) 1993-95  Rolf v Gelder -+- Eindhoven -+- The Netherlands '
   
   *-- Draw double box for main menu
   @14,7 TO 19,72 DOUBLE
   
   *-- Display main menu
   nChoice = AChoice ( 15, 9, 18, 70, aMenu, '', '', nChoice )
   
   IF LastKey () = 27 .or. nChoice = Len ( aMenu )
      *-- <Esc> or 'End of Demo'
      EXIT
   ENDIF
   
   *-- Display header lines
   Header ()
   
   DO CASE
   CASE nChoice = 1
      *-- MAKE A BACKUP TO DRIVE A:
      cOldCol = SetColor ( 'W+/BG' )
      
      @09,16 SAY '                                                '
      @10,16 SAY '               !!! CAUTION !!!                  '
      @11,16 SAY '                                                '
      @12,16 SAY ' ALL FILES on the ROOT directory  of the BACKUP '
      @13,16 SAY '     DISK(S) will be automatically DELETED !    '
      @14,16 SAY '                                                '
      
      Inkey ( 10 )
      
      SetColor ( cOldCol )
      
      @2,0 CLEAR
      
      nBarRow = 7
      nBarCol = 15
      nBarLen = 50
      cMode   = 'B'
      
      *-- Draw a fancy box around the progress bar ...
      DrawBar ( nBarRow, nBarCol, 'Creating a backup on drive A:' )
      
      *---------------------------------------------------------------------
      * Syntax :
      * FUNCTION R_Backup ( acSkeleton, cDestDrv, cFileName
      *    nBarLen, nBarRow, nBarCol, cBarChr, cBarColor,
      *    lEscape, lSilent, bRBckBlk, nMsgRow, nMsgCol,
      *    cInsMsg, cMsgColor )
      *---------------------------------------------------------------------
      nRetCode = R_BackUp ( '*.TXT;*.NG;*.PRG;*.DOC', ;
         'A:', '', ;
         nBarLen, nBarRow, nBarCol, Chr (177), 'GR+/R', ;
         .T., .F., 'ShowName', ;
         23, -1, '', 'W+*/B' )
      
      @2,0 CLEAR
      
      IF nRetCode != 0			&& BU_OKAY
         *-- Error detected : display error message
         Message ( 'Error detected : ' + aErrTxt [ nRetCode ], .T. )
         
      ELSE
         *-- No errors detected !
         Message ( 'BackUp made !', .T. )
         
      ENDIF
      
   CASE nChoice = 2
      *-- RESTORE FROM DRIVE A:
      
      nBarRow = 7
      nBarCol = 15
      nBarLen = 50
      cMode   = 'R'
      
      *-- Draw a fancy box around the progress bar ...
      DrawBar ( nBarRow, nBarCol, 'Restoring files from drive A:' )
      
      *---------------------------------------------------------------------
      * Syntax :
      * FUNCTION R_Restore ( cSrcDrv, cMask, cDestSpec, cFileName,
      *    nBarLen, nBarRow, nBarCol, cBarChr, cBarColor,
      *    lEscape, lSilent, cRBckFnc,
      *    nMsgRow, nMsgCol, cInsMsg, cMsgColor, cConfirm )
      *---------------------------------------------------------------------
      nRetCode = R_Restore ( 'A:', '*.*', 'C:\RBCKTEST', '', ;
         nBarLen, nBarRow, nBarCol, Chr (177), 'GR+/R', ;
         .T., .F., 'ShowName', ;
         23, -1, '', '', 'Confirm' )
      
      @2,0 CLEAR
      
      IF nRetCode != 0			&& BU_OKAY
         *-- Error detected : display error message
         Message ( 'Error detected : ' + aErrTxt [ nRetCode ], .T. )
         
      ELSE
         *-- No errors detected !
         Message ( 'File(s) restored !', .T. )
         
      ENDIF

   CASE nChoice = 3
      *-- CONTENTS OF A BACKUP-SET -----------------------------------------
      @23,20 SAY 'Just a moment, examining backup-set ....'

      nFiles = R_BckList ( 'A:', '', .T., .F., 23, -1, '', '' )

      IF nFiles < 0
         *-- Error detected : Display error message
         @2,0 Clear
         Message ( 'Error detected : ' + aErrTxt [ -(nFiles) ], .T. )

      ELSE
         *-- No error : nRetCode contains number of files in backup-set

         *-- Declare arrays to hold file info
         DECLARE acFileSpec [ nFiles ]
         DECLARE anFSize    [ nFiles ]
         DECLARE acFDate    [ nFiles ]
         DECLARE acFTime    [ nFiles ]
         DECLARE acFileName [ nFiles ]

         nRetCode = R_BckList ( 'A:', '', .T., .F., 23, -1, '', '', .F., ;
            acFileSpec, anFSize, acFDate, acFTime, acFileName )

         @2,0 Clear

         IF nRetCode < 0
            *-- Error detected : Display error message
            Message ( 'Error detected : ' + aErrTxt [ -(nRetCode) ], .T. )

         ELSE
            cOldCol = SetColor ( 'W+/RB' )

            @3,5 SAY '    Filespec                       Size ' + ;
               'Date       Time  BackUp-File  '

            SetColor ( 'W+/BG' )

            For nFile = 1 to nFiles

               @ nFile + 3, 5 SAY Str ( nFile, 3 ) + ' ' + ;
                  PadR ( acFileSpec [ nFile ], 26 ) + ' ' + ;
                  Str ( anFSize [ nFile ], 8 ) + ' ' + ;
                  acFDate [ nFile ] + ' ' + ;
                  acFTime [ nFile ] + ' ' + ;
                  PadR ( acFileName [ nFile ], 12 ) + ' '

            Next

            *-- Wait for a key to be pressed
            SetColor ( cOldCol )

            @ 24, 32 SAY 'Hit any key ....'

            InKey ( 0 )

         ENDIF

      ENDIF

   ENDCASE
   
ENDDO

@23,0 SAY ''

SET CURSOR ON

QUIT


*!*****************************************************************************
*!
*!       Function: DRAWBAR()
*!
*!*****************************************************************************
FUNCTION DrawBar
*==========================================================================
* FUNCTION TO DRAW A FANCY BOX AROUND THE PROGRES BAR
*==========================================================================

PARAMETERS nRow, nCol, cHeader

PRIVATE	cOldCol
PRIVATE	i

cOldCol = SetColor ( 'W+/BG' )
nRow = nRow - 2
nCol = nCol - 2

*-- Clear box area
@nRow, nCol CLEAR TO  nRow+4, nCol+53
*-- Draw box
@nRow, nCol TO nRow+4, nCol+53

*-- Draw header (centered)
@ nRow, ( 80 - Len ( cHeader ) ) / 2 SAY ' ' + cHeader + ' '

*-- Draw footer
@ nRow+4, 31 SAY ' Hit ESC to abort '

*-- Draw ruler lines
@ nRow+1, nCol+2 SAY '0  10   20   30   40   50   60   70   80   90  100'
@ nRow+3, nCol+2 SAY Chr ( 16 )
FOR i = 1 TO 9
   @ nRow+3, nCol+1+5*i SAY Chr ( 30 )
NEXT
@ nRow+3, nCol+51 SAY Chr ( 17 )

SetColor ( cOldCol )

RETURN .F.


*!*****************************************************************************
*!
*!       Function: SHOWNAME()
*!
*!*****************************************************************************
FUNCTION ShowName
PARAMETER cFName
*==========================================================================
* FUNCTION TO DISPLAY A FILE NAME
*==========================================================================

PRIVATE	cMsg

cMsg = IF ( cMode = 'B', 'Adding: ', 'Extracting: ' ) + cFName
*-- Clear message line
@11,0 CLEAR TO 11,79
*-- Display message
@11, ( 80 - Len ( cMsg ) ) / 2 SAY cMsg

RETURN 1				&& BU_CONT


*!*****************************************************************************
*!
*!       Function: CONFIRM()
*!
*!*****************************************************************************
FUNCTION Confirm
PARAMETER cFName
*==========================================================================
* OVERWRITE CONFIRMATION
*==========================================================================

PRIVATE	cWindow				&& Screen buffer
PRIVATE	cOverwrite			&& Overwrite Y/N
PRIVATE	cMsg				&& Message
PRIVATE	nCol				&& Column for input

cWindow    = SaveScreen ( 10, 0, 12, 79 )
cOverwrite = 'N'
cMsg       = 'File ' + cFName + ' exists !  Overwrite ? (Y/N) X'
nCol       = Len (cMsg) + ( (80-Len ( cMsg ) ) / 2 ) - 1
Message ( cMsg, .F. )

SET CURSOR ON
*-- Get value at the 'X' position ...
@11,nCol GET cOverwrite PICTURE '!' VALID ( cOverwrite $ 'YN' )
READ
SET CURSOR OFF

RestScreen ( 10, 0, 12, 79, cWindow )

IF cOverwrite = 'Y'
   RETURN 3				&& BU_OVERWRITE
ENDIF

RETURN 2				&& BU_SKIPFILE


*!*****************************************************************************
*!
*!       Function: HEADER()
*!
*!*****************************************************************************
FUNCTION Header
*==========================================================================
* DISPLAY HEADER LINES
*==========================================================================

Clear

@0,0 SAY 'RBckDemS: Demo program for RBckLib v1.0d - ' + ;
   '18/01/95 (c) 1993-95  Rolf van Gelder'
@1,0 SAY Replicate ( '─', 80 )

RETURN .F.


*!*****************************************************************************
*!
*!       Function: MESSAGE()
*!
*!*****************************************************************************
FUNCTION Message
PARAMETER cMsg, lKey
*==========================================================================
* DISPLAY A MESSAGE AND WAIT FOR A KEY (IF lKey = .T.)
*==========================================================================

PRIVATE	nCol
PRIVATE	cOldCol

*-- Set color
cOldCol = SetColor ( 'W+/RB' )

*-- Center message
nCol    = ( ( 80 - Len ( cMsg ) ) / 2 ) - 1

@10, nCol SAY Space ( Len ( cMsg ) + 2 )
@11, nCol SAY ' ' + cMsg + ' '
@12, nCol SAY Space ( Len ( cMsg ) + 2 )

IF lKey
   *-- Wait for a key
   @23, 25 SAY ' Hit any key to continue .... '
   InKey ( 0 )
ENDIF

*-- Restore color
SetColor ( cOldCol )

RETURN .F.


*-- Pad a string with blanks to the length of nLen characters
FUNCTION PadR
PARAMETERS cStr, nLen

RETURN cStr + Space ( nLen - Len ( cStr ) )
*
* EOF RBckDemS.PRG