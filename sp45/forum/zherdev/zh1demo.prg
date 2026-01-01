******************************************
*
* Георгий ЖЕРДЕВ, 1992
*
* ZH1DEMO.PRG
* Демонстрационная программа
* работы функций библиотеки
* ZH1.LIB
*
* В данную программу не включены функции работы с базами данных - это
* существенно увеличило бы размеры файла.
* Эти функции продемонстрированы в другой демонстрационной программе, которую
* Вы можете заказать (смотрите ZH1.DOC).
*
* ЗАМЕЧАНИЯ ПО КОМПИЛЯЦИИ:
* Данная программа написана для компиляции компилятором Clipper версии 5.0
*
* Не забудьте в список библиотек при линковке включить  ZH1.LIB!
*
* ВСЯЧЕСКИХ ВАМ УСПЕХОВ В ТРУДЕ И ЛИЧНОЙ ЖИЗНИ !
* ПИШИТЕ: 672005. г. Чита-5,
*         ул. Рахова, 98, кв. 49.
*         Жердев Г.В.
*
******************************************



nosnow(.t.)           &&  Если у Вас CGA
set cursor off
set scoreboard off
private maincolor,choicecolor,democolor1,democolor2,democolor3,stringcolor,;
        choice,numbuffer,charbuffer,lbuffer

* Массив для демонстрации функции RunLine
    Private aSETUP:={'  *  Георгий ЖЕРДЕВ приветствует Вас ! В данный момент '+;
                     'демонстрируется работа функции RUNLINE. Для выхода из '+;
                     'этого раздела нажмите <ESCAPE>',14,33,76,0.15,"G/GR+"},;
                    maincolor:='gr/b', choicecolor:='gr/b,b+/gr+,,,b/gr',;
                    democolor1:='gr+/g,n/gr+,,,w/g', democolor2:='w/g',;
                    democolor3:='g/gr+', stringcolor:='gr+/b*', choice:=1
setcolor(maincolor)
SET KEY -1 TO _CALC           && Калькулятор - только демонстрационная картинка
@ 0,0,24,79 BOX "┌─┐│╛═╘│ "
@ 24,3 SAY ' Георгий Жердев 1992 '
@ 24,44 SAY ' <ESCAPE> - Завершить программу '
@ 3,1,22,30 BOX "╓─┐│╛═╚║ "
@ 3,4 SAY '* Ваш выбор: '
@ 22,4 SAY '* <F2> - Калькулятор/DEMO '
setcolor(democolor1)
@ 3,31,22,78 BOX "┌─╖║╝═╘│ "
@ 3,33 SAY "* DEMO "
set message to 1 center

DO WHILE .t.

* Ваш выбор:
    setcolor(choicecolor)
    @ 05,04 PROMPT ' AReversBot / AReversTop ' MESSAGE 'Перемещение элемента массива в начало / в конец'
    @ 06,06 PROMPT ' BoxCenter / SayBox ' MESSAGE 'Рамка / Строка по центру окна'
    @ 07,12 PROMPT ' BoxUp ' MESSAGE 'Распахивание окна на экран'
    @ 08,09 PROMPT ' Da / LString ' MESSAGE 'Выбор между "Да" и "Нет" / Выдача логического значения на экран'
    @ 09,03 PROMPT ' First / IsLetter / IsRus ' MESSAGE 'Первый символ строки / Есть ли это буква / Русского ли алфавита ?'
    @ 10,05 PROMPT ' SwitchInsert / Insert ' MESSAGE 'Автоматич. переключение формы курсора в зависимости от режима'
    @ 11,10 PROMPT ' AMultiSort ' MESSAGE 'Сортировка параллельных подмассивов'
    @ 12,11 PROMPT ' OverCirc ' MESSAGE 'Закраска / заполнение окна по кругу'
    @ 13,11 PROMPT ' OverLong ' MESSAGE 'Закраска / заполнение окна продольными штрихами'
    @ 14,11 PROMPT ' PauseWrit 'MESSAGE 'Замедленная выдача строки по буквам'
    @ 15,11 PROMPT ' PressKey ' MESSAGE 'Ожидание нажатия заданных клавиш'
    @ 16,11 PROMPT ' PutBlink ' MESSAGE 'Переключение режима мерцания в заданном участке экрана'
    @ 17,12 PROMPT ' RLimit ' MESSAGE 'Предупреждение о приближении к правому краю окна MEMO-редактора'
    @ 18,08 PROMPT ' RLower / RUpper ' MESSAGE 'Обращение строк в нижний / верхний регистр (в том числе кириллицы)'
    @ 19,12 PROMPT ' RunLine ' MESSAGE 'Бегущая строка'
    @ 20,11 PROMPT ' SayCenter ' MESSAGE 'Выдача строки по центру экрана'
    menu to choice
    DO CASE
        CASE choice=0
            IF lastkey()=27
                return
            ELSE
                choice=1
                loop
            ENDIF

