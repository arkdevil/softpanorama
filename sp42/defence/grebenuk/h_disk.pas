PROGRAM Hard_disk_on_off_utility;
{─────────────────────────────────────────────────────────────────────────┐
│                                                                         │──┐
│                                                                         │  │
│                                                                         │  │
│         ╔═══════════════════╦════╦══════════╦════╗                      │  │
│         ║    ╔═╗            ║    ║          ║    ║                      │  │
│         ║    ╠═╝            ║    ║          ║    ║                      │  │
│         ║    ╠═╗╔═╗╔═╗╔═╗╔═╗║    ╠═╗╔═╗╔═╗╔═╣ ╔══╩════════════╦══╗      │  │
│         ║    ║ ║╠═╝╚═╗╚═╗╠═╝║    ║ ║╔═╣║ ║║ ║ ║   ╦╗     ╔    ╬══╣      │  │
│         ║    ╚═╝╚═╝╚═╝╚═╝╚═╝╚════╩═╝╚═╩╝ ╚╚═╝ ║   ╠╝╔╗╔╗╔╣╗╔╔═║  ║      │  │
│         ╚═════════════════════════════════════╣   ╩ ╩ ╚╝╚╚╚╝╚═╚  ║      │  │
│                                               ╚══════════════════╝      │  │
│                                                                         │  │
│                                                                         │  │
│                                                                         │  │
└─────────────────────────────────────────────────────────────────────────┘  │
   │                                                                         │
   └─────────────────────────────────────────────────────────────────────────}

(*****************************************************************************
*    г. КИЕВ                                                       S SYSTEM  *
*   КВИРТУ ПВО                                                     23.09.91  *
*                               H _ D I S K                                  *
*                                                                            *
*                                 VER 1.0                                    *
*                                                                            *
*        Сергей Гребенюк                              TURBO PASCAL UNIT 6.0  *
*****************************************************************************)

(*****************************************************************************
* Bessel club product                                              S SYSTEM  *
*                   D E S C R I P T I O N       P R O G R A M                *
*  Программа предназначена для включения / выключения твердого диска для     *
*                       загрузки или использования.                          *
*****************************************************************************)
{$M 6000,0,600}
{$V- F- O- X-}
USES
    DOS,Crt;
(******************************  T Y P E  ***********************************)
TYPE
    WorkMode = (help,DiskOn,DiskOff); {возможные режимы работы программы}
    Buf1024 = array[1..512] of byte;
    PtrBuf1024 = ^Buf1024;
    st2 = string[2];
(******************************   V A R   ***********************************)
VAR
   ModeWorkProgram : WorkMode;   {реж. работы}
   Buf             : PtrBuf1024; {динамический буфер}
   StrError        : string;     {для ошибок}
   ErrCode         : word;       {ошибка при работе с Hard Disk}
(************   P R O C E D U R E   &   F U N C T I O N *********************)

{───────────────────────────────────────────────────────────────────────────┐
│ PROCEDURE Show_Description_Run_Program                                    │
│                                                                           │
│               Вывести на экран описание режимов запуска программы         │
│                                                                           │
└───────────────────────────────────────────────────────────────────────────}
PROCEDURE Show_Description_Run_Program;
Begin
 writeln('(*****************************************************************************');
 writeln('* Bessel club product                                              S SYSTEM  *');
 writeln('*                                                                            *');
 writeln('*              D E S C R I P T I O N    R U N     P R O G R A M              *');
 writeln('*                                                                            *');
 writeln('*                                    H _ D I S K                             *');
 writeln('*                                                                            *');
 writeln('*         Запуск программы осуществляется при помощи командной строки:       *');
 writeln('* H_Disk on  - подключение жесткого диска для использования.                 *');
 writeln('* H_Disk off - отключение.                                                   *');
 writeln('*         Предназначена программа для ограничения доступа к жесткому диску   *');
 writeln('* в Ваше отсутствие. При запуске программы с ключом off происходит изменение *');
 writeln('* служебной информации на винчестере. При новой загрузке операционной систе- *');
 writeln('* мы BIOS распознает винчестер как аварийное устройство и не подключает его  *');
 writeln('* для дальнейшего использования.                                             *');
 writeln('*                                                                            *');
 writeln('*         ВНИМАНИЕ! Обязательно храните копию программы H_Disk на дискете.   *');
 writeln('*                                                                            *');
 writeln('* Сергей Гребенюк                                Turbo Pascal    version 6.0 *');
 writeln('* Киев,  тел.213-03-91                           Borland International, Inc. *');
 writeln('*****************************************************************************)');
End;

