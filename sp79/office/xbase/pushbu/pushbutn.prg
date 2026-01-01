/*-------------------------------------------------------------------------*

             This program was adapted from the public domain work,
                              RADIOBTN.PRG,
                           by Dan Comeau, 1991

                       And the public domain work,
                               PUSHBU.PRG,
                          by Wendy Starbuck, 1992
                      With modifications by Rey Bango

                                 NOTICE
    PUSHBUTN.PRG, PUSHDEMO.CH, and PUSHDEMO.PRG were written by Wendy
    Starbuck and placed into the public domain on 6/12/93.  The accompanying
    PUSHDEMO.LIB was included for demonstration purposes only and all
    copyrights are retained by the author, Wendy Starbuck.

    Mod History:
    05-21-94  Fix kill stack bug and handle various parameter defaults
    05-21-94  Provide vertical display option


*--------------------------------------------------------------------------*

    Functions.:  PushBtnNew            Create push buttons
                 DrawPushButtons       Draw all the push buttons
                 PushBtnReader         Push button custom reader
                 PushBtnKill           Kill the push button stack
                 DispPushButton        Display an individual push button

*--------------------------------------------------------------------------*/

// Include standard headers
#include "pushbutn.ch"                 // Pushbutton headers
#include "box.ch"                      // Box frame constants
#include "inkey.ch"                    // Keypress constants
#include "setcurs.ch"                  // Cursor constants
#include "getexit.ch"                  // Get system constants

// Define program constants
#define HOT_BUTTON             .t.     // The button is in focus
#define COLD_BUTTON            .f.     // The button is inactive
#define ACTIVATE_BTNS          .t.     // Activate buttons, set focus
#define DEACTIVATE_BTNS        .f.     // Deactivate buttons, kill focus
#define BUTTON_PRESSED         .t.     // Button pressed indicator
#define BUTTON_PASSED          .f.     // Button passed over indictor

// Get stack for push buttons
static  aAllButtons := {}


/*-------------------------------------------------------------------------*
    Function..:  PushBtnNew     Initialization for Push Buttons
*--------------------------------------------------------------------------*/

function PushBtnNew( oGet,           ; // Current get object
                     nRow,           ; // Row coordinate
                     nCol,           ; // Column coordinate
                     nReturn,        ; // Return value
                     nChoice,        ; // Starting choice
                     aChoices,       ; // Array of push button names
                     lVertical       ) // Vertical display option

    // Declare work variables
    local  x                           // pointer
    local  y                           // pointer
    local  lInit                       // initialization status indicator
    local  cTrigger                    // button trigger keys
    local  nTotButtons                 // total buttons in array

    // Declare color scheme variables
    local  cColor                      // Window color string
    local  cBackGrnd                   // Window background color
    local  cBtnColor                   // Button background color
    local  cBarColor                   // Background bar color
    local  cHotColor                   // Hot button color
    local  cColColor                   // Cold button color

    // Kill the cursor
    set cursor off

    // Handle defaults
    nChoice    := iif(empty(nChoice), 0, nChoice)
    aChoices   := iif(empty(aChoices), { "NONE" }, aChoices )
    lVertical  := iif(valtype(lVertical) == "L", lVertical, .F. )

    // make sure nChoice is in valid range
    nTotButtons := len( aChoices )
    if nChoice < 1 .or. nChoice > nTotButtons
        nChoice := 1
    endif

    // Create the button color scheme
    cColor     := oGet:ColorSpec
    x          := at("/", cColor)
    cBackGrnd  := substr( cColor, x+1, at(",",cColor)-x )
    cBtnColor  := if( "W" $ cBackGrnd, "BG", "W" )
    cBarColor  := "N/"  + cBackGrnd
    cHotColor  := "W+/" + cBtnColor
    cColColor  := "N/"  + cBtnColor

    // Add choices array to the aAllButtons array
    aAdd( aAllButtons, { oGet:Name, aChoices, lVertical,   ;
                         cBarColor + ";" + cHotColor + ";" + cColColor } )

    // draw the buttons
    DrawPushButtons( nRow, nCol, lVertical,                ;
                     aChoices, nTotButtons, nChoice,       ;
                     cBarColor, cHotColor, cColColor,      ;
                     BUTTON_PASSED, DEACTIVATE_BTNS        )

