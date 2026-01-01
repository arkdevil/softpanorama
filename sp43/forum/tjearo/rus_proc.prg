*****************************************************************
*				Rus_Proc			*
*****************************************************************

Procedure RusTabl
*****************************************************************
* RusTabl - функция возвращает .T., если установлена основная	*
* таблица русских букв, иначе - .F. Если значение глобальной	*
* переменной Rus_tabl не определено функция предлагает сделать	*
* выбор и возвращает соответствующее значение, модифицирует	*
* глобальную переменную Rus_Tabl для дальнейшего использования,	*
* по Esc отмечает основную таблицу.				*
*		 КБ "ИСЕТЬ", Тэаро А.Р., 25.06.90, Ver. 1.0	*
*****************************************************************
Public	Rus_Tabl			&& тип таблицы русских букв: Osn, Alt

if Type("Rus_Tabl")<>'C' .Or.;
	(Upper(Rus_Tabl) <> "OSN" .And. Upper(Rus_Tabl) <> "ALT"))
	Save Screen to Rus_Tab_S
	@ 11,20 Clear to 14,59
	@ 11,20 To 14,59 Double
	@ 12,22 Say [Определите тип таблицы русских букв:]
	@ 13,25 Prompt [ Основная ]
	@ 13,40 Prompt [ Альтернативная ]
	Menu to Rt
	if(Rt = 0)			&& если нажали при выборе Esc => основная
		Rt=1
	endif
	Restore Screen From Rus_Tab_S
	if(Rt = 1)
		Rus_Tabl="OSN"
		Return(.T.)
	else
		Rus_Tabl="ALT"
		Return(.F.)
	endif
endif
if Upper(Rus_Tabl) = "OSN"		&& основная таблица
	Return(.T.)
else
	Return(.F.)
endif


Procedure RusUPper
*****************************************************************
* RusUPper - функция переводит строку-параметр из нижнего	*
* регистра на верхний, включая и русские буквы.			*
*			КБ "ИСЕТЬ", Тэаро А.Р. 25.06.90,Ver.1.2.*
*****************************************************************
Parameters Str

LenStr=Len(Str)

if LenStr=0				&& Null
	Return(Str)
endif

Rt=RusTabl()				&& .T. - основная таблица русских букв

i=0
do while i<LenStr			&& цикл по строке
	i=i+1
	Char=SubStr(Str,i,1)		&& символ

if (Char>='a' .And. Char<='z')
    Str=Stuff(Str,i,1,Chr(Asc(Char)-32)) && латинский верхний
    loop
endif

	if Char='ё'			&& буква Е краткая
		Str=Stuff(Str,i,1,Chr('Ё'))
	loop
	endif

    if Rt				&& осовная таблица
	if Char>='╨' .And. Char<='я'	&& русский нижний
		Str=Stuff(Str,i,1,Chr(Asc(Char)-32))	&& русский верхний
loop
	endif
     else				&& альтернатив.таблица
	if Char>='а' .And. Char<='п'
		Str=Stuff(Str,i,1,Chr(Asc(Char)-32))
loop
	endif
	if Char>='р' .And. Char<='я'
		Str=Stuff(Str,i,1,Chr(Asc(Char)-80))
loop
	endif
     endif
enddo

Return(Str)			&& возврат сформир.строки



Procedure RusLOwer
*****************************************************************
* RusLOwer - функция переводит строку-параметр с верхнего	*
* регистра на нижний, включая и русские буквы.			*
* КБ "ИСЕТЬ", Тэаро А.Р. 25.06.90, Ver. 1.2.			*
*****************************************************************
Parameters Str

LenStr=Len(Str)

if LenStr=0				&& Null
	Return(Str)
endif

Rt=RusTabl()				&& .T. - основная таблица русских букв

i=0
do while i<LenStr			&& цикл по строке
	i=i+1
	Char=SubStr(Str,i,1)		&& символ

if (Char>='A' .And. Char<='Z')
    Str=Stuff(Str,i,1,Chr(Asc(Char)+32)) && английский нижний
    loop
endif

	if Char='Ё'			&& буква Е краткая
		Str=Stuff(Str,i,1,Chr('ё'))
	loop
	endif

    if Rt				&& осовная таблица
	if Char>='░' .And. Char<='╧'	&& русский верхний
		Str=Stuff(Str,i,1,Chr(Asc(Char)+32))	&& русский нижний
