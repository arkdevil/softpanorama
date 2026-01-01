#include <fcntl.h>

extern int _psp;
typedef unsigned char byte;
typedef unsigned size_t;
#define  FP_OFF(p)	((unsigned)(p))
#define  FP_SEG(p)	((unsigned)(byte _seg *)(byte far *)(p))
#define  MK_FP(seg,ofs)	((byte _seg *)(seg)+(byte near *)(ofs))

#define WILDCARDS 0x01
#define EXTENSION 0x02
#define FILENAME  0x04
#define DIRECTORY 0x08
#define DRIVE     0x10
                      
#define MAXPATH   80  
#define MAXDRIVE  3   
#define MAXDIR    66  
#define MAXFILE   9   
#define MAXEXT    5   

#define Active	(*(MK_FP(0,0x500)))

void interrupt (*getvect(int interrupno))();
void setvect(int interruptno,void interrupt(*isr)());
int open(const char *path,int access);
int write(int handle,void *buf,unsigned len);
int printf(const char *format, ... );
int bioskey(int cmd);
char *strncpy(char *dest, const char *src,unsigned maxlen);
char *strcat(char *dest, const char *src);
char *strrchr(const char *s, int c);
int fnsplit(const char *path, char *drive,char *dir, char *name,char *ext);
void fnmerge(char *path, const char *drive,const char *dir,const char *name,const char *ext);
int getcurdir(int drive, char *directory);
int getdisk();
int rename(const char *oldname,const char *newname);
void exit(int status);
char *strupr(char *String);
int close(int handle);
int _creat(const char *path, int attrib);
void __emit__();
void movedata(unsigned srcseg,unsigned srcoff,unsigned destseg,unsigned destoff,size_t n);

#define BufferSize 0x7FFFL
#define NULL 0L

byte Locked,Twice=0;
byte far *PrBuffer;
unsigned long CurrentPos=0;
unsigned FileHandle,i;
char far Name[MAXPATH]="\\PSPOOL.PRN";
char Drive[MAXDRIVE],Dir[MAXPATH],Nam[MAXFILE],Ext[MAXEXT];
extern int directvideo=1;
extern unsigned _heaplen=1;
extern unsigned _stklen=100;

void interrupt (*OldPrinter )(void);
void interrupt (*OldKeyboard)(void);

void interrupt Keyboard(void)
{
  __emit__(0xFA); /* cli */
  __emit__(0xE4,0x60); /* in al,60h */
  if(_AL==0x58&&!Locked&&Active)
  {
    Locked++;
    _AX=0x0100;
    __emit__(0xCD,0x17); /* int 17h */
    Locked=0;
  }
  OldKeyboard();
  __emit__(0xFB); /* sti */
} /* Keyboard */

void interrupt Printer(Bp,Di,Si,Ds,Es,Dx,Cx,Bx,Ax,Ip,Cs,Flags)
  unsigned Bp,Di,Si,Ds,Es,Dx,Cx,Bx,Ax,Ip,Cs,Flags;
{
  #pragma argsused
  if(Active&&((Ax&0xFF00)==0))
  {
    PrBuffer[CurrentPos++]=Ax&0xFF;
  }
  if((Ax&0xFF00)==0x0100 || ((Ax&0xFF00)==0x0000 && CurrentPos>=BufferSize)&&Active)
  {
    FileHandle=open(Name,O_WRONLY|O_APPEND|O_BINARY);
    write(FileHandle,PrBuffer,CurrentPos);
    close(FileHandle);
    CurrentPos=0;
    if((Ax&0xFF00)==0x0100)
      Active=0;
    Ax=0xD000|(Ax&0x00FF);
  }
  else 
    if(Ax=='??')
    {
      Bx=FP_SEG(Name);
      Ax='77';
    }
    else
      if(!Active)
      {
 	_DX=Dx;
        _AX=Ax;
        OldPrinter();
	Ax=_AX;
      }
      else
	Ax=0xD000|(Ax&0x00FF);
}

void main(int argc,char **argv)
{
  printf("Printer Spooler  Version 1.21 (c) 1991 7-Soft.\r\n");
  printf("Press F12 or type ENDPRN after end of printing.\r\n");
  Active=1;
  _AX='??';	/* Check installation */
  __emit__(0xCD,0x17); /* int 17h */
  if(_AX=='77')	/* Installed */
  {
    FileHandle=_BX;	/* Save file name adress */
    Twice=1;
    printf("PRINTER already installed.");
    printf("\r\nUse new file name (Y/N)?");
    if((bioskey(0)>>8)!=0x15)
      exit(printf("No."));
    else
      printf("Yes\r\n");
  }
  if(argc>1)
    strncpy(Name,argv[1],MAXPATH); 
  i=fnsplit(strupr(Name),Drive,Dir,Nam,Ext);
  if(i&WILDCARDS)
    exit(printf("Please, use no wildcards."));
  if((~i)&DRIVE)
    *(unsigned *)Drive=getdisk()+'A';
  if((~i)&DIRECTORY)
  {
    Dir[0]='\\';
    getcurdir(Drive[0]-'A'+1,Dir+1);
  }
  if((~i)&FILENAME)
    strncpy(Nam,"PSPOOL",MAXFILE);
  if((~i)&EXTENSION)
    strncpy(Ext,".PRN",MAXEXT);
  fnmerge(Name,Drive,Dir,Nam,Ext);
  printf("Spool file name is %s.\r\n",Name);
  i=open(Name,O_RDONLY);
  if(i!=(unsigned)-1)
  {
    close(i);
    printf("File %s already exists.\r\nPress Esc to cancel,Enter to rewrite,other key to backup :",Name);
    switch(bioskey(0)) {
	case 0x011B:exit(1);	/* Esc pressed */
	case 0x1C0D:break;	/* Enter pressed */
	default:strncpy(Dir,Name,(unsigned)(strrchr(Name,'.')-Name));
		strcat(Dir,".OLD");
		rename(Name,Dir);
              }
  }
  _creat(Name,0);
  if(!Twice)	/* Not installed => set vectors & keep */
  {
    OldPrinter =getvect(0x17);
    OldKeyboard=getvect(0x09);
    setvect(0x17,Printer);
    __emit__(0xFA); /* cli */
    setvect(0x09,Keyboard);
    __emit__(0xFB); /* sti */
    PrBuffer=MK_FP(_SS,_SP+1);
    keep(0, FP_SEG(PrBuffer) + FP_OFF(PrBuffer)/16 + 1 - _psp + BufferSize/16 + 1);
  }
  else	/* Installed => set new name & exit */
    movedata(FP_SEG(Name),FP_OFF(Name),FileHandle,FP_OFF(Name),strlen(Name));
}