#define FP_SEG(fp) (*((unsigned *)&(fp) + 1))
#define FP_OFF(fp) (*((unsigned *)&(fp)))
void fortran mkwind();
void fortran rmwind();
void fortran wrtext();
void fortran rdtext();
void fortran chattr();
void fortran getkey();
void fortran scrllf();
void fortran scrlrg();
void fortran intoch();

static unsigned char *dta,dtamem[43];
void fortran patcat(char *p1,char *p2,char *p12)
{ int i,count;
  count=0;
  while((p12[count++]=p1[count])>0x20);
  if(p12[count-2] != '\\')
    p12[(++count)-2]='\\';
  i=count-1;
  count=0;
  while(p2[count]>0x20 && count<12)
    p12[i++]=p2[count++];
  p12[i]=0;
}
void fortran fnd1st(char *mask,char *fname,char *attrib,long *size)
{ int segm,ofst,count,res;
  count=0;
  while(mask[count++]>=0x20);
  mask[count-1]=0;
  dta=dtamem;
  segm=FP_SEG(dta);
  ofst=FP_OFF(dta);
  _asm
    { mov dx,segm
      push ds
      push dx
      mov dx,ofst
      pop ds
      mov ah,1Ah
      int 21h
      pop ds
    }
  segm=FP_SEG(mask);
  ofst=FP_OFF(mask);
  _asm
    { mov dx,segm
      push ds
      push dx
      mov dx,ofst
      pop ds
      mov ah,4Eh
      mov cx,37h
      int 21h
      pop ds
      mov res,ax
    }
  if(res)
    *size=*attrib=-1;
  else
    { *size=*((long*)(dta+26));
      *attrib=dta[21];
      count=0;
      while(fname[count++]=dta[count+30]);
    }
}
void fortran fndnxt(char *fname,char *attrib,long *size)
{ int segm,ofst,count,res;
  dta=dtamem;
  segm=FP_SEG(dta);
  ofst=FP_OFF(dta);
  _asm
    { mov dx,segm
      push ds
      push dx
      mov dx,ofst
      pop ds
      mov ah,4Fh
      int 21h
      pop ds
      mov res,ax
    }
  if(res)
    *size=*attrib=-1;
  else
    { *size=*((long*)(dta+26));
      *attrib=dta[21];
      count=0;
      while(fname[count++]=dta[30+count]);
    }
}
void fortran chdir(char *str,long *iferr)
{ char *ptr,str2[80],drive;
  int i,segm,ofst;
  i=0;
  *iferr=0;
  ptr=str2;
  while((ptr[i++]=str[i])>0x20);
  ptr[--i]=0;
  if(i>0)
    { if(ptr[--i]=='\\')
	if(i!=0 && (i!=2 || ptr[1]!=':'))
	  ptr[i]=0;
      if(ptr[1]==':')
	{ drive=ptr[0]-'A';
	  if(drive>=32) drive-=32;
	    _asm
	      { mov ah,0Eh
		mov dl,drive
		int 21h
	      }
	}
      segm=FP_SEG(ptr);
      ofst=FP_OFF(ptr);
      _asm
	{ mov ax,segm
	  mov dx,ofst
	  push ds
	  mov ds,ax
	  mov ah,3Bh
	  int 21h
	  pop ds
	  mov i,ax
	}
      *iferr=i;
    }
}
void fortran getdir(char *str)
{ int segm,ofst;
  char drive;
  _asm
    { mov ah,19h
      int 21h
      mov drive,al
    }
  str[0]='A'+drive;
  str[1]=':';
  str[2]='\\';
  segm=FP_SEG(str);
  ofst=FP_OFF(str)+3;
  _asm
    { mov ax,segm
      mov si,ofst
      push ds
      mov ds,ax
      sub dl,dl
      mov ah,47h
      int 21h
      pop ds
    }
}

static char far *buf_alloc(unsigned *size)
{ unsigned res,rbx;
  char far *memo;
  rbx=((*size-1)>>4)+1;
  _asm
    { mov ah,48h
      mov bx,rbx
      int 21h
      jnc okm
      mov rbx,bx
      mov ah,48h
      int 21h
      okm: mov res,ax
    }
  *size=rbx<<4;
  FP_SEG(memo)=res;
  FP_OFF(memo)=0;
  return(memo);
}
static void buf_free(char far *buf)
{ unsigned res;
  res=FP_SEG(buf);
  _asm
    { push es
      mov ax,res
      mov es,ax
      mov ah,49h
      int 21h
      pop es
    }
}

