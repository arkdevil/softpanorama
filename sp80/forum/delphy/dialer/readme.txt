
Dialer is a small non visual component which allows you to dial phone
numbers from your Delphi applications. I am not a great expert in 
communications but it works fine for my modem. You can modify it as much
as you wish.

Dialer has four published properties, which will appear in you Object
Inspector.

ComPort      - Set a communication port of your modem (dpCom1..dpCom4);
Confirm      - true if you wish dialer to ask you if you are sure to dial 
               the number;
Method       - Dialing method - Pulse or Tone
NumberToDial - string, which contains Phone Number you wish to dial e.g. 
               '911' :)

You can set these properties from Object Inspector or during the run-time.

There is one public procedure: Execute

After you add an icon representing dialer (BTW it looks a bit ugly, but I am
a poor designer) you can use TButton component to run it. e.g.

procedure TForm1.Button1Click(Sender: TObject);
begin
  Dialer1.Execute;
end;

You can create the Dialer component "On Fly", without adding its icon to
your form:

procedure TForm1.Button1Click(Sender: TObject);
var
  TempDialer : TDialer;
begin
  TempDialer:=TDialer.Create(Self);
  with TempDialer do
  begin
    ComPort:=dpCom4;
    Confirm:=true;
    Method:=dmTone;
    NumberToDial:='1(222)333-4444';
    Execute;
    Free;
  end;
end;

in this case don't forget to add to your uses statement Dialer unit.

That's it. Have fun. Any comments and improvements (including ugly icon) are
welcome.

Regards

Archie

75231,330