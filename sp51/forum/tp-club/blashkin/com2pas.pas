{$A+,B-,D-,E-,F-,G+,I-,L-,N-,O-,R-,S-,V-,X+}
{$M 16384,0,0}
PROGRAM COM_TO_PAS;

{
   Программа для преобразования COM-файлов (или любых двоичных
   файлов размером до 64K) в типизированную константу PASCAL. 

   Обращение: COM2PAS двоичный_файл

   Создаваемый программой файл имеет имя исходного и расширение
   .PAS

   Автор: Блашкин И.И.
}


uses	dos;
const	header:string[200] = '{ -------------------------- File:  -------------------------- }'#13#10#13#10+
			     'const  _len = ;'#13#10+
			     'type    = array [0.._len] of byte;'#13#10+
			     'const  _code: = (';
	com_file:word = 0;
	file_len:word = 0;

var	file_name:string[72];
	fnlen:byte absolute file_name;
	d_str:string[64];
	n_str:string[8];
	e_str:string[4];
	count:word;


procedure	write_byte(var b:byte;cnd:boolean);
const	hexl:string[16] = '0123456789ABCDEF';
begin
	write(input,'$'+hexl[((b shr 4) and 15)+1]+hexl[(b and 15)+1]);
	if  cnd  then  writeln(input,');')
		 else  write(input,',');
end;

procedure	fail;far;
begin
	exitproc := nil;
	if  textrec(input).mode <> fmClosed  then  close(input);
	case  exitcode  of
		0:writeln(#13'Done.');
              254:writeln('Usage: COM2PAS binary_file_name');
	      255:writeln(#13'User break.');
	    else  writeln(#13'Aborted due to internal error no.',exitcode);
	end;
	halt(exitcode);
end;

begin
	exitproc := @fail;
	writeln('COM2PAS version 1.0, Copyright (C) by Blashkin I.I., 1992');
	if  paramcount = 1
	    then  file_name := fexpand(paramstr(1)) + #0
	    else  runerror(254);
	asm
		mov	ah,48h
		mov	bx,4096
		int	21h
		jc	@err
		mov	word ptr com_file,ax
		mov     ax,3D00h
		mov	dx,offset file_name[1]
		int	21h
		jc	@err
		mov	bx,ax
		mov	ax,word ptr com_file
		push	ds
		mov	ds,ax
		mov	ah,3Fh
		mov	cx,0FFFFh
		sub	dx,dx
		int	21h
		pop	ds
		jc	@err
		dec	ax
		mov	word ptr file_len,ax
		mov	ah,3Eh
		int	21h
		sub	ax,ax
	@err:	mov	word ptr exitcode,ax
	end;
	if  exitcode <> 0  then  runerror(hi(exitcode));
	dec(fnlen);
	fsplit(file_name,d_str,n_str,e_str);
	d_str := d_str + n_str + '.PAS';
	assign(input,d_str);
	asm
		mov	ah,48h
		mov	bx,$FFFF
		int	21h
		mov	ah,48h
		mov	word ptr textrec(input).bufsize,bx
		int	21h
		mov     word ptr exitcode,ax
	end;
	textrec(input).bufptr := ptr(exitcode,0);
	rewrite(input);
	if  inoutres <> 0  then  runerror(inoutres);
	writeln('Converting "',file_name,'" into "',d_str+'"');
	str(file_len,d_str);
	insert(n_str,header,135);
	insert(n_str,header,129);
	insert(n_str,header,106);
	insert(n_str,header,93);
	insert(d_str,header,83);
	insert(n_str,header,76);
	insert(n_str+e_str,header,35);
	write(input,header);
	exitcode := pos('(',header)-(pos('_code',header)-7-length(n_str))+1;
	fillchar(file_name[1],exitcode,32);
	fnlen := lo(exitcode);
	insert(#13#10,file_name,1);
	for  count := 0 to file_len  do
	     begin
		if  (count <> 0) and ((count mod 10) = 0)
		    then  write(input,file_name);
		write_byte(mem[com_file:count],count = file_len);
	     end;
	writeln(input,#13#10#9'{ --------------------- The End --------------------- }');
end.
