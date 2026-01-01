{$X+}

Unit Defence;      { Self-Defence unit }

interface

Uses
  Dos,TpClone,MsgBox,TpString,TpDate,Views;

type
  UserInfo = record
    Name: String[10];
    Date1: LongInt;
  end;

  StatInfo = record
    CloneID: LongInt;
    CSum: LongInt;
    BootCS: Word;
    UserList: Array[1..10] Of UserInfo;
    UserN: Byte;
    PS2: Byte;
    MainCSum: Word;
  end;

const
  CArea: StatInfo = (
    CloneID:  $0;            { Marker to find out patch area }
    CSum:     $0;            { EXE file checksum by itself }
    BootCS:   $0;            { C: Boot sector checksum }
    UserList: ((),(),(),(),(),(),(),(),(),());
    UserN:    $0;
    PS2:      $0;
    MainCSum: $0             { Checksum of all of the above }
  );

procedure InitDSystem;

implementation

{$L RND.OBJ}
procedure _RND_; external;

type
  A256 = Array [0..255] Of Byte;

var
  CP: ClonePack;
  Offset: LongInt;
  RND: ^A256;
  i: Word;
  Boot: Array[0..511] Of Byte;
  R: Registers;
  Buf: Array[1..2048] Of Byte;
  _A: Array[1..SizeOf(CArea)] Of byte absolute CArea;

{$L README.OBJ}
procedure Doc; external;  { not a procedure, it's .LZH self-extractor }

procedure UnpackDoc;
const
  FSize = 4541;
type
  FBuf = Array[1..FSize] Of Byte;
var
  Buf: ^FBuf;
  F: File;

begin
  Buf := @Doc;
  Assign(F,'README.EXE');
  {$I-} Rewrite(F,1); {$I+}
  if IOResult = 0 then
  begin
    BlockWrite(F,Buf^,FSize);
    Close(F);
    MessageBox(#13^C'Sfx README.EXE created.', nil, mfInformation+mfOkButton);
  end
  else
  begin
    MessageBox(#13^C'Error creating Sfx file,'#13+
               ^C'maybe, disk write protected.',
               nil, mfError+mfOkButton);
  end;
end;

function BootCSL: LongInt;
var
  A: LongInt;
begin
  A := 0;
  R.es := Seg(Boot);
  R.bx := Ofs(Boot);
  R.ax := $0201;
  R.dx := $0180;
  R.cx := $0001;
  Intr($13,R);
  for i := 0 to 511 do
    Inc(A,Boot[i]);
  BootCSL := A;
end;

function GetCSum(S: LongInt): LongInt;
var
  R: Word;
  L: LongInt;
begin
  Seek(CP.CloneF,0);
  L := 0;
  repeat
    BlockRead(CP.CloneF,Buf,2048,R);
    for i := 1 to R do
      Inc(L,Buf[i]);
    if S-FilePos(CP.CloneF) < 2048 then
    begin
      BlockRead(CP.CloneF,Buf,S-FilePos(CP.CloneF),R);
      Seek(CP.CloneF,FileSize(CP.CloneF));
      for i := 1 to R do
        Inc(L,Buf[i]);
    end;
  until Eof(CP.CloneF);
  GetCSum := L;
end;

procedure EncodeCArea(Length: LongInt);
var
  L: LongInt;
begin
  L := 0;
  CArea.BootCS := BootCSL;
  CArea.CSum := GetCSum(Length);
  for i := 1 to SizeOf(CArea)-4 do
    Inc(L,_A[i]);
  CArea.MainCSum := L;
  for i := Byte(L) to SizeOf(CArea)-7+Byte(L) do
    Inc(_A[i-Byte(L)+5],RND^[Byte(i)]);
end;

procedure DecodeCArea;
var
  L: LongInt;
begin
  L := CArea.MainCSum;
  for i := Byte(L) to SizeOf(CArea)-7+Byte(L) do
    Dec(_A[i-Byte(L)+5],RND^[Byte(i)]);
end;

procedure AddUser;
var
  S: String;
  T: DateTime;
  CompID: Byte absolute $F000:$FFFE;

begin
  S := '';
  InputBox('Wow! New owner! How pleasant!',
           'Please, identify yourself:',S,10);
  Inc(CArea.UserN);
  if CArea.UserN > 10 then CArea.UserN := 1;
  CArea.UserList[CArea.UserN].Name := S;
  CArea.UserList[CArea.UserN].Date1 := Today;
  CArea.PS2 := 3;
  if CompID in [$FA,$F8] then CArea.PS2 := 1;
  if CompID in [$FF,$FE,$FD,$FB,$F9] then CArea.PS2 := 0;
  if (CompID = $FC)or(CArea.PS2 = 3) then
  begin
    if MessageBox(#13^C'Is your computer PS2 ?', nil, 
                  mfConfirmation+mfYesButton+mfNoButton) <> cmYes then
    CArea.PS2 := 0 else CArea.PS2 := 1;
  end;
  if Offset <> 0 then
  begin
    EncodeCArea(FileSize(CP.CloneF)-SizeOf(CArea));
    StoreDefaults(CP,Offset,CArea,SizeOf(CArea));
  end
  else
    EncodeCArea(FileSize(CP.CloneF));
  DecodeCArea;
  if MessageBox(#13^C'Do you want to unpack'#13+
                ^C'my README.TXT file ?', nil, 
                mfConfirmation+mfYesButton+mfNoButton) = cmYes then
    UnpackDoc;
end;

procedure InitDSystem;
var
  A: LongInt;
  S: String[80];
begin
  RND := @_RND_;
  S := ParamStr(0);
  CArea.CloneID := $12340000+$00005678;
  Offset := InitForCloning(S,CP,CArea.CloneID,4);
  if Offset = 0 then
  begin
    if S[1] = 'C' then
    begin
      AddUser;
      EncodeCArea(FileSize(CP.CloneF));
      Seek(CP.CloneF,FileSize(CP.CloneF));
      BlockWrite(CP.CloneF,CArea,SizeOf(CArea));
      if IOResult <> 0 then
        MessageBox(^C'Drive '+S[1]+': is write-protected.'#13+
                   ^C'Please, run program on unprotected'#13+
                   ^C'drive on your computer at once.', nil, mfError+mfOkButton);
      CloseForCloning(CP);
      Halt;
    end
    else
    begin
      MessageBox(^C'EXE file changed (compressed?).'#13+
                 ^C'Use backup copy, please.', nil, mfError + mfOkButton);
      CloseForCloning(CP);
      Halt;
    end;
  end;
  LoadDefaults(CP,Offset,CArea,SizeOf(CArea));
  DecodeCArea;
  A := 0;
  for i := 1 to SizeOf(CArea)-4 do
    Inc(A,_A[i]);
  if (Word(A) <> CArea.MainCSum) or
     (CArea.CSum <> GetCSum(FileSize(CP.CloneF)-SizeOf(CArea))) then
  begin
    MessageBox(^C'EXE file checksum error,'#13+
               ^C'maybe, file was compressed'#13+
               ^C'or infected by virus.', nil, mfError+mfOkButton);
    Halt;
  end;
  if CArea.BootCS <> BootCSL then AddUser;
  CloseForCloning(CP);
end;

end.
