{*******************************************************}
{                                                       }
{         Borland Delphi Unit                           }
{                                                       }
{         Copyright (c) 1995 OKO ROSNO                  }
{                                                       }
{*******************************************************}
{$D-,L-,S-}

unit CustReg;

interface

{ Register custom controls and gadgets }

uses Classes, DsgnIntf;

procedure Register;

implementation

uses Controls, SysUtils, FiltEdit, CustCtrl, Dice, Switch, VCLClock,
  ServEdit, Animate, ExtConst, HintProp;

{ Designer registration }

procedure Register;
begin
  RegisterComponents(GetExtStr(srGadgets), [TTextListBox, TComboEdit,
    TFilenameEdit, TDirectoryEdit, TDateEdit]);
  RegisterComponents(GetExtStr(srGadgets), [TShadowLabel, TClock,
    TSecretPanel, TColorComboBox, TAnimateImage, TSwitch, TDice]);
  RegisterPropertyEditor(TypeInfo(string), TFileNameEdit,
    'Filter', TFilterProperty);
  RegisterPropertyEditor(TypeInfo(string), TControl, 'Hint', THintProperty);
  RegisterPropertyEditor(TypeInfo(string), TCustomComboEdit, 'ButtonHint',
    THintProperty);
end;

end.
