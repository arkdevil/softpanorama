

               {----------------------------------------------}
               {  Модуль MenuBar  V 1.1  пакета  TURBO SUPPORT}
               {  Язык программирования Turbo Pascal V 6.0    }
               {----------------------------------------------}
               { Дата последних изменений : 14/08/1991        }
               {----------------------------------------------}
               {      Модуль включает в себя обьект для       }
               {    работы  с древовидным многоуровневым      }
               {              командным меню                  }
               {----------------------------------------------}
               { (c) 1991, Мигач Ярослав                      }
               {----------------------------------------------}


UNIT MnBar;

{$IFDEF DEBUGMENU}
      {$D+,L+,R+,S+}
{$ELSE}
      {$D-,L-,R-,S-}
{$ENDIF}

{$F+,O+,I-,V-,B-,A+}

INTERFACE

USES Crt, Dos, Def, FKey11, TWindow;

TYPE

    MenuBarPtr = ^MenuBar;
                {  указатель на обьект управления меню }

    MenuCommandPtr = ^MenuCommand;
                { указатель на элемент списка команд меню }

    MenuCommand = RECORD   {  список команд меню  }

                        X, Y : BYTE;
                           {  координаты команды в окне  }

                        LnCommand : StandartString;
                           {  строковое значение команды }

                        NextCommand : MenuCommandPtr;
                            { указатель на следующий элемент списка команд }

                        PrevCommand : MenuCommandPtr;
                            { указатель на предшествующий элемент  }
                            {         списка команд                }

                        CASE Key : BYTE OF { ( по признаку подчинения )  }

                              0  : ( RunCommand : ^RunProcedure; );
                                   { исполняемая процедура   }

                              1  : ( SubMenuPtr : MenuBarPtr;   );
                                   { подменю       }
                  END;



    MenuBar = OBJECT ( Control_Func_Key ) { обьект управляющий системой }
                                          {            меню             }

                    Num : BYTE;
                        { номер текущей команды меню }

                    Key : BOOLEAN;
                        { признак подключения нижнего уровня по управлению }

                    x1, y1, x2, y2 : BYTE;
                        { координаты окна меню  }

                    HowBar  : BYTE;
                        { признак направления меню  }

                    ColorFon, ColorSymbol : BYTE;
                        { основной цвет фона и символов  }

                    ColorFonLine, ColorSymbolLine : BYTE;
                        { цвет фона и символов активной строки  }

                    ColorFonShade, ColorSymbolShade : BYTE;
                        { цвет символов и фона тени }

                    FrameSymbol : CHAR;
                        { символ рамки  }

                    SingShade   : BOOLEAN;
                        { признак тени  }

                    FirstCmdPtr : MenuCommandPtr;
                        { первая команда меню }

                    WindowPtr : TextWindowPtr;
                        { рабочее окно текущего уровня меню }

                    HelpProc : RunProcedure;
                        { процедура подсказки по F1 }

              CONSTRUCTOR SetMenu ( kx1,ky1,kx2,ky2,ClFon,ClSym,ClFonLn,
                                  ClSymLn, ClFonSh, ClSymSh : BYTE;
                                  FrmSb : CHAR; SngShd : BOOLEAN; Hb : BYTE;
                                  Proc :   RunProcedure;
                                  CmdPtr : MenuCommandPtr );
                        { установка параметров меню  }

              FUNCTION StartMenu  : CHAR;
                        { запуск меню  }

              Destructor Done;
                        { очистка меню  }

              END; { object MenuBar }


FUNCTION SetCmd ( kx, ky : BYTE; Line : StandartString;
         Key : BYTE; Cmd : POINTER; Next : MenuCommandPtr )
                            : MenuCommandPtr;
                 { функция установки команды  }



IMPLEMENTATION

VAR
   Start : RunProcedure;

{----------------------------------------------------------}

CONSTRUCTOR MenuBar.SetMenu ( kx1,ky1,kx2,ky2,ClFon,ClSym,ClFonLn,
                                  ClSymLn, ClFonSh, ClSymSh : BYTE;
                                  FrmSb : CHAR; SngShd : BOOLEAN; Hb : BYTE;
                                  Proc : RunProcedure;
                                  CmdPtr : MenuCommandPtr );

       {              установка параметров меню                  }

       {  kx1, ky1, kx2, ky2 -  координаты окна создавамого меню       }
       {  ClFon, ClSym - цвет фона и цвет символов окна создаваемого   }
       {                 меню                                          }
       {  ClFonLn, ClSymLn - цвет фона и символов активной строки      }
       {  FrmSb - символ рамки                                         }
       {  SngShd - признак наличия тени                                }
       {  Hb - если 0 то меню считается горизонтальным,                }
       {        если 1 то вертикальным                                 }
       {  CmdPtr - указатель на описание первой команды меню           }


BEGIN
     x1 := kx1;
     x2 := kx2;
     y1 := ky1;
     y2 := ky2;
     ColorFon := ClFon;
     ColorSymbol := ClSym;
     ColorFonLine := ClFonLn;
     ColorSymbolLine := ClSymLn;
     ColorFonShade := ClFonSh;
     ColorSymbolShade := ClSymSh;
     FrameSymbol := FrmSb;
     SingShade := SngShd;
     FirstCmdPtr :=  CmdPtr;
     HowBar := Hb;
     Num := 1;
     WindowPtr := NIL;
     HelpProc := Proc

