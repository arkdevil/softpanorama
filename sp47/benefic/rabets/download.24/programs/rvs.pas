{$A+,B-,D+,E-,F-,I+,L+,N-,O-,R+,S+,V-}

unit RVS; {Rabets V.S.}  {Служебные программки для LoadFontTransfer}

interface
uses Dos, CRT;
var TA: byte absolute TextAttr;

procedure Pik;          {Пик}
procedure ClearBuf;     {Очистка буфера клавиатуры}
function GetKey: char;  {Очисткой буфера клавиатуры и прием 1 символа}
procedure Wait;         {Ожидание нажатия любой клавиши}
function Yes (S: string; Attr:byte): boolean;
procedure Error (S: string);    {Сообщение об ошибке}
procedure Open (var f: file; Mode:char; S: PathStr); {Открытие файла}
procedure FClose (var f:file);                       {Закрытие файла}
function ExistFile (S: PathStr): boolean;  {true - если указанный файл есть}

implementation
type OfFileType = record Dummy: array [1..2+2+2+26+15] of byte;
                         Name:  String[80];  {Если переменная этого типа рас-}
                  end;                  {положена по одному адресу с file, то}
                                     {Name[1..80] совпадают с полем file.Name}
procedure Pik;   begin sound (3000); delay (20); nosound; end;

procedure ClearBuf;  {Очистка буфера клавиатуры}
var C: char;  begin while keypressed do C:=readkey; end;

function GetKey: char;   {Очисткой буфера клавиатуры и прием 1 символа}
begin ClearBuf; GetKey:=ReadKey; end;

procedure Wait;  var C: char;  {Ожидание нажатия любой клавиши}
begin TextColor(6); write (#10#13'Press any key ...');
      C:=Getkey;
end;

function Yes (S: string; Attr:Byte): boolean;
var C: char;
    b, SavedTA: byte;
begin for b:=1 to 5 do Pik;  SavedTA:=TA; TA:=Attr;
      write (S,' (Y/any other=N) ?');   Yes:=UpCase(GetKey)='Y';
      TA:=SavedTA;
end;

procedure Error (S: string);    {Сообщение об ошибке}
begin TA:=LightRed+blink;
      writeln (#13#10'ERROR:'#7); TA:=White; writeln (S);  Wait; halt (2);
end;

procedure Open (var f: file; Mode:char; S: PathStr);
begin assign(f,S);
      if Mode='W' then  {$I-} rewrite(f,1) else reset(f,1); {$I+}
      if IOresult>0 then Error('Error opening file '+S)
end;

procedure FClose (var f:file);  {!! Портится последний байт UserData!}
var OfFile: OfFileType absolute f;    { (занимается под длину имени) }
begin OfFile.Name[0]:=#80; OfFile.Name[0]:=char(pos(#0,OfFile.Name));
      {$I-} close(f); {$I+}
      if IOresult>0 then Error('Error closing file '+OfFile.Name)
end;

function ExistFile (S: PathStr): boolean;  {true - если указанный файл есть}
var f: file;
    SavedFileMode: byte;
begin SavedFileMode:=FileMode; FileMode:=0;
  assign (f,S); {$I-} reset(f); close(f); {$I+} ExistFile:=IOresult=0;
  FileMode:=SavedFileMode;
end;

end.
