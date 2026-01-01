
            {-------------------------------------------------}
            {         Программа EditFont V 1.0                }
            {-------------------------------------------------}
            { Язык программирования : Turbo Pascal V 6.0      }
            {-------------------------------------------------}
            { Дата создания : 08/04/1992                      }
            { Дата последних изменений : 09/04/1992           }
            {-------------------------------------------------}
            {   Программа предназначена для редактирования    }
            {            файлов точечных шрифтов              }
            {-------------------------------------------------}
            {  (c) 1992 Ярослав Мигач                         }
            {-------------------------------------------------}

PROGRAM Edit_Font;

USES Dos, Crt, Def, FKey11;

VAR
   Fl : FILE; { Файл просматриваемого и редактируемого шрифта }

   SizeFont : LONGINT;
              { Размер редактируемого файла шрифтов }

   Counter : LONGINT;
              { Указатель на номер первого просматриваемого байта }

   ScreenBuf : ARRAY [ 1..256 ] OF BYTE;
              { Буфер Экрана }

   SingWrite : BOOLEAN;
              { Признак записи текущего буфера }

   BlockBegin : LONGINT;
              { Маркер начала блока }

   BlockEnd : LONGINT;
              { Маркер конца блока }

   KeyExit : BOOLEAN;
              { Признак выхода }

   NameFont : STRING [ 40 ];
               { Имя файла шрифта }

   SizeYFont : BYTE;
               { Количество строк в символе шрифта }

   SizeXFont : BYTE;
               { Количество пикселей по горизонтале }

   Orient : BYTE;
               { Ориентация отображения шрифта }

   MaxScreen : BYTE; { Количество байт отображаемых на экране }

   CurrentByte : BYTE; { Текущий байт на экране }

   CurrentBit : BYTE;  { Текущий бит на экране }

   StartAddres : LONGINT; { Стартовый адрес }

{----------------------------------------------------------}

PROCEDURE War ( Mess : STRING );

          { Выдача предупреждающего сообщения }
VAR
   Index : WORD;

BEGIN
     TEXTBACKGROUND ( BLACK );
     TEXTCOLOR ( LIGHTRED + BLINK );
     GOTOXY ( 1, 22 );
     WRITE ( Mess );
     FOR Index := 10 DOWNTO 1 DO
         BEGIN
              SOUND ( 15 * Index );
              DELAY ( 200 );
              NOSOUND;
              DELAY ( 100 )
         END;
     DELAY ( 2000 );
     GOTOXY ( 1, 22 );
     WRITE ( '                                                         ' )

END; { procedure Mess }

{----------------------------------------------------------}

FUNCTION HexStr ( Num : LONGINT ) : STRING;

         { Преобразование целого числа в шеснадцатиричный формат }
VAR
   Line : STRING;
   Hlp : LONGINT;
   Index : LONGINT;

BEGIN
     IF ( Num < 0 ) THEN
        BEGIN
             HexStr := '';
             EXIT
        END;
      Line := '';
      REPEAT
            Index := Num MOD 16;
            CASE Index OF
                   0 : Line := '0' + Line;
                   1 : Line := '1' + Line;
                   2 : Line := '2' + Line;
                   3 : Line := '3' + Line;
                   4 : Line := '4' + Line;
                   5 : Line := '5' + Line;
                   6 : Line := '6' + Line;
                   7 : Line := '7' + Line;
                   8 : Line := '8' + Line;
                   9 : Line := '9' + Line;
                   10: Line := 'A' + Line;
                   11: Line := 'B' + Line;
                   12: Line := 'C' + Line;
                   13: Line := 'D' + Line;
                   14: Line := 'E' + Line;
                   15: Line := 'F' + Line
            ELSE
                War ( 'Ошибка преобразования' )
            END;
            Num := Num DIV 16
      UNTIL ( Num <= 0 );
      HexStr := Line

END; { function HexStr }

{----------------------------------------------------------}

PROCEDURE ShowFont_Vert;

          { Показать на экране текущий отрезок файла шрифта }
          {           в вертикальной ориентации             }
VAR
   Index, Hlp : BYTE;
   Sing : BOOLEAN;
   SB : BYTE;
   Ch : CHAR;
   DealSymbol : BYTE;
   FirstNumber : LONGINT;
   HelpS : STRING [ 80 ];

