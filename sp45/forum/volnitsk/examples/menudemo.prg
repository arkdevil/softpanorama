
#include       "CTK.CH"

#define        NAMEPLATE_MSG {;
                    {"                               "},;
                    {      "Clipper ToolsKit"         },;
                    {""                               },;
                    {      "Menu() usage example "    },;
                    {""                               };
                }


 static lSound := .t.               // some logic flag we must to toggle


PROC      MAIN
     local aItem := {}

     InitCTK ()
     set bell on

     MsgBox (,,NAMEPLATE_MSG)


     aadd (aItem, {;
          ' Display message     ',;
          {||MsgBox (, xVERIFY, {{" Selected Item One "}})};
	})

     aadd (aItem, {;
          ' Beep exaple ',;
          {||beep({222,2,444,2,666,2,888,2,1111,2}, lSound)};
	})

     aadd (aItem, {;
          ' Sound           '+ if(lSound, ' On', 'Off'),;
          {|aItem, nCurItem| ToggleHandle(aItem, nCurItem, @lSound)};
	})

     aadd (aItem, {;
          ' Submenu ...  ',;
          {|| submenu()};
	})

     aadd (aItem, {;
          ' Exit         ',;
          {|| EOJ()};
	})

     menu (,,{0,0},, aItem)


     EOJ ()

 return



FUNCTION      ToggleHandle(aItem, nCurItem)

     LOCAL  ItemNameLen := len (aItem[nCurItem][MI_NAME])
     LOCAL  OnOffMsg

     lSound   := if (lSound, .f., .t.)
     OnOffMsg  := if (lSound, " On", "Off")
     aItem[nCurItem][MI_NAME] :=;
          substr (aItem[nCurItem][MI_NAME], 1, ItemNameLen - 3) + OnOffMsg

 RETURN  HE_DROW_ITEMS


func  submenu()

    MENU (,,,,{;
     {' submenu  beep 111 ', {||beep({111,2}, lSound)} },;
     {' submenu  beep 222 ', {||beep({222,2}, lSound)} },;
     {' submenu  beep 333 ', {||beep({333,2}, lSound)} },;
     {' submenu  beep 444 ', {||beep({444,2}, lSound)} },;
     {' submenu  beep 555 ', {||beep({555,2}, lSound)} },;
     {' submenu  beep 666 ', {||beep({666,2}, lSound)} },;
     {' submenu  beep 777 ', {||beep({777,2}, lSound)} },;
     {' submenu  beep 888 ', {||beep({888,2}, lSound)} },;
     {' submenu  beep 999 ', {||beep({999,2}, lSound)} };
    })

return  nil