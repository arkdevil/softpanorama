{$A+,B-,D+,E-,F-,G-,I-,L+,N-,O-,P-,Q-,R-,S-,T-,V+,X+}
{$M $4000,0,$20000}
program VC_Color; {Программа раскрашивания Волков-командера}
{Зулин Борис, (8-0572)400-875, BZSoft Inc., 1993 }
uses TPCrt,Dos,TPString;
{В файле VC.INI с о смещения B4h начинается таблица цветов, пачками по 6 байт
 для каждого цвета - по слову на режим (черно-белый, цветной, лаптоп), где
 в слове один байт под моду 3, а другой - под 7}
const DataSize = 436;
      Ind      = 3;  {Color mode 3}
      MenuItem : array[1..38] of string[58] = (
   {123456789012345678901234567890123456789012345678901234567890}
{ 1}'Цифры - номера функциональных клавиш в KEY BAR           ',
{ 2}'Поле описания функциональных клавиш в KEY BAR            ',
{ 3}'Строка главного МЕНЮ, Title-строка в View и Edit         ',
{ 4}'Поле окон                                                ',
{ 5}'Указатель текущего файла                                 ',
{ 6}'Заголовок столбца                                        ',
{ 7}'Текущ. подкат. в панели дерева, отмеченные файлы         ',
{ 8}'Указатель на выделенном файле                            ',
{ 9}'Окно ошибки                                              ',
{10}'Буква при запросе на перевыбор устройства при сбое       ',
{11}'Окошки сообщений, диалогов                               ',
{12}'Слово right (left) при выборе дисков из списка           ',
{13}'Кнопка подтверждения в диалоге                           ',
{14}'Курсор в главном МЕНЮ                                    ',
{15}'Рамочки в падающем меню                                  ',
{16}'Поле в падающем меню                                     ',
{17}'Активные буквы в падающем меню                           ',
{18}'Выделенный пункт в падающем меню                         ',
{19}'Активная буква в выделенном пункте падающего меню        ',
{20}'Недоступный пункт в падающем меню                        ',
{21}'Текст USER MENU                                          ',
{22}'Выделенный пункт в USER MENU                             ',
{23}'Часики                                                   ',
{24}'Точки на звездном небе                                   ',
{25}'Минус перед запрещенным пунктом падающего меню           ',
{26}'Звезды на звездном небе                                  ',
{27}'Выделенные слова при запросах (DELETING)                 ',
{28}'Стрелки во вьювере и редакторе, когда длинный текст      ',
{29}'Окна CONFIGURATION, MEM, INFO, NCD, FF                   ',
{30}'TITLE подокон                                            ',
{31}'Выделенный текст в подокнах                              ',
{32}'Текущий подкаталог, и на котором стоит указатель в NCD   ',
{33}'Линии обрамления подсказки при редакт. файлов расширений ',
{34}'Окно подсказки в редакторе файлов расширений             ',
{35}'Текст HELP                                               ',
{36}'Заголовок текущего текста в HELP''е                       ',
{37}'Указатель в HELP''е                                       ',
{38}'Выделенный текст в HELP''е                                ');

{-------------------------------------------------------------------}
  Group1 : array[1..25] of string[58] = (
    {         1         2         3         4         5         6}
    {123456789012345678901234567890123456789012345678901234567890}
{ 1}'╔════════════╤══ C:\DOS ════════╤═ 4:55p',
{ 2}'║    Name    │   Size  │  Date  │ Time ║',
{ 3}'║..          │UP--DIR│10-29-91│ 2:55p║',
{ 4}'║append   exe│     8169╔════════════════ Tree ═══════════',
{ 5}'║assign   com│     6399║ \                               ',
{ 6}'║ba                    ║ ├──SYS                          ',
{ 7}'║ba   ╔══════ Drive let║ ├─▌DOS         ▐                ',
{ 8}'║bc   ║    Choose left ║ ├──NC                           ',
{ 9}'║ca   ║  A   B   C   D ║ ├─▌EXEC        ▐                ',
{10}'║ch   ╚════════════════║ ├──DRV                          ',
{11}'║co                    ║                                 ',
{12}'║cyrdos   com│      740║   ╔════════ User Menu ═══════╗  ',
{13}'║diskcopy com│    11793║   ║ F2   Turbo Pascal 7.0    ║  ',
{14}'║doshelp  hlp│     8133║   ║ F3   Norton Guide 1.04   ║  ',
{15}'║doskey   com│     5883║   ║ F4   Multi Edit 6.10     ║  ',
{16}'║dosswap  exe│    18756║   ╚══════════════════════════╝  ',
{17}'║exe2bin  exe│     8424║                                 ',
{18}'║fastopen exe│    12050║ ├──SPELL                        ',
{19}'║fc       exe│    18650║ └──SAVE                         ',
{20}'║fdisk    exe│    29312║                                 ',
{21}'╟────────────┴─────────║                                 ',
{22}'║   39,124 bytes in 3 s║                                 ',
{23}'╚══════════════════════║                                 ',
{24}'C:\DOS>                ╟─────────────────────────────────',
{25}'1Help   2Menu   3View  ║C:\DOS                           ');
    {123456789012345678901234567890123456789012345678901234567890}

