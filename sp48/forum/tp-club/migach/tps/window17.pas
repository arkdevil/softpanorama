               {--------------------------------------}
               { ПАКЕТ ДЛЯ РАБОТЫ С ТЕКСТОВЫМИ ОКНАМИ }
               {                                      }
               {     W I N D O W S    V 1.7           }
               {        ( turbo windows )             }
               {                                      }
               {  (c) 1990, 1991, Мигач Ярослав       }
               {--------------------------------------}

UNIT window17;

{$O+,F+,D-,R-,S-,I-}

INTERFACE

USES Dos, Crt, Def, Fkey11;

{-------------------------------------------------------------------------}

CONST
     wwmax = 32;  { количество независимых окон }

TYPE
     ecran_memory = TextScreen;

     ss_string = StandartString; { стандартная строка }


{-------------------------------------------------------------------------}

PROCEDURE set_color_symbol ( sym : BYTE );
PROCEDURE set_color_fon ( fon : BYTE );
PROCEDURE w_display ( x, y : BYTE; fon, sym : BYTE; ch : CHAR );
PROCEDURE t_display ( x,y : BYTE; ch : CHAR );
PROCEDURE save_ecran;
PROCEDURE restore_ecran;
PROCEDURE d_ecran;
PROCEDURE copy_ecran_to_window;
PROCEDURE work_number ( number : BYTE );
PROCEDURE n_window ( kx1, ky1, kx2, ky2 : BYTE; col_fon,col_sym : BYTE );
PROCEDURE wn_window ( kx1, ky1, kx2, ky2 : BYTE; col_fon,col_sym : BYTE;
                      number_window : BYTE );
PROCEDURE w_char ( x,y : BYTE; ch : CHAR );
PROCEDURE xy_char ( x,y : BYTE; ch : CHAR );
PROCEDURE w_xy_char ( x,y : BYTE; ch : CHAR );
PROCEDURE w_print ( x, y : BYTE; stroka : ss_string );
PROCEDURE xy_print ( x, y : BYTE; stroka : ss_string );
PROCEDURE w_xy_print ( x, y : BYTE; stroka : ss_string );
PROCEDURE ld_char ( x, y : BYTE; VAR ch : CHAR; VAR at : BYTE );
PROCEDURE xy_edit ( x, y : BYTE; VAR ch : CHAR; ln : BYTE;
                    VAR stroka : ss_string );
PROCEDURE d_window;
PROCEDURE p_window ( number : BYTE );
PROCEDURE tp_window;
PROCEDURE c_window;
PROCEDURE f_window ( VAR fl : TEXT; rem_cod, stop_cod : CHAR;
                     VAR kkey : BOOLEAN );
PROCEDURE conout ( x, y, key : BYTE; ch : CHAR );
PROCEDURE line_y ( x, y1, y2,pointer, key : BYTE; ch : CHAR );
PROCEDURE line_x ( y, x1, x2,pointer, key : BYTE; ch : CHAR );
PROCEDURE r1_window ( kx1, ky1, kx2, ky2, key : BYTE; ch : CHAR );
PROCEDURE rn_window ( ch : CHAR );
PROCEDURE rd_window ( ch : CHAR );
PROCEDURE sirena;
PROCEDURE warning ( x, y : BYTE; stroka : ss_string );
PROCEDURE show_cursor;
PROCEDURE tp_old_screen;
PROCEDURE pd_window;
PROCEDURE m_window ( x, y : BYTE );
PROCEDURE show_t ( fon, sym : BYTE );
PROCEDURE epson ( ch : CHAR; VAR key : BOOLEAN );
PROCEDURE cursor ( x,y : BYTE );
PROCEDURE SetInsEdit;
PROCEDURE ReSetInsEdit;
PROCEDURE HideCursor;
PROCEDURE DoneAllWindows;
PROCEDURE SetClearEdit;
PROCEDURE SetColorEdit ( fon, sym : BYTE );
PROCEDURE SetColorClearEdit ( fon, sym : BYTE );
PROCEDURE ReSetColorEdit;
PROCEDURE List ( Stroka : STRING; VAR key : BOOLEAN );
PROCEDURE ListLn ( Stroka : STRING; VAR key : BOOLEAN );
PROCEDURE SetTypeEdit ( tp : BYTE );
PROCEDURE ReadData ( x, y : BYTE; VAR Stroka : StandartString );
FUNCTION RushLardg ( ch : CHAR ) : CHAR;
FUNCTION RushAll ( ch : CHAR ) : CHAR;
PROCEDURE ForTextHelp ( x1, y1, x2, y2, fon, sym : BYTE );
PROCEDURE SetBackGround16;
PROCEDURE SetBackGround8;
FUNCTION GetCurrentWorkNumber : BYTE;

{-------------------------------------------------------------------------}

IMPLEMENTATION

TYPE
     location = ARRAY [ 1..80*25 ] OF RECORD
                                            ch : CHAR;
                                            at : BYTE
                                      END;

     point_ecran = ^ecr;
                    { ссылка на образ экрана }

     ecr = RECORD    { образ экрана }
                 x, y : BYTE;
                         { координаты курсора }
                 from : ecran_memory;
                         { сохраненный экран }
                 pointer : point_ecran;
                         { ссылка на последующий экран }
                 pred : point_ecran
                         { ссылка на предшествующий экран }
           END;

     point_window = ^data_window;
                    { ссылка на образ окна }

     data_window = RECORD    { образ окна }
                     color_fon : BYTE;   { цвет фона окна }
                     color_sym : BYTE;   { цвет символов в окне }
                     x1,y1,x2,y2 : BYTE; { координаты окна }
                     old_pic : ^location; { старый экран }
                     pic : ^location;    { текстовый образ окна }
                     pointer : point_window; { ссылка на сдедующее впереди }
                                             { по цепочке окно }
                     pred : point_window;  { ссылка на предшествующее }
                                           { по цепочке окно }
                     sx, sy : BYTE; { размер окна по осям }
                     st : BOOLEAN; { признак тени }
                     fon_t, sym_t, at_t : BYTE;

                   END;

{-------------------------------------------------------------------------}

VAR
     www_beg : ARRAY [ 1..wwmax ] OF point_window;
               { ссылки на первичные образы независимых }
               {            экранных окон               }

     www_seg : ARRAY [ 1..wwmax ] OF point_window;
               { ссылки на текущие образы независимых   }
               {            экранных окон               }

     ww_num : BYTE; { номер текущего независимого окна }

     w_insert : BOOLEAN;

     { w_ecran : ^ecran_memory  ABSOLUTE screen_memory; }
                        { экранная память в текстовом режиме }

     s_ecran : point_ecran; { ссылка на первый сохраненный экран }

     www_fon : BYTE; { текущий фон }

     www_sym : BYTE; { текущий цвет символа }

     www_atr : BYTE; { текущий атрибут }

     w_cursor : BOOLEAN; { Признак гашения курсора }

     rg : Registers;

     old_screen : BOOLEAN;

     ClearEdit : BOOLEAN; { Признак удаления информации при редактировании }

     SingColorEdit : BOOLEAN; { признак установки цвета редактирования }

     ColorEditFon : BYTE;     { цвет фона редактирования }

     ColorEditSymbol : BYTE;    { цвет символов редактирования }

     ColorEditClearFon : BYTE;    { цвет фона возможного удаления }

     ColorEditClearSymbol : BYTE;   { цвет символов возможного удаления }

     TypeEdit : BYTE;  { возможный тип редактирования : }
                       { 0 - строка                     }
                       { 1 - простое число              }
                       { 2 - вещественное число         }

{-------------------------------------------------------------------------}

          { Процедуры и функции обьявленные в программе }
          {      WIN.ASM низкоуровневого оконного       }
          {        интерфейса Turbo Pascal 6.0          }

{$L WIN}

procedure WriteStr(X, Y: Byte; S: String; Attr: Byte);
external {WIN};

procedure WriteChar(X, Y, Count: Byte; Ch: Char; Attr: Byte);
external {WIN};

procedure FillWin(Ch: Char; Attr: Byte);
external {WIN};

procedure WriteWin(var Buf);
external {WIN};

procedure ReadWin(var Buf);
external {WIN};

function WinSize: Word;
external {WIN};

{-------------------------------------------------------------------------}

FUNCTION GetCurrentWorkNumber : BYTE;

BEGIN
     GetCurrentWorkNumber := ww_num;

END; { function GetCurrentWorkNumber }

{-------------------------------------------------------------------------}

PROCEDURE set_pic ( x,y : BYTE; ch : CHAR; at : BYTE );

VAR
   indx : INTEGER;

BEGIN
     IF ( www_seg [ ww_num ] = NIL ) THEN
        EXIT;
     WITH www_seg [ ww_num ]^ DO
          BEGIN
               indx := ( y - 1 ) * sx + x;
               pic^[ indx ].ch := ch;
               pic^[ indx ].at := at
          END

END; { procedure set_pic }

{-------------------------------------------------------------------------}

PROCEDURE get_pic ( x,y : BYTE; VAR ch : CHAR; VAR at : BYTE );

VAR
   indx : INTEGER;

BEGIN
     WITH www_seg [ ww_num ]^ DO
          BEGIN
               indx := ( y - 1 ) * sx + x;
               ch := pic^[ indx ].ch;
               at := pic^[ indx ].at
          END

END; { procedure get_pic }

{-------------------------------------------------------------------------}

PROCEDURE set_old_pic ( x,y : BYTE; ch : CHAR; at : BYTE );

VAR
   indx : INTEGER;

BEGIN
     IF ( www_seg [ ww_num ] = NIL ) THEN
        EXIT;
     WITH www_seg [ ww_num ]^ DO
          BEGIN
               indx := ( y - 1 ) * sx + x;
               old_pic^[ indx ].ch := ch;
               old_pic^[ indx ].at := at
          END

END; { procedure set_old_pic }

{-------------------------------------------------------------------------}

PROCEDURE get_old_pic ( x,y : BYTE; VAR ch : CHAR; VAR at : BYTE );

VAR
   indx : INTEGER;

BEGIN
     WITH www_seg [ ww_num ]^ DO
          BEGIN
               indx := ( y - 1 ) * sx + x;
               ch := old_pic^[ indx ].ch;
               at := old_pic^[ indx ].at
          END

END; { procedure get_old_pic }

{-------------------------------------------------------------------------}

PROCEDURE show_cursor;

          { Процедура делает курсор видимым до следующего }
          {          обращения к work_number              }

BEGIN
     w_cursor := NOT ( w_cursor )

END; { procedure show_cursor }

{-------------------------------------------------------------------------}

PROCEDURE HideCursor;

         {  гашение курсора }

BEGIN
      w_cursor := TRUE;
      rg.AH := 02;
      rg.BH := 0;
      rg.DH := 25;
      rg.DL := 0;
      INTR ( $10, rg )

