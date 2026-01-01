
 #include       "ctk.ch"

 #define        NAMEPLATE_MSG {;
                    {""                                },;
                    {       "Clipper ToolsKit"         },;
                    {""                                },;
                    {"     MsgBox() usage example     "},;
                    {""                                };
                }


PROC      MAIN

     InitCTK ()

     MsgBox (,,NAMEPLATE_MSG)

     while .t.
          msgbox(,,{;
               {""                                                         },;
               {        "Are you going exit CTK MsgBox() demo? "           },;
               {""                                                         },;
               {"     @ Yes &    @ No &    @ just beep and continue &      ",;
                   {||EOJ()},   {||HE_CONTINUE},    {||Beep()}             },;
               {""                                                         };
          })
     end

 return