return NIL


/*-------------------------------------------------------------------------*
    Function..:  DrawPushButtons  Draw push buttons.
*--------------------------------------------------------------------------*/

static function DrawPushButtons(     ;
                        nRow,        ; // Row coordinate
                        nCol,        ; // Column coordinate
                        lVertical,   ; // Vertical display option
                        aChoices,    ; // Array of button names
                        nTotButtons, ; // Total buttons in array
                        nInFocus,    ; // Starting choice
                        cBarColor,   ; // Background bar color
                        cHotColor,   ; // Hot button color
                        cColColor,   ; // Cold button color
                        lBtnPressed, ; // Button pressed or static
                        lActivate    ) // Buttons are active or deselected


    // Declare work variables
    local nActive       := 0           // Active choice
    local nBtnOffset    := 0           // Button offset
    local nPusPopOffset := 0           // Push/Pop offset
    local x             := 0           // counter

    // Handle defaults
    lBtnPressed := if( valtype( lBtnPressed ) == "L", lBtnPressed, .F. )
    lActivate   := if( valtype( lActivate ) == "L", lActivate, .T. )

    // Display all the buttons
    DispBegin()
    for nActive = 1 to nTotButtons

        SetColor( cBarColor )
        if lVertical

            if nInFocus == nActive
                DispPushBtn( nRow, nCol, nBtnOffset, lVertical, ;
                             if( lActivate, HOT_BUTTON, COLD_BUTTON), ;
                             aChoices[nActive], cHotColor, lBtnPressed )
                nPusPopOffset := nBtnOffset
            else
                DispPushBtn( nRow, nCol, nBtnOffset, lVertical, ;
                             COLD_BUTTON, aChoices[nActive], cColColor )
            endif
            nBtnOffset += 3

        else

            if nInFocus == nActive
                DispPushBtn( nRow, nCol, nBtnOffset, lVertical, ;
                             if( lActivate, HOT_BUTTON, COLD_BUTTON), ;
                             aChoices[nActive], cHotColor, lBtnPressed )
                nPusPopOffset := nBtnOffset
            else
                DispPushBtn( nRow, nCol, nBtnOffset, lVertical, ;
                             COLD_BUTTON, aChoices[nActive], cColColor )
            endif
            nBtnOffset += ( len( aChoices[nActive] ) + 4 )

        endif

    next
    DispEnd()

    // Handle pop-out action if the button was pushed
    if lBtnPressed
        Inkey(.2)
        SetColor( cBarColor )
        DispPushBtn( nRow, nCol, nPusPopOffset, lVertical, HOT_BUTTON, ;
                     aChoices[nInFocus], cHotColor, BUTTON_PASSED )
        Inkey(.1)
    endif

return NIL


/*-------------------------------------------------------------------------*
    Function..:  PushBtnReader
*--------------------------------------------------------------------------*/

