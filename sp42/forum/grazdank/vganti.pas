{************************************}
{*    Turbo Pascal 4.0 - 6.0        *}
{*   Свободно для использования     *}
{*         и модификации            *}
{*----------------------------------*}
{*  Автор:  Гражданкин Валерий      *}
{*             г.Курск              *}
{*           VGSoft Inc.            *}
{************************************}

{*=======================================================*}
{*   P.S. Неудачен алгоритм построения дерева каталога : *}
{*                может не хватить памяти                *}
{*=======================================================*}

program VGAnti;
uses Dos, CRT {, AidsTst };
const
     Len=10;
     AidsDat:array[0..len-1] of byte=
     ($FA, $80, $FC, $3E, $75, $3, $E8, $5, $0, $EA );
type
    ByteArr = array [0..65534] of byte;

    PPath = ^PathRec;
    PathRec = record
             Path : PathStr;
             Next : PPath;
    end;

var Vec1o, Vec1s, Vec2o, Vec2s:word;
    I: integer;
    Buf, Buf1: ^ByteArr;
    Result, AIP : word;
    AOfs, VirOfs, VirLoc : longint;
    Vakcin : boolean;
    VS : string[20];
    FPath : PathStr;
    Sr:SearchRec;
    DiskName : String[2];
    F:file;
    Trees, PTree1 : PPath;

Procedure NextToSpis(Var PS: PPath; LPath: PathStr; Var Sr: SearchRec);
var P1 :PPath;
begin
     While DosError=0 do
     begin
          New(P1);
          P1^.Next:=PS;
          PS:=P1;
          PS^.Path:=DiskName+LPath+'\'+Sr.Name;
          FindNext(Sr);
     end;
end;

procedure MakeTree( Var PTree: PPath);
label 10, 20, 30;
type
     PDKats = ^DKats;
     DKats = record
          Name : String[14];
          Path : PathStr;
          Level : word;
          Pred  : PDKats;
          Right : PDKats;
          Left  : PDKats;
     end;

var  Sr, KSr : SearchRec;

     SP, LPath : PathStr;

     TekKat   : PDKats;
     WorkKat, OldLeft, OldPred  : PDKats;

     P1, P2 : PPath;
     CurLevel:word;
     CurPath :PathStr;
     IsOne   :Boolean;
begin

     While PTree<>nil do
     begin
          P1:=PTree;
          PTree:=PTree^.Next;
          Dispose(P1);
     end;

     FindFirst(DiskName+'\*.EXE', Archive, Sr);
     NextToSpis(PTree,'', Sr);


     SP:='';
     CurLevel:=1;
     CurPath :='\';

     New(TekKat);
     TekKat^.Pred:=nil;
     TekKat^.Left:=nil;
     TekKat^.Right:=nil;
     TekKat^.Level:=0;
     TekKat^.Name:='';
     TekKat^.Path:='\';
     FindFirst(DiskName+'\*.*', Directory, KSr);
     OldLeft:=TekKat;
     OldPred:=nil;
     IsOne:=false;

10:
     IsOne:=false;
     while DosError=0 do
     begin
         if (KSr.Name<>'.') and (KSr.Name<>'..') and (KSr.Attr=Directory) then
         begin
              IsOne:=true;
              New(WorkKat);
              WorkKat^.Pred:=OldPred;
              WorkKat^.Left:=OldLeft;
              WorkKat^.Right:=nil;
              WorkKat^.Name:=KSr.Name;
              WorkKat^.Level:=CurLevel;
              if CurPath='\' then WorkKat^.Path:=CurPath+KSr.Name
              else WorkKat^.Path:=CurPath+'\'+KSr.Name;
              TekKat:=WorkKat;
              OldLeft:=TekKat;
              OldPred:=nil;
{              Writeln(DiskName+TekKat^.Path);}

              FindFirst(DiskName+TekKat^.Path+'\*.EXE', Archive, Sr);
              NextToSpis(PTree,TekKat^.Path, Sr);

         end;
         FindNext(KSr);
     end;
     If IsOne then
     begin
20:
          CurPath:=TekKat^.Path;
          FindFirst(DiskName+CurPath+'\*.*', Directory, KSr);
          if DosError=0 then
          begin
               OldLeft:=nil;
               OldPred:=TekKat;
               goto 10;
          end;
     end;
30:
     if TekKat^.Left<>nil then
     begin
          TekKat:=TekKat^.Left;
          if TekKat^.Right<>nil then Dispose(TekKat^.Right);
          Goto 20;
     end;
     if TekKat^.Pred<>nil then
     begin
          TekKat:=TekKat^.Pred;
          if TekKat^.Right<>nil then Dispose(TekKat^.Right);
          Goto 30;
     end;
