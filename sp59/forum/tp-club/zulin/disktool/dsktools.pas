{$A+,B-,D+,E-,F-,G-,I-,L+,N-,O-,R+,S+,V-,X-} { Turbo Pascal 6.0-7.x,  ! }
{ Из опций компилятора Вы можете изменять только $O-/$O+ - код оверлея


      █▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█
      █                                                             █▒▒
      █                         DSKTOOLS                            █▒▒
      █                                                             █▒▒
      █   Модуль (-исследование) работы с дисковыми устройствами    █▒▒
      █                 (, файлами и драйверами).                   █▒▒
      █                                                             █▒▒
      █          (C) Copyright BZSoft,  1990 - jan. 1993.           █▒▒
      █   (C) Copyright GalaSoft United Group International, 1992.  █▒▒
      █                                                             █▒▒
      █                        version 3.05                         █▒▒
      █                                                             █▒▒
      █                                                             █▒▒
      █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█▒▒
        ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒


  ************************ МОТИВЫ НАПИСАНИЯ МОДУЛЯ *********************

    Многие программы для удобства пользователя  создают  списки  дисков,
  файлов, каталогов. Большинство программ неверно  определяют количество
  доступных дисков, состав таблицы допустимых имен. Наиболее распростра-
  ненный способ - прочитать LastDrive и создать таблицу от  этого значе-
  ния вниз до A:. Причем сбои в работе программ возникают также  пpи на-
  личии в системе одного дисковода  для  гибких  дисков,  переназначении
  дисков программой SUBST. Этот модуль предназначен для  устранения этих
  ошибок. В модуле находится  pяд процедур, дублирующих подобные в паке-
  те Turbo Professional [3], но если не обращаться к этим процедурам, то
  компилятор НЕ ВКЛЮЧИТ их код в  программу.  Дублирование  введено  для
  полноты ощущений - это модуль работы с ДИСКАМИ (да и TPDOS я использую
  все реже и реже).

  ************************ АНАЛОГИ *************************************

   Определение типа диска введено в модуль TPDOS, но при работе происхо-
  дит  обращение   к  накопителю  (что  нежелательно),  процедура  TPDOS
  работает через Media Descriptor и правдива только в стандартной конфи-
  гурации системы.

  ************************ ЗАВИСИМОСТЬ ОТ ВЕРСИИ DOS *******************

   В связи с некоторыми различиями DR-DOS и MS-DOS этот модуль определя-
  ет тип системы при  запуске  программы,  также  как  и  OS/2  (которая
  совместима с MS-DOS 3.30), у DR-DOS в окружении установлены  следующие
  строки : OS=DRDOS,  VER=5.0  (или  6.0 соответственно).
  Напомню, что в MS-DOS  5.0  Вы  можете  указать  любой  программе, что
  используется другая версия DOS, запустив  программу  SETVER,  но  этот
  модуль определяет верно номер версии DOS.

  ************************ ТЕСТ ****************************************

    Этот модуль был тестирован в  MS-DOS  5.0  при  установке  различных
  драйверов, запуске команды SUBST, переназначении дисковода A: на  дис-
  ковод B: в системе с одним дисководом для сменного диска,также при ра-
  боте системы XENIX при загруженном драйвере VP/ix (он грузит  как под-
  задачу MS-DOS 3.20) при работе модуля в системе MS-DOS  2.0 невозможно
  определение типов устройств и нельзя воспользоваться  определением пе-
  реприсвоений для дисководов сменных дисков.

    Тест продолжен в MS-DOS 3.30, COMPAQ DOS 3.31 и DR-DOS 6.0.

  Модуль поддерживает работу с жестким диском, размером более 32M.

  ************************ РАЗМЕРЫ ********************************

  При использовании в Вашей программе только  инициализации  модуля
  Uses
       ...
       DskTools,
       ...;
  без вызова процедур, размер кода  увеличивается на  0.3k,  размер
  данных - на 0.03k, при вызове процедуры  DiskInit - размер кода -
  на 1.8k, размер данных - на 0.17k.
  Такой малый объем достигается оптимизацией кода и  использованием
  языка ассемблера при написании модуля.

  ************************ ИСТОРИЯ ********************************

  Версия 1.0 -  проверяла  только  число  дисководов  для  гибких
  дисков, количество и наименование доступных дисков.

  Версия 2.0 - устанавливала тип диска стандартной конфигурации.

  Версия 3.0 - модуль полностью переписан на ассемблере,  изменен
  алгоритм работы многих процедур, добавлены процедуры сервиса.

  Версия 3.01 -  введена  процедура  определения  типа  дисковода
  гибких дисков, оптимизирован ассемблерный  код  ряда  процедур,
  часть переменных перенесена из сегмента данных в сегмент стека,
  что увеличивает объем доступной памяти для пользователя.
    Добавлены функции определения инсталляции.
    Добавлены комментарии к процедурам и описание методов работы,
  новая переменная компилятора IniDiskTable,  позволяющая  запус-
  кать инициализацию непосредственно при  запуске  программы, при
  отключенном определении процедуры инициализации  НЕ БУДУТ ЗАНЕ-
  СЕНЫ в код программы, если к ним не будет обращения,  но  тогда
  для использования массивов имен и типов дисков необходимо будет
  инициализировать эти массивы следующим образом :

  if not DskToolsVarInit Then InitDiskVariable;

  Версия 3.02 - разделение модуля на два - DskTools  и  DrvTools.
    Добавление  документации и процедур  определения  инсталляции
  (см. DrvTools). Модуль переименован (ранее назывался DiskTool).
    Добавлен ряд процедур.

  Версия 3.03 - У некоторых процедур обновлен алгоритм, проведена
  оптимизация. Изменена процедура DiskInit.  Модуль адаптирован к
  языкам МОДУЛА-2 и Ассемблер (,Си и другие  языки  при  соответ-
  ствующем методе  вызова) -  создана  библиотека  для  указанных
  языков. (адаптацию проводил Березин  Антон).  Ряд  пеменных  из
  сегмента данных перенесен в сегмент стека, что увеличивает сво-
  бодную статическую память.

  Версия 3.04 - В процедурах GetVolumeLabel/SetVolumeLabel
  изменена работа с регистрами.

  Версия 3.05 - Добавления для TURBO 7.0

  ******************************************************************
}
{.$DEFINE ExitIfBadDOS - установите, если хотите, чтобы  при
                     запуске  вашей  программы  при  наличии
                     DOS версии ниже 3.20 происходил останов
}
{$DEFINE BZdetaily - для возвращения головки/дорожки/сектора
                     при эмуляции чтения сектора.
}
{.$DEFINE IniDiskTable - Устанавливается для инициализации
                         таблиц типов дисков при загрузке
                         программы, по умолчанию выключено,
                         что НЕ ДОБАВЛЯЕТ код в программы,
                         не использующие массивы типов дисков.}
{$IFDEF VER70}
{$DEFINE OkVer}
{$ENDIF}
{$IFDEF VER60}
{$DEFINE OkVer}
{$ENDIF}

{$IFDEF OkVer}
unit DskTools;

Interface

