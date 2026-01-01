*--------------------------------------------------------------------------
* RPCXDemo.PRG - Program to demonstrate the use of the functions
*                in the graphic RPCXLib library for CA-Clipper
*
* This demo has been written for CA-Clipper version 5.xx
*
* Compile    :	CLIPPER RPCXDEMO /N
*
* Link       :	RTLINK  file RPCXDEMO lib RPCXLIB    - or -
*		BLINKER file RPCXDEMO lib RPCXLIB
*
* Syntax     :  RPCXDEMO [d:][\path]
*		[d:][\path] : directory where PCX-files are located
*--------------------------------------------------------------------------
* Date       :  19/04/95
*--------------------------------------------------------------------------
* Author     :  Rolf van Gelder
*               Binnenwiertzstraat 27
*               5615 HG  EINDHOVEN
*		THE NETHERLANDS
*
* E-Mail     :  Internet: RCROLF@urc.tue.nl
*               BitNet  : RCROLF@heitue5
*--------------------------------------------------------------------------
* (c) 1993-95  Rolf van Gelder  -  All rights reserved
*--------------------------------------------------------------------------
MEMVAR	GetList				&& To eliminate Clipper /W warning

*--------------------------------------------------------------------------
* Standard CA-Clipper HEADER files
*--------------------------------------------------------------------------
#include "Inkey.ch"
#include "AChoice.ch"
#include "SetCurs.ch"
#include "Directry.ch"

*--------------------------------------------------------------------------
* RPCXLIB HEADER FILE
*--------------------------------------------------------------------------
#include "RPCXLib.ch"

*--------------------------------------------------------------------------
* Static array (used by different functions)
*--------------------------------------------------------------------------
*-- Initialize the array with error messages (from RPCXLib.CH)
STATIC	aPCXError := PL_ERRMSG

*--------------------------------------------------------------------------
*
*                         Main function : RPCXDemo
*
*--------------------------------------------------------------------------

FUNCTION R_PCXDemo ( cDrvPath )

LOCAL	nSVGA     := R_VGACard ()	&& Number of SVGA card
LOCAL	aDrivers  := PL_SVGA_NAMES	&& Names of the SVGA cards

LOCAL	cGraphDrv			&& Description SVGA card
LOCAL	cGraphSys := 'UNKNOWN'		&& Description Graphic System

LOCAL	cGraphMsg			&& Text buffer

LOCAL	nFiles				&& Number of PCX-files in directory
LOCAL	nBottom				&& Last line for AChoice window

LOCAL	aPCXList  := {}			&& Array with PCX-file info
LOCAL	aValid    := {}			&& Selectable items for AChoice
LOCAL	aPCXDir   := {}			&& Directory info PCX-files

LOCAL	nChoice   := 1			&& Sequence number chosen file
LOCAL	nLastKey			&& Keycode
LOCAL	cFile				&& Name of PCX-file
LOCAL	nVidMode  := R_VMGet ()		&& Original video mode
LOCAL	nRetCode			&& Return code of R_ShowPCX
LOCAL	cScreen				&& Screen buffer
LOCAL	cSpec				&& Filespec PCX-file
LOCAL	cComment			&& Comment on PCX-file
LOCAL	i				&& Counter
LOCAL	n				&& Help variable
LOCAL	nRed				&& Red   component
LOCAL	nGreen				&& Green component
LOCAL	nBlue				&& Blue  component

LOCAL	aBWhite := PL_DEF_BRIGHT_WHITE	&& Composition BRIGHT WHITE
LOCAL	aWhite  := PL_DEF_WHITE		&& Composition WHITE
LOCAL	aYellow := PL_DEF_YELLOW	&& Composition YELLOW

LOCAL	cPalette			&& Palette buffer
LOCAL	cPalOrg := R_SavePal ()		&& Save original palette

*-- Install the default CA-Clipper palette (just to be sure ...)
R_DefPal ()

