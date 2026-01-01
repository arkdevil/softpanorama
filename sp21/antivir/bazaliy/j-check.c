/*========================= JB CHECKF ==================================*/
/*                                                                      */
/*  Module:  Check file for length, date-time and CRC.                  */
/*  Version: 1.2                                                        */
/*  Format:  j-check FileName [Check-data FileName]                     */
/*  Copyright (C) J.A.Bazalij  18.09.1989 Kiev 446-44-05                */
/*                                                                      */
/*======================================================================*/
#include <dir.h>
#include <dos.h>
#include <fcntl.h>
#include <stdio.h>
#include <io.h>
#include <stdlib.h>
#include <string.h>
#include <jdef.h>
/*......................................................................*/
#define MEM_SIZE   512*4*5             /* size for allocate memory      */
#define NEW_LINE   '\n'
#define HEAD       0x01

static int Data_head(void);
static int G_crc(void);
static int D_chk(void);
static int P_dat(void);
/*......................................................................*/
static char     Buf[MEM_SIZE];
static char     Path[MAXPATH];
static char     *Mp;
static unsigned char flag=0;
static long     Dcp;
static FILE     *Dfp;
static int      RC;
static unsigned CRC;
static PFI      W_ptr;
static struct   ffblk Ff;

static char   *Msg[15+1]= {
"\n   CHECK FILE  LENGTH, DATE, TIME and CRC.               J.A.Bazalij 1989 V1.2",

"Bad LENGTH program J-CHECKF.",                                  /*  1  */
"Bad CRC program J-CHECKF.",                                     /*  2  */
"\n   Syntax is: J-CHECKF filename [data-file]",                 /*  3  */
"              filename  - name checking file's (*,?)",          /*  4  */
"              data-file - filename data-file of J-CHECKF",      /*  5  */

"   Date: %.2hi.%.2hi.%.2i   Time %.2hi:%.2hi:%.2hi\n\n",        /*  6  */
"   Filename      Length     Date       Time     CRC",           /*  7  */
" ------------   -------   --------   --------   ----",          /*  8  */
/*XXXXXXXX.XXX   1234567   XX.XX.XX   XX.XX.XX   XXXX */
" %-12.12s   %7.li   %.2i.%.2i.%.2i   %.2i:%.2i:%.2i   %.4X",    /*  9  */

"J-CHECKF DATA-FILE length is zero.",                            /* 10  */
"Error headers J-CHECKF DATA-FILE.",                             /* 11  */
"J-CHECKF DATA-FILE ",                                           /* 12  */
" -OLD value",                                                   /* 13  */
" -NEW value\n",                                                 /* 14  */
" %-12.12s - File not found in J-CHECKF DATA-FILE.\n"            /* 15  */
};

/*""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""*/
void main(int argc, char *argv[]) {

char drive[MAXDRIVE];
char dir[MAXDIR];
char file[MAXFILE];
char ext[MAXEXT];
struct date D;
struct time T;
int CheckSum=0;
/*......................................................................*/
    puts(Msg[0]);
/*** printf("Length=%u CRC=%.4X %u\r\n",_pgm_len,_pgm_crc,_pgm_crc); ***/

    if (_pgm_len NE 8888)       { Mp=Msg[1]; goto error; }
    if (_pgm_crc NE 0)          { Mp=Msg[2]; goto error; }
/*......................................................................*/
    if (argc LT 2 OR argc GT 3)           goto help;
/*......................................................................*/
    getdate(&D);
    gettime(&T);
  printf(Msg[6],D.da_day,D.da_mon,D.da_year,T.ti_hour,T.ti_min,T.ti_sec);
/*......................................................................*/
   W_ptr = &P_dat;
   if (argc EQ 3)                            {
	strcpy(Path,argv[2]);
	if (NOT Data_head())   goto error;   }

/*........................ First File ..................................*/

    fnsplit(argv[1], drive,dir,file,ext);
    fnmerge(Path, drive,dir,file,ext);
    if ((RC=findfirst(argv[1], &Ff, 0)) NE 0)  goto err_fl;

    file[0] = '\0';
    ext[0]  = '\0';
    fnmerge(Path, drive,dir,file,ext);
    strcat(Path, Ff.ff_name);
/*........................ Next File ...................................*/
              while (NOT RC) {
    if  (NOT G_crc())  continue;
	 sprintf(Path,Msg[9],
		      Ff.ff_name, Ff.ff_fsize,
		      Ff.ff_fdate And 0x001F,
		     (Ff.ff_fdate Sr 5) And 0x000F,
		     (Ff.ff_fdate Sr 9)+80,
		      Ff.ff_ftime Sr 11,
		     (Ff.ff_ftime Sr 5) And 0x003F,
		      Ff.ff_ftime And 0x001F,
		      CRC );
	 W_ptr();            /*   ?????? if ???????*/
    RC = findnext( &Ff );
    fnmerge(Path, drive,dir,file,ext);
    strcat(Path,Ff.ff_name);
} /*                       end while                                    */
    puts(Msg[8]);
    RC = 1; goto EXIT;
/*......................................................................*/
err_fl:    Mp=_strerror(Path);
	   goto error;

help:	   puts(Msg[3]);
	   puts(Msg[4]);
	   Mp=Msg[5];

error:     puts(Mp);

EXIT:	   fcloseall();
	   exit(Not RC);
} /*====================================================================*/

