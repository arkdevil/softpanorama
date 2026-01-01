macro_file WS; // version 1.3
/***************************************************************************

                         MULTI-EDIT 7.xx MACRO FILE

Name:   WS
                                Борис Зулин.

  Симбиоз Wordstar и др.
  Все права сохраняются за авторами макросов.
  Этот файл представляет собой экстракт из макросов SP.
  Часть макросов пришлось откорректировать, часть написана с нуля.
  Знаком "!" помечены наиболее интересные,
  "`" - для внутреннего употребления.


+ WORDSTAR        - Initializes the editor for Wordstar emulation
+ WS_PROCESS_KEY1 - Used by other Wordstar emulation macros
! CTRLQ           - Traps <CtrlQ> and process the second keystroke
! CTRLK           - Traps <CtrlK> and process the second keystroke
! CTRLO           - Traps <CtrlO> and process the second keystroke
+ CTRLW           - Performs Wordstar-like scroll down
+ CTRLZ           - Performs Wordstar-like scroll up
! DELWORDR        - Delete word right
! DELWHOLEWORD    - Удаляет слово целиком
! MarkWord        - Отмечает слово, как блок
+ UM              - Выгрузка макросов
` HOMEKEY         - Special processing for the home key
` ENDKEY          - Special processing for the end key
` RIGHTMAR        - Sets right margin
` LEFTMAR         - Sets left margin
` RESETMAR        - Resets margin
` INDENT          - Performs Wordstar like indent
` UNDENT          - Performs Wordstar like undent
+ DelMsg          - Удалить с экрана последнее сообщение
+ EuroDate        - Дата в европейском стиле (может перекл. на англ. яз.)
+ Time24          - Время в стиле 24
+ DateTime        - Штамп даты и времени
+ MULMTCH         - Поиск "скобок"- начало/конец
+ RCorr           - корректировка слова, ошибочно набранного не на том регистре
+ MarkWord        - отметить слово как блок
+ SWCASE          - изменение регистра русского и латинского текста
+ WORD_CASE       - изменение регистра русских и латинских слов
- WORD_SCH        - поиск/замена слов, ограниченных с обеих сторон
                    не алфавитно-цифровыми символами
+ Chng_Up         - на первую измененную вверху
+ Chng_Dn         - на первую измененную внизу
+ SaveAllFiles    - записывает все измененные файлы на диск
+ Trim            - удаляет лидирующие и заверщающие пробелы / знаки TAB
                    Строка берется и помещается из/в Return_Str
! MLine           - Сдвиг строки согласно отступа
                  /M=L  - влево, используя Left margin
                  /M=R  - вправо, используя Right margin
                  /M=S  - в разные стороны от позиции курсора
                          ( <Left margin - Right margin> )
! RusSpCh         - проверка орфографии блока или целого файла
                  /F=FileName - путь и имя файла программы проверки
                  /Q=1        - запросить имя файла и установить переменную
                  /B=1        - проверять блок
+ InstGlbVar      - устанавливает значение глобальной переменной
+ GetGlbVar       - выдает значение глобальной переменной
+ GetAllGlbVar    - выдает значение ВСЕХ глобальных переменных в текущее окно,
                    используется для отладки; /C=1 - со значениями
+ Drag_Line       - сдвигает строку влево/вправо
! SEARCH_PREV     - поиск предыдущего значения
+ Hide_Block      - скрывает/показывает блок
+ Mark_Block      - отметка блока
!!FillBlock       - заполняет блок указанными символами (строкой)
+ Dup_Line        - Дублирует текущую строку
+ Dup_Char        - Дублирует символ из предыдущей строки
+ ExpandBlock     - Расширяет блок до позиции курсора
+ SwitchVideoMode - переключает режим 25/[30/33] строки
  SearchLongLine  - Поиск строки длиной более правого отступа
+ SetWindow       - Установить указанное окно

****************************************************************************/

macro WORDSTAR {
/****************************************************************************
															MULTI-EDIT MACRO

Name:		WORDSTAR

Description:  Initializes the editor for Wordstar emulation

							 (C) Copyright 1991 by American Cybernetics, Inc.
               Changed by Boris Zulin
****************************************************************************/

  Right_Margin = 76;
	Set_Global_Int('Margin_Released',FALSE);
	Set_Global_Int('Left_Margin',1);
	Set_Global_Int('Right_Margin',Right_Margin);
	Set_Global_Int('Name_La',0);
	Set_Global_Int('Stat_La',0);
  Indent_Style = 0;
	Goto_Col(1);
	Set_Indent_Level;

}

macro WS_PROCESS_KEY1 {
/* This macro takes the primary scan code KEY1, and converts it to an uppercase
alpha ASCII code to significantly simplify processing of keystrokes for the
macros CTRLQ, CTRLK, and CTRLO */

	if (key1 < 32) {
/* Convert CTRL keys to alpha */
		key1 = key1 + 64;
	}
/* Convert lower case to upper case */
	Key1 = Ascii(Caps(Char(Key1)));
}

macro CTRLQ {

  int x, y;

	if (Global_Int('@WS_CTRL_HLP_OFF@')) {
		Make_Message('<CtrlQ>');
		Read_Key;
		Make_Message('');
	} else {
    if (WhereY >= 12) { x=1; y=3; } else { x=1; y=12; }
		Set_Global_Int('MENU_LEVEL',Global_Int('MENU_LEVEL') + 1);
    Put_Box(x,y,x+45,y+10,0,M_B_Color,'<CtrlQ>',true);
    Write('E - Top of screen',    x+2,y+1,0,M_T_Color);Draw_Attr(x+2,y+1,M_S_Color,1);
    Write('X - Bottom of screen', x+2,y+2,0,M_T_Color);Draw_Attr(x+2,y+2,M_S_Color,1);
    Write('R - Beginning of file',x+2,y+3,0,M_T_Color);Draw_Attr(x+2,y+3,M_S_Color,1);
    Write('C - End of file',      x+2,y+4,0,M_T_Color);Draw_Attr(x+2,y+4,M_S_Color,1);
    Write('S - Beginning of line',x+2,y+5,0,M_T_Color);Draw_Attr(x+2,y+5,M_S_Color,1);
    Write('Q - Repeat last com.', x+2,y+6,0,M_T_Color);Draw_Attr(x+2,y+6,M_S_Color,1);
    Write('F - Search',           x+2,y+7,0,M_T_Color);Draw_Attr(x+2,y+7,M_S_Color,1);
    Write('0..9 - Get mark',      x+2,y+8,0,M_T_Color);Draw_Attr(x+2,y+8,M_S_Color,4);

    Write('D - End of line',  x+25,y+1,0,M_T_Color); Draw_Attr(x+25,y+1,M_S_Color,1);
    Write('B - Block begin',  x+25,y+2,0,M_T_Color); Draw_Attr(x+25,y+2,M_S_Color,1);
    Write('K - Block end',    x+25,y+3,0,M_T_Color); Draw_Attr(x+25,y+3,M_S_Color,1);
    Write('P - Undo',         x+25,y+4,0,M_T_Color); Draw_Attr(x+25,y+4,M_S_Color,1);
    Write('L - Spell checker',x+25,y+5,0,M_T_Color); Draw_Attr(x+25,y+5,M_S_Color,1);
    Write('W - Last error',   x+25,y+6,0,M_T_Color); Draw_Attr(x+25,y+6,M_S_Color,1);
    Write('A - Replace',      x+25,y+7,0,M_T_Color); Draw_Attr(x+25,y+7,M_S_Color,1);
    Write('- - Select mark',  x+25,y+8,0,M_T_Color); Draw_Attr(x+25,y+8,M_S_Color,1);

		Read_Key;
		Kill_Box;
		Set_Global_Int('MENU_LEVEL',Global_Int('MENU_LEVEL') - 1);
	}

	if (Key1 != 0) {
/* Convert scan code to uppercase alpha ASCII code */
		RM('WS_PROCESS_KEY1');

    switch (Key1) {
    case 83 :                                     /*  S  Home */
      Goto_Col(1); break;
    case 89 :                                     /*  Y  Delete to EOL */
			Push_Undo;
			Del_Chars(Length(Get_Line) - c_col + 1);
      Pop_Undo; break;
    case 68 :                                     /*  D  Move to end of line */
			Refresh = FALSE;
			Push_Undo;
			Eol;
			if (C_Col > 80) {
				Goto_Col(1);
				Goto_Col(80);
			}
			Pop_Undo;
			Refresh = TRUE;
      Redraw; break;
    case 69 :                                     /*  E  Top of screen */
			RM('TopWin');
			if (At_Eol) {
				Eol;
			}
      break;
    case 88 :                                     /*  X  Bottom of screen */
			RM('BotWin');
			if (At_Eol) {
				Eol;
			}
      break;
    case 76 :                                     /*  L  Spell checker */
      RM('SPELL'); break;
    case 82 :                                     /*  R  Beg. of file */
      Tof; break;
    case 67 :                                     /*  C  End of file */
      Eof; break;
    case 70 :                                     /*  F  Search */
      RM('Meutil2^Search'); break;
    case 65 :                                     /*  A  Replace */
      RM('Meutil2^S_Repl'); break;
    case 81 :                                     /*  Q  Repeat command */
      RM('Meutil2^Repeat'); break;
    case 87 :                                     /*  W  Last error */
      RM('LANGUAGE^CMPERROR '); break;
    case 80 :                                     /*  P  Undo */
      Undo; break;
    case 48 :                                     /*  0  */
      RM('TEXT^GET_MARK 10'); break;
    case 49 :                                     /*  1  */
      RM('TEXT^GET_MARK 1'); break;
    case 50 :                                     /*  2  */
      RM('TEXT^GET_MARK 2'); break;
    case 51 :                                     /*  3  */
      RM('TEXT^GET_MARK 3'); break;
    case 52 :                                     /*  4  */
      RM('TEXT^GET_MARK 4'); break;
    case 53 :                                     /*  5  */
      RM('TEXT^GET_MARK 5'); break;
    case 54 :                                     /*  6  */
      RM('TEXT^GET_MARK 6'); break;
    case 55 :                                     /*  7  */
      RM('TEXT^GET_MARK 7'); break;
    case 56 :                                     /*  8  */
      RM('TEXT^GET_MARK 8'); break;
    case 57 :                                     /*  9  */
      RM('TEXT^GET_MARK 9'); break;
    case 45 :                                     /*  -  */
      RM('TEXT^GET_MARK'); break;
    default :
			if (Block_Stat) {
        if (Key1 == 66) {                         /*  B  */
					RM('TOPBLOCK');
					Redraw;
        } else if (Key1 == 75) {                  /*  K  */
					RM('ENDBLOCK');
				}
			}
  }
  } else {
		if ((Key2 == 83) | (Key2 == 147)) { /*  <DEL> or <CtrlDEL>  */
/* Delete all chars left of cursor */
			Push_Undo;
			Put_Line(Copy(Get_Line,C_Col,2048));
			Goto_Col(1);
			Redraw;
			Pop_Undo;
		}
	}
}