BEGIN
     FOR Index := 1 TO MaxScreen DO
         BEGIN
              SB := 1;
              IF ( ( ( Counter + Index - 1 ) >= BlockBegin ) AND
                   ( ( Counter + Index - 1 ) <= BlockEnd )
                     AND ( BlockEnd > 0  ) AND ( BlockBegin > 0 ) ) THEN
                 BEGIN
                      TEXTCOLOR ( BLACK );
                      TEXTBACKGROUND ( LIGHTGRAY )
                 END
              ELSE
                  BEGIN
                      TEXTCOLOR ( YELLOW );
                      TEXTBACKGROUND ( BLUE )
                  END;
              FOR Hlp := 1 TO 8 DO
                  BEGIN
                       IF ( ( ScreenBuf [ Index ] AND SB ) <> 0 ) THEN
                          Ch := #04
                       ELSE
                           Ch := ' ';
                       IF ( Hlp <> 8 ) THEN
                          SB := SB * 2;
                       GOTOXY ( Index, Hlp );
                       WRITE ( Ch )
                  END;
         END;

     TEXTBACKGROUND ( BLACK );
     FirstNumber := ( Counter - StartAddres ) DIV SizeYFont;
     DealSymbol := MaxScreen DIV SizeYFont;
     FOR Index := 1 TO DealSymbol DO
         BEGIN
              GOTOXY ( ( ( Index - 1 ) * SizeYFont + 1 ),10 );
              STR ( FirstNumber, HelpS );
              HelpS := '<' + HelpS;
              WHILE ( LENGTH ( HelpS ) < SizeYFont ) DO
                    HelpS := HelpS + ' ';
              TEXTCOLOR ( GREEN );
              WRITE ( HelpS );

              HelpS := HexStr ( FirstNumber );
              IF ( LENGTH ( HelpS ) = 1 ) THEN
                  HelpS := '0' + HelpS;
              GOTOXY ( ( ( Index - 1 ) * SizeYFont + 1 ),11 );
              HelpS := '|' + HelpS;
              WHILE ( LENGTH ( HelpS ) < SizeYFont ) DO
                    HelpS := HelpS + ' ';
              TEXTCOLOR ( RED );
              WRITE ( HelpS );
              INC ( FirstNumber )
         END;

END; { procedure ShowFont_Vert }

{----------------------------------------------------------}

PROCEDURE ShowFont_Hor;

          { Показать на экране текущий отрезок файла шрифта }
          {         в горизонтальной ориентации             }
VAR
   Index, Hlp : BYTE;
   Sing : BOOLEAN;
   SB : BYTE;
   Ch : CHAR;
   DealSymbol : BYTE;
   FirstNumber : LONGINT;
   HelpS : STRING [ 80 ];

BEGIN
     FOR Index := 1 TO MaxScreen DO
         BEGIN
              SB := 1;
              IF ( ( ( Counter + Index - 1 ) >= BlockBegin ) AND
                   ( ( Counter + Index - 1 ) <= BlockEnd )
                      AND ( BlockEnd > 0 ) AND ( BlockBegin > 0 ) ) THEN
                 BEGIN
                      TEXTCOLOR ( BLACK );
                      TEXTBACKGROUND ( LIGHTGRAY )
                 END
              ELSE
                  BEGIN
                      TEXTCOLOR ( YELLOW );
                      TEXTBACKGROUND ( BLUE )
                  END;
              FOR Hlp := 8 DOWNTO 1 DO
                  BEGIN
                       IF ( ( ScreenBuf [ Index ] AND SB ) <> 0 ) THEN
                          Ch := #04
                       ELSE
                           Ch := ' ';
                       IF ( Hlp <> 1 ) THEN
                          SB := SB * 2;
                       GOTOXY ( Index, Hlp );
                       WRITE ( Ch )
                  END;
         END;

     TEXTBACKGROUND ( BLACK );
     FirstNumber := ( Counter - StartAddres ) DIV SizeYFont;
     DealSymbol := MaxScreen DIV SizeYFont;
     FOR Index := 1 TO DealSymbol DO
         BEGIN
              GOTOXY ( ( ( Index - 1 ) * SizeYFont + 1 ),10 );
              STR ( FirstNumber, HelpS );
              HelpS := '<' + HelpS;
              WHILE ( LENGTH ( HelpS ) < SizeYFont ) DO
                    HelpS := HelpS + ' ';
              TEXTCOLOR ( GREEN );
              WRITE ( HelpS );

              HelpS := HexStr ( FirstNumber );
              IF ( LENGTH ( HelpS ) = 1 ) THEN
                  HelpS := '0' + HelpS;
              GOTOXY ( ( ( Index - 1 ) * SizeYFont + 1 ),11 );
              HelpS := '|' + HelpS;
              WHILE ( LENGTH ( HelpS ) < SizeYFont ) DO
                    HelpS := HelpS + ' ';
              TEXTCOLOR ( RED );
              WRITE ( HelpS );
              INC ( FirstNumber )
         END;

