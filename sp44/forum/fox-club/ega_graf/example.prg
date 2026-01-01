* Ega_Graf Example Programm for FoxPro.
* Тэаро А.Р., 1991 [(3432) 58-37-37].

ans=Ega_Graf('Active')
if ans <> 'y'
	? "Ega Not Installed or EGA.Bin Not Found. Program Aborted."
	Return(-1)
endif
Save Screen to Example
ans=Ega_Graf('Clear',16)		&& инициал.графики
ans=Rand(-1)
On Escape i=i+10000
i=0
ans=Ega_Graf('Color',5)
ans=Ega_Graf('Text',20,0,'Example Graphic Programm for FoxPro')
ans=Ega_Graf('Text',35,24,'Esc-Exit')
do while(i<100)			&& 100 случайных линий
	ans=Ega_Graf('Color',Int(Rand()*15)+1)
	ans=Ega_Graf('Line',Rand()*639,Rand()*349,Rand()*639,Rand()*349)
	i=i+1
enddo
ans=InKey(5)
ans=Ega_Graf('Video',3)
Restore Screen From Example
On Escape
Return(0)