*-- Mix a special GREEN colour for the background :
*--    5 x RED + 30 x GREEN + 30 x BLUE
R_SetRGB ( PL_GREEN, 5, 30, 30 )

*-- Determine the number of PCX-files in the current directory
IF cDrvPath != NIL
   *-- Path passed as command line parameter

   *-- Append a backslash (if needed)
   cDrvPath := Trim ( cDrvPath )

   IF Right ( cDrvPath, 1 ) != ':'
      *-- Path has been given

      IF Right ( cDrvPath, 1 ) != '\'
         *-- Path doesn't end with a backslash : append !

         cDrvPath += '\'

      ENDIF

   ENDIF

ELSE
   *-- No drive nor path given

   cDrvPath := ''

ENDIF

*-- Get the directory list of the PCX-files
aPCXDir := Directory ( cDrvPath + '*.PCX' )
nFiles  := Len ( aPCXDir )

IF nFiles > 0
   *-- PCX-files found !

   FOR i := 1 TO nFiles
      *-- Stuff the info of all the PCX-files in an array

      AADD ( aValid , GetInfo (cDrvPath+aPCXDir[i,F_NAME], @cSpec, @cComment ) )
      AADD ( aPCXList, PADR ( aPCXDir[i,F_NAME], 12 ) + ' │ ' + ;
         Str ( aPCXDir[i,F_SIZE],6 ) + ' │ ' + ;
         PADR ( cSpec, 16 ) + ' │ ' + PADR ( cComment, 33 ) )

   NEXT

   *-- Sort the array on file name
   aPCXList := ASORT ( aPCXList )
   
ENDIF

IF nSVGA < 1
   *-- SuperVGA unknown or not present !

   *-- Determine the graphic system of the PC
   IF R_IsMCGA ()
      cGraphSys := 'MCGA'
      
   ELSEIF R_IsVGA ()
      cGraphSys := 'VGA'
      
   ELSEIF R_IsEGA ()
      cGraphSys := 'EGA'
      
   ENDIF
   
ELSE
   
   cGraphSys := 'SUPERVGA'

   *-- Name of the SuperVGA adapter
   cGraphDrv := aDrivers [nSVGA]
   
ENDIF

SETCOLOR ( 'W+/G' )
SETBLINK ( .t. )
CLEAR

*-- Header text
DEVPOS ( 1, 11 )
DEVOUT ( 'RPCXDemo : Demo program for the RPCXLib CA-Clipper Library' )

SETCOLOR ( 'GR+/G' )
DEVPOS ( 2, 26 )
DEVOUT ( '(c) 1993-95 Rolf van Gelder' )
SETCOLOR ('W+/G')

IF nFiles < 1
   *-- No PCX-files in current directory :
   *--    Just show the graphic configuration
   
   ALERT ( '-+- CONFIGURATION -+-;;;Graphic System: ' + cGraphSys + ;
      IF ( cGraphDrv != nil, ';;;SVGA Adapter: ' + cGraphDrv, nil ) )
   
   ALERT ( 'No PCX-files found !' )
   
   RETURN nil
   
ENDIF

*-- Determine the height of the directory listbox
nBottom := Min ( nFiles+6, 16 ) 

DEVPOS ( nBottom+1, 11 )
DEVOUT ( '<─┘ = Show file  -+-  <F10> = SlideShow   -+- <Esc> = Quit' )

@19,0 TO 22,79
DEVPOS ( 20, 2 )
DEVOUT ( 'MIX BACKGROUND COLOUR         Current values : RED   5'+;
         ' - GREEN 30 -  BLUE 30' )
DEVPOS ( 21, 2 )
DEVOUT ( 'F1=RED    F2=RED        F3=GREEN    F4=GREEN       '+;
         'F5=BLUE    F6=BLUE ' )

@4,0 TO nBottom,79 DOUBLE
SETCOLOR ( 'GR+/G' )
@5,2 SAY 'File name    │  Bytes │ Width Height Col │ Video mode / Comment  '

