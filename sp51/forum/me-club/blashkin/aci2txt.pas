{ 
  Преобразование файла из формата ACI HyperText в текстовый формат 

  Версия 1.0 от 05/10/92 09:04

  Автор: Блашкин И.И.

}
{$A+,B-,D-,E-,F-,G-,I+,L-,N-,O-,R-,S-,V-,X+}
{$M 16384,0,655360}
program ACI2TXT;

type    io_buffer = array [0..65000] of byte;
	TextRec   = record
			  Handle    :Word;
			  Mode      :Word;
			  BufSize   :Word;
			  Private   :Word;
			  BufPos    :Word;
			  BufEnd    :Word;
			  BufPtr    :Pointer;
			  OpenFunc  :Pointer;
			  InOutFunc :Pointer;
			  FlushFunc :Pointer;
			  CloseFunc :Pointer;
			  UserData  :array[1..16] of Byte;
			  Name      :array[0..79] of Char;
			  Buffer    :array [0..127] of Char;
		    end;


const	n_line:word = 1;
	fmClosed    = $D7B0;

var     np:byte;
	line:string;
	out_stream:text;
        in_buf,out_buf:^io_buffer;
	


procedure	error_handler;far;
begin
    exitproc := NIL;
    if  textrec(input).mode = $D7B1  then  close(input);
    if  textrec(out_stream).mode = $D7B2  then  close(out_stream);
    case  exitcode  of
	    0:writeln(#13'Преобразование ',n_line,' строк успешно завершено ...');
	  233:writeln('Преобразование файлов из формата ACI Hyper Text'#13#10+
		      'Командная строка : ACI2TXT aci_файл txt_файл');
          255:writeln(#13#10'Преобразование прервано по Ctrl-Break ...');
	else  writeln(#13#10'Аварийное завершение из-за ошибки #',exitcode:3);
    end;
    erroraddr := NIL;
    halt(exitcode);
end;


procedure	process_FF;

begin
	while (line[1] <> ' ') and (line <> '')  do  delete(line,1,1);
	if  line[1] = ' '  then  delete(line,1,1);
	writeln(out_stream,#13#10);
end;


function	search (substr,str:string):byte;
begin
	search := np + system.pos(substr,copy(str,np,length(str)-np+1)) - 1;
end;


procedure	process_power;

begin
  while  pos('^',line) <> 0  do
     begin
       np := pos('^',line);
       case  line[np+1] of
	  'A':delete(line,np,4);
	  'G':while  (line[np] <> '"') and (np <> length(line)) do  delete(line,np,1);
	  '^':begin
		delete(line,np,2);
		insert('',line,np);
	      end;
	  'C':begin
		delete(line,np,2);
		insert('ASCII ',line,np);
	      end;
	 else  delete(line,np,2);
       end;
     end;
end;


procedure	process_at;

begin
   while  pos('@',line) <> 0  do
      begin
	np := pos('@',line);
	if  line[np+1] = '@'
	    then  begin
		    delete(line,np,2);
                    insert('"@"',line,np);
		  end
	    else  begin
		    while  (pos('[!',line) <> 0)  do  delete(line,pos('[!',line)+1,1);
		    if  line[np+1] in ['<','>']
			then  insert('(Do cmd/macro '+copy(line,np+2,search('[',line)-np)+')',line,search(']',line)+1);
		    delete(line,np,search('[',line)-np+1);
		    delete(line,search(']',line),1);
		  end;
      end;
end;


begin
	exitproc := @error_handler;
        writeln('ACI2TXT version 1.0  Copyright (C) 1992  Блашкин И.И.');
	if  paramcount <> 2
	    then  runerror(233)
	    else  writeln('Преобразование файла '+paramstr(1)+' из ACI-формата в текстовый файл '+paramstr(2));
	assign(input,paramstr(1));
	new(in_buf);
	settextbuf(input,in_buf^,65000);
	reset(input);
	assign(out_stream,paramstr(2));
	new(out_buf);
	settextbuf(out_stream,out_buf^,65000);
	rewrite(out_stream);
	while  not eof(input)  do
	   begin
		readln(line);
		if line[1] = #12
		   then  process_FF
		   else  begin
			   if  pos('@',line) <> 0   then  process_at;
			   if  pos('^',line) <> 0   then  process_power;
                         end;
		writeln(out_stream,line);
		inc(n_line);
		if  (n_line mod 10) = 0  then  write(#13'Обрабатывается ',n_line:4,' строка');
	   end;
end.
