*--------------------------------------------------------------------------
*                         CLIPPER SUMMER '87 VERSION
*--------------------------------------------------------------------------
* RCmpDemS.PRG - Program to demonstrate the use of the functions
*                in the Clipper Library, RCmpLib v3.1
*
* Used functions :
*
*      R_CmpFile ()  - Compress one or more files into one archive
*      R_DCmpFile () - Extract  one or more files from an archive
*      R_CmpList ()  - Retrieves info about files in a RCmpLib archive
*      R_FSize ()    - Determine the size of a file
*      R_CmpStr ()   - Compress a string
*      R_DCmpStr ()  - Decompress a string
*
* Compile    :  CLIPPER RCMPDEMS
*
* Link       :  PLINK86  file RCMPDEMS lib RCMP_S87  - or -
*               BLINKER  file RCMPDEMS lib RCMP_S87
*
* Syntax     :  RCMPDEMS
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
* (c) 1995  Rolf van Gelder, All rights reserved
*--------------------------------------------------------------------------

PRIVATE aMenu [5]                       && Main menu

*-- Initialize menu-array
aMenu [1] = 'Compress files into an archive      - R_CmpFile()'
aMenu [2] = 'Show file-info from an archive file - R_CmpList()'
aMenu [3] = 'Extract files from an archive       - R_DCmpFile()'
aMenu [4] = 'String compression/decompression    - R_CmpStr(),R_DCmpStr()'
aMenu [5] = 'End of Demo'

PRIVATE nChoice                         && Menu choice
nChoice = 1

PRIVATE nRetCode                        && Return code
PRIVATE cOldCol                         && Old color
PRIVATE aCmpList                        && Array with file-info
PRIVATE nTotOrgSize                     && Counter
PRIVATE nTotCmpSize                     && Counter
PRIVATE nFile                           && Counter
PRIVATE nFiles                          && Counter
PRIVATE nHandle                         && File handle
PRIVATE cString                         && String buffer
PRIVATE nOrgSize                        && Original string size
PRIVATE nCmpSize                        && Compressed string size
PRIVATE aErrTxt [11]                    && Array with error messages

*-- Initialize array with error messages
aErrTxt [ 1] = "Invalid parameter passed"
aErrTxt [ 2] = "Error opening input file"
aErrTxt [ 3] = "Not compressed by RCmpLib or protected"
aErrTxt [ 4] = "Wrong version of RCmpLib"
aErrTxt [ 5] = "Error creating output file"
aErrTxt [ 6] = "Error reading input file"
aErrTxt [ 7] = "Error writing output file"
aErrTxt [ 8] = "No files found to compress"
aErrTxt [ 9] = "Function aborted by user"
aErrTxt [10] = "String couldn't be compressed"
aErrTxt [11] = "String was already compressed"

SetColor ( 'W+/B' )

*-- Disable scoreboard
SET SCOREBOARD OFF

