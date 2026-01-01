/** 
   get arguments from 
   the command line
**/
setarg(argv)
  int *argv;
{ 
  #asm
  mov   si,4
  mov   bx,word ptr [bp+4]
  mov   cx,42h
  mov   di,82h
  mov   word ptr cs:[bx+2],di
  mov   ax,1
  cmp   byte ptr cs:[di-2],0h
  jne   sarg1
  mov   ax,0
  jmp short sarg4
sarg1:
  inc   di
  cmp   byte ptr cs:[di-1],0dh
  je    sarg3
  cmp   byte ptr cs:[di-1],20h
  jne   sarg2
  mov   byte ptr cs:[di-1],0
  mov   word ptr cs:[bx+si],di
  inc   si
  inc   si
sarg2:
  loop  sarg1
sarg3:
  mov   byte ptr cs:[di-1],0
sarg4:
  #endasm
} 
/* full exit to DOS */
exit()
{ 
  #asm
  mov ah,4ch
  int 21h
  #endasm
} 
