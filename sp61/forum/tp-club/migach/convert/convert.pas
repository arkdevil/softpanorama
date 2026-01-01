          {-------------------------------------------------}
          {         Convert  V 1.0 for Windows              }
          {-------------------------------------------------}
          { Язык программирования : Borland Pascal V 7.0    }
          { Дата создания : 12.11.1993                      }
          { Дата последних изменений : 12.11.1993           }
          {-------------------------------------------------}
          {  Программа предназначена для перекодировки      }
          {  текстовых файлов с русскими символами из       }
          {  формата MS-DOS 866 code page в формат Windows  }
          {-------------------------------------------------}
          { (c) 1993, Ярослав Мигач                         }
          {-------------------------------------------------}

Program Convert;
{$R Conv.Res }
{$R CDlg.Res }
Uses Objects, WinDos, WinTypes, WinProcs, Strings, OWindows,
  ODialogs, OstdDlgs;
Type
  TConvertApplication = Object ( TApplication )
    { Тип обьекта приложения программы конвертации }
    Procedure InitMainWindow; Virtual;
      { Инициализация главного окна пограммы }
    Procedure InitInstance; Virtual;
      {  Инициализация таблицы акселераторов}
  End; { Object TConvertApplication }
{----------------------------------------------------------}
Const
  id_DosWin = 102;
    { Команда перевода Dos - Windows }
  id_WinDos = 103;
    { Команда перевода Windows - Dos }
  id_Return = 104;
    { Команда окончания сеанса установки опций }
Type
  POptDialog = ^TOptDialog;
    { Тип указателя на обьект диалога опций }
  TOptDialog = Object ( TDialog )
    { Тип обьекта диалога опций }
    Coder : Integer;
      { Тип перекодировки }
    Procedure DosToWindows ( Var Msg : TMessage );
      Virtual id_First + id_DosWin;
        { Установить признак перекодировки Dos - Windows }
    Procedure WindowsToDos ( Var Msg : TMessage );
      Virtual id_First + id_WinDos;
        { Установить признак перекодировки Windows - Dos }
    Procedure Return ( Var Msg : TMessage );
      Virtual id_First + id_Return;
        { Окончание сеанса установки опций }
  End; { Object TOptDialog }
{----------------------------------------------------------}
Const
  cm_File = 201;
    {  команда "Файл" }
  cm_Options = 202;
    {  команда "Опции" }
  cm_Path = 203;
    {  команда "Назначение" }
  cm_Help = 204;
    {  команда "Подсказка" }
  cm_Exit = 205;
    {  команда "Выход" }
Type
  TCoder = ( NoCoder, Dos_Windows, Windows_Dos );
    { Тип возможной перекодировки }
  PMainWin = ^TMainWin;
    { Тип указателя на обьект главного окна программы }
  TMainWin = Object ( TWindow )
    { Тип обьекта главного окна программы }
    DestinationPath : Array [ 0..40 ] Of Char;
      { Путь назначения }
    Coder : TCoder;
      { Текущий тип перекодировки }
    Constructor Init ( AParent : PWindowsObject; ATitle : PChar );
      { Инициализация обьекта }
    Procedure GetWindowClass ( Var AWndClass : TWndClass ); Virtual;
      { Установить новый сласс окна }
    Procedure Files ( Var Msg : TMessage ); Virtual cm_First + cm_File;
      { Обработка команды меню "Файл" }
    Procedure Options ( Var Msg : TMessage ); Virtual cm_First + cm_Options;
      { Обработка команды "Опции" }
    Procedure Path ( Var Msg : TMessage ); Virtual cm_First + cm_Path;
      { Обработка команды "Назначение" }
    Procedure Help ( Var Msg : TMessage ); Virtual cm_First + cm_Help;
      { Обработка команды "Подсказка"  }
    Procedure Quit ( Var Msg : TMessage ); Virtual cm_First + cm_Exit;
      { Обработка команды "Выход"  }
  End; { Object TMainWin}
{----------------------------------------------------------}
Const
  wm_Proc = 101;
    { Сообщение об изменеии процентов }
Type
  PMsgWindow = ^TMsgWindow;
    { Тип указателя на окно сообщения времени обработки }
  TMsgWindow = Object ( TWindow )
    { Тип обьекта окна сообщения времени обработки }
    StartParam : LongInt;
      { Полное значение для завершения процесса }
    Constructor Init ( AParent : PWindowsObject; ATitle : PChar;
      Start : LongInt; sx, sy : Word );
      { Инициализация обьекта }
    Procedure ProcMsg ( Var Msg : TMessage ); Virtual wm_First + wm_Proc;
     { Обработка процентного сообщения }
  End; { Object TMsgWindow }
{==========================================================}
Function t866ToParaGraph ( Line : String ) : String;
  { Преобразование строки из стандарта 866 code page в
   стандарт ParaGraph }
