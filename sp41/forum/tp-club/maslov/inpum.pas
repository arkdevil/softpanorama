{         Интегратор утилит INPUM ( Версия 1.0, 23.09.91 )                       }
{ АВТОР :      Маслов Владислав Васильевич                             }
{ АДРЕС :      141400, Химки-9 Московской обл., ул. Московская,        }
{           д. 21, ВНПОлеспром, лаб. патентования, Маслову В.В.        }
{ ТЕЛЕФОН :    572-70-03, доб. 7-02  ( с 9.00 до 18.00 )               }
{              или 571-82-54  ( с 21.00 до 23.00 ).                    }
{ СРЕДСТВА :   ТурбоПаскаль 5.0 + TurboProfessional 4.0                }
{                                                                      }
{ АННОТАЦИЯ     Интегратор предназначен для быстрого поиска утилиты,   }
{            получения по ней справки, запуска утилиты.                }
{               Все задействованные утилиты разделены по темам.        }
{               Информация о темах и утилитах расположена в файле      }
{            меню INPUM.MNU.                                           }
{               Стрелки управляют перемещением по меню.                }
{               TAB вызывает просмотр подробной документации на утилиту}
{               ENTER запускает утилиту.                               }
{               ESC прекращает работу интегратора.                     }
{               F1 вызывает помощь по интегратору (пока не реализована)}
{               Любой другой символ вводится в командную строку как    }
{            очередной символ параметра утилиты.                       }
PROGRAM INPUM;
uses TPCrt,TPString,TPEdit,Dos,TpDos;
label 5;

const
   c11=11;
   c12=12;
   c113=113;
   Att1=30;
   Att2=78;
   Att3=47;
   kstr=500;
   kmen=50;
   kraz=8;
zs = '                                                                              ';
s76 =
'                                                                            ';
s66 =
'                                                                 ';
var
   f, fop : text;
   NFOP : string[12] ;
   lw, nso1, j, n, n1, n1h, nw, ndm, yw, nwm : word;
   Cs,ch, ChH, cha, cc, chm : char;
   s,As,Comm,Coml,Naut : string[80];
   A,Spc : string[1];
   gv, SuR, Tmin, Tmax, Tk, sd : real;
   Rk,SuD : LongInt;
  Ret,Es : boolean;
  Covers : pointer;
   nd1,nd2,i1,i2,ii,Le,kin,colm,kot,ik,sdv, keg, nso,
   r1h,j1,j2,r,k,i, col, kk,jj,hc,ls: byte;
   nd,code : integer;
   Lv, Vs : Longint;
   MF : Array[1..kmen] of String[8];
   Ut : Array[1..kmen] of byte;
   Nmr : Array[1..kraz] of byte;
   Tsd : Array[0..kmen] of byte;
   Tx : Array[1..kstr] of String[64];

Procedure Avar(ast:string);
begin
  write(ast);
  Halt(code);
end;


PROCEDURE VERT;
   label 1;

Procedure Muc(n,col:byte);
      begin
        S:=MF[n+nd];
  if (col=30)and(Ut[n+nd]=2) then colm:=63
  else colm:=col;
        FastWrite(S,n+yw,3,colm);
      end;

Procedure Mus(n,col:byte);
begin
  ChangeAttribute(8,2,(n-1)*9+3,col);
end; {  }

Procedure INICOM;
begin
  for i:=i1 to i2 do
       FastWrite(S66,i+yw-i1+1,14,30);
  kin:=n1+nd;
  if Ut[kin]>0 then
  begin
  i1:=Tsd[kin-1]+1;
  i2:=Tsd[kin];
  for i:=i1 to i2 do
     begin
       S:=Tx[i];
       FastWrite(S,i+yw-i1+1,14,30);
     end;
  end
  else
     begin
       i1:=1;
       i2:=18;
     end;
  if Ut[kin]=1 then
     begin
  FastWrite(S76,23,3,47);
        As:=MF[kin];
        Le:=Search(As,9,Spc,1);
        Naut:=Copy(As,1,Le);
        Comm:=Trim(Naut)+' ';
  Le:=Length(Comm)+3;
  FastWrite(Comm,23,3,47);
  Normalcursor;
  GOTOxyABS(Le,23);
  end
  else
  begin
    HiddenCursor;
    FastWrite(S76,23,3,30);
  end;
end;

Procedure IniRAZ;
begin
  for k:=1 to nso1 do
       FastWrite('        ',k+yw,3,30);
  n1:=1;
  n:=1;
  nd1:=Nmr[r]-1;
  nd2:=Nmr[r+1]-1;
  nso1:=nd2-nd1;
  nd:=nd1;
  if nso1<nwm then nw:=nso1 else nw:=nwm ;
  for k:=1 to nso1 do
      begin
        S:=MF[k+nd];
        FastWrite(S,k+yw,3,30);
      end;
  Muc(1,78);
  INICOM;
end;


