{$A+,B-,E+,F-,I+,N-,O-,R-,V-}
{$UNDEF DEBUG}
{$IFDEF DEBUG} {$D+,L+,S+} {$ELSE} {$D-,L-,S-} {$ENDIF}
Unit Buffer;

Interface


Type BigBuffer     = Array [0..65000] of Byte;
     Str79         = String[79];

     DiskBufferOBJ = Object
      vDiskError    : Integer; { Set when there is a error }
      vFile         : File;
      vUseBuffer    : Boolean;
      vUpdateBuffer : Boolean;
      vBufferSize   : Word;
      vBufferPtr    : ^BigBuffer;
      vBufStart,
      vBufEnd,
      vFilePtr      : Longint; { Geeft start buffer en eind van buffer aan }

      Constructor Init(BufferSize : Word);
      Function    Open(F : Str79) : Boolean;
      Procedure   Close;
      Procedure   ReadIntoBuffer; { Internaly called }
      Procedure   Seek(P : Longint);
      Function    FilePos : Longint;
      Function    ReadByte : Byte;
      Function    ReadChar : Char;
      Function    ReadWord : Word;
      Function    ReadLong : Longint;
      Destructor  Done;
     End;


Implementation


Constructor DiskBufferOBJ.Init(BufferSize : Word);
Begin
 vBufferSize   := BufferSize;
 vDiskError    := 0;
 vUpdateBuffer := True;

 if MemAvail>=vBufferSize then
  Begin
   GetMem(vBufferPtr,vBufferSize);
   vUseBuffer := True;
  End Else Begin
            vBufferPtr := Nil;
            vUseBuffer := False;
           End;
End;

Function DiskBufferOBJ.Open(F : Str79) : Boolean;
Begin
 Open := False;
 Assign(vFile,F);
{$I-}
 Reset(vFile,1);
 if IOResult<>0 then Exit;
{$I+}
 vBufEnd   := 0;
 vBufStart := 0;
 vFilePtr  := -1;
 Open      := True;
End;

Procedure DiskBufferOBJ.Close;
Begin
{$I-}
 System.Close(vFile);
 if IOResult<>0 then ;
{$I+}
End;

Procedure DiskBufferOBJ.Seek(P : Longint);
Begin
 System.Seek(vFile,P);
 if (P>=vBufStart) And (P<=vBufEnd) then vFilePtr := P
  Else vUpdateBuffer := True;
End;

Function DiskBufferOBJ.FilePos : Longint;
Begin
 FilePos := vFilePtr;
End;

Procedure DiskBufferOBJ.ReadIntoBuffer;
Var Result : Word;
Begin
 vUpdateBuffer := False;
 vBufStart     := System.FilePos(vFile);
 vFilePtr      := vBufStart;
 BlockRead(vFile,vBufferPtr^,vBufferSize,Result);
 vBufEnd := vFilePtr + Pred(Result);
End;

Function DiskBufferOBJ.ReadByte : Byte;
Var Result : Word;
    B      : Byte;
Begin
 if vUseBuffer then
  Begin
   if (vFilePtr>vBufEnd) Or (vFilePtr<vBufStart) Or (vUpdateBuffer) then
    ReadIntoBuffer;
   B := vBufferPtr^[vFilePtr-vBufStart];
   Inc(vFilePtr);
  End Else Begin
            BlockRead(vFile,B,Sizeof(B),Result);
            if Result<>Sizeof(B) then vDiskError := 1;
           End;

 ReadByte := B;
End;

Function DiskBufferOBJ.ReadChar : Char;
Var Result : Word;
    B      : Byte;
Begin
 if vUseBuffer then
  Begin
   if (vFilePtr>vBufEnd) Or (vFilePtr<vBufStart) Or (vUpdateBuffer) then
    ReadIntoBuffer;
   B := vBufferPtr^[vFilePtr-vBufStart];
   Inc(vFilePtr);
  End Else Begin
            BlockRead(vFile,B,Sizeof(B),Result);
            if Result<>Sizeof(B) then vDiskError := 1;
           End;

 ReadChar := Char(B);
End;

Function DiskBufferOBJ.ReadWord : Word;
Var W : Word;
    B : Array [1..2] of Byte Absolute W;
Begin
 B[1] := ReadByte;
 B[2] := ReadByte;
 ReadWord := W;
End;

Function DiskBufferOBJ.ReadLong : Longint;
Var L : Word;
    B : Array [1..4] of Byte Absolute L;
Begin
 B[1] := ReadByte;
 B[2] := ReadByte;
 B[3] := ReadByte;
 B[4] := ReadByte;
 ReadLong := L;
End;

Destructor DiskBufferOBJ.Done;
Begin
 if vBufferPtr<>Nil then
  Begin
   FreeMem(vBufferPtr,vBufferSize);
   vBufferSize := 0;
  End;
End;




End.