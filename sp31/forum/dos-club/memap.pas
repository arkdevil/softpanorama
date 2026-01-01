{$D-,I-,E-,N-,R-,S-,V-,B-}
{$M 16535, 0, 640000}
program Memap;

uses
  Dos,
  TPInline,
  TPDos,
  TPCrt,
  TPString,
  TPWindow,
  TPCmd,
  TPPick;

const
  _DOS        = $21;
  EmptyPath   = '';
  EmptyName   = '';
  FreeCh       = ' ';
  EvenCh      = '▀';
  OddCh       = '▄';
  FullCh      = '█';
  MapX        =  2;
  MapY        =  3;
  MapH        = 16;
  MapW        = 40;
  PickX       = MapX+MapW+5;
  PickY       = MapY+1;
  PickH       = MapH-1;
  PickW       = 31;
  InfoX       = MapX+1;
  InfoY       = 22;
  FirstInfoX  = 23;
  InfoW       = 80 - FirstInfoX - 1;
  KbPerSeg    = 64;
  SegPerKb    = 1024 div 16;
  Seg640      = 640 * SegPerKb;
  SegPerPoint = Seg640 div ( MapH * MapW );
  KbPerPoint  = SegPerPoint div SegPerKb;
  MaxHelpItem = 9;
  Help1       : array[1..MaxHelpItem] of string[7] =
                ( 'free'    ,
                  'config'  ,
                  'ms-dos?' ,
                  'COMMAND' ,
                  'command' ,
                  'unident' ,
                  'unknown' ,
                  'secret'  ,
                  ''''      );
  Help2       : array[1..MaxHelpItem] of string[21] =
                ( 'DOS free blocks'      ,
                  'DOS system drivers'   ,
                  'maybe, DOS blocks'    ,
                  'primarly COMMAND.COM' ,
                  'secondary COMMAND.COM',
                  'information released' ,
                  'information destroyed',
                  'information not found',
                  'DOS 4.XX process info');

type
  _MemoryChar = array[1..65534] of char;
  _VectorAddr = record
                  _Ofs: word;
                  _Seg: word
                end;
  _MemCtrl    = record
                  _Header   : char;
                  _OwnerPSP : word;
                  _Size     : word;
                  _Unknown  : array[1..3] of byte;
                  _ProcessID: array[1..8] of char;
                end;
  Segment     = word;
  NameStr     = string[12];
  ComLineStr  = string[80];
  MemBlockPtr = ^MemBlock;
  MemBlock    = record
                  BeginSeg      : Segment;
                  Size          : word;
                  NextBlockPtr  : MemBlockPtr
                end;
  HookIntrPtr = ^HookIntr;
  HookIntr    = record
                  No            : byte;
                  NextIntrPtr   : HookIntrPtr;
                end;
  MemProgPtr  = ^MemProg;
  MemProg     = record
                  Owner         : Segment;
                  Name          : NameStr;
                  ComLine       : ComLineStr;
                  FirstBlockPtr : MemBlockPtr;
                  FirstIntrPtr  : HookIntrPtr;
                  NextProgPtr   : MemProgPtr
                end;
var
  FirstProgPtr : MemProgPtr;
  MainWin      : WindowPtr;
  DOSMajorVer  : byte;
  PickAtrs     : PickColorArray;
  NormAtr,
  HiAtr,
  MenuAtr,
  MarkAtr      : byte;

function __Ptr2LSup(ThisPtr : pointer) : longint;
  var
    NormPtr : pointer;
  begin {__Ptr2LSup}
    NormPtr    := Normalized(ThisPtr);
    __Ptr2LSup := (longint(_VectorAddr(NormPtr)._Seg) shl 4) + longint(_VectorAddr(NormPtr)._Ofs)
  end;	{__Ptr2LSup}

  {$I AlterMem.IMP}
  {$I  CtrlMem.IMP}
  {$I FirstMem.IMP}
  {$I  FreeMem.IMP}
  {$I  HookMem.IMP}

  function TotalMem: word;
  var
    Reg : registers;
  begin {TotalMem}
    with Reg do
      begin
	Intr($12,Reg);
	TotalMem := AX;
      end
  end;	{TotalMem}

  procedure Abort;
  begin
    repeat until EraseTopWindow = Nil;
    WriteLn ( 'No enought memory !' );
    SwapVectors;
    Halt;
  end;

  procedure CheckNilPtr ( CheckingPtr : pointer );
  begin
    if  CheckingPtr = Nil  then  Abort
  end;

  procedure FreeThisProgram;   {-- Освободить память этой программы }
  var
    MemPtr    : pointer;
    NextPtr   : pointer;
    Dummy     : word;
    ErrorCode : word;
    MCB       : _MemCtrl;
    ThisBlocks: array[1..10] of pointer;
    BlockNo   : byte;
  label
    ExitOnError;
  begin
    BlockNo:= 0;
    MemPtr := __FirstMem;
    while  MemPtr <> Nil  do
      begin
        NextPtr:= __CtrlMem( MemPtr, MCB );
        if MCB._OwnerPSP = PrefixSeg then
          begin
            Inc ( BlockNo );
            ThisBlocks[BlockNo]:= MemPtr;
            __FreeMem ( MemPtr, ErrorCode );
            if ErrorCode <> 0 then goto ExitOnError;
          end;
          MemPtr:= NextPtr
      end;
    while  BlockNo > 0  do      {-- удалить фрагментированность }
      begin
        __AlterMem ( $FFFF, ThisBlocks[BlockNo], Dummy, ErrorCode );
        if  ErrorCode = 7  then  goto ExitOnError;
        Dec( BlockNo )
      end;
    Exit;
  ExitOnError:
    WriteLn ('DOS Memory Control Block destroyed !');
    Halt
  end;

  procedure CreateMemList;

  function  GetProgPtr ( Own : Segment ) : MemProgPtr;
    var
      ProgPtr  : MemProgPtr;
    begin
      if FirstProgPtr = Nil then             {-- init memory program list }
        begin
          New ( FirstProgPtr );
          CheckNilPtr ( FirstProgPtr );
          with FirstProgPtr^ do
            begin
              Owner         := Own;
              Name          := EmptyName;
              ComLine       := EmptyPath;
              FirstBlockPtr := Nil;
              FirstIntrPtr  := Nil;
              NextProgPtr   := Nil
            end
        end;
                                             {-- find owner's program in list }
      ProgPtr:= FirstProgPtr;
      while ( ProgPtr^.NextProgPtr <> Nil ) and ( ProgPtr^.Owner <> Own ) do
        ProgPtr:=  ProgPtr^.NextProgPtr;

      if ProgPtr^.Owner = Own then           {-- owner found }
        GetProgPtr:= ProgPtr
      else                                   {-- owner not found }
        begin
          New ( ProgPtr^.NextProgPtr );
          CheckNilPtr ( ProgPtr^.NextProgPtr );
          with ProgPtr^.NextProgPtr^ do      {-- init new item in program list }
            begin
              Owner        := Own;
              Name         := EmptyName;
              ComLine      := EmptyPath;
              FirstBlockPtr:= Nil;
              FirstIntrPtr := Nil;
              NextProgPtr  := Nil
            end;
          GetProgPtr:= ProgPtr^.NextProgPtr
        end;

    end { GetProgPtr };


  procedure AddBlockPtr ( ProgPtr : MemProgPtr; BlockSeg, BlockSize : word );
    var
      BlockPtr      : MemBlockPtr;
      IntrPtr       : HookIntrPtr;
      TempIntrPtr   : HookIntrPtr;
      BlockIntrPtr  : HookIntrPtr;
      IntrNo        : integer;
      IntrFound     : boolean;
    begin
      if ProgPtr^.FirstBlockPtr = Nil then {-- first memory block for owner }
        begin
          New ( ProgPtr^.FirstBlockPtr );
          CheckNilPtr ( ProgPtr^.FirstBlockPtr );
          ProgPtr^.FirstBlockPtr^.NextBlockPtr:= Nil;
          BlockPtr:= ProgPtr^.FirstBlockPtr
        end
      else                                 {-- find last memory block for owner }
        begin
          BlockPtr:= ProgPtr^.FirstBlockPtr;
          while BlockPtr^.NextBlockPtr <> Nil do
            BlockPtr:= BlockPtr^.NextBlockPtr;
          New ( BlockPtr^.NextBlockPtr );
          CheckNilPtr ( BlockPtr^.NextBlockPtr );
          BlockPtr^.NextBlockPtr^.NextBlockPtr:= Nil;
          BlockPtr:= BlockPtr^.NextBlockPtr
        end;

      BlockPtr^.BeginSeg:= BlockSeg;
      BlockPtr^.Size    := BlockSize;

      BlockIntrPtr:= Nil;
      IntrFound   := False;
      IntrNo      := 0;
      repeat
        __HookMem ( BlockSeg, IntrNo );
        if IntrNo >= 0  then
          if not IntrFound then
            begin
              New(IntrPtr);
              CheckNilPtr ( IntrPtr );
              BlockIntrPtr:= IntrPtr;
              with IntrPtr^ do
                begin
                  NextIntrPtr:= Nil;
                  No         := byte(IntrNo)
                end;
              IntrFound:= True;
              Inc ( IntrNo )
            end
          else
            begin
              New ( TempIntrPtr );
              CheckNilPtr ( TempIntrPtr );
              IntrPtr^.NextIntrPtr := TempIntrPtr;
              IntrPtr:= TempIntrPtr;
              with IntrPtr^ do
                begin
                  NextIntrPtr:= Nil;
                  No         := byte(IntrNo)
                end;
              Inc ( IntrNo )
            end
      until ( IntrNo < 0 ) or ( IntrNo > 255 );

      if IntrFound then
        if ProgPtr^.FirstIntrPtr = Nil then  {-- first hooked intr for program }
          ProgPtr^.FirstIntrPtr:= BlockIntrPtr
        else                                 {-- link block intrs list to program list }
          begin
            IntrPtr:=  ProgPtr^.FirstIntrPtr;{-- find last intr in program list }
            while IntrPtr^.NextIntrPtr <> Nil do IntrPtr:= IntrPtr^.NextIntrPtr;
            IntrPtr^.NextIntrPtr:= BlockIntrPtr
          end;

    end; { AddBlockPtr }

  procedure ProcessID ( ProgPtr : MemProgPtr; ProgSeg : Segment );
  var
    EnvSeg  : word;
    EnvPtr  : ^_MemoryChar;
    EnvSize : word;
    I,J     : integer;
    Found   : boolean;
    TempStr : string;
    ComPath,
    ComName,
    ComEnd  : string;
    CLPtr   : ^string;
  label
    ExitProcess;

  begin
    ComPath:= '';
    ComName:= '';
    ComEnd := '';

    if  MemW[ProgSeg - 1:1] <> ProgSeg  then   {-- Это не процесс ! }
      with ProgPtr^ do
        begin
          case  Owner  of
            0 : Name:= 'free';
            8 : Name:= 'config';
          else
            if  Name = EmptyName  then  Name:= 'ms-dos?'
          end;
          ComLine:= 'none';
          Exit
        end;

    CLPtr:= Ptr(ProgSeg, $80);               {-- Поиск строки параметров }
    if (CLPtr^[0] < #$80) and (CLPtr^[Succ(Ord(CLPtr^[0]))] = #$0D) then
      ComEnd:= CLPtr^
    else
      ComEnd:= ', rest destroyed';

    EnvSeg := MemW[ProgSeg:$2C];

    if  EnvSeg > ProgSeg  then              {-- Первая копия (the shell) COMMAND.COM }
       begin
         ComName:= 'COMMAND';
	 goto ExitProcess
       end;

    if EnvSeg = 0  then                     {-- Вторичная копия  COMMAND.COM }
       begin
         ComName:= 'command';
	 goto ExitProcess
       end;

    if (MemW[EnvSeg - 1:1] <> ProgSeg) then {-- Environment потеряно }
       begin
         ComName:= 'unident';
	 goto ExitProcess
       end;

    EnvSize := 16 * MemW[EnvSeg - 1:3];
    I	    := 0;

    EnvPtr  := Ptr(EnvSeg,0);
    repeat			            {-- Поиск конца таблицы environment }
      Inc(I);
      if (I > EnvSize) then
	 begin
	   ComName := 'unknown';
	   goto ExitProcess
	 end;
    until ((EnvPtr^[I] = #0) and (EnvPtr^[I+1] = #0));

    I := I + 4;

    J := 0;
    repeat
      Inc(J);
      TempStr[J] := UpCase(EnvPtr^[I]);
      Inc(I)
    until  EnvPtr^[I] = #0;
    TempStr[0] := Chr(J);

    Found := FALSE;                          {-- поиск первой '\' или ':' }
    I	  := J;
    while  not Found  and  (I >= 1)  do
      if  (TempStr[I] = '\') or (TempStr[I] = ':')  then
	 Found := TRUE
      else
	 Dec(I);

    if  Found  then
      begin
	if TempStr[I] = '\' then
	  ComPath:= Copy(TempStr,1,I)
	else
	  ComPath:= Copy(TempStr,1,I) + '\';
	ComName:= Copy(TempStr,I + 1,255)
      end
    else
      if TempStr <> '' then
        ComName:= TempStr
      else
        ComName:= 'secret';

  ExitProcess:
    ProgPtr^.ComLine:= Copy(ComPath + ComName + ComEnd, 1, 80);
    if DOSMajorVer > 3 then with ProgPtr^ do
      begin
        I:= 8;
        Name:= '';
        while  ( Chr( Mem[ProgSeg-1:I] ) >= #$20 ) and ( I <= 15 )  do
          begin
            Name:= Name + Chr( Mem[ProgSeg-1:I] );
            Inc(I)
          end;
        Name:= Name + LeftPad( '''', 9 - Ord(Name[0]) );
      end
    else
      ProgPtr^.Name   := ComName;
  end;  { ProcessID }

  var
    MemPtr    : pointer;
    NextPtr   : pointer;
    MPPtr,
    PLastPtr,
    P0Ptr     : MemProgPtr;
    MCB       : _MemCtrl;
    CLPtr     : ^string;

  begin { CreateMemList }
    MemPtr       := __FirstMem;
    FirstProgPtr := Nil;

    while MemPtr <> Nil do      {-- сформировать список программ }
      begin
        NextPtr := __CtrlMem( MemPtr, MCB );
        MPPtr   := GetProgPtr ( MCB._OwnerPSP );
        AddBlockPtr( MPPtr, Seg( MemPtr^ ), MCB._Size );
        ProcessID ( MPPtr, Seg( MemPtr^ ) );
        MemPtr := NextPtr
      end { while not last block };

    PLastPtr:= FirstProgPtr;    {-- поиск последней программы }
    while PLastPtr^.NextProgPtr <> Nil do PLastPtr:= PLastPtr^.NextProgPtr;
    MPPtr:= FirstProgPtr;
    while ( MPPtr^.NextProgPtr <> Nil ) and ( MPPtr^.NextProgPtr^.Owner <> 0 ) do
      MPPtr:= MPPtr^.NextProgPtr;
    if (MPPtr <> Nil) and (MPPtr^.NextProgPtr^.NextProgPtr <> Nil) then
      begin                     {-- перенос свободного блока в конец списка }
        P0Ptr                := MPPtr^.NextProgPtr;
        MPPtr^.NextProgPtr   := MPPtr^.NextProgPtr^.NextProgPtr;
        PLastPtr^.NextProgPtr:= P0Ptr;
        P0Ptr^.NextProgPtr   := Nil
      end;

  end;  { CreateMemList }


  function  PosX ( PosInMap: word ): byte;  begin  PosX:= PosInMap div MapH + MapX + 1 end;
  function  PosY ( PosInMap: word ): byte;  begin  PosY:= PosInMap mod MapH + MapY + 1 end;


  procedure DrawTotal;
  const
    EndPoint = Pred ( Seg640 div SegPerPoint );
  var
    LastPoint : word;
    Pos       : word;
  begin
    LastPoint:= Pred( TotalMem div KbPerPoint );
    for  Pos:= 0  to  LastPoint  do
      FastWrite ( FreeCh, PosY(Pos), PosX(Pos), MarkAtr );
    for  Pos:= Succ(LastPoint)  to  EndPoint  do
      FastWrite ( FreeCh,  PosY(Pos),  PosX(Pos), NormAtr );
    FastWrite ( ' ', Succ(MapY),  MapW + Succ(MapX), NormAtr );
  end;


  procedure InitScreen;
  var
    X, Y    : byte;
  begin
    HiddenCursor;
    FastWrite (' Memory Map ', 1, 35, NormAtr );
    FastWrite ('   PSP  Bytes Blks  Name       ', PickY-1, PickX, NormAtr );
    for  X:= 1 to  MapW  do  if  Pred(X) mod 8 = 0 then
      FastWrite ( '┌'+ Long2Str(Pred(X) * MapH * KbPerPoint) + 'K', MapY, X + MapX, NormAtr );
    FastWrite ('by Oleg', 25, 74, NormAtr );
    FastWrite ( 'Command line      > ', InfoY  , InfoX, NormAtr );
    FastWrite ( 'Hooked interrupts : ', InfoY+1, InfoX, NormAtr );
    DrawTotal;
  end;

  procedure DrawBlock ( BegSeg, EndSeg : Segment );
  var
    BegPos, EndPos, Pos: integer;
  begin
    BegPos:=      BegSeg  * longint(2) div SegPerPoint;
    EndPos:= Pred(EndSeg) * longint(2) div SegPerPoint;
    if BegSeg = Seg640 then
      begin
        FastWrite ( FullCh, PosY(BegPos div 2), PosX(BegPos div 2), MarkAtr );
        Exit
      end;
    if  Odd(BegPos)  then
      FastWrite ( OddCh,  PosY(BegPos div 2), PosX(BegPos div 2), MarkAtr )
    else
      FastWrite ( EvenCh, PosY(BegPos div 2), PosX(BegPos div 2), MarkAtr );
    for  Pos:= Succ(BegPos) div 2  to  EndPos div 2 do
      FastWrite ( FullCh, Pos mod MapH + Succ(MapY), Pos div MapH + Succ(MapX), MarkAtr );
    if  not Odd(EndPos)  then
      FastWrite ( EvenCh, PosY(EndPos div 2), PosX(EndPos div 2), MarkAtr );
  end; { DrawBlock }


  {$F+}
  procedure Help;
    var
      HelpWin : WindowPtr;
      I       : byte;
    begin
      if not MakeWindow ( HelpWin, 22,7, 58, Succ(MaxHelpItem) + 7, True, True, False, HiAtr, HiAtr, HiAtr, '' ) then
         Abort;
      if not DisplayWindow ( HelpWin ) then  Abort;
      for I:= 1 to MaxHelpItem do
        begin
          FastWriteClip (       Help1[I],  I, 3, HiAtr );
          FastWriteClip ('- ' + Help2[I],  I,11, NormAtr );
        end;
      repeat until KeyPressed;
      if ReadKeyWord = 0 then {-- wait for key pressed };
      KillWindow ( HelpWin )
    end;


  procedure RedrawBlocks( Item : word );
  var
    ProgPtr   : MemProgPtr;
    BlockPtr  : MemBlockPtr;
    IntrPtr   : HookIntrPtr;
    ProgNum   : byte;
    IntrX,
    IntrY     : byte;
    ComLine   : string;

  begin
    DrawTotal;
    ProgPtr := FirstProgPtr;
    for ProgNum:= 2 to Item do ProgPtr:= ProgPtr^.NextProgPtr;
    BlockPtr:= ProgPtr^.FirstBlockPtr;

    FastWrite ( LeftPad ( '', 80-FirstInfoX ) , InfoY  , FirstInfoX, NormAtr );
    FastWrite ( LeftPad ( '', 80-FirstInfoX ) , InfoY+1, FirstInfoX, NormAtr );
    FastWrite ( LeftPad ( '', 80-FirstInfoX ) , InfoY+2, FirstInfoX, NormAtr );
    if ProgPtr^.ComLine[0] > Chr(InfoW) then
      ComLine:= Copy ( ProgPtr^.ComLine, 1, InfoW-2 ) + '..'
    else
      ComLine:= ProgPtr^.ComLine;
    FastWrite ( ComLine, InfoY, FirstInfoX, HiAtr );
    IntrY:= Succ(InfoY);
    IntrPtr:= ProgPtr^.FirstIntrPtr;
    if  IntrPtr <> Nil then
      begin
        IntrX:= FirstInfoX;
        while  ( IntrPtr <> Nil ) and ( IntrY < 25 )  do
          begin
            FastWrite ( HexB(IntrPtr^.No) + ' ', IntrY, IntrX, HiAtr );
            IntrPtr:= IntrPtr^.NextIntrPtr;
            Inc ( IntrX, 3 );
            if  IntrX >= (FirstInfoX + InfoW - 3)  then
              begin
                Inc(IntrY);
                if  IntrY = 25 then
                  FastWrite ( '..', Pred(IntrY), FirstInfoX + InfoW - 2 , HiAtr );
                IntrX:= FirstInfoX;
              end
          end
      end
    else
      FastWrite ( 'none', IntrY, FirstInfoX, HiAtr );

    while BlockPtr <> Nil do
      begin
        DrawBlock ( BlockPtr^.BeginSeg, BlockPtr^.BeginSeg + BlockPtr^.Size);
        BlockPtr:= BlockPtr^.NextBlockPtr
      end

  end; { RedrawBlocks }


  function ProgFromList ( Item : word ) : string;
  var
    ProgPtr   : MemProgPtr;
    BlockPtr  : MemBlockPtr;
    ProgNum   : byte;
    ProgSize  : word;
    ProgBlocks: byte;
    ProgOwner : Segment;
    ProgName  : string[12];
  begin
    ProgPtr:= FirstProgPtr;
    ProgNum:= 1;
    while  ProgNum <> Item  do  {-- Вычислить TSR по номеру в списке }
      begin
        ProgPtr:= ProgPtr^.NextProgPtr;
        Inc ( ProgNum )
      end;
    ProgOwner := ProgPtr^.Owner; {-- Определить ее характеристики }
    ProgName  := ProgPtr^.Name;
    ProgSize  := 0;
    ProgBlocks:= 0;
    BlockPtr  := ProgPtr^.FirstBlockPtr;
    while BlockPtr <> Nil do
      begin
        Inc ( ProgSize, BlockPtr^.Size );
        Inc ( ProgBlocks );
        BlockPtr:= BlockPtr^.NextBlockPtr
      end;
    ProgFromList:= LeftPad( HexW    (ProgOwner),               5 ) + ' ' +
                   LeftPad( Long2Str(ProgSize * longint(16) ), 6 ) + ' ' +
                   Center ( Long2Str(ProgBlocks),              3 ) + ' ' +
                   ProgName
  end;
  {$F+}

  procedure LookProg;
  var
    Item, Row   : word;
    PickWin     : WindowPtr;
    PickListMax : word;
    ProgPtr     : MemProgPtr;
  begin
    if not MakeWindow( PickWin, PickX, PickY, PickX+PickW, PickY+PickH, True, True, False, MenuAtr, MenuAtr, MenuAtr, '') then
      Abort;
    if not DisplayWindow ( PickWin )  then  Abort;

    PickListMax:= 0;
    ProgPtr    := FirstProgPtr;
    while ProgPtr <> Nil do
      begin
        ProgPtr:= ProgPtr^.NextProgPtr;
        Inc ( PickListMax )
      end;
    Item:= 1; Row:= 1;
    PickUserPtr:= @RedrawBlocks;
    PickHelpPtr:= @Help;
    FillPickWindow ( PickWin, @ProgFromList, PickListMax, PickAtrs, Item, Row );
    repeat
       PickBar ( PickWin, @ProgFromList, PickListMax, PickAtrs, False, Item, Row );
    until  PickCmdNum = PKSExit;
    KillWindow ( PickWin );
  end; { LookProg }


begin { Main }
  DOSMajorVer:= Hi(DosVersion);
  if  DOSMajorVer < 3  then
    begin
      WriteLn ( ' DOS 3.00 or later required. ' );
      Halt;
    end;
  if  CurrentDisplay = MonoHerc  then
    if CurrentMode <> BW80  then  TextMode(BW80) else {}
  else
    if CurrentMode <> CO80  then  TextMode(CO80);
  if  CurrentMode = BW80  then
    begin
      NormAtr:= LightGray + Black shl 4;
      HiAtr  := White     + Black shl 4;
      MenuAtr:= Black     + LightGray shl 4;
      MarkAtr:= Black     + LightGray shl 4  +  Blink;
    end
  else
    begin
      NormAtr:= LightGray + Blue      shl 4;
      HiAtr  := Yellow    + Blue      shl 4;
      MenuAtr:= Black     + Cyan      shl 4;
      MarkAtr:= Red       + LightGray shl 4;
    end;
  PickAtrs[WindowAttr]:= MenuAtr;
  PickAtrs[FrameAttr] := MenuAtr;
  PickAtrs[HeaderAttr]:= MenuAtr;
  PickAtrs[SelectAttr]:= HiAtr;
  PickAtrs[AltNormal] := MenuAtr;
  PickAtrs[AltHigh]   := HiAtr;
  BIOSScroll:= False;
  {
  Shadow := True;
  Explode:= True;
  }
  FreeThisProgram;
  SwapVectors;
  if not MakeWindow ( MainWin, 1,1, 80,25, False, True, False, NormAtr, NormAtr, NormAtr, '' ) then  Abort;
  if not DisplayWindow ( MainWin ) then  Abort;
  CreateMemList;
  InitScreen;
  LookProg;
  KillWindow ( MainWin );
  WriteLn ( 'Memory Map. Written by Oleg Oleynick, Dniepropetrovsk, 45-85-55.' );
  SwapVectors;
end.
