 /* TFM  14.09.90 - Начало проектирования
 Макрокоманда редактора Multi-edit (Л.З.А.) v7
 Форматирование абзаца в пределах :
  Левой границы
  Правой границы
  Отступа абзаца
  */
 /* ********** настройка среды ****************************** */
 macro tfm {
  int ls,ds,rs,x;
  str id,d1,l1,r1,b1;
  id = get_extension(file_name) + str(window_id);
  l1 = 'leftpoint' + id;  /*  левая гpаница  */
  d1 = 'dleftpoint' + id;  /*  отступ  */
  r1 = 'rightpoint' + id;  /*  пpавая гpаница  */
  b1 = 'blockblock' +id;  /*  признак открытия блока  */
  ls = parse_int('/l=',mparm_str);
  ds = parse_int('/a=',mparm_str);
  rs = parse_int('/r=',mparm_str);
  error_level = 0; x = 0;
  if(  rs == 1935  ) {
     ls = global_int(l1);  /*  левая гpаница  */
     ds = global_int(d1);  /*  отступ  */
     rs = global_int(r1);  /*  пpавая гpаница  */
     x = 1;
  };
  if(  rs == 0  ) {
     rs = right_margin;
     if(  rs == 0  ) {
        rs = 72;
     };
  };
  if(  ((ls >= rs) | (ds >= rs) | (rs < 3) | (rs > 256))  ) {
     put_box(5, 4, 27, 7, white, red, 'error', true);
     write ('Ошибка в параметрах', 6,5, white, red);
     beep;
     delay(1000);
     kill_box;
     error_level = 1;
     goto t;
  };
  set_global_int(l1,ls);  /*  левая гpаница  */
  set_global_int(d1,ds);  /*  отступ  */
  set_global_int(r1,rs);  /*  пpавая гpаница  */
  set_global_int(b1,0);  /*  признак открытия блока  */
  indent_style = 0;   /* ручная установка левой границы */
  wrap_stat = 0;      /* не рвать строку, не помещающуюся на экране */
  macro_to_key(<Enter>,'abz_break',edit);
  macro_to_key(<GreyEnter>,'abz_break',edit);
  macro_to_key(< >,'abz_space',edit);
  /* run_macro (''ti''); */
  if(  ((ds > 0) & (x == 0))  ) {
     goto_col(ds);
  };
 t:
 };
 /*  ********************************************************** */
 /*  расстройка среды ****************************** */
 macro tu {
  int bl;
  str id,d1,l1,r1,b1;
  id = get_extension(file_name) + str(window_id);
  l1 = 'leftpoint' + id;  /*  левая гpаница  */
  d1 = 'dleftpoint' + id;  /*  отступ  */
  r1 = 'rightpoint' + id;  /*  пpавая гpаница  */
  b1 = 'blockblock' +id;  /*  признак открытия блока  */
  /* macro_to_key(< >,''abz1_space'',edit);
  macro_to_key(<enter>,''abz1_break'',edit);
  macro_to_key(<GreyEnter>,''abz1_break'',edit); */
  set_global_int(l1,0);  /*  левая гpаница  */
  set_global_int(d1,0);  /*  отступ  */
  set_global_int(r1,0);  /*  пpавая гpаница  */
  bl = global_int(b1);  /*  признак открытия блока  */
  if(  bl > 0  ) {
     set_global_int(b1,0);
     block_off;
  };
  make_message ('Форматизация аннулирована для файла ' + file_name);
 };
 /*  ********************************************************** */
 /*  ******** основная точка входа **************************** */
 macro tf {
 int ls,ds,rs;
 int i,j,k,k1,nn,bl1,bl2,insertmo,first,prglas;
 char cc,c1,c2,c4;
 str lin,st[2];
 str id,d1,l1,r1;
 id = get_extension(file_name) + str(window_id);
 l1 = 'leftpoint' + id;  /*  левая гpаница  */
 d1 = 'dleftpoint' + id;  /*  отступ  */
 r1 = 'rightpoint' + id;  /*  пpавая гpаница  */

 ls = global_int(l1);  /*  левая гpаница  */
 ds = global_int(d1);  /*  отступ  */
 rs = global_int(r1);  /*  пpавая гpаница  */
 if(  rs == 0  ) {
    goto t;
 };
 push_undo;
 working;
 /* refresh := false; */
 insertmo = insert_mode;
 insert_mode = 1;
   if(  ((block_stat == 1) & (marking == false))  ) {
      bl1 = block_line1;          /*  начало блока  */
      bl2 = block_line2;          /*  конец  блока  */
      i = bl1;
      goto_line(i);
      if(  ds == 0  ) { /* автоустановка позиции начала абзаца */
         while(  (i <= bl2)  ) {
            eol;
            if(  c_col > 1  ) {
               home; ds = c_col; goto t1;
						} else {
               i = i+1; down;
            };
         };
         if(  ds == 0  ) {
            goto final;
         };
      };
 t1:  goto_line(i+1);
      if(  ls == 0  ) { /* автоустановка позиции левой границы */
         while(  (i <= bl2)  ) {
            eol;
            if(  c_col > 1  ) {
               home; ls = c_col; goto t2;
						} else {
               i = i+1; down;
            };
         };
         if(  ls == 0  ) {
            ls = ds;
         };
      };
 t2:  first = ds; goto_line(bl1);
	 } else {
     goto final;
   };
m0: goto_col(1);
    while(  (ascii(cur_char) < 33)  ) { /*  подтягивание к началу  */
      del_char;
    };
    nn = 1;
    while(  (nn < first)  ) {  /* вставка пробелов */
      text (' '); nn = nn + 1;
    };
    nn = 0;
    goto_col(first);
    while(  ((at_eol == 0) & (c_col <= rs))  ) {  /* сжатие пробелов */
       if(  (ascii(cur_char) < 33)  ) {
          if(  (nn == 0)  ) {
              nn = 1; right;
					} else {
              del_char;
          };
			 } else {
          nn = 0; right;
       };
    };
    /* while search_fwd(''  '',1) do
       replace('' '');
    end; */
    lin = get_line;
    if(  length(lin) > rs  ) {       /*  стpока длинная  */
       goto m1;
		} else {
       bl2 = block_line2; i = c_line;
       /* подтклейка следующей строки */
       if(  (c_line  <  bl2)   ) {
          eol;  text(' '); del_char; left;
          while(  ((ascii(cur_char) < 33) & (c_col > first))  ) {
             left;
          };
          cc = cur_char;
          if(  (cc == '-')  ) {
              if(  (c_col > first)  ) {
                 left;
                 if(  (ascii(cur_char) > 32)  ) {
                    right; del_char;
                    while(  (ascii(cur_char) < 33)  ) {
                      del_char;
                    };
                  };
               };
          };
			 } else {
          goto final;
       };
    };
    goto m0;
m01:
    cr; up;
    run_macro('balance');
    first = ls; goto m0;
m1:                 /* растаскивание слов по пробелам */
    /*  ------------------------------------------------------------- */
    while(  (true)  ) { /* *****внешний цикл **************************** */
       goto_col(rs);  cc = cur_char; /* но вначале проверяем разделитель */
       if(  ((cc == ';') | (cc == ',') | (cc == '?') | (cc == '!'))    ) {
            right;
            goto m01;
       };
       if(  cc == '.'   ) {
            right;
            if(  cur_char != '.'  ) {
               goto m01;
            };
       };
       goto_col(rs);

       if(  (ascii(cur_char) > 32)  ) { /*  не  пробел в rs */
          goto_col(rs+1);
          if(  (ascii(cur_char) < 33)  ) { /*  пробел в rs+1 */
             goto m01;
          };
       };

         /* проверка на перенос */
       i = 0; j = 0; k = 0;
       goto_col(rs-3); call provglas; k1 = prglas; 
       while( (i < 4)  ) { /* ah-ha, ha-ha, ha-ah */
          goto_col(rs-2+i);
          call provglas;
          if(  prglas == 0  ) {           /* знак */
             goto pr;
          };
          j = j + prglas;
          if(  i == 1  ) {
             if ( (j == 4) & ((k1 == 0) | (k1 == 2)) ) {
                goto pr;                /* _hh-?? */
             };
             k = prglas; j = 0;
          };
          if(  ((i == 2) & (k == 2) & (prglas == 1))  ) {
             goto pr;                   /* ah-a? */
          };
          i = i + 1;
       };
       if(  j == 4  ) {                   /* ??-hh */
          goto_col(rs+2); call provglas; k1 = prglas; 
          if ((k1 == 0) | (k1 == 2)) {goto pr;};
       };
       goto_col(rs); text('-');
       goto m01;

          /* перенос не получился, вставляем пробел */
 pr:      goto_col(rs+1);
          word_left; i = 0; /* не буква но не пробел */
          while(  ((i == 0) & (c_col > 1))  ) {
             left;
             if(  (ascii(cur_char) < 33)  ) {
                i = 1; right;
             };
          };
          if(  (c_col <= first)  ) {
             goto_col(rs+1); /* больше  не вставляется, ломаем строку */
             goto m01;
          };
          text(' ');           /*  вот он - пробел */
    };    /*  конец внешнего цикла ******************* */
    /* ------------------------------------------------------ */

 /* *** пп пpовеpки на согласную, гласную и знак  ** */
provglas:
 int k;
 prglas = 2;               /* согласная ? */
 cc = cur_char;
 if(  ((cc == 'а') | (cc == 'и') | (cc == 'о') | (cc == 'е') | (cc == 'я')
      | (cc == 'у') | (cc == 'ю') | (cc == 'ы') | (cc == 'э')
      | (cc == 'А') | (cc == 'И') | (cc == 'О') | (cc == 'Е') | (cc == 'Я')
      | (cc == 'У') | (cc == 'Ю') | (cc == 'Ы') | (cc == 'Э'))  ) {
         prglas = 1;       /* гласная  */
 } else {
     k = ascii(cur_char);
     if(  ( (k < $41)
        | ((k > $5a) & (k < $61))
        | ((k > $7a) & (k < $80))
        | (cc == 'ь') | (cc == 'Ь') | (cc == 'ъ') | (cc == 'Ъ'))  ) {
         prglas = 0;       /* знак  */
     };
 /* if ((cc = ''i'') or (cc = ''I'') or (cc = ''o'') or (cc = ''O'')
      or (cc = ''e'') or (cc = ''E'') or (cc = ''u'') or (cc = ''U'')
      or (cc = ''a'') or (cc = ''A'') or (cc = ''у'') or (cc = ''Y'')) then
         prglas := 1;       гласная
  end; */
 };
 ret;

 final: down;
    down; down; down; up;up;up; /* отрыв от нижней границы окна */
    /* refresh := true;    */
    goto_col(ds);
    insert_mode = insertmo;
    pop_undo;
 t:
 };
 /*  ********************************************************** */
