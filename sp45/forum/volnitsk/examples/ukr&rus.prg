
#include       "ctk.ch"

#define        NAMEPLATE_MSG {;
          {"                                                "},;
          {               "Clipper ToolsKit"                 },;
          {""                                                },;
          {           "Multi nationals language example"     },;
          {""                                                },;
          {""                                                },;
          {          "Ukranian as basic language"            },;
          {         "Russian as additional language"         },;
          {         "English as system language"             },;
          {""                                                },;
          {                   "Warning!"                     },;
          {""                                                },;
          {       "Ukranian font set must be loaded"         },;
          {""                                                };
  }


PROC      Ukr_rus

local lConfirm   := set (_SET_CONFIRM)   // var edit complited only by Enter
local cString    := SPACE(10)
local nNumber    := 0
local nNumber2   := 0
local dDate      := DATE()
local cString2   := '         '

     InitCTK (LS_UKRANIAN_RUSSIAN, K_F9)
     MsgBox (,,NAMEPLATE_MSG)
     SetKey (K_F10, {||EOJ()})


     set cursor on
     set scoreboard on

     @   1, 0   say Replicate('─', SCR_WIDTH)

     @   5, 0   say "          CONFIRM  Так/Hi : "   get  lConfirm

     @  14, 0   say "                     Текст: "   get  cString
     @  16, 0   say "       Число (вiд 1 до 10): "   get  nNumber  range 1,10
     @  18, 0   say "                Число > 0 : "   get  nNumber2  valid 0 < nNumber2
     @  20, 0   say "           Установiть дату: "   get  dDate

     @  23, 0   say Replicate('─', SCR_WIDTH)
     @  24, 0   say "F10 - вихiд, F9 -  перелюченя мови, Space - переключеня логiчних значень"

	read save

     while .t.

          BEEP({222,1})

          @   3, 55  say "Введенi значення"

          @   5, 55  say  set (_SET_CONFIRM, lConfirm)

          @  14, 55  say  cString
          @  16, 55  say  nNumber
          @  18, 55  say  nNumber2
          @  20, 55  say  dDate
          @  22, 55  say  cString2

		read save
	end

 RETURN