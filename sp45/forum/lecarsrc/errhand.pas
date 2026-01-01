
{************************************************}
{                                                }
{        L e c a r                               }
{   Turbo Pascal 5.X, 6.X                        }
{   Попросту, без чинов и Copyright-ов  1991     }
{    Версия 1.0 от 11.11.1991 14.00.45.55        }
{************************************************}


{$A+,B-,D-,E-,F-,I-,N-,O-,R-,S-,L-}
{$M $1000, 0, $800}

Unit ErrHand;

{  Используется для обработки критических ошибок,
   возникающих в результате дисковых операций ввода/вывода.
   Благодаря секции инициализации может быть отключен без
   существенных последствий для основной программы. В этом
   случае ошибочные функции завершаются через Abort
}

Interface

Uses
    Crt,
    Dos;

Const
     ErrorFlag     : Boolean = False;    { Индикатор  ошибки }
     LastError     : String  = '';       { Сообщение о последней ошибке }
     MonoHi        : Byte    = $0F;      { Атрибут активного пункта меню (моно) }
     MonoLo        : Byte    = $70;      { Атрибут неактивного пункта меню (моно) }
     ColorSelect   : Byte    = $1E;      { Атрибут активного пункта меню (цвет) }
     ColorUnSelect : Byte    = $4F;      { Атрибут неактивного пункта меню (цвет) }
     ErrHandlerPtr : Pointer = NIL;      { Указатель на пользовательскую процедуру обработки ошибок }
     RetryFlag     : Boolean = True;     { Флаг, возвращаемый пользов. процедурой для операции Retry }

Function GetErrorName : String;          { Возвращает имя ошибки }

Implementation

Var
   ErrorHandler : Procedure Absolute ErrHandlerPtr;
   { Если не указывает в NIL вызывается при каждой дисковой ошибке }

Const
     ErrMsg : Array [0..$58] of String[35] = { Массив сообщений об ошибках }
           (
{00}         'Undefine',
{01}         'Invalid function number',
{02}         'File not found',
{03}         'Path not found',
{04}         'Too many open files',
{05}         'Access denied',
{06}         'Invalid handle',
{07}         'MCB destroyed',
{08}         'Insufficient memory',
{09}         'Invalid memory block addres',
{0A}         'Invalid environment',
{0B}         'Invalid format',
{0C}         'Invalid accses code',
{0D}         'Invalid data',
{0E}         '',
{0F}         'Invalid drive specified',
{10}         'Can''t remove current dir',
{11}         'Not same device',
{12}         'No more matching file',
{13}         'Write-protected',
{14}         'Unknown unit ID',
{15}         'Drive not ready',
{16}         'Unknown command',
{17}         'Disk data error (CRC error)',
{18}         'Bad request structure length',
{19}         'Disk seek error',
{1A}         'Unknown disk media type',
{1B}         'Sector not found',
{1C}         'Out of paper',
{1D}         'Write fault',
{1E}         'Read fault',
{1F}         'General failure',
{20}         'File sharing violation',
{21}         'File locking violation',
{22}         'Invalid disk change',
{23}         'Too many FCBs',
{24}         'Sharing buffer overflow',
{25}         '',
{26}         '',
{27}         '',
{28}         '',
{29}         '',
{2A}         '',
{2B}         '',
{2C}         '',
{2D}         '',
{2E}         '',
{2F}         '',
{30}         '',
{31}         '',
{32}         'Network request not supported',
{33}         'Remote computer not listening',
{34}         'Duplicate name on network',
{35}         'Network name not found',
{36}         'Network busy',
{37}         'Network device no longer exists',
{38}         'Net BIOS command limit exceeded',
{39}         'Network adapter hardware error',
{3A}         'Incorrect response from network',
{3B}         'Unexpected network error',
{3C}         'Incompatible remote adapter',
{3D}         'Print gueue full',
{3E}         'Not enough space for print file',
{3F}         'Print file was deleted',
{40}         'Network name was deleted',
{41}         'Access denided',
{42}         'Incorrect network device type',
{43}         'Network name not found',
{44}         'Network name limit exceeded',
{45}         'Net BIOS sessinon linit exceeded',
{46}         'Temporarily paused',
{47}         'Network request not accepted',
{48}         'Print or disk redirection is paused',
{49}         '',
{4A}         '',
{4B}         '',
{4C}         '',
{4D}         '',
{4E}         '',
{4F}         '',
{50}         'File already exist',
{51}         '',
{52}         'Cannot make directory entry',
{53}         'Fail error from int 24h',
{54}         'Too many redirections',
{55}         'Duplicate redirection',
{56}         'Invalid password',
{57}         'Invalid parameter',
{58}         'Network data fault'
           );

     { Сообщения об ошибках, возвращаемые INT 24H }
     Int24ErrMsg : Array [0..$11] of String[30] =
           (
{00}         'Write-protect error',
{01}         'Unknown unit',
{02}         'Drive not ready',
{03}         'Unknown command',
{04}         'Data error ( bad CRC )',
{05}         'Bad request structure lentgh',
{06}         'Seek error',
{07}         'Unknown media type',
{08}         'Sector not found',
{09}         'Printer out of paper',
{0A}         'Write fault',
{0B}         'Read fault',
{0C}         'General failure',
{0D}         'Sharing violation',
{0E}         'Lock violation',
{0F}         'Invalid disk change',
{10}         'FCB unavailable',
{11}         'Sharing buffer overflow'
           );

     TextModes : Set of Byte = [ 0, 1, 2, 3, 7 ] ;
     { Видеорежимы, поддерживаемые unit-ом ErrHand }

