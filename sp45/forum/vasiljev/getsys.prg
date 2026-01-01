/***
*	Getsys.prg
*  Модернизированная GET/READ-подсистема для Clipper 5.0
*  Copyright (c) 1990, 1991 Nantucket Corp.  &
*                      1992 МП " КАСТ "  Васильев Игорь Викторович
*                      г. Самара
*  Компилировать с опциями: /m/n/w
*/

#include "Set.ch"
#include "Inkey.ch"
#include "Getexit.ch"

#define K_UNDO          K_CTRL_U


// Глобальные переменные состояния для активации READ
static Format
static Updated := .f.
static KillRead
static LastExit
static Lastrrow
static LastCcol
static ActiveGet
static ReadProcName
static ReadProcLine
static Allowed


// Индексы массива, используемого для сохранения состояния переменных
#define GSV_KILLREAD        1
#define GSV_LASTEXIT            2
#define GSV_LASTRROW        3
#define GSV_LASTCCOL            4
#define GSV_ACTIVEGET       5
#define GSV_READVAR             6
#define GSV_READPROCNAME    7
#define GSV_READPROCLINE        8
#define GSV_ALLOWED         9

#define GSV_COUNT           9



/***
*	ReadModal()
* Стандартная функция исполняющая READ для массива сформированного
* командами GET.
*
* Замечание: GetList стал двумерным , поэтому будем в комментариях
* различать строки и столбцы GetList и строки и столбцы как координаты
* GET на экране
*/
func ReadModal( GetList )

local get
local rrow              //  Строка в  GetList
local ccol              //  Столбец в GetList
local savedGetSysVars

if ( ValType(Format) == "B" )
   Eval(Format)
end

if ( Empty(getList) )
                        // Для совместимости с S87
   SetPos( MaxRow()-1, 0 )
   return (.f.)       // выход со значением "ложь", которое обычно не анализируется
end

// Сохранение состояния глобальных переменных
savedGetSysVars := ClearGetSysVars()

// Установка состояния для использования в SET KEY
ReadProcName := ProcName(1)
ReadProcLine := ProcLine(1)

// Установка на начальный GET для чтения
ccol := GetList[1,1]:cargo[3]
rrow := GetList[1,1]:cargo[4]
LastExit := GetList[ccol,rrow]:exitState := GE_DOWN


while allowed

 // Получение следующего GET из списка и передача его как активного GET
   get := GetList[ccol,rrow]
   PostActiveGet( get )

 // Чтение для GET
   if ( ValType( get:reader ) == "B" )
      Eval( get:reader, get )     // использование блока для чтения
   else
      GetReader( get )        // использование стандартной функции чтения
   end

 // Переход к следующему GET-объекту, базируясь на состоянии выхода
 // из предыдущего чтения
   Settle( GetList, @rrow, @ccol )

end

 // Запомним координаты GETа в GetList , из которого вышли ,
 // в cargo первого элемента GetList
GetList[1,1]:cargo[3] := ccol
GetList[1,1]:cargo[4] := rrow

// Восстановление глобальных переменных
RestoreGetSysVars(savedGetSysVars)

return (Updated)




/***
*	GetReader()
* Стандартная функция чтения для одиночного GET-объекта
* Замечание: Признак "виртуального" GETа - пустая переменная get:name
*/
proc GetReader( get )
LOCAL virtual:=Empty(get:name)

  // чтение GET-объекта при выполнении WHEN-условия
	if ( GetPreValidate(get) )

    // Активизация GET-объекта для чтения
      IF virtual
         Virt_SetFocus(get)
      ELSE
         get:SetFocus()
      ENDIF

		while ( get:exitState == GE_NOEXIT )

      // Проверка на инициацию typeOut (выход за границы буфера ввода)
			if ( get:typeOut )
				get:exitState := GE_ENTER
			end

      // Прием и анализ нажатия клавиш до выхода из чтения.
      // Обычные и виртуальные GETы обрабатываются разными функциями
         IF virtual
            while ( get:exitState == GE_NOEXIT )
               VirtApplyKey( get )
            end
         ELSE
            while ( get:exitState == GE_NOEXIT )
               GetApplyKey( get, Inkey(0) )
            end
         ENDIF
      // Запрет выхода, если условие VALID не выполнено
			if ( !GetPostValidate(get) )
				get:exitState := GE_NOEXIT
			end

		end

    // деактивизация GET
      IF virtual
         Virt_KillFocus(get)
      ELSE
         get:KillFocus()
      ENDIF
	end

