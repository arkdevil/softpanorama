      unit dirgraph;
{  
   Модуль предназначен для поиска в каталоге файла с сохраненным
   фрагментом экрана ( слайда ). Рассматириваются только файлы
   с расширением  .PSL   
                         }
      interface
                procedure dir(sss:string;var nameoffile:string);
      implementation
      uses
           dos,crt,graph,foread;
        procedure dir;
      type
           lin=string[12];
      const
           p2:array[1..5] of pointtype =
           ((x:3;y:3),(x:637;y:3),(x:637;y:346),(x:3;y:346),(x:3;y:3));
           p3:array[1..5] of pointtype =
           ((x:10;y:10),(x:490;y:10),(x:490;y:320),(x:10;y:320),(x:10;y:10));
           p4:array[1..5] of pointtype =
           ((x:40;y:30),(x:460;y:30),(x:460;y:80),(x:40;y:80),(x:40;y:30));
           p5:array[1..5] of pointtype =
           ((x:50;y:40),(x:470;y:40),(x:470;y:90),(x:50;y:90),(x:50;y:40));
      var
           kp,funckey:boolean;
           grmode,grdriver:integer;
           errcode:integer;
           fn:array[1..400] of lin;
           at:array[1..400] of lin;
           katal,d,mr:string;
           d1:string[12];
           s:SearchRec;
           ch:char;
           ind,NN,pn,NK,k1,lm,sl,klop,x,y,kl,prog,n,i,j,k,l,m,nl,lt,shrift,strok,fl:integer;
      label
       10,20,90,185,
       71,72,73,74,75,76,77,78,79,81,82,83,84,85,86,87,88,89;

{ процедура информации о командных клавишах }

      procedure fank;
      begin
        setcolor(14);
        setfillstyle(1,4);
        bar(380,20,630,330);
        rectangle(380,20,630,330); setcolor(9);
        outtextxy(480,40,'КОМАНДЫ');outtextxy(470,60,'УПРАВЛЕНИЯ');

         setcolor(13); outtextxy(390,090,'..');   setcolor(10); outtextxy(432,090,'- управление куpсоpом');
         setcolor(13); outtextxy(390,110,'PgDn');   setcolor(10); outtextxy(432,110,'- Вывод следующей стpа-');
         setcolor(13); outtextxy(390,120,'      '); setcolor(10); outtextxy(432,120,'  ницы оглавления');
         setcolor(13); outtextxy(390,140,'PgUp');   setcolor(10); outtextxy(432,140,'- Вывод первой стpаницы');
         setcolor(13); outtextxy(390,150,'      '); setcolor(10); outtextxy(432,150,'  оглавления.');
         setcolor(13); outtextxy(390,170,'Enter');  setcolor(10); outtextxy(432,170,'- Выбор файла и выход.');
         setcolor(13); outtextxy(390,190,'F1 ');    setcolor(10); outtextxy(432,190,'- Инфоpмация.');
         setcolor(13); outtextxy(390,210,'F2 ');    setcolor(10); outtextxy(432,210,'- Пpосмотp файла.');
         setcolor(13); outtextxy(390,230,'F3 ');    setcolor(10); outtextxy(432,230,'- Cмена каталога.');
         setcolor(13); outtextxy(390,250,'ESC');    setcolor(10); outtextxy(432,250,'- Выход без выбоpа.');

      end;

    {  процедура информации о модуле  ( по клавише  "I" ) }

      procedure info;
      begin
        setcolor(14);
        setfillstyle(1,1);
        bar(380,20,630,330);
        rectangle(380,20,630,330); setcolor(13);
        outtextxy(470,40,'ИHФОРМАЦИЯ');
         setcolor(10);
         outtextxy(380,090,'       Модуль  "DIRECTOR"');
         setcolor(13);
         outtextxy(380,105,'       Веpсия  2.2 (.PSL)');
         setcolor(14);
         outtextxy(385,120,'   Модуль DIRECTOR  pазpаботан');
         outtextxy(385,130,'в июле 1991 года  в  институте');
         outtextxy(385,140,'"Магадангpажданпpоект".');
         outtextxy(385,160,'   Автоp - Воpонин Д.А.  ');
         outtextxy(385,170,'   Язык - TURBO-PASCAL.  ');
         outtextxy(385,190,'   Модуль позволит вам пеpеме-');
         outtextxy(385,200,'щаться  по  каталогам,  и пpо-');
         outtextxy(385,210,'сматpивать содеpжимое   файлов');
         outtextxy(385,220,'на экpане. Пpи нажатии клавиши');
         outtextxy(385,230,'"ENTER" пpоисходит возвpащение');
         outtextxy(385,240,'в исходный каталог.  Выбpанный');
         outtextxy(385,250,'файл  pасшиpяется  до  полного');
         outtextxy(385,260,'имени  и пеpедается вызывающей');
         outtextxy(385,270,'пpогpамме. ');
         setcolor(13);
         outtextxy(380,305,'        Hажмите  "ENTER"');
         end;