macro CTRLK {
	str FName[128];
  int x,y;

	if (Global_Int('@WS_CTRL_HLP_OFF@')) {
		Make_Message('<CtrlK>');
		Read_Key;
		Make_Message('');
	} else {
    if (WhereY >= 12) { x=1; y=3; } else { x=1; y=12; }
    Set_Global_Int('MENU_LEVEL',Global_Int('MENU_LEVEL') + 1);
    Put_Box(x,y,x+51,y+12,0,M_B_Color,'<CtrlK>',true);
    Write('D - Save - done',         x+2,y+1,0,M_T_Color); Draw_Attr(x+2,y+1,M_S_Color,1);
    Write('Q - Quit',                x+2,y+2,0,M_T_Color); Draw_Attr(x+2,y+2,M_S_Color,1);
    Write('S - Save file',           x+2,y+3,0,M_T_Color); Draw_Attr(x+2,y+3,M_S_Color,1);
    Write('X - Save and quit',       x+2,y+4,0,M_T_Color); Draw_Attr(x+2,y+4,M_S_Color,1);
    Write('J - Delete file',         x+2,y+5,0,M_T_Color); Draw_Attr(x+2,y+5,M_S_Color,1);
    Write('R - Merge file from disk',x+2,y+6,0,M_T_Color); Draw_Attr(x+2,y+6,M_S_Color,1);
    Write('K - Mark block end',      x+2,y+7,0,M_T_Color); Draw_Attr(x+2,y+7,M_S_Color,1);
    Write('T - Mark word',           x+2,y+8,0,M_T_Color); Draw_Attr(x+2,y+8,M_S_Color,1);
    Write('O - <Ctrl> help on/off',  x+2,y+9,0,M_T_Color); Draw_Attr(x+2,y+9,M_S_Color,1);
    Write('0..9 - Set Mark',         x+2,y+10,0,M_T_Color);Draw_Attr(x+2,y+10,M_S_Color,4);

    Write('B - Mark block begin',x+28,y+1,0,M_T_Color); Draw_Attr(x+28,y+1,M_S_Color,1);
    Write('C - Copy block',      x+28,y+2,0,M_T_Color); Draw_Attr(x+28,y+2,M_S_Color,1);
    Write('V - Move block',      x+28,y+3,0,M_T_Color); Draw_Attr(x+28,y+3,M_S_Color,1);
    Write('W - Save block',      x+28,y+4,0,M_T_Color); Draw_Attr(x+28,y+4,M_S_Color,1);
    Write('Y - Delete Block',    x+28,y+5,0,M_T_Color); Draw_Attr(x+28,y+5,M_S_Color,1);
    Write('H - Hide/Show Block', x+28,y+6,0,M_T_Color); Draw_Attr(x+28,y+6,M_S_Color,1);
    Write('P - Print',           x+28,y+7,0,M_T_Color); Draw_Attr(x+28,y+7,M_S_Color,1);
    Write('I - Indent Block',    x+28,y+8,0,M_T_Color); Draw_Attr(x+28,y+8,M_S_Color,1);
    Write('U - Undent Block',    x+28,y+9,0,M_T_Color); Draw_Attr(x+28,y+9,M_S_Color,1);
    Write('- - Select mark',     x+28,y+10,0,M_T_Color);Draw_Attr(x+28,y+10,M_S_Color,1);

		Read_Key;
		Kill_Box;
		Set_Global_Int('MENU_LEVEL',Global_Int('MENU_LEVEL') - 1);
	}

	if (Key1 != 0) {
/* Convert scan code to uppercase alpha ASCII code */
		RM('WS_PROCESS_KEY1');

    switch (Key1) {

		case 89 : RM('MEUTIL2^BLOCKOP /BT=2'); break; /*  Y  - Delete block */
		case 74 :                                     /*  J Delete file from disk */
			FName = '';
			Create_Global_Str('!W_ISTR_1','');
			Create_Global_Str('!W_IPARM_1','/C=0/L=1/W=60/ML=80/H=/T=');
			RM( 'USERIN^DATA_IN /PRE=!W_/#=1/T=NAME OF FILE TO DELETE?/X=3/Y=4');
			if (Return_Int) {
				FName = Global_Str('!W_ISTR_1');
				if (File_Exists(FName)) {
					Del_File(FName);
					if (Error_Level) {
						RM('MEERROR');
					} else {
						Make_Message(Caps(FName) + ' Deleted.');
					}
				} else {
					RM('MEERROR^MessageBox /B=1/T=ERROR/M=FILE ' + Caps(FName) + ' NOT FOUND!');
				}
			}
			Set_Global_Str('!W_ISTR_1','');
      break;
    case 68 :                                     /*  D  Save/Done */
			RM('MEUTIL1^SAVEFILE');
			if (Return_Int == 1) {
				RM('MEUTIL1^LOADFILE');
			}
      break;
    case 81 :                                     /*  Q  Quit */
			RM('EXIT');
      break;
    case 79 :                                     /*  O  CtrlK-help*/
      if (Global_Int('@WS_CTRL_HLP_OFF@')) {
        Set_Global_Int('@WS_CTRL_HLP_OFF@',0);
      } else {
        Set_Global_Int('@WS_CTRL_HLP_OFF@',1);
      }
      break;
    case 83 :                                     /*  S  Save file */
			Save_File;
      /* If you want to be prompted, which is not the way
         Wordstar does it, replace the above line with
         this one.
         RM('MEUTIL1^SAVEFILE');
      */
      break;
    case 88 :                                     /*  X  Save and quit */
      RM('EXIT^AutoSave /NP=1');
			RM('EXIT');
      break;
    case 80 :                                     /*  P  Print */
      if (Block_Stat == 0) {
        RM('MEUTIL3^Print_File_Block');
      } else {
        RM('MEUTIL3^Print_File_Block /B=1');
      }
      break;
    case 78 :                                     /*  N  RESERVED */
      break;
    case 66 :                                     /*  B  mark Block Begin */
      Make_Message('Press ^K^K or '+Global_Str('!BM_KEY15')+' to stop.');
			Str_Block_Begin;
      break;
    case 75 :                                     /*  K  mark Block End */
      Make_Message(''); Block_End; break;
    case 72 :                                     /*  H  Hide block */
      rm('Hide_Block'); break;
    case 67 :                                     /*  C  Block copy */
      RM('MEUTIL2^BLOCKOP /BT=0'); break;
    case 73 :                                     /*  I  Indent */
      RM('MEUTIL2^IndBlk'); break;
    case 84 :                                     /*  T  Mark word */
      RM('MarkWord'); break;
    case 85 :                                     /*  U  Undent */
      RM('MEUTIL2^UndBlk'); break;
    case 86 :                                     /*  V  Block move */
      RM('MEUTIL2^BLOCKOP /BT=1'); break;
    case 87 :                                     /*  W  Save block */
      RM('MEUTIL1^SAVEBLCK'); break;
    case 82 :                                     /*  R  Load block */
      RM('MEUTIL1^Splice'); break;
    case 48 :                                     /*  0  */
      RM('TEXT^SET_MARK 10'); break;
    case 49 :                                     /*  1  */
      RM('TEXT^SET_MARK 1'); break;
    case 50 :                                     /*  2  */
      RM('TEXT^SET_MARK 2'); break;
    case 51 :                                     /*  3  */
      RM('TEXT^SET_MARK 3'); break;
    case 52 :                                     /*  4  */
      RM('TEXT^SET_MARK 4'); break;
    case 53 :                                     /*  5  */
      RM('TEXT^SET_MARK 5'); break;
    case 54 :                                     /*  6  */
      RM('TEXT^SET_MARK 6'); break;
    case 55 :                                     /*  7  */
      RM('TEXT^SET_MARK 7'); break;
    case 56 :                                     /*  8  */
      RM('TEXT^SET_MARK 8'); break;
    case 57 :                                     /*  9  */
      RM('TEXT^SET_MARK 9'); break;
    case 45 :                                     /*  -  */
      RM('TEXT^SET_MARK');
    }
	}
}