{-------------------------------------------------------------------}
  Group2 : array[1..25] of string[58] = (
    {         1         2         3         4         5         6}
    {123456789012345678901234567890123456789012345678901234567890}
{ 1}'    Left    Files    Commands    Options                 ',
{ 2}'  ┌───────────────────────┐                              ',
{ 3}'  │  Brief                │                ∙         ∙   ',
{ 4}'  │  Full                 │                              ',
{ 5}'  │  Info                 │       ∙                      ',
{ 6}'  │  Tree                 │                              ',
{ 7}'  │  quick View           │        *              ∙      ',
{ 8}'  │√ On/Off       Ctrl-F1 │                              ',
{ 9}'  │ ───────────────────── │                              ',
{10}'  │  Name                 │                              ',
{11}'  │  eXtension            │                              ',
{12}'  │  tiMe                 │            ∙                 ',
{13}'  │  Size                 │                        ∙     ',
{14}'  │  Unsorted             │                              ',
{15}'  │ ───────────────────── │                              ',
{16}'  │  Re-read              │                             ',
{17}'  │ -fiLter...            │                              ',
{18}'  │  Drive...     Alt-F1  │          ∙                   ',
{19}'  └───────────────────────┘                        ∙     ',
{20}'                                             ■           ',
{21}'                          ∙                              ',
{22}'       ∙                                                ',
{23}'                                                         ',
{24}'                    ∙                    ∙               ',
{25}'                                                         ');
    {123456789012345678901234567890123456789012345678901234567890}

{-------------------------------------------------------------------}
  Group3 : array[1..25] of string[58] = (
    {         1         2         3         4         5         6}
    {123456789012345678901234567890123456789012345678901234567890}
{ 1}'Edit: C:\NC\vc.ext                    *  Line 1     Col 1',
{ 2}'pas:    d:\tp\╔═══════════ Chose Directory ════════════╗',
{ 3}'asm:    tasm /║     ├──BGI                             ║',
{ 4}'obj:    tlink ║     ├─ ARC                            ║',
{ 5}'arc:    pkxarc ║     ├──B-TREE                          ║',
{ 6}'zip:    un !.! ║     ├──DIR                             ║',
{ 7}'ice:    lha ╔══════════════════ Error ══════════════════╗',
{ 8}'lzh:    lha ║      Can''t read the disk in drive A:      ║',
{ 9}'pak:    unpa║  Press ENTER to try again, ESC to abort,  ║',
{10}'pc╔══════════════════ Edit ══════════════════╗r here A: ║',
{11}'pi║ You''ve made changes since the last save. ║══════════╝',
{12}'pr║   Save   Don''t save   Continue editing   ║          ║',
{13}'st╚═══════════════════════════╔═════════ Delete ════════╗',
{14}'arj:    x !.!  ║     ├──PK    ║     You are DELETING    ║',
{15}'gif:    gif !.!║     ├──PLOT  ║       5 files from      ║',
{16}'▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄║     ├──QRS   ║        D:\TP\EXEC       ║',
{17}' ╔═════════════╟──────────────║  Delete   All   Cancel  ║',
{18}' ║ Format of th║ D:\TP\EXEC   ╚═════════════════════════╝',
{19}' ║ '' comment   ║ Speed search:                         ║',
{20}' ║ txt: edit !.╚══════════════════┌ Screen colors ──────┐',
{21}' ║     cls           Any addition│  ( ) Black & White  │',
{22}' ║  └──────────────── File extensi│  () Color          │',
{23}' ╚════════════════════════════════│  ( ) Laptop         │',
{24}'▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀└─────────────────────┘',
{25}'1Help   2Save   3       4Hex    5       6       7Search 8');
    {123456789012345678901234567890123456789012345678901234567890}
{-------------------------------------------------------------------}
  Group4 : array[1..22] of string[58] = (
    {         1         2         3         4         5         6}
    {123456789012345678901234567890123456789012345678901234567890}
{ 2}'╔═════════════════════════════ Help ═════════════════════',
{ 3}'║ Configuration...                                       ',
{ 4}'╟────────────────────────────────────────────────────────',
{ 5}'║  This dialog box  allows you ╔═════════════════════════',
{ 6}'║  options.  Use the cursor ke ║               The Norton',
{ 7}'║  to change, and use the Spac ╟─────────────────────────',
{ 8}'║  Enter to accept the dialog  ║  About the Commander    ',
{ 9}'║                              ║  Keyboard reference     ',
{10}'║  ┌ Screen colors ──────┐  Th ║  View -- Keyboard refere',
{11}'║  │  ( ) Black & White  │  wh ║  View -- Status line    ',
{12}'║  │  () Color          │  th ║  Edit -- Keyboard refere',
{13}'║  │  ( ) Laptop         │  la ║  Edit -- Status line    ',
{14}'║  └─────────────────────┘  co ║  Left/Right menu        ',
{15}'║                              ║       Brief/Full        ',
{16}'║  ┌ Screen blank delay ─┐  Th ║       Info              ',
{17}'║  │  ( ) 40 minutes     │  be ║       Tree              ',
{18}'╟───────────────────────────── ║       Quick View        ',
{19}'║        [ Next ]   [ Previous ║       On/Off            ',
{20}'╚═════════════════════════════ ║       Sorting order for ',
{21}'                               ╟─────────────────────────',
{22}'                               ║                      [ H',
{23}'                               ╚═════════════════════════');
    {123456789012345678901234567890123456789012345678901234567890}

{-------------------------------------------------------------------}

  U : byte =0;
  Y : byte =1;

const
   _Esc  = $011B;
   _Enter= $1C0D;
   _Up   = $4800;
   _Lf   = $4B00;
   _Rt   = $4D00;
   _Down = $5000;

