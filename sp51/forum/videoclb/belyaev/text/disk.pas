unit disk;
{ блок ввода информации  <SVB> 08.08.90 }

interface

uses  Dos;

function Ofile(var f; regim:byte; S:String):boolean;
{ 08.08.90 открытие файла с именем S
  regim:= 0  - чтение
          1  - запись
          2  - чтение и запись
  True - тогда ошибка при открытии заносится в f }

function Nfile(var f; atrib:byte; S:String):boolean;
{ 08.08.90 создание либо открытие файла с именем S
  atrib --> * * A D V S H R                  R=1 - только чтение
            7 6 5 4 3 2 1 0 <- номер бита    H=1 - спрятанный файл
                                             S=1 - системный
                                             V=1 - метка тома
                                             D=1 - директорий
                                             A=1 - архивный
  True - тогда ошибка при открытии заносится в f }

function Cfile(var f):boolean;
{ 08.08.90 закрытие файла f
  True - произошла ошибка, которая заносится в err }

function Sfile(var f;regim:byte;pos:longint;var npos:longint):boolean;
{ 08.08.90 установить указатель файла f на заданную позицию
  regim = 0 - перейти к началу + pos
          1 - сместить к текущей позиции + pos
          2 - сместить к концу + pos
  На выходе npos <-- новая позиция файлового указателя
  True - прозошла ошибка, которая заносится в npos }

function Rfile(var f; var buf; count:word;var num:word):boolean;
{ 08.08.90 чтение файла в буфер buf, count - число читаемых байт,
  num - фактическое число прочитанных байт,
  True - произошла ошибка, которая заносится в num }

function Wfile(var f; var buf; count:word;var num:word):boolean;
{ 08.08.90 запись файла из буфера buf, count - число записываемых байт,
  num - фактическое число записанных байт,
  True - произошла ошибка, которая заносится в num }

implementation

function Ofile;
var r :registers; fw :word absolute f;
begin
   r.ah:=$3D; r.al:=regim;
   S:=S+#0; r.ds:=seg(S); r.dx:=ofs(S)+1;
   if r.dx=0 then r.ds:=r.ds+$1000;
   MsDos(r); fw:=r.ax;
   Ofile:= ((r.flags and 1)=1)
end;

function Nfile;
var r :registers; fw :word absolute f;
begin
   r.ah:=$3C; r.cx:=atrib;
   S:=S+#0; r.ds:=seg(S); r.dx:=ofs(S)+1;
   if r.dx=0 then r.ds:=r.ds+$1000;
   MsDos(r); fw:=r.ax;
   Nfile:= ((r.flags and 1)=1)
end;

function Cfile;
var r :registers; fw :word absolute f;
begin
   r.ah:=$3E; r.bx:=fw;
   MsDos(r);
   Cfile:= ((r.flags and 1)=1)
end;

function Sfile;
var    r :registers; fw :word absolute f;
begin
   r.ah:=$42; r.bx:=fw; r.al:=regim;
   r.cx:=pos div 65536; r.dx:=pos-65536*r.cx;
   MsDos(r);
   Sfile:= ((r.flags and 1)=1);
   if (r.flags and 1)=1 then npos:=r.ax
   else npos:=65536*r.dx+r.ax
end;

function Rfile;
var r :registers; fw :word absolute f;
begin
   r.ah:=$3F; r.bx:=fw; r.ds:=seg(buf); r.dx:=ofs(buf);
   r.cx:=count; MsDos(r); num:=r.ax;
   Rfile:= ((r.flags and 1)=1)
end;

function Wfile;
var r :registers; fw :word absolute f;
begin
   r.ah:=$40; r.bx:=fw; r.ds:=seg(buf); r.dx:=ofs(buf);
   r.cx:=count; MsDos(r); num:=r.ax;
   Wfile:= ((r.flags and 1)=1)
end;

end.