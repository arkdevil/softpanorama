{$A+,B-,E+,F+,G-,I-,N-,O-,R-,S-,V+,X+}
{$M 16384,0,655360}
uses Crt,Dos,TpDate;
type
    tShowDate = (before,today,after);
const
    bShowDate : tShowDate = today;
    CR = #13+#10;
var
   wYear,
   wMonth,
   wDay,
   wDayOfWeek  : Word;
   wYearC,
   wMonthC,
   wDayC,
   wDayOfWeekC : Word;
   t           : Text;
   iCode       : Integer;
   wCntr,i     : word;
   sData,
   sPart,sMess : string;
   ch          : char;
   cDate,tDate : Date;
   wOutString  : Word;
   bPage       : Byte;
begin
   if (ParamCount>0)and(Pos('?',ParamStr(1))<>0) then begin
   writeln(CR+'V-Lab On-Boot Diary v.1.0. (C) Virtual Laboratory, 1993');
   writeln(CR+'Usage: MESSAGE [message_filename]');
   writeln('If not specificated message_filename program try to use file VL_DIARY.DAT');
   writeln('in current directory ');
   writeln(CR+'Every string in message file consist of:');
   writeln(CR+'*DD/MM/YYYY Example of message string');
   writeln(CR+'where *:  "=" show message if date equal ');
   writeln(   '          ">" show message after this date ');
   writeln(   '          "<" show message before this date ');
   writeln('Wildcard available: =XX/XX/XXXX for every day message');
   writeln('Example: message with =01/XX/XXXX will be shown every first day of month');
   halt(1);
   end;
   if ParamCount<1 then assign(t,'vl_diary.dat')
                   else assign(t,ParamStr(1));
   reset(t);
   sound(1000);delay(25);NoSound;
   sound(2000);delay(25);NoSound;
   sound(1000);delay(25);NoSound;
   sound(2000);delay(25);NoSound;
   sound(1000);delay(25);NoSound;
   clrscr; bPage:=1;
   writeln('V-Lab Diary:  Today ',TodayString('dd/mm/yy'),'        Page=',bPage:2);
   writeln;
   if IOResult<>0 then begin
     writeln('Can''t open message file');
     halt(1);
   end;
   GetDate(wYear,wMonth,wDay,wDayOfWeek);
   wCntr:=0; wOutString:=0;
   while not EOF(t) do begin
     readln(t,sData);
     Inc(wCntr);
     sPart:=sData[2]+sData[3];
     if upcase(sPart[1])='X' then wDayC:=wDay
     else begin
       val(sPart,wDayC,iCode);
       if iCode<>0 then writeln ('Error in day. String ', wCntr:5);
     end;
     sPart:=sData[5]+sData[6];
     if upcase(sPart[1])='X' then wMonthC:=wMonth
     else begin
       val(sPart,wMonthC,iCode);
       if iCode<>0 then writeln ('Error in month. String ', wCntr:5);
     end;
     sPart:=sData[8]+sData[9]+sData[10]+sData[11];
     if upcase(sPart[1])='X' then wYearC:=wYear
     else begin
       val(sPart,wYearC,iCode);
       if iCode<>0 then writeln ('Error in year. String ', wCntr:5);
     end;

     if sData[1]='=' then bShowDate:=Today;
     if sData[1]='>' then bShowDate:=After;
     if sData[1]='<' then bShowDate:=Before;

     sMess:=''; for i:=12 to length(sData) do sMess:=sMess+sData[i];
     if not ValidDate(wDayC,wMonthC,wYearC) then
            writeln ('Error in date. String ', wCntr:5);
     cDate:=DMYToDate(wDayC,wMonthC,wYearC);
     tDate:=DMYToDate(wDay,wMonth,wYear);
     if ((bShowDate=Today)and(tDate=cDate))or
        ((bShowDate=After)and(tDate>cDate))or
        ((bShowDate=Before)and(tDate<cDate))
        then begin
                writeln(DateToDateString('dd/mm/yy',cDate),' ',sMess);
                inc(wOutString);
                if wOutString>19 then begin
                   writeln(CR+'Press any key');
                   ch:=Readkey;
                   if KeyPressed then repeat ch:=ReadKey until not KeyPressed;
                   clrscr; inc(bPage);
                   writeln('V-Lab Diary:  Today ',TodayString('dd/mm/yy'),'        Page=',bPage:2);
                   writeln;
                   wOutString:=1;
                end;
     end;
   end;
   close(t);
   if wOutString=0 then begin
      writeln(CR);
      writeln ('Nothing to say today...')
   end
   else begin
   writeln(CR+'Press any key');
   ch:=Readkey;
   if KeyPressed then repeat ch:=ReadKey until not KeyPressed;
   end;
end.