* Функции AReversBot / AReversTop
        CASE choice=1
            _arev()
* Сама процедура _arev() описана в конце файла
            loop

* Функции BoxCenter / SayBox
        CASE choice=2
             save screen
             setcolor(democolor1)
             numbuffer=BoxCenter (8,12,60,"╒═╕│╛═╘│ ")

* Здесь, как и везде, на экран выдается фрагмент
* кода, использующий данную функцию

             SayBox (8,numbuffer,numbuffer+60,' COL = BoxCenter(8,12,60,"╒═╕│╛═╘│ ") ')
             SayBox (10,numbuffer,numbuffer+60,'SayBox(12,COL,COL+60," Нажмите любую клавишу ")')
             setcolor(democolor2)
             SayBox (12,numbuffer,numbuffer+60,' Нажмите любую клавишу ')
             inkey(0)
             restore screen
             loop

* Функция BoxUp
         CASE choice=3
             setcolor(democolor1)
             @ 4,32 clear to 4,77

* Здесь, как и везде, на экран выдается фрагмент
* кода, использующий данную функцию

             @ 4,33 SAY 'BoxUp (5,32,21,77,0.02,"┌─╖║╝═╘│ ")'
             setcolor(democolor3)
             BoxUp (5,32,21,77,0.02,"┌─╖║╝═╘│ ")
             loop

* Функции SwitchInsert / Insert
         CASE choice=6
             _clear()
             charbuffer=''
* Вызвав функцию Insert, связываем клавишу <INS> с функцией SwitchInsert:

             Insert()

* Здесь, как и везде, на экран выдается фрагмент
* кода, использующий данную функцию

             @ 4,33 SAY 'Insert()'
             @ 5,33 SAY '* 22 - Inkey-код клавиши <INSERT>'
             @ 17,33 SAY 'Проверьте работу клавиши <INSERT>'
             setcolor(democolor2)
             @ 7,33,15,76 BOX "┌─╖║╝═╘│ "
             @ 15,35 SAY '* <ESC - для выхода '
             setcursor(if(readinsert(),2,1))
             memoedit(charbuffer,8,34,14,75,.t.)
             setcursor(0)
             SET KEY 22 TO
             loop

* Функция AMultiSort
         CASE choice=7
             _amultis()
* Сама процедура _amultis() описана в конце файла
             loop

* Функция PauseWrit
         CASE choice=10
             _clear()
             charbuffer='Георгий ЖЕРДЕВ приветствует Вас !'

* Здесь, как и везде, на экран выдается фрагмент
* кода, использующий данную функцию

             @ 4,33 SAY 'SET KEY -1 TO CALCULATOR'

* Калькулятор подвешен к клавише F2 постоянно;
* в данном случае просто демонстрируется, что функция
* является состоянием ожидания, из которого можно вызвать
* клавишную функцию

             @ 5,33 SAY 'MESSAGE = "Георгий ЖЕРДЕВ приветствует Вас !"'
             @ 6,33 SAY 'PauseWrit (8,33,0.3,MESSAGE)'
             setcolor(democolor2)
             PauseWrit (8,33,0.3,charbuffer)
             loop

