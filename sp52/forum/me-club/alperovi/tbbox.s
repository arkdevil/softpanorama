 /* Tbbox  4.11.92 - Начало проектирования
 Макрокоманда редактора Multi-edit (Л.З.А.)
 "Табличный редактор"
  */
 /* **********  В сетке ****************************** */
 macro tbbox {
  int li,ci,i,j,flag,lb1,lb2,cb1,cb2,n;
  char sym;
  str  ss[1];
  push_undo;
  set_global_int('tbbflag',0);
  ss  = parse_str('/s=',mparm_str);
  if (ss ==  '') {
     ss  = global_str('tbbsym');
     if (ss ==  '')  ss  = '*';
  }
  set_global_str('tbbsym',ss);
  sym = char(ascii(ss));
  li=c_line; ci=c_col;
  flag=0;
  goto_col(1);
  while ( c_line > 0 ){
    if ( c_line ==  1) {
       if  (cur_char == sym)  goto l1; else break;
    }
    if (cur_char == sym ){
      flag=1; break;
    }
    up;
  }
  if (flag==0) {
    goto_col(ci); goto_line(li);
    goto t;
  }
l1:  lb1 = c_line; flag = 0;
  goto_line(li+1);
  goto_col(1);
  while(at_eof == 0)  {
    if (cur_char == sym ){
       flag = 1; break;
    }
    down;
  }
  if (flag==0) {
    goto_col(ci); goto_line(li);
    goto t;
  }
  lb2 = c_line;
  goto_line(lb1);
  goto_col(ci);
  flag=0;
  while ( c_col >0 ){
    if (cur_char == sym ){
      flag=1; break;
    }
    left;
  }
  if (flag==0) {
    goto_col(ci); goto_line(li);
    goto t;
  }
  cb1 = c_col; flag = 0;
  goto_col(ci+1);
  while(at_eol == 0)  {
    if (cur_char == sym ){
       flag = 1; break;
    }
    right;
  }
  if (flag==0) {
    goto_col(ci); goto_line(li);
    goto t;
  }
  cb2 = c_col;

  set_global_int('tbbl1',lb1+1);
  set_global_int('tbbl2',lb2-1);
  set_global_int('tbbc1',cb1+1);
  set_global_int('tbbc2',cb2-1);
  //make_message('l12c12='+str(lb1)+' '+str(lb2)+' '+str(cb1)+' '+str(cb2)+' ');
  if (cb2-cb1 < 2 ){
     set_global_int('tbbflag',1); goto t;
  }
  if (lb2 - lb1 < 2){
     set_global_int('tbbflag',2); goto t1;
  }
  goto_col(cb1+1);  goto_line(lb1+1);
  col_block_begin;
  goto_col(cb2-1);  goto_line(lb2-1);
  block_end;
  set_global_int('tbbflag',3);
 t1: run_macro('tbbox2');
 t:
  page_down; page_up;
  down; down; down;
  down; down; down;
  up;up;up;
  up;up;up; /* отрыв от нижней границы окна */
  pop_undo;
 }
 /* **********  Вышли из сетки ****************************** */
 macro tbbox2 {
  int i,j,k,flag,wi;
  wi = cur_window;
  set_global_int('tbb_wind_i',wi);

  flag = global_int('tbbflag');
  if (flag==0) goto t;
  i =global_int('tbbc2') - global_int('tbbc1') +1 ;
  j =global_int('tbbl2') - global_int('tbbl1');
  if (i < 3) goto t;
  create_window;

  run_macro('tfm /a=1/l=1/r=' + str(i));
  if (flag < 3) goto t;
  window_move (wi);
  block_off;
  goto_line(1);goto_col(1);
 t:
 }
 /* **********  обратно в сетку ****************************** */
 macro tbboxx {
  int i,j,k,k2,w2;
  int insertmo,refr;
  char sym;

  refr = refresh;
  refresh = false;
  insertmo = insert_mode;
  insert_mode = 1;
  push_undo;

  if (global_int('tbbflag')==0) goto t;
  sym = char(ascii(global_str('tbbsym')));
  w2 = cur_window;
  set_global_int('tbb_wind_2',w2);
  goto_line(1);
  eof; j=c_line;
  if (j ==1 ){
     goto_col(1); eol;
     if (c_col == 1) {
        if (global_int('tbbflag')==2) {
           delete_window;
           switch_window(global_int('tbb_wind_i'));
           goto t1;
        }
     }
  }
  k = global_int('tbbl2') - global_int('tbbl1');
  //make_message('i1,j,k='+str(i1)+' '+str(j)+' '+str(k));
  if (j -1 < k) j  =  k + 1;
  else { /* Набили больше, чем было */
     i=j-1;
     switch_window(global_int('tbb_wind_i'));
     goto_col(1);
     goto_line(global_int('tbbl2'));
     while(k < i){
        eol; cr; k++;
     }
     switch_window(global_int('tbb_wind_2'));
  }
  goto_line(1); goto_col(1);
  col_block_begin;
  goto_line(j);
  goto_col(global_int('tbbc2') - global_int('tbbc1')+1);
  block_end;
  switch_window(global_int('tbb_wind_i'));

  goto_col (global_int('tbbc1'));
  goto_line(global_int('tbbl1'));
  window_move (w2);
  switch_window(global_int('tbb_wind_2'));
  delete_window;
  switch_window(global_int('tbb_wind_i'));
  k2 = block_line2;
  block_off;
  goto_col(1); goto_line(k2);
  while(cur_char != sym){
    eol;
    if (c_col > 1) break;
    del_char; up; goto_col(1);
  }
t1:  goto_col (global_int('tbbc1'));
     goto_line(global_int('tbbl1'));
     page_down; page_up;
t:
    set_global_int('tbbflag',0);
    down; down; down; up;up;up; /* отрыв от нижней границы окна */
    if(  c_col > 4  ) {
       up;up;up; down; down; down;; /* отрыв от верхней границы окна */
    }
    refresh = refr;
    insert_mode = insertmo;
    pop_undo;
 }
 /* **********  Форматирование клетки ************************ */
 macro tbboxf {
  if (global_int('tbbflag')==0) goto t;
  if  (block_stat == 0) {
     goto_line(1);
     block_begin;
     eof;
     block_end;
  }
  run_macro('tf');
  block_off;
  goto_line(1);
  page_down; page_up;
t:
 }
 /*  *** Экранная установка символа сетки************** */
 macro tbbsym {
  int pb;

  set_mark(1); /* Запомнили положение курсора */
  macro_to_key(<enter>,'tbb_break',edit);
  if(  c_row > 4  ) {
     pb = 4;
  } else {
     pb = 8;
  };
  kill_box;
  put_box(17, pb, 63, pb + 2, 7, red, '', 0);
  write ('Укажите курсором строку сетки и нажмите Enter', 18,pb + 1, 7, 5);
};
/*  ******Реализация  ENTER *********************************** */
 macro tbb_break {
  str ss[1];

  goto_col(1);
  ss = get_line;
  if (ascii(ss) < 33)  {
     kill_box;
     put_box(5, 4, 26, 7, white, red, 'error', true);
     write ('ОШИБКА: НЕ СЕТКА', 6,5, white, red);
     beep;
     delay(1200);
     kill_box;
     goto t;
  }
  set_global_str('tbbsym',ss);
  make_message ('/s= ' + ss );
 t:
  macro_to_key(<enter>,'tbb_enter',edit);
  kill_box;
  get_mark(1);
  };
  macro tbb_enter {  cr;  };
 /* ********************************************************** */