END; { procedure HideCursor }

{-------------------------------------------------------------------------}

PROCEDURE SetBackGround16;

BEGIN
     rg.AH := $10;
     rg.AL := 03;
     rg.BL := 0;
     INTR ( $10, rg )

END; { procedure SetBackGround16 }

{-------------------------------------------------------------------------}

PROCEDURE SetBackGround8;

BEGIN
     rg.AH := $10;
     rg.AL := 03;
     rg.BL := 1;
     INTR ( $10, rg )

END; { procedure SetBackGround8 }

{-------------------------------------------------------------------------}

PROCEDURE set_color_symbol ( sym : BYTE );

          { процедура установки текущего цвета символов }
BEGIN
     www_sym := sym;
     www_atr := www_fon * 16 + sym

END; { procedure set_color_symbol }

{-------------------------------------------------------------------------}
PROCEDURE set_color_fon ( fon : BYTE );

         { процедура установки текущего цвета фона }
BEGIN
     www_fon := fon;
     www_atr := fon * 16 + www_sym

END; { procedure set_color_fon }

{-------------------------------------------------------------------------}

PROCEDURE w_display ( x, y : BYTE;
                           { абсолютные координаты символа }
                      fon, sym : BYTE;
                           { цвета фона и символа }
                      ch : CHAR
                           { выводимый символ } );

           { Процедура скоростного вывода символа на }
           {     экран терминала по абсолютным       }
           {    координатам, с заданным цветом       }

BEGIN
     WINDOW ( 1, 1, 80, 25 );
     WriteChar ( X, Y, 1, Ch, ( fon*16 + sym ) );
     IF ( NOT w_cursor ) THEN
        BEGIN
             rg.AH := 02;
             rg.BH := 0;
             rg.DH := y - 1;
             rg.DL := x;
             INTR ( $10, rg )
        END;
     Work_Number ( 0 )

END; { procedure w_display }


{-------------------------------------------------------------------------}

PROCEDURE t_display ( x,y : BYTE; ch : CHAR );

           { Процедура скоростного вывода символа на }
           {     экран терминала по абсолютным       }
           {            координатам                  }

BEGIN
     WINDOW ( 1, 1, 80, 25 );
     WriteChar ( X, Y, 1, Ch, www_atr );
     IF ( NOT w_cursor ) THEN
        BEGIN
             rg.AH := 02;
             rg.BH := 0;
             rg.DH := y - 1;
             rg.DL := x;
             INTR ( $10, rg )
        END;
     Work_Number ( 0 )


END; { procedure t_display }

{-------------------------------------------------------------------------}

PROCEDURE cursor ( x, y : BYTE );

BEGIN
     IF ( w_cursor ) THEN
        EXIT;
     GOTOXY ( x, y )

END; { procedure cursor }
{-------------------------------------------------------------------------}

PROCEDURE save_ecran;

               { Процедура сохранения текущего экрана }

VAR
   help : point_ecran; { вспомогательная ссылка }

BEGIN
     WINDOW ( 1, 1, 80, 25 );
     IF ( s_ecran = NIL ) THEN
        BEGIN
             NEW ( s_ecran );
             WITH s_ecran^ DO
                 BEGIN
                      pred := NIL;
                      pointer := NIL;
                      ReadWin ( from );
                      x := WHEREX;
                      y := WHEREY
                 END
        END
     ELSE
         BEGIN
              NEW ( s_ecran^.pointer );
              help := s_ecran;
              s_ecran := s_ecran^.pointer;
              WITH s_ecran^ DO
                   BEGIN
                        pred := help;
                        pointer := NIL;
                        ReadWin ( from );
                        x := WHEREX;
                        y := WHEREY
                   END
         END;
     Work_Number ( 0 )

END; { procedure save_ecran }

{-------------------------------------------------------------------------}

PROCEDURE restore_ecran;

             { Процедура восстановления последнего }
             {        сохраненного экрана          }

BEGIN
     IF ( s_ecran = NIL ) THEN
        EXIT;
     WINDOW ( 1, 1, 80, 25 );
     WriteWin ( s_ecran^.from );
     GOTOXY ( s_ecran^.x, s_ecran^.y );
     IF ( s_ecran^.pred = NIL ) THEN
        BEGIN
             DISPOSE ( s_ecran );
             s_ecran := NIL
        END
     ELSE
         BEGIN
              s_ecran := s_ecran^.pred;
              DISPOSE ( s_ecran^.pointer );
              s_ecran^.pointer := NIL
         END;
     Work_Number ( 0 )

END; { procedure restore_ecran }

{-------------------------------------------------------------------------}

PROCEDURE d_ecran;

             { Процедура удаления последнего }
             {     сохраненного экрана       }

BEGIN
     IF ( s_ecran = NIL ) THEN
        EXIT;
     IF ( s_ecran^.pred = NIL ) THEN
        BEGIN
             DISPOSE ( s_ecran );
             s_ecran := NIL
        END
     ELSE
         BEGIN
              s_ecran := s_ecran^.pred;
              DISPOSE ( s_ecran^.pointer );
              s_ecran^.pointer := NIL
         END

END; { procedure d_ecran }

{-------------------------------------------------------------------------}

PROCEDURE copy_ecran_to_window;

              { Процедура копирования последнего }
              { сохраненного экрана в текущее    }
              {             окно                 }

VAR
   indx_x, indx_y : INTEGER;
           { индексные переменные }

BEGIN
     IF ( ( www_seg [ ww_num ] = NIL ) OR ( s_ecran = NIL ) ) THEN
        EXIT;
     WITH www_seg [ ww_num ]^ , s_ecran^ DO
          FOR indx_x := 1 TO sx DO
              FOR indx_y := 1 TO sy DO
                  set_pic ( indx_x, indx_y, from [ ( y1 + indx_y - 1 ),
                            ( x1 + indx_x - 1 ) ].ch,
                            from [ ( y1 + indx_y - 1 ),
                            ( x1 + indx_x - 1 ) ]. at )

END; { procedure copy_ecran_to_window }

{-------------------------------------------------------------------------}

PROCEDURE copy_ecran_to_old_screen;

VAR
   indx_x, indx_y : INTEGER;

BEGIN
     save_ecran;
     WITH www_seg [ ww_num ]^, s_ecran^ DO
          FOR indx_x := 1 TO sx DO
              FOR indx_y := 1 TO sy DO
                  set_old_pic ( indx_x, indx_y, from [ ( y1 +
                                indx_y - 1 ), ( x1 + indx_x - 1 )].ch,
                                from [ ( y1 + indx_y - 1 ), ( x1 +
                                indx_x - 1 ) ].at );
     d_ecran

END; { procedure copy_ecran_to_old_screen }

{-------------------------------------------------------------------------}

PROCEDURE w_init;
         { процедура инициадизации пакета }

VAR
   indx : INTEGER; { ндексная переменная }

BEGIN

    FOR indx := 1 TO wwmax DO
      BEGIN
          www_beg [ indx ] := NIL;
          www_seg [ indx ] := NIL
      END;
    ww_num := 1;  { первое рабочее окно по умолчанию }
    w_insert := TRUE;
    s_ecran := NIL;
    w_cursor := TRUE;
    www_fon := BLACK;
    www_sym := WHITE;
    www_atr := BLACK * 16 + WHITE;
    old_screen := FALSE;
    ClearEdit := FALSE;
    SingColorEdit := FALSE;
    TypeEdit := 0

END; { procedure w_init }

{-------------------------------------------------------------------------}

PROCEDURE work_number ( number : BYTE );
         { установка рабочего номера независимого окна }

BEGIN
    IF ( number <> 0 ) THEN
       ww_num := number;
    old_screen := FALSE;

       { установка параметров окна на экране }

    IF ( www_seg [ ww_num ] <> NIL ) THEN
       WITH www_seg [ ww_num ]^ DO
          BEGIN
              WINDOW ( x1, y1, x2, y2 );
              IF ( w_cursor ) THEN
                 BEGIN
                      rg.AH := 02;
                      rg.BH := 0;
                      rg.DH := 25;
                      rg.DL := 0;
                      INTR ( $10, rg )
                 END;
              set_color_fon ( color_fon );
              set_color_symbol ( color_sym )
          END

END; { procedure work_number }

{-------------------------------------------------------------------------}
PROCEDURE n_window ( kx1, ky1, kx2, ky2 : BYTE;
                          { абсолютные координаты вновь }
                          {      образуемого окна       }
                     col_fon : BYTE;
                          { цвет фона окна }
                     col_sym : BYTE
                          { цвет символов в окне }      );

           { процедура инициализирует следующее по цепочке }
           { независимое окно с заданным номером, цветами  }
           {               и координатами                  }

VAR
   indx_x, indx_y : BYTE;
           { индексные переменные координат }
   help : point_window;
           { формирователь ссылки на предшествующее окно }

BEGIN
     IF ( ( kx1 < 1 ) OR ( kx1 > 80 ) OR ( ky1 < 1 ) OR ( ky1 > 25 ) ) THEN
        EXIT;
     IF ( ( kx2 < kx1 ) OR ( kx2 > 80 ) OR ( ky2 < ky1 ) OR ( ky2 > 25 ) )
        THEN  EXIT;

    IF ( www_beg [ ww_num ] = NIL ) THEN
       BEGIN
           NEW ( www_beg [ ww_num ] );
           www_seg [ ww_num ] := www_beg [ ww_num ];
           www_seg [ ww_num ]^.pred := NIL
       END
    ELSE
       BEGIN
           help := www_seg [ ww_num ];
           NEW ( www_seg [ ww_num ]^.pointer );
           www_seg [ ww_num ] := www_seg [ ww_num ]^.pointer;
           www_seg [ ww_num ]^.pred := help
       END;

          { инициализация нового образа }

    WITH www_seg [ ww_num ]^ DO
       BEGIN
           pointer := NIL;
           x1 := kx1;
           y1 := ky1;
           x2 := kx2;
           y2 := ky2;
           WINDOW ( x1, y1, x2, y2 );
           sx := x2 - x1 + 1;
           sy := y2 - y1 + 1;
           GETMEM ( pic, ( 2 * sx * sy ) );
           GETMEM ( old_pic, ( 2 * sx * sy ) );
           color_fon := col_fon;
           color_sym := col_sym;
           st := FALSE;
           fon_t := BLACK;
           sym_t := WHITE;
           at_t := fon_t * 16 + sym_t;
           set_color_fon ( color_fon );
           set_color_symbol ( color_sym );
           FOR indx_x := 1 TO sx DO
             FOR indx_y := 1 TO sy DO
                 set_pic ( indx_x, indx_y, ' ', www_atr )
       END;
    work_number ( ww_num );
    Set_Color_Symbol ( col_sym );
    Set_Color_Fon ( col_fon );
    copy_ecran_to_old_screen