* Функция PressKey
        CASE choice=11
             _clear()
* Здесь, как и везде, на экран выдается фрагмент
* кода, использующий данную функцию

             @ 4,33 SAY 'SET KEY -1 TO CALCULATOR'

* Калькулятор подвешен к клавише F2 постоянно;
* в данном случае просто демонстрируется, что функция
* является состоянием ожидания, из которого можно вызвать
* клавишную функцию

             @ 5,33 SAY '@ 11,33 SAY "Нажмите клавиши A,B,C,<ENTER>"+;'
             @ 6,33 SAY '            " или <ESC>"'
             @ 7,33 SAY 'RET_KEY=PressKey ("A,B,C","13,27",.F.,13,33)'
             @ 8,33 SAY '@ 15,33 SAY "INKEY-Код нажатой клавиши: ";'
             @ 9,45 SAY '+ Ltrim(Str(RET_KEY))'
             setcolor(democolor2)
             @ 11,33 SAY 'Нажмите "A", "B", "C", <ENTER> или <ESC>'
             numbuffer=PressKey ("A,B,C","13,27",.F.,13,33)
             @ 15,33 SAY "INKEY-Код нажатой клавиши: "+Ltrim(Str(numbuffer))
             loop

* Функция RunLine
        CASE choice=15
             _clear()

* Здесь, как и везде, на экран выдается фрагмент
* кода, использующий данную функцию

             @ 4,33 SAY 'SET KEY -1 TO CALCULATOR'

* Калькулятор подвешен к клавише F2 постоянно;
* в данном случае просто демонстрируется, что функция
* является состоянием ожидания, из которого можно вызвать
* клавишную функцию

             @ 5,33 SAY 'Private aSETUP:={TEXT,14,33,76,0.15,"G/GR+"}'
* На самом деле массив определен в начале программы
             @ 6,33 SAY 'USER_KEY = 0'
             @ 7,33 SAY 'DO WHILE USER_KEY != 27'
             @ 8,33 SAY '   USER_KEY = RunLine (aSETUP)'
             @ 9,33 SAY '   @ 16,33 SAY "INKEY-Код нажатой клавиши: ";'
             @ 10,33 SAY '               +PadR(USER_KEY,4)'
             @ 11,33 SAY 'ENDDO'
             setcolor(democolor2)
             numbuffer = 0
* Обращение к RunLine в цикле, пока не нажмут <ESC>
             DO WHILE numbuffer <> 27
                numbuffer = RunLine (aSETUP)
                @ 16,33 SAY "INKEY-Код нажатой клавиши: "+PadR(numbuffer,4)
            ENDDO
            loop

* Функции Da / LString
         CASE choice=4
             _clear()

* Здесь, как и везде, на экран выдается фрагмент
* кода, использующий данную функцию

             @ 4,33 SAY '@ 11,33 SAY "Выберите между ДА и НЕТ"'
             @ 5,33 SAY 'LOG = Da(13,33)'
             @ 6,33 SAY '@ 13,33 SAY "Ваш выбор: " + LString(LOG,0)'
             @ 7,33 SAY '@ 14,33 SAY "Ваш выбор: " + LString(LOG,1)'
             @ 8,33 SAY '@ 15,33 SAY "Ваш выбор: " + LString(LOG,2)'
             setcolor(democolor2)
             @ 11,33 SAY "Выберите между ДА и НЕТ"
             lbuffer = Da(13,33)
             @ 13,33 SAY "Ваш выбор: " + LString(lbuffer,0)
             @ 14,33 SAY "Ваш выбор: " + LString(lbuffer,1)
             @ 15,33 SAY "Ваш выбор: " + LString(lbuffer,2)
             loop

* Функции First / IsLetter / IsRus
        CASE choice=5
             _clear()

* Здесь, как и везде, на экран выдается фрагмент
* кода, использующий данную функцию

             @ 04,33 SAY 'SET KEY -1 TO CALCULATOR'