return




/***
*	GetApplyKey()
* Исполнение действий по нажатию клавиши, принятого по Inkey(),
* для GET-объекта.
* Замечание: GET-объект должен иметь фокус ввода
*/
proc GetApplyKey(get, key)

local cKey
local bKeyBlock


  // Сначала проверка на SET KEY
	if ( (bKeyBlock := SetKey(key)) <> NIL )

		GetDoSetKey(bKeyBlock, get)
    return                  // См. замечание

	end


   DO CASE
   CASE ( key == K_UP )
		get:exitState := GE_UP

   CASE ( key == K_DOWN )
		get:exitState := GE_DOWN

//
   CASE ( key == K_CTRL_UP )
      get:exitState := GE_UP

   CASE ( key == K_CTRL_DOWN )
      get:exitState := GE_DOWN

   CASE ( key == K_CTRL_LEFT )
      get:exitState := GE_JMP_LEFT

   CASE ( key == K_CTRL_RIGHT )
      get:exitState := GE_JMP_RIGHT

   CASE ( key == K_CTRL_HOME )
		get:exitState := GE_TOP

   CASE (key == K_CTRL_END)
		get:exitState := GE_BOTTOM

   CASE (key == K_CTRL_PGUP)
      get:exitState := GE_COL_TOP

   CASE (key == K_CTRL_PGDN)
      get:exitState := GE_COL_BOTTOM

//

   CASE ( key == K_ENTER )
		get:exitState := GE_ENTER

   CASE ( key == K_ESC )
		if ( Set(_SET_ESCAPE) )
			get:undo()
			get:exitState := GE_ESCAPE
		end

   CASE ( key == K_PGUP )
		get:exitState := GE_WRITE

   CASE ( key == K_PGDN )
		get:exitState := GE_WRITE

   CASE ( key == K_CTRL_W )
		get:exitState := GE_WRITE
//
	case (key == K_INS)
		Set( _SET_INSERT, !Set(_SET_INSERT) )
		ShowScoreboard()

	case (key == K_UNDO)
		get:Undo()

	case (key == K_HOME)
		get:Home()

	case (key == K_END)
		get:End()

	case (key == K_RIGHT)
		get:Right()

	case (key == K_LEFT)
		get:Left()

   case (key == K_TAB)
      get:WordRight()

   case (key == K_SH_TAB)
      get:WordLeft()

	case (key == K_BS)
		get:BackSpace()

	case (key == K_DEL)
		get:Delete()

	case (key == K_CTRL_T)
		get:DelWordRight()

	case (key == K_CTRL_Y)
		get:DelEnd()

	case (key == K_CTRL_BS)
		get:DelWordLeft()

	otherwise

		if (key >= 32 .and. key <= 255)

			cKey := Chr(key)

			if (get:type == "N" .and. (cKey == "." .or. cKey == ","))
        IF ('- ' $ get:Buffer).OR.('-0' $ get:Buffer) //  The Nantucket News
          get:ToDecPos()                              //  ******************
          get:Left()                                  //  Volume 5 Number 3
          get:Left()                                  //  November/December 1990
          get:Insert(CHR(45))                         //  Page # 25                                                //  Page # 25
          get:Insert(CHR(48))                         //  ----------------------
        ELSE                                          //  Том 5 номер 3
          get:ToDecPos()                              //  Ноябрь/Декабрь 1990
        ENDIF                                         //  Страница 25
			else
				if ( Set(_SET_INSERT) )
					get:Insert(cKey)
				else
					get:Overstrike(cKey)
				end

				if (get:typeOut .and. !Set(_SET_CONFIRM) )
					if ( Set(_SET_BELL) )
						?? Chr(7)
					end

					get:exitState := GE_ENTER
				end

			end

		end

	endcase