END; { procedure n_window }

{-------------------------------------------------------------------------}

PROCEDURE wn_window ( kx1, ky1, kx2, ky2 : BYTE; col_fon,col_sym : BYTE;
                      number_window : BYTE );

BEGIN
     IF ( www_seg [ number_window ] = NIL ) THEN
        EXIT;
     WITH www_seg [ number_window ] ^ DO
          n_window ( ( kx1 + x1 - 1 ), ( ky1 + y1 - 1 ),
                     ( kx2 + x1 - 1 ), ( ky2 + y1 - 1 ),
                     col_fon, col_sym )

END; { procedure wn_window }

{-------------------------------------------------------------------------}

PROCEDURE w_char ( x,y : BYTE; { координаты символа в окне }
                   ch : CHAR { выводимый символ }              );

           { процедура помещения символа в образ окна }
           { без отображения на экране, по заданным    }
           {              координатам                  }

BEGIN
     set_pic ( x, y, ch, www_atr )

END; { procedure w_char }

{-------------------------------------------------------------------------}

PROCEDURE xy_char ( x,y : BYTE; { координаты символа в окне }
                   ch : CHAR { выводимый символ }              );

           { процедура вывода символа в текущее окно на    }
           {     экран, по заданным координатам            }

BEGIN
      WITH www_seg [ ww_num ]^ DO
            WriteChar ( X, Y, 1, Ch, www_atr )

END; { procedure xy_char }

{-------------------------------------------------------------------------}

PROCEDURE w_xy_char ( x,y : BYTE; { координаты символа в окне }
                      ch : CHAR { выводимый символ }              );

           { процедура вывода символа в образ текущго окна }
           {     и на экран, по заданным координатам       }

BEGIN
    set_pic ( x, y, ch, www_atr );
    WITH www_seg [ ww_num ]^ DO
         WriteChar ( X, Y, 1, Ch, www_atr );

END; { procedure w_xy_char }

{-------------------------------------------------------------------------}

{$V-}

PROCEDURE w_print ( x, y : BYTE; { координаты строки в окне }
                    stroka : ss_string { выводимая строка }      );

          { процедура вывода строки в образ окна, }
          { без отображения на экране, по         }
          {       заданным координатам            }

VAR
   indx : INTEGER; { индексная переменная }
   u : INTEGER; { вспомогательная переменная }

BEGIN

     u := LENGTH ( stroka );
     WHILE ( u > ( www_seg [ ww_num ]^.sx - x + 1 ) ) DO
         DEC ( u );
     FOR indx := 1 TO u DO
         w_char ( x + indx - 1, y, stroka [ indx ] )

END; { procedure w_print }

{$V+}

{-------------------------------------------------------------------------}

{$V-}

PROCEDURE xy_print ( x, y : BYTE; { координаты строки в окне }
                    stroka : ss_string { выводимая строка }      );

          { процедура вывода строки на экран по }
          { заданным координатам в текущем окне }

VAR
   indx : INTEGER; { индексная переменная }
   u : INTEGER; { вспомогательная переменная }

BEGIN

     u := LENGTH ( stroka );
     WHILE ( u > ( www_seg [ ww_num ]^.sx - x + 1 ) ) DO
         DEC ( u );
     WriteStr ( X, Y, Stroka, www_atr )

END; { procedure xy_print }

{$V+}

{-------------------------------------------------------------------------}

{$V-}

PROCEDURE w_xy_print ( x, y : BYTE; { координаты строки в окне }
                       stroka : ss_string { выводимая строка }      );

          { процедура вывода строки на экран и в }
          { образ окна, по заданным координатам  }

VAR
   indx : INTEGER; { индексная переменная }
   u : INTEGER; { вспомогательная переменная }

BEGIN

     u := LENGTH ( stroka );
     WHILE ( u > ( www_seg [ ww_num ]^.sx - x + 1 ) ) DO
         DEC ( u );
     WriteStr ( X, Y, Stroka, www_atr );
     FOR indx := 1 TO u DO
         w_char ( x + indx - 1, y, stroka [ indx ] )

END; { procedure w_xy_print }

{$V+}

{-------------------------------------------------------------------------}

PROCEDURE ld_char ( x, y : BYTE;
                    VAR ch : CHAR;
                    VAR at : BYTE );

         { процедура получения символа из образа окна }
         {          по заданным координатам           }

BEGIN
    get_pic ( x, y, ch, at )

END; { procedure ld_char }

{-------------------------------------------------------------------------}

FUNCTION RushLardg ( ch : CHAR ) : CHAR;

         { функция возвращает только русские большие буквы }
         {     независимо от регистра нажатой клавиши      }

BEGIN
     CASE ch OF
        ' '             : RushLardg  :=    ' ';
        'q','Q','й','Й' : RushLardg  :=    'Й';
        'w','W','ц','Ц' : RushLardg  :=    'Ц';
        'e','E','у','У' : RushLardg  :=    'У';
        'r','R','к','К' : RushLardg  :=    'К';
        't','T','е','Е' : RushLardg  :=    'Е';
        'y','Y','н','Н' : RushLardg  :=    'Н';
        'u','U','г','Г' : RushLardg  :=    'Г';
        'i','I','ш','Ш' : RushLardg  :=    'Ш';
        'o','O','щ','Щ' : RushLardg  :=    'Щ';
        'p','P','з','З' : RushLardg  :=    'З';
        '[','{','х','Х' : RushLardg  :=    'Х';
        'a','A','ф','Ф' : RushLardg  :=    'Ф';
        's','S','ы','Ы' : RushLardg  :=    'Ы';
        'd','D','в','В' : RushLardg  :=    'В';
        'f','F','а','А' : RushLardg  :=    'А';
        'g','G','п','П' : RushLardg  :=    'П';
        'h','H','р','Р' : RushLardg  :=    'Р';
        'j','J','о','О' : RushLardg  :=    'О';
        'k','K','л','Л' : RushLardg  :=    'Л';
        'l','L','д','Д' : RushLardg  :=    'Д';
        ';',':','ж','Ж' : RushLardg  :=    'Ж';
        '''','"','э','Э': RushLardg  :=    'Э';
        'z','Z','я','Я' : RushLardg  :=    'Я';
        'x','X','ч','Ч' : RushLardg  :=    'Ч';
        'c','C','с','С' : RushLardg  :=    'С';
        'v','V','м','М' : RushLardg  :=    'М';
        'b','B','и','И' : RushLardg  :=    'И';
        'n','N','т','Т' : RushLardg  :=    'Т';
        'm','M','ь','Ь' : RushLardg  :=    'Ь';
        ',','<','б','Б' : RushLardg  :=    'Б';
        '.','>','ю','Ю' : RushLardg  :=    'Ю'
     ELSE
         RushLardg := CHR ( 0 )
     END

END; { function RushLardg }

{--------------------------------------------------------------------}

FUNCTION RushAll ( ch : CHAR ) : CHAR;

         { преобразует латинские символы в русские }
         { независмо от включенного на клавиатуре  }
         {                регистра                 }

BEGIN
     CASE ch OF
        ' '     : RushAll :=   ' ';
        'Q','Й' : RushAll :=   'Й';
        'W','Ц' : RushAll :=   'Ц';
        'E','У' : RushAll :=   'У';
        'R','К' : RushAll :=   'К';
        'T','Е' : RushAll :=   'Е';
        'Y','Н' : RushAll :=   'Н';
        'U','Г' : RushAll :=   'Г';
        'I','Ш' : RushAll :=   'Ш';
        'O','Щ' : RushAll :=   'Щ';
        'P','З' : RushAll :=   'З';
        '{','Х' : RushAll :=   'Х';
        'A','Ф' : RushAll :=   'Ф';
        'S','Ы' : RushAll :=   'Ы';
        'D','В' : RushAll :=   'В';
        'F','А' : RushAll :=   'А';
        'G','П' : RushAll :=   'П';
        'H','Р' : RushAll :=   'Р';
        'J','О' : RushAll :=   'О';
        'K','Л' : RushAll :=   'Л';
        'L','Д' : RushAll :=   'Д';
        ':','Ж' : RushAll :=   'Ж';
        '"','Э' : RushAll :=   'Э';
        'Z','Я' : RushAll :=   'Я';
        'X','Ч' : RushAll :=   'Ч';
        'C','С' : RushAll :=   'С';
        'V','М' : RushAll :=   'М';
        'B','И' : RushAll :=   'И';
        'N','Т' : RushAll :=   'Т';
        'M','Ь' : RushAll :=   'Ь';
        '<','Б' : RushAll :=   'Б';
        '>','Ю' : RushAll :=   'Ю';
        'q','й' : RushAll :=   'й';
        'w','ц' : RushAll :=   'ц';
        'e','у' : RushAll :=   'у';
        'r','к' : RushAll :=   'к';
        't','е' : RushAll :=   'е';
        'y','н' : RushAll :=   'н';
        'u','г' : RushAll :=   'г';
        'i','ш' : RushAll :=   'ш';
        'o','щ' : RushAll :=   'щ';
        'p','з' : RushAll :=   'з';
        '[','х' : RushAll :=   'х';
        'a','ф' : RushAll :=   'ф';
        's','ы' : RushAll :=   'ы';
        'd','в' : RushAll :=   'в';
        'f','а' : RushAll :=   'а';
        'g','п' : RushAll :=   'п';
        'h','р' : RushAll :=   'р';
        'j','о' : RushAll :=   'о';
        'k','л' : RushAll :=   'л';
        'l','д' : RushAll :=   'д';
        ';','ж' : RushAll :=   'ж';
        '''','э': RushAll :=   'э';
        'z','я' : RushAll :=   'я';
        'x','ч' : RushAll :=   'ч';
        'c','с' : RushAll :=   'с';
        'v','м' : RushAll :=   'м';
        'b','и' : RushAll :=   'и';
        'n','т' : RushAll :=   'т';
        'm','ь' : RushAll :=   'ь';
        ',','б' : RushAll :=   'б';
        '.','ю' : RushAll :=   'ю'
     ELSE
         IF ( ch IN [ '1','2','3','4','5','6','7','8','9','0','-','=',
                      '\','!','@','#','$','%','^','&','*','(',')','_',
                      '+','|' ] ) THEN
            RushAll := ch
         ELSE
             RushAll := CHR ( 0 )
     END

END; { function RushAll }

{--------------------------------------------------------------------}

{$V-}
PROCEDURE xy_edit ( x, y : BYTE; VAR ch : CHAR;
                    ln : BYTE; VAR stroka : ss_string );

          { экранное редактирование символьной строки }
          { в текущем окне, по заданным координатам   }

