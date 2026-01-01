
clear
set talk off
set status off
set procedure to sufler
set color to w/b,gr+/rb,n
@ 2,30 say 'проверка sufler'
***************************** проверка основная
public cappy_(4)
cappy_(1) = 3
cappy_(2) = '==================================  Пользуйтесь клавишами:'
cappy_(3) = ':  должность    :    оклад       :     стрелки,PGDN,PGUP,'
cappy_(4) = '==================================        ENTER,ESC'
nrecord = 0
valpole = ' '
do sufler with 7,5,6,75,'sufltest','dol  okl ',;
  nrecord,valpole,' ',' ',':\:\ руб.:','\\.cappy_','',' '
set color to w/b,gr+/rb,n
 ? 'Вы отметили ',valpole,' из ',str(nrecord,2),' записи файла SUFLTEST.'
 ? ' '
 wait '************ проверка установки длин'
do sufler with 10,4,7,75,'sufltest','dol:14 okl:10.0 dol:20',;
  nrecord,valpole,' ',' ',':\:\ руб.:',' ','\\.cappy_',' '
set color to w/b,gr+/rb,n
 ? 'Вы отметили ',valpole,' из ',str(nrecord,2),' записи файла SUFLTEST.'
 ? ' '
 wait '******************* проверка расцветки '
 dimension clr123(4)
clr123(1) = 'b/w'
clr123(2) = ' '
clr123(3) = 'g/b'
clr123(4) = 'b/g'
do sufler with 0,0,0,0,'sufltest','dol',;
  nrecord,valpole,' ','okl < 160','\ ','низкооплачиваемые','подвал','clr123'
	set color to w/b,gr+/rb,n
 ? 'Вы отметили ',valpole,' из ',str(nrecord,2),' записи файла SUFLTEST.'
 ? ' '
wait '***************** проверка массива'
DIMENSION mm(10)
mm(1) = 11
mm(2) = .f.
mm(3) = .t.
mm(4) = date()
mm(5) = '51'
mm(6) = '  61'
mm(7) = 'ggg71'
mm(8) = '81g'
mm(9) = '91ff'
mm(10) = '10aaaa'
n = 0
val = ' '
do sufler with 10,5,5,30,'\\.mm(10)','c:10',n,val,' ',' ',;
      '.? . ? \***','заголовок','примечание',''
? n,val
wait ' еще'
mm(1) = 1
mm(2) = '2a'
mm(3) = date()
mm(4) = .t.
mm(5) = .f.
mm(6) = 66.66
mm(7) = 77.77
mm(8) = 88.88
mm(9) = 99.99
mm(10) = 0
n = 0
val = ' '
do sufler with 10,5,3,30,'\\.mm(10)','a:6.2',n,val,' ',' ',;
      '','','примечание',''
? n,val
wait '******************* проверка режима просмотра'
clr123(2) = clr123(1)
do sufler with 7,5,4,30,'sufltest','dol  ',;
  nrecord,valpole,' ',' ',':','','выход по ESC','clr123'
clear
wait ' конец проверки SUFLER'
set procedure to
set status on
