{ ┌──────────────────────────────────────────╖
  │  Николай Михайлов                        ║▐  Подробная информация о ис-
  │  г. Сергиев Посад, ул. Дружбы 11-94      ║▐  пользовании программы   Вы
  │  тел . (8-254)-200-36                    ║▐  можете  найти  ниже, в  ее
  │                                          ║▐  листинге. Поскольку данная
  ╞══════════════════════════════════════════╣▐  программа написана не про-
  │ Программа   Denorton.pas                 ║▐  фессиональным  программис-
  │ Содержание  Проверка/удаление пароля с   ║▐  том, а также т.к. это пер-
  │             утилит П. Нортона 6.0 версии ║▐  вый опыт работы ее  автора
  │ Язык        Pascal                       ║▐  c Turbo-Pascal'ем,   автор
  │ Транслятор  Turbo-Pascal V. 5.5          ║▐  будет признателен за любые
  │                                          ║▐  пожелания в его адрес .
  └──────────────────────────────────────────╜▐
    ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀  }


{$A-,B-,D-,E-,F-,I-,L-,N-,O-,R-,S-,V-}

Program Denorton ;
Var     X,Z,I,Param      : byte;
        Message,Password : string ;
        f                : file of Char ;
        Pass_in_file     : Char;
        Print            : array [1..15] of string [70];

label   Endd,Start,Errors,Prnt;

const Name_file : array [1..17] of string [8] =
      ('UNFORMAT','DISKEDIT','NDD','SF','SD','UE','NUCONFIG','SFORMAT','SPEEDISK',
      'UNERASE','DE','CALIBRATE','FILEFIX','WI','WIPEINFO','DT','DISKTOOL');

      Pass_new : string [16] =('TUJ[IIMUH^SII_N;');

      Data : array [1..49] of string [80]=
      ('Program ','Is not a utility by P.Norton','Password present : ','Password deleted',
       'Password not present','Password already deleted','Error : Disk write protect','Error : Disk not ready',
       'Error: Programs not found','DENORTON  Version 2.00 07.04.1993  Copyright Nick Michailov ',
       'Use     : Denorton.exe  [ switchs ]  [ file ]',
       'Switchs : /i  View Password ','\/d  Delete Password ',
       '\/?  Detailed information on Russuan','\/e  English ',
       'Программа ','Не является утилитой П.Нортона','Пароль установлен : ','Пароль cнят',
       'Пароль не установлен','Пароль yже cнят','Ошибка : Диск защищен от записи','Ошибка : Диск не готов',
       'Ошибка : Программ не обнаружено','DENORTON  Версия 2.00 07.04.1993  (C) Н.Михайлов ',
       'Вызов :   Denorton.exe  [ ключи ]  [ имя файла ]',
       'Ключи :   /i  Просмотр пароля ','\/d  Удалить пароль ',
       '\/?  Подробная информация на русском языке','\/e  English',
       'DENORTON  Программа просмотра/удаления пароля с утилит П. Нортона 6.0 версии',
       'Версия 2.00 07.04.1993  (C) Н.Михайлов г. Сергиев Посад. Тел (8-254)-2-00-36','',
       'Вызов : Denorton.exe  [ ключи ]  [ файл ]','',
       'Ключи : /i Просмотр пароля ',
       '\/d Удаление пароля с программы  .  Если Вы хотите, чтобы при за- ',
       '\   пуске программа запрашивала пароль, но он имел нулевую длину,',
       '\   примените ключ  "/dd" .',
       '\/e Выдавать все сообщения на английском языке ',
       '\/? Выдать эту информацию','',
       '\Одовременное применение в коммандной строке ключей  /i и /d',
       '\не допускается . В противном случае используется ключ, вве-',
       '\денный последним.  При ключе  ''/?''  все остальные ключи не-',
       '\действительны .','',
       'Файл :  имя одной из утилит П.Нортона 6.00 Версии.( По умолчанию ве-',
       '\дется  работа  со всеми утилитами, найденными в каталоге ) .');

        Pass : array [32..122] of byte =
        (58,59,56,57,62,63,60,61,50,51,48,49,54,55,52,53,42,43,40,41,46,47,44,45,34,35,32,33,
         38,39,36,37,122,91,120,121,94,95,92,93,114,115,112,113,118,119,116,117,106,107,104,105,110,111,108,
         109,98,99,64,97,102,103,100,101,0,123,0,0,126,0,124,125,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,96);

