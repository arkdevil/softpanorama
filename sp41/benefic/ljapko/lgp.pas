(*  	
	▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
	▒▒		№ Copyright 1991 by George G.Lyapko		▒▒
	▒▒	Программа для упаковки файлов, отмеченных в NC v3.0	▒▒
	▒▒			LGP.PAS	v1.0				▒▒
	▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
    
    
     	Программа занимает место MCI.EXE (после запуска REPLMCI.COM) в списке 
внешних команд NC . Для упаковки файлов достаточно отметить их клавишей <Ins>
либо  "Серым" + , далее войти в  PullDn Menu , выбрать опцию "Files" и строку
"Pack files" ("Send files" в оригинальном NCMAIN.EXE), либо F9+F+P.

	Программа запросит имя архива (по умолчанию -  "(lgp).arj"  в текущем
каталоге) и упакует файлы одним из 5 архиваторов (в зависимости от указанного
расширения).

	Архиваторы должны быть доступны по PATH !!!

	Длина пути, из которого будут упаковываться файлы, не должна превышать
61 байта (без имени устройства и двоеточия), но это уже особенности NC.

	Размер программы в ОЗУ - 7.2 кБ

	Фрагменты программы, выделенные как примечания, можно использовать.
Если после процедуры Socha 

	archiver = 0 программа вызвана из "Options","send/Receive mail"
	archiver = 1 программа вызвана из "Options","commander maiL"
	archiver = 2 программа вызвана из "Files","Send files",
		     имена отмеченных файлов хранятся в lgp.att в виде
		     file1,file2,...,filenEOF

в buf1 хранится блок байт, который вставляется после нормальной командной
строки NCMAIN.EXE для своих утилит (здесь пока не все понятно, но, например,
WPVIEW явно его использует). Для обычных программ он не нужен.
               
	Можно еще раз "влезть" в NCMAIN.EXE и изменить сообщения 
(я, например, использую две разных оболочки и сообщения выглядят так:
	Offset 20DA3: Run SHEZ v6.2         вызов из NC -   F9,O,R
	Offset 20DB5: ARchiveHANdler        вызов из NC -   F9,O,A
	
	Естественно, кроме "исправления" NCMAIN.EXE необходимо изменить 
данную программу в соответствующих местах.)

Краткое описание процедур LGHANDLE.TPU:

	CutExeSize - высвобождает максимум пространства для DOS(используется 
	             функция DOS 4Ah);
	OpenFile   - открывает файл для чтения/записи;
	СloseFile  - закрывает файл;
	FileSize   - возвращает размер файла(не более 64кБ),
		     указатель - в конец файла;
	SeekToTopOfFile - перемещает указатель на начало файла;
	ReadFromFile    - считывает указанное количество байт в буфер
			  по указанному адресу;
	WriteToFile	- пишет указанное количество байт из буфера
			  по указанному адресу;
	ExistFile	- возвращает True, если файл существует
			  (работает только с полными именами файлов)

	В блоке вызова архиваторов оставлено несколько пустых байт в EXE-файле
(команды начинаются с Offset 20B) для возможности вставки опций архиватора 
(например -jm для ARJ) "по-живому". 
	Если у вас машина с 286 и выше процессором, компилируйте программу с 
ключом /$G+ (это уменьшит размер примерно на 300 байт)
                                                                            *)
{$D-,I-,L-,R-,S-,V-}

{$M 1024,0,655360}

uses Dos,Lghandle;

type	bufpointer	= ^buffertype;                      
	buffertype	= array [1..$A000] of char;

var	archivename,
	dataname,
	command		: PathStr;
	extension	: ExtStr absolute dataname;
	handle,
	archiver,
	i,
	datasize	: word;
	buffer		: bufpointer;
(*
	buf1	: array [0..14] of char;

procedure Socha;

var
	nc	: array [0..4] of char absolute buf1;	
	a	: byte;
	i	: word;

begin
	i := 1;
	while Mem[ PrefixSeg : $80+i ]<>0 do Inc(i);
	Move(Mem[ PrefixSeg : $80+i+1 ], buf1, 15);
	archiver := Mem[ PrefixSeg : $80+i+15 ];
	if (nc<>'Socha') then archiver:=2;
end;
*)

begin
(*
	Socha;
	case archiver of
	0:begin
		command:=Copy(ParamStr(0),1,length(ParamStr(0))-7)+'mci.exe';
		if ExistFile(command) then begin
			CutExeSize;
			Exec(GetEnv('COMSPEC'),'/c '+command+Chr(0)+buf1);
		end else Writeln(command,' not found')
	end;
	1:begin
		command:=Copy(ParamStr(0),1,length(ParamStr(0))-7)+'mci.exe';
		if ExistFile(command) then begin
			CutExeSize;
			Exec(GetEnv('COMSPEC'),'/c '+command+Chr(0)+buf1);
		end else Writeln(command,' not found')
	end;
	2:begin
*)
	Write(#10#13'NC selected files packing v1.0'#9#9#9,
	'November 1991,by George G.Lyapko'#10#13,
	'Input archive name (Default = (lgp).arj):');
	Readln(archivename);
	if archivename='' then	begin
		archivename:='(lgp).arj'; archiver:=1
	end else begin
		i:=Length(archivename); 
		while (i>0) and (archivename[i]<>'.') and
		(archivename[i]<>'\') do Dec(i);
		if (i=0) or (archivename[i]='\') then archiver:=1 else
		begin extension:=Copy(archivename,i,4);
			for i:=1 to length(extension) do 
				extension[i]:=UpCase(extension[i]);
			if extension='.ARJ' then archiver:=1 else
			if extension='.ZIP' then archiver:=2 else
			if extension='.LZH' then archiver:=3 else
			if extension='.PAK' then archiver:=4 else
			if extension='.ZOO' then archiver:=5 else begin
			Writeln('Invalid archive extension'); Halt(1) end;
		end;
	end;
	dataname:=Copy(ParamStr(0),1,length(Paramstr(0))-3)+'att';
	OpenFile(dataname,handle);
	datasize:=FileSize(handle);
	GetMem(buffer,datasize);
	SeekToTopOfFile(handle);
	ReadFromFile(handle,@buffer^,datasize);
	SeekToTopOfFile(handle);
	for i:=1 to datasize do if buffer^[i]=',' then buffer^[i]:=Chr($0a);
	WriteToFile(handle,@buffer^,datasize);
	CloseFile(handle);
	CutExeSize;
	command:=GetEnv('COMSPEC');
	case archiver of
	1:Exec(command,'/c arj a '+archivename+' !'+dataname);
	2:Exec(command,'/c pkzip '+archivename+' @'+dataname);
	3:Exec(command,'/c lha a '+archivename+' @'+dataname);
	4:Exec(command,'/c pak a '+archivename+' @'+dataname);
	5:Exec(command,'/c type '+dataname+'|'+'zoo aI '+archivename);
	end;
	EraseFile(dataname);
(*	end;
	end;
*)
end.
	