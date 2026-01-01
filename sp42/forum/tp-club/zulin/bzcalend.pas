{$A+,B-,D+,E-,F-,I-,L+,N-,O-,R-,S-,V-}
{$M 1204, 4600, 24000}

unit BZCalend;                         { (c) BZSoft Inc. 1992. }

Interface

uses TpCrt,TpWindow,TpDate,Dos,TpMouse,TpDos;

const EnableMouseCal : boolean = false;
      SoundSwith : word = $1F00; { Alt/S, Install $0000 to ignore }
      DelayOfWhiteCal : word = 30; { second }
      WhiteAndExitCal : boolean = false;
var
    DateFormatCal,
    PYear,
    PMont,
    PDate,Pd : Word;
type CalArrayType = array[0..11] of string[56];
    const
         DD : array [0..6] of string[2] =
               ('Вс','Пн','Вт','Ср','Чт','Пт','Сб');
          DayStringR: array[0..6] of string[11] =
          ('Воскресенье','Понедельник','Вторник    ','Среда      '
          ,'Четверг    ','Пятница    ','Суббота    ');
          MonthString : array[1..12] of string[8] =
          (' Январь ','Февраль ','  Март  ',' Апрель ','  Май   ','  Июнь  '
          ,'  Июль  ',' Август ','Сентябрь','Октябрь ',' Ноябрь ','Декабрь ');
          LenMon:array[1..12] of byte = (31,29,31,30,31,30,31,31,30,31,30,31);
          FormDUS = 0{mdy}; FormDEurope = 1{dmy}; FormDJapan = 2{ymd};
          FormCal : 0..2 = FormDEurope;
          DateSlashChar : char = '.';
          HelpCalArray : CalArrayType =
           (' КАЛЕНДАРЬ ',
            '',
            '    Сейчас  Вы  можете  выбрать  нужную  дату  в  окошке',
            '  КАЛЕНДАРЯ.  Для  ввода  выбранной  даты нажмите ENTER.',
            '  Перемещать  курсор  в  окошке  можно  с помощью клавиш',
            '  управления  курсором.  Клавиша Home уменьшает значение',
            '  ГОДа, End -увеличивает. Для МЕСЯЦа соотв. клавиши PgUp',
            '  и  PgDn.  Выбранная  дата  не может быть вне указанных',
            '  пределов, но просмотр возможен с 1600 по 4000 год.    ',
            '  Можете использовать также для управления  "мышь", если',
            '  это утройство и его драйвер установлены в системе.',
            '');

procedure EnterDate ( var oM:word; var oD:word; var oY:word;
                      bM,bD,bY:word; eM,eD,eY:word;
                      Xc,Yc : byte; CalSound:boolean;
                      VA,FA,WA,CA,PA,HA:byte; title : string;
                      var PressEsc : boolean);

Implementation

procedure EnterDate ( var oM:word; var oD:word; var oY:word;
                      bM,bD,bY:word; eM,eD,eY:word;
                      Xc,Yc : byte; CalSound:boolean;
                      VA,FA,WA,CA,PA,HA:byte; title : string;
                      var PressEsc : boolean);

label Jump;

const
     HomeK  = 1;
     EndK   = 2;
     PgUpK  = 3;
     PgDnK  = 4;
     LeftK  = 5;
     RightK = 6;
     UpK    = 7;
     DownK  = 8;
     EnterK = 9;
     HelpK  =10;

