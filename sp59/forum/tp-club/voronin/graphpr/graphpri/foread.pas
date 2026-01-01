unit foread;
interface
{┌────────────────────────────────────────────────────────────────────────┐}
{│                         Модуль  FOREAD                                 │}
{│                                                                        │}
{│   Поскольку паскаль не обеспечивает ввод строки с клавиатуры при ра-   │}
{│   боте в графическом режиме ( т.е. обеспечивает, но "вслепую", не      │}
{│   высвечивая вводимых символов), пришлось сделать отдельный модуль,    │}
{│   содержащий единственную процедуру:  вводить текстовую переменную     │}
{│   из указанного места, с учетом цвета линии и фона.                    │}
{│                                                                        │}
{└────────────────────────────────────────────────────────────────────────┘}
uses crt,graph;
    procedure gread(var a:string);
     implementation
var a:string;
    b:integer;
    c:text;
    d:real;
procedure gread;
      var
        ch:char;
        x1,x,k,y,i:integer;
        funckey:boolean;
        w:fillsettingstype;
        cl:word;
      label
        10,20,190,90;
      begin;
         x1:=getx;
      a:='';
  10: ch:=readkey;
      if ch<>#0 then funckey:=false else
      begin
         funckey:=true;
         ch:=readkey;
      end;
      if ch=chr(13) then goto 20;
      if (ch=chr(75)) and (funckey=true) then begin ch:=chr(8); funckey:=false; end;
      if ch=chr(8) then goto 90;
      if ch=chr(27) then goto 190;
         a:=a+ch;
         outtext(ch);
         x:=getx;
         y:=gety;
         goto 10;
     90: getfillsettings(w);
         cl:=getcolor;
         setcolor(w.color);
         if x>x1 then x:=x-8;
         outtextxy(x,y,'█');
         setcolor(cl);
         moveto(x,y);
         i:=length(a);
         i:=i;
         delete(a,i,1);
         goto 10;
    190: i:=length(a);
         moveto(x1,y);
         getfillsettings(w);
         cl:=getcolor;
         setcolor(w.color);
         for k:=1 to i do outtext('█');
         setcolor(cl);
         moveto(x1,y);
         a:='';
         goto 10;
     20: end;
end.
