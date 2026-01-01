#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <process.h>

void main(int argc, char *argv[])
{
  FILE *Input, *Output;
  char line[256], name[256], ext[4] = ".01", *c;
  int  number = 1;

  printf("This is uuprep, Version 1.0, written 1992 by Johannes Martin\n");
  if (argc != 3)
    {
      printf("\nuuprep: wrong number of arguments\n\n");
      printf("uuprep: PREPare files for UUdecoding\n\n");
      printf("Usage: uuprep <input-file> <output-file>\n");
      printf("       \".uue\" will be appended to both filenames\n\n");
      exit(1);
    }
  if (strcmp(argv[1], argv[2]) == 0)
    {
      printf("uuprep: input and output file have same name\n");
      exit(1);
    }
  strcpy(name, argv[1]);
  strcat(name, ".uue");
  if ((Input = fopen(name, "r")) == NULL)
    {
      printf("uuprep: file \"%s\" not found\n", name);
      exit(1);
    }
  while (fgets(line, 256, Input) != NULL)
    {
      if (((c = strstr(line, "part")) != NULL) &&
          (*(c + 6) == '/'))
        {
          ext[1] = *(c + 4);
          ext[2] = *(c + 5);
        }
      else
        if (strncmp(line, "BEGIN--cut here--cut here", 25) == 0)
          {
            strcpy(name, argv[2]);
            strcat(name, ext);
            if ((Output = fopen(name, "w")) == NULL)
              {
                printf("uuprep: could not create file \"%s\"\n", name);
                fclose(Input);
                exit(1);
              }
            while ((fgets(line, 256, Input) != NULL) &&
                   (strncmp(line, "END--cut here--cut here", 23) != 0))
              fputs(line, Output);
            fclose(Output);
          }
    }
  fclose(Input);
  strcpy(name, argv[2]);
  strcat(name, ".uue");
  if ((Output = fopen(name, "w")) == NULL)
    {
      printf("uuprep: could not create file \"%s\"\n", name);
      exit(1);
    }
  while (1)
    {
      ext[1] = number / 10 + '0';
      ext[2] = number % 10 + '0';
      strcpy(name, argv[2]);
      strcat(name, ext);
      if ((Input = fopen(name, "r")) == NULL)
        break;
      while (fgets(line, 256, Input) != NULL)
        fputs(line, Output);
      fclose(Input);
      unlink(name);
      number++;
    }
  fclose(Output);
  strcpy(name, argv[2]);
  strcat(name, ".uue");
  execlp("uudecode", "uudecode", name, NULL);
}
