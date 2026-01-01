#include "arjcrack.h"
#include <io.h>
#include <stdio.h>
#include <string.h>

struct INFO
 {
 char file [120];     /* имя рабочего файла             */
 int  flags;          /* флаги                          */
 char *buf;           /* буфер для зашифрованного файла */
 long elen;           /* длина сжатого файла            */
 long dlen;           /* длина несжатого файла          */
 char *pwd;           /* буфер для пароля               */
 int  plen;           /* длина пароля                   */
 unsigned long fcrc;  /* контрольная сумма              */
 };
UCRC   crc;
UCRC   crctable [UCHAR_MAX + 1];
ushort headersize;
uchar  header [HEADERSIZE_MAX];
UCRC   header_crc;
//--------------- информация из заголовка файла -------------
uchar  first_hdr_size;
uchar  arj_nbr;
uchar  arj_x_nbr;
uchar  host_os;
uchar  arj_flags;
short  method;
int    file_type;
uchar  garb_char;      //* 
ulong  time_stamp;
long   compsize;
long   origsize;
UCRC   file_crc;
short  entry_pos;
uint   file_mode;
ushort host_data;
//--------------- информация из заголовка файла -------------
uchar  *get_ptr;

#define get_crc()       get_longword()
#define fget_crc(f,b)   fget_longword(f,b)
#define setup_get(PTR)  (get_ptr = (PTR))
#define get_byte()      ((uchar)(*get_ptr++ & 0xff))
#define UPDATE_CRC(r,c) r=crctable[((uchar)(r)^(uchar)(c))&0xff]^(r>>CHAR_BIT)
#define CRCPOLY         0xEDB88320L

/*-------------------------- Functions -------------------------*/

void make_crctable ()
{
uint i, j;
UCRC r;

for (i=0; i <= UCHAR_MAX; i++)
   {
   r=i;
   for (j=CHAR_BIT; j > 0; j--)
      {
      if (r & 1) r = (r >> 1) ^ CRCPOLY;
      else       r >>= 1;
      }
   crctable[i] = r;
   }
return;
}

int fget_byte (int fd, int *c)
{
if (read (fd, (char *)c, sizeof (char)) != sizeof (char)) return (-1);
(*c) &= 0xFF;
return (0);
}

int fget_word (int fd, int *c)
{
if (read (fd, (char *)c, sizeof (int)) != sizeof (int)) return (-1);
return (0);
}

int fget_longword (int fd, long *c)
{
if (read (fd, (char *)c, sizeof (long)) != sizeof (long)) return (-1);
return (0);
}

void crc_buf (char *str, int len)
{
while (len--) UPDATE_CRC (crc, *str++);
return;
}

void fread_crc (uchar *p, int n, int fd)
{
n = read (fd, (char *)p, n);
origsize += n;
crc_buf ((char *)p, n);
return;
}

uint get_word ()
{
uint b0, b1;

b0 = get_byte();
b1 = get_byte();
return (b1 << 8) + b0;
}

ulong get_longword ()
{
ulong b0, b1, b2, b3;

b0 = get_byte();
b1 = get_byte();
b2 = get_byte();
b3 = get_byte();
return (b3 << 24) + (b2 << 16) + (b1 << 8) + b0;
}

