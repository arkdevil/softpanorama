
 /****
 *  CTK.CH
 *  Clipper  ToolsKit 1.0 beta 2  header file
 *  Copyright (c) 1992 Leonid Volnitsky.  All rights reserved.
 *
 *****/

//        includes -----------------------------------------------------------

 #define _CTK_DEFINED

 #ifndef  K_UP
     #include  "inkey.ch"
 #endif

 #ifndef  _SET_DEFINED
     #include  "set.ch"
 #endif

//        memvars  -----------------------------------------------------

 memvar        xSet
 memvar        GetList

//   xSet indexes ---------------------------------------------------------

 // indexis in xSet for shadow size
 #define  xSHADOW_HEIGHT         (_SET_COUNT+1)
 #define  xSHADOW_WIDTH          (_SET_COUNT+2)

 #define  xKEY_BLOCK             (_SET_COUNT+3)  // SetKey() equivalent
 #define  xFKEY_BLOCK            (_SET_COUNT+4)  // SetKey() + update label bar

 #define  xWORK_AREA             (_SET_COUNT+5)  // coordinates of screen area for SetWorkArea()/DeleteWorkArea()

 #define  xCURSOR                (_SET_COUNT+6)  // cursor of/off state
 #define  xINS_CURSOR            (_SET_COUNT+7)  // cursor shape for ins state
 #define  xOVR_CURSOR            (_SET_COUNT+8)  // cursor shape for ovr state
 #define  xNO_CURSOR             (_SET_COUNT+9)  // cursor shape for off state

//        Get system paramrters--------------------------

 #define  xLANGUAGE              (_SET_COUNT+21)   // current language
 #define  xLANGUAGE_TOGGLE_KEY   (_SET_COUNT+22)   // block used to switch languageses
 #define  xLANGUAGE_TOGGLE_BLOCK (_SET_COUNT+23)   // block used to switch languageses
 #define  xLOGIC_TOGGLE_STR      (_SET_COUNT+24)   // logic Yes keys
 #define  xLOGIC_YES_STR         (_SET_COUNT+25)   // logic Yes keys
 #define  xLOGIC_NO_STR          (_SET_COUNT+26)   // logic No keys
 #define  xKEY_TABLE             (_SET_COUNT+27)   // keyboard layout
 #define  xSC_LANGUAGE           (_SET_COUNT+28)   // scoreboard message of current language
 #define  xSC_INS                (_SET_COUNT+29)  // scoreboard message of Ins state
 #define  xSC_OVR                (_SET_COUNT+30)  // scoreboard message of Ovr state
 #define  xSC_BAD_DATE           (_SET_COUNT+31)  // scoreboard message about bad bate
 #define  xSC_BAD_RANGE          (_SET_COUNT+32)  // scoreboard message about not vlaid range
 #define  xSC_NOT_VALID          (_SET_COUNT+33)  // scoreboard message about not vlaid post block
 #define  xALPHABET_UPPER        (_SET_COUNT+34)  // string uset to create indexis in national languge order
 #define  xALPHABET_LOWER        (_SET_COUNT+35)  // string uset to create indexis in national languge order


//        Beep ------------------------------------------------------

 #define       B_DUMMY        {}
 #define       B_SYSBELL      {333, 9}
 #define       B_TOGGLE       {188, 1}
 #define       B_ERROR        {44, 3}
 #define       B_UPDATE       {888, 1}
 #define       B_DING         {1777, 1}

//        SetList ----------------------------------------------------------

 #define        SL_INDEX      1
 #define        SL_NEW        2
 #define        SL_OLD        3

//        xSet ----------------------------------------------------------
//             sound -----------------------------------------------------
 #define       xSOUND             (_SET_COUNT+49)

 #define            xSYSBELL         1     // <=> ??chr(7)
 #define            xERROR           2     // error ivent
 #define            xWRONG_KEY       3     // wrong key pressed
 #define            xLANGUAGE_TOGGLE 4     // Succesfuly entered

 #define            xGS_ERROR        5     // not valid entered value
 #define            xGS_WRONG_KEY    6     // wrong key pressed for this data type
 #define            xGS_UPDATE       7     // Succesfuly entered
 #define            xGS_DING         8     // Succesfuly entered by typeout
                                           // when Confirm off

