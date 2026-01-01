#define IGNORE 0
#define RETRY  1
char buferr[4000];
char *er_menu[]={ " Retry ",
	          " Abort " };
char *er_mes[]={ "",
		 "" };
int act_er[] = {0, 0};
int kol_er = 1;
int det_er = 7;
int col_no=0x70,col_in=0x20, col_nob=0x3e,
    col_chno=0x74,col_chin=0x24,col_shd=0x30,col_soff=0x33;
int er_x1=30, er_y1=13, er_x2=60,er_y2=13;
int er_xm=1,er_ym=1;
static char *err_msg[]={
	  "Защита  от  записи",
	  "   Unknown unit   ",
	  "  Драйвер не готов",
	  "  Неизвес. команда",
	  "  Неправ. (CRC)   ",
	  "   Bad request    ",
	  "   Seek error     ",
	  "Unknown media type",
	  "Сектор  не  найден",
	  "   Конец бумаги   ",
	  "  Неправ. чтение  ",
	  "  Неправ. запись  ",
	  "  Фатальная ошибка",
	  "  Зарезервировано ",
	  "  Зарезервировано ",
	  "   Несущ. диск    "};
error_win(){
  int retval;

  while(1){
   retval = ermenu(er_x1,er_y1,kol_er,er_menu,act_er,
			     det_er,er_xm,er_ym,er_mes,
				   col_no,col_in,col_chno,
					  col_chin,col_shd,col_soff);
      if(retval == 1){
	 retval = IGNORE;
	 puttext(er_x1-14,er_y1-4,er_x2+5+2,er_y2+2,buferr);
	 break;
      }
      if(retval == 0){
	 retval = RETRY;
	 puttext(er_x1-14,er_y1-4,er_x2+5+2,er_y2+2,buferr);
	 break;
      }
  }
  return(retval);
}
#pragma warn -par
 int handler(int errval,int ax,int bp,int si){
 unsigned di;
 int drive;
 int errorno;
 di=_DI;
 gettext(er_x1-14,er_y1-4,er_x2+5+2,er_y2+2,buferr);
/*------------------*/
    if (ax < 0){
       error_win();
       hardretn(IGNORE);
    }
/*------------------*/
 drive = ax & 0x00ff;
 errorno = di & 0x00ff;
 ClearBox(er_x1-15,er_y1-5,er_x2+3+2,er_y2+1,0,col_nob);
 sound(1000);
 delay(50);
 nosound();
 BOX(er_x1-12,er_y1-3,er_x2+3,er_y2-1,col_nob);
 SHADOW(er_x1-12,er_y1-4,er_x2+5+2,er_y2+2,7);
 PrintString(er_x1-10,er_y1-2,"Ошибка устройства",col_nob);
 PrintUsingCharX(er_x1+11,er_y1-2,'A'+drive,col_nob);
 PrintString(er_x1+12,er_y1-2,err_msg[errorno],col_nob);
 hardresume(error_win());
 puttext(er_x1-14,er_y1-4,er_x2+5+2,er_y2+2,buferr);
 return IGNORE;
 }
#pragma warn +par

void err(void){
 harderr(handler);
}