var
    W1,W2                     : WindowPtr;

    Xcal,Ycal,LastCol,
    SaveShadowAttr,
    MouseInDay,
    Number,Xlo,Ylo,Xhi,Yhi    : byte;

    SaveSound, Ok, b,
    SaveShadow,
    SaveMouseCursor,
    EnableMouseCalUse         : boolean;

    SaveDelay, a, i,
    FirstDay, LastDay         : word;

    SaveShadowMode            : ShadowType;

    S                         : string;

    c                         : Char;

    TimeCal                   : LongInt;

    MouseSet : set of byte;

 procedure DrawCalendar(M:word;Y:Word);
 var i,c: integer;
     s  : string;
     d  : Date;
     dn : DayType;
     r : word;
 begin ClrScr;
  if Y<100 Then y:=y+1900;
  Str(Y:4,s);s:=' '+s+' '+MonthString[M]+' ';
  FastWrite(s,Ycal,Xcal+4,WA);
  for i:=1 to 6 do FastWrite(DD[i],Ycal+i,Xcal+2,WA);
  FastWrite(DD[0],Ycal+7,Xcal+2,PA);
  d:=DMYtoDate(1,M,Y); Dn:=DayOfWeek(d); r:=Ord(Dn); if r=0 Then r:=7;
  FirstDay := r;
  if M=2 Then
     if (Trunc(Y/4)*4)=Y Then LastDay:=29 else LastDay:=28
   else LastDay:=LenMon[M]; c:=1;
  for i:=1 to LastDay do
   begin
     Str(i:2,s);
     if r=7 Then
        begin FastWrite(s,Ycal+r,Xcal+c*3+2,PA); r:=1; Inc(c) end
       else begin FastWrite(s,Ycal+r,Xcal+c*3+2,WA); inc(r) end
   end
 end;

 procedure Click;
 begin
  case Number of
    1: {Home } ChangeAttribute( 5,Yc+ 3,Xc+29,not VA);
    2: {End  } ChangeAttribute( 5,Yc+ 3,Xc+35,not VA);
    3: {PgUp } ChangeAttribute( 5,Yc+ 5,Xc+29,not VA);
    4: {PgDn } ChangeAttribute( 5,Yc+ 5,Xc+35,not VA);
    5: {Left } ChangeAttribute( 2,Yc+ 7,Xc+35,not VA);
    6: {Right} ChangeAttribute( 2,Yc+ 7,Xc+38,not VA);
    7: {Up   } ChangeAttribute( 2,Yc+ 7,Xc+29,not VA);
    8: {Down } ChangeAttribute( 2,Yc+ 7,Xc+32,not VA);
    9: {Enter} ChangeAttribute(11,Yc+ 9,Xc+29,not VA);
   10: {F1   } ChangeAttribute(11,Yc+11,Xc+29,not VA);
  end;
  if CalSound Then
     begin
       Sound(3000); Delay(50);
       Sound( 600); Delay(50);
       NoSound
     end else Delay(100);
  case Number of
    1: {Home } ChangeAttribute( 5,Yc+ 3,Xc+29, VA);
    2: {End  } ChangeAttribute( 5,Yc+ 3,Xc+35, VA);
    3: {PgUp } ChangeAttribute( 5,Yc+ 5,Xc+29, VA);
    4: {PgDn } ChangeAttribute( 5,Yc+ 5,Xc+35, VA);
    5: {Left } ChangeAttribute( 2,Yc+ 7,Xc+35, VA);
    6: {Right} ChangeAttribute( 2,Yc+ 7,Xc+38, VA);
    7: {Up   } ChangeAttribute( 2,Yc+ 7,Xc+29, VA);
    8: {Down } ChangeAttribute( 2,Yc+ 7,Xc+32, VA);
    9: {Enter} ChangeAttribute(11,Yc+ 9,Xc+29, VA);
   10: {F1   } ChangeAttribute(11,Yc+11,Xc+29, VA);
  end;
