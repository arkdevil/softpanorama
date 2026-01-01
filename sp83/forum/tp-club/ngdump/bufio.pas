{$R+,I+}
{$M 45000,0,655360}
unit BufIO;

interface

procedure bread(var f:file; var buf; count:word; var result:word);
procedure bskip(var f:file; n:longint);
procedure bseek(var f:file; p:longint);
function  bpos(var f:file):longint;

implementation

{$define Buffered}

{$ifdef Buffered}

const MaxFbuf = 1024;

var   fbuf   : array [1..MaxFbuf] of byte;
      inbuf  : 0..MaxFbuf;
      curbuf : 1..MaxFbuf+1;

procedure bread( var f:file; var buf; count:word; var result:word);
type ByteArray = array [1..maxint] of byte;
var done,n:word;
    abuf : ByteArray absolute buf;
begin
  result := 0;
  if (count > inbuf) or (inbuf = 0) then begin
     if (inbuf > 0)
      then move(fbuf[curbuf], buf, inbuf);
     done := inbuf;
     while (done < count) do begin
        blockread(f, fbuf, MaxFbuf, result);
        inbuf := result;
        if (inbuf < 1) then begin
{           writeln('BufIO.bread: unexpected eof.'); }
           FillChar(buf, count, 0);
           result := 0;
           exit;
        end;
        curbuf := 1;
        n := count - done;
        if (n > inbuf) then n := inbuf;
        move(fbuf[curbuf], abuf[done+1], n);
        inc(done, n);
        dec(inbuf, n);
        inc(curbuf, n);
     end;
  end
  else begin
     move(fbuf[curbuf], buf, count);
     dec(inbuf, count);
     inc(curbuf);
  end;
  result := count;
end;

procedure bseek(var f:file; p:longint);
begin
  seek(f, p);
  inbuf := 0; curbuf := 1;       { flush buffer }
end;

function bpos(var f:file):longint;
begin
  bpos := filepos(f) - inbuf;
end;

procedure bskip(var f:file; n:longint);
begin
  if (n < inbuf) then begin
     dec(inbuf, n);
     inc(curbuf, n);
  end
  else begin
     bseek(f, bpos(f)+n);
  end;
end;

{$else}

procedure bread( var f:file; var buf; count:word; var result:word);
begin
  blockread(f, buf, count, result);
  if (result < 1) then begin
     writeln('BufIO.bread: unexpected eof.');
  end;
end;

procedure bseek(var f:file; p:longint);
begin
  seek(f, p);
end;

function bpos(var f:file):longint;
begin
  bpos := filepos(f);
end;

procedure bskip(var f:file; n:longint);
begin
  bseek(f, filepos(f)+n);
end;

{$endif}

(*
var SaveExitProc : Pointer;

{$F+} procedure MyExitProc; {$F-}
begin
  ExitProc := SaveExitProc;
end;
*)

begin
{$ifdef Buffered}
  inbuf := 0;
  curbuf := 1;
{$endif}
end.
