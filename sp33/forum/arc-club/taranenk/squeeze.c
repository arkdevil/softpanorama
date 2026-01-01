# pragma inline

# include <stdio.h>

# define  WORD  unsigned int
# define  BYTE  unsigned char

static BYTE buffer [0x4500];
static BYTE outbuf [36];
static long wrought_bytes;
static BYTE index_byte;
static BYTE index_bit;

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

long squeeze (FILE *inf, FILE *outf)
{
 WORD       readed_size,
            i;
 BYTE	    len,
            maxlen;
 int        span;

  wrought_bytes = 0L;
  index_bit = index_byte = 0;
  while (readed_size = fread (buffer,1,0x4500,inf))
  {
    if (put_bit (outf,1))  return -1L;
    put_byte (*buffer);
    for (i = 1; i < readed_size; i++)
    {
     BYTE  *ptr = buffer + i;
     int    s;

      len = 0;
      maxlen = (readed_size - i < 0xff ? readed_size - i : 0xff);
      _ES = _DS;
      asm cld;
      for (s = -(i < 0x2000 ? i : 0x2000); s < 0; s++)
      {
       BYTE l;

	/* while (*ptr != *(ptr + s) && s) s++; */
	_DI = (unsigned)(ptr + s);
	_CX = -s;
	_AL = *ptr;
	asm repne scasb;
	asm jnz short no_cmp;
	asm inc cx;
	no_cmp: ;
	asm jcxz not_found;
	s = -_CX;
	/* for (l = 0; l < maxlen && *(ptr + l) == *(ptr + s + l); l++) ; */
	_SI = (unsigned)ptr;
	_DI = (unsigned)(ptr + s);
	_CX = maxlen;
	asm repe cmpsb;
	asm jz short cmp;
	asm inc cx;
	cmp: ;
	l = maxlen - _CX;
	if (l > len)
	{
	  len = l;
	  span = s;
	  if (l == maxlen) break;
	}
      }
      not_found: ;
      if (span >= -0xff && len >= 2 || span < -0xff && len > 2)
      {
	if (put_bit (outf,0))  return -1L;
	i += len - 1;
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
	  if (len <= 9)
	    len = (len - 2) | (((WORD)span >> 5) & ~0x7);
	  else
	    put_byte (((WORD)span >> 5) & ~0x7);
	  put_byte (len);
	}
      }
      else
      {
	if (put_bit (outf,1))  return -1L;
	put_byte (buffer [i]);
      }
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
