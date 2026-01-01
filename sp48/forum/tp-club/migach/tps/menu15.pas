
                 {---------------------------}
                 {   Пакет работы с меню     }
                 {      MENU    V 1.5        }
                 {                           }
                 {  (c) 1990, Мигач Ярослав  }
                 {---------------------------}

        { Пакет предназначен для использования совместно }
        {         с пакетом WINDOW V 1.6                 }

UNIT menu15;

INTERFACE

USES Dos, Crt, Def, Window17;

{----------------------------------------------------------}

CONST
     mm_max = 20; { Максимальное количество меню }

PROCEDURE num_mnu ( number : BYTE );
PROCEDURE n_mnu ( cl_usr, mkey, x, y : BYTE );
PROCEDURE n_cmd ( cmd : ss_string );
PROCEDURE d_mnu;
FUNCTION max_cmd_num : INTEGER;
PROCEDURE ctl_mnu ( VAR number : INTEGER; VAR ch : CHAR );
PROCEDURE p_cmd ( number : INTEGER; kkey : BYTE );

{----------------------------------------------------------}

IMPLEMENTATION

TYPE
    point_mnu = ^data_mnu;
                { Ссылка на образ меню }

    data_mnu = RECORD   { Образ команды меню }

                     color_usr : BYTE;
                                 { Цвет выборки }
                     key : BYTE;
                                 { Направление рисования }
                                 { 0 - по горизонтали    }
                                 { 1 - по вертикали      }
                     kx, ky : BYTE;
                                 { Координаты команды меню }
                                 { в текущем окне          }
                     m_point : point_mnu;
                                 { Ссылка на следующую }
                                 { команду             }
                     m_pred : point_mnu;
                                 { Ссылка на предыдущую }
                                 { команду              }
                     mnu : ss_string
                                 { Команда меню }
               END;

{----------------------------------------------------------}

VAR
   mm_num : BYTE;    { Текущий номер меню }

   mm_dat : ARRAY [ 1..mm_max ] OF point_mnu;
                        { Ссылки на создаваемые меню }

{----------------------------------------------------------}

PROCEDURE m_init;  { Процедура инициализации пакета   }
                   {   / должна быть вызвана 1 раз    }
                   { до ипользования ниже приведенных }
                   { подпрограмм /                    }

VAR
   indx : BYTE; { Индексная переменная }

BEGIN
     FOR indx := 1 TO mm_max DO
        mm_dat [ indx ] := NIL;
     mm_num := 1
END; { procedure m_init }

{---------------------------------------------------------}

PROCEDURE num_mnu ( number : BYTE );
                    { Процедура установки номера }
                    { рабочего меню              }

BEGIN
     mm_num := number
END; { procedure mun_mnu }

{----------------------------------------------------------}

PROCEDURE n_mnu ( cl_usr : BYTE;
                          { Цвет выборки }
                  mkey : BYTE;
                          { Направление рисования }
                  x, y : BYTE
                          { Координаты первой команды }
                          { меню в рабочем окне       } );

          { Процедура образования нового меню  }
          { Перед вызовом этой процедуры необ- }
          { ходимо инициализировать новое окно }
          { в котором будет находится данное   }
          { меню и установить его номер        }

BEGIN
     NEW ( mm_dat [ mm_num ] );
     WITH mm_dat [ mm_num ]^ DO
         BEGIN
              m_point := NIL;
              m_pred := NIL;
              kx := x;
              ky := y;
              color_usr := cl_usr;
              mnu := '';
              key := mkey
         END
END; { procedure n_mnu }

{----------------------------------------------------------}

PROCEDURE n_cmd ( cmd : ss_string );

          { Процедура добавления новой команды }
          {          в текущее меню            }

VAR
   p, help : point_mnu; { Вспомогательные ссылки }

   hstr : ss_string; { Вспомогательная строка }

BEGIN
     SetHeapMess ( 'Модуль Menu15, процедура добавления новой команды меню');
     WITH mm_dat [ mm_num ]^ DO
          BEGIN
               IF ( mnu = '' ) THEN
                  BEGIN
                       mnu := cmd;
                       w_print ( kx, ky, cmd );
                       EXIT
                  END;
               help := m_point
          END;
     p := mm_dat [ mm_num ];
     WHILE ( help <> NIL ) DO
           BEGIN
                p := help;
                help := help^.m_point
           END;
     NEW ( help );
     p^.m_point := help;
     help^.m_pred := p;
     help^.m_point := NIL;
     help^.key := p^.key;
     help^.color_usr := p^.color_usr;
     help^.mnu := cmd;
     IF ( p^.key = 0 ) THEN
        BEGIN
             help^.ky := p^.ky;
             IF ( p = NIL ) THEN
                help^.kx := p^.kx + 1 + LENGTH ( cmd )
             ELSE
                BEGIN
                     hstr := p^.mnu;
                     help^.kx := p^.kx + 1 + LENGTH ( hstr )
                END
        END
     ELSE
         BEGIN
              help^.ky := p^.ky + 1;
              help^.kx := p^.kx
         END;
     w_print ( help^.kx, help^.ky, cmd )
