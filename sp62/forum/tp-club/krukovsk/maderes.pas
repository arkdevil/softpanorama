
{***************************************************}
{                                                   }
{        L e c a r                                  }
{   Turbo Pascal 6.X,7.X                            }
{   Попросту, без чинов и Copyright-ов  1991,92,93  }
{   Версия 2.0 от ...... (нужное дописать)          }
{***************************************************}

uses
  Objects, GViewer;

var
  S : PBufStream;
  Res : TResourceFile;
begin
  Picture := New(PPicture, Init(ParamStr(1)));
  S := New(PBufStream, Init('picture.res', stCreate, 2048));
  Res.Init(S);
  if Picture <> nil then Res.Put(Picture, 'PICTURE');
  Res.Done;
end.