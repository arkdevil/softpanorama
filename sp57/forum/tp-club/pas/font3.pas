{$M 3000,30000,30000}
{$DEFINE Heap6}
{$F+,S-}
Uses TpCrt,Dos,TpWindow,TpEdit,TpString,TpLabel,TpVFont,TpTsr;

Const
  x : byte = 1;
  y : byte = 1;
  xx = 8;
  yy = 2;
  xt = 41;
  yt = 12;
  AttWrite = 1;
  WinAttr  : byte = 32;
  QryAttr  : byte = 7;
  WrnAttr  : byte = 44;
  HotAttr  : byte = 46;
  FldAttr  : byte = 23;
  SrvAttr  : byte = 26;
  ChrAttr  : byte = 28;
  UndAttr  : byte = 32;
  OnChar   : char = '▓';
  OffChar  : char = '▒';
  Empty    : string[15] = '▒ ▒ ▒ ▒ ▒ ▒ ▒ ▒';
  MainStr  : string[99] = '~1 ~Clean  ~2 ~Save   ~3 ~Load  ~4 C~har  ~5 ~Fill  ~6 ~Resize  ~7 ~Browse  ~8 ~Origin  ~9 Co~py';
  AltStr   : string[99] = '~1 8x8    ~2 8x14   ~3 8x16  ~4 Save all fon~ts  ~5 (~+)Resident   E~xit';
  ShftStr  : string[99] = '~1 Invert ~2 Revert ~3 Negative ~4 Undraw  ~5 Redraw';
  CtrlStr  : string[99] = 'Copyright (C) 1993  Dmitry Karasik';
  RestyStr : string[99] = '~1 ~Search         ~P~g~U~p/~P~g~D~n to Next/Prev image  ~E~s~c to abort';
  CopyStr  : string[99] = ' Choise the char where will copying and press <~C~R>. ~Esc to ~abort';
  RightStr : string[35] = 'DK Inc. (C) 1993  Text Font Editor';
  Power    : array[1..8] of byte = (1,2,4,8,16,32,64,128);
  ExpChar  : byte = 255;
  MemErStr : string[15] = 'Memory fail...';
  ChoiseStr: string[31] = 'Choise the image and press <CR>';
  Size     : byte = 14;
  ASC      : Boolean = true;
  BodyID7  : Word = $CF90;
  Resident : Boolean = False;
  SetImage : Boolean = False;

Type
  MaxCharArray = array[1..18] of byte;
  MaxFontArray = array[1..256] of MaxCharArray;
  McPtr = ^MaxCharArray;
  MfPtr = ^MaxFontArray;

Var
  B,SaveB    : McPtr;
  P          : MfPtr;
  Win,BakGrn : WindowPtr;
  A          : Boolean;
  i,j        : Integer;
  Code,SvXX  : Byte;
  st,st2,st3 : String;
  F          : File;
  SvX,SvY    : Byte;
  ExSave     : Pointer;
  FontField  : Array[1..5] of Pointer;
  PX         : Pointer;
  Deb        : Word;
  Stack      : Pointer;
  SaveTextAttr : Byte;
  SaveID7    : Pointer;
  SvYY       : Byte;


{$L VGAFont.OBJ}
Procedure VGAFont;External;

{$L EGAFont.OBJ}
Procedure EGAFont;External;

{$L CGAFont.OBJ}
Procedure CGAFont;External;

Function RealSize : Byte;
Begin
  case Size of
    8           : RealSize := 8;
    15,16,17,18 : RealSize := 16;
    14          : RealSize := 14;
  else  RealSize := 14;
  end;
End;

Function FontGAProc : Pointer;
Begin
  case RealSize of
  8  : FontGAProc := @CGAFont;
  16 : FontGAProc := @VGAFont;
  else FontGAProc := @EGAFont;
  end;
End;

Function OrdFont : Byte;
Begin
  case RealSize of
  8  : OrdFont := 1;
  16 : OrdFont := 3;
  else OrdFont := 2;
  end;
End;

Procedure VideoInt;
Begin
  Move(B^,PX^,RealSize);
  Move(PX^,B^,RealSize);
  ChangeSymbol(ExpChar,Size,B);
  PX := FontField[OrdFont];
  IncP(PX,ExpChar * RealSize);
