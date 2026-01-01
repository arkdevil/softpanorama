#include "dbedit.ch"
#include "inkey.ch"

   procedure mdbedit(top,left,bottom,right,columns,userfunc,saypict,;
                     colheaders,headingsep,colsep,footingsep,colfooting,;
                     frozen,skipfunc,gotopblock,gobottomblock,fixed)

    local i, rc, nkey, utype, column, baction, calluser, nkeyx
    local  colhtype, saytype, headstype, colstype, footstype, colftype, fixedtype
    private dbbrowse, rec_no, getold

// Проверяем экранный диапазон :

    if top = NIL
     top:= 0
    elseif valtype(top) <> 'N'
     return
    endif
    if left = NIL
     left:= 0
    elseif valtype(left) <> 'N'
     return
    endif
    if bottom = NIL
     bottom:= maxrow()
    elseif valtype(bottom) <> 'N'
     return
    endif
    if right = NIL
     right:= maxcol()
    elseif valtype(right) <> 'N'
     return
    endif
    if top<0 .or. left<0 .or. bottom<0 .or. top<0 .or. ;
       right<= left .or. bottom<= top
     return
    endif

// Проверяем и, если надо, строим массив столбцов :

    if columns = NIL
     columns:= {}
     for i:= 1 to fcount()
      aadd(columns,fieldname(i))
     next
    elseif valtype(columns) = 'A'
     for i:= 1 to len(columns)
      if valtype(columns[i]) <> 'C'
       adel(columns,i)
       i--
      endif
     next
    else
     return
    endif

// Строим блок пользовательской функции (если имеется) :

    utype:= valtype(userfunc)
    if utype = 'C'
     calluser:= &('{|mode|'+userfunc+'(mode,dbbrowse:colpos,dbbrowse)}')
    endif

// Предопределяем типы параметров для ускорения работы :

    colhtype:= valtype(colheaders)
    saytype:= valtype(saypict)
    headstype:= valtype(headingsep)
    colstype:= valtype(colsep)
    footstype:= valtype(footingsep)
    colftype:= valtype(colfooting)
    fixedtype:= valtype(fixed)

//  Создаем экземпляр объекта TBROWSE:

    dbbrowse:= tbrowsedb(top,left,bottom,right)

// Строим объекты - столбцы и добавляем к экземпляру объекта TBROWSE :

    for i:= 1 to len(columns)
     column:= tbcolumnnew(if(colhtype = 'A',;
              if(i<=len(colheaders),colheaders[i],''),if(colhtype = 'C',;
              colheaders,columns[i])),;
              if(saytype = 'A',if(i<=len(saypict),;
              &('{||transform('+columns[i]+',"'+saypict[i]+'")}'),;
              &('{||'+columns[i]+'}')),;
              if(saytype = 'C',;
              &('{||transform('+columns[i]+',"'+saypict+'")}'),;
              &('{||'+columns[i]+'}'))))
     column:headsep:= if(headstype = 'A',if(i<=len(headingsep),;
                         headingsep[i],'═'),if(headstype= 'C',;
                         headingsep,'═'))
     column:colsep:= if(colstype= 'A',if(i<=len(colsep),;
                         colsep[i],'│'),if(colstype = 'C',;
                         colsep,'│'))
     column:footsep:= if(footstype = 'A',if(i<=len(footingsep),;
                         footingsep[i],''),if(footstype = 'C',;
                         footingsep,''))
     column:footing:= if(colftype= 'A',if(i<=len(colfooting),;
                         colfooting[i],''),if(colftype = 'C',;
                         colfooting,''))

     dbbrowse:addcolumn(column)
    next

// Устанавливаем блоки переходов :

    dbbrowse:cargo:= .F.
    if(valtype(frozen) = 'N',dbbrowse:freeze:= frozen,)
    if valtype(skipfunc) = 'C'
       dbbrowse:skipblock:= &('{|x|'+skipfunc+'(x,dbbrowse)}')
    else
       dbbrowse:skipblock:= { |x| Skipper(x, dbbrowse) }
    endif
    if valtype(gotopblock) = 'B'
      dbbrowse:gotopblock:= gotopblock
    endif
    if valtype(gobottomblock) = 'B'
      dbbrowse:gobottomblock:= gobottomblock
    endif

// Вперед !

      if fixedtype = 'N' .and. dbbrowse:colpos <= fixed
       dbbrowse:colpos:= fixed+1
      endif
      if utype <> 'C'
       dbbrowse:cargo:= .F.
      endif

// Инициирующий запуск пользовательской функции :

      if utype = 'C'
       rec_no:= recno()
       rc:= eval(calluser,DE_INIT)
       if !evalcode(rc,dbbrowse)
        return
       endif
      endif

// Главный цикл:

      do while .T.

// Проверяем наличие управляющей клавиши в буфере :

       nkey:= nextkey()
       if !(nkey <> 0 .and. ;
       (nkey = K_DOWN .or. nkey = K_UP .or. nkey = K_PGDN .or. nkey = K_PGUP ;
        .or. nkey = K_CTRL_PGDN .or. nkey = K_CTRL_PGUP .or. nkey = K_LEFT ;
        .or. nkey = K_RIGHT .or. nkey = K_CTRL_RIGHT .or. nkey = K_CTRL_LEFT ;
        .or. nkey = K_CTRL_HOME .or. nkey = K_CTRL_END .or. nkey = K_END ;
        .or. nkey = K_HOME ))

