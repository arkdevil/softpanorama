{$A+,B-,D+,E-,F-,G-,I+,L+,N-,O-,P-,Q-,R-,S+,T-,V+,X+}
{$M $2000,0,0}
Program VCA_demo; {Программа поиска файлов оболочки VC (типа NCA) }
{ Зулин Борис, (8-0572)400-875, BZSoft Inc., 1993 }
{!! ПОКА только для VC, работающего в режиме SMALL.}
{Uses TPDos;}

{----------------------------------------------------------------------
        Вам будет интересно просмотреть набор процедур для VC

function SearchSignature(Signature : string) : pointer; assembler;
ищет блок VC в памяти

function VCWindow(Right : boolean) : VCWindowType;
выдает тип панели

procedure WriteVCWindType(T : VCWindowType);
выводит на экран тип панели, используется только в этом файле в качестве
демонствации

function GetVCFileName(Right : boolean; Num : byte) : string;
возвращает имя из указанной строки указанного окна

function NumFiles(Right : boolean) : byte;
всего файлов в окне

function NumFiles(Right : boolean) : byte;
текущий файл в окне

function TopFile(Right : boolean) : byte;
верхний файл в окне

function CurDir(Right : boolean) : string;
текущий подкаталог в окне
----------------------------------------------------------------------}
const ErrVCA : string[6] = ^G'VCA: ';
type

    VCWindowType = (Files,Tree,Info,View,NoWindow);

    Entry = record
      Name : array [1..12] of char;
      Attr : byte;
    end; {record}

    {Set1,Set2 - текущие параметры среды:
      1 : 0 = список файлов, 1 = Tree, 2 = Info, 3 = Quick View;
      2 : 0 = Brief, 1 = Full;
      3 : 0/1 невидимое/видимое окно;
      4 : 0/1 = не показывать/показывать скрытые файлы
      5 : 0/1 = все файлы/только выполняемые файлы
      6 : сортировка 0 = Name, 1 = Ext, 2 = Time, 3 = Size, 4 - Unsort
    }
    A68c = array [1..68] of char;
    PVC  = ^VC;
    VC   = record
      x1   : array [0..$0942] of byte;
      Set1 : array [1..20] of byte;
      CDir1: A68c;
      Cur1 : word;
      Up1  : word;
      Len1 : word;
      Dir1 : array [1..256] of Entry;
      Set2 : array [1..20] of byte;
      CDir2: A68c;
      Cur2 : word;
      Up2  : word;
      Len2 : word;
      Dir2 : array [1..256] of Entry;
      x2   : array [1..255] of byte;
      Right: boolean;
    end; {record}

var
    V : PVC;
    T : VCWindowType;
    i : integer;

function SearchSignature(Signature : string) : pointer; assembler;
VAR
    LastPSEG : WORD;
    PrefSEG  : WORD;
asm
        PUSH    DS           { сохраняем, т.к. будут изменены }
        PUSH    ES
        MOV     BX, PrefixSeg
        MOV     PrefSeg, BX
        LDS     SI, Signature
        CMP     BYTE PTR [SI], 0
        JZ      @NO
        MOV     AH, 52h
        INT     21h
        SUB     BX, 2
        JNC	@1
        MOV     AX, ES
        SUB     AX, 1000h
        MOV     ES, AX
@1:     MOV     AX, ES:[BX]
        MOV     ES, AX
        XOR     BX, BX
        MOV     LastPSEG, BX
        CLD

@SCAN:
        MOV     DI, 0117h
        LDS     SI, Signature
        XOR     CH, CH
        MOV     CL, BYTE PTR [SI]  { длина строки }
        INC     SI
  REPE  CMPSB                      { СРАВНИВАЕМ СИГНАТУРЫ }
        JNE     @NEXT
        MOV     AX, ES
        MOV     LastPSEG, AX       { СОХРАНЯЕМ НАЙДЕНЫЙ АДРЕС И }
                                   { ИЩЕМ ДАЛЬШЕ НА СЛУЧАЙ ВТОРОЙ КОПИИ }