* Калькулятор подвешен к клавише F2 постоянно;
* в данном случае просто демонстрируется, что функция
* является состоянием ожидания, из которого можно вызвать
* клавишную функцию

             @ 05,33 SAY '@ 14,33 SAY "Введите слово: " GET STRING'
             @ 06,33 SAY 'READ'
             @ 07,33 SAY '@ 16,33 SAY "Первый символ: " +;'
             @ 08,33 SAY '            First(STRING)'
             @ 09,33 SAY '@ 17,33 SAY "Является буквой: " +;'
             @ 10,33 SAY '            LString(IsLeter(STRING,2))'
             @ 11,33 SAY '@ 18,55 SAY "Кириллица: " +;'
             @ 12,33 SAY '            LString(IsRus(STRING,2))'
             setcolor(democolor2)
             setcursor(if(readinsert(),2,1))
             charbuffer=space(20)
             @ 14,33 SAY "Введите слово: " GET charbuffer
             READ
             setcursor(0)
             @ 16,33 SAY "Первый символ: " + First(charbuffer)
             @ 17,33 SAY "Является буквой: " + LString(isletter(charbuffer,2))
             @ 18,33 SAY "Кириллица: " + LString(isrus(charbuffer,2))
             loop

* Функция OverCirc
        CASE choice=8
             _clear()

* Здесь, как и везде, на экран выдается фрагмент
* кода, использующий данную функцию

             @ 4,33 SAY 'OverCirc(5,32,21,77,"▒")'
             setcolor(democolor3)
             OverCirc(5,32,21,77,"▒")
             loop

* Функция OverLong
        CASE choice=9
             _clear()

* Здесь, как и везде, на экран выдается фрагмент
* кода, использующий данную функцию

             @ 4,33 SAY 'OverLong(5,32,21,77,"▒")'
             setcolor(democolor3)
             OverLong(5,32,21,77,"▒")
             loop

* Функция PutBlink
        CASE choice=12
             _clear()

* Здесь, как и везде, на экран выдается фрагмент
* кода, использующий данную функцию

             @ 4,33 SAY 'PutBlink(18,0,24,25)'
             PutBlink(18,0,24,25)
             setcolor(democolor2)
             @ 6,33 SAY 'Нажмите любую клавишу'
             inkey(0)
             setcolor(democolor1)
             @ 6,33 SAY 'И еще раз:           '
             @ 7,33 SAY 'PutBlink(18,0,24,25)'
             PutBlink(18,0,24,25)
             @ 9,33 SAY '                     '
             loop

* Функция RLimit
        CASE choice=13
             _clear()
             charbuffer=chr(13)+chr(10)+;
                        'FUNCTION MyFunc(MODE,CURROW,CURCOL)'+chr(13)+chr(10)+;
                        '    IF MODE = 0'+chr(13)+chr(10)+;
                        '        RLimit(CURCOL,44,6,.F.)'+chr(13)+chr(10)+;
                        '    ENDIF'+chr(13)+chr(10)+;
                        'RETURN 0'+chr(13)+chr(10)
* Данная строка (charbuffer) будет показана в окне MemoEdit
* Аналогичная функция MyFunc описана в конце файла

* Здесь, как и везде, на экран выдается фрагмент
* кода, использующий данную функцию

             @ 4,33 SAY 'MemoEdit(BUFFER,7,33,13,76,.T.,"MyFunc")'
             setcolor(democolor2)
             @ 6,32,14,77 BOX "╓─╖║╝═╚║ "
             @ 6,34 SAY '* Перемещайтесь к правому краю '
             @ 14,34 SAY '* <ESC> для завершения '
             setcursor(if(readinsert(),2,1))
             memoedit(charbuffer,7,33,13,76,.t.,'MyFunc')
             SETCURSOR(0)
             loop

* Функции RLower / RUpper
        CASE choice=14
             _clear()
             charbuffer=space(20)

