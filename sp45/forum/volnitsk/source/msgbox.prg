
 #include       "ctk.ch"

FUNCTION      MsgBox         (cTitle, nColor, aLine)

     local Choice := PromptBox (;
          cTitle, nColor,;
          {,,J_CENTER,J_CENTER},;       // location in screeeen center
          {2, 4, FB_DOUBLE},;           // frame height, width
          aLine;
     )

 return  Choice