{───────────────────────────────────────────────────────────────────────────┐
│ PROCEDURE TestParamCount(var Error:string);                               │
│                                                                           │
│         Проверить командную строку и выяснить режим работы программы      │
│     режим работы возвращается в глобальной переменной - ModeWorkProgram;  │
│ ошибку задания командной строки  возвратить в строковой переменной Error; │
│                         без ошибок Error=''                               │
│                                                                           │
└───────────────────────────────────────────────────────────────────────────}
(*****************************************************************************
* В командной строке задаются: on  - включить винт                           *
*                              off - выключить винт                          *
*****************************************************************************)
PROCEDURE TestParamCount(var Error:string);
Var
   param : string;{строка для анализа параметров, заданных в командной строке}
Begin
 Error:='';
 if ParamCount > 0
 then
 begin
   param:=ParamStr(1);
   if (param='on') or (param='ON')
   then begin
         ModeWorkProgram:=DiskOn;
         EXIT;
        end;
   if (param='off') or (param='OFF')
   then begin
         ModeWorkProgram:=DiskOff;
         EXIT;
        end;
    ModeWorkProgram:=help;
    Error:='не распознан параметр командной строки ';
 end
 else
 begin
  ModeWorkProgram:=help;
  Error:=' не задан параметр командной строки.';
 end;
End;

{───────────────────────────────────────────────────────────────────────────┐
│ FUNCTION Code_Error_Int13(err:byte):string;                               │
│                                                                           │
│        Возвращает строку по коду ошибки работы с 13H прерыванием          │
│                                                                           │
└───────────────────────────────────────────────────────────────────────────}
FUNCTION Code_Error_Int13(err:byte):string;
Begin
 case err of
      $0:  Code_Error_Int13:='последняя операция выполнена без ошибок.';
      $01: Code_Error_Int13:='плохая команда: неверный запрос к контроллеру.';
      $02: Code_Error_Int13:='плохая адресная марка.';
      $03: Code_Error_Int13:='защита записи: попытка записи на защищенную дискету.';
      $04: Code_Error_Int13:='ID сектора запорчен или не найден.';
      $05: Code_Error_Int13:='ошибка сброса.';
      $08: Code_Error_Int13:='сбой DMA.';
      $09: Code_Error_Int13:='перекрытие DMA: попытка записи через 64K-байтовую границу.';
      $0b: Code_Error_Int13:='встретился флаг плохой дорожки.';
      $10: Code_Error_Int13:='сбой CRC: несовпадение контрольной суммы данных.';
      $11: Code_Error_Int13:='данные исправлены; исправимая ошибка; исправлено алгоритмом ECC.';
      $20: Code_Error_Int13:='сбой контроллера.';
      $40: Code_Error_Int13:='неудачный поиск. Запрошенная дорожка не найдена.';
      $80: Code_Error_Int13:='Таймаут. Устройство не ответило.';
      $bb: Code_Error_Int13:='неопределенная ошибка.';
      $ff: Code_Error_Int13:='сбой операции опроса (sense).'
      else Code_Error_Int13:='??? неизвестная ошибка';
 end; {case of}
End;

{───────────────────────────────────────────────────────────────────────────┐
│ FUNCTION Read_Disk_Int13(p:pointer;NDisk,head,dor,sector,                 │
│                         NumberSector:byte):string;                        │
│                                                                           │
│    Читать диск через 13H прерывание BIOS. NDisk - N диска (0-диск A...;   │
│    80H - 0-й тв.диск,81H - 1-й тв.диск); p - указатель на данные;         │
│    head - N головки; dor - N дорожки; sector - N сектора; NumberSector -  │
│          число секторов. Возвратить ошибку (''-нет ошибок)                │
│                                                                           │
└───────────────────────────────────────────────────────────────────────────}
FUNCTION Read_Disk_Int13(p:pointer;NDisk,head,dor,sector,
                         NumberSector:byte):string;
Var
   r : registers;
Begin
 r.ah:=$2;           {2-я функция 13H прерывания}
 r.dl:=NDisk;        {0-диск A...;80H - 0-й тв.диск,81H - 1-й тв.диск}
 r.dh:=head;         {N головки чтения}
 r.ch:=dor;          {N дорожки}
 r.cl:=sector;       {N сектора}
 r.al:=NumberSector; {число секторов}
 r.es:=seg(p^);      {адрес буфера}
 r.bx:=ofs(p^);
 intr($13,r);
 if r.ah<>0
 then Read_Disk_Int13:=Code_Error_Int13(r.ah)
 else Read_Disk_Int13:='';
End;

{───────────────────────────────────────────────────────────────────────────┐
│ FUNCTION Write_Disk_Int13(p:pointer;NDisk,head,dor,sector,                │
│                         NumberSector:byte):string;                        │
│                                                                           │
│ Писать на диск через 13H прерывание BIOS. NDisk - N диска (0-диск A...;   │
│    80H - 0-й тв.диск,81H - 1-й тв.диск); p - указатель на данные;         │
│    head - N головки; dor - N дорожки; sector - N сектора; NumberSector -  │
│          число секторов. Возвратить ошибку (''-нет ошибок)                │
│                                                                           │
└───────────────────────────────────────────────────────────────────────────}
FUNCTION Write_Disk_Int13(p:pointer;NDisk,head,dor,sector,
                         NumberSector:byte):string;