begin
   for r:=1 to j2 do
      begin
        k:=Nmr[r];
        S:=MF[k];
        FastWrite(S,2,(r-1)*9+3,Att1);
      end;
   i1:=1;
   i2:=18;
   nwm:=21-yw;
   if nso1<nwm then nw:=nso1 else nw:=nwm ;
   kk:=1;
   n1:=1;
   jj:=1;
   n1h:=1;
       Window(1,25,80,25);
       TextBackground(7);TextColor(0); ClrScr;
         sdv:=14;
         Write(' '+#27+' '+#26+' '+#25+' '+#24+' PgUp PgDn',' выбор ');
         Write(' Enter выполнение  Tab описание  Esc выход  F1 помощь');
       Fastwrite(' '+#27+' '+#26+' '+#25+' '+#24+' PgUp PgDn',25,1,116);
       Fastwrite('Enter',25,sdv+13,116);
       Fastwrite('Tab',25,sdv+31,116);
       Fastwrite('Esc',25,sdv+45,116);
       Fastwrite('F1',25,sdv+56,116);
  FrameWindow( 1,1,80,24,31,112,' ИНТЕГРАТОР УТИЛИТ 1.0 ' );
  FrameWindow( 13,yw,79,22,31,113,' СПРАВКА ' );
  FrameWindow( 2,yw,12,22,31,113,' УТИЛИТЫ ' );
        TextBackground(1); TextColor(14);
        Window(3,4,11,21);
        ClrScr;
   Mus(r1h,63); r:=r1h;
1:
   for n:=1 to nw do
      Muc(n,30);
   Muc(n1,78); n:=n1;
   INICOM;
      repeat
         Ch:=ReadKey;
         { Ввод параметров утилиты }
             if (Ch>=#32)and(Ut[n1+nd]=1) then
                begin
                  A:=Ch;
                  Comm:=Comm+A;
                  FastWrite(Comm,23,3,47);
                  Le:=Length(Comm)+3;
                  GOTOxyABS(Le,23);
                end;
         { Ввод BackSpace }
             if (Ch=#8)and(Ut[n1+nd]=1) then
                begin
                  Comm:=Copy(Comm,1,Length(Comm)-1);
                  FastWrite(S76,23,3,47);
                  FastWrite(Comm,23,3,47);
                  Le:=Length(Comm)+3;
                  GOTOxyABS(Le,23);
                end;
         { Запуск утилиты }
             if (Ch=#13)and(Ut[n1+nd]=1) then
                begin
                  Ret:=SaveWindow(1,1,80,25,True,Covers);
                  Window(1,1,80,25);
                  ClrScr;
                  Code:=ExecDos(Comm,True,Nil);
                  if Code<>0 then
                     Avar('Неверная утилита '+Comm);
                  Window(1,25,80,25);
                  write('Нажмите любую клавишу для возврата в интегратор...');
                  cc:=Readkey;
                  Window(3,4,11,21);
                  gotoxyabs(le,23);
                  if Ret then
                     RestoreWindow(1,1,80,25,False,Covers);
                end;
         { Вызов описания утилиты }
             if (Ch=#9)and(ut[n1+nd]=1) then
                begin
                  Ret:=SaveWindow(1,1,80,25,True,Covers);
                  Coml:='README '+Naut+'.DOC';
                  Code:=ExecDos(Coml,True,Nil);
                  if Code<>0 then
                     Avar('Нет описания утилиты: '+Coml);
                  gotoxyabs(le,23);
                  if Ret then
                     RestoreWindow(1,1,80,25,False,Covers);
                end;
             if Ch=#0 then
                begin
                   ch:=ReadKey;
                   if (ch=#72)and(n=1)
                     then ch:=#73;
                   if (ch=#80)and(n=nw)
                     then ch:=#81;
                   case ch of
           { F1 }     #59: ;
          { <- }   #75: begin
                          if r>j1 then r:=r-1
                          else r:=j2;
                          Mus(r1h,Att1);
                          Mus(r,63); r1h:=r;
                          INIRAZ;
                        end;
          { -> }   #77: begin
                          if r<j2 then r:=r+1
                          else r:=j1;
                          Mus(r1h,Att1);
                          Mus(r,63); r1h:=r;
                          INIRAZ;
                        end;
           { ^ }   #72: begin
                          n:=n-1;
                          Muc(n1,30);
                          Muc(n,78); n1:=n;
                          INICOM;
                        end;
           { V }   #80: begin
                          n:=n+1;
                          Muc(n1,30);
                          Muc(n,78); n1:=n;
                          INICOM;
                        end;
           { PgUp }   #73: if (nso1>nwm) then
                              begin
                                 nd:=nd-nw+1;
                                 if nd<nd1 then nd:=nd1;
                                 goto 1;
                              end;
           { PgDn }   #81: if (nso1>nwm) then
                              begin
                                 nd:=nd+nw-1;
                                 if nd>nd2 then nd:=nd2;
                                 goto 1;
                              end;
                      end;  { case }
                end;  { ch=#0 }
        until ch=#27; { ESC }
        kk:=n+nd;
        n1:=n;
   end;   { VERT }

{ Главная процедура }
begin { }
   Assign(f,'INPUM.MNU');
   Reset(f);
   Textbackground(1); TextColor(14); ClrScr;
   col:=30;
   Spc:=' ';
   k:=0; ii:=0; r:=0;
   while NOT Eof(f) do
      begin
        Readln(f,S);
        Cs:=S[1];
        if (Cs='`')or(Cs='=') then
          begin
            k:=k+1;
            S:=S+'        ';
            Ls:=Length(S);
            MF[k]:=copy(S,2,LS);
            Ls:=Length(Trim(S));
            Ut[k]:=0;
            if (Cs='`')and(LS>1) then Ut[k]:=1;
            if (Cs='=') then
               begin
                 r:=r+1;
                 Nmr[r]:=k;
                 Ut[k]:=2;
               end;
            Tsd[k-1]:=ii;
          end
        else
          if k>0 then
          begin
            ii:=ii+1;
            if ii<=kstr then Tx[ii]:=S;
          end;
      end; {while}
   Close(f);
   Tsd[k]:=ii;
   Nmr[r+1]:=k+1;
   j1:=1;
   j2:=r;
   r1h:=1;
   n1:=1;
   nd:=0;
  nd1:=Nmr[r1h]-1;
  nd2:=Nmr[r1h+1]-1;
   lw:=8;
   nso1:=nd2-nd1;
   kk:=1;
   jj:=1;
   yw:=3;
   VERT;
Window(1,1,80,25); ClrScr;
end. {  }