/*  ******Реакция на ENTER *********************************** */
 macro abz_break {
  int ls,rs,nn;
  str id,r1;
  id = get_extension(file_name) + str(window_id);
  r1 = 'rightpoint' + id;  /*  пpавая гpаница  */
  rs = global_int(r1);
  if(  (rs == 0)  ) {
     cr; goto t;
  };
  run_macro('abzx_break /n=1');
 t:
  };
/* *********************************************************** */
/*  ******Реализация  ENTER *********************************** */
 macro abzx_break {
  int ls,ds,rs,n,nn,rr,r,rr1;
  char cc;
  int insertmo;
  str id,d1,l1,r1;
  id = get_extension(file_name) + str(window_id);
  l1 = 'leftpoint' + id;  /*  левая гpаница  */
  d1 = 'dleftpoint' + id;  /*  отступ  */
  r1 = 'rightpoint' + id;  /*  пpавая гpаница  */

  insertmo = insert_mode;
  insert_mode = 1;
  refresh = false;
  n = parse_int('/n=',mparm_str);

  push_undo;
  rs = global_int(r1);
  ds = global_int(d1);
  ls = global_int(l1);
  nn = c_col;
  home;
  if(  (c_col == ds)  ) {
     rr = ds;
	} else {
     rr = ls;
  };
  rr1 = ds;
  if(  ds == 0  ) { /* автоустановка позиции левой границы */
     eol;
     if(  c_col > 1  ) {
        home;
		 } else {
        goto_col(nn);
     };
     rr1 = c_col;
  };
  goto_col(nn);
  if(  (c_col < rs)  ) {  /* стpока короткая  */
    cr;
    goto_col(1);
    while(  (ascii(cur_char) < 33)  ) {
      del_char;
    };
    r = 1;
    while(  (r < rr1)  ) {
      text (' '); r = r + 1;
    };
	} else {
    r = ds;
    if(  (rr == ls)  ) {
       set_global_int(d1,ls);
    };
    run_macro('abz_blo');
    run_macro('abz_go');
    set_global_int(d1,r);
    up;
    if(  n == 1  ) {    /* по ENTER */
       eol; cr;
       r = 1;  goto_col(1);
       while(  (r < rr1)  ) {
          text (' ');  r = r + 1;
       };
		} else {
       eol;
    };
  };
  refresh = true;
  insert_mode = insertmo;
  pop_undo;
  };
 /*  ********************************************************** */
 /*  ***** реакция на SPACE *********************************** */
