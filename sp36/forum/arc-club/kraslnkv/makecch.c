/* Эта программа генерирует текстовый файл cc.h */
/* по двоичному файлу frog.bin                  */

#include <stdio.h>

 FILE* inf;
 FILE* ouf;
 int   froglen, i;
 unsigned char  buff[1024]; /* Длина frog.bin должна быть меньше */

void main()
{
  inf = fopen ( "frog.bin", "rb" );
  ouf = fopen ( "cc.h", "wt" );

  froglen = fread ( buff, 1, 1024, inf );

  fprintf ( ouf, "# define frog_length %d\n\n", froglen );

  fprintf ( ouf, "char frog_bin [] = {\n" );

  for ( i = 0; i < froglen; i++ )
  {
     fprintf ( ouf, "0x%hx", ( unsigned char ) buff[i] );
     if ( i < froglen-1 ) fprintf ( ouf, ", " );
     if ( ( i % 10 ) == 9 ) fprintf ( ouf, "\n" );
  }
  fprintf ( ouf, "};\n" );
  fclose ( inf );
  fclose ( ouf );
}
