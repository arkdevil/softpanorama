/* instest.c                                   
============ micro-c ================
   This test-programm input
   string from user by int-21h-0ah
   the command line is:              
   instest.com                
=====================================
*/                                   
char string[80];
main()
{ 
/* ================================== */
  while(1)
  {
    string[0] = 80;	      /* size of buffer */
    instr(string);
    string[string[1]+2] = 0;  /* depress CR */
    
    outsym(string+2,1760,23); /* skip 2 bytes */
    if(string[2] == 'q') break;
  } 
/* ================================== */
} 
#include disp.inc
/*********/
