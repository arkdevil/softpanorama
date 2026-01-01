program demo2;
uses crt,graph,grafika,mys;
var
 x,y:real;
 z:char;

{$F+}
function f(x:real):real;
begin
 f:=4*sin(x/5)+5;
end;
{$F-}

begin
 initgraphics;
 showmouse;
 Axes(-5,0,105,10,'x','f(x)');
 DrawFunction(0,100,f);
 Information(' Press any key to start and left mouse button to exit ! ');
 z:=readkey;
 Showmousepos(x,y);
 closegraph;
end.