CONST

    cr = $0D; { выход из редактора }
    lf = $0A;
    esc = 27;
    ctlf = 06;
    ctla = 01;

    del =  08; { удаление предыдущего слова }
    ctlg = 07; { удаление текущего символа }
    ddel = 83;
    ctld = 04; right = 77; { на символ вперед }
    ctlh = 19; ctls = 19; left = 75; { на символ назад }
    ins = 82; invs = 01;

VAR
   kx : BYTE; { текущий символ }
   cm : CHAR;    { командная переменная }
   u : INTEGER; { вспомогательная переменная }
   key_edit : BOOLEAN; { ключ редактирования }
   help : SS_String;

PROCEDURE quit;

BEGIN
     work_number ( 0 );
     xy_print ( x, y, help );
     xy_print ( x, y, stroka );
     WHILE ( ( LENGTH ( stroka ) <> 0 ) AND
           ( stroka [ LENGTH ( stroka ) ] = ' ' ) ) DO
           DELETE ( stroka, LENGTH ( stroka ), 1 )

END; { procedure quit }

PROCEDURE SetSymbol;

BEGIN
     IF ( ClearEdit ) THEN
        BEGIN
             stroka := '';
             kx := 1
        END;
     IF ( w_insert ) THEN
        BEGIN
             IF ( kx > LENGTH ( Stroka ) ) THEN
                BEGIN
                     Stroka := Stroka + Ch;
                     IF ( kx < ln ) THEN
                        INC ( kx )
                END
             ELSE
                 BEGIN
                      IF ( LENGTH ( stroka ) = ln ) THEN
                         BEGIN
                              DELETE ( stroka, LENGTH ( stroka ), 1 )
                         END;
                      INSERT ( ch, stroka, kx );
                      INC ( kx )
                 END
        END
     ELSE
         BEGIN
              IF ( kx > LENGTH ( stroka ) ) THEN
                  stroka := CONCAT ( stroka, ch )
              ELSE
                  stroka [ kx ] := ch;
              IF ( kx < ln ) THEN
                 INC ( kx )
         END

END; { procedure SetSymbol }


BEGIN

    kx := 1;
    help := '';
    FOR u := 1 TO ln DO
        help := help + ' ';

    WHILE TRUE DO   { цикл редактирования }

        BEGIN
          IF ( SingColorEdit ) THEN
             BEGIN
                  IF ( ClearEdit ) THEN
                     BEGIN
                          Set_Color_Fon ( ColorEditClearFon );
                          Set_Color_Symbol ( ColorEditClearSymbol )
                     END
                  ELSE
                      BEGIN
                           Set_Color_Fon ( ColorEditFon );
                           Set_Color_Symbol ( ColorEditSymbol )
                      END;
                  xy_print ( x, y, help );
            END;
            WHILE ( LENGTH ( stroka ) > ln ) DO
                  DELETE ( stroka, LENGTH ( stroka ), 1 );
            IF ( kx > ln ) THEN
               kx := LENGTH ( stroka );
            xy_print ( x, y, stroka );
            u := LENGTH ( stroka );
            WHILE ( u <> ln ) DO
                 BEGIN
                     xy_print ( ( x + u ), y, ' ' );
                     INC ( u )
                 END;
            GOTOXY ( ( x + kx - 1 ), y );

            ch := GetKey;                 { ввод команды }
            IF ( SingKey ) THEN
               BEGIN
                    cm := GetKey;
                    CASE  ORD ( cm )  OF
                          left: ch := CHR ( ctls );
                          right:ch := CHR ( ctld );
                          ddel :ch := CHR ( ctlg );
                          ins  :ch := CHR ( invs )
                    ELSE
                        BEGIN
                             ch := cm;
                             quit;
                             EXIT
                        END
                    END
               END;
            CASE ORD ( ch ) OF

                     cr   : BEGIN
                                 quit;
                                 EXIT
                            END;

                     lf   : BEGIN
                                 quit;
                                 EXIT
                            END;

                     esc  : BEGIN
                                 quit;
                                 EXIT
                            END;

                     invs : w_insert := NOT ( w_insert );

                     del  : IF ( kx > 1 ) THEN
                               BEGIN
                                    DEC ( kx );
                                    DELETE ( stroka, kx, 1 )
                               END
                            ELSE
                                IF ( ( kx = 1 ) AND
                                     ( LENGTH ( stroka ) <> 0 ) ) THEN
                                   DELETE ( stroka, 1, 1 );

                     ctlg : IF ( ( LENGTH ( stroka ) <> 0 ) AND
                                 ( kx <= LENGTH ( stroka ) ) ) THEN
                               DELETE ( stroka, kx, 1 );

                     ctld : IF ( kx < LENGTH ( stroka ) ) THEN
                               INC ( kx )
                            ELSE
                                IF ( ln > LENGTH ( stroka ) ) THEN
                                   kx := LENGTH ( stroka ) + 1;

                     ctls : IF ( kx <> 1 ) THEN
                                DEC ( kx )
                            ELSE
                                BEGIN
                                     ch := CHR ( 75 );
                                     quit;
                                     EXIT
                                END;

                     ctla : kx := 1;

                     ctlf : kx := LENGTH ( stroka )
            ELSE
                CASE TypeEdit OF

                        0  :  SetSymbol;

                        1  :  IF ( ch IN [ '1','2','3','4','5','6',
                                           '7','8','9','0' ] ) THEN
                                 SetSymbol;

                        2  :  IF ( ch IN [ '1','2','3','4','5','6','-','+',
                                           '7','8','9','0','.','E','e'] ) THEN
                                 SetSymbol;

                        3  :  IF ( ch IN [ '1','2','3','4','5','6','-','+',
                                           '7','8','9','0' ] ) THEN
                                 SetSymbol;

                        4  :  BEGIN
                                   ch := RushLardg ( ch );
                                   IF ( ch <> CHR ( 0 ) ) THEN
                                      SetSymbol
                              END;

                        5  :  BEGIN
                                   ch := RushAll ( ch );
                                   IF ( ch <> CHR ( 0 ) ) THEN
                                      SetSymbol
                              END
                END
            END;
        ClearEdit := FALSE;
        END

END; { procedure xy_edit }
{$V+}

{--------------------------------------------------------------------}

PROCEDURE SetInsEdit;

          { Включить режим вставки для редактора }
BEGIN
     w_insert := TRUE

END; { procedure SetInsEdit }

{--------------------------------------------------------------------}

PROCEDURE ReSetInsEdit;

          { Выключить режим вставки для редактора }
BEGIN
     w_insert := FALSE

END; { procedure ReSetInsEdit }

{--------------------------------------------------------------------}

PROCEDURE SetClearEdit;

          { установить признак стирания информации при редактировании }
BEGIN
     ClearEdit := TRUE

END; { procedure SetClearEdit }

{--------------------------------------------------------------------}

PROCEDURE SetColorEdit ( fon, sym : BYTE );

          { установить цвета редактирования }
BEGIN
     SingColorEdit := TRUE;
     ColorEditFon := fon;
     ColorEditSymbol := sym;
     ColorEditClearFon := fon;
     ColorEditClearSymbol := sym

END; { procedure SetColorEdit }

{---------------------------------------------------------------------}

PROCEDURE SetColorClearEdit ( fon, sym : BYTE );

          { установить цвета возможного стирания для редактирования }
BEGIN
     ColorEditClearFon := fon;
     ColorEditClearSymbol := sym

END; { procedure SetColorClearEdit }

{--------------------------------------------------------------------}

PROCEDURE ReSetColorEdit;

          { сбросить установку цветов для редактирования }
BEGIN
     SingColorEdit := FALSE

END; { procedure ReSetColorEdit }

{--------------------------------------------------------------------}

PROCEDURE List ( Stroka : STRING; VAR key : BOOLEAN );

          { вывод строки на печатающее устройство }
VAR
   index : BYTE;
           { индексная переменная }

BEGIN
     IF ( key ) THEN
        EXIT;
     FOR index := 1 TO LENGTH ( Stroka ) DO
         IF ( NOT key ) THEN
            epson ( Stroka [ index ], key )

END; { procedure List }

{--------------------------------------------------------------------}

PROCEDURE ListLn ( Stroka : STRING; VAR key : BOOLEAN );

          { вывод строки и перевод строки на печать }

BEGIN
     IF ( key ) THEN
        EXIT;
     List ( Stroka, key );
     IF ( key ) THEN
        EXIT;
     epson ( CHR ( $0D ), key );
     IF ( key ) THEN
        EXIT;
     epson ( CHR ( $0A ), key )

END; { procedure ListLn }

{--------------------------------------------------------------------}

PROCEDURE SetTypeEdit ( tp : BYTE );

          {  установить тип редактирования }
          {  0 - строка                    }
          {  1 - простое число             }
          {  2 - вещественное число        }
          {  3 - простое со знаками        }
          {  4 - только русские большие    }
          {  5 - только русский алфавит    }

BEGIN
     IF ( tp IN [ 0, 1, 2, 3, 4, 5 ] ) THEN
        TypeEdit := tp

END; { procedure SetTypeEdit }

{--------------------------------------------------------------------}

PROCEDURE ReadData ( x, y : BYTE; VAR Stroka : StandartString );

           {  Ввод и редактирование даты }
           {      в формате ДДММГГ       }
CONST

    cr = $0D; { выход из редактора }
    lf = $0A;
    esc = 27;
    ctlf = 06;
    ctla = 01;

    del =  08; { удаление предыдущего слова }
    ctlg = 07; { удаление текущего символа }
    ddel = 83;
    ctld = 04; right = 77; { на символ вперед }
    ctlh = 19; ctls = 19; left = 75; { на символ назад }
    ins = 82; invs = 01;

    ln = 6;

VAR
   kx : BYTE; { текущий символ }
   cm : CHAR;    { командная переменная }
   u : INTEGER; { вспомогательная переменная }
   key_edit : BOOLEAN; { ключ редактирования }
   help : SS_String;
   ch : CHAR;
   SingExit : BOOLEAN;
   God, Ms, Day, Week : WORD;
   StrGod, StrMs, StrDay : STRING [ 4 ];

PROCEDURE quit;

VAR
   line : StandartString;
   insp : BYTE;
   err : INTEGER;

BEGIN
     IF ( LENGTH ( Stroka ) <> 6 ) THEN
        BEGIN
             Stroka := '';
             SingExit := FALSE;
             EXIT
        END;
     line := Stroka [ 1 ] + Stroka [ 2 ];
     VAL ( line, insp, err );
     IF ( ( err <> 0 ) OR ( insp < 1 ) OR ( insp > 31 ) ) THEN
        BEGIN
             Stroka := '';
             SingExit := FALSE;
             EXIT
        END;
     line := Stroka [ 3 ] + Stroka [ 4 ];
     VAL ( line, insp, err );
     IF ( ( err <> 0 ) OR ( insp < 1 ) OR ( insp > 12 ) ) THEN
        BEGIN
             Stroka := '';
             SingExit := FALSE;
             EXIT
        END;
     line := Stroka [ 5 ] + Stroka [ 6 ];
     VAL ( line, insp, err );
     IF ( ( err <> 0 ) OR ( insp < 90 ) OR ( insp > 99 ) ) THEN
        BEGIN
             Stroka := '';
             SingExit := FALSE;
             EXIT
        END;

     IF ( SingExit ) THEN
        BEGIN
             work_number ( 0 );
             xy_print ( x, y, help );
             xy_print ( x, y, stroka )
        END