function PushBtnReader( oGet )

    // Declare work variables
    local aChoices                     // Push button choices
    local nMaxChoices                  // Max number of choices
    local nChoice                      // Button choices (1st one is name of get variable)
    local nOldChoice                   // To save current choice
    local cGetVar                      // Current get variable
    local cSavedScreen                 // To save portion of screen normally showing GET value
    local nSaveCursor                  // Save the current cursor
    local cSaveColor                   // Save the current color
    local cTrigger                     // Button trigger keys
    local lVertical     := .F.         // Vertical diaplay option
    local nKey          := 0           // Key pressed
    local n             := 0           // Temp variable
    local x             := 0           // Temp variable

    // Declare color scheme variables
    local cColor                       // Color string
    local cBarColor                    // Background bar color
    local cHotColor                    // Hot button color
    local cColColor                    // Cold button color

    // Housekeeping
    nSaveCursor:= SetCursor( SC_NONE )
    cSaveColor := SetColor()

 
    // initialize choices
    aChoices   := aAllButtons[ascan(aAllButtons, { |a| a[1] == oGet:Name }),2]
    nChoice    := oGet:VarGet()
    nMaxChoices:= len( aChoices )

    lVertical  := aAllButtons[ascan(aAllButtons, { |a| a[1] == oGet:Name }),3]

    // initialize color scheme
    cColor     := aAllButtons[ascan(aAllButtons, { |a| a[1] == oGet:Name }),4]
    cBarColor  := substr( cColor, 1, at( ";", cColor)-1 )
    cHotColor  := substr( cColor, (x := at(";",cColor)+1), rat(";",cColor)-x )
    cColColor  := substr( cColor, rat(";",cColor)+1 )
    
    // activate the GET for reading
    dispbegin()

    // save the 1 character spot where the GET value is about to be displayed
    cSavedScreen := savescreen( oGet:row, oGet:col, oGet:row, oGet:col )
    oGet:SetFocus()

    // restore the 1 character spot where the GET displayed its value
    restscreen( oGet:row, oGet:col, oGet:row, oGet:col, cSavedScreen )

    // draw the buttons
    DrawPushButtons( oGet:Row, oGet:Col, lVertical,                       ;
                     aChoices, nMaxChoices, nChoice,                      ;
                     cBarColor, cHotColor, cColColor,                     ;
                     BUTTON_PASSED, ACTIVATE_BTNS                         )
    dispend()

    oGet:exitState := GE_NOEXIT
    while ( oGet:exitState == GE_NOEXIT )

        nOldChoice := nChoice      // save "old" choice before movement
        nKey := Inkey(0)           // SWIS lib uses WaitState(0)    
    
        // determine what key was pressed
        do case
        case nKey == K_ESC    ; oGet:ExitState := GE_ESCAPE
        case nKey == K_ENTER  ; oGet:ExitState := GE_ENTER
        case nKey == K_SPACE  ; oGet:ExitState := GE_ENTER
        case nKey == K_UP
             if lVertical          // Vertical display option
                 nChoice := if(nChoice==1,nMaxChoices,nChoice-1)
             else
                 oGet:ExitState := GE_UP
             endif
        case nKey == K_DOWN
             if lVertical
                 nChoice := if(nChoice==nMaxChoices,1,nChoice+1)
             else
                 oGet:ExitState := GE_DOWN
             endif
        case nKey == K_LEFT   ; nChoice := if(nChoice==1,nMaxChoices,nChoice-1)
        case nKey == K_RIGHT  ; nChoice := if(nChoice==nMaxChoices,1,nChoice+1)
        case nKey == K_TAB
            if nChoice == nMaxChoices
                oGet:ExitState := GE_DOWN
            else
                nChoice++
            endif
        case nKey == K_SH_TAB
            if nChoice == 1
                oGet:ExitState := GE_UP
            else
                nChoice--
            endif
        otherwise
            // handle if user pressed a key to select the first letter
            // of a key name
            n := ascan( aChoices,                                         ;
                        { |c| upper( left( alltrim(c),1) ) ==             ;
                              upper( chr(nKey) ) }                        )
            if n > 0
                nChoice := n
                keyboard chr( K_ENTER )
            endif
        endcase

        // check if moved to new push button selection
        if ! nOldChoice == nChoice
            DrawPushButtons( oGet:Row, oGet:Col, lVertical,               ;
                             aChoices, nMaxChoices, nChoice,              ;
                             cBarColor, cHotColor, cColColor,             ;
                             BUTTON_PASSED, ACTIVATE_BTNS                 )
        endif

    enddo
    
    oGet:VarPut( nChoice )
    dispbegin()

    // save the 1 character spot where the GET value is about to be displayed
    cSavedScreen := savescreen( oGet:row, oGet:col, oGet:row, oGet:col )
    oGet:KillFocus()

    // restore the 1 character spot where the GET displayed its value
    restscreen( oGet:row, oGet:col, oGet:row, oGet:col, cSavedScreen )
    dispend()

    if nKey == K_ENTER .or. nKey == K_SPACE
        // If button pushed, then make it look like you pushed the darn thing
        DrawPushButtons( oGet:Row, oGet:Col, lVertical,    ;
                         aChoices, nMaxChoices, nChoice,   ;
                         cBarColor, cHotColor, cColColor,  ;
                         BUTTON_PRESSED, ACTIVATE_BTNS     )
    else
        // otherwise, deselect the buttons
        DrawPushButtons( oGet:Row, oGet:Col, lVertical,    ;
                         aChoices, nMaxChoices, nChoice,   ;
                         cBarColor, cHotColor, cColColor,  ;
                         BUTTON_PASSED, DEACTIVATE_BTNS    )
    endif

    // Housekeeping
    SetCursor( nSaveCursor )
    SetColor( cSaveColor )

