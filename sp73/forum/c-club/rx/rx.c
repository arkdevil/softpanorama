/*--------------------------------------------------------------------      */
/* rxvar.h                                                                  */
/*NOTE:                                                                     */
/*This is a completly experimental program in it's pre-beta version.        */
/*It is not guaranteed to work properly under all circumstances, although   */
/*it has been tested for a couple of weeks. Everyone who uses this program  */
/*does this on his own risk, so if your machine explodes, don't tell me     */
/*you didn't know.                                                          */
/*                                                                          */
/*Andreas Gruen releases this software "as is", with no express or          */
/*implied warranty, including, but not limited to, the implied warranties   */
/*of merchantability and fitness for a particular purpose.                  */
/*                                                                          */
/*This program is completly free for everyone.                              */
/*You can do with it and its sources whatever you want, but it would        */
/*be fine to leave my name somewhere in the program or startup-banner.      */
/*---------------------------------------------------------------------     */
#include <stdio.h>
#include <string.h>
#include "rx.h"
#include "rxvar.h"

char copyleft[] = " (c) Copyright Andreas Gruen 1991.  All rights reserved.";

#define EXIT(X) {fprintf(stderr,"RX: %s\n",X);exit(1);}

#define ALIGN(X,Y) ( (ULONG)(X) << (Y) )    /* align to 2^Y   */

#define TMPSIZE 16384

#define MAX(X,Y) (((X) > (Y)) ? (X) : (Y))   /* for those who don't have it*/
#define MIN(X,Y) (((X) < (Y)) ? (X) : (Y))

#define GOT_TEXT 0
#define GOT_ID   1

#define MEMF_DISC  0x1000         /* memory-options*/
#define MEMF_MOVE  0x0010
#define MEMF_PREL  0x0040
#define FLAG_MASK  0x1050

DOSHEAD doshead;             /* DOS EXE-header*/
OSHEAD oshead;               /* WIN/ OS2-header*/
UCHAR tmpbuf[TMPSIZE];
int filenum;
char verbose = 0;
char *resname[16] = { "---","CURSOR","BITMAP","ICON","MENU","DIALOG",
                      "STRING","FONTDIR","FONT","ACCELERATOR","RCDATA",
                      "(unknown)-11-","CURSORHEADER","(unknown)-13-",
                      "ICONHEADER","NAMETABLE" };

char *stdclassname[6] = { "button","edit","static",
                        "listbox","scrollbar","combobox" };

char spaces[] =
  "                                                                ";

USHORT ntentry = 0;
#define MAXSPACE 64
#define SPC(X) (spaces + (MAXSPACE-(X)))
#define INDENTVAL 2
#define IS_MENUOPT (MF_GRAYED|MF_DISABLED|MF_CHECKED|MF_MENUBARBREAK|MF_MENUBREAK)

int get_rctab(FILE*);
int get_lstrings(FILE*);
int get_rcentry(FILE *,USHORT);

int put_icon(FILE *,FILE *,long);
int put_font(FILE *,FILE *,long);
int put_bitmap(FILE *,FILE *,long);
int put_cursor(FILE *,FILE *,long);
int put_menu(FILE *,FILE *,long,char *,USHORT,USHORT);
int put_dialog(FILE *,FILE *,long,char *,USHORT,USHORT);
int put_nametab(FILE *,FILE *,long);
int put_strings(FILE *,FILE *,long,char *,USHORT,USHORT);
int put_rcdata(FILE *,FILE *,long,long,char *,USHORT,USHORT);
int put_accel(FILE *,FILE *,long,char *,USHORT,USHORT);

int print_styles(FILE *,ULONG,UCHAR);
char *lookup_name(RCENTRY *, USHORT);
char * get_virttext(UCHAR);
int read_string(FILE *,char *);
int read_nstring(FILE *,char *,USHORT);
USHORT read_word(FILE *);
ULONG read_dword(FILE *);
UCHAR read_byte(FILE *);
int copy_block(FILE * ,FILE *, ULONG);
int read_textorid(FILE *,char*,int *);

int iflg,mflg,cflg,bflg,dflg,sflg,fflg,aflg,nflg,rflg;
int i_num,m_num,c_num,b_num,d_num,s_num,f_num,a_num,n_num,r_num,xtract;

