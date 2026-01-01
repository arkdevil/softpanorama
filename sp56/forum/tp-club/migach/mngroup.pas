

               {----------------------------------------------}
               {  Модуль MenuGroup V 1.2  пакета TURBO SUPPORT}
               {  Язык программирования Turbo Pascal V 6.0    }
               {----------------------------------------------}
               { Дата последних изменений : 02/04/1992        }
               {----------------------------------------------}
               {      Модуль включает в себя обьект для       }
               {          работы с меню по отметке            }
               {----------------------------------------------}
               { (c) 1991-1992, Мигач Ярослав                 }
               {----------------------------------------------}


UNIT MnGroup;

{$IFDEF DEBUGMENU}
      {$D+,L+,R+,S+}
{$ELSE}
      {$D-,L-,R-,S-}
{$ENDIF}

{$F+,O+,I-,V-,B-,A+}

INTERFACE

USES Crt, Dos, Def, FKey11, TWindow;

TYPE
    InsProcedure = PROCEDURE ( VAR Cod : BYTE );

    MenuGroupPtr = ^MenuGroup;
                {  указатель на обьект управления меню }

    MenuCommandGPtr = ^MenuCommandG;
                { указатель на элемент списка команд меню }

    MenuCommandG = RECORD   {  список команд меню  }

                        X, Y : BYTE;
                           {  координаты команды в окне  }

                        LnCommand : StandartString;
                           {  строковое значение команды }

                        SingIns : BOOLEAN;
                             { Признак отметки }

                        NextCommand : MenuCommandGPtr;
                            { указатель на следующий элемент списка команд }

                        RunCommand : ^InsProcedure;
                                   { исполняемая процедура при попытке
                                              отметки  }
                  END;



    MenuGroup = OBJECT ( Control_Func_Key ) { обьект управляющий системой }
                                          {            меню             }

                    Num : BYTE;
                        { номер текущей команды меню }

                    x1, y1, x2, y2 : BYTE;
                        { координаты окна меню  }

                    ColorFon, ColorSymbol : BYTE;
                        { основной цвет фона и символов  }

                    ColorFonLine, ColorSymbolLine : BYTE;
                        { цвет фона и символов активной строки  }

                    ColorFonShade, ColorSymbolShade : BYTE;
                        { цвет символов и фона тени }

                    ColorIns : BYTE;
                        { цвет отмеченной команды меню }

                    FrameSymbol : CHAR;
                        { символ рамки  }

                    SingShade   : BOOLEAN;
                        { признак тени  }

                    FirstCmdPtr : MenuCommandGPtr;
                        { первая команда меню }

                    WindowPtr : TextWindowPtr;
                        { указатель на рабочее окно }

                    HelpProc : RunProcedure;
                        { процедура подсказки по F1 }

              CONSTRUCTOR SetMenu ( kx1,ky1,kx2,ky2,ClFon,ClSym,ClFonLn,
                                  ClSymLn, ClFonSh, ClSymSh : BYTE;
                                  FrmSb : CHAR; SngShd : BOOLEAN; Ci : BYTE;
                                  Proc : RunProcedure;
                                  CmdPtr : MenuCommandGPtr );
                        { установка параметров меню  }

              FUNCTION StartMenu  : CHAR;
                        { запуск меню  }

              Destructor Done;
                        { очистка меню  }

              END; { object MenuGroup }


FUNCTION SetCmdG ( kx, ky : BYTE; Line : StandartString; Sing : BOOLEAN;
         Cmd : POINTER; Next : MenuCommandGPtr ) : MenuCommandGPtr;
                 { функция установки команды  }



IMPLEMENTATION

VAR
   Start : InsProcedure;

{----------------------------------------------------------}

CONSTRUCTOR MenuGroup.SetMenu ( kx1,ky1,kx2,ky2,ClFon,ClSym,ClFonLn,
                                  ClSymLn, ClFonSh, ClSymSh : BYTE;
                                  FrmSb : CHAR; SngShd : BOOLEAN; Ci : BYTE;
                                  Proc : RunProcedure;
                                  CmdPtr : MenuCommandGPtr );

       {              установка параметров меню                  }

       {  kx1, ky1, kx2, ky2 -  координаты окна создавамого меню       }
       {  ClFon, ClSym - цвет фона и цвет символов окна создаваемого   }
       {                 меню                                          }
       {  ClFonLn, ClSymLn - цвет фона и символов активной строки      }
       {  FrmSb - символ рамки                                         }
       {  SngShd - признак наличия тени                                }
       {  Ci - цвет символов отмеченной команды                        }
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
     ColorIns := Ci;
     Num := 1;
     HelpProc := Proc;
     WindowPtr := NIL

END; { constructor MenuGroup.SetMenu }

{----------------------------------------------------------}

FUNCTION MenuGroup.StartMenu : CHAR;

              {          запуск меню        }
       {  возвращает последний код нажатия клавиши при возврате из меню }


