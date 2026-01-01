                                { tpBMP.PAS }
{ ///////////////////////////////////////////////////////////////////////// }
{                     Small Test for "BMPClass" module.                     }
{  15-Nov-91 :         Konstantin E. Isakov  (C)1991.         : 25-Nov-91   }
{ ///////////////////////////////////////////////////////////////////////// }

program tpBMP;                   {$R BMP}   { - Connect Resources 'BMP.res' }
                                            {        TEST_BITMAP            }
uses  WinTypes, WinProcs, BMPClass;         {        BMP_DIALOG             }

const
  DLG_TITLE = 100;                 { central text string in dialog template }

var
  Wnd  :HWND;
  Dlg  :HWND;
  Msg  :TMSG;
  ret  :boolean;
  OriginWnd :TFarProc;

{ ///////////////////////////////////////////////////////////////////////// }

function SubClassWndProc (Dlg :HWnd; Msg, wParam :word; lParam :longint) :longint; export;
begin
  if Msg = wm_Close then begin
    DestroyWindow (Wnd);
    DestroyWindow (Dlg);
  end;
  if Msg = wm_Destroy then begin
    PostQuitMessage (0);
  end;
  SubClassWndProc := CallWindowProc (OriginWnd, Dlg, Msg, wParam, lParam);
end{DlgWndProc};

{ ///////////////////////////////////////////////////////////////////////// }

begin {tpBMP}

  Wnd := CreateWindow ('BitmapWnd', 'TEST_BITMAP',
           ws_OverlappedWindow + ws_Visible,
           100, 20, 140, 200, 0, 0, HInstance, nil);

  Dlg := CreateDialog (HInstance, 'BMP_DIALOG', 0, nil);
  { assert (Dlg); }

  OriginWnd := TFarProc (SetWindowLong (Dlg, gwl_WndProc,
               longint (MakeProcInstance (@SubClassWndProc, HInstance)) ));

  SetWindowText (GetDlgItem (Dlg, DLG_Title), 'Windows Turbo Pascal');

  while GetMessage (Msg, 0, 0, 0) do begin
    TranslateMessage (Msg);
    DispatchMessage  (Msg);
  end;

end{tpBMP}.

{ ///////////////////////////////////////////////////////////////////////// }
{                         End of file "tpBMP.PAS"                           }
{ ///////////////////////////////////////////////////////////////////////// }
