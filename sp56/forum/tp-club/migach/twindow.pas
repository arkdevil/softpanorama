

               {----------------------------------------------}
               {  Модуль TWindow V 2.1  пакета  TURBO SUPPORT }
               {  Язык программирования Turbo Pascal V 7.0    }
               {----------------------------------------------}
               { Дата создания : 08/08/1991                   }
               { Дата последних изменений : 02/04/1993        }
               {----------------------------------------------}
               {      Модуль включает в себя обьект для       }
               {  работы с динамически создаваемыми окнами    }
               {----------------------------------------------}
               { (c) 1989-1993, Мигач Ярослав                 }
               {----------------------------------------------}

UNIT TWindow;

{$IFDEF DEBUGWINDOW}
      {$D+,L+,R+,S+}
{$ELSE}
      {$D-,L-,R-,S-}
{$ENDIF}

{$F+,O+,I-,V-,B-,A+}

INTERFACE

USES Crt, Dos, Def;

TYPE
    Location = ARRAY [ 1..80*25 ] OF RECORD
                                            ch : CHAR;
                                            at : BYTE
                                      END;
                { расположение символов и атрибутов в экранной области }


    TextWindowPtr = ^TextWindow;

    TextWindow = OBJECT { обьект текстового окна }

                 ColorFon : BYTE;   { цвет фона окна }

                 ColorSym : BYTE;   { цвет символов в окне }

                 AttrWindow : BYTE;
                            { текущий атрибут окна }

                 Wx1,Wy1,Wx2,Wy2 : BYTE; { координаты окна }

                 OldPic : ^location; { старый экран }

                 Pic : ^location;    { текстовый образ окна }

                 Sx, Sy : BYTE; { размер окна по осям }

                 SingShade : BOOLEAN; { признак тени }

                 FonShade, SymShade, AttrShade : BYTE;
                                      { цветовые атрибуты тени }

                 ClearEdit : BOOLEAN;
                            { Признак удаления информации при редактировании }

                 SingColorEdit : BOOLEAN;
                            { признак установки цвета редактирования }

                 ColorEditFon : BYTE;
                            { цвет фона редактирования }

                 ColorEditSymbol : BYTE;
                            { цвет символов редактирования }

                 ColorEditClearFon : BYTE;
                            { цвет фона возможного удаления }

                 ColorEditClearSymbol : BYTE;
                            { цвет символов возможного удаления }

                 TypeEdit : BYTE;
                            { возможный тип редактирования  }

                 SingInsert : BOOLEAN;
                            { режим вставки/ замещения }

                 OldScreen : BOOLEAN;
                            { Признак старого экрана }

                 MaskEditChar : CHAR;
                            { Маска редактирования }

                 CONSTRUCTOR MakeWindow ( kx1, ky1, kx2, ky2 : BYTE;
                                          col_fon,col_sym : BYTE );
                           { инициализировать обьект, запомнить
                             информацию под создаваемым окном   }

                 PROCEDURE SetPic ( x,y : BYTE; ch : CHAR; at : BYTE );
                           { установить пиксель в образ окна }

                 PROCEDURE GetPic ( x,y : BYTE; VAR ch : CHAR; VAR at : BYTE );
                           { получить пиксель из образа окна }

                 PROCEDURE SetOldPic ( x,y : BYTE; ch : CHAR; at : BYTE );
                           { установить пиксель в образ под окном }

                 PROCEDURE GetOldPic ( x,y : BYTE; VAR ch : CHAR;
                                       VAR at : BYTE );
                           { получить пиксель из под образа окна }

                 PROCEDURE SetColorSymbol ( Sym : BYTE );
                           { установить цвет символов в окне }

                 PROCEDURE SetColorFon ( fon : BYTE );
                           { установить цвет фона в окне }

                 PROCEDURE WChar ( x,y : BYTE; ch : CHAR );
                           { вывести символ в образ окна }

                 PROCEDURE XYChar ( x,y : BYTE; ch : CHAR );
                           { выести символ на экран в окно }

                 PROCEDURE WXYChar ( x,y : BYTE; ch : CHAR );
                           { вывести символ на экран и в образ окна }

                 PROCEDURE WPrint ( x, y : BYTE; stroka : StandartString );
                           { вывести строку в образ окна }

                 PROCEDURE XYPrint ( x, y : BYTE; stroka : StandartString );
                           { вывести строку на экран в окно }

                 PROCEDURE WXYPrint ( x, y : BYTE; stroka : StandartString );
                           { вывести строку в образ окна и на экран }

                 PROCEDURE LoadChar ( x, y : BYTE; VAR ch : CHAR;
                                      VAR at : BYTE );
                           { прочесть символ из окна }

                 PROCEDURE XYEdit ( x, y : BYTE; VAR ch : CHAR; ln : BYTE;
                                  VAR stroka : StandartString );
                           { редактировать строку в окне }

                 PROCEDURE PrintWindow;
                           { отпечатать окно }

                 PROCEDURE ClearWindow ( Ch : CHAR; Fon, Sym : BYTE );
                           { заполнить образ окна }

                 PROCEDURE Conout ( x, y, key : BYTE; ch : CHAR );
                           { вывести символ по заданному направлению }

                 PROCEDURE LineY ( x, y1, y2,pointer, key : BYTE; ch : CHAR );
                           { Вывести вертикальную линию }

                 PROCEDURE LineX ( y, x1, x2,pointer, key : BYTE; ch : CHAR );
                           { вывести горизонтальную линию }

                 PROCEDURE FrameWindow ( kx1, ky1, kx2, ky2, key : BYTE;
                                         ch : CHAR );
                           { вывести рамку в окно }

                 PROCEDURE TypeFrameWindow ( ch : CHAR );
                           { печатать окно с разворотом рамки }

                 PROCEDURE TypeOldScreen;
                           { печатать информацию бывшую под окном }

                 PROCEDURE MoveWindow ( x, y : BYTE );
                           { переместить окно }

                 PROCEDURE SetShade ( fon, sym : BYTE );
                           { установить тень }

                 PROCEDURE Cursor ( x,y : BYTE );
                           { дать курсор по координатам }

                 PROCEDURE SetInsEdit;
                           { установить режим вставки для редактирования }

                 PROCEDURE ReSetInsEdit;
                           { установить режим замещения для редактирования }

                 PROCEDURE SetClearEdit;
                           { установить режим первичного стирания в редакторе }

                 PROCEDURE SetColorEdit ( fon, sym : BYTE );
                           { установить цвета мини-редактора }

                 PROCEDURE SetColorClearEdit ( fon, sym : BYTE );
                           { установить цвета первоначального стирания }

                 PROCEDURE ReSetColorEdit;
                           { сбросить цвета редактирования }

                 PROCEDURE SetTypeEdit ( tp : BYTE );
                           { установить тип редактирования }

                 PROCEDURE SetMaskEdit ( Msk : CHAR );
                           { Установить маску для редактирования }
                           { Пробел - отсутствие маски           }

                 PROCEDURE ReadData ( x, y : BYTE;
                                      VAR Stroka : StandartString );
                           { ввести дату }

                 DESTRUCTOR Done;
                           { уничтожить окно }

                 DESTRUCTOR UnFrameDone ( ch : CHAR );
                           { уничтожить с сверткой рамки }

                 DESTRUCTOR TypeDone;
                           { уничтожить с печатью старой информации }

                 END; { object TextWindow }

