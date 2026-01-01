/*------------------------------------------------------------------------*

    Push Buttons Get Command
    NOTE: Adapted from public domain program written by Dan Comeau, 1991

*-------------------------------------------------------------------------*/

#define  OK_BUTTON           1
#define  YES_NO_BUTTONS      2
#define  QUIT_RETRY_DEFAULT  3

#command @ <row>, <col>  GET <var>                                        ;
                        [COLOR <color>]                                   ;
                        [SEND <msg>]                                      ;
                        [START AT <start>]                                ;
                        [<vertical: VERTICAL>]                            ;
                         WITH PUSHBUTTONS <buttons>                       ;
         => SetPos( <row>, <col> )                                        ;
          ; aAdd( GetList, _GET_( <var>, <(var)>, "9" ) )                 ;
         [; aTail(GetList):colorDisp(<color>)]                            ;
         [; aTail(GetList):<msg>]                                         ;
          ; PushBtnNew( aTail(getlist), <row>, <col>, <var>, <start>,     ;
                        <buttons>, <.vertical.> )                         ;
          ; aTail(getlist):reader := { |get| PushBtnReader( get ) }


/*------------------------------------------------------------------------*

    Radio Button Get Command
    NOTE: Adapted from public domain program written by Dan Comeau, 1991
    NOTE: This adaptation includes options which do not comply with the 
    latest release of RADIOBTN.PRG. See RADIOB.ZIP in Library 1.

*-------------------------------------------------------------------------*/

#command @ <row>, <col> [SAY <sayxpr>]                                    ;
                         GET <var>                                        ;
                        [COLOR <color>]                                   ;
                        [WHEN <when>]                                     ;
                        [SEND <msg>]                                      ;
                         WITH RADIOBUTTONS <buttons>                      ;
                        [<horiz: HORIZONTAL>]                             ;
                        [<nobox: NOBOX>]                                  ;
                        [<double: DOUBLE>]                                ;
                        [<tab2kill: TAB2KILL>]                            ;
         => SetPos( <row>, <col> )                                        ;
          ; aAdd( GetList, _GET_( <var>, <(var)>, "9",, <{when}> ) )      ;
         [; aTail(GetList):colorDisp(<color>)]                            ;
         [; aTail(GetList):<msg>]                                         ;
          ; RadioBtnNew( aTail(getlist), <{when}>,                        ;
                        <row>, <col>, <sayxpr>, <var>,                    ;
                        <buttons>, <.nobox.>, <.double.>, <.horiz.> )     ;
          ; aTail(getlist):reader := { |get| RadioBtnReader( get,         ;
                        <.nobox.>, <.horiz.>, <.tab2kill.>, <sayxpr> ) }
   

/*------------------------------------------------------------------------*
    Windows Constants & Commands
*-------------------------------------------------------------------------*/

// Win_Create() defaults
#define  WIN_DFLT_TOP        0
#define  WIN_DFLT_LFT        0
#define  WIN_DFLT_BOT        MaxRow()
#define  WIN_DFLT_RGT        MaxCol()
#define  WIN_DFLT_COLOR      ColorSet(COL_WIND_STD)
#define  WIN_DFLT_TYPE       "W"
#define  WIN_DFLT_SHADOW     7
#define  WIN_DFLT_ZOOMER     .T.
#define  WIN_DFLT_SPEEDER    20
#define  WIN_DFLT_TITLE_COL  "N/W+*"   // Requires SetBlink(.F.)
#define  WIN_DFLT_TITLE_MON  "N/W"
#define  WIN_DFLT_CON_MENU   "W"
#define  WIN_DFLT_HOR_MENU   ""
#define  WIN_DFLT_VER_MENU   ""
#define  WIN_DFLT_EXIT_BLK   "{ || Win_Alert() }"
#define  WIN_DUMB_WINDOW     "X"

// Simulate '@...SAY' in a window
#xcommand @ <r>, <c> WSAY <t> => Win_Say( <r>, <c>, <t> )

// Simulate '@...GET' in a window
#xcommand @ <r>, <c> WGET <v> [<list,...>]  => ;
          @ Win_Row( <r> ), Win_Col( <c> ) get <v> [<list>]

// Simulate '@ t, l TO b, r' in a window
#xcommand @ <t>, <l> WTO <b>, <r> => ;
          @ Win_Row( <t> ), Win_Col( <l> ) TO Win_Row( <b> ), Win_Col( <r> )


/*-------------------------------------------------------------------------*
    Color System Constants.
*--------------------------------------------------------------------------*/

// Abbreviate color constants, type WINDOW
#define  COL_WIND_STD        4,1
#define  COL_WIND_BOLD       4,2
#define  COL_WIND_TEXT       4,3
#define  COL_WIND_SEL        4,4
#define  COL_WIND_UNSEL      4,5


/*------------------------------------------------------------------------*
    Sounds Constants
*-------------------------------------------------------------------------*/

#define  SOUND_UPTONE        1         // "Dootle, Doot"
#define  SOUND_DOWNTONE      2         // "Doodle, Dude"
#define  SOUND_ALERT         3         // "Dootle, Dootle, Doot"
#define  SOUND_BEEPER        4         // "Dee, Dee, Dee"
#define  SOUND_PROCESSING    5         // "Duuu, Duuu, Duuu"
#define  SOUND_RASPBERRY     6         // "BLAAHHH"


/*------------------------------------------------------------------------*
    Miscelaneous Definitions
*-------------------------------------------------------------------------*/

// Window frame sting
#define  B_WINDOW            "█▀███▄██"
