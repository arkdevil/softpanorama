{+--------------------------------------------------------------+}
{| Unit AlphaBar.                                               |}
{|                                                              |}
{| This unit includes the following VCL components:             |}
{|    o tAlphaPanel                                             |}
{|                                                              |}
{| Version 1.0 - May 1995.                                      |}
{| (c) Ingo Humann                                              |}
{|     Mühlstr. 3                                               |}
{|     67105 Schifferstadt                                      |}
{|     GERMANY                                                  |}
{|     CIS: 100116,3354  Internet: 100116.3354@compuserve.com   |}
{+--------------------------------------------------------------+}

{$A+,B-,D-,F-,G+,I-,K+,P+,Q-,R-,S-,T-,V-,W-,X+,Y+}

unit Alphabar;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls, Buttons, Menus;

type
  TAlphaPanel = class(TCustomPanel)
  private
    { Private-Deklarationen }
    fActiveButton : char;
    fAlphaButtons : tStringList;
    fButtonFont : tFont;
    fBlankXSize, fBlankYSize, fButtonHeight, fButtonLeftMargin, fButtonTopMargin,
      fButtonWidth : word;
    fButtonXSpacing, fButtonYSpacing : integer;
    fAllowAllUp, fCatchButtons : boolean;
    firstButton : tSpeedButton;
    fOnValueChange : tNotifyEvent;
    procedure HandleButton(Sender :tObject);
    procedure SetActiveButton(value :char);
    procedure SetAllowAllUp(value :boolean);
    procedure SetAlphaButtons(value :tStringList);
    procedure SetBlankXSize(value :word);
    procedure SetBlankYSize(value :word);
    procedure SetButtonFont(value :tFont);
    procedure SetButtonHeight(value :word);
    procedure SetButtonLeftMargin(value :word);
    procedure SetButtonTopMargin(value :word);
    procedure SetButtonWidth(value :word);
    procedure SetCatchStates;
    procedure SetCatchButtons(value :boolean);
    procedure SetButtonXSpacing(value :integer);
    procedure SetButtonYSpacing(value :integer);
  protected
    { Protected-Deklarationen }
    procedure AddLetterButtons; virtual;
    procedure DestroyButtons;
    procedure Loaded; override;
  public
    { Public-Deklarationen }
    constructor Create(aOwner :tComponent); override;
    destructor Destroy; override;
    function GetButton(value :char) :tSpeedButton;
  published
    { Published-Deklarationen }
    property Align;
    property BevelInner;
    property BevelOuter;
    property BorderStyle;
    property BevelWidth;
    property Color;
    property Ctl3D;
    property Cursor;
    property Enabled;
    property Height default 22;
    property Locked;
    property ParentColor;
    property ParentCtl3D;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property Width default 448;
    property Visible;
    property ActiveButton :char read fActiveButton write SetActiveButton default #0;
    property AllowAllUp :boolean read fAllowAllUp write SetAllowAllUp default false;
    property AlphaButtons :tStringList read fAlphaButtons write SetAlphaButtons;
    property BlankXSize :word read fBlankXSize write SetBlankXSize default 9;
    property BlankYSize :word read fBlankYSize write SetBlankYSize default 9;
    property ButtonFont :tFont read fButtonFont write SetButtonFont;
    property ButtonHeight :word read fButtonHeight write SetButtonHeight default 18;
    property ButtonLeftMargin :word read fButtonLeftMargin write SetButtonLeftMargin default 2;
    property ButtonTopMargin :word read fButtonTopMargin write SetButtonTopMargin default 2;
    property ButtonWidth :word read fButtonWidth write SetButtonWidth default 18;
    property ButtonXSpacing :integer read fButtonXSpacing write SetButtonXSpacing default -1;
    property ButtonYSpacing :integer read fButtonYSpacing write SetButtonYSpacing default -1;
    property CatchButtons :boolean read fCatchButtons write SetCatchButtons;
    property OnValueChange :tNotifyEvent read fOnValueChange write fOnValueChange;
  end;

procedure Register;

implementation

{+--------------------------------------------------------------+}
{| Def: tAlphaPanel                                             |}
{+--------------------------------------------------------------+}

constructor TAlphaPanel.Create;
var
  aButton : tSpeedButton;
