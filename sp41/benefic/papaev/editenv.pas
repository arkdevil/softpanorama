{
                         Название программы: EditEnv

           Программа для редактирования переменных окружения ДОСа.

              Идея создания: ночь с 23 на 24 октября 1991 года.

          Размер ЕХЕ файла свернутого LZEXE составляет 13445 Кбайт.

                   Текст на английском писал Антон Трушин.

                 Воплощение идеи осуществлял Папаев Владимир.

               При создании программы использовались библиотеки
                Object Professional фирмы TurboPower Software.

           Компиляция программы осуществлялась на Turbo Pascal 6.0

         Замечания и пожелания лучше высказать по телефону в Москве:
                     421-0359 с 21.00 до 22.00 (Володя).
}

Program EditEnv;

uses             
   OpString, { Библиотеки Object Professional фирмы TurboPower Software }
   OpDos,
   OpCrt,
   OpCmd,
   OpSEdit;

const                               { Определение цветов }
  OurColorSet : ColorSet = (
    TextColor            : $1B; TextMono            : $07;
    CtrlColor            : $71; CtrlMono            : $70;
    FrameColor           : $17; FrameMono           : $0F;
    HeaderColor          : $71; HeaderMono          : $70;
    ShadowColor          : $08; ShadowMono          : $70;
    HighlightColor       : $71; HighlightMono       : $70;
    PromptColor          : $1B; PromptMono          : $07;
    SelPromptColor       : $1B; SelPromptMono       : $07;
    ProPromptColor       : $1B; ProPromptMono       : $07;
    FieldColor           : $1F; FieldMono           : $0F;
    SelFieldColor        : $71; SelFieldMono        : $70;
    ProFieldColor        : $1F; ProFieldMono        : $0F;
    ScrollBarColor       : $17; ScrollBarMono       : $07;
    SliderColor          : $17; SliderMono          : $07;
    HotSpotColor         : $71; HotSpotMono         : $07;
    BlockColor           : $2F; BlockMono           : $0F;
    MarkerColor          : $0F; MarkerMono          : $70;
    DelimColor           : $1F; DelimMono           : $07;
    SelDelimColor        : $71; SelDelimMono        : $70;
    ProDelimColor        : $1F; ProDelimMono        : $07;
    SelItemColor         : $2F; SelItemMono         : $70;
    ProItemColor         : $17; ProItemMono         : $07;
    HighItemColor        : $1F; HighItemMono        : $0F;
    AltItemColor         : $1F; AltItemMono         : $0F;
    AltSelItemColor      : $2F; AltSelItemMono      : $70;
    FlexAHelpColor       : $1F; FlexAHelpMono       : $0F;
    FlexBHelpColor       : $1F; FlexBHelpMono       : $0F;
    FlexCHelpColor       : $1B; FlexCHelpMono       : $70;
    UnselXrefColor       : $1E; UnselXrefMono       : $09;
    SelXrefColor         : $5F; SelXrefMono         : $70;
    MouseColor           : $4F; MouseMono           : $70
  );

var
  sle : simplelineeditor;
  e,s:string;
  env:envrec;

procedure help;
begin
  writeln('Mastering Your Environment');
  writeln('~~~~~~~~~~~~~~~~~~~~~~~~~~');
  writeln('While running Windows 3.0 in 386 enhanced mode, there''s no way to modify DOS''s');
  writeln('master copy of the environment. For example, it''s not possible to change the');
    write('system PATH after starting Windows. Revising the PATH from a COMMAND window or a');
    write('batch file affects only that copy of the environment; the PATH settings of other');
  writeln('windows remain unchanged.');
  writeln;
  writeln('Edited by Anton Trushin.');
end;

begin
  writeln;
  writeln('Edit the master environment in DOS and Windows 3.0');
  writeln('Сopyright (c) Papaev Wladimir, Moscow 1991, Version 1.0');
  writeln;
  e:=stupcase(paramstr(1));
  
  if e='' then begin
    writeln('Usage: EDITENV variable name');
    writeln('       To edit variable name');
    writeln('   Or: EDITENV /D');
    writeln('       To display environment');
    writeln;
    writeln('To edit an environment variable, type EDITENV NAME, where NAME is the');
    writeln('variable in question - for example, PATH or PROMPT. In order to diplay all');
    writeln('varibles, their settings, and the amount of unused environment space.');
    writeln;
    help;
    halt;
  end;
  
  masterenv(env);
  
  if (e='/D') or (e='-D') then 
  begin
    dumpenv(env);
    halt
  end;
  s:=getenvstr(env,e);
  
  if s='' then 
  begin
    writeln('"',e,'" not found in environment');
    halt(1);
  end;
  
  with ourcolorset do 
  begin
    sle.init(defaultcolorset); { Инициализация строки с цветом по умолчанию }
    sle.setpromptattr(promptcolor,promptmono); { Определение цвета для сообщения }
    sle.setfieldattr(fieldcolor,fieldmono); { Определение цвета для поля }
  end;
  
  writeln('Current value: ',s); { Вывод текущего значения }
  writeln;
  
  sle.readstring('New value:      ',wherey,1,127,screenwidth-16,s);
  { Запрос нового значения }
  
  if (sle.getlastcommand<>ccQuit) then  { Обработка команды пользователя }
  begin
    writeln;
    writeln;
    if setenvstr(env,e,s) then
      writeln('Environment string changed')
    else
      writeln('Unable to change environment');
   end;
   writeln;
end.
