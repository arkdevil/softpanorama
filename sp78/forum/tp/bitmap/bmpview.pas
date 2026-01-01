program BMPviewer;

uses Bitmap, Dos, WinRes, Graph, Objects;

var
  index, count: integer;
  d, m: integer;
  Image: pointer;
  s: PStream;
  bmpfilename: string;
  Dir: DirStr;
  Name: NameStr;
  Ext: ExtStr;

begin
  WriteLn('Bitmap Viewer, Copr. 1995 Matthias Köppe');
  WriteLn;
  WriteLn('This is a demonstration program for handling Windows BMP files');
  WriteLn('in DOS by our <Windows Bitmap Resource for DOS> tool.');
  WriteLn;
  If ParamCount = 0
  then count := MaxInt
  else count := ParamCount;
  Index := 1;

  Repeat

    If Count = MaxInt
    then Begin
      Write('Bitmap file to be shown: ');
      Readln(bmpfilename);
      if bmpfilename = '' then break
    End
    else Begin
      bmpFileName := ParamStr(index);
      Inc(index)
    End;

    FSplit(bmpFileName, Dir, Name, Ext);
    If Ext = '' then Ext := '.BMP';
    bmpFileName := Dir + Name + Ext;
    bmpFileName := FSearch(bmpFileName, GetEnv('PATH'));
    If bmpfilename = ''
    then begin
      WriteLn('File not found...');
      Continue
    end;

    d := vga;
    m := vgahi;
    initgraph(d, m, '\bp\bgi');

    s := new(pdosstream, Init(bmpfilename, stOpenRead));
    Image := Loadbitmapfileimg(s^);
    Dispose(s, done);

    If Image <> nil then
    PutImage(0, 0, Image^, normalput);
{    FreeImage(Image);}

    Readln;
    CloseGraph

  Until Index > Count;

  WriteLn('Bitmap Viewer, Copr. 1995 Matthias Köppe');
  WriteLn;
  WriteLn('<Windows Bitmap Resource for DOS> is a programming tool available');
  WriteLn('for Borland Pascal, provided on shareware basis. Please register.');
  WriteLn('Read the documentation for more information.');
end.
