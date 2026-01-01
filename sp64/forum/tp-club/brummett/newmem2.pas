{NewMem2.pas  A memory management unit for Turbo Pascal with swapping

 Copyright 1994 Anthony Brummett

 Released as "freeware"  See the file readme.doc for more information
}

unit NewMem2;

interface

type BitmapTypePtr=^BitmapType;
     BitmapType=array[1..65535] of byte;{Bitmap of free/used space}

     HeaderTypePtr=^HeaderType;
     HeaderType=record
       sig:word;              {Signature of a valid header is $F3C1}
       size:word;             {Number of bytes allocated to this block}
       granularity:word;      {Smallest size of allocation}
       next:HeaderTypePtr;    {pointer to next header}
       BitmapSize:word;       {Size of the bitmap array}
       bitmap:BitmapTypePtr;  {pointer to bitmap array}
       NumBlocks:word;        {Number of "quanta" of allocation}
       RefCount:word;         {Number of objects allocated to this block}
       Flags:byte;            {Flags of this block:
                                Bit     Meaning
                              XXXX      Unused
                                   1    Locked in memory
                                    1   Already Malloc-ed
                                     1  Buffer Dirty
                                      1 Swapped In}


       FileOfs:longint;        {Offset in swap file to swap to}
       block:pointer;          {pointer to data block}
     end;{HeaderType}


     Descriptor=object
        header:HeaderTypePtr;  {Header info for this pointer}
        referenced:boolean;    {Has this descriptor been used lately?}
        stuff:word;            {How many blocks past start of memory is this
                                pointer?}

        function Addr:pointer; {Returns a pointer to this memory}
     end;

var MemDebug:boolean;  {Print messages during execution?}

function AllocateBuffer(size:word; gran:word):HeaderTypePtr;
{Sets the size of a memory allocation block}

procedure MemGet(var p:Descriptor; ptr:HeaderTypePtr; ReqSize:word);
{Allocates some memory from a block}

procedure MemFree(ptr:Descriptor; size:word);
{Free some memory back to a block}

procedure FreeAll(ptr:HeaderTypePtr);
{Free all memory of a block}

procedure ReleaseBuffer(ptr:HeaderTypePtr);
{Releases a block back to the heap}

procedure ReleaseAllBuffers;
{Releases all blocks to the heap}

function MemLeft(ptr:HeaderTypePtr):word;
{Returns the number of bytes free in a block}

function MaxLeft(ptr:HeaderTypePtr):word;
{Returns the largest amount of contiguous memory in a block}

procedure MemSwapOn(filename:string; size:longint);
{Turn on swapping}

procedure MemSwapResize(size:longint);
{Change the max amount of memory used at once}

procedure MemSwapOff;
{Turn off swapping}

procedure MemLock(ptr:HeaderTypePtr; l:boolean);
{Lock a block in memory}

procedure MemNotDirty(ptr:HeaderTypePtr);
{Clear the dirty bit of a block}

function HexStr(q:word):string;
{Converts q to a hexadecimal string}

procedure SwapBlock(ptr:HeaderTypePtr);
{Manually swap a block out to disk}

procedure LoadBlock(ptr:HeaderTypePtr);
{Manually swap a block in from disk}


implementation

const SWAPPED_IN=$01;   {For Flags byte}
      DIRTY=$02;
      MALLOCED=$04;
      LOCKED=$80;

      FROM_START=0;     {For move file pointer}
      FROM_CURR=1;
      FROM_END=2;

      HEADER_SIG=$F3C1;

var RootMem:HeaderTypePtr;      {Root ot the header linked list}
    SwapFileName:string;        {Name of the swap file}
    SwapFileHandle:word;        {DOS File handle for the swap file}
    MemSize,                    {Current amount of memory swapped in}
    MaxMemSize:longint;         {Max amount of memory that can be swapped in}
    SwapOn:boolean;             {Is the swapper turned on?}


procedure WriteFile(p:pointer; count:word; code:byte; pos:longint);
{Write a block of data to the swap file}
  var s,o,l,h:word;
  begin
    s:=seg(p^);
    o:=ofs(p^);
    l:=(pos AND $FFFF);
    h:=(pos SHL 16);

    ASM
      push ds

      mov ah,$42   {Move File Handle}
      mov al,code
      mov bx,SwapFileHandle
      mov cx,h
      mov dx,l
      int $21

      mov ah,$40   {Write to file}
      mov bx,SwapFileHandle
      mov cx,count
      mov dx,s
      push dx
      mov dx,o
      pop ds
      int $21

      pop ds
    end;{asm}
  end;{WriteFile}

