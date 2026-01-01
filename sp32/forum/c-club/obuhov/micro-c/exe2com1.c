/* exe2com.c                                   
  ============ micro-c ================

   This programm convert
   the .exe-file to another .com-file
   the command line is:              
   exe2com.com <exe-file> <com-file>   
            
  =====================================
*/                                   
char a;
int  i;
int input,output;
main()
{ 
  int  *argv[4];
  setarg (argv);

  outsym("╔════════ *** exe2com Umbrella company *** ════════╗",0335,14);
  outsym("╠════════ **Copyright (c) 1989 Obuhov L.** ════════╣",0415,14);
  outsym("╠                                                  ╣",0495,14);
  outsym("╠                                                  ╣",0575,14);
  outsym("╠                                                  ╣",0655,14);
  outsym("╠   byte =                                         ╣",0735,14);
  outsym("╠                                                  ╣",0815,14);
  outsym("╠                                                  ╣",0895,14);
  outsym("╠                                                  ╣",0975,14);
  outsym("╚══════════════════════════════════════════════════╝",1055,14);

  if (input =fopen(argv[1],0)) outsym(argv[1],579,10);
  else {outsym(" input file error ! ",579,04);exit();}
  if (output=fopen(argv[2],1)) outsym(argv[2],659,10);
  else {outsym(" output file error !",659,04);exit();}

  i=0;
  while(feof(input)==0)
  if(i < 768 ) {++i; fgetc(input);}
  else 
  { 
    fputc(fgetc(input),output);
    outnum((i++)-768,746,15);
  } 

  outsym("o^key ",899,10);

  fclose(input);
  fclose(output);
  exit();
} 
#include st.inc
#include fio.inc
#include disp.inc
/*********/
