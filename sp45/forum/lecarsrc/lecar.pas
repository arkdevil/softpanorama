
{************************************************}
{                                                }
{        L e c a r                               }
{   Turbo Pascal 5.X, 6.X                        }
{   Попросту, без чинов и Copyright-ов  1991     }
{    Версия 1.0 от 11.11.1991 14.00.45.55        }
{   перед употреблением - PkLiiteить             }
{************************************************}

{
 К сожалению, не можем похвастаться очень сильной
 раскомментированостью, поэтому доп. вопросы выяснять
 по FIDO 2:463/34 -  Mikrob Point - (044) 224-7070
 voice phone (044) 449-9767  до и после 11.0
}

{$A+,B-,D+,F-,I-,O-,R-,L+,S-}
{$M $4000, 0, $4000}   { 16K stack, 16K heap }

Uses
    Crt,
    Compress, { Для раскрутки LZEXE }
    MemVir,   { Для поиска СДЯВов в памяти }
    ErrHand,  { Для обработки критических ошибок, можно отключить }
    DiskTest, { Для поиска Boot-СДЯВов }
    Dos;      { Для работы с Intr, Registers }

Type
    SRecPtr    = ^SearchRec;
    { Структура под борьбу со СДЯВами в файле. Во время поиска по
      файлам Lecar ищет байты из поля Maska со смещением из поля
      Offs соответственно, если находит, то считает, что найден СДЯВ
      с именем из поля Name  типа VType и лечить его надо в соответствии
      с данными по номеру VInd для COM-файлов и номером VIndEXE для
      EXE-файлов.
      Значения полей :
      Name    : номер имени вируса в Virus_Names
      Maska   : байты маски
      Offs    : байты смещения
      VType   : тип СДЯВа
      VInd    : тип для COM
      VIndEXE : тип для EXE
    }
    HandleType = Record
                   Name    : Word;
                   Maska   : Array [0..3] of Byte;
                   Offs    : Array [0..3] of Word;
                   VType   : VirusType;
                   VInd    : Byte;
                   VIndEXE : Byte;
                 End;
    {Указатель на этот тип для передачи параметров}
    HandleTypePtr = ^HandleType;

    { Структура для убивания СДЯВов в файлах для СДЯВов типа COM1.
      Значение полей :
      OffsJmp : Смещение в файле до слова перехода(для СДЯВов,
                начинающихся с JMP, OffsJmp = 1)
      Offs    : Смещение от текущей позиции(после перехода) до
                исходных байт программы
      Count   : Количество исходных байт
    }
    COM1FagType= Record
                   OffsJmp : Byte;
                   Offs    : Integer;
                   Count   : Byte;
                 End;

    { Структура для убивания СДЯВов в файлах для СДЯВов типа COM2.
      Значение полей :
      OffsTrue: Смещение от конца файла до исходных байт
      OffsTrun: Смещение от конца файла до места, откуда отрезать
      Count   : Количество исходных байт
    }

    COM2FagType= Record
                   OffsTrue: Word;
                   OffsTrun: Word;
                   Count   : Byte;
                 End;

    { Структура для убивания СДЯВов в файлах для СДЯВов типа EXE1.
      Значение полей :
      VName    : Номер имени СДЯВа
      OffsEntr : Смещение до исходной точки входа
      OffsStack: Смещение до исходного размера стэка
      Imagelen : На сколько надо уменьшить размер образа
    }
    EXE1FagType= Record
                   VName    : Word;
                   OffsEntr : Word;
                   OffsStack: Word;
                   Imagelen : Word;
                 End;
{ Структура под сообщения о днях рождения.
  Значения полей комментариям не подлежат
}
    MonthT =(January, February, March, April, May, June, Jyle,
              August, September, October, November, December);
    BirthdayT= Record
                 Month : MonthT;
                 Day   : Byte;
                 Year  : Word;
               End;
    GoodProgT= record
                 Ident : String[12];
                 Say   : String[50];
               end;

Const
     TestAll       : Boolean = False;  { Инициализация параметров,}
     TestServers   : Boolean = False;  {задаваемых в командной строке }
     Help          : Boolean = False;
     LzFlag        : Boolean = False;
     LzTmp         : Boolean = False;
     AllDrive      : Boolean = False;
     EraseUnLz     : Boolean = True;
     StrongMan     : Boolean = False;
     LzPath        : PathStr = '';
     Tmp_Flag      : Boolean = True;

     TotalFiles    : Longint = 0;      { Инициализация переменных }
     TotalInfected : Longint = 0;
     CurrentDrive  : Byte = 0;

{ Общие данные }
     AllViruses    = '58'; {всего вирусов лечится}
     Version       = '1.07';
     Owner         = 'киевским сисопам';
     CreatDate     = '27 Apr 1992';

{ Константы, задающие общий размер данных }
     Max_COM_Begin = 14;
     Max_EXE_Us    = 31;
     Max_COM1      = 24;
     Max_COM2      = 1;
     Max_Other     = 1;
     Max_EXE1      = 2;
     Max_Birthdays = 8;
     Max_GoodProg  = 23;

{Данные под СДЯВы, живущие в начале файлов}
     COM_Begin     : Array [1..Max_COM_Begin] of HandleType =
                  (
                   (
                      Name    : 9;  { 512 A, B, F, X }
                      Maska   : ($00,$01,$F3,$A7);
                      Offs    : ($35,$36,$37,$38);
                      VType   : Other;
                      VInd    : 1;
                      VIndEXE : 0
                    ),
                   (
                      Name    : 9;  { 512 C }
                      Maska   : ($54,$08,$13,$CD);
                      Offs    : ($08,$09,$0B,$0C);
                      VType   : Other;
                      VInd    : 1;
                      VIndEXE : 0
                    ),
                   (
                      Name    : 9;  { 512 D }
                      Maska   : ($54,$08,$13,$CD);
                      Offs    : ($06,$07,$09,$0A);
                      VType   : Other;
                      VInd    : 1;
                      VIndEXE : 0
                    ),
                   (
                      Name    : 9;  { 512 E }
                      Maska   : ($54,$08,$13,$CD);
                      Offs    : ($0C,$0D,$0F,$10);
                      VType   : Other;
                      VInd    : 1;
                      VIndEXE : 0
                    ),
                   (
                      Name    : 65;  { Incom C648 }
                      Maska   : ($BA,$02,$01,$E9);
                      Offs    : ($00,$01,$02,$03);
                      VType   : COM1;
                      VInd    : 12;
                      VIndEXE : 0
                    ),
                   (
                      Name    : 71;  { Time Bomb C644 }
                      Maska   : ($0E,$1F,$E8,$C3);
                      Offs    : ($00,$01,$02,$05);
                      VType   : COM1;
                      VInd    : 10;
                      VIndEXE : 0
                    ),
                   (
                      Name    : 72;  { Bebe 1016 }
                      Maska   : ($50,$C8,$01,$06);
                      Offs    : ($00,$03,$05,$06);
                      VType   : COM2;
                      VInd    : 1;
                      VIndEXE : 0
                    ),
                   (
                      Name    : 73;  { Kemerovo C257 }
                      Maska   : ($92,$E8,$92,$E8);
                      Offs    : ($00,$01,$00,$01);
                      VType   : COM1;
                      VInd    : 17;
                      VIndEXE : 0
                    ),
                   (
                      Name    : 31;  { Lovechild }
                      Maska   : ($FB,$E9,$FB,$E9);
                      Offs    : ($00,$01,$00,$01);
                      VType   : COM1;
                      VInd    : 18;
                      VIndEXE : 0
                    ),
                   (
                      Name    : 9;  { 512 }
                      Maska   : ($FF,$01,$F3,$A6);
                      Offs    : ($2A,$2B,$2C,$2D);
                      VType   : Other;
                      VInd    : 1;
                      VIndEXE : 0
                    ),
                   (
                      Name    : 80;  { 512 }
                      Maska   : ($B8,$F0,$FF,$E9);
                      Offs    : ($00,$01,$02,$03);
                      VType   : COM1;
                      VInd    : 23;
                      VIndEXE : 0
                    ),
                   (
                      Name    : 83;  { Crazy Imp v2.0 }
                      Maska   : ($0E,$E8,$27,$27);
                      Offs    : ($00,$01,$05,$06);
                      VType   : Other;
                      VInd    : 0;
                      VIndEXE : 0
                    ),
                   (
                      Name    : 85;  { Tiny RC145 }
                      Maska   : ($FC,$B9,$B8,$BE);
                      Offs    : ($0A,$01,$04,$07);
                      VType   : Other;
                      VInd    : 0;
                      VIndEXE : 0
                    ),
                   (
                      Name    : 88;  { RC763 }
                      Maska   : ($BB,$FF,$FF,$E3);
                      Offs    : ($00,$03,$03,$04);
                      VType   : Other;
                      VInd    : 0;
                      VIndEXE : 0
                    )
                   );