char base_file[128],rc_file[128], temp_name[128];
char exe_file[128];
FILE *fprc;                /* .RC-File  */
main(argc,argv)
  int argc;
  char *argv[];
  {
    int i,n;
    FILE *fp;
    USHORT dossign,ossign;
    ULONG newhead;
    char *s;

    dossign = *( (USHORT *)"MZ");       /* well, hum, but it works*/
    ossign = *( (USHORT *)"NE");

    nflg = iflg = mflg = cflg = bflg = dflg = 0;
    sflg = fflg = aflg = rflg = 0;
    n_num = i_num = m_num = c_num = b_num = d_num = 0;
    s_num = f_num = a_num = r_num = 0;
    xtract = 0;

    while(--argc > 0 && (*++argv)[0] == '-')
      {
        for(s = (*argv)+1; *s && argc > 0 ; s++)
          {
            switch(*s)
              {
                case 'i':
                 iflg = xtract = 1;
                 break;
                case 'm':
                 mflg = xtract = 1;
                 break;
                case 'c':
                 cflg = xtract = 1;
                 break;
                case 'b':
                 bflg = xtract = 1;
                 break;
                case 'd':
                 dflg = xtract = 1;
                 break;
                case 's':
                 sflg = xtract = 1;
                 break;
                case 'f':
                 fflg = xtract = 1;
                 break;
                case 'a':
                 aflg = xtract = 1;
                 break;
                case 'n':
                 nflg = 1;
                 break;
                case 'r':
                 rflg = xtract = 1;
                 break;
                case 'x':
                 nflg = iflg = mflg = cflg = bflg = dflg = 1;
                 sflg = fflg = aflg = rflg = xtract = 1;
                 break;
                case 'v':
                  verbose = 1;
                  break;
                case '?':
                case 'h':
                  argc = -1;
                  break;
                default:
                  fprintf(stderr,"illegal option '%c'\n",*s);
                  argc = -1;
                  break;
              }
         }
      }
    if(argc <= 0)
      {
        fprintf(stderr,"Usage: RX -{ibcmdsfav} filename [outputname]\n");
        fprintf(stderr,"             -i   : extract ICONs\n");
        fprintf(stderr,"             -b   : extract BITMAPs\n");
        fprintf(stderr,"             -c   : extract CURSORs\n");
        fprintf(stderr,"             -m   : extract MENUs\n");
        fprintf(stderr,"             -d   : extract DIALOGs\n");
        fprintf(stderr,"             -s   : extract STRINGTABLEs\n");
        fprintf(stderr,"             -f   : extract FONTs\n");
        fprintf(stderr,"             -a   : extract ACCELERATORS\n");
        fprintf(stderr,"             -n   : extract NAMETABLE (internal use)\n");
        fprintf(stderr,"             -r   : extract RCDATA\n");
        fprintf(stderr,"             -x   : extract all\n");
        fprintf(stderr,"             -v   : verbose mode\n");
        fprintf(stderr,"separate files wil be created and\n");
        fprintf(stderr,"#include'd in RC-File\n");
        exit(1);
      }

    strcpy(exe_file,argv[0]);
    strupr(exe_file);
    if( (fp = fopen(exe_file,"rb")) == NULL)
      {
        strcat(exe_file,".EXE");
        if( (fp = fopen(exe_file,"rb")) == NULL)
          EXIT("can't open infile");
      }
    printf("RX: %s\n",copyleft);
    printf("Processing  '%s'\n",exe_file);
    if(argc > 1)
      {
        strcpy(base_file,argv[1]);
      }
    else
      {
        strcpy(base_file,exe_file);
      }
    /* look if there's an ext. (like .EXE),
       ext. are 4 chars max including '.'
       if yes : strip it */

    s = base_file + strlen(base_file) - 4;
    while(*s)
      {
        if(*s == '.')
          {
            *s = '\0';   /* strip*/
            break;       /* and go */
          }
        s++;
      }

    if(xtract)
      {
        strcpy(temp_name,base_file);
        strcat(temp_name,".rc");
      }
    else
      {
        strcpy(temp_name,"NUL");       /* no output,
                                          could be coded better, I know
                                          (sigh) */
      }
    if( (fprc = fopen(temp_name,"w")) == NULL)  EXIT("can't open RC-file");

    fprintf(fprc,"#include <windows.h>\n\n");   /* must be*/

    fread(&doshead,sizeof(DOSHEAD),1,fp);

    if(doshead.sign != dossign)    EXIT("Invalid file (no EXE, DLL...)");

    if(verbose)
      printf("Header-Size : %ld \n",(ULONG)(doshead.nparhead) << 4);

    if(doshead.posreloc != 0x40)
      {
        fclose(fp);
        EXIT("No Windows/OS2-executable or lib");       /*DOS-Exe*/
      }

    newhead = doshead.posnewhead;
    if(verbose)
      printf("OS-Header at : %lX \n",newhead);

    fseek(fp,newhead,0);
    fread(&oshead,sizeof(OSHEAD),1,fp);

    if(oshead.sign != ossign)
      EXIT("Invalid file (no EXE, DLL...) [new header]");

    build_nametable(fp);

    get_rctab(fp);     /* view/extract resources*/

    fclose(fp);
    fclose(fprc);
    return(0);
  }
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

get_rctab(fp)
  FILE *fp;
  {
    USHORT rcalign;
    ULONG rctab;

    rctab = (ULONG)oshead.posrctab+doshead.posnewhead;
    if(verbose)
      printf("Resourcetable at offset: %04lX\n",rctab);

    fseek(fp,rctab,0);
    rcalign = read_word(fp);        /* padding size = 2^rcalign bytes*/

    if(verbose)
      printf("Resource-alignment = %d bytes\n",1<<rcalign);
    while(get_rcentry(fp,rcalign));
    get_lstrings(fp);
    return(0);
  }
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

build_nametable(fp)
  FILE *fp;
  {
    USHORT rcalign;
    ULONG rctab;
    RCENTRY rce;
    USHORT rctyp,nrc,i;
    long tpos,tlen;

    rctab = (ULONG)oshead.posrctab+doshead.posnewhead;

    fseek(fp,rctab,0);
    rcalign = read_word(fp);        /* padding size = 2^rcalign bytes*/

    rctyp = read_word(fp);
    ntentry = 0;
    while(rctyp)
      {
        nrc = read_word(fp);
        read_dword(fp);               /*skip reserved bytes*/
        if((rctyp & 0x7fff) == 0x000f)   /* joop, we have it*/
          {
            for(i = 0; i < nrc; i++)
              {
                fread(&rce,sizeof(RCENTRY),1,fp);
                tpos = ALIGN(rce.datp,rcalign);
                tlen = ALIGN(rce.len,rcalign);
                fill_ntable(fp,tpos);
              }
            break;
          }
        else
          {
            fseek(fp,(ULONG)sizeof(RCENTRY)*(ULONG)nrc,1);  /*skip it*/
          }
        rctyp = read_word(fp);
      }
    return(ntentry);
  }
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

int fill_ntable(fp,filep)
  FILE *fp;
  long filep;
  {
    long fpos;
    char xname[16];
    char rcname[256];
    USHORT len,rctype,rcnum,i;
    long filelen;

    fpos = ftell(fp);

    fseek(fp,filep,0);

    while(len = read_word(fp))
      {
        rctype = read_word(fp);
        rctype &= 0x000f;
        rctype %= 11;             /* refs to icons are refs to iconheaders
                                     same for bitmaps, think about that */
        nametab[ntentry].type = rctype;
        nametab[ntentry].num = read_word(fp) & 0x7fff;
        read_byte(fp);            /* skip 1 byte */
        fread(nametab[ntentry].name,1,len-7,fp);
                 /* may use read_string, but this is safe*/
        ntentry++;
      }
    fseek(fp,fpos,0);
    return(0);
  }
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

get_lstrings(fp)
  FILE *fp;
  {
    UCHAR clen;
    USHORT len;
    char buff[256];

    while(clen = read_byte(fp))
      {
        read_nstring(fp,buff,(USHORT)clen);
        printf("Resource-Name : %s\n",buff);
      }
    return(0);
  }

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

