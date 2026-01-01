(*
          Б  А  Л  Д  А
          (детская игра)
      Павел Северов 1989, 1993
*)

uses Crt;

label
  START,MENU;

const
  BS=#8;
  CR=#13;
  LF=#13#10;
  Etx=#0;
  SizW=20;
  SizIRW=8000;
  Nothing=-1;
  Balda='БАЛДААААААААААААААААААААААААААААААААААААААААААААА';

const
  BigSize=65535;

type
  BigChars=array [1..BigSize] of char;
  GameWord=string[SizW];

var
  C1,C2,C3:^BigChars;
  i,j,k,l,m,n,LenW,jBest:longint;
  kFr,FFr,LFr:longint;
  CountMy,CountYour:byte;
  a,b,c,d:char;
  W,WW,w1,w2:GameWord;
  FileWords:text;
  OrigMode:integer;
  LogFFr,LogLFr,ImFirst:boolean;
  NRW,NRWBest,NRWAll,MaxArray:longint;
  IRW,LRW:array [1..SizIRW+1] of longint;

{***************************************************************************}

procedure Win;
begin TextBackground(Blue);TextColor(Yellow);Window(1,1,40,24);ClrScr end;

procedure Men;
begin TextBackground(Blue);TextColor(Yellow);Window(1,5,40,11);ClrScr end;

procedure Mes;
begin TextBackground(Blue);TextColor(Yellow);Window(1,15,40,19);ClrScr end;

procedure Ask;
begin TextBackground(Blue);TextColor(Yellow);Window(1,20,40,24);ClrScr end;

procedure War;
begin TextBackground(Black);TextColor(Yellow);Window(1,25,40,25);ClrScr end;

procedure Wor;
begin TextBackground(Blue);Window(1,2,40,2);ClrScr;
Window(15,2,40,2);TextBackground(Red);TextColor(Yellow);
write(' ',W,' ');end;

procedure Think;
begin Win;
TextColor(Yellow+Blink);writeln;
write('         подожди, я думаю...');end;


function GetKey:char;
var c:char;
begin
c:=ReadKey;
if c=#27 then begin TextMode(OrigMode);Halt end;
GetKey:=c; end;


function BigC(c:char):char;
begin
case c of
  'а'..'п': c:=Chr(Ord(c)-32);
  'р'..'я': c:=Chr(Ord(c)-48-32);
  end;
BigC:=c;
end;

function Rus(c:char):boolean;
begin if c in ['А'..'Я','а'..'п','р'..'я'] then Rus:=True else Rus:=False;end;

function Ran(i:longint):longint;{Выдает случайное 1..i}
begin Ran:=Random(i)+1;end;

procedure Beep;
begin Sound(220);Delay(100);Nosound end;


function GetC:char;
var c:char;
begin
repeat
  c:=GetKey;
  if c=#0 then begin Beep; GetKey; continue end
  until true;
