#include <stdio.h>
#include <string.h>
#include <dir.h>
#include <dos.h>
#include <conio.h>
#include <alloc.h>
#define Buffstr 280
#define StrConst "*.*"
#define StrFile 14
#define SizeFile 14
struct ffblk ffblk;
char NewPath[MAXPATH];
char DirBlk[100][StrFile], FileBlk[100][StrFile];
char FileSize[100][SizeFile];
int done, MaxFil=0, MaxDir=0;
int x1=26, y1=10, x2=54, y2=17;
int PrFile=1, PrDir=1;
static int PrSetDrive=0;
char save[Buffstr]=StrConst;
/*------------------------------*/
char *ChenDir(char *path){
int disk=0, disks=0;
int SaveDisk;
register int i;
char direct[Buffstr]="";
 strcpy(path, "X:\\");
 for(i=0;i <= strlen(save)+2;i++){
   if(((save[i]==':')&&(PrSetDrive!=0))||((save[i]=='\\')&&(PrSetDrive!=0))){
      SaveDisk = getdisk();
      disks = setdisk(SaveDisk);
       for (disk = 0;disk <= disks ;disk++){
	 if (disk + 'A' == toupper(save[0])){
	   setdisk(disk);
	   break;
	 }
       }
	 memcpy(direct,save,i);
	 chdir(direct+3);
	 path[0] = disk + 'A';
	 getcurdir(0,path+3);
   }else{
     path[0] ='A' + getdisk();
     setdisk(path[0]-'A');
     getcurdir(0,path+3);
     chdir(path+3);
   }
 }
 return(path);
}

