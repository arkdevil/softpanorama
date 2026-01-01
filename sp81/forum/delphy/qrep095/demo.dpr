program Demo;

uses
  Forms,
  Main in 'MAIN.PAS' {TQuickReportDemo},
  Mdrep in 'MDREP.PAS' {MDForm},
  Simprep in 'SIMPREP.PAS' {SimpForm},
  Biorep in 'BIOREP.PAS' {Bioform},
  Demopre in 'DEMOPRE.PAS' {PrevForm};

{$R *.RES}
 var
 t : longint;
begin
  Application.CreateForm(TTQuickReportDemo, TQuickReportDemo);
  Application.CreateForm(TSimpForm, SimpForm);
  Application.CreateForm(TMDForm, MDForm);
  Application.CreateForm(TBioform, Bioform);
  Application.CreateForm(TPrevForm, PrevForm);
  t:=Memavail;
  Application.Run;
  t:=Memavail;
end.