macro abz_space {
  int ls,rs,nn,r;
  int insertmo;
  str id,l1,r1;
  id = get_extension(file_name) + str(window_id);
  l1 = 'leftpoint' + id;  /*  левая гpаница  */
  r1 = 'rightpoint' + id;  /*  пpавая гpаница  */
  rs = global_int(r1);
  if(  (rs == 0)  ) {
     text(' '); goto t1;
  };
  push_undo;

  refresh = false;
  insertmo = insert_mode;
  ls = global_int(l1);
  if(  (c_col > rs)  ) {       /*  стpока длинная  */
     nn = c_col; r = 0; home;
     if(  ls == 0  ) { /* автоустановка позиции левой границы */
         ls = c_col;
     };
     while(  ((at_eol == 0) & (c_col <= rs))  ) {  /* сжатие пробелов */
        if(  (ascii(cur_char) < 33)  ) {
           if(  (r == 0)  ) {
               r = 1;  right;
					 } else {
               del_char;
               if(  c_col <= nn  ) {
                  nn = nn - 1;
               };
           };
				} else {
           r = 0;  right;
        };
     };
     if(  nn <= rs  ) {
        goto_col(nn);
        text(' '); goto t;
     };
     goto_col(rs+1);
     insert_mode = 1;
     if(  (at_eol == 1)  ) {  /* за пределами строки, rs+1 = end */
        cr;
        goto_col(1); r = 1;
        while(  (r < ls)  ) {
           text (' '); r = r + 1;
        };
        goto t;
     };
     goto_col(nn);
     if(  at_eol == 0  ) { /*  находимся внутри строки < END, но > rs+1 */
        goto_col(nn);
        cr; goto_col(1);   /* работа сo второй половиной строки */
        while(  (ascii(cur_char) < 33)  ) { /*  подтягивание к началу  */
          del_char;
        };
        r = 1;
        while(  (r < ls)  ) {  /* вставка пробелов */
           text (' '); r = r + 1;
        };
        up;                /* поднялись к первой половине строки */
        eol;
     };
     run_macro ('abzx_break /n=0');
     if(  (c_col > ls)  ) {
        text(' ');
     };
     nn = c_col;goto_col(1);goto_col(nn); /* восстановить рамки экрана */
	} else {
     text(' ');
  };
  t:
  insert_mode = insertmo;
  refresh = true;
  pop_undo;
  t1:
  };
 /*  ********************************************************** */
 /* *********** открытие блока ******************************** */
 macro abz_blo {
  int bl,rs;
  str id,r1,b1;
  id = get_extension(file_name) + str(window_id);
  r1 = 'rightpoint' + id;  /*  пpавая гpаница  */
  b1 = 'blockblock' +id;  /*  признак открытия блока  */
  rs = global_int(r1);  /*  пpавая гpаница  */
  if(  (rs == 0)  ) {
    goto t;
  };
  bl = global_int(b1);  /*  признак открытия блока  */
  if(  ((bl == 0) | (marking == false))  ) {
     set_global_int(b1,1);
     block_begin;
	} else {
     down;
  };
  t:
 };
