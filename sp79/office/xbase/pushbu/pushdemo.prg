/*-------------------------------------------------------------------------*

    Program...: PUSHDEMO.PRG    PUSHBUTTON DEMO PROGRAM
    Date......: June 12, 1993
    Author....: Wendy Starbuck

    Modified..: May 21, 1994    Vertical & norizontal buttons

    Notes.....: This demo program contains windows (win), color and
                other routines from my toolkit.  It is assumed that you
                already have similar functions in your toolkit.
                 
*--------------------------------------------------------------------------*/


// Include Standard Headers
#include "pushbutn.ch"                 // Pushbutton headers
#include "inkey.ch"                    // Keypress constants

// Define Program Actions
#define  INITIALIZATION       1
#define  OPEN_WINDOW          2
#define  ENTER_UPDATE_DATA    3
#define  VERTICAL_TEST        4
#define  HORIZONTAL_TEST      5
#define  END_OF_JOB           6


// Declare public variables
memvar GetList


function Main()


    // Declare control variables
    local  lContinue    := .T.         // Continuation status indicator
    local  nAction      := 1           // Program action pointer
    local  nChoice
    local  cFileFrom
    local  cFileTo
    local  nFileType
    local  nFileMethod
    local  cGetColor

    // Housekeeping
    SaveEnviron()                      // This function simply save the
                                       // screen, cursor, etc.

    // Program control loop
    while lContinue

        do case
        case nAction == INITIALIZATION

            set scoreboard off
            cls
            cGetColor := substr( ( cGetColor := ColorSet(COL_WIND_STD)),;
                                 1, (at(",",cGetColor)-1 ) )
            SetBlink(.F.)  // For high intensity background colors
            cFileFrom   := "C:\DATA" + space(23)
            cFileTo     := "C:\BACKUP" + space(21)
            nFileType   := 1
            nFileMethod := 1
            nChoice     := 1
            nAction     := OPEN_WINDOW

        case nAction == OPEN_WINDOW

            // Create an instance of a window
            Win_Create( 4, 10, 20, 69, ColorSet(COL_WIND_STD), WIN_DUMB_WINDOW )
            Win_Title( "Wendy Starbuck's Pushbuttons" )
            ColorChg( COL_WIND_STD )
            @ 3,  3 WTO  6, 56
            @ 7,  3 WTO 11, 29
            @ 7, 30 WTO 11, 56
            @ 4,  6 WSAY "From Directory.:"
            @ 5,  6 WSAY "To Directory...:"
            ColorChg( COL_WIND_TEXT )
            @ 3, 27 WSAY "From/To"
            @ 7, 10 WSAY "Selection 1"
            @ 7, 36 WSAY "Selection 2"
            nAction := ENTER_UPDATE_DATA

        case nAction == ENTER_UPDATE_DATA

            // Place a message on the message bar and define gets
            Win_Mssg( " SPACE=Select, ESC=Exit " )

            // Window get from my toolkit 
            @ 4, 23 WGET cFileFrom picture "@!"

            // Regular get
            @ 9, 33 GET cFileTo   picture "@!"

            /*
               Sample Radiobuttons from RADIOBTN.PRG by Dan Comeau
            */
            @ 8, 06 WGET nFileType                                        ;
                         color cGetColor                                  ;
                         with radiobuttons { "Application files",         ;
                                             "Database files",            ;
                                             "All files"          } nobox
            @ 8, 32 WGET nFileMethod                                      ;
                         color cGetColor                                  ;
                         with radiobuttons { "Overwrite files",           ;
                                             "Save files first"   } nobox

            /**************************************************************

               Sample Pushbuttons from PUSHBUTN.PRG by Wendy Starbuck

               One or more button or sets of buttons may be written
               into a get list.  This sample uses WGET to position the
               line within a window, however a regular GET follows the
               same syntax.

            ***************************************************************/
            @13, 07 WGET nChoice                                          ;
                         color ColorSet( COL_WIND_STD )                   ; 
                         start at nChoice                                 ;
                         with pushbuttons { "  Vertical  ",               ;
                                            " Horizontal ",               ;
                                            "    Quit    "  }
            set cursor on
            read
            set cursor off

            // Kill buttons
            RadioBtnKill()  // Always kill buttons or wierd things happen
            PushBtnKill()

            // Handle keypresses
            do case
            // Permit enter or spacebar to execute the buttons
            case LastKey() == K_ENTER .or. ;
                 LastKey() == K_SPACE
                    // Handle button choices
                    do case
                    case nChoice == 1 ; nAction := VERTICAL_TEST
                    case nChoice == 2 ; nAction := HORIZONTAL_TEST
                    case nChoice == 3 ; nAction := END_OF_JOB
                    endcase
            case LastKey() == K_ESC
                nAction := END_OF_JOB
            endcase

        case nAction == VERTICAL_TEST

            VerticalButtons()
            nAction := ENTER_UPDATE_DATA

        case nAction == HORIZONTAL_TEST

            HorizontalButtons()
            nAction := ENTER_UPDATE_DATA

        case nAction == END_OF_JOB
            Win_Kill()
            lContinue := .F.
   
        endcase

    end

    // Housekeeping
    RestEnviron()                      // This function restores screen,
                                       // cursor, etc.


return NIL


/*-------------------------------------------------------------------------*
    Function..:  VerticalButtons 
*--------------------------------------------------------------------------*/

function VerticalButtons()

   // Declare work variables
   local  nChoice := 1

   // Save the environment and current get list
   SaveEnviron()
   SaveGetz()     // This function simply save the get list

   // Create a window to display vertical buttons
   Win_Create( 7, 25, 17, 54, ColorSet(COL_WIND_STD), WIN_DUMB_WINDOW )
   Win_Title( "Test Vertical Buttons" )
   ColorChg( COL_WIND_STD )

   /**********************************************************************

       This sample uses the regular get

   ***********************************************************************/
   @ 09, 33 GET nChoice                         ;
            color ColorSet( COL_WIND_STD )      ; 
            VERTICAL                            ;
            with pushbuttons { " Vert Test 1 ", ;
                               " Vert Test 2 ", ;
                               " Vert Test 3 "  }

   set cursor on
   read
   set cursor off


   // Kill buttons
   PushBtnKill()
   Win_Kill()
   RestGetz()     // Rest the get list
   RestEnviron()

return NIL


/*-------------------------------------------------------------------------*
    Function..:  HorizontalButtons 
*--------------------------------------------------------------------------*/

function HorizontalButtons()

   // Declare work variables
   local  nChoice := 1

   // Save the environment and current get list
   SaveEnviron()
   SaveGetz()     // This function simply save the get list

   // Create a window to display vertical buttons
   Win_Create(  9, 17, 16, 62, ColorSet(COL_WIND_STD), WIN_DUMB_WINDOW )
   Win_Title( "Test Vertical Buttons" )
   ColorChg( COL_WIND_STD )

   /**********************************************************************

       This sample uses the regular get

   ***********************************************************************/
   @ 03, 04 WGET nChoice                        ;
            color ColorSet( COL_WIND_STD )      ; 
            with pushbuttons { " Horiz 1 ",     ;
                               " Horiz 2 ",     ;
                               " Horiz 3 "      }

   set cursor on
   read
   set cursor off


   // Kill buttons
   PushBtnKill()
   Win_Kill()
   RestGetz()     // Rest the get list
   RestEnviron()

return NIL


/* EOF: PUSHDEMO.PRG ------------------------------------------------------*/