END; { procedure quit }

PROCEDURE SetSymbol;

BEGIN
     IF ( ClearEdit ) THEN
        BEGIN
             stroka := '';
             kx := 1
        END;
     IF ( w_insert ) THEN
        BEGIN
             IF ( kx = ln ) THEN
                BEGIN
                     stroka [ kx ] := ch
                END
             ELSE
                 BEGIN
                      IF ( LENGTH ( stroka ) = ln ) THEN
                         BEGIN
                              DELETE ( stroka, LENGTH ( stroka ), 1 )
                         END;
                      INSERT ( ch, stroka, kx );
                      INC ( kx )
                 END
        END
     ELSE
         BEGIN
              IF ( kx > LENGTH ( stroka ) ) THEN
                  stroka := CONCAT ( stroka, ch )
              ELSE
                  stroka [ kx ] := ch;
              IF ( kx < ln ) THEN
                 INC ( kx )
         END

END; { procedure SetSymbol }

BEGIN

    GetDate ( God, Ms, Day, Week );
    STR ( God, StrGod );
    STR ( Ms, StrMs );
    STR ( Day, StrDay );
    IF ( LENGTH ( StrDay ) = 1 ) THEN
       StrDay := '0' + StrDay;
    IF ( LENGTH ( StrMs ) = 1 ) THEN
       StrMs := '0' + StrMs;
    StrGod := StrGod [ 3 ] + StrGod [ 4 ];
    kx := 1;
    help := 'ДДММГГ';
    w_insert := FALSE;
    stroka := StrDay + StrMs + StrGod;
    ch := #0;
    HideKey;

    WHILE TRUE DO   { цикл редактирования }

        BEGIN
          IF ( SingColorEdit ) THEN
             BEGIN
                  Set_Color_Fon ( ColorEditFon );
                  Set_Color_Symbol ( ColorEditSymbol );
                  xy_print ( x, y, help );
                  work_number ( 0 );
                  Set_Color_Fon ( ColorEditFon )
            END;
            SingExit := TRUE;
            WHILE ( LENGTH ( stroka ) > ln ) DO
                  DELETE ( stroka, LENGTH ( stroka ), 1 );
            IF ( kx > ln ) THEN
               kx := LENGTH ( stroka );
            IF ( LENGTH ( Stroka ) = 0 ) THEN
               kx := 1;
            xy_print ( x, y, stroka );
            u := LENGTH ( stroka );
            GOTOXY ( ( x + kx - 1 ), y );

            ch := GetKey;                 { ввод команды }
            IF ( SingKey ) THEN
               BEGIN
                    cm := GetKey;
                    CASE  ORD ( cm )  OF
                          left: ch := CHR ( ctls );
                          right:ch := CHR ( ctld );
                          ddel :ch := CHR ( ctlg );
                          ins  :ch := CHR ( invs )
                    ELSE
                        BEGIN
                             ch := cm;
                             quit;
                             IF ( SingExit ) THEN
                                EXIT
                        END
                    END
               END;
            CASE ORD ( ch ) OF

                     cr   : BEGIN
                                 quit;
                                 IF ( SingExit ) THEN EXIT
                            END;

                     lf   : BEGIN
                                 quit;
                                 IF ( SingExit ) THEN EXIT
                            END;

                     esc  : BEGIN
                                 quit;
                                 IF ( SingExit ) THEN EXIT
                            END;

                     invs : w_insert := NOT ( w_insert );

                     del  : IF ( kx > 1 ) THEN
                               BEGIN
                                    DEC ( kx );
                                    DELETE ( stroka, kx, 1 )
                               END
                            ELSE
                                IF ( ( kx = 1 ) AND
                                     ( LENGTH ( stroka ) <> 0 ) ) THEN
                                   DELETE ( stroka, 1, 1 );

                     ctlg : IF ( ( LENGTH ( stroka ) <> 0 ) AND
                                 ( kx <= LENGTH ( stroka ) ) ) THEN
                               DELETE ( stroka, kx, 1 );

                     ctld : IF ( kx < LENGTH ( stroka ) ) THEN
                               INC ( kx )
                            ELSE
                                IF ( ln > LENGTH ( stroka ) ) THEN
                                   kx := LENGTH ( stroka ) + 1;

                     ctls : IF ( kx <> 1 ) THEN
                                DEC ( kx )
                            ELSE
                                BEGIN
                                     ch := CHR ( 75 );
                                     quit;
                                     IF ( SingExit ) THEN EXIT
                                END;

                     ctla : kx := 1;

                     ctlf : kx := LENGTH ( stroka )
            ELSE
                IF ( ch IN [ '1','2','3','4','5','6',
                                     '7','8','9','0' ] ) THEN
                   SetSymbol
            END;
        ClearEdit := FALSE;
        END

END; { procedure ReadData }
{$V+}

{--------------------------------------------------------------------}

PROCEDURE d_window;
          { уничтожение образа текущего окна }

VAR
  help : point_window; { вспомогательная ссылка }

BEGIN

    IF ( www_beg [ ww_num ] = www_seg [ ww_num ] ) THEN
      BEGIN
          IF ( www_beg [ ww_num ] <> NIL ) THEN
             BEGIN
                  WITH www_beg [ ww_num ]^ DO
                       BEGIN
                            FREEMEM ( pic, ( 2 * sx * sy ) );
                            FREEMEM ( old_pic, ( 2 * sx * sy ) )
                       END;
                  DISPOSE ( www_beg [ ww_num ] )
             END;
          www_beg [ ww_num ] := NIL;
          www_seg [ ww_num ] := NIL
      END
    ELSE
       BEGIN
           help := www_seg [ ww_num ]^.pred;
           WITH www_seg [ ww_num ]^ DO
                BEGIN
                     FREEMEM ( pic, ( 2 * sx * sy ) );
                     FREEMEM ( old_pic, ( 2 * sx * sy ) )
                END;
           DISPOSE ( www_seg [ ww_num ] );
           www_seg [ ww_num ] := help;
           help^.pointer := NIL
      END;
    work_number ( ww_num )

END; { procedure d_window }

{-------------------------------------------------------------------------}

PROCEDURE DoneAllWindows;

           { уничтожение образов всех окон }
VAR
   index : BYTE;

BEGIN
     FOR index := 1 TO wwmax DO
         WHILE ( www_beg [ index ] <> NIL ) DO
               BEGIN
                    work_number ( index );
                    d_window
               END

END; { procedure DoneAllWindows }

{-------------------------------------------------------------------------}

PROCEDURE p_window ( number : BYTE );
          { процедура отображения на экране терминала }
          { верхнего по цепочке окна с номером number }
          { если number = 0, то выбирается текущее    }
          {            окно                           }

VAR
  x, y : INTEGER;   { текущие координаты }
  Ch : CHAR;
  At : BYTE;

BEGIN

    IF ( number <> 0 ) THEN
       work_number ( number );
    WITH www_seg [ ww_num ]^ DO
       FOR x := x1 TO x2 DO
         FOR y := y1 TO y2 DO
             BEGIN
                  get_pic ( ( x - x1 + 1 ), ( y - y1 + 1 ), Ch, At );
                  WriteChar ( ( x- x1 + 1 ), ( y - y1 + 1 ), 1, Ch, At )
             END

END; { priocedure p_window }

{-------------------------------------------------------------------------}

PROCEDURE tp_window;

          { Мгновенное отображение окна на экране }

VAR
   e : ^ecran_memory;
   x, y : BYTE;

BEGIN
     WINDOW ( 1, 1, 80, 25 );
     NEW ( e );
     ReadWin ( e^ );
     WITH www_seg [ ww_num ]^ DO
          FOR y := y1 TO y2 DO
              FOR x := x1 TO x2 DO
                  get_pic ( ( x - x1 + 1 ), ( y - y1 + 1 ),
                            e^ [ y, x ].ch, e^ [ y, x ].at );
     WriteWin ( e^ );
     DISPOSE ( e );
     Work_Number ( 0 )

END; { procedure tp_window }

{-------------------------------------------------------------------------}

PROCEDURE tp_old_screen;

          { Мгновенное отображение скрытого под окном }
          {         изображения на экран              }

VAR
   e : ^ecran_memory;
   x, y : BYTE;

BEGIN
     WINDOW ( 1, 1, 80, 25 );
     NEW ( e );
     ReadWin ( e^ );
     WITH www_seg [ ww_num ]^ DO
          FOR y := y1 TO y2 DO
              FOR x := x1 TO x2 DO
                  get_old_pic ( ( x - x1 + 1 ), ( y - y1 + 1 ),
                            e^ [ y, x ].ch, e^ [ y, x ].at );
     WriteWin ( e^ );
     DISPOSE ( e );
     Work_Number ( 0 )

END; { procedure tp_old_screen }

{-------------------------------------------------------------------------}

PROCEDURE pd_window;

          { Удаление окна с мгновенным восстановлением }
          {            экранной информации             }

BEGIN
      tp_old_screen;
      d_window

END; { procedure pd_window }

{-------------------------------------------------------------------------}

PROCEDURE m_window ( x, y : BYTE );

          { Процедура перемещения активизированного окна }
          {    по новым координатам. x и y задают новое  }
          {     положение верхнего левого угла окна      }

BEGIN
     WITH www_seg [ ww_num ]^ DO
          IF ( ( x < 1 ) OR ( x > ( 80 - sx ) ) OR ( y < 1 ) OR
               ( y > ( 25 - sy ) ) ) THEN
             EXIT;
     tp_old_screen;
     WITH www_seg [ ww_num ]^ DO
          BEGIN
               x1 := x;
               y1 := y;
               x2 := x1 + sx - 1;
               y2 := y1 + sy - 1;
               WINDOW ( x1, y1, x2, y2 );
               copy_ecran_to_old_screen;
               IF ( st ) THEN
                  show_t ( fon_t, sym_t )
          END;
     tp_window

END; { procedure m_window }

{-------------------------------------------------------------------------}

PROCEDURE show_t ( fon, sym : BYTE );

          { Установить тень в образе окна }
VAR
   x, y : BYTE;
   ch : CHAR;
   at : BYTE;
   ad : BYTE;

