	program demo
	character*1 buff1(38400),buff2(38400)
	real xx(64),yy(64)
	common buff1,buff2,xx,yy
	call derase
	call movcur(10,16)
	call movcur(-5,0)
	call setrev(1)
	call prompt('Please select videomode (1 - EGA, 2 - VGA): ',44)
	call setrev(0)
  1     call inkey(is,ia)
	ia=ia-ichar('0')
	if(ia.ne.1.and.ia.ne.2) goto 1
C       INIT, DERASE, DCOLOR, RECTAB, INQPOS, MOVEAB, TEXT demo
	call init(ia)
	maxy=350
	if(ia.eq.2) maxy=480
	call derase
	do 2 i=1,15
	call dcolor(i)
	call rectab(i*10-5,i*10-5,645-i*10,maxy+5-i*10,0)
	call rectab(i*10,i*10,640-i*10,maxy-i*10,1)
  2     continue
	call moveab(240,maxy-170)
	call inqpos(icx,icy)
	call dcolor(12)
	call text("Connell under UNIX",18)
C       RDBBLK, WRBBLK, VWAIT, SOUND demonstration
	call moveab(icx,icy)
	call rdbblk(18*8,18,buff1)
  3     continue
	icy=icy-1
	call moveab(icx,icy)
	call wrbblk(18*8,18,buff1)
	if(icy.gt.maxy/2-10) goto 3
	call sound(300,3)
	call vwait(1)
	call sound(300,1)
	call sound(400,6)
	call vwait(50)
	call moveab(0,0)
	call rdbblk(320,maxy/2,buff1)
	call moveab(320,maxy/2)
	call rdbblk(320,maxy/2,buff2)
	call wrbblk(320,maxy/2,buff1)
	call moveab(0,0)
	call wrbblk(320,maxy/2,buff2)
	call vwait(50)
	call wrbblk(320,maxy/2,buff1)
	call moveab(320,maxy/2)
	call wrbblk(320,maxy/2,buff2)
	call vwait(30)
	call vpage(1)
C       DRAWAB, FLOOD demonstration
	call dcolor(1)
	call rectab(0,0,639,maxy-1,1)
	call dcolor(15)
	call moveab(20,175)
	call drawab(20,275)
	call drawab(120,345)
	call drawab(520,75)
	call drawab(620,175)
	call drawab(620,75)
	call drawab(520,5)
	call drawab(120,275)
	call drawab(20,175)
	call moveab(380,108)
	call drawab(460,108)
	call drawab(260,242)
	call drawab(180,242)
	call drawab(380,108)
	call dcolor(11)
	call flood(320,208)
	call vwait(50)
C       WRPIXL demonstration
	call derase
	irnd=196-98-59
	do 9 i=1,6000
	icol=1+int(urand(irnd)*15)
	ix=int(urand(irnd)*640)
	iy=int(urand(irnd)*maxy)
	call wrpixl(ix,iy,icol)
  9     continue
	call vwait(50)
	call dcolor(3)
	call wrpixl(320,240,0)
	call flood(320,240)
	call vwait(30)
	if(ia.eq.1) then
	  call vpage(0)
	  call vwait(30)
	else
	  call derase
	  call colmap(0,0,0,2)
	  call ldfont('/usr/lib/vidi/font8x16.rus ',0)
C       High Level Graphics demonstration
C       If you want to run these subroutines in EGA mode,
C       type 350 instead of 480 inside subroutine setvie.
	  call setvie(0.2,0.2,0.8,0.8,-1,-1)
	  call setwor(-6.,-2.,6.,2.)
	  call txtulh('|High Level DEMO|')
	  call txturh('|HALO under UNIX|')
	  call axlin(6,12,1)
	  call aylin(6,12,1)
	  call txtxax('|X Axis|')
	  call txtyax('|Y Axis|')
	  call movabs(0.,1.7)
	  call texth('|y=sin(2*x)*exp(-0.2*x)|')
	  do 10 i=1,64
	    x=(i-32.)/6.
	    xx(i)=x
	    yy(i)=sin(2.*x)*exp(-0.2*x)
 10       continue
	  call movabs(xx(1),yy(1))
	  call polyla(xx,yy,64)
	  call vwait(120)
	  call colmap(0,0,0,0)
	endif
