{NewMem.pas  A memory management unit for Turbo Pascal

 Copyright 1994 Anthony Brummett

 Released as "freeware"  See the file readme.doc for more information
}

unit newmem;

interface

type AllocationType=(FirstFit, BestFit, LastFit);{First-fit is the only one
                                                  working now}

     BitmapTypePtr=^BitmapType;
     BitmapType=array[1..65535] of byte;

     MemTypePtr=^MemType;
     MemType=record
       size:word;                      {How many bytes this block has}
       block:pointer;                  {Pointer to the allocated block}
       granularity:word;               {Granularity for allocating}
       Allocation:AllocationType;      {Allocation strategy}
       next:MemTypePtr;                {Pointer to next header}
       BitmapSize:word;                {Size of the allocation bitmap}
       bitmap:BitmapTypePtr;           {Pointer to the bitmap}
       NumBlocks,                      {Number of allocation "quanta"}
       LastByte:word;                  {Next block to be allocated for}
       LastBit:shortInt;               {  last-fit allocation}
     end;{MemHeaderType}

var MemDebug:boolean;

function AllocateBuffer(size:word; gran:word):MemTypePtr;
  {Sets the size of a memory allocation block}

{Only First-fit is supported in this version. A block is automaticly set to
 use first-fit by the AllocateBuffer function}
{procedure SetAllocationStrategy(ptr:MemTypePtr; alloc:AllocationType);}
  {Sets the allocation strategy for a memory block}

function MemGet(ptr:MemTypePtr; ReqSize:word):pointer;
  {Allocates some memory from a block}

procedure MemFree(ptr:MemTypePtr; p:pointer; size:word);
  {Frees some memory back to a block}

procedure ReleaseBuffer(ptr:MemTypePtr);
  {Releases a block back to the heap}

procedure ReleaseAllBuffers;
  {Releases all buffers back to the heap}

function MemLeft(ptr:MemTypePtr):word;
  {Returns the number of bytes free in a block}

function MaxLeft(ptr:MemTypePtr):word;
  {Returns the largest amount of contiguous memory in a block}

procedure FreeAll(ptr:MemTypePtr);
  {Frees all memory in a block}

function HexStr(q:word):string;
  {Converts q to a hexadecimal string}




implementation

var RootMem:MemTypePtr;

function hexstr(q:word):string;
  const HexChars:array[0..15] of char=('0','1','2','3','4','5','6','7',
                                       '8','9','A','B','C','D','E','F');
  var s:string[4];
      w:byte;
      e,r:word;
  begin
    s[0]:=#4;
    for w:=0 to 3 do begin
      e:=15 SHL (w*4);
      r:=(q AND e) SHR (w*4);
      s[4-w]:=HexChars[r];
    end;{for}

    HexStr:=s;
  end;{HexStr}



function ceil(r:real):integer;
  begin
    if frac(r)=0 then
      ceil:=trunc(r)
    else
      ceil:=trunc(r)+1;
  end;{ceil}

function PtrAdd(p:pointer; a:word):pointer;
  var s,o:word;
  begin
    s:=seg(p^);
    o:=ofs(p^);
    s:=s+(o div 16);
    o:=(o mod 16)+a;
    ptradd:=ptr(s,o);
  end;{ptradd}

function Bit(q,w:byte):byte;
  begin
    bit:=((q SHR w) AND 1);
  end;{bit}


function AllocateBuffer(size:word; gran:word):MemTypePtr;
  var p:MemTypePtr;
      q:word;
  begin
    if MemDebug then
      writeln(output,'Allocating buffer size ',size,' granularity ',gran);

    GetMem(p, SizeOf(MemType));
    if p<>NIL then begin

      if MemDebug then
        writeln(output,'Buffer block located at ',
          HexStr(seg(p^)),':',HexStr(ofs(p^)));

      p^.size:=size;
      p^.NumBlocks:=ceil(size/gran);
      p^.BitmapSize:=ceil(p^.NumBlocks/8);
      GetMem(p^.block, size);
      GetMem(p^.bitmap, p^.BitmapSize);

      if (p^.block=NIL) then begin
        p:=NIL;
        if memDebug then
          writeln(output,'Not enough heap memory for memory block');
      end {if p^.block=NIL}

      else if (p^.Bitmap=NIL) then begin
        p:=NIL;
        if memdebug then
          writeln(output,'Not enough heap memory for allocation bitmap');
      end {if p^.bitmap=NIL}

      else begin

        {Clear allocation bitmap}
        for q:=1 to (p^.BitmapSize) do
          p^.bitmap^[q]:=0;

        {Mark leftover blocks as "allocated"}
        if (p^.numBlocks mod 8)<>0 then
          p^.Bitmap^[p^.BitmapSize]:=(1 SHL (8-(p^.NumBlocks mod 8)))-1;

        p^.granularity:=gran;
        p^.allocation:=FirstFit;
        p^.next:=RootMem;
        RootMem:=p;

        if MemDebug then begin
          writeln(output,'Memory block located at ',
            HexStr(seg(p^.block^)),':',HexStr(ofs(p^)));
          writeln(output,'Allocation bitmap located at ',
            HexStr(seg(p^.Bitmap^)),':',HexStr(ofs(p^.Bitmap^)));

          writeln(memavail,' bytes free on heap now');
          writeln(maxavail,' bytes in largest hunk');
        end;{if debug}
      end;{else}
    end;{if}

    AllocateBuffer:=p;
  end;{AllocateBuffer}

