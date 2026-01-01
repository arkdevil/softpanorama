#define FP_SEG(fp) (*((unsigned *)&(fp) + 1))
#define FP_OFF(fp) (*((unsigned *)&(fp)))
static char far *env="\7Incorrect DOS version\015\012$";
void fortran comlin(char *fname,char *params)
{ unsigned sgf,sgp,of;
  _asm
    { mov ah,30h
      int 21h
      sub bx,bx
      cmp al,03h
      jl msb
      mov ah,62h
      int 21h
      mov sgp,bx
      push es
      mov es,bx
      mov bx,es:[2Ch]
      pop es
      msb: mov sgf,bx
    }
  if(sgf)
    { FP_SEG(env)=sgf;
      FP_OFF(env)=0;
      while(*(env++)!=0x01);
      while(*(fname++)=*(++env));
      FP_SEG(env)=sgp;
      FP_OFF(env)=0x81;
      for(of=0;of<env[-1];of++)
	params[of]=env[of];
      params[of]=0;
    }
  else
    { sgf=FP_SEG(env);
      of=FP_OFF(env);
      _asm
	{ mov dx,sgf
	  push dx
	  mov dx,of
	  pop ds
	  mov ah,09h
	  int 21h
	  mov ax,4CFFh
	  int 21h
	}
    }
}