C       COLMAP demonstration
	call derase
	do 4 i=0,15
	call dcolor(i)
	call rectab(i*40,0,(i+1)*40-1,maxy-1,1)
  4     continue
	call vwait(10)
	do 5 i=1,12
	do 6 j=0,15
	ir=i+j/2
	ir=ir-(ir/4)*4
	ig=2*i+j+j/3+1
	ig=ig-(ig/4)*4
	ib=3*i+j+2*j/3+3
	ib=ib-(ib/4)*4
	call colmap(j,ir,ig,ib)
 6      continue
	call vwait(5)
  5     continue
C       restore default palette
	do 7 j=0,15
	call colmap(j,-1,-1,-1)
  7     continue
	call vwait(5)
C       CPYBLK demonstration
	do 8 i=0,639
	do 8 j=62,162
	if((j/5.eq.((j/5)/2)*2.and.i/5.eq.((i/5)/2)*2).or.
     *     (j/5.ne.((j/5)/2)*2.and.i/5.ne.((i/5)/2)*2)) then
	  call wrpixl(i,j,14)
	else
	  call wrpixl(i,j,0)
	endif
  8     continue
	call vwait(10)
	call cpyblk(60,150,380,maxy-150,200,100)
	call vwait(10)
	call cpyblk(380,150,60,maxy-150,200,100)
	call vwait(20)
	call dcolor(0)
	call moveab(220,100)
	call rectab(220,100,220+24*8,116,1)
	call dcolor(13)
	call text('Press any key to exit...',24)
	call vwait(600)
	call finit
	end
C
	real function urand(iy)
C       Uniformly Distributed Random Numbers Generator
C       by G.E.Forsythe, M.A.Malcolm, C.B.Moler
C       "Computer Methods for Mathematical Computations"
	integer iy
        integer ia,ic,itwo,m2,m,mic
	double precision halfm
        real s
        double precision datan,dsqrt
        data m2/0/,itwo/2/
	if(m2.ne.0) goto 20
        m=1
10      m2=m
        m=itwo*m2
	if(m.gt.m2) goto 10
	halfm=m2
        ia=8*idint(halfm*datan(1.d0)/8.d0)+5
        ic=2*idint(halfm*(0.5d0-dsqrt(3.d0)/6.d0))+1
        mic=(m2-ic)+m2
        s=0.5/halfm
20      iy=iy*ia
	if(iy.gt.mic) iy=(iy-m2)-m2
        iy=iy+ic
	if(iy/2.gt.m2) iy=(iy-m2)-m2
        if(iy.lt.0) iy=(iy+m2)+m2
        urand=float(iy)*s
        return
        end
C
C       High Level Graphic subroutines (emulate base HALO procedures)
C
	subroutine setvie(x1,y1,x2,y2,icbord,icfill)
C       Defines view region position. Length unit is the screen size.
	common/halovp/ ix1,iy1,ix2,iy2,xmin,ymin,xmax,ymax,dxi,dyi
	ix1=x1*640.-1.
	ix2=x2*640.-1.
	iy1=y1*480.-1.
	iy2=y2*480.-1.
	if(icfill.ge.0) then
	  call dcolor(icfill)
	  call rectab(ix1,iy1,ix2,iy2,1)
	endif
	if(icbord.ge.0) then
	  call dcolor(icbord)
	  call rectab(ix1,iy1,ix2,iy2,0)
	endif
	return
	end
C
	subroutine setwor(x1,y1,x2,y2)
C       Defines math coordinates of view region corners
	common/halovp/ ix1,iy1,ix2,iy2,xmin,ymin,xmax,ymax,dxi,dyi
	xmin=x1
	xmax=x2
	ymin=y1
	ymax=y2
	dxi=(ix2-ix1)/(x2-x1)
	dyi=(iy2-iy1)/(y2-y1)
	return
	end
C
	subroutine wtp(x,y,ix,iy)
C       Transforms math coordinates to pixel address
	common/halovp/ ix1,iy1,ix2,iy2,xmin,ymin,xmax,ymax,dxi,dyi
	if(x.le.xmin) then
	  ix=ix1
	else if(x.lt.xmax) then
	  ix=ix1+(x-xmin)*dxi
	else
	  ix=ix2
	endif
	if(y.le.ymin) then
	  iy=iy2
	else if(y.lt.ymax) then
	  iy=iy2-(y-ymin)*dyi
	else
	  iy=iy1
	endif
	return
	end
