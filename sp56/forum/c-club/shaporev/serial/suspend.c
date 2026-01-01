#pragma inline

void suspend(long counter)
{
   asm push es
   asm mov  si,counter
   asm mov  di,counter+2

   asm xor  ax,ax
   asm mov  es,ax
   asm xor  dx,dx

delay_loop:
   asm add  ax,1
   asm adc  dx,0	; /* increase long */
   asm mov  cx,si	; /* begin long comparison */
   asm xor  cx,ax
   asm mov  bx,di
   asm xor  bx,dx
   asm cmp  di,es:[46Ch]
   asm or   cx,bx	; /* finish long conparison */
   asm jnz  delay_loop

   asm pop  es
}

#pragma warn-rvl

long suscount(void)
{
   asm push es
   asm xor  ax,ax
   asm mov  es,ax
   asm xor  dx,dx

   asm mov  di,es:[46Ch]
wait_tick_over:
   asm cmp  di,es:[46Ch]
   asm je   wait_tick_over

   asm add  di,6	; /* wait for 5 more ticks */

calibrate_loop:
   asm add  ax,1
   asm adc  dx,0	; /* increase long */
   asm mov  cx,si	; /* begin long comparison */
   asm xor  cx,ax
   asm mov  bx,di
   asm xor  bx,dx
   asm or   cx,bx	; /* finish long comparison */
   asm cmp  di,es:[46Ch]
   asm ja   calibrate_loop
/* The returned long number matches to 270272 microseconds */
   asm pop  es
}
