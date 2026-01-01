{$A+,B-,D+,E-,F-,G-,I+,L+,N-,O-,P-,Q-,R-,S-,T+,V-,X+,Y+}
{$M 16384,0,0}
uses Dos, TpCrt, TpString;
var  SaveMode: word;
     SaveExitProc,
     SaveInt09,
     SaveInt16: pointer;
     Int09Vect: pointer absolute 0:$09*4;
     Int16Vect: pointer absolute 0:$16*4;
     TopRow, BotRow,
     Row, Col, Attr, IncRow: byte;
     S, PredS: byte;
     CursorXY, CursorLines: word;
     SplitScreen: boolean;

procedure Help;
begin
  writeln (#10' KeyBoard  (C) V.S. Rabets, 1994'#13#10#10 +
           ' Программа для просмотра scan-кодов клавиатуры на уровне int 9.');
  writeln (' Коды изображаются в hex-формате:'#13#10 +
           '      нажатие    - жёлтым,'#13#10 +
           '      отпускание - ярко-белым,'#13#10 +
           '      повтор     - белым,'#13#10 +
           '      код FA (признак триггера) - зелёным,'#13#10 +
           '      код E0 (префикс расширенной клавиатуры) - бирюзовым.');
  writeln (' ПРОБЕЛ - очистка окна,'#13#10 +
           ' ESC - выход (scan-коды Escape: нажатие - 1, отпускание - 81h).');
  writeln (#10' Если в текущем каталоге находится KNKBDI.EXE Никиты Корзуна'+
           ' (СофтПанорама 45)'#13#10 +
           '   и экран способен переключаться в режим 43/50 строк,');
  writeln ('   то KNKBDI.EXE запускается в верхней половине экрана,'#13#10 +
           '   а KeyBoard работает в нижней.'#13#10 +
           ' Это позволяет наблюдать за работой клавиатуры'#13#10 +
           '   на уровне как int 9, так и int 16h.');
  halt;
end;

procedure Int9; interrupt;
begin
   S:=Port[$60];
   if  S=1{Esc} then Int09Vect:=SaveInt09;
   IncRow:=1;
   if S=$FA then Attr:=$12 else
   if S=$E0 then Attr:=$13 else
   if S<$80 then begin if S<>PredS then Attr:=$1E else Attr:=$17 end
            else begin Attr:=$1F; IncRow:=2 end;
   PredS:=S;
   if Row>BotRow then begin Row:=TopRow; inc(Col,8) end;
   if (S=$39{Space}) or (Col>=80) then begin
      GetCursorState (CursorXY, CursorLines);
      ClrScr; Row:=TopRow; Col:=2;
      RestoreCursorState (CursorXY, CursorLines);
   end;
   FastWrite (HexB(S), Row, Col, Attr);
   inc(Row,IncRow);
   asm pushF; call SaveInt09 end;
end;

procedure Int16 (Flags, CS,IP, AX,BX,CX,DX, SI,DI, DS,ES,BP: word); interrupt;
begin
   if (not SplitScreen) or (not Font8x8Selected) then begin
      SelectFont8x8 (SplitScreen);
      HiddenCursor;
        TopRow:=27; BotRow:=succ(hi(WindMax));
        if not Font8x8Selected then begin TopRow:=2; BotRow:=25 end;
      Window (1,pred(TopRow), 80,BotRow); TextAttr:=$21; ClrEOL;
             write ('ESC - exit    SPACE - clear window':56);
      Window (1,TopRow, 80,BotRow); TextAttr:=$10; ClrScr;
      GotoXYabs (1,1);
      Row:=TopRow; Col:=2; PredS:=0;
      Int16Vect:=SaveInt16;
      Int09Vect:=@Int9;
   end;
   asm mov AX,&AX;  mov BX,&BX;  mov CX,&CX
                                             pushF; call SaveInt16
       mov &AX,AX;  mov &BX,BX;  mov &CX,CX
       pushF;       pop &Flags
   end;
end;

procedure SC_ExitProc; far;
begin
   SetIntVec ($09,SaveInt09);
   SetIntVec ($16,SaveInt16);
   ExitProc:=SaveExitProc;
   TextMode (SaveMode);
end;

begin
   if ParamStr(1)='/?' then Help;
   SaveMode:=LastMode;
   GetIntVec ($09,SaveInt09);
   GetIntVec ($16,SaveInt16);
   SaveExitProc:=ExitProc;
   ExitProc:=@SC_ExitProc;
   SetIntVec ($16,@Int16);
     TextMode (Co80+Font8x8);
     SplitScreen:=Font8x8Selected;
     if SplitScreen then begin
        SwapVectors;
        exec (FExpand('knkbdi.exe'),'');
        SwapVectors;
        SplitScreen:=DosError=0;
     end;
     if not SplitScreen then while ReadKey<>#27 do;
end.
