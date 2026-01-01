{           Copyright_(c)_VES__Волынский_Е.С.  24. 7.1992   10:51            }
unit VES;

interface

uses Crt,Dos;

const CRLF = #13 + #10;
      Ver : string [8] = 'v 1.0';
      CreateDate : string [8] = '00.00.00';

type
    NameExtStr = string[12];
var
    i,j,k,l,m,n : integer;
    FileSpec : SearchRec;
    InStr,OutStr : string;
    path1,path2,path3,path4,path5 : PathStr;
    com1,com2,com3,com4,com5 : ComStr;
    fd1,fd2,fd3,fd4,fd5 : DirStr;
    fn1,fn2,fn3,fn4,fn5 : NameStr;
    fe1,fe2,fe3,fe4,fe5 : ExtStr;
    str1,str2,str3,str4,str5 : string;
    fne1,fne2,fne3,fne4,fne5 : NameExtStr;
    ch1,ch2,ch3,ch4,ch5 : char;
    InpF,OutF : Text;
    Regs : Registers;
    Year,Month,Day,DayOfWeek,Hour,Minute,Second,Sec100 : word;

procedure WaitAnyKey;
procedure Beep;
procedure DelCur;
procedure TITLE (var FileTitle : text; var fndiski : PathStr);
procedure NumOff;
procedure NumOn;
procedure OpenInpFile (InpFileSpec : PathStr);
procedure OpenOutFile (OutFileSpec : PathStr);
function  Sign ( var x ) : integer;


implementation

procedure WaitAnyKey;
 begin
  repeat until KeyPressed;
  ch1:=ReadKey; if ( ch1 = #0 ) then ch1:=ReadKey
end;

procedure Beep;
 begin
    Writeln (^G);
 end;

procedure DelCur;
 begin
  Regs.ch:=32; Regs.cl:=13; Regs.ah:=1; Intr(16,Regs);
end;

procedure TITLE (var FileTitle : text; var fndiski : PathStr);
const
    FillChLeft = '<<<<<<<<<<<<';  FillChRight = '>>>>>>>>>>>>';

 begin
  FSplit (ParamStr(0),fd1,fn1,fe1); str1:='   '+fn1+'  ';
  FSplit (fndiski,fd1,fn1,fe1); str1:=str1+fn1+fe1+'  ';
  GetDate (Year,Month,Day,DayOfWeek); GetTime (Hour,Minute,Second,Sec100);
  writeln (FileTitle,FillChLeft,str1,Day:2,'/',Month:2,'/',Year:4,
           '   ',Hour:2,':',Minute:2,'   ',FillChRight);
end;

procedure NumOff;
const
     ByteOff = $CF;
begin
 Mem[0:$417]:=Mem[0:$417] and ByteOff
end;

procedure NumOn;
const
     ByteOn = $20;
begin
 Mem[0:$417]:=Mem[0:$417] or ByteOn
end;

procedure OpenInpFile (InpFileSpec : PathStr);
begin
    FindFirst (InpFileSpec,Archive,FileSpec);
    if DosError<>0 then begin { Задано имя несуществующего файла }
      writeln ('File not found !'); Beep; Halt (1)
                        end;
    Assign (InpF,InpFileSpec); Reset (InpF)
end;

procedure OpenOutFile (OutFileSpec : PathStr);
begin
    Assign (Outf,OutFileSpec); Rewrite (OutF)
end;

function Sign ( var x ) : integer;
var
  xs : real absolute x;
begin
  if xs < 0 then begin sign:=-1; exit end;
  if xs = 0 then begin sign:= 0; exit end;
  if xs > 0 then begin sign:= 1; exit end;
end;

end.
