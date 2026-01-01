/*
  =========micro-c============
 
   This demo-programm concatenate
   two files to one file;
   command line is:
   copy1.com <file1> <file2> <dst.file>

  ===========================
*/
main()
{ 
  int  *argv[4];
  int  input1,input2,output,i;
  char ch;

  setarg (argv);
  input1=fopen (argv[1],0);
  input2=fopen (argv[2],0);
  output=fopen (argv[3],1);
/**/
  while (1)
  { 
    ch=fgetc(input1);
    fputc(ch,output);
    if( feof(input1)) break;
  } 
  while (1)
  { 
    ch=fgetc(input2);
    fputc(ch,output);
    if( feof(input2)) break;
  } 
/**/
  fclose(input1);
  fclose(input2);
  fclose(output);
  exit();
} 
#include st.inc
#include fio.inc
/****** end ******/