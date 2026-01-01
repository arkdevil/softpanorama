{ Kiev, Technosoft 1989,1990.  Programmed by Shehovtsov A.L. }
{                              on Turbo-Pascal 5.0           }


{
  Текст программы включен в поставку Локатора и Интегратора, распространяемую
  для участников семинара в КИИГА. В обычную поставку я не включаю 
  исходный текст Интегратора, поэтому о нем не упоминается в описании
  Локатора и Интегратора (в файле VLI.DOC).
}

{
 Данная версия интегратора упрощена и уменьшена в размерах.
 Ранее я писал интегратор под 100 антивирусов, но с появлением полидетекторов,
 таких как DOCTOR Чижова, это стало излишеством. Поэтому я полагаю, что можно
 обойтись 18-ю антивирусами, т.е. их список будет помещаться на экране   
 }


program VirusIntegrator;

{  Works with virus doctors like Norton integrator with Norton Utilities}

{$A+,D-,E-,L-,I-,B-,R-,S-,V-}
{$M 16384,10000,40000}

Uses Dos,CRT,WindTS;

{
  Модуль WindTS является адаптацией модуля Windows из TopSpeedModula
 под Turbo-Pascal версий 4.0 и 5.0 
 и служит для организации полиэкранного (многооконного) интерфейса.
 Локатор и Интегратор максимально используют этот модуль. Некоторые
 процедуры, функции и переменные WindTS соответствуют по выполняемым
 действиям одноименным процедурам, функциям и переменным из стандарт-
 ного модуля CRT. 
  Чтобы вам было легче определить, функция какого из двух модулей
 используется, замечу, что из CRT я взял :

                  ReadKey, KeyPressed, Delay.

  В остальных случаях при использовании CRT я применял явную ссылку
 на него, например:

                  CRT.TextColor


  Еще замечу, что поскольку текст программы Интегратора написан с
 помощью R - технологии, а затем преобразован в "чистый" Паскаль
 препроцессором, то некоторые строки текста выглядят не совсем
 естественно.

}

Const

   VISize   = 23120;             { size of file VI.EXE                }
   LenFName = 80;                { maximum length of file name        }
   Esc      = #27;
   Enter    = #13;
   BackSpace= #8;
   MaxANum  =  18;               { maximum number of antiviruses     }  
   LMenuItem = 60;               { maximum length of menu item       }
   LCmdItem  = 20;               { maximum length of command item    } 
   LWideCmd  = LCmdItem+3;       { три символа- для /C в командной строке }
   
LongLine ='                                                                  '; 

   Press    = ' Press any key to continue ';

   Header   = ' Virus Integrator version 1.2 ';

   Cannot   = ' Can not opened file ';

   Failure  = ' Failured reading from file';
   Incorrect =' Incorrect format of file';
    
   Head =  '  Select Antivirus  ─────────────Enter──Esc';
  

Type FSystemNames = string[ LenFName ];



Var
   DataFile       : FSystemNames;{ файл VI.DAT - полный путь                }
   Menu           : array[1..MaxAnum] of string[LMenuItem];
   Cmd            : array[1..MaxAnum] of string[LCmdItem];
   W              : array[1..3] of WinType;  { 2 - основное меню,
                                               3 - выбор антивируса,
                                               1 - нижнее окно       }

   RANum          : word;        { число прочитанных записей   }
   Disk           : char;        { имя диска, на котором ищутся вирусы       } 
   Home           : FSystemNames;{ каталог, в котором находятся VI.EXE,VI.DAT
                                   а также все антивирусы                    }
   Command_com    : FSystemNames;{ полное имя COMMAND.COM                    }
   CurrDir        : FSystemNames;{ каталог, из которого запущен VI.EXE       }

procedure MakeDownWindow;
{ Создание нижнего окна. Используются только процедуры и переменные из WindTS }
  


BEGIN 
  W[1] := Used;
  CursorOff;
  TextBackground( Green );
  TextColor( White );
  SetFrame( W[1],DoubleFrame,White,Black );
  SetTitle( W[1],Header,CenterUpperTitle );
  Clear;
  
end; {MakeDownWindow}


procedure WindInfo( Var WD : WinDef ; C1,C2,D1,D2 : word; IsFrame : boolean );

{ Описание структуры информационного окна. Тип WinDef импортируется из WindTS}