*--------------------------------------------------------------------------
*                   M A I N   P R O G R A M   L O O P
*--------------------------------------------------------------------------
DO WHILE .t.

   *-- Display header lines
   bHeader ()

   *-- Do some advertisement ...
   @ 2,21 SAY 'THE COMPRESSION LIBRARY FOR CA-CLIPPER'
   @ 4,11 SAY ' ▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄                    ▄        ▄▄  ▄      '
   @ 5,11 SAY '▒▒▒▒▒▒▒█ ▒▒▒▒▒▒▒▀                   ▒█       ▒▒▀ ▒█      '
   @ 6,11 SAY '▒█▄▄▄▄▒█ ▒█        ▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄ ▒█        ▄▄ ▒█▄▄▄▄▄▄'
   @ 7,11 SAY '▒▒▒▒▒▒▒▀ ▒█       ▒▒▒▒▒▒▒█ ▒▒▒▒▒▒▒█ ▒█       ▒▒█ ▒▒▒▒▒▒▒█'
   @ 8,11 SAY '▒█   ▒▀▄ ▒█▄▄▄▄▄▄ ▒▒█▒█▒▒█ ▒█▄▄▄▄▒█ ▒█▄▄▄▄▄▄ ▒▒█ ▒█▄▄▄▄▒█'
   @ 9,11 SAY '▒▀    ▒▀ ▒▒▒▒▒▒▒▀ ▒▒▀▒▀▒▒▀ ▒▒▒▒▒▒▒▀ ▒▒▒▒▒▒▒▀ ▒▒▀ ▒▒▒▒▒▒▒▀'
   @10,11 SAY '                           ▒█                            '
   @11,11 SAY ' (c) 1995 Rolf van Gelder  ▒▀ Eindhoven, The Netherlands '

   *-- Draw double box for main menu
   @13,8 TO 19,71 DOUBLE

   *-- Display main menu
   nChoice = AChoice ( 14, 10, 18, 69, aMenu, '', '', nChoice )

   IF LastKey () = 27 .or. nChoice = Len ( aMenu )
      *-- <Esc> or 'End of Demo'
      EXIT
   ENDIF

   *-- Display header lines
   bHeader ()

   DO CASE
   CASE nChoice = 1
      *-- COMPRESS FILES INTO AN ARCHIVE

      CenterMsg ( 3, 'COMPRESS FILES INTO AN ARCHIVE - R_CmpFile()' )

      cOldCol = SetColor ( 'W+/BG' )
      @5,13 TO 8,64
      @6,14 SAY ' The files RCMPLIB.*, *.PRG and DUTCH.REG will be '
      @7,14 SAY ' compressed into an archive called ARCHIVE.RCP.   '
      SetColor ( cOldCol )

      *-- Hit any key ....
      bHitKey ()

      @5,0 CLEAR

      *-- Draw box for progression bar
      cOldCol = SetColor ( 'W+/R' )
      @6,23 CLEAR TO 8,56
      @6,23 TO 8,56
      SetColor ( cOldCol )
      @9,25 SAY 'Compressing: '

      *--------------------------------------------------------------------
      * Files to compress : RCmpLib.*, *.PRG and Dutch.REG
      * Archive file      : Archive.RCP
      * Keep originals    : lMove = .F.
      * Progression bar   : Length = 30,           (Row,Col) = (7,25)
      *                   : Character = Chr (177), Color = Yellow on Red
      * Password          : none ( '' )
      * Interruptable     : lEscape = .T.
      * User function     : DispName() to display current filename
      *--------------------------------------------------------------------
      nRetCode = R_CmpFile ( 'RCmpLib.*;*.PRG;Dutch.REG', ;
         'Archive.RCP', .F., 30, 7, 25, Chr ( 177 ), 'GR+/R', '', .T., ;
         'DispName' )

      *-- Clear box
      @6,0 CLEAR

      IF nRetCode != 0
         *-- Error detected : display error message
         CenterMsg ( 22, 'Error : ' + aErrTxt [ nRetCode ] )

      ELSE
         *-- No errors detected !
         CenterMsg ( 22, 'Archive ARCHIVE.RCP created.' )

      ENDIF

      *-- Hit any key ....
      bHitKey ()


   CASE nChoice = 2
      *-- SHOW FILE-INFO FROM AN ARCHIVE FILE

      CenterMsg ( 3, 'SHOW FILE-INFO FROM AN ARCHIVE FILE - R_CmpList()' )

      cOldCol = SetColor ( 'W+/BG' )
      @5,17 TO 8,60
      @6,18 SAY ' File information for the files in the    '
      @7,18 SAY ' archive file ARCHIVE.RCP will be listed. '
      SetColor ( cOldCol )

      *-- Hit any key ....
      bHitKey ()

      @5,0 CLEAR

      @5,0 SAY ''
      *-- Determine number of files in the archive
      nFiles = R_CmpList ( 'Archive.RCP' )

      IF nFiles > 0
         *-- One of more files found in the archive !

         DECLARE aNames   [ nFiles ]    && Filenames
         DECLARE aOSize   [ nFiles ]    && Original file size
         DECLARE aODate   [ nFiles ]    && Original file date
         DECLARE aOTime   [ nFiles ]    && Original file time
         DECLARE aCSize   [ nFiles ]    && Size of compressed file
         DECLARE aRatio   [ nFiles ]    && Compression ratio
         DECLARE aVersion [ nFiles ]    && Version of RCmpLib

         nRetCode = R_CmpList ( 'Archive.RCP', '', @aNames, @aOSize, ;
            @aODate, @aOTime, @aCSize, @aRatio, @aVersion )

         IF nRetCode >= 0
            *-- File-Info loaded into the arrays !

            nTotOrgSize = 0             && Total counters
            nTotCmpSize = 0

            CenterMsg ( 5, 'Filename      Org.Size Filedate   Time  ' + ;
              'Cmp.Size    Ratio  Version        ', 'W+/BG' )

            *-- Display contents of the file-info array
            FOR nFile = 1 TO nFiles
               ?Str ( nFile, 2 ) + ' ' + ;
               Left ( aNames [ nFile ], 13 ) + ' ' + ;
               Str ( aOSize [ nFile ], 8 ) + ' ' + ;
               aODate [ nFile ] + ' ' + aOTime [ nFile ] + ' ' + ;
               Str ( aCSize [ nFile ], 8 ) + ' ' + ;
               Str ( aRatio [ nFile ], 8, 2 ) + '%' + ' ' + ;
               aVersion [ nFile ]
               nTotOrgSize = nTotOrgSize + aOSize [ nFile ]
               nTotCmpSize = nTotCmpSize + aCSize [ nFile ]
            NEXT

            *-- Display totals
            CenterMsg ( Row()+1, 'Totals       ' + Str ( nTotOrgSize, 9 ) + ;
               Space ( 17 ) + Str ( nTotCmpSize, 9 ) + ;
               Space ( 3 ) + ;
               Str ( 100 * (nTotOrgSize-nTotCmpSize) / nTotOrgSize, 6, 2 ) + ;
               '%' + Space ( 15 ), 'W+/BG' )

         ENDIF

      ELSE
         *-- No files found or error detected ...
         nRetCode = nFiles

      ENDIF

      IF nRetCode < 0
         *-- Error detected : display error message
         CenterMsg ( 22, 'Error : ' + aErrTxt [ -nRetCode ] )

      ENDIF

      *-- Hit any key ....
      bHitKey ()


   CASE nChoice = 3
      *-- Extract files from an archive

      CenterMsg ( 3, 'EXTRACT FILES FROM AN ARCHIVE - R_DCmpFile()' )

      cOldCol = SetColor ( 'W+/BG' )
      @5,11 TO 8,66
      @6,12 SAY ' The files *.CH and *.PRG will be extracted from      '
      @7,12 SAY ' the archive file ARCHIVE.RCP to the ROOT directory.  '
      SetColor ( cOldCol )

      *-- Hit any key ....
      bHitKey ()

      @5,0 CLEAR

      *-- Draw box for progression bar
      cOldCol = SetColor ( 'W+/BG' )
      @6,23 CLEAR TO 8,56
      @6,23 TO 8,56
      SetColor ( cOldCol )
      @9,25 SAY 'Extracting: '

      *--------------------------------------------------------------------
      * Archive file      : Archive.RCP
      * Files to extract  : *.CH and *.PRG
      * Destination dir   : \
      * Progression bar   : Length    = 30, (Row,Col) = (7,25)
      *                   : Character = Chr (177), Color = Yellow on Red
      * Password          : none ( '' )
      * Interruptable     : lEscape = .T.
      * User Function     : DispName() to display current file skeleton
      *--------------------------------------------------------------------
      nRetCode = R_DCmpFile ( 'Archive.RCP', '*.CH;*.PRG', '\', ;
         30, 7, 25, Chr ( 177 ), 'GR+/R', '', .T., 'DispName' )

      *-- Clear box
      @6,0 CLEAR

      IF nRetCode != 0
         *-- Error detected : display error message
         CenterMsg ( 22, 'Error : ' + aErrTxt [ nRetCode ] )

      ELSE
         *-- No errors detected !
         CenterMsg ( 22, 'Files extracted from ARCHIVE.RCP ' + ;
                 'to the ROOT directory !' )

      ENDIF

      *-- Hit any key ....
      bHitKey ()


   CASE nChoice = 4
      *-- STRING COMPRESSION / DECOMPRESSION

      CenterMsg ( 3, 'STRING COMPRESSION/DECOMPRESSION - ' + ;
         'RCmpStr(),R_DCmpStr()' )

      cOldCol = SetColor ( 'W+/BG' )
      @5,13 TO 8,64
      @6,14 SAY ' The file RCMPLIB.DOC will be read into a string, '
      @7,14 SAY ' the string will be compressed and decompressed.  '
      SetColor ( cOldCol )

      *-- Hit any key ....
      bHitKey ()

      @5,0 CLEAR

      IF File ( 'RCmpLib.DOC' )
         *-- Get the file size of RCmpLib.DOC
         nOrgSize = R_FSize ( 'RCmpLib.DOC' )

         *-- Allocate buffer space
         cString = Space ( nOrgSize )

         *-- Open file
         nHandle = FOpen ( 'RCmpLib.DOC' )

         *-- Read file into a string
         FRead ( nHandle, @cString, nOrgSize )

         *-- Close file
         FClose ( nHandle )

         CenterMsg ( 20, 'File RCmpLib.DOC is read into a string.' )
         CenterMsg ( 21, '' )
         CenterMsg ( 22, 'String length = ' + Str ( nOrgSize, 5 ) + ;
                 ' bytes.' )

         *-- Hit any key ....
         bHitKey ()
         @20,0 CLEAR

         *-- Show the string as read from the file (using MEMOEDIT)
         DispStr ( cString, ;
            'Original string─' + LTrim ( Str ( nOrgSize ) ) + ' bytes' )

         CenterMsg ( 21, 'The string containing RCmpLib.DOC ' + ;
            'will be compressed,' )
         CenterMsg ( 22, 'using the R_CmpStr() function ...' )

         *-- Hit any key ....
         bHitKey ()
         @21,0 CLEAR

         *-- COMPRESS THE STRING !
         cString  = R_CmpStr ( cString )

         *-- Size of the compressed string
         nCmpSize = Len ( cString )

         CenterMsg ( 17, 'The string is compressed !' )
         CenterMsg ( 18, '' )
         CenterMsg ( 19, 'Length of ORIGINAL   string ' + ;
            Str ( nOrgSize, 7 ) )
         CenterMsg ( 20, 'Length of COMPRESSED string ' + ;
            Str ( nCmpSize, 7 ) )
         CenterMsg ( 21, '' )
         CenterMsg ( 22, 'Compression ratio ' + ;
            Str ( 100 * (nOrgSize-nCmpSize)/nOrgSize, 6, 2 ) + '%' )

         *-- Hit any key ....
         bHitKey ()
         @17,0 CLEAR

         CenterMsg ( 22, 'Now take a look at the COMPRESSED string ...', ;
            'W+/RB' )

         *-- Hit any key ....
         bHitKey ()
         @22,0 CLEAR

         *-- Show the compressed string using MEMOEDIT()
         DispStr ( cString, ;
            'Compressed string─' + LTrim ( Str ( nCmpSize ) ) + ' bytes' )

         CenterMsg ( 21, 'The compressed string will now be decompressed', ;
            'W+/RB' )
         CenterMsg ( 22, 'using the R_DCmpStr() function ...' )

         *-- Hit any key ....
         bHitKey ()
         @21,0 CLEAR

         *-- DECOMPRESS THE STRING !
         cString = R_DCmpStr ( cString )

         CenterMsg ( 20, 'Decompression done !' )
         CenterMsg ( 21, '' )
         CenterMsg ( 22, 'Look at the ORIGINAL string ...' )

         *-- Hit any key ....
         bHitKey ()

         @20,0 CLEAR

         *-- Show the decompressed string using MEMOEDIT
         DispStr ( cString, ;
            'Original string─' + LTrim ( Str ( nOrgSize ) ) + ' bytes' )

      ELSE
         CenterMsg ( 22, 'File not found : RCMPLIB.DOC' )

         *-- Hit any key ....
         bHitKey ()

      ENDIF

   ENDCASE

