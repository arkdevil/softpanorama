Macro_File LangKit;
/*****************************************************************
*                                                                *
*      Меню дополнительной языковой поддержки                    *
*      Copyright (c) Л.Г.Бунич -- Multi-Edit 6.1P --             *
*                                                                *
*    LANGKIT...... меню                                          *
*    ASM_KIT...... поддержка Ассемблера                          *
*    CLA_KIT...... поддержка Clarion                             *
*    S_KIT........ поддержка Multi-Edit                          *
*    SRC_KIT...... поддержка старого макроязыка Multi-Edit       *
*    ASM_FORMAT... отформатировать блок ассемблерных строк       *
*                                                                *
*****************************************************************/

Macro LangKit {

  str ext;

  ext = Get_Extension(File_Name);
  if        ( ext == 'ASM' ) {
    RM ('ASM_KIT');                                /* Assembler */
  } else if ( ext == 'CLA' ) {
    RM ('CLA_KIT');                                /* Clarion */
  } else if ( ext == 'S'   ) {
    RM ('S_KIT');                                  /* Multi_Edit */
  } else if ( ext == 'SRC' ) {
    RM ('SRC_KIT');                                /* Multi_Edit old */
  } else {
    Make_Message(ext + ' extension is not supported.');
  };
};

macro ASM_KIT trans2 {

  int k,BG,FG,X1,Y1,X2,Y2;
  int im;

  BG = M_T_Color >> 4;  FG = M_T_Color & $0F;
  X1 = 14; Y1 = 08; X2 = 70; Y2 = 17;
Open:
  Mark_Pos;
  Put_Box(X1,Y1,X2,Y2,BG,FG,' Assembler Support Kit ',1);
  Write('Condensed......сжатое отображение процедур',          X1+3,Y1+2,BG,FG);
  Write('Format.........форматировать выделенный блок',        X1+3,Y1+4,BG,FG);
  Write('Label..........создать метку на следующей строке',    X1+3,Y1+6,BG,FG);

  Write(' Нажмите одну из указанных клавиш (ESC - отказ) ',X1+5,Y2-1,
        M_S_Color >> 4, M_S_Color & $0F);

  for ( k = Y1+2; k < (Y2-2); k += 2 ) {
    Draw_Attr(X1+3,k,M_H_Color,1);
  };
  GoToXY(0,0);
  Read_Key; Kill_Box; GoTo_Mark;

  Switch (KEY2) {
    case 46:                                    /* Condensed */
      SET_GLOBAL_INT('Condense_Mode',1);
      SET_GLOBAL_STR('Condense_Search','proc');
      RM ('SUPPORT^CONDENSE');
      SET_GLOBAL_INT('Condense_Mode',0);
      break;
    case 33:                                    /* Format */
      RM('ASM_FORMAT');
      break;
    case 38:                                    /* Label */
      Push_Undo; Refresh = False;
      Mark_Pos; Word_Left;
      im = Insert_Mode; Insert_Mode = True;
      RM ('WORDKIT^MARK_WORD');
      EOL; CR; GoTo_Col(1);
      RM ('MEUTIL2^BLOCKOP /BT=0');
      RM ('MEUTIL2^BLOCKOFF');
      EOL; Text(':');
      GoTo_Mark; Insert_Mode = im; Refresh = True;
      Pop_Undo;
    case 1:
      break;
    default:
      GoTo Open;
  };
  Redraw;
};

