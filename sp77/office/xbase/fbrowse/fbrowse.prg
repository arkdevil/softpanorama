/****************************************************************************
*  Browse Function By: Tom Claffy  March 1993
*  Search Routine  By: Phil Barnett  April 3, 1993
*  Minor Repair of DownFillArray By: Phil Barnett  April 5, 1993
*  Added Highlight to Search By: Tom Claffy  April 10, 1993
*  Added minor comments and fixed anomalous display on small files
*                                Tom Claffy  May 25, 1993
*  Added MAXBROWSELENGTH to avoid lockup on binary files: TC 7-26-1993
*  Fixed Ctrl-PgUp and Ctrl-PgDn problems with small files: TC 9-15-93
*  Added optional code block to modify text as it is extracted TC 9-23-93
*  LineDisp Function By: Todd C. MacDonald 9-28-1993 with minor
*      modification by Tom Claffy
*
*  Placed in Public Domain July 29, 1993 by Tom Claffy
*
*  Pure Clipper Text File Browser
*
*  with...
*
*      Virtual Reads  (view any size file with low memory overhead)
*      Relative Position Indicator
*      Panning
*      User-defineable Color Blocks
*      Search and Repeat Search
*      Handles all Video Screen sizes (looks nice in 40*132)
*      100% Clipper
*
*      Compile Clipper 5.x -n
****************************************************************************/
#include 'inkey.ch'
#include 'common.ch'
/***************************************************************************
* This is the default maximum line length
***************************************************************************/
#define MAXBROWSELENGTH 135

/***************************************************************************
* These defines are used by the LineDisp function to define the
* elements of the display color as written by Todd C. MacDonald.
****************************************************************************/
#define CODE_LEN    3
#define COLOR_CODE  1
#define COLOR_SET   2
#define COLOR_DELIM '~~'

/****************************************************************************
* Sample usage
* NOTE - the FileBrowse function has no error trapping built in for
* opening the file to browse - it assumes you have verified the existence
* of a valid file. Although designed to browse a standard text file
* with a line termination string of CR LF, it is also error-trapped
* so it will not choke on a binary file (but don't expect any meaningful
* display :).
****************************************************************************/

Function fBrowse( cFileName )
LOCAL OldBlink

/**************************************************************************
* aDispColors variable:
* ~~7 ~~R This is modeled from Todd C. MacDonald's example provided in his
* ~~7 ~~R LineDisp() function. The actual delimiter is left to you and you
* ~~7 ~~R can use whatever you want just be sure it is guaranteed unique
* ~~7 ~~R and is properly inserted in the COLOR_DELIM define above.
* ~~7 ~~R Todd used the double tilde hence I am simply carrying forward
* ~~7 ~~R his convention. The double tilde in this comment block will
* ~~7 ~~R cause these lines to be displayed in BRIGHT WHITE on RED if
* ~~7 ~~R you compile, link and browse this program file. The double
* ~~7 ~~R tilde character will be stripped before display.
* ~~7 ~~N This line will be BLACK on RED.
* ~~7              (And the whole thing is in a semi-shadow)
****************************************************************************/
LOCAL aDispColors := { { '~~R', 'GR+/B'  } , { '~~7', 'W/N'   } , ;
                       { '~~N', 'N/R'   } , { '~~D', NIL     } , ;
                       { '~~Y' , 'GR+/B' } , { '~~G' , 'G+/B' } }

/***************************************************************************
* bApplyText:
* This code block will be applied to all lines of text before they are
* stored in the display array as follows: cLine = Eval( bApplyText , cLine )
* A standard usage of this block would be to strip imbedded printer control
* codes for display of the file.
* Credited to Todd C. MacDonald, who encloses the printer codes in
* delimiters, strips the entire code for display, then strips just the
* delimiters to allow the user to immediately send the same file to the
* printer with printer control codes intact.
****************************************************************************/
LOCAL bApplyText := { |x| Strtran( x ,"Function" , "FUNCTION" ) }

set scoreboard off
If cFileName == NIL
   ? 'Browse <cFileName>'
Elseif !file( cFileName )
   ? cFileName + ' not found!'
