unit HintProp;

interface

uses DsgnIntf;

type
  THintProperty = class(TStringProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure Edit; override;
  end;

implementation

uses SysUtils, StrEdit, Forms, Controls;

function THintProperty.GetAttributes: TPropertyAttributes;
begin
  Result := inherited GetAttributes + [paDialog];
end;

procedure THintProperty.Edit;
var
  HintString: array[0..255] of Char;
  Temp: string absolute HintString;
  P: PChar;
begin
  with TStrEditDlg.Create(Application) do
  try
    Memo.MaxLength := 255;
    StrPCopy(@HintString, GetStrValue);
    Memo.Lines.SetText(@HintString);
    UpdateStatus(nil);
    ActiveControl := Memo;
    if ShowModal = mrOk then begin
      P := Memo.Lines.GetText;
      try
        Temp := StrPas(P);
      finally
        StrDispose(P);
      end;
      if (Temp[0] > #0) then Dec(Temp[0], 2);
      SetStrValue(Temp);
    end;
  finally
    Free;
  end;
end;

end.
