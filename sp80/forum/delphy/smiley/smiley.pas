{-------------------------------------------------}
{                                                 }
{    The TSmiley component is Copyright (c) 1995  }
{         by Nick Hodges All Rights Reserved      }
{                                                 }
{-------------------------------------------------}

unit Smiley;

{$R Smiley.res}

interface

uses  WinProcs, Classes, Graphics, Controls, StdCtrls, Messages, ExtCtrls;

procedure Register;

type
    TMood = (smHappy, smSad, smShades, smTongue, smIndifferent, smOoh);

const
     MoodString : array[tMood] of PChar = ('smHappy', 'smSad', 'smShades', 'smTongue', 'smIndifferent', 'smOoh');
     MaxHeight = 26;
     MaxWidth = 26;

type
  TSmiley = class(TImage)
  private
	{ Private declarations }
	Face         : TBitmap;
	FMood,
        OldMood      : TMood;
	procedure SetBitmap;
	procedure SetMood(NewMood: TMood);
        procedure WMSize (var Message: TWMSize); message wm_paint;
  public
	{ Public declarations }
        constructor Create(AOwner: TComponent); override;
        destructor Free; 
        procedure Toggle;
        procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
        procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  published
        property Mood: TMood read FMood write SetMood;
  end;


implementation

Uses Choose, DsgnIntf;

{-------------------------------------------------
                        TSmiley
--------------------------------------------------}

constructor TSmiley.Create(AOwner: TComponent);
begin
     inherited Create(AOwner);
     FMood := smHappy;
     Face := TBitmap.Create;  {Note dynamic allocation of the pointer}
     Face.Handle := LoadBitmap(hInstance, 'Happy'); {Old-fashioned API call}
     Self.Height := MaxHeight;
     Self.Width := MaxWidth;
     SetBitmap;
     OldMood := smHappy;
end; {Create}

destructor TSmiley.Free;
begin
     Face.Free; {Use Free rather than Destroy, as Free checks for a nil pointer first}
     inherited Free;
end; {Free}

procedure TSmiley.Toggle;
begin
     if fMood = smOoh then fMood := smHappy else Inc(fMood);  {Don't allow fMood to overflow}
     SetBitmap;
end; {Toggle}

procedure TSmiley.SetBitmap;
begin
     Face.Handle := LoadBitmap(hInstance, MoodString[fMood]);
     Self.Picture.Graphic := Face as TGraphic;  {Use RTTI to cast face as TGraphic, needed by TImage}
end; {SetBitmap}

procedure TSmiley.SetMood(NewMood: TMood);
begin
     FMood := NewMood;
     SetBitmap;
end; {SetMood}

{This method will respond to a mouse push on the Smiley by storing the
old face for later use and giving the "Sad" face.  Smileys don't like to get
clicked on!}
procedure TSmiley.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
     inherited MouseDown(Button, Shift, X, Y);
     OldMood := Mood;
     SetMood(smSad);
end; {MouseDown}

{This method restores the old face when the mouse comes back up}
procedure TSmiley.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
     inherited MouseUp(Button, Shift, X, Y);
     SetMood(OldMood);
end; {MouseUp}

{This method keeps the user from sizing the Smiley at design time.
You can use the 'csDesigning in ComponentState' to control what the
user can do at design time}
procedure TSmiley.WMSize(var Message: TWMSize);
begin
     inherited;
     if (csDesigning in ComponentState) then
     begin
          Width := MaxWidth;
          Height := MaxHeight;
     end;
end; {WMSize}

{------------------------------------}

procedure Register;
begin
  RegisterComponents('Custom', [TSmiley]);
  RegisterPropertyEditor( TypeInfo( TMood ), TSmiley, 'Mood', TMoodProperty );
end; {Register}

end.

