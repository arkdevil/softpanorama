Parameters x,y,Text
***	Вывод текста со звуком печатающей машинки
Private	i,j,k
Beep=File('Fox_Beep.Bin')		&& звук.файл
if Beep
	Load 'Fox_Beep'
endif
if Beep
	j=1
	do while j<=Len(Text)
		if SubStr(Text,j,1) = ' '
			k=150
		else
			Call Fox_Beep
			k=50
		endif
		i=0
		do while i<k
			i=i+1
		enddo
		@ y,x+j-1 Say SubStr(Text,j,1)
		j=j+1
	enddo
	Call Fox_Beep with 'L'
	i=0
	do while i<350
		i=i+1
	enddo
else
	@ y,x Say Text
endif

Release Module Fox_Beep
Return