End;

Procedure LoadImage;
Begin
  PX := FontField[OrdFont];
  IncP(PX,ExpChar * RealSize);
  Move(PX^,B^,RealSize);
End;

Procedure DoneShow;
Var
  PXs : Pointer;
Begin
  PXs := EraseTopWindow;
  if PXs = BakGrn then BakGrn := PXs else begin
    Win := PXs;
    BakGrn := EraseTopWindow;
  end;
  TextAttr := SaveTextAttr;
End;

Procedure DoneMemory;
Begin
  KillWindow(Win);
  KillWindow(BakGrn);
  Release(FontField[4]);
  SetIntVec($D7,SaveID7);
End;

Procedure Exits;
Begin
  DoneShow;
  DoneMemory;
  if ExitCode <> 0 then ErrorAddr := NIL
  else  if not(Resident) then WriteLn(RightStr);
  ExitProc := ExSave;
End;

Procedure Error(x :  string);
Begin
  StuffString(x);
  Halt(0);
End;

Procedure UnderLine(x: string);
Var
  St : string;
  i,j : Byte;
Begin
  FastFill(80,' ',25,1,UndAttr);
  if x <> CtrlStr then begin
    st := '';
    j := 0;
    for i := 1 to Length(x) do
      if x[i] <> '~' then st := Concat(st,x[i]) else begin
      Inc(j);
      ChangeAttribute(1,25,i-j+1,HotAttr);
    end;
    FastText(st,25,1);
  end
  else FastCenter(x,25,HotAttr);
End;

Procedure ErrorBox(st : String);
Var
  c : Char;
Begin
  FastWriteWindow(Concat(st,'Press any key '),2,2,WrnAttr);
  HiddenCursor;
  c := ReadKey;
  NormalCursor;
End;

Procedure SaveXY;
Begin
  SvX := WhereX;
  SvY := WhereY;
End;

Procedure DrawDesk;
Var
  st3 : String;
Begin
  for y:= 1 to 19 do FastFill(30,' ',y + yy,xx - 3,FldAttr);
  for y:= 1 to Size do begin
    Str(y,st3);
    if y < 10 then St3 := Concat('0',St3);
    FastText(Concat(st3,'  ',Empty,'  000  00 ',Chr(0)),y+yy,xx-3);
  end;
  FastWrite('7 6 5 4 3 2 1 0 ',yy,xx+1,SrvAttr);
  FastWrite('7 6 5 4 3 2 1 0 ',yy+Size+1,xx+1,SrvAttr);
End;

Procedure DrawScreen;
Begin
  TextAttr := FldAttr;
  ClrScr;
  FastCenter(RightStr,1,SrvAttr);
  DrawDesk;
  FastVert('00000000',12,38,SrvAttr);
  FastVert('00000000',12,76,SrvAttr);
  FastVert('02468ACE',12,39,SrvAttr);
  FastVert('02468ACE',12,75,SrvAttr);
  FastWrite('0123456789ABCDEF0123456789ABCDEF',11,41,SrvAttr);
  FastWrite('0123456789ABCDEF0123456789ABCDEF',20,41,SrvAttr);
  UnderLine(MainStr);
  FastWrite('Char,ASCII : ',4,45,SrvAttr);
  FastWrite(Chr(ExpChar),4,58,ChrAttr);
  Str(ExpChar,st);
  FastWrite(Concat('Char,DEC   : ',st),3,45,SrvAttr);
  for i := 0 to 255 do begin
    FastText(Chr(i),yt + (i div 32),xt + i - ((i div 32) * 32));
  end;
  Code := 0;
End;

Procedure GotoXYASC(Xs : Byte);
Begin
  I := Xs div 32;
  GotoXY(xt + Xs - (I * 32), yt + I);
End;