macro CTRLO {

int x,y,c;

	if (Global_Int('@WS_CTRL_HLP_OFF@')) {
		Make_Message('<CtrlO>');
		Read_Key;
		Make_Message('');
	} else {
    if (WhereY >= 12) { x=1; y=3; } else { x=1; y=12; }
    Set_Global_Int('MENU_LEVEL',Global_Int('MENU_LEVEL') + 1);
    Put_Box(x,y,x+41,y+11,0,M_B_Color,'<CtrlO>',true);

    Write('C - Center line',  x+2,y+1,0,M_T_Color);Draw_Attr(x+2,y+1,M_S_Color,1);
    Write('W - Word wrap ' + COPY('offon',(Not(Wrap_Stat) * 3) + 1,3),x+2,y+2,0,M_T_Color);
                                                   Draw_Attr(x+2,y+2,M_S_Color,1);
    Write('R - Right margin', x+2,y+3,0,M_T_Color);Draw_Attr(x+2,y+3,M_S_Color,1);
    Write('Up- Upcase word',  x+2,y+4,0,M_T_Color);Draw_Attr(x+2,y+4,M_S_Color,2);
    Write('A - capitalize',   x+2,y+5,0,M_T_Color);Draw_Attr(x+2,y+5,M_S_Color,1);
    Write('Lt- Line left',    x+2,y+6,0,M_T_Color);Draw_Attr(x+2,y+6,M_S_Color,2);
    Write('/ - Separate line',x+2,y+7,0,M_T_Color);Draw_Attr(x+2,y+7,M_S_Color,1);
    Write('D - Data stamp',   x+2,y+8,0,M_T_Color);Draw_Attr(x+2,y+8,M_S_Color,1);
    Write('O - Insert Pascal options',x+2,y+9,0,M_T_Color);Draw_Attr(x+2,y+9,M_S_Color,1);

    Write('L - Left margin',   x+20,y+1,0,M_T_Color);Draw_Attr(x+20,y+1,M_S_Color,1);
    Write('X - Margin release',x+20,y+2,0,M_T_Color);Draw_Attr(x+20,y+2,M_S_Color,1);
    Write('Z - translate R/L', x+20,y+3,0,M_T_Color);Draw_Attr(x+20,y+3,M_S_Color,1);
    Write('Down- Locase word', x+20,y+4,0,M_T_Color);Draw_Attr(x+20,y+4,M_S_Color,4);
    Write('PgUp- Upcase line', x+20,y+5,0,M_T_Color);Draw_Attr(x+20,y+5,M_S_Color,4);
    Write('Rt- Line right',    x+20,y+6,0,M_T_Color);Draw_Attr(x+20,y+6,M_S_Color,2);
    Write('B - Data&Time',     x+20,y+7,0,M_T_Color);Draw_Attr(x+20,y+7,M_S_Color,1);
    Write('T - Time stamp',    x+20,y+8,0,M_T_Color);Draw_Attr(x+20,y+8,M_S_Color,1);

    Read_Key;
		Kill_box;
		Set_Global_Int('MENU_LEVEL',Global_Int('MENU_LEVEL') - 1);
	}

    switch (Key2) {
    case 46 : RM('TEXT^Center'); break;  /*  C - Center line     */
    case 17 :                           /*  W - Word wrap       */
      Wrap_Stat = NOT(Wrap_Stat); break;
    case 19 : RM('RightMar'); break;    /*  R - Right margin    */
    case 38 : RM('LeftMar'); break;     /*  L - left margin     */
    case 45 : RM('ResetMar'); break;    /*  X - margin release  */
    case 44 : RM('RCorr'); break;       /*  Z - translate R/L   */
    case 72 : RM('Word_Case /o=u'); break;/*  Up- Upcase word   */
    case 80 : RM('Word_Case /o=l'); break;/*  Down- Locase word */
    case 30 : RM('Word_Case'); break;   /*  A - capitalize      */
    case 73 :                           /*  PgUp- Upcase line   */
      c = C_Col; Goto_Col(1);
      RM('Swcase /t=e /o=u');
      Goto_Col(c); break;
    case 75 : RM('MLine /M=L'); break;  /*  Lt- Line left       */
    case 77 : RM('MLine /M=R'); break;  /*  Rt- Line right      */
    case 53 : RM('MLine /M=S'); break;  /*  / - Separate line   */
    case 48 : RM('WS^DateTime'); break; /*  B - Data&Time       */
    case 32 :                           /*  D - Data stamp      */
      RM('WS^EuroDate'); Text(Return_Str); break;
    case 20 :                           /*  T - Time stamp      */
      RM('WS^Time24'); Text(Return_Str); break;
    case 24 :                           /*  O - Time stamp      */
      if ( Get_Extension(File_Name) == 'PAS' ) {
        Push_Undo;
        Goto_Col(1);
        Goto_Line(1);
        Text(Global_Str('PasCompFlags')); CR;
        Text(Global_Str('PasCompMemory')); CR;
        Pop_Undo;
      }
    }
}

macro CTRLW {
	Push_Undo;
	RM('ScrollDn');
	if (WhereY < (Win_Y2 - 1)) {
		Down;
	}
	Pop_Undo;
}

macro CTRLZ {
	Push_Undo;
	RM('ScrollUp');
	if (WhereY > (Win_Y1 + 1)) {
		Up;
	}
	Pop_Undo;
}

macro DELWORDR {
	str Temp_Line;
	Messages = FALSE;
	Push_Undo;
  if ((Cur_Char == ' ') || AT_EOL ) {
    while( (Cur_Char == ' ') || AT_EOL ) {
			Del_Char;
		}
		Goto Macro_Exit;
	}
	if (XPos(Cur_Char,'.,:;!?',1)) {
		Del_Char;
		Goto Macro_Exit;
	}
  while ((XPos(Cur_Char,Word_delimits,1) == 0) && (NOT(At_Eol) || NOT(At_Eof))) {
		if (NOT(At_Eol && (Cur_Char == char(255)))) {
			Del_Char;
		} else {
			Down;
			Temp_Line = Get_Line;
			Del_Line;
			Up;
			Eol;
			Mark_Pos;
			Text(Temp_Line);
			Goto_Mark;
			Goto Macro_Exit;
		}
	}
	if (XPos(Cur_Char,'.,:;!?',1)) {
		Del_Char;
	}
Macro_Exit:
	Pop_Undo;
	Refresh = TRUE;
	Messages = TRUE;
}

macro DELWHOLEWORD {
  Push_Undo;
  right; Word_Left;
  rm('DELWORDR');
  Pop_Undo;
}

macro HOMEKEY {
	Push_Undo;
	if (Global_Int('WS_Mode')) {
		RM('^TopWin');
		Goto_Col(1);
	} else {
		if (C_Col != 1) {
			Goto_Col(1);
		} else {
			RM('^TopWin');
			Goto_Col(1);
		}
	}
	Pop_Undo;
}

macro ENDKEY {
	Push_Undo;
	if (Global_Int('WS_Mode')) {
		RM('^BotWin');
		if (At_Eol) {
			Eol;
		}
	} else {
		if (!(At_Eol)) {
			Eol;
		} else {
			RM('^BotWin');
			if (At_Eol) {
				Eol;
			}
		}
	}
	Pop_Undo;
}

macro RIGHTMAR {
	int J2,J3;

	Set_Global_Int('!W_IINT_1',Right_Margin);
	Create_Global_Str('!W_IPARM_1','/TP=1/C=1/L=1/W=3/H=WP/T=RIGHT MARGIN COLUMN NUMER (<ESC> for cursor column)?/MIN=1/MAX=254');
	RM( 'USERIN^DATA_IN /PRE=!W_/#=1/T=RIGHT MARGIN/X=8/Y=3');
	if (Return_int) {
    J2 = Global_Int('!W_IINT_1');
	} else {
		J2 = C_Col;
	}
	Set_Global_Int('!W_IINT_1',0);
	J3 = Pos('R',Format_Line);
	if (J3 == 0) {
		J3 = Pos('r',Format_Line);
	}
	if (J3 != 0) {
		Format_Line = Str_Del(Format_Line,J3,1);
		Format_Line = Str_Ins(' ',Format_Line,J3);
	}
	Format_Line = Str_Del(Format_Line,J2,1);
	Format_Line = Str_Ins('R',Format_Line,J2);
	Right_Margin = J2;
	Set_Global_Int('Right_Margin',J2);
}