case c of
  'Q':c:='Й';'{':c:='Х';':':c:='Ж';'>':c:='Ю';'o':c:='щ';'k':c:='л';'m':c:='ь';
  'W':c:='Ц';'A':c:='Ф';'"':c:='Э';'}':c:='Ъ';'p':c:='з';'l':c:='д';',':c:='б';
  'E':c:='У';'S':c:='Ы';'Z':c:='Я';'q':c:='й';'[':c:='х';';':c:='ж';'.':c:='ю';
  'R':c:='К';'D':c:='В';'X':c:='Ч';'w':c:='ц';'a':c:='ф';'''':c:='э';']':c:='ъ';
  'T':c:='Е';'F':c:='А';'C':c:='С';'e':c:='у';'s':c:='ы';'z':c:='я';
  'Y':c:='Н';'G':c:='П';'V':c:='М';'r':c:='к';'d':c:='в';'x':c:='ч';
  'U':c:='Г';'H':c:='Р';'B':c:='И';'t':c:='е';'f':c:='а';'c':c:='с';
  'I':c:='Ш';'J':c:='О';'N':c:='Т';'y':c:='н';'g':c:='п';'v':c:='м';
  'O':c:='Щ';'K':c:='Л';'M':c:='Ь';'u':c:='г';'h':c:='р';'b':c:='и';
  'P':c:='З';'L':c:='Д';'<':c:='Б';'i':c:='ш';'j':c:='о';'n':c:='т';
  end;
GetC:=c
end;

function GetRusC:char;
var cc,c:char;
begin
c:=#0;
TextBackground(Red);write(' ',BS);
repeat
  cc:=GetC; if (cc=CR) and (c<>#0) then break;
  if cc<>CR then c:=cc;
  if not Rus(c) then begin Beep;continue end;
  c:=BigC(c);write(c,BS) until false;
GetRusC:=c
end;

procedure Wlf(i:integer);
begin for i:=i downto 0 do writeln end;


procedure Chao(Im:boolean);
var c:char;i:longint;
begin
ImFirst:=Im;
if not Im then CountMy:=CountMy+1 else CountYour:=CountYour+1;
Ask;
write('      Счет такой:   Я = ');
TextColor(Yellow+Blink);
write(Copy(Balda,1,CountMy),LF);
TextColor(Yellow);
write('                   ТЫ = ');
TextColor(Yellow+Blink);
write(Copy(Balda,1,CountYour),LF,LF);
TextColor(Yellow);
write('      Еще поиграем (Д/Н) ');
TextColor(Yellow+Blink);
write('?');
c:=GetKey;
if c in ['Д','д','L','l',#13] then begin
  Think;
  C1^:=C2^;
  {i:=1;repeat C1^[i]:=C2^[i];i:=i+1 until C2^[i]=Etx}
  end
else begin TextMode(OrigMode);Halt end;
end;


function Select:boolean;
var i,j,k,l,ii,len:longint;
begin
i:=1;j:=1;l:=1;NRW:=Nothing;
repeat
  if C1^[i]=CR then begin i:=i+1; j:=i end;
  ii:=i;
  k:=1; while (k<=Length(W)) and (C1^[i]=W[k]) do begin i:=i+1;k:=k+1 end;
  if (k>Length(W)) and (C1^[i]=CR) and (ii=j) then begin Select:=True;exit end;
  if C1^[i]=CR then i:=i-1;
  if (k>Length(W)) and (NRW<SizIRW) then begin {нашли еще слово и заносим его в xRW}
    if NRW=Nothing then NRW:=1 else NRW:=NRW+1;
    IRW[NRW]:=l;
    len:=0;
    repeat
      C1^[l]:=C1^[j]; l:=l+1; j:=j+1; len:=len+1
      until C1^[l-1]=CR;
    LRW[NRW]:=len-1;
    i:=j-1 end;
  i:=i+1
  until C1^[i-1]=Etx;
C1^[l]:=Etx;Select:=False;
end;

{***************************************************************************}

begin
OrigMode:=LastMode;TextMode(C40);
ImFirst:=False;Randomize;
CountMy:=0;CountYour:=0;
Win;

TextColor(Yellow);
writeln;writeln;
writeln('           Б  А  Л  Д  А');
writeln;
writeln('           (детская игра)');
writeln;writeln;writeln;
TextColor(Yellow);
writeln('       Павел Северов 1989, 1993');
writeln;
writeln(' Правила:');
writeln;
writeln('Ты загадываешь слово и пишешь букву из');
writeln('него, я приписываю к ней с любого конца');
writeln('еще одну, имея при этом в виду свое');
writeln('слово. И так далее...');
writeln('Проигрывает тот, кто завершит слово,');
writeln('либо тот, кто такое слово не знает.');
writeln;
writeln('   (программа немного жухает...)');
TextColor(Yellow+Blink);
writeln;
write(LF,'         Подожди немного...');

New(C1);New(C2);
Assign(FileWords,'bigbalda.dat');Reset(FileWords);
i:=1;
while not Eof(FileWords) and (i<=Bigsize) do begin
  read(FileWords,C1^[i]);
  C2^[i]:=C1^[i];
  {write(C1^[i]);}
  i:=i+1;
  end;
{потом убрать        while C1^[i]<>CR do i:=i-1;}
{C1^[i]:=CR;C2^[i]:=CR;i:=i+1;}
C1^[i]:=Etx;C2^[i]:=Etx;

for i:=1 to 20 do write(BS);
TextColor(Yellow);
writeln('нажми любую клавишу.');
GetKey;ClrScr;

START: {--------------------------------------------------}

Win;Mes;
WW:='';
if ImFirst then begin
  write(' Ты проиграл, я начинаю.');
  W:=Chr(Ord('А')+Ran(31)); NRW:=0 end
else begin
  write(' Ты начинаешь, введи первую букву >>>');
  W:=GetRusC;ClrScr;
  {W:='РОДИН';}
  {W:='АНТ'; ---- здесь жухает!}
  end;


repeat {------------------------}

  Wor;
  if ImFirst then ImFirst:=False
  else begin
    Think;
    if Select then begin Wor;Mes;write(' Ты проиграл, я знаю это слово.');Chao(True);goto START end;
    if NRW=Nothing then begin
      Wor;Mes;
      writeln(' Сдаюсь, я такого слова не знаю.');
      if WW<>'' then write(' А я загадал слово ',WW);
      Chao(False);goto START end;

    {поиск оптимального слова}
    jBest:=Nothing;NRWAll:=NRW; NRWBest:=1;

    LenW:=Length(W);


    {поиск первого подходящего}
    for i:=1 to NRW do
      if not Odd(LRW[i]-LenW) then begin
        jBest:=i;

        {поиск мимнимального подходящего}
        NRWBest:=1;
        for i:=i+1 to NRW do
          if not Odd(LRW[i]-LenW) then begin
            NRWBest:=NRWBest+1;
            if LRW[i]<LRW[jBest] then jBest:=i;
            end;

        {выбор минимальных}
        if jBest<>Nothing then begin
          k:=1;
          for i:=1 to NRW do
            if LRW[jBest]=LRW[i] then begin
              IRW[k]:=IRW[i];LRW[k]:=LRW[i];k:=k+1 end;
          NRW:=k-1;
          end;

       break end;


    {если выигрышных нет сортируем невыигрышные по убыванию длины}
    if jBest=Nothing then begin
      for k:=1 to NRW do
        for l:=k+1 to NRW do if LRW[k]<LRW[l] then begin
           m:=LRW[k];LRW[k]:=LRW[l];LRW[l]:=m;
           m:=IRW[k];IRW[k]:=IRW[l];IRW[l]:=m end;

      {проверяем не входят ли маленькие в большие}
      for k:=1 to NRW do begin
        w1:='';for m:=IRW[k] to IRW[k]+LRW[k]-1 do w1:=w1+C1^[m];
        n:=0;
        for l:=k+1 to NRW do begin
          w2:='';for m:=IRW[l] to IRW[l]+LRW[l]-1 do w2:=w2+C1^[m];
          n:=n+Pos(w2,w1) end;
        if n=0 then begin
          IRW[1]:=IRW[k];LRW[1]:=LRW[k];
          break;end;
        end;
      NRW:=1;
      end;

    jBest:=Ran(NRW);

    {посылаем оптимальное слово в WW}
    i:=IRW[jBest];WW:='';
    while C1^[i]<>CR do begin WW:=WW+C1^[i];i:=i+1 end;

    {определяем границы вхождения W в WW}
    FFr:=Pos(W,WW);LFr:=FFr+Length(W)-1;

    {с какой стороны подставляем букву?}
    LogFFr:=FALSE;LogLFr:=FALSE;
    i:=FFr-1; if FFr<>1        then begin LogFFr:=TRUE;kFr:=i end;
    j:=LFr+1; if j<=Length(WW) then begin LogLFr:=TRUE;kFr:=j end;
    if LogFFr and LogLFr then if Ran(2)=2 then kFr:=i else kFr:=j;
    if kFr=i then W:=WW[kFr]+W else W:=W+WW[kFr];

    Wor;Mes;writeln(LF,LF,' Я сделал ход.');
    if NRW>0 then
      write(LF,'     Я выбирал из ',NRWAll,' слов ',LF,
            '     ',NRWBest,' из них были выигрышными'{,LF,'W=',W,' WW=',WW});
    Wor;
    if W=WW then begin
      Wor;Mes;write('Я проиграл,',LF,'это слово мне известно.');
      Chao(FALSE);goto START;
      end
    end;


MENU:MEN;
  writeln('   ',#27,'  добавить букву в начало');
  writeln('   ',#26,'  добавить букву в конец');
  writeln('   ',#24,'  текущее слово мне известно');
  writeln('   ',#25,'  сдаюсь');

  TextColor(Yellow+Blink);write(LF,'   ?');
  repeat c:=GetKey until c=#0; c:=GetKey;
  TextColor(Yellow);DelLine;

  case c of

    #75:begin Mes;Ask;Wor;write(CR);W:=GetRusC+W end;

    #77:begin Mes;Ask;Wor;write(BS);W:=W+GetRusC end;

    #80:begin
      Ask;Mes;writeln('   Ну и БАЛДА!!!');
      if WW<>'' then write('   А я загадал слово ',WW);
      Chao(TRUE);goto START;
      end;

    #72:begin
      Ask;Mes;write('  Значит я проиграл...');Chao(FALSE);goto START;
      end;

    '+':begin
      Win;
      writeln('--------------------------------------');
      for j:=1 to NRW do begin
        write('  ',j,')  POZ=',IRW[j],'  LEN=',LRW[j],'   <');
        i:=IRW[j]; while C1^[i]<>CR do begin write(C1^[i]);i:=i+1 end;
        writeln('>')
        end;
      writeln('<',WW,'>   RAN=',kFr,' LEFT=',FFr,' RIGHT=',LFr);
      writeln('--------------------------------------');
      GetKey;ClrScr;
      end;

    else goto MENU;
    end{case};

  until False;

Chao(False);goto START;

end.

