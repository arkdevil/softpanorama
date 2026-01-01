/* vgallev_.o */
/* Graphic functions for Green Hills compilers under SCO Open Desktop UNIX.
	Version 1.3. Copyright(C) Martynoff D.A.(KIAE, Moscow) 1991-92 */

/* Only C callable routines */
char getch();
/* Waits for keystroke if necessary and returns ASCII code of key pressed.
   Remember that control keys under UNIX generate Escape Sequences
   rather than Extended ASCII codes. */

char timout();
/* timout(unsigned char vtime);
   Sets maximal waiting time for getch(). Unit of time=0.1 sec.
   Don't forget to restore standard value - timout(0); */

void sound();
/* sound(int freq,int time);
   Generates sound (time unit=0.1 sec). */

int setfnt();
/* setfnt(char *fname);
   Loads 8x8, 8x14 or 8x16 matrix font from file.
   Returns 0 if successful */

int setpal();
/* setpal(char color,char map);
   Loads palette register for color with map (rgbRGB).
   Loads default value if map<0.
   Returns 0 if successful */

int getpal();
/* getpal(char color);
   Returns palette register contents */

int initgr();
/* initgr(int vmode);
   Selects videomode: vmode==0 - textmode, 1 - 640*350, 2 - 640*480.
   For vmode==1 loads font /usr/lib/vidi/font8x16,
   for vmode==2 loads font /usr/lib/vidi/font8x14.
   Returns 0 if successful */

int setpag();
/* setpag(int page);
   Selects video page 0 or 1 for videomode 640*350.
   Returns 0 if successful */

int getpag();
/* Returns active video page */

void derase();
/* derase(int color);
   Floods total screen with color */

void putpix();
/* putpix(int x,int y,int color);
   Draws single pixel */

int getpix();
/* getpix(int x,int y);
   Returns pixel color or (-1) if pixel doesn't exist */

int chkcol();
/* chkcol(int x,int y,int col);
   Returns 1 if pixel (x,y) has color col,
	   0 if pixel (x,y) has another color
	  -1 if pixel (x,y) doesn't exist */

void rdpblk();
/* rdpblk(int x0,int y0,unsigned dx,unsigned dy,char *buffer);
   Saves rectangle in buffer (one byte per pixel).
   Information layout in buffer:
   { getpix(x0,y0),getpix(x0,y0+1),...,
     getpix(x0,y0+dx-1),getpix(x0+1,y0),getpix(x0+1,y0+1),...,
     getpix(x0+dx-1,y0+dy-2),getpix(x0+dx-1,y0+dy-1)}  */

void wrpblk();
/* wrpblk(int x0,int y0,unsigned dx,unsigned dy,char *buffer);
   Restores rectangle saved by rdpblk */

void drawln();
/* drawln(int x0,int y0,int x1,int y1,int color);
   Draws line from (x0,y0) to (x1,y1) */

void horlin();
/* horlin(int x0,int y,unsigned dx,int color);
   Draws horizontal line from (x0,y) to (x0+dx-1,y).
   More fast than drawln(x0,y,x0+dx-1,y,color);
   Used by drawln. */

long floodf();
/* floodf(int x,int y,int color);
   Floods closed area by color.
   Returns number of changed pixels */

void putext();
/* putext(char *text,int count,int x,int y,int color,int angle);
   Outputs text string (length=count, if count<0 - full string)
   Angle==0: from left to right,
   Angle==1: from bottom to top,
   Angle==2: from right to left,
   Angle==3: from top to bottom  */

void rdbblk();
/* rdbblk(int x0,int y0,unsigned dx,unsigned dy,char *buffer);
   Almost the same as rdpblk. Differences:
   1. x0, x0+dx will be rounded to byte-align this rectangle
      for higher performance.
   2. Buffer length must be 4*dy*((x0+dx-1)/8-x0/8+1) bytes.
      Information layout differs from rdpblk. */

void wrbblk();
/* wrbblk(int x0,int y0,unsigned dx,unsigned dy,char *buffer);
   Restores rectangle saved by rdbblk */

void rectab();
/* rectab(int x0,int y0,int x1,int y1,int color,int fill);
   Draws rectangle with opposite corners (x0,y0), (x1,y1).
   fill==0 : empty     fill != 0 : filled. */

int hardco();
/* hardco();
   Makes graphic hard copy of screen contents
   on the EPSON compatible printer. Returns 0 if successful.

   When creating your own printscreen function, for example, to support
   laser printer, use lpr option -o stty='-opost', or some bit sequences
   will be distorted by lpr. */

void hcpopt();
/* hcpopt(char quality,char bgcolor);
   Defines printer quality and selects background color for hardco:
   quality==0  Epson FX
   quality==1  Epson LQ */

/* To open this toolkit for extensions following procedures added */
char *getvid();
/* getvid();
   Returns pointer to current video page when in graphic mode */