Var
  Index : Byte;
Begin
  For Index := 1 To Length ( Line ) Do Begin
    Case Line [ Index ] Of
      #$80..#$AF : Line [ Index ] := Chr ( Ord ( Line [ Index ] ) + $40 );
      #$E0..#$EF : Line [ Index ] := Chr ( Ord ( Line [ Index ] ) + $10 );
    End; { Case }
  End;
  t866ToParaGraph := Line;
End; { Function t866ToParaGraph }
{----------------------------------------------------------}
Function ParaGraphTot866 ( Line : String ) : String;
  { Преобразование строки из стандарта ParaGraph в стандарт
   866 code page }
Var
  Index : Byte;
Begin
  For Index := 1 To Length ( Line ) Do Begin
    Case Line [ Index ] Of
      #$C0..#$EF : Line [ Index ] := Chr ( Ord ( Line [ Index ] ) - $40 );
      #$F0..#$FF : Line [ Index ] := Chr ( Ord ( Line [ Index ] ) - $10 );
    End; { Case }
  End;
  ParaGraphTot866 := Line;
End; { Function ParaGraphTot866 }
{==========================================================}
Constructor TMsgWindow.Init ( AParent : PWindowsObject; ATitle : PChar;
  Start : LongInt; sx, sy : Word );
  { Инициализация обьекта }
Begin
  TWindow.Init ( AParent, ATitle );
  With Attr Do Begin
    Style := ws_PopupWindow Or ws_Caption Or ws_Child Or ws_Visible;
    X := sx + 80;
    Y := sy + 80;
    W := 400;
    H := 100;
  End;
  StartParam := Start;
End; { Constructor TMsgWindow.Init }
{----------------------------------------------------------}
Procedure TMsgWindow.ProcMsg ( Var Msg : TMessage );
  { Обработка процентного сообщения }
Var
  Proc : Real;
  Line : Array [ 0..60 ] of Char;
  DC : HDC;
  KeyOut : Boolean;
Begin
  Proc := ( Msg.LParam / StartParam ) * 100.0;
  Str ( Proc : 5 : 2, Line );
  DC := GetDC ( HWindow );
  StrCat ( Line, ' % преобразовано    ' );
  SetTextColor ( DC, RGB ( 255, 0, 0 ) );
  KeyOut := TextOut ( DC, 100, 20, Line, StrLen ( Line ) );
  ReleaseDC ( HWindow, DC );
End; { Procedure TMsgWindow.ProcMsg }
{==========================================================}
Procedure TOptDialog.DosToWindows ( Var Msg : TMessage );
 { Установить признак перекодировки Dos - Windows }
Begin
  SendDlgItemMsg ( id_DosWin, bm_SetCheck, 1, LongInt ( 0 ) );
  SendDlgItemMsg ( id_WinDos, bm_SetCheck, 0, LongInt ( 0 ) );
  PMainWin ( Application^.MainWindow )^.Coder := Dos_Windows;
End; { Procedure TOptDialog.DosToWindows }
{----------------------------------------------------------}
Procedure TOptDialog.Return ( Var Msg : TMessage );
  { Окончание сеанса установки опций }
Begin
  SendMessage ( HWindow, wm_Close, 0, LongInt ( 0 ) );
End; { Procedure TOptDialog.Return }
{----------------------------------------------------------}
Procedure TOptDialog.WindowsToDos ( Var Msg : TMessage );
 { Установить признак перекодировки Windows - Dos }
Begin
  SendDlgItemMsg ( id_WinDos, bm_SetCheck, 1, LongInt ( 0 ) );
  SendDlgItemMsg ( id_DosWin, bm_SetCheck, 0, LongInt ( 0 ) );
  PMainWin ( Application^.MainWindow )^.Coder := Windows_Dos;
End; { Procedure TOptDialog.WindowsToDos }
{==========================================================}
Constructor TMainWin.Init ( AParent : PWindowsObject; ATitle : PChar );
  { Инициализация обьекта }
