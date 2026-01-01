*--------------------------------------------------------------------------
*                         CA-CLIPPER 5.xx VERSION
*--------------------------------------------------------------------------
* RCmpDemo.PRG - Program to demonstrate the use of the functions
*                in the CA-Clipper Library, RCmpLib v3.1
*
* Used functions :
*
*       R_CmpFile ()  - Compress one or more files into one archive
*       R_DCmpFile () - Extract  one or more files from an archive
*       R_CmpList ()  - Retrieves info about files in a RCmpLib archive
*       R_FSize ()    - Determine the size of a file
*       R_LastErr ()  - Determine last error
*       R_CmpStr ()   - Compress a string
*       R_DCmpStr ()  - Decompress a string
*
* Compile    :  CLIPPER RCMPDEMO /N
*
* Link       :  RTLINK   file RCMPDEMO lib RCMP_C50      - or -
*               BLINKER  file RCMPDEMO lib RCMP_C50      - or -
*               EXOSPACE file RCMPDEMO lib RCMP_C50 EXO PAC INT10
*		(RCMP_C52 for Clipper 5.2x)
*
* Syntax     :  RCMPDEMO
*--------------------------------------------------------------------------
* Date       :  24/01/95
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
* (c) 1995 Rolf van Gelder, All rights reserved
*--------------------------------------------------------------------------

*--------------------------------------------------------------------------
* Standard Clipper HEADER files
*--------------------------------------------------------------------------
#include "Directry.CH"
#include "Set.CH"
#include "FileIO.CH"

*--------------------------------------------------------------------------
* RCMPLIB header file
*--------------------------------------------------------------------------
#include "RCmpLib.CH"

*-- Initialize the array with error messages (from RCmpLib.CH)
STATIC  aErrTxt := CP_ERRMSG


*--------------------------------------------------------------------------
* STATIC CODEBLOCKS
*--------------------------------------------------------------------------

*-- Display "Hit any key" message & wait for a key
STATIC  bHitKey := { || DevPos (MaxRow(), 32), DevOut ( 'Hit any key ....' ),;
                        InKey ( 0 ) }

*-- Display headerline (with clear screen)
STATIC  bHeader := { || Scroll (), DevPos ( 0, 0 ), ;
                        DevOut ('RCmpDemo: Demo program for RCmpLib v3.1 - '+;
                                '24/01/95     (c) 1995  Rolf van Gelder' ), ;
                        DevPos ( 1, 0 ), ;
                        DevOut ( Replicate ( '─', 80 ) ) }

*--------------------------------------------------------------------------
*
*                          Main function : RCmpDemo
*
*--------------------------------------------------------------------------
FUNCTION RCmpDemo

*-- Main menu
LOCAL   aMenu := { ;
   'Compress files into an archive      - R_CmpFile()' , ;
   'Show file-info from an archive file - R_CmpList()', ;
   'Extract files from an archive       - R_DCmpFile()', ;
   'String compression/decompression    - R_CmpStr(),R_DCmpStr()', ;
   'End of Demo' }

LOCAL   nChoice := 1                    && Menu choice
LOCAL   nRetCode                        && Return code
LOCAL   cOldCol                         && Old color
LOCAL   aCmpList                        && Array with file-info
LOCAL   nTotOrgSize                     && Counter
LOCAL   nTotCmpSize                     && Counter
LOCAL   nFiles                          && Counter
LOCAL   nHandle                         && File handle
LOCAL   cString                         && String buffer
LOCAL   nOrgSize                        && Original string size
LOCAL   nCmpSize                        && Compressed string size

SetColor ( 'W+/B' )

*-- Disable scoreboard
Set ( _SET_SCOREBOARD, .f. )

