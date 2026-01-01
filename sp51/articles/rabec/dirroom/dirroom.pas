{$A+,B-,D+,E-,F-,I+,L+,N-,O-,R+,S+,V-}
{$M 65520,0,0}
program DirRoom;  { (C) V.S. Rabets, 1992 }
                       { edition 11-11-92 }
uses DOS,CRT,DirRUnit;

const CopyRight = '!DirRoom, ver. 1.00.  (C) V.S. Rabets, 1992';

const CR = #13#10;                { Новая строка }
const DRfile: string = '';        { Диск:\путь\имя файла !DirRoom }
      DRsize: longint = 0;        {  его размер }
      InfoMode: boolean = true;   { Информ. режим - без создания !DirRoom }
      Verbose: boolean = false;   { Выдача на экран размеров всех каталогов }
      ClCount: longint = 0;       { Число кластеров во всех каталогах }
var ClSizeB,                    { Размер кластера в байтах }
    ClSizeEl,                   { то же, в элементах каталога (1 эл.=32 байт)}
    FreeSpaceCl: word;          { Свободное пространство на диске, кластеров }
    RootDir: string[3];         { Имя корневого каталога (Диск:\) }
    MaxY: byte absolute 0:$484; { Число строк экрана минус 1 }


procedure Help;
begin
  writeln ('Программа - довесок к SpeeDisk (Norton Utilities 6.0, 5.0, 4.5).'+
       CR+ ' Создает файл такого размера, чтобы объем дискового пространства,'+
       CR+ ' занимаемого этим файлом и всеми оглавлениями каталогов (кроме корневого),');
  writeln (' равнялся заданному.'+LF+
       CR+ 'Вызов программы:'+
       CR+ ' !DirRoom  drive[\path[\filename]] [size] [/V] [/P]'+LF+
       CR+ ' drive[\path[\filename]] - указывает обрабатываемый диск и, возможно,');
  writeln ('                           имя и местоположение создаваемого файла.'+
       CR+ '      Файл, естественно, всегда создается на обрабатываемом диске.'+
       CR+ '      Возможные варианты:');
  writeln ('         диск\путь\имяфайла - указывает и имя файла, и его местоположение.'+
       CR+ '         диск\путь          - файл !DIRROOM создается в указанном директории.'+
       CR+ '         диск               - файл !DIRROOM создается в текущем каталоге');
  writeln ('                              указанного диска.'+
       CR+ ' size - объем дискового пространства (в кластерах), которое должны занимать файл'+
         + '        !DirRoom и оглавления всех (кроме корневого) каталогов (целое число).');
  writeln ('        Если size<=0 или не указан, то файл !DirRoom не создается.'+
       CR+ ' /V (verbose) - на монитор выдаются размеры оглавлений каталогов.'+
       CR+ ' /P (pause) - пауза после сообщения об ошибке.');
  halt (1);
end;

procedure GetCommandLineParameters;
var Par: string;
    b: byte;
begin
  if ParamCount=0 then Help;
  for b:=ParamCount downto 1 do
  begin
    Par:=StrUpCase(ParamStr(b));
    if (Par='?') or (Par='/?') or (Par='/H') then Help else
    if (Par[2]=':') and (Par[1] in ['A'..'Z']) and (Par[0]>=#2)
       then DrFile:=Par else
    if Str2Long (Par, DRsize) then InfoMode:=DRsize<=0 else
    if Par='/V' then Verbose:=true else
    if Par='/P' then Pause := true else
    Error ('Не распознан параметр '+Par, 2);
  end;
  if DRfile='' then Error ('Не указан или указан неверно  ДИСК[\ПУТЬ[\ИМЯФАЙЛА]]', 2);
end;

procedure GetDiskParameters;
var R: registers;
begin
  with R do
  begin AH:=$36;
        DL:= byte(DRfile[1]) - byte(pred('A'));
        MsDos (R);
        if AX=$FFFF then
           Error ('Не удалось получить параметры диска '+copy(DRfile,1,2), 3);
        ClSizeB:=AX*CX;
        ClSizeEl:=ClSizeB div 32;
        FreeSpaceCl:=BX;
  end;
end;

procedure DetermineDRfile;
var AltDRfile: string;
begin
  DRfile:=FExpand(DRfile);
  RootDir:=DRfile;
  if InfoMode then exit;
  AltDRfile:=DRfile;
  if not TextOpen (DRfile) then
  begin DRfile:=AddBackSlash(DRfile)+'!DirRoom';
    if not TextOpen (DRfile) then
       Error ('Не удалось открыть ни '+AltDRfile+', ни '+DRfile, 4);
  end;
end;

procedure WriteTableHeader;
begin
  writeln (LF+'  Число  │    Размер    │           Директорий');
  writeln (   'элементов│ Байт  Класт-в│');
  window (1,WhereY, 80,MaxY);
end;

procedure CountDirSpace (Dir: string);
const HeadLength = 25;
var SRec: SearchRec;
    SizeEl, SizeCL: longint;   { Размер оглавления в элементах и кластерах }
begin
  SizeEl:=0;
  Dir:=AddBackSlash(Dir);
  FindFirst (Dir+'*.*', AnyFile, SRec);
  while DosError=0 do
  with SRec do
  begin
    inc(SizeEl);
    if (Attr and 16 <>0) and (Name[1]<>'.') then  CountDirSpace (Dir+Name);
    FindNext(SRec);
  end;

  SizeCl:=SizeEl div ClSizeEl + byte( SizeEl mod ClSizeEl<>0 );
  if Dir<>RootDir then  begin
   inc (ClCount, SizeCl);
   if Verbose then  begin
    if length(Dir)<79-HeadLength then write('':HeadLength, Dir)
                                 else write(Dir:79, #13, '':HeadLength,'...');
    writeln (#13, SizeEl:8, SizeEl*32:8, SizeCl:6, '   ');
   end
  end
end;

procedure CreateDirRoomFile;
var DRfileSize,  { Размер файла !DirRoom в кластерах }
    l: longint;
begin
  if ClCount>DRsize then
     Error ('Оглавления каталогов занимают места больше, чем size.', 6);
  DRfileSize:=DRsize-ClCount;
  if DRfileSize>FreeSpaceCl then
     Error ('Нет места для создания файла !DIRROOM.', 5);
  if DRfileSize>0 then
     for l:=1 to DRfileSize*ClSizeEl do
     write (tf, '0123456789ABCDEF0123456789abcde ');
  {$I-} close(tf); {$I+}
  if IOResult>0 then Error ('Не могу закрыть файл '+DRfile, 3);
  writeln ('Создан файл ', DRfile, ' размером ',
            DRfileSize*ClSizeB, ' байт (', DRfileSize, ' кластеров).');
end;

begin
  ClrScr; TA:=$F; writeln (LF+CopyRight); TA:=7;
  GetCommandLineParameters;
  GetDiskParameters;
  DetermineDRfile;
  if Verbose then WriteTableHeader;
  CountDirSpace (RootDir);
  writeln (LF, 'Оглавления всех каталогов (кроме корневого) занимают ',
                ClCount, ' кластеров (',ClCount*ClSizeB div 1024, ' KB).');
  if not InfoMode then CreateDirRoomFile;
end.
