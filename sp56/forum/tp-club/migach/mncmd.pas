

               {----------------------------------------------}
               {  Модуль MenuCmd  V 1.0 пакета  TURBO SUPPORT }
               {  Язык программирования Turbo Pascal V 6.0    }
               {----------------------------------------------}
               { Дата последних изменений : 14/08/1991        }
               {----------------------------------------------}
               {      Модуль включает в себя обьект для       }
               {         работы  с  командным меню            }
               {----------------------------------------------}
               { (c) 1991, Мигач Ярослав                      }
               {----------------------------------------------}



UNIT MnCmd;

{$IFDEF DEBUGMENU}
      {$D+,L+,R+,S+}
{$ELSE}
      {$D-,L-,R-,S-}
{$ENDIF}

{$F+,O+,I-,V-,B-,A+}

INTERFACE

USES Crt, Dos, Def, FKey11, TWindow;

TYPE

    MenuCmdPtr = ^MenuCmd;
                {  указатель на обьект управления меню }

    MenuCommandCPtr = ^MenuCommandC;
                { указатель на элемент списка команд меню }

    MenuCommandC = RECORD   {  список команд меню  }

                        X, Y : BYTE;
                           {  координаты команды в окне  }

                        LnCommand : StandartString;
                           {  строковое значение команды }

                        NextCommand : MenuCommandCPtr;
                            { указатель на следующий элемент списка команд }

                  END;

    MenuCmd = OBJECT ( Control_Func_Key ) { обьект управляющий системой }
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

                    FirstCmdPtr : MenuCommandCPtr;
                        { первая команда меню }

                    WindowPtr : TextWindowPtr;
                        { рабочее окно текущего уровня меню }

                    HelpProc : RunProcedure;
                        { процедура подсказки по F1 }

              CONSTRUCTOR SetMenu ( kx1,ky1,kx2,ky2,ClFon,ClSym,ClFonLn,
                                  ClSymLn, ClFonSh, ClSymSh : BYTE;
                                  FrmSb : CHAR; SngShd : BOOLEAN; Hb : BYTE;
                                  Number : BYTE; Proc :   RunProcedure;
                                  CmdPtr : MenuCommandCPtr );
                        { установка параметров меню  }

              FUNCTION StartMenu  : BYTE;
                        { запуск меню  }

              Destructor Done;
                        { очистка меню  }

              END; { object MenuCmd }

FUNCTION SetCmdC ( kx, ky : BYTE; Line : StandartString;
                  Next : MenuCommandCPtr ) : MenuCommandCPtr;
                 { функция установки команды  }

IMPLEMENTATION

{----------------------------------------------------------}

CONSTRUCTOR MenuCmd.SetMenu ( kx1,ky1,kx2,ky2,ClFon,ClSym,ClFonLn,
                                  ClSymLn, ClFonSh, ClSymSh : BYTE;
                                  FrmSb : CHAR; SngShd : BOOLEAN; Hb : BYTE;
                                  Number : BYTE; Proc : RunProcedure;
                                  CmdPtr : MenuCommandCPtr );

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
     Num := Number;
     WindowPtr := NIL;
     HelpProc := Proc

END; { constructor MenuCmd.SetMenu }

{----------------------------------------------------------}

FUNCTION MenuCmd.StartMenu : BYTE;

              {          запуск меню        }
       {  возвращает последний код нажатия клавиши при возврате из меню }


VAR
   Ch : CHAR;
   TempPtr, FindPtr : MenuCommandCPtr;
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
     TypeMenu;
     REPEAT
           TypeMenu;
           Ch := GetKey;
           IF ( ( SingKey ) AND ( Ch = #0 ) ) THEN
              Ch := GetKey;
           CASE Ch OF

                Arrow_Up    : IF ( ( HowBar = 1 ) AND ( Num > 1 ) ) THEN
                                 BEGIN
                                      FindPtr := FirstCmdPtr;
                                      WHILE ( FindPtr^.NextCommand <>
                                              TempPtr ) DO
                                             FindPtr := FindPtr^.NextCommand;
                                      DEC ( Num );
                                      TempPtr := FindPtr;
                                      TypeMenu
                                 END;

                Arrow_Down  : IF ( ( HowBar = 1 ) AND
                                 ( TempPtr^.NextCommand <> NIL ) ) THEN
                                 BEGIN
                                      TempPtr := TempPtr^.NextCommand;
                                      INC ( NUM );
                                      TypeMenu
                                 END;

                Arrow_Left  : IF ( ( HowBar = 0 ) AND ( Num > 1 ) ) THEN
                                 BEGIN
                                      FindPtr := FirstCmdPtr;
                                      WHILE ( FindPtr^.NextCommand <>
                                              TempPtr ) DO
                                             FindPtr := FindPtr^.NextCommand;
                                      DEC ( Num );
                                      TempPtr := FindPtr;
                                      TypeMenu
                                 END;

                Arrow_Right : IF ( ( HowBar = 0 ) AND
                                 ( TempPtr^.NextCommand <> NIL ) ) THEN
                                 BEGIN
                                      TempPtr := TempPtr^.NextCommand;
                                      INC ( NUM );
                                      TypeMenu
                                  END;

                F1         :  HelpProc
           END
     UNTIL ( ( Ch = #27 ) OR ( Ch = #$0D ) );
     DISPOSE ( WindowPtr, TypeDone );
     WindowPtr := NIL;
     IF ( Ch <> #27 ) THEN
        StartMenu := Num
     ELSE
         StartMenu := 0

END; { procedure MenuCmd.StartMenu }

{----------------------------------------------------------}

DESTRUCTOR MenuCmd.Done;
               {         очистка меню  }

VAR
   TempPtr, FindPtr : MenuCommandCPtr;

BEGIN
     WHILE ( FirstCmdPtr^.NextCommand <> NIL ) DO
           BEGIN
                TempPtr := FirstCmdPtr;
                WHILE ( TempPtr^.NextCommand <> NIL ) DO
                      BEGIN
                           FindPtr := TempPtr;
                           TempPtr := TempPtr^.NextCommand
                      END;
                DISPOSE ( TempPtr );
                FindPtr^.NextCommand := NIL
           END;
     DISPOSE ( FirstCmdPtr )

END; { destructor MenuCmd.Done }

{----------------------------------------------------------}

FUNCTION SetCmdC ( kx, ky : BYTE; Line : StandartString;
         Next : MenuCommandCPtr )
                            : MenuCommandCPtr;

                   {  функция установки команды  }
           { возвращает указатель на описатель команды меню }

        { kx, ky -  координаты команды меню в окне                }
        { Line  -  строковое значение ( имя ) команды             }
        { Next  -  указатель на следующий описатель команды меню  }

VAR
    TempPtr : MenuCommandCPtr;

BEGIN
     NEW ( TempPtr );
     TempPtr^.x := kx;
     TempPtr^.y := ky;
     TempPtr^.LnCommand := Line;
     TempPtr^.NextCommand := Next;
     SetCmdC := TempPtr

END; { function SetCmdC }

{----------------------------------------------------------}

END.