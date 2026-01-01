macro DVMENU FROM ALL  TRANS  {
/* ******************************************************************************
  К.Е.Г. - обеспеч.совм. по F2-10 03.07.91-15.02 -  MULTI-EDIT MACRO
                                  15.06.92-18:53 - конвертировано by SRCCONV
NAME:  DVMENU (Dynamic Vertical Menu)

DESCRIPTION:  This is a general purpose vertical menu generator that creates
a box just the right size to fit the menu, and returns both the number of the
menu element that was picked, and the string of the menu element in Return_Int
and Return_Str respectively.  The menu is scrollable if the menu is larger than
will fit on the screen.
You must initialize global variables with the menu strings.  If one global
will not hold the entire menu, use as many as you wish.  The format for the
global variable names is:
	Name1
	Name2
	Name3
	etc.
Where name is any name you wish, which is supplied to the program via a
parameter called Menu_Prefix.  The amount of globals is supplied via the /#=
parameter.
Although, for the sake of compatibility, the format of each menu string is
identical to that expected for V_MENU and H_MENU, the 2 character help strings
are not actually used.  Instead you must provide the 2 character help string
via the /H= parameter.

This menu does not have the "Press the highlighted character to select" feature,
however, there is an incremental search feature which, if an alphanumeric
character is pressed, it will invoke and all subsequent characters will be
appended to the search expression.  Pressing the backspace will right-truncate
the search expression.

 Parameters expected:
  /P=     Menu_Prefix   string   the "prefix" of the 3 global variables
                                               defining the 3 menu strings for the
                                               vertical menu
  /H=     Help_Str      string   the 2 character help string for prompts
  /T=     Title         string   the title of the box
  /S=     Choice_Str    string   the string of the defualt selection
  /SN=                  integer  instead of using /S= for default, use
                                                this.
  /X=     Menu_X        integer  the upper left X coordinate of the box
  /Y=     Menu_Y        integer  the upper left Y coordinate of the box
  /B=     Make_Box      integer  1=create a box 0=don''t
  /K=     Box_Kill      integer  1=kill the box before exiting 0=don''t
  /O=     Menu_Modify   integer  1=display modify choice 0=don''t
  /C=     Menu_Create   integer  1=display create choice 0=don''t
  /CT=    Create_Title  string   If present, will replace the defalult
                                                title on the create box prompt.
  /D=     Menu_Delete   integer  1=display delete choice 0=don''t
  /MH=                                      Menu Height override
  /#=     Menu_Index    integer  The number of globals used for menu
  /W=     Max_Width     integer  The maximum allowable string length
                                               for when a user adds a menu item.
  /F2-10=                        Support for function key labels F: 2 - 10
* /DF2-10=                       -- ""-- Fxx + текст в TOP-EVENT
  /PRE=                 char     This one was created primarily for the
                                                 macro EXTENS.  If present, and the user
                                                 creates a new menu item, the item he
                                                 enters MUST be preceeded by the defined
                                                 character.  In EXTENS, the extension menu
                                                 items must be preceeded by a period(.).
  /U=                   integer  1=Force upper case on menu item
                                                 additions.  0= Normal.
  /EC=                  integer  1=exit this macro upon addition of a new
                                                 menu item.  Primarily intended for
                                                 situations where processing other than
                                                 merely adding to the menu it''self is
                                                 neccesary.
  /ED=                  integer  1=exit this macro upon deletion of a menu
                                                 item. Primarily intended for situations
                                                 where processing other than merely
                                                 deleting from the menu it''self is
                                                 neccesary.
  /ND=                  string   A series of strings, separated by spaces,
                                                 that tell DVMENU to disallow deletion of
                                                 the contained strings.  Only valid and
                                                 neccesary if /D=1
  /NM=                  string   A series of strings, separated by spaces,
                                                 that tell DVMENU to disallow modification
                                                 of the contained strings.  Only valid and
                                                 neccesary if /O=1
  /NR=                  integer   No rebuild.  If 1, then DVMENU will not
                                                 alter the global menu strings in the event
                                                 of a create or delete.
  /I=                    string   A string expression to preceed the
                                                 incremental search string.  Under normal
                                                 circumstances, it should be % to match
                                                 the beginning of line.
  /WIN=nn                The window # to use if we do NOT want
                                                 a window created.
  /WW=nn                 window width  Desired width only active when using
                                                 /WIN.  If not present, /W will be used
                                                 instead.

  /OCPG=                 One Choice Per Global -    When adding or deleting from
                                                 a  menu, there will be only one menu
                                                 choice per global string and the help
                                                 index will not be appended to each choice.

  /ROW=                  Init_Row      This one is currently only used for KEYMAP.
                                                 Used to pass a row number to highlite on
                                                 recursive calls to DVMENU so that the menu
                                                 doesn''t shift positions.
 ***********
  /EV#=n        Number of events.        14.06.91-15.34
  /EV=str       Global string prefix for events (не надо использовать ''@EV..#'')
                   The event globals are cleared upon exit.
                   The event string format is as follows:
                            /T=str   title
                            /K1=n    Keycode 1
                            /K2=n    Keycode 2
                            /R=n     Result code ( лучше от -11 и дальше в -)
                            /ND=1    No display
                            /LL=1    Put event on bottom line of window
                        ?   /KC=<..> текст <KEY> в EVENT
 ***********

  Returns                Return_Int       0 = Escape was pressed.
                                          1 = Return was pressed.
                                          2 = A menu item was added(only if /EC=1).
                                          3 = A menu item was deleted(only if /ED=1).
                                          4 = Modify item was selected.
                                          5 = Add item was selected.
                                         -2:-10 =F2-F10 нажаты (при /Fnn= или /DFnn=).
                         Return_Str    If Return_Int = 0, = /S=.
                                          If Return_Int = 1, = The selected item.
                                          If Return_Int = 2, = The added item.
                                          If Return_Int = 3, = The deleted item.
                                          If Return_Int = 4, = The selected item.
                                          If Return_Int < 0, = The selected item.

							 (C) Copyright 1989 by American Cybernetics, Inc.
****************************************************************************** */
   str Menu_Prefix[19],Choice_Str[77],Temp_String
         ,Help_Str[40],Create_Title[77]
         , Event_Str[20]
         , e_event_str[20];            /* Внешние EVENT-s = имя Global-      */

   int Temp_Integer,jx,jy,Make_Box,Menu_X,Menu_Y,Choice_Int,Temp_Choice,
					Active_Window,Menu_Window,Temp_Refresh,Temp_Ignore_Case,Temp_Messages,
					Temp_Reg_Exp_Stat,Temp_Explosions,Menu_Index,Menu_Mode,Menu_Width,
					Skip_Count,Temp_Insert_Mode,Menu_Changed,skip_win,temp_mode,
               Extra_Index,OCPG,No_Choices,Ev_Count
               ,e_ev_count = 0 ;       /* Внешние EVENT-s = кол-во Global    */

   char Temp_Char;

	Set_Global_Int('MENU_LEVEL', Global_Int('MENU_LEVEL') + 1);

   Temp_Refresh = Refresh;
   Refresh = False;

	Push_Labels;
   Menu_Changed = False;
   No_Choices = False;
   Temp_Messages = Messages;
   Temp_Insert_Mode = Insert_Mode;
   Insert_Mode = True;
   Temp_Explosions = Explosions;
   Explosions = False;
   Menu_Prefix = Parse_Str('/P=',MParm_Str);
   Help_Str = Parse_Str('/H=',MParm_Str);
   Choice_Str = Parse_Str('/S=',MParm_Str);
   OCPG = Parse_Int('/OCPG=',MParm_Str);
   Menu_X = Parse_Int('/X=',MParm_Str);
   Menu_Y = Parse_Int('/Y=',MParm_Str);
   menu_width = Parse_Int('/WW=',MParm_Str);
   Make_Box = Parse_Int('/B=',MParm_Str);
   Active_Window = Cur_Window;
   Menu_Window = 0;
   temp_mode = mode;
   mode = edit;
   Temp_Ignore_Case = Ignore_Case;
   Ignore_Case = True;
   Temp_Reg_Exp_Stat = Reg_Exp_Stat;
   Reg_Exp_Stat = True;
   Menu_Index = Parse_Int('/#=',MParm_Str) + 1;
   if(  (Menu_Index < 1)  ) {
      Menu_Index = 4;
   };
   Menu_Mode = 0;

/* if a window is already defined then skip the build process */
   skip_win = false;
   if(  parse_int( '/WIN=', mparm_str) != 0  ) {
      skip_win = true;
      menu_window = parse_int( '/WIN=', mparm_str);
		switch_window( menu_window );
		eof;
      if(  c_col != 1  ) {
			down;
      };
   } else {
		Switch_Window(Window_Count);
		Create_Window;
   };
   window_attr = window_attr | $96;
   Menu_Window = Cur_Window;
   Extra_Index = 0;
   Temp_Integer = 0;

/* create the additional menu choices as outlined in the passed parameter string */
   if(  (Parse_Int('/C=',MParm_Str))  ) {
		++ Extra_Index;
      Temp_Integer = 15;
   };
   if(  (Parse_Int('/D=',MParm_Str))  ) {
		++ Extra_Index;
      Temp_Integer = 15;
   };
   if(  (Parse_Int('/O=',MParm_Str))  ) {
		++ Extra_Index;
      if(  (Temp_Integer < 9)  ) {
         Temp_Integer = 9;
      };
   };

   if(  (Extra_Index)  ) {
		++Extra_Index;
   };

/* set the minmum width according to the presence or absence of the "extras" */
   if(  (menu_width == 0)  ) {
      if(  (Extra_Index)  ) {
         Menu_Width = Temp_Integer;
      } else {
         Menu_Width = 7;
      };
   };
/* If the width of the title is more than the current width of the menu, make 
 it bigger so it will fit */
   if(  (Length(Parse_Str('/T=',MParm_Str)) > Menu_Width)  ) {
      Menu_Width = Length(Parse_Str('/T=',MParm_Str));
   };
   Temp_Integer = 1;
   Choice_Int = 1;

   Temp_Choice = Parse_Int('/SN=',MParm_Str);
   if(  skip_win  ) {
      if(  (temp_choice == 0) & (choice_str != '')  ) {
         reg_exp_stat = false;
			tof;
         if(  search_fwd( choice_str , 0 )  ) {
            temp_choice = c_line;
         };
         reg_exp_stat = true;
			eof;
      };
		goto skip_build;
   };
/* Determing how long the menu will be to determine box size */
   while(  (Temp_Integer < Menu_Index)  ) {
      Jx = 1;
      Temp_String = Global_Str(Menu_Prefix + Str(Temp_Integer));

BUILD_MENU:
      Jy = XPos('(',Temp_String,Jx);

      if(  (Jy == 0)  ) {
         Jy = Svl(Temp_String) + 1;
      };

      if(  (Jy)  ) {
DOUBLE_PARENS:
         if(  (XPos('((',Temp_String,Jy) == Jy)  ) {
            Temp_String = Str_Del(Temp_String,Jy,1);
            Jy = XPos('(',Temp_String,JY + 1);
            if(  (Jy == 0)  ) {
               Jy = Svl(Temp_String) + 1;
            };
				Goto DOUBLE_PARENS;
         };
			Put_Line(Copy(Temp_String,Jx,Jy - Jx));
         if(  (Get_Line == Choice_Str)  ) {
            Temp_Choice = C_Line;
         };
         if(  (Get_Line != '')  ) {
				Down;
         };
         if(  (((Jy - Jx) > Menu_Width) & (Parse_Int('/WW=',MParm_Str) == 0))  ) {
            Menu_Width = Jy - Jx;
         };
                                       /* Move pointer beyond closing paren  */
         Jx = XPos(')',Temp_String,Jy + 1);
         if(  (Jx < SVL(Temp_String) & (Jx > 0))  ) {
            ++Jx;
				Goto BUILD_MENU;
         };
      };

		++Temp_Integer;
   };

skip_build:
   if(  (menu_width + menu_x) > (screen_width - 3)  ) {
      menu_width = (screen_width - 3 - menu_x);
   };
	eof;
skiploop:
	eol;
   if(  (c_col == 1) & (c_line > 1)  ) {
		up;
		goto skiploop;
   };
   File_Changed = False;

REDO_MENU:
	Tof;
   if(  (At_Eof)  ) {
/* If this menu is empty, alert the user. */
      No_Choices = True;
      if(  (Menu_Width < 23)  ) {
         Menu_Width = 23;
      };
		Put_Line('No choices in this menu');
   };

CHOICE_LOOP:
   Ev_Count = 3;
   event_str =  '@EV' + Str(Global_Int( 'MENU_LEVEL' )) + '#';
	Set_Global_Str(Event_Str + '1', '/T=Select/K1=13/K2=28/R=1/LL=1');
	Set_Global_Str(Event_Str + '2', '/T=Cancel/K1=27/K2=1/R=0/LL=1');
   Set_Global_Str(Event_Str + '3', '/K1=13/K2=224/R=1/ND=1');

   if(  (Extra_Index > 1)  ) {
		++Ev_Count;
		Set_Global_Str(Event_Str  + Str(Ev_Count), '/T=Create/K1=0/K2=82/R=2');
   };

   if(  (Extra_Index > 2)  ) {
		++Ev_Count;
		Set_Global_Str(Event_Str  + Str(Ev_Count), '/T=Delete/K1=0/K2=83/R=3');
   };

   if(  (Extra_Index > 3)  ) {
		++Ev_Count;
		Set_Global_Str(Event_Str  + Str(Ev_Count), '/T=Modify/K1=0/K2=61/R=4');
   };
   temp_integer = 1;                   /* К.Е.Г. - обеспеч.совм. по F2-10   -*/
   while(  temp_integer < 10  ) {
      jx = 1;                          /* Может быть нужно их и в TOP-EVENT ?*/
      ++temp_integer;
      temp_string = Parse_Str('/DF' + Str(temp_integer) + '=', Mparm_Str);
      if(  (temp_string == '')   ) {
         temp_string = Parse_Str('/F' + Str(temp_integer) + '=', Mparm_Str);
         if(  (temp_string != '')  ) {
            jx = 0;
         };
      };
      if(  (temp_integer == 1) & (temp_string == '')  ) {
         temp_string = 'Help';
      };
      if(  (temp_integer > 1) & (temp_string != '')  ) {
         ++Ev_Count;
         Set_Global_Str(Event_Str  + Str(Ev_Count),
            '/T=' +  temp_string
         + '/K1=0/K2=' + Str(58 + temp_integer)
         + '/FL=' +  temp_string
         + '/R=-' + Str(temp_integer));
         if(  NOT(jx)  ) {             /* F2-F10 в TOP-EVENT не помещать     */
            Set_Global_Str(Event_Str  + Str(Ev_Count),
               Global_Str(Event_Str  + Str(Ev_Count))
            + '/ND=1 ' +  temp_string  );
         };
      };
   };                                  /* К.Е.Г. - обеспеч.совм. по F2-10   .*/
                                       /* К.Е.Г. - Дополнительные EVENT     -*/
   e_ev_count = Parse_Int('/EV#=',Mparm_Str);
   if(  (e_ev_count)  ) {                /*  -> If есть "внешние" EVENT - передаем */
      e_event_str = Parse_Str('/EV=',Mparm_Str) ;
      jx = 0;
      while(  (jx < e_ev_count)  ) {
         ++jx ;
         if(  (Global_Str(e_event_str + Str(jx)) != '' )  ) {
            ++ev_count;
            Set_Global_Str(event_str + Str(ev_count),
                  Global_Str(e_event_str  + Str(jx)) );
         };
      };
   };                                  /*-- If .. 14.06.91-15.14 --        ..*/
                                       /* К.Е.Г. - Дополнительные EVENT     .*/

	++Ev_Count;
	Set_Global_Str(Event_Str  + Str(Ev_Count), '/K1=0/K2=75/R=100/ND=1');
	++Ev_Count;
	Set_Global_Str(Event_Str  + Str(Ev_Count), '/K1=0/K2=77/R=100/ND=1');
   if(  temp_choice == 0  ) {
      temp_choice = 1;
   };
   RM('WMENU /DBL=1/X=' + Str(Menu_X) + '/Y=' + Str(Menu_Y) + '/S=' +
		Str(Temp_Choice) + '/MH=' + parse_str('/MH=',mparm_str) +
		'/NK=1/OR=5/EV=' + event_str + '/EV#=' + Str(Ev_Count) + '/T=' +
		Parse_Str('/T=',MParm_Str) + '/W=' + Str(Menu_Width) + '/SP=' +
		Parse_Str('/I=',MParm_Str) + '/NB=' + Str(Not(Make_Box)));
   if(  (Return_Int < 0)   ) {         /*К.Е.Г. для совместимости  F2-F10   -*/
      Return_Str = Get_Line;
      Goto SPECIAL_EXIT;
   };                                  /* К.Е.Г. - обеспеч.совм. по F2-10   .*/
   if(  ((Return_Int == 0) | (Return_Int == 1))  ) {
		Set_Global_Int('DVINT',C_Line);
      if(  (Return_Int == 1)  ) {
         Return_Str = Get_Line;
      };
      Refresh = True;
      if(  ((Return_Int == 0) & (Menu_Mode == 0))  ) {
         Return_Str = Choice_Str;
         Return_Int = 0;
			Goto SPECIAL_EXIT;
      };
      if(  (Menu_Mode == 0)  ) {
			Goto CHOICE_MADE;
      };
      Menu_Mode = 0;
	Goto CHOICE_MADE;
   };

   if(  (Return_Int == 2)  ) {
		Call ADD_TO_MENU;
      if(  (Return_Int)  ) {
         Menu_Mode = 1;
         if(  (Parse_Int('/EC=',MParm_Str) == 1)  ) {
				Goto CHOICE_MADE;
         };
         refresh = false;
			Kill_Box;
			Goto REDO_MENU;
      } else {
			Goto CHOICE_LOOP;
      };
   };

   if(  (Return_Int == 3)  ) {
      Menu_Mode = 2;
      Refresh = False;
		Call CHECK_DELETE;
      if(  (Return_Int)  ) {
			Goto SKIP_DELETE;
      };
		RM('USERIN^VERIFY /T=Are you sure you want to delete this menu item?/C=1/L=' +
		Str(Menu_Y + Extra_Index + 1));
      if(  (Return_Int == 0)  ) {
SKIP_DELETE:
         Menu_Mode = 0;
			Goto CHOICE_LOOP;
      };
      Return_Str = Get_Line;
		Set_Global_Int('DVINT',C_Line);
		Del_Line;
		Up;
      Menu_Changed = True;
      if(  (Parse_Int('/ED=',MParm_Str) == 1)  ) {
			Goto CHOICE_DELETED;
      };
   /* If we deleted the default menu choice, we must change it to something else
   just in case the user presses <ESC>.  The obvious choice is item above */
      if(  (Return_Str == Choice_Str)  ) {
         Choice_Str = Get_Line;
      };
		Kill_Box;
		Goto REDO_MENU;
   };

   if(  (Return_Int == 4)  ) {
		Call CHECK_MODIFY;
      if(  (Return_Int)  ) {
			Goto CHOICE_LOOP;
      };
      Menu_Mode = 3;
      Return_Str = Get_Line;
		Goto CHOICE_MADE;
   };

	GOTO CHOICE_LOOP;

CHOICE_MADE:
/* Put the menu choice integer into a global, so the calling macro can retrieve
it */
	Set_Global_Int('DVINT',C_Line);
CHOICE_DELETED:
   Refresh = False;
/* This is a very special case for the macro EXTENS */
   Jx = C_Line;
   Jy = C_Row;
   if(  (C_Line > 1)  ) {
		Up;
		Call SKIP_SEEK_UP;
		Goto GET_BACK;
   } else {
GET_BACK:
		Set_Global_Str('DVSTR',Get_Line);
      while(  (C_Row < Jy)  ) {
			Down;
      };
		Goto_Line(Jx);
   };
   Return_Int = Menu_Mode + 1;
SPECIAL_EXIT:
ERROR_EXIT:
   Refresh = False;
   if(  skip_win == false  ) {
      if(  ((Parse_Int('/NR=',MParm_Str) == 0) & (Menu_Changed == True))  ) {
			Call REBUILD_MENU;
      };
		Delete_Window;
   };
	Switch_Window(Active_Window);
	GOTO EXIT;

/* ********************************** SUBROUTINES ****************************** */

SKIP_SEEK_UP:
   Skip_Count = 1;
   if(  (XPos('|254',Get_Line,1) == Length(Get_Line))  ) {
      if(  (C_Line > 1)  ) {
			++Skip_Count;
			Up;
      } else {
         while(  (Skip_Count)  ) {
				Down;
				--Skip_Count;
         };
			Ret;
      };
		Goto SKIP_SEEK_UP;
   };
	RET;

ADD_TO_MENU:
/* Querybox is a general purpose "boxed" prompt. */
      Create_Title = Parse_Str('/CT=',MParm_Str);
      if(  (Create_Title == '')  ) {
         Create_Title = 'CREATE NEW MENU ITEM';
      };
      Return_Str = '';
		RM('USERIN^QUERYBOX /H=IN/C=' + Str(Menu_X) + '/L=' + Str(Menu_Y + Extra_Index + 1) +
		'/W=' + str( Parse_int('/W=',MParm_Str) - length(Parse_Str('/PRE=',MParm_Str)))
		 + '/T=' + Create_Title + '/P='
		 + Parse_Str('/PRE=',MParm_Str));

      if(  (Return_Int == True) & (Return_Str != '')  ) {
         return_str = Parse_Str('/PRE=',MParm_Str) + return_str;
         if(  (Parse_Int('/U=',MParm_Str) == 1)  ) {
            Return_Str = Caps(Return_Str);
         };
/* First, see if the new addition already exists, if so, prevent redundant
entries by assuming the user merely wants to select this menu choice */
         Temp_Integer = C_Line;
         Refresh = False;
         Tof;
         if(  (Search_Fwd('%' + Return_Str + '$',0))  ) {
            Return_Int = 0;
				RET;
         } else {
				Goto_Line(Temp_Integer);
         };
         if(  (No_Choices == False)  ) {
				Eol;
				Cr;
				Goto_Col(1);
         };
			Put_Line(Return_Str);
         Menu_Changed = True;
         No_Choices = False;
      } else {
         Return_Int = 0;

      };
		RET;

REBUILD_MENU:
   Temp_String = Return_Str;
   Refresh = False;
	Tof;
   Menu_Index = 1;
	Set_Global_Str(Menu_Prefix + '1','');

   while(  (Not(At_Eof))  ) {
		RM('DBLPAREN ' + Get_Line);
      if(  (OCPG)  ) {
			Set_Global_Str(Menu_Prefix + Str(Menu_Index),Return_Str);
			++Menu_Index;
      } else {
         if(  ((Length(Global_Str(Menu_Prefix + Str(Menu_Index))) + Length(Return_Str))
            > 196)  ) {
				++ Menu_Index;
				Set_Global_Str(Menu_Prefix + Str(Menu_Index),'');
         };
			Set_Global_Str(Menu_Prefix + Str(Menu_Index),Global_Str(Menu_Prefix + Str(Menu_Index)) + Return_Str + '(' + Help_Str + ')');
      };
		Down;
   };
   Temp_Integer = Menu_Index;
/* If there are globals beyond the current index, deallocate them */
   while(  (Temp_Integer < Parse_Int('/#=',MParm_Str))  ) {
		++Temp_Integer;
		Set_Global_Str(Menu_Prefix + Str(Temp_Integer),'');
   };
	++Menu_Index;
   Return_Str = Temp_String;
	RET;

CHECK_DELETE:
   Return_Int = 0;
   if(  (Parse_Str('/ND=',MParm_Str) != '')  ) {
      if(  (XPos( ' ' + Get_Line + ' ',' ' + Parse_Str('/ND=',MParm_Str) + ' ',1))  ) {
			RM('MEERROR^Beeps /C=1');
         Return_Int = 1;
      };
   };
	RET;

CHECK_MODIFY:
   Return_Int = 0;
   if(  (Parse_Str('/NM=',MParm_Str) != '')  ) {
      if(  (XPos(Get_Line,Parse_Str('/NM=',MParm_Str),1))  ) {
			RM('MEERROR^Beeps /C=1');
         Return_Int = 1;
      };
   };
	RET;
/* ***************************************************************************** */

EXIT:
   if(  ((Make_Box > 0) & (Parse_Int('/K=',MParm_Str) > 0))  ) {
		Kill_Box;
   };
   if(  (e_ev_count)  ) {                /*  -> If есть "внешние" EVENT - зачистим */
      jx = 0;
      while(  (jx < e_ev_count)  ) {
         ++jx ;
         Set_Global_Str(e_event_str  + Str(jx) , '');
      };
   };                                  /*-- If .. 14.06.91-15.14 --        ..*/
   mode = temp_mode;
   Refresh = Temp_Refresh;
   Ignore_Case = Temp_Ignore_Case;
   Reg_Exp_Stat = Temp_Reg_Exp_Stat;
   Explosions = Temp_Explosions;
   Insert_Mode = Temp_Insert_Mode;
   Messages = Temp_Messages;
	pop_labels;
	Set_Global_Int('MENU_LEVEL', Global_Int('MENU_LEVEL') - 1);
};

