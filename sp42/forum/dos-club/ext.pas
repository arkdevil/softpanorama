     {$S-,D-,E-,I-,F-,A-,N-,L-,V-,M 2000,0,0}
     uses Dos;
     type str3=string[3];
     var  i: integer;
          ext:str3;
     {Перевод строки в верхний регистр}
     function stUpCase(s:string):string;
       var i:integer;
       begin
         stUpcase:=s;
         for i:=1 to Length(s) do stUpCase[i]:=upcase(s[i]);
       end;{stUpCase}
     {если необходимо,дополнить строку пробелами до длины 3}
     function To3(s:str3):str3;
       begin
         while Length(s)<3 do s:=s+' ';
         To3:=stUpCase(s);
       end;{To3}
     {Сравнить расширение файла со строкой описания}
      function CompExt(sf,ss:str3):boolean;
        var
          i:byte;
          fd,fc:boolean;
        begin
          fd:=true; fc:=true;
          for i:= 1 to 3 do
            if fd then begin
              if sf[i] <> ss[i] then
                 if ss[i] <> '?' then
                    if ss[i] <> '*' then fc :=false
                    else fd := false
            end;
          CompExt:=fc;
        end;

       begin
           if paramcount>1 then begin
             ext:=To3(Copy(paramstr(1),
                  Pos('.',paramstr(1))+1,
                  length(paramstr(1))-Pos('.',paramstr(1))+1 ));
             {получить расширение входного файла}
             for i:=1 to paramcount-1 do
                if CompExt(ext,
                   To3(Copy(paramstr(i+1),
                   2,length(paramstr(i+1))-1)))
                then  halt(i)
           end
           else begin {неверное число параметров при вызове}
             writeln( ' Используйте EXT.EXE в NCEDIT.BAT так:');
             writeln( 'ext [d:][path]filename.ext .ext1 [.ext2 ...]');
             writeln( 'если у filename ext = ext1 то ErrorLevel = 1,');
             writeln( 'если у filename ext = ext2 то ErrorLevel = 2...');
           end;
      end.

