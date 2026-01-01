{***********************************************************************}
{ Тест - перемножение матриц   Павел Северов 1989                       }
{***********************************************************************}

{$R-,S+,I+,D+,T-,F-,V+,B-,N-,L+}
{$M 16384,0,655360 }

program TimeTest;

uses Dos;

const SizeMatr=40;M=40;N=40;L=40;

type MyReal=extended;

var A,B,C:array[1..SizeMatr,1..SizeMatr] of MyReal;
    S:MyReal;i,j,k:integer;StartTime,FinishTime:real;

function Time:real;
var H,M,S,S100:word;
begin
  GetTime(H,M,S,S100);
  Time:=(((((H*60)+M)*60)+S)*100+S100)/100;
end;


begin
  for i:=1 to M do for j:=1 to N do A[i,j]:=2.0/(i*j);
  for i:=1 to N do for j:=1 to L do B[i,j]:=2.0*i*j;
  StartTime:=Time;
  for k:=1 to M do for j:=1 to L do begin
    S:=0;
    for i:=1 to N do S:=S+A[k,i]*B[i,j];
    C[k,j]:=S end;
  FinishTime:=Time;
  for j:=1 to 4 do for k:=1 to 2 do writeln(C[k,j]:18:13);
  writeln('Время=',FinishTime-StartTime:5:2,' сек.');
end.


