{ Unit Bitmap Demonstration

  Pre-release, no support, no warranty

  Copr. 1994 Matthias Köppe
}


uses Objects, WinRes, Graph, Bitmap;

var
  i, d, m: Integer;

procedure LoadImage(Path: string; Atx, Aty: Integer; User: Boolean);
var
  s: PStream;
  Bit: PBitmap;
  Image: pointer;
Begin
  s := new(pdosstream, Init(Path, stOpenRead));
  bit := loadbitmapfile(s^);
  dispose(s, done);
  If Bit = nil then Exit;
  If User
  then Image := BitmapToImageWithUserPalette(Bit, nil)
  else Image := BitmapToImage(Bit);
  DeleteBitmap(Bit);
  PutImage(Atx, Aty, Image^, normalput);
End;

Begin
  d:=vga; m:=vgahi;
  initgraph(d,m,'c:\bp\bgi');

  Color := 8 + 4;
  BkColor :=      4 + 1;

  with ColorWeights do Begin
    rgbtBlue := 1;
    rgbtGreen := 1;
    rgbtRed := 1
  End;

  { Show images
  }
  LoadImage('c:\windows\blaetter.bmp', 0, 0, true);

  readln;
  closegraph
end.
