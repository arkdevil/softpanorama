*FUNCTION	RestFile
PARAMETERS	fn,path
* Функция восстановления файлов базы данных по частям,
* сохраненным функцией SaveFile.
* Автоp: Тэаpо А.Р., дата последней коppектиpовки: 10/25/90 01:37pm
* Синтаксис: RestFile(FileName,Path)
* Возвращает количество восстановленных частей копии файла: 0,1...N
* Производит восстановление файла FileName по пути Path
* При отсутствии параметров FN вводится, Path предполагается
* как A: (с подтверждением и возможным изменением).
* Если файл Fn не найден на носителе Path, то файл ищется на
* том же носителе по частям с расширением: .{N}SubStr(Type,2,2),
* где {N} - цифра номера части файла. Старые версии файлов
* в текущем директории уничтожаются. Все найденные файлы частей
* копируются в активный директорий и об"единяются. Ведется контроль
* величины копируемых и об"единяемых файлов.

PRIVATE	nf,def,begstr,path,namef,typef,i,handler,size,old,un,fr,fnc
Private	ans,nc,np,Sel_Arr,oldp,nrf,buf1,buf2,Bak,next,p,fc,nr
Private SetCol,k,l,Base_Name,npl,LenBn

Set Escape on
*set echo off
*set talk off
*set step off
*set device to screen
*set color to 7/1

* Сохранение копии экрана
SAVE SCREEN TO RestFile

def=''
buf1=''
buf2=''
begstr='║ '			&& +space(9)
nrf=[Имя восстанавливаемого файла <.dbf>: ]

* Сохранение параметров цвета
SetCol=""
if (FILE("Color.Prg") .Or. FILE("Color.Fox")) .And. File("Color.Bin")	&& есть модули
	@ 13,35 Say [ ]
	SetCol=Color(35,13)
	Set Color To w/b
endif

k=13
l=30
do while(k>=10)
	@ k,l Clear To 27-k,79-l		&& чистка области вывода
	@ k,l To 27-k,79-l Double
	k=k-1
	l=l-10
	i=Inkey()
enddo

@ 10,32 SAY " [ RestFile ] "
@ 10,14 SAY ' '+DTOC(DATE())+' '
@ 10,64 SAY ' '+TIME()+' '

if TYPE("fn") <> 'C'			&& параметр не задан или не символьный
	@ 13,17 TO 16,63
	@ 14,19 SAY [Восстановление файлов базы данных по частям]
	@ 15,23 SAY [К Б  " И С Е Т Ь "  -  Тэаро  А.Р.]
	@ 10,14 SAY [ ]
    WAIT begstr+nrf TO ans
    KEYBOARD ans
else
    @ 11,2 SAY nrf+fn			&& выдать имя параметра
    ans=inkey(3)
endif

@ 13,16 Clear TO 16,63

sel_arr=CHR(ASC('A')+SELECT()-1)	&& текущая рабочая область
SELECT 0				&& выбор свободной области

* Ввод имени файла, если не задан
do   while(TYPE("fn") <> 'C' .Or. Len(Trim(Ltrim(Fn))) = 0)
     @ 11,2 Clear TO 11,78
     @ 10,7 SAY [ ]
     ACCEPT begstr+nrf TO fn
     fn=TRIM(LTRIM(fn))
     if LEN(fn) = 0 .OR. TYPE("fn") <> 'C'
	fn = .f.
	loop
     endif
enddo

fn=TRIM(LTRIM(fn))			&& удаляем ведущие и концевые пробелы

if .NOT. ('.' $ fn)			&& расширения нет => .dbf
    np=LEN(fn)+2			&& позиция точки + 1
    fn=fn+'.dbf'
else
    np=AT('.',fn)+1
    fn=fn+'   '
endif

BaseName=Fn			&& только имя файла базы данных