*-- Display the graphic configuration on line 23
cGraphMsg := '-+- Graphic System : '+cGraphSys

IF cGraphDrv != nil
   
   cGraphMsg += ' -+- SVGA Adapter : '+cGraphDrv
   
ENDIF

cGraphMsg += ' -+-'

@23, ( 80 - LEN ( cGraphMsg ) ) / 2 SAY cGraphMsg
SETCOLOR ( 'W+/G,W+/R,,,W/G' )

cScreen := SAVESCREEN ( 0, 0, MAXROW(), MAXCOL() )

*----------------------------------------------------------------
* Main loop for displaying pictures and changing the background
* colour
*----------------------------------------------------------------
DO WHILE .T.
   
   nChoice  := ACHOICE ( 6, 2, nBottom-1, 77, aPCXList, ;
               aValid, 'AchUser', nChoice )

   nLastKey := LASTKEY ()

   DO CASE

   CASE nLastKey = K_ESC
      *-- Quit
      EXIT

   CASE nLastKey = K_RETURN
      *-- SHOW CHOSEN FILE

      *-- File name PCX-file
      cFile    := cDrvPath + TRIM ( LEFT ( aPCXList [nChoice], 12 ) )

      *-- Save current palette to a string
      cPalette := R_SavePal ()

      *-- Show the PCX-file on the screen
      nRetCode := R_ShowPCX ( cFile )
   
      IF nRetCode = PL_OKAY
         *-- It went okay !

         *-- Show the picture 10 seconds (interruptible)
         INKEY ( 10 )

         *-- Restore original video mode
         R_VMSet ( nVidMode )

      ENDIF

      *-- Restore original palette
      *-- (Palette has been reset by R_VMSet () ....)
      R_RestPal ( cPalette )

      *-- Repaint the screen
      RESTSCREEN ( 0, 0, MAXROW(), MAXCOL(), cScreen )

      IF nRetCode != PL_OKAY

         *-- Error while displaying PCX-file : display error message

         ALERT ('-+- Error displaying '+cFile+' -+-;;'+;
            aPCXError[nRetCode])

      ENDIF

   CASE nLastKey = K_F10
      *-- Slideshow

      *-- Save current palette to a string
      cPalette := R_SavePal ()

      FOR i := 1 TO nFiles

          IF aValid [i]
             *-- PCX-file can be displayed !

             *-- Name of the PCX-file
             cFile    := cDrvPath + TRIM ( LEFT ( aPCXList [i], 12 ) )

             *-- Display the PCX-file
             nRetCode := R_ShowPCX ( cFile )
   
             IF nRetCode = PL_OKAY
                *-- Picture is on the screen

                *-- Wait for 5 seconds (interruptible)
                INKEY ( 5 )

             ENDIF

         ENDIF

      NEXT

      *-- Restore original video mode
      R_VMSet ( nVidMode )

      *-- Restore original palette
      *-- (The palette has been reset by R_VMSet () ....)
      R_RestPal ( cPalette )

      *-- Repaint the screen
      RESTSCREEN ( 0, 0, MAXROW(), MAXCOL(), cScreen )

   ENDCASE
   
ENDDO

SETCURSOR ( SC_NONE )

*--------------------------------------------------------------------------
* Nice piece of code which demonstrates the DIMMING of colours.
* All colours on the screen will fade to BLACK.
*--------------------------------------------------------------------------

*-- Get the current composition of PL_GREEN
R_GetRGB ( PL_GREEN, @nRed, @nGreen, @nBlue )

