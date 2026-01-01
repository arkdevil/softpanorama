
         {----------------------------------------------------}
         {     Программа обработки текстов и документов       }
         {              LPrint  V 3.5.J                       }
         {     Язык программирования Turbo Pascal  V 6.0      }
         {----------------------------------------------------}
         { Дата последних изменений :  20/10/1992             }
         {----------------------------------------------------}
         { Программа предназначена для печати просмотра и     }
         {       редактирования текстовых файлов              }
         {----------------------------------------------------}
         { (c) 1990-1992, Мигач Ярослав                       }
         {----------------------------------------------------}


PROGRAM  LPrint;

{$M 64000, $0, $20000 }
{$F+,O+,I-,D-,R-,S-,B-,A+,V-,G-}

USES Dos, Crt, CheckFl, Printer, Def, JetFont, Fkey11, TWindow, MnCmd, Lptr,
     LcText, ViewT, ViewLt, EditT, MnBar, MnGroup, FLprint, HLPrint, Font_PM;

TYPE
    TypeBuf = ARRAY [ 1..$8000 ] OF BYTE;
                { тип вспомогательного буфера }

CONST
     OnCondens :  STRING [ 4 ] =  #27 + #120 + #49;
     OffCondens : STRING [ 4 ] =  #27 + #120 + #48;
     OnTitle :    STRING [ 4 ] = #27 + 'W1';
     OffTitle :   STRING [ 4 ] = #27 + 'W0';
     OnLitl :     STRING [ 4 ] = #15;
     OffLitl :    STRING [ 4 ] = #18;

     MyPassword = 'Ira';
                  { Пароль доступа к кодированию }

VAR
   MngMenuPtr : MenuBarPtr;
                { главное меню }

   Ch : CHAR;
             { команда главного меню }

   StartPath : STRING;
                { Стартовый путь доступа }

   DirPathLeft, DirPathRight : STRING;
                { путь доступа левой и правой панелей }

   DirStreamPtr : LocationListTextPtr;
                { текстовый поток директория }

   DirWindow : ViewLineNumberText;
                { обьект управления директорием }

   DirCommand : BYTE;
                { команда управления директорием }

   NumberFile : LONGINT;
                { порядковый номер файла в поддиректории }

   MaxDrivers : BYTE;
                { максимальное количество драйверов в системе }

   NumberFirstPage : WORD;
                { номер первой страницы }

   NumberStartPage : WORD;
                { номер страницы для начала печати }

   NumberEndPage : WORD;
                { номер последней печатаемой страницы }

   NowNumberPage : WORD;
                { номер текущей страницы }

   NowLocalNumber : WORD;
                { текущий локальный номер }

   QuantityLines : WORD;
                { количество строк на странице }

   SizeLeft : BYTE;
                { размер левого поля }

   SingNumberUp : BOOLEAN;
                { признак печати номера вверху }

   SingNumberDown : BOOLEAN;
                { признак печати номера внизу }

   SingAllNumber : BOOLEAN;
                { признак сквозной нумерации }

   SingLocalNumber : BOOLEAN;
                { признак локальной нумерации }

   LineLocal : STRING [ 8 ];
                { префикс локальной нумерации }

   RepeatPrint : BYTE;
                { количество копий }

   SingFileName : BOOLEAN;
                { признак печати имени файла }

   LineTitle : StandartString;
                { титульный заголовок }

   PageWait : BOOLEAN;
                { Признак паузы }

   PageIgnore : BOOLEAN;
                { Признак игнорирования переводов страниц в файле }

   GoToPrinter : BOOLEAN;
                { Признак прерывания печати }

   PrintStreamPtr : LocationProtectTextPtr;
                { Указатель на печатаемый текстовый поток }

   MyWordWap : BYTE;
                { Количество символов в строке при редактировании }

   Sequrity : BYTE;
                { Пароль кодирования текстовых файлов }

   GWind : TextWindowPtr;
                { главный экран программы }

   SingMod2 : BOOLEAN;
                { Признак печати четных страниц }

   SingMod1 : BOOLEAN;
                { Признак печати нечетных страниц }

   SingVarMod : BOOLEAN;
                { Чередующаяся печать }

{----------------------------------------------------------}

PROCEDURE LineToPrinter ( Line : STRING; VAR KeyPrint : BOOLEAN );

          { Печать строки }
VAR
   Index : BYTE;
   Ch : CHAR;

