/**************************************************
*           Файл iterat.prg
*
*         Программа сканирует текущий диск
*         и формирует массив, содержащий "дерево"
*
*         В программе используется функция из 
*         библиотеки CT150 :    DIRCHANGE()
*
*         Киев, "ИнфоМир", CLIPPER 5.0
*         Август 1992  Ханин С.Г., Ханин А.Г.
***************************************************/
LOCAL rez
rez:=direval()
AEVAL(rez,{|x|QOUT(x)})
*********************************
FUNCTION direval()
LOCAL mas,final:={},pro,i,star
STATIC rez:={},j:=0
* mas   - результат работы функции DIRECTORY() в текущем каталоге
* final - массив поддиректорий в текущем каталоге
* pro   - массив поддиректорий каталога на один уровень ниже
* i     - переменная цикла
* star  - исходная директория (туда надо вернуться)
* rez   - результирующий массив директорий
* j     - уровень "погружения"
DO CASE
   CASE j==0
        star:="\"+CURDIR()
        Dirchange("\")
END
j++
mas:=DIRECTORY("*.*","D")
* выделим список поддиректорий
AEVAL(mas,{|x|IF(x[5]=="D" .and. x[1]#"." .and. x[1]#"..",;
AADD(final,IF(CURDIR()=="","\"+x[1],"\"+CURDIR()+"\"+x[1])),NIL)})
DO CASE
  CASE LEN(final)#0       //ели в данном каталоге есть подкаталоги
       FOR I=1 TO LEN(final)
           Dirchange(final[i]) // опускаемся
           pro:=direval()      // рекурсивный вызов
           AEVAL(pro,{|x|AADD(rez,x)}) // добавим полученное в rez
       NEXT
END    
j--
DO CASE
   CASE j==0  // если пора "совсем" выходить
        AEVAL(rez,{|x|AADD(final,x)}) // добавим все в final
        Dirchange(star)           
        ASORT(final)
END
RETURN(final)
