
{************************************************}
{                                                }
{        L e c a r                               }
{   Turbo Pascal 5.X, 6.X                        }
{   Попросту, без чинов и Copyright-ов  1991     }
{    Версия 1.0 от 11.11.1991 14.00.45.55        }
{************************************************}

{$A+,B-,D+,F-,I-,O-,R-,L+}
{$M $1000, 0, $1000}   { 4K stack, 4K heap }

Unit MemVir;

{   Предназначен для обнаружения СДЯВ в памяти и дезактивации
    местности. Содержит имена вирусов, их маски в памяти и
    методы дезактивации. Дезактивация выполняется с помощью
    процедуры трассировки. Любители вирусов могут попробовать
    загнуть трассировщик, а заодно побороть очередь команд 80X86.
}

Interface

Const
     TotalVirusNames = 94;  { Увеличить при добавлении имени }

Type
    Virus_NameType = Array [0..TotalVirusNames] of String[20];
    { Имя СДЯВ содержит не более 20 - ти символов }

Const
     TestServers : Boolean = False;
     DOSSeg      : Word = $022B;
     DosSeg_30   : Word = $022B;
     DosOfs      : Word = $1460;
     BiosSeg     : Word = 0;
     BiosOfs     : Word = 0;         { Инициализация - на шару }
     Hacker_Flag : Boolean = False;  { По умолчанию не паясничать  }

     { Имена СДЯВ. Пронумерованные СДЯВ уже лечатся на диске,
      остальные только в памяти.
     }
     Virus_Name  : Virus_NameType =
                (
                  '',                { Не менять - заглушка под RELEASE }
{1}               'Stone RB512',XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
                  'Print Screen v0.1',
{3}               'Ping Pong RB512',XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
{4}               'Den Zuk',XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
                  'Brain',
                  'Joshi',
                  'Disk Killer',
                  'AidsKiller (AntiLoz)',XXXXXXXXXXXXXXXXXXXXXXXXX
{9}               '512 (666 Virus)',XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
                  'Jerusalem v.B',
{11}              'Sunday',
                  'Peterburg',
{13}              'Letter 1701/1704',XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
                  'Dark Avenger',
{15}              'Murphy',XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
{16}              'Flip RC2343',
{17}              'Attention',XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
{18}              '417 Fuck You',XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
{19}              '707 Zamorochka',XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
                  'Hymn ++ RCE2144',
                  '2048/2560 Magnum',
                  'TP4,5,6,10 (Vacsina)',
                  'TP24,25 (Y. Doodle)',
                  'TP33,34 (Y.Doodle)',
                  'TP-38-45 (Y.Doodle)',
                  'Eddie V2000',
{27}              'Tumen-1.0',XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
{28}              'Tumen-2.0',XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
                  '4096 100 Year',
                  'Voroneg-2',
{31}              'LoveChild',XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
                  '905 Virus',
                  'SurivA (1st April-A)',
                  'SurivB (1st April-B)',
                  'Alabama ',
{36}              'Yankee Shot E1961',XXXXXXXXXXXXXXXXXXXXXXXXXXXX
                  'Mirror - A',
                  'Yankee - 1049',
                  'Jmp in Jmp',
                  'Mega RC1193',
                  'Something RC658',
{42}              'Tiny RC144',XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
                  'Words 4',
                  'Words 3',
                  'Words 1-2',
                  'Words 1',
                  'Words 2',
                  'TP4 (Vacsina)',
                  'TP5 (Vacsina)',
                  'TP10 (Vacsina)',
                  'TP24 (Y.Doodle)',
                  'TP25 (Y.Doodle)',
                  'TP33 (Y.Doodle)',
                  'TP34 (Y.Doodle)',
                  'TP38 (Y.Doodle)',
                  'TP39 (Y.Doodle)',
                  'TP41 (Y.Doodle)',
                  'TP44 (Y.Doodle)',
                  'TP45 (Y.Doodle)',
                  'TP46 (Y.Doodle)',
                  'TP48 (Y.Doodle)',
                  '2048 Magnum-1',
                  '2560 Magnum-2',
{64}              'RC506 Hero',XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
                  'Incom C648 Я.Цурин',XXXXXXXXXXXXXXXXXXXXXXXXXXX
                  'Time Bomb C648 v.A',XXXXXXXXXXXXXXXXXXXXXXXXXXX
{67}              'Kiev 90',XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
{68}              'LenInfo',XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
{69}              'TothLess C534',XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
{70}              'Harkov REXXXX',
{71}              'Time Bomb C644',XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
{72}              'BEBE C1016',
{73}              'Kemerovo C257',XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
{74}              'Tumen-1.2',XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
{75}              'Time Bomb C623',XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
{76}              'Joker 0.1',XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
{77}              'Si RC492',XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
{78}              'C377',XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
{79}              'Export of Sex',XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
{80}              'C713 им.Фомы',XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
{81}              'Softpanorama RCE1864',XXXXXXXXXXXXXXXXXXXXXXXXX
{82}              'ХРЕН-4 RCE4928',XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
{83}              'Crazy Imp RCE1445',XXXXXXXXXXXXXXXXXXXXXXXXXXXX
{84}              'Hercen RBSE2048',
{85}              'Tiny RC145',
{86}              'Rostov RB512', XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
{87}              'Misspeller RB1024',XXXXXXXXXXXXXXXXXXXXXXXXXXXX
{88}              'RC763',XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
{89}              'BCV RCE5287',XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
{90}              'Flip modified',
{91}              'Jews-2 RCE2370',XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
{92}              'March6 RB512',XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
{93}              'RC800',
{94}              'Phoenix RC1704'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
                );

  { Смотри  }