{----------------------------------------------------------}

PROCEDURE SetBackGround16;
          { установить 16 фоновых цветов /EGA/VGA }

PROCEDURE SetBackGround8;
          { установить 8 фоновых цветов }

PROCEDURE HideCursor;
          { погасить курсор }

FUNCTION RushLardg ( ch : CHAR ) : CHAR;
          { преобразование в только русские большие }

FUNCTION RushNumLardg ( ch : CHAR ) : CHAR;

FUNCTION RushAll ( ch : CHAR ) : CHAR;
          { преобразовать в русские маленькие и большие }

IMPLEMENTATION

VAR
   Rg : REGISTERS;

{----------------------------------------------------------}

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

{----------------------------------------------------------}

PROCEDURE FatalError ( Line : STRING );

BEGIN
     Window ( 1, 1, 80, 25 );
     TEXTBACKGROUND ( BLACK );
     TEXTCOLOR ( LIGHTGRAY );
     CLRSCR;
     WRITELN ( #07 );
     WRITELN ( 'Критический сбой в обьекте Text Window' );
     WRITELN ( Line );
     WRITELN ( 'Выполнение программы прекращается,'
              ,' обращайтесь к программисту' );
     HALT ( 1 )

END; { procedure FatalError }

{----------------------------------------------------------}

PROCEDURE SetWindow ( X1, Y1, X2, Y2 : BYTE );

          { Установка параметров окна }
BEGIN
     WindMin := ( Y1 - 1 ) * $100 + ( X1 - 1 );
     WindMax := ( Y2 - 1 ) * $100 + ( X2 - 1 )

END; { procedure SetWindow }

{----------------------------------------------------------}

PROCEDURE WCalc ( lnx, lny : BYTE;
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

END; { procedure Wcalc }

{----------------------------------------------------------}

PROCEDURE SetBackGround16;

          { установить 16 фоновых цветов /EGA/VGA }
BEGIN
     rg.AH := $10;
     rg.AL := 03;
     rg.BL := 0;
     INTR ( $10, rg )

END; { procedure SetBackGround16 }

{----------------------------------------------------------}

PROCEDURE SetBackGround8;

          { установить 8 фоновых цветов }
BEGIN
     rg.AH := $10;
     rg.AL := 03;
     rg.BL := 1;
     INTR ( $10, rg )

END; { procedure SetBackGround8 }

{----------------------------------------------------------}

PROCEDURE HideCursor;

          { погасить курсор }
BEGIN
      rg.AH := 02;
      rg.BH := 0;
      rg.DH := 25;
      rg.DL := 0;
      INTR ( $10, rg )

END; { procedure HideCursor }

{----------------------------------------------------------}

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

{----------------------------------------------------------}

FUNCTION RushNumLardg ( ch : CHAR ) : CHAR;

         { функция возвращает только русские большие буквы и цифры }
         {        независимо от регистра нажатой клавиши           }

BEGIN
     CASE ch OF
        ' '             : RushNumLardg  :=    ' ';
        'q','Q','й','Й' : RushNumLardg  :=    'Й';
        'w','W','ц','Ц' : RushNumLardg  :=    'Ц';
        'e','E','у','У' : RushNumLardg  :=    'У';
        'r','R','к','К' : RushNumLardg  :=    'К';
        't','T','е','Е' : RushNumLardg  :=    'Е';
        'y','Y','н','Н' : RushNumLardg  :=    'Н';
        'u','U','г','Г' : RushNumLardg  :=    'Г';
        'i','I','ш','Ш' : RushNumLardg  :=    'Ш';
        'o','O','щ','Щ' : RushNumLardg  :=    'Щ';
        'p','P','з','З' : RushNumLardg  :=    'З';
        '[','{','х','Х' : RushNumLardg  :=    'Х';
        'a','A','ф','Ф' : RushNumLardg  :=    'Ф';
        's','S','ы','Ы' : RushNumLardg  :=    'Ы';
        'd','D','в','В' : RushNumLardg  :=    'В';
        'f','F','а','А' : RushNumLardg  :=    'А';
        'g','G','п','П' : RushNumLardg  :=    'П';
        'h','H','р','Р' : RushNumLardg  :=    'Р';
        'j','J','о','О' : RushNumLardg  :=    'О';
        'k','K','л','Л' : RushNumLardg  :=    'Л';
        'l','L','д','Д' : RushNumLardg  :=    'Д';
        ';',':','ж','Ж' : RushNumLardg  :=    'Ж';
        '''','"','э','Э': RushNumLardg  :=    'Э';
        'z','Z','я','Я' : RushNumLardg  :=    'Я';
        'x','X','ч','Ч' : RushNumLardg  :=    'Ч';
        'c','C','с','С' : RushNumLardg  :=    'С';
        'v','V','м','М' : RushNumLardg  :=    'М';
        'b','B','и','И' : RushNumLardg  :=    'И';
        'n','N','т','Т' : RushNumLardg  :=    'Т';
        'm','M','ь','Ь' : RushNumLardg  :=    'Ь';
        ',','<','б','Б' : RushNumLardg  :=    'Б';
        '.','>','ю','Ю' : RushNumLardg  :=    'Ю'
     ELSE
         IF ( ch IN [ '0'..'9' ] ) THEN
            RushNumLardg := ch
         ELSE
             RushNumLardg := CHR ( 0 )
     END

END; { function RushNumLardg }

{----------------------------------------------------------}


{----------------------------------------------------------}

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
        '.','ю' : RushAll :=   'ю';
        '/','?' : RushAll :=   '/'
     ELSE
         IF ( ch IN [ '1','2','3','4','5','6','7','8','9','0','-','=',
                      '\','!','@','#','$','%','^','&','*','(',')','_',
                      '+','|' ] ) THEN
            RushAll := ch
         ELSE
             RushAll := CHR ( 0 )
     END

END; { function RushAll }

{==========================================================}

CONSTRUCTOR TextWindow.MakeWindow ( kx1, ky1, kx2, ky2 : BYTE;
                         col_fon,col_sym : BYTE );

           { инициализировать обьект, запомнить
             информацию под создаваемым окном   }
VAR
   Indx_X, Indx_Y : BYTE;

BEGIN
     IF ( ( ( kx1 < 1 ) OR ( kx1 > 80 ) OR ( ky1 < 1 ) OR ( ky1 > 25 ) ) OR
        ( ( kx2 < kx1 ) OR ( kx2 > 80 ) OR ( ky2 < ky1 ) OR ( ky2 > 25 ) ) )
        THEN
        FatalError ( 'Неправильно заданны координаты размещения для MakeWindow' );
      Wx1 := kx1;
      Wy1 := ky1;
      Wx2 := kx2;
      Wy2 := ky2;
      SetWindow ( Wx1, Wy1, Wx2, Wy2 );
      sx := Wx2 - Wx1 + 1;
      sy := Wy2 - Wy1 + 1;
      GETMEM ( Pic, ( 2 * sx * sy ) );
      GETMEM ( OldPic, ( 2 * sx * sy ) );
      ReadWin ( OldPic^ );
      ColorFon := col_fon;
      ColorSym := col_sym;
      SingShade := FALSE;
      FonShade := BLACK;
      SymShade := WHITE;
      AttrShade := FonShade * 16 + SymShade;
      SetColorFon ( ColorFon );
      SetColorSymbol ( ColorSym );
      MaskEditChar := ' ';
      FOR indx_x := 1 TO sx DO
          FOR indx_y := 1 TO sy DO
              SetPic ( indx_x, indx_y, ' ', AttrWindow );
     SingInsert := TRUE;
     ClearEdit := FALSE;
     SingColorEdit := FALSE;
     TypeEdit := 0;
     OldScreen := FALSE;
     HideCursor

END; { constructor TextWindow.MakeWindow }

{-------------------------------------------------------------------------}

PROCEDURE TextWindow.SetPic ( x,y : BYTE; ch : CHAR; at : BYTE );

          { установить пиксель в образ окна }
VAR
   indx : INTEGER;

BEGIN
     indx := ( y - 1 ) * Sx + x;
     Pic^[ indx ].ch := ch;
     Pic^[ indx ].at := at

END; { procedure TextWindow.SetPic }

{-------------------------------------------------------------------------}

PROCEDURE TextWindow.GetPic ( x,y : BYTE; VAR ch : CHAR; VAR at : BYTE );

          { получить пиксель из образа окна }
VAR
   indx : INTEGER;

BEGIN
     indx := ( y - 1 ) * sx + x;
     ch := Pic^[ indx ].ch;
     at := Pic^[ indx ].at

END; { procedure TextWindow.GetPic }

{-------------------------------------------------------------------------}

PROCEDURE TextWindow.SetOldPic ( x,y : BYTE; ch : CHAR; at : BYTE );

          { установить пиксель в образ под окном }
VAR
   indx : INTEGER;

BEGIN
     indx := ( y - 1 ) * sx + x;
     OldPic^[ indx ].ch := ch;
     OldPic^[ indx ].at := at

END; { procedure TextWindow.SetOldPic }

{-------------------------------------------------------------------------}

PROCEDURE TextWindow.GetOldPic ( x,y : BYTE; VAR ch : CHAR; VAR at : BYTE );

         { получить пиксель из под образа окна }
VAR
   indx : INTEGER;

BEGIN
     indx := ( y - 1 ) * sx + x;
     ch := OldPic^[ indx ].ch;
     at := OldPic^[ indx ].at

END; { procedure TextWindow.GetOldPic }

{----------------------------------------------------------}

PROCEDURE TextWindow.SetColorSymbol ( Sym : BYTE );

          { установить цвет символов в окне }
BEGIN
     ColorSym := Sym;
     AttrWindow := ColorFon * 16 + Sym

END; { procedure TextWindow.SetColorSymbol }

{----------------------------------------------------------}

PROCEDURE TextWindow.SetColorFon ( fon : BYTE );

          { установить цвет фона в окне }
BEGIN
     ColorFon := Fon;
     AttrWindow := Fon * 16 + ColorSym

END; { procedure TextWindow.SetColorFon }

{----------------------------------------------------------}

PROCEDURE TextWindow.WChar ( x,y : BYTE; ch : CHAR );

          { вывести символ в образ окна }
BEGIN
     SetPic ( x, y, ch, AttrWindow )

END; { procedure TextWindow.WChar }

{----------------------------------------------------------}

PROCEDURE TextWindow.XYChar ( x,y : BYTE; ch : CHAR );

          { выести символ на экран в окно }
BEGIN
     SetWindow ( Wx1, Wy1, Wx2, Wy2 );
     WriteChar ( X, Y, 1, Ch, AttrWindow )

END; { procedure TextWindow.XYChar }

{----------------------------------------------------------}

PROCEDURE TextWindow.WXYChar ( x,y : BYTE; ch : CHAR );

          { вывести символ на экран и в образ окна }
BEGIN
     SetPic ( x, y, ch, AttrWindow );
     SetWindow ( Wx1, Wy1, Wx2, Wy2 );
     WriteChar ( X, Y, 1, Ch, AttrWindow )

END; { procedure TextWindow.WXYChar }

{----------------------------------------------------------}

PROCEDURE TextWindow.WPrint ( x, y : BYTE; stroka : StandartString );

          { вывести строку в образ окна }
VAR
   indx : INTEGER; { индексная переменная }

BEGIN
     WHILE ( LENGTH ( stroka ) > ( sx - x + 1 ) ) DO
           DELETE ( Stroka, LENGTH ( Stroka ), 1 );
     FOR indx := 1 TO LENGTH ( Stroka ) DO
         WChar ( x + indx - 1, y, stroka [ indx ] )

END; { procedure TextWindow.WPrint }

{----------------------------------------------------------}

PROCEDURE TextWindow.XYPrint ( x, y : BYTE; stroka : StandartString );

          { вывести строку на экран в окно }
BEGIN
     SetWindow ( Wx1, Wy1, Wx2, Wy2 );
     WriteStr ( X, Y, Stroka, AttrWindow )

END; { procedure TextWindow.XYPrint }

{----------------------------------------------------------}

PROCEDURE TextWindow.WXYPrint ( x, y : BYTE; stroka : StandartString );

          { вывести строку в образ окна и на экран }
VAR
   indx : INTEGER; { индексная переменная }

BEGIN
     SetWindow ( Wx1, Wy1, Wx2, Wy2 );
     WHILE ( LENGTH ( stroka ) > ( sx - x + 1 ) ) DO
           DELETE ( Stroka, LENGTH ( Stroka ), 1 );
     FOR indx := 1 TO LENGTH ( Stroka ) DO
         WChar ( x + indx - 1, y, stroka [ indx ] );
     WriteStr ( X, Y, Stroka, AttrWindow )

END; { procedure TextWindow.WXYPrint }

{----------------------------------------------------------}

PROCEDURE TextWindow.LoadChar ( x, y : BYTE; VAR ch : CHAR; VAR at : BYTE );

          { прочесть символ из окна }
BEGIN
     GetPic ( x, y, ch, at )

END; { procedure TextWindow.LoadChar }

{----------------------------------------------------------}

PROCEDURE TextWindow.SetMaskEdit ( Msk : CHAR );

          { Установить маску для редактирования }
          { Пробел - отсутствие маски           }
BEGIN
     MaskEditChar := Msk

END; { procedure TextWindow.SetMaskEdit }

{----------------------------------------------------------}

PROCEDURE TextWindow.XYEdit ( x, y : BYTE; VAR ch : CHAR; ln : BYTE;
                                  VAR stroka : StandartString );

          { редактировать строку в окне }
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
   help : StandartString;
   Index : BYTE;

PROCEDURE quit;

VAR
   Index : BYTE;

BEGIN
     SetColorFon ( ColorFon );
     SetColorSymbol ( ColorSym );
     XYPrint ( x, y, help );
     XYPrint ( x, y, stroka );
     FOR Index := 1 TO LENGTH ( Stroka ) DO
         XYChar ( X + Index - 1, y , MaskEditChar );
     WHILE ( ( LENGTH ( stroka ) <> 0 ) AND
           ( stroka [ LENGTH ( stroka ) ] = ' ' ) ) DO
           DELETE ( stroka, LENGTH ( stroka ), 1 );
     HideCursor

END; { procedure quit }

PROCEDURE SetSymbol;

BEGIN
     IF ( ClearEdit ) THEN
        BEGIN
             stroka := '';
             kx := 1
        END;
     IF ( SingInsert ) THEN
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
                          SetColorFon ( ColorEditClearFon );
                          SetColorSymbol ( ColorEditClearSymbol )
                     END
                  ELSE
                      BEGIN
                           SetColorFon ( ColorEditFon );
                           SetColorSymbol ( ColorEditSymbol )
                      END;
                  XYPrint ( x, y, help );
            END;
            WHILE ( LENGTH ( stroka ) > ln ) DO
                  DELETE ( stroka, LENGTH ( stroka ), 1 );
            IF ( kx > ln ) THEN
               kx := LENGTH ( stroka );
            XYPrint ( x, y, stroka );
            IF ( MaskEditChar <> ' ' ) THEN
               FOR Index := 1 TO LENGTH ( Stroka ) DO
                   XYChar ( X + Index - 1, y , MaskEditChar );
            u := LENGTH ( stroka );
            WHILE ( u <> ln ) DO
                 BEGIN
                     XYChar ( ( x + u ), y, ' ' );
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

                     invs : SingInsert := NOT ( SingInsert );

                     del  : IF ( kx > 1 ) THEN
                               BEGIN
                                    DEC ( kx );
                                    DELETE ( stroka, kx, 1 )
                               END
                            ELSE
                                IF ( ( kx = 1 ) AND
                                     ( LENGTH ( stroka ) <> 0 ) ) THEN
                                     BEGIN
                                          Stroka := '';
                                          Kx := 1
                                     END;

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
                              END;

                        6  :  BEGIN
                                Ch := RushNumLardg ( Ch );
                                IF ( Ch <> #0 ) THEN
                                  SetSymbol
                              END
                END
            END;
        ClearEdit := FALSE;
        END

END; { procedure TextWindow.XYEdit }

{----------------------------------------------------------}

PROCEDURE TextWindow.PrintWindow;

          { отпечатать окно }
VAR
   e : ^TextScreen;
   x, y : BYTE;

BEGIN
     SetWindow ( 1, 1, 80, 25 );
     NEW ( e );
     ReadWin ( e^ );
     FOR y := Wy1 TO Wy2 DO
         FOR x := Wx1 TO Wx2 DO
             GetPic ( ( x - Wx1 + 1 ), ( y - Wy1 + 1 ),
                      e^ [ y, x ].ch, e^ [ y, x ].at );
     WriteWin ( e^ );
     DISPOSE ( e );
     SetColorSymbol ( ColorSym );
     SetColorFon ( ColorFon )

END; { procedure TextWindow.PrintWindow }

{----------------------------------------------------------}

PROCEDURE TextWindow.ClearWindow ( Ch : CHAR; Fon, Sym : BYTE );

          { заполнить образ окна }
VAR
  x, y, Attr : BYTE; { вспомогательные индексные переменные }

BEGIN
     Attr := Fon * 16 + Sym;
     FOR x := Wx1 TO Wx2 DO
        FOR y := Wy1 TO Wy2 DO
            SetPic ( ( x - Wx1 + 1 ), ( y - Wy1 + 1 ), Ch, Attr )

END; { procedure TextWindow.ClearWindow }

{----------------------------------------------------------}

PROCEDURE TextWindow.Conout ( x, y, key : BYTE; ch : CHAR );

          { вывести символ по заданному направлению }
BEGIN
     CASE key OF
          0 : XYChar ( x, y, ch );
          1 : WChar ( x, y, ch );
          2 : WXYChar ( x, y, ch )
     END

END; { procedure TextWindow.Conout }

{----------------------------------------------------------}

PROCEDURE TextWindow.LineY ( x, y1, y2,pointer, key : BYTE; ch : CHAR );

          { Вывести вертикальную линию }
VAR
   indx : BYTE; { индексная переменная }

BEGIN
     CASE pointer OF
            0  : FOR indx := y1 TO y2 DO
                   conout ( x, indx, key, ch );
            1  : FOR indx := y2 DOWNTO y1 DO
                   conout ( x, indx, key, ch )
     END

END; { procedure TextWindow.LineY }

{----------------------------------------------------------}

PROCEDURE TextWindow.LineX ( y, x1, x2,pointer, key : BYTE; ch : CHAR );

          { вывести горизонтальную линию }
VAR
   indx : BYTE; { индексная переменная }

BEGIN
     CASE pointer OF
            0  : FOR indx := x1 TO x2 DO
                   conout ( indx, y, key, ch );
            1  : FOR indx := x2 DOWNTO x1 DO
                   conout ( indx, y, key, ch )
     END

END; { procedure TextWindow.LineX }

{----------------------------------------------------------}

PROCEDURE TextWindow.FrameWindow ( kx1, ky1, kx2, ky2, key : BYTE; ch : CHAR );

          { вывести рамку в окно }
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

BEGIN
     FOR x := kx1 TO kx2 DO
         BEGIN
              IF ( OldScreen ) THEN
                 GetOldPic ( x, ky1, ch, at )
              ELSE
                  GetPic ( x, ky1, ch, at );
              WriteChar ( x, ky1, 1, ch, at )
         END;
     FOR y := ky1 TO ky2 DO
         BEGIN
              IF ( OldScreen ) THEN
                 GetOldPic ( kx2, y, ch, at )
              ELSE
                  GetPic ( kx2, y, ch, at );
              WriteChar ( kx2, y, 1, ch, at )
         END;
     FOR x := kx2 DOWNTO kx1 DO
         BEGIN
              IF ( OldScreen ) THEN
                 GetOldPic ( x, ky2, ch, at )
              ELSE
                  GetPic ( x, ky2, ch, at );
              WriteChar ( x, ky2, 1, ch, at )
         END;
     FOR y := ky2 DOWNTO ky1 DO
         BEGIN
              IF ( OldScreen ) THEN
                 GetOldPic ( kx1, y, ch, at )
              ELSE
                  GetPic ( kx1, y, ch, at );
              WriteChar ( kx1, y, 1, ch, at )
         END

END; { procedure ramka_old }

PROCEDURE rln ( ch1, ch2, ch3, ch4 : CHAR );
         { процедура рисования сторон рамки }
         {        заданными символами       }

BEGIN
     LineX ( ky1, kx1, kx2, 0, key, ch1 );
     LineY ( kx2, ky1, ky2, 0, key, ch2 );
     LineX ( ky2, kx1, kx2, 1, key, ch3 );
     LineY ( kx1, ky1, ky2, 1, key, ch4 )

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

     END { case }

END; { procedure TextWindow.FrameWindow }

{----------------------------------------------------------}

PROCEDURE TextWindow.TypeFrameWindow ( ch : CHAR );

          { печатать окно с разворотом рамки }
VAR
   knx1, kny1, knx2, kny2 : BYTE;
              { координаты начала движения рамки }

   lnx, lny : BYTE;
              { размеры окна по координатным осям }

BEGIN
    OldScreen := FALSE;
    lnx := Wx2 - Wx1 + 1;
    lny := Wy2 - Wy1 + 1;
    WCalc ( lnx, lny, knx1, kny1, knx2, kny2 );
    FrameWindow ( knx1, kny1, knx2, kny2, 0, ch );
    WHILE ( ( knx1 <> 1 ) AND ( kny1 <> 1 ) ) DO
          BEGIN
               DEC ( knx1 );
               DEC ( kny1 );
               INC ( knx2 );
               INC ( kny2 );
               FrameWindow ( knx1, kny1, knx2, kny2, 0, ch );
               FrameWindow ( ( knx1 + 1 ), ( kny1 + 1 ),
                               ( knx2 - 1 ), ( kny2 - 1 ), 0, CHR ( 0 ) )
          END;
    FrameWindow ( knx1, kny1, knx2, kny2, 1, ch )

END; { procedure TextWindow.TypeFrameWindow }

{----------------------------------------------------------}

PROCEDURE TextWindow.TypeOldScreen;

          { печатать информацию бывшую под окном }
VAR
   e : ^TextScreen;
   x, y : BYTE;

BEGIN
     SetWindow ( 1, 1, 80, 25 );
     NEW ( e );
     ReadWin ( e^ );
     FOR y := Wy1 TO Wy2 DO
         FOR x := Wx1 TO Wx2 DO
             GetOldPic ( ( x - Wx1 + 1 ), ( y - Wy1 + 1 ),
                         e^ [ y, x ].ch, e^ [ y, x ].at );
     WriteWin ( e^ );
     DISPOSE ( e );
     SetColorSymbol ( ColorSym );
     SetColorFon ( ColorFon );

END; { procedure TextWindow.TypeOldScreen }

{----------------------------------------------------------}

PROCEDURE TextWindow.MoveWindow ( x, y : BYTE );

          { переместить окно }
BEGIN
     IF ( ( x < 1 ) OR ( x > ( 80 - sx ) ) OR ( y < 1 ) OR
          ( y > ( 25 - sy ) ) ) THEN
         EXIT;
     TypeOldScreen;
     Wx1 := x;
     Wy1 := y;
     Wx2 := Wx1 + sx - 1;
     Wy2 := Wy1 + sy - 1;
     SetWindow ( Wx1, Wy1, Wx2, Wy2 );
     PrintWindow

END; { procedure TextWindow.MoveWindow }

{----------------------------------------------------------}

PROCEDURE TextWindow.SetShade ( fon, sym : BYTE );

          { установить тень }
VAR
   x, y : BYTE;
   ch : CHAR;
   at : BYTE;
   ad : BYTE;

BEGIN
     ad := fon * 16 + sym;
     AttrShade := ad;
     FonShade := fon;
     SymShade := sym;
     SingShade := TRUE;
     FOR x := 1 TO sx DO
         BEGIN
              GetOldPic ( x, sy, ch, at );
              IF ( x <> 1 ) THEN
                 at := ad;
              SetPic ( x, sy, ch, at )
         END;
     FOR y := 1 TO sy DO
         BEGIN
              GetOldPic ( sx, y, ch, at );
              IF ( y <> 1 ) THEN
                 at := ad;
              SetPic ( sx, y, ch, at )
         END

END; { procedure TextWindow.SetShade }

{----------------------------------------------------------}

PROCEDURE TextWindow.Cursor ( x,y : BYTE );

          { дать курсор по координатам }
BEGIN
     GOTOXY ( X, Y )

END; { procedure TextWindow.Cursor }

{----------------------------------------------------------}

PROCEDURE TextWindow.SetInsEdit;

          { установить режим вставки для редактирования }
BEGIN
     SingInsert := TRUE

END; { procedure TextWindow.SetInsEdit }

{----------------------------------------------------------}

PROCEDURE TextWindow.ReSetInsEdit;

          { установить режим замещения для редактирования }
BEGIN
     SingInsert := FALSE

END; { procedure TextWindow.ReSetInsEdit }

{----------------------------------------------------------}

PROCEDURE TextWindow.SetClearEdit;

          { установить режим первичного стирания в редакторе }
BEGIN
     ClearEdit := TRUE

END; { procedure TextWindow.SetClearEdit }

{----------------------------------------------------------}

PROCEDURE TextWindow.SetColorEdit ( fon, sym : BYTE );

          { установить цвета мини-редактора }
BEGIN
     SingColorEdit := TRUE;
     ColorEditFon := fon;
     ColorEditSymbol := sym;
     ColorEditClearFon := fon;
     ColorEditClearSymbol := sym

END; { procedure TextWindow.SetColorEdit }

{----------------------------------------------------------}

PROCEDURE TextWindow.SetColorClearEdit ( fon, sym : BYTE );

          { установить цвета первоначального стирания }
BEGIN
     ColorEditClearFon := fon;
     ColorEditClearSymbol := sym

END; { procedure TextWindow.SetColorClearEdit }

{----------------------------------------------------------}

PROCEDURE TextWindow.ReSetColorEdit;

          { сбросить цвета редактирования }
BEGIN
     SingColorEdit := FALSE

END; { procedure TextWindow.ReSetColorEdit }

{----------------------------------------------------------}

PROCEDURE TextWindow.SetTypeEdit ( tp : BYTE );

          {  установить тип редактирования }
          {  0 - строка                    }
          {  1 - простое число             }
          {  2 - вещественное число        }
          {  3 - простое со знаками        }
          {  4 - только русские большие    }
          {  5 - только русский алфавит    }
          {  6 - русские большие и цифры   }

BEGIN
     IF ( tp IN [ 0, 1, 2, 3, 4, 5, 6 ] ) THEN
        TypeEdit := tp

END; { procedure TextWindow.SetTypeEdit }

{----------------------------------------------------------}

PROCEDURE TextWindow.ReadData ( x, y : BYTE; VAR Stroka : StandartString );

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
   help : StandartString;
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
     HideCursor;
     IF ( LENGTH ( Stroka ) <> 6 ) THEN
        BEGIN
             Stroka := '';
             SingExit := FALSE;
             EXIT
        END;
     line := Stroka [ 1 ] + Stroka [ 2 ];
     VAL ( line, Day, err );
     IF ( ( err <> 0 ) OR ( Day < 1 ) OR ( Day > 31 ) ) THEN
        BEGIN
             Stroka := '';
             SingExit := FALSE;
             EXIT
        END;
     line := Stroka [ 3 ] + Stroka [ 4 ];
     VAL ( line, Ms, err );
     IF ( ( err <> 0 ) OR ( Ms < 1 ) OR ( Ms > 12 ) ) THEN
        BEGIN
             Stroka := '';
             SingExit := FALSE;
             EXIT
        END;
     line := Stroka [ 5 ] + Stroka [ 6 ];
     VAL ( line, God, err );
     IF ( ( err <> 0 ) OR ( God < 90 ) OR ( God > 99 ) ) THEN
        BEGIN
             Stroka := '';
             SingExit := FALSE;
             EXIT
        END;
     God := God + 1900;

     IF ( SingExit ) THEN
        BEGIN
             SetColorSymbol ( ColorSym );
             SetColorFon ( ColorFon );
             XYPrint ( x, y, help );
             XYPrint ( x, y, stroka );
             SetDate ( God, Ms, Day )
        END

END; { procedure quit }

PROCEDURE SetSymbol;

BEGIN
     IF ( ClearEdit ) THEN
        BEGIN
             stroka := '';
             kx := 1
        END;
     IF ( SingInsert ) THEN
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
    SingInsert := FALSE;
    stroka := StrDay + StrMs + StrGod;
    ch := #0;
    HideKey;

    WHILE TRUE DO   { цикл редактирования }

        BEGIN
          IF ( SingColorEdit ) THEN
             BEGIN
                  SetColorFon ( ColorEditFon );
                  SetColorSymbol ( ColorEditSymbol );
                  XYPrint ( x, y, help );
                  SetColorFon ( ColorEditFon )
            END;
            SingExit := TRUE;
            WHILE ( LENGTH ( stroka ) > ln ) DO
                  DELETE ( stroka, LENGTH ( stroka ), 1 );
            IF ( kx > ln ) THEN
               kx := LENGTH ( stroka );
            IF ( LENGTH ( Stroka ) = 0 ) THEN
               kx := 1;
            XYPrint ( x, y, stroka );
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

                     invs : SingInsert := NOT ( SingInsert );

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

END; { procedure TextWindow.ReadData }

{----------------------------------------------------------}

DESTRUCTOR TextWindow.Done;

           { уничтожить окно }
BEGIN
     FREEMEM ( Pic, ( 2 * sx * sy ) );
     FREEMEM ( OldPic, ( 2 * sx * sy ) )

END; { destructor TextWindow.Done }

{----------------------------------------------------------}

DESTRUCTOR TextWindow.UnFrameDone ( ch : CHAR );

           { уничтожить с сверткой рамки }
VAR
    kx1, ky1, kx2, ky2 : BYTE;
          { координаты рамки текущего окна }

BEGIN
     IF ( Ch = #0 ) THEN
        Ch := ' ';
     OldScreen := TRUE;

           { установка координат рамки текущего окна }

     kx1 := 1;
     ky1 := 1;
     kx2 := Wx2 - Wx1 + 1;
     ky2 := Wy2 - Wy1 + 1;

            { цикл исчезновения / восстановления }

     WHILE ( ( ( kx2 - kx1 ) >= 1 ) AND ( ( ky2 - ky1 ) >= 1 ) ) DO
         BEGIN
              FrameWindow ( kx1, ky1, kx2, ky2, 0, ch );
              FrameWindow ( kx1, ky1, kx2, ky2, 0, CHR ( 0 ) );
              INC ( kx1 );
              INC ( ky1 );
              DEC ( kx2 );
              DEC ( ky2 );
         END;
     FrameWindow ( kx1, ky1, kx2, ky2, 0, CHR ( 0 ) );
     OldScreen := FALSE;
     FREEMEM ( Pic, ( 2 * sx * sy ) );
     FREEMEM ( OldPic, ( 2 * sx * sy ) )

END; { destructor TextWindow.UnFrameDone }

{----------------------------------------------------------}

DESTRUCTOR TextWindow.TypeDone;

           { уничтожить с печатью старой информации }
BEGIN
     TypeOldScreen;
     FREEMEM ( Pic, ( 2 * sx * sy ) );
     FREEMEM ( OldPic, ( 2 * sx * sy ) )

END; { destructor TextWindow.TypeDone }

{----------------------------------------------------------}

END.