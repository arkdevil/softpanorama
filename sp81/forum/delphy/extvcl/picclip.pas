unit PicClip;

interface

uses Classes, Controls, WinTypes, Graphics, ExtCtrls;

type

{ TPicClip }

  TPicClip = class(TImage)
  private
    FRows: Integer;
    FCols: Integer;
    FPicture: TBitmap;
    function GetCell(Index: Integer): TBitmap;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property GraphicCell[Index: Integer]: TBitmap read GetCell;
  published
    property AutoSize default True;
    property Rows: Integer read FRows write FRows;
    property Cols: Integer read FCols write FCols;
    property Visible default False;
  end;

procedure Register;

implementation

Uses ExtConst;

{ TPicClip }

constructor TPicClip.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FPicture := TBitmap.Create;
  Visible := False;
  AutoSize := True;
end;

destructor TPicClip.Destroy;
begin
  FPicture.Free;
  inherited Destroy;
end;

function TPicClip.GetCell(Index: Integer): TBitmap;
var
  BWidth, BHeight: Integer;
  SrcR, DestR: TRect;
begin
  BWidth := Picture.Width div FCols;
  BHeight := Picture.Height div FRows;
  DestR := Bounds(0, 0, BWidth, BHeight);
  SrcR := Bounds((Index mod Cols) * BWidth, (Index div Cols) * BHeight,
    BWidth, BHeight);
  with FPicture do begin
    Width := BWidth;
    Height := BHeight;
    {BitBlt(Canvas.Handle, DestR.Left, DestR.Top, BWidth, BHeight,
      Self.Canvas.Handle, SrcR.Left, SrcR.Top, SRCCOPY);}
    Canvas.CopyRect(DestR, Self.Canvas, SrcR);
  end;
  GetCell := FPicture;
end;

{ Designer registration }

procedure Register;
begin
  RegisterComponents(GetExtStr(srGadgets), [TPicClip]);
end;

end.