type
     ColorArr = array[1..6] of byte;
     IniRec = record
       B1  : array[1..179] of byte;
       C   : array[1..38]  of ColorArr;
       B2  : array[1..29]  of byte;
       CRC : word;
     end; {record}

var F     : file of IniRec;
    B     : IniRec;
    X1,X2 : byte;
    i,j   : integer;
    Color : byte;
    Key   : word;
    Name  : string;

procedure CRC; assembler;
asm
        LEA     BX, B
        MOV     CX, DataSize;
        XOR     AX, AX
@LOOP:
        ADD     AL, BYTE PTR [BX]
        JNC     @NEXT
        INC     AH
@NEXT:
        INC     BX
        LOOP    @LOOP
        MOV     WORD PTR B.CRC, AX
end; {asm}

procedure SetColor(Color : byte);
begin
  GotoXYAbs( 61 + Color mod 16, 5 + Color div 16);
  FastWrite(HexB(Color)+'h  '+LeftPad(Long2Str(Color),3),3,62,30);
  FastWrite('XXX',3,71,Color);
  case Color mod 16 of
  0 : FastWrite('Черный      ',22,65,30);
  1 : FastWrite('Синий       ',22,65,30);
  2 : FastWrite('Зеленый     ',22,65,30);
  3 : FastWrite('Циан        ',22,65,30);
  4 : FastWrite('Красный     ',22,65,30);
  5 : FastWrite('Лиловый     ',22,65,30);
  6 : FastWrite('Коричневый  ',22,65,30);
  7 : FastWrite('Белый       ',22,65,30);
  8 : FastWrite('Серый       ',22,65,30);
  9 : FastWrite('Ярко синий  ',22,65,30);
 10 : FastWrite('Ярко зеленый',22,65,30);
 11 : FastWrite('Ярко циан   ',22,65,30);
 12 : FastWrite('Ярко красный',22,65,30);
 13 : FastWrite('Ярко лиловый',22,65,30);
 14 : FastWrite('Желтый      ',22,65,30);
 15 : FastWrite('Ярко белый  ',22,65,30);
 end; {case}
  case Color div 16 of
  0,8  : FastWrite('на черном    ',23,65,30);
  1,9  : FastWrite('на синем     ',23,65,30);
  2,10 : FastWrite('на зеленом   ',23,65,30);
  3,11 : FastWrite('на циане     ',23,65,30);
  4,12 : FastWrite('на красном   ',23,65,30);
  5,13 : FastWrite('на лиловом   ',23,65,30);
  6,14 : FastWrite('на коричневом',23,65,30);
  7,15 : FastWrite('на белом     ',23,65,30);
 end; {case}

end;

procedure SelectColor(Item : byte);
var {W : WindowPtr;}
    i,j  : byte;
    Code : byte;
    C    : byte;
    P    : pointer;
procedure GetColor;
label Next;
var Key : word;
begin
Next:
  Key := ReadKeyWord;
  case Key of
  _Enter : Code := 1;
  _Esc   : Code := 2;
  _Up    : if (C div 16) = 0  Then C:=C+$F0 else Dec(C,16);
  _Down  : if (C div 16) = 15 Then C:=C mod 16 else Inc(C,16);
  _Rt    : if (C mod 16) = 15 Then Dec(C,15) else Inc(C);
  _Lf    : if (C mod 16) = 0  Then Inc(C,15) else Dec(C);
  else Goto Next;
  end; {case}