BEGIN
     ad := fon * 16 + sym;
     WITH www_seg [ ww_num ]^ DO
          BEGIN
               at_t := ad;
               fon_t := fon;
               sym_t := sym;
               st := TRUE;
               FOR x := 1 TO sx DO
                   BEGIN
                        get_old_pic ( x, sy, ch, at );
                        IF ( x <> 1 ) THEN
                           at := ad;
                        set_pic ( x, sy, ch, at )
                   END;
               FOR y := 1 TO sy DO
                   BEGIN
                        get_old_pic ( sx, y, ch, at );
                        IF ( y <> 1 ) THEN
                           at := ad;
                        set_pic ( sx, y, ch, at )
                   END
          END

END; { procedure show_t }

{-------------------------------------------------------------------------}

PROCEDURE c_window;
          { стирание образа текущего окна }

VAR
  x, y : BYTE; { вспомогательные индексные переменные }

BEGIN
     WITH www_seg [ ww_num ]^ DO
          FOR x := x1 TO x2 DO
              FOR y := y1 TO y2 DO
                  set_pic ( ( x - x1 + 1 ), ( y - y1 + 1 ), ' ', www_atr )

END; { procedure c_window }

{-------------------------------------------------------------------------}

{$V-}
PROCEDURE f_window ( VAR fl : TEXT; { файловая переменная }
                     rem_cod : CHAR; { код комментариев }
                     stop_cod : CHAR;  { стоп код }
                     VAR kkey : BOOLEAN { флаг ошибки } );

         { процедура загрузки образа текущего окна     }
         { из файлллла типа TEXT ( заранее открытого ) }
         { ввод заканчивается по заполнению окна или   }
         { по стоп коду. если строка начинается с кода }
         {    комментариев, то она игнорируется        }

VAR
   x, y : BYTE; { индексная переменная }
   help : ss_string; { вспомогательная переменная }

BEGIN

    c_window;
    y := 1;
    help := ' ';
    kkey := FALSE;
    WITH www_seg [ ww_num ]^ DO
       BEGIN
           WHILE ( ( NOT EOF ( fl ) ) AND ( y <> ( y2 - y1 + 1 ) ) AND
                   ( help [ 1 ] <> stop_cod ) ) DO
                BEGIN
                    {$I-}
                    READLN ( fl, help );
                    {$I+}
                    IF ( IORESULT <> 0 ) THEN
                       BEGIN
                            kkey := TRUE;
                            EXIT
                       END;
                    IF ( ( help [ 1 ] <> stop_cod ) AND
                         ( help [ 1 ] <> rem_cod ) ) THEN
                      BEGIN
                          INC ( y );
                          w_print ( 2, y, help )
                      END
                END
       END

END; { procedure f_window }
{$V+}

{-------------------------------------------------------------------------}

PROCEDURE conout ( x, y : BYTE; { координаты символа }
                   key : BYTE; { место размещения : }
                                  {  0 - экран         }
                                  {  1 - образ окна    }
                                  {  2 - экран и образ }
                   ch : CHAR { выводимый символ }         );

           { процедура вывода символа в текущее окно }
           {       по заданным координатам           }

BEGIN

    CASE key OF
          0 : xy_char ( x, y, ch );
          1 : w_char ( x, y, ch );
          2 : w_xy_char ( x, y, ch )
    END;

END; { procedure conout }

{-------------------------------------------------------------------------}

PROCEDURE w_line_y ( x, y1, y2 : BYTE; { координаты линии }
                   pointer : BYTE; { указатель направлеия рисунка }
                                      { 0 - сверху вниз              }
                                      { 1 - снизу вверх              }
                   key : BYTE; { место рисования }
                   ch : CHAR { символ линии }                         );

            { процедура рисования вертикальной линии }
            {             в текущем окне             }

VAR
   indx : BYTE; { индексная переменная }

BEGIN

     CASE pointer OF
            0  : FOR indx := y1 TO y2 DO
                   conout ( x, indx, key, ch );
            1  : FOR indx := y2 DOWNTO y1 DO
                   conout ( x, indx, key, ch )
     END;

END; { procedure w_line_y }

{-------------------------------------------------------------------------}

PROCEDURE w_line_x ( y, x1, x2 : BYTE; { координаты линии }
                   pointer : BYTE; { указатель направлеия рисунка }
                                      { 0 - слева направо            }
                                      { 1 - справа налево            }
                   key : BYTE; { место рисования }
                   ch : CHAR { символ линии }                         );

            { процедура рисования горизонтальной линии }
            {             в текущем окне               }

VAR
   indx : BYTE; { индексная переменная }

BEGIN

     CASE pointer OF
            0  : FOR indx := x1 TO x2 DO
                   conout ( indx, y, key, ch );
            1  : FOR indx := x2 DOWNTO x1 DO
                   conout ( indx, y, key, ch )
     END;

END; { procedure w_line_x }

{-------------------------------------------------------------------------}

PROCEDURE r1_window ( kx1, ky1, kx2, ky2 : BYTE;
                           { координаты выводимой рамки }
                      key : BYTE;
                           { место размещения }
                           { 0 - экран        }
                           { 1 - образ окна   }
                           { 2 - экран и образ}
                      ch : CHAR
                           { символ рамки                        }
                           { если ch = 196, 205, 219, 242, то    }
                           { рамка изображается соответствующими }
                           { псевдографическими символами, если  }
                           { ch = 0, то рамка выводится на экран }
                           { символами из текущего образа окна   }
                           {     соответствующих координат       } );

          { процедура рисует на экране или в образе окна }
          { рамку по заданным координатам заданными      }
          { символами либо выводит на экран рамку из     }
          {      символов текущего образа окна           }

VAR
   cd : BYTE; { вспомогательная переменная кода символа рамки }

PROCEDURE corners ( ch1, ch2, ch3, ch4 : CHAR );
          { процедура выводит необходимые символы }
          {         по углам рамки окна           }

BEGIN

    conout ( kx1, ky1, key, ch1 );
    conout ( kx2, ky1, key, ch2 );
    conout ( kx2, ky2, key, ch3 );
    conout ( kx1, ky2, key, ch4 )

END; { procedure corners }


PROCEDURE ramka_old;
         { процедура рисования рамки символами }
         {           из образа окна            }

VAR
    x, y : BYTE; { индексная переменная }
    ch : CHAR;
    at : BYTE;
    d_atr : BYTE;

BEGIN

     d_atr := www_atr;
     WITH www_seg [ ww_num ]^ DO
         BEGIN
              FOR x := kx1 TO kx2 DO
                  BEGIN
                       IF ( old_screen ) THEN
                          get_old_pic ( x, ky1, ch, at )
                       ELSE
                           get_pic ( x, ky1, ch, at );
                       www_atr := at;
                       xy_char ( x, ky1, ch )
                  END;
              FOR y := ky1 TO ky2 DO
                  BEGIN
                       IF ( old_screen ) THEN
                          get_old_pic ( kx2, y, ch, at )
                       ELSE
                           get_pic ( kx2, y, ch, at );
                       www_atr := at;
                       xy_char ( kx2, y, ch )
                  END;
              FOR x := kx2 DOWNTO kx1 DO
                  BEGIN
                       IF ( old_screen ) THEN
                          get_old_pic ( x, ky2, ch, at )
                       ELSE
                           get_pic ( x, ky2, ch, at );
                       www_atr := at;
                       xy_char ( x, ky2, ch )
                  END;
              FOR y := ky2 DOWNTO ky1 DO
                  BEGIN
                       IF ( old_screen ) THEN
                          get_old_pic ( kx1, y, ch, at )
                       ELSE
                           get_pic ( kx1, y, ch, at );
                       www_atr := at;
                       xy_char ( kx1, y, ch )
                  END
         END;
     www_atr := d_atr

END; { procedure ramka_old }


PROCEDURE rln ( ch1, ch2, ch3, ch4 : CHAR );
         { процедура рисования сторон рамки }
         {        заданными символами       }

BEGIN

    w_line_x ( ky1, kx1, kx2, 0, key, ch1 );
    w_line_y ( kx2, ky1, ky2, 0, key, ch2 );
    w_line_x ( ky2, kx1, kx2, 1, key, ch3 );
    w_line_y ( kx1, ky1, ky2, 1, key, ch4 )

END; { procedure rln }


BEGIN

    cd := ORD ( ch );

    CASE cd OF

         0  :  ramka_old;  { образ в памяти }

         196:  BEGIN       { тонкая линия }
                   rln ( CHR(196), CHR(179), CHR(196), CHR(179) );
                   corners ( CHR(218), CHR(191), CHR(217), CHR(192) )
               END;

         205:  BEGIN       { двойная линия }
                   rln ( CHR(205), CHR(186), CHR(205), CHR(186) );
                   corners ( CHR(201), CHR(187), CHR(188), CHR(200) )
               END;

         219:  BEGIN       { толстая линия }
                   rln ( CHR(223), CHR(219), CHR(220), CHR(219) );
                   corners ( CHR(219), CHR(219), CHR(219), CHR(219) )
               END;

         242:  BEGIN       { тонкая линия, срезанные углы }
                   rln ( CHR(196), CHR(179), CHR(196), CHR(179) );
                   corners ( CHR(242), CHR(243), CHR(244), CHR(245) )
               END
     ELSE
        rln ( ch, ch, ch, ch )

     END; { case }

END; { procedure r1_window }

{-------------------------------------------------------------------------}

PROCEDURE w_calc ( lnx, lny : BYTE;
                   { размер окна по координатным осям }
                   VAR x1, y1, x2, y2 : BYTE
                   { начальные координаты окна } );

          { процедура вычисления начальных координат }
          {               окна                       }


BEGIN
    x1 := 1;
    y1 := 1;
    x2 := lnx;
    y2 := lny;
    WHILE ( ( ( x2 - x1 ) > 1 ) AND ( ( y2 - y1 ) > 1 ) ) DO
        BEGIN
            INC ( x1 );
            DEC ( x2 );
            INC ( y1 );
            DEC ( y2 )
         END

END; { procedure w_calc }

{-------------------------------------------------------------------------}

PROCEDURE rn_window ( ch : CHAR );

          { плавное появление рамки в окне }
          {    вместе с содержимым окна    }

VAR
   knx1, kny1, knx2, kny2 : BYTE;
              { координаты начала движения рамки }

   lnx, lny : BYTE;
              { размеры окна по координатным осям }

BEGIN
    old_screen := FALSE;
    WITH www_seg [ ww_num ]^ DO
       BEGIN
           lnx := x2 - x1 + 1;
           lny := y2 - y1 + 1;
           w_calc ( lnx, lny, knx1, kny1, knx2, kny2 );
           r1_window ( knx1, kny1, knx2, kny2, 0, ch );
           WHILE ( ( knx1 <> 1 ) AND ( kny1 <> 1 ) ) DO
               BEGIN
                   DEC ( knx1 );
                   DEC ( kny1 );
                   INC ( knx2 );
                   INC ( kny2 );
                   r1_window ( knx1, kny1, knx2, kny2, 0, ch );
                   r1_window ( ( knx1 + 1 ), ( kny1 + 1 ),
                               ( knx2 - 1 ), ( kny2 - 1 ), 0, CHR ( 0 ) )
               END;
           r1_window ( knx1, kny1, knx2, kny2, 1, ch )
       END;

