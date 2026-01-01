{$A+,B-,E+,F-,I+,N-,O-,R-,V-}
{$UNDEF DEBUG}
{$IFDEF DEBUG} {$D+,L+,S+} {$ELSE} {$D-,L-,S-} {$ENDIF}
Unit Invoer;

Interface

Uses YNSystem,YNCrt,FastScr,StrInt;


Type SpecialKeys = (RightShift,LeftShift,Ctrl,Alt,ScrollLock,NumLock,
                    CapsLock,Ins);
     KeyState    = Set of SpecialKeys;

     KeyOBJ      = Object
      Function  InsertLock : Boolean;
      Function  CapsLock : Boolean;
      Function  NumLock : Boolean;
      Function  ScrollLock : Boolean;
      Function  AltPressed : Boolean;
      Function  CtrlPressed : Boolean;
      Function  LeftShiftPressed : Boolean;
      Function  RightShiftPressed : Boolean;
      Function  ShiftPressed : Boolean;
      Procedure GetKey(Var C : Char;Var S : Byte;Var Ks : KeyState);
     End;


Procedure EditStr(Var S : Str80;MaxLen,EditLen : Byte;Valid : CharSet;
                  Var ExitChar : Char;InputAttr : Byte);
Procedure EditNum(Var N : Longint;MaxLen,EditLen : Byte;Var ExitChar : Char;
                  InputAttr : Byte);


Var KeyBoard : KeyOBJ;

Implementation

Var KeyStatusBits : Byte Absolute $0040:$0017;


{Start Key Object}
Function KeyOBJ.InsertLock : Boolean;
Begin
 InsertLock := (KeyStatusBits And 128) <> 0;
End;

Function KeyOBJ.CapsLock : Boolean;
Begin
 CapsLock := (KeyStatusBits And 64) <> 0;
End;

Function KeyOBJ.NumLock : Boolean;
Begin
 NumLock := (KeyStatusBits And 32) <> 0;
End;

Function KeyOBJ.ScrollLock : Boolean;
Begin
 ScrollLock := (KeyStatusBits And 16) <> 0;
End;

Function KeyOBJ.AltPressed : Boolean;
Begin
 AltPressed := (KeyStatusBits And 8) <> 0;
End;

Function KeyOBJ.CtrlPressed : Boolean;
Begin
 CtrlPressed := (KeyStatusBits And 4) <> 0;
End;

Function KeyOBJ.LeftShiftPressed : Boolean;
Begin
 LeftShiftPressed := (KeyStatusBits And 2) <> 0;
End;

Function KeyOBJ.RightShiftPressed : Boolean;
Begin
 RightShiftPressed := (KeyStatusBits and 1) <> 0;
End;

Function KeyOBJ.ShiftPressed : Boolean;
Begin
 ShiftPressed := ((KeyStatusBits And 2) <> 0) Or
                 ((KeyStatusBits And 1) <> 0);
End;


Procedure KeyOBJ.GetKey(Var C : Char;Var S : Byte;Var Ks : KeyState);
Var W : Word;
    B : Array [1..2] of Byte Absolute W;
Begin
 W := ReadWord;
 C := Char(B[1]);
 S := B[2];

 Byte(Ks) := KeyStatusBits;
End;
{End Key Object}


Procedure Beep;
Begin
 Sound(1000);
 Delay(100);
 NoSound;
End;

Procedure EditStr(Var S : Str80;MaxLen,EditLen : Byte;Valid : CharSet;
                  Var ExitChar : Char;InputAttr : Byte);
Var X,Y,
    IPos,
    T,B,
    SPos    : Byte;
    Ch      : Char;
    FirstCh,
    InsMode : Boolean;
    sCursor : Word;

  Function PartStr : Str80;
  Begin
   PartStr := FillRight(Copy(S,SPos,EditLen),EditLen);
  End;

  Procedure GoRight;
  Begin
   if IPos<=Length(S) then
    Begin
     Inc(IPos);
     if SPos+EditLen<=IPos then Inc(SPos);
    End;
  End;

  Procedure GoLeft;
  Begin
   if IPos>1 then
    Begin
     Dec(IPos);
     if IPos<SPos then Dec(SPos);
    End;
  End;

  Procedure GoHome;
  Begin
   IPos := 1;
   SPos := 1;
  End;

  Procedure GoEnd;
  Begin
   IPos := Succ(Length(S));
   if Integer(Succ(IPos-EditLen))<1 then SPos := 1
    Else SPos := Succ(IPos-EditLen);
  End;

Begin
{Maak plaats voor cursor, komt een plaats na laatste char}
 sCursor := GetCursorShape;
 GoEnd;
 With Screen Do
  Begin
   X := WhereX; Y := WhereY;
   InsMode := True; InsertCursor;
   FirstCh := True; {Clear s when plain char pressed}

   Repeat
    FastWrite(X,Y,InputAttr,PartStr);
    GotoXY(X+(IPos-SPos),Y);
    Ch := ReadKey;

    if Ch=#0 then
     Begin {Extended code}
      Ch := ReadKey;
      Case Byte(Ch) of
{Ins}   82 : Begin
              InsMode := Not InsMode;
              if InsMode then InsertCursor
               Else NormalCursor;
             End;
{Right} 77 : GoRight;
{Left}  75 : GoLeft;
{Home}  71 : GoHome;
{End}   79 : GoEnd;
{Del}   83 : if IPos<=Length(S) then Delete(S,IPos,1);
      End;{Case}
     End Else Begin {Normal character}

               if Ch=#8 then
                Begin
                 if IPos>1 then
                  Begin
                   GoLeft;
                   Delete(S,IPos,1);
                  End;
                End
                Else
                if Ch=#25 then {Ctrl-Y,delete till end of line}
                 Begin
                  Delete(S,IPos,255);
                 End
                 Else
                 if (Ch in Valid) And (Ch<>#13) And (Ch<>#27) then
                  Begin
                   if FirstCh then
                    Begin
                     S := '';
                     GoEnd;
                    End;

                   if (MaxLen>Length(S)) And (Pred(IPos)<=Length(S))
                      And InsMode then Begin
                                        Insert(Ch,S,IPos);
                                        GoRight;
                                       End;
                   if (IPos<=MaxLen) And Not InsMode then
                     Begin
                      S[IPos] := Ch;
                      if Length(S)<IPos then Inc(S[0]);
                      GoRight;
                     End;
                  End;
              End;
    FirstCh := False;
   Until (Ch=#13) Or (Ch=#27);
  End;

 ExitChar := Ch;
 SetCursorShape(sCursor);
End;


Procedure EditNum(Var N : Longint;MaxLen,EditLen : Byte;Var ExitChar : Char;
                  InputAttr : Byte);
Var S : String[80];
    R : Integer;
Begin
 Str(N,S);
 EditStr(S,MaxLen,EditLen,['0'..'9'],ExitChar,InputAttr);
 Val(S,N,R);
End;





End.