(****************************************************************)
(*                     DATABASE TOOLBOX 4.0                     *)
(*     Copyright (c) 1984, 87 by Borland International, Inc.    *)
(*                                                              *)
(*                         WindowU                              *)
(*                                                              *)
(*  Simple window managment unit used by the BTree program.     *)
(*                                                              *)
(****************************************************************)
unit WindowU;

interface
uses CRT;

type
  Rectangle = record
                X1, Y1, X2, Y2 : byte;
              end;

  WindowRec = record
                Border,
                Vis : Rectangle;
                { Visible  Rectangle or window is inset from the border }
                ForeColor,
                BackColor,
                BorderColor : byte;
                WTitle : String;
              end;

procedure SetColor(Fore, Back : byte);
{ Set foreground and background color in one procedure call }

procedure SetWindowColor(var W : WindowRec);
{ Set the current foreground and background color to those
  used by W. }

function Center(Len, Left, Right : integer) : integer;
{  Used for centering boxes on the screen }

procedure DisplayWindow(var W : WindowRec);
{ Draws the border for W and sets the current window to
  W's visible region. }

procedure EraseWindow(var W : WindowRec);
{ Erase W from Screen }

procedure NewWindow(var W : WindowRec;
                    Title : String;
                    X1, Y1, X2, Y2 : integer;
                    Fore, Back, BorderC : byte;
                    Display : boolean);
{ Initialize W and then display it if the display the
  window if the boolean display is true.  }

procedure SetWindow(var W : WindowRec);
{ Set W as the current active window. }

implementation

type
  CharSet = Set of Char;
  LineStr = String;
  Token = record
            s : LineStr;
            Delim : char;
          end;

const
  Null = #0;
  EmptyStr = '';
  Space = ' ';
  Tab = ^I;
  Blanks : CharSet = [Space, Tab];
  EndPunct : CharSet = ['!', '?', '.'];
  Delimeters  : CharSet = [Space, Tab, '!', '?', ',', ';'];


procedure WhiteSpace(var Line : LineStr);
var
  i : integer;
  done : boolean;
begin
  repeat
    i := pos(Tab, Line);
    if i > 0 then
      Line[i] := ' ';
  until i = 0;
  repeat
    i := pos('  ', Line);
    if i > 0 then
      Delete(Line, succ(i), 1);
  until i = 0;
  if Line = EmptyStr then
    Exit;
  if Line[1] = ' ' then
    Delete(Line,1, 1);
  if Line = EmptyStr then
    Exit;
  while Line[Length(Line)] = ' ' do
    Delete(Line, Length(Line), 1);
  i := pos(^Z, Line);
  if i > 0 then
    Delete(Line, i, 1);
end;

procedure NextToken(var Line : LineStr;
                    var T : Token);
var
  ch : char;
begin
  with T do
  begin
    S := EmptyStr;
    Delim := Null;
    if Line = EmptyStr then
      Exit;
    repeat
      ch := Line[1];
      if (ch in Delimeters) then
        Delim := ch
      else
        S := S + ch;
      Delete(Line, 1, 1);
    until (Delim <> Null) or (Line = EmptyStr);
    if Delim = Null then
      Delim := Space;
  end;
end; { NextToken }


procedure PrintToken(T : Token;
                     RightWall : integer);
var
  Len : integer;

begin
  with T do
  begin
    if (Delim = Space) and (S = EmptyStr) then
      Exit;

    Len := Length(S);
    if Delim <> Space then
      Len := succ(Len);

    if (WhereX + Len) > RightWall then
      Writeln;
    if S <> EmptyStr then
      Write(S);
    if Delim <> Space then
      Write(Delim);
    if (Delim in EndPunct) then
      if (WhereX <= RightWall) then
        Write(Space);
    if (WhereX < RightWall) and (WhereX > 1) then
      Write(Space);
  end;
end; { PrintToken }

procedure DisplayLine(var W : WindowRec;
                      CurLine : String);
var
  T : Token;

begin
  WhiteSpace(CurLine);
  if CurLine = EmptyStr then
  begin
    if WhereX > 1 then
      Writeln;
    Writeln;
  end;
  while CurLine <> EmptyStr do
  begin
    NextToken(CurLine, T);
    with W.Vis do
      PrintToken(T, (X2 - X1));
  end;
end;  { DisplayLine }

procedure SetColor{Fore, Back : byte};
begin
  TextColor(Fore);
  TextBackground(Back);
end; { SetColor }

procedure SetWindowColor{(var W : WindowRec)};
begin
  SetColor(W.ForeColor, W.BackColor);
end;

function Center{(Len, Left, Right : integer) : integer};
begin
  Center := (succ(Right - Left) div 2) - (Len div 2);
end;

procedure Box(var W : WindowRec);
const
  UpLeft = #201;
  UpRight = #187;
  LoLeft =  #200;
  LoRight = #188;
  HWall = #205;
  VWall = #186;

var
  x, y : integer;

begin
  with W, Border do
  begin
    Window(X1, Y1, X2, Y2);
    TextBackground(BackColor);
    ClrScr;
    TextColor(BorderColor);
    if BorderColor <> BackColor then
    begin
      Window(1, 1, 80, 25);
      GotoXY(X1, Y1);
      Write(UpLeft);
      for x := succ(X1) to pred(X2) do
        Write(HWall);
      GotoXY(X2, Y1);
      Write(UpRight);
      for Y := succ(Y1) to pred(Y2) do
      begin
        GotoXY(X2, y);
        Write(VWall);
      end;
      GotoXY(X1, Y2);
      Write(LoLeft);
      for x := succ(X1) to pred(X2) do
        Write(HWall);
      Write(LoRight);
      for Y := pred(Y2) downto succ(Y1) do
      begin
        GotoXY(X1, y);
        Write(VWall);
      end;
      Window(X1, Y1, X2, Y2);
      GotoXY(Center(Length(WTitle) + 2, X1, X2), 1);
      TextColor(White);
      Write(' ', WTitle, ' ');
    end;
    SetWindowColor(W);
  end;
end; { Box }

procedure DisplayWindow{(var W : WindowRec)};
begin
  with W, Vis do
  begin
    Box(W);
    Window(X1, Y1, X2, Y2);
    GotoXY(1, 1);
  end;
end; { DisplayWindow }

procedure EraseWindow{(var W : WindowRec)};
begin
  with W, Border do
  begin
    Window(X1, Y1, X2, Y2);
    NormVideo;
    ClrScr;
  end;
  Window(1, 1, 80, 25);
end; { EraseWindow }

procedure NewWindow{var W : WindowRec;
                    Title : String;
                    X1, Y1, X2, Y2 : integer;
                    Fore, Back, BorderC : byte;
                    Display : boolean};
begin
  FillChar(W, SizeOf(W), 0);
  with W do
  begin
    Border.X1 := X1; Border.Y1 := Y1;
    Border.X2 := x2; Border.Y2 := Y2;
    Vis.X1 := X1; Vis.X2 := x2;
    Vis.Y1 := y1;
    Vis.Y2 := y2;
    if BorderC <> Back then
    { If there will be a border we inset the inner rectangle }
    with Vis do
    begin
      inc(x1, 2);
      dec(x2, 2);
      inc(y1, 1);
      if Y2 > succ(Vis.Y1) then
        dec(Y2, 1);
    end;
    ForeColor := Fore;
    BackColor := Back;
    BorderColor := BorderC;
    WTitle := Title;
    if Display then
      DisplayWindow(W);
  end;
end; { NewWindow }

procedure SetWindow{var W : WindowRec};
begin
  with W.Vis do
    Window(X1, Y1, X2, Y2);
  SetWindowColor(W);
end;

end.