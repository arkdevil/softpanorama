program pslview;
uses crt,slaid,graph;
var
    funckey:boolean;
    grmode,grdriver:integer;
    errcode,xb,yb,i,x1,x2,x3,x4:integer;
    f:text;
     ch:char;
    s,s1:string;
procedure screen1;
begin;
assign(f,s);
reset(f);
readln(f,x1,x2,x3,x4);
close(f);
setcolor(10);
slideout(s,x1,x2,0,0);
end;
{
           MAIN
}
begin
   s:=paramstr(2);
   if s<>'' then begin
     getdir(0,s1); chdir(s); end;
   grdriver:=detect;
   initgraph(grdriver,grmode,'');
   if graphresult<>0 then begin
   writeln('Для просмотра файла необходимо наличие в текущем каталоге драйвера EGAVGA.BGI');
   halt; end;
   if s<>'' then chdir(s1);



   xb:=0; yb:=0;
   s:=paramstr(1);
   screen1;
   ch:=readkey;
   if ch<>#0 then funckey:=false else
   begin
      funckey:=true;
      ch:=readkey;
   end;
closegraph;
end.
