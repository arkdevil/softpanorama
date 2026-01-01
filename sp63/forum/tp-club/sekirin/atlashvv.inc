 {atlas IK spyektrov - chasth shapki i vv/vyv sp-rov}
 const npolosmax=25;
 type str2=string[2];
 type polosa=record ny:real; si:str2; intens:real end;
 type spyektr=record
  nazv:string[80]; npolos:integer; arr:array[1..npolosmax] of polosa
 end;

 var b:text;

 procedure wwo(var s:spyektr);
  var st:string[80]; st1,st2:string[10]; j,code,ii:integer;
 begin
  with s do begin
   readln(b,nazv);
   npolos:=0; repeat
    readln(b,st); if st<>'^$^' then begin
     j:=0; repeat j:=j+1 until ord(st[j])>=$40; {ishchem 1-yu bukvu}
     st1:=copy(st,1,j-1);
     st2:=copy(st,j,length(st)+1-j); if length(st2)=1 then st2:=st2+' ';
     st2:=copy(st2,1,2); {sryez.kommyentar.}
     npolos:=npolos+1; if npolos>npolosmax then begin
      write('wwo:nazv=',nazv,'; npolos>npolosmax.'); readln
     end;
     val(st1,arr[npolos].ny,code);
     if code<>0 then begin
      write('wwo:nye ponyato:nazv,st,st1= ',nazv,'/',st,'/',st1,'/'); readln
     end;
     arr[npolos].si:=st2;
     with arr[npolos] do begin
     if st2='vw' then intens:=0.01
      else if st2='w ' then intens:=sqrt(10)*0.01
      else if st2='m ' then intens:=0.1
      else if st2='s ' then intens:=sqrt(10)*0.1
      else if st2='vs' then intens:=1
      else begin
       write('wwo:nye ponyato:nazv,st,st2= ',nazv,'/',st,'/',st2,'/'); readln
      end;
     end {with arr[npolos]}
    end {if st<>'^$^'};
   until st='^$^';
  end {repeat};
 end;

 procedure wyw(s:spyektr); var i:integer;
 begin
  with s do begin
   writeln(nazv);
   write(' npolos=',npolos:4,'; ');
   for i:=1 to npolos do with arr[i] do write(ny:7:0,si,intens:5:2,'  ');
   writeln;
  end;
 end;
