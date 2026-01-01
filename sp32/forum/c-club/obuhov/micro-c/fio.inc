/*
  ===============
  the service for file IO

  handle=fopen(file,type);
  fclose(handle);
  fgetc(handle);
  fputc(c,handle);
  feof(handle);
  getchar();
  putchar(c);

  ===============
*/
int File_ds;
fopen(file,typ1)/* must be prepare File_ds */
  int *file,typ1;
{ 
  #asm
  push  ds
  mov	ax,cs
  add	ax,1000h
  mov   word ptr cs:File_ds,ax
;*
  mov   dx,word ptr [bp+6]
  mov   al,byte ptr [bp+4]
  mov   cx,0
  cmp   word ptr [bp+4],0
  je    fopen4
  mov   ah,3ch
  int   21h		; @Create
  jc    fopen2
  jmp   short fopen5
fopen4:
  mov   ah,3dh
  int   21h		; @Open
  jc    fopen2
fopen5:
  mov	bx,ax
  sub	bx,5
  mov	ax,400h
  mul   bx
  add   ax,word ptr cs:File_ds
  mov	ds,ax
  mov	word ptr ds:[0],4
  mov	word ptr ds:[2],3
  cmp	word ptr [bp+4],0
  je	fopen3
  mov	word ptr ds:[0],0
fopen3:
  add	bx,5
  mov   ax,bx
  jmp short fopen1
fopen2:
  mov   ax,0
fopen1:
  pop	ds
  #endasm
} 
fclose(handle)
  int handle;
{ 
  #asm
  push  ds
  mov   bx,word ptr [bp+4]
  sub	bx,5
  mov   ax,400h
  mul	bx
  add   ax,word ptr cs:File_ds
  mov   ds,ax
  cmp	word ptr ds:[0],0
  jne	fclose1
;*
  mov   bx,word ptr [bp+4]
  mov   dx,4
  mov   cx,word ptr ds:[2]
  sub	cx,3
  mov   ah,40h
  int   21h		; @Write
fclose1:
  mov   bx,word ptr [bp+4]
  mov   ah,3eh
  int   21h		; @Close
  pop	ds
  #endasm
} 
fgetc(handle)
  int handle;
{ 
  #asm
  push  ds
  mov   bx,word ptr [bp+4]
  sub	bx,5
  mov   ax,400h
  mul	bx
  add   ax,word ptr cs:File_ds
  mov   ds,ax
  cmp	word ptr ds:[2],3
  jne	fgetc1
;*
  mov   bx,word ptr [bp+4]
  mov   dx,4
  mov   cx,3ffch
  mov   ah,3fh
  int   21h		; @Read
  jc	fgetc4
  and	ax,3fffh
  mov	word ptr ds:[2],4
  add	ax,4
  mov	word ptr ds:[0],ax
fgetc1:
  mov	si,word ptr ds:[2]
  mov	al,byte ptr ds:[si]
  xor	ah,ah
  inc	si
  mov	word ptr ds:[2],si
  cmp	si,word ptr ds:[0]
  jc	fgetc2
  mov	word ptr ds:[2],3
  test	word ptr ds:[0],3fffh
  jz	fgetc3
fgetc4:
  mov	word ptr ds:[2],0	; yes feof !
fgetc3:
  mov	word ptr ds:[0],4
fgetc2:
  pop	ds
  #endasm
} 
fputc (c,handle)
  char c;int handle;
{ 
  #asm
  push  ds
  mov   bx,word ptr [bp+4]
  sub	bx,5
  mov   ax,400h
  mul	bx
  add   ax,word ptr cs:File_ds
  mov   ds,ax
fputc2:
  mov	si,word ptr ds:[2]
  inc	si
  mov	word ptr ds:[2],si
  cmp	si,4000h
  jc	fputc1
;*
  mov   bx,word ptr [bp+4]
  mov   dx,4
  mov   cx,3ffch
  mov   ah,40h
  int   21h		; @Write
  mov	word ptr ds:[0],0
  mov	word ptr ds:[2],3
  jmp short fputc2
fputc1:
  mov	al,byte ptr [bp+6]
  xor	ah,ah
  mov	byte ptr ds:[si],al
  pop	ds
  #endasm
} 
feof(handle)
  int handle;
{ 
  #asm
  push  ds
  mov   bx,word ptr [bp+4]
  sub	bx,5
  mov   ax,400h
  mul	bx
  add   ax,word ptr cs:File_ds
  mov   ds,ax
;*
  mov	ax,0
  cmp	word ptr ds:[2],0
  jne	feof1
  mov	ax,1
feof1:
  pop	ds
  #endasm
} 
getchar()
{ 
  #asm
  mov   ah,01h
  int   21h
  xor   ah,ah
  #endasm
} 
putchar(c)
  int c;
{ 
  #asm
  mov   dl,byte ptr [bp+4]
  mov   ah,02h
  int   21h
  #endasm
} 
/*****/