macro LEFTMAR {
	int J2;
	Push_Undo;

	Set_Global_Int('!W_IINT_1',Indent_Level);
	Create_Global_Str('!W_IPARM_1','/TP=1/C=1/L=1/W=3/H=WP/T=LEFT MARGIN COLUMN NUMER (<ESC> for cursor column)?/MIN=1/MAX=254');
	RM( 'USERIN^DATA_IN /PRE=!W_/#=1/T=LEFT MARGIN/X=8/Y=3');
	if (Return_int) {
		J2 = Global_Int('!W_IINT_1');
		Refresh = FALSE;
		Messages = FALSE;
		Mark_Pos;
		Goto_Col(J2);
		Set_Indent_Level;
		Goto_Mark;
		Messages = True;
		Refresh = TRUE;
	} else {
		Set_Indent_Level;
		J2 = C_Col;
	}
	Set_Global_Int('!W_IINT_1',0);

	Set_Global_Int('Left_Margin',J2);
	Pop_Undo;
}

macro RESETMAR {
	Refresh = FALSE;
	Messages = FALSE;
	Mark_Pos;
	if (NOT(Global_Int('Margin_Released'))) {
		Set_Global_Int('Margin_Released',TRUE);
		Right_Margin = 254;
		Goto_Col(1);
	} else {
		Set_Global_Int('Margin_Released',FALSE);
		Goto_Col(Global_Int('Left_Margin'));
		Right_Margin = Global_Int('Right_Margin');
	}
	Set_Indent_Level;
	Goto_Mark;
	Refresh = TRUE;
	Redraw;
	Messages = TRUE;
}

macro INDENT {
	Indent;
	Set_Global_Int('Left_Margin',C_Col);
}

macro UNDENT {
	Undent;
	Set_Global_Int('Left_Margin',C_Col);
}

MACRO DosScreen Dump{
              /*
                  To <AltF5> From Edit;
                  Заглянуть в оригинальный экран DOS
                  Взято из софтпанорамы, встречается
                  у многих авторов. *BZ*.
              */
  int mc ,tc ,fc, vm;
  mc = Mem_Col; tc = Time_Col; fc = Fkey_Row;
  Mem_Col = 0;  Time_Col = 0;  Fkey_Row = 0;
  if ( Ext_Video_Status == 1 ) { vm = Ext_Video_Mode;
  } else { vm = Video_Mode; }
  Rest_Dos_Screen;
  Read_Key;
  Mem_Col = mc;  Time_Col = tc; Fkey_Row = fc;
  Set_Video_Mode(vm); New_Screen;
  rm('InsTgl'); rm('InsTgl'); /* в некоторых режимах теряется курсор */
  Make_Message('');
}
macro UM  {
  /*  Выгрузка макросов  */
  str nms[3];
  int nm;
  nms = parse_str('/#=',Global_Str('Macro_History'));
  Val(nm,nms);
  if(  ( nm > 0 )  ) {
    Return_str = Global_Str('Macro_History'+ nms);
  } else {
    /* Make_message (''Макро Не загружались!'');
    goto CONEC;   */
    Return_str = '' ;
  }
BOX:
  Run_Macro('USERIN^Querybox /N=0 /C=1 /W=20 /T=Выгрузка Макросов /L=2 /P=Введите имя Макро: /HISTORY=MACRO_HISTORY');
    if(  ( Return_int == 0 )  ) {  goto CONEC; };
        if(  ( Inq_Macro(Return_Str) == 1 )  ) {
          Unload_Macro(Return_Str);
          Make_message ('Макроc  '+ CAPS(Return_Str)+ '  удален из памяти !');
        } else {
        RM('Meerror^Messagebox /M=Макрос '+CAPS(Return_Str)+' не загружен');
        }
    CONEC:
}

macro DelMsg TRANS {             /*  Удалить с экрана последнее сообщение  */
  Make_Message ('');
}

/*    Макрокоманда EuroDate возвращает текущую дату в более привычном для  */
/*  нас формате: число-месяц-год, напр. 08-Mar-90. Результат возвращается  */
/*  в строковой переменной Return_Str.                                     */
/*         Run_Macro (''Extens^EuroDate'');  Text (Return_Str);              */

macro EuroDate DUMP {
  int  Mounth;
  if(  VAL (Mounth ,Copy(DATE ,1,2))  ) { /* Контроль ошибки */ }
  if ( Global_Int('DateFormLat') ) {
    if(  Mounth == 1   ) { Return_Str = '-Jan-'; }   /*  Янв   Jan  */
    if(  Mounth == 2   ) { Return_Str = '-Feb-'; }   /*  Фев   Feb  */
    if(  Mounth == 3   ) { Return_Str = '-Mar-'; }   /*  Мар   Mar  */
    if(  Mounth == 4   ) { Return_Str = '-Apr-'; }   /*  Апр   Apr  */
    if(  Mounth == 5   ) { Return_Str = '-May-'; }   /*  Май   May  */
    if(  Mounth == 6   ) { Return_Str = '-Jun-'; }   /*  Июн   Jun  */
    if(  Mounth == 7   ) { Return_Str = '-Jul-'; }   /*  Июл   Jul  */
    if(  Mounth == 8   ) { Return_Str = '-Aug-'; }   /*  Авг   Aug  */
    if(  Mounth == 9   ) { Return_Str = '-Sep-'; }   /*  Сен   Sep  */
    if(  Mounth == 10  ) { Return_Str = '-Oct-'; }   /*  Окт   Oct  */
    if(  Mounth == 11  ) { Return_Str = '-Nov-'; }   /*  Ноя   Nov  */
    if(  Mounth == 12  ) { Return_Str = '-Dec-'; }   /*  Дек   Dec  */
  } else {
    if(  Mounth == 1   ) { Return_Str = '-Янв-'; }   /*  Янв   Jan  */
    if(  Mounth == 2   ) { Return_Str = '-Фев-'; }   /*  Фев   Feb  */
    if(  Mounth == 3   ) { Return_Str = '-Мар-'; }   /*  Мар   Mar  */
    if(  Mounth == 4   ) { Return_Str = '-Апр-'; }   /*  Апр   Apr  */
    if(  Mounth == 5   ) { Return_Str = '-Май-'; }   /*  Май   May  */
    if(  Mounth == 6   ) { Return_Str = '-Июн-'; }   /*  Июн   Jun  */
    if(  Mounth == 7   ) { Return_Str = '-Июл-'; }   /*  Июл   Jul  */
    if(  Mounth == 8   ) { Return_Str = '-Авг-'; }   /*  Авг   Aug  */
    if(  Mounth == 9   ) { Return_Str = '-Сен-'; }   /*  Сен   Sep  */
    if(  Mounth == 10  ) { Return_Str = '-Окт-'; }   /*  Окт   Oct  */
    if(  Mounth == 11  ) { Return_Str = '-Ноя-'; }   /*  Ноя   Nov  */
    if(  Mounth == 12  ) { Return_Str = '-Дек-'; }   /*  Дек   Dec  */
  }
  Return_Str = Str_Ins(Copy(DATE,4,2),Return_Str,1) + Copy(DATE,7,2);
}

/*  /////////////////////////////////////////////////////////////////////  */

/*     Возвращает в Return_Str системное время в 24-х часовом формате      */
/*      16:25:58     Run_Macro ('Extens^Time24'); Text (Return_Str);       */

macro Time24 DUMP {
  int  hour;
  str  ti[12];
  ti = TIME;
  if(  VAL(hour ,Copy (ti ,1 ,2))  ) { /* Ошибка */ }
  hour = hour + ((Pos ('pm' ,ti) != 0) * 12);
  Return_Str = STR (hour);
  if(  Length (Return_Str) == 1  ) {
    Return_Str = Str_Ins ('0' ,Return_Str ,1);
  }
  Return_Str = Return_Str + Copy (ti ,3 ,6);
}

/*  /////////////////////////////////////////////////////////////////////  */

/*   Макрокоманда DateTime предназначена для подмены стандартной функции   */
/*   <Shift-F2>; возвращает дату / время в другом формате.                 */

macro DateTime DUMP {
  Run_Macro ('WS^EuroDate'); Text (Return_Str);
  Run_Macro ('WS^Time24');   Text ('  ' + Return_Str);
}


 /* ************************************************************************** */
 /*                                 MULTI-EDIT MACRO                           */
 /*                                                                            */
 /* Name: WSMTCH :пришлось переобозвать MULMTCH в WSMTCH для возможности       */
 /*               запуска из LANGUAGE                                          */
 /*                                                                            */
 /*                (C) Copyright 1988 by American Cybernetics, Inc.            */
 /*                          Modified by Kevin Jackson                         */
 /*                     Last modified by Boris Zulin 1993                      */
 /* ************************************************************************** */

