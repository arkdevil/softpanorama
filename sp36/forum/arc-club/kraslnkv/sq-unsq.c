# include <stdio.h>
# include <io.h>

# define  WORD	unsigned int
# define  BYTE	unsigned char
# define  SUCCESS 0
# define  FAILURE 1

typedef struct {
        FILE  *fp;
	WORD  buf;
        BYTE  count;
    } bitstream;

static int getbit(bitstream *);
static void initbits(bitstream *, FILE *);

void main (int ac,char **av)
{

 long squeeze (FILE *inf,FILE *outf);
 int  unsqu (FILE *inf,FILE *outf);

 FILE *inf,
      *ouf1,
      *ouf2;
 long  compr_length,
       nocompr_length,
       l1, l2,
       percent;
 WORD  m1,m2;
 unsigned
       lr;
 static char
       bf1 [512], bf2 [512];

  printf ("Проверка процедуры упаковки SQUEEZE.\n");
  if (ac != 4)
  {
    printf ("Формат вызова: %s <входной файл> <промежуточный файл>"
            " <выходной файл>\n",av [0]);
    return;
  }
  if (!(inf = fopen (av [1],"rb")))
  {
    printf ("Невозможно открыть входной файл.\n");
    return;
  }
  if (!(ouf1 = fopen (av [2],"wb+")))
  {
    printf ("Невозможно открыть промежуточный файл.\n");
    return;
  }
  if (!(ouf2 = fopen (av [3],"wb+")))
  {
    printf ("Невозможно открыть выходной файл.\n");
    return;
  }
  printf ("Упаковка...");
  if ((compr_length = squeeze (inf,ouf1)) < 0L)
  {
    printf ("\nОшибка ввода-вывода.\n");
    return;
  }
  printf ("\rУпаковка завершена.\n");
  fgetpos (inf,&nocompr_length);
  l1 = nocompr_length;
  percent = 10000L - compr_length * 10000L / nocompr_length;
  rewind (ouf1);
  printf ("Распаковка.");
  if (unsqu (ouf1,ouf2))
  {
    printf ("\nОшибка ввода-вывода.\n");
    return;
  }
  printf ("\rРаспаковка завершена.                       \n\n");
  printf ("  Исходный файл : %ld\n  Упакованный файл : %ld\n"
	  "  Упакован на %ld.%ld%%.\n\n",
	   nocompr_length,compr_length,percent / 100L,percent % 100L);
  printf ("Сравнение исходного и распакованного файлов...");
  fgetpos (ouf2,&l2);
  if (l1 != l2)
    printf ("\b\b\b неуспешно.\n"
            "Файлы имеют различную длину.\n");
  else
  {
    rewind (inf);
    rewind (ouf2);
    while (l1)
    {
      lr = fread (bf1,1,512,inf);
      l1 -= (long)lr;
      if (lr != 512 && l1)
      {
        printf ("\nОшибка ввода-вывода.\n");
        return;
      }
      lr = fread (bf2,1,512,ouf2);
      l2 -= (long)lr;
      if (lr != 512 && l2)
      {
        printf ("\nОшибка ввода-вывода.\n");
        return;
      }
      if (memcmp (bf1,bf2,512))
      {
	printf ("\b\b\b неуспешно.\n"
		"Несовпадение обнаружено в %ld блоке по 512.\n",
		(nocompr_length - l1) / 512L);
	break;
      }
    }
    printf ("\b\b\b успешно.\n");
  }
  fclose (inf);
  fclose (ouf1);
  fclose (ouf2);
}


static BYTE buffer [0x4500];
static BYTE outbuf [36];
static long wrought_bytes;
static BYTE index_byte;
static BYTE index_bit;

static int last_occurence[256],
	   char_list[0x4500];

# define  put_byte(byte)  outbuf [index_byte++ + 2] = (byte);

static int put_bit (FILE *f, BYTE bit)
{
  *(WORD *)outbuf >>= 1;
  *(WORD *)outbuf |= (bit & 1) ? 0x8000 : 0;
  if (++index_bit == 0x10)
  {
    if (fwrite (outbuf,1,index_byte + 2,f) != index_byte + 2)
      return -1;
    wrought_bytes += index_byte + 2;
    index_bit = index_byte = 0;
  }
  return 0;
}