Begin
  TWindow.Init ( AParent, ATitle );
  Attr.Menu := LoadMenu ( hInstance, 'CMENU' );
  Attr.X := 80;
  Attr.Y := 100;
  Attr.W := 500;
  Attr.H := 300;
  FillChar ( DestinationPath, SizeOf ( DestinationPath ), #0 );
  StrCat ( DestinationPath, 'D:\WORK.WIN\LIB' );
  Coder := Dos_Windows;
End; { Constructor TMainWin.Init }
{----------------------------------------------------------}
Procedure TMainWin.GetWindowClass ( Var AWndClass : TWndClass );
  { Установить новый сласс окна }
Begin
  TWindow.GetWindowClass ( AWndClass );
  AWndClass.hIcon := LoadIcon ( hInstance, 'CICON' );
End; { Procedure TMainWin.GetWindowClass }
{----------------------------------------------------------}
Procedure TMainWin.Files ( Var Msg : TMessage );
  { Обработка команды меню "Файл" }
Var
  CurrDir : Array [ 0..fsPathName ] Of Char;
  FileName : Array [ 0..fsPathName ] Of Char;
  FileOut : Array [ 0..fsPathName ] Of Char;
  Fl_In, Fl_Out : Text;
  FlSz : File;
  InSize : LongInt;
  Counter : LongInt;
  S1, S2 : Array [ 0..fsPathName ] Of Char;
  Line : String;
  Dir : Array [ 0..fsPathName ] Of Char;
  Name : Array [ 0..fsFileName ] Of Char;
  Ext : Array [ 0..fsExtension ] Of Char;
  MsgWnd : PWindow;
Begin
  if StrPas ( DestinationPath ) = '' then Begin
    MessageBox ( HWindow, 'Неустановлен путь для преобразования', 'Ошибка',
      mb_OK + mb_IconExclamation );
    Exit;
  End;
  GetCurDir ( CurrDir, 0 );
  if IOResult <> 0 then Begin
    MessageBox ( HWindow, 'Нет доступа в текущий каталог','Ошибка',
      mb_OK + mb_IconExclamation );
    Exit;
  End;
  ChDir ( StrPas ( DestinationPath ) );
  if IOResult <> 0 then Begin
    MessageBox ( HWindow, 'Нет доступа в выходной каталог','Ошибка',
      mb_OK + mb_IconExclamation );
    Exit;
  End;
  ChDir ( StrPas ( CurrDir ) );
  if IOResult <> 0 then Begin
    MessageBox ( HWindow, 'Нет доступа в текущий каталог','Ошибка',
      mb_OK + mb_IconExclamation );
    Exit;
  End;
  FillChar ( FileName, SizeOf ( FileName ), #0 );
  StrCat ( FileName, '*.*' );
  While Application^.ExecDialog ( New ( PFileDialog,
    Init ( @Self, PChar ( sd_FileOpen ), FileName ) ) ) = id_OK Do Begin
    FillChar ( FileOut, SizeOf ( FileOut ), #0 );
    StrCat ( FileOut, DestinationPath );
    StrCat ( FileOut, '\' );
    FileSplit ( FileName, Dir, Name, Ext );
    StrCat ( FileOut, Name );
    StrCat ( FileOut, Ext );
    if FileExpand ( S1, FileName ) = FileExpand ( S2, FileOut ) then Begin
      MessageBox ( HWindow, 'Исходный файл является файлом назначения',
        'Ошибка', mb_OK + mb_IconExclamation );
      Exit;
    End;
    Assign ( FlSz, StrPas ( S1 ) );
    ReSet ( FlSz, 1 );
    if IOResult <> 0 then Begin
      MessageBox ( HWindow, 'Входной файл отсутствует',
        'Ошибка', mb_OK + mb_IconExclamation );
      Continue;
    End;
    InSize := FileSize ( FlSz );
    Close ( FlSz );
    if IOResult <> 0 then;
    Assign ( Fl_In, StrPas ( S1 ) );
    Assign ( Fl_Out, StrPas ( S2 ) );
    ReSet ( Fl_In );
    if IOResult <> 0 then Begin
      MessageBox ( HWindow, 'Входной файл отсутствует',
        'Ошибка', mb_OK + mb_IconExclamation );
      Continue;
    End;
    ReWrite ( Fl_Out );
    if IOResult <> 0 then Begin
      MessageBox ( HWindow, 'Выходной файл неможет быть создан',
        'Ошибка', mb_OK + mb_IconExclamation );
      Close ( Fl_In );
      if IOResult <> 0 then;
      Continue;
    End;
    Counter := 0;
    MsgWnd := New ( PMsgWindow,
      Init ( @Self, 'Преобразование', InSize, Attr.X, Attr.Y ) );
    Application^.MakeWindow ( MsgWnd );
    While Not Eof ( Fl_In ) Do Begin
      ReadLn ( Fl_In, Line );
      if IOResult <> 0 then Begin
        MessageBox ( HWindow, 'Ошибка чтения входного файла',
          'Ошибка', mb_OK + mb_IconExclamation );
        Break;
      End;
      Case Coder Of
        Dos_Windows : Line := t866ToParaGraph ( Line );
        Windows_Dos : Line := ParaGraphTot866 ( Line );
      End; { Case }
      WriteLn ( Fl_Out, Line );
      if IOResult <> 0 then Begin
        MessageBox ( HWindow, 'Ошибка записи выходного файла',
          'Ошибка', mb_OK + mb_IconExclamation );
        Break;
      End;
      Counter := Counter + Length ( Line ) + 2;
      SendMessage ( MsgWnd^.HWindow, wm_Proc, 0, Counter );
    End;
    SendMessage ( MsgWnd^.HWindow, wm_Close, 0, LongInt ( 0 ) );
    Close ( Fl_In );
    if IOResult <> 0 then;
    Close ( Fl_Out );
    if IOResult <> 0 then;
  End;
End; { Procedure TMainWin.Files }
{----------------------------------------------------------}
Procedure TMainWin.Options ( Var Msg : TMessage );
  { Обработка команды "Опции" }
Begin
  Coder := Dos_Windows;
  Application^.ExecDialog ( New ( POptDialog, Init ( @Self, 'CDIALOG' ) ) );
End; { Procedure TMainWin.Options }
{----------------------------------------------------------}
Procedure TMainWin.Path ( Var Msg : TMessage );
  { Обработка команды "Назначение" }
Var
  CurrDir : Array [ 0..fsPathName ] Of Char;
  KeyDir : Boolean;
Begin
  Repeat
    KeyDir := True;
    if Application^.ExecDialog ( New ( PInputDialog,
      Init ( @Self, 'Назначение','Введите путь для преобразования:',
        DestinationPath, SizeOf ( DestinationPath ) ) ) ) <> id_OK then
          Break;
    GetCurDir ( CurrDir, 0 );
    if IOResult <> 0 then Begin
      MessageBox ( HWindow, 'Нет доступа в текущий каталог','Ошибка',
        mb_OK + mb_IconExclamation );
      Exit;
    End;
    ChDir ( StrPas ( DestinationPath ) );
    if IOResult <> 0 then Begin
      MessageBox ( HWindow, 'Нет доступа в выходной каталог','Ошибка',
        mb_OK + mb_IconExclamation );
      KeyDir := False;
    End;
    ChDir ( StrPas ( CurrDir ) );
    if IOResult <> 0 then Begin
      MessageBox ( HWindow, 'Нет доступа в текущий каталог','Ошибка',
        mb_OK + mb_IconExclamation );
      Exit;
    End;
  Until KeyDir;
End; { Procedure TMainWin.Path }
{----------------------------------------------------------}
Procedure TMainWin.Help ( Var Msg : TMessage );
  { Обработка команды "Подсказка"  }
Begin
  Application^.ExecDialog ( New ( POptDialog, Init ( @Self, 'HDIALOG' ) ) );
End; { Procedure TMainWin.Help }
{----------------------------------------------------------}
Procedure TMainWin.Quit ( Var Msg : TMessage );
  { Обработка команды "Выход"  }
Begin
  SendMessage ( HWindow, wm_Close, 0, LongInt ( 0 ) );
End; { Procedure TMainWin.Quit }
{==========================================================}
Procedure TConvertApplication.InitMainWindow;
  { Инициализация главного окна программы }
Begin
  MainWindow := New ( PMainWin, Init ( Nil,
    'Программа перекодировки' ) );
End; {  Procedure TConvertApplication.InitMainWindow }
{----------------------------------------------------------}
Procedure TConvertApplication.InitInstance;
  {  Инициализация таблицы акселераторов}
Begin
  TApplication.InitInstance;
  HAccTable := LoadAccelerators ( hInstance, 'CACCELERATORS' );
End; { Procedure TConvertApplication.InitInstance; }
{==========================================================}
Var
  Conv : TConvertApplication;
  Lib : THandle;
  Dir : Array [ 0..fsPathName ] Of Char;
Begin
  FileSearch ( Dir, 'BWCC.DLL', GetEnvVar ( 'PATH' ) );
  if StrPas ( Dir ) <> '' then Begin;
    Lib := LoadLibrary ( 'BWCC.DLL' );
    Conv.Init ( 'Перекодировщик' );
    Conv.Run;
    Conv.Done;
    FreeLibrary ( Lib );
  End
  else Begin
    MessageBox ( 0, 'Нет библиотеки BWCC.DLL','Критическая ошибка',
      mb_Ok + mb_IconStop + mb_SystemModal );
  End;
End. { Program Convert }