macro MULMTCH TRANS {  /*  Поиск "скобок"- начало/конец          */

   str  Str1,     /* Primary   - First Match string */
        EStr1,    /* Secondary - End   Match string */
        T_Str, S_Str, FStr ;

  int  Direction,   /* 1 = search forward, 0 = backward */
       B_Count,     /* Match count.  0 = match found */
       S_Res,       /* Search results */
       Second_Time ;


  Second_Time = False;
  Refresh = False;     /* Turn screen refresh off */
  Str1 = '';
  EStr1 = '';

 Find_Match_Str:

  if(  (Cur_Char == '(')  ) {   /* Setup match for '(' */
    Str1 = '(';
    EStr1 = ')';
    Direction = 1;
    S_Str = '[()]';
		GOTO Start_Match;
  }

  if(  (Cur_Char == ')')  ) {   /* Setup match for ')' */
    Str1 = ')';
    EStr1 = '(';
    Direction = 0;
    S_Str = '[()]';
		GOTO Start_Match;
  }

  if(  (Cur_Char == '{')  ) {   /* Setup match for '{' */
    Str1  = '{';
    EStr1 = '}';
    Direction = 1;
    S_Str = '[@{@}]';
		GOTO Start_Match;
  }

  if( (Cur_Char == '}') ) { /* Setup match for '}' */
    Str1 = '}';
    EStr1 = '{';
    Direction = 0;
    S_Str = '[@{@}]';
		GOTO Start_Match;
  }

  if(  (Cur_Char == '[')  ) {   /* Setup match for '{' */
    Str1  = '[';
    EStr1 = ']';
    Direction = 1;
    S_Str = '[@[@]]';
		GOTO Start_Match;
  }

  if( (Cur_Char == ']') ) { /* Setup match for '}' */
    Str1 = ']';
    EStr1 = '[';
    Direction = 0;
    S_Str = '[@[@]]';
		GOTO Start_Match;
  }

  /* If we didn''t find a word to match the first time then try again */
  if(  NOT( Second_Time )  ) {
    Second_Time = True;
		First_Word;
		GOTO Find_Match_Str;
  }

	Make_Message('NOTHING to Match');
	GOTO Macro_Exit;

 Start_Match:
  Reg_Exp_Stat = True;
  Ignore_Case = True;
  B_Count = 1;
  S_Res = 1;
	Make_Message('Matching...  Hit <ESC> to Stop.');
	Working;

 MATCH_LOOP:   /* Main loop */
          /* If the <ESC> key is pressed while matching then abort the search */
  if(  check_key  ) {
    if(  key1 == 27  ) {
			Make_Message('Match Aborted.');
			goto macro_exit;
    }
  }

  if(  S_Res == 0  ) {   /* If last search result was false then exit */
		GOTO Error_Exit;
  }

  if(  B_Count == 0  ) { /* If match count is 0 then success */
		GOTO Found_Exit;
  }

  if(  Direction == 1  ) { /* Perform search based on direction */
		Right;
    while(  NOT (At_EOL) && ((Cur_CHar == '|255') | (Cur_Char == '|9'))  ) {
			Right;
    }
    S_Res = Search_Fwd(S_Str,0);
  } else {
		Left;
    while(  (Cur_Char == '|255') |
          (Cur_Char == '|9')  ) {
			Left;
    }
    S_Res = Search_Bwd(S_Str,0);
  }

  if(  S_Res == 0  ) {   /* If search failed then exit */
		GOTO Macro_Exit;
  }

  FStr = Caps(Found_Str);

  if(  Length(FStr) > 2  ) {
      if(  XPOS(Copy(FStr,1,1),'|9 ',1)   ) {
         FStr = Copy(FStr,2,20);
    }
    if(  XPOS(Copy(FStr,Length(FStr),1),'|9 ',1)  ) {
      FStr = Copy(FStr,1,Length(FStr) - 1);
    }
  }

                              /* If we found the first match string then */
  if(  XPOS(FStr,STR1,1)  ) {
    ++B_Count;   /* Inc the match count */
		GOTO Match_Loop;
  }

  if(  XPOS(FStr,ESTR1,1)  ) { /* If we found the second match string then */
    --B_Count;    /*   decrement the match count */
		GOTO Match_Loop;
  }

 Error_Exit:     /* Go here for unsucessfull match */
   Make_Message('Match NOT Found for ' + Str1);
	GOTO Macro_Exit;

 Found_Exit:     /* Go here for successfull match */
   Make_Message('Match Found for ' + Str1);
 Macro_Exit:
  Refresh = True;
	Redraw;
}                             /*  WSMTCH  - Multi_Match                */

macro RCorr {
  /* корректировка слова, ошибочно набранного не на том регистре */
  /* Л.Г.Бунич 24.09.90 */

  int i,k;
  char c;
  str cyr,lat;

  INSERT_MODE = FALSE; i = 0;
  lat = '%^&qwertyuiop[]asdfghjkl;''zxcvbnm,.QWERTYUIOP{}ASDFGHJKL:"ZXCVBNM<>';
  cyr = ':,.йцукенгшщзхъфывапролджэячсмитьбюЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ';
process:
  if(  C_COL < 2  ) { goto wordend; }
  Left;
  if(  i == 0  ) {
    if(  ASCII(CUR_CHAR) < 128  )  i = 1;  else  i = 2;
  }
  k = 1;
  while( (k <= LENGTH(lat))  ) {
    if(  i == 1  ) {
      if(  CUR_CHAR == COPY(lat,k,1)  ) {
        TEXT(COPY(cyr,k,1));
        Left; goto process;
      }
    } else {
      if(  CUR_CHAR == COPY(cyr,k,1)  ) {
        TEXT(COPY(lat,k,1));
        Left; goto process;
      }
    }
    ++k;
  }
wordend:;
}

macro MarkWord TRANS2 {

  Push_Undo;
  Block_Off;
  Mark_Pos;
  if(  Xpos(Cur_Char,Word_Delimits,1)  ) {
    Word_Right;                 /*  мы вне слова  */
  } else {
    Right; Word_Left;           /*  мы внутри слова  */
  }
  Col_Block_Begin;
  Forward_Till(Word_Delimits);
  Left;  Block_End;
  Goto_Mark;
  Pop_Undo;
}

macro Swcase TRANS2 {
  /*  Изменение регистра русских и латинских букв

    Параметры:
      /t=e  - конвертирование идет до конца строки
      /t=l  - конвертируется одна (текущая) буква
              (если /t опущено, конвертирование идет до конца слова)
      /o=u  - преобразование в заглавные буквы
      /o=l  - преобразование в строчные буквы
              (если /o опущено, регистр букв переключается, т.е. заглавные
               буквы преобразуются в строчные, а строчные - в заглавные)
   */
  int n,im,d = 0,k;
  char c;
  str t,o;

  t = Parse_Str('/T=',Mparm_Str);
  if(  t == ''  ) { t = Parse_Str('/t=',Mparm_Str); }
  t = Lower(t);
  if(  (t != '') & (t != 'e') & (t != 'l')  ) {
    Make_Message('SWCASE: invalid parameter /t');
    Beep; GoTo F;
  }
  o = Parse_Str('/O=',Mparm_Str);
  if(  o == ''  ) { o = Parse_Str('/o=',Mparm_Str); }
  o = Lower(o);
  if(  (o != '') & (o != 'u') & (o != 'l')  ) {
    Make_Message('SWCASE: invalid parameter /o');
    Beep; GoTo F;
  }
  k = 0; im = Insert_Mode;
  Push_Undo; Insert_Mode = False; Refresh = False;
process:
  if(  At_EOF  ) { GoTo Finish; }
  if(  At_EOL  ) {
    if(  t != 'e'  ) { Down; Home; }
    GoTo Finish;
  }
  n = ASCII(Cur_Char);
  if(  n < 65   ) { GoTo NextChar; }
  if(  n < 91   ) { GoTo lower; }                         /* A-Z */
  if(  n < 97   ) { GoTo NextChar; }
  if(  n < 123  ) { GoTo upper; }                         /* a-z */
  if(  n < 128  ) { GoTo NextChar; }
  if(  n < 144  ) { GoTo lower; }                         /* А-П */
  if(  n < 160  ) {                                          /* Р-Я */
     d = 1;
     if(  o == 'u'  ) { GoTo NextChar; }
     c = Char(n + 80); GoTo convert;
  }
  if(  n < 176  ) { GoTo upper; }                         /* а-п */
  if(  n < 224  ) { GoTo NextChar; }
  if(  n > 239  ) { GoTo NextChar; }
  d = 1;                                                  /* р-я */
  if(  o == 'l'  ) { GoTo NextChar; }
  c = Char(n - 80); GoTo convert;
upper:
  d = 1;
  if(  o == 'l'  ) { GoTo NextChar; }
  c = Char(n - 32); GoTo convert;
lower:
  d = 1;
  if(  o == 'u'  ) { GoTo NextChar; }
  c = Char(N + 32);
convert:
  d = 1;
  Text(c); ++k; GoTo ChkOpt;
NextChar:
  if(  (t == '') & (d)  ) {
    if(  Xpos(Cur_Char,Word_Delimits + '_',1)  ) { GoTo Finish; }
  }
  Right;
ChkOpt:
  if(  t != 'l'  ) { GoTo process; }
Finish:
  Pop_Undo;
  Make_Message(Str(k)+' letters converted.');
  Insert_Mode = im;
  Refresh = True;
F:
}

