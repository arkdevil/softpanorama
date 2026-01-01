
PROGRAM show_window15_and_menu14;

	{--------------------------------------------}
	{  Демонстрационная программа использования  }
	{        пакетов Window15 и Menu14           }
	{           для Turbo pascal 5.5             }
	{					     }
	{          (c) 1990, Ярослав Мигач           }
	{--------------------------------------------}

USES dos,crt, def, window17, menu15;
             { Подключение пакетов }

VAR
   ch : CHAR;
   command : INTEGER;
   stroka : ss_string;
   all_number : BOOLEAN;
   dir_path : ss_string;
   dir_mask : ss_string;
   catalog : ARRAY [ 1..200 ] OF SEARCHREC;
   f : SEARCHREC;
   max_cat : INTEGER;
   fl : TEXT;
   ed : ARRAY [ 1..10 ] OF ss_string;

PROCEDURE load_catalog;

VAR
   stroka : ss_string;

BEGIN
     max_cat := 0;
     stroka := dir_path + dir_mask;
     FINDFIRST ( stroka, ANYFILE - DIRECTORY, f );
     IF ( DOSERROR <> 0 ) THEN
        EXIT;
     MOVE ( f, catalog [ 1 ], SIZEOF ( SEARCHREC ) );
     max_cat := 1;
     WHILE ( ( DOSERROR = 0 ) AND ( max_cat <= 200 ) ) DO
         BEGIN
             INC ( max_cat );
             FINDNEXT ( f );
             MOVE ( f, catalog [ max_cat ], SIZEOF ( SEARCHREC ) )
         END;
     DEC ( max_cat )

END; { procedure load_catalog }

{----------------------------------------------------------}

PROCEDURE find_file;

VAR
   mn : INTEGER;
   max_mn : INTEGER;
   y : INTEGER;
   err : INTEGER;
   size : ss_string;
   indx : INTEGER;
   stroka : ss_string;
   w : INTEGER;
   ch : CHAR;
   i_help : INTEGER;
   key_number : INTEGER;
   str_hlp : STRING;
   num_file : INTEGER;
   key_file : ARRAY [ 1..200 ] OF CHAR;
   indx_file : ARRAY [ 1..200 ] OF INTEGER;