procedure ReadFile(p:pointer; count:word; code:byte; pos:longint);
{Read a data block from the swap file}
  var s,o,l,h:word;
  begin
    s:=seg(p^);
    o:=ofs(p^);
    l:=(pos AND $FFFF);
    h:=(pos SHL 16);

    ASM
      push ds

      mov ah,$42   {Move file handle}
      mov al,code
      mov bx,SwapFileHandle
      mov cx,h
      mov dx,l
      int $21

      mov ah,$3F   {Read from file}
      mov bx,SwapFileHandle
      mov cx,count
      mov dx,s
      push dx
      mov dx,o
      pop ds
      int $21

      pop ds
    end;{asm}
  end;{ReadFile}


procedure SwapBlock(ptr:HeaderTypePtr);
{Swap the data block controlled by header ptr to disk}
  begin
    if (ptr^.flags AND SWAPPED_IN)=0 then begin
      if MemDebug then
        writeln(output,'Tried to swap out block at ',HexStr(seg(ptr^)),':',
                HexStr(ofs(ptr^)),' which is already swapped');
      exit;
    end {if}

    else if (ptr^.flags AND LOCKED)>0 then begin
      if MemDebug then
        writeln(output,'Tried to swap out block at ',HexStr(seg(ptr^)),':',
                HexStr(ofs(ptr^)),' which is locked');
      exit;
    end {else if}

    else begin
      if MemDebug then
        writeln(output,'Swapping out block at ',HexStr(seg(ptr^)),':',
                HexStr(ofs(ptr^)),' to file offset ',ptr^.FileOfs);

      if (ptr^.RefCount>0) and ((ptr^.flags AND DIRTY)>0) then
        WriteFile(ptr^.block, ptr^.size, FROM_START, ptr^.FileOfs);

      FreeMem(ptr^.block,ptr^.size);
      ptr^.flags:=ptr^.flags AND (NOT SWAPPED_IN);
      MemSize:=MemSize-ptr^.size;
    end;{else}
  end;{SwapBlock}


procedure SwapABlock;
{Swap the "best" data block to disk}
{Look for a segment with RefCount of 0, or the biggest segment}
  var p,best:HeaderTypePtr;
  label GetOut;
  begin
    if RootMem=NIL then begin
      if MemDebug then
        writeln(output,'Called SwapABlock with no blocks allocated!?!');
      exit;
    end;{if}

    best:=RootMem;
    while (best<>NIL) and (((best^.flags AND SWAPPED_IN)=0) or
          ((best^.flags AND LOCKED)>0)) do
      best:=best^.next;

    p:=best^.next;
    while (p<>NIL) do begin
      if ((best^.flags AND LOCKED)=0) and (best^.RefCount=0) and
         ((best^.flags AND SWAPPED_IN)>0) then
        goto GetOut;

      if ((p^.flags AND LOCKED)=0) and (p^.refCount<best^.RefCount) and
         ((p^.flags AND SWAPPED_IN)>0) then
        best:=p;
      p:=p^.next;
    end;{while}

    if best<>RootMem then goto GetOut;

    p:=RootMem^.next;
    while p<>NIL do begin
      if ((p^.flags AND LOCKED)=0) and (p^.size>best^.size) and
         ((p^.flags AND SWAPPED_IN)>0) then
        best:=p;
      p:=p^.next;
    end;{while}

GetOut:
    if best=NIL then begin
      if MemDebug then
        writeln(output,'Cannot swap out any blocks. Probably too many are locked');
      writeln('NewMem2 Memory Fault: No swap space. Exiting...');
      RunError(204);
    end;{if}

    SwapBlock(best);
  end;{SwapABlock}