procedure SetAllocationStrategy(ptr:MemTypePtr; alloc:AllocationType);
  begin
    ptr^.Allocation:=alloc;
  end;{SetAlloc}

procedure FirstAllocate(ptr:MemTypePtr; ReqSize:word; var AllocBlock:pointer);
  var MaxBlocks,PlaceByte,MarkByte,ReqBlocks:word;
      PlaceBit, MarkBit:shortint;
      p:pointer;
  label GetOut;  {Ack! a goto. So sue me...}
  begin
    with ptr^ do begin
        MaxBlocks:=0;
        PlaceByte:=1;
        PlaceBit:=7;
        ReqBlocks:=ceil(ReqSize/Granularity);
        MarkByte:=1;
        MarkBit:=7;
        while (PlaceByte<=BitmapSize) and (MaxBlocks<ReqBlocks) do begin
          while (PlaceBit>=0) and (MaxBlocks<ReqBlocks) do begin

            if bit(Bitmap^[PlaceByte],PlaceBit)=1 then begin {If block in use}
              MaxBlocks:=0;  {Start over}
              if PlaceBit=0 then begin
                MarkBit:=7;
                MarkByte:=PlaceByte+1;
              end {if PlaceBit} else
                MarkBit:=PlaceBit-1;
            end {if} else
              inc(MaxBlocks);

            dec(PlaceBit);
          end;{while}

          if MaxBlocks<ReqBlocks then begin
            inc(PlaceByte);
            PlaceBit:=7;
          end;{if}

        end; {while}

        if MaxBlocks=ReqBlocks then begin  {Mark new mem as allocated}
          PlaceBit:=MarkBit;
          for PlaceByte:=MarkByte to 65535 do begin
            while PlaceBit>=0 do begin
              if MaxBlocks=0 then goto GetOut;

              {Set the bit}
              Bitmap^[PlaceByte]:=Bitmap^[PlaceByte] OR (1 SHL PlaceBit);
              dec(PlaceBit);
              dec(MaxBlocks);
            end;{while PlaceBit}
            PlaceBit:=7;
          end;{for PlaceByte}

GetOut:

          p:=PtrAdd(block, (((MarkByte-1)*8)+(7-MarkBit))*Granularity);
        end {if maxblocks} else
          p:=NIL;  {Not enought memory}
    end;{with}

    AllocBlock:=p;
  end;{MemGet}


procedure BestAllocate(ptr:MemTypePtr; ReqSize:word; var AllocBlock:pointer);
  var p:pointer;
      PlaceByte, MarkByte, ReqBlocks, BestBlocks, ThisBlocks:word;
      PlaceBit, MarkBit:shortint;
  label GetOut, FoundMem;
  begin
    with ptr^ do begin

    end;{with}
  end;{BestAllocate}

procedure LastAllocate(ptr:MemTypePtr; ReqSize:word; var AllocBlock:pointer);
  var p:pointer;
      PlaceByte, ReqBlocks:word;
      PlaceBit:shortint;
  begin
    if MaxLeft(ptr)<ReqSize then
      p:=NIL
    else begin


    end;{else MaxLeft}
    AllocBlock:=p;
  end;{LastAllocate}

function MemGet(ptr:MemTypePtr; ReqSize:word):pointer;
  var AllocBlock:pointer;

  begin
    if MemDebug then
      writeln(output,'Allocating ',reqsize,' bytes from buffer at ',
               hexstr(seg(ptr^)),':',hexstr(ofs(ptr^)));

    case ptr^.allocation of
      FirstFit : FirstAllocate(ptr, ReqSize, AllocBlock);
      BestFit : BestAllocate(ptr, ReqSize, AllocBlock);
      LastFit : LastAllocate(ptr, ReqSize, AllocBlock);
    end;{case}

    if MemDebug then
      if AllocBlock=NIL then
        writeln(output,'Not enough memory')
      else begin
        writeln(output,'Returning pointer ',
                HexStr(seg(AllocBlock^)),':',HexStr(ofs(AllocBlock^)));
        writeln(   (seg(AllocBlock^) SHL 4)+(ofs(AllocBlock^)) -
                   (seg(ptr^.block^) SHL 4)+(ofs(ptr^.block^)),
                   ' bytes past start of memory block');
      end;{else}

    MemGet:=AllocBlock;
  end;{MemGet}