end;

 function DateStrRet(d,m,y:word) : string;
 var s,s1,s2,s3:string;
 begin
   Str(d:2,s1); Str(m:2,s2); Str(y:4,s3);
   if (d<10) and (FormCal<>1) Then s1[1]:='0';
   if (m<10) and (FormCal >0) Then s2[1]:='0';
   case FormCal of
    0: s:=s2+DateSlashChar+s1+DateSlashChar+s3;
    1: s:=s1+DateSlashChar+s2+DateSlashChar+s3;
    2: s:=s3+DateSlashChar+s2+DateSlashChar+s1;
   end;
   DateStrRet:=s
 end;

 function DateInSet (d,m,y:word) : boolean;
 var
     n,nb,ne : Date;
 begin
  { Почему-то в этом месте Паскаль производит перемножение слов
    результатом в слово, этим вызвана ошибка и нежелание работать в Новом,
    1992 году, заменим это на стандартные процедуры...
   n := 10000*y+m*100+d;
   nb:= bY*10000+bM*100+bD;
   ne:= eY*10000+eM*100+eD; }
   n := DMYtoDate( d, m, y);
   nb:= DMYtoDate(bd,bm,by);
   ne:= DMYtoDate(ed,em,ey);
   DateInSet:= (n>nb) and (n<ne);
 end;

 procedure AttrDate (d,r:word; High:Boolean);
 var
  X,Y,Attr : byte;
  s : string[2];
 begin
   if EnableMouseCalUse Then HideMouse;
   if r=0 Then r:=7;
   x:= Round(int((d+r-2)/7))+1;
   y:= d-7*(x-1)+r-1;
   x:= Xcal+x*3+2;
   Str(d:2,s);
   if High Then Attr:=CA else if y=7 Then Attr:=PA else Attr:=WA;
   FastWrite(s,y+Ycal,x,Attr);
   if EnableMouseCalUse and High Then ShowMouse;
 end;

 procedure Comm;
 begin
   DrawCalendar(oM,oY);
   if oD>LastDay Then oD:=LastDay;
 end;

 function HelpCal : boolean;
 var
 w : windowPtr;
 a : word;
 i : integer;
 b : boolean;
 begin
   b:= MakeWindow( W,Xc,Yc,Xc+60,Yc+14,true,true,
                    false,HA,HA,HA,HelpCalArray[0]);
   if Not b Then begin HelpCal:=false; Exit; end;
   b := DisplayWindow(W);
   if Not b Then begin HelpCal:=false; Exit; end;
   for i:=1 to 11 do WriteLn (HelpCalArray[i]);
   WriteLn;
   Write ('                Для возврата нажми ПУСК...');
   NormalCursor;
   while (not KeyPressed) and (not MousePressed) do ;
   while KeyPressed or MousePressed do a:=ReadKeyorButton;
   HiddenCursor;
   HelpCal:=true;
   KillWindow(W);
 end;

 procedure VerifyDate(var d:word; var m:word; var y:word);
 begin
   if y<1600 Then y:=1600;
   if y>4000 Then y:=4000;
   if m<1    Then m:=1;
   if m>12   Then m:=12;
   if d<1    Then d:=1;
   if m=2    Then if y=(y/4*4) Then
                     if d>29 Then d:=29 else else if d>28 Then d:=28
             else if d>LenMon[m] Then d:=LenMon[m];
 end;

procedure Beep;
begin
  Sound(800); Delay(250); NoSound
end;

procedure CallF (Func : byte);
begin
Number:=Func;
AttrDate(oD,FirstDay,false);
Click;
  case Func of
   HelpK: if not HelpCal Then Beep;
   HomeK : if oY>1600 Then begin Dec(oY); Comm; end; {Home}
   EndK  : if oY<3999 Then begin Inc(oY); Comm; end; {End}
   PgUpK : begin if oM=1 Then begin
             if oY>1600 Then begin oM:=12;Dec(oY); end end
                      else Dec(oM);
          Comm; end; {PgUp}
   PgDnK : begin if oM=12 Then begin if oY<3999 Then
             begin oM:=1;Inc(oY); end end
                      else Inc(oM);
          Comm; end; {PgDn}
   UpK   : if oD>1 Then Dec(oD)
             else if oM>1 Then begin Dec(oM); DrawCalendar(oM,oY);
                  oD:=LastDay; end
             else if oY>1600 Then begin Dec(oY); oM:=12;
                  DrawCalendar(oM,oY); oD:=LastDay; end; {Up}
   DownK : if oD<LastDay Then Inc(oD)
             else if oM<12 Then begin Inc(oM); DrawCalendar(oM,oY);
                  oD:=1; end
             else if oY<4000 Then begin Inc(oY); oM:=1;
                  DrawCalendar(oM,oY); oD:=1; end; {Down}
   LeftK : if (oD*1.-7)>=1 Then Dec(oD,7)
             else if oM>1 Then begin Dec(oM); DrawCalendar(oM,oY);
                  oD:=LastDay; end
             else if oY>1600 Then begin Dec(oY); oM:=12;
                  DrawCalendar(oM,oY); oD:=LastDay; end; {Left}
   RightK: if oD+7<=LastDay Then Inc(oD,7)
             else if oM<12 Then begin Inc(oM); DrawCalendar(oM,oY);
                  oD:=1; end
             else if oY<4000 Then begin Inc(oY); oM:=1;
                  DrawCalendar(oM,oY); oD:=1; end; {Right}
   end;
