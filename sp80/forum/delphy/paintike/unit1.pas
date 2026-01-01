unit Unit1;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls;

type
  TForm1 = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  protected
      function Hooker(var message: TMessage): Boolean; virtual; export;
      procedure CreateIcon;
      procedure PutOnAHappyFace(aCanvas: TCanvas; ARect: TRect);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  MyIcon: TIcon;

implementation

{$R *.DFM}

procedure TForm1.CreateIcon;
var
    andBmp, xorBmp: TBitmap;
    andBitmap, xorBitmap: WinTypes.TBitmap;
    andBits, xorBits: Pointer;
    andAlloc, xorAlloc: Integer;
    r: TRect;
begin
    try
        { Create the AND and XOR bitmaps.  The XOR bitmap is basically the
        part you want the user to see.  The AND bitmap is a monochrome
        mask that gives icons trasparency or inverse screen color.}
        andBmp := TBitmap.Create;
        andBmp.Monochrome := True;
        xorBmp := TBitmap.Create;
        andBmp.Width := GetSystemMetrics(SM_CXICON);
        xorBmp.Width := andBmp.Width;
        andBmp.Height := GetSystemMetrics(SM_CYICON);
        xorBmp.Height := andBmp.Height;
        r.Left := 0;
        r.Top := 0;
        r.Right := xorBmp.Width;
        r.Bottom := xorBmp.Height;

        with xorBmp.Canvas do
        begin
            Brush.Color := clBlack;
            FillRect(r);
        end;
        PutOnAHappyFace(xorBmp.Canvas, r);

        with andBmp.Canvas do
        begin
            Brush.Color := clWhite;
            FillRect(r);
            InflateRect(r, -1, -1);
            Brush.Color := clBlack;
            Ellipse(r.Left, r.Top, r.Right, r.Bottom);
        end;

        { There should be a cleaner way to do this in Delphi }
        GetObject(xorBmp.Handle, SizeOf(xorBitmap), @xorBitmap);
        GetObject(andBmp.Handle, SizeOf(andBitmap), @andBitmap);
        with xorBitmap do
            xorAlloc :=  bmPlanes * bmHeight * bmWidthBytes;
        with andBitmap do
            andAlloc := bmPlanes *bmHeight * bmWidthBytes;
        xorBits := AllocMem(xorAlloc);
        andBits := AllocMem(andAlloc);
        GetBitmapBits(xorBmp.Handle, xorAlloc, xorBits);
        GetBitmapBits(andBmp.Handle, andAlloc, andBits);

        MyIcon.Handle := Winprocs.CreateIcon(HInstance,
            xorBmp.Width, xorBmp.Height, xorBitmap.bmPlanes,
            xorBitmap.bmBitsPixel, andBits, xorBits);
    finally
        FreeMem(xorBits, xorAlloc);
        FreeMem(andBits, andAlloc);
        andBmp.Free;
        xorBmp.Free;
    end;
end;

procedure TForm1.PutOnAHappyFace(aCanvas: TCanvas; ARect: TRect);
var
    topOfSmile: Integer;
    r: TRect;
begin
    with aCanvas do
    begin
        r := ARect;
        { Draw the face }
        InflateRect(r, -1, -1);
        Brush.Color := clYellow;
        Ellipse(r.Left, r.Top, r.Right, r.Bottom);

        {Draw the smile }
        InflateRect(r, -6, -6);
        topOfSmile := r.Bottom - (r.Bottom - r.Top) div 3;
        Arc(r.Left, r.Top, r.Right, r.Bottom,
            r.Left, topOfSmile, r.Right, topOfSmile);

        {Draw the eyes }
        InflateRect(r, -1, -1);
        Brush.Color := clBlack;
        Ellipse(r.Left, r.Top, r.Left + 5, r.Top + 5);
        Ellipse(r.Right - 5, r.Top, r.Right, r.Top + 5);
    end;
end;

function TForm1.Hooker(var message: TMessage): Boolean;
var
    DC: HDC;
    ps: TPaintStruct;
    IconCanvas: TCanvas;
    r: TRect;
begin
    case message.Msg of
        WM_QUERYDRAGICON:
            begin
            if MyIcon.Empty then
                CreateIcon;
            message.Result := MyIcon.Handle;
            Result := True;
            end;

        WM_ERASEBKGND:
            Result := True;

        WM_PAINT:
            if (IsIconic(Application.Handle)) then
            try
                DC := BeginPaint(Application.Handle, ps);
                SendMessage(Application.Handle, WM_ICONERASEBKGND, DC, 0);
                IconCanvas := TCanvas.Create;
                IconCanvas.Handle := DC;
                r.Left := 0;
                r.Top := 0;
                r.Right := GetSystemMetrics(SM_CXICON);
                r.Bottom := GetSystemMetrics(SM_CYICON);
                PutOnAHappyFace(IconCanvas, r);
            finally
                IconCanvas.Free;
                EndPaint(Application.Handle, ps);
                Result := True;
            end;

        else {case Msg }
            Result := False
    end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
    Application.HookMainWindow(Hooker);
    MyIcon := TIcon.Create;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
    Application.UnhookMainWindow(Hooker);
    MyIcon.Free;
end;

end.
