macro_file PASCAL;
/*******************************************************************************
														MULTI-EDIT MACRO FILE

Name: PASCAL

Description:	Language support for Pascal

PASMTCH - Construct matching
PAS_IND - Smart indent
PASTEMP - Template editing (old style)
PASSETX - Sets up the template expansion data global string.

							 (C) Copyright 1991 by American Cybernetics, Inc.
***************************************************************************** **/

macro PASMTCH TRANS {
/*******************************************************************************
																MULTI-EDIT MACRO

Name: PASMTCH

Description:  Этот макрос предназначен для поиска блок-операторов
 языка Паскаль - скобок (),[], операторных скобок BEGIN/END, а также
 CASE/END, ASM/END, RECORD/END, OBJECT/END, REPEAT/UNTIL.
 Кроме операторных скобок производится поиск соответствующего
 открывающего оператора для зарезервированного слова ELSE -
 IF или CASE, что может понадобиться при изучении и отладке.
 Поиск производится с учетом комментариев языка ПАСКАЛЬ (* *) { }.

Параметры:
  /RC=1 - После поиска происходит возврат курсора в первоначальную позицию
  /HI=1 - При нахождении пары происходит выделение пространства между
          парой цветом

     (C) Copyright 1991 by American Cybernetics, Inc.
     (C) Portion copyrighr 1993 by BZSoft, Inc. (& GALASoft Untd.Gr.Int.)
*******************************************************************************/

  str  Str1, Str2,        /* Строки поиска */
       Str3 = '',
       Str4 = '',
       Str5 = '',
       T_Str,S_str, FStr ;

  int  Direction,         /* 1 = поиск вперед, 0 = назад */
           B_Count,       /* количество открытых пар. 0 = пара найдена */
           C_Count = 0,   /* счетчик количества ELSE */
           E_Flag = 0,    /* при нахождении внутри CASE игнорирует IF */
           S_Res,         /* Результат поиска */
					 Second_Time,
           oldrefresh = refresh,
					 shift_stat = peek( 0, 0x417 ),
           T_Col, T_Line, /* Позиция старта поиска */
           JX,
           F_Line, F_Col; /* Найденная позиция */

  T_Line = C_Line;        /* Сохраняем текущую позицию */
	T_Col = C_Col;

  Push_Undo;
  Mark_Pos;

	Second_Time = False;
  Refresh = False;        /* Запрещаем изменения на экране */
  B_Count = 1;

Find_Match_Str:

  FStr = Get_Line;

  if( (Cur_Char == '(') && (copy(FStr,C_Col+1,1) != '*' ) ){
    Str1 = '(';                 /* Установки для поиска пары '(' */
    Str2 = ')';                 /* исключая комментарии */
		Direction = 1;
		S_Str = Str1+'||'+Str2+'||[''{}]||{(@*}||{@*)}';
		GOTO Start_Match;
	}

  if( (Cur_Char == ')') && (C_Col > 1) && (copy(FStr,C_Col-1,1) != '*') ) {
    Str1 = ')';                 /* Установки для поиска пары ')' */
    Str2 = '(';                 /* исключая комментарии */
		Direction = 0;
		S_Str = Str1+'||'+Str2+'||[''{}]||{(@*}||{@*)}';
		GOTO Start_Match;
	}

  if(  (Cur_Char == '[')  ) {   /* Установки для поиска пары '[' */
    Str1 = '[';
    Str2 = ']';
		Direction = 1;
    S_Str = '@[||@]||[''{}]||{(@*}||{@*)}';
		GOTO Start_Match;
	}

  if(  (Cur_Char == ']')  ) {   /* Установки для поиска пары ']' */
    Str1 = ']';
    Str2 = '[';
		Direction = 0;
    S_Str = '@]||@[||[''{}]||{(@*}||{@*)}';
		GOTO Start_Match;
	}

  if(  At_EOL  ) { /* Если в конце строки - переместиться на первое слово */
		First_Word;
	}

  while ( NOT(XPOS(Cur_Char,';. })]|9|255',1)) && (C_Col > 1) ) {
    Left;          /* Перемещаемся к началу слова */
  }

  if((Cur_Char == ' ')  |
     (Cur_Char == '|9') |
     (Cur_Char == '|255')){ /* Если позиция на пустом месте - переходим к */
    Word_Right;             /* слову правее */
	}

  T_Col = C_Col; T_Line = C_Line; /* Конечная установка стартовой позиции */
  T_Str = Caps( Get_Word(';. {([|9|255') );  /* Взять текущее слово */

  if (T_Str == 'REPEAT') {  /* REPEAT >> UNTIL */
    Str1 = 'REPEAT';
    Str2 = 'UNTIL';
    Str3 = '';
		Direction = 1;
    S_Str = '{%||[|9 ;})]{'+Str1+'}||{'+Str2+'}$||[ |9;{(]}||[''{}]||{(@*}||{@*)}';
		GOTO Start_Match;
	}

  if (T_Str == 'UNTIL') {   /* REPEAT << UNTIL */
    Str1 = 'UNTIL';
    Str2 = 'REPEAT';
    Str3 = '';
    Direction = 0;
    Word_Left;
		Left;
    S_Str = '{%||[|9 ;})]{'+Str1+'}||{'+Str2+'}$||[ |9;{(]}||[''{}]||{(@*}||{@*)}';
    GOTO Start_Match;
	}

  if ( (T_Str=='BEGIN')  || (T_Str=='RECORD') ||
       (T_Str=='OBJECT') || (T_Str=='ASM') ||
       (T_Str=='CASE')  ) {   /* $$$ >> END */
    Str1 = T_Str;
		Str2 = 'END';
    Str3 = '{BEGIN}||{RECORD}||{OBJECT}||{CASE}||{ASM}';
		Direction = 1;
    S_Str = '{%||[|9 ;})@]=]{'+Str1+'}||{'+Str2+'}||'+Str3+'$||[ |9;.{(]}||[''{}]||{(@*}||{@*)}';
    GOTO Start_Match;
	}

  if(  T_Str == 'END'  ) {    /* $$$ << END */
		Str1 = 'END';
    Str2 = '';
    Str3 = '{BEGIN}||{RECORD}||{OBJECT}||{CASE}||{ASM}';
		Direction = 0;
		Word_Left;
		Left;
    S_Str = '{%||[|9 ;})@]=]{'+Str1+'}||'+Str3+'$||[ |9;.{(]}||[''{}]||{(@*}||{@*)}';
		GOTO Start_Match;
	}

  if(  T_Str == 'ELSE'  ) {   /* IF|CASE << ELSE */
    Str1 = '';
    Str2 = '';
    Str3 = '{CASE}||{:}||{IF}';
    Str4 = 'END';
    Str5 = 'ELSE';
    Direction = 0;
    C_Count = 1;
    B_Count = 0;
    Word_Left;
		Left;
    S_Str = '{%||[|9 ;})@]]{'+Str5+'}||{'+Str4+'}||'+Str3+'$||[ |9;.{(]}||[''{}]||{(@*}||{@*)}';
		GOTO Start_Match;
	}

    /* Если не получилось найти слова, попробуем еще раз */
	if(  NOT( Second_Time )  ) {
		Second_Time = True;
		First_Word;
		GOTO Find_Match_Str;
	}

	Make_Message('NOTHING to Match');
	GOTO Macro_Exit;

Start_Match:
  if( (Direction == 0) && ((Length(Str1) > 2) || (Length(Str5) > 0)) ) {
    T_Col = T_Col + Length(Str1) + Length(Str5) - 1;
  }
	Reg_Exp_Stat = True;
	Ignore_Case = True;
  S_Res = 1;
	Make_Message('Matching...  Press <ESC> to Stop.');
	Working;

MATCH_LOOP:   /* Основной цикл */

  /* Нажатие <ESC> прекращает поиск */
	if(  check_key  ) {
		if(  key1 == 27  ) {
			Make_Message('Match Aborted.');
      Goto_Mark;
			goto macro_exit;
		}
	}

  if(  S_Res == 0  ) {   /* Если результат поиска false - выходим */
		GOTO Error_Exit;
	}

  if((B_Count == 0) && (C_Count == 0)) {/* Пара успешно найдена */
		GOTO Found_Exit;
	}

  if((B_Count == 0) && (C_Count > 0)) {/* Поиск внутреннего блока завершен */
    Str1 = '';
    if( E_Flag == 0 ) {
      Str3 = '{CASE}||:||{IF}';
    } else {
      Str3 = '{CASE}';
    }
    S_Str = '{%||[|9 ;})]{'+Str5+'}||{'+Str4+'}||'+Str3+'$||[ |9;.{(]}||[''{}]||{(@*}||{@*)}';
	}

  if(  Direction == 1  ) { /* Направление поиска задается Direction */
		Right;
    while(  NOT( At_EOL) && (Cur_CHar == '|255')  ) {
			Right;
		}
		S_Res = Search_Fwd(S_Str,0);
	} else {
		Left;
		while(  (Cur_CHar == '|255') |
					(Cur_Char == '|9')  ) {
			Left;
		}
		S_Res = Search_Bwd(S_Str,0);
	}

  if(  S_Res == 0  ) {   /* При неуспешном поиске выходим */
		GOTO Error_Exit;
	}

  FStr = Caps(Found_Str); /* Найденную строку переводим в верхний регистр */
  /* При ограничении слова слева пробелом или ";", удаляем символ */
  if( XPOS(Copy(FStr,1,1),'|9 ;',1) ) {
    FStr = Copy(FStr,2,20);
	}

  /* При ограничении слова справа пробелом, "." или ";", удаляем символ */
  if(  XPOS(Copy(FStr,Length(FStr),1),'|9 ;.',1)  ) {
    FStr = Copy(FStr,1,Length(FStr) - 1);
	}

  if(  FStr == STR1  ) {  /* Если найдено первое значение */
    ++B_Count;            /* увеличиваем значение счетчика (+1) */
		GOTO Match_Loop;
	}

  if(  FStr == STR2  ) {  /* Если найдено второе значение */
    --B_Count;            /* уменьшаем значение счетчика (-1) */
		GOTO Match_Loop;
	}

  if( FStr == ':' ) {
    E_Flag = 1;
    Str3 = '{CASE}';
    S_Str = '{%||[|9 ;})]{'+Str5+'}||{'+Str4+'}||'+Str3+'$||[ |9;.{(]}||[''{}]||{(@*}||{@*)}';
    GOTO Match_Loop;
  }

  if(  FStr == STR4  ) {  /* При поиске пары "ELSE" могут всретится */
    Str1 = 'END';         /* внутренние операторные скобки, находим их */
    Str3 = '{BEGIN}||{RECORD}||{OBJECT}||{CASE}||{ASM}';
    S_Str = '{%||[|9 ;})@]=]{'+Str1+'}||'+Str3+'$||[ |9;.{(]}||[''{}]||{(@*}||{@*)}';
    ++B_Count;
		GOTO Match_Loop;
	}

  if(  FStr == STR5  ) {  /* Специально для ELSE */
    ++C_Count;
		GOTO Match_Loop;
	}

  if(  FStr == ''''''  ) {/* Опускаем две одинарные кавычки */
		if(  Direction == 1  ) {
			RIGHT;
		} else {
			LEFT;
		}
		GOTO Match_Loop;
	}

  if(  FStr == ''''  ) {  /* Если нашли одну кавычку, найдем к ней пару */

		Quote_Loop:

			if(  Direction == 1  ) {
				RIGHT;
			} else {
				LEFT;
			}
			if(  Direction == 1  ) {
				S_Res = Search_Fwd('''',0);
			} else {
				S_Res = Search_Bwd('''',0);
			}
			if(  S_Res == 0  ) {
				GOTO Macro_Exit;
			}
			FStr = Found_Str;
      if(  FStr == ''''''  ) {  /* Если это "кавычка внутри", опускаем ее */
				GOTO Quote_Loop;
			}
			GOTO Match_Loop;
	}

                            /* Игнорируем содержание комментария */
  if(  (Direction == 1) && (FStr == '{')  ) {
			S_Res = Search_Fwd('@}',0);
			GOTO Match_Loop;
	}
                            /* Игнорируем содержание комментария */
  if( (Direction == 0) && (FStr == '}') ) {
			S_Res = Search_Bwd('@{',0);
			GOTO Match_Loop;
	}
                            /* Игнорируем содержание комментария */
  if( (Direction == 1) && (FStr == '(*') ) {
			S_Res = Search_Fwd('@*)',0);
			GOTO Match_Loop;
	}
                            /* Игнорируем содержание комментария */
  if( (Direction == 0) && (FStr == '*)') ) {
			S_Res = Search_Bwd('(@*',0);
			GOTO Match_Loop;
	}
                            /* Если найдена третья строка */
  JX = XPOS(FStr,Str3,1);   /* при поиске назад */
  if( (Direction == 0) && ( JX ) && (copy(Str3,JX-1,1)=='{') &&
      (copy(Str3,JX+Length(FStr),1)=='}') ) {
    if( B_Count > 0 ) {     /* уменьшаем счетчик */
      --B_Count;            /* числа операторных скобок */
    } else {
      --C_Count;            /* блоков IF|CASE/ELSE */
    }
		GOTO Match_Loop;
  }                         /* при поиске вперед */
  if( (Direction == 1) && ( JX ) && (copy(Str3,JX-1,1)=='{') &&
      (copy(Str3,JX+Length(FStr),1)=='}') ){
    ++B_Count;              /* увеличиваем счетчик */
		GOTO Match_Loop;
	}

Error_Exit:                 /* Неудовлетворительный поиск */
	goto_mark;
	Make_Message('Match NOT Found');
	GOTO Macro_Exit;

Found_Exit:                 /* Пара найдена */

  F_Line = C_Line;          /* Позиция пары */
  F_Col = C_Col;
  /* если слово ограничено разделяющими символами - сместить вправо */
  if( Caps(Cur_Char) != copy(FStr,1,1) ) ++F_Col;

	if(  C_Line > T_Line  ) {
		JX = C_Line - T_Line;
	} else {
		JX = T_Line - C_Line;
	}

  Goto_Line(T_Line); Goto_Col(T_Col);
  /* goto_mark; mark_pos; */
  int tbl1 = block_line1, /* сохранить параметры текущего блока */
			tbl2 = block_line2,
			tbc1 = block_col1,
			tbc2 = block_col2,
			tblx = block_linex,
			tbcx = block_colx,
			tbs = block_stat,
			tm = Marking,
      highlight_block = parse_int('/HI=', mparm_str); /* Выделить блок? */
  if(  jx < Screen_Length  ) { /* возможно, если в пределах экрана */
		if( highlight_block ) {
			block_off;
      str_block_begin;
		}
    while( jx > 0 ) {
			--jx;
			if(  f_line > t_line  ) {
				down;
			} else {
				up;
			}
		}
	}
	else
    highlight_block = false; /* нет возможности выделить блок */

  goto_line( f_line );       /* переходим в найденую точку */
	goto_col( f_col );
	Make_Message('Match Found.');
	if( highlight_block ) {
		int t_pb = persistent_blocks;
		persistent_blocks = TRUE;
    block_end;               /* выделяем блок цветом */
    if(Direction == 1) {     /* корректируем размер блока */
      block_col2 = block_col2 + Length(FStr);
    }
    if( parse_int('/RC=', mparm_str) ) { /* воссстанавливаем позицию */
			goto_mark;
		}
		else
				pop_mark;
    refresh = true;                      /* показываем изменения */
		redraw;
    while (shift_stat == peek( 0, 0x417 )/* пока нажата клавиша сдвига */
			)
		{
      if ( check_key )                  /* или не нажата любая символьная */
			{
				shift_stat = -1;
				push_key(key1, key2);
			}
		}
    block_off;                          /* восстанавливаем параметры */
    block_line1 = tbl1;                 /* текущего блока */
    block_line2 = tbl2;
		block_col1 = tbc1;
		block_col2 = tbc2;
		block_linex = tblx;
		block_colx = tbcx;
		block_stat = tbs;
		Marking = tm;
		goto_line( c_line );
		goto_col( c_col );
		persistent_blocks = t_pb;
		refresh = TRUE;
		redraw;
	} else {
		if( parse_int('/RC=', mparm_str) ) {
			goto_mark;
		}
		else
				pop_mark;
	}
Macro_Exit:
	Refresh = OldRefresh;
	Redraw;
	Pop_Undo;
}

macro PAS_IND {
/*******************************************************************************
																MULTI-EDIT MACRO

Name: PAS_IND

Description:  This macro will perform a smart indent when the <ENTER> key is
	pressed.  This macro is called by the macro CR.

							 (C) Copyright 1991 by American Cybernetics, Inc.
*******************************************************************************/

	str C_STR;          /* Word to check for indent */
	int T_COL,T_COL2;   /* Temp column positions */
	int sig_char_found,ind_count,jx,oldrefresh = refresh;
	char found_char;
	Messages = False;

	MARK_POS;
	Reg_Exp_Stat = True;
	Down;
	Refresh = False;
	Up;
	LEFT;
	/* Check to see if we are inside a comment */
	/* Don''t go back farther than 5 lines in order to improve speed */

	if(  Search_Bwd('@{||@}||{(@*}||{@*)}',5)  ) {
		if(  (Cur_Char == '{') | (Cur_Char == '(')  ) {
			if(  (Cur_Char == '{')  ) {
				RIGHT;
			} else {
				RIGHT;
				RIGHT;
			}
			Set_Indent_Level;
			GOTO_MARK;
		/* 	Refresh := True;  */
			CR;
			GOTO MAC_EXIT;
		}
	}

	GOTO_MARK;

	MARK_POS;

	CALL SKIP_PAS_NOISE1;
	FOUND_CHAR = CUR_CHAR;
	GOTO_MARK;
 /* REFRESH := TRUE; */

	T_COL2 = C_COL;         /* Store current position */
	FIRST_WORD;              /* Go to the first word on the line */
	T_COL = C_COL;          /* Store this position */

	if(  T_COL2 < T_COL  ) {   /* If this position is greater than the original */
		T_COL = T_COL2;       /*   then store the original */
		GOTO_COL(T_COL);       /*   and go there */
	}
	if(  At_Eol == False  ) { /* If we are beyond the end of the line then */
		SET_INDENT_LEVEL;      /*   set the indent level */
	}

	T_COL = C_COL;          /* Store the current position */
													 /* Get the current word, removing any extra space */
	C_STR = ' ' + REMOVE_SPACE(CAPS( GET_WORD('; (,{') )) + ' ';
	GOTO_COL(T_COL2);        /* Put cursor on original position */
	CR;                      /* Perform a carriage return */

													 /* If the word is in this list, and the original
															position was not on the first word then
															indent */
	if(  (T_COL != T_COL2) & (LENGTH(C_STR) != 0) &
		(POS(C_STR,
	 ' PROCEDURE FUNCTION BEGIN '
	 ) != 0)  ) {
			INDENT;
	} else {
		if(  (Found_Char != ';') & (T_COL != T_COL2) & (LENGTH(C_STR) != 0)
			& (POS(C_STR,
		' VAR TYPE CONST PROCEDURE FUNCTION BEGIN IF WHILE REPEAT WITH FOR ELSE '
		) != 0)  ) {
			INDENT;
		} else {
	/***********************************************************************/
	/****>>> IF YOU DON''T WANT AN UNDENT AFTER 'END' THEN COMMENT OUT THE   */
	/****>>> FOLLOWING THREE LINES                                          */
			if(  (C_STR == ' END ')  ) {
				UNDENT;
        /* Попробуем малость добавить */
        T_Col = C_Col;
        Mark_Pos;
        Up;
        First_Word;
        if( T_Col < C_Col ) {
          Left;
          while( (Cur_Char == ' ') && (C_Col >= T_Col ) ) {
            Del_Char;
            Left;
          }
        }
        Goto_Mark;
        /* -------------------------- */
			}
		}
	}
	GOTO MAC_EXIT;

SKIP_PAS_NOISE1:

/*  Here we look for the nearest preceding nonblank character.  If it is a
	closing comment then we find the  nearest opening comment.
 */

	if(  (SEARCH_BWD('[~ |9]', 1))  ) {
		if(  (CUR_CHAR == ')')  ) {
			LEFT;
			if(  (CUR_CHAR == '*')  ) {
				JX = SEARCH_BWD('(@*', 0);
				LEFT;
				GOTO SKIP_PAS_NOISE1;
			}
			RIGHT;
			SIG_CHAR_FOUND = TRUE;
			GOTO EXIT_SKIP_PAS;
		} else {
			if(  (CUR_CHAR == '}')  ) {
				JX = SEARCH_BWD('@{', 0);
				LEFT;
				GOTO SKIP_PAS_NOISE1;
			}
		}

		SIG_CHAR_FOUND = TRUE;
		GOTO EXIT_SKIP_PAS;
	}

/*  If we failed to find a nonblank character on the current line, and the
	cursor is on line 1, we failed to find a significant character; otherwise,
	we back up a line and try again.  */

	if(  (C_LINE == 1)  ) {
		SIG_CHAR_FOUND = FALSE;
		GOTO EXIT_SKIP_PAS;
	}
	UP;
	EOL;
	GOTO SKIP_PAS_NOISE1;

EXIT_SKIP_PAS:
 /* REFRESH := TRUE; */
	RET;

MAC_EXIT:
	REFRESH = oldrefresh;
	Messages = True;
}

macro PASTEMP TRANS {
/*******************************************************************************
																MULTI-EDIT MACRO

Name: PASTEMP

Description: Creates pascal language constructs based on a single character
	to the left of the current cursor position.

							 (C) Copyright 1991 by American Cybernetics, Inc.
*******************************************************************************/

	int Temp_Col,Temp_Insert,Choice, UC;
	str XStr;
	Temp_Insert = Insert_Mode;
	if(  (At_Eol == False)  ) {
		GOTO END_OF_MAC;
	}

	Insert_Mode = True;
	Temp_Col = C_COL;

	Left;

	if(  (C_Col > 1)  ) {
		Left;
		if(  (Pos(Cur_Char,' ;})Ff|255|9') == 0)  ) {
			Goto_Col(Temp_Col);
			Goto END_OF_MAC;
		} else {
			Right;
		}
	}

  UC = false;

	if(  (Cur_Char == 'B')  ) {
		GOTO MAKEBEGIN;
	}

	if(  (Cur_Char == 'I')  ) {
		GOTO MAKEIF;
	}

	if(  (Cur_Char == 'W')  ) {
		GOTO MAKEWHILE;
	}

	if(  (Cur_Char == 'R')  ) {
		GOTO MAKEREPEAT;
	}

	if(  (Cur_Char == 'O')  ) {
		Del_Char;
		Temp_Col = Temp_Col - 1;
		GOTO MAKEFOR;
	}

	if(  (Cur_Char == 'U')  ) {
		Temp_Col = Temp_Col - 1;
		Del_Char;
		GOTO MAKEFUNCTION;
	}

	if(  (Cur_Char == 'F')  ) {

		RM('userin^xmenu /L=Select:/B=1/T=1/X=' + str(wherex) + '/Y=' + str(wherey - 2) +
				'/M=for-Next do(TE) Function()');
		choice = return_int;
		Make_Message('');
		if(  (Choice == 2)  ) {
			GOTO MAKEFUNCTION;
		} else {
			GOTO MAKEFOR;
		}
	}

	if(  (Cur_Char == 'P')  ) {
		GOTO MAKEPROCEDURE;
	}

	if(  (Cur_Char == 'C')  ) {
		GOTO MAKECASE;
	}


	UC = false;
	if(  (Cur_Char == 'b')  ) {
		GOTO MAKEBEGIN;
	}

	if(  (Cur_Char == 'i')  ) {
		GOTO MAKEIF;
	}

	if(  (Cur_Char == 'w')  ) {
		GOTO MAKEWHILE;
	}

	if(  (Cur_Char == 'r')  ) {
		GOTO MAKEREPEAT;
	}

	if(  (Cur_Char == 'o')  ) {
		Del_Char;
		Temp_Col = Temp_Col - 1;
		GOTO MAKEFOR;
	}

	if(  (Cur_Char == 'u')  ) {
		Temp_Col = Temp_Col - 1;
		Del_Char;
		GOTO MAKEFUNCTION;
	}

	if(  (Cur_Char == 'f')  ) {

		RM('userin^xmenu /L=Select:/B=1/T=1/X=' + str(wherex) + '/Y=' + str(wherey - 2) +
				'/M=for-Next do(TE) Function()');
		Choice =  return_int;

		make_message('');
		if(  (Choice == 2)  ) {
			GOTO MAKEFUNCTION;
		} else {
			GOTO MAKEFOR;
		}
	}

	if(  (Cur_Char == 'p')  ) {
		GOTO MAKEPROCEDURE;
	}

	if(  (Cur_Char == 'c')  ) {
		GOTO MAKECASE;
	}

	Goto_Col(Temp_Col);
	GOTO END_OF_MAC;

MAKEIF:
	Goto_Col(Temp_Col);
	XStr = 'f () then';
	CALL XTEXT;
	Cr;
	Goto_Col(Temp_Col);
	Indent;
	Up;
	Goto_Col(Temp_Col + 3);
	GOTO END_OF_MAC;

MAKEWHILE:
	Goto_Col(Temp_Col);
	XSTR = 'hile () Do';
	CALL XTEXT;
	Cr;
	Goto_Col(Temp_Col);
	Indent;
	Up;
	Goto_Col(Temp_Col + 6);
	GOTO END_OF_MAC;

MAKEBEGIN:
	Goto_Col(Temp_Col);
	XStr = 'egin';
	CALL XTEXT;
	First_Word;
	Temp_Col = C_Col;
	Eol;
	Cr;
	Cr;
	Goto_Col(Temp_Col);
	XStr = 'end;';
	CALL XTEXT;
	Up;
	Goto_Col(Temp_Col);
	Indent;
	GOTO END_OF_MAC;

MAKEFOR:
	Goto_Col(Temp_Col);
	XStr = 'or  :=  to  do';
	CALL XTEXT;
	Cr;
	Goto_Col(Temp_Col);
	Indent;
	Up;
	Goto_Col(Temp_Col + 4);
	GOTO END_OF_MAC;

MAKEREPEAT:
	Goto_Col(Temp_Col);
	XStr = 'epeat';
	CALL XTEXT;
	Cr;
	Goto_Col(Temp_Col - 1);
	Indent;
	Cr;
	Goto_Col(Temp_Col - 1);
	XStr = 'until ();';
	CALL XTEXT;
	Goto_Col(Temp_Col + 6);
	GOTO END_OF_MAC;

MAKEPROCEDURE:
	Goto_Col(Temp_Col);
	XStr = 'rocedure  ;';
	CALL XTEXT;
	Cr;
	Goto_Col(Temp_Col - 1);
	Indent;
	XStr = 'begin';
	CALL XTEXT;
	Cr;
	Cr;
	XStr = 'end;';
	CALL XTEXT;
	Up;
	Goto_Col(Temp_Col);
	Indent;
	Up;
	Up;
	Goto_Col(Temp_Col + 9);
	GOTO END_OF_MAC;

MAKEFUNCTION:
	Goto_Col(Temp_Col);
	XStr = 'unction  ;';
	CALL XTEXT;
	Cr;
	Goto_Col(Temp_Col - 1);
	Indent;
	XStr = 'begin';
	CALL XTEXT;
	Cr;
	Cr;
	XStr = 'end;';
	CALL XTEXT;
	Up;
	Goto_Col(Temp_Col);
	Indent;
	Up;
	Up;
	Goto_Col(Temp_Col + 8);
	GOTO END_OF_MAC;

MAKECASE:
	Goto_Col(Temp_Col);
	XStr = 'ase () of';
	CALL XTEXT;
	Cr;
	Cr;
	Goto_Col(Temp_Col - 1);
	XStr = 'end;';
	CALL XTEXT;
	Up;
	Goto_Col(Temp_Col - 1);
	Indent;
	Up;
	Goto_Col(Temp_Col + 5);
	GOTO END_OF_MAC;

XTEXT:
	if(  UC  ) {
		XSTR = CAPS(XSTR);
	}
	TEXT( XSTR );
	RET;

END_OF_MAC:
	Insert_Mode = Temp_Insert;

}

/****************************************************************************
																MULTI-EDIT MACRO

Name: PASSETX

Description:  This macro is run every time a PASCAL type file is loaded.
							The template expansion global variable is defined here the
							first time this macro gets run.  The following is a brief
							description of the control codes contained in the template.

		'юC=' = Expansion case type.
								0 = case sensitive.    Keyword  - case sensitive
																			Expansion - verbatim.
								1 = case insensitive.  Keyword  - case insensitive
																			Expansion - All caps.
								2 = case insensitive.  Keyword  - case insensitive
																			Expansion - First letter caps.
								3 = case insensitive.  Keyword  - case insensitive
																			Expansion - dependent on keyword.
		'юM=' = Minimum number of characters in keyword required for an
							expansion to occurr.
	238 - 'ю' = Parameter delimiter
	127 - '' = Field separator
	 20 - '' = Carriage return (Run CR macro)
	174 - 'о' = Carriage return (Goto starting column)
	196 - '─' = Record cursor position
	 17 - '' = Move cursor left
	 16 - '' = Move cursor right
	 24 - '' = Move cursor up
	 25 - '' = Move cursor down
	 64 - '@' = Translate next character literally
	168 - 'и' = Remember current column position
	173 - 'н' = Goto remembered column number
	240 - 'Ё' = Goto starting column
	241 - 'ё' = Toggle Insert mode
	251 - '√' = Run macro:  "/*√C^CCOMMENT"
	252 - '№' = Expand template for preceding character (be carefull about
								infinite loops)
							 (C) Copyright 1991 by American Cybernetics, Inc.
****************************************************************************/
macro PASSETX {

	if ( !Global_Int("@DA_AB_MATCH")  ) {
    key_to_window( <)>, 'pas_close_paren' );
	}

	if ( "" == Global_Str("!PAS.Tmplt0") )
  Set_Global_Str("!PAS.Tmplt0", "юC=2юM=1"+
  "begin─end;"+              /* юC=1 Case insensitive. Template will expand */
  "case (─) ofend;"+           /*      to all caps (Example:  PROCEDURE) */
	"for ─ := to do"+							/*    2 Case insensitive. Template will expand */
	"function ─;иbeginнend;"+		/*      to upper/lower (Example:  Procedure) */
	"if (─) thenиbeginнend"+		/*    3 Case first letter case sensitive  */
	"procedure ─;иbeginнend;"+	/*      following characters case insensitive. */
	"program ─;"+									/*      Template will expand to case of first */
	"pgroram ─;"+								/*      letter. */
	"repeatооuntil (─);"+					/* юM=1 Minimum expansion of 1 (only one character */
	"while (─) doиbeginнend"+		/*      is requried to expand the template */
	"{"+
	"{$"+
	"{$ifdef ─}о{$endif}"+
	"{endif}"+
	"");
  Set_Global_Str('PasCompFlags', '{$A+,B-,D+,E-,F-,G-,I+,L+,N-,O-,P-,Q-,R-,S+,T-,V+,X+}');
  Set_Global_Str('PasCompMemory','{$M 16384,0,655360}');
}

/*-----------------09-16-92 011:00am-----------------
 * Highlights to matching open paren when a closing
 * paren is entered.
 *--------------------------------------------------*/
macro pas_close_paren
{
	push_undo;
  text(')');
	left;
  rm('PASMTCH /RC=1/HI=1/LS=20');
	right;
	pop_undo;
}
