void scrline(int fn, short x, short y, char far *s, int arg)
{
   auto int oldpozition;
   auto char page, width;

   asm mov  ah,15
   asm int  10h
   asm mov  width,ah
   asm mov  page,bh

   asm test byte ptr fn,1
   asm jnz  set_cursor
   asm mov  ah,3		; /* BH = current page   */
   asm int  10h			; /* ask cursor position */
   asm mov  oldpozition,dx	; /* and save it         */
set_cursor:
   asm mov  dh,y
   asm mov  dl,x
   asm mov  ah,2		; /* BH = current page   */
   asm int  10h

   asm test byte ptr fn,2
   asm jz   string_format
   asm jmp  screen_format

string_format:
   asm les  si,s
output_string:
   asm mov  cl,width	; /* DX contains cursor position      */
   asm sub  cl,dl	; /* number of chars to end of screen */
   asm xor  ch,ch
   asm xor  di,di	; /* clear sequence counter */
count_sequence:
   asm lods byte ptr es:[si]
   asm or   al,al
   asm jz   break_sequence
   asm cmp  al,7	; /* bell? */
   asm je   break_sequence
   asm cmp  al,10	; /* carriage return? */
   asm je   break_sequence
   asm cmp  al,13	; /* line feed? */
   asm je   break_sequence
   asm inc  di          ; /* yet another char */
   asm loop count_sequence
   asm jmp  short output_sequence
break_sequence:
   asm dec  si
output_sequence:
   asm or   di,di
   asm jz   handle_special

   asm mov  cx,dx	; /* remember cursor position  */
   asm add  dx,di	; /* assume DH unchanged       */
   asm dec  dx		; /* last pozition of sequence */
   asm mov  bh,arg	; /* means attribute here      */
   asm mov  ax,0600h	; /* paint region by attribute */
   asm int  10h

   asm mov  bh,page
   asm mov  bl,arg
   asm mov  si,s
   asm mov  cx,di
print_sequence:
   asm lods byte ptr es:[si]
   asm mov  ah,14
   asm int  10h
   asm loop print_sequence
handle_special:
   asm mov  al,es:[si]
   asm or   al,al
   asm jnz  continue_special
   asm jmp  end_function
continue_special:
   asm cmp  al,7	; /* bell? */
   asm je   output_special
   asm cmp  al,10	; /* carriage return? */
   asm je   output_special
   asm cmp  al,13	; /* line feed? */
   asm jne  continue_string
output_special:
   asm mov  bh,page
   asm mov  bl,arg
   asm mov  ah,14
   asm int  10h
   asm inc  si
continue_string:
   asm mov  s,si	; /* save pointer */
   asm mov  ah,3	; /* BH = current page */
   asm int  10h
   asm jmp  short output_string

screen_format:
   asm les  si,s
output_screen:
   asm mov  cl,width	; /* DX contains cursor position      */
   asm sub  cl,dl	; /* number of chars to end of screen */
   asm cmp  cl,1
   asm jb   short_portion
   asm dec  cl
short_portion:
   asm xor  ch,ch
   asm cmp  cx,arg      ; /* means number of symbols here */
   asm jbe  max_portion
   asm mov  cx,arg
max_portion:
   asm jcxz end_function
   asm xor  di,di	; /* clear portion counter */
   asm mov  bx,es:[si]
count_portion:
   asm lods word ptr es:[si]
   asm cmp  ah,bh	; /* compare attribute */
   asm jne  break_portion
   asm cmp  al,7	; /* bell? */
   asm je   break_portion
   asm cmp  al,10	; /* carriage return? */
   asm je   break_portion
   asm cmp  al,13	; /* line feed? */
   asm je   break_portion
   asm inc  di          ; /* yet another char */
   asm loop count_portion
   asm jmp  short output_portion
break_portion:
   asm dec  si
   asm dec  si
output_portion:
   asm cmp  di,1
   asm ja   fastload
   asm mov  di,1	; /* number of patterns will be printed */
   asm mov  si,s	; /* restore pointer */
   asm lods word ptr es:[si]
   asm mov  bl,ah       ; /* attribute */
   asm mov  bh,page
   asm mov  cx,1        ; /* the only character */
   asm mov  ah,9	; /* write pattern */
   asm int  10h

   asm inc  dl
   asm cmp  dl,width
   asm jb   same_row
   asm mov  dl,0	; /* left column */
   asm inc  dh          ; /* of the next row */
same_row:
   asm mov  ah,2	; /* BH = current page   */
   asm int  10h         ; /* set cursor position */
   asm jmp  short continue_screen

fastload:
   asm mov  cx,dx	; /* remember cursor position  */
   asm add  dx,di	; /* assume DH unchanged       */
   asm dec  dx		; /* last pozition of portion  */
   asm mov  ax,0600h	; /* paint region by attribute */
   asm int  10h		; /* BH contains attributes    */

   asm mov  bh,page
   asm mov  bl,arg
   asm mov  si,s
   asm mov  cx,di
print_portion:
   asm lods word ptr es:[si]
   asm mov  ah,14
   asm int  10h
   asm loop print_portion

   asm mov  ah,3	; /* BH = current page */
   asm int  10h		; /* ask cursor position */
continue_screen:
   asm mov  s,si	; /* save new pointer */
   asm sub  arg,di      ; /* decrease rest of patterns */
   asm jmp  short output_portion

end_function:
   asm test byte ptr fn,1
   asm jnz  end
   asm mov  dx,oldpozition
   asm mov  bh,page
   asm mov  ah,2
   asm int  10h
end:;
}
