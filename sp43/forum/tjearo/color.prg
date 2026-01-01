*Procedure Color
*************************************************************************
* Color  - процедура определяет Set Color To установку для точки с коор-*
* динатами, заданными параметрами процедуры - числами X и Y. Возвращает *
* строку для команды Set. КБ "ИСЕТЬ", Тэаро А.Р. 28.06.90, Ver.1.0.	*
*************************************************************************

Parameters X,Y

Private Parm

if Type('X') <> 'N' .Or. Type('Y') <> 'N' .Or. X < 0 .Or. X > 79 .Or. Y < 0 .Or. Y > 24
    Return('E')			&& неверные параметры
endif

Parm=Chr(X+1)+Chr(Y+1)+space(7)	&& строка параметров для Ассемблера

Err=.f.				&& модуль загружен

on Error Err=.t.		&& если файл не загружен - отметить ошибку

Call Color With Parm		&& выполнили модуль на Ассемблере

if Err				&& была ошибка
    if File("Color.Bin")
	Err=.f.			&& сбросили ошибку
	Load Color		&& загрузка Bin файла
	Call Color With Parm
    else
	Err=.t.			&& установили ошибку - нет Bin-файла
    endif
endif

if Err	.Or. SubStr(Parm,1,1) = 'e'
	&& не удалось загрузить модуль, он не найден или неверные параметры
    Return('E')
endif

if SubStr(Parm,1,1) = '*'	&& короткая входная строка
    return('*')
endif

*? Asc(SubStr(Parm,1,1)),Asc(SubStr(Parm,2,1))
Return(Parm)
*Return(SubStr(Parm,1,1)+'/'+SubStr(Parm,2,1)+' '+SubStr(Parm,3,1)+'/'+SubStr(Parm,4,1))
				&& цвета по формату Foxbase+