macro CLA_KIT trans2 {

  int k,BG,FG,X1,Y1,X2,Y2;
  str F;

  BG = M_T_Color >> 4;  FG = M_T_Color & $0F;
  X1 = 8; Y1 = 8; X2 = 72; Y2 = 19;
Open:
  Mark_Pos;
  Put_Box(X1,Y1,X2,Y2,BG,FG,' CLARION Support Kit ',1);
  Write('Condensed.........сжатое отображение (PROCEDURE и ROUTINE)',X1+3,Y1+2,BG,FG);
  Write('Editor............вызвать текстовый редактор Clarion',      X1+3,Y1+3,BG,FG);
  Write('Generate headers..вставить заголовок программы',            X1+3,Y1+4,BG,FG);
  Write('Insert separator..вставить разделительную строчку',         X1+3,Y1+5,BG,FG);
  Write('Load INCLUDE......загрузить INCLUDE-файл',                  X1+3,Y1+6,BG,FG);
  Write('Procview..........сжатое отображение процедур',             X1+3,Y1+7,BG,FG);
  Write('Straighten........выравнять комментарии на колонку 50',     X1+3,Y1+8,BG,FG);

  Write(' Нажмите одну из указанных клавиш (ESC - отказ) ',X1+5,Y2-1,
        M_S_Color >> 4, M_S_Color & $0F);

  k = Y1+2;
  while(  k < (Y2-2)  ) {;
    Draw_Attr(X1+3,k,M_H_Color,1); ++k;
  };
  GoToXY(0,0);
  Read_Key; Kill_Box; GoTo_Mark;

  if (KEY2 == 46) {                             // Condensed
    SET_GLOBAL_INT('Condense_Mode',1);
    SET_GLOBAL_STR('Condense_Search','{ROUTINE}||{PROCEDURE}');
    F = GLOBAL_STR('Condense_Switches');
    SET_GLOBAL_STR('Condense_Switches','I');
    RM ('SUPPORT^CONDENSE');
    SET_GLOBAL_INT('Condense_Mode',0);
    SET_GLOBAL_STR('Condense_Switches',F);
  } else if ( KEY2 == 18 ) {                    // Editor call
    RM ('CLARION^CLAEDT');
  } else if ( KEY2 == 34 ) {                    // Generate Header
    RM ('CLASETUP^PROGHEAD');
  } else if ( KEY2 == 23 ) {                    // Insert separator
    RM ('CLASETUP^ROUTINE_SEP');
  } else if ( KEY2 == 38 ) {                    // Load included file
    RM ('CLASETUP^INCLUDE');
  } else if ( KEY2 == 25 ) {                    // Procedure view
    SET_GLOBAL_INT('Condense_Mode',1);
    SET_GLOBAL_STR('Condense_Search','PROCEDURE');
    F = GLOBAL_STR('Condense_Switches');
    SET_GLOBAL_STR('Condense_Switches','IX');
    RM ('SUPPORT^CONDENSE');
    SET_GLOBAL_INT('Condense_Mode',0);
    SET_GLOBAL_STR('Condense_Switches',F);
  } else if ( KEY2 == 31 ) {                    // Straightens comments
    RM ('CLASETUP^FIX_COMMENTS');
  } else if ( KEY2 != 1 ) { GoTo Open;
  };

};