return



/***
*  VirtApplyKey()
* Исполнение действий по нажатию клавиши, принятого по Inkey(),
* для виртуального GET-объекта.
* Замечание: GET-объект должен иметь фокус ввода
*/
PROC VirtApplyKey(get)

LOCAL cKey
LOCAL bKeyBlock
LOCAL key

 // Если есть процедура,заданная GET_PROC - выполнить ее ,
 // иначе ждем нажатия клавиши

   IF Valtype(get:cargo[2])="B"
      Eval(get:cargo[2])
      key := Lastkey()
   ELSE
      key:=Inkey(0)
       // Сначала проверка на SET KEY
      IF ( (bKeyBlock := SetKey(key)) <> NIL )
         GetDoSetKey(bKeyBlock, get)
         RETURN                  // См. замечание
      ENDIF
   ENDIF

   DO CASE
   CASE ( key == K_UP )
		get:exitState := GE_UP

   CASE ( key == K_DOWN )
		get:exitState := GE_DOWN

//
   CASE ( key == K_CTRL_UP )
      get:exitState := GE_UP

   CASE ( key == K_CTRL_DOWN )
      get:exitState := GE_DOWN

   CASE ( key == K_CTRL_LEFT )
      get:exitState := GE_JMP_LEFT

   CASE ( key == K_CTRL_RIGHT )
      get:exitState := GE_JMP_RIGHT

   CASE ( key == K_CTRL_HOME )
		get:exitState := GE_TOP

   CASE (key == K_CTRL_END)
		get:exitState := GE_BOTTOM

   CASE (key == K_CTRL_PGUP)
      get:exitState := GE_COL_TOP

   CASE (key == K_CTRL_PGDN)
      get:exitState := GE_COL_BOTTOM

//

   CASE ( key == K_ENTER )
		get:exitState := GE_ENTER

   CASE ( key == K_ESC )
		if ( Set(_SET_ESCAPE) )
			get:undo()
			get:exitState := GE_ESCAPE
		end

   CASE ( key == K_PGUP )
		get:exitState := GE_WRITE

   CASE ( key == K_PGDN )
		get:exitState := GE_WRITE

   CASE ( key == K_CTRL_W )
		get:exitState := GE_WRITE

   ENDCASE

RETURN




/***
*	GetPreValidate()
* Проверка условия входа в Get-объект (предложение WHEN).
*/
func GetPreValidate(get)

local saveUpdated
local when := .t.


	if ( get:preBlock <> NIL )

		saveUpdated := Updated

		when := Eval(get:preBlock, get)

		get:Display()

		ShowScoreBoard()
		Updated := saveUpdated

	end


	if ( KillRead )
		when := .f.
    get:exitState := GE_ESCAPE    // вызвать выход из ReadModal()

	elseif ( !when )
    get:exitState := GE_WHEN    // индикация невыполнения условия

	else
    get:exitState := GE_NOEXIT    // подготовка к редактированию

	end

return (when)



/***
*	GetPostValidate()
* Проверка условия выхода (предложение VALID) для GET-объекта.
*
* Замечание: ошибочные данные отвергаются путем восстановления сохраненного буфера
*/
func GetPostValidate(get)