Else
   OldBlink = SetBlink(.f.)
   *FileBrowse(cFileName,0,0,maxrow(),maxcol(),'w+/b','b+/b','b+/w','r+/bg',;
   *           bApplyText,aDispColors)
   FileBrowse(cFileName,2,0,maxrow(),maxcol(),'w/b','b+/b','b/w','r/bg',;
              bApplyText,aDispColors)
   SetBlink( OldBlink )
Endif
RETURN NIL

* End of commercial announcement

/****************************************************************************
* Syntax          FileBrowse( <cFileName> , [<nTop>] , [<nLeft>] ,
*                     [<nBottom>] , [<nRight>] , [<cWinColor>] ,
*                     [<cBoxColor>] , [<cBarColor>] , [<cButtonColor>] ,
*                     [<bApplyText>] , [<aDispColors>] )
*
* Arguments       <cFileName> DOS file to browse. Provide your own
*                     error trapping prior to calling FileBrowse().
*                     This function assumes a valid, readable file.
*                 <nTop>, <nLeft>, <nBottom> , <nRight> browse window
*                     coordinates; If not specified, defaults to 0,0,
*                     MaxRow(),MaxCol()
*                 <cWinColor> , <cBoxColor> , <cBarColor>, <cButtonColor>
*                     Clipper color strings; If not specified, defaults to
*                     SetColor() , Setcolor() , "W/N" , "N/W" respectively.
*                 <bApplyText>  An optional code block which will be
*                     applied to each line of text as it is extracted
*                     from the file allowing control codes, etc. to be
*                     removed prior to display
*                 <aDispColors> An optional array of codes and Clipper color
*                     strings to affect the display colors. Each element of
*                     the array contains { cCode , cColorString }. Each
*                     cCode used must begin with a common delimiter and
*                     contain a unique identifier. Example:
*                      { { '~~WR' , 'W+/R' } , { ~~BW , 'B/W' } } where
*                     ~~ is the common delimiter and WR or BW is the
*                     unique identifier portion of each cCode.
*                     Imbed the cCode in the text file to display the text
*                     in the corresponding color. Each color change is
*                     only applicable to the end fo the  current line or
*                     another cCode is encountered; subsequent lines revert
*                     to the default cWinColor. If not specified, all
*                     output will be in the cWinColor.
* Returns         NIL
*
* Description     Pure Clipper text file browser
*
* Calls           NONE
*
* Notes           Beats the pants off of the similar tBrowse implementation
****************************************************************************/
Function FileBrowse(cFileName,nTop,nLeft,nBottom,nRight,cWinColor,;
                    cBoxColor,cBarColor,cButtonColor,bApplyText,aDispColors)