end;
procedure Colorize1;
var i: byte;
begin
  case Item of
   1 : begin
         ChangeAttribute(1,25, 1,C);
         ChangeAttribute(2,25, 8,C);
         ChangeAttribute(2,25,16,C);
       end;
   2 : begin
         ChangeAttribute(6,25, 2,C);
         ChangeAttribute(6,25,10,C);
         ChangeAttribute(6,25,18,C);
       end;
   4 : begin
         ChangeAttribute(16, 1, 1,C); ChangeAttribute(10, 1,25,C);
         ChangeAttribute( 1, 2, 1,C); ChangeAttribute( 1, 2,14,C);
         ChangeAttribute( 1, 2,24,C); ChangeAttribute( 1, 2,33,C);
         ChangeAttribute( 1, 2,40,C); ChangeAttribute(40, 3, 1,C);
         ChangeAttribute(57, 4, 1,C); ChangeAttribute(57, 4, 1,C);
         ChangeAttribute(57, 5, 1,C); ChangeAttribute(34, 6,24,C);
         for i:=6 to 11 do ChangeAttribute( 3, i, 1,C);
         ChangeAttribute( 4, 7,24,C); ChangeAttribute(16, 7,42,C);
         ChangeAttribute(34, 8,24,C); ChangeAttribute(34,10,24,C);
         ChangeAttribute( 4, 9,24,C); ChangeAttribute(16, 9,42,C);
         ChangeAttribute( 2,11,24,C);
         for i:=12 to 14 do ChangeAttribute(25, i, 1,C);
         ChangeAttribute(25,16, 1,C); ChangeAttribute( 2,16,24,C);
         ChangeAttribute( 1,15, 1,C); ChangeAttribute( 2,15,24,C);
         ChangeAttribute( 1,17, 1,C); ChangeAttribute( 2,17,24,C);
         ChangeAttribute( 1,18, 1,C); ChangeAttribute(34,18,24,C);
         ChangeAttribute( 1,19, 1,C); ChangeAttribute( 4,19,24,C);
         ChangeAttribute(16,19,42,C);
         ChangeAttribute(57,20, 1,C); ChangeAttribute(57,21, 1,C);
         ChangeAttribute(57,23, 1,C);
         ChangeAttribute( 1,22, 1,C); ChangeAttribute(34,22,24,C);
         ChangeAttribute(34,24,24,C); ChangeAttribute(34,25,24,C);
       end;
   5 : begin
         ChangeAttribute(22,15, 2,C); ChangeAttribute( 8, 1,17,C);
         ChangeAttribute(14,19,28,C);
       end;
   6 : begin
         ChangeAttribute(12, 2, 2,C); ChangeAttribute( 9, 2,15,C);
         ChangeAttribute( 8, 2,25,C); ChangeAttribute( 6, 2,34,C);
       end;
   7 : begin
         ChangeAttribute(22,18, 2,C); ChangeAttribute(22,19, 2,C);
         ChangeAttribute(14, 7,28,C); ChangeAttribute(22,22, 2,C);
       end;
   8 : begin
         ChangeAttribute(22,17, 2,C); ChangeAttribute(14, 9,28,C);
       end;
  11 : begin
         ChangeAttribute(20, 6, 4,C); ChangeAttribute(20, 7, 4,C);
         ChangeAttribute(20,10, 4,C); ChangeAttribute(20,11, 4,C);
         ChangeAttribute(15, 8, 4,C); ChangeAttribute( 1, 8,23,C);
         ChangeAttribute(13, 9, 4,C); ChangeAttribute( 4, 9,20,C);
       end;
  12 : ChangeAttribute( 4, 8,19,C);
  13 : ChangeAttribute( 3, 9,17,C);
  21 : begin
         ChangeAttribute(32,11,26,C); ChangeAttribute(32,12,26,C);
         ChangeAttribute(32,14,26,C); ChangeAttribute(32,15,26,C);
         ChangeAttribute(32,16,26,C); ChangeAttribute(32,17,26,C);
         ChangeAttribute( 3,13,26,C); ChangeAttribute( 3,13,55,C);
       end;
  22 : ChangeAttribute(26,13,29,C);
  23 : begin
         ChangeAttribute( 6, 1,35,C); ChangeAttribute( 1, 1,37,C or $80);
       end;
  end; {case}
end; {Colorize1}

procedure Colorize2;
var i : integer;
begin
  case Item of
    3  : begin
         ChangeAttribute( 2, 1, 1,C); ChangeAttribute(47, 1,11,C);
         end;
    14 : ChangeAttribute( 8, 1, 3,C);
    15 : begin
         for i:=2 to 19 do begin
           ChangeAttribute( 1, i, 3,C); ChangeAttribute( 1, i,27,C);
         end;
         ChangeAttribute(23, 2, 4,C); ChangeAttribute(23, 9, 4,C);
         ChangeAttribute(23,15, 4,C); ChangeAttribute(23,19, 4,C);
         end;
    16 : begin
         ChangeAttribute( 2, 3, 4,C); ChangeAttribute(20, 3, 7,C);
         ChangeAttribute( 2, 4, 4,C); ChangeAttribute(20, 4, 7,C);
         ChangeAttribute( 2, 5, 4,C); ChangeAttribute(20, 5, 7,C);
         ChangeAttribute( 2, 6, 4,C); ChangeAttribute(20, 6, 7,C);
         ChangeAttribute( 8, 7, 4,C); ChangeAttribute(14, 7,13,C);
         ChangeAttribute( 2,10, 4,C); ChangeAttribute(20,10, 7,C);
         ChangeAttribute( 3,11, 4,C); ChangeAttribute(19,11, 8,C);
         ChangeAttribute( 4,12, 4,C); ChangeAttribute(18,12, 9,C);
         ChangeAttribute( 2,13, 4,C); ChangeAttribute(20,13, 7,C);
         ChangeAttribute( 2,14, 4,C); ChangeAttribute(20,14, 7,C);
         ChangeAttribute( 2,16, 4,C); ChangeAttribute(20,16, 7,C);
         ChangeAttribute( 2,18, 4,C); ChangeAttribute(20,18, 7,C);
         end;
    17 : begin
         ChangeAttribute( 1, 3, 6,C); ChangeAttribute( 1, 4, 6,C);
         ChangeAttribute( 1, 5, 6,C); ChangeAttribute( 1, 6, 6,C);
         ChangeAttribute( 1, 7,12,C); ChangeAttribute( 1,10, 6,C);
         ChangeAttribute( 1,11, 7,C); ChangeAttribute( 1,12, 8,C);
         ChangeAttribute( 1,13, 6,C); ChangeAttribute( 1,14, 6,C);
         ChangeAttribute( 1,16, 6,C); ChangeAttribute( 1,18, 6,C);
         end;
    18 : begin
         ChangeAttribute( 2, 8, 4,C); ChangeAttribute(20, 8, 7,C);
         end;
    19 : ChangeAttribute( 1, 8, 6,C);
    20 : begin
         ChangeAttribute( 1,17, 4,C); ChangeAttribute(21,17, 6,C);
         end;
    24 : begin
         for i:= 2 to 19 do ChangeAttribute( 2, i, 1,C);
         for i:= 2 to  6 do ChangeAttribute(30, i,28,C);
         for i:= 8 to 15 do ChangeAttribute(30, i,28,C);
         for i:=17 to 19 do ChangeAttribute(30, i,28,C);
         for i:=23 to 25 do ChangeAttribute(57, i, 1,C);
         ChangeAttribute(57,21, 1,C);
         ChangeAttribute( 8, 7,28,C); ChangeAttribute(21, 7,37,C);
         ChangeAttribute(19,16,28,C); ChangeAttribute(10,16,48,C);
         ChangeAttribute(45,20, 1,C); ChangeAttribute(11,20,47,C);
         ChangeAttribute(34,22, 1,C); ChangeAttribute(22,22,36,C);
         end;
    25 : ChangeAttribute( 1,17, 5,C);
    26 : begin
         ChangeAttribute( 1, 7,36,C); ChangeAttribute( 1,16,47,C);
         ChangeAttribute( 1,20,46,C); ChangeAttribute( 1,22,35,C);
         end;
  end; {case}