{
 Данные под СДЯВы, за которыми надо идти по точке входа или по
 начальному JMPу, если после этого будет JMP до по нему пройдемся тоже
}
     EXE_Vir       : Array [1..Max_EXE_Us] of HandleType =
                  (
                   (
                      Name    : 15;  { Murphy }
                      Maska   : ($1E,$4B,$E9,$01);
                      Offs    : ($00,$06,$0B,$0D);
                      VType   : COM1;
                      VInd    : 1;
                      VIndEXE : 2
                    ),
                   (
                      Name    : 13;  { Letter Fall }
                      Maska   : ($BC,$34,$06,$31);
                      Offs    : ($17,$1B,$19,$1A);
                      VType   : COM1;
                      VInd    : 15;
                      VIndEXE : 0
                    ),
                   (
                      Name    : 8;   { AidsKiller }
                      Maska   : ($2E,$8A,$44,$FC);
                      Offs    : ($10,$11,$12,$13);
                      VType   : COM1;
                      VInd    : 16;
                      VIndEXE : 0

                    ),
                   (
                      Name    : 64;  { Hero - 506 }
                      Maska   : ($81,$2E,$85,$02);
                      Offs    : ($03,$09,$0C,$0D);
                      VType   : COM1;
                      VInd    : 2;
                      VIndEXE : 0
                    ),
                   (
                      Name    : 18;  { 417 Fuck You }
                      Maska   : ($CD,$12,$06,$1E);
                      Offs    : ($04,$05,$14,$15);
                      VType   : COM1;
                      VInd    : 3;
                      VIndEXE : 0
                    ),
                   (
                      Name    : 17;  { Attention }
                      Maska   : ($79,$01,$02,$00);
                      Offs    : ($07,$08,$0A,$0B);
                      VType   : COM1;
                      VInd    : 4;
                      VIndEXE : 0
                    ),
                   (
                      Name    : 42;  { Tiny RC144 }
                      Maska   : ($60,$00,$C6,$31);
                      Offs    : ($00,$04,$08,$09);
                      VType   : COM1;
                      VInd    : 5;
                      VIndEXE : 0
                    ),
                   (
                      Name    : 66;  { C648 v.A }
                      Maska   : ($BA,$FC,$8B,$03);
                      Offs    : ($01,$04,$05,$0F);
                      VType   : COM1;
                      VInd    : 6;
                      VIndEXE : 0
                    ),
                   (
                      Name    : 67;  { Kiev 90 }
                      Maska   : ($8B,$E9,$8B,$87);
                      Offs    : ($00,$01,$07,$08);
                      VType   : COM1;
                      VInd    : 7;
                      VIndEXE : 0
                    ),
                   (
                      Name    : 68;  { Lenifo }
                      Maska   : ($90,$90,$83,$C6);
                      Offs    : ($00,$01,$08,$09);
                      VType   : COM1;
                      VInd    : 8;
                      VIndEXE : 0
                    ),
                   (
                      Name    : 78;  { C377 }
                      Maska   : ($B9,$79,$01,$CD);
                      Offs    : ($10E,$10F,$120,$121);
                      VType   : COM1;
                      VInd    : 9;
                      VIndEXE : 0
                    ),
                   (
                      Name    : 69;  { Tothless C534 }
                      Maska   : ($B9,$65,$01,$83);
                      Offs    : ($F2,$F3,$F4,$F5);
                      VType   : COM1;
                      VInd    : 9;
                      VIndEXE : 0
                    ),
                   (
                      Name    : 27;  { Tumen1 }
                      Maska   : ($FA,$50,$FB,$C3);
                      Offs    : ($00,$01,$12,$13);
                      VType   : COM1;
                      VInd    : 13;
                      VIndEXE : 0
                    ),
                   (
                      Name    : 28;  { Tumen2 }
                      Maska   : ($5B,$81,$84,$19);
                      Offs    : ($03,$0C,$0E,$1A);
                      VType   : COM1;
                      VInd    : 14;
                      VIndEXE : 0
                    ),
                   (
                      Name    : 74;  { Tumen1.2 }
                      Maska   : ($5B,$81,$36,$2C);
                      Offs    : ($00,$09,$0B,$17);
                      VType   : COM1;
                      VInd    : 19;
                      VIndEXE : 0
                    ),
                   (
                      Name    : 75;  { C623 }
                      Maska   : ($BA,$FC,$00,$F3);
                      Offs    : ($01,$04,$0F,$10);
                      VType   : COM1;
                      VInd    : 20;
                      VIndEXE : 0
                    ),
                   (
                      Name    : 76;  { Joker 0.1 }
                      Maska   : ($2E,$47,$53,$81);
                      Offs    : ($01,$03,$05,$06);
                      VType   : COM1;
                      VInd    : 21;
                      VIndEXE : 0
                    ),
                   (
                      Name    : 77;  { Si RC492 }
                      Maska   : ($8B,$1E,$01,$01);
                      Offs    : ($01,$02,$03,$04);
                      VType   : COM1;
                      VInd    : 22;
                      VIndEXE : 0
                    ),
                   (
                      Name    : 36;  { Yankee Shot E1961 }
                      Maska   : ($5B,$53,$FB,$C3);
                      Offs    : ($01,$02,$03,$04);
                      VType   : EXE1;
                      VInd    : 0;
                      VIndEXE : 1
                    ),
                   (
                      Name    : 81;  { SoftPanorama RCE1864 }
                      Maska   : ($E8,$00,$B1,$04);
                      Offs    : ($00,$01,$04,$05);
                      VType   : COM1;
                      VInd    : 24;
                      VIndEXE : 0
                    ),
                   (
                      Name    : 84;  { Hercen RE2509 }
                      Maska   : ($0E,$C0,$6C,$04);
                      Offs    : ($02,$05,$0A,$0B);
                      VType   : Other;
                      VInd    : 0;
                      VIndEXE : 0
                    ),
                   (
                      Name    : 82; { FastOpen RCE4928 }
                      Maska   : ($E8,$5B,$86,$50);
                      Offs    : ($00,$03,$06,$08);
                      VType   : Other;
                      VInd    : 0;
                      VIndEXE : 0
                    ),
                   (
                      Name    : 89; { BCV RCE5287 }
                      Maska   : ($89,$8C,$F4,$55);
                      Offs    : ($01,$06,$08,$09);
                      VType   : Other;
                      VInd    : 0;
                      VIndEXE : 0
                    ),
                   (
                      Name    : 19;  { 707 Zamorochka }
                      Maska   : ($EB,$E8,$00,$5F);
                      Offs    : ($00,$03,$04,$06);
                      VType   : COM1;
                      VInd    : 11;
                      VIndEXE : 0
                    ),
                   (
                      Name    : 16;  { Flip }
                      Maska   : ($0E,$1F,$B9,$0C);
                      Offs    : ($00,$04,$05,$0F);
                      VType   : Other;
                      VInd    : 0;
                      VIndEXE : 0
                    ),
                   (
                      Name    : 90;  { Flip - modified }
                      Maska   : ($0E,$1F,$B9,$01);
                      Offs    : ($00,$04,$05,$0F);
                      VType   : Other;
                      VInd    : 0;
                      VIndEXE : 0
                    ),
                   (
                      Name    : 91;  { FEDA COM }
                      Maska   : ($EE,$67,$01,$E8);
                      Offs    : ($05,$06,$07,$08);
                      VType   : Other;
                      VInd    : 0;
                      VIndEXE : 0
                    ),
                   (
                      Name    : 91;  { FEDA EXE }
                      Maska   : ($EE,$2F,$01,$E8);
                      Offs    : ($05,$06,$07,$08);
                      VType   : Other;
                      VInd    : 0;
                      VIndEXE : 0
                    ),
                   (
                      Name    : 91;  { FEDA RCSE2370 }
                      Maska   : ($EE,$0A,$00,$0E);
                      Offs    : ($0C,$0D,$0E,$0F);
                      VType   : Sys;
                      VInd    : 0;
                      VIndEXE : 0
                    ),
                   (
                      Name    : 93;  { Live after death RC800 }
                      Maska   : ($95,$E8,$8B,$FE);
                      Offs    : ($01,$02,$0A,$0B);
                      VType   : Other;
                      VInd    : 0;
                      VIndEXE : 0
                    ),
                   (
                      Name    : 94;  { Phoenix RC1704 }
                      Maska   : ($BE,$8B,$33,$D2);
                      Offs    : ($01,$07,$09,$0A);
                      VType   : Other;
                      VInd    : 0;
                      VIndEXE : 0
                    )
                   );