AttrDate(oD,FirstDay,true);
end;

procedure MouseDay;

var Mx,My,LD : byte;

begin
 Mx:=MouseWhereX-XCal; My:=MouseWhereY-YCal;
   if (Mx < 5) or ((Mx < 8) and (My < FirstDay)) Then
     begin MouseInDay := 0; Exit end;
  LD := (FirstDay-1+LastDay) mod 7;
  LastCol := (FirstDay-1+LastDay) div 7;
  if (Mx > (LastCol*3+3)) or
     ((LD>0) and ((MX > ((LastCol-1)*3+3)) and (My > Ld))) Then
     begin MouseInDay := 32; Exit end;
  if not (Mx in MouseSet) Then begin MouseInDay:=33; Exit end;
  if ((Mx-2) mod 3) > 0 Then Dec(Mx);
  MouseInDay := ((Mx-2) div 3 - 1) * 7 + My - FirstDay + 1;
end;

begin
SaveShadow:=Shadow; Shadow:=true; SaveShadowAttr:=ShadowAttr;
EnableMouseCalUse := EnableMouseCal and MouseInstalled;
if EnableMouseCalUse Then
   begin
     SaveMouseCursor:=MouseCursorOn;
     EnableEventHandling;
     Xlo:=MouseXLo; Ylo:=MouseYLo;
     Xhi:=MouseXHi; Yhi:=MouseYHi;
     FullMouseWindow;
     MouseGotoXY(Xc+1,Yc+1);
    end;
ShadowAttr:=$07; Ok:=false; PressEsc:=false;
SaveShadowMode:=ShadowMode; ShadowMode:=BigShadow;
SaveDelay:=ExplodeDelay; SaveSound:=SoundFlagW;
SoundFlagW:=CalSound; Explode:=true;
ExplodeDelay:=5; VerifyDate(oD,oM,oY);
if (bD+bM+bY)>0 Then VerifyDate(bD,bM,bY);
if (eD+eM+eY)>0 Then VerifyDate(eD,eM,eY);
b := MakeWindow( w2, Xc, Yc, Xc+60, Yc+14, true,
                 true, false, VA, VA, VA, title);