local saveUpdated
local changed, valid := .t.


	if ( get:exitState == GE_ESCAPE )
    return (.t.)          // выход по ESC со значением "истина"
	end

	if ( get:BadDate() )
		get:Home()
		DateMsg()
		ShowScoreboard()
    return (.f.)          // выход со значением "ложь"
	end


  // если было редактирование, то присвоение переменной нового значения
	if ( get:changed )
		get:Assign()
		Updated := .t.
	end


  // подготовка буфера редактирования, курсор в начало, отображение
	get:Reset()


  // проверка условия VALID, если оно используется
	if ( get:postBlock <> NIL )

		saveUpdated := Updated

    // совместимость с S87
        SetPos( get:row, get:col + Len(get:buffer) )

		valid := Eval(get:postBlock, get)

    // переустановка курсора
		SetPos( get:row, get:col )

		ShowScoreBoard()
		get:UpdateBuffer()

		Updated := saveUpdated

		if ( KillRead )
      get:exitState := GE_ESCAPE  // вызвать выход из ReadModal()
			valid := .t.
		end

	end

return (valid)




/***
*	GetDoSetKey()
* Исполнение действий по SET KEY во время редактирования.
*/
proc GetDoSetKey(keyBlock, get)

local saveUpdated


  // Если было редактирование, то присвоение переменной значения
	if ( get:changed )
		get:Assign()
		Updated := .t.
	end


	saveUpdated := Updated

	Eval(keyBlock, ReadProcName, ReadProcLine, ReadVar())

	ShowScoreboard()
	get:UpdateBuffer()

	Updated := saveUpdated


	if ( KillRead )
    get:exitState := GE_ESCAPE    // вызвать выход из ReadModal()
	end

return



/***
*  Virt_SetFocus(get)
* Активизация одиночного виртуального GET-объекта
*/
Virt_SetFocus(get)
PROC Virt_SetFocus(get)
LOCAL inv_color:=get:ColorSpec
LOCAL need_color:=Substr(inv_color,At(",",inv_color)+1)
IF !Empty( get:cargo[1] )
// Если есть процедура,заданная GET_SHOW - выполнить ее
   @ get:row,get:col SAY Eval(get:cargo[1]) COLOR need_color
ENDIF
Devpos(get:row,get:col)
RETURN



/***
*  Virt_KillFocus(get)
* Деактивизация одиночного виртуального GET-объекта
*/
PROC Virt_KillFocus(get)
LOCAL need_color:=get:ColorSpec
// Если есть процедура,заданная GET_SHOW - выполнить ее
IF !Empty( get:cargo[1] )
	@ get:row,get:col SAY Eval(get:cargo[1]) COLOR need_color
ENDIF
Devpos(get:row,get:col)
RETURN




/**************************
*
* READ сервис
*
*/





/***
*	Settle()
*
* Возвращает новую позицию Get-объекта, базируясь на
*
*   - текущей позиции
*   - exitState - состоянию окончания чтения текущего объекта
*
* Замечание: установление allowed := .F. означает прекращение READ
* Замечание: exitState старого Get передается новому Get
*/
STATIC PROC Settle(GetList, rrow , ccol)