loop
	endif
    else				&& альтернатив.таблица
	if Char>='А' .And. Char<='П'
		Str=Stuff(Str,i,1,Chr(Asc(Char)+32))
loop
	endif
	if Char>='Р' .And. Char<='Я'
		Str=Stuff(Str,i,1,Chr(Asc(Char)+80))
loop
	endif
    endif

enddo

Return(Str)			&& возврат сформир.строки



Procedure IsRusUPper
*****************************************************************
* Is_Rus_UPper - функция проверки на верхнюю букву первого	*
* символа строки-параметра.  При удачной проверке возвращает.T.,*
* иначе -.F. КБ "ИСЕТЬ", Тэаро А.Р. 25.06.90, Ver. 1.2.		*
*****************************************************************
Parameters Str

if Len(Str)=0				&& Null
	Return(.F.)
endif

Char=SubStr(Str,1,1)			&& 1-ый символ
if	(Char>='A' .And. Char<='Z') .Or. (Char>='А' .And. Char<='Я') .Or. Char='Ё'
			&& верхний английский и русский, Е краткое
	Return(.T.)
else
	Return(.F.)
endif


Procedure IsRusLOwer
*****************************************************************
* Is_Rus_LOwer - функция проверки на нижнюю букву первого	*
* символа строки-параметра. При удачной	проверке возвращает .T.,*
* иначе - .F.	КБ "ИСЕТЬ", Тэаро А.Р. 25.06.90, Ver. 1.2.	*
*****************************************************************
Parameters Str

if Len(Str)=0				&& Null
	Return(.F.)
endif

Rt=RusTabl()				&& .T. - основная таблица русских букв

Char=SubStr(Str,1,1)			&& 1-ый символ

if	  (Char>='a' .And. Char<='z') .Or. Char='ё'.Or. ( Rt .And. (Char>='╨' .And. Char<='я')).Or. (!Rt .And.((Char>='а' .And. Char<='п') .Or. (Char>='р' .And. Char<='я')))
		&& нижний английский и Е краткое, нижний русский основн.табл.
	Return(.T.)
endif
Return(.F.)				&& иначе - не буква на нижнем регистре




Procedure IsRussian
*****************************************************************
* Is_Russian - функция проверки на русскую букву всех символов	*
* строки-параметра. При удачной проверке возвращает .T.,	*
* иначе -.F. КБ "ИСЕТЬ", Тэаро А.Р. 25.06.90, Ver. 1.2.		*
*****************************************************************
Parameters Str

LenStr=Len(Str)

if LenStr=0				&& Null
	Return(.F.)
endif

Rt=RusTabl()				&& .T. - основная таблица русских букв

i=0
do while(i<LenStr)			&& цикл по строке
i=i+1
	Char=SubStr(Str,i,1)		&& i-ый символ
	if Char=' '.Or. ( Rt .And. (Char>='░' .And. Char<='ё')) .Or. (!Rt .And. (Char>='А' .And. Char<='ё'))
	&& пробел, русск.буквы основн.код.табл., русск.буквы альтерн.код.табл.
		loop			&& на следующий символ
	endif
	Return(.F.)			&& не пробел и не русская буква
enddo
Return(.T.)


Procedure IsRusAlpha
*****************************************************************
* Is_Rus_Alpha - функция проверки на русскую или английскую	*
* букву первого	символа строки-параметра. При удачной проверке	*
* возвращает .T.,иначе -.F. КБ"ИСЕТЬ",Тэаро А.Р. 25.06.90,V.1.2.*
*****************************************************************
Parameters Str

if Len(Str)=0				&& Null
	Return(.F.)
endif

Rt=RusTabl()				&& .T. - основная таблица русских букв

Char=SubStr(Str,1,1)			&& 1-ый символ
if (Char>='A' .And. Char<='Z') .Or. (Char>='a' .And. Char<='z') .Or. Char=' ' .Or. ( Rt .And. (Char>='░' .And. Char<='ё')) .Or. (!Rt .And. (Char>='А' .And. Char<='ё'))
		&& английская буква или пробел, русск.буквы основн.код.табл., русск.буквы альтерн.код.табл.
	Return(.T.)
else
	Return(.F.)			&& не пробел и не буква
endif