macro Word_Case TRANS2 {
  /*  Изменение регистра русских и латинских слов

    Параметры:
      /o=u  - преобразование в заглавные буквы
      /o=l  - преобразование в строчные буквы
              (если /o опущено, первая буква слова становится заглавной,
              а остальные - строчными)
   */

  str o;

  o = Parse_Str('/O=',Mparm_Str);
  if(  o == ''  ) { o = Parse_Str('/o=',Mparm_Str); }
  o = Lower(o);
  if(  (o != '') & (o != 'u') & (o != 'l')  ) {
    Make_Message('SWCASE: invalid parameter /o');
    Beep; GoTo F;
  }
  Push_Undo;
  Refresh = False;
  if(  Xpos(Cur_Char,Word_Delimits,1)  ) {      /*  мы вне слова  */
    Word_Right; GoTo FixBegin;
  }
SmartStep:                                    /*  мы внутри слова  */
  if(  Xpos(Cur_Char,Word_Delimits + '_',1)  ) {
    Right; GoTo FixBegin; }
  if(  C_Col > 1  ) {
    Left; GoTo SmartStep; }
FixBegin:
  if(  o == ''  ) {
    RM ('SWCASE /O=U/T=L');
    RM ('SWCASE /O=L');
  } else if(  o == 'u'  ) {
    RM ('SWCASE /O=U');
  } else if(  o == 'l'  ) {
    RM ('SWCASE /O=L');
  }
  Pop_Undo; Refresh = True;
F:
}

macro Word_Sch TRANS2 {
/*  Параметр:
        опущен - поиск слов
        /R     - замена слов
 */
  int i,res;
  str w,ss;
  str dlm  = '[~0-9A-Z_a-zА-пр-я]';
  str meta = '?%$*+[]{}||@';

  Push_Undo;
  if(  Xpos(Cur_Char,Word_Delimits,1)  ) {
    Word_Right;                 /*  мы вне слова  */
  } else {
    Right; Word_Left;           /*  мы внутри слова  */
  }
  Return_Str = Get_Word(Word_Delimits);   /*  формируем умалчиваемое слово  */
  res = Reg_Exp_Stat;  Reg_Exp_Stat = True;
  if(  XPos('/R',Caps(Mparm_str),1) == 0  ) {      /*  просто поиск  */
    RM('USERIN^QUERYBOX /W=60/T=Поиск слов/P= Введите слово');
    if(  Return_Int == 0  ) { GoTo F; }
    Call PrePro;
    ss = Global_Str('SWITCHES');
    w = ss; i = XPos('X',ss,1);               /*  отменим режим X  */
    if(  i > 0  ) { w = Str_Del(ss,i,1); }
    Set_Global_Str('SWITCHES',w);
    Push_Key(9,15); Push_Key(9,15);
    RM('MEUTIL2^SEARCH');
    Set_Global_Str('SWITCHES', ss) ;            /*  восстановим режимы  */
  } else {                                          /*  поиск с заменой  */
    RM('USERIN^QUERYBOX /W=60/T=Поиск и замена слов/P= Введите слово');
    if(  Return_Int == 0  ) { GoTo F; }
    Call PrePro;
    RM('USERIN^QUERYBOX /W=60/T=Поиск ' + Return_Str + '/P= Заменить на');
    if(  Return_Int == 0  ) { GoTo F; }
    w = Return_Str; i = 0;
prloop:  ++i;
    if(  Xpos(Str_Char(w,i),'$%&#^@',1)  ) {
      w = Str_Ins('@',w,i); ++i;               /*  метасимволы допускаются  */
    }
continueR:
    if(  i < Length(w)  ) { GoTo prloop; }
    Set_Global_Str('REPLACE_STR', '#1' + w + '#3') ;
    ss = Global_Str('REPL_SWITCHES');
    w = ss; i = XPos('X',ss,1);               /*  отменим режим X  */
    if(  i > 0  ) { w = Str_Del(ss,i,1); }
    Set_Global_Str('REPL_SWITCHES',w);
    Push_Key(9,15); Push_Key(9,15); Push_Key(9,15);
    RM('MEUTIL2^S_REPL');
    Set_Global_Str('REPL_SWITCHES', ss) ;       /*  восстановим режимы  */
  }
  GoTo F;

PrePro:
  w = Return_Str; i = 0;
pploop:  ++i;
  if(  Xpos(Str_Char(w,i),meta,1)  ) {
    w = Str_Ins('@',w,i); ++i;                 /*  метасимволы допускаются  */
  }
continue:
  if(  i < Length(w)  ) { GoTo pploop; }
  Set_Global_Str('SEARCH_STR', '{%}||{' + dlm + '}' + w
               + '{$}||{' + dlm + '}') ;
  Ret;

F:
  Reg_Exp_Stat = res;
  Pop_Undo;
}

/* ******************************MULTI-EDIT MACRO******************************

Name:  CHaNGe_UP & CHaNGe_DN
			Два макроса предназначенных для быстрого
			поика вперед и назад измененных строк

		  Stern i K°   Стерник Геннадий       10-04-92 16:25

***************************************************************************** */
macro Chng_Up  FROM EDIT {
  working;
  Refresh = 0;
  Up;
  while(  ((not(Line_Changed)) & (not (AT_EOF)) & (C_Line > 1 ))  ) {
	Up;
  };
  Refresh = 1;
  Redraw;
};

macro Chng_Dn  FROM EDIT {
  Working;
  Refresh = 0;
  Down;
  while(  ((not(Line_Changed)) & (not (AT_EOF)) & (C_Line > 1 ))  ) {
	Down;
  };
  Refresh = 1;
  Redraw;
};

macro Trim { /* удаляет лидирующие и заверщающие пробелы/знаки TAB  */
             /* Строка берется и помещается в Return_Str            */
str s;
  s = Return_Str;
  if ( SVL(s) > 0 ) {
    while ( (Str_Char(s,1) == ' ' ) | (Str_Char(s,1) == Char(9) ) |
          (Str_Char(s,1) == Char(255) ) ) {
      s = Str_Del(s,1,1);
    }
    while ( (Str_Char(s,SVL(s)) == ' ' ) | (Str_Char(s,SVL(S)) == Char(9) ) |
          (Str_Char(s,SVL(S)) == Char(255) ) ) {
      s = Str_Del(s,SVL(s),1);
    }
  }
  Return_Str = s;
}

macro MLine TRANS2 {
  /*  Сдвиг строки согласно отступа
    Параметры:
      /M=L  - влево, используя Left margin
      /M=R  - вправо, используя Right margin
      /M=S  - в разные стороны от позиции курсора
              ( <Left margin - Right margin> )
   */

  str o, s, f;
  int n, l, r;

  o = Parse_Str('/M=',Mparm_Str);
  if(  o == ''  ) { o = Parse_Str('/m=',Mparm_Str); }
  o = Lower(o);
  if(  (o != 's') && (o != 'r') && (o != 'l')  ) {
    Make_Message('MLine: invalid parameter /M');
    Beep;
    GoTo ExitMacro;
  }
/* ******************************************************************* */
  Push_Undo;
  if ( o == 's' ) {
    if ( (! AT_EOL) & (! AT_EOF) & (C_Col > 1) ) {
      s = Get_Line;
      r = Global_Int('Right_Margin');
      l = Global_Int('Left_Margin');
      if (l<=0) { l = 1; }
      --l; f = '';
      n = C_Col;
      Return_Str = copy(s,1,n-1);
      rm('Trim');
      o = Return_Str;
      Return_Str = Str_Del(s,1,n-1);
      rm('Trim');
      s = Return_Str;
      if ( ((SVL(o) + SVL(s) + l) <= r) & (SVL(s)>0 ) ) {
        n = r - l - SVL(o) - SVL(s);
        Pad_Str(f,l,' ');
        o = f + o;
        Pad_Str(f,n,' ');
        s = o + f + s;
        Put_Line(s);
      }
    }
  } else if ( o == 'r' ) {
    Return_Str = Get_Line;
    rm('Trim');
    s = Return_Str; o = '';
    r = Global_Int('Right_Margin');
    if ( SVL(S) < r ) {
      l = r - SVL(s);
      Pad_Str(o,l,' ');
      s = Str_Ins(o,s,1);
      Put_Line(s);
    }
  } else if ( o == 'l' ) {
    Return_Str = Get_Line;
    rm('Trim');
    s = Return_Str; o = '';
    l = Global_Int('Left_Margin');
    if (l<=0) { l = 1; }
    --l;
    Pad_Str(o,l,' ');
    s = Str_Ins(o,s,1);
    Put_Line(s);
  }
  Pop_Undo; New_Screen;
/* ******************************************************************* */
ExitMacro:
}