LOCAL exitState
// Массив , используемый для определения следующего GET
// в случае выхода из редактирования GET по Ctrl_Right или Ctrl_Left
LOCAL jmp_arr := {100,0,0}

   exitState := GetList[ccol,rrow]:exitState
   IF ( exitState == GE_ESCAPE .or. exitState == GE_WRITE )
      allowed := .F.
      RETURN          // замечание 1
   END

   IF ( exitState <> GE_WHEN )
    // сброс информационного состояния
      Lastrrow := rrow
      LastCcol := ccol

   ELSE
    // exitState сохраняется , если выход был по Up или Down
      IF LastExit <> GE_UP .AND. LastExit <>  GE_DOWN
         LastExit := GE_DOWN
      ENDIF
      exitState := LastExit

   END

	/***
  * дешифратор кодов для передвижения по Get-объектам
	*/
   DO CASE
      CASE ( exitState == GE_UP )
         DO CASE
            CASE rrow <> 1
               rrow --
            CASE rrow = 1 .AND. ccol <> 1
               ccol--
               rrow := Len(GetList[ccol] )
         ENDCASE

      CASE ( exitState == GE_DOWN )
         DO CASE
            CASE rrow <> Len(GetList[ccol] )
               rrow ++
            CASE rrow = Len(GetList[ccol] ) .AND. Len(GetList) > ccol
               ccol++
               rrow := 1
            OTHERWISE
               ccol := 1
               rrow := 1
         ENDCASE

      CASE ( exitState == GE_TOP )
         rrow := 1
         ccol := 1
         exitState := GE_DOWN

      CASE ( exitState == GE_BOTTOM )
         ccol := Len(GetList)
         rrow := Len(GetList[ccol])
         exitState := GE_UP

      CASE ( exitState == GE_COL_TOP  )
         rrow := 1
         IF ccol == 1
            exitState := GE_DOWN
         ENDIF

      CASE ( exitState == GE_COL_BOTTOM  )
         rrow := Len(Getlist[ccol])
         IF ccol == Len(Getlist)
            exitState := GE_UP
         ENDIF

      CASE ( exitState == GE_ENTER )
         DO CASE
            CASE rrow <> Len(GetList[ccol] )
               rrow ++
            CASE rrow = Len(GetList[ccol] ) .AND. Len(GetList) > ccol
               ccol++
               rrow := 1
            OTHERWISE
               allowed := .F.
         ENDCASE

      CASE ( exitState == GE_JMP_LEFT )
         IF ccol > 1
            old_g_row  := Getlist[ccol,rrow]:row
            BEGIN SEQUENCE
               WHILE .T.
                  ccol--                           // Следующий столбец
                  rrow := 1
                  num_rrow := Len(GetList[ccol])  // Количество строк в столбце
                  WHILE .T.                       // GetList
                     g_row := Getlist[ccol,rrow]:row
                     DO CASE
                        CASE g_row =  old_g_row

                           // Нашли GET на той же строке на экране.
                           // Прыгаем!

                           BREAK

                        CASE g_row > old_g_row

                           // GET на той же строке не найден.
                           // Если разность между строками этих GET на экране
                           // меньше , чем записанная в jmp_arr[1] , сохраним
                           // в массиве jmp_arr ее и координаты в GetList
                           // текущего GET

                           IF  (buff := g_row - old_g_row) < jmp_arr[1]
                              jmp_arr[1] := buff
                              jmp_arr[2] := ccol
                              jmp_arr[3] := rrow
                           ENDIF
                           EXIT

                        CASE rrow = num_rrow

                           // Последняя строка
                           // Смотрите комментарий выше

                           IF  Abs( (buff := g_row - old_g_row) ) < jmp_arr[1]
                              jmp_arr[1] := buff
                              jmp_arr[2] := ccol
                              jmp_arr[3] := rrow
                           ENDIF
                           EXIT

                     ENDCASE
                     rrow++     // Следующая строка
                  END
                  IF ccol = 1

                     // Последняя колонка
                     // Пора принимать решение

                     ccol := jmp_arr[2]
                     rrow := jmp_arr[3]
                     EXIT
                  ENDIF
               END
            END SEQUENCE
         ENDIF

      CASE ( exitState == GE_JMP_RIGHT )

         // Все анологично вышеописанному

         IF ccol < ( len_get_list := Len(GetList) )
            old_g_row  := Getlist[ccol,rrow]:row
            BEGIN SEQUENCE
               WHILE .T.
                  ccol++
                  rrow := 1
                  num_rrow := Len(GetList[ccol])
                  WHILE .T.
                     g_row := Getlist[ccol,rrow]:row
                     DO CASE
                        CASE g_row =  old_g_row
                           BREAK             // Very well

                        CASE g_row > old_g_row
                           IF  (buff := g_row - old_g_row) < jmp_arr[1]
                              jmp_arr[1] := buff
                              jmp_arr[2] := ccol
                              jmp_arr[3] := rrow
                           ENDIF
                           EXIT

                        CASE rrow = num_rrow
                           IF  Abs( (buff := g_row - old_g_row) ) < jmp_arr[1]
                              jmp_arr[1] := buff
                              jmp_arr[2] := ccol
                              jmp_arr[3] := rrow
                           ENDIF
                           EXIT

                     ENDCASE
                     rrow++
                  END
                  IF ccol = len_get_list
                     ccol := jmp_arr[2]
                     rrow := jmp_arr[3]
                     EXIT
                  ENDIF
               END
            END SEQUENCE
         ENDIF

      ENDCASE

  // Запись состояния выхода из чтения Get-объекта
	LastExit := exitState

   if ( rrow <> 0 )
      GetList[ccol,rrow]:exitState := exitState
   end