get_rcentry(fp,rcalign)
  FILE *fp;
  USHORT rcalign;
  {

    RCENTRY rce;
    FILE *fpout;
    USHORT rctyp,nrc,i;
    char *pname;
    long tpos,tlen;

    fread(&rctyp,2,1,fp);
    if(rctyp == 0)   return(0);    /* got all */

    fread(&nrc,2,1,fp);
    fread(tmpbuf,1,4,fp);          /*reserved bytes*/


    if((rctyp & 0x7fff) < 16)
      {
        printf("%u %s (s)\n",nrc,resname[rctyp & 0xf]);
      }
    else
      {
        printf("unknown resource-type %04X (%u resources)\n",nrc,rctyp);
      }

    for(i = 0; i < nrc; i++)
      {
        fread(&rce,sizeof(RCENTRY),1,fp);
        tpos = ALIGN(rce.datp,rcalign);
        tlen = ALIGN(rce.len,rcalign);
        if(verbose)
          printf("offset %04lX  len = %lu ord= %04X flags=%04X\n"
                 ,tpos,tlen,rce.id,rce.flags);

/* extract it */
        switch(rctyp & 0x0fff)
          {
            case 0x0001:               /*CURSOR-resource*/
              if(cflg)
                {
                  sprintf(temp_name,"CURS%d.CUR",c_num++);
                  if((fpout = fopen(temp_name,"wb")) == NULL)  EXIT("file-write failed");
                  put_cursor(fp,fpout,tpos);
                  fclose(fpout);
                  rce.id--;         /* don't ask me why
                                       but cursor-numbers start with 2*/
                  if(pname = lookup_name(&rce,rctyp))
                    fprintf(fprc,"%s CURSOR ",pname);
                  else
                    fprintf(fprc,"%d CURSOR ",rce.id & 0x7fff);
                  print_flags(fprc,rce.flags,rctyp & 0x0f);
                  fprintf(fprc,"%s\n",temp_name);
                }
              break;
            case 0x0002:               /*BITMAP-resource*/
              if(bflg)
                {
                  sprintf(temp_name,"BITM%d.BMP",b_num++);
                  if((fpout = fopen(temp_name,"wb")) == NULL)  EXIT("file-write failed");
                  put_bitmap(fp,fpout,tpos);
                  fclose(fpout);
                  if(pname = lookup_name(&rce,rctyp))
                    fprintf(fprc,"%s BITMAP ",pname);
                  else
                    fprintf(fprc,"%d BITMAP ",rce.id & 0x7fff);
                  print_flags(fprc,rce.flags,rctyp & 0x0f);
                  fprintf(fprc,"%s\n",temp_name);
                }
              break;
            case 0x0003:               /*ICON-resource*/
              if(iflg)
                {
                  sprintf(temp_name,"ICON%d.ICO",i_num++);
                  if((fpout = fopen(temp_name,"wb")) == NULL)  EXIT("file-write failed");
                  put_icon(fp,fpout,tpos);
                  fclose(fpout);
                  if(pname = lookup_name(&rce,rctyp))
                    fprintf(fprc,"%s ICON ",pname);
                  else
                    fprintf(fprc,"%d ICON ",rce.id & 0x7fff);
                  print_flags(fprc,rce.flags,rctyp & 0x0f);
                  fprintf(fprc,"%s\n",temp_name);
                }
              break;
            case 0x0008:               /*FONT-resource  */
              if(fflg)
                {
                  sprintf(temp_name,"FONT%d.FNT",f_num++);
                  if((fpout = fopen(temp_name,"wb")) == NULL)  EXIT("file-write failed");
                  put_font(fp,fpout,tpos);
                  fclose(fpout);
                  /* fonts don't have names*/
                  fprintf(fprc,"%d FONT ",rce.id & 0x7fff);
                  print_flags(fprc,rce.flags,rctyp & 0x0f);
                  fprintf(fprc,"%s\n",temp_name);
                }
              break;
            case 0x0004:               /*MENU-resource */
              if(mflg)
                {
                  strcpy(temp_name,base_file);
                  strcat(temp_name,".MEN");
                  if(mflg++ == 1)    /* first menu should overwrite*/
                    {
                      fprintf(fprc,"#include \"%s\"\n",temp_name);
                      if((fpout = fopen(temp_name,"w")) == NULL)
                        EXIT("file-write failed");
                    }
                  else
                    {
                      if((fpout = fopen(temp_name,"a")) == NULL)
                        EXIT("file-write failed");
                    }
                  pname = lookup_name(&rce,rctyp);
                  put_menu(fp,fpout,tpos,pname,rce.id & 0x7fff,rce.flags);
                  fclose(fpout);
                }
              break;
            case 0x0005:               /*DIALOG-resource */
              if(dflg)
                {
                  strcpy(temp_name,base_file);
                  strcat(temp_name,".DLG");
                  if(dflg++ == 1)    /* first should overwrite*/
                    {
                      fprintf(fprc,"#include \"%s\"\n",temp_name);
                      if((fpout = fopen(temp_name,"w")) == NULL)
                        EXIT("file-write failed");
                    }
                  else
                    {
                      if((fpout = fopen(temp_name,"a")) == NULL)
                        EXIT("file-write failed");
                    }
                  pname = lookup_name(&rce,rctyp);
                  put_dialog(fp,fpout,tpos,pname,rce.id & 0x7fff,rce.flags);
                  fclose(fpout);
                }
              break;
            case 0x0006:               /*STRING-resource*/
              if(sflg)
                {
                  strcpy(temp_name,base_file);
                  strcat(temp_name,".STR");
                  if(sflg++ == 1)    /* first should overwrite*/
                    {
                      fprintf(fprc,"#include \"%s\"\n",temp_name);
                      if((fpout = fopen(temp_name,"w")) == NULL)
                        EXIT("file-write failed");
                    }
                  else
                    {
                      if((fpout = fopen(temp_name,"a")) == NULL)
                        EXIT("file-write failed");
                    }
                  pname = lookup_name(&rce,rctyp);
                  put_strings(fp,fpout,tpos,pname,rce.id & 0x7fff,rce.flags);
                  fclose(fpout);
                }
              break;
            case 0x0007:               /*FONTDIR-resource,
                                         not implemented*/
              break;
            case 0x0009:               /*ACCEL-resource*/
              if(aflg)
                {
                  strcpy(temp_name,base_file);
                  strcat(temp_name,".ACC");
                  if(aflg++ == 1)    /* first should overwrite*/
                    {
                      fprintf(fprc,"#include \"%s\"\n",temp_name);
                      if((fpout = fopen(temp_name,"w")) == NULL)
                        EXIT("file-write failed");
                    }
                  else
                    {
                      if((fpout = fopen(temp_name,"a")) == NULL)
                        EXIT("file-write failed");
                    }
                  pname = lookup_name(&rce,rctyp);
                  put_accel(fp,fpout,tpos,pname,rce.id & 0x7fff,rce.flags);
                  fclose(fpout);
                }
              break;
            case 0x000a:               /*RCDATA-resource */
              if(rflg)
                {
                  strcpy(temp_name,base_file);
                  strcat(temp_name,".RCD");
                  if(rflg++ == 1)    /* first should overwrite*/
                    {
                      fprintf(fprc,"#include \"%s\"\n",temp_name);
                      if((fpout = fopen(temp_name,"w")) == NULL)
                        EXIT("file-write failed");
                    }
                  else
                    {
                      if((fpout = fopen(temp_name,"a")) == NULL)
                        EXIT("file-write failed");
                    }
                  pname = lookup_name(&rce,rctyp);
                  put_rcdata(fp,fpout,tpos,tlen,pname,rce.id & 0x7fff,rce.flags);
                  fclose(fpout);
                }
              break;
            case 0x000c:               /*CURSOR-header-resource,
                                         undocumented, not needed*/
              break;
            case 0x000e:               /*ICON-header-resource,
                                         undocumented, no need*/
              break;
            case 0x000f:               /*NAMETABLE-resource,
                                         undocumented (?)*/
              if(nflg)
                {
                  strcpy(temp_name,base_file);
                  strcat(temp_name,".NAM");
                  if(nflg++ == 1)    /* first should overwrite*/
                    {
                      if((fpout = fopen(temp_name,"w")) == NULL)
                        EXIT("file-write failed");
                    }
                  else
                    {
                      if((fpout = fopen(temp_name,"a")) == NULL)
                        EXIT("file-write failed");
                    }
                  put_nametab(fp,fpout,tpos);
                  fclose(fpout);
                }
              break;
            default:
              break;
          }
      }
    return(1);
  }
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