VAR
   Ch : CHAR;
   TempPtr, FindPtr : MenuCommandGPtr;
   Index : BYTE;
   Kx, Ky : BYTE;
   Cod : BYTE;

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
                        IF ( FindPtr^.SingIns ) THEN
                           WindowPtr^.SetColorSymbol ( ColorIns );
                        WindowPtr^.WPrint ( FindPtr^.X, FindPtr^.Y,
                                 FindPtr^.LnCommand );
                        TempPtr := FindPtr
                   END
                ELSE
                    BEGIN
                         IF ( FindPtr^.SingIns ) THEN
                            WindowPtr^.SetColorSymbol ( ColorIns );
                         WindowPtr^.WPrint ( FindPtr^.X, FindPtr^.Y,
                                   FindPtr^.LnCommand )
                    END;
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
     Num := 1;
     REPEAT
           TypeMenu;
           Ch := GetKey;
           IF ( ( SingKey ) AND ( Ch = #0 ) ) THEN
              Ch := GetKey;
           CASE Ch OF
                Key_Ins     : BEGIN
                                   @Start := TempPtr^.RunCommand;
                                   Start ( Cod );
                                   IF ( Cod <> 0 ) THEN
                                      TempPtr^.SingIns := TRUE;
                                   IF ( Cod = 2 ) THEN
                                      TempPtr^.SingIns := FALSE
                              END;

                Arrow_Up    : IF ( Num > 1 ) THEN
                                 BEGIN
                                      FindPtr := FirstCmdPtr;
                                      WHILE ( FindPtr^.NextCommand <>
                                              TempPtr ) DO
                                             FindPtr := FindPtr^.NextCommand;
                                      DEC ( Num );
                                      TempPtr := FindPtr
                                 END;

                Arrow_Down  : IF ( TempPtr^.NextCommand <> NIL ) THEN
                                 BEGIN
                                      TempPtr := TempPtr^.NextCommand;
                                      INC ( NUM )
                                 END;

                Arrow_Left  : IF (  Num > 1 ) THEN
                                 BEGIN
                                      Ky := TempPtr^.Y;
                                      Kx := TempPtr^.X;
                                      REPEAT
                                            FindPtr := FirstCmdPtr;
                                            WHILE ( FindPtr^.NextCommand <>
                                                  TempPtr ) DO
                                                  FindPtr :=
                                                      FindPtr^.NextCommand;
                                            DEC ( Num );
                                            TempPtr := FindPtr;
                                      UNTIL ( ( Num <= 1 ) OR
                                        ( ( Kx > TempPtr^.X ) AND
                                          ( Ky = TempPtr^.Y ) ) )
                                 END;

                Arrow_Right : IF ( TempPtr^.NextCommand <> NIL ) THEN
                                 BEGIN
                                      Ky := TempPtr^.Y;
                                      Kx := TempPtr^.X;
                                      REPEAT
                                            TempPtr := TempPtr^.NextCommand;
                                            INC ( NUM )
                                      UNTIL ( ( TempPtr^.NextCommand = NIL )
                                          OR ( ( TempPtr^.X > Kx )
                                          AND ( TempPtr^.Y = Ky ) ) )
                                 END;
                F1           : HelpProc
           END
     UNTIL ( ( Ch = #27 ) OR ( Ch = F2 ) );
     StartMenu := Ch;
     DISPOSE ( WindowPtr, TypeDone )

END; { procedure MenuGroup.StartMenu }


{----------------------------------------------------------}

DESTRUCTOR MenuGroup.Done;
               {         очистка меню  }

VAR
   TempPtr, FindPtr : MenuCommandGPtr;

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

END; { destructor MenuGroup.Done }

{----------------------------------------------------------}

FUNCTION SetCmdG ( kx, ky : BYTE; Line : StandartString; Sing : BOOLEAN;
         Cmd : POINTER; Next : MenuCommandGPtr ) : MenuCommandGPtr;

                   {  функция установки команды  }
           { возвращает указатель на описатель команды меню }

        { kx, ky -  координаты команды меню в окне                }
        { Line  -  строковое значение ( имя ) команды             }
        { Cmd   - либо указатель на исполняемую команду, при      }
        {         обработке нажатия Insert                        }
        { Next  -  указатель на следующий описатель команды меню  }

VAR
    TempPtr : MenuCommandGPtr;
    Proc : POINTER ABSOLUTE Cmd;
    Mnu  : MenuGroupPtr ABSOLUTE Cmd;

BEGIN
     NEW ( TempPtr );
     TempPtr^.x := kx;
     TempPtr^.y := ky;
     TempPtr^.LnCommand := Line;
     TempPtr^.SingIns := Sing;
     TempPtr^.RunCommand := Proc;
     TempPtr^.NextCommand := Next;
     SetCmdG := TempPtr

END; { function SetCmdG }

{----------------------------------------------------------}

END.