*-- Loop to put the colours to BLACK (gradually)
FOR i := 63 TO 0 STEP -1

   *-- Scaling factor
   N := i / 63

   *-- Decrease BRIGHT WHITE
   R_SetRGB ( PL_BRIGHT_WHITE, N * aBWhite[1], N * aBWhite[2], N * aBWhite[3] )

   *-- Decrease WHITE
   R_SetRGB ( PL_WHITE,  N * aWhite[1],  N * aWhite[2],  N * aWhite[3] )

   *-- Decrease YELLOW
   R_SetRGB ( PL_YELLOW, N * aYellow[1], N * aYellow[2], N * aYellow[3] )

   *-- Decrease GREEN
   R_SetRGB ( PL_GREEN,  N * nRed,       N * nGreen,     N * nBlue )

   *-- Little delay
   IF INKEY ( 0.1 ) = K_ESC
      *-- <Esc> pressed : abort
      EXIT
   ENDIF
   
NEXT

SETCOLOR ('W/N')

CLEAR

*-- Restore the original palette
R_RestPal ( cPalOrg )

CLEAR

SETCURSOR ( SC_NORMAL )

RETURN NIL


*--------------------------------------------------------------------------
*
*                   GetInfo ( cFName, cSpec, cComment )
*
*--------------------------------------------------------------------------
* Function to get and format PCX-file information
*
* INPUT
* cFName   : Name PCX-file (has to have the .PCX extension)
* cSpec    : Text buffer for specification of the PCX-file
* cComment : Text buffer for comment about the PCX-file
*
* OUTPUT
* lValid   : .T. = PCX-file is valid
*            .F. = PCX-file is invalid
*--------------------------------------------------------------------------
STATIC FUNCTION GetInfo ( cFName, cSpec, cComment )

LOCAL	nWidth			&& Width  of the PCX-file (pixels)
LOCAL	nHeight			&& Height of the PCX-file (pixels)
LOCAL	nColors			&& Number of colours (16 or 256)
LOCAL	nAdapter		&& Required adapter for PCX-file
LOCAL	lValid := .T.		&& Return code (.T.=valid, .F.=invalid)
LOCAL	nRetCode		&& Return code of R_PCXInfo ()

***
* Get information of the current PCX-file.
*    Note : the last 4 parameters must be passed BY REFERENCE (@) !
***
nRetCode := R_PCXInfo ( cfname, @nWidth, @nHeight, @nColors, @nAdapter )

IF nRetCode != PL_OKAY
   *-- Error detected by R_PCXInfo()

   *-- Place the error message in cComment
   cComment := aPCXError [nRetCode]
   
   RETURN .F.
   
ENDIF

cComment := cSpec := ""

*-- Place the dimension and colours in the specification string (cSpec)
cSpec    := STR(nWidth,5) + ' ' + STR(nHeight,6) + ' ' + STR(nColors,3)

*--------------------------------------------------------------------------
* Determine which VIDEO MODE will be used for the current PCX_file
*--------------------------------------------------------------------------
IF nWidth > 640 .OR. nHeight > 480

   *-- Maximal dimension is 640 x 480 !
   cComment := '(Picture too large !)'

   RETURN .F.
   
ENDIF

IF nColors = 16

   *-- 16 colours !
   IF nAdapter = PL_EGA

      *-- EGA adapter required
      cComment := 'EGA 16    640 x 350 x  16'

      *-- EGA adapter present ?
      lValid   := R_IsEGA ()

   ELSE

      *-- Standard VGA adapter required
      cComment := 'VGA 18    640 x 480 x  16'

      *-- Standard VGA adapter present ?
      lValid   := R_IsVGA ()

   ENDIF

ELSE
   *-- 256 colours !
   IF nAdapter = PL_VGA

      *-- Standard VGA adapter required
      cComment := 'VGA 19    320 x 200 x 256'

      *-- Standard VGA adapter present ?
      lValid   := R_IsVGA ()

   ELSE

      *-- SuperVGA adapter required
      cComment := 'SuperVGA  640 x 480 x 256'

      *-- Supported SuperVGA adapter present ?
      lValid   := R_IsSVGA ()

   ENDIF

ENDIF

RETURN lValid


