/*                                   
============ micro-c ================
   This demo-programm output the part
   of the file to the screen,and test
   getting parameters;               
   the command line is:              
   ademo <file> <text>               
=====================================
*/                                   
#define MWhite  95                   
#define BYellow 30                   
                                     
char string[80];                     
int File_ds;                         
main()                               
{ 
  int  *argv[2];
  int  i,k;
  char *str;
  int  input;

  setarg (argv);

  input=fopen (argv[1],0);
  k = 0;
  while(1)
  { 
    string[79] = 0;
    i = 0;
    while ( (string[i++]=fgetc(input)) != '\r'); 
    fgetc(input);	/* skip the LF */
    string[i-1] = 0;
    outsym ( string,564+80*k++,MWhite);
    if ( k >= 15 ) break;
  } 
  fclose(input);

  outsym ( argv[1],324,BYellow);
  outsym ( argv[2],404,BYellow);

  str = "══ may be output the text,that you want ══";
  outnum (1234,292, MWhite);
  outsym ( str,244, MWhite);
  outnum (65520,300,BYellow);

  exit();
} 
#include st.inc
#include disp.inc
#include fio.inc
/****** end *******/