* Здесь, как и везде, на экран выдается фрагмент
* кода, использующий данную функцию

             @ 4,33 SAY '@ 12,33 SAY "Введите любое слово: " GET STR'
             @ 5,33 SAY 'READ'
             @ 6,33 SAY 'STRING = RUpper(STR)'
             @ 7,33 SAY '@ 13,33 SAY "RUpper = " + STR'
             @ 8,33 SAY 'STRING = Rlower(STR)'
             @ 9,33 SAY '@ 14,33 SAY "Обратное обращение: "'
             @ 10,33 SAY '@ 15,33 SAY "RLower = " + STR'
             setcolor(democolor2)
             setcursor(if(readinsert(),2,1))
             @ 12,33 SAY "Введите любое слово: " GET charbuffer
             READ
             setcursor(0)
             charbuffer=RUpper(trim(charbuffer))
             @ 13,33 SAY "RUpper = " + charbuffer
             @ 14,33 SAY "Обратное обращение: "
             @ 15,33 SAY "RLower = " + RLower(charbuffer)
             loop

* Функция SayCenter
        CASE choice=16
             save screen
             setcolor(democolor3)

* Здесь, как и везде, на экран выдается фрагмент
* кода, использующий данную функцию

             SayCenter(10,' SayCenter(12," Нажмите любую клавишу для продолжения ") ')
             SayCenter(12," Нажмите любую клавишу для продолжения ")
             inkey(0)
             restore screen
             loop
    ENDCASE
ENDDO
RETURN


PROCEDURE _CLEAR
    setcolor(democolor1)
    @ 4,32 CLEAR TO 21,77
RETURN

* Функция RLimit
FUNCTION MyFunc(MODE,CURROW,CURCOL)
    IF MODE=0
        RLimit(CURCOL,44,6,.F.)
    ENDIF
RETURN 0


* Функции AReversBot / AReversTop
PROCEDURE _ARev
    private exampl:={'Элемент1','Элемент2','Элемент3','Элемент4','Элемент5'},;
            num
    _clear()

* Здесь, как и везде, на экран выдается фрагмент
* кода, использующий данную функцию

    @ 4,33 SAY 'PRIVATE ARRAY[5] '
    FOR num=1 TO 5
        @ num+4,37 SAY 'ARRAY['+ltrim(str(num))+'] = '+exampl[num]
    NEXT
    setcolor(democolor2)
    @ 11,33 SAY 'AreversBot(ARRAY,1)'
    AreversBot(exampl,1)
    FOR num=1 TO 5
        @ num+11,33 SAY 'ARRAY['+ltrim(str(num))+'] = '+exampl[num]
    NEXT
    @ 19,33 SAY 'Нажмите любую клавишу'
    inkey(0)
    @ 11,58 SAY 'AreversTop(ARRAY,5)'
    AreversTop(exampl,5)
    FOR num=1 TO 5
        @ num+11,58 SAY 'ARRAY['+ltrim(str(num))+'] = '+exampl[num]
    NEXT
    @ 19,33 SAY '                     '
RETURN

* Функция AMultiSort
PROCEDURE  _amultis
    _clear()
    private exampl:={{1,2,3,4,5},{'Один','Два','Три','Четыре','Пять'}},num

* Здесь, как и везде, на экран выдается фрагмент
* кода, использующий данную функцию

    @ 4,33 SAY 'PRIVATE ARRAY[2]'
    FOR num=1 TO 5
        @ num+5,33 SAY 'ARRAY[1]['+ltrim(str(num))+'] := '+ltrim(str(exampl[1,num]))+;
                  '     ARRAY[2]['+ltrim(str(num))+'] := "'+ exampl[2,num]+'"'
    NEXT
    @ 12,33 SAY 'AMultiSort(ARRAY,2)'
    AMultiSort(exampl,2)
    FOR num=1 TO 5
        @ num+13,33 SAY 'ARRAY[1]['+ltrim(str(num))+'] := '+ltrim(str(exampl[1,num]))+;
                  '     ARRAY[2]['+ltrim(str(num))+'] := "'+ exampl[2,num]+'"'
    NEXT
RETURN