END; { constructor MenuBar.SetMenu }

{----------------------------------------------------------}

FUNCTION MenuBar.StartMenu : CHAR;

              {          запуск меню        }
       {  возвращает последний код нажатия клавиши при возврате из меню }


VAR
   Ch : CHAR;
   TempPtr, FindPtr : MenuCommandPtr;
   Index : BYTE;

PROCEDURE TypeMenu;

BEGIN
     Index := 1;
     FindPtr := FirstCmdPtr;
     WHILE ( FindPtr <> NIL ) DO
           BEGIN
                IF ( Index = Num ) THEN
                   BEGIN
                        WindowPtr^.SetColorFon ( ColorFonLine );
                        WindowPtr^.SetColorSymbol ( ColorSymbolLine );
                        WindowPtr^.WPrint ( FindPtr^.X, FindPtr^.Y,
                                 FindPtr^.LnCommand );
                        TempPtr := FindPtr
                   END
                ELSE
                    WindowPtr^.WPrint ( FindPtr^.X, FindPtr^.Y,
                              FindPtr^.LnCommand );
                WindowPtr^.SetColorFon ( ColorFon );
                WindowPtr^.SetColorSymbol ( ColorSymbol );
                FindPtr := FindPtr^.NextCommand;
                INC ( Index )
           END;
    WindowPtr^.PrintWindow

END; { procedure TypeMenu }

