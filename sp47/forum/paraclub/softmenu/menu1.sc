
menu1_menu_choice = ""
WHILE menu1_menu_choice <> "Return to previous menu" and menu1_menu_choice <> "Esc"

   menu1_menu_choice = SOFT_MENU(2, 7, 13,
   "Menu choice 1",
   "Advance to 3rd menu",
   "Menu choice 3",
   "Return to previous menu",
   "","","","","","","","","","","",
   "Description for choice 1",
   "Advance to next menu",
   "Description for choice 3",;
   "Return to previous menu",
   "","","","","","","","","","","",
   95,58,72,                                    ;BoxColor,TextColor,CursorColor
   15,                                          ;Menu Desc Color DescColor
   24)                                          ;Row to put Help

   SWITCH
      CASE menu1_menu_choice = "Advance to 3rd menu":
         PLAY "menu2"
   ENDSWITCH
ENDWHILE