{ ГОЛОВНОЙ МОДУЛЬ }

      begin
              for i:=1 to 400 do fn[i]:='';

      setactivepage(0);
      setvisualpage(0);
        getdir(0,katal);
     cleardevice;
        setfillstyle(1,5);setcolor(5);
        bar(2,2,638,348);
        rectangle(1,1,639,349);
        setfillstyle(1,1);setcolor(10);
        bar(10,10,370,320);
        rectangle(9,9,371,321);
        rectangle(6,6,374,324);
        line(130,43,130,320);line(250,43,250,320);
        line(10,40,370,40);line(10,43,370,43);
        getdir(0,d);
        outtextxy(20,25,'ТЕК. КАТАЛОГ:  '); setcolor(11);
        fank;
    74: setcolor(14);
        outtextxy(130,25,d);
        mr:=sss; m:=17; n:=1; ind:=0;
        findfirst(mr,AnyFile,s);
    72: d1:=SearchRec(s).Name;
        str(SearchRec(s).Attr,d);   at[1]:=d;
        if d<>'32' then begin if d='16' then goto 78; findnext(s);goto 72;end;
    78: fn[1]:=d1;
        n:=2;
        while doserror<>18 do begin
        findnext(s);
        if doserror=18 then goto 77;
        d1:=SearchRec(s).Name;
        str(SearchRec(s).Attr,d);
        if d='32' then goto 79;
        if d='16' then goto 79;
        if d='0' then goto 79;
        goto 71;
    79: fn[n]:=d1;
        at[n]:=d;  n:=n+1;
        71: ;
        end;
        {  вывод оглавления на экран }
    77: nn:=1;nk:=51;  k:=2;              n:=n-1;
   85:        pn:=nn;
   185: k1:=20; m:=0;
        for i:=nn to nk do begin
             if fn[1]<>'.' then begin
             if ind=1 then goto 82;
             ind:=1;
             k:=k-1; goto 82; end;
             if k>n then goto 83;
         82: l:=50+15*m;
             if l>300 then begin m:=0; k1:=k1+120; goto 82;end;
             if at[k]='16' then setcolor(13);
             outtextxy(k1,l,fn[k]);
             if at[k]='16' then setcolor(14);
             m:=m+1;  k:=k+1;
        end;
      83: setcolor(12);x:=13;y:=46;rectangle(x,y,x+110,y+13);

  10: ch:=readkey;
      if ch<>#0 then funckey:=false else
      begin
         funckey:=true;
         ch:=readkey;
      end;
      if ch=chr(72) then
      begin
        setcolor(1); rectangle(x,y,x+110,y+13); setcolor(12);
        y:=y-15;if y<45 then begin y:=286; x:=x-120; if x<10 then begin
        y:=46; x:=13; pn:=pn+1; end;end;     pn:=pn-1;
         rectangle(x,y,x+110,y+13);  goto 10;
      end;
      if ch=chr(75) then
      begin
        setcolor(1); rectangle(x,y,x+110,y+13); setcolor(12);
        x:=x-120;if x<5 then x:=13 else  pn:=pn-17;
         rectangle(x,y,x+110,y+13);  goto 10;
      end;
      if ch=chr(77) then
      begin
        setcolor(1); rectangle(x,y,x+110,y+13); setcolor(12);
        x:=x+120;if x>300 then x:=253 else  pn:=pn+17;
         rectangle(x,y,x+110,y+13);  goto 10;
      end;
      if ch=chr(80) then
      begin
        setcolor(1); rectangle(x,y,x+110,y+13); setcolor(12);
        y:=y+15; if  y>289 then begin y:=46; x:=x+120; if x>300 then begin
        y:=286; x:=x-120;  pn:=pn-1; end;end;          pn:=pn+1;
        rectangle(x,y,x+110,y+13);  goto 10;
      end;
      if ch=chr(13) then begin d:=at[pn+1]; if ind=1 then d:= at[pn]; if d='16' then goto 89;goto 20;end;
      if ch=chr(59) then begin
                         info;
                         readln;
                         fank;
                         goto 10;
                         end;
      if ch=chr(73) then goto 86;
      if ch=chr(81) then goto 84;
      if ch=chr(61) then goto 81;
      if ch=chr(27) then begin nameoffile:='';goto 90;end;
      goto 10;
      {  смена каталога  }
      89: d:=fn[pn+1];
          if ind=1 then d:=fn[pn];
          goto 88;
      84: if k>n-1 then goto 10;
        setfillstyle(1,1);setcolor(10);
        bar(10,10,370,320);
        rectangle(9,9,371,321);
        rectangle(6,6,374,324);
        line(130,43,130,320);line(250,43,250,320);
        line(10,40,370,40);line(10,43,370,43);
        getdir(0,d);
        outtextxy(20,25,'ТЕК. КАТАЛОГ:  ');

        setcolor(14);
        outtextxy(130,25,d);
        nn:=nn+51;nk:=nk+51;
        goto 85;
      86: {f k<74 then goto 10;}
        setfillstyle(1,1);setcolor(10);
        bar(10,10,370,320);
        rectangle(9,9,371,321);
        rectangle(6,6,374,324);
        line(130,43,130,320);line(250,43,250,320);
        line(10,40,370,40);line(10,43,370,43);
        getdir(0,d);
        outtextxy(20,25,'ТЕК. КАТАЛОГ:  ');
        setcolor(14);
        outtextxy(130,25,d);
        nn:=nn-51;nk:=nk-51;k:=2; pn:=1;
        goto 185;
        81: ;
        setcolor(13);setfillstyle(1,2);
        bar(383,280,627,317);
        rectangle(383,280,627,317);
        setcolor(14);rectangle(386,292,623,313);outtextxy(425,282,'Укажите адрес каталога');
        setcolor(15); moveto(390,297); gread(d);
        if d='' then goto 74;
        {I-}
     88: ChDir(d);
        for i:=1 to 400 do fn[i]:='';
        {I+}
        if ioresult<>0 then begin
        setcolor(13);setfillstyle(1,4);
        fillpoly(sizeof(p4) div sizeof(pointtype),p4);
        setcolor(14);rectangle(45,50,455,75);outtextxy(160,37,'Каталог не найден !!!');
        readln; goto 81; end;
        setfillstyle(1,1);setcolor(10);
        bar(10,10,370,320);
        rectangle(9,9,371,321);
        rectangle(6,6,374,324);
        line(130,43,130,320);line(250,43,250,320);
        line(10,40,370,40);line(10,43,370,43);
        getdir(0,d);
        outtextxy(20,25,'ТЕК. КАТАЛОГ:  ');
        setcolor(14);
        outtextxy(130,25,d);
        goto 74;
        73: ;
        20: setcolor(0);setfillstyle(1,0);fillpoly(sizeof(p5) div sizeof(pointtype),p5);
        setcolor(15);setfillstyle(1,2);pn:=pn+1; if ind=1 then pn:=pn-1;
        nameoffile:=FExpand(fn[pn]);
        fillpoly(sizeof(p4) div sizeof(pointtype),p4);
        setcolor(13);rectangle(45,50,455,75);outtextxy(160,37,'  Выбран файл :');
        setcolor(11);outtextxy(80,62,nameoffile);
        ch:=readkey;
        if ch=chr(0) then begin
             funckey:=true;
             ch:=readkey; end;
        if ch=chr(27) then goto 86;
        90: chdir(katal);
        cleardevice;
        setactivepage(1); setvisualpage(1);
        end;
        end.