end; {Colorize2}

procedure Colorize3;
var i : integer;
begin
  case Item of
    9  : begin
         ChangeAttribute(45, 7,13,C); ChangeAttribute(45, 8,13,C);
         ChangeAttribute(45, 9,13,C); ChangeAttribute(51,10, 3,C);
         ChangeAttribute( 3,10,55,C); ChangeAttribute(55,11, 3,C);
         ChangeAttribute( 3,12, 3,C); ChangeAttribute(35,12,12,C);
         ChangeAttribute(55,13, 3,C); ChangeAttribute(14,14,31,C);
         ChangeAttribute( 5,14,53,C); ChangeAttribute(27,15,31,C);
         ChangeAttribute(27,16,31,C); ChangeAttribute( 2,17,31,C);
         ChangeAttribute(17,17,41,C); ChangeAttribute(27,18,31,C);
         end;
    10 : begin
         ChangeAttribute( 1,10,54,C); ChangeAttribute( 6,12, 6,C);
         ChangeAttribute( 8,17,33,C);
         end;
    27 : ChangeAttribute( 8,14,45,C);
    28 : begin
         ChangeAttribute( 1, 2, 1,C); ChangeAttribute( 1, 3, 1,C);
         ChangeAttribute( 1, 4, 1,C);
         end;
    29 : begin
         ChangeAttribute(42, 2,16,C); ChangeAttribute(42, 3,16,C);
         ChangeAttribute(42, 5,16,C); ChangeAttribute(42, 6,16,C);
         ChangeAttribute(20,20,16,C); ChangeAttribute( 8, 4,16,C);
         ChangeAttribute(17, 4,38,C); ChangeAttribute( 2, 4,56,C);
         for i:=14 to 19 do ChangeAttribute(15, i,16,C);
         ChangeAttribute(15,19,43,C); ChangeAttribute(11,12,47,C);
         ChangeAttribute( 7,20,51,C); ChangeAttribute(23,21,35,C);
         ChangeAttribute(23,22,35,C); ChangeAttribute(23,23,35,C);
         ChangeAttribute(23,24,35,C);
         end;
    30 : begin
         ChangeAttribute( 1, 4,55,C); ChangeAttribute(15,20,36,C);
         end;
    31 : ChangeAttribute(12,19,31,C or Blink);
    32 : ChangeAttribute(14, 4,24,C);
    33 : begin
         ChangeAttribute(15,16, 1,C); ChangeAttribute(34,24, 1,C);
         end;
    34 : begin
         ChangeAttribute(15,17, 1,C); ChangeAttribute(15,18, 1,C);
         ChangeAttribute(15,19, 1,C); ChangeAttribute(15,20, 1,C);
         ChangeAttribute(34,21, 1,C); ChangeAttribute(34,22, 1,C);
         ChangeAttribute(34,23, 1,C);
         end;
  end; {case}
end; {Colorize3}

procedure Colorize4;
var i : integer;
begin
  case Item of
    35 : begin
         ChangeAttribute(57, 2, 1,C); ChangeAttribute(57, 4, 1,C);
         ChangeAttribute(57, 5, 1,C);
         for i:=11 to 15 do ChangeAttribute(57, i, 1,C);
         for i:=17 to 18 do ChangeAttribute(57, i, 1,C);
         ChangeAttribute(57,20, 1,C); ChangeAttribute(27,21,31,C);
         ChangeAttribute(24,22,31,C); ChangeAttribute(27,23,31,C);
         ChangeAttribute( 2, 3, 1,C); ChangeAttribute(39, 3,19,C);
         ChangeAttribute(21, 6, 1,C); ChangeAttribute(30, 6,28,C);
         ChangeAttribute(26, 7, 1,C); ChangeAttribute(27, 7,31,C);
         ChangeAttribute( 3, 8, 1,C); ChangeAttribute(49, 8, 9,C);
         ChangeAttribute(32, 9, 1,C);
         ChangeAttribute( 5,10, 1,C); ChangeAttribute(39,10,19,C);
         ChangeAttribute( 5,16, 1,C); ChangeAttribute(34,16,24,C);
         ChangeAttribute( 9,19, 1,C); ChangeAttribute(40,19,18,C);
         end;
    36 : begin
         ChangeAttribute(16, 3, 3,C); ChangeAttribute(13,10, 6,C);
         ChangeAttribute(18,16, 6,C);
         end;
    37 : begin
         ChangeAttribute( 8,19,10,C); ChangeAttribute( 3,22,55,C);
         ChangeAttribute(25, 9,33,C);
         end;
    38 : begin
         ChangeAttribute( 6, 6,22,C); ChangeAttribute( 4, 7,27,C);
         ChangeAttribute( 5, 8, 4,C);
         end;
  end; {case}