Var
   r : registers;
Begin
 r.ah:=$3;           {3-я функция 13H прерывания}
 r.dl:=NDisk;        {0-диск A...;80H - 0-й тв.диск,81H - 1-й тв.диск}
 r.dh:=head;         {N головки чтения}
 r.ch:=dor;          {N дорожки}
 r.cl:=sector;       {N сектора}
 r.al:=NumberSector; {число секторов}
 r.es:=seg(p^);      {адрес буфера}
 r.bx:=ofs(p^);
 intr($13,r);
 if r.ah<>0
 then Write_Disk_Int13:=Code_Error_Int13(r.ah)
 else Write_Disk_Int13:='';
End;


{───────────────────────────────────────────────────────────────────────────┐
│ PROCEDURE Reset_Device                                                    │
│                                                                           │
│                           Сброс диска                                     │
│                                                                           │
└───────────────────────────────────────────────────────────────────────────}
PROCEDURE Reset_Device(NDisk:byte);
Var
   r : registers;
Begin
 r.ah:=NDisk;  {0-я функция 13H прерывания}
 r.dl:=$80;  {80H - 0-й тв.диск}
 intr($13,r);
End;

{───────────────────────────────────────────────────────────────────────────┐
│ FUNCTION H_Read(NDisk:byte;p:pointer):string;                             │
│                                                                           │
│     Прочитать через 13 прерывание BIOS (при ошибке повторить 3 раза)      │
│                                                                           │
└───────────────────────────────────────────────────────────────────────────}
FUNCTION H_Read(NDisk:byte;p:pointer):string;
Var
   n  : byte;
   st : string;
Begin
 n:=0;
 repeat
  st:=Read_Disk_Int13(p,NDisk,0,0,1,1);
  if st<>'' then Reset_Device(NDisk);
  inc(n);
 until (st='') or (n=3);
 H_Read:=st;
End;

{───────────────────────────────────────────────────────────────────────────┐
│ FUNCTION H_Write(NDisk:byte;p:pointer):string;                            │
│                                                                           │
│      Записать через 13 прерывание BIOS (при ошибке повторить 3 раза)      │
│                                                                           │
└───────────────────────────────────────────────────────────────────────────}
FUNCTION H_Write(NDisk:byte;p:pointer):string;
Var
   n  : byte;
   st : string;
Begin
 n:=0;
 repeat
  st:=Write_Disk_Int13(p,NDisk,0,0,1,1);
  if st<>'' then Reset_Device(NDisk);
  inc(n);
 until (st='') or (n=3);
 H_Write:=st;
End;

{───────────────────────────────────────────────────────────────────────────┐
│ PROCEDURE  SetCursor(n:byte);                                             │
│                                                                           │
│                   Устанавливает курсор высотой в n позиций                │
│                                                                           │
└───────────────────────────────────────────────────────────────────────────}
PROCEDURE SetCursor(n:byte);
Var
   reg : registers;
Begin
 reg.ah:=1;
 reg.ch:=8-n;
 reg.cl:=7;
 Intr($10,reg);
End;

{───────────────────────────────────────────────────────────────────────────┐
│ PROCEDURE Reset_Keyboard;                                                 │
│                                                                           │
│                      Сбросить буфер клавиатуры                            │
│                                                                           │
└───────────────────────────────────────────────────────────────────────────}
PROCEDURE Reset_Keyboard;
Var
   ch : char;
Begin
 If keypressed
    then
    begin
     while keypressed do ch:=readkey;
    end
    else EXIT;
End;


{───────────────────────────────────────────────────────────────────────────┐
│ FUNCTION Read_Char_with_star(n:byte):string;                              │
│                                                                           │
│  Читать number символов с клавиатуры; возвратить строку (мигающий курсор) │
│              символы не отображаются; отображается - *                    │
│                                                                           │
└───────────────────────────────────────────────────────────────────────────}
FUNCTION Read_Char_with_star(number:byte):string;
Var
   grad  : boolean; {градиент увеличения курсора}
   count : byte;    {сколько раз читать символ (2 раза)}
   st    : string;
   ch    : char;
   n     : byte;
Begin
 st:='';
 grad:=true; {курсор будет возрастать}
 n:=0;
 count:=0;
 repeat
   if keypressed
   then
   begin
     ch:=readkey;
     write('*');
     st:=st+ch;
     inc(count);
     if count=number
     then
     begin
      delay(300);
      SetCursor(2);
      Read_Char_with_star:=st;
      EXIT;
     end;
   end;
  if grad
  then
  begin
   n:=n+1;
   SetCursor(n);
   if n=8 then grad:=not(grad);
  end
  else
  begin
   n:=n-1;
   SetCursor(n);
   if n=1 then grad:=not(grad);
  end;
  delay(300);
 until false;
