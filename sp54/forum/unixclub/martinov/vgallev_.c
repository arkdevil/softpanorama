#include <stdio.h>
#include <fcntl.h>
#include <sys/console.h>  /* Standard file sys/console.h conflicts with gcc */
#include <signal.h>
#include <malloc.h>
#include <termio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/vtkd.h>

static struct pcxheader
  { char manuf;
    char hard;
    char encod;
    char bitpx;
    short x1;
    short y1;
    short x2;
    short y2;
    short hres;
    short vres;
    char clrma[48];
    char vmode;
    char nplanes;
    short bplin;
    short palinfo;
    char xtra[58];
  } ph;
static struct port_io_arg pio;
static unsigned linenumber=0;
static int fd=(-1);
static unsigned short connel_color,connel_x,connel_y;
static char *video;
static char palette[16]={0,1,2,3,4,5,6,7,56,9,18,27,36,45,54,63};
static char *copr="VGALLEV:Copyright(C) Martynoff D.A.(KIAE,Moscow) 1991-92";
static char *serno="Ver.1.3:Present to SoftPanorama:Serial Number 003";
static char writmode,oldppmask,actpage;
static char *font,fntsize=0,curchkcolor,hcquality=0,hcbgcolor=0;
static unsigned char *ftn_fname=(char*)&ph;
static unsigned char getch_vmin=1,getch_vtime=0;

/* Keyboard reading procedures */
char getch()
{ struct termio ttyb;
  int lflag,iflag;
  char key,eof,eol,intr;
  ioctl(fileno(stdin),TCGETA,&ttyb);
  lflag=ttyb.c_lflag;
  iflag=ttyb.c_iflag;
  intr=ttyb.c_cc[0];
  eof=ttyb.c_cc[4];
  eol=ttyb.c_cc[5];
  ttyb.c_cc[0]=0;  /* INTR */
  ttyb.c_cc[4]=getch_vmin;
  ttyb.c_cc[5]=getch_vtime;
  ttyb.c_lflag &= ~ICANON;
  ttyb.c_lflag &= ~ECHO;
  ttyb.c_iflag &= ~IXON;
  ioctl(fileno(stdin),TCSETA,&ttyb);
  key=getchar();
  ttyb.c_lflag=lflag;
  ttyb.c_iflag=iflag;
  ttyb.c_cc[0]=intr;
  ttyb.c_cc[4]=eof;
  ttyb.c_cc[5]=eol;
  ioctl(fileno(stdin),TCSETA,&ttyb);
  if(key==intr) kill(getpid(),SIGINT);
  return(key);
}
void timout(vtime)
unsigned char vtime;
/* Set timeout for getch();  vtime in 0.1 sec */
{ getch_vtime=vtime;
  if(vtime)
    getch_vmin=0;
  else
    getch_vmin=1;
}
void sound(freq,time)
unsigned freq,time;
/* Generates sound. Time unit 0.1 sec */
{ if(fd<0) fd=fileno(stderr);
  if(freq>0)
    ioctl(fd,KIOCSOUND,1190000L/freq);
  timout(time);
  getch();
  timout(0);
  ioctl(fd,KIOCSOUND,0L);
}

