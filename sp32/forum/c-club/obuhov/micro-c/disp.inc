/* disp.inc */
/** the service for screen io **/
/* output string to display */
outsym(str,pos,atr)
  char str[];
  int pos,atr;
{ 
  #asm
  push es
  mov  ax,0b800h
  mov  es,ax
  mov  cx,50h
  mov  si,word ptr [bp+8]
  mov  di,word ptr [bp+6]
  shl  di,1
  mov  ah,byte ptr [bp+4]
outsym1:
  lodsb
  cmp  al,0
  je   outsym2
  stosw
  loop outsym1  
outsym2:
  pop  es
  #endasm
} 
/* swap string to display */
swapsym(str,pos,atr)
  char str[];
  int pos,atr;
{ 
  #asm
  push es
  mov  ax,0b800h
  mov  es,ax
  mov  cx,50h
  mov  si,word ptr [bp+8]
  mov  di,word ptr [bp+6]
  shl  di,1
swaps1:
  lodsw
  cmp  byte ptr [bp+4],0
  je   swaps3
  mov  ah,byte ptr [bp+4]
swaps3:
  cmp  al,0
  je   swaps2
  xchg ax,es:[di]	; not default !
  inc  di
  inc  di
  mov  word ptr [si-2],ax
  loop swaps1  
swaps2:
  pop  es
  #endasm
} 
/* output number to display */
outnum (num,pos,atr)
  int num,pos,atr;
{ 
  #asm
  push  es
  mov   ax,0b800h
  mov   es,ax
  mov   ax,word ptr [bp+8]
  mov   di,word ptr [bp+6]
  shl   di,1
  sub   cx,cx
  mov   bx,10
lopo:
  sub   dx,dx
  div   bx
  add   dl,30h
  push  dx
  or    ax,ax
  loopnz lopo
  neg   cx
  mov   dx,cx
lopp:
  pop   ax
  mov   ah,byte ptr [bp+4]
  stosw
  loop  lopp
  mov   ax,dx
  pop   es
  #endasm
} 
/* output hex-byte to display */
outhex (hex,pos,atr)
  int hex,pos,atr;
{ 
  #asm
  push  es
  mov   ax,0b800h
  mov   es,ax
  mov   al,byte ptr [bp+8]
  mov   ah,al
  and   ah,00fh
  call  outh1
  xchg  al,ah
  mov   cl,4
  shr   ah,cl
  call  outh1
  jmp short outh3
outh1:
  cmp   ah,0ah
  jc    outh2
  add   ah,27h
outh2:
  add   ah,30h
  retn
outh3:
  mov   di,word ptr [bp+6]
  shl   di,1
  mov   bh,byte ptr [bp+4]
  mov   bl,ah
  mov   word ptr es:[di],bx
  mov   bl,al
  mov   word ptr es:[di+2],bx
  pop   es
  #endasm
} 
/* get the code from user */
inkey()
{ 
  #asm
  mov   ah,08h
  int   21h
  xor   ah,ah
  #endasm
} 
/* test was the code user ? */
iskey()
{ 
  #asm
  mov   ah,01h
  int   16h
  mov   ax,1
  jnz   iskey1
  mov   ax,0
iskey1:
  #endasm
} 
/* input with convert number */
innum()
{ 
  int k,a;
  k=0;
  while ( (a=inkey()) != '\r')
  { 
    k=k*10+(a-'0');
  } 
  return k;
} 
/* input full string to CR */
instr(buf)
  char *buf;
{ 
  #asm
  mov  dx,word ptr [bp+4]
  mov  ah,0ah
  int  21h
  #endasm
}
