{$M 32768,0,655360}
program menus;
uses
  TPString,
  TPCrt,
  TPCmd,
  TPWindow,
  TPMenu,
  TPDos,
  scanl;
procedure info;
  begin
    clrscr;
    writeln('Программа для организации меню в командном файле       ');
    writeln('');
    writeln('Запуск:    MENUS  X  Y  s  ИМЯ_ФАЙЛА  [*]              ');
    writeln('');
    writeln('Параметры командной строки:                            ');
    writeln('');
    writeln('  Х,Y        - координаты левого верхнего угла меню    ');
    writeln('  ИМЯ_ФАЙЛА  - имя файла, содержащего описание меню    ');
    writeln('  s          - ориентация меню. Может принимать зна-');
    writeln('               чение "V" - вертикальное и "H" - го-');
    writeln('               ризонтальное');
    writeln('  *          - если установлен, то после использования');
    writeln('               меню будет убрано с экрана');
    writeln('');
    writeln('  Примечание: Если в командной строке явно не указан   ');
    writeln('  путь доступа, то файл данных ищется в текущем ката-  ');
    writeln('  логе а затем по пути доступа из AUTOEXEC.BAT         ');
    writeln('');
    writeln('');
    writeln('        Для продолжения нажмите ENTER                  ');
    readln; clrscr;
    writeln('           Структура записи в файле данных             ');
    writeln('');
    writeln('    Пр: [Kод] Название элемента меню/подменю           ');
    writeln('');
    writeln(' Условные обозначения признака элемента в файле данных ');
    writeln('');
    writeln('  !t: - заголовок меню                                 ');
    writeln('  !m: - элемент меню, содержащий подменю               ');
    writeln('  !s: - элемент подменю                                ');
    writeln('  !o: - элемент главного меню, не содержащий подменю   ');
    writeln('  1,2... - код выхода, проверяемый по ERRORLEVEL       ');
    writeln('');
    writeln('          !t:Работа с ИС АРАМИС        ──┐             ');
    writeln('          !o: 1 Справочная информация    │             ');
    writeln('          !m:Запуск АРАМИС               │ пример      ');
    writeln('          !s: 2 Запуск модуля АРАМИС1    │ файла       ');
    writeln('          !s: 3 Запуск модуля АРАМИС2    │ описания    ');
    writeln('          !m:Архивирование АРАМИС        │ меню        ');
    writeln('          !s: 4 Архивирование БД         │             ');
    writeln('          !s: 5 Архивирование АРАМИС     │             ');
    writeln('          !o: 6 Выход в DOS            ──┘             ');
    writeln('');
    writeln('        Для продолжения нажмите ENTER                  ');
    readln; clrscr;
    writeln('');
    writeln('');
    writeln('');
    writeln('');
    writeln('');
    writeln('    Командная строка содержит ошибки !!!!!!!!!!       ');
    writeln('');
    writeln('');
    writeln('');
    writeln('');
    writeln('');
    writeln('');
  end;
procedure usek(var s:string);
  label 1;
  begin
  1:  if copy(s,1,1)<>' ' then exit;
    delete(s,1,1);
    if s='' then exit;
    goto 1;
  end;

procedure InitMenu(var M : Menu; var d:integer);
const
  Color1 : MenuColorArray = ($1E, $4E, $1A, $2E, $1F, $0E, $1A, $79);
  Frame1 : FrameArray = '╔╚╗╝═║';
var kor,md,otc,i,j,k,xb,yb,ori:integer;
    f:text;
    si:string[3];
    sh,st,s,s1,smt:string;
    sm:array[1..23] of  string[60];
    ss:array[1..23,1..20] of  string[60];
    km:array[1..23] of integer;
    ks:array[1..23,1..20] of integer;
label
   1,2;


