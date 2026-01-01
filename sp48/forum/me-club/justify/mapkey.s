Macro MapKey {

/* ********************************************************************
  Выводит в окно KEYBOARD упорядоченную информацию о клавиатурной раскладке.
  Переделка известного макроса В.Соколинского под Multi-Edit 6.00

  Исправления и доработки для ME 6.0:  Бунич Л.Г.  июль 1992
  Обращение:  MAPKEY /DB=<имя-db-файла-без-расширения>
                         (по умолчанию - текущий план клавиатуры)
******************************************************************** */

  int jx, im, te, res, keymap_window, mapkey_window,
                  default_window, q1, q2, perc, i, j, k=0;
  str ext, key, s_str, whole_line, descrip, mf,mc, kname,
                  prim_key, alt_key,  dir_line[71];

  kname = Parse_Str('/DB=',CAPS(Mparm_Str));
  if (kname == '')
    kname = Parse_Str('FN=',Global_Str('@KeyMap_Name@'));
  kname = kname + '.DB';
  Make_Message('Построение файла KEYBOARD для ' + kname);

  Undo_Stat = False;
  te = Tab_Expand;    Tab_Expand = False;
  im = Insert_Mode;   Insert_Mode = True;
  res = Reg_Exp_Stat; Reg_Exp_Stat = 0;
  Refresh = False;

  default_window = cur_window;

  Switch_Window(Window_Count);
  Create_Window;
  File_Name = 'KEYBOARD';
  Mapkey_Window = Cur_Window;

  Put_Line('   ╔═════════════════════════════════════════════════════╗ ');
  Down;
  Put_Line('   ║ Использование клавиатуры в среде редактора ME 6.00P ║ -- '
               + kname + '--');
  Down;
  Put_Line('   ╚═════════════════════════════════════════════════════╝ ');
    Down;  Down;
  Put_line('Клавиша           Описание               Доп. клавиша   МакроФайл ИмяМакро ');
    EOL;  CR;  CR;  Up;


  dir_line = '───────────────────────────────────────────────────────────────────────';
  text(dir_line);  CR;

  ext = '';      call FUNC_DRAW;  text(dir_line);  CR;
  ext = 'Ctrl';  call FUNC_DRAW;  text(dir_line);  CR;
  ext = 'Alt';   call FUNC_DRAW;  text(dir_line);  CR;
  ext = 'Shft';  call FUNC_DRAW;  text(dir_line);  CR;

  ext = '';      call DIGIT_DRAW; text(dir_line);  CR;
  ext = 'Ctrl';  call DIGIT_DRAW; text(dir_line);  CR;
  ext = 'Alt';   call DIGIT_DRAW; text(dir_line);  CR;
  ext = 'Shft';  call DIGIT_DRAW; text(dir_line);  CR;

  ext = '';      call GREY_DRAW;
  ext = 'Ctrl';  call GREY_DRAW;
  ext = 'Alt';   call GREY_DRAW;  text(dir_line);  CR;

  ext = '';  key = 'ScrollLockOn';  call DRAW;
             key = 'ScrollLockOff'; call DRAW;
             key = 'ESC';           call DRAW;
  ext = 'Alt';                      call DRAW;

             key = 'ENTER';
  ext = '';                         call DRAW;
  ext = 'Ctrl';                     call DRAW;
  ext = 'Alt';                      call DRAW;

             key = 'TAB';
  ext = '';                         call DRAW;
  ext = 'Ctrl';                     call DRAW;
  ext = 'Alt';                      call DRAW;
  ext = 'Shft';                     call DRAW;

             key = 'BS';
  ext = '';      call DRAW;
  ext = 'Ctrl';  call DRAW;
  ext = 'Alt';   call DRAW;

             key = 'SPACE';
  ext = 'Ctrl';  call DRAW;
  ext = 'Alt';   call DRAW;

  text(dir_line);  CR;

  ext = 'Ctrl';
  key = '@';  call DRAW;
  key = '^';  call DRAW;
  key = '_';  call DRAW;
  key = '[';  call DRAW;
  key = '\';  call DRAW;
  key = ']';  call DRAW;
  CR;

  ext = 'Alt';
  for ( jx = 0; jx < 10; ++jx ) {
    key = str(jx);  call DRAW;
  };

  key = '''';  call DRAW;
  key = '`';   call DRAW;
  key = '-';   call DRAW;
  key = '=';   call DRAW;
  key = ';';   call DRAW;
  key = '/';   call DRAW;
  key = '<';   call DRAW;
  key = '>';   call DRAW;
  key = '?';   call DRAW;
  key = '[';   call DRAW;
  key = '\';   call DRAW;
  key = ']';   call DRAW;
  text(dir_line);
  CR;

  ext = 'Ctrl';
  for ( jx = 65; jx < 91; ++jx ) {
    key = char(jx);  call DRAW;
  };
  text(dir_line);  CR;

  ext = 'Alt';
  for ( jx = 65; jx < 91; ++jx ) {
    key = char(jx);  call DRAW;
  };
  text(dir_line);  CR;

  ext='';        call Mouse_draw;
  ext = 'Ctrl';  call Mouse_draw;
  ext = 'Alt';   call Mouse_draw;
  ext = 'Shft';  call Mouse_draw;

  Switch_Window(Window_Count);
  Create_Window;
  Load_file(ME_PATH + kname);
  /* File_Name = ME_PATH + 'KEYMAP.ME'; */
  keymap_window = cur_window;
  Eof;  q2 = c_line;  Tof;

Loop:
  whole_line = Get_Line;
  q1 = c_line;
  perc = q1 * 100 / q2 ;
  Make_Message('Построение файла KEYBOARD для ' + kname + ' - ' + str(perc) + '%');

  if (xpos('|254',whole_line,1))      goto WHILE_LOOP;
  if (copy(whole_line,1,4) != 'MC=') goto WHILE_LOOP;

  mc       = Parse_Str('MC=',    whole_line);
  descrip  = Parse_Str('DESCR=', whole_line);
  prim_key = Parse_Str('K1=',    whole_line);
  alt_key  = Parse_Str('K2=',    whole_line);
  mf       = Parse_Str('MF=',    whole_line);
    if (mf == 'NOT APPLICABLE') mf = 'n/a';

  Switch_Window(Mapkey_Window);
  if (prim_key != '') {
      s_str = prim_key;
      call INS_DESCRIP;
      if ( C_Line > 1 ) {
          goto_col(43);  text(alt_key);
          goto_col(57);  text(mf);
          goto_col(67);  text(mc);
      };
  };
  if(  (alt_key != '')  ) {
      s_str = alt_key;
      call INS_DESCRIP;
      if ( C_Line > 1 ) {
          goto_col(43);  text(prim_key);
          goto_col(57);  text(mf);
          goto_col(67);  text(mc);
      };
  };
  Switch_Window(Keymap_Window);

WHILE_LOOP:
  down;
  if(  at_eof  ) {
    delete_window;
    goto cancel;
  } else {
    goto loop;
  };
/* ***************************************************************************** */


DRAW:
  text('<' + ext + key + '>');  CR;
  RET;


FUNC_DRAW:
  jx = 0;
  while ( jx < 12 ) {
    ++jx;
    key = 'F' + str(jx);
    call draw;
  };
  RET;


DIGIT_DRAW:
  key = 'LF';    call draw;
  key = 'RT';    call draw;
  key = 'UP';    call draw;
  key = 'DN';    call draw;
  key = 'PGUP';  call draw;
  key = 'PGDN';  call draw;
  key = 'HOME';  call draw;
  key = 'END';   call draw;
  key = 'INS';   call draw;
  key = 'DEL';   call draw;
  key = 'CNTR';  call draw;
  RET;

GREY_DRAW:
  key = 'GREY/';     call draw;
  key = 'GREY*';     call draw;
  key = 'GREY-';     call draw;
  key = 'GREY+';     call draw;
  key = 'GREYENTER'; call draw;
  RET;

Mouse_draw:
  key = 'MEVENT';  call draw;
  key = 'MEVENT2'; call draw;
  key = 'MEVENT3'; call draw;
  RET;


INS_DESCRIP:
  TOF;
Repeat:
  if (search_fwd(s_str,0)) {
    if (c_col != 1) { Down;  GoTo Repeat; };
    if (remove_space(copy( GET_LINE, 17, 25)) != '')  {
      EOL; CR;
    }
  }
  else {
    EOF;  CR;
    if (k == 0) {
      text(dir_line);  CR;
      k = C_Line;  }
    text(s_str);  }

  goto_col(17);  text(descrip);
  RET;


CANCEL:
    Undo_Stat = True;
    Tab_Expand = te;
    Insert_Mode = im;
    Reg_Exp_Stat = res;

    Switch_Window(mapkey_Window);
    if (k>0) {
      EOF;  Block_Begin;
      do Up;
        while(Get_Line != Dir_Line);
      Down;  Block_End;
      Make_Message('Sorting keys...');
      RM('TEXT^TEXTSORT /B');
      Block_Off;
    }
    TOF;
    Refresh = True;
    Make_Message('');
};