RETURN





/***
*	PostActiveGet()
* Сообщение активного GET-объекта функциям ReadVar() и fGetActive().
*/
static proc PostActiveGet(get)

	GetActive( get )
	ReadVar( GetReadVar(get) )

	ShowScoreBoard()

return



/***
*	ClearGetSysVars()
* Сохранение и очистка глобальных переменных READ. Возвращает массив
* с сохраненными значениями
*
* Замечание: состояние 'Updated' очищается, но не сохраняется (совместимо с S87).
*/
static func ClearGetSysVars()

local saved[ GSV_COUNT ]


	saved[ GSV_KILLREAD ] := KillRead
	KillRead := .f.

	saved[ GSV_LASTEXIT ] := LastExit
	LastExit := 0

	saved[ GSV_LASTRROW ] := Lastrrow
	Lastrrow := 0

	saved[ GSV_LASTCCOL ] := Lastccol
	Lastccol := 0

	saved[ GSV_ACTIVEGET ] := GetActive( NIL )

	saved[ GSV_READVAR ] := ReadVar( "" )

	saved[ GSV_READPROCNAME ] := ReadProcName
	ReadProcName := ""

	saved[ GSV_READPROCLINE ] := ReadProcLine
	ReadProcLine := 0

   saved[ GSV_ALLOWED ] := allowed
   allowed := .T.

	Updated := .f.

return (saved)



/***
*   RestoreGetSysVars()
* Восстановление глобальных переменных READ из массива сохраненных значений.
*
* Замечание: состояние 'Updated' не восстанавливается (совместимо с S87).
*/
static proc RestoreGetSysVars(saved)

	KillRead := saved[ GSV_KILLREAD ]

	LastExit := saved[ GSV_LASTEXIT ]

	Lastrrow := saved[ GSV_LASTRROW ]

	Lastccol := saved[ GSV_LASTCCOL ]

	GetActive( saved[ GSV_ACTIVEGET ] )

	ReadVar( saved[ GSV_READVAR ] )

	ReadProcName := saved[ GSV_READPROCNAME ]

	ReadProcLine := saved[ GSV_READPROCLINE ]

   allowed := saved[ GSV_ALLOWED ]

return



/***
*	GetReadVar()
* Возвращает имя переменной (READVAR()) GET-объекта.
*/
static func GetReadVar(get)

local name := Upper(get:name)


//#ifdef SUBSCRIPT_IN_READVAR
local i

	/***
  * Следующая часть программы включает в имя переменной, возвращаемого
  * этой функцией, указатель индекса, если переменная - элемент массива.
	*
  * Наличие индекса определяется по встроенной переменной get:subscript
	*
  * Замечание: Нет совместимости с Summer 87
	*/

	if ( get:subscript <> NIL )
		for i := 1 to len(get:subscript)
			name += "[" + ltrim(str(get:subscript[i])) + "]"
		next
	end

//#endif

return (name)



/**********************
*
* системный сервис
*
*/