end; {Colorize4}
begin
Code :=0;
C := B.C[Item,Ind];
TextAttr:=7;
if not SaveWindow(1,1,59,25,True,P) Then Exit;
Window(1,1,59,25); ClrScr; Window(1,1,80,25);
case Item of
1,2,4,5,6,7,8,11,12,13,21,22,23 : begin
  for i :=1 to 25 do FastWrite(Group1[i],i,1,B.C[4,Ind]);
ChangeAttribute(23,24, 1,7);
ChangeAttribute( 1,25, 1,B.C[ 1,Ind]); ChangeAttribute( 2,25, 8,B.C[ 1,Ind]);
ChangeAttribute( 2,25,16,B.C[ 1,Ind]); ChangeAttribute( 6,25, 2,B.C[ 2,Ind]);
ChangeAttribute( 6,25,10,B.C[ 2,Ind]); ChangeAttribute( 6,25,18,B.C[ 2,Ind]);
ChangeAttribute(22,15, 2,B.C[ 5,Ind]); ChangeAttribute( 8, 1,17,B.C[ 5,Ind]);
ChangeAttribute(14,19,28,B.C[ 5,Ind]);
ChangeAttribute(12, 2, 2,B.C[ 6,Ind]); ChangeAttribute( 9, 2,15,B.C[ 6,Ind]);
ChangeAttribute( 8, 2,25,B.C[ 6,Ind]); ChangeAttribute( 6, 2,34,B.C[ 6,Ind]);
ChangeAttribute(22,18, 2,B.C[ 7,Ind]); ChangeAttribute(22,19, 2,B.C[ 7,Ind]);
ChangeAttribute(14, 7,28,B.C[ 7,Ind]); ChangeAttribute(22,22, 2,B.C[ 7,Ind]);
ChangeAttribute(22,17, 2,B.C[ 8,Ind]); ChangeAttribute(14, 9,28,B.C[ 8,Ind]);
ChangeAttribute(20, 6, 4,B.C[11,Ind]); ChangeAttribute(20, 7, 4,B.C[11,Ind]);
ChangeAttribute(20,10, 4,B.C[11,Ind]); ChangeAttribute(20,11, 4,B.C[11,Ind]);
ChangeAttribute(15, 8, 4,B.C[11,Ind]); ChangeAttribute( 1, 8,23,B.C[11,Ind]);
ChangeAttribute(13, 9, 4,B.C[11,Ind]); ChangeAttribute( 4, 9,20,B.C[11,Ind]);
ChangeAttribute( 4, 8,19,B.C[12,Ind]); ChangeAttribute( 3, 9,17,B.C[13,Ind]);
ChangeAttribute(32,11,26,B.C[21,Ind]); ChangeAttribute(32,12,26,B.C[21,Ind]);
ChangeAttribute(32,14,26,B.C[21,Ind]); ChangeAttribute(32,15,26,B.C[21,Ind]);
ChangeAttribute(32,16,26,B.C[21,Ind]); ChangeAttribute(32,17,26,B.C[21,Ind]);
ChangeAttribute( 3,13,26,B.C[21,Ind]); ChangeAttribute( 3,13,55,B.C[21,Ind]);
ChangeAttribute(26,13,29,B.C[22,Ind]); ChangeAttribute( 6, 1,35,B.C[23,Ind]);
ChangeAttribute( 1, 1,37,B.C[23,Ind] or $80);
  end;
3,14,15,16,17,18,19,20,24,25,26 : begin
  for i :=1 to 25 do FastWrite(Group2[i],i,1,B.C[24,Ind]);
ChangeAttribute( 2, 1, 1,B.C[ 3,Ind]); ChangeAttribute(47, 1,11,B.C[ 3,Ind]);
ChangeAttribute( 8, 1, 3,B.C[14,Ind]);
for i:=2 to 19 do begin
  ChangeAttribute( 1, i, 3,B.C[15,Ind]); ChangeAttribute( 1, i,27,B.C[15,Ind]);
