{$A+,B-,D+,E-,F-,G-,I-,L+,N-,O-,R-,S-,V-,X-}
{$M $2000,0,0}
program DeleteOverlayData;
uses Dos,Crt;
var f,t : file;
    s1,s2 : string;
    buf : array[1..$8000] of byte;
    l : LongInt;
    r,w : word;
    head : array [0..1] of char absolute buf;

procedure Stop(s,MSG : string;error : byte);
begin
  WriteLn(' ',s,' - ',MSG);
  Halt(Error)
end;

procedure TruncateOneFile;
var b, o : word;
begin
  Assign(f,s1); Reset(f,1);
  if IOResult>0 Then stop(s1,'File not found.',1);
  if FileSize(f)<32 Then Stop(s1,'Bad data.',2);
  BlockRead(f, buf, SizeOf(buf), r);
  if IOResult>0 Then Stop(s1,'Read error.',4);
  if (head<>'MZ') and (head<>'ZM') Then stop(s1,'It isn''t .EXE file.',2);
  asm
        lea     bx, buf
        mov     ax, word ptr [bx+4]
        mov     b, ax
        mov     ax, word ptr [bx+2]
        mov     o, ax
        cmp     o, 0
        je      @cont
        dec     b
 @cont:
  end;
  l := b * LongInt(512) + o;
  if FileSize(f)<l Then stop(s1,'Overlay data not found',0);
  Seek(f,l);
  if IOResult>0 Then Stop(s1,'Seek error.',3);
  Truncate(f);
  if IOResult>0 Then Stop(s1,'Write error.',4);
  Close(f);
  Stop(s1,'Truncated Ok.',0);
end;

procedure CopyTwoFiles;
var b, o : word;
begin
  Assign(f,s1); Reset(f,1);
  if IOResult>0 Then stop(s1,'File not found.',1);
  if FileSize(f)<32 Then Stop(s1,'Bad data.',2);
  BlockRead(f, buf, SizeOf(buf), r);
  if IOResult>0 Then Stop(s1,'Read error.',4);
  if (head<>'MZ') and (head<>'ZM') Then stop(s1,'It isn''t .EXE file.',2);
  asm
        lea     bx, buf
        mov     ax, word ptr [bx+4]
        mov     b, ax
        mov     ax, word ptr [bx+2]
        mov     o, ax
        cmp     o, 0
        je      @cont
        dec     b
 @cont:
  end;
  l := b * LongInt(512) + o;
  if FileSize(f)<l Then stop(s1,'Overlay data not found',0);
  Assign(t,s2); ReWrite(t,1);
  if IOResult>0 Then Stop(s2,'Open error.',1);
  repeat
    if r>l Then begin r:=l; l:=0; end else l:=l-r;
    BlockWrite(t, buf, r, w);
    if IOResult>0 Then Stop(s2,'Write error.',4);
    if w<r Then Stop(s2, 'Disk full.',4);
    if l>0 Then begin
      BlockRead(f, buf, SizeOf(buf), r);
      if IOResult>0 Then Stop(s1,'Read error.',4);
    end;
  until l=0;
  Close(f); Close(t);
  Stop(s1,'> '+s2+' Ok.',0);
end;

begin
  WriteLn(' Delete Overlay Data in .EXE files, (C) BZSoft Inc. 1992.');
  if ParamCount=0 Then
     begin
       WriteLn(' Usage : DOD FromFile [ToFile]');
       Halt
     end;
  s1 := FExpand(ParamStr(1));
  if ParamCount=1 Then TruncateOneFile;
  s2 := FExpand(ParamStr(2));
  if s1=s2 Then TruncateOneFile;
  CopyTwoFiles;
end.