// the browse variables
LOCAL aLines
LOCAL aWinbuff := {savescreen(),setcolor(cWinColor),row(),col(),setcursor(0)}
LOCAL lApplyBlock := (bApplyText # NIL .and. VALTYPE(bApplyText) == "B")
LOCAL lHitBottom := .f.
LOCAL nCurrentLeft := 1
LOCAL nHandle := Fopen( cFileName , 0 )
LOCAL nKey := 0
LOCAL nLastOffSet := 0
LOCAL nLastLine
LOCAL nLeftBrowse := 1
LOCAL nLengthBrowse
LOCAL nMaxRight := 0
LOCAL nSize := Fseek( nHandle , 0 , 2 )
// for the ScrollBar
LOCAL nRow
LOCAL nBarTop
LOCAL nBarBottom
// for the search function
LOCAL cLookText := ''
LOCAL nHighLiteLine := 0
LOCAL nHighLiteOffSet := 0
LOCAL nLastFind
LOCAL nLooklen := 0
LOCAL nTotalFound := 0
// move back to the top of the file
Fseek(nHandle,0)
// set the defaults
DEFAULT nTop TO 0
DEFAULT nLeft TO 0
DEFAULT nBottom TO maxrow()
DEFAULT nRight TO maxcol()
DEFAULT cWinColor TO SetColor()
DEFAULT cBoxColor TO SetColor()
DEFAULT cBarColor TO 'W/N'
DEFAULT cButtonColor TO  'N/W'
// Set other vars; NOTE: if you change the window look at these carefully
nRow = nTop+1
nBarTop = nTop+1
nBarBottom = nBottom-1
nLastLine = nBottom - nTop - 1
nLengthBrowse = (nRight - nLeft - 2 )
// declare and fill the array
aLines = Array( nLastLine )
aFill( aLines , {'',0,0} )
DownFillArray(nHandle,aLines,1,nLastLine,lApplyBlock,bApplyText)
// paint the screen
DispBegin()
Scroll(nTop,nLeft,nBottom,nRight)
Dispbox(nTop,nLeft,nBottom,nRight,,cBoxColor)
ScrollBar(.t.,aLines[1,2],nLastOffSet,nSize,nLastLine,;
          nBarTop,nRight,nBarBottom,@nRow,cBarColor,cButtonColor)
DispEnd()
While .t.
   // reset default values
   nMaxRight := nLastOffSet := 0
   // display the screen
   DispBegin() 
   LineDisp(aLines,nTop,nLeft,nLeftBrowse,nLengthBrowse,;
            @nMaxRight,@nLastOffset,aDispColors,nLastLine,cWinColor)
   If nHighLiteLine # 0  // highlight the search text
      nHighLiteLine = Highlight(cLookText,nHighLiteOffSet-nLeftBrowse+1,;
                      nTop+nHighLiteLine,nLeft+1)
   Endif
   ScrollBar(.f.,aLines[1,2],nLastOffSet,nSize,nLastLine,nBarTop,nRight,;
         nBarBottom,@nRow,cBarColor,cButtonColor) // update the scroll bar
   DispEnd()
   Clear TypeaHead // I like this thing to stop when I stop pressing a key
   do case
   case (nKey := Inkey(0)) == K_ESC
      Exit
   case nKey == K_DOWN
      SkipDown(nHandle,aLines,nLastLIne,1,nSize,lApplyBlock,bApplyText)
   case nKey == K_UP
      SkipUp(nHandle,aLines,lApplyBlock,bApplytext)
   case nKey == K_PGUP
      If !UpFillArray(nHandle,aLines,nLastLine,nSize,lApplyBlock,bApplyText)
         Fseek( nHandle , 0 )
         aFill( aLines , {'',0,0} )
         DownFillArray(nHandle,aLines,1,nLastLine,lApplyBlock,bApplyText)
      Endif
   case nKey == K_PGDN
      SkipDown(nHandle,aLines,nLastLine,nLastLine,nSize,;
               lApplyBlock,bApplyText)
   case nKey == K_LEFT .and. nLeftBrowse > 1
      nLeftBrowse --
   case nKey == K_RIGHT .and. nLeftBrowse < ( nMaxRight - nLengthBrowse )
      nLeftBrowse ++
   case nKey == K_HOME .and. nLeftBrowse > 1
      nLeftBrowse = 1
   case nKey == K_END .and. nLeftBrowse < ( nMaxRight - nLengthBrowse )
      nLeftBrowse = ( nMaxRight - nLengthBrowse )
   case nKey == K_CTRL_PGUP //.and. aLines[1,2] # 0
      Fseek( nHandle , 0 )
      DownFillArray(nHandle,aLines,1,nLastLine,lApplyBlock,bApplyText)
   case nKey == K_CTRL_PGDN
      aLines[1,2] = Fseek( nHandle , 0 , 2 )
      If !UpFillArray(nHandle,aLines,nLastLine,nSize,lApplyBlock,bApplyText)
         Fseek( nHandle , 0 )
         aFill( aLines , {'',0,0} )
         DownFillArray(nHandle,aLines,1,nLastLine,lApplyBlock,bApplyText)
      Endif
   case nKey == K_TAB .and. nLeftBrowse < ( nMaxRight - nLengthBrowse )
      nLeftBrowse = MIN(nLeftBrowse+nLengthBrowse,nLeftBrowse+5)
   case nKey == K_SH_TAB .and. nLeftBrowse > 1
      nLeftBrowse = MAX(0,nLeftBrowse-5)
   case nKey == K_ALT_F .or. nKey == K_ALT_R
      If (nLastOffSet := search(nHandle,If(nKey==K_ALT_F,1,2),;
            @nLastFind,@cLookText,@nLooklen,@nHighLiteOffSet,;
                                     nBottom,@nTotalFound) ) > 0
         DownFillArray(nHandle,aLines,1,nLastLine,@lHitBottom,;
                       lApplyBlock,bApplyText)
         If lHitBottom .or. aScan(aLines,{|x|!Empty(x[1])}) = 0
            // we hit bottom or no text in any line
            aFill( aLines , {'',0,0} )
            aLines[1,2] = Fseek( nHandle , 0 , 2 )
            If !UpFillArray(nHandle,aLines,nLastLine,nSize,;
                            lApplyBlock,bApplyText)
               Fseek( nHandle , 0 )
               aFill( aLines , {'',0,0} )
               // this is not really as redundant as it may first appear
               DownFillArray(nHandle,aLines,1,nLastLine,;
                             lApplyBlock,bApplyText)
            Endif
         Endif
         nHighLiteLine = CheckDisp(cLookText,aLines,nLastOffSet,;
                                 nHighLiteOffSet,@nLeftBrowse,nLengthBrowse)
      Endif
   case SetKey( nKey ) # NIL
      Eval( SetKey( nKey) )
   Endcase
End
fClose( nHandle )
SetColor( aWinbuff[2]) // next 4 lines are my screen restore stuff
RestScreen(0,0,maxrow(),maxcol(),aWinbuff[1])
SetPos(aWinbuff[3],aWinbuff[4])
SetCursor(aWinbuff[5])
RETURN NIL

/****************************************************************************
* Displays the lines of text contained in the array
****************************************************************************/

STATIC Function LineDisp(aLines,nTop,nLeft,nLeftBrowse,nLengthBrowse,;
                        nMaxRight,nLastOffset,aDispColors,nLastLine,;
                        cWinColor)
// The LOCAL vars for Todd's part of this function
LOCAL cColorCode
LOCAL cColorSet
LOCAL cLine
LOCAL cOutPut
LOCAL nColorCode
LOCAL nCodePos
LOCAL nDiff
LOCAL nKey
LOCAL nLength
LOCAL nLine
LOCAL nLinePos

nLeft ++ // this needs to be incremented for both display methods
If aDispColors = NIL // no colors defined so use the standard display method
   Aeval(aLines,{ |x,y|DevPos(nTop+y,nLeft),;
                       DevOut(Pad(Substr(x[1],nLeftBrowse),nLengthBrowse)),;
                       nMaxRight   := Max(nMaxRight,Len(x[1])),;
                       nLastOffSet := Max(nLastOffSet,x[3])})
Else
  /*************************************************************************
  * This is an original work by Todd C. MacDonald and is hereby
  * placed in the public domain.
  *
  * The framework for this portion of the LineDisp function was
  * graciously provided by Todd C. MacDonald. It is included here with
  * modifications to use the established variables and conventions in
  * FileBrowse - Tom Claffy 9-28-93
  **************************************************************************/

  nTop ++
  FOR nLine = 1 TO nLastLine
     setpos( nTop++, nLeft )
     cLine = aLines[ nLine , 1 ]
     nLinePos = 1
     cColorSet = cWinColor
     nLength = LEN( cLine )
     WHILE (COLOR_DELIM $ cLine)
       nCodePos = at( COLOR_DELIM , cLine )
       cOutPut = Left( cLine , nCodePos - 1 )
       // strip the beginning of the line if we are panned right
       // this must be done as a color code may be in this part
       // of the line so we must process the characters but cannot
       // display any characters until we reach the first virtual column
       // of the display window
       If nLinePos < nLeftBrowse
          nDiff = MIN( LEN( cOutPut ) , nLeftBrowse - nLinePos )
          nLinePos += nDiff
          cOutPut = Substr( cOutPut , nDiff + 1 )
       Endif
       // output line up to code position in current color
       devout( cOutPut , cColorSet )
       // strip off text just displayed
       cLine =  substr( cLine, nCodePos )
       // Set new color based on color code.  If the color code
       // is not found in the array, the code is not stripped out
       // (therefore the code itself gets displayed in the output
       // text).  If the code is found but the color value is nil,
       // the color is set to the default.
       cColorCode = left( cLine, CODE_LEN )
       IF ( nColorCode := ascan( aDispColors, ;
          { | a | a[ COLOR_CODE ] == cColorCode } ) ) # 0
          IF ( cColorSet := aDispColors[ nColorCode, COLOR_SET ] ) =  NIL
             cColorSet = cWinColor
          ENDIF
          // strip off color code
          cLine = substr( cLine, CODE_LEN + 1 )
          // keep track of the line length
          nLength -= (CODE_LEN +1)
       ELSE
          // strip off color code prefix
          cLine = substr( cLine, CODE_LEN )
          // keep track of the line length
          nLength -= CODE_LEN
       ENDIF
     END
     // cut to the left column if we are not already there
     If nLinePos < nLeftBrowse
        cLine = Substr( cLine , nLeftBrowse - nLinePos + 1)
     Endif
     // output remainder of line
     devout( Pad( cLine , nLeft + nLengthBrowse - Col() ) , cColorSet )
     // set the system counters
     nMaxRight   = Max(nMaxRight,nLength)
     nLastOffSet = Max(nLastOffSet,aLines[nLine,3])
   NEXT
Endif
RETURN NIL

/***************************************************************************
* Justify the display before displaying the found text
* The find column may be out of view left or right
****************************************************************************/
STATIC Function CheckDisp(cLookText,aLines,nLastOffSet,;
                          nHighLiteOffSet,;
                          nLeftBrowse,nLengthBrowse)
LOCAL nLength := LEN(AllTrim(cLookText))
If nHighLiteOffSet < nLeftbrowse  // the find text is out of scope left
   nLeftBrowse = nHighLiteOffSet
Elseif nLeftBrowse+nHighLiteOffSet+nLength > ;
       nLeftBrowse+nLengthBrowse  // the find text is out of scope right
   nLeftBrowse = (nHighLiteOffSet+nLength-nLengthBrowse )
Endif
RETURN (Ascan(aLines,{ |x| x[2] <= nLastOffSet .and. x[3] > nLastOffSet}))

/***************************************************************************
* Highlight the found text
****************************************************************************/
STATIC Function HighLight(cLookText,nOffSet,nRow,nCol)
LOCAL nLength := LEN(AllTrim(cLookText))
LOCAL cScreen := SAVESCREEN(nRow,nCol+nOffSet-1,;
                            nRow,nCol+nOffSet+nLength-2)
// use this variable to set the highlight color you want to use
LOCAL cChar := If( Chr(7) $ cScreen,Chr(112),Chr(7))
RESTSCREEN(nRow,nCol+nOffSet-1,nRow,nCol+nOffSet+nLength-2,;
   TRANSFORM(cScreen,REPLICATE(("X"+cChar),nLength)))
RETURN 0

/***************************************************************************
* Clean up the line by removing control characters
* and apply the user-defined block if applicable
* cLine is passed to this function by reference
* thus no return value
****************************************************************************/
STATIC Function LineClean( cLine , lApplyBlock , bApplyText )
cLine = Strtran( cLine , Chr(10) , ' ' )   // LF
cLine = StrTran( cLine , Chr(12) , ' ' )   // FF
cLine = StrTran( cLine , Chr(13) , ' ' )   // CR
cLine = StrTran( cLine , Chr(26) , ' ' )   // EOF
If lApplyBlock
   cLine = Eval( bApplyText , cLine )
Endif
RETURN NIL

/****************************************************************************
* Search for line-feed or form-feed mark - return the first offset
* The extraordinary error trapping is included here to prevent
* lock-up when a binary file is browsed, i.e. a loop can be
* caused by the eof mark not being found
****************************************************************************/
STATIC Function FirstEolmark(cBuffer)
LOCAL nFFmark := At(Chr(12),cBuffer)
LOCAL nLFmark := At(Chr(10),cBuffer)
LOCAL nReturn := 0
If nFFmark > 0 .and. nLFmark > 0
   nReturn = MIN( MIN(nFFmark,nLFmark) , MAXBROWSELENGTH )
Elseif nFFmark > 0 .or. nLFmark > 0
   nReturn = MIN( MAX(nFFmark,nLFmark) , MAXBROWSELENGTH )
Elseif LEN( cBuffer ) >= MAXBROWSELENGTH
   nReturn = MAXBROWSELENGTH
Endif
RETURN nReturn
           
/***************************************************************************
* fill the array traversing down the file
****************************************************************************/
STATIC Function DownFillArray(nHandle,aLines,nStart,nEnd,;
                              lApplyBlock,bApplyText,lHitBottom)
LOCAL nBlock := 1024
LOCAL cBuffer
LOCAL cLine
LOCAL nEOL
LOCAL nCounter := nStart - 1
LOCAL nFilePos := Fseek( nHandle , 0 , 1 )
LOCAL nLineLength
LOCAL nLoopCounter := 0
LOCAL nBytesRead
lHitBottom = .f.
// while the array is not full
While nCounter < nEnd
   // reposition to current file position
   Fseek( nHandle , nFilePos , 0 )
   // assign a buffer and read the file
   cBuffer = Space( nBlock )
   if (nBytesRead := Fread( nHandle , @cBuffer , nBlock )) # nBlock
      nLoopCounter ++
   endif
   // check for eof
   If nBytesRead < 1 .or. nLoopCounter > 2
      lHitBottom = .t.
      Exit
   Else
      While nCounter < nEnd .and. (nEOL := FirstEolMark( cBuffer )) # 0
         nCounter ++
         // extract the line
         cLine = Left( cBuffer , nEOL )
         // strip the line from the buffer
         cBuffer = Substr(cBuffer,nEOL+1)
         // save the length
         nLineLength = LEN( cLine )
         // clean it up
         LineClean( @cLine , lApplyBlock , bApplyText )
         // store it in the array
         aLines[nCounter] = { cLine , nFilePos , nFilePos + nLineLength }
         // keep the pointer current
         nFilePos += nLineLength
      End
      // test for eof
      lHitBottom = (nCounter < nEnd)
   Endif
End
RETURN NIL

/***************************************************************************
* add one line to the bottom the array
****************************************************************************/
STATIC Function SkipDown(nHandle,aLines,nLastLine,nNumLines,nSize,;
                         lApplyBlock,bApplyText)
LOCAL lHitBottom := .f.
If aLines[ nLastLine , 3 ] # 0
   // position file to last line offset
   Fseek( nHandle , aLines[ nLastLine , 3 ] , 0 )
   Adel( aLines , 1 )
   aLines[nLastLine] = {'',0,0}
   // get the next line
   DownFillArray(nHandle,aLines,nLastLine+1-nNumLines,nLastLine,;
                 lApplyBlock,bApplyText,@lHitBottom)
   If lHitBottom .or. aScan(aLines,{|x|!Empty(x[1])}) = 0
      // we hit bottom or no text in any line
      aLines[1,2] = Fseek( nHandle , 0 , 2 )
      UpFillArray(nHandle,aLines,nLastLine,nSize,lApplyBlock,bApplyText)
   Endif
Endif
RETURN NIL

/***************************************************************************
* fill the array traversing up ... the tricky one ...
* This function was originally coded with the RAT function
* Tests show the AT func to be about 10 times faster than RAT
* thus the overhead of the aTemp with the AT function as an offset map
****************************************************************************/
STATIC func UpFillArray(nHandle,aLines,nEnd,nSize,lApplyBlock,bApplyText)
LOCAL aOffSets
LOCAL cBuffer
LOCAL cFirstChar
LOCAL cLine := ''
LOCAL nBlock := 1024
LOCAL nCounter := 0
LOCAL nEOL
LOCAL nFilePos := Fseek( nHandle , 0 , 1 )
LOCAL nTempCount
LOCAL lEOF :=  (nSize = nFilePos )
LOCAL lReturn := .t.
While nCounter < nEnd
   // assign some defaults and read the file
   nBlock = Min(nBlock,aLines[1,2])
   nFilePos = aLines[1,2] - nBlock
   Fseek( nHandle , nFilePos , 0 )
   cBuffer = Space( nBlock )
   If Fread( nHandle , @cBuffer , nBlock ) = 0
      Exit
   Else
      If nFilePos = 0
         aOffSets = {1}
      Else
         aOffSets = { }     // discard the first line - it is a fragment
      Endif
      // map the lines into a temp array
      nTempCounter = 0
      While (nEOL := FirstEolMark( Substr( cBuffer , nTempCounter + 1 ))) # 0
         nTempCounter += nEOL
         Aadd( aOffSets , nTempCounter )
      End
      // pick up the last line if eof and it does not end w/ LF CR etc.
      If lEOF .and. nTempCounter < nBlock
         Aadd( aOffSets , nBlock )
      Endif
      nTempCounter = LEN( aOffSets )
      // fill the array
      While nCounter < nEnd .and. nTempCounter > 1
         nCounter ++
         nTempCounter --
         cLine = Substr(cBuffer,aOffSets[nTempCounter]+1)
         // strip the first char if it is a control char
         // going down we don't have this problem as it is at the end and
         // we don't care
         cFirstChar = Left( cLine , 1 )
         If cFirstChar = Chr(10) .or. cFirstChar = Chr(12) .or. ;
            cFirstChar = Chr(13) .or. cFirstChar = Chr(26)
            cLine = Substr( cLine , 2 )
         Endif
         // clean it up
         LineClean( @cLine , lApplyBlock , bApplyText )
         // store the line and it's parameters
         Ains( aLines , 1 )
         aLines[1] = {cLine,;
                      nFilePos+aOffSets[nTempCounter],;
                      nFilePos+aOffSets[nTempCounter+1]}
         // strip the line from the buffer
         cBuffer = Left(cBuffer,aOffSets[nTempCounter])
      End
      // if nCounter < nEnd we ran out of lines
      // return .f. and fill the array from the top
      lReturn = (nCounter = nEnd )
      If nFilePos = 0 
         If aLines[1,2] = 1 // assign BOF status explicitly for the other
            aLines[1,2] = 0 // functions
         Endif
         Exit  // we're done here
      Endif
   Endif
End
RETURN lReturn

/***************************************************************************
* add one line to the top of the array
****************************************************************************/
STATIC func SkipUp(nHandle,aLines,lApplyBlock,bApplyText)
LOCAL nBlock
LOCAL cBuffer
LOCAL cLine := ''
LOCAL lBOF := .f.
LOCAL nEOL
LOCAL nFilePos
LOCAL nLength
If aLines[1,2] #0
   nBlock = Min(512,aLines[1,2])
   nFilePos = aLines[1,2] - nBlock
   lBOF = (nFilePos <= 1 )
   Fseek( nHandle , nFilePos , 0 )
   cBuffer = Space( nBlock )
   If !Fread( nHandle , @cBuffer , nBlock ) = 0
      // get past the first eol mark
      nEOL = MAX( Rat(Chr(12),cBuffer), Rat(Chr(10),cBuffer) )
      If nEOL # 0
         cLine = Right( cBuffer , Len(cBuffer)-nEOL+1 )
         cBuffer = Left(cBuffer,nEOL-1)
      Endif
      // get the last line in the buffer
      nEOL = MAX( Rat(Chr(12),cBuffer), Rat(Chr(10),cBuffer) )
      If nEOL == 0 .and. !lBOF
         nEOL = MIN(nBlock,MAXBROWSELENGTH)
      Elseif LEN(cBuffer) - nEOL > MAXBROWSELENGTH
         nEOL = MAXBROWSELENGTH
      Endif
      // update the file position
      nFilePos += nEol
      // get the line
      cLine = ( Right(cBuffer,Len(cBuffer)-nEOL) + cLine )
      // save the real length of the line in the file
      nLength = LEN( cLine )
      // clean it up
      LineClean( @cLine , lApplyBlock , bApplyText )
      // store the line and it's parameters
      Ains( aLines , 1 )
      aLines[1] = {cLine,nFilePos,nFilePos+nLength}
   Endif
Endif
RETURN NIL

/***************************************************************************
* Display a status bar based on the relative position in the file
* Not 100 % accurate but a fair representation to pacify the mere mortals
****************************************************************************/
STATIC Function ScrollBar(lPaint,nStart,nEnd,nSize,nLastLine,nBarTop,nRight,;
                          nBarBottom,nRow,cBarColor,cButtonColor)
LOCAL nCounter
LOCAL nMiddle
LOCAL nPercent
If lPaint  // this only happens on the very first call
   For nCounter = nBarTop to nBarBottom
      DevPos(nCounter,nRight); DevOut(Chr(177),cBarColor)
   Next
Else // update the button
   // erase the old button - where's the whiteout
   DevPos(nRow,nRight); DevOut(Chr(177),cBarColor)
   If nStart = 0             // figger out the new row
      nRow = nBarTop         // nRow is passed by ref so it will be updated
   Elseif nEnd >= nSize -1
      nRow = nBarBottom
   Else
      nMiddle = nStart + ((nEnd - nStart) / 2 )
      nPercent = (nMiddle/nSize)
      nRow = nBarTop + INT( (nBarBottom - nBarTop) * nPercent )
   Endif
   // display the button
   DevPos(nRow,nRight); DevOut( chr(10),cButtonColor)
Endif
RETURN NIL

/***************************************************************************
* Search Routine By: Phil Barnett  April 3, 1993
* Search and repeat last find
****************************************************************************/
STATIC Function Search(nHandle,nMode,nLastFind,cLookText,nLooklen,;
                       nHighLiteOffSet,nBottom,nTotalFound)
LOCAL cBuffer
LOCAL cSaveIt := savescreen(nBottom,1,nBottom,60)
LOCAL nBytesRead
LOCAL nBlock := 4096  // Bigger is probably faster up to ~10000 bytes
LOCAL nThisOffset
LOCAL nOffset := 0
LOCAL nLoop := 0
LOCAL getlist := {}
LOCAL cMiniBuff
LOCAL nMBsize
LOCAL nEOLat
LOCAL cHoldBack := ''
if nMode == 1     // initiate search (ALT_F)ind
  nTotalFound = 0
  nLastFind = -1
  cLookText = pad(cLookText,25)
  @ nBottom,1 say space(49)
  @ nBottom,2 say 'Enter Search Phrase' get cLookText picture '@K@!'
  SetCursor( If(ReadInsert(),2,1 ))
  read
  SetCursor(0)
  restscreen(nBottom,1,nBottom,60,cSaveIt)
  if lastkey() == 27 .or. empty(cLookText)
    RETURN 0
  endif
  cLookText = upper(alltrim(cLookText))
  nLookLen = len(cLookText)
endif
fseek(nHandle,nLastFind+1,0)  // Position filepointer to starting location
nBytesRead = nBlock          // setup loop entry
do while nBytesRead == nBlock
  // Get and prepare the Character Buffer
  cBuffer = space(nBlock)
  nBytesRead = fread(nHandle,@cBuffer,nBlock)
  if nBytesRead < nBlock
    cBuffer = left(cBuffer,nBytesRead)
  endif
  cBuffer = cHoldBack + upper(cBuffer)
  nThisOffset = at(cLookText,cBuffer)
  if !empty(nThisOffset)
    // position the File Pointer to the find.
    nLastFind += ( nLoop * nBlock ) + nThisOffset - Len( cHoldBack )
    Fseek( nHandle, nLastFind , 0)
    // Now, locate the beginning of the line 
    // ( It might not be in current buffer, so make a new minibuffer )
    nMBsize = min( nLastFind, 512 )
    cMiniBuff = space(nMBsize)
    fseek( nHandle,-nMBsize,1)
    fread(nHandle,@cMiniBuff,nMBsize)
    nEOLat = MAX( Rat(Chr(12),cMiniBuff), Rat(Chr(10),cMiniBuff) )
    if nEOLat > 0
       fseek( nHandle, nEOLat-nMBsize,1)
    endif
    nOffset = fseek(nHandle,0,1)
    nHighLiteOffSet = (nLastfind - nOffSet + 1)
    nTotalFound ++
    // We found one so...
    exit
  endif
  cHoldBack = right(cBuffer,nLookLen - 1)
  nLoop ++
enddo
if nOffset == 0
  @ nBottom,1 say ' ' +Ltrim(Trim(Str(nTotalFound)))+;
                  ' Occurences Found - No More Finds (Press Any Key) '
  Tone(100,1)
  inkey(0)
  restscreen(nBottom,1,nBottom,60,cSaveIt)
endif
RETURN nOffset