{ Данные под ВПХР на СДЯВы типа COM1 }
     COM1Fag  : Array [1..Max_COM1] of COM1FagType =
                  (
                   (
                     OffsJmp : 1;
                     Offs    : 3; { Murphy }
                     Count   : 3
                    ),
                   (
                     OffsJmp : 1;
                     Offs    : $87; { Hero 506 }
                     Count   : 4
                    ),
                   (
                     OffsJmp : 1;
                     Offs    : $74; { 417 Fuck You }
                     Count   : 3
                    ),
                   (
                     OffsJmp : 1;
                     Offs    : -16; { Attention }
                     Count   : 16
                    ),
                   (
                     OffsJmp : 1;
                     Offs    : $37; { Tiny RC144 }
                     Count   : 3
                    ),
                   (
                     OffsJmp : 1;
                     Offs    : $203; { Time Bomb C648 v.A }
                     Count   : 3
                    ),
                   (
                     OffsJmp : 1;
                     Offs    : $1D1; { Kiev 90 C483 }
                     Count   : 3
                    ),
                   (
                     OffsJmp : 1;
                     Offs    : $23C; { Leninfo & Joker }
                     Count   : 3
                    ),
                   (
                     OffsJmp : 1;
                     Offs    : $14B; { MS Right C534 }
                     Count   : 3
                    ),
                   (
                     OffsJmp : 3;
                     Offs    : $204; { Time Bomb C644 }
                     Count   : 6
                    ),
                   (
                     OffsJmp : 1;
                     Offs    : -226; { 707 Zamorochka }
                     Count   : 5
                    ),
                   (
                     OffsJmp : 4;
                     Offs    : $266; { Incom Я. Цурин }
                     Count   : 6
                    ),
                   (
                     OffsJmp : 1;
                     Offs    : -220; { Tumen 1 }
                     Count   : 7
                    ),
                   (
                     OffsJmp : 1;
                     Offs    : -385; { Tumen 2 }
                     Count   : 3
                    ),
                   (
                     OffsJmp : 1;
                     Offs    : 0; { Letter Fall 1701/1704 }
                     Count   : 3
                    ),
                   (
                     OffsJmp : 1;
                     Offs    : 0; { AidsKiller }
                     Count   : 4
                    ),
                   (
                     OffsJmp : 2;
                     Offs    : $C5; { Piter C257 }
                     Count   : 4
                    ),
                   (
                     OffsJmp : 2;
                     Offs    : $75; { LoveChild }
                     Count   : 4
                    ),
                   (
                     OffsJmp : 1;
                     Offs    : -307; { Tumen1.2 }
                     Count   : 3
                    ),
                   (
                     OffsJmp : 1;
                     Offs    : -137; { Time Bomb C623 }
                     Count   : 3
                    ),
                   (
                     OffsJmp : 1;
                     Offs    : -1153; { Joker 0.1 }
                     Count   : 3
                    ),
                   (
                     OffsJmp : 1;
                     Offs    : $6F; { Si RC492 }
                     Count   : 6
                    ),
                   (
                     OffsJmp : 4;
                     Offs    : -55; { C713 им. Фомы }
                     Count   : 6
                    ),
                   (
                     OffsJmp : 1;
                     Offs    : $1dE; { SoftPanorama }
                     Count   : 14
                    )
                   );

{ Данные под ВПХР на СДЯВы типа COM2 }
     COM2Fag  : Array [1..Max_COM2] of COM2FagType =
                  (
                   (
                     OffsTrue: 990;
                     OffsTrun: 1016;
                     Count   : 14
                    )
                   );

{ Данные под ВПХР на СДЯВы типа EXE1 }
     EXE1Fag  : Array [1..Max_EXE1] of EXE1FagType =
                  (
                   (
                     VName    : 36; { Yankee Shot E1961 }
                     OffsEntr : 1851;
                     OffsStack: 1855;
                     Imagelen : 4
                    ),
                   (
                     VName    : 15; { Murphy }
                     OffsEntr : $1B;
                     OffsStack: 0;
                     Imagelen : 0
                    )
                   );

{ Данные под стуктуру о днях рождения }
   Birthdays : Array [1..Max_BirthDays] of BirthdayT =
              (
               (
                 Month : January; Day : 1; Year  : 1972
                ),
               (
                 Month : March;   Day : 19; Year  : 1971
                ),
               (
                 Month : August;  Day : 25; Year  : 1971
                ),
               (
                 Month : August;  Day : 26; Year  : 1971
                ),
               (
                 Month : May;     Day : 28; Year  : 1971
                ),
               (
                 Month : December; Day : 29; Year  : 1970
                ),
               (
                 Month : November; Day   : 8; Year  : 1970
                ),
               (
                 Month : March;    Day   : 3; Year  : 1970
                )
               );

{Любимые программы}
   Good_Prog     : Array [1..Max_GoodProg] of GoodProgT=
                 (
                  ( Ident : 'NC.EXE';
                    Say   : ' - не плох, определенно не плох !'
                  ),
                  ( Ident : 'LECAR.EXE';
                    Say   : ' -а это Я !!!'
                  ),
                  ( Ident : 'TURBO.EXE';
                    Say   : ' - Здравствуй, папа !!!'
                  ),
                  ( Ident : 'DIGGER.COM';
                    Say   : ' - хороша цацка, а?'
                  ),
                  ( Ident : 'WC.EXE';
                    Say   : ' - а вторая секретная миссия есть?'
                  ),
                  ( Ident : 'WC2.EXE';
                    Say   : ' - и ты к Angel пристаешь ?'
                  ),
                  ( Ident : 'RACONFIG.EXE';
                    Say   : ' - какой версии ремота?'
                  ),
                  ( Ident : 'FDSETUP.EXE';
                    Say   : ' - интересно, какая станция'
                  ),
                  ( Ident : 'ADM.EXE';
                    Say   : ' - не держите меня, я его убью !!!'
                  ),
                  ( Ident : 'DM.EXE';
                    Say   : ' - не держите меня, я его убью !!!'
                  ),
                  ( Ident : 'LEX.EXE';
                    Say   : ' - плавали, знаем'
                  ),
                  ( Ident : 'AFD.COM';
                    Say   : ' - ляпота то какая'
                  ),
                  ( Ident : 'NDD.EXE';
                    Say   : ' - Norton Disk Destroyer'
                  ),
                  ( Ident : 'NAV.EXE';
                    Say   : ' - ну и гадость эта заливная рыба'
                  ),
                  ( Ident : 'AIDSTEST.EXE';
                    Say   : ' - здравствуйте, коллега'
                  ),
                  ( Ident : 'LZEXE.EXE';
                    Say   : ' - разворочууу....'
                  ),
                  ( Ident : 'ARJ.EXE';
                    Say   : ' - хорош'
                  ),
                  ( Ident : 'LHA.EXE';
                    Say   : ' - ошибки есть ... '
                  ),
                  ( Ident : 'CLIPPER.EXE';
                    Say   : ' - восстановление за дополнительную плату'
                  ),
                  ( Ident : 'TD.EXE';
                    Say   : ' - батюшки, братки !'
                  ),
                  ( Ident : 'TC.EXE';
                    Say   : ' - вай-вай, каво я вижу'
                  ),
                  ( Ident : 'ACAD.EXE';
                    Say   : ' - слов нет...'
                  ),
                  ( Ident : 'AGENTC.EXE';
                    Say   : ' - узнаю, узнаю'
                  )
                 );