C
	subroutine movabs(x,y)
	call wtp(x,y,ix,iy)
	call moveab(ix,iy)
	return
	end
C
	subroutine polyla(x,y,npts)
C       Draws polyline from current position
C       through npts points with coords from x,y arrays.
	common/halovp/ ix1,iy1,ix2,iy2,xmin,ymin,xmax,ymax,dxi,dyi
	real x(npts),y(npts)
	data lincol/12/
	call dcolor(lincol)
	call inqpos(ixc,iyc1)
	iyc2=iyc1
	do 1 i=1,npts
	call wtp(x(i),y(i),ix,iy)
	if(ix.eq.ixc) then
	  if(iy.lt.iyc1) iyc1=iy
	  if(iy.gt.iyc2) iyc2=iy
	endif
	if(ixc.ne.ix.or.i.eq.npts) then
	  do 2 j=iyc1,iyc2
	  call wrpixl(ixc,j,lincol)
  2       continue
	  if(iabs(ix-ixc).gt.1.or.(iy-iyc1)*(iy-iyc2).gt.0)
     *       call drawab(ix,iy)
	  ixc=ix
	  iyc1=iy
	  iyc2=iy
	endif
	call moveab(ix,iy)
  1     continue
	return
	end
C
	subroutine txtulh(txtstr)
C       Draws text labels in various places.
C       Text in txtstr must be bounded with '|'.
	common/halovp/ ix1,iy1,ix2,iy2,xmin,ymin,xmax,ymax,dxi,dyi
	character*1 txtstr(72)
	data itxcol/11/
	iplace=0
	goto 3
	entry txturh(txtstr)
	iplace=1
	goto 3
	entry txtxax(txtstr)
	iplace=2
	goto 3
	entry txtyax(txtstr)
	iplace=3
	goto 3
	entry texth(txtstr)
	iplace=4
  3     i0=-1
	i1=-1
	do 1 j=1,72
	if(txtstr(j).ne.'|') goto 1
	if(i0.lt.0) then
	  i0=j+1
	else
	  i1=j-1
	  goto 2
	endif
  1     continue
  2     if(i1.ge.i0) then
	  if(iplace.eq.0) then
	    ix=ix1
	    iy=iy1-20
	    iang=0
	  else if(iplace.eq.1) then
	    ix=ix2-8*(i1-i0+1)
	    iy=iy1-20
	    iang=0
	  else if(iplace.eq.2) then
	    ix=(ix2+ix1-8*(i1-i0+1))/2
	    iy=iy2+24
	    iang=0
	  else if(iplace.eq.3) then
	    ix=ix1-70
	    iy=(iy1+iy2+8*(i1-i0+1))/2
	    iang=1
	  else
	    call inqpos(ix,iy)
	    iang=0
	  endif
	call putext(txtstr(i0),i1-i0+1,ix,iy,itxcol,iang)
	endif
	return
	end
C
	subroutine axlin(inbig,insmal,iprlab)
C       Draws X-axis.
C       inbig, insmall - numbers of tics
C       iprlab - if nonzero, axes will be labeled
	common/halovp/ ix1,iy1,ix2,iy2,xmin,ymin,xmax,ymax,dxi,dyi
	character*8 labfmt,xlabel
	data iaxcol/11/
	call dcolor(iaxcol)
	call inqpos(ix,iy)
	call moveab(ix1,iy1)
	call drawab(ix2,iy1)
	call moveab(ix1,iy2)
	call drawab(ix2,iy2)
	call moveab(ix,iy)
	call axslab(xmin,xmax,inbig,dx,ifexp,labfmt)
	eps=0.5/dxi
	if(insmal.gt.0) then
	  dxs=dx/insmal*inbig
	  n1=int(xmin/dxs)-2
 1        x=n1*dxs
	  if(x.ge.xmax+eps) goto 2
	  if(x.gt.xmin-eps) then
	    call wtp(x,0.5,ix,iy)
	    do 3 i=1,2
	    call wrpixl(ix,iy1+i,iaxcol)
	    call wrpixl(ix,iy2-i,iaxcol)
 3          continue
	  endif
	  n1=n1+1
	  goto 1
	endif
 2      n1=int(xmin/dx)-2
 4      x=n1*dx
	if(x.ge.xmax+eps) goto 5
	if(x.gt.xmin-eps) then
	  call wtp(x,0.5,ix,iy)
	  do 6 i=1,4
	  call wrpixl(ix,iy1+i,iaxcol)
	  call wrpixl(ix,iy2-i,iaxcol)
 6        continue
	  if(iprlab.ne.0) then
	    write(xlabel,labfmt) x*10.**(-ifexp)
	    if(xlabel.eq.'  00.') xlabel='   0.'
	    call putext(xlabel,5,ix-20,iy2+5,iaxcol,0)
	  endif
	endif
	n1=n1+1
	goto 4
 5      if(ifexp.ne.0) then
	  write(xlabel,7) 10.**(ifexp-1)
 7        format(e8.1)
	  call putext(xlabel(5:8),4,ix-12,iy2+21,iaxcol,0)
	endif
	return
	end