int put_icon(fp,fpout,filep)
  FILE *fp,*fpout;
  long filep;
  {
    long fpos;
    char xname[16];
    BMHEAD dib;
    ICONHEAD ih;
    USHORT len;
    long filelen;

    fpos = ftell(fp);

    fseek(fp,filep,0);
    fread(&dib,sizeof(BMHEAD),1,fp);

    fseek(fp,filep,0);

    ih.reserv1 = 0;
    ih.rctype  = 1;
    ih.count   = 1;                        /*images in file*/
    ih.wid     = (UCHAR)dib.width;
    ih.hei     = (UCHAR)(dib.height>>1);   /*important ! AND-MASK in DIB*/
    ih.colors  = (UCHAR)(1<<dib.bitcount);
    ih.reserv2 = 0;
    ih.xhot    = 0;                        /*reserved for icons*/
    ih.yhot    = 0;
    ih.DIBsize = dib.size +
                 4L*(ULONG)ih.colors +    /* size of colortable*/
                                          /* size of bitmap*/
                 ((ULONG)ih.wid*(ULONG)ih.hei * (ULONG)dib.bitcount)/8 +
                                          /*size of bitmask*/
                 ((ULONG)ih.wid*(ULONG)ih.hei)/8;
    ih.DIBoff  = sizeof(ICONHEAD);         /*hope for packed struct's*/

    fwrite(&ih,sizeof(ICONHEAD),1,fpout);

    copy_block(fpout,fp,ih.DIBsize);

    fseek(fp,fpos,0);
    return(0);
  }
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

int put_cursor(fp,fpout,filep)
  FILE *fp,*fpout;
  long filep;
  {
    long fpos;
    char xname[16];
    BMHEAD dib;
    CURSORHEAD cu;
    USHORT len;
    long filelen;

    fpos = ftell(fp);

    fseek(fp,filep,0);
    read_dword(fp);                     /* don't ask me why, skip dummy*/
    fread(&dib,sizeof(BMHEAD),1,fp);

    fseek(fp,filep,0);
    read_dword(fp);                     /* don't ask me why, skip dummy*/

    cu.reserv1 = 0;
    cu.rctype  = 2;
    cu.count   = 1;                        /*images in file*/
    cu.wid     = (UCHAR)dib.width;
    cu.hei     = (UCHAR)(dib.height>>1);   /*important ! AND-MASK in DIB*/
    cu.colors  = (UCHAR)(1<<dib.bitcount);
    cu.reserv2 = 0;
    cu.xhot    = 0;                        /*hotspot set to 0,0, sorry*/
    cu.yhot    = 0;
    cu.DIBsize = dib.size +
                 4L*(ULONG)cu.colors +    /* size of colortable*/
                                          /* size of bitmap*/
                 ((ULONG)cu.wid*(ULONG)cu.hei * (ULONG)dib.bitcount)/8 +
                                          /*size of bitmask*/
                 ((ULONG)cu.wid*(ULONG)cu.hei)/8;
    cu.DIBoff  = sizeof(CURSORHEAD);         /*hope for packed struct's*/

    fwrite(&cu,sizeof(CURSORHEAD),1,fpout);

    copy_block(fpout,fp,cu.DIBsize);

    fseek(fp,fpos,0);
    return(0);
  }
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

int put_bitmap(fp,fpout,filep)
  FILE *fp,*fpout;
  long filep;
  {
    long fpos;
    char xname[16];
    BMHEAD dib;
    BMFHEAD bfh;
    USHORT len;
    long filelen;

    fpos = ftell(fp);

    fseek(fp,filep,0);
    fread(&dib,sizeof(BMHEAD),1,fp);

    fseek(fp,filep,0);

    bfh.sign    = (USHORT)'B' + (USHORT)'M'* 256;
    bfh.fsize   = (ULONG)sizeof(BMFHEAD)+    /*filesize*/
                  dib.size +
                  (ULONG)(1<<dib.bitcount) * 4L +
                  ((ULONG)dib.width*(ULONG)dib.height * (ULONG)dib.bitcount)/8;

                        /*offset to bits in file*/
    bfh.offset  = (ULONG)sizeof(BMFHEAD)+
                  dib.size +
                  (ULONG)(1<<dib.bitcount) * 4L;

    bfh.reserv1 = bfh.reserv2 = 0;

    fwrite(&bfh,sizeof(BMFHEAD),1,fpout);

    copy_block(fpout,fp,bfh.fsize - sizeof(BMFHEAD));

    fseek(fp,fpos,0);
    return(0);
  }
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

