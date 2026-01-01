{*******************************************************}
{                                                       }
{         Borland Delphi Unit                           }
{                                                       }
{         Copyright (c) 1995 OKO ROSNO                  }
{                                                       }
{*******************************************************}

unit AppUtils;

interface

uses
  Forms;

{ Утилиты уровня приложения }

function GetDefaultIniName: string;

function FindForm(FormClass: TFormClass): TForm;

procedure SaveFormPlacement(Form: TForm);
procedure RestoreFormPlacement(Form: TForm);

implementation

uses
  WinTypes, WinProcs,Classes, SysUtils, IniFiles,
  AGSLib;

function GetDefaultIniName: string;
begin
  Result := ExtractFileName(ChangeFileExt(Application.ExeName, '.INI'));
end;

function FindForm(FormClass: TFormClass): TForm;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Screen.FormCount - 1 do begin
    if Screen.Forms[I] is FormClass then begin
      Result := Screen.Forms[I];
      Break;
    end;
  end;
end;

procedure SaveFormPlacement(Form: TForm);
var
  Placement: TWindowPlacement;
begin
  with TIniFile.Create(GetDefaultIniName) do begin
    try
      Placement.length := SizeOf(TWindowPlacement);
      GetWindowPlacement(Form.Handle, @Placement);
      with Placement, Form do begin
        if (FormStyle = fsMDIChild) and (WindowState = wsMinimized) then
          Flags := Flags or WPF_SETMINPOSITION;
        WriteInteger(Caption, 'Flags', Flags);
        WriteInteger(Caption, 'ShowCmd', ShowCmd);
        WriteString(Caption, 'MinMaxPos', Format('%d %d %d %d',
          [ptMinPosition.X, ptMinPosition.Y, ptMaxPosition.X, ptMaxPosition.Y]));
        WriteString(Caption, 'NormPos', Format('%d %d %d %d',
          [rcNormalPosition.Left, rcNormalPosition.Top, rcNormalPosition.Right, rcNormalPosition.Bottom]));
      end;
    finally
      Free;
    end;
  end;
end;

procedure RestoreFormPlacement(Form: TForm);
var
  PosStr: string;
  Placement: TWindowPlacement;
  WinState: TWindowState;
begin
  with TIniFile.Create(GetDefaultIniName) do begin
    try
      Placement.length := SizeOf(TWindowPlacement);
      with Placement, Form do begin
        Flags := ReadInteger(Caption, 'Flags', 0);
        ShowCmd := ReadInteger(Caption, 'ShowCmd', SW_SHOWNORMAL);
        WinState := wsNormal;
        case ShowCmd of
          SW_MINIMIZE, SW_SHOWMINIMIZED:
            WinState := wsMinimized;
          SW_MAXIMIZE:
            WinState := wsMaximized;
        end;
        ShowCmd := SW_HIDE;
        PosStr := ReadString(Caption, 'MinMaxPos', '');
        if PosStr <> '' then begin
          ptMinPosition.X := StrToInt(ExtractWord(1, PosStr, [' ']));
          ptMinPosition.Y := StrToInt(ExtractWord(2, PosStr, [' ']));
          ptMaxPosition.X := StrToInt(ExtractWord(3, PosStr, [' ']));
          ptMaxPosition.Y := StrToInt(ExtractWord(4, PosStr, [' ']));
          PosStr := ReadString(Caption, 'NormPos', '');
          if PosStr <> '' then begin
            rcNormalPosition.Left := StrToInt(ExtractWord(1, PosStr, [' ']));
            rcNormalPosition.Top := StrToInt(ExtractWord(2, PosStr, [' ']));
            rcNormalPosition.Right := StrToInt(ExtractWord(3, PosStr, [' ']));
            rcNormalPosition.Bottom := StrToInt(ExtractWord(4, PosStr, [' ']));
            if rcNormalPosition.Right > rcNormalPosition.Left then begin
              SetWindowPlacement(Handle, @Placement);
              WindowState := WinState;
            end;
          end;
        end;
      end;
    finally
      Free;
    end;
  end;
end;

end.