static int put_rest (FILE *f)
{
  *(WORD *)outbuf >>= 0x10 - index_bit;
  if (fwrite (outbuf,1,index_byte + 2,f) != index_byte + 2)
    return -1;
  wrought_bytes += index_byte + 2;
  return 0;
}
/* Процедура упаковки файла */
long squeeze (FILE *inf, FILE *outf)
{
 WORD       readed_size,
            i;
 WORD       len,
	    maxlen;
 int        span,
      buffer_top,
	    s_minimum,
	    i_minimum,
	    j;
 long       bytes_total,
	    bytes_now;
 long       perc, perc_old;

  bytes_total = filelength ( fileno ( inf ) );

  wrought_bytes = 0L;
  index_bit = index_byte = 0;
  bytes_now = 0L;

  readed_size = fread ( buffer, 1, 0x4500, inf );
  buffer_top = readed_size;

  /* Заполнение массивов индексов */
  for ( i = 0; i < 256; i++ ) last_occurence[i] = -1;
  char_list[0] = -1;
  last_occurence[ (WORD) *buffer ] = 0;

  if (put_bit (outf,1))  return -1L;
  put_byte (*buffer);

  perc_old = -1L;

  for (i = 1; i < buffer_top; i++)
  {
   BYTE  *ptr = buffer + i;
   int    s;

    perc = ( 10000L * i + 10000L * bytes_now )/ ( bytes_total );
    if (  perc - perc_old > 18 )
    {
      printf( "\rОбработано %3ld.%02ld%%  ", perc/100L, perc%100L );
      perc_old = perc;
    }
    char_list[i] = last_occurence[ (WORD) *ptr ];
    last_occurence[ (WORD) *ptr ] = i;

    len = 0;
    maxlen = (buffer_top - i < 0x100 ? buffer_top - i : 0x100);
    s_minimum = -(i > 0x2000 ? 0x2000 : i);
    i_minimum = (i > 0x2000 ? i-0x2000 : 0);

    /* Просмотр буфера назад по указателям */
    for (j = char_list[i] ; j >= i_minimum;
    j = char_list[j] )
    {
     WORD l;

      if ( j < i_minimum ) break;
      s = j - i;

      for (l = 1; l < maxlen && *(ptr + l) == *(ptr + s + l); l++) ;

      if (l > len)
      {

        len = l;
        span = s;
        if (l >= maxlen) break;
      }
    }
    if( len > maxlen ) len = maxlen;
    if (span >= -0xff && len >= 2 || span < -0xff && len > 2)
    {
    if (put_bit (outf,0))  return -1L;

    for ( j = 1; j < len; j++ )
    {
      i++;
      char_list[i] = last_occurence[ (WORD) *(ptr+j) ];
      last_occurence[ (WORD) *(ptr+j) ] = i;
    }


      if (len <= 5 && span >= -0xff)
      {
        len -= 2;
        if (put_bit (outf,0))  return -1L;
        if (put_bit (outf,len >> 1))  return -1L;
        if (put_bit (outf,len))  return -1L;
        put_byte (span & 0xff);
      }
      else
      {
        if (put_bit (outf,1))  return -1L;
        put_byte (span & 0xff);
        if (len <= 9) {
          len = (len - 2) | (((WORD)span >> 5) & ~0x7);
          put_byte( len );
        }
        else
        {
          put_byte (((WORD)span >> 5) & ~0x7);
          put_byte (len-1); /* ! */
        }
      }
    }
    else
    {
      if (put_bit (outf,1))  return -1L;
      put_byte (buffer [i]);
    }
    if ( i > 0x4000 ) 
    { /* Смещаем буфер на 0x2000 и читаем очередную порцию */

      /* Коррекция указателей */
      for ( j=0; j<256; j++ )
      last_occurence[j] = ( last_occurence[j] < 0x2000 ? -1 :
                            last_occurence[j] - 0x2000 );
      for ( j=0x2000; j<buffer_top; j++ )
      {
        buffer[j-0x2000] = buffer[j];
        char_list[j-0x2000] = char_list[j] <0x2000 ? -1 : char_list[j] - 0x2000;
      }
      i -= 0x2000;
      buffer_top -= 0x2000;
      bytes_now += 0x2000;

      readed_size = fread( buffer+buffer_top, 1, 0x4500 - buffer_top, inf );
      buffer_top += readed_size;
    }
  }
  if (put_bit (outf,0))  return -1L;
  if (put_bit (outf,1))  return -1L;
  put_byte (-0xff);
  put_byte (0);
  put_byte (0);
  if (put_rest (outf))  return -1L;
  return wrought_bytes;
}

/* Процедура распаковки файла */
int unsqu (FILE *ifile,FILE *ofile){
    int len;
    int span;
    long fpos;
    bitstream bits;
    static BYTE data[0x4500], *p=data;

    initbits(&bits,ifile);
    for(;;){
        if(ferror(ifile)) {printf("\nread error\n"); return(FAILURE); }
        if(ferror(ofile)) {printf("\nwrite error\n"); return(FAILURE); }
        if(p-data>0x4000){
            fwrite(data,sizeof data[0],0x2000,ofile);
            p-=0x2000;
            memcpy(data,data+0x2000,p-data);
            putchar('.');
        }
        if(getbit(&bits)) {
            *p++=getc(ifile);
            continue;
        }
        if(!getbit(&bits)) {
            len=getbit(&bits)<<1;
            len |= getbit(&bits);
            len += 2;
            span=getc(ifile) | 0xff00;
        } else {
            span=(BYTE)getc(ifile);
            len=getc(ifile);
            span |= ((len & ~0x07)<<5) | 0xe000;
            len = (len & 0x07)+2;
            if (len==2) {
                len=getc(ifile);

                if(len==0)
                    break;    /* end mark of compreesed load module */

                if(len==1)
                    continue; /* segment change */
                else
                    len++;
            }
        }
        for( ;len>0;len--,p++){
            *p=*(p+span);
        }
    }
    if(p!=data)
        fwrite(data,sizeof data[0],p-data,ofile);

    return(SUCCESS);
}


/*-------------------------------------------*/

/* get compress information bit by bit */
void initbits(bitstream *p,FILE *filep){
    p->fp=filep;
    p->count=0x10;
    p->buf=getw(filep);
    /* printf("%04x ",p->buf); */
}

int getbit(bitstream *p) {
    int b;
    b = p->buf & 1;
    if(--p->count == 0){
        (p->buf)=getw(p->fp);
        /* printf("%04x ",p->buf); */
        p->count= 0x10;
    }else
        p->buf >>= 1;

    return b;
}

void setenvp(); /* Экономим память, исключив ненужный модуль */
