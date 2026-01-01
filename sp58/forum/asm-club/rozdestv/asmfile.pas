uses
     Dos,Crt;

const
     bcfn='Bad command or file name';
var
    AsmFile,FileAsm,info:file;
    position1,position2,stroka:longint;
    symb,space:char;
    check:word;
    filename,filename1:pathstr;
    dir,dir1:dirstr;
    n,n1:namestr;
    e,e1:extstr;
    i,j,x,y:integer;
    push:array[1..5] of char;
    pushst,remst:boolean;
    rem:array [1..1000] of char;
    endln:string[1];

    function upcasestr(g:pathstr):pathstr;
    var
       i:byte;
    begin
      for i:=0 to length(g) do
        upcasestr[i]:=upcase(g[i]);
    end;

    procedure halt1;
    begin
     if IOresult<>0 then
       begin
          writeln(bcfn);
          halt;
       end;
    end;

    Begin
       checkbreak:=false;      {Обработка данных из командной строки}
       SetCbreak(False);
       stroka:=0;
       if paramcount<1 then
       begin
          filename:=paramstr(0);
          fsplit(filename,dir,n,e);
          assign(info,dir+'afinfo.inf');
          reset(info,1);
          if ioresult<>0 then
          begin
             writeln('Could not find the file ''afinfo.inf''');
             halt;
          end;
          clrscr;
          repeat
             blockread(info,symb,1,check);
             if check<>0 then write(symb);
          until check=0;
          halt;
       end;
       assign(AsmFile,paramstr(1));  {Открывает файл для чтения с диска}
       reset(AsmFile,1);             {исходного текста                 }
       halt1;
       filename:=upcasestr(paramstr(1));
       filename1:=upcasestr(paramstr(2));
       if filename=filename1 then
       begin
          fsplit(filename,dir,n,e);
          fsplit(filename1,dir1,n1,e1);
          if (e='.BAK') and (e1='.BAK') then {Создание .BAK копии в слуае}
          begin                     {одинаковых параметров командной строки} 
             writeln('See afinfo file');
             halt;
          end;
          e:='';
          e:='.bak';
          filename:='';
          filename:=dir+n+e;
          close(Asmfile);
          assign(asmfile,paramstr(1));
          rename(asmfile,filename);
          halt1;
          reset(asmfile,1);
       end;
       assign(FileAsm,paramstr(2));{Oткрытие файла для записи}
       rewrite(FileAsm,1);
       halt1;
       ClrScr;
       writeln('AsmFile V 1.0');
       writeln;
       writeln('Please wait.....');writeln;
       x:=whereX;
       y:=whereY;
       pushst:=false;
       remst:=false;
       space:=' ';
       j:=0;
       repeat
          position1:=FilePos(AsmFile);
          repeat
             position2:=FilePos(AsmFile);{Поиск символа<>' ' или <>#9}
             BlockRead(AsmFile,symb,1,check);
          until (symb<>#9) and (symb<>' ') or (symb=#10) or (check=0);
          push[1]:=symb;
          i:=1;
          while (i<>5) and (check<>0) and (symb<>#10) do
          begin
             i:=i+1;
             BlockRead(AsmFile,push[i],1,check);
          end;
          blockread(asmfile,symb,1,check);
          if (push='push ') or (push='PUSH ') or (push='push'+#9)
          or (push='PUSH'+#9) and (check<>0) then
          begin
             if pushst=false then        {Эта часть программы выполняет основ-}
             begin                       {ную работу                          }               
                seek(AsmFile,position1);
                for i:=position1 to (position2-1) do
                begin
                   blockread(asmfile,symb,1);
                   blockwrite(fileasm,symb,1);
                end;
                blockwrite(fileasm,push,5);
                blockread(asmfile,push,5);
                blockread(asmfile,symb,1,check);
                while (symb=#9) or (symb=' ') and (check<>0) do
                begin
                   blockwrite(fileasm,symb,1);
                   blockread(asmfile,symb,1,check);
                end;
             end else
             begin
               blockwrite(fileasm,space,1);
               while ((symb=#9) or (symb=' ')) and (check<>0) and (symb<>';')
               and (symb<>#13) do
               begin
                  blockread(asmfile,symb,1,check);
               end;
             end;
             repeat
                while (symb<>#9) and (symb<>' ') and (symb<>';')
                and (symb<>#13) and (check<>0) do
                begin
                   blockwrite(fileasm,symb,1);
                   blockread(asmfile,symb,1,check);
                end;
                while ((symb=#9) or (symb=' ')) and (symb<>#13) and (check<>0) do
                   blockread(asmfile,symb,1,check);
                if (symb<>';') and (symb<>#13) then
                   blockwrite(fileasm,space,1);
             until (symb=';') or (symb=#13) or (check=0);
             if (check<>0) and (symb=';') then
             begin
                j:=j+1;
                rem[j]:=symb;
                repeat
                   j:=j+1;
                   blockread(asmfile,rem[j],1,check);
                until (rem[j]=#10) or (check=0);
             end else
             begin
                while (check<>0) and (symb<>#10) do
                   blockread(asmfile,symb,1,check);
             end;
             stroka:=stroka+1;
             gotoXY(x,y);write('(',stroka,') lines completed');
             pushst:=true;
          end else
          begin
             if pushst=true then
             begin
                endln[0]:=#13;
                endln[1]:=#10;
                blockwrite(fileasm,endln,2);
             end;
             if remst=true then
             begin
                for i:=1 to j do
                   blockwrite(fileasm,rem[i],1);
                j:=1;
             end;
             seek(asmfile,position1);
             repeat
                blockread(asmfile,symb,1,check);
                if check<>0 then
                   blockwrite(fileasm,symb,1);
             until (symb=#10) or (check=0);
             stroka:=stroka+1;
             gotoXY(x,y);write('(',stroka,') lines completed');
             pushst:=false;
             remst:=false;
          end;
       until check=0;
       if remst then
        for i:=1 to j do
           blockwrite(fileasm,rem[i],1);
       close(asmfile);
       close(fileasm);
       SetCbreak(True);
   End.