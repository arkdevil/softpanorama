{*******************************************************}
{                                                       }
{         Borland Delphi Unit                           }
{                                                       }
{         Copyright (c) 1995 OKO ROSNO                  }
{                                                       }
{*******************************************************}
Unit ExtConst;

interface

{$I EXTCONST.INC}

function GetExtStr(Source: Longint): string;

implementation

{$R *.RES}

Uses SysUtils;

function GetExtStr(Source: Longint): string;
begin
  Result := '';
  if PChar(Source) <> nil then begin
    if PtrRec(Source).Seg = 0 then
      Result := LoadStr(PtrRec(Source).Ofs)
    else
      Result := StrPas(PChar(Source));
  end;
end;

end.