/***
*   __SetFormat()
*     служебная процедура для SET FORMAT
*/
func __SetFormat(b)
	Format := if ( ValType(b) == "B", b, NIL )
return (NIL)


/***
*	__KillRead()
*   служебная процедура для CLEAR GETS
*/
proc __KillRead()
	KillRead := .t.
return


/***
*	GetActive()
*/
func GetActive(g)
local oldActive := ActiveGet
	if ( PCount() > 0 )
		ActiveGet := g
	end
return ( oldActive )


/***
*	Updated()
*/
func Updated()
return (Updated)


/***
*	ReadExit()
*/
func ReadExit(lNew)
return ( Set(_SET_EXIT, lNew) )


/***
*	ReadInsert()
*/
func ReadInsert(lNew)
return ( Set(_SET_INSERT, lNew) )



/**********************************
*
* Совместимость с dBASE
*
*/


// Координаты SCOREBOARD - области состояния на экране
#define SCORE_ROW		0
#define SCORE_COL		60


/***
*   ShowScoreboard()
*/
static proc ShowScoreboard()

local nRow, nCol


    if ( Set(_SET_SCOREBOARD) )
        nRow := Row()
        nCol := Col()

        SetPos(SCORE_ROW, SCORE_COL)
        DispOut( if(Set(_SET_INSERT), "Вст", "Зам") )  // "Ins","   "
        SetPos(nRow, nCol)
     end

return



/***
*	DateMsg()
*/
static proc DateMsg()

local nRow, nCol


    if ( Set(_SET_SCOREBOARD) )
      nRow := Row()
      nCol := Col()

      SetPos(SCORE_ROW, SCORE_COL)
      DispOut("Ошибка Даты ")
          SetPos(nRow, nCol)

      while ( Nextkey() == 0 )
		end

		SetPos(SCORE_ROW, SCORE_COL)
		DispOut("            ")
        SetPos(nRow, nCol)

	end

return



/***
*   RangeCheck()
*
* Замечание: Для совместимости с 5.00 не используется второй параметр
*/

func RangeCheck(get, junk, lo, hi)

local cMsg, nRow, nCol
local xValue


	if ( !get:changed )
		return (.t.)
	end

	xValue := get:VarGet()

	if ( xValue >= lo .and. xValue <= hi )
    return (.t.)                  // удовлетворяет заданному диапазону
	end

  if ( Set(_SET_SCOREBOARD) )
    cMsg := "Диапазон: " + Ltrim(Transform(lo, "")) + ;
      " - " + Ltrim(Transform(hi, ""))

    if ( Len(cMsg) > MaxCol() )
      cMsg := Substr( cMsg, 1, MaxCol() )
    end

    nRow := Row()
    nCol := Col()

		SetPos( SCORE_ROW, Min(60, MaxCol() - Len(cMsg)) )
		DispOut(cMsg)
    SetPos(nRow, nCol)

		while ( NextKey() == 0 )
		end

		SetPos( SCORE_ROW, Min(60, MaxCol() - Len(cMsg)) )
		DispOut( Space(Len(cMsg)) )
        SetPos(nRow, nCol)

	end

return (.f.)




/***
*   Grow_getlist()
*   Процедура формирования GetList , вызываемая командами @  x,x GET ,@ x,x GET_SHOW
*
* Замечание: Признак "виртуального" GETа - пустая переменная get:name
*
*/
PROC Grow_getlist(g_list,new_gobj)
LOCAL grow:=new_gobj:row,gcol:=new_gobj:col,arrlen:=Len(g_list),subarrlen
LOCAL i:=1,currg_row,currg_col
IF arrlen == 0

   // В cargo первого GET об'екта записываем , какой GET из GetList
   // будет извлечен первым функцией ReadModal() - GetList[1,1]

   IF Empty(new_gobj:name)
      Aadd(new_gobj:cargo,1)
      Aadd(new_gobj:cargo,1)
   ELSE
      new_gobj:cargo := { NIL,NIL,1,1 }
   ENDIF
   g_list := {}
   Aadd(g_list,{new_gobj})
   RETURN