*--------------------------------------------------------------------------
*                   M A I N   P R O G R A M   L O O P
*--------------------------------------------------------------------------
DO WHILE .t.

   *-- Display header lines
   Eval ( bHeader )

   *-- Do some advertisement ...
   DevPos ( 2,21 )
   DevOut ( 'THE COMPRESSION LIBRARY FOR CA-CLIPPER' )
   DevPos ( 4, 11 )
   DevOut ( ' ▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄                    ▄        ▄▄  ▄      ' )
   DevPos ( 5, 11 )
   DevOut ( '▒▒▒▒▒▒▒█ ▒▒▒▒▒▒▒▀                   ▒█       ▒▒▀ ▒█      ' )
   DevPos ( 6, 11 )
   DevOut ( '▒█▄▄▄▄▒█ ▒█        ▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄ ▒█        ▄▄ ▒█▄▄▄▄▄▄' )
   DevPos ( 7, 11 )
   DevOut ( '▒▒▒▒▒▒▒▀ ▒█       ▒▒▒▒▒▒▒█ ▒▒▒▒▒▒▒█ ▒█       ▒▒█ ▒▒▒▒▒▒▒█' )
   DevPos ( 8, 11 )
   DevOut ( '▒█   ▒▀▄ ▒█▄▄▄▄▄▄ ▒▒█▒█▒▒█ ▒█▄▄▄▄▒█ ▒█▄▄▄▄▄▄ ▒▒█ ▒█▄▄▄▄▒█' )
   DevPos ( 9, 11 )
   DevOut ( '▒▀    ▒▀ ▒▒▒▒▒▒▒▀ ▒▒▀▒▀▒▒▀ ▒▒▒▒▒▒▒▀ ▒▒▒▒▒▒▒▀ ▒▒▀ ▒▒▒▒▒▒▒▀' )
   DevPos ( 10, 11 )
   DevOut ( '                           ▒█                            ' )
   DevPos ( 11, 11 )
   DevOut ( ' (c) 1995 Rolf van Gelder  ▒▀ Eindhoven, The Netherlands ' )

   *-- Draw double box for main menu
   DispBox ( 13, 8, 19, 71, 2 )

   *-- Display main menu
   nChoice := AChoice ( 14, 10, 18, 69, aMenu, , , nChoice )

   IF LastKey () = 27 .or. nChoice = Len ( aMenu )
      *-- <Esc> or 'End of Demo'
      EXIT
   ENDIF

   *-- Display header lines
   Eval ( bHeader )

   DO CASE
   CASE nChoice = 1
      *-- COMPRESS FILES INTO AN ARCHIVE

      CenterMsg ( 3, 'COMPRESS FILES INTO AN ARCHIVE - R_CmpFile()' )

      cOldCol := SetColor ( 'W+/BG' )
      DispBox ( 5, 13, 8, 64 )
      DevPos ( 6, 14 )
      DevOut ( ' The files RCMPLIB.*, *.PRG and DUTCH.REG will be ' )
      DevPos ( 7, 14 )
      DevOut ( ' compressed into an archive called ARCHIVE.RCP.   ' )
      SetColor ( cOldCol )

      *-- Hit any key ....
      Eval ( bHitKey )

      Scroll ( 5, 0 )

      *-- Draw box for progression bar
      cOldCol := SetColor ( 'W+/R' )
      Scroll ( 6, 23, 8, 56 )
      DispBox ( 6, 23, 8, 56 )
      SetColor ( cOldCol )
      DevPos ( 9,25 )
      DevOut ( 'Compressing: ' )

      *--------------------------------------------------------------------
      * Files to compress : RCmpLib.*, *.PRG and Dutch.REG
      * Archive file      : Archive.RCP
      * Keep originals    : lMove = .F.
      * Progression bar   : Length = 30,           (Row,Col) = (7,25)
      *                   : Character = Chr (177), Color = Yellow on Red
      * Password          : none (nil)
      * Interruptable     : lEscape = .T.
      * CodeBlock         : Function DispName ( Fname, row, col )
      *--------------------------------------------------------------------
      nRetCode := R_CmpFile ( { 'RCmpLib.*', '*.PRG', 'Dutch.REG' }, ;
         'Archive.RCP', .F., 30, 7, 25, Chr ( 177 ), 'GR+/R', nil, .T., ;
         { |x| DispName ( x, 9, 38 ) } )

      *-- Clear box
      Scroll ( 6, 0 )

      IF nRetCode != CP_OKAY
         *-- Error detected : display error message
         Alert ( 'Error compressing: ' + ;
         IF ( nRetCode <= Len ( aErrTxt ), aErrTxt [ nRetCode ], ;
              Str ( nRetCode ) ) )
      ELSE
         *-- No errors detected !
         Alert ( 'Archive ARCHIVE.RCP created.' )

      ENDIF

   CASE nChoice = 2
      *-- SHOW FILE-INFO FROM AN ARCHIVE FILE

      CenterMsg ( 3, 'SHOW FILE-INFO FROM AN ARCHIVE FILE - R_CmpList()' )

      cOldCol := SetColor ( 'W+/BG' )
      DispBox ( 5, 17, 8, 60 )
      DevPos ( 6, 18 )
      DevOut ( ' File information for the files in the    ' )
      DevPos ( 7, 18 )
      DevOut ( ' archive file ARCHIVE.RCP will be listed. ' )
      SetColor ( cOldCol )

      *-- Hit any key ....
      Eval ( bHitKey )

      Scroll ( 5, 0 )
      DevPos ( 5, 0 )

      *-- Load file-info into the array aCmpList
      aCmpList  := R_CmpList ( 'Archive.RCP' )

      IF R_LastErr() != CP_OKAY
         IF aCmpList = NIL
            Alert ( 'Error R_CmpList: ' + aErrTxt [ R_LastErr() ] )
         ELSE
            *-- Corrupted file detected in archive
            *--    Some files are okay ...
            Alert ( 'Corrupted file(s) detected in archive !;;' + ;
                    'The following file(s) are correct ...' )
         ENDIF
      ENDIF

      IF aCmpList != NIL
         *-- File-Info loaded : display info and cumulate filesizes

         nTotOrgSize := 0               && Total counters
         nTotCmpSize := 0
         nFiles      := 0

         CenterMsg ( 5, 'Filename      Org.Size Filedate   Time  ' + ;
            'Cmp.Size    Ratio   Version       ', 'W+/BG' )

         *-- Display contents of the file-info array
         AEval ( aCmpList, ;
         { |x| QOut  ( Str ( ++nFiles, 2 ) + ;
           ' ' + x [CP_FNAME]   + ' ' + Str ( x [CP_ORGSIZE], 8 ) + ;
           ' ' + PadR ( x [CP_ORGDATE], 10 ) + ' ' + x [CP_ORGTIME] + ;
           ' ' + Str ( x [CP_CMPSIZE], 8 ) + ;
           ' ' + Str ( x [CP_RATIO], 8, 2 ) + '% ' + ;
           ' ' + x [CP_VERSION] ), ;
           nTotOrgSize += x [CP_ORGSIZE], ;
           nTotCmpSize += x [CP_CMPSIZE] } )

         *-- Display totals
         CenterMsg ( Row()+1, 'Totals       ' + Str ( nTotOrgSize, 9 ) + ;
            Space ( 17 ) + Str ( nTotCmpSize, 9 ) + ;
            Space ( 3 ) + ;
            Str ( 100 * (nTotOrgSize-nTotCmpSize) / nTotOrgSize, 6, 2 ) + ;
            '%' + Space ( 15 ), 'W+/BG' )

         *-- Hit any key ....
         Eval ( bHitKey )

      ENDIF


   CASE nChoice = 3
      *-- EXTRACT FILES FROM AN ARCHIVE

      CenterMsg ( 3, 'EXTRACT FILES FROM AN ARCHIVE - R_DCmpFile()' )

      cOldCol := SetColor ( 'W+/BG' )
      DispBox ( 5, 11, 8, 66 )
      DevPos ( 6, 12 )
      DevOut ( ' The files *.CH and *.PRG will be extracted from      ' )
      DevPos ( 7, 12 )
      DevOut ( ' the archive file ARCHIVE.RCP to the ROOT directory.  ' )
      SetColor ( cOldCol )

      *-- Hit any key ....
      Eval ( bHitKey )

      Scroll ( 5, 0 )

      *-- Draw box for progression bar
      cOldCol := SetColor ( 'W+/BG' )
      Scroll ( 6, 23, 8, 56 )
      DispBox ( 6, 23, 8, 56 )
      SetColor ( cOldCol )
      DevPos ( 9,25 )
      DevOut ( 'Extracting: ' )

      *--------------------------------------------------------------------
      * Archive file      : Archive.RCP
      * Files to extract  : *.CH and *.PRG
      * Destination dir   : \
      * Progression bar   : Length    = 30, (Row,Col) = (7,25)
      *                   : Character = Chr (177), Color = Yellow on Red
      * Password          : none (nil)
      * Interruptable     : lEscape = .T.
      * CodeBlock         : Function DispName ( Fname, row, col )
      *--------------------------------------------------------------------
      nRetCode := R_DCmpFile ( 'Archive.RCP', { '*.CH', '*.PRG' }, '\', ;
         30, 7, 25, Chr ( 177 ), 'GR+/R', nil, .T., ;
         { |x| DispName ( x, 9, 38 ) } )

      *-- Clear box
      Scroll ( 6, 0 )

      IF nRetCode != CP_OKAY
         *-- Error detected : display error message
         Alert ( 'Error extracting: ' + aErrTxt [ nRetCode ] )

      ELSE
         *-- No errors detected !
         Alert ( 'Files extracted from ARCHIVE.RCP;' + ;
                 'to the ROOT directory !         ' )

      ENDIF


   CASE nChoice = 4
      *-- STRING COMPRESSION / DECOMPRESSION

      CenterMsg ( 3, 'STRING COMPRESSION/DECOMPRESSION - ' + ;
         'RCmpStr(),R_DCmpStr()' )

      cOldCol := SetColor ( 'W+/BG' )
      DispBox ( 5, 13, 8, 64 )
      DevPos ( 6, 14 )
      DevOut ( ' The file RCMPLIB.DOC will be read into a string, ' )
      DevPos ( 7, 14 )
      DevOut ( ' the string will be compressed and decompressed.  ' )
      SetColor ( cOldCol )

      *-- Hit any key ....
      Eval ( bHitKey )

      Scroll ( 5, 0 )

      IF File ( 'RCmpLib.DOC' )
         *-- Get the file size of RCmpLib.DOC
         nOrgSize := R_FSize ( 'RCmpLib.DOC' )

         *-- Allocate buffer space
         cString := Space ( nOrgSize )

         *-- Open file
         nHandle := FOpen ( 'RCmpLib.DOC', FO_READ + FO_SHARED )

         *-- Read file into a string
         FRead ( nHandle, @cString, nOrgSize )

         *-- Close file
         FClose ( nHandle )

         Alert ( 'File RCmpLib.DOC is read into a string.;;' + ;
                 'String length = ' + Str ( nOrgSize, 5 ) + ;
                 ' bytes.           ' )

         *-- Show the string as read from the file (using MEMOEDIT)
         DispStr ( cString, ;
            'Original string─' + LTrim ( Str ( nOrgSize ) ) + ' bytes' )

         Alert ( 'The string containing RCmpLib.DOC will be compressed,;' + ;
                 'using the R_CmpStr() function ...                    ' )

         *-- COMPRESS THE STRING !
         cString  := R_CmpStr ( cString )

         *-- Size of the compressed string
         nCmpSize := Len ( cString )

         Alert ( 'The string is compressed !;;' + ;
            'Length of ORIGINAL   string ' + Str ( nOrgSize, 7 ) + ';' + ;
            'Length of COMPRESSED string ' + Str ( nCmpSize, 7 ) + ';;' + ;
            'Compression ratio ' + ;
            Str ( 100 * (nOrgSize-nCmpSize)/nOrgSize, 6, 2 ) + '%' )

         Alert ( 'Now take a look at the COMPRESSED string ...' )

         *-- Show the compressed string using MEMOEDIT()
         DispStr ( cString, ;
            'Compressed string─' + LTrim ( Str ( nCmpSize ) ) + ' bytes' )

         Alert ( 'The compressed string will now be decompressed;' + ;
                 'using the R_DCmpStr() function ...            ' )

         *-- DECOMPRESS THE STRING !
         cString := R_DCmpStr ( cString )

         Alert ( 'Decompression done !           ;;' + ;
                 'Look at the ORIGINAL string ...' )

         *-- Show the decompressed string using MEMOEDIT
         DispStr ( cString, ;
            'Original string─' + LTrim ( Str ( nOrgSize ) ) + ' bytes' )

      ELSE

         Alert ( 'File not found : RCmpLib.DOC' )

      ENDIF

   ENDCASE

