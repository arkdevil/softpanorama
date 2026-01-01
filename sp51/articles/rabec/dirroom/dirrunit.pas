{$A+,B-,D+,E-,F-,G-,I+,L+,N-,O-,R+,S+,V-,X+}

unit DirRUnit;       { Unit for programme !DirRoom.  (C) V.S. Rabets, 1992 }
                     { Edition 11-11-92 }
interface

uses CRT;

const LF = #10;                              { Перевод строки }
const Pause: boolean = false;                { Пауза после ошибки }
var TA: byte absolute TextAttr;              { Сокращение имени TextAttr }
    tf: text;                                { Файл !DirRoom }
    TextBuf: array [1..32*1024] of byte;     { Буфер для tf }

procedure Error (S: string; ExCode: word);
function StrUpCase (S: string): string;
function Str2Long (S:string; var I:longInt): boolean;
function TextOpen (S: string): boolean;
function AddBackSlash (DirName: string): string;

implementation

procedure Error (S: string; ExCode: word);
begin
  TA:=$F+128; writeln (LF+'ОШИБКА:'#7);
  TA:=$F;     writeln (S);
  TA:=7;
  {$I-} close(tf); erase(tf); {I$+}
  if Pause then begin
              writeln (LF+'Нажмите любую клавишу ...');
              while keypressed do readkey;  readkey;
  end;
  halt (ExCode);
end;

function StrUpCase (S: string): string;
var b: byte;
begin  for b:=1 to length(S) do S[b]:=UpCase(S[b]); StrUpCase:=S;  end;

function Str2Long (S:string; var I:longInt): boolean;
var code: word;
    tmp: longint;
begin  val (S,tmp,code);
       if code=0 then  begin I:=tmp; Str2Long:=true end
                 else  Str2Long:=false;
end;

function TextOpen (S: string): boolean;
begin
  assign (tf,S);
  SetTextBuf (tf,TextBuf);
  {$I-} rewrite (tf); {$I+}
  TextOpen := IOResult=0;
end;

function AddBackSlash (DirName: string): string;
begin
  if DirName[Length(DirName)] = '\'
     then AddBackSlash:=DirName
     else AddBackSlash:=DirName+'\';
end;

end.