BEGIN
  WITH

    WD DO
      BEGIN
         X1 := C1;              { Координаты окна }
         X2 := C2;
         Y1 := D1;
         Y2 := D2;
         ForeGround := Yellow;         {  Цвет текста     }
         BackGround := Blue;           {  Цвет фона       }
         CursorOn   := False;          {  Курсор не нужен }
         WrapOn     := True;           {  Перeвод строки нужен }
         Hidden     := True;           {  Окно пока не выводится на экран}
         FrameOn    := IsFrame;        {  Нужна ли рамка  }
         FrameDef   := SingleFrame;    {Если да - стандартную (а можно и свою описать)}
         FrameFore  := White;          {  Цвет символов рамки }
         FrameBack  := Blue;           {  Цвет текста рамки   }
      END

end; {WindInfo}


procedure SelectDisk;

{ Рисуется меню выбора диска, на котором будут искаться вирусы}

Var
   W  : WinType;             { Указатель на создаваемое окно }
   WD : WinDef;              { Описание окна                 }
   MD : MenuDef;             { Описание меню                 }
   CurItem : word;
   PressedKey : integer;
   M  : TextMenu;            { Массив указателей на строки меню }
   L  : word;


BEGIN
  WITH   MD DO
      BEGIN
        WindInfo( WD,45,65,12,18,True );
        ItemLength      := 3;                   {Длина элемента меню}
        Rows            := 5;                   {Число строк меню   }
        Columns         := 6;                   {Число столбцов меню}
        QItems          := 26;                  {Число элементов меню}
        ActiveColorFore := White;
        ActiveColorBack := Red;
        MaxFuncKey      := 0;
        MaxSingleKey    := 0;
        CurItem         := ORD(Disk)-ORD('A')+1;
        LoadMem( M , QItems, ItemLength );     {Память под элементы меню}
      END ;
  FOR L:=1 to 26 DO
    BEGIN                 {Заполнение строк меню}
      M^[L]^ := '   ';
      M^[L]^[2]:=CHR(ORD('A')+L-1);
    END ;
  W:=MakeMenu(WD,MD,M);                              {Создать меню}
  SetTitle(W,' Select drive ', CenterUpperTitle );   { Создать рамку меню}
  ActiveMenu(W,M,CurItem,PressedKey);{ Вывести меню на экран и активизировать его}
  Disk := CHR(ORD('A')+CurItem-1);   { Обработка результата (имя диска)     }
  UnLoadMem(M,MD.QItems,MD.ItemLength);{ Освободить память, взятую для меню        }
  CloseWin(W);                   { Закрыть (уничтожить) окно меню            }


end;{SelectDisk}



procedure WindMenu( Var WD : WinDef ; Var MD : MenuDef ;
                    Var M  : TextMenu ; A1,A2,B1,B2 : word );

