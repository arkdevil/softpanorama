unit ExtForms;

interface

uses Forms;

type
  TProfileForm = class(TForm)
    procedure Loaded; override;
    destructor Destroy; override;
  end;

implementation

uses
  AppUtils;

procedure TProfileForm.Loaded;
begin
  inherited Loaded;
  try
    RestoreFormPlacement(Self);
  except
  end;
end;

destructor TProfileForm.Destroy;
begin
  try
    SaveFormPlacement(Self);
  except
  end;
  inherited Destroy;
end;

end.
