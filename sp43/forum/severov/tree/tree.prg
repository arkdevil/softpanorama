**********************************************************
*                                                        *
*                    T R E E   -   1991                  *
*                                                        *
*                Павел Северов   ИФЗ АH СССР             *
*                                                        *
**********************************************************

#define iName   1
#define iFather 2
#define iMother 3
#define iBranch 4

SET TALK OFF
SET STAT OFF
SET SCOR OFF
SET PROC TO Tree
SET DELE ON
PUBL Anc[20],EndBranch[20],Lev,Bra,MaxBranch

DO Menu

SET COLO TO
CLEAR
RETURN

*****************************************************************************

PROC menu

CLEAR

level1 = 1                 && memvar for 1st menu
level2 = 1                 && memvar for nested menus

SET MESSAGE TO 24          && display MESSAGEs on line 24

DO WHILE (level1 <> 0)

IF ISCOLOR()
  SetColor("W/B, B/W, W, W, B/W")
ELSE
  SetColor("W/N, N/W, W, W, N/W")
ENDIF

DO Title

  @ 16,10 PROM " ВВОД "        MESS "                    Ввод новой информации в базу данных"
  @ 16,25 PROM " ДЕРЕВО "      MESS "           Построение генеалогического дерева по введенным данным"
  @ 16,40 PROM " КОММЕНТАРИИ " MESS "                          Вывод комментариев"
  @ 16,55 PROM " ОЧИСТКА "     MESS "           Уничтожение старой и создание новой, пустой базы данных"

  MENU to level1
  IF (level1=0)
    RETURN
  ENDIF

  IF (level1=1)
    @ 18,level1*10 PROMPT " Данные сортировать не надо                "
    @ 19,level1*10 PROMPT " Хочу редактировать отсортированные данные "
    @ 20,level1*10 PROMPT " Просто восстанови, пожалуйста, индексы    "
    level2=1
    MENU TO level2
    IF (level2=1)
      USE Tree INDEX Tree-N,Tree-F,Tree-M,Tree-B
      SET ORDER TO 0
      SET DELE OFF
      GO TOP
      RECALL WHILE .T.
      GO TOP
      DO TreeBrow
      ENDIF
    IF (level2=2)
      USE Tree INDEX Tree-N,Tree-F,Tree-M,Tree-B
      SET ORDER TO iName
      SET DELE OFF
      GO TOP
      RECALL WHILE .T.
      GO TOP
      DO TreeBrow
      ENDIF
    IF (level2=3)
      USE Tree
      SET DELE OFF
      GO TOP
      RECALL WHILE .T.
      INDEX ON Name   TO Tree-N
      INDEX ON Father TO Tree-F
      INDEX ON Mother TO Tree-M
      INDEX ON Branch TO Tree-B
      USE Tree INDEX Tree-N,Tree-F,Tree-M,Tree-B
      ENDIF
    ENDIF

  IF (level1=2)
    @ 18,level1*10+4 PROMPT " Вывод на экран         "
    @ 19,level1*10+4 PROMPT " Вывод на печать        "
    @ 20,level1*10+4 PROMPT " Запись в файл TREE.TXT "
    level2=1
    MENU TO level2
    IF (level2=1)
      CLEAR
      DO MakeTree
      @ 24,33
      WAIT "Hажми любую клавишу..."
      ENDIF
    IF (level2=2)
      SET PRINTER ON
      SET DEVICE TO PRINTER
      SET CONSOLE OFF
      DO MakeTree
      ?
      SET PRINTER OFF
      SET DEVICE TO SCREEN
      SET CONSOLE ON
      ENDIF
    IF (level2=3)
      SET PRINTER TO tree.txt
      SET DEVICE TO PRINTER
      SET PRINTER ON
      SET CONSOLE OFF
      DO MakeTree
      ?
      SET PRINTER OFF
      SET PRINTER TO
      SET DEVICE TO SCREEN
      SET CONSOLE ON
      ENDIF
    ENDIF

  IF (level1=3)
    @ 18,level1*10+9 PROMPT " Вывод на экран            "
    @ 19,level1*10+9 PROMPT " Вывод на печать           "
    @ 20,level1*10+9 PROMPT " Запись в файл COMMENT.TXT "
    level2=1
    MENU TO level2
    IF (level2=1)
      CLEAR
      DO GetComm
      @ 24,33
      WAIT "Hажми любую клавишу..."
      ENDIF
    IF (level2=2)
      SET PRINTER ON
      SET DEVICE TO PRINTER
      SET CONSOLE OFF
      DO GetComm
      ?
      SET PRINTER OFF
      SET DEVICE TO SCREEN
      SET CONSOLE ON
      ENDIF
    IF (level2=3)
      SET PRINTER TO comment.txt
      SET DEVICE TO PRINTER
      SET PRINTER ON
      SET CONSOLE OFF
      DO GetComm
      ?
      SET PRINTER OFF
      SET PRINTER TO
      SET DEVICE TO SCREEN
      SET CONSOLE ON
      ENDIF
    ENDIF

  IF (level1=4)
    @ 18,level1*10+5 PROMPT " Я ошибся, вернись назад   "
    @ 19,level1*10+5 PROMPT " Я действительно это хочу! "
    level2=1
    MENU TO level2
    IF (level2=2)
      CREATE TempStru
      USE TempStru
      APPEND BLANK
      REPLACE Field_name WITH "Name"   ,Field_type WITH "C",Field_len WITH 38,Field_dec  WITH 0
      APPEND BLANK
      REPLACE Field_name WITH "Birth"  ,Field_type WITH "C",Field_len WITH 4 ,Field_dec  WITH 0
      APPEND BLANK
      REPLACE Field_name WITH "Death"  ,Field_type WITH "C",Field_len WITH 4 ,Field_dec  WITH 0
      APPEND BLANK
      REPLACE Field_name WITH "Father" ,Field_type WITH "C",Field_len WITH 38,Field_dec  WITH 0
      APPEND BLANK
      REPLACE Field_name WITH "Mother" ,Field_type WITH "C",Field_len WITH 38,Field_dec  WITH 0
      APPEND BLANK
      REPLACE Field_name WITH "Branch" ,Field_type WITH "N",Field_len WITH 3 ,Field_dec  WITH 0
      APPEND BLANK
      REPLACE Field_name WITH "Comment",Field_type WITH "M",Field_len WITH 10,Field_dec  WITH 0
      CLOSE
      CREATE Tree FROM TempStru
      ERASE TempStru.dbf

      USE Tree
      APPEND BLANK
      REPLACE Comment WITH "                                        "
      INDEX ON Name   TO Tree-N
      INDEX ON Father TO Tree-F
      INDEX ON Mother TO Tree-M
      INDEX ON Branch TO Tree-B
      USE Tree INDEX Tree-N,Tree-F,Tree-M,Tree-B
      ENDIF
    ENDIF

  @ 15,0 CLEAR
