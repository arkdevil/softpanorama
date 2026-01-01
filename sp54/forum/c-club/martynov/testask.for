	program sample
	common val(160)
	character*72 path,curdir
	character*12 fname
	character*8 names(3)
	integer lchar(3),buff(1000)
	external info,fkey,info2,fkey2,getlin
	equivalence (fname,val(2)),(s1,val(1)),(s2,val(5))
	integer freqs(6),durats(6)
	data freqs/294,330,330,294,247,196/
	data durats/16,8,8,12,4,16/
	do i=1,6
	  call sound(freqs(i),durats(i)-1)
	  call sound(0,1)
	enddo
	call getcur(ix,iy)
	call movcur(0,25)
	call mkwind(4,0,72,13,16*2,buff)
	call mkbord(4,0,72,13,1,16*2+9)
	do i=1,160
	  val(i)=sqrt(i-1.)
	enddo
	call spread(5,2,70,10,16*1+15,16*3+9,16,10,val,info,fkey)
	call rmwind(4,0,72,13,buff)
	call mkwind(35,5,10,15,16*1,buff)
	call mkbord(35,5,10,15,2,16*4+14)
	call ivmenu(36,6,8,12,255,16*1+11,16*4+14,isnum,
     *	  getlin,info2,fkey2)
	call rmwind(35,5,10,15,buff)
	call getdir(curdir)
	call disa24
	call askfil(5,15,fname)
	s1=alog(2.)
	s2=sin(0.314159)
	call mkwind(21,4,38,5,0,buff)
	call mkbord(21,4,38,5,1,19)
	lchar(1)=0
	names(1)=' S1='
	lchar(2)=12
	names(2)=' FNAME='
	lchar(3)=0
	names(3)=' S2='
	call askval(22,5,36,3,49,14,3,val,lchar,names,8)
	call rmwind(21,4,38,5,buff)
	call getdir(path)
	call patcat(path,fname,path)
	call cls(0)
	call edtext(path,72,4,7,72,31)
	call movcur(ix,iy)
	write(*,*) path,s1,s2
	call chdir(curdir,iferr)
	call enab24
	call comlin(path,curdir)
	call wrtext(path,72,0,5,80,11)
	call wrtext(curdir,72,0,6,80,11)
	end
C
	subroutine info(nlin,ncol)
	common val(10,16)
	character*30 infxy
	write(infxy,1) nlin,ncol,val(ncol,nlin)
 1	format('Row=',i2,' Col=',i2,' Val=',g12.5)
	call wrtext(infxy,30,25,1,30,7*16+9)
	return
	end
C
	subroutine fkey(nkey,nlin,ncol)
	integer buff(40)
	character*30 infnxy
	integer scan,ascii
	call mkwind(25,1,30,1,0,buff)
	write(infnxy,1) nlin,ncol,nkey
 1	format('Row=',i2,' Col=',i2,' Нажата F',i1)
	call wrtext(infnxy,30,25,1,30,7*16+4)
	call getkey(scan,ascii)
	call rmwind(25,1,30,1,buff)
	return
	end
C
	subroutine getlin(nlin,length,buf)
	character*80 buf
	write(buf(1:3),'(i3)') nlin
	write(buf(4:length),'(1x,3a1)') nlin,nlin,nlin
	return
	end
C
	subroutine info2(nlin)
	character*8 infsn
	write(infsn,1) nlin
 1	format('Row=',i3)
	call wrtext(infsn,8,36,18,8,16*3+9)
	entry fkey2(nkey,sn)
	return
	end
