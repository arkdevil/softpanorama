program Ap_test;

uses
  Forms,
  Ap_testm in 'AP_TESTM.PAS' {Mainform};

{$R *.RES}

begin
  Application.Title := 'TAlphaPanel Demo';
  Application.CreateForm(TMainform, Mainform);
  Application.Run;
end.
