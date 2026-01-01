uses vvs_dbf;
const filename='kadr';  {имя файла без расширения}

var d:fbase_dcb; {описание файла dbf}
  i,j:integer;
  n:longint;
  fnam:string;
  f1,f2:longint;
begin
  Open_Dbf(d,filename); {открыли файл}

  {-----------общие сведения о файле------------------}
  Writeln('Файл ',filename);
  Writeln('Полей . . . . . . . . . . .  ',d.k);
  Writeln('Записей в файле/longint/. .  ',d.head.lf);
  Writeln('Длина заголовка/word/ . . .  ',d.head.headlen);
  Writeln('Длина записи/word/. . . . .  ',d.head.reclen);
  {------поля------}
  for i:=1 to d.k do
  begin

    fnam:=''; {имя поля}
    for j:=1 to 11 do
       if d.phead^[i].name[j]<>chr(0) then fnam:=fnam+d.phead^[i].name[j];
    {получили имя поля}


    Writeln(i:4,                              {N П/П}
    ' тип: ',d.phead^[i].typef,               { char  тип поля /C,N,L,D,M/}
    ' длина: ',d.phead^[i].width:3,' ',d.phead^[i].dec:2,{byte  ширина поля}
    ' имя ',fnam);

  end;
  readln;
  {------поиск конкретных полей--------}
  Fnam:='FIO';   {имя поля заглавными буквами}
  f1:=Find_Dbf(d,fnam);
  Writeln (f1,' имя ',fnam);
  if f1=0 then Writeln ('Поле не найдено') else  Writeln ('Поле найдено');

  Fnam:='FIo';   {имя поля заглавными буквами}
  f2:=Find_Dbf(d,fnam);
  Writeln (f2,' имя ',fnam);
  if f2=0 then Writeln ('Поле не найдено') else  Writeln ('Поле найдено');

  Fnam:='ZVAN';   {имя поля заглавными буквами}
  f2:=Find_Dbf(d,fnam);
  Writeln (f2,' имя ',fnam);
  if f2=0 then Writeln ('Поле не найдено') else  Writeln ('Поле найдено');

  readln;
  for i:=1 to d.head.lf do
  begin
    Read_Dbf(d); {прочли очередную запись}
    writeln(i:4,' FIO  ',Get_Dbf(d,f1));
    writeln('     ZVAN ',Get_Dbf(d,f2));
  end;


  Close_Dbf(d); {закрыли файл теперь переменную d можно использовать
                                                  для работы с другим файлом}
end.