Macro S_KIT trans2 {

  int k, meerr_id, temp_id, ref=Refresh, res=Reg_Exp_Stat;
  str F, Tid = User_Id + 'MEERR.TMP';
  int BG = M_T_Color >> 4, FG = M_T_Color & $0F;
  int X1 = 12, Y1 = 8, X2 = 68, Y2 = 19;

Open:
  Mark_Pos;
  Put_Box(X1,Y1,X2,Y2,BG,FG,' Multi-Edit Support Kit ',1);
  Write('Condensed...сжатое отображение (заголовки макро)', X1+3,Y1+2,BG,FG);
  Write('Debug.......запуск отладчика для текущего макро',  X1+3,Y1+4,BG,FG);
  Write('Make........компиляция и запуск отладчика',        X1+3,Y1+6,BG,FG);
  Write('Run.........запуск текущего макро',                X1+3,Y1+8,BG,FG);

  Write(' Нажмите одну из указанных клавиш (ESC - отказ) ',X1+5,Y2-1,
        M_S_Color >> 4, M_S_Color & $0F);

  k = Y1+2;
  while( k < (Y2-2) ) {
    Draw_Attr(X1+3,k,M_H_Color,1);  k += 2;
  };
  GoToXY(0,0);
  Read_Key; Kill_Box; GoTo_Mark;

  if ( KEY2 == 46 ) {                           /* Condensed */
    SET_GLOBAL_INT('Condense_Mode',1);
    SET_GLOBAL_STR('Condense_Search','%{ }*Macro ');
    F = GLOBAL_STR('Condense_Switches');
    SET_GLOBAL_STR('Condense_Switches','I');
    RM ('SUPPORT^CONDENSE');
    SET_GLOBAL_INT('Condense_Mode',0);
    SET_GLOBAL_STR('Condense_Switches',F);

  } else if (KEY2 == 32) {                      /* Debug current macro */
Debug:
    Call FormMname;
    Set_Global_Str( 'LAST_DEBUG', F );
    RM('MEDEBUG^DEBUG');

  } else if (KEY2 == 50) {                      /* Make - compile and debug */
    Refresh = False;  temp_id = Window_Id;  meerr_id = 0;
    RM('AutoSave');

    k = 0;      // очистим старое окно MEERR.TMP, если оно было
    while (k < Window_Count) {
      Switch_Window(++k);
      if  ( Caps(Truncate_Path(File_Name)) == Tid ) {
        Erase_Window;  meerr_id = Window_Id;  break;
    } }

    Switch_Win_Id(temp_id);     // вызовем компилятор
    Return_Str = ME_Path + 'CMAC.EXE ' + File_Name +
      ' -P' + ME_Path + 'MAC -M';
    RM('MEUTIL1^EXEC /MEM=0/SCREEN=3/RED=' + Tid + '/T=Compile and Debug');
    Set_Global_Str('LAST_COMP','MULTI_EDIT');

    if ( !Switch_Win_Id(meerr_id) )  {  // создадим окно MEERR.TMP, если надо
      RM('CreateWindow');  meerr_id = Window_Id;  RM('SetWindowNames');
    }
    Load_File(Tid);  Set_Global_Int('~MEERR_ID', meerr_id );

    if (Exit_Code == 0) {              // не было ошибок
      k = Ignore_Case;  Ignore_Case = True;
      if ( Search_Fwd('OUTPUT-FILE',0)  ) {
        Goto_Col(C_col + 12);
        While( Cur_Char == ' ' )  Right;
        If   ( Cur_Char == '=' )  Right;
        F = Remove_Space(Get_Word(''));
        Load_Macro_File(F);  Switch_Win_Id(temp_id);
        Make_Message('Ошибок нет. Макрофайл: ' + F);
      }
      Ignore_Case = k;  Refresh = True;
      Switch_Win_Id( temp_id );  Redraw;
      GoTo Debug;
    }
    // были ошибки
    Switch_Win_Id(temp_id);  RM('LANGUAGE^CMPERROR');

  } else if (KEY2 == 19) {                      /* Run current macro */
    Call FormMname;
    Set_Global_Str( 'MAC_RUN', F );
    RM('MEUTIL1^RUNMAC');
  } else if (KEY2 != 1)  GoTo Open;
  goto Finish;

FormMname:
  Mark_Pos;  k = Ignore_Case;  Ignore_Case = True;
  Refresh = False;  Reg_Exp_Stat = True;
  if ( Search_Bwd('%{ }*Macro ',0) )  {
    Word_Right;  F = Get_Word(' ;');
  } else F = Truncate_Extension( Truncate_Path(File_Name) );
  TOF;
  if ( Search_Fwd('MACRO_FILE ',10) )  {
    Word_Right;  F = Get_Word(' ;') + '^' + F;
  } else F = Truncate_Extension( Truncate_Path(File_Name) ) + '^' + F;
  Ignore_Case = k;  GoTo_Mark;
  Ret;

Finish:
  Reg_Exp_Stat = res;  Refresh = ref;
};

