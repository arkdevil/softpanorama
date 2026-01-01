# include <stdio.h>
# include <io.h>
# include "cc.h"

# define  WORD	unsigned int
# define  BYTE	unsigned char
# define  SUCCESS 0
# define  FAILURE 1
# define buffer_length 0x4500
# define maximum_len 0x100

# define tmpfname  "$tmpfil$.cc"

void main (int ac,char **av)
{


 long squeeze (FILE *inf,FILE *outf);

 FILE *inf,
      *ouf1,
      *ouf2;
 long  compr_length,
       nocompr_length,
       l1, l2,
       percent;
 WORD  m1,m2;
 WORD  *pword;
 unsigned
       lr;
 static char
       bf1 [512], bf2 [512];

  printf ("CC 1.00 - упаковщик COM-файлов. (C) Красильников 1991.\n");
  if (ac != 3)
  {
    printf ("Формат вызова: %s <входной файл> <выходной файл>\n",av [0]);
    return;
  }

  if (!(inf = fopen (av [1],"rb")))
  {
    printf ("Невозможно открыть входной файл.\n");
    return;
  }

  nocompr_length = filelength ( fileno ( inf ) );
  l2 = (long) nocompr_length + (long) frog_length + 0x200L;
  if (l2 > 0xFFF0 )
  {
    printf ( "Этот файл слишком длинный - сжать нельзя!\n" );
    return;
  }

  fread ( bf1, 1, 2, inf );
  if ( bf1[0] == 'M' && bf1[1] == 'Z' )
  {
    printf ( "Это EXE-файл - сжать нельзя!\n" );
    return;
  }
  rewind ( inf );

  if (!(ouf1 = fopen ( tmpfname,"wb+")))
  {
    printf ("Невозможно открыть промежуточный файл.\n");
    return;
  }

  if ((compr_length = squeeze (inf,ouf1)) < 0L)
  {
    printf ("\nОшибка ввода-вывода.\n");
    return;
  }

  printf ("\rУпаковка завершена.\n");

  l1 = compr_length + frog_length;
  percent = 10000L - l1 * 10000L / nocompr_length;
  m1 = compr_length;
  m2 = nocompr_length + frog_length + 0x200;

  if ( l1 > nocompr_length )
  {
    printf ("Файл %s сжать не удалось.\n", av[1] );
    remove ( tmpfname );
    return;
  }

  pword = ( WORD* ) ( frog_bin + 1 );
  *pword = m2;
  pword = ( WORD* ) ( frog_bin + 4 );
  *pword = m1;

  if (!(ouf2 = fopen (av [2],"wb+")))
  {
    printf ("Невозможно открыть выходной файл.\n");
    return;
  }

  if ( frog_length != fwrite ( frog_bin, 1, frog_length, ouf2 ) )
  {
    printf ("\nОшибка ввода-вывода.\n");
    return;
  }

  rewind (ouf1);

  printf ("  Исходный файл : %ld\n  Упакованный файл : %ld\n"
	  "  Упакован на %ld.%ld%%.\n\n",
	   nocompr_length,compr_length+frog_length,
	   percent / 100L,percent % 100L);

  while (lr = fread (bf1,1,512,ouf1) )
  {
    if ( lr != fwrite (bf1,1,lr,ouf2) )
    {
      printf ("\nОшибка ввода-вывода.\n");
      return;
    }
  }
  fclose (inf);
  fclose (ouf1);
  remove ( tmpfname );
  fclose (ouf2);
}


static BYTE buffer [buffer_length];
static BYTE outbuf [36];
static long wrought_bytes;
static BYTE index_byte;
static BYTE index_bit;

static int last_occurence[256],
	   char_list[buffer_length];

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

  readed_size = fread ( buffer, 1, buffer_length, inf );
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
        if (put_bit ( outf,0 ) )  return -1L;
        if (put_bit ( outf, (BYTE) (len >> 1) ) )  return -1L;
        if (put_bit ( outf, (BYTE) len ) )  return -1L;
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

      readed_size = fread( buffer+buffer_top, 1, buffer_length - buffer_top, inf );
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


void setenvp();
