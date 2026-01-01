{$I-,F+}
Uses Dos,TpString,Crt;
Type
  Colors = Array[1..8] of Byte;

Const
  Strings : Array[1..8] of String[12] =
  ((' Window     '),
   (' Input line '),
   (' wArning    '),
   (' Hot keys   '),
   (' Background '),
   (' Foreground '),
   (' Char       '),
   (' Status bar '));

   NoByte : Word = $E4B4;
   Y      : String[23] = 'WwIiAaHhBbFfCcSsOo12345';
   Aux    : Integer = 0;
   Org    : Colors = (32,7,44,46,23,26,28,32);
   Name   : String = 'FONT3.EXE';
   ExitSv : Pointer= NIL;
   Inst   : Boolean = False;

Var
  F,F2 : File;
  I,J  : Byte;
  Code : Integer;
  X    : Colors;
  St   : String;

Procedure Exits;
Begin
  WriteLn;
  if Inst then WriteLn('Installed') else Writeln('Not installed');
  Close(F);
  ExitProc := ExitSv;
End;

Procedure ReadOut;
Begin
  Seek(F,NoByte);
  BlockRead(F,X,SizeOf(X));
End;

Procedure WriteOut;
Begin
  Seek(F,NoByte);
  BlockWrite(F,X,SizeOf(X));
End;

Procedure Display;
Begin
  For i := 1 to 8 do begin
    TextAttr := 7;
    Write(Strings[i],':',HexB(X[i]),' ');
    TextAttr := X[i];
    Write(' XXX');
    TextAttr := 7;
    WriteLn;
  end;
End;


Begin
  ExitProc := @Exits;
  WriteLn(' DK Inc. (C) 1993  Color installer for ',Name);
  WriteLn;
  Assign(F,Name);
  Reset(f,1);
  if IOResult <> 0 then begin
    WriteLn(Name,' not found');
    Halt;
  end; 
  if ParamCount = 0 then begin
    ReadOut;
    Display;
    WriteLn(' Specify the CHAR and ATTRIBUTE : ');
    WriteLn(' for example   S 123   to Status bar = 123');
    WriteLn(' or O <riginal colors> {any number}');
  end else begin
    Val(ParamStr(2),J,Code);
    St := ParamStr(1);
    Aux := Pos(St[1],Y);
    if Aux = 0 then WriteLn('Invalid function')
    else begin
      if St[1] = '1' then begin
        Assign(F2,ParamStr(2));
        Reset(F2,1);
        if IOResult <> 0 then WriteLn(ParamStr(2),' not found')
        else begin
          BlockRead(F2,X,SizeOf(X));
          WriteOut;
          Display;
          Inst := True;
        end;
        Close(F2);
        Halt;
      end;  
      if Code <> 0 then WriteLn('Invalid data')
      else begin  
        ReadOut;
        if Aux < 17 then X[(Aux + 1) div 2] := J else X := Org;
        WriteOut;
        if ((Code = 0) or (IOResult <> 0)) then Aux := 0;
        Display;
        Inst := True;
      end;  
    end;
  end;
End.