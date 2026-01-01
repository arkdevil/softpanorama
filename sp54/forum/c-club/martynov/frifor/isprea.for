	subroutine isprea(x,y,dx,dy,sa1,sa2,linnum,colnum,val,info,fkey)
	integer x,y,dx,dy,linnum,colnum,sa1,sa2
	integer val(linnum)
	integer xx,yy,sn,bp,cn,cnmax,cnold,snold
	integer*2 scan,inkey
	character*1 buf(12),ln(12),sym
	cnmax=(dx-5)/13
	if(cnmax.gt.colnum) cnmax=colnum
	do sn=1,linnum
	  if(sn.gt.dy) goto 1
	  call intoch(sn,ln)
	  yy=y+sn-1
	  call wrtext(ln(9),4,x,yy,dx,sa1)
	  do cn=1,cnmax
	    call intoch(val(cn+(sn-1)*colnum),buf)
	    xx=x-8+13*cn
	    call wrtext(buf,12,xx,yy,12,sa1)
	  enddo
	enddo
 1	bp=0
	sn=1
	cn=1
	nss=0
	nsc=0
	yy=y
	xx=x+5
	call chattr(12,xx,yy,sa2)
 2	j=1
	call info(sn,cn)
	call getkey(scan,inkey)
	sym=char(inkey)
	if(sym.ge.' ') then
	  if(sym.eq.' '.or.(sym.ge.'0'.and.sym.le.'9')
     *	    .or.sym.eq.'+'.or.sym.eq.'-') then
	    if(bp.eq.0) then
	      do i=1,12
	  	buf(i)=' '
	      enddo
	    else
	      do i=1,11
	        buf(i)=buf(i+1)
	      enddo
	    endif
	    buf(12)=sym
	    bp=bp+1
	    call wrtext(buf,12,xx,yy,12,sa2)
	  else
	    call beep
	  endif
	elseif(inkey.eq.8.and.bp.gt.0) then
	  do i=12,2,-1
	    buf(i)=buf(i-1)
	  enddo
	  buf(1)=' '
	  call wrtext(buf,12,xx,yy,12,sa2)
	  bp=bp-1
	elseif(inkey.eq.13) then
	  if(bp.gt.0) then
	    call chtoin(buf,val((sn-1)*colnum+cn))
	    call info(sn,cn)
	    bp=0
	  endif
	  call intoch(val((sn-1)*colnum+cn),buf)
	  call wrtext(buf,12,xx,yy,12,sa2)
	elseif(inkey.eq.27) then
	  inkey=0
	endif
        if(inkey.eq.0) then
	  if(bp.gt.0) then
	    call chtoin(buf,val((sn-1)*colnum+cn))
	    call info(sn,cn)
	    bp=0
	  endif
	  call intoch(val((sn-1)*colnum+cn),buf)
	  call wrtext(buf,12,xx,yy,12,sa2)
	  if(scan.ge.59.and.scan.le.68) then
	    call fkey(scan-58,sn,cn)
	  elseif(scan.eq.72.or.scan.eq.73) then
	    if(scan.eq.73) j=dy+(yy-y)
	    do i=1,j
	      if(sn.gt.1) then
	        sn=sn-1
	        if(yy.gt.y) then
		  call chattr(12,xx,yy,sa1)
		  yy=yy-1
		  call chattr(12,xx,yy,sa2)
	        else
		  call intoch(sn,ln)
		  call scrldn(ln(9),4,x,y,dx,dy)
		  nss=nss-1
		  cnold=cn
		  do cn=1,cnmax
		    call intoch(val((sn-1)*colnum+cn+nsc),buf)
		    xx=x-8+13*cn
		    call wrtext(buf,12,xx,yy,12,0)
		  enddo
		  cn=cnold
		  xx=x-8+13*(cn-nsc)
	        endif
	      endif
	    enddo
	  elseif(scan.eq.75) then
	    if(cn.gt.nsc+1) then
	      call chattr(12,xx,yy,sa1)
	      cn=cn-1
	      xx=x-8+13*(cn-nsc)
	      call chattr(12,xx,yy,sa2)
	    elseif(cn.gt.1) then
	      call scrlrg(x+5,y,dx-5,dy,13)
	      snold=sn
	      yyold=yy
	      cn=cn-1
	      nsc=nsc-1
	      do sn=1,dy
	        yy=y+sn-1
		call intoch(val((sn+nss-1)*colnum+cn),buf)
		call wrtext(buf,12,xx,yy,12,0)
	      enddo
	      sn=snold
	      yy=yyold
	    endif
	  elseif(scan.eq.77) then
	    if(cn-nsc.lt.cnmax) then
	      call chattr(12,xx,yy,sa1)
	      cn=cn+1
	      xx=x-8+13*(cn-nsc)
	      call chattr(12,xx,yy,sa2)
	    elseif(cn.lt.colnum) then
	      call scrllf(x+5,y,dx-5,dy,13)
	      snold=sn
	      yyold=yy
	      cn=cn+1
	      nsc=nsc+1
	      do sn=1,dy
	        yy=y+sn-1
		call intoch(val((sn+nss-1)*colnum+cn),buf)
		call wrtext(buf,12,xx,yy,12,0)
	      enddo
	      sn=snold
	      yy=yyold
	    endif
	  elseif(scan.eq.80.or.scan.eq.81) then
	    if(scan.eq.81) j=dy+(dy-(yy-y))-1
	    do i=1,j
	      if(sn.lt.linnum) then
	        sn=sn+1
	        if(yy.lt.(y+dy-1)) then
		  call chattr(12,xx,yy,sa1)
		  yy=yy+1
		  call chattr(12,xx,yy,sa2)
	        else
		  call intoch(sn,ln)
		  call scrlup(ln(9),4,x,y,dx,dy)
		  nss=nss+1
		  cnold=cn
		  do cn=1,cnmax
		    call intoch(val((sn-1)*colnum+cn+nsc),buf)
		    xx=x-8+13*cn
		    call wrtext(buf,12,xx,yy,12,0)
		  enddo
	          cn=cnold
	          xx=x-8+13*(cn-nsc)
	        endif
	      endif
	    enddo
	  endif
	endif
	if(scan.ne.1) goto 2
	return
	end
