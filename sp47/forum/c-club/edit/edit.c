#define MAIN
#include "edstr.h"
#include <dos.h>
#include <dir.h>
char BackPath[MAXPATH];
void interrupt (*oldvec)(void);
void main(void){
char *HorMenStr[] = { " About ",
		      " File ",
		      " Edit ",
		      " Options " };
char *HorMenStrMes[] = { "Copyright information",
			 "File management commands",
			 "File editing commands",
			 "Set clock, color" };
int HorMenStrA[] = {0, 0, 0, 0};
int HorLeftRigthKey[] = {-1,1,-1, 3};
int KolHorMen = 3, HorStep = 2;
char *VerMenStr[] = { " Open           F3 ",
		      " New ",
		      " Save           F2 ",
		      " Save as... ",
		      " Delete ",
		      "",
		      " Print ",
		      "",
		      " Quit        Alt-X "};
int VerMenStrA[] = {0, -2, -2, -2, -2, -1, -2, -1, 0};
char *VerMenStrMes[] = { "Locate and open a file",
			 "Create a new file",
			 "Save the file",
			 "Save the file under a different name",
			 "Delete the file",
			 "",
			 "Print the file",
			 "",
			 "Exit editor" };
int KolVerMen = 8,VerStep = 1;
char *VerMenStr1[] = { "√Clock           ",
		       " Alarm Clock ... ",
		       " Color          " };
int VerMenStrA1[] = {0, 0, 1};
char *VerMenStrMes1[] = { "Clock On or Off",
			  "Set Alarm Clock",
			  "Set Color To Environment" };
int KolVerMen1 = 2,VerStep1 = 1;
static int PointVerMen2[3];
static int PointVerMen1[3];
static int PointHorMen1[3];
static int PointHorMenEnt[3];
int StartVerMenX1 = 28;
int StartVerMenX = 12, StartVerMenY = 3;
int StartHorMenX = 2, StartHorMenY = 1;
int StartMenMesX = 12, StartMenMesY = 25;
int ColNorm = 0x70,ColInver = 0x20,
    ColChNorm = 0x7E,ColChInver = 0x2E;
int BackPath1;
BackPath1 = getdisk();
getcurdir(0,BackPath);
 *PointVerMen1=0;
 *(PointVerMen1+1)=0;
 *(PointVerMen1+2)=0;
 *PointHorMenEnt=0;
 *(PointHorMenEnt+1)=0;
 *(PointHorMenEnt+2)=0;
 *PointVerMen2=0;
 *(PointVerMen2+1)=0;
 *(PointVerMen2+2)=0;
 *PointHorMen1=0;
 *(PointHorMen1+1)=0;
 *(PointHorMen1+2)=0;
 CursorShape=get_cursor_size();
 set_cursor_size(NoCursor);
 FON(0xb0,0x71);
 ClearStringX(1,1,80);
 ClearStringX(1,25,80);
 PrintString(2,25,"F1 Help │",ColNorm);
 NegTabX(2,25,2,ColChNorm);
 oldvec = getvect(0x1c);
 SetMyTime(ColNorm);
begin:
  HorMen(StartHorMenX,StartHorMenY,KolHorMen,HorMenStr,HorMenStrA,HorStep,
	 StartMenMesX,StartMenMesY,HorMenStrMes,ColNorm,ColInver,ColChNorm,
	 ColChInver,PointHorMen1,HorLeftRigthKey,PointHorMenEnt);
 if((*PointHorMen1==0)&&(*(PointHorMen1+2)==0))
      Autor(ColNorm,ColInver,ColChNorm,ColChInver);
  if((*PointHorMen1==1)&&(*(PointHorMen1+2)==0)){
      VerMen(StartVerMenX,StartVerMenY,KolVerMen,VerMenStr,
	     VerMenStrA,VerStep,StartMenMesX,StartMenMesY,
	     VerMenStrMes,ColNorm,ColInver,ColChNorm,ColChInver,PointVerMen1);
	     *(PointHorMenEnt+2) = *(PointVerMen1+2);
    if((*PointVerMen1==0)&&(*(PointVerMen1+2)==0))FileDirChen(CursorShape);
    if((*PointVerMen1==8)&&(*(PointVerMen1+2)==0)){
			    setvect(0x1c,oldvec);
			    setdisk(BackPath1);
			    chdir(BackPath);
			    ExitProg(CursorShape);
    }
  }
  if((*PointHorMen1==3)&&(*(PointHorMen1+2)==0)){
      VerMen(StartVerMenX1,StartVerMenY,KolVerMen1,VerMenStr1,
	     VerMenStrA1,VerStep1,StartMenMesX,StartMenMesY,VerMenStrMes1,
	     ColNorm,ColInver,ColChNorm,ColChInver,PointVerMen2);
	     *(PointHorMenEnt+2) = *(PointVerMen2+2);
      if((*PointVerMen2==0)&&(*(PointVerMen2+2)==0)){
       MarkMen(1,VerMenStr1[0]);
	if(VerMenStr1[0][0]=='√'){
	  oldvec = getvect(0x1c);
	  SetMyTime(ColNorm);
	}else{
	  setvect(0x1c,oldvec);
	  ClearStringX(70,1,10);
	}
      }
      if((*PointVerMen2==1)&&(*(PointVerMen2+2)==0))AlarmClock();
  }
goto begin;
}

























