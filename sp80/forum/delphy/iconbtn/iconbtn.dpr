program Iconbtn;

uses
  Forms,
  Iconbutn in 'ICONBUTN.PAS' {IconButtonDemo};

{$R *.RES}

begin
  Application.CreateForm(TIconButtonDemo, IconButtonDemo);
  Application.Run;
end.