end;
ChangeAttribute(23, 2, 4,B.C[15,Ind]); ChangeAttribute(23, 9, 4,B.C[15,Ind]);
ChangeAttribute(23,15, 4,B.C[15,Ind]); ChangeAttribute(23,19, 4,B.C[15,Ind]);
ChangeAttribute( 2, 3, 4,B.C[16,Ind]); ChangeAttribute(20, 3, 7,B.C[16,Ind]);
ChangeAttribute( 2, 4, 4,B.C[16,Ind]); ChangeAttribute(20, 4, 7,B.C[16,Ind]);
ChangeAttribute( 2, 5, 4,B.C[16,Ind]); ChangeAttribute(20, 5, 7,B.C[16,Ind]);
ChangeAttribute( 2, 6, 4,B.C[16,Ind]); ChangeAttribute(20, 6, 7,B.C[16,Ind]);
ChangeAttribute( 8, 7, 4,B.C[16,Ind]); ChangeAttribute(14, 7,13,B.C[16,Ind]);
ChangeAttribute( 2,10, 4,B.C[16,Ind]); ChangeAttribute(20,10, 7,B.C[16,Ind]);
ChangeAttribute( 3,11, 4,B.C[16,Ind]); ChangeAttribute(19,11, 8,B.C[16,Ind]);
ChangeAttribute( 4,12, 4,B.C[16,Ind]); ChangeAttribute(18,12, 9,B.C[16,Ind]);
ChangeAttribute( 2,13, 4,B.C[16,Ind]); ChangeAttribute(20,13, 7,B.C[16,Ind]);
ChangeAttribute( 2,14, 4,B.C[16,Ind]); ChangeAttribute(20,14, 7,B.C[16,Ind]);
ChangeAttribute( 2,16, 4,B.C[16,Ind]); ChangeAttribute(20,16, 7,B.C[16,Ind]);
ChangeAttribute( 2,18, 4,B.C[16,Ind]); ChangeAttribute(20,18, 7,B.C[16,Ind]);
ChangeAttribute( 1, 3, 6,B.C[17,Ind]); ChangeAttribute( 1, 4, 6,B.C[17,Ind]);
ChangeAttribute( 1, 5, 6,B.C[17,Ind]); ChangeAttribute( 1, 6, 6,B.C[17,Ind]);
ChangeAttribute( 1, 7,12,B.C[17,Ind]); ChangeAttribute( 1,10, 6,B.C[17,Ind]);
ChangeAttribute( 1,11, 7,B.C[17,Ind]); ChangeAttribute( 1,12, 8,B.C[17,Ind]);
ChangeAttribute( 1,13, 6,B.C[17,Ind]); ChangeAttribute( 1,14, 6,B.C[17,Ind]);
ChangeAttribute( 1,16, 6,B.C[17,Ind]); ChangeAttribute( 1,18, 6,B.C[17,Ind]);
ChangeAttribute( 2, 8, 4,B.C[18,Ind]); ChangeAttribute(20, 8, 7,B.C[18,Ind]);
ChangeAttribute( 1, 8, 6,B.C[19,Ind]);
ChangeAttribute( 1,17, 4,B.C[20,Ind]); ChangeAttribute(21,17, 6,B.C[20,Ind]);
ChangeAttribute( 1,17, 5,B.C[25,Ind]);
ChangeAttribute( 1, 7,36,B.C[26,Ind]); ChangeAttribute( 1,16,47,B.C[26,Ind]);
ChangeAttribute( 1,20,46,B.C[26,Ind]); ChangeAttribute( 1,22,35,B.C[26,Ind]);
end;
9,10,27,28,29,30,31,32,33,34    : begin
  for i :=1 to 25 do FastWrite(Group3[i],i,1,B.C[4,Ind]);
  ChangeAttribute(57, 1, 1,B.C[ 3,Ind]);
  ChangeAttribute(57,25, 1,B.C[ 2,Ind]);
ChangeAttribute( 1,25, 1,B.C[ 1,Ind]); ChangeAttribute( 2,25, 8,B.C[ 1,Ind]);
ChangeAttribute( 2,25,16,B.C[ 1,Ind]); ChangeAttribute( 2,25,24,B.C[ 1,Ind]);
ChangeAttribute( 2,25,32,B.C[ 1,Ind]); ChangeAttribute( 2,25,40,B.C[ 1,Ind]);
ChangeAttribute( 2,25,48,B.C[ 1,Ind]); ChangeAttribute( 2,25,56,B.C[ 1,Ind]);
{---------------------------------------------------------------------------}
ChangeAttribute(45, 7,13,B.C[ 9,Ind]); ChangeAttribute(45, 8,13,B.C[ 9,Ind]);
ChangeAttribute(45, 9,13,B.C[ 9,Ind]); ChangeAttribute(51,10, 3,B.C[ 9,Ind]);
ChangeAttribute( 3,10,55,B.C[ 9,Ind]); ChangeAttribute(55,11, 3,B.C[ 9,Ind]);
ChangeAttribute( 3,12, 3,B.C[ 9,Ind]); ChangeAttribute(35,12,12,B.C[ 9,Ind]);
ChangeAttribute(55,13, 3,B.C[ 9,Ind]); ChangeAttribute(14,14,31,B.C[ 9,Ind]);
ChangeAttribute( 5,14,53,B.C[ 9,Ind]); ChangeAttribute(27,15,31,B.C[ 9,Ind]);
ChangeAttribute(27,16,31,B.C[ 9,Ind]); ChangeAttribute( 2,17,31,B.C[ 9,Ind]);
ChangeAttribute(17,17,41,B.C[ 9,Ind]); ChangeAttribute(27,18,31,B.C[ 9,Ind]);
ChangeAttribute( 1,10,54,B.C[10,Ind]); ChangeAttribute( 6,12, 6,B.C[10,Ind]);
ChangeAttribute( 8,17,33,B.C[10,Ind]); ChangeAttribute( 8,14,45,B.C[27,Ind]);
ChangeAttribute( 1, 2, 1,B.C[28,Ind]); ChangeAttribute( 1, 3, 1,B.C[28,Ind]);
ChangeAttribute( 1, 4, 1,B.C[28,Ind]);
ChangeAttribute(42, 2,16,B.C[29,Ind]); ChangeAttribute(42, 3,16,B.C[29,Ind]);
ChangeAttribute(42, 5,16,B.C[29,Ind]); ChangeAttribute(42, 6,16,B.C[29,Ind]);
ChangeAttribute(20,20,16,B.C[29,Ind]); ChangeAttribute( 8, 4,16,B.C[29,Ind]);
ChangeAttribute(17, 4,38,B.C[29,Ind]); ChangeAttribute( 2, 4,56,B.C[29,Ind]);
for i:=14 to 19 do ChangeAttribute(15, i,16,B.C[29,Ind]);
ChangeAttribute(15,19,43,B.C[29,Ind]); ChangeAttribute(11,12,47,B.C[29,Ind]);
ChangeAttribute( 7,20,51,B.C[29,Ind]); ChangeAttribute(23,21,35,B.C[29,Ind]);
ChangeAttribute(23,22,35,B.C[29,Ind]); ChangeAttribute(23,23,35,B.C[29,Ind]);
ChangeAttribute(23,24,35,B.C[29,Ind]);
ChangeAttribute( 1, 4,55,B.C[30,Ind]); ChangeAttribute(15,20,36,B.C[30,Ind]);
ChangeAttribute(12,19,31,B.C[31,Ind] or Blink);
ChangeAttribute(14, 4,24,B.C[32,Ind]);
ChangeAttribute(15,16, 1,B.C[33,Ind]); ChangeAttribute(34,24, 1,B.C[33,Ind]);
ChangeAttribute(15,17, 1,B.C[34,Ind]); ChangeAttribute(15,18, 1,B.C[34,Ind]);
ChangeAttribute(15,19, 1,B.C[34,Ind]); ChangeAttribute(15,20, 1,B.C[34,Ind]);
ChangeAttribute(34,21, 1,B.C[34,Ind]); ChangeAttribute(34,22, 1,B.C[34,Ind]);
ChangeAttribute(34,23, 1,B.C[34,Ind]);
end;
35,36,37,38                     : begin
  for i :=1 to 22 do FastWrite(Group4[i],i+1,1,B.C[35,Ind]);
  ChangeAttribute(30,21, 1,TextAttr); ChangeAttribute(30,22, 1,TextAttr);
  ChangeAttribute(30,23, 1,TextAttr);