Function TestMemoryOnViruses : Boolean;
Procedure GetVector ( Vect : Byte; Var Ptr : Pointer );
Procedure SetVector ( Vect : Byte; Ptr : Pointer );
Function HexWord(W : Word) : String;

Implementation

Uses
    Crt,Dos;    { Для работы с INTR, MSDOS, REGISTERS }

Type
    { Структура под войну со СДЯВами в  памяти.
      Трассировщик во время странствий по интерраптам,
      ищет байты из поля Memo со смещением из поля Offs для
      каждого байта соответственно. Если находит, затирает
      с текущего места 5 байтами из поля Kill, т.к. считает,
      что нашел вирус с номером из поля Name
    }
    HandleType = Record
                   Memo : Array [0..3] of Byte;  { коды }
                   Offs : Array [0..3] of Byte;  { смещения }
                   Name : Word;    { номер имени в Virus_Name }
                   Kill : Array [0..5] of Byte;  { чем убивать }
                 End;

    { Для передачи данных трассировщику }
    HandleArray = Array [1..100] of HandleType;
    HandleTypePtr = ^HandleArray;

Const
     { Max_13 и Max_21 показывают сколько СДЯВов надо искать
       во время трассировки 13-го и 21-го соответственно }
     Max_13 = 9;
     Max_21 = 51;

     Trace_13 : Boolean = False;
     { Данные по СДЯВам для 13-го }
     Handle_13 : Array [1..Max_13] of HandleType =
             (
              (
                Memo : ($1E,$C0,$8E,$D8);
                Offs : ($00,$11,$12,$13);
                Name : 1;
                Kill : ($2E,$FF,$2E,$09,$00,$54)
              ),
              (
                Memo : ($1E,$0E,$1F,$80);
                Offs : ($00,$01,$02,$03);
                Name : 2;
                Kill : ($CD,$6D,$CF,$54,$75,$72)
              ),
              (
                Memo : ($1E,$06,$50,$53);
                Offs : ($00,$01,$02,$03);
                Name : 3;
                Kill : ($2E,$FF,$2E,$2A,$7D,$54)
              ),
              (
                Memo : ($EB,$0A,$9C,$06);
                Offs : ($00,$01,$0C,$0D);
                Name : 4;
                Kill : ($CD,$6F,$CF,$54,$75,$72)
              ),
              (
                Memo : ($02,$75,$18,$80);
                Offs : ($03,$04,$05,$06);
                Name : 5;
                Kill : ($CD,$6D,$CF,$54,$75,$72)
              ),
              (
                Memo : ($FF,$FF,$FF,$FF);
                Offs : ($00,$01,$02,$03);
                Name : 7;
                Kill : ($2E,$FF,$2E,$09,$00,$FF)
              ),
              (
                Memo : ($80,$F9,$01,$75);
                Offs : ($00,$01,$02,$03);
                Name : 8;
                Kill : ($EB,$E7,$54,$75,$72,$6D)
              ),
              (
                Memo : ($1E,$80,$72,$17);
                Offs : ($01,$02,$05,$06);
                Name : 79;
                Kill : ($2E,$FF,$2E,$09,$00,$6D)
              ),
              (
                Memo : ($1E,$50,$0A,$00);
                Offs : ($00,$01,$17,$18);
                Name : 92;
                Kill : ($2E,$FF,$2E,$0A,$00,$72)
              )
             );

     { Данные по СДЯВам для 21-го }
     Handle_21 : Array [1..Max_21] of HandleType =
             (
              (
                Memo : ($06,$3F,$74,$B0); {512A}
                Offs : ($00,$08,$09,$0A);
                Name : 9;
                Kill : ($2E,$FF,$2E,$04,$00,$54)
              ),
              (
                Memo : ($55,$BF,$17,$01); {512 B, C, D}
                Offs : ($00,$0A,$0B,$0C);
                Name : 9;
                Kill : ($2E,$FF,$2E,$04,$00,$54)
              ),
              (
                Memo : ($3F,$80,$FC,$3E); {512 E, F}
                Offs : ($02,$0D,$0E,$0F);
                Name : 9;
                Kill : ($2E,$FF,$2E,$04,$00,$54)
              ),
              (
                Memo : ($9C,$80,$FC,$E0);
                Offs : ($00,$01,$02,$03);
                Name : 10;
                Kill : ($2E,$FF,$2E,$17,$00,$54)
              ),
              (
                Memo : ($FF,$05,$04,$DD);
                Offs : ($03,$05,$08,$0D);
                Name : 11;
                Kill : ($2E,$FF,$2E,$17,$00,$75)
              ),
              (
                Memo : ($36,$01,$19,$1E);
                Offs : ($02,$04,$0A,$0D);
                Name : 12;
                Kill : ($2E,$FF,$2E,$FD,$02,$54)
              ),
              (
                Memo : ($80,$FC,$4B,$10);
                Offs : ($00,$01,$02,$04);
                Name : 13;
                Kill : ($2E,$FF,$2E,$37,$01,$54)
              ),
              (
                Memo : ($55,$8B,$EC,$28);
                Offs : ($00,$01,$02,$0A);
                Name : 14;
                Kill : ($2E,$FF,$2E,$4F,$07,$54)
              ),
              (
                Memo : ($E8,$80,$FC,$74);
                Offs : ($00,$11,$12,$14);
                Name : 15;
                Kill : ($2E,$FF,$2E,$29,$01,$54)
              ),
              (
                Memo : ($75,$0A,$C0,$24);
                Offs : ($04,$06,$07,$09);
                Name : 16;
                Kill : ($2E,$FF,$2E,$DF,$00,$54)
              ),
              (
                Memo : ($90,$4B,$3D,$00);
                Offs : ($00,$03,$06,$07);
                Name : 8;
                Kill : ($E9,$8E,$02,$54,$75,$6D)
              ),
              (
                Memo : ($52,$06,$FC,$4B);
                Offs : ($03,$07,$09,$0A);
                Name : 17;
                Kill : ($2E,$FF,$2E,$15,$00,$54)
              ),
              (
                Memo : ($50,$03,$9B,$00);
                Offs : ($00,$05,$07,$08);
                Name : 18;
                Kill : ($50,$E9,$A0,$00,$54,$75)
              ),
              (
                Memo : ($B7,$3A,$74,$EA);
                Offs : ($01,$03,$05,$08);
                Name : 19;
                Kill : ($EB,$06,$54,$75,$72,$6D)
              ),
              (
                Memo : ($EC,$FF,$9D,$5D);
                Offs : ($02,$03,$06,$07);
                Name : 20;
                Kill : ($2E,$3A,$26,$FF,$0D,$77)
              ),
              (
                Memo : ($06,$00,$FA,$1E);
                Offs : ($02,$05,$06,$08);
                Name : 21;
                Kill : ($2E,$FF,$2E,$54,$01,$54)
              ),
              (
                Memo : ($9C,$00,$06,$9D);
                Offs : ($00,$02,$05,$06);
                Name : 22;
                Kill : ($2E,$FF,$2E,$00,$00,$54)
              ),
              (
                Memo : ($9C,$00,$61,$3D);
                Offs : ($00,$02,$05,$06);
                Name : 23;
                Kill : ($2E,$FF,$2E,$10,$00,$54)
              ),
              (
                Memo : ($9C,$00,$5F,$3D);
                Offs : ($00,$02,$05,$06);
                Name : 24;
                Kill : ($E9,$7E,$02,$54,$75,$72)
              ),
              (
                Memo : ($80,$23,$C5,$80);
                Offs : ($01,$05,$08,$06);
                Name : 25;
                Kill : ($2E,$FF,$2E,$2A,$00,$54)
              ),
              (
                Memo : ($8B,$FF,$9D,$AF);
                Offs : ($01,$03,$06,$0A);
                Name : 26;
                Kill : ($2E,$FF,$2E,$18,$08,$54)
              ),
              (
                Memo : ($EB,$FD,$FC,$FD);
                Offs : ($01,$02,$04,$05);
                Name : 27;
                Kill : ($2E,$FF,$2E,$3C,$04,$54)
              ),
              (
                Memo : ($80,$FF,$10,$E8);
                Offs : ($00,$02,$0C,$0D);
                Name : 28;
                Kill : ($2E,$FF,$2E,$B0,$00,$54)
              ),
              (
                Memo : ($55,$12,$E8,$08);
                Offs : ($00,$0A,$0F,$10);
                Name : 29;
                Kill : ($EA,$00,$00,$00,$00,$54)
              ),
              (
                Memo : ($9C,$80,$AB,$3D);
                Offs : ($00,$02,$04,$0C);
                Name : 30;
                Kill : ($2E,$FF,$2E,$C2,$01,$54)
              ),
              (
                Memo : ($EA,$CD,$02,$00);
                Offs : ($00,$01,$02,$04);
                Name : 31;
                Kill : ($2E,$3A,$26,$FF,$0D,$77)
              ),
              (
                Memo : ($FB,$3D,$FA,$F1);
                Offs : ($00,$02,$08,$09);
                Name : 32;
                Kill : ($2E,$FF,$2E,$93,$03,$54)
              ),
              (
                Memo : ($DD,$0B,$26,$2E);
                Offs : ($03,$05,$0A,$0C);
                Name : 33;
                Kill : ($2E,$FF,$2E,$26,$01,$54)
              ),
              (
                Memo : ($DE,$75,$03,$31);
                Offs : ($03,$09,$0A,$0C);
                Name : 34;
                Kill : ($2E,$FF,$2E,$0F,$00,$54)
              ),
              (
                Memo : ($FC,$3C,$08,$FF);
                Offs : ($01,$04,$09,$11);
                Name : 35;
                Kill : ($EB,$3F,$54,$75,$05,$54)
              ),
              (
                Memo : ($FC,$14,$F0,$06);
                Offs : ($02,$0A,$0D,$0F);
                Name : 0;
                Kill : ($9C,$80,$FC,$4B,$74,$14)
              ),
              (
                Memo : ($65,$00,$E8,$03);
                Offs : ($03,$04,$0C,$0D);
                Name : 36;
                Kill : ($2E,$FF,$2E,$B9,$01,$54)
              ),
              (
                Memo : ($93,$93,$BE,$74);
                Offs : ($01,$06,$0B,$0C);
                Name : 37;
                Kill : ($9C,$EB,$0B,$54,$75,$72)
              ),
              (
                Memo : ($4B,$52,$26,$80);
                Offs : ($02,$06,$09,$0A);
                Name : 38;
                Kill : ($2E,$FF,$2E,$0C,$00,$54)
              ),
              (
                Memo : ($FC,$03,$CD,$AB);
                Offs : ($01,$04,$0D,$0E);
                Name : 39;
                Kill : ($2E,$FF,$2E,$7F,$02,$54)
              ),
              (
                Memo : ($00,$09,$B0,$03);
                Offs : ($02,$05,$0C,$0D);
                Name : 40;
                Kill : ($2E,$FF,$2E,$77,$03,$54)
              ),
              (
                Memo : ($80,$02,$CD,$B4);
                Offs : ($02,$08,$0A,$0B);
                Name : 41;
                Kill : ($2E,$FF,$2E,$90,$00,$54)
              ),
              (
                Memo : ($40,$03,$EB,$01);
                Offs : ($03,$0A,$0C,$0D);
                Name : 42;
                Kill : ($2E,$FF,$2E,$5D,$00,$54)
              ),
              (
                Memo : ($3D,$03,$D6,$01);
                Offs : ($01,$05,$07,$08);
                Name : 43;
                Kill : ($2E,$FF,$2E,$41,$00,$54)
              ),
              (
                Memo : ($3D,$03,$80,$40);
                Offs : ($01,$05,$09,$0B);
                Name : 44;
                Kill : ($2E,$FF,$2E,$0D,$00,$54)
              ),
              (
                Memo : ($75,$05,$C0,$CF);
                Offs : ($03,$04,$08,$09);
                Name : 64;
                Kill : ($EB,$28,$54,$75,$72,$6D)
              ),
              (
                Memo : ($FA,$3E,$05,$00);
                Offs : ($00,$03,$07,$08);
                Name : 70;
                Kill : ($EB,$07,$54,$75,$72,$6D)
              ),
              (
                Memo : ($80,$FF,$14,$50);
                Offs : ($00,$02,$0C,$0D);
                Name : 74;
                Kill : ($2E,$FF,$2E,$25,$00,$54)
              ),
              (
                Memo : ($CD,$62,$CD,$62);
                Offs : ($00,$01,$00,$01);
                Name : 81; { SoftPanorama }
                Kill : ($2E,$3A,$26,$FF,$0D,$77)
              ),
              (
                Memo : ($F3,$C1,$28,$80);
                Offs : ($02,$03,$05,$06);
                Name : 82; { FastOpen RCE4928 }
                Kill : ($2E,$FF,$2E,$2F,$00,$54)
              ),
              (
                Memo : ($80,$3E,$75,$2F);
                Offs : ($01,$02,$06,$07);
                Name : 83; { Crazy Imp. v 2.0 }
                Kill : ($2E,$FF,$2E,$DA,$06,$54)
              ),
              (
                Memo : ($FA,$56,$3D,$00);
                Offs : ($00,$01,$0A,$0B);
                Name : 84; { Hercen RE2509 }
                Kill : ($E9,$E0,$01,$54,$54,$54)
              ),
              (
                Memo : ($FC,$75,$3C,$CC);
                Offs : ($01,$03,$05,$06);
                Name : 85; { Tiny RC145 }
                Kill : ($EB,$5C,$54,$54,$54,$54)
              ),
              (
                Memo : ($FC,$3D,$74,$05);
                Offs : ($01,$02,$03,$04);
                Name : 88; { RC763 88 }
                Kill : ($EB,$0B,$54,$54,$54,$54)
              ),
              (
                Memo : ($50,$53,$EC,$14);
                Offs : ($00,$01,$0C,$0D);
                Name : 89; { BCV RCE5287 }
                Kill : ($E9,$69,$F6,$54,$54,$54)
              ),
              (
                Memo : ($3D,$DA,$FE,$0A);
                Offs : ($01,$02,$03,$05);
                Name : 91; { Feda }
                Kill : ($EB,$6F,$90,$90,$90,$90)
              )
             );