/* Low level graphic procedures */
char invga(vgareg)
short vgareg;
{ pio.args[0].dir=IN_ON_PORT;
  pio.args[0].port=vgareg;
  pio.args[1].port=0;
  if(fd<0) fd=fileno(stderr);
  ioctl(fd,CONSIO,&pio);
  return(pio.args[0].data);
}
void outvga(vgareg1,byte1,vgareg2,byte2)
short vgareg1,vgareg2;
char byte1,byte2;
{ pio.args[0].dir=OUT_ON_PORT;
  pio.args[0].port=vgareg1;
  pio.args[0].data=byte1;
  pio.args[1].dir=OUT_ON_PORT;
  pio.args[1].port=vgareg2;
  pio.args[1].data=byte2;
  pio.args[2].port=0;
  if(fd<0) fd=fileno(stderr);
  ioctl(fd,CONSIO,&pio);
}
char *getvid()
{ return(video);
}
int setfnt(fname)
char *fname;
{ FILE *ptr1;
  ptr1=fopen(fname,"r");
  if(ptr1)
    { if(fntsize<8) font=malloc(4096);
      fntsize=fread(font,256,16,ptr1);
      fclose(ptr1);
      if(fntsize>=8) return(0);
      fntsize=0;
      free(font);
    }
  return(-1);
}
int setpal(color,map)
unsigned char color,map;
{ unsigned char setmap;
  if(color>15) return(-1);
  setmap=map;
  if(setmap>=64) /* make default */
    { setmap=color & 0x07;
      if(color & 0x08)
	{ if(setmap==0) setmap=56;
	    else setmap |= setmap<<3;
	}
    }
  invga(0x3DA);
  outvga(0x3C0,color,0x3C0,setmap);
  outvga(0x3C0,0x20,0,0);
  palette[color]=setmap;
  return(0);
}
int getpal(color)
unsigned char color;
{ if(color>15)
    return(-1);
  else
    return(palette[color]);
}
int initgr(vmode)
int vmode;
/* 0 - textmode, 1 - 640*350, 2 - 640*480 */
{ static int pid0=0,pid=0;
  int res,j;
  actpage=0;
  if(fd<0) fd=fileno(stderr);
  if(vmode==0)
    { if(linenumber<350) return(0);
      res=ioctl(fd,SW_VGA80x25,0L);
      if(res<0) ioctl(fd,SW_ENHC80x25,0L);
      linenumber=0;
      if(pid>0)
	{ kill(pid,SIGKILL);
	  waitpid(pid,&j,0);
	}
      return(0);
    }
  if(linenumber>=350) return(-1);
  res=350;
  j=0;
  while(copr[j])
    res+=copr[j++]*((j & 0x07)+1);
  if(res!=20375) return(-1);
  j=0;
  while(serno[j])
    res+=serno[j++]*((j & 0x07)+1);
  /* printf("\n Ser.No checksum:%d\n",res); */
  if(res!=39670) return(-1);
  pid0=getpid();
  pid=fork();
  if(pid==0)
    { /* Child process. Resets videomode after abnormally terminated parent */
      for(j=1;j<=18;j++)
	signal(j,SIG_IGN);
      while(pid0==getppid()) sleep(3);
      res=ioctl(fd,SW_VGA80x25,0L);
      if(res<0) ioctl(fd,SW_ENHC80x25,0L);
      fprintf(stderr,"\7 Task terminated abnormally.\n");
      kill(getpid(),SIGKILL); /* suicide */
    }
  if(pid < 0) return(-1);
  if(vmode==1)
    { res=ioctl(fd,SW_ENH_CG640,0L); /* Set videomode 640*350 */
      if(res<0) return(-1);
      linenumber=350;
      res=ioctl(fd,MAPEGA,0L);  /* Set pointer to videobuffer */
      if(fntsize<8)
	{ font=malloc(4096);
	  setfnt("/usr/lib/vidi/font8x14");
	}
    }
  else
    { res=ioctl(fd,SW_VGA12,0L); /* Set videomode 640*480 */
      if(res<0) return(-1);
      linenumber=480;
      res=ioctl(fd,MAPVGA,0L);  /* Set pointer to videobuffer */
      if(fntsize<8)
	{ font=malloc(4096);
	  setfnt("/usr/lib/vidi/font8x16");
	}
    }
  video=(char*) res;
  writmode=0;
  oldppmask=0;
  curchkcolor=(-1);
  for(j=0;j<16;j++)
    setpal(j,palette[j]);
  return(0);
}
int setpag(page)
unsigned short page;
{ if(linenumber==350)
    { if(page>1) return(-1);
      if(actpage==page) return(0);
      if(page==0)
	{ outvga(0x3D4,12,0x3D5,0);
	  video-=0x8000;
	}
      else
	{ outvga(0x3D4,12,0x3D5,0x80);
	  video+=0x8000;
	}
      actpage=page;
      return(0);
    }
  return(-1);
}
int getpag()
{ return(actpage);
}
void derase(color)
short color;
{ unsigned short i;
  char fill;
  color &= 0x0F;
  outvga(0x3CE,5,0x3CF,0);
  writmode=0;
  curchkcolor=(-1);
  outvga(0x3CE,8,0x3CF,0xFF); /* bit mask */
  fill=0xFF;
  if(color==0 || color==0x0F)
    { if(color==0) fill=0;
      outvga(0x3C4,2,0x3C5,0x0F); /* enable all planes */
      for(i=0;i<80*linenumber;i++)
	video[i]=fill;
    }
  else
    { outvga(0x3C4,2,0x3C5,~color);
      for(i=0;i<80*linenumber;i++)
	video[i]=0;
      outvga(0x3C4,2,0x3C5,color);
      for(i=0;i<80*linenumber;i++)
	video[i]=fill;
    }
}
void putpix(x,y,color)
unsigned short x,y,color;
{ unsigned short j;
  static char mask;
  if(y<linenumber && x<640)
    { j=y*80+(x>>3);
      mask=0x80>>(x & 0x07);
      if(writmode!=2)
	{ oldppmask=0;
	  outvga(0x3C4,2,0x3C5,0x0F); /* enable all planes */
	  outvga(0x3CE,5,0x3CF,2); /* set write mode 2 */
	  curchkcolor=(-1);
	  writmode=2;
	}
      if(mask!=oldppmask)
	outvga(0x3CE,0x08,0x3CF,mask);
      oldppmask=mask;
      mask=video[j]; /* latch reading */
      video[j]=color;
    }
}
int getpix(x,y)
unsigned short x,y;
{ unsigned short j,color;
  char mask,k;
  if(y<linenumber && x<640)
    { j=y*80+(x>>3);
      mask=0x80>>(x & 0x07);
      if(curchkcolor>=0)
	{ outvga(0x3CE,5,0x3CF,2);
	  curchkcolor=(-1);
	  writmode=2;
	}
      color=0;
      for(k=0;k<4;k++)
	{ outvga(0x3CE,4,0x3CF,k);
	  if(video[j] & mask) color |= (0x01<<k);
	}
      return(color);
    }
  return(-1);
}
int chkcol(x,y,col)
unsigned short x,y,col;
{ unsigned short j;
  char mask,k;
  if(y<linenumber && x<640)
    { j=y*80+(x>>3);
      mask=0x80>>(x & 0x07);
      if(curchkcolor!=col)
	{ outvga(0x3CE,2,0x3CF,col);
	  outvga(0x3CE,5,0x3CF,0x0A);
	  curchkcolor=col;
	  writmode=2;
	}
     if(video[j] & mask)
	return(1);
      else
	return(0);
    }
  return(-1);
}
void rdpblk(x0,y0,dx,dy,buffer)
short x0,y0,dx,dy;
char *buffer;
{ unsigned short j,xmin,xmax,ymin,ymax,x,y;
  char mask,k;
  long index,indmax;
  if(x0>=0 && y0>=0 && dx>0 && dy>0 && x0+dx<=640 && y0+dy<=linenumber)
    { xmin=x0;
      xmax=x0+dx-1;
      ymin=y0;
      ymax=y0+dy-1;
      if(curchkcolor>=0)
	{ outvga(0x3CE,5,0x3CF,2);
	  curchkcolor=(-1);
	  writmode=2;
	}
      indmax=(long)dx*(long)dy;
      for(index=0;index<indmax;index++)
	buffer[index]=0;
      for(k=0;k<4;k++)
	{ outvga(0x3CE,4,0x3CF,k);
	  index=0;
	  for(x=xmin;x<=xmax;x++)
	    { mask=0x80>>(x & 0x07);
	      j=ymin*80+(x>>3);
	      for(y=ymin;y<=ymax;y++)
		{ if(video[j] & mask) buffer[index] |= (0x01<<k);
		  index++;
		  j+=80;
		}
	    }
	}
    }
}
void wrpblk(x0,y0,dx,dy,buffer)
unsigned short x0,y0,dx,dy;
char *buffer;
{ unsigned short j,xmin,xmax,ymin,ymax,x,y;
  char mask;
  long index;
  if(x0>=0 && y0>=0 && dx>0 && dy>0 && x0+dx<=640 && y0+dy<=linenumber)
    { xmin=x0;
      xmax=x0+dx-1;
      ymin=y0;
      ymax=y0+dy-1;
      index=0;
      for(x=xmin;x<=xmax;x++)
	for(y=ymin;y<=ymax;y++)
	  putpix(x,y,buffer[index++]);
    }
}
void horlin(x0,y,dx,color)
short x0,y,dx,color;
{ static unsigned char mask,mask1,mask2;
  unsigned j,jmin,jmax;
  if(x0>=0 && y>=0 && dx>0 && x0+dx<=640 && y<linenumber)
    { jmin=y*80+(x0>>3);
      jmax=y*80+((x0+dx)>>3);
      mask1=0xFF>>(x0 & 0x07);
      mask2=~(0xFF>>((x0+dx) & 0x07));
      if(writmode!=2)
	{ outvga(0x3C4,2,0x3C5,0x0F); /* enable all planes */
	  outvga(0x3CE,5,0x3CF,2); /* set write mode 2 */
	  curchkcolor=(-1);
	  writmode=2;
	}
      oldppmask=0;
      if(jmin==jmax)
	{ mask = mask1 & mask2;
	  outvga(0x3CE,0x08,0x3CF,mask);
	  mask=video[jmin];
	  video[jmin]=color;
	}
      else
	{ outvga(0x3CE,0x08,0x3CF,mask1);
	  mask=video[jmin];
	  video[jmin]=color;
	  if(mask2)
	    { outvga(0x3CE,0x08,0x3CF,mask2);
	      mask=video[jmax];
	      video[jmax]=color;
	    }
	  if(jmax-jmin>1)
	    { outvga(0x3CE,0x08,0x3CF,0xFF);
	      for(j=jmin+1;j<jmax;j++)
		video[j]=color;
	    }
	}
    }
}
void drawln(x0,y0,x1,y1,color)
unsigned short x0,y0,x1,y1,color;
{ short xmin,xmax,x,dotlg,stepy,y,ymin,ymax,dx,dy,delta;
  if(x0<640 && x1<640 && y0<linenumber && y1<linenumber)
    { if(x0>x1)
	{ xmin=x1;
	  xmax=x0;
	  ymin=y1;
	  ymax=y0;
	}
      else
	{ xmin=x0;
	  xmax=x1;
	  ymin=y0;
	  ymax=y1;
	}
      stepy=1;
      if(ymax < ymin)
	stepy=(-1);
      x=xmin;
      y=ymin;
      dx=xmax-xmin;
      dy=ymax-ymin;
      dotlg=1;
      delta=0;  /* delta=(y-ymin)*dx-(x-xmin)*dy */
      do
	{ if(abs(delta+dx*stepy) > abs(delta-dy))   /* move right */
	    { dotlg++;
	      x++;
	      delta-=dy;
	    }
	  else
	    { if(dotlg>1)
		{ horlin(x-dotlg+1,y,dotlg,color);
		  dotlg=1;
		}
	      else
		{ putpix(x,y,color);
		}
	      y+=stepy;
	      delta+=dx*stepy;
	    }
	}
      while(x<=xmax && (ymax-y)*stepy>=0);
      if(dotlg>1)
	horlin(x-dotlg+1,ymax,dotlg-1,color);
    }
}
long floodf(x,y,color)
short x,y,color;
{ char *bufp,curcol;
  long count,jbuf,lgbuf;
  short *bufx,*bufy,xc,dx,xmax,xmin,colup,coldn;
  if(x>=0 && x<640 && y>=0 && y<linenumber && color!=(curcol=getpix(x,y)))
    { count=0;
      jbuf=0;
      lgbuf=4096;
      bufx=malloc(lgbuf<<1);
      if(bufx==NULL)
	return(-1);
      bufy=malloc(lgbuf<<1);
      if(bufy==NULL)
	{ freebufx:
	  free(bufx);
	  return(-1);
	}
      do
	{ for(xc=x;xc>=0 && chkcol(xc,y,curcol);xc--);
	  xmin=xc+1;
	  colup=coldn=(-1);
	  for(xc=xmin;xc<640 && chkcol(xc,y,curcol);xc++)
	    { if(chkcol(xc,y-1,curcol)==1)
		{ if(xc==xmin || colup!=curcol)
		    { bufx[jbuf]=xc;
		      bufy[jbuf]=y-1;
		      jbuf++;
		    }
		  colup=curcol;
		}
	      else
		colup=(-1);
	      if(chkcol(xc,y+1,curcol)==1)
		{ if(xc==xmin || coldn!=curcol)
		    { bufx[jbuf]=xc;
		      bufy[jbuf]=y+1;
		      jbuf++;
		    }
		  coldn=curcol;
		}
	      else
		coldn=(-1);
	      if(jbuf>=lgbuf)
		{ lgbuf+=4096;
		  bufx=realloc(bufx,lgbuf<<1);
		  bufy=realloc(bufy,lgbuf<<1);
		  if(bufx==NULL || bufy==NULL) return(-1);
		}
	    }
	  xc--;
	  dx=xc-xmin+1;
	  horlin(xmin,y,dx,color);
	  count+=dx;
	  if(jbuf)
	    { jbuf--;
	      x=bufx[jbuf];
	      y=bufy[jbuf];
	    }
	  else
	    break;
	}
      while(1);
      free(bufx);
      free(bufy);
      return(count);
    }
  else
    return(0);
}
void putext(text,count,x,y,color,angle)
unsigned char *text;
unsigned short count,x,y,color,angle;
{ unsigned short i,j,k,xx,index;
  if(fntsize>=8)
    { if(angle==0 || angle==2)
	{ for(j=0;j<8;j++)
	    { if(angle==0)
		xx=x+j;
	      else
		xx=x-j;
	      for(i=0;i<count && text[i];i++)
		{ index=fntsize*text[i];
		  for(k=0;k<fntsize;k++)
		    if(font[index+k] & (0x80>>j))
		      { if(angle==0)
			  putpix(xx,y+k,color);
			else
			  putpix(xx,y-k,color);
		      }
		    if(angle==0)
		      xx+=8;
		    else
		      xx-=8;
		}
	    }
	}
      else
	{ for(k=0;k<fntsize;k++)
	    { for(i=0;i<count && text[i];i++)
		{ index=fntsize*text[i];
		  for(j=0;j<8;j++)
		    if(font[index+k] & (0x80>>j))
		      { if(angle==1)
			  putpix(x,y-(i<<3)-j,color);
			else
			  putpix(x,y+(i<<3)+j,color);
		      }
		}
	      if(angle==1)
		 x++;
	       else
		 x--;
	    }
	}
    }
}
void rdbblk(x0,y0,dx,dy,buffer)
short x0,y0,dx,dy;
char *buffer;
{ long index;
  unsigned short j,xmin,xmax,ymin,ymax,x,y,k;
  if(x0>=0 && y0>=0 && dx>0 && dy>0 && x0+dx<=640 && y0+dy<=linenumber)
    { xmin=x0 >> 3;
      xmax=(x0+dx-1) >> 3;
      ymin=y0;
      ymax=y0+dy-1;
      if(curchkcolor>=0)
	{ outvga(0x3CE,5,0x3CF,2);
	  curchkcolor=(-1);
	  writmode=2;
	}
      index=0;
      for(k=0;k<4;k++)
	{ outvga(0x3CE,4,0x3CF,k);
	  for(y=ymin;y<=ymax;y++)
	    for(x=xmin;x<=xmax;x++)
	      buffer[index++]=video[80*y+x];
	}
    }
}
void wrbblk(x0,y0,dx,dy,buffer)
short x0,y0,dx,dy;
char *buffer;
{ long index;
  unsigned short j,xmin,xmax,ymin,ymax,x,y,k;
  if(x0>=0 && y0>=0 && dx>0 && dy>0 && x0+dx<=640 && y0+dy<=linenumber)
    { xmin=x0 >> 3;
      xmax=(x0+dx-1) >> 3;
      ymin=y0;
      ymax=y0+dy-1;
      index=0;
      outvga(0x3CE,5,0x3CF,0);
      writmode=0;
      curchkcolor=(-1);
      outvga(0x3CE,8,0x3CF,0xFF); /* bit mask */
      for(k=0;k<4;k++)
	{ outvga(0x3C4,2,0x3C5,0x01<<k);
	  for(y=ymin;y<=ymax;y++)
	    for(x=xmin;x<=xmax;x++)
	      video[80*y+x]=buffer[index++];
	}
      outvga(0x3C4,2,0x3C5,0x0F); /* enable all planes */
    }
}
void rectab(ix1,iy1,ix2,iy2,color,fill)
unsigned short ix1,iy1,ix2,iy2,fill;
{ unsigned short xmin,xmax,ymin,ymax,y,dx,j,jmin,jmax;
  static unsigned char mask,mask1,mask2;
  if(ix1<ix2)
    { xmin=ix1;
      xmax=ix2;
    }
  else
    { xmin=ix2;
      xmax=ix1;
    }
  if(iy1<iy2)
    { ymin=iy1;
      ymax=iy2;
    }
  else
    { ymin=iy2;
      ymax=iy1;
    }
  dx=xmax-xmin+1;
  if(fill)
    { if(writmode!=2)
	{ outvga(0x3C4,2,0x3C5,0x0F); /* enable all planes */
	  outvga(0x3CE,5,0x3CF,2); /* set write mode 2 */
	  writmode=2;
	  curchkcolor=(-1);
	}
      oldppmask=0;
      jmin=xmin>>3;
      jmax=(xmax+1)>>3;
      mask1=0xFF>>(xmin & 0x07);
      mask2=~(0xFF>>((xmax+1) & 0x07));
      if(jmin==jmax)
	{ mask = mask1 & mask2;
	  outvga(0x3CE,0x08,0x3CF,mask);
	  for(y=ymin;y<=ymax;y++)
	    { mask=video[y*80+jmin];
	      video[y*80+jmin]=color;
	    }
	  return;
	}
      else
	{ outvga(0x3CE,0x08,0x3CF,mask1);
	  for(y=ymin;y<=ymax;y++)
	    { mask=video[y*80+jmin];
	      video[y*80+jmin]=color;
	    }
	  if(mask2)
	    { outvga(0x3CE,0x08,0x3CF,mask2);
	      for(y=ymin;y<=ymax;y++)
		{ mask=video[y*80+jmax];
		  video[y*80+jmax]=color;
		}
	    }
	  if(jmax-jmin>1)
	    { outvga(0x3CE,0x08,0x3CF,0xFF);
	      for(y=ymin;y<=ymax;y++)
		for(j=jmin+1;j<jmax;j++)
		  video[80*y+j]=color;
	    }
	}
    }
  else
    { horlin(xmin,ymin,dx,color);
      horlin(xmin,ymax,dx,color);
      drawln(xmin,ymin,xmin,ymax,color);
      drawln(xmax,ymin,xmax,ymax,color);
    }
}
int hardco()
{ int i,j,j6,k;
  FILE *ptr1;
  char *string;
  static char initgrdr[4]={27,'K',0,1};
  static char prnreset[2]={27,'@'};
  static char initgrlq[5]={27,'*',39,0,5};
  static char setspace[3]={27,'3',24};
  static char restspc[2]={27,'2'};
  static char linefeed[2]={10,13};
  if(linenumber<350) return(-1);
  ptr1=fopen("hardcopy99.tmp","w");
  if(ptr1==NULL) return(-1);
  if(fwrite(prnreset,2,1,ptr1)!=1) goto fwerr;
  if(fwrite(setspace,3,1,ptr1)!=1) goto fwerr;
  if(hcquality)
    { string=malloc(6*640);
      if(string==NULL) goto deltmp;
      if(fwrite(linefeed,2,1,ptr1)!=1) goto fwerr;
      for(i=0;i<linenumber;i+=12)
	{ if(fwrite(initgrlq,5,1,ptr1)!=1) goto fwerr;
	  for(j=0;j<640;j++)
	    { j6=6*j;
	      string[j6+2]=string[j6+1]=string[j6]=0;
	      for(k=0;k<12;k++)
		if(chkcol(j,i+k,hcbgcolor)==0)
		  string[j6+(k>>2)] |= 0xC0>>((k & 0x03)<<1);
	      for(k=0;k<3;k++)
		string[j6+k+3]=string[j6+k];
	    }
	  if(fwrite(string,6*640,1,ptr1)!=1) goto fwerr;
	  if(fwrite(linefeed,2,1,ptr1)!=1) goto fwerr;
	}
      goto okhardco;
    }
  else
    { string=malloc(linenumber);
      if(string==NULL) goto deltmp;
      initgrdr[2]=linenumber-256;
      for(i=632;i>=0;i-=8)
	{ if(fwrite(initgrdr,4,1,ptr1)!=1) goto fwerr;
	  for(j=0;j<linenumber;j++)
	    { string[j]=0;
	      for(k=0;k<8;k++)
		if(chkcol(i+k,j,hcbgcolor)==0)
		  string[j] |= 0x01<<k;
	    }
	  if(fwrite(string,linenumber,1,ptr1)!=1) goto fwerr;
	  if(fwrite(linefeed,2,1,ptr1)!=1) goto fwerr;
	}
    }
  okhardco:
  if(fwrite(restspc,2,1,ptr1)!=1) goto fwerr;
  free(string);
  fclose(ptr1);
  system("lpr -s -o stty='-opost' hardcopy99.tmp; rm -f hardcopy99.tmp");
  return(0);
  fwerr:
  free(string);
  deltmp:
  fclose(ptr1);
  system("rm -f hardcopy99.tmp");
  return(-1);
}
void hcpopt(quality,bgcolor)
char quality,bgcolor;
{ if(quality)
    hcquality=1;
  else
    hcquality=0;
  hcbgcolor=bgcolor;
}