int put_font(fp,fpout,filep)
  FILE *fp,*fpout;
  long filep;
  {
    long fpos;
    char xname[16];
    USHORT len;
    long filelen;

    fpos = ftell(fp);

    fseek(fp,filep,0);
    read_word(fp);                /*skip dummy*/
    filelen = read_dword(fp);

    fseek(fp,filep,0);    /* and back*/

    copy_block(fpout,fp,filelen);

    fseek(fp,fpos,0);
    return(0);
  }
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

int put_strings(fp,fpout,filep,sname,sid,flags)
  FILE *fp,*fpout;
  long filep;
  char *sname;
  USHORT sid;
  USHORT flags;
                    /* ATTENTION: stringtable names not supported
                       (well, officially not allowed but possible,
                         try it !   Maybe I will work on it) */
  {
    long fpos;
    char xname[16];
    char string[257];   /* enough !*/
    UCHAR slen;
    USHORT len;
    USHORT i,n;
    UCHAR *strp;
    long filelen;

    fpos = ftell(fp);

    fseek(fp,filep,0);

    fprintf(fpout,"STRINGTABLE ");
    print_flags(fpout,flags,6);
    fprintf(fpout,"\nBEGIN\n");
    for(i = 0; i < 16; i++)     /*16 strings in a segment */
      {
        slen = read_byte(fp);
        if(slen)                    /* ugly-but-must-be*/
          {
            read_nstring(fp,string,slen);
            strp = string;
            fprintf(fpout,"  %u,\"",i+(sid-1)*16);
            while(*strp)
              {
                if(*strp < 0x20)
                  fprintf(fpout,"\\%03o",*strp);
                else if(*strp == '"')
                  fprintf(fpout,"\"\"",*strp);
                else if(*strp == '\\')
                  fprintf(fpout,"\\\\");
                else
                  fprintf(fpout,"%c",*strp);
                strp++;
              }
            fprintf(fpout,"\"\n");
          }
      }
    fprintf(fpout,"END\n");
    fseek(fp,fpos,0);
    return(0);
  }
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

int put_rcdata(fp,fpout,filep,tlen,rname,rid,flags)
  FILE *fp,*fpout;
  long filep,tlen;
  char *rname;
  USHORT rid;
  USHORT flags;
  {
    long fpos;
    char xname[16];
    USHORT len;
    long filelen;
    USHORT i;
    char first;
    UCHAR c;         /*I don't like accessing arrays to much*/

    fpos = ftell(fp);

    fseek(fp,filep,0);
    filelen = tlen;

    if(rname != NULL)
      fprintf(fpout,"%s RCDATA ",rname);
    else
      fprintf(fpout,"%d RCDATA ",rid);
    print_flags(fpout,flags,10);

    fprintf(fpout,"\nBEGIN\n");

    first = 1;
    while(filelen)
      {
        len = fread(tmpbuf,1,(USHORT)MIN(filelen,TMPSIZE),fp);
        for(i = 0; i < len; i++)
          {
            c = tmpbuf[i];

            if((i & 15) == 0)
              {
                if(first)       /* are there better ways ??  sure ! */
                  {
                    fprintf(fpout,"\n  \"",c);
                    first = 0;
                  }
                else
                  fprintf(fpout,"\",\n  \"",c);
              }

            if(c >= ' ' && c <= '~')
              fprintf(fpout,"%c",c);
            else
              {
                if(c == 0)              /* occurs quite often */
                  fprintf(fpout,"\\0");
                else
                  fprintf(fpout,"\\%03o",c);
              }

            if (filelen-i <= 1)          fprintf(fpout,"\"");
          }
        filelen -= len;
      }
    fprintf(fpout,"\nEND\n");
    fseek(fp,fpos,0);
    return(0);
  }
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

int put_accel(fp,fpout,filep,aname,aid,flags)
  FILE *fp,*fpout;
  long filep;
  char *aname;
  USHORT aid;
  USHORT flags;
  {
    long fpos;
    char xname[16];
    char *vkname;
    UCHAR keytype,keyval;
    USHORT idval;

    fpos = ftell(fp);

    fseek(fp,filep,0);
    if(aname != NULL)
      fprintf(fpout,"%s ACCELERATORS ",aname);
    else
      fprintf(fpout,"%d ACCELERATORS ",aid);
    print_flags(fpout,flags,9);

    fprintf(fpout,"\nBEGIN\n");
    do
      {
        keytype = read_byte(fp);
        keyval  = read_byte(fp);
        read_byte(fp);                           /* skip dummy*/
        idval = read_word(fp);
        if((keytype & 0x01) == 0)                /*ascii */
          {
            if(keyval < 0x20)
              fprintf(fpout,"  \"^%c\",%d",keyval+'@',idval);
            else
              fprintf(fpout,"  \"%c\",%d",keyval,idval);
          }
        else                             /*virtkey*/
          {
            if(keyval >= 'A' && keyval <= 'Z')
              fprintf(fpout,"  \"%c\",%d,VIRTKEY",keyval,idval);
            else if(keyval >= '0' && keyval <= '9')
              fprintf(fpout,"  \"%c\",%d,VIRTKEY",keyval,idval);
            else
              {
                vkname = get_virttext(keyval);
                if(vkname != NULL)
                  fprintf(fpout,"  VK_%s,%d,VIRTKEY",vkname,idval);
                else
                  fprintf(fpout,"  %u,%d,VIRTKEY",keyval,idval);
              }
          }
        if(keytype & 0x02)
          fprintf(fpout,",NOINVERT");
        if(keytype & 0x04)
          fprintf(fpout,",SHIFT");
        if(keytype & 0x08)
          fprintf(fpout,",CONTROL");
        if(keytype & 0x10)
          fprintf(fpout,",ALT");
        fprintf(fpout,"\n");
      } while ( (keytype &0x80) == 0);
    fprintf(fpout,"END\n");
    fseek(fp,fpos,0);
    return(0);
  }
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