Var
    FName    : PathStr;
    Regs     : Registers;
    CurrDir  : DirStr;
    EXE_Buff : Array [0..$200] of Word;
    Buff     : Array [0..1023] of Byte;
    EntPoint,
    TmpPoint : Longint;
    Save21,
    SaveExit,
    Int13,
    Save13   : Pointer;
    J,K,L    : Byte;
    Present,
    EXEFile  : Boolean;
    F, F1    : File;
    SRec,
    TRec     : SearchRec;
    DateYear,
    DateMonth,
    DateDay,
    DateWeek : Word;
    T        : Longint;
    CmdLine  : ComStr;
    N        : NameStr;
    D        : DirStr;
    E        : ExtStr;
    Percent  : Real;
    Ch       : Char;

{ Сбрасывание флага критической ошибки }
Procedure ResetIOResult;
Begin
     If IOResult <> 0 then InOutRes := 0;
End;

{ Вычисление исполнительного адреса для нахождения точки входа }
Function WireA20(Segment, Offset : Word) : Longint;
Var T1 : Longint;
Begin
  WireA20 := (Longint(Segment) Shl 4 + Longint(Offset)) AND $FFFFF;
End;

{ Медленный вывод, используется в RunHelp }
Procedure WriteSlow( St : String );
Var
   I : Byte;
   J : Word;
Begin
  For I := 1 to Length( St ) do
    begin
      Sound( 50 );
      Write( St[I] );
      NoSound;
      Delay( 55 );
    end;
  WriteLn;
End;

{ Раскрутка LZEXE-файлов }
Function UnLz( FileN : PathStr ) : Boolean;
   Var
      N  : NameStr;
      D  : DirStr;
      E  : ExtStr;
      S1,
      S2 : String;
Begin
  UnLz := True;
  FSplit( FileN, D, N, E );
  S1 := FileN + #0;
  S2 := D + N + '.UNL' + #0; { Расширение разворачиваемых файлов }
  If LzTmp then S2 := LzPath+N+'.UNL'+#0;
  If LzFlag then
    If Compress.UnLz( S1, S2 ) then begin
       WriteLn;
       Exit;
    end;
  UnLz := False;
  WriteLn( ' дайте /l' ); { Раскручивать не надо }
End;

{ Процедура проверки файлов на СДЯВы }
Procedure TestFile( FRec : SRecPtr );
   Var
      I : Byte;
      ByteRead : Word;

{ Процедура лечения вирусов }
Procedure ClearFile( Hand : HandleTypePtr );
  Var
     I : Word;

  Procedure BCVXor; { Процедура расшифровки BCV5287 }
    Var
      I, XWord : Word;
    Begin
      I := 0; XWord := 0;
      While I <= $36 do begin
        XWord := XWord Xor EXE_Buff[I];
        Inc(I);
      end;
      For I:=0 to $36 do EXE_Buff[I] := EXE_Buff[I] Xor XWord;
    End;