ENDDO

RETURN

**************************************************************************

PROC pshik
CLEAR
@ 12,33
WAIT "                                  П  Ш  И  К . . .    "
RETURN

************************************************************************

PROC Title
CLEAR
TEXT
                     В ПОМОЩЬ ИССЛЕДОВАТЕЛЯМ РОДОСЛОВИЙ
         ╔═════════════════════════════════════════════════════════╗
         ║▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒║
         ║▒▒▒▒▒▒▒ Павел Северов 1991  ИФЗ АН СССР 254-93-35 ▒▒▒▒▒▒▒║
         ║▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒║
         ║▒▒▒▒▒▒▒╔═══════════════╗▒▒▒   ▒▒▒╔═══════════════╗▒▒▒▒▒▒▒║
         ║▒▒▒▒▒▒▒║               ║▒▒▒ T ▒▒▒║               ║▒▒▒▒▒▒▒║
         ║▒▒▒▒▒▒▒║               ║▒▒▒ R ▒▒▒║               ║▒▒▒▒▒▒▒║
         ╚═══════╝               ║▒▒▒ E ▒▒▒║               ╚═══════╝
                                 ║▒▒▒ E ▒▒▒║
                       ╔═════════╝▒▒▒   ▒▒▒╚═════════╗
                       ║▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒║
                       ╚═════════════════════════════╝

ENDTEXT
RETURN

*****************************************************************************