END; { procedure rn_window }

{-------------------------------------------------------------------------}

PROCEDURE rd_window ( ch : CHAR );

          { процедура удаления текущего окна с     }
          { медленным исчезновением рамки и        }
          { появлением изображения предшествующего }
          {              окна                      }

VAR
    kx1, ky1, kx2, ky2 : BYTE;
          { координаты рамки текущего окна }

BEGIN
     old_screen := TRUE;

           { установка координат рамки текущего окна }

     WITH www_seg [ ww_num ]^ DO
        BEGIN
            kx1 := 1;
            ky1 := 1;
            kx2 := x2 - x1 + 1;
            ky2 := y2 - y1 + 1
        END;

            { цикл исчезновения / восстановления }

     WHILE ( ( ( kx2 - kx1 ) >= 1 ) AND ( ( ky2 - ky1 ) >= 1 ) ) DO
         BEGIN
              r1_window ( kx1, ky1, kx2, ky2, 0, ch );
              r1_window ( kx1, ky1, kx2, ky2, 0, CHR ( 0 ) );
              INC ( kx1 );
              INC ( ky1 );
              DEC ( kx2 );
              DEC ( ky2 );
         END;
     r1_window ( kx1, ky1, kx2, ky2, 0, CHR ( 0 ) );
     old_screen := FALSE;
     d_window;

END; { procedure rd_window }

{-------------------------------------------------------------------------}

PROCEDURE sirena;     { Сирена до нажатия клавиши }

VAR
   ch : CHAR;
   k : INTEGER;

BEGIN
     WHILE ( NOT KEYPRESSED ) DO
           BEGIN
                FOR k := 200 TO 800 DO
                    BEGIN
                         SOUND ( k );
                         DELAY ( 2 )
                    END;
                FOR k := 800 DOWNTO 200 DO
                    BEGIN
                         SOUND ( k );
                         DELAY ( 1 )
                    END
           END;
     NOSOUND;
     ch := READKEY

END; { procedure sirena }

{------------------------------------------------------------------------}

PROCEDURE warning ( x, y : BYTE; stroka : ss_string );

          { Выдача сообщения об ошибке }

BEGIN
     work_number ( 0 );
     n_window ( x, y, ( x + LENGTH ( stroka ) + 4 ), ( y + 3 ), RED, GREEN );
     w_print ( 3, 2, stroka );
     show_t ( BLACK, WHITE );
     tp_window;
     sirena;
     pd_window

END; { procedure warning }

{------------------------------------------------------------------------}

PROCEDURE out_line ( x, y, lc, key : BYTE; ch : CHAR; lend : BOOLEAN );

VAR
   at : BYTE;
   cl : CHAR;
   lx, ly : BYTE;
   lkey : BYTE;
   wx, wy : BYTE;

FUNCTION key_left : BOOLEAN;