END; { procedure n_cmd }

{$V+}

{----------------------------------------------------------}

PROCEDURE d_mnu;   { Процедура уничтожения меню }
                   {    с текущим номером       }

VAR
   help : point_mnu; { Вспомогательная ссылка }

BEGIN
     help := mm_dat [ mm_num ];
     WHILE ( help^.m_point <> NIL ) DO
           help := help^.m_point;
     WHILE ( help^.m_pred <> NIL ) DO
           BEGIN
                help := help^.m_pred;
                DISPOSE ( help^.m_point )
           END;
     DISPOSE ( mm_dat [ mm_num ] );
     mm_dat [ mm_num ] := NIL
END; { procedure d_mnu }

{----------------------------------------------------------}

FUNCTION max_cmd_num : INTEGER;

         { Функция возвращает максимальный номер }
         {     команды в текущем меню            }

VAR
   help : point_mnu;  { Вспомогательная ссылка }

   m : INTEGER; { Индексная переменая }

BEGIN
     help := mm_dat [ mm_num ]^.m_point;
     m := 1;
     WHILE ( help <> NIL ) DO
           BEGIN
                m := m + 1;
                help := help^.m_point
           END;
     max_cmd_num := m

END; { function max_cmd_num }

{----------------------------------------------------------}

PROCEDURE ctl_mnu ( VAR number : INTEGER;
                               { Номер команды меню }
                    VAR ch : CHAR
                               { Команда выборки } );

         { Процедура управления текущим меню }

VAR
   help : point_mnu;  { Вспомогательная ссылка }

   m : INTEGER; { Вспомогательный номер }

   hhh : BYTE;

BEGIN
     ch := ' ';
     IF ( number > max_cmd_num ) THEN
        number := max_cmd_num;
     IF ( number < 1 ) THEN
        number := 1;
     WHILE ( ( ch = ' ' ) OR ( ( ( ch = CHR ( 75 ) ) OR
             ( ch = CHR ( 77 ) ) ) AND ( mm_dat [ mm_num ]^.key = 0 ) )
             OR ( ( ( ch = CHR ( 72 ) ) OR ( ch = CHR ( 80 ) ) ) AND
             ( mm_dat [ mm_num ]^.key <> 0 ) ) ) DO
            BEGIN
                 m := 1;
                 help := mm_dat [ mm_num ];
                 WHILE ( m <> number ) DO
                       BEGIN
                            INC ( m );
                            help := help^.m_point
                       END;
                 WITH help^ DO
                      BEGIN
                           work_number ( 0 );
                           set_color_fon ( color_usr );
                           xy_print ( kx,ky, mnu );
                           work_number ( 0 )
                      END;
                 ch := GetKey;
                 IF ( SingKey ) THEN
                    ch := GetKey;
                 IF ( ( ( ch = CHR ( 75 ) )  AND
                        ( mm_dat [ mm_num ]^.key = 0 ) )
                   OR ( ( ch = CHR ( 72 ) ) AND
                        ( mm_dat [ mm_num ]^.key = 1 ) ) ) THEN
                    BEGIN
                         DEC ( number );
                         IF ( number < 1 ) THEN
                            number := max_cmd_num
                    END;
                 IF ( ( ( ch = CHR ( 80 ) ) AND
                        ( mm_dat [ mm_num ]^.key = 1 ) )
                   OR ( ( ch = CHR ( 77 ) ) AND
                        ( mm_dat [ mm_num ]^.key = 0 ) ) ) THEN
                    BEGIN
                         INC ( number );
                         IF ( number > max_cmd_num ) THEN
                            number := 1
                    END;
                 WITH help^ DO
                      xy_print ( kx, ky, mnu )
            END;

END; { procedure  ctl_mnu }

{----------------------------------------------------------}

PROCEDURE p_cmd ( number : INTEGER;
                           { Номер команды }
                  kkey : BYTE
                           { Ключ печати       }
                           { 0 - без выделения }
                           { 1 - с выделением  } );

         { Процедура печати команды с заданным }
         {              номером                }


VAR
   m : INTEGER;
   help : point_mnu;
   hhh : BYTE;

BEGIN
     IF ( ( number < 1 ) OR ( number > max_cmd_num ) ) THEN
        EXIT;
     m := 1;
     help := mm_dat [ mm_num ];
     WHILE ( m <> number ) DO
           BEGIN
                INC ( m );
                help := help^.m_point
           END;
     WITH help^ DO
          IF ( kkey = 0 ) THEN
             xy_print ( kx, ky, mnu )
          ELSE
             BEGIN
                   work_number ( 0 );
                   set_color_fon ( color_usr );
                   xy_print ( kx, ky, mnu );
                   work_number ( 0 )
             END

END; { procedure p_cmd }

{----------------------------------------------------------}

BEGIN
     m_init

END.

{----------------------------------------------------------}