procedure LoadBlock(ptr:HeaderTypePtr);
{Load a data block controlled by header ptr from disk}
  begin

    if MemDebug then
      writeln(output,'Swapping in block at ',HexStr(seg(ptr^)),':',
              HexStr(ofs(ptr^)));

    while MemSize+ptr^.size > MaxMemSize do
      SwapABlock;

    if MemDebug then
      writeln(output,'Copying block from disk at offset ',ptr^.FileOfs);

    GetMem(ptr^.block,ptr^.size);
    while (ptr^.block=NIL) do begin
      if MemDebug then
        writeln('Failed to allocate data block. Swapping another out.');
      SwapABlock;
      GetMem(ptr^.block, ptr^.size);
    end;{while}

    if ptr^.RefCount>0 then
      ReadFile(ptr^.block, ptr^.size, FROM_START, ptr^.FileOfs);

    ptr^.flags:=ptr^.flags OR SWAPPED_IN;
    MemSize:=MemSize+ptr^.size;
  end;{LoadBlock}



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
{Standard ceiling function. Return the smallest integer greater than or equal
 to r}
  begin
    if frac(r)=0 then
      ceil:=trunc(r)
    else
      ceil:=trunc(r)+1;
  end;{ceil}

function PtrAdd(p:pointer; a:word):pointer;
{Increment the pointer p by a bytes}
  var s,o:word;
  begin
    s:=seg(p^);
    o:=ofs(p^);
    s:=s+(o div 16);
    o:=(o mod 16)+a;
    ptradd:=ptr(s,o);
  end;{ptradd}

function Bit(q,w:byte):byte;
{Returns the status of the wth bit of q}
  begin
    bit:=((q SHR w) AND 1);
  end;{bit}