PROC GetComm
USE Tree
SET DELE OFF
GO TOP
DO WHILE !EOF()
  IF LEN(Comment)>1
    ? "---------------------------------------------------------------------"
    ? ALLTRIM(Name),ALLTRIM(BIRTH)+"-"+ALLTRIM(DEATH)
    ? Comment
    ENDIF
  SKIP
  ENDDO
? "---------------------------------------------------------------------"

RETURN

*****************************************************************************

PROC MakeTree
USE Tree INDEX Tree-N,Tree-F,Tree-M,Tree-B
SET DELE OFF
GO TOP
RECALL WHILE .T.
Shift="    "
SET ORDER TO iBranch
Bra=1
GO BOTTOM
MaxBranch=Branch
? "-------------------------------------------------------"

DO WHILE.T.
  SET ORDER TO iBranch
  SET DELE OFF
  SET SOFTSEEK ON
  SEEK Bra
  Bra=Branch
  SET SOFTSEEK OFF
  SET DELE ON
  IF EOF()
    EXIT
    ENDIF
  DO Branch
  Bra=Bra+1
  IF Bra>MaxBranch
    EXIT
    ENDIF
  ENDDO

RETURN

**************************************************************

PROC Branch
Lev=1
Anc[Lev]=Name
EndBranch[Lev]=.F.
DO Show

DO WHILE .T.
  IF.NOT.EndBranch[Lev]
    DO Child
    ENDIF
  IF.NOT.FOUND().OR.EndBranch[Lev]
    IF Lev=1
      ? "-------------------------------------------------------"
      EXIT
      ENDIF
    Lev=Lev-1
    LOOP
    ENDIF
  Lev=Lev+1
  Anc[Lev]=Name
  EndBranch[Lev]:=Branch=(-Bra)
  DELETE
  DO Show
  ENDDO

SET DELE OFF
GO TOP
RECALL WHILE .T.
RETURN

**************************************************************

PROC Show
PRIV Fat,Mot
SET DELETED OFF
Fat=Father
Mot=Mother
i=1
? STR(Lev,2)+" "
DO WHILE i<Lev
  ?? Shift
  i=i+1
  ENDDO
?? ALLTRIM(Name),ALLTRIM(BIRTH)+"-"+ALLTRIM(DEATH)+" ("+ALLTRIM(Father)
SET ORDER TO iName

SEEK Fat
IF FOUND()
  ?? " "+ALLTRIM(BIRTH)+"-"+ALLTRIM(DEATH)
  ENDIF

?? " + "+ALLTRIM(Mot)
SEEK Mot
IF FOUND()
  ?? " "+ALLTRIM(BIRTH)+"-"+ALLTRIM(DEATH)
  ENDIF
?? ")"

SET DELETED ON
RETURN

**************************************************************

PROC Child
SET ORDER TO iFather
SEEK Anc[Lev]
IF .NOT.FOUND()
  SET ORDER TO iMother
  SEEK Anc[Lev]
  ENDIF
RETURN

**********************************************************
**********************************************************

#include "inkey.ch"
#include "setcurs.ch"
#include "box.ch"


#define MY_HSEP		"═╤═"
#define MY_CSEP		" │ "

PROC TreeBrow

        SET DELETED ON
	CLEAR SCREEN
        @ 0,0 SAY        "поле BRANCH - основатели ветвей (N:начало ветви, [-N:ветвь ниже не продожать])"
        @ MaxRow(),0 SAY " F4-ЭкрРедакт F6-УбрВКарман  F7-КопВКарман F8-КопИзКармана  CTRL+F10-УбрСтроку"

        SET DATE FORMAT "dd.mm.yy"

	MyBrowse(2, 0, MaxRow() - 2, MaxCol())

	*SET COLOR TO
	@ MaxRow(), 0 CLEAR


PACK
*CLEAR SCREEN
return (NIL)


************************
***
*	MyBrowse()
*

