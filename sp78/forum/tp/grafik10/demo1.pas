program demo1;
uses crt,graph,grafika;
var
 z:char;

{$F+}
function f(x:real):real;
begin
 f:=4*sin(x/5)+5;
end;
{$F-}

begin
 initgraphics;
 ShowFunction(0,100,f,'x','f(x)');
 Information(' Function y = 4*sin(x/5) + 5');
 z:=readkey;
 closegraph;
end.
