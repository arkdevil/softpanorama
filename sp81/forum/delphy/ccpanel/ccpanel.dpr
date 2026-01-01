program Ccpanel;

uses
  Forms,
  Ccpantst in 'CCPANTST.PAS' {Form1};

{$R *.RES}

begin
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
