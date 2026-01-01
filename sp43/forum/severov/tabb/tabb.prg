*****
*
*       TABB.prg
*	Illustration of TBROWSE and GET objects
*	Copyright (c) 1990 Nantucket Corp.  All rights reserved.
*
*       Павел Северов   ИФЗ АH СССР   1991
*
*	Note:  compile with /n/w/a
*

#include "inkey.ch"
#include "setcurs.ch"
#include "box.ch"


#define MY_HSEP		"═╤═"
#define MY_CSEP		" │ "

****
*       TABB <dbf> [<index>]
*

func tabb(datafile, indexfile)

	if Valtype(datafile) == "U"
		?
                ? "            ┌───────────────┐"
                ? "            │ TABLE BROWSER │"
                ? "            └───────────────┘"
                ?
                ? "Must enter name of data file on command line."
                ? "   Example:"
                ? "             TABB  EXAMPLE.DBF"
                ? "             TABB  EXAMPLE.DBF  INDEX.NTX"
                ?
                QUIT

	end

	if .not. (File(datafile) .or. File(datafile + ".dbf"))
		?
		? "File not found."
		?
                QUIT

	end

        IF ISCOLOR()
          SetColor("W/B, B/W, W, W, B/W")
        ELSE
          SetColor("W/N, N/W, W, W, N/W")
        ENDIF

        SET DELETED ON
	CLEAR SCREEN
        @ 0,10 SAY "TABLE BROWSER  (Nantucket Corp. + Pavel Severov 1991)"
        @ MaxRow(),0 SAY "F4-FullScrEd F6-MoveToPocket F7-CopyToPocket F8-CopyFromPocket CTRL+F10-DelRow"

	* file exists
	if Valtype(indexfile) == "C" .and.;
	   (File(indexfile) .or. File(indexfile + IndexExt()))
		USE (datafile) INDEX (indexfile)

	else
		USE (datafile)

	end

        SET DATE FORMAT "dd.mm.yy"

	MyBrowse(2, 0, MaxRow() - 2, MaxCol())

	SET COLOR TO
	@ MaxRow(), 0 CLEAR


PACK
CLEAR SCREEN
RETURN(NIL)

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
                        @ 0,0 SAY "  Ctrl+W - save and exit   ESC - exit without save                              "
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