begin
      param:=0;
      for i:=1 to 15 do Print[i]:=Data[i+15];

      { ------ Анализ коммандной строки -------- }

      For I:=1 to ParamCount do
       begin
         Message := ParamStr(i);
           for x := 1 to Length(Message) do Message[x] := UpCase(Message[x]);
              if Message = '/I'  then param:=1; { Вывод информации }
              if Message = '/D'  then param:=2; { Снятие пароля    }
              if Message = '/DD' then param:=3; { Установка 'нулевого' пароля }
              if Message = '/E'  then for x:=1 to 15 do Print[x]:=Data[x];
              if Message = '/?'  then
                 begin
                 { ---- Вывод подробной информации ---- }
                   for i:=1 to 19 do
                      begin
                        Message:=Data[i+30];
                        if Copy(Message,1,1)='\' then Message:='        '+Copy(Message,2,79);
                        WriteLn (Message);
                      end;
                   goto endd;
                   end;
         end;


     if param=0 then
     {  ----    Коммандная строка отсутствует ----- }
        begin
         for i:=10 to 15 do
          begin
             Message:=Print[i];
             if Copy(Message,1,1)='\' then Message:='          '+Copy(Message,2,79);
             WriteLn (Message);
          end;
        goto endd;
       end;

    WriteLn ;
    WriteLn (Print[10]);
    WriteLn ;

        { Проверка на наличие в коммандной строке имени файла }

   For i:=1 to 17 do if (Name_file[i]=Message) or (Name_file[i]+'.EXE'=Message ) then
       begin
         Message:= Name_file[i];
         Goto Start
       end;


For I:=1 to 17 do
begin
       Message:=Name_File[i];
Start:
       Print[11]:='';
       Password:='';
       Message:=Message+'.EXE';
       if Message='NDD.EXE' then Print[11]:='-';
       Assign (f,Message);
       Reset (f);
       Z:=IOresult;
       if Z<>2 then
       begin
           if Z<>0 then goto Errors;
           Print [10]:='+';
           Message:=Copy(Message+'               ',1,20);
           Message:='────────> '+Print[1]+Message;

{ ------- Проверка на то, что найденный файл действительно является
          программой П. Нортона 6.0 версии .  Для этого считываются
          с 72 по 79 байт от начала программы и  проверяется на на-
          личие в них ключевого слова "Symantec". Исключение  дела-
          ется только для NDD.exe т.к. у него это слово отсутствует
          почему-то в любом случае     --------------------------  }

          For x:=72 to 79 do
           begin
              seek (f,x);
              read (f,Pass_in_file);
              Password:=Password+Pass_in_file;
              Z:=IoResult;
              if (Z<>0) and (Z<>100) then goto errors;
           end;

          if (Password<>'Symantec') and (Print[11]<>'-') then
          { Это не программа (С) 1991 Symantec Corporation  }
               begin
                   Message:=Message+Print[2];
                   goto prnt;
               end;

          Password:='';

{ ------- Cчитываем байты, с 36 по 51, содержащие пароль и дешифру-
          ем его. Признак конца пароля - ASCII код 26.( Данная про-
          грамма дешифрует только символы с 32 по 127,  не  включая
          расширенные ASCII коды .) -----------------------------  }

          Password:='';

           for x:=36 to 51 do
           begin
               seek (f,x);
               read (f,Pass_in_file);
               Z:=Ord(Pass_in_file);
               if (Z<>26) and (Z>31) and (Z<128) then Password:=Password+Chr(Pass[Z]);
               Z:=IoResult;
              if Z<>0 then goto errors;
           end;

{  Если дешифрируемое слово = "nopasswordisset!", значит пароль отсутствует }

          if Password<>'nopasswordisset!' then
          Begin
             if param=1 then Message:=Message+Print[3]+Password;
             if param>1 then
                             { -------- Снимаем пароль ---------------- }
             Begin
             Message:=Message+Print[4];
                     for x:=36 to 51 do
                         begin
                            if param=2 then Pass_in_File:=Pass_new[x-35] else Pass_in_File:=chr(26);
                          {$i-}
                          seek (f,x);
                          Write (f,Pass_in_file);
                         end;
             end;
          end
          Else if param=1 then Message:=Message+Print[5] else Message:=Message+Print[6];


prnt:        close(f);
             Z:=IoResult;
Errors:       if Z<>0 then
               begin
                 if Z=150 then  WriteLn (Print[7]); { Диск защищен от записи }
                 if Z=152 then  WriteLn (Print[8]); { Диск не готов          }
                 goto endd
               end;

Writeln (Message);
end;
end;

if Print[10]<>'+' then WriteLn (Print[9]); { Программ не найдено ! }

endd: WriteLn ;
      end.