long find_header (int fd)
{
long arcpos, lastpos;
int c;

arcpos = tell (fd);
lseek (fd, 0L, SEEK_END);
lastpos = tell (fd) - 2L;
if (lastpos > MAXSFX)
    lastpos = MAXSFX;
for (; arcpos < lastpos; arcpos++)
   {
   lseek (fd, arcpos, SEEK_SET);
   if (fget_byte (fd,&c)) return (-1);
   while (arcpos < lastpos)
      {                        /* low order first */
      if (c != HEADER_ID_LO)
         { if (fget_byte (fd,&c)) return (-1); }
      else
         {
         if (fget_byte (fd,&c)) return (-1);
         if (c == HEADER_ID_HI)  break;
         }
      arcpos++;
      }
   if (arcpos >= lastpos) break;
   if (fget_word (fd, &headersize)) return (-1);
   if (headersize <= HEADERSIZE_MAX)
      {
      UCRC fcrc;
      
      crc = CRC_MASK;
      fread_crc (header, (int) headersize, fd);
      if (fget_crc(fd,&fcrc)) return (-1);
      if ((crc ^ CRC_MASK) == fcrc)
         {
         lseek (fd, arcpos, SEEK_SET);
         return (arcpos);
         }
      }
   }
return (-1);          /* could not find a valid header */
}

int read_header (int first, int fd, struct INFO *x)
{
ushort extheadersize, header_id;

if (fget_word (fd, &header_id))   return (-1);
if (header_id != HEADER_ID)       return (-2);
if (fget_word (fd, &headersize))  return (-3);
if (headersize <= 0)              return (-4);   /* end of archive */
if (headersize > HEADERSIZE_MAX)  return (-5);
crc = CRC_MASK;
fread_crc (header, (int) headersize, fd);
if (fget_crc(fd,&header_crc))     return (-6);
if ((crc^CRC_MASK) != header_crc) return (-7);

setup_get(header);
first_hdr_size = get_byte();
arj_nbr        = get_byte();
arj_x_nbr      = get_byte();
host_os        = get_byte();
arj_flags      = get_byte();
method         = get_byte();
file_type      = get_byte();
garb_char      = get_byte();       //*
time_stamp     = get_longword();
compsize       = get_longword();
origsize       = get_longword();
file_crc       = get_crc();
entry_pos      = get_word();
file_mode      = get_word();
host_data      = get_word();

strncpy (x->file, header+first_hdr_size, sizeof (x->file));
x->flags = arj_flags;
x->elen  = compsize;
x->dlen  = origsize;
x->fcrc  = file_crc;

while (fget_word (fd, &extheadersize) == 0)
   {
   if (extheadersize == 0) break;
   lseek (fd, (long) (extheadersize + 4), SEEK_CUR);
   }
return (0);                   /* success */
}

extern unsigned char stream [];
extern unsigned char password [];
extern int glength;
extern int bound;
extern unsigned char cmin,cmax;
extern unsigned char only[];
extern int onlylen;

void unstore ()
{
register int i,j;
int k;
register unsigned char t;

k=(int)origsize;
for (i=j=0; i<k; i++)
   {
   t = stream [i] ^ password [j++];
   if (bound > 0)   { if (t<cmin || t>cmax) return; }
   if (i < onlylen) { if (t != only [i]) return; }
   UPDATE_CRC (crc, t);
   j %= glength;
   }
return;
}

int    gletter;                           //*
int    offset;                            //*
ushort bitbuf;
int    bitcount;
uchar  subbitbuf;

int fillbuf (int n)       /* Shift bitbuf n bits left, read n bits */
{
if (offset > compsize) return (1);
bitbuf = (bitbuf << n) & 0xFFFF;  /* lose the first n bits */
while (n > bitcount)
   {
   bitbuf |= subbitbuf << (n -= bitcount);
   if (offset < compsize)
      {
      subbitbuf = stream [offset++];      //*
      subbitbuf ^= password [gletter++];  //*
      gletter %= glength;                 //*
      }
   else
      subbitbuf = 0;
   bitcount = CHAR_BIT;
   }
bitbuf |= subbitbuf >> (bitcount -= n);
return (0);
}

int init_getbits ()
{
bitbuf    = 0;
subbitbuf = 0;
bitcount  = gletter = offset = 0;
return fillbuf (2 * CHAR_BIT);
}

ushort getbits (int n, int *error)
{
ushort x;

x = bitbuf >> (2 * CHAR_BIT - n);
(*error) = fillbuf (n);
return x;
}