ENDIF
   // GetList является двумерной таблицей , где GET об'екты
   // группируются в колонки , в каждой из которых GET об'екты
   // имеют одинаковое значение get:col , причем отсортированы
   // по возрастанию get:row . Соответственно колонки расположены
   // слево-направо в порядке возрастания get:col
   // Задача функции Grow_getlist() вставить вновь образованный
   // GET об'ект в GetList согласно вышеописанному порядку .

DO WHILE .T.
   currg_col:=g_list[i,1]:col
   DO CASE
      CASE currg_col == gcol
         // Добавить GET об'ект в эту колонку согласно get:row
          j:=1
          subarrlen:=Len( g_list[i] )
          DO WHILE .T.
             currg_row:=g_list[i,1]:row
             DO CASE
                CASE currg_row == grow
                   // Ошибка расположения GETов на экране

                   Tone(100,1)
                   @ 1,1 SAY "У вас GETы налезают один на другой!"
                   Inkey(0)
                   QUIT
                CASE currg_row > grow
                   // Вставить сюда GET об'ект

                   Asize(g_list[i],subarrlen+1)
                   Ains(g_list[i],j)
                   g_list[i,j]:=new_gobj
                   RETURN

                CASE j == subarrlen
                   // Добавить GET об'ект

                   Aadd(g_list[i],new_gobj)
                   RETURN

                OTHERWISE
                   j++
             ENDCASE
          ENDDO
         RETURN

      CASE currg_col > gcol
         // Вставить сюда новую колонку

         Asize(g_list,arrlen+1)
         Ains(g_list,i)
         g_list[i] := {new_gobj}
         RETURN

      CASE i == arrlen
         // Добавить новую колонку

         Aadd(g_list,{new_gobj})
         RETURN

      OTHERWISE
         i++
   ENDCASE
ENDDO

RETURN



/***
*   _V_get_()
*   Процедура формирования виртуального GET об'екта , вызываемая
*   командой @ x,x GET_SHOW
*
* Замечание: Признак "виртуального" GETа - пустая переменная get:name
*/
PROC _V_get_( cblock, g_proc , cbvalid , cbwhen ,grow,gcol)
LOCAL new_gobj:=Getnew(,,,,,)
new_gobj:row:=grow
new_gobj:col:=gcol
new_gobj:preblock:=cbwhen
new_gobj:postblock:=cbvalid
new_gobj:cargo:={cblock,g_proc}
IF cblock<>NIL
   // Если есть процедура,заданная GET_SHOW - выполнить ее

   @ new_gobj:row,new_gobj:col SAY Eval(cblock) COLOR new_gobj:Colorspec
ENDIF
RETURN new_gobj



/***
*   Is_exit_key()
*  Функция , которой удобно пользоваться в процедурах , вызываемых
*  виртуальным GET , когда ожидается прием символа с клавиатуры и
*  если он не должен вызвать переход на другой GET , процедура выполняется,
*  иначе - переход на другой GET.
*  Примечание: см.пример
*/
FUNCTION Is_exit_key(key)
DO CASE
   CASE key==K_UP.OR.key==K_DOWN
      RETURN .T.
   CASE key==K_CTRL_UP.OR.key==K_CTRL_DOWN
      RETURN .T.
   CASE key==K_CTRL_LEFT.OR.key==K_CTRL_RIGHT
      RETURN .T.
   CASE key==K_CTRL_PGUP.OR.key==K_CTRL_PGDN
      RETURN .T.
   CASE key==K_CTRL_HOME.OR.key==K_CTRL_END
      RETURN .T.
   CASE key==K_ENTER.OR.key==K_ESC
      RETURN .T.
   CASE key==K_PGUP.OR.key==K_PGDN
      RETURN .T.
ENDCASE
RETURN .F.