/* Fortran interface likewise Connel Graphics */
void init_(mode)
unsigned long *mode;
{ if(*mode<=2)
    initgr(*mode);
  else
    initgr(1);
  connel_color=15;
  connel_x=connel_y=0;
}
void finit_()
{ initgr(0);
}
void derase_()
{ if(linenumber)
    derase(0);
  else
    fprintf(stderr,"\033[2J");
}
void colmap_(ind,ir,ig,ib)
long *ind,*ir,*ig,*ib;
{ unsigned char map;
  if(*ir<0)
    { setpal(*ind,-1);
      return;
    }
  map=0;
  if(*ir & 0x02) map |= 0x04;
  if(*ir & 0x01) map |= 0x20;
  if(*ig & 0x02) map |= 0x02;
  if(*ig & 0x01) map |= 0x10;
  if(*ib & 0x02) map |= 0x01;
  if(*ib & 0x01) map |= 0x08;
  setpal(*ind,map);
}
void inqmap_(ind,ir,ig,ib)
long *ind,*ir,*ig,*ib;
{ unsigned char map;
  map=getpal(*ind);
  *ir=0;
  if(map & 0x04) *ir |= 0x02;
  if(map & 0x20) *ir |= 0x01;
  *ig=0;
  if(map & 0x02) *ig |= 0x02;
  if(map & 0x10) *ig |= 0x01;
  *ib=0;
  if(map & 0x01) *ib |= 0x02;
  if(map & 0x08) *ib |= 0x01;
}
void dcolor_(icol)
long *icol;
{ connel_color=(*icol) & 0x0F;
}
void moveab_(ix,iy)
long *ix,*iy;
{ connel_x=(*ix);
  connel_y=(*iy);
  if(connel_x>=640) connel_x=639;
  if(connel_y>=linenumber) connel_y=linenumber-1;
}
void drawab_(ix,iy)
long *ix,*iy;
{ drawln(connel_x,connel_y,*ix,*iy,connel_color);
  moveab_(ix,iy);
}
void rectab_(ix1,iy1,ix2,iy2,fill)
unsigned long *ix1,*iy1,*ix2,*iy2,*fill;
{ rectab(*ix1,*iy1,*ix2,*iy2,connel_color,*fill);
}
void ldfont_(fname,dummy)
unsigned char *fname,*dummy;
{ int i,ip;
  for(i=0;i<120;i++)
    { ftn_fname[i]=fname[i];
      if(ftn_fname[i]<=32)
	{ ftn_fname[i]=0;
	  break;
	}
    }
  setfnt(ftn_fname);
}
void rdpblk_(wid,high,buff)
unsigned long *wid,*high;
char *buff;
{ rdpblk(connel_x,connel_y,*wid,*high,buff);
}
void wrpblk_(wid,high,buff)
unsigned long *wid,*high;
char *buff;
{ wrpblk(connel_x,connel_y,*wid,*high,buff);
}
void cpyblk_(sx,sy,dx,dy,iw,ih)
unsigned long *sx,*sy,*dx,*dy,*iw,*ih;
{ char *buff;
  buff=malloc((*iw)*(*ih));
  if(buff==NULL) return;
  rdpblk(*sx,*sy,*iw,*ih,buff);
  wrpblk(*dx,*dy,*iw,*ih,buff);
  free(buff);
}
void rdbblk_(wid,high,buff)
unsigned long *wid,*high;
char *buff;
{ rdbblk(connel_x,connel_y,*wid,*high,buff);
}
void wrbblk_(wid,high,buff)
unsigned long *wid,*high;
char *buff;
{ wrbblk(connel_x,connel_y,*wid,*high,buff);
}
void vpage_(ipage)
long *ipage;
{ setpag(*ipage);
}
void vwait_(pause)
long *pause;
/* Pause unit 0.1 sec */
{ long vmin;
  unsigned char key;
  key=255;
  vmin=(*pause);
  while(key==0xFF && vmin>0)
    { if(vmin>=255)
	timout(255);
      else
	timout(vmin);
      key=getch();
      if(key=='P'-'A'+1 && linenumber>=350)
	{ hardco();
	  key=getch();
	}
      vmin-=255;
    }
  timout(0);
}
void rdpixl_(ix,iy,icol)
long *ix,*iy,*icol;
{ *icol=getpix(*ix,*iy);
}
void wrpixl_(ix,iy,icol)
long *ix,*iy,*icol;
{ putpix(*ix,*iy,*icol);
}
void inqpos_(ix,iy)
long *ix,*iy;
{ *ix=connel_x;
  *iy=connel_y;
}
void inkey_(is,ia)
long *is,*ia;
{ unsigned char key;
  readkb:
  timout(3);
  key=getch();
  if(key=='P'-'A'+1 && linenumber>=350)
    { hardco();
      goto readkb;
    }
  if(key==127)
    { *is=0x53; /* Del */
      *ia=0;
      timout(0);
      return;
    }
  *is=0;
  if(key==0xFF)
    { *ia=0;  /* timeout expired */
      timout(0);
      return;
    }
  if(key==0x1B)
    { key=getch();
      if(key==0xFF)
	{ *ia=0x1B; /* Single Esc pressed */
	  timout(0);
	  return;
	}
      if(key=='[')   /* Control key */
	{ *ia=0;
	  timout(0);
	  key=getch();
	  switch(key)
	    { case 'A': *is=0x48;  /* Up */
			break;
	      case 'B': *is=0x50;  /* Down */
			break;
	      case 'C': *is=0x4D;  /* Right */
			break;
	      case 'D': *is=0x4B;  /* Left */
			break;
	      case 'E': *is=0x4C;  /* <5> */
			break;
	      case 'F': *is=0x4F;  /* End */
			break;
	      case 'G': *is=0x51;  /* PgDn */
			break;
	      case 'H': *is=0x47;  /* Home */
			break;
	      case 'I': *is=0x49;  /* PgUp */
			break;
	      case 'L': *is=0x52;  /* Ins */
			break;
	      case 'W': *is=0x57;  /* F11 */
			break;
	      case 'X': *is=0x58;  /* F12 */
			break;
	      case 'Z': *is=0x0F;  /* Shift-TAB */
			break;
	      default:  *is=key-'M'+0x3B; /* F1..F10 */
	    }
	  return;
	}
    }
  *ia=key;
  timout(0);
}
void putext_(text,count,x,y,color,angle)
unsigned char *text;
unsigned long *count,*x,*y,*color,*angle;
{ putext(text,*count,*x,*y,*color,*angle);
}
void text_(text,count)
unsigned char *text;
unsigned long *count;
{ putext(text,*count,connel_x,connel_y,connel_color,0);
  if((connel_x+=(*count*8))>=640)
    { connel_x-=640;
      if((connel_y+=fntsize)>=linenumber) connel_y-=linenumber;
    }
}
void flood_(x,y)
long *x,*y;
{ floodf(*x,*y,connel_color);
}
void hardco_()
{ hardco();
}
void hcpopt_(quality,bgcolor)
long *quality,*bgcolor;
{ hcpopt(*quality,*bgcolor);
}
void sound_(freq,time)
long *freq,*time;
{ sound(*freq,*time);
}