procedure MemFree(ptr:MemTypePtr; p:pointer; size:word);
  var BlockNum, NumBlocks:word;
      PlaceByte:word;
      PlaceBit:ShortInt;
      p1,p2:longint;
  begin

    p1:=(seg(ptr^.block^) SHL 4) + ofs(ptr^.block^);
    p2:=(seg(p^) SHL 4) + ofs(p^);
    BlockNum:=(p2-p1) div ptr^.Granularity;
    PlaceByte:=(BlockNum div 8)+1;
    PlaceBit:=7-(BlockNum mod 8);
    NumBlocks:=ceil(size/ptr^.granularity);

    if NumBlocks>0 then begin

      if MemDebug then
        writeln(output,'Freeing ',NumBlocks*ptr^.Granularity, ' bytes at ',
                HexStr(seg(p^)),':',HexStr(ofs(p^)),' from buffer at ',
                HexStr(seg(ptr^)),':',HexStr(ofs(ptr^)));

      while NumBlocks>0 do begin
        while (NumBlocks>0) and (PlaceBit>=0) do begin
          ptr^.Bitmap^[PlaceByte]:=ptr^.Bitmap^[PlaceByte] AND
                                   (NOT (1 SHL PlaceBit));
          dec(PlaceBit);
          dec(NumBlocks);
        end;{while}
        PlaceBit:=7;
        inc(PlaceByte);
      end;{while}
    end {if} else
      if MemDebug then
        writeln(output,'Tried to free ',HexStr(seg(p^)),':',HexStr(ofs(p^)),
        ' from buffer at ',HexStr(seg(ptr^)),':',HexStr(ofs(ptr^)),
        ' which was not allocated');
  end;{MemFree}

procedure ReleaseBuffer(ptr:MemTypePtr);
  var p1,p2:MemTypePtr;
  begin
    if ptr=RootMem then  {Fixup linked list}
      RootMem:=ptr^.next
    else begin
      p1:=RootMem;
      while p1<>ptr do begin
        p2:=p1;
        p1:=p1^.next;
      end;{while}
      p2^.next:=p1^.next;
    end;{else}

    FreeMem(ptr^.Bitmap, ptr^.BitmapSize);
    FreeMem(ptr^.Block, ptr^.size);
    FreeMem(ptr, sizeof(MemType));

    if MemDebug then begin
      writeln(output,'Freeing buffer at ',seg(ptr^),':',ofs(ptr^));
      writeln(memavail,' bytes free on heap now');
      writeln(maxavail,' bytes in largest hunk');
    end;{if}
  end;{ReleaseBuffer}

procedure ReleaseAllBuffers;
  var p,q:MemTypePtr;
  begin
    p:=RootMem;

    while p<>NIL do begin
      q:=p^.next;
      ReleaseBuffer(p);
      p:=q;
    end;{while}
  end;{ReleaseAllBuffers}

function MemLeft(ptr:MemTypePtr):word;
  var PlaceByte:word;
      PlaceBit:shortint;
      FreeBlocks:word;
  begin
    FreeBlocks:=0;
    with ptr^ do
      for PlaceByte:=1 to BitmapSize do
        for PlaceBit:=7 downto 0 do
          if bit(Bitmap^[PlaceByte], PlaceBit)=0 then
            inc(FreeBlocks);
    MemLeft:=FreeBlocks * ptr^.Granularity;
  end;{MemLeft}


function MaxLeft(ptr:MemTypePtr):word;
  var PlaceByte:word;
      Max, MaxMax:word;
      PlaceBit:ShortInt;
  begin
    max:=0;
    MaxMax:=0;
    with ptr^ do begin
      for PlaceByte:=1 to BitmapSize do
        for PlaceBit:=7 downto 0 do

          if bit(Bitmap^[PlaceByte], PlaceBit)=1 then begin
            if max > MaxMax then   {if local max is greater than found so far}
              MaxMax:=max;  {This is the real max so far}
            max:=0;
          end {if} else
            inc(max);
      if max>MaxMax then
        Max:=max*granularity
      else
        Max:=MaxMax*granularity;
    end;{with}

    MaxLeft:=Max;
  end;{MaxLeft}

procedure FreeAll(ptr:memTypePtr);
  var MarkByte:word;
  begin
    with ptr^ do begin
      for MarkByte:=1 to BitmapSize-1 do
        Bitmap^[MarkByte]:=0;

      Bitmap^[BitmapSize]:=(1 SHL (8-(NumBlocks mod 8)))-1;

      LastByte:=1;
      LastBit:=7;

    end;{with}
  end;{freeAll}


begin {main}
  RootMem:=NIL;
  MemDebug:=FALSE;
end.