// Цикл стабилизации :

        do while !dbbrowse:stabilize()
        enddo
        rec_no:= recno()
        getold:= eval(dbbrowse:getcolumn(dbbrowse:colpos):block)

// Вызов пользовательской функции по результатам стабилизации (если нужно) :

        if lastrec() = 0 .and. utype = 'C'
         rc:= eval(calluser,DE_EMPTY)
         if !evalcode(rc,dbbrowse)
          return
         endif
        endif
        if dbbrowse:hittop .and. utype = 'C'
         rc:= eval(calluser,DE_HITTOP)
         if !evalcode(rc,dbbrowse)
          return
         endif
        endif
        if dbbrowse:hitbottom .and. utype = 'C'
         rc:= eval(calluser,DE_HITBOTTOM)
         if !evalcode(rc,dbbrowse)
          return
         endif
        endif
       endif
        if (nkey:=inkey()) = 0

// Вызов пользовательской функции в режиме DE_IDLE :

         if utype = 'C'
          rc:= eval(calluser,DE_IDLE)
          if !evalcode(rc,dbbrowse)
           return
          endif
         endif
         nkey:= inkey(0)
        endif
       do case

// Обработка ранее назначенных клавиш :

        case (baction:= setkey(nkey)) != NIL
         eval(baction)
         loop

// Обработка стандартных клавиш навигации :

        case nkey = K_DOWN
         dbbrowse:down()
        case nkey = K_UP
         dbbrowse:up()
        case nkey = K_PGDN
         dbbrowse:pagedown()
        case nkey = K_PGUP
         dbbrowse:pageup()
        case nkey = K_CTRL_PGDN
         dbbrowse:gobottom()
        case nkey = K_CTRL_PGUP
         dbbrowse:gotop()
        case nkey = K_LEFT
         dbbrowse:left()
         if fixedtype = 'N' .and. dbbrowse:colpos = fixed
          dbbrowse:right()
         endif
        case nkey = K_RIGHT
         dbbrowse:right()
        case nkey = K_CTRL_RIGHT
         dbbrowse:panright()
        case nkey = K_CTRL_LEFT
         dbbrowse:panleft()
         if fixedtype = 'N' .and. dbbrowse:colpos = fixed
          dbbrowse:right()
         endif
        case nkey = K_CTRL_HOME
         dbbrowse:panhome()
         if fixedtype = 'N' .and. dbbrowse:colpos = fixed
          dbbrowse:right()
         endif
        case nkey = K_CTRL_END
         dbbrowse:panend()
        case nkey = K_END
         dbbrowse:end()
        case nkey = K_HOME
         dbbrowse:home()
         if fixedtype = 'N' .and. dbbrowse:colpos = fixed
          dbbrowse:right()
         endif
        case (nkey = K_ESC .or. nkey = K_ENTER) .and. utype <> 'C'
         return
        otherwise

// Обработка исключительных клавиш :

         if utype = 'C'
          rc:= eval(calluser,DE_EXCEPT)

// Оценка значений возврата :

          if rc == DE_REFRESH
           dbbrowse:cargo:= .T.
           dbbrowse:refreshall()
           dbbrowse:cargo:= .F.
          elseif rc == DE_CONT

// "Освежить", если переместился указатель :

           if recno() <> rec_no
            dbbrowse:cargo:= .T.
            dbbrowse:refreshall()
            dbbrowse:cargo:= .F.
           else

// "Освежить" текущую запись, если произошли изменения :

            if getold <> eval(dbbrowse:getcolumn(dbbrowse:colpos):block)
             dbbrowse:refreshcurrent()
            endif
           endif
          elseif rc == DE_ABORT
           return
          endif
         endif
       endcase
      enddo


// Функция обработки значений возврата пользовательской функции :

      static function evalcode(rc,browse)
       local need_st:= .F.
          if rc == DE_ABORT
           return .F.
          elseif rc == DE_REFRESH
           browse:cargo:= .T.
           browse:refreshall()
           browse:cargo:= .F.
           need_st:= .T.
          elseif rc == DE_CONT
           if recno() <> rec_no
            browse:cargo:= .T.
            browse:refreshall()
            browse:cargo:= .F.
            need_st:= .T.
           else
            if getold <> eval(browse:getcolumn(browse:colpos):block)
             browse:refreshcurrent()
             need_st:= .T.
            endif
           endif
          endif
          if need_st
           do while !browse:stabilize()
           enddo
          endif
          return .T.

// Стандартная функция перехода:

      static function skipper(x,browse)
      local i:=0
      if x>0
       do while i<x .and. !eof()
        skip 1
        if  eof()
         skip -1
         exit
        endif
        i++
       enddo
      elseif x<0
       do while i>x
        skip -1
        if bof()
         if browse:cargo
          browse:rowpos:= -i+1
         endif
         exit
        endif
        i--
       enddo
      endif
     return i