b := DisplayWindow(w2); HiddenCursor;
FastWrite('Клавиши управления :',                          Yc+ 1,Xc+32,VA);
FastWrite('┌─────┬─────┐',                                 Yc+ 2,Xc+28,VA);
FastWrite('│Home │ End │ - выбор года',                    Yc+ 3,Xc+28,VA);
FastWrite('├─────┼─────┤',                                 Yc+ 4,Xc+28,VA);
FastWrite('│PgUp │PgDn │ - выбор месяца',                  Yc+ 5,Xc+28,VA);
FastWrite('├──┬──┼──┬──┤',                                 Yc+ 6,Xc+28,VA);
FastWrite('│'+#24+' │'+#25+' │'+#27+' │'+#26+' │ - выбор даты',Yc+ 7,Xc+28,VA);
FastWrite('├──┴──┴──┴──┤',                                 Yc+ 8,Xc+28,VA);
FastWrite('│   Enter   │ - ввод даты',                     Yc+ 9,Xc+28,VA);
FastWrite('├───────────┤',                                 Yc+10,Xc+28,VA);
FastWrite('│     F1    │ - подсказка',                     Yc+11,Xc+28,VA);
FastWrite('└───────────┘',                                 Yc+12,Xc+28,VA);
if (bM+bD+bY)>0 Then
   FastWrite('Минимальная дата '+DateStrRet(bD,bM,bY),Yc+13,Xc+2,VA);
if (eM+eD+eY)>0 Then
   FastWrite('Максимальная дата '+DateStrRet(eD,eM,eY),Yc+13,Xc+31,VA);
Xcal:=Xc+2;Ycal:=Yc+3; SoundFlagW:=false; Shadow:=false;
MouseSet := [ 5, 6, 8, 9,11,12,14,15,17,18,21,22];
b := MakeWindow( w1,Xcal,Ycal,Xcal+23,Ycal+8,true,true,false,WA,FA,FA,'');
b := DisplayWindow(w1);
DrawCalendar(oM,oY);
AttrDate(oD,FirstDay,true);
repeat
TimeCal:=TimeMs;
While WhiteAndExitCal and (not (KeyPressed or
                               (EnableMouseCalUse and MousePressed))) do
      if TimeCal<(TimeMs-DelayOfWhiteCal*1000) Then
         if DateInSet(oD,oM,oY)
            Then begin CallF(EnterK); goto Jump end
            else begin TimeCal:=TimeMs; Beep end;
a:=ReadKeyOrButton;
   case a of
   $1C0D: begin CallF(EnterK); Ok:=DateInSet(oD,oM,oY) end;
   $011B,MouseRt: PressEsc:=true;
   $3B00,MouseCtr: CallF(HelpK);
   $4F00: if oY<3999 Then CallF(EndK);
   $4700: if oY>1600 Then CallF(HomeK);
   $4900: CallF(PgUpK);
   $5100: CallF(PgDnK);
   $4800: CallF(UpK);
   $4B00: CallF(LeftK);
   $4D00: CallF(RightK);
   $5000: CallF(DownK);
   MouseLft : begin
     if MouseInWindow(Xcal+1,Ycal+1,Xcal+22,Ycal+7) Then
        begin
          MouseDay;
          case MouseInDay of
          0 : CallF(PgUpK);
          32: CallF(PgDnK);
          1..31 : if MouseInDay = oD Then
                 begin CallF(EnterK); Ok:=DateInSet(oD,oM,oY) end
                else begin
                  Number:=0;
                  AttrDate(oD,FirstDay,false);
                  Click; oD:=MouseInDay;
                  AttrDate(oD,FirstDay,true);
                end
          end
        end;
     if MouseInWindow(Xc+29,Yc+3,Xc+33,Yc+3) and (oY>1600) Then CallF(HomeK);
     if MouseInWindow(Xc+35,Yc+3,Xc+39,Yc+3) and (oY<3999) Then CallF(EndK);
     if MouseInWindow(Xc+29,Yc+5,Xc+33,Yc+5) Then CallF(PgUpK);
     if MouseInWindow(Xc+35,Yc+5,Xc+39,Yc+5) Then CallF(PgDnK);
     if MouseInWindow(Xc+29,Yc+7,Xc+30,Yc+7) Then CallF(UpK);
     if MouseInWindow(Xc+32,Yc+7,Xc+33,Yc+7) Then CallF(DownK);
     if MouseInWindow(Xc+35,Yc+7,Xc+36,Yc+7) Then CallF(LeftK);
     if MouseInWindow(Xc+38,Yc+7,Xc+39,Yc+7) Then CallF(RightK);
     if MouseInWindow(Xc+29,Yc+9,Xc+39,Yc+9) Then begin
        CallF(EnterK);  Ok:=DateInSet(oD,oM,oY) end;
     if MouseInWindow(Xc+29,Yc+11,Xc+39,Yc+11) Then CallF(HelpK);
    end; { Mouse Left Button }
   end;
if a=SoundSwith Then CalSound:= not CalSound;
until Ok or PressEsc;
Jump:
if EnableMouseCalUse Then
   begin
     if SaveMouseCursor Then ShowMouse else HideMouse;
   end;
killWindow(w1); SoundFlagW:=CalSound;
killWindow(w2); Shadow:=SaveShadow; ShadowAttr := SaveShadowAttr;
SoundFlagW:=SaveSound; ShadowMode:=SaveShadowMode; 
ExplodeDelay:=SaveDelay;
if EnableMouseCalUse Then
   begin
     MouseWindow(Xlo,Ylo,Xhi,Yhi);
     if SaveMouseCursor Then ShowMouse else HideMouse;
   end;
end;
end.
