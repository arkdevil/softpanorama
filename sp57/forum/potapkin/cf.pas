type
	header=record
		title:array [1..22] of char;
		name:array [1..8] of char;
		pass:array [1..5] of char;
	end;
const
	hh='Закодированный файл'#13#10#26;
var
	f1,f2:file;
	t:header;
	buf:array [1..5000] of word;
	p1,p2:array [1..5] of char;
	m:word;
	s:string;
	w:word;

function readkeyword:word; inline($b4/0/$cd/$16);

procedure getpass(mess:string; var p);
var
	pp:array [1..5] of byte absolute p;
	i,n:byte;
	ww:array [1..2] of byte absolute w;
begin
	write(mess);
	s:='';
	write('░░░░░░░░░░░░░░░░░░░░'#8#8#8#8#8#8#8#8#8#8#8#8#8#8#8#8#8#8#8#8);
	repeat
		m:=readkeyword;
		if m=$0E08 then
			if s<>'' then
			begin
				write(#8#176#8);
				delete(s,length(s)-1,2);
			end else
		else
		if (m<>$1C0D) and (length(s)<40) then
		begin
			s:=s+chr(lo(m))+chr(hi(m));
			write(#219);
		end;
	until m=$1C0D;
	fillchar(pp,5,0);
	w:=0;
	for i:=1 to length(s) do
	begin
		n:=ord(s[i]);
		pp[1]:=pp[1]+n;
		pp[2]:=pp[2]-n;
		pp[3]:=pp[3] xor n;
		pp[4]:=pp[4]+pp[1]+n;
		pp[5]:=pp[5]-pp[2]-n;
		ww[1]:=ww[1]+n;
		ww[2]:=ww[2] xor n;
	end;
	writeln;
end;

procedure help;
begin
	writeln(#13#10'Вызов : CF <вх_файл> <вых_файл>');
	halt;
end;

procedure code(mess:string);
var
	l,l1:longint;
	k,i:word;
begin
	l:=filepos(f1); l1:=filesize(f1);
	while not eof(f1) do
	begin
		blockread(f1,buf,10000,k);
		for i:=1 to k div 2 do buf[i]:=buf[i] xor w;
		blockwrite(f2,buf,k);
		inc(l,k);
		write(mess);
		write((l/l1)*100:6:1,'%'#13);
	end;
	writeln;
end;

procedure work;
begin
	reset(f1,1);
	rewrite(f2,1);
	blockread(f1,t,sizeof(t));
	if t.title<>hh then
	begin { Кодируем f1 в f2 }
		seek(f1,0);
		repeat
			getpass('Введите пароль : ',p1);
			getpass('И еще разок    : ',p2);
			if p1<>p2 then writeln('Ошибочка !');
		until p1=p2;
		t.title:=hh;
		t.name:='????????';
		move(p1,t.pass,5);
		blockwrite(f2,t,sizeof(t));
		code('Кодирование : ');
	end else
	begin
		getpass('Введите пароль : ',p1);
		if p1<>t.pass then writeln('Ошибочка !') else
		begin
			seek(f1,0);
			blockread(f1,t,sizeof(t));
			code('Раскодирование : ');
		end;
	end;
end;

begin
	writeln('File Coder V1.0 (C) SEEM Group, 1993'#13#10);
	if paramcount<>2 then help;
	assign(f1,paramstr(1));
	assign(f2,paramstr(2));
	work;
	close(f1);
	close(f2);
end.