/* ************************************************ */
/*  закрытие блока и обращение к  tf ************** */
 macro abz_go {
  int bl;
  str id,b1;
  id = get_extension(file_name) + str(window_id);
  b1 = 'blockblock' +id;  /*  признак открытия блока  */
  bl = global_int(b1);  /*  признак открытия блока  */
  refresh = false;
  if(  (bl == 1)  ) {
     set_global_int(b1,0);
     block_end;
     run_macro ('tf');
     block_off;
	} else {
     run_macro ('tb /a=0/m=0');
  };
  refresh = true;
 };
 /*  ************************************************* */
/*  Автоустановка блока и форматирование tb ************** */
 macro tb {
  int l0,lt,n1,n2,i,a,ls,ds,m;
  str id,d1,l1;
  id = get_extension(file_name) + str(window_id);
  l1 = 'leftpoint' + id;  /*  левая гpаница  */
  d1 = 'dleftpoint' + id;  /*  отступ  */
  ls = global_int(l1);  /*  левая гpаница  */
  ds = global_int(d1);  /*  отступ  */
  a = parse_int('/a=',mparm_str); /*  > 0 - с проверкой соответствия левой границе */
  m = parse_int('/m=',mparm_str); /*  1 - из TG  */
     push_undo;
     refresh = false;
   i = 0;
   call p;
   while(  lt == 0  ) {   /* спускаемся по пустым строкам */
      if(  at_eof == 1  ) {
         goto t;
      };
      down; call p;
   };

   l0 = lt;
   while(  ((lt == l0) & (c_line > 1))  ) {  /* под''ем и определение первой линии блока */
      up; call p;
      if(  lt == l0  ) {
         i = 1;
      };
   };
   n1 = c_line;
   if(  lt == 0  ) {
      down;
      n1 = c_line;
	 } else {
      if(  i == 0  ) {
         if(  lt < l0  ) {
            down;
            n1 = c_line;
         };
      };
   };

   goto_line(n1); call p;
   lt = l0; i = 0;
   while(  ((lt == l0) & (at_eof == 0))  ) { /* спуск и определен6ие последней линии блока */
      down; call p;
      if(  lt == l0  ) {
         i = 1;
      };
   };
   if(  lt > 0  ) {
      if(  i == 0  ) {
         if(  lt < l0  ) {
            l0 = lt;
            while(  lt == l0  ) {
               down; call p;
               if(  lt != l0  ) {
                  goto t1;
               };
            };
         };
      };
   };

  t1:   /* все готово */
   up; n2 = c_line;
   goto_line(n1);
   if(  a > 0  ) {
      call p;
      if(  lt != a  ) {
         goto_line(n2 +1);
         goto t;
      };
   };
   block_begin;
   while(  n1 < n2  ) {
      down; n1 = n1 + 1;
   };
   block_end;
   run_macro ('tf');
   block_off;
   goto t;
  /* -----пп ------ */
  p:
  lt = 0;
  eol;   /*  строку не меняет  */
  if(  c_col > 1  ) {
     home; lt = c_col;
  };
  ret;
  /* -------------- */
  t:
  pop_undo;
  if(  m == 0  ) {
     refresh = true;
  };
 };
 /*  ************************************************* */
