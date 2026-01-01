#include 'box.ch'
#include 'dbedit.ch'
#include 'inkey.ch'
#include 'error.ch'

      clear screen
      set cursor off
      set deleted on

?'Клименко Дмитрий, г. Винница, СП "Импульс Интернэшнл", т. (04322) 2-26-10'

    bshandler:= errorblock({|x|break(x)})

    do while .T.
     begin sequence

     if !used()
      use firms index o_naz
     endif
     use stuff index p_naz new


     recover using error
      if error:gencode == EG_OPEN
       if upper(error:filename) = 'O_NAZ.NTX'
        index on upper(fname) to o_naz
        loop
       elseif upper(error:filename) = 'P_NAZ.NTX'
        index on upper(fname+name) to  p_naz
       else
        alert('Нет базы данных '+error:filename+' !')
        quit
       endif
      endif

     end sequence
     exit
    enddo

     errorblock(bshandler)

      alert('Программа демонстрации возможностей; динамической фильтрации !')


      select firms
      set relation to upper(trim(fname)) into stuff

      alert('Сначала для любой из фирм ; визуализируем штат сотрудников.'+;
      ';Нажимайте <ВК> на требуемой фирме.')

      @ 5,2,18,53 box B_DOUBLE+' ' color 'n/bg'
      @ 5,3 say padc(' ФИРМЫ-ПАРТНЕРЫ: ',50,'═') color 'n/bg'
      setcolor('n/bg,r+/n')
      begk:= .F.
      mdbedit(6,3,17,52,,'ffirms',,{'Название','Тип','Телефон'})


       alert('Теперь для каждой из фирм нужно выбрать сотрудников'+;
             ';этой фирмы, фамилии которых начинаются на букву "К".')
      begk:= .T.
      go top
      mdbedit(6,3,17,52,,'ffirms',,{'Название','Тип','Телефон'})

      alert(' Далее рассмотрим более сложный пример.'+;
            ';Работаем только с отношением ФИРМЫ-ПАРТНЕРЫ.'+;
            ';Необходимо выбрать все фирмы, названия которых начинаются'+;
            ';с буквы "K" либо с буквы "M".')

      seek 'K'
      set relation to
      mdbedit(6,3,17,52,,,,{'Название','Тип','Телефон'},,,,,,;
      'userskip3',{||dbseek('K')},;
      {||dbseek('M'),dbeval(NIL,,{||FNAME = 'M'},,,.T.)})


      alert('Наконец, еще один пример. Работаем только с'+;
            ';отношением СОТРУДНИКИ. Необходимо выбрать всех'+;
            '; сотрудников, фамилии которых начинаются с буквы'+;
            '"К" и работающих в фирмах, начинающихся с буквы "М".')
      setcolor('w/n')
      clear screen
?'Клименко Дмитрий, г. Винница, СП "Импульс Интернэшнл", т. (04322) 2-26-10'
      @ 10,0,21,79 box B_DOUBLE_SINGLE+' ' color 'n/w'
      @ 10,1 say padc(' СОТРУДНИКИ: ',78,'═') color 'n/w'
      setcolor('n/w,w/n')
      select stuff
      eval({||dbseek('M'),if(found(),(__dblocate({||NAME='К'},{||FNAME='M'},,,.T.),;
      if(!found(),(dbgobottom(),dbskip()),)),)})
      mdbedit(11,1,20,78,{'left(fname,50)','name'},,,{'Фирма','Фамилия'},;
      ,,,,,'userskip4',;
      {||dbseek('M'),if(found(),(__dblocate({||NAME='К'},{||FNAME='M'},,,.T.),;
      if(!found(),(dbgobottom(),dbskip()),)),)},;
      {||r_s:= set(_SET_SOFTSEEK,.T.),dbseek('N'),dbskip(-1),;
        skipback(),set(_SET_SOFTSEEK,r_s)})
      setcolor('w/n')



      function ffirms(mode,col,browse)
      local rc,lc
      if mode = DE_EXCEPT
       if lastkey() = K_ENTER
        rc:= savescreen(10,58,21,79)
        @ 10,58,21,79 box B_DOUBLE_SINGLE+' ' color 'n/w'
        @ 10,59 say padc(' СОТРУДНИКИ: ',20,'═') color 'n/w'
        lc:= setcolor('n/w,w/n')
        select stuff
        if begk
         seek upper(FIRMS->FNAME)+'К'
         mdbedit(11,59,20,78,{'name'},,,{'Фамилия'},,,,,,'userskip2',;
         {||dbseek(upper(FIRMS->FNAME)+'К')},;
         {||dbeval(NIL,,{||FNAME == FIRMS->FNAME .and. FNAME = 'К'},,,.T.)})
        else
         mdbedit(11,59,20,78,{'name'},,,{'Фамилия'},,,,,,'userskip1',;
         {||dbseek(trim(upper(FIRMS->FNAME)))},;
         {||dbeval(NIL,,{||FNAME == FIRMS->FNAME},,,.T.)})
        endif
        select firms
        restscreen(10,58,21,79,rc)
        setcolor(lc)
       elseif lastkey() = K_ESC
        return DE_ABORT
       endif
      endif
      return DE_CONT


         function userskip1(x,browse)
         local i:=0
         if x>0 .and. !eof()
          do while i<x
           skip 1