/*=========================== Data_head ================================*/
/* SubFun: Header Data-File.                                            */
int Data_head(void) {
char *Df;
register i;

      if (findfirst(Path, &Ff, 0))  {       /* NE 0 - file not found    */
	 if ((Df = searchpath(Path)) EQ NULL)         goto err_df;
	 else if ((findfirst(Df, &Ff, 0)) NE 0)       goto err_df;
	 strcpy(Path,Df);
      }

      Mp=Msg[10];
      if ((Dfp=fopen(Path,"rt")) EQ NULL)     goto err_df;
      if (Ff.ff_fsize EQ 0)                   goto err_dh;

   Mp=Msg[11];
   for (i=0; i LT 6; i++) {
	if ((fgets(Buf,MAXPATH,Dfp)) EQ NULL)   goto err_dh;
	if (i EQ 1) {
	   if (strncmp(Buf,Msg[0]+1,strlen(Msg[0]-1)) NE 0)
						goto err_dh;
	}
   }
      if ((Dcp = ftell(Dfp)) LT 0)             goto err_df;
      W_ptr = &D_chk;
	return 1;
/*......................................................................*/
err_df: Mp=_strerror(Path);
err_dh: return 0;
} /*====================================================================*/

/*=========================== GET_CRC ==================================*/
/* SubFun: get CRC file.                                                */
int  G_crc(void)       {

unsigned *Adr;
int R_len, fh;
register i;

   CRC Xor_ CRC;                       /* clear CRC                     */
   RC = 0;                             /* RC=0 : Replay code = ERROR    */
/*......................................................................*/
   if ((fh = open(Path, O_RDONLY Or O_BINARY)) EQ -1)  goto ERR;
/*......................................................................*/
      R_len=1;
      Adr = (unsigned *)Buf;

      while (R_len GT 0) {

   if ((R_len = read(fh, Buf, MEM_SIZE)) LE 0)  {
	if (R_len EQ 0) break;         /*  end of file                  */
	else  goto ERR;
   }
   for (i=0; i LT R_len/2; i++)
	CRC Xor_ *(Adr + i);           /* unsigned int - format         */
   if (R_len NE (R_len/2)*2 )
	CRC Xor_ *(Buf + R_len -2);    /* char - format                 */
      }                            /* end while */

      RC = 1;
      goto END;
/*......................................................................*/
ERR:     puts(_strerror(Path));
	 RC = 0;

END:     close(fh);
         return RC;
} /*====================================================================*/

/*============================== P_dat =================================*/
/* SubFun: put data.                                                    */
int P_dat(void)      {

  if (NOT TEST_fl(flag,HEAD)) {
      puts(Msg[7]);
      puts(Msg[8]);
      SET_fl(flag,HEAD);
  }
  puts(Path);
    return 1;
} /*====================================================================*/

/*============================== D_CHECK ===============================*/
/* SubFun: check data file.                                             */
int D_chk(void)            {

 	    if (NOT TEST_fl(flag,HEAD)) {
		    puts(Msg[7]);
		    puts(Msg[8]);
		    SET_fl(flag,HEAD);
	     }
     if (fseek(Dfp,Dcp,SEEK_SET))   goto err_kf;

    while(Dfp)  {
       if ((fgets(Buf,MAXPATH,Dfp)) EQ NULL)
	   { if feof(Dfp) break;     goto err_kf;  }

	if (strncmp(Buf+1,Ff.ff_name,strlen(Ff.ff_name)) NE 0)
	    continue;

	if (strncmp(Buf,Path,strlen(Path)))  {

	       strcpy(Buf+strlen(Buf)-1, Msg[13] );
	       puts(Buf);
	       strcpy(Path+strlen(Path), Msg[14]);
	       puts(Path);
	}
	goto  end_k;
     } /*                      end while                                */
       printf(Msg[15],Ff.ff_name);
       P_dat();
       putchar(NEW_LINE);
/*......................................................................*/
end_k: return 1;

err_kf:   Mp=_strerror(Msg[12]);
err_k:    puts(Mp);
	  return 0;
} /*====================================================================*/