*--------------------------------------------------------------------------
*
*                              AchUser ( nMode )
*
*--------------------------------------------------------------------------
* User-defined function for the CA-Clipper AChoice () function
*
* INPUT
* nMode : Mode of AChoice ()
*
* OUTPUT
* Return code for AChoice ()
*--------------------------------------------------------------------------
FUNCTION AchUser ( nMode )

LOCAL	nKey := LASTKEY ()		&& Last key pressed

LOCAL	nRed				&& Red   component
LOCAL	nGreen				&& Green component
LOCAL	nBlue				&& Blue  component

LOCAL	lSetPal := .F.			&& Flag that indicates whether
					&& the palette is changed

IF nMode != AC_EXCEPT
   *-- No keystroke exception
   
   RETURN AC_CONT
   
ENDIF

*-- KEYSTROKE EXCEPTION

IF nKey = K_F1 .OR. nKey = K_F2 .OR. ;
   nKey = K_F3 .OR. nKey = K_F4 .OR. ;
   nKey = K_F5 .OR. nKey = K_F6

   *-- Key pressed for changing the background colour

   *-- Get the current composition of PL_GREEN
   R_GetRGB ( PL_GREEN, @nRed, @nGreen, @nBlue )
   
ENDIF

DO CASE
   
CASE nKey = K_F1
   *-- Increase the RED component
   IF nRed < 63
      *-- Can be increased
      nRed ++
      lSetPal := .T.
   ENDIF
   
CASE nKey = K_F2
   *-- Decrease the RED component
   IF nRed > 0
      *-- Can be decreased
      nRed --
      lSetPal := .T.
   ENDIF
   
CASE nKey = K_F3
   *-- Increase the GREEN component
   IF nGreen < 63
      *-- Can be increased
      nGreen ++
      lSetPal := .T.
   ENDIF
   
CASE nKey = K_F4
   *-- Decrease the GREEN component
   IF nGreen > 0
      *-- Can be decreased
      nGreen --
      lSetPal := .T.
   ENDIF
   
CASE nKey = K_F5
   *-- Increase the BLUE component
   IF nBlue < 63
      *-- Can be increased
      nBlue ++
      lSetPal := .T.
   ENDIF
   
CASE nKey = K_F6
   *-- Decrease the BLUE component
   IF nBlue > 0
      *-- Can be decreased
      nBlue --
      lSetPal := .T.
   ENDIF

CASE nKey = K_F10
   *-- Request for a SLIDESHOW : abort AChoice ()
   RETURN AC_SELECT
   
CASE nKey = K_HOME
   *-- To first record
   KEYBOARD (CHR(K_CTRL_PGUP))
   
CASE nKey = K_END
   *-- To last record
   KEYBOARD (CHR(K_CTRL_PGDN))
   
CASE nKey = K_RETURN
   *-- PCX-file chosen
   RETURN AC_SELECT
   
CASE nKey = K_ESC
   *-- Aborted
   RETURN AC_ABORT
   
CASE nKey > 31 .AND. nKey < 126
   *-- Letter or digit
   RETURN AC_GOTO
   
CASE nKey = K_LEFT .OR. nKey = K_RIGHT
   *-- Ignore Left and Right arrow keys
   RETURN AC_CONT
   
ENDCASE

IF lSetPal
   *-- Background colour changed : adjust the palette

   *-- Substitute the new value of PL_GREEN into the palette
   R_SetRGB ( PL_GREEN, nRed, nGreen, nBlue )

   *-- Display the new composition of the background colour (PL_GREEN)
   DEVPOS ( 20,54 ); DEVOUT ( STR ( nRed,  2 ) )
   DEVPOS ( 20,65 ); DEVOUT ( STR ( nGreen, 2 ) )
   DEVPOS ( 20,76 ); DEVOUT ( STR ( nBlue, 2 ) )
   
ENDIF

RETURN AC_CONT
*
* EOF RPCXDemo.PRG ========================================================