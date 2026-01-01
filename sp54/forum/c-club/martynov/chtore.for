	subroutine CHTORE(ch,re)
	character*1 ch(48),key
	am=0.
	s=1.
	io=0
	iso=1
	ifo=0
	p=-1.
	do 1 i=1,48
	key=ch(i)
	if(key.eq.'+'.or.key.eq.' ') goto 1
	if(key.eq.'.') then
	  p=0.1
	else if(key.eq.'-') then
	  if(ifo.eq.0) then
	    s=-s
	  else
	    iso=-iso
	  endif
	else if(key.eq.'e'.or.key.eq.'E') then
	  ifo=1
	else
	  ia=ichar(key)-48
	  if(ifo.eq.0) then
	    if(p.lt.0) then
	      am=10.*am+ia
	    else
	      am=am+ia*p
	      p=p*0.1
	    endif
	  else
	    io=io-(io/10)*10
	    io=10*io+ia
	  endif
	endif
    1   continue
	re=s*am*10.**(io*iso)
	return
	end
C
	subroutine RETOCH(re,ch)
	character*12 ch,FRM
	are=abs(re)
	if(are.eq.0.) then
	  ch='          0.'
	  goto 2
	endif
	if(are.lt.2e9) then
	  if(are.eq.float(int(are)).and.are.lt.1.e6) then
	    write(ch,'(f12.0)') re
	    goto 2
	  endif
	endif
	if(are.lt.0.001.or.are.ge.1.e6) then
	  write(ch,1) re
    1     format(e12.6)
	  if(ch(1:1).eq.' ') ch(1:1)='0'
	else
	  lm=6-int(alog10(are))
	  if(are.ge.1.) lm=lm-1
	  write(FRM,3) lm
    3     format('(f12.',i1,')')
	  write(ch,FRM) re
    7	  if(ch(12:12).ne.'0') goto 5
	  do 4 j=1,11
	  ch(13-j:13-j)=ch(12-j:12-j)
    4	  continue
	  ch(1:1)=' '
	  goto 7
    5	  do 6 j=1,11
	  if(ch(j:j+1).ne.' .') goto 6
	  ch(j:j+1)='0.'
	  goto 2
    6	  continue
	endif
    2   return
	end
