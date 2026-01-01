static unsigned char enbreak=0x01;
static unsigned char ifmouse=0x01;
void fortran getkey(char *is,char *ia)
{ char iss,iaa,cbreak;
  int hor,ver,rb,lb;
  if(ifmouse==0x01)
    _asm
      { sub ax,ax
	int 33h
	mov ifmouse,al
      }
  do
    { iaa=iss=cbreak=rb=lb=0;
      if(ifmouse)
	{ _asm
	    { mov ax,0Bh
	      int 33h
	      mov hor,cx
	      mov ver,dx
	      mov ax,06h
	      sub bx,bx
	      int 33h
	      mov lb,bx
	      mov ax,06h
	      mov bx,01h
	      int 33h
	      mov rb,bx
	    }
	  if(lb)
	    { iaa=0x0D;
	      iss=0x1C;
	    }
	  if(rb)
	    { iaa=0x1B;
	      iss=0x01;
	    }
	  if(ver>8) iss=0x50;
	  if(ver<(-8)) iss=0x48;
	  if(hor>16) iss=0x4D;
	  if(hor<(-16)) iss=0x4B;
	}
      _asm
	{ mov ah,01h
	  int 16h
	  jz endl
	  sub ah,ah
	  int 16h
	  cmp ah,0
	  jne usekey
	  mov cbreak,01h
	  usekey:
	  mov iss,ah
	  mov iaa,al
	  endl:
	}
    }
  while(iss==0 && iaa==0 && cbreak==0);
  if(cbreak)
    { if(enbreak)
	_asm
	  { mov ax,4C02h
	    int 21h
	  }
       else
	 { *is=46;
	   *ia=3;
	 }
    }
  else
    { *is=iss;
      *ia=iaa;
    }
}
void fortran enabrk()
{ enbreak=0x01;
}
void fortran disbrk()
{ enbreak=0x00;
}
void fortran movcur(int *x,int *y)
{ char xx,yy;
  xx=*x;
  yy=*y;
  _asm
    { sub bh,bh
      mov dh,yy
      mov dl,xx
      mov ah,02h
      int 10h
    }
}
void fortran getcur(long *x,long *y)
{ char xx,yy;
  _asm
    { sub bh,bh
      mov ah,03h
      int 10h
      mov yy,dh
      mov xx,dl
    }
  *x=xx;
  *y=yy;
}
