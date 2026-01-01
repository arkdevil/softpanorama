type
  PNewStatusLine = ^TNewStatusLine;
  TNewStatusLine = object(TStatusLine)
   function Hint(AHelpCtx : Word) : String;virtual;
  end;
function TNewStatusLine.Hint(AHelpCtx : Word): String;
 begin
  case AHelpCtx of
   100: Hint := 'Show dialog demo';
   101: Hint := 'Show dialog Find';
   102: Hint := 'Exit program';
   103: Hint := 'Windows managment ';
   104: Hint := 'Move and size windows';
   105: Hint := 'Make next window current';
   106: Hint := 'Make previous window current';
   107: Hint := 'Close current window';
    else Hint := '';
  end;
end;
procedure TDemoApplication.InitStatusLine;
var
     R : TRect;
begin
    GetExtent(R);
    R.A.Y := R.B.Y-1;
     StatusLine := New(PNewStatusLine,Init(R, 
      NewStatusDef(0,99, 
      NewStatusKey('~F1~ Help',kbF1,cmHelp, 
      NewStatusKey('~Ctrl-F5~ Resize',kbCtrlF5,cmResize, 
      NewStatusKey('~F6~ Next',kbF6,cmNext, 
      NewStatusKey('~F10~ Menu',kbF10,cmMenu,nil)))),nil)));
end;