End;

{───────────────────────────────────────────────────────────────────────────┐
│ FUNCTION Get_Parol_From_Disk:PathStr;                                     │
│                                                                           │
│       Запрашивает у пользователя 2 символа - пароль доступа к винту       │
│                                                                           │
└───────────────────────────────────────────────────────────────────────────}
FUNCTION Get_Parol_From_Disk:PathStr;
Var
   parol,
   InputParol : st2;
Begin
 Reset_Keyboard;
 parol:='';
 if (Buf^[511]=$55) and (Buf^[512]=$AA)
 then
  begin
   Get_Parol_From_Disk:='нет необходимости использовать программу H_DISK с ключом on.';
   EXIT;
  end;
 parol:=parol+chr(Buf^[511]);
 parol:=parol+chr(Buf^[512]);
 Write('Введите пароль (2 символа): ');
 InputParol:=Read_Char_with_star(2);
 if parol = InputParol
 then
  begin
   Buf^[511]:=$55;
   Buf^[512]:=$AA;
   Get_Parol_From_Disk:=''
  end
 else Get_Parol_From_Disk:='неверный пароль; доступ отвергнут.';
 GotoXY(1,WhereY);
 ClrEol;
End;

{───────────────────────────────────────────────────────────────────────────┐
│ FUNCTION Get_Parol_From_KeyBoard:PathStr;                                 │
│                                                                           │
│  Запрашивает у пользователя 2 символа - с каким паролем закрывать винт    │
│                                                                           │
└───────────────────────────────────────────────────────────────────────────}
FUNCTION Get_Parol_From_KeyBoard:PathStr;
Var
   parol,parol1 : st2;
Begin
 Reset_Keyboard;
 if (Buf^[511]<>$55) or (Buf^[512]<>$AA)
 then
  begin
   Get_Parol_From_KeyBoard:='изменение пароля отвергнуто; используйте программу H_DISK с ключом on.';
   EXIT;
  end;
 Write('Введите пароль (2 символа): ');
 Parol:=Read_Char_with_star(2);
 GotoXY(1,WhereY);
 ClrEol;
 Write('Контроль ввода; просьба подтвердить пароль (2 символа): ');
 Parol1:=Read_Char_with_star(2);
 GotoXY(1,WhereY);
 ClrEol;
 if parol1<>parol
 then
  begin
   Get_Parol_From_KeyBoard:='нарушение корректности ввода пароля.';
   EXIT;
  end
 else
  begin
   Buf^[511]:=ord(parol[1]);
   Buf^[512]:=ord(parol[2]);
   Get_Parol_From_KeyBoard:='';
  end;
End;

{───────────────────────────────────────────────────────────────────────────┐
│ PROCEDURE Run;                                                            │
│                                                                           │
│                                 Работа                                    │
│                                                                           │
└───────────────────────────────────────────────────────────────────────────}
PROCEDURE Run;
Begin
 StrError:='';
 TestParamCount(StrError);
 New(Buf);
 FillChar(Buf^,SizeOf(Buf^),0);
 case ModeWorkProgram of
      help:  Show_Description_Run_Program;
      DiskOn:
      begin
        StrError:=H_Read($80,Buf);
        if StrError<>'' then EXIT;
        StrError:=Get_Parol_From_Disk;
        if StrError<>'' then EXIT;
        StrError:=H_Write($80,Buf);
        if StrError<>'' then EXIT;
      end;
      DiskOff:
      begin
        StrError:=H_Read($80,Buf);
        if StrError<>'' then EXIT;
        StrError:=Get_Parol_From_KeyBoard;
        if StrError<>'' then EXIT;
        StrError:=H_Write($80,Buf);
        if StrError<>'' then EXIT;
      end;
 end; {case off}
End;

{──────────────────────────────────────────────────────────────────────────┐
│**************************************************************************│
│**********************                        ***************** S SYSTEM *│
│**********************   ОСНОВНАЯ ПРОГРАММА   ****************************│
│**********************                        ****************************│
│**************************************************************************│
└──────────────────────────────────────────────────────────────────────────}
BEGIN
 {авторские права}
 writeln;
 writeln;
 writeln('H_Disk              Ver 1.0         23.09.91');
 writeln('Bessel club product                 S SYSTEM');
 writeln('г.Киев                           Сергей Гребенюк');
 writeln;
 Run;
 Dispose(Buf);
 if StrError<>''
 then writeln('Ошибка: '+StrError)
 else writeln('Операция завершилась успешно');
END.