macro DBLPAREN FROM ALL {
/* ******************************************************************************
															 MULTI-EDIT MACRO

NAME:  DBLPAREN

DESCRIPTION:  This is a general purpose string manipulator that changes
any occurance of a "(" to "((", which was entered by a user in a prompt, so
that it may be used to create a menu without screwing up.
The string is passed to this macro via the standard ME parameter passing
convention, and the result is returned in Return_Str

							 (C) Copyright 1989 by American Cybernetics, Inc.
****************************************************************************** */
   str Tstr;
   int JX;
   TStr = MParm_Str;
   jx = 1;
CHECKQ:
   jx = XPOS('(',TStr,jx);
   if(  jx != 0  ) {
      TStr = Str_Ins('(',TStr,jx);
      jx = jx + 2;
		goto CHECKQ;
   };
   Return_Str = Tstr;
};

macro USERSTR FROM ALL {
/* ******************************************************************************
															 MULTI-EDIT MACRO

NAME:  USERSTR

DESCRIPTION:  This macro creates a scrollable prompt.  Functionally equivalent
to the macro function String_In, except allows scrolling.  Allows user inputs
of up to 254 characters.

System variables and parameters:

Return_Str -  Returns user input if enter is pressed, or default if ESC is
							pressed.
Return_Int -  Returns 1 if enter is pressed, 0 if ESC is pressed, -1 if
							a enabled function key was press.

Names of parameters are similar to arguments for String_In.
/P=   Prompt string.  If omitted, same as above.
/F1 - F12 =str  Enables F2.  Assigns str as the label;  Now works for F1 - F12
/L=   Length.  Maximum length of input.
/X=   Col.  Left Column of prompt.
/Y=   Row.  Row of Prompt.
/H=   Help string.  2 character index for help system.
/W=   Input Width.  Width of visable portion of input.
/B=   1 = Create Box;
/BL=	Box Label;
/NK=  1 = don''t kill box when done.
/A=		1 = Exit on use of up or down arrow keys with return_int = 1 and
			push the key back on the keyboard stack.
/HISTORY=	Name of history list globals
/EV=	Name of mouse event globals
/EV#=	Number of mouse event globals
/TAB=1 Tab key (or ShiftTab) accepts entry

							 (C) Copyright 1989 by American Cybernetics, Inc.
****************************************************************************** */

   int Active_Window,Temp_Refresh,Input_Width,Len,Col,Row, t_mode, t_display_tabs,
					Temp_Message_Row, t_undo_stat, first_time, t_trunc,t_tab_expand, history_stat,
					jx, Temp_Integer, Box, box_width, ps_width, T_EOL_CHAR, arrow_stat,
					texp, event_count,Center_Offset,
               history_offset = 0,
               tab_accept;

   str  fstr[100], t_page_str[20], history_str[20], event_str[20] ;

/* We are using a window to create the input field, therefore, we have to turn
all status lines off in order to take advantage of the windows natural
refreshing, yet not screw up the display */

   Temp_Refresh = Refresh;
   Refresh = False;
	Set_Global_Int('MENU_LEVEL', Global_Int('MENU_LEVEL') + 1);
   texp = explosions;
   explosions = false;
   t_mode = mode;
   t_tab_expand = tab_expand;
   T_trunc = truncate_spaces;
   T_Undo_Stat = Undo_Stat;
   t_eol_char = eol_char;
   t_page_str = page_str;
   t_display_tabs = display_tabs;
   eol_char = 177;
   Temp_Message_Row = Message_Row;


	Push_Labels;

   if(  (Mparm_Str == '')  ) {
		RM('MEERROR^Beeps /C=1');
		Goto EXIT;
   };


   tab_accept = parse_int('/TAB=', mparm_str );
   event_str =  '@EV' + Str(Global_Int( 'MENU_LEVEL' )) + '#';
   event_count = 0;
   display_tabs = true;
   tab_expand = true;
   truncate_spaces = false;
   Undo_Stat = false;
   first_time = true;
   page_str = '';
   temp_integer = 0;
   history_stat = 0;

   history_str = parse_str('/HISTORY=', mparm_str);
   if(  history_str != ''  ) {
      history_stat = 1;
      history_offset = 3;
   };
   while(  temp_integer < 10  ) {
		++temp_integer;
      fstr = parse_str('/F' + str(temp_integer) + '=', mparm_str);
      jx = temp_integer;
      if(  jx < 11  ) {
         if(  (jx == 1) & (fstr == '')  ) {
            fstr = 'Help';
         };
         if(  fstr != ''  ) {
				flabel( fstr,jx, -1);
         };
      };
   };


   Message_Row = 0;
   Col = Parse_Int('/X=',MParm_Str);
   if(  col <= 0  ) {
      col = 2;
   };
   Row = Parse_Int('/Y=',MParm_Str);
   if(  row <= 0  ) {
      row = 3;
   };
   Len = Parse_Int('/L=',MParm_Str);
   Box = (Parse_Int('/B=',MParm_Str) != 0);
   arrow_stat = parse_int( '/A=', mparm_str );

   Input_Width = Parse_Int('/W=',MParm_Str);

   if(  (row + (box * 3)) >= screen_length  ) {
      row = screen_length - (box * 3) - 1;
   };

   if(  len == 0  ) {
      len = input_width;
   };
   if(  (Input_Width > Len)  ) {
      Input_Width = Len;
   };


   ps_width = Length(Parse_Str('/P=',MParm_Str));
/* If the Left X coordinate is too far to the right to accommodate the prompt and
data field, move it over to the left */
   if(  (col + ps_width + input_width) > screen_width  ) {
      Col = (screen_width - ps_width - Input_Width - 2) - history_offset;
   };
   if(  (Col < 1)  ) {
      Col = 1;
   };

/* If it still won''t fit, shorten the visable field width */
   if(  (col + ps_width + input_width) > screen_width  ) {
      input_width = (screen_width - ps_width - col - 2) - history_offset;
   };

	set_virtual_display;
   if(  box  ) {
      box_width = ps_width + input_width + 3 + history_offset;
      if(  box_width < length(parse_str('/BL=',MParm_Str))  ) {
         box_width = length(parse_str('/BL=', mparm_str));
      };
      if(  box_width < 25  ) {
         box_width = 25;
      };
		put_box(col, row, col + box_width, row + 3, 0, m_b_color, parse_str('/BL=', mparm_str),
						true);
      if(  Parse_Int('/EV#=', mparm_str) == 0  ) {
         event_count = 2;
         temp_integer = 0;
			Set_Global_Str(event_str + '1',
					'/T=OK/KC=<ENTER>/W=9/K1=13/K2=28/R=1');
			Set_Global_Str(event_str + '2',
					'/T=Cancel/KC=<ESC>/W=11/K1=27/K2=1/R=0');
      };
   };

   if(  Parse_Int('/EV#=', mparm_str) != 0  ) {
      event_count = Parse_Int('/EV#=', mparm_str);
      event_str = Parse_Str('/EV=', mparm_str);
   };
	RM('CheckEvents /M=4/G=' + event_str + '/#=' + str(event_count) + '/X=' + str(col) + '/Y=' + str(row + 2) + '/W=' + str( box_width - 1));
	RM('CheckEvents /M=2/G=' + event_str + '/#=' + str(event_count));

	Set_Global_Str('@UIDEFAULT@', return_str );
   Active_Window = Window_Id;
                                       /* Create the window for user input   */
	switch_window(window_count);
	Create_Window;
   t_color = m_h_color;
   c_color = m_h_color;
   eof_color = m_h_color & $F0;

   Window_Attr = $96;
	Size_Window(Col - 1 + ps_width + box,Row - 1 + box,Col + ps_width + Input_Width + Box,Row + 1 + box);

	Put_Line( return_str );
   mode = edit;
   Refresh = True;
	Redraw;
   if(  (Parse_Str
      ('/P=',MParm_Str) != '')  ) {
		Write(Parse_Str('/P=',MParm_Str),Col + box, Row + box, 0,m_t_color);
   };
   if(  history_offset > 0  ) {
      Write('|222 |221', col + box + input_width, row + box, 0, (button_key_color & $70 >> 4) + (m_b_color & $F0));
		Write('|25', col + box + input_width + 1, row + box, 0, button_key_color);
   };

	update_virtual_display;
	reset_virtual_display;
   file_changed = false;

	Goto Read_Key_Loop2;
READ_KEY_LOOP:

   first_time = false;

READ_KEY_LOOP2:
	Read_Key;
   if(  NOT( tab_accept )  ) {
      jx = INQ_KEY( key1, key2, 5, fstr );
      if(  jx == 1  ) {
			RM(fstr);
			goto read_key_loop2;
      };
   };

/* We will allow entry of the escape character via ALT keypad which returns key2
as 0, but catch pressing the escape key as a user abort */
   if(  ((Key1 == 13) & (Key2 != 0) & (key2 != 56))  ) { /* 13/0 on XT for ALT13 */
CR_EXIT:                               /* 13/56 on AT for ALT13              */
      if(  history_stat  ) {
			call add_to_history;
      };
      Return_Int = 1;
		Goto EXIT;
   } else if(  ((Key1 == 27) & (Key2 != 0) & (key2 != 56))  ) {
ESC_EXIT:
      if(  tab_accept & NOT(file_changed)  ) {
			push_key(key1,key2);
      };
      Return_Int = 0;
		Goto EXIT;
   } else if(  (Key1 == 8) & (key2 == 14 )  ) {
      if(  first_time  ) {
			put_line('');
			redraw;
      } else {
         if(  ((C_Col == Len) & (Not(At_Eol)))  ) {
				Del_Char;
         } else {
				Back_Space;
         };
      };

   } else if(  (key1 == 9) & (tab_accept) & (key2 != 0)  ) {
		goto cr_exit;
   } else if(  (Key1 == 0)  ) {
      if(  (key2 == 250)  ) {          /* Mouse event                        */
			RM('MOUSE^MouseInWindow');
         if(  RETURN_INT == 0  ) {
            if(  (Mou_Last_Y == Fkey_Row)  ) {
					RM( 'MOUSE^MouseFkey' );
            } else {
					RM('CheckEvents /M=1/G=' + event_str + '/#=' + str(event_count));
               if(  RETURN_INT != 0  ) {
                  Return_Int = Parse_Int('/R=', return_str);
                  if(  (Return_Int == 1)  ) {
/* We jump to CR_EXIT so the history list is added to */
							Goto CR_EXIT;
                  };
						Goto EXIT;
               } else {
                  if(  (history_stat) & (mou_last_x >= (col + box + input_width ))
                           & (mou_last_x <= (col + box + input_width + 2 ))
                           & (mou_last_y == (box + row))  ) {
							call list_history;
							goto read_key_loop2;
                  } else if(  ((Mou_Last_X < col) | (Mou_Last_X > (col + box_width + history_offset)) |
                        (Mou_Last_Y < row) | (Mou_Last_Y > (row + 3)))
                         ) {
                     return_int = tab_accept;
							Push_Key(0,250);
                     if(  return_int  ) {
								goto cr_exit;
                     };
							Goto EXIT;
                  } else if(  ((return_int == 0) & NOT(BOX))  ) {
							Push_Key( 0,250 );
                     Return_Int = 1;
							Goto EXIT;
                  };
               };
            };
         };
      } else if(  (Key2 == 3)  ) {
/* This is <CTRL@> which is a synonym for the null character.  This, unlike
String_In, will allow entry of null chars via this method */
			Goto INSERT_NULL;
      } else if(  (Key2 == 75)  ) {
			Left;
      } else if(  (Key2 == 77)  ) {
         if(  (C_Col < Len)  ) {
				Right;
         };
      } else if(  (Key2 == 71)  ) {
			Home;
      } else if(  (Key2 == 79)  ) {
                                       /* END key                            */
         if(  (Length(Get_Line) < Len)  ) {
				eol;
         } else {
				Goto_Col(Len);
				Redraw;
         };
      } else if(  (Key2 == 82)  ) {
         Insert_Mode = Not(Insert_Mode);
      } else if(  NOT(At_EOL) & (Key2 == 83)  ) {
			Del_Char;
      } else if(  (key2 == 116) & (c_col < len) & NOT(at_eol)  ) {
			word_right;
      } else if(  (key2 == 115) & (c_col > 1)  ) {
			word_left;
      } else if(  (key2 == 80) & (history_stat)  ) {
			call list_history;
      } else if(  (key2 > 59) & (key2 <= 68)  ) {
         if(  parse_str('/F' + str(key2 - 58) + '=', mparm_str) != ''  ) {
		 freturn:
            return_int = -1;
            return_str = get_line;
				goto exit;
         };
      } else if(  (key2 == 15)  ) {
         if(  (tab_accept)  ) {
				goto cr_exit;
         };
      } else if(  (key2 == 238)  ) {
         if(  (tab_accept)  ) {
				push_key( key1, key2 );
				goto cr_exit;
         };
      } else if(  (key2 == 59)  ) {
			help(parse_str('/H=', mparm_str));
      } else if(  (key2 == 62) & (history_stat)  ) {
			call list_history;
			goto read_key_loop2;
      } else if(  (((key2 > 15) & (key2 < 26)) |
               ((key2 > 29) & (key2 < 39)) |
               ((key2 > 43) & (key2 < 51)) |
               ((key2 > 119) & (key2 < 131))) &
               (TAB_ACCEPT)  ) {
			push_key( key1, key2 );
			goto cr_exit;
      };
   } else {
INSERT_NULL:
      if(  (C_Col <= Len)  ) {
         if(  first_time  ) {
				put_line('');
				redraw;
         };
         if(  (C_Col == Len)  ) {
				Put_Line(Copy(Get_Line,1,Len - 1) + char(key1) );
				Redraw;
         } else {
				text( char(key1) );
				put_line( copy(get_line,1, len) );
         };
      };
   };
	Goto READ_KEY_LOOP;

list_history:
   eol_char = t_eol_char;
	RM('GlobalVarList /REV=1/G=' + history_str +
			'/X=' + str(col) + '/Y=' + str(row + 1) +
			'/S=1/T=HISTORY/H=XX/#=' + parse_str( '/#=' , global_str(history_str)) );
   eol_char = 177;
   if(  return_int == 1  ) {
		put_line(return_str);
   };
	redraw;
	ret;

add_to_history:
   if(  (History_Str == 'FILE_HISTORY')  ) {
      return_str = caps(get_line);
   } else {
      return_str = Get_Line;
   };
   if(  return_str != ''  ) {
      jx = parse_int('/#=', global_str(history_str));
      temp_integer = 0;
      while(  temp_integer < jx  ) {
			++temp_integer;
         if(  global_str( history_str + str(temp_integer) ) == return_str  ) {
            return_int = temp_integer;
				RM('deleteitem /G=' + history_str  + '/#=' + str(jx));
				--jx;
            temp_integer = jx;
         };
      };
      if(  jx > 15  ) {
         return_int = 0;
			RM('deleteitem /G=' + history_str  + '/#=' + str(jx));
      } else {
			++jx;
      };
		set_global_str( history_str + str(jx), return_str);
		set_global_str( history_str, '/#=' + str(jx));
   };
	ret;

EXIT:
/* Restore all altered system variables and clean up */
   if(  return_int != 0  ) {
      Return_Str = Get_Line;
   } else {
      Return_Str = Global_Str('@UIDEFAULT@');
   };
	Set_Global_Str('@UIDEFAULT@','');

   if(  box  ) {
      if(  parse_int('/NK=', mparm_str) == 0  ) {
			kill_box;
      };
   };
   Refresh = False;
   page_str = t_page_str;
   mode = t_mode;
   eol_char = t_eol_char;
   truncate_spaces = t_trunc;
   tab_expand = t_tab_expand;
   display_tabs = t_display_tabs;
   Message_Row = Temp_Message_Row;
	Delete_Window;
	Switch_Win_Id(Active_Window);
   Undo_Stat = T_Undo_Stat;
	Pop_Labels;
   explosions = texp;
	RM('CheckEvents /M=3/G=' + event_str + '/#=' + str(event_count));
	Set_Global_Int('MENU_LEVEL', Global_Int('MENU_LEVEL') - 1);
   Refresh = Temp_Refresh;
};

