/*
  ==========================

  this demo programm convert
  the deasm format file to
  format without code-colon
  command line is:
  convdem.com file1 file2

  ==========================
*/
char string[80];
main()
{ 
  int  *argv[3],i,input,output;

  setarg (argv);

  input=fopen (argv[1],0);
  output=fopen (argv[2],1);
  while (1) 
  { 
    i = 0;
    while ( (string[i++]=fgetc(input)) != '\r') ;
    fgetc(input);
    if (feof(input)) break; 

    i = 5;
    while (        i < 9     ) fputc (string[i++],output);
    fputc (':',output);

    i = 24;
    while ( string[i] != '\r') fputc (string[i++],output);
    fputc ('\r',output);
    fputc ('\n',output);
  } 
  fclose(input);
  fclose(output);
  exit();
} 
#include st.inc
#include fio.inc
/****** end *******/