BEGIN
     num_file := 1;
     indx := 1;
     y := 15;
     max_mn := 1;
     w := 3;
     WHILE  ( indx <= max_cat ) DO
         BEGIN
             IF ( y > 14 ) THEN
                BEGIN
                     y := 1;
                     INC ( max_mn );
                     work_number ( w );
                     INC ( w );
                     num_mnu ( max_mn );
		     n_window ( 25, 8, 66, 24, GREEN,YELLOW );
                     r1_window ( 1, 1,( 45 - 4 ),( 22 - 6 ),
                                 1, CHR ( 205 ) );
                     show_t ( BLACK, WHITE );
                     w_print ( 2, ( 22 - 6 ),
                        'Просмотр постранично : Pg/up, Pg/dn' );
                     STR ( ( max_mn - 1 ), stroka );
                     stroka := CONCAT ( 'Страница > ', stroka );
                     w_print ( 17, 1, '  Завершение ESC ' );
                     w_print ( 3, 1, stroka );
		     n_mnu ( RED, 1, 6,2 )
                END;
              STR ( catalog [ indx ].size, size );
              stroka := catalog [ indx ].name;
              stroka := CONCAT ( ' ', stroka );
              WHILE ( LENGTH ( stroka ) < 13 ) DO
                   stroka := CONCAT ( stroka, ' ' );
              stroka := CONCAT ( stroka, ' size > ',size );
              WHILE ( LENGTH ( stroka ) < 33 ) DO
                   stroka := CONCAT ( stroka, ' ' );
              n_cmd ( stroka );
              INC ( indx );
              INC ( y )
         END;
     ch := ' ';
     indx := 1;
     w := 3;
     mn := 2;
     i_help := 0;
     key_number := 0;
     WHILE ( ( ch <> CHR ( $0D ) ) AND ( ch <> CHR ( 27 ) ) ) DO
           BEGIN
                work_number ( w );
                num_mnu ( mn );
                p_window ( w );
                ch := ' ';
                WHILE ( ( ch <> CHR ( $0D ) ) AND ( ch <> CHR ( 73 ) )
                        AND ( ch <> CHR ( 81 ) ) AND
                        ( ch <> CHR ( 27 ) ) AND ( ch <> CHR ( 82 ) ) AND
                        ( ch <> CHR ( 83 ) ) ) DO
                      ctl_mnu ( indx, ch );
                IF ( ( ch = CHR ( 73 ) ) AND ( mn < max_mn ) ) THEN
                   BEGIN
                        INC ( mn );
                        indx := 1;
                        INC ( w )
                   END;
                IF ( ( ch = CHR ( 81 ) ) AND ( mn > 2 ) ) THEN
                   BEGIN
                        DEC ( mn );
                        indx := 1;
                        DEC ( w )
                   END;
                IF  ( ch = CHR ( 82 ) ) THEN
                   BEGIN
                        IF ( key_file [ indx + ( w - 3 ) * 14 ] = ' ' )
                           THEN BEGIN
                                INC ( key_number );
                                indx_file [ key_number ] :=
                                   indx + ( w - 3 ) * 14;
                                key_file [ indx + ( w - 3 ) * 14 ] := '+';
                                w_xy_print ( 5, ( indx + 1 ), CHR ( 16 ) );
                                STR ( key_number , str_hlp );
                                w_xy_print ( 2, ( indx + 1 ), str_hlp );
                                INC ( indx );
                                INC ( i_help )
                           END
                        ELSE
                            IF ( indx_file [ key_number ] =
                                 indx + ( w - 3 ) * 14 ) THEN
                               BEGIN
                                     key_file [ indx + ( w - 3 ) * 14 ]
                                              := ' ';
                                     w_xy_print ( 2, ( indx + 1 ), '    ' );
                                     INC ( indx );
                                     DEC ( i_help );
                                     indx_file [ key_number ] := 0;
                                     DEC ( key_number )
                               END
                   END
           END;
     num_file := indx + ( w - 3 ) * 14;
     IF ( i_help = 0 ) THEN
        BEGIN
             indx_file [ 1 ] := num_file;
             indx_file [ 2 ] := 0
        END;
     IF ( ch = CHR ( 27 ) ) THEN
        num_file := 0;
     w := 3;
     mn := 2;
     WHILE ( mn < max_mn ) DO
           BEGIN
               work_number ( w );
               num_mnu ( mn );
               d_window;
               d_mnu;
               INC ( w );
               INC ( mn )
           END;
     work_number ( w );
     num_mnu ( mn );
     d_mnu;
     rd_window ( CHR ( 205 ) )

END; { procedure find_file }

PROCEDURE any_key;

VAR
   ch : CHAR;

BEGIN
     WHILE ( KEYPRESSED ) DO
	   ch := READKEY;
     ch := READKEY;
     IF ( KEYPRESSED ) THEN
	ch := READKEY

END; { procedure any_key }

PROCEDURE wait;

BEGIN
     work_number ( 1 );
     set_color_symbol ( WHITE );
     set_color_fon ( RED );
     xy_print ( 7,22,
     '             Нажмите любую клавишу для продолжения                ');
     any_key;
     work_number ( 1 );
     xy_print ( 7,22,
     '                                                                  ')
END; { procedure wait }

PROCEDURE quit;

BEGIN
      work_number ( 2 );
      rd_window ( CHR ( 205 ));
      work_number ( 1 );
      rd_window ( CHR ( 205 ));
      HALT

END; { procedure quit }

PROCEDURE speed_windows;

VAR
    indx : BYTE;