Macro SRC_KIT trans2 {

  int k, ref=Refresh, res=Reg_Exp_Stat;
  str F;

  int BG = M_T_Color >> 4, FG = M_T_Color & $0F;
  int X1 = 12, Y1 = 9, X2 = 70, Y2 = 18;
Open:
  Mark_Pos;
  Put_Box(X1,Y1,X2,Y2,BG,FG,' Multi-Edit SRC Support Kit ',1);
  Write('Condensed......сжатое отображение (заголовки макро)',X1+3,Y1+2,BG,FG);
  Write('Run............запуск текущего макро',               X1+3,Y1+4,BG,FG);
  Write('Transform......конвертирование на язык CMAC',        X1+3,Y1+6,BG,FG);

  Write(' Нажмите одну из указанных клавиш (ESC - отказ) ',X1+5,Y2-1,
        M_S_Color >> 4, M_S_Color & $0F);

  k = Y1+2;
  while(  k < (Y2-2)  ) {;
    Draw_Attr(X1+3,k,M_H_Color,1);  k += 2;
  };
  GoToXY(0,0);
  Read_Key; Kill_Box; GoTo_Mark;

  if ( KEY2 == 46 ) {                           /* Condensed */
    SET_GLOBAL_INT('Condense_Mode',1);
    SET_GLOBAL_STR('Condense_Search','@$Macro');
    F = GLOBAL_STR('Condense_Switches');
    SET_GLOBAL_STR('Condense_Switches','I');
    RM ('SUPPORT^CONDENSE');
    SET_GLOBAL_INT('Condense_Mode',0);
    SET_GLOBAL_STR('Condense_Switches',F);

  } else if ( KEY2 == 19 ) {                    /* Run current macro */
    Mark_Pos;  k = Ignore_Case;  Ignore_Case = True;
    Refresh = False;  Reg_Exp_Stat = True;
    if ( Search_Bwd('%{ }*@$Macro ',0) )  {
      Right;  Word_Right;  F = Get_Word(' ;');
    } else F = Truncate_Extension( Truncate_Path(File_Name) );
    TOF;
    if ( Search_Fwd('MACRO_FILE ',10) )  {
      Word_Right;  F = Get_Word(' ;') + '^' + F;
    } else F = Truncate_Extension( Truncate_Path(File_Name) ) + '^' + F;
    Ignore_Case = k;  GoTo_Mark;
    Set_Global_Str( 'MAC_RUN', F );
    RM('MEUTIL1^RUNMAC');

  } else if ( KEY2 == 20 ) {                    /* Transform macro */
    RM('SRCCONV');
    RM('MEUTIL2^BLOCKOFF');

  } else if (KEY2 != 1)  GoTo Open;

  Reg_Exp_Stat = res;  Refresh = ref;
};

Macro ASM_FORMAT {
/*

  Name: ASM_FORMAT

  Description:  Reformats 8086 assembly language source code.
  Modifications: L.G.Bunich -- Jan 1993

            (C) Copyright 1991 by American Cybernetics, Inc.
*/

str  tstr[10], cw[12];
str  t=",EQU,DB,DW,DD,LABEL,=,RECORD,STRUC,ENDS,SEGMENT,ENDS,PROC,ENDP,GROUP,";
int  im, space_found ;

  Push_Undo;
  Refresh = False;
  im = Insert_Mode; Insert_Mode = True;
  working;  mark_pos;

  if (block_stat != 1 || Marking) {
    Make_Message('No lines marked.');
    goto exit;
  }
  goto_line(block_line1);

  while (c_line <= block_line2) {
    Put_Line_Num(C_Line);
    first_word;

    /* If first character is a ';' then ignore line */
    if (cur_char == ';') goto do_loop;

    /* Delete all leading characters */
    GoTo_Col(1);  call DelBlanks;

    /* Position after first word */
    Forward_Till(' :|9|255');

    /* If this is a label then go on */
    if (Cur_Char == ':') {
      Right;  if (AT_EOL) goto do_loop;
      CR; continue;  }

    /* if only one word then adjust it */
    if (AT_EOL) {
      goto_col(1);  tab_right;  goto do_loop;  }

    space_found = 0;
    tab_right;
    call DelBlanks;                             /* to beginning of 2nd word */
    cw = ',' + CAPS(Get_Word(' |9')) + ',';     /* second word */
    if (Xpos(cw,t,1) == 0) {
      goto_col(1);  tab_right;
      Forward_Till(' |9');                      /* after end of 1st word */
      Forward_Till_Not(' |9');                  /* to beginning of 2nd word */
      space_found = 1;
    }

Find_Comment:
    tstr = Get_Word('''"; |9');
    if(  (cur_char == '''')  ) {
      right;
      tstr = get_word('''');
      right;
      goto Find_Comment;
    }
    if(  (cur_char == '"')  ) {
      right;
      tstr = get_word('"');
      right;
      goto Find_Comment;
    }
    call DelBlanks;
    if ( not(at_eol) ) {
      if (cur_char == ';') {

        /*  adjust comment  */
        if (c_col > 41) text(' ');
        while (c_col < 41) tab_right;
        goto do_loop;

      } else {

        if (space_found == 1) text(' ');
                         else tab_right;
        space_found = 1;
        goto Find_Comment;

      }
    }

do_loop:
    down;
  }
  Goto Exit;

DelBlanks:
  while ((Cur_Char == ' ') || (Cur_Char == '|9'))  del_char;
  ret;

Exit:
  Goto_Mark;  Insert_Mode = im;
  RM('MEUTIL2^BLOCKOFF');
  Refresh = True; Pop_Undo;
}