end;
begin
     writeln;
     writeln('VGAnti версия 1.0, автор В.Гражданкин.');
     writeln('(C) VGSoft, май, 1991 г.');
     writeln;
     writeln('Средство против вируса "AIDS"');
     writeln;

{     AidsControl(129,21,14);}

     Vakcin :=false;
     Vec1o:=MemW[0:$A];
     Vec1s:=MemW[0:$C];
     Vec2o:=MemW[0:$84];
     Vec2s:=MemW[0:$86];
     I:=0;
     While (I<len) and (Mem[Vec2s:Vec2o+I]=AidsDat[I]) do inc(I);
     if I>=Len then
     begin
          Writeln('Вирус "AIDS" в памяти Вашей машины !!!');
          MemW[0:$84]:=MemW[Vec2s:Vec2o+Len];
          MemW[0:$86]:=MemW[Vec2s:Vec2o+Len+2];
          writeln('Деятельность вируса блокирована .');
          inc(MemW[0:$413]);
          writeln('Вирус из памяти удален.');
          writeln;
     end;
     if paramcount<1 then
     begin
          writeln('Это моя первая антивирусная программа, так что не обижайтесь,');
          writeln('если она что-нибудь не так исправит. Пока VGAnti находит ');
          writeln('только "AIDS" и излечивает от него. Файлы, испорченные вирусом,');
          writeln('после запуска выдают на экран заставку и машина зависает.');
          writeln('Такие файлы легко обнаружить самому, они исправлению не подлежат');
          writeln('и их надо уничтожить. ');
          writeln;
          writeln('Формат запуска : VGAnti Диск /V');
          writeln('Например       : VGAnti C: /V');
          writeln('Флажок /V указывает на вакцинирование файлов (если возможно)');
          writeln('от повторного заражения "AIDS"');
          exit;
     end;
     DiskName:=ParamStr(1);
     DiskName[2]:=':';
     DiskName[1]:=UpCase(DiskName[1]);
     if paramcount>1 then
     begin
          VS:=ParamStr(2);
          if (VS='/v') or (VS='/V') then Vakcin:=true;
     end;


     TRees:=nil;
     MakeTree(Trees);

     GetMem(Buf, $1A);
     GetMem(Buf1, 10000);

     while Trees<>nil do
     begin
     Assign(F, Trees^.Path);
     {$I-}
     reset(F,1);
     {$I+}
     if IOResult<>0 then
     begin
          writeln('Ошибка ввода-вывода : ненормальное завершение .');
          exit;
     end;
     GotoXY(1, WhereY);
     ClrEol;
     write(Trees^.Path);
     BlockRead(F, Buf^, $1A, Result);
     if (Buf^[$13]=$19) and(Buf^[$12]=$90) then
     begin
          write(' - заражен "AIDS"');
          AOfs:=(Buf^[8]+Buf^[9]*256)*16;
          AIP:=Buf^[$14]+Buf^[$15]*256;
          VirOfs:=(Buf^[$16]+Buf^[$17]*256);
          VirLoc:=AOfs+AIP+VirOfs*16;
          Seek(F, VirLoc);
          BlockRead(F, Buf1^, 1000, Result);
          Buf^[$14]:=Buf1^[10];
          Buf^[$15]:=Buf1^[11];
          Buf^[$16]:=Buf1^[3];
          Buf^[$17]:=Buf1^[4];
          VirOfs:=VirLoc-$FF;
          AIP:=(VirOfs-AOfs) mod 512;
          Buf^[2]:=Lo(AIP);
          Buf^[3]:=Hi(AIP);
          AIP:=trunc(VirOfs/512);
          if AIP*512<VirOfs then inc(AIP);
          Buf^[4]:=Lo(AIP);
          Buf^[5]:=Hi(AIP);
If Vakcin then
          Buf^[$12]:=1 else Buf^[$12]:=0;
          Buf^[$13]:=0;
          Seek( F, 0);
          BlockWrite(F, Buf^, $1A, Result);
          Seek(F, VirLoc-$FF);
          Truncate(F);
          write(' : вылечен');
          if Buf^[$12] = 1 then writeln(' и вакцинирован') else writeln;
     end;
     close(F);
     PTree1:=Trees;
     Trees:=Trees^.Next;
     Dispose(PTree1);
     end;
     FreeMem(Buf, $1A);
     FreeMem(Buf1, 10000);
     gotoXy(1,WhereY);
     ClrEol;
     writeln('Работа закончена .');
end.