int put_menu(fp,fpout,filep,mname,mid,flags)
  FILE *fp,*fpout;
  long filep;
  char *mname;
  USHORT mid;
  USHORT flags;
  {
    long fpos;
    char xname[16];
    int indent;
    USHORT mflag,idval;
    char menustr[256],*msp;    /*should be enough*/
    char levelend[32],level;   /* have you seen an application
                                  32 menu-levels deep ?? */

    for(level = 0; level < 32;level++)  levelend[level] = 0;
    level = 0;

    fpos = ftell(fp);

    fseek(fp,filep,0);
    read_dword(fp);                        /* unused*/

    if(mname != NULL)
      fprintf(fpout,"%s MENU ",mname);
    else
      fprintf(fpout,"%d MENU ",mid);
    print_flags(fpout,flags,4);
    fprintf(fpout,"\nBEGIN\n");

    indent = INDENTVAL;
    level++;
    levelend[0] = 1;

    while(level > 0)
      {
        mflag = read_word(fp);                    /*menu-flags*/
        if(!(mflag & MF_POPUP))
          idval = read_word(fp);                  /*id-value*/

        read_string(fp,menustr);

        if(mflag & MF_POPUP)
          {
            fprintf(fpout,"%sPOPUP \"%s\"",SPC(indent),menustr);
            if(mflag & MF_GRAYED)        fprintf(fpout,", GRAYED");
            if(mflag & MF_DISABLED)      fprintf(fpout,", INACTIVE");
            if(mflag & MF_CHECKED)       fprintf(fpout,", CHECKED");
            if(mflag & MF_MENUBARBREAK)  fprintf(fpout,", MENUBARBREAK");
            if(mflag & MF_MENUBREAK)     fprintf(fpout,", MENUBREAK");
            fprintf(fpout,"\n%sBEGIN\n",SPC(indent));
            indent += INDENTVAL;
            if(mflag & MF_END)
              {
                levelend[level] = 1;
              }
            level++;
          }
        else
          {
            if(menustr[0] || (mflag & IS_MENUOPT))
              fprintf(fpout,"%sMENUITEM \"%s\", %d",SPC(indent),menustr,idval);
            else
              fprintf(fpout,"%sMENUITEM SEPARATOR",SPC(indent));

            if(mflag & MF_GRAYED)        fprintf(fpout,", GRAYED");
            if(mflag & MF_DISABLED)      fprintf(fpout,", INACTIVE");
            if(mflag & MF_CHECKED)       fprintf(fpout,", CHECKED");
            if(mflag & MF_MENUBARBREAK)  fprintf(fpout,", MENUBARBREAK");
            if(mflag & MF_MENUBREAK)     fprintf(fpout,", MENUBREAK");
            fprintf(fpout,"\n");
            if(mflag & MF_END)
              {
                indent -= INDENTVAL;
                level--;
                fprintf(fpout,"%sEND\n",SPC(indent));
                while(levelend[level] && level)
                  {
                    indent -= INDENTVAL;
                    level--;
                    fprintf(fpout,"%sEND\n",SPC(indent));
                  }
              }
          }
      }
    fseek(fp,fpos,0);
    return(0);
  }
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

int put_dialog(fp,fpout,filep,dname,did,flags)
  FILE *fp,*fpout;
  long filep;
  char *dname;
  USHORT did;
  USHORT flags;
  {
    long fpos;
    char xname[16];
    USHORT len;
    ULONG rstyle;
    UCHAR rclass;
    UCHAR nctrl;                    /* # of controls in box*/
    USHORT fontsize;
    char fontname[64];
    USHORT x,y,wid,hei,idval;
    UCHAR text[256],*txtp;                 /* should be enough*/
    char classname[256],*classp;
    int i;
    int numref;
    long filelen;

    fpos = ftell(fp);

    fseek(fp,filep,0);    /* and back*/

    rstyle = read_dword(fp);        /* dlgbox-style*/
    nctrl = read_byte(fp);          /* # controls*/
    x     = read_word(fp);
    y     = read_word(fp);
    wid   = read_word(fp);
    hei   = read_word(fp);

    if(dname != NULL)
      fprintf(fpout,"%s DIALOG ",dname);
    else
      fprintf(fpout,"%d DIALOG ",did);
    print_flags(fpout,flags,5);

    fprintf(fpout," %d, %d, %d, %d\n",x,y,wid,hei);
    fprintf(fpout,"STYLE ");
    print_styles(fpout,rstyle,0);
    fprintf(fpout,"\n");

    if(read_textorid(fp,text,&numref) == GOT_ID)   /* MENU name*/
      fprintf(fpout,"MENU %d\n",numref);
    else if(text[0])
      fprintf(fpout,"MENU \"%s\"\n",text);

    if(read_textorid(fp,text,&numref) == GOT_ID)   /* CLASS name*/
      fprintf(fpout,"CLASS %d\n",numref);
    else if(text[0])
      fprintf(fpout,"CLASS \"%s\"\n",text);

    if(read_textorid(fp,text,&numref) == GOT_ID)   /* CAPTION */
      fprintf(fpout,"CAPTION %d\n",numref);
    else if(text[0])
      fprintf(fpout,"CAPTION \"%s\"\n",text);

    if(rstyle & DS_SETFONT)
      {
        fontsize = read_word(fp);
        read_string(fp,fontname);
        fprintf(fpout,"FONT %u,\"%s\"\n",fontsize,fontname);
      }


    fprintf(fpout,"\nBEGIN\n");

    for(i = 0; i < nctrl;i++)
      {
        x     = read_word(fp);
        y     = read_word(fp);
        wid   = read_word(fp);
        hei   = read_word(fp);
        idval = read_word(fp);
        rstyle = read_dword(fp);         /* ctrl-style*/
        rclass = read_byte(fp);          /* class (std or by name) */
        if(rclass < 0x80 || rclass > 0x85)   /* non standard class*/
          {
            classname[0] = rclass;
            if(rclass)
              read_string(fp,classname+1);
          }
        else
          {
            strcpy(classname,stdclassname[rclass & 0x0f]);
          }

        if(read_textorid(fp,text,&numref) == GOT_ID)
            fprintf(fpout,"  CONTROL %d, %d,\"%s\",",
                           numref,idval,classname,rstyle,x,y,wid,hei);
        else
            fprintf(fpout,"  CONTROL \"%s\", %d,\"%s\",",
                          text,idval,classname,rstyle,x,y,wid,hei);

        read_byte(fp);                        /*there's another 0*/
        if(rclass < 0x80 || rclass > 0x85)   /* non standard class*/
          {
            fprintf(fpout,"0x%08lX",rstyle);
          }
        else
          {
            print_styles(fpout,rstyle,rclass);
          }
        fprintf(fpout,",%d, %d, %d, %d\n",
                       x,y,wid,hei);
      }
    fprintf(fpout,"END\n");
    fseek(fp,fpos,0);
    return(0);
  }
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