@NEXT:
        XOR     BX, BX
        CMP     BYTE PTR ES:[BX], 'Z'
        JE      @END
        MOV     AX, ES
        MOV     BX, ES:[3]
        INC     BX
        ADD     AX, BX
        CMP     AX, PrefSEG        {НЕ ИСКАТЬ ДАЛЬШЕ СЕБЯ}
        JAE     @END
        MOV     ES, AX
        JMP     @SCAN
@END:
        MOV     AX, 0110h
        MOV     DX, LastPSEG       {БЕРЕМ ПОСЛЕДНЮЮ КОПИЮ}
        JMP     @QUIT
@NO:
        XOR     AX, AX
        MOV     DX, AX
@QUIT:
        POP     ES
        POP     DS
end;

function VCWindow(Right : boolean) : VCWindowType;
begin
  if Right Then begin
    if not boolean(V^.Set2[3]) Then begin VCWindow:=NoWindow; Exit end;
    VCWindow := VCWindowType(V^.Set2[1])
  end else begin
    if not boolean(V^.Set1[3]) Then begin VCWindow:=NoWindow; Exit end;
    VCWindow := VCWindowType(V^.Set1[1])
  end;
end;

procedure WriteVCWindType(T : VCWindowType);
begin
  case T of
   Files     : WriteLn('Список файлов');
   Tree      : WriteLn('Дерево каталогов');
   Info      : WriteLn('Информация');
   View      : WriteLn('Просмотр файлов');
   NoWindow  : WriteLn('погашено');
  end
end;

function GetVCFileName(Right : boolean; Num : byte) : string;
var E : Entry;
    x,
    S : string;
    i : byte;
begin
  if Right Then E := V^.Dir2[Num] else E := V^.Dir1[Num];
  S := '';
  if (E.Attr and $01) = $01 Then S:=S+'R/o ' else S:=S+'___ ';
  if (E.Attr and $02) = $02 Then S:=S+'Hid ' else S:=S+'___ ';
  if (E.Attr and $04) = $04 Then S:=S+'Sys ' else S:=S+'___ ';
  if (E.Attr and $20) = $20 Then S:=S+'Arc ' else S:=S+'___ ';
  if (E.Attr and $10) = $10 Then S:=S+'Dir ' else S:=S+'___ ';
  if (E.Attr and $40) = $40 Then S:=S+'Selected ' else S:=S+'________ ';
  X:= E.Name;
  i := pos(#0,X); if i>0 Then X[0]:=char(i);
  GetVCFileName := S + X;
end;

function NumFiles(Right : boolean) : byte;
var W : word;
begin
  if Right Then W := V^.Len2 else W := V^.Len1;
  NumFiles := (W-$262) div 24;
end;

function CurFile(Right : boolean) : byte;
var W : word;
begin
  if Right Then W := V^.Cur2 else W := V^.Cur1;
  CurFile := (W-$262) div 24 + 1;
end;

function TopFile(Right : boolean) : byte;
var W : word;
begin
  if Right Then W := V^.Up2 else W := V^.Up1;
  TopFile := (W-$262) div 24 + 1;
end;

function CurDir(Right : boolean) : string;
var CDir: A68c;
begin
  if Right Then CDir := V^.CDir2 else CDir := V^.CDir1;
  CurDir := copy(CDir,1,pos(#0,CDir)-1);
end;

begin
  V := SearchSignature('COMMAND.COM'#0#10'VVV');
  if (V = NIL)  Then begin
    {if HandleIsConsole(StdOutHandle) Then}
    WriteLn(ErrVCA+'VCommander not found.');
    Halt(1);
  end;
  Write('Активна '); if V^.Right Then Write('правая') else Write('левая');
  WriteLn(' панель');
  Write('Левое окно - '); T := VCWindow(false); WriteVCWindType(T);
  if T=Files Then begin
    WriteLn('Текущий каталог ',CurDir(false));
    for i:=1 to NumFiles(false) do WriteLn(GetVCFileName(false,i));
  end;
  Write('Правое окно - '); T := VCWindow(true); WriteVCWindType(T);
  if T=Files Then begin
    WriteLn('Текущий каталог ',CurDir(true));
    for i:=1 to NumFiles(true) do WriteLn(GetVCFileName(true,i));
  end;

end.
