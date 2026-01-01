/* Программа для составления файла списка выделенных файлов оболочки VC v.032.
   Для других версий скорректировать смещения в строках 20, 91.
   Компилятор Turbo C.
   Программа переделана из vca_demo.pas SP54.
*/
#pragma inline
#include <dos.h>
#include <stdio.h>
#include <stdlib.h>
#include <process.h>


typedef struct{
  char Name[12];
  char Attr;
}Entry;


typedef struct{
  unsigned char x1[0x0ACF];
  unsigned char Set1[20];
  char  CDir1[68];
  int   Cur1;
  int   Up1;
  int   Len1;
  Entry Dir1[256];
  unsigned char Set2[20];
  char  CDir2[68];
  int   Cur2;
  int   Up2;
  int   Len2;
  Entry Dir2[256];
}VC;

VC far *V;

MCB(){
asm     PUSH    DS
asm     PUSH    ES
asm     MOV     AH, 52h
asm     INT     21h
asm     SUB     BX, 2
asm     JNC     n1
asm     MOV     AX, ES
asm     SUB     AX, 1000h
asm     MOV     ES, AX
n1:
asm     MOV     AX, ES:[BX]
asm        POP        ES
asm        POP        DS
  return _AX;
}


SearchSignature(){
char data[16]={'C','O','M','M','A','N','D','.','C','O','M',0x00,0x0A,'V','V','V'};
  unsigned char far *str;
  unsigned int a, far * shift;
  unsigned int ES1;

  ES1=MCB();

SCAN:
  str=MK_FP(ES1,0x117);
  for(a=0; a<16 && !(data[a]-str[a]); a++)
    ;
  if(a==16)
    return ES1;
  shift=MK_FP(ES1,3);
  a=*shift;
  ES1+=a+1;
  if(ES1>=_psp)
    return 0;
  goto SCAN;
}


main(int argc, char *argv[]){
  int numfiles, a, b;
  char file[19], commanda[120];
  char filetmp[]={"@f:\_arch.$$$"};
  FILE *out;
  Entry far *E;
  char far *CDir;

  a=SearchSignature();
  V=MK_FP(a,0);
  if (V==NULL){
    printf("VCommander v.032 not found.");
    exit (1);}
  CDir=MK_FP(a,0xB6A+0x117);
  if(CDir[0]==0x1)
    V=MK_FP(a,0xD5E);

  if(argc>=2){
    commanda[0]='\0';
    for(a=2; argc>1; argc--){
      strcat(commanda,argv[a++]);
      strcat(commanda," ");}}
  else{
    printf("Use:  VCA arj(lha,pkzip) [options] file_name.\n");
    printf("      VCA program_name [options] filelist_%s [options].",filetmp+1);
    exit(1);}

  if((out=fopen(filetmp+1,"wt"))==NULL){
    printf("Error write."); exit (1);}

  numfiles=(V->Len1-0x262)/24;

  E=V->Dir1;
  for( a=0, b=0; a<numfiles && a<256; a++)
    if( (E[a].Attr & 0x40) == 0x40){
      for(b=0; b<12 && E[a].Name[b]; b++)
        file[b]=E[a].Name[b];
      file[b]='\0';
      if(E[a].Attr==0x50)
        strcat(file,"\\*.*");
      fputs(file,out);
      fputs("\n",out);}
  fclose (out);

  if(b){
    if(!strcmp(argv[1],"arj")){
      filetmp[0]='!';
      spawnlp(P_WAIT,argv[1],argv[0],"a","-r","-jm",commanda,filetmp,NULL);}
    else if(!strcmp(argv[1],"lha"))
      spawnlp(P_WAIT,argv[1],argv[0],"a","-x1r1",commanda,filetmp,NULL);
    else if(!strcmp(argv[1],"pkzip"))
      spawnlp(P_WAIT,argv[1],argv[0],"-ex","-rp",commanda,filetmp,NULL);
    else
      spawnlp(P_WAIT,argv[1],argv[0],commanda,NULL);}
  unlink(filetmp+1);
}