func MyBrowse(nTop, nLeft, nBottom, nRight)
local b, column, cType, n
local cColorSave, nCursSave
local lMore, nKey, lAppend
local Pocket, CurField


	/* make new browse object */
	b := TBrowseDB(nTop, nLeft, nBottom, nRight)

	/* default heading and column separators */
        b:headSep := MY_HSEP
	b:colSep := MY_CSEP

	/* add custom 'skipper' (to handle append mode) */
	b:skipBlock := {|x| Skipper(x, lAppend)}

	/* colors */
        IF ISCOLOR()
          b:colorSpec := "W/B, W/B, W/B, B/W, W/B, B/W, W/B, B/W"
        ELSE
          b:colorSpec := "W/N, W/N, W/N, N/W, W/N, N/W, W/N, N/W"
        ENDIF

	/* add a column for recno() */
	column := TBColumnNew( "  Rec #", {|| Recno()} )
	b:addColumn(column)

	/* add a column for each field in the current workarea */
	for n = 1 to FCount()

		/* make the new column */
		column := TBColumnNew( 	FieldName(n), ;
                              FieldWBlock(FieldName(n), Select()) )


		/* evaluate the block once to get the field's data type */
		cType := ValType( Eval(column:block) )


		/* if numeric, use a color block to highlight negative values */
		if ( cType == "N" )
			column:defColor := {5, 6}
			column:colorBlock := {|x| if( x < 0, {7, 8}, {5, 6} )}

		else
			column:defColor := {3, 4}

		end

		b:addColumn(column)
	next


	/* freeze leftmost column (recno) */
	b:freeze := 1


        @ nTop-1, nLeft-1,nBottom+1, nRight+1 BOX B_SINGLE

        /* make a window shadow
	cColorSave := SetColor("W/N")
	@ nTop+1, nLeft+1 CLEAR TO nBottom+1, nRight+1
	SetColor("N/N")
	@ nTop, nLeft CLEAR TO nBottom, nRight
        SetColor(cColorSave) */


	nCursSave := SetCursor(0)
	lAppend := .f.

	lMore := .t.
	while (lMore)

		/* don't allow cursor to move into frozen columns */
		if ( b:colPos <= b:freeze )
			b:colPos := b:freeze + 1
		end

		/* stabilize the display */
		while ( !b:stabilize() )
			nKey := InKey()
			if ( nKey != 0 )
                                exit  /* (abort if a key is waiting) */
			end
		end


		if ( b:stable )
			/* display is stable */
			if ( b:hitBottom .and. !lAppend )
				/* banged against EOF; go into append mode */
				lAppend := .t.
				nKey := K_DOWN

			else
				if ( b:hitTop .or. b:hitBottom )
					Tone(125, 0)
				end

				/* everything's done; just wait for a key */
				nKey := InKey(0)

			end
		end


		/* process key */
		do case
		case ( nKey == K_DOWN )
			b:down()

		case ( nKey == K_UP )
			b:up()

			if ( lAppend )
				lAppend := .f.
				b:refreshAll()
			end

		case ( nKey == K_PGDN )
			b:pageDown()

		case ( nKey == K_PGUP )
			b:pageUp()
			if ( lAppend )
				lAppend := .f.
				b:refreshAll()
			end

		case ( nKey == K_CTRL_PGUP )
			b:goTop()
			lAppend := .f.

		case ( nKey == K_CTRL_PGDN )
			b:goBottom()
			lAppend := .f.

		case ( nKey == K_RIGHT )
			b:right()

		case ( nKey == K_LEFT )
			b:left()

		case ( nKey == K_HOME )
			b:home()

		case ( nKey == K_END )
			b:end()

		case ( nKey == K_CTRL_LEFT )
			b:panLeft()

		case ( nKey == K_CTRL_RIGHT )
			b:panRight()

		case ( nKey == K_CTRL_HOME )
			b:panHome()

		case ( nKey == K_CTRL_END )
			b:panEnd()

		case ( nKey == K_ESC )
			lMore := .f.

                case ( nKey == K_RETURN )
			DoGet(b, lAppend)

                case ( nKey == K_F4 )
                      CurField:=FIELD(b:colPos-1)
                      IF ValType(&CurField)=="C".OR.ValType(&CurField)=="M"
                        SAVE SCREEN
                        SET CURSOR ON
                        CurField:=FIELD(b:colPos-1)
                        if ( lAppend .and. Recno() == LastRec() + 1 )
                          APPEND BLANK
                          end
                        @ 0,0 SAY "  Ctrl+W - записать и выйти  ESC - выйти без записи                              "
                        @ 1,-1,MaxRow()+2,MaxCol()+1 BOX B_SINGLE
                        REPLACE &CurField WITH MEMOEDIT(&CurField,nTop,,MaxRow())
                        RESTORE SCREEN
                        SET CURSOR OFF
                        b:refreshCurrent()
                      ENDIF

                case ( nKey == K_F6 )
                        CurField:=FIELD(b:colPos-1)
                        Pocket:=&CurField
                        DO CASE
                        CASE Valtype(Pocket)=="N"
                          REPLACE &CurField WITH 0
                        CASE Valtype(Pocket)=="D"
                          REPLACE &CurField WITH CTOD("")
                        CASE Valtype(Pocket)=="L"
                          REPLACE &CurField WITH .F.
                        OTHERWISE
                          REPLACE &CurField WITH ""
                          ENDCASE
                        b:refreshCurrent()

                case ( nKey == K_F7 )
                        CurField:=FIELD(b:colPos-1)
                        Pocket:=&CurField

                case ( nKey == K_F8 )
                      CurField:=FIELD(b:colPos-1)
                      if Valtype(Pocket)==Valtype(&CurField)
                        if ( lAppend .and. Recno() == LastRec() + 1 )
                          APPEND BLANK
                          end
                        REPLACE &CurField WITH Pocket
                        b:refreshCurrent()
                        end

                case ( nKey == K_CTRL_F10 )
                        DELETE
                        b:refreshAll()

                otherwise
                        CurField:=FIELD(b:colPos-1)
                        Pocket:=&CurField
                        IF Valtype(Pocket)=="M"
                          CLEAR TYPEAHEAD
                        ELSE
                          KEYBOARD( Chr(nKey) )
                          DoGet(b, lAppend)
                        ENDIF

		end

	end

	SetCursor(nCursSave)