/*  Глобальное  форматирование tg ************** */
 macro tg {
  int bl1,bl2,nn,n;
  n = parse_int('/n=',mparm_str);
  if(  n > 0  ) {
     n = c_col;
     make_message (' Tfm:   Поиск /a=' + str(n));
  };
  push_undo;
  refresh = false;
  working;
  if(  block_stat != 1  ) {
     goto t;
  };
  bl1 = block_line1;          /*  начало блока  */
  bl2 = block_line2;          /*  конец  блока  */
  goto_line(bl2);
  while(  (at_eof == 1)  ) {
     up;
  };
  set_mark(1); /* Запомнили положение курсора */
  goto_line(bl1); nn = c_line;
  while( (true)  ) {;
     get_mark(1);
     if(  nn >= c_line  ) {
     run_macro('ti');
        goto t;
     };
     goto_line(nn);
     run_macro('tb /m=1/a=' + str(n));
     nn = c_line;
  };
  t:
  refresh = true;
  pop_undo;
 };
 /*  ************************************************* */
 /*  *** ENTER ДЛЯ TP ********************************* */
 macro abzp_break { run_macro ('abz_pp /n=1'); };
 /*  *** ESCAPE ДЛЯ TP ********************************* */
 macro abzp_esc { run_macro ('abz_pp /n=2'); };
 /*  *** SPACE для TP ********************************* */
 macro abzp_space { run_macro ('abz_pp /n=3'); };
 /*  *** Экранная установка границ************** */
 macro tp {
  str c;
  int result;
  set_global_int('anypointabz',1);
  result = inq_key(27,1,edit,c);
  set_global_str('tfm_esc',c);
  result = inq_key(0,244,edit,c);
  set_global_str('tfm_btm0',c);
  macro_to_key(<enter>,'abzp_break',edit);
  macro_to_key(<btn0>,'abzp_break',edit);
  macro_to_key(<GreyEnter>,'abzp_break',edit);
  macro_to_key(<esc>,'abzp_esc',edit);
  macro_to_key(< >,'abzp_space',edit);
  run_macro ('abz_pp');
  };
 /*  ******************************************** */
 /*  *** Реализация экранной установки границ ***** */
 macro abz_pp {
  int n,p,i,ls,ds,rs,color;
  int pb;
  str id,d1,l1,r1,c;
  id = get_extension(file_name) + str(window_id);
  l1 = 'leftpoint' + id;  /*  левая гpаница  */
  d1 = 'dleftpoint' + id;  /*  отступ  */
  r1 = 'rightpoint' + id;  /*  пpавая гpаница  */
  p = global_int('anypointabz');
  if(  p == 0  ) {                      /*  левая гpаница  */
     goto t;
  };
  if(  c_row > 4  ) {
     pb = 4;
	} else {
     pb = 8;
  };
  if(  p == 1  ) {                      /*  левая гpаница  */
     set_global_int('anypointabz',2);
     c = 'Левая граница'; color = 0; call boxx;
     goto t;
  };
  n = parse_int('/n=',mparm_str);
  if(  p == 2  ) {                      /*  левая гpаница  */
     set_global_int('anypointabz',3);
     if(  n == 1  ) {
        i = c_col;
        set_global_int(l1,i);
     };
     if(  n == 3  ) {
        set_global_int(l1,0);
     };
     c = 'Начало абзаца'; color = 4; call boxx;
     goto t;
  };
  if(  p == 3  ) {                      /*  отступ  */
     set_global_int('anypointabz',4);
     if(  n == 1  ) {
        i = c_col;
        set_global_int(d1,i);
     };
     if(  n == 3  ) {
        set_global_int(d1,0);
     };
     c = 'Правая граница'; color = 14; call boxx;
     write ('Enter -позиция, Esc - старое, Space - r.m.', 18,pb + 2 , 7, 5);
     goto t;
  };
  if(  p == 4  ) {                      /*  правая граница  */
     kill_box;
     set_global_int('anypointabz',0);
     unassign_key(<enter>,edit);
     /* unassign_key(<btn0>,edit); */
     unassign_key(<GreyEnter>,edit);
     unassign_key(< >,edit);
     /* unassign_key(<esc>,edit);    */
     c = global_str('tfm_esc');
     if(  c != ''  ) {
        macro_to_key(<esc>,c,edit);
     };
     c = global_str('tfm_btm0');
     if(  c != ''  ) {
        macro_to_key(<btn0>,c,edit);
     };
     if(  n == 1  ) {
        i = c_col;
        set_global_int(r1,i);
     };
     if(  n == 3  ) {
        set_global_int(r1,0);
     };
     run_macro ('tfm /r=1935');
     run_macro ('ti');
     goto t;
  };
  /*  ---------------ПП -------------------------------- */
  boxx:
     kill_box;
     run_macro ('ti');
     put_box(17, pb, 60, pb + 3, 7, red, '', 0);
     write (c, 31,pb + 1, 7, color);
     write ('Enter -позиция, Esc - старое, Space - нуль', 18,pb + 2, 7, 5);
     /* beep; */
     ret;
  /*  --------------------------------------------------- */
 t:
 error_level = 0;
 };
 /*  ********************************************************** */
 /* ********** информация о параметрах форматирования ********* */
 macro ti {
  int ls,ds,rs;
  str id,d1,l1,r1;
  id = get_extension(file_name) + str(window_id);
  l1 = 'leftpoint' + id;  /*  левая гpаница  */
  d1 = 'dleftpoint' + id;  /*  отступ  */
  r1 = 'rightpoint' + id;  /*  пpавая гpаница  */
  ls = global_int(l1);  /*  левая гpаница  */
  ds = global_int(d1);  /*  отступ  */
  rs = global_int(r1);  /*  пpавая гpаница  */
  make_message ('TFM:параметры /l=' + str(ls) +
  '/a=' + str(ds) + '/r=' + str(rs) /* + ' ' + file_name */);
 };
 /*  ********************************************************** */
