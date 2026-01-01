
#include       "ctk.ch"

#define        NAMEPLATE_MSG {;
                    {"                               "},;
                    {"       Clipper ToolsKit        "},;
                    {"                               "},;
                    {"     Get system extentions     "},;
                    {"                               "};
                }


PROC      GetDemo

local lConfirm   := set (_SET_CONFIRM)   // var edit complited only by Enter
local lEscape    := set (_SET_ESCAPE)    // var edit can be aborted by Esc
local lScoreBoard:= set (_SET_SCOREBOARD)// display status info
local lExit      := set (_SET_EXIT)      // UpArrow/DownArrow can complit READ
local cString    := SPACE(10)
local nNumber    := 0
local nNumber2   := 0
local dDate      := DATE()
local cString2   := '         '

     InitCTK (LS_ENGLISH, K_F9)
     MsgBox (,,NAMEPLATE_MSG)
     SetKey (K_F10, {||EOJ()})

     set cursor on
     set scoreboard on

     @   1, 0   say Replicate('─', SCR_WIDTH)

     @   5, 0   say "              Set CONFIRM : "   get  lConfirm picture 'Y'
     @   7, 0   say "               Set ESCAPE : "   get  lEscape
     @   9, 0   say "           Set SCOREBOARD : "   get  lScoreBoard
     @  11, 0   say "             Set READEXIT : "   get  lExit

     @  14, 0   say "            Enter any text: "   get  cString
     @  16, 0   say "Enter number in 1-10 range: "   get  nNumber  range 1,10
     @  18, 0   say "        Enter number > 0  : "   get  nNumber2  valid 0 < nNumber2
     @  20, 0   say "                Enter date: "   get  dDate
     @  22, 0   say "  Enter by picture XXX,###: "   get  cString2 picture 'XXX,###'

     @  23, 0   say Replicate('─', SCR_WIDTH)
     @  24, 0   say "Press F10 to quit, Space to toggle logic values"

	read save

     while .t.

          BEEP({222,1})

          @   3, 55  say "New values"

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