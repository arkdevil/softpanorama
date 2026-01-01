{ Программа decrypt.pas после ввода и проверки пароля дешифрирует       }
{  файл, созданный программой smartdrv.com, преобразуя его в текстовый  }
{  с именем encrypt. Автор - П.Борзяк                                   }
{          Пароль - "scintrex"                                          }

 Uses CRT,DOS;
label 11;
const St1='Enter the password: ';
      St2='File Name: ';
      St3='ENCRYPT';                   { Выходной файл - дешифрированный }

var
    F,F1:File of Byte;
    ch:Char;
    B:Byte;
    password,Passstr,FName:String;
    i,j:Word;

begin
 password:='cSY^dbUh';   { Закрутка от любителей взламывать пароли }
 ClrScr;
 writeln;
 write(St1);
  for i:=1 to 100 do begin
       ch:=ReadKey;         { Ввод пароля }
       ch:=UpCase(ch);
       write('*');
       if Ord(ch)=13 then Break;
        for j:=1 to 16 do ch:=Succ(ch);
       Passstr:=Passstr+ch;
 end;
 if Passstr<>password then begin
            ClrScr;
            Writeln(' INCORRECT!  - Досвидания!');
            Halt(1);
            end;
 writeln;
 write(St2);
 readln(FName);
  Assign(F,FNAme);
  Reset(F);
  Assign(F1,St3);
  Rewrite(F1);
                       { Дешифрируем файл }
   while not eof(F) do begin
        read(F,B);
        B:=B xor $48;
        B:=B-2;
        write(F1,B);
        end;
   Close(F);
   Close(F1);
 writeln('  OK! Results in file "encrypt"');
end.