ChangeAttribute(16, 3, 3,B.C[36,Ind]); ChangeAttribute(13,10, 6,B.C[36,Ind]);
ChangeAttribute(18,16, 6,B.C[36,Ind]);
ChangeAttribute( 8,19,10,B.C[37,Ind]); ChangeAttribute( 3,22,55,B.C[37,Ind]);
ChangeAttribute(25, 9,33,B.C[37,Ind]);
ChangeAttribute( 6, 6,22,B.C[38,Ind]); ChangeAttribute( 4, 7,27,B.C[38,Ind]);
ChangeAttribute( 5, 8, 4,B.C[38,Ind]);
end;
end; {case}

  repeat
    SetColor(C);
    GetColor;
    case Item of
    1,2,4,5,6,7,8,11,12,13,21,22,23 : Colorize1;
    3,14,15,16,17,18,19,20,24,25,26 : Colorize2;
    9,10,27,28,29,30,31,32,33,34    : Colorize3;
    35,36,37,38                     : Colorize4;
    end; {case}

  until Code>0;
  if Code=1 Then B.C[Item,Ind]:=C;
  RestoreWindow(1,1,59,25,True,P);
  SetColor(B.C[Item,Ind])
end;

begin
TextAttr := 30;
ClrScr;
if ParamCount>0 Then begin
   Name := ParamStr(1);
   if (pos('?',Name)>0) or (pos('/H',Name)>0) or (pos('/h',Name)>0) Then
   begin
     WriteLn('Эта программа предназначена для изменения цветов');
     WriteLn('в оболочке VCommander (VC)');
     WriteLn('Запуск: VC_COLOR [\путь\VC.INI]');
     WriteLn('Изменения вносятся только в файл VC.INI !');
   end
   end else Name := 'VC.INI';
Assign(F,Name);
Reset(F);
if IOResult<>0 Then begin
  WriteLn('Файл ',Name,' не найден или ошибка чтения');
  Halt(1);
end;
Read(F,B);
FastWrite('┌'+CharStr('─',16)+'┐', 2,60,31);
FastWrite('│'+CharStr(' ',16)+'│', 3,60,31);
FastWrite('├'+CharStr('─',16)+'┤', 4,60,31);
for i:=5 to 20 do FastWrite('│'+CharStr(' ',16)+'│', i,60,31);
FastWrite('└'+CharStr('─',16)+'┘',21,60,31);
for i:=0 to 15 do
  for j:=0 to 15 do FastWrite('*',5+i,61+j,i*16+j);
for i:=1 to 25 do FastWrite(MenuItem[i],i,1,30);

repeat
SetColor(B.C[Y+U,Ind]);
FastWrite(MenuItem[Y+U],U+1,1,112);
FastWrite(LeftPad(Long2Str(Y+U),2),3,75,31);
Key:=ReadKeyWord;
FastWrite(MenuItem[Y+U],U+1,1,30);
case Key of
  _Enter : SelectColor(Y+U);
  _Up : if U>0 Then Dec(U) else
           if Y>1 Then
              begin
                Dec(Y);
                for i:=1 to 25 do FastWrite(MenuItem[i+Y-1],i,1,30);
              end;
  _Down :if U<24 Then Inc(U) else
           if Y<14 Then
              begin
                Inc(Y);
                for i:=1 to 25 do FastWrite(MenuItem[i+Y-1],i,1,30);
              end;
end; {case}
until Key=_Esc;
CRC; Seek(F,0); Write(F,B);
if IOResult<>0 Then begin
  WriteLn('Ошибка записи');
end;
Close(F);
TextAttr:=7;
ClrScr;
WriteLn('VC Color, by BZSoft Inc., 1993');
end.
