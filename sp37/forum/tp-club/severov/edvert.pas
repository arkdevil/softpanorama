 (* CEBEPOB ПАВЕЛ 1991 *)
 program EdVert;
 uses Crt;
 const SizeBuf=50;
       SizeControlLine=128;
       SizeProgram=100;
       SLine=1000;
 type OutLine=array [1..SLine] of char;
      ControlLine=record case IsLine:boolean of
                    True:(Line:string[SizeControlLine]);
                    False:(First,Last:integer);end;
 var
   Prog:array [1..SizeProgram] of ControlLine;
   c:char;str:string;
   s:array [1..SizeBuf] of OutLine;
   i,j,k,l,Counter,SizeProg:longint;
   code:integer;
   Inp,Out,P:text;

(****************************************************************************)

 procedure GetProgram;
 var c:char;i,j,k:integer;s:string;

 procedure Error;
 begin
 Sound(1760);Delay(500);NoSound;
 writeln('В строке ',j:0,' - ошибка "',s,'"');
 Halt;
 end;

 function GetInt(s:string;min,max:integer):integer;
 var code,i,k,l:integer;
 begin
 k:=1;
 while s[k]=' '  do k:=k+1;
 l:=k;
 while (l<=Length(s)) and (s[l]<>' ') do l:=l+1;
 Val(Copy(s,k,l-k),i,code);
 {writeln(s,k:6,l:6,code:6);}
 if (code<>0) or (i<min) or (i>max) then Error;
 GetInt:=i;
 end;

 begin
 i:=0;j:=0;
 while not Eof(P) do begin
   while Eoln(P) do readln(P);
   readln(P,s);j:=j+1;
   case s[1] of
     ' ':begin
           {writeln('комм=',s);}
           end;
     '=':begin
           i:=i+1;
           Prog[i].IsLine:=False;
           Prog[i].First:=GetInt(Copy(s,3,Length(s)),1,SLine);
           k:=2;
           while s[k]=' '  do k:=k+1;
           while s[k]<>' ' do k:=k+1;
           Prog[i].Last:=GetInt(Copy(s,k,Length(s)),Prog[i].First,SLine);
           {writeln('исх=',Prog[i].First,' ',Prog[i].Last,Prog[i].IsLine);}
           end;
     '+':begin
           i:=i+1;
           Prog[i].IsLine:=True;
           Prog[i].Line:=Copy(s,3,Length(s));
           {writeln('вст=',Prog[i].Line,Prog[i].IsLine);}
           end;
     else begin
            Error;
            end;
     end;
   end;
 SizeProg:=i;
 end;


(****************************************************************************)

 procedure CHANGING(var s:OutLine);
 var i,j,k,l:integer;ss:Outline;
 begin
 Counter:=Counter+1;
 k:=1;while s[k]<>Chr(0) do begin ss[k]:=s[k];k:=k+1 end;
 for k:=k to Sline do ss[k]:=' ';
 l:=1;
 for i:=1 to SizeProg do with Prog[i] do begin
   if Prog[i].IsLine
     then begin
       for j:=1 to Length(Line) do begin s[l]:=Line[j];l:=l+1 end;
       {writeln('вст=',Line);}
       end
     else begin
       for j:=First to Last do begin s[l]:=ss[j];l:=l+1 end;
       {writeln('исх=',First,' ',Last);}
       end;
   end;
 s[l]:=Chr(0);
 {k:=1;while s[k]<>Chr(0) do begin write(s[k]);k:=k+1 end;writeln;}
 end;