type DiskClass =
   ( IllegalDisk,     { несуществующий }
     Floppy,          { Дисковод для дискет }
     BernoulliDisk,   { Гибрид слишком гибкого и жесткого }
     HD0,             { Раздел жесткого 0 диска }
     HD1,             { Раздел жесткого 1 диска }
     DeviceDriven,    { Сжатые (Stacker,HiperDisk,SuperStor) и т.п. }
     NetWorkDisk,     { Сетевой диск }
     SubstitutedDisk, { Диск, образован SUBST, см. комментарий ниже }
     AssignedDisk,    { переназначен ASSIGN, только в MS-DOS (и совместимых)}
     VDisk,           { диски в RAM (...XMS, EMS) (VDISK,RAMDISK,RAMDRIVE) }
     EgaDisk,         { размещен в EGA/VGA памяти  }
     Encrypted,       { образован DiskReet из пакета Norton Utilities }
{    PhantomDrive,    { фантомное устройство }
     UnKnown);        { Неопределено }

{***********************************************************************
   Для DR-DOS  в  связи  с  его   совмещением  SUBST  и  ASSIGN   диски,
   переназначенный  ASSIGN  будут  иметь  тип  также   SubstitutedDisk !
   Для DR-DOS разница  в  командах  ASSIGN  и  SUBST состоит в том,  что
   ASSIGN  теперь  является  подфункцией  SUBST,  т.е.  это  равносильно
   запуск SUBST  с присвоением  корневого каталога одного диска  другому
   диску. Т.е. можно сказать, что команда ASSIGN выведена (как резидент)
   из DR-DOS и ее эмуляция  работает  через  SUBST,  что  подтверждается
   тем, что при переприсвоении диска ASSIGN  SUBST  также  имеет  доступ
   к данным об переприсвоении, например:

C:\>ASSIGN a=f
C:\>ASSIGN /a
A: => F:\       <────────────────────┐
                                     │
C:\>SUBST                            │ сообщения DOS
A: => F:\       <────────────────────┼───────────────
                                     │
C:\>SUBST a: /d                      │
C:\>ASSIGN /a                        │
                <────────────────────┘
     не выводит ничего, программы, определяющие ASSIGN (SysInfo) также
     опознают Substituted Disk. Еще одно замечание: при переприсвоении
     с/на гибкие диски дискета должна быть в дисководе,  т.к.  к  нему
     будет сделано обращение на чтение.
     ! Указанное в этой ремарке справедливо только для DR-DOS.
**********************************************************************
}

type IOCTLDriveType  =
     (F360k,F1M2,F720k,F_SD8i,F_DD8i,FixedDisk,TapeDrv,F1M44,
      Optical_RW,F2M88,UnKnownFloppy);

{ Типы дисковых устройств, возвращаемых функцией GetIOCTLDriveType
      -----------------------------------------------------------
      |        ТИП        |        спецификация       | размер, |
      |                   |                           | дюймы   |
      |-------------------+---------------------------+---------|
      |  F360k            | 320k/360k устройство      |    5    |
      |  F1M2             | 1.2M                      |    5    |
      |  F720k            | 720k                      |    3    |
      |  F_SD8i           | устр. одинарной плотности |    8    |
      |  F_DD8i           | устр. двойной   плотности |    8    |
      |  FixedDisk        | жесткий диск              |    -    |
      |  TapeDrv          | лента                     |    -    |
      |  F1M44            | 1.44M (DOS 3.30+)         |    3    |
      |  Optical_RW       | оптический диск чт/зап    |    -    |
      |  F2M88            | 2.88M (DOS 5.0+)          |    3    |
      |  UnKnownFloppy    | неизвестное устройство    |    -    |
      ----------------------------------------------------------- }

type BootType = (_NoBootDisk, _BootDisk, _IllegalHDisk);

type DriverName = string[8];

const MaxSectorSize = 1024;

const SmartDev : DriverName = 'SMARTAAR';       { MS-DOS Cache driver }
const PCkwikDev: DriverName = 'PCKXXXX0';       { DR-DOS Cache driver }
const F_DefDev : DriverName = 'F_Defend';       { Read/Only file protector }

const PhantomMessage : pointer = nil;
    (*  указатель на процедуру, дающую запрос на подготовку диска,
        например "Insert disk in drive B: and press any key..."
        процедура должна быть FAR и описана (имя можно любое):
        {$F+} procedure MsgProc(Disk : char); {$F-}
    *)
const
  { типы разделов винчестеров }
  UnUsed = $00; Dos12  = $01;
  XENIX  = $02; XENIX_U = $03;
  Dos16  = $04; DosExt = $05; BigDos = $06;
  HPFS    = $07;
  Split_AIXBoot = $08; AIX_DATA = $09;
  DM     = $50; DM_    = $51;
  GB     = $56; SpeedStor = $61;
  _386_ix= $63; Net286 = $64; Net386 = $65;
  PCIX   = $75; Minix_1= $80; ADM_Minix= $81;
  DRDos12= $C1; DRDos16= $C4; DRDosExt=$C5; DRBigDos=$C6;
  CP_M   = $DB; SpeedStor12E = $E1; SpeedStor16E = $E4;
  BBT    = $FF;

type HDPartition = UnUsed..BBT;

type OS_type = (_MSDOS,_DRDOS,_OS2);

type StatusHandler = (HNoInst, HEnabled, HDisabled);

type DriverSetting = (D_UnKnown,       {не определено- неверная версия DOS }
                      D_OkToInstall,   {не установлен, но может быть уст.  }
                      D_NotOkToInstall,{не установлен и не может быть уст. }
                      D_Installed);    {установлен                         }

type
{ взято из TPDOS (Turbo Professional) }
    ParamBlock =
      record
        DriveNumber, DeviceDriverUnit : Byte;
        BytesPerSector : Word;
        SectorsPerCluster, ShiftFactor : Byte;
        ReservedBootSectors : Word;
        FatCopies : Byte;
        RootDirEntries, FirstDataSector, HighestCluster : Word;
        SectorsPerFat : Byte;
        RootDirStartingSector : Word;
        DeviceDriverAddress : Pointer;
        Media2and3 : Byte; {media descriptor here in DOS 2.x and 3.x}
        Media4 : Byte;     {media descriptor here in DOS 4.x}
        NextDeviceParamBlock : Pointer;
      end;

type BootRec = record                     { формат записи Boot - сектора    }
      JmpInstr   : byte;                  {+00h  1 инструкция JMP           }
      NearOffs   : word;                  {+01h  2 NEAR-смещение для инстр. }
      CoLabel    : array[1..8] of char;   {+03h  8 неисп. метка фирмы       }
      BytePerSec : word;                  {+0Bh  2 байт в секторе           }
      SecPerClust: byte;                  {+0Dh  1 секторов в кластере      }
      ResSect    : word;                  {+0Eh  2 резевн. сект. перед 1 FAT}
      FatCnt     : byte;                  {+10h  1 число FAT                }
      RootSize   : word;                  {+11h  2 число 20h записей в ROOT }
      TotSecs    : word;                  {+13h  2 секторов на диске        }
      Media      : byte;                  {+15h  1 Media-дескриптор         }
      SecPerFAT  : word;                  {+16h  2 секторов в одной FAT     }
      SecPerTrk  : word;                  {+18h  2 секторов на дорожку      }
      HeadCnt    : word;                  {+1Ah  2 число головок (поверхн.) }
      HidnSec    : word;                  {+1Bh  2 спрятанных секторов      }
      Proc       : array[1..482] of byte; {+1Eh 482 код загрузки            }
                                          { ------------ }
                                          {   512 bytes  }
     end; {type BootRec}
type
     DirEntry = record
      Name : array[0..7] of char; {+00h 8б, имя файла, дополнено пробелами }
      Ext  : array[0..2] of char; {+08h 3б, расширение,дополнено пробелами }
      Attr : byte;                {+0Bh 1б, атрибут файла см.модуль DOS(TP)}

   { зарезервировано в MS-DOS поле размером 10 байт, заполнено символом #0.}
                                  {+0Ch 0Ah б}
   { Для DR-DOS поля расписаны подробнее (использует резевн. область:      }
      R0   : byte;                {+0Ch 1б, обычно 0                       }
      RFcr : char;                {+0Dh 1б, первый символ имени, сохраненный
                                            при стирании файла в DR-DOS,
                                            используется UNDELETE          }
      RPass: word;                {+0Eh 2б, CRC закрывающего пароля        }
      Resv : array[0..3] of byte; {+10h 4б, нули                           }
      RPAtt: word;                {+14h 2б, атрибут защиты DR-DOS:
                                            помните,что в памяти (и на диске)
                                            слово хранится Lo,Hi а мы пишем
                                            Hi,Lo байты соответственно.
                                            0000h - открыт
                                            0111h - запрещено удаление.
                                            0555h - запрещено изменение.
                                            0DDDh - запрещен доступ.       }
      Time : word;                {+16h 2б, время создания/посл. модификации
                                            в формате FileTime             }
      Date : word;                {+18h 2б, дата ---"---"---"---"---"---"  }
      ClstNo:word;                {+1Ah 2б, номер начального кластера (FAT)}
      Size : LongInt;             {+1Ch 4б, размер файла, для DIR, VOL = 0 }
                                  {----------------------------------------}
                                  { 20h bytes                              }

     end; {type DirEntry}

type HDPartRec = record
      BootFlag  : byte;           {+00h 1б, флаг загр.: 80h-активен, 0-нет }
      BegPartHd : byte;           {+01h 1б, начало раздела, номер головки  }
      BegSecCyl : word;           {+02h 2б, --"-- сектор/цилиндр корн.сект.
                                   младшие 6 бит-сектор, остальное-цилиндр }
      SysID     : byte;           {+04h 1б, код системы, см. HDPartition   }
      EndPartHd : byte;           {+05h 1б, конец  раздела, номер головки  }
      EndSecCyl : word;           {+06h 2б, --"-- сектор/цилиндр корн.сект.
                                   младшие 6 бит-сектор, остальное-цилиндр }
      BegSec    : LongInt;        {+08h 4б, относит. номер начального сект.}
      PartSize  : LongInt;        {+0Ch 4б, размер (число секторов)        }
     end; {type HDPartRec}

const

    MaxDiskCount = 26;
    { Максимально можем задавать 26 имен дисков (A..Z) }

const
    ListOfList : pointer = nil;
    { список списков DOS }
    ListOfCDS  : pointer = nil;
    { список каталогов DOS }
    SizeOfCDS  : byte    = 0;
    { размер одного блока "структуры текущего каталога" DOS }
const
    DskToolsVarInit : boolean = FALSE;
    {TRUE, если массивы типов уже инициализированы }

const
   OS_Version    : word = 0;
{ Т.к. DR-DOS возвращает номер версии 3.31, при загрузке в DR-DOS
  в этой переменной переменной будет находиться  настоящий  номер
  версии системы, это же относится и к OS/2.  В  старшем  байте -
  главный номер версии, в младшем - десятичная часть.
  ТОЛЬКО ДЛЯ ЧТЕНИЯ ! НЕ ИЗМЕНЯТЬ ! }

VAR
   DOS_Version   : word;
{ В этой переменной находится номер версии DOS, даже если установлен
  драйвер SetVet, будет находиться настоящий номер версии.
  В старшем байте находится главный номер, в младшем - субномер
  ТОЛЬКО ДЛЯ ЧТЕНИЯ ! НЕ ИЗМЕНЯТЬ ! }

    Current_OS          : OS_type;
    { тип текущей операционной системы
      ТОЛЬКО ДЛЯ ЧТЕНИЯ ! НЕ ИЗМЕНЯТЬ ! }

VAR
    INT11Dat      : Word absolute $0:$0410;
    { статус системы - слово, возвращаемое прерыванием 11h см. [1] }

    PhantomB      : byte absolute $0:$0504; { см. [1] BIOS Data }

VAR
    NumHardDisk   : byte absolute $0:$0475;

CONST
    LastDisk  : BYTE = 0;
    { номер последнего дискового устройства, доступного системе }

    NumFloppy : BYTE = 0;
    { количество накопителей для гибких дисков }

    NumDrive  : BYTE = 0;
    { Количество доступных логических дисковых устройств
      (записаны в DiskNameArray) }

VAR
    DiskNameArray       : array [1..MaxDiskCount] of Char;
                { Массив имен доступных дисков, расположенных в
                  алфавитном порядке, допустимо к использованию
                  NumDrive первых байт массива }

VAR
    AssignToChar        : array [1..MaxDiskCount] of Char;
                { Список дисковых имен, к которым  направляются
                  запросы чтения/записи }

VAR
    DiskTypeArray       : array [1..MaxDiskCount] of DiskClass;
                { Массив характеристик дисковых устройств }

VAR
    AMore32MDisk        : array [1..MaxDiskCount] of boolean;
                { Массив флагов, которые устанавливаются только для HD }
                { индикация превышения 32M предела. }

VAR
    AssignToType        : array [1..MaxDiskCount] of DiskClass;
                { Диск переназначен на диск типа ... }

VAR
   _DRIVE : BYTE;
{$IFDEF BZdetaily}
   _HEAD  : BYTE;
   _TRACK : word;
   _SECTOR: BYTE;
{$ENDIF}
   PartMore32M : boolean;

{ ----------- функции/процедуры, контроля статуса устройств ------------ }

function  AIsActingAsB : boolean;
{ Возвращает TRUE при наличии в системе 1 floppy - устройства и
  определенном как диск B: (обычно диск A:) }

function LastDrive : byte;
{ Возвращает номер последнего допустимого устройства в системе }

function LastDriveChar : char;
{ Возвращает имя последнего допустимого устройства в системе,
  аналог функции NumberOfDrives в системе Turbo Professional [1] [3] }

function CurrentDrive : byte;
{ Возвращает номер текущего диска A=0, B=1, C=2 ... [1] }

function CurrentDriveChar : char;
{ Возвращает текущий диск }

procedure SetDrive ( Disk : char);
{ Устанавливает активный диск }

function AvailableDisk (Disk : char) : boolean;
{ возвращает TRUE, если устройство с именем Disk доступно }

procedure GetAppendStr (var path: string);
{ возвращает строку "пути", исп. программой APPEND, при отсутствии
  таковой или пустой строке возвращает пустую строку ('') }
  
function SubstitutedTo (Disk : char) : string;
{ указывает путь, к которому ведется обращение как к диску }

function GetJoinPath (Disk : char) : string;
{ возвращает строку пути JOIN для указанного устройства, '' если не уст. }

procedure SafeSetDisk (Disk : char);
{ устанавливает текущим диск без запроса для фантомных "Insert disk in..." }

function PhantomDisk (Disk : char) : boolean;
{ указанный диск фантомный? }

function PhantomAppeal (Disk : char) : char;
{ указывает, к какому физическому устройству обращается фантомный диск }

procedure IgnoreDiskQuest (Disk : char);
{ при обращении к фантомному диску подавляет вывод сообщения }
{ "Insert disk in...", необходимо вызывать перед каждым обращением }
{ к фантомному диску }

function SearchDriverName(Name : DriverName) : boolean;
{ ищет указанное имя в цепочке драйверов }

function BootDisk : byte;
{ 0-unknown, 1-A... возвращает системный диск, в DOS 4.0+ }

{ ----------- проц/функц выдачи статуса установки драйверов ---------- }

function AssignStatus : DriverSetting;
{ выдает статус ASSIGN }

function DriverSysStatus : DriverSetting;
{ выдает статус DRIVER.SYS }

function DiskReetInstalled : boolean;
{ возвращает TRUE, если установлен DiskReet.sys из Norton Utilities. }

function DiskMonInstalled : boolean;
{ возвращает TRUE, если установлен DiskMon из Norton Utilities. }

function FileSaveInstalled : boolean;
{ возвращает TRUE, если установлен FileSave (5.x) или EP (6.x+) }
{ из Norton Utilities. }

function EgaDiskInstalled : boolean;
{ возвращает TRUE, если установлен EgaDisk }

function Drv800Installed : boolean;
{ возвращает TRUE, если установлен драйвер дисководов 800.COM }
{ * 800 II * V1.xx+ * Diskette BIOS Enhancer * Alberto PASQUALE (ITALY) * }

function CacheActive : boolean;
{ суммарное определение активности кэш - драйверов }

function NCacheInstalled : boolean;
{ дисковый кэш NCACHE }

function SmartDriveInstalled : boolean;
{ дисковый кэш SMARTDRV.SYS (MS-DOS),
  PCkwik for WINDOWS - PCkwin.sys (DR-DOS) }

function PckwikInstalled : boolean;
{ дисковый кэш PCkwik.sys (DR-DOS) }

function IBMCacheInstalled : boolean;
{ дисковый кэш IBM }

function QCacheInstalled : boolean;
{ дисковый кэш Qualitas }

function CompaqCacheInstalled : boolean;
{ Compaq System Pro - Cache controller status }

function HyperDiskInstalled : boolean;
{ disk cache by HyperWare (Roger Cross) }

function PC_CacheInstalled : boolean;
{ PC-Cache  Central Point Software, Inc. }

function F_DefenderInstalled : boolean;
{ защита файлов с атрибутами READ/ONLY }

{ --------------------------- сервис ---------------------------------- }

function SearchStr(Var Block; Size : word; Pos_: WORD; Sign : string) : word;
{ поиск строки в памяти по смещению }

function UpCaseFileName (var Name : string) : boolean;
{ переводит маленькие буквы в большие для имени файла
  используя таблицу символов DOS. Работает в DOS 3.30+.
  Возвращает TRUE при безошибочном выполнении.
}

function GetVolumeLabel(Disk : char; var Name : string) : word;
{ возвращает метку тома указанного диска, пусто при отсутствии,
  будьте осторожны при обращении к сжимающим дискам! (SUPERSTOR,STACKER...)
}

function SetVolumeLabel(Disk : char; Name : string) : word;
{ устанавливает метку тома на указанное устройство, допустимы любые
  символы, кроме #0. Возвращает код ошибки, FFFF если нет места для метки,
  0 - если все в порядке
  будьте осторожны при обращении к сжимающим дискам! (SUPERSTOR,STACKER...)
}

procedure CloneReadSector(DISK : BYTE; FirstSec : word);
{ Имитирует чтение сектора (одного), используется для проверки
  принадлежности логического диска физическому.
  ДЛЯ ВНУТРЕННЕГО ИСПОЛЬЗОВАНИЯ ! Если Вы хотите использовать эту
  процедуру, внимательно разберитесь в принципе работы !
}

procedure DisableDrive(Disk : char);
{ запрещает устройство }

procedure EnableDrive(Disk : char);
{ разрешает устройство }

{ ---------------------- проц/функц инициализации --------------------- }

procedure AssignArrayInit;
{ инициирует массив имен дисков, образованных ASSIGN }

procedure FloppyDetected;
{   Тестирует наличие в системе floppy - устройств и устанавливает пере-
  менную NumFloppy }

procedure DiskInit;
{   Заполняет массив разрешенных имен DiskNameArray,  вызов  вставлен  в
  секцию инициализации, вызов этой процедуры может Вам понадобиться пос-
  ле выхода в OS Shell, т.к. могут вызываться программы  SUBST,
  может быть произведен переход с диска A:  на  B:  при  наличии  одного
  floppy - дисковода. Структура массива очень простая, как у Пети Норто-
  на в Norton Commander (v1.0 - ds:ADD8h; v3.0 - ds:6A72h -у него запол-
  няется только при вызове функции списка дисков!), Нортон  вызывает по-
  добную процедуру непосредственно перед построением окна выбора дисков.
}

procedure ReadDiskType;
{ Заполняет массив DiskTypeArray }

function GetDiskType(disk : char) : DiskClass;
{ Выдает тип указанного устройства (исключая ASSIGNED, см. ниже) }

function GetIOCTLDriveType (Disk : char) : IOCTLDriveType;
{ возвращает тип дисковода }

procedure InitDiskVariable;
{ Выполняет вызов всех процедур инициализации таблиц }

Implementation

{------------------------------------------------------------------------}
const
   DiskReetInst : boolean = false;
   EgaDiskInst  : boolean = false;

var
   MyINT13hVec : pointer;
   Ver    : word;

function SearchStr(Var Block; Size : word; Pos_: WORD; Sign : string) : word;
assembler;
{ Block - блок памяти, имя переменной или что-либо, нужен только }
{ адрес и размер (FFF0 max) , в строке - что искать, возвращает  }
{ смещение, если найдено или FFFF - если нет. POS_ - начинать    }
{ поиск по смещению...0 - сначала (например, продолжить поиск)   }
asm
        PUSH    DS           { сохраняем, т.к. будут изменены }
        PUSH    ES
        LES     DI, Block    { адрес блока, в котором искать }
        MOV     AX, DI
        MOV     BX, ES       { нормализуем указатель, если можно...}
        SHR     AX, 1
        SHR     AX, 1
        SHR     AX, 1
        SHR     AX, 1
        ADD     BX, AX
        JC      @NOADD
        MOV     ES, BX
        AND     DI, 000Fh
@NOADD:
        MOV     CX, WORD PTR Size  { размер блока }
        CMP     CX, WORD PTR POS_  { позиция начала поиска за }
        JBE     @NO                { пределами блока? }
        SUB     CX, WORD PTR POS_  { искать осталось уже меньше...}
        ADD     DI, WORD PTR POS_  { и начинать надо дальше...}
        LDS     SI, Sign           { нормализовать не будем, т.к.    }
        XOR     AH, AH             { вероятность выхода за FFFF мала }
        MOV     AL, BYTE PTR [SI]  { длина строки }
        CMP     AX, CX             { искать больше, чем где...? }
        JA      @NO
        SUB     CX, AX             { из длины буфера исключаем длину строки }
        INC     CX
        INC     SI
        MOV     AL, BYTE PTR [SI]  { искать первый символ }
        INC     SI                 { SI указывает на второй }
@SCAN:
        CLD
  REPNE SCASB                      { сканировать вперед }
        JNE     @NO
        CMP     BYTE PTR [SI-2], 1 { для поиска задана строка в 1 байт? }
        JE      @YES
        XOR     BX, BX             { смещение от текущего положения DI и SI }
        MOV     DH, BYTE PTR [SI-2]
        DEC     DH
        DEC     DH
@LOOP:                             { сравниваем следующие байты }
        MOV     DL, BYTE PTR ES:[DI+BX]
        CMP     DL, BYTE PTR [SI+BX]
        JE      @CONT
        OR      CX, CX
        JZ      @NO
        JMP     @SCAN
@CONT:
        CMP     BL, DH
        JE      @YES
        INC     BX
        JMP     @LOOP
@YES:
        MOV     AX, DI
        MOV     BX, WORD PTR Block
        AND     BX, 000Fh
        SUB     AX, BX
        DEC     AX
        JMP     @QUIT
@NO:
        MOV     AX, 0FFFFh
@QUIT:
        POP     ES
        POP     DS
end;

function SearchDriverName(Name : DriverName) : boolean; assembler;
{ ищет драйвер устройства с заданным именем, кроме NUL - }
{ С НЕГО НАЧИНАЕТСЯ ПОИСК }
asm
        CMP     BYTE PTR VER, 1
        JE      @NO
        CMP     BYTE PTR VER, 2 { DOS 2.x }
        JE      @1
        CMP     WORD PTR VER, 3 { DOS 3.0 }
        JE      @2
        MOV     DX, 22h
        JMP     @3
@1:
        MOV     DX, 17h
        JMP     @3
@2:
        MOV     DX, 28h
@3:
        PUSH    DS                         { List of list }
        PUSH    BP
        MOV     AX, 5200h
        INT     21h
        POP     BP
        POP     DS
        ADD     BX, DX                     { цепочка драйверов }
        MOV     DI, BX
@REPEAT:
        PUSH    DS
        LDS     SI, Name
        MOV     CL, BYTE PTR [SI]
        XOR     CH, CH
        INC     SI
        ADD     DI, 0Ah
        CLD
   REPE CMPSB                            { сравнение строк }
        POP     DS
        JZ      @OK
        MOV     AX, ES:[BX+2]
        MOV     BX, ES:[BX]
        MOV     DI, BX
        MOV     ES, AX
        CMP     DI, 0FFFFh
        JE      @NO
        JMP     @REPEAT
@OK:
        MOV     AX, 1       { TRUE }
        JMP     @QUIT
@NO:
        XOR     AX, AX      { FALSE }
@QUIT:
end;

function UpCaseFileName (var Name : string) : boolean; assembler;
{ переводит маленькие буквы в большие для имени файла
  используя таблицу символов DOS. Работает в DOS 3.30+.
  Возвращает TRUE при безошибочном выполнении.
}
var BUF : ARRAY[0..$30] OF BYTE;
asm
        PUSHF
        PUSH    DS
        PUSH    ES
        PUSH    DX
        PUSH    DI
        PUSH    BX
        LES     DI, NAME
        CMP     BYTE PTR ES:[DI], 0
        JE      @OK
        CMP     DOS_Version, 31Eh
        JB      @ERROR              { > неверная версия DOS }
        MOV     AX, 6504h           { * дать указатель на таблицу перевода }
        MOV     BX, 0FFFFh          { * символов имени файла }
        MOV     DX, BX
        MOV     CX, SS
        MOV     ES, CX
  SEGES LEA     DI, BUF
        MOV     CX, 5
        INT     21h
        JC      @ERROR              { > ошибка }
        CMP     CX, 5
        JA      @ERROR              { > несовпадение длины буфера }
        LDS     BX, DWORD PTR ES:[DI+1]
        CMP     WORD PTR [BX], 80h
        JNE     @ERROR              { > несовпадение длины таблицы }
        ADD     BX, 2
        LES     DI, NAME
        MOV     CL, BYTE PTR ES:[DI]
        XOR     CH, CH
        INC     DI
        SUB     BX, 80h
@LOC:
        MOV     AL, BYTE PTR ES:[DI]
        CMP     AL, 80h
        JB      @EN
        XLAT                          { код символа > 128 }
        MOV     BYTE PTR ES:[DI], AL
        JMP     @CONT
@EN:
        CMP     AL, 61h
        JB      @CONT
        CMP     AL, 7Ah               { a..z }
        JA      @CONT
        AND     AL, 5Fh
        MOV     BYTE PTR ES:[DI], AL
@CONT:
        INC     DI
        LOOP    @LOC
@OK:
        MOV     AX, 1               
        JMP     @QUIT
@ERROR:
        XOR     AX, AX
@QUIT:
        POP     BX
        POP     DI
        POP     DX
        POP     ES
        POP     DS
        POPF
end; { func UpCaseFileName }

function  AIsActingAsB : boolean;
begin
  AIsActingAsB := PhantomB = $01;
  { В переменных BIOS содержится информация о текущем назначении
    дисковода - как A: или как B: }
end;

procedure FloppyDetected; assembler;
{ Определяет число накопителей гибких дисков и устанавливает NumFloppy
  имеется ввиду физически существующих, не переприсвоенных драйверами
  и не фантомных }
asm
        PUSH    ES
        XOR     AX, AX
        MOV     ES, AX
        MOV     BX, 0410h
        MOV     AX, ES:[BX]             {INT11Dat}
        TEST    AX, 1
        JZ      @NoFloppy
        AND     AX, 00C0h
        JZ      @OneFDisk
        CMP     AX, 0040h
        JE      @TwoFDisk
        CMP     AX, 0080h
        JE      @ThreeFDisk
        CMP     AX, 00C0h
        JE      @FourFDisk
@NoFloppy:
        MOV     BYTE PTR NumFloppy, 0        { иначе пусть будет 0 }
        JMP     @QUIT
@OneFDisk:
        MOV     BYTE PTR NumFloppy, 1
        JMP     @QUIT
@TwoFDisk:
        MOV     BYTE PTR NumFloppy, 2
        JMP     @QUIT
@ThreeFDisk:
        MOV     BYTE PTR NumFloppy, 3  { ,что бывает о-очень редко,
                                       ну о-очень... бывает на мини-AT
                                       с двумя 3" дисками, когда к ним
                                       подключают внешний 5"  дисковод,
                                       но надо попробовать... }
        JMP     @QUIT
@FourFDisk:
        MOV     BYTE PTR NumFloppy, 4
                                { а такой конфигурации я вооще не видел }
@QUIT:
        POP     ES
        { не  путайте  диски, установленные в  системе  физически  и }
        { переопределенные   драйвером,  т.е. в массиве типов  может }
        { быть указано несколько устройств с  типом  Floppy,  а  эта }
        { функция   возвратит   количество  физически  установленных }
        { устройств. }
end; {proc FloppyDetected;}

function SubstitutedTo (Disk : char) : string; assembler;
{ указывает, к какому каталогу переприсвоено обращение }
asm
        PUSH    DS
        MOV     DL, BYTE PTR DISK
        AND     DX, 1Fh
        DEC     DX
        MOV     AL, SizeOfCDS
        MUL     DL
        LDS     SI, DWORD PTR ListOfCDS
        ADD     SI, AX                  { ES:DI - CDS of Disk }
        LES     DI, @Result
        MOV     BX, DI
        XOR     CX, CX
        TEST    BYTE PTR [SI+44h], 10h
        JZ      @NO
        MOV     CL, [SI+4Fh]
        MOV     AL, CL
        CLD
        INC     DI
    REP MOVSB
        MOV     CL, AL
@NO:
        MOV     BYTE PTR ES:[BX], CL
@QUIT:
        POP     DS
end; { func SubstitutedTo }

function GetJoinPath (Disk : char) : string; assembler;
{ возвращает строку пути JOIN для указанного устройства, '' если не уст. }
asm
        PUSH    DS
        MOV     DL, BYTE PTR DISK
        AND     DX, 1Fh
        DEC     DX
        MOV     AL, SizeOfCDS
        MUL     DL
        LDS     SI, DWORD PTR ListOfCDS
        ADD     SI, AX                  { ES:DI - CDS of Disk }
        LES     DI, @Result
        MOV     BX, DI
        XOR     CX, CX
        TEST    BYTE PTR [SI+44h], 20h
        JZ      @NO
        CLD
        INC     DI
@LOOP:
        LODSB
        OR      AL, AL
        JZ      @ENDLOOP
        STOSB
        INC     CX
        JMP     @LOOP
@ENDLOOP:
@NO:
        MOV     BYTE PTR ES:[BX], CL
@QUIT:
        POP     DS
end; { func GetJoinPath }

procedure SafeSetDisk (Disk : char); assembler;
{ Используйте эту процедуру для того, чтобы DOS опускала вывод запроса
  на подготовку диска и нажатие клавиши. Это очень некрасиво смотрится
  в некоторых программах, включая  широко известный  Norton  Commander
  ( для проверки попробуйте скопировать что-либо на диск B: на  машине
  с одним дисководом). Красиво эта проблема решена в Turbo Pascal 6.0.}
asm
        CMP     DOS_Version, 314h     { если не та версия DOS - будет }
        JB      @SET                  { выведено сообщение DOS,  если }
        MOV     AL, Disk              { диск фантомный }
        XOR     AH, AH
        PUSH    AX
        CALL    PhantomDisk           { диск Фантомный ? }
        OR      AL, AL                    
        JZ      @SET
        CMP     WORD PTR PHANTOMMESSAGE, 0    { Да! }
        JNE     @MSG
        CMP     WORD PTR PHANTOMMESSAGE+2, 0
        JE      @CONT
@MSG:                                     { Вызвать процедуру пользователя, }
        CALL    DWORD PTR PHANTOMMESSAGE  { если ее адрес не NIL }
@CONT:
        MOV     BL, BYTE PTR Disk         
        AND     BX, 01Fh
        MOV     AX, 440Fh
        INT     21h                       { сбросить вывод сообщения }
@SET:
        MOV     DL, BYTE PTR Disk
        AND     DX, 001Fh                 { Переводим символ в номер }
        DEC     DX                        { функция 0Eh DOS устанавливает }
        MOV     AX, 0E00h                 { текущий диск }
        INT     21h
end; { proc SafeSetDisk }

function PhantomDisk (Disk : char) : boolean; assembler;
asm
        PUSH    ES
        PUSH    BX
        AND     BYTE PTR Disk, 5Fh
        CMP     DOS_Version, 314h   { DOS позволяет определить }
        JB      @DV                 { фантомный ли диск ? }
        MOV     BL, BYTE PTR Disk
        AND     BX, 01Fh
        MOV     AX, 440Eh           { Диск фантомный ? }
        INT     21h
        JC      @DV
        OR      AL, AL
        JZ      @NO
        MOV     BL, BYTE PTR Disk
        AND     BX, 01Fh
        CMP     AL, BL
        JE      @NO
        JMP     @YES
@DV:
        CALL    FloppyDetected
        CMP     NumFloppy, 0
        JE      @NO
        CMP     NumFloppy, 1
        JA      @NO
        XOR     AX, AX
        MOV     ES, AX
        MOV     BX, 0504h
        CMP     BYTE PTR Disk, 'A'
        JE      @TEST_A
        CMP     BYTE PTR Disk, 'B'
        JNE     @NO
        CMP     BYTE PTR ES:[BX], 1        { Phantom B }
        JE      @YES
        JMP     @NO
@TEST_A:
        CMP     BYTE PTR ES:[BX], 1        { Phantom A }
        JE      @NO
@YES:
        MOV     AX, 1
        JMP     @QUIT
@NO:
        XOR     AX, AX
@QUIT:
        POP     BX
        POP     ES
end; { func PhantomDisk }

function PhantomAppeal (Disk : char) : char; assembler;
asm
        CMP     Dos_Version, 314h    { Версия DOS ok ? }
        JB      @NO
        MOV     BL, BYTE PTR Disk
        AND     BX, 01Fh
        MOV     AX, 440Eh
        INT     21h                  { Диск фантомный ? }
        JC      @SELF
        OR      AL, AL
        JZ      @SELF                { устройству присвоена одна буква ? }
        MOV     BL, BYTE PTR Disk
        AND     BX, 01Fh
        CMP     AL, BL               { имена совпадают ? }
        JE      @SELF
        XOR     AH, AH
        ADD     AX, 40h              { имя диска, к которому обращается }
        JMP     @QUIT                { драйвер фантомного }
@SELF:
        MOV     AL, BYTE PTR Disk
        JMP     @QUIT
@NO:
        XOR     AX, AX               { нельзя установить имя ... }
@QUIT:
end; { func PhantomAppeal }

procedure IgnoreDiskQuest (Disk : char); assembler;
asm
        CMP     DOS_Version, 314h
        JB      @QUIT
        MOV     BL, BYTE PTR Disk
        AND     BX, 01Fh
        MOV     AX, 440Fh
        INT     21h                 { сбросить запрос на подготовку диска }
@QUIT:
end; { proc IgnoreDiskQuest }

{!!! *******************************************************************
    Пpи написании процедур, работающих с дисками, надо  следить  за вер-
  ностью номера устройства, т.к. для некоторых  функций  0 -  устройство
  A:, для других - текущее }

function AssignStatus : DriverSetting; assembler;
{ выдает статус ASSIGN }
{
INT 2F - DOS v3.0+ ASSIGN - INSTALLATION CHECK
	AX = 0600h
Return: AL = status
	    00h not installed
	    01h not installed, but not OK to install
	    FFh installed
Note:	ASSIGN is not a TSR in DR-DOS 5.0; it is internally replaced by SUBST
	  (see INT 21/AX=2152h)
SeeAlso: AX=0601h,INT 21/AX=2152h
}
asm
        CMP     DOS_Version, 300h
        JB      @NOKN
        CMP     Current_OS, _DRDOS
        JE      @NOKN
        MOV     AX, 0600h
        INT     2Fh
        CMP     AL, 0
        JE      @1
        CMP     AL, 1
        JE      @2
        CMP     AL, 0FFh
        JE      @3
@NOKN:
        MOV     AX, D_UnKnown
        JMP     @QUIT
@1:
        MOV     AX, D_OkToInstall
        JMP     @QUIT
@2:
        MOV     AX, D_NotOkToInstall
        JMP     @QUIT
@3:
        MOV     AX, D_Installed
@QUIT:
end; { func AssignStatus }

function DriverSysStatus : DriverSetting; assembler;
{ выдает статус DRIVER.SYS }
{
INT 2F U - DRIVER.SYS support - INSTALLATION CHECK
	AX = 0800h
Return:	AL = 00h not installed, OK to install
	     01h not installed, not OK to install
	     FFh installed
Note:	supported by DR-DOS 5.0
См.также INT 2F/ AX = 0801h, 0802h, 0803h.
}
asm
        CMP     DOS_Version, 300h
        JB      @NOKN
        MOV     AX, 0800h
        INT     2Fh
        CMP     AL, 0
        JE      @1
        CMP     AL, 1
        JE      @2
        CMP     AL, 0FFh
        JE      @3
@NOKN:
        MOV     AX, D_UnKnown
        JMP     @QUIT
@1:
        MOV     AX, D_OkToInstall
        JMP     @QUIT
@2:
        MOV     AX, D_NotOkToInstall
        JMP     @QUIT
@3:
        MOV     AX, D_Installed
@QUIT:
end; { func DriverSysStatus }

function DiskReetInstalled : boolean; assembler;
{ тестировалась с DiskReet версии 6.01 }
asm
        MOV     AX, 0FE00h
        MOV     DI, 'NU'
        MOV     SI, 'DC'
        INT     2Fh
        CMP     SI, 'dc'
        JE      @INSTALLED
        XOR     AX, AX
        JMP     @QUIT
@INSTALLED:
        MOV     AX, 1    { отмечу, что в CX:AX содержится  адрес        }
                         { резидентной части DISKREET, его можно        }
                         { открывать как символьное устройство @DSKREET }
@QUIT:
end; { func DiskReetInstalled }

function DiskMonInstalled : boolean; assembler;
{ возвращает TRUE, если установлен DiskMon из Norton Utilities. }
asm
        MOV     AX, 0FE00h
        MOV     DI, 'NU'
        MOV     SI, 'DM'
        INT     2Fh           { CX - сегмент резидентной части }
        CMP     SI, 'dm'
        JE      @INSTALLED
        XOR     AX, AX
        JMP     @QUIT
@INSTALLED:
        MOV     AX, 1
@QUIT:
end; { func DiskMonInstalled }

function FileSaveInstalled : boolean; assembler;
{ возвращает TRUE, если установлен FileSave (5.x) или EP (6.x+) }
{ из Norton Utilities. }
asm
        MOV     AX, 0FE00h
        MOV     DI, 'NU'
        MOV     SI, 'FS'
        INT     2Fh           { CX - сегмент резидентной части }
        CMP     SI, 'fs'
        JE      @INSTALLED
        XOR     AX, AX
        JMP     @QUIT
@INSTALLED:
        MOV     AX, 1
@QUIT:
end; { func FileSaveInstalled }

function EgaDiskInstalled : boolean; assembler;
{ работа проводилась с EGADISK.EXE версии 4.00 }
{ P. Tsarebko (C) 1990. }
asm
        MOV     AX, 0EE00h
        INT     10h
        CMP     AH, 11h  { not 0EEh }
        JNE     @NO
        { В AL содержится тип установки : 0- из CONFIG, 1- EXE}
        { в BX - сегмент CS резидентной части }
        MOV     AX, 1
        JMP     @QUIT
@NO:
        XOR     AX, AX
@QUIT:
end; { func EgaDiskInstalled }

function Drv800Installed : boolean; assembler;
{ тестировалась с 800 [h] II версий 1.40, 1.68 и 1.80}
{ (C) Alberto Pasquale }
asm
        MOV     AH, 18h
        XOR     DL, DL
        MOV     CX, 0FEDCh
        INT     13h
        CMP     AX, 0BA98h
        JNE     @NO
        MOV     AX, 1
        JMP     @QUIT
@NO:
        XOR     AX, AX
@QUIT:
end; { func Drv800Installed }

function F_DefenderInstalled : boolean; assembler;
asm
        PUSH    DS
        MOV     AX, OFFSET F_DefDev
        PUSH    AX
        CALL    SearchDriverName
end; { func F_DefenderInstalled }

function SmartDriveInstalled : boolean; assembler;
asm
        PUSH    DS
        MOV     AX, OFFSET SmartDev
        PUSH    AX
        CALL    SearchDriverName
end; { func SmartDriveInstalled }

function PckwikInstalled : boolean; assembler;
asm
        PUSH    DS
        MOV     AX, OFFSET PCkwikDev
        PUSH    AX
        CALL    SearchDriverName
end; { func PckwikInstalled }

function NCacheInstalled : boolean; assembler;
asm
        MOV     AX, 0FE00h      { NCache   6.0x }
        XOR     CX, CX          { NCache-F 5.0x }
        MOV     BX, 'NU'
        MOV     SI, 'CF'
        MOV     DI, BX
        STC
        INT     2Fh
        JC      @NO
        CMP     SI, 'cf'
        JNE     @NO
        MOV     AX, 1          { в ES - базовый адрес драйвера }
        JMP     @QUIT          { ES:00 - сам драйвер @CACHE-X  }
@NO:                           { CX - сегмент резидентной части }
        MOV     AX, 0FE00h     
        XOR     CX, CX
        MOV     BX, 'NU'
        MOV     SI, 'CS'       { NCache-S 5.0x }
        MOV     DI, BX
        STC
        INT     2Fh
        JC      @XX
        CMP     SI, 'cs'
        JNE     @XX
        MOV     AX, 1
        JMP     @QUIT
@XX:
        XOR     AX, AX
@QUIT:
end; { func NCacheInstalled }

function IBMCacheInstalled : boolean; assembler;
{ дисковый кэш IBM }
asm
        PUSH    ES
        PUSH    BX
        XOR     DX, DX
        MOV     AX, 1D01h
        CLC
        INT     13h
        JC      @NO
        MOV     AX, 1
        JMP     @QUIT
@NO:
        XOR     AX, AX
@QUIT:
        POP     BX
        POP     ES
end; { func IBMCacheInstalled }

function QCacheInstalled : boolean; assembler;
{ дисковый кэш Qualitas }
asm
        PUSH    BX
        MOV     AX, 2700h
        XOR     BX, BX
        INT     13h
        OR      BX, BX
        JZ      @NO
        MOV     AX, 1
        JMP     @QUIT
@NO:
        XOR     AX, AX
@QUIT:
        POP     BX
end; { func QCacheInstalled }

function CompaqCacheInstalled : boolean; assembler;
{ Compaq System Pro - Cache controller status }
asm
        MOV     AX, 0F400h
        INT     16h
        CMP     AX, 0E201h
        JNE     @NO
        MOV     AX, 1
        JMP     @QUIT
@NO:
        XOR     AX, AX
@QUIT:
end; { func CompaqCacheStatus }

function HyperDiskInstalled : boolean; assembler;
{ disk cache by HyperWare (Roger Cross) v4.20+ }
asm
        MOV     AX, 0DF00h
        MOV     BX, 'DH'
        CLC
        INT     2Fh           { HyperDisk v4.20+ - INSTALLATION CHECK }
                    { BX:DX -> ??? in resident portion if BX=4448h on entry }
        JC      @NO { для DR-DOS }
        CMP     AL, 0FFh
        JNE     @NO
        CMP     CX, 'YH'
        JNE     @NO
        MOV     AX, 1
        JMP     @QUIT
@NO:
        XOR     AX, AX
@QUIT:
end; { func HyperDiskInstalled }

function PC_CacheInstalled : boolean; assembler;
{ PC-Cache }
asm
        MOV     AX, 0FFh
        MOV     SI, 'CX'
        MOV     CX, SP
        PUSH    CX
        INT     25h
        POP     CX
        CMP     CX, SP
        JE      @2
        POP     CX
@2:
        CMP     SI, 'cx'
        JE      @OK
        MOV     AX, 2B00h
        MOV     CX, 'CX'
        INT     21h
        OR      AL, AL
        JNZ     @1
        CMP     CX, 'cx'
        JE      @OK
@1:
        PUSH    ES
        PUSH    DI
        MOV     AX, 0FFA5h
        MOV     CX, 1111h
        INT     16h
        POP     DI
        POP     ES
        CMP     CX, 1
        JE      @OK
        XOR     AX, AX
        JMP     @QUIT
@OK:
        MOV     AX, 1
@QUIT:
end; { func PC_CacheInstalled }

function CacheActive : boolean;
{ суммарное определение активности кэш - драйверов }
begin
CacheActive := NCacheInstalled    or SmartDriveInstalled  or
               QCacheInstalled    or IBMCacheInstalled    or
               PCKwikInstalled    or PC_CacheInstalled    or
               HyperDiskInstalled or CompaqCacheInstalled
end; { func CaheActive }

function BootDisk : byte; assembler;
asm
        CMP     BYTE PTR VER, 4
        JB      @NO
        MOV     AX, 3305h
        CLC
        INT     21h
        JC      @NO
        CMP     AL, 0FFh
        JE      @NO
        MOV     AL, DL
        XOR     AH, AH
        JMP     @QUIT
@NO:
        XOR     AX, AX
@QUIT:
{
   fully reentrant
   NEC 9800-series PCs always call the boot drive A: and assign the other
   drive letters sequentially to the other drives in the system
}
end; { func BootDisk }

function AvailableDisk (Disk : char) : boolean; assembler;
VAR
   Buffer : array [0..2]   of byte;
   FCB    : array [0..$0F] of byte;
asm
        MOV     AX, SS                 { для определения дисков используем }
        PUSH    DS                     { функцию 29 DOS, которая разбирает }
        PUSH    ES                     { имя файла, пpи неверном диске в   }
        MOV     DS, AX
        MOV     ES, AX
        LEA     SI, Buffer             { имени, возвращается ошибка.       }
        LEA     DI, FCB                { Имя формируется в массиве Buffer  }
        MOV     BYTE PTR [SI+1], ':'   { в FCB помещается разобранное имя  }
        MOV     BYTE PTR [SI+2], 0     { Для работы функции подсовываем    }
        MOV     BL, BYTE PTR Disk      { только имя диска                  }
        AND     BX, 05Fh
        MOV     BYTE PTR [SI], bl
        MOV     AX, 2900h              { разбор имени, побочный  эффект -  }
        INT     21h                    { индикация доступности имени диска }
        CMP     AL, 0FFh
        JE      @NOT
        MOV     AX, 1  {true}
        JMP     @QUIT
@NOT:
        XOR     AX, AX {false}
@QUIT:
        POP     ES
        POP     DS
end; { func AvailableDisk }

procedure GetAppendStr (var path: string); assembler;
asm
        LES     DI, PATH
        MOV     BYTE PTR ES:[DI], 0
        CMP     DOS_Version, 300h
        JB      @QUIT                       { неверна версия DOS }
        MOV     AX, 0B700h
        INT     2Fh
        CMP     AL, 0FFh
        JNE     @QUIT                       { APPEND не установлен }
        PUSH    DS
        PUSH    DI
        PUSH    ES
        MOV     AX, 0B704h
        INT     2Fh
        MOV     SI, DI
        MOV     DX, ES
        MOV     CX, 80h
        XOR     AX, AX
        CLD
  REPNE SCASB                               { ищем конец строки }
        JNE     @FULL
        SUB     DI, SI
        DEC     DI
        MOV     CX, DI
        JMP     @MOVE
@FULL:
        MOV     CX, 80h
@MOVE:
        MOV     DS, DX
        POP     ES
        POP     DI
        MOV     BYTE PTR ES:[DI], CL
        INC     DI
    REP MOVSB                               { выдаем значение функции }
        POP     DS
@QUIT:
end; { func GetAppendStr }

function CurrentDrive : byte; assembler;
asm
        MOV     AX, 1900h     { функция 19h DOS возвращает }
        INT     21h           { текущий диск в AL }
        XOR     AH, AH
end; { func CurrentDrive }

function CurrentDriveChar : char; assembler;
asm
        MOV     AX, 1900h     { функция 19h DOS возвращает }
        INT     21h           { текущий диск в AL }
        XOR     AH, AH
        ADD     AX, 41h       { Превратим байт в символ }
end; { func CurrentDriveChar }

procedure SetDrive (Disk : char); assembler;
{ см. SafeSetDisk }
asm
        PUSH    DX
        MOV     DL, BYTE PTR Disk
        AND     DX, 001Fh     { Переводим символ в номер }
        DEC     DX            { функция 0Eh DOS устанавливает }
        MOV     AX, 0E00h     { текущий диск }
        INT     21h
        POP     DX
end; { proc SetDrive }

function LastDrive : byte; assembler;
asm
        PUSH    DX
        CALL    CurrentDrive  { Определяем текущий диск }
        MOV     DX, AX
        MOV     AX, 0E00h     { Устанавливаем текущим текущий диск -><- }
        INT     21h           { Побочный эффект - в AL возвращается }
        XOR     AH, AH        { количество допустимых дисков в системе }
        POP     DX            { восстановим DX }
end; { func LastDrive }

function LastDriveChar : char; assembler;
asm
        CALL    LastDrive
        ADD     AX, 40h       { Превратим байт в символ }
end; { func LastDriveChar }

procedure AssignArrayInit; assembler;
{
INT 2F U - DOS v3.0+ ASSIGN - GET DRIVE ASSIGNMENT TABLE
	AX = 0601h
Return: ES = segment of ASSIGN work area and assignment table
Note:	under DOS 3+, the 26 bytes starting at ES:0103h specify which drive
	  each of A: to Z: is mapped to.  Initially set to 01h 02h 03h....
SeeAlso: AX=0600h
}
asm
        CALL    AssignStatus
        CMP     AL, D_Installed
        JNE     @QUIT
        MOV     AX, 0601h             { дать таблицу ASSIGN }
        INT     2Fh
        PUSH    DS
        LEA     DI, AssignToChar
        PUSH    DS
        PUSH    ES                    { swap DS <-> ES }
        POP     DS
        POP     ES
        MOV     CX, MaxDiskCount
        MOV     SI, 103h
    REP MOVSB
        POP     DS

        MOV     CX, MaxDiskCount
        LEA     BX, AssignToChar
@1:
        ADD     BYTE PTR [BX], 40h
        INC     BX
        LOOP    @1
@QUIT:
end; { proc AssignArrayInit }

procedure DiskInit; assembler;
asm
        XOR     AX, AX
        CLD                                     { вперед и только вперед }
        MOV     CX, SEG DiskNameArray
        MOV     ES, CX
        MOV     CX, MaxDiskCount
  SEGES LEA     DI, DiskNameArray
    REP STOSB                                   { Обнуляем массив }
        MOV     CX, SEG AssignToChar
        MOV     ES, CX
        MOV     CX, MaxDiskCount
  SEGES LEA     DI, AssignToChar
    REP STOSB                                   { Обнуляем массив }

        CALL    FloppyDetected
        CALL    DiskReetInstalled
        MOV     DiskReetInst, AL
        CALL    EgaDiskInstalled
        MOV     EgaDiskInst, AL
        CALL    LastDrive
        MOV     LastDisk, AL
        CMP     AL, MaxDiskCount
        JBE     @@1
        MOV     AL, MaxDiskCount
        MOV     LastDisk, AL    { Береженого Бог бережет }
@@1:
        XOR     BX, BX

        { устанавливаем имена действующих дисков в массив имен }

        MOV     AL, 'A'
        PUSH    BX
        CALL    NEAR PTR @FL
        POP     BX
        JC      @DISK_B
        MOV     BYTE PTR DiskNameArray,   'A'     { [1] }
        INC     BX
@DISK_B:
        MOV     AL, 'B'
        PUSH    BX
        CALL    NEAR PTR @FL
        POP     BX
        JC      @DISK_C
        MOV     BYTE PTR DiskNameArray+BX, 'B'     { [2] }
        INC     BX
        JMP     @DISK_C

@FL:        (******* NEAR PROC *************************************)

    { А вот этого даже Нортон не учел, что несуществующему,  но зарезер-
  вированному  floppy-диску  можно  переопределить  устройство  командой
  SUBST !!!            Но, к сожалению, это идет только в DOS 3.1 и выше
  (интересно, есть у кого-нибудь 1.0 и 2.0 ?),  наверное только  "ИСКРА"
  сейчас поставляется с АДОСом (или я не прав?) }

        PUSH    AX
        PUSH    AX
        CALL    AvailableDisk
        OR      AL, AL
        POP     AX
        JZ      @NO

        PUSH    AX
        PUSH    AX
        CALL    PhantomDisk
        OR      AL, AL
        POP     AX
        JE      @OK
        CMP     DOS_Version, 300h
        JB      @NO

        PUSH    AX
        MOV     BX, 1
        MOV     AX, 4409h
        INT     21h
        POP     AX
        JC      @CO
        TEST    DX, 8000h      { CF <- 0 }
        JNZ     @OK
@CO:
        PUSH    AX
        CALL    AssignStatus
        CMP     AL, D_Installed
        POP     AX
        JNE     @NO
        PUSH    AX
        CALL    AssignArrayInit
        POP     AX
        MOV     BL, AL
        XOR     BX, 1Fh
        DEC     BX
        CMP     BYTE PTR AssignToChar+BX, AL
        JNE     @OK
@NO:
        STC
        RETN
@OK:
        CLC
        RETN
            (*******************************************************)

@DISK_C:
        MOV     CX, 3
        MOV     DX, CX
        ADD     DX, 40h
@@2:
        PUSH    BX
        PUSH    DX
        CALL    AvailableDisk
        POP     BX
        OR      AL, AL
        JZ      @@3
        LEA     DI, DiskNameArray       { пpи OK заносим имя в массив }
        MOV     BYTE PTR [DI+BX], DL
        INC     BX
@@3:
        INC     DX
        INC     CX
        CMP     CL, LastDisk
        JA      @@4                     { повторяем до прохождения всех }
        JMP     @@2                     { возможных дисков }
@@4:
        MOV     NumDrive, BL
end; { proc DiskInit }

function GetIOCTLDriveType (Disk : char) : IOCTLDriveType; assembler;
{ возвращает тип дисковода }
const
   SizeOfTestBuf = $4F;
   { размер таблицы }
var
   TestBuf: array [0..SizeOfTestBuf] of byte;
asm
        PUSH    DS
        CMP     DOS_Version, 314h
        JB      @NO
        MOV     SI, SS          { для OS/2 }
        MOV     DS, SI          { для DOS  }
        MOV     ES, SI
        MOV     CX, (SizeOfTestBuf+1)
        LEA     DI, TestBuf
        MOV     DX, DI
        XOR     AX, AX
        CLD
    REP STOSB                                   { Обнуляем массив }
        MOV     BL, BYTE PTR DISK
        AND     BX, 1Fh
        MOV     DI, DX
        MOV     CX, 0860h
        MOV     AX, 440Dh
        INT     21h                        { IOCTL }
        JC      @NO
        MOV     AL, BYTE PTR TestBuf+1
        CMP     AL, 9
        JBE     @QUIT
@NO:
        MOV     AL, UnKnownFloppy
@QUIT:
        XOR     AH, AH
        POP     DS
end; { func GetIOCTLDriveType }

procedure MyINT13h; far; assembler;      { ОСТОРОЖНО! Полностью рубим }
asm                                      { дисковый I/O               }
        PUSH    DS                       { обманули DOS, ни...чего    }
        MOV     AX, SEG @DATA            { не прочитали, но узнали,   }
        MOV     DS, AX                   { к какому физическому диску }
        MOV     BYTE PTR _DRIVE, DL      { было обращение             }
{$IFDEF BZdetaily}
        MOV     BYTE PTR _HEAD, DH
        MOV     BX, CX
        AND     BX, 3Fh
        MOV     BYTE PTR _SECTOR, BL
        XCHG    CH, CL
        SHR     CH, 1
        SHR     CH, 1
        SHR     CH, 1
        SHR     CH, 1
        SHR     CH, 1
        SHR     CH, 1
        MOV     WORD PTR _TRACK, CX
{$ENDIF}
        POP     DS
        XOR     AX, AX
        CLC
        IRET                             { возвертаемося... }
end; { proc MyINT13h }

procedure CloneReadSector(DISK : BYTE; FirstSec : word); assembler;
VAR
     BUF    : array[0..MaxSectorSize] of byte;
     {!!! стека должно быть определено достаточно }
asm
        PUSH    ES
        PUSH    BX
        MOV     _DRIVE, 0FFh
        XOR     AX, AX
        MOV     PartMore32M, AL
                                               { указатель на таблицу }
        MOV     ES, AX                         { векторов прерываний  }
        MOV     DI, 13h*4                      { ADDR int 13h         }

        CLI                                    { Весь участок с фиктивным
                                                 13-м прерыванием должен
                                                 проходиться без intrpts }
        PUSH    WORD PTR ES:[DI]               { читаем вектор }
        PUSH    WORD PTR ES:[DI+2]
                                               { на мгновение устанавливаем }
        MOV     AX, WORD PTR MyINT13hVec       { вектор прямо в таблицу,    }
        MOV     WORD PTR ES:[DI], AX           { минуя DOS и ловушки        }
        MOV     AX, WORD PTR MyINT13hVec+2
        MOV     WORD PTR ES:[DI+2], AX

        MOV     AL, BYTE PTR DISK       { обратиться к диску... }
        AND     AX, 001Fh
        DEC     AX
        PUSH    DS                      { сохраним регистры }
        PUSH    BP
        MOV     CX, SS                  { укажем буфер }
        MOV     DS, CX
        LEA     BX, BUF                 { LEA уже в DS (DS уже установлен) }
                                        { ежели вдруг драйвер прорвется,   }
                                        { будем читать BOOT-сектор         }
        MOV     DX, WORD PTR FirstSec
        MOV     BP, BX                  { это необходимо для того, чтобы   }
                                        { исключить сбой при ошибке - DOS  }
                                        { 3.1-3.3 пишет FFFF по ES:[BP+1Eh]}
                                        { так это слово будет в стеке !    }
        MOV     CX, 1
        XOR     DI, DI                  { ??? }
        INT     25h                     { ой, фу !!! Що то було ??? }
        POP     DX                      { выравниваем  стек  после INT 25h,}
                                        { там остается слово флагов        }
        POP     BP
        POP     DS
        JNC     @CONT                   { Флаг устанавливается при запуске }
                                        { на чтение для разделов более 32M }
{--------------------------------------------------------------------------}
        MOV     _DRIVE, 0FFh
        MOV     BYTE PTR PartMore32M, TRUE
        MOV     AL, BYTE PTR DISK       { обратиться к диску... }
        AND     AX, 001Fh
        DEC     AX
        PUSH    DS
        PUSH    BP
        MOV     CX, SS                  { укажем буфер конфигурации }
        MOV     DS, CX
        LEA     BX, BUF
        MOV     DX, WORD PTR FirstSec
        MOV     WORD PTR [BX  ], DX     { С какого сектора читать          }
        MOV     WORD PTR [BX+2], 0
        MOV     WORD PTR [BX+4], 1      { сколько секторов читать          }
        MOV     WORD PTR [BX+6], BX     { куда читать }
        MOV     WORD PTR [BX+8], CX
        MOV     BP, BX
        MOV     CX, 0FFFFh
        XOR     DI, DI
        INT     25h
        POP     DX
        POP     BP
        POP     DS
@CONT:
        JNC     @NC
        MOV     _DRIVE, 0FEh            { Особая ошибка }
        XOR     AX, AX
        MOV     PartMore32M, AL
@NC:
        XOR     DI, DI
        MOV     ES, DI
        MOV     DI, 13h*4               { восстанавливаем INT 13h }

        POP     WORD PTR ES:[DI+2]
        POP     WORD PTR ES:[DI]
        STI                             { Конец участка запрета ints }
        POP     BX
        POP     ES
end; { proc CloneReadSector }

function GetDiskType(disk : char) : DiskClass; assembler;
{ возвращает тип диска (кроме фантомного  и  переназначенного  (ASSIGN)), }
{ т.к. фантомный и переназначенный имеют основной тип, а подтип проверяют }
{ соответствующие процедуры }
type
     DiskReetZone = record
       Head : byte;      { <- $12        ─┐        }
       Swith: byte;      { <- $FF, -> 0   │ Output }
       LI   : LongInt;   { <- $00000000   │ 7 byte }
       Name : char;      { <- disk       ─┘        }
       Size : LongInt;   { -> размер диска, 0 если не DiskReet-устройство}
     end;
var
     DRData : DiskReetZone;
     zzz,
     Handle : WORD;
const
     DiskReetDev : array[0..8] of char = '@DSKREET'#0;
asm
        PUSH    ES
        PUSH    SI
        PUSH    DI
        PUSH    CX
        PUSH    DX

        XOR     AX, AX                     { обнуляем }
        MOV     PartMore32M, AL
        MOV     AL, DISK
        PUSH    AX
        CALL    AvailableDisk              { устройство доступно ? }
        OR      AL, AL
        JNZ     @@I                        { ILLEGAL }
        MOV     AL, ILLEGALDISK
        JMP     @@7
@@I:
        CMP     DiskReetInst, FALSE        { DiskReet установлен ? }
        JE      @@9
        MOV     AX, 3D02h
        MOV     DX, OFFSET DiskReetDev
        MOV     CX, SEG DiskReetDev
        PUSH    DS
        MOV     DS, CX
        INT     21h                        { open character device }
        MOV     WORD PTR Handle, AX
        POP     DS
        JC      @@9
        MOV     BX, WORD PTR Handle
        MOV     BYTE PTR DRData.Head,  12h
        MOV     BYTE PTR DRData.Swith, 0FFh
        MOV     WORD PTR DRData.LI,    0
        MOV     WORD PTR DRData.LI+2,  0
        MOV     AL, BYTE PTR disk
        MOV     BYTE PTR DRData.Name, AL
        MOV     WORD PTR DRData.Size,  0
        MOV     WORD PTR DRData.Size+2,0
        MOV     AX, 4403h
  SEGSS LEA     DX, DRData
        MOV     CX, SS
        PUSH    DS
        MOV     DS, CX
        MOV     CX, 7
        INT     21h                        { WRITE to device }
        POP     DS
        MOV     BX, WORD PTR Handle
        MOV     AX, 3E00h
        INT     21h                        { close file }
        CMP     WORD PTR DRData.Size, 0
        JNZ     @@8                        { данное устройство DiskReet ? }
        CMP     WORD PTR DRData.Size + 2, 0
        JZ      @@9
@@8:
        MOV     AL, Encrypted
        JMP     @@7
@@9:
        CLC                        { эта функция показывает, надо ли }
        MOV     BL, BYTE PTR disk  { строить таблицы каждый раз  при }
        AND     BX, 001Fh          { обращении к диску,  т. е.  диск }
        MOV     AX, 4408h          { является сменным }
        INT     21h
        JC      @@E1
        CMP     AL, 0              { FLOPPY }
        JNE      @@E1
@@2:
        MOV     AL, Floppy
        JMP     @@7
@@E1:
        MOV     AX, 4409h
        INT     21h                { CHECK IF BLOCK DEVICE REMOTE }
        JC      @@1
        TEST    DX, 1000h          { NETWORK }
        JZ      @@5
        MOV     AL, NetWorkDisk
        JMP     @@7
@@5:
        TEST    DX, 8000h          { SUBSTITUTED }
        JZ      @@0
        MOV     AL, SubstitutedDisk
        JMP     @@7
@@0:
        CMP     BYTE PTR VER, 0Ah
        JAE     @@NL1
        PUSH    DS
        PUSH    BP
        MOV     AX, 3200h          { Getdrive parameter block }
        MOV     DL, BYTE PTR disk  { для определения media descriptor }
        AND     DX, 001Fh          { и числа секторов в одной FAT }
        INT     21h                { для идентификации диска Bernoulli }
        POP     BP
        CMP     AL, 0FFh
        MOV     AX, DS
        MOV     ES, AX
        POP     DS
        JE      @@NL1
        CMP     BYTE PTR VER, 4
        JAE     @NN_1
        MOV     AL, BYTE PTR ES:[BX+16h]
        MOV     BL, BYTE PTR ES:[BX+0Fh]
        XOR     BH, BH
        JMP     @NN_2
@NN_1:
        MOV     AL, BYTE PTR ES:[BX+17h]
        MOV     BX, WORD PTR ES:[BX+0Fh]
@NN_2:
        CMP     AL, 0FDh
        JNE     @@NL1
        CMP     BX, 2
        JBE     @@NL1
        MOV     AL, BernoulliDisk
        JMP     @@7
@@NL1:
        PUSH    WORD PTR DISK             { эмулируем чтение сектора }
        XOR     AX, AX
        PUSH    AX
        CALL    CloneReadSector

        CMP     BYTE PTR _DRIVE, 0FEh      { ОШИБКА }
        JE      @@1
        CMP     BYTE PTR _DRIVE, 0FFh      { НЕТ ОБРАЩЕНИЯ К ФИЗИЧ УСТР }
        JE      @@4
        TEST    BYTE PTR _DRIVE, 80h       { _DRIVE = 1..4 }
        JZ      @@2                        { Floppy }

        MOV     AX, WORD PTR _TRACK
        MOV     WORD PTR HANDLE, AX
        MOV     DL, BYTE PTR _DRIVE
        XOR     DH, DH
        MOV     AX, 0800h
        INT     13h
        MOV     AX, CX
        AND     AX, 3Fh
        INC     DH
        MUL     DH
        PUSH    AX
        PUSH    DS
        PUSH    BP
        MOV     DL, BYTE PTR DISK
        AND     DX, 001Fh
        MOV     AX, 3200h
        INT     21h
        POP     BP
        MOV     DX, DS
        POP     DS
        MOV     ES, DX
        CMP     AL, 0FFh
        JNE     @@T5
        POP     AX
        JMP     @@1
@@T5:
        MOV     DX, WORD PTR ES:[BX+0Dh]
        MOV     AL, BYTE PTR ES:[BX+04h]
        XOR     AH, AH
        MUL     DX
        OR      DX, DX
        JZ      @@T3
        MOV     AX, 07FFFh
@@T3:
        CMP     AX, 07FFFh
        JBE     @@T4
        MOV     AX, 07FFFh
@@T4:
        XOR     DX, DX
        POP     BX
        DIV     BX
        XOR     DX, DX
        PUSH    AX
        DEC     AX
        MUL     BX

        PUSH    WORD PTR DISK
        PUSH    AX
        CALL    CloneReadSector

        CMP     BYTE PTR _DRIVE, 0FEh      { ОШИБКА }
        JE      @@1
        CMP     BYTE PTR _DRIVE, 0FFh
        JE      @@4
        TEST    BYTE PTR _DRIVE, 80h
        JZ      @@2
        MOV     AX, WORD PTR _TRACK
        SUB     AX, WORD PTR HANDLE
        INC     AX
        POP     BX
        CMP     AX, BX
        JB      @@NL2

        CMP     BYTE PTR _DRIVE, 80h       { _DRIVE = 80h }
        JNE     @@3
        MOV     AL, HD0                    { Hard Disk }
        JMP     @@7
@@3:
        MOV     AL, HD1                    { _DRIVE = 81h }
        JMP     @@7
@@1:
        MOV     AL, UnKnown                { иначе - неизвестный тип }
        JMP     @@7
@@4:
        CMP     EgaDiskInst, FALSE         { EgaDisk установлен ? }
        JE      @@A
        CLC
        MOV     DL, BYTE PTR DISK
        AND     DX, 001Fh
        MOV     AX, 3200h
        PUSH    DS                         { В таблице, на которую дает }
        INT     21h                        { указатель 32 функция DOS   }
        MOV     DX, DS                     { можно найти адрес of device}
        POP     DS                         { driver,                    }
        JC      @@1
        CMP     AL, 0FFh
        JE      @@1
        MOV     ES, DX
        CMP     BYTE PTR VER, 3
        JA      @@T1
        MOV     AX, WORD PTR ES:[BX+14h]   { в MS-DOS 3.x и DR-DOS по сме-}
        JMP     @@T2                       { щению 14h в таблице,         }
@@T1:
        MOV     AX, WORD PTR ES:[BX+15h]   { в MS-DOS 4.0 и старше - 15h  }
@@T2:                                      { находится слово сегмента     }
        MOV     WORD PTR HANDLE, AX
        MOV     AX, 0EE00h
        INT     10h                        { выдает сегмента EgaDisk }
        CMP     BX, WORD PTR HANDLE
        JNE      @@A
        MOV     AL, EgaDisk
        JMP     @@7
@@A:
        PUSH    DS
        MOV     AX, 3200h               { в блоке  параметров устройства, }
        MOV     DL, BYTE PTR disk       { когда  точно  установлено,  что }
        AND     DX, 001Fh               { указанное устройство образовано }
        INT     21h                     { загружаемым  драйвером,  читаем }
        CMP     AL, 0FFh                { число копий  FAT,  у  RAMDISK'а }
        JE      @@NL2                   { только одна копия FAT           }
        MOV     AL, BYTE PTR [BX+08h]
        POP     DS
        CMP     AL, 1
        JNE     @@NL2
        MOV     AL, VDisk
        JMP     @@7
@@NL2:
        MOV     AL, DeviceDriven        { иначе это устройство образовано }
@@7:                                    { другим драйвером }
        CLC
        XOR     AH, AH
        POP     DX
        POP     CX
        POP     DI
        POP     SI
        POP     ES
end; { func GetDiskType }

procedure ReadDiskType; assembler;
{ заполняет все таблицы типов }
asm
        CLD
        MOV     AL, IllegalDisk
        MOV     CX, SEG AssignToType
        MOV     ES, CX
        MOV     CX, MaxDiskCount
  SEGES LEA     DI, AssignToType
    REP STOSB                                   { Обнуляем массив }
        MOV     CX, SEG DiskTypeArray
        MOV     ES, CX
        MOV     CX, MaxDiskCount
  SEGES LEA     DI, DiskTypeArray
    REP STOSB                                   { Обнуляем массив }
        XOR     AX, AX
        MOV     CX, SEG AMore32MDisk
        MOV     ES, CX
        MOV     CX, MaxDiskCount
  SEGES LEA     DI, AMore32MDisk
    REP STOSB                                   { Обнуляем массив }
        CMP     DOS_Version, 314h
        JB      @QUIT
        MOV     CL, NumDrive
        LEA     SI, DiskNameArray
        LEA     DI, DiskTypeArray
        MOV     BX, CX
        DEC     BX
        ADD     SI, BX
        ADD     DI, BX
@@1:
        XOR     BH, BH
        MOV     BL, BYTE PTR[SI]
        PUSH    BX
        CALL    GetDiskType
        MOV     BYTE PTR[DI], AL
        CMP     PartMore32M, TRUE
        JNE     @@4
        XOR     BH, BH
        MOV     BL, BYTE PTR [SI]
        AND     BX, 1Fh
        DEC     BX
        MOV     BYTE PTR [AMore32MDisk+BX], TRUE
@@4:
        DEC     DI
        DEC     SI
        LOOP    @@1

        CALL    AssignStatus            { ASSIGN загружен ? }
        CMP     AL, D_Installed
        JNE     @QUIT
        CALL    AssignArrayInit         { заполнить таблицу присвоений }
        XOR     CX, CX                  { драйвера ASSIGN }
        MOV     CL, NumDrive
        XOR     AX, AX
        XOR     BX, BX
        XOR     DI, DI
@@2:
        MOV     AL, BYTE PTR DiskNameArray[BX]
        MOV     DI, AX   { надо заметить, что положение символов в таблицах}
        SUB     DI, 41h  { может не совпадать, поэтому вычисляем смещение. }
        CMP     AL, BYTE PTR AssignToChar [DI]
        JE      @@3
        MOV     AL, BYTE PTR DiskTypeArray[BX]
        MOV     BYTE PTR AssignToType [DI], AL
        MOV     BYTE PTR DiskTypeArray[BX], AssignedDisk
@@3:
        INC     BX
        LOOP    @@2
@QUIT:
end; { proc ReadDiskType }

procedure DisableDrive (Disk : char); assembler;
{ запрещает устройство }
{ аналог функции DOS 5.0 5F08 - но только работает в DOS 3.20+
INT 21 - DOS 5.0 - DISABLE DRIVE
	AX = 5F08h
	DL = drive number (0=A:)
Return: CF clear if successful
	CF set on error
	    AX = error code (0Fh) (see AH=59h)
Note:	simply clears the "valid" bit in the drive's CDS
SeeAlso: AH=52h,AX=5F07h"DOS"
}
asm
        CMP     DOS_Version, 314h
        JB      @QUIT
        LES     BX, DWORD PTR ListOfCDS
        MOV     DL, BYTE PTR DISK
        AND     DX, 1Fh
        DEC     DX
        MOV     AL, SizeOfCDS
        XOR     AH, AH
        MUL     DL
        ADD     BX, AX
        ADD     BX, 44h
        MOV     AL, BYTE PTR ES:[BX]
        AND     AL, 0BFh
        MOV     BYTE PTR ES:[BX], AL
@QUIT:
end; { proc DisableDrive }

procedure EnableDrive(Disk : char); assembler;
{ разрешает устройство }
{ аналог функции DOS 5.0 5F07 - но только работает в DOS 3.20+
INT 21 - DOS 5.0 - ENABLE DRIVE
	AX = 5F07h
	DL = drive number (0=A:)
Return: CF clear if successful
	CF set on error
	    AX = error code (0Fh) (see AH=59h)
Note:	simply sets the "valid" bit in the drive's CDS
SeeAlso: AH=52h,AX=5F08h"DOS"
}
asm
        CMP     DOS_Version, 314h
        JB      @QUIT
        LES     BX, DWORD PTR ListOfCDS
        MOV     DL, BYTE PTR DISK
        AND     DX, 1Fh
        DEC     DX
        MOV     AL, SizeOfCDS
        XOR     AH, AH
        MUL     DL
        ADD     BX, AX
        ADD     BX, 44h
        MOV     AL, BYTE PTR ES:[BX]
        OR      AL, 40h
        MOV     BYTE PTR ES:[BX], AL
@QUIT:
end; { proc EnableDrive }

{ **************************************************************************
  Процедуры чтения/записи (GetVolumeLabel, SetVolumeLabel...)
  основаны на использовании прерываний 25h и 26h, далее рассмотрим
  их особенности и параметры вызова.

  INT 25h - DOS 1+ - АБСОЛЮТНОЕ ЧТЕНИЕ ДИСКА
                     (исключая разделы фиксированного диска > 32M)
	AL = номер устройства (00h = A:, 01h = B:, ...)
	CX = количество секторов прочитать
	DX = номер начального логического сектора (0000h ...)
	DS:BX -> буффер для данных
Возвращает:
        CF сброшен, если все в порядке
	CF установлен при ошибке
	    AH = статус
                 80h устройство не отвечает (timeout)
                 40h ошибка операции установки головок
                 20h ошибка контроллера
                 10h ошибка данных (несовпадение CRC)
                 08h ошибка DMA
                 04h указанный сектор не найден
                 03h защита записи диска (только у INT 26h)
                 02h неверный адресный маркер
                 01h неверная команда
	    AL = код ошибки (возвращаемый INT 24h в DI)

         может изменить все другие регистры, исключая регистры сегментов.
Замечание:
         после выхода из прерывания в стеке остается слово флагов,
         которое должно быть вытолкнуто.
Ошибки:
         DOS 3.1 по 3.3 устанавливает слово ES:[BP+1Eh] в FFFFh если в AL
         находится неверный номер устройства.

См.также: INT 13/AH=02h,INT 26

 --------------------------------------------------------------------------

INT 25 - DOS 3.31+ - АБСОЛЮТНОЕ ЧТЕНИЕ ДИСКА
                    (включая разделы твердого диска >32M)
	AL = номер устройства (0=A, 1=B, ...)
	CX = FFFFh
	DS:BX -> пакет чтения диска (см.ниже)
Возвращает: то же, что и INT 25h
Замечание:
        раздел потенциально >32M (и необходима эта форма вызова) если
        бит 1 слова атрибута устройства в драйвере устройства установлен.
        Слово флагов остается в стеке, необходимо удалять после вызова
        прерывания.
См.также: INT 13/AH=02h,INT 26

Формат блока чтения диска:
Смещение Размер Описание
 00h	 DWORD	номер сектора
 04h	 WORD	количество секторов
 06h	 DWORD	адрес буфера

 --------------------------------------------------------------------------

INT 26 - DOS 1+ (3.31+) - АБСОЛЮТНОЕ ЧТЕНИЕ ДИСКА
                  все аналогично прерыванию 25h (<32M и >=32M)

 ************************************************************************** }

function GetVolumeLabel(Disk : char; var Name : string) : word; assembler;
var
    BUF : array [0..MaxSectorSize] of byte;
    DRPacket : record
        SeekSec : LongInt;
        NumSect : word;
        TrAddr  : pointer;
    end;
    SecSize,
    ENTR,
    ROOT: WORD;
asm
        PUSH    DS
        PUSH    ES
        PUSHF
        CMP     DskToolsVarInit, TRUE
        JE      @INIOK
        CALL    InitDiskVariable
@INIOK:
        MOV     AX, DS
        MOV     ES, AX
        MOV     AX, SS
        MOV     DS, AX
        LEA     BX, BUF
        MOV     CX, 1
        XOR     DX, DX
        MOV     AL, BYTE PTR Disk
        AND     AX, 01Fh
        DEC     AX
        MOV     BYTE PTR Disk, AL
  SEGES CMP     DOS_Version, 31Fh { DOS 3.31, SEGES т.к. DS=SS, а ES=@DSeg }
        JB      @NB0
        MOV     WORD PTR DRPacket.TRAddr, BX
        MOV     BX, DS
        MOV     WORD PTR DRPacket.TRAddr+2, BX
        LEA     BX, DRPacket
        MOV     WORD PTR DRPacket.NumSect, CX
        MOV     CX, 0FFFFh
        MOV     WORD PTR DRPacket.SeekSec, DX
        MOV     WORD PTR DRPacket.SeekSec+2, DX
@NB0:
        PUSH    BP
        INT     25h
        POP     DX
        POP     BP
        JC      @ERROR
        LEA     BX, BUF
        MOV     AX, WORD PTR [BX+16h]
        MOV     CL, BYTE PTR [BX+10h]
        XOR     CH, CH
        MUL     CX
        ADD     AX, WORD PTR [BX+0Eh]      { начальный сектор ROOT DIR }
        MOV     WORD PTR ROOT, AX
        MOV     AX, WORD PTR [BX+11h]
        MOV     WORD PTR [ENTR], AX
        MOV     AX, WORD PTR [BX+0Bh]
        MOV     WORD PTR [SecSize], AX
@LOOP:
        MOV     CX, 1
        MOV     DX, ROOT
        MOV     AL, BYTE PTR Disk
  SEGES CMP     DOS_Version, 31Fh { DOS 3.31 }
        JB      @NB1
        LEA     BX, DRPacket
        MOV     WORD PTR DRPacket.NumSect, CX
        MOV     CX, 0FFFFh
        MOV     WORD PTR DRPacket.SeekSec, DX
        MOV     WORD PTR DRPacket.SeekSec+2, 0
@NB1:
        PUSH    BP
        INT     25h
        POP     DX
        POP     BP
        JC      @ERROR
        LEA     BX, BUF
        XOR     SI, SI
@SCAN:
        TEST    BYTE PTR [BX+SI+0Bh], 08h
        JNZ     @FOUND
@CONT:
        DEC     WORD PTR ENTR
        CMP     WORD PTR ENTR, 0
        JE      @NO
        ADD     SI, 20h
        CMP     SI, WORD PTR SecSize
        JB      @SCAN
        INC     WORD PTR ROOT
        JMP     @LOOP
@FOUND:
        CMP     BYTE PTR [BX+SI], 0E5h
        JNE     @OK
        JMP     @CONT
@OK:
        MOV     CX, 0Bh
        PUSH    DS
        POP     ES
        MOV     DI, BX
        ADD     DI, SI
        MOV     SI, DI
        ADD     DI, 0Ah
        MOV     AL, 20h
        STD
   REPE SCASB
        OR      CX, CX
        JZ      @NO
        LES     DI, Name
        INC     CX
        MOV     BYTE PTR ES:[DI], CL
        INC     DI
        CLD
    REP MOVSB
        XOR     AX, AX
        JMP     @QUIT
@NO:
        XOR     AX, AX
@ERROR:
        LDS     BX, Name
        MOV     BYTE PTR [BX], 0
@QUIT:
        POPF
        POP     ES
        POP     DS
end; { func GetVolumeLabel }

function SetVolumeLabel(Disk : char; Name : string) : word; assembler;
{ возвращает FFFF если нет места для метки }
var
    BUF    : array [0..MaxSectorSize] of byte;
    DRPacket : record
        SeekSec : LongInt;
        NumSect : word;
        TrAddr  : pointer;
        end;
    SecSize,
    S_SI,
    ENTR,
    S_ROOT,
    ROOT   : WORD;
    FLAG,
    DEL_   : BYTE;
asm
        PUSH    DS
        PUSH    ES
        PUSHF
        CMP     DskToolsVarInit, TRUE
        JE      @INIOK
        CALL    InitDiskVariable
@INIOK:
        MOV     AX, DS
        MOV     ES, AX
        XOR     AX, AX
        MOV     BYTE PTR DEL_, AL
        MOV     BYTE PTR FLAG, AL
        MOV     WORD PTR S_ROOT, AX
        MOV     WORD PTR S_SI, AX
        LDS     SI, Name
        CMP     BYTE PTR [SI], 0
        JNE     @NO_DEL
        MOV     BYTE PTR DEL_, 1
@NO_DEL:
        MOV     AX, SS
        MOV     DS, AX
        LEA     BX, BUF
        XOR     DX, DX
        MOV     CX, 1
        MOV     AL, BYTE PTR Disk
        AND     AX, 01Fh
        DEC     AX
        MOV     BYTE PTR Disk, AL
  SEGES CMP     DOS_Version, 31Fh { DOS 3.31 }
        JB      @NB0
        MOV     WORD PTR DRPacket.TRAddr, BX
        MOV     BX, DS
        MOV     WORD PTR DRPacket.TRAddr+2, BX
        LEA     BX, DRPacket
        MOV     WORD PTR DRPacket.NumSect, CX
        MOV     CX, 0FFFFh
        MOV     WORD PTR DRPacket.SeekSec, DX
        MOV     WORD PTR DRPacket.SeekSec+2, DX
@NB0:
        PUSH    BP
        INT     25h
        POP     DX
        POP     BP
        JC      @QUIT
        LEA     BX, BUF
        MOV     AX, WORD PTR [BX+16h]
        MOV     CL, BYTE PTR [BX+10h]
        XOR     CH, CH
        MUL     CX
        ADD     AX, WORD PTR [BX+0Eh]      { начальный сектор ROOT DIR }
        MOV     WORD PTR ROOT, AX
        MOV     AX, WORD PTR [BX+11h]
        MOV     WORD PTR ENTR, AX
        MOV     AX, WORD PTR [BX+0Bh]
        MOV     WORD PTR SecSize, AX
@LOOP:
        MOV     CX, 1
        MOV     DX, ROOT
        MOV     AL, BYTE PTR Disk
  SEGES CMP     DOS_Version, 31Fh { DOS 3.31 }
        JB      @NB1
        LEA     BX, DRPacket
        MOV     WORD PTR DRPacket.NumSect, CX
        MOV     CX, 0FFFFh
        MOV     WORD PTR DRPacket.SeekSec, DX
        MOV     WORD PTR DRPacket.SeekSec+2, 0
@NB1:
        PUSH    BP
        INT     25h
        POP     DX
        POP     BP
        JC      @QUIT
        LEA     BX, BUF
        XOR     SI, SI
@SCAN:
        TEST    BYTE PTR [BX+SI+0Bh], 08h
        JNZ     @SAVE
        CMP     BYTE PTR [BX+SI], 0E5h      { это стертый файл? }
        JNE     @3
        CMP     FLAG, 1                     { приоритет }
        JAE     @3
        MOV     AX, ROOT
        MOV     S_ROOT, AX
        MOV     S_SI, SI
        MOV     FLAG, 1
        JMP     @CONT
@3:
        CMP     BYTE PTR [BX+SI], 0         { пустой вход? }
        JNE     @CONT
        CMP     WORD PTR [BX+SI+1Ah], 0
        JNE     @CONT
        CMP     WORD PTR [BX+SI+1Ch], 0
        JNE     @CONT
        CMP     WORD PTR [BX+SI+1Eh], 0
        JNE     @CONT
        CMP     FLAG, 2
        JAE     @CONT
        MOV     AX, ROOT
        MOV     S_ROOT, AX
        MOV     S_SI, SI
        MOV     FLAG, 2                     { приоритет }
@CONT:
        DEC     WORD PTR ENTR
        CMP     WORD PTR ENTR, 0
        JNE     @ADD
        CMP     DEL_, 0
        JNE     @QUIT
        CMP     BYTE PTR FLAG, 0
        JE      @NO
        MOV     AX, S_ROOT
        CMP     AX, ROOT
        JE      @4
        MOV     ROOT, AX
        MOV     DX, AX
        MOV     CX, 1
        MOV     AL, BYTE PTR Disk
  SEGES CMP     DOS_Version, 31Fh { DOS 3.31 }
        JB      @NB2
        LEA     BX, DRPacket
        MOV     WORD PTR DRPacket.NumSect, CX
        MOV     CX, 0FFFFh
        MOV     WORD PTR DRPacket.SeekSec, DX
        MOV     WORD PTR DRPacket.SeekSec+2, 0
@NB2:
        PUSH    BP
        INT     25h
        POP     DX
        POP     BP
        JC      @QUIT
        LEA     BX, BUF
@4:
        MOV     SI, S_SI
        JMP     @2
@ADD:
        ADD     SI, 20h
        CMP     SI, WORD PTR SecSize
        JB      @SCAN
        INC     WORD PTR ROOT
        JMP     @LOOP
@SAVE:
        CMP     BYTE PTR [BX+SI], 0E5h      { это стертая метка? }
        JNE     @1
        CMP     BYTE PTR FLAG, 3
        JAE     @CONT
        MOV     AX, ROOT
        MOV     S_ROOT, AX
        MOV     S_SI, SI
        MOV     FLAG, 3                     { приоритет }
        JMP     @CONT
@1:
        CMP     BYTE PTR DEL_, 1            { стереть метку }
        JNE     @2
        MOV     AL, BYTE PTR [BX+SI]
        MOV     BYTE PTR [BX+SI+0Dh], AL    { сохраняем первую букву в }
        MOV     BYTE PTR [BX+SI], 0E5h      { зарезервированной области, }
        JMP     @WRITE                      { как это делает DR-DOS }
@2:
        MOV     DI, BX                      { установить новую метку }
        ADD     DI, SI
        MOV     BYTE PTR [DI+0Bh], 28h      { атрибут архивный и метка }
        MOV     AX, 2C00h
        INT     21h                         { время }
        SHL     CL, 1                       { преобразование формата }
        SHL     CL, 1
        SHL     CX, 1
        SHL     CX, 1
        SHL     CX, 1
        XCHG    DH, DL
        SHR     DL, 1
        AND     DX, 1Fh
        OR      DX, CX
        MOV     WORD PTR [DI+16h], DX
        MOV     AX, 2A00h
        INT     21h                         { дата }
        SUB     CX, 1980 {DECIMAL}          { преобразование формата }
        XCHG    CH, CL
        SHL     CX, 1
        SHL     DL, 1
        SHL     DL, 1
        SHL     DL, 1
        SHR     DX, 1
        SHR     DX, 1
        SHR     DX, 1
        OR      DX, CX
        MOV     WORD PTR [DI+18h], DX
        CMP     BYTE PTR [DI], 0E5h
        JE      @XXX
        XOR     AX, AX
        MOV     WORD PTR [DI+1Ah], AX   { кластер }
        MOV     WORD PTR [DI+1Ch], AX   { размер  }
        MOV     WORD PTR [DI+1Eh], AX
@XXX:
        LDS     SI, Name
        MOV     CL, BYTE PTR [SI]
        CMP     CL, 0Bh
        JBE     @BE
        MOV     CL, 0Bh
@BE:
        XOR     CH, CH
        MOV     AX, SS
        MOV     ES, AX
        MOV     AX, 0Bh
        SUB     AX, CX
        INC     SI
        CLD
    REP MOVSB                              { имя }
        MOV     CX, AX
        MOV     AX, 20h
    REP STOSB                              { дополнение пробелами }
@WRITE:
        MOV     AX, SS
        MOV     DS, AX
        MOV     AX, SEG @DATA
        MOV     ES, AX
        XOR     AX, AX
        MOV     CX, 1
        MOV     DX, ROOT
        MOV     AL, BYTE PTR Disk
  SEGES CMP     DOS_Version, 31Fh { DOS 3.31 }
        JB      @NB3
        LEA     BX, DRPacket
        MOV     WORD PTR DRPacket.NumSect, CX
        MOV     CX, 0FFFFh
        MOV     WORD PTR DRPacket.SeekSec, DX
        MOV     WORD PTR DRPacket.SeekSec+2, 0
@NB3:
        PUSH    BP
        INT     26h                        { пишем }
        POP     DX
        POP     BP
        JC      @QUIT
        XOR     AX, AX
        JMP     @QUIT
@NO:
        MOV     AX, 0FFFFh                 { не помещается }
@QUIT:
        POPF
        POP     ES
        POP     DS
end; { func SetVolumeLabel }

procedure InitDiskVariable;
begin
  FloppyDetected;
  DiskInit;
  ReadDiskType;
  DskToolsVarInit := TRUE;
end; {proc InitDiskVariable}

begin
asm
        MOV     AX, 3306h
        CLC
        INT     21h         { при установленном драйвере SetVer в }
        JC      @RV         { MS-DOS 5.0 в BX - версия системы }
        CMP     AL, 0FFh
        JE      @RV
        MOV     AX, BX
        JMP     @@5
@RV:
        MOV     AX, 3000h   { для 5.0 версии MS-DOS можно  поместить }
                            { в AL 1 для возврата в BX флага системы,}
                            { который указывает, в какой части памяти}
                            { располагается DOS - ROM (BH=08h)       }
                            { или HMA (BH=10h) }
        INT     21h                { дать версию DOS }
{
        BH = OEM number
            00h IBM
            05h Zenith
            16h DEC
            23h Olivetti
            29h Toshiba
            4Dh Hewlett-Packard
            99h STARLITE architecture (OEM DOS, NETWORK DOS, SMP DOS)
            FFh Microsoft, Phoenix
}
        OR      AL, AL
        JNZ     @@5
        MOV     AL, 1
@@5:
        MOV     Ver, AX
        CMP     AL, 3
        JB      @@2
        JA      @@1
        CMP     AH, 14h            { < 3.20 ? }
        JB      @@2
@@1:

        { читаем при DOS версии 3.20 и выше, поэтому нет специфических }
        { проверок и изменение смещений на List of List для DOS 3.0    }
        { Если кто-то собирается изменять/дополнять - учтите это       }
        { обстоятельство и добавьте соответствующие проверки.          }

        CMP     AL, 0Ah
        JAE     @O3
        CMP     AL, 3
        JA      @BigCDS
@O3:
        MOV     BYTE PTR SizeOfCDS, 51h
        { У версий 3.x MS-DOS и любых DR-DOS размер CDS 81 байт }
        JMP     @GetLOL
@BigCDS:
        MOV     BYTE PTR SizeOfCDS, 58h
        { У версий MS-DOS >=4.0 размер CDS 88 байт }
@GetLOL:
        MOV     AX, 5200h                   { установить адрес List of list }
        INT     21h
        MOV     WORD PTR ListOfList, BX
        MOV     WORD PTR ListOfList+2, ES
        MOV     AX, ES:[BX+16h]
        MOV     WORD PTR ListOfCDS, AX
        MOV     AX, ES:[BX+18h]
        MOV     WORD PTR ListOfCDS+2, AX
@@3:
        MOV     AX, 4452h              { DR-DOS ? }
        STC
        INT     21h
        JC      @MSDOS
        MOV     Current_OS, _DRDOS
        CMP     DX, 1063h
        JA      @D2
        JB      @D1
        MOV     OS_Version, 31Fh     { DR-DOS 3.31 }
        JMP     @CONTINUE
@D1:
        MOV     OS_Version, 329h     { DR-DOS 3.41 }
        JMP     @CONTINUE
@D2:
        CMP     DX, 1065h
        JA      @D3
        MOV     OS_Version, 500h     { DR-DOS 5.00 }
        JMP     @CONTINUE
@D3:
        MOV     OS_Version, 600h     { DR-DOS 6.00 }
        JMP     @CONTINUE
@@2:
        XOR     AX, AX
        MOV     BYTE PTR SizeOfCDS,    AL
        MOV     WORD PTR ListOfList,   AX
        MOV     WORD PTR ListOfList+2, AX
        MOV     WORD PTR ListOfCDS,    AX
        MOV     WORD PTR ListOfCDS+2,  AX
@MSDOS:
        CMP     BYTE PTR VER, 0Ah      { OS/2 ? }
        JB      @@4
        MOV     Current_OS, _OS2
        MOV     AX, WORD PTR VER
        CMP     BYTE PTR VER, 0Ah
        JA      @O1
        MOV     AL, 1               { OS/2 1.xx }
        JMP     @O2
@O1:
        MOV     AL, 2
@O2:
        XCHG    AH, AL
        MOV     OS_Version, AX       { OS/2 1.xx }
        JMP     @CONTINUE
@@4:
        MOV     Current_OS, _MSDOS     {...а остальные вообще MS-DOS }
        MOV     AX, WORD PTR VER
        XCHG    AH, AL
        MOV     OS_Version, AX
@CONTINUE:
        MOV     AX, WORD PTR VER
        XCHG    AH, AL
        MOV     DOS_Version, AX
end;

{$IFDEF ExitIfBadDOS}
{ может потребоваться останов программы при версии DOS < 3.20 }
If not GoodDOSVer Then
   begin WriteLn(ParamStr(0),': Need DOS 3.20 or latter.'); Halt(1) end;
{$ENDIF}

{ обычно происходит инициализация сразу при запуске программы, }
{ но Вы после можете повторить инициализацию, например после OS Shell. }

  MyINT13hVec := @MyINT13h;
  {$IFDEF IniDiskTable}
  InitDiskVariable
  {$ENDIF}

{$ELSE}
begin
WriteLn(^G'Вы не сможете откомпилировать этот модуль на TP версии ниже 6.0!');
{$ENDIF}
end. { Unit DskTools }

(************************************************************************

 Кроме примененных при написании программы, Вам наверняка будут
 интересны следующие сведения.

 ------------------------------------------------------------------------
INT 2F U - DOS 3+ internal - GET DOS DATA SEGMENT
	AX = 1203h
Return: DS = segment of IBMDOS.COM/MSDOS.SYS
 ------------------------------------------------------------------------
INT 2F U - DOS 3+ internal - GET CURRENT DIRECTRY STRUCTURE FOR DRIVE
	AX = 1217h
	SS = DOS DS
	STACK: WORD drive (0 = A:, 1 = B:, etc)
Return: CF set on error
	    (drive > LASTDRIVE)
	CF clear if successful
	    DS:SI -> current directory structure for specified drive
	STACK unchanged
SeeAlso: AX=1219h
 ------------------------------------------------------------------------
INT 2F U - DOS 3.3+ internal - GET DEVICE CHAIN
	AX = 122Ch
Return: BX:AX ->header of second device driver (NUL is first) in driver chain
SeeAlso: INT 21/AH=52h
 ------------------------------------------------------------------------
INT 2F U - DOS 3.3+ internal - SET FASTOPEN ENTRY POINT
	AX = 122Ah
	BX = entry point to set (0001h or 0002h)
	DS:SI -> FASTOPEN entry point
		(entry point not set if SI = FFFFh for DOS 4+)
Return: CF set if specified entry point already set
Notes:	entry point in BX is ignored under DOS 3.30
	both entry points set to same handler by DOS 4.01

DOS 3.30 FASTOPEN is called with:
	AL = 01h  ???
	    CX = ??? seems to be offset
	    DI = ??? seems to be offset
	    SI = offset in DOS DS of filename
	AL = 02h  ???
	AL = 03h  open file???
	    SI = offset in DOS DS of filename
	AL = 04h  ???
	    AH = subfunction (00h,01h,02h)
	    ES:DI -> ???
	    CX = ??? (subfunctions 01h and 02h only)
Returns: CF set on error or not installed
Note: function 03h calls function 01h first

PCDOS 4.01 FASTOPEN is additionally called with:
	AL = 04h ???
	    AH = 03h
	    ???
	AL = 05h ???
	AL = 0Bh ???
	AL = 0Ch ???
	AL = 0Dh ???
	AL = 0Eh ???
	AL = 0Fh ???
	AL = 10h ???
 ------------------------------------------------------------------------
INT 2F U - DOS 4+ internal - SET DOS VERSION NUMBER TO RETURN
	AX = 122Fh
	DX = DOS version number (0000h = return true DOS version)
Note:	not available under DR-DOS 5.0
SeeAlso: INT 21/AH=30h
 ------------------------------------------------------------------------
 ------------------------------------------------------------------------

 ************************************************************************


                  ИСТОЧНИКИ ДОПОЛНИТЕЛЬНОЙ ИНФОРМАЦИИ

!  [1] - Tech Help! (v3.20, v4.01) (C) Flambeaux Software.
*  [2] - Assembly Language database, (C) 1987 by Peter Norton Computing, Inc.
   [3] - Turbo Professional, (C) TurboPower Software. (v 5.xx TPDOS,...)
   [4] - Turbo Professional Doc, (v 5.0)
*  [5] - Interrupt List, (c) 1991 Ralf Brown, (C) 1991 Sergey Sotnikov
   [6] - Interrupt List, Release 36, (c) 1989-93 Ralf Brown.  {!!!}
*  [7] - Bios Technical Reference, (C) 1987-88 Wildmill Technologies Ltd.
   [8] - FORSIUK.M45 (Виктор Форсюк), заметка электронного бюллетеня
         SoftPanorama volume 4.5, (C) NeatAvia, 1992.
   [9] - DI.COM, Сусликов Евгений, (C) SEN.
  [10] - SysInfo.EXE  v6.01, Norton Utilities, (C) Symantec Corp. 1991.
  [11] - DiskEdit.EXE v6.01, Norton Utilities, (C) Symantec Corp. 1991.
  [12] - DiskReet.EXE v6.01, Norton Utilities, (C) Symantec Corp. 1991.
  [13] - NCache.EXE   v6.01, Norton Utilities, (C) Symantec Corp. 1991.
  [14] - VidRAM.COM, (C) 1989-90 Quarterdeck Office Systems, Inc.
  [15] - EGA2MEM.COM, (C) Maxim Savchenko V., 1991 (v1.2)
  [16] - EGADisk.EXE v4.00, (C) P. Tsarenko, 1990.
  [17] - 800 II, V1.xx, Diskette BIOS Enhancer, (c) Alberto PASQUALE (ITALY)
  [18] - Скэнлон. Программирование на языке ассемблера.

>>
  - Знаком "*" отмечены электронные справочники, поддерживаемые
    The Norton Guides, v1.04, (c) 1987 by Peter Norton Computing, Inc.
  - Знаком "!" отмечены электронные справочники, поддерживаемые
    Help! version 4.xx. Copyright (c) 1985,89 by Flambeaux Software, Inc.

>>
    Местами в код вставлены комментарии - текст из Interrupt List.

>>
    Все "коктейли" из кода на  Паскале  и  Ассемблере  переписаны  в
    текст на ассемблере по просьбе  Березина  Антона,  что  упрощает
    адаптацию модуля (процедур) к любому  другому  языку  (Модула-2,
    Си, Ассемблер, Бейсик и т.д.).
    !!! Березин Антон уже перевел (изменил вызовы)  этот  модуль  на
    языки ASSEMBLER и MODULA-2, причем для  увеличения  компактности
    ассемблерный текст переписан с использованием SAT - оболочки для
    ассемблера (написана Антоном) при  соответствующем  типе  вызова
    ассемблерные библиотеки совместимы с компилиторами других языков
    (например Си).

>>
    Кроме указанных выше, в программе упоминались продукты фирм :

                    Borland International.
                    Microsoft Corp.
                    Digital Research Inc.
                    IBM Corp.
                    PKWARE Inc.
                    JohnPC.
                    Central Point Software, Inc.
                    Compact Soft.
                    HyperWare.

 ***********************************************************************

 Организована группа программистов GalaSoft United Group International
 (организаторы Зулин Борис, Березин Антон), цель группы - помощь в
 распространении программ, консультации по их использованию и обмен
 модулями и новой информацией.

 Если Вам удобнее, можете обращаться :

 320038, Украина г. Днепропетровск,
 (0562) 50-40-84 (д), 47-14-72 (сл). Березин Антон.

 ***********************************************************************

 (C) BZSoft Inc., сентябрь 1992. 
 г.Шебекино. (04872) 4-51-96 (д, выходн.дни), 
 г.Харьков.  (0572)  400-875 (р). Зулин Борис.

 ***********************************************************************)