do while(At('\',BaseName)>0)
    BaseName=Right(BaseName,Len(BaseName)-at('\',BaseName))
enddo

npl=Len(Fn)-np				&& кол-во символов с конца до "." -1
LenBn=Len(BaseName)

SAVE Screen TO RestFl1			&& образ экрана для команды Dir
old=SYS(5)				&& старый диск по умолчанию

* Уничтожение существующего старого файла и его частей в активном директории
   Bak=.f.				&& .Bak-файл не создан
   if FILE(fn)				&& файл уже существует
	ans=' '
	do while(ans <> 'Y' .AND. ans <> 'N')
	    @ 12,2 Clear TO 13,78
	    @ 12,2 SAY [Файл ]+fn+" уже существует."
	    ON Escape ans='Esc'
	    WAIT begstr+"Уничтожить его или сохранить в Bak-файле [Y/N/Esc-Exit] ? " TO ans
	    ON Escape
	    ans=UPPER(ans)
	    if ans = 'ESC'		&& отказ
		SELECT &sel_arr
		if Len(SetCol)>1		&& параметр цвета не отсутствует
			Set Color To &SetCol
		endif
		RESTORE Screen FROM RestFile
		RETURN(0)
	    endif
	enddo
	@ 13,2 Clear To 13,78
	if ans='Y'
	    @ 13,2 SAY [Уничтожение старой копии файла ]+fn+[ ...]
	    ERASE &fn
	else
	    fc=STuff(fn,np,3,'Bak')
	    @ 13,2 Say [Переименование старой копии файла ]+fn+[ в .Bak-файл]
	    Rename &fn To &fc
	    Bak=.t.			&& создан .Bak-файл
	endif
	ans=InKey(2)
   endif

i=1
do while(i<10)
    fc=Trim(STuff(BaseName,LenBn-npl,1,Str(i,1)))
    if File(fc)				&& файл уже существует
	@ 13,2 Say [Уничтожение старой копии файла ]+fc+[ ...]
	Erase &fc
	ans=InKey(1)
    endif
   i=i+1
enddo

* Ввод - анализ маршрута.
     if TYPE("path") <> 'C' .Or. Len(Path) < 1		&& Если не задан => "A:"
	path='A:'
     endif

* Восстановление.
buf1=space(10)			&& флаги чтения файлов частей:0...N
buf2=space(60)			&& кол-во записей в файлах частей
next=.t.
@ 13,2 Clear TO 13,78
do while(next)
    @ 12,2 Clear TO 12,78
    @ 12,2 SAY [Маршрут восстановления :  ]+path+[ ]
    ans=InKey(0.5)
    @ 13,2 Clear TO 13,78
*    @ 11,1 SAY [ ]
*    WAIT begstr+"Маршрут восстановления [ "+path+" ]:" TO ans
*    @ 13,2 Clear TO 13,78
*    if LEN(ans) > 0			&& не -Enter-
*	KEYBOARD ans
*	@ 11,1 SAY [ ]
*	oldp=path
*	ACCEPT begstr+"Маршрут восстановления [ "+path+" ]:" TO path
*	if LEN(path) = 0
*	   path=oldp
*	endif
*    endif
    path=TRIM(LTRIM(path))		&& Удаление хвостовых и начальных пробелов
    if SUBSTR(path,LEN(path),1) = '\'
	path=SUBSTR(path,1,LEN(path)-1)	&& Удаление хвостового '\'
    endif
    if LEN(path) = 1
	path=path+':'
    endif

* Опознание входных устройств 'A:' или 'B:' (их может и не быть)
    un=IIF(SUBSTR(path,2,1) = ':', UPPER(SUBSTR(path,1,1)),'C')
    if un = 'A' .OR. un = 'B'
	ans=' '
	@ 12,1 SAY [ ]
	ON Escape p='E'
	WAIT begstr+[Установите ]+def+[дискету в ]+un+;
	     ": ... [D-Dir, Esc-конец восстан.] " TO p
	ON Escape
	if UPPER(p) = 'E'		&& отказ
	   exit
	endif
	do while(.T.)
	    fr=FlopRead(un)
	    if fr < 1
		@ 13,1 Say [ ]
		On Escape ans='E'
		if fr = -2
		    @ 14,2 Say [Модуль проверки дискетника "FlopRead.Bin" не найден.]
		    @ 15,2 Say [Проверка не осуществляется !]
		    i=InKey(5)		&& если нажали 'E'
		    On Escape
		    exit
		endif
		Wait BegStr+[Дискета в устройстве ]+un+ ": не готова ! [Esc-конец восстан.] "+Chr(7) To ans
		On Escape
		if Upper(ans) = 'E'	&& отказ
		    exit
		endif
	    else
		ans='*'			&& если нажали 'E'
		exit	    && выход из цикла опроса устройства по готовности
	    endif
	enddo
	if Upper(ans) = 'E'
	    exit
	endif
	if UPPER(p) = 'D'		&& Directory
	   Clear
*	   ans="*."+SUBSTR(fn,np,3)
*	   if ans = "*.dbf"
*	      ans=''
*	   endif
*	   ans=path+'\'+ans
*	   DIR &ans
	   p=path+'\*.*'
	   Dir &p
	   WAIT space(34)+"Далее ?"
	   RESTORE Screen FROM RestFl1
	   @ 10,64 SAY ' '+TIME()+' '
	   loop 			&& на повторный ввод маршрута
	endif
    endif

* Поиск и копирование в активный директорий файлов частей
    i=0
    k=0
    set default to &un
    do while(i<10)
	if(SUBSTR(buf1,i+1,1))=' '	&& не было копирования этой части
	    fc=IIF(i=0,BaseName,STUFF(BaseName,LenBn-npl,1,STR(i,1)))
	    fnc=path+'\'+fc
	    if FILE(fnc)		&& файл найден  по path
		@ 13,1 Clear TO 15,78
		@ 13,2 SAY [Копирование файла ]+fnc+[ в выходной директорий...]
		SELECT 0		&& свободная область
		USE &fnc
		k=k+1
		buf1=STUFF(buf1,i+1,1,STR(i,1))
		buf2=STUFF(buf2,i*6+1,6,STR(RECCOUNT(),6)) && кол-во записей части файла
		USE
		set default to &old
		COPY FILE &fnc TO &fc	&& в активный директорий
		ans=INKEY(3)		&& задержка на 3 секунды
		if i=0			&& копирование основного файла
		    next=.f.		&& копирование окончено
		    exit
		endif
		set default to &un
	    endif
	endif
	i=i+1
    enddo				&& конец найденных файлов дискеты
    set default to &old			&& диск умолчания
    if k=0				&& файлов не найдено
	@ 12,1 SAY [ ]
	on Escape ans='E'
	WAIT begstr+[По маршруту ]+path+[ файлов вида ]+;
	     STUFF(BaseName,LenBn-npl,1,'X')+" не найдено [Esc-конец восстан.] " TO ans
	ON Escape
	if UPPER(ans)='E'		&& отказ
	    exit
	endif
    endif
    def='другую '
    if .not. next && скопирован основной файл
    exit
    endif
enddo					&& конец копирования с дискет

* Слияние частей файлов в требуемый
nf=0					&& количество об"единенных частей файла
if next					&& основной файл еще не скопирован
    buf1=LTRIM(TRIM(buf1))		&& только флаги скопированных частей
    do while(LEN(buf1)>0)		&& есть еще флаги файлов ?
	i=SUBSTR(buf1,1,1)		&& номер очередного файла
	buf1=LTRIM(STUFF(buf1,1,1,''))	&& отметка выбора файла
	fc=STUFF(fn,np,1,i)
	if nf=0				&& первый файл
	    SELECT 0			&& свободная область
	    RENAME &fc TO &fn		&& переименовываем в искомый
	    USE &fn
	    @ 13,2 Clear TO 16,78
	    nr=RECCOUNT()		&& кол-во записей до слияния
	    if VAL(SUBSTR(buf2,VAL(i)*6+1,6))>nr
		@ 13,2 SAY [Ошибка при создании файла ]+fn+[ из файла ]+fc+CHR(7)
	    else
		@ 13,2 SAY [Файл ]+fn+[ создан из файла ]+fc
	    endif
	else
	    nr=RECCOUNT()
	    APPEND FROM &fc		&& добавление следующей части
	    if nr+VAL(SUBSTR(buf2,VAL(i)*6+1,6))>RECCOUNT()
					&& записей в файле меньше, чем д.б.
		? begstr+[Ошибка при добавлении файла ]+fc+[ в файл ]+fn
	    else
		? begstr+[Файл ]+fc+[ добавлен в файл ]+fn
	    endif
	    ERASE &fc			&& уничтожим добавленную часть
	endif
	nf=nf+1
    enddo
    USE					&& закрытие созданного файла
else
    i=1					&& уничтожение файлов частей при
    do while(i<10)			&& восстановлении основного файла
	if SUBSTR(buf1,i+1,1)<>' '	&& есть файл части
	    fc=STUFF(fn,np,1,STR(i,1))
	    ERASE &fc			&& кроме основного
	endif
    i=i+1
    enddo
endif

* Завершение работы
fc=STuff(fn,np,3,'Bak')			&& .Bak-файл
if .NOT. next .OR. nf>0
    if Bak				&& .Bak-файл создан
	Erase &fc
    endif
    on Escape ans='E'
    if nf=0
	WAIT begstr+[Файл ]+fn+[ восстановлен.]
	nf=1
    else
	WAIT begstr+[Файл ]+fn+[ восстановлен по]+STR(nf,2)+[ частям.]
    endif
    on Escape
else
    if Bak				&& есть .Bak-файл
	Rename &fc To &fn		&& переименование в старое имя
    endif
    on Escape ans='E'
    Wait BegStr+[Файл ]+fn+[ не восстановлен !]+Chr(7)
    on Escape
endif

SELECT &sel_arr
if Len(SetCol)>1		&& параметр цвета отсутствует
	Set Color To &SetCol
endif
RESTORE Screen FROM RestFile
RETURN(nf)