BEGIN
     key_left := FALSE;
     IF ( ( x - 1 ) < 1 ) THEN EXIT;
     ld_char ( ( x - 1 ), y, cl, at );
     IF ( cl IN [ #192, #193, #194, #195, #196, #197, #199, #210,
                  #211, #214, #215, #218 ] ) THEN
         BEGIN
              lkey := 1;
              key_left := TRUE
         END;
     IF ( cl IN [ #198, #200, #201, #202, #203, #204, #205, #206,
                  #207, #209, #212, #213, #216 ] ) THEN
         BEGIN
              lkey := 2;
              key_left := TRUE
         END

END; { function key_left }

FUNCTION key_right : BOOLEAN;

BEGIN
     key_right := FALSE;
     IF ( ( x + 1 ) > wx ) THEN EXIT;
     ld_char ( ( x + 1 ), y, cl, at );
     IF ( cl IN [ #180, #182, #183, #189, #191, #193, #194, #196,
                  #197, #208, #210, #215, #217 ] ) THEN
        BEGIN
             lkey := 1;
             key_right := TRUE
        END;
     IF ( cl IN [ #181, #184, #185, #187, #188, #190, #202, #203,
                  #205, #206, #207, #209, #216 ] ) THEN
        BEGIN
             lkey := 2;
             key_right := TRUE
        END

END; { function key_right }

FUNCTION key_up : BOOLEAN;

BEGIN
     key_up := FALSE;
     IF ( ( y - 1 ) < 1 ) THEN EXIT;
     ld_char ( x, ( y - 1 ), cl, at );
     IF ( cl IN [ #179, #180, #181, #184, #191, #194, #195, #197,
                  #198, #209, #213, #216, #218 ] ) THEN
        BEGIN
             lkey := 1;
             key_up := TRUE
        END;
     IF ( cl IN [ #182, #183, #185, #186, #187, #199, #201, #203,
                  #204, #206, #210, #214, #215 ] ) THEN
        BEGIN
             lkey := 2;
             key_up := TRUE
        END

END; { function key_up }

FUNCTION key_down : BOOLEAN;

BEGIN
     key_down := FALSE;
     IF ( ( y + 1 ) > wy ) THEN EXIT;
     ld_char ( x, ( y + 1 ), cl, at );
     IF ( cl IN [ #179, #180, #181, #190, #192, #193, #195, #197,
                  #198, #207, #212, #216, #217 ] ) THEN
        BEGIN
             lkey := 1;
             key_down := TRUE
        END;
     IF ( cl IN [ #182, #185, #186, #188, #189, #199, #200, #202,
                  #204, #206, #208, #211, #215 ] ) THEN
        BEGIN
             lkey := 2;
             key_down := TRUE
        END

END; { function key_down }

PROCEDURE vert_end ( cdown, cup : CHAR );

BEGIN
     IF ( NOT key_down ) THEN
        conout ( x, y, key, cdown );
     IF ( NOT key_up ) THEN
        conout ( x, y, key, cup );
     IF ( ( NOT key_down ) AND ( NOT key_up ) ) THEN
        BEGIN
             IF ( lc = 1 ) THEN
                conout ( x, y, key, cup )
             ELSE
                conout ( x, y, key, cdown )
        END

END; { procedure vert_end }

PROCEDURE gor_end ( cleft, cright : CHAR );

BEGIN
     IF ( NOT key_left ) THEN
        conout ( x, y, key, cleft );
     IF ( NOT key_right ) THEN
        conout ( x, y, key, cright );
     IF ( ( NOT key_left ) AND ( NOT key_right ) ) THEN
        BEGIN
             IF ( lc = 4 ) THEN
                conout ( x, y, key, cright )
             ELSE
                conout ( x, y, key, cleft )
        END

END; { procedure gor_end }

PROCEDURE one_vert;  { Вертикальная одинарная }

BEGIN
     IF ( key_left AND key_right ) THEN
        BEGIN
             IF ( lkey = 1 ) THEN
                BEGIN
                     conout ( x, y, key, #197 );
                     IF ( lend ) THEN
                        vert_end ( #193, #194 )
                END
             ELSE
                 BEGIN
                      conout ( x, y, key, #216 );
                      IF ( lend ) THEN
                         vert_end ( #207, #209 )
                 END;
             EXIT
        END;
     IF ( key_left AND ( NOT key_right ) ) THEN
        BEGIN
             IF ( lkey = 1 ) THEN
                BEGIN
                     conout ( x, y, key, #180 );
                     IF ( lend ) THEN
                        vert_end ( #217, #191 )
                END
             ELSE
                 BEGIN
                      conout ( x, y, key, #181 );
                      IF ( lend ) THEN
                         vert_end ( #190, #184 )
                 END;
             EXIT
        END;
     IF ( ( NOT key_left ) AND key_right ) THEN
        BEGIN
             IF ( lkey = 1 ) THEN
                BEGIN
                     conout ( x, y, key, #195 );
                     IF ( lend ) THEN
                        vert_end ( #192, #218 )
                END
             ELSE
                 BEGIN
                      conout ( x, y, key, #198 );
                      IF ( lend ) THEN
                         vert_end ( #212, #213 )
                 END;
             EXIT
        END;
     conout ( x, y, key, ch )

END; { procedure one_vert }

PROCEDURE duble_vert;  { Вертикальная двойная }

BEGIN
     IF ( key_left AND key_right ) THEN
        BEGIN
             IF ( lkey = 1 ) THEN
                BEGIN
                     conout ( x, y, key, #215 );
                     IF ( lend ) THEN
                        vert_end ( #208, #210 )
                END
             ELSE
                 BEGIN
                      conout ( x, y, key, #206 );
                      IF ( lend ) THEN
                         vert_end ( #202, #203 )
                 END;
             EXIT
        END;
     IF ( key_left AND ( NOT key_right ) ) THEN
        BEGIN
             IF ( lkey = 1 ) THEN
                BEGIN
                     conout ( x, y, key, #182 );
                     IF ( lend ) THEN
                        vert_end ( #189, #183 )
                END
             ELSE
                 BEGIN
                      conout ( x, y, key, #185 );
                      IF ( lend ) THEN
                         vert_end ( #188, #187 )
                 END;
             EXIT
        END;
     IF ( ( NOT key_left ) AND key_right ) THEN
        BEGIN
             IF ( lkey = 1 ) THEN
                BEGIN
                     conout ( x, y, key, #199 );
                     IF ( lend ) THEN
                        vert_end ( #211, #214 )
                END
             ELSE
                 BEGIN
                      conout ( x, y, key, #204 );
                      IF ( lend ) THEN
                         vert_end ( #200, #201 )
                 END;
             EXIT
        END;
     conout ( x, y, key, ch )

END; { procedure duble_vert }

PROCEDURE one_gor;    { Горизонтальная одинарная }

BEGIN
     IF ( key_down AND key_up ) THEN
        BEGIN
             IF ( lkey = 1 ) THEN
                BEGIN
                     conout ( x, y, key, #197 );
                     IF ( lend ) THEN
                        gor_end ( #195, #180 )
                END
             ELSE
                 BEGIN
                      conout ( x, y, key, #215 );
                      IF ( lend ) THEN
                         gor_end ( #199, #182 )
                 END;
             EXIT
        END;
     IF ( key_down AND ( NOT key_up ) ) THEN
        BEGIN
             IF ( lkey = 1 ) THEN
                BEGIN
                     conout ( x, y, key, #194 );
                     IF ( lend ) THEN
                        gor_end ( #218, #191 )
                END
             ELSE
                 BEGIN
                      conout ( x, y, key, #210 );
                      IF ( lend ) THEN
                         gor_end ( #214, #183 )
                 END;
             EXIT
        END;
     IF ( ( NOT key_down ) AND key_up ) THEN
        BEGIN
             IF ( lkey = 1 ) THEN
                BEGIN
                     conout ( x, y, key, #193 );
                     IF ( lend ) THEN
                        gor_end ( #192, #217 )
                END
             ELSE
                 BEGIN
                      conout ( x, y, key, #208 );
                      IF ( lend ) THEN
                         gor_end ( #211, #189 )
                 END;
             EXIT
        END;
     conout ( x, y, key, ch )

END; { procedure one_gor }

PROCEDURE duble_gor;  { Горизонтальная двойная }

BEGIN
     IF ( key_down AND key_up ) THEN
        BEGIN
             IF ( lkey = 1 ) THEN
                BEGIN
                     conout ( x, y, key, #216 );
                     IF ( lend ) THEN
                        gor_end ( #198, #181 )
                END
             ELSE
                 BEGIN
                      conout ( x, y, key, #206 );
                      IF ( lend ) THEN
                         gor_end ( #204, #185 )
                 END;
             EXIT
        END;
     IF ( key_down AND ( NOT key_up ) ) THEN
        BEGIN
             IF ( lkey = 1 ) THEN
                BEGIN
                     conout ( x, y, key, #209 );
                     IF ( lend ) THEN
                        gor_end ( #213, #184 )
                END
             ELSE
                 BEGIN
                      conout ( x, y, key, #203 );
                      IF ( lend ) THEN
                         gor_end ( #201, #187 )
                 END;
             EXIT
        END;
     IF ( ( NOT key_down ) AND key_up ) THEN
        BEGIN
             IF ( lkey = 1 ) THEN
                BEGIN
                     conout ( x, y, key, #207 );
                     IF ( lend ) THEN
                        gor_end ( #212, #190 )
                END
             ELSE
                 BEGIN
                      conout ( x, y, key, #202 );
                      IF ( lend ) THEN
                         gor_end ( #200, #188 )
                 END;
             EXIT
        END;
     conout ( x, y, key, ch )

END; { procedure duble_gor }

BEGIN
     WITH www_seg [ ww_num ]^ DO
          BEGIN
               wx := x2 - x1 + 1;
               wy := y2 - y1 + 1
          END;
     CASE ORD ( ch ) OF

          179 : IF ( ( lc = 1 ) OR ( lc = 3 ) ) THEN
                    one_vert
                 ELSE
                     conout ( x, y, key, ch );

          186 : IF ( ( lc = 1 ) OR ( lc = 3 ) ) THEN
                    duble_vert
                 ELSE
                     conout ( x, y, key, ch );

          196 : IF ( ( lc = 2 ) OR ( lc = 4 ) ) THEN
                    one_gor
                 ELSE
                     conout ( x, y, key, ch );

          205 : IF ( ( lc = 2 ) OR ( lc = 4 ) ) THEN
                    duble_gor
                 ELSE
                     conout ( x, y, key, ch )
     ELSE
         conout ( x, y, key, ch )
     END

END; { procedure out_line }

{------------------------------------------------------------------------}

PROCEDURE line_y ( x, y1, y2 : BYTE; { координаты линии }
                   pointer : BYTE; { указатель направлеия рисунка }
                                      { 0 - сверху вниз              }
                                      { 1 - снизу вверх              }
                   key : BYTE; { место рисования }
                   ch : CHAR { символ линии }                         );

            { процедура рисования вертикальной линии }
            {             в текущем окне             }

VAR
   indx : BYTE; { индексная переменная }
   lend : BOOLEAN;

BEGIN

     CASE pointer OF
            0  : FOR indx := y1 TO y2 DO
                     BEGIN
                          IF ( ( indx = y1 ) OR ( indx = y2 ) ) THEN
                             lend := TRUE
                          ELSE
                              lend := FALSE;
                          out_line ( x, indx, 1, key, ch, lend )
                     END;
            1  : FOR indx := y2 DOWNTO y1 DO
                     BEGIN
                          IF ( ( indx = y1 ) OR ( indx = y2 ) ) THEN
                             lend := TRUE
                          ELSE
                              lend := FALSE;
                          out_line ( x, indx, 3, key, ch, lend )
                     END;
     END;

END; { procedure line_y }

{-------------------------------------------------------------------------}

PROCEDURE line_x ( y, x1, x2 : BYTE; { координаты линии }
                   pointer : BYTE; { указатель направлеия рисунка }
                                      { 0 - слева направо            }
                                      { 1 - справа налево            }
                   key : BYTE; { место рисования }
                   ch : CHAR { символ линии }                         );

            { процедура рисования горизонтальной линии }
            {             в текущем окне               }

VAR
   indx : BYTE; { индексная переменная }
   lend : BOOLEAN;

BEGIN

     CASE pointer OF
            0  : FOR indx := x1 TO x2 DO
                     BEGIN
                          IF ( ( indx = x1 ) OR ( indx = x2 ) ) THEN
                             lend := TRUE
                          ELSE
                              lend := FALSE;
                          out_line ( indx, y, 2, key, ch, lend )
                     END;
            1  : FOR indx := x2 DOWNTO x1 DO
                     BEGIN
                          IF ( ( indx = x1 ) OR ( indx = x2 ) ) THEN
                             lend := TRUE
                          ELSE
                              lend := FALSE;
                          out_line ( indx, y, 4, key, ch, lend )
                     END;
     END;

END; { procedure line_x }

{-------------------------------------------------------------------------}

PROCEDURE ForTextHelp ( x1, y1, x2, y2, fon, sym : BYTE );

VAR
   index, SizeX, SizeY : BYTE;
   Ch : CHAR;
   Line : ARRAY [ 1..23 ] OF StandartString;

BEGIN
     FOR index := 1 TO 23 DO
         Line [ index ] := '';
     N_Window ( x1, y1, x2, y2, fon, sym );
     Show_T ( BLACK, WHITE );
     R1_Window ( 1, 1, ( x2 - x1 ), ( y2 - y1 ), 1, #196 );
     SizeX := x2 - x1 - 2;
     SizeY := y2 - y1 - 1;
     index := 2;
     Rn_Window ( #0 );
     SetTypeEdit ( 0 );
     SetColorEdit ( fon, sym );
     SetColorClearEdit ( fon, sym );
     REPEAT
            XY_Edit ( 2, index, Ch, SizeX, Line [ index ] );
            CASE Ch OF
                 arrow_up   : BEGIN
                                   IF ( index > 2 ) THEN
                                      DEC ( index )
                              END;
                 arrow_down : BEGIN
                                   IF ( index < SizeY ) THEN
                                      INC ( index )
                              END;
                 #$0D       : BEGIN
                                   IF ( index < SizeY ) THEN
                                      INC ( index )
                              END
            END
     UNTIL ( Ch = #27 );
     SOUND ( 800 );
     DELAY ( 50 );
     NOSOUND;
     AnyKey;
     Rd_Window ( #0 )

END; { procedure ForTextHelp }

{-------------------------------------------------------------------------}

PROCEDURE epson ( ch : CHAR; VAR key : BOOLEAN );

VAR
   rg : REGISTERS;
   cc: CHAR;
   rm : BOOLEAN;
   ss : STRING;
   all : BOOLEAN;

BEGIN
    IF ( key ) THEN
       EXIT;
    rm := FALSE;
    all := FALSE;
    WHILE ( NOT all ) DO
          BEGIN
               rg.DX := 0;
               rg.AH := 2;
               INTR ( $17, rg );
               IF ( rg.AH = 144 ) THEN
                   all := TRUE
               ELSE
                   IF ( ( NOT rm ) AND ( NOT all ) AND ( rg.AH <> 16 ) AND
                        ( rg.AH <> 208 ) AND ( rg.AH <> 80 ) ) THEN
                      BEGIN
                           n_window ( 10, 15, 36, 19, RED, BLUE );
                           CASE rg.AH OF
                                 24 :  w_print ( 4, 2,
                                       'Включите ON LINE' );
                                 25 :  w_print ( 4, 2,
                                       'Включите ON LINE' );
                                 56 :  w_print ( 4, 2,
                                       'Нет бумаги' );
                                 57 :  w_print ( 4, 2,
                                       'Нет бумаги' );
                                200 :  w_print ( 4, 2,
                                       'Включите принтер' )
                           ELSE
                                BEGIN
                                     STR ( rg.AH, ss );
                                     w_print ( 4, 2,
                                             'Сбой принтера' );
                                     w_print ( 4, 3,
                                             CONCAT ( 'Ошибка # ',ss ) )
                                END
                           END;
                           rm := TRUE;
                           show_t ( BLACK, WHITE );
                           tp_window;
                           WRITE ( CHR ( 7 ) )
                       END;
               IF ( ( KEYPRESSED ) AND ( NOT all ) ) THEN
                  BEGIN
                       cc := READKEY;
                       IF ( rm ) THEN
                          rd_window ( ' ' );
                       rm := FALSE;
                       IF ( cc = CHR ( 27 ) ) THEN
                          BEGIN
                               key := TRUE;
                               EXIT
                          END
                  END

          END;
    IF ( rm ) THEN
       rd_window ( ' ' );
    rm := FALSE;
    WHILE TRUE DO
          BEGIN
               rg.DX := 0;
               rg.AH := 0;
               rg.AL := ORD ( ch );
               INTR ( $17, rg );
               IF ( ( rg.AH mod 2 ) = 0 ) THEN
                  BEGIN
                       IF ( rm ) THEN
                          rd_window ( ' ' );
                       EXIT
                  END;
               IF ( ( NOT rm ) AND ( rg.AH <> 208 ) ) THEN
                  BEGIN
                       n_window ( 10, 15, 36, 19, RED, BLUE );
                       CASE rg.AH OF
                             25 :  w_print ( 4, 2,
                                   'Включите ON LINE' );
                             57 :  w_print ( 4, 2,
                                   'Нет бумаги' )
                       ELSE
                            BEGIN
                                 STR ( rg.AH, ss );
                                 w_print ( 4, 2,
                                         'Сбой принтера' );
                                 w_print ( 4, 3,
                                         CONCAT ( 'Ошибка # ',ss ) )
                            END
                       END;
                       rm := TRUE;
                       show_t ( BLACK, WHITE );
                       tp_window ;
                       WRITE ( CHR ( 7 ) )
                   END;
               IF KEYPRESSED THEN
                  BEGIN
                       cc := READKEY;
                       IF ( rm ) THEN
                          rd_window ( ' ' );
                       rm := FALSE;
                       IF ( cc = CHR ( 27 ) ) THEN
                          BEGIN
                               key := TRUE;
                               EXIT
                          END
                  END
           END

END; { procedure epson }

{-------------------------------------------------------------------}

BEGIN
     w_init

END.