// Проверка выхода за нижнюю границу :
           if  eof() .or. FNAME <> FIRMS->FNAME
            skip -1
            exit
           endif
           i++
          enddo
         elseif x<0
          do while i>x
           skip -1
// Проверка выхода за верхнюю границу :
           if bof()
            if browse:cargo
             browse:rowpos:= -i+1
            endif
            exit
           endif
           if FNAME <> FIRMS->FNAME
            if browse:cargo
             browse:rowpos:= -i+1
            endif
            skip 1
            exit
           endif
           i--
          enddo
         endif
         return i


         function userskip2(x,browse)
         local i:=0
         if x>0
          do while i<x .and. !eof()
           skip 1
// Проверка выхода за нижнюю границу :
           if  eof() .or. FNAME <> 'К' .or. FNAME <> FIRMS->FNAME
            skip -1
            exit
           endif
           i++
          enddo
         elseif x<0
          do while i>x
           skip -1
// Проверка выхода за верхнюю границу :
           if bof()
            if browse:cargo
             browse:rowpos:= -i+1
            endif
            exit
           endif
           if FNAME <> 'К' .or. FNAME <> FIRMS->FNAME
            if browse:cargo
             browse:rowpos:= -i+1
            endif
            skip 1
            exit
           endif
           i--
          enddo
         endif
         return i


         function userskip3(x,browse)
         local i:=0, r
         if x>0 .and. !eof()
          do while i<x
           skip 1
// Проверка выхода за нижнюю границу :
           if  eof() .or. FNAME > 'M'
            skip -1
            exit
// Проверка выхода за букву 'K' :
           elseif FNAME > 'K' .and. FNAME < 'M'
            r:= recno()
            seek 'M'
// Если на букву 'M' вообще нет названий :
            if !found()
// Возврат на предыдущую позицию :
             goto r
             skip -1
             exit
            endif
           endif
           i++
          enddo
         elseif x<0
          do while i>x
           skip -1
// Проверка выхода за верхнюю границу :
           if bof()
            if browse:cargo
             browse:rowpos:= -i+1
            endif
            exit
           elseif FNAME < 'K'
            if browse:cargo
             browse:rowpos:= -i+1
            endif
            skip
            exit
// Проверка выхода за букву 'M' :
           elseif FNAME > 'K' .and. FNAME < 'M'
            r:= recno()
            set softseek ON
            seek 'L'
            set softseek OFF
            skip -1
// Если на букву 'K' вообще нет названий :
            if FNAME <> 'K'
             if browse:cargo
              browse:rowpos:= -i+1
             endif
             goto r
             skip
             exit
            endif
           endif
           i--
          enddo
         endif
         return i

         function userskip4(x,browse)
         local i:=0, r
         if x>0
          do while i<x .and. !eof()
           skip
           if eof() .or. FNAME <> 'M'
            skip -1
            exit
// Если фамилия не начинается на 'К', то переходим к другой фирме :
           elseif NAME <> 'К'
            r:= recno()
            LOCATE REST FOR NAME='К' WHILE FNAME='M'
// Если фамилий на 'К' больше нет, то возвращаемся :
            if !found()
             goto r
             skip -1
             exit
            endif
           endif
           i++
          enddo
         elseif x<0
          do while i>x
           skip -1
           if bof()
            exit
           elseif FNAME <> 'M'
            skip
            exit
           elseif NAME <> 'К'
            r:= recno()
// Приходится работать "вручную":
            do while NAME <> 'К' .and. FNAME = 'M'
             skip -1
            enddo
            if FNAME <> 'M'
             goto r
             skip
             exit
            endif
           endif
           i--
          enddo
         endif
         return i

     procedure skipback
     local r
      do while NAME <> 'К' .and. FNAME = 'M'
       skip -1
      enddo
// Если не найдено, идем на конец файла:
      if FNAME <> 'M'
       go bottom
       skip
      endif