ENDDO

@23,0 SAY ''

QUIT


*==========================================================================
* FUNCTION TO DISPLAY HEADER LINES
*==========================================================================
FUNCTION bHeader

CLEAR

@0,0 SAY 'RCmpDemS: Demo program for RCmpLib v3.1 - '+;
         '24/01/95     (c) 1995  Rolf van Gelder'
@1,0 SAY Replicate ( '─', 80 )

RETURN .F.


*==========================================================================
* HIT ANY KEY ....
*==========================================================================
FUNCTION bHitKey

@24,32 SAY 'Hit any key ....'

InKey ( 0 )

RETURN .F.


*==========================================================================
* FUNCTION TO DISPLAY A FILENAME
*==========================================================================
FUNCTION DispName

PARAMETERS cFName

@9,38 SAY cFName + Space ( 12 - Len ( cFName ) )

RETURN 1                                && Continue (de-)compression


*==========================================================================
* FUNCTION TO CENTER A MESSAGE
*==========================================================================
FUNCTION CenterMsg

PARAMETERS nRow, cTxt, cColor

PRIVATE cOldCol

IF PCount () > 2
   *-- Colorstring passed
   cOldCol = SetColor ( cColor )
ELSE
   *-- Default colorstring
   cOldCol = SetColor ( 'W+/RB' )
ENDIF

@nRow, 0 CLEAR TO nRow, 79
@nRow, ( 80 - Len ( cTxt ) ) / 2 SAY cTxt

SetColor ( cOldCol )

RETURN .F.


*==========================================================================
* FUNCTION TO DISPLAY A STRING USING THE MEMO-EDITOR, MEMOEDIT()
*==========================================================================
FUNCTION DispStr

PARAMETERS cString, cTitle

PRIVATE cOldCol

cOldCol = SetColor ( 'W+/BG' )

@2,0 CLEAR TO 22,79
@2,0 TO 22,79

@ 2,2 SAY cTitle
@22,2 SAY 'Press <Esc> to Exit'

MemoEdit ( cString, 3, 1, 21, 78, .F. )

SetColor ( cOldCol )

@2,0 CLEAR

RETURN .F.
*
* EOF RCmpDemS.PRG ========================================================
