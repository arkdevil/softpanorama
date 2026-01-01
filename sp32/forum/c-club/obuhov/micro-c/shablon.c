/* shablon.c                                   
============ micro-c ================
   This demo-programm assembled
   the file to another file
   with visual errors at the screen
   the command line is:              
   shablon.com <infile> <outfile>               
=====================================
*/                                   
char a;
int  i;
int input,output;
main()
{ 
  int  *argv[4];
  setarg (argv);
  outsym ("╔══════════════════════════════════════════════════╗",255,13);
  outsym ("║  = by Leon Obuhov 1989 =  ║",335,13);
  outsym ("╚═══════════════════════════════════════════════════╝",415,13);
  input=fopen (argv[1],0);
  output=fopen (argv[2],1);
/* ==================================== */





/* ==================================== */
  fclose(input);
  fclose(output);
  exit();
} 
#include st.inc
#include fio.inc
#include disp.inc
/*********/