/* Following programs intended for text mode (for gf77) */
void prompt_(text,count)
/* Text string output in text mode without CR after it */
unsigned char *text;
unsigned long *count;
{ int i;
  for(i=0;i<*count && text[i];i++)
    putc(text[i],stderr);
}
void movcur_(line,col)
long *line,*col;
{ if(*line>0 && *col>0)
    fprintf(stderr,"\033[%ld;%ldH",*line,*col);
  if(*col==0)
    { if(*line>0)
	fprintf(stderr,"\033[%ldB",*line);
      if(*line<0)
	fprintf(stderr,"\033[%ldA",-(*line));
    }
  if(*line==0)
    { if(*col>0)
	fprintf(stderr,"\033[%ldC",*col);
      if(*col<0)
	fprintf(stderr,"\033[%ldD",-(*col));
    }
}
void setrev_(onoff)
long *onoff;
{ putc(0x1B,stderr);
  putc('[',stderr);
  if(*onoff)
    putc('7',stderr);
  else
    putc('0',stderr);
  putc('m',stderr);
}

/* PCX file save/restore routines */
void savpcx_(x,y,dx,dy,fname)
long *x,*y,*dx,*dy;
unsigned char *fname;
#define PBSIZE 16384
{ FILE *ptr1;
  long i,j,k,l,vs,hs;
  unsigned char *buffer,*pb,*plane,byte,rept;
  if(!linenumber) return;
  for(i=0;i<120;i++)
    { ftn_fname[i]=fname[i];
      if(ftn_fname[i]<=32)
	{ ftn_fname[i]=0;
	  break;
	}
    }
  i=(*x)>>3;
  j=(*x+*dx-1)>>3;
  if(i<0 || j>=80 || *y<0 || *y+*dy>linenumber) return;
  hs=j-i+1;
  vs=(*dy);
  pb=malloc(PBSIZE);
  if(!pb) return;
  buffer=malloc(4*hs*vs);
  if(buffer)
    { rdbblk(*x,*y,*dx,*dy,buffer);
      ptr1=fopen(ftn_fname,"w");
      if(ptr1)
	{ ph.manuf=10;
	  ph.hard=5;
	  ph.encod=1;
	  ph.bitpx=1;
	  ph.hres=640;
	  ph.vres=linenumber;
	  ph.nplanes=4;
	  ph.palinfo=1;
	  ph.x1=i<<3;
	  ph.x2=(j<<3)+7;
	  ph.bplin=hs;
	  ph.y1=(*y);
	  ph.y2=(*y+*dy-1);
	  for(i=0;i<16;i++)
	    { inqmap_(&i,&j,&k,&l);
	      ph.clrma[3*i]=j*0x55;
	      ph.clrma[3*i+1]=k*0x55;
	      ph.clrma[3*i+2]=l*0x55;
	    }
	  fwrite(&ph,sizeof(ph),1,ptr1);
	  l=0;
	  for(i=0;i<vs;i++)
	    { rept=0xC0;
	      for(j=0;j<4;j++)
		{ plane=buffer+hs*(i+j*vs);
		  for(k=0;k<hs;k++)
		    { if(rept==0xC0) byte=plane[k];
		      if(plane[k]==byte)
			{ if(++rept==0xFF)
			    { pb[l++]=0xFF;
			      pb[l++]=byte;
			      rept=0xC0;
			    }
			}
		      else
			{ if(rept>0xC1 || byte>=0xC0) pb[l++]=rept;
			  pb[l++]=byte;
			  byte=plane[k];
			  rept=0xC1;
			}
		      if(l>=PBSIZE-1)
			{ fwrite(pb,l,1,ptr1);
			  l=0;
			}
		    }
		}
	      if(rept>0xC1 || byte>=0xC0) pb[l++]=rept;
	      pb[l++]=byte;
	      if(l>=PBSIZE-1)
		{ fwrite(pb,l,1,ptr1);
		  l=0;
		}
	    }
	  if(l) fwrite(pb,l,1,ptr1);
	  fclose(ptr1);
	}
      free(buffer);
      free(pb);
    }
}
void loapcx_(x,y,fname)
long *x,*y;
unsigned char *fname;
{ FILE *ptr1;
  long i,j,k,l,hs,vs,pbs;
  struct stat buf;
  unsigned char *pb,*buffer,*plane,byte,rept,cx;
  for(i=0;i<120;i++)
    { ftn_fname[i]=fname[i];
      if(ftn_fname[i]<=32)
	{ ftn_fname[i]=0;
	  break;
	}
    }
  if(stat(ftn_fname,&buf)) return;
  pbs=buf.st_size-sizeof(ph);
  pb=malloc(pbs);
  if(!pb) return;
  ptr1=fopen(ftn_fname,"r");
  if(ptr1)
    { fread(&ph,sizeof(ph),1,ptr1);
      if(ph.manuf==10 && ph.bitpx==1 && ph.hres==640 && ph.nplanes==4)
	{ hs=ph.bplin;
	  vs=ph.y2-ph.y1+1;
	  fread(pb,pbs,1,ptr1);
	  j=ioctl(fileno(stderr),CONS_GET,0L);
	  if(!linenumber)
	    { if(ph.vres==480)
		{ if(initgr(2)) goto setega;
		}
	      else
		{ setega:
		  if(initgr(1)) goto rels;
		}
	    }
	  if(*y+vs>linenumber) vs=linenumber-(*y);
	  buffer=malloc(4*hs*vs);
	  if(!buffer) goto rels;
	  i=j=k=0;
	  plane=buffer;
	  for(l=0;l<pbs;l++)
	    { byte=pb[l];
	      if(ph.encod && byte>0xC0)
		{ rept=byte&0x3F;
		  byte=pb[++l];
		}
	      else
		rept=1;
	      for(cx=0;cx<rept;cx++)
		{ plane[k++]=byte;
		  if(k>=hs)
		    { k=0;
		      if(++j>=4)
			{ j=0;
			  if(++i>=vs) goto ready;
			}
		      plane=buffer+hs*(i+j*vs);
		    }
		}
	    }
	  ready:
	  for(i=0;i<16;i++)
	    { j=ph.clrma[3*i]>>6;
	      k=ph.clrma[3*i+1]>>6;
	      l=ph.clrma[3*i+2]>>6;
	      colmap_(&i,&j,&k,&l);
	    }
	  wrbblk(*x,*y,hs<<3,vs,buffer);
	  free(buffer);
	}
      rels:
      fclose(ptr1);
    }
  free(pb);
}
