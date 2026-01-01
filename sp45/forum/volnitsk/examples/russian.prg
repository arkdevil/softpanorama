
#include       "ctk.ch"

#define        NAMEPLATE_MSG {;
                    {""                                      },;
                    {          "Clipper ToolsKit"            },;
                    {""                                      },;
                    {"    Russian languge scheme example    "},;
                    {""                                      };
                }


PROC      Russian

local lConfirm   := set (_SET_CONFIRM)   // var edit complited only by Enter
local lEscape    := set (_SET_ESCAPE)    // var edit can be aborted by Esc
local lScoreBoard:= set (_SET_SCOREBOARD)// display status info
local lExit      := set (_SET_EXIT)      // UpArrow/DownArrow can complit READ
local cString    := SPACE(10)
local nNumber    := 0
local nNumber2   := 0
local dDate      := DATE()
local cString2   := '         '

     InitCTK (LS_RUSSIAN, K_F9)
     MsgBox (,,NAMEPLATE_MSG)
     SetKey (K_F10, {||EOJ()})

     set cursor on
     set scoreboard on

     @   1, 0   say Replicate('─', SCR_WIDTH)

     @   5, 0   say "  Установка SET CONFIRM   : "   get  lConfirm
     @   7, 0   say "  Установка SET ESC       : "   get  lEscape
     @   9, 0   say "  Установка SET SCOREBOARD: "   get  lScoreBoard
     @  11, 0   say "  Установка SET READEXIT  : "   get  lExit

     @  14, 0   say "             Введите текст: "   get  cString
     @  16, 0   say "Введите число (от 1 до 10): "   get  nNumber  range 1,10
     @  18, 0   say "Введите число > 0         : "   get  nNumber2  valid 0 < nNumber2
     @  20, 0   say "              Введите дату: "   get  dDate
     @  22, 0   say "Введите по шаблону XXX,###: "   get  cString2 picture 'XXX,###'

     @  23, 0   say Replicate('─', SCR_WIDTH)
     @  24, 0   say "F10 - выход, F9 -  перелючение языка,  Space - переключение логических значений"

	read save

     while .t.

          BEEP({222,1})

          @   3, 55  say "Введенные значения"

          @   5, 55  say  set (_SET_CONFIRM, lConfirm)
          @   7, 55  say  set (_SET_ESCAPE, lEscape)
          @   9, 55  say  set (_SET_SCOREBOARD, lScoreBoard)
          @  11, 55  say  set (_SET_EXIT)

          @  14, 55  say  cString
          @  16, 55  say  nNumber
          @  18, 55  say  nNumber2
          @  20, 55  say  dDate
          @  22, 55  say  cString2

		read save
	end

 RETURN