function AllocateBuffer(size:word; gran:word):HeaderTypePtr;
  var p:HeaderTypePtr;
      q:word;
      TempInfo:byte;
  begin
    if MemDebug then
      writeln(output,'Allocating buffer size ',size,' granularity ',gran);

    if (SwapOn) and (size>MaxMemSize) then begin
      if MemDebug then
        writeln(output,'size ',size,' is larger than the max in-memory size');
      p:=NIL;
    end {if}
    else begin

      GetMem(p,SizeOf(HeaderType));
      if p<>NIL then begin

        if MemDebug then
          writeln(output,'Buffer block located at ',
            HexStr(seg(p^)),':',HexStr(ofs(p^)));

        {Initialize the block}
        p^.sig:=HEADER_SIG;
        p^.RefCount:=0;
        p^.flags:=0;
        p^.block:=NIL;  {Don't allocate memory for data block until needed}
        p^.size:=size;
        p^.NumBlocks:=ceil(size/gran);
        p^.BitmapSize:=ceil(p^.Numblocks/8);
        GetMem(p^.bitmap, p^.BitmapSize);
        if RootMem=NIL then
          p^.FileOfs:=0
        else
          p^.FileOfs:=RootMem^.FileOfs+RootMem^.Size;

        if (p^.Bitmap=NIL) then begin
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
          p^.next:=RootMem;
          RootMem:=p;

          If SwapOn then begin
            tempinfo:=0;
            for q:=1 to size do
              WriteFile(@tempinfo,SizeOf(TempInfo),FROM_END, 0);
          end;{if}

          if MemDebug then begin
            writeln(output,'Memory block located at ',
              HexStr(seg(p^.block^)),':',HexStr(ofs(p^)));
            writeln(output,'Allocation bitmap located at ',
              HexStr(seg(p^.Bitmap^)),':',HexStr(ofs(p^.Bitmap^)));

            writeln(output,memavail,' bytes free on heap now');
            writeln(output,maxavail,' bytes in largest hunk');
          end;{if debug}
        end;{else}
      end;{if}
    end;{else}

    AllocateBuffer:=p;
  end;{AllocateBuffer}


procedure MemGet(var p:Descriptor; ptr:HeaderTypePtr; ReqSize:word);
  var MaxBlocks,PlaceByte,MarkByte,ReqBlocks:word;
      PlaceBit, MarkBit:shortint;
  label GetOut;  {Ack! a goto. So sue me...}
  begin

    if MemDebug then
      writeln(output,'Allocating ',reqsize,' bytes from buffer at ',
               hexstr(seg(ptr^)),':',hexstr(ofs(ptr^)));

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

          with p do begin
            header:=ptr;
            referenced:=FALSE;
            stuff:=((MarkByte-1)*8)+(7-MarkBit);
          end;{with}
          inc(ptr^.RefCount);

          if MemDebug then
            writeln(output,'Allocated at BlockNum ',((MarkByte-1)*8)+(7-MarkBit),
                     '. ',((MarkByte-1)*8)+(7-MarkBit)*ptr^.granularity,
                     ' bytes past start of memory block');

        end {if maxblocks} else begin  {Not enough memory}
          with p do begin
            header:=NIL;
            referenced:=FALSE;
            stuff:=0;
          end;{with}

          if MemDebug then
            writeln(output,'Not enough memory');
        end;{else}

    end;{with}
  end;{MemGet}


procedure MemFree(ptr:Descriptor; size:word);
  var BlockNum, NumBlocks:word;
      PlaceByte:word;
      PlaceBit:ShortInt;
  begin

    BlockNum:=ptr.stuff;
    PlaceByte:=(BlockNum div 8)+1;
    PlaceBit:=7-(BlockNum mod 8);
    NumBlocks:=ceil(size/ptr.header^.granularity);

    if NumBlocks>0 then begin

      if MemDebug then
        writeln(output,'Freeing ',NumBlocks*ptr.header^.Granularity,
                ' bytes at block ',ptr.stuff,' from buffer at ',
                HexStr(seg(ptr.header^)),':',HexStr(ofs(ptr.header^)));

      while NumBlocks>0 do begin
        while (NumBlocks>0) and (PlaceBit>=0) do begin
          ptr.header^.Bitmap^[PlaceByte]:=ptr.header^.Bitmap^[PlaceByte] AND
                                   (NOT (1 SHL PlaceBit));
          dec(PlaceBit);
          dec(NumBlocks);
        end;{while}
        PlaceBit:=7;
        inc(PlaceByte);
      end;{while}
      dec(ptr.header^.RefCount);

    end {if} else

      if MemDebug then
        writeln(output,'Tried to free block ',ptr.stuff,
                ' from buffer at ',HexStr(seg(ptr.header^)),':',
                HexStr(ofs(ptr.header^)),' which was not allocated');
  end;{MemFree}


procedure ReleaseBuffer(ptr:HeaderTypePtr);
  var p1,p2:HeaderTypePtr;
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

    if ((ptr^.flags AND SWAPPED_IN)>0) then
      FreeMem(ptr^.Block, ptr^.size);

    FreeMem(ptr^.Bitmap, ptr^.BitmapSize);
    FreeMem(ptr, sizeof(HeaderType));

    if MemDebug then begin
      writeln(output,'Freeing buffer at ',seg(ptr^),':',ofs(ptr^));
      writeln(output,memavail,' bytes free on heap now');
      writeln(output,maxavail,' bytes in largest hunk');

      if (ptr^.RefCount>0) then
        writeln(output,'Warning: RefCount is not 0!');
    end;{if}

  end;{ReleaseBuffer}


procedure ReleaseAllBuffers;
  var p,q:HeaderTypePtr;
  begin
    p:=RootMem;

    while p<>NIL do begin
      q:=p^.next;
      ReleaseBuffer(p);
      p:=q;
    end;{while}
  end;{ReleaseAllBuffers}


function MemLeft(ptr:HeaderTypePtr):word;
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


function MaxLeft(ptr:HeaderTypePtr):word;
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

procedure FreeAll(ptr:HeaderTypePtr);
  var MarkByte:word;
  begin
    with ptr^ do begin
      for MarkByte:=1 to BitmapSize-1 do
        Bitmap^[MarkByte]:=0;

      Bitmap^[BitmapSize]:=(1 SHL (8-(NumBlocks mod 8)))-1;

      RefCount:=0;
    end;{with}
  end;{freeAll}


procedure MemLock(ptr:HeaderTypePtr; l:boolean);
  begin
    if l then
      ptr^.flags:=ptr^.flags OR LOCKED
    else
      ptr^.flags:=ptr^.flags AND (NOT LOCKED);

    if (ptr^.flags AND SWAPPED_IN)=0 then
      LoadBlock(ptr);
  end;{MemLock}

procedure MemNotDirty(ptr:HeaderTypePtr);
  begin
    ptr^.flags:=ptr^.flags AND (NOT DIRTY);
  end;{MemNotDirty}


procedure MemSwapOn(filename:string; size:longint);
  var s,o:word;
      p:HeaderTypePtr;
      f:file;
  begin

    if MemDebug then
      writeln(output,'Activating swapping');

    if not SwapOn then begin

      p:=RootMem;
      while p<>NIL do begin
        if p^.size>size then begin
          if MemDebug then
            writeln(output,'Cannot activate swapping with limit ',size,'.');
            writeln(output,'Block at ',HexStr(seg(p^)),':',HexStr(ofs(p^)),
                     ' is too large: ',p^.size,' bytes');
          exit;
        end;{if}
        p:=p^.next;
      end;{while}

      SwapFileName:=filename;
      SwapFileName[ord(SwapFileName[0])+1]:=#0;  {Make it ASCIIZ}

      assign(f,filename);
      rewrite(f);   {Create the file}
      close(f);
      s:=seg(SwapFileName);
      o:=ofs(SwapFileName)+1;  {Skip over length byte}
      ASM
        push ds

        mov ah,$3D
        mov al,$B2    {Not inherited, deny read/write, open read/write}
        mov dx,o
        mov cx,s
        mov ds,cx
        int $21

        pop ds

        mov SwapFileHandle,ax
      end;{asm}

      SwapOn:=TRUE;
      MaxMemSize:=size;

      while MemSize>MaxMemSize do
        SwapABlock;

    end {if not swapon}
    else
      if MemDebug then
        writeln(output,'Swapping already active');
  end;{SwapOn}

procedure MemSwapResize(size:longint);
  var p:HeaderTypePtr;
  begin

    p:=RootMem;
    while p<>NIL do begin
      if p^.size>size then begin
        if MemDebug then
          writeln(output,'Cannot activate swapping with limit ',size,'.');
          writeln(output,'Block at ',HexStr(seg(p^)),':',HexStr(ofs(p^)),
                   ' is too large: ',p^.size,' bytes');
        exit;
      end;{if}
      p:=p^.next;
    end;{while}

    MaxMemSize:=size;

    if SwapOn then
      while MemSize>MaxMemSize do
        SwapABlock;
  end;{MemSwapResize}

procedure MemSwapOff;
  var p:HeaderTypePtr;
      s,o:word;
  begin

    if MemDebug then
      writeln(output,'Deactivating swapping');

    SwapOn:=FALSE;
    MaxMemSize:=MemAvail;

    p:=RootMem;
    while p<>NIL do begin
      if (p^.flags AND SWAPPED_IN)=0 then
        LoadBlock(p);
      p:=p^.next;
    end;{while}

    ASM
      push ds

      mov ah,$3E   {Close file}
      mov bx,SwapFileHandle
      int $21

      pop ds
    end;{asm}
  end;{SwapOff}


function Descriptor.Addr:pointer;
  var p:pointer;
  begin

    if self.header^.sig<>HEADER_SIG then begin
      if MemDebug then
        writeln(output,'Tried dereferencing a descriptor with invalid header signature');
      writeln('NewMem2 Memory Fault: Segmentation Violation');
      RunError(204);
    end;{if}

    self.referenced:=TRUE;
    self.header^.flags:=self.header^.flags OR DIRTY;

    if (self.header^.flags AND MALLOCED)=0 then begin
    {Data block has never been used before}
      if SwapOn then
        while (MemSize+self.header^.size>MaxMemSize) do
          SwapABlock;

      GetMem(self.header^.block, self.header^.size);
      while (self.header^.block=NIL) do begin
        if MemDebug then
          writeln('Failed to allocate data block. Swapping another out.');
        SwapABlock;
        GetMem(self.header^.block, self.header^.size);
      end;{while}

      self.header^.flags:=self.header^.flags OR MALLOCED OR SWAPPED_IN;
      MemSize:=MemSize+self.header^.size;
    end {if}

    else
    if (self.header^.flags AND SWAPPED_IN)=0 then
      LoadBlock(self.header);

    p:=PtrAdd(self.header^.block, self.stuff*self.header^.Granularity);

    Addr:=p;
  end;{MemPtr}


begin {main}
  MemDebug:=FALSE;
  RootMem:=NIL;
  SwapFileName:='';
  SwapFileHandle:=0;
  MemSize:=0;
  MaxMemSize:=MaxAvail;
  SwapOn:=FALSE;
end.