//             Colors         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


 #define       xMODE                    (_SET_COUNT+50)
 #define            CO80      1                        // posible xMODE
 #define            MONO      2                        // values


 #define       xCOLOR                   (_SET_COUNT+51)
 #define            xSYSTEM             1
 #define            xBACKGROUND         2
 #define            xMENU               3
 #define            xSTAT               4
 #define            xFKEY_LABEL         5
 #define            xMSGBOX             7
 #define            xMESSAGE            8
 #define            xHELP               9
 #define            xNAME_PLATE         10
 #define            xVERIFY             11
 #define            xINBOX              12
 #define            xSHADOW             13
 #define                 xINTENS        1
 #define                 xPROMPT        xINTENS
 #define                 xGET           xINTENS
 #define                 xUNAVAILABLE   2
 #define                 xHIGHLIGHTED   xINTENS
 #define                 xHEAD          3
 #define                 xFRAME         4
 #define                 xTEXT          5



//        InitCTK ------------------------------------------

 // languges scheme
 #define       LS_SYSTEM                0
 #define       LS_ENGLISH               1
 #define       LS_RUSSIAN               2
 #define       LS_UKRANIAN              3
 #define       LS_UKRANIAN_RUSSIAN      4


//        Get system --------------------

 #command @ <row>, <col> GET <var>                                  ;
                         [PICTURE <pic>]                            ;
                         [VALID <valid>]                            ;
                         [WHEN <when>]                              ;
                         [SEND <msg>]                               ;
                                                                    ;
     => SetPos( <row>, <col> )                                      ;
     ; AAdd(                                                        ;
               GetList,                                             ;
               _GET_( <var>, <(var)>, <pic>, <{valid}>, <{when}> )  ;
          )                                                         ;
     ; GetDisplay(ATail(GetList))                                   ;
     [; ATail(GetList):<msg>]



//             keyboard layout --------------------

 //       ukranian layout
 //       ------------------------------------------------------
 //       original   russian   generated
 //       key        key       key
 //       ------------------------------------------------------
 //       S          Ы         I    49   I
 //       s          ы         i    69   i
 //       '          э         Є    242  ye big
 //       "          Э         є    243  ye small
 //       }          Ъ         Ї    244  yi big   with two dots
 //       ]          ъ         ї    245  yi small with two dots
 //       ------------------------------------------------------

 #define   KB_ENGLISH         '@#$%^&*' + "qwertyuiop[]asdfghjkl;'zxcvbnm,./QWERTYUIOP{}ASDFGHJKL:ZXCVBNM<>?" + '"'
 #define   KB_RUSSIAN         '?/":,.?' + "йцукенгшщзхъфывапролджэячсмитьбюёЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЯЧСМИТЬБЮЁ" + 'Э'
 #define   KB_UPPER_RUSSIAN   '?/":,.?' + "ЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮЁЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЯЧСМИТЬБЮЁ" + 'Э'
 #define   KB_UKRANIAN        '?/":,.?' + "йцукенгшщзхїфiвапролджєячсмитьбюёЙЦУКЕНГШЩЗХЇФIВАПРОЛДЖЯЧСМИТЬБЮЁ" + 'Є'

 #define       UPPER_KEYS "QWERTYUIOPASDFGHJKLZXCVBNMЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮЁ"
 #define       LOWER_KEYS "qwertyuiopasdfghjklzxcvbnmйцукенгшщзхъфывапролджэячсмитьбюё"

 // sorted upper/lower chars for ...

 #define       ALPHABET_UPPER_RUSSIAN  "АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯABCDEFGHIJKLMNOPQRSTUVWXYZ"
 #define       ALPHABET_LOWER_RUSSIAN  "абвгдеёжзийклмнопрстуфхцчшщъыьэюяabcdefghijklmnopqrstuvwxyz"

 #define       ALPHABET_UPPER_UKRANIAN "АБВГДЕЄЁЖЗИIЇЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯABCDEFGHIJKLMNOPQRSTUVWXYZ"
 #define       ALPHABET_LOWER_UKRANIAN "абвгдеєёжзиiїйклмнопрстуфхцчшщъыьэюяabcdefghijklmnopqrstuvwxyz"

 #define       ALPHABET_UPPER_UKRANIAN_RUSSIAN "АБВГДЕЄЁЖЗИIЇЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯABCDEFGHIJKLMNOPQRSTUVWXYZ"
 #define       ALPHABET_LOWER_UKRANIAN_RUSSIAN "абвгдеєёжзиiїйклмнопрстуфхцчшщъыьэюяabcdefghijklmnopqrstuvwxyz"

 #define       UPPER(s)  Translate (s, LOWER_KEYS, UPPER_KEYS)

 #define       LOWER(s)  Translate (s, UPPER_KEYS, LOWER_KEYS)


//             scorebord   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 #define       SCORE_ROW      0
 #define       SCORE_COL      60