Begin
  Close(F);
  SetFAttr(F, $20); { Установить атрибуты на Архив }
  ResetIOResult;       { на всяк случай сбросить флаг ошибки }
  FileMode := 2;
  If Not ExeFile then  { Ежели COM-файл }
  Case Hand^.VType of
      COM1 :begin      { Лечить тип COM1 }
          Reset( F, 1 );
          Seek( F, COM1Fag[Hand^.VInd].OffsJmp );
          BlockRead(F, Buff, 10, ByteRead); { 10 можно увеличить }
          ResetIOResult;
          EntPoint := Word(Buff[1] Shl 8) + Buff[0] +
                      2 + COM1Fag[Hand^.VInd].OffsJmp;
          Seek( F, EntPoint + COM1Fag[Hand^.VInd].Offs); {Сдвинемся на JMP}
          BlockRead( F, Buff, COM1Fag[Hand^.VInd].Count, ByteRead ); {и считаем исходные байты}
          ResetIOResult;
          { Шифрованные СДЯВы : }
          { Расшифровка AidsKiller }
          If Hand^.Name = 8 then begin
             Seek( F, FilePos(F) - COM1Fag[Hand^.VInd].Count );
             BlockRead( F, Buff, 210, ByteRead);
             ResetIOResult;
             Buff[0] := Buff[$B7] XOR Buff[$B];
             Buff[1] := Buff[$BD] XOR Buff[$B];
             Buff[2] := Buff[$C3] XOR Buff[$B];
             Buff[3] := Buff[$C9] XOR Buff[$B];
          end;
          { Расшифровка Letter Fall }
          If Hand^.Name = 13 then begin
             Seek( F, FilePos(F) - COM1Fag[Hand^.VInd].Count );
             BlockRead(F, Buff, 55, ByteRead);
             ResetIOResult;
             DateWeek := Word(Buff[$19] Shl 8) + Buff[$18];  { SP }
             DateYear  := EntPoint + $22 + $100;             { SI }
             For K := $22 to $30 do begin
                Buff[K] :=(Buff[K] XOR Lo(DateYear)) XOR Lo(DateWeek);
                Buff[K+1] :=(Buff[K+1] XOR Hi(DateYear)) XOR Hi(DateWeek);
                Inc( DateYear );
                Dec( DateWeek );
             end;
             Buff[0] := Buff[$2D];
             Buff[1] := Buff[$2E];
             Buff[2] := Buff[$2F];
             Dec( EntPoint );
          end;
          Reset( F, 1 );
          BlockWrite( F, Buff, COM1Fag[Hand^.VInd].Count );
          ResetIOResult;
          { СДЯВы, отрезаемые не с точки входа вируса }
          Case Hand^.Name of
              19 : Dec( EntPoint, $103 ); { Dec - сдвинуться назад }
              27 : Dec( EntPoint, $3EA );
              28 : Dec( EntPoint, $181 );
              31 : Dec( EntPoint, $16  );
              74 : Dec( EntPoint, $133 );
              75 : Dec( EntPoint, $93 );
              76 : Dec( EntPoint, $709F );
              80 : Dec( EntPoint, $40 );
          end; { Case }
          Seek( F, EntPoint );
          FRec^.Size := EntPoint;
            end;
      COM2 :begin   { лечение СДЯВов типа COM2 }
            Reset( F, 1 );
            BlockRead(F, Buff, COM2Fag[Hand^.VInd].Count, ByteRead);
            EntPoint :=(Word(Buff[$0D] Shl 8) + Buff[$0C]) Shl 4 +
                         Word(Buff[$0B] Shl 8) + Buff[$0A] - $100;
            Dec(EntPoint, $16 );
            Seek(F, FRec^.Size - COM2Fag[Hand^.VInd].OffsTrue);
            BlockRead(F, Buff, COM2Fag[Hand^.VInd].Count, ByteRead);
            Reset(F, 1);
            BlockWrite(F, Buff, COM2Fag[Hand^.VInd].Count);
            Seek(F, EntPoint);
            BlockRead(F, DateWeek, 2, ByteRead);
            Frec^.Size := Longint(DateWeek);
            Seek( F, Frec^.Size );
      end;
      { подарки, которые не вписываются в структуры }
      Other : Case Hand^.Name of
              9 : begin
                  { 512 virus }
                     Reset( F, 1 );
                     Seek( F, Frec^.Size + 512 );
                     Truncate( F );
                     Reset( F, 1 );
                     Seek( F, Frec^.Size );
                     BlockRead( F, Buff, 512, ByteRead);
                     Reset( F, 1 );
                     BlockWrite( F, Buff, 512 );
                     Seek( F, Frec^.Size );
                  end;
              82: begin { FastOpen RCE 4928 }
                    Reset(F, 1);
                    Seek(F, 1);
                    BlockRead( F, Buff, 10, ByteRead); { 10 можно увеличить }
                    ResetIOResult;
                    EntPoint := Longint(Buff[1] Shl 8)+Buff[0]+2+1-$974;
                    Seek(F, EntPoint);  { Сдвинемся на начало данных }
                    BlockRead(F, Exe_Buff, 30, ByteRead); { и считаем исходные байты }
                    ResetIOResult;
                    Exe_Buff[14] := Exe_Buff[14] XOR $9590; { ХР }
                    For I:=0 to 11 do Exe_Buff[I] := Exe_Buff[I] XOR Exe_Buff[14];
                    Exe_Buff[0] := Exe_Buff[0] XOR Exe_Buff[12];
                    Reset(F, 1);
                    BlockWrite(F, Exe_Buff, $18);
                    Dec(EntPoint, $13);
                    Seek(F, EntPoint+$10);
                  end;
              83: begin { Crazy Imp v 2.0 }
                     Reset( F, 1 );
                     Seek( F, 7 );
                     BlockRead( F, Buff, 2, ByteRead);
                     EntPoint :=(Buff[1] Shl 8) + Buff[0];
                     Seek( F, EntPoint );
                     BlockRead(F, Buff, $0B, ByteRead);
                     Reset( F, 1 );
                     BlockWrite( F, Buff, $0B );
                     Seek( F, EntPoint );
                  end;
              85: begin { Tiny RC415 }
                    Reset(F,1);
                    Seek (F,FileSize(F)-$91);
                    BlockRead(F, Buff, $91, ByteRead);
                    Reset (F,1);
                    BlockWrite( F, Buff, $91);
                    Seek (F,FileSize(F)-$91);
                  end;
              88: begin { RC763 }
                    Reset (F,1);
                    BlockRead(F, Buff, 10, ByteRead); { 10 можно увеличить }
                    ResetIOResult;
                    EntPoint := Longint(Buff[2] Shl 8) + Buff[1] -$100+$2D3;
                    Seek (F,EntPoint);
                    BlockRead(F, Buff, 5, ByteRead);
                    Reset (F,1);
                    BlockWrite( F, Buff, 5);
                    Seek (F,FileSize(F)-763);
                  end;
              89: begin { BCV RCE5287 }
                    Reset( F, 1 );
                    Seek( F, 1 );
                    BlockRead(F, Buff, 10, ByteRead);
                    ResetIOResult;
                    EntPoint := Longint(Buff[1] Shl 8) + Buff[0]-$100;
                    EntPoint := EntPoint-$F14+$13C7;
                    Seek(F, EntPoint);
                    BlockRead(F, EXE_Buff, $6E, ByteRead);
                    ResetIOResult;
                    BCVXor;
                    Reset(F, 1);
                    BlockWrite(F, EXE_Buff, 10, ByteRead);
                    ResetIOResult;
                    Dec(EntPoint, $13C7);
                    Seek(F, EntPoint);
                    ResetIOResult;
                  end;
            16,90:begin { Flip }
                    Reset( F, 1 );
                    Seek (F,1);
                    BlockRead(F, Buff, 10, ByteRead); { 10 можно увеличить }
                    ResetIOResult;
                    EntPoint := Word(Buff[1] Shl 8) + Buff[0] + 3;
                    Seek( F, EntPoint);
                    BlockRead( F, Buff, $A, ByteRead );
                    K := Buff[$9];
                    If Hand^.Name = 16 then Seek( F, EntPoint - 2076)
                      else Seek( F, EntPoint - 1890);
                    BlockRead( F, Buff, 3, ByteRead );
                    Buff[0] := Buff[0] + K;
                    Buff[1] := Buff[1] + K;
                    Buff[2] := Buff[2] + K;
                    Reset( F, 1 );
                    BlockWrite( F, Buff, 3 );
                    ResetIOResult;
                    If Hand^.Name = 16 then Seek( F, EntPoint - 2271)
                      else Seek( F, EntPoint - 2085);
                  end;
               91:begin
                    Reset (F,1);
                    Seek (F,1);
                    BlockRead(F, Buff, 10, ByteRead);
                    ResetIOResult;
                    EntPoint := Word(Buff[1] Shl 8) + Buff[0] + 3;
                    Seek(F,EntPoint+$7D9);
                    BlockRead(F,Buff,3,ByteRead);
                    Seek(F,0);
                    BlockWrite(F,Buff,3,ByteRead);
                    Seek(F,EntPoint-$164);
                  end;
            93,94:begin
                    Reset (F,1);
                    Seek (F,1);
                    BlockRead(F, Buff, 10, ByteRead);
                    ResetIOResult;
                    EntPoint := Word(Buff[1] Shl 8) + Buff[0] + 3;
                    Seek(F,EntPoint+$1E);
                    BlockRead(F,Buff,$400,ByteRead);
                    DateYear := $0; DateDay :=0; DateMonth:=$0;
                    Repeat
                      DateYear := DateYear XOR (Word(Buff[DateDay+1] Shl 8)+Buff[DateDay]);
                      Inc ( DateDay,2 );
                      Inc ( DateMonth );
                    Until DateMonth = $181;
                    Seek(F,EntPoint+$2E2);
                    BlockRead(F,Buff,$400,ByteRead);
                    Move (Buff,EXE_Buff,8);
                    EXE_Buff[0] := EXE_Buff[0] XOR DateYear;
                    EXE_Buff[1] := EXE_Buff[1] XOR DateYear;
                    Move (EXE_Buff,Buff,8);
                    Seek (F,0);
                    BlockWrite(F,Buff[1],$3,ByteRead);
                    Seek(F,EntPoint+$320);
                    BlockRead(F,Buff,$190,ByteRead);
                    Seek(F,EntPoint);
                    BlockWrite(F,Buff,$190,ByteRead);
                    If Hand^.Name = 93 then Seek (F,FileSize(F)-800)
                       else Seek (F,FileSize(F)-1704);
                  end;
      end; { Case of Hand^.Name }
      Sys   : Case Hand^.Name of
               91:begin
                    Reset (F,1);
                    Seek (F,0);
                    BlockRead (F, Buff, $200, ByteRead);
                    EntPoint:= ( Buff[7] Shl 8 ) + Buff[6];
                    Seek(F,EntPoint+$44); BlockRead(F,Buff,2);
                    Seek(F,6); BlockWrite(F,Buff,2);
                    Seek(F,EntPoint+$93D); BlockRead(F,Buff,5);
                    Seek(F,8); BlockRead(F,EXE_Buff[0],2); Seek(F,EXE_Buff[0]);
                    BlockWrite(F,Buff,5);
                    Seek(F,EntPoint);
                  end;
      end; { Case of Hand^.Name }
  end { case }
  else { ежели EXE-файл }
  Case Hand^.VType of
  COM1,
  EXE1 :If Hand^.VindEXE <> 0 then
        begin
          Reset( F, 1 );
          EntPoint := WireA20(EXE_Buff[$0B], EXE_Buff[$0A]) +
                      Longint(EXE_Buff[$04]) Shl 4;
          Seek( F, EntPoint + EXE1Fag[Hand^.VindEXE].OffsEntr );
          BlockRead( F, EXE_Buff[$0A], 4, ByteRead);
          If EXE1Fag[Hand^.VindEXE].OffsStack <> 0 then begin
            Seek( F, EntPoint + EXE1Fag[Hand^.VindEXE].OffsStack );
            If EXE1Fag[Hand^.VindEXE].Vname = 36 then
               BlockRead(F, EXE_Buff[$07], 2, ByteRead)
            else BlockRead(F, EXE_Buff[$07], 4, ByteRead);
          end;
          If EXE1Fag[Hand^.VindEXE].ImageLen <> 0 then
            If EntPoint < Longint(EXE_Buff[$2] Shl 9)
              then Dec(EXE_Buff[$2], EXE1Fag[Hand^.VindEXE].ImageLen )
            else
          else begin
              EXE_Buff[$2] := Word(EntPoint Shr 9);
              If(EntPoint Mod 512) <> 0 then Inc( EXE_Buff[$2] );
          end;
          Reset( F, 1 );
          BlockWrite( F, EXE_Buff, $1C );
          Seek( F, EntPoint );

        end; {EXE1}
  Other:Case Hand^.Name of
          84:begin
               Reset( F, 1 );
               EntPoint := WireA20(EXE_Buff[$0B], EXE_Buff[$0A]) +
                           Longint(EXE_Buff[$04]) Shl 4;
               Seek( F, EntPoint+$D8);
               BlockRead(F, EXE_Buff[$0A], 4, ByteRead); {Real entry_point}
               EXE_Buff[$2] :=((FileSize(F)-2048) DIV 512) +1;
               EXE_Buff[$3] := EXE_Buff[$3] -1;
               Reset( F, 1 );
               BlockWrite( F, EXE_Buff, $1C );
               Seek( F, FileSize(F)-2048 );
             end;
          82:begin { FastOpen RCE 4928 }
               Reset(F, 1);
               EntPoint := WireA20(EXE_Buff[$0B], EXE_Buff[$0A]) +
                           Longint(EXE_Buff[$04]) Shl 4;
               Seek( F, EntPoint-$974); { Сдвинемся на начало данных }
               BlockRead(F, Exe_Buff, 30, ByteRead); { и считаем исходные байты }
               ResetIOResult;
               Exe_Buff[14] := Exe_Buff[14] XOR $9590; { ХР }
               For I:=0 to 11 do Exe_Buff[I] := Exe_Buff[I] XOR Exe_Buff[14];
               Exe_Buff[0] := Exe_Buff[0] XOR Exe_Buff[12];
               Reset(F, 1);
               BlockWrite(F, Exe_Buff, $18);
               Dec(EntPoint, $986);
               Seek(F, EntPoint);
             end;
          89: begin { BCV RCE5287 }
                Reset( F, 1 );
                EntPoint := WireA20(EXE_Buff[$0B], EXE_Buff[$0A]) +
                            Longint(EXE_Buff[$04]) Shl 4;
                EntPoint := EntPoint-$F14+$13C7;
                Seek(F, EntPoint);
                BlockRead(F, EXE_Buff, $6E, ByteRead);
                ResetIOResult;
                BCVXor;
                Reset(F, 1);
                BlockWrite(F, EXE_Buff, 24, ByteRead);
                ResetIOResult;
                Dec(EntPoint, $13C7);
                Seek(F, EntPoint);
                ResetIOResult;
              end;
       16,90: begin {Flip}
                    Reset( F, 1 );
                    EntPoint := WireA20(EXE_Buff[$0B], EXE_Buff[$0A]) +
                                Longint(EXE_Buff[$04]) Shl 4;
                    Seek(F, EntPoint);
                    BlockRead( F, Buff, $A, ByteRead );
                    K := Buff[$9];
                    If Hand^.Name = 16 then Seek( F, EntPoint - 2076)
                      else Seek( F, EntPoint - 1890);
                    BlockRead( F, Buff, $A, ByteRead );
                    For I:=0 to $A do Buff[I] := Buff[I] + K;
                    EXE_Buff[$A] := Word(Buff[1] Shl 8) + Buff[0];
                    EXE_Buff[$B] := Word(Buff[3] Shl 8) + Buff[2];
                    Dec (EXE_Buff[$B], $10);
                    EXE_Buff[$7] := Word(Buff[5] Shl 8) + Buff[4];
                    Dec (EXE_Buff[$7], $10);
                    If Hand^.Name = 16 then begin
                      EXE_Buff[2] := Word((EntPoint - 2271) Div 512)+1;
                      EXE_Buff[1] := Word((EntPoint - 2271) Mod 512);
                    end
                    else begin
                           EXE_Buff[2] := Word((EntPoint - 2085) Div 512)+1;
                           EXE_Buff[1] := Word((EntPoint - 2085) Mod 512);
                         end;
                    Reset( F, 1 );
                    BlockWrite(F, EXE_Buff, 24, ByteRead);
                    ResetIOResult;
                    If Hand^.Name = 16 then Seek( F, EntPoint - 2271)
                      else Seek( F, EntPoint - 2085);
              end;
           91:begin
                Reset (F,1);
                Seek(F,1);
                EntPoint := WireA20(EXE_Buff[$0B], EXE_Buff[$0A]) +
                                Longint(EXE_Buff[$04]) Shl 4;
                EntPoint:= EntPoint - $12C;
                Seek(F,EntPoint+$04A);
                BlockRead(F,EXE_Buff[$7],2);
                BlockRead(F,EXE_Buff[$8],2);
                ResetIOResult;
                Seek(F,EntPoint+$160);
                ResetIOResult;
                BlockRead(F,EXE_Buff[$A],2);
                BlockRead(F,EXE_Buff[$B],2);
                Reset( F, 1 );
                BlockWrite(F, EXE_Buff, 24, ByteRead);
                ResetIOResult;
                Seek(F,EntPoint);
              end;
        end; {Case of Hand^.Name }
  end; {Case}
  Truncate( F );
  Reset( F, 1 );
  Write(' дезактивировал');
  Close( F );
  ResetIOResult;
  WriteLn;
  Reset(F, 1);
  Close(F);
  ResetIOResult;
  SetFAttr(F, Word(FRec^.Attr));
  SetFTime(F, FRec^.Time);
  ResetIOResult;
  FileMode := 0;
