unit Udemolan;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, WinLan, StdCtrls, Buttons;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    Button10: TButton;
    BitBtn1: TBitBtn;
    WinLan1: TWinLan;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.FormCreate(Sender: TObject);
begin
  Edit1.Text:=WinLan1.MachineName;
  Edit2.Text:=WinLan1.UserName;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  ShowMessage(WinLan1.FindMachine);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  WinLan1.ConnectDisk;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  WinLan1.DisConnectDisk;
end;

procedure TForm1.Button7Click(Sender: TObject);
begin
  ShowMessage(WinLan1.FindPrinter);
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  WinLan1.ConnectPrinter;
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  WinLan1.DisConnectPrinter;
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
  ShowMessage(WinLan1.FindDisk);
end;

procedure TForm1.Button8Click(Sender: TObject);
begin
  WinLan1.ChangePassword;
end;

procedure TForm1.Button9Click(Sender: TObject);
begin
  WinLan1.AutoLogon;
end;

procedure TForm1.Button10Click(Sender: TObject);
begin
  WinLan1.Logoff;
end;

end.