END; { procedure ShowFont_Hor }

{----------------------------------------------------------}

PROCEDURE SetCursor_Hor;

          { Установить курсор по горизонтальной ориентации }
BEGIN
     IF ( ( ( Counter + CurrentByte - 1 ) >= BlockBegin ) AND
          ( ( Counter + CurrentByte - 1 ) <= BlockEnd ) ) THEN
        BEGIN
             TEXTCOLOR ( BLACK );
             TEXTBACKGROUND ( LIGHTGRAY )
        END
     ELSE
         BEGIN
              TEXTCOLOR ( YELLOW );
              TEXTBACKGROUND ( BLUE )
         END;
     GOTOXY ( CurrentByte, ( 9 - CurrentBit ) )

END; { procedure SetCursor_Hor }

{----------------------------------------------------------}

PROCEDURE SetCursor_Vert;

           { Установить курсор по вертикальной ориентации }
BEGIN
     IF ( ( ( Counter + CurrentByte - 1 ) >= BlockBegin ) AND
          ( ( Counter + CurrentByte - 1 ) <= BlockEnd )
            AND ( BlockEnd > 0 ) AND ( BlockBegin > 0 ) ) THEN
        BEGIN
             TEXTCOLOR ( BLACK );
             TEXTBACKGROUND ( LIGHTGRAY )
        END
     ELSE
         BEGIN
              TEXTCOLOR ( YELLOW );
              TEXTBACKGROUND ( BLUE )
         END;
     GOTOXY ( CurrentByte, ( CurrentBit ) )

END; { procedure SetCursor_Vert }

{----------------------------------------------------------}

PROCEDURE SetCursor;

