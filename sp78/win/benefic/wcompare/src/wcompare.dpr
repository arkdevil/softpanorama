program Wcompare;

uses
  Forms,
  Main in 'MAIN.PAS' {FrameForm},
  Child in 'CHILD.PAS' {EditForm},
  About in 'ABOUT.PAS' {AboutBox},
  Options in 'OPTIONS.PAS' {OptionsDlg};

{$R *.RES}

begin
  Application.Title := 'WCompare';
  Application.HelpFile := 'WCOMPARE.HLP';
  Application.CreateForm(TFrameForm, FrameForm);
  Application.CreateForm(TAboutBox, AboutBox);
  Application.CreateForm(TOptionsDlg, OptionsDlg);
  Application.Run;
end.