return NIL


/*-------------------------------------------------------------------------*
    Function..:  PushBtnKill
*--------------------------------------------------------------------------*/

function PushBtnKill()
    aSize( aAllButtons, len(aAllButtons) - 1 )
return nil


/*-------------------------------------------------------------------------*
    Function..:  DispPushBtn    Button - push button style.
*--------------------------------------------------------------------------*/

static function DispPushBtn( nRow, nCol, nBtnOffset, lVertical, ;
                             lHotButton, cName, cColor, lBtnPressed )

    // Declare work variables
    local  nLen
    local  cPointer1
    local  cPointer2

    // Handle defaults
    lHotButton := if( valtype( lHotButton ) == "L", lHotButton, .F. )
    lBtnPressed:= if( valtype( lBtnPressed ) == "L", lBtnPressed, .F. )
    nLen       := len( cName )
    nCol       := if( lVertical, nCol, nCol + nBtnOffset )
    nRow       := if( lVertical, nRow + nBtnOffset, nRow )
    cColor     := if( cColor == NIL, SetColor(), cColor )
    cPointer1  := if( lHotButton, chr(16), " " )
    cPointer2  := if( lHotButton, chr(17), " " )

    if lBtnPressed
        @ nRow,   nCol   say space( nLen + 3 )
        @ nRow+1, nCol   say space( nLen + 3 )
        SetColor( cColor )
        @ nRow,   nCol+1 say cPointer1 + cName + cPointer2
    else
        @ nRow,   nCol+nLen+2 say "▄"
        @ nRow+1, nCol+1 say Replicate( "▀", nLen + 2 )
        SetColor( cColor )
        @ nRow,   nCol+0 say cPointer1 + cName + cPointer2
    endif

return NIL


/*-------------------------------------------------------------------------*
    Function..:  DispPushBox     Button - box style.
*--------------------------------------------------------------------------*/

static function DispPushBox( nRow, nCol, nBtnOffset, lVertical, ;
                             lHotButton, cName, cColor, lBtnPressed )

    local nLen := Len( cName )

    cColor     := if( cColor == NIL, SetColor(), cColor )
    lBtnPressed:= if( lBtnPressed == NIL, .F., lBtnPressed )
    nCol       := if( lVertical, nCol, nCol + nBtnOffset )
    nRow       := if( lVertical, nRow + nBtnOffset, nRow )

    if lHotButton .and. ! lBtnPressed
        @ nRow+0, nCol+0, nRow+2, nCol+nLen+4 box "┌─╖║╝═╘│"
        SetColor( cColor )
        @ nRow+1, nCol+2  say cName
    else
        @ nRow+0, nCol+0, nRow+2, nCol+nLen+4 box B_SINGLE
        @ nRow+1, nCol+2  say cName
    endif

return NIL


/* EOF: SWISPBTN.PRG -----------------------------------------------------*/
