macro_file LISP;
/*******************************************************************************
														MULTI-EDIT MACRO FILE

Name: LISP

Description:  Language support for AutoLisp (Auto Cad)

LisMTCH - Construct matching
LISSETX - Sets up the template expansion data global string.
LisSTRBL- Показывает левую незакрытую до текущей позиции скобку миганием
lsp_close_paren - Макро, вызываемое при нажатии ')',Up,Down,Left и Right.
                  для поиска соответствующей парной скобки.

               (C) Copyright 1993 by BZSoft, Inc.
***************************************************************************** **/

macro LisMTCH TRANS {
/*******************************************************************************
																MULTI-EDIT MACRO

Name: LisMTCH

Description:  This macro will match occurances of ()
	and handles problems withc statements embedded in quotes or comments.

               (C) Copyright 1993 by BZSoft, Inc.
*******************************************************************************/

	str  Str1, Str2, Str3,     /* Match strings */
					 T_Str,S_str, FStr ;

	int  Direction,   /* 1 = search forward, 0 = backward */
					 B_Count,     /* Match count.  0 = match found */
					 S_Res,       /* Search result */
					 Second_Time,
           i,
           oldrefresh = refresh,
					 shift_stat = peek( 0, 0x417 ),
					 T_Row, T_Col, T_Line, /* Holds the original position */
					 JX,            /* General purpos */
           F_Line, F_Col; /* Found position */

	T_Line = C_Line;      /* Store the current position */
	T_Col = C_Col;

  Push_Undo;
	Mark_Pos;
  Refresh = False;     /* Turn screen refresh off */
  //------ Не сканируем, если область комментариев -------------------
  //------ или внутри строки -----------------------------------------
  i = C_Col;
  Goto_Col(1);
  while ( Search_Fwd('"||;',1) ) {
    if( i < C_Col ) {
      Goto_Col(i);
      GOTO Continue;
    }
    if( Found_Str == '""' ) { RIGHT; RIGHT; }
    if( Found_Str == '"' ) {
Quote_Loop1:
      RIGHT;
      S_Res = Search_Fwd('"',1);
      if( S_Res == 0 ) GOTO Error_Exit;
      if( Found_Str == '""' ) { RIGHT; RIGHT; GOTO Quote_Loop1; }
      if( i < C_Col ) GOTO Error_Exit; // область строки
      RIGHT;
    }
    if( Found_Str == ';' ) GOTO Error_Exit; // область комментария
  }
  Goto_Col(i);
  //------------------------------------------------------------------
Continue:

	Second_Time = False;
  Str3 = '';           /* Some matchs only require 2 match strings so init the 3rd */

Find_Match_Str:

	if(  (Cur_Char == '(')  ) {   /* Setup match for '(' */
		Str1 = '(';
		Str2 = ')';
		Direction = 1;
    S_Str = Str1+'||'+Str2+'||"||;';
		GOTO Start_Match;
	}

	if(  (Cur_Char == ')')  ) {   /* Setup match for ')' */
		Str1 = ')';
		Str2 = '(';
		Direction = 0;
    S_Str = Str1+'||'+Str2+'||"';
		GOTO Start_Match;
	}


	if(  At_EOL  ) {     /* If we are at the end of a line the go to the first word */
		First_Word;
	}

	if(  (Cur_Char == ' ') |
		 (Cur_Char == '|9') |
		 (Cur_Char == '|255')  ) {      /* If we are on a blank space then find a word */
		Word_Right;
	}

	T_Str = Caps( Get_Word(';. |9|255') );  /* Get the current word */

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
	Make_Message('Matching...  Press <ESC> to Stop.');
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
  Found_Str = '';
	if(  Direction == 1  ) { /* Perform search based on direction */
		Right;
		while(  NOT( At_EOL) & (Cur_CHar == '|255')  ) {
			Right;
		}
		S_Res = Search_Fwd(S_Str,0);
	} else {
		Left;
  //------ Определяем закомментированный участок ---------------------
    i = C_Col;
    Goto_Col(1);
    while( Search_Fwd( ';||"',1 ) ){
        if( i < C_Col ) {
          Goto_Col(i);
          GOTO Continue1;
        }
        if( Found_Str == '""' ) { RIGHT; RIGHT; }
        if( Found_Str == '"' ) {
Quote_Loop2:
          RIGHT;
          S_Res = Search_Fwd('"',1);
          if( S_Res == 0 ) GOTO Error_Exit;
          if( Found_Str == '""' ) GOTO Quote_Loop2;
          RIGHT;
        }
        if( Found_Str == ';' ) { LEFT; GOTO Continue1; }
      }
      Goto_Col(i);
Continue1:
  //------------------------------------------------------------------
    while( (Cur_CHar == '|255') || (Cur_Char == '|9') ) {
      LEFT;
      if( (C_Col == 1) && (C_Line == 1 ) ) {
        GOTO Error_Exit;
      }
    }
    S_Res = Search_Bwd(S_Str,1);
    if(  S_Res == 0  ) {   /* If search failed then exit */
      GOTO_Col(1);
      S_Res = 1;
      GOTO MATCH_Loop;
    }
  }

	if(  S_Res == 0  ) {   /* If search failed then exit */
		GOTO Error_Exit;
	}


  FStr = Found_Str;

															/* If we found the first match string then */
	if(  FStr == STR1  ) {
		B_Count = B_Count + 1;   /* Inc the match count */
		GOTO Match_Loop;
	}

	if(  FStr == STR2  ) {          /* If we found the second match string then */
		B_Count = B_Count - 1;    /*   decrement the match count */
		GOTO Match_Loop;
	}

  if(  FStr == ';'  ) {
    EOL;
    GOTO Match_Loop;
  }

  if(  FStr == '""'  ) {        /* If we found two single quotes the skip it */
		if(  Direction == 1  ) {
			RIGHT;
		} else {
			LEFT;
		}
		GOTO Match_Loop;
	}

															/* If we found a single quote then match it */
  if(  FStr == '"'  ) {

		Quote_Loop:

			if(  Direction == 1  ) {
				RIGHT;
			} else {
				LEFT;
			}
			if(  Direction == 1  ) {
        S_Res = Search_Fwd('"',0);
			} else {
        S_Res = Search_Bwd('"',0);
			}
			if(  S_Res == 0  ) {
				GOTO Macro_Exit;
			}
			FStr = Found_Str;
      if(  FStr == '""'  ) {
				GOTO Quote_Loop;
			}
			GOTO Match_Loop;

	}
                            /* Резерв на будущее */
														/* If we found the third string then */
														/*   if forward search then */
	if(  (Direction == 0) & (FStr == Str3)  ) {
    --B_Count;              /*   decrement the match count */
		GOTO Match_Loop;
  }                         /*   if backward search then */
	if(  (Direction == 1) & (FStr == Str3)  ) {
    ++B_Count;              /*   increment the match count */
		GOTO Match_Loop;
	}

Error_Exit:                 /* Go here for unsucessfull match */
	goto_mark;
	Make_Message('Match NOT Found');
	GOTO Macro_Exit;

Found_Exit:                 /* We go here if a match was found */

	F_Line = C_Line;  F_Col = C_Col;


	if(  C_Line > T_Line  ) {
		JX = C_Line - T_Line;
	} else {
		JX = T_Line - C_Line;
	}

	goto_mark;
	mark_pos;
	int tbl1 = block_line1,
			tbl2 = block_line2,
			tbc1 = block_col1,
			tbc2 = block_col2,
			tblx = block_linex,
			tbcx = block_colx,
			tbs = block_stat,
			tm = Marking,
			highlight_block = parse_int('/HI=', mparm_str);
	if(  jx < Screen_Length  ) {
		if( highlight_block ) {
			block_off;
			str_block_begin;
		}
		while(   jx > 0  ) {
			--jx;
			if(  f_line > t_line  ) {
				down;
			} else {
				up;
			}
		}
	}
	else
		highlight_block = false;

	goto_line( f_line );
	goto_col( f_col );
	Make_Message('Match Found.');
	if( highlight_block ) {
		int t_pb = persistent_blocks;
		persistent_blocks = TRUE;
		block_end;
		if((f_line > t_line) || ((f_line == t_line) && (f_col >= t_col)) )
			block_col2 = block_col2 + 1;
		if( parse_int('/RC=', mparm_str) ) {
			goto_mark;
		}
		else
				pop_mark;
		refresh = true;
		redraw;
		while (shift_stat == peek( 0, 0x417 )
			)
		{
			if ( check_key )
			{
				shift_stat = -1;
				push_key(key1, key2);
			}
		}
		block_off;
		block_line1 = tbl1;
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
Macro_End:
}

macro LisSTRBL TRANS {
/*******************************************************************************
																MULTI-EDIT MACRO

Name: LisSTRBL

Description:  Этот макро показывает левую незакрытую скобку для
 текущей позиции курсора (если эта скобка находится в пределах
 экрана) изменением атрибута символа (добавляется мигание).

               (C) Copyright 1993 by BZSoft, Inc.
*******************************************************************************/

	str  Str1, Str2, Str3,     /* Match strings */
					 T_Str,S_str, FStr ;

  int
           i,
					 B_Count,     /* Match count.  0 = match found */
					 S_Res,       /* Search result */
           oldrefresh = refresh,
					 shift_stat = peek( 0, 0x417 ),
           T_Row, T_Col, T_Line; /* Holds the original position */

	T_Line = C_Line;      /* Store the current position */
	T_Col = C_Col;

	Mark_Pos;
//Redraw;

  Refresh = False;     /* Turn screen refresh off */
	Str3 = '';           /* Some matchs only require 2 match strings so init the 3rd */

  Str1 = ')';
  Str2 = '(';
  S_Str = Str1+'||'+Str2+'||"';
	Reg_Exp_Stat = True;
	Ignore_Case = True;
	B_Count = 1;
	S_Res = 1;
	Working;

  //------ Не сканируем, если область комментариев -------------------
  i = C_Col;
  Goto_Col(1);
  while ( Search_Fwd('"||;',1) ) {
    if( i < C_Col ) {
      Goto_Col(i);
      GOTO MATCH_LOOP;
    }
    if( Found_Str == '""' ) { RIGHT; RIGHT; }
    if( Found_Str == '"' ) {
Quote_Loop1:
      RIGHT;
      S_Res = Search_Fwd('"',1);
      if( S_Res == 0 ) GOTO Error_Exit;
      if( Found_Str == '""' ) { RIGHT; RIGHT; GOTO Quote_Loop1; }
      if( i < C_Col ) GOTO Error_Exit; // область строки
      RIGHT;
    }
    if( Found_Str == ';' ) GOTO Error_Exit; // область комментария
  }
  Goto_Col(i);
  //------------------------------------------------------------------

MATCH_LOOP:   /* Main loop */

					/* If the <ESC> key is pressed while matching then abort the search */
	if(  check_key  ) {
		if(  key1 == 27  ) {
      goto_mark;
			goto macro_exit;
		}
	}

	if(  S_Res == 0  ) {   /* If last search result was false then exit */
		GOTO Error_Exit;
	}

	if(  B_Count == 0  ) { /* If match count is 0 then success */
		GOTO Found_Exit;
	}

  if ( ( C_Col == 1 ) && ( C_Row == 1 ) ) { GOTO Error_Exit; }

  Left;

  while( (Cur_Char == '|255') || (Cur_Char == '|9') ) {
    if ( ( C_Col == 1 ) && ( C_Row == 1 ) ) { GOTO Error_Exit; }
    Left;
  }
  //------ Определяем закомментированный участок ---------------------
  i = C_Col;
  Goto_Col(1);
  while ( Search_Fwd('"||;',1) ) {
    if( i < C_Col ) {
      Goto_Col(i);
      GOTO Continue;
    }
    if( Found_Str == '""' ) { RIGHT; RIGHT; }
    if( Found_Str == '"' ) {
Quote_Loop2:
      RIGHT;
      S_Res = Search_Fwd('"',1);
      if( S_Res == 0 ) GOTO Error_Exit;
      if( Found_Str == '""' ) GOTO Quote_Loop2;
      RIGHT;
    }
    if( Found_Str == ';' ) { LEFT; GOTO Continue; }
  }
  Goto_Col(i);
Continue:
  //------------------------------------------------------------------

  S_Res = Search_Bwd(S_Str,1);

	if(  S_Res == 0  ) {   /* If search failed then exit */
    GOTO_Col(1);
    S_Res = 1;
    GOTO MATCH_Loop;
	}


  FStr = Found_Str;
                                     /* If it ended in a space then */
	if(  XPOS(Copy(FStr,Length(FStr),1),'|9 ;.',1)  ) {
		FStr = Copy(FStr,1,Length(FStr) - 1);  /* eliminate that char */
	}
															/* If we found the first match string then */
	if(  FStr == STR1  ) {
    ++B_Count;                /* Inc the match count */
		GOTO Match_Loop;
	}

	if(  FStr == STR2  ) {          /* If we found the second match string then */
    --B_Count;    /*   decrement the match count */
		GOTO Match_Loop;
	}

  if(  FStr == '""'  ) {        /* If we found two single quotes the skip it */
    if ( (C_Col == 1) && (C_Row == 1) ) {
      GOTO Error_Exit;
    }
    LEFT;
		GOTO Match_Loop;
	}

															/* If we found a single quote then match it */
  if(  FStr == '"'  ) {

		Quote_Loop:

      if ( ( C_Col == 1 ) && ( C_Row == 1 ) ) { GOTO Error_Exit; }
      LEFT;
      S_Res = Search_Bwd('"',0);
			if(  S_Res == 0  ) {
				GOTO Macro_Exit;
			}
			FStr = Found_Str;
      if(  FStr == '""'  ) {
				GOTO Quote_Loop;
			}
			GOTO Match_Loop;
	}

														/* If we found the third string then */
  if( FStr == Str3 ) {
    --B_Count;              /*   decrement the match count */
		GOTO Match_Loop;
  }                         /*   if backward search then */

Error_Exit:                 /* Go here for unsucessfull match */
	goto_mark;
	GOTO Macro_Exit;

Found_Exit:                 /* We go here if a match was found */

  int Blink_Color;
  if ( ((Block_Stat==1)&&(block_line1<=C_Line)&&(block_line2 >= C_Line)) ||
       ((Block_Stat==2)&&(block_line1<=C_Line)&&(block_line2 >= C_Line) &&
        (block_col1<=C_Col) && (block_col2>=C_Col)) ||
       ((Block_Stat==3)&&(
        ((block_line1==C_Line)&&(block_line2>C_Line)&&(block_col1<=C_Col))||
        ((block_line1<C_Line)&&(block_line2==C_Line)&&(block_col2>=C_Col))||
        ((block_line1<C_Line)&&(block_line2>C_Line))
       ))
     ) {
    Blink_Color = H_Color | 0x80;
  } else {
    Blink_Color = T_Color | 0x88;
  }
  int S_X,S_Y;
  Refresh = true;
  Goto_Line(C_Line); Goto_Col(C_Col);
  S_X = WHEREX; S_Y = WHEREY;
  Refresh = false;
  goto_mark;
  Refresh = true;
  Redraw;
  Draw_Attr( S_X, S_Y, Blink_Color, 1 );
Macro_Exit:
	Refresh = OldRefresh;
}

/****************************************************************************
																MULTI-EDIT MACRO

               (C) Copyright 1993 by BZSoft, Inc.
****************************************************************************/
macro LISSETX {

	if ( !Global_Int("@DA_AB_MATCH")  ) {
    key_to_window( <)>,  'lsp_close_paren' );
    key_to_window( <UP>, 'lsp_close_paren /P=1' );
    key_to_window( <DN>, 'lsp_close_paren /P=2' );
    key_to_window( <LF>, 'lsp_close_paren /P=3' );
    key_to_window( <RT>, 'lsp_close_paren /P=4' );
  }

/*  if ( "" == Global_Str("!LSP.Tmplt0") )
  Set_Global_Str("!LSP.Tmplt0", "юC=2юM=1"); */
}

/*-----------------08-10-93 -------------------------
 * Highlights to matching open paren when a closing
 * paren is entered.
 *--------------------------------------------------*/
macro lsp_close_paren
{
  int c;
  c = Parse_Int('/P=',MParm_Str);
  push_undo;
  if( c == 0 ) {
    text(')');
    left;
    rm('LisMTCH /RC=1/HI=1/LS=30');
    right;
  } else {
    switch ( c ) {
      case 1 :
              Up;
              Break;
      case 2 :
              Down;
              Break;
      case 3 :
              Left;
              Break;
      case 4 :
              Right;
    }
    if( Cur_Char == ')' )
      rm('LisSTRBL');
  }
  pop_undo;
}
