

menu3_menu_choice = ""
WHILE menu3_menu_choice <> "Return to previous menu" and menu3_menu_choice <> "Esc"
                                                                             ;painted screen
   menu3_menu_choice = SOFT_MENU(4, 6, 24,
   "Clear The Screen",
   "Menu choice 2",
   "Menu choice 3",
   "Return to previous menu",
   "","","","","","","","","","","",
   "Clear the screen, then return here",
   "Description for choice 2",
   "Description for choice 3",;
   "Return to previous menu",
   "","","","","","","","","","","",
   14,127,92,                                    ;BoxColor,TextColor,CursorColor
   15,                                            ;Menu Desc Color DescColor
   24)                                            ;Row to put Help

   SWITCH
      CASE menu3_menu_choice = "Clear The Screen":
         CLEAR
         @ 0,0 ?? "Press a key"
         x=GETCHAR()
   ENDSWITCH
ENDWHILE