ENDDO

DevPos ( 23, 0 )

RETURN nil


*==========================================================================
* FUNCTION TO DISPLAY A FILE NAME
*==========================================================================
STATIC FUNCTION DispName ( cFName, nRow, nCol )

DevPos ( nRow, nCol )
DevOut ( PadR ( cFName, 12 ) )

RETURN CP_CONT                          && Continue (de-)compression

*==========================================================================
* FUNCTION TO CENTER A MESSAGE
*==========================================================================
STATIC FUNCTION CenterMsg ( nRow, cTxt, cColor )

LOCAL   cOldCol

IF cColor != NIL
   *-- Colorstring passed
   cOldCol := SetColor ( cColor )
ELSE
   *-- Default colorstring
   cOldCol := SetColor ( 'W+/RB' )
ENDIF

Scroll ( nRow, 0, nRow, MaxCol () )
DevPos ( nRow, ( MaxCol() + 1 - Len ( cTxt ) ) / 2 )
DevOut ( cTxt )

SetColor ( cOldCol )

RETURN nil


*==========================================================================
* FUNCTION TO DISPLAY A STRING USING THE MEMO-EDITOR, MEMOEDIT()
*==========================================================================
STATIC FUNCTION DispStr ( cString, cTitle )

LOCAL   cOldCol := SetColor ( 'W+/BG' )

Scroll  ( 2, 0, 22, 79 )
DispBox ( 2, 0, 22, 79 )
DevPos ( 2, 2 )
DevOut ( cTitle )
DevPos ( 22, 2 )
DevOut ( 'Press <Esc> to Exit' )

MemoEdit ( cString, 3, 1, 21, 78, .F. )

SetColor ( cOldCol )

Scroll ( 2, 0 )

RETURN nil
*
* EOF RCmpDemo.PRG ========================================================
