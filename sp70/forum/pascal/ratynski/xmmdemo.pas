uses Objects, Strings;
const
  TestStr: String = 'XMS Stream test!';
var
  S: TXMSStream;
  I: Byte;
begin
  S.Init(1);
  if S.Status <> stOk Then WriteLn('Error in XMS Stream!')
  else begin
    for I := 0 to StrLength(TestStr) do S.Write(TestStr[I], 1);
    WriteLn('Current position = ', S.GetPos);
    S.Seek(0);
    WriteLn('Current position = ', S.GetPos);
    WriteLn('Current size = ', S.GetSize);
    FillChar(TestStr, 20, 0);
    for I := 0 to 16 do begin
      S.Read(TestStr[I], 1);
      Write(S.GetPos, ' ');
    end;
    WriteLn;
    WriteLn(TestStr);
    WriteLn('Status = ', S.Status);
    WriteLn('Current position = ', S.GetPos);
    WriteLn('Current size = ', S.GetSize);
    S.Seek(0);
    TestStr := '';
    WriteLn(S.ReadString);
  end;
  S.Done;
end.