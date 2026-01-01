#include <io.h>
#include <fcntl.h>
#define NULL 0L
char Copyright[]="NC group utility installator. By Gandlaf Sofware 1991.\r\n\
Make backup copy of NCMAIN.EXE before installation!!!\r\nSure to install NCA(y/n)?";
char UNABLE[]="Unable to open The Norton Commander.";
char MyName[]="nca.exe",My1[]="nul.att";
char Name[]="ncmain.exe";
char Spec[]="specnca";
char Mask[]={ 
 0x4C,0x69,0x62,0x72,0x61,0x72,0x69,0x65,0x73,0x20,0x43,0x6F,0x70,0x79,0x72,0x69,  //Libraries Copyri
 0x67,0x68,0x74,0x20,0x31,0x39,0x38,0x36,0x2C,0x20,0x4A,0x6F,0x68,0x6E,0x20,0x53,  //ght 1986, John S
 0x6F,0x63,0x68,0x61,0x00,0x00,0x00,0x00,0x00,0xBB,0xD3,0x1B,0x8E,0xDB,0x2E,0x89,  //ocha............
 0x1E,0x26,0x00,0x8D,0x06,0x70,0x71,0x25,0xF0,0xFF,0xFA,0x8E,0xD3,0x8B,0xE0,0xFB   //.&...pq%........
 };
char Buf[0x40];
char NewMenu1[]="Init group",NewMenu2[]="do Group command ",Nm[]="gRoup once     ";
char *getenv();
char *strchr();
extern int errno;

void check()
{
 if(errno)
   exit(printf("Error %d occured during installation !!!",errno));
}

void main()
{
  char *Norton,Path[65]="",*Pth;
  int Handle1,Point;
  printf(Copyright);
  if((getchar()&0x5F)!='Y')
    exit(puts("Nothing venture - nothing have ..."));
  Norton=getenv("NC");
  if(Norton!=NULL)
  {
    strcpy(Path,Norton);
    *(unsigned *)(Path+strlen(Path))='\\';
    strcat(Path,Name);
  }
  else
  {
    if(!access(Name,0))
      strcpy(Path,Name);
    else
    {
      for(Point=0,Pth=getenv("PATH");*Pth&&Pth;Pth+=Point+1)
      {
        Point=strchr(Pth,';')-Pth;
        strncpy(Path,Pth,Point);
        if(Path[Point-1]!='\\')
          *(unsigned*)(Path+Point)='\\';
        else
          Path[Point]=0;
        strcat(Path,Name);
        if(!access(Path,0))
        {
          Pth=NULL;
          break;
        }
      }
      if(Pth!=NULL)    
        exit(puts(UNABLE));
    }
  }
  Handle1=open(Path,O_RDWR|O_BINARY);
  if(Handle1==-1)
    exit(puts(UNABLE));
  lseek(Handle1,0x1800,SEEK_SET);
  read(Handle1,(void *)Buf,0x40);
  if(memcmp(Mask,Buf,0x40))
    exit(puts("Your NCMAIN.EXE is not 3.0 or non-patchable.")); 
  lseek(Handle1,0x1E708L,SEEK_SET);
  check();
  write(Handle1,MyName,0x10);
  check();
  lseek(Handle1,0x20D1BL,SEEK_SET);
  check();
  write(Handle1,NewMenu1,11);
  check();
  lseek(Handle1,0x20dA3,SEEK_SET);
  check();
  write(Handle1,NewMenu2,32);
  check();
  lseek(Handle1,0x214DDL,SEEK_SET);
  check();
  write(Handle1,Spec,8);
  check();
  lseek(Handle1,0x2154FL,SEEK_SET);
  check();
  write(Handle1,Spec,8);
  check();
  close(Handle1);
  check();
  puts("Installation successfully done.");
  puts("Set value of SPECNCA environment variable to path where NCA.EXE is situated.");
  puts("Set value of TEMPNCA environment variable to path for temporary NCA files.");
}