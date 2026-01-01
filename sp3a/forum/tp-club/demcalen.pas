{$A-,B-,D-,E-,F-,I-,L-,N-,O-,R-,S-,V-}
program DemoCalender;
{********************************************************************}
{***                  DEMCALEN.PAS     04-10-91                   ***}
{***                       Writted by BZSoft.                     ***}
{***                                                              ***}
{***           Демонстрационная программа использования           ***}
{***                       модуля  BZCalend                       ***}
{***                                                              ***}
{***                          version 2.0                         ***}
{***                     для Turbo Pascal v6.0                    ***}
{********************************************************************}
uses BZCalend,
     Dos,
     TpString,
     TpCrt,
     BZTools;
var
    PYear,SaveYear,
    PMont,SaveMont,
    PDate,SaveDate,Pd : Word;
    PStr : string;
    EnableSoundEffect : boolean;
    NameFile : string;
    f : file of word;
    LoadDate, WriteDate,
    SetDateSys : boolean;
    LoadOk : boolean;
    PressEsc : boolean;
    i : integer;
{    HelpCalArray : CalArrayType; -> array[0..7] of string[54] }
procedure DateNotSaved;
begin
  WriteToScreen('Date not saved...');
  Halt(2) { Внимание! При невозможности записи возвращается код ошибки 2 }
end;
begin
HelpCalArray[ 1]:='';
HelpCalArray[ 2]:='   Программа  просмотра  и  установки  системной  даты,';
HelpCalArray[ 3]:='                  создано BZSoft, 1991.';
HelpCalArray[ 4]:='';
HelpCalArray[ 5]:='   Определены следующие ключи:';
HelpCalArray[ 6]:='              S - выключить звуковые эффекты';
HelpCalArray[ 7]:='              L - загрузить дату из файла';
HelpCalArray[ 8]:='              W - записать дату в файл';
HelpCalArray[ 9]:='              I - установить системную дату';
HelpCalArray[10]:='';
HelpCalArray[11]:='';
{********* по умолчанию определен следующий текст *********************
          HelpCalArray : CalArrayType =
           (' КАЛЕНДАРЬ ',
            '    Сейчас  Вы  можете  выбрать  нужную  дату  в  окошке',
            '  КАЛЕНДАРЯ.  Для  ввода  выбранной  даты нажмите ENTER.',
            '  Перемещать  курсор  в  окошке  можно  с помощью клавиш',
            '  управления  курсором.  Клавиша Home уменьшает значение',
            '  ГОДа, End -увеличивает. Для МЕСЯЦа соотв. клавиши PgUp',
            '  и  PgDn.  Выбранная  дата  не может быть вне указанных',
            '  пределов, но просмотр возможен с 1600 по 4000 год.',
            '  Можете использовать также для управления  "мышь", если',
            '  это утройство и его драйвер установлены в системе.');
************************************************************************}
CheckBreak:=false; EnableMouseCal:=true; MapColors:=false;
WhiteAndExitCal:=true; DelayOfWhiteCal:=15;
WriteToScreen('Computers Calender ( for PC or XT machine ), version 2.0');
WriteToScreen('  Written by BZSoft, 1991. FreeWare');
LoadDate:=false; WriteDate:=false;
SetDateSys :=false;
EnableSoundEffect :=true;
if ParamCount>0 Then
   begin
     PStr:='';  for i:=1 to ParamCount do PStr:=PStr+ParamStr(i);
     PStr:=StUpCase(PStr);
     if pos('S',PStr)>0 Then EnableSoundEffect:=false;
     if pos('L',PStr)>0 Then LoadDate := true;
     if pos('W',PStr)>0 Then WriteDate:= true;
     if pos('I',PStr)>0 Then SetDateSys:=true;
     PStr:=ParamStr(0);
     NameFile:=Copy(PStr,1,LenGth(PStr)-3)+'DAT';
   end;
GetDate(PYear,PMont,PDate,Pd);       { Читаем текущую дату }
if LoadDate Then
   begin
    Assign(f,NameFile);
    Reset(f);
    if IOResult=0 Then begin
    Read(f,PYear,PMont,PDate);
    if IOResult>0 Then LoadOk:=false;
    close(f) end else LoadOk:=false;
    if not LoadOk Then GetDate(PYear,PMont,PDate,Pd);
   end;
SaveYear:=PYear; SaveMont:=PMont; SaveDate:=PDate;
EnterDate (PMont,PDate,PYear,        { Передаем в процедуру начальную дату,
                                       Затем сюда же будет возвращено новое
                                       значение даты }
           1,1,1991,                 { Задаем минимально допустимую дату,
                                       чтобы опустить проверку ввода- 0,0,0 }
           12,31,2090,               { Задаем максимально допустимую дату,
                                       опустить - задать 0,0,0 }
           10,6,                     { X и Y - координаты верхнего левого
                                       угла окошка }
           EnableSoundEffect,        { Разрешение звуковых эффектов }
           62,                       { Аттрибуты большего окошка }
           31,                       { Аттрибуты рамки календаря }
           30,                       { Аттрибуты поля календаря }
           112,                      { Аттрибуты маркера }
           28,                       { Аттрибуты воскресных дней }
           47,                       { Аттрибуты окна подсказки }
           ' Выберите нужную дату ', { Вписать в рамку }
           PressEsc);
if PressEsc Then begin WriteToScreen(' Break...');Halt(1);end;
if SetDateSys Then SetDate(PYear,PMont,PDate);
if not ((SaveYear=PYear) and (SaveMont=PMont)
                  and (SaveDate=PDate)) Then
   if WriteDate Then
   begin
    Assign(f,NameFile);
    ReWrite(f);
    if IOResult>0 Then DateNotSaved;
    Write(f,PYear,PMont,PDate);
    close(f);
    if IOResult>0 Then DateNotSaved;
    Halt(3)
   end else else Halt(0)
end.