int put_nametab(fp,fpout,filep)
  FILE *fp,*fpout;
  long filep;
  {
    long fpos;
    char xname[16];
    char rcname[256];
    USHORT len,rctype,rcnum,i;
    long filelen;

    fpos = ftell(fp);

    fseek(fp,filep,0);    /* and back*/

    while(len = read_word(fp))
      {
        rctype = read_word(fp);
        rctype &= 0x000f;
        rctype %= 11;             /* refs to icons are refs to iconheaders
                                     same for bitmaps, think about that */
        rcnum = read_word(fp);
        rcnum &= 0x7fff;
        read_byte(fp);            /* skip 1 byte */
        fread(rcname,1,len-7,fp);   /* may use read_string, but this is safe*/
        fprintf(fpout,"%s %s @%d\n",rcname,resname[rctype],rcnum);
      }
    fseek(fp,fpos,0);
    return(0);
  }
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

int print_styles(fpout,rstyle,rclass)
  FILE *fpout;
  ULONG rstyle;
  UCHAR rclass;
  {
                             /* common window styles*/
    fprintf(fpout,"0");      /* sorry!*/
    if(rstyle & WS_VISIBLE)
      fprintf(fpout,"|WS_VISIBLE");
    if(rstyle & WS_POPUP)
      fprintf(fpout,"|WS_POPUP");
    if(rstyle & WS_CHILD)
      fprintf(fpout,"|WS_CHILD");
    if(rstyle & WS_MINIMIZE)
      fprintf(fpout,"|WS_MINIMIZE");
    if(rstyle & WS_DISABLED)
      fprintf(fpout,"|WS_DISABLED");
    if(rstyle & WS_DISABLED)
      fprintf(fpout,"|WS_DISABLED");
    if(rstyle & WS_CLIPSIBLINGS)
      fprintf(fpout,"|WS_CLIPSIBLINGS");
    if(rstyle & WS_CLIPCHILDREN)
      fprintf(fpout,"|WS_CLIPCHILDREN");
    if(rstyle & WS_MAXIMIZE)
      fprintf(fpout,"|WS_MAXIMIZE");
    if((rstyle & WS_CAPTION) == WS_CAPTION)
      fprintf(fpout,"|WS_CAPTION");
    else
      {
        if(rstyle & WS_BORDER)
          fprintf(fpout,"|WS_BORDER");
        if(rstyle & WS_DLGFRAME)
          fprintf(fpout,"|WS_DLGFRAME");
      }
    if(rstyle & WS_VSCROLL)
      fprintf(fpout,"|WS_VSCROLL");
    if(rstyle & WS_HSCROLL)
      fprintf(fpout,"|WS_HSCROLL");
    if(rstyle & WS_SYSMENU)
      fprintf(fpout,"|WS_SYSMENU");
    if(rstyle & WS_THICKFRAME)
      fprintf(fpout,"|WS_THICKFRAME");
    if(rstyle & WS_GROUP)
      fprintf(fpout,"|WS_GROUP");
    if(rstyle & WS_TABSTOP)
      fprintf(fpout,"|WS_TABSTOP");
    if(rstyle & WS_MINIMIZEBOX)
      fprintf(fpout,"|WS_MINIMIZEBOX");
    if(rstyle & WS_MAXIMIZEBOX)
      fprintf(fpout,"|WS_MAXIMIZEBOX");
    if(rclass == 0)                     /* is dialog-box style*/
      {
        if(rstyle & DS_ABSALIGN)
          fprintf(fpout,"|DS_ABSALIGN");
        if(rstyle & DS_SYSMODAL)
          fprintf(fpout,"|DS_SYSMODAL");
        if(rstyle & DS_LOCALEDIT)
          fprintf(fpout,"|DS_LOCALEDIT");
        if(rstyle & DS_SETFONT)
          fprintf(fpout,"|DS_SETFONT");
        if(rstyle & DS_MODALFRAME)
          fprintf(fpout,"|DS_MODALFRAME");
        if(rstyle & DS_NOIDLEMSG)
          fprintf(fpout,"|DS_NOIDLEMSG");
      }
    else if(rclass == 0x80)                     /* button styles*/
      {
        fprintf(fpout,"|%s",button_text[rstyle & 0x0fL]);
        if(rstyle & BS_LEFTTEXT)
          fprintf(fpout,"|BS_LEFTTEXT");
      }
    else if(rclass == 0x81)                     /* edit styles*/
      {
        fprintf(fpout,"|%s",edit_text[rstyle & 0x03L]);
        if(rstyle & ES_MULTILINE)
          fprintf(fpout,"|ES_MULTILINE");
        if(rstyle & ES_UPPERCASE)
          fprintf(fpout,"|ES_UPPERCASE");
        if(rstyle & ES_LOWERCASE)
          fprintf(fpout,"|ES_LOWERCASE");
        if(rstyle & ES_PASSWORD)
          fprintf(fpout,"|ES_PASSWORD");
        if(rstyle & ES_AUTOVSCROLL)
          fprintf(fpout,"|ES_AUTOVSCROLL");
        if(rstyle & ES_AUTOHSCROLL)
          fprintf(fpout,"|ES_AUTOHSCROLL");
        if(rstyle & ES_NOHIDESEL)
          fprintf(fpout,"|ES_NOHIDESEL");
        if(rstyle & ES_OEMCONVERT)
          fprintf(fpout,"|ES_OEMCONVERT");
      }
    else if(rclass == 0x82)                     /* static styles*/
      {
        fprintf(fpout,"|%s",static_text[rstyle & 0x0fL]);
        if(rstyle & SS_NOPREFIX)
          fprintf(fpout,"|SS_NOPREFIX");
      }
    else if(rclass == 0x83)                     /* listbox styles*/
      {
        if(rstyle & LBS_NOTIFY)
          fprintf(fpout,"|LBS_NOTIFY");
        if(rstyle & LBS_SORT)
          fprintf(fpout,"|LBS_SORT");
        if(rstyle & LBS_NOREDRAW)
          fprintf(fpout,"|LBS_NOREDRAW");
        if(rstyle & LBS_MULTIPLESEL)
          fprintf(fpout,"|LBS_MULTIPLESEL");
        if(rstyle & LBS_OWNERDRAWFIXED)
          fprintf(fpout,"|LBS_OWNERDRAWFIXED");
        if(rstyle & LBS_OWNERDRAWVARIABLE)
          fprintf(fpout,"|LBS_OWNERDRAWVARIABLE");
        if(rstyle & LBS_HASSTRINGS)
          fprintf(fpout,"|LBS_HASSTRINGS");
        if(rstyle & LBS_USETABSTOPS)
          fprintf(fpout,"|LBS_USETABSTOPS");
        if(rstyle & LBS_NOINTEGRALHEIGHT)
          fprintf(fpout,"|LBS_NOINTEGRALHEIGHT");
        if(rstyle & LBS_MULTICOLUMN)
          fprintf(fpout,"|LBS_MULTICOLUMN");
        if(rstyle & LBS_WANTKEYBOARDINPUT)
          fprintf(fpout,"|LBS_WANTKEYBOARDINPUT");
        if(rstyle & LBS_EXTENDEDSEL)
          fprintf(fpout,"|LBS_EXTENDEDSEL");
      }
    else if(rclass == 0x84)                     /* scrollbar styles*/
      {

        if(rstyle & SBS_VERT)
          {
            fprintf(fpout,"|SBS_VERT");
            if(rstyle & SBS_LEFTALIGN)
              fprintf(fpout,"|SBS_LEFTALIGN");
            if(rstyle & SBS_RIGHTALIGN)
              fprintf(fpout,"|SBS_RIGHTALIGN");
          }
        else
          {
            fprintf(fpout,"|SBS_HORZ");
            if(rstyle & SBS_TOPALIGN)
              fprintf(fpout,"|SBS_TOPALIGN");
            if(rstyle & SBS_BOTTOMALIGN)
              fprintf(fpout,"|SBS_BOTTOMALIGN");
          }

        if(rstyle & SBS_SIZEBOX)
          {
            fprintf(fpout,"|SBS_SIZEBOX");
            if(rstyle & SBS_SIZEBOXTOPLEFTALIGN)
              fprintf(fpout,"|SBS_SIZEBOXTOPLEFTALIGN");
            if(rstyle & SBS_SIZEBOXBOTTOMRIGHTALIGN)
              fprintf(fpout,"|SBS_SIZEBOXBOTTOMRIGHTALIGN");
          }
      }
    else if(rclass == 0x85)                     /* combobox styles*/
      {
        fprintf(fpout,"|%s",combo_text[rstyle & 0x03L]);
        if(rstyle & CBS_OWNERDRAWFIXED)
          fprintf(fpout,"|CBS_OWNERDRAWFIXED");
        if(rstyle & CBS_OWNERDRAWVARIABLE)
          fprintf(fpout,"|CBS_OWNERDRAWVARIABLE");
        if(rstyle & CBS_AUTOHSCROLL)
          fprintf(fpout,"|CBS_AUTOHSCROLL");
        if(rstyle & CBS_OEMCONVERT)
          fprintf(fpout,"|CBS_OEMCONVERT");
        if(rstyle & CBS_SORT)
          fprintf(fpout,"|CBS_SORT");
        if(rstyle & CBS_HASSTRINGS)
          fprintf(fpout,"|CBS_HASSTRINGS");
        if(rstyle & CBS_NOINTEGRALHEIGHT)
          fprintf(fpout,"|CBS_NOINTEGRALHEIGHT");
      }
    return(0);
  }
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

