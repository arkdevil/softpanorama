 /* INW 19.11.90
 Макрокоманда редактора Multi-edit (Л.З.А.)
 Пересылка слов в текущую строку
  */
 macro inw {
  int i,wi,ww,k;
  str c;
  if(  global_int('inw_inw') == 1  ) { goto qq; };
  set_global_int('inw_inw',1);
  set_mark(1); /* Запомнили положение курсора */
  k = inq_key(13,28,edit,c);
  set_global_str('inw_enter',c);
  k = inq_key(13,224,edit,c);
  set_global_str('inw_grenter',c);
  k = inq_key(27,1,edit,c);
  set_global_str('inw_esc',c);
  k = inq_key(0,244,edit,c);
  set_global_str('inw_btm0',c);
  macro_to_key(<enter>,'inw_break',edit);
  macro_to_key(<GreyEnter>,'inw_break',edit);
  macro_to_key(<esc>,'inw_esc',edit);
  macro_to_key(<btn0>,'inw_break',edit);
  wi = cur_window;
  set_global_int('inw_wind_i',wi);
  left;
  if(  ((ascii(cur_char) < 33) | (at_eol == 1))  ) { /*  пробел 1 */
     c = '';
	} else {
     i = 0; /* не буква но не пробел */
     while(  ((i == 0) & (c_col > 1))  ) {
        left;
        if(  (ascii(cur_char) < 33)  ) {
           i = 1; right;
        };
     };
     set_global_int('inw_c_col',c_col);
     set_global_int('inw_c_line',c_line);
     c = ' ' + get_word(' ');
  };

  set_global_str('inw_wind_c',c);
  ww =  global_int('inw_wind_w');
  if(  ww != 0  ) {
     switch_window(ww);
  };
  if(  c != ''  ) {
     goto_line(1); goto_col(1);
 qq: c = global_str('inw_wind_c');
     if(  search_fwd(c,0) == 0  ) {
        make_message ('INW  Нет слова: "'+ c + '" в файле ' + file_name);
        run_macro('inw_esc /n=1');
        goto t;
		 } else {
        right;
        if(  ((wi == cur_window)                   &
            (global_int('inw_c_line') == c_line) &
            (global_int('inw_c_col')  == c_col))  ) {
            goto qq;
         };
     };
  };
 make_message (' INW Файл ' + file_name + ', Состояние подкачки слов - '+c);
t:
};
 /*  ******************************************** */
 /*  Реакция на Enter  */
 macro inw_break {
  int i,insertmo;
  str c;
     if(  ((ascii(cur_char) < 33) | (at_eol == 1))  ) { /*  пробел 1 */
        goto t;
     };
     refresh = false;
     insertmo = insert_mode;
     insert_mode = 1;

     set_global_int('inw_wind_w',cur_window);
     i = 0; /* не буква но не пробел */
     while(  ((i == 0) & (c_col > 1))  ) {
        left;
        if(  (ascii(cur_char) < 33)  ) {
           i = 1; right;
        };
     };

     col_block_begin;
     while(  ((ascii(cur_char) > 32) & (at_eol == 0))  ) {
        right;
     };
     block_end;

     if(   global_int('inw_wind_i') == cur_window  ) {
        call word;
        copy_block;
		 } else {
        set_mark(2);
        switch_window(global_int('inw_wind_i'));
        call word;
        window_copy(global_int('inw_wind_w'));
        switch_window(global_int('inw_wind_w'));
        goto_line(1); goto_col(1);  cr; up; text(' ');        
        copy_block;
        get_mark(2);
        del_line;
        switch_window(global_int('inw_wind_i'));
        get_mark(1);
     };
     block_off;
     while(  ((ascii(cur_char) > 32) & (at_eol == 0))  ) {
        if(  cur_char == '$'  ) {
           del_char; text(' ');
				} else {
           right;
        };
     };
     run_macro('inw_esc /n=2');
     refresh = true;
     insert_mode = insertmo;
     goto t;
/* ---------------------------------------------------------- */
word:
        get_mark(1);
        if(  c_col > 1  ) {
           left;
           if(  (ascii(cur_char) > 32)  ) {
              i = 0; /* не буква но не пробел */
              while(  ((i == 0) & (c_col > 1))  ) {
                 left;
                 if(  (ascii(cur_char) < 33)  ) {
                    i = 1; right;
                 };
              };
              while(  ((ascii(cur_char) > 32) & (at_eol == 0))  ) {
                 del_char;
              };
					 } else {
              right;
           };
        };
     ret;
/* ---------------------------------------------------------- */
 t:
 };
 /*  ********************************************************** */
 /*  Реакция на Escape  */
 macro inw_esc {
     int i,n;
     str c;
     block_off;
     set_global_int('inw_inw',0);
     c = global_str('inw_enter');
     if(  c != ''  ) {
        macro_to_key(<enter>,c,edit);
		 } else {
        macro_to_key(<enter>,'inw_enter',edit);
     };
     c = global_str('inw_grenter');
     if(  c != ''  ) {
        macro_to_key(<GreyEnter>,c,edit);
     };
     c = global_str('inw_esc');
     if(  c != ''  ) {
        macro_to_key(<esc>,c,edit);
     };
     c = global_str('inw_btm0');
     if(  c != ''  ) {
        macro_to_key(<btn0>,c,edit);
     };
     n = parse_int('/n=',mparm_str);
     if(  n < 2  ) {
        set_global_int('inw_wind_w',cur_window);
     };
     i = global_int('inw_wind_i');
     if(  i > 0  ) { switch_window(i); };
     if(  n < 2  ) {
        get_mark(1);
     };
     if(  n != 1  ) { make_message (' '); };
   };
 /*  ********************************************************** */
 /*  Пополнение словаря заготовок  */
 macro inwt {
  str c;
  int insertmo;
  int i,wi,ww;
  ww =  global_int('inw_wind_w');
  wi = cur_window;
  set_mark(1); /* Запомнили положение курсора */
  if(  ww == wi  ) { goto t; };
  /* if ((ascii(cur_char) < 33) or (at_eol = 1)) then
     goto t;
  end; */
  insertmo = insert_mode;
  insert_mode = 1;
  i = 0; /* не буква но не пробел */
  while(  ((i == 0) & (c_col > 1))  ) {
     left;
     if(  (ascii(cur_char) < 33)  ) {
        i = 1; right;
     };
  };
  c = ' ' + get_word(' ');
  switch_window(ww);
  goto_line(1); goto_col(1); cr; up;
  put_line(c);
  switch_window(wi);
  get_mark(1);
  insert_mode = insertmo;
t:
 };
 macro inw_enter {  cr;  };
 /*  ********************************************************** */
