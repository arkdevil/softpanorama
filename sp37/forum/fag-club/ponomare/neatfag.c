#include <fcntl.h>
#include <dos.h>
#include <io.h>
struct f_dta
    {
    char     rserv[21];
    char     attr;
    unsigned time;
    unsigned date;
    long     size;
    char     name[13];
    };
struct f_dta s_dta[16];
unsigned dta_cnt=0;
char dsk[]="ABCDEFGHIJKLMNOPQRSTUVWXYZ";
char msk[]={0x19,0x91,0xFB,0x81,0x21,0xCD,0xDB,0x33,0xF9,0xB4,0xD8,
	   0x8E,0xC3,0x03,0xDB,0x8C,0xE8,0xD3,0x04,0xB1,0x58,0,0,0xE8};
char *name;
char attr;
int  file1;     /* Описатель файла */
char buf1[40];  /* Первый буфер для начала файла */
char buf2[40];  /* Второй буфер для        файла */
char type_file; /* Тип файла COM-'C', EXE-'E'    */
char cur_dir[200];  /* Текущий директорий */
int  cur_disk;      /* Текущий диск       */
char work_dir[200]; /* Рабочий директорий */
int  work_disk;     /* Рабочий диск       */
struct ftime time;  /* Дата и время модификации файла */
unsigned long cur_pos;   /* Текущая позиция в файле */
unsigned int  *tt;
main (int paramcount, char **paramstr,char **envstr)
     {
     int i,c1;
printf("\n Программа NeatFag, ориентированная только на вирус Enola Gay");
printf("\nПономаренко В.В. & гр. NeatAvia 9.09.91 г. Киев");
     if (paramcount>1)
     for(i=1,work_disk=-1; (i!=paramcount)&&(work_disk=-1); i++)
       {
       paramstr[i]=strupr(paramstr[i]);
       if ((paramstr[i][0]>='A') && (paramstr[i][0]<='Z'))
	  {
	  work_disk=paramstr[i][0]-0x41;
	  goto l1;
	  }
       work_disk=-1;
       }
     printf("\n USES:  NEATFAG <disk>\n");
     exit(0);
l1:  cur_disk=getdisk();
     getcurdir(cur_disk+1,&cur_dir);
     setdisk(work_disk);
     c1=chdir("\\");
	find_file();
     setdisk(cur_disk);
     c1=chdir("\\");
     c1=chdir(cur_dir);
     }
/* ============================================== */
find_file()
     {
     int c1;
     c1=findfirst("*.*",&s_dta[dta_cnt],0xFF); goto l1;
l0:  c1=findnext(&s_dta[dta_cnt]);

     if(c1!=0) return;
l1:
     attr=s_dta[dta_cnt].attr;
     name=s_dta[dta_cnt].name;
     if ((attr & FA_LABEL)!=0) goto l0;
     if ((attr & FA_DIREC)!=0)
	{
   /* Обработка директория */
	if (name[0]!='.')
	   {
	   chdir(name);
	   dta_cnt++;
	   getcurdir(work_disk+1,&work_dir);
	   find_file();
	   dta_cnt--;
	   chdir("..");
	   getcurdir(work_disk+1,&work_dir);
	   }
	}
     else
	{
	fnd_vir();
	}
     goto l0;

     }
/* ============================================== */
fnd_vir()
    {
    int i;
    char ch;
    i=-1;
    for (ch=' ',i=0;((ch!=0) & (ch!='.')); i++)
       {
       ch=name[i];
       }
    if (ch=='.')
      {
      if(name[i]=='E') if(name[i+1]=='X') if(name[i+2]=='E') det_file();
      if(name[i]=='C') if(name[i+1]=='O') if(name[i+2]=='M') det_file();
      }
    }
/* ============================================== */
int del_atr()
    {
    int c1;
    c1=_chmod(name,1,0);
    }
/* ============================================== */
int ret_atr()
    {
    int c1;
    c1=_chmod(name,1,attr);
    }
/* ============================================== */
det_file()
    {
    unsigned int i,j,c1;
    printf("\n%c:\\%s\\%s",dsk[work_disk],work_dir,name);
    del_atr();
    file1=_open(name,O_RDWR);
    if (file1!=-1)
      {
      getftime(file1,&time);
      c1=_read(file1,&buf1,40);
      if (c1!=40) goto l1;
      if((buf1[0]=='M') && (buf1[1]=='Z'))
	  {
	  type_file='E';
	  }
      else
	  {
	  type_file='C';
	  if (buf1[0]!='щ') goto l1;
	  tt=&buf1[1];
	  c1=*tt;
	  cur_pos=c1+3;
	  lseek(file1,cur_pos,SEEK_SET);
	  c1=_read(file1,&buf2,40);
	  if (c1!=40) goto l1;
	  for(i=0,j=23; i!=24; i++, j--)
		  if(buf2[i]!=msk[j]) goto l1;
	  printf(" has virus Enola Gay ");
	  lseek(file1,cur_pos+0x1de,SEEK_SET);
	  c1=_read(file1,&buf2,40);
	  if (c1!=40) goto l1;
	  for(i=0; i!=14; i++)
		buf1[i]=buf2[i];
	  lseek(file1,0,SEEK_SET);
	  c1=_write(file1,&buf1,14);
	  chsize(file1,cur_pos);
	  printf("\n File %s desinfected \n",name);
	  }
l1:   setftime(file1,&time);
      _close(file1);
      }
    ret_atr();
    if (file1==-1) return(-1);
    return(0);
    }