begin
  inherited Create(aOwner);
  Width := 448; Height := 22;
  ControlStyle := ControlStyle - [csSetCaption];
  fActiveButton := #0;
  fButtonFont := tFont.Create;
  fBlankXSize := 9; fBlankYSize := 9;
  fButtonWidth := 18; fButtonHeight := 18;
  fButtonXSpacing := -1; fButtonYSpacing := -1;
  fButtonLeftMargin := 2;
  fButtonTopMargin := 2;
  aButton := tSpeedButton.Create(Self);
  fButtonFont.Assign(aButton.Font);
  aButton.Destroy;
  fAlphaButtons := tStringList.Create;
end;

destructor TAlphaPanel.Destroy;
begin
  fButtonFont.Destroy;
  inherited Destroy;
end;

procedure TAlphaPanel.AddLetterButtons;
var
  aButton : tSpeedButton;
  ButtonCount, i, m, n, aXPos, aYPos : word;
  sign : char;
  isblank : boolean;
begin
  aXPos := fButtonLeftMargin; aYPos := fButtonTopMargin;
  aButton := NIL; ButtonCount := 0;
  for n := 1 to fAlphaButtons.Count do
  begin
    m := Length(fAlphaButtons.Strings[n - 1]);
    if m = 0 then {* empty line }
    begin
      inc(aYPos, fBlankYSize);
      aXPos := fButtonLeftMargin;
      isBlank := true;
    end else
      for i := 1 to m do
      begin
        sign := fAlphaButtons.Strings[n - 1][i];
        if sign = #32 then {* blank character = horizontal blank... }
        begin
          inc(aXPos, fBlankXSize);
          isBlank := true;
        end
        else {* ...otherwise: insert button }
        begin
          isBlank := false;
          aButton := tSpeedButton.Create(Self);
          InsertControl(aButton);
          with aButton do
          begin
            Left := axPos; Top := aYPos;
            width := fButtonWidth; height := fButtonHeight;
            Caption := sign;
            tag := ord(sign);
            OnClick := HandleButton;
            font.Assign(fButtonFont);
            visible := true;
          end;
          if not isBlank then
            inc(aXPos, fButtonWidth);
          inc(aXPos, fButtonXSpacing);
          inc(ButtonCount);
        end;
      end;
    if not isBlank then
      inc(aYPos, fButtonHeight);
    inc(aYPos, fButtonYSpacing);
    aXPos := fButtonLeftMargin;
  end;
  firstButton := aButton;
  SetCatchStates;
end;

procedure TAlphaPanel.DestroyButtons;
var
  i, n : integer;
  aButton : tSpeedButton;
begin
  n := ControlCount;
  for i := 1 to n do
  begin
    aButton := tSpeedButton(Controls[0]);
    RemoveControl(aButton);
    aButton.Destroy;
  end;
  firstButton := NIL;
end;

function TAlphaPanel.GetButton(value :char) :tSpeedButton;
var
  i : integer;
begin
  Result := NIL;
  i := ControlCount;
  while (i <> 0) and (result = NIL) do
  begin
    if Controls[i - 1] is tSpeedButton then
      if (Controls[i - 1] as tSpeedButton).Tag = ord(value) then
        Result := tSpeedButton(Controls[i - 1]);
    dec(i);
  end;
end;

procedure TAlphaPanel.HandleButton;
var
  SenderBtn : tSpeedButton;
begin
  SenderBtn := Sender as tSpeedButton;
  case fCatchButtons of
    true  : if SenderBtn.Down then
              fActiveButton := chr(SenderBtn.Tag)
            else
              fActiveButton := #0;
    false : fActiveButton := chr(SenderBtn.Tag);
  end;
  if Assigned(FOnValueChange) then
    FOnValueChange(Self);
end;

procedure tAlphaPanel.Loaded;
begin
  inherited Loaded;
  AddLetterButtons;
end;

procedure TAlphaPanel.SetActiveButton;
var
  aButton : tSpeedButton;