/*------------------------------*/
void FileList(NextFile)
char *NextFile;
{
register int i=0, j;
 strcpy(save,"");
 strcat(save,NextFile);
 done = findfirst(NextFile,&ffblk,0);
 PrFile=done?1:0;
      ltoa(ffblk.ff_fsize,FileSize[i],10);
      strcpy(FileBlk[i],ffblk.ff_name);
   while (!done){
      MaxFil=i;
      i++;
      done = findnext(&ffblk);
      ltoa(ffblk.ff_fsize,FileSize[i],10);
      strcpy(FileBlk[i],ffblk.ff_name);
   }
}
/*------------------------------*/
void DirList(char *NextDir){
register int i=0, j;
char NextDir_1[Buffstr]="";
strcpy(NextDir_1,NextDir);
 if(0!=strcmp(NextDir_1,"*.*")){
   j=strlen(NextDir_1);
   while((NextDir_1[j]!='\\')&&(NextDir_1[j]!=':')&&(j!=0)){
     NextDir_1[j--]='';
   }
  strcat(NextDir_1,"*.*");
 }
 done = findfirst(NextDir_1,&ffblk,-1);
 PrDir=done?1:0;
 if(ffblk.ff_attrib!=16) strcpy(DirBlk[i],"");;
  if((ffblk.ff_attrib==16)
      &&(0!=strcmp(ffblk.ff_name,"."))){
	      strcpy(DirBlk[i],ffblk.ff_name);

  } else  i--;
    while (!done){
       done = findnext(&ffblk);
	MaxDir=i;
       if(ffblk.ff_attrib==16){
	 i++;
	 strcpy(DirBlk[i],ffblk.ff_name);
       }
    }
}
/*------------------------------*/
void FilePrint(void){
register int i=0;
  /* Очистить окно File */
     ClearBox(x1,y1,x1+StrFile-2,y2);
     ClearStringX(x1,y2+2,x2-x1);
  /* Выводит список File */
  if(!PrFile){
     PrintString(x1+1,y1+i,FileBlk[i],0x70);
  /* PrintString(x1+1,y1+i,FileBlk[i],0x70); */
  }
  while((i < MaxFil)&&(i < y2-y1)&&(!PrFile)){
     i++;
     PrintString(x1+1,y1+i,FileBlk[i],0x70);
  }
}
/*------------------------------*/
void DirPrint(void){
register int i=0;
  /* Очистить окно Drive */
     ClearBox(x2-StrFile+1,y1,x2,y2);
     ClearStringX(x1,y2+2,x2-x1);
  /* Выводит список Sub-Dir */
    if(!PrDir){
      PrintString(x1+StrFile+2,y1+i,DirBlk[i],0x70);
    }
    while((i < MaxDir)&&(i < y2-y1)&&(!PrDir)){
      i++;
      PrintString(x1+StrFile+2,y1+i,DirBlk[i],0x70);
    }
}
/*------------------------------*/
void LoadWind(void){
 char *string[]={ "Name",
		  "File",
		  "Subdir & drive" };
 PrintBox(x1-5,y1-6,x2+5,y2+4,0x00,0x70);
 ShadowRigth(x1-5,y1-6,x2+5,y2+4,7);
 BoxDraw(x1-3,y1-5,x2+3,y2+3,"┌┐└┘──││",0x7F);
 PrintString(x1-1,y1-4,string[0],0x70);
 NegTabX(x1-1,y1-4,1,0x7E);
 PrintString(x1-1,y1-2,string[1],0x70);
 NegTabX(x1-1,y1-2,1,0x7E);
 PrintString(x1+StrFile,y1-2,string[2],0x70);
 NegTabX(x1+StrFile,y1-2,1,0x7E);
 /* Окно строчного редактора */
 NegTabX(x1-1,y1-3,(x2-x1)+3,0x07);
 /* Рамка окна выборки */
 BoxDraw(x1+StrFile,y1-1,x2+1,y2+1,"┌┐└┘──││",0x7F);
 BoxDraw(x1-1,y1-1,x1+StrFile,y2+1,"┌┬└┴──│▒",0x7F);
 PrintUsingCharY(x1+StrFile,y1,1,30,0x7F);
 PrintUsingCharY(x1+StrFile,y2,1,31,0x7F);
}
/*------------------------------*/
int ChenDriveDirFile(StartX,MaxCol,PrElm,MasElm)
int StartX,MaxCol;
char MasElm[100][StrFile];
{
int ch;
int point=0, stay=0, porch=0;
register int i=0, j=0;
NegTabX(x1+StrFile,y1+1+porch,1,0x11);
NegTabX(x1+StartX,y1,StrFile,0x20);
begin:
     ch=getch();
      if(ch==0){
	 ch=getch();
	   if(ch==80){
	     if((point!=MaxCol)
	       &&(PrElm!=1)&&(0!=strcmp(MasElm[0],""))){
	       NegTabX(x1+StrFile,y1+1+porch,1,0x7F);
	       point++;
	       porch=(point*(y2-y1-2))/MaxCol;
	       NegTabX(x1+StrFile,y1+1+porch,1,0x11);
	       if(stay < y2-y1){
		 NegTabX(x1+StartX,y1+stay++,StrFile,0x70);
		 NegTabX(x1+StartX,y1+stay,StrFile,0x20);
	       }else{
		 for(i=point,j=0;i>=point-(y2-y1);i--,j++){
		    ClearStringX(x1+StartX,y2-j,StrFile);
		    PrintString(x1+StartX+1,y2-j,MasElm[i],0x70);
		 }
		NegTabX(x1+StartX,y1+stay,StrFile,0x20);
	       }
	    }
	  }
	  if(ch==72){
	    if(0 != point){
	       NegTabX(x1+StrFile,y1+1+porch,1,0x7F);
	       point--;
	       porch=(point*(y2-y1-2))/MaxCol;
	       NegTabX(x1+StrFile,y1+1+porch,1,0x11);
	      if(stay > 0 ){
	       NegTabX(x1+StartX,y1+stay--,StrFile,0x70);
	       NegTabX(x1+StartX,y1+stay,StrFile,0x20);
	      }else{
	       for(i=point,j=0;i<=point+(y2-y1);i++,j++){
		   ClearStringX(x1+StartX,y1+j,StrFile);
		   PrintString(x1+StartX+1,y1+j,MasElm[i],0x70);
	       }
		  NegTabX(x1+StartX,y1+stay,StrFile,0x20);
	      }
	    }
	  }
      }
      if(ch==9) goto TabGo;
      if(ch==27) goto EscGo;
      if(ch==13) goto EnterGo;
    goto begin;
TabGo:
     NegTabX(x1+StartX,y1+stay,StrFile,0x70);
     NegTabX(x1+StrFile,y1+1+porch,1,0x7F);
  /* Число для проверки на выход */
     return(-2);
EscGo:
     NegTabX(x1+StartX,y1+stay,StrFile,0x70);
     NegTabX(x1+StrFile,y1+1+porch,1,0x7F);
  /* Число для проверки на выход */
     return(-1);
EnterGo:;
    NegTabX(x1+StartX,y1+stay,StrFile,0x70);
    NegTabX(x1+StrFile,y1+1+porch,1,0x7F);
    return(point);
}
/*------------------------------*/
#define StartxStrWn 25 /* x1-1 */
#define EndxStrWn   57 /* x2+3 */
char *FileDirChen(int CurSize){
unsigned char *buf;
char *StRet;
register int i, j;
register int FilePoint, DirPoint;
unsigned char DialBar[EndxStrWn-StartxStrWn-2];
unsigned char DialBarBuffer[EndxStrWn-StartxStrWn-2];
int BarAttr=0x20;
memset(DialBar,BarAttr,EndxStrWn-StartxStrWn-2);
buf=(unsigned char *)malloc(4096);
StRet=(char *)malloc(Buffstr);
SaveText(x1-5,y1-6,x2+7,y2+5,buf);
LoadWind();
tab_e:
    NegTabX(x1+StrFile,y1+1,1,0x11);
    strcpy(StRet,(char *)edit_string(y1-3,x1-2,x1+(x2-x1)+2,CurSize,
				  Buffstr,save,DialBar,DialBarBuffer));
    if(0==strcmp(StRet,"")) goto e_xit;
    PrSetDrive=1;
    NegTabX(x1-1,y1-3,(x2-x1)+3,0x07);
    ChenDir(NewPath);
    FileList(StRet);
    DirList(StRet);
    FilePrint();
    DirPrint();

  FilePoint = ChenDriveDirFile(0,MaxFil,PrFile,FileBlk);
   if(FilePoint==-2) goto dir;
    if(FilePoint!=-1){
	 i=strlen(NewPath);
	  if(NewPath[i-1]!='\\')
	     strcat(NewPath,"\\");
       strcat(NewPath,FileBlk[FilePoint]);
      goto e_ret;
    }else goto e_xit;
dir:
  DirPoint = ChenDriveDirFile(StrFile+1,MaxDir,PrDir,DirBlk);
   if(DirPoint==-2) goto tab_e;
    if(DirPoint!=-1){
      chdir(DirBlk[DirPoint]);
      PrSetDrive=0;
      ChenDir(NewPath);
      FileList(StRet);
      DirList(StRet);
      FilePrint();
      DirPrint();
      goto dir;
    }else goto e_xit;
   e_ret:
    RestTextNorm(x1-5,y1-6,x2+7,y2+5,buf);
    free(buf);
    free(StRet);
    return(NewPath);

   e_xit:;
    RestTextNorm(x1-5,y1-6,x2+7,y2+5,buf);
    free(buf);
    free(StRet);
    return(NULL);
}


