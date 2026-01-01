
         {----------------------------------------------------}
         {            Программа Test_FT V 1.0                 }
         {     Язык программирования Borland Pascal  V 7.0    }
         {----------------------------------------------------}
         { Дата создания : 01/12/1993                         }
         {----------------------------------------------------}
         { Дата последних изменений :  01/12/1993             }
         {----------------------------------------------------}
         {      Тестирование модуля обслуживания текстового   }
         {                режима терминала                    }
         {----------------------------------------------------}
         { (c) 1993, Мигач Ярослав                            }
         {----------------------------------------------------}

Program TEST_FT;

{================= Ключи компиляции =======================}

{$IFOPT D+}
      {$M $4000, 0, 650000 }
      {$L+,R+,S+,Q+}
{$ELSE}
      {$M $4000, 100000, 650000 }
      {$L-,R-,S-,Q-}
{$ENDIF}

{$F+,O+,B-,I-,N-,A+,X+}

{==========================================================}

Uses Crt, Dos, Def, FontTxt, TWindow, GTitle, ViewT;

Var
  FlName : PathStr;
  Fl : File;
  PBuf : Pointer;
  Index : Byte;
  Fact : Word;
  Line : String;
  Wn : TextWindowPtr;
Begin
  FlName := ParamStr ( 1 );
  if FlName = '' then FlName := 'TEST_FT.PUT';
  WriteLn ( 'Вывод картинки в текстовом режиме ', FlName );
  SecondFont16;
  SecondFontOn;
  AllTitle := 'Тест модуля вывода картинки в текстовом режиме';
  CopyRightLine := '(c) 1993 Ярослав Мигач';
  ColorDesk := Brown;
  GoTitle;
  New ( Wn, MakeWindow ( 5, 5, 75, 22, BLUE, LightGray ) );
  Wn^.FrameWindow ( 1, 1, 70, 17, 1, #205 );
  Wn^.SetShade ( Black, Blue );
  Wn^.PrintWindow;
  Wn^.SetColorSymbol ( White );
  Assign ( Fl, FlName );
  ReSet ( Fl, 1 );
  if ( IOResult = 0 ) And ( FileSize ( Fl ) <= 4096 + 4 ) then Begin
    GetMem ( PBuf, FileSize ( Fl ) );
    BlockRead ( Fl, PBuf^, FileSize ( Fl ), Fact );
    SetPic ( PBuf^, Fact, 16, 0 );
    FreeMem ( PBuf, FileSize ( Fl ) );
    Close ( Fl );
    if IOResult = 0 then;
    SecondUserFont16;
    For Index := 1 To DealLinesPic Do Begin
      Line := GetPicLine ( Index );
      Wn^.XYPrint ( 3, Index + 2, Line );
    End;
    AnyKey;
  End
  else Begin
    War ( 'Нет файла картинки' );
  End;
  Dispose ( Wn, TypeDone );
  SecondFontOff;
End. { Program TEST_FT }