macro WMENU FROM ALL {
/* *******************************MULTI-EDIT MACRO******************************

Name:  WMENU

Description: Builds a scrollable menu out of the current window.

Parameters:
							/T=n				Menu title
							/X=n				X coordinate
							/Y=n				Y coordinate
							/W=n				The width override
							/MH=				Height override
							/S=n				Starting line number
							/A=n				1 = Enable use of right and left error keys.
							/OR=n				Starting (old) row number
							/SP=str			Search prefix
							/SM=n				Search_Mode, if 1, search keys off of first char only
													and starts over with each keystroke.  Primarily added
													for the switch window list.
							/NB=n				1 = no box
                     /NK=n          1 = don''t kill box on exit
							/H=str			Help string
							/MARK=n			Enable item marking.
							/NCR=n			1 = Disable CR from exiting.
							/DBL=n			1 = Require double click of mouse for selection.
							/CL#=n			Number of columns to display.  Default is 1.
							/CLW=n			Column width.
							/CLC=n			Current column #.

							/EV#=n			Number of events.
							/EV=str			Global string prefix for events
													The event globals are cleared upon exit.
														The event string format is as follows:
													/T=str		title
													/K1=n			Keycode 1
													/K2=n			Keycode 2
													/R=n			Result code
													/ND=1			No display
													/LL=1			Put event on bottom line of window

NOTE:
This macro changes the window attribute(WINDOW_ATTR) to make the window
non-switchable via the normal user interface.  Be aware of this should you
wonder why your window "dissapeared".  This is of no concern if you deal
with the window only in your macro and get rid of it before exiting to edit
mode.  If you need to deal with the window in the edit mode, before exiting
your macro do something like:
Window_Attr := 0;

Returns:			Return_Int = 1		Item was selected.
													 0		ESC was pressed.
													All other values corrispond to event results.

							 (C) Copyright 1989 by American Cybernetics, Inc.
****************************************************************************** */
   int  x, y, menu_width, menu_length, menu_count,
               jx, jy, jz,             /* Temporary variables                */
					event_count, event_lines, tbc, t_undo,
					cl, scroll_bar, t_ins,
					ll_col,ll2, u_col,
					marking_enabled, ll, mdl, t_mode,
               column_count, column_width, current_column, search_mode ;

   str  event_str[20], tstr, tstr2, inc_search_str[20], inc_search_prefix[20] ;

	Set_Global_Int('MENU_LEVEL', Global_Int('MENU_LEVEL') + 1);

   Refresh = FALSE;
   t_mode = mode;
   mode = edit;
   Search_Mode = Parse_Int('/SM=',MParm_Str);

	Push_Labels;
   t_undo = undo_stat;
   undo_stat = false;
   t_ins = insert_mode;
   insert_mode = true;
	TOF;
   jx = Parse_Int('/W=', mparm_str);
   if(  jx > 0  ) {
      menu_width = jx;
		eof;
		goto_col(1);
      if(  not(at_eof)  ) {
         menu_count = c_line;
      } else {
         menu_count = c_line - 1;
      };
   } else {
      menu_width = 0;
      while(  NOT(at_eof)  ) {
         tstr = Get_Line;
         jx = svl(tstr);
         if(  str_char(tstr, jx) != '|254'  ) {
            if(  jx > menu_width  ) {
               menu_width = jx;
            };
         };
			DOWN;
      };
      menu_count = c_line - 1;
   };

   if(  menu_count == 0  ) {
		Put_Line('No Items In Menu');
      menu_width = Length( get_line );
   };

   marking_enabled = Parse_Int('/MARK=', mparm_str);

   x = Parse_Int('/X=', mparm_str);
   y = Parse_Int('/Y=', mparm_str);

   if(  y <= 0  ) {
      y = min_window_row + 1;
   };

   current_column = parse_int('/CLC=', mparm_str);
   if(  current_column < 1  ) {
      current_column = 1;
   };
   column_width = parse_int('/CLW=', mparm_str);
   column_count = parse_int('/CL#=', mparm_str);
   if(  column_count == 0  ) {
      column_count = 1;
   };

   if(  menu_width < (column_count * column_width)  ) {
      menu_width = column_count * column_width;
   };

      /* Now process keystroke/mouse event list */
   event_count = Parse_Int('/EV#=', MParm_Str);
                              /* 
                              Make_Message('' Wmenu: '' + Mparm_str);
                              Delay(1000);
                              */
   event_str = Parse_Str('/EV=', MParm_Str);
   if(  (marking_enabled) & (event_count > 0)  ) {
		++event_count;
			Set_Global_Str(Event_Str + str(event_count), '/T=Mark item/KC=<SpaceBar>/K1=32/K2=57/R=0/PK=1');
   };
   jx = 0;
   jy = 1000;
   ll_col = 0;
   event_lines = 0;
   mdl = 1;
   while(  jx < event_count  ) {
		++jx;
      tstr = Global_Str( event_str + str(jx));
                                       /*К.Е.Г. Игры с F2 - F10            ->*/
      key1 = Parse_Int('/K1=', tstr);
      key2 = Parse_Int('/K2=', tstr);
      if(  (Key1 == 0) &
         (Key2 > 58) & (Key2 < 70)  ) {
            Flabel(Parse_Str('/FL=', tstr), Key2 - 58, -1);
         /* 
            k_fsub := Str_Ins(Str_Del(k_fsub , (key2-59),1) ,''1'', (key2-59));
            Make_Message(''WMENU '' + Parse_Str(''/FL='', tstr) 
                  + Str(key2-59) + '':'' + tStr);
            Beep;
            Delay(1000);
         */
      };
                                       /*К.Е.Г. Игры с F2 - F10            ..*/
      if(  parse_int('/ND=',tstr) == 0  ) {
         return_str = parse_str('/KC=', tstr);
         if(  return_str == ''  ) {
				RM( 'SETUP^MAKEKEY /K1=' + Str(key1) +
														'/K2=' + Str(key2));
         };
         jz = Length(return_str) + Length( Parse_Str('/T=', tstr)) + 1;
         ll = Parse_Int('/LL=', tstr);
         if(  ll == 1  ) {
            tstr = tstr + '/C=' + str( ll_col );
            ll_col = ll_col + jz + 1;
            if(  (menu_width < (ll_col - 2))  ) {
               menu_width = ll_col - 3;
            };
         } else if(  ll == 2  ) {
            tstr = tstr + '/C=' + str( mdl + 1 );
            mdl = mdl + jz/*  + 1 */;
         } else {
            if(  (menu_width - jy) < jz  ) {
               if(  (event_lines > 0)  ) {
						set_global_int('@EVL#' + str( event_lines ), jy - 3);
               };
               jy = 0;
					++event_lines;
            };
            if(  (menu_width < (jy + jz))  ) {
               menu_width = jy + jz;
            };
            tstr = tstr + '/EL=' + str( event_lines ) + '/C=' + str( jy );
            jy = jy + jz + 1;
         };
         tstr = tstr + '/KC=' + return_str  + '/W=' + str(jz - 1);
			Set_Global_Str( event_str + str(jx), tstr );
      };
   };
   if(  (event_lines > 0)  ) {
		set_global_int('@EVL#' + str( event_lines ), jy - 3);
   };

   if(  (menu_width > (Screen_Width - 3))  ) {
      menu_width = Screen_Width - 3;
   };
   if(  x <= 0  ) {
      x = (screen_width / 2) - ((menu_width) / 2);
   };

   if(  ((x + menu_width) > (Screen_Width - 2))  ) {
      x = Screen_Width - menu_width - 2;
   };

   menu_length = menu_count;
   if(  menu_count == 0  ) {
      menu_length = 1;
   };
   jx = parse_int('/MH=', mparm_str);
   if(  jx != 0  ) {
      menu_length = jx;
   };
   if(  (y + menu_length + event_lines + 3 + (event_lines > 0)) > Screen_length  ) {
      menu_length = ((screen_length - y) - event_lines - 3 - (event_lines > 0));
   };


	set_virtual_display;
   tbc = box_count;
   if(  Parse_Int('/NB=',mparm_str) == 0  ) {
                                       /* THIS IS IT!                        */
		Put_Box( x, y, x + menu_width + 3, y + event_lines + menu_length + 2 + (event_lines > 0),
						0, m_b_color, Parse_Str('/T=', mparm_str), TRUE );
   };


	tof;
   t_color = m_t_color;
   b_color = m_b_color;
   s_color = m_s_color;
   h_color = m_h_color;
   c_color = m_t_color;
   eof_color = (m_t_color & $F0) | ((m_t_color & $70) >> 4);
   window_attr = $96;
	Size_Window( x , y + event_lines + (event_lines > 0),
							 x + menu_width + 1, y + menu_length + event_lines + 1 + (event_lines > 0) );


   if(  event_count > 0  ) {
      if(  event_lines > 0  ) {
			Draw_Char(196, x + 1, y + event_lines + 1, m_b_color, menu_width );
      };
      jx = 0;
      while(  jx < event_lines  ) {
			++jx;
			Set_Global_Int('@EVL#' + str(jx),
				 x + 1 + ((menu_width / 2) - (Global_Int('@EVL#' + str(jx)) / 2)));
      };

      if(  ll_col > 0  ) {
         ll_col = ll_col - 3;
      };
      ll_col = x + 1 + ((menu_width / 2) - (ll_col / 2));
      ll2 = 0;
      u_col = 0;
      jx = 0;
      while(  jx < event_count  ) {
			++jx;
         tstr = Global_Str( event_str + str(jx));
         if(  (parse_int('/ND=', tstr) == 0)  ) {
            ll = Parse_Int('/LL=', tstr);
            if(  ll == 1  ) {
               jz = win_y2;
               jy = ll_col + ll2;
               ll_col = ll_col + parse_int('/W=', tstr) + 1;
            } else if(  ll == 2  ) {
               jz = (y + event_lines + 1) * (event_lines != 0);
               jy = parse_int('/C=',tstr) + x;
            } else {
               jz = Parse_Int('/EL=', tstr);
               jy = Global_Int('@EVL#' + str(jz)) +
														Parse_Int('/C=', tstr);
               jz = y + jz;
            };
				Set_Global_Str( event_str + str(jx), tstr + '/X=' + str(jy) +
															'/Y=' + str(jz));
            tstr2 = Parse_Str('/T=', tstr );
				write( tstr2, jy, jz, 0, button_color );
            jy = jy + svl(tstr2);
            tstr2 = Parse_Str('/KC=', tstr);
				write( tstr2, jy, jz, 0, button_key_color );
         };
      };

   };



   jy = parse_int('/S=', mparm_str );
   if(  jy == 0  ) {
      jy = 1;
   };
   jx = parse_int('/OR=', mparm_str);
   if(  jy > menu_count  ) {
      jy = menu_count;
   };
   if(  (menu_count - (jy - jx)) < menu_length  ) {
      jx = menu_length;
   };
   while(  (c_row < jx) & (c_row < menu_length)  ) {
		DOWN;
   };
	Goto_Line(jy);

   Scroll_Bar = (menu_length > 2) & (menu_count > menu_length);
   if(  scroll_bar == 0  ) {
      window_attr = window_attr | $18;
   };
	call skip_up;
	call skip_down;

   REFRESH = true;
	redraw;

	update_virtual_display;
	reset_virtual_display;

   inc_search_str = '';
   inc_search_prefix = Parse_Str('/SP=',mparm_str);
   if(  inc_search_prefix == ''  ) {
      if(  marking_enabled  ) {
         inc_search_prefix = '%?';
      } else {
         inc_search_prefix = '%';
      };
   };

   if(  column_width == 0  ) {
      column_width = menu_width;
   };

main_loop:
	goto_col( (column_width * (current_column - 1))
									+ svl(inc_search_str) + 1 + marking_enabled);
   if(  (at_eof) & (current_column > 1)  ) {
		goto go_left;
   };
	call Hi_Line;
	read_key;
	draw_attr( x + 1, wherey, m_t_color, menu_width );
pass_key_through:
   if(  key1 == 0  ) {
      inc_search_str = '';
      if(  (key2 == 59)  ) {
			Help( Parse_Str('/H=', mparm_str ) );
			Goto Main_Loop;
      } else if(  (key2 == 77) | (key2 == 242)  ) {
			go_right:
			++current_column;
         if(  (current_column > column_count)  ) {
            current_column = 1;
				goto go_down;
         };
      } else if(  (key2 == 75) | (key2 == 243) | (key2 == 15)  ) {
			go_left:
			--current_column;
         if(  (current_column < 1)  ) {
            current_column = column_count;
				goto go_up;
         };
      } else if(  (key2 == 80) | (key2 == 241)  ) {
		 go_down:
         if(  (c_line < menu_count)  ) {
				DOWN;
         };
			Call Skip_Down; Call Skip_Up;
      } else if(  (key2 == 72) | (key2 == 240)  ) {
		go_up:
			UP;
			Call Skip_Up; Call Skip_Down;
      } else if(  (key2 == 73)  ) {
			Page_Up;
			Call Skip_Up; Call Skip_Down;
      } else if(  (key2 == 81)  ) {
         if(  (c_line + Menu_Length - C_row) > (menu_count  - Menu_Length + 1)  ) {
				goto goto_eof;
         };
			Page_Down;
			Call Skip_Down; Call Skip_Up;
      } else if(  (key2 == 79)  ) {
	 goto_eof:
         refresh = false;
			EOF;
			goto_col(1);
			goto_line(c_line - 1);
			down;
			Call Skip_Up; Call Skip_Down;
         current_column = column_count;
         refresh = true;
			redraw;
      } else if(  (key2 == 71)  ) {
	 goto_tof:
         current_column = 1;
			tof;
			Call Skip_Down; Call Skip_Up;
      } else if(  (key2 == 244)  ) {
			Goto go_cr;
      } else if(  (key2 == 245)  ) {
			Goto go_esc;
      } else if(  (key2 == 250)  ) {   /* process mouse event                */
			Goto do_mouse_event;
      } else if(  (key2 == 251) & (marking_enabled)  ) {
			Mark_Pos;
			RM('MOUSE^MouseInWindow');
         if(  at_eof  ) {
				goto_mark;
         } else {
				pop_mark;
            current_column = ((c_col - 1) / column_width) + 1;
            if(  (return_int == 1) & (xpos('|254', get_line,1) == 0)  ) {
					call toggle_mark;
            };
         };
      } else {
			call Process_Key_Event;
         if(  jx != 0  ) {
				goto exit;
         };
      };
   } else {
		call process_key_event;
      if(  jx != 0  ) {
			goto exit;
      };
      if(  (key1 == 27)  ) {
		go_esc:
         RETURN_INT = 0;
			Goto EXIT;
      } else if(  (key1 == 13)  ) {
		go_cr:
         if(  Parse_Int('/NCR=', mparm_str) == 0  ) {
            RETURN_INT = 1;
				Goto EXIT;
         };
      } else if(  (key1 == 43) & (marking_enabled)  ) {
		do_mark:
			call toggle_mark;
      } else if( ( key1 == 08 )  ) {
         if(  svl(inc_search_str) > 0  ) {
            refresh = false;
				TOF;
            inc_search_str = str_del( inc_search_str, svl(inc_search_str), 1 );
				GOTO inc_search;
      } else if(  (key1 == 9)  ) {
			goto go_right;
      };
      } else {
		inc_search:
         if(  (Search_Mode)  ) {
            inc_search_str = '';
            if(  key1 != 08  ) {
               tstr = CAPS(char(key1));
            };
         } else {
            tstr = CAPS(inc_search_str);
            if(  key1 != 08  ) {
               tstr = tstr + CAPS(char(key1));
            };
         };

         refresh = false;
			mark_pos;
         if(  (inc_search_str == '')  ) {
				tof;
         };
         jy = 0;
		search_loop:
			++jy;
         if(  (jy > column_count)  ) {
				down;
            jy = 1;
         };
         if(  (c_line > menu_count)  ) {
				goto search_exit;
         };
			goto_col( (column_width * (jy - 1)) + 1 + marking_enabled );
         if(  caps(copy(get_line, c_col, svl(tstr))) == tstr  ) {
            if(  key1 != 08  ) {
               inc_search_str = inc_search_str + char(key1);
            };
				pop_mark;
            refresh = true;
            current_column = jy;
				GOTO main_loop;
         };
			goto search_loop;
	search_exit:
			goto_mark;
         refresh = true;
      };
   };
	GOTO main_loop;

Toggle_Mark:
   insert_mode = false;
	goto_col( (column_width * (current_column - 1)) + 1 );
   if(  (cur_char == '|16')  ) {
		text(' ');
   } else {
		text('|16');
   };
   insert_mode = true;
	ret;

/* Returns with jx = 0, no action;  jx > 0, goto exit */
Process_Key_Event:
   jx = 0;
	RM('CheckEvents /G=' + event_str + '/#=' + str(event_count));
   if(  RETURN_INT != 0  ) {
      JX = RETURN_INT;
      RETURN_INT = Parse_Int('/R=', Return_Str );
   };
	RET;


Skip_Down:
   while(  (Xpos('|254',get_line,1) != 0) & (c_line < menu_count)  ) {
		DOWN;
   };
	RET;

Skip_UP:
   while(  (Xpos('|254',get_line,1) != 0) & (C_Line > 1)  ) {
		UP;
   };
	RET;

Hi_Line:
	draw_attr( x + 1 + ((current_column - 1) * column_width), wherey, m_h_color, column_width );
	RET;

Do_Mouse_Event:
	Mark_pos;
   jy = c_line;
   jx = current_column;
	RM('MOUSE^MouseInWindow');
   if(  (return_int == 1) & (xpos('|254', get_line,1) == 0) & (not(at_eof))  ) {
		pop_mark;
      current_column = ((c_col - 1) / column_width) + 1;
		goto_col( (column_width * (current_column - 1)) + 1 );
		call Hi_Line;
      if(  (Parse_Int('/DBL=', mparm_str) == 0) |
            ((jy == c_line) & (jx == current_column ))  ) {
         return_int = 1;
			goto exit;
      };
   } else {
		goto_mark;
      if(  (Mou_Last_Y == Fkey_Row)  ) {
			RM( 'MOUSE^MouseFkey' );
			GOTO Main_Loop;
      } else if(  (Mou_Last_X == Win_X2)  ) {
			RM('MOUSE^HandleScrollBar /EOF=1/L=' + str(menu_count));
         if(  return_int == 1  ) {
				call skip_down;
         } else if(  return_int == 2  ) {
        call skip_up;
         };
      } else {
			RM('CheckEvents /M=1/G=' + event_str + '/#=' + str(event_count));
         if(  RETURN_INT != 0  ) {
            RETURN_INT = Parse_Int('/R=', Return_Str );
            if(  parse_int('/PK=', mparm_str)  ) {
               key1 = parse_int('/K1=', mparm_str);
               key2 = parse_int('/K2=', mparm_str);
					goto pass_key_through;
            };
				Goto Exit;
         };
      };
   };
   if(  (Mou_Last_X < X) | (Mou_Last_X > (X + Menu_Width + 3))
         | (Mou_Last_Y < Y) | (Mou_Last_Y > (WIN_Y2 + 1))  ) {
		Push_Key(0,250);
      RETURN_INT = 0;
		goto exit;
   };
	goto main_loop;

exit:
   refresh = false;
	call hi_line;
   if(  menu_count == 0  ) {
      if(  ((return_int == 1) & (Parse_Int('/OEM=',MParm_Str) == 0))  ) {
         return_int = 0;
      };
		del_line;
   };
   if(  Parse_Int('/NK=',mparm_str) == 0  ) {
      while(  (box_count > tbc)  ) {
			kill_box;
      };
   };

   jx = 0;
   while(  (jx < Event_Count)  ) {
		++jx;
		Set_Global_Str( event_str + str(jx), '');
   };
	goto_col( (column_width * (current_column - 1)) + 1 );
	Pop_Labels;
   undo_stat = t_undo;
   insert_mode = t_ins;
   mode = t_mode;
	Set_Global_Int('MENU_LEVEL', Global_Int('MENU_LEVEL') - 1);
}
