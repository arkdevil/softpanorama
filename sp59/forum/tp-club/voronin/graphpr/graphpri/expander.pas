      unit expander;
{
  ***************************************************************************
  *                                                                         *
  *                        Модуль    " EXPAND "                             *
  *                                                                         *
  *   Модуль содержит ряд функций для обработки видеоинформации и исполь-   *
  *   зуется для в результирующих программах GRAPHPR.                       *
  *                                                                         *
  *  procedure palitra(x1,y1,x2,y2,c:integer);   Цветовой сдвиг             *
  *  procedure fon(x1,y1,x2,y2,cf,c:integer);    Заливка цветом фона (кисть)*
  *  procedure chcol(x1,y1,x2,y2,i1,i2:integer); Замена цветов              *
  *  procedure orihor(x1,y1,x2,y2:integer);      Переворот по вертикали     *
  *  procedure oriver(x1,y1,x2,y2:integer);      Переворот по горизонтали   *
  *                                                                         *
  ***************************************************************************
}
interface
      uses dirgraph,foread,slaid,crt,graph,tpdos1;

  procedure palitra(x1,y1,x2,y2,c:integer);
  procedure fon(x1,y1,x2,y2,cf,c:integer);
  procedure chcol(x1,y1,x2,y2,i1,i2:integer);
  procedure orihor(x1,y1,x2,y2:integer);
  procedure oriver(x1,y1,x2,y2:integer);

implementation

{ цветовой сдвиг изображения }

procedure palitra(x1,y1,x2,y2,c:integer);
 var
   i,t,j,k:integer;
begin
    for i:=x1+1 to x2-1 do begin
      for j:=y1+1 to y2-1 do begin
       k:=getpixel(i,j);
       if k<>0 then begin
           k:=k-c;
           if k<0 then k:=k+15;
           if k>15 then k:=k-15;
       end;
       putpixel(i,j,k);
      end;
    end;
end;

{ залить поле фоновым цветом с сохранением одного из цветов }

procedure fon(x1,y1,x2,y2,cf,c:integer);
 var
   i,t,j,k:integer;
begin
    for i:=x1+1 to x2-1 do begin
      for j:=y1+1 to y2-1 do begin
       k:=getpixel(i,j);
       if k<>c then putpixel(i,j,cf);
      end;
    end;
end;

{ Изменить цвет }

procedure chcol(x1,y1,x2,y2,i1,i2:integer);
 var
   i,t,j,k:integer;
begin
    for i:=x1+1 to x2-1 do begin
      for j:=y1+1 to y2-1 do begin
       k:=getpixel(i,j);
       if k=i1 then putpixel(i,j,i2);
      end;
    end;
end;

{ Смена ориентации по горизонтали }

procedure orihor(x1,y1,x2,y2:integer);
 var
   i,t,j,k:integer;
   a:array[1..640] of integer;
label 1,2,10;
begin
    for i:=1 to 640 do a[i]:=0;
    for j:=y1+1 to y2-1 do begin
      for i:=x1+1 to x2-1 do a[i-x1]:=getpixel(i,j);
      for i:=x1+1 to x2-1 do putpixel(i,j,a[x2-i]);
    end;
end;

{ Смена ориентации по вертикали }

procedure oriver(x1,y1,x2,y2:integer);
 var
   i,t,j,k:integer;
   a:array[1..480] of integer;
begin
    for i:=1 to 480 do a[i]:=0;
    for i:=x1+1 to x2-1 do begin
      for j:=y1+1 to y2-1 do a[j-y1]:=getpixel(i,j);
      for j:=y1+1 to y2-1 do putpixel(i,j,a[y2-j]);
    end;
end;

end.