char *get_virttext(val)
  UCHAR val;
  {
    TEXTTAB *tp;
    tp = virt_text;
    while(tp->val)
      {
        if(tp->val == val)    return(tp->text);
        tp++;
      }
    return(NULL);
  }

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/* helper functions              */
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

int read_string(fp,str)          /* read string with terminating 0*/
  FILE *fp;
  char *str;
  {
    int cnt;

    cnt = 0;
                             /*get string with terminating 0*/
    do { fread(str,1,1,fp); cnt++;} while(*str++);
    return(cnt-1);           /* return strlen */
  }
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

int read_nstring(fp,str,n)      /* read string of length n,
                                   add terminating 0*/
  FILE *fp;
  char *str;
  USHORT n;
  {
    fread(str,n,1,fp);       /*size n, because we want it with
                               only one read (say 'hi' to *nix & *icrosoft)*/
    str[n] = '\0';
    return(n);               /* return strlen */
  }
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

USHORT read_word(fp)
  FILE *fp;
  {
    USHORT tmp;
    fread(&tmp,2,1,fp);
    return(tmp);
  }
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

ULONG read_dword(fp)
  FILE *fp;
  {
    ULONG tmp;
    fread(&tmp,4,1,fp);
    return(tmp);
  }
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

UCHAR read_byte(fp)
  FILE *fp;
  {
    UCHAR tmp;
    fread(&tmp,1,1,fp);
    return(tmp);
  }
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

int copy_block(fpto,fp,size)
  FILE *fpto,*fp;
  ULONG size;
  {
    USHORT len;

    while(size)
      {
        len = fread(tmpbuf,1,(USHORT)MIN(size,TMPSIZE),fp);
        fwrite(tmpbuf,1,len,fpto);
        size -= (ULONG)len;
      }
    return(0);
  }
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

int read_textorid(fp,text,idp)
  FILE *fp;
  char *text;
  int *idp;
  {
    UCHAR chkc;

    chkc = read_byte(fp);
    if(chkc == 0xff)  /* undocumented numerical reference*/
      {
        *idp = read_word(fp);
        return(GOT_ID);
      }
    text[0] = chkc;
    if(chkc)      read_string(fp,text+1);    /*there is text*/
    return(GOT_TEXT);
  }
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

char *lookup_name(rce,type)
  RCENTRY *rce;
  USHORT type;
  {
    int i;

    type &= 0x000f;
    type %= 11;
    for(i = 0; i < ntentry; i++)
      {
        if(((rce->id & 0x7fff) == (nametab[i].num & 0x7fff)) &&
           (type == nametab[i].type))
          return(nametab[i].name);
      }
    return(NULL);
  }
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

int print_flags(fp,flg,type)
  FILE *fp;
  USHORT flg;
  USHORT type;
  {
    if(type != 2)   /* BITMAP*/
      {
        if( (flg & FLAG_MASK) == (MEMF_DISC|MEMF_MOVE))
          return(0);   /* is default*/
      }
    else
      {
        if( (flg & FLAG_MASK) == MEMF_MOVE)
          return(0);
      }

    if(flg & MEMF_PREL)           /*PRELOAD*/
      fprintf(fp,"PRELOAD ");
    else
      fprintf(fp,"LOADONCALL ");

    if(flg & MEMF_DISC)           /*DISCARDABLE*/
      fprintf(fp,"DISCARDABLE ");

    if(flg & MEMF_MOVE)           /*MOVEABLE*/
      fprintf(fp,"MOVEABLE ");
    else
      fprintf(fp,"FIXED ");


    return(0);
  }
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