void outvga();
/* outvga(int port1,char data1,int port2,char data2);
   Sends data into EGA/VGA registers.
   If only one register must be changed, use port2=0.
   It is recommended to restore changed masks and read/write modes
   to avoid inconsistency between real EGA/VGA registers contents
   and VGALLEV internal variables */

char invga();
/* invga(int port);
   Returns byte read from EGA/VGA register */

/* Fortran callable functions similar to Connell Scientific Graphics */
void init_();
/* init_(long *mode);
   call init(mode)  */

void finit_();
/* call finit */

void derase_();
/* call derase */

void colmap_();
/* colmap_(long *ind,long *ir,long *ig,long *ib);
   call colmap(ind,ir,ig,ib)
   If ir<0, standard colormap will be restored */

void inqmap_();
/* inqmap_(long *ind,long *ir,long *ig,long *ib);
   call inqmap(ind,ir,ig,ib) */

void dcolor_();
/* dcolor_(long *icol);
   call dcolor(icol)  */

void moveab_();
/* moveab_(long *ix,long *iy);
/* call moveab(ix,iy) */

void drawab_();
/* drawab_(long *ix,long *iy);
/* call drawab(ix,iy) */

void rectab_();
/* rectab_(long *ix1,long *iy1,long *ix2,long *iy2,long *fill);
   call rectab(ix1,iy1,ix2,iy2,fill) */

void ldfont_();
/* ldfont_(char *fname,char *dummy);
   call ldfont(fname,dummy)
   fname must be space- or null-ended. 2nd parameter not used.
   See "setfnt". */

void rdpblk_();
/* rdpblk_(long *wid,long *high,char *buff);
   call rdpblk(wid,high,buff) */

void wrpblk_();
/* wrpblk_(long *wid,long *high,char *buff);
   call wrpblk(wid,high,buff) */

void cpyblk_();
/* cpyblk_(long *sx,long *sy,long *dx,long *dy,long *iw,long *ih);
   call cpyblk(sx,sy,dx,dy,iw,ih) */

void rdbblk_();
/* rdbblk_(long *wid,long *high,char *buff);
   call rdbblk(wid,high,buff) */

void wrbblk_();
/* wrbblk_(long *wid,long *high,char *buff);
   call wrbblk(wid,high,buff) */

void vpage_();
/* vpage_(long *ipage);
   call vpage(ipage)
     See "setpag"  */

void vwait_();
/* void vwait_(long *pause);
   call vwait(pause)
     Difference from standard: pause expressed in 0.1 seconds.
     Any keystroke terminates pause */

void rdpixl_();
/* rdpixl_(long *ix,long *iy,long *icol);
   call rdpixl(ix,iy,icol) */

void wrpixl_();
/* wrpixl_(long *ix,long *iy,long *icol);
   call wrpixl(ix,iy,icol) */

void inqpos_();
/* inqpos_(long *ix,long *iy);
   call inqpos(ix,iy)
Returns current position */

void inkey_();
/* inkey_(long *is,long *ia);
   call inkey(is,ia)
Returns: if key pressed is text key then    ia=its ASCII code
	 if key pressed is control key then is=its scan code.
	 if none key pressed during 0.3 sec then ia=0, is=0.
   If Ctrl-P pressed, hardco() will be invoked */

void putext_();
/* putext_(char *text,long *count,long *x,long *y,long *color,long *angle);
   call putext(text,count,x,y,color,angle) */

void text_();
/* text_(char *text,long *count);
   call text(text,count)
   Take into account that text_() moves current position
   to the end of output string */

void flood_();
/* flood_(long *x,long *y);
   call flood(x,y) */

void hardco_();
/* hardco_();
   call hardco */

void hcpopt_();
/* hcpopt_(long* quality,long *bgcolor);
   call hcpopt(lpqual,ibgcol) */

void sound_();
/* sound_(long *freq,long *time);
   call sound(ifreq,itime) */

/* Following programs intended for text mode (for gf77) */
void prompt_();
/* prompt_(char *text,long *count);
   call prompt(text,count)
Text string output from current position without CR */

void movcur_();
/* movcur_(long *line,long *col);
   call movcur(line,col)
Moves cursor to (line,col).
   if line==0 moves cursor to (current line,current col + col)
   if col==0  moves cursor to (current line + line,current col) */

void setrev_();
/* setrev_(long *onoff);
   call setrev(onoff)
Sets or unsets screen output attribute "reversed" */

/* PCX file save/restore routines */
void savpcx_();
/* savpcx_(long *x,long *y,long *dx,long *dy,char *fname);
   call savpcx(x,y,dx,dy,fname)
   Saves rectangle in PCX format file. fname must be space- or null-ended.
   x0, x0+dx will be rounded to byte-align this rectangle. */

void loapcx_();
/* savpcx_(long *x,long *y,char *fname);
   call loapcx(x,y,fname)
   Restores rectangle from PCX format file. */
