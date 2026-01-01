/** wait for time **/
delay(time1)
  int time1;
{ 
  #asm
  mov   cx,word ptr [bp+4]
delay1:
  push  cx
  mov   cx,2000
  loop  $
  pop   cx
  loop  delay1
  #endasm
} 