macro SaveAllFiles; { /* записывает все измененные файлы на диск */
int jx, wi;
      Make_Message(' Saving files...');
      jx = 0;
      Refresh = false;
      wi = Window_ID;
		while( jx < Window_Count ) {
			Switch_Window(++jx);
			if ( (File_Changed != 0) & (CAPS(FILE_NAME) != '?NO-FILE?') ) {
				SAVE_FILE;
				if ( Error_Level != 0 ) {
					Refresh = True;
					Redraw;
					Make_Message('Incorrect file name or error saving file.');
					RM('MEERROR^Beeps /C=1');
					Goto exit;
				}
			}
		}
exit:
Switch_Win_ID(wi);
Make_Message('');
Refresh = True;
Redraw;
}

macro RusSpCh Trans2 {
  /* проверка орфографии блока или целого файла
     Параметры:
     /F=FileName - путь и имя файла программы проверки
     /Q=1        - запросить имя файла и установить переменную
     /B=1        - проверять блок
  */
  int b,i;
  str s, f;

  s = Parse_Str('/F=',Mparm_Str);
  if(  s != ''  ) { Set_Global_Str('Rus_Spell_Spec',s); }

  i = Parse_Int('/Q=',Mparm_Str);
  if(  i || (Global_Str('Rus_Spell_Spec') == '') ) {
    Return_Str = Global_Str ( 'Rus_Spell_Spec' );
    RM('USERIN^QUERYBOX /W=40/ML=65/T= Проверка орфографии '+
        '/P= Введите имя программы проверки ');
    if (Return_Int == 1) {
      Set_Global_Str('Rus_Spell_Spec',Return_Str);
    }
    if( i ) Goto Ex_M;
  }

  s = Global_Str('Rus_Spell_Spec');
  if ( SVL(S)==0 ) {
    Make_Message(' Отсутствует имя программы проверки орфографии...');
    goto Ex_M;
  }

  s = Parse_Str('/B=',Mparm_Str);
  if(  s == '1'  ) { /* проверяем блок */
    if ( Block_Stat == 0 ) {
      Make_Message (' Блок не отмечен...');
      Goto Ex_M;
    }
    s = TEMP_PATH + 'RSC_TEMP.ME';
    rm('SaveAllFiles');
    if (File_Exists(s)) {
      Del_File(s);
      if (Error_Level) RM('MEERROR');
    }
    Make_Message(' Записываем блок на диск...');
    rm('MEUTIL1^SaveBlck /FN='+s);
    if ( ! Return_Int ) Goto Ex_M;
    f = Global_Str('Rus_Spell_Spec') + ' ' + s;
    Return_Str = f;
    Make_Message(Return_Str);
    rm('MEUTIL1^EXEC /MEM=0/SWAP=0/CMD=1/SCREEN=2');
    b = 0; Refresh = False;
    while( (b < Window_Count) & (FILE_NAME != s) ) Switch_Window(++b);
    Refresh = true;
    if (FILE_NAME != s ) {
      Erase_Window;
      LOAD_FILE(s);
      RM('EXTSETUP');
    } else {
      Return_Str = s;
      rm('MESYS^LDFILES /LC=1/NC=1/NW=1/CW=2/NHA=1');
      if (FILE_NAME != s ) {
        b = 0; Refresh = False;
        while( (b < Window_Count) & (FILE_NAME != s) ) Switch_Window(++b);
        Refresh = true;
      }
    }
  } else { /* проверяем весь файл */
    s = File_Name;
    rm('SaveAllFiles');
    f = Global_Str('Rus_Spell_Spec') + ' ' + s;
    Return_Str = f;
    Make_Message(Return_Str);
    rm('MEUTIL1^EXEC /MEM=0/SWAP=0/CMD=1/SCREEN=2');
    Erase_Window;
    Load_File(S);
    RM('EXTSETUP');
  }
Redraw;
Ex_M:
}

macro Drag_Line Trans2 { /* сдвигает строку влево/вправо
                            /A=1 - вправо, иначе влево */
 str s,p;
  s = Parse_Str('/A=',Mparm_Str); p = ' '+Char(9)+Char(255);
  if(  s == '1'  ) {
    s = Get_Line;
    if ( ! (((C_Col == 1) & At_EOL) | At_EOF))
      Push_Undo;
      s = ' '+s;
      Put_Line(s);
      Redraw;
      Pop_Undo;
  } else {
    s = Get_Line;
      if (XPos(Str_Char(s,1),p,1) > 0 ) {
      Push_Undo;
      s = Str_Del(s,1,1);
      Put_Line(s);
      Redraw;
      Pop_Undo;
    }
  }
}

macro InstGlbVar TRANS2 { /* устанавливает значение глобальной переменной */

  int  menu = menu_create ;
  int  x;
  str  VN, PR;

  if (Global_Int('InGlVar') > 0) {       /* тип переменной по умолчанию */
    x = Global_Int('InGlVar'); --x;
  } else x = TRUE;

  /* создаем меню */
  menu_set_item(menu,1,'V - Переменная : ','',
                '/QK=1/C=3/W=30/ML=30/L=1/HISTORY=InVarV_HISTORY',0,0,0);
  menu_set_item(menu,2,'P - Параметр   : ','',
                '/QK=1/C=3/W=30/ML=30/L=2/HISTORY=InVarP_HISTORY',0,0,0);
  menu_set_item(menu,3,'Тип параметра:','','/C=3/W=39/L=3',10,0,0);
  menu_set_item(menu,4,'S - Строковый    ','','/QK=1/C=19/L=3',12,(! x),0);
  menu_set_item(menu,5,'N - Численный    ','','/QK=1/C=19/L=4',12,   x ,0);
	return_int = menu;

  /* вызываем меню */
  RM('UserIn^Data_In /HN=1/S=1/#=5/T=Ввод значения переменной');

  /* считываем переменные */
    x = (menu_item_int( menu, 4, 2 ) == 0);
    VN = menu_item_str( menu, 1, 2 );
    PR = menu_item_str( menu, 2, 2 );

  /* устанавливаем переменные */
  if( (return_int != 0) & (VN != '') ) {
    Set_Global_Int('InGlVar',x+1);
    if ( x ) {
      Make_Message('Int - '+VN+' = '+PR);
      if (Val(x,PR) == 0) Set_Global_Int(VN,x);
    } else {
      Make_Message('Str - '+VN+' = '+PR);
      Set_Global_Str(VN,PR);
    }
	}
  menu_delete( menu );
}

macro GetGlbVar TRANS2 { /* выдает значение глобальной переменной */

  int  menu = menu_create ;
  int  x;
  str  VN, PR;

  if (Global_Int('InGlVar') > 0) {       /* тип переменной по умолчанию */
    x = Global_Int('InGlVar'); --x;
  } else x = TRUE;

  /* создаем меню */
  menu_set_item(menu,1,'V - Переменная : ','',
                '/QK=1/C=3/W=30/ML=30/L=1/HISTORY=InVarV_HISTORY',0,0,0);
  menu_set_item(menu,2,'Тип параметра:','','/C=3/W=39/L=2',10,0,0);
  menu_set_item(menu,3,'S - Строковый    ','','/QK=1/C=19/L=2',12,(! x),0);
  menu_set_item(menu,4,'N - Численный    ','','/QK=1/C=19/L=3',12,   x ,0);
	return_int = menu;

  /* вызываем меню */
  RM('UserIn^Data_In /HN=1/S=1/#=4/T=Индикация значения переменной');

  /* считываем переменные */
    x = (menu_item_int( menu, 3, 2 ) == 0);
    VN = menu_item_str( menu, 1, 2 );

  /* читаем переменные */
  if( return_int != 0 ) {
    Set_Global_Int('InGlVar',x+1);
    if ( x ) {
      PR = Str(Global_Int(VN));
    } else {
      PR = Global_Str(VN);
    }
    if ( Parse_Int('/N=',MParm_Str) ) {
      Make_Message(VN+':'+PR);
    } else {
      Make_Message(PR);
    }
	}
  menu_delete( menu );
}

macro GetAllGlbVar TRANS2 { /* выдает значение ВСЕХ глобальных переменных */
                            /* в текущее окно, используется для отладки   */
                            /* /C=1 - со значениями                       */

 /* ME имеет список глобальных переменных, и используя функции First_Global
    и Next_Global можно просканировать весь список. ME не знает, какого типа
    данная переменная. При запросе численного значения строковой переменной
    будет возвращен 0, строкового значения численной переменной - пустая
    строка.
 */

  int  x,i;
  str  VN, PR;

  Push_Undo;
  x = Parse_Int('/C=',MParm_Str);

  CR;
  Text('--------------------------------------------------------------');CR;
  Text('--                   Строковые переменные                   --');CR;
  Text('--------------------------------------------------------------');CR;
  i = 0;
  VN = First_Global( i );
  while ( VN != '' ) {
    if ( x ) {
      PR = ' : '+Global_Str(VN);
    } else {
      PR = '';
    }
    Text(VN+PR); CR;
    VN = Next_Global( i );
  }
  CR;

  Text('--------------------------------------------------------------');CR;
  Text('--                   Численные переменные                   --');CR;
  Text('--------------------------------------------------------------');CR;
  i = 1;
  VN = First_Global( i );
  while ( VN != '' ) {
    if ( x ) {
      PR = ' : '+Str(Global_Int(VN));
    } else {
      PR = '';
    }
    Text(VN+PR); CR;
    VN = Next_Global( i );
  }
  Pop_Undo;
}