Procedure StandImage;
Begin
  for i:=1 to Size do
  begin
    st2 := BinaryB(B^[i]);
    st := Empty;
    for j:=1 to 8 do begin
       if st2[j] = '1' then begin
         st[2*j - 1] := OnChar;
       end;
    end;
    st2:='';
    Str(B^[i],st2);
   case Length(st2) of
    1 : st2 := Concat('00',st2);
    2 : st2:= Concat('0',st2);
    else
    end;
    FastText(st,yy + i,xx+1);
    FastText(st2,yy + i,xx+18);
    FastText(HexB(B^[i]),yy + i,xx+23);
    FastText(Chr(B^[i]),yy + i,xx+26);
  end;
End;

Procedure InitMemory;
Begin
  GetIntVec($D7, SaveID7 );
  if Word(SaveID7^) = BodyID7 then begin
    WriteLn('Already loaded...'#13#10'Alt - Space to activate');
    LoadByExit := False;
    Halt;
  end;
  SetIntVec($D7, @BodyID7);

  Mark(FontField[4]);
  New(B);
  New(P);
  New(SaveB);
  GetMem(Stack,1500);
  IncP(Stack,1500);
  GetMem(FontField[3],256 * 16);
  GetMem(FontField[2],256 * 14);
  GetMem(FontField[1],256 * 8);

  PX := @CGAFont;
  Move(PX^,FontField[1]^,256 * 8);
  PX := @EGAFont;
  Move(PX^,FontField[2]^,256 * 14);
  PX := @VGAFont;
  Move(PX^,FontField[3]^,256 * 16);

  WindowRelative := true;
  st3 := '';
  FillChar(B^,18,0);
  ExSave := ExitProc;
  ExitProc := @Exits;
  if (not(MakeWindow(Win,40,6,75,9,true,true,false,WinAttr,WinAttr,WinAttr,''))
   or not(MakeWindow(BakGrn,1,1,ScreenWidth,ScreenHeight,
      False,False,False,WinAttr,WinAttr,WinAttr,''))) then Error(MemErStr);

  Case CurrentDisplay of
    CGA,MonoHerc,MCGA : Size := 8;
    VGA : Size := 16;
  else
  end;
End;

Procedure InitShow;
Begin
  SaveTextAttr := TextAttr;

  if not DisplayWindow(BakGrn) then Error('');

   if ((CurrentDisplay < EGA) and DisplayWindow(Win)) then begin
    FastCenter(' Warning ',0,WinAttr);
    FastWriteWindow('Unable to remake fonts.Requested',1,2,WrnAttr);
    ErrorBox('EGA/VGA text mode.');
    Win := EraseTopWindow;
    OffChar := ' ';
    Empty := '               ';
  end;

  ReInitLabelFonts;

  PX := FontField[OrdFont];
  Y := RealSize;
  if CurrentDisplay >= EGA then begin
     for X := 0 to 255 do begin
       ReadRamChar(X,Y,PX);
       IncP(PX,Y);
     end;
   end;

  DrawScreen;
  if ParamCount > 0 then st3 := ParamStr(1);
  LoadImage;
  StandImage;
  if not ASC then GotoXYASC(ExpChar) else GotoXY(xx + 1,yy + 1);
End;

Procedure Handler;
Begin
  if ASC then begin
    x := 9 - (WhereX - xx+1) div 2; y := WhereY - yy;
    if (B^[y] and Power[x]) <> 0 then B^[y] := B^[y] and (255 xor Power[x])
    else B^[y] := B^[y] or Power[x];
    SetImage := True;
  end else begin
  end;
End;

Function OpenFile(St : String) : Boolean;
Var
  Sx : String;
Begin
  Sx := St;
  OpenFile := True;
  HiddenCursor;
  St := Fsearch(St,GetEnv('PATH'));
  NormalCursor;
  if st <> '' then begin
    {$I-}Assign(f,st);Reset(f,1);{$I+}
    if IOResult <> 0 then OpenFile := False;
  end
  else OpenFile := False;
End;

Procedure ReadAndStand;
Begin
  {$I-}
  BlockRead(f,B^,Size);
  {$I+}
  StandImage;
  VideoInt;
End;

Procedure CloseProc;
Begin
  Win := EraseTopWindow;
  NormalCursor;
  {$I-}Close(f);{$I+}
  i := IOResult;
End;


Function QueryPoint(var Code : Byte): Boolean;
Begin
  QueryPoint := True;
  ReadString('File : ',1,2,25,WinAttr,QryAttr,135,a,st3);
  FastWriteWindow(' .. Searching ..',2,2,QryAttr + 128);
  st := st3;
  if a then begin
    QueryPoint := False;
    CloseProc;
    Exit;
  end;
  if not(OpenFile(st)) then
    if (Code and AttWrite) = 0 then
    begin
      ErrorBox('File not found.');
      CloseProc;
      QueryPoint := False;
      Exit;
    end else begin
      ErrorBox('Open new file.');
      FastFillWindow(32,' ',2,2,WinAttr);
      FastWriteWindow('  .. Opening..',2,2,QryAttr + 128);
      HiddenCursor;
      {$I-}Assign(f,st3);Rewrite(f,1);{$I+}
      Code := 0;
      if IOResult <> 0 then
      begin
        ErrorBox('Unoperable file.');
        CloseProc;
        QueryPoint := False;
        Exit;
      end;
    end;
End;

Procedure ShiftImage(dX,dY : ShortInt);
Var
  i,j,Serv : Byte;
Begin
  if dX < 0 then begin
    Repeat
      Serv := B^[1];
      for i := 1 to Size - 1 do B^[i] := B^[i + 1];
      B^[Size] := Serv;
      Inc(dX);
    Until dX = 0;
  end;
  if dX > 0 then begin
    Repeat
      Serv := B^[Size];
      for i := Size downto 2 do B^[i] := B^[i - 1];
      B^[1] := Serv;
      Dec(dX);
    Until dX = 0;
  end;
  if dY <> 0 then begin
    for i := 1 to Size do begin
      Serv := B^[i];
      j := Abs(dY);
      asm
        mov  al,Serv
        mov  cl,j
      end;
      if dY < 0 then Inline($D2/$C0)
      else Inline($D2/$C8);
      asm
        mov  Serv,al
      end;
      B^[i] := Serv;
    end;
  end;
  SetImage := True;
End;

Procedure RevertY;
Begin
  Move(B^,P^,Size);
  PX := P;
  for i := Size downto 1 do begin
    B^[i] := Byte(PX^);
    IncP(PX,1);
  end;
  SetImage := True;
End;

Procedure RevertX;
Var
  Z,M,N,D : Byte;
Begin
  D := 136;
  for i := 1 to Size do begin
    M := 0;
    Z := 7;
    While Z < 8 do begin
      N := B^[i];
      asm
        mov ah, N
        mov al, D
        and ah, al
        ror al, 1
        mov D, al
        mov cl, Z
        ror ah, cl
        mov al, M
        or  al, ah
        mov M, al
      end;
      Dec(Z,2);
    end;
    B^[i] := M;
  end;
  SetImage := True;
End;

Procedure Neg;
Begin
  for i := 1 to Size do B^[i] := not B^[i];
  SetImage := True;
End;

Procedure InsDel(c : Char);
Var
  Xs,Ys : Byte;
Begin
  if ASC then begin
    x := 9 - (WhereX - xx+1) div 2; y := WhereY - yy;
    Xs := ((B^[y] shr x) shl x);
    case c of
    #83 : begin
           Ys := B^[y] shl (9 - x);
           Ys := Ys shr (8 - x);
          end;
    #82 : begin
           Ys := B^[y] shl (8 - x);
           Ys := Ys shr (9 - x);
          end;
    else end;
    B^[y] := Xs + Ys;
    SetImage := True;
  end else begin
  end;
End;

Procedure Redraw;
Begin
  SaveXY;
  DrawScreen;
  GotoXY(SvX,SvY);
  StandImage;
End;

Procedure Undraw;
Begin
  Move(WindowP(BakGrn)^.Draw.Covers^,Ptr($B800,0)^,
       WindowP(BakGrn)^.Draw.BufSize);
End;

Procedure MoveInFile(Var c : Char; PrimPos : Word);
Var
  X    : Word;
  Allow: Boolean;
Begin
  UnderLine(RestyStr);
  Seek(f,PrimPos * Size);
  ReadAndStand;
  Allow := True;
  repeat
    HiddenCursor;
    Allow := True;
    c:= ReadKey;
    if c = #0 then
    begin
      c:= ReadKey;
      case c of
      #59,#31 : begin
              FastFillWindow(22,' ',2,11,WinAttr);
              X := FilePos(F) div Size ;
              Deb := FileSize(F) div Size ;
              if Deb = 0 then Deb := 1;
              ReadWord('Seek for image ',2,2,5,WinAttr,QryAttr,0,Deb,A,X);
              if not(A) then begin
                if X = 0 then Inc(X);
                Seek(F,(X-1)*Size);
                ReadAndStand;
              end;
              FastFillWindow(22,' ',2,11,WinAttr);
            end;
      #73 : if FilePos(f) >= 2*Size - 1 then Seek(f,FilePos(f) - 2*Size)
            else Seek(f,0);
      #81 : if not(FilePos(f) < FileSize(f) -Size - 1) then Seek(F,FileSize(F) - Size);
      #71 : Seek(f,0);
      #79 : Seek(F,FileSize(F) - Size);
      #72 : if FilePos(f) > Size then Seek(f,FilePos(f) - Size - 1)
            else Allow := False;
      #80 : if ((FilePos(f) < FileSize(f)) and (FilePos(f) > Size - 1)) then
            Seek(f,FilePos(f) - Size + 1) else Allow := False;
      else end;
    end;
    if ((c in [#71..#73,#79..#81]) and Allow) then ReadAndStand;
    if Allow then begin
      X := FilePos(F)-Size;
      Str(X,st);
      FastFillWindow(24,' ',2,11,WinAttr);
      FastWriteWindow(Concat(' Bytes : ',st),2,2,HotAttr);
      Str(FilePos(F) div Size,st);
      FastWriteWindow(Concat(' Image : ',st),2,18,HotAttr);
    end;
  until c in [#27,#13];
  UnderLine(MainStr);
  NormalCursor;
End;

Procedure Restorer;
Var
  c : char;
Begin
  if DisplayWindow(Win) then
  begin
    FastCenter(' Browsing ',0,WinAttr);
    Code := 0;
    if QueryPoint(Code) then begin
      FastWriteWindow(ChoiseStr,2,2,WrnAttr);
      MoveInFile(c,0);
      CloseProc;
    end;
  end
  else Error(MemErStr);
End;

Procedure Cleaner(x : byte);
Begin
  FillChar(B^,Size,x);

  SetImage := True;
End;



Procedure HandleCursor(var c : Char);
Begin
  if ASC then
  case c of
       #71 : GotoXY(xx+1,yy+1);
       #72 : if WhereY > yy+1 then GotoXY(WhereX,WhereY-1)
                else ShiftImage(1,0);
       #73 : GotoXY(xx+15,yy+1);
       #75 : if WhereX > xx+1 then GotoXY(WhereX-2,WhereY)
                else ShiftImage(0,1);
       #76 : Handler;
       #77 : if WhereX < xx+15 then GotoXY(WhereX+2,WhereY)
                else ShiftImage(0,-1);
       #79 : GotoXY(xx+1,yy+Size);
       #80 : if WhereY < yy+Size then GotoXY(WhereX,WhereY+1)
                else ShiftImage(-1,0);
       #81 : GotoXY(xx+15,yy+Size);
  else
  end
  else begin
    case c of
       #71 : GotoXY(xt,yt);
       #72 : if WhereY > yt then GotoXY(WhereX,WhereY-1)
             else GotoXY(WhereX,yt + 7);
       #73 : GotoXY(xt+31,yt);
       #75 : if WhereX > xt then GotoXY(WhereX-1,WhereY)
             else GotoXY(xt+31,WhereY);
       #77 : if WhereX < xt+31 then GotoXY(WhereX+1,WhereY)
             else GotoXY(xt,WhereY);
       #79 : GotoXY(xt,yt+7);
       #80 : if WhereY < yt+7 then GotoXY(WhereX,WhereY+1)
             else GotoXY(WhereX,yt);
       #81 : GotoXY(xt+31,yt+7);
    else  end;
  end;
End;



Procedure SetStandartFonts(C : Char);
Var
  ProcFont : Pointer;
Begin
  SaveXY;
  case c of
 #104 : Size := 8;
 #105 : Size := 14;
 #106 : Size := 16;
  else
  end;
  if c = #104 then TextMode(Font8x8 + CO80) else TextMode(CO80);
  DrawScreen;
  ProcFont := FontGAProc;
  QuietFnt(256,0,Seg(ProcFont^),Ofs(ProcFont^),0,Size,Load);
  Move(ProcFont^,FontField[OrdFont]^,256 * RealSize);
  LoadImage;
  StandImage;
  if ((SvY > yy + Size) and ASC) then SvY := yy + Size;
  GotoXy(SvX,SvY);
End;

Procedure CopyTo;
Var
  xs : Word;
  c : Char;

Procedure StandFnt;
Begin
  PX := FontField[OrdFont];
  IncP(PX,Xs * RealSize);
  Move(B^,PX^,RealSize);
  Move(PX^,B^,RealSize);
  QuietFnt(1,Xs,Seg(PX^),Ofs(PX^),0,Size,Load);
  GotoXY(SvX,SvY);
End;

Begin
 if ASC then begin
  a:=DisplayWindow(Win);
  if a then
  begin
    Xs := ExpChar;
    FastCenter(' Copy to char ',0,WinAttr);
    ReadWord('Number of char',1,2,3,WinAttr,QryAttr,0,255,a,Xs);
    if not(A) then StandFnt;
    Win := EraseTopWindow;
  end
  else Error(MemErStr);
 end else begin
   UnderLine(CopyStr);
   SaveXY;
   Repeat
     c := ReadKey;
     if c = #0 then begin
       C := ReadKey;
       HandleCursor(c);
     end;
   Until c in [#27,#13,'A','a','E','e'];
   Xs :=  ((WhereY - yt) * 32)  + WhereX - xt;
   if c = #13 then StandFnt;
   UnderLine(MainStr);
 end;
End;

Procedure RestoreChrFile;
Var
  c        : char;
  xd,yd,id    : Word;
Begin
  if DisplayWindow(Win) then
  begin
    FastCenter(' Load font style ',0,WinAttr);
    Code := 0;
    if QueryPoint(Code) then begin
      FastWriteWindow(ChoiseStr,2,2,WrnAttr);
      MoveInFile(c,0);
      if c = #13 then begin
        Xd := 0;
        Yd := 255;
        FastFillWindow(31,' ',2,2,WinAttr);
        ReadWord('First char  ',2,2,3,WinAttr,QryAttr,0,255,a,Xd);
        if not(A) then begin
          ReadWord('Last char   ',2,2,3,WinAttr,QryAttr,Xd,255,a,Yd);
          if not(A) then begin
            Seek(f,FilePos(F) - Size);
            i := IOResult;
            id := 0;
            {$I-}
            PX := P;
            While ((Id <= (Yd - Xd)) and (IOResult = 0)) do begin
              BlockRead(f,PX^,Size);
              IncP(PX,Size);
              Inc(id);
            end;
            {$I+}
            Dec(id);
            PX := FontField[OrdFont];
            IncP(PX,Xd * RealSize);
            Move(P^,PX^,RealSize * Id);
            if xd <> 0 then Move(PX^,P^,RealSize * Id);
            QuietFnt(Id,Xd,Seg(P^),Ofs(P^),0,Size,Load);
          end;
        end;
      end;
      CloseProc;
    end;
  end
  else Error(MemErStr);
End;

Procedure Saver(Qty : Word);
Var
  c : char;
  st4 : String;
Label
  Exits;
Begin
  i := 0;
  a:=DisplayWindow(Win);
  if a then
  begin
    FastCenter(' Save ',0,WinAttr);
    Code := AttWrite;
    if QueryPoint(Code) then
    begin
      if Qty = 256 then PX := FontField[OrdFont] else PX := B;
        Move(PX^,P^,RealSize * Qty);
      if FileSize(f) <> 0 then begin
        FastWriteWindow('Append,Rewrite,Cancel? [A]',2,2,WrnAttr);
        Repeat c := ReadKey;
        Until c in ['A','a','R','r','C','c',#27,#13];
      case c of
      #13,'A','a' : begin
       		     Seek(f,FileSize(f));
	            {$I-}
                    BlockWrite(f,P^,Size*Qty,i);
                    {$I+}
	            if ((IOREsult <> 0) or (i = 0)) then
		    begin
          	      ErrorBox('File write error.');
          	      Goto Exits;
        	    end;
      		  end;
        'R','r' : begin
                    FastWriteWindow(ChoiseStr,2,2,WrnAttr);
                    SaveB^ := B^;
                    MoveInFile(c,0);
                    B^ := SaveB^;
                    StandImage;
                    VideoInt;
                    if c = #13 then
                    begin
                      FastFillWindow(31,' ',2,2,WinAttr);
                      a := YesOrNo('Owerwrite? (Y/N)',2,2,WrnAttr,'Y');
                      if a then begin
                        Seek(f,FilePos(f) - Size);
                        BlockWrite(f,P^,Size * Qty);
                      end;
                    end;
		  end;
      else end;
      end
      else BlockWrite(f,P^,Size * Qty);
Exits:CloseProc;
    end;
  end
  else Error(MemErStr);
End;


Procedure EmulType(c : Char);
Begin
  if ASC then begin
  Val(Concat('$',c),Code,i);
  if i = 0 then begin
    x := 9 - (WhereX - xx+1) div 2; y := WhereY - yy;
    if x > 4 then begin
      Code := Code shl 4;
      B^[y] := B^[y] and 15;
    end
    else B^[y] := B^[y] and 240;
    B^[y] := B^[y] or Code;
    SetImage := True;
  end;
  end;
End;

Procedure GetChar;
Var
  x : Word;
Begin
  a:=DisplayWindow(Win);
  if a then
  begin
    X := ExpChar;
    PX := FontField[OrdFont];
    IncP(PX,X * RealSize);
    Move(B^,PX^,RealSize);
    FastCenter(' Load char ',0,WinAttr);
    ReadWord('Number of char',1,2,3,WinAttr,QryAttr,0,255,a,X);
    if not(A) then begin
      ExpChar := X;
      LoadImage;
      SetImage := True;
      Str(ExpChar,st2);
      FastWrite(Concat(st2,'  '),3,58,SrvAttr);
      FastText(Chr(ExpChar),4,58);
    end;
    Win := EraseTopWindow;
    if not ASC then GotoXYASC(ExpChar);
  end
  else Error(MemErStr);
End;


Procedure Originizer;
Var
  SaveSize : Byte;
Begin
  SaveSize := Size;
  Size := RealSize;
  PX := FontGAProc;
  IncP(PX,ExpChar * Size);
  Move(PX^,B^,Size);
  Size := SaveSize;
  SetImage := True;
End;

Procedure Resize;
Var
  C : Char;
  Save : Byte;
Begin
  Save := Size;
  UnderLine('Use arrow keys to change matrix size.~E~s~c - Abort,<~C~R>-Accept');
  Repeat
    c := ReadKey;
    if c = #0 then begin
      c := ReadKey;
      case c of
        #72 : if Size > 8 then Dec(Size);
        #80 : if Size < 18 then Inc(Size);
      else
      end;
      if C in [#72,#80] then begin
        DrawDesk;
	StandImage;
      end;
      if ((WhereY > (yy + Size)) and ASC) then GotoXY(WhereX,WhereY - 1);
    end;
  Until C in [#13,#27];
  if C = #27 then begin
    Size := Save;
    DrawDesk;
    StandImage;
  end;
  UnderLine(MainStr);
End;

Function Exitter : Boolean;
Begin
  if not(Resident) then begin
     a:=DisplayWindow(Win);
     if a then
     begin
       FastCenter(' Exitting ',0,WinAttr);
       a := YesOrNo('Are you sure? (Y/N)',1,2,WrnAttr,'Y');
       FastCenter(' Save image ',0,WinAttr);
       if a then begin
         if ((CurrentDisplay > CGA) and a) then
           LoadByExit := YesOrNo('Clear changed fonts? (Y/N)',1,2,WrnAttr,'N');
       FillChar(B^,18,0);
       Exitter := True;
       end else begin
         Exitter := False;
         CloseProc;
       end;
     end;
   end else Exitter := True;
End;

Procedure RunAll(var R : Registers);Forward;

Procedure RestExit;
Begin
  DoneShow;
  LoadByExit := False;
  if Resident then begin
    ExitProc := @Exits;
    SetIntVec($1C,OldInt1C);
    if DisableTSR then;
    MemW[MemW[PrefixSeg : $2C] - 1 : 1] := 0;
    MemW[PrefixSeg - 1 : 1] := 0;
    Halt(0);
  end else begin
    Resident := True;
    AltStr[55] := '-';
    ExitProc := ExSave;
    WriteLn(RightStr);
    WriteLn('Alt - Space to activate');
    PopupsOn;
    if not (DefinePop($0839,@RunAll,Stack,true)
    and  TerminateAndStayResident(ParagraphsToKeep,0))
    then ErrorBox('Can''t stay resident.');
  end;
End;

Procedure Stopper;
Const
  ex : boolean = false;
  c: char = 'l';
Var
  AltKey : Byte Absolute 0 : $417;
  SavKey : Byte;
Begin
  SavKey := 0;
  Repeat
  if KeyPressed then begin
    c := ReadKey;
    case c of
                      #27   : Ex := Exitter;
                   #13,#32  : Handler;
                       #9   : begin
                               ASC := Not(ASC);
                               if ASC then GotoXy(SvXX,SvYY)
                               else begin
                                 SvXX :=  WhereX;
                                 SvYY :=  WhereY;
                                 GotoXYASC(ExpChar);
                               end;
                               if ((WhereY > (yy + Size)) and ASC) then GotoXY(WhereX,Size + yy);
                              end;
#48..#57,#65..#70,#97..#102 : EmulType(c);
                    'S','s' : Saver(1);
                    'L','l' : RestoreChrFile;
                    'H','h' : GetChar;
                    'R','r' : Resize;
                    'O','o' : Originizer;
                    'P','p' : CopyTo;
                    '+','-' : RestExit;
    #0 :  begin
            c := ReadKey;
            HandleCursor(c);
            case c of
            #45 : StuffKey($011B);
        #59,#46 : Cleaner(0);
        #31,#60 : Saver(1);
        #38,#61 : RestoreChrFile;
        #35,#62 : GetChar;
        #63,#33 : Cleaner(255);
        #19,#64 : Resize;
        #48,#65 : Restorer;
        #24,#66 : Originizer;
        #25,#67 : CopyTo;
       #107,#20 : Saver(256);
           #108 : RestExit;
     #104..#106 : SetStandartFonts(C);
           #84  : RevertY;
           #85  : RevertX;
           #86  : Neg;
       #82,#83  : InsDel(C);
           #87  : Undraw;
           #88  : Redraw;
  #71..#73,#75,#77,#79..#81 : if not(ASC) then begin
                                 ExpChar :=  ((WhereY - yt) * 32)  + WhereX - xt;
                                 Str(ExpChar,st2);
                                 FastWrite(Concat(st2,'  '),3,58,SrvAttr);
                                 FastText(Chr(ExpChar),4,58);
                                 LoadImage;
                                 StandImage;
                               end;
            else
            end;
          end;
    else
    end;
  end
  else begin
    if ((AltKey and 15) <> SavKey) then begin
      if ((AltKey and 15) <> 0) then begin
        if ((AltKey and 4) <> 0) then UnderLine(CtrlStr);
        if ((AltKey and 8) <> 0) then UnderLine(AltStr);
        if ((AltKey and 3) <> 0) then UnderLine(ShftStr);
      end else UnderLine(MainStr);
    end;
    Savkey := AltKey and 15;
  end;
  if SetImage then begin
    StandImage;
    VideoInt;
    SetImage := False;
  end;
  Until ex;
  Ex := False;
End;

Procedure RunAll(var R : Registers);
Begin
  ExitProc := @Exits;
  InitShow;
  Stopper;
  DoneShow;
End;

Begin
  InitMemory;
  InitShow;
  Stopper;
End.