BEGIN
     IF ( NOT TypeFont.SingJet ) THEN
        BEGIN
             IF ( NOT TypeFont.SingMachin ) THEN
                List ( Line, KeyPrint )
             ELSE
                 PMList ( Line, KeyPrint )
        END
     ELSE
         BEGIN
              Index := 1;
              WHILE ( ( Index <= LENGTH ( Line ) ) AND ( NOT KeyPrint ) ) DO
                    BEGIN
                         REPEAT
                               WRITE ( Lst, Line [ Index ] );
                               IF ( KEYPRESSED ) THEN
                                  BEGIN
                                       Ch := READKEY;
                                       KeyPrint := ( Ch = #27 )
                                  END
                         UNTIL ( IORESULT = 0 ) OR ( KeyPrint );
                         INC ( Index )
                    END
         END

END; { procedure LineToPrinter }

{----------------------------------------------------------}

PROCEDURE LineLnToPrinter ( Line : STRING; VAR KeyPrint : BOOLEAN );

         { Печать строки с переводом }
VAR
   Index : BYTE;
   Ch : CHAR;

BEGIN
     IF ( NOT TypeFont.SingJet ) THEN
        BEGIN
             IF ( NOT TypeFont.SingMachin ) THEN
                ListLn ( Line, KeyPrint )
             ELSE
                 PMLineList ( Line, KeyPrint )
        END
     ELSE
         BEGIN
              Index := 1;
              WHILE ( ( Index <= LENGTH ( Line ) ) AND ( NOT KeyPrint ) ) DO
                    BEGIN
                         REPEAT
                               WRITE ( Lst, Line [ Index ] );
                               IF ( KEYPRESSED ) THEN
                                  BEGIN
                                       Ch := READKEY;
                                       KeyPrint := ( Ch = #27 )
                                  END
                         UNTIL ( IORESULT = 0 ) OR ( KeyPrint );
                         INC ( Index )
                    END;
              IF ( NOT KeyPrint ) THEN
                 REPEAT
                       WRITELN ( Lst, '' );
                       IF ( KEYPRESSED ) THEN
                          BEGIN
                               Ch := READKEY;
                               KeyPrint := ( Ch = #27 )
                          END
                 UNTIL ( IORESULT = 0 ) OR ( KeyPrint )
         END

END; { procedure LineLnToPrinter }

{----------------------------------------------------------}

PROCEDURE StartSetUp;

         { установка начальной конфигурации }
VAR
   Fl : FILE;
   Key : BOOLEAN;

BEGIN
     ASSIGN ( Fl, 'Lprint.Cgf' );
     RESET ( Fl, 1 );
     Key := FALSE;
     IF ( IORESULT = 0 ) THEN
        BEGIN
              BLOCKREAD ( Fl, NumberFirstPage, SIZEOF ( NumberFirstPage ) );
              Key := ( IORESULT <> 0 ) OR Key;
              BLOCKREAD ( Fl, NumberStartPage, SIZEOF ( NumberStartPage ) );
              Key := ( IORESULT <> 0 ) OR Key;
              BLOCKREAD ( Fl, NumberEndPage, SIZEOF ( NumberEndPage ) );
              Key := ( IORESULT <> 0 ) OR Key;
              BLOCKREAD ( Fl, QuantityLines, SIZEOF ( QuantityLines ) );
              Key := ( IORESULT <> 0 ) OR Key;
              BLOCKREAD ( Fl, SizeLeft, SIZEOF ( SizeLeft ) );
              Key := ( IORESULT <> 0 ) OR Key;
              BLOCKREAD ( Fl, RepeatPrint, SIZEOF ( RepeatPrint ) );
              Key := ( IORESULT <> 0 ) OR Key;
              BLOCKREAD ( Fl, LineTitle, SIZEOF ( LineTitle ) );
              Key := ( IORESULT <> 0 ) OR Key;
              BLOCKREAD ( Fl, SingNumberUp, SIZEOF ( SingNumberUp ) );
              Key := ( IORESULT <> 0 ) OR Key;
              BLOCKREAD ( Fl, SingNumberDown, SIZEOF ( SingNumberDown ) );
              Key := ( IORESULT <> 0 ) OR Key;
              BLOCKREAD ( Fl, SingLocalNumber, SIZEOF ( SingLocalNumber ) );
              Key := ( IORESULT <> 0 ) OR Key;
              BLOCKREAD ( Fl, SingAllNumber, SIZEOF ( SingAllNumber ) );
              Key := ( IORESULT <> 0 ) OR Key;
              BLOCKREAD ( Fl, LineLocal, SIZEOF ( LineLocal ) );
              Key := ( IORESULT <> 0 ) OR Key;
              BLOCKREAD ( Fl, SingFileName, SIZEOF ( SingFileName ) );
              Key := ( IORESULT <> 0 ) OR Key;
              BLOCKREAD ( Fl, PageWait, SIZEOF ( PageWait ) );
              Key := ( IORESULT <> 0 ) OR Key;
              BLOCKREAD ( Fl, PageIgnore, SIZEOF ( PageIgnore ) );
              Key := ( IORESULT <> 0 ) OR Key;
              BLOCKREAD ( Fl, MyWordWap, SIZEOF ( MyWordWap ) );
              Key := ( IORESULT <> 0 ) OR Key;
              BLOCKREAD ( Fl, SingMod2, SIZEOF ( SingMod2 ) );
              Key := ( IORESULT <> 0 ) OR Key;
              BLOCKREAD ( Fl, SingMod1, SIZEOF ( SingMod1 ) );
              Key := ( IORESULT <> 0 ) OR Key;
              BLOCKREAD ( Fl, SingVarMod, SIZEOF ( SingVarMod ) );
              Key := ( IORESULT <> 0 ) OR Key;
              BLOCKREAD ( Fl, TypeFont, SIZEOF ( TypeFont ) );
              Key := ( IORESULT <> 0 ) OR Key;
              CLOSE ( Fl );
              Key := ( IORESULT <> 0 ) OR Key;
              Key := NOT Key
        END;
     IF ( NOT Key ) THEN
         BEGIN
              NumberFirstPage := 1;
              NumberStartPage := 1;
              NumberEndPage := 9999;
              QuantityLines := 55;
              SizeLeft := 0;
              RepeatPrint := 1;
              LineTitle := '';
              SingNumberUp := TRUE;
              SingNumberDown := FALSE;
              SingLocalNumber := FALSE;
              SingAllNumber := TRUE;
              LineLocal := '';
              SingFileName := FALSE;
              ReSetFonts;
              PageWait := FALSE;
              PageIgnore := FALSE;
              MyWordWap := 65;
              SingMod2 := TRUE;
              SingMod1 := TRUE;
              SingVarMod := FALSE;
              TypeFont.SingRoman := TRUE;
              TypeFont.SingMachin := FALSE;
              TypeFont.MachineInterval := $34
         END;
     Sequrity := 0

END; { procedure StartSetUp }

{----------------------------------------------------------}

PROCEDURE SaveSetUp;

          { Сохранение параметров }
VAR
   Fl : FILE;
   Key : BOOLEAN;

BEGIN
     ASSIGN ( Fl, 'Lprint.Cgf' );
     RESET ( Fl, 1 );
     Key := FALSE;
     IF ( IORESULT <> 0 ) THEN
        BEGIN
             REWRITE ( Fl, 1 );
             IF ( IORESULT <> 0 ) THEN
                EXIT
        END;
     BLOCKWRITE ( Fl, NumberFirstPage, SIZEOF ( NumberFirstPage ) );
     Key := ( IORESULT <> 0 ) OR Key;
     BLOCKWRITE ( Fl, NumberStartPage, SIZEOF ( NumberStartPage ) );
     Key := ( IORESULT <> 0 ) OR Key;
     BLOCKWRITE ( Fl, NumberEndPage, SIZEOF ( NumberEndPage ) );
     Key := ( IORESULT <> 0 ) OR Key;
     BLOCKWRITE ( Fl, QuantityLines, SIZEOF ( QuantityLines ) );
     Key := ( IORESULT <> 0 ) OR Key;
     BLOCKWRITE ( Fl, SizeLeft, SIZEOF ( SizeLeft ) );
     Key := ( IORESULT <> 0 ) OR Key;
     BLOCKWRITE ( Fl, RepeatPrint, SIZEOF ( RepeatPrint ) );
     Key := ( IORESULT <> 0 ) OR Key;
     BLOCKWRITE ( Fl, LineTitle, SIZEOF ( LineTitle ) );
     Key := ( IORESULT <> 0 ) OR Key;
     BLOCKWRITE ( Fl, SingNumberUp, SIZEOF ( SingNumberUp ) );
     Key := ( IORESULT <> 0 ) OR Key;
     BLOCKWRITE ( Fl, SingNumberDown, SIZEOF ( SingNumberDown ) );
     Key := ( IORESULT <> 0 ) OR Key;
     BLOCKWRITE ( Fl, SingLocalNumber, SIZEOF ( SingLocalNumber ) );
     Key := ( IORESULT <> 0 ) OR Key;
     BLOCKWRITE ( Fl, SingAllNumber, SIZEOF ( SingAllNumber ) );
     Key := ( IORESULT <> 0 ) OR Key;
     BLOCKWRITE ( Fl, LineLocal, SIZEOF ( LineLocal ) );
     Key := ( IORESULT <> 0 ) OR Key;
     BLOCKWRITE ( Fl, SingFileName, SIZEOF ( SingFileName ) );
     Key := ( IORESULT <> 0 ) OR Key;
     BLOCKWRITE ( Fl, PageWait, SIZEOF ( PageWait ) );
     Key := ( IORESULT <> 0 ) OR Key;
     BLOCKWRITE ( Fl, PageIgnore, SIZEOF ( PageIgnore ) );
     Key := ( IORESULT <> 0 ) OR Key;
     BLOCKWRITE ( Fl, MyWordWap, SIZEOF ( MyWordWap ) );
     Key := ( IORESULT <> 0 ) OR Key;
     BLOCKWRITE ( Fl, SingMod2, SIZEOF ( SingMod2 ) );
     Key := ( IORESULT <> 0 ) OR Key;
     BLOCKWRITE ( Fl, SingMod1, SIZEOF ( SingMod1 ) );
     Key := ( IORESULT <> 0 ) OR Key;
     BLOCKWRITE ( Fl, SingVarMod, SIZEOF ( SingVarMod ) );
     Key := ( IORESULT <> 0 ) OR Key;
     BLOCKWRITE ( Fl, TypeFont, SIZEOF ( TypeFont ) );
     Key := ( IORESULT <> 0 ) OR Key;
     CLOSE ( Fl );
     Key := ( IORESULT <> 0 ) OR Key

END; { procedure SaveSetUp }

{----------------------------------------------------------}

FUNCTION GetLastDriver : BYTE;

        { получить количество драйверов в системе }
VAR
   rg : REGISTERS;
   Line : STRING;


BEGIN
     rg.AH := $19;
     INTR ( $21, rg );
     rg.DH := 0;
     rg.DL := rg.AL;
     rg.AH := $0E;
     INTR ( $21, rg );
     IF ( rg.AL > 12 ) THEN
        rg.AL := 12;
     GetLastDriver := rg.AL

END; { function GetLastDriver }

{----------------------------------------------------------}

PROCEDURE LprintTitle;

VAR
   Stroka : StandartString;
   line : StandartString;
   err : INTEGER;

BEGIN
     NEW ( GWind, MakeWindow ( 1, 1, 80, 25, MAGENTA, MAGENTA ) );
     GWind^.ClearWindow ( #178, BLUE, YELLOW );
     GWind^.TypeFrameWindow ( CHR ( 219 ) );
     GWind^.SetColorSymbol  ( YELLOW );
     GWind^.FrameWindow ( 1, 1, 80, 25, 0, #196 );
     GWind^.SetColorSymbol ( WHITE );
     GWind^.XYPrint ( 3, 25, '  Enter - исполнить команду, ' + #26 +
     ', ' + #27 + ', ' + #24 + ', ' + #25 + '  -  перемещение , ESC - Выход  ' );
     GWind^.SetColorSymbol ( BLACK );
     GWind^.SetColorFon ( CYAN );
     GWind^.XYPrint ( 18, 2, 'Программа обработки текстов и документов  V 3.5.J' );
     GWind^.SetColorFon ( MAGENTA );
     GWind^.SetColorSymbol ( LIGHTCYAN );
     GWind^.XYPrint ( 25, 23,'(c) 1990-1992,  I P M   Group');
     DirPathLeft := GetCurrentDir;
     DirPathRight := DirPathLeft

END; { procedure LprintTitle }

{----------------------------------------------------------}

PROCEDURE EnterParameter ( x, y, Ml : BYTE; VAR Ch : CHAR; VAR param : STRING ;
                           mess : STRING; Tp, ClF, ClC, ClF_C, ClC_C : BYTE );

          { Ввод параметра с заданным сообщением }
VAR
   SizeX : BYTE;
   SzL : BYTE;
   WindMsg : TextWindowPtr;

BEGIN
     SizeX := LENGTH ( Mess ) + 4;
     IF ( SizeX < 51 ) THEN
        SizeX := 51;
     IF ( ( SizeX + X ) > 79 ) THEN
        SizeX := 79 - X;
     IF ( Ml < ( SizeX - 8 ) ) THEN
        Szl := Ml
     ELSE
         Szl := SizeX - 8;
    NEW ( WindMsg, MakeWindow ( x, y, ( x + SizeX ), ( y + 4 ),
                                MAGENTA, WHITE ) );
    WindMsg^.WPrint ( 3, 2, mess );
    WindMsg^.WPrint ( 4, 3, CHR ( 16 ) );
    WindMsg^.FrameWindow ( 1, 1, SizeX, 4, 1, CHR(196) );
    WindMsg^.SetShade ( BLACK, BLACK );
    WindMsg^.PrintWindow;
    WindMsg^.SetTypeEdit ( Tp );
    WindMsg^.SetColorEdit ( ClF, ClC );
    WindMsg^.SetClearEdit;
    WindMsg^.SetColorClearEdit ( ClF_C, ClC_C );
    IF ( Param = 'Password' ) THEN
       BEGIN
            Param := '';
            WindMsg^.SetMaskEdit ( '*' )
       END;
    WindMsg^.XYEdit ( 6, 3, ch, Szl, param );
    DISPOSE ( WindMsg, TypeDone )

END; { procedure EnterParametr }

{----------------------------------------------------------}

PROCEDURE CmdF1; BEGIN DirCommand := 1 END;
PROCEDURE CmdF2; BEGIN DirCommand := 2 END;
PROCEDURE CmdF3; BEGIN DirCommand := 3 END;
PROCEDURE CmdF4; BEGIN DirCommand := 4 END;
PROCEDURE CmdF5; BEGIN DirCommand := 5 END;
PROCEDURE CmdF6; BEGIN DirCommand := 6 END;
PROCEDURE CmdF7; BEGIN DirCommand := 7 END;
PROCEDURE CmdF8; BEGIN DirCommand := 8 END;
PROCEDURE CmdF9; BEGIN DirCommand := 9 END;
PROCEDURE CmdF10; BEGIN DirCommand := 10 END;
PROCEDURE CmdCtl_F1; BEGIN DirCommand := 11 END;
PROCEDURE CmdCtl_F2; BEGIN DirCommand := 12 END;
PROCEDURE CmdCtl_F3; BEGIN DirCommand := 13 END;

{----------------------------------------------------------}

FUNCTION NameFl ( Index : LONGINT ) : STRING;

        { возвращает имя файла по индексу }
VAR
   Line, Hlp : STRING;
   Key : BYTE;

BEGIN
     Line := DirWindow.GetLine ( Index );
     Hlp := '';
     Key := 1;
     WHILE ( Line [ Key ] <> ' ' ) DO
           BEGIN
                Hlp := Hlp + Line [ Key ];
                INC ( Key )
           END;
     NameFl := Hlp

END; { function NameFl }

{----------------------------------------------------------}

PROCEDURE GetNewPath ( Ext : LONGINT );

       { установить новый путь доступа в каталог }
VAR
   Line : STRING;
   HelpPath : STRING;
   Index : BYTE;

BEGIN
     Line := DirWindow.GetLine ( Ext );
     IF ( POS ( '< SUB-DIR >', Line ) = 0 ) THEN
        EXIT;
     IF ( POS ( '..', Line ) = 1 ) THEN
        BEGIN
             DELETE ( DirPathLeft, ( LENGTH ( DirPathLeft ) ), 1 );
             WHILE ( DirPathLeft [ LENGTH ( DirPathLeft ) ] <> '\' ) DO
                   DELETE ( DirPathLeft, ( LENGTH ( DirPathLeft ) ), 1 )
        END
     ELSE
         BEGIN
              HelpPath := '';
              Index := 1;
              WHILE ( Line [ Index ] <> ' ' ) DO
                    BEGIN
                         HelpPath := HelpPath + Line [ Index ];
                         INC ( Index )
                    END;
              DirPathLeft := DirPathLeft + HelpPath + '\'
         END;

END; { procedure GetNewPath }

{----------------------------------------------------------}

FUNCTION EnterPath ( OldPath : STRING ) : STRING;

         { ввести путь доступа с экрана }
VAR
   Ch : CHAR;
   Key : BOOLEAN;
   Wind_P : TextWindowPtr;

BEGIN
     Key := FALSE;
     IF ( ( OldPath [ LENGTH ( OldPath ) ] = '\' ) AND
          ( LENGTH ( OldPath )  <> 3 ) ) THEN
        DELETE ( OldPath, LENGTH ( OldPath ), 1 );
     NEW ( Wind_P, MakeWindow ( 25, 9, 76, 13, MAGENTA, WHITE ) );
     Wind_P^.WPrint ( 3, 2, '   Укажите путь' );
     Wind_P^.WPrint ( 5, 3, CHR ( 16 ) );
     Wind_P^.FrameWindow ( 1, 1, 51, 4, 1, CHR(196) );
     Wind_P^.SetShade ( BLACK, BLACK );
     Wind_P^.PrintWindow;
     REPEAT
           IF ( Key ) THEN
              War ( ' Ошибка чтения директория ' );
           Wind_P^.SetTypeEdit ( 0 );
           Wind_P^.SetColorEdit ( LIGHTGRAY, BLUE );
           Wind_P^.SetClearEdit;
           Wind_P^.SetColorClearEdit ( LIGHTGRAY, LIGHTRED );
           Wind_P^.XYEdit ( 7, 3, ch, 40, OldPath );
           IF ( Ch <> #27 ) THEN
              CHDIR ( OldPath );
           Key := ( IORESULT <> 0 )
     UNTIL ( ( NOT Key ) OR ( Ch = #27 ) );
     DISPOSE ( Wind_P, TypeDone );
     IF ( Ch = #27 ) THEN
        BEGIN
             EnterPath := '';
             EXIT
        END;
     IF ( OldPath [ LENGTH ( OldPath ) ] <> '\' ) THEN
              OldPath := CONCAT ( OldPath, '\' );
     EnterPath := OldPath

END; { function EnterPath }

{----------------------------------------------------------}

PROCEDURE NewDriver;

        { смена драйвера }

CONST
     Sz = 3;
VAR
   Index : BYTE;
   Ch : Char;
   Command : BYTE;
   rg : REGISTERS;
   Menu : MenuCmdPtr;
   ListCmd, Hlp : MenuCommandCPtr;

BEGIN
     ListCmd := SetCmdC ( 3, 2, ' ' + CHR ( ORD ( 'A' ) ) + ' ', NIL );
     Hlp := ListCmd;
     FOR Index := 2 TO MaxDrivers DO
         BEGIN
              Hlp^.NextCommand := SetCmdC ( ( 3 + ( Index - 1 ) * 5 ), 2,
                              ' ' + CHR ( ORD ( 'A' ) - 1 + Index ) + ' ',
                              NIL );
              Hlp := Hlp^.NextCommand
         END;
     rg.AH := $19;
     INTR ( $21, rg );
     Command := rg.AL + 1;
     NEW ( Menu, SetMenu ( 5, 13, ( 7 + ( ( Sz + 2 ) * MaxDrivers ) ), 16,
                 BLUE, WHITE, LIGHTRED, WHITE, BLACK, CYAN, #205, TRUE,
                 0, Command, NulRunProcedure, ListCmd ) );
     Command := Menu^.StartMenu;
     DISPOSE ( Menu, Done );
     IF ( Command = 0 ) THEN
        EXIT;
     rg.AH := $0E;
     rg.DX := Command - 1;
     INTR ( $21, rg );
     GETDIR ( Command, DirPathLeft );
     IF ( DirPathLeft [ LENGTH ( DirPathLeft ) ] <> '\' ) THEN
        DirPathLeft := DirPathLeft + '\'

END; { procedure NewDriver }

{----------------------------------------------------------}

PROCEDURE HelpFileMenu;

       { вывести подсказку по файловому меню }
VAR
   HelpStreamPtr : LocationListTextPtr;
   HelpWindow : ViewText;
   Num : LONGINT;
   WindH : TextWindowPtr;

BEGIN
     NEW ( WindH, MakeWindow ( 5, 9, 75, 22, CYAN, BLUE ) );
     WindH^.SetShade ( BLACK, BLACK );
     WindH^.FrameWindow ( 1, 1, 70, 13, 1, #205 );
     WindH^.PrintWindow;
     NEW ( HelpStreamPtr, Init ( BuildLineList (
     '     Для перемещения по подкаталогам необходимо',
     BuildLineList (
     '  вывести указатель на имя подкаталога и нажать Enter',
     BuildLineList (
     '  Выбор нового диска осуществляется при помощи ',
     BuildLineList (
     '  команды F2.  Комады просмотра и редактирования',
     BuildLineList (
     '  работают с файлами длиной до 32 Мбайт .  Снимать',
     BuildLineList (
     '  поставленную отметку можно только если она имеет',
     BuildLineList (
     '  наибольший номер среди выставленных отметок',
     BuildLineList (
     '  Печать группы файлов осуществляется в порядке их',
     BuildLineList (
     '  нумерации.  ',
     BuildLineList (
     '',
     BuildLineList (
     '         Ins - поставить/ снять отметку',
     NIL ) ) ) ) ) ) ) ) ) ) ) , 200 ) );
     WITH HelpWindow DO
          BEGIN
               Init ( WindH, HelpStreamPtr );
               SetState ( TRUE, TRUE );
               Control_Inf ( num )
          END;
     HelpWindow.Done;
     DISPOSE ( WindH, TypeDone );
     DISPOSE ( HelpStreamPtr, Done )

END; { procedure HelpFileMenu }

{----------------------------------------------------------}

PROCEDURE PrintFile ( Name : STRING );

VAR
   NowLineNumber : LONGINT;
         { текущий номер строки в потоке }

   Listing : RecLinePtr;
         { Указатель на список строк страницы }

   SingEnd : BOOLEAN;
         { Признак завершения файла }

   WindP : TextWindowPtr;
         {   Указатель на окно с именем печатаемого файла }

   WindM : TextWindowPtr;
         { Указатель на окно с сообщением о переходе страницы }

   SizePrint : REAL;
         { Процент отпечатанного текста }

   StrSizePrint : STRING [ 10 ];
         { Строковое значение процента отпечатанного текста }

PROCEDURE FormList;

         { Сформировать список строк для печатаемой страницы }
VAR
   Hlp, First : RecLinePtr;
   Line : STRING;
   Index : BYTE;
   SzList : WORD;

FUNCTION GetLineTitle : STRING;

         { сформировать титульную строку }
VAR
   Line : STRING;
   Help : STRING [ 8 ];
   Index : BYTE;

PROCEDURE SetLine ( VAR Line : STRING; Ln : STRING; Num : BYTE );

VAR
   Index : BYTE;

BEGIN
     FOR Index := Num TO ( LENGTH ( Ln ) + Num - 1 ) DO
         Line [ Index ] := Ln [ Index - Num + 1 ]

END; { procedure SetLine }

BEGIN
     Line := '';
     FOR Index := 1 TO 200 DO
         Line := Line + ' ';
     IF ( SingLocalNumber ) THEN
        BEGIN
             SetLine ( Line, LineLocal, 2 + SizeLeft );
             STR ( NowLocalNumber , Help );
             SetLine ( Line, Help, LENGTH ( LineLocal ) + 3 + SizeLeft )
        END;
     STR ( NowNumberPage, Help );
     Help := '- ' + Help + '-';
     IF ( SingFileName ) THEN
        SetLine ( Line, ' Файл - ' + Name, 10 + SizeLeft );
     SetLine ( Line, Help, 40 + SizeLeft );
     SetLine ( Line, LineTitle, 48 + SizeLeft );
     WHILE ( Line [ LENGTH ( Line ) ] = ' ' ) DO
           DELETE ( Line, LENGTH ( Line ), 1 );
     GetLineTitle := Line

END; { function GetLineTitle }

BEGIN
     NEW ( Listing );
     Listing^.Next := NIL;
     Listing^.Line := '';
     Hlp := Listing;
     SzList := 0;
     IF ( ( NOT PageIgnore ) AND ( NowLineNumber > 1 ) ) THEN
        BEGIN
             DEC ( NowLineNumber );
             PrintStreamPtr^.SetLineNumber ( NowLineNumber );
             PrintStreamPtr^.ReadLine ( Line );
             IF ( POS ( #12, Line ) <> 0 ) THEN
                BEGIN
                     FOR Index := POS ( #12, Line ) TO LENGTH ( Line ) DO
                         Hlp^.Line := Hlp^.Line + Line [ Index ]
                END;
             INC ( NowLineNumber )
        END;
     REPEAT
           PrintStreamPtr^.ReadLine ( Line );
           SingEnd := PrintStreamPtr^.EofText;
           FOR Index := 1 TO SizeLeft DO
               Line := ' ' + Line;
           NEW ( Hlp^.Next );
           Hlp := Hlp^.Next;
           Hlp^.Next := NIL;
           Hlp^.Line := Line;
           NowLineNumber := PrintStreamPtr^.GetLineNumber;
     UNTIL ( ( NowLineNumber > PrintStreamPtr^.GetSize ) OR
           ( SizeListLine ( Listing ) >= QuantityLines )
           OR ( NOT PageIgnore AND ( POS ( #12, Line ) <> 0 ) )
           OR ( SingEnd ) );
     IF ( ( NOT PageIgnore ) AND ( POS ( #12, Line ) <> 0 ) ) THEN
        FOR Index := POS ( #12, Line ) TO LENGTH ( Line ) DO
            DELETE ( Line, Index, 1 );
     Line := GetLineTitle;
     if Listing^.Line = '' then
       DelListLine ( 1, Listing );
     IF ( SingNumberUp ) THEN
        BEGIN
             Hlp := NIL;
             NEW ( Hlp );
             First := Hlp;
             Hlp^.Line := Line;
             NEW ( Hlp^.Next );
             Hlp := Hlp^.Next;
             Hlp^.Line := '';
             Hlp^.Next := Listing;
             Listing := First
        END;
     IF ( SingNumberDown ) THEN
        BEGIN
             NEW ( Hlp^.Next );
             Hlp := Hlp^.Next;
             Hlp^.Line := '';
             NEW ( Hlp^.Next );
             Hlp := Hlp^.Next;
             Hlp^.Line := Line;
             Hlp^.Next := NIL
        END;

END; { procedure FormList }

PROCEDURE PrintList;

      { Печатать список }
VAR
   Hlp : RecLinePtr;

BEGIN
     IF ( NowNumberPage < NumberStartPage ) THEN
        EXIT;
     IF ( SingMod2 AND ( ( NowNumberPage MOD 2 ) <> 0 ) AND
        ( NOT SingMod1 ) ) THEN
        EXIT;
     IF ( SingMod1 AND ( ( NowNumberPage MOD 2 ) = 0 ) AND
        ( NOT SingMod2 ) ) THEN
        EXIT;
     Hlp := Listing;
     SetFont ( GoToPrinter );
     WHILE ( ( Hlp <> NIL ) AND ( NOT GoToPrinter ) ) DO
           BEGIN
                IF ( POS ( #12, Hlp^.Line ) <> 0 ) THEN
                   DELETE ( Hlp^.Line, POS ( #12, Hlp^.Line ), 1 );
                LineLnToPrinter ( Hlp^.Line, GoToPrinter );
                Hlp := Hlp^.Next
           END;
     IF ( GoToPrinter ) THEN
        EXIT;
     EndFont ( GoToPrinter );
     LineToPrinter ( #12, GoToPrinter )

END; { procedure PrintList }

BEGIN
     IF ( GoToPrinter ) THEN
        EXIT;
     SingEnd := FALSE;
     NowLocalNumber := NumberFirstPage;
     IF ( NOT SingAllNumber ) THEN
        NowNumberPage := NumberFirstPage;
     NEW ( PrintStreamPtr, Init ( $4000, Name, Sequrity  ) );
     PrintStreamPtr^.SetErrorProc ( ShowError );
     IF ( PrintStreamPtr = NIL ) THEN
        EXIT;
     NowLineNumber := PrintStreamPtr^.GetLineNumber;
     IF ( PrintStreamPtr^.GetSize = 0 ) THEN
        BEGIN
             DISPOSE ( PrintStreamPtr, Done );
             EXIT
        END;
     NEW ( WindP, MakeWindow ( 20, 10, 60, 14, CYAN, BLACK ) );
     WindP^.FrameWindow ( 1, 1, 40, 4, 1, CHR ( 205 ) );
     WindP^.SetShade ( BLACK, WHITE );
     WindP^.WPrint ( 6, 2, 'Печать файла  ' + Name );
     WindP^.PrintWindow;
     REPEAT
           FormList;
           IF ( ( PageWait ) AND ( NowNumberPage >= NumberStartPage ) ) THEN
              BEGIN
                   NEW ( WindM, MakeWindow ( 25, 16, 65, 20,
                                             GREEN, MAGENTA ) );
                   WindM^.FrameWindow ( 1, 1, 40, 4, 1, CHR ( 205 ) );
                   WindM^.SetShade ( BLACK, WHITE );
                   WindM^.WPrint ( 6, 2, 'Поставьте новый лист бумаги' );
                   WindM^.WPrint ( 6, 3, 'и нажмите любую клавишу' );
                   WindM^.PrintWindow;
                   AnyKey;
                   DISPOSE ( WindM, TypeDone )
              END;
           IF ( PrintStreamPtr^.GetNumberError <> 0 ) THEN
              GoToPrinter := TRUE;
           IF ( NOT GoToPrinter ) THEN
              PrintList;
           INC ( NowLocalNumber );
           INC ( NowNumberPage );
           SizePrint := ( NowLineNumber / PrintStreamPtr^.GetSize ) * 100.0;
           STR ( SizePrint : 6 : 2, StrSizePrint );
           WindP^.XYPrint ( 10, 3, StrSizePrint + ' %    ' );
           ClearListRecLine ( Listing )
     UNTIL ( ( NowLineNumber > PrintStreamPtr^.GetSize ) OR ( SingEnd )
             OR ( GoToPrinter ) OR ( NowNumberPage > NumberEndPage ) );
     DISPOSE ( WindP, TypeDone );
     DISPOSE ( PrintStreamPtr, Done )

END;  { procedure PrintFile }

{----------------------------------------------------------}

PROCEDURE PrintFiles;

        { печать файлов }
VAR
   Key : BOOLEAN;
   Index : LONGINT;
   Hlp : BYTE;
   RepeatL : BYTE;
   SizePrint : BYTE;
   WindM : TextWindowPtr;

BEGIN
     IF ( SingVarMod ) THEN
         SizePrint := 2 * RepeatPrint
     ELSE
         SizePrint := RepeatPrint;
     FOR RepeatL := 1 TO SizePrint DO
         BEGIN
              IF ( SingVarMod ) THEN
                 BEGIN
                      SingMod1 := ( ( RepeatL MOD 2 ) <> 0 );
                      SingMod2 := ( ( RepeatL MOD 2 ) = 0 );
                      NEW ( WindM, MakeWindow ( 25, 16, 65, 20,
                                             GREEN, MAGENTA ) );
                      WindM^.FrameWindow ( 1, 1, 40, 4, 1, CHR ( 205 ) );
                      WindM^.SetShade ( BLACK, WHITE );
                      IF ( SingMod1 ) THEN
                         WindM^.WPrint ( 6, 2, 'Печать нечетных страниц' );
                      IF ( SingMod2 ) THEN
                         WindM^.WPrint ( 6, 2, 'Печать четных страниц' );
                      WindM^.WPrint ( 6, 3, ' Нажмите любую клавишу' );
                      WindM^.PrintWindow;
                      AnyKey;
                      DISPOSE ( WindM, TypeDone )
                 END;
              GoToPrinter := FALSE;
              NowNumberPage := NumberFirstPage;
              Key := TRUE;
              FOR Index := 1 TO DirWindow.GetLastNumber DO
                  IF ( DirWindow.TestLine ( Index ) <> 0 ) THEN
                     Key := FALSE;
              IF ( Key ) THEN
                 BEGIN
                      DirWindow.ControlLine [ NumberFile ] := 1;
                      DirWindow.LastNumber := 1
                 END;
              FOR Hlp := 1 TO DirWindow.LastNumber DO
                  FOR Index := 1 TO DirWindow.GetLastNumber DO
                      IF ( ( DirWindow.TestLine ( Index ) = Hlp ) AND
                           ( POS ( '< SUB-DIR >',
                           DirWindow.GetLine ( Index ) ) = 0 ) ) THEN
                         PrintFile ( NameFl ( Index ) )
         END

END; { procedure PrintFiles }

{----------------------------------------------------------}

PROCEDURE ViewFile;

         { просмотр файла }
VAR
   HelpStreamPtr : LocationProtectTextPtr;
   HelpWindow : ViewText;
   Num : LONGINT;
   HelpLine : STRING;
   Index : BYTE;
   WindV : TextWindowPtr;

BEGIN
     HelpLine := NameFl ( NumberFile );
     IF ( POS ( '< SUB-DIR >', DirWindow.GetLine ( NumberFile ) ) <> 0 ) THEN
        EXIT;
     NEW ( WindV, MakeWindow ( 1, 1, 80, 25, CYAN, BLUE ) );
     WindV^.FrameWindow ( 1, 1, 80, 25, 1, #205 );
     WindV^.SetColorSymbol ( RED );
     WindV^.WPrint ( 10, 1, ' Просмотр файла  ' + HelpLine + ' ' );
     WindV^.SetColorSymbol ( BLUE );
     WindV^.PrintWindow;
     NEW ( HelpStreamPtr, Init ( $1000,
           DirPathLeft + HelpLine , Sequrity ) );
     HelpStreamPtr^.SetErrorProc ( ShowError );
     WITH HelpWindow DO
          BEGIN
               Init ( WindV, HelpStreamPtr );
               SetState ( TRUE , FALSE );
               Set_Key ( F1, HelpForViewer );
               Control_Inf ( num )
          END;
     HelpWindow.Done;
     DISPOSE ( WindV, UnFrameDone ( #205 ) );
     DISPOSE ( HelpStreamPtr, Done )

END; { procedure ViewFile }

{----------------------------------------------------------}

PROCEDURE EditFile;

          { редактирование файла }
VAR
   HelpStreamPtr : LocationProtectTextPtr;
   HelpWindow : EditText;
   Num : LONGINT;
   HelpLine : STRING;
   WindE : TextWindowPtr;

BEGIN
     HelpLine := NameFl ( NumberFile );
     IF ( POS ( '< SUB-DIR >', DirWindow.GetLine ( NumberFile ) ) <> 0 ) THEN
        EXIT;
     NEW ( WindE, MakeWindow ( 1, 1, 80, 25, CYAN, BLUE ) );
     WindE^.FrameWindow ( 1, 1, 80, 25, 1, #205 );
     WindE^.SetColorSymbol ( RED );
     WindE^.WPrint ( 10, 1, ' Редактирование файла  ' + HelpLine + ' ' );
     WindE^.SetColorSymbol ( BLUE );
     WindE^.PrintWindow;
     NEW ( HelpStreamPtr, Init ( $1000,
           DirPathLeft + HelpLine , Sequrity ) );
     HelpStreamPtr^.SetErrorProc ( ShowError );
     WITH HelpWindow DO
          BEGIN
               Init ( WindE, HelpStreamPtr );
               SetState ( TRUE, FALSE );
               SetWordWap ( MyWordWap );
               Set_Key ( F1, HelpForEditor );
               Control_Inf ( num )
          END;
     HelpWindow.Done;
     DISPOSE ( WindE, UnFrameDone ( #205 ) );
     DISPOSE ( HelpStreamPtr, Done )

END; { procedure EditFile }

{----------------------------------------------------------}

PROCEDURE EditNewFile;

         { редактирование нового файла }
VAR
   HelpStreamPtr : LocationProtectTextPtr;
   HelpWindow : EditText;
   Num : LONGINT;
   HelpLine : STRING;
   Key : BOOLEAN;
   Index : BYTE;
   Ch : CHAR;
   Fl : FILE;
   WindM, WindE : TextWindowPtr;

BEGIN
     Key := FALSE;
     NEW ( WindM, MakeWindow ( 25, 9, 76, 13, MAGENTA, WHITE ) );
     WindM^.WPrint ( 3, 2, '   Укажите имя файла' );
     WindM^.WPrint ( 5, 3, CHR ( 16 ) );
     WindM^.FrameWindow ( 1, 1, 51, 4, 1, CHR(196) );
     WindM^.SetShade ( BLACK, BLACK );
     WindM^.PrintWindow;
     HelpLine := '';
     REPEAT
           IF ( Key ) THEN
              War ( ' Этот файл уже есть на диске ' );
           WindM^.SetTypeEdit ( 0 );
           WindM^.SetColorEdit ( LIGHTGRAY, BLUE );
           WindM^.SetClearEdit;
           WindM^.SetColorClearEdit ( LIGHTGRAY, LIGHTRED );
           WindM^.XYEdit ( 7, 3, ch, 40, HelpLine );
           IF ( ( Ch = #27 ) OR ( HelpLine = '' ) ) THEN
              BEGIN
                   DISPOSE ( WindM, TypeDone );
                   EXIT
              END;
           ASSIGN ( Fl, HelpLine );
           RESET ( Fl );
           Key := ( IORESULT = 0 );
           CLOSE ( Fl );
           IF ( IORESULT <> 0 ) THEN
              BEGIN
              END
     UNTIL ( ( NOT Key ) OR ( Ch = #27 ) );
     DISPOSE ( WindM, TypeDone );

     NEW ( WindE, MakeWindow ( 1, 1, 80, 25, CYAN, BLUE ) );
     WindE^.FrameWindow ( 1, 1, 80, 25, 1, #205 );
     WindE^.SetColorSymbol ( RED );
     WindE^.WPrint ( 10, 1, ' Редактирование файла  ' + HelpLine + ' ' );
     WindE^.SetColorSymbol ( BLUE );
     WindE^.PrintWindow;
     NEW ( HelpStreamPtr, Init ( $1000,
           DirPathLeft + HelpLine, Sequrity ) );
     HelpStreamPtr^.SetErrorProc ( ShowError );
     WITH HelpWindow DO
          BEGIN
               Init ( WindE, HelpStreamPtr );
               SetState ( TRUE, FALSE );
               SetWordWap ( MyWordWap );
               Set_Key ( F1, HelpForEditor );
               Control_Inf ( num )
          END;
     HelpWindow.Done;
     DISPOSE ( WindE, TypeDone );
     DISPOSE ( HelpStreamPtr, Done )

END; { procedure EditNewFile }

{----------------------------------------------------------}

PROCEDURE SetPassword;

          { Установка пароля доступа к кодовым файлам }
VAR
   Line : StandartString;
   Ch : CHAR;
   Err : INTEGER;
   Num : WORD;

BEGIN
     IF ( Sequrity = 0 ) THEN
        BEGIN
             Line := 'Password';
             EnterParameter ( 34, 14, 10, Ch, Line, 'Введите личный пароль ', 0,
                                       LIGHTGRAY, BLUE, LIGHTGRAY, RED );
             IF ( ( Ch = #27 ) OR ( Line = '' ) ) THEN
                EXIT;
             IF ( Line <> MyPassword ) THEN
                BEGIN
                     WINDOW ( 1, 1, 80, 25 );
                     TEXTBACKGROUND ( BLACK );
                     TEXTCOLOR ( LIGHTGRAY );
                     HALT ( 1 )
                END;
        END;
     STR ( Sequrity, Line );
     REPEAT
           EnterParameter ( 34, 14, 4, Ch, Line,
                'Введите код доступа ', 1,
                LIGHTGRAY, BLUE, LIGHTGRAY, RED );
           IF ( Ch = #27 ) THEN
              EXIT;
           VAL ( Line, Num, Err );
           IF ( Err <> 0 ) THEN
              War ( 'Не числовое значение' )
           ELSE
               IF ( Num > 255 ) THEN
                  War ( 'Недопустимый код доступа' )
     UNTIL ( ( Err = 0 ) AND ( Num <= 255 ) );
     Sequrity := LO ( Num )

END; { procedure SetPassword }

{----------------------------------------------------------}

PROCEDURE CoderFiles;

          { Кодирование файлов }
VAR
   Index, Quantity : LONGINT; { вспомогательная переменная }

   Fl : FILE; {  файлы источника и назначения }

   key_error : BOOLEAN; { выход по ошибке }

   abort : BOOLEAN; { ключ прерывания по ESC }

   ch : CHAR; { переменная опроса }

   WindM : TextWindowPtr;

   InStream : LocationTextPtr;

   ToStream : LocationProtectTextPtr;

   NameFile, TempFile : StandartString;

   HelpList : RecLinePtr;

BEGIN
     IF ( Sequrity = 0 ) THEN
        BEGIN
             War ( 'Неустановлен пароль и код доступа' );
             EXIT
        END;
     key_error := TRUE;
     FOR Index := 1 TO DirWindow.GetLastNumber DO
         IF ( DirWindow.TestLine ( Index ) <> 0 ) THEN
            Key_Error := FALSE;
     IF ( Key_Error ) THEN
        DirWindow.ControlLine [ NumberFile ] := 1;
     abort := FALSE;
     HideKey;
     Ch := ' ';
     FOR Index := 1 TO DirWindow.GetLastNumber DO
         IF ( ( DirWindow.TestLine ( Index ) <> 0 ) AND
              ( NOT abort ) AND ( POS ( '< SUB-DIR >',
               DirWindow.GetLine ( Index ) ) = 0 ) ) THEN
            BEGIN
                 key_error := FALSE;
                 NameFile := DirPathLeft + NameFl ( Index );
                 TempFile := DirPathLeft + 'Lprint.Tmp';
                 ASSIGN ( Fl, TempFile );
                 REWRITE ( Fl );
                 IF ( NOT key_error ) THEN
                    key_error := ( IORESULT <> 0 );
                 CLOSE ( Fl );
                 IF ( NOT key_error ) THEN
                    key_error := ( IORESULT <> 0 );
                 NEW ( InStream, Init ( $1000, NameFile ) );
                 NEW ( ToStream, Init ( $1000, TempFile, Sequrity ) );
                 NEW ( WindM, MakeWindow ( 20, 10, 60, 16, CYAN, BLACK ) );
                 WindM^.FrameWindow ( 1, 1, 40, 6, 1, CHR ( 205 ) );
                 WindM^.SetShade ( BLACK, CYAN );
                 WindM^.WPrint ( 6, 3, 'Кодирование '+ NameFl ( Index ) );
                 WindM^.PrintWindow;
                 WHILE ( ( NOT InStream^.EofText ) AND ( Ch <> #27 ) ) DO
                       BEGIN
                            Quantity := InStream^.GetSize -
                                        InStream^.GetLineNumber + 1;
                            IF ( Quantity > 70 ) THEN
                               Quantity := 70;
                            HelpList := NIL;
                            InStream^.ReadLines ( Quantity, HelpList );
                            ToStream^.AddLines ( Quantity, HelpList );
                            ClearListRecLine ( HelpList );
                            IF ( KEYPRESSED ) THEN
                               Ch := READKEY;
                            HideKey
                       END;
                 Abort := ( Ch = #27 );
                 DISPOSE ( InStream, Done );
                 DISPOSE ( ToStream, Done );
                 IF ( NOT Abort ) THEN
                    BEGIN
                         ASSIGN ( Fl, NameFile );
                         RESET ( Fl );
                         IF ( IORESULT = 0 ) THEN
                            ERASE ( Fl );
                         IF ( NOT key_error ) THEN
                            key_error := ( IORESULT <> 0 );
                         CLOSE ( Fl );
                         IF ( NOT key_error ) THEN
                            key_error := ( IORESULT <> 0 );
                         ASSIGN ( Fl, TempFile );
                         RESET ( Fl );
                         IF ( IORESULT = 0 ) THEN
                            RENAME ( Fl, NameFile );
                         IF ( NOT key_error ) THEN
                            key_error := ( IORESULT <> 0 );
                         CLOSE ( Fl );
                         IF ( NOT key_error ) THEN
                            key_error := ( IORESULT <> 0 )
                    END;
                 IF ( key_error ) THEN
                    War ( ' Ошибка кодирования ' );
                 DISPOSE ( WindM, TypeDone )
            END

END; { procedure CoderFiles }

{----------------------------------------------------------}

PROCEDURE DecoderFiles;

          { Декодирование файлов }
VAR
   Index, Quantity : LONGINT; { вспомогательная переменная }

   Fl : FILE; {  файлы источника и назначения }

   key_error : BOOLEAN; { выход по ошибке }

   abort : BOOLEAN; { ключ прерывания по ESC }

   ch : CHAR; { переменная опроса }

   WindM : TextWindowPtr;

   InStream : LocationProtectTextPtr;

   ToStream : LocationTextPtr;

   NameFile, TempFile : StandartString;

   HelpList : RecLinePtr;

BEGIN
     IF ( Sequrity = 0 ) THEN
        BEGIN
             War ( 'Неустановлен пароль и код доступа' );
             EXIT
        END;
     key_error := TRUE;
     FOR Index := 1 TO DirWindow.GetLastNumber DO
         IF ( DirWindow.TestLine ( Index ) <> 0 ) THEN
            Key_Error := FALSE;
     IF ( Key_Error ) THEN
        DirWindow.ControlLine [ NumberFile ] := 1;
     abort := FALSE;
     HideKey;
     Ch := ' ';
     FOR Index := 1 TO DirWindow.GetLastNumber DO
         IF ( ( DirWindow.TestLine ( Index ) <> 0 ) AND
              ( NOT abort ) AND ( POS ( '< SUB-DIR >',
               DirWindow.GetLine ( Index ) ) = 0 ) ) THEN
            BEGIN
                 key_error := FALSE;
                 NameFile := DirPathLeft + NameFl ( Index );
                 TempFile := DirPathLeft + 'Lprint.Tmp';
                 ASSIGN ( Fl, TempFile );
                 REWRITE ( Fl );
                 IF ( NOT key_error ) THEN
                    key_error := ( IORESULT <> 0 );
                 CLOSE ( Fl );
                 IF ( NOT key_error ) THEN
                    key_error := ( IORESULT <> 0 );
                 NEW ( InStream, Init ( $1000, NameFile, Sequrity ) );
                 NEW ( ToStream, Init ( $1000, TempFile ) );
                 NEW ( WindM, MakeWindow ( 20, 10, 60, 16, CYAN, BLACK ) );
                 WindM^.FrameWindow ( 1, 1, 40, 6, 1, CHR ( 205 ) );
                 WindM^.SetShade ( BLACK, CYAN );
                 WindM^.WPrint ( 6, 3, 'Декодирование '+ NameFl ( Index ) );
                 WindM^.PrintWindow;
                 WHILE ( ( NOT InStream^.EofText ) AND ( Ch <> #27 ) ) DO
                       BEGIN
                            Quantity := InStream^.GetSize -
                                        InStream^.GetLineNumber + 1;
                            IF ( Quantity > 70 ) THEN
                               Quantity := 70;
                            HelpList := NIL;
                            InStream^.ReadLines ( Quantity, HelpList );
                            ToStream^.AddLines ( Quantity, HelpList );
                            ClearListRecLine ( HelpList );
                            IF ( KEYPRESSED ) THEN
                               Ch := READKEY;
                            HideKey
                       END;
                 Abort := ( Ch = #27 );
                 DISPOSE ( InStream, Done );
                 DISPOSE ( ToStream, Done );
                 IF ( NOT Abort ) THEN
                    BEGIN
                         ASSIGN ( Fl, NameFile );
                         RESET ( Fl );
                         IF ( IORESULT = 0 ) THEN
                            ERASE ( Fl );
                         CLOSE ( Fl );
                         IF ( NOT key_error ) THEN
                            key_error := ( IORESULT <> 0 );
                         IF ( NOT key_error ) THEN
                            key_error := ( IORESULT <> 0 );
                         ASSIGN ( Fl, TempFile );
                         RESET ( Fl );
                         IF ( IORESULT = 0 ) THEN
                            RENAME ( Fl, NameFile );
                         IF ( NOT key_error ) THEN
                            key_error := ( IORESULT <> 0 );
                         CLOSE ( Fl );
                         IF ( NOT key_error ) THEN
                            key_error := ( IORESULT <> 0 )
                    END;
                 IF ( key_error ) THEN
                    War ( ' Ошибка кодирования ' );
                 DISPOSE ( WindM, TypeDone )
            END


END; { procedure DecoderFiles }

{----------------------------------------------------------}

PROCEDURE CopyFiles;

         { копирование файлов }
VAR
   Index : LONGINT; { вспомогательная переменная }

   DirAssign : STRING; { директорий назначения копирования  }

   from_f, to_f : FILE; {  файлы источника и назначения }

   num_read, num_written : WORD; { количество считанных и }
   				 {   записанных блоков    }

   key_error : BOOLEAN; { выход по ошибке }

   abort : BOOLEAN; { ключ прерывания по ESC }

   ch : CHAR; { переменная опроса }

   Buf : ^TypeBuf; { указатель на вспомогательный буффер }

   WindM : TextWindowPtr;

BEGIN
     DirAssign := '';
     DirAssign := EnterPath ( DirAssign );
     IF ( DirAssign = '' ) THEN
        EXIT;
     key_error := TRUE;
     FOR Index := 1 TO DirWindow.GetLastNumber DO
         IF ( DirWindow.TestLine ( Index ) <> 0 ) THEN
            Key_Error := FALSE;
     IF ( Key_Error ) THEN
        DirWindow.ControlLine [ NumberFile ] := 1;
     abort := FALSE;
     FOR Index := 1 TO DirWindow.GetLastNumber DO
         IF ( ( DirWindow.TestLine ( Index ) <> 0 ) AND
              ( NOT abort ) AND ( POS ( '< SUB-DIR >',
               DirWindow.GetLine ( Index ) ) = 0 ) ) THEN
            BEGIN
                 key_error := FALSE;
                 ASSIGN ( from_f,  DirPathLeft + NameFl ( Index ) );
                 ASSIGN ( to_f, DirAssign + NameFl ( Index ) );
                 NEW ( WindM, MakeWindow ( 20, 10, 60, 16, CYAN, BLACK ) );
                 WindM^.FrameWindow ( 1, 1, 40, 6, 1, CHR ( 205 ) );
                 WindM^.SetShade ( BLACK, CYAN );
                 WindM^.WPrint ( 6, 3, 'Копирование '+ NameFl ( Index ) );
                 WindM^.WPrint ( 2, 4, ' на диск  '+ DirAssign );
                 WindM^.PrintWindow;
                 RESET ( from_f, 1 );
                 key_error := ( IORESULT <> 0 );
                 IF ( NOT key_error ) THEN
                    BEGIN
                         REWRITE ( to_f, 1 );
                         key_error := ( IORESULT <> 0 )
                    END;
                 ch := ' ';
                 WHILE ( KEYPRESSED ) DO
                       ch := READKEY;
                 IF ( ch = #27 ) THEN
                    abort := TRUE;
                 NEW ( buf );
                 IF ( ( NOT key_error ) AND ( NOT abort ) )THEN
                    REPEAT
                          BLOCKREAD ( from_f, buf^, SIZEOF ( buf^ ),
                                      num_read );
                          key_error := ( IORESULT <> 0 );
                          IF ( NOT key_error ) THEN
                             BEGIN
                                  BLOCKWRITE ( to_f, buf^, num_read,
                                               num_written );
                                  key_error := ( IORESULT <> 0 )
                             END
                    UNTIL ( key_error OR ( num_read = 0 ) OR
                          ( num_written <> num_read ) OR ( EOF ( from_f )));
                 DISPOSE ( buf );
                 CLOSE ( from_f );
                 IF ( NOT key_error ) THEN
                    key_error := ( IORESULT <> 0 );
                 CLOSE ( to_f );
                 IF ( NOT key_error ) THEN
                    key_error := ( IORESULT <> 0 );
                 IF ( key_error ) THEN
                    War ( ' Ошибка копирования ' );
                 DISPOSE ( WindM, TypeDone )
            END

END; { procedure CopyFiles }

{----------------------------------------------------------}

PROCEDURE RenameFiles;

        { переименование файлов }
VAR
   Index : INTEGER; { вспомогательная переменная }

   key_error : BOOLEAN; { признак ошибки }

   abort : BOOLEAN; { ключ завершения по ESC }

   new_name : STRING; { новое имя файла }

   fl : FILE; { переименуемый файл }

   Ch : CHAR; { переменная опроса }

BEGIN
     key_error := TRUE;
     FOR Index := 1 TO DirWindow.GetLastNumber DO
         IF ( DirWindow.TestLine ( Index ) <> 0 ) THEN
            Key_Error := FALSE;
     IF ( Key_Error ) THEN
        DirWindow.ControlLine [ NumberFile ] := 1;
     abort := FALSE;
     key_error := TRUE;
     FOR Index := 1 TO DirWindow.GetLastNumber DO
         IF ( ( DirWindow.TestLine ( Index ) <> 0 ) AND
              ( NOT abort ) AND ( POS ( '< SUB-DIR >',
               DirWindow.GetLine ( Index ) ) = 0 ) ) THEN
            BEGIN
                 key_error := FALSE;
                 ASSIGN ( fl, DirPathLeft + NameFl ( Index ) );
                 RESET ( fl );
                 key_error := ( IORESULT <> 0 );
                 CLOSE ( fl );
                 new_name := '';
                 ch := ' ';
                 WHILE ( KEYPRESSED ) DO
                       ch := READKEY;
                 IF ( ch = #27 ) THEN
                    abort := TRUE;
                 IF ( ( NOT key_error ) AND ( NOT abort ) ) THEN
                    BEGIN
                         EnterParameter ( 18, 12, 40, Ch, new_name,
                               'Введите новое имя для '+
                                 NameFl ( Index ) , 0, LIGHTGRAY, BLUE,
                                 LIGHTGRAY, RED );
                         IF ( ( new_name <> '' ) AND ( Ch <> #27 ) ) THEN
                            BEGIN
                                 RENAME ( fl, DirPathLeft + new_name );
                                 key_error := ( IORESULT <> 0 )
                            END
                    END;
                 IF ( Ch = #27 ) THEN
                    Abort := TRUE;
                 IF ( key_error ) THEN
                    War ( ' Ошибка дисковой операции ' )
            END

END; { procedure RenameFiles }

{----------------------------------------------------------}

PROCEDURE EraseFiles;

       { стирание файлов }
VAR
   Index : LONGINT; { вспомогательная переменная }

   fl : FILE; { удаляемый файл }

   key_error : BOOLEAN; { признак ошибки дисковой опреации }

   abort : BOOLEAN; { признак прерывания по ESC }

   ch, sh : CHAR; { переменная опроса }

   WindM : TextWindowPtr;

BEGIN
     key_error := TRUE;
     FOR Index := 1 TO DirWindow.GetLastNumber DO
         IF ( DirWindow.TestLine ( Index ) <> 0 ) THEN
            Key_Error := FALSE;
     IF ( Key_Error ) THEN
        DirWindow.ControlLine [ NumberFile ] := 1;
     abort := FALSE;
     NEW ( WindM, MakeWindow ( 20, 10, 60, 14, RED, YELLOW ) );
     WindM^.FrameWindow ( 1, 1, 40, 4 , 1, CHR ( 196 ) );
     WindM^.SetShade ( BLACK, WHITE );
     WindM^.WPrint ( 4, 2, 'Вы дейсвительно хотите удалить ?' );
     WindM^.WPrint ( 4, 3, '         Y / [ N ]' );
     WindM^.PrintWindow;
     WHILE ( KEYPRESSED ) DO
           ch := READKEY;
     ch := READKEY;
     WHILE ( KEYPRESSED ) DO
           sh := READKEY;
     DISPOSE ( WindM, TypeDone );
     IF ( NOT ( ch IN [ 'y', 'Y', 'д', 'Д' ] ) ) THEN
        EXIT;
     abort := FALSE;
     FOR Index := 1 TO DirWindow.GetLastNumber DO
         IF ( ( DirWindow.TestLine ( Index ) <> 0 ) AND
              ( NOT abort ) AND ( POS ( '< SUB-DIR >',
               DirWindow.GetLine ( Index ) ) = 0 ) ) THEN
            BEGIN
                 NEW ( WindM, MakeWindow ( 20, 10, 60, 14, CYAN, BLACK ) );
                 WindM^.FrameWindow ( 1, 1, 40, 4, 1, CHR ( 205 ) );
                 WindM^.SetShade ( BLACK, WHITE );
                 WindM^.WPrint ( 6, 2, 'Удаление' );
                 WindM^.WPrint ( 6, 3, NameFl ( Index ) );
                 WindM^.PrintWindow;
                 key_error := FALSE;
                 ASSIGN ( fl, DirPathLeft + NameFl ( Index ) );
                 RESET ( fl );
                 key_error := ( IORESULT <> 0 );
                 CLOSE ( fl );
                 ch := ' ';
                 WHILE ( KEYPRESSED ) DO
                       ch := READKEY;
                 IF ( ch = #27 ) THEN
                    abort := TRUE;
                 IF ( ( NOT key_error ) AND ( NOT abort ) ) THEN
                    BEGIN
                         ERASE ( fl );
                         key_error := ( IORESULT <> 0 )
                    END;
                 IF ( key_error ) THEN
                    War ( ' Ошибка дисковой операции ' );
                 DISPOSE ( WindM, TypeDone )
            END

END; { procedure EraseFiles }

{----------------------------------------------------------}

PROCEDURE SubCmd2;

          { общая подсказка }
VAR
   HelpStreamPtr : LocationListTextPtr;
   HelpWindow : ViewText;
   Num : LONGINT;
   Wn : TextWindowPtr;

BEGIN
     NEW ( Wn, MakeWindow ( 5, 9, 75, 22, CYAN, BLUE ) );
     Wn^.SetShade ( CYAN, BLACK );
     Wn^.FrameWindow ( 1, 1, 70, 13, 1, #205 );
     Wn^.TypeFrameWindow ( #0 );
     Wn^.SetColorSymbol ( BLUE );
     Wn^.SetColorFon ( WHITE );
     Wn^.WChar ( 70, 3, #24 );
     Wn^.WChar ( 70, 11, #25 );
     Wn^.SetColorSymbol ( CYAN );
     Wn^.SetColorFon ( BLUE );
     NEW ( HelpStreamPtr, Init ( BuildLineList (
     '     Программа обработки текстов Lprint V 3.0 прежде всего',
     BuildLineList (
     '  предназначена для печати текстов на мозаичном принтере',
     BuildLineList (
     '  в различных форматах. Однако новая версия программы ',
     BuildLineList (
     '  предоставляет возможность просмотра и корректировки',
     BuildLineList (
     '  текстовых файлов любой длины / до 32 Мбайт /. Кроме этого',
     BuildLineList (
     '  педусмотрены функции копирования, стирания, переименования',
     BuildLineList (
     '  файлов. Все выше приведенные возможности реализуются',
     BuildLineList (
     '  командой "Файловое меню".  Команда "Путь" позволяет',
     BuildLineList (
     '  предварительно установить путь доступа в заданный',
     BuildLineList (
     '  поддиректорий. При помощи команды "Конфигурация"',
     BuildLineList (
     '  устанавливается конфигурация и парамеры печати.',
     BuildLineList (
     '     Версия Lprint 3.3  являетя дальнейшим усовершенствованием',
     BuildLineList (
     '  программы в ней исправлен ряд ошибок. Приставка "J" в версии ',
     BuildLineList (
     '  программы означает возможность работы с принтером LaserJet II.',
     BuildLineList (
     '  при этом перед вызовом Lprint необходимо воспользоваться',
     BuildLineList (
     '  драйвером и загрузчиком шрифтов "Белецкого" ( Горсистемотехника )',
     BuildLineList (
     '  для лазерного принтера LaserJet II ',
     BuildLineList (
     '  Автор программы будет благодарен Вам за предоставление технической',
     BuildLineList (
     '  информации по программированию различных видов принтеров, а также',
     BuildLineList (
     '  за замечания по работе программы',
     BuildLineList (
     '  Замечание : 1) Lprint V 3.3.J проверяет свою длину и контрольные',
     BuildLineList (
     '  суммы. В случае заражения вирусами будет выдано предупреждающее',
     BuildLineList (
     '  сообщение  2) Возможны "вылеты" при попытке просмотра или',
     BuildLineList (
     '  редактирования сбойных файлов / ошибки операций чтения & записи/',
     BuildLineList (
     '  Замечание : 1) LPrint V 3.5.J позволяет печатать с использованием',
     BuildLineList (
     '  машинописного шрифта в латинском, русском и украинском / с',
     BuildLineList (
     '  использованием кодировки стандарта Верховного Совета. Имеется',
     BuildLineList (
     '  возможность плавно менять интервал между строками.',
     BuildLineList (
     '              2) Все недостатки предыдущих версий устранены.',
     BuildLineList (
     '  ..........................................................',
     BuildLineList (
     '  г. Киев  441-40-81 (сл)   - Ярослав Мигач',
     BuildLineList (
     '   ( c ) 1989 - 1992         I P M  Group',
     BuildLineList (
     '         Программа           Ярослав Мигач',
     BuildLineList (
     '         Машинописный шрифт  Андрей Букин',
     NIL ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) ) )
         ) ) ) ) ) ) ) ) ) ) ) ) ) , 100 ) );
     WITH HelpWindow DO
          BEGIN
               Init ( Wn, HelpStreamPtr );
               SetState ( TRUE, TRUE );
               Control_Inf ( num )
          END;
     HelpWindow.Done;
     DISPOSE ( Wn, UnFrameDone ( #205 ) );
     DISPOSE ( HelpStreamPtr, Done )

END; { procedure SubCmd2 }

{----------------------------------------------------------}

PROCEDURE SubCmd3;

          { Установить текущий путь доступа }
VAR
   Line : STRING;

BEGIN
     Line := EnterPath ( DirPathLeft );
     IF ( Line <> '' ) THEN
        DirPathLeft := Line

END; { procedure SubCmd3 }

{----------------------------------------------------------}

PROCEDURE SubCmd411;

          { нумерация и печать первой страницы текста }
VAR
   Line : StandartString;
   Ch : CHAR;
   Err : INTEGER;
   Num : WORD;

BEGIN
     STR ( NumberFirstPage, Line );
     REPEAT
           EnterParameter ( 34, 14, 4, Ch, Line,
                'Введите номер первой страницы ', 1,
                LIGHTGRAY, BLUE, LIGHTGRAY, RED );
           IF ( Ch = #27 ) THEN
              EXIT;
           VAL ( Line, Num, Err );
           IF ( Err <> 0 ) THEN
              War ( 'Не числовое значение' )
           ELSE
               BEGIN
                    IF ( Num < 1 ) THEN
                       War ( 'Номер не меньше 1' );
                    IF ( Num > NumberEndPage ) THEN
                       War ( 'Это больше номера последней страницы' )
               END
     UNTIL ( ( Err = 0 ) AND ( Num >= 1 ) AND ( Num <= NumberEndPage ) );
     NumberFirstPage := Num;
     STR ( NumberFirstPage, Line );
     REPEAT
           EnterParameter ( 34, 14, 4, Ch, Line,
                'Введите номер страницы для начала печати', 1,
                LIGHTGRAY, BLUE, LIGHTGRAY, RED );
           IF ( Ch = #27 ) THEN
              BEGIN
                   NumberStartPage := NumberFirstPage;
                   EXIT
              END;
           VAL ( Line, Num, Err );
           IF ( Err <> 0 ) THEN
              War ( 'Не числовое значение' )
           ELSE
               BEGIN
                    IF ( Num < NumberFirstPage ) THEN
                       War ( 'Но это меньше номера первой страницы !' );
                    IF ( Num > NumberEndPage ) THEN
                       War ( 'Это больше номера последней страницы' )
               END
     UNTIL ( ( Err = 0 ) AND ( Num >= NumberFirstPage )
             AND ( Num <= NumberEndPage ) );
     NumberStartPage := Num

END; { procedure SubCmd411 }

{----------------------------------------------------------}

PROCEDURE SubCmd412;

         { Номер последней печатаемой страницы }
VAR
   Line : StandartString;
   Ch : CHAR;
   Err : INTEGER;
   Num : WORD;

BEGIN
     STR ( NumberEndPage, Line );
     REPEAT
           EnterParameter ( 34, 14, 4, Ch, Line,
                'Введите номер последней страницы ', 1,
                LIGHTGRAY, BLUE, LIGHTGRAY, RED );
           IF ( Ch = #27 ) THEN
              EXIT;
           VAL ( Line, Num, Err );
           IF ( Err <> 0 ) THEN
              War ( 'Не числовое значение' )
           ELSE
               IF ( Num < NumberStartPage ) THEN
                   War ( 'Это меньше номера первой печатаемой страницы' )
     UNTIL ( ( Err = 0 ) AND ( Num >= NumberStartPage ) );
     NumberEndPage := Num

END; { procedure SubCmd412 }

{----------------------------------------------------------}

PROCEDURE SubCmd413;

         { Количество строк на странице }
VAR
   Line : StandartString;
   Ch : CHAR;
   Err : INTEGER;
   Num : WORD;

BEGIN
     STR ( QuantityLines, Line );
     REPEAT
           EnterParameter ( 34, 14, 4, Ch, Line,
                'Введите количество строк на странице ', 1,
                LIGHTGRAY, BLUE, LIGHTGRAY, RED );
           IF ( Ch = #27 ) THEN
              EXIT;
           VAL ( Line, Num, Err );
           IF ( Err <> 0 ) THEN
              War ( 'Не числовое значение' )
           ELSE
               IF ( Num < 10 ) THEN
                   War ( 'Не менее 10' );
               IF ( Num > 200 ) THEN
                   War ( 'не более 200' )
     UNTIL ( ( Err = 0 ) AND ( Num <= 200 ) AND ( Num >= 10 ) );
     QuantityLines := Num

END; { procedure SubCmd413 }

{----------------------------------------------------------}

PROCEDURE SubCmd414;

        { Размер левого поля }
VAR
   Line : StandartString;
   Ch : CHAR;
   Err : INTEGER;
   Num : WORD;

BEGIN
     STR ( SizeLeft, Line );
     REPEAT
           EnterParameter ( 34, 14, 3, Ch, Line,
                'Размер левого поля ( в символах ) ', 1,
                LIGHTGRAY, BLUE, LIGHTGRAY, RED );
           IF ( Ch = #27 ) THEN
              EXIT;
           VAL ( Line, Num, Err );
           IF ( Err <> 0 ) THEN
              War ( 'Не числовое значение' )
           ELSE
               IF ( Num > 40 ) THEN
                   War ( 'не более 40' )
     UNTIL ( ( Err = 0 ) AND ( Num <= 40 ) );
     SizeLeft := LO ( Num )

END; { procedure SubCmd414 }

{----------------------------------------------------------}

PROCEDURE SubCmd421;

       { Печатать ли номера на странице }
VAR
   command : BYTE;
   ch : CHAR;
   Menu : MenuCmdPtr;

BEGIN
     IF ( ( NOT SingNumberDown ) AND ( NOT SingNumberUp ) ) THEN
        command := 1;
     IF ( ( NOT SingNumberDown ) AND SingNumberUp ) THEN
        command := 2;
     IF ( SingNumberDown AND ( NOT SingNumberUp ) ) THEN
        command := 3;
    NEW ( Menu, SetMenu (  35, 15, 56, 20, MAGENTA, WHITE, LIGHTGRAY, BLUE,
                          BLACK, BLACK, #205, TRUE, 1, Command,
                          NulRunProcedure,
                SetCmdC ( 3, 2, ' Не печатать     ',
                SetCmdC ( 3, 3, ' Печатать вверху ',
                SetCmdC ( 3, 4, ' Печатать внизу  ', NIL ) ) ) ) );

    Command := Menu^.StartMenu;
    IF ( Command <> 0 ) THEN CASE command OF
            1 :  BEGIN
                      SingNumberDown := FALSE;
                      SingNumberUp := FALSE
                 END;
            2 :  BEGIN
                      SingNumberDown := FALSE;
                      SingNumberUp := TRUE
                 END;
            3 :  BEGIN
                      SingNumberDown := TRUE;
                      SingNumberUp := FALSE
                 END
    END;
    DISPOSE ( Menu, Done )

END; { procedure SubCmd421 }

{----------------------------------------------------------}

PROCEDURE SubCmd422;

       { локальная нумерация }
VAR
   command : BYTE;
   ch : CHAR;
   Wn : TextWindowPtr;
   Menu : MenuCmdPtr;

BEGIN
     IF ( SingAllNumber ) THEN
        command := 1
     ELSE
         command := 2;
     NEW ( Wn, MakeWindow ( 37, 15, 68, 20, MAGENTA, WHITE ) );
     Wn^.WPrint ( 3, 2, 'Вводить сквозную нумерацию' );
     Wn^.WPrint ( 3, 3, 'при печати группы файлов ?' );
     Wn^.FrameWindow ( 1, 1, 31, 5, 1, CHR ( 205 ) );
     Wn^.SetShade ( BLACK, BLACK );
     Wn^.PrintWindow;
     NEW ( Menu, SetMenu ( 45, 18, 59, 22, BLUE, WHITE, LIGHTRED, WHITE,
                           BLACK, BLACK, #196, TRUE, 1, Command,
                           NulRunProcedure,
                 SetCmdC ( 3, 2, '   ДА    ',
                 SetCmdC ( 3, 3, '   НЕТ   ', NIL ) ) ) );
     Command := Menu^.StartMenu;
     DISPOSE ( Menu, Done );
     DISPOSE ( Wn, TypeDone );
     IF ( Command = 0 ) THEN
        EXIT;
     IF ( command = 1 ) THEN
        SingAllNumber := TRUE
     ELSE
         SingAllNumber := FALSE;

END; { procedure SubCmd422 }

{----------------------------------------------------------}

PROCEDURE SubCmd423;

         { Нумерация группы файлов }
VAR
   command : BYTE;
   ch : CHAR;
   Line : StandartString;
   Wn : TextWindowPtr;
   Menu : MenuCmdPtr;

BEGIN
     IF ( SingLocalNumber ) THEN
        command := 1
     ELSE
         command := 2;
     NEW ( Wn, MakeWindow ( 39, 15, 70, 20, MAGENTA, WHITE ) );
     Wn^.WPrint ( 3, 2, 'Вводить локальную нумерацию' );
     Wn^.WPrint ( 3, 3, 'при печати группы файлов ?' );
     Wn^.FrameWindow ( 1, 1, 31, 5, 1, CHR ( 205 ) );
     Wn^.SetShade ( BLACK, BLACK );
     Wn^.PrintWindow;
     NEW ( Menu, SetMenu ( 48, 18, 62, 22, BLUE, WHITE, LIGHTRED, WHITE,
                           BLACK, BLACK, #196, TRUE, 1, Command,
                           NulRunProcedure,
                 SetCmdC ( 3, 2, '   ДА    ',
                 SetCmdC ( 3, 3, '   НЕТ   ', NIL ) ) ) );
     Command := Menu^.StartMenu;
     DISPOSE ( Menu, Done );
     DISPOSE ( Wn, TypeDone );
     IF ( Command = 0 ) THEN
        EXIT;
     IF ( command = 1 ) THEN
         SingLocalNumber := TRUE
     ELSE
         SingLocalNumber := FALSE;
     IF ( command = 1 ) THEN
        BEGIN
             Line := LineLocal;
             EnterParameter ( 34, 15, 8, Ch, Line,
                 'Введите префикс локального номера', 0,
                LIGHTGRAY, BLUE, LIGHTGRAY, RED );
             IF ( Ch <> #27 ) THEN
                LineLocal := Line
        END

END; { procedure SubCmd423 }

{----------------------------------------------------------}

PROCEDURE SubCmd43;

          { Количество копий }
VAR
   Line : StandartString;
   Ch : CHAR;
   Err : INTEGER;
   Num : WORD;

BEGIN
     STR ( RepeatPrint, Line );
     REPEAT
           EnterParameter ( 34, 14, 3, Ch, Line,
                'Количество копий ', 1,
                LIGHTGRAY, BLUE, LIGHTGRAY, RED );
           IF ( Ch = #27 ) THEN
              EXIT;
           VAL ( Line, Num, Err );
           IF ( Err <> 0 ) THEN
              War ( 'Не числовое значение' )
           ELSE
               IF ( Num < 1 ) THEN
                  War ( 'Не менее 1' );
               IF ( Num > 200 ) THEN
                   War ( 'не более 200' )
     UNTIL ( ( Err = 0 ) AND ( Num <= 200 ) AND ( Num >= 1 ) );
     RepeatPrint := LO ( Num )

END; { procedure SubCmd43 }

{----------------------------------------------------------}

PROCEDURE SubCmd451;

         { Титульная строка }
VAR
   Line : StandartString;
   Ch : CHAR;
   Err : INTEGER;
   Num : WORD;

BEGIN
     Line := LineTitle;
     EnterParameter ( 34, 14, 40, Ch, Line,
             'Введите титульный заголовок ', 0,
                LIGHTGRAY, BLUE, LIGHTGRAY, RED );
     IF ( Ch <> #27 ) THEN
        LineTitle := Line

END; { procedure SubCmd451 }

{----------------------------------------------------------}

PROCEDURE SubCmd452;

       { признак печати имени файла }
VAR
   Line : StandartString;
   Ch : CHAR;
   Err : INTEGER;
   Num : WORD;
   Command : BYTE;
   Wn : TextWindowPtr;
   Menu : MenuCmdPtr;

BEGIN
    IF ( SingFileName ) THEN
       command := 1
    ELSE
       command := 2;
    NEW ( Wn, MakeWindow ( 42, 18, 73, 23, MAGENTA, WHITE ) );
    Wn^.WPrint ( 4, 2, 'Печатать ли имя файла' );
    Wn^.WPrint ( 4, 3, 'на каждой странице ?' );
    Wn^.FrameWindow ( 1, 1, 31, 5, 1, CHR ( 205 ) );
    Wn^.SetShade ( BLACK, BLACK );
    Wn^.PrintWindow;
     NEW ( Menu, SetMenu ( 51, 21, 65, 25, BLUE, WHITE, LIGHTRED, WHITE,
                           BLACK, BLACK, #196, TRUE, 1, Command,
                           NulRunProcedure,
                 SetCmdC ( 3, 2, '   ДА    ',
                 SetCmdC ( 3, 3, '   НЕТ   ', NIL ) ) ) );
     Command := Menu^.StartMenu;
     DISPOSE ( Menu, Done );
     DISPOSE ( Wn, TypeDone );
     IF ( Command = 0 ) THEN
        EXIT;
     SingFileName := ( Command = 1 )

END; { procedure SubCmd452 }

{----------------------------------------------------------}

PROCEDURE SubCmd46;

         { перевод формата }
VAR
   Line : StandartString;
   Ch : CHAR;
   Err : INTEGER;
   Num : WORD;
   Command : BYTE;
   Wn : TextWindowPtr;
   Menu : MenuCmdPtr;

BEGIN
    IF ( PageIgnore ) THEN
       command := 1
    ELSE
        command := 2;
    NEW ( Wn, MakeWindow ( 47, 15, 78, 20, MAGENTA, WHITE ) );
    Wn^.WPrint ( 3, 2, 'Игнорировать ли переводы ' );
    Wn^.WPrint ( 3, 3, 'страниц указанные в файле ?' );
    Wn^.FrameWindow ( 1, 1, 31, 5, 1, CHR ( 205 ) );
    Wn^.SetShade ( BLACK, BLACK );
    Wn^.PrintWindow;
     NEW ( Menu, SetMenu ( 55, 18, 70, 22, BLUE, WHITE, LIGHTRED, WHITE,
                           BLACK, BLACK, #196, TRUE, 1, Command,
                           NulRunProcedure,
                 SetCmdC ( 3, 2, '   ДА    ',
                 SetCmdC ( 3, 3, '   НЕТ   ', NIL ) ) ) );
     Command := Menu^.StartMenu;
     DISPOSE ( Menu, Done );
     DISPOSE ( Wn, TypeDone );
     IF ( Command = 0 ) THEN
        EXIT;
    IF ( command = 1 ) THEN
       PageIgnore := TRUE
    ELSE
        PageIgnore := FALSE

END; { procedure SubCmd46 }

{----------------------------------------------------------}

PROCEDURE SubCmd47;

         { пауза }
VAR
   Line : StandartString;
   Ch : CHAR;
   Err : INTEGER;
   Num : WORD;
   Command : BYTE;
   Wn : TextWindowPtr;
   Menu : MenuCmdPtr;

BEGIN
    IF ( PageWait ) THEN
       command := 1
    ELSE
        command := 2;
    NEW ( Wn, MakeWindow ( 45, 15, 76, 20, MAGENTA, WHITE ) );
    Wn^.WPrint ( 3, 2, 'Делать ли паузу при переходе' );
    Wn^.WPrint ( 3, 3, 'на каждую следующую страницу ?' );
    Wn^.FrameWindow ( 1,1,31,5,1,CHR(205));
    Wn^.SetShade ( BLACK, BLACK );
    Wn^.PrintWindow;
     NEW ( Menu, SetMenu ( 53, 18, 68, 22, BLUE, WHITE, LIGHTRED, WHITE,
                           BLACK, BLACK, #196, TRUE, 1, Command,
                           NulRunProcedure,
                 SetCmdC ( 3, 2, '   ДА    ',
                 SetCmdC ( 3, 3, '   НЕТ   ', NIL ) ) ) );
     Command := Menu^.StartMenu;
     DISPOSE ( Menu, Done );
     DISPOSE ( Wn, TypeDone );
     IF ( Command = 0 ) THEN
        EXIT;
    IF ( command = 1 ) THEN
       PageWait := TRUE
    ELSE
        PageWait := FALSE

END; { procedure SubCmd47 }

{----------------------------------------------------------}

PROCEDURE SubCmd48;

          { Установить количество символов для редактора }
VAR
   Line : StandartString;
   Ch : CHAR;
   Err : INTEGER;
   Num : WORD;

BEGIN
     STR ( MyWordWap, Line );
     REPEAT
           EnterParameter ( 34, 18, 3, Ch, Line,
                'Количество симолов в строке редактора ', 1,
                LIGHTGRAY, BLUE, LIGHTGRAY, RED );
           IF ( Ch = #27 ) THEN
              EXIT;
           VAL ( Line, Num, Err );
           IF ( Err <> 0 ) THEN
              War ( 'Не числовое значение' )
           ELSE
               IF ( Num < 1 ) THEN
                  War ( 'Не менее 1' );
               IF ( Num > 200 ) THEN
                   War ( 'не более 200' )
     UNTIL ( ( Err = 0 ) AND ( Num <= 200 ) AND ( Num >= 1 ) );
     MyWordWap := LO ( Num )

END; { procedure SubCmd48 }

{----------------------------------------------------------}

PROCEDURE SubCmd4A;

          { Установка способа печати }
VAR
   Command : BYTE;
   Menu : MenuCmdPtr;

BEGIN
     IF ( SingVarMod ) THEN
        Command := 4
     ELSE
         IF ( SingMod1 AND ( NOT SingMod2 ) ) THEN
            Command := 2
         ELSE
             IF ( ( NOT SingMod1 ) AND ( SingMod2 ) ) THEN
                Command := 3
             ELSE
                 Command := 1;
     NEW ( Menu, SetMenu ( 40, 15, 70, 21, MAGENTA, WHITE, LIGHTGRAY, BLUE,
                           CYAN, BLACK, #205, TRUE, 1, Command,
                           NulRunProcedure,
                 SetCmdC ( 5, 2, ' Сплошная печать     ',
                 SetCmdC ( 5, 3, ' Нечетные страницы   ',
                 SetCmdC ( 5, 4, ' Четные страницы     ',
                 SetCmdC ( 5, 5, ' Чередующаяся печать ', NIL ) ) ) ) ) );
     Command := Menu^.StartMenu;
     DISPOSE ( Menu, Done );
     CASE Command OF
            1 : BEGIN
                     SingMod1 := TRUE;
                     SingMod2 := TRUE;
                     SingVarMod := FALSE
                END;
            2 : BEGIN
                     SingMod1 := TRUE;
                     SingMod2 := FALSE;
                     SingVarMod := FALSE
                END;
            3 : BEGIN
                     SingMod1 := FALSE;
                     SingMod2 := TRUE;
                     SingVarMod := FALSE
                END;
            4 : BEGIN
                     SingMod1 := TRUE;
                     SingMod2 := TRUE;
                     SingVarMod := TRUE
                END
     END;

END; { procedure SubCmd4A }

{----------------------------------------------------------}

PROCEDURE Config;

VAR
   Menu : MenuBarPtr;
   Ch : CHAR;

BEGIN
     NEW ( Menu,
         SetMenu ( 10, 8, 32, 22, BLUE, WHITE, LIGHTGRAY, BLACK,
           CYAN, BLACK, #205, TRUE, 1, HelpMenuBar,
                 SetCmd ( 3, 3, ' Страницы         ', 1, NEW ( MenuBarPtr,
              SetMenu (  34, 10, 75, 13, BROWN, WHITE, BLACK, GREEN,
              CYAN, BLACK, #196, TRUE, 0, HelpMenuBar,
                    SetCmd ( 2, 2,  ' Первая ', 0, @SubCmd411,
                    SetCmd ( 10, 2, ' Последняя ', 0, @SubCmd412,
                    SetCmd ( 21, 2, ' Строки ', 0, @SubCmd413,
                    SetCmd ( 29, 2, ' Левое поле ', 0, @SubCmd414,
                    NIL ) ) ) ) ) ),
                 SetCmd ( 3, 4, ' Номер            ', 1, NEW ( MenuBarPtr,
              SetMenu ( 34, 11, 78, 14, BROWN, WHITE, BLACK, GREEN,
              CYAN, BLACK, #196, TRUE, 0, HelpMenuBar,
                    SetCmd ( 2, 2,  ' Общий номер ', 0, @SubCmd421,
                    SetCmd ( 15, 2, ' Локальный номер ', 0, @SubCmd423,
                    SetCmd ( 33, 2, ' Нумерация ', 0, @SubCmd422,
                    NIL ) ) ) ) ),
                 SetCmd ( 3, 5, ' Количество копий ', 0, @SubCmd43,
                 SetCmd ( 3, 6, ' Шрифт            ', 1, NEW ( MenuBarPtr,
              SetMenu ( 34, 13, 79, 16, BROWN, WHITE, BLACK, GREEN,
              CYAN, BLACK, #196, TRUE, 0, HelpMenuBar,
                    SetCmd ( 2, 2, ' Шаг ', 0, @DefTypeFont,
                    SetCmd ( 6, 2, ' Стиль ', 0, @DefCondens,
                    SetCmd ( 12, 2,' Режим ', 0, @DefWideFont,
                    SetCmd ( 18, 2,' Отображение ', 0, @DefTypePrint,
                    SetCmd ( 30, 2,' Качество ', 0, @DefRoman,
                    SetCmd ( 39, 2, ' Маш.', 0, @FontMachine,
                    NIL ) ) ) ) ) ) ) ),
                 SetCmd ( 3, 7, ' Титул            ', 1, NEW ( MenuBarPtr,
              SetMenu ( 34, 14, 74, 17, BROWN, WHITE, BLACK, GREEN,
              CYAN, BLACK, #196, TRUE, 0, HelpMenuBar,
                    SetCmd ( 2, 2,  ' Титульная строка ', 0, @SubCmd451,
                    SetCmd ( 20, 2, ' Печать имени файла ', 0, @SubCmd452,
                    NIL ) ) ) ),
                 SetCmd ( 3, 8, ' Перевод формата  ', 0, @SubCmd46,
                 SetCmd ( 3, 9, ' Пауза            ', 0, @SubCmd47,
                 SetCmd ( 3, 10,' Редактор         ', 0, @SubCmd48,
                 SetCmd ( 3, 11,' Принтер          ', 0, @SetPrinter,
                 SetCmd ( 3, 12,' Метод печати     ', 0, @SubCmd4A,
                 NIL ) ) ) ) ) ) ) ) ) ) ) );
     REPEAT
           Ch := Menu^.StartMenu
     UNTIL ( Ch = #27 );
     DISPOSE ( Menu, Done )

END; { procedure Config }

{----------------------------------------------------------}

PROCEDURE SubCmd1;

          { файловое меню }
VAR
   Ch : CHAR;
   Ext : LONGINT;
   Line : STRING;
   Wind, Wk : TextWindowPtr;
   CommandNumber : LONGINT;

BEGIN
     NEW ( Wind, MakeWindow ( 46, 9, 77, 24, LIGHTGRAY, BLACK ) );
     Wind^.SetShade ( CYAN, BLACK );
     Wind^.FrameWindow ( 1, 1, 31, 15, 1, #196 );
     Wind^.WPrint ( 3, 2, '' );
     Wind^.WPrint ( 3, 3,  'F1  - Подсказка' );
     Wind^.WPrint ( 3, 4,  'F2  - Смена диска' );
     Wind^.WPrint ( 3, 5,  'F3  - Просмотр файла' );
     Wind^.WPrint ( 3, 6,  'F4  - Редактирование файла' );
     Wind^.WPrint ( 3, 7,  'F5  - Копирование файла /ов/' );
     Wind^.WPrint ( 3, 8,  'F6  - Переименование ' );
     Wind^.WPrint ( 3, 9,  '      файла /ов/' );
     Wind^.WPrint ( 3, 10, 'F7  - Печать файла /ов/' );
     Wind^.WPrint ( 3, 11, 'F8  - Удаление файла /ов/' );
     Wind^.WPrint ( 3, 12, 'F9  - Создание файла   ' );
     Wind^.WPrint ( 3, 13, 'F10 - Конфигурация' );
     IF ( Sequrity <> 0 ) THEN
        Wind^.WPrint ( 3, 14, 'Ctrl + F2/F3  - Кд/Дкд' );
     Wind^.PrintWindow;
     NEW ( Wk, MakeWindow ( 3, 9, 44, 24, LIGHTGRAY, WHITE ) );
     Wk^.SetShade ( CYAN, BLACK );
     CommandNumber := 1;
     REPEAT
           Line := DirPathLeft;
           DELETE ( Line, LENGTH ( Line ), 1 );
           CHDIR ( Line );
           IF ( IORESULT <> 0 ) THEN
              BEGIN
                   War ( ' Ошибка чтения директория ' );
                   DISPOSE  ( Wind, TypeDone );
                   DISPOSE  ( Wk, TypeDone );
                   EXIT
              END;
           DirCommand := 0;
           Wk^.FrameWindow ( 1, 1, 41, 15, 1, #205 );
           Wk^.WPrint ( 3, 1, ' ' + DirPathLeft + ' ' );
           NEW ( DirStreamPtr,
                 Init ( SortDirList ( BuildDirList ( DirPathLeft ) ) , 500) );
           DirWindow.Init ( Wk, DirStreamPtr );
           DirWindow.SetState ( TRUE, TRUE );
           DirWindow.SetColorText ( WHITE );
           DirWindow.SetColorFon ( LIGHTGRAY );
           DirWindow.SetColorHelp ( BLACK );
           DirWindow.SetColorInsert ( RED );
           DirWindow.SetSingAlt ( TRUE );
           DirWindow.SetLineNumber ( CommandNumber );
           WITH DirWindow DO
                BEGIN
                     Set_Key ( F1, CmdF1 );
                     Set_Key ( F2, CmdF2 );
                     Set_Key ( F3, CmdF3 );
                     Set_Key ( F4, CmdF4 );
                     Set_Key ( F5, CmdF5 );
                     Set_Key ( F6, CmdF6 );
                     Set_Key ( F7, CmdF7 );
                     Set_Key ( F8, CmdF8 );
                     Set_Key ( F9, CmdF9 );
                     Set_Key ( F10, CmdF10 );
                     Set_Key ( Ctl_F1, CmdCtl_F1 );
                     Set_Key ( Ctl_F2, CmdCtl_F2 );
                     Set_Key ( Ctl_F3, CmdCtl_F3 )
                END;
           DirWindow.Control_Inf ( Ext );
           NumberFile := Ext;
           CommandNumber := Ext;
           IF ( DirCommand IN [ 0, 2 ] ) THEN
              CommandNumber := 1;
           IF ( Ext <> 0 ) THEN
              CASE DirCommand OF
                      0 : GetNewPath ( Ext );
                      1 : HelpFileMenu;
                      7 : PrintFiles;
                      3 : ViewFile;
                      4 : EditFile;
                      9 : EditNewFile;
                      5 : CopyFiles;
                      6 : RenameFiles;
                      8 : EraseFiles;
                      2 : NewDriver;
                      10: Config;
                      11: SetPassword;
                      12: CoderFiles;
                      13: DecoderFiles
              END;
           DirWindow.Done;
           DISPOSE ( DirStreamPtr, Done )
     UNTIL ( Ext = 0 );
     DISPOSE ( Wk, TypeDone );
     DISPOSE ( Wind, TypeDone )

END; { procedure SubCmd1 }

{----------------------------------------------------------}

BEGIN
     WRITELN;
     WRITELN ( 'Lprint V 3.5.J  (c) 1990-1992, IPM Group' );
     WRITELN ( '      Software                 Yaroslav Migach' );
     WRITELN ( ' Font designer                 Andrew Buckin' );
     WRITELN;

          {  Тест на изменения в исполняемом коде }
             CheckStart ( PARAMSTR ( 0 ) );

     GETDIR ( 0, StartPath );
     SetBuildFunc;
     IF ( IORESULT <> 0 ) THEN
        BEGIN
             WRITELN ( 'Ошибка дисковой операции', #7 );
             HALT ( 1 );
        END;
     StartSetUp;
     MaxDrivers := GetLastDriver;
     LprintTitle;
     NEW ( MngMenuPtr, SetMenu ( 5, 4, 75, 7, BLACK, YELLOW, GREEN, BLACK,
           CYAN, BLACK, #196, TRUE, 0, HelpMenuBar,
           SetCmd ( 4, 2,  '  Файловое меню  ', 0, @SubCmd1,
           SetCmd ( 23, 2, '  Конфигурация   ', 0, @Config,
           SetCmd ( 42, 2, '  Подсказка  ', 0, @SubCmd2,
           SetCmd ( 58, 2, '   Путь   ',0, @SubCmd3,
           NIL ) ) ) ) ) );
     REPEAT
           Ch := MngMenuPtr^.StartMenu
     UNTIL ( Ch = #27 );
     DISPOSE ( MngMenuPtr, Done );
     DISPOSE ( GWind, UnFrameDone ( #205 ) );
     CHDIR ( StartPath );
     IF ( IORESULT <> 0 ) THEN
        CHDIR ( DirPathLeft );
     IF ( IORESULT <> 0 ) THEN
        BEGIN
        END;
     SaveSetUp;
     WINDOW ( 1, 1, 80, 25 );
     TEXTBACKGROUND ( BLACK );
     TEXTCOLOR ( LIGHTGRAY );
     GOTOXY ( 1, 25 );
     WRITELN

END.
