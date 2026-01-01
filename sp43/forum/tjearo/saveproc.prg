*FUNCTION	SAVEFILE
PARAMETERS	fn,path,usl
* Функция сохpанения файлов базы данных по частям.
* Автоp: Тэаpо А.Р., дата последней коppектиpовки: 10/25/90 12:47pm
* Синтаксис: SaveFile(FileName,Path,Usl)
* Возвращает количество созданных частей копии файла: 0,1...N
* Производит сохранение файла FileName по пути Path
* При отсутствии параметров FN вводится, Path предполагается
* как A: (с подтверждением и возможным изменением).
* Если файл не входит на носитель Path, то файл записывается
* по частям с расширением: .{N}SubStr(Type,2,2),
* где {N} - цифра номера части файла.

PRIVATE	nf,def,begstr,fn,path,i,handler,size,old,un,fr,fnc,ans,nc,np,nsf,nr
Private SetCol,k,l,Sel_Arr,Base_Name,npl,LenBn

set Escape on
*set echo off
*set talk off
*set step off
*set device to screen
*set color to 7/1

* Сохранение образа экрана
SAVE Screen TO SaveFile

nf=0
def=''
begstr='║ '				&& +space(9)
nsf=[Имя сохраняемого файла <.dbf>: ]

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

@ 10,32 SAY " [ SaveFile ] "
@ 10,14 SAY ' '+DTOC(DATE())+' '
@ 10,64 SAY ' '+TIME()+' '

if TYPE("fn") <> 'C'			&& параметр не задан или не символьный
	@ 13,20 TO 16,58
	@ 14,22 SAY [Запись файлов базы данных по частям]
	@ 15,22 SAY [К Б  " И С Е Т Ь "  -  Тэаро  А. Р.]
	@ 10,14 SAY [ ]
    WAIT begstr+nsf TO ans
    KEYBOARD ans
else
    @ 11,2 SAY nsf+fn			&& выдать имя параметра
    ans=inkey(3)
endif

@ 13,20 Clear TO 16,59

sel_arr=CHR(ASC('A')+SELECT()-1)	&& текущая рабочая область
SELECT 0				&& выбор свободной области

* Ввод имени файла, если не задан
do   while(.t.)
     if TYPE("fn") <> 'C'
	@ 11,2 Clear TO 11,78
	@ 10,7 SAY [ ]
	ACCEPT begstr+nsf TO fn
	fn=TRIM(LTRIM(fn))
	if LEN(fn) = 0 .OR. TYPE("fn") <> 'C'
	    fn = .f.
	    loop
	endif
     endif

     fn=TRIM(LTRIM(fn))			&& удаляем ведущие и концевые пробелы

     if .NOT. ('.' $ fn)		&& расширения нет => .dbf
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

	SAVE Screen TO Savefl1		&& область экрана для команды Dir

* Проверка существования файла в активном директории
    if .NOT. FILE(fn)
	@ 11,1 SAY [ ]
	ON Escape ans='E'
	WAIT begstr+CHR(7)+[Файл ]+TRIM(fn)+" не найден ... [Esc-Exit, D-Dir] ";
	     TO ans
	ON Escape
	if UPPER(ans) = 'E'		&& отказ
*	   Set Filter to		&& отказаться от условия
	   SELECT &sel_arr
	   if Len(SetCol)>1		&& параметр цвета не отсутствует
		  Set Color To &SetCol
	   endif
	   RESTORE Screen FROM SaveFile
	   RETURN(0)
	endif
	if UPPER(ans) = 'D'		&& Directory
	   Clear
	   ans="*."+SUBSTR(fn,np,3)
	   if ans = "*.dbf"
	      ans=''
	   endif
	   DIR &ans
	   WAIT space(34)+"Далее ?"
	   RESTORE Screen FROM SaveFl1
	   @ 10,64 SAY ' '+TIME()+' '
	endif
	@ 12,1 Clear TO 12,78
	fn=.f.				&& на повторный ввод имени файла
     else
	exit				&& файл найден
     endif
enddo

* Доступ к файлу, определение его размера и размера его заголовка.
USE &fn
* Количество атрибутов
handler=(FCOUNT()-1)*32+34
nr=RECCOUNT()
sizefile=handler+RECSIZE()*nr

* Условие копирования
if Type("&Usl") = 'L'			&& верный тип параметра
	Set Filter to &Usl
	Count For &Usl To nr
	Goto Top					&& вернуться на начало файла после пересчета
	sizefile=handler+RECSIZE()*nr
endif

* Ввод - анализ маршрута.
     if TYPE("path") <> 'C' .Or. Len(Path) < 1		&& Если не задан => "A:"
	path='A:'
     endif

* Запись.
do   while(sizefile > handler)
     @ 13,1 Clear TO 16,78
     if nf = 0
	@ 12,2 SAY [Размер файла: ]+LTRIM(STR(sizefile,7))+[ байт.]
     else
	@ 12,2 SAY [Осталось копировать: ]+LTRIM(STR(sizefile,7))+[ байт.]
     endif

* Ввод маршрута.
     @ 13,1 Clear TO 13,78
     @ 13,2 SAY [Маршрут сохранения :  ]+path+[ ]
*     @ 12,1 SAY [ ]
*     old=path
*     ACCEPT begstr+"Маршрут сохранения [ "+path+" ]:" TO path
*     if LEN(path) = 0
*	path=old
*     endif

     path=TRIM(LTRIM(path))		&& Удаление хвостовых пробелов
     if SUBSTR(path,LEN(path),1) = '\'
	path=SUBSTR(path,1,LEN(path)-1)	&& Удаление хвостового '\'
     endif
     if LEN(path) = 1
	path=path+':'
     endif