BEGIN
     TEXTBACKGROUND ( BLACK );
     TEXTCOLOR ( LIGHTRED );
     GOTOXY ( 30, 24 );
     WRITE ( ' Байт -',Counter + CurrentByte, '         ' );
     GOTOXY ( 60, 24 );
     WRITE ( ' Бит -',CurrentBit - 1, ' ' );

     CASE Orient OF
            1 : SetCursor_Hor;
            2 : SetCursor_Vert
     ELSE
         BEGIN
              WRITELN ( 'Недопустимая ориентация' );
              WRITELN ( #7 );
              HALT ( 1 )
         END
     END

END; { Procedure SetCursor }

{----------------------------------------------------------}

PROCEDURE ShowFont;

          { Показать на экране текущий отрезок файла шрифта }
          {         в установленной ориентации              }
BEGIN
     CASE Orient OF
            1 : ShowFont_Hor;
            2 : ShowFont_Vert
     ELSE
         BEGIN
              WRITELN ( 'Недопустимая ориентация' );
              WRITELN ( #7 );
              HALT ( 1 )
         END
     END;

     TEXTBACKGROUND ( BLACK );
     TEXTCOLOR ( LIGHTGRAY );
     GOTOXY ( 1, 24 );
     WRITE ( ' Адрес - /С',Counter, '           ' );

     SetCursor

END; { procedure ShowFont }

{----------------------------------------------------------}

FUNCTION GetCommand : CHAR;

         { Получить текущую команду редактора }
BEGIN
     GetCommand := GetKey;
     IF ( SingKey ) THEN
        GetCommand := GetKey

END; { Function GetCommand }

{----------------------------------------------------------}

PROCEDURE SetUp;

          { Начальные установки }
VAR
   Index : BYTE;
   Err : INTEGER;
   HelpS : STRING [ 20 ];
   DealSymbol : BYTE;

BEGIN
     KeyExit := FALSE;
     SingWrite := FALSE;
     HideKey;
     Orient := 1;
     MaxScreen := 80;
     CurrentByte := 1;
     CurrentBit := 1;
     Counter := 0;
     SizeXFont := 1;
     SizeYFont := 8;
     CurrentByte := 1;
     CurrentBit := 1;
     BlockBegin := - 1;
     BlockEnd := - 1;

     FOR Index := 2 TO 5 DO
         BEGIN
              IF ( ( POS ( '/X',( PARAMSTR ( Index ) ) ) <> 0 ) OR
                 ( POS ( '/x', ( PARAMSTR ( Index ) ) ) <> 0 ) ) THEN
                 BEGIN
                      HelpS := PARAMSTR ( Index );
                      DELETE ( HelpS, 1, 2 );
                      VAL ( HelpS, SizeXFont, Err );
                      IF ( ( Err <> 0 ) OR  ( SizeXFont = 0 ) OR
                           ( SizeXFont > 3 ) ) THEN
                          BEGIN
                               WRITELN ( 'Допустимое значение - /X1..3' );
                               WRITELN ( #7 );
                               HALT ( 1 )
                          END
                 END;
              IF ( ( POS ( '/Y', ( PARAMSTR ( Index ) ) ) <> 0 ) OR
                 ( POS ( '/y', ( PARAMSTR ( Index ) ) ) <> 0 ) ) THEN
                 BEGIN
                      HelpS := PARAMSTR ( Index );
                      DELETE ( HelpS, 1, 2 );
                      VAL ( HelpS, SizeYFont, Err );
                      IF ( ( Err <> 0 ) OR  ( SizeYFont < 4 ) OR
                           ( SizeYFont > 80 ) ) THEN
                          BEGIN
                               WRITELN ( 'Допустимое значение - /Y4..80' );
                               WRITELN ( #7 );
                               HALT ( 1 )
                          END
                 END;
              IF ( ( POS ( '/O', ( PARAMSTR ( Index ) ) ) <> 0 ) OR
                 ( POS ( '/o', ( PARAMSTR ( Index ) ) ) <> 0 ) ) THEN
                 BEGIN
                      HelpS := PARAMSTR ( Index );
                      DELETE ( HelpS, 1, 2 );
                      VAL ( HelpS, Orient, Err );
                      IF ( ( Err <> 0 ) OR  ( Orient < 1 ) OR
                           ( Orient > 2 ) ) THEN
                          BEGIN
                               WRITELN ( 'Допустимое значение - /Y0..24' );
                               WRITELN ( #7 );
                               HALT ( 1 )
                          END
                 END;
              IF ( ( POS ( '/C', ( PARAMSTR ( Index ) ) ) <> 0 ) OR
                 ( POS ( '/c', ( PARAMSTR ( Index ) ) ) <> 0 ) ) THEN
                 BEGIN
                      HelpS := PARAMSTR ( Index );
                      DELETE ( HelpS, 1, 2 );
                      VAL ( HelpS, Counter, Err );
                      IF ( Err <> 0 ) THEN
                          BEGIN
                               WRITELN ( 'Допустимое значение - /C0..FILESIZE' );
                               WRITELN ( #7 );
                               HALT ( 1 )
                          END
                 END;
         END;

     StartAddres := Counter;
     CASE Orient OF
            1: BEGIN
                    DealSymbol := 80 DIV SizeYFont;
                    MaxScreen := DealSymbol * SizeYFont
               END;

            2: BEGIN
                    DealSymbol := 80 DIV SizeYFont;
                    MaxScreen := DealSymbol * SizeYFont
               END
     ELSE
         BEGIN
              WRITELN ( 'Недопустимая ориентация' );
              WRITELN ( #7 );
              HALT ( 1 )
         END
     END

END; { Procedure SetUp }

{----------------------------------------------------------}

PROCEDURE StartHelp;

BEGIN
     WRITELN ( 'Редактор шрифтов V 1.0, (c) 1992 Ярослав Мигач, FREEWARE' );
     WRITELN ( '' );
     WRITELN ( 'Формат командной строки :' );
     WRITELN ( 'EDFONTS.EXE <filename> [/O. /Y.. /C...]' );
     WRITELN ( '<filename> - Имя файла содержащего шрифт' );
     WRITELN ( '/Ynn - Количество пикселей по Y от 4 до 80' );
     WRITELN ( '/On - 1 или 2 позволяет менять ориентацию' );
     WRITELN ( '      шрифта на экране / вверх ногами /' );
     WRITELN ( '/Сnnnnnn - Стартовый адрес начала просмотра' );
     WRITELN ( '      в файле 0 .. и далее /в десятичном ' );
     WRITELN ( '      представлении /' );
     WRITELN ( '/H - Подсказка' );
     WRITELN ( '' );
     WRITELN ( ' Редактор позволяет редактировать битовые поля' );
     WRITELN ( 'перемещением курсора при помощи функциональной' );
     WRITELN ( 'клавиатуры или мышки. Доступны такие блоковые' );
     WRITELN ( 'операции, как копирование блока, запись блока' );
     WRITELN ( 'на диск и чтение блока с диска' );
     WRITELN ( ' Автор может помочь с перепрошивкой знакогенераторов' );
     WRITELN ( 'принтеров различных марок' );
     WRITELN ( 'г. Киев  тел. 441-40-81 ( сл )' )

END; { Procedure StartHelp }

{----------------------------------------------------------}

PROCEDURE SetFont;

          { Увстановка Файла шрифта }
BEGIN
     IF ( ( PARAMSTR ( 1 ) = '' ) OR ( PARAMSTR ( 1 ) = '/H' ) OR
        ( PARAMSTR ( 1 ) = '/h' ) ) THEN
        BEGIN
             StartHelp;
             HALT ( 1 )
        END;
     NameFont := PARAMSTR ( 1 );
     ASSIGN ( Fl, NameFont );
     RESET ( Fl, 1 );
     IF ( IORESULT <> 0 ) THEN
        BEGIN
             WRITELN;
             WRITELN ( 'Ошибка открытия файла шрифта' );
             HALT ( 1 )
        END;

     SizeFont := FILESIZE ( Fl )

END; { procedure SetFont }

{----------------------------------------------------------}

PROCEDURE ReadBuffer;

          { Чтение в буффер }
BEGIN
     SEEK ( Fl, Counter );
     BLOCKREAD ( Fl, ScreenBuf, MaxScreen );
     IF ( IORESULT <> 0 ) THEN
        War ( 'Ошибка чтения файла' )

END; { procedure ReadBuffer }

{----------------------------------------------------------}

PROCEDURE WriteBuffer;

          { Запись в буффер }
BEGIN
     IF ( SingWrite ) THEN
        BEGIN
             SEEK ( Fl, Counter );
             BLOCKWRITE ( Fl, ScreenBuf, MaxScreen );
             IF ( IORESULT <> 0 ) THEN
                 War ( 'Ошибка записи изменений' );
             SingWrite := FALSE
        END

END; { procedure WriteBuffer }

{----------------------------------------------------------}

PROCEDURE SetScreen;

          { Установка экрана }
BEGIN
     WINDOW ( 1, 1, 80, 25 );
     TEXTBACKGROUND ( BLACK );
     CLRSCR;
     TEXTCOLOR ( LIGHTCYAN );
     GOTOXY ( 1, 14 );
     WRITELN ( '     '+ #27 + ' , ' + #26 +' , ' + #24 + ' , ' + #25 +
               ' /или mouse /  - Перемещение указателя в переделах экрана' );
     WRITELN ( '     Ctrl+ '+ #27 + ' ,Ctrl+ ' + #26 +
               ' - Сдвиг экрана на позицию шрифта ' );
     WRITELN ( '     Enter /или лев. клавиша mouse /- Инвертирование пикселя' );
     WRITELN ( '     ESC - Выход и запись изменений' );
     WRITELN ( '     Ctrl-KB - Отметка начала блока, Ctrl-KK - конца блока' );
     WRITELN ( '     Ctrl-KH - Отмена блока, Ctrl-KC - Копирование блока' );
     WRITELN ( '     Ctrl-KW - Запись блока, Ctrl-KR - Чтение блока' );
     TEXTCOLOR ( MAGENTA );
     GOTOXY ( 1, 25 );
     WRITE ( '    Редактор шрифтов  V 1.0       (c) 1992 Ярослав Мигач' )

END; { procedure SetScreen }

{----------------------------------------------------------}

PROCEDURE ChangeInf;

VAR
   Key : BOOLEAN;
   Mask : BYTE;

BEGIN
     SingWrite := TRUE;
     CASE CurrentBit OF
             1 : Mask := $01;
             2 : Mask := $02;
             3 : Mask := $04;
             4 : Mask := $08;
             5 : Mask := $10;
             6 : Mask := $20;
             7 : Mask := $40;
             8 : Mask := $80
     END;
     IF ( ( ScreenBuf [ CurrentByte ] AND Mask ) <> 0 ) THEN
        BEGIN
             WRITE ( ' ' );
             ScreenBuf [ CurrentByte ] := ScreenBuf [ CurrentByte ]
                                          AND ( NOT Mask )
        END
     ELSE
         BEGIN
              WRITE ( #04 );
             ScreenBuf [ CurrentByte ] := ScreenBuf [ CurrentByte ]
                                          OR Mask
         END;
     SetCursor

END; { PROCEDURE ChangeInf }

{----------------------------------------------------------}

PROCEDURE BitLeft;

          { На бит влево }
BEGIN
     CASE Orient OF
            1 : BEGIN
                     DEC ( CurrentBit );
                     IF ( CurrentBit < 1 ) THEN
                        CurrentBit := 1
                END;
            2 : BEGIN
                     INC ( CurrentBit );
                     IF ( CurrentBit > 8 ) THEN
                        CurrentBit := 8
                END
     END;
     SetCursor

END; { procedure BitLeft }

{----------------------------------------------------------}

PROCEDURE BitRight;

          { На бит вghfво }
BEGIN
     CASE Orient OF
            1 : BEGIN
                     INC ( CurrentBit );
                     IF ( CurrentBit > 8 ) THEN
                        CurrentBit := 8
                END;
            2 : BEGIN
                     DEC ( CurrentBit );
                     IF ( CurrentBit < 1 ) THEN
                        CurrentBit := 1
                END
     END;
     SetCursor

END; { procedure BitRight }

{----------------------------------------------------------}

PROCEDURE ByteLeft;

          { На байт влево }
BEGIN
     CASE Orient OF
            1 : BEGIN
                     DEC ( CurrentByte );
                     IF ( CurrentByte < 1 ) THEN
                        CurrentByte := 1
                END;
            2 : BEGIN
                     DEC ( CurrentByte );
                     IF ( CurrentByte < 1 ) THEN
                        CurrentByte := 1
                END
     END;
     SetCursor

END; { procedure ByteLeft }

{----------------------------------------------------------}

PROCEDURE ByteRight;

          { На байт вправо }
BEGIN
     CASE Orient OF
            1 : BEGIN
                     INC ( CurrentByte );
                     IF ( CurrentByte > MaxScreen ) THEN
                        CurrentByte := MaxScreen
                END;
            2 : BEGIN
                     INC ( CurrentByte );
                     IF ( CurrentByte > MaxScreen ) THEN
                        CurrentByte := MaxScreen
                END
     END;
     SetCursor

END; { procedure ByteRight }

{----------------------------------------------------------}

PROCEDURE SymbolLeft;

          { На символ влево }
BEGIN
     IF ( Counter <= StartAddres ) THEN
        EXIT;
     WriteBuffer;
     Counter := Counter - SizeYFont * SizeXFont;
     IF ( Counter < StartAddres ) THEN
        Counter := StartAddres;
     ReadBuffer;
     ShowFont

END; { PROCEDURE SymbolLeft }

{----------------------------------------------------------}

PROCEDURE SymbolRight;

          { На символ вправо }
BEGIN
     IF ( ( Counter + SizeXFont * SizeYFont ) >= SizeFont ) THEN
        EXIT;
     WriteBuffer;
     Counter := Counter + SizeYFont * SizeXFont;
     IF ( ( Counter + SizeXFont * SizeYFont ) > SizeFont ) THEN
        Counter := SizeFont - SizeYFont * SizeXFont;
     ReadBuffer;
     ShowFont

END; { PROCEDURE SymbolRight }

{----------------------------------------------------------}

PROCEDURE Init;

          { Инициализация файла шрифта и переменных редактирования }
BEGIN
     SetUp;
     SetFont;
     ReadBuffer;
     SetScreen

END; { procedure Init }

{----------------------------------------------------------}

PROCEDURE SetBegin;

          { Установить маркер начала блока }
BEGIN
     BlockBegin := Counter + CurrentByte - 1

END; { PROCEDURE SetBegin }

{----------------------------------------------------------}

PROCEDURE SetEnd;

          { Установить маркер конца блока }
BEGIN
     BlockEnd := Counter + CurrentByte - 1

END; { PROCEDURE SetEnd }

{----------------------------------------------------------}

PROCEDURE HideBlock;

          { Погасить блок }
BEGIN
     BlockBegin := -1;
     BlockEnd := -1

END; { PROCEDURE HideBlock }

{----------------------------------------------------------}

PROCEDURE CopyBlock;

         { Копировать блок }
VAR
   Buf : POINTER;
   Size : LONGINT;

BEGIN
     IF ( ( BlockBegin > BlockEnd ) OR ( BlockBegin < 0 )
          OR ( BlockEnd < 0 ) ) THEN
        BEGIN
             SOUND ( 1000 );
             DELAY ( 100 );
             NOSOUND;
             EXIT
        END;
      GETMEM ( Buf, BlockEnd - BlockBegin + 1 );
      WriteBuffer;
      SEEK ( Fl, BlockBegin );
      BLOCKREAD ( Fl, Buf^, BlockEnd - BlockBegin + 1 );
      IF ( IORESULT <> 0 ) THEN
         War ( 'Ошибка чтения  блока из файла' );
      SEEK ( Fl, Counter + CurrentByte - 1 );
      BLOCKWRITE ( Fl, Buf^, BlockEnd - BlockBegin + 1 );
      IF ( IORESULT <> 0 ) THEN
         War ( 'Ошибка записи блока в файл' );
      FREEMEM ( Buf, BlockEnd - BlockBegin + 1 );
      ReadBuffer;
      Size := BlockEnd - BlockBegin;
      BlockBegin := Counter + CurrentByte - 1;
      BlockEnd := BlockBegin + Size

END; { PROCEDURE СорBlock }

{----------------------------------------------------------}

FUNCTION GetFileName : STRING;

         { Запрос имени файла }
VAR
   Line : STRING;

BEGIN
     TEXTBACKGROUND ( BLACK );
     TEXTCOLOR ( WHITE );
     GOTOXY ( 30, 23 );
     WRITE ( 'Введите имя файла >' );
     READLN ( Line );
     GOTOXY ( 1, 23 );
     WRITE ( '                                                         ' );
     GetFileName := Line

END;  { FUNCTION GetFileName }

{----------------------------------------------------------}

PROCEDURE WriteBlock;

          { Записать блок }
VAR
   Ft : FILE;
   Name : STRING;
   Buf : POINTER;

BEGIN
     IF ( ( BlockBegin > BlockEnd ) OR ( BlockBegin < 0 )
          OR ( BlockEnd < 0 ) ) THEN
        BEGIN
             SOUND ( 1000 );
             DELAY ( 100 );
             NOSOUND;
             EXIT
        END;

     TEXTBACKGROUND ( BLACK );
     TEXTCOLOR ( LIGHTGREEN );
     GOTOXY ( 1, 23 );
     WRITE ( 'Запись блока' );
     Name := GetFileName;
     ASSIGN ( Ft, Name );
     REWRITE ( Ft, 1 );
     IF ( IORESULT <> 0 ) THEN
        BEGIN
             War ( 'Ошибка создания файла' );
             EXIT
        END;
      GETMEM ( Buf, BlockEnd - BlockBegin + 1 );
      SEEK ( Fl, BlockBegin );
      BLOCKREAD ( Fl, Buf^, BlockEnd - BlockBegin + 1 );
      IF ( IORESULT <> 0 ) THEN
         War ( 'Ошибка чтения блока' );
      BLOCKWRITE ( Ft, Buf^, BlockEnd - BlockBegin + 1 );
      IF ( IORESULT <> 0 ) THEN
         War ( 'Ошибка записи блока в файл' );
      FREEMEM ( Buf, BlockEnd - BlockBegin + 1 );
      CLOSE ( Ft );
      IF ( IORESULT <> 0 ) THEN
         War ( 'Ошибка закрытия созданного файла' )

END; { PROCEDURE WriteBlock }

{----------------------------------------------------------}

PROCEDURE ReadBlock;

          { Считать блок }
VAR
   Ft : FILE;
   Name : STRING;
   Buf : POINTER;

BEGIN
     WriteBuffer;
     TEXTBACKGROUND ( BLACK );
     TEXTCOLOR ( LIGHTGREEN );
     GOTOXY ( 1, 23 );
     WRITE ( 'Чтение блока' );
     Name := GetFileName;
     ASSIGN ( Ft, Name );
     RESET ( Ft, 1 );
     IF ( IORESULT <> 0 ) THEN
        BEGIN
             War ( 'Нет такого файла' );
             EXIT
        END;
      IF ( ( FILESIZE ( Ft ) < 1 ) OR
           ( FILESIZE ( Ft ) >= $FFFE ) ) THEN
         BEGIN
              War ( 'Ошибочный формат файла' );
              EXIT
         END;
      GETMEM ( Buf, FILESIZE ( Ft ) );
      BLOCKREAD ( Ft, Buf^, FILESIZE ( Ft ) );
      IF ( IORESULT <> 0 ) THEN
         War ( 'Ошибка чтения файла' );
      SEEK ( Fl, Counter + CurrentByte - 1 );
      BLOCKWRITE ( Fl, Buf^, FILESIZE ( Ft ) );
      IF ( IORESULT <> 0 ) THEN
         War ( 'Ошибка записи блока в файл' );
      BlockBegin := Counter + CurrentByte - 1;
      BlockEnd := BlockBegin + FILESIZE ( Ft ) - 1;
      FREEMEM ( Buf, FILESIZE ( Ft ) );
      CLOSE ( Ft );
      IF ( IORESULT <> 0 ) THEN
         War ( 'Ошибка закрытия файла' );
      ReadBuffer

END; { PROCEDURE ReadBlock }

{----------------------------------------------------------}

PROCEDURE BlockOperation;

          { Блоковые операции }
VAR
   Index : WORD;

BEGIN
     CASE GetCommand OF

             #27             : EXIT;

             'B','b','и','И' : SetBegin;

             'K','k','л','Л' : SetEnd;

             'H','h','Р','р' : HideBlock;

             'C','c','С','с' : CopyBlock;

             'W','w','Ц','ц' : WriteBlock;

             'R','r','К','к' : ReadBlock

     ELSE
         BEGIN
              FOR Index := 2000 DOWNTO 200 DO
                  BEGIN
                       SOUND ( Index );
                       IF ( ( Index MOD 4 ) = 0 ) THEN
                          DELAY ( 1 )
                  END;
              NOSOUND
         END
     END;
     ShowFont

END; { procedure BlockOperation }

{----------------------------------------------------------}

PROCEDURE EditFont;

          { Просмотр и редактирование файла шрифта }
BEGIN
     CASE GetCommand OF

          #11             : BlockOperation;

          #13             : ChangeInf;

          #27             : KeyExit := TRUE;

          Arrow_Down      : BitLeft;

          Arrow_Up        : BitRight;

          Arrow_Left      : ByteLeft;

          Arrow_Right     : ByteRight;

          Ctl_Arrow_Left  : SymbolLeft;

          Ctl_Arrow_Right : SymbolRight

     ELSE
         BEGIN
              SOUND ( 1000 );
              DELAY ( 100 );
              NOSOUND
         END
     END

END; { procedure EditFont }

{----------------------------------------------------------}

PROCEDURE Done;

          { Сохранение отредактированного файла шрифта }
BEGIN
     WriteBuffer;
     CLOSE ( Fl );
     IF ( IORESULT <> 0 ) THEN
        War ( 'Ошибка закрытия файла' );
     TEXTCOLOR ( LIGHTGRAY );
     TEXTBACKGROUND ( BLACK );
     GOTOXY ( 1, 25 );
     WRITELN

END; { procedure Done }

{----------------------------------------------------------}

BEGIN
     Init;
     ShowFont;
     REPEAT
           EditFont
     UNTIL ( KeyExit );
     Done

END. { PROGRAM Edit_Pronter_Font }
