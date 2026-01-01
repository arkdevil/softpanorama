	subroutine ivmenu(x,y,dx,dy,linnum,sa1,sa2,selnum,
     *		getlin,info,fkey)
	integer x,y,dx,dy,linnum,sa1,sa2,selnum
	character*1 line(80)
	integer yy,sn
	integer*2 scan,inkey
	do sn=1,linnum
	  if(sn.gt.dy) goto 1
	  call getlin(sn,dx,line)
	  call wrtext(line,dx,x,y+sn-1,dx,sa1)
	enddo
 1	sn=1
	yy=y
	call chattr(dx,x,yy,sa2)
 2	j=1
	call info(sn)
	call getkey(scan,inkey)
	if(scan.eq.28) goto 3
	if(scan.ge.59.and.scan.le.68) then
	  call fkey(scan-58,sn)
	elseif(scan.eq.72.or.scan.eq.73) then
	  if(scan.eq.73) j=dy+(yy-y)
	  do i=1,j
	    if(sn.gt.1) then
	      sn=sn-1
	      if(yy.gt.y) then
		call chattr(dx,x,yy,sa1)
		yy=yy-1
		call chattr(dx,x,yy,sa2)
	      else
		call getlin(sn,dx,line)
		call scrldn(line,dx,x,y,dx,dy)
	      endif
	    endif
	  enddo
	elseif(scan.eq.80.or.scan.eq.81) then
	  if(scan.eq.81) j=dy+(dy-(yy-y))-1
	  do i=1,j
	    if(sn.lt.linnum) then
	      sn=sn+1
	      if(yy.lt.(y+dy-1)) then
		call chattr(dx,x,yy,sa1)
		yy=yy+1
		call chattr(dx,x,yy,sa2)
	      else
		call getlin(sn,dx,line)
		call scrlup(line,dx,x,y,dx,dy)
	      endif
	    endif
	  enddo
	endif
	if(scan.ne.1) goto 2
	sn=0
 3	selnum=sn
	return
	end
C
	subroutine ismenu(x,y,dx,dy,linnum,sa1,sa2,selnum,
     *		getlin,info,fkey)
	integer x,y,dx,dy,linnum,sa1,sa2,selnum(linnum)
	character*1 line(80),sel,uns
	integer yy,sn
	integer*2 scan,inkey
	sel='√'
	uns=' '
	do sn=1,linnum
	  if(sn.gt.dy) goto 1
	  call getlin(sn,dx,line)
	  if(selnum(sn).gt.0) then
	    line(dx)=sel
	  else
	    line(dx)=uns
	  endif
	  call wrtext(line,dx,x,y+sn-1,dx,sa1)
	enddo
 1	sn=1
	yy=y
	call chattr(dx,x,yy,sa2)
 2	j=1
	call info(sn)
	call getkey(scan,inkey)
	if(scan.eq.28.or.scan.eq.57.or.scan.eq.82) then
	  if(selnum(sn).eq.0) then
	    selnum(sn)=1
	    call wrtext(sel,1,x+dx-1,yy,1,sa2)
	  else
	    selnum(sn)=0
	    call wrtext(uns,1,x+dx-1,yy,1,sa2)
	  endif
	  scan=80
	endif
	if(scan.ge.59.and.scan.le.68) then
	  call fkey(scan-58,sn)
	elseif(scan.eq.72.or.scan.eq.73) then
	  if(scan.eq.73) j=dy+(yy-y)
	  do i=1,j
	    if(sn.gt.1) then
	      sn=sn-1
	      if(yy.gt.y) then
		call chattr(dx,x,yy,sa1)
		yy=yy-1
		call chattr(dx,x,yy,sa2)
	      else
		call getlin(sn,dx,line)
		if(selnum(sn).gt.0) then
		  line(dx)=sel
		else
		  line(dx)=uns
		endif
		call scrldn(line,dx,x,y,dx,dy)
	      endif
	    endif
	  enddo
	elseif(scan.eq.80.or.scan.eq.81) then
	  if(scan.eq.81) j=dy+(dy-(yy-y))-1
	  do i=1,j
	    if(sn.lt.linnum) then
	      sn=sn+1
	      if(yy.lt.(y+dy-1)) then
		call chattr(dx,x,yy,sa1)
		yy=yy+1
		call chattr(dx,x,yy,sa2)
	      else
		call getlin(sn,dx,line)
		if(selnum(sn).gt.0) then
		  line(dx)=sel
		else
		  line(dx)=uns
		endif
		call scrlup(line,dx,x,y,dx,dy)
	      endif
	    endif
	  enddo
	endif
	if(scan.ne.1) goto 2
	return
	end