#define MAX_F 550
static unsigned char far *scr_save,*file_buf,*files[MAX_F];
void fortran askfil(int *yy,int *dyy,char *fname)
{ unsigned char str[13],scan,inkey,attrib,sa,symb,tail;
  long size;
  int i,j,y0,y1,x,x0,y,dx,dy,np,np1,nfiles,count,ymax,x2,y2;
  unsigned fbs,sss,fnmax;
  y0=*yy;y1=y0-1+*dyy;
  fbs=MAX_F*20;
  file_buf=buf_alloc(&fbs);
  fnmax=fbs/20;
  fbs=*dyy*160;
  scr_save=buf_alloc(&fbs);
  again:
  x=x0=0;y=y0;dy=*dyy;sa=0x1B;np=1;i=0;
  str[12]=0;
  fnd1st("*.*",str,&attrib,&size);
  if(str[0]=='.' && str[1]==0)
    fndnxt(str,&attrib,&size);
  while(size>=0 && i<fnmax)
    { files[i]=file_buf+i*20;
      if(attrib & 0x10)
	{ files[i][12]=' ';
	  files[i][13]='<';
	  files[i][14]='D';
	  files[i][15]='I';
	  files[i][16]='R';
	  files[i][17]='>';
	  files[i][18]=' ';
	}
      else
	intoch(&size,files[i]+7);
      files[i][19]=0;
      tail=0;
      for(j=0;j<12;j++)
	{ symb=str[j];
	  if(symb<' ')
	    tail=1;
	  if(tail)
	    symb=' ';
	  files[i][j]=symb;
	}
      fndnxt(str,&attrib,&size);
      i++;
    }
  nfiles=i;
  np=(i-1)/dy+1;
  dx=20*np;
  np1=0;
  if(dx>80) dx=80;
  if(sss>=*yy*160) mkwind(&x,&y,&dx,&dy,&sa,scr_save);
  count=19;
  for(i=0;i<nfiles && x<80;i++)
    { wrtext(files[i],&count,&x,&y,&count,&sa);
      ymax=y;
      if(++y>y1)
	{ y=y0;
	  x+=20;
	}
    }
  x=0;y=y0;sa=0x71;
  chattr(&count,&x,&y,&sa);
  while(1)
    { getkey(&scan,&inkey);
      count=19;
      switch(scan)
	{ case 28: x+=13;count=1;
	 /*Enter*/ rdtext(str,&count,&x,&y);
		   x-=13;count=12;
		   if(str[0] != '<')
		     { rdtext(fname,&count,&x,&y);
		       goto ret;
		     }
		   else
		     { rdtext(str,&count,&x,&y);
		       chdir(str,&size);
		       clw:
		       x=0;y=y0;
		       if(sss>=*yy*160) rmwind(&x,&y,&dx,&dy,scr_save);
		       goto again;
		     }
	  case 72: sa=0x1B;
	  /*Up*/   chattr(&count,&x,&y,&sa);
		   if(y>y0 || x>0 || np1>0) y--;
		   if(y<y0)
		     { y=y1;x-=20;
		     }
		   if(x<0)
		     { count++;
		       scrlrg(&x0,&y0,&dx,&dy,&count);
		       count--;
		       np1--;
		       x+=20;
		       for(i=0;i<dy;i++)
			 { y2=y0+i;
			   wrtext(files[i+dy*np1],&count,&x,&y2,&count,&sa);
			 }
		     }
		   sa=0x71;
		   chattr(&count,&x,&y,&sa);
		   break;
	  case 80: sa=0x1B;
	  /*Down*/ chattr(&count,&x,&y,&sa);
		   if(x<(np-np1-1)*20 || y<ymax) y++;
		   if(y>y1)
		     { y=y0;x+=20;
		     }
		   if(x>dx-20)
		     { count++;
		       scrllf(&x0,&y0,&dx,&dy,&count);
		       count--;
		       np1++;
		       x-=20;
		       for(i=0;i<dy;i++)
			 { y2=y0+i;
			   j=i+dy*(3+np1);
			   if(j<nfiles)
			     { wrtext(files[j],&count,&x,&y2,&count,&sa);
			       ymax=y2;
			     }
			 }
		     }
		   sa=0x71;
		   chattr(&count,&x,&y,&sa);
		   break;
	  case 73: /*PgUp*/
	  case 75: sa=0x1B;
	  /*Left*/ chattr(&count,&x,&y,&sa);
		   if(x>0 || np1>0) x-=20;
		   if(x<0)
		     { count++;
		       scrlrg(&x0,&y0,&dx,&dy,&count);
		       count--;
		       np1--;
		       x+=20;
		       for(i=0;i<dy;i++)
			 { y2=y0+i;
			   wrtext(files[i+dy*np1],&count,&x,&y2,&count,&sa);
			 }
		     }
		   sa=0x71;
		   chattr(&count,&x,&y,&sa);
		   break;
	  case 81: /*PgDn*/
	  case 77: sa=0x1B;
	 /*Right*/ chattr(&count,&x,&y,&sa);
		   if(x<(np-np1-1)*20) x+=20;
		   if(x>dx-20)
		     { count++;
		       scrllf(&x0,&y0,&dx,&dy,&count);
		       count--;
		       np1++;
		       x-=20;
		       for(i=0;i<dy;i++)
			 { y2=y0+i;
			   j=i+dy*(3+np1);
			   if(j<nfiles)
			     { wrtext(files[j],&count,&x,&y2,&count,&sa);
			       ymax=y2;
			     }
			 }
		     }
		   if(y>ymax && x>=(np-np1-1)*20) y=ymax;
		   sa=0x71;
		   chattr(&count,&x,&y,&sa);
		   break;
	  case 1:  fname[0]='*';
	  /*Esc*/  goto ret;
	  default: if(inkey>0 && inkey<0x1B)
	  /*Ctrl-D*/ { _asm
			 { mov dl,inkey
			   dec dl
			   mov ah,0Eh
			   int 21h
			 }
		       goto clw;
		     }
	}
    }
  ret: x=0;y=y0;dx=20*np;
  if(dx>80) dx=80;
  if(sss>=*yy*160) rmwind(&x,&y,&dx,&dy,scr_save);
  buf_free(scr_save);
  buf_free(file_buf);
}