BEGIN
     NEW ( WindowPtr, MakeWindow ( x1, y1, x2, y2,
                                  ColorFon, ColorSymbol ) );
     IF ( SingShade ) THEN
        BEGIN
             WindowPtr^.SetShade ( ColorFonShade, ColorSymbolShade );
             WindowPtr^.FrameWindow ( 1, 1, ( x2 - x1 ), ( y2 - y1 ),
                                      1, FrameSymbol )
        END
     ELSE
         WindowPtr^.FrameWindow ( 1, 1, ( x2 - x1 + 1 ), ( y2 - y1 + 1 ),
                     1, FrameSymbol );
     TempPtr := FirstCmdPtr;
     Key := TRUE;
     REPEAT
           TypeMenu;
           IF ( ( Key ) OR ( TempPtr^.Key = 0 ) ) THEN
              BEGIN
                   Ch := ' ';
                   Ch := GetKey;
                   IF ( ( SingKey ) AND ( Ch = #0 ) ) THEN
                      Ch := GetKey;
              END;
           CASE Ch OF
                #$0D        : BEGIN
                                   CASE TempPtr^.Key OF
                                           0  : BEGIN
                                                     @Start :=
                                                        TempPtr^.RunCommand;
                                                     Start;
                                                     Ch := #27
                                                END;
                                           1  :  Ch :=
                                               TempPtr^.SubMenuPtr^.StartMenu
                                   END;
                                   IF ( Ch <> #27 ) THEN
                                      Key := FALSE
                                   ELSE
                                       BEGIN
                                            Key := TRUE;
                                            Ch := ' '
                                       END
                              END;

                Arrow_Up    : IF ( ( HowBar = 1 ) AND ( Num > 1 ) ) THEN
                                 BEGIN
                                      FindPtr := FirstCmdPtr;
                                      WHILE ( FindPtr^.NextCommand <>
                                              TempPtr ) DO
                                             FindPtr := FindPtr^.NextCommand;
                                      DEC ( Num );
                                      TempPtr := FindPtr;
                                      TypeMenu;
                                      IF ( ( NOT key ) AND
                                         ( TempPtr^.Key = 1 ) ) THEN
                                         BEGIN
                                             Ch := TempPtr^.SubMenuPtr^.
                                                             StartMenu;
                                             IF ( Ch <> #27 ) THEN
                                                 Key := FALSE
                                             ELSE
                                                 BEGIN
                                                      Key := TRUE;
                                                      Ch := ' '
                                                 END
                                         END
                                 END
                              ELSE
                                  IF ( ( HowBar = 1 ) AND ( NUM <= 1 )
                                     AND ( NOT key ) ) THEN
                                     Ch := #$0D;


                Arrow_Down  : IF ( ( HowBar = 1 ) AND
                                 ( TempPtr^.NextCommand <> NIL ) ) THEN
                                 BEGIN
                                      TempPtr := TempPtr^.NextCommand;
                                      INC ( NUM );
                                      TypeMenu;
                                      IF ( ( NOT key ) AND
                                         ( TempPtr^.Key = 1 ) ) THEN
                                         BEGIN
                                             Ch := TempPtr^.SubMenuPtr^.
                                                             StartMenu;
                                             IF ( Ch <> #27 ) THEN
                                                 Key := FALSE
                                             ELSE
                                                 BEGIN
                                                      Key := TRUE;
                                                      Ch := ' '
                                                 END
                                         END
                                 END
                              ELSE
                                  IF ( ( HowBar = 1 ) AND ( TempPtr^.
                                       NextCommand = NIL ) AND
                                       ( NOT key ) ) THEN
                                     Ch := #$0D;

                Arrow_Left  : IF ( ( HowBar = 0 ) AND ( Num > 1 ) ) THEN
                                 BEGIN
                                      FindPtr := FirstCmdPtr;
                                      WHILE ( FindPtr^.NextCommand <>
                                              TempPtr ) DO
                                             FindPtr := FindPtr^.NextCommand;
                                      DEC ( Num );
                                      TempPtr := FindPtr;
                                      TypeMenu;
                                      IF ( ( NOT key ) AND
                                         ( TempPtr^.Key = 1 ) ) THEN
                                         BEGIN
                                             Ch := TempPtr^.SubMenuPtr^.
                                                             StartMenu;
                                             IF ( Ch <> #27 ) THEN
                                                 Key := FALSE
                                             ELSE
                                                 BEGIN
                                                      Key := TRUE;
                                                      Ch := ' '
                                                 END
                                         END
                                 END
                              ELSE
                                  IF ( ( HowBar = 0 ) AND ( NUM <= 1 )
                                     AND ( NOT key ) ) THEN
                                     Ch := #$0D;

                Arrow_Right : IF ( ( HowBar = 0 ) AND
                                 ( TempPtr^.NextCommand <> NIL ) ) THEN
                                 BEGIN
                                      TempPtr := TempPtr^.NextCommand;
                                      INC ( NUM );
                                      TypeMenu;
                                      IF ( ( NOT key ) AND
                                         ( TempPtr^.Key = 1 ) ) THEN
                                         BEGIN
                                             Ch := TempPtr^.SubMenuPtr^.
                                                             StartMenu;
                                             IF ( Ch <> #27 ) THEN
                                                 Key := FALSE
                                             ELSE
                                                 BEGIN
                                                      Key := TRUE;
                                                      Ch := ' '
                                                 END
                                         END
                                  END
                              ELSE
                                  IF ( ( HowBar = 0 ) AND ( TempPtr^.
                                       NextCommand = NIL ) AND
                                       ( NOT key ) ) THEN
                                     Ch := #$0D;

                F1         :  HelpProc
           END
     UNTIL ( ( Ch = #27 )
             OR ( ( HowBar = 0 ) AND ( Ch IN [ Arrow_Up, Arrow_Down ] ) )
             OR ( ( HowBar = 1 ) AND ( Ch IN [ Arrow_Left, Arrow_Right ]
                          ) ) );
     DISPOSE ( WindowPtr, TypeDone );
     WindowPtr := NIL;
     StartMenu := Ch

END; { procedure MenuBar.StartMenu }


{----------------------------------------------------------}

DESTRUCTOR MenuBar.Done;
               {         очистка меню  }

VAR
   TempPtr, FindPtr : MenuCommandPtr;

BEGIN
     WHILE ( FirstCmdPtr^.NextCommand <> NIL ) DO
           BEGIN
                TempPtr := FirstCmdPtr;
                WHILE ( TempPtr^.NextCommand <> NIL ) DO
                      BEGIN
                           FindPtr := TempPtr;
                           TempPtr := TempPtr^.NextCommand
                      END;
                IF ( TempPtr^.Key = 1 ) THEN
                   DISPOSE ( TempPtr^.SubMenuPtr, Done );
                DISPOSE ( TempPtr );
                FindPtr^.NextCommand := NIL
           END;
     IF ( FirstCmdPtr^.Key = 1 ) THEN
         DISPOSE ( FirstCmdPtr^.SubMenuPtr, Done );
     DISPOSE ( FirstCmdPtr )

END; { destructor MenuBar.Done }

{----------------------------------------------------------}

FUNCTION SetCmd ( kx, ky : BYTE; Line : StandartString;
         Key : BYTE; Cmd : POINTER; Next : MenuCommandPtr )
                            : MenuCommandPtr;

                   {  функция установки команды  }
           { возвращает указатель на описатель команды меню }

        { kx, ky -  координаты команды меню в окне                }
        { Line  -  строковое значение ( имя ) команды             }
        { Key   -  признак наличия под-меню или исполняемой       }
        {           команды                                       }
        {          0 - исполняемая команда                        }
        {          1 - указатель на обьект меню                   }
        { Cmd   - либо указатель на исполняемую команду, либо     }
        {         указатель на обьект меню                        }
        { Next  -  указатель на следующий описатель команды меню  }

VAR
    TempPtr : MenuCommandPtr;
    Proc : POINTER ABSOLUTE Cmd;
    Mnu  : MenuBarPtr ABSOLUTE Cmd;

BEGIN
     NEW ( TempPtr );
     TempPtr^.x := kx;
     TempPtr^.y := ky;
     TempPtr^.LnCommand := Line;
     TempPtr^.Key := Key;
     CASE Key OF
          0  : TempPtr^.RunCommand := Proc;
          1  : TempPtr^.SubMenuPtr := Mnu;
     END;
     TempPtr^.NextCommand := Next;
     SetCmd := TempPtr

END; { function SetCmd }

{----------------------------------------------------------}

END.