macro SEARCH_PREV TRANS { /* поиск предыдущего значения */
int x,r;
	Set_Global_Str('Switches',Caps(Global_Str('Switches')));
  x = XPos('B',Global_Str('Switches'),1);
  if( x == 0 ) {
		Set_Global_Str('Switches',Global_Str('Switches') + 'B');
  } else {
    Set_Global_Str('Switches',Str_Del(Global_Str('Switches'),x,1));
  }

  r = Global_Int('REPSEARCH');
  SET_GLOBAL_INT('REPSEARCH',1);
  RM('MEUTIL2^S_AND_R');
  SET_GLOBAL_INT('REPSEARCH',r);

  x = XPos('B',Global_Str('Switches'),1);
  if(  x == 0  ) {
		Set_Global_Str('Switches',Global_Str('Switches') + 'B');
  } else {
    Set_Global_Str('Switches',Str_Del(Global_Str('Switches'),x,1));
  }
}

macro Mark_Block { /* отметка блока */
int i;
str s;
  if ((Block_Stat > 0) & (! Marking)) Block_Off;
  if ( Marking ) {
    Block_End;
    Make_Message('');
    Goto Exit_M;
  }
  s = Global_Str('!BM_KEY15');
  Make_Message('Press '+s+' to stop marking...');
  i = Parse_int('/O=', MParm_Str);
  if ( i == 1 ) { /* Stream */
    Str_Block_Begin;
  } else if ( i == 2 ) { /* Linear */
    Block_Begin;
  } else if ( i == 3 ) { /* Column */
    Col_Block_Begin;
  } else Make_Message(' Invalid parameters');
Exit_M:
}

macro Hide_Block { /* скрывает/показывает блок */
  if ( Marking ) Block_End;
  if ( Block_Stat > 0 ) { /* убираем отметку с сохранением */
    Set_Global_Int('WS_SBl_Stat',Block_Stat);
    Set_Global_Int('WS_SBl_Line1',Block_Line1);
    Set_Global_Int('WS_SBl_Line2',Block_Line2);
    Set_Global_Int('WS_SBl_Col1',Block_Col1);
    Set_Global_Int('WS_SBl_Col2',Block_Col2);
    Block_Off;
  } else { /* восстанавливаем отметку, если сохранена */
    if ( Global_Int('WS_SBl_Stat') > 0 ) {
    Block_Line1 = Global_Int('WS_SBl_Line1');
    Block_Line2 = Global_Int('WS_SBl_Line2');
    Block_Col1  = Global_Int('WS_SBl_Col1');
    Block_Col2  = Global_Int('WS_SBl_Col2');
    Block_Stat  = Global_Int('WS_SBl_Stat');

    Set_Global_Int('WS_SBl_Stat' ,0);
    Set_Global_Int('WS_SBl_Line1',0);
    Set_Global_Int('WS_SBl_Line2',0);
    Set_Global_Int('WS_SBl_Col1' ,0);
    Set_Global_Int('WS_SBl_Col2' ,0);
    }
  }
Make_Message(''); New_Screen;
}

macro FillBlock TRANS2 { /* заполняет блок указанными символами */

  int  menu = menu_create ;
  int  x,m,l1,l2,c1,c2,i;
  str  V,S,z;

  if ( Block_Stat != 2 ) {
    Make_Message(' Отметьте перед заполнением прямоугольный блок');
    Goto Ex_M;
  }
  if ( Marking ) Block_End;
  x = TRUE; i = TRUE;

  /* создаем меню */
  v = Global_Str('FILL_HISTORY');
  if ( v != '' ) {
    v = Parse_Str('/#=',v);
    v = Global_Str('FILL_HISTORY'+v);
  }
  menu_set_item(menu,1,'F - Заполнитель : ',v,
                '/QK=1/C=3/W=37/ML=256/L=1/HISTORY=FILL_HISTORY',0,0,0);
  menu_set_item(menu,2,'Тип заполнения:','','/C=3/W=21/L=3',10,0,0);
  menu_set_item(menu,3,'C - Колонка   ','','/QK=1/C=3/L=4',12,   x,0);
  menu_set_item(menu,4,'L - Линия     ','','/QK=1/C=3/L=5',12,(! x),0);
  menu_set_item(menu,5,'Длина строки превышает ширину блока :','','/C=24/W=37/L=3',10,0,0);
  menu_set_item(menu,6,'I - Вставить текст               ','','/QK=1/C=24/L=4',12,   i ,0);
  menu_set_item(menu,7,'O - Перекрыть                    ','','/QK=1/C=24/L=5',12,(! i),0);
  return_int = menu;

  /* вызываем меню */
  RM('UserIn^Data_In /HN=1/S=1/W=68/#=7/T= Заполнение блока ');

  /* считываем переменные */
  x = (menu_item_int( menu, 3, 2 ) != 0);
  i = (menu_item_int( menu, 6, 2 ) != 0);
  V = menu_item_str( menu, 1, 2 );

  /* удаляем меню */
  menu_delete( menu );

  l1 = Block_Line1; c1 = Block_Col1;
  l2 = Block_Line2; c2 = Block_Col2;
  if( (return_int != 0) & (V != '') ) {
    if ( x ) {
      x = C2 - C1 +1;
      s = v;
      while ( (SVL(S)+SVL(v))<=x ) s = s + v;
    } else s = v;
    Push_Undo; Working;
    Refresh = false;
    Mark_Pos;
    if ( SVL(s) > (c2-c1+1) ) {
      if ( i ) {
        m = c2 + 1;
      } else {
        m = c1 + SVL(s) - 1;
      } } else { m = c2 + 1;
    }
    for ( x = l1; x <= l2; ++x ) {
      Goto_Line(x);
      v = Get_Line;
      if ( c1 > 1 ) {
      z = Copy(v,1,c1-1); Pad_Str(z,c1-1,' ');
      } else { z = ''; }
      v = z+s+Copy(v,m,SVL(v)-m+1);
      Put_Line(v);
    }
    Block_Line1 = l1; Block_Col1 = c1;
    Block_Line2 = l2; Block_Col2 = c2;
    Goto_Mark;
    Refresh = true;
    Redraw;
    Pop_Undo;
	}
Ex_M:
}

macro Dup_Line TRANS2 { /* Дублирует текущую строку */
int Temp_Insert_Mode;
str SL;
  Push_Undo;
  SL = Get_Line;
	Temp_Insert_Mode = Insert_Mode;
	Insert_Mode = True;
	Eol;
	Cr;
  Put_Line(SL);
	Insert_Mode = Temp_Insert_Mode;
  Redraw;
  Pop_Undo;
}

macro Dup_Char TRANS2 { /* дублирует символ из предыдущей строки */
str c[1];
  if ( C_LINE > 1 ) {
    Push_Undo;
    Up; c = Cur_Char;
    Down; Text(c); Redraw;
    Pop_Undo;
  }
}

macro ExpandBlock TRANS2 { /* расширяет блок до позиции курсора */

  if (MARKING) Goto ExitMacro;
  if ( Block_Stat == 0 ) {Make_Message(' No block'); Goto ExitMacro; }
  Push_Undo;
  if ((C_Col <= Block_Col1) && (C_Line <= Block_Line1)) {
    Block_Col1 = C_Col; Block_Line1 = C_Line;
  } else {
    Block_Col2 = C_Col; Block_Line2 = C_Line;
  }
  Redraw;
  Pop_Undo;
ExitMacro:
}

macro SwitchVideoMode; { /* переключает режим 25/[30/33] строки */
                         /* Использован код макро SETUP.TGLVID  */
    int VMode;           /* The video mode before the toggle    */

	Refresh = False;
  VMode = Video_Mode;
  if ( VMode == 0 ) { Set_Video_Mode(1);
  } else Set_Video_Mode(0);
  mouse = mouse;
	RM('SETSCRN');

	REFRESH = TRUE;
	NEW_SCREEN;
	Mou_Set_Limits( 1, 1, Screen_Width, Screen_Length );
}

macro SearchLongLine; { /* Поиск строки длиной более правого отступа */
	WORKING;
	Refresh = False;
	if (Parse_Str('/D=',MParm_Str)=='B') {
    while ((C_Line > 1) && (Length(Get_Line) <= Right_Margin)) Up;
	} else {
    while ((At_EOF != true) && (Length(Get_Line) <= Right_Margin)) Down;
	}
	Refresh = True;
	Redraw;
}

macro SetWindow; {      /* Установить указанное окно */

  int n,i,j,w,rf;

  if ((Val(i,MParm_Str)==0) && (i<=Window_Count)) {
    rf = Refresh;
    Refresh = false;
    w = Cur_Window;
    j = 0;
    for (n=1; n<=Window_Count; n++) {
      Switch_Window(n);
      if ((Window_Attr & $80)==0) j++;
      if (j==i) Break;
    }
    if (j != i) Switch_Window(w);
    Window_Attr = Window_Attr & $FE;
    Refresh = rf;
    Redraw;
  }
}


//                                              (R) BZSoft Inc. 1993.
