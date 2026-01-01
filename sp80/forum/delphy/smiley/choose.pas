unit Choose;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Buttons, ExtCtrls, StdCtrls, Smiley, DsgnIntF, TypInfo;

type
  TChooseDlg = class(TForm)
    BitBtn1: TBitBtn;
    Panel1: TPanel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    SpeedButton6: TSpeedButton;
    procedure SpeedButton1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FMood      : TMood;
    procedure SetMood(NewMood: TMood);
  public
    { Public declarations }
    property Mood: TMood read FMood write SetMood;
  end;

  TMoodProperty = class( TEnumProperty )
       function GetAttributes: TPropertyAttributes; override;
       procedure Edit; override;
  end;

var
  ChooseDlg: TChooseDlg;

implementation

{$R *.DFM}

procedure TChooseDlg.SpeedButton1Click(Sender: TObject);
begin
     FMood := TMood((Sender as TSpeedButton).Tag);
end; {SpeedButton1Click}

procedure TChooseDlg.FormCreate(Sender: TObject);
begin
     SpeedButton1.Down := True;
end; {FormCreate}

procedure TChooseDlg.SetMood(NewMood: TMood);
var
   Counter: Integer;
begin
     FMood := NewMood;
     for Counter := 0 to ComponentCount - 1 do
     begin
          if (Components[Counter] is TSpeedButton) then
          begin
               if TSpeedButton(Components[Counter]).Tag = Ord(NewMood) then
                  TSpeedButton(Components[Counter]).Down := True; 
          end;
     end;
end;  {SetMood}

{---------Property Editor Stuff--------------}

function TMoodProperty.GetAttributes: TPropertyAttributes;
begin
	Result := [paDialog];
end;  {GetAttributes}

procedure TMoodProperty.Edit;
var
   ChooseDlg: TChooseDlg;
begin
     ChooseDlg := TChooseDlg.Create(Application);
     try
        ChooseDlg.Mood := TMood(GetOrdValue);
        ChooseDlg.ShowModal;
        SetOrdValue(Ord(ChooseDlg.Mood))
     finally
        ChooseDlg.Free
     end;
end; {Edit}

end.
