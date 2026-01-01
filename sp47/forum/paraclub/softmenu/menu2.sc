

menu2_menu_choice = ""
WHILE menu2_menu_choice <> "Return to previous menu" and menu2_menu_choice <> "Esc"
   menu2_menu_choice = SOFT_MENU(3, 10, 11,
   "Clear The Screen",
   "Menu choice 2",
   "Advance to 4th menu",
   "Return to previous menu",
   "","","","","","","","","","","",
   "Clear the scrren, then return here",
   "Description for choice 2",
   "Advance to the next menu",;
   "Return to previous menu",
   "","","","","","","","","","","",
   14,127,10,                                    ;BoxColor,TextColor,CursorColor
   15,                                            ;Menu Desc Color DescColor
   24)                                            ;Row to put Help

   SWITCH
      CASE menu2_menu_choice = "Clear The Screen":
         CLEAR
         @ 0,0 ?? "Press a key"
         x=GETCHAR()
      CASE menu2_menu_choice = "Advance to 4th menu":
         PLAY "Menu3"
   ENDSWITCH
ENDWHILE