/*  ****** Обращение к внешней программе TFORM.exe для глобального
         форматирования****** */
 macro tgf {
  int ls,ds,rs;
  int insertmo;
  str id,d1,l1,r1;
  id = get_extension(file_name) + str(window_id);
  l1 = 'leftpoint' + id;  /*  левая гpаница  */
  d1 = 'dleftpoint' + id;  /*  отступ  */
  r1 = 'rightpoint' + id;  /*  пpавая гpаница  */

  insertmo = insert_mode;
  insert_mode = 1;
  refresh = false;
  rs = global_int(r1);
  ds = global_int(d1);
  ls = global_int(l1);
    Save_File;
    Shell_To_Dos('tform ' + File_Name + ' A' + Str(ds) +
    ' R' + Str(rs) + ' F' + ' V0', TRUE);
    run_macro ('ti');
  Load_File(File_Name);
  refresh = true;
  insert_mode = insertmo;
  };
 /*  ********************************************************** */
macro BALANCE trans2 {
  /* BALANCE  - оптимальное распределение пробелов в текущей строке */
  /* Макрос Л.Г.Бунича */

  int L, im, c1;
  str T, c[1], old[1];

  im = Insert_Mode;  Insert_Mode = True;
  EOL;  L = C_Col;  Home;  c1 = C_Col;
  T = Get_Line;  Tabs_to_spaces(T);  T = Remove_Space(T);
  L = L - c1 - Length(T);                /* избыток пробелов */
  RM('MESYS^DELEOL');  Text(T);

InsLoop:
  GoTo_Col(c1);
FirstStep:                          /* вставки после точек и знаков ''!?'' */
  if ( L <= 0 ) { goto Finish; };
  Forward_Till('.!?');  Right;
  if (Not(At_EOL))   {
    if ( Cur_Char == ' ')  {
      Text(' ');  --L;
    };
    goto FirstStep;
  };
  GoTo_Col(c1);
SecondStep:                         /* вставки после др. знаков препинания */
  if(  L == 0  ) { goto Finish;  };
  Forward_Till(',:;');  Right;
  if (Not(At_EOL))   {
    if ( Cur_Char == ' ' ) {
      Text(' ');  --L;
    };
    goto SecondStep;
  };
  GoTo_Col(c1);
LastStep:
  old = '|0';
  while(   Not(At_EOL)   ) {;
    if(  L == 0  ) { goto Finish;  };
    c = Cur_Char;
    if(  c == ' '  ) {
      if(  Xpos(old,' .!?,:;',1) == 0  ) {
        Text(' ');  --L;  Right;
      };
    };
    Right;  old = c;
  };
  goto InsLoop;

Finish:
  Down;  EOL;  Home;
  Insert_Mode = im;

};