(****************************************************************************)

 begin
 writeln;
 writeln;
 writeln('                ╔═══════════════════════╗');
 writeln('               ┌╢ ВЕРТИКАЛЬНЫЙ РЕДАКТОР ║');
 writeln('               │║  Северов Павел  1991  ║');
 writeln('               │╚══════════════════════╤╝');
 writeln('               │ ИФЗ АН СССР 254-93-35 │');
 writeln('               └───────────────────────┘');
 writeln;

 if ParamCount<3 then begin
   writeln('Форма обращения:');
   writeln;
   writeln('    EDVERT  PROGRAM.EXT  OTKUDA.EXT  KUDA.EXT');
   writeln;
   writeln('       PROGRAM.EXT - файл содержащий команды для EDVERT;');
   writeln('       OTKUDA.EXT  - входной файл;');
   writeln('       KUDA.EXT    - выходной файл.');
   writeln;
   writeln('   Длина строк в файлах OTKUDA.EXT и KUDA.EXT не более ',SLine,' символов.');
   writeln('   Длина строк в файле PROGRAM.EXT не более ',SizeControlLine,' символов.');
   writeln('   Число исполняемых операторов в PROGRAM.TXT не более ',SizeProgram,'.');
   writeln;
   writeln('   Программа предназначена для вертикального редактирования текстовых          ');
   writeln('файлов (действие команд относится к одним и тем же позициям всех строк)        ');
   writeln;
   writeln;
   writeln('                               нажмите любую клавишу...');
   repeat until KeyPressed;c:=ReadKey;
   writeln;
   writeln;
   writeln;
   writeln;
   writeln('  Команда должна начинаться с первой позиции строки, конец строки служит       ');
   writeln('разделителем между командами. Пробел в первой позиции является признаком       ');
   writeln('строки - комментария                                                           ');
   writeln('                                                                               ');
   writeln('                         Команды EDVERT:                                       ');
   writeln('                                                                               ');
   writeln('= <нач.поз.> <кон.поз.> <комментарий> - определение столбца текста,            ');
   writeln('                   без изменений попадающего в выходной файл;                  ');
   writeln('                                                                               ');
   writeln('+ <некий текст>  - данный текст будет вставлен во все выходные строки          ');
   writeln('                   в соответствующей позиции;                                  ');
   writeln('                                                                               ');
   writeln('                                                                               ');
   writeln('  ПРИМЕР:         PROGRAM.EXT        OTKUDA.EXT        KUDA.EXT                ');
   writeln('  ───────        ┌───────────┐      ┌──────────┐     ┌────────────┐            ');
   writeln('                 │  год рожд.│      │Вася  1962│     │1962,"Вася "│            ');
   writeln('                 │= 7 10     │      │Петя  1961│     │1961,"Петя "│            ');
   writeln('                 │  имя      │      │Маша  1963│     │1963,"Маша "│            ');
   writeln('                 │+ ,"       │      │Basil 1960│     │1960,"Basil"│            ');
   writeln('                 │= 1 5      │      │Piter 1965│     │1965,"Piter"│            ');
   writeln('                 │+ "        │      │Mary  1963│     │1963,"Mary "│            ');
   writeln('                 └───────────┘      └──────────┘     └────────────┘            ');
   Halt;end;

 Assign(P,ParamStr(1));Reset(P);
 Assign(Inp,ParamStr(2));Reset(Inp);
 Assign(Out,ParamStr(3));Rewrite(Out);
 GetProgram;
 Writeln;
 GoToXY(1,24);Writeln('обработал 0 строк');
 i:=0;j:=0;Counter:=0;
 while not Eof(Inp) do begin
   i:=i+1;j:=j+1;
   k:=1;
   while not Eoln(Inp) and (k<SLine) do begin
     read(Inp,s[j,k]);k:=k+1 end;
   s[j,k]:=Chr(0);readln(Inp);
   CHANGING(s[j]);
   if j=SizeBuf then begin
     for l:=1 to SizeBuf do begin
       k:=1;while s[l,k]<>Chr(0) do begin write(Out,s[l,k]);k:=k+1 end;writeln(Out);
       end;
     GoToXY(1,24);Writeln('обработал ',i:0,' строк');
     j:=0 end;
   if KeyPressed then begin Readln;Close(Out);Halt end;
   end;
 for l:=1 to j do begin;
   k:=1;while s[l,k]<>Chr(0) do begin write(Out,s[l,k]);k:=k+1 end;writeln(Out);end;
 Close(Out);
 GoToXY(1,24);Writeln('обработал ',i:0,' строк');
{1, 7}Delay(   1);Sound( 1976);Delay(  27);NoSound;
{1, 5}Delay(   1);Sound( 1760);Delay(  27);NoSound;
{1, 4}Delay(   1);Sound( 1661);Delay(  27);NoSound;
{1, 2}Delay(   1);Sound( 1480);Delay(  27);NoSound;
{1, 0}Delay(   1);Sound( 1319);Delay(  27);NoSound;
{1, 7}Delay(   1);Sound( 1976);Delay(  27);NoSound;
{1, 5}Delay(   1);Sound( 1760);Delay( 250);NoSound;
 Writeln('O.K.');
 end.