BEGIN
     work_number ( 2 );
     n_window ( 20,10,60,15, GREEN, MAGENTA );
     r1_window ( 1,1,40,5,1,CHR ( 196 ));
     show_t ( BLACK, WHITE );
     w_print ( 2,2,'При помощи этих пакетов Вы можете' );
     w_print ( 2,3,'организовать эстетичный и удобный' );
     w_print ( 2,4,'   интерфейс с пользователем' );
     work_number ( 2 );
     rn_window ( #0 );
     FOR indx := 1 TO 9 DO
	 BEGIN
	      DELAY ( 20 );
	      m_window ( ( 20 - indx * 2 ), 10 )
	 END;
     FOR indx := 1 TO 9 DO
	 BEGIN
	      DELAY ( 20 );
	      m_window ( 2, ( 10 - indx ) )
	 END;
     DELAY ( 2000 );
     n_window ( 20,10,60,15, GREEN, MAGENTA );
     r1_window ( 1,1,40,5,1,CHR ( 196 ));
     show_t ( BLACK, WHITE );
     w_print ( 2,2, 'Использование Window15 и Menu14' );
     w_print ( 2,3,'  сделает Ваши программы более' );
     w_print ( 2,4,'наглядными и конкурентоспособными' );
     work_number ( 2 );
     rn_window ( #0 );
     FOR indx := 1 TO 9 DO
	 BEGIN
	      DELAY ( 20 );
	      m_window ( ( 20 + indx * 2 ), 10 )
	 END;
     FOR indx := 1 TO 11 DO
	 BEGIN
	      DELAY ( 20 );
	      m_window ( 38, ( 10 + indx ) )
	 END;
     DELAY ( 2000 );
     n_window ( 20,10,55,15, GREEN, MAGENTA );
     r1_window ( 1,1,35,5,1,CHR ( 196 ));
     show_t ( BLACK, WHITE );
     w_print ( 2,2,'Подпрограммы пакетов позволяют' );
     w_print ( 2,3,'вводить и редактировать строки,' );
     w_print ( 2,4,'рисовать таблицы, строить меню' );
     work_number ( 2 );
     rn_window ( #0 );
     FOR indx := 1 TO 12 DO
	 BEGIN
	      DELAY ( 20 );
	      m_window ( ( 20 + indx * 2 ), 10 )
	 END;
     FOR indx := 1 TO 9 DO
	 BEGIN
	      DELAY ( 20 );
	      m_window ( 44, ( 10 - indx ) )
	 END;
     DELAY ( 2000 );
     n_window ( 20,10,55,15, GREEN, MAGENTA );
     r1_window ( 1,1,35,5,1,CHR ( 196 ));
     show_t ( BLACK, WHITE );
     w_print ( 2,2,'Подпрограммы пакетов позволяют' );
     w_print ( 2,3,' накладывать и переность окна,' );
     w_print ( 2,4,'   управлять принтером и т.п' );
     work_number ( 2 );
     rn_window ( #0 );
     FOR indx := 1 TO 9 DO
	 BEGIN
	      DELAY ( 20 );
	      m_window ( ( 20 - indx * 2 ), 10 )
	 END;
     FOR indx := 1 TO 11 DO
	 BEGIN
	      DELAY ( 20 );
	      m_window ( 2, ( 10 + indx ) )
	 END;
     DELAY ( 2000 );
     n_window ( 20,10,65,16, RED, BLUE );
     r1_window ( 1,1,45,6,1,CHR ( 205 ));
     show_t ( BLACK, WHITE );
     set_color_symbol ( WHITE );
     w_print ( 2,2,'        Кооператив   В Е С Т А ' );
     w_print ( 2,4,'    обеспечивает высокую надежность,' );
     w_print ( 2,5,' и эффективность разработанных программ' );
     work_number ( 2 );
     rn_window ( #0 );
     DELAY ( 10000 );

     pd_window;
     DELAY ( 500 );
     pd_window;
     DELAY ( 500 );
     pd_window;
     DELAY ( 500 );
     pd_window;
     DELAY ( 500 );
     pd_window


END; { procedure speed_windows }

PROCEDURE titl;

VAR
   indx : BYTE;

BEGIN
     WRITELN;
     WRITELN ( ' (c) 1990, В Е С Т А' );
     work_number ( 1 );
     n_window ( 1,1,80,25, CYAN, BLUE );
     w_print ( 15,2, 'Демонстрационная программа работы с текстовыми');
     w_print ( 15,3, ' окнами при помощи пакетов Window15 и Menu14');
     set_color_symbol ( WHITE );
     set_color_fon ( RED );
     work_number ( 1 );
     rn_window ( #205 );
     work_number ( 31 );
     n_window ( 24, 11, 54, 14 , RED, WHITE );
     set_color_symbol ( BLINK + YELLOW );
     w_print ( 5,2,'(c) 1990,    В Е С Т А');
     work_number ( 31 );
     show_t ( MAGENTA, WHITE );
     r1_window ( 1,1,30,3,1,CHR ( 205 ) );
     tp_window;
     work_number ( 1 );
     w_xy_print ( 7,22,
     '                                                               ');
     speed_windows;
     work_number ( 2 );
     n_window ( 3,4,77,7,BLUE,YELLOW );
     work_number ( 2 );
     num_mnu ( 1 );
     n_mnu ( RED, 0,3,2 );
     n_cmd ( ' ОКНА ' );
     n_cmd ( ' ЛИНИИ ' );
     n_cmd ( ' РЕДАКТОР ' );
     n_cmd ( ' ФАЙЛЫ ' );
     n_cmd ( ' ПРИНТЕР ' );
     n_cmd ( ' Window15 ' );
     n_cmd ( ' Menu14 ' );
     n_cmd ( ' ВЫХОД ' );
     r1_window ( 1,1,74,3,1,CHR(205));
     show_t ( BLACK, WHITE );
     rn_window ( CHR ( 0 ));
     FOR indx := 1 TO 10 DO
	 ed [ indx ] := '';
     ed [ 2 ] := '          Вы можете отредактировать этот текст';
     ed [ 3 ] := '          и распечатать его командой  ПРИНТЕР';
     ed [ 6 ] := '          В Е С Т А  выполнит любой Ваш заказ на ';
     ed [ 7 ] := '        программное обеспечение в кратчайшие сроки';
     ed [ 9 ] := '         Обращайтесь по тел. 441-40-81, 518-09-01';
     ed [ 10 ]:= ''
END;

PROCEDURE wind;

VAR
    indx : BYTE;

BEGIN
     work_number ( 2 );
     n_window ( 20,10,60,15, GREEN, MAGENTA );
     r1_window ( 1,1,40,5,1,CHR ( 196 ));
     show_t ( BLACK, WHITE );
     w_print ( 2,2,'При помощи этих пакетов Вы можете' );
     w_print ( 2,3,'организовать эстетичный и удобный' );
     w_print ( 2,4,'   интерфейс с пользователем' );
     work_number ( 2 );
     rn_window ( #0 );
     FOR indx := 1 TO 9 DO
	 BEGIN
	      DELAY ( 20 );
	      m_window ( ( 19 - indx * 2 ), ( 10 - indx ) )
	 END;
     DELAY ( 2000 );
     n_window ( 20,10,60,15, GREEN, MAGENTA );
     r1_window ( 1,1,40,5,1,CHR ( 196 ));
     show_t ( BLACK, WHITE );
     w_print ( 2,2, 'Использование Window15 и Menu14' );
     w_print ( 2,3,'  сделает Ваши программы более' );
     w_print ( 2,4,'наглядными и конкурентоспособными' );
     work_number ( 2 );
     rn_window ( #0 );
     FOR indx := 1 TO 10 DO
	 BEGIN
	      DELAY ( 20 );
	      m_window ( ( 21 + indx * 2 ), ( 10 + indx ))
	 END;
     DELAY ( 2000 );
     n_window ( 20,10,55,15, GREEN, MAGENTA );
     r1_window ( 1,1,35,5,1,CHR ( 196 ));
     show_t ( BLACK, WHITE );
     w_print ( 2,2,'Подпрограммы пакетов позволяют' );
     w_print ( 2,3,'вводить и редактировать строки,' );
     w_print ( 2,4,'рисовать таблицы, строить меню' );
     work_number ( 2 );
     rn_window ( #0 );
     FOR indx := 1 TO 9 DO
	 BEGIN
	      DELAY ( 20 );
	      m_window ( ( 24 + indx * 2 ), ( 10 - indx ) )
	 END;
     DELAY ( 2000 );
     n_window ( 20,10,55,15, GREEN, MAGENTA );
     r1_window ( 1,1,35,5,1,CHR ( 196 ));
     show_t ( BLACK, WHITE );
     w_print ( 2,2,'Подпрограммы пакетов позволяют' );
     w_print ( 2,3,' накладывать и переность окна,' );
     w_print ( 2,4,'   управлять принтером и т.п' );
     work_number ( 2 );
     rn_window ( #0 );
     FOR indx := 1 TO 10 DO
	 BEGIN
	      DELAY ( 20 );
	      m_window ( ( 21 - indx * 2 ), ( 10 + indx ) )
	 END;
     DELAY ( 2000 );
     n_window ( 20,10,65,16, RED, BLUE );
     r1_window ( 1,1,45,6,1,CHR ( 205 ));
     show_t ( BLACK, WHITE );
     set_color_symbol ( WHITE );
     w_print ( 2,2,'        Кооператив   В Е С Т А ' );
     w_print ( 2,4,'    обеспечивает высокую надежность,' );
     w_print ( 2,5,' и эффективность разработанных программ' );
     work_number ( 2 );
     rn_window ( #0 );
     DELAY ( 5000 );

     pd_window;
     DELAY ( 500 );
     pd_window;
     DELAY ( 500 );
     pd_window;
     DELAY ( 500 );
     pd_window;
     DELAY ( 500 );
     pd_window

END; { procedure wind }

PROCEDURE lines;

VAR
   stroka : ss_string;
   ch : CHAR;
   wx1,wy1,wx2,wy2, wy, wx : BYTE;
   err : INTEGER;
   cd : BYTE;
   mx, my : BYTE;
   key : BOOLEAN;

PROCEDURE load_coord ( k_stroka : ss_string; VAR coord : BYTE );

VAR
   err : INTEGER;

BEGIN
    n_window ( 20,20,60,23,RED,BLUE );
    w_print ( 4,2,'Для выхода нажмите ESC');
    show_t ( BLACK, WHITE );
    tp_window;
    stroka := '';
    n_window ( 10,10,41,14,GREEN, YELLOW );
    w_print ( 2,2, k_stroka );
    rn_window ( #196 );
    r1_window ( 1,1,31,4,1,#196);
    show_t ( BLACK, WHITE );
    tp_window;
    REPEAT
          xy_edit ( 2,3,ch,2,stroka );
          VAL ( stroka, coord, err );
          IF (( err <> 0 ) AND ( stroka <> '' )) THEN
             warning ( 5,5,'Нечисловое значение !!!' )
    UNTIL ( ( err = 0 ) OR  ( ch = CHR ( 27 ) )  );
    rd_window ( #196 );
    pd_window;
    IF  ( ch = CHR ( 27 ) ) THEN key := TRUE

END;

PROCEDURE line_cod ( VAR cd : BYTE; k : BYTE );

VAR
   cm : INTEGER;

BEGIN
     n_window ( 15,20,68,23,RED,WHITE );
     w_print ( 4,1,'Для перемещения окна используйте : S - влево, ');
     w_print ( 4,2,'      D - вправо, E - вверх, X - вниз');
     stroka := '  '+CHR(27)+','+CHR (26)+', Enter, ESC ';
     w_print ( 2,3,'Для управления меню используйте : '+stroka );
     show_t ( BLACK, WHITE );
     tp_window;
     num_mnu ( 2 );
     n_window ( mx,my,( mx + 26 ),( my + 4 ),GREEN,WHITE );
     n_mnu ( BLACK,1,2,2 );
     IF ( k = 0 ) THEN
        BEGIN
             n_cmd( 'Горизонтальная одинарная' );
             n_cmd( 'Горизонтальная двойная  ' )
        END
     ELSE
         BEGIN
              n_cmd ( 'Вертикальная одинарная' );
              n_cmd ( 'Вертикальная двойная  ' )
         END;
     ch := ' ';
     cm := 1;
     set_color_symbol ( RED );
     rn_window ( CHR ( 196 ));
     r1_window ( 1,1,26,4,1,#196);
     work_number ( 0 );
     show_t ( BLACK, WHITE );
     tp_window;
     WHILE ( ch <> CHR ( $0D ) )  DO
           BEGIN
                ctl_mnu ( cm, ch );
                CASE ch OF
                    #27 : BEGIN
			       d_mnu;
			       pd_window;
			       pd_window;
			       key := TRUE;
			       EXIT
                          END;
                    'e','E' : BEGIN
                               DEC ( my );
                               IF ( my = 0 ) THEN
                                  INC ( my );
                               m_window ( mx, my )
                          END;
                    'x','X' : BEGIN
                               INC ( my );
                               IF ( my = 20 ) THEN
                                  DEC ( my );
                               m_window ( mx, my )
                          END;
                    's','S' : BEGIN
                               DEC ( mx );
                               IF ( mx < 1 ) THEN
                                  INC ( mx );
                               m_window ( mx, my )
                          END;
                    'd','D' : BEGIN
                               INC ( mx );
                               IF ( mx = 55 ) THEN
                                  DEC ( mx );
                               m_window ( mx, my )
                          END
                END
           END;
     IF ( k = 0 ) THEN
        CASE cm OF
             1 : cd := 196;
             2 : cd := 205
        END
     ELSE
         CASE cm OF
              1 : cd := 179;
              2 : cd := 186
	 END;
     d_mnu;
     pd_window;
     pd_window

END; { procedure line_code }

BEGIN
     mx := 10;
     my := 10;
     key := FALSE;
     work_number ( 1 );
     n_window ( 1,1,80,25, CYAN, BLUE );
     w_print ( 25,3, 'Lines testing procedures' );
     rn_window ( #205 );
     WHILE TRUE DO
           BEGIN
                line_cod ( cd, 1 );
		IF ( key ) THEN
		   BEGIN
			rd_window ( CHR ( 205 ));
			EXIT
		   END;
                REPEAT
                      load_coord ('Введите y1', wx1 );
		      IF ( key ) THEN
			 BEGIN
			      rd_window ( CHR ( 205 ));
			      EXIT
			 END;
                      IF (( wx1 < 1 ) OR ( wx1 > 25 ) ) THEN
                         warning ( 10,20,'Недопустмое значение')
                UNTIL ((wx1 >= 1 ) AND ( wx1 <= 25 ));
                REPEAT
                      load_coord ('Введите y2', wx2 );
		      IF ( key ) THEN
			 BEGIN
			      rd_window ( CHR ( 205 ));
			      EXIT
			 END;
                      IF (( wx2 < 1 ) OR ( wx2 > 25 ) OR ( wx2 < wx1 )) THEN
                         warning ( 10,20,'Недопустмое значение')
                UNTIL ((wx2 >= 1 ) AND ( wx2 <= 25 ) AND ( wx2 >= wx1 ));
                REPEAT
                      load_coord ('Введите x', wy );
		      IF ( key ) THEN
			 BEGIN
			      rd_window ( CHR ( 205 ));
			      EXIT
			 END;
                      IF (( wy < 1 ) OR ( wy > 80 )) THEN
                         warning ( 10,20,'Недопустмое значение')
                UNTIL ((wy >= 1 ) AND ( wy <= 80 ));
                line_y ( wy, wx1, wx2, 0, 2, CHR ( cd ) );
                ch := READKEY;
                line_cod ( cd, 0 );
		IF ( key ) THEN
		   BEGIN
			rd_window ( CHR ( 205 ));
			EXIT
		   END;
                REPEAT
                      load_coord ('Введите x1', wy1 );
		      IF ( key ) THEN
			 BEGIN
			      rd_window ( CHR ( 205 ));
			      EXIT
			 END;
                      IF (( wy1 < 1 ) OR ( wy1 > 80 )) THEN
                         warning ( 10,20,'Недопустмое значение')
                UNTIL ((wy1 >= 1 ) AND ( wy1 <= 80 ));
                REPEAT
                      load_coord ('Введите x2', wy2 );
		      IF ( key ) THEN
			 BEGIN
			      rd_window ( CHR ( 205 ));
			      EXIT
			 END;
                      IF (( wy2 < wy1 ) OR ( wy2 > 80 )) THEN
                         warning ( 10,20,'Недопустмое значение')
                UNTIL ((wy2 >= wy1 ) AND ( wy2 <= 80 ));
                REPEAT
                      load_coord ('Введите y', wx );
		      IF ( key ) THEN
			 BEGIN
			      rd_window ( CHR ( 205 ));
			      EXIT
			 END;
                      IF (( wx < 1 ) OR ( wx > 25 )) THEN
                         warning ( 10,20,'Недопустмое значение')
                UNTIL ((wx >= 1 ) AND ( wx <= 25 ));
                line_x ( wx, wy1, wy2, 0, 2, CHR ( cd ) )
           END

END; { procedure lines }

PROCEDURE editor;

VAR
   ch : CHAR;
   ey : BYTE;
   indx : BYTE;
   stroka : ss_string;

BEGIN
     n_window ( 5,2,75,24,GREEN,BLUE);
     set_color_symbol ( YELLOW );
     w_print ( 10,3,'Для редактирования текста из 10 строк используйте:');
     stroka := ' '+CHR(26)+','+CHR(27)+','+CHR(24)+','+CHR(25)+
	       ' ESC, Ins, Del ';
     w_print ( 19, 4, stroka );
     work_number ( 0 );
     rn_window ( CHR ( 196 ) );
     n_window ( 7,8,73,18,LIGHTGRAY,BLACK);
     show_t ( RED,YELLOW );
     tp_window;
     ey := 1;
     ch := ' ';
     FOR indx := 1 TO 10 DO
	 xy_print ( 2, indx, ed [ indx ] );
     WHILE ( ch <> CHR ( 27 ) ) DO
	  BEGIN
	       xy_edit ( 2,ey,ch,60,ed [ ey ] );
	       IF ( ( ( ch = CHR ( 80 ) ) OR ( ch = CHR ( $0D )))
		   AND ( ey < 10 ) ) THEN
		  INC ( ey );
	       IF ( ( ey > 1 ) AND ( ch = CHR ( 72 ) ) ) THEN
		  DEC ( ey  )
	  END;
     d_window;
     rd_window ( CHR ( 196 ) )

END; { procedure editor }

PROCEDURE menu;

BEGIN
     GETDIR ( 0, dir_path );
     IF ( dir_path [ LENGTH ( dir_path ) ] <> '\' ) THEN
        dir_path := CONCAT ( dir_path, '\' );
     dir_mask := '*.*';
     load_catalog;
     find_file

END; { procedure menu }

PROCEDURE printer;

VAR
   indx : BYTE;
   key : BOOLEAN;
   sym : BYTE;
   stroka : ss_string;

BEGIN
     n_window ( 6, 20, 70, 25, BLUE, RED );
     w_print ( 16, 3, ' Для выхода воспользуйтесь ESC' );
     show_t ( BLACK, WHITE );
     rn_window ( CHR ( 0 ) );
     key := FALSE;
     indx := 1;
     WHILE ( ( NOT key ) AND ( indx <= 10 ) ) DO
	   BEGIN
		sym := 1;
		stroka := ed [ indx ];
		WHILE ( ( NOT key ) AND ( sym <= LENGTH ( stroka ))) DO
		      BEGIN
			   epson ( stroka [ sym ], key );
			   INC ( sym )
		      END;
		epson ( CHR ( $0D ), key );
		epson ( CHR ( $0A ), key );
		INC ( indx )
	   END;
     pd_window

END; { procedure printer }

PROCEDURE files ( name : ss_string );

VAR
   error : BOOLEAN;

BEGIN
     ASSIGN ( fl, name);
     {$I-}
     RESET ( fl );
     {$I+}
     IF ( IORESULT <> 0 ) THEN
        BEGIN
	    n_window ( 30, 12, 53, 15, RED, BLINK + YELLOW );
	    w_print ( 2,2 ,'Нет файла '+ name );
            w_print ( 2,3 ,'Нажмите любую клавишу' );
            rn_window ( CHR ( 205 ) );
	    any_key;
            rd_window ( CHR ( 205 ) );
            EXIT
        END;
     n_window ( 3, 8, 77, 23, RED, GREEN );
     r1_window ( 1, 1,( 77 - 2 ),( 22 - 6 ), 2, CHR ( 205 ) );
     w_xy_print ( 6, ( 22 - 6 ),
     'Нажмите любую клавишу для продолжения или ESC - возврат' );
     n_window ( 4, 9, 76, 22, RED, WHITE );
     ch := ' ';
     WHILE ( ( NOT EOF ( fl ) ) AND ( ch <> CHR ( 27 ) ) ) DO
           BEGIN
                f_window ( fl, '/','@', error );
                IF ( NOT error ) THEN
                   BEGIN
			p_window ( 0 );
			ch := READKEY
		   END
                ELSE
		    BEGIN
			 {$I-}
			 CLOSE ( fl );
			 {$I+}
			 d_window;
                         rd_window ( CHR ( 205 ) );
                         EXIT
                    END
	   END;
     {$I-}
     CLOSE ( fl );
     {$I+}
     d_window;
     rd_window ( CHR ( 205 ) )

END; { procedure files }

PROCEDURE wind15;

BEGIN
     files ( 'WINDOW15.DOC' )

END; { procedure wind15 }

PROCEDURE mnu14;

BEGIN
     files ( 'MENU14.DOC' )

END; { procedure mnu14 }

BEGIN
      titl;
      command := 1;
      WHILE TRUE DO
	    BEGIN
		  work_number ( 1 );
		  set_color_fon ( RED );
		  set_color_symbol ( WHITE );
		  xy_print ( 7,22,
     '    Для передвижения указателя меню используйте клавиши:       ');
		  stroka := '  '+CHR (26)+' перейти влево, ';
		  stroka := stroka + CHR (27)+' перейти вправо, ';
		  stroka := stroka + 'Enter выбрать команду ';
		  xy_print ( 9, 23,stroka );
		  ch := ' ';
		  num_mnu ( 1 );
		  work_number ( 2 );
		  WHILE ( ch <> CHR ( $0D )) DO
			ctl_mnu ( command, ch );
		  CASE command OF
			 1 : wind;
			 2 : BEGIN
                                  save_ecran;
                                  lines;
                                  restore_ecran
                             END;
			 3 : editor;
			 4 : menu;
			 5 : printer;
			 6 : wind15;
                         7 : mnu14;
			 8 : quit
		  END
	    END

END.
