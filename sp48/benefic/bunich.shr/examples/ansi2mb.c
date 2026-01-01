/****************************************************************
*                                                               *
*   M  A  C  R  O  B  A  T    (C) 1992 Л.Г.Бунич                *
*                                                               *
*   ANSI2MB...... конвертор ANSI-картинок в формат MacroBat     *
*   Вход......... текстовый файл, содержащий ANSI-команды       *
*   Ограничение.. обрабатываются только коды A,C,H,J,M          *
*                 (игнорируются D,K,S,U)                        *
*   Выход........ соответствующая программа на языке MacroBat   *
*   Запуск....... ANSI2MB  исходный_файл  выходной_файл         *
*                                                               *
****************************************************************/

#include <stdio.h>
#include <string.h>

#define ESC  '\x1B'
#define ZERO '\x00'

int knum, N[40];
char buf[251], b[251], *pnum, rout[251], *pout;
FILE *hin, *hout;

void main(int argc, char* argv[]) {

  void GetNum(), flush(), output(char *);
  int k, clr, nl, nc;
  char rin[251], *pin, *pbuf, *p1, *p;
  char c, code, FG[20]="white", BG[20]="black", BRIGHT[2]="";

  if (argc != 3) {
    printf("\nSyntax:  ANSI2MB  ANSIfile  MBfile\n");
    return;
  }
  if ((hin = fopen(argv[1],"rt")) == NULL) {
    printf("\nCannot open input file.\n");
    return;
  }

  if ((hout = fopen(argv[2],"wt")) == NULL) {
    printf("\nCannot open output file.\n");
    return;
  }
  rout[0]=ZERO;  pout=rout;
GetIn:
  if (fgets(rin,250,hin) == NULL) goto inend;
  pin=rin;
Choice:
  pbuf=buf;  p1=pin;
  if (*pin == ESC)  goto GetESC;
  if (*pin == ZERO) goto GetIn;
  if (*pin == '\n') { ++pin; goto Choice; }
  while ((c=*(pin++)) != ESC && c != ZERO && c != '\n')
    *(pbuf++)=c;
  --pin;  *pbuf = ZERO;
  if (p1==rin) {
    sprintf(b,"-- %s",buf);  output(b); }
  else {
    sprintf(b,"put %s%s ON %s \"%s\"",FG,BRIGHT,BG,buf);
    output(b); }
  goto Choice;

GetESC:
  while ( isdigit(c = *(++pin)) || c == ';' || c == '[')
    *(pbuf++) = c;
  *pbuf = ZERO;

  if ( buf[0] != '[' ) goto Unknown;
  p=strchr("aAcCdDhHjJkKmMsSuU",*pin);
  if (p==NULL) goto Unknown;
  code=toupper(*p);
  switch(code) {
    case 'A':
//      N[0]=1;
//      GetNum();
      if (p1 != rin)  sprintf(b,"put +0,1");
        else          sprintf(b,"put +1,1");
      output(b);  break;
    case 'C':
      N[0]=1;
      GetNum();
      sprintf(b,"put +0,+%d",N[0]);  output(b);
      break;
    case 'D':  break;
    case 'H':
      pnum=buf+1;
      GetNum();
      nl=nc=1;
      if (knum>0) {
        nl=N[0];
        if (knum>1) nc=N[1];
      }
      sprintf(b,"put %d,%d",nl,nc);  output(b);
      break;
    case 'J':
      sprintf(b,"cls %s ON %s",FG,BG);  output(b);
      break;
    case 'K':
      sprintf(b,"put +1,1");  output(b);
      break;
    case 'M':
      GetNum();
      for (k=0; k < knum; ++k) {
        clr = N[k];
        if ( clr > 01 && clr < 30) continue;
        if ( clr > 47) continue;
        switch (clr) {
          case  0:  strcpy(FG,"white");  strcpy(BG,"black");
                    BRIGHT[0] = ZERO;  break;
          case  1:  strcpy(BRIGHT,"+");  break;

          case 30:  strcpy(FG,"black");   break;
          case 31:  strcpy(FG,"red");     break;
          case 32:  strcpy(FG,"green");   break;
          case 33:  strcpy(FG,"brown");   break;
          case 34:  strcpy(FG,"blue");    break;
          case 35:  strcpy(FG,"magenta"); break;
          case 36:  strcpy(FG,"cyan");    break;
          case 37:  strcpy(FG,"white");   break;

          case 40:  strcpy(BG,"black");   break;
          case 41:  strcpy(BG,"red");     break;
          case 42:  strcpy(BG,"green");   break;
          case 43:  strcpy(BG,"brown");   break;
          case 44:  strcpy(BG,"blue");    break;
          case 45:  strcpy(BG,"magenta"); break;
          case 46:  strcpy(BG,"cyan");    break;
          case 47:  strcpy(BG,"white");   break;
          default:    goto Unknown;
        }
      }
      break;
    case 'S':  break;
    case 'U':  break;
    default:
      goto Choice;
  }
  ++pin;
  goto Choice;

Unknown:
  printf("\n** unrecognized command: %s%c",buf,*pin);
  goto Choice;

inend:
  flush();
  fclose(hin); fclose(hout);
}

/***************************************************************/

void GetNum() {
  char *p;

  knum=0;  pnum=buf+1;
count:
  p=pnum;
  while (isdigit(*p)) ++p;
  sscanf(pnum,"%d",N+(knum++));
  pnum=p+1;
  if (*p == ';') goto count;
}

/***************************************************************/

void output(char *txt) {

  void flush();
  if (*pout != 'p' || *txt != 'p') {
    flush();  strcpy(pout,txt);  return; }
  if (strlen(pout) + strlen(txt) < 83)
    strcat(pout,txt+3);
  else {
    flush();  strcpy(pout,txt);  }
}

/***************************************************************/

void flush() {

  if (pout[0] != ZERO) fprintf(hout,"%s\n",pout);
}