Var
   SaveInt1        : Pointer;
   Already         : Boolean;
   Regs            : Registers;
   Counter         : Longint;
   I, J            : Byte;
   Present         : Boolean;
   Viruses         : Boolean;
   Keep_CS         : Word;

Procedure DisableInterrupt; Inline( $FA );     { CLI }
Procedure EnableInterrupt; Inline( $FB );     { STI }

Procedure ClearTrapFlag;              { Сбросить флаг трассировки }
     Inline (
              $9C/                    { PUSHF            }
              $58/                    { POP  AX          }
              $25/>$FEFF/             { AND  AX, 0FEFFH  }
              $50/                    { PUSH AX          }
              $9D                     { POPF             }
            );

Procedure SetTrapFlag;                { Установить флаг трассировки }
     Inline (
              $9C/                    { PUSHF            }
              $5B/                    { POP  BX          }
              $81/<$CB/>$0100/        { OR   BX, 0100H   }
              $53/                    { PUSH BX          }
              $9D                     { POPF             }
            );

{ Некоторые СДЯВ подсовывают адрес, сидя на INT 21H, поэтому Lecar не доверяет ДОСу }

Procedure SetVector( Vect : Byte; Ptr : Pointer );
   Begin
        DisableInterrupt;
        MemL[0000:Vect*4] := Longint(Ptr);
        EnableInterrupt;
   End;

