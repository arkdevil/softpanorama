;Demo how to call the SOFT_MENU procedure

setswap 20000
AUTOLIB = "softmenu"

main_menu_choice = ""
WHILE main_menu_choice <> "Leave the system" AND main_menu_choice <> "Esc"

   main_menu_choice = SOFT_MENU(1, 3, 5,   ; level, row, column
   "Advance to 2nd menu",
   "Menu choice 2",                        ;          │ Up to 15 menu
   "Menu choice 3",                        ;          │  Descriptions
   "Leave the system",                     ;        <─┘
   "","","","","","","","","","","",
   "Go the the next menu selection screen",  ;Menu Choice Descriptions
   "Description for choice 2",               ;          │ Up to 15 menu
   "Description for choice 3",               ;          │  Descriptions
   "Leave the system",                       ;        <─┘
   "","","","","","","","","","","",
   32,10,127,                                    ;BoxColor,TextColor,CursorColor
   15,                                           ;Menu Desc Color DescColor
   24)                                           ;Row to put Help
   SWITCH
      CASE main_menu_choice = "Advance to 2nd menu":
         PLAY "Menu1"
   ENDSWITCH
ENDWHILE

RELEASE_MENU_VARS()