End;

Begin
  If Length(FName) < 40
     then  Write( FName, '':79-Length( FName ), #13)
    else begin { Заложимся на длинное имя(с директориями) }
         FSplit( FName, D, N, E );
         Write( D[1]+':\...\'+N+E, '':79-7-Length( N+E ), #13)
    end;
  If Hacker_Flag then begin { Поприкалываемся }
    FSplit( FName, D, N, E );
    For K := 1 to Max_GoodProg do
      If N+E = Good_Prog[K].Ident then
        If Length(FName) < 40
          then WriteLn(FName, Good_Prog[K].Say)
        else WriteLn( D[1]+':\...\'+N+E, Good_Prog[K].Say)
  end;

  FileMode := 0;
  Assign( F, FName );
  Reset( F, 1 );
  { Зараженный файл не может меньше 135 байт }
  If FRec^.Size > 135 then begin
     BlockRead(F, Buff, 136, ByteRead);
     ResetIOResult;
     If(Buff[0]=$4D) AND(Buff[1]=$5A) then begin
        { EXE-файл }
        EXEFile := True;
        Move( Buff, EXE_Buff, $1C ); { EXE - заголовок }
        EntPoint :=  WireA20(EXE_Buff[$0B], EXE_Buff[$0A]) +
                     Longint(EXE_Buff[$04]) Shl 4;
        Seek(F, EntPoint); { пойдем по точке входа }
        If FilePos( F ) > FRec^.Size - $10 then begin
           Close( F ); { точка входа на конец файла или за него  }
           Exit;
        end;
        BlockRead(F, Buff, $200, ByteRead); { читаем с точки входа }
        ResetIOResult;
     end
     else begin
         EXEFile := False;
         If(Buff[0] = $E8) OR(Buff[0] = $E9) { проверяем на JMP }
           then begin
{ сдвигаемся по }  Seek(F, FilePos( F )-ByteRead+3+Longint(Buff[$2]) Shl 8 + Buff[$1]);
{    JMP        }  If FilePos( F ) > FRec^.Size - 200 then
                 If FilePos( F ) > FRec^.Size - 30 then begin
                   Close( F );
                   Exit;
                 end
                 else BlockRead(F, Buff, FRec^.Size-FilePos( F ), ByteRead)
               else BlockRead(F, Buff, $200, ByteRead);
               ResetIOResult;
           end
           else begin
             If (Buff[4] = $C3) AND ((Buff[3] AND $F0) = $50)
               then begin
                 Seek(F, Word(Buff[2] Shl 8) + Buff[1]-$100);
                 ResetIOResult;
                 If FilePos( F ) > FRec^.Size - 30 then begin
                   Close( F );
                   Exit;
                 end
                 else BlockRead(F, Buff, 100, ByteRead);
               end
             else
             If Buff[0] XOR Buff[1] XOR Buff[2] XOR Buff[3] XOR $FF = $FF then begin
                Seek(F, Word (Buff[7] Shl 8) + Buff[6]);
                BlockRead(F, Buff, $200, ByteRead);
                ResetIOResult;
             end else  begin
{ проверка на вирусы, которые мы узнаем по началу файла }
               For I := 1 to Max_COM_Begin do begin
                 Present := True;
                 J := 0;
                 Repeat
                   If Buff[COM_Begin[I].Offs[J]] <> COM_Begin[I].Maska[J]
                     then Present := False;
                   Inc(J);
                 Until(NOT Present) OR(J>3);
                 If Present then begin { найден вирус }
                 If Length( FName ) < 40
                    then  Write( FName, ' вирус ',Virus_Name[COM_Begin[I].Name] )
                   else begin
                        FSplit( FName, D, N, E );
                        Write( D[1]+':\...\'+N+E, ' вирус ',Virus_Name[COM_Begin[I].Name])
                   end;
                    If Present then Inc( TotalInfected );
                    If Fag AND(COM_Begin[I].Vtype <> None) then begin
  { нашли вирус и умеем его лечить, если что, раскручиваем матрешку }
                       ClearFile( @COM_Begin[I] );
                       TestFile( FRec );
                       Reset( F, 1 );
                    end
                    else WriteLn;
                 end;
               end; { End For }
               Close( F );
               Exit;
             end;
           end;
     end;
     If((Buff[0] = $E8) OR(Buff[0] = $E9)) AND
       ((Buff[$1]<>$00) OR(Buff[$2]<>$00)) then begin
     { если что пойдем по JMP }
           Seek(F, FilePos(F)-ByteRead+3+Longint(Buff[$2] Shl 8) + Buff[$1]);
           If FilePos(F) > FRec^.Size - 100 then begin
              Close( F );
              Exit;
           end;
           BlockRead(F, Buff, $100, ByteRead);
           ResetIOResult;
     end;
     { СДЯВы, которые не узнаем по началу }
     For I := 1 to Max_EXE_Us do begin
        Present := True;
        J := 0;
{сравниваем}Repeat
{с маской }       If Buff[EXE_Vir[I].Offs[J]] <> EXE_Vir[I].Maska[J]
                then Present := False;
              Inc(J);
        Until(NOT Present) OR(J>3);
        If Present then begin { обнаружен СДЯВ }
        If Length( FName ) < 40
           then  Write( FName, ' вирус ',Virus_Name[EXE_Vir[I].Name] )
          else begin
               FSplit( FName, D, N, E );
               Write( D[1]+':\...\'+N+E, ' вирус ',Virus_Name[EXE_Vir[I].Name]);
          end;
           If Present then Inc( TotalInfected );
           If Fag AND(EXE_Vir[I].Vtype <> None) then begin
              ClearFile( @EXE_Vir[I] ); { лечим }
              TestFile( FRec ); { перепроверим  }
              Reset( F, 1 );  { для нормального выхода из рекурсии }
           end
           else WriteLn;
        end;
     end;
     { Распознавание LZEXE формата }
     If(Buff[5] = $0C) AND(Buff[6] = $0) AND
       (Buff[7] = $8B) AND(Buff[8] = $F1) then begin
        Write( FName, ' архивирован LZEXE ');
        If UnLz( FName ) then begin { раскручиваем LZEXE }
          FSplit( FName, D, N, E );
          If LzTmp then FName := LzPath + N + '.UNL'
             else FName := D + N + '.UNL';
          FindFirst( FName, $3F, TRec );
          Close( F );
          TestFile( @TRec ); { проверяем на СДЯВы }
          Reset( F1, 1 );
          If NOT Present then begin
            Assign( F1, FName ); { если шо, удаляем раскрученный файл }
            If EraseUnLz then Erase( F1 );
          end;
          Close( F1 );
        end;
     end;
  end;
  Close( F );
  Write( #13 );
End;

{ перебираем нужные файлы }
Function NeedFile( P : PathStr ) : Boolean;
Const
     MaxExtDefault = 4;
     { Расширения, которые проверяются по умолчанию }
      NeedExt  : Array[1..MaxExtDefault] of ExtStr =
     ( '.EXE', '.COM','.SYS','.BIN' );
 Var
    Dir        : DirStr;
    Name       : NameStr;
    Ext        : ExtStr;
    I          : Integer;
 Begin
   NeedFile := True;
   If TestAll then Exit;
   FSplit( P, Dir, Name, Ext );
   For I := 1 to MaxExtDefault do
      If Ext = NeedExt[I] then Exit;
   NeedFile := False;
 End;

{ Бегаем по директориям }
Procedure SearchDir( Dir : PathStr);
 Var
    SRec       : SearchRec;
    CRC        : Word;
    Error      : Integer;
    Len        : Longint;
 Begin
   CRC := 0;
   Error := 0;
   If Dir[ Length(Dir) ] <> '\' then Dir := Dir+'\';
   FindFirst( Dir+'*.*', AnyFile, SRec );
   While DosError = 0 do
     begin
       With SRec do       { Directory looking }
         If Attr AND 24 = 0 then
           begin
             FName := Dir + Name;
             If NeedFile( FName ) then
               begin
                 If Error = 0 then
                  begin
                    Inc( TotalFiles );
                    { проверяем нйденный файл }
                    TestFile( @SRec );
                  end;
               end;
           end;
       FindNext( SRec );
     end;
   FindFirst( Dir+'*.*', AnyFile, SRec );
   While DosError = 0 do
     begin
       With SRec do
         If( Attr AND 16 <> 0 ) AND( Name[1] <> '.' ) then
           begin
             SearchDir( Dir+Name );   { Restore DTA }
             Regs.AH := $1A;
             Regs.DS := Seg( Srec );
             Regs.DX := Ofs( SRec );
             MsDos( Regs );
           end;
       FindNext( SRec );                    { Directory searching }
     end;
 End;

{ разберемся с критическими ошибками }
{$F+}
Procedure Int23;Interrupt;
   Begin
     Halt ($FF); { $FF - на шару }
   End;

Procedure ExitHandler;
   Begin
     { восстанавливаем вектора, которые хватали }
     ExitProc := SaveExit;
     SetVector( $21, Save21 );
     If StrongMan then SetVector( $13, Save13 );

     If ErrorAddr <> Nil then begin { ошибка }
       WriteLn;
       WriteLn( 'Лекарь утомился по адресу ', HexWord( Seg(ErrorAddr^) ),
                 ':', HexWord( Ofs(ErrorAddr^) ) );
       Exit;
     end;
     If ExitCode <> $FF then Halt;
     { Нажали Ctrl-Break }
     WriteLn;
     WriteLn('* Надоело --- не пускай !!! *');
     Halt( $FE );
   End;
{$F-}

{ Разборка командной строки, комментарии излишни }
Procedure GetCmdLine;
   Var
      _I, _J : Byte;
Begin
  CmdLine := '';
  For _I := 1 to Mem[PrefixSeg:$80] do
    CmdLine := CmdLine + UpCase( Char(Mem[PrefixSeg:$80+_I]) );
  For _I := 1 to Length( CmdLine ) do begin
    If CmdLine[_I] = '*' then AllDrive := True;
    If CmdLine[_I] = ':' then CurrentDrive := Byte(CmdLine[_I-1]) - Byte('A');
    If CmdLine[_I] = '/' then
      Case CmdLine[_I+1] of
           'F','C' : Fag         := True;
           'G','A' : TestAll     := True;
           'H'     : Hacker_Flag := True;
           'L'     : LzFlag      := True;
           'N'     : EraseUnLz   := False;
           'B'     : StrongMan   := True;
           'D'     : TestServers := True;
           'S'     : begin
                          LzTmp := True;
                          _J := _I+2;
                          Repeat
                                Inc( _J );
                          Until(CmdLine[_J] = ' ') OR
                               ( _J > Ord(CmdLine[0]) ) OR
                               (CmdLine[_J] = '/');
                          LzPath := Copy( CmdLine, _I+3, _J-_I-3  );
                          If LzPath[Length(LzPath)] <> '\'
                            then LzPath := LzPath + '\';
                     end;
           else Help := True;
       end; { case }
     If(CmdLine[_I] = ':') AND(CmdLine[_I-2] <> '=') then begin
       _J := _I-1;
       CurrDir := '';
       Repeat
             CurrDir := CurrDir + CmdLine[_J];
             Inc(_J);
       Until(CmdLine[_J] = ' ') OR( _J > Ord(CmdLine[0]) );

     end;
   end;
End;

{ Если бул запущен без параметров или с ключом /h }
Procedure RunHelp;
Begin
  WriteLn;
  WriteLn(' Здравствуйте, я Лекарь');
  WriteLn(' Умею искать и лечить вирусы, раскручивать LZEXE');
  WriteLn(' Понимаю следующие параметры :');
  WriteSlow(' Lecar [path] [/options]  , где');
  WriteSlow('       path    - вирусоопасное направление');
  WriteSlow('       *       - проверять все винты');
  WriteSlow('       options - методы искоренения:');
  WriteSlow('       /a      - проверять все, что плохо лежит');
  WriteSlow('       /c      - лечить настигнутых негодяев');
  WriteSlow('       /d      - работа в сети или многозадчке');
  WriteSlow('       /l      - разархивировать заархивированных LZEXE');
  WriteSlow('       /s=path - установить рабочий каталог( использовать совместно с /l )');
  WriteSlow('       /n      - раскрученнные файлы не удалять');
  WriteSlow('       /b      - применять при тяжелых случаях ADMa');
  WriteSlow('       /h      - попросту, без чинов');
  WriteSlow('       /?      - эта пространная информация');
  WriteLn(#13,#10,
            ' Lecar *  /c/h - проверить с лечением все диски > B:');
  WriteLn(  ' Lecar c: /h   - проверить диск C:');
  WriteLn(#13,#10,' Cвязь по FIDO : 2:463/34 ─── Mikrob Point - (044) 224-7070');
  WriteLn(' Voice phone   : (044) 449-97-67 ─── до и после 11.00');
  WriteLn;
  Write(' Нажми любую клавишу для продолжения');
  Ch := ReadKey;
  If Ch = #0 then Ch := ReadKey;
  Write(#13,'                                      ',#13);
End;

{ Титулка, выводится каждый раз }
Procedure Titul;
Begin
  WriteLn('┌─────────────────────────────────────────────────────────┐');
  WriteLn('│               Л е к а р ь    v '+Version+'X'+AllViruses+'                  │');
  If Hacker_Flag then begin
     WriteLn('│  раз, два, три, четыре, пять - вышел  ЛЕКАРЬ  погулять  │');
     WriteLn('│          Кто не спpятался, - я не виноват               │');
  end;
  WriteLn('└─────────────────────────────────────────────────────────┘');
  WriteLn (' Посвящается '+Owner+'   '+CreatDate);
End;

{ Проверка диска }
Procedure Testing;
Begin
  WriteLn;
  WriteLn( CurrDir, ' Дышите глубже' );
  TestDisk( CurrentDrive ); { на Boot }
  SearchDir( CurrDir ); { пошли шуршать по дискам }
  ResetIOResult;
  { выведем статистику }
  WriteLn( #1, '':30, #13, 'Всего проверено файлов: ', TotalFiles, '':20 );
  If TotalInfected <> 0 then begin
    If Fag then WriteLn( 'Всего вылечено вирусов:  ', TotalInfected )
    else WriteLn( 'Всего заражено файлов: ', TotalInfected );
    If Hacker_Flag then begin
      Percent := TotalInfected / TotalFiles;
      Write('ДИАГНОЗ:  ');
      If( Percent < 0.1 ) then WriteLn(' Не отчаивайтесь, бывает и хуже')
      else If( Percent < 0.3 ) then WriteLn(' И где Вы столько набрали ?')
           else If( Percent < 0.7 ) then WriteLn(' Больной перед смертью потел  ? ')
                else WriteLn(' Ну вот, на коллекцию натравили');
    end;
  end
  else WriteLn( 'Проверено. Мин нет. Лекарь.' );
End;

Procedure TestMyselfOnViruses;
Var
   S : String;
Begin
  Assign( F,  ParamStr(0) );
  Reset( F, 1 );
  BlockRead(F, Buff, 136);
  ResetIOResult;
  Move( Buff, EXE_Buff, $1C ); { EXE - заголовок }
  EntPoint := WireA20(EXE_Buff[$0B], EXE_Buff[$0A]) +
              Longint(EXE_Buff[$04]) Shl 4;
  Seek(F, EntPoint ); { пойдем по точке входа }
  BlockRead(F,Buff, 136);
  If(Buff[00] <> $B8) OR(Buff[03] <> $BA) OR
    (Buff[06] <> $8C) OR(Buff[07] <> $DB) then
  begin
    WriteLn;
    WriteLn(' Я инфицирован неизвестным мне вирусом, если погибну');
    WriteLn(' сообщите родителям по тел. (044) 449-97-67');
  end;
  Close( F );
End;

{ Основной модуль }
Begin
  SaveExit := ExitProc; { обработчик ошибок - на себя }
  ExitProc := @ExitHandler;
  SetVector( $23, Addr( Int23 ) );
  GetDir( 0, CurrDir ); { текущая директория }
  CurrDir := Copy( CurrDir, 1, 3 );
  Regs.AH := $19;  { текущий диск }
  MsDos( Regs );
  CurrentDrive := Regs.AL;
  GetCmdLine;  { Разберем коммандную строку }
  { инициализируем паскалевские variables }
  CheckSnow := False;
  FileMode := 0;
  DirectVideo := False;
  WriteLn;
  CheckBreak := False;
  Titul;
  If Help then RunHelp; {если без параметров или с ключом /h}
  CheckBreak := True;
  DirectVideo := True;
  { Запомним вектора }
  GetVector( $21, Save21 );
  GetVector( $13, Save13 );
  { проверка на вирусы в памяти }
  If TestMemoryOnViruses then begin
    SetVector( $21, Ptr(DosSeg, DosOfs) );
    Int13 := Ptr(BiosSeg,BiosOfs);
    If(Int13 <> NIL) AND StrongMan then SetVector( $13, Int13 );
    { если вирус в памяти, проверим себя и }
    Tmp_Flag := Fag; { Запомним состияние ключа }
    Fag := True; {Если на дали /f, а лечиться надо}
    FName := ParamStr(0);
    FindFirst( FName, $3F, SRec );
    TestFile( @SRec );
    Reset( F, 1 );
    FName := GetEnv( 'COMSPEC' );
    FindFirst( FName, $3F, SRec );
    If DosError = 0 then begin
      TestFile( @SRec ); { Command.com}
      Reset( F, 1 );
    end
    else WriteLn( ' не могу найти COMMAND.COM по COMSPEC' ); { спрятали}
    Write( #13, '': 40 );
    Fag := Tmp_Flag;
  end;
  TestMyselfOnViruses;
  { Немного расслабимся, расскажем о днях рождения }
  If Hacker_Flag then begin
     GetDate( DateYear, DateMonth, DateDay, DateWeek );
     For J := 1 to Max_Birthdays do
         If(DateMonth= Word(Birthdays[J].Month)+1) AND
           (DateDay  = Birthdays[J].Day) then begin
                Dec(DateYear, Birthdays[J].Year);
                WriteLn( ' Поздравьте меня, у меня сегодня праздник !!!' );
                WriteLn ( ' Одному из моих авторов исполнилось ', DateYear: 2,  ' лет');
                WriteLn;
            end;
  end;
  { На время проверки рванем 21-й на себя }
  If Not TestServers  then SetVector( $21, Ptr(DosSeg, DosOfs) );
  Int13 := Ptr(BiosSeg,BiosOfs); { если дали ключ /b }
  If(Int13 <> NIL) AND(StrongMan) then SetVector( $13, Int13 );
  If NOT AllDrive then begin
    Testing; { Шуршим по заданному диску и директории }
    Halt( $FE );
  end;

  { Если дали * для поиска по всем дискам }
  For CurrentDrive := 3 to Byte('Z')-Byte('A') do begin
    Regs.BL := CurrentDrive;
    Regs.AX := $440E;
    MsDos( Regs );
    If Regs.AX <> 15 then begin { существует ли такой диск }
       CurrDir := Char($40+Regs.BL) + ':\';
       ResetIOResult;
       Testing; { проверяем }
       TotalFiles := 0; { сбрасываем статистику }
       TotalInfected := 0;
     end;
  end;
End.