{ Описание структуры вертикального меню (для выбора действия и/или
  для выбора антивируса
}
BEGIN
  WITH   MD DO
      BEGIN
        WindInfo( WD,A1,A2,B1,B2,True );
        ItemLength      := A2-A1-1;
        Rows            := B2-B1-1;
        Columns         := 1;
        QItems          := Rows;
        ActiveColorFore := White;
        ActiveColorBack := Red;
        MaxFuncKey      := 0;
        MaxSingleKey    := 0;
        LoadMem( M , QItems, ItemLength );
      END


end;{WindMenu}


procedure RunAnti( Num : word; Many : Boolean; Var PrEsc : Boolean);
{
 Запуск антивируса по его номеру (Num). Приходится преодолевать трудности,
 связанные с тем, что вирусные доктора "не признают" модуль WindTS
}
Var
  C        : char;
  SaveMode : word;
  way      : string[3];
  ComLine  : string[3];
  CodeStr  : string[3];

procedure TextErr( S1,S2 : string;ClFlag : Boolean );
{ Сообщение об ошибках. }

BEGIN
  CRT.TextColor(CRT.LightRed);
  CRT.TextBackGround(CRT.Black);;
  IF ClFlag THEN
    BEGIN
      CRT.ClrEol;
    END ;
  Write(S1);
  CRT.TextColor(CRT.White);;
  IF ClFlag THEN
    BEGIN
      CRT.ClrEol;
    END ;
  Write(S2);
end;{TextErr}

procedure GoodBuy;
{ Текст, выводимый после отработки каждого из антивирусов}
BEGIN
  ChDir(CurrDir);
  CRT.TextColor(CRT.Cyan);
  CRT.TextBackGround(CRT.Black);
  CRT.GoToXY(20,25);
  CRT.ClrEol;
  Write( Press );;
  IF Many THEN
    BEGIN
      Write('or');
      CRT.TextColor(CRT.White);
      Write(' Esc ');
      CRT.TextColor(CRT.Cyan);
      Write('to stop');
    END ;
  C := ReadKey;
  PrEsc := C = Esc;
  TextMode(SaveMode);

end;{GoodBuy}




BEGIN
  SaveMode:=LastMode;
  TextMode(LastMode);
  way := ' :\';
  way[1]:=Disk;
  ChDir(way);;
  IF IOResult<>0 THEN
    BEGIN
      CRT.GoToXY(20,24);
      TextErr('Can not jump to ',way,TRUE );
    END
  ELSE
    BEGIN              { Starting antivirus  }
      ComLine := '/C ';
      exec( Command_com,ConCat(ComLine,Home,Cmd[Num]));;
      CASE DosError OF

        0:
          BEGIN
            CRT.TextColor(CRT.White);
            CRT.TextBackground(CRT.Black);
            CRT.GoToXY(20,24);
            Write(Cmd[Num]);
            CRT.TextColor(CRT.Cyan);
            write(' finished.');;
            IF Many THEN
              BEGIN
                Write('   (',Num,' of ',RANum,')');
              END
          END ;
        8:
          BEGIN
            CRT.GoToXY(20,24);
            TextErr('Not enough memory to run ',Cmd[Num],TRUE);

          END ;
        2:
          BEGIN
            CRT.GoToXY(20,24);
            TextErr('Wasn''t finded ',Cmd[Num],FALSE);
            TextErr('   or ',Command_com,FALSE);
            TextErr(' to run it','',TRUE);

          END
      ELSE
        BEGIN
          CRT.GoToXY(20,24);
          TextErr('Some error with ',Cmd[Num],FALSE);
          Str(DosError,CodeStr);
          TextErr('   DosError code = ',CodeStr,TRUE);
        END
      END
    END ;
  WHILE KeyPressed DO
    BEGIN
      C := ReadKey;
    END ;
  GoodBuy;



end;{RunAnti}




procedure AntivirMenu;

{ Рисование на экране меню выбора антивируса. }

Var
  WD : WinDef;
  MD : MenuDef;
  M  : TextMenu;
  PressedKey : integer;
  CurItem    : word;
  PressedEsc : Boolean;

procedure CycleFill;

{ Закачка текстов в элементы меню. }

Var k : word;
BEGIN
  FOR k := 1 to MaxANum DO
    BEGIN
      M^[k]^:=LongLine;;
      IF k <= RANum THEN
        BEGIN
          Move(Menu[k][1],M^[k]^[1],Length(Menu[k]));
        END
    END
end;{CycleFill}

BEGIN
  WITH MD DO
      BEGIN
        Hide(W[2]);
        WindMenu(WD,MD,M,8,8+LMenuItem+2,2,2+MaxANum+1);
        CurItem      := 1;
        PressedKey   := 2;
        MaxSingleKey := 2;
        SingleKey[1] := Esc;
        SingleKey[2] := Enter;
        MD.QItems    := RANum;

      END ;
  WHILE PressedKey <> 1 DO
    BEGIN
      CycleFill;
      W[3]:=MakeMenu(WD,MD,M);
      SetTitle(W[3],Head,LeftUpperTitle);
      ActiveMenu(W[3],M,CurItem,PressedKey);
      CloseWin(W[3]);;
      IF PressedKey = 2 {Enter} THEN
        BEGIN
          RunAnti(CurItem,False,PressedEsc);
          Hide( W[1] );
          PutOnTop( W[1] );
        END
    END ;
  PutOnTop(W[2]);
  UnloadMem(M,MaxANum,MD.ItemLength);
end;{AntivirMenu}





procedure DataLoad;

{ Чтение файла VI.DAT. Способ, которым получен его полный путь, не был
  допустим в Turbo-Pascal 4.0
}
Var
   C   : char;
   F   : Text;
   EOF : Boolean;
   Atr : word;
   S   : SearchRec;

procedure Data0;
{ Получение полного пути файла VI.DAT }
BEGIN
  Home := ParamStr(0);;
  WHILE (Home[0] <> #0 ) and (Home[Length(Home)] <> '\' ) DO
    BEGIN
      Dec( Home[0] );
    END ;
  DataFile := Concat(Home,'VI.DAT');

end; {Data0}


procedure Data1;

{ Чтение файла VI.DAT }


BEGIN
  IF IOResult <> 0 THEN
    BEGIN
      WriteLn(Cannot,'  ',DataFile);
      Halt;
    END
  ELSE
    BEGIN
      RANum:=0;
      EOF:=SeekEOF(F);;
      WHILE (NOT EOF)AND(RANum<MaxANum) DO
        BEGIN
          INC(RANum);
          ReadLn(F,Menu[RANum]);
          EOF:=SeekEOF(F);;
          IF (NOT EOF) AND (Length(Menu[RANum])>0) THEN
            BEGIN
              ReadLn(F,Cmd[RANum]);
              EOF := SeekEOF(F);;
              IF (Length(Cmd[RANum])=0) THEN
                BEGIN
                  WriteLn(Incorrect,'   ',DataFile);
                  DEC(RANum);
                  WriteLn('Number of correct records: ',RANum);
                  EOF := TRUE;
                  WriteLn(Press);
                  C := ReadKey;
                END
            END
          ELSE
            BEGIN
              WriteLn(Incorrect,'  ',DataFile);
              Dec(RANum);
              WriteLn('Number of correct records: ',RANum);

              WriteLn(Press);
              C := ReadKey;
              EOF := TRUE;
            END
        END ;
      Close(F);
      SetFAttr(F,Atr);;
      IF RANum=0 THEN
        BEGIN
          WriteLn('File ',DataFile,' is empty ');
          WriteLn('or has incorrect format');
          Halt;
        END
    END

end;{Data1}


procedure CheckVISize;

{ Самоконтроль! Если вирус заразит файл VI.EXE то его размер (как правило)
  изменится.
}

Var
    C : Char;
BEGIN
  FindFirst(ParamStr(0),AnyFile,S );;
  IF DosError = 0 THEN
    BEGIN

      IF S.Size <> VISize THEN
        BEGIN
          CRT.ClrScr;
          CRT.TextColor(CRT.Red);
          WriteLn('Danger!!! Don''t use me!');
          CRT.TextColor( CRT.White );
          WriteLn('I was infected by some virus.');
          WriteLn('My real size is ',VISize,' bytes but now it is ',S.Size,' bytes.');
          WriteLn;
          WriteLn( Press );
          C := ReadKey;
          Halt( 1 );
        END
    END
  ELSE
    BEGIN
      WriteLn( Cannot,' ',ParamStr(0) );
      Halt;
    END



end;{CheckVISize}


BEGIN
  CheckVISize;
  GetDir(0,CurrDir);;
  IF IOResult<>0 THEN
    BEGIN
      WriteLn('Can not get name',' of current directory');
      Halt;

    END
  ELSE
    BEGIN
      Disk := UpCase(CurrDir[1]);
    END ;
  Command_com :=GetEnv('COMSPEC');
  ;
  IF IOResult<>0 THEN
    BEGIN
      WriteLn('Can not finded ','COMMAND.COM');
      Halt;
    END
  ELSE
    BEGIN
      FindFirst( Command_com,AnyFile,S);;
      IF DosError <> 0 THEN
        BEGIN
          WriteLn('Can not finded ',Command_com,' to run antiviruses.');
          Halt;
        END
    END ;
  Data0;
  Assign(F,DataFile);
  GetFAttr(F,Atr);
  SetFAttr(F,0);
  ReSet(F);
  Data1;

end;{DataLoad}


procedure ShowPreface;

{ Рисование на экране начальной информации }

Var W   : WinType;
    WD  : WinDef;
    i,j : word;
    C   : char;
BEGIN
  WITH WD DO
      BEGIN
         WindInfo( WD,23,56,9,15,True );
         W := OpenWin( WD );
         WrLn;
         WrStr(' KIEV   TechnoSoft  1989, 1990 ');
         WrLn;
         WrLn;

         WrStr(Header);
         PutOnTop( W );
         i := 1;
      END ;
  WHILE (Not KeyPressed ) AND ( i < 150 ) DO
    BEGIN
      delay( 40 );
      INC( i );
    END ;
  WHILE KeyPressed DO
    BEGIN
      C := ReadKey;
    END ;
  CloseWin( W );

end; {ShowPreface}



procedure ShowFinal;    { Завершение работы }
BEGIN
  CursorOn;
  RestoreMode;
end; {ShowFinal}


procedure  PrintHelp;

{ Вывод мини-рекламы и авторских прав }

Var
  WD : WinDef;
  W  : WinType;
  C  : char;


BEGIN
  WHILE KeyPressed DO
    BEGIN
      C := ReadKey;
    END ;
  WindInfo(WD,8,71,4,20,True);
  W := OpenWin( WD );
  SetTitle(W,' Info ',CenterUpperTitle );
  SetFrame(W,'╒═╕││╘═╛',WD.Foreground,WD.Background);

  WrStr(' You started ');
  TextColor(LightCyan);
  WrStr('copyfree Virus Integrator');
  TextColor(Yellow);
  WrStr(' which aim is to help');
  WrLn;
  WrStr('you in detecting of viruses on disk(ette).');
  WrLn;
  TextColor(LightCyan);
  WrStr(' Virus Integrator');
  TextColor(Yellow);
  WrStr(' works with file VI.DAT, where defined all');
  WrLn;
  WrStr('antiviruses you');
  WrStr(' want to run. You can define till 18 names');
  WrLn;
  WrStr('of antiviruses in this file.');
  WrLn;
  TextColor(LightCyan);
  WrStr(' Virus Integrator');
  TextColor(Yellow);
  WrStr(' proposes you to run all antiviruses one by');
  WrLn;
  WrStr('one, or to run only one from them defined by you with the');
  WrLn;
  WrStr('help of menu <Select Antivirus>. You can also define drive');
  WrLn;
  WrStr('where to search viruses using menu <Select drive>.');
  WrLn;
  WrLn;
  WrLn;
  WrLn;
  TextColor(LightCyan);
  WrStr('  Virus Integrator');
  TextColor(Yellow);
  WrStr(' was written by Shehovtsov Alexander, using');
  WrLn;
  WrStr('Turbo-Pascal 5.0, window manager WindTS.TPU and R-technology.');
  WrLn;
  GoToXY(20,WhereY);
  TextColor(White);
  TextBackground(Red);
  WrStr(Press);

  PutOnTop(W);
  c := ReadKey;
  CloseWin(W);

end; {PrintHelp}


procedure RunAll;

{ Запуск всех антивирусов, имена которых прочитаны из VI.DAT }

Var
   i    : word;
   Stop : Boolean;
BEGIN
  i := 1;
  Stop:=False;;
  WHILE (i <= RANum) AND NOT Stop DO
    BEGIN
      RunAnti(i,TRUE,Stop);
      Inc(i);
    END ;
  Hide(W[1]);
  PutOnTop(W[1]);
end;{RunAll}

procedure MainProcedure;

{ Головное меню и запуск процедур - действий в меню }

Var CurItem    :  word;
    PressedKey :  integer;
    M          :  TextMenu;
    MD         :  MenuDef;
    WD         :  WinDef;
    CC         :  char;


BEGIN
  WHILE KeyPressed DO
    BEGIN
      CC := ReadKey;
    END ;
  WITH   MD DO
      BEGIN
        WindMenu(WD,MD,M,28,52,9,15);
        M^[1]^ := ' Start all Antiviruses ';
        M^[2]^ := '  Search on drive   A: ';
        M^[2]^[21] := Disk;
        M^[3]^ := '   Select Antivirus    ';
        M^[4]^ := '         Info          ';
        M^[5]^ := '         Quit          ';
        W[2] := MakeMenu( WD,MD,M );
        SetTitle( W[2],' Main Menu ',CenterUpperTitle );
        CurItem := 1;
      END ;
  WHILE CurItem <> 5 DO
    BEGIN
      ActiveMenu(W[2],M,CurItem,PressedKey );;
      CASE  CurItem OF

        1:
          BEGIN
            RunAll;
          END ;
        2:
          BEGIN
            SelectDisk;
            M^[2]^[21]:=Disk;
          END ;
        3:
          BEGIN
            AntivirMenu;
          END ;
        4:
          BEGIN
            PrintHelp;
          END ;
        5:
          BEGIN
            Hide(W[2]);
          END
        END
    END

end; {MainProcedure}

{ Тело программы VI.PAS }
BEGIN
  DataLoad;

  InitWindows( Screen25x80 );
  CheckBreak := False;
  MakeDownWindow;
  ShowPreface;
  MainProcedure;
  ShowFinal;

end. {VirusIntegrator}