Type
    BuffType   = Array [0..3999] of Byte;
    { Видеобуфер  }

Const
     Height  = 10; { Высота окна ошибки }
     XL      = 25; { Верхний левый угол }
     YL      = 8;
     Abort   = ' Abort ';
     Retry   = ' Retry ';
     PrevWindow : Array [0..Height-2] of String[30] =
              (

               '                   ',
               ' ┌───────────────┐ ',
               ' │               │ ',
               ' │               │ ',
               ' │               │ ',
               ' │               │ ',
               ' │               │ ',
               ' └───────────────┘ ',
               '                   '
              );

     Window  : Array [0..Height] of String[40] =
              (

               '                                   ',
               ' ┌──────────── Error ────────────┐ ',
               ' │                               │ ',
               ' │                               │ ',
               ' │                               │ ',
               ' │                               │ ',
               ' │                               │ ',
               ' │                               │ ',
               ' │                               │ ',
               ' └───────────────────────────────┘ ',
               '                                   '
              );


Var
   ExtCode   : Word;
   I, J      : Byte;
   Sys24     : Procedure;  { Системный обработчик INT 24H }
   Buff      : BuffType;   { Видео буфер }
   SaveExit,
   VideoPtr  : Pointer;
   VideoMem  : Word;
   F         : File;
   Regs      : Registers;
   VideoPage,
   Columns   : Byte;

Function GetVideoMode : Byte;   { Возвращает параметры видео режима INT 10H }
Begin
     Regs.AH := $0F;
     Intr ( $10, Regs );
     GetVideoMode := Regs.AL;
     VideoPage := Regs.BH;
     Columns := Regs.AH;
End;

{$F+}  { Применять FAR тип вызовов подпрограмм }

Function GetErrorName : String; { Возвращает расширенную информацию об ошибке INT 21H }
Begin
     Regs.AH := $59;
     Regs.BX := 0;
     MsDos ( Regs );
     GetErrorName := ErrMsg[Lo(Regs.AX)];
End;

Function GetKey : Word;  { Читатет расширенный код клавиши }
Begin
     Regs.AH := 0;
     Intr ( $16, Regs );
     If Regs.AL = 0 then GetKey := Regs.AX
       else GetKey := Regs.AL;
End;

{  Собственно обработчик критических ошибок }
Procedure Int24 ( Flags,CS,IP,AX,BX,CX,DX,SI,DI,DS,ES,BP: Word); Interrupt;
   Var
      Mode     : Byte;
      Choice   : Byte;
      _X, _Y   : Byte;
      Msg      : String[20];
      SaveAttr : Byte;
      Select,
      Unselect : Byte;