* Опознание выходных устройств 'A:' или 'B:' (их может и не быть)
     un=IIF(SUBSTR(path,2,1) = ':', UPPER(SUBSTR(path,1,1)),'C')
     if un = 'A' .OR. un = 'B'
	@ 13,1 SAY [ ]
	ON Escape ans='E'
	WAIT begstr+[Установите ]+def+[дискету в ]+un+": ... [Esc-Exit] " TO ans
	ON Escape
	if UPPER(ans) = 'E'		&& отказ
	   exit
	endif
	do while(.T.)
	    fr=FlopRead(un)
	    if fr < 1
		@ 13,8 Say [ ]
		On Escape ans='E'
		if fr = -2
		    @ 14,2 Say [Модуль проверки дискетника "FlopRead.Bin" не найден.]
		    @ 15,2 Say [Проверка не осуществляется !]
		    ans=InKey(5)+' * '	&& если нажали 'E'
		    On Escape
		    exit
		endif
		Wait BegStr+[Дискета в устройстве ]+un+ ": не готова ! [Esc-Exit] "+Chr(7) To ans
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
     endif

* Диск для копирования
     old=SYS(5)				&& старый диск по умолчанию
     set default to &un

* Проверка наличия и уничтожение старых копий файла
     i=0
     ans=' '
     do while(i<nf+2)
	fc=IIF(i=0,BaseName,STUFF(BaseName,LenBn-npl,1,STR(nf+1,1)))
	fnc=path+'\'+fc
	if FILE(fnc)			&& найдена старая копия файла
	   @ 14,1 Clear TO 14,78
	   @ 14,2 SAY [По маршруту ]+path+[ имеется файл ]+fc
	   ans=' '
	   do while(ans <> 'Y' .AND. ans <> 'N' .AND. ans <> 'E')
		@ 15,1 Clear TO 15,78
		@ 14,1 SAY [ ]
		ON Escape ans='E'
		WAIT begstr+"Уничтожить его (Y/N) [Esc-Exit] ? " TO ans
		ON Escape
		ans=UPPER(ans)
	   enddo
	   if ans = 'N' .OR. ans = 'E'	&& отказ
	        set default to &old	&& старый диск
		exit
	   endif
	   @ 15,2 SAY [Уничтожение старой копии файла ]+fnc+[ ...]
	   ERASE &fnc			&& стирание старой копии файла
	endif
	i=i+1
     enddo
     if ans = 'E'			&& выход
	exit
     endif
     if ans = 'N'			&& другой маршрут
	def='другую '
	loop
     endif

* Свободное место на диске.
     fr=DISKSPACE()
     set default to &old		&& старый диск
     @ 14,1 Clear TO 14,78
     @ 14,2 SAY [По маршруту ]+path+[ свободно ]+LTRIM(STR(fr,7))+[ байт.]
     if(fr < handler + RECSIZE())	&& диск заполнен или мало места
	ON Escape ans='E'
	WAIT begstr+CHR(7)+[а диске ]+un+;
	     " мало свободного места ... [Esc-Exit] " TO ans
	ON Escape
	def='другую '
	if UPPER(ans) = 'E'		&& отказ
	   exit
	endif
	loop
     endif

* Имя выходного файла: если мал - сохраняем, иначе - в тип добавляем номер.
     fc=IIF(nf = 0 .AND. sizefile <= fr,BaseName,STUFF(BaseName,LenBn-npl,1,STR(nf+1,1)))
     fnc=path+'\'+fc
     ans=' '
     do   while(ans <> 'Y' .AND. ans <> 'N' .AND. ans <> 'E')
	@ 15,1 Clear TO 16,78
	@ 14,1 SAY [ ]
	ON Escape ans='E'
	WAIT begstr+[Копируем файл: ]+Trim(fn)+[ по маршруту ]+Trim(fnc)+;
		" [Esc-Exit] ? " TO ans
	ON Escape
	if LEN(ans) = 0
	   ans='Y'
	endif
	ans=UPPER(ans)
     enddo
     if ans = 'E'
	exit
     endif
     def='другую '
     if ans = 'N'		&& отказ от копирования => след.маршрут
	loop
     endif

* Копирование.
     nc=INT((fr-handler)/RECSIZE())	&& количество войдущих по PATH записей
     if nc > nr
	nc=nr				&& копиpуем количество имеющихся записей
     endif
	 @ 15,1 Clear To 15,78
     @ 15,2 SAY [Копирование ]+LTRIM(STR(nc,6))+[ записей файла ]+Trim(fn)+;
	' в '+Trim(fnc)+[ ...]
     COPY NEXT nc TO &fnc
     if RECNO() < nr			&& не последняя запись
	GOTO RECNO()+1			&& первая не скопированная запись
     endif
     @ 16,0 SAY begstr

* Оставшийся размер файла.
     sizefile=sizefile-nc*RECSIZE()
     nf=nf+1
enddo					&& копирование следующей части файла

* Конец копирования.
if nf > 0				&& было копиpование
   @ 11,1 Clear TO 16,78		&& чистка области вывода

   On Escape ans='E'
   if nf = 1
	@ 12,1 SAY [ ]
	WAIT begstr+[Копирование файла ]+Trim(fn)+' в '+Trim(fnc)+[ окончено.]
   else
	@ 13,2 SAY [Копирование файла ]+Trim(fn)+[ по]+STR(nf,2)+[ частям окончено.]
	@ 13,1 SAY [ ]
	WAIT begstr+[Для его восстановления используйте RestFile().]
   endif
   On Escape
endif
Set Filter to		&& отказаться от условия
USE					&& закрытие файла
ON Escape
SELECT	&sel_arr
if Len(SetCol)>1		&& параметр цвета отсутствует
	Set Color To &SetCol
endif
RESTORE Screen FROM SaveFile
RETURN(nf)