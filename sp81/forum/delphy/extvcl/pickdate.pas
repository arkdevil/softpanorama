{*******************************************************}
{                                                       }
{         Borland Delphi Unit                           }
{                                                       }
{         Copyright (c) 1995 OKO ROSNO                  }
{                                                       }
{*******************************************************}
{$S-}

unit PickDate;

interface

uses WinTypes, WinProcs, Classes, Controls, SysUtils;

function SelectDate(var Date: TDateTime; const DlgCaption: TCaption): Boolean;
function SelectDateStr(var StrDate: string; const DlgCaption: TCaption): Boolean;

implementation

Uses Graphics, Forms, Buttons, StdCtrls, Grids, Calendar, ExtCtrls,
  ExtConst;

{$R *.RES}

{ TSelectDateDlg }

type
  TSelectDateDlg = class(TForm)
    Calendar: TCalendar;
    TitleLabel: TLabel;
    PrevMonthBtn: TSpeedButton;
    NextMonthBtn: TSpeedButton;
    PrevYearBtn: TSpeedButton;
    NextYearBtn: TSpeedButton;
    procedure PrevMonthBtnClick(Sender: TObject);
    procedure NextMonthBtnClick(Sender: TObject);
    procedure PrevYearBtnClick(Sender: TObject);
    procedure NextYearBtnClick(Sender: TObject);
    procedure CalendarChange(Sender: TObject);
  private
    { Private declarations }
    procedure SetDate(Date: TDateTime);
    function GetDate: TDateTime;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent);
    property Date: TDateTime read GetDate write SetDate;
  end;

constructor TSelectDateDlg.Create(AOwner: TComponent);
begin
  inherited CreateNew(AOwner);
  Caption := GetExtStr(SDateDlgTitle);
  BorderStyle := bsDialog;
  ClientWidth := 362;
  ClientHeight := 215;
  Font.Name := 'MS Sans Serif';
  Font.Size := 8;
  Font.Style := [fsBold];
  Position := poScreenCenter;
  ShowHint := True;

  with TBevel.Create(Self) do begin
    Parent := Self;
    SetBounds(8, 8, 345, 167);
    Style := bsRaised;
  end;

  TitleLabel := TLabel.Create(Self);
  with TitleLabel do begin
    Parent := Self;
    ParentFont := True;
    SetBounds(63, 18, 236, 13);
    Alignment := taCenter;
    AutoSize := False;
    Caption := '';
  end;

  PrevMonthBtn := TSpeedButton.Create(Self);
  with PrevMonthBtn do begin
    Parent := Self;
    SetBounds(46, 16, 20, 20);
    Glyph.Handle := LoadBitmap(hInstance, 'PREV_1');
    OnClick := PrevMonthBtnClick;
    Hint := GetExtStr(SPrevMonth);
  end;

  PrevYearBtn := TSpeedButton.Create(Self);
  with PrevYearBtn do begin
    Parent := Self;
    SetBounds(22, 16, 20, 20);
    Glyph.Handle := LoadBitmap(hInstance, 'PREV_2');
    OnClick := PrevYearBtnClick;
    Hint := GetExtStr(SPrevYear);
  end;

  NextMonthBtn := TSpeedButton.Create(Self);
  with NextMonthBtn do begin
    Parent := Self;
    SetBounds(295, 16, 20, 20);
    Glyph.Handle := LoadBitmap(hInstance, 'NEXT_1');
    OnClick := NextMonthBtnClick;
    Hint := GetExtStr(SNextMonth);
  end;

  NextYearBtn := TSpeedButton.Create(Self);
  with NextYearBtn do begin
    Parent := Self;
    SetBounds(319, 16, 20, 20);
    Glyph.Handle := LoadBitmap(hInstance, 'NEXT_2');
    OnClick := NextYearBtnClick;
    Hint := GetExtStr(SNextYear);
  end;

  Calendar := TCalendar.Create(Self);
  with Calendar do begin
    Parent := Self;
    ParentFont := True;
    SetBounds(22, 41, 317, 120);
    Color := clSilver;
    StartOfWeek := 1;
    TabOrder := 0;
    UseCurrentDate := False;
    OnChange := CalendarChange;
  end;

  with TBitBtn.Create(Self) do begin
    Parent := Self;
    ParentFont := True;
    SetBounds(176, 181, 85, 27);
    Kind := bkOk;
    TabOrder := 1;
    Margin := 2;
    Spacing := -1;
  end;

  with TBitBtn.Create(Self) do begin
    Parent := Self;
    ParentFont := True;
    SetBounds(268, 181, 85, 27);
    Kind := bkCancel;
    TabOrder := 2;
    Margin := 2;
    Spacing := -1;
  end;

  Calendar.CalendarDate := Date;
  ActiveControl := Calendar;
end;

procedure TSelectDateDlg.SetDate(Date: TDateTime);
begin
  try
    Calendar.CalendarDate := Date;
  except
    Calendar.CalendarDate := SysUtils.Date;
  end;
end;

function TSelectDateDlg.GetDate: TDateTime;
begin
  Result := Calendar.CalendarDate;
end;

procedure TSelectDateDlg.PrevYearBtnClick(Sender: TObject);
begin
  Calendar.PrevYear;
end;

procedure TSelectDateDlg.NextYearBtnClick(Sender: TObject);
begin
  Calendar.NextYear;
end;

procedure TSelectDateDlg.PrevMonthBtnClick(Sender: TObject);
begin
  Calendar.PrevMonth;
end;

procedure TSelectDateDlg.NextMonthBtnClick(Sender: TObject);
begin
  Calendar.NextMonth;
end;

procedure TSelectDateDlg.CalendarChange(Sender: TObject);
begin
  TitleLabel.Caption := FormatDateTime('MMMM, YYYY', Calendar.CalendarDate);
end;

{ SelectDate routines }

function SelectDate(var Date: TDateTime; const DlgCaption: TCaption): Boolean;
var
  D: TSelectDateDlg;
begin
  Result := False;
  D := TSelectDateDlg.Create(Application);
  try
    D.Date := Date;
    if DlgCaption <> '' then D.Caption := DlgCaption;
    { scale to screen res }
    if Screen.PixelsPerInch <> 96 then
    begin
      D.ScaleBy(Screen.PixelsPerInch, 96);
      { The ScaleBy method does not scale the font well, so set the
        font back to the original info. }
      D.Calendar.ParentFont := True;
      D.Font.Name := 'MS Sans Serif';
      D.Font.Size := 8;
      D.Font.Style := [fsBold];
      D.Left := (Screen.Width div 2) - (D.Width div 2);
      D.Top := (Screen.Height div 2) - (D.Height div 2);
      D.Font.Color := clBlack;
    end;
    if D.ShowModal = mrOk then begin
      Date := D.Date;
      Result := True;
    end;
  finally
    D.Free;
  end;
end;

function SelectDateStr(var StrDate: string; const DlgCaption: TCaption): Boolean;
var
  DateValue: TDateTime;
begin
  if StrDate <> '' then
  begin
    try
      DateValue := StrToDate(StrDate);
    except
      DateValue := Date;
    end;
  end
  else DateValue := Date;
  Result := SelectDate(DateValue, DlgCaption);
  if Result then StrDate := DateToStr(DateValue);
end;

end.
