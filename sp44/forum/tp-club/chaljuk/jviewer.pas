{******************************* JViewer ***********************************}
{ просмотр сохраненных экранов                                              }
{***************************************************************************}
program JViewer;
Uses
  TpCrt,
  Dos;

const
  ModuleName : string = 'JViewer';  

const
   MaxCol = 80;    { размеры экрана }
   maxRow = 25;

type
   Sym = record  { символ экранной памяти }
      S : char;  { код ASCII символа }
      A : byte;  { атрибут цвета }
   end;

   Scr = array[1..MaxRow,1..MaxCol] of Sym;

var

   VideoRAM     : Scr absolute $b800:$0000;
   SaveVideoRAM : Scr;

   Fscr : file of Scr; { файл с экранной памятью }
   BaseName  : pathStr;
   ch : char;

{░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░}

{******************************* LeadingZero *******************************}
{ LeadingZero - Преобразование числа в строку с лидирующим нулем            }
{***************************************************************************}
function LeadingZero(w : Word) : String;
var
  s : String;
begin {LeadingZero}
  Str(w:0,s);
  if Length(s) = 1 then
    s := '0' + s;
  if Length(s) = 2 then
    s := '0' + s;
  LeadingZero := s;
end;  {LeadingZero}

{***************************************************************************}

procedure Abort(Message : string);
    {-Display message and Halt}
  begin
    WriteLn(Message);
    Halt(1);
  end;


{*****************************************************************************}

begin {JViewer}
   HighVideo;
   WriteLn(ModuleName+', Copyright 1990');
   LowVideo;

   if (ParamCount=0) then
      begin
        writeln;
        writeln('Формат запуска: ',ModuleName,' Name.Ext');
        Halt;
      end;

  BaseName:=ParamStr(1);

  assign(Fscr,BaseName);
  reset(Fscr);             { и запишем в него копию }
  SaveVideoRAM:=VideoRAM;
  read(Fscr,VideoRAM);
  repeat until KeyPressed; ch:=Readkey;
  close(Fscr);
  VideoRAM:=SaveVideoRAM;


end.  {JViewer}
{***************************************************************************}