begin
  if (value = #0) and fCatchButtons then
  begin
    aButton := GetButton(fActiveButton);
    if aButton <> NIL then
      aButton.Down := false;
    fActiveButton := #0;
    if Assigned(FOnValueChange) then
      FOnValueChange(Self);
    Exit;
  end;
  aButton := GetButton(value);
  begin
    fActiveButton := value;
    if fCatchButtons then
      aButton.Down := true;
    if Assigned(FOnValueChange) then
      FOnValueChange(Self);
  end;
end;

procedure TAlphaPanel.SetAllowAllUp(value :boolean);
begin
  if fAllowAllUp <> value then
  begin
    fAllowAllUp := value;
    if fCatchButtons then
      SetCatchStates;
  end;
end;

procedure TAlphaPanel.SetAlphaButtons;
begin
  DestroyButtons;
  fAlphaButtons.Clear;
  fAlphaButtons.Assign(value);
  AddLetterButtons;
  fActiveButton := #0;
  SetCatchStates;
  if Assigned(FOnValueChange) then
    FOnValueChange(Self);
end;

procedure TAlphaPanel.SetBlankXSize;
begin
  if fBlankXSize <> value then
  begin
    fBlankXSize := value;
    DestroyButtons;
    AddLetterButtons;
  end;
end;

procedure TAlphaPanel.SetBlankYSize;
begin
  if fBlankYSize <> value then
  begin
    fBlankYSize := value;
    DestroyButtons;
    AddLetterButtons;
  end;
end;

procedure TAlphaPanel.SetButtonFont;
var
  i : integer;
  aButton : tSpeedButton;
begin
  for i := 0 to ControlCount - 1 do
  begin
    aButton := NIL;
    if Controls[i] is tSpeedButton then
      tSpeedButton(Controls[i]).Font.Assign(value);
  end;
  fButtonFont.Assign(value);
end;

procedure TAlphaPanel.SetButtonHeight;
begin
  if fButtonHeight <> value then
  begin
    fButtonHeight := value;
    DestroyButtons;
    AddLetterButtons;
  end;
end;

procedure TAlphaPanel.SetButtonLeftMargin;
begin
  if fButtonLeftMargin <> value then
  begin
    fButtonLeftMargin := value;
    DestroyButtons;
    AddLetterButtons;
  end;
end;

procedure TAlphaPanel.SetButtonTopMargin;
begin
  if fButtonTopMargin <> value then
  begin
    fButtonTopMargin := value;
    DestroyButtons;
    AddLetterButtons;
  end;
end;

procedure TAlphaPanel.SetButtonXSpacing;
begin
  if fButtonXSpacing <> value then
  begin
    fButtonXSpacing := value;
    DestroyButtons;
    AddLetterButtons;
  end;
end;

procedure TAlphaPanel.SetButtonYSpacing;
begin
  if fButtonYSpacing <> value then
  begin
    fButtonYSpacing := value;
    DestroyButtons;
    AddLetterButtons;
  end;
end;

procedure TAlphaPanel.SetButtonWidth;
begin
  if fButtonWidth <> value then
  begin
    fButtonWidth := value;
    DestroyButtons;
    AddLetterButtons;
  end;
end;

procedure TAlphaPanel.SetCatchButtons;
begin
  if value = fCatchButtons then
    Exit;
  fCatchButtons := value;
  SetCatchStates;
end;

procedure TAlphaPanel.SetCatchStates;
var
  i : integer;
  aButton : tSpeedButton;
begin
  if firstButton <> NIL then
    firstButton.AllowAllUp := true;
  for i := 0 to ControlCount - 1 do
  begin
    aButton := NIL;
    if Controls[i] is tSpeedButton then
    begin
      aButton := tSpeedButton(Controls[i]);
      aButton.Down := false;
      if fCatchButtons then
        aButton.GroupIndex := 1
      else
        aButton.GroupIndex := 0;
    end;
  end;
  if firstButton <> NIL then
    if not fAllowAllUp then
      firstButton.AllowAllUp := false;
  if fActiveButton <> #0 then
  begin
    aButton := GetButton(fActiveButton);
    if aButton <> NIL then
      aButton.Down := fCatchButtons;
  end;
end;

{+--------------------------------------------------------------+}
{| Register the components                                      |}
{+--------------------------------------------------------------+}

procedure Register;
begin
  RegisterComponents('Beispiele', [TAlphaPanel]);
end;

end.
