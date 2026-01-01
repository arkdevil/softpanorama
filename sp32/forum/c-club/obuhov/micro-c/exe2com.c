/* exe2com.c                                   
  ============ micro-c ================

   This demo-programm convert
   the .exe-file to another .com-file
   the command line is:              
   exe2com.com <exe-file> <com-file>   
            
  =====================================
*/                                   
char a;
int  i;
int File_ds,input,output;
main()
{ 
  int  *argv[4];
  setarg (argv);
  input=fopen (argv[1],0);
  output=fopen (argv[2],1);

  outsym ("_____________________________________________________",1532,12);
  outsym ("╔═exe2com══════════════════════════════════════════╗",1612,14);
  outsym ("║  = by Leon Obuhov 1989 =  ║",1692,14);
  outsym ("╚═══════════════════════════════════════════════════╝",1772,14);

  i=0;
  while(feof(input)==0)
  if(i < 768 ) { ++i; fgetc(input);}
  else fputc(fgetc(input),output);

  fclose(input);
  fclose(output);
  exit();
} 
#include st.inc
#include fio.inc
#include disp.inc
/*********/
