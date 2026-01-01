{
  ИCXOДНЫЙ ТЕКСТ ПЕЧАТИ ФАЙЛА
  Имя модуля: PF (Print File)
  Автор: Вадим Низамов
  141305 г.Сеpгиев Посад Московской обл.
  Скобяной пос. ул. Кирпичная 27 кв.124
  Рабочий тел. (254)4-77-98
  Версия: 1.01
  Дата создания: 1.06.93
  Язык программирования: Turbo Pascal
  Использованный транслятор: Turbo Pascal 7.0
  Запуск: PF <имя файла> [/<принтер>] [/<качество>]

  Модуль анализирует параметры запуска, последовательно читает и
  и отправляет на печать строки файла, для чего используется модуль
  печати строки PrintString.
}
program PrintFile;
  uses
    PrintString; {подключение модуля печати строки}
  const
    EndOfLine=#$0D#$0A;
  var
    i:word;
    j:integer;
    ParamString:string;
    TextFile:text;
  procedure Help;
    begin
      WRITELN(  'Print File,Copyright(C)1993,PROZA,Nizamov'+
      EndOfLine+'PF <имя файла> [/<принтер>] [/<качество>]'+
      EndOfLine+'принтер: EPSON800,EPSONFX,AMSTRAD,CM6337'+
      EndOfLine+'качество: 0 (черновое), 1 (высокое)')
    end;
  begin
    for i:=1 to ParamCount do
      begin
        ParamString:=PARAMSTR(i);
        for j:=1 to LENGTH(ParamString) do
          ParamString[j]:=UPCASE(ParamString[j]);
        if ParamString='/?' then begin Help;HALT end
        else if ParamString='/0' then Quality:=draft
        else if ParamString='/1' then Quality:=high
        else if ParamString='/EPSON800' then PrinterType:=EPSON800
        else if ParamString='/EPSONFX'  then PrinterType:=EPSONFX
        else if ParamString='/AMSTRAD'  then PrinterType:=AMSTRAD
        else if ParamString='/CM6337'   then PrinterType:=CM6337
        else ASSIGN(TextFile,ParamString);
      end;
    if i=0 then Help
    else
      begin
        {$I-}
        RESET(TextFile);
        {$I+}
        if IOResult=0 then
          begin
            while not EOF(TextFile) do
              begin
                READLN(TextFile,Str); {чтение строки из файла}
                ExecPrint             {запуск процедуры печати строки}
              end;
            CLOSE(TextFile)
          end
        else WRITELN('Файл не найден')
      end
  end.