{ Dimarker's Software 1992 }

uses Objects;

var 
 FIn, FOut : TBufStream;
 i,j,k     : integer;
 b         : byte;
 s         : string;
 l         : longint;
begin
 if ParamCount <> 2 then
  begin
   Writeln('Obj to Chr file converter. (anti binobj)');
   Writeln('Dimarker''s Software 1992');
   Writeln;
   Writeln('usage: OBJCHR OBJFILE CHRFILE');
   Writeln('CHRFILE will be rewritten !');
   Halt(0);
  end;
 if ParamStr(1) = ParamStr(2) then
  begin
   Writeln('source and destination must be different !');
   Halt(4);
  end;
 FIn.Init(ParamStr(1), stOpenRead, 1024);
 if FIn.Status <> stOk then
  begin
   Writeln('error opening ', ParamStr(1));
   Halt(1);
  end;
 FOut.Init(ParamStr(2), stCreate,  1024);
 if FOut.Status <> stOk then
  begin
   Writeln('error creating ', ParamStr(2));
   Halt(2);
  end;
 FIn.Read(s[1], 255);
 s[0]:=#255;
 i:=0; byte(s[0]):=4;
 while (Copy(s, 1, 4) <> 'PK'#8#8) and (i < 255 ) do
  begin { search for CHR header }
   Move(s[2], s[1], 254);
   Inc(i);
  end;
 if i > 250 then
  begin
   Writeln(ParamStr(1),' does not contain BGI font');
   Halt(3);
  end;
 FIn.Seek(i); j:=0; k:=0;
{ cut 7 bytes from input after each $400 (obj format) }
 for l:=0 to FIn.GetSize - i do
  begin
   FIn.Read(b, 1);
   if k > 0 then Dec(k);
   if k = 0 then FOut.Write(b, 1);
   Inc(j);
   if j = 1024 then 
    begin k:=8; j:=-7; end;
  end;
 FOut.Done;
 FIn.Done; 
end.