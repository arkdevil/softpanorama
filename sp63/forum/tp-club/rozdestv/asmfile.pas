{Александp Pождественский, пpогpамма конвеpсии листинга
в фоpмат туpбо-ассемблеpа}

uses
     Dos,Crt;
const
     bcfn         = 'Bad command or file name';
     BufPos:word  =1;
     Tabs:word    =0;
     Spaces:word  =0;



var

    AsmFile,FileAsm,info    :file;
    position1,stroka        :longint;
    symb,space              :char;
    filename,filename1      :pathstr;
    dir,dir1                :dirstr;
    n,n1                    :namestr;
    e,e1                    :extstr;
    i,j,x,y,Check           :Word;
    push                    :array[1..5] of char;
    pushst                  :boolean;
    Buffer                  :array [1..1024*32] of char;

const

    BufSize       =SizeOf(Buffer);


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


    procedure MainWrite(Symb:Char);
    begin
       if Check<>0 then
       begin
          if BufPos=BufSize+1 then
          begin
             BlockWrite(FileAsm,Buffer,BufSize);
             BufPos:=1;
          end;
          Buffer[BufPos]:=Symb;
          Inc(BufPos);
       end;
    end;



    Begin
       checkbreak:=false;
       stroka:=0;
       if ParamCount<1 then
       begin
          filename:=paramstr(0);
          fsplit(filename,dir,n,e);
          assign(info,dir+'afinfo.inf');
          reset(info,1);
          if IOresult<>0 then
          begin
             writeln('Could not find the file ''afinfo.inf''');
             halt;
          end;
          clrscr;
          repeat
             BlockRead(info,symb,1,check);
             if check<>0 then write(symb);
          until check=0;
          halt;
       end;
       assign(AsmFile,paramstr(1));
       reset(AsmFile,1);
       halt1;
       FileName:=UpCaseStr(paramstr(1));
       FileName1:=UpCaseStr(paramstr(2));
       if FileName=FileName1 then
       begin
          FSplit(filename,dir,n,e);
          FSplit(filename1,dir1,n1,e1);
          if (e='.BAK') and (e1='.BAK') then
          begin
             writeln('See afinfo file');
             halt;
          end;
          e:='';
          e:='.bak';
          FileName:='';
          FileName:=dir+n+e;
          close(Asmfile);
          assign(asmfile,paramstr(1));
          rename(asmfile,filename);
          halt1;
          reset(asmfile,1);
       end;
       assign(FileAsm,paramstr(2));
       rewrite(FileAsm,1);
       halt1;
       ClrScr;
       writeln('AsmFile V 1.1');
       writeln;
       writeln('Please wait.....');writeln;
       x:=whereX;
       y:=whereY;
       pushst:=false;
       space:=' ';
       j:=0;
       repeat
          position1:=FilePos(AsmFile);
          repeat
             BlockRead(AsmFile,symb,1,check);
             if Symb=#9 then Tabs:=Tabs+1;
             if Symb=' ' then Spaces:=Spaces+1;
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
             if pushst=false then
             begin
                if Tabs<>0 then
                begin
                   for i:=1 to Tabs do
                      MainWrite(#9);
                   Tabs:=0;
                end;
                if Spaces<>0 then
                begin
                   for i:=1 to Spaces do
                      MainWrite(' ');
                   Spaces:=0;
                end;
                for i:=1 to 5 do
                   MainWrite(Push[i]);
                while (symb=#9) or (symb=' ') and (check<>0) do
                begin
                   MainWrite(Symb);
                   blockread(asmfile,symb,1,check);
                end;
             end else
             begin
               MainWrite(Space);
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
                   MainWrite(Symb);
                   blockread(asmfile,symb,1,check);
                end;
                while ((symb=#9) or (symb=' ')) and (symb<>#13) and (check<>0) do
                   blockread(asmfile,symb,1,check);
                if (symb<>';') and (symb<>#13) then
                   MainWrite(Space);
             until (symb=';') or (symb=#13) or (check=0);
             if (check<>0) and (symb=';') then
             begin
                repeat
                   blockread(asmfile,symb,1,check);
                until (symb=#10) or (check=0);
             end else
             begin
                while (check<>0) and (symb<>#10) do blockread(asmfile,symb,1,check);
             end;
             stroka:=stroka+1;
             gotoXY(x,y);write('(',stroka,') lines completed');
             pushst:=true;
          end else
          begin
             Spaces:=0;
             Tabs:=0;
             if pushst then
             begin
                MainWrite(#13);
                MainWrite(#10);
             end;
             seek(asmfile,position1);
             repeat
                blockread(asmfile,symb,1,check);
                if symb=#10 then
                begin
                   Inc(stroka);
                   gotoxy(x,y);
                   write('(',stroka,') lines completed');
                end;
                if check<>0 then MainWrite(symb);
             until (symb=' ') or (symb=#9) or (check=0);
             pushst:=false;
          end;
       until check=0;
       close(asmfile);
       BlockWrite(FileAsm,Buffer,BufPos-1);
       close(fileasm);
       writeln;writeln;writeln('OK');
   End.