C
	subroutine aylin(inbig,insmal,iprlab)
C       Draws Y-axis.
	common/halovp/ ix1,iy1,ix2,iy2,xmin,ymin,xmax,ymax,dxi,dyi
	character*8 labfmt,xlabel
	data iaxcol/11/
	call dcolor(iaxcol)
	call inqpos(ix,iy)
	call moveab(ix1,iy1)
	call drawab(ix1,iy2)
	call moveab(ix2,iy1)
	call drawab(ix2,iy2)
	call moveab(ix,iy)
	call axslab(ymin,ymax,inbig,dy,ifexp,labfmt)
	eps=0.5/dyi
	if(insmal.gt.0) then
	  dys=dy/insmal*inbig
	  n1=int(ymin/dys)-3
 1        y=n1*dys
	  if(y.ge.ymax+eps) goto 2
	  if(y.gt.ymin-eps) then
	    call wtp(0.5,y,ix,iy)
	    do 3 i=1,2
	    call wrpixl(ix1+i,iy,iaxcol)
	    call wrpixl(ix2-i,iy,iaxcol)
 3          continue
	  endif
	  n1=n1+1
	  goto 1
	endif
 2      n1=int(ymin/dy)-2
 4      y=n1*dy
	if(y.ge.ymax+eps) goto 5
	if(y.gt.ymin-eps) then
	  call wtp(0.5,y,ix,iy)
	  do 6 i=1,4
	  call wrpixl(ix1+i,iy,iaxcol)
	  call wrpixl(ix2-i,iy,iaxcol)
 6        continue
	  if(iprlab.ne.0) then
	    write(xlabel,labfmt) y*10.**(-ifexp)
	    if(xlabel.eq.'  00.') xlabel='   0.'
	    call putext(xlabel,5,ix1-45,iy-8,iaxcol,0)
	  endif
	endif
	n1=n1+1
	goto 4
 5      if(ifexp.ne.0) then
	  write(xlabel,7) 10.**(ifexp-1)
 7        format(e8.1)
	  call putext(xlabel(5:8),4,ix1-36,iy+8,iaxcol,0)
	endif
	return
	end
C
	subroutine axslab(x0,x1,n,dx,ifexp,labfmt)
C       Selects format for axes tic labels. Used by axlin, aylin.
	character*8 labfmt
	dx=abs(x1-x0)/n
	aldx=alog10(dx)
	ndx=int(aldx)
	if(aldx.lt.0.) ndx=ndx-1
	amdx=dx*10.**(-ndx)
	if(amdx.lt.1.5) then
	  dx=1.
	else if(amdx.lt.3.5) then
	  dx=2.
	else if(amdx.lt.7.5) then
	  dx=5.
	else
	  dx=1.
	  ndx=ndx+1
	endif
	dx=dx*10.**ndx
	axmax=abs(x0)
	if(abs(x1).gt.axmax) axmax=abs(x1)
	alxm=alog10(axmax)
	nxm=int(alxm)+3
	if(nxm.lt.3) nxm=3
	if(x0.ge.0..and.x1.ge.0.) then
	  if(nxm.gt.5) then
	    nxm=nxm-1
	  else if(ndx.lt.(-2)) then
	    nxm=nxm-1
	    ndx=ndx+1
	  endif
	endif
	if(nxm.gt.5.or.(alxm.lt.0..and.ndx.lt.(-2))) then
	  labfmt='(f5.2)'
	  ifexp=int(alxm)
	  if(alxm.lt.0.) ifexp=ifexp-1
	  return
	else
	  ifexp=0
	  labfmt='(f5.'//char(5-nxm+48)//')'
	endif
	return
	end
