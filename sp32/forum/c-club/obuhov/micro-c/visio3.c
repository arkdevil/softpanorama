/* shablon.c                                   
============ micro-c ================
   This programm output
   the file at the screen
   the command line is:              
   visio.com <infile>                
=====================================
*/ 
#define lsize 38
/**/
char string[80],string1[80],*p1;
int i,lnum,a;
int input,output;
main()
{ 
  int  *argv[4];
  setarg (argv);
  outsym ("╔visio══════════════════════════════════════════════╗",815,10);
  outsym ("║  = by Leon Obuhov 1989 =  ║",895,10);
  outsym ("╚══════════════════ press any key ══════════════════╝",975,10);
  inkey();
  if((input=fopen (argv[1],0))==0) exit();
/* ===== */
  p1="════════════════════════════════════════";
  outsym(p1,0,96)    ;outsym(p1,40,96);
  outsym(p1,1920,96) ;outsym(p1,1960,96);
  outsym("╔",0,96)   ;outsym("╗",lsize+1,96);
  outsym("╚",1920,96);outsym("╝",1920+lsize+1,96);
  outsym("╔",40,96)  ;outsym("╗",lsize+41,96);
  outsym("╚",1960,96);outsym("╝",1920+lsize+41,96);
  while(1)
  {
    lnum=1;
    while (lnum < 24 )
    { 
      i=0;while (i<80) string[i++]=' ';
      i=0;while (i<80) string1[i++]=' ';
      i=0;while ((a=fgetc(input))!= '\r' & i<80 ) 
      { 
        if (a=='\t') a=' ';
        string[i]=a;
        /****************/
        if (a >= 97 & a < 127 ) a=a-32;
        string1[i]=a;
        /****************/
        i++;
        if(feof(input)) break;
      } 
      if(feof(input)) {i=0;while (i<80) string[i++]=' ';}
      else fgetc(input);
      if(feof(input)) {i=0;while (i<80) string1[i++]=' ';}
      string[lsize]=0;
      string1[lsize]=0;
      /**/
      outsym("║",lnum*80,96);
      outsym("║",lnum*80+1+lsize,96);
      outsym(string,lnum*80+1,23);
      /************************/
      outsym("║",lnum*80+40,96);
      outsym("║",lnum*80+41+lsize,96);
      outsym(string1,lnum*80+41,23);
      /***********************/
      lnum++;
    } 
  if(inkey()==27) break;
  if(feof(input)) break;
  }
/* ==== */
  fclose(input);
  exit();
} 
#include st.inc
#include fio.inc
#include disp.inc
/*********/
