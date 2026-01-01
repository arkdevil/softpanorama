#include <stdio.h>
#include <dos.h>
#include <conio.h>
#include <fcntl.h>
#include <math.h>

#define byte unsigned char

 int	x,y,i,i1,j,	/*	Служебные				*/
	logSect,	/*	Стартовый сектор файла			*/
	first,		/*	Номер первого сектора текущего dir	*/
	rr,		/*	Род работ				*/
	drive=2		/*	Номер привода				*/
	;



 struct  bbb			/*	Информация о формате устройства	*/
 {
   byte 	jmp[3];		/*	Стартовый адрес загрузчика	*/
   char		vers[8];	/*	Версия ДОС			*/
   int		SectSize;	/*	Размер сектора			*/
   byte		ClustSize;	/*	Размер кластера			*/
   int          ResSecs;	/*	Резерв секторов			*/
   byte		ColFat;		/*	Количество FAT			*/
   int		RootSize;	/*	Размер Root			*/
   int		TotSecs;	/*	Общее количество секторов в media 	*/
   byte		Media;		/*	FAT ID byte ( media )		*/
   int		FatSize;	/*	Размер FAT			*/
   int		TrkSecs;	/*	Количество секторов на дорожку	*/
   int		ColHead;	/*	Количество поверхностей		*/
   int		HidnSec;	/*	Спрятанных секторов		*/
   byte		boot[482];	/*	Текст загрузчика		*/
   } bpb ;


    unsigned char * fat;
    unsigned char left,right;

   char	name[]="boot-fat.sum";
	int	cf,i;
	int     old_sum,now_sum;
	int * buffer;



int	yes()
{
	char	c;
	c = getche(); cputs("\n\r");
	return c == 'y' || c == 'Y';
}


int	csum(byte* buf,int n)
{
	byte*	p = buf;
	int	s = 0;
	int	c = 0;
	while (--n >= 0)
	switch (c++ & 03) {
	case 0:

		s += *p++; break;
	case 1:
		s += ~(*p++); break;
	case 2:
		s += (*p++) << 1; break;
	case 3:
		s -= *p++; break;
	}
	return s;
}
 int fat_res(int num_clust, unsigned char * fat_array)
	{
	   int offs,res;
	   offs=(int)(num_clust * 1.5);
	   res=*( (int *) (fat_array + offs) );
	   if ( num_clust % 2 == 0 ) return ( res & 4095 );
			     else   return ( ( res   >> 4 ) & 4095);
	}


 main()
 {  int clst,secty;
     unsigned char * bbf;

   _fmode=O_BINARY;


textattr(0x0f);
clrscr();
textattr(0x70);
gotoxy(40,1);
cputs("Boot-Fat test ");

   gotoxy(20,3);
   cprintf("  Dos version  %u . %u ",_osmajor,_osminor);
gotoxy(20,5);
textattr(0x20);
	if ((cf = open(name, O_RDONLY)) < 0) {
		cputs("Cannot read file: "); cputs(name);
		       old_sum=0;
					     }
	   else { read(cf,&old_sum,2);
			close(cf);
		}

 i=absread(drive,1,0,&bpb);
    if (i!=0)
{
	cprintf("\r\n Disk error ...\r\n\n ");
}
else
{ now_sum = csum(bpb.boot,482);    }
 gotoxy(1,7);
cprintf("Boot csum old : %u  \n",old_sum); gotoxy(1,8);
cprintf("Boot csum now : %u  \n",now_sum);
cprintf("   Fat  size  : %u  \n",bpb.FatSize);
fat=( unsigned char * )malloc(512*bpb.FatSize);
bbf=( unsigned char * )malloc(512);
   i=absread(drive,bpb.FatSize,1,fat);
       if (i!=0)
{
	cprintf("\r\n Disk error ...\r\n\n ");
}
   for(i=0;i<(512*bpb.FatSize/3);i++ ) {

	       clst=fat_res(i,fat);
	     if(clst == 0xFF7) {
				  cprintf(" cluster %u marked as bad \n ",clst);

				secty=bpb.ResSecs+bpb.ColFat*bpb.FatSize+
				  (bpb.RootSize* 32 )/bpb.SectSize+
				  ((i-2)*bpb.ClustSize);
				   i=absread(drive,1,secty,bbf);
			    if (i!=0) { puts(" ATTANTION !!!   it is virus !!! \007 \n ");}
				   }
 printf("  %u ->  %X   \n",i,clst);


 }           getch();
    gotoxy(10,10);
       textattr(0x70);
    if ( old_sum == now_sum ) {  cputs("Ok"); }
       else  {
		cputs(" !!!!!!!! Boot was changed !!!!!!!!!");
		gotoxy(10,11);
		cputs(" !!    May be   it is  virus      !!");
		gotoxy(10,12);
	      cputs("      Write change (w),  restore boot (r) , quit(q) ? ");

	       switch ( getch()) {

	case 'w':
	case 'W':
		 if ((cf = open(name, O_WRONLY)) < 0) {
		cputs("\n Cannot write file: "); cputs(name);
		      exit(1);
					     }
	   else {  if (write(cf,&now_sum,2) < 0) {cputs("\n Error writing ...");
						   exit(1);
						 }
					    write(cf,bpb.boot,482);
			close(cf);
		} break;
	case 'r':
	case 'R': {
		    gotoxy(10,15);
		    cputs(" !!!!  Boot restore , are you shure ?  (Y/N)");
		    absread(drive,1,0,&bpb);
		    if (yes()){
			  if ((cf = open(name, O_RDONLY)) < 0) {
		cputs("Cannot write file: "); cputs(name);
		      exit(1);
		  }
	   else {  if (read(cf,&now_sum,2) < 0) {cputs("\n Error reading ...");
						 exit(1);
						}
		read(cf,bpb.boot,482);
			      i= abswrite(drive,1,0,&bpb);
					       gotoxy(10,17);
					       cputs("  All right");
			close(cf);
		} break;


			}
			      }
		  }




	     }
}

