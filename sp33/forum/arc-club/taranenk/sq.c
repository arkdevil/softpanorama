# include <stdio.h>
# include <mem.h>

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
  printf ("\b\b\b завершена.\n");
  fgetpos (inf,&nocompr_length);
  l1 = nocompr_length;
  percent = 10000L - compr_length * 10000L / nocompr_length;
  rewind (ouf1);
  printf ("Распаковка...");
  if (unsqu (ouf1,ouf2))
  {
    printf ("\nОшибка ввода-вывода.\n");
    return;
  }
  printf ("\b\b\b завершена.\n\n");
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