begin
  s:=paramstr(1);
  scli(s,i);
  if i<>0 then begin info; halt(0); end;
  val(s,xb,i);
  s:=paramstr(2);
  scli(s,i);
  if i<>0 then begin info; halt(0); end;
  val(s,yb,i);
  s:=paramstr(3);
  usek(s);
  if ((s<>'v') and (s<>'V') and (s<>'h') and (s<>'H')) then
   begin info; halt(0); end;
  if (s='v') or (s='V') then ori:=1;
  if (s='h') or (s='H') then ori:=2;
  s:=paramstr(4);
  if Existonpath(s,s1)=false then begin info; halt(0); end;
  s:=paramstr(5);
  usek(s);
  if s='*' then d:=1 else d:=0;

  {Customize this call for special exit characters and custom item displays}
  for i:=1 to 20 do begin
    sm[i]:=''; km[i]:=0;
    for j:=1 to 20 do begin
      ss[i,j]:=''; ks[i,j]:=0;
    end;
  end;
  i:=0; j:=0;
  assign(f,s1);
  reset(f);
1:  read(f,si);
  if (si='') or (si='   ') then goto 2;
  if si='!t:' then
    begin
       readln(f,s);  st:=s;
    end;
  if si='!m:' then
    begin
       readln(f,s); i:=i+1; j:=0; sm[i]:=s; km[i]:=0;
    end;
  if si='!s:' then
    begin
       read(f,k);
       readln(f,s);  j:=j+1; ss[i,j]:=s; ks[i,j]:=k;
    end;
  if si='!o:' then
    begin
       read(f,k);
       readln(f,s); i:=i+1; j:=0; sm[i]:=s; km[i]:=k;
    end;
  if eof(f) then goto 2 else goto 1;
2:
  i:=1;
  usek(st);
  while sm[i]<>'' do begin
    s:=sm[i];
    usek(s);
    sm[i]:=s;
    j:=1;
    while ss[i,j]<>'' do begin
    s:=ss[i,j];
    usek(s);
    ss[i,j]:=s;
      j:=j+1;
      end;
    i:=i+1;
  end;

  M := NewMenu([], nil);

  if ori=1 then begin

  SubMenu(xb,yb,1,Vertical,Frame1,Color1,st);
  i:=1;
  while sm[i]<>'' do begin
    smt:=sm[i];  if km[i]=0 then sh:=chr(26) else sh:=' ';
    MenuItem(smt,i,1,km[i],sh);
    j:=1;
    if ss[i,j]<>'' then begin
    SubMenu(xb+length(smt),yb+i,1,Vertical,Frame1,Color1,'');
    while ss[i,j]<>'' do begin
      MenuItem(ss[i,j],j,1,ks[i,j],'');
      j:=j+1;
      end;
    PopSublevel;
    end;
    i:=i+1;
    end;
  end else begin

  SubMenu(xb,yb,1,Horizontal,Frame1,Color1,st);
  i:=1;   otc:=2;
  while sm[i]<>'' do begin
    smt:=sm[i]; if km[i]=0 then sh:=chr(25) else sh:=' ';
    MenuItem(smt,otc,1,km[i],sh); otc:=otc+length(smt)+3;
    j:=1;
    if ss[i,j]<>'' then begin
      md:=0;
      for k:=1 to 20 do if length(ss[i,k])>md then md:=length(ss[i,k]);
    kor:=otc-length(smt);
    if kor+md+3>79 then kor:=79-md-3;
    SubMenu(kor,yb+2,1,Vertical,Frame1,Color1,'');
    while ss[i,j]<>'' do begin
      MenuItem(ss[i,j],j,1,ks[i,j],'');
      j:=j+1;
      end;
    PopSublevel;
    end;
    i:=i+1;
    end;

  end;
  ResetMenu(M);
end;
var
  M : Menu;
  Ch : Char;
  Key : MenuKey;
  d:integer;

begin
  InitMenu(M,d);
  Key := MenuChoice(M, Ch);
  if ch=chr(27) then key:=0;
  if d=1 then EraseMenu(M, False);
  halt(key);
end.
