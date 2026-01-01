                              { BMPClass.PAS }
{ ///////////////////////////////////////////////////////////////////////// }
{         "Bitmap Window" class. The same as "STATIC" with SS_ICON          }
{  15-Nov-91 :         Konstantin E. Isakov  (C)1991.         : 25-Nov-91   }
{ ///////////////////////////////////////////////////////////////////////// }

unit BMPClass;     interface

uses
  WinTypes, WinProcs;

const
  ClassName = 'BitmapWnd';
  ClassStyle = cs_HRedraw + cs_VRedraw;


{ ///////////////////////////////////////////////////////////////////////// }

implementation

const
  WndClsExtra = sizeof (THandle);
  hBmpIdx = 0;


function WndProc (Wnd :HWnd; Msg, wParam :word; lParam :longint) :longint; export;

    procedure CreateBmp;
    var
      r :TRect; SrcDC, DstDC :HDC;
      bm :TBitmap;  hBmp, hSrcBmp, s1, s2 :HBitmap;
      Buf :array [0..80] of char;
    begin
      GetWindowText (Wnd, @Buf, 80);
      GetClientRect (Wnd, r);

      DstDC := GetDC (Wnd);
      hBmp := CreateCompatibleBitmap (DstDC, R.right, R.bottom);
      { assert (hBmp); }
      ReleaseDC (Wnd, DstDC);
      SetWindowWord (Wnd, hBmpIdx, hBmp);

      DstDC := CreateCompatibleDC (0);
      s1 := SelectObject (DstDC, hBmp);

      hSrcBmp := LoadBitmap (HInstance, Buf);
      if hSrcBmp = 0 then begin
        BitBlt (DstDC, 0,0, R.right, R.bottom, 0, 0,0, BLACKNESS);
        { WndProc := 1;  }                                     { ??????? }
        end
      else begin
        GetObject (hSrcBmp, sizeof (TBITMAP), @Bm);
        SrcDC := CreateCompatibleDC (0);
        s2 := SelectObject (SrcDC, hSrcBmp);
        StretchBlt (DstDC, 0,0, R.right, R.bottom,
                    SrcDC, 0,0, Bm.bmWidth, Bm.bmHeight, SRCCOPY);
        DeleteObject (SelectObject (SrcDC, s2));
        DeleteDC (SrcDC);
      end{if};

      SelectObject (DstDC, s1);
      DeleteDC (DstDC);
    end{CreateBmp};


    procedure wmCreate;
    begin
      SetWindowWord (Wnd, hBmpIdx, 0);
      {wmSize really create bitmap}
    end{wmCreate};


    procedure wmPaint;
    var  DC, MemDC  :HDC;      R   :TRECT;
         hBmp, sBmp :HBITMAP;  ps  :TPAINTSTRUCT;
    begin
      hBmp := GetWindowWord (Wnd, hBmpIdx);
      { assert (hBmp); }
      MemDC := CreateCompatibleDC (0);
      { assert (MemDC); }
      sBmp := SelectObject (MemDC, hBmp);
      GetClientRect (Wnd, R);
      DC := BeginPaint (Wnd, ps);
      BitBlt (DC, 0,0, R.right, R.bottom, MemDC, 0,0, SRCCOPY);
      EndPaint (Wnd, ps);
      SelectObject (MemDC, sBmp);
      DeleteDC (MemDC);
    end{wmPaint};


    procedure wmDestroy;
    var   hBmp :HBITMAP;
    begin
      hBmp := GetWindowWord (Wnd, hBmpIdx);
      if hBmp = 0 then exit;
      DeleteObject (hBmp);
      SetWindowWord (Wnd, hBmpIdx, 0);
    end{wmDestroy};


    procedure wmSize;
    begin
      wmDestroy;
      CreateBmp;
    end{wmSize};


begin{WndProc}
  WndProc := 0;
  case Msg of
    wm_Create:  wmCreate;
    wm_Size:    wmSize;
    wm_Paint:   wmPaint;
    wm_Destroy: wmDestroy;
  else
    WndProc := DefWindowProc (Wnd, Msg, wParam, lParam);
  end{case};
end{WndProc};

{ ///////////////////////////////////////////////////////////////////////// }

function  RegisterBMP :boolean;
var    wc :TWndClass;
begin
  if GetClassInfo (HInstance, ClassName, wc) then begin
    RegisterBMP := true; exit;
  end;
  wc.style          := ClassStyle;
  wc.lpfnWndProc    := @WndProc;
  wc.cbClsExtra     := 0;
  wc.cbWndExtra     := WndClsExtra;
  wc.hInstance      := HInstance;
  wc.hIcon          := 0;
  wc.hCursor        := LoadCursor (0, idc_Arrow);
  wc.hbrBackground  := 0;
  wc.lpszMenuName   := nil;
  wc.lpszClassName  := ClassName;
  RegisterBMP := boolean(RegisterClass (wc));
end{RegisterBMP};


begin
  if not RegisterBMP then Halt (255);
end{BMPClass}.

{ ///////////////////////////////////////////////////////////////////////// }
{                        End of file "BMPClass.PAS"                         }
{ ///////////////////////////////////////////////////////////////////////// }
