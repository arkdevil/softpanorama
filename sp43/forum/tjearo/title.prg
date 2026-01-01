* Определяем параметры подпрограммы вывода заставки
Dimension TDim(8)
Name1="Создание и ведение"
Name2="КЛАССИФИКАТОРА HОРМАЛИЗОВАHHОГО ИHСТРУМЕHТА"
TDim(1)="██    ███  ██     ██  ██      ███"
TDim(2)="██   ██    ██     ██  ██     ████"
TDim(3)="██  ██     ██     ██  ██    ██ ██"
TDim(4)="█████      █████████  ██   ██  ██"
TDim(5)="█████      ██     ██  ██  ██   ██"
TDim(6)="██  ██     ██     ██  ██ ██    ██"
TDim(7)="██   ██    ██     ██  ████     ██"
TDim(8)="██    ███  ██     ██  ███      ██"
CopyRight='По всем вопросам обращаться в XXX "XXXXX" к Xxxxx X.X.: т.р. xx-xx-xx, т.д. xx-xx-xx, 620000, г.Xxxxxxxxxx, ул.Xxxxxxxxxx, x. '
Set Echo Off
Set Talk Off
Set Status Off
Set Score Off
Set Procedure to Title
do TPlay with Name1,Name2,CopyRight
Set Procedure to
Return

************************************
* Программа вывода заставки:       *
* 0 - исчерпание времени ожидания, *
* иначе - код нажатой клавиши      *
************************************
Procedure TPlay
Parameters n1,n2,cr

if Len(cr)<80
	cr=cr+Space(80-Len(cr))
endif
LenCr=Len(cr)
nDim=39-Len(TDim(1))/2
Set Color To 7/1
@ 0,0,24,79 Box[░░░░░░░░░]
@ 1,2 to 19,76
if Len(n1)>0
	@ 3,39-Len(n1)/2 say n1
endif
if Len(n2)>0
	@ 5,39-Len(n2)/2 say n2
endif
*if Len(n2)>0
*	@ 8,40 say "и"
*endif
*@ 9,39-Len(n2)/2 say n2
i=1
do while(i<9)
	@ 6+i,nDim Say TDim(i)
i=i+1
enddo
@ 16,05 say "Для продолжения  нажмите любую  клавишу"
@ 16,55 say "Сегодня: "+dtoc(date())
@ 17,05 say "Для выхода нажмите ESC или ждите 3 мин."
TimeBeg=Time()
@ 17,55 say "Сейчас : "+TimeBeg
Save Screen To Title
NBeg=(Val(SubStr(TimeBeg,1,2))*60+Val(SubStr(TimeBeg,4,2)))*60+Val(SubStr(TimeBeg,7,2))
@ 21,0 Say SubStr(cr,1,80)
ich=1
iwork=1
icol=0
rc=0

Set Escape Off
do while(rc=0)
	rc=InKey(0.055)
	if Int((iwork-1)/8)*8=iwork-1		&& кратно 8
		iDim=1
		Col=Str(icol-Int(icol/8)*8,1)+iif(icol<8,"/1","+/1")
		icol=icol+1
		if icol=1
			icol=2
		endif
		if icol=16
			icol=0
			iwork=1
		endif
	endif
	Set Color To &Col
	if iDim>8
		iDim=1
	endif
	@ 6+iDim,nDim Say TDim(iDim)
	iDim=iDim+1
	if ich>LenCr			&& разворот строки
		ich=1
	endif
	Work=SubStr(cr,ich)+SubStr(cr,1,ich)
	ich=ich+1
	iwork=iwork+1
	Set Color To 1/3
	@ 21,0 Say SubStr(Work,1,80)
	TimeNew=Time()
	Set Color To w/b
	@ 17,64 say TimeNew
	NNew=(Val(SubStr(TimeNew,1,2))*60+Val(SubStr(TimeNew,4,2)))*60+Val(SubStr(TimeNew,7,2))
	if NNew-NBeg>180		&& прошло больше 3 минут
		Exit
	endif
enddo
Restore Screen From Title
@ 17,64 Say Time()
Set Escape On
Return(rc)