return (.t.)


****
*	Skipper()
*

func Skipper(n, lAppend)
local i

	i := 0
	if ( LastRec() != 0 )
		if ( n == 0 )
			SKIP 0

		elseif ( n > 0 .and. Recno() != LastRec() + 1 )
			while ( i < n )
				SKIP 1
				if ( Eof() )
					if ( lAppend )
						i++
					else
						SKIP -1
					end

					exit
				end

				i++
			end

		elseif ( n < 0 )
			while ( i > n )
				SKIP -1
				if ( Bof() )
					exit
				end

				i--
			end
		end
	end

return (i)


****
*	DoGet()
*
func DoGet(b, lAppend)
local bInsSave, lScoreSave, lExitSave
local column, get, nKey


	/* make sure browse is stable */
	while ( !b:stabilize() ) ; end


	/* if confirming new record, append blank */
	if ( lAppend .and. Recno() == LastRec() + 1 )
		APPEND BLANK
	end


	/* save state */
	lScoreSave := Set(_SET_SCOREBOARD, .f.)
	lExitSave := Set(_SET_EXIT, .t.)
	bInsSave := SetKey(K_INS)

	/* set insert key to toggle insert mode and cursor */
	SetKey( K_INS, ;
           {|| SetCursor( if(ReadInsert(!ReadInsert()), SC_NORMAL, SC_INSERT))};
             )

	/* initial cursor setting */
	SetCursor( if(ReadInsert(), SC_INSERT, SC_NORMAL) )


	/* get column object from browse */
	column := b:getColumn(b:colPos)

	/* create a corresponding GET */
	get := GetNew(Row(), Col(), column:block, column:heading,, b:colorSpec)

	/* read it */
	ReadModal( {get} )


	/* restore state */
	SetCursor(0)
	Set(_SET_SCOREBOARD, lScoreSave)
	Set(_SET_EXIT, lExitSave)
	SetKey(K_INS, bInsSave)


	/* force redisplay of current row */
	b:refreshCurrent()


	/* check exit key */
	nKey := LastKey()
	if ( nKey == K_UP .or. nKey == K_DOWN .or. ;
		nKey == K_PGUP .or. nKey == K_PGDN )

		KEYBOARD( Chr(nKey) )
	end

return (NIL)


