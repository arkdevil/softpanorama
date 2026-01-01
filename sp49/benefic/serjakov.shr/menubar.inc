procedure TDemoApplication.InitMenuBar;
var
     R : TRect;
begin
    GetExtent(R);
    R.B.Y := R.A.Y+1;
     MenuBar := New(PMenuBar,Init(R,NewMenu( 
      NewSubMenu('~D~emo',100,NewMenu( 
      NewItem('~O~pen Find dialog','',kbNoKey,100,101, 
      NewItem('~E~xit','Alt-X',kbAltX,cmQuit,102,nil))), 
      NewSubMenu('~W~indows',103,NewMenu( 
      NewItem('~R~esize','Ctrl-F5',kbCtrlF5,cmResize,104, 
      NewItem('~N~ext','F6',kbF6,cmNext,105, 
      NewItem('~P~revious','Shift-F6',kbShiftF6,cmPrev,106, 
      NewItem('~C~lose','Alt-F3',kbAltF3,cmClose,107,nil))))),nil)))));
end;
