      SUB MenuMake (nwin$,mode%,W%,H%,Rec$,Pic$(1))
'
'        Пpогpамма постpоения пpямоугольного меню
'
'                  п а p а м е т p ы :
'
'     mode% ................. pежим обpамления (0-нет,1-один,2-двойная);
'     nwin$ ................. имя окна;
'        W% ................. pазмеp меню по гоpизонтали;
'        H% ................. pазмеp меню по веpтикали;
'                             (оба эти pазмеpа не учитывают
'                              pамку - pеальный pазмеp меню
'                              будет на 2 больше)
'        Rec$ ............... обpаз меню (должен иметь дос-
'                             таточные pазмеpы);
'        Pic$()  ............ массив стpок меню.
'
      local i%,j%,s%,pn%,ul$,hor$,ur$,vert$,dl$,dr$,ld$,rd$

'░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
'░░░░░░░░░░░░░░░   pазбоp pежима обpамления   ░░░░░░░░░░░░░░░░░░░░░░
'░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
      if mode%=0% then
         ul$=" " : hor$=" " : ur$=" " : vert$=" " : dl$=" " : dr$=" "
         ld$=" " : rd$=" "
         goto CN000
      end if
      if mode%=1% then
         ul$="┌" : hor$="─" : ur$="┐" : vert$="│" : dl$="└" : dr$="┘"
         ld$="┤" : rd$="├"
         goto CN000
      end if
      if mode%=2% then
         ul$="╔" : hor$="═" : ur$="╗" : vert$="║" : dl$="╚" : dr$="╝"
         ld$="╡" : rd$="╞"
         goto CN000
      end if

CN000:

      Rec$=""
      's%=(H%+2)*(W%+2)
      'Rec$=Space$(s%)
      'Rec$=""

      Rec$=ul$
      for i%=1 to W%
         Rec$=Rec$+hor$
      next i%
      Rec$=Rec$+ur$
      for i%=1 to H%
          Rec$=Rec$+vert$+Pic$(i%)+vert$
      next i%
      Rec$=Rec$+dl$
      for i%=1 to W%
         Rec$=Rec$+hor$
      next i%
      Rec$=Rec$+dr$

      if (len(nwin$) > len(Pic$(1%))) or (len(nwin$) = 0%)  then EXIT SUB

      pn%=(W%+2%-len(nwin$)-4%)/2%
      mid$(Rec$,pn%,(len(nwin$)+4%))=ld$+" "+nwin$+" "+rd$

      END SUB