Procedure GetVector ( Vect : Byte; Var Ptr : Pointer );
   Begin
        DisableInterrupt;
        Ptr := Pointer (MemL[0000:Vect*4]);
        EnableInterrupt;
   End;

Function HexWord(W : Word) : String; { Вывод слова в HEX формате }
   Const
        HexChars : array [0..$F] of Char = '0123456789ABCDEF';
   Begin
        HexWord := '';
        HexWord := HexChars[Hi(w) shr 4] + HexChars[Hi(w) and $F] +
                   HexChars[Lo(w) shr 4] + HexChars[Lo(w) and $F];
   End;

{$F+}

{ Обработчик INT 01H, должен иметь дальний тип вызовов }

Procedure Int1 (Flags,CS,IP,AX,BX,CX,DX,SI,DI,DS,ES,BP : Word);Interrupt;

{ ВПХР для обнаружения СДЯВ }

Procedure TestViruses ( Max : Byte; Handle : HandleTypePtr );
   Begin
        DisableInterrupt;
        For I:=1 to Max do begin      { Поиск маски по всем округам }
           Present := True;           { Пусть найдена }
           J := 0;
           Repeat
                 If Mem [CS:IP+Handle^[I].Offs[J]] <> Handle^[I].Memo[J]
                   then Present := False; { Хотя бы один несовпадающий байт }
                 Inc (J);
           Until (NOT Present) OR (J>3);
           If ( Handle^[I].Name = 0 ) AND ( Hacker_Flag ) AND Present
              then begin              { Найден RELEASE }
                   WriteLn(#13,' Обнаружена  и не убита программа Release...');
                   WriteLn(' Не вирус конечно, но очень, очень похож !!!!');
                   WriteLn;           { Все хотят быть похожими на куклу Синди }
              end;
           If Handle^[I].Name = 0 then Present := False; { RELEASE не убивать }
           If Present then begin      { А вот с вами мы поговорим подробнее }
             Write('По адресу ',
                      HexWord (CS), ':', HexWord (IP) ); { Место дислокации СДЯВ }
             { Особо опасные СДЯВы. Вооружены и очень опасны }
{    TP  Int 1C     }
             If (((Handle^[I].Name <= 25) AND (Handle^[I].Name >= 22)) OR
                  (Handle^[I].Name = 83) )
               then Mem[MemW[0:$72]:MemW[0:$70]] := $CF; { Вставить IRET }
             { Подрезать хвост серии TP и Crazy Imp. }
{    4096           }
             If Handle^[I].Name = 29
                then begin
                    For J:=1 to 4 do Handle^[I].Kill[J]:=Mem[CS:$1234+J];
                    For J:=0 to 4 do
                       Mem[MemW[CS:$1235+2]:MemW[CS:$1235]+J]:=Mem[CS:$124B+J];
                       { Вытащить на свет божий начало обработчика ДОС }
                end;
{    Hymn           }
             If Handle^[I].Name = 20 then begin
                      Move ( Handle^[I].Kill, Ptr(DosSeg,$1460)^, 5 );
                      Handle^[I].Kill[0] := $EA;        { JMP FAR }
                      Handle^[I].Kill[1] := Lo(DosOfs);
                      Handle^[I].Kill[2] := Hi(DosOfs);
                      Handle^[I].Kill[3] := Lo(DosSeg);
                      Handle^[I].Kill[4] := Hi(DosSeg);
             { Срезать всех с INT 21H ( Hymn выше MS DOS 3.30 не жилец ) }
             end;
             { Все остальные погибают бесславно }
             For J:=0 to 5 do Mem [CS:IP+J] := Handle^[I].Kill[J];
             WriteLn(' застигнут врасплох вирус ', Virus_Name[Handle^[I].Name]);
             Viruses := True;    { Кто то не успел вовремя пригнутся }
           end;
        end;
        EnableInterrupt;
   End;

   Begin
        If CS = Keep_CS then Exit;    { Если CS не изменился, ничего не делать }
        If Already then begin
           Flags := Flags AND $FEFF;
           Exit;                      { Если уже все кончено, ускорить процесс }
        end;
        If Trace_13 then
          If CS > $C000 then begin    { Трассировать выше 0C0000 }
             Already := True;         { Дошли до цели }
             BiosOfs := IP;           { INT 13H  вещь нужная }
             BiosSeg := CS;           { Пригодится в хозяйстве }
          end;
        If Not Trace_13 then
          If CS = DosSeg then begin
             Already := True;
             DosOfs  := IP;           { INT 21H тоже пригодится }
           end;
        If Trace_13
          then TestViruses ( Max_13, @Handle_13 )  { Проверить INT 13H }
          else TestViruses ( Max_21, @Handle_21 ); { Проверить INT 21H }
        Keep_CS := CS;                { Запомнить CS }
        Flags := Flags OR $0100;      { Возвести флаг трассировки на случай добрых людей }
   End;
{$F-}

Function TestMemoryOnViruses;         { Проверяет память на наличие СДЯВ }
   Begin
        TestMemoryOnViruses := False;
        Viruses := False;
        Keep_CS := 0;
        Already := False;
        Regs.AX := $1203;                { Get DOS Segment }
        Intr ( $2F, Regs );
        DosSeg := Regs.DS;
        DosSeg_30 := MemW[0000:$30*4+3];
        If DosSeg <> DosSeg_30 then begin
          If Hacker_Flag then WriteLn(' не могу нормально вычислить DOS segment');
          TestServers := True;
        end;

        If (Mem [ MemW[0000:$2A*4+2]:MemW[0000:$2A*4] ] = $56) AND
           (Mem [ MemW[0000:$2A*4+2]:MemW[0000:$2A*4]+$A ] = $75) then begin
              Write (' Обнаружен вирус Phoenix RCXXXX  - ату его ... ');
                Mem [ MemW[0000:$2A*4+2]:MemW[0000:$2A*4] ] := $CF;
                { Отобрать INT 2AH из нечестивых рук }
                For I := 1 to 20 do
                  Mem [ MemW[0000:$2A*4+2]:MemW[0000:$2A*4] +I] := $0;
              Sound(50); WriteLn ('готов!!!'); NoSound; Delay(55);
        end;

        If (Not TestServers) AND (MemW [000:$2A*4+2] <> DosSeg) AND
           (Mem [ MemW[0000:$2A*4+2]:MemW[0000:$2A*4] ] <> $CF) then begin
             WriteLn (' Многозадачка или сеть тут у Вас??, советую использовать /d ');
             If Hacker_Flag then WriteLn (' Кстати, VM386 - неплохая штука, пробовали ?');
        end;

        GetVector ( $1, SaveInt1 );
        SetVector ( $1, Addr(Int1) );    { Установить обработчик пошагового выполнения }
        SetTrapFlag;                     { Начать трассировку }
        Regs.AH := $30;                  { Get DOS Version }
        MsDos ( Regs );
        ClearTrapFlag;                   { Закончить трассировку (на всякий случай ) }
        Already := False;
        Trace_13 := True;                { Трассировать INT 13H }
        SetTrapFlag;                     { Начать трассировку }
        Regs.AH := $00;                  { Reset Disk system }
        Regs.DL := $0;
        Intr( $13, Regs );
        ClearTrapFlag;                   { Закончить трассировку }
        SetVector ( $1, SaveInt1 );      { Восстановить INT 01H }
        If Viruses then TestMemoryOnViruses := True;
        { Если обнаружен СДЯВ, пожаловаться главному }
   End;
End.