//        Window -----------------------------------------------

 //  idexes for Window Structure

 #define       TOP                 1
 #define       LEFT                2
 #define       BOTTOM              3
 #define       RIGHT               4
 #define       SAVE_SCREEN         5
 #define       TOP_SHADOW          6
 #define       LEFT_SHADOW         7
 #define       RIGHT_SHADOW        8
 #define       BOTTOM_SHADOW       9
 #define       W_MAX_WINDOW        9



 // demention array

 #define       D_MAX         2
 #define       D_HEIGHT      1
 #define       D_WIDTH       2


 // location array indexes

 #define       L_LN            1
 #define       L_CL            2
 #define       L_J_VERTICAL    3
 #define       L_J_HORIZONTAL  4
 #define       L_MAX           4


 // posible justication modes

 #define       J_TOP         0
 #define       J_CENTER      1
 #define       J_BOTTOM      2
 #define       J_LEFT        0
 #define       J_RIGHT       2
 #define       J_MAX         2


 // frame array indexes

 #define       F_HEIGHT      1
 #define       F_WIDTH       2
 #define       F_BORDER      3
 #define       F_MAX         3


 // frame border

 #define       FB_NONE       0
 #define       FB_SINGLE     1
 #define       FB_DOUBLE     2
 #define       FB_BIGTITLE   3    // ie title bitwin two singl frame if need
 #define       FB_MAX        3


//        menu   -------------------------------------------
//             Item struct   -------------------------------------------

 #define       MI_NAME             1    // simbolic name displaed in menu
 #define       MI_HANDLE           2    // Code block assotiated with
								// this menu item, by default
								// executed when ENTER was pressed
								// on cur item

 #define       MI_SELECTABLE       3    // is this item selectable ?
 #define       MI_COD              4    // Usualy simbolic cod identifying
								// current menu item,
								// say in database.
 #define       MI_MAX              4

 #define       MH_KEY              1    // menu handles: idx of acFuncHandle
 #define       MH_BLOCK            2




 #define       H_SELECT(block)     {;
				K_SELECT,;
                         {|aItem, nCurItem|;
                              aItem [nCurItem] [MI_SELECTABLE] :=;
                                not aItem [nCurItem] [MI_SELECTABLE],;
                              eval (block, @aItem, @nCurItem),;
                              HE_DROW_SELECTED;
					};
			}


 #define       H_S(QE_Type)    {;
          H_SELECT ({|p, n|;
               p[n][MI_NAME] := ltrim(rtrim(substr (p[n][MI_NAME], 1, len(p[n][MI_NAME])-2))),;
			AddQueryItem (;
				QE_Type,;
				{;
                         p[n][MI_NAME],;
					iif (;
                              p [n][MI_COD] <> nil,;
                              p [n][MI_COD],;
                              p [n][MI_NAME];
					);
				};
			);
		});
	}

//             handles exit codes ------------------------------------

                           // nil - continue normal menu/box execution
 #define    HE_CONTINUE         0 // continue normal menu/box execution
 #define    HE_EXIT             1 // terminate current menu/box
 #define    HE_DROW_SELECTED    2 // use if set of selected items changed
 #define    HE_DROW_ITEMS       3 // use if menu item names changed
 #define    HE_DROW_ALL         4 // use if dimentions of aitem changed

//        Msgbox and PromptBox

 //*Box() aLine indexis
 #define       B_LINE             1
 #define       B_HANDLE           2  // first handle at 2, second at 3, ...

 #define       B_HIGHLIGHT_BEGIN       "@"
 #define       B_HIGHLIGHT_END         "&"


//        my legability, you can delete them ----------------


 #define       not            !
 #define       or             .or.
 #define       and            .and.
 #define       in
 #define       out
 #define       inout

 #define       K_UNDO          K_CTRL_U
 #define       K_SPACE         32

//        screen dimentions --------------------

 #define       MINROW         0
 #define       MINCOL         0
 #define       MAXROW         maxrow()
 #define       MAXCOL         maxcol()
 #define       SCR_HEIGHT     (MAXROW - MINROW+1)
 #define       SCR_WIDTH      (MAXCOL - MINCOL+1)

//        assert ----------------------------------------------------

 #define _ASSERT_DEFINED

 #ifndef NDEBUG
   #command CHKPARM (<exp> [,<msg>]) => _assert(<exp>, <"exp">,"  Bad parameter: "+ if(<.msg.>,<msg>, ''))
   #command ASSERT  (<exp> [,<msg>]) => _assert(<exp>, <"exp">, <msg>)
 #else
   #command _assert(a,b,c,d,f,g)         =>
 #endif // NDEBUG