Begin
     ErrorFlag := True;                   { Произошла ошибка }
     LastError := Int24ErrMsg[Lo(DI)];    { Имя ошибки }
     If ErrHandlerPtr <> NIL then begin   { Если существует пользовательский обработчик, вызвать его }
       ErrorHandler;
       If RetryFlag then AX := Hi(AX) Shl 8 + 1  { Retry }
         else AX := Hi(AX) Shl 8 + 3;     { Установить код выхода Abort }
       Exit;                              {  Выход }
     end;
     SaveAttr := TextAttr;
     Mode := GetVideoMode;                { Читать видео режим }
     Choice := 0;
     If Mode In TextModes then begin      { Проверка поддерживаемых режимов }
       DirectVideo := True;
       CheckSnow := False;
       _X := WhereX;
       _Y := WhereY;
       Select := ColorSelect;
       UnSelect := ColorUnSelect;
       If Mode  = 7 then begin           { Монохромный режим }
         VideoMem := $B000;
         Select := MonoLo;
         UnSelect := MonoHi;
       end
       else VideoMem := $B800;          { Цветной }
       VideoPtr := Ptr ( VideoMem, VideoPage*4000 ); { Вычисление адреса текущей страницы }
       Move ( VideoPtr^, Buff, 4000 );   {  Сохранение экрана в буфере }
       TextAttr := UnSelect;
       For I:=0 to Height-2 do begin
          GoToXY ( XL+8, YL+I+1 );
          Write ( PrevWindow [I] );      { Рисование  окна }
       end;
       Delay ( 50 );
       For I:=0 to Height do begin
          GoToXY ( XL, YL+I );
          Write ( Window [I] );          { Рисование еще одного окна }
       end;
       GoToXY ( XL+17-(Length(Int24ErrMsg[Lo(DI)]) Div 2), YL+3 );
       TextAttr := UnSelect;
       Write ( Int24ErrMsg[Lo(DI)] );    { Вывод сообщения об ошибке }
       Msg := 'Drive: ';
       If (AX AND $8000) = 0
         then Msg := Msg + Char(Byte('A')+Lo(AX)) + ':'
         else For I := $0A to $12 do Msg := Msg + Char(Mem[BP:SI+I]);
       GoToXY ( XL+17-(Length(Msg) Div 2), YL+5 );
       Write ( Msg );                    { Вывод ошибочного устройства }
       Mem [ $0000:$41C ] := Mem [ $0000:$41A ]; { Очистка буфера клавиатуры }
       If (Hi(AX) AND $10) = 0 then begin
         AX := Hi(AX) Shl 8 + 3;         { Ошибка безнадежная }
         GoToXY ( XL+17-(Length(Abort) Div 2), YL+7 );
         TextAttr := $1E;
         Write  ( Abort );
         GoToXY ( _X, _Y );
         Repeat
               ExtCode := GetKey;
         Until (ExtCode = 13) Or (ExtCode = 27); { Выход по Ener либо ESC }
       end
       else begin
           GoToXY ( XL+9, YL+7 );
           TextAttr := Select;
           Write  ( Abort );
           GoToXY ( XL+19, YL+7 );
           TextAttr := UnSelect;
           Write  ( Retry );
           GoToXY ( _X, _Y );
           Repeat                      { Учинить выбор между Abort и Retry }
                 ExtCode := GetKey;
                 Case ExtCode of
                      $4B00 : If Choice = 1 then Choice := 0
                                else Choice := 1;
                      $4D00 : If Choice = 0 then Choice := 1
                                else Choice := 0;
                 end;           { Стрелки для выбора }
                 If Choice = 0 then begin
                   GoToXY ( XL+9, YL+7 );
                   TextAttr := Select;
                   Write  ( Abort );
                   GoToXY ( XL+19, YL+7 );
                   TextAttr := UnSelect;
                   Write  ( Retry );
                   AX := Hi(AX) Shl 8 + 3;      { Abort }
                 end
                 else begin
                   GoToXY ( XL+9, YL+7 );
                   TextAttr := UnSelect;
                   Write  ( Abort );
                   GoToXY ( XL+19, YL+7 );
                   TextAttr := Select;
                   Write  ( Retry );
                   AX := Hi(AX) Shl 8 + 1;      { Retry }
                 end;
                 GoToXY ( _X, _Y );
           Until (ExtCode = 13) Or (ExtCode = 27);
           If ExtCode = 27 then AX := Hi(AX) Shl 8 + 3;
       end;
       Move ( Buff, VideoPtr^, 4000 ); { Восстановить экран }
       GoToXY ( _X, _Y );
       TextAttr := SaveAttr;
     end
     else begin
          AX := Hi(AX) Shl 8 + 3;
          Exit;
     end;
End;

Procedure ExitHandler;      { Обработчик внутренних ошибок утомления }
Begin
     ExitProc := SaveExit;  { Восстановить исходный обработчик }
     Halt( 0 );             { 0  -  заглушка }
End;

{$F-}

Begin                                  { Секция инициализации }
     SaveExit := ExitProc;             
     ExitProc := @ExitHandler;         { Установка обработчика внутренних ошибок }
     GetIntVec ( $24, @Sys24);         
     SetIntVec ( $24, Addr(Int24